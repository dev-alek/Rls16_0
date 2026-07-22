/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать тела KM-6

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DO:
/*  if temp-str.summ-end <> 0 and temp-str.summ-begin <> 0 then do:*/
/*    assign sum1-shift    = (temp-str.summ-end - temp-str.summ-begin) .*/
/*  end.*/
/*  else do :*/
/*    assign sum1-shift    = sum1-shift + temp-str.summ-sale .*/
/*  end.*/
  ASSIGN
    sum2-shift    = sum2-shift + temp-str.summ-return
    Lines_Counter = Lines_Counter + 1
  .

  if line-counter( Out-Stream ) + 3 > page-size( Out-Stream )
  then  PAGE STREAM Out-Stream.


  display stream Out-Stream
          sym1  temp-str.z-number
          sym2  empty-str09-2
          sym3  empty-str09-3
          Sym4  temp-str.zero-counter
          sym5  temp-str.summ-begin
          sym6  temp-str.summ-end
          sym7  temp-str.summ-sale
          sym8  temp-str.summ-return
          sym9  temp-str.person
          sym10 empty-str09-10
          sym11
  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1}
  .

  run km6xl-write-line-data in this-procedure (
        input p-sheet-name
      , input temp-str.z-number
      , input temp-str.summ-sale
      , input temp-str.summ-return
      , input temp-str.person
  ).
end.
/* $Workfile$   E n d */