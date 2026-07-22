/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/21/06
Author: Svetlana Chernova
Creation date: 03/21/06

*/
define temp-table locb-ord-line-rcv    no-undo like ub.ord-line-rcv.
define temp-table locb-ord-dtl-rcv     no-undo like ub.ord-dtl-rcv.
define temp-table rcvlocb-ord-line     no-undo like ub.ord-line.
define temp-table rcvlocb-ord-dtl      no-undo like ub.ord-dtl.
define temp-table rcvlocb-ord-doc      no-undo like ub.ord-doc.


define temp-table locb-ord-rcv-attr         no-undo like ub.ord-rcv-attr.
define temp-table locb-ord-rcv-line-attr    no-undo like ub.ord-rcv-line-attr.
define temp-table rcvlocb-ord-line-attr     no-undo like ub.ord-line-attr.
define temp-table rcvlocb-ord-doc-attr      no-undo like ub.ord-doc-attr.