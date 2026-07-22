block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00001000.p $
$Archive: cut/00001000.p $

Файл пирога обрезания. Относится к категории 1.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
config
c-config
sysconf
c-sysconf
sys-ctrl
sys-ctrl-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00001000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00001000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 1.".
{ cmp/str-glbl.i }
{ utl/00000001.i }
{ gbl/db-attr.i  }

define buffer old-config    for src.config .
define buffer new-config    for dst.config .
define buffer old-c-config    for src.c-config .
define buffer new-c-config    for dst.c-config .
define buffer old-sysconf   for src.sysconf .
define buffer new-sysconf   for dst.sysconf .
define buffer old-c-sysconf for src.c-sysconf .
define buffer new-c-sysconf for dst.c-sysconf .
define buffer old-sys-ctrl  for src.sys-ctrl .
define buffer new-sys-ctrl  for dst.sys-ctrl .
define buffer old-sys-ctrl-attr  for src.sys-ctrl-attr .
define buffer new-sys-ctrl-attr  for dst.sys-ctrl-attr .

define buffer new-db-attr   for dst.db-attr .
define buffer old-db        for src.db .

do
on error undo, return error
:
  disable triggers for load of dst.config.

  on write of dst.sysconf   override do: end.
  on write of dst.c-sysconf override do: end.
  on write of dst.sys-ctrl  override do: end.
  on write of dst.sys-ctrl-attr  override do: end.
  on write of dst.db-attr     override do: end.
  on write of dst.c-config override do: end.

  define variable v-new-cut-date as date      no-undo .

  { utl/00000002.i config    }
  if varstay-history then do:
    { utl/00000002.i c-config    }
  end.

  for each old-sysconf no-lock
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-sysconf .
    buffer-copy old-sysconf to new-sysconf .
    if varstay-history then do:
      for each old-c-sysconf no-lock
        where old-c-sysconf.host-code = old-sysconf.host-code
      on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
        create new-c-sysconf .
        buffer-copy old-c-sysconf to new-c-sysconf .
      end.
    end.
  end.

  find src.sys-ctrl .
  create dst.sys-ctrl .
  buffer-copy src.sys-ctrl to dst.sys-ctrl.

  if vartype-cut = 0 then do:
    if vardate-actual-docs <> ?
    then do:
      assign
        v-new-cut-date = vardate-actual-docs
      .
    end.
    else do:
      assign
        v-new-cut-date = today
      .
    end.
    assign
      dst.sys-ctrl.cut-date = v-new-cut-date
    .
    for each old-db
    on error undo, return no-apply
    :
      find first new-db-attr exclusive-lock
        where new-db-attr.db-num    = old-db.db-num
          and new-db-attr.attr-code = {&attr-cut-fin-date}
        no-error .
      if not available new-db-attr then do:
        create new-db-attr .
        assign
          new-db-attr.db-num    = old-db.db-num
          new-db-attr.attr-code = {&attr-cut-fin-date}
        .
      end.
      assign
        new-db-attr.attr-value = string( vardate-actual-findoc, "99/99/9999" )
      .
    end.
  end.
  { utl/00000002.i sys-ctrl-attr  }

  output stream str-gen close.
  return "Произведен экспорт таблиц: config c-config sysconf c-sysconf sys-ctrl sys-ctrl-attr.".
end. /*do*/