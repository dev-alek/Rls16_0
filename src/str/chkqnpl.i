/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура проверки допустимости использования кол-ва по месту хранени

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/12/07
Author: Dmitry Ukhanov
Creation date: 10/12/07

*/

&scop proc-name lib-trn3_chkqnpl
{&run_proc_lib-trn3}
  (  input {1} /* p-doc-type */
  ,  input {2} /* p-obj-type */
  ,  input {3} /* p-obj-code */
  ,  input {4} /* p-pl-code  */
  ,  input {5} /* p-gds-code */
  ,  input {6} /* p-msg-on   */
  ,  input {7} /* p-qnty     */
  , output {8} /* p-new-qnty */
  )        {9} /* no-error   */
  .

/* $Workfile$ e n d */