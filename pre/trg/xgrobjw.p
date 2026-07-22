block-level on error undo, throw.
trigger procedure for write of ub.xgroupobj
  new buffer new-xgroupobj
  old buffer old-xgroupobj
.
if new new-xgroupobj
then
   run utl\xattr-f.p (new-xgroupobj.GroupObj-Code, no).
