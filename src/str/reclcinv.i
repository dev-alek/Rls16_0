/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет документа инвентаризации по линии

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&scop proc-name lib-trn2_reclcinv
{&run_proc_lib-trn2}
(
input        {1},  /*work-mode                     */
input        {2},  /*parrec-line                   */
input        {3},  /*pardoc-code                   */
input-output {4},  /*vartot-docold                 */
input-output {5},  /*vartot-rublold                */
input-output {6},  /*i-total-doc-line_tot-ovold    */
input-output {7},  /*i-total-doc-line_fact-rublold */
input-output {8},  /*i-total-doc-line_fact-baseold */
input-output {9},  /*i-total-doc-line_fact-qntyold */
input-output {10}, /*i-total-doc-line_doc-qntyold  */
input-output {11}, /*i-total-doc-line_cli-qntyold  */
input-output {12}, /*i-total-parts_fact-baseold    */
input-output {13}, /*i-total-parts_fact-rublold    */
input-output {14}  /*i-total-parts_fact-qntyold    */
) {15}.