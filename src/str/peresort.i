/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание программы

Автор: Чернова Светлана Александровна
Дата создания: 09/12/07
Author: Svetlana Chernova
Creation date: 09/12/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 05/12/06


*/

define temp-table tt-gds-dtl no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.

define temp-table tt-gds-dtl-plus no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.

define temp-table tt-pl-qty no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.

define temp-table tt-pl-qty-plus no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field rsrv-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.