/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение диапазона fact-order по диапазону дат

Автор: Булгаков Андрей Николаевич
Дата создания: 04/13/05
Author: Andrew Bulgakoff
Creation date: 04/13/05

*/

&scop proc-name lib-ptro_get-fo
{&run_proc_lib-ptro}
  (  input  {1} , /* store-code  */
     input  {2} , /* store-type  */
     input  {3} , /* Tog-Shift   */
     input  {4} , /* date-start  */
     input  {5} , /* date-end    */
     input  {6} , /* shift-start */
     input  {7} , /* shift-end   */
     input  {8} , /* sum-type    */
     input  {9} , /* cat-id      */
     input {10} , /* Tog-Obj     */
    output {11}   /* Fact-Order  */
  )        {12} . /* no-error    */

/* $Workfile$   E n d */

