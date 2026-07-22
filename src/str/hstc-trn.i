/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись удаляемого складского документа в историю

Автор: Чернова Светлана Александровна
Дата создания: 12/13/06
Author: Svetlana Chernova
Creation date: 12/13/06


*/
&scop proc-name lib-trn_hstc-trn
{&run_proc_lib-trn}
  (
    input {1}  /* parrec-trn-doc     */
  , input {2}  /* parobj-date        */
  , input {3}  /* parshift-date      */
  , input {4}  /* parshift-num       */
  , input {5}  /* parshift-name      */
  , input {6}  /* parcorr-incas-code */
  , input {7}  /* parcorr-fbr-code   */
  , input {8}  /* paruserid          */
  , input {9}  /* parcurdb-num       */
  , input {10} /* parchipnum         */
  ) {11}.
/* $Workfile$ e n d */