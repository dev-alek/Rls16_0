/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет количества в единицах поставщика для lib-calc

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/
&scop proc-name lib-calc_clccliqt
{&run_proc_lib-calc}
  (
   input   {1} /*parext-gds-type  */
  ,input   {2} /*pardoc-qnty      */
  ,input   {3} /*parcli-base-rate */
  ,input   {4} /*pardensity       */
  ,input   {5} /*parround         */
  ,output  {6} /*parcli-qnty      */
  ) {7}.
/* $Workfile$ e n d */