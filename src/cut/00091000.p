block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00091000.p $
$Archive: cut/00091000.p $

Файл пирога обрезания. Относится к категории 91.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06


Обработка таблиц:

dis-rule
c-dis-rule
dis-rule-attr
c-dis-rule-attr
dis-time-rule
c-dis-time-rule
dis-time-rule-attr
dis-cfg-rule
c-dis-cfg-rule
dis-cfg-rule-attr
drt-prop
c-drt-prop
dis-some-rule
c-dis-some-rule
dis-some-rule-attr
dis-card-type
c-dis-card-type
dis-card-mask
c-dis-card-mask
dis-card-mask-attr
c-dis-card-mask-attr
dis-dct-rule
c-dis-dct-rule
dis-dct-rule-attr
dis-card
c-dc-hist
c-dis-card
dis-card-property
c-dis-card-property
dis-card-long
c-dis-card-long
dis-card-long-attr
c-dis-card-long-attr
dis-obj
c-dis-cobj
dis-host
c-dis-host
dis-dc-rule
c-dis-dc-rule
dis-dc-rule-attr
payment
c-payment
payment-attr
c-payment-attr
stop-list
stop-list-attr
stop-list-line
stop-list-line-attr
c-stop-list
c-stop-list-line

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00091000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00091000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 91.".

{ cmp/str-glbl.i }

define buffer old-dis-card-type         for src.dis-card-type.
define buffer new-dis-card-type         for dst.dis-card-type.
define buffer old-c-dis-card-type       for src.c-dis-card-type.
define buffer new-c-dis-card-type       for dst.c-dis-card-type.
define buffer old-dis-card-type-attr    for src.dis-card-type-attr.
define buffer new-dis-card-type-attr    for dst.dis-card-type-attr.
define buffer old-c-dis-card-type-attr  for src.c-dis-card-type-attr.
define buffer new-c-dis-card-type-attr  for dst.c-dis-card-type-attr.
define buffer old-dis-card-mask         for src.dis-card-mask.
define buffer new-dis-card-mask         for dst.dis-card-mask.
define buffer old-c-dis-card-mask       for src.c-dis-card-mask.
define buffer new-c-dis-card-mask       for dst.c-dis-card-mask.
define buffer old-dis-card-mask-attr    for src.dis-card-mask-attr.
define buffer new-dis-card-mask-attr    for dst.dis-card-mask-attr.
define buffer old-c-dis-card-mask-attr  for src.c-dis-card-mask-attr.
define buffer new-c-dis-card-mask-attr  for dst.c-dis-card-mask-attr.
define buffer old-dis-dct-rule          for src.dis-dct-rule.
define buffer new-dis-dct-rule          for dst.dis-dct-rule.
define buffer old-c-dis-dct-rule        for src.c-dis-dct-rule.
define buffer new-c-dis-dct-rule        for dst.c-dis-dct-rule.
define buffer old-dis-dct-rule-attr     for src.dis-dct-rule-attr.
define buffer new-dis-dct-rule-attr     for dst.dis-dct-rule-attr.
define buffer old-dis-card              for src.dis-card.
define buffer new-dis-card              for dst.dis-card.
define buffer old-dis-obj               for src.dis-obj.
define buffer new-dis-obj               for dst.dis-obj.
define buffer old-dis-host              for src.dis-host.
define buffer new-dis-host              for dst.dis-host.
define buffer old-c-dc-hist             for src.c-dc-hist.
define buffer new-c-dc-hist             for dst.c-dc-hist.
define buffer old-c-dis-card            for src.c-dis-card.
define buffer new-c-dis-card            for dst.c-dis-card.
define buffer old-c-dis-obj             for src.c-dis-obj.
define buffer new-c-dis-obj             for dst.c-dis-obj.
define buffer old-c-dis-host            for src.c-dis-host.
define buffer new-c-dis-host            for dst.c-dis-host.
define buffer old-dis-card-property     for src.dis-card-property.
define buffer new-dis-card-property     for dst.dis-card-property.
define buffer old-c-dis-card-property   for src.c-dis-card-property.
define buffer new-c-dis-card-property   for dst.c-dis-card-property.
define buffer old-dis-card-long         for src.dis-card-long.
define buffer new-dis-card-long         for dst.dis-card-long.
define buffer old-c-dis-card-long       for src.c-dis-card-long.
define buffer new-c-dis-card-long       for dst.c-dis-card-long.
define buffer old-dis-card-long-attr    for src.dis-card-long-attr.
define buffer new-dis-card-long-attr    for dst.dis-card-long-attr.
define buffer old-c-dis-card-long-attr  for src.c-dis-card-long-attr.
define buffer new-c-dis-card-long-attr  for dst.c-dis-card-long-attr.
define buffer old-dis-dc-rule           for src.dis-dc-rule.
define buffer new-dis-dc-rule           for dst.dis-dc-rule.
define buffer old-c-dis-dc-rule         for src.c-dis-dc-rule.
define buffer new-c-dis-dc-rule         for dst.c-dis-dc-rule.
define buffer old-dis-dc-rule-attr      for src.dis-dc-rule-attr.
define buffer new-dis-dc-rule-attr      for dst.dis-dc-rule-attr.
define buffer old-dis-rule              for src.dis-rule.
define buffer new-dis-rule              for dst.dis-rule.
define buffer old-c-dis-rule            for src.c-dis-rule.
define buffer new-c-dis-rule            for dst.c-dis-rule.
define buffer old-dis-rule-attr         for src.dis-rule-attr.
define buffer new-dis-rule-attr         for dst.dis-rule-attr.
define buffer old-c-dis-rule-attr       for src.c-dis-rule-attr.
define buffer new-c-dis-rule-attr       for dst.c-dis-rule-attr.
define buffer old-dis-time-rule         for src.dis-time-rule.
define buffer new-dis-time-rule         for dst.dis-time-rule.
define buffer old-c-dis-time-rule       for src.c-dis-time-rule.
define buffer new-c-dis-time-rule       for dst.c-dis-time-rule.
define buffer old-dis-time-rule-attr    for src.dis-time-rule-attr.
define buffer new-dis-time-rule-attr    for dst.dis-time-rule-attr.
define buffer old-dis-cfg-rule          for src.dis-cfg-rule.
define buffer new-dis-cfg-rule          for dst.dis-cfg-rule.
define buffer old-c-dis-cfg-rule        for src.c-dis-cfg-rule.
define buffer new-c-dis-cfg-rule        for dst.c-dis-cfg-rule.
define buffer old-dis-cfg-rule-attr     for src.dis-cfg-rule-attr.
define buffer new-dis-cfg-rule-attr     for dst.dis-cfg-rule-attr.
define buffer old-drt-prop              for src.drt-prop.
define buffer new-drt-prop              for dst.drt-prop.
define buffer old-c-drt-prop            for src.c-drt-prop.
define buffer new-c-drt-prop            for dst.c-drt-prop.
define buffer old-dis-some-rule         for src.dis-some-rule.
define buffer new-dis-some-rule         for dst.dis-some-rule.
define buffer old-c-dis-some-rule       for src.c-dis-some-rule.
define buffer new-c-dis-some-rule       for dst.c-dis-some-rule.
define buffer old-dis-some-rule-attr    for src.dis-some-rule-attr.
define buffer new-dis-some-rule-attr    for dst.dis-some-rule-attr.
define buffer new-payment               for dst.payment.
define buffer old-payment               for src.payment.
define buffer new-c-payment             for dst.c-payment.
define buffer old-c-payment             for src.c-payment.
define buffer new-payment-attr          for dst.payment-attr.
define buffer old-payment-attr          for src.payment-attr.
define buffer new-c-payment-attr        for dst.c-payment-attr.
define buffer old-c-payment-attr        for src.c-payment-attr.
define buffer new-trn-doc               for dst.trn-doc.
define buffer new-c-trn-doc             for dst.c-trn-doc.
define buffer old-trn-doc               for src.trn-doc.
define buffer old-c-trn-doc             for src.c-trn-doc.
define buffer new-inkas                 for dst.inkas.
define buffer new-c-inkas               for dst.c-inkas.
define buffer old-inkas                 for src.inkas.
define buffer old-c-inkas               for src.c-inkas.
define buffer old-stop-list             for src.stop-list.
define buffer old-c-stop-list           for src.c-stop-list.
define buffer old-stop-list-attr        for src.stop-list-attr.
define buffer old-stop-list-line        for src.stop-list-line.
define buffer old-c-stop-list-line      for src.c-stop-list-line.
define buffer old-stop-list-line-attr   for src.stop-list-line-attr.
define buffer new-stop-list             for dst.stop-list.
define buffer new-c-stop-list           for dst.c-stop-list.
define buffer new-stop-list-attr        for dst.stop-list-attr.
define buffer new-stop-list-line        for dst.stop-list-line.
define buffer new-c-stop-list-line      for dst.c-stop-list-line.
define buffer new-stop-list-line-attr   for dst.stop-list-line-attr.
define buffer new-ord-doc               for dst.ord-doc.
define buffer new-fin-doc               for dst.fin-doc.
define buffer new-c-fin-doc               for dst.c-fin-doc.


define variable v-cash-pay              as integer no-undo .
define variable v-obj-type              as character no-undo .
define variable v-obj-code              as integer no-undo .
define variable v-export                as logical no-undo .

define buffer new-clients  for dst.clients.


do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
on WRITE of dst.dis-card-type        override do: end.
on WRITE of dst.c-dis-card-type      override do: end.
on WRITE of dst.dis-card-type-attr   override do: end.
on WRITE of dst.c-dis-card-type-attr override do: end.
on WRITE of dst.dis-card-mask        override do: end.
on WRITE of dst.c-dis-card-mask      override do: end.
on WRITE of dst.dis-card-mask-attr   override do: end.
on WRITE of dst.c-dis-card-mask-attr override do: end.
on WRITE of dst.dis-dct-rule         override do: end.
on WRITE of dst.c-dis-dct-rule       override do: end.
on WRITE of dst.dis-dct-rule-attr    override do: end.
on WRITE of dst.dis-card             override do: end.
on WRITE of dst.dis-obj              override do: end.
on WRITE of dst.dis-host             override do: end.
on WRITE of dst.c-dc-hist            override do: end.
on WRITE of dst.c-dis-card           override do: end.
on WRITE of dst.c-dis-obj            override do: end.
on WRITE of dst.c-dis-host           override do: end.
on WRITE of dst.dis-card-property    override do: end.
on WRITE of dst.c-dis-card-property  override do: end.
on WRITE of dst.dis-card-long        override do: end.
on WRITE of dst.c-dis-card-long      override do: end.
on WRITE of dst.dis-card-long-attr   override do: end.
on WRITE of dst.c-dis-card-long-attr override do: end.
on WRITE of dst.dis-dc-rule          override do: end.
on WRITE of dst.c-dis-dc-rule        override do: end.
on WRITE of dst.dis-dc-rule-attr     override do: end.
on WRITE of dst.dis-rule             override do: end.
on WRITE of dst.c-dis-rule           override do: end.
on WRITE of dst.dis-rule-attr        override do: end.
on WRITE of dst.c-dis-rule-attr      override do: end.
on WRITE of dst.dis-time-rule        override do: end.
on WRITE of dst.c-dis-time-rule      override do: end.
on WRITE of dst.dis-time-rule-attr   override do: end.
on WRITE of dst.dis-cfg-rule         override do: end.
on WRITE of dst.c-dis-cfg-rule       override do: end.
on WRITE of dst.dis-cfg-rule-attr    override do: end.
on WRITE of dst.drt-prop             override do: end.
on WRITE of dst.c-drt-prop           override do: end.
on WRITE of dst.dis-some-rule        override do: end.
on WRITE of dst.c-dis-some-rule      override do: end.
on WRITE of dst.dis-some-rule-attr   override do: end.

on WRITE of dst.payment              override do: end.
on WRITE of dst.c-payment            override do: end.
on WRITE of dst.payment-attr         override do: end.
on WRITE of dst.c-payment-attr       override do: end.
on WRITE of dst.stop-list            override do: end.
on WRITE of dst.c-stop-list          override do: end.
on WRITE of dst.stop-list-attr       override do: end.
on WRITE of dst.stop-list-line       override do: end.
on WRITE of dst.c-stop-list-line     override do: end.
on WRITE of dst.stop-list-line-attr  override do: end.


{ utl/00000002.i dis-card-type }
{ utl/00000002.i dis-card-type-attr }
{ utl/00000002.i dis-card-mask }
{ utl/00000002.i dis-card-mask-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-card-type }
  { utl/00000002.i c-dis-card-type-attr }
  { utl/00000002.i c-dis-card-mask }
  { utl/00000002.i c-dis-card-mask-attr }
end.
{ utl/00000002.i dis-dct-rule }
{ utl/00000002.i dis-dct-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-dct-rule }
end.
{ utl/00000002.i dis-rule }
if varstay-history then do:
  { utl/00000002.i c-dis-rule }
end.
{ utl/00000002.i dis-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-rule-attr }
end.
{ utl/00000002.i dis-time-rule }
if varstay-history then do:
  { utl/00000002.i c-dis-time-rule }
end.
{ utl/00000002.i dis-time-rule-attr }
{ utl/00000002.i dis-cfg-rule }
{ utl/00000002.i dis-cfg-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-cfg-rule }
end.
{ utl/00000002.i drt-prop }
if varstay-history then do:
  { utl/00000002.i c-drt-prop }
end.
{ utl/00000002.i dis-some-rule }
{ utl/00000002.i dis-some-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-some-rule }
end.
{ utl/00000002.i dis-card }
{ utl/00000002.i dis-obj }
{ utl/00000002.i dis-host }
{ utl/00000002.i dis-card-property }
{ utl/00000002.i dis-card-long }
{ utl/00000002.i dis-card-long-attr }
{ utl/00000002.i dis-dc-rule }
{ utl/00000002.i dis-dc-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-dis-card }
  { utl/00000002.i c-dis-obj }
  { utl/00000002.i c-dis-host }
  { utl/00000002.i c-dc-hist }
  { utl/00000002.i c-dis-card-property }
  { utl/00000002.i c-dis-card-long }
  { utl/00000002.i c-dis-card-long-attr }
  { utl/00000002.i c-dis-dc-rule }
end.



/*раньше была проверка при переносе dis-obj и dis-host на то что есть магазин и фирма в новой БД
проверку выкинула - потому что магазины и свои фирмы мы не обрезаем
*/

/*внимание!!! при переносе в 14.0 надо предусмотреть что dis-obj бывают с d-card begins d-card + {&delim-par} частные итоги */
/*внимание!!! при переносе в 14.0 надо предусмотреть что dis-host бывают с host-code = 0 и d-card begins d-card + {&delim-par} частные итоги */

/*payment.source-type бывает  {&pmnt-cash-desk} {&pmnt-ord-doc} {&pmnt-trn-doc} {&pmnt-fin-doc} */

_payment:
for each old-payment no-lock
break
by old-payment.source-type
by old-payment.source-ref
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  v-export = no.
  if old-payment.d-card = '':u
  or (vardate-actual-docs <> ?
      and old-payment.fact-date >= vardate-actual-docs)
  or not (old-payment.source-type = {&pmnt-trn-doc}
         or
         old-payment.source-type = {&pmnt-cash-desk})
  then do:
    case old-payment.source-type:
      when {&pmnt-fin-doc} then do:
        if old-payment.pmnt-code begins "-" then do:
          find first new-c-fin-doc no-lock where
                    new-c-fin-doc.host-code = old-payment.host-code
                and new-c-fin-doc.fin-doc-code = integer(entry(2, old-payment.source-ref, "-"))
                and new-c-fin-doc.is-del = yes
                no-error.
          if available new-c-fin-doc then do:
            v-export = yes.
          end.
        end.
        else do:
          find first new-fin-doc no-lock where
                    new-fin-doc.host-code = old-payment.host-code
                and new-fin-doc.fin-doc-code = integer(old-payment.source-ref)
                no-error.
          if available new-fin-doc then do:
            v-export = yes.
          end.
        end.
      end. /*when {&pmnt-fin-doc} then do:*/
      when {&pmnt-ord-doc} then do:
        find first new-ord-doc no-lock where
                  new-ord-doc.doc-code = old-payment.source-ref no-error.
        if available new-ord-doc then do:
          v-export = yes.
        end.
      end.
    end case.
    /*копируем*/
    if v-export then do:
      create new-payment.
      buffer-copy old-payment to new-payment.
      next _payment.
    end.
  end.
  else do:
    if old-payment.source-type = {&pmnt-trn-doc} then do:
      find first new-trn-doc no-lock where
                new-trn-doc.doc-code = old-payment.source-ref no-error.
      if not available new-trn-doc then do:
        find first new-c-trn-doc no-lock where
                  new-c-trn-doc.doc-code = old-payment.source-ref no-error.
        if not available new-c-trn-doc then do:
          /*валим в кучу*/
          find first old-trn-doc no-lock where
                    old-trn-doc.doc-code = old-payment.source-ref no-error.
          if not available old-trn-doc then do:
            find first old-c-trn-doc no-lock where
                      old-c-trn-doc.doc-code = old-payment.source-ref no-error.
            if available old-c-inkas then do:
              assign
              v-obj-type = old-c-trn-doc.obj-type
              v-obj-code = old-c-trn-doc.obj-code
              .
            end.
            else do:
              assign
              v-obj-type = {&shop}
              v-obj-code = 0
              .
            end.
          end.
          else do:
            assign
            v-obj-type = old-trn-doc.obj-type
            v-obj-code = old-trn-doc.obj-code
            .
          end.
          run create-sum-record ( buffer old-payment
                                , input v-obj-type
                                , input v-obj-code
                                ).
        end. /*if not available new-c-trn-doc then do:*/
      end. /*if not available new-trn-doc then do:*/
      else do:
        /*копируем*/
        create new-payment.
        buffer-copy old-payment to new-payment.
      end.
    end.
    if old-payment.source-type = {&pmnt-cash-desk} then do:
      find first new-inkas no-lock where
                new-inkas.inkas-code = old-payment.source-ref no-error.
      if not available new-inkas then do:
        find first new-c-inkas no-lock where
                  new-c-inkas.inkas-code = old-payment.source-ref no-error.
        if not available new-c-inkas then do:
          /*валим в кучу*/
          find first old-inkas no-lock where
                    old-inkas.inkas-code = old-payment.source-ref no-error.
          if not available old-inkas then do:
            find first old-c-inkas no-lock where
                      old-c-inkas.inkas-code = old-payment.source-ref no-error.
            if available old-c-inkas then do:
              assign
              v-obj-type = old-c-inkas.obj-type
              v-obj-code = old-c-inkas.obj-code
              .
            end.
            else do:
              assign
              v-obj-type = {&shop}
              v-obj-code = 0
              .
            end.
          end.
          else do:
            assign
            v-obj-type = old-inkas.obj-type
            v-obj-code = old-inkas.obj-code
            .
          end.
          run create-sum-record ( buffer old-payment
                                , input v-obj-type
                                , input v-obj-code
                                ).
        end. /*if not available new-c-inkas then do:*/
      end. /*if not available new-inkas then do:*/
      else do:
        /*копируем*/
        create new-payment.
        buffer-copy old-payment to new-payment.
      end.
    end.
  end.
end.
for each old-payment-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first new-payment no-lock where new-payment.pmnt-code = old-payment-attr.pmnt-code no-error.
  if available new-payment then do:
    create new-payment-attr.
    buffer-copy old-payment-attr to new-payment-attr.
  end.
end.
for each old-c-payment no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first new-payment no-lock where new-payment.pmnt-code = old-c-payment.pmnt-code no-error.
  if available new-payment then do:
    create new-c-payment.
    buffer-copy old-c-payment to new-payment.
  end.
end.
for each old-c-payment-attr no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first new-payment no-lock where new-payment.pmnt-code = old-c-payment-attr.pmnt-code no-error.
  if available new-payment then do:
    create new-c-payment-attr.
    buffer-copy old-c-payment-attr to new-payment-attr.
  end.
end.

for each old-stop-list no-lock
where old-stop-list.status_ = {&fact}
  and (vardate-actual-docs = ? or old-stop-list.fact-date >= vardate-actual-docs)
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
 create new-stop-list.
 buffer-copy old-stop-list to new-stop-list.
 for each old-stop-list-line no-lock where
        old-stop-list-line.classif-type = old-stop-list.classif-type
    and old-stop-list-line.stop-list-code = old-stop-list.stop-list-code
     on error undo, return error:
   create new-stop-list-line.
   buffer-copy old-stop-list-line to new-stop-list-line.
 end.
 for each old-stop-list-line-attr no-lock where
        old-stop-list-line-attr.classif-type = old-stop-list.classif-type
    and old-stop-list-line-attr.stop-list-code = old-stop-list.stop-list-code
     on error undo, return error:
   create new-stop-list-line-attr.
   buffer-copy old-stop-list-line-attr to new-stop-list-line-attr.
 end.
 if varstay-history then do:
  for each old-c-stop-list no-lock where
          old-c-stop-list.classif-type = old-stop-list.classif-type
      and old-c-stop-list.stop-list-code = old-stop-list.stop-list-code
      on error undo, return error:
    create new-c-stop-list.
    buffer-copy old-c-stop-list to new-c-stop-list.
  end.
  for each old-c-stop-list-line no-lock where
          old-c-stop-list-line.classif-type = old-stop-list.classif-type
      and old-c-stop-list-line.stop-list-code = old-stop-list.stop-list-code
      on error undo, return error:
    create new-c-stop-list-line.
    buffer-copy old-c-stop-list-line to new-c-stop-list-line.
  end.
 end.
 for each old-stop-list-attr no-lock where
        old-stop-list-attr.classif-type = old-stop-list.classif-type
    and old-stop-list-attr.stop-list-code = old-stop-list.stop-list-code
     on error undo, return error:
   create new-stop-list-attr.
   buffer-copy old-stop-list-attr to new-stop-list-attr.
 end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: dis-card-type c-dis-card-type dis-card-mask c-dis-card-mask dis-dct-rule dis-dct-rule-attr c-dis-dct-rule ~
dis-rule c-dis-rule dis-rule-attr c-dis-rule-attr dis-time-rule c-dis-time-rule dis-time-rule-attr ~
dis-cfg-rule dis-cfg-rule-attr c-dis-cfg-rule drt-prop c-drt-prop  dis-some-rule dis-some-rule-attr c-dis-some-rule ~
dis-card c-dc-hist c-dis-card  dis-obj c-dis-obj dis-host c-dis-dis-host dis-card-type-property c-dis-card-type-property ~
dis-card-long c-dis-card-long dis-card-long-attr c-dis-card-long-attr dis-dc-rule c-dis-dc-rule dis-dc-rule-attr ~
payment c-payment payment-attr c-payment-attr ~
stop-list c-stop-list stop-list-line stop-list-line-attr c-stop-list-line stop-list-attr .".
end.

procedure create-sum-record :
define parameter buffer old-payment for src.payment.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .

define variable v-source-ref as character no-undo .
define buffer new-payment for dst.payment.

  do
  on error undo, return error return-value
  :
     v-source-ref = substitute('&1&2-&3-&4'
                              , p-obj-type
                              , p-obj-code
                              , string(vardate-actual-docs, '99/99/9999')
                              , old-payment.pay-code
                              ).
     find first new-payment where
              new-payment.host-code = old-payment.host-code
          and new-payment.d-card = old-payment.d-card
          and new-payment.source-type = old-payment.source-type
          and new-payment.source-ref = v-source-ref
          and new-payment.status_ = {&fact}
          and new-payment.fact-date = vardate-actual-docs
          no-error.
     if not available new-payment then do:
       create new-payment.
       buffer-copy old-payment
       except source-ref fact-date exch-date
       to new-payment
       assign
       new-payment.source-ref = v-source-ref
       new-payment.fact-date = vardate-actual-docs
       new-payment.exch-date = vardate-actual-docs
       .

     end.
     else do:
      assign
      new-payment.tot-base = new-payment.tot-base + old-payment.tot-base
      new-payment.tot-cli  = new-payment.tot-cli  + old-payment.tot-cli
      new-payment.tot-rubl = new-payment.tot-rubl + old-payment.tot-rubl
      .
     end.
  end.

end procedure. /* create-sum-record */