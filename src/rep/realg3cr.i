/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение процедура для рождения записей в таблице treal-3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

ЮКОС лист 3

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE create-g-{1}.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
&if "{2}" = "repzak" &then
define input parameter p-is-out  as logical no-undo . /*расход возврат*/
DEFINE INPUT PARAMETER p-src-code like ub.chk-gds.src-code no-undo.
&else
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
&endif
&if "{2}" = "rep" &then
define input parameter p-rv as integer no-undo . /*расход возврат*/
&endif
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
&if "{2}" = "bge" &then
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
&endif


_main:
DO ON ERROR UNDO _main, return error:
    create {1}.
    assign
    {1}.gds-code = pgds-code
&if "{2}" = "rep" &then
    {1}.rv = p-rv
&endif
&if "{2}" = "repzak" &then
    {1}.is-out   = p-is-out
    {1}.src-code = p-src-code
&else
    {1}.cpay-code = pcpay-code
    {1}.curr-code = pcurr-code
&endif
    {1}.qnty1  =  pqnty1
    {1}.netto = pnetto
    {1}.out-name = pout-name
    {1}.is-pay = pis-pay
    {1}.ii = pii
&if "{2}" = "bge" &then
    {1}.pay-desk = p-pay-desk
    {1}.prefix   = p-prefix
&endif


    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.

/* $Workfile$ e n d */