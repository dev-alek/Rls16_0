/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для печати топливной оборотки (аналог  o s t - l i n e o t h e r - t a x)

Автор: Булгаков Андрей Николаевич
Дата создания: 04/12/05
Author: Andrew Bulgakoff
Creation date: 04/12/05

*/

&SCOP proc-name lib-ptro_rststktx
{&run_proc_lib-ptro}
(
   INPUT  {1} /* store-code    */
,  INPUT  {2} /* store-type    */
,  INPUT  {3} /* artic         */
,  INPUT  {4} /* prod-code     */
,  INPUT  {5} /* prod-type     */
,  INPUT  {6} /* Tog-Shift     */
,  INPUT  {7} /* Fact-order    */
,  INPUT  {8} /* sum-type      */
,  INPUT  {9} /* cat-id        */
,  INPUT {10} /* Tog-Obj       */
,  INPUT {11} /* date-start    */
,  INPUT {12} /* date-end      */
, OUTPUT {13} /* quantity      */
, OUTPUT {14} /* sum-rubl      */
, OUTPUT {15} /* sum-base      */
, OUTPUT {16} /* VAT-rubl      */
, OUTPUT {17} /* VAT-base      */
, OUTPUT {18} /* SLT-rubl      */
, OUTPUT {19} /* SLT-base      */
, OUTPUT {20} /* other-rubl    */
, OUTPUT {21} /* other-base    */
, OUTPUT {22} /* quantity-kg   */
, OUTPUT {23} /* sum-kg-rubl   */
, OUTPUT {24} /* sum-kg-base   */
, OUTPUT {25} /* VAT-kg-rubl   */
, OUTPUT {26} /* VAT-kg-base   */
, OUTPUT {27} /* SLT-kg-rubl   */
, OUTPUT {28} /* SLT-kg-base   */
, OUTPUT {29} /* other-kg_rubl */
, OUTPUT {30} /* other-kg_base */
)        {31} .

/* $Workfile$   E n d */

