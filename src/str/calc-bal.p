block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calc-bal.p $
$Archive: str/calc-bal.p $

пересчет текущего баланса по договору

Автор: Чернова Светлана Александровна
Дата создания: 09/15/06
Author: Svetlana Chernova
Creation date: 09/15/06


*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calc-bal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/calc-bal.p $":U .
define variable vss-description as character no-undo init "пересчет текущего баланса по договору".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ cmp/library.i }*/

define input  parameter p-type          as character no-undo . /* fin-ob или fin-doc */
define input  parameter p-znak          as logical   no-undo .
define input  parameter p-doc-type      as character no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-sum           as decimal   no-undo .
define input  parameter p-sum-rubl      as decimal   no-undo .
define input  parameter p-sum-base      as decimal   no-undo .

define buffer buf_contract for ub.contract.
find first buf_contract exclusive-lock
  where buf_contract.host-code     = p-host-code
    and buf_contract.contract-code = p-contract-code
no-error .
if available buf_contract then do:
  if p-type = "finob" then do:
    if p-znak then
      assign
        buf_contract.balance-fo      = buf_contract.balance-fo      + p-sum
        buf_contract.balance-fo-rubl = buf_contract.balance-fo-rubl + p-sum-rubl
        buf_contract.balance-fo-base = buf_contract.balance-fo-base + p-sum-base
      .
    else
      assign
        buf_contract.balance-fo      = buf_contract.balance-fo      - p-sum
        buf_contract.balance-fo-rubl = buf_contract.balance-fo-rubl - p-sum-rubl
        buf_contract.balance-fo-base = buf_contract.balance-fo-base - p-sum-base
      .
  end.
  else do:
    if p-doc-type = {&expense-cashless} or p-doc-type = {&expense-cash} or p-doc-type = {&expense-payoff}  then assign p-znak = not p-znak .
    if p-znak then
      assign
        buf_contract.balance-plat      = buf_contract.balance-plat      + p-sum
        buf_contract.balance-plat-rubl = buf_contract.balance-plat-rubl + p-sum-rubl
        buf_contract.balance-plat-base = buf_contract.balance-plat-base + p-sum-base
      .
    else
      assign
        buf_contract.balance-plat      = buf_contract.balance-plat      - p-sum
        buf_contract.balance-plat-rubl = buf_contract.balance-plat-rubl - p-sum-rubl
        buf_contract.balance-plat-base = buf_contract.balance-plat-base - p-sum-base
      .
  end.
end.