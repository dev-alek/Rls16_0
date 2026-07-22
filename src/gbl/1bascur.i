/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция, показывающая все ли в TH объекты  принадлежат фирмам с одной базовой валютой

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/15/04
Author: Bakhtadze Natalya
Creation date: 11/15/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ gbl/dct-algo.i }

FUNCTION one-base-cur-for-objs  returns logical (output p-glob-curr-code as integer):
define variable v-glob-val as logical no-undo init yes.

define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.

assign
p-glob-curr-code =  -1
.

FOR EACH buf_sysconf NO-LOCK,
    first buf_clients no-lock where
         buf_clients.host-code = buf_sysconf.host-code:
    if p-glob-curr-code = -1 then
    assign
    p-glob-curr-code = buf_sysconf.base-code
    .
    else if p-glob-curr-code <> buf_sysconf.base-code then do:
        assign
        v-glob-val = no
        p-glob-curr-code = ?
        .
        LEAVE.
    end.
END.
return v-glob-val.
END FUNCTION.

/* $Workfile$ e n d */