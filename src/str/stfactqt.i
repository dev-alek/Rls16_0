/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простановка факт. кол-ва в топливные строки внешней приходной накладной для lib-calc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

&scop proc-name lib-calc_stfactqt
{&run_proc_lib-calc}
  ( input        {1}  /* parstfactpl          */
  , input        {2}  /* pardoc-qnty          */
  , input        {3}  /* pardensity           */
  , input        {4}  /* parrvs-before-qnty   */
  , input        {5}  /* parrvs-after-qnty    */
  , input        {6}  /* parauto-tank-qnty    */
  , input        {7}  /* parauto-tank-density */
  , input        {8}  /* parcheck-place       */
  , input-output {9}  /* parfact-qnty         */
  ,       output {10} /* varchg               */
  ,       output {11} /* varst-doc            */
  )              {12}
.

/* $Workfile$   E n d */
