block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00111000.p $
$Archive: cut/00111000.p $

Файл пирога обрезания. Относится к категории 104.

ext-system
c-ext-system
ext-system-attr
esys-all-attr
esys-pck-keys
esys-pck-rcvd
esys-pck-sent
esys-route
esys-route-dump
c-esys-datatype-exp
c-esys-datatype-imp
datatype-exp
datatype-exp-attr
datatype-imp
datatype-imp-attr
datatype-table
datatype-table-exp
datatype-table-field
datatype-table-field-exp
datatype-table-field-imp
datatype-table-imp
esys-datatype-exp
esys-datatype-imp



Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/09
Author: Bakhtadze Natalya
Creation date: 05/25/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00111000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00111000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 111.".
{ cmp/str-glbl.i }

define buffer old-ext-system for src.ext-system.
define buffer new-ext-system for dst.ext-system.
define buffer old-c-ext-system for src.c-ext-system.
define buffer new-c-ext-system for dst.c-ext-system.
define buffer old-ext-system-attr for src.ext-system-attr.
define buffer new-ext-system-attr for dst.ext-system-attr.
define buffer old-esys-all-attr for src.esys-all-attr.
define buffer new-esys-all-attr for dst.esys-all-attr.
define buffer old-esys-pck-keys for src.esys-pck-keys.
define buffer new-esys-pck-keys for dst.esys-pck-keys.
define buffer old-esys-pck-rcvd for src.esys-pck-rcvd.
define buffer new-esys-pck-rcvd for dst.esys-pck-rcvd.
define buffer old-esys-pck-sent for src.esys-pck-sent.
define buffer new-esys-pck-sent for dst.esys-pck-sent.
define buffer old-esys-route for src.esys-route.
define buffer new-esys-route for dst.esys-route.
define buffer old-esys-route-dump for src.esys-route-dump.
define buffer new-esys-route-dump for dst.esys-route-dump.

define buffer old-c-esys-datatype-exp      for src.c-esys-datatype-exp     .
define buffer old-c-esys-datatype-imp      for src.c-esys-datatype-imp     .
define buffer old-datatype-exp             for src.datatype-exp            .
define buffer old-datatype-exp-attr        for src.datatype-exp-attr       .
define buffer old-datatype-imp             for src.datatype-imp            .
define buffer old-datatype-imp-attr        for src.datatype-imp-attr       .
define buffer old-datatype-table           for src.datatype-table          .
define buffer old-datatype-table-exp       for src.datatype-table-exp      .
define buffer old-datatype-table-field     for src.datatype-table-field    .
define buffer old-datatype-table-field-exp for src.datatype-table-field-exp.
define buffer old-datatype-table-field-imp for src.datatype-table-field-imp.
define buffer old-datatype-table-imp       for src.datatype-table-imp      .
define buffer old-esys-datatype-exp        for src.esys-datatype-exp       .
define buffer old-esys-datatype-imp        for src.esys-datatype-imp       .


define buffer new-c-esys-datatype-exp      for dst.c-esys-datatype-exp     .
define buffer new-c-esys-datatype-imp      for dst.c-esys-datatype-imp     .
define buffer new-datatype-exp             for dst.datatype-exp            .
define buffer new-datatype-exp-attr        for dst.datatype-exp-attr       .
define buffer new-datatype-imp             for dst.datatype-imp            .
define buffer new-datatype-imp-attr        for dst.datatype-imp-attr       .
define buffer new-datatype-table           for dst.datatype-table          .
define buffer new-datatype-table-exp       for dst.datatype-table-exp      .
define buffer new-datatype-table-field     for dst.datatype-table-field    .
define buffer new-datatype-table-field-exp for dst.datatype-table-field-exp.
define buffer new-datatype-table-field-imp for dst.datatype-table-field-imp.
define buffer new-datatype-table-imp       for dst.datatype-table-imp      .
define buffer new-esys-datatype-exp        for dst.esys-datatype-exp       .
define buffer new-esys-datatype-imp        for dst.esys-datatype-imp       .

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.ext-system override do: end.
on WRITE of dst.c-ext-system override do: end.
on WRITE of dst.ext-system-attr override do: end.
on WRITE of dst.esys-all-attr override do: end.
on WRITE of dst.esys-pck-keys override do: end.
on WRITE of dst.esys-pck-rcvd override do: end.
on WRITE of dst.esys-pck-sent override do: end.
on WRITE of dst.esys-route override do: end.
on WRITE of dst.esys-route-dump override do: end.
on WRITE of dst.c-esys-datatype-exp      override do: end.
on WRITE of dst.c-esys-datatype-imp      override do: end.
on WRITE of dst.datatype-exp             override do: end.
on WRITE of dst.datatype-exp-attr        override do: end.
on WRITE of dst.datatype-imp             override do: end.
on WRITE of dst.datatype-imp-attr        override do: end.
on WRITE of dst.datatype-table           override do: end.
on WRITE of dst.datatype-table-exp       override do: end.
on WRITE of dst.datatype-table-field     override do: end.
on WRITE of dst.datatype-table-field-exp override do: end.
on WRITE of dst.datatype-table-field-imp override do: end.
on WRITE of dst.datatype-table-imp       override do: end.
on WRITE of dst.esys-datatype-exp        override do: end.
on WRITE of dst.esys-datatype-imp        override do: end.

{ utl/00000002.i ext-system }
if varstay-history then do:
  { utl/00000002.i c-ext-system }
end.
{ utl/00000002.i ext-system-attr }
{ utl/00000002.i esys-all-attr }
{ utl/00000002.i esys-pck-keys }
{ utl/00000002.i esys-pck-rcvd }
{ utl/00000002.i esys-pck-sent }
{ utl/00000002.i esys-route }
{ utl/00000002.i esys-route-dump }
{ utl/00000002.i datatype-exp             }
{ utl/00000002.i datatype-exp-attr        }
{ utl/00000002.i datatype-imp             }
{ utl/00000002.i datatype-imp-attr        }
{ utl/00000002.i datatype-table           }
{ utl/00000002.i datatype-table-exp       }
{ utl/00000002.i datatype-table-field     }
{ utl/00000002.i datatype-table-field-exp }
{ utl/00000002.i datatype-table-field-imp }
{ utl/00000002.i datatype-table-imp       }
{ utl/00000002.i esys-datatype-exp        }
{ utl/00000002.i esys-datatype-imp        }

if varstay-history then do:
  { utl/00000002.i c-esys-datatype-exp }
  { utl/00000002.i c-esys-datatype-imp }
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ext-system c-ext-system ext-system-attr esys-all-attr" +
"esys-pck-keys esys-pck-rcvd esys-pck-sent esys-route esys-route-dump" +
"~
c-esys-datatype-exp ~
c-esys-datatype-imp ~
datatype-exp ~
datatype-exp-attr ~
datatype-imp ~
datatype-imp-attr ~
datatype-table ~
datatype-table-exp ~
datatype-table-field ~
datatype-table-field-exp ~
datatype-table-field-imp ~
datatype-table-imp ~
esys-datatype-exp ~
esys-datatype-imp ~
.".
end.