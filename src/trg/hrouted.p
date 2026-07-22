block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи маршрутизации OpenXML

Автор: Белоусов Илья Александрович
Дата создания: 11/15/06
Author: Ilia Belousov
Creation date: 11/15/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.h-route .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи маршрутизации OpenXML".
{ cmp/vssrevis.i }

    define buffer buf_h-route      for ub.h-route .
    define buffer buf_h-route-dump for ub.h-route-dump .
do
for buf_h-route
  , buf_h-route-dump
on error undo, return error
:
    find first buf_h-route no-lock
        where buf_h-route.dump-ord = ub.h-route.dump-ord
          and buf_h-route.db-num   <> ub.h-route.db-num
    no-error
    .
    if not available buf_h-route
    then do:
        for each buf_h-route-dump
           where buf_h-route-dump.dump-ord = ub.h-route.dump-ord
        on error undo, return error
        :
            delete buf_h-route-dump.
        end.
    end.
end.