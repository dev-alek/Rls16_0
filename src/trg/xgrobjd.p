block-level on error undo, throw.
&scoped-define main-tbl xgroupobj
trigger procedure for delete of ub.{&main-tbl}.
define buffer buf-GroupObj for xGroupObj.
find first buf-groupobj where buf-groupobj.Parent-GroupObj eq {&main-tbl}.GroupObj-Code
no-lock no-error.
if avail buf-groupobj
then 
   return error "У записи есть потомомки. Удаление запрещено."