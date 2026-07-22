/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

v-gds-code  код товара
v-obj-type  тип объекта или "" если для всех объектов текущей базы
v-obj-code  код объекта или 0 если для всех объектов текущей базы
v-b-str     prod-bc.b-str или  ? если нужен первый существующий
v-overwrite переписать если уже существует

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name sclcdattr
{&run_proc_library}
  (input  {1} /* v-gds-code   */
  ,input  {2} /* v-obj-type   */
  ,input  {3} /* v-obj-code   */
  ,input  {4} /* v-b-str      */
  ,input  {5} /* v-overwrite  */
  ) {6} .

/* $Workfile$ e n d */