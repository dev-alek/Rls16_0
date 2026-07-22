block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00139000.p $
$Archive: cut/00139000.p $

Файл пирога обрезания. Относится к категории 139.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
pck-rcvd
pck-rcvd-attr
pck-sent
pck-sent-attr
pck-keys
route
route-attr
route-dump
route-dump-attr
route-dump-link

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00139000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00139000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 139.".
{ cmp/str-glbl.i }

define buffer old-pck-rcvd        for src.pck-rcvd.
define buffer new-pck-rcvd        for dst.pck-rcvd.
define buffer old-pck-rcvd-attr        for src.pck-rcvd-attr.
define buffer new-pck-rcvd-attr        for dst.pck-rcvd-attr.
define buffer old-pck-sent        for src.pck-sent.
define buffer new-pck-sent        for dst.pck-sent.
define buffer old-pck-sent-attr   for src.pck-sent-attr.
define buffer new-pck-sent-attr   for dst.pck-sent-attr.
define buffer old-pck-keys        for src.pck-keys.
define buffer new-pck-keys        for dst.pck-keys.
define buffer old-route           for src.route.
define buffer new-route           for dst.route.
define buffer old-route-attr      for src.route-attr.
define buffer new-route-attr      for dst.route-attr.
define buffer old-route-dump      for src.route-dump.
define buffer new-route-dump      for dst.route-dump.
define buffer old-route-dump-attr for src.route-dump-attr.
define buffer new-route-dump-attr for dst.route-dump-attr.
define buffer old-route-dump-link for src.route-dump-link.
define buffer new-route-dump-link for dst.route-dump-link.

do
on error undo, return error substitute( "&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2))
on stop  undo, return error substitute( "stop" )
:
  define variable v-msg as character no-undo .

  define buffer buf_db for src.db .

  { utl/00000001.i }
  on write of dst.route override do: end.
  on write of dst.pck-rcvd override do: end.
  on write of dst.pck-rcvd-attr override do: end.
  on write of dst.pck-sent override do: end.
  on write of dst.pck-sent-attr override do: end.

  if vartype-cut = 0 then do:
    for each buf_db
    on error undo, return error substitute( "&1 &2", return-value, error-status :get-message ( 1 ) )
    :
      find last old-pck-sent
        where old-pck-sent.db-num = buf_db.db-num
        use-index pi
        no-error
      .
      if available old-pck-sent then do:  /* был хоть один пакет */
        create new-pck-sent.
        buffer-copy old-pck-sent to new-pck-sent
          assign
            new-pck-sent.pack-num   = 0
            new-pck-sent.rcvd       = true
            new-pck-sent.total-recs = 0
        .
      end.
      find last old-pck-rcvd
        where old-pck-rcvd.db-num = buf_db.db-num
        use-index pi
        no-error
      .
      if available old-pck-rcvd then do:  /* был хоть один пакет */
        create new-pck-rcvd.
        buffer-copy old-pck-rcvd to new-pck-rcvd
          assign
            new-pck-rcvd.pack-num   = 0
            new-pck-rcvd.rcvd-recs  = 0
            new-pck-rcvd.rcvd       = true
            new-pck-rcvd.total-recs = 0
        .
      end.
    end.

    assign
      v-msg = "Игнорированы таблицы:"
    .
  end.
  else do:
    { utl/00000002.i pck-rcvd }
    { utl/00000002.i pck-rcvd-attr }
    { utl/00000002.i pck-sent }
    { utl/00000002.i pck-sent-attr }
    { utl/00000002.i pck-keys        }
    { utl/00000002.i route           }
    { utl/00000002.i route-attr      }
    { utl/00000002.i route-dump      }
    { utl/00000002.i route-dump-attr }
    { utl/00000002.i route-dump-link }
    assign
      v-msg = "Произведен экспорт таблиц:"
    .
  end.
output stream str-gen close.
  return substitute( "&1 pck-rcvd, pck-rcvd-attr, pck-sent, pck-sent-attr, pck-keys, route, route-attr, route-dump, route-dump-attr, route-dump-link.", v-msg ).
end.