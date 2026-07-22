/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет дорожного налогоа для lib-calc

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-calc_clcrdtax
{&run_proc_lib-calc}
  (
   input   {1}  /*pargds-code      */
  ,input   {2}  /*parext-gds-type  */
  ,input   {3}  /*parcli-base-rate */
  ,input   {4}  /*pardoc-qnty      */
  ,input   {5}  /*pardensity       */
  ,input   {6}  /*parroad-tax-cli  */
  ,input   {7}  /*parbase-rate     */
  ,input   {8}  /*parbase-scale    */
  ,input   {9}  /*parexch-rate     */
  ,input   {10} /*parexch-scale    */
  ,output  {11} /*parroad-tax      */
  ) {12} .
/* $Workfile$ e n d */