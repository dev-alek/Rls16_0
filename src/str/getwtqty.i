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

&scop proc-name lib-trn3_getwtqty
{&run_proc_lib-trn3} (  input {1} ,      /* doc-code                       */
                        input {2} ,      /* artic                          */
                        input {3} ,      /* prod-type                      */
                        input {4} ,      /* prod-code                      */
                       output {5} ,      /* before-qnty - было             */
                       output {6} ,      /* after-qnty  - стало            */
                       output {7} ,      /* qnty        - по документу     */
                       output {8} ) {9}. /* abs-qnty    - abs по документу */

/* $Workfile$   E n d */

