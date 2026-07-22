block-level on error undo, throw.

&Glob main-tbl xgroupobj
trigger procedure for write of ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.
if new new-{&main-tbl}
then
   run utl\xattr-f.p (new-{&main-tbl}.GroupObj-Code, no).