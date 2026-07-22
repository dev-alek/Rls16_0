using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.kass-book.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impkass-book implements ibs.th.bge.1crn.import.iimpsubject:
define temp-table tt-cashbook like ub.CashBook
  field stat              as character
  field mark              as character
  field basic-kb          as logical
  field SourceCode        as character
  field BankRecip-host    as integer
  field BankRecip-code    as integer
  field BankRecip-acct    as character
  field BankDepos-host    as integer
  field BankDepos-code    as integer
  field CountCollect-type as character
  field CountCollect-code as integer
  field CountCash-type    as character
  field CountCash-code    as integer
  field BasisIncas        as character
  field CorrAcctIncas     as character
  field Corr-transf       as character
  field rule-osn-transf   as character
  field contr-type-transf as character
  field contr-code-transf as integer
  field Vnecli-type       as character
  field Vnecli-code       as integer
  field Avanscli-type     as character
  field Avanscli-code     as integer
  field rule-payer-transf as character
  field rule-payer-rko    as character
  field rule-payer-inkass as character
  field corrPkoVne        as character
  field takenfromVne      as character
  field RuleOsnPkoVne     as character
  field corrPkoAvans      as character
  field takenfromAvans    as character
  field RuleOsnPkoAvans   as character
  .
define dataset ds-cashbook for tt-cashbook .
method private character getRuleOsnName (input p-rule-reason as character) :
    define variable v-name as character no-undo .
    case p-rule-reason :
      when "0" then v-name = "Выручка от реализации" .
      when "1" then v-name = "Номера Z-отчетов" .
      when "2" then v-name = "Не заполнять" .
        otherwise v-name = p-rule-reason .
    end case .
    return v-name .
  end method .
  method private character getRuleOsnID (input p-rule-reason as character) :
    define variable v-id as character no-undo .
    case p-rule-reason :
      when "Выручка от реализации" then v-id = "0" .
      when "Номера Z-отчетов" then v-id = "1" .
      when "Не заполнять" then v-id = "2" .
        otherwise v-id = p-rule-reason .
    end case .
    return v-id .
  end method .
  method private character getRulePrilName (input p-rule-att as integer) :
    define variable v-name as character no-undo .
    case p-rule-att :
      when 1 then v-name = "Не заполнять" .
        otherwise v-name = "Номера Z-отчетов" .
    end case .
    return v-name .
  end method .
    method private character getRulePrilID (input p-rule-att as character) :
    define variable v-id as character no-undo .
    case p-rule-att :
      when "Не заполнять" then v-id = "1" .
        otherwise v-id = "0" .
    end case .
    return v-id .
  end method .
define temp-table tt-cashbookrule like ub.cashbookrule
  field RkoMask         as character
  field PkoMask         as character
  field currPko         as character
  field currRko         as character
  field ManagerPosition as character
  field ManagerFIO      as character
  field BuhFIO          as character
  field struct          as character
  field uchet           as character
  field DptName         as character
  field DptType         as character
  field DptCode         as integer
  field obj             as character
  field stat            as character
  field Pin             as character
.
define dataset ds-cashbookrule for tt-cashbookrule .
 method private character getMgrPositionName (input p-post-chief as character) :
    define variable v-name as character no-undo .
    case p-post-chief :
      when "1" then v-name = "Директор" .
      when "2" then v-name = "Управляющий" .
      when "0" then v-name = "Должность рук-ля фирмы" .
      otherwise v-name = p-post-chief .
    end case .
    return v-name .
  end method .
 method private character getMgrPositionID (input p-post-chief as character) :
    define variable v-id as character no-undo .
    case p-post-chief :
      when "Директор" then v-id = "1" .
      when "Управляющий" then v-id = "2" .
      when "Должность рук-ля фирмы" then v-id = "0" .
      otherwise v-id = p-post-chief.
    end case .
    return v-id .
  end method .
  method private character getMgrFioName (input p-fio-chief as character) :
    define variable v-name as character no-undo .
    case p-fio-chief :
      when "1" then v-name = "ФИО руководителя магазина" .
      when "0" then v-name = "ФИО руководителя фирмы" .
      otherwise v-name = p-fio-chief .
    end case .
    return v-name .
  end method .
  method private character getMgrFioID (input p-fio-chief as character) :
    define variable v-id as character no-undo .
    case p-fio-chief :
      when "ФИО руководителя магазина" then v-id = "1" .
      when "ФИО руководителя фирмы" then v-id = "0" .
        otherwise v-id = p-fio-chief .
    end case .
    return v-id .
  end method .
  method private character getBuhFioName (input p-fio-booker as character) :
    define variable v-name as character no-undo .
    case p-fio-booker :
      when "1" then v-name = "ФИО бухгалтера магазина" .
      when "0" then v-name = "ФИО гл. бухгалтера фирмы" .
      otherwise v-name = p-fio-booker .
    end case .
    return v-name .
  end method .
  method private character getBuhFioID (input p-fio-booker as character) :
    define variable v-id as character no-undo .
    case p-fio-booker :
      when "ФИО бухгалтера магазина" then v-id = "1" .
      when "ФИО гл. бухгалтера фирмы" then v-id = "0" .
      otherwise v-id = p-fio-booker .
    end case .
    return v-id .
  end method .
  method private character getStructName (input p-struct-unit as integer) :
    define variable v-name as character no-undo .
    case p-struct-unit :
      when 1 then v-name = "Взять из объекта" .
      when 2 then v-name = "Значение по умолчанию" .
      when 0 then v-name = "Заполняет оператор" .
        otherwise v-name = string(p-struct-unit) .
    end case .
    return v-name .
  end method .
  method private character getStructID (input p-struct-unit as character) :
    define variable v-id as character no-undo .
    case p-struct-unit :
      when "Взять из объекта" then v-id = "1" .
      when "Значение по умолчанию" then v-id = "2" .
      when "Заполняет оператор" then v-id = "0" .
        otherwise v-id = p-struct-unit .
    end case .
    return v-id .
  end method .
  method private character getUchetName (input p-acc-shift as integer) :
    define variable v-name as character no-undo .
    case p-acc-shift :
      when 1 then v-name = "по сменным датам" .
      when 0 then v-name = "по календарным датам" .
        otherwise v-name = string (p-acc-shift) .
    end case .
    return v-name .
  end method .
  method private character getUchetID (input p-acc-shift as character) :
    define variable v-id as character no-undo .
    case p-acc-shift :
      when "по сменным датам" then v-id = "1" .
      when "по календарным датам" then v-id = "0" .
        otherwise v-id = p-acc-shift .
    end case .
    return v-id .
  end method .
  define private temp-table tt-gds no-undo
    field gds-code as integer
    .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp          as class     kass-book                           no-undo.
    define variable v-retfl         as logical   no-undo .
    define variable v-mode          as character no-undo.
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
    define variable v-cashbookid    as int64     no-undo .
    define variable v-commentrytype as integer   no-undo .
    define variable v-host-code     as integer   no-undo .
    define buffer buf_clients          for ub.clients .
    define buffer buf_goods            for ub.goods .
    define buffer buf_goods-attr       for ub.goods-attr .
    define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc .
    objImp = cast (subjectObj, kass-book).
    if objImp:del-f > 0 then
      undo, throw new Progress.Lang.AppError("физичесткое удаление Типа кассовых книг не предусмотрено") .
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
        if objImp:del-l > 0 then
        do :
          if tt-cashbook.id = 0 then undo, throw new Progress.Lang.AppError(
              substitute("Ошибка логического удаления. Попытка удаления кассовой книги по признаку «Основная деятельность».")
              ) .
          v-mode = 'удаление':U .
        end .
        else v-mode = 'ИЗМЕНЕНИЕ':U .
      end .
      else
      do :
        if objImp:del-l > 0 then
        do :
          undo, throw new Progress.Lang.AppError(
            substitute("Ошибка логического удаления. Тип кассовой книги с кодом [&1] отсутствует в БД.", v-code)
            ) .
        end .
        v-mode = 'ДОБАВЛЕНИЕ':U .
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
          v-mode               = 'ИЗМЕНЕНИЕ':U
          .
      end.
      else
      do:
        v-mode = 'ДОБАВЛЕНИЕ':U .
        create tt-cashbook .
        assign
          tt-cashbook.ext-code = v-code
          tt-cashbook.id       = 0
          tt-cashbook.basic-kb = yes
          .
      end.
    end.
    if v-mode = 'удаление':U then
    do :
      if tt-cashbook.Status_ = 0  then
      do :
        for each buf_goods-attr exclusive-lock
          where buf_goods-attr.attr-code  = 'cash-book-id':U
          and buf_goods-attr.attr-value = v-str-kb-id :
          delete buf_goods-attr.
        end .
        v-storage:deleteDB(input dataset ds-cashbook by-reference) .
      end .
      v-retfl = true.
      return true .
    end .
    v-host-code = -1 .
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
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
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
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
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
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
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
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
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
    if objImp:code-payer <> ? then
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = objImp:code-payer) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для оформления ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , 'орг':U, objImp:code-payer, v-code, objImp:name_
          ) ) .
    end .
    if objImp:code-payer-nonop-inc <> ? then
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = objImp:code-payer-nonop-inc) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для внереализационный доход ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , 'орг':U, objImp:code-payer-nonop-inc, v-code, objImp:name_
          ) ) .
    end .
    if objImp:code-payer-prepayment <> ? then
    do :
      if not can-find (first buf_clients
        where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = objImp:code-payer-prepayment) then
        undo, throw new Progress.Lang.AppError( substitute(
          "Контрагент для аванса ПКО [&1 &2] из кассовой книги [&3 &4] отсутствует в справочнике клиентов."
          , 'орг':U, objImp:code-payer-prepayment, v-code, objImp:name_
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
      tt-cashbook.cli-type          = 'орг':U
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
      tt-cashbook.CountCollect-type = 'орг':U
      when  objImp:cont-inkass <> ?
      tt-cashbook.CountCollect-Code = objImp:cont-inkass
      when objImp:cont-inkass <> ?
      tt-cashbook.CountCash-type    = 'орг':U
      when objImp:contr-code-rko <> ?
      tt-cashbook.CountCash-code    = objImp:contr-code-rko
      when objImp:contr-code-rko <> ?
      tt-cashbook.Corr-transf       = objImp:Corr-transf
      when objImp:Corr-transf <> ?
      tt-cashbook.contr-type-transf = 'орг':U
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
      .
      if objImp:code-payer <> ? then
      assign
      tt-cashbook.cli-code          = objImp:code-payer
      tt-cashbook.cli-type          = 'орг':U  .
      if objImp:code-payer-nonop-inc <> ? then
      assign
      tt-cashbook.Vnecli-type       = 'орг':U
      tt-cashbook.Vnecli-code       = objImp:code-payer-nonop-inc
      tt-cashbook.Avanscli-type       = 'орг':U .
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
    tt-cashbook.takenfrom    = objImp:rule-payer .
    tt-cashbook.takenfromVne = objImp:rule-payer-nonop-inc .
    tt-cashbook.takenfromAvans = objImp:rule-payer-prepayment .
    if v-mode = 'ДОБАВЛЕНИЕ':U then
    do :
      v-storage:insertDB(buffer tt-cashbook, output v-cashbookid) .
      if v-storage:Msg <> "" then undo, throw new Progress.Lang.AppError(
          substitute("Ошибка импорта кассовой книги [&1]: &2", objImp:name_, v-storage:Msg)
          ) .
      tt-cashbook.id = v-cashbookid .
      v-str-kb-id = string(tt-cashbook.id) .
      for each buf_clients no-lock
        where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
        empty temp-table tt-cashbookrule .
        create tt-cashbookrule .
        assign
          tt-cashbookrule.cashbookId      = tt-cashbook.id
          tt-cashbookrule.obj-type        = buf_clients.obj-type
          tt-cashbookrule.obj-code        = buf_clients.obj-code
          tt-cashbookrule.obj             = substitute("&1&2", tt-cashbookrule.obj-type, tt-cashbookrule.obj-code)
          tt-cashbookrule.host-code       = if buf_clients.obj-type = 'орг':U then string(buf_clients.obj-code) else string(buf_clients.host-code)
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
        and buf_clients.obj-type = 'маг':U
        and buf_clients.stts     = 0 :
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
            tt-cashbookrule.host-code  = if buf_clients.obj-type = 'орг':U then string(buf_clients.obj-code) else string(buf_clients.host-code)
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
      end .
    end .
        empty temp-table tt-gds .
    if (v-mode = 'ИЗМЕНЕНИЕ':U) and (v-basic-kb = 0) then
    do :
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
        if v-mode = 'ИЗМЕНЕНИЕ':U then
        do :
          for each buf_goods-attr exclusive-lock
            where buf_goods-attr.attr-code  = 'cash-book-id':U
            and buf_goods-attr.attr-value = v-str-kb-id :
            if not can-find (first tt-gds where tt-gds.gds-code = buf_goods-attr.gds-code) then
              delete buf_goods-attr.
          end .
        end .
        for each tt-gds :
          find first buf_goods-attr exclusive-lock
            where buf_goods-attr.gds-code  = tt-gds.gds-code
            and buf_goods-attr.attr-code = 'cash-book-id':U no-error .
          if available buf_goods-attr then assign
              buf_goods-attr.attr-value = v-str-kb-id when (buf_goods-attr.attr-value <> v-str-kb-id)
              .
          else
          do:
            create buf_goods-attr .
            assign
              buf_goods-attr.gds-code   = tt-gds.gds-code
              buf_goods-attr.attr-code  = 'cash-book-id':U
              buf_goods-attr.attr-value = v-str-kb-id
              .
          end.
        end .
      end. // end_of_gds
      else
      do:
        for each buf_goods-attr exclusive-lock
          where buf_goods-attr.attr-code  = 'cash-book-id':U
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
          Msg = Msg + chr(10) + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then .
        else Msg = "AppError в типах кассовых книг" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + chr(10) + exProErrors:GetMessage(i) .
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
  end method.
end class.
