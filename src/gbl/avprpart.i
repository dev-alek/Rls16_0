/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Средняя продажная цена по партиям

Автор: Чернова Светлана Александровна
Дата создания: 12/14/09
Author: Svetlana Chernova
Creation date: 12/14/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lib-trn3_avprpart
{&run_proc_lib-trn3}
  (input  {1} /* v-obj-type    */
  ,input  {2} /* v-obj-code    */
  ,input  {3} /* v-b-code      */
  ,input  {4} /* v-root-b-code */
  ,input  {5} /* v-fact-order  */
  ,output {6} /* v-doc-num     */
  ,output {7} /* v-price-sale  */
  ,output {8} /* v-road-tax    */
  ,output {9} /* v-excise      */
  ) {10} .

  /* $Workfile$ e n d */