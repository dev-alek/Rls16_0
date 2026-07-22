block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.route-dump .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи маршрутизации".
do
on error undo, return error
:
  define buffer buf_route-dump-link for ub.route-dump-link .
  for each buf_route-dump-link
    where buf_route-dump-link.dump-ord = ub.route-dump.dump-ord
      and buf_route-dump-link.rec-ord  = ub.route-dump.rec-ord
  on error undo, return error
  :
    delete buf_route-dump-link.
  end.
end.
