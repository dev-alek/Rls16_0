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

RS = shop
 аргументы i файла
{1} - r-b или rubl
{2} legacy-obj или dis-obj

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF NOT TOTALONLY then do:
  if FIRST-of({2}.d-card) AND bsj-cards.obj-qnty  < 0 then do:
    if not first( {2}.d-card ) then do:
    {&underline}
    end.
    {&down}
    DISPLAY STREAM PrnLibStream
    {2}.d-card @ dis-obj.d-card
    bsj-cards.cli-name @ sj-cards.cli-name
    bsj-cards.d-pcntchr @ for-d-pcnt
    bsj-cards.tot @ TotalSum
    bsj-cards.disc @ DiscSum
    bsj-cards.netto @ NettoSum
    bsj-cards.instant-pay  @ InstantPaySum
    bsj-cards.credit-pay  @ CreditSum
    bsj-cards.pay @ PaySumStr
    bsj-cards.saldo @ SaldoSUmStr
    bsj-cards.must-pay @ MustPayStr
    bsj-cards.num-chk  @ dis-obj.num-chk
    with frame X123 .
    {&down}
  end.

END. /*IF NOT TOTALONLY*/

IF FIRST-oF({2}.d-card) then do:
  ACCUMULATE
  bsj-cards.d-card (COUNT)
  bsj-cards.num-chk (TOTAL)
  bsj-cards.tot (TOTAL)
  bsj-cards.disc (TOTAL)
  bsj-cards.netto (TOTAL)
  bsj-cards.instant-pay (TOTAL)
  bsj-cards.credit-pay (TOTAL)
  bsj-cards.pay (TOTAL)
  bsj-cards.saldo (TOTAL)
  bsj-cards.must-pay (TOTAL)
  bsj-cards.num-chk (TOTAL)
  .
END.

IF NOT TOTALONLY then do:
assign
PaySUmStr = (IF BSJ-CARDS.OBJ-QNTY >= 0
          THEN STRING(bsj-cards.pay, "->>>,>>>,>>9.99")
          ELSE "")
MustPayStr = (IF BSJ-CARDS.OBJ-QNTY >= 0
          THEN STRING(bsj-cards.Must-Pay, "->>>,>>>,>>9.99")
          ELSE "")
SaldoSumStr = (IF BSJ-CARDS.OBJ-QNTY >= 0
          THEN STRING(bsj-cards.saldo, "->>>,>>>,>>9.99")
          ELSE "")
.
&if "{2}" = "legacy-obj" &then
DISPLAY STREAM PrnLibStream
(if bsj-cards.obj-qnty > 0 then bsj-cards.d-card else "") @ dis-obj.d-card
legacy-obj.obj-code @ dis-obj.obj-code
(if bsj-cards.obj-qnty > 0 then bsj-cards.cli-name else "" ) /*bsj-cards.cli-name*/ @ sj-cards.cli-name
(if bsj-cards.obj-qnty > 0 then bsj-cards.d-pcntchr else "") @ for-d-pcnt
legacy-obj.gds-tot-{1} @ TotalSum
legacy-obj.gds-dis-{1} @ DiscSum
(legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) @ NettoSum
legacy-obj.pay-tot-{1} @ InstantPaySum
(legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1} - legacy-obj.pay-tot-{1}) @ CreditSum
PaySUmStr
SaldoSUmstr
MustPayStr
legacy-obj.num-chk @ dis-obj.num-chk
with frame X123 .

&else

DISPLAY STREAM PrnLibStream
(if bsj-cards.obj-qnty > 0 then bsj-cards.d-card else "") @ dis-obj.d-card
dis-obj.obj-code
(if bsj-cards.obj-qnty > 0 then bsj-cards.cli-name else "" ) @ sj-cards.cli-name
(if bsj-cards.obj-qnty > 0 then bsj-cards.d-pcntchr else "") @ for-d-pcnt
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
&endif

{&down}

if last-of({2}.d-card) AND bsj-cards.obj-qnty  < 0 then do:
  if last( {2}.d-card ) then do:
    {&underline}
  end.
  {&down}
end.
else do:
  if last( {2}.d-card ) then do:
    {&underline}
    {&down}
  end.
end.

END. /*IF NOT TOTALONLY*/

if last({2}.d-card) then do:
  FIND FIRST sj-cards where sj-cards.d-card = ? NO-ERROR.
  /*
  assign
  PaySUmStr = (IF num-objs = 1
            THEN STRING(ACCUM TOTAL bsj-cards.pay, "->>>,>>>,>>9.99")
            ELSE "")
  MustPayStr = (IF num-objs = 1
            THEN STRING(ACCUM TOTAL bsj-cards.Must-Pay, "->>>,>>>,>>9.99")
            ELSE "")
  SaldoSumStr = (IF num-objs = 1
            THEN STRING(ACCUM TOTAL bsj-cards.saldo, "->>>,>>>,>>9.99")
            ELSE "")
  .
  */
  assign
  PaySUmStr = STRING(ACCUM TOTAL bsj-cards.pay, "->>>,>>>,>>9.99")
  MustPayStr = STRING(ACCUM TOTAL bsj-cards.Must-Pay, "->>>,>>>,>>9.99")
  SaldoSumStr = STRING(ACCUM TOTAL bsj-cards.saldo, "->>>,>>>,>>9.99")
  .

/*  {&underline}*/
/*  {&down}*/
  DISPLAY STREAM PrnLibStream
  "ИТОГО" @ dis-obj.d-card
  (string(ACCUM COUNT bsj-cards.d-card) + " карт") @ sj-cards.cli-name
  "" @ for-d-pcnt
  ACCUM TOTAL bsj-cards.tot  @ TotalSum
  ACCUM TOTAL bsj-cards.disc  @ DiscSum
  ACCUM TOTAL bsj-cards.netto  @ NettoSum
  ACCUM TOTAL bsj-cards.instant-pay @ InstantPaySum
  ACCUM TOTAL bsj-cards.credit-pay  @ CreditSum
  PaySUmStr
  SAldoSUmStr
  MustPayStr
  ACCUM TOTAL bsj-cards.num-chk @ dis-obj.num-chk
  with frame X123 .
  {&underline}
end.


/* $Workfile$ e n d */