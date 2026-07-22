/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

значение по ставке налога на товар в выбранный момент времени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

vargds-code код товара
vartax-code код налога
var-date дата на которую определяем налог   /*if par-date = ? то для сейчас*/
varhost-code код фирмы
varobj-type тип объекта
varobj-code код объекта

возвращает
vartax-value  - значение налога для данного товара на данном объекте данной фирмы

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name pftxvalg
{&run_proc_library}
  (input  {1} /* vargds-code   */
  ,input  {2} /* vartax-code  */
  ,input  {3} /* var-date  */
  ,input  {4} /* varhost-code  */
  ,input  {5} /* varobj-type  */
  ,input  {6} /* varobj-code  */
  ,output {7} /* vartax-value    */
  ) {8} .
/* $Workfile$ e n d */