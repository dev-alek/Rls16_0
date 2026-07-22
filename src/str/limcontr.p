block-level on error undo, throw.
/*

$Revision: 8af0ca92507d, 852, rls $
$Author: EShklyar $
$Date: Wed Oct 19 12:26:26 2016 +0300 $
$Workfile: limcontr.p $
$Archive: str/limcontr.p $

проверка на превышение лимита кредита по договору

Автор: Чернова Светлана Александровна
Дата создания: 09/15/06
Author: Svetlana Chernova
Creation date: 09/15/06


*/
define variable vss-revision    as character no-undo init "$Revision: 8af0ca92507d, 852, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Oct 19 12:26:26 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: limcontr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/limcontr.p $":U .
define variable vss-description as character no-undo init "проверка на превышение лимита кредита по договору".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-type          as integer   no-undo .  /* что проверять 0 - р у б; 1-вал; 2 -все */
define input  parameter p-sum-rubl      as decimal   no-undo .
define input  parameter p-sum-base      as decimal   no-undo .

define buffer buf_contract for ub.contract.
define variable v-exch-rate   as decimal   no-undo .
define variable v-exch-scale  as integer   no-undo .
define variable v-curr-abbr   as character no-undo .
define variable v-kredit-sum  as decimal   no-undo .

find first buf_contract no-lock
  where buf_contract.host-code     = p-host-code
    and buf_contract.contract-code = p-contract-code
no-error .
if available buf_contract and buf_contract.kredit-limit = yes then do:
  assign v-kredit-sum = buf_contract.kredit-sum .
  if buf_contract.curr-code > 0 then do:
    { gbl/exchrate.i  buf_contract.curr-code today v-exch-rate v-exch-scale v-curr-abbr }
    assign v-kredit-sum = v-kredit-sum * v-exch-rate / v-exch-scale .
  end.

/*  if  buf_contract.doc-type = {&income} then do:*/

    case p-type :
      when 0 then do:
        if buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl + p-sum-rubl > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 {&abbr_rub}; лимит &3 {&abbr_rub}; сумма по документу: &4 {&abbr_rub}', p-contract-code, buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl, v-kredit-sum , p-sum-base) .
      end.
      when 1 then do:
        if buf_contract.balance-fo-base - buf_contract.balance-plat-base + p-sum-base > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 ; лимит &3 ; сумма по документу: &4 ', p-contract-code, buf_contract.balance-fo-base - buf_contract.balance-plat-base, v-kredit-sum , p-sum-base) .
      end.
      when 2 then do:
        if buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl + p-sum-rubl > v-kredit-sum or
           buf_contract.balance-fo-base - buf_contract.balance-plat-base + p-sum-base > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 {&abbr_rub}; лимит &3 {&abbr_rub}; сумма по документу: &4 {&abbr_rub}', p-contract-code, buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl, v-kredit-sum , p-sum-rubl) .
      end.
    end.
  end.
/*  else do:                                                                                                                                                                                                                                                                               */
/*    case p-type :                                                                                                                                                                                                                                                                        */
/*      when 0 then do:                                                                                                                                                                                                                                                                    */
/*        if buf_contract.balance-plat-rubl - buf_contract.balance-fo-rubl + p-sum-rubl > v-kredit-sum then                                                                                                                                                                                */
/*          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 {&abbr_rub}; лимит &3 {&abbr_rub}; сумма по документу: &4 {&abbr_rub}', p-contract-code, buf_contract.balance-plat-rubl - buf_contract.balance-fo-rubl, v-kredit-sum , p-sum-rubl) .*/
/*      end.                                                                                                                                                                                                                                                                               */
/*      when 1 then do:                                                                                                                                                                                                                                                                    */
/*        if buf_contract.balance-plat-base - buf_contract.balance-fo-base + p-sum-base > v-kredit-sum then                                                                                                                                                                                */
/*          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 ; лимит &3 ; сумма по документу: &4 ', p-contract-code, buf_contract.balance-plat-base - buf_contract.balance-fo-base, v-kredit-sum , p-sum-base) .                                 */
/*      end.                                                                                                                                                                                                                                                                               */
/*      when 2 then do:                                                                                                                                                                                                                                                                    */
/*        if buf_contract.balance-plat-rubl - buf_contract.balance-fo-rubl + p-sum-rubl > v-kredit-sum or                                                                                                                                                                                  */
/*           buf_contract.balance-plat-base - buf_contract.balance-fo-base + p-sum-base > v-kredit-sum then                                                                                                                                                                                */
/*          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 {&abbr_rub}; лимит &3 {&abbr_rub}; сумма по документу: &4 {&abbr_rub}', p-contract-code, buf_contract.balance-plat-rubl - buf_contract.balance-fo-rubl, v-kredit-sum , p-sum-rubl) .*/
/*      end.                                                                                                                                                                                                                                                                               */
/*    end.                                                                                                                                                                                                                                                                                 */
/*  end.                                                                                                                                                                                                                                                                                   */
/*end.                                                                                                                                                                                                                                                                                     */