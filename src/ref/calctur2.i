/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет итого по покупателю

Автор: Чернова Светлана Александровна
Дата создания: 12/02/05
Author: Svetlana Chernova
Creation date: 12/02/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i }
procedure pricing_calc-itogo-buyer :

  do
  on error undo, return error return-value
  :
define input  parameter  p-cli-type as character no-undo .
define input  parameter  p-cli-code as integer   no-undo .
define output parameter  p-itogo-sum-doc-rubl  as decimal   no-undo . /* суммарный оборот в р у б */
define output parameter  p-itogo-sum-doc-base  as decimal   no-undo . /* суммарный оборот в баз вал */
define output parameter  p-itogo-sum-rash-base as decimal   no-undo . /* суммарный расходный оборот в баз вал */
define output parameter  p-itogo-sum-rash      as decimal   no-undo . /* суммарный расходный оборот в р у б */
define output parameter  p-itogo-sum-vozv-base as decimal   no-undo . /* суммарный возвратный оборот в баз вал */
define output parameter  p-itogo-sum-vozv      as decimal   no-undo . /* суммарный возвратный оборот в р у б */
define output parameter  p-itogo-qnty-doc      as decimal   no-undo . /* всего документов */
define output parameter  p-itogo-qnty-check    as decimal   no-undo . /* всего чеков */

define buffer bb_turnover-buyer      for ub.turnover-buyer.
define buffer bb_turnover-buyer-main for ub.turnover-buyer-main.


assign
  p-ITOGO-sum-doc-rubl =  0
  p-ITOGO-sum-doc-base =  0
  p-ITOGO-sum-rash-base = 0
  p-ITOGO-sum-rash      = 0
  p-ITOGO-sum-vozv-base = 0
  p-ITOGO-sum-vozv      = 0
  p-ITOGO-qnty-doc      = 0
  p-ITOGO-qnty-check    = 0
.

for each bb_turnover-buyer-main no-lock where
         bb_turnover-buyer-main.cli-type = p-cli-type and
         bb_turnover-buyer-main.cli-code = p-cli-code
         :
    p-ITOGO-qnty-doc     = p-ITOGO-qnty-doc     + bb_turnover-buyer-main.qnty-doc-itog .
    p-ITOGO-qnty-check   = p-ITOGO-qnty-check   + bb_turnover-buyer-main.qnty-check-itog .
    p-ITOGO-sum-doc-rubl = p-ITOGO-sum-doc-rubl + bb_turnover-buyer-main.sum-doc-rubl-itog .
    p-ITOGO-sum-doc-base = p-ITOGO-sum-doc-base + bb_turnover-buyer-main.sum-doc-base-itog .
end.

for each bb_turnover-buyer no-lock where
         bb_turnover-buyer.cli-type = p-cli-type and
         bb_turnover-buyer.cli-code = p-cli-code
         :
    if bb_turnover-buyer.ext-doc-type = {&TDEDT_Ras_Vnesh}      or
       bb_turnover-buyer.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or
       bb_turnover-buyer.ext-doc-type = ""  /* ручное добавление рассматриваем как расход  */
       then do:
        p-ITOGO-sum-rash      = p-ITOGO-sum-rash      + bb_turnover-buyer.sum-doc-rubl .
        p-ITOGO-sum-rash-base = p-ITOGO-sum-rash-base + bb_turnover-buyer.sum-doc-base .
    end.
    else do:
        p-ITOGO-sum-vozv      = p-ITOGO-sum-vozv      + bb_turnover-buyer.sum-doc-rubl .
        p-ITOGO-sum-vozv-base = p-ITOGO-sum-vozv-base + bb_turnover-buyer.sum-doc-base .
    end.
end.

  end.

end procedure. /* pricing_calc-itogo-buyer */
