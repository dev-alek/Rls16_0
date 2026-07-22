block-level on error undo, throw.
using ibs.th.adm.upd.*.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter p-connpar as character no-undo.
define output parameter p-isUpdShm as logical init false no-undo.
define variable updschmObj as class updschm no-undo.
define variable str as character no-undo.
define stream slogwrite.
output stream slogwrite to "update.log".
subscribe "WriteLogAsunc" anywhere.
subscribe "PutStatAsunc" anywhere run-procedure "WriteLogAsunc".
updschmObj = new updschm (input p-connpar,"",this-procedure).
if updschmObj:IsErr
then do:
  str = updschmObj:Msg.
  delete object updschmObj no-error.
  return error str.
end.
if updschmObj:isNeedUpd
then do:
  updschmObj:upddbshm().
  if updschmObj:IsErr
  then do:
    str = updschmObj:Msg.
    delete object updschmObj no-error.
    return error str.
  end.
end.
p-isUpdShm = updschmObj:isUpdShm.
delete object updschmObj.
unsubscribe "WriteLogAsunc".
unsubscribe "PutStatAsunc".
output stream slogwrite close.
procedure WriteLogAsunc:
   define input  parameter itext as character no-undo.
   define input  parameter iMes  as logical   no-undo.
   put stream slogwrite unformatted itext skip.
end.
