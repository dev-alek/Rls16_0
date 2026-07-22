/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет предполагаемой продажной цены для внешнего прихода

Автор: Чернова Светлана Александровна
Дата создания: 02/16/07
Author: Svetlana Chernova
Creation date: 02/16/07


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "run"  &then
run find-new-price-sale in this-procedure (
   input  {2} /* gen-mrgn  */
  ,input  {3} /* pr-nakl   */
  ,input  {4} /* doc-code  */
  ,input  {5} /* artic     */
  ,input  {6} /* prod-type */
  ,input  {7} /* prod-code */
  ,input  {8} /* price-rubl */
  ,input  {9} /* price-base */
  ,input  {10} /* vat-pc */
  ,input  {11} /* slt-pc */
  ,input-output {12} /* new-price-sale*/
    )
    {13} .

&endif
&if "{1}" = "proc"  &then
procedure find-new-price-sale :
define input  parameter  par-gm           as character no-undo .
define input  parameter  par-pr-nakl      as logical   no-undo .
define input  parameter  p-doc-code       as character no-undo .
define input  parameter  p-artic          as character no-undo .
define input  parameter  p-prod-type      as character no-undo .
define input  parameter  p-prod-code      as integer   no-undo .
define input  parameter  p-doc-price-rubl as decimal   no-undo .
define input  parameter  p-doc-price-base as decimal   no-undo .
define input  parameter  p-doc-vat-pc     as decimal   no-undo .
define input  parameter  p-doc-slt-pc     as decimal   no-undo .
define input-output parameter  p-new-price-sale as decimal   no-undo .


define buffer buf_trn-doc for ub.trn-doc  .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .


  do
  on error undo, return error return-value
  :
 find first buf_trn-doc no-lock where buf_trn-doc.doc-code =  p-doc-code no-error .
 { str/is-petrl.i
  p-artic
  p-prod-type
  p-prod-code
  is-petrolium
  is-pieces
 }

if not (par-pr-nakl = yes and par-gm = {&typeprice_before-margin} and is-petrolium = false ) then return .

  run str/in-prno.p (
      input   parParentProc ,
      input   p-doc-code    ,
      input   p-artic       ,
      input   p-prod-type   ,
      input   p-prod-code   ,
      input   p-doc-price-rubl ,
      input   p-doc-price-base ,
      input   p-doc-vat-pc ,
      input   p-doc-slt-pc ,
      input-output  p-new-price-sale ) .
  end.

end procedure. /* find-new-price-sale */
&endif