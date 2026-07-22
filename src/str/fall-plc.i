/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов процедуры fall-plc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/23/05
Author: Dmitry Ukhanov
Creation date: 12/23/05

*/

&scop proc-name lib-rvs_fall-plc
{&run_proc_lib-rvs}
  (
    input {1}   /* obj-type */
  , input {2}   /* obj-code */
  , input {3}   /* rvs-code */
  , input {4}   /* is-full  */
  )       {5} . /* no-error */

/* $Workfile$   E n d */
