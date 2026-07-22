/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура возврата печатных номеров смен и номеров смен для просмотра в случае возможности отсутствия shift-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/06
Author: Bakhtadze Natalya
Creation date: 01/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-trn3_shiftnme
{&run_proc_lib-trn3} ( input  {1}, /* parobj-type       */
                       input  {2}, /* parobj-code       */
                       input  {3}, /* parshift-date     */
                       input  {4}, /* parshift-num      */
                       input-output {5}, /* parshift-name     */
                       output {6}  /* parshift-name-num */
                       ) {7} . /* can close */

/* $Workfile$   E n d */