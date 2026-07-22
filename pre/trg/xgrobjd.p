block-level on error undo, throw.
trigger procedure for delete of ub.xgroupobj.
define buffer buf-GroupObj for xGroupObj.
find first buf-groupobj where buf-groupobj.Parent-GroupObj eq xgroupobj.GroupObj-Code
no-lock no-error.
if avail buf-groupobj
then
   return error "У записи есть потомомки. Удаление запрещено."
