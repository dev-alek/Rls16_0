block-level on error undo, throw.
define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter itext as character no-undo.
define input  parameter iobjcode as char no-undo.
define variable mAnswer as character  no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
subscribe   to "ResponseToQuestion" anywhere run-procedure "SendAnswer".
if itext <> ""
then do:
  mAnswer = "4".
  run str/sendcash_num.p(iUtil:parparentproc,this-procedure,this-procedure,string(iobjcode) + chr(4) + itext).
end.
unsubscribe to "ResponseToQuestion".
procedure SendAnswer:
   define output parameter oAnswer as character  no-undo.
   oAnswer = mAnswer.
end procedure.
procedure write-log-and-file :
define input parameter p-tabs as integer no-undo .
define input parameter p-log-file as character no-undo .
define input parameter p-int2 as integer no-undo .
define input parameter p-mess as character no-undo .
iUtil:put-log(p-mess).
end procedure.
procedure show-counter :
end procedure.
