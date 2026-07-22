/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для ввода месяцев в помесячных отчетах - определени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


/*
&IF DEFINED(UIB_is_Running) NE 0 &THEN
&MESSAGE UIB_is_Running "{1}"
&else
&MESSAGE UIB_is_NOT_Running "{1}"
&endif
*/

&IF "{1}" = "NEW" or "{1}" = "NEW GLOBAL" &then
    &IF DEFINED(UIB_is_Running) NE 0 &THEN
    { cmp/obj-list.i "{1}" }
    &else
    /*
    { cmp/obj-list.i }*/
    &endif
&else
{ cmp/obj-list.i }
&endif

DEFINE {1} shared VARIABLE loc#log as LOGICAL NO-UNDO.
DEFINE {1} shared VARIABLE loc#db-num as integer NO-UNDO.
DEFINE {1} shared VARIABLE loc#host-code as integer NO-UNDO.
DEFINE {1} shared VARIABLE loc#store-code as integer NO-UNDO.
DEFINE {1} shared VAR vStartPoint        as      date       NO-UNDO.
DEFINE {1} shared VAR vEndPoint          as      date       NO-UNDO.
DEFINE {1} shared VAR vStrBuf          as      char       NO-UNDO.
DEFINE {1} shared VAR vEndLastDay      as  integer     no-undo.
define variable State-source as WIDGET-HANDLE.