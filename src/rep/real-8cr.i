/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура для рождения записей в таблице treal-8

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/01/07
Author: Bakhtadze Natalya
Creation date: 08/01/07

сменный отчет лист 8

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE create-{1}.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.


_main:
DO ON ERROR UNDO _main, return error:
    create {1}.
    assign
    {1}.gds-code = pgds-code
    {1}.cpay-code = pcpay-code
    {1}.curr-code = pcurr-code
    {1}.qnty1  =  pqnty1
    {1}.netto = pnetto
    {1}.cli-type = p-cli-type
    {1}.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.


/* $Workfile$ e n d */