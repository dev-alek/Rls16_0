/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 06/23/08
Author: Svetlana Chernova
Creation date: 06/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gdscheck
{&run_proc_library}
  (input {1} /* p-obj-type  */
  ,input {2} /* p-obj-code  */
  ,input {3} /* p-artic     */
  ,input {4} /* p-prod-type */
  ,input {5} /* p-prod-code */
  ,input {6} /* p-root-node */
  ,input {7} /* p-mode      */
  ) {8} .
/* $Workfile$ e n d */