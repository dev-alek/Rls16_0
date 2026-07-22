block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: r-yandex-rep.p $
$Archive: rep/r-yandex-rep.p $

Утилита проверки целостности свободной зоны марок и восстановления

Автор: Сергей Сливенко
Дата создания: 25/05/2020
Author: Sergey Slivenko
Creation date: 25/05/2020

*/

define variable vss-revision as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-yandex-rep.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-yandex-rep.p $":U .
define variable vss-description as character no-undo initial "Отчет по невалидным маркам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ ref/grplibfn.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }

define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter p-cd-pay-recid     as character no-undo .
define input parameter p-rep-type         as integer no-undo .
define input parameter p-file             as character no-undo .
define input parameter p-RRN              as character no-undo .

define buffer buf_clients   for ub.clients .
define buffer buf_goods     for ub.goods .
define buffer buf_obj-list  for obj-list.
define buffer buf_gds-list  for gds-list.
define buffer buf_cash-pay  for ub.cash-pay .
define buffer buf_shift-obj for ub.shift-obj .
    
define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num        as integer   no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name       as character no-undo.         /* Наименование отчёта */
    
define variable v-azk-list          as character no-undo .
define variable v-period            as character no-undo .
define variable v-color             as character no-undo .    
define stream str-marks .
define stream OutStr-html.
    
function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date) forward.

function fnc-obj-name returns character 
    (input p-obj-code as integer, input p-obj-type as character) forward.
        
find first buf_cash-pay no-lock where recid(buf_cash-pay) = integer(p-cd-pay-recid) .

define temp-table tt-trans
    field azk      as character
    field qnty     as decimal
    field summ     as decimal
    field dt       as datetime
    field RRN      as character
    field transID  as character
    field gds-name as character
    field taken    as logical
    index pi as primary
    azk RRN
    .
    
define temp-table tt-rep
    field obj-type     as character
    field obj-code     as integer
    field obj-name     as character
    field gds-name     as character
    field shift-date   as date
    field shift-num    as integer
    field RRN-TH       as character
    field RRN-RN       as character
    field transID      as character
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    field dt-TH        as date
    field time-TH      as character
    field dt-RN-cart   as datetime
    field dt-yandex    as datetime
    field azk          as character
    index pi as primary
    obj-type obj-code RRN-TH
    .

define temp-table tt-itog
    field qnty-del     as integer
    field qnty-TH      as integer
    field qnty-RN      as integer
    field qnty-only-TH as integer 
    .
    
define temp-table tt-obj
    field obj-type     like ub.clients.obj-type
    field obj-code     like ub.clients.obj-code
    field obj-name     like ub.clients.obj-name
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    index pi as primary
    obj-type obj-code
    .
    
define temp-table tt-shift 
    field obj-type     as character
    field obj-code     as integer
    field shift-date   as date
    field shift-num    as integer
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    .


/*определение товара*/
/*    for each buf_obj-list :*/
/*    end .                  */
    
run waitfram-show in this-procedure ( "ЖДИТЕ... Обработка файла транзакций") .
if p-rep-type = 1
    then 
do :
    run imp-RN-cart .
end .
if p-rep-type = 2
    then 
do :
    run imp-yandex .
end .
run waitfram-hide in this-procedure .
    
    
    
run waitfram-show in this-procedure ( "ЖДИТЕ... Сборка данных для отчёта") .
run make-rep .
run waitfram-hide in this-procedure .
    
if x-TOG-Shift
    then 
do :
    v-period = ("С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
        " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End))
        .
end .
else 
do :
    v-period = ("С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) +
        " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) )
        .
end .
    
for each obj-list :
    v-azk-list = v-azk-list + obj-list.obj-name + ", " .
end .
v-azk-list = trim(v-azk-list) .
v-azk-list = trim(v-azk-list, ",") .
    
if p-rep-type = 1
    then 
do :
    run my-rep-ul in this-procedure .
end .
    
if p-rep-type = 2
    then 
do :
    run my-rep-fl in this-procedure .
end .


procedure make-rep :
    define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
    define buffer buf_chk-pay-attr for ub.chk-pay-attr .
    define buffer buf_chk-doc      for ub.chk-doc .
    define buffer buf_chk-gds      for ub.chk-gds .
    define buffer buf_goods        for ub.goods .
  
    define variable v-RRN  as character no-undo .
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .
    empty TEMP-TABLE tt-itog .
    create tt-itog .
    
    if p-RRN > ""
        then 
    do :
        find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "CPDOC"
            and buf_chk-pay-attr.attr-value = p-RRN
            no-error .
        if not available buf_chk-pay-attr
            then 
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "CPDOC"
                and int64(buf_chk-pay-attr.attr-value) = int64(p-RRN)
                no-error .
        end .
        if not available buf_chk-pay-attr
            then 
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "RRN"
                and buf_chk-pay-attr.attr-value = p-RRN
                no-error .
        end .
        if not available buf_chk-pay-attr
            then 
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "RRN"
                and int64(buf_chk-pay-attr.attr-value) = int64(p-RRN)
                no-error .
        end .
    
        find first tt-trans exclusive-lock where tt-trans.RRN > ""
            and int64(tt-trans.RRN) = int64(p-RRN)
            and not tt-trans.taken
            no-error .
    
        if available buf_chk-pay-attr
            then 
        do :
            for first buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-pay-attr.doc-code
                and buf_chk-gds-pay.cpline-num = buf_chk-pay-attr.line-num,
                first bar-code no-lock where bar-code.b-code = buf_chk-gds-pay.b-code,
                first buf_goods no-lock where buf_goods.gds-code = bar-code.gds-code
                :
                create tt-rep .
                assign
                    tt-rep.obj-type   = buf_chk-gds-pay.obj-type
                    tt-rep.obj-code   = buf_chk-gds-pay.obj-code
                    
                    tt-rep.gds-name   = buf_goods.gds-name
                    tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                    tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                    tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                    tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99") 
                    tt-rep.shift-date = buf_chk-gds-pay.shift-date
                    tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                    tt-rep.RRN-TH     = p-RRN
                    .
                    tt-rep.obj-name   = fnc-obj-name(buf_chk-gds-pay.obj-code, buf_chk-gds-pay.obj-type) .
                if available tt-trans
                    then 
                do :
                    assign
                        tt-rep.dt-RN-cart   = tt-trans.dt
                        tt-rep.qnty-RN-cart = tt-trans.qnty
                        tt-rep.summ-RN-cart = tt-trans.summ
                        tt-rep.RRN-RN       = tt-trans.RRN
                        tt-rep.transID      = tt-trans.transID
                        tt-rep.azk          = tt-trans.azk
                        tt-trans.taken      = true      
                        tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                        .
                    if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .      
                end .
                else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .    
                 
            end .
        end .
        else 
        do :
            if available tt-trans
                then 
            do :
                create tt-rep .
                assign
                    tt-rep.azk          = tt-trans.azk
                    tt-rep.gds-name     = tt-trans.gds-name
                    tt-rep.dt-RN-cart   = tt-trans.dt
                    tt-rep.qnty-RN-cart = tt-trans.qnty
                    tt-rep.summ-RN-cart = tt-trans.summ
                    tt-rep.RRN-RN       = tt-trans.RRN
                    tt-rep.transID      = tt-trans.transID
                    tt-trans.taken      = true
                    tt-itog.qnty-RN     = tt-itog.qnty-RN + 1
                    .
            end .
        end .
                                          
        return .
    end .
    
    for each obj-list /* _obj: for each obj-list: */
      :
      if x-TOG-Shift
      then do :
        if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            ub.chk-doc.shift-date >= X-date-Start and
            ub.chk-doc.shift-date <= X-date-End and
            ub.chk-doc.out-code > "" )
        then do:
          run rep/rpychk0.p ( input "r-shftc2"
              ,input obj-list.obj-type
              ,input obj-list.obj-code
              ,input ? /*p-date-from*/
              ,input ? /*p-date-to*/
              ,input X-date-Start /*p-shift-date-from*/
              ,input x-Date-End /*p-shift-date-to*/
              ,input x-Shift-Start /*p-shift-num-start*/
              ,input x-Shift-End /*p-shift-num-end*/
              ,input ? /*p-inkas-code*/
              ).
        end .
      end .
      else do :
        if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            ub.chk-doc.chk-date >= X-date-Start and
            ub.chk-doc.chk-date <= X-date-End and
            ub.chk-doc.out-code > "" )
        then do:
          run rep/rpychk0.p ( input "r-shftc2"
              ,input obj-list.obj-type
              ,input obj-list.obj-code
              ,input x-date-Start /*p-date-from*/
              ,input x-Date-End /*p-date-to*/
              ,input ? /*p-shift-date-from*/
              ,input ? /*p-shift-date-to*/
              ,input ? /*p-shift-num-start*/
              ,input ? /*p-shift-num-end*/
              ,input ? /*p-inkas-code*/
              ).
        end .
      end .
    end . /* _obj: for each obj-list: */
  
    for each units no-lock where
        lookup( {&petrolium}, units.type) > 0,
        each buf_goods no-lock where
        buf_goods.unit-base = units.unit-name  , first bar-code no-lock where bar-code.gds-code  = buf_goods.gds-code
        :
        obj_:
        for each obj-list /* _obj: for each obj-list: */
            :
            if x-TOG-Shift
                then 
            do :
                if can-find(first ub.chk-doc where
                    ub.chk-doc.obj-type = obj-list.obj-type and
                    ub.chk-doc.obj-code = obj-list.obj-code and
                    ub.chk-doc.shift-date >= X-date-Start and
                    ub.chk-doc.shift-date <= X-date-End and
                    ub.chk-doc.out-code > "" )
                    then 
                do:
                    for each buf_chk-gds-pay no-lock where  buf_chk-gds-pay.b-code = bar-code.b-code  and
                        buf_chk-gds-pay.obj-type = obj-list.obj-type and
                        buf_chk-gds-pay.obj-code = obj-list.obj-code and
                        (
                        buf_chk-gds-pay.shift-date >= X-date-start and
                        buf_chk-gds-pay.shift-date <= X-date-end) :
                        if ((buf_chk-gds-pay.shift-date = x-date-Start and buf_chk-gds-pay.shift-num < X-shift-start)
                            or (buf_chk-gds-pay.shift-date = x-date-End and  buf_chk-gds-pay.shift-num > X-shift-end) )
                            then next.
            
                        if not (buf_chk-gds-pay.pay-code = buf_cash-pay.cdpay-code
                            and buf_chk-gds-pay.curr-code = buf_cash-pay.curr-code)
                            then next .
            
                        v-RRN = '' .
                        for first buf_chk-pay-attr no-lock
                            where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code 
                            and buf_chk-pay-attr.attr-code = "CPDOC" 
                            and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num  :
                            v-RRN = buf_chk-pay-attr.attr-value .
                        end.       
                        if v-RRN = '' 
                            then 
                        do: 
                            for first buf_chk-pay-attr no-lock
                                where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code 
                                and buf_chk-pay-attr.attr-code = "RRN"
                                and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num:
                                v-RRN = buf_chk-pay-attr.attr-value .
                            end.
                        end.
            
                        find first tt-trans exclusive-lock where  tt-trans.RRN > ""
                            and int64(tt-trans.RRN) = int64(v-RRN)
                            and not tt-trans.taken
                            no-error .
            
                        create tt-rep .
                        assign
                            tt-rep.obj-type   = obj-list.obj-type
                            tt-rep.obj-code   = obj-list.obj-code
                            tt-rep.obj-name   = obj-list.obj-name
                            tt-rep.gds-name   = buf_goods.gds-name
                            tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                            tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                            tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                    tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99")
                            tt-rep.shift-date = buf_chk-gds-pay.shift-date
                            tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                            tt-rep.RRN-TH     = v-RRN
                            .
                        if available tt-trans
                            then 
                        do :
                            assign
                                tt-rep.dt-RN-cart   = tt-trans.dt
                                tt-rep.qnty-RN-cart = tt-trans.qnty
                                tt-rep.summ-RN-cart = tt-trans.summ
                                tt-rep.RRN-RN       = tt-trans.RRN
                                tt-rep.transID      = tt-trans.transID
                                tt-rep.azk          = tt-trans.azk
                                tt-trans.taken      = true      
                                tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                                .
                            if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .        
                        end .
                        
                        else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .
                        release tt-rep .
                    end. 
                end .
            end .
            else 
            do :
                if can-find(first ub.chk-doc where
                    ub.chk-doc.obj-type = obj-list.obj-type and
                    ub.chk-doc.obj-code = obj-list.obj-code and
                    ub.chk-doc.chk-date >= X-date-Start and
                    ub.chk-doc.chk-date <= X-date-End and
                    ub.chk-doc.out-code > "" )
                    then 
                do:
                    for each buf_chk-gds-pay no-lock where  buf_chk-gds-pay.b-code = bar-code.b-code  and
                        buf_chk-gds-pay.obj-type = obj-list.obj-type and
                        buf_chk-gds-pay.obj-code = obj-list.obj-code and
                        (
                        buf_chk-gds-pay.chk-date >= X-date-start and
                        buf_chk-gds-pay.chk-date <= X-date-end) :
            
                        if not (buf_chk-gds-pay.pay-code = buf_cash-pay.cdpay-code
                            and buf_chk-gds-pay.curr-code = buf_cash-pay.curr-code)
                            then next .
            
                        v-RRN = '' .
                        for first buf_chk-pay-attr no-lock
                            where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code 
                            and buf_chk-pay-attr.attr-code = "CPDOC" 
                            and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num  :
                            v-RRN = buf_chk-pay-attr.attr-value .
                        end.       
                        if v-RRN = '' 
                            then 
                        do: 
                            for first buf_chk-pay-attr no-lock
                                where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code 
                                and buf_chk-pay-attr.attr-code = "RRN"
                                and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num:
                                v-RRN = buf_chk-pay-attr.attr-value .
                            end.
                        end.
            
                        find first tt-trans exclusive-lock where tt-trans.RRN > ""
                            and int64(tt-trans.RRN) = int64(v-RRN)
                            and not tt-trans.taken
                            no-error .
            
                        create tt-rep .
                        assign
                            tt-rep.obj-type   = obj-list.obj-type
                            tt-rep.obj-code   = obj-list.obj-code
                            tt-rep.obj-name   = obj-list.obj-name
                            tt-rep.gds-name   = buf_goods.gds-name
                            tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                            tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                            tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                            tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99")
                            tt-rep.shift-date = buf_chk-gds-pay.shift-date
                            tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                            tt-rep.RRN-TH     = v-RRN
                            .
                        if available tt-trans
                            then 
                        do :
                            assign
                                tt-rep.dt-RN-cart   = tt-trans.dt
                                tt-rep.qnty-RN-cart = tt-trans.qnty
                                tt-rep.summ-RN-cart = tt-trans.summ
                                tt-rep.RRN-RN       = tt-trans.RRN
                                tt-rep.transID      = tt-trans.transID
                                tt-rep.azk          = tt-trans.azk
                                tt-trans.taken      = true      
                                tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                                .
                            if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .    
                        end .
                        else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .    
                        release tt-rep .
                    end. 
                end .
            end .
    
        end . /* _obj: for each obj-list: */
    end .
  
    for each tt-trans exclusive-lock where not tt-trans.taken :
      
        create tt-rep .
        assign
            tt-rep.azk          = tt-trans.azk
            tt-rep.gds-name     = tt-trans.gds-name
            tt-rep.dt-RN-cart   = tt-trans.dt
            tt-rep.qnty-RN-cart = tt-trans.qnty
            tt-rep.summ-RN-cart = tt-trans.summ
            tt-rep.RRN-RN       = tt-trans.RRN
            tt-rep.transID      = tt-trans.transID
            tt-trans.taken      = true
            .
        tt-itog.qnty-RN     = tt-itog.qnty-RN + 1 
            .
        /*    v-date = date(tt-trans.dt) .                                                    */
        /*    v-time = integer(truncate(MTIME(tt-trans.dt) / 1000, 0)) .                      */
        /*    for first buf_shift-obj no-lock where buf_shift-obj.obj-type = tt-trans.obj-type*/
        /*                                      and buf_shift-obj.obj-code = tt-trans.obj-code*/
        /*                                      and buf_shift-obj.open-date <= v-date         */
        /*                                      and buf_shift-obj.open-time <= v-time         */
        /*                                      and buf_shift-obj.close-date >= v-date        */
        /*                                      and buf_shift-obj.close-time >= v-time        */
        /*                                      :                                             */
        /*      assign                                                                        */
        /*        tt-rep.shift-date = buf_shift-obj.shift-date                                */
        /*        tt-rep.shift-num  = buf_shift-obj.shift-num                                 */
        /*      .                                                                             */
        /*    end .                                                                           */
    
        release tt-rep .
    end .
   
  
    for each tt-rep break by tt-rep.obj-type
        by tt-rep.obj-code
        by tt-rep.shift-date
        by tt-rep.shift-num
        :
        if first-of(tt-rep.obj-type)
            or first-of(tt-rep.obj-code)
            then 
        do :
            create tt-obj .
            assign
                tt-obj.obj-type = tt-rep.obj-type
                tt-obj.obj-code = tt-rep.obj-code
                .
            for first obj-list no-lock where obj-list.obj-type = tt-rep.obj-type
                and obj-list.obj-code = tt-rep.obj-code
                :
                assign 
                    tt-obj.obj-name = obj-list.obj-name .                            
            end .
        end .
    
        if first-of(tt-rep.shift-date)
            or first-of(tt-rep.shift-num)
            then 
        do :
            create tt-shift .
            assign
                tt-shift.obj-type   = tt-rep.obj-type
                tt-shift.obj-code   = tt-rep.obj-code
                tt-shift.shift-date = tt-rep.shift-date
                tt-shift.shift-num  = tt-rep.shift-num
                .
        end .
    
        assign
            tt-obj.qnty-TH      = tt-obj.qnty-TH      + tt-rep.qnty-TH
            tt-obj.summ-TH      = tt-obj.summ-TH      + tt-rep.summ-TH
            tt-obj.qnty-RN-cart = tt-obj.qnty-RN-cart + tt-rep.qnty-RN-cart
            tt-obj.summ-RN-cart = tt-obj.summ-RN-cart + tt-rep.summ-RN-cart
            tt-obj.qnty-yandex  = tt-obj.qnty-yandex  + tt-rep.qnty-yandex
            tt-obj.summ-yandex  = tt-obj.summ-yandex  + tt-rep.summ-yandex
            .
    
        assign
            tt-shift.qnty-TH      = tt-shift.qnty-TH      + tt-rep.qnty-TH
            tt-shift.summ-TH      = tt-shift.summ-TH      + tt-rep.summ-TH
            tt-shift.qnty-RN-cart = tt-shift.qnty-RN-cart + tt-rep.qnty-RN-cart
            tt-shift.summ-RN-cart = tt-shift.summ-RN-cart + tt-rep.summ-RN-cart
            tt-shift.qnty-yandex  = tt-shift.qnty-yandex  + tt-rep.qnty-yandex
            tt-shift.summ-yandex  = tt-shift.summ-yandex  + tt-rep.summ-yandex
            .
    
        if last-of(tt-rep.obj-type)
            or last-of(tt-rep.obj-code)
            then 
        do :
            release tt-obj .
        end .
    
        if last-of(tt-rep.shift-date)
            or last-of(tt-rep.shift-num)
            then 
        do :
            release tt-shift .
        end .
                          
    end .
  
end procedure .
    
procedure imp-RN-cart :
    DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
    DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
    DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
    DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
  
    DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
  
    define variable v-num             as character        no-undo .
    define variable v-azk             as character        no-undo .
    define variable v-summ            as character        no-undo .
    define variable v-qnty            as character        no-undo .
    define variable v-dt              as character        no-undo .
    define variable v-RRN             as character        no-undo .
    define variable v-transID         as character        no-undo .
    define variable v-gds-name        as character        no-undo .
  
    CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.    
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(p-file)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
        .
  
    loopbl:
    do vLine = 1 to 1000000:
        ASSIGN
            vChLine    = STRING(vLine)
            v-azk      = ''
            v-summ     = ''
            v-qnty     = ''
            v-dt       = ''
            v-RRN      = ''
            v-transID  = ''
            v-gds-name = ''
            .
    
        v-RRN = mWorkSheet:Range("P" + vChLine):FORMULA NO-ERROR.  
        if v-RRN = ? then v-RRN = mWorkSheet:Range("P" + vChLine):VALUE NO-ERROR.
    
        if p-RRN > ""
            then 
        do :
            if int64(p-RRN) <> int64(v-RRN) then next loopbl .
        end .
    
        v-num = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.  
        if v-num = ? then v-num = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.
    
        integer(v-num) no-error .
        if error-status:error then next loopbl .
    
        v-azk = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.  
        if v-azk = ? then v-azk = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR. 
    
        v-summ = mWorkSheet:Range("M" + vChLine):FORMULA NO-ERROR.  
        if v-summ = ? then v-summ = mWorkSheet:Range("M" + vChLine):VALUE NO-ERROR.
        v-summ = replace(v-summ, ",", ".") .
    
        decimal(v-summ) no-error .
        if error-status:error then next loopbl .
    
        v-qnty = mWorkSheet:Range("K" + vChLine):FORMULA NO-ERROR.  
        if v-qnty = ? then v-qnty = mWorkSheet:Range("K" + vChLine):VALUE NO-ERROR.
        v-qnty = replace(v-qnty, ",", ".") .
    
        v-dt = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.  
        if v-dt = ? then v-dt = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.
    
        v-transID = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.  
        if v-transID = ? then v-transID = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
    
        v-gds-name = mWorkSheet:Range("J" + vChLine):VALUE NO-ERROR.  
        if v-gds-name = ? then v-gds-name = mWorkSheet:Range("J" + vChLine):FORMULA NO-ERROR.
    
    
        if length(v-azk) > 0
            or length(v-summ) > 0
            or length(v-qnty) > 0
            or length(v-dt) > 0
            or length(v-RRN) > 0
            or length(v-transID) > 0
            or length(v-gds-name) > 0
            then 
        do :
            vNoLine = 0 .
        end.
        else 
        do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl. 
            ELSE NEXT loopbl. 
        end.
    
        /*    find first buf_obj-list no-lock where buf_obj-list.obj-type = {&shop}                            */
        /*                                      and entry(1, buf_obj-list.obj-name, " ") = entry(1, v-azk, " ")*/
        /*                                      no-error .                                                     */
        /*    if not available buf_obj-list then next loopbl .                                                 */
    
        create tt-trans .
        tt-trans.azk       = v-azk .
        tt-trans.qnty      = decimal(v-qnty) .
        tt-trans.summ      = decimal(v-summ) .
        tt-trans.dt        = datetime(v-dt) .
        tt-trans.RRN       = trim(v-RRN) .
        tt-trans.transID   = trim(v-transID) .
        tt-trans.gds-name  = v-gds-name .
        tt-trans.taken     = false .
        release tt-trans .
    
    end.
  
end procedure .

procedure imp-yandex :
    DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
    DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
    DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
    DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
  
    DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
  
    define variable v-num             as character        no-undo .
    define variable v-azk             as character        no-undo .
    define variable v-summ            as character        no-undo .
    define variable v-qnty            as character        no-undo .
    define variable v-dt              as character        no-undo .
    define variable v-RRN             as character        no-undo .
    define variable v-transID         as character        no-undo .
    define variable v-gds-name        as character        no-undo .
  
    define variable v-date            as character        no-undo .
    define variable v-time            as character        no-undo .
  
    CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.    
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(p-file)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
        .
  
    loopbl:
    do vLine = 1 to 1000000:
        ASSIGN
            vChLine    = STRING(vLine)
            v-azk      = ''
            v-summ     = ''
            v-qnty     = ''
            v-dt       = ''
            v-RRN      = ''
            v-transID  = ''
            v-gds-name = ''
            .
    
        /*    v-num = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.                */
        /*    if v-num = ? then v-num = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.*/
        /*                                                                             */
        /*    integer(v-num) no-error .                                                */
        /*    if error-status:error then next loopbl .                                 */

        v-RRN = mWorkSheet:Range("P" + vChLine):FORMULA NO-ERROR.  
        if v-RRN = ? then v-RRN = mWorkSheet:Range("P" + vChLine):VALUE NO-ERROR.
    
        if p-RRN > ""
            then 
        do :
            if int64(p-RRN) <> int64(v-RRN) then next loopbl .
        end .
    
        v-azk = mWorkSheet:Range("B" + vChLine):VALUE NO-ERROR.  
        if v-azk = ? then v-azk = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR. 
    
        v-summ = mWorkSheet:Range("M" + vChLine):FORMULA NO-ERROR.  
        if v-summ = ? then v-summ = mWorkSheet:Range("M" + vChLine):VALUE NO-ERROR.
        v-summ = replace(v-summ, ",", ".") .
    
        decimal(v-summ) no-error .
        if error-status:error then next loopbl .
    
        v-qnty = mWorkSheet:Range("K" + vChLine):FORMULA NO-ERROR.  
        if v-qnty = ? then v-qnty = mWorkSheet:Range("K" + vChLine):VALUE NO-ERROR.
        v-qnty = replace(v-qnty, ",", ".") .
    
        v-date = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.  
        if v-date = ? then v-date = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.
    
        v-time = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.  
        if v-time = ? then v-time = mWorkSheet:Range("F" + vChLine):VALUE NO-ERROR.
    
        v-dt = v-date + "  " + v-time .
        v-dt = trim(v-dt) .
    
        v-transID = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.  
        if v-transID = ? then v-transID = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
    
        v-gds-name = mWorkSheet:Range("N" + vChLine):VALUE NO-ERROR.  
        if v-gds-name = ? then v-gds-name = mWorkSheet:Range("N" + vChLine):FORMULA NO-ERROR.
    
    
        if length(v-azk) > 0
            or length(v-summ) > 0
            or length(v-qnty) > 0
            or length(v-dt) > 0
            or length(v-RRN) > 0
            or length(v-transID) > 0
            or length(v-gds-name) > 0
            then 
        do :
            vNoLine = 0 .
        end.
        else 
        do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl. 
            ELSE NEXT loopbl. 
        end.
    
        /*    find first buf_obj-list no-lock where buf_obj-list.obj-type = {&shop}                                  */
        /*                                      and trim(entry(2, buf_obj-list.obj-name, "№")) = entry(1, v-azk, " ")*/
        /*                                      no-error .                                                           */
        /*    if not available buf_obj-list then next loopbl .                                                       */
    
        create tt-trans .
        tt-trans.azk       = v-azk .
        tt-trans.qnty      = decimal(v-qnty) .
        tt-trans.summ      = decimal(v-summ) .
        tt-trans.dt        = datetime(v-dt) .
        tt-trans.RRN       = trim(v-RRN) .
        tt-trans.transID   = trim(v-transID) .
        tt-trans.gds-name  = v-gds-name .
        tt-trans.taken     = false .
        release tt-trans .
    
    end.
  
end procedure .    
    
procedure my-rep-ul :
  
    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


    run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
  
  &scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  
  
    /* Системная шапка HTML */
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody, td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
    
    put stream OutStr-html unformatted
        '<body>' skip
        '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 140px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '</tr>' skip
        .
                        
 
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="13" style="text-align: center; font-weight:bold;">Отчет по сверке продаж по Юр. Лицам по ' + v-azk-list + '</td>' skip
        '</tr>' skip   
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip  
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;">Параметры: ' + v-period + '</td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '</thead>' skip
        .  
    
    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Номенклатура</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение литры</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (РН-Карт)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (ГБД)</th>' skip
        '       </tr>' skip
        . /* Точка для закрытия Put */
  
    if p-RRN = ""
        then 
    do :
        for each tt-obj by tt-obj.obj-name desc:
            if not trim(tt-obj.obj-name) = ""
                then
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="text-align: left; background-color: yellow;">' + tt-obj.obj-name + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '       </tr>' skip
                    . /* Точка для закрытия Put */
            if tt-obj.obj-name = ""
                then
                
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan = "13" style="text-align: left; font-weight: normal; background-color: yellow;">Расхождения</td>' skip
                    '       </tr>' skip
                    . /* Точка для закрытия Put */       
            for each tt-shift where tt-shift.obj-type = tt-obj.obj-type
                and tt-shift.obj-code = tt-obj.obj-code
                :
                if tt-shift.shift-date <> ?
                    then                     
                    put stream OutStr-html unformatted
                        '       <tr level="2">' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: yellow;">  Смена №' + string(tt-shift.shift-num) + ' от ' + string(tt-shift.shift-date) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '       </tr>' skip
                        . /* Точка для закрытия Put */    
        
                for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
                    and tt-rep.obj-code   = tt-shift.obj-code
                    and tt-rep.shift-date = tt-shift.shift-date
                    and tt-rep.shift-num  = tt-shift.shift-num
                    :
                        if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .
                    put stream OutStr-html unformatted
                        '       <tr level="3">' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                        '       </tr>' skip
                        . /* Точка для закрытия Put */                    
                end . /* tt-rep */                
            end . /* tt-shift */
        end . /* tt-obj */
    end.
    else 
    do :
        for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
            and tt-rep.obj-code   = tt-shift.obj-code
            and tt-rep.shift-date = tt-shift.shift-date
            and tt-rep.shift-num  = tt-shift.shift-num
            :
                if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .
            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                '       </tr>' skip
                . /* Точка для закрытия Put */                    
        end . /* tt-rep */
    end .
    for first tt-itog:

        put stream OutStr-html unformatted
            '       <tfoot>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">Всего транзакций: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH + tt-itog.qnty-only-TH + tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip   
/*            '       <tr>' skip                                                                                                                */
/*            '       <td colspan = "1"></td>' skip                                                                                             */
/*            '       <td colspan = "4" style="text-align: left; font-weight: normal">Кол-во транзакций, по которым есть совпадение: </td>' skip*/
/*            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH) + '</td>' skip                             */
/*            '       <td colspan = "8"></td>' skip                                                                                             */
/*            '       </tr>' skip                                                                                                               */
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">из них с расхождением: </td>' skip
            '       <td style="text-align: right; font-weight: normal"></td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только из ГБД: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-only-TH) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip                  
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только РН-кард: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip 
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">по суммам и кол-ву: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-del) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip  
         
            '       </tfoot>' skip
            . /* Точка для закрытия Put */                    
    end . /* tt-itog */  
    put stream OutStr-html unformatted
        '     </tbody>' skip
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        . /* Точка для закрытия Put */
    output stream OutStr-html close.
  
    run waitfram-hide in this-procedure .
  
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
  
  
end procedure .

procedure my-rep-fl :
  
    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


    run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
  
  &scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  
  
    /* Системная шапка HTML */
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
        '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
        '      htm' skip
        '      .rotate ' + chr(123) skip
        '        -webkit-transform: rotate(-90deg);' skip
        '        -moz-transform: rotate(-90deg);' skip
        '        -ms-transform: rotate(-90deg);' skip
        '        -o-transform: rotate(-90deg);' skip
        '        transform: rotate(-90deg);' skip

        /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
        '        -webkit-transform-origin: 50% 50%;' skip
        '        -moz-transform-origin: 50% 50%;' skip
        '        -ms-transform-origin: 50% 50%;' skip
        '        -o-transform-origin: 50% 50%;' skip
        '        transform-origin: 50% 50%;' skip

        /* Should be unset in IE9+ I think.*/
        '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
        '          ' + chr(125) skip
        '            th' + ' ' + chr(123) skip
        '            border: 1px black solid;' skip
        '            word-wrap: break-word;' skip
        '          ' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
    
    put stream OutStr-html unformatted
        '<body>' skip
        '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 140px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 200px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '</tr>' skip
        .
                        
 
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="14" style="text-align: center; font-weight:bold;">Отчет по сверке продаж по Физ. Лицам по ' + v-azk-list + '</td>' skip
        '</tr>' skip   
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip  
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;">Параметры: ' + v-period + '</td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '</thead>' skip
        .  
    
    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px; width: 140px;">Номенклатура</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение литры</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата Яндекс (московск. время)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">ID Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (Яндекс)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (ГБД)</th>' skip
        '       </tr>' skip
        . /* Точка для закрытия Put */

    if p-RRN = ""
        then 
    do :

        for each tt-obj by tt-obj.obj-name desc:
            if not trim(tt-obj.obj-name) = ""
                then
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td style="text-align: left; font-weight: normal; background-color: yellow;">' + tt-obj.obj-name + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '       </tr>' skip
                    . /* Точка для закрытия Put */
            if tt-obj.obj-name = ""
                then
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan = "14" style="text-align: left; font-weight: normal; background-color: yellow;">Расхождения</td>' skip
                    '       </tr>' skip
                    . /* Точка для закрытия Put */   
            for each tt-shift where tt-shift.obj-type = tt-obj.obj-type
                and tt-shift.obj-code = tt-obj.obj-code
                :
                if tt-shift.shift-date <> ?
                    then
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: yellow;">  Смена №' + string(tt-shift.shift-num) + ' от ' + string(tt-shift.shift-date) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '       </tr>' skip
                        . /* Точка для закрытия Put */    
        
                for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
                    and tt-rep.obj-code   = tt-shift.obj-code
                    and tt-rep.shift-date = tt-shift.shift-date
                    and tt-rep.shift-num  = tt-shift.shift-num
                    /*                          and tt-rep.dt-TH <> ? and tt-rep.qnty-TH <> 0*/
                    :
                    if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .                        
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.transID + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                        '       </tr>' skip
                        . /* Точка для закрытия Put */                    
                end . /* tt-rep */ 
            end . /* tt-shift */
        end . /* tt-obj */
    end.
    else 
    do :
                       
        for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
            and tt-rep.obj-code   = tt-shift.obj-code
            and tt-rep.shift-date = tt-shift.shift-date
            and tt-rep.shift-num  = tt-shift.shift-num
            :
            if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
            else v-color = "white" .  
            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.gds-name + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.transID + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                '       </tr>' skip
                . /* Точка для закрытия Put */                    
        end . /* tt-rep */
    end .
    for first tt-itog:

        put stream OutStr-html unformatted
            '       <tfoot>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">Всего транзакций: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH + tt-itog.qnty-only-TH + tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip               
/*            '       <tr>' skip                                                                                                                */
/*            '       <td colspan = "1"></td>' skip                                                                                             */
/*            '       <td colspan = "4" style="text-align: left; font-weight: normal">Кол-во транзакций, по которым есть совпадение: </td>' skip*/
/*            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH) + '</td>' skip                             */
/*            '       <td colspan = "9"></td>' skip                                                                                             */
/*            '       </tr>' skip                                                                                                               */
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">из них с расхождением: </td>' skip
            '       <td style="text-align: right; font-weight: normal"></td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только из ГБД: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-only-TH) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip                  
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только Яндекс: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip 
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">по суммам и кол-ву: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-del) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip  
        
            '       </tfoot>' skip
            . /* Точка для закрытия Put */                    
    end . /* tt-itog */
    put stream OutStr-html unformatted
        '     </tbody>' skip
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        . /* Точка для закрытия Put */
    output stream OutStr-html close.
    output stream OutStr-html close.

    run waitfram-hide in this-procedure .
  
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
  
  
end procedure .

procedure get-full-path-RepViewer:
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.

procedure define-full-path-Report:
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:
    /* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.

end procedure.

procedure Report-Viewer:
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date):
    /* Преобразование даты в формат: "01.01.2014" */

    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

    return p-str-date.

end function.
             
 function fnc-obj-name returns character 
    (input p-obj-code as integer, input p-obj-type as character):
    /* Преобразование даты в формат: "01.01.2014" */

    define variable result     as character no-undo.
    define variable p-obj-name as character no-undo.
    define buffer buf_clients for ub.clients .
    for first buf_clients no-lock where buf_clients.obj-code = p-obj-code
                                    and buf_clients.obj-type = p-obj-type:
    p-obj-name = buf_clients.obj-name.
    end.
    return p-obj-name.

end function.            