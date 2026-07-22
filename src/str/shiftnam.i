/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура возврата печатных номеров смен и номеров смен для просмотра

Автор: Суслов Алексей Юрьевич
Дата создания: 12/20/05
Author: Alexey Suslov
Creation date: 12/20/05

*/

&scop proc-name lib-trn3_shiftnam
{&run_proc_lib-trn3}
  (
     input {1}   /* parobj-type       */
  ,  input {2}   /* parobj-code       */
  ,  input {3}   /* parshift-date     */
  ,  input {4}   /* parshift-num      */
  , output {5}   /* parshift-name     */
  , output {6}   /* parshift-name-num */
  )        {7} . /* no-error          */

/* $Workfile$   E n d */

