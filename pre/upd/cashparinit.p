block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.
run ref\cashparaminit.p no-error.
oOk = not error-status:error.
if not oOk
then
message return-value  error-status:get-message(1)
  view-as alert-box.
