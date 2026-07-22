/*

$Revision: e01c030e3256, 3600, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:36 $
$Workfile: impkass-book.cls $
$Archive: ibs/th/bge/1crn/import/impkass-book.cls $

Класс ипорта данных kass-book (типы кассовых книг) из 1С

Автор: Молотков Сергей
Дата создания: 13/02/19
Author: Molotkov Sergey
Creation date: 13/02/19

*/
&scoped-define impclass kass-book
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} implements ibs.th.bge.1crn.import.iimpsubject: 

  { ibs/th/ref/ttCashBook.i }
  { ibs/th/ref/ttCashBookRule.i }
  
  { cmp/str-glbl.i class } /* &add-def, &update, &deletion, &shop, &attr-cash-book-id, &attr-oper-serv-id */
  /* { gbl/attr-lib.i class } gds-attr-write() заинлайнена */
  
  define private temp-table tt-gds no-undo
    field gds-code as integer
    .
  /*  define private temp-table tt-operserv no-undo like ub.OperServ .*/
  
  define property Msg as character no-undo
    get. 
    set.

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp          as class     {&impclass}                           no-undo.
    define variable v-retfl         as logical   no-undo .
    define variable v-mode          as character no-undo. /* create/update */
    define variable v-storage       as class     ibs.th.ref.cashbookstorage            no-undo .

    define variable v-code          as character no-undo .
    define variable v-basic-kb      as integer   no-undo .
    define variable v-objlist       as class     ibs.th.bge.1crn.subjects.subjects     no-undo . // imp:kb-gds[]
    define variable v-gds-gd        as class     ibs.th.bge.1crn.subjects.kass-book-gd no-undo .
    define variable v-i-counter     as integer   no-undo .
    define variable v-i-num         as integer   no-undo .
    define variable v-stub          as integer   no-undo .
    define variable v-gds-code      as integer   no-undo .
    define variable v-str-kb-id     as character no-undo .
    /*    define variable v-str-ossid as character no-undo .*/
    /*    define variable v-pay-agent as class ibs.th.bge.1crn.subjects.payment-agent no-undo . // imp:payment-agent*/
    define variable v-cashbookid    as int64     no-undo .
    /*    define variable v-operservid as int64 no-undo .*/
    define variable v-commentrytype as integer   no-undo .
    define variable v-host-code     as integer   no-undo .
    define buffer buf_clients          for ub.clients .
    define buffer buf_goods            for ub.goods .
    define buffer buf_goods-attr       for ub.goods-attr .
    /*    define buffer buf_OperServ   for ub.OperServ .*/
    define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc .


    objImp = cast (subjectObj, {&impclass}).

    if objImp:del-f > 0 then
      undo, throw new Progress.Lang.AppError("физичесткое удаление Типа кассовых книг не предусмотрено") .    
    
    /* если код не задан:
         - если пришла с признаком "основная" - то обновляем CashBook.id = 0 и не грузим секцию с товарами;
         - если пришла без признака "основная" - то режим создания с автоматическим присвоением кода;
       если код задан:
         - признак "основная" игнорируется;
         - если код присутствует в БД - режим обновления;
         - если код отсутствует в БД - режим создания;
       логическое удаление - только, если код задан, присутствует в БД, и CashBook.id <> 0.
       
       чтобы при изменении записи не затирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи;
       чтобы при изменении записи не затирать поля из необязательных тегов, которые пришли из 1С, пустыми значениями -
       читаем их значения из исходной записи.
    */
    assign
      v-code     = objImp:code_
      v-basic-kb = objImp:basic-kb
      Msg        = "":U
      .
    empty temp-table tt-cashbook .
    v-storage = new ibs.th.ref.cashbookstorage () .
    if v-basic-kb ne 0 then 
    do :
      v-basic-kb = ? .
      
      v-storage:getcashbook(v-code, output dataset ds-cashbook by-reference) .
      find first tt-cashbook no-error .
      if available tt-cashbook then 
      do :
        v-str-kb-id = string(tt-cashbook.id) .
        /* ТР вер.1.9 4.3.4.1: Удалить – логическое удаление записи справочника; */
        if objImp:del-l > 0 then 
        do :
          if tt-cashbook.id = 0 then undo, throw new Progress.Lang.AppError(        
              substitute("Ошибка логического удаления. Попытка удаления кассовой книги по признаку «Основная деятельность».")
              ) .
          v-mode = {&deletion} .
        end .
        else v-mode = {&update} .
      end .
      else 
      do :
        if objImp:del-l > 0 then 
        do :
          undo, throw new Progress.Lang.AppError(        
            substitute("Ошибка логического удаления. Тип кассовой книги с кодом [&1] отсутствует в БД.", v-code)
            ) .
        end .
        v-mode = {&add-def} .
        create tt-cashbook .
        assign
          tt-cashbook.ext-code = v-code
          .
      end .
    end .
    else 
    do :
      if objImp:del-l > 0 then
        undo, throw new Progress.Lang.AppError("Удаление основной кассовой книги не возможно.").
      v-storage:getcashbook(0, output dataset ds-cashbook by-reference) .
      find first tt-cashbook no-error .
      if available tt-cashbook 
        then 
      do: 
        if     tt-cashbook.ext-code ne "0"
          and tt-cashbook.ext-code ne v-code
          then
          undo, throw new Progress.Lang.AppError(substitute ("Редактирование номера основной кассовой книги во внешней ВС запрещено. Старый номер: &1 Новый номер: &2", tt-cashbook.ext-code, v-code)).
         
        assign
          tt-cashbook.ext-code = v-code
          v-str-kb-id          = "0"
          v-mode               = {&update}
          .
      end.
      else 
      do: 
        v-mode = {&add-def} .
        create tt-cashbook .
        assign
          tt-cashbook.ext-code = v-code
          tt-cashbook.id       = 0
          tt-cashbook.basic-kb = yes
          .
           
      end.  
      
    end.
    
    if v-mode = {&deletion} then 
    do :
      if tt-cashbook.Status_ = 0 /* 0:"Текущий" */ then 
      do : 
        for each buf_goods-attr exclusive-lock
          where buf_goods-attr.attr-code  = {&attr-cash-book-id}
          and buf_goods-attr.attr-value = v-str-kb-id :
          delete buf_goods-attr.
        end .
        /* 21/V-2019 платёжный агент вынесен в отдельную сущность
        find first buf_OperServ exclusive-lock
             where buf_OperServ.ext-code = tt-cashbook.ext-code no-error .
        if available buf_OperServ then do:
          buf_OperServ.Status_ = 1 .
          /* или менять buf_OperServ.Status_ на статус, полученный tt-cashbook внутри v-storage:deleteDB() */
          for each buf_goods-attr exclusive-lock
             where buf_goods-attr.attr-code  = {&attr-oper-serv-id}
               and buf_goods-attr.attr-value = string(buf_OperServ.id) :
            delete buf_goods-attr.
          end .
        end .
        */
        v-storage:deleteDB(input dataset ds-cashbook by-reference) .
      end .
      v-retfl = true.
      return true . /* несмотря на return true, внутри final всё равно сработает return v-retfl */
    end .

    /* Для поиска значений счёта кредита и дебета, а также для взятия контрагента "Тип и код реализации",
       используется host-code.
       Мы ищем какой-нибудь host-code, запоминаем последний найденный, а при его отсутсвии берём как в library.p
    */
    v-host-code = -1 .

    /* проверить счета дебета и кредита по справочнику счетов */
    define variable v-int-schet   as integer   no-undo .
    define variable v-schet-found as logical   no-undo .
    define variable v-code-value  as character no-undo .
    if objImp:kredit <> ? then 
    do :
      v-int-schet = integer (objImp:kredit) no-error .
      v-code-value = objImp:kredit .
      v-schet-found = false .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        if can-find (first buf_fin-code-cor-acc
          where buf_fin-code-cor-acc.host-code  = buf_clients.host-code
          AND buf_fin-code-cor-acc.code-value = v-code-value) then 
        do :
          v-host-code   = buf_clients.host-code .
          v-schet-found = true .
          leave.
        end .
      end .
      if not v-schet-found then
        undo, throw new Progress.Lang.AppError( substitute(
          "Счёт кредита [&1] из кассовой книги [&2 &3] отсутствует в справочнике счетов."
          , objImp:kredit, v-code, objImp:name_
          ) ) .
    end .
    if objImp:kredit-nonop-inc <> ? then 
    do :
      v-int-schet = integer (objImp:kredit-nonop-inc) no-error .
      v-code-value = objImp:kredit-nonop-inc .
      v-schet-found = false .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        if can-find (first buf_fin-code-cor-acc
          where buf_fin-code-cor-acc.host-code  = buf_clients.host-code
          AND buf_fin-code-cor-acc.code-value = v-code-value) then 
        do :
          v-host-code   = buf_clients.host-code .
          v-schet-found = true .
          leave.
        end .
      end .
      if not v-schet-found then
        undo, throw new Progress.Lang.AppError( substitute(
          "Счёт кредита для формирования ПКО «Внереализационный доход» [&1] из кассовой книги [&2 &3] отсутствует в справочнике счетов."
          , objImp:kredit-nonop-inc, v-code, objImp:name_
          ) ) .
    end .
    if objImp:credit-prepayment <> ? then 
    do :
      v-int-schet = integer (objImp:credit-prepayment) no-error .
      v-code-value = objImp:credit-prepayment .
      v-schet-found = false .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        if can-find (first buf_fin-code-cor-acc
          where buf_fin-code-cor-acc.host-code  = buf_clients.host-code
          AND buf_fin-code-cor-acc.code-value = v-code-value) then 
        do :
          v-host-code   = buf_clients.host-code .
          v-schet-found = true .
          leave.
        end .
      end .
      if not v-schet-found then
        undo, throw new Progress.Lang.AppError( substitute(
          "Счёт кредита для формирования ПКО «Аванс» [&1] из кассовой книги [&2 &3] отсутствует в справочнике счетов."
          , objImp:credit-prepayment, v-code, objImp:name_
          ) ) .
    end .
    if objImp:debit <> ? then 
    do :
      v-int-schet = integer (objImp:debit) no-error .
      v-code-value = objImp:debit .
      v-schet-found = false .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        if can-find (first buf_fin-code-cor-acc
          where buf_fin-code-cor-acc.host-code  = buf_clients.host-code
          AND buf_fin-code-cor-acc.code-value = v-code-value) then 
        do :
          v-host-code   = buf_clients.host-code .
          v-schet-found = true .
          leave.
        end .
      end .
      if not v-schet-found then
        undo, throw new Progress.Lang.AppError( substitute(
          "Счёт дебета [&1] из кассовой книги [&2 &3] отсутствует в справочнике счетов."
          , objImp:debit, v-code, objImp:name_
          ) ) .
    end .

    /* проверить код контрагента для оформления ПКО по справочнику клиентов */
    if objImp:code-payer <> ? then 
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = objImp:code-payer) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для оформления ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , {&cmp}, objImp:code-payer, v-code, objImp:name_
          ) ) .
    end .
    /* проверить код контрагента для оформления ПКО по справочнику клиентов */
    if objImp:code-payer-nonop-inc <> ? then 
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = objImp:code-payer-nonop-inc) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для внереализационный доход ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , {&cmp}, objImp:code-payer-nonop-inc, v-code, objImp:name_
          ) ) .
    end .
    if objImp:code-payer-prepayment <> ? then 
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = objImp:code-payer-prepayment) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для аванса ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , {&cmp}, objImp:code-payer-prepayment, v-code, objImp:name_
          ) ) .
    end .
    define variable vbank-resive      as integer no-undo.
    define variable vbank-resive-host as integer no-undo.
    find first fin-bank where fin-bank.bik eq objImp:bank-resive
      no-lock no-error.
    if available fin-bank
      then 
    do:
      vbank-resive = fin-bank.code-bank.
      vbank-resive-host = fin-bank.host-code .
    end.   
    /*   else
          undo, throw new Progress.Lang.AppError( substitute(
             "Не известный банк-получатель с БИК  &1.",objImp:bank-resive)).
      */ 
    define variable vbank-deposit      as integer no-undo.
    define variable vbank-deposit-host as integer no-undo.
    find first fin-bank where fin-bank.bik eq objImp:bank-deposit
      no-lock no-error.
    if available fin-bank
      then 
    do:
      vbank-deposit = fin-bank.code-bank.
      vbank-deposit-host = fin-bank.host-code .
    end.   
    /*  else
         undo, throw new Progress.Lang.AppError( substitute(
            "Не известный банк-вноситель с БИК  &1.",objImp:bank-deposit)).
      */    
    assign
      tt-cashbook.CashBookName      = objImp:name_               
      when objImp:name_ <> ?
      tt-cashbook.CorrPko           = objImp:kredit              
      when objImp:kredit <> ? 
      tt-cashbook.corrPkoVne        = objImp:kredit-nonop-inc              
      when objImp:kredit-nonop-inc <> ? 
      tt-cashbook.corrPkoAvans        = objImp:credit-prepayment       
      when objImp:credit-prepayment <> ? 
      tt-cashbook.CorrRko           = objImp:Corr-Rko            
      when objImp:Corr-Rko <> ?
      tt-cashbook.RuleOsnPko        = objImp:rule-reason         
      when objImp:rule-reason <> ?
      tt-cashbook.RuleOsnPkoVne     = objImp:rule-reason-nonop-inc 
      when objImp:rule-reason-nonop-inc <> ?
      tt-cashbook.RuleOsnPkoAvans     = objImp:rule-reason-prepayment 
      when objImp:rule-reason-prepayment <> ?
      tt-cashbook.OsnAcct           = objImp:debit               
      when objImp:debit <> ? 
      tt-cashbook.RuleOsnRko        = objImp:Rule-Osn-Rko        
      when objImp:Rule-Osn-Rko <> ?
      tt-cashbook.cli-type          = {&cmp}       
            when objImp:code-payer-prepayment <> ?
      tt-cashbook.RulePril          = string(objImp:rule-att)    
      when objImp:rule-att <> ?
      tt-cashbook.FlagSepCash       = (objImp:ind-kass-pko = 1)  
      when objImp:ind-kass-pko <> ?
      tt-cashbook.FlagSepFull       = (objImp:apart-np-tnp = 1)  
      when objImp:apart-np-tnp <> ?
      tt-cashbook.SourceCode        = string(objImp:code-symbol) 
      when objImp:code-symbol <> ?
      tt-cashbook.BankRecip-code    = vbank-resive               
      when vbank-resive <> ?
      tt-cashbook.BankDepos-code    = vbank-deposit              
      when vbank-deposit <> ?
      tt-cashbook.BankDepos-host    = vbank-deposit-host
      tt-cashbook.BankRecip-host    = vbank-resive-host
      tt-cashbook.CountCollect-type = {&cmp}                     
      when  objImp:cont-inkass <> ? 
      tt-cashbook.CountCollect-Code = objImp:cont-inkass         
      when objImp:cont-inkass <> ?
      tt-cashbook.CountCash-type    = {&cmp}                     
      when objImp:contr-code-rko <> ?
      tt-cashbook.CountCash-code    = objImp:contr-code-rko      
      when objImp:contr-code-rko <> ?
      tt-cashbook.Corr-transf       = objImp:Corr-transf         
      when objImp:Corr-transf <> ?
      tt-cashbook.contr-type-transf = {&cmp}                     
      when objImp:contr-code-transf <> ?
      tt-cashbook.contr-code-transf = objImp:contr-code-transf   
      when objImp:contr-code-transf <> ?
      tt-cashbook.rule-payer-transf = objImp:rule-payer-transf   
      when objImp:rule-payer-transf <> ?
      tt-cashbook.rule-payer-rko    = objImp:rule-payer-rko      
      when objImp:rule-payer-rko    <> ?
      tt-cashbook.rule-payer-inkass = objImp:rule-payer-inkass   
      when objImp:rule-payer-inkass <> ?
      tt-cashbook.BankRecip-acct    = objImp:bank-resive-acc     
      when objImp:bank-resive-acc  <> ?
      tt-cashbook.CorrAcctIncas     = objImp:Corr-inkass         
      when objImp:Corr-inkass  <> ?
      tt-cashbook.BasisIncas        = objImp:rule-osn-incass     
      when objImp:rule-osn-incass  <> ?
      tt-cashbook.Status_           = objImp:del-l 
      /* tt-cashbook.Status_      = 0:"Текущий", 1:"Удаленный"
         - при создании заполняется значением по умолчанию, при обновлении остаётся в прежнем значении */
      .      
            
      if objImp:code-payer <> ? then
      assign
      tt-cashbook.cli-code          = objImp:code-payer   
      tt-cashbook.cli-type          = {&cmp}  .

      if objImp:code-payer-nonop-inc <> ? then
      assign
      tt-cashbook.Vnecli-type       = {&cmp}
      tt-cashbook.Vnecli-code       = objImp:code-payer-nonop-inc     
      tt-cashbook.Avanscli-type       = {&cmp} .
      if objImp:code-payer-prepayment <> ? then
      tt-cashbook.Avanscli-code       = integer(objImp:code-payer-prepayment)  .

    assign
      tt-cashbook.rule-osn-transf = objImp:rule-reason         
      when objImp:rule-reason <> ?  and tt-cashbook.id ne 0
      tt-cashbook.rule-osn-transf = objImp:Rule-Osn-Rko        
      when objImp:Rule-Osn-Rko <> ? and tt-cashbook.id eq 0
      tt-cashbook.rule-osn-transf = objImp:rule-osn-transf     
      when objImp:rule-osn-transf <> ?
      .
    /* Текст поля «Принято от» для ПКО.
       Если не указано, то в ПКО проставляется наименование контрагента (см. п. 4.3.4.3) */
    tt-cashbook.takenfrom    = objImp:rule-payer .
    tt-cashbook.takenfromVne = objImp:rule-payer-nonop-inc .
    tt-cashbook.takenfromAvans = objImp:rule-payer-prepayment .
    /*
    if objImp:rule-payer <> ? then do : 
      tt-cashbook.takenfrom    = objImp:rule-payer .
    end .
    else 
    do :
      /* п.4.3.4.3
         Поле «Получено от» - представляет собой контрагента, от которого поступили ДС.
         Если не заполнено, то подставляется контрагент, указанный в настройке фирмы «Тип и код реализации».
         Наименование контрагента – текстовое поле, которое может быть изменено посредством РВД или импортом из 1С:ERP.
         Значение поля наименования контрагента выводится в поле «Получено от» в ПКО.
         27/V-2019  в поле "Принято от (авто)" должно писаться наименование контрагента, а не тип контрагента.
      */
      
      /* 27/V-2019 Т.к. неизвестно, какое наименование соответствует sysconf.sale-type, то
                   подставляется наименование от cashbook.cli-type + cashbook.cli-code
      define buffer buf_shop    for ub.shop .
      define buffer buf_sysconf for ub.sysconf .
      if v-host-code < 0 then do :
        find first buf_shop no-lock no-error .
        if available buf_shop then do:
          v-host-code = buf_shop.host-code .
        end.
      end .
      if v-host-code < 0 then do :
        find first buf_sysconf no-lock no-error .
      end .
      else do :
        find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code no-error .
      end .
      if available buf_sysconf then tt-cashbook.takenfrom = buf_sysconf.sale-type . 
      else undo, throw new Progress.Lang.AppError( substitute(
          "В настройках БД отсутствует контрагент ~«Тип и код реализации~» для кассовой книги [&2 &3]"
          , "", v-code, objImp:name_
      ) ) .
      */
      
      find first buf_clients no-lock
           where buf_clients.obj-type = tt-cashbook.cli-type
             and buf_clients.obj-code = tt-cashbook.cli-code no-error .
      if available buf_clients then tt-cashbook.takenfrom = buf_clients.obj-name .
      else undo, throw new Progress.Lang.AppError( substitute(
          "В справочнике отсутствует контрагент [&1 &2] ~«Тип и код реализации~» для кассовой книги [&3 &4]"
          , tt-cashbook.cli-type, tt-cashbook.cli-code, v-code, objImp:name_
      ) ) .
    end .
    */
    if v-mode = {&add-def} then 
    do :
      v-storage:insertDB(buffer tt-cashbook, output v-cashbookid) .
      if v-storage:Msg <> "" then undo, throw new Progress.Lang.AppError(        
          substitute("Ошибка импорта кассовой книги [&1]: &2", objImp:name_, v-storage:Msg)
          ) .
      
      tt-cashbook.id = v-cashbookid .
      v-str-kb-id = string(tt-cashbook.id) .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        empty temp-table tt-cashbookrule .
        create tt-cashbookrule .
        assign
          tt-cashbookrule.cashbookId      = tt-cashbook.id
          tt-cashbookrule.obj-type        = buf_clients.obj-type
          tt-cashbookrule.obj-code        = buf_clients.obj-code
          tt-cashbookrule.obj             = substitute("&1&2", tt-cashbookrule.obj-type, tt-cashbookrule.obj-code)
          tt-cashbookrule.host-code       = if buf_clients.obj-type = {&cmp} then string(buf_clients.obj-code) else string(buf_clients.host-code)
          /* 05/III-2019 Маски формировать из Получаемого префикса + "[NNNN]" */
          tt-cashbookrule.RkoMask         = substitute("&1[NNNN]", objImp:pko-prefix) 
          when objImp:pko-prefix <> ?
          tt-cashbookrule.PkoMask         = substitute("&1[NNNN]", objImp:rko-prefix) 
          when objImp:rko-prefix <> ?
          tt-cashbookrule.ManagerPosition = string(objImp:post-chief) 
          when objImp:post-chief <> ?
          tt-cashbookrule.ManagerFIO      = string(objImp:fio-chief)       
          when objImp:fio-chief <> ?
          tt-cashbookrule.BuhFIO          = string(objImp:fio-booker)      
          when objImp:fio-booker <> ?
          tt-cashbookrule.Struct          = string(objImp:struct-unit) 
          when objImp:struct-unit <> ?
          tt-cashbookrule.DptName         = objImp:struct-unit-name           
          when objImp:struct-unit-name <> ?
          tt-cashbookrule.DptType         = objImp:struct-unit-type           
          when objImp:struct-unit-type <> ?
          tt-cashbookrule.DptCode         = objImp:struct-unit-code           
          when objImp:struct-unit-code <> ?
          tt-cashbookrule.uchet           = string(objImp:acc-shift)          
          when objImp:acc-shift <> ?
          tt-cashbookrule.Pin             = objImp:pin                        
          when objImp:pin <> ?
          .
        v-storage:updateDBobj(input dataset ds-cashbookrule by-reference) .
        if v-storage:Msg <> "" then undo, throw new Progress.Lang.AppError(        
            substitute("Ошибка импорта кассовой книги [&1]: &2", objImp:name_, v-storage:Msg)
            ) .
      end .
    end .
    else 
    do :
      v-storage:updateDB(buffer tt-cashbook) .
      if v-storage:Msg <> "" then undo, throw new Progress.Lang.AppError(        
          substitute("Ошибка импорта кассовой книги [&1]: &2", objImp:name_, v-storage:Msg)
          ) .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = {&shop}
        and buf_clients.stts     = {&bef-current-status-int} :
        empty temp-table tt-cashbookrule .
        v-storage:getCashBookRule (tt-cashbook.id, buf_clients.obj-type, buf_clients.obj-code, output dataset ds-cashbookrule by-reference) .
        find first tt-cashbookrule no-error .
        if not available tt-cashbookrule then 
        do :
         
          create tt-cashbookrule .
          assign
            tt-cashbookrule.cashbookId = tt-cashbook.id
            tt-cashbookrule.obj-type   = buf_clients.obj-type
            tt-cashbookrule.obj-code   = buf_clients.obj-code
            tt-cashbookrule.obj        = substitute("&1&2", tt-cashbookrule.obj-type, tt-cashbookrule.obj-code)
            tt-cashbookrule.host-code  = if buf_clients.obj-type = {&cmp} then string(buf_clients.obj-code) else string(buf_clients.host-code)
         
            .
         
        end .
        assign
          tt-cashbookrule.RkoMask         = substitute("&1[NNNN]", objImp:pko-prefix) 
          when objImp:pko-prefix <> ?
          tt-cashbookrule.PkoMask         = substitute("&1[NNNN]", objImp:rko-prefix) 
          when objImp:rko-prefix <> ?
          tt-cashbookrule.ManagerPosition = string(objImp:post-chief) 
          when objImp:post-chief <> ?
          tt-cashbookrule.ManagerFIO      = string(objImp:fio-chief)       
          when objImp:fio-chief <> ?
          tt-cashbookrule.BuhFIO          = string(objImp:fio-booker)      
          when objImp:fio-booker <> ?
          tt-cashbookrule.Struct          = string(objImp:struct-unit) 
          when objImp:struct-unit <> ?
          tt-cashbookrule.DptName         = objImp:struct-unit-name           
          when objImp:struct-unit-name <> ?
          tt-cashbookrule.DptType         = objImp:struct-unit-type           
          when objImp:struct-unit-type <> ?
          tt-cashbookrule.DptCode         = objImp:struct-unit-code           
          when objImp:struct-unit-code <> ?
          tt-cashbookrule.uchet           = string(objImp:acc-shift)        
          when objImp:acc-shift <> ?
          tt-cashbookrule.Pin             = objImp:pin                      
          when objImp:pin <> ?
          .
        v-storage:updateDBobj(input dataset ds-cashbookrule by-reference) .
        if v-storage:Msg <> "" then undo, throw new Progress.Lang.AppError(        
            substitute("Ошибка импорта кассовой книги [&1]: &2", objImp:name_, v-storage:Msg)
            ) .
      end . /* end_of for_each_clients */
    end .


    /* на выходе товары:
       - привязаны к пришедшей кассовой книге,
       - других товаров к ней не привязано,
       - от других книг товары отвязаны
    */
    &scop proc-name gds-attr-write
    empty temp-table tt-gds .
    if (v-mode = {&update}) and (v-basic-kb = 0) then 
    do :
    /* при обновлении основной кассовой книги секция с товарами игнорируется */
    end .
    else 
    do :
      
      v-objlist = objImp:kb-gds .
      if valid-object(v-objlist) then 
      do :
        v-i-counter = v-objlist:iCounter .
        do v-i-num = 1 to v-i-counter :
          v-stub = v-objlist:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
          v-gds-gd = cast(v-objlist:SubjectObjCurr, ibs.th.bge.1crn.subjects.kass-book-gd) .
          v-gds-code = integer(v-gds-gd:gd-code) .
          if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
            undo, throw new Progress.Lang.AppError( substitute(
              "Код товара [&1] из кассовой книги [&2 &3] отсутствует в справочнике товаров."
              , v-gds-code, v-code, objImp:name_
              ) ) .
          create tt-gds.
          tt-gds.gds-code = v-gds-code .
        end . // end_of_objImp:gds[]

        /* Отвязать от других кассовых книг. Скопировано из attr-lib:gds-attr-DELETE() */
        if v-mode = {&update} then 
        do :
          for each buf_goods-attr exclusive-lock
            where buf_goods-attr.attr-code  = {&attr-cash-book-id}
            and buf_goods-attr.attr-value = v-str-kb-id :
            if not can-find (first tt-gds where tt-gds.gds-code = buf_goods-attr.gds-code) then
              delete buf_goods-attr.
          end .
        end .
        /* Перепривязать к пришедшей кассовой книге. Скопировано из attr-lib:gds-attr-write() */
        for each tt-gds :
          find first buf_goods-attr exclusive-lock
            where buf_goods-attr.gds-code  = tt-gds.gds-code
            and buf_goods-attr.attr-code = {&attr-cash-book-id} no-error .
          if available buf_goods-attr then assign
              buf_goods-attr.attr-value = v-str-kb-id when (buf_goods-attr.attr-value <> v-str-kb-id)
              .
          else 
          do:
            create buf_goods-attr .
            assign
              buf_goods-attr.gds-code   = tt-gds.gds-code
              buf_goods-attr.attr-code  = {&attr-cash-book-id}
              buf_goods-attr.attr-value = v-str-kb-id
              .
          end.
        end .
      /* образец вызова из attr-lib.p
      {&run_proc_attr-lib}
      (input  v-gds-code
      ,input  {&attr-cash-book-id}
      ,input  v-str-kb-id
      ) no-error .
      */
      end. // end_of_gds
      else 
      do:
        for each buf_goods-attr exclusive-lock
          where buf_goods-attr.attr-code  = {&attr-cash-book-id}
          and buf_goods-attr.attr-value = v-str-kb-id :
            
          delete buf_goods-attr.
        end .
      end. 
         
    end .
    
    
    v-retfl = true.
    
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . 
      else 
      do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + {&new-line} + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . 
        else Msg = "AppError в типах кассовых книг" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + {&new-line} + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . 
      else Msg = "ProError в типах кассовых книг" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в типах кассовых книг" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      dataset ds-cashbook:empty-dataset() .
      if valid-object(v-storage) then delete object v-storage .
      return v-retfl .
    end finally .
  end method. /* end_of Excute */
    
end class.
