/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка линии на возможность добавления задним числом

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_chkaddln
{&run_proc_lib-trn}
  (
    input {1}  /* pardb-num        */
  , input {2}  /* paruserid        */
  , input {3}  /* parobj-type      */
  , input {4}  /* parobj-code      */
  , input {5}  /* parartic         */
  , input {6}  /* parprod-type     */
  , input {7}  /* parprod-code     */
  , input {8}  /* pardoc-code      */
  , input {9}  /* parfact-order    */
  , input {10}  /* pardoc-type      */
  , input {11}  /* parext-doc-type  */
  , input {12} /* parshift-date    */
  , input {13} /* parshift-num     */
  , input {14} /* parfact-qnty     */
  , input {15} /* parfile-name-err */
  ) {16}.
/* $Workfile$ e n d */