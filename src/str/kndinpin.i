/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вид заполнения приходной накладной для lib-calc

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/
&scop proc-name lib-calc_kndinpin
{&run_proc_lib-calc}
  (
   input  {1}  /*pargds-code             */
  ,input  {2}  /*parcli-type             */
  ,input  {3}  /*parcli-code             */
  ,input  {4}  /*parobj-type             */
  ,input  {5}  /*parobj-code             */
  ,output {6}  /*parext-gds-type         */
  ,output {7}  /*parcli-qnty-input       */
  ,output {8}  /*pardensity-input        */
  ,output {9}  /*parcli-base-rate-input  */
  ,output {10} /*pardoc-qnty-input       */
  ,output {11} /*parfact-qnty-input      */
  ,output {12} /*parprice-cli-input      */
  ,output {13} /*parbase-price-input     */
  ,output {14} /*partax-3-input          */
  ,output {15} /*parcli-qnty-calc        */
  ,output {16} /*pardensity-calc         */
  ,output {17} /*parcli-base-rate-calc   */
  ,output {18} /*pardoc-qnty-calc        */
  ,output {19} /*parfact-qnty-calc       */
  ,output {20} /*parprice-cli-calc       */
  ,output {21} /*parbase-price-calc      */
  ,output {22} /*partax-3-calc           */
  ,output {23} /*parround                */
  ) {24}.
/* $Workfile$ e n d */