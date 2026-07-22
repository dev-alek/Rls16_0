/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общая часть отчетов по архивам поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

Дата создания: 08/16/01
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

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable ii like i init 0 no-undo .
define variable t#cat-id like stk-line.cat-id no-undo .
define variable t#Sum-type like stk-line.Sum-type no-undo .
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
  when 1 then  do:
    Assign
      t#cat-id   = {&single-cat-id}
      t#sum-type = {&arh-cost}  .
  end.
  when 2 then do:
    Assign
      t#cat-id   = {&arh-repayment}
      t#sum-type = {&arh-cost} + {&arh-supp} .
  end.
  when 3 then do:
    Assign
      t#cat-id   = {&arh-cons_acc}
      t#sum-type = {&arh-cost} + {&arh-supp} .
  end.
  when 4 then do:
    Assign
      t#cat-id   = {&arh-resp_stor}
      t#sum-type = {&arh-cost} + {&arh-supp} .
  end.
  when 5 then do:
    Assign
      t#cat-id   = {&arh-old_cons}
      t#sum-type = {&arh-cost} + {&arh-supp} .
  end.
End case.

if xTogobj = false  then DO:
  Case Select-Good :
    when {&g-all}   then    RUN Run1-0.
    when {&g-grp}   then    run run2-0.
    when {&g-prod}  then    run run3-0.
    otherwise do:
        run run45-0.
    end.
  End case.
End.
Else do:
  Case Select-Good :
    when {&g-all}  then    RUN Run1.
    when {&g-grp}  then    run run2.
    when {&g-prod} then    run run3.
    otherwise do:
      run run45.
    end.
  End case.
End.

procedure run1 :
CASE RetClassify :
  when "no-classify":U then  DO:
    { rep/p-run1.i  {3} &b1 = 1  &b2 = 1  {2}   }
  End.
  when "grp-goods":U  then     DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &b1 = temp-t-post-stk-line.goods-grp-name   &b2 = 1    {2}   }
    End.
    Else DO:
      { rep/p-run1.i  {3} &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2}   }
    End.
  End.
  when "prod":U then  DO:
    { rep/p-run1.i  {3} &b1 = {&id-prod}  &b2 = 1  {2}  }
  End.
  when "post":U  then       DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &b1 = temp-t-post-stk-line.clients-grp-name   &b2 = 1  {2}   }
    End.
    Else DO:
      { rep/p-run1.i  {3} &b1 = {&lavel-clients-grp-name}  &b2 = 1    {2}   }
    End.
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run1.i  {3} &b1 = temp-t-post-stk-line.clients-grp-name   &b2 = temp-t-post-stk-line.goods-grp-name    {2}   } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run1.i  {3} &b1 = temp-t-post-stk-line.goods-grp-name     &b2 = temp-t-post-stk-line.clients-grp-name    {2}  } .
  End.
End case.
End procedure.
procedure run2 :
CASE RetClassify :
  when "no-classify":U  then   DO:
    { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = 1  &b2 = 1  {2}                 } .
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1    {2}    } .
    END.
    ELSE  DO:
      { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2}   } .
    END.
  End.
  when "prod":U then  DO:
    { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"     &b1 ={&id-prod}  &b2 = 1  {2}  }
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = temp-t-post-stk-line.clients-grp-name   &b2 = 1  {2}   } .
    End.
    ELSE  DO: { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = {&lavel-clients-grp-name}  &b2 = 1  {2}   } .
    End.
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = temp-t-post-stk-line.clients-grp-name &b2 = temp-t-post-stk-line.goods-grp-name {2}   } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run1.i  {3} &f2 = "{&Select-Good-2}"  &b1 = temp-t-post-stk-line.goods-grp-name   &b2 = temp-t-post-stk-line.clients-grp-name {2}   } .
  End.
End case.

End procedure.
procedure run3 :
CASE RetClassify :
  when "no-classify":U  then   DO:
     { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = 1  &b2 = 1  {2}  } .
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
       { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1    {2}  } .
    End.
    ELSE  DO:
      { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = {&lavel-goods-grp-name}  &b2 = 1    {2}  } .
    End.
  End.
  when "prod":U then  DO:
    { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = {&id-prod}  &b2 = 1  {2}  }
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = temp-t-post-stk-line.clients-grp-name   &b2 = 1 {2}  } .
    End.
    ELSE  DO:
      { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = {&lavel-clients-grp-name}   &b2 = 1 {2}  } .
    End.
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = temp-t-post-stk-line.clients-grp-name  &b2 = temp-t-post-stk-line.goods-grp-name {2}  } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run1.i  {3} &f3 = "{&Select-Good-3}"  &b1 = temp-t-post-stk-line.goods-grp-name    &b2 = temp-t-post-stk-line.clients-grp-name {2}  } .
  End.
End case.
End procedure.
procedure run45 :
CASE RetClassify :
  when "no-classify":U  then   DO:
    { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = 1  &b2 = 1  {2}  } .
  End.
  when "prod":U then  DO:
    { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&id-prod}  &b2 = 1  {2}  }
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = temp-t-post-stk-line.goods-grp-name  &b2 = 1    {2}  } .
    End.
    ELSE  DO:
      { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&lavel-goods-grp-name}  &b2 = 1 {2}  } .
    End.
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
      { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = "(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))"   &b2 = 1 {2}   } .
    End.
    ELSE  DO:
      { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = {&lavel-clients-grp-name}  &b2 = 1 {2}  } .
    End.
  End.
  when "post/grp-goods":U then DO:
    { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = "(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))"   &b2 = temp-t-post-stk-line.goods-grp-name  {2}  } .
  End.
  when "grp-goods/post":U then DO:
    { rep/p-run1.i  {3} &f45 = "{&Select-Good-45}"  &b1 = temp-t-post-stk-line.goods-grp-name   &b2 = "(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))" {2}  } .
  End.
End case.
End procedure.


procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
{&PUT-u1} trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
{&PutExcel} fill(" " + {&tabulation}, N - 1) trim(Name) skip.
END PROCEDURE.

procedure run1-0 :
 { rep/p-run2.i  {3} &b1 = 1  &b2 = 1  {2} }
End procedure.


procedure run2-0 :
 { rep/p-run2.i  {3} &f2 = "{&Select-Good-2}"  &b1 = 1  &b2 = 1  {2} }
End procedure.


procedure run3-0 :
 { rep/p-run2.i  {3} &f3 = "{&Select-Good-3}"  &b1 = 1  &b2 = 1  {2} }
End procedure.


procedure run45-0 :
 { rep/p-run2.i  {3} &f45 = "{&Select-Good-45}"  &b1 = 1  &b2 = 1  {2} }
End procedure.
/* $Workfile$ e n d */