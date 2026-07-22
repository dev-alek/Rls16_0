block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delroute.p $
$Archive: utl/delroute.p $

утилита удаления ВСЕХ записей маршрутизации по ПОДТВЕРЖДЕННЫМ пакетам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/00
Author: Dmitry Ukhanov
Creation date: 03/23/00

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delroute.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delroute.p $":U .
define variable vss-description as character no-undo init "утилита удаления ВСЕХ записей маршрутизации по ПОДТВЕРЖДЕННЫМ пакетам".
{ cmp/vssrevis.i }
{ gbl/cur-time.i }

do
on error undo, return error
:
  define stream StrRoute.
  define stream StrRouteDump.
  define variable msg-log   as logical no-undo.
  define variable count-rt  as integer no-undo .
  define variable count-rtd as integer no-undo .

  define buffer buf_route for ub.route .

  def frame inf
    ub.db.db-num         label "По БД" skip
    ub.pck-sent.pack-num label "Пакет" skip
    count-rt             label "Удалено route" skip
    count-rtd            label "Удалено route-dump" skip
    with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации".

  message "Вы действительно хотите очистить таблицу маршрутизации?"
    view-as alert-box question update msg-log.

  output stream StrRoute     to "del-rt.d"  page-size 0 append.
  output stream StrRouteDump to "del-rtd.d" page-size 0 append.
  assign
    count-rt  = 0
    count-rtd = 0
  .
  put stream StrRoute     unformatted "---> ":U cur-time-string() skip.
  put stream StrRouteDump unformatted "---> ":U cur-time-string() skip.

  view frame inf.

  for each ub.db no-lock
    where ub.db.db-num > 0
    ,each ub.route exclusive-lock
    where ub.route.db-num    = ub.db.db-num
      and ub.route.last-pack > 0
    ,each ub.pck-sent no-lock
    where ub.pck-sent.db-num   = ub.route.db-num
      and ub.pck-sent.pack-num = ub.route.last-pack
      and ub.pck-sent.rcvd     = true
  on error  undo, return error
  :

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

    if not available buf_route then do:
      for each ub.route-dump exclusive-lock
        where ub.route-dump.dump-ord = ub.route.dump-ord
      on error  undo, return error
      :
        export stream StrRouteDump ub.route-dump .
        delete ub.route-dump.
        assign
          count-rtd = count-rtd + 1
        .
        display
          ub.db.db-num
          ub.pck-sent.pack-num
          count-rt
          count-rtd
          with frame inf.
      end.
    end.
    export stream StrRoute ub.route .
    delete ub.route.
    assign
      count-rt = count-rt + 1
    .
    display
      ub.db.db-num
      ub.pck-sent.pack-num
      count-rt
      count-rtd
      with frame inf.
  end.

  hide frame inf no-pause .
  output stream StrRouteDump close.
  output stream StrRoute close.
  message "Удаление завершено. Удалено записей" skip
          "route:" string( count-rt ) skip
          "route-dump:" string( count-rtd )
          view-as alert-box information.
end.