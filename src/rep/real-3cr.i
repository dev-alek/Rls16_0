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

PROCEDURE create-{1}.
DEFINE INPUT PARAMETER pgrp-code-sheet like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.

_main:
DO ON ERROR UNDO _main, return error:
    create {1}.
    assign
    {1}.grp-code-sheet = pgrp-code-sheet
    {1}.cpay-code = pcpay-code
    {1}.curr-code = pcurr-code
    {1}.qnty1  =  pqnty1
    {1}.netto = pnetto
    {1}.out-name = pout-name
    {1}.is-pay = pis-pay
    {1}.ii = pii
    {1}.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.

/* $Workfile$ e n d */