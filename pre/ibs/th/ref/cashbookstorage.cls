using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.cashbookstorage final:
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
  define property Msg as character
    get.
    private set.
  define variable mQuery as handle no-undo.
  define variable mQueryRule as handle no-undo.
  define variable objKeyRec as ibs.th.gbl.keyrec no-undo.
  define variable objCount  as ibs.th.ref.counter.counterstorage no-undo.
  constructor public cashbookstorage (  ):
    super ().
    objKeyRec = new ibs.th.gbl.keyrec().
    objCount  = new ibs.th.ref.counter.counterstorage().
  end constructor.
  destructor public cashbookstorage ( ):
     delete object objKeyRec.
     delete object objCount.
  end destructor.
  method private void checkCashBook (buffer tt-cashbook for tt-cashbook) :
    Msg = "" .
    if trim(tt-cashbook.CashBookName) = ""
    then do :
      Msg = "Наименование типа кассовой книги не может быть пустым!" .
      return .
    end.
    if trim(tt-cashbook.CorrPko) = ""
    then do :
      Msg = "Поле Кор. счет ПКО не может быть пустым!" .
      return .
    end.
    if trim(tt-cashbook.OSnAcct) = ""
    then do :
      Msg = "Поле Основной счет не может быть пустым!" .
      return .
    end.
    if trim(tt-cashbook.RuleOsnPko) = ""
    then do :
      Msg = 'Правило заполнения графы "Основание" ПКО не может быть пустым!' .
      return .
    end.
    if trim(tt-cashbook.RulePril) = ""
    then do :
      Msg = "Правило заполнения графы Приложение не может быть пустым!" .
      return .
    end.
    if (trim(tt-cashbook.cli-type) = ""
    or tt-cashbook.cli-code = ? or tt-cashbook.cli-code <= 0) and tt-cashbook.id eq 0
    then do :
      Msg = "Выберите контрагента для автоматического формирования платежей. Поле Контрагент (авто)." .
      return .
    end.
    find first ub.cashbook no-lock where ub.CashBook.CashBookName = tt-cashbook.CashBookName and ub.CashBook.id <> tt-cashbook.id no-error.
    if available ub.cashbook
    then do :
      Msg = "Уже есть тип кассовой книги с наименованием  " + tt-cashbook.CashBookName .
      return .
    end.
    return .
  end method .
  method private void checkCashBookRule (buffer tt-cashbookrule for tt-cashbookrule) :
    Msg = "" .
    if trim(tt-cashbookrule.obj) = ""
    then do :
      Msg = "Выберите объект!" .
      return .
    end.
    if tt-cashbookrule.obj-type <> 'маг':U
    then do :
      if trim(tt-cashbookrule.ManagerPosition) = ""
      then do :
        Msg = "Выберите должность руководителя!" .
        return .
      end.
      if trim(tt-cashbookrule.ManagerFIO) = ""
      then do :
        Msg = "Выберите ФИО руководителя!" .
        return .
      end.
      if trim(tt-cashbookrule.BuhFIO) = ""
      then do :
        Msg = "Выберите ФИО бухгалтера!" .
        return .
      end.
      if trim(tt-cashbookrule.struct) = ""
      then do :
        Msg = "Поле <Структурное подразделение> не выбрано!" .
        return .
      end.
      if trim(tt-cashbookrule.uchet) = ""
      then do :
        Msg = "Поле <учёт ведётся> не выбрано!" .
        return .
      end.
      if trim(tt-cashbookrule.PkoMask) = ""
      then do :
        Msg = "Маска ПКО не может быть пустой!" .
        return .
      end.
      if trim(tt-cashbookrule.RkoMask) = ""
      then do :
        Msg = "Маска РКО не может быть пустой!" .
        return .
      end.
    end.
    if tt-cashbookrule.obj-type <> 'орг':U
    then do :
      if tt-cashbookrule.currPko > ""
      then do :
        int64(tt-cashbookrule.currPko) no-error.
        if error-status:error
        then do :
          Msg = "Текущий номер ПКО должен быть целым числом (без маски)" .
          return .
        end.
      end.
      if tt-cashbookrule.currRko > ""
      then do :
        int64(tt-cashbookrule.currRko) no-error.
        if error-status:error
        then do :
          Msg = "Текущий номер РКО должен быть целым числом (без маски)" .
          return .
        end.
      end.
    end.
    return.
  end method .
  method public void insertDB (buffer tt-cashbook for tt-cashbook, output p-id as int64) :
      if not tt-cashbook.basic-kb
      then
         tt-cashbook.id = -1.
      checkCashBook(buffer tt-cashbook) .
      if Msg <> ""
      then return .
      create ub.cashbook .
      buffer-copy tt-cashbook to ub.CashBook
      assign
        ub.CashBook.id = if tt-cashbook.basic-kb then 0 else next-value(s-cashbook-id)
        ub.CashBook.Status_ = 0
        ub.CashBook.RulePril = getRulePrilID(tt-cashbook.RulePril)
        ub.CashBook.RuleOsnPko = getRuleOsnID(tt-cashbook.RuleOsnPko)
        tt-cashbook.id         = ub.CashBook.id
      .
      updateAttrForcashbook (buffer tt-cashbook:handle).
      p-id = ub.CashBook.id .
  end method .
  method public void ttCashbooksaturation (input iBuffer as handle):
     define variable vField as handle no-undo.
     define variable vitm  as integer no-undo.
     define buffer buf_file  for _file.
     define buffer buf_field for _field.
     define buffer CashBookrule for CashBookrule.
      find first buf_file where buf_file._file-name eq "cashbook" no-lock.
     do vitm = 1 to iBuffer:num-fields:
         vField = iBuffer:buffer-field(vItm).
         if lookup (vField:name,"stat,mark,basic-kb") eq 0
         then do:
            find first buf_field where buf_field._file-recid eq recid(buf_file)
                                   and buf_field._Field-Name eq vField:name
            no-lock no-error.
            if not available buf_field
            then do:
               find first ub.CashBookrule where ub.CashBookRule.CashBookID eq iBuffer:buffer-field ("id"):buffer-value ()
                                            and ub.CashBookRule.Obj-type   eq 'всем':U
                                            and ub.CashBookRule.Obj-code   eq 0
                                            and ub.CashBookRule.Code       eq vField:name
               no-lock no-error.
               if  available  ub.CashBookrule
               then do:
                  vField:buffer-value () =  ub.CashBookRule.RuleValue.
               end.
            end.
         end.
      end.
  end.
   method public void updateAttrForcashbook (input iBuffer as handle):
     define variable vField as handle no-undo.
     define variable vitm  as integer no-undo.
     define buffer buf_file  for _file.
     define buffer buf_field for _field.
     define buffer CashBookrule for CashBookrule.
      find first buf_file where buf_file._file-name eq "cashbook" no-lock.
     do vitm = 1 to iBuffer:num-fields:
         vField = iBuffer:buffer-field(vItm).
         if lookup (vField:name,"stat,mark,basic-kb") eq 0
         then do:
            find first buf_field where buf_field._file-recid eq recid(buf_file)
                                   and buf_field._Field-Name eq vField:name
            no-lock no-error.
            if not available buf_field
            then do:
               find first ub.CashBookrule where ub.CashBookRule.CashBookID eq iBuffer:buffer-field ("id"):buffer-value ()
                                            and ub.CashBookRule.Obj-type   eq 'всем':U
                                            and ub.CashBookRule.Obj-code   eq 0
                                            and ub.CashBookRule.Code       eq vField:name
               exclusive-lock no-error.
               if not available  ub.CashBookrule
               then do:
                  create ub.CashBookRule.
                  assign
                     ub.CashBookRule.CashBookID = iBuffer:buffer-field ("id"):buffer-value ()
                     ub.CashBookRule.Obj-type   = 'всем':U
                     ub.CashBookRule.Obj-code   = 0
                     ub.CashBookRule.Code       = vField:name
                     ub.CashBookRule.Status_    = 0
                  .
               end.
               ub.CashBookRule.RuleValue =  vField:buffer-value ().
               release ub.CashBookRule .
            end.
         end.
      end.
  end.
  method public void updateDB (buffer tt-cashbook for tt-cashbook) :
      checkCashBook(buffer tt-cashbook) .
      if Msg <> ""
      then return .
      find first ub.cashbook exclusive-lock where ub.cashbook.id = tt-cashbook.id .
      buffer-copy tt-cashbook except tt-cashbook.RulePril tt-cashbook.RuleOsnPko to ub.CashBook .
      assign
      ub.CashBook.RuleOsnPko = getRuleOsnID(tt-cashbook.RuleOsnPko)
      ub.CashBook.RulePril = getRulePrilID(tt-cashbook.RulePril)
      .
      updateAttrForcashbook(buffer tt-cashbook:handle).
  end method .
  method private void CrRuleDBobj (buffer tt-cashbookrule for tt-cashbookrule  , icode as character  ) :
     find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID  = tt-cashbookrule.CashBookID
                                                 and ub.CashBookRule.Obj-type    = tt-cashbookrule.obj-type
                                                 and ub.CashBookRule.Obj-code    = tt-cashbookrule.obj-code
                                                 and ub.CashBookRule.Code        = icode
        no-error .
     if not available ub.CashBookRule
     then do:
        create ub.CashBookRule.
        assign
           ub.CashBookRule.CashBookID  = tt-cashbookrule.CashBookID
           ub.CashBookRule.Obj-type    = tt-cashbookrule.obj-type
           ub.CashBookRule.Obj-code    = tt-cashbookrule.obj-code
           ub.CashBookRule.Code        = icode
        .
     end.
     ub.CashBookRule.host-code   = tt-cashbookrule.host-code.
     ub.CashBookRule.Status_     = tt-cashbookrule.Status_ .
     ub.CashBookRule.RuleValue = if      icode eq "PkoMask"
                                  then tt-cashbookrule.PkoMask
                                  else if icode eq "RkoMask"
                                  then tt-cashbookrule.RkoMask
                                  else if icode eq "currPko"
                                  then tt-cashbookrule.currPko
                                  else if icode eq "currRko"
                                  then tt-cashbookrule.currRko
                                  else if icode eq "ManagerPosition"
                                  then getMgrPositionID(tt-cashbookrule.ManagerPosition)
                                  else if icode eq "ManagerFIO"
                                  then getMgrFioID(tt-cashbookrule.ManagerFIO)
                                  else if icode eq "BuhFIO"
                                  then getBuhFioID(tt-cashbookrule.BuhFIO)
                                  else if icode eq "Struct"
                                  then getStructID(tt-cashbookrule.Struct)
                                  else if icode eq "uchet"
                                  then getUchetID(tt-cashbookrule.uchet)
                                  else if icode eq "DptName"
                                  then tt-cashbookrule.DptName
                                  else if icode eq "DptType"
                                  then tt-cashbookrule.DptType
                                  else if icode eq "DptCode"
                                  then string (tt-cashbookrule.DptCode)
                                  else if icode eq "Pin"
                                  then string (tt-cashbookrule.Pin)
                                  else ""
                                  .
         define variable v-cashbookrule-key-rec as character no-undo.
         if icode eq "currPko"  or icode eq "currRko"
         then do:
            objKeyRec:GenKeyRec ( input 'CashBookRule':U
                                               ,input buffer ub.cashbookrule:handle
                                               ,output v-cashbookrule-key-rec).
            find first clients where clients.obj-type eq tt-cashbookrule.obj-type
                             and clients.obj-code eq tt-cashbookrule.obj-code
                             no-lock no-error.
            if     available clients
               and clients.db-num ne ?
            then
            objcount:SetCountValue(clients.db-num,
                                   "cashbookrule",
                                   v-cashbookrule-key-rec,
                                   icode,
                                   int64(ub.cashbookrule.RuleValue)).
        end.
  end method.
  method public void updateDBobj (input dataset for ds-cashbookrule) :
    for each tt-cashbookrule :
      checkCashBookRule(buffer tt-cashbookrule) .
      if Msg <> ""
      then return .
      CrRuleDBobj(buffer tt-cashbookrule, "PkoMask").
      CrRuleDBobj(buffer tt-cashbookrule, "RkoMask").
      CrRuleDBobj(buffer tt-cashbookrule, "currPko").
      CrRuleDBobj(buffer tt-cashbookrule, "currRko" ).
      CrRuleDBobj(buffer tt-cashbookrule, "ManagerPosition").
      CrRuleDBobj(buffer tt-cashbookrule, "ManagerFIO").
      CrRuleDBobj(buffer tt-cashbookrule, "BuhFIO" ).
      CrRuleDBobj(buffer tt-cashbookrule, "Struct").
      CrRuleDBobj(buffer tt-cashbookrule, "uchet").
      CrRuleDBobj(buffer tt-cashbookrule,"DptName" ).
      CrRuleDBobj(buffer tt-cashbookrule,"DptType").
      CrRuleDBobj(buffer tt-cashbookrule,"DptCode").
      CrRuleDBobj(buffer tt-cashbookrule,"Pin").
    end.
  end method .
  method public void deleteDB (input dataset for ds-cashbook) :
    for each tt-cashbook :
      find first ub.cashbook exclusive-lock where ub.cashbook.id = tt-cashbook.id .
      if ub.CashBook.Status_ = 0
      then do :
        ub.CashBook.Status_ = 1.
        for each ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = ub.cashbook.id :
          delete ub.CashBookRule.
        end.
        for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = 'cash-book-id':U
                                              and ub.goods-attr.attr-value = string(ub.cashbook.id):
        delete ub.goods-attr .
      end.
      end.
      else
      if ub.CashBook.Status_ = 1
      then do :
        ub.CashBook.Status_ = 0.
      end.
    end.
  end method .
  method public void deleteDB (input id as int64) :
    find first ub.cashbook exclusive-lock where ub.cashbook.id = id .
    if ub.CashBook.Status_ = 0
    then do :
      ub.CashBook.Status_ = 1.
      for each ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = ub.cashbook.id :
        delete ub.CashBookRule.
      end.
      for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = 'cash-book-id':U
                                              and ub.goods-attr.attr-value = string(ub.cashbook.id):
        delete ub.goods-attr .
      end.
    end.
    else if ub.CashBook.Status_ = 1
    then do :
      ub.CashBook.Status_ = 0.
    end.
  end method .
  method public void deleteDBobj (input cashbookId as int64, input p-obj-type as character, input p-obj-code as integer) :
    for each ub.cashbookrule exclusive-lock where ub.CashBookRule.CashBookID = cashbookId
                                              and ub.CashBookRule.obj-type   = p-obj-type
                                              and ub.CashBookRule.obj-code   = p-obj-code :
      delete ub.CashBookRule .
    end.
  end method .
  method public void getcashbook (input pExtCode as character, output dataset ds-cashbook ) :
    define buffer buf_cashbook for ub.cashbook .
    for each buf_cashbook no-lock where buf_cashbook.ext-code = pExtCode :
      create tt-cashbook .
      buffer-copy buf_cashbook to tt-cashbook
      assign
        tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
        tt-cashbook.basic-kb = tt-cashbook.id eq 0
      .
      ttCashbooksaturation(buffer tt-cashbook:handle).
    end.
  end method.
  method public void getcashbook (input pCashBookId as int64, output dataset ds-cashbook ) :
    define buffer buf_cashbook for ub.cashbook .
    find first buf_cashbook no-lock where buf_cashbook.id = pCashBookId no-error .
    if available buf_cashbook then do :
      create tt-cashbook .
      buffer-copy buf_cashbook to tt-cashbook
      assign
        tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
        tt-cashbook.basic-kb = tt-cashbook.id eq 0
      .
      ttCashbooksaturation(buffer tt-cashbook:handle).
    end.
  end method.
  method public handle getquery
  ( input v-stat as character,
    input v-firm as character,
    output oQuery as handle,
    output oQueryRule as handle)
  :
    define buffer buf_cashbook for ub.cashbook .
    define buffer buf_cashbookrule for ub.cashbookrule .
    if valid-object(mQuery) then delete object mQuery.
    if valid-object(mQueryRule) then delete object mQueryRule.
    empty temp-table tt-cashbook .
    empty temp-table tt-cashbookrule .
    case v-firm :
      when 'все':U
      then do :
        case v-stat :
          when 'все':U
          then do :
            for each buf_cashbook no-lock :
              create tt-cashbook .
              buffer-copy buf_cashbook except buf_cashbook.RulePril buf_cashbook.RuleOsnPko to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and  buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
          when 'тек':U
          then do :
            for each buf_cashbook no-lock where buf_cashbook.status_ = 0:
              create tt-cashbook .
              buffer-copy buf_cashbook except buf_cashbook.RulePril buf_cashbook.RuleOsnPko to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and buf_cashbookrule.status_ = 0
                                                  and buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
          when 'удал':U
          then do :
            for each buf_cashbook no-lock where buf_cashbook.status_ = 1:
              create tt-cashbook .
              buffer-copy buf_cashbook except buf_cashbook.RulePril buf_cashbook.RuleOsnPko to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and buf_cashbookrule.status_ = 1
                                                  and  buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
        end case .
      end.
      otherwise
      do :
        case v-stat :
          when 'все':U
          then do :
            for each buf_cashbook no-lock :
              create tt-cashbook .
              buffer-copy buf_cashbook to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and buf_cashbookrule.host-code = v-firm
                                                  and buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                  tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
                  tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
          when 'тек':U
          then do :
            for each buf_cashbook no-lock where buf_cashbook.status_ = 0:
              create tt-cashbook .
              buffer-copy buf_cashbook to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and buf_cashbookrule.host-code = v-firm
                                                  and buf_cashbookrule.status_ = 0
                                                  and  buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
          when 'удал':U
          then do :
            for each buf_cashbook no-lock where buf_cashbook.status_ = 1:
              create tt-cashbook .
              buffer-copy buf_cashbook to tt-cashbook
              assign
                tt-cashbook.stat = if tt-cashbook.status_ = 0 then "Текущий" else if tt-cashbook.status_ = 1 then "Удаленный" else "?"
              .
              tt-cashbook.RulePril = getRulePrilName(integer(buf_cashbook.RulePril)) .
              tt-cashbook.RuleOsnPko = getRuleOsnName(buf_cashbook.RuleOsnPko) .
              ttCashbooksaturation(buffer tt-cashbook:handle).
              for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = buf_cashbook.id
                                                  and buf_cashbookrule.host-code = v-firm
                                                  and buf_cashbookrule.status_ = 1
                                                  and buf_cashbookrule.obj-type ne 'всем':U
                                                  break by buf_cashbookrule.obj-type desc
                                                        by buf_cashbookrule.obj-code:
                if first-of(buf_cashbookrule.obj-type)
                or first-of(buf_cashbookrule.obj-code)
                then do :
                  create tt-cashbookrule.
                  buffer-copy buf_cashbookrule to tt-cashbookrule .
                  tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
                end.
                fill_cashbookrule (buffer buf_cashbookrule) .
              end.
            end.
          end.
        end case .
      end.
    end case.
    if not valid-object(mQuery)
    then do:
       create query mQuery.
       mQuery:set-buffers(buffer tt-cashbook:HANDLE).
       mQuery:query-prepare("FOR EACH tt-cashbook").
    end.
    mQuery:query-open ().
    oQuery = mQuery.
    if not valid-object(mQueryRule)
    then do:
       create query mQueryRule.
       mQueryRule:set-buffers(buffer tt-cashbookrule:HANDLE).
       mQueryRule:query-prepare("FOR EACH tt-cashbookrule").
    end.
    mQueryRule:query-open ().
    oQueryRule = mQueryRule.
    return oQuery.
  end method.
  method public void getCashBookRule (input pCashBookId as int64, input pObjType as character, input pObjCode as integer, output dataset ds-cashbookrule) :
    define buffer buf_cashbookrule for ub.cashbookrule .
    for each buf_cashbookrule no-lock where buf_cashbookrule.cashbookId = pCashBookId
                                        and buf_cashbookrule.obj-code = pObjCode
                                        and buf_cashbookrule.obj-type = pObjType
                                        break by buf_cashbookrule.obj-type
                                              by buf_cashbookrule.obj-code:
      if first-of(buf_cashbookrule.obj-type)
      or first-of(buf_cashbookrule.obj-code)
      then do :
        create tt-cashbookrule.
        buffer-copy buf_cashbookrule to tt-cashbookrule .
        tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
      end.
      fill_cashbookrule (buffer buf_cashbookrule) .
    end.
  end method.
  method public character getSinglRule (input pCashBookId as int64, input pObjType as character, input pObjCode as integer, input pRuleCode as character ) :
    find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = pCashBookId
                                         and ub.CashBookRule.Obj-type   = pObjType
                                         and ub.CashBookRule.Obj-code   = pObjCode
                                         and ub.CashBookRule.Code       = pRuleCode
                                         no-error.
    if not available ub.CashBookRule
    then do :
      find first ub.clients no-lock where ub.clients.obj-type = pObjType
                                      and ub.clients.obj-code = pObjCode
                                      no-error.
      if not available ub.clients
      then do :
        return ? .
      end.
      find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = pCashBookId
                                           and ub.CashBookRule.Obj-type   = 'орг':U
                                           and ub.CashBookRule.Obj-code   = ub.clients.host-code
                                           and ub.CashBookRule.Code       = pRuleCode
                                           no-error.
      if not available ub.CashBookRule
      then do :
         find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = pCashBookId
                                              and ub.CashBookRule.Obj-type   = 'всем':U
                                              and ub.CashBookRule.Obj-code   = 0
                                              and ub.CashBookRule.Code       = pRuleCode
                                              no-error.
         if not available ub.CashBookRule
         then do :
            return ? .
         end.
      end.
    end.
    return ub.CashBookRule.RuleValue .
  end.
  method private void fill_cashbookrule (buffer buf_cashbookrule for ub.cashbookrule) :
    define variable v-cashbookrule-key-rec as character no-undo.
    case buf_cashbookrule.code :
      when "PkoMask"
      then do :
        tt-cashbookrule.PkoMask = buf_cashbookrule.RuleValue .
      end.
      when "RkoMask"
      then do :
        tt-cashbookrule.RkoMask = buf_cashbookrule.RuleValue .
      end.
      when "currPko"
      then do :
        objKeyRec:GenKeyRec ( input 'CashBookRule':U
                                            ,input buffer buf_cashbookrule:handle
                                            ,output v-cashbookrule-key-rec).
        find first clients where clients.obj-type eq tt-cashbookrule.obj-type
                             and clients.obj-code eq tt-cashbookrule.obj-code
                             no-lock no-error.
            if     available clients
               and clients.db-num ne ?
            then
        tt-cashbookrule.currPko = string(
                                         objcount:getCountValue(clients.db-num,
                                                                "cashbookrule",
                                                                v-cashbookrule-key-rec,
                                                                "currPKO")
                                         ).
      end.
      when "currRko"
      then do :
         objKeyRec:GenKeyRec ( input 'CashBookRule':U
                                            ,input buffer buf_cashbookrule:handle
                                            ,output v-cashbookrule-key-rec).
         find first clients where clients.obj-type eq tt-cashbookrule.obj-type
                             and clients.obj-code eq tt-cashbookrule.obj-code
                             no-lock no-error.
            if     available clients
               and clients.db-num ne ?
            then
         tt-cashbookrule.currRko = string(objcount:getCountValue(clients.db-num,
                                                                 "cashbookrule",
                                                                 v-cashbookrule-key-rec,
                                                                 "currRko")) .
      end.
      when "ManagerPosition"
      then do :
        tt-cashbookrule.ManagerPosition = getMgrPositionName(buf_cashbookrule.RuleValue) .
      end.
      when "ManagerFIO"
      then do :
        tt-cashbookrule.ManagerFIO = getMgrFioName(buf_cashbookrule.RuleValue) .
      end.
      when "BuhFIO"
      then do :
        tt-cashbookrule.BuhFIO = getBuhFioName(buf_cashbookrule.RuleValue) .
      end.
      when "Struct"
      then do :
        tt-cashbookrule.Struct = getStructName(integer(buf_cashbookrule.RuleValue)) .
      end.
      when "uchet"
      then do :
        tt-cashbookrule.uchet = getUchetName(integer(buf_cashbookrule.RuleValue)) .
      end.
      when "DptName"
      then do :
        tt-cashbookrule.DptName = buf_cashbookrule.RuleValue .
      end.
      when "DptType"
      then do :
        tt-cashbookrule.DptType = buf_cashbookrule.RuleValue .
      end.
      when "DptCode"
      then do :
        tt-cashbookrule.DptCode = integer(buf_cashbookrule.RuleValue) no-error .
      end.
      when "Pin"
      then do :
        tt-cashbookrule.Pin = buf_cashbookrule.RuleValue .
      end.
    end case.
  end method.
end class.
