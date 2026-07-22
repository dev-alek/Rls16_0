/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка, нужно ли создавать, и если нухно, то создание строки inv-line для складского документа (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 04/22/05
Author: Andrew Bulgakoff
Creation date: 04/22/05

*/

&scop proc-name lib-trn3_chkinvln
{&run_proc_lib-trn3} (  input  {1} ,       /* doc-code        */
                        input  {2} ,       /* artic           */
                        input  {3} ,       /* prod-type       */
                        input  {4} ,       /* prod-code       */
                        input  {5} ,       /* sale-rubl (kg)  */
                        input  {6} ,       /* sale-base (kg)  */
                        input  {7} ,       /* acc-rubl  (kg)  */
                        input  {8} ,       /* acc-base  (kg)  */
                        input  {9} ,       /* fact-qnty (kg)  */
                        input {10} ,       /* density         */
                       output {11} ) {12}. /* recid(inv-line) */

/* $Workfile$   E n d */

