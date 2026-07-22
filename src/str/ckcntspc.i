/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка товаров и их цен на соответствие спецификации к договору

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn3_ckcntspc
{&run_proc_lib-trn3}
( input {1}       /*parhost-code    */
 ,input {2}       /*parcontract-code*/
 ,input {3}       /*pargds-code     */
 ,input {4}       /*parprice-rubl   */
 ,input {5}       /*parvat-type     */
 ,input {6}       /*parvat-pc       */
) {7} .

/* $Workfile$ e n d */