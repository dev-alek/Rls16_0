/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы, в которой будем держать всю нужную информацию по счетчикам ТРК (сменный отчет лист 7)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

define {1} temp-table t-7 no-undo
field pump-code like ub.icnt-line.pump-code
field nozzle-code like ub.icnt-line.nozzle-code
field gds-code  like ub.goods.gds-code
field fact-order  like ub.icnt-doc.fact-order
field gds-name  like ub.goods.gds-name
field state-el-cnt like ub.icnt-line.state-el-cnt
field state-mh-cnt like ub.icnt-line.state-mh-cnt
index pi is unique primary
  pump-code
  nozzle-code
  gds-code
  fact-order
.


/* $Workfile$ e n d */