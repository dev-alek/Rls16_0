/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов процедуры fill1plc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/23/05
Author: Dmitry Ukhanov
Creation date: 12/23/05

*/

&scop proc-name lib-rvs_fill1plc
{&run_proc_lib-rvs} ( input              {1} ,       /* obj-type       */
                      input              {2} ,       /* obj-code       */
                      input              {3} ,       /* pl-code        */
                      input              {4} ,       /* recid rvs-line */
                      input              {5} ,       /* prev-code      */
                      input-output table {6} ) {7} . /* tt-meas        */

/* $Workfile$   E n d */

