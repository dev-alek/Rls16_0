/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание истории по изменению товара на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gohist
{&run_proc_library}
  (input  {1}  /* p-obj-type          */
  ,input  {2}  /* p-obj-code          */
  ,input  {3}  /* p-gds-code          */
  ,input  {4}  /* p-action-type       */
  ,input  {5}  /* p-fact-qnty         */
  ,input  {6}  /* p-fact-cli-qnty     */
  ,input  {7}  /* p-fact-base         */
  ,input  {8}  /* p-fact-rubl         */
  ,input  {9}  /* p-fact-sale         */
  ,input  {10} /* p-old-fact-qnty     */
  ,input  {11} /* p-old-fact-cli-qnty */
  ,input  {12} /* p-old-fact-base     */
  ,input  {13} /* p-old-fact-rubl     */
  ,input  {14} /* p-old-fact-sale     */
  ,input  {15} /* p-source-type       */
  ,input  {16} /* p-source-ref        */
  ,input  {17} /* p-source-date       */
  ,input  {18} /* p-corr-user-db-num  */
  ,input  {19} /* p-corr-user-name    */
  ,input  {20} /* p-corr-date         */
  ,input  {21} /* p-corr-time         */
  ,input  {22} /* p-corr-time-str     */
  ) {23} .
/* $Workfile$ e n d */