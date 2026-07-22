define variable mDisableNwsFortable as character no-undo.

procedure DisableNws:
   define input  parameter iTable  as character no-undo.
   define output parameter oNotNWS as logical no-undo.
   if      mDisableNwsFortable ne ?
       and can-do(mDisableNwsFortable,iTable)
   then
      oNotNWS = yes.
end.

procedure SetNwsTable:
   define input  parameter iTable  as character no-undo.
   mDisableNwsFortable = iTable.
end.

procedure RunProcAny:
   define input  parameter iProc  as character no-undo.
   define input  parameter iParam as character no-undo.
   define output parameter oOk    as logical   no-undo.
   run value(iproc) (parparentproc, iparam, output oOk) no-error.
   if error-status:error
   then
      return substitute ("&1 &2", return-value, error-status:get-message(1)).
   
end.
