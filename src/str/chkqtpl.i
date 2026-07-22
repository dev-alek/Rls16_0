/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка параметра stfactpl

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/13/06

*/

&scop proc-name lib-calc_chkqtpl
{&run_proc_lib-calc}
  (  input {1} /* parstfactpl  */
  , output {2} /* parupdate    */
  , output {3} /* parrevision  */
  , output {4} /* parpercrev   */
  , output {5} /* parauto-tank */
  , output {6} /* parpercauto  */
  , output {7} /* parinv       */
  , output {8} /* parpercinv   */
  , output {9} /* parinv-set   */
  ) {10} .

/* $Workfile$   E n d */