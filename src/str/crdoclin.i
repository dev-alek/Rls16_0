/*

$Revision$
$Author$
$Date$
$Workfile$Archive:

Создание строки складского документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_crdoclin
{&run_proc_lib-trn}
(input {1}  /*doc-code    */
,input {2}  /*artic       */
,input {3}  /*prod-type   */
,input {4}  /*prod-code   */
,input {5}  /*obj-type    */
,input {6}  /*obj-code    */
,input {7}  /*status_     */
,input {8}  /*ext-doc-type*/
,input {9}  /*prt-root    */
,input {10} /*vat-pc      */
,input {11} /*slt-pc      */
,input {12} /*cons-vat-pc */
) {13}
.
/* $Workfile$ e n d */