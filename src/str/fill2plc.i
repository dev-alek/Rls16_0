/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 02/15/08
Author: Ilia Belousov
Creation date: 02/15/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-rvs_fill2plc
{&run_proc_lib-rvs} ( input              {1} ,       /* obj-type       */
                      input              {2} ,       /* obj-code       */
                      input              {3} ,       /* pl-code        */
                      input              {4} ,       /* recid rvs-line */
                      input              {5} ,       /* prev-code      */
                      input-output table {6} ) {7} . /* tt-meas        */

/* $Workfile$ e n d */