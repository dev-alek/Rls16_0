block-level on error undo, throw.
define input parameter  pswd     as character no-undo .
define output parameter enc-pswd as character no-undo .
do
on error undo, return error return-value
:
  run pswd-enc-procedure in this-procedure
    (input  pswd
    ,output enc-pswd
    ) .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc-procedure :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
