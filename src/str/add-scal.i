/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-trn3_add-scal
{&run_proc_lib-trn3}
(input {1}  /*parparentproc */
,input {2}  /*p-obj-type */
,input {3}  /*p-obj-code */
,input {4}  /*pardoc-code */
,input {5}  /*pardoc-type */
,input {6} /*paradd-scal-handle*/
) {7}.

/* $Workfile$ e n d */