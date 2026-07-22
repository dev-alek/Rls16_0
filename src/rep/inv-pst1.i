/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/17/03 2:38

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  assign Lines_Counter = Lines_Counter + 1  .

  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.

  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .

  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    p-sum-a-qnty    = p-sum-a-qnty    + temp-str.a-qnty
    p-sum-b-qnty    = p-sum-b-qnty    + temp-str.b-qnty
    p-sum-a-qnty1   = p-sum-a-qnty1   + temp-str.a-qnty1
    p-sum-b-qnty1   = p-sum-b-qnty1   + temp-str.b-qnty1
    p-sum-a-stoim   = p-sum-a-stoim   + temp-str.a-stoim
    p-sum-b-stoim   = p-sum-b-stoim   + temp-str.b-stoim
    p-sum-ubl       = p-sum-ubl       + temp-str.ubl

    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
  .

  /* полное название на несколько строк */
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END. /* DO WHILE ... */
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.

  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).

if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    &if "{1}" = "invent"                  &then sym8 sym11   temp-str.price-befor temp-str.Price-after  &endif
    &if "{1}" = "invent-gold"             &then sym8 sym11   temp-str.price-befor temp-str.Price-after  &endif
    &if "{1}" = "sl" or "{1}" = "sl-gold" &then sym14 temp-str.UBL                &endif
    &if "{1}" = "sl-gold"                 &then sym8 sym11  sym15 UBL-v           &endif
    &if "{1}" = "invent-gold"             &then temp-str.a-qnty1 temp-str.b-qnty1 &endif
    &if "{1}" = "sl-gold"                 &then temp-str.a-qnty1 temp-str.b-qnty1 &endif
    sym7     temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym10    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym13
     with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1} .

  if print-graft = false THEN  Put stream Out-Stream LineBuf format "{2}" SKIP.
end.

/* $Workfile$ e n d */