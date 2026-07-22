/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просчет учетных цен для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06


*/
&scop proc-name lib-trn_ass-cost
{&run_proc_lib-trn}
(
 input {1}  /*parrecid-doc             */
,input {2}  /*parinc_tot-ovnew         */
,input {3}  /*parinc_fact-rublnew      */
,input {4}  /*parinc_fact-basenew      */
,input {5}  /*parinc_fact-qntynew      */
,input {6}  /*parinc_doc-qntynew       */
,input {7}  /*parinc_cli-qntynew       */
,input {8}  /*parinc_tot-ovold         */
,input {9}  /*parinc_fact-rublold      */
,input {10} /*parinc_fact-baseold      */
,input {11} /*parinc_fact-qntyold      */
,input {12} /*parinc_doc-qntyold       */
,input {13} /*parinc_cli-qntyold       */
)
{14}.
/* $Workfile$ e n d */