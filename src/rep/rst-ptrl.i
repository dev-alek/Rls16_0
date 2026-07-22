/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для печати топливной оборотки (аналог  o s t a t o k)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/05
Author: Dmitry Ukhanov
Creation date: 04/12/05

*/

&SCOP proc-name lib-ptro_rst-ptrl
{&run_proc_lib-ptro}
(
   INPUT  {1} /* store-code  */
,  INPUT  {2} /* store-type  */
,  INPUT  {3} /* Tog-Shift   */
,  INPUT  {4} /* date-start  */
,  INPUT  {5} /* date-end    */
,  INPUT  {6} /* shift-start */
,  INPUT  {7} /* shift-end   */
,  INPUT  {8} /* sum-type    */
,  INPUT  {9} /* cat-id      */
,  INPUT {10} /* Tog-Obj     */
, OUTPUT {11} /* Quantity    */
, OUTPUT {12} /* Cost_R      */
, OUTPUT {13} /* Cost_V      */
, OUTPUT {14} /* VAT_R       */
, OUTPUT {15} /* VAT_V       */
, OUTPUT {16} /* Fact-Order  */
, OUTPUT {17} /* Quantity-kg */
, OUTPUT {18} /* Cost-kg_R   */
, OUTPUT {19} /* Cost-kg_V   */
, OUTPUT {20} /* VAT-kg_R    */
, OUTPUT {21} /* VAT-kg_V    */
)        {22} .

/* $Workfile$   E n d */

