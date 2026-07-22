/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок оборотки по поставщикам слитно по объектам

Автор: Чернова Светлана Александровна
Дата создания: 05/07/08
Author: Svetlana Chernova
Creation date: 05/07/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
{ rep/r-defpst.i {1} }
{ rep/f-fdec.i       }
{ rep/f-flav.i       }
{ gbl/waitfram.i     }

define variable ii like i init 0 no-undo .
define variable t#cat-id like ub.stk-line.cat-id no-undo .
define variable t#Sum-type like ub.stk-line.Sum-type no-undo .
define variable t#kol-rec-obj like i init 0  no-undo .

if Show-Negativ then null-fact-order = 0 .
   else  null-fact-order = fact-order-1 .
&if  "{1}" = "&framename='oborot':U" &then
null-fact-order = 0 .
&endif
for each obj-list no-lock :
  t#kol-rec-obj = t#kol-rec-obj + 1.
End.
  case type-stor /* консигнация или выкуп */ :
        when 1 then
          Assign
            t#cat-id   = {&single-cat-id}
            t#sum-type = {&arh-cost}  .
        when 2 then
          Assign
            t#cat-id   = {&arh-repayment}
            t#sum-type = {&arh-cost} + {&arh-supp} .
        when 3 then
          Assign
            t#cat-id   = {&arh-cons_acc}
            t#sum-type = {&arh-cost} + {&arh-supp} .
        when 4 then
          Assign
            t#cat-id   = {&arh-resp_stor}
            t#sum-type = {&arh-cost} + {&arh-supp} .
        when 5 then
          Assign
            t#cat-id   = {&arh-old_cons}
            t#sum-type = {&arh-cost} + {&arh-supp} .
  End case.
Case Select-Good :
  when {&g-all}  then run run1-0.
  when {&g-grp}  then run run2-0.
  when {&g-prod} then run run3-0.
  otherwise do:
    run run45-0.
  end.
End case.

procedure run1-0 :
CASE RetClassify :
  when "no-classify":u then  do:
    { rep/p-run3.i  {3} &b1 = 1  &b2 = 1  {2} }
  end.
  when "grp-goods":u  then  do:
      if xlavel = 0 then  do:
      { rep/p-run3.i  {3} &b1 = temp-t-post-stk-line.goods-grp-name   &b2 = 1    {2}  }
      end.
      else do:
      { rep/p-run3.i  {3} &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2}  }
      end.
  end.
End case.
End procedure.


procedure run2-0 :
CASE RetClassify :
  when "no-classify":U  then   DO: { rep/p-run3.i  {3} &f2 = "{&Select-Good-2}"  &b1 = 1  &b2 = 1  {2}                 } .  End.
  when "grp-goods":U then      DO:
  if xLavel = 0 THEN
  DO:
   { rep/p-run3.i {3} &f2 = "{&Select-Good-2}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1  {2} } .
  END.
  ELSE DO:
   { rep/p-run3.i {3} &f2 = "{&Select-Good-2}"  &b1 = {&lavel-goods-grp-name}              &b2 = 1  {2} } .
  END.
  End.
End case.
End procedure.
procedure run3-0 :
CASE RetClassify :
when "no-classify":U  then   DO: { rep/p-run3.i  {3} &f3 = "{&Select-Good-3}"  &b1 = 1  &b2 = 1  {2} } .                        End.
when "grp-goods":U then      DO:
if xLavel = 0 THEN  DO: { rep/p-run3.i  {3} &f3 = "{&Select-Good-3}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1    {2} } . End.
ELSE  DO: { rep/p-run3.i  {3} &f3 = "{&Select-Good-3}"  &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2} } . End.
End.
End case.
End procedure.

procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
{&PUT-u1} trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
{&PutExcel} fill(" " + {&tabulation}, N - 1) trim(Name) skip.
END PROCEDURE.


procedure run45-0 :
CASE RetClassify :
when "no-classify":U  then   DO: { rep/p-run3.i  {3} &f45 = "{&Select-Good-45}"  &b1 = 1  &b2 = 1  {2} } .              End.
when "prod":U then  DO:   { rep/p-run3.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&id-prod}  &b2 = 1  {2} }  End.
when "grp-goods":U then      DO:
if xLavel = 0 THEN  DO: { rep/p-run3.i  {3} &f45 = "{&Select-Good-45}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1    {2} } .  End.
ELSE  DO: { rep/p-run3.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2} } .  End.
End.
End case.
End procedure.
/* $Workfile$ e n d */