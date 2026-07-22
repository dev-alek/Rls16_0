/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск параметров как формировать автопереоценки по объектам

Автор: Чернова Светлана Александровна
Дата создания: 05/12/06
Author: Svetlana Chernova
Creation date: 05/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gtpl-fs
{&run_proc_library2}
 ( input  {1} /* p-handle     */
  ,input  {2} /* p-obj-type   */
  ,input  {3} /* p-obj-code   */
  ,output {4} /* p-first-ie    */
  ,output {5} /* p-first-iv    */
  ,output {6} /* p-first-im    */
  ,output {7} /* p-second-ie    */
  ,output {8} /* p-second-iv    */
  ,output {9} /* p-second-im    */
  ) {10} .
/* $Workfile$ e n d */