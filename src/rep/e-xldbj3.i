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


RS = group
 аргументы i файла
{1} - r-b или rubl
{2} legacy-obj иди dis-obj

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if first-of({2}.obj-code) AND num-objs > 1 then do:
/*  if first({2}.obj-code) then do:*/
/*    {&underline}*/
/*    {&down}*/
/*  end.*/
  FIND FIRST ub.clients No-LOCK WHERE
              ub.clients.obj-type = obj-list.obj-type AND
              ub.clients.obj-code = obj-list.obj-code NO-ERROR.
  DISPLAY STREAM PrnLibStream
  "Магазин" @ ub.dis-obj.d-card
  {2}.obj-code @ ub.dis-obj.obj-code
  ub.clients.obj-name @ sj-cards.cli-name
  WITH FRAME X123.
  {&underline}
  {&down}
end.
if first-of(bsj-cards.g-code) then do:
  FIND FIRST sj-groups No-LOCK WHERE
             sj-groups.g-code = bsj-cards.g-code AND
             sj-groups.obj-code = {2}.obj-code NO-ERROR.
  DISPLAY STREAM PrnLibStream
  "Группа" @ ub.dis-obj.d-card
  sj-groups.g-name @ sj-cards.cli-name
  WITH FRAME X123.
  {&underline}
  {&down}
end.

if t-legacy or t-subsid
then do:
  ACCUMULATE
  bsj-cards.d-card (COUNT BY {2}.obj-code )
  bsj-cards.num-chk (TOTAL BY {2}.obj-code)
  bsj-cards.tot (TOTAL BY {2}.obj-code )
  bsj-cards.disc (TOTAL BY {2}.obj-code )
  bsj-cards.netto (TOTAL BY {2}.obj-code )
  bsj-cards.instant-pay (TOTAL BY {2}.obj-code )
  bsj-cards.credit-pay (TOTAL BY {2}.obj-code  )
  .

  ACCUMULATE
  legacy-obj.d-card (COUNT BY bsj-cards.g-code )
  legacy-obj.num-chk (TOTAL BY bsj-cards.g-code  )
  legacy-obj.gds-tot-{1} (TOTAL BY bsj-cards.g-code )
  legacy-obj.gds-dis-{1} (TOTAL BY bsj-cards.g-code  )
  (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) (total BY  bsj-cards.g-code )
  legacy-obj.pay-tot-{1} (TOTAL BY bsj-cards.g-code  )
  ((legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) - legacy-obj.pay-tot-{1}) (TOTAL BY bsj-cards.g-code  )
  .

end.
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

.

IF NOT TOTALONLY then do:

if t-legacy or t-subsid /*and last-of({2}.d-card */  then do:

  DISPLAY STREAM PrnLibStream
  legacy-obj.d-card @ ub.dis-obj.d-card
  legacy-obj.obj-code @ ub.dis-obj.obj-code
  bsj-cards.cli-name @ sj-cards.cli-name
  legacy-obj.d-pcntchr @ for-d-pcnt
  legacy-obj.gds-tot-{1} @ TotalSum
  legacy-obj.gds-dis-{1} @ DiscSum
  (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) @ NettoSum
  legacy-obj.pay-tot-{1} @ InstantPaySum
  (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1} - legacy-obj.pay-tot-{1})  @ CreditSum
  PaySUmStr
  SaldoSUmstr
  MustPayStr
  bsj-cards.num-chk @ ub.dis-obj.num-chk
  with frame X123 .
end.

else
DISPLAY STREAM PrnLibStream
ub.dis-obj.d-card
ub.dis-obj.obj-code
bsj-cards.cli-name @ sj-cards.cli-name
bsj-cards.d-pcntchr @ for-d-pcnt
(if t-legacy or t-subsid
then bsj-cards.tot
else (ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}))  @ TotalSum
(ub.dis-obj.gds-dis-{1} +  ub.dis-obj.sum-dis-{1}) @ DiscSum
((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
 (ub.dis-obj.gds-dis-{1} +  ub.dis-obj.sum-dis-{1})) @ NettoSum
 ub.dis-obj.pay-tot-{1} @ InstantPaySum
((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
 (ub.dis-obj.gds-dis-{1} +  ub.dis-obj.sum-dis-{1}) -
  ub.dis-obj.pay-tot-{1}
)  @ CreditSum
PaySUmStr
SaldoSUmstr
MustPayStr
ub.dis-obj.num-chk
with frame X123 .

{&down}


END. /*IF NOT TOTALONLY*/

if last-of(bsj-cards.g-code) then do:
  FIND FIRST sj-groups No-LOCK WHERE
             sj-groups.g-code = bsj-cards.g-code AND
             sj-groups.obj-code = {2}.obj-code NO-ERROR.
  {&underline}
  {&down}
  if t-legacy or t-subsid then
  DISPLAY STREAM PrnLibStream
  "ИТОГО по группе" @ ub.dis-obj.d-card
  sj-groups.g-name @ sj-cards.cli-name
  ACCUM TOTAL by bsj-cards.g-code (legacy-obj.gds-tot-{1}) @ TotalSum
  ACCUM TOTAL by bsj-cards.g-code (legacy-obj.gds-dis-{1}) @ DiscSum
  ACCUM TOTAL by bsj-cards.g-code (legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) @ NettoSum
  ACCUM TOTAL by bsj-cards.g-code (legacy-obj.pay-tot-{1}) @ InstantPaySum
  ACCUM TOTAL by bsj-cards.g-code ((legacy-obj.gds-tot-{1} - legacy-obj.gds-dis-{1}) - legacy-obj.pay-tot-{1}) @ CreditSum
  ACCUM TOTAL by bsj-cards.g-code (legacy-obj.num-chk) @ ub.dis-obj.num-chk
  with frame X123 .


  else
  DISPLAY STREAM PrnLibStream
  "ИТОГО по группе" @ ub.dis-obj.d-card
  sj-groups.g-name @ sj-cards.cli-name
  sj-groups.tot @ TotalSum
  sj-groups.disc @ DiscSum
  sj-groups.netto @ NettoSum
  sj-groups.instant-pay @ CreditSum
  sj-groups.credit-pay @ CreditSum
  sj-groups.num-chk @ ub.dis-obj.num-chk
  with frame X123 .
  if num-objs <= 1 then do:
    {&underline}
    {&down}
  end.
end.

if last-of({2}.obj-code) AND num-objs > 1 then do:
  {&underline}
  {&down}

  if t-legacy or t-subsid
  then
  DISPLAY STREAM PrnLibStream
  "ИТОГО по маг-ну" @ ub.dis-obj.d-card
  (string(ACCUM COUNT by {2}.obj-code bsj-cards.d-card) + " карт ") @ sj-cards.cli-name
  "" @ for-d-pcnt
  ACCUM TOTAL by {2}.obj-code (bsj-cards.tot) @ TotalSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.disc) @ DiscSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.netto) @ NettoSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.instant-pay) @ InstantPaySum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.credit-pay) @ CreditSum
  ACCUM TOTAL by {2}.obj-code (bsj-cards.num-chk) @ ub.dis-obj.num-chk
  with frame X123 .

  else
  DISPLAY STREAM PrnLibStream
  "ИТОГО по маг-ну" @ ub.dis-obj.d-card
  (string(ACCUM COUNT by {2}.obj-code ub.dis-obj.d-card) + " карт ") @ sj-cards.cli-name
  "" @ for-d-pcnt
  ACCUM TOTAL by {2}.obj-code (ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) @ TotalSum
  ACCUM TOTAL by {2}.obj-code (ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1}) @ DiscSum
  ACCUM TOTAL by {2}.obj-code
  ((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
   (ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1}))  @ NettoSum
  ACCUM TOTAL by {2}.obj-code ub.dis-obj.pay-tot-{1} @ InstantPaySum
  ACCUM TOTAL by {2}.obj-code
  ((ub.dis-obj.gds-tot-{1} + ub.dis-obj.sum-tot-{1}) -
   (ub.dis-obj.gds-dis-{1} + ub.dis-obj.sum-dis-{1}) -
    ub.dis-obj.pay-tot-{1}) @ CreditSum
  ACCUM TOTAL by {2}.obj-code ub.dis-obj.num-chk @ ub.dis-obj.num-chk
  with frame X123 .

  {&underline}
  {&down}
end.

If last({2}.obj-code) /*and num-objs > 1*/ then do:
/*  {&underline}*/
/*  {&down}*/
  assign
    TotalSum = 0
    DiscSum = 0
    NettoSum = 0
    CreditSum = 0
    InstantPaySum = 0
    CreditSum = 0
    vPaySum = 0
    vMustPay = 0
    vSaldoSUm = 0
    vnum-chk = 0
  .
  FOR EACH sj-groups No-LOCK WHERE
           sj-groups.obj-code = 0:
    DISPLAY STREAM PrnLibStream
    "Итого по объектам" @ ub.dis-obj.d-card
    sj-groups.g-name @ sj-cards.cli-name
    sj-groups.g-name @ sj-cards.cli-name
    sj-groups.tot @ TotalSum
    sj-groups.disc @ DiscSum
    sj-groups.netto @ NettoSum
    sj-groups.instant-pay @ InstantPaySum
    sj-groups.credit-pay @ CreditSum
    sj-groups.pay @ PaySumStr
    sj-groups.must-pay @  MustPayStr
    sj-groups.saldo @  SaldoSUmStr
    sj-groups.num-chk @ ub.dis-obj.num-chk
    WITH FRAME X123.
    {&down}
    assign
      TotalSum      = TotalSum      + sj-groups.tot
      DiscSum       = DiscSum       + sj-groups.disc
      NettoSum      = NettoSum      + sj-groups.netto
      InstantPaySum = InstantPaySum + sj-groups.instant-pay
      CreditSum     = CreditSum     + sj-groups.credit-pay
      vPaySum       = vPaySum       + sj-groups.pay
      vMustPay      = vMustPay      + sj-groups.must-pay
      vSaldoSUm     = vSaldoSUm     + sj-groups.saldo
      vnum-chk      = vnum-chk      + sj-groups.num-chk
    .
  END.
  {&underline}
  {&down}
END.

if last({2}.obj-code) then do:
  FIND FIRST sj-cards where sj-cards.d-card = ? NO-ERROR.
/*  {&underline}*/
/*  {&down}*/
/*  if t-legacy then*/
/*  DISPLAY STREAM PrnLibStream*/
/*  "ИТОГО" @ dis-obj.d-card*/
/*  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name*/
/*  ACCUM TOTAL bsj-cards.tot @ TotalSum*/
/*  ACCUM TOTAL bsj-cards.disc @ DiscSum*/
/*  ACCUM TOTAL bsj-cards.netto @ NettoSum*/
/*  ACCUM TOTAL bsj-cards.instant-pay @ InstantPaySum*/
/*  ACCUM TOTAL bsj-cards.credit-pay @ CreditSum*/
/*  ACCUM TOTAL bsj-cards.num-chk @ dis-obj.num-chk*/
/*  sj-cards.pay @ PaySumStr*/
/*  sj-cards.Must-pay @ MustPayStr*/
/*  sj-cards.saldo @ SaldoSumStr*/
/*  with frame X123 .*/


/*  else*/
  DISPLAY STREAM PrnLibStream
  "ИТОГО" @ ub.dis-obj.d-card
  (string(sj-cards.obj-qnty) + " карт") @ sj-cards.cli-name
  TotalSum
  DiscSum
  NettoSum
  InstantPaySum
  CreditSum
  vnum-chk @ ub.dis-obj.num-chk
  vPaySum   @ PaySumStr
  vMustPay  @ MustPayStr
  vSaldoSUm @ SaldoSumStr
  with frame X123 .

  {&underline}
end.




/* $Workfile$ e n d */