/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Внутренность цикла печати для отчета итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

RS = card
 аргументы i файла
{1} - r-b или rubl
{2} - RS-SORT

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if first-of({2}.obj-code) AND num-objs > 1 then do:
  if not first({2}.obj-code) then do:
    {&underline}
    {&down}
  end.
  FIND FIRST ub.clients No-LOCK WHERE
              ub.clients.obj-type = {&shop} AND
              ub.clients.obj-code = {2}.obj-code NO-ERROR.
  DISPLAY STREAM PrnLibStream
  "Магазин" @ ub.dis-obj.d-card
  clients.obj-name @ sj-cards.cli-name
  WITH FRAME X123.
  {&underline}
  {&down}
end.

/*if t-legacy or t-subsid*/
/*then*/
ACCUMULATE
bsj-cards.d-card (COUNT BY {2}.obj-code)
bsj-cards.num-chk (TOTAL BY {2}.obj-code)
bsj-cards.tot (TOTAL BY {2}.obj-code)
bsj-cards.disc (TOTAL BY {2}.obj-code)
bsj-cards.netto (TOTAL BY {2}.obj-code)
bsj-cards.instant-pay (TOTAL BY {2}.obj-code)
bsj-cards.credit-pay (TOTAL BY {2}.obj-code)
bsj-cards.num-chk (TOTAL BY {2}.obj-code)
.
/*else*/
/*ACCUMULATE*/
/*dis-obj.d-card (COUNT BY {2}.obj-code)*/
/*dis-obj.num-chk (TOTAL BY {2}.obj-code)*/
/*(dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) (TOTAL BY {2}.obj-code)*/
/*(dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) (TOTAL BY {2}.obj-code)*/
/*((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/*(dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1})*/
/*) (TOTAL BY {2}.obj-code)*/
/* dis-obj.pay-tot-{1} (TOTAL BY {2}.obj-code)*/
/*((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/* (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) -*/
/* dis-obj.pay-tot-{1}) (TOTAL BY {2}.obj-code)*/
/*dis-obj.num-chk (TOTAL BY {2}.obj-code)*/
/*.*/

IF NOT TOTALONLY then do:
assign
PaySUmStr = string(bsj-cards.pay, "->>>,>>>,>>9.99")
MustPayStr = STRING(bsj-cards.Must-Pay, "->>>,>>>,>>9.99")
SaldoSumStr = STRING(bsj-cards.saldo, "->>>,>>>,>>9.99")
.
&if "{2}" = "legacy-obj" &then
  DISPLAY STREAM PrnLibStream
  legacy-obj.d-card @ dis-obj.d-card
  legacy-obj.obj-code @ dis-obj.obj-code
  bsj-cards.cli-name @ sj-cards.cli-name
  (if bsj-cards.obj-qnty > 0 then bsj-cards.d-pcntchr else "") @ for-d-pcnt
  legacy-obj.gds-tot-{1} @ TotalSum
  legacy-obj.gds-dis-{1} @ DiscSum
  (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) @ NettoSum
  legacy-obj.pay-tot-{1} @ InstantPaySum
  (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}  - legacy-obj.pay-tot-{1}) @ CreditSum
  PaySUmStr
  SaldoSUmstr
  MustPayStr
  legacy-obj.num-chk @ ub.dis-obj.num-chk
  with frame X123 .
&else
DISPLAY STREAM PrnLibStream
dis-obj.d-card
dis-obj.obj-code
bsj-cards.cli-name @ sj-cards.cli-name
bsj-cards.d-pcntchr @ for-d-pcnt

(dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) @ TotalSum
(dis-obj.gds-dis-{1} +  dis-obj.sum-dis-{1}) @ DiscSum
((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -
 (dis-obj.gds-dis-{1} +  dis-obj.sum-dis-{1})) @ NettoSum
dis-obj.pay-tot-{1} @ InstantPaySum
((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -
 (dis-obj.gds-dis-{1} +  dis-obj.sum-dis-{1}) -
  dis-obj.pay-tot-{1}
)  @ CreditSum
PaySUmStr
SaldoSUmstr
MustPayStr
ub.dis-obj.num-chk
with frame X123 .
&endif

{&down}


END. /*IF NOT TOTALONLY*/

if last-of({2}.obj-code) AND num-objs > 1 then do:
  {&underline}
  {&down}

/*  if t-legacy or t-subsid*/
/*  then*/
  DISPLAY STREAM PrnLibStream
  "ИТОГО по маг-ну" @ dis-obj.d-card
  (string(ACCUM COUNT by {2}.obj-code (bsj-cards.d-card)) + " карт ") @ sj-cards.cli-name
  "" @ for-d-pcnt
  ACCUM TOTAL by {2}.obj-code (bsj-cards.tot) @ TotalSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.disc) @ DiscSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.netto)  @ NettoSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.instant-pay) @ InstantPaySum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.credit-pay) @ CreditSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.num-chk) @ ub.dis-obj.num-chk
  with frame X123 .

/*  else*/
/*  DISPLAY STREAM PrnLibStream*/
/*  "ИТОГО по маг-ну" @ dis-obj.d-card*/
/*  (string(ACCUM COUNT by {2}.obj-code dis-obj.d-card) + " карт ") @ sj-cards.cli-name*/
/*  "" @ for-d-pcnt*/
/*  ACCUM TOTAL by {2}.obj-code (dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) @ TotalSum*/
/*  ACCUM TOTAL by {2}.obj-code (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) @ DiscSum*/
/*  ACCUM TOTAL by {2}.obj-code*/
/*  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/*   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}))  @ NettoSum*/
/*  ACCUM TOTAL by {2}.obj-code dis-obj.pay-tot-{1} @ InstantPaySum*/
/*  ACCUM TOTAL by {2}.obj-code*/
/*  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/*   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) -*/
/*    dis-obj.pay-tot-{1}) @ CreditSum*/
/*  ACCUM TOTAL by {2}.obj-code dis-obj.num-chk @ dis-obj.num-chk*/
/*  with frame X123 .*/
  if last( {2}.obj-code ) then do:
    {&underline}
    {&down}
  end.
end.

if last({2}.obj-code) then do:
  FIND FIRST sj-cards where sj-cards.d-card = ? NO-ERROR.
/*  {&underline}*/
/*  {&down}*/

/*  if t-legacy or t-subsid then*/
  DISPLAY STREAM PrnLibStream
  "ИТОГО" @ dis-obj.d-card
  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name
  ACCUM TOTAL by {2}.obj-code (bsj-cards.tot) @ TotalSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.disc) @ DiscSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.netto)  @ NettoSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.instant-pay) @ InstantPaySum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.credit-pay) @ CreditSum
  sj-cards.pay @ PaySumStr
  sj-cards.Must-pay @ MustPayStr
  sj-cards.saldo @ SaldoSumStr
  ACCUM TOTAL bsj-cards.num-chk   @ ub.dis-obj.num-chk
  with frame X123 .

/*  else*/
/*  DISPLAY STREAM PrnLibStream*/
/*  "ИТОГО" @ dis-obj.d-card*/
/*  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name*/
/*  ACCUM TOTAL (dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) @ TotalSum*/
/*  ACCUM TOTAL (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) @ DiscSum*/
/*  ACCUM TOTAL*/
/*  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/*   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1})) @ NettoSum*/
/*  ACCUM TOTAL  dis-obj.pay-tot-{1} @ InstantPaySum*/
/*  ACCUM TOTAL*/
/*  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -*/
/*   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) -*/
/*    dis-obj.pay-tot-{1}) @ CreditSum*/
/*  ACCUM TOTAL dis-obj.num-chk @ dis-obj.num-chk*/
/*  sj-cards.pay format "->>>,>>>,>>9.99" @ PaySumStr*/
/*  sj-cards.Must-pay format "->>>,>>>,>>9.99" @ MustPayStr*/
/*  sj-cards.saldo format "->>>,>>>,>>9.99" @ SaldoSumStr*/
/*  with frame X123 .*/

  {&underline}
end.
/* $Workfile$ e n d */