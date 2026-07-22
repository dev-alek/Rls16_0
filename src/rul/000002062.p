/*

$Revision: 5ee64da48eb6, 3419, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:30 $
$Workfile: 000002062.p $
$Archive: rul/000002062.p $

Вспомогательный файл для кодекса правил 24, набор 1

Автор: Комаров Иван Сергеевич
Дата создания: 07/05/11
Author: Ivan Komarov
Creation date: 07/05/11

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 10/16/09


---------------------------&start-codex_id=24;ruleset_id=1;-------------------------------

---------------------------&end-codex_id=24;ruleset_id=1;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/
block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc   as widget-handle       no-undo .
define input parameter p-parent-handle as handle              no-undo .
define input parameter p-log-handle    as handle              no-undo .
define input parameter p-cont-handle   as handle              no-undo .
define input parameter p-codex-id      as integer             no-undo .
define input parameter p-ruleset-id    as integer             no-undo .
define input parameter p-call-id       as character           no-undo .
define input parameter p-order-id      as integer             no-undo .
define input parameter p-rule-id       as integer             no-undo .
define input parameter p-profile-id    as integer             no-undo .
define input parameter p-is-dynamic    as logical             no-undo .
define input parameter p-doc-type      as character           no-undo .
define input parameter p-host-code  like ub.sysconf.host-code no-undo .
define input parameter p-obj-type   like ub.clients.obj-type  no-undo .
define input parameter p-obj-code   like ub.clients.obj-code  no-undo .
define input parameter p-doc-code      as character           no-undo .
define input parameter p-process-file-name as character       no-undo .
define input parameter p-save          as integer             no-undo .
define input parameter v-curr-r-b      as character           no-undo .
define input parameter p-cmd-proc-handle as handle            no-undo .
define input parameter p-cmd-code      as integer             no-undo .


define variable vss-revision    as character no-undo init "$Revision: 5ee64da48eb6, 3419, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:30 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 000002062.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rul/000002062.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 24, набор 1".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }
{ cmp/obj-list.i new }
  run create_obj-list(p-obj-type,p-obj-code).
  { rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" } /* Fact-order и остатки на дату ПО ФИН АРХИВАМ */
  { ref/fndocip.i  }
  { rep/r-pychk0.i defalgo    }
  { str/out-vatp.i def    }
  { str/lib-trn.i  }
  { ref/gds-attr.i }
  { ref/fd-attr.i }


  /*переменные контекста*/
  /*это у нас объект 0*/
  define variable v-current-doc-code   as character no-undo .
  define variable log-file-name        as character no-undo init "process-fdoc.txt".
  define variable v-view-log           as logical   no-undo .
  define variable v-stop               as logical   no-undo .
  define variable v-last-error-message as character no-undo .
  /*****************************/
  define variable file-name            as character no-undo.
  define variable v-sign               as integer   no-undo.
  define variable l-res                as integer   no-undo.
  define variable v-es                 as logical   no-undo.
  define variable v-esm                as character no-undo.
  define variable v-rv                 as character no-undo.
  define variable v-err-mess           as character no-undo.
  define variable is-petrolium         as logical   no-undo.

  define variable o-uchet              as character no-undo .
  define variable v-uchet              as character no-undo .
  define variable v-value-date         as date      no-undo .
  define variable v-value-decimal      as decimal   no-undo .
  define variable v-value-integer      as INTEGER   no-undo .
  define variable v-value-logical      AS LOGICAL   no-undo .
  define variable par-type             as character no-undo .
  define variable v-tth                as handle    no-undo .
  define variable mValue               as character no-undo.
  define variable mType                as character no-undo.
  define variable mValueVne            as character no-undo.
  define variable mTypeVne             as character no-undo.
  define variable mValueAvans          as character no-undo.
  define variable mTypeAvans           as character no-undo.
  define variable mTypePay             as character no-undo.
  define variable taxVne               as character no-undo .
  define buffer buf_shift-obj for ub.shift-obj.
  { str/dia2auto.i }
  { rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




  /*---------------------------&start-rule-call-param&-------------------------------*/
  define variable mCashBook         as class     ibs.th.ref.cashbookstorage no-undo .
  define variable p-by-cash-desk    as logical   no-undo .
  define variable p-by-petrol-goods as logical   no-undo .
  define variable p-by-osnovanie    as character no-undo .
  define variable p-by-pril         as character no-undo .


  /*---------------------------&end-rule-call-param&-------------------------------*/


  /* ------------------------- &start-i-script& -----------------------------------*/



  /* ------------------------- &end-i-script& -----------------------------------*/

  on delete of this-procedure 
    do:
      run garbcoll_clear in this-procedure .
    end.
  run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
  if error-status:error then 
  do:
    undo, return error return-value .
  end.
  if return-value = "return" then return ''.

  /* ------------------------- &start-def-vars& -----------------------------------*/


  /* ------------------------- &end-def-vars& -----------------------------------*/

  if not this-procedure:persistent then 
  do:
    run proc-main in this-procedure no-error .
    if error-status:error then 
    do:
      v-esm = error-status :get-message (1).
      v-es = error-status:error .
      v-rv = return-value .
    end.
    if v-es then 
    do:
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
  
  define temp-table tt-cashbookAttr no-undo 
    field cashbookid as int64
    field vneCli     as character
    field vneCorr    as character
    field avansCli   as character
    field avansCorr  as character
    index pi cashbookid
    .
  
  define temp-table tt-cashBookOst no-undo
    field cashbookid as int64
    field ost        as decimal 
    field osnpko     as decimal
    field osnrko     as decimal 
    index pi cashbookid.

  define temp-table tt-cashBookOstVne no-undo
    field cashbookid as int64
    field ost        as decimal 
    field osnpko     as decimal
    field osnrko     as decimal 
    index pi cashbookid.

  define temp-table tt-cashBookOstAvans no-undo
    field cashbookid as int64
    field ost        as decimal 
    field osnpko     as decimal
    field osnrko     as decimal 
    index pi cashbookid.
        
  define temp-table temp-fin-sum no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character 
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .

  define temp-table temp-fin-sumVne no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character 
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .

  define temp-table temp-fin-sumAvans no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character 
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .
        
  define temp-table temp-gds no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    /*is-petrol*/
    .
    
  define temp-table temp-gdsVne no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    /*is-petrol*/
    .

  define temp-table temp-gdsAvans no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    /*is-petrol*/
    .
        
  define temp-table temp-tax no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
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
    pay-type
    .

  define temp-table temp-taxVne no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
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
    pay-type
    .

  define temp-table temp-taxAvans no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
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
    pay-type
    .
        
  define temp-table temp-z-number no-undo
    field z-number  as integer
    field cash-desk as integer
    index pi is unique primary
    cash-desk z-number.

  define temp-table temp-z-number-list no-undo
    field cash-desk    as integer
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

  define buffer buf_inkas                 for ub.inkas.
  define buffer buf_inkas-pay-desk        for ub.inkas-pay-desk.
  define buffer buf_cash-pay              for ub.cash-pay.
  define buffer buf_temp-fin-sum          for temp-fin-sum.
  define buffer buf_temp-fin-sum-Pko      for temp-fin-sum.
  define buffer buf_temp-fin-sumVne       for temp-fin-sumVne.
  define buffer buf_temp-fin-sumVne-Pko   for temp-fin-sumVne.
  define buffer buf_temp-fin-sumAvans     for temp-fin-sumAvans.
  define buffer buf_temp-fin-sumAvans-Pko for temp-fin-sumAvans.
  define buffer buf_chk-gds-pay           for ub.chk-gds-pay.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer buf_chk-pay               for ub.chk-pay.
  define buffer buf_chk-pay-attr          for ub.chk-pay-attr.
  define buffer buf_temp-gds              for temp-gds.
  define buffer buf_temp-gdsVne           for temp-gdsVne.
  define buffer buf_temp-gdsAvans         for temp-gdsAvans.
  define buffer buf_bar-code              for ub.bar-code.
  define buffer buf_goods                 for ub.goods.
  define buffer buf_sale-doc              for ub.sale-doc.
  define buffer buf_trn-doc               for ub.trn-doc.
  define buffer buf_doc-line              for ub.doc-line.
  define buffer buf_gds-dtl               for ub.gds-dtl.
  define buffer buf_temp-tax              for temp-tax.
  define buffer buf_temp-taxVne           for temp-taxVne.  
  define buffer buf_temp-taxAvans         for temp-taxAvans.    
  define buffer buf_fin-doc               for ub.fin-doc.
  define buffer buf_sysconf               for ub.sysconf.
  define buffer buf_shift-staff           for ub.shift-staff.
  define buffer buf_chk-gds               for ub.chk-gds.
  mCashBook = new ibs.th.ref.cashbookstorage () .
      
      
  _main:
  do
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :

    define variable v-err as logical no-undo .

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
    /*      undo, return error .                                                                                                              */
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
    /*      undo, return error .                                                                                                              */
    /*    end.                                                                                                                                */
 
    /* Посмотрим заполнены ли параметры для кассовых книг */

    for each ub.CashBook no-lock:
      create tt-cashbookAttr .
      assign 
        tt-cashbookAttr.cashbookid = ub.CashBook.id .
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "Vnecli-code":
        tt-cashbookAttr.vneCli = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "corrPkoVne":
        tt-cashbookAttr.vneCorr = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "Avanscli-code":
        tt-cashbookAttr.avansCli = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "corrPkoAvans":
        tt-cashbookAttr.avansCorr = ub.CashBookRule.RuleValue .
      end.         
    end.
 
    /*перезаполним с учетом  требований ЮКОС*/
    find first buf_shift-staff no-lock
      where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
      and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
      and buf_shift-staff.shift-date = buf_shift-obj.shift-date
      and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
      and buf_shift-staff.staff-role = yes no-error.
    if not available buf_shift-staFF THEN 
    DO:
      if buf_shift-obj.status_ = {&sht-closed} then 
      do:
        v-cashier = "адм".
      end.
      else 
      do:
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
        if return-value = 'false':u then 
        do:
      &scop my-message substitute("Нельзя создать ордер на выручку, если кассир не определен")
          {&display-message}.
          undo, return error .
        END.
      end.
      v-cashier = v-value.
    end.
    else 
    do:
      v-cashier = buf_shift-staff.name.
    end.

    /*проверим что есть размаз*/
    for each buf_chk-gds-pay no-lock
      where buf_chk-gds-pay.obj-type   = buf_shift-obj.obj-type
      and buf_chk-gds-pay.obj-code   = buf_shift-obj.obj-code
      and buf_chk-gds-pay.shift-date = buf_shift-obj.shift-date
      and buf_chk-gds-pay.shift-num  = buf_shift-obj.shift-num
      and buf_chk-gds-pay.algo-num   = {&current-algo-1}:
      assign
        v-tot-r-b-chk = v-tot-r-b-chk  + buf_chk-gds-pay.tot-r-b
        .
      if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
        and entry(2, buf_chk-gds-pay.line-type, {&delim-par}) = ""
        then 
      do :
        find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_chk-gds-pay.b-code
          and buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code
          and buf_chk-gds.line-num = buf_chk-gds-pay.line-num
          no-error .
        if not available buf_chk-gds
          then 
        do :
          find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_chk-gds-pay.b-code
            and buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code .  
        end. 
        if num-entries(buf_chk-gds.line-type, {&delim-par}) > 1 
          then 
        do :                               
          find first ub.chk-gds-pay exclusive-lock where rowid(ub.chk-gds-pay) = rowid(buf_chk-gds-pay) .
          assign
            entry(2, ub.chk-gds-pay.line-type, {&delim-par}) = entry(2, buf_chk-gds.line-type, {&delim-par})
            .   
          release ub.chk-gds-pay .
        end.                             
      end.
    end. /*for each buf_chk-gds-pay no-lock where*/
    for each buf_inkas no-lock
      where buf_inkas.obj-type   = buf_shift-obj.obj-type
      and buf_inkas.obj-code   = buf_shift-obj.obj-code
      and buf_inkas.status_    = {&fact}
      and buf_inkas.shift-date = buf_shift-obj.shift-date
      and buf_inkas.shift-num  = buf_shift-obj.shift-num
      :
      assign
        v-count         = v-count + 1
        v-tot-r-b-inkas = v-tot-r-b-inkas  + buf_inkas.netto
        .
      /*     for each buf_inkas-pay-desk no-lock                                          */
      /*         where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code :             */
      /*       find first buf_cash-pay no-lock                                            */
      /*             where buf_cash-pay.cdpay-code = buf_inkas-pay-desk.pay-code          */
      /*               and buf_cash-pay.curr-code = buf_inkas-pay-desk.curr-code no-error.*/
      /*       if not available buf_cash-pay then do:                                     */
      /*       end.                                                                       */
      /*       if not (buf_cash-pay.is-cash                                               */
      /*       or buf_cash-pay.cdpay-code = 1) then do:                                   */
      /*         next.                                                                    */
      /*       end.                                                                       */
      /*     end.                                                                         */
      for each buf_chk-doc no-lock
        where buf_chk-doc.obj-type    = buf_inkas.obj-type
        and buf_chk-doc.obj-code    = buf_inkas.obj-code
        and buf_chk-doc.out-code    = buf_inkas.inkas-code
        and (buf_chk-doc.chk-type    = integer({&rcpt-sale})
        or  buf_chk-doc.chk-type    = integer({&rcpt-return}))
        :
        /*          find first buf_inkas-pay-desk no-lock where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code*/
        /*                                                  and buf_inkas-pay-desk.pay-desk = buf_chk-doc.pay-desk  */
        if not can-find (first temp-z-number
          where temp-z-number.cash-desk = buf_chk-doc.pay-desk
          and temp-z-number.z-number  = buf_chk-doc.z-number)
          then 
        do:
          create temp-z-number.
          assign
            temp-z-number.cash-desk = buf_chk-doc.pay-desk
            temp-z-number.z-number  = buf_chk-doc.z-number
            .
        end.
      end. /* for each ub.chk-doc */
    end. /*for each buf_inkas no-lock where*/
    if abs(v-tot-r-b-chk - v-tot-r-b-inkas) > 0.015 * v-count then 
    do:
      &scop my-message substitute("В БД нет ПОЛНОЙ информации по разбиению товарных сумм в чеках по типам кассовых платежей")
      {&display-message}.
      undo _main, return error .
    end. /*if abs(v-tot-r-b-chk - v-tot-r-b-inkas) > 0.015 * v-count then do:*/
    &scop my-message substitute("Создание кассовых ордеров для выручки по смене № &1 от &2 (П. &3) &6&4&5" ~
                                , buf_shift-obj.shift-name ~
                                , buf_shift-obj.shift-date ~
                                , buf_shift-obj.shift-nuM    ~
                                , buf_shift-obj.obj-type ~
                                , buf_shift-obj.obj-code ~
                                , ~{&new-line~} ~
                                )
    {&DISPLAY-MESSAGE}.

    for each buf_inkas no-lock
      where buf_inkas.obj-type   = buf_shift-obj.obj-type
      and buf_inkas.obj-code   = buf_shift-obj.obj-code
      and buf_inkas.status_    = {&fact}
      and buf_inkas.shift-date = buf_shift-obj.shift-date
      and buf_inkas.shift-num  = buf_shift-obj.shift-num
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :

      for each buf_inkas-pay-desk no-lock
        where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code
        break
        by buf_inkas-pay-desk.inkas-code
        by buf_inkas-pay-desk.pay-code
        by buf_inkas-pay-desk.curr-code
        by buf_inkas-pay-desk.pay-desk
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
        :

        find first buf_cash-pay no-lock
          where buf_cash-pay.cdpay-code = buf_inkas-pay-desk.pay-code
          and buf_cash-pay.curr-code = buf_inkas-pay-desk.curr-code no-error.
        if not available buf_cash-pay then 
        do:
        end.
        if not (buf_cash-pay.is-cash
          or buf_cash-pay.cdpay-code = 1) then 
        do:
          next.
        end.

        if last-of(buf_inkas-pay-desk.pay-desk) then 
        do:
//создание финдоков
          for each buf_chk-doc no-lock
            where buf_chk-doc.obj-code = buf_inkas.obj-code
            and buf_chk-doc.obj-type = buf_inkas.obj-type
            and buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
            and buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
            /*          and buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier*/
            :
            for each buf_chk-gds-pay no-lock
              where buf_chk-gds-pay.out-code = buf_inkas-pay-desk.inkas-code
              and buf_chk-gds-pay.obj-code = buf_inkas.obj-code
              and buf_chk-gds-pay.pay-code = buf_inkas-pay-desk.pay-code
              and buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
              and buf_chk-gds-pay.algo-num = {&current-algo-1}
              :
              if buf_chk-gds-pay.curr-code <> buf_inkas-pay-desk.curr-code then next .
                    
              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input "cash-book-id"
                ,output mValue
                ,output mType) no-error.

              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input {&attr-item-matter-mark}
                ,output mValueVne
                ,output mTypeVne) no-error.                     

              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input {&attr-type-method-calc}
                ,output mValueAvans
                ,output mTypeAvans) no-error.        
                                       
              if p-by-petrol-goods then 
              do: /*проверяем товар на топливность*/
                run check-petrol in this-procedure (
                  input buf_chk-gds-pay.b-code ,
                  output is-petrolium
                  ).
              end.       
              define variable msum    as decimal no-undo.
              define variable msumVne as decimal no-undo.
              case buf_chk-gds-pay.curr-code:
                when 0 then 
                  do:
                    assign
                      msum = (if v-curr-r-b = {&r-b-rubl}
                                 then buf_chk-gds-pay.tot-r-b
                                 else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                          )
                      .
                  end.
                when v-base-code then 
                  do:
                    assign
                      msum = (if v-curr-r-b = {&r-b-base}
                                then buf_chk-gds-pay.tot-r-b
                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                          )
                      .
                  end.
              end case.
              find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
              if not available ub.CashBook 
                then 
              do :
                find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
              end.
              find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
              if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
              if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
               
              if available ub.CashBook
                then 
              do :
                find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
                  and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
                  and ub.chk-gds-attr.attr-code = "cstype"
                  no-lock no-error.
                p-by-cash-desk = ub.CashBook.FlagSepCash .
                p-by-petrol-goods = ub.CashBook.FlagSepFull .
                mTypePay          = if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then 'Cash' else "".
                /*p-by-osnovanie = if (msum < 0 and ub.CashBook.id ne 0) then ub.CashBook.RuleOsnRko else  ub.CashBook.RuleOsnPko .
                p-by-pril = ub.CashBook.RulePril */
                .
              end.   
              if mValueVne = "15" then 
              do:  
                /* Внереалиционный доход */
                find first buf_temp-fin-sumVne
                  where buf_temp-fin-sumVne.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sumVne.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sumVne.is-petrol = is-petrolium)
                  and buf_temp-fin-sumVne.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sumVne.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sumVne.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sumVne then 
                do:
                  create buf_temp-fin-sumVne.
                  assign
                    buf_temp-fin-sumVne.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sumVne.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sumVne.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sumVne.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sumVne.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sumVne.pay-type        = mTypePay
                        
                    .
                end.
                assign
                  buf_temp-fin-sumVne.tot-rubl = buf_temp-fin-sumVne.tot-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumVne.tot-base = buf_temp-fin-sumVne.tot-base + (if v-curr-r-b = {&r-b-base}
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumVne.tot-sum  = buf_temp-fin-sumVne.tot-sum + msum
                    
                  .       
              end .
              else 
              do:
                /* Аванс */
                if mValueAvans > "" then do:
                                  find first buf_temp-fin-sumAvans
                  where buf_temp-fin-sumAvans.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sumAvans.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sumAvans.is-petrol = is-petrolium)
                  and buf_temp-fin-sumAvans.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sumAvans.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sumAvans.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sumAvans then 
                do:
                  create buf_temp-fin-sumAvans.
                  assign
                    buf_temp-fin-sumAvans.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sumAvans.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sumAvans.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sumAvans.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sumAvans.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sumAvans.pay-type        = mTypePay
                        
                    .
                end.
                assign
                  buf_temp-fin-sumAvans.tot-rubl = buf_temp-fin-sumAvans.tot-rubl + (if v-curr-r-b = {&r-b-rubl}
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumAvans.tot-base = buf_temp-fin-sumAvans.tot-base + (if v-curr-r-b = {&r-b-base}
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumAvans.tot-sum  = buf_temp-fin-sumAvans.tot-sum + msum
                    
                  .       
                  
                end.
                else do:
                find first buf_temp-fin-sum
                  where buf_temp-fin-sum.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sum.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sum.is-petrol = is-petrolium)
                  and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sum.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sum.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sum then 
                do:
                  create buf_temp-fin-sum.
                  assign
                    buf_temp-fin-sum.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sum.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sum.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sum.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sum.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sum.pay-type        = mTypePay
                        
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
                  buf_temp-fin-sum.tot-sum  = buf_temp-fin-sum.tot-sum + msum
                    
                  .
               
              end.  
             end.                            
                    
                  
            end.
          end.
          if mValueVne = "15" then 
          do:
            FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
              AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
              AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
              EACH buf_chk-pay NO-LOCK
              where buf_chk-pay.doc-code = buf_chk-doc.doc-code
              AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
              AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
              FIRST buf_chk-pay-attr NO-LOCK
              WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
              AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
              AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
              assign
                buf_temp-fin-sumVne.tot-sum  = buf_temp-fin-sumVne.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumVne.tot-rubl = buf_temp-fin-sumVne.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumVne.tot-base = buf_temp-fin-sumVne.tot-base - decimal(buf_chk-pay-attr.attr-value)
                .      /* автотанк только на рублевых объектах  */
              find first buf_chk-gds no-lock
                where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                no-error.
              if available buf_chk-gds then 
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                if available buf_bar-code then 
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then 
                  do:
                    { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-vat-pc no-error }
                    { gbl/pftxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-slt-pc no-error }
                  end.
                end.
              end.

              find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                and temp-autotank.vat-pc    =  v-vat-pc
                and temp-autotank.slt-pc    =  v-slt-pc
                and temp-autotank.pay-desk = (if p-by-cash-desk
                then buf_inkas-pay-desk.pay-desk
                else 0)
                and temp-autotank.is-petrol = (if p-by-petrol-goods
                then buf_temp-fin-sumVne.is-petrol
                else no)
                no-error.
              if not available temp-autotank then 
              do:
                create temp-autotank.
                assign
                  temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                  temp-autotank.vat-pc    = v-vat-pc
                  temp-autotank.slt-pc    = v-slt-pc
                  temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                  temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sumVne.is-petrol
                                        else no)
                  .
              end.

              assign
                temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                .
            END.
          end.
          else 
          do:
            if mValueAvans > "" then 
            do:
                          FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
              AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
              AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
              EACH buf_chk-pay NO-LOCK
              where buf_chk-pay.doc-code = buf_chk-doc.doc-code
              AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
              AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
              FIRST buf_chk-pay-attr NO-LOCK
              WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
              AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
              AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
              assign
                buf_temp-fin-sumAvans.tot-sum  = buf_temp-fin-sumAvans.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumAvans.tot-rubl = buf_temp-fin-sumAvans.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumAvans.tot-base = buf_temp-fin-sumAvans.tot-base - decimal(buf_chk-pay-attr.attr-value)
                .      /* автотанк только на рублевых объектах  */
              find first buf_chk-gds no-lock
                where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                no-error.
              if available buf_chk-gds then 
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                if available buf_bar-code then 
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then 
                  do:
                    { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-vat-pc no-error }
                    { gbl/pftxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-slt-pc no-error }
                  end.
                end.
              end.

              find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                and temp-autotank.vat-pc    =  v-vat-pc
                and temp-autotank.slt-pc    =  v-slt-pc
                and temp-autotank.pay-desk = (if p-by-cash-desk
                then buf_inkas-pay-desk.pay-desk
                else 0)
                and temp-autotank.is-petrol = (if p-by-petrol-goods
                then buf_temp-fin-sumAvans.is-petrol
                else no)
                no-error.
              if not available temp-autotank then 
              do:
                create temp-autotank.
                assign
                  temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                  temp-autotank.vat-pc    = v-vat-pc
                  temp-autotank.slt-pc    = v-slt-pc
                  temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                  temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sumAvans.is-petrol
                                        else no)
                  .
              end.

              assign
                temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                .
            END.
              
            end.
            else 
            do:
              FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
                AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
                AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
                EACH buf_chk-pay NO-LOCK
                where buf_chk-pay.doc-code = buf_chk-doc.doc-code
                AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
                AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
                FIRST buf_chk-pay-attr NO-LOCK
                WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
                assign
                  buf_temp-fin-sum.tot-sum  = buf_temp-fin-sum.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                  buf_temp-fin-sum.tot-rubl = buf_temp-fin-sum.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                  buf_temp-fin-sum.tot-base = buf_temp-fin-sum.tot-base - decimal(buf_chk-pay-attr.attr-value)
                  .      /* автотанк только на рублевых объектах  */
                find first buf_chk-gds no-lock
                  where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                  no-error.
                if available buf_chk-gds then 
                do:
                  find first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                  if available buf_bar-code then 
                  do:
                    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                    if available buf_goods then 
                    do:
                    { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-vat-pc no-error }
                    { gbl/pftxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-host-code buf_inkas.obj-type buf_inkas.obj-code v-slt-pc no-error }
                    end.
                  end.
                end.

                find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                  and temp-autotank.vat-pc    =  v-vat-pc
                  and temp-autotank.slt-pc    =  v-slt-pc
                  and temp-autotank.pay-desk = (if p-by-cash-desk
                  then buf_inkas-pay-desk.pay-desk
                  else 0)
                  and temp-autotank.is-petrol = (if p-by-petrol-goods
                  then buf_temp-fin-sum.is-petrol
                  else no)
                  no-error.
                if not available temp-autotank then 
                do:
                  create temp-autotank.
                  assign
                    temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                    temp-autotank.vat-pc    = v-vat-pc
                    temp-autotank.slt-pc    = v-slt-pc
                    temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                    temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sum.is-petrol
                                        else no)
                    .
                end.

                assign
                  temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                  .
              END.
            end.
          end.
          _chk-gds-pay:
          for each buf_chk-gds-pay no-lock
            where buf_chk-gds-pay.out-code = buf_inkas.inkas-code
            and buf_chk-gds-pay.obj-code = buf_inkas.obj-code
            and buf_chk-gds-pay.pay-code = buf_inkas-pay-desk.pay-code
            and buf_chk-gds-pay.algo-num = {&current-algo-1},
            first buf_chk-doc no-lock
            where buf_chk-doc.doc-code = buf_chk-gds-pay.doc-code
            and buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk:
            if buf_chk-gds-pay.curr-code <> buf_inkas-pay-desk.curr-code then next _chk-gds-pay.
            /* if p-by-cash-desk then do:
               find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = buf_chk-gds-pay.doc-code no-error.
               if not available buf_chk-doc then do:
               end.
               else do:
                 if buf_chk-doc.pay-desk <> buf_inkas-pay-desk.pay-desk then next _chk-gds-pay.
               end.
             end.  */
        
            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input "cash-book-id"
              ,output mValue
              ,output mType) no-error.
              
            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input {&attr-item-matter-mark}
              ,output mValueVne
              ,output mTypeVne) no-error.       

            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input {&attr-type-method-calc}
              ,output mValueAvans
              ,output mTypeAvans) no-error.     
                                
            find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
            if not available ub.CashBook 
              then 
            do :
              find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
            end.
            if available ub.CashBook
              then 
            do :
              assign
                p-by-cash-desk    = ub.CashBook.FlagSepCash
                p-by-petrol-goods = ub.CashBook.FlagSepFull 
                .
            /*p-by-osnovanie = ub.CashBook.RuleOsn .
            p-by-pril = ub.CashBook.RulePril .*/
            end.
            find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
            if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
            if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
            
            if p-by-petrol-goods then 
            do: /*проверяем товар на топливность*/
              run check-petrol in this-procedure (
                input buf_chk-gds-pay.b-code ,
                output is-petrolium
                ).
            end.
            find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
              and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
              and ub.chk-gds-attr.attr-code = "cstype"
              no-lock no-error.
            mTypePay          = if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then 'Cash' else "".
            if mValueVne = "15" then 
            do:
              find first buf_temp-gdsVne no-lock where
                buf_temp-gdsVne.b-code = buf_chk-gds-pay.b-code
                and buf_temp-gdsVne.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                else '')
                and buf_temp-gdsVne.curr-code = buf_inkas-pay-desk.curr-code
                and (p-by-cash-desk = no or buf_temp-gdsVne.cash-desk = buf_inkas-pay-desk.pay-desk)
                and (p-by-petrol-goods = no or buf_temp-gdsVne.is-petrol = is-petrolium)
                and buf_temp-gdsVne.pay-type = mTypePay 
                no-error.
              if not available buf_temp-gdsVne then 
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                if available buf_bar-code then 
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then 
                  do:
                    if p-by-petrol-goods then 
                    do: /*проверяем товар на топливность*/
                      run check-petrol in this-procedure (
                        input buf_chk-gds-pay.b-code ,
                        output is-petrolium
                        ).
                    end.
                    create buf_temp-gdsVne.
                    assign
                      buf_temp-gdsVne.b-code    = buf_chk-gds-pay.b-code
                      buf_temp-gdsVne.gds-code  = buf_bar-code.gds-code
                      buf_temp-gdsVne.artic     = buf_goods.artic
                      buf_temp-gdsVne.prod-type = buf_goods.prod-type
                      buf_temp-gdsVne.prod-code = buf_goods.prod-code
                      buf_temp-gdsVne.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                                          else '')
                      buf_temp-gdsVne.curr-code = buf_inkas-pay-desk.curr-code
                      buf_temp-gdsVne.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                      buf_temp-gdsVne.pay-type  = mTypePay 
                      buf_temp-gdsVne.node-code = buf_bar-code.node-code
                      buf_temp-gdsVne.is-petrol = (if p-by-petrol-goods then is-petrolium else no) 
                      .
                    find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                      and chk-gds.line-num eq buf_chk-gds-pay.line-num
                      no-lock no-error.
                    buf_temp-gdsVne.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.                    
                  end.
                end.
              end. /*if not available buf_temp-gds then do:*/
              if available buf_temp-gdsVne then 
              do:
                assign
                  buf_temp-gdsVne.tot-r-b      = buf_temp-gdsVne.tot-r-b + buf_chk-gds-pay.tot-r-b
                  buf_temp-gdsVne.eff-doc-qnty = buf_temp-gdsVne.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                  buf_temp-gdsVne.tot-rubl     = buf_temp-gdsVne.tot-rubl +   (if v-curr-r-b = {&r-b-rubl}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                  buf_temp-gdsVne.tot-base     = buf_temp-gdsVne.tot-base +   (if v-curr-r-b = {&r-b-base}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                  .
                case buf_chk-gds-pay.curr-code:
                  when 0 then 
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  when v-base-code then 
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = {&r-b-base}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  otherwise 
                  do:
                    find first buf_chk-pay no-lock where
                      buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                      and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                    if available buf_chk-pay then 
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                        .
                    end.
                    else 
                    do:
                    /**/
                    end.
                  end. /*otherwise do:*/
                end case.
              end. /*if available buf_temp-gds then do:*/              

            end .
            else 
            do:
              if mValueAvans > "" then 
              do:
                              find first buf_temp-gdsAvans no-lock where
                buf_temp-gdsAvans.b-code = buf_chk-gds-pay.b-code
                and buf_temp-gdsAvans.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                else '')
                and buf_temp-gdsAvans.curr-code = buf_inkas-pay-desk.curr-code
                and (p-by-cash-desk = no or buf_temp-gdsAvans.cash-desk = buf_inkas-pay-desk.pay-desk)
                and (p-by-petrol-goods = no or buf_temp-gdsAvans.is-petrol = is-petrolium)
                and buf_temp-gdsAvans.pay-type = mTypePay 
                no-error.
              if not available buf_temp-gdsAvans then 
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                if available buf_bar-code then 
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then 
                  do:
                    if p-by-petrol-goods then 
                    do: /*проверяем товар на топливность*/
                      run check-petrol in this-procedure (
                        input buf_chk-gds-pay.b-code ,
                        output is-petrolium
                        ).
                    end.
                    create buf_temp-gdsAvans.
                    assign
                      buf_temp-gdsAvans.b-code    = buf_chk-gds-pay.b-code
                      buf_temp-gdsAvans.gds-code  = buf_bar-code.gds-code
                      buf_temp-gdsAvans.artic     = buf_goods.artic
                      buf_temp-gdsAvans.prod-type = buf_goods.prod-type
                      buf_temp-gdsAvans.prod-code = buf_goods.prod-code
                      buf_temp-gdsAvans.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                                          else '')
                      buf_temp-gdsAvans.curr-code = buf_inkas-pay-desk.curr-code
                      buf_temp-gdsAvans.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                      buf_temp-gdsAvans.pay-type  = mTypePay 
                      buf_temp-gdsAvans.node-code = buf_bar-code.node-code
                      buf_temp-gdsAvans.is-petrol = (if p-by-petrol-goods then is-petrolium else no) 
                      .
                    find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                      and chk-gds.line-num eq buf_chk-gds-pay.line-num
                      no-lock no-error.
                    buf_temp-gdsAvans.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.                    
                  end.
                end.
              end. /*if not available buf_temp-gds then do:*/
              if available buf_temp-gdsAvans then 
              do:
                assign
                  buf_temp-gdsAvans.tot-r-b      = buf_temp-gdsAvans.tot-r-b + buf_chk-gds-pay.tot-r-b
                  buf_temp-gdsAvans.eff-doc-qnty = buf_temp-gdsAvans.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                  buf_temp-gdsAvans.tot-rubl     = buf_temp-gdsAvans.tot-rubl +   (if v-curr-r-b = {&r-b-rubl}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                  buf_temp-gdsAvans.tot-base     = buf_temp-gdsAvans.tot-base +   (if v-curr-r-b = {&r-b-base}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                  .
                case buf_chk-gds-pay.curr-code:
                  when 0 then 
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  when v-base-code then 
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = {&r-b-base}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  otherwise 
                  do:
                    find first buf_chk-pay no-lock where
                      buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                      and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                    if available buf_chk-pay then 
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                        .
                    end.
                    else 
                    do:
                    /**/
                    end.
                  end. /*otherwise do:*/
                end case.
              end. /*if available buf_temp-gds then do:*/              
                
              end.
              else 
              do:
                find first buf_temp-gds no-lock where
                  buf_temp-gds.b-code = buf_chk-gds-pay.b-code
                  and buf_temp-gds.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                  then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                  else '')
                  and buf_temp-gds.curr-code = buf_inkas-pay-desk.curr-code
                  and (p-by-cash-desk = no or buf_temp-gds.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-gds.is-petrol = is-petrolium)
                  and buf_temp-gds.pay-type = mTypePay 
                  no-error.
                if not available buf_temp-gds then 
                do:
                  find first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                  if available buf_bar-code then 
                  do:
                    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                    if available buf_goods then 
                    do:
                      if p-by-petrol-goods then 
                      do: /*проверяем товар на топливность*/
                        run check-petrol in this-procedure (
                          input buf_chk-gds-pay.b-code ,
                          output is-petrolium
                          ).
                      end.
                      create buf_temp-gds.
                      assign
                        buf_temp-gds.b-code    = buf_chk-gds-pay.b-code
                        buf_temp-gds.gds-code  = buf_bar-code.gds-code
                        buf_temp-gds.artic     = buf_goods.artic
                        buf_temp-gds.prod-type = buf_goods.prod-type
                        buf_temp-gds.prod-code = buf_goods.prod-code
                        buf_temp-gds.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, {&delim-par}) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, {&delim-par})
                                          else '')
                        buf_temp-gds.curr-code = buf_inkas-pay-desk.curr-code
                        buf_temp-gds.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                        buf_temp-gds.pay-type  = mTypePay 
                        buf_temp-gds.node-code = buf_bar-code.node-code
                        buf_temp-gds.is-petrol = (if p-by-petrol-goods then is-petrolium else no) 
                        .
                      find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                        and chk-gds.line-num eq buf_chk-gds-pay.line-num
                        no-lock no-error.
                      buf_temp-gds.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.                    
                    end.
                  end.
                end. /*if not available buf_temp-gds then do:*/
                if available buf_temp-gds then 
                do:
                  assign
                    buf_temp-gds.tot-r-b      = buf_temp-gds.tot-r-b + buf_chk-gds-pay.tot-r-b
                    buf_temp-gds.eff-doc-qnty = buf_temp-gds.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                    buf_temp-gds.tot-rubl     = buf_temp-gds.tot-rubl +   (if v-curr-r-b = {&r-b-rubl}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                    buf_temp-gds.tot-base     = buf_temp-gds.tot-base +   (if v-curr-r-b = {&r-b-base}
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                    .
                  case buf_chk-gds-pay.curr-code:
                    when 0 then 
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                          .
                      end.
                    when v-base-code then 
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = {&r-b-base}
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                          .
                      end.
                    otherwise 
                    do:
                      find first buf_chk-pay no-lock where
                        buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                        and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                      if available buf_chk-pay then 
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = {&r-b-rubl}
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                          .
                      end.
                      else 
                      do:
                      /**/
                      end.
                    end. /*otherwise do:*/
                  end case.
                end. /*if available buf_temp-gds then do:*/
              end.
            end.
          end. /*for each buf_chk-gds-pay no-lock where*/
        end. /*if last-of (buf_inkas-pay-desk.curr-code:*/
      end. /*  for each buf_inkas-pay-desk no-lock where*/

      for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
        and buf_sale-doc.in-inkas = yes
        and buf_sale-doc.storage = {&table_trn-doc}
        ,
        first buf_trn-doc no-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code:
        for each buf_temp-gds no-lock
          where buf_temp-gds.doc-kind = buf_sale-doc.ext-doc-type ,
          first buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_sale-doc.doc-code
          and  buf_doc-line.artic = buf_temp-gds.artic
          and  buf_doc-line.prod-type = buf_temp-gds.prod-type
          and  buf_doc-line.prod-code = buf_temp-gds.prod-code,
          first buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_sale-doc.doc-code
          and  buf_gds-dtl.artic = buf_temp-gds.artic
          and  buf_gds-dtl.prod-type = buf_temp-gds.prod-type
          and  buf_gds-dtl.prod-code = buf_temp-gds.prod-code
          and  buf_gds-dtl.prt-code = buf_temp-gds.node-code
          :
          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input "cash-book-id"
            ,output mValue
            ,output mType) no-error.
            
          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input {&attr-item-matter-mark}
            ,output mValueVne
            ,output mTypeVne) no-error.    

          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input {&attr-type-method-calc}
            ,output mValueAvans
            ,output mTypeAvans) no-error.  
            
                          
          find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
          if not available ub.CashBook 
            then 
          do :
            find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
          end.
          if available ub.CashBook
            then 
          do :
            assign
              p-by-cash-desk    = ub.CashBook.FlagSepCash 
              p-by-petrol-goods = ub.CashBook.FlagSepFull 
              .
          /*  p-by-osnovanie = ub.CashBook.RuleOsn .
            p-by-pril = ub.CashBook.RulePril .*/
          end.
          find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
          if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
          if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
          
          find first buf_temp-tax where
            buf_temp-tax.curr-code = buf_temp-gds.curr-code
            and buf_temp-tax.vat-pc = buf_doc-line.vat-pc
            and buf_temp-tax.slt-pc = buf_doc-line.slt-pc
            and buf_temp-tax.cash-desk = buf_temp-gds.cash-desk
            and buf_temp-tax.is-petrol = buf_temp-gds.is-petrol
            and buf_temp-tax.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
            and buf_temp-tax.is-expense_cash = (buf_temp-gds.tot-doc < 0 and buf_temp-gds.pay-type eq "cash")
            and buf_temp-tax.pay-type = buf_temp-gds.pay-type
            and buf_temp-tax.num-expense_cash = 0
              
            /*              and (p-by-cash-desk = no or buf_temp-tax.cash-desk = buf_temp-gds.cash-desk)   */
            /*              and (p-by-petrol-goods = no or buf_temp-tax.is-petrol = buf_temp-gds.is-petrol)*/
            no-error.
          if not available buf_temp-tax then 
          do:
            create buf_temp-tax.
            assign
              buf_temp-tax.curr-code        = buf_temp-gds.curr-code
              buf_temp-tax.vat-pc           = buf_doc-line.vat-pc
              buf_temp-tax.slt-pc           = buf_doc-line.slt-pc
              buf_temp-tax.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gds.cash-desk
                                    else 0)
              buf_temp-tax.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gds.is-petrol
                                    else no)
              buf_temp-tax.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
              buf_temp-tax.is-expense_cash  = (buf_temp-gds.tot-doc < 0 and buf_temp-gds.pay-type eq "cash")
              buf_temp-tax.num-expense_cash = 0
              buf_temp-tax.pay-type         = buf_temp-gds.pay-type
              buf_temp-tax.with-vat         = buf_temp-gds.with-vat
              .
          end. /*if not available buf_temp-tax then do:*/
         /*получаем НДС*/
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl.  }

assign
  buf_temp-gds.vat-rubl = buf_temp-gds.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gds.vat-base = buf_temp-gds.eff-doc-qnty  * vat-base-buyer
  buf_temp-gds.vat-doc  = (if buf_temp-gds.curr-code = 0
                                 then buf_temp-gds.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gds.curr-code = v-base-code
                                       then buf_temp-gds.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gds.eff-doc-qnty * vat-rubl-buyer * buf_temp-gds.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-tax.sum-rubl = buf_temp-tax.sum-rubl + buf_temp-gds.tot-rubl
  buf_temp-tax.sum-base = buf_temp-tax.sum-base + buf_temp-gds.tot-base
  buf_temp-tax.sum-doc  = buf_temp-tax.sum-doc  + buf_temp-gds.tot-doc
  buf_temp-tax.vat-rubl = buf_temp-tax.vat-rubl + buf_temp-gds.vat-rubl
  buf_temp-tax.vat-base = buf_temp-tax.vat-base + buf_temp-gds.vat-base
  buf_temp-tax.vat-doc  = buf_temp-tax.vat-doc  + buf_temp-gds.vat-doc
        
  .

release buf_temp-tax.
end. /*      for each buf_temp-gds no-lock where*/

for each buf_temp-gdsVne no-lock
  where buf_temp-gdsVne.doc-kind = buf_sale-doc.ext-doc-type ,
  first buf_doc-line no-lock
  where buf_doc-line.doc-code = buf_sale-doc.doc-code
  and  buf_doc-line.artic = buf_temp-gdsVne.artic
  and  buf_doc-line.prod-type = buf_temp-gdsVne.prod-type
  and  buf_doc-line.prod-code = buf_temp-gdsVne.prod-code,
  first buf_gds-dtl no-lock where
  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
  and  buf_gds-dtl.artic = buf_temp-gdsVne.artic
  and  buf_gds-dtl.prod-type = buf_temp-gdsVne.prod-type
  and  buf_gds-dtl.prod-code = buf_temp-gdsVne.prod-code
  and  buf_gds-dtl.prt-code = buf_temp-gdsVne.node-code
  :
  run gds-attr-value in this-procedure (
    input buf_temp-gdsVne.gds-code
    ,input "cash-book-id"
    ,output mValue
    ,output mType) no-error.
            
  find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
  if not available ub.CashBook 
    then 
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then 
  do :
    assign
      p-by-cash-desk    = ub.CashBook.FlagSepCash 
      p-by-petrol-goods = ub.CashBook.FlagSepFull 
      .
  /*  p-by-osnovanie = ub.CashBook.RuleOsn .
    p-by-pril = ub.CashBook.RulePril .*/
  end.
  find first buf_temp-taxVne where
    buf_temp-taxVne.curr-code = buf_temp-gdsVne.curr-code
    and buf_temp-taxVne.vat-pc = buf_doc-line.vat-pc
    and buf_temp-taxVne.slt-pc = buf_doc-line.slt-pc
    and buf_temp-taxVne.cash-desk = buf_temp-gdsVne.cash-desk
    and buf_temp-taxVne.is-petrol = buf_temp-gdsVne.is-petrol
    and buf_temp-taxVne.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
    and buf_temp-taxVne.is-expense_cash = (buf_temp-gdsVne.tot-doc < 0 and buf_temp-gdsVne.pay-type eq "cash")
    and buf_temp-taxVne.pay-type = buf_temp-gdsVne.pay-type
    and buf_temp-taxVne.num-expense_cash = 0
    no-error.
  if not available buf_temp-taxVne then 
  do:
    create buf_temp-taxVne.
    assign
      buf_temp-taxVne.curr-code        = buf_temp-gdsVne.curr-code
      buf_temp-taxVne.vat-pc           = buf_doc-line.vat-pc
      buf_temp-taxVne.slt-pc           = buf_doc-line.slt-pc
      buf_temp-taxVne.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gdsVne.cash-desk
                                    else 0)
      buf_temp-taxVne.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gdsVne.is-petrol
                                    else no)
      buf_temp-taxVne.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
      buf_temp-taxVne.is-expense_cash  = (buf_temp-gdsVne.tot-doc < 0 and buf_temp-gdsVne.pay-type eq "cash")
      buf_temp-taxVne.num-expense_cash = 0
      buf_temp-taxVne.pay-type         = buf_temp-gdsVne.pay-type
      buf_temp-taxVne.with-vat         = buf_temp-gdsVne.with-vat
      .
  end. /*if not available buf_temp-tax then do:*/
         /*получаем НДС*/
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl.  }

assign
  buf_temp-gdsVne.vat-rubl = buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gdsVne.vat-base = buf_temp-gdsVne.eff-doc-qnty  * vat-base-buyer
  buf_temp-gdsVne.vat-doc  = (if buf_temp-gdsVne.curr-code = 0
                                 then buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gdsVne.curr-code = v-base-code
                                       then buf_temp-gdsVne.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer * buf_temp-gdsVne.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-taxVne.sum-rubl = buf_temp-taxVne.sum-rubl + buf_temp-gdsVne.tot-rubl
  buf_temp-taxVne.sum-base = buf_temp-taxVne.sum-base + buf_temp-gdsVne.tot-base
  buf_temp-taxVne.sum-doc  = buf_temp-taxVne.sum-doc  + buf_temp-gdsVne.tot-doc
  buf_temp-taxVne.vat-rubl = buf_temp-taxVne.vat-rubl + buf_temp-gdsVne.vat-rubl
  buf_temp-taxVne.vat-base = buf_temp-taxVne.vat-base + buf_temp-gdsVne.vat-base
  buf_temp-taxVne.vat-doc  = buf_temp-taxVne.vat-doc  + buf_temp-gdsVne.vat-doc
        
  .

release buf_temp-taxVne.
end. /*      for each buf_temp-gdsVne no-lock where*/

for each buf_temp-gdsAvans no-lock
  where buf_temp-gdsAvans.doc-kind = buf_sale-doc.ext-doc-type ,
  first buf_doc-line no-lock
  where buf_doc-line.doc-code = buf_sale-doc.doc-code
  and  buf_doc-line.artic = buf_temp-gdsAvans.artic
  and  buf_doc-line.prod-type = buf_temp-gdsAvans.prod-type
  and  buf_doc-line.prod-code = buf_temp-gdsAvans.prod-code,
  first buf_gds-dtl no-lock where
  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
  and  buf_gds-dtl.artic = buf_temp-gdsAvans.artic
  and  buf_gds-dtl.prod-type = buf_temp-gdsAvans.prod-type
  and  buf_gds-dtl.prod-code = buf_temp-gdsAvans.prod-code
  and  buf_gds-dtl.prt-code = buf_temp-gdsAvans.node-code
  :
  run gds-attr-value in this-procedure (
    input buf_temp-gdsAvans.gds-code
    ,input "cash-book-id"
    ,output mValue
    ,output mType) no-error.
            
  find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
  if not available ub.CashBook 
    then 
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then 
  do :
    assign
      p-by-cash-desk    = ub.CashBook.FlagSepCash 
      p-by-petrol-goods = ub.CashBook.FlagSepFull 
      .
  /*  p-by-osnovanie = ub.CashBook.RuleOsn .
    p-by-pril = ub.CashBook.RulePril .*/
  end.
  find first buf_temp-taxAvans where
    buf_temp-taxAvans.curr-code = buf_temp-gdsAvans.curr-code
    and buf_temp-taxAvans.vat-pc = buf_doc-line.vat-pc
    and buf_temp-taxAvans.slt-pc = buf_doc-line.slt-pc
    and buf_temp-taxAvans.cash-desk = buf_temp-gdsAvans.cash-desk
    and buf_temp-taxAvans.is-petrol = buf_temp-gdsAvans.is-petrol
    and buf_temp-taxAvans.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
    and buf_temp-taxAvans.is-expense_cash = (buf_temp-gdsAvans.tot-doc < 0 and buf_temp-gdsAvans.pay-type eq "cash")
    and buf_temp-taxAvans.pay-type = buf_temp-gdsAvans.pay-type
    and buf_temp-taxAvans.num-expense_cash = 0
    no-error.
  if not available buf_temp-taxAvans then 
  do:
    create buf_temp-taxAvans.
    assign
      buf_temp-taxAvans.curr-code        = buf_temp-gdsAvans.curr-code
      buf_temp-taxAvans.vat-pc           = buf_doc-line.vat-pc
      buf_temp-taxAvans.slt-pc           = buf_doc-line.slt-pc
      buf_temp-taxAvans.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gdsAvans.cash-desk
                                    else 0)
      buf_temp-taxAvans.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gdsAvans.is-petrol
                                    else no)
      buf_temp-taxAvans.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
      buf_temp-taxAvans.is-expense_cash  = (buf_temp-gdsAvans.tot-doc < 0 and buf_temp-gdsAvans.pay-type eq "cash")
      buf_temp-taxAvans.num-expense_cash = 0
      buf_temp-taxAvans.pay-type         = buf_temp-gdsAvans.pay-type
      buf_temp-taxAvans.with-vat         = buf_temp-gdsAvans.with-vat
      .
  end. /*if not available buf_temp-tax then do:*/
         /*получаем НДС*/
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl.  }

assign
  buf_temp-gdsAvans.vat-rubl = buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gdsAvans.vat-base = buf_temp-gdsAvans.eff-doc-qnty  * vat-base-buyer
  buf_temp-gdsAvans.vat-doc  = (if buf_temp-gdsAvans.curr-code = 0
                                 then buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gdsAvans.curr-code = v-base-code
                                       then buf_temp-gdsAvans.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer * buf_temp-gdsAvans.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-taxAvans.sum-rubl = buf_temp-taxAvans.sum-rubl + buf_temp-gdsAvans.tot-rubl
  buf_temp-taxAvans.sum-base = buf_temp-taxAvans.sum-base + buf_temp-gdsAvans.tot-base
  buf_temp-taxAvans.sum-doc  = buf_temp-taxAvans.sum-doc  + buf_temp-gdsAvans.tot-doc
  buf_temp-taxAvans.vat-rubl = buf_temp-taxAvans.vat-rubl + buf_temp-gdsAvans.vat-rubl
  buf_temp-taxAvans.vat-base = buf_temp-taxAvans.vat-base + buf_temp-gdsAvans.vat-base
  buf_temp-taxAvans.vat-doc  = buf_temp-taxAvans.vat-doc  + buf_temp-gdsAvans.vat-doc
        
  .

release buf_temp-taxAvans.
end. /*      for each buf_temp-gdsAvans no-lock where*/

end. /*    for each buf_sale-doc no-lock where*/
assign
  v-real-obj-type = buf_trn-doc.cli-type
  v-real-obj-code = buf_trn-doc.cli-code
  . 
empty temp-table temp-gds.
empty temp-table temp-gdsVne.
empty temp-table temp-gdsAvans.
end. /*   for each buf_inkas no-lock where*/

define variable Fact-order as decimal no-undo.
define buffer tt-cashBookOst0           for tt-cashBookOst.
define buffer buf_new_temp-fin-sum      for temp-fin-sum.
define buffer tt-cashBookOst0Vne        for tt-cashBookOstVne.
define buffer buf_new_temp-fin-sumVne   for temp-fin-sumVne.
define buffer tt-cashBookOst0Avans      for tt-cashBookOstAvans.
define buffer buf_new_temp-fin-sumAvans for temp-fin-sumAvans.
define variable mNumDoc as integer no-undo.

/* Не внереализационный доход */
find first tt-cashBookOst0 where tt-cashBookOst0.cashbookid eq 0
  no-error.
if not available tt-cashBookOst
  then 
do:
  create tt-cashBookOst0.
  tt-cashBookOst0.cashbookid =  0.
  run fostatok in this-procedure (
    input   v-host-code
    ,input   buf_shift-obj.obj-code
    ,input   buf_shift-obj.obj-type
    ,input   yes
    ,input   buf_shift-obj.close-date - 1
    ,input   date('')
    ,input   buf_shift-obj.shift-num
    ,input   buf_shift-obj.shift-num
    ,input   yes /*xTog-obj*/
    ,input   0 /*p-curr-code*/
    ,input   0 
    ,output  tt-cashBookOst0.ost
    ,output  Fact-order)
    no-error .
end.
find first buf_temp-fin-sum-Pko where buf_temp-fin-sum-Pko.num-expense_cash eq 0
  and buf_temp-fin-sum-Pko.is-expense_cash eq no
  and buf_temp-fin-sum-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sum-Pko
  then 
  tt-cashBookOst0.ost = tt-cashBookOst0.ost + buf_temp-fin-sum-Pko.tot-sum.
for each buf_temp-fin-sum where  buf_temp-fin-sum.num-expense_cash eq 0
  and  buf_temp-fin-sum.is-expense_cash  eq yes
  and  buf_temp-fin-sum.cashbookid  ne 0
  :
          
  find first tt-cashBookOst where tt-cashBookOst.cashbookid eq buf_temp-fin-sum.cashbookid
    no-error.
  if not available tt-cashBookOst
    then 
  do:
    create tt-cashBookOst.
    tt-cashBookOst.cashbookid =  buf_temp-fin-sum.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   buf_temp-fin-sum.cashbookid 
      ,output  tt-cashBookOst.ost
      ,output  Fact-order)
      no-error .
    find first buf_temp-fin-sum-Pko where buf_temp-fin-sum-Pko.num-expense_cash eq 0
      and buf_temp-fin-sum-Pko.is-expense_cash eq (not buf_temp-fin-sum.is-expense_cash)
      and buf_temp-fin-sum-Pko.cash-desk       eq buf_temp-fin-sum.cash-desk
      and buf_temp-fin-sum-Pko.curr-code       eq buf_temp-fin-sum.curr-code
      and buf_temp-fin-sum-Pko.cashbookid      eq buf_temp-fin-sum.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sum-Pko
      then 
      tt-cashBookOst.ost = tt-cashBookOst.ost + buf_temp-fin-sum-Pko.tot-sum.
                                              
  end.
  msum = tt-cashBookOst.ost + buf_temp-fin-sum.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный 
  if msum < 0
    then 
  do:
    tt-cashBookOst.ost = 0.
             
             
    if tt-cashBookOst0.ost + msum > 0
      then 
    do:
      create buf_new_temp-fin-sum.
      buffer-copy buf_temp-fin-sum except cashbookid to  buf_new_temp-fin-sum
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sum.cashbookid       = 0
        buf_new_temp-fin-sum.contr-kb         = buf_temp-fin-sum.cashbookid
        buf_new_temp-fin-sum.num-expense_cash = mNumDoc
        buf_new_temp-fin-sum.tot-sum          = msum
        buf_new_temp-fin-sum.tot-base         = msum
        buf_new_temp-fin-sum.tot-rubl         = msum
        buf_new_temp-fin-sum.pay-type         = "trans"
                   
        tt-cashBookOst0.ost                   = tt-cashBookOst0.ost + msum.
      .
                
      create buf_temp-tax.
      assign
        buf_temp-tax.curr-code        = buf_new_temp-fin-sum.curr-code
        buf_temp-tax.cash-desk        = buf_new_temp-fin-sum.cash-desk
        buf_temp-tax.is-petrol        = buf_new_temp-fin-sum.is-petrol
        buf_temp-tax.cashbookId       = buf_new_temp-fin-sum.cashbookid
        buf_temp-tax.is-expense_cash  = buf_new_temp-fin-sum.is-expense_cash
        buf_temp-tax.num-expense_cash = buf_new_temp-fin-sum.num-expense_cash
        buf_temp-tax.pay-type         = buf_new_temp-fin-sum.pay-type
        buf_temp-tax.sum-rubl         = msum
        buf_temp-tax.sum-base         = msum
        buf_temp-tax.sum-doc          = msum
                
        .
                
      create buf_new_temp-fin-sum.
      buffer-copy buf_temp-fin-sum to  buf_new_temp-fin-sum
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sum.tot-sum          = msum
        buf_new_temp-fin-sum.num-expense_cash = mNumDoc
        buf_new_temp-fin-sum.tot-base         = msum
        buf_new_temp-fin-sum.tot-rubl         = msum
        buf_new_temp-fin-sum.is-expense_cash  = no
        buf_new_temp-fin-sum.contr-kb         = 0
        buf_new_temp-fin-sum.pay-type         = "trans"
                   
        .
      create buf_temp-tax.
      assign
        buf_temp-tax.curr-code        = buf_new_temp-fin-sum.curr-code
        buf_temp-tax.cash-desk        = buf_new_temp-fin-sum.cash-desk
        buf_temp-tax.is-petrol        = buf_new_temp-fin-sum.is-petrol
        buf_temp-tax.cashbookId       = buf_new_temp-fin-sum.cashbookid
        buf_temp-tax.is-expense_cash  = buf_new_temp-fin-sum.is-expense_cash
        buf_temp-tax.num-expense_cash = buf_new_temp-fin-sum.num-expense_cash
        buf_temp-tax.pay-type         = buf_new_temp-fin-sum.pay-type
        buf_temp-tax.sum-rubl         = msum
        buf_temp-tax.sum-base         = msum
        buf_temp-tax.sum-doc          = msum
        .
                
    end.
    else 
    do:
             &scop fin-doc-type-code (if buf_temp-fin-sum.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
                 &scop my-message substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств." ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sum.cashbookid ~
                                  , abs(buf_temp-fin-sum.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
      {&DISPLAY-MESSAGE}.
             delete  buf_temp-fin-sum.
                
                
    end.
  end.
  else
    tt-cashBookOst.ost = msum. 
end.

/* Внереализационный доход */
find first tt-cashBookOst0Vne where tt-cashBookOst0Vne.cashbookid eq 0
  no-error.
if not available tt-cashBookOstVne
  then 
do:
  find first temp-fin-sumVne no-error .
  if available (temp-fin-sumVne) then 
  do:
    create tt-cashBookOst0Vne.
    tt-cashBookOst0Vne.cashbookid =  0.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   0 
      ,output  tt-cashBookOst0Vne.ost
      ,output  Fact-order)
      no-error .
  end.
end.

find first buf_temp-fin-sumVne-Pko where buf_temp-fin-sumVne-Pko.num-expense_cash eq 0
  and buf_temp-fin-sumVne-Pko.is-expense_cash eq no
  and buf_temp-fin-sumVne-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sumVne-Pko
  then 
  tt-cashBookOst0Vne.ost = tt-cashBookOst0Vne.ost + buf_temp-fin-sumVne-Pko.tot-sum.
for each buf_temp-fin-sumVne where  buf_temp-fin-sumVne.num-expense_cash eq 0
  and  buf_temp-fin-sumVne.is-expense_cash  eq yes
  and  buf_temp-fin-sumVne.cashbookid  ne 0
  :
          
  find first tt-cashBookOstVne where tt-cashBookOstVne.cashbookid eq buf_temp-fin-sumVne.cashbookid
    no-error.
  if not available tt-cashBookOstVne
    then 
  do:
    create tt-cashBookOstVne.
    tt-cashBookOstVne.cashbookid =  buf_temp-fin-sumVne.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   buf_temp-fin-sumVne.cashbookid 
      ,output  tt-cashBookOstVne.ost
      ,output  Fact-order)
      no-error .    
    find first buf_temp-fin-sumVne-Pko where buf_temp-fin-sumVne-Pko.num-expense_cash eq 0
      and buf_temp-fin-sumVne-Pko.is-expense_cash eq (not buf_temp-fin-sumVne.is-expense_cash)
      and buf_temp-fin-sumVne-Pko.cash-desk       eq buf_temp-fin-sumVne.cash-desk
      and buf_temp-fin-sumVne-Pko.curr-code       eq buf_temp-fin-sumVne.curr-code
      and buf_temp-fin-sumVne-Pko.cashbookid      eq buf_temp-fin-sumVne.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sumVne-Pko
      then 
      tt-cashBookOstVne.ost = tt-cashBookOstVne.ost + buf_temp-fin-sumVne-Pko.tot-sum.
                                              
  end.

  msum = tt-cashBookOstVne.ost + buf_temp-fin-sumVne.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный 
  if msum < 0
    then 
  do:
    tt-cashBookOstVne.ost = 0.
             
             
    if tt-cashBookOst0Vne.ost + msum > 0
      then 
    do:
      create buf_new_temp-fin-sumVne.
      buffer-copy buf_temp-fin-sumVne except cashbookid to  buf_new_temp-fin-sumVne
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sumVne.cashbookid       = 0
        buf_new_temp-fin-sumVne.contr-kb         = buf_temp-fin-sumVne.cashbookid
        buf_new_temp-fin-sumVne.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumVne.tot-sum          = msum
        buf_new_temp-fin-sumVne.tot-base         = msum
        buf_new_temp-fin-sumVne.tot-rubl         = msum
        buf_new_temp-fin-sumVne.pay-type         = "trans"
                   
        tt-cashBookOst0Vne.ost                   = tt-cashBookOst0Vne.ost + msum.
      .
                
      create buf_temp-taxVne.
      assign
        buf_temp-taxVne.curr-code        = buf_new_temp-fin-sumVne.curr-code
        buf_temp-taxVne.cash-desk        = buf_new_temp-fin-sumVne.cash-desk
        buf_temp-taxVne.is-petrol        = buf_new_temp-fin-sumVne.is-petrol
        buf_temp-taxVne.cashbookId       = buf_new_temp-fin-sumVne.cashbookid
        buf_temp-taxVne.is-expense_cash  = buf_new_temp-fin-sumVne.is-expense_cash
        buf_temp-taxVne.num-expense_cash = buf_new_temp-fin-sumVne.num-expense_cash
        buf_temp-taxVne.pay-type         = buf_new_temp-fin-sumVne.pay-type
        buf_temp-taxVne.sum-rubl         = msum
        buf_temp-taxVne.sum-base         = msum
        buf_temp-taxVne.sum-doc          = msum
                
        .
        
      create buf_new_temp-fin-sumVne.
      buffer-copy buf_temp-fin-sumVne to  buf_new_temp-fin-sumVne
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sumVne.tot-sum          = msum
        buf_new_temp-fin-sumVne.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumVne.tot-base         = msum
        buf_new_temp-fin-sumVne.tot-rubl         = msum
        buf_new_temp-fin-sumVne.is-expense_cash  = no
        buf_new_temp-fin-sumVne.contr-kb         = 0
        buf_new_temp-fin-sumVne.pay-type         = "trans"
                   
        .
      create buf_temp-taxVne.
      assign
        buf_temp-taxVne.curr-code        = buf_new_temp-fin-sumVne.curr-code
        buf_temp-taxVne.cash-desk        = buf_new_temp-fin-sumVne.cash-desk
        buf_temp-taxVne.is-petrol        = buf_new_temp-fin-sumVne.is-petrol
        buf_temp-taxVne.cashbookId       = buf_new_temp-fin-sumVne.cashbookid
        buf_temp-taxVne.is-expense_cash  = buf_new_temp-fin-sumVne.is-expense_cash
        buf_temp-taxVne.num-expense_cash = buf_new_temp-fin-sumVne.num-expense_cash
        buf_temp-taxVne.pay-type         = buf_new_temp-fin-sumVne.pay-type
        buf_temp-taxVne.sum-rubl         = msum
        buf_temp-taxVne.sum-base         = msum
        buf_temp-taxVne.sum-doc          = msum
        buf_temp-taxVne.vat-pc           = -1
        .   
    end.
    else 
    do:
             &scop fin-doc-type-code (if buf_temp-fin-sumVne.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
                 &scop my-message substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств." ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sumVne.cashbookid ~
                                  , abs(buf_temp-fin-sumVne.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
      {&DISPLAY-MESSAGE}.
             delete  buf_temp-fin-sumVne.
                
                
    end.
  end.
  else
    tt-cashBookOstVne.ost = msum. 
end.

/* Авансы */
find first tt-cashBookOst0Avans where tt-cashBookOst0Avans.cashbookid eq 0
  no-error.
if not available tt-cashBookOstAvans
  then 
do:
  find first temp-fin-sumAvans no-error .
  if available (temp-fin-sumAvans) then 
  do:
    create tt-cashBookOst0Avans.
    tt-cashBookOst0Avans.cashbookid =  0.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   0 
      ,output  tt-cashBookOst0Avans.ost
      ,output  Fact-order)
      no-error .
  end.
end.
find first buf_temp-fin-sumAvans-Pko where buf_temp-fin-sumAvans-Pko.num-expense_cash eq 0
  and buf_temp-fin-sumAvans-Pko.is-expense_cash eq no
  and buf_temp-fin-sumAvans-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sumAvans-Pko
  then 
  tt-cashBookOst0Avans.ost = tt-cashBookOst0Avans.ost + buf_temp-fin-sumAvans-Pko.tot-sum.
for each buf_temp-fin-sumAvans where  buf_temp-fin-sumAvans.num-expense_cash eq 0
  and  buf_temp-fin-sumAvans.is-expense_cash  eq yes
  and  buf_temp-fin-sumAvans.cashbookid  ne 0
  :
          
  find first tt-cashBookOstAvans where tt-cashBookOstAvans.cashbookid eq buf_temp-fin-sumAvans.cashbookid
    no-error.
  if not available tt-cashBookOstAvans
    then 
  do:
    create tt-cashBookOstAvans.
    tt-cashBookOstAvans.cashbookid =  buf_temp-fin-sumAvans.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   buf_temp-fin-sumAvans.cashbookid 
      ,output  tt-cashBookOstAvans.ost
      ,output  Fact-order)
      no-error .
                      
    find first buf_temp-fin-sumAvans-Pko where buf_temp-fin-sumAvans-Pko.num-expense_cash eq 0
      and buf_temp-fin-sumAvans-Pko.is-expense_cash eq (not buf_temp-fin-sumAvans.is-expense_cash)
      and buf_temp-fin-sumAvans-Pko.cash-desk       eq buf_temp-fin-sumAvans.cash-desk
      and buf_temp-fin-sumAvans-Pko.curr-code       eq buf_temp-fin-sumAvans.curr-code
      and buf_temp-fin-sumAvans-Pko.cashbookid      eq buf_temp-fin-sumAvans.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sumAvans-Pko
      then 
      tt-cashBookOstAvans.ost = tt-cashBookOstAvans.ost + buf_temp-fin-sumAvans-Pko.tot-sum.
                                              
  end.

  msum = tt-cashBookOstAvans.ost + buf_temp-fin-sumAvans.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный 
  if msum < 0
    then 
  do:
    tt-cashBookOstAvans.ost = 0.
             
             
    if tt-cashBookOst0Avans.ost + msum > 0
      then 
    do:
      create buf_new_temp-fin-sumAvans.
      buffer-copy buf_temp-fin-sumAvans except cashbookid to  buf_new_temp-fin-sumAvans
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sumAvans.cashbookid       = 0
        buf_new_temp-fin-sumAvans.contr-kb         = buf_temp-fin-sumAvans.cashbookid
        buf_new_temp-fin-sumAvans.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumAvans.tot-sum          = msum
        buf_new_temp-fin-sumAvans.tot-base         = msum
        buf_new_temp-fin-sumAvans.tot-rubl         = msum
        buf_new_temp-fin-sumAvans.pay-type         = "trans"
                   
        tt-cashBookOst0Avans.ost                   = tt-cashBookOst0Avans.ost + msum.
      .

      create buf_temp-taxAvans.
      assign
        buf_temp-taxAvans.curr-code        = buf_new_temp-fin-sumAvans.curr-code
        buf_temp-taxAvans.cash-desk        = buf_new_temp-fin-sumAvans.cash-desk
        buf_temp-taxAvans.is-petrol        = buf_new_temp-fin-sumAvans.is-petrol
        buf_temp-taxAvans.cashbookId       = buf_new_temp-fin-sumAvans.cashbookid
        buf_temp-taxAvans.is-expense_cash  = buf_new_temp-fin-sumAvans.is-expense_cash
        buf_temp-taxAvans.num-expense_cash = buf_new_temp-fin-sumAvans.num-expense_cash
        buf_temp-taxAvans.pay-type         = buf_new_temp-fin-sumAvans.pay-type
        buf_temp-taxAvans.sum-rubl         = msum
        buf_temp-taxAvans.sum-base         = msum
        buf_temp-taxAvans.sum-doc          = msum
        
                
        .
                
      create buf_new_temp-fin-sumAvans.
      buffer-copy buf_temp-fin-sumAvans to  buf_new_temp-fin-sumAvans
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sumAvans.tot-sum          = msum
        buf_new_temp-fin-sumAvans.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumAvans.tot-base         = msum
        buf_new_temp-fin-sumAvans.tot-rubl         = msum
        buf_new_temp-fin-sumAvans.is-expense_cash  = no
        buf_new_temp-fin-sumAvans.contr-kb         = 0
        buf_new_temp-fin-sumAvans.pay-type         = "trans"
                   
        .
      create buf_temp-taxAvans.
      assign
        buf_temp-taxAvans.curr-code        = buf_new_temp-fin-sumAvans.curr-code
        buf_temp-taxAvans.cash-desk        = buf_new_temp-fin-sumAvans.cash-desk
        buf_temp-taxAvans.is-petrol        = buf_new_temp-fin-sumAvans.is-petrol
        buf_temp-taxAvans.cashbookId       = buf_new_temp-fin-sumAvans.cashbookid
        buf_temp-taxAvans.is-expense_cash  = buf_new_temp-fin-sumAvans.is-expense_cash
        buf_temp-taxAvans.num-expense_cash = buf_new_temp-fin-sumAvans.num-expense_cash
        buf_temp-taxAvans.pay-type         = buf_new_temp-fin-sumAvans.pay-type
        buf_temp-taxAvans.sum-rubl         = msum
        buf_temp-taxAvans.sum-base         = msum
        buf_temp-taxAvans.sum-doc          = msum
        .
                
    end.
    else 
    do:
             &scop fin-doc-type-code (if buf_temp-fin-sumAvans.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
                 &scop my-message substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств." ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sumAvans.cashbookid ~
                                  , abs(buf_temp-fin-sumAvans.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
      {&DISPLAY-MESSAGE}.
             delete  buf_temp-fin-sumAvans.
                
                
    end.
  end.
  else
    tt-cashBookOstAvans.ost = msum. 
end.



for each temp-z-number
  break
  by temp-z-number.cash-desk
  :
  if first-of( temp-z-number.cash-desk) then 
  do:
    find first temp-z-number-list
      where temp-z-number-list.cash-desk = temp-z-number.cash-desk no-error.
    if not available temp-z-number-list then 
    do:
      create temp-z-number-list.
      assign
        temp-z-number-list.cash-desk = temp-z-number.cash-desk
        .
    end.
  end.
  assign
    v-naznach-plat                  = v-naznach-plat + (if v-naznach-plat = '' then '' else {&comma-char}) + string(temp-z-number.z-number)
    temp-z-number-list.naznach-plat = temp-z-number-list.naznach-plat + (if temp-z-number-list.naznach-plat = '' then '' else {&comma-char}) + string(temp-z-number.z-number)
    .
end.

v-naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", v-naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
for each temp-z-number-list:
  assign
    temp-z-number-list.naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", temp-z-number-list.naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
end.
v-naznach-plat2 = v-naznach-plat . 
   
define variable v-real-obj-type-save as character no-undo.
define variable v-real-obj-code-save as integer   no-undo.
define variable mosnacct             as character no-undo.
define variable mdopacct             as character no-undo.
define variable mpayer-name          as character no-undo.
define variable mreceiver-name       as character no-undo.

/*теперь создадим fin-doc*/
_temp-fin-sum:
for each buf_temp-fin-sum no-lock
  by buf_temp-fin-sum.tot-sum descending  /* EXPSD-7148 добавлена обратная сортировка по сумме, чтобы сначала создавались док-ты по приходу */
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :

  empty temp-table tt0-fin-doc-tax.
  empty temp-table tt0-fin-doc-attr.
  empty temp-table tt-fin-doc.
  if buf_temp-fin-sum.tot-sum = 0  then 
  do:
    next _temp-fin-sum.
  end.
  v-naznach-plat = v-naznach-plat2 .
  find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.cashbookid no-error .
  if not available ub.CashBook 
    then 
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.

  assign
    mreceiver-name = ""
    mpayer-name    = ""
    .
  if     buf_temp-fin-sum.pay-type eq "cash"
    and buf_temp-fin-sum.tot-sum < 0
    then 
  do:
    assign
      v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "CountCash-type"  )
      v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "CountCash-code"  ))
      mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "rule-payer-rko"  )
      p-by-osnovanie       = ub.CashBook.RuleOsnRko
      mosnacct             = ub.CashBook.OsnAcct
      mdopacct             = ub.CashBook.CorrRko
      .
  end.
  else if     buf_temp-fin-sum.pay-type eq "trans"
      then 
    do:
      assign
        p-by-osnovanie       = "Перемещение денежных средств"
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "contr-type-transf"  )
        v-real-obj-code-save = int(mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "contr-code-transf"  ))
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "rule-osn-transf")
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "rule-payer-transf"  ) 
        when buf_temp-fin-sum.tot-sum < 0
        mpayer-name          = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "rule-payer-transf"  ) 
        when buf_temp-fin-sum.tot-sum > 0
        mosnacct             = ub.CashBook.OsnAcct   
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0, "Corr-transf")
         //mcredit              = if  buf_temp-fin-sum.tot-sum < 0 then mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0, "Corr-transf") else ub.CashBook.OsnAcct
        .
      if p-by-osnovanie       = ""
        then
        p-by-osnovanie       = "Перемещение денежных средств".
    end.
    else if buf_temp-fin-sum.tot-sum > 0
        then 
      do:
        assign
          p-by-osnovanie       = ub.CashBook.RuleOsnPko 
          v-real-obj-type-save = ub.CashBook.cli-type
          v-real-obj-code-save = ub.CashBook.cli-code
          mdopacct             = ub.CashBook.CorrPko
          mosnacct             = ub.CashBook.OsnAcct
          mpayer-name          = ub.CashBook.takenfrom
          .
        if mpayer-name eq "" or mpayer-name eq ?
          then 
        do:
          find first ub.clients no-lock where ub.clients.obj-type = ub.CashBook.cli-type
            and ub.clients.obj-code = ub.CashBook.cli-code
            no-error .
          if available ub.clients
            then 
            mpayer-name = ub.clients.obj-name .
        end.
      end.
      else
        assign
          p-by-osnovanie       = ub.CashBook.RuleOsnRko 
          v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "CountCash-type"  )
          v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "CountCash-code"  ))
          mosnacct             = ub.CashBook.OsnAcct
          mdopacct             = ub.CashBook.CorrRko
          mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0,  "rule-payer-rko"  )
          .
      
  define variable v-doc-rec as recid no-undo .
  if buf_temp-fin-sum.tot-sum > 0  then 
  do:
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
      ,input  v-real-obj-type-save  /*p-receiver-type*/ 
      ,input  v-real-obj-code-save /*p-receiever-code*/
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
      ,input ""
      ,INPUT-OUTPUT table tt-fin-doc
      ,INPUT-OUTPUT table ttc-fin-doc
      ,output table tt0-fin-doc-attr
      ,output v-limit-access ) no-error .
  end.
  else 
  do:
           
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
      ,input  v-real-obj-type-save  /*p-receiver-type*/
      ,input v-real-obj-code-save /*p-receiever-code*/
      ,input 0 /*p-receiver-code-schet*/
      ,input buf_temp-fin-sum.curr-code
      ,input 0 /*p-cor-acc*/
      ,input 0 /*p-cor-acc1*/
      ,input 0 /*p-an-uchet-code*/
      ,input 0 /*p-cel-nazn-code*/
      ,input buf_temp-fin-sum.cashbookid
      ,input ""
      ,INPUT-OUTPUT table tt-fin-doc
      ,INPUT-OUTPUT table ttc-fin-doc
      ,output table tt0-fin-doc-attr
      ,output v-limit-access ) no-error .
  end.
  if error-status:error then 
  do:
        &scop my-message substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
    {&display-message}.
    undo _main, return error.

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
    and buf_temp-tax.pay-type = buf_temp-fin-sum.pay-type
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
    if buf_temp-fin-sum.tot-sum > 0  then 
    do :
      assign
        tt0-fin-doc-tax.sum-line-doc      = buf_temp-tax.sum-doc
        tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-tax.vat-doc
        tt0-fin-doc-tax.sum-line-rubl     = buf_temp-tax.sum-rubl
        tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-tax.vat-rubl
        tt0-fin-doc-tax.sum-line-base     = buf_temp-tax.sum-base
        tt0-fin-doc-tax.sum-vat-line-base = buf_temp-tax.vat-base
        .
    end.
    else 
    do :
      assign
        tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-tax.sum-doc)
        tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-tax.vat-doc)
        tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-tax.sum-rubl)
        tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-tax.vat-rubl)
        tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-tax.sum-base)
        tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-tax.vat-base)
        .
    end.
    find first temp-autotank no-lock
      where temp-autotank.curr-code = buf_temp-tax.curr-code
      and temp-autotank.pay-desk = buf_temp-tax.cash-desk
      and temp-autotank.is-petrol = buf_temp-tax.is-petrol
      and temp-autotank.vat-pc    = buf_temp-tax.vat-pc
      and temp-autotank.slt-pc    = buf_temp-tax.slt-pc
      no-error.
    if available temp-autotank then 
    do:
      assign
        tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        .
    end.

    release tt0-fin-doc-tax.
  end.
  taxVne = "" .    
  run StrTax in this-procedure ( input-output tt-fin-doc.including) .
  /* округляем  */
  run RoundTax in this-procedure .

      
  if available ub.CashBook
      
    then 
  do :
    p-by-cash-desk = ub.CashBook.FlagSepCash .
    p-by-petrol-goods = ub.CashBook.FlagSepFull .
       
    p-by-pril = ub.CashBook.RulePril .
  end.

  if p-by-cash-desk then 
  do:
    find first temp-z-number-list no-lock
      where temp-z-number-list.cash-desk = buf_temp-fin-sum.cash-desk
      no-error.
  end.        
      

  if     trim(p-by-pril) = '0' 
    and buf_temp-fin-sum.pay-type ne "trans" 
    then 
    tt-fin-doc.enclosure = v-naznach-plat.
  case p-by-osnovanie:
    when '0' then 
      do :
        v-naznach-plat = 'Выручка от реализации'.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
      end.
    when '2'          then 
      do :
        v-naznach-plat = ''.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
      end.
    when '1'          then 
      do :
        if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
      end.
    otherwise 
    do:
      v-naznach-plat = p-by-osnovanie.
      if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
    end.        
  end case .  

  assign
    tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
    .
  assign
    tt-fin-doc.CashBookId = buf_temp-fin-sum.cashbookid
    tt-fin-doc.sum-doc    = abs(buf_temp-fin-sum.tot-sum)
    tt-fin-doc.sum-base   = abs(buf_temp-fin-sum.tot-base)
    tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sum.tot-rubl)
    tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sum.curr-code = 0 then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-sum )
    tt-fin-doc.exch-scale = 1
    tt-fin-doc.base-rate  = abs(if buf_temp-fin-sum.curr-code = v-base-code then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-base )
    tt-fin-doc.base-scale = 1
    .
  if buf_temp-fin-sum.tot-sum > 0  then 
  do:
    if p-by-petrol-goods then 
    do:
      assign
        tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sum.is-petrol then "нефтепродуктов" else "ТНП")
        tt-fin-doc.receiver-sign3 = v-cashier
        .
    end.
    else 
    do:
      assign
        tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
        tt-fin-doc.receiver-sign3 = v-cashier
        .
    end.
    assign
      tt-fin-doc.payer-name = mpayer-name 
      when mpayer-name ne "". 
  end.
  else 
  do:
    if p-by-petrol-goods then 
    do:
      assign
        /* tt-fin-doc.receiver-name   = "Выручка от реализации " + (if buf_temp-fin-sum.is-petrol then "нефтепродуктов" else "ТНП")*/ 
        tt-fin-doc.payer-sign3 = v-cashier
        .
    end.
    else 
    do:
      assign
        /*   tt-fin-doc.receiver-name   = "Выручка от реализации нефтепродуктов, ТНП"*/ 
          
            
        tt-fin-doc.payer-sign3 = v-cashier
        .
    end.
    assign
      tt-fin-doc.receiver-name = mreceiver-name 
      when mreceiver-name ne "".
  end.
      
      
  o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
      
      
      
  if available ub.CashBook
    then 
  do :
    tt-fin-doc.cor-acc-value  = mdopacct .
    tt-fin-doc.cor-acc1-value = mosnacct.
        
    if buf_temp-fin-sum.tot-sum > 0
      then 
    do: 
      /*tt-fin-doc.payer-type = ub.CashBook.cli-type .
      tt-fin-doc.payer-code = ub.CashBook.cli-code .*/
      tt-fin-doc.payer-name = mpayer-name .
    end.
        
    FIND ub.fin-code-cor-acc WHERE
      ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
      AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
      AND  ub.fin-code-cor-acc.status_ = integer({&current-status-int})
      NO-LOCK NO-error.
        
    if not available ub.fin-code-cor-acc
      then 
    do:
      assign
        tt-fin-doc.cor-acc-value = {&question-mark}
        .
    end.
    else 
    do:
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
      then 
    do:
      assign
        tt-fin-doc.cor-acc1-value = {&question-mark}
        .
    end.
    else 
    do:
      assign
        tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
        .
    end.
  end.
      
  if o-uchet = "0"
    then v-uchet = "cal" .
  else v-uchet = "smen" . 
      

  /*подкручиваем для утилиты */
  if buf_shift-obj.status_ = {&sht-closed} and v-uchet = "smen" then 
  do:
    assign
      tt-fin-doc.doc-date   = buf_shift-obj.close-date
      tt-fin-doc.shift-date = buf_shift-obj.shift-date
      tt-fin-doc.shift-num  = buf_shift-obj.shift-num
      tt-fin-doc.shift-name = buf_shift-obj.shift-name
      .
  end.
  if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
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
  if error-status:error then 
  do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
    {&display-message}.
    undo _main, return error.
  end.
  /*закрываем до факта*/
  find first buf_fin-doc share-lock where
    recid(buf_fin-doc) = v-doc-rec.
  assign
    buf_fin-doc.shift-flag = integer({&fin-flag-shift})
    .
  if buf_temp-fin-sum.contr-kb ne ?
    then 
  do:
    find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
      and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
      and fin-doc-attr.attr-code eq "contr-kb"
      exclusive-lock no-error.
    if not available fin-doc-attr
      then 
    do:
      create fin-doc-attr.
      assign
        fin-doc-attr.host-code    = buf_fin-doc.host-code
        fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
        fin-doc-attr.attr-code    = "contr-kb"
        .
    end.
    fin-doc-attr.attr-value = String(buf_temp-fin-sum.contr-kb).
  end.
      
  run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
  if error-status :error then 
  do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
    {&display-message}.
    undo _main, return error.
  END.
  if buf_fin-doc.status_ <> {&fin-fact} then 
  do:
    run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
    if error-status :error then 
    do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
      {&display-message}.
      undo _main, return error.
    END.
  end.
  if buf_fin-doc.status_ <> {&fin-fact} then 
  do:
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
    if error-status :error then 
    do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
      {&display-message}.
      undo _main, return error.
    END.
  end.
     &scop fin-doc-type-code (if buf_temp-fin-sum.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
     &scop my-message substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8" ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sum.cashbookid ~
                                  , abs(buf_temp-fin-sum.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
  {&DISPLAY-MESSAGE}.

   end. /*for each buf_temp-fin-sum no-lock*/

  /* Внереализационный доход */
  _temp-fin-sumVne:
  for each buf_temp-fin-sumVne no-lock
    by buf_temp-fin-sumVne.tot-sum descending  /* EXPSD-7148 добавлена обратная сортировка по сумме, чтобы сначала создавались док-ты по приходу */
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :

    empty temp-table tt0-fin-doc-tax.
    empty temp-table tt0-fin-doc-attr.
    empty temp-table tt-fin-doc.
    if buf_temp-fin-sumVne.tot-sum = 0  then 
    do:
      next _temp-fin-sumVne.
    end.
    v-naznach-plat = v-naznach-plat2 .
    find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sumVne.cashbookid no-error .
    if not available ub.CashBook 
      then 
    do :
      find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
    end.

    assign
      mreceiver-name = ""
      mpayer-name    = ""
      .
    if buf_temp-fin-sumVne.tot-sum > 0
      then
    do:
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "RuleOsnPkoVne"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "Vnecli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "Vnecli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "corrPkoVne"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "takenfromVne"  )
        .
      if mpayer-name eq "" or mpayer-name eq ?
        then
      do:
        find first ub.clients no-lock where ub.clients.obj-type = v-real-obj-type-save
          and ub.clients.obj-code = v-real-obj-code-save
          no-error .
        if available ub.clients
          then
          mpayer-name = ub.clients.obj-name .
      end.
    end.
    else
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "RuleOsnPkoVne"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "Vnecli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "Vnecli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "corrPkoVne"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, {&by_all}, 0,  "takenfromVne"  )
        .
    if buf_temp-fin-sumVne.tot-sum > 0  then 
    do:
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
        ,input  v-real-obj-type-save  /*p-receiver-type*/ 
        ,input  v-real-obj-code-save /*p-receiever-code*/
        ,input 0 /*p-payer-code-schet*/
        ,input {&cmp} /*p-receiver-type*/
        ,input v-host-code /*p-receiver-code*/
        ,input 0 /*p-receiver-code-schet*/
        ,input buf_temp-fin-sumVne.curr-code
        ,input 0 /*p-cor-acc*/
        ,input 0 /*p-cor-acc1*/
        ,input 0 /*p-an-uchet-code*/
        ,input 0 /*p-cel-nazn-code*/
        ,input buf_temp-fin-sumVne.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    else 
    do:
           
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
        ,input v-real-obj-type-save  /*p-receiver-type*/
        ,input v-real-obj-code-save /*p-receiever-code*/
        ,input 0 /*p-receiver-code-schet*/
        ,input buf_temp-fin-sumVne.curr-code
        ,input 0 /*p-cor-acc*/
        ,input 0 /*p-cor-acc1*/
        ,input 0 /*p-an-uchet-code*/
        ,input 0 /*p-cel-nazn-code*/
        ,input buf_temp-fin-sumVne.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    if error-status:error then 
    do:
        &scop my-message substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.

    end.
    find first tt-fin-doc.
    /*заполнение налогов*/
    for each buf_temp-taxVne no-lock
      where buf_temp-taxVne.curr-code        = buf_temp-fin-sumVne.curr-code
      and buf_temp-taxVne.cash-desk         = buf_temp-fin-sumVne.cash-desk
      and buf_temp-taxVne.is-petrol        = buf_temp-fin-sumVne.is-petrol
      and buf_temp-taxVne.cashbookId       = buf_temp-fin-sumVne.cashbookId
      and buf_temp-taxVne.is-expense_cash  = buf_temp-fin-sumVne.is-expense_cash
      and buf_temp-taxVne.num-expense_cash = buf_temp-fin-sumVne.num-expense_cash
      and buf_temp-taxVne.pay-type = buf_temp-fin-sumVne.pay-type
      :
      v-line-num = v-line-num + 1.
      create tt0-fin-doc-tax .
      assign
        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
        tt0-fin-doc-tax.line-num           = v-line-num
        tt0-fin-doc-tax.VAT-pc             = -1
        tt0-fin-doc-tax.slt-pc             = buf_temp-taxVne.slt-pc
        tt0-fin-doc-tax.sum-line-contr     = 0
        tt0-fin-doc-tax.sum-vat-line-contr = 0
        tt0-fin-doc-tax.with-vat           = no
        .
      if buf_temp-fin-sumVne.tot-sum > 0  then 
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = buf_temp-taxVne.sum-doc
          tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-taxVne.vat-doc
          tt0-fin-doc-tax.sum-line-rubl     = buf_temp-taxVne.sum-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-taxVne.vat-rubl
          tt0-fin-doc-tax.sum-line-base     = buf_temp-taxVne.sum-base
          tt0-fin-doc-tax.sum-vat-line-base = buf_temp-taxVne.vat-base
          .
      end.
      else 
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-taxVne.sum-doc)
          tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-taxVne.vat-doc)
          tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-taxVne.sum-rubl)
          tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-taxVne.vat-rubl)
          tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-taxVne.sum-base)
          tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-taxVne.vat-base)
          .
      end.
      find first temp-autotank no-lock
        where temp-autotank.curr-code = buf_temp-taxVne.curr-code
        and temp-autotank.pay-desk = buf_temp-taxVne.cash-desk
        and temp-autotank.is-petrol = buf_temp-taxVne.is-petrol
        and temp-autotank.vat-pc    = buf_temp-taxVne.vat-pc
        and temp-autotank.slt-pc    = buf_temp-taxVne.slt-pc
        no-error.
      if available temp-autotank then 
      do:
        assign
          tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          .
      end.

      release tt0-fin-doc-tax.
    end.
    taxVne = "Vne" .  
    run StrTax in this-procedure ( input-output tt-fin-doc.including) .
    /* округляем  */
    run RoundTax in this-procedure .

      
    if available ub.CashBook
      
      then 
    do :
      p-by-cash-desk = ub.CashBook.FlagSepCash .
      p-by-petrol-goods = ub.CashBook.FlagSepFull .
       
      p-by-pril = ub.CashBook.RulePril .
    end.

    if p-by-cash-desk then 
    do:
      find first temp-z-number-list no-lock
        where temp-z-number-list.cash-desk = buf_temp-fin-sumVne.cash-desk
        no-error.
    end.        
      

    if     trim(p-by-pril) = '0' 
      and buf_temp-fin-sumVne.pay-type ne "trans" 
      then 
      tt-fin-doc.enclosure = v-naznach-plat.
    case p-by-osnovanie:
      when '0' then 
        do :
          v-naznach-plat = 'Выручка от реализации'.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
        end.
      when '2'          then 
        do :
          v-naznach-plat = ''.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
        end.
      when '1'          then 
        do :
          if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
        end.
      otherwise 
      do:
        v-naznach-plat = p-by-osnovanie.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
      end.        
    end case .  

    assign
      tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
    assign
      tt-fin-doc.CashBookId = buf_temp-fin-sumVne.cashbookid
      tt-fin-doc.sum-doc    = abs(buf_temp-fin-sumVne.tot-sum)
      tt-fin-doc.sum-base   = abs(buf_temp-fin-sumVne.tot-base)
      tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sumVne.tot-rubl)
      tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sumVne.curr-code = 0 then 1 else buf_temp-fin-sumVne.tot-rubl / buf_temp-fin-sumVne.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate  = abs(if buf_temp-fin-sumVne.curr-code = v-base-code then 1 else buf_temp-fin-sumVne.tot-rubl / buf_temp-fin-sumVne.tot-base )
      tt-fin-doc.base-scale = 1
      .
    if buf_temp-fin-sumVne.tot-sum > 0  then 
    do:
      if p-by-petrol-goods then 
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sumVne.is-petrol then "нефтепродуктов" else "ТНП")
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      else 
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.payer-name = mpayer-name 
        when mpayer-name ne "". 
    end.
    else 
    do:
      if p-by-petrol-goods then 
      do:
        assign
          /* tt-fin-doc.receiver-name   = "Выручка от реализации " + (if buf_temp-fin-sum.is-petrol then "нефтепродуктов" else "ТНП")*/ 
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      else 
      do:
        assign
          /*   tt-fin-doc.receiver-name   = "Выручка от реализации нефтепродуктов, ТНП"*/ 
          
            
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.receiver-name = mreceiver-name 
        when mreceiver-name ne "".
    end.
      
      
    o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
      
      
      
    if available ub.CashBook
      then 
    do :
      tt-fin-doc.cor-acc-value  = mdopacct .
      tt-fin-doc.cor-acc1-value = mosnacct.
        
      if buf_temp-fin-sumVne.tot-sum > 0
        then 
      do: 
        /*tt-fin-doc.payer-type = ub.CashBook.cli-type .
        tt-fin-doc.payer-code = ub.CashBook.cli-code .*/
        tt-fin-doc.payer-name = mpayer-name .
      end.
        
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer({&current-status-int})
        NO-LOCK NO-error.
        
      if not available ub.fin-code-cor-acc
        then 
      do:
        assign
          tt-fin-doc.cor-acc-value = {&question-mark}
          .
      end.
      else 
      do:
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
        then 
      do:
        assign
          tt-fin-doc.cor-acc1-value = {&question-mark}
          .
      end.
      else 
      do:
        assign
          tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
      end.
    end.
      
    if o-uchet = "0"
      then v-uchet = "cal" .
    else v-uchet = "smen" . 
      

    /*подкручиваем для утилиты */
    if buf_shift-obj.status_ = {&sht-closed} and v-uchet = "smen" then 
    do:
      assign
        tt-fin-doc.doc-date   = buf_shift-obj.close-date
        tt-fin-doc.shift-date = buf_shift-obj.shift-date
        tt-fin-doc.shift-num  = buf_shift-obj.shift-num
        tt-fin-doc.shift-name = buf_shift-obj.shift-name
        .
    end.
    if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
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
    if error-status:error then 
    do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.
    end.
    /*закрываем до факта*/
    find first buf_fin-doc share-lock where
      recid(buf_fin-doc) = v-doc-rec.
    assign
      buf_fin-doc.shift-flag = integer({&fin-flag-shift})
      .
    if buf_temp-fin-sumVne.contr-kb ne ?
      then 
    do:
      find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
        and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
        and fin-doc-attr.attr-code eq "contr-kb"
        exclusive-lock no-error.
      if not available fin-doc-attr
        then 
      do:
        create fin-doc-attr.
        assign
          fin-doc-attr.host-code    = buf_fin-doc.host-code
          fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
          fin-doc-attr.attr-code    = "contr-kb"
          .
      end.
      fin-doc-attr.attr-value = String(buf_temp-fin-sumVne.contr-kb).
    end.
      
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
    if error-status :error then 
    do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.
    END.
    if buf_fin-doc.status_ <> {&fin-fact} then 
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
      if error-status :error then 
      do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
        {&display-message}.
        undo _main, return error.
      END.
    end.
    if buf_fin-doc.status_ <> {&fin-fact} then 
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
      if error-status :error then 
      do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
        {&display-message}.
        undo _main, return error.
      END.
    end.
     &scop fin-doc-type-code (if buf_temp-fin-sumVne.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
     &scop my-message substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8" ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sumVne.cashbookid ~
                                  , abs(buf_temp-fin-sumVne.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
    {&DISPLAY-MESSAGE}.

   end. /*for each buf_temp-fin-sumVne no-lock*/

  /* Аванс */
  _temp-fin-sumAvans:
  for each buf_temp-fin-sumAvans no-lock
    by buf_temp-fin-sumAvans.tot-sum descending  /* EXPSD-7148 добавлена обратная сортировка по сумме, чтобы сначала создавались док-ты по приходу */
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :

    empty temp-table tt0-fin-doc-tax.
    empty temp-table tt0-fin-doc-attr.
    empty temp-table tt-fin-doc.
    if buf_temp-fin-sumAvans.tot-sum = 0  then 
    do:
      next _temp-fin-sumAvans.
    end.
    v-naznach-plat = v-naznach-plat2 .
    find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sumAvans.cashbookid no-error .
    if not available ub.CashBook 
      then 
    do :
      find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
    end.

    assign
      mreceiver-name = ""
      mpayer-name    = ""
      .
    if buf_temp-fin-sumAvans.tot-sum > 0
      then
    do:
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "RuleOsnPkoAvans"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "Avanscli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "Avanscli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "corrPkoAvans"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "takenfromAvans"  )
        .
      if mpayer-name eq "" or mpayer-name eq ?
        then
      do:
        find first ub.clients no-lock where ub.clients.obj-type = v-real-obj-type-save
          and ub.clients.obj-code = v-real-obj-code-save
          no-error .
        if available ub.clients
          then
          mpayer-name = ub.clients.obj-name .
      end.
    end.
    else
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "RuleOsnPkoAvans"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "Avanscli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "Avanscli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "corrPkoAvans"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, {&by_all}, 0,  "takenfromAvans"  )
        .
    if buf_temp-fin-sumAvans.tot-sum > 0  then 
    do:
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
        ,input  v-real-obj-type-save  /*p-receiver-type*/ 
        ,input  v-real-obj-code-save /*p-receiever-code*/
        ,input 0 /*p-payer-code-schet*/
        ,input {&cmp} /*p-receiver-type*/
        ,input v-host-code /*p-receiver-code*/
        ,input 0 /*p-receiver-code-schet*/
        ,input buf_temp-fin-sumAvans.curr-code
        ,input 0 /*p-cor-acc*/
        ,input 0 /*p-cor-acc1*/
        ,input 0 /*p-an-uchet-code*/
        ,input 0 /*p-cel-nazn-code*/
        ,input buf_temp-fin-sumAvans.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    else 
    do:
           
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
        ,input v-real-obj-type-save  /*p-receiver-type*/
        ,input v-real-obj-code-save /*p-receiever-code*/
        ,input 0 /*p-receiver-code-schet*/
        ,input buf_temp-fin-sumAvans.curr-code
        ,input 0 /*p-cor-acc*/
        ,input 0 /*p-cor-acc1*/
        ,input 0 /*p-an-uchet-code*/
        ,input 0 /*p-cel-nazn-code*/
        ,input buf_temp-fin-sumAvans.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    if error-status:error then 
    do:
        &scop my-message substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.

    end.
    find first tt-fin-doc.
    /*заполнение налогов*/
    for each buf_temp-taxAvans no-lock
      where buf_temp-taxAvans.curr-code        = buf_temp-fin-sumAvans.curr-code
      and buf_temp-taxAvans.cash-desk         = buf_temp-fin-sumAvans.cash-desk
      and buf_temp-taxAvans.is-petrol        = buf_temp-fin-sumAvans.is-petrol
      and buf_temp-taxAvans.cashbookId       = buf_temp-fin-sumAvans.cashbookId
      and buf_temp-taxAvans.is-expense_cash  = buf_temp-fin-sumAvans.is-expense_cash
      and buf_temp-taxAvans.num-expense_cash = buf_temp-fin-sumAvans.num-expense_cash
      and buf_temp-taxAvans.pay-type = buf_temp-fin-sumAvans.pay-type
      :
      v-line-num = v-line-num + 1.
      create tt0-fin-doc-tax .
      assign
        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
        tt0-fin-doc-tax.line-num           = v-line-num
        tt0-fin-doc-tax.VAT-pc             = buf_temp-taxAvans.vat-pc
        tt0-fin-doc-tax.slt-pc             = buf_temp-taxAvans.slt-pc
        tt0-fin-doc-tax.sum-line-contr     = 0
        tt0-fin-doc-tax.sum-vat-line-contr = 0
        tt0-fin-doc-tax.with-vat           = buf_temp-taxAvans.with-vat
        .
      if buf_temp-fin-sumAvans.tot-sum > 0  then 
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = buf_temp-taxAvans.sum-doc
          tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-taxAvans.vat-doc
          tt0-fin-doc-tax.sum-line-rubl     = buf_temp-taxAvans.sum-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-taxAvans.vat-rubl
          tt0-fin-doc-tax.sum-line-base     = buf_temp-taxAvans.sum-base
          tt0-fin-doc-tax.sum-vat-line-base = buf_temp-taxAvans.vat-base
          .
      end.
      else 
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-taxAvans.sum-doc)
          tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-taxAvans.vat-doc)
          tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-taxAvans.sum-rubl)
          tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-taxAvans.vat-rubl)
          tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-taxAvans.sum-base)
          tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-taxAvans.vat-base)
          .
      end.
      find first temp-autotank no-lock
        where temp-autotank.curr-code = buf_temp-taxAvans.curr-code
        and temp-autotank.pay-desk = buf_temp-taxAvans.cash-desk
        and temp-autotank.is-petrol = buf_temp-taxAvans.is-petrol
        and temp-autotank.vat-pc    = buf_temp-taxAvans.vat-pc
        and temp-autotank.slt-pc    = buf_temp-taxAvans.slt-pc
        no-error.
      if available temp-autotank then 
      do:
        assign
          tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          .
      end.

      release tt0-fin-doc-tax.
    end.
    taxVne = "avans" .  
    run StrTax in this-procedure ( input-output tt-fin-doc.including) .
    /* округляем  */
    run RoundTax in this-procedure .

      
    if available ub.CashBook
      
      then 
    do :
      p-by-cash-desk = ub.CashBook.FlagSepCash .
      p-by-petrol-goods = ub.CashBook.FlagSepFull .
       
      p-by-pril = ub.CashBook.RulePril .
    end.

    if p-by-cash-desk then 
    do:
      find first temp-z-number-list no-lock
        where temp-z-number-list.cash-desk = buf_temp-fin-sumAvans.cash-desk
        no-error.
    end.        
      

    if     trim(p-by-pril) = '0' 
      and buf_temp-fin-sumAvans.pay-type ne "trans" 
      then 
      tt-fin-doc.enclosure = v-naznach-plat.
    case p-by-osnovanie:
      when '0' then 
        do :
          v-naznach-plat = 'Выручка от реализации'.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
        end.
      when '2'          then 
        do :
          v-naznach-plat = ''.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
        end.
      when '1'          then 
        do :
          if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
        end.
      otherwise 
      do:
        v-naznach-plat = p-by-osnovanie.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
      end.        
    end case .  

    assign
      tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
    assign
      tt-fin-doc.CashBookId = buf_temp-fin-sumAvans.cashbookid
      tt-fin-doc.sum-doc    = abs(buf_temp-fin-sumAvans.tot-sum)
      tt-fin-doc.sum-base   = abs(buf_temp-fin-sumAvans.tot-base)
      tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sumAvans.tot-rubl)
      tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sumAvans.curr-code = 0 then 1 else buf_temp-fin-sumAvans.tot-rubl / buf_temp-fin-sumAvans.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate  = abs(if buf_temp-fin-sumAvans.curr-code = v-base-code then 1 else buf_temp-fin-sumAvans.tot-rubl / buf_temp-fin-sumAvans.tot-base )
      tt-fin-doc.base-scale = 1
      .
    if buf_temp-fin-sumAvans.tot-sum > 0  then 
    do:
      if p-by-petrol-goods then 
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sumAvans.is-petrol then "нефтепродуктов" else "ТНП")
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      else 
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.payer-name = mpayer-name 
        when mpayer-name ne "". 
    end.
    else 
    do:
      if p-by-petrol-goods then 
      do:
        assign
          /* tt-fin-doc.receiver-name   = "Выручка от реализации " + (if buf_temp-fin-sum.is-petrol then "нефтепродуктов" else "ТНП")*/ 
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      else 
      do:
        assign
          /*   tt-fin-doc.receiver-name   = "Выручка от реализации нефтепродуктов, ТНП"*/ 
          
            
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.receiver-name = mreceiver-name 
        when mreceiver-name ne "".
    end.
      
      
    o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
      
      
      
    if available ub.CashBook
      then 
    do :
      tt-fin-doc.cor-acc-value  = mdopacct .
      tt-fin-doc.cor-acc1-value = mosnacct.
        
      if buf_temp-fin-sumAvans.tot-sum > 0
        then 
      do: 
        /*tt-fin-doc.payer-type = ub.CashBook.cli-type .
        tt-fin-doc.payer-code = ub.CashBook.cli-code .*/
        tt-fin-doc.payer-name = mpayer-name .
      end.
        
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer({&current-status-int})
        NO-LOCK NO-error.
        
      if not available ub.fin-code-cor-acc
        then 
      do:
        assign
          tt-fin-doc.cor-acc-value = {&question-mark}
          .
      end.
      else 
      do:
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
        then 
      do:
        assign
          tt-fin-doc.cor-acc1-value = {&question-mark}
          .
      end.
      else 
      do:
        assign
          tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
      end.
    end.
      
    if o-uchet = "0"
      then v-uchet = "cal" .
    else v-uchet = "smen" . 
      

    /*подкручиваем для утилиты */
    if buf_shift-obj.status_ = {&sht-closed} and v-uchet = "smen" then 
    do:
      assign
        tt-fin-doc.doc-date   = buf_shift-obj.close-date
        tt-fin-doc.shift-date = buf_shift-obj.shift-date
        tt-fin-doc.shift-num  = buf_shift-obj.shift-num
        tt-fin-doc.shift-name = buf_shift-obj.shift-name
        .
    end.
    if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
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
    if error-status:error then 
    do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.
    end.
    /*закрываем до факта*/
    find first buf_fin-doc share-lock where
      recid(buf_fin-doc) = v-doc-rec.
    assign
      buf_fin-doc.shift-flag = integer({&fin-flag-shift})
      .
    if buf_temp-fin-sumAvans.contr-kb ne ?
      then 
    do:
      find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
        and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
        and fin-doc-attr.attr-code eq "contr-kb"
        exclusive-lock no-error.
      if not available fin-doc-attr
        then 
      do:
        create fin-doc-attr.
        assign
          fin-doc-attr.host-code    = buf_fin-doc.host-code
          fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
          fin-doc-attr.attr-code    = "contr-kb"
          .
      end.
      fin-doc-attr.attr-value = String(buf_temp-fin-sumAvans.contr-kb).
    end.
      
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
    if error-status :error then 
    do:
        &scop my-message substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"  ~
                                  , ~{&new-line~}  ~
                                  , error-status:get-message(1)    ~
                                  , return-value )
      {&display-message}.
      undo _main, return error.
    END.
    if buf_fin-doc.status_ <> {&fin-fact} then 
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
      if error-status :error then 
      do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
        {&display-message}.
        undo _main, return error.
      END.
    end.
    if buf_fin-doc.status_ <> {&fin-fact} then 
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
      if error-status :error then 
      do:
          &scop my-message substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"  ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1)    ~
                                    , return-value )
        {&display-message}.
        undo _main, return error.
      END.
    end.
     &scop fin-doc-type-code (if buf_temp-fin-sumAvans.tot-sum > 0 then ~{&FDEDT_Income_Cash~} else ~{&FDEDT_expense_Cash~})
     &scop my-message substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8" ~
                                  , ~{&fin-doc-type-name~}  ~
                                  , buf_shift-obj.shift-name ~
                                  , buf_shift-obj.shift-date ~
                                  , buf_shift-obj.shift-nuM    ~
                                  , buf_shift-obj.obj-type ~
                                  , buf_shift-obj.obj-code ~
                                  , buf_temp-fin-sumAvans.cashbookid ~
                                  , abs(buf_temp-fin-sumAvans.tot-sum) ~
                                  , ~{&new-line~} ~
                                  )
    {&DISPLAY-MESSAGE}.

   end. /*for each buf_temp-fin-sumAvans no-lock*/
  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

  end. /*doe _main*/
  finally:
    delete object mCashBook no-error .
  end finally.
end procedure. /* proc-main */

procedure load-ruleset-context :
  define input parameter p-ruleset-id as integer no-undo .
  define variable v-rowid    as rowid     no-undo .
  define variable v-tbl-name as character no-undo .
  define buffer buf_rule-call-param for ub.rule-call-param.
  main-block:
  do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    if g#news = yes then 
    do:
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


PROCEDURE StrTax :
  do
    on error undo, return error return-value
    :
    define input-output parameter str as character no-undo .
    define variable v-envd as logical no-undo .
    assign 
      str = " В т.ч.: "  .

    for each tt0-fin-doc-tax :
      if str <> " В т.ч.: " then str = str + "," .
      if not tt0-fin-doc-tax.with-vat then assign str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else 
      do:
        if tt-fin-doc.curr-code = 0 then 
        do:
            case taxVne:
              when "vne" then 
                do:
                  str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              when "avans" then 
                do:
                  str = str + string(tt0-fin-doc-tax.vat-pc,">>9") + "/" + string(tt0-fin-doc-tax.vat-pc + 100,">>9") + " НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              otherwise 
              do:
                str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
              end.  
            end case .
        end.
        else 
        do:
            case taxVne:
              when "vne" then 
                do:
                  str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              when "avans" then 
                do:
                  str = str + string(tt0-fin-doc-tax.vat-pc,">>9") + "/" + string(tt0-fin-doc-tax.vat-pc + 100,">>9") + " НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + "(от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              otherwise 
              do:
                str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + "(от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
              end.  
            end case .
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
        tt0-fin-doc-tax.sum-line-doc      = ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc  = ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl     = ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl = ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base     = ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base = ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
        .
    end.
  end.
END PROCEDURE.

procedure proc-close :
  define parameter buffer buf_fin-doc for ub.fin-doc.

  define variable v-status_         as character no-undo .
  /*куда перейдет*/
  define variable v-old-status_     as character no-undo .
  /*статус первой записи*/
  define variable v-ask-date        as logical   no-undo .
  /*дата перехода статуса*/
  define variable v-ask-message     as character no-undo .
  /*подтверждающий запрос пользователю */
  define variable v-status-date-chr as character no-undo.
  define variable v-date1           as date      no-undo .
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
  if error-status:error then 
  do:
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
  if error-status:error then 
  do:
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

  define variable is-petrol as logical   no-undo.
  define variable is-pieces as logical   no-undo.
  define variable v-value   as character no-undo.
  define variable v-type    as character no-undo.

  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods    for ub.goods.

  find first buf_bar-code no-lock where
    buf_bar-code.b-code = p-b-code no-error.
  if available buf_bar-code then 
  do:
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if available buf_goods then 
    do:

      assign 
        p-is-petrolium = false .

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
    then 
  do : /* проверим на ТНП через ТРК */
    run gds-attr-value in this-procedure (
      input buf_goods.gds-code
      ,input {&attr-ptrl-as-good}
      ,output v-value
      ,output v-type
      ) no-error.
    if NOT logical(v-value) = yes then 
    do: /* нет атрибута */
      assign 
        p-is-petrolium = yes.
    end.
  end.
end.
end.

end procedure.



