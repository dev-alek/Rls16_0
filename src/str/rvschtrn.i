/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка, есть ли незакрытые документы за смену

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/26/06
Author: Dmitry Ukhanov
Creation date: 01/26/06

*/

&scop proc-name lib-trn3_rvschtrn
{&run_proc_lib-trn3}
  (  input {1} /* obj-type   */
  ,  input {2} /* obj-code   */
  ,  input {3} /* shift-date */
  ,  input {4} /* shift-num  */
  ,  input {5} /* rvs-code   */
  ,  input {6} /* talk on    */
  ,  input {7} /* ask        */
  , output {8} /* was found  */
  )        {9} /* no-error   */
.

/* $Workfile$   E n d */

