block-level on error undo, throw.
define output parameter p-version-name as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-version-name = "16.0":u
  .
end.
