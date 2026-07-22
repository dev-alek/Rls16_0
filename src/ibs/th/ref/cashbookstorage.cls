 
 /*------------------------------------------------------------------------
    File        : cashbookstorage
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Thu Feb 14 10:39:01 AST 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.cashbookstorage final: 
  {cmp/str-glbl.i class}
  
  { ibs/th/ref/ttCashBook.i }
  { ibs/th/ref/ttCashBookRule.i }
  
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
/*    if trim(tt-cashbook.CorrPkoVne) = ""                                        */
/*    then do :                                                                   */
/*      Msg = "Поле Кор. счет ПКО внереализационный доход не может быть пустым!" .*/
/*      return .                                                                  */
/*    end.                                                                        */
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
    /*if trim(tt-cashbook.RuleOsnRko) = ""
    then do :
      Msg = 'Правило заполнения графы "Основание" РКО не может быть пустым!' .
      return .
    end.*/
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
/*    if (trim(tt-cashbook.Vnecli-type) = ""                                                                                          */
/*    or tt-cashbook.Vnecli-code = ? or tt-cashbook.Vnecli-code <= 0) and tt-cashbook.id eq 0                                         */
/*    then do :                                                                                                                       */
/*      Msg = "Выберите контрагента для формирования платежей внереализационного дохода. Поле Контрагент (внереализационный доход)." .*/
/*      return .                                                                                                                      */
/*    end.                                                                                                                            */
   /* if trim(tt-cashbook.takenfrom) = ""
    then do :
      Msg = "Поле Принято от (авто) не может быть пустым!" .
      return .
    end.
    */
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
    if tt-cashbookrule.obj-type <> {&shop}
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
    
    if tt-cashbookrule.obj-type <> {&cmp}
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
         if lookup (vField:name,{&cashbookSysField}) eq 0
         then do:
            find first buf_field where buf_field._file-recid eq recid(buf_file) 
                                   and buf_field._Field-Name eq vField:name
            no-lock no-error.
            if not available buf_field
            then do:
               find first ub.CashBookrule where ub.CashBookRule.CashBookID eq iBuffer:buffer-field ("id"):buffer-value ()
                                            and ub.CashBookRule.Obj-type   eq {&by_all}
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
         if lookup (vField:name,{&cashbookSysField}) eq 0
         then do:
            find first buf_field where buf_field._file-recid eq recid(buf_file) 
                                   and buf_field._Field-Name eq vField:name
            no-lock no-error.
            if not available buf_field
            then do:
               find first ub.CashBookrule where ub.CashBookRule.CashBookID eq iBuffer:buffer-field ("id"):buffer-value ()
                                            and ub.CashBookRule.Obj-type   eq {&by_all}
                                            and ub.CashBookRule.Obj-code   eq 0
                                            and ub.CashBookRule.Code       eq vField:name
               exclusive-lock no-error.
               if not available  ub.CashBookrule
               then do:
                  create ub.CashBookRule.
                  assign
                     ub.CashBookRule.CashBookID = iBuffer:buffer-field ("id"):buffer-value ()
                     ub.CashBookRule.Obj-type   = {&by_all}
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
            objKeyRec:GenKeyRec ( input {&table_cashbookrule}
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
        for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = {&attr-cash-book-id}
                                              and ub.goods-attr.attr-value = string(ub.cashbook.id):
        delete ub.goods-attr .
      end.
      end.  
      else
      if ub.CashBook.Status_ = 1
      then do :
        ub.CashBook.Status_ = 0.
/*        for each ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = ub.cashbook.id :*/
/*          ub.CashBookRule.Status_ = ub.CashBook.Status_ .                                          */
/*        end.                                                                                       */
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
      for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = {&attr-cash-book-id}
                                              and ub.goods-attr.attr-value = string(ub.cashbook.id):
        delete ub.goods-attr .
      end.
    end.  
    else if ub.CashBook.Status_ = 1
    then do :
      ub.CashBook.Status_ = 0.
/*      for each ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = ub.cashbook.id :*/
/*        ub.CashBookRule.Status_ = ub.CashBook.Status_ .                                          */
/*      end.                                                                                       */
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
      when {&all}
      then do :
        case v-stat :
          when {&all}
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
                                                  and  buf_cashbookrule.obj-type ne {&by_all}
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
          when {&current-status}
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
                                                  and buf_cashbookrule.obj-type ne {&by_all}
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
          when {&deleted-status}
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
                                                  and  buf_cashbookrule.obj-type ne {&by_all}
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
          when {&all}
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
                                                  and buf_cashbookrule.obj-type ne {&by_all}
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
          when {&current-status}
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
                                                  and  buf_cashbookrule.obj-type ne {&by_all}
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
          when {&deleted-status}
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
                                                  and buf_cashbookrule.obj-type ne {&by_all}
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
                                           and ub.CashBookRule.Obj-type   = {&cmp}
                                           and ub.CashBookRule.Obj-code   = ub.clients.host-code
                                           and ub.CashBookRule.Code       = pRuleCode
                                           no-error.  
      if not available ub.CashBookRule
      then do :
         find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = pCashBookId
                                              and ub.CashBookRule.Obj-type   = {&by_all}
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
      when "PkoMask" /*маска ПКО*/
      then do :
        tt-cashbookrule.PkoMask = buf_cashbookrule.RuleValue .
      end.
      when "RkoMask" /*маска РКО*/
      then do :
        tt-cashbookrule.RkoMask = buf_cashbookrule.RuleValue .
      end.
      when "currPko" /*маска ПКО*/
      then do :
        objKeyRec:GenKeyRec ( input {&table_cashbookrule}
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
      when "currRko" /*маска РКО*/
      then do :
         objKeyRec:GenKeyRec ( input {&table_cashbookrule}
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
      when "ManagerPosition" /*Должность руководителя*/
      then do :
        tt-cashbookrule.ManagerPosition = getMgrPositionName(buf_cashbookrule.RuleValue) .
      end.
      when "ManagerFIO" /*Фио руководителя*/
      then do :
        tt-cashbookrule.ManagerFIO = getMgrFioName(buf_cashbookrule.RuleValue) .
      end.
      when "BuhFIO" /*Фио бухгалтера*/
      then do :
        tt-cashbookrule.BuhFIO = getBuhFioName(buf_cashbookrule.RuleValue) .
      end.
      when "Struct" /*Структурное подразделение*/
      then do :
        tt-cashbookrule.Struct = getStructName(integer(buf_cashbookrule.RuleValue)) .
      end.
      when "uchet" /*Учёт ведётся*/
      then do :
        tt-cashbookrule.uchet = getUchetName(integer(buf_cashbookrule.RuleValue)) .
      end.
      when "DptName" /*Наименование структурного подразделения по умолчанию*/
      then do :
        tt-cashbookrule.DptName = buf_cashbookrule.RuleValue .
      end.
      when "DptType" /*Тип структурного подразделения по умолчанию*/
      then do :
        tt-cashbookrule.DptType = buf_cashbookrule.RuleValue .
      end.
      when "DptCode" /*Код структурного подразделения по умолчанию*/
      then do :
        tt-cashbookrule.DptCode = integer(buf_cashbookrule.RuleValue) no-error .
      end.
      when "Pin" /*Код структурного подразделения по умолчанию*/
      then do :
        tt-cashbookrule.Pin = buf_cashbookrule.RuleValue .
      end.
    end case.
  end method.

end class.