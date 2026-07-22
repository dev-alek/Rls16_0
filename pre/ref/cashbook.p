block-level on error undo, throw.
SESSION:ERROR-STACK-TRACE=YES.
define input  parameter parparentproc as handle no-undo .
define input  parameter pMode as character  no-undo .
  define variable v-brw as class ibs.th.ref.cashbookbrw no-undo .
  v-brw = new ibs.th.ref.cashbookbrw ( pMode, parparentproc ).
  wait-for  v-brw:ShowDialog() .
define variable v-err-msg as character no-undo .
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbook.p" .
    end .
    message v-err-msg  view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) .
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbook.p" .
    message "ProError" skip(1) v-err-msg  view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbook.p " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg  view-as alert-box.
  end catch .
finally:
    SESSION:ERROR-STACK-TRACE=no.
   if valid-object(v-brw) then delete object v-brw no-error .
end finally.
