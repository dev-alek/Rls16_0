/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка линии при переходе по статусам

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn3_chklinst
{&run_proc_lib-trn3}
(input  {1}  /*parhandle   */
,input  {2}  /*pardoc-code */
,input  {3}  /*parstatus   */
,output {4}  /*parfact-ok  */
) {5}.