define input  parameter pid as int64 no-undo.
define variable vlable as character no-undo.
{ref/brwhist.i &Paramonly = yes &buf_obj-hist = c-cashbook-head}
vlable = if p-mode eq "one"  then "История по кассовой книге " + string(pid) else "История по кассовым книгам". 
{ref/brwhist.i 
  &buf_obj-hist = c-cashbook-head 
  &objhead = yes 
  &lable = vlable
  &browse-fields="X_c-obj-hist.id COLUMN-LABEL 'Код!КК' FORMAT '>>9':U"
}

function get-subject returns character
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-obj-hist-code p-subject
  return p-subject.   /* Function return value. */

end function.
 
procedure local-view-cange:
   define output parameter odescription as character no-undo.
   if X_c-obj-hist.subject eq "cashbook"
   then
      run cashbook-proc (output odescription).
   else if X_c-obj-hist.subject eq "cashbookrule"
   then
      run cashbookrule-proc (output odescription).
   else if X_c-obj-hist.subject eq "c-goods-attr-any"
   then
      run cashbookgds-proc (output odescription).
   else
         
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .

     if p-mode eq "one"
     then do:
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-obj-hist.id         = pid  or ~
          X_c-obj-hist.cashbookid = pid  "
          &dyn_where-cond = " substitute('  X_c-obj-hist.id  = &1  or ~
          X_c-obj-hist.cashbookid  = &1 ', pid)  "

          &use-ind    = " "
          &by         = " by X_c-obj-hist.chip-num " }
     end.
     else do:
     
{ gbl/fltopend.i
          &where-cond = " TRUE "
          
          &by         = "  " }
     end.
  return true.
end.

procedure cashbook-proc :
define output parameter p-description as character no-undo .
define buffer current_c-cashbook for ub.c-cashbook  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-cashbook no-lock where
              current_c-cashbook.id = X_c-obj-hist.id
       
          and current_c-cashbook.chip-num = X_c-obj-hist.chip-num
          and current_c-cashbook.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-cashbook then do:
      v-mess = "Неверная ссылка на c-cashbook в таблице c-cashbook-head".
     
      return error  v-mess .
  end.
 
&scop fields-name-list "ext-code,CashBookName,RuleOsn,RulePril,Status_,Credit,FlagSepCash,FlagSepFull,Debit,cli-type,cli-code,takenfrom"

define variable v-label-param as character no-undo .
  v-label-param =
   "ext-code"     + {&delim-par} + "ext-code"                              + {&delim-par} + "" + {&delim-flf}
 + "CashBookName" + {&delim-par} + "Наименование"                          + {&delim-par} + "" + {&delim-flf}
 + "RuleOsn"      + {&delim-par} + "Правило заполнения графы Основание"    + {&delim-par} + "" + {&delim-flf}
 + "RulePril"     + {&delim-par} + "Правило заполнения графы Приложение"   + {&delim-par} + "" + {&delim-flf}
 + "Status_"      + {&delim-par} + "Статус"                                + {&delim-par} + "" + {&delim-flf}
 + "Credit"       + {&delim-par} + "Значение для заполнения поля «кредит»" + {&delim-par} + "" + {&delim-flf}
 + "FlagSepCash"  + {&delim-par} + "Отдельный ПКО для каждой кассы"        + {&delim-par} + "" + {&delim-flf}
 + "FlagSepFull"  + {&delim-par} + "Раздельно НП и ТНП"                    + {&delim-par} + "" + {&delim-flf}
 + "cli-type"     + {&delim-par} + "Тип контрагента"                       + {&delim-par} + "" + {&delim-flf}
 + "cli-code"     + {&delim-par} + "Код контрагента"                       + {&delim-par} + "" + {&delim-flf}
 + "takenfrom"    + {&delim-par} + "Принято от"                            + {&delim-par} + "" + {&delim-flf}
 + "Debit"        + {&delim-par} + "Значение для заполнения поля «дебет»"  + {&delim-par} + "" .

  run proc-full-temp-changes in this-procedure (
                                               input current_c-cashbook.action = integer({&hn-create})
                                              ,input current_c-cashbook.action = integer({&hn-delete})
                                              ,input  buffer current_c-cashbook:handle
                                              ,input  {&table_cashbook}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* cashbook-proc */

procedure cashbookrule-proc :
define output parameter p-description as character no-undo .
define buffer current_c-cashbookrule for ub.c-cashbookrule  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-cashbookrule no-lock where
              current_c-cashbookrule.cashbookid = X_c-obj-hist.cashbookid
          and current_c-cashbookrule.Obj-code = X_c-obj-hist.Obj-code
          and current_c-cashbookrule.Obj-type = X_c-obj-hist.Obj-type    
       
          and current_c-cashbookrule.chip-num = X_c-obj-hist.chip-num
          and current_c-cashbookrule.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-cashbookrule then do:
      v-mess = "Неверная ссылка на c-cashbook в таблице c-cashbook-head".
     
      return error  v-mess .
  end.
  
&scop fields-name-list "RuleValue"
define variable v-label-param as character no-undo .
  v-label-param =
   "RuleValue"     + {&delim-par} + 
       ( if  current_c-cashbookrule.Code eq "PkoMask" then "Маска ПКО"  
    else if  current_c-cashbookrule.Code eq "RkoMask" then "Маска РКО"
    else if  current_c-cashbookrule.Code eq "currPko" then "Текущий ПКО"
    else if  current_c-cashbookrule.Code eq "currRko" then "Текущий РКО"
    else if  current_c-cashbookrule.Code eq "ManagerPosition" then "Должность руководителя"
    else if  current_c-cashbookrule.Code eq "ManagerFIO" then "ФИО руководителя "
    else if  current_c-cashbookrule.Code eq "BuhFIO" then "ФИО бухгалтера"
    else if  current_c-cashbookrule.Code eq "Struct" then "Структурное подразделение"
    else if  current_c-cashbookrule.Code eq "uchet" then "Учёт ведется"
    else if  current_c-cashbookrule.Code eq "DptName" then "Наименование структурного подразделения по умлочанию"
    else if  current_c-cashbookrule.Code eq "DptType" then "Тип структурного подразделения по умлочанию"
    else if  current_c-cashbookrule.Code eq "DptCode" then "Код структурного подразделения по умлочанию"
    else if  current_c-cashbookrule.Code eq "Pin" then "Пин"
    else string(current_c-cashbookrule.Code) )
    
    
    
    
                               + {&delim-par} + "" .
    

  run proc-full-temp-changes in this-procedure (
                                               input current_c-cashbookrule.action = integer({&hn-create})
                                              ,input current_c-cashbookrule.action = integer({&hn-delete})
                                              ,input  buffer current_c-cashbookrule:handle
                                              ,input  {&table_cashbookrule}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* cashbookrule-proc */
procedure cashbookgds-proc :
define output parameter p-description as character no-undo .
define buffer current_c-goods-attr-any for ub.c-goods-attr-any  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-goods-attr-any no-lock where
             current_c-goods-attr-any.Bush               = "cashbook"
         and current_c-goods-attr-any.attr-code          = "cashbookid"
         and current_c-goods-attr-any.attr-value         = string(X_c-obj-hist.cashbookid)  
         and current_c-goods-attr-any.chip-num             = X_c-obj-hist.chip-num
         and current_c-goods-attr-any.corr-user-db-num     = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-goods-attr-any then do:
      v-mess = "Неверная ссылка на c-goods-attr-any в таблице c-cashbook-head".
     
      return error  v-mess .
  end.
  
&scop fields-name-list "gds-code"
define variable v-label-param as character no-undo .
  v-label-param =
   "gds-code"     + {&delim-par} + "Код товара " + {&delim-par} + "" .
    

  run proc-full-temp-changes in this-procedure (
                                               input current_c-goods-attr-any.action = integer({&hn-create})
                                              ,input current_c-goods-attr-any.action = integer({&hn-delete})
                                              ,input  buffer current_c-goods-attr-any:handle
                                              ,input  {&table_goods-attr}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* cashbookrule-proc */