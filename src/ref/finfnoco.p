block-level on error undo, throw.
/*

$Revision: 5ee64da48eb6, 3419, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:30 $
$Workfile: finfnoco.p $
$Archive: ref/finfnoco.p $

Заполнение и проверка временной таблицы платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/06/05
Author: Bakhtadze Natalya
Creation date: 11/06/05

*/

DEFINE TEMP-TABLE tt0-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0c-fin-doc NO-UNDO LIKE ub.fin-doc.
define temp-table tt-fin-doc no-undo like ub.fin-doc.
define temp-table ttc-fin-doc no-undo like ub.fin-doc.
define temp-table nc-tt-fin-doc no-undo like ub.fin-doc.
define temp-table a0-tt-fin-doc no-undo like ub.fin-doc.
define temp-table tt0-fin-doc-attr no-undo like ub.fin-doc-attr.


DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT     PARAMETER par-call-handle  AS HANDLE NO-UNDO.
/*указатель на вызвавшую процедуру - для установки там найденных здесь буферов*/

/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&add-copy} {&update} {&lookup} close-doc open-doc*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-doc-rec as recid no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-doc-type     like ub.fin-doc.fin-doc-type no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo .
define input parameter p-ob-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
define input parameter p-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input parameter p-cashbookId like ub.fin-doc.CashBookId no-undo .
define input parameter p-cashier as character no-undo .
define INPUT-OUTPUT parameter table for tt0-fin-doc.
/*если p-mode = {&add-def} в этой таблице будет лежать заполняемый платеж
если p-mode = {&add-copy} он уже будет предварительно заполнен заполнен из копируемой записи
 в противном случае здесь лежит просто буфер в котором заполняются поля и мы ПО НЕМУ как по правильному проверяем имеющийся платеж
     */

define INPUT-OUTPUT parameter table for ttc-fin-doc.
/*если p-mode <> {&add-def}
и p-mode <> {&add-copy} в этой таблице лежит проверяемый платеж
в противном случае мы его не используем

  */
define OUTPUT parameter table for tt0-fin-doc-attr.
define output parameter p-limit-access as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: 5ee64da48eb6, 3419, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:30 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finfnoco.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finfnoco.p $":U .
define variable vss-description as character no-undo init "Заполнение и проверка временной таблицы платежа".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ cmp/operlist.i }
{ ref/tmpchgs.i "NEW SHARED" temp-labels update }
{ ref/findocip.i &action="define3" }
{ trg/new-bcod.i }
{ gbl/thbj-def.i }
{ str/lib-farh.i }
{ ref/fd-attr.i " " tt0-fin-doc-attr }
{ gbl/db-attr.i }

define variable v-copy-mode                 as logical   no-undo .
define variable v-buttons                   as character no-undo .
define variable v-desc                      as character no-undo .
define variable v-t                         as character no-undo .
define variable v-num                       as integer   no-undo .
define variable v-bank-name                 like ub.fin-bank.bank-name no-undo .
define variable v-dop1                      like ub.fin-schet.dop1 no-undo .
define variable v-dop2                      like ub.fin-schet.dop2 no-undo .
define variable v-bik                       like ub.fin-bank.bik no-undo .
define variable v-c-schet                   like ub.fin-bank.cor-acc no-undo .
define variable v-r-schet                   like ub.fin-schet.r-schet no-undo .
define variable v-code-schet                like ub.fin-schet.code-schet no-undo .
define variable v-payer-schet-curr-code     like ub.fin-schet.curr-code no-undo .
define variable v-receiver-schet-curr-code  like ub.fin-schet.curr-code no-undo .
define variable v-payer-schet-curr-abbr     like ub.currency.curr-abbr no-undo .
define variable v-receiver-schet-curr-abbr  like ub.currency.curr-abbr no-undo .
define variable v-base-code                 like ub.sysconf.base-code no-undo .
define variable v-base-curr-abbr            like ub.currency.curr-abbr no-undo .
define variable v-curr-abbr-contr           like ub.currency.curr-abbr no-undo .
define variable v-sel-curr                  as character no-undo .
define variable v-curr-code                 like ub.currency.curr-code no-undo.
define variable v-today                     as date      no-undo .
define variable v-time                      as integer   no-undo .
define variable v-cli-side-inn-kpp-obj-name as character no-undo .
define variable v-contract-code             like ub.fin-doc.contract-code no-undo .
define variable v-recid-schet               as recid     no-undo .
define variable v-recid-bank                as recid     no-undo .
define variable v-ok                        as logical   no-undo .
define variable v-fin-doc-code              like ub.fin-doc.fin-doc-code no-undo .
define variable f-cor-acc-descr             as character no-undo .
define variable f-cor-acc1-descr            as character no-undo .
DEFINE VARIABLE f-an-uchet-descr            AS CHARACTER NO-UNDO.
DEFINE VARIABLE f-cel-nazn-descr            AS CHARACTER no-undo .
define variable fc-cor-acc-descr            as character no-undo .
define variable fc-cor-acc1-descr           as character no-undo .
DEFINE VARIABLE fc-an-uchet-descr           AS CHARACTER NO-UNDO.
DEFINE VARIABLE fc-cel-nazn-descr           AS CHARACTER no-undo .
define variable v-refill-payer-schet        as logical   no-undo .
define variable v-refill-receiver-schet     as logical   no-undo .
define variable v-fd-code                   as integer   no-undo .
define variable v-obj-db-num                as integer   no-undo init -1.
define variable v-author                    as character no-undo .
define variable v-param-type                as character no-undo .
define variable v-value-character           as character no-undo .
define variable v-value-date                as date      no-undo .
define variable v-value-decimal             as decimal   no-undo .
define variable v-value-integer             as INTEGER   no-undo .
define variable v-value-logical             AS LOGICAL   no-undo .
define variable v-tth                       as handle    no-undo .
define variable v-prefix-fin-doc            as character no-undo .
define variable mCashBook                   as class     ibs.th.ref.cashbookstorage no-undo .
assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
define variable o-uchet as character no-undo .


define buffer buf_contract           for ub.contract.
define buffer buf_tt-fin-doc         for tt-fin-doc.    /*заполняемый буфер */
define buffer bufc_ttc-fin-doc       for ttc-fin-doc. /*проверяемый буфер - если p-mode <> {&add-def}*/
define buffer buf_currency           for ub.currency.
define buffer buf_payer              for ub.clients.
define buffer buf_receiver           for ub.clients.
define buffer buf_fin-ob             for ub.fin-ob.
define buffer buf_sysconf            for ub.sysconf.
define buffer buf_curr_sysconf       for ub.sysconf.
define buffer buf_firm               for ub.firm.
define buffer buf_clients-host       for ub.clients.
define buffer buf_clients-obj        for ub.clients.
define buffer buf_payer-fin-schet    for ub.fin-schet.
define buffer buf_receiver-fin-schet for ub.fin-schet.
define buffer buf_payer-fin-bank     for ub.fin-bank.
define buffer buf_receiver-fin-bank  for ub.fin-bank.
define buffer buf_payer-firm         for ub.firm.
define buffer buf_payer-person       for ub.person.
define buffer buf_receiver-firm      for ub.firm.
define buffer buf_receiver-person    for ub.person.
define buffer buf_nc-tt-fin-doc      for nc-tt-fin-doc.
define buffer buf_a0-tt-fin-doc      for a0-tt-fin-doc.
define buffer buf_fin-code-cor-acc   for ub.fin-code-cor-acc.
define buffer buf_fin-code-cor-acc1  for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet  for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn  for ub.fin-code-cel-nazn.
define buffer buf_contract-currency  for ub.currency.
define buffer locked_fin-doc         for ub.fin-doc.


do
  on error undo,
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) )  
  /* return error substitute( "&1" , return-value )   */
  :

  { gbl/getcntxt.i get }
  
  assign
    v-prefix-fin-doc = (if num-entries(p-mode, {&delim-par}) > 2
            then entry(3, p-mode, {&delim-par})
            else '':U)    
    v-author = (if num-entries(p-mode, {&delim-par}) > 1
            then entry(2, p-mode, {&delim-par})
            else '':U)
    p-mode   = entry(1, p-mode, {&delim-par})
    .


  if p-mode <> {&add-copy}
    then 
  do:
    /*заполняемый буфер tt-fin-doc - записи в нем нет*/
    for each tt-fin-doc:
      delete tt-fin-doc.
    end.
  end.
  if p-mode = {&add-copy} then 
  do:
    /*заполняемый буфер tt-fin-doc - запись в нем есть*/
    for each tt0-fin-doc no-lock where
      tt0-fin-doc.host-code = p-host-code
      AND tt0-fin-doc.fin-doc-code = 0:
      create buf_tt-fin-doc.
      buffer-copy tt0-fin-doc to buf_tt-fin-doc.
      release buf_tt-fin-doc.
      create buf_a0-tt-fin-doc.
      buffer-copy tt0-fin-doc to buf_a0-tt-fin-doc.
      release buf_a0-tt-fin-doc.
    END.
    find first tt-fin-doc no-error .
    if not avail tt-fin-doc then 
    do:
      return error substitute("Нет записи в заполняемом буфере для платежа с типом &1", p-fin-ext-doc-type).
    end.
    find first buf_a0-tt-fin-doc.
    run get-fin-code-descr in this-procedure (
      input {&lookup}
      ,input buf_a0-tt-fin-doc.cor-acc1
      ,input buf_a0-tt-fin-doc.cor-acc
      ,input buf_a0-tt-fin-doc.an-uchet-code
      ,input buf_a0-tt-fin-doc.cel-nazn-code
      ,input-output buf_a0-tt-fin-doc.cor-acc1-value
      ,input-output buf_a0-tt-fin-doc.cor-acc-value
      ,input-output buf_a0-tt-fin-doc.an-uchet-value
      ,input-output buf_a0-tt-fin-doc.cel-nazn-value
      ,output fc-cor-acc1-descr
      ,output fc-cor-acc-descr
      ,output fc-an-uchet-descr
      ,output fc-cel-nazn-descr
      ).

  end.
  if p-mode <> {&add-def}
    and p-mode <> {&add-copy}
    then 
  do:
    /*проверяемый буфер ttc-fin-doc - запись в нем есть*/
    for each tt0c-fin-doc no-lock where
      tt0c-fin-doc.host-code = p-host-code
      AND tt0c-fin-doc.fin-doc-code = p-fin-doc-code:
      create bufc_ttc-fin-doc.
      buffer-copy tt0c-fin-doc to bufc_ttc-fin-doc.
      v-fin-doc-code = tt0c-fin-doc.fin-doc-code.
      release bufc_ttc-fin-doc.
    END.
    find first ttc-fin-doc no-error .
    if not avail ttc-fin-doc then 
    do:
      return error substitute("Нет записи в проверяемом буфере для платежа &1", p-fin-doc-code).
    end.
    /*скопируем ЧАСТЬ проверяемого буфера в tt-fin-doc - те поля которые соответствуют входынм параметрам*/
    create tt-fin-doc.
    if p-mode = {&lookup} then 
    do:
      buffer-copy ttc-fin-doc
        to
        tt-fin-doc.
    end.
    else 
    do:
      buffer-copy ttc-fin-doc
        using
        host-code
        fin-doc-code
        fin-doc-type
        fin-ext-doc-type
        obj-type
        obj-code
        contract-code
        /*ob-doc-code*/
        payer-type
        payer-code
        payer-code-schet
        receiver-type
        receiver-code
        receiver-code-schet
        curr-code
        status_
        to
        tt-fin-doc.
    end.
  end.
  CASE p-mode:
    when {&lookup} then 
      do:
        assign
          p-limit-access = 10
          .
      end.
    when {&add-def}
    or
    when {&add-copy}
    then 
      do:
        assign
          p-limit-access = 0.
      end.
    otherwise 
    do:
      /*для переводов статуса*/
      assign
        p-mode = {&update}
        .
      if tt-fin-doc.status_ = {&fin-permitted}  then 
      do:
        assign
          p-limit-access = 1
          .
      end.
      if tt-fin-doc.status_ = {&fin-bank}  then 
      do:
        assign
          p-limit-access = 2
          .
      end.
    end. /*otherwise*/
  end CASE.
  /*блок проверки параметров*/
  find first buf_sysconf no-lock where
    buf_sysconf.host-code = p-host-code.
  if (p-mode = {&add-def}
    and p-obj-type <> "":U
    and p-obj-code <> 0)
    or  (p-mode <> {&add-def}
    and tt-fin-doc.obj-type <> "":U
    and tt-fin-doc.obj-code <> 0)
    then 
  do:
    find first buf_clients-obj no-lock where
      buf_clients-obj.obj-type = (if p-mode = {&add-def}
      then p-obj-type
      else tt-fin-doc.obj-type)
      AND buf_clients-obj.obj-code = (if p-mode = {&add-def}
      then p-obj-code
      else tt-fin-doc.obj-code)  no-error.
    if not available buf_clients-obj then 
    do:
      undo, return error substitute ("&1 &2 &3&4Неверное значение параметров вызова p-obj-type или поля obj-type &5&4и/или p-obj-code или поля obj-code&6"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,{&new-line}
        ,(if p-mode = {&add-def} then p-obj-type else tt-fin-doc.obj-type)
        ,(if p-mode = {&add-def} then p-obj-code else tt-fin-doc.obj-code)).
    end.
    { gbl/objdbnum.i buf_clients-obj.obj-type buf_clients-obj.obj-code v-obj-db-num }
  end. /*if (p-mode = {&add-def}*/
  define variable v-cash-book-place as character no-undo .
  define variable v-cash-book       as integer   no-undo .
  if (p-mode = {&add-def}
    and p-obj-type <> "":U
    and p-obj-code <> 0)
    or  (p-mode = {&add-copy}
    and tt-fin-doc.obj-type <> "":U
    and tt-fin-doc.obj-code <> 0)
    then 
  do:
    /*при создании платежа проставим cash-book-place  - auto сюда не должны попадать*/
    if v-obj-db-num = v-cntxt-db-num then 
    do:
      /*только там может быть не пусто v-cash-book-place */
      /*      { gbl/cashbook.i buf_clients-obj.obj-type buf_clients-obj.obj-code v-cash-book no-error }*/
      /*                                                                                               */
      /*      if v-cash-book = integer({&cash-book-object}) then do:                                   */
      assign
        v-cash-book-place = buf_clients-obj.obj-type + string(buf_clients-obj.obj-code, "99999")
        .
    /*      end.*/
    end.
    /*найдем как заполнить стурктурное подразделение*/
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    
    define variable par-type        as character no-undo .
    define variable v-dpt-option    as character no-undo .
    define variable v-dpt-dflt-name as character no-undo .
    define variable v-dpt-dflt-type as character no-undo .
    define variable v-dpt-dflt-code as integer   no-undo .
    define variable v-hist-code     as character no-undo .
    define variable v-hist-name     as character no-undo .
    
    mCashBook = new ibs.th.ref.cashbookstorage () .
      
    v-dpt-option    = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "Struct") .
    v-dpt-dflt-name = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptName") .
    v-dpt-dflt-type = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptType") .
    v-dpt-dflt-code = integer(mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptCode")) .
    o-uchet         = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "uchet") .
    delete object mCashBook no-error .
    
    case v-dpt-option:
      when "1" then 
        do:
            run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
            run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-name},OUTPUT v-hist-name ,OUTPUT par-type) .
            if v-hist-code = "" then v-dpt-dflt-code = buf_clients-obj.obj-code .  
            if v-hist-name = "" then v-dpt-dflt-name = buf_clients-obj.obj-name .
            v-dpt-dflt-type = buf_clients-obj.obj-type .  
      end.
      when "0" then do:
      assign
        v-dpt-dflt-name = ''
        v-dpt-dflt-type = ''
        v-dpt-dflt-code = 0
        .
    end.
      otherwise do:
  /*уже заполнено в цикле*/
  assign
    v-dpt-dflt-name = v-dpt-dflt-name
    v-dpt-dflt-type = v-dpt-dflt-type
    v-dpt-dflt-code = v-dpt-dflt-code
    .
end.
end case.
end. /*if (p-mode = {&add-def}*/
if p-mode = {&update} then 
do:
  v-cash-book-place = ttc-fin-doc.trn-doc-code.
end.
define variable v-log      as logical   no-undo .
define variable v-out-mess as character no-undo .
if p-mode <> {&lookup} then 
do:
  /*    { str/finchkdb.i                                                                                          */
  /*      p-host-code                                                                                             */
  /*      p-fin-doc-code                                                                                          */
  /*      p-obj-type                                                                                              */
  /*      p-obj-code                                                                                              */
  /*      p-fin-ext-doc-type                                                                                      */
  /*      v-cash-book-place                                                                                       */
  /*      ?                                                                                                       */
  /*      v-log                                                                                                   */
  /*      v-out-mess                                                                                              */
  /*      no-error }                                                                                              */
  /*    if error-status:error then do:                                                                            */
  /*      undo, return error  substitute("Ошибка при проверке возможности создания документа в данной БД &1&2&1&3"*/
  /*                                                  , {&new-line}                                               */
  /*                                                  , error-status:get-message(1)                               */
  /*                                                  , return-value                                              */
  /*                                                  ).                                                          */
  /*                                                                                                              */
  /*    end.                                                                                                      */
  /*    if not v-log then do:                                                                                     */
  /*      undo, return error substitute("Невозможно создать/изменить документ в данной БД:&1&2"                   */
  /*                                  , {&new-line}                                                               */
  /*                                  , v-out-mess).                                                              */
  /*    end.                                                                                                      */
  if not (p-obj-type = '' and p-obj-code = 0)
    and v-obj-db-num = v-cntxt-db-num then 
  do:
    define variable l-shift-on as logical no-undo .
    { gbl/objat.i
        p-obj-type
        p-obj-code
        "'shift-on=request'"
        l-shift-on
      }
  end.
end.

find first buf_clients-host no-lock where
  buf_clients-host.obj-type = {&cmp}
  AND buf_clients-host.obj-code = p-host-code  no-error.
if not available buf_clients-host then 
do:
  undo, return error substitute("&1 &2 &3&4Неверное значение параметра вызова p-host-code &5"
    ,vss-workfile
    ,vss-revision
    ,vss-description
    ,{&new-line}
    ,p-host-code).
end.
find first buf_firm no-lock where
  buf_firm.firm-code = p-host-code.
if (p-mode = {&add-def}
  and p-contract-code <> 0)
  or (p-mode <> {&add-def}
  and tt-fin-doc.contract-code <> 0) then 
do:
  find first buf_contract no-lock where
    buf_contract.contract-code = (if p-mode = {&add-def}
    then p-contract-code
    else tt-fin-doc.contract-code)
    and buf_contract.host-code     = p-host-code   no-error .
  if error-status :error then 
  do:
    undo, return error substitute("&1 &2 &3&4Неверное значение параметра P-contract-code или поля contract-code&4Не найден контракт с кодом &1 по фирме &2"
      ,(if p-mode = {&add-def} then p-contract-code else tt-fin-doc.contract-code)
      ,p-host-code).
  end.
  v-contract-code = buf_contract.contract-code.
end.

if (p-mode = {&add-def}
  and p-ob-doc-code <> "" )
  then 
do:
  find first buf_fin-ob where
    buf_fin-ob.host-code = p-host-code
    AND buf_fin-ob.doc-code = p-ob-doc-code
    /*(if p-mode = {&add-def}
     then p-ob-doc-code
     else tt-fin-doc.ob-doc-code)*/
    no-error .
  if not available buf_fin-ob then 
  do:
    undo, return error substitute("&1 &2 &3&4Не найдено финобязательство с кодом &4 по фирме &5"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,p-ob-doc-code  /*(if p-mode = {&add-def} then p-ob-doc-code else tt-fin-doc.ob-doc-code)*/
      ,p-host-code).
  end.
  find first buf_contract where
    buf_contract.host-code = p-host-code
    AND buf_contract.contract-code = buf_fin-ob.contract-code  no-error .
  if not available buf_contract
    or buf_contract.contract-code <> v-contract-code
    then 
  do:
    undo, return error( substitute("&1 &2 &3&4Неверный параметр p-ob-doc-code или значение поля ob-doc-code &5&4&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,p-ob-doc-code /*(if p-mode = {&add-def}  then buf_fin-ob.doc-code else tt-fin-doc.ob-doc-code)*/
      ,(if not available buf_contract
      then "Не найден договор для финобязательства"
      else substitute("Номер договора в платеже &1, номер договора для финобязательства &2"
      ,v-contract-code
      ,buf_contract.contract-code))
      )).
  end.
  assign
    v-curr-code = buf_fin-ob.curr-code
    .
end.
if (p-mode = {&add-def} and p-curr-code <> ?)
  or p-mode <> {&add-def}
  then 
do:
  find first buf_currency no-lock where
    buf_currency.curr-code = (if p-mode = {&add-def}
    then p-curr-code
    else tt-fin-doc.curr-code)  no-error .
  if not available buf_currency
    or (v-curr-code <> ? and buf_currency.curr-code <> v-curr-code and p-mode = {&add-def})
    then 
  do:
    undo, return error substitute("&1 &2 &3&4Неверный параметр p-curr-code или значение поля curr-code&5&4&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,(if p-mode = {&add-def} then p-curr-code else tt-fin-doc.curr-code)
      ,(if not available buf_currency
      then "Не найден валюта с таким кодом"
      else substitute("Код валюты в платеже &1, код валюты для финобязательства &2"
      ,v-curr-code
      ,buf_currency.curr-code))
      ).
  end.
end.
if (p-mode = {&add-def}
  and p-payer-type <> "":U
  AND p-payer-code <> 0)
  or (p-mode <> {&add-def}
  and tt-fin-doc.payer-type <> '':U
  and tt-fin-doc.payer-code <> 0)
  then 
do:
  FIND FIRST buf_payer NO-LOCK WHERE
    buf_payer.obj-type = (if p-mode = {&add-def}
    then p-payer-type
    else tt-fin-doc.payer-type)
    AND buf_payer.obj-code = (if p-mode = {&add-def}
    then p-payer-code
    else tt-fin-doc.payer-code)
    NO-ERROR .
  if not avail buf_payer then 
  do:
    undo, return error substitute("&1& 2& 3&4 Неверные параметры p-payer-type или значение поля payer-type&5&4" +
      "И/ИЛИ p-payer-code или значение поля payer-code&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,(if p-mode = {&add-def} then p-payer-type else tt-fin-doc.payer-type)
      ,(if p-mode = {&add-def} then p-payer-code else tt-fin-doc.payer-code)).
  end.
  if buf_payer.obj-type = {&cmp} then 
  do:
    find first buf_payer-firm no-lock where
      buf_payer-firm.firm-code = buf_payer.obj-code no-error.
    if not avail buf_payer-firm then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике организаций"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,string(buf_payer.obj-code)).
    end.
  end.
  else 
  do:
    find first buf_payer-person no-lock where
      buf_payer-person.psn-code = buf_payer.obj-code no-error.
    if not avail buf_payer-person then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике физических лиц"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,string(buf_payer.obj-code)).
    end.
  end.
end.
if (p-mode = {&add-def}
  and p-receiver-type <> "":U
  AND p-receiver-code <> 0)
  or (p-mode <> {&add-def}
  and
  tt-fin-doc.receiver-type <> '':U
  and
  tt-fin-doc.receiver-code <> 0)
  then 
do:
  
  FIND FIRST buf_receiver WHERE
    buf_receiver.obj-type = (if p-mode = {&add-def}
    then p-receiver-type
    else tt-fin-doc.receiver-type)
    AND buf_receiver.obj-code = (if p-mode = {&add-def}
    then p-receiver-code
    else tt-fin-doc.receiver-code)
    NO-LOCK  no-error.
  if not avail buf_receiver then 
/*   do:
     

    undo, return error substitute("&1 &2 &3&4 Неверные параметры p-receiver-type или значение поля receiver-type &5&4И/ИЛИ p-receiver-code или значение поля receiver-code &6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,(if p-mode = {&add-def} then p-receiver-type else tt-fin-doc.receiver-type)
      ,(if p-mode = {&add-def} then p-receiver-code else tt-fin-doc.receiver-code)).
  end. */
  
  do:
    undo, return error substitute("Неверные параметры p-receiver-type или значение поля receiver-type &1 &2 И/ИЛИ p-receiver-code или значение поля receiver-code &3",
      (if p-mode = {&add-def} then p-receiver-type else tt-fin-doc.receiver-type)
      ,{&new-line}
      ,(if p-mode = {&add-def} then p-receiver-code else tt-fin-doc.receiver-code)).
  end.
  
  if buf_receiver.obj-type = {&cmp} then 
  do:
    find first buf_receiver-firm no-lock where
      buf_receiver-firm.firm-code = buf_receiver.obj-code no-error. 
    if not avail buf_receiver-firm then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике организаций"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,string(buf_receiver.obj-code)).
    end.
  end.
  else 
  do:
    find first buf_receiver-person no-lock where
      buf_receiver-person.psn-code = buf_receiver.obj-code.
    if not avail buf_receiver-person then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике физических лиц"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,string(buf_receiver.obj-code)).
    end.
  end.

end.
/*блок проверки счетов по безналу*/
if p-fin-doc-type = {&income-cashless}
  or p-fin-doc-type = {&expense-cashless} then 
do:
  if (p-mode = {&add-def} and p-payer-code-schet <> 0)
    or (p-mode <> {&add-def} and tt-fin-doc.payer-code-schet <> 0)
    then 
  do:
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input (if p-mode = {&add-def}
      then p-payer-code-schet
      else tt-fin-doc.payer-code-schet)
      ,input (if p-mode = {&add-def}
      then p-receiver-code-schet
      else tt-fin-doc.receiver-code-schet)
      ,input (if p-mode = {&add-def} then p-payer-type else tt-fin-doc.payer-type)
      ,input (if p-mode = {&add-def} then p-payer-code else tt-fin-doc.payer-code)
      ,input (if p-mode = {&add-def} then p-receiver-type else tt-fin-doc.receiver-type)
      ,input (if p-mode = {&add-def} then p-receiver-code else tt-fin-doc.receiver-code)
      ,input no /*refill if need*/
      ,input-output tt-fin-doc.payer-bank-name
      ,input-output tt-fin-doc.receiver-bank-name
      ,input-output tt-fin-doc.payer-bank-city
      ,input-output tt-fin-doc.receiver-bank-city
      ,input-output tt-fin-doc.payer-bik
      ,input-output tt-fin-doc.receiver-bik
      ,input-output tt-fin-doc.payer-r-schet
      ,input-output tt-fin-doc.receiver-r-schet
      ,input-output tt-fin-doc.payer-c-schet
      ,input-output tt-fin-doc.receiver-c-schet
      ) no-error .
    if error-status:error then 
    do:
      undo, return error return-value .
    end.
  end.
  if  not avail buf_receiver-fin-schet
    and available buf_receiver
    then 
  do:
    run get-single-schet in this-procedure(
      input p-host-code
      ,input buf_receiver.obj-type
      ,input buf_receiver.obj-code
      ,input v-curr-code
      ,output v-recid-schet
      ,output v-recid-bank
      ).
    if v-recid-schet <> ? then 
    do:
      find first buf_receiver-fin-schet no-lock where
        recid(buf_receiver-fin-schet) = v-recid-schet.
      find first buf_receiver-fin-bank no-lock where
        recid(buf_receiver-fin-bank) = v-recid-bank.
    end.
  end.
  if not avail buf_payer-fin-schet
    and available buf_payer
    then 
  do:
    run get-single-schet in this-procedure(
      input p-host-code
      ,input buf_payer.obj-type
      ,input buf_payer.obj-code
      ,input v-curr-code
      ,output v-recid-schet
      ,output v-recid-bank
      ).
    if v-recid-schet <> ? then 
    do:
      find first buf_payer-fin-schet no-lock where
        recid(buf_payer-fin-schet) = v-recid-schet.
      find first buf_payer-fin-bank no-lock where
        recid(buf_payer-fin-bank) = v-recid-bank.
    end.
  end.
end. /* безналичные*/


if p-mode = {&add-def}
  or p-mode = {&add-copy} then 
do:
  if p-mode = {&add-def} then 
  do:
    create tt-fin-doc.
  end.
  run gen-b-code in this-procedure ( input {&gbl-fd-code}
    , output v-fd-code) no-error .
  if error-status:error then 
  do:
    undo, return error substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
      , {&new-line}
      , error-status:get-message(1)
      , return-value ).
  end.
  assign
    tt-fin-doc.host-code        = p-host-code
    tt-fin-doc.fin-doc-code     = v-fd-code
    v-fin-doc-code              = tt-fin-doc.fin-doc-code
    tt-fin-doc.fin-doc-type     = p-fin-doc-type
    tt-fin-doc.fin-ext-doc-type = p-fin-ext-doc-type
    tt-fin-doc.prn-doc-code     = v-prefix-fin-doc + "":U /*todo*/
    tt-fin-doc.status_          = {&fin-new}
    tt-fin-doc.user-db-num-doc  = v-cntxt-db-num
    tt-fin-doc.user-name-doc    = v-cntxt-userid
    tt-fin-doc.curr-code        = v-curr-code
    /*значения курсов здесь неважны их потом все равно пересчитываем!!!!*/
    tt-fin-doc.base-rate        = 1
    tt-fin-doc.base-scale       = 1
    tt-fin-doc.exch-rate        = 1
    tt-fin-doc.exch-scale       = 1
    tt-fin-doc.CashBookId       = (if p-mode = {&add-def}
                                then p-cashbookId
                                else tt-fin-doc.cashbookId)
    tt-fin-doc.contract-code    = (if p-mode = {&add-def}
                                then p-contract-code
                                else tt-fin-doc.contract-code)
    tt-fin-doc.contract-curr    = (if p-mode = {&add-def}
                                then (if available buf_contract
                                      then buf_contract.curr-code
                                      else 0)
                                else tt-fin-doc.contract-curr)
    tt-fin-doc.contract-rate    = (if p-mode = {&add-def}
                                then 1
                                else tt-fin-doc.contract-rate)
    tt-fin-doc.contract-scale   = (if p-mode = {&add-def}
                                 then 1
                                 else tt-fin-doc.contract-scale)
    tt-fin-doc.obj-type         = (if p-mode = {&add-def}
                                then p-obj-type
                                else tt-fin-doc.obj-type)
    tt-fin-doc.obj-code         = (if p-mode = {&add-def}
                                then p-obj-code
                                else tt-fin-doc.obj-code)
    tt-fin-doc.str-podr-name    = if v-hist-name = "" then v-dpt-dflt-name else v-hist-name
    tt-fin-doc.str-podr-type    = v-dpt-dflt-type
    tt-fin-doc.str-podr-code    = v-dpt-dflt-code
    tt-fin-doc.sum-doc          = (if p-mode = {&add-def}
                           then (if available buf_fin-ob
                                 then buf_fin-ob.sum-doc
                                 else 0)
                           else tt-fin-doc.sum-doc)
    tt-fin-doc.doc-author       = v-author
    tt-fin-doc.shift-flag       = (if l-shift-on and v-cash-book-place <> ""
                                    and lookup(tt-fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
                                    and (tt-fin-doc.doc-author = {&manual} or tt-fin-doc.doc-author = {&auto})
                                    then integer({&fin-flag-shift})
                                    else 0)
    tt-fin-doc.trn-doc-code     = (if p-mode = {&add-def}
                               then v-cash-book-place
                               else tt-fin-doc.trn-doc-code)
    .
  /* message tt-fin-doc.doc-author        tt-fin-doc.shift-flag view-as alert-box .     */
  /*заплним смену*/
  if l-shift-on
    and tt-fin-doc.shift-flag = integer({&fin-flag-shift})
    then 
  do:
    define variable v-fin-doc-shift-date      as date      no-undo .
    define variable v-fin-doc-shift-num       as integer   no-undo .
    define variable v-fin-doc-shift-name      as character no-undo .
    define variable v-fin-doc-shift-date-char as character no-undo .
    define variable v-fin-doc-shift-num-char  as character no-undo .
    define variable varobj-shift-date         as date      no-undo .
    define variable varobj-shift-num          as integer   no-undo .
    define variable varobj-shift-name         as character no-undo .
    define variable v-can-back-shift          as logical   no-undo .

    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_fin-doc_create-back-shift':U
        {&cntxt-object}
        tt-fin-doc.host-code
        tt-fin-doc.obj-type
        tt-fin-doc.obj-code
        0
        0
        0
        false
        v-can-back-shift
      }


    { gbl/curshift.i
        tt-fin-doc.obj-type
        tt-fin-doc.obj-code
        varobj-shift-date
        varobj-shift-num
        varobj-shift-name
        no-error
      }

    if error-status :error then 
    do:
      if not v-can-back-shift then 
      do:
        return error substitute("Не найдена текущая смена на &1&2", tt-fin-doc.obj-type, tt-fin-doc.obj-code).
      end.
    end.
    assign
      v-fin-doc-shift-date = varobj-shift-date
      v-fin-doc-shift-num  = varobj-shift-num
      v-fin-doc-shift-name = varobj-shift-name
      .
    define variable v-date as date no-undo  .

    run cur-time in this-procedure(output v-date, output v-time).
    /*
     run gbl/chk-date.p
    ( input tt-fin-doc.obj-type
    , input tt-fin-doc.obj-code
    , input tt-fin-doc.doc-date
    , input v-time
    , input v-fin-doc-shift-date
    , input v-fin-doc-shift-num
    , input no) no-error.
    if error-status:error then do:
      undo, return error substitute("Ошибка при проверке сменной даты&1&2&1&3"
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
    end.*/
    assign
      tt-fin-doc.shift-date = v-fin-doc-shift-date
      tt-fin-doc.shift-num  = v-fin-doc-shift-num
      tt-fin-doc.shift-name = v-fin-doc-shift-name
      .
      if o-uchet <> "0" then tt-fin-doc.doc-date = v-fin-doc-shift-date .
      else tt-fin-doc.doc-date = v-today .
  end. /*if l-shift-on*/
  else 
  do:
    assign
      tt-fin-doc.shift-date = ?
      tt-fin-doc.shift-num  = 0
      tt-fin-doc.shift-name = ''
      .
  end.
  if p-mode = {&add-copy}
    then
    assign
      p-mode      = {&add-def}
      v-copy-mode = yes
      .
end.
run cur-time in this-procedure
  (output v-today
  ,output v-time
  ) no-error .
/*присвоение полей специфических для типа платежа*/
if tt-fin-doc.status_ <> {&fin-fact} then 
do:
  if tt-fin-doc.obj-type <> ''then 
  do:
    /*      run adm/shattri.p (                 */
    /*          input "get":U                   */
    /*          ,input  tt-fin-doc.obj-type     */
    /*          ,input  tt-fin-doc.obj-code     */
    /*          ,input  {&attr-fin-doc}         */
    /*          ,input  "":U /*p-param-code*/   */
    /*          ,output v-value-character       */
    /*          ,output v-value-date            */
    /*          ,output v-value-decimal         */
    /*          ,output v-value-integer         */
    /*          ,output v-value-logical         */
    /*          ,output v-param-type            */
    /*          ,INPUT-OUTPUT table-handle v-tth*/
    /*          ) no-error .                    */
    define variable o-head-position as character no-undo .
    define variable o-director      as character no-undo .
    define variable o-snr-accnt     as character no-undo .
    define variable o-cashier       as character no-undo .
    define variable v-head-position as character no-undo .
    define variable v-director      as character no-undo .
    define variable v-snr-accnt     as character no-undo .
    define variable v-cashier       as character no-undo .
    define buffer buf_shop  for ub.shop.
    define buffer buf_store for ub.store.
    define variable p-by-osnovanie    as character no-undo .
    define variable p-by-pril         as character no-undo .
    define variable p-by-cash-desk    as logical   no-undo .
    define variable p-by-petrol-goods as logical   no-undo .
    mCashBook = new ibs.th.ref.cashbookstorage () .

    o-head-position = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerPosition") .
    o-director      = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerFIO") .
    o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .
      
    delete object mCashBook no-error .

    case o-head-position:
      when '0':U then 
        do:
          v-head-position = buf_sysconf.head-position.
        end.
      when '1':U then 
        do:
          v-head-position = "Директор".
        end.
      when '2':U then 
        do:
          v-head-position = "Управляющий".
        end.
      otherwise 
      do :
        v-head-position = o-head-position.
      end. 
    end case.
    case o-director:
      when '1':U then 
        do:
          if p-obj-type = {&shop} then 
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then 
            do:
              v-director = buf_shop.director.
            end.
          end.
          if p-obj-type = {&stock} then 
          do:
            find first buf_store no-lock where
              buf_store.obj-code = p-obj-code no-error .
            if available buf_store then 
            do:
              v-director = buf_store.store-boss.
            end.
          end.
        end. /*when 'dir_obj' then do:*/
      when '0':U then 
        do:
          v-director = buf_firm.director.
        end.
      otherwise 
      do:
        v-director = o-director .
      end.  
    end case.
    case o-snr-accnt:
      when '1':U then 
        do:
          if p-obj-type = {&shop} then 
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then 
            do:
              v-snr-accnt = entry(1,buf_shop.acct,"|").
            end.
          end.
          if p-obj-type = {&stock} then 
          do:
            v-snr-accnt = ''.
          end.
        end.
      when '2':U then 
        do:
          v-snr-accnt = buf_sysconf.snr-accnt.
        end.
      otherwise 
      do:
        v-snr-accnt = o-snr-accnt .
      end.  
    end case.
      
    v-cashier = buf_sysconf.cashier.
    if v-cashier = "" then v-cashier = p-cashier .
  end. /*if tt-fin-doc.obj-type <> ''then do:*/
  else 
  do:
    assign
      v-head-position = buf_sysconf.head-position
      v-director      = buf_firm.director
      v-snr-accnt     = buf_sysconf.snr-accnt
      v-cashier       = buf_sysconf.cashier
      .
  end.
  /* ищем следующюю смену и ее персонал */

  FIND FIRST ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = p-obj-type AND
    ub.shift-staff.obj-code   = p-obj-code AND
    ub.shift-staff.shift-date = tt-fin-doc.shift-date AND
    ub.shift-staff.shift-num  = tt-fin-doc.shift-num AND
    ub.shift-staff.shift-name  = tt-fin-doc.shift-name AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 No-ERROR.
  assign 
    v-cashier = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else  string(p-cashier, "X(30)") .
  .
  find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookid no-error .
  if not available ub.CashBook 
    then 
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then 
  do :
    p-by-cash-desk = ub.CashBook.FlagSepCash .
    p-by-petrol-goods = ub.CashBook.FlagSepFull .
  /*        case ub.CashBook.RulePril:                      */
  /*          when "0" then p-by-pril = "Номера Z-отчетов" .*/
  /*          when "1" then p-by-pril = "Не заполнять" .    */
  /*          otherwise p-by-pril = ub.CashBook.RulePril .  */
  /*        end case.                                       */
  end.
      
  CASE p-fin-ext-doc-type:
    when {&FDEDT_Income_Cash} then 
      do:
        assign
          tt-fin-doc.receiver-type  = {&cmp}
          tt-fin-doc.receiver-code  = p-host-code
          tt-fin-doc.receiver-okpo  = buf_firm.okpo
          tt-fin-doc.receiver-name  = buf_clients-host.obj-name
          tt-fin-doc.doc-date       = v-today
          tt-fin-doc.receiver-sign1 = v-director
          tt-fin-doc.receiver-sign2 = v-snr-accnt
          tt-fin-doc.receiver-sign3 = v-cashier
          tt-fin-doc.payer-type     = (if available buf_payer then buf_payer.obj-type else {&cmp})
          tt-fin-doc.payer-code     = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name     = (if available buf_payer then buf_payer.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in-cash
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in-cash
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in-cash
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-in-cash
            .
          if available (ub.CashBook)
          and ub.CashBook.CorrPko <> "" then 
          do:
            for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrPko
              and ub.fin-code-cor-acc.host-code = p-curr-host-code :
              tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
            end.
          end.
        end.
      end.
    when {&FDEDT_Expense_Cash} then 
      do:
        assign
          tt-fin-doc.payer-type    = {&cmp}
          tt-fin-doc.payer-code    = p-host-code
          tt-fin-doc.payer-okpo    = buf_firm.okpo
          tt-fin-doc.payer-name    = buf_clients-host.obj-name
          tt-fin-doc.payer-sign1   = v-head-position + {&delim-par} + v-director
          tt-fin-doc.payer-sign2   = v-snr-accnt
          tt-fin-doc.payer-sign3   = v-cashier
          tt-fin-doc.receiver-type = (if available buf_receiver then buf_receiver.obj-type else {&cmp})
          tt-fin-doc.receiver-code = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name = (if available buf_receiver then buf_receiver.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out-cash
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out-cash
            .
          if available (ub.CashBook) then 
          do:
            case ub.CashBook.RuleOsnRko :
              when "0" then 
                tt-fin-doc.naznach-plat = "Выручка от реализации" .
              when "1" or 
              when "2" then 
                tt-fin-doc.naznach-plat = "" .
              otherwise 
              tt-fin-doc.naznach-plat = ub.CashBook.RuleOsnRko .
            end case .
            if ub.CashBook.RulePril = "0" or ub.CashBook.RulePril = "1" then tt-fin-doc.enclosure = "" .
            else tt-fin-doc.enclosure = ub.CashBook.RulePril .
            if ub.CashBook.CorrRko <> "" then 
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrRko
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
              end.
            end.
            else 
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
                tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
              end. 
            end.  
            if ub.CashBook.OsnAcct <> "" then 
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code .
              end.
            end.
          end.
      
        end.
      end.
    when {&FDEDT_Income_Cashless} then 
      do:
        assign
          tt-fin-doc.curr-code           = 0
          tt-fin-doc.receiver-type       = {&cmp}
          tt-fin-doc.receiver-code       = p-host-code
          tt-fin-doc.receiver-inn        = buf_firm.inn
          tt-fin-doc.receiver-kpp        = buf_firm.kpp
          tt-fin-doc.receiver-name       = buf_clients-host.obj-name
          tt-fin-doc.receiver-bank-name  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-name
                                         else '':U)
          tt-fin-doc.receiver-bank-city  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.receiver-bik        = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          tt-fin-doc.receiver-code-schet = if available buf_receiver-fin-schet
                                      then buf_receiver-fin-schet.code-schet
                                      else 0
          tt-fin-doc.receiver-r-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.receiver-c-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = buf_firm.director
          tt-fin-doc.payer-sign2         = buf_sysconf.snr-accnt
          tt-fin-doc.ocher-pl            = "6":U
          tt-fin-doc.stat-pl             = "":U
          tt-fin-doc.payer-type          = (if available buf_payer then buf_payer.obj-type else {&cmp})
          tt-fin-doc.payer-code          = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name          = (if available buf_payer then buf_payer.obj-name else "":U)
          tt-fin-doc.payer-inn           = (if available buf_payer
                                    then (if buf_payer.obj-type = {&cmp}
                                          then buf_payer-firm.inn
                                          else buf_payer-person.inn )
                                    else "":U)
          tt-fin-doc.payer-kpp           = (if available buf_payer
                                      then (if buf_payer.obj-type = {&cmp}
                                            then buf_payer-firm.kpp
                                            else buf_payer-person.kpp )
                                    else "":U)
          tt-fin-doc.payer-bank-name     = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bank-name
                                      else '':U)
          tt-fin-doc.payer-bank-city     = (if available buf_payer-fin-bank
                                        then buf_payer-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.payer-bik           = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          tt-fin-doc.payer-code-schet    = (if available buf_payer-fin-schet
                                       then buf_payer-fin-schet.code-schet
                                       else 0)
          tt-fin-doc.payer-r-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.payer-c-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = (if available buf_payer-firm then buf_payer-firm.director else '')
          tt-fin-doc.payer-sign2         = (if available buf_payer-firm then buf_payer-firm.gen-acct else '')
          tt-fin-doc.vid-plat            = {&fin-vp-electronic}
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in
            .
        end.
      end.
    when {&FDEDT_Expense_Cashless} then 
      do:
        assign
          tt-fin-doc.curr-code           = 0
          tt-fin-doc.payer-type          = {&cmp}
          tt-fin-doc.payer-code          = p-host-code
          tt-fin-doc.payer-inn           = buf_firm.inn
          tt-fin-doc.payer-kpp           = buf_firm.kpp
          tt-fin-doc.payer-name          = buf_clients-host.obj-name
          tt-fin-doc.payer-bank-name     = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bank-name
                                      else '':U)
          tt-fin-doc.payer-bank-city     = (if available buf_payer-fin-bank
                                        then buf_payer-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.payer-bik           = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          tt-fin-doc.payer-code-schet    = if available buf_payer-fin-schet
                                      then buf_payer-fin-schet.code-schet
                                      else 0
          tt-fin-doc.payer-r-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.payer-c-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = buf_firm.director
          tt-fin-doc.payer-sign2         = buf_sysconf.snr-accnt
          tt-fin-doc.ocher-pl            = "6":U
          tt-fin-doc.stat-pl             = "":U
          tt-fin-doc.receiver-type       = (if available buf_receiver then buf_receiver.obj-type else {&cmp})
          tt-fin-doc.receiver-code       = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name       = (if available buf_receiver then buf_receiver.obj-name else "":U)
          tt-fin-doc.receiver-inn        = (if available buf_receiver
                                    then (if buf_receiver.obj-type = {&cmp}
                                          then buf_receiver-firm.inn
                                          else buf_receiver-person.inn )
                                    else "":U)
          tt-fin-doc.receiver-kpp        = (if available buf_receiver
                                      then (if buf_receiver.obj-type = {&cmp}
                                            then buf_receiver-firm.kpp
                                            else buf_receiver-person.kpp )
                                    else "":U)
          tt-fin-doc.receiver-bank-name  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-name
                                        else '':U)
          tt-fin-doc.receiver-bank-city  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.receiver-bik        = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          tt-fin-doc.receiver-code-schet = (if available buf_receiver-fin-schet
                                          then buf_receiver-fin-schet.code-schet
                                          else 0)
          tt-fin-doc.receiver-r-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.receiver-c-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.vid-plat            = {&fin-vp-electronic}
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-out
            .
        end.
      end.
    when {&FDEDT_Income_Payoff} then 
      do:
        assign
          tt-fin-doc.receiver-type  = {&cmp}
          tt-fin-doc.receiver-code  = p-host-code
          tt-fin-doc.receiver-okpo  = buf_firm.okpo
          tt-fin-doc.receiver-name  = buf_clients-host.obj-name
          tt-fin-doc.receiver-sign1 = buf_sysconf.head-position + {&delim-par} + buf_firm.director
          tt-fin-doc.payer-sign1    = (if available buf_payer
                            and buf_payer.obj-type = {&cmp}
                            then buf_payer-firm.director
                            else (if available buf_payer
                                  then buf_payer.obj-name
                                  else "":U
                                )
                            )
          tt-fin-doc.payer-type     = (if available buf_payer then buf_payer.obj-type else {&cmp})
          tt-fin-doc.payer-code     = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name     = (if available buf_payer then buf_payer.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in-payoff
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in-payoff
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in-payoff
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-in-payoff
            .
        end.
      end.
    when {&FDEDT_Expense_Payoff} then 
      do:
        assign
          tt-fin-doc.payer-type     = {&cmp}
          tt-fin-doc.payer-code     = p-host-code
          tt-fin-doc.payer-okpo     = buf_firm.okpo
          tt-fin-doc.payer-name     = buf_clients-host.obj-name
          tt-fin-doc.payer-sign1    = buf_sysconf.head-position + {&delim-par} + buf_firm.director
          tt-fin-doc.receiver-sign1 = (if available buf_receiver
                              and buf_receiver.obj-type = {&cmp}
                              then buf_receiver-firm.director
                              else (if available buf_receiver
                                    then buf_receiver.obj-name
                                    else "":U
                                    )
                            )
          tt-fin-doc.receiver-type  = (if available buf_receiver then buf_receiver.obj-type else {&cmp})
          tt-fin-doc.receiver-code  = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name  = (if available buf_receiver then buf_receiver.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then 
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out-payoff
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out-payoff
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-out-payoff
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-out-payoff
            .
        end.
      end.
  END CASE.
end. /*if add-def*/

run get-fin-code-descr in this-procedure (
  input {&add-def}
  ,input tt-fin-doc.cor-acc1
  ,input tt-fin-doc.cor-acc
  ,input tt-fin-doc.an-uchet-code
  ,input tt-fin-doc.cel-nazn-code
  ,input-output tt-fin-doc.cor-acc1-value
  ,input-output tt-fin-doc.cor-acc-value
  ,input-output tt-fin-doc.an-uchet-value
  ,input-output tt-fin-doc.cel-nazn-value
  ,output f-cor-acc1-descr
  ,output f-cor-acc-descr
  ,output f-an-uchet-descr
  ,output f-cel-nazn-descr
  ).
if p-mode <> {&add-def} then 
do:
  run get-fin-code-descr in this-procedure (
    input {&lookup}
    ,input ttc-fin-doc.cor-acc1
    ,input ttc-fin-doc.cor-acc
    ,input ttc-fin-doc.an-uchet-code
    ,input ttc-fin-doc.cel-nazn-code
    ,input-output ttc-fin-doc.cor-acc1-value
    ,input-output ttc-fin-doc.cor-acc-value
    ,input-output ttc-fin-doc.an-uchet-value
    ,input-output ttc-fin-doc.cel-nazn-value
    ,output fc-cor-acc1-descr
    ,output fc-cor-acc-descr
    ,output fc-an-uchet-descr
    ,output fc-cel-nazn-descr
    ).
end.



/*сохраним значения до прохода по контракту - это позволит нам отследить не устарелим ли данные в контракте*/
create buf_nc-tt-fin-doc.
if p-mode = {&add-def} then
  buffer-copy tt-fin-doc to buf_nc-tt-fin-doc.
else
  buffer-copy ttc-fin-doc to buf_nc-tt-fin-doc.

/*зполним контрактную часть*/
if (p-mode = {&add-def}
  and p-contract-code <> 0)
  or
  (p-mode <> {&add-def}
  and tt-fin-doc.status_ <> {&fin-fact}
  and tt-fin-doc.contract-code <> 0)
  then 
do:

  if p-mode = {&add-def} then 
  do:
    run ref/finfcont.p (
      input parparentproc
      ,input p-host-code
      ,input p-mode
      ,input tt-fin-doc.fin-doc-code
      ,input tt-fin-doc.fin-doc-type
      ,input tt-fin-doc.fin-ext-doc-type
      ,input (if p-mode = {&add-def}
      then p-contract-code
      else tt-fin-doc.contract-code)
      ,input-output table tt-fin-doc )
      no-error .
  end.
  else 
  do:
    run ref/finfcont.p (
      input parparentproc
      ,input p-host-code
      ,input p-mode
      ,input tt-fin-doc.fin-doc-code
      ,input tt-fin-doc.fin-doc-type
      ,input tt-fin-doc.fin-ext-doc-type
      ,input (if p-mode = {&add-def}
      then p-contract-code
      else tt-fin-doc.contract-code)
      ,input-output table tt-fin-doc
      )
      no-error .
  end.
  if error-status:error then 
  do:
    if p-mode = {&add-def}
      and return-value = "exit":U then undo, return error "exit":U .
    else 
    do:
      undo, return error ( substitute("Ошибка при заполнении реквизитов платежа согласно контракту&1&2 &3"
        , {&new-line}
        ,(if return-value <> "":U then return-value else "":U)
        ,error-status:get-message(1))).
    end.
  end.
  if not avail tt-fin-doc then 
  do:
    find first tt-fin-doc.
  end.
end. /*заполнение контрактных полей*/

if tt-fin-doc.contract-code <> 0 then 
do:
  find first buf_contract where
    buf_contract.host-code = p-host-code
    AND buf_contract.contract-code = tt-fin-doc.contract-code  no-error .
  if not available buf_contract then 
  do:
    undo, return error substitute ("&1 &2 &3&4Неверный параметр p-contract-code или значение поля contract-code &5"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,{&new-line}
      ,tt-fin-doc.contract-code).
  end.
  assign
    v-curr-code = buf_contract.curr-code
    .
  /*здесь снова надо проверить все поля но уже перезаполненные контрактами*/
  if (tt-fin-doc.payer-type <> '':U
    and tt-fin-doc.payer-code <> 0)
    then 
  do:
    FIND FIRST buf_payer NO-LOCK WHERE
      buf_payer.obj-type = tt-fin-doc.payer-type
      AND buf_payer.obj-code = tt-fin-doc.payer-code NO-ERROR .
    if not avail buf_payer then 
    do:
      undo, return error substitute("&1& 2& 3&4 Неверный ПЛАТЕЛЬЩИК &5&6 в контракте &7"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,{&new-line}
        ,tt-fin-doc.payer-type
        ,tt-fin-doc.payer-code
        ,buf_contract.contract-code
        ).
    end.
    if buf_payer.obj-type = {&cmp} then 
    do:
      find first buf_payer-firm no-lock where
        buf_payer-firm.firm-code = buf_payer.obj-code.
    end.
    else 
    do:
      find first buf_payer-person no-lock where
        buf_payer-person.psn-code = buf_payer.obj-code.
    end.
  end.
  if tt-fin-doc.receiver-type <> '':U
    and tt-fin-doc.receiver-code <> 0
    then 
  do:
    FIND FIRST buf_receiver WHERE
      buf_receiver.obj-type = tt-fin-doc.receiver-type
      AND buf_receiver.obj-code = tt-fin-doc.receiver-code NO-LOCK .
    if not avail buf_receiver then 
    do:
      undo, return error substitute("&1& 2& 3&4 Неверный ПОЛУЧАТЕЛЬ &5&6 в контракте &7"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,{&new-line}
        ,tt-fin-doc.receiver-type
        ,tt-fin-doc.receiver-code
        ,buf_contract.contract-code
        ).
    end.
    if buf_receiver.obj-type = {&cmp} then 
    do:
      find first buf_receiver-firm no-lock where
        buf_receiver-firm.firm-code = buf_receiver.obj-code.
    end.
    else 
    do:
      find first buf_receiver-person no-lock where
        buf_receiver-person.psn-code = buf_receiver.obj-code.
    end.
  end.
  /*блок проверки счетов по безналу*/
  if p-fin-doc-type = {&income-cashless}
    or p-fin-doc-type = {&expense-cashless} then 
  do:
    if tt-fin-doc.payer-code-schet <> 0
      then 
    do:
      find first buf_payer-fin-schet no-lock where
        buf_payer-fin-schet.host-code = p-host-code
        AND  buf_payer-fin-schet.code-schet = tt-fin-doc.payer-code-schet no-error .
      if available buf_payer-fin-schet then 
      do:
        find first buf_payer-fin-bank no-lock where
          buf_payer-fin-bank.host-code = p-host-code
          AND  buf_payer-fin-bank.code-bank = buf_payer-fin-schet.code-bank no-error .
        if not available buf_payer-fin-bank then 
        do:
          undo, return error substitute("&1 &2 &3&4Неверный счет ПЛАТЕЛЬЩИКА &5 в контракте &6 &7"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            ,buf_payer-fin-schet.code-schet
            ,buf_contract.contract-code
            ,(if not available buf_payer-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if not available buf_payer-fin-schet
        or not (buf_payer-fin-schet.cli-type = tt-fin-doc.payer-type
        and
        buf_payer-fin-schet.cli-code = tt-fin-doc.payer-code)
        or  (p-fin-doc-type = {&expense-cashless}
        and not(buf_payer-fin-schet.cli-type = {&cmp}
        AND
        buf_payer-fin-schet.cli-code = p-host-code)
        )
        then 
      do:
        undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
          ,vss-workfile
          ,vss-revision
          ,vss-description
          ,{&new-line}
          ,buf_payer-fin-schet.code-schet
          ,buf_contract.contract-code
          ,(if not available buf_payer-fin-schet then "Не найден такой счет" else '':U)
          ).

      end.
      if p-mode = {&add-def}
        and available buf_payer-fin-schet
        and buf_payer-fin-schet.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПЛАТЕЛЬЩИКА &2&3 &4"
          ,p-payer-code-schet
          ,buf_payer-fin-schet.cli-type
          ,buf_payer-fin-schet.cli-code
          ,buf_payer-fin-schet.status_
          ).
      end.
      if p-mode = {&add-def}
        and available buf_payer-fin-bank
        and buf_payer-fin-bank.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_payer-fin-bank.code-bank
          ,buf_payer-fin-bank.status_).
      end.
    end.
    if tt-fin-doc.receiver-code-schet <> 0
      then 
    do:
      find first buf_receiver-fin-schet no-lock where
        buf_receiver-fin-schet.host-code = p-host-code
        AND  buf_receiver-fin-schet.code-schet = tt-fin-doc.receiver-code-schet no-error .
      if available buf_receiver-fin-schet then 
      do:
        find first buf_receiver-fin-bank no-lock where
          buf_receiver-fin-bank.host-code = tt-fin-doc.host-code
          AND  buf_receiver-fin-bank.code-bank = buf_receiver-fin-schet.code-bank .
        if not available buf_receiver-fin-bank then 
        do:
          undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            ,buf_receiver-fin-schet.code-schet
            ,buf_payer-fin-bank.code-bank
            ,(if not available buf_receiver-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if not available buf_receiver-fin-schet
        OR (not (buf_receiver-fin-schet.cli-type = tt-fin-doc.receiver-type
        and
        buf_receiver-fin-schet.cli-code = tt-fin-doc.receiver-code)
        )
        or
        (p-fin-doc-type = {&income-cashless}
        and not (
        buf_receiver-fin-schet.cli-type = {&cmp}
        AND
        buf_receiver-fin-schet.cli-code = p-host-code)
        )
        then 
      do:
        undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
          ,vss-workfile
          ,vss-revision
          ,vss-description
          ,{&new-line}
          ,tt-fin-doc.receiver-code-schet
          ,buf_payer-fin-bank.code-bank
          ,(if not available buf_receiver-fin-schet then "Не найден такой счет" else '':U)
          ).
      end.
      if p-mode = {&add-def}
        and available buf_receiver-fin-schet
        and buf_receiver-fin-schet.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПОЛУЧАТЕЛЯ &2&3 &4"
          ,p-receiver-code-schet
          ,buf_receiver-fin-schet.cli-type
          ,buf_receiver-fin-schet.cli-code
          ,buf_receiver-fin-schet.status_
          ).
      end.
      if p-mode = {&add-def}
        and available buf_receiver-fin-bank
        and buf_receiver-fin-bank.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_receiver-fin-bank.code-bank
          ,buf_receiver-fin-bank.status_).
      end.
    end.
  end. /* безналичные*/
  run get-fin-code-descr in this-procedure (
    input {&add-def}
    ,input tt-fin-doc.cor-acc1
    ,input tt-fin-doc.cor-acc
    ,input tt-fin-doc.an-uchet-code
    ,input tt-fin-doc.cel-nazn-code
    ,input-output tt-fin-doc.cor-acc1-value
    ,input-output tt-fin-doc.cor-acc-value
    ,input-output tt-fin-doc.an-uchet-value
    ,input-output tt-fin-doc.cel-nazn-value
    ,output f-cor-acc1-descr
    ,output f-cor-acc-descr
    ,output f-an-uchet-descr
    ,output f-cel-nazn-descr
    ).
end. /*if tt-fin-doc.contract-code <> 0 then do:*/
if tt-fin-doc.status_ <> {&fin-fact} then 
do:
  /*создадим записи во временной таблице которая покажет нам изменения каких полей нам интересны*/
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-name"
    , input "ПЛАТЕЛЬЩИК"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).
  if tt-fin-doc.fin-ext-doc-type <> {&FDEDT_expense_cash}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_income_cash}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_income_payoff}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_expense_payoff}
    then 
  do:
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "payer-inn"
      , input "{&abbr_inn_allshift} ПЛАТЕЛЬЩИКА"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "payer-kpp"
      , input "{&abbr_kpp_allshift} ПЛАТЕЛЬЩИКА"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-bank-name"
    , input "БАНК ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-bik"
    , input "БИК ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-bank-city"
    , input "Город банка ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-r-schet"
    , input "Р/С ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-c-schet"
    , input "К/С ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet'
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "payer-code-schet"
    , input "Внутр. код счета ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).

  CASE tt-fin-doc.fin-ext-doc-type:
    when {&FDEDT_income_cash} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-okpo"
          , input "ОКПО"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).

        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-sign2"
          , input "Гл. бухгалтер"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-sign3"
          , input "Кассир"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when {&FDEDT_expense_cash} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-okpo"
          , input "ОКПО"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).

        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign1"
          , input "Директор"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign2"
          , input "Гл.бухгалтер"
          , input (p-limit-access < 1)
          , input no
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign3"
          , input "Кассир"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when {&FDEDT_income_cashless} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign1"
          , input "Подпись плательщика 1"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign2"
          , input "Подпись плательщика 2"
          , input (p-limit-access < 10)
          , input '':U
          , input yes
          ).
      end.
    when {&FDEDT_expense_cashless} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign1"
          , input "Подпись плательщика 1"
          , input (p-limit-access < 1)
          , input '':U
          , input yes

          ).
      /*
      run tempchgs-create-lable-record in this-procedure (
                                                          input {&table_fin-doc}
                                                        , input "payer-sign2"
                                                        , input "Подпись плательщика 2"
                                                        , input (p-limit-access < 1)
                                                        , input '':U
                                                        , input yes
                                                        ).*/
      end.
    when {&FDEDT_income_payoff} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-okpo"
          , input "ОКПО (ПОЛУЧАТЕЛЯ)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).


        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign1"
          , input "Подпись ПЛАТЕЛЬЩИКА (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-sign1"
          , input "Подпись ПОЛУЧАТЕЛЯ (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when {&FDEDT_expense_payoff} then 
      do:
        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-okpo"
          , input "ОКПО (ПЛАТЕЛЬЩИКА)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).

        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "payer-sign1"
          , input "Подпись ПЛАТЕЛЬЩИКА (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).

        run tempchgs-create-lable-record in this-procedure (
          input {&table_fin-doc}
          , input "receiver-sign1"
          , input "Подпись ПОЛУЧАТЕЛЯ (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
  END CASE.
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-name"
    , input "ПОЛУЧАТЕЛЬ"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).

  if tt-fin-doc.fin-ext-doc-type <> {&FDEDT_expense_cash}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_income_cash}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_income_payoff}
    and tt-fin-doc.fin-ext-doc-type <> {&FDEDT_expense_payoff}
    then 
  do:
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "receiver-inn"
      , input "{&abbr_inn_allshift} ПОЛУЧАТЕЛЯ"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "receiver-kpp"
      , input "{&abbr_kpp_allshift} ПОЛУЧАТЕЛЯ"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-code-schet"
    , input "Внутр. код счета ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-bank-name"
    , input "Банк ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-bank-city"
    , input "Город банка ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-bik"
    , input "БИК ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-r-schet"
    , input "Р/С ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "receiver-c-schet"
    , input "К/С ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  if tt-fin-doc.fin-ext-doc-type <> {&FDEDT_expense_cashless}
    and  tt-fin-doc.fin-ext-doc-type <> {&FDEDT_income_cashless} then 
  do:
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "cor-acc1-value"
      , input "Корсчет касса"
      , input (p-limit-access < 10)
      , input 'cor-acc1':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input {&table_fin-doc}
      , input "cor-acc1"
      , input "Корсчет касса (внутр. №)"
      , input (p-limit-access < 10)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "cor-acc-value"
    , input "Корсчет кредит"
    , input (p-limit-access < 10)
    , input 'cor-acc':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "cor-acc"
    , input "Корсчет кредит (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "an-uchet-value"
    , input "Код ан. учета"
    , input (p-limit-access < 10)
    , input 'an-uchet-code':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "an-uchet-code"
    , input "Код ан. учета (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "cel-nazn-value"
    , input "Код целевого назнач."
    , input (p-limit-access < 10)
    , input 'cel-nazn-code':U
    , input yes
    ).

  run tempchgs-create-lable-record in this-procedure (
    input {&table_fin-doc}
    , input "cel-nazn-code"
    , input "Код целевого назнач. (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).
  if p-mode = {&update}
    or p-mode = {&lookup}
    then 
  do:
    run ref/view-chg.w ( input parparentproc
      ,input this-procedure:handle
      ,input {&table_fin-doc}
      ,input buffer ttc-fin-doc:handle
      ,input buffer tt-fin-doc:handle
      ,input p-mode
      ,input p-limit-access
      ,input substitute("Несоответствия в реквизитах платежа &1, вызванные изменениями справочников системы и/или договора"
      , tt-fin-doc.fin-doc-code) /*p-title*/
      ,input "В платеже"
      ,input "Текущ.рек-ты справочников(договора)"
      ,input '':U /*на будущее - 3 -я колонка*/
      ,input (if p-mode = {&update}
      then substitute("Вы можете подтвердить изменения, если они не противоречат статусу платежа (выделенные поля)&1" +
      "изменения реквизитов, которые не могут быть подтверждены в данном статусе, запрещены (серые поля)"
      , {&new-line})
      else substitute("Увидеть какие изменения могут быть подтверждены в текущем статусе платежа,&1можно ТОЛЬКО в режиме редактирования"
      , {&new-line})
      ) /*p-descr*/
      ,output v-ok
      ) no-error .
    if error-status:error then 
    do:
    end.
    if p-mode <> {&lookup}
      and v-ok
      then 
    do:
      for each temp-labels where temp-labels.f_update :
        if temp-labels.f_update then
          assign
            buffer ttc-fin-doc:buffer-field(temp-labels.f_name):buffer-value = buffer tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value
            .
      end.
    end.
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input ttc-fin-doc.payer-code-schet
      ,input ttc-fin-doc.receiver-code-schet
      ,input ttc-fin-doc.payer-type
      ,input ttc-fin-doc.payer-code
      ,input ttc-fin-doc.receiver-type
      ,input ttc-fin-doc.receiver-code
      ,input p-mode <> {&lookup} /*refill if need*/
      ,input-output ttc-fin-doc.payer-bank-name
      ,input-output ttc-fin-doc.receiver-bank-name
      ,input-output ttc-fin-doc.payer-bank-city
      ,input-output ttc-fin-doc.receiver-bank-city
      ,input-output ttc-fin-doc.payer-bik
      ,input-output ttc-fin-doc.receiver-bik
      ,input-output ttc-fin-doc.payer-r-schet
      ,input-output ttc-fin-doc.receiver-r-schet
      ,input-output ttc-fin-doc.payer-c-schet
      ,input-output ttc-fin-doc.receiver-c-schet
      ) no-error .
    if error-status:error then 
    do:
      undo, return error return-value .
    end.
    run get-fin-code-descr in this-procedure (
      input p-mode
      ,input ttc-fin-doc.cor-acc1
      ,input ttc-fin-doc.cor-acc
      ,input ttc-fin-doc.an-uchet-code
      ,input ttc-fin-doc.cel-nazn-code
      ,input-output ttc-fin-doc.cor-acc1-value
      ,input-output ttc-fin-doc.cor-acc-value
      ,input-output ttc-fin-doc.an-uchet-value
      ,input-output ttc-fin-doc.cel-nazn-value
      ,output f-cor-acc1-descr
      ,output f-cor-acc-descr
      ,output f-an-uchet-descr
      ,output f-cel-nazn-descr
      ).
  end.
  if p-mode = {&add-def}
    and v-copy-mode = yes
    then 
  do:
    run ref/view-chg.w ( input parparentproc
      ,input this-procedure:handle
      ,input {&table_fin-doc}
      ,input buffer tt-fin-doc:handle
      ,input buffer buf_a0-tt-fin-doc:handle
      ,input p-mode
      ,input p-limit-access
      ,input substitute("Несоответствия в реквизитах платежа &1, вызванные изменениями в справочниках системы и/или договора"
      , tt-fin-doc.fin-doc-code) /*p-title*/
      ,input "В платеже в соотв. с Текущ.рек-ми справочников(договора)"
      ,input substitute("В платеже-ОРИГИНАЛЕ")
      ,input "":U
      ,input  substitute("Вы можете подтвердить изменения, если они не противоречат статусу платежа (выделенные поля)&1" +
      "изменения реквизитов, которые не могут быть подтверждены в данном статусе, запрещены (серые поля)"
      , {&new-line}) /*p-descr*/
      ,output v-ok
      ) no-error .
    if v-ok then 
    do:
      for each temp-labels where temp-labels.f_update = yes:
        assign
          buffer tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value = buffer buf_a0-tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value
          .
      end.
    end.
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input tt-fin-doc.payer-code-schet
      ,input tt-fin-doc.receiver-code-schet
      ,input tt-fin-doc.payer-type
      ,input tt-fin-doc.payer-code
      ,input tt-fin-doc.receiver-type
      ,input tt-fin-doc.receiver-code
      ,input yes /*refill if need*/
      ,input-output tt-fin-doc.payer-bank-name
      ,input-output tt-fin-doc.receiver-bank-name
      ,input-output tt-fin-doc.payer-bank-city
      ,input-output tt-fin-doc.receiver-bank-city
      ,input-output tt-fin-doc.payer-bik
      ,input-output tt-fin-doc.receiver-bik
      ,input-output tt-fin-doc.payer-r-schet
      ,input-output tt-fin-doc.receiver-r-schet
      ,input-output tt-fin-doc.payer-c-schet
      ,input-output tt-fin-doc.receiver-c-schet

      ) no-error .
    if error-status:error then 
    do:
      undo, return error return-value .
    end.
    run get-fin-code-descr in this-procedure (
      input {&update}
      ,input tt-fin-doc.cor-acc1
      ,input tt-fin-doc.cor-acc
      ,input tt-fin-doc.an-uchet-code
      ,input tt-fin-doc.cel-nazn-code
      ,input-output tt-fin-doc.cor-acc1-value
      ,input-output tt-fin-doc.cor-acc-value
      ,input-output tt-fin-doc.an-uchet-value
      ,input-output tt-fin-doc.cel-nazn-value
      ,output f-cor-acc1-descr
      ,output f-cor-acc-descr
      ,output f-an-uchet-descr
      ,output f-cel-nazn-descr
      ).
  end.
end. /*статус не факт*/
if  tt-fin-doc.status_ = {&fin-fact}
  or (p-mode = {&add-def}
  and v-copy-mode = no) then 
do:
  run get-fin-schet  in this-procedure (
    buffer buf_payer-fin-schet
    ,buffer buf_receiver-fin-schet
    ,buffer buf_payer-fin-bank
    ,buffer buf_receiver-fin-bank
    ,input tt-fin-doc.payer-code-schet
    ,input tt-fin-doc.receiver-code-schet
    ,input tt-fin-doc.payer-type
    ,input tt-fin-doc.payer-code
    ,input tt-fin-doc.receiver-type
    ,input tt-fin-doc.receiver-code
    ,input (tt-fin-doc.status_ <> {&fin-fact}) /*refill if need*/
    ,input-output tt-fin-doc.payer-bank-name
    ,input-output tt-fin-doc.receiver-bank-name
    ,input-output tt-fin-doc.payer-bank-city
    ,input-output tt-fin-doc.receiver-bank-city
    ,input-output tt-fin-doc.payer-bik
    ,input-output tt-fin-doc.receiver-bik
    ,input-output tt-fin-doc.payer-r-schet
    ,input-output tt-fin-doc.receiver-r-schet
    ,input-output tt-fin-doc.payer-c-schet
    ,input-output tt-fin-doc.receiver-c-schet

    ).


  run get-fin-code-descr in this-procedure (
    input {&add-def}
    ,input tt-fin-doc.cor-acc1
    ,input tt-fin-doc.cor-acc
    ,input tt-fin-doc.an-uchet-code
    ,input tt-fin-doc.cel-nazn-code
    ,input-output tt-fin-doc.cor-acc1-value
    ,input-output tt-fin-doc.cor-acc-value
    ,input-output tt-fin-doc.an-uchet-value
    ,input-output tt-fin-doc.cel-nazn-value
    ,output f-cor-acc1-descr
    ,output f-cor-acc-descr
    ,output f-an-uchet-descr
    ,output f-cel-nazn-descr
    ).

end.

/*установим буфера наверху*/

/*
run set-buffers in par-call-handle(
                                  BUFFER buf_clients-host:handle
                                  ,BUFFER buf_firm:handle
                                  ,BUFFER buf_sysconf:handle
                                  ,buffer buf_fin-code-cor-acc:handle
                                  ,buffer buf_fin-code-an-uchet:handle
                                  ,buffer buf_fin-code-cel-nazn:handle
                                  ,buffer buf_currency:handle
                                  ,buffer buf_contract-currency:handle
                                  ,BUFFER buf_receiver:handle
                                  ,BUFFER buf_payer:handle
                                  ,buffer buf_curr_sysconf:handle
                                  ,buffer buf_payer-fin-schet:handle
                                  ,buffer buf_payer-fin-bank:handle
                                  ,buffer buf_payer-firm:handle
                                  ,buffer buf_payer-person:handle
                                  ,buffer buf_receiver-fin-schet:handle
                                  ,buffer buf_receiver-fin-bank:handle
                                  ,buffer buf_receiver-firm:handle
                                  ,buffer buf_receiver-person:handle
                                  ,buffer buf_contract:handle
                                  ,buffer buf_fin-ob:handle
                                  ,buffer buf_clients-obj:handle ).*/
if valid-handle(par-call-handle) then
  run set-buffers in par-call-handle(
    input recid(buf_clients-host)
    ,input recid(buf_firm)
    ,input recid(buf_sysconf)
    ,input recid(buf_fin-code-cor-acc)
    ,input recid(buf_fin-code-cor-acc1)
    ,input recid(buf_fin-code-an-uchet)
    ,input recid(buf_fin-code-cel-nazn)
    ,input recid(buf_currency)
    ,input recid(buf_contract-currency)
    ,input recid(buf_receiver)
    ,input recid(buf_payer)
    ,input recid(buf_curr_sysconf)
    ,input recid(buf_payer-fin-schet)
    ,input recid(buf_payer-fin-bank)
    ,input recid(buf_payer-firm)
    ,input recid(buf_payer-person)
    ,input recid(buf_receiver-fin-schet)
    ,input recid(buf_receiver-fin-bank)
    ,input recid(buf_receiver-firm)
    ,input recid(buf_receiver-person)
    ,input recid(buf_contract)
    ,input recid(buf_fin-ob)
    ,input recid(buf_clients-obj)
    ,input f-cor-acc1-descr
    ,input f-cor-acc-descr
    ,input f-an-uchet-descr
    ,input f-cel-nazn-descr
    ) no-error .
if p-mode = {&add-def} then 
do:
  for each buf_tt-fin-doc no-lock where
    buf_tt-fin-doc.host-code = p-host-code
    AND buf_tt-fin-doc.fin-doc-code = v-fin-doc-code:
    find first tt0-fin-doc where
      tt0-fin-doc.host-code = p-host-code
      AND tt0-fin-doc.fin-doc-code = 0 no-error.
    if not available tt0-fin-doc then 
    do:
      create tt0-fin-doc.
    end.
    buffer-copy buf_tt-fin-doc to tt0-fin-doc.
    release tt0-fin-doc.
  END.
end.
if p-mode = {&update} then 
do:
  for each bufc_ttc-fin-doc no-lock where
    bufc_ttc-fin-doc.host-code = p-host-code
    AND bufc_ttc-fin-doc.fin-doc-code = v-fin-doc-code:
    find first tt0c-fin-doc where
      tt0c-fin-doc.host-code = p-host-code
      AND tt0c-fin-doc.fin-doc-code = v-fin-doc-code no-error.
    if not available tt0c-fin-doc then 
    do:
      create tt0c-fin-doc.
    end.
    buffer-copy bufc_ttc-fin-doc to tt0c-fin-doc.
    release tt0c-fin-doc.
  END.
end.
end.

procedure get-fin-code-descr :
  define input parameter p-mode as character no-undo .
  define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo .
  define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo .
  define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo .
  define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo .
  define input-output parameter p-cor-acc1-value like ub.fin-doc.cor-acc1-value no-undo .
  define input-output parameter p-cor-acc-value like ub.fin-doc.cor-acc-value no-undo .
  define input-output parameter p-an-uchet-value like ub.fin-doc.an-uchet-value no-undo .
  define input-output parameter p-cel-nazn-value like ub.fin-doc.cel-nazn-value no-undo .
  define output parameter f-cor-acc1-descr as character no-undo .
  define output parameter f-cor-acc-descr as character no-undo .
  define output parameter f-an-uchet-descr as character no-undo .
  define output parameter f-cel-nazn-descr as character no-undo .

  define variable v-cor-acc1-value like ub.fin-doc.cor-acc1-value no-undo .
  define variable v-cor-acc-value  like ub.fin-doc.cor-acc-value no-undo .
  define variable v-an-uchet-value like ub.fin-doc.an-uchet-value no-undo .
  define variable v-cel-nazn-value like ub.fin-doc.cel-nazn-value no-undo .

  if p-cor-acc1 = ? then p-cor-acc1 = 0.
  if p-cor-acc = ? then p-cor-acc = 0.
  if p-an-uchet-code = ? then p-an-uchet-code = 0 .
  if p-cel-nazn-code = ? then p-cel-nazn-code = 0 .
  assign
    f-cor-acc1-descr = '':U
    f-cor-acc-descr  = '':U
    f-an-uchet-descr = '':U
    f-cel-nazn-descr = '':U
    .

  if tt-fin-doc.fin-ext-doc-type = {&income-cash}
    or tt-fin-doc.fin-ext-doc-type = {&expense-cash}
    or tt-fin-doc.fin-ext-doc-type = {&income-payoff}
    or tt-fin-doc.fin-ext-doc-type = {&expense-payoff} then 
  do:
    if p-cor-acc1 <> 0 then 
    do:
      find first buf_fin-code-cor-acc1 no-lock where
        buf_fin-code-cor-acc1.fin-code  = p-cor-acc1
        AND buf_fin-code-cor-acc1.host-code  = tt-fin-doc.host-code
        no-error.
      if available buf_fin-code-cor-acc1
        and buf_fin-code-cor-acc1.status_ = integer({&current-status-int}) then 
      do:
        assign
          f-cor-acc1-descr = buf_fin-code-cor-acc1.descr
          v-cor-acc1-value = buf_fin-code-cor-acc1.code-value
          .
      end.
      if not available buf_fin-code-cor-acc1
        or (buf_fin-code-cor-acc1.code-value <> p-cor-acc1-value and p-mode <> {&add-def} and p-cor-acc1-value = '':U)
        or buf_fin-code-cor-acc1.status_ <> integer({&current-status-int})
        then 
      do:
        assign
          f-cor-acc1-descr = "!!!Код больше не существует"
          .
      end.
      if p-mode <> {&lookup} then 
      do:
        p-cor-acc1-value = v-cor-acc1-value.
      end.
    end.
    else if p-mode <> {&lookup} then 
      do:
        p-cor-acc1-value = '':U.
      end.
  end.

  if p-cor-acc <> 0 then 
  do:
    find first buf_fin-code-cor-acc no-lock where
      buf_fin-code-cor-acc.fin-code  = p-cor-acc
      AND buf_fin-code-cor-acc.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-cor-acc
      and buf_fin-code-cor-acc.status_ = integer({&current-status-int})
      then 
    do:
      assign
        f-cor-acc-descr = buf_fin-code-cor-acc.descr
        v-cor-acc-value = buf_fin-code-cor-acc.code-value
        .
    end.
    if not available buf_fin-code-cor-acc
      or (buf_fin-code-cor-acc.code-value <> p-cor-acc-value and p-mode <> {&add-def} and p-cor-acc-value = '':U)
      or buf_fin-code-cor-acc.status_ <> integer({&current-status-int})
      then 
    do:
      assign
        f-cor-acc-descr = "!!!Код больше не существует"
        .
    end.
    if p-mode <> {&lookup} then 
    do:
      p-cor-acc-value = v-cor-acc-value.
    end.
  end.
  else if p-mode <> {&lookup} then 
    do:
      p-cor-acc-value = '':U.
    end.
  if p-an-uchet-code <> 0 then 
  do:
    find first buf_fin-code-an-uchet no-lock where
      buf_fin-code-an-uchet.fin-code  = p-an-uchet-code
      AND buf_fin-code-an-uchet.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-an-uchet
      and buf_fin-code-an-uchet.status_ = integer({&current-status-int})
      then 
    do:
      assign
        f-an-uchet-descr = buf_fin-code-an-uchet.descr
        v-an-uchet-value = buf_fin-code-an-uchet.code-value
        .
    end.
    if not available buf_fin-code-an-uchet
      or (buf_fin-code-an-uchet.code-value <> p-an-uchet-value and p-mode <> {&add-def} and p-an-uchet-value = '':U)
      or buf_fin-code-an-uchet.status_ <> integer({&current-status-int})
      then 
    do:
      assign
        f-an-uchet-descr = "!!!Код больше не существует".
      .
    end.
    if p-mode <> {&lookup} then 
    do:
      p-an-uchet-value = v-an-uchet-value.
    end.
  end.
  else if p-mode <> {&lookup} then 
    do:
      p-an-uchet-value = '':U.
    end.
  if p-cel-nazn-code <> 0 then 
  do:
    find first buf_fin-code-cel-nazn no-lock where
      buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code
      AND buf_fin-code-cel-nazn.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-cel-nazn
      and buf_fin-code-cel-nazn.status_ = integer({&current-status-int})
      then 
    do:
      assign
        f-cel-nazn-descr = buf_fin-code-cel-nazn.descr
        v-cel-nazn-value = Buf_fin-code-cel-nazn.code-value
        .
    end.
    if not available buf_fin-code-cel-nazn
      or (buf_fin-code-cel-nazn.code-value <> p-cel-nazn-value and p-mode <> {&add-def} and p-cel-nazn-value = '':U)
      or buf_fin-code-cel-nazn.status_ <> integer({&current-status-int})
      then 
    do:
      assign
        f-cel-nazn-descr = "!!!Код больше не существует"
        .
    end.
    if p-mode <> {&lookup} then 
    do:
      p-cel-nazn-value = v-cel-nazn-value.
    end.
  end.
  else if p-mode <> {&lookup} then 
    do:
      p-cel-nazn-value = '':U.
    end.

/*end проверка кодов учета*/

end procedure. /* get-fin-code-descr */

procedure get-fin-schet :
  define parameter buffer buf_payer-fin-schet    for ub.fin-schet  .
  define parameter buffer buf_receiver-fin-schet for ub.fin-schet .
  define parameter buffer buf_payer-fin-bank     for ub.fin-bank  .
  define parameter buffer buf_receiver-fin-bank  for ub.fin-bank  .
  define input parameter p-payer-code-schet like ub.fin-schet.code-schet no-undo .
  define input parameter p-receiver-code-schet like ub.fin-schet.code-schet no-undo .
  define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
  define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
  define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
  define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
  define input parameter p-refill-if-nees as logical no-undo .
  define input-output parameter p-payer-bank-name like ub.fin-doc.payer-bank-name no-undo .
  define input-output parameter p-receiver-bank-name like ub.fin-doc.receiver-bank-name no-undo .
  define input-output parameter p-payer-bank-city like ub.fin-doc.payer-bank-city no-undo .
  define input-output parameter p-receiver-bank-city like ub.fin-doc.receiver-bank-city no-undo .
  define input-output parameter p-payer-bik like ub.fin-doc.payer-bik no-undo .
  define input-output parameter p-receiver-bik like ub.fin-doc.receiver-bik no-undo .
  define input-output parameter p-payer-r-schet like ub.fin-doc.payer-r-schet no-undo .
  define input-output parameter p-receiver-r-schet like ub.fin-doc.receiver-r-schet no-undo .
  define input-output parameter p-payer-c-schet like ub.fin-doc.payer-c-schet no-undo .
  define input-output parameter p-receiver-c-schet like ub.fin-doc.receiver-c-schet no-undo .


  define variable v-refill-payer    as logical no-undo .
  define variable v-refill-receiver as logical no-undo .

  do
    on error undo, return error
    :
    if p-fin-ext-doc-type <> {&income-cashless}
      and p-fin-ext-doc-type <> {&expense-cashless} then return.
    if (not available buf_payer-fin-schet and  p-payer-code-schet <> 0 and p-payer-code-schet <> ?)
      or (available buf_payer-fin-schet and p-payer-code-schet <> buf_payer-fin-schet.code-schet) then 
    do:
      if p-payer-code-schet = 0
        or p-payer-code-schet = ? then  
      do:
        release buf_payer-fin-schet.
        release buf_payer-fin-bank.
        v-refill-payer = yes.
      end.
      else 
      do:
        v-refill-payer = yes.
        find first buf_payer-fin-schet no-lock where
          buf_payer-fin-schet.host-code = p-host-code
          AND  buf_payer-fin-schet.code-schet = p-payer-code-schet  no-error .
        if available buf_payer-fin-schet then 
        do:
          if not available buf_payer-fin-bank
            or buf_payer-fin-bank.code-bank <> buf_payer-fin-schet.code-bank then 
          do:
            find first buf_payer-fin-bank no-lock where
              buf_payer-fin-bank.host-code = p-host-code
              AND  buf_payer-fin-bank.code-bank = buf_payer-fin-schet.code-bank no-error .
          end.
        end. /*        if available buf_payer-fin-schet then do:*/
        if not available buf_payer-fin-schet
          or not available buf_payer-fin-bank
          or (
          (p-mode = {&add-def}
          and
          NOT (p-payer-type = buf_payer-fin-schet.cli-type
          and
          p-payer-code = buf_payer-fin-schet.cli-code  )
          )
          OR (
          p-mode <> {&add-def}
          AND
          not (buf_payer-fin-schet.cli-type = p-payer-type
          and
          buf_payer-fin-schet.cli-code = p-payer-code)
          )
          or
          (p-fin-doc-type = {&expense-cashless}
          and not(buf_payer-fin-schet.cli-type = {&cmp}
          AND
          buf_payer-fin-schet.cli-code = p-host-code)
          ))
          then 
        do:
          undo, return error substitute("&1 &2 &3&4Неверный параметр p-payer-fin-schet или значение поля payer-code-schet &5&4&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            ,buf_payer-fin-schet.code-schet
            ,(if not available buf_payer-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end. /* payer-code-schet <> 0 */
      if p-mode = {&add-def}
        and available buf_payer-fin-schet
        and buf_payer-fin-schet.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПЛАТЕЛЬЩИКА &2&3 &4"
          ,p-payer-code-schet
          ,buf_payer-fin-schet.cli-type
          ,buf_payer-fin-schet.cli-code
          ,buf_payer-fin-schet.status_
          ).
      end.
      if p-mode = {&add-def}
        and available buf_payer-fin-bank
        and buf_payer-fin-bank.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_payer-fin-bank.code-bank
          ,buf_payer-fin-bank.status_).
      end.
    end. /*    if p-payer-code-schet <> buf_payer-fin-schet.code-schet then do:*/
    if (not available buf_receiver-fin-schet and  p-receiver-code-schet <> 0 and p-receiver-code-schet <> ?)
      or (available buf_receiver-fin-schet and p-receiver-code-schet <> buf_receiver-fin-schet.code-schet) then 
    do:
      if p-receiver-code-schet = 0
        or p-receiver-code-schet = ? then  
      do:
        release buf_receiver-fin-schet.
        release buf_receiver-fin-bank.
        V-REFILL-receiver = yes.
      end.
      else 
      do:
        v-refill-receiver = yes.
        find first buf_receiver-fin-schet no-lock where
          buf_receiver-fin-schet.host-code = p-host-code
          AND  buf_receiver-fin-schet.code-schet = p-receiver-code-schet  no-error .
        if available buf_receiver-fin-schet then 
        do:
          if not available buf_receiver-fin-bank
            or buf_receiver-fin-bank.code-bank <> buf_receiver-fin-schet.code-bank then 
          do:
            find first buf_receiver-fin-bank no-lock where
              buf_receiver-fin-bank.host-code = p-host-code
              AND  buf_receiver-fin-bank.code-bank = buf_receiver-fin-schet.code-bank no-error .
          end.
        end. /*if available buf_receiver-fin-schet then do:*/
        if not available buf_receiver-fin-schet
          or not available buf_receiver-fin-bank
          or (
          (p-mode = {&add-def}
          and
          NOT (p-receiver-type = buf_receiver-fin-schet.cli-type
          and
          p-receiver-code = buf_receiver-fin-schet.cli-code  )
          )
          OR (
          p-mode <> {&add-def}
          AND
          not (buf_receiver-fin-schet.cli-type = p-receiver-type
          and
          buf_receiver-fin-schet.cli-code = p-receiver-code)
          )
          or
          (p-fin-doc-type = {&income-cashless}
          and not (
          buf_receiver-fin-schet.cli-type = {&cmp}
          AND
          buf_receiver-fin-schet.cli-code = p-host-code)
          ))
          then 
        do:
          undo, return error substitute("&1 &2 &3&4Неверный параметр p-receiver-fin-schet или значение поля receiver-code-schet &5&4&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            ,buf_receiver-fin-schet.code-schet
            ,(if not available buf_receiver-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end. /*receiver-code-schet <> 0*/
      if p-mode = {&add-def}
        and available buf_receiver-fin-schet
        and buf_receiver-fin-schet.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПОЛУЧАТЕЛЯ &2&3 &4"
          ,p-receiver-code-schet
          ,buf_receiver-fin-schet.cli-type
          ,buf_receiver-fin-schet.cli-code
          ,buf_receiver-fin-schet.status_
          ).
      end.
      if p-mode = {&add-def}
        and available buf_receiver-fin-bank
        and buf_receiver-fin-bank.status_ <> {&current-status} then 
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_receiver-fin-bank.code-bank
          ,buf_receiver-fin-bank.status_).
      end.
    end. /*if p-receiver-code-schet <> buf_receiver-fin-schet.code-schet then do:*/
    if p-refill-if-nees then 
    do:
      if v-refill-payer then 
      do:
        assign
          p-payer-bank-name = (if available buf_payer-fin-bank
                            then buf_payer-fin-bank.bank-name
                            else '':U)
          p-payer-bank-city = (if available buf_payer-fin-bank
                             then buf_payer-fin-bank.bank-city
                             else '':U)
          p-payer-bik       = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          p-payer-r-schet   = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          p-payer-c-schet   = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          .
      end.
      if v-refill-receiver then 
      do:
        assign
          p-receiver-bank-name = (if available buf_receiver-fin-bank
                            then buf_receiver-fin-bank.bank-name
                            else '':U)
          p-receiver-bank-city = (if available buf_receiver-fin-bank
                             then buf_receiver-fin-bank.bank-city
                             else '':U)
          p-receiver-bik       = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          p-receiver-r-schet   = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          p-receiver-c-schet   = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          .

      end.
    end.

  end. /*doe*/




end procedure. /* get-fin-schet */

