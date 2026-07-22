block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00012000.p $
$Archive: cut/00012000.p $

Файл пирога обрезания. Относится к категории 12.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
db
c-db
db-info
db-status
db-status-attr
db-attr
db-rec-attr
hist-nws-option
c-hist-nws-option
hist-nws-option-attr
c-hist-nws-option-attr


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00012000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00012000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 12.".
{ cmp/str-glbl.i }
{ gbl/db-attr.i  }

define buffer old-db          for src.db.
define buffer new-db          for dst.db.
define buffer old-c-db        for src.c-db.
define buffer new-c-db        for dst.c-db.
define buffer old-db-info     for src.db-info.
define buffer new-db-info     for dst.db-info.
define buffer old-db-status   for src.db-status.
define buffer new-db-status   for dst.db-status.
define buffer old-db-status-attr   for src.db-status-attr.
define buffer new-db-status-attr   for dst.db-status-attr.
define buffer old-db-attr     for src.db-attr.
define buffer new-db-attr     for dst.db-attr.
define buffer old-db-rec-attr for src.db-rec-attr.
define buffer new-db-rec-attr for dst.db-rec-attr.
define buffer old-hist-nws-option  for src.hist-nws-option.
define buffer new-hist-nws-option  for dst.hist-nws-option.
define buffer old-c-hist-nws-option  for src.c-hist-nws-option.
define buffer new-c-hist-nws-option  for dst.c-hist-nws-option.
define buffer old-hist-nws-option-attr  for src.hist-nws-option-attr.
define buffer new-hist-nws-option-attr  for dst.hist-nws-option-attr.
define buffer old-c-hist-nws-option-attr  for src.c-hist-nws-option-attr.
define buffer new-c-hist-nws-option-attr  for dst.c-hist-nws-option-attr.




do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.db          override do: end.
  on WRITE of dst.c-db        override do: end.
  on WRITE of dst.db-info     override do: end.
  on WRITE of dst.db-status   override do: end.
  on WRITE of dst.db-status-attr override do: end.
  on write of dst.db-attr     override do: end.
  on write of dst.db-rec-attr override do: end.
  on WRITE of dst.hist-nws-option  override do: end.
  on WRITE of dst.c-hist-nws-option  override do: end.
  on WRITE of dst.hist-nws-option-attr  override do: end.
  on WRITE of dst.c-hist-nws-option-attr  override do: end.


  for each old-db no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-db.
    buffer-copy old-db to new-db.
    if old-db.db-num <> 0
       and vartype-cut <> 1
    then do:
      assign
        new-db.db-key = ""
        new-db.db-key-enc = ""
      .
    end.
  end.
  if varstay-history then do:
    { utl/00000002.i c-db }
  end.
  { utl/00000002.i db-info }
  { utl/00000002.i db-status }
  { utl/00000002.i db-status-attr }


  for each old-db-attr no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    if vartype-cut = 0
      and old-db-attr.attr-code = {&attr-cut-fin-date}
    then do:
      next. /* не перетаскиваем т.к. это уже новое создается в 0001000.p */
    end.

    create new-db-attr.
    buffer-copy old-db-attr to new-db-attr.
  end.

  { utl/00000002.i db-rec-attr }
  { utl/00000002.i hist-nws-option }
  if varstay-history then do:
    { utl/00000002.i c-hist-nws-option }
  end.
  { utl/00000002.i hist-nws-option-attr }
  if varstay-history then do:
    { utl/00000002.i c-hist-nws-option-attr }
  end.

  output stream str-gen close.
  return "Произведен экспорт таблиц: db c-db db-status db-attr db-rec-attr hist-nws-option c-hist-nws-option hist-nws-option-attr c-hist-nws-option-attr.".
end.