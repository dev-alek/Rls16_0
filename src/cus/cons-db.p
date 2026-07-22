block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cons-db.p $
$Archive: cus/cons-db.p $

Список номеров БД по СЗФП

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/12/02 5:52

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cons-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/cons-db.p $":U .
define variable vss-description as character no-undo init "Список номеров БД по СЗФП    ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
define input parameter p-doc like ub.ord-cons.cons-code no-undo .
define output parameter p-db as character no-undo .

define buffer buf_ord-cons for ub.ord-cons.
define buffer buf_ord-doc for  ub.ord-doc.
define buffer buf_ord-line for  ub.ord-line.
main-block :
do on error undo main-block, return error
:
find first buf_ord-cons no-lock where  buf_ord-cons.cons-code  = p-doc no-error .

    for each   buf_ord-doc no-lock where buf_ord-doc.cons-code = buf_ord-cons.cons-code and
                                         buf_ord-doc.doc-type = {&o-f} ,
        first ub.clients  no-lock where  ub.clients.obj-type = buf_ord-doc.obj-type and
                                      ub.clients.obj-code = buf_ord-doc.obj-code and
                                      ub.clients.db-num <> g#db-num
                                      break by ub.clients.db-num  :
           if first-of(ub.clients.db-num) then do:
              if first (ub.clients.db-num) then do:
                  p-db = string(ub.clients.db-num) .
              end.
              else
                  p-db = p-db + {&delim-nws} + string(ub.clients.db-num) .
         end.

    end.
end.
/* $Workfile: cons-db.p $ e n d */