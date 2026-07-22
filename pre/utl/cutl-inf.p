block-level on error undo, throw.
do
on error undo, return error return-value :
  find first src.sys-ctrl.
  find first src.db
    where src.db.db-num = src.sys-ctrl.db-num
    .
  return string("db: " + string(src.db.db-num) + " db-name: " + src.db.db-name + " db-key: " + src.db.db-key ).
end.
