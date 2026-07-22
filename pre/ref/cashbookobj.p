block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter iMode as character no-undo.
define input  parameter i-id as int64 no-undo.
define input  parameter i-obj-code as integer no-undo.
define input  parameter i-obj-type as character no-undo.
    define variable v-brw as class ibs.th.ref.cashbookobj no-undo .
    v-brw = new ibs.th.ref.cashbookobj (parparentproc, iMode, i-id, i-obj-code, i-obj-type ).
    subscribe   to "getNextseq"     anywhere run-procedure "local-getNextseq".
    wait-for  v-brw:ShowDialog() .
    unsubscribe to "getNextseq".
 define variable mSeqSave as integer no-undo init ?.
  procedure local-getNextseq:
     define input  parameter iseqnamehist    as character no-undo.
     define input  parameter idb-name_schema as character no-undo.
     define output parameter oSeq            as int64 no-undo.
     if iseqnamehist ne "s-c-cashbook-chip-num"
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
        else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbookobj.p" .
      end .
      message v-err-msg  view-as alert-box.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      v-err-msg = exProErrors:GetMessage(1) .
      if v-err-msg > "" then .
      else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbookobj.p" .
      message "ProError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\cashbookobj.p " + exAnyErrors:GetMessage(1).
      message "LangError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    finally:
      if valid-object(v-brw) then delete object v-brw no-error .
    end finally.
