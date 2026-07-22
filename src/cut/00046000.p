block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00046000.p $
$Archive: cut/00046000.p $

Файл пирога обрезания. Относится к категории 46.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:

 c-trn-doc
 c-doc-line
 c-gds-dtl
 c-doc-line-attr
 c-doc-pl
 c-doc-pl-pump
 c-inkas
 c-sale-doc
 c-inkas-pay
 c-inkas-pay-desk
 c-inkas-pay-wth
 c-doc-prts
 c-parts
 c-parts-root
 c-parts-attr - решили не трогать.

*/


define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00046000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00046000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 46.".
{ cmp/str-glbl.i }
define buffer old-c-trn-doc   for src.c-trn-doc.
define buffer new-c-trn-doc   for dst.c-trn-doc.
define buffer old-c-doc-line  for src.c-doc-line.
define buffer new-c-doc-line  for dst.c-doc-line.
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define buffer old-c-doc-line-attr  for src.c-doc-line-attr.
define buffer new-c-doc-line-attr  for dst.c-doc-line-attr.
define buffer old-c-gds-dtl  for src.c-gds-dtl.
define buffer new-c-gds-dtl  for dst.c-gds-dtl.
define buffer old-c-gds-dtl-attr  for src.c-gds-dtl-attr.
define buffer new-c-gds-dtl-attr  for dst.c-gds-dtl-attr.


define buffer old-c-doc-pl        for src.c-doc-pl.
define buffer new-c-doc-pl        for dst.c-doc-pl.
define buffer old-c-doc-pl-pump   for src.c-doc-pl-pump.
define buffer new-c-doc-pl-pump   for dst.c-doc-pl-pump.
define buffer new-pump            for dst.pump.
define buffer new-place           for dst.place.

define buffer old-c-inkas          for src.c-inkas          .
define buffer new-c-inkas          for dst.c-inkas          .
define buffer old-c-sale-doc       for src.c-sale-doc       .
define buffer new-c-sale-doc       for dst.c-sale-doc       .
define buffer old-c-inkas-pay      for src.c-inkas-pay      .
define buffer new-c-inkas-pay      for dst.c-inkas-pay      .
define buffer old-c-inkas-pay-desk for src.c-inkas-pay-desk .
define buffer new-c-inkas-pay-desk for dst.c-inkas-pay-desk .
define buffer old-c-inkas-pay-wth  for src.c-inkas-pay-wth  .
define buffer new-c-inkas-pay-wth  for dst.c-inkas-pay-wth  .
define buffer old-c-doc-prts       for src.c-doc-prts       .
define buffer new-c-doc-prts       for dst.c-doc-prts       .
define buffer old-c-parts          for src.c-parts          .
define buffer new-c-parts          for dst.c-parts          .
define buffer old-c-parts-root     for src.c-parts-root          .
define buffer new-c-parts-root     for dst.c-parts-root          .



do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ utl/tt-objs.i  }
on WRITE of dst.c-trn-doc         override do: end.
on WRITE of dst.c-doc-line        override do: end.
on WRITE of dst.c-gds-dtl         override do: end.
on WRITE of dst.c-gds-dtl-attr         override do: end.
on WRITE of dst.c-doc-line-attr   override do: end.
on WRITE of dst.c-doc-pl          override do: end.
on WRITE of dst.c-doc-pl-pump     override do: end.
on write of dst.c-inkas           override do: end.
on write of dst.c-sale-doc        override do: end.
on write of dst.c-inkas-pay       override do: end.
on write of dst.c-inkas-pay-desk  override do: end.
on write of dst.c-inkas-pay-wth   override do: end.
on write of dst.c-doc-prts        override do: end.
on write of dst.c-parts           override do: end.
on write of dst.c-parts-root      override do: end.

if not varstay-history  then return .

define variable my-fact-order as decimal   no-undo .
run day-begin-fact-order (input vardate-actual-docs , output my-fact-order) .

if vardate-actual-docs <> ? then do:
   for each new-shop no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = {&shop}           and
                                 tt-objs.obj-code = new-shop.obj-code no-error.
      end.
      if vartype-cut = 0      or
         (vartype-cut = 1 and available tt-objs) then do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = {&shop}           and
                 old-c-trn-doc.obj-code                       = new-shop.obj-code and
                 old-c-trn-doc.status_                        = {&fact}           and
                 old-c-trn-doc.fact-order                    >= my-fact-order
                 no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
      else do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = {&shop}           and
                 old-c-trn-doc.obj-code                       = new-shop.obj-code and
                 old-c-trn-doc.status_                        = {&fact}           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
   end.
   for each new-store no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = {&stock}           and
                                 tt-objs.obj-code = new-store.obj-code no-error.
      end.
      if vartype-cut = 0      or
         (vartype-cut = 1 and available tt-objs) then do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = {&stock}   and
                 old-c-trn-doc.obj-code   = new-store.obj-code            and
                 old-c-trn-doc.status_    = {&fact}                       and
                 old-c-trn-doc.fact-order >= my-fact-order                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
      else do:
        for each old-c-trn-doc where old-c-trn-doc.obj-type   = {&stock}  and
                 old-c-trn-doc.obj-code   = new-store.obj-code            and
                 old-c-trn-doc.status_    = {&fact}                       no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
           run proc-bod .
        end.
      end.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц:  c-trn-doc c-doc-line c-gds-dtl c-doc-line-attr c-doc-pl c-doc-pl-pump c-inkas c-sale-doc " +
"c-inkas-pay c-inkas-pay-desk c-inkas-pay-wth c-doc-prts  c-parts  c-parts-root".
end.

procedure proc-bod :

  do
  on error undo, return error return-value
  :


  for each old-c-doc-line where
           old-c-doc-line.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-doc-line.
          buffer-copy old-c-doc-line to new-c-doc-line.
  end.

  for each old-c-doc-line-attr where
           old-c-doc-line-attr.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-doc-line-attr.
          buffer-copy old-c-doc-line-attr to new-c-doc-line-attr.
  end.

  for each old-c-gds-dtl where
           old-c-gds-dtl.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-gds-dtl.
          buffer-copy old-c-gds-dtl to new-c-gds-dtl.
  end.

  for each old-c-gds-dtl-attr where
           old-c-gds-dtl-attr.doc-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
          create new-c-gds-dtl-attr.
          buffer-copy old-c-gds-dtl-attr to new-c-gds-dtl-attr.
  end.


  for each new-place
       no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
       :
       for each old-c-doc-pl where
           old-c-doc-pl.obj-code = new-place.obj-code and
           old-c-doc-pl.obj-type = new-place.obj-type and
           old-c-doc-pl.pl-code  = new-place.pl-code  and
           old-c-doc-pl.out-code = old-c-trn-doc.doc-code
           no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
           :
              create new-c-doc-pl .
              buffer-copy old-c-doc-pl to new-c-doc-pl .
       end.
       for each new-pump where
                new-pump.obj-code = new-place.obj-code and
                new-pump.obj-type = new-place.obj-type
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :
          for each old-c-doc-pl-pump where
              old-c-doc-pl-pump.obj-code   = new-place.obj-code and
              old-c-doc-pl-pump.obj-type   = new-place.obj-type and
              old-c-doc-pl-pump.pl-code    = new-place.pl-code  and
              old-c-doc-pl-pump.pump-code  = new-pump.pump-code  and
              old-c-doc-pl-pump.out-code   = old-c-trn-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
              :
                  create new-c-doc-pl-pump .
                  buffer-copy old-c-doc-pl-pump to new-c-doc-pl-pump .
          end.
       end.
  end.

    for each old-c-doc-prts where
        old-c-doc-prts.out-code = old-c-trn-doc.doc-code
        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          create new-c-doc-prts .
          buffer-copy old-c-doc-prts to new-c-doc-prts .
    end.

    for each old-c-parts where
        old-c-parts.out-code = old-c-trn-doc.doc-code
        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
          create new-c-parts .
          buffer-copy old-c-parts to new-c-parts .

    end.

      for each old-c-parts-root no-lock  where
          old-c-parts-root.doc-code = old-c-trn-doc.doc-code
          on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
          :
          create new-c-parts-root.
          BUFFER-COPY old-c-parts-root to new-c-parts-root.
      end.

      /*код отчета о продаже равен номер расходной накладной через кассу*/
      if old-c-trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then do:
            for each old-c-inkas
              where old-c-inkas.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas.
                buffer-copy old-c-inkas to new-c-inkas.
            end.
            for each old-c-sale-doc
              where old-c-sale-doc.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-sale-doc.
                buffer-copy old-c-sale-doc to new-c-sale-doc.
            end.
            for each old-c-inkas-pay
              where old-c-inkas-pay.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay.
                buffer-copy old-c-inkas-pay to new-c-inkas-pay.
            end.
            for each old-c-inkas-pay-wth
              where old-c-inkas-pay-wth.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay-wth.
                buffer-copy old-c-inkas-pay-wth to new-c-inkas-pay.
            end.
            for each old-c-inkas-pay-desk
              where old-c-inkas-pay-desk.inkas-code = old-c-trn-doc.doc-code no-lock
            on error undo, return error
            :
                create new-c-inkas-pay-desk.
                buffer-copy old-c-inkas-pay-desk to new-c-inkas-pay-desk.
            end.
      end.


  create new-c-trn-doc.
  buffer-copy old-c-trn-doc to new-c-trn-doc.

  end.

end procedure. /* proc-bod */