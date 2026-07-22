block-level on error undo, throw.
define input  parameter p-parts-attr-recid as recid     no-undo .
define buffer buf_parts-attr for ub.parts-attr .
define button b-close
     label "&Выход" auto-go
     size 10 by 1
     .
form b-close skip
  with frame a side-labels 1 column scrollable
  view-as dialog-box three-d size 60 by 20
  .
form buf_parts-attr with frame a .
find first buf_parts-attr no-lock
  where recid(buf_parts-attr) = p-parts-attr-recid
  no-error .
if available buf_parts-attr
then do:
  display
    buf_parts-attr
    with frame a .
  enable b-close with frame a .
  apply 'entry':u to b-close .
  wait-for go of frame a .
end.
