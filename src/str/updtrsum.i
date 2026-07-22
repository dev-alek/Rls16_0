/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересчет сумм при модификации документа

Автор: Чернова Светлана Александровна
Дата создания: 11/10/06
Author: Svetlana Chernova
Creation date: 11/10/06

create: Булгаков Андрей Николаевич
Дата создания: 02/01/06


*/

&scop proc-name lib-rwds_updtrsum
{&run_proc_lib-rwds} ( input              {1} ,       /* doc-code            */
                       input              {2} ,       /* artic               */
                       input              {3} ,       /* prod-type           */
                       input              {4} ,       /* prod-code           */
                       input              {5} ,       /* mode                */
                       input-output table {6} ,       /* tt-allsum-line      */
                       input-output table {7} ,       /* tt-doc-line-sum     */
                       input-output table {8} ) {9} . /* tt-old-doc-line-sum */

/* $Workfile$   E n d */