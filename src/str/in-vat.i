/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет цен и количеств, исходя из интерфейса внешнего прихода для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 07/22/08
Author: Svetlana Chernova
Creation date: 07/22/08

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06


*/
&scop proc-name lib-trn_in-vat
{&run_proc_lib-trn}
  (
   input   {1}  /*pardoc-code-or-zone         */
  ,input   {2}  /*parbase-rate                */
  ,input   {3}  /*parbase-scale               */
  ,input   {4}  /*parexch-rate                */
  ,input   {5}  /*parexch-scale               */
  ,input   {6}  /*parvat-type                 */
  ,input   {7}  /*parslt-type                 */
  ,input   {8}  /*parartic                    */
  ,input   {9}  /*parprod-type                */
  ,input   {10} /*parprod-code                */
  ,input   {11} /*parpr-cli                   */
  ,input   {12} /*parcli-base-rate            */
  ,input   {13} /*parpr-rubl                  */
  ,input   {14} /*parvat-pc                   */
  ,input   {15} /*parslt-pc                   */
  ,input   {16} /*parroad-tax                 */
  ,input   {17} /*partransport-rubl           */
  ,input   {18} /*parother-rubl               */
  ,output  {19} /*parprice-cli                */
  ,output  {20} /*parprice-cli-unit-base      */
  ,output  {21} /*parprice-road-tax           */
  ,output  {22} /*parprice-other-exp          */
  ,output  {23} /*parprice-transport-exp      */
  ,output  {24} /*parprice-without-abs        */
  ,output  {25} /*parprice-slt                */
  ,output  {26} /*parprice-no-slt             */
  ,output  {27} /*parprice-vat                */
  ,output  {28} /*parprice-no-vat-slt         */
  ,output  {29} /*parprice-rubl               */
  ,output  {30} /*parprice-road-tax-rubl      */
  ,output  {31} /*parprice-other-exp-rubl     */
  ,output  {32} /*parprice-transport-exp-rubl */
  ,output  {33} /*parprice-without-abs-rubl   */
  ,output  {34} /*parprice-slt-rubl           */
  ,output  {35} /*parprice-no-slt-rubl        */
  ,output  {36} /*parprice-vat-rubl           */
  ,output  {37} /*parprice-no-vat-slt-rubl    */
  ,output  {38} /*parprice-base               */
  ,output  {39} /*parprice-road-tax-base      */
  ,output  {40} /*parprice-other-exp-base     */
  ,output  {41} /*parprice-transport-exp-base */
  ,output  {42} /*parprice-without-abs-base   */
  ,output  {43} /*parprice-slt-base           */
  ,output  {44} /*parprice-no-slt-base        */
  ,output  {45} /*parprice-vat-base           */
  ,output  {46} /*parprice-no-vat-slt-base    */
  ) {47}.
/* $Workfile$ e n d */