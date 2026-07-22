block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00210000.p $
$Archive: cut/00210000.p $

Файл пирога обрезания. Относится к категории 210.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:

condition-keeping
c-condition-keeping
condition-keeping-attr
c-condition-keeping-attr
deliv-type-cond-keep
c-deliv-type-cond-keep
deliv-type-cond-keep-attr
c-deliv-type-cond-keep-attr
delivery-subject
c-delivery-subject
delivery-subject-attr
c-delivery-subject-attr
delivery-type
c-delivery-type
delivery-type-attr
c-delivery-type-attr
delivery-type-subject
c-delivery-type-subject
delivery-type-subject-attr
c-delivery-type-subject-attr
group-period-validity
c-group-period-validity
group-period-validity-attr
c-group-period-validity-attr
var-deliv-gr-per-val
c-var-deliv-gr-per-val
var-deliv-gr-per-val-attr
variant-delivery
c-variant-delivery
variant-delivery-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00210000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00210000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 210.".
{ cmp/str-glbl.i }

define buffer old-upgrade       for src.upgrade.
define buffer new-upgrade       for dst.upgrade.

define buffer old-condition-keeping             for src.condition-keeping          .
define buffer new-condition-keeping             for dst.condition-keeping          .
define buffer old-c-condition-keeping           for src.c-condition-keeping        .
define buffer new-c-condition-keeping           for dst.c-condition-keeping        .
define buffer old-condition-keeping-attr        for src.condition-keeping-attr          .
define buffer new-condition-keeping-attr        for dst.condition-keeping-attr          .
define buffer old-c-condition-keeping-attr      for src.c-condition-keeping-attr        .
define buffer new-c-condition-keeping-attr      for dst.c-condition-keeping-attr        .
define buffer old-deliv-type-cond-keep          for src.deliv-type-cond-keep       .
define buffer new-deliv-type-cond-keep          for dst.deliv-type-cond-keep       .
define buffer old-c-deliv-type-cond-keep        for src.c-deliv-type-cond-keep     .
define buffer new-c-deliv-type-cond-keep        for dst.c-deliv-type-cond-keep     .
define buffer old-deliv-type-cond-keep-attr     for src.deliv-type-cond-keep-attr       .
define buffer new-deliv-type-cond-keep-attr     for dst.deliv-type-cond-keep-attr       .
define buffer old-c-deliv-type-cond-keep-attr   for src.c-deliv-type-cond-keep-attr     .
define buffer new-c-deliv-type-cond-keep-attr   for dst.c-deliv-type-cond-keep-attr     .
define buffer old-delivery-subject              for src.delivery-subject           .
define buffer new-delivery-subject              for dst.delivery-subject           .
define buffer old-c-delivery-subject            for src.c-delivery-subject         .
define buffer new-c-delivery-subject            for dst.c-delivery-subject         .
define buffer old-delivery-subject-attr         for src.delivery-subject-attr      .
define buffer new-delivery-subject-attr         for dst.delivery-subject-attr    .
define buffer old-c-delivery-subject-attr       for src.c-delivery-subject-attr    .
define buffer new-c-delivery-subject-attr       for dst.c-delivery-subject-attr    .
define buffer old-delivery-type                 for src.delivery-type              .
define buffer new-delivery-type                 for dst.delivery-type              .
define buffer old-c-delivery-type               for src.c-delivery-type            .
define buffer new-c-delivery-type               for dst.c-delivery-type            .
define buffer old-delivery-type-attr            for src.delivery-type-attr              .
define buffer new-delivery-type-attr            for dst.delivery-type-attr              .
define buffer old-c-delivery-type-attr          for src.c-delivery-type-attr            .
define buffer new-c-delivery-type-attr          for dst.c-delivery-type-attr            .
define buffer old-delivery-type-subject         for src.delivery-type-subject      .
define buffer new-delivery-type-subject         for dst.delivery-type-subject      .
define buffer old-c-delivery-type-subject       for src.c-delivery-type-subject    .
define buffer new-c-delivery-type-subject       for dst.c-delivery-type-subject    .
define buffer old-delivery-type-subject-attr    for src.delivery-type-subject-attr      .
define buffer new-delivery-type-subject-attr    for dst.delivery-type-subject-attr      .
define buffer old-c-delivery-type-subject-attr  for src.c-delivery-type-subject-attr    .
define buffer new-c-delivery-type-subject-attr  for dst.c-delivery-type-subject-attr    .
define buffer old-group-period-validity         for src.group-period-validity      .
define buffer new-group-period-validity         for dst.group-period-validity      .
define buffer old-c-group-period-validity       for src.c-group-period-validity    .
define buffer new-c-group-period-validity       for dst.c-group-period-validity    .
define buffer old-group-period-validity-attr    for src.group-period-validity-attr      .
define buffer new-group-period-validity-attr    for dst.group-period-validity-attr      .
define buffer old-c-group-period-validity-attr  for src.c-group-period-validity-attr    .
define buffer new-c-group-period-validity-attr  for dst.c-group-period-validity-attr    .
define buffer old-var-deliv-gr-per-val          for src.var-deliv-gr-per-val       .
define buffer new-var-deliv-gr-per-val          for dst.var-deliv-gr-per-val       .
define buffer old-c-var-deliv-gr-per-val        for src.c-var-deliv-gr-per-val     .
define buffer new-c-var-deliv-gr-per-val        for dst.c-var-deliv-gr-per-val     .
define buffer old-var-deliv-gr-per-val-attr     for src.var-deliv-gr-per-val-attr  .
define buffer new-var-deliv-gr-per-val-attr     for dst.var-deliv-gr-per-val-attr  .
define buffer old-variant-delivery              for src.variant-delivery           .
define buffer new-variant-delivery              for dst.variant-delivery           .
define buffer old-c-variant-delivery            for src.c-variant-delivery         .
define buffer new-c-variant-delivery            for dst.c-variant-delivery         .
define buffer old-variant-delivery-attr         for src.variant-delivery-attr      .
define buffer new-variant-delivery-attr         for dst.variant-delivery-attr      .


on WRITE of dst.condition-keeping               override do: end.
on WRITE of dst.c-condition-keeping             override do: end.
on WRITE of dst.condition-keeping-attr          override do: end.
on WRITE of dst.c-condition-keeping-attr        override do: end.
on WRITE of dst.deliv-type-cond-keep            override do: end.
on WRITE of dst.c-deliv-type-cond-keep          override do: end.
on WRITE of dst.deliv-type-cond-keep-attr       override do: end.
on WRITE of dst.c-deliv-type-cond-keep-attr     override do: end.
on WRITE of dst.delivery-subject                override do: end.
on WRITE of dst.c-delivery-subject              override do: end.
on WRITE of dst.delivery-subject-attr           override do: end.
on WRITE of dst.c-delivery-subject-attr         override do: end.
on WRITE of dst.delivery-type                   override do: end.
on WRITE of dst.c-delivery-type                 override do: end.
on WRITE of dst.delivery-type-attr              override do: end.
on WRITE of dst.c-delivery-type-attr            override do: end.
on WRITE of dst.delivery-type-subject           override do: end.
on WRITE of dst.c-delivery-type-subject         override do: end.
on WRITE of dst.delivery-type-subject-attr      override do: end.
on WRITE of dst.c-delivery-type-subject-attr    override do: end.
on WRITE of dst.group-period-validity           override do: end.
on WRITE of dst.c-group-period-validity         override do: end.
on WRITE of dst.group-period-validity-attr      override do: end.
on WRITE of dst.c-group-period-validity-attr    override do: end.
on WRITE of dst.var-deliv-gr-per-val            override do: end.
on WRITE of dst.c-var-deliv-gr-per-val          override do: end.
on WRITE of dst.var-deliv-gr-per-val-attr       override do: end.
on WRITE of dst.variant-delivery                override do: end.
on WRITE of dst.c-variant-delivery              override do: end.
on WRITE of dst.variant-delivery-attr           override do: end.



do
on error undo, return error
:
  { utl/00000001.i }


  { utl/00000002.i condition-keeping             }
  if varstay-history then do:
    { utl/00000002.i c-condition-keeping           }
  end.
  { utl/00000002.i condition-keeping-attr        }
  if varstay-history then do:
    { utl/00000002.i c-condition-keeping-attr      }
  end.
  { utl/00000002.i deliv-type-cond-keep          }
  if varstay-history then do:
    { utl/00000002.i c-deliv-type-cond-keep        }
  end.
  { utl/00000002.i deliv-type-cond-keep-attr     }
  if varstay-history then do:
    { utl/00000002.i c-deliv-type-cond-keep-attr   }
  end.
  { utl/00000002.i delivery-subject              }
  if varstay-history then do:
    { utl/00000002.i c-delivery-subject            }
  end.
  { utl/00000002.i delivery-subject-attr         }
  if varstay-history then do:
    { utl/00000002.i c-delivery-subject-attr       }
  end.
  { utl/00000002.i delivery-type                 }
  if varstay-history then do:
    { utl/00000002.i c-delivery-type               }
  end.
  { utl/00000002.i delivery-type-attr            }
  if varstay-history then do:
    { utl/00000002.i c-delivery-type-attr          }
  end.
  { utl/00000002.i delivery-type-subject         }
  if varstay-history then do:
    { utl/00000002.i c-delivery-type-subject       }
  end.
  { utl/00000002.i delivery-type-subject-attr    }
  if varstay-history then do:
    { utl/00000002.i c-delivery-type-subject-attr  }
  end.
  { utl/00000002.i group-period-validity         }
  if varstay-history then do:
    { utl/00000002.i c-group-period-validity       }
  end.
  { utl/00000002.i group-period-validity-attr    }
  if varstay-history then do:
    { utl/00000002.i c-group-period-validity-attr  }
  end.
  { utl/00000002.i var-deliv-gr-per-val          }
  if varstay-history then do:
    { utl/00000002.i c-var-deliv-gr-per-val        }
  end.
  { utl/00000002.i var-deliv-gr-per-val-attr     }
  { utl/00000002.i variant-delivery              }
  if varstay-history then do:
    { utl/00000002.i c-variant-delivery            }
  end.
  { utl/00000002.i variant-delivery-attr         }

output stream str-gen close.
  return "Произведен экспорт таблиц: condition-keeping c-condition-keeping condition-keeping-attr c-condition-keeping-attr " +
"deliv-type-cond-keep c-deliv-type-cond-keep deliv-type-cond-keep-attr c-deliv-type-cond-keep-attr " +
"delivery-subject c-delivery-subject  delivery-subject-attr c-delivery-subject-attr " +
"delivery-type c-delivery-type delivery-type-attr c-delivery-type-attr " +
"delivery-type-subject c-delivery-type-subject delivery-type-subject-attr c-delivery-type-subject-attr " +
"group-period-validity c-group-period-validity group-period-validity-attr c-group-period-validity-attr " +
"var-deliv-gr-per-val c-var-deliv-gr-per-val var-deliv-gr-per-val " +
"variant-delivery c-variant-delivery variant-delivery.".
end.