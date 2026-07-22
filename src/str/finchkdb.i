/*

$Revision$
$Author$
$Date$
$Workfile$Archive:

Провекра корректности БД для работы с фин документами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/31/10
Author: Bakhtadze Natalya
Creation date: 03/31/10

*/
&scop proc-name lib-farh_finchkdb
{&run_proc_lib-farh}
(input {1}  /*parhost-code    */
,input {2}  /*parfin-doc-code */
,input {3} /*p-obj-type*/
,input {4} /*p-obj-code*/
,input {5} /*p-fin-ext-doc-type*/
,input {6} /*p-trn-doc-code - там лежит оп кассае сли p-fin-doc-code = 0 то заполнится*/
,input {7} /*p-is-autoobj*/
,output {8}  /*p-ok     */
,output {9}  /*p-mess    */
) {10}
.
/* $Workfile$ e n d */