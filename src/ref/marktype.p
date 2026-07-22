block-level on error undo, throw.
/*

$Revision:
$Author:
$Date:
$Workfile: marktype.p $
$Archive: rep/marktype.p $

Результаты проверки HDD

Автор: Ростовцев Александр 
Дата создания: 27/03/24
Author: Aleksandr R0stovtsev
Creation date: 27/03/24

*/

define variable vss-revision    as character no-undo init "$Revision: c575f5acca55, 2347, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:33 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: marktype.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/marktype.p $":U .
define variable vss-description as character no-undo init "Форма изменения типа маркировки".

/*block-level on error undo, throw.*/

SESSION:ERROR-STACK-TRACE=YES.
DEFINE TEMP-TABLE tt_code NO-UNDO LIKE code.

define input        parameter parparentproc as handle            no-undo.
define input        parameter iMode         as character         no-undo.
define input-output parameter iCode       like ub.code.code      no-undo.
define input-output parameter iCodeValue  like ub.code.codevalue no-undo.
define input-output parameter iCodeName   like ub.code.codename  no-undo.
define input-output parameter iMisc1      like ub.code.misc1 no-undo.
define input-output parameter iMisc2      like ub.code.misc2 no-undo.
define input-output parameter iMisc3      like ub.code.misc3 no-undo.
define input-output parameter iMisc4      like ub.code.misc4 no-undo.
define output       parameter isUpdated     as logical       no-undo.

{ gbl/userobjs.i }

define variable mMarkType as class ibs.th.ref.marktype no-undo .
mMarkType = new ibs.th.ref.marktype (
                    parparentproc, iMode, 
                    iCode, iCodeValue, iCodeName, iMisc1, iMisc2, iMisc3, iMisc4
                ).
  
wait-for  mMarkType:ShowDialog() .

isUpdated = mMarkType:isUpdated.
if isUpdated then 
do:
    assign
        iCode      = mMarkType:codeType
        iCodeValue = mMarkType:codeValue
        iCodeName  = mMarkType:codeName
        iMisc1     = mMarkType:codeMisc1
        iMisc2     = mMarkType:codeMisc2
        iMisc3     = mMarkType:codeMisc3
        iMisc4     = mMarkType:codeMisc4
    .
end.

define variable v-err-msg as character no-undo .  
catch exAppErrors as class Progress.Lang.AppError :
  v-err-msg = exAppErrors:ReturnValue .
  if v-err-msg > "" then . 
  else 
  do :
    v-err-msg = exAppErrors:GetMessage(1) .
    if v-err-msg > "" then .
    else v-err-msg = "AppError в модуле {&FILE-NAME}" .
  end .
  message v-err-msg  view-as alert-box.
end catch .
catch exProErrors as class Progress.Lang.ProError :
  v-err-msg = exProErrors:GetMessage(1) . 
  if v-err-msg > "" then . 
  else v-err-msg = "ProError в модуле {&FILE-NAME}" .
  message "ProError" skip(1) v-err-msg /*skip exProErrors:CallStack*/ view-as alert-box.
end catch .
catch exAnyErrors as class Progress.Lang.Error:
  v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
  message "LangError" skip(1) v-err-msg /*skip exAnyErrors:CallStack*/ view-as alert-box.
end catch .
finally:
  SESSION:ERROR-STACK-TRACE=no. 
  if valid-object(mMarkType) then delete object mMarkType no-error .
end finally.  
