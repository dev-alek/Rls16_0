block-level on error undo, throw.
/*

$Revision: 9b6d26303b27, 2913, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: r-QR-rep.p $
$Archive: rep/r-QR-rep.p $

Сверка по оплатам QR-кодом

Автор: Сергей Сливенко
Дата создания: 25/05/2020
Author: Sergey Slivenko
Creation date: 25/05/2020

*/

define variable vss-revision as character no-undo initial "$Revision: 9b6d26303b27, 2913, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: Пн ноя 22 19:49:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-QR-rep.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-QR-rep.p $":U .
define variable vss-description as character no-undo initial "Отчет по оплатам QR-кодом".
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
define input parameter p-file             as character no-undo .

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
    field summ     as decimal
    field dt       as datetime
    field RRN      as character
    field taken    as logical
    index pi as primary
    azk RRN
    .
    
define temp-table tt-rep
    field obj-type     as character
    field obj-code     as integer
    field obj-name     as character
    field shift-date   as date
    field shift-num    as integer
    field RRN-TH       as character
    field RRN-QR       as character
    field chk-date     as date
    field chk-time     as character
    field chk-doc-code as character
    field summ-TH      as decimal
    field summ-QR      as decimal
    field dt-QR        as datetime
    field azk          as character
    field azk-disp     as character
    index pi as primary
    obj-type obj-code RRN-TH
    .

define temp-table tt-itog
    field op-qnty-TH   as integer
    field summ-TH      as decimal
    field op-qnty-QR   as integer
    field summ-QR      as decimal 
    .
    
define temp-table tt-obj
    field obj-type     like ub.clients.obj-type
    field obj-code     like ub.clients.obj-code
    field obj-name     like ub.clients.obj-name
    field op-qnty-TH   as integer
    field summ-TH      as decimal
    field op-qnty-QR   as integer
    field summ-QR      as decimal
    index pi as primary
    obj-type obj-code
    .
    
define temp-table tt-shift 
    field obj-type     as character
    field obj-code     as integer
    field shift-date   as date
    field shift-num    as integer
    field op-qnty-TH   as integer
    field summ-TH      as decimal
    field op-qnty-QR   as integer
    field summ-QR      as decimal
    .


/*определение товара*/
/*    for each buf_obj-list :*/
/*    end .                  */
    
run waitfram-show in this-procedure ( "ЖДИТЕ... Обработка файла транзакций") .
run imp-QR .
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

run my-rep in this-procedure .



procedure make-rep :
    define buffer buf_chk-pay      for ub.chk-pay .
    define buffer buf_chk-pay-attr for ub.chk-pay-attr .
    define buffer buf_chk-doc      for ub.chk-doc .
    define buffer buf_chk-gds      for ub.chk-gds .
  
    define variable v-RRN  as character no-undo .
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .
    
    
    empty TEMP-TABLE tt-itog .
    create tt-itog .
    
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
              
              for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-list.obj-type
                                             and buf_chk-doc.obj-code = obj-list.obj-code
                                             and buf_chk-doc.shift-date >= X-date-start
                                             and buf_chk-doc.shift-date <= X-date-end
                                             and buf_chk-doc.out-code > ""
                                             :
                if ((buf_chk-doc.shift-date = x-date-Start and buf_chk-doc.shift-num < X-shift-start)
                or (buf_chk-doc.shift-date = x-date-End and  buf_chk-doc.shift-num > X-shift-end) )
                then next.         
                                      
                for each buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
                                                    and buf_chk-pay-attr.attr-code = "sbprrn",
                first buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-pay-attr.doc-code
                                            and buf_chk-pay.line-num = buf_chk-pay-attr.line-num
                                            :
                  if not (buf_chk-pay.pay-code = buf_cash-pay.cdpay-code
                          and buf_chk-pay.curr-code = buf_cash-pay.curr-code)
                  then next .
                    
                  v-RRN = buf_chk-pay-attr.attr-value .
                    
        
                  find first tt-trans exclusive-lock where  tt-trans.RRN > ""
                      and trim(tt-trans.RRN) = trim(v-RRN)
                      and not tt-trans.taken
                      no-error .
        
                  create tt-rep .
                  assign
                    tt-rep.obj-type   = obj-list.obj-type
                    tt-rep.obj-code   = obj-list.obj-code
                    tt-rep.obj-name   = obj-list.obj-name
                    tt-rep.summ-TH    = buf_chk-pay.tot-rubl
                    tt-rep.chk-date   = buf_chk-doc.chk-date
                    tt-rep.chk-time   = string(buf_chk-doc.chk-time, "HH:MM:SS")
                    tt-rep.chk-doc-code = buf_chk-doc.doc-code
                    tt-rep.shift-date = buf_chk-doc.shift-date
                    tt-rep.shift-num  = buf_chk-doc.shift-num
                    tt-rep.RRN-TH     = v-RRN
                    tt-rep.azk        = ""
                    tt-itog.op-qnty-TH  = tt-itog.op-qnty-TH + 1
                    tt-itog.summ-TH   = tt-itog.summ-TH + tt-rep.summ-TH
                  .
                  
                  if available tt-trans
                  then do :
                    assign
                      tt-rep.dt-QR        = tt-trans.dt
                      tt-rep.summ-QR      = tt-trans.summ
                      tt-rep.RRN-QR       = tt-trans.RRN
                      tt-trans.taken      = true      
                      tt-itog.op-qnty-QR  = tt-itog.op-qnty-QR + 1
                      tt-itog.summ-QR     = tt-itog.summ-QR + tt-rep.summ-QR
                    .
                  end .
                  
                  release tt-rep .
                end . 
              end .
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
              
              for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-list.obj-type
                                             and buf_chk-doc.obj-code = obj-list.obj-code
                                             and buf_chk-doc.chk-date >= X-date-start
                                             and buf_chk-doc.chk-date <= X-date-end
                                             and buf_chk-doc.out-code > ""
                                             :
                                      
                for each buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
                                                    and buf_chk-pay-attr.attr-code = "sbprrn",
                first buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-pay-attr.doc-code
                                            and buf_chk-pay.line-num = buf_chk-pay-attr.line-num
                                            :
                  if not (buf_chk-pay.pay-code = buf_cash-pay.cdpay-code
                          and buf_chk-pay.curr-code = buf_cash-pay.curr-code)
                  then next .
                    
                  v-RRN = buf_chk-pay-attr.attr-value .
                    
        
                  find first tt-trans exclusive-lock where  tt-trans.RRN > ""
                      and trim(tt-trans.RRN) = trim(v-RRN)
                      and not tt-trans.taken
                      no-error .
        
                  create tt-rep .
                  assign
                    tt-rep.obj-type   = obj-list.obj-type
                    tt-rep.obj-code   = obj-list.obj-code
                    tt-rep.obj-name   = obj-list.obj-name
                    tt-rep.summ-TH    = buf_chk-pay.tot-rubl
                    tt-rep.chk-date   = buf_chk-doc.chk-date
                    tt-rep.chk-time   = string(buf_chk-doc.chk-time, "HH:MM:SS")
                    tt-rep.chk-doc-code = buf_chk-doc.doc-code
                    tt-rep.shift-date = buf_chk-doc.shift-date
                    tt-rep.shift-num  = buf_chk-doc.shift-num
                    tt-rep.RRN-TH     = v-RRN
                    tt-rep.azk        = ""
                    tt-itog.op-qnty-TH  = tt-itog.op-qnty-TH + 1
                    tt-itog.summ-TH   = tt-itog.summ-TH + tt-rep.summ-TH
                  .
                  
                  if available tt-trans
                  then do :
                    assign
                      tt-rep.azk-disp     = tt-trans.azk
                      tt-rep.dt-QR        = tt-trans.dt
                      tt-rep.summ-QR      = tt-trans.summ
                      tt-rep.RRN-QR       = tt-trans.RRN
                      tt-trans.taken      = true      
                      tt-itog.op-qnty-QR  = tt-itog.op-qnty-QR + 1
                      tt-itog.summ-QR     = tt-itog.summ-QR + tt-rep.summ-QR
                    .
                  end .
                  
                  release tt-rep .
                end . 
              end .
            end .
        end .

    end . /* _obj: for each obj-list: */
  
    for each tt-trans exclusive-lock where not tt-trans.taken :
      
        create tt-rep .
        assign
          tt-rep.azk          = tt-trans.azk
          tt-rep.dt-QR        = tt-trans.dt
          tt-rep.summ-QR      = tt-trans.summ
          tt-rep.RRN-QR       = tt-trans.RRN
          tt-trans.taken      = true      
          tt-itog.op-qnty-QR  = tt-itog.op-qnty-QR + 1
          tt-itog.summ-QR     = tt-itog.summ-QR + tt-rep.summ-QR
        .
        if trim(tt-rep.azk) = "" then tt-rep.azk = "?" .
    
        release tt-rep .
    end .
   
  
    for each tt-rep where tt-rep.azk = ""
                    break by tt-rep.obj-type
                          by tt-rep.obj-code
                          by tt-rep.shift-date
                          by tt-rep.shift-num
      :
      if first-of(tt-rep.obj-type)
      or first-of(tt-rep.obj-code)
      then do :
        create tt-obj .
        assign
          tt-obj.obj-type = tt-rep.obj-type
          tt-obj.obj-code = tt-rep.obj-code
          tt-obj.obj-name = tt-rep.obj-name
        .
      end .
  
      if first-of(tt-rep.shift-date)
      or first-of(tt-rep.shift-num)
      then do :
        create tt-shift .
        assign
          tt-shift.obj-type   = tt-rep.obj-type
          tt-shift.obj-code   = tt-rep.obj-code
          tt-shift.shift-date = tt-rep.shift-date
          tt-shift.shift-num  = tt-rep.shift-num
        .
      end .
  
      assign
        tt-obj.op-qnty-TH = (tt-obj.op-qnty-TH + 1) when trim(tt-rep.RRN-TH) > ""
        tt-obj.summ-TH    = tt-obj.summ-TH    + tt-rep.summ-TH
        tt-obj.op-qnty-QR = (tt-obj.op-qnty-QR + 1) when trim(tt-rep.RRN-QR) > ""
        tt-obj.summ-QR    = tt-obj.summ-QR    + tt-rep.summ-QR
      .
  
      assign
        tt-shift.op-qnty-TH = (tt-shift.op-qnty-TH + 1) when trim(tt-rep.RRN-TH) > ""
        tt-shift.summ-TH    = tt-shift.summ-TH    + tt-rep.summ-TH
        tt-shift.op-qnty-QR = (tt-shift.op-qnty-QR + 1) when trim(tt-rep.RRN-QR) > ""
        tt-shift.summ-QR    = tt-shift.summ-QR    + tt-rep.summ-QR
      .
  
      if last-of(tt-rep.obj-type)
      or last-of(tt-rep.obj-code)
      then do :
        release tt-obj .
      end .
  
      if last-of(tt-rep.shift-date)
      or last-of(tt-rep.shift-num)
      then do :
        release tt-shift .
      end .
                          
    end .
  
end procedure .
    
procedure imp-QR :
    DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
    DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
    DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
    DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
  
    DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
  
    define variable v-azk             as character        no-undo .
    define variable v-summ            as character        no-undo .
    define variable v-dt              as character        no-undo .
    define variable v-RRN             as character        no-undo .
  
    define variable v-date            as character        no-undo .
    define variable v-time            as character        no-undo .
  
    CREATE "Excel.Application":U mExcelApplication.
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
            v-dt       = ''
            v-RRN      = ''
            .
    

        v-RRN = mWorkSheet:Range("I" + vChLine):FORMULA NO-ERROR.  
        if v-RRN = ? then v-RRN = mWorkSheet:Range("I" + vChLine):VALUE NO-ERROR.
    
        v-azk = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.  
        if v-azk = ? then v-azk = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR. 
    
        v-summ = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.  
        if v-summ = ? then v-summ = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR.
        v-summ = replace(v-summ, ",", ".") .
    
        decimal(v-summ) no-error .
        if error-status:error then next loopbl .
    
        v-dt = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.  
        if v-dt = ? then v-dt = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.
        
/*        v-date = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.                     */
/*        if v-date = ? then v-date = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.*/
/*                                                                                     */
/*        v-time = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.                   */
/*        if v-time = ? then v-time = mWorkSheet:Range("F" + vChLine):VALUE NO-ERROR.  */
/*                                                                                     */
/*        v-dt = v-date + "  " + v-time .                                              */
        v-dt = trim(v-dt) .
    
    
    
        if length(v-azk) > 0
            or length(v-summ) > 0
            or length(v-dt) > 0
            or length(v-RRN) > 0
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
        tt-trans.summ      = decimal(v-summ) .
        tt-trans.dt        = datetime(v-dt) .
        tt-trans.RRN       = trim(v-RRN) .
        tt-trans.taken     = false .
        release tt-trans .
    
    end.
  
end procedure .    
    
procedure my-rep :
  
    run gbl/getrpnum.p (output g#report-num).  /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

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
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 60px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '</tr>' skip
        .
                        
 
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="18" style="text-align: left; font-weight:bold;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="18" style="text-align: center; font-weight:bold;">Сверка по транзакциям с оплатой через СБП</td>' skip
        '</tr>' skip   
        '<tr>' skip
        '<td colspan="18" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip  
        '<tr>' skip
        '<td colspan="18" style="text-align: left; font-weight:bold;">За период: ' + v-period + '</td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td colspan="18" style="text-align: left; font-weight:bold;">По: ' + v-azk-list + '</td>' skip
        '</tr>' skip
        '</thead>' skip
    .
    
    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th colspan="4" style="text-align: center; font-weight:bold; background-color: green; height: 30px;">Общая информация по данным Системы</th>' skip
        '         <th colspan="6" style="text-align: center; font-weight:bold; background-color: green;">По данным из документов продажи</th>' skip
        '         <th colspan="6" style="text-align: center; font-weight:bold; background-color: green;">По данным банка-партнера</th>' skip
        '         <th colspan="2" style="text-align: center; font-weight:bold; background-color: green;">Разница</th>' skip
        '       </tr>' skip
    . /* Точка для закрытия Put */  
    
    put stream OutStr-html unformatted
        '       <tr>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green; height: 50px;">АЗК/АЗС</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Смена</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Дата открытия смены</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Дата закрытия смены</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">RRN</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Дата чека</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Время чека</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Идентификатор чека</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Число операций</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Название АЗК/АЗС</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">RRN</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Дата операции</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Время операции</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Число операций</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Число операций</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: green;">Сумма</th>' skip
        '       </tr>' skip
    . /* Точка для закрытия Put */
    
    for first tt-itog:

        put stream OutStr-html unformatted
            '       <tr level="1">' skip
            '         <th colspan = "4" style="text-align: center; font-weight:bold; background-color: green;">Итого по всем объектам</th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;">' + string(tt-itog.op-qnty-TH) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-itog.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: green;">' + fnc-convert-dot-to-colon(tt-itog.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;"></th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;">' + string(tt-itog.op-qnty-QR) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-itog.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: green;">' + fnc-convert-dot-to-colon(tt-itog.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '         <th style="text-align: center; font-weight:bold; background-color: green;">' + string(tt-itog.op-qnty-TH - tt-itog.op-qnty-TH) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon((tt-itog.summ-TH - tt-itog.summ-QR),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: green;">' + fnc-convert-dot-to-colon((tt-itog.summ-TH - tt-itog.summ-QR),"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '       </tr>' skip               
        . /* Точка для закрытия Put */                    
    end . /* tt-itog */

    for each tt-obj :
        put stream OutStr-html unformatted
            '       <tr level="1">' skip
            '         <th colspan = "4" style="text-align: center; font-weight:bold;">Итого по ' + tt-obj.obj-name + '</th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;">' + string(tt-obj.op-qnty-TH) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;"></th>' skip
            '         <th style="text-align: center; font-weight:bold;">' + string(tt-obj.op-qnty-QR) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-obj.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '         <th style="text-align: center; font-weight:bold;">' + string(tt-obj.op-qnty-TH - tt-obj.op-qnty-TH) + '</th>' skip
            '         <th num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-QR),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-QR),"->>>>>>>>>>>>>9.99",2) + '</th>' skip
            '       </tr>' skip               
        . /* Точка для закрытия Put */ 
        for each tt-shift where tt-shift.obj-type = tt-obj.obj-type
                            and tt-shift.obj-code = tt-obj.obj-code,
        first buf_shift-obj no-lock where buf_shift-obj.obj-type = tt-shift.obj-type
                                      and buf_shift-obj.obj-code = tt-shift.obj-code
                                      and buf_shift-obj.shift-date = tt-shift.shift-date
                                      and buf_shift-obj.shift-num = tt-shift.shift-num
          :
            if tt-shift.summ-TH = tt-shift.summ-QR
            then do :
              put stream OutStr-html unformatted
                '       <tr level="2">' skip
                '         <th style="text-align: center; font-weight:bold;">' + tt-obj.obj-name + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;">' + string(tt-shift.shift-num) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;">' + string(buf_shift-obj.open-date, "99.99.9999") + " " + string(buf_shift-obj.open-time, "HH:MM:SS") + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;">' + (if buf_shift-obj.close-date <> ? then (string(buf_shift-obj.close-date, "99.99.9999") + " " + string(buf_shift-obj.close-time, "HH:MM:SS")) else "") + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;">' + string(tt-shift.op-qnty-TH) + '</th>' skip
                '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;">' + string(tt-shift.op-qnty-QR) + '</th>' skip
                '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-shift.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '         <th style="text-align: center; font-weight:bold;"></th>' skip
                '       </tr>' skip               
              . /* Точка для закрытия Put */ 
            end .
            else do :
              put stream OutStr-html unformatted
                '       <tr level="2">' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-obj.obj-name + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-shift.shift-num) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(buf_shift-obj.open-date, "99.99.9999") + " " + string(buf_shift-obj.open-time, "HH:MM:SS") + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + (if buf_shift-obj.close-date <> ? then (string(buf_shift-obj.close-date, "99.99.9999") + " " + string(buf_shift-obj.close-time, "HH:MM:SS")) else "") + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-shift.op-qnty-TH) + '</th>' skip
                '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: red;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-shift.op-qnty-QR) + '</th>' skip
                '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: red;">' + fnc-convert-dot-to-colon(tt-shift.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-shift.op-qnty-TH - tt-shift.op-qnty-TH) + '</th>' skip
                '         <th num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-QR),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: red;">' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-QR),"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                '       </tr>' skip               
              . /* Точка для закрытия Put */ 
            end .
    
            for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
                              and tt-rep.obj-code   = tt-shift.obj-code
                              and tt-rep.shift-date = tt-shift.shift-date
                              and tt-rep.shift-num  = tt-shift.shift-num
            :
              if tt-rep.summ-TH = tt-rep.summ-QR
              then do :
                put stream OutStr-html unformatted
                  '       <tr level="3">' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-obj.obj-name + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + string(tt-shift.shift-num) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + string(buf_shift-obj.open-date, "99.99.9999") + " " + string(buf_shift-obj.open-time, "HH:MM:SS") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + (if buf_shift-obj.close-date <> ? then (string(buf_shift-obj.close-date, "99.99.9999") + " " + string(buf_shift-obj.close-time, "HH:MM:SS")) else "") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-rep.RRN-TH + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + string(tt-rep.chk-date, "99.99.9999") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-rep.chk-time + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-rep.chk-doc-code + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;"></th>' skip
                  '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-rep.azk-disp + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + tt-rep.RRN-QR + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + (if tt-rep.dt-QR <> ? then string(tt-rep.dt-QR, "99.99.9999") else " ") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;">' + (if tt-rep.dt-QR <> ? then string(INTEGER(truncate(MTIME(tt-rep.dt-QR) / 1000, 0)), "HH:MM:SS") else " ") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;"></th>' skip
                  '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold;"></th>' skip
                  '         <th style="text-align: center; font-weight:bold;"></th>' skip
                  '       </tr>' skip               
                . /* Точка для закрытия Put */      
              end .
              else do :
                put stream OutStr-html unformatted
                  '       <tr level="3">' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-obj.obj-name + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-shift.shift-num) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(buf_shift-obj.open-date, "99.99.9999") + " " + string(buf_shift-obj.open-time, "HH:MM:SS") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + (if buf_shift-obj.close-date <> ? then (string(buf_shift-obj.close-date, "99.99.9999") + " " + string(buf_shift-obj.close-time, "HH:MM:SS")) else "") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-rep.RRN-TH + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + string(tt-rep.chk-date, "99.99.9999") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-rep.chk-time + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-rep.chk-doc-code + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                  '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: red;">' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-rep.azk-disp + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + tt-rep.RRN-QR + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + (if tt-rep.dt-QR <> ? then string(tt-rep.dt-QR, "99.99.9999") else " ") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;">' + (if tt-rep.dt-QR <> ? then string(INTEGER(truncate(MTIME(tt-rep.dt-QR) / 1000, 0)), "HH:MM:SS") else " ") + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                  '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold; background-color: red;">' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                  '         <th style="text-align: center; font-weight:bold; background-color: red;"></th>' skip
                  '       </tr>' skip               
                . /* Точка для закрытия Put */ 
              end .               
            end . /* tt-rep */ 
        end . /* tt-shift */
    end . /* tt-obj */
        
    if can-find(first tt-rep where tt-rep.azk > "")
    then do :
      /* Расхождения */
      put stream OutStr-html unformatted
        '       <tr level="1">' skip
        '         <th style="text-align: center; font-weight:bold;">Транзакциии, не найденные в системе:</th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '         <th style="text-align: center; font-weight:bold;"></th>' skip
        '       </tr>' skip               
      . /* Точка для закрытия Put */ 
      for each tt-rep where tt-rep.azk > "" :
        put stream OutStr-html unformatted
          '       <tr level="3">' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;">' + tt-rep.azk + '</th>' skip
          '         <th style="text-align: center; font-weight:bold;">' + tt-rep.RRN-QR + '</th>' skip
          '         <th style="text-align: center; font-weight:bold;">' + (if tt-rep.dt-QR <> ? then string(tt-rep.dt-QR, "99.99.9999") else " ") + '</th>' skip
          '         <th style="text-align: center; font-weight:bold;">' + (if tt-rep.dt-QR <> ? then string(INTEGER(truncate(MTIME(tt-rep.dt-QR) / 1000, 0)), "HH:MM:SS") else " ") + '</th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center; font-weight:bold;">' + fnc-convert-dot-to-colon(tt-rep.summ-QR,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '         <th style="text-align: center; font-weight:bold;"></th>' skip
          '       </tr>' skip               
        . /* Точка для закрытия Put */ 
      end .
    end .
    
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

procedure define-full-path-Report:
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

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