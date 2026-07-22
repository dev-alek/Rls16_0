/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка возможности установки налога с продаж для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_chpsltpc
{&run_proc_lib-trn}
(
 input  {1} /*parinternal*/
,input  {2} /*pardoc-type*/
,input  {3} /*parpay-code*/
,input  {4} /*parcash-pay*/
,input  {5} /*parslt-type*/
,input  {6} /*parext-doc-type*/
,output {7} /*parslt-yes */
)
{8}.
/* $Workfile$ e n d */