/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет коэффициента пересчета из клиентских единиц в базовые для lib-calc

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/
&scop proc-name lib-calc_clcclirt
{&run_proc_lib-calc}
  (
   input  {1} /*parext-gds-type   */
  ,input  {2} /*parcli-qnty       */
  ,input  {3} /*pardoc-qnty       */
  ,input  {4} /*pardensity        */
  ,input  {5} /*parround          */
  ,output {6} /*parcli-base-rate  */
  ) {7}.
/* $Workfile$ e n d */