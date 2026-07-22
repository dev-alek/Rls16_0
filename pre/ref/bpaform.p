block-level on error undo, throw.
define input  parameter iChange as character no-undo.
define input  parameter i-id as integer  no-undo.
    define variable v-listact-brw as class ibs.th.ref.bpa.BPA_form no-undo .
    v-listact-brw = new ibs.th.ref.bpa.BPA_form ( iChange, i-id
      ).
    subscribe   to "getNextseq"     anywhere run-procedure "local-getNextseq".
    wait-for  v-listact-brw:ShowDialog() .
    unsubscribe to "getNextseq".
 define variable mSeqSave as integer no-undo init ?.
  procedure local-getNextseq:
     define input  parameter iseqnamehist    as character no-undo.
     define input  parameter idb-name_schema as character no-undo.
     define output parameter oSeq            as int64 no-undo.
     if iseqnamehist ne "s-c-operserv-chip-num"
     then
        oSeq = ?.
     else if mSeqSave = ?
     then
        assign
           mSeqSave = dynamic-next-value (iseqnamehist, idb-name_schema)
           oSeq     = mSeqSave
        .
     else
        oSeq = mSeqSave.
 end.
 define variable v-err-msg as character no-undo .
 catch exAppErrors as class Progress.Lang.AppError :
   v-err-msg = exAppErrors:ReturnValue .
   if v-err-msg > "" then .
   else
   do :
     v-err-msg = exAppErrors:GetMessage(1) .
     if v-err-msg > "" then .
     else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\bpaform.p" .
   end .
   message v-err-msg  view-as alert-box.
 end catch .
 catch exProErrors as class Progress.Lang.ProError :
   v-err-msg = exProErrors:GetMessage(1) .
   if v-err-msg > "" then .
   else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\bpaform.p" .
   message "ProError" skip(1) v-err-msg  view-as alert-box.
 end catch .
 catch exAnyErrors as class Progress.Lang.Error:
   v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\bpaform.p " + exAnyErrors:GetMessage(1).
   message "LangError" skip(1) v-err-msg  view-as alert-box.
 end catch .
 finally:
   if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
 end finally.
