/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение значения атрибута партии на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10


*/

&scop proc-name partolib_partoval
{&run_proc_partolib} (  input {1}        /* obj-type   */
                       ,input {2}        /* obj-code   */
                       ,input {3}        /* gds-code   */
                       ,input {4}        /* prt-code   */
                       ,input {5}        /* in-code   */
                       ,input {6}        /* out-code   */
                       ,input {7}        /* part-code   */
                       ,input {8}        /* attr-code  */
                       ,output {9}        /* attr-value */
                       ,output {10} ) {11} . /* type       */

/* $Workfile$   E n d */