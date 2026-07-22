block-level on error undo, throw.
session:debug-alert = yes.
output to "error.log".
output close.
define variable vAsyncProc as class ibs.th.file.AsyncProc.
define variable mDir as character no-undo.
vAsyncProc = new ibs.th.file.AsyncProc().
vAsyncProc:creatProcInfo(1,1,1).
assign
   mdir =
   vAsyncProc:GetPARAM(1)
    .
output to "endproc.txt".
put unformatted "end" skip.
output close.
  define variable v-ProcView as class ibs.th.file.ProcViewth no-undo .
  v-ProcView = new  ibs.th.file.ProcViewth (
  ).
  //iChange = not iChange.
  v-ProcView:MWorkDir = mdir.
  wait-for  v-ProcView:ShowDialog() .
delete object vAsyncProc.
delete object v-ProcView.
quit.
define variable v-err-msg as character no-undo .
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\proc-view-proc.p" .
    end .
    message v-err-msg  view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) .
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\proc-view-proc.p" .
    message "ProError" skip(1) v-err-msg  view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\proc-view-proc.p " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg  view-as alert-box.
  end catch .
finally:
    session:error-stack-trace=no.
   if valid-object(v-ProcView) then delete object v-ProcView no-error .
end finally.
