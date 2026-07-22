block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00019000.p $
$Archive: cut/00019000.p $
Файл пирога обрезания. Относится к категории 19.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
tax
c-tax
tax-attr
tax-rate-gds
c-tax-rate-gds
tax-rate-gds-attr
tax-rate
c-tax-rate
tax-rate-attr
tax-rate-value
tax-rate-value-attr
tax-rate-gds-grp
c-tax-rate-gds-grp
tax-rate-gds-grp-attr
tax-units
c-tax-units
tax-units-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00019000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00019000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 19.".

{ cmp/str-glbl.i }

define buffer old-tax              for src.tax             .
define buffer new-tax              for dst.tax             .
define buffer old-c-tax            for src.c-tax           .
define buffer new-c-tax            for dst.c-tax           .
define buffer old-tax-attr         for src.tax-attr        .
define buffer new-tax-attr         for dst.tax-attr        .


define buffer old-tax-rate-gds     for src.tax-rate-gds    .
define buffer new-tax-rate-gds     for dst.tax-rate-gds    .
define buffer old-tax-rate-gds-attr for src.tax-rate-gds-attr .
define buffer new-tax-rate-gds-attr for dst.tax-rate-gds-attr .
define buffer old-tax-rate         for src.tax-rate        .
define buffer new-tax-rate         for dst.tax-rate        .
define buffer old-c-tax-rate       for src.c-tax-rate      .
define buffer new-c-tax-rate       for dst.c-tax-rate      .
define buffer old-tax-rate-attr    for src.tax-rate-attr   .
define buffer new-tax-rate-attr    for dst.tax-rate-attr   .
define buffer old-tax-rate-value   for src.tax-rate-value  .
define buffer new-tax-rate-value   for dst.tax-rate-value  .
define buffer old-tax-rate-value-attr   for src.tax-rate-value-attr .
define buffer new-tax-rate-value-attr   for dst.tax-rate-value-attr  .
define buffer old-c-tax-rate-gds-grp for src.c-tax-rate-gds-grp.
define buffer new-c-tax-rate-gds-grp for dst.c-tax-rate-gds-grp.
define buffer old-tax-rate-gds-grp for src.tax-rate-gds-grp.
define buffer new-tax-rate-gds-grp for dst.tax-rate-gds-grp.
define buffer old-tax-rate-gds-grp-attr for src.tax-rate-gds-grp-attr.
define buffer new-tax-rate-gds-grp-attr for dst.tax-rate-gds-grp-attr.
define buffer old-tax-units        for src.tax-units       .
define buffer new-tax-units        for dst.tax-units       .
define buffer old-c-tax-units      for src.c-tax-units       .
define buffer new-c-tax-units      for dst.c-tax-units       .
define buffer old-tax-units-attr   for src.tax-units-attr       .
define buffer new-tax-units-attr   for dst.tax-units-attr       .
define buffer old-c-tax-hist       for src.c-tax-hist       .
define buffer new-c-tax-hist       for dst.c-tax-hist       .





define buffer new-goods            for dst.goods.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.tax                override do: end.
on WRITE of dst.tax-attr           override do: end.
on WRITE of dst.c-tax              override do: end.
on WRITE of dst.tax-rate-gds       override do: end.
on WRITE of dst.tax-rate-gds-attr  override do: end.
on WRITE of dst.tax-rate           override do: end.
on WRITE of dst.c-tax-rate         override do: end.
on WRITE of dst.tax-rate-attr      override do: end.
on WRITE of dst.tax-rate-value     override do: end.
on WRITE of dst.tax-rate-value-attr override do: end.
on WRITE of dst.tax-rate-gds-grp   override do: end.
on WRITE of dst.c-tax-rate-gds-grp override do: end.
on WRITE of dst.tax-rate-gds-grp-attr   override do: end.
on WRITE of dst.tax-units          override do: end.
on WRITE of dst.c-tax-units        override do: end.
on WRITE of dst.tax-units-attr     override do: end.
on WRITE of dst.c-tax-hist         override do: end.

{ utl/00000002.i tax }
for each old-tax-rate-gds no-lock,
   first new-goods where new-goods.gds-code    = old-tax-rate-gds.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-tax-rate-gds.
  buffer-copy old-tax-rate-gds to new-tax-rate-gds.
end.
for each old-tax-rate-gds-attr no-lock,
   first new-goods where new-goods.gds-code    = old-tax-rate-gds-attr.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-tax-rate-gds-attr.
  buffer-copy old-tax-rate-gds-attr to new-tax-rate-gds-attr.
end.


{ utl/00000002.i tax-rate         }
{ utl/00000002.i tax-rate-attr    }
{ utl/00000002.i tax-rate-value   }
{ utl/00000002.i tax-rate-value-attr  }
{ utl/00000002.i tax-rate-gds-grp }
{ utl/00000002.i tax-rate-gds-grp-attr }
{ utl/00000002.i tax-units        }
{ utl/00000002.i tax-units-attr   }
if varstay-history then do:
  { utl/00000002.i c-tax            }
  { utl/00000002.i c-tax-rate         }
  { utl/00000002.i c-tax-rate-gds-grp }
  { utl/00000002.i c-tax-units        }
  { utl/00000002.i c-tax-hist         }
end.

output stream str-gen close.
return "Произведен экспорт таблиц: tax c-tax-hist c-tax tax-attr tax-rate-gds tax-rate-gds-attr tax-rate c-tax-rate tax-rate-attr tax-rate-value tax-rate-value-attr ~
tax-rate-gds-grp c-tax-rate-gds-grp tax-rate-gds-grp-attr tax-units c-tax-units tax-units-attr ".
end.