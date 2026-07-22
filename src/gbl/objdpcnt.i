/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение скидки на карте на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

v-type       тип карты
v-emitent-host-code код эмитента
v-host-code  фирма
v-obj-type    объект
v-obj-code


Возвращаемые параметры:
v-d-pcnt      скидка

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name objdpcnt
{&run_proc_library}
  (
   input  {1} /* v-type                 */
  ,input  {2} /* v-emitent-host-code    */
  ,input  {3} /* v-host-code            */
  ,input  {4} /* v-obj-type             */
  ,input  {5} /* v-obj-code             */
  ,input  {6} /* {&ddctr-def-pcnt}  {&ddctr-def-cash-pcnt}  {&ddctr-def-categ  */
  ,output {7} /* v-d-pcnt               */
  ) {8} .

/* $Workfile$ e n d */