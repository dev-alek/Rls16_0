block-level on error undo, throw.
/*

$Revision: 12c0f79a3864, 3013, rls $
$Author: EShklyar $
$Date: Ср апр 06 16:23:44 2022 +0300 $
$Workfile: rkocollection.p $
$Archive: utl/rkocollection.p $

Инкасация

Автор: Рубан Дмитрий
Дата создания1: 10/11/19


---------------------------&start-codex_id=24;ruleset_id=1;-------------------------------

---------------------------&end-codex_id=24;ruleset_id=1;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
/*define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
*/


define variable vss-revision    as character no-undo init "$Revision: 12c0f79a3864, 3013, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkocollection.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rkocollection.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 24, набор 1".
define variable vi as integer no-undo.
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }
{ cmp/obj-list.i new }
run create_obj-list(v-cntxt-obj-type, v-cntxt-obj-code).
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" } /* Fact-order и остатки на дату ПО ФИН АРХИВАМ */
{ ref/fndocip.i  }
{ rep/r-pychk0.i defalgo    }
{ str/out-vatp.i def    }
{ str/lib-trn.i  }
{ ref/gds-attr.i }
{ ref/fd-attr.i }
define variable v-curr-r-b as character no-undo.
{ gbl/curr-r-b.i
  v-curr-r-b
}
&glob debug yes
&if defined (debug) ne 0
&then
  output to "rkoincas.log" .
  output close.
&endif
/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable log-file-name                as character      no-undo init "process-fdoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name    as character no-undo.
define variable v-sign       as integer   no-undo.
define variable l-res        as integer   no-undo.
define variable v-es         as logical   no-undo.
define variable v-esm        as character no-undo.
define variable v-rv         as character no-undo.
define variable v-err-mess   as character no-undo.
define variable is-petrolium as logical   no-undo.

define variable o-uchet as character no-undo .
define variable v-uchet as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable par-type as character no-undo .
define variable v-tth as handle no-undo .
define variable mValue as character no-undo.
define variable mType as character no-undo.

define buffer buf_shift-obj for ub.shift-obj.

{ str/dia2auto.i }
{ rul/seterror.i }
run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + string(0)), yes, '', 'Прием чеков с касс') .
&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)



/*---------------------------&start-rule-call-param&-------------------------------*/
define variable mCashBook         as class ibs.th.ref.cashbookstorage no-undo .
define variable p-by-cash-desk    as logical no-undo .
define variable p-by-petrol-goods as logical no-undo .
define variable p-by-osnovanie    as character  no-undo .
define variable p-by-pril         as character  no-undo .


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/



/* ------------------------- &end-i-script& -----------------------------------*/

/*on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

*/
find last buf_shift-obj
          where buf_shift-obj.obj-type    = v-cntxt-obj-type 
            and buf_shift-obj.obj-code    = v-cntxt-obj-code
            and buf_shift-obj.status_  = {&sht-current}
      no-error.
if not available buf_shift-obj
then do:
   message
      vss-workfile vss-revision vss-description skip
           "Ошибка при поиске текущей смены" skip
            "Объект"  v-cntxt-obj-type v-cntxt-obj-code skip
view-as alert-box error .
undo, return return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.

{ibs/th/ref/cashbookost.i }

define temp-table temp-fin-sum no-undo
field cash-desk  as integer
field curr-code as integer
field tot-sum as decimal
field tot-base as decimal
field tot-rubl as decimal
field is-petrol as logical
field cashbookid as int64
field is-expense_cash as logical
field num-expense_cash as int
index pi is unique primary
num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid
.

define temp-table temp-gds no-undo
field with-vat as logical init yes
field b-code as integer
field node-code as integer
field doc-code as character
field doc-kind as character
field gds-code as integer
field artic as character
field prod-type as character
field prod-code as integer
field eff-doc-qnty as decimal
field tot-r-b as decimal
field tot-rubl as decimal
field tot-base as decimal
field tot-doc as decimal
field vat-base as decimal
field vat-rubl as decimal
field vat-doc as decimal
field curr-code as integer
field cash-desk  as integer
field is-petrol as logical
index pi is unique primary
cash-desk
b-code
doc-kind
curr-code
/*is-petrol*/
.
define temp-table temp-tax no-undo
field with-vat as logical init yes
field curr-code as integer
field vat-pc as decimal
field slt-pc as decimal
field vat-base as decimal
field vat-rubl as decimal
field vat-doc as decimal
field sum-base as decimal
field sum-rubl as decimal
field sum-doc as decimal
field cash-desk  as integer
field is-petrol as logical
field cashbookId as int64
field is-expense_cash as logical
field num-expense_cash as int
index pi is unique primary
num-expense_cash
is-expense_cash
cash-desk
curr-code
vat-pc
slt-pc
is-petrol
cashbookId
.

define temp-table temp-z-number no-undo
field z-number as integer
field cash-desk as integer
index pi is unique primary
cash-desk z-number.

define temp-table temp-z-number-list no-undo
field cash-desk as integer
field naznach-plat as character
index pi is unique primary
cash-desk .

define temp-table temp-autotank no-undo
field curr-code  as integer
field pay-desk   as integer
field sum-return as decimal
field is-petrol  as logical
field vat-pc     as decimal
field slt-pc     as decimal
index idx curr-code pay-desk is-petrol vat-pc slt-pc .


procedure proc-main :
define variable v-count         as integer   no-undo .
define variable v-tot-r-b-chk   as decimal   no-undo .
define variable v-tot-r-b-inkas as decimal   no-undo .
define variable v-real-obj-type as character no-undo .
define variable v-real-obj-code as integer   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-host-name     as character no-undo .
define variable v-base-code     as integer   no-undo .
define variable v-param-type    as character no-undo .
define variable v-naznach-plat  as character no-undo .
define variable v-naznach-plat2 as character no-undo .
define variable cash-book       as integer   no-undo .
define variable v-value         as character no-undo .
define variable v-cashier       as character no-undo .
define variable v-limit-access  as integer   no-undo .
define variable v-obj-db-num    as integer   no-undo .
define variable v-vat-pc        as integer   no-undo .
define variable v-slt-pc        as integer   no-undo .
define variable fact-order      as decimal   no-undo .

define buffer buf_inkas          for ub.inkas.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_cash-pay       for ub.cash-pay.
define buffer buf_temp-fin-sum   for temp-fin-sum.
define buffer buf_temp-fin-sum-Pko for temp-fin-sum.
define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
define buffer buf_chk-doc        for ub.chk-doc.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-pay-attr   for ub.chk-pay-attr.
define buffer buf_temp-gds       for temp-gds.
define buffer buf_bar-code       for ub.bar-code.
define buffer buf_goods          for ub.goods.
define buffer buf_sale-doc       for ub.sale-doc.
define buffer buf_trn-doc        for ub.trn-doc.
define buffer buf_doc-line       for ub.doc-line.
define buffer buf_gds-dtl        for ub.gds-dtl.
define buffer buf_temp-tax       for temp-tax.
define buffer buf_fin-doc        for ub.fin-doc.
define buffer buf_sysconf        for ub.sysconf.
define buffer buf_shift-staff    for ub.shift-staff.
define buffer buf_chk-gds        for ub.chk-gds.
mCashBook = new ibs.th.ref.cashbookstorage () .
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

define variable v-err               as logical    no-undo .

/*run adm/shattri.p (                                  */
/*        input "get":U                                */
/*        ,input buf_shift-obj.obj-type                */
/*        ,input buf_shift-obj.obj-code                */
/*        ,input {&attr-fin-doc}                       */
/*        ,input  {&attr-fin-doc_uchet}                */
/*        ,output v-uchet                              */
/*        ,output v-value-date                         */
/*        ,output v-value-decimal                      */
/*        ,output v-value-integer                      */
/*        ,output v-value-logical                      */
/*        ,output par-type                             */
/*        ,INPUT-OUTPUT table-handle v-tth             */
/*        ) no-error .                                 */
/*      if error-status :error  then v-uchet = "smen" .*/
/*                                                     */
/*      delete object v-tth no-error.                  */


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/
/*    { gbl/cashbook.i  buf_shift-obj.obj-type buf_shift-obj.obj-code cash-book no-error }                   */
/*    IF error-status:error then do:                                                                         */
/*      &scop my-message  substitute("Ошибка при получении настроек фин.документов НА ОБЪЕКТЕ &1&2:&3&4 &5" ~*/
/*              , buf_shift-obj.obj-type ~                                                                   */
/*              , buf_shift-obj.obj-code ~                                                                   */
/*              , ~{&new-line~}   ~                                                                          */
/*              , error-status:get-message(1) ~                                                              */
/*              , return-value )                                                                             */
/*      undo, return error .                                                                                 */
/*    end.                                                                                                   */
   { gbl/hostname.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-host-code v-host-name }
   { gbl/objdbnum.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-obj-db-num }
   { gbl/basecode.i v-host-code v-base-code }
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
/*    if cash-book = integer({&cash-book-firm}) then do:                                                                                  */
/*      /*затычка - чтобы не создавался ордер если не настроено на объекте*/                                                              */
/*      return "return".                                                                                                                  */
/*    end.                                                                                                                                */
/*    if cash-book = integer({&cash-book-firm})                                                                                           */
/*    and g#db-num <> buf_sysconf.firm-db-num                                                                                             */
/*    then do:                                                                                                                            */
/*      &scop my-message substitute("Невозможно создать платеж для &1&2 на БД &3&4На БД объекта не ведется Операционная кассовая книга" ~ */
/*                                  ,buf_shift-obj.obj-type ~                                                                             */
/*                                  ,buf_shift-obj.obj-code ~                                                                             */
/*                                  ,g#db-num  )                                                                                          */
/*      {&display-message}.                                                                                                               */
/*      undo, return error {&my-message}.                                                                                                              */
/*    end.                                                                                                                                */
/*    if cash-book = integer({&cash-book-object})                                                                                         */
/*    and g#db-num <> v-obj-db-num                                                                                                        */
/*    then do:                                                                                                                            */
/*      &scop my-message substitute("Невозможно создать платеж для &1&2 на БД &3&4На БД объекта ведется Операционная кассовая книга&4" + ~*/
/*                                  "Текущая БД &3 БД объекта &5" ~                                                                       */
/*                                  ,buf_shift-obj.obj-type ~                                                                             */
/*                                  ,buf_shift-obj.obj-code ~                                                                             */
/*                                  ,g#db-num     ~                                                                                       */
/*                                  , {&new-line} ~                                                                                       */
/*                                  , v-obj-db-num  )                                                                                     */
/*      {&display-message}.                                                                                                               */
/*      undo, return error  {&my-message}.                                                                                                              */
/*    end.                                                                                                                                */
    /*перезаполним с учетом  требований ЮКОС*/
    find first buf_shift-staff no-lock
         where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
           and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
           and buf_shift-staff.shift-date = buf_shift-obj.shift-date
           and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
/*           and buf_shift-staff.staff-role = yes*/
           no-error.
    if not available buf_shift-staFF THEN DO:
       if buf_shift-obj.status_ = {&sht-closed} then do:
          v-cashier = "адм".
       end.
       else do:
             run gbl/d-prompt.w (
            'title=':u + "Менеджер смены неопределен. Введите ФИО кассира," + '\':u
          + 'text1=':u + "от имени которого будем оформлять Ордер на выручку" + '\':u
          + 'format=' + "X(40)" + '\':u
          + 'type=' + {&type-char} + '\':u
          + 'fillin_row=3\':u
          + 'fillin_col=4\':u
          + 'fillin_width=41\':u
          + 'fillin_height=1\':u
          + 'max-chars=5\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=no\':u
          , input-output v-value
          ).   
          if return-value = 'false':u then do:
               &scop my-message substitute("Нельзя создать ордер на выручку, если кассир не определен")
               {&display-message}.
               undo, return error {&my-message}.
          END.
       end.
      v-cashier = v-value.
   end.
   else do:
      v-cashier = buf_shift-staff.name.
   end.
   define variable v-obj-date as date no-undo.
   { gbl/curobjdt.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-obj-date }
   block-chk:
   for each chk-doc where(  chk-doc.obj-type   = buf_shift-obj.obj-type
                      and chk-doc.obj-code     = buf_shift-obj.obj-code
                      and chk-doc.shift-date   = buf_shift-obj.shift-date
                      and chk-doc.shift-num    = buf_shift-obj.shift-num
                      )
                      or  (    chk-doc.obj-type eq buf_shift-obj.obj-type
                           and chk-doc.obj-code eq buf_shift-obj.obj-code
                           and chk-doc.out-code  = ?)
    no-lock: 
       if     chk-doc.chk-type    ne integer({&rcpt-sale})
          and chk-doc.chk-type    ne integer({&rcpt-return})
       then
          next block-chk.
       do vi = 1 to num-entries(chk-doc.office):
          if can-do({&chk-err-list},entry(vi,chk-doc.office))
          then do:
             next block-chk.
          end.
       end.
       run rep/r-pychone.p(parparentproc,chk-doc.doc-code).
       for each buf_chk-gds-pay where
           buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = {&current-algo-1}
        and buf_chk-gds-pay.pay-code eq 1
       no-lock:
          run gds-attr-value in this-procedure (
                                         input buf_chk-gds-pay.gds-code
                                        ,input "cash-book-id"
                                        ,output mValue
                                        ,output mType) no-error.
          find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
          if not available ub.CashBook 
          then do :
             find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
          end.
          if available ub.CashBook
          then do :
             p-by-cash-desk = no .
             p-by-petrol-goods = no .
          end.
          find first tt-cashBookOst where tt-cashBookOst.cashbookid eq CashBook.id
          no-error.
          if not available tt-cashBookOst
          then do:
             create tt-cashBookOst.
             assign
                tt-cashBookOst.cashbookid   =  CashBook.id
                tt-cashBookOst.cashbookname =  CashBook.CashBookName
             .
             run fostatok in this-procedure (
                 input   v-host-code
                  ,input   buf_shift-obj.obj-code
                  ,input   buf_shift-obj.obj-type
                  ,input   yes
                  ,input   buf_shift-obj.close-date - 1
                  ,input   v-obj-date
                  ,input   buf_shift-obj.shift-num
                  ,input   buf_shift-obj.shift-num
                  ,input   yes /*xTog-obj*/
                  ,input   0 /*p-curr-code*/
                  ,input   CashBook.id
                  ,output  tt-cashBookOst.ostrasch
                  ,output  Fact-order)
                 no-error .
                 tt-cashBookOst.ost = tt-cashBookOst.ostrasch.
               &if defined (debug) ne 0
               &then
                   output to "rkoincas.log" append.
                   put unformatted "Кассовая книга " CashBook.id " остаток " tt-cashBookOst.ostrasch " статус " CashBook.Status_ skip.
                   output close.
               &endif
          end.
          define variable msum as decimal no-undo.
          case buf_chk-gds-pay.curr-code:
             when 0 then do:
                assign
                   msum =  (if v-curr-r-b = {&r-b-rubl}
                             then buf_chk-gds-pay.tot-r-b
                             else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                           )
                 .
             end.
             when v-base-code then do:
                  assign
                     msum = (if v-curr-r-b = {&r-b-base}
                             then buf_chk-gds-pay.tot-r-b
                             else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                            )
                 .
             end.
          end case.         
          find first buf_temp-fin-sum
               where buf_temp-fin-sum.curr-code = buf_chk-gds-pay.curr-code
                 and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                 and buf_temp-fin-sum.is-expense_cash = no
          no-error.
          if not available buf_temp-fin-sum 
          then do:
             create buf_temp-fin-sum.
             assign
                buf_temp-fin-sum.curr-code = buf_chk-gds-pay.curr-code
                buf_temp-fin-sum.cash-desk = 0
                buf_temp-fin-sum.is-petrol = no
                buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                buf_temp-fin-sum.is-expense_cash = no
                buf_temp-fin-sum.tot-rubl = tt-cashBookOst.ostrasch
                buf_temp-fin-sum.tot-base = tt-cashBookOst.ostrasch
                buf_temp-fin-sum.tot-sum =  tt-cashBookOst.ostrasch
             .
          end.
          assign
             buf_temp-fin-sum.tot-rubl = buf_temp-fin-sum.tot-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                                    then buf_chk-gds-pay.tot-r-b
                                                                     else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                    )
              buf_temp-fin-sum.tot-base = buf_temp-fin-sum.tot-base + (if v-curr-r-b = {&r-b-base}
                                                                     then buf_chk-gds-pay.tot-r-b
                                                                     else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
              buf_temp-fin-sum.tot-sum = buf_temp-fin-sum.tot-sum + msum
              tt-cashBookOst.ostrasch = + tt-cashBookOst.ostrasch + msum
          . 
              &if defined (debug) ne 0
              &then 
                   output to "rkoincas.log" append.
                   put unformatted "Кассовая книга " CashBook.id " чек " chk-doc.doc-code " продажа " chk-doc.out-code " Товар " " - "/* buf_chk-gds-pay.gds-code */ " сумма " msum skip.
                   output close.
               &endif
                    
       end.
       if ub.chk-doc.out-code eq ?
       then
          for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
           and buf_chk-gds-pay.algo-num = {&current-algo-1}
          exclusive-lock:
             delete buf_chk-gds-pay.
          end.
    end.
    
    cashb:
    for each cashbook no-lock:
       find first tt-cashBookOst where tt-cashBookOst.cashbookid eq CashBook.id
       no-error.
       if not available tt-cashBookOst
       then do:
          create tt-cashBookOst.
          assign
             tt-cashBookOst.cashbookid   =  CashBook.id
             tt-cashBookOst.cashbookname =  CashBook.CashBookName
          .
          run fostatok in this-procedure (
                 input   v-host-code
                  ,input   buf_shift-obj.obj-code
                  ,input   buf_shift-obj.obj-type
                  ,input   yes
                  ,input   buf_shift-obj.close-date - 1
                  ,input   v-obj-date
                  ,input   buf_shift-obj.shift-num
                  ,input   buf_shift-obj.shift-num
                  ,input   yes /*xTog-obj*/
                  ,input   0 /*p-curr-code*/
                  ,input   CashBook.id
                  ,output  tt-cashBookOst.ostrasch
                  ,output  Fact-order)
                 no-error .
                           
          /* если кассова книга удалена и нет остатка, то убираем ее из списка */
          if ub.CashBook.Status_ = 1 and tt-cashBookOst.ostrasch = 0 then 
          do:
              delete tt-cashBookOst.
              next cashb.
          end.    
          
          tt-cashBookOst.ost = tt-cashBookOst.ostrasch.                 
          find first buf_temp-fin-sum
               where buf_temp-fin-sum.curr-code = 0
                 and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                 and buf_temp-fin-sum.is-expense_cash = no
          no-error.
          if not available buf_temp-fin-sum 
          then do:
             create buf_temp-fin-sum.
             assign
                buf_temp-fin-sum.curr-code = 0
                buf_temp-fin-sum.cash-desk = 0
                buf_temp-fin-sum.is-petrol = no
                buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                buf_temp-fin-sum.is-expense_cash = no
                 buf_temp-fin-sum.tot-rubl = tt-cashBookOst.ostrasch
              buf_temp-fin-sum.tot-base = tt-cashBookOst.ostrasch
              buf_temp-fin-sum.tot-sum = tt-cashBookOst.ostrasch
             .
          end.
                   
       
       end.
       else
          tt-cashBookOst.ostrasch = round(tt-cashBookOst.ostrasch,2).
    end.
    
    define variable mSumAll as decimal no-undo.
    
    for each tt-cashBookOst where tt-cashBookOst.ostrasch > 0:
       mSumAll = mSumAll + tt-cashBookOst.ostrasch.
       tt-cashBookOst.chang = yes.
    end. 
    for each tt-cashBookOst where tt-cashBookOst.cashbookid eq 0:
       tt-cashBookOst.chang = yes.
    end.
    define variable msumInc as decimal no-undo.
    define variable msumInc-save as decimal no-undo.
    define variable mOsnbag as character no-undo.
    define variable mMoney  as character no-undo.
    define variable mOk     as logical no-undo.
    run ref/incas.p (input-output table tt-cashBookOst 
                   ,  input  mSumAll
                   , output msumInc
                   , output mOsnbag
                   , output mMoney
                   , output mOk).
    if not mOk then return.
    msumInc-save = msumInc.
    
    /*_______________________
    message "Остаток по всем кассовым книгам " mSumAll 
               " Инкасировать " msumInc " не возможно!" mSumAll - msumInc
       view-as alert-box.
    return.
    
    */
   /*if  msumInc > mSumAll
    then do:
       message "Остаток по всем кассовым книгам " mSumAll 
               " Инкасировать " msumInc " не возможно!" mSumAll - msumInc
       view-as alert-box.
       return.
    end.
    */
    
    for each buf_temp-fin-sum where  buf_temp-fin-sum.num-expense_cash eq 0
                                and  buf_temp-fin-sum.is-expense_cash  eq no
                                   by buf_temp-fin-sum.cashbookid desc:
       find first tt-cashBookOst where tt-cashBookOst.cashbookid eq buf_temp-fin-sum.cashbookid and tt-cashBookOst.chang no-lock no-error.
       if available tt-cashBookOst
       then
          buf_temp-fin-sum.tot-sum = -1 * min (if  buf_temp-fin-sum.cashbookid ne 0 then max(buf_temp-fin-sum.tot-sum,0) else msumInc,msumInc).
       else
          buf_temp-fin-sum.tot-sum = 0.
       msumInc = msumInc + buf_temp-fin-sum.tot-sum.
       if buf_temp-fin-sum.tot-sum eq 0
       then delete buf_temp-fin-sum.
       else do:
          create buf_temp-tax.
          assign
             buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
             buf_temp-tax.cash-desk        = buf_temp-fin-sum.cash-desk
             buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
             buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookid
             buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
             buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
             buf_temp-tax.sum-rubl         = buf_temp-fin-sum.tot-sum
             buf_temp-tax.sum-base         = buf_temp-fin-sum.tot-sum
             buf_temp-tax.sum-doc          = buf_temp-fin-sum.tot-sum
          .
       end.
    end.
                      
   
   for each temp-z-number
   break
   by temp-z-number.cash-desk
   :
     if first-of( temp-z-number.cash-desk) then do:
        find first temp-z-number-list
        where temp-z-number-list.cash-desk = temp-z-number.cash-desk no-error.
       if not available temp-z-number-list then do:
         create temp-z-number-list.
         assign
            temp-z-number-list.cash-desk = temp-z-number.cash-desk
          .
       end.
     end.
     assign
     v-naznach-plat = v-naznach-plat + (if v-naznach-plat = '' then '' else {&comma-char}) + string(temp-z-number.z-number)
     temp-z-number-list.naznach-plat = temp-z-number-list.naznach-plat + (if temp-z-number-list.naznach-plat = '' then '' else {&comma-char}) + string(temp-z-number.z-number)
     .
   end.

   v-naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", v-naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
   for each temp-z-number-list:
     assign
     temp-z-number-list.naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", temp-z-number-list.naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
   end.
   v-naznach-plat2 = v-naznach-plat . 

   /*теперь создадим fin-doc*/
   _temp-fin-sum:
   for each buf_temp-fin-sum no-lock
    by buf_temp-fin-sum.cashbookid desc 
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :

      empty temp-table tt0-fin-doc-tax.
      empty temp-table tt0-fin-doc-attr.
      empty temp-table tt-fin-doc.
      if buf_temp-fin-sum.tot-sum = 0  then do:
        next _temp-fin-sum.
      end.
      
      v-naznach-plat = v-naznach-plat2 .
      find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.CashBookId no-error .
      define variable mCashbookName as character no-undo.     
      mCashbookName = string(ub.CashBook.id).                            
      if available CashBook then assign
         v-real-obj-type = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, {&by_all}, 0, "CountCollect-type") . 
         v-real-obj-code = int(mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, {&by_all}, 0, "CountCollect-code") ).
         mCashbookName = string(ub.CashBook.id) + " (" + CashBook.CashBookName + ")".
      .
      define variable v-doc-rec as recid no-undo .
      /*if buf_temp-fin-sum.tot-sum > 0  then do:
        run ref/finfnoco.p (
                       INPUT parParentProc
                      ,INPUT ? /*не надо нам*/
                      ,input v-host-code
                      ,input ({&add-def} + {&delim-par} + {&auto})
                      ,input v-host-code
                      ,input v-doc-rec
                      ,input 0 /*p-fin-doc-code*/
                      ,input {&income-cash} /*p-fin-doc-type*/
                      ,input {&FDEDT_income_cash} /*p-fin-ext-doc-type*/
                      ,input buf_shift-obj.obj-type
                      ,input buf_shift-obj.obj-code
                      ,input 0 /*p-contract-code*/
                      ,input '' /*p-ob-doc-code*/
                      ,input v-real-obj-type /*p-payer-type*/
                      ,input v-real-obj-code /*p-payer-code*/
                      ,input 0 /*p-payer-code-schet*/
                      ,input {&cmp} /*p-receiver-type*/
                      ,input v-host-code /*p-receiver-code*/
                      ,input 0 /*p-receiver-code-schet*/
                      ,input buf_temp-fin-sum.curr-code
                      ,input 0 /*p-cor-acc*/
                      ,input 0 /*p-cor-acc1*/
                      ,input 0 /*p-an-uchet-code*/
                      ,input 0 /*p-cel-nazn-code*/
                      ,input buf_temp-fin-sum.cashbookid
                      ,INPUT-OUTPUT table tt-fin-doc
                      ,INPUT-OUTPUT table ttc-fin-doc
                      ,output table tt0-fin-doc-attr
                      ,output v-limit-access ) no-error .
        end.
        else do:
           */
          run ref/finfnoco.p (
                      INPUT parParentProc
                      ,INPUT ? /*не надо нам*/
                      ,input v-host-code
                      ,input ({&add-def} + {&delim-par} + {&auto})
                      ,input v-host-code
                      ,input v-doc-rec
                      ,input 0 /*p-fin-doc-code*/
                      ,input {&expense-cash} /*p-fin-doc-type*/
                      ,input {&FDEDT_expense_cash} /*p-fin-ext-doc-type*/
                      ,input buf_shift-obj.obj-type
                      ,input buf_shift-obj.obj-code
                      ,input 0 /*p-contract-code*/
                      ,input '' /*p-ob-doc-code*/
                      ,input {&cmp} /*p-payer-type*/
                      ,input v-host-code /*p-payer-code*/
                      ,input 0 /*p-payer-code-schet*/
                      ,input v-real-obj-type  /*p-receiver-type*/
                      ,input v-real-obj-code /*p-receiever-code*/
                      ,input 0 /*p-receiver-code-schet*/
                      ,input buf_temp-fin-sum.curr-code
                      ,input 0 /*p-cor-acc*/
                      ,input 0 /*p-cor-acc1*/
                      ,input 0 /*p-an-uchet-code*/
                      ,input 0 /*p-cel-nazn-code*/
                      ,input buf_temp-fin-sum.cashbookid
                      ,input v-cashier
                      ,INPUT-OUTPUT table tt-fin-doc
                      ,INPUT-OUTPUT table ttc-fin-doc
                      ,output table tt0-fin-doc-attr
                      ,output v-limit-access ) no-error .
       /* end. */ 
      if error-status:error then do:
        &scop my-message substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
        {&display-message}.
        undo _main, return error {&my-message}.

      end.
      find first tt-fin-doc.
      /*заполнение налогов*/
      define variable v-line-num as integer no-undo .

      for each buf_temp-tax no-lock
         where buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
          and buf_temp-tax.cash-desk         = buf_temp-fin-sum.cash-desk
           and buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
           and buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookId
           and buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
           and buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
              :
        v-line-num = v-line-num + 1.
        create tt0-fin-doc-tax .
        assign
        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
        tt0-fin-doc-tax.line-num           = v-line-num
        tt0-fin-doc-tax.VAT-pc             = buf_temp-tax.vat-pc
        tt0-fin-doc-tax.slt-pc             = buf_temp-tax.slt-pc
        tt0-fin-doc-tax.sum-line-contr     = 0
        tt0-fin-doc-tax.sum-vat-line-contr = 0
        tt0-fin-doc-tax.with-vat           = buf_temp-tax.with-vat
        .
        if buf_temp-fin-sum.tot-sum > 0  then do :
          assign
            tt0-fin-doc-tax.sum-line-doc       = buf_temp-tax.sum-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = buf_temp-tax.vat-doc
            tt0-fin-doc-tax.sum-line-rubl      = buf_temp-tax.sum-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = buf_temp-tax.vat-rubl
            tt0-fin-doc-tax.sum-line-base      = buf_temp-tax.sum-base
            tt0-fin-doc-tax.sum-vat-line-base  = buf_temp-tax.vat-base
          .
        end.
        else do :
          assign
        tt0-fin-doc-tax.sum-line-doc       = abs(buf_temp-tax.sum-doc)
        tt0-fin-doc-tax.sum-vat-line-doc   = abs(buf_temp-tax.vat-doc)
        tt0-fin-doc-tax.sum-line-rubl      = abs(buf_temp-tax.sum-rubl)
        tt0-fin-doc-tax.sum-vat-line-rubl  = abs(buf_temp-tax.vat-rubl)
        tt0-fin-doc-tax.sum-line-base      = abs(buf_temp-tax.sum-base)
        tt0-fin-doc-tax.sum-vat-line-base  = abs(buf_temp-tax.vat-base)
        .
        end.
        find first temp-autotank no-lock
             where temp-autotank.curr-code = buf_temp-tax.curr-code
                                  and temp-autotank.pay-desk = buf_temp-tax.cash-desk
               and temp-autotank.is-petrol = buf_temp-tax.is-petrol
               and temp-autotank.vat-pc    = buf_temp-tax.vat-pc
               and temp-autotank.slt-pc    = buf_temp-tax.slt-pc
                                  no-error.
        if available temp-autotank then do:
          assign
           tt0-fin-doc-tax.sum-line-doc       =  tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-doc   =  tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           .
        end.

        release tt0-fin-doc-tax.
      end.
      
      run StrTax in this-procedure ( input-output tt-fin-doc.including) .
       /* округляем  */
      run RoundTax in this-procedure .

      /*find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.cashbookid no-error .
      if not available ub.CashBook 
      then do :
        find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
      end.*/
      if available ub.CashBook
      then do :
        p-by-cash-desk = ub.CashBook.FlagSepCash .
        p-by-petrol-goods = ub.CashBook.FlagSepFull .
        p-by-osnovanie = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, {&by_all}, 0, "BasisIncas") .
        p-by-pril = ub.CashBook.RulePril .
      end.

      if p-by-cash-desk then do:
        find first temp-z-number-list no-lock
             where temp-z-number-list.cash-desk = buf_temp-fin-sum.cash-desk
             no-error.
        end.        
      

      if trim(p-by-pril) = '0' then tt-fin-doc.enclosure = v-naznach-plat.
      
        v-naznach-plat = if cashbook.id eq 0 then "Поступление от продажи товаров" else "Прочие поступления".
        if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
      
      assign
      tt-fin-doc.naznach-plat       = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
      assign
      tt-fin-doc.CashBookId = buf_temp-fin-sum.cashbookid
      tt-fin-doc.sum-doc = abs(buf_temp-fin-sum.tot-sum)
      tt-fin-doc.sum-base = abs(buf_temp-fin-sum.tot-base)
      tt-fin-doc.sum-rubl = abs(buf_temp-fin-sum.tot-rubl)
      tt-fin-doc.exch-rate = abs(if buf_temp-fin-sum.curr-code = 0 then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate = abs(if buf_temp-fin-sum.curr-code = v-base-code then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-base )
      tt-fin-doc.base-scale = 1
      .
      
      
      o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
      
      
      
      if available ub.CashBook
      then do :
        tt-fin-doc.cor-acc-value  = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, {&by_all}, 0, "CorrAcctIncas") .
        tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct .
        
               
        FIND ub.fin-code-cor-acc WHERE
         ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
         AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
         AND  ub.fin-code-cor-acc.status_ = integer({&current-status-int})
         NO-LOCK NO-error.
        
        if not available ub.fin-code-cor-acc
        then do:
          assign
            tt-fin-doc.cor-acc-value = {&question-mark}
          .
        end.
        else do:
          assign
            tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code
          .
        end.
        FIND ub.fin-code-cor-acc WHERE
         ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc1-value
         AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
         AND  ub.fin-code-cor-acc.status_ = integer({&current-status-int})
         NO-LOCK NO-error.
        
        if not available ub.fin-code-cor-acc
        then do:
          assign
            tt-fin-doc.cor-acc1-value = {&question-mark}
          .
        end.
        else do:
          assign
            tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
        end.
      end.
      if tt-fin-doc.cor-acc1-value eq "" or tt-fin-doc.cor-acc1-value eq ?
      then do:
         &scop my-message substitute("Не задан счет для инкасации" ~
                                     )
       {&DISPLAY-MESSAGE}.
       undo _main, return error  {&my-message}.
      end.
      if o-uchet = "0"
      then v-uchet = "cal" .
      else v-uchet = "smen" . 
      

       /*подкручиваем для утилиты */
       if buf_shift-obj.status_ = {&sht-closed} and v-uchet = "smen" then do:
         assign
         tt-fin-doc.doc-date = buf_shift-obj.close-date
         tt-fin-doc.shift-date = buf_shift-obj.shift-date
         tt-fin-doc.shift-num  = buf_shift-obj.shift-num
         tt-fin-doc.shift-name = buf_shift-obj.shift-name
         .
       end.
       assign
       tt-fin-doc.doc-author = {&auto}.
    &scop prfx tt-fin-doc.
      run ref/findoc0.p (
      input-output v-doc-rec
            ,input {&add-def} + {&delim-par} + {&auto}
            ,input yes
            {&all-fin-doc-params-doc-status-transfer}
            {&all-fin-doc-params-doc-status-transfer-2}
            ,input table tt0-fin-doc-tax
            ,input table tt0-fin-doc-attr
            ,input no /*p-save-payment*/
            ,input table tt0-payment
      ) no-error.
      if error-status:error then do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
        {&display-message}.
        undo _main, return error  {&my-message}.
      end.
      /*закрываем до факта*/
      find first buf_fin-doc share-lock where
                recid(buf_fin-doc) = v-doc-rec.
      assign
      buf_fin-doc.shift-flag = integer({&fin-flag-shift})
      .
      find first fin-doc-attr where fin-doc-attr.host-code    eq buf_fin-doc.host-code
                                and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                and fin-doc-attr.attr-code    eq "pre-vedom"
                                exclusive-lock no-error.
      if not available fin-doc-attr
      then do:
         create fin-doc-attr.
         assign
            fin-doc-attr.host-code    = buf_fin-doc.host-code
            fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
            fin-doc-attr.attr-code    = "pre-vedom"
         .
      end.
      define variable mPin as character no-undo.
      
      mPin   = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "Pin") .
      
      fin-doc-attr.attr-value = substitute("&1;&2;&3;&4;&5;&6;&7"
                                          ,mOsnbag
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankDepos-code")
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-code") 
                                          ,mPin
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "SourceCode")
                                          ,msumInc-save
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-acct")).
      buf_fin-doc.enclosure     =  "№ сумки: " + entry(1,fin-doc-attr.attr-value,";") + " " + buf_fin-doc.enclosure.
      define variable Vparentrec as character no-undo. 
      if Vparentrec eq ""
      then
         run gen-key-rec in this-procedure ("fin-doc",(buffer buf_fin-doc:handle),output Vparentrec ).
      find first fin-doc-attr where fin-doc-attr.host-code       eq buf_fin-doc.host-code
                                   and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                   and fin-doc-attr.attr-code    eq "ParentMoney"
                                   exclusive-lock no-error.
         if not available fin-doc-attr
         then do:
            create fin-doc-attr.
            assign
               fin-doc-attr.host-code    = buf_fin-doc.host-code
               fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
               fin-doc-attr.attr-code    = "ParentMoney"
            .
         end.
         fin-doc-attr.attr-value = Vparentrec.
      if mMoney ne ""
      then do:
         find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
                                   and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                   and fin-doc-attr.attr-code eq "cover_sheet"
                                   exclusive-lock no-error.
         if not available fin-doc-attr
         then do:
            create fin-doc-attr.
            assign
               fin-doc-attr.host-code    = buf_fin-doc.host-code
               fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
               fin-doc-attr.attr-code    = "cover_sheet"
            .
         end.
         fin-doc-attr.attr-value = mMoney.
         mMoney = "".
      end.
      
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
      if error-status :error then do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
        {&display-message}.
        undo _main, return error  {&my-message}.
       END.
      if buf_fin-doc.status_ <> {&fin-fact} then do:
        run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
        if error-status :error then do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
          {&display-message}.
          undo _main, return error  {&my-message}.
        END.
      end.
      if buf_fin-doc.status_ <> {&fin-fact} then do:
        run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
        if error-status :error then do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
          {&display-message}.
          undo _main, return error  {&my-message}.
        END.
     end.
     
     &scop fin-doc-type-code (if buf_temp-fin-sum.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
     &scop my-message substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 &9" ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , mCashbookName ~
                                  , abs(buf_temp-fin-sum.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
    {&DISPLAY-MESSAGE}.
    message {&my-message} view-as alert-box.
   end. /*for each buf_temp-fin-sum no-lock*/

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/
  run rep/pre-vedom.p (
                  INPUT parParentProc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
              ) no-error.
end. /*doe _main*/

finally:
    delete object mCashBook no-error .
end finally.
end procedure. /* proc-main */

/*procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#news = yes then do:
    return "return".
  end.
  run gen-row-keyr in this-procedure (
                                        input  p-doc-code /*uniq-key-rec смены*/
                                        ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                        ,input  "ub"
                                        ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                        ,input  no-lock
                                        ,output v-rowid
                                        ,output v-tbl-name ) .

  find first buf_shift-obj no-lock where
            rowid(buf_shift-obj) = v-rowid.

  /*---------------------------&start-process-rule-call-param&-------------------------------*/
/*  find first buf_rule-call-param no-lock                               */
/*  where buf_rule-call-param.codex_id = p-codex-id                      */
/*  and buf_rule-call-param.ruleset_id = p-ruleset-id                    */
/*  and buf_rule-call-param.call_id = p-call-id                          */
/*  and buf_rule-call-param.order_id = p-order-id                        */
/*  and buf_rule-call-param.rule_id = p-rule-id                          */
/*  and buf_rule-call-param.param-name = "p-by-cash-desk" no-error.      */
/*  if available buf_rule-call-param then do:                            */
/*    assign p-by-cash-desk = buf_rule-call-param.param-value-logical.   */
/*  end.                                                                 */
/*                                                                       */
/*  find first buf_rule-call-param no-lock                               */
/*  where buf_rule-call-param.codex_id = p-codex-id                      */
/*    and buf_rule-call-param.ruleset_id = p-ruleset-id                  */
/*    and buf_rule-call-param.call_id = p-call-id                        */
/*    and buf_rule-call-param.order_id = p-order-id                      */
/*    and buf_rule-call-param.rule_id = p-rule-id                        */
/*    and buf_rule-call-param.param-name = "p-by-petrol-goods" no-error. */
/*  if available buf_rule-call-param then do:                            */
/*    assign p-by-petrol-goods = buf_rule-call-param.param-value-logical.*/
/*  end.                                                                 */

/*---------------------------&end-process-rule-call-param&-------------------------------*/

end. /*doe*/

end procedure. /* load-ruleset-context */
*/

PROCEDURE StrTax :
  do
  on error undo, return error return-value
  :
    define input-output parameter str as character no-undo .
    define variable v-envd as logical no-undo .
    assign str = " В т.ч.: "  .

    for each tt0-fin-doc-tax :
      
      if str <> " В т.ч.: " then str = str + "," .
      if not tt0-fin-doc-tax.with-vat then assign str = str + "без НДС - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else do:
      if tt-fin-doc.curr-code = 0 then do:
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      end.
      else do:
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      end.  
    end.
    if str = " В т.ч.: " then assign str = "" .
  end.
  end.
END PROCEDURE.

PROCEDURE RoundTax :
  do
  on error undo, return error return-value
  :
    for each tt0-fin-doc-tax :
      assign
        tt0-fin-doc-tax.sum-line-doc       =  ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc   =  ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl      =  ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl  =  ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base      =  ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base  =  ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
      .
    end.
  end.
END PROCEDURE.

procedure proc-close :
define parameter buffer buf_fin-doc for ub.fin-doc.

define variable v-status_ as character no-undo .
/*куда перейдет*/
define variable v-old-status_ as character no-undo .
/*статус первой записи*/
define variable v-ask-date as logical no-undo .
/*дата перехода статуса*/
define variable v-ask-message as character no-undo .
/*подтверждающий запрос пользователю */
define variable v-status-date-chr as character no-undo.
define variable v-date1 as date no-undo .
assign
v-old-status_ = buf_fin-doc.status_
.
run trg/findgraf.p (
                input  buf_fin-doc.host-code
                ,input  buf_fin-doc.fin-doc-code
                ,input  {&close-doc}
                ,input  '' /*много платежей неизвестно можн и ли нет*/
                ,input  v-old-status_
                ,input  ?                     /*p-status-date*/
                ,output v-status_
                ,output v-ask-date
                ,output v-ask-message
                ) no-error.
if error-status:error then do:
  return error substitute("Ошибка при проверке возможности &1&2&3"
                           ,{&close-doc}
                           , {&new-line}
                           , return-value ).
end.

v-date1 = buf_fin-doc.doc-date.
run trg/findstat.p (
                  input parparentproc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
                ,input {&close-doc}
                ,input {&auto} /*p-author*/
                ,input v-status_
                ,input-output v-date1
                ,input no /*p-silent*/
                ) no-error .
if error-status:error then do:
  return error substitute("Ошибка при переводе статуса финансового документа:&1&2&1&3"
                           ,{&close-doc}
                           , {&new-line}
                           , return-value ).


end.
end procedure. /* proc-close */

/*-------------------------*/
procedure check-petrol :

define input  parameter p-b-code       like ub.chk-gds-pay.b-code no-undo.
define output parameter p-is-petrolium as logical                 no-undo.

define variable is-petrol    as logical   no-undo.
define variable is-pieces    as logical   no-undo.
define variable v-value      as character no-undo.
define variable v-type       as character no-undo.

define buffer buf_bar-code       for ub.bar-code.
define buffer buf_goods          for ub.goods.

  find first buf_bar-code no-lock where
          buf_bar-code.b-code = p-b-code no-error.
  if available buf_bar-code then do:
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if available buf_goods then do:

      assign p-is-petrolium = false .

      { str/is-petrl.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            is-petrol
            is-pieces
            no-error
      }

      if  is-petrol = yes
      and is-pieces = no
      then do : /* проверим на ТНП через ТРК */
        run gds-attr-value in this-procedure (
                                         input buf_goods.gds-code
                                        ,input {&attr-ptrl-as-good}
                                        ,output v-value
                                        ,output v-type
                                        ) no-error.
        if NOT logical(v-value) = yes then do: /* нет атрибута */
          assign p-is-petrolium = yes.
        end.
      end.
    end.
  end.

end procedure.



