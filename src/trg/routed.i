/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тело триггера на удаление route

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/05
Author: Dmitry Ukhanov
Creation date: 03/22/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_route           for {1}.route .
define buffer buf_route-dump      for {1}.route-dump .
define buffer buf_route-dump-link for {1}.route-dump-link .
define buffer buf_sys-ctrl        for {1}.sys-ctrl .

disable triggers for load of {1}.route-dump .

find first buf_sys-ctrl no-lock.

if buf_sys-ctrl.db-num = 0 then do:
  find first buf_route no-lock
    where buf_route.dump-ord = {1}.route.dump-ord
      and buf_route.db-num   > {1}.route.db-num
    no-error
  .
  if not available buf_route then do:
    find first buf_route no-lock
      where buf_route.dump-ord = {1}.route.dump-ord
        and buf_route.db-num   < {1}.route.db-num
      no-error
    .
  end.
end.

if buf_sys-ctrl.db-num <> 0
  or not available buf_route
then do:

  for each buf_route-dump-link
    where buf_route-dump-link.dump-ord = {1}.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump-link.
  end.

  for each buf_route-dump
    where buf_route-dump.dump-ord = {1}.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump.
  end.
end.


/* $Workfile$ e n d */