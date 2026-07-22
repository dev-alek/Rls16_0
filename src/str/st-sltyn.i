/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия налога с продаж для lib-trn

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/
&scop proc-name lib-trn3_st-sltyn
{&run_proc_lib-trn3}
(
 input  {1} /*p-trn-doc-recid    */
,input  {2} /*p-cash-pay         */
,output {3} /*p-st-sltpc-have-slt*/
)
{4}.
/* $Workfile$ e n d */