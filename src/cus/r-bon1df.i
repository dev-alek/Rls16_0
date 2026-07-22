/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для отчета Начисление и списание бонусов -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/06
Author: Bakhtadze Natalya
Creation date: 09/21/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-bon1 no-undo
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field gds-code like ub.goods.gds-code
field chk-date like ub.chk-doc.chk-date
field chk-time like ub.chk-doc.chk-time
field doc-code like ub.chk-doc.doc-code
field line-num like ub.chk-discnt.line-num
field discnt-id like ub.chk-discnt.discnt-id
field object-line-num like ub.chk-discnt.object-line-num
field shift-date like ub.chk-doc.shift-date
field shift-num like ub.chk-doc.shift-num
field shift-name as character
field d-card like ub.chk-discnt.d-card
field op-code as integer  /*1 начисление -1 списание*/
field src-qnty like ub.chk-discnt.object-qnty init 0
field src-price like ub.chk-gds.src-price
field src-sum  like ub.chk-discnt.object-sum /*брутто*/
field pay-sum  like ub.chk-discnt.object-sum /*нетто*/
field discnt-value-abs like ub.chk-discnt.discnt-value-abs
field cashier-psn-code like ub.chk-doc.cashier-psn-code
field item-type as integer /*1 товар 2 топливо */
field item-name as character /* для товара "Соп. Товары" для топлива название топлива */
field level as integer
index pi is unique primary
doc-code
line-num
discnt-id
object-line-num
index imain
obj-type
obj-code
item-type
item-name
op-code
chk-date
chk-time
index imain2
obj-type
obj-code
chk-date
chk-time
index ilevel
level
.

define temp-table temp-bon1-shft no-undo
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field shift-date like ub.chk-doc.shift-date
field shift-num like ub.chk-doc.shift-num
field shift-name as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.

define temp-table temp-bon1-cashier no-undo
field cashier-psn-code like ub.person.psn-code
field obj-name like ub.clients.obj-name
index pi is unique primary
cashier-psn-code
.

define {1} temp-table temp-bon1-gds no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
index pi is unique primary
gds-code
.

/* $Workfile$   E n d */