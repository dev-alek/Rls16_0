/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать тела inv-8

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DO:
  assign Lines_Counter = Lines_Counter + 1  .

  if line-counter( out-stream ) + 9 > page-size( out-stream ) then do:
     display stream Out-Stream
        Line format {&format-inv-gold} AT 1
        String("Итого"
               + sym6
               + String(PgQnty ,     "->>>>>>>>9.999"    )
               + sym7
               + "               "
               + sym8
               + String(PgWeight ,   "->>>>>>>>>9.999"    )
               + sym9
               + String(PgQntyBuh,   "->>>>>>>>9.999"     )
               + sym10
               + "               "
               + sym11
               + String(PgWeightBuh, "->>>>>>>>>9.999" )
               + sym12)  at 84 Format "x(100)"
               skip
        "Итого по странице : " skip
        "а) количество порядковых номеров "           AT 18 "(" STRING(PgNPP)    ")" f-wp-qnty (decimal(PgNPP)) FORMAT "x(90)"   SKIP
        "б) общее количество единиц фактически "      AT 18 "(" STRING(PgQnty)   ")" f-wp-qnty (decimal(PgQnty)) FORMAT "x(90)"   SKIP
        "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
        "лигатурная "                                 AT 25 "(" STRING(PgWeight) ")" f-wp-qnty (decimal(PgWeight)) FORMAT "x(90)"  SKIP
        "чистая "                                     AT 25                               SKIP
     with FRAME PageFrame width {&DOS_CW_2} NO-LABELS NO-BOX .
     DOWN stream Out-Stream 1 with FRAME PageFrame.
     page stream out-stream.
  end.

  if line-counter( Out-Stream ) < Tmp_Counter then DO:
     assign
        PgNPP       = 0
        PgQnty      = 0
        PgWeight    = 0
        PgQntyBuh   = 0
        PgWeightBuh = 0
     .
  END.

  assign
    Tmp_Counter     = line-counter( Out-Stream )
    PgNPP           = PgNPP           + 1
    PgQnty          = PgQnty          + temp-str.qntyFact
    PgQntyBuh       = PgQntyBuh       + temp-str.qntyBuh
    PgWeight        = PgWeight        + temp-str.weightItem * temp-str.qntyFact
    PgWeightBuh     = PgWeightBuh     + temp-str.weightItem * temp-str.qntyBuh
    num-ln          = num-ln          + 1
    sum-qntyFact    = sum-qntyFact    + temp-str.qntyFact
    sum-qntyBuh     = sum-qntyBuh     + temp-str.qntyBuh
    sum-weightFact  = sum-weightFact  + temp-str.weightItem * temp-str.qntyFact
    sum-weightBuh   = sum-weightBuh   + temp-str.weightItem * temp-str.qntyBuh
    sum1-qntyFact   = sum1-qntyFact   + temp-str.qntyFact
    sum1-qntyBuh    = sum1-qntyBuh    + temp-str.qntyBuh
    sum1-weightFact = sum1-weightFact + temp-str.weightItem * temp-str.qntyFact
    sum1-weightBuh  = sum1-weightBuh  + temp-str.weightItem * temp-str.qntyBuh
    sum2-qntyFact   = sum2-qntyFact   + temp-str.qntyFact
    sum2-qntyBuh    = sum2-qntyBuh    + temp-str.qntyBuh
    sum2-weightFact = sum2-weightFact + temp-str.weightItem * temp-str.qntyFact
    sum2-weightBuh  = sum2-weightBuh  + temp-str.weightItem * temp-str.qntyBuh
  .

  if line-counter( Out-Stream ) + j > page-size( Out-Stream )
  then  PAGE STREAM Out-Stream.


  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     temp-str.gds-name
    sym4     temp-str.b-code
    sym5     temp-str.EI
    sym6     temp-str.qntyFact
    sym7     temp-str.weightItem
    sym8     temp-str.weightItem * temp-str.qntyFact @ sum1-weightFact
    sym9     temp-str.qntyBuh
    sym10     temp-str.weightItem @ weightItem
    sym11     temp-str.weightItem * temp-str.qntyBuh  @ sum1-weightBuh
    sym12
  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1}
  .

  run inv8xl-write-line-data in this-procedure (
      input num-ln
      , input temp-str.gds-name
      , input temp-str.artic
      , input temp-str.b-code
      , input temp-str.EI
      , input temp-str.QntyFact
      , input temp-str.WeightItem
      , input temp-str.WeightItem * Qntyfact
      , input temp-str.QntyBuh
      , input temp-str.WeightItem
      , input temp-str.WeightItem * QntyBuh
  ).
end.