function getStsName returns character (iSts as int ):
  define variable thMarkSts  as class ibs.th.str.marking.sts.mark no-undo.
  thMarkSts = ObjSrv:Env:Marking:Sts:Mark.

  return thMarkSts:GetLabel(iSts).
end.

function getOnlineResultName returns character (iOnlineResult as int ):
  define variable vNames as character no-undo
    init "Запрет продажи,Продажа разрешена,Необходимо проверить сроки годности".   
  return if iOnlineResult = ? then "null" else entry(iOnlineResult + 1, vNames).
end.

function formatLogicalValue returns character (iValue as character ):
  return if iValue = "" then ? else string(logical(iValue),"Да/Нет").
end.

function formatValue returns character (iValue as character ):
  define variable vLog as logical no-undo. 
  define variable vDec as decimal no-undo.
  define variable vChr as character no-undo.
  
  vChr = iValue.
  
  if iValue <> "" then do:
      vLog = logical(iValue) no-error.
      if vLog <> ? then vChr = string(vLog,"Да/Нет").
      else do:
         vDec = decimal(iValue) no-error.
         if vDec <> ? then vChr = string(vDec).          
      end.   
  end.    
  return vChr.
end.

function getAttributeName returns character (iCode as character ):
  return 
    if iCode = "notOnlineCheck" 
      then "Игнорировать результат online-проверки"
      else if iCode = "weight" then "Вес"
      else "Значение атрибута " + iCode. 
end.

&glob tt_name temp-changes
procedure ParentPars:
   define input  parameter iOldBuf as handle no-undo.
   define input  parameter iCurBuf as handle no-undo.
end.

function get-subject returns character
  ( p-subject as character ) :
  
  return if p-subject = "marking" then "Марка" else "Атрибут марки".

end function.
 
procedure local-view-cange:
  define output parameter odescription as character no-undo.
  
  define buffer current_c-marking for ub.c-marking  .
  define variable v-mess as character no-undo.

  &if defined(head) &then
   if X_c-obj-hist.subject <> "marking"
   then
      run getMarkingAttr (output odescription).
   else
  &endif
      run getMarking (output odescription).
end procedure.

procedure getMarking:
  define output parameter p-description as character no-undo .

  define buffer current_c-marking for ub.c-marking.
  define variable v-mess as character no-undo.
  
  do
  on error undo, return error return-value
  :
    find first current_c-marking no-lock where
               current_c-marking.mark = X_c-obj-hist.mark
           and current_c-marking.chip-num = X_c-obj-hist.chip-num
           and current_c-marking.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
    if not avail current_c-marking then do:
        v-mess = "Неверная ссылка на марку в таблице c-marking".
        return error  v-mess .
    end.
    &scop fields-name-list "sts,last-change,online-result"
    define variable v-label-param as character no-undo .
    v-label-param =
          "sts"   + {&delim-par} + "Статус" + {&delim-par} + "getStsName" + {&delim-flf}
        + "last-change" + {&delim-par} + "Изменен" + {&delim-par} + "" + {&delim-flf}
        + "online-result" + {&delim-par} + "Результат ГИС МТ" + {&delim-par} + "getOnlineResultName".
    run proc-full-temp-changes in this-procedure (
                                                 input current_c-marking.action = integer({&hn-create})
                                                ,input current_c-marking.action = integer({&hn-delete})
                                                ,input  buffer current_c-marking:handle
                                                ,input  "marking"
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).
  end.
end procedure. /* getMarking */

procedure getMarkingAttr:
  define output parameter p-description as character no-undo .

  define buffer current_c-marking for ub.c-marking-attr.
  define variable v-mess as character no-undo.
  
  do
  on error undo, return error return-value
  :
    find first current_c-marking no-lock where
               current_c-marking.mark = X_c-obj-hist.mark
           and current_c-marking.chip-num = X_c-obj-hist.chip-num
           and current_c-marking.corr-user-db-num = X_c-obj-hist.corr-user-db-num no-error .
    if not avail current_c-marking then do:
        v-mess = "Неверная ссылка на марку в таблице c-marking".
        return error  v-mess .
    end.
    &scop fields-name-list "attr-value"
    define variable v-label-param as character no-undo .
    v-label-param =
          "attr-value"   + {&delim-par} + getAttributeName(current_c-marking.attr-code) + {&delim-par} 
          + (if current_c-marking.attr-code = "notOnlineCheck" then "formatLogicalValue" else "formatValue").
    run proc-full-temp-changes in this-procedure (
                                                 input current_c-marking.action = integer({&hn-create})
                                                ,input current_c-marking.action = integer({&hn-delete})
                                                ,input  buffer current_c-marking:handle
                                                ,input  "marking-attr"
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).
  end.
end procedure. /* getMarkingAttr */

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
    ,input substitute("and X_c-obj-hist.mark begins '&1' "
      , p-obj-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-obj-code in frame Dialog-Frame.
END PROCEDURE.
