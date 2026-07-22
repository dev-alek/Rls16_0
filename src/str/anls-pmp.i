/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов процедуры anls-pmp

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/23/05
Author: Dmitry Ukhanov
Creation date: 12/23/05

*/

&scop proc-name lib-rvs_anls-pmp
{&run_proc_lib-rvs} ( input              {1} ,       /* p-parent-proc       */
                      input              {2} ,       /* obj-type            */
                      input              {3} ,       /* obj-code            */
                      input              {4} ,       /* check-goods         */
                      input-output table {5} ,       /* tt-pump-nozzle-file */
                      input-output table {6} ,       /* tt-pump-nozzle      */
                      input              {7} ,       /* read-cur            */
                      input              {8} ,       /* message-on          */
                      input              {9}) {10} . /* no-waitfram         */

/* $Workfile$   E n d */

