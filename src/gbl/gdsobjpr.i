/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить своиства по Асс.политике товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

p-artic
p-prod-type
p-prod-code     можно задать или троицу-артикул или gds-code

p-gds-code      можно задать или троицу-артикул или gds-code

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gdsobjpr
{&run_proc_library}
  (input  {1} /* p-obj-type         */
  ,input  {2} /* p-obj-code         */
  ,input  {3} /* p-artic            */
  ,input  {4} /* p-prod-type        */
  ,input  {5} /* p-prod-code        */
  ,input  {6} /* p-gds-code         */
  ,output {7} /* p-return-AssMin    */
  ,output {8} /* p-return-igt      */
  ,output {9}  /* p-gdop-min-stock    */
  ,output {10} /* p-grop-max-stock    */
  ,output {11} /* p-grop-level-always-presence */
  ,output {12} /* p-grop-min-order             */
  ) {13} .
/* $Workfile$ */