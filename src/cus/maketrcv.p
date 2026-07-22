block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: maketrcv.p $
$Archive: cus/maketrcv.p $

вычленение темпов продаж из заказа ФП по Объектам

Автор: Чернова Светлана Александровна
Дата создания: 06/06/06
Author: Svetlana Chernova
Creation date: 06/06/06

m a k e - r c v . p  - головная процедура

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: maketrcv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/maketrcv.p $":U .
define variable vss-description as character no-undo init "вычленение темпов продаж из заказа ФП по Объектам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cus/df-ex-za.i }

define input parameter table for export-ras .

define shared temp-table tt-obj-gds no-undo
field obj-type  like ub.clients.obj-type
field obj-code  like ub.clients.obj-code
field artic     like ub.ord-line.artic
field prod-type like ub.ord-line.prod-type
field prod-code like ub.ord-line.prod-code
field t-temp    as decimal
index pi obj-type
         obj-code
         artic
         prod-type
         prod-code
         .

empty temp-table tt-obj-gds .
for each export-ras where export-ras.temp-rash <> 0 :
    create  tt-obj-gds .
    buffer-copy export-ras  to tt-obj-gds
    assign
       tt-obj-gds.t-temp = export-ras.temp-rash
    .
    /* message tt-obj-gds.t-temp . */
end.