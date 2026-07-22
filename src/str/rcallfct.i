/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересчет всех сумм на факт либо по требованию

Автор: Чернова Светлана Александровна
Дата создания: 11/10/06
Author: Svetlana Chernova
Creation date: 11/10/06

create: Булгаков Андрей Николаевич
Дата создания: 02/01/06

*/

&scop proc-name lib-rwds_rcallfct
{&run_proc_lib-rwds} ( input              {1} ,        /* doc-code        */
                       input              {2} ,        /* calc wastage    */
                       input              {3} ,        /* calc add sums   */
                       input              {4} ,        /* handle          */
                       input-output table {5} ,        /* tt-wast-line    */
                       input-output table {6} ,        /* tt-allsum-line  */
                       input-output table {7} ,        /* tt-doc-line-sum */
                       input-output table {8} ,        /* tt-clcparts     */
                       input-output table {9} ) {10} . /* temp-parts      */

/* $Workfile$   E n d */
