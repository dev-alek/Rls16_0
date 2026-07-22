/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просчет части шапки документа для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scop proc-name lib-trn_clcpttrn
{&run_proc_lib-trn}
  (
   input {1}  /*parrec-doc               */
  ,input {2}  /*pardiscnt-base-fact-new  */
  ,input {3}  /*pardiscnt-rubl-fact-new  */
  ,input {4}  /*parroad-tax-fact-new     */
  ,input {5}  /*parexcise-fact-new       */
  ,input {6}  /*parslt-fact-base-new     */
  ,input {7}  /*parvat-fact-base-new     */
  ,input {8}  /*parslt-fact-rubl-new     */
  ,input {9}  /*parvat-fact-rubl-new     */
  ,input {10} /*pardiscnt-base-fact-old  */
  ,input {11} /*pardiscnt-rubl-fact-old  */
  ,input {12} /*parroad-tax-fact-old     */
  ,input {13} /*parexcise-fact-old       */
  ,input {14} /*parslt-fact-base-old     */
  ,input {15} /*parvat-fact-base-old     */
  ,input {16} /*parslt-fact-rubl-old     */
  ,input {17} /*parvat-fact-rubl-old     */
  ) {18}.
/* $Workfile$ e n d */