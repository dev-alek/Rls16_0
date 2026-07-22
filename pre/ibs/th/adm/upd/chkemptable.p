define input  parameter iParam as character no-undo.
define output parameter oOk as logical no-undo.
define variable vi as integer no-undo.
function Checktable returns logical (itable as character) forward.
do vi = 1 to num-entries (iParam,"|"):
   if not Checktable(entry(vi,iParam,"|")) then  return.
end.
ook = yes.
return.
function Checktable returns logical (itable as character):
   define variable vBufTable as handle no-undo.
   define variable vQuery          as handle no-undo.
   define variable vOk             as logical no-undo.
   create buffer vBufTable for table itable.
   create query vQuery.
   vQuery:set-buffers(vBufTable).
   vQuery:query-prepare("for each " + vBufTable:name + " no-lock").
   vQuery:query-open().
   vQuery:get-first().
   vOk = not vBufTable:available.
   vQuery:query-close().
   delete object vQuery.
   delete object vBufTable.
   return vOk.
end.
