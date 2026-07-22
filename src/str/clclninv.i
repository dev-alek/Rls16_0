/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет линии документа инвентаризации для lib-trn

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/
&scop proc-name lib-trn_clclninv
{&run_proc_lib-trn}
(
 input  {1}  /*parrec-line          */
,input  {2}  /*parstate-price       */
,input  {3}  /*parmode              */
,output {4}  /*partot-doc           */
,output {5}  /*partot-rubl          */
)
{6}.
/* $Workfile$ e n d */