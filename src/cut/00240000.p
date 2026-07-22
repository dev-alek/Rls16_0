block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00240000.p $
$Archive: cut/00240000.p $

Файл пирога обрезания. Относится к категории 240.

Автор: Чернова Светлана Александровна
Дата создания: 06/01/09
Author: Svetlana Chernova
Creation date: 06/01/09

Обработка таблиц:


factur-connect
factur-connect-attr
factur-connect-line
factur-connect-line-attr

schet-fact-doc
schet-fact-doc-attr
schet-fact-line
schet-fact-line-attr

c-schet-fact-doc
c-schet-fact-line


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00240000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00240000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 240.".
{ cmp/str-glbl.i }

define buffer old-schet-fact-doc                for src.schet-fact-doc                  .
define buffer old-schet-fact-line               for src.schet-fact-line                 .
define buffer old-schet-fact-doc-attr           for src.schet-fact-doc-attr             .
define buffer old-schet-fact-line-attr          for src.schet-fact-line-attr            .

define buffer old-factur-connect                for src.factur-connect                  .
define buffer old-factur-connect-attr           for src.factur-connect-attr             .
define buffer old-factur-connect-line        for src.factur-connect-line          .
define buffer old-factur-connect-line-attr   for src.factur-connect-line-attr     .
define buffer old-c-schet-fact-doc             for src.c-schet-fact-doc              .
define buffer old-c-schet-fact-line            for src.c-schet-fact-line             .


define buffer new-schet-fact-doc               for dst.schet-fact-doc                .
define buffer new-schet-fact-line              for dst.schet-fact-line               .
define buffer new-schet-fact-doc-attr          for dst.schet-fact-doc-attr              .
define buffer new-schet-fact-line-attr         for dst.schet-fact-line-attr               .

define buffer new-factur-connect               for dst.factur-connect                .
define buffer new-factur-connect-attr          for dst.factur-connect-attr           .
define buffer new-factur-connect-line       for dst.factur-connect-line        .
define buffer new-factur-connect-line-attr  for dst.factur-connect-line-attr   .
define buffer new-c-schet-fact-doc             for dst.c-schet-fact-doc              .
define buffer new-c-schet-fact-line            for dst.c-schet-fact-line             .
define buffer new-goods for dst.goods  .

define buffer buf_clients     for dst.clients.

do
on error undo, return error
:
  { utl/00000001.i }
  { utl/tt-objs.i  }

  on WRITE of dst.schet-fact-doc               override do: end.
  on WRITE of dst.schet-fact-line              override do: end.
  on WRITE of dst.factur-connect               override do: end.
  on WRITE of dst.factur-connect-attr          override do: end.
  on WRITE of dst.factur-connect-line          override do: end.
  on WRITE of dst.factur-connect-line-attr     override do: end.
  on WRITE of dst.c-schet-fact-doc             override do: end.
  on WRITE of dst.c-schet-fact-line            override do: end.

  { utl/00000002.i factur-connect           }
  { utl/00000002.i factur-connect-attr      }
  { utl/00000002.i factur-connect-line      }
  { utl/00000002.i factur-connect-line-attr }


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
          for each old-schet-fact-doc where old-schet-fact-doc.obj-type   = buf_clients.obj-type             and
                    old-schet-fact-doc.obj-code   = buf_clients.obj-CODE and
                    old-schet-fact-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy ( old-schet-fact-doc.doc-code , old-schet-fact-doc.db-num ) no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
            for each old-schet-fact-doc where
                     old-schet-fact-doc.obj-type   = buf_clients.obj-type             and
                     old-schet-fact-doc.obj-code   = buf_clients.obj-CODE
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy ( old-schet-fact-doc.doc-code , old-schet-fact-doc.db-num) no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
        schet-fact-doc schet-fact-line factur-connect factur-connect-attr factur-connect-line factur-connect-line-attr c-schet-fact-doc c-schet-fact-line ".

end.


procedure proc-copy :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-db-num  as integer   no-undo .

  do
  on error undo, return error return-value
  :
  { utl/00000002.i schet-fact-doc       " where old-schet-fact-doc.doc-code       = p-doc-code and old-schet-fact-doc.db-num       = p-db-num " }
  { utl/00000002.i schet-fact-doc-attr  " where old-schet-fact-doc-attr.doc-code  = p-doc-code and old-schet-fact-doc-attr.db-num  = p-db-num " }
  { utl/00000002.i schet-fact-line      " where old-schet-fact-line.doc-code      = p-doc-code and old-schet-fact-line.db-num      = p-db-num " }
  { utl/00000002.i schet-fact-line-attr " where old-schet-fact-line-attr.doc-code = p-doc-code and old-schet-fact-line-attr.db-num = p-db-num " }


for each old-factur-connect  where
         old-factur-connect.factur-doc-code = p-doc-code and
         old-factur-connect.db-num      = p-db-num  no-lock on error undo,
         return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect.
   buffer-copy old-factur-connect to new-factur-connect.

      for each old-factur-connect-attr  where
               old-factur-connect-attr.connect-code = old-factur-connect.connect-code and
               old-factur-connect-attr.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-attr.
        buffer-copy old-factur-connect-attr to new-factur-connect-attr.
      end.
      for each old-factur-connect-line  where
               old-factur-connect-line.connect-code = old-factur-connect.connect-code and
               old-factur-connect-line.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-line.
        buffer-copy old-factur-connect-line to new-factur-connect-line.
      end.

      for each old-factur-connect-line-attr  where
               old-factur-connect-line-attr.connect-code = old-factur-connect.connect-code and
               old-factur-connect-line-attr.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-line-attr.
        buffer-copy old-factur-connect-line-attr to new-factur-connect-line-attr.
      end.
end.



  if varstay-history = yes then do:
      { utl/00000002.i c-schet-fact-doc     " where old-c-schet-fact-doc.doc-code = p-doc-code " }
      { utl/00000002.i c-schet-fact-line    " where old-c-schet-fact-line.doc-code = p-doc-code " }
  end.
end.

end procedure. /* proc-copy */