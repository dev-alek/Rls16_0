/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет шапки внешней приходной накладной для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_clcintrn
{&run_proc_lib-trn}
  (
   input {1}  /*parparentproc    */
  ,input {2}  /*parrec-linenew   */
  ,input {3}  /*pardoc-code      */
  ,input {4}  /*parartic         */
  ,input {5}  /*parprod-type     */
  ,input {6}  /*parprod-code     */
  ,input {7}  /*parprice-cli     */
  ,input {8}  /*parprice-rubl    */
  ,input {9}  /*parprice-base    */
  ,input {10}  /*parcli-qnty      */
  ,input {11} /*parcli-base-rate */
  ,input {12} /*parfact-qnty     */
  ,input {13} /*pardoc-qnty      */
  ,input {14} /*parvat-pc        */
  ,input {15} /*parslt-pc        */
  ,input {16} /*parroad-tax      */
  ,input {17} /*parexcise        */
  ,input {18} /*partransport-rubl*/
  ,input {19} /*parother-rubl    */
  ,input {20} /*parmode          */
  ,input {21} /*parrsrv-inf      */
  ) {22}.
/* $Workfile$ e n d */