block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00176000.p $
$Archive: cut/00176000.p $

Файл пирога обрезания. Относится к категории 181.


alc-sale-lic
alc-sale-lic-attr
alc-sale-lic-type
alc-sale-lic-type-attr
alc-supp-lic
alc-supp-lic-attr
alc-supp-lic-type
alc-supp-lic-type-attr
alc-type
alc-type-attr
alc-type-gds
alc-type-gds-attr
c-alc-sale-lic
c-alc-sale-lic-attr
c-alc-sale-lic-type
c-alc-supp-lic
c-alc-supp-lic-attr
c-alc-supp-lic-type
c-alc-type
c-alc-type-attr
c-alc-type-gds
c-ex-mark
ex-mark
ex-mark-attr
egais-clients
c-egais-clients
egais-gds
c-egais-gds


Автор: Белоусов Илья Александрович
Дата создания: 06/18/09
Author: Ilia Belousov
Creation date: 06/18/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00176000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00176000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
{ cmp/str-glbl.i }

define buffer old-alc-sale-lic           for src.alc-sale-lic          .
define buffer old-alc-sale-lic-attr      for src.alc-sale-lic-attr     .
define buffer old-alc-sale-lic-type      for src.alc-sale-lic-type     .
define buffer old-alc-sale-lic-type-attr for src.alc-sale-lic-type-attr.
define buffer old-alc-supp-lic           for src.alc-supp-lic          .
define buffer old-alc-supp-lic-attr      for src.alc-supp-lic-attr     .
define buffer old-alc-supp-lic-type      for src.alc-supp-lic-type     .
define buffer old-alc-supp-lic-type-attr for src.alc-supp-lic-type-attr.
define buffer old-alc-type               for src.alc-type              .
define buffer old-alc-type-attr          for src.alc-type-attr         .
define buffer old-alc-type-gds           for src.alc-type-gds          .
define buffer old-alc-type-gds-attr      for src.alc-type-gds-attr     .
define buffer old-c-alc-sale-lic         for src.c-alc-sale-lic        .
define buffer old-c-alc-sale-lic-attr    for src.c-alc-sale-lic-attr   .
define buffer old-c-alc-sale-lic-type    for src.c-alc-sale-lic-type   .
define buffer old-c-alc-supp-lic         for src.c-alc-supp-lic        .
define buffer old-c-alc-supp-lic-attr    for src.c-alc-supp-lic-attr   .
define buffer old-c-alc-supp-lic-type    for src.c-alc-supp-lic-type   .
define buffer old-c-alc-type             for src.c-alc-type            .
define buffer old-c-alc-type-attr        for src.c-alc-type-attr       .
define buffer old-c-alc-type-gds         for src.c-alc-type-gds        .
define buffer old-c-ex-mark              for src.c-ex-mark             .
define buffer old-ex-mark                for src.ex-mark               .
define buffer old-ex-mark-attr           for src.ex-mark-attr          .
define buffer old-egais-clients          for src.egais-clients.
define buffer new-egais-clients          for dst.egais-clients.
define buffer old-c-egais-clients        for src.c-egais-clients.
define buffer new-c-egais-clients        for dst.c-egais-clients.


/*define buffer old- for src..*/

define buffer new-alc-sale-lic           for dst.alc-sale-lic          .
define buffer new-alc-sale-lic-attr      for dst.alc-sale-lic-attr     .
define buffer new-alc-sale-lic-type      for dst.alc-sale-lic-type     .
define buffer new-alc-sale-lic-type-attr for dst.alc-sale-lic-type-attr.
define buffer new-alc-supp-lic           for dst.alc-supp-lic          .
define buffer new-alc-supp-lic-attr      for dst.alc-supp-lic-attr     .
define buffer new-alc-supp-lic-type      for dst.alc-supp-lic-type     .
define buffer new-alc-supp-lic-type-attr for dst.alc-supp-lic-type-attr.
define buffer new-alc-type               for dst.alc-type              .
define buffer new-alc-type-attr          for dst.alc-type-attr         .
define buffer new-alc-type-gds           for dst.alc-type-gds          .
define buffer new-alc-type-gds-attr      for dst.alc-type-gds-attr     .
define buffer new-c-alc-sale-lic         for dst.c-alc-sale-lic        .
define buffer new-c-alc-sale-lic-attr    for dst.c-alc-sale-lic-attr   .
define buffer new-c-alc-sale-lic-type    for dst.c-alc-sale-lic-type   .
define buffer new-c-alc-supp-lic         for dst.c-alc-supp-lic        .
define buffer new-c-alc-supp-lic-attr    for dst.c-alc-supp-lic-attr   .
define buffer new-c-alc-supp-lic-type    for dst.c-alc-supp-lic-type   .
define buffer new-c-alc-type             for dst.c-alc-type            .
define buffer new-c-alc-type-attr        for dst.c-alc-type-attr       .
define buffer new-c-alc-type-gds         for dst.c-alc-type-gds        .
define buffer new-c-ex-mark              for dst.c-ex-mark             .
define buffer new-ex-mark                for dst.ex-mark               .
define buffer new-ex-mark-attr           for dst.ex-mark-attr          .
define buffer old-egais-gds          for src.egais-gds.
define buffer new-egais-gds          for dst.egais-gds.
define buffer old-c-egais-gds        for src.c-egais-gds.
define buffer new-c-egais-gds        for dst.c-egais-gds.


define buffer new-goods                  for dst.goods .




/*define buffer new- for dst..*/


do
on error undo, return error SUBSTITUTE ( "&1 &2 &3"
                                       , return-value
                                       , error-status:get-message(1)
                                       , error-status:get-message(2)
                                       ) :
{ utl/00000001.i }

on WRITE of dst.alc-sale-lic                           override do: end.
on WRITE of dst.alc-sale-lic-attr                      override do: end.
on WRITE of dst.alc-sale-lic-type                      override do: end.
on WRITE of dst.alc-sale-lic-type-attr                 override do: end.
on WRITE of dst.alc-supp-lic                           override do: end.
on WRITE of dst.alc-supp-lic-attr                      override do: end.
on WRITE of dst.alc-supp-lic-type                      override do: end.
on WRITE of dst.alc-supp-lic-type-attr                 override do: end.
on WRITE of dst.alc-type                               override do: end.
on WRITE of dst.alc-type-attr                          override do: end.
on WRITE of dst.alc-type-gds                           override do: end.
on WRITE of dst.alc-type-gds-attr                      override do: end.
on WRITE of dst.c-alc-sale-lic                         override do: end.
on WRITE of dst.c-alc-sale-lic-attr                    override do: end.
on WRITE of dst.c-alc-sale-lic-type                    override do: end.
on WRITE of dst.c-alc-supp-lic                         override do: end.
on WRITE of dst.c-alc-supp-lic-attr                    override do: end.
on WRITE of dst.c-alc-supp-lic-type                    override do: end.
on WRITE of dst.c-alc-type                             override do: end.
on WRITE of dst.c-alc-type-attr                        override do: end.
on WRITE of dst.c-alc-type-gds                         override do: end.
on WRITE of dst.c-ex-mark                              override do: end.
on WRITE of dst.ex-mark                                override do: end.
on WRITE of dst.ex-mark-attr                           override do: end.
on WRITE of dst.egais-clients                          override do: end.
on WRITE of dst.c-egais-clients                        override do: end.
on WRITE of dst.egais-gds                              override do: end.
on WRITE of dst.c-egais-gds                            override do: end.



{ utl/00000002.i alc-sale-lic           }
{ utl/00000002.i alc-sale-lic-attr      }
{ utl/00000002.i alc-sale-lic-type      }
{ utl/00000002.i alc-sale-lic-type-attr }
{ utl/00000002.i alc-supp-lic           }
{ utl/00000002.i alc-supp-lic-attr      }
{ utl/00000002.i alc-supp-lic-type      }
{ utl/00000002.i alc-supp-lic-type-attr }
{ utl/00000002.i alc-type               }
{ utl/00000002.i alc-type-attr          }

for each old-alc-type-gds
    no-lock
    :

   FIND first new-goods
        where new-goods.gds-code = old-alc-type-gds.gds-code
        no-lock
        no-error
        .

   IF AVAILABLE new-goods
   THEN DO:
      create new-alc-type-gds.
      BUFFER-COPY old-alc-type-gds to new-alc-type-gds.
   END.

end.

for each old-alc-type-gds-attr
   no-lock
   :

   FIND first new-goods
        where new-goods.gds-code = old-alc-type-gds-attr.gds-code
        no-lock
        no-error
        .

   IF AVAILABLE new-goods
   THEN DO:
      create new-alc-type-gds-attr.
      BUFFER-COPY old-alc-type-gds-attr to new-alc-type-gds-attr.
   END.

end.

if varstay-history then do:
   { utl/00000002.i c-alc-sale-lic         }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-sale-lic-attr    }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-sale-lic-type    }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-supp-lic         }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-supp-lic-attr    }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-supp-lic-type    }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-type             }
end.
if varstay-history then do:
   { utl/00000002.i c-alc-type-attr        }
end.

if varstay-history then do:
   for each old-c-alc-type-gds
   no-lock
   :

      FIND first new-goods
         where new-goods.gds-code = old-alc-type-gds-attr.gds-code
         no-lock
         no-error
         .

      IF AVAILABLE new-goods
      THEN DO:
         create new-c-alc-type-gds.
         BUFFER-COPY old-c-alc-type-gds to new-c-alc-type-gds.
      end.
   end.
end.

{ utl/00000002.i ex-mark                }
{ utl/00000002.i ex-mark-attr           }
if varstay-history then do:
   { utl/00000002.i c-ex-mark              }
end.
{ utl/00000002.i egais-gds " , first new-goods where new-goods.gds-code = old-egais-gds.gds-code " }
if varstay-history then do:
  { utl/00000002.i c-egais-gds " , first new-goods where new-goods.gds-code = old-c-egais-gds.gds-code " }
end.
{ utl/00000002.i egais-clients }
if varstay-history then do:
  { utl/00000002.i c-egais-clients }
end.


/*{ utl/00000002.i  }*/

output stream str-gen close.
return "Произведен экспорт таблиц: ~
alc-sale-lic ~
alc-sale-lic-attr ~
alc-sale-lic-type ~
alc-sale-lic-type-attr ~
alc-supp-lic ~
alc-supp-lic-attr ~
alc-supp-lic-type ~
alc-supp-lic-type-attr ~
alc-type ~
alc-type-attr ~
alc-type-gds ~
alc-type-gds-attr ~
c-alc-sale-lic ~
c-alc-sale-lic-attr ~
c-alc-sale-lic-type ~
c-alc-supp-lic ~
c-alc-supp-lic-attr ~
c-alc-supp-lic-type ~
c-alc-type ~
c-alc-type-attr ~
c-alc-type-gds ~
c-ex-mark ~
ex-mark ~
ex-mark-attr ~
egais-gds ~
c-egais-gds ~
egais-clients ~
c-egais-clients ~
.".

end.