block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00133000.p $
$Archive: cut/00133000.p $

Файл пирога обрезания. Относится к категории 133.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
pay-type
c-pay-type
pay-type-attr
c-pay-type-attr
trn-reason
c-trn-reason
trn-reason-host
c-trn-reason-host
trn-reason-obj
c-trn-reason-obj
c-trn-rsn-attr
trn-rsn-attr
c-trn-rsn-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00133000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00133000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 133.".

{ cmp/str-glbl.i }

define buffer old-pay-type for src.pay-type.
define buffer new-pay-type for dst.pay-type.
define buffer old-c-pay-type for src.c-pay-type.
define buffer new-c-pay-type for dst.c-pay-type.
define buffer old-pay-type-attr for src.pay-type-attr.
define buffer new-pay-type-attr for dst.pay-type-attr.
define buffer old-c-pay-type-attr for src.c-pay-type-attr.
define buffer new-c-pay-type-attr for dst.c-pay-type-attr.
define buffer old-trn-reason for src.trn-reason.
define buffer new-trn-reason for dst.trn-reason.
define buffer old-c-trn-reason for src.c-trn-reason.
define buffer new-c-trn-reason for dst.c-trn-reason.
define buffer old-trn-reason-host for src.trn-reason-host.
define buffer new-trn-reason-host for dst.trn-reason-host.
define buffer old-c-trn-reason-host for src.c-trn-reason-host.
define buffer new-c-trn-reason-host for dst.c-trn-reason-host.
define buffer old-trn-reason-obj for src.trn-reason-obj.
define buffer new-trn-reason-obj for dst.trn-reason-obj.
define buffer old-c-trn-reason-obj for src.c-trn-reason-obj.
define buffer new-c-trn-reason-obj for dst.c-trn-reason-obj.
define buffer old-trn-rsn-attr for src.trn-rsn-attr.
define buffer new-trn-rsn-attr for dst.trn-rsn-attr.
define buffer old-c-trn-rsn-attr for src.c-trn-rsn-attr.
define buffer new-c-trn-rsn-attr for dst.c-trn-rsn-attr.





do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
on WRITE of dst.pay-type override do: end.
on WRITE of dst.c-pay-type override do: end.
on WRITE of dst.pay-type-attr override do: end.
on WRITE of dst.c-pay-type-attr override do: end.
on WRITE of dst.trn-reason override do: end.
on WRITE of dst.c-trn-reason override do: end.
on WRITE of dst.trn-reason-host override do: end.
on WRITE of dst.c-trn-reason-host override do: end.
on WRITE of dst.trn-reason-obj override do: end.
on WRITE of dst.c-trn-reason-obj override do: end.
on WRITE of dst.trn-reason override do: end.
on WRITE of dst.c-trn-rsn-attr override do: end.
on WRITE of dst.trn-rsn-attr override do: end.


{ utl/00000002.i pay-type }
if varstay-history then do:
  { utl/00000002.i c-pay-type }
end.
{ utl/00000002.i pay-type-attr }
if varstay-history then do:
  { utl/00000002.i c-pay-type-attr }
end.
{ utl/00000002.i trn-reason }
if varstay-history then do:
  { utl/00000002.i c-trn-reason }
end.
{ utl/00000002.i trn-rsn-attr }
if varstay-history then do:
  { utl/00000002.i c-trn-rsn-attr }
end.
{ utl/00000002.i trn-reason-host }
if varstay-history then do:
  { utl/00000002.i c-trn-reason-host }
end.
{ utl/00000002.i trn-reason-obj }
if varstay-history then do:
  { utl/00000002.i c-trn-reason-obj }
end.

output stream str-gen close.
return "Произведен экспорт таблиц: pay-type c-pay-type pay-type-attr c-pay-type-attr ~
trn-reason c-trn-reason trn-rsn-attr c-trn-rsn-attr ~
trn-reason-host c-trn-reason-host trn-reason-obj c-trn-reason-obj.".
end.