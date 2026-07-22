/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка и очистка контекста для пользователя радиотерминала.

Автор: Хныкин Павел Андреевич
Дата создания: 02/05/08
Author: Pavel Khnykin
Creation date: 02/05/08


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop rt-cntxt-setcntxt-procname "w-reqsrv_setcntxt":U
&scop rt-cntxt-clrcntxt-procname "w-reqsrv_clrcntxt":U

define variable v-rt-cntxt_parparentproc  as handle    no-undo .
define variable v-rt-cntxt_proc-signature as character no-undo .

&if "{1}" = "def" and "{2}" <> " " &then
&scoped-define main-menu-handle-variable {2}
&else
&scoped-define main-menu-handle-variable parparentproc
&endif

/*==========================================================================*/
procedure rt-cntxt_setcntxt :
  define input parameter p-cntxt-db-num        as integer   no-undo .
  define input parameter p-cntxt-user-id       as character no-undo .
  define input parameter p-cntxt-level         as character no-undo .
  define input parameter p-cntxt-host-code-obj as integer   no-undo .
  define input parameter p-cntxt-obj-type      as character no-undo .
  define input parameter p-cntxt-obj-code      as integer   no-undo .
  define input parameter p-cntxt-db-num-obj    as integer   no-undo .
  define input parameter p-cntxt-is-admin      as logical   no-undo .

do
on error undo, return error return-value
:
  run w-reqsrv_setcntxt in {&main-menu-handle-variable}
    ( input p-cntxt-db-num
    , input p-cntxt-user-id
    , input p-cntxt-level
    , input p-cntxt-host-code-obj
    , input p-cntxt-obj-type
    , input p-cntxt-obj-code
    , input p-cntxt-db-num-obj
    , input p-cntxt-is-admin
    ) .

end.

end procedure. /* rt-cntxt_setcntxt */

/*==========================================================================*/
procedure rt-cntxt_clrcntxt :

do
on error undo, return error return-value
:
  run w-reqsrv_clrcntxt in {&main-menu-handle-variable} .
end.

end procedure. /* rt-cntxt_clrcntxt */

/* $Workfile$ e n d */
