/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы ДОПБК - специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*отссылка ДОПБК на кассу*/
&if "{&called}" = "s-prodbcn" &then
  if NOT (ub.shop.cd-pb-base OR ub.shop.cd-pb-alt ) then return.
FOR EACH pbc-list NO-LOCK BREAK BY pbc-list.b-code:
  if first-of(pbc-list.b-code) then new-good = yes.
  else new-good = no.
&else
  if NOT (ub.shop.cd-pb-base OR ub.shop.cd-pb-alt OR ub.shop.cd-sc-base ) then NEXT _shop.
&endif
  RUN term-prt no-error.
&if "{&called}" = "s-prodbcn" &then
  if error-status:error then return error.
  if return-value = "NEXT" then NEXT.
END. /*FOR EACH pbc-list*/
&else
if error-status:error then do:
    error-status:error = no.
    NEXT _shop.
end.
IF return-value = "next" then do:
    NEXT _shop.
end.
&endif

if can-find(first cash-gds) then
RUN SENDING no-error.
{&sending-error}.
/*нужно ли стирать temp-table?*/
FOR EACH cash-gds:
    delete cash-gds.
END.

/* $Workfile$ e n d */