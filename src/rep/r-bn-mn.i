/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Шальнев Иван Сергеевич
Дата создания: 13/08/10
Author: Svetlana Chernova
Creation date: 13/08/10

Дата создания: 13/08/10
*/

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ rep/r-defpst.i {1} }
{ rep/f-fdec.i       }
{ rep/f-flav.i       }
{ gbl/waitfram.i }

define variable ii like i init 0 no-undo .
define variable t#cat-id like ub.stk-line.cat-id no-undo .
define variable t#Sum-type like ub.stk-line.Sum-type no-undo .
define variable t#kol-rec-obj like i init 0  no-undo .




for each obj-list no-lock :
  t#kol-rec-obj = t#kol-rec-obj + 1.
End.


  Case Select-Good :
    when {&g-all}  then    RUN Run1.
    when {&g-grp}  then    run run2.
    when {&g-prod} then    run run3.
    otherwise do:
      run run45.
    end.
  End case.

procedure run1 :
CASE RetClassify :
  when "no-classify":U then  DO:
    { rep/p-run-bn.i  {3} &b1 = 1  &b2 = 1  {2} &page-object = {4} }
  End.
  when "grp-goods":U  then     DO:
      { rep/p-run-bn.i  {3} &b1 = tmp-itog.tmp-goods-grp-name   &b2 = 1    {2}  &page-object = {4} }
  End.
  when "prod":U then  DO:
    { rep/p-run-bn.i  {3} &b1 = {&id-prod1}  &b2 = 1  {2}  &page-object = {4} }
  End.
  when "post":U  then       DO:
      { rep/p-run-bn.i  {3} &b1 = tmp-itog.tmp-clients-grp-name   &b2 = 1  {2}  &page-object = {4} }
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &b1 = tmp-itog.tmp-clients-grp-name   &b2 = tmp-itog.tmp-goods-grp-name    {2}  &page-object = {4} } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run-bn.i  {3} &b1 = tmp-itog.tmp-goods-grp-name     &b2 = tmp-itog.tmp-clients-grp-name    {2} &page-object = {4} } .
  End.
  when "prod/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &b1 = {&id-prod1}   &b2 = tmp-itog.tmp-goods-grp-name  {2}  &page-object = {4} } .
  End.
  when "grp-goods/prod":U then DO:
    { rep/p-run-bn.i  {3} &b1 = tmp-itog.tmp-goods-grp-name  &b2 = {&id-prod1}  {2}  &page-object = {4} } .
  End.
End case.
End procedure.
procedure run2 :
CASE RetClassify :
  when "no-classify":U  then   DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = 1  &b2 = 1  {2}  &page-object = {4} } .
  End.
  when "grp-goods":U then      DO:
      { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = 1  {2}  &page-object = {4} } .
  End.
  when "prod":U then  DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"     &b1 ={&id-prod1}  &b2 = 1  {2}  &page-object = {4} }
  End.
  when "post":U  then          DO:
      { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = tmp-itog.tmp-clients-grp-name   &b2 = 1  {2}  &page-object = {4} } .
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = tmp-itog.tmp-clients-grp-name &b2 = tmp-itog.tmp-goods-grp-name {2}  &page-object = {4} } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = tmp-itog.tmp-goods-grp-name   &b2 = tmp-itog.tmp-clients-grp-name {2}  &page-object = {4} } .
  End.
  when "prod/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = {&id-prod1}   &b2 = tmp-itog.tmp-goods-grp-name  {2}  &page-object = {4} } .
  End.
  when "grp-goods/prod":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-2}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = {&id-prod1}  {2}  &page-object = {4} } .
  End.
End case.

End procedure.
procedure run3 :
CASE RetClassify :
  when "no-classify":U  then   DO:
     { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = 1  &b2 = 1  {2} &page-object = {4} } .
  End.
  when "grp-goods":U then      DO:
       { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = 1    {2}  &page-object = {4} } .
  End.
  when "prod":U then  DO:
    { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = {&id-prod1}  &b2 = 1  {2} &page-object = {4} }
  End.
  when "post":U  then          DO:
      { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = tmp-itog.tmp-clients-grp-name   &b2 = 1 {2} &page-object = {4} } .
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = tmp-itog.tmp-clients-grp-name  &b2 = tmp-itog.tmp-goods-grp-name {2} &page-object = {4} } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run-bn.i  {3} &f3 = "{&Select-Good-3}"  &b1 = tmp-itog.tmp-goods-grp-name    &b2 = tmp-itog.tmp-clients-grp-name {2} &page-object = {4} } .
  End.
  when "prod/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-3}"  &b1 = {&id-prod1}   &b2 = tmp-itog.tmp-goods-grp-name  {2}  &page-object = {4} } .
  End.
  when "grp-goods/prod":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-3}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = {&id-prod1}  {2}  &page-object = {4} } .
  End.
End case.
End procedure.
procedure run45 :
CASE RetClassify :
  when "no-classify":U  then   DO:
    { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = 1  &b2 = 1  {2} &page-object = {4} } .
  End.
  when "prod":U then  DO:
    { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&id-prod1}  &b2 = 1  {2} &page-object = {4} }
  End.
  when "grp-goods":U then      DO:
      { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = 1    {2} &page-object = {4} } .
  End.
  when "post":U  then          DO:
      { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = "(tmp-itog.tmp-cli-type + string(tmp-itog.tmp-cli-code))"   &b2 = 1 {2}  &page-object = {4} } .
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = "(tmp-itog.tmp-cli-type + string(tmp-itog.tmp-cli-code))"   &b2 = tmp-itog.tmp-goods-grp-name  {2} &page-object = {4} } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run-bn.i  {3} &f45 = "{&Select-Good-45}"  &b1 = tmp-itog.tmp-goods-grp-name   &b2 = "(tmp-itog.tmp-cli-type + string(tmp-itog.tmp-cli-code))" {2} &page-object = {4} } .
  End.
  when "prod/grp-goods":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-45}"  &b1 = {&id-prod1}   &b2 = tmp-itog.tmp-goods-grp-name  {2}  &page-object = {4} } .
  End.
  when "grp-goods/prod":U then DO:
    { rep/p-run-bn.i  {3} &f2 = "{&Select-Good-45}"  &b1 = tmp-itog.tmp-goods-grp-name  &b2 = {&id-prod1}  {2}  &page-object = {4} } .
  End.
End case.
End procedure.


procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
{&PUT-u1} trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
{&PutExcel} fill(" " + {&tabulation}, N - 1) trim(Name) skip.
END PROCEDURE.
/* $Workfile$ e n d */