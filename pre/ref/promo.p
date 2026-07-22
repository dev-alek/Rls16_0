block-level on error undo, throw.
SESSION:ERROR-STACK-TRACE=YES.
define input  parameter parparentproc as handle no-undo .
define input  parameter iChange as logical  no-undo .
define output parameter oSubs   as class ibs.th.ref.promo.promoActionSubs no-undo .
  define variable v-listact-brw as class ibs.th.ref.promo.wListActions no-undo .
  v-listact-brw = new ibs.th.ref.promo.wListActions (
  ).
  //iChange = not iChange.
  v-listact-brw:parparentproc = parparentproc.
  v-listact-brw:Visual_Buttons(iChange).
  wait-for  v-listact-brw:ShowDialog() .
  if iChange
  then
     oSubs = v-listact-brw:oPromoActionSubs.
define variable v-err-msg as character no-undo .
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\promo.p" .
    end .
    message v-err-msg  view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) .
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\promo.p" .
    message "ProError" skip(1) v-err-msg  view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\promo.p " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg  view-as alert-box.
  end catch .
finally:
    SESSION:ERROR-STACK-TRACE=no.
   if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
end finally.
