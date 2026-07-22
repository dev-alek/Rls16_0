block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.route .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи маршрутизации".
do
on error undo, return error
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_route           for ub.route .
define buffer buf_route-dump      for ub.route-dump .
define buffer buf_route-dump-link for ub.route-dump-link .
define buffer buf_sys-ctrl        for ub.sys-ctrl .
disable triggers for load of ub.route-dump .
find first buf_sys-ctrl no-lock.
if buf_sys-ctrl.db-num = 0 then do:
  find first buf_route no-lock
    where buf_route.dump-ord = ub.route.dump-ord
      and buf_route.db-num   > ub.route.db-num
    no-error
  .
  if not available buf_route then do:
    find first buf_route no-lock
      where buf_route.dump-ord = ub.route.dump-ord
        and buf_route.db-num   < ub.route.db-num
      no-error
    .
  end.
end.
if buf_sys-ctrl.db-num <> 0
  or not available buf_route
then do:
  for each buf_route-dump-link
    where buf_route-dump-link.dump-ord = ub.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump-link.
  end.
  for each buf_route-dump
    where buf_route-dump.dump-ord = ub.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump.
  end.
end.
end.
