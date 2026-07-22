/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание истории по изменению товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/05
Author: Bakhtadze Natalya
Creation date: 08/15/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name plgohist
{&run_proc_library}
  (input  {1}  /* p-obj-type          */
  ,input  {2}  /* p-obj-code          */
  ,input  {3}  /* p-pl-code           */
  ,input  {4}  /* p-gds-code          */
  ,input  {5}  /* p-action-type       */
  ,input  {6}  /* p-fact-qnty         */
  ,input  {7}  /* p-cli-qnty          */
  ,input  {8}  /* p-free-qnty         */
  ,input  {9}  /* p-cli-fact-qnty     */
  ,input  {10} /* p-cli-free-qnty     */
  ,input  {11}  /* p-old-fact-qnty    */
  ,input  {12} /* p-old-cli-qnty      */
  ,input  {13} /* p-old-free-qnty     */
  ,input  {14} /* p-old-cli-fact-qnty */
  ,input  {15} /* p-old-cli-free-qnty */
  ,input  {16} /* p-source-type       */
  ,input  {17} /* p-source-ref        */
  ,input  {18} /* p-source-date       */
  ,input  {19} /* p-corr-user-db-num  */
  ,input  {20} /* p-corr-user-name    */
  ,input  {21} /* p-corr-date         */
  ,input  {22} /* p-corr-time         */
  ,input  {23} /* p-corr-time-str     */
  ) {24} .
/* $Workfile$ e n d */