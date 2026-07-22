/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



procedure lockesys :
define input  parameter p-esys-rowid    as rowid            no-undo.
define input  parameter p-esys-name     as character        no-undo.
define output parameter p-success       as logical          no-undo.

define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where rowid( buf_ext-system ) = p-esys-rowid
    no-error no-wait.
    if not available buf_ext-system
    then do:
        assign
            p-success = no
        .
        if locked( buf_ext-system )
        then do:
            return  substitute( "&1. Другой пользователь работает с ВС &2!"
                                    , vss-workfile
                                    , p-esys-name ) .
        end.
        else do:
            return substitute( "&1. ВС &2 не найдена!!!", vss-workfile, p-esys-name ) .
        end.
    end.
    else do:
        assign
            p-success = yes
        .
        return ''.
    end.
end.
end procedure. /* lockesys */

/* $Workfile$ e n d */