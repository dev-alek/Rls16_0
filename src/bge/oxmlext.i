/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для создания и запуска новой ВС

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


/*==========================================================================*/
procedure oxmlext-create :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-esys-id           as integer          no-undo.

    define variable v-today     as date         no-undo.
    define variable v-time      as integer      no-undo.
    define variable v-userid    as character    no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run oxmlext-esys-id in this-procedure (
        output p-esys-id
    ).
    run get-userid in p-mainmenu-handle (
        output v-userid
    ).
    create buf_ext-system.
    assign
        buf_ext-system.esys-id                          = p-esys-id
        buf_ext-system.db-num                           = p-current-db-num
        buf_ext-system.esys-date-change                 = v-today
        buf_ext-system.esys-chk-ingr-imp                = no
        buf_ext-system.esys-chk-seq-imp                 = no
        buf_ext-system.esys-date-change-attr            = v-today
        buf_ext-system.esys-date-change-exp             = v-today
        buf_ext-system.esys-date-change-imp             = v-today
        buf_ext-system.esys-db-num-exp                  = p-current-db-num
        buf_ext-system.esys-db-num-imp                  = p-current-db-num
        buf_ext-system.esys-des                         = ""
        buf_ext-system.esys-file-chk-ing-imp            = "":U
        buf_ext-system.esys-have-export                 = no
        buf_ext-system.esys-have-import                 = no
        buf_ext-system.esys-have-proc-chk-ing-imp       = no
        buf_ext-system.esys-last-pack                   = 0
        buf_ext-system.esys-name                        = "<Новая внешняя система>"
        buf_ext-system.esys-num-days-keep-exp           = 0
        buf_ext-system.esys-num-days-keep-imp           = 0
        buf_ext-system.esys-proc-chk-ing-imp            = "":U
        buf_ext-system.esys-send-news-exp               = no
        buf_ext-system.esys-send-news-imp               = no
        buf_ext-system.esys-status                      = integer( {&openxml-status-new} )
        buf_ext-system.esys-work-update                 = no
        buf_ext-system.esys-creid                       = v-userid
        buf_ext-system.esys-sys-date                    = v-today
        buf_ext-system.esys-sys-time-int                = v-time
        buf_ext-system.esys-sys-time                    = string( v-time, "HH:MM:SS" )
        buf_ext-system.esys-user-name                   = v-userid
        buf_ext-system.esys-user-db-num                 = p-current-db-num
    .
end.
end procedure. /* oxmlext-create */


/*==========================================================================*/
/* 29/VIII-2018 - не используется. Вызывалась в единственном месте - bge/extsyss1.p
                  Перенесена в место вызова.
procedure oxmlext-esys-id :
define output parameter p-esys-id   as integer          no-undo.

do
on error undo, return error
:
    assign
        p-esys-id = next-value( s-ext-system, {&db-name_schema} )
    .
end.
end procedure. /* oxmlext-esys-id */
*/
/*==========================================================================*/
procedure oxmlext-start-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 20
    then do:
        assign
            buf_ext-system.esys-status = 21
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 1
        .
    end.
end.
end procedure. /* oxmlext-start-subsystem */


/*==========================================================================*/
procedure oxmlext-stop-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 21
    then do:
        assign
            buf_ext-system.esys-status = 20
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 0
        .
    end.
end.
end procedure. /* oxmlext-stop-subsystem */

/*==========================================================================*/
procedure oxmlext-stop-import :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

do
on error undo, return error
:

end.
end procedure. /* oxmlext-stop-import */

/*==========================================================================*/
procedure oxmlext-stop-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

do
on error undo, return error
:

end.
end procedure. /* oxmlext-stop-export */

/* $Workfile$ e n d */