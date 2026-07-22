/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы, в которой будем держать всю нужную информацию по скидкам, лист 10

Автор: Белоусов Илья Александрович
Дата создания: 12/17/07
Author: Ilia Belousov
Creation date: 12/17/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define {1} temp-table t-10 no-undo
field gds-code       like ub.goods.gds-code
field b-code       like ub.bar-code.b-code

field gds-name       like ub.goods.gds-name


field qnty       as decimal INITIAL 0
field delta          as decimal INITIAL 0
field pay-code   like ub.cash-pay.cdpay-code
field pay-name as char
field discnt-type like ub.chk-discnt.discnt-type
field discnt-name as char
field sum-netto   as decimal INITIAL 0
field sum-brutto  as decimal INITIAL 0
field discount-sum     as decimal INITIAL 0


index pi is unique primary
  gds-code
  pay-code
  discnt-type
.

/* $Workfile$ e n d */