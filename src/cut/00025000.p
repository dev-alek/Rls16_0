block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00025000.p $
$Archive: cut/00025000.p $

Файл пирога обрезания. Относится к категории 25.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
place
c-place
place-attr
c-place-attr
pl-gds
c-pl-gds
c-pl-gds-obj
pl-gds-attr
c-pl-gds-attr
pl-gds-pump
c-pl-gds-pump
pl-gds-pump-attr
c-pl-gds-pump-attr
pl-pump
c-pl-pump
pl-pump-attr
c-pl-pump-attr

pump
c-pump
pump-attr
c-pump-attr


pl-pump-nozzle
c-pl-pump-nozzle
pl-pump-nozzle-attr
c-pl-pump-nozzle-attr
pump-nozzle
c-pump-nozzle
pump-nozzle-attr
c-pump-nozzle-attr
nozzle
c-nozzle
nozzle-attr
c-nozzle-attr

auto-tank
auto-tank-meas
auto-tank-attr
auto-tank-meas-attr
c-auto-tank
c-auto-tank-attr
c-auto-tank-meas-attr
pl-level
c-pl-level
pl-level-attr
c-pl-level-attr

c-plc-hist
c-pmp-hist
c-nzl-hist

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00025000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00025000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 25.".
{ cmp/str-glbl.i }

define buffer old-place         for src.place.
define buffer new-place         for dst.place.
define buffer old-c-place       for src.c-place.
define buffer new-c-place       for dst.c-place.
define buffer old-place-attr    for src.place-attr.
define buffer new-place-attr    for dst.place-attr.
define buffer old-c-place-attr  for src.c-place-attr.
define buffer new-c-place-attr  for dst.c-place-attr.
define buffer old-pl-gds        for src.pl-gds.
define buffer new-pl-gds        for dst.pl-gds.
define buffer old-c-pl-gds      for src.c-pl-gds.
define buffer new-c-pl-gds      for dst.c-pl-gds.
define buffer old-c-pl-gds-obj  for src.c-pl-gds-obj.
define buffer new-c-pl-gds-obj  for dst.c-pl-gds-obj.
define buffer old-pl-gds-attr   for src.pl-gds-attr.
define buffer new-pl-gds-attr   for dst.pl-gds-attr.
define buffer old-c-pl-gds-attr for src.c-pl-gds-attr.
define buffer new-c-pl-gds-attr for dst.c-pl-gds-attr.


define buffer old-pl-gds-pump        for src.pl-gds-pump.
define buffer new-pl-gds-pump        for dst.pl-gds-pump.
define buffer old-c-pl-gds-pump      for src.c-pl-gds-pump.
define buffer new-c-pl-gds-pump      for dst.c-pl-gds-pump.
define buffer old-pl-gds-pump-attr   for src.pl-gds-pump-attr.
define buffer new-pl-gds-pump-attr   for dst.pl-gds-pump-attr.
define buffer old-c-pl-gds-pump-attr for src.c-pl-gds-pump-attr.
define buffer new-c-pl-gds-pump-attr for dst.c-pl-gds-pump-attr.

define buffer old-pl-pump       for src.pl-pump.
define buffer new-pl-pump       for dst.pl-pump.
define buffer old-c-pl-pump       for src.c-pl-pump.
define buffer new-c-pl-pump       for dst.c-pl-pump.
define buffer old-pl-pump-attr       for src.pl-pump-attr.
define buffer new-pl-pump-attr       for dst.pl-pump-attr.
define buffer old-c-pl-pump-attr       for src.c-pl-pump-attr.
define buffer new-c-pl-pump-attr       for dst.c-pl-pump-attr.

define buffer old-pump          for src.pump.
define buffer new-pump          for dst.pump.
define buffer old-c-pump          for src.c-pump.
define buffer new-c-pump          for dst.c-pump.
define buffer old-pump-attr          for src.pump-attr.
define buffer new-pump-attr          for dst.pump-attr.
define buffer old-c-pump-attr          for src.c-pump-attr.
define buffer new-c-pump-attr          for dst.c-pump-attr.


define buffer old-pl-pump-nozzle for src.pl-pump-nozzle.
define buffer new-pl-pump-nozzle for dst.pl-pump-nozzle.
define buffer old-c-pl-pump-nozzle for src.c-pl-pump-nozzle.
define buffer new-c-pl-pump-nozzle for dst.c-pl-pump-nozzle.
define buffer old-pl-pump-nozzle-attr for src.pl-pump-nozzle-attr.
define buffer new-pl-pump-nozzle-attr for dst.pl-pump-nozzle-attr.
define buffer old-c-pl-pump-nozzle-attr for src.c-pl-pump-nozzle-attr.
define buffer new-c-pl-pump-nozzle-attr for dst.c-pl-pump-nozzle-attr.

define buffer old-pump-nozzle    for src.pump-nozzle.
define buffer new-pump-nozzle    for dst.pump-nozzle.
define buffer old-c-pump-nozzle  for src.c-pump-nozzle.
define buffer new-c-pump-nozzle  for dst.c-pump-nozzle.
define buffer old-pump-nozzle-attr    for src.pump-nozzle-attr.
define buffer new-pump-nozzle-attr    for dst.pump-nozzle-attr.
define buffer old-c-pump-nozzle-attr  for src.c-pump-nozzle-attr.
define buffer new-c-pump-nozzle-attr  for dst.c-pump-nozzle-attr.


define buffer old-nozzle         for src.nozzle.
define buffer new-nozzle         for dst.nozzle.
define buffer old-c-nozzle       for src.c-nozzle.
define buffer new-c-nozzle       for dst.c-nozzle.
define buffer old-nozzle-attr    for src.nozzle-attr.
define buffer new-nozzle-attr    for dst.nozzle-attr.
define buffer old-c-nozzle-attr  for src.c-nozzle-attr.
define buffer new-c-nozzle-attr  for dst.c-nozzle-attr.




define buffer old-auto-tank      for src.auto-tank.
define buffer new-auto-tank      for dst.auto-tank.
define buffer old-c-auto-tank      for src.c-auto-tank.
define buffer new-c-auto-tank      for dst.c-auto-tank.
define buffer old-auto-tank-meas for src.auto-tank-meas.
define buffer new-auto-tank-meas for dst.auto-tank-meas.
define buffer old-auto-tank-attr for src.auto-tank-attr.
define buffer new-auto-tank-attr for dst.auto-tank-attr.
define buffer old-c-auto-tank-attr      for src.c-auto-tank-attr.
define buffer new-c-auto-tank-attr      for dst.c-auto-tank-attr.
define buffer old-auto-tank-meas-attr for src.auto-tank-meas-attr.
define buffer new-auto-tank-meas-attr for dst.auto-tank-meas-attr.
define buffer old-c-auto-tank-meas-attr for src.c-auto-tank-meas-attr.
define buffer new-c-auto-tank-meas-attr for dst.c-auto-tank-meas-attr.
define buffer old-pl-level      for src.pl-level.
define buffer new-pl-level      for dst.pl-level.
define buffer old-c-pl-level      for src.c-pl-level.
define buffer new-c-pl-level      for dst.c-pl-level.
define buffer old-pl-level-attr      for src.pl-level-attr.
define buffer new-pl-level-attr      for dst.pl-level-attr.
define buffer old-c-pl-level-attr      for src.c-pl-level-attr.
define buffer new-c-pl-level-attr      for dst.c-pl-level-attr.





define buffer old-c-plc-hist     for src.c-plc-hist.
define buffer new-c-plc-hist     for dst.c-plc-hist.
define buffer old-c-pmp-hist     for src.c-pmp-hist.
define buffer new-c-pmp-hist     for dst.c-pmp-hist.
define buffer old-c-nzl-hist     for src.c-nzl-hist.
define buffer new-c-nzl-hist     for dst.c-nzl-hist.






define buffer new-goods for dst.goods.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  { utl/00000001.i }
  on WRITE of dst.place          override do: end.
  on WRITE of dst.c-place        override do: end.
  on WRITE of dst.place-attr     override do: end.
  on WRITE of dst.c-place-attr   override do: end.
  on WRITE of dst.pl-gds         override do: end.
  on WRITE of dst.c-pl-gds       override do: end.
  on WRITE of dst.c-pl-gds-obj   override do: end.
  on WRITE of dst.pl-gds-attr    override do: end.
  on WRITE of dst.c-pl-gds-attr  override do: end.

  on WRITE of dst.pl-gds-pump    override do: end.
  on WRITE of dst.c-pl-gds-pump  override do: end.
  on WRITE of dst.pl-gds-pump-attr    override do: end.
  on WRITE of dst.c-pl-gds-pump-attr  override do: end.

  on WRITE of dst.pl-pump        override do: end.
  on WRITE of dst.c-pl-pump      override do: end.
  on WRITE of dst.pl-pump-attr   override do: end.
  on WRITE of dst.c-pl-pump-attr override do: end.

  on WRITE of dst.pump           override do: end.
  on WRITE of dst.c-pump         override do: end.
  on WRITE of dst.pump-attr      override do: end.
  on WRITE of dst.c-pump-attr    override do: end.


  on WRITE of dst.pl-pump-nozzle  override do: end.
  on WRITE of dst.c-pl-pump-nozzle  override do: end.
  on WRITE of dst.pl-pump-nozzle-attr  override do: end.
  on WRITE of dst.c-pl-pump-nozzle-attr  override do: end.
  on WRITE of dst.pump-nozzle        override do: end.
  on WRITE of dst.c-pump-nozzle      override do: end.
  on WRITE of dst.pump-nozzle-attr   override do: end.
  on WRITE of dst.c-pump-nozzle-attr override do: end.
  on WRITE of dst.nozzle          override do: end.
  on WRITE of dst.c-nozzle        override do: end.
  on WRITE of dst.nozzle-attr     override do: end.
  on WRITE of dst.c-nozzle-attr   override do: end.
  on WRITE of dst.auto-tank       override do: end.
  on WRITE of dst.c-auto-tank       override do: end.
  on WRITE of dst.auto-tank-attr  override do: end.
  on WRITE of dst.c-auto-tank-attr  override do: end.
  on WRITE of dst.c-plc-hist     override do: end.
  on WRITE of dst.c-pmp-hist     override do: end.
  on WRITE of dst.c-nzl-hist     override do: end.
  on WRITE of dst.auto-tank-meas  override do: end.
  on WRITE of dst.auto-tank-meas-attr  override do: end.
  on WRITE of dst.c-auto-tank-meas-attr  override do: end.
  on WRITE of dst.pl-level         override do: end.
  on WRITE of dst.c-pl-level       override do: end.
  on WRITE of dst.pl-level-attr  override do: end.
  on WRITE of dst.c-pl-level-attr  override do: end.


  { utl/00000002.i place   }
  if varstay-history then do:
    { utl/00000002.i c-place   }
  end.
  { utl/00000002.i place-attr   }
  if varstay-history then do:
    { utl/00000002.i c-place-attr   }
  end.
  { utl/00000002.i pump    }
  if varstay-history then do:
    { utl/00000002.i c-pump    }
  end.
  { utl/00000002.i pump-attr    }
  if varstay-history then do:
    { utl/00000002.i c-pump-attr }
  end.

  { utl/00000002.i pl-pump }
  if varstay-history then do:
    { utl/00000002.i c-pl-pump }
  end.
  { utl/00000002.i pl-pump-attr }
  if varstay-history then do:
    { utl/00000002.i c-pl-pump-attr }
  end.
  { utl/00000002.i pl-pump-nozzle }
  if varstay-history then do:
    { utl/00000002.i c-pl-pump-nozzle }
  end.
  { utl/00000002.i pl-pump-nozzle-attr }
  if varstay-history then do:
    { utl/00000002.i c-pl-pump-nozzle-attr }
  end.
  { utl/00000002.i pump-nozzle }
  if varstay-history then do:
    { utl/00000002.i c-pump-nozzle }
  end.
  { utl/00000002.i pump-nozzle-attr }
  if varstay-history then do:
    { utl/00000002.i c-pump-nozzle-attr }
  end.
  { utl/00000002.i nozzle }
  if varstay-history then do:
    { utl/00000002.i c-nozzle }
  end.
  { utl/00000002.i nozzle-attr }
  if varstay-history then do:
    { utl/00000002.i c-nozzle-attr }
  end.

  for each old-pl-gds no-lock
    ,first new-goods no-lock
    where new-goods.gds-code  = old-pl-gds.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds.
    buffer-copy old-pl-gds to new-pl-gds.
  end.
  if varstay-history then do:
    for each old-c-pl-gds no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds.
      buffer-copy old-c-pl-gds to new-c-pl-gds.
    end.
    for each old-c-pl-gds-obj no-lock
      ,first new-goods no-lock
      where new-goods.gds-code = old-c-pl-gds-obj.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-obj.
      buffer-copy old-c-pl-gds-obj to new-c-pl-gds-obj.
    end.

  end.
  for each old-pl-gds-attr no-lock
    ,first new-goods no-lock
    where new-goods.gds-code = old-pl-gds-attr.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-attr.
    buffer-copy old-pl-gds-attr to new-pl-gds-attr.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-attr no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-attr.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-attr.
      buffer-copy old-c-pl-gds-attr to new-c-pl-gds-attr.
    end.
  end.
  for each old-pl-gds-pump no-lock
    ,first new-goods no-lock
    where new-goods.gds-code  = old-pl-gds-pump.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-pump.
    buffer-copy old-pl-gds-pump to new-pl-gds-pump.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-pump no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-pump.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-pump.
      buffer-copy old-c-pl-gds-pump to new-c-pl-gds-pump.
    end.
  end.
  for each old-pl-gds-pump-attr no-lock
    ,first new-goods no-lock
    where new-goods.gds-code = old-pl-gds-pump-attr.gds-code
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    create new-pl-gds-pump-attr.
    buffer-copy old-pl-gds-pump-attr to new-pl-gds-pump-attr.
  end.
  if varstay-history then do:
    for each old-c-pl-gds-pump-attr no-lock
      ,first new-goods no-lock
      where new-goods.gds-code  = old-c-pl-gds-pump-attr.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
      create new-c-pl-gds-pump-attr.
      buffer-copy old-c-pl-gds-pump-attr to new-c-pl-gds-pump-attr.
    end.
  end.
  if varstay-history then do:
    for each old-c-plc-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if old-c-plc-hist.subject = {&table_pl-gds}
      or old-c-plc-hist.subject = {&table_pl-gds-pump}
      or old-c-plc-hist.subject = {&table_pl-gds-attr}
      or old-c-plc-hist.subject = {&table_pl-gds-pump-attr}
      then do:
        find first new-goods where new-goods.gds-code  = old-c-plc-hist.gds-code no-lock no-error.
        if not available new-goods then do:
          next.
        end.
      end.
      create new-c-plc-hist.
      buffer-copy old-c-plc-hist to new-c-plc-hist.
    end.
    for each old-c-pmp-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if old-c-pmp-hist.subject = {&table_pl-gds-pump}
      or old-c-pmp-hist.subject = {&table_pl-gds-pump-attr}
      then do:
        find first new-goods where new-goods.gds-code  = old-c-pmp-hist.gds-code no-lock no-error.
        if not available new-goods then do:
          next.
        end.
      end.
      create new-c-pmp-hist.
      buffer-copy old-c-pmp-hist to new-c-pmp-hist.
    end.
    for each old-c-nzl-hist no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      create new-c-nzl-hist.
      buffer-copy old-c-nzl-hist to new-c-nzl-hist.
    end.
  end.



  { utl/00000002.i auto-tank      }
  if varstay-history then do:
    { utl/00000002.i c-auto-tank      }
  end.
  { utl/00000002.i auto-tank-attr }
  if varstay-history then do:
    { utl/00000002.i c-auto-tank-attr  }
  end.
  { utl/00000002.i auto-tank-meas }
  { utl/00000002.i auto-tank-meas-attr }
  if varstay-history then do:
    { utl/00000002.i c-auto-tank-meas-attr }
  end.

  { utl/00000002.i pl-level      }
  if varstay-history then do:
    { utl/00000002.i c-pl-level      }
  end.
  { utl/00000002.i pl-level-attr }
  if varstay-history then do:
    { utl/00000002.i c-pl-level-attr  }
  end.

  output stream str-gen close.
  return "Произведен экспорт таблиц: place c-place place-attr c-place-attr pl-gds c-pl-gds c-pl-gds-obj pl-gds-attr c-pl-gds-attr ~
  pl-gds-pump c-pl-gds-pump pl-gds-pump-attr c-pl-gds-pump-attr pump c-pump pump-attr c-pump-attr pl-pump c-pl-pump pl-pump-attr c-pl-pump-attr pl-pump-nozzle c-pl-pump-nozzle ~
  pl-pump-nozzle-attr c-pl-pump-nozzle-attr pump-nozzle c-pump-nozzle pump-nozzle-attr c-pump-nozzle-attr nozzle c-nozzle nozzle-attr c-nozzle-attr ~
  auto-tank c-auto-tank auto-tank-meas auto-tank-attr c-auto-tank-attr auto-tank-meas-attr c-auto-tank-meas-attr c-plc-hist c-nzl-hist c-pmp-hist ~
  pl-level c-pl-level pl-level-attr c-pl-level-attr  " .
end.