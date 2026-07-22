/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение наценки товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

v-gds-code  код товара
v-obj-type  объект
v-obj-code
v-increase-pc - значение наценки

Если определен атрибут товара на объекте increase-pc-o то возвращается его значение
если он не определн то возвращается goods.increase-pc

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gdsoattr-increase-pc
{&run_proc_library}
  (input  {1} /* v-gds-code   */
  ,input  {2} /* v-obj-type  */
  ,input  {3} /* v-obj-code  */
  ,output  {4} /* v-increase-pc  */
  ) {5} .



/* $Workfile$ e n d */