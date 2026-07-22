block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 387c9a6a2a52, 2235, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cover_sheet.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cover_sheet.p $":U .
define variable vss-description as character no-undo init "".
SESSION:ERROR-STACK-TRACE=YES.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-host-code   as integer no-undo .
define input  parameter p-fin-code    as integer no-undo .
define input  parameter p-CashBookId  as integer no-undo .
define input  parameter p-sum-doc     as decimal no-undo .
define input  parameter p-mode        as character  no-undo .
define variable v-listact-brw as class ibs.th.ref.Cover_Sheet no-undo .
do trans:
v-listact-brw = new ibs.th.ref.Cover_Sheet (p-host-code, p-fin-code, p-CashBookId, p-sum-doc, p-mode).
v-listact-brw:parparentproc = parparentproc .
wait-for  v-listact-brw:ShowDialog() .
end.
define variable v-err-msg as character no-undo .
catch exAppErrors as class Progress.Lang.AppError :
  v-err-msg = exAppErrors:ReturnValue .
  if v-err-msg > "" then .
  else
  do :
    v-err-msg = exAppErrors:GetMessage(1) .
    if v-err-msg > "" then .
    else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cover_sheet.p" .
  end .
  message v-err-msg  view-as alert-box.
end catch .
catch exProErrors as class Progress.Lang.ProError :
  v-err-msg = exProErrors:GetMessage(1) .
  if v-err-msg > "" then .
  else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cover_sheet.p" .
  message "ProError" skip(1) v-err-msg  view-as alert-box.
end catch .
catch exAnyErrors as class Progress.Lang.Error:
  v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cover_sheet.p " + exAnyErrors:GetMessage(1).
  message "LangError" skip(1) v-err-msg  view-as alert-box.
end catch .
finally:
  SESSION:ERROR-STACK-TRACE=no.
  if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
end finally.
