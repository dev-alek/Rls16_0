block-level on error undo, throw.
{ bge/socet.i }
{ utl/proc-async.i proc_def}
procedure setParam:
   define input parameter iParamName  as character no-undo.
   define input parameter iParamValue as character no-undo.
   if iParamName eq "addTimeOut"
   then
      mAddTimeOut = logical(iParamValue) no-error.
   else if iParamName eq "TimeOut"
   then
      mWaitFramTimeOut = int(iParamValue).
   else if iParamName eq "FileLogSocet"
   then
      mFileLogSocet = iParamValue.
   else if iParamName eq "TypeResponce"
   then
      mTypeResponse = iParamValue.
end.

procedure isEndWork:
   define output parameter oWorkEnd as logical no-undo.
   oWorkEnd = mWaitFramStop.
end.

procedure getResponceMemptr:
   define output parameter oMemptr as memptr no-undo.
   if OerrMsg eq ""
   then
      oMemptr = mWebRespMptr.
   delete object mHSocket no-error.
end.

procedure getResponceLongchar:
   define output parameter oMemptr as longchar no-undo.
   if OerrMsg eq ""
   then
      oMemptr = mWebResp.
   delete object mHSocket no-error.
end.

procedure IsWorkSocet:
   define output parameter oValidSocet as logical no-undo.
   oValidSocet = valid-handle(mHSocket).
end.

on delete of this-procedure do:
   { utl/proc-async.i proc_end}
   run Disconect.
end.
