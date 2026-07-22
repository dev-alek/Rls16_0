/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Какие товары, требующие резервирования по складским местам, можно включать в документ без резервирования.

Автор: Булгаков Андрей Николаевич
Дата создания: 02/10/06
Author: Andrew Bulgakoff
Creation date: 02/10/06

*/

&scop proc-name lib-trn4_gdnorsrv
{&run_proc_lib-trn4}
  (  input {1} /* artic        */
  ,  input {2} /* prod-type    */
  ,  input {3} /* prod-code    */
  ,  input {4} /* ext-doc-type */
  , output {5} /* can-process  */
  )        {6} .

/* $Workfile$   E n d */

