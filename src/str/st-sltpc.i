/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка налога с продаж для lib-trn

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/
&scop proc-name lib-trn_st-sltpc
{&run_proc_lib-trn}
(
 input  {1} /*p-goods-recid  */
,input  {2} /*p-trn-doc-recid*/
,input  {3} /*p-cash-pay     */
,output {4} /*p-st-sltpc-slt */
)
{5}.
/* $Workfile$ e n d */