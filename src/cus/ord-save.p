/*

$Revision: e470dcf1e011, 295, rls $
$Author: SSlivenko $
$Date: Tue Dec 01 19:11:38 2015 +0300 $
$Workfile: ord-save.p $
$Archive: cus/ord-save.p $

ЗАКАЗЫ  Сохранение данных введенных на экране в базу

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/20/01
*/
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
define input parameter parParentProc        as widget-handle no-undo.
define input parameter t-action             as character no-undo .
define input parameter p-deliv-type-code    as integer   no-undo .
define input parameter p-point-obj-code     as integer   no-undo .
define input parameter p-point-cli-code     as integer   no-undo .
define input parameter p-point-obj-db-num   as integer   no-undo .
define input parameter p-point-cli-db-num   as integer   no-undo .
define input parameter p-transport-host-code     as integer   no-undo .
define input parameter p-transport-cli-type     as character no-undo .
define input parameter p-transport-cli-code     as integer   no-undo .
define input parameter p-transport-contract   as integer   no-undo .
define input parameter p-transport-condition  as integer   no-undo .
define input parameter p-transport-value      as decimal   no-undo .
define input parameter p-transport-sum        as decimal   no-undo .
define input parameter p-transport-vat        as decimal   no-undo .
define input parameter is-edoc-nn-doc         as logical   no-undo .
define input parameter is-edi-doc             as logical   no-undo .
define input parameter p-dm-edi               as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-save.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-save.p $":U .
define variable vss-description as character no-undo init "Сохранение данных введенных на экране в базу  ЗАКАЗЫ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i      }
{ cus/df-zakaz.i }
{ gbl/cur-time.i }
{ cmp/showinf.i }
{ gbl/clntattr.i     }
{ cus/vcopm.i        }
{ gbl/getcntxt.i def }
{ cus/ord-savl.i }
{ gbl/waitfram.i }


define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

&glob  start-proc do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):

define variable k as int init 0 no-undo.
define variable ord-qnty    as decimal init 0 no-undo.
define variable ord-sum-cli as decimal init 0 no-undo.
define variable t-ret as logical no-undo .
define variable to-day as date no-undo .
{ cmp/df-sub.i pr }
define variable t-date  as date      no-undo .
define variable t-time  as integer   no-undo .
define variable t-log-3 as logical   no-undo .

run cur-time (output  t-date , output  t-time ).

t-ret =  session:set-wait-state("general") .

assign     k = 0
           ord-qnty    = 0
           ord-sum-cli = 0.
/* по t-action записать в shar-buf_ord-doc */
case t-action :
when "lkp" then do :
/*-----------------------------------------------------------------------------------------------------------------------*/
end.
when "chg" or when "add":u  or when "copy" then do :
/*-----------------------------------------------------------------------------------------------------------------------*/
   k = 0 .

   for each tmp#zakaz no-lock :
       assign k = k + 1 .
   end.

  /* признаки */
  for each shar_ord-dtl where shar_ord-dtl.doc-code = loc-ord-num exclusive-lock   :
      delete shar_ord-dtl .
  end.
  for each tmp#zakaz-dtl  :
      create shar_ord-dtl no-error.
      buffer-copy  tmp#zakaz-dtl to shar_ord-dtl
        assign
          shar_ord-dtl.doc-code  = loc-ord-num
          no-error .
  end.
  /* шапка */
  find first shar_ord-doc exclusive-lock where shar_ord-doc.doc-code = loc-ord-num   no-error  .
  if not available shar_ord-doc then do:
     create shar_ord-doc.
  end.
  assign
  shar_ord-doc.start-date   = date-1
  shar_ord-doc.end-date     = date-2
  shar_ord-doc.doc-code     = loc-ord-num
  shar_ord-doc.doc-date     = doc-date
  shar_ord-doc.cli-code     = loc-cli-code
  shar_ord-doc.cli-name     = loc-obj-name
  shar_ord-doc.cli-type     = loc-cli-type
  shar_ord-doc.agnt         = agnt
  shar_ord-doc.boss         = boss
  shar_ord-doc.status_      = loc-status
  shar_ord-doc.wrkr         = wrkr
  shar_ord-doc.host-code    = g#host-code
  shar_ord-doc.doc-type     = loc-doc-type
  shar_ord-doc.tot-lines    = k
  shar_ord-doc.fact-date    = ?
  shar_ord-doc.ship-date    = loc-date-ship
  shar_ord-doc.sum-service  = loc-service
  shar_ord-doc.deliv-type-code     = p-deliv-type-code
  shar_ord-doc.obj-point-code      = p-point-obj-code
  shar_ord-doc.cli-point-code      = p-point-cli-code
  shar_ord-doc.obj-point-db-num    = p-point-obj-db-num
  shar_ord-doc.cli-point-db-num    = p-point-cli-db-num
  shar_ord-doc.transport-host-code = p-transport-host-code
  shar_ord-doc.transport-cli-type  = p-transport-cli-type
  shar_ord-doc.transport-cli-code  = p-transport-cli-code
  shar_ord-doc.transport-contract  = p-transport-contract
  shar_ord-doc.transport-condition = p-transport-condition
  shar_ord-doc.transport-value     = p-transport-value
  shar_ord-doc.sum-ship            = p-transport-sum
  shar_ord-doc.transport-vat       = p-transport-vat
  shar_ord-doc.pay-code    =  paytype
  shar_ord-doc.order-type  =  tog-type
  shar_ord-doc.cycle-day   =  cycle-day
  shar_ord-doc.pay-day     =  pay-day
  shar_ord-doc.obj-type    =  loc-store-type
  shar_ord-doc.obj-code    =  loc-store-code
  shar_ord-doc.slt-type    =  slt_type
  shar_ord-doc.vat-type    =  vat_type
  shar_ord-doc.base-rate   =  loc-base-rate
  shar_ord-doc.base-scale  =  loc-base-scale
  shar_ord-doc.cli-qnty    =  loc-cli-qnty
  shar_ord-doc.exch-code   =  loc-exch-code
  shar_ord-doc.exch-date   =  t-date
  shar_ord-doc.exch-rate   =  loc-exch-rate
  shar_ord-doc.exch-scale  =  loc-exch-scale
  shar_ord-doc.out-code    =  loc-out-code
  shar_ord-doc.qnty        =  loc-qnty
  shar_ord-doc.sum-base    =  loc-sum-base
  shar_ord-doc.sum-cli     =  loc-sum-cli
  shar_ord-doc.sum-rubl    =  loc-sum-rubl
  shar_ord-doc.tot-lines   =  loc-tot-lines
  shar_ord-doc.e-method    =  e-method
  shar_ord-doc.date-sale-1  = date-sale-1
  shar_ord-doc.date-sale-2  = date-sale-2
  shar_ord-doc.cli-out-doc = loc-cli-out-doc + {&delim-par} +
                             (if t-action = "add"
                               or t-action = "copy"
                               or num-entries(shar_ord-doc.cli-out-doc, {&delim-par}) < 2
                               then string(iso-date(t-date))
                               else entry(2, shar_ord-doc.cli-out-doc, {&delim-par})
                               )   + {&delim-par} +
                             (if t-action = "add"
                               or t-action = "copy"
                               or num-entries(shar_ord-doc.cli-out-doc, {&delim-par}) < 3
                               then string(time, "HH:MM")
                               else entry(3, shar_ord-doc.cli-out-doc, {&delim-par})
                               )
        .

  find first ub.contract no-lock where
              ub.contract.contract-code = loc-contract  and
              ub.contract.host-code     = g#host-code
              no-error .
  if available ub.contract then
  do:
    shar_ord-doc.contract-code = ub.contract.contract-code .
  end.
  else do:
    shar_ord-doc.contract-code = 0.
  end.

  if shar_ord-doc.ship-date = ? then do:
    message
    "Не задана дата доставки!"
    view-as alert-box error .
    t-log-3 = true .
    undo, return error .
  end.
  assign
  shar_ord-doc.ship-time = ( loc-hour * 3600 ) + ( loc-min * 60 ) .

  if k = 0 then do:
    if shar_ord-doc.cli-code = 0 or shar_ord-doc.cli-code = ? then do:
      message "В заказе нет строк . Удаляем документ "
      view-as alert-box information .
      t-log-3 = true .
    end.
    else do:
      message "В заказе нет строк . Удаляем документ ? "
      view-as alert-box question
      buttons yes-no title "" update t-log-3 .
    end.
    if t-log-3 = true then do:
      delete shar_ord-doc.
      run proc-fin in this-procedure .
    end.
  end.
end.
end case.


define variable v-choice as integer   no-undo .
define variable g-log    as logical   no-undo .

/* для новых неотправленных и повторных */
if not available shar_ord-doc  or
   not can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code ) or
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.qnty = 0 ) or
       /*can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.qnty = ? ) or*/
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.price-cli = 0 ) or
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.cli-art = "" )
   then do:
        run proc-fin in this-procedure .
   return .
end.
run waitfram-show in this-procedure ( input "Проверка строк ..." ).
for each ub.ord-line exclusive-lock
    where ub.ord-line.doc-code = shar_ord-doc.doc-code
on error undo , return error
on stop undo , return error
on end-key undo , return error
:
  run ord-savl_process-line in this-procedure ( buffer shar_ord-doc, buffer ub.ord-line) no-error .
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    return error.
  end.
  define buffer buf2_ord-line for ub.ord-line.
  if ( is-edi-doc     and shar_ord-doc.ord-int1 = integer({&edi-empty})  ) and
 ( t-action = "chg" or t-action = "add") and
    shar_ord-doc.doc-type = {&O-P} and
    shar_ord-doc.status_  = {&g___new}
  then do:
          /*проверим не надо ли его перенумеровать!!!*/
    find first buf2_ord-line no-lock where
              buf2_ord-line.doc-code = shar_ord-doc.doc-code
          and  buf2_ord-line.line-num = ub.ord-line.line-num
          and recid(buf2_ord-line) <> recid(ub.ord-line) no-error.
    if available buf2_ord-line then do:
      run waitfram-hide in this-procedure .
      run gbl/d-askw.w
        (input "Проверка заказа перед отсылкой по EDI"
        ,input "Обнаружены строки заказа с ОДИНАКОВЫМ ПОРЯДКОВЫМ НОМЕРОМ! Перенумеруйте строки заказа!!"
        ,input "|"
        ,input "Не отправлять"
        ,input "Заказ остается в текущем статусе. Его можно корректировать."
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 1 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      return error.
    end. /*if available buf2_ord-line then do*/
  end. /*if ( is-edi-doc     and shar_ord-doc.ord-int1 = integer({&edi-empty})  ) and*/
end.
run waitfram-hide in this-procedure .
if  t-action = "chg"  and
    shar_ord-doc.doc-type = {&O-P} and
    shar_ord-doc.status_  = {&g___new}
   then do:
    define variable v-err as logical no-undo .
    run ver-clients-calc  (
          input shar_ord-doc.cli-type
        , input shar_ord-doc.cli-code
        , input shar_ord-doc.obj-type
        , input shar_ord-doc.obj-code
        , input shar_ord-doc.e-method
        , output v-err
                          ) .
    if v-err then return error 'Заказ не был рассчитан !!!'.
end.
if  ( is-edoc-nn-doc and shar_ord-doc.ord-int1 = integer({&edoc-empty}) )
 or ( is-edi-doc     and shar_ord-doc.ord-int1 = integer({&edi-empty})  ) and
 ( t-action = "chg" or t-action = "add") and
    shar_ord-doc.doc-type = {&O-P} and
    shar_ord-doc.status_  = {&g___new}
  then do:
      if is-edoc-nn-doc then do :
      run gbl/d-askw.w
        (input "Решение по отправке заказа поставщику"
        ,input "Выберите один из пунктов "
        ,input "|"
        ,input "Отправить|Нет"
        ,input "Заказ отправляется ПОСТАВЩИКУ и ожидает подтверждения|"
             + "Заказ остается в текущем статусе. Его можно корректировать."
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 2 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).

      case v-choice :
        when 1 then do:
              assign
                shar_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
              .
           run cus/edocsord.p (  input parParentProc
                               , input recid(shar_ord-doc)
                               , input {&table_ord-doc}
                               , input yes
                               )  .
        end.
        when 2 then do:
        end.
      end case.
end.
      if is-edi-doc then do:
        /* временно разрешим!!!
        if shar_ord-doc.vat-type <> {&inc-VAT} then do:
           message
           substitute("В заказах, маршрутизируемых через EDI, тип НДС должен быть <&1>", {&inc-VAT})
           view-as alert-box error.
           undo, return error .
        end.
        */
         /*проверим заказ на авто!!!*/
        define variable v-not-corr-op as character no-undo .
        define variable v-not-corr-op-type as character no-undo .
        run clntattr-value (
            input   shar_ord-doc.cli-type
          , input   shar_ord-doc.cli-code
          , input   {&attr-not-corr-op}
          , output  v-not-corr-op
          , output  v-not-corr-op-type
          ) no-error .
       if logical(v-not-corr-op) = yes then do:
         /*отправляем без спросу!!!*/
         v-choice = 2.
       end.
       else do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_pmnt-ord-doc_send-bypass-EDI':U
          {&cntxt-object}
          g#host-code
          store-type
          store-code
          0
          0
          0
          false
          g-log
        }
        run gbl/d-askw.w
          (input "Выбор метода отправки заказа поставщику"
          ,input "Выберите один из пунктов "
          ,input "|"
          ,input "Вручную" + (if g-log then "" else "^disable") + "|EDI|Не отправлять"
          ,input "Заказ будет обработан вручную|"
               + "Заказ отправляется ПОСТАВЩИКУ по системе EDI и ожидает подтверждения|"
               + "Заказ остается в текущем статусе. Его можно корректировать."
          ,input 2 /* значение возвращаемое при нажатии enter */
          ,input 1 /* значение возвращаемое при нажатии escape */
          ,output v-choice
          ).
        end.
        case v-choice :
          when 1 then do:
              assign
                shar_ord-doc.whole-send-news = integer({&doc-dm-empty})
              .
          end.
          when 2 then do:
              assign
                shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
              .
              if not can-find
                    ( first tmp#zakaz  no-lock    where
                      tmp#zakaz.qnty  <>  0 and
                      tmp#zakaz.qnty  <>  ?
                    )
              then do :      
                message "В заказе все строки нерассчитанные. Нельзя отправлять через EDI." view-as alert-box.
                return no-apply.   
              end.      
              run cus/edocsord.p (  input parParentProc
                                  , input recid(shar_ord-doc)
                                  , input {&table_ord-doc}
                                  , input yes
                                  )  .
          end.
          when 3 then do:
              assign
                shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
              .
          end.
        end case.
    end.
end.
if t-action = "chg"   then do:
  if ( ( is-edoc-nn-doc and (shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok})   or shar_ord-doc.ord-int1 = int ({&edoc-rpl})))
  or ( is-edi-doc     and shar_ord-doc.ord-int1 = int ({&edi-ordrsp}))) /*EDI если сохранение происходит после того, как приняли ORDRSP с action = 5*/
  and shar_ord-doc.doc-type = {&O-P}
  and shar_ord-doc.status_  = {&g___new} then do:
define variable v-buttons as character no-undo .
define variable v-descriptions as character no-undo .
    case shar_ord-doc.whole-send-news:
      when integer({&doc-dm-edoc-nn}) then do:
          /* Подтверждаю    - статус_ ПОСТАВКА ord-int1 = 'acc' (закрыть) и отправить acc  */
          /* На коррекцию   - статус_ новый    ord-int1 = ''                               */
          /* Отложить       - статус_ новый    ord-int1 = 'rpl-ok'                         */
          if can-find (first tmp#zakaz  where
                             tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty or
                             tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli )
          then do:  /* есть несовпадения */
            assign
            v-buttons =  "Подтверждаю^disable|На коррекцию|Отложить"
            v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                    + "Заказ возвращается в первоначальный статус. Его можно корректировать и снова отправить ПОСТАВЩИКУ на подтверждение.|"
                    + "Заказ остается в текущем статусе. Его можно корректировать."
            .
         end.
        else do:
          assign
          v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
          v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                  + "Заказ возвращается в первоначальный статус. Его можно корректировать и снова отправить ПОСТАВЩИКУ на подтверждение.|"
                  + "Заказ остается в текущем статусе. Его можно корректировать."
          .
        end.
      end. /*when integer({&doc-dm-edoc-nn}) then do:*/
      when integer({&doc-dm-edi}) then do:
          if p-dm-edi = integer({&esys-dm-contour-edi}) then do :
            if can-find (first tmp#zakaz  where
                                tmp#zakaz.ord-dec2 <> tmp#zakaz.cli-qnty )
            then do:  /* есть несовпадения */
              assign
              v-buttons =  "Подтверждаю^disable|C коррекцией|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
            else do:
              assign
              v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.  
          end.
          else do :    
            if can-find (first tmp#zakaz  where
                                tmp#zakaz.ord-dec2 <> tmp#zakaz.cli-qnty or
                                tmp#zakaz.ord-dec3 <> tmp#zakaz.price-cli )
            then do:  /* есть несовпадения */
              assign
              v-buttons =  "Подтверждаю^disable|C коррекцией|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
            else do:
              assign
              v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
          end.  
      end.
      otherwise do:
          /*error*/
      end.
    end case. /*case har_ord-doc.whole-send-news:*/
    run gbl/d-askw.w
                (input "Решение по ответу поставщика"
      ,input "Выберите один из пунктов для решения," + {&new-line}
           + "что делать с заказом" + {&new-line}
                ,input "|"
      ,input v-buttons
      ,input v-descriptions
                ,input 1 /* значение возвращаемое при нажатии enter */
                ,input 3 /* значение возвращаемое при нажатии escape */
                ,output v-choice
                ).
      case v-choice :
      when 1 then do:
        if is-edi-doc then do :
          if p-dm-edi = integer({&esys-dm-contour-edi}) then do :
            define variable p-cmd-code as integer no-undo init 0 .
            define variable v-last-error-message as character no-undo .
            define variable v-current-doc-code as character no-undo .
            define variable v-current-obj-type as character no-undo .
            define variable v-current-obj-code as integer no-undo .
            define variable p-parent-handle as handle no-undo.
            define variable p-log-handle as handle no-undo.
            define variable v-cli-out-doc as character no-undo .            
            define variable v-desadv-DELIVERYNOTENUMBER as character no-undo.
            define variable v-desadv-DELIVERYNOTEDATE as date no-undo.
            
            define buffer temp-edi-status for ub.edi-status .
            { rul/garbcoll.i }
            { gbl/gate-clb.i }
            { gbl/key-rec.i }
            { bge/esysattr.i }
            { cus/cr-edist.i }            
            
            assign
                shar_ord-doc.ord-int1 = integer({&edi-ordrsp-sts})
            .            
            
            assign
                v-current-doc-code = shar_ord-doc.doc-code
                v-current-obj-type = shar_ord-doc.obj-type
                v-current-obj-code = shar_ord-doc.obj-code
                p-parent-handle = this-procedure:handle
            .
            { cus/send-stat_contour.i }
            run send-stat_contour ( input "ORDRSP"
                                    ,input "OK"
                                    ,input "checking"
                                    ,input "Сообщение принято"
                                    ,input ?) .
          end.  
          else  
            assign
                shar_ord-doc.ord-int1 = integer({&edi-ordrsp-yes})
            .
        end.
        run cus/ord-clos.p
          ( input  parParentProc
          , input  recid(shar_ord-doc)
          , input  shar_ord-doc.obj-type
          , input  shar_ord-doc.obj-code
          , input  v-cntxt-db-num
          , input  true
          , input  "no" /*p-param-list пока тока один параметр, говорит что edi или не edi*/
          ) no-error .
        if error-status :error or return-value <> "" then do:
            message return-value         skip
            error-status :get-message(1) skip
            view-as alert-box error
            title "Закрытие заказа"
          .
          return  .  /* error ? */
        end.

        /*  shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok}) orord-int1 = acc*/
        /*  отправить xml acc */
        if p-dm-edi <> integer({&esys-dm-contour-edi}) then do :
            run cus/edocsord.p (  input parParentProc
                                  ,input recid(shar_ord-doc)
                                  ,input {&table_ord-doc}
                                  ,input yes
                                  ) no-error  .
            if error-status :error or
            (shar_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
            and shar_ord-doc.ord-int1 <> integer({&edoc-acc}))
            or
            (shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
            and p-dm-edi = integer({&esys-dm-exite-edi})
            and not shar_ord-doc.ord-int1 = integer({&edi-ordrsp-yes})
            )
            then do:
              message
              "Не удалось отправить заказ !" view-as alert-box information .
              shar_ord-doc.status_ = {&g___new} .
              /* А  в новости ушла поставка */
            end.
        end.  
      end. /*when 1 then do:*/
      when 2 then do:
        if is-edoc-nn-doc then do :
         assign
         shar_ord-doc.ord-int1 = integer({&edoc-empty})
         shar_ord-doc.ord-int2 = integer({&edoc-return})
         .
        end.
        if is-edi-doc then do :
            if p-dm-edi = integer({&esys-dm-contour-edi}) then
                assign shar_ord-doc.ord-int1 = integer({&edi-orders}) .
            else
                assign
                  shar_ord-doc.ord-int1 = integer({&edi-ordrsp-no})
                  shar_ord-doc.ord-int2 = integer({&edi-return})
                .
          run cus/edocsord.p (  input parParentProc
                                ,input recid(shar_ord-doc)
                                ,input {&table_ord-doc}
                                ,input yes
                                ) no-error  .
          if error-status :error or
            (shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
            and p-dm-edi = integer({&esys-dm-exite-edi})
            and shar_ord-doc.ord-int1 <> integer({&edi-ordrsp-no})
            )
          or (shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
            and p-dm-edi = integer({&esys-dm-contour-edi})
            and shar_ord-doc.ord-int1 <> integer({&edi-orders})
            )  
          then do:
            message
            "Не удалось отправить заказ !" view-as alert-box information .
            shar_ord-doc.status_ = {&g___new} .
          end.
        end.
      end. /*when 2 then do:*/
      when 3 then do:
          /*статус не меняется*/
      end.
    end case. /*      case v-choice :*/
  end. /*if ( ( is-edoc-nn-doc and (shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok})   or shar_ord-doc.ord-int1 = int ({&edoc-rpl})))*/
end. /*if t-action = "chg"   then do:*/
run proc-fin in this-procedure .
return .

/*-----------------------------------------------------------------------------------------------------------------------*/

 procedure proc-fin :

   do
   on error undo, return error return-value
   :
      for each tmp#zakaz      :   delete tmp#zakaz     . end .
      for each tmp#zakaz-dtl  :   delete tmp#zakaz-dtl . end .
      t-ret =  session:set-wait-state("") .

   end.

 end procedure. /* proc-fin */


procedure display-line-process :
define input parameter p-num-rec as integer no-undo .
define parameter buffer buf_ord-line for ub.ord-line.

do
on error undo, return error
:
  if  p-num-rec modulo 10 = 0 then do:
    run waitfram-show in this-procedure ( input "Просмотрено &1 строк", p-num-rec ).
  end.
end.

end procedure. /* display-line-process */