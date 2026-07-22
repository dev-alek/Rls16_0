block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clearrtd.p $
$Archive: utl/clearrtd.p $

Очистка мусора в таблица маршрутизации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/03/08
Author: Dmitry Ukhanov
Creation date: 10/03/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clearrtd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/clearrtd.p $":U .
define variable vss-description as character no-undo init "Очистка мусора в таблица маршрутизации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-ind-av as integer   no-undo .
  define variable v-ind-d  as integer   no-undo .

  define frame f-info
    v-ind-av label "Просмотрено" format ">>>>>>>>>9" skip
    v-ind-d  label "Удалено"     format ">>>>>>>>>9" skip
    with view-as dialog-box side-labels 1 columns three-d title "Очистка таблиц маршрутизации"
  .

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.
  assign
    v-ind-av = 0
    v-ind-d  = 0
  .

  view frame f-info .

  for each route-dump exclusive-lock
  on error undo, next
  :
    assign
      v-ind-av = v-ind-av + 1
    .
    pause 0.
    display
      v-ind-av
      v-ind-d
      with frame f-info.
    find first route exclusive-lock
      where route.dump-ord = route-dump.dump-ord
      no-error.
    if not available route then do:
      for each route-dump-link exclusive-lock
        where route-dump-link.dump-ord = route-dump.dump-ord
          and route-dump-link.rec-ord  = route-dump.rec-ord
      on error undo, return error
      :
        delete route-dump-link.
      end.
      delete route-dump.
      assign
        v-ind-d = v-ind-d + 1
      .
    end.
  end.

  hide frame f-info NO-PAUSE.

  message
    substitute( "Просмотрено записей: &1", v-ind-av ) skip
    substitute( "Удалено записей: &1", v-ind-d ) skip
    view-as alert-box information.

  return .

end.