/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Распознавание любых кодов, бар-кодов, складских мест

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/11/06


*/
&scop proc-name libbcrcn_bc-rcnz
{&run_proc_libbcrcn}
(
 input  {1}  /*parparentproc  */
,input  {2}  /*parstr-code    */
,input  {3}  /*parprice       */
,input  {4}  /*parobj-type    */
,input  {5}  /*parobj-code    */
,input  {6}  /*parwith-chs    */
,input  {7}  /*paronly-b-code */
,input  {8}  /*parscales-pref */
,input  {9}  /*parpgscales-pref */
,output {10}  /*parresult      */
,output {11} /*partype-bc     */
,output {12} /*parweight      */
,buffer {13} /*bf_bar-code    */
,buffer {14} /*bf_prod-bc     */
,buffer {15} /*bf_place       */
) {16}.