/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает запрашиваемое количество (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 03/23/05
Author: Andrew Bulgakoff
Creation date: 03/23/05

*/

&scop proc-name lib-trn3_invlnqty
{&run_proc_lib-trn3} (  input {1} ,      /* doc-code  */
                        input {2} ,      /* artic     */
                        input {3} ,      /* prod-type */
                        input {4} ,      /* prod-code */
                        input {5} ,      /* qnty-type (yes-архив,no-тек.) */
                       output {6} ) {7}. /* qnty (kg) */

/* $Workfile$   E n d */

