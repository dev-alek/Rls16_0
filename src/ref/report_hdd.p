block-level on error undo, throw.
/*

$Revision: c188d6f80d33, 2331, rls $
$Author: druban $
$Date: Ср июн 10 21:13:32 2020 +0300 $
$Workfile: report_hdd.p $
$Archive: ref/report_hdd.p $

Платежные агенты/операторы

Автор: Молотков Сергей
Дата создания: 21/06/18
Author: Molotkov Sergey
Creation date: 21/06/18

*/
 

define variable vss-revision    as character no-undo init "$Revision: c188d6f80d33, 2331, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:32 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: report_hdd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/report_hdd.p $":U .
define variable vss-description as character no-undo init "".

/*block-level on error undo, throw.*/

SESSION:ERROR-STACK-TRACE=YES.

define input  parameter parparentproc as handle no-undo .
{ gbl/userobjs.i }
define variable v-listact-brw as class ibs.th.ref.report_hdd no-undo .
v-listact-brw = new ibs.th.ref.report_hdd ().
  
v-listact-brw:parparentproc = parparentproc.
v-listact-brw:p-callback-handle = this-procedure :handle.  
wait-for  v-listact-brw:ShowDialog() .
/*  pList = v-listact-brw:p-list .*/
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
  if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
end finally.  
