/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&Scop Sort-pole  if sort-gr then  ub.goods.grp-name Else ub.goods.artic

FOR EACH ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK ,
        First ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                                           ub.goods.prod-code = ub.doc-line.prod-code AND
                                           ub.goods.artic = ub.doc-line.artic NO-LOCK BREAK BY ({&Sort-pole}) BY ub.goods.artic :

        FIND FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK NO-ERROR .
        assign
        Lines_Counter = Lines_Counter + 1
        Tmp_Counter   = line-counter( OutStream )
        .

        { str/out-vatp.i    ub.doc-line ub.doc-line. ub.trn-doc.}

        IF CostPrice = true then DO:
          if PrintRubl Then  Assign   b-price  = ub.doc-line.price-Rubl   .
                       Else  Assign   b-price  = ub.doc-line.price-Base   .
                       End.
        Else  DO:
          if PrintRubl Then  Assign   b-price = price-Rubl-with-tax-sale .
                       Else  Assign   b-price = price-base-with-tax-sale .
                       End.

       b-stoim = ub.doc-line.fact-qnty * b-price.
    Assign
       b-qnty = ub.doc-line.doc-qnty
    .

    ACCUMULATE   b-qnty  ( TOTAL )
                 b-stoim ( TOTAL )
                 ub.goods.artic ( COUNT ).

    if sort-gr = true  and first-of ({&Sort-pole}) THEN DO:
      DOWN stream OutStream 1 with FRAME {2} .
      PUT stream OutStream UNFORMATTED
           String("_______________Группа : " + TRIM(CAPS(goods.grp-name)) + UndLine)  FORMAT "{1}"
           Skip .
           End.

    DISPLAY stream OutStream
      sym1
      Lines_Counter
      sym2
      ub.goods.artic
      sym3
      ub.goods.gds-name
      sym4
      trim( string( ub.goods.gds-code )) @ tb-code
      sym5
      ub.units.OKEI
      sym6
      ub.goods.unit-base
      sym7
      {3}
      {4}
      {5}
      {6}
      sym9
      b-price
      sym10
      b-qnty
      sym11
      b-stoim
      sym12 with FRAME {2}.
      DOWN stream OutStream 1 with FRAME {2} .
      {&PutExcel}
      Lines_Counter  {&tabulation}
      ub.goods.artic    {&tabulation}
      ub.goods.gds-name {&tabulation}
      ub.goods.gds-code {&tabulation}
      ub.units.OKEI     {&tabulation}
      ub.goods.unit-base   {&tabulation}
      ub.goods.qnty-cart   {&tabulation}
      ub.goods.wt-cart     {&tabulation}
      ub.goods.ms-cart     {&tabulation}
      excel-format-dec-to-char(b-price)           {&tabulation}
      excel-format-dec-to-char(b-qnty )           {&tabulation}
      excel-format-dec-to-char(b-stoim)           {&tabulation}
      ub.doc-line.unit-cli {&tabulation}
      ub.doc-line.cli-qnty {&tabulation}
      ub.doc-line.price-cli
      skip.

/*---------------------------------------------------------ПО ПРИЗНАКАМ----------------------------------------------*/
        if ub.trn-doc.internal and PrintScale then
            do:
              FOR EACH ub.gds-dtl where
                      ub.gds-dtl.artic     = ub.doc-line.artic     AND
                      ub.gds-dtl.doc-code  = ub.doc-line.doc-code  AND
                      ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
                      ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock :
                FIND FIRST gds-prt-1  WHERE gds-prt-1.node-code  = ub.gds-dtl.prt-code NO-LOCK no-error .
                FIND FIRST bar-code-1 WHERE
                                          bar-code-1.gds-code  = ub.goods.gds-code  AND
                                          bar-code-1.unit-cli  = ub.goods.unit-base    AND
                                          bar-code-1.node-code = gds-prt-1.node-code  AND
                                          bar-code-1.part-code = ""                 AND
                                          bar-code-1.in-code   = ""  NO-LOCK no-error .
        { str/out-vatp.i  calc-gds-dtl   ub.doc-line. ub.trn-doc. gds-dtl. }

        IF CostPrice = true then DO:
          if PrintRubl Then  Assign   b-price  = gds-dtl.price-Rubl   .
                       Else  Assign   b-price  = gds-dtl.price-Base   .
                       End.
        Else  DO:
          if PrintRubl Then  Assign   b-price = price-Rubl-with-tax-sale.
                       Else  Assign   b-price = price-base-with-tax-sale .
                       End.

       b-stoim = gds-dtl.fact-qnty * b-price.
    Assign
       b-qnty = gds-dtl.doc-qnty
    .

        DISPLAY stream OutStream
          sym1 sym2 sym3
         '  /'+ gds-prt-1.f-name @  ub.goods.gds-name
          sym4
          trim( string( bar-code-1.b-code )) @ tb-code
          sym5
          ub.units.OKEI
          sym6
          ub.goods.unit-base
          sym7
          {3}
          {4}
          {5}
          {6}
          sym9
          b-price
          sym10
          b-qnty
          sym11
          b-stoim
          sym12 with FRAME {2}.
          DOWN stream OutStream 1 with FRAME {2} .
      {&PutExcel}
                                                  {&tabulation}
                                                  {&tabulation}
      '  /'+ gds-prt-1.f-name                     {&tabulation}
      trim( string( bar-code-1.b-code ))          {&tabulation}
      ub.units.OKEI                                  {&tabulation}
      ub.goods.unit-base                             {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
      excel-format-dec-to-char(b-price)           {&tabulation}
      excel-format-dec-to-char(b-qnty )           {&tabulation}
      excel-format-dec-to-char(b-stoim)           {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
      skip.
          End.
          End. /*конец печати признаков */
     if print-graft = false THEN  Put stream OutStream LineBuf format "{1}" SKIP.

    if ( ( ( ACCUM COUNT ub.goods.artic ) modulo 10 ) = 0 ) AND
         ( ( ACCUM COUNT ub.goods.artic ) >= 10 ) then
        run waitfram-show ( "Обработано строк : " + string( ACCUM COUNT ub.goods.artic ) ) .
END.        /* FOR EACH ... */
/* Итоговые суммы */
    DISPLAY stream OutStream
    "Итого по док-ту" @ ub.goods.artic
      sym1
      sym2
      sym3
      sym4
      sym5
      sym6
      sym7
      {4}
      {6}
      sym9
      sym10
      accum TOTAL b-qnty    @ b-qnty
      sym11
      accum TOTAL b-stoim   @ b-stoim
      sym12 with FRAME {2}.
      DOWN stream OutStream 1 with FRAME {2} .
      {&PutExcel}
      "Итого по док-ту"                           {&tabulation}
                                                  {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
      excel-format-dec-to-char( accum TOTAL b-qnty )     {&tabulation}
      excel-format-dec-to-char( accum TOTAL b-stoim)     {&tabulation}
                                                  {&tabulation}
                                                  {&tabulation}
      skip.
    if print-graft = false THEN Put stream OutStream LineBuf format "{1}" SKIP.