/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы, в которой будем держать всю нужную информацию по переливам, лист 9

Автор: Белоусов Илья Александрович
Дата создания: 12/17/07
Author: Ilia Belousov
Creation date: 12/17/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define {1} temp-table t-9 no-undo
field gds-code       like ub.goods.gds-code
field gds-name       like ub.goods.gds-name
field pump-code      like ub.rvs-line-pump.pump-code
field nozzle-code    like ub.icnt-line.nozzle-code

field start-mh-qnty  like ub.rvs-line-pump.meas-mh-cnt
field end-mh-qnty    like ub.rvs-line-pump.meas-mh-cnt
field meas-qnty      like ub.rvs-line-pump.meas-mh-cnt
field prev-start-mh-qnty like ub.rvs-line-pump.meas-mh-cnt

field start-el-qnty  like ub.rvs-line-pump.meas-el-cnt
field end-el-qnty    like ub.rvs-line-pump.meas-el-cnt
field prev-start-el-qnty like ub.rvs-line-pump.meas-el-cnt


field doc-qnty       as decimal INITIAL 0
field delta          as decimal INITIAL 0

field cancell-qnty      as decimal INITIAL 0
field cancell-qnty-notot as decimal INITIAL 0
field overflow-qnty     as decimal INITIAL 0
field trans-qnty        as decimal INITIAL 0
field tech-refuell-qnty as decimal INITIAL 0

index pi is unique primary
  gds-code
  pump-code
  nozzle-code
.

/* $Workfile$ e n d */