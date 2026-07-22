/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать ценников (этикеток). Подготовка к печати.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/

DEFINE VARIABLE b-count as integer init 0 no-undo.
DEFINE VARIABLE v-fact-order        like ub.trn-doc.fact-order     no-undo.

run rep/tickets.w (input parparentproc, input p-obj-type, input p-obj-code, input Action, input &if "{1}" = "" &then "" &else {1} &endif ).

if TicketName = "" then
    RETURN.

OUTPUT STREAM OutStream TO VALUE( lbc-tmp + "title" ) CONVERT TARGET TitleCP PAGE-SIZE 0 .


/* $Workfile$ e n d */