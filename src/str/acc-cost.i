/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простановка учетных цен для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 12/07/06
Author: Svetlana Chernova
Creation date: 12/07/06

Create: Суслов Алексей Юрьевич


*/
&scop proc-name lib-trn_acc-cost
{&run_proc_lib-trn}
(
 input  {1}   /*parobj-type  */
,input  {2}   /*parobj-code  */
,input  {3}   /*pardoc-code  */
,input  {4}   /*parartic     */
,input  {5}   /*parprod-type */
,input  {6}   /*parprod-code */
,input  {7}   /*parcli-qnty  */
,input  {8}   /*pardoc-qnty  */
,input  {9}   /*parfact-qnty */
,input  {10}  /*parprice-base*/
,input  {11}  /*parprice-rubl*/
,input  {12}  /*parmode      */
,output {13}  /*partotal-doc-line_tot-ov        */
,output {14}  /*partotal-doc-line_fact-rubl     */
,output {15}  /*partotal-doc-line_fact-base     */
,output {16}  /*partotal-doc-line_fact-qnty     */
,output {17}  /*partotal-doc-line_doc-qnty      */
,output {18}  /*partotal-doc-line_cli-qnty      */
)
{19}.
/* $Workfile$ e n d */