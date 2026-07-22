define new global shared variable mAsyncProc as class ibs.th.file.asyncproc no-undo.
define output parameter oAsyncProc as class ibs.th.file.asyncproc no-undo.
if not valid-object (mAsyncProc)
then
   mAsyncProc = new ibs.th.file.asyncproc().
oAsyncProc = mAsyncProc.