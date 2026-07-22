block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00230000.p $
$Archive: cut/00230000.p $

Файл пирога обрезания. Относится к категории 230.

Автор: Чернова Светлана Александровна
Дата создания: 06/01/09
Author: Svetlana Chernova
Creation date: 06/01/09

Обработка таблиц:

add-doc
add-line
add-trn
add-trn-attr
gds-add-charges
gds-add-charges-attr
parts-add-attr
parts-add
c-parts-add
c-add-doc
c-add-line


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00230000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00230000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 230.".
{ cmp/str-glbl.i }

define buffer old-add-doc                for src.add-doc                  .
define buffer old-add-line               for src.add-line                 .
define buffer old-add-trn                for src.add-trn                  .
define buffer old-add-trn-attr           for src.add-trn-attr             .
define buffer old-gds-add-charges        for src.gds-add-charges          .
define buffer old-gds-add-charges-attr   for src.gds-add-charges-attr     .
define buffer old-parts-add-attr         for src.parts-add-attr           .
define buffer old-parts-add              for src.parts-add                .
define buffer old-c-parts-add            for src.c-parts-add              .
define buffer old-c-add-doc              for src.c-add-doc                .
define buffer old-c-add-line             for src.c-add-line               .

define buffer new-add-doc               for dst.add-doc                .
define buffer new-add-line              for dst.add-line               .
define buffer new-add-trn               for dst.add-trn                .
define buffer new-add-trn-attr          for dst.add-trn-attr           .
define buffer new-gds-add-charges       for dst.gds-add-charges        .
define buffer new-gds-add-charges-attr  for dst.gds-add-charges-attr   .
define buffer new-parts-add-attr        for dst.parts-add-attr         .
define buffer new-parts-add             for dst.parts-add              .
define buffer new-c-parts-add           for dst.c-parts-add            .
define buffer new-c-add-doc             for dst.c-add-doc              .
define buffer new-c-add-line            for dst.c-add-line             .
define buffer new-goods for dst.goods  .

define buffer buf_clients     for dst.clients.

do
on error undo, return error
:
  { utl/00000001.i }
  { utl/tt-objs.i  }

  on WRITE of dst.add-doc               override do: end.
  on WRITE of dst.add-line              override do: end.
  on WRITE of dst.add-trn               override do: end.
  on WRITE of dst.add-trn-attr          override do: end.
  on WRITE of dst.gds-add-charges       override do: end.
  on WRITE of dst.gds-add-charges-attr  override do: end.
  on WRITE of dst.parts-add-attr        override do: end.
  on WRITE of dst.parts-add             override do: end.
  on WRITE of dst.c-parts-add           override do: end.
  on WRITE of dst.c-add-doc             override do: end.
  on WRITE of dst.c-add-line            override do: end.


{ utl/00000002.i gds-add-charges      " no-lock , first new-goods where new-goods.gds-code = old-gds-add-charges.gds-code "  }
{ utl/00000002.i gds-add-charges-attr " no-lock , first new-goods where new-goods.gds-code = old-gds-add-charges-attr.gds-code "  }
{ utl/00000002.i parts-add            " no-lock , first new-goods where new-goods.gds-code = old-parts-add.gds-code " }
{ utl/00000002.i parts-add-attr       " no-lock , first new-goods where new-goods.gds-code = old-parts-add-attr.gds-code " }



if vardate-actual-docs <> ? then do:

    for each buf_clients no-lock  where
             buf_clients.db-num <> ?
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :

      if vartype-cut = 1 then do:
          find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                   tt-objs.obj-code = buf_clients.obj-code no-error.
      end.

      if vartype-cut = 0      or
          (vartype-cut = 1 and available tt-objs) then do:
        if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
          for each old-add-doc where old-add-doc.obj-type   = buf_clients.obj-type             and
                    old-add-doc.obj-code   = buf_clients.obj-CODE and
                    old-add-doc.status_    = {&act-overvalue}         and
                    old-add-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy ( old-add-doc.doc-code ) no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
            for each old-add-doc where
                     old-add-doc.obj-type   = buf_clients.obj-type             and
                     old-add-doc.obj-code   = buf_clients.obj-CODE  and
                     old-add-doc.status_    = {&act-overvalue}
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy ( old-add-doc.doc-code ) no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
        add-doc add-line add-trn add-trn-attr gds-add-charges gds-add-charges-attr parts-add-attr parts-add c-parts-add c-add-doc c-add-line ".

end.


procedure proc-copy :
define input  parameter p-doc-code as character no-undo .

  do
  on error undo, return error return-value
  :

  { utl/00000002.i add-doc              " where old-add-doc.doc-code = p-doc-code " }
  { utl/00000002.i add-line             " where old-add-line.doc-code = p-doc-code " }
  { utl/00000002.i add-trn              " where old-add-trn.doc-code = p-doc-code " }
  { utl/00000002.i add-trn-attr         " where old-add-trn-attr.doc-code = p-doc-code " }
  if varstay-history = yes then do:
  { utl/00000002.i c-add-doc            " where old-c-add-doc.doc-code = p-doc-code " }
  { utl/00000002.i c-add-line           " where old-c-add-line.doc-code = p-doc-code " }
  end.

end.

end procedure. /* proc-copy */