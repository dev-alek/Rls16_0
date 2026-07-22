/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы БК - специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*отслыка БК на кассу*/
&if "{&called}" = "send-bcn" &then
if NOT (ub.shop.cd-bc-base OR ub.shop.cd-bc-alt OR ub.shop.cd-loc-base OR ub.shop.cd-loc-alt) then return.
FOR EACH bc-list NO-LOCK BREAK by bc-list.gds-code:
  if NOT (action = "D") = bc-list.del then NEXT.
  if first-of(bc-list.gds-code) then new-good = yes.
  else new-good = no.
&else
  if NOT (ub.shop.cd-bc-base OR ub.shop.cd-bc-alt OR ub.shop.cd-loc-base OR ub.shop.cd-loc-alt) then NEXT _shop.
&endif
  RUN term-prt no-error.
&if "{&called}" = "send-bcn" &then
  if error-status:error then return error.
  if return-value = "NEXT" then NEXT.
END. /*FOR EACH bc-list*/
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