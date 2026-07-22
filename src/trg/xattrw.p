block-level on error undo, throw.

&Glob main-tbl xattr
trigger procedure for write of ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.
