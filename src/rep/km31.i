/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать тела KM-3

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

Автор1: Белоусов Илья Александрович

*/

DO:
  ASSIGN
    sum2-shift    = sum2-shift + temp-str.chk-tot
    Lines_Counter = Lines_Counter + 1
  .

  if line-counter( Out-Stream ) + 3 > page-size( Out-Stream )
  then  PAGE STREAM Out-Stream.

  &if "{2}" = "is-doc" &then
  display stream Out-Stream
            sym1  Lines_Counter         @ temp-str.num-pos
            sym2  temp-str.section-name
            sym3  temp-str.shift-num
            Sym4  temp-str.chk-num
            sym5  temp-str.chk-tot
            sym6  temp-str.person
          sym7
  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1}
  .

    run km3xl-write-line-data in this-procedure ( input p-sheet-name
                                                , input Lines_Counter
                                              , input temp-str.section-name
                                              , input temp-str.shift-num
                                              , input temp-str.chk-num
                                              , input temp-str.chk-tot
                                              , input temp-str.person
                                              ) .
  &else
    display stream Out-Stream
            sym1  Lines_Counter         @ temp-str.num-pos
            sym2  temp-str.section-name
            sym3  temp-str.shift-date
            sym4  temp-str.shift-num
            Sym5  temp-str.cash-num
            sym6  temp-str.chk-num
            sym7  temp-str.chk-tot
            sym8  temp-str.person
            sym9
    with FRAME {1}.
    DOWN stream Out-Stream 1 with FRAME {1}
    .
    {&PutExcel}
      Lines_Counter                {&tabulation}
      temp-str.section-name        {&tabulation}
      temp-str.shift-date          {&tabulation}
      temp-str.shift-num           {&tabulation}
      temp-str.cash-num            {&tabulation}
      temp-str.chk-num             {&tabulation}
      temp-str.chk-tot             {&tabulation}
      temp-str.person              {&tabulation} {&new-line}
    .

  &endif
end.

/* $Workfile$   E n d */