/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

RCS: Процедуры

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*==========================================================================*/
procedure get-shops-type-and-code :
do
on error undo, return error
:
define input parameter p-shops-id           as character    no-undo.
define output parameter p-shops-obj-type    as character    no-undo.
define output parameter p-shops-obj-code    as integer      no-undo.

    define buffer buf_rcs-shops     for rcs-shops.

    find first buf_rcs-shops no-lock
         where buf_rcs-shops.id = p-shops-id
    no-error.
    if not available buf_rcs-shops
    then do:
        undo, return error "get-shops-id: Не найден объект."
                + {&new-line} + "ID объекта: " + p-shops-id
        .
    end.
    else do:
        assign
            p-shops-obj-type    = buf_rcs-shops.obj-type
            p-shops-obj-code    = buf_rcs-shops.obj-code
        .
    end.
end.
end procedure. /* get-shops-type-and-code */

/*==========================================================================*/
procedure get-destination-id :
do
on error undo, return error
:
define input parameter p-destination-name   as character    no-undo.
define output parameter p-destination-id    as character    no-undo.

    define buffer buf_rcs-destn     for rcs-destn.

    find first buf_rcs-destn no-lock
         where buf_rcs-destn.name = p-destination-name
    no-error.
    if not available buf_rcs-destn
    then do:
        assign
            p-destination-id = ""
        .
    end.
    else do:
        assign
            p-destination-id = buf_rcs-destn.destination_rowid
        .
    end.
end.
end procedure. /* get-destination-id */


/* $Workfile$ e n d */