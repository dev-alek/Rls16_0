/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает запрашиваемый тип цены в  р у б  или б.в. (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 03/23/05
Author: Andrew Bulgakoff
Creation date: 03/23/05

*/

&scop proc-name lib-trn3_invlnprc
{&run_proc_lib-trn3}
(
   input {1} /* doc-code              */
,  input {2} /* artic                 */
,  input {3} /* prod-type             */
,  input {4} /* prod-code             */
,  input {5} /* price-type (acc,sale) */
,  input {6} /* print-rubl (yes,no)   */
, output {7} /* price (kg)            */
)        {8} .

/* $Workfile$   E n d */

