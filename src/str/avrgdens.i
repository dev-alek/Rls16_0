/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет средней плотности по одному из алгоритмов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/11/08
Author: Dmitry Ukhanov
Creation date: 01/11/08

*/

&scop proc-name lib-trn3_avrgdens
{&run_proc_lib-trn3}
  (  input  {1} /* p-gds-code   */
  ,  input  {2} /* p-obj-type   */
  ,  input  {3} /* p-obj-code   */
  ,  input  {4} /* p-pl-code    */
  ,  input  {5} /* p-shift-date */
  ,  input  {6} /* p-shift-num  */
  ,  input  {7} /* p-fact-date  */
  ,  input  {8} /* p-fact-time  */
  , output  {9} /* p-density    */
  , output {10} /* p-Reconc-tank-attr */
  ) {11} .

/* $Workfile$   E n d */
