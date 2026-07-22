/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

в какие документы можно включать товары без резервирования по складским местам

Автор: Булгаков Андрей Николаевич
Дата создания: 04/21/06
Author: Andrew Bulgakoff
Creation date: 04/21/06

*/

&scop proc-name lib-trn4_chk4rsrv
{&run_proc_lib-trn4}
  (  input {1} /* ext-doc-type */
  ,  input {2} /* is-hold-doc  */
  , output {3} /* can-process  */
  )        {4} .

/* $Workfile$   E n d */

