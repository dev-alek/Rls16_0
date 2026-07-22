/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание основной записи сумм по строке

Автор: Чернова Светлана Александровна
Дата создания: 11/10/06
Author: Svetlana Chernova
Creation date: 11/10/06


create1: Булгаков Андрей Николаевич
Дата создания: 02/01/06

*/

&scop proc-name lib-rwds_cctrnsum
{&run_proc_lib-rwds} ( input              {1} ,        /* doc-code        */
                       input              {2} ,        /* artic           */
                       input              {3} ,        /* prod-type       */
                       input              {4} ,        /* prod-code       */
                       input              {5} ,        /* sum-type (list) */
                       input-output table {6} ,        /* tt-allsum-line  */
                       input-output table {7} ,        /* tt-doc-line-sum */
                       input-output table {8} ,        /* tt-clcparts     */
                       input-output table {9} ) {10} . /* temp-parts      */

/* $Workfile$   E n d */