/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

внутренность цикла печати для отчета итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

RS = sum  single

 аргументы i файла
{1} - r-b или rubl
{2} dis-obj или legacy-obj

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if t-legacy or t-subsid
then
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


else
ACCUMULATE
ub.dis-obj.d-card (COUNT BY {2}.obj-code)
ub.dis-obj.num-chk (TOTAL BY {2}.obj-code)
(ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) (TOTAL BY {2}.obj-code)
(ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1}) (TOTAL BY {2}.obj-code)
((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
(ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1})
) (TOTAL BY {2}.obj-code)
 ub.dis-obj.pay-tot-{1} (TOTAL BY {2}.obj-code)
((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
 (ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1}) -
 ub.dis-obj.pay-tot-{1}) (TOTAL BY {2}.obj-code)
ub.dis-obj.num-chk (TOTAL BY {2}.obj-code)
.

IF NOT TOTALONLY then do:

assign
PaySUmStr = string(bsj-cards.pay, "->>>,>>>,>>9.99")
MustPayStr = STRING(bsj-cards.Must-Pay, "->>>,>>>,>>9.99")
SaldoSumStr = STRING(bsj-cards.saldo, "->>>,>>>,>>9.99")
.
if t-legacy or t-subsid
then
DISPLAY STREAM PrnLibStream
bsj-cards.d-card @ dis-obj.d-card
legacy-obj.obj-code @ dis-obj.obj-code
bsj-cards.cli-name @ sj-cards.cli-name
bsj-cards.d-pcntchr @ for-d-pcnt
bsj-cards.tot @ TotalSum
bsj-cards.disc @ DiscSum
bsj-cards.netto @ NettoSum
bsj-cards.instant-pay @ InstantPaySum
bsj-cards.credit-pay  @ CreditSum
PaySUmStr
SaldoSUmstr
MustPayStr
bsj-cards.num-chk @ dis-obj.num-chk
with frame X123 .


else
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
dis-obj.num-chk
with frame X123 .

{&down}


END. /*IF NOT TOTALONLY*/

if last({2}.obj-code) then do:
  FIND FIRST sj-cards where sj-cards.d-card = ? NO-ERROR.
  {&underline}
  {&down}
  if t-legacy
  or t-subsid
  then
  DISPLAY STREAM PrnLibStream
  "ИТОГО" @ dis-obj.d-card
  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name
  ACCUM TOTAL (bsj-cards.tot) @ TotalSum
  ACCUM TOTAL (bsj-cards.disc) @ DiscSum
  ACCUM TOTAL (bsj-cards.netto)  @ NettoSum
  ACCUM TOTAL (bsj-cards.instant-pay) @ InstantPaySum
  ACCUM TOTAL (bsj-cards.credit-pay) @ CreditSum
  ACCUM TOTAL (bsj-cards.num-chk) @ dis-obj.num-chk
  sj-cards.pay @ PaySumStr
  sj-cards.Must-pay @ MustPayStr
  sj-cards.saldo @ SaldoSumStr
  with frame X123 .


  else
  DISPLAY STREAM PrnLibStream
  "ИТОГО" @ dis-obj.d-card
  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name
  ACCUM TOTAL (dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) @ TotalSum
  ACCUM TOTAL (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) @ DiscSum
  ACCUM TOTAL
  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -
   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}))  @ NettoSum
  ACCUM TOTAL dis-obj.pay-tot-{1} @ InstantPaySum
  ACCUM TOTAL
  ((dis-obj.gds-tot-{1} + dis-obj.sum-tot-{1}) -
   (dis-obj.gds-dis-{1} + dis-obj.sum-dis-{1}) -
    dis-obj.pay-tot-{1}) @ CreditSum
  ACCUM TOTAL dis-obj.num-chk @ dis-obj.num-chk
  string(sj-cards.pay,      "->>>,>>>,>>9.99") @ PaySumStr
  string(sj-cards.Must-pay, "->>>,>>>,>>9.99") @ MustPayStr
  string(sj-cards.saldo,    "->>>,>>>,>>9.99") @ SaldoSumStr
  with frame X123 .

  {&underline}
end.






/* $Workfile$ e n d */