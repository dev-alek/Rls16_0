/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временных таблиц (бывший  r w d o c s u m . i)

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create: Булгаков Андрей Николаевич

*/

define temp-table tt-doc-line-sum     no-undo like ub.doc-line-sum.
define temp-table tt-old-doc-line-sum no-undo like tt-doc-line-sum.
define temp-table tt-wast-line        no-undo
  field obj-type            like ub.doc-line.obj-type
  field obj-code            like ub.doc-line.obj-code
  field status_             like ub.doc-line.status_
  field artic               like ub.doc-line.artic
  field prod-type           like ub.doc-line.prod-type
  field prod-code           like ub.doc-line.prod-code
  field fact-order          like ub.doc-line.fact-order
  field prev-inv-fact-order like ub.doc-line.fact-order
  index prev-inv-fact-order      prev-inv-fact-order.

/* $Workfile$   E n d */
