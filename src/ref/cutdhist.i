{str/utd-err.i}
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
   if X_c-obj-hist.subject eq "utd"
   then
      run utd-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-err"
   then
      run utd-err-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-lines"
   then
      run utd-lines-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-marking-lines"
   then
      run utd-marking-lines-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-attr"
   then
      run utd-attr-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-err-attr"
   then
      run utd-err-attr-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-lines-attr"
   then
      run utd-lines-attr-proc (output odescription).
   else if X_c-obj-hist.subject eq "utd-marking-lines-attr"
   then
      run utd-marking-lines-attr-proc (output odescription).
   
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .
   for each X_c-obj-hist :
      delete X_c-obj-hist.
   end.
   if p-mode eq "one"
   then do:
      if p-chip-num eq ?
      then do:
         for each {&buf_obj-hist} where {&buf_obj-hist}.DB-NUM = p-DB-NUM-utd  
                                    and {&buf_obj-hist}.doc-id = p-doc-id-utd
                                    and {&buf_obj-hist}.corr-user-db-num = v-corr-user-db-num
         no-lock:
            create X_c-obj-hist.
            buffer-copy {&buf_obj-hist} to X_c-obj-hist.
         end.
      end.
      else do:
         for each {&buf_obj-hist} where {&buf_obj-hist}.corr-user-db-num   eq v-corr-user-db-num
                                    and {&buf_obj-hist}.chip-num           eq p-chip-num  
         no-lock:
            &glob addTable utd-err
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-lines
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-marking-lines
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-attr
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
                                   
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-err-attr
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-lines-attr
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd-marking-lines-attr
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            &glob addTable utd
            for each c-{&addTable} where c-{&addTable}.corr-user-db-num   eq v-corr-user-db-num
                                   and c-{&addTable}.chip-num           eq p-chip-num
                                   
            no-lock:
               create X_c-obj-hist.
               buffer-copy {&buf_obj-hist} to X_c-obj-hist.
               buffer-copy c-{&addTable} to X_c-obj-hist
               assign 
                  X_c-obj-hist.subject = "{&addTable}"
               .
            end.
            
         end.
      end.
   end.
   
     
{ gbl/fltopend.i
          &where-cond = " TRUE "
          
          &by         = " by X_c-obj-hist.chip-num  " }
  
  return true.
end.

function  getStsMark returns character (ists as int ):
   
   return StatusMark:GetLabel(ists).
   
end.


function  getStsTh returns character (ists as int ):
   
   return StatusTH:GetLabel(ists).
   
end.
function  getStsEdi returns character (ists as int ):
   
   return if ists eq 0 then "" else StatusEDI:GetLabel(ists).
   
end.
function  getStsEdocType returns character (itype as int ):
   
   return if itype eq 0 then "" else  EdocType:GetLabel(itype).
   
end.

procedure utd-proc :
define output parameter p-description as character no-undo .
define buffer current_c-utd for ub.c-utd  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-utd no-lock where
               current_c-utd.db-num = X_c-obj-hist.db-num
           and current_c-utd.doc-id = X_c-obj-hist.doc-id
       
          and current_c-utd.chip-num = X_c-obj-hist.chip-num
          and current_c-utd.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-utd then do:
      v-mess = "Неверная ссылка на c-utd в таблице c-utd-head".
     
      return error  v-mess .
  end.
 
&scop fields-name-list "DocumentExt,OrganizationExt,LoadDate,parentDocumentExt,parentOrganizationExt,RevocationStatus,RecipientResponseStatus,TypeId,CounteragentId,~
CustomDocumentId,DocumentNumber,DocumentDate,Timestamp,ReceiptStatus,Direction,ModifyDate,PackageId,EDocType,AmendmentRequested,BaseDocumentNumber,BaseDocumentName,~
BaseDocumentDate,cli-FnsParticipantId,cli-info,obj-FnsParticipantId,obj-info,sts,sts-edi,cli-type,cli-code,host-code,contract-code,obj-type,obj-code,~
ModifyTime,doc-code,AdditInfo,comment,db-num,doc-id"

define variable v-label-param as character no-undo .
  v-label-param =
   "OrganizationExt"     + {&delim-par} + "ID организации в ЭДО"                              + {&delim-par} + "" + {&delim-flf}
 + "DocumentExt" + {&delim-par} + "ID документа в ЭДО"                          + {&delim-par} + "" + {&delim-flf}
 + "LoadDate"      + {&delim-par} + "Дата загрузки"    + {&delim-par} + "" + {&delim-flf}
 + "parentOrganizationExt"     + {&delim-par} + "ID организации в родительском документе в ЭДО"   + {&delim-par} + "" + {&delim-flf}
 + "parentDocumentExt"      + {&delim-par} + "ID родительского документа в ЭДО"                                + {&delim-par} + "" + {&delim-flf}
 + "RevocationStatus"       + {&delim-par} + "Статус аннулирования документа" + {&delim-par} + "" + {&delim-flf}
 + "RecipientResponseStatus"  + {&delim-par} + "Состояние ответного действия"        + {&delim-par} + "" + {&delim-flf}
 + "TypeId"  + {&delim-par} + "Тип документа ЭДО"                    + {&delim-par} + "" + {&delim-flf}
 + "CounteragentId"     + {&delim-par} + "Контрагент документа"                       + {&delim-par} + "" + {&delim-flf}
 + "CustomDocumentId"     + {&delim-par} + "Идентификатор документа, определяемый внешней системой"                       + {&delim-par} + "" + {&delim-flf}
 + "DocumentNumber"    + {&delim-par} + "Номер документа"                            + {&delim-par} + "" + {&delim-flf}
 + "DocumentDate"     + {&delim-par} + "Дата документа"                       + {&delim-par} + "" + {&delim-flf}
 + "Timestamp"    + {&delim-par} + "Дата и время создания в ЭДО"                            + {&delim-par} + "" + {&delim-flf}
 + "ReceiptStatus"     + {&delim-par} + "Состояние ИОП на документ"                       + {&delim-par} + "" + {&delim-flf}
 + "Direction"    + {&delim-par} + "Направление документа"                            + {&delim-par} + "" + {&delim-flf}
 + "ModifyDate"     + {&delim-par} + "Дата изменения"                       + {&delim-par} + "" + {&delim-flf}
 + "ModifyTime"     + {&delim-par} + "Время изменения"                       + {&delim-par} + "" + {&delim-flf}
 + "PackageId"    + {&delim-par} + "ID пакета в ЭДО"                            + {&delim-par} + "" + {&delim-flf}
 + "EDocType"     + {&delim-par} + "Тип документа"                       + {&delim-par} + "getStsEdocType" + {&delim-flf}
 + "AmendmentRequested"    + {&delim-par} + "Зарошена корректировка"                            + {&delim-par} + "" + {&delim-flf}
 + "BaseDocumentNumber"     + {&delim-par} + "Номер договора"                       + {&delim-par} + "" + {&delim-flf}
 + "BaseDocumentName"    + {&delim-par} + "Наименование договора"                            + {&delim-par} + "" + {&delim-flf}
 + "BaseDocumentDate"     + {&delim-par} + "Дата договора"                       + {&delim-par} + "" + {&delim-flf}
 + "cli-FnsParticipantId"    + {&delim-par} + "ID подразделения отправителя"                            + {&delim-par} + "" + {&delim-flf}
 + "cli-info"    + {&delim-par} + "Инф. отправителя"                            + {&delim-par} + "" + {&delim-flf}
 + "obj-FnsParticipantId"     + {&delim-par} + "ID подразделения получателя"                       + {&delim-par} + "" + {&delim-flf}
 + "obj-info"    + {&delim-par} + "Инф. получателя"                            + {&delim-par} + "" + {&delim-flf}
 + "sts"     + {&delim-par} + "Статус TH"                       + {&delim-par} + "getStsTh" + {&delim-flf}
 + "sts-edi"    + {&delim-par} + "Статус ЭДО"                            + {&delim-par} + "getStsEdi" + {&delim-flf}
 + "cli-type"    + {&delim-par} + "Тип отправителя"                            + {&delim-par} + "" + {&delim-flf}
 + "cli-code"     + {&delim-par} + "Код отправителя"                       + {&delim-par} + "" + {&delim-flf}
 + "host-code"    + {&delim-par} + "Фирма"                            + {&delim-par} + "" + {&delim-flf}
 + "obj-type"     + {&delim-par} + "Тип объекта"                       + {&delim-par} + "" + {&delim-flf}
 + "obj-code"    + {&delim-par} + "Код объекта"                            + {&delim-par} + "" + {&delim-flf}
 + "doc-code"    + {&delim-par} + "Номер накладной"                            + {&delim-par} + "" + {&delim-flf}
 + "total"    + {&delim-par} + "Сумма"                            + {&delim-par} + "" + {&delim-flf}
 + "comment"    + {&delim-par} + "Комментарий"                            + {&delim-par} + "" + {&delim-flf}
 + "Vat"    + {&delim-par} + "НДС"                            + {&delim-par} + "" + {&delim-flf}
  
 + "AdditInfo"        + {&delim-par} + "Ошибки"  + {&delim-par} + ""  + {&delim-flf}
 + "db-num"     + {&delim-par} + "db-num"  + {&delim-par} + "" + {&delim-flf}
 + "doc-id"     + {&delim-par} + "doc-id"  + {&delim-par} + "".

  run proc-full-temp-changes in this-procedure (
                                               input current_c-utd.action = integer({&hn-create})
                                              ,input current_c-utd.action = integer({&hn-delete})
                                              ,input  buffer current_c-utd:handle
                                              ,input  "utd" /*{&table_utd}*/
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* utd-proc */

procedure utd-attr-proc :
define output parameter p-description as character no-undo .
&glob tab-attr utd-attr
define buffer current_c-{&tab-attr} for ub.c-{&tab-attr}  .
define variable v-mess as character no-undo.

   do
   on error undo, return error return-value
   :
     find first current_c-{&tab-attr} no-lock where
                  current_c-{&tab-attr}.db-num = X_c-obj-hist.db-num
              and current_c-{&tab-attr}.doc-id = X_c-obj-hist.doc-id
             and current_c-{&tab-attr}.attr-code = X_c-obj-hist.attr-code
             and current_c-{&tab-attr}.chip-num = X_c-obj-hist.chip-num
             and current_c-{&tab-attr}.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
     if not avail current_c-{&tab-attr} then do:
         v-mess = "Неверная ссылка на c-{&tab-attr} в таблице c-utd-head".
        
         return error  v-mess .
     end.
      &scop fields-name-list "attr-code,attr-value"
   
   define variable v-label-param as character no-undo .
     v-label-param =
      "attr-code"     + {&delim-par} + "атрибут"                              + {&delim-par} + "" + {&delim-flf}
    + "attr-value"        + {&delim-par} + "Значение атрибута"  + {&delim-par} + "" .
      
     run proc-full-temp-changes in this-procedure (
                                                  input current_c-{&tab-attr}.action = integer({&hn-create})
                                                 ,input current_c-{&tab-attr}.action = integer({&hn-delete})
                                                 ,input  buffer current_c-{&tab-attr}:handle
                                                 ,input  "{&tab-attr}" /*{&table_utd}*/
                                                 ,input  {&fields-name-list}
                                                 ,input  v-label-param).
   end.
end.
define variable mCheckType as character no-undo.
define variable mCodeErr as character no-undo.

function  err-text returns character (iCheckObj as character ):
   
   return if iCheckObj  eq "" then "" else GetTextErrortype( mCheckType, mCodeErr, iCheckObj,"all").
   
end.

procedure utd-err-proc :
define output parameter p-description as character no-undo .
define buffer current_c-utd-err for ub.c-utd-err  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-utd-err no-lock where
               current_c-utd-err.db-num = X_c-obj-hist.db-num
           and current_c-utd-err.doc-id = X_c-obj-hist.doc-id
       and current_c-utd-err.CheckType = X_c-obj-hist.CheckType
       and current_c-utd-err.CodeErr = X_c-obj-hist.CodeErr
       and current_c-utd-err.CheckObj = X_c-obj-hist.CheckObj
       and current_c-utd-err.reckey = X_c-obj-hist.reckey
          and current_c-utd-err.chip-num = X_c-obj-hist.chip-num
          and current_c-utd-err.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-utd-err then do:
      v-mess = "Неверная ссылка на c-utd в таблице c-utd-head".
     
      return error  v-mess .
  end.
 mCheckType = current_c-utd-err.CheckType.
 mCodeErr = current_c-utd-err.CodeErr.
 
         
&scop fields-name-list "CheckType,CodeErr,CheckObj,reckey,LineNum"

define variable v-label-param as character no-undo .
  v-label-param =
   "CheckType"     + {&delim-par} + "Тип ошибки"                              + {&delim-par} + "" + {&delim-flf}
 + "LineNum" + {&delim-par} + "Линия"                          + {&delim-par} + "" + {&delim-flf}
 + "CodeErr" + {&delim-par} + "Код ошибки"                          + {&delim-par} + "" + {&delim-flf}
 + "CheckObj"      + {&delim-par} + "Текст"    + {&delim-par} + "err-text" + {&delim-flf}
 + "reckey"        + {&delim-par} + "ключ записи с ошибкой"  + {&delim-par} + "" .

  run proc-full-temp-changes in this-procedure (
                                               input current_c-utd-err.action = integer({&hn-create})
                                              ,input current_c-utd-err.action = integer({&hn-delete})
                                              ,input  buffer current_c-utd-err:handle
                                              ,input  "utd-err" /*{&table_utd}*/
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure.

&glob tab-attr utd-err-attr
procedure {&tab-attr}-proc :
define output parameter p-description as character no-undo .

define buffer current_c-{&tab-attr} for ub.c-{&tab-attr}  .
define variable v-mess as character no-undo.

   do
   on error undo, return error return-value
   :
     find first current_c-{&tab-attr} no-lock where
                  current_c-{&tab-attr}.db-num = X_c-obj-hist.db-num
              and current_c-{&tab-attr}.doc-id = X_c-obj-hist.doc-id
              and current_c-{&tab-attr}.CheckType = X_c-obj-hist.CheckType
              and current_c-{&tab-attr}.CodeErr = X_c-obj-hist.CodeErr
              and current_c-{&tab-attr}.CheckObj = X_c-obj-hist.CheckObj
              and current_c-{&tab-attr}.reckey = X_c-obj-hist.reckey
             and current_c-{&tab-attr}.attr-code = X_c-obj-hist.attr-code
             and current_c-{&tab-attr}.chip-num = X_c-obj-hist.chip-num
             and current_c-{&tab-attr}.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
     if not avail current_c-{&tab-attr} then do:
         v-mess = "Неверная ссылка на c-{&tab-attr} в таблице c-utd-head".
        
         return error  v-mess .
     end.
      &scop fields-name-list "CheckType,CodeErr,CheckObj,reckey,attr-code,attr-value,LineNum"
   
   define variable v-label-param as character no-undo .
     v-label-param =
     "CheckType"     + {&delim-par} + "Тип ошибки"                              + {&delim-par} + "" + {&delim-flf}
+ "LineNum" + {&delim-par} + "Линия"                          + {&delim-par} + "" + {&delim-flf}
 
    + "CodeErr" + {&delim-par} + "Код ошибки"                          + {&delim-par} + "" + {&delim-flf}
    + "CheckObj"      + {&delim-par} + "Текст"    + {&delim-par} + "err-text" + {&delim-flf}
    + "reckey"        + {&delim-par} + "ключ записи с ошибкой"  + {&delim-par} + "" + {&delim-flf}
    + "attr-code"     + {&delim-par} + "атрибут"                              + {&delim-par} + "" + {&delim-flf}
    + "attr-value"        + {&delim-par} + "Значение атрибута"  + {&delim-par} + "" .
      
     run proc-full-temp-changes in this-procedure (
                                                  input current_c-{&tab-attr}.action = integer({&hn-create})
                                                 ,input current_c-{&tab-attr}.action = integer({&hn-delete})
                                                 ,input  buffer current_c-{&tab-attr}:handle
                                                 ,input  "{&tab-attr}" /*{&table_utd}*/
                                                 ,input  {&fields-name-list}
                                                 ,input  v-label-param).
   end.
end.

procedure utd-lines-proc :
define output parameter p-description as character no-undo .
define buffer current_c-utd-lines for ub.c-utd-lines  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-utd-lines no-lock where
               current_c-utd-lines.db-num = X_c-obj-hist.db-num
           and current_c-utd-lines.doc-id = X_c-obj-hist.doc-id
           and current_c-utd-lines.linenum = X_c-obj-hist.linenum
          and current_c-utd-lines.chip-num = X_c-obj-hist.chip-num
          and current_c-utd-lines.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-utd-lines then do:
      v-mess = "Неверная ссылка на c-utd-lines в таблице c-utd-head".
     
      return error  v-mess .
  end.
 

         
&scop fields-name-list "LineNum,ProductCode,Article,UnitCode,ParcelType,TaxRate,Vat,Total,Quantity,TotalWithVatExcluded,gds-code,GdsName,sts"

define variable v-label-param as character no-undo .
  v-label-param =
   "LineNum"     + {&delim-par} + "Номер линии"                              + {&delim-par} + "" + {&delim-flf}
 + "ProductCode" + {&delim-par} + "Товар в ЭДО"                          + {&delim-par} + "" + {&delim-flf}
 + "Article"      + {&delim-par} + "Артикл в ЭДО"    + {&delim-par} + "" + {&delim-flf}
 + "UnitCode" + {&delim-par} + "Ед. в ЭДО"                          + {&delim-par} + "" + {&delim-flf}
/* + "ParcelType"      + {&delim-par} + "Текст"    + {&delim-par} + "err-text" + {&delim-flf}*/
 + "TaxRate" + {&delim-par} + "НДС,%"                          + {&delim-par} + "" + {&delim-flf}
 + "Vat"      + {&delim-par} + "Сумма НДС"    + {&delim-par} + "" + {&delim-flf}
 + "Total" + {&delim-par} + "Сумма"                          + {&delim-par} + "" + {&delim-flf}
 + "TotalWithVatExcluded"      + {&delim-par} + "Сумма без ндс"    + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара"                          + {&delim-par} + "" + {&delim-flf}
/* + "GdsName"      + {&delim-par} + "Наименование"    + {&delim-par} + "" + {&delim-flf}*/
 + "sts"        + {&delim-par} + "Статус"  + {&delim-par} + "".

  run proc-full-temp-changes in this-procedure (
                                               input         current_c-utd-lines.action = integer({&hn-create})
                                              ,input         current_c-utd-lines.action = integer({&hn-delete})
                                              ,input  buffer current_c-utd-lines:handle
                                              ,input                  "utd-lines" /*{&table_utd}*/
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure.

&glob tab-attr utd-lines-attr
procedure {&tab-attr}-proc :
define output parameter p-description as character no-undo .

define buffer current_c-{&tab-attr} for ub.c-{&tab-attr}  .
define variable v-mess as character no-undo.

   do
   on error undo, return error return-value
   :
     find first current_c-{&tab-attr} no-lock where
                  current_c-{&tab-attr}.db-num = X_c-obj-hist.db-num
              and current_c-{&tab-attr}.doc-id = X_c-obj-hist.doc-id
              and current_c-{&tab-attr}.linenum = X_c-obj-hist.linenum
             and current_c-{&tab-attr}.attr-code = X_c-obj-hist.attr-code
             and current_c-{&tab-attr}.chip-num = X_c-obj-hist.chip-num
             and current_c-{&tab-attr}.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
     if not avail current_c-{&tab-attr} then do:
         v-mess = "Неверная ссылка на c-{&tab-attr} в таблице c-utd-head".
        
         return error  v-mess .
     end.
      &scop fields-name-list "LineNum,attr-code,attr-value"
   
   define variable v-label-param as character no-undo .
     v-label-param =
     "LineNum"     + {&delim-par} + "Номер линии"                              + {&delim-par} + "" + {&delim-flf}
     + "attr-code"     + {&delim-par} + "атрибут"                              + {&delim-par} + "" + {&delim-flf}
     + "attr-value"        + {&delim-par} + "Значение атрибута"  + {&delim-par} + "" .
      
     run proc-full-temp-changes in this-procedure (
                                                  input current_c-{&tab-attr}.action = integer({&hn-create})
                                                 ,input current_c-{&tab-attr}.action = integer({&hn-delete})
                                                 ,input  buffer current_c-{&tab-attr}:handle
                                                 ,input  "{&tab-attr}" /*{&table_utd}*/
                                                 ,input  {&fields-name-list}
                                                 ,input  v-label-param).
   end.
end.

procedure utd-marking-lines-proc :
define output parameter p-description as character no-undo .
define buffer current_c-utd-marking-lines for ub.c-utd-marking-lines  .
define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  find first current_c-utd-marking-lines no-lock where
               current_c-utd-marking-lines.db-num = X_c-obj-hist.db-num
           and current_c-utd-marking-lines.doc-id = X_c-obj-hist.doc-id
           and current_c-utd-marking-lines.linenum = X_c-obj-hist.linenum
        and current_c-utd-marking-lines.mark = X_c-obj-hist.mark
          and current_c-utd-marking-lines.chip-num = X_c-obj-hist.chip-num
          and current_c-utd-marking-lines.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
  if not avail current_c-utd-marking-lines then do:
      v-mess = "Неверная ссылка на c-utd-lines в таблице c-utd-head".
     
      return error  v-mess .
  end.
         
&scop fields-name-list "LineNum,doc-level,site,gds-code,mark,sts"

define variable v-label-param as character no-undo .
  v-label-param =
   "LineNum"     + {&delim-par} + "Номер линии"                              + {&delim-par} + "" + {&delim-flf}
 + "doc-level " + {&delim-par} + "Уровень вложености марки( 1 привязан к документу) "                          + {&delim-par} + "" + {&delim-flf}
 + "site"      + {&delim-par} + "Сторона (- Возврат)"    + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара"                          + {&delim-par} + "" + {&delim-flf}
 + "mark" + {&delim-par} + "Марка"                          + {&delim-par} + "" + {&delim-flf}
 + "sts"        + {&delim-par} + "Статус"  + {&delim-par} + "getStsMark" .

  run proc-full-temp-changes in this-procedure (
                                               input         current_c-utd-marking-lines.action = integer({&hn-create})
                                              ,input         current_c-utd-marking-lines.action = integer({&hn-delete})
                                              ,input  buffer current_c-utd-marking-lines:handle
                                              ,input                  "utd-marking-lines" /*{&table_utd}*/
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure.
&glob tab-attr utd-marking-lines-attr
procedure {&tab-attr}-proc :
define output parameter p-description as character no-undo .

   define buffer current_c-{&tab-attr} for ub.c-{&tab-attr}  .
   define variable v-mess as character no-undo.
   
   do
   on error undo, return error return-value
   :
     find first current_c-{&tab-attr} no-lock where
                  current_c-{&tab-attr}.db-num = X_c-obj-hist.db-num
              and current_c-{&tab-attr}.doc-id = X_c-obj-hist.doc-id
              and current_c-{&tab-attr}.linenum = X_c-obj-hist.linenum
              and current_c-{&tab-attr}.mark = X_c-obj-hist.mark
             and current_c-{&tab-attr}.attr-code = X_c-obj-hist.attr-code
             and current_c-{&tab-attr}.chip-num = X_c-obj-hist.chip-num
             and current_c-{&tab-attr}.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
     if not avail current_c-{&tab-attr} then do:
         v-mess = "Неверная ссылка на c-{&tab-attr} в таблице c-utd-head".
        
         return error  v-mess .
     end.
      &scop fields-name-list "LineNum,mark,attr-code,attr-value"
   
   define variable v-label-param as character no-undo .
     v-label-param =
     "LineNum"     + {&delim-par} + "Номер линии"                              + {&delim-par} + "" + {&delim-flf}
     + "mark" + {&delim-par} + "Марка"                          + {&delim-par} + "" + {&delim-flf}
     + "attr-code"     + {&delim-par} + "атрибут"                              + {&delim-par} + "" + {&delim-flf}
     + "attr-value"        + {&delim-par} + "Значение атрибута"  + {&delim-par} + "" .
      
     run proc-full-temp-changes in this-procedure (
                                                  input current_c-{&tab-attr}.action = integer({&hn-create})
                                                 ,input current_c-{&tab-attr}.action = integer({&hn-delete})
                                                 ,input  buffer current_c-{&tab-attr}:handle
                                                 ,input  "{&tab-attr}" /*{&table_utd}*/
                                                 ,input  {&fields-name-list}
                                                 ,input  v-label-param).
   end.
end.

PROCEDURE proc-find-obj-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-obj-code as character no-undo.

if p-obj-code = "" then return .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input true  /* p-find-next  */
    ,input substitute("and X_c-obj-hist.doc-id = &1 "
      , p-obj-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-obj-code in frame Dialog-Frame.
END PROCEDURE.
