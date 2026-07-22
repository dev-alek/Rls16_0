/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение процедура для рождения записей в таблице treal-2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

ЮКОС лист 2
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE create-{1}.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
&if "{2}" = "bge" &then
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
&if "{3}" = "pump" &then
define input parameter p-pump as integer no-undo .
&endif
&if "{3}" = "pump-nozzle" &then
define input parameter p-pump as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
&endif

&endif


_main:
DO ON ERROR UNDO _main, return error:
    create {1}.
    assign
    {1}.gds-code = pgds-code
    {1}.cpay-code = pcpay-code
    {1}.curr-code = pcurr-code
    {1}.qnty1  =  pqnty1
    {1}.qnty2  = pqnty2
    {1}.netto = pnetto
    {1}.out-name = pout-name
    {1}.is-pay = pis-pay
    {1}.ii = pii
&if not "{2}" = "bge" &then
    {1}.discnt-type = -99
&endif
&if "{2}" = "bge" &then
    {1}.pay-desk = p-pay-desk
    {1}.prefix   = p-prefix
&if "{3}" = "pump" &then
    {1}.pump   = p-pump
&endif
&if "{3}" = "pump-nozzle" &then
    {1}.pump   = p-pump
    {1}.nozzle-code   = p-nozzle-code
&endif

&endif
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.


/* $Workfile$ e n d */