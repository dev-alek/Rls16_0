/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка топливного товара для lib-trn

Автор: Суслов Алексей Юрьевич
Дата создания: 04/03/02
Author: Alexey Suslov
Creation date: 04/03/02

*/

&scop proc-name lib-trn_is-petrl
{&run_proc_lib-trn}
  (
     input {1} /* artic        */
  ,  input {2} /* prod-type    */
  ,  input {3} /* prod-code    */
  , output {4} /* is-petrolium */
  , output {5} /* is-pieces    */
  ) {6}.

/* $Workfile$   E n d */

