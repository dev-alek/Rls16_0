/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Значение по ставке налога в заданный момент  времени для заданного объекта и фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

var-rc ресид ставки налога
vartax-code код налога
varrate-code код ставки налога
var-date дата на которую определяем налог   /*if par-date = ? то для сейчас*/
varhost-code код фирмы
varobj-type тип объекта
varobj-code код объекта

возвращает
vartax-value  - значение данной ставки на данном объекте данной фирмы

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name pftaxval
{&run_proc_library}
  (input  {1} /* var-rc   */
  ,input  {2} /* vartax-code  */
  ,input  {3} /* varrate-code  */
  ,input  {4} /* var-date  */
  ,input  {5} /* varhost-code  */
  ,input  {6} /* varobj-type  */
  ,input  {7} /* varobj-code  */
  ,output {8} /* vartax-value    */
  ) {9} .
/* $Workfile$ e n d */