/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формы для Торг-13xl

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def-frame" &then

&if "{2}" = "gold" &then
DEFINE FRAME f-doc-cost-gold
&else
DEFINE FRAME f-doc-cost
&endif
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format &if "{2}" = "gold" &then "X(31)" &else "X(35)" &endif space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
&if "{2}" = "gold" &then
        goods.sort column-label "Про!ба! ! ! " format "X(3)" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
&endif
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Учетная цена!с НДС! ! ! " format "->,>>>,>>9.99" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма!учетных цен!без НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма!учетных цен!с НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + string(tdoc-code) + " от " + v-doc-date-string )
                                                        at 40 format "X(45)"
        ( if t-doc.status_ <> {&fact} then
             string( "Статус: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " "   )                                   at 86 format "X(14)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) )
                                                        at 112 format "X(13)" SKIP
        Line format "X(130)" AT 1
    with width {&A4_CW0} down stream-io.

&if "{2}" = "gold" &then
DEFINE FRAME f-doc-doc-gold
&else
DEFINE FRAME f-doc-doc
&endif
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp_gds-name.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format &if "{2}" = "gold" &then "X(31)" &else "X(35)" &endif space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
&if "{2}" = "gold" &then
        goods.sort column-label "Про!ба! ! ! " format "X(3)" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
&endif
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        PriceWithNDS COLUMN-LABEL "Цена по доку!менту!с НДС! ! " format "->,>>>,>>9.99" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumNoNDS COLUMN-LABEL "Сумма!цен по доку!менту!без НДС! " format "->>,>>>,>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        SumWithNDS COLUMN-LABEL "Сумма!цен по доку!менту!с НДС! " format "->>,>>>,>>9.99" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + string(tdoc-code) + " от " + v-doc-date-string )
                                                        at 40 format "X(45)"
        ( if t-doc.status_ <> {&fact} then
             string( "Статус: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
          else
              " "   )                                   at 86 format "X(14)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) )
                                                        at 112 format "X(13)" SKIP
        Line format "X(130)" AT 1
    with width {&A4_CW0} down stream-io.

/*define temp-table temp_doc-line no-undo like doc-line.*/

&else
    if page-number( Out-Stream ) > PrevPage
    then assign
        Pg-tqnty = 0
        Pg-SumNoNDS = 0
        Pg-SumNDS = 0
        Pg-SumWithNDS = 0
    .
    &if "{1}" <> "itog" &then
        &if "{1}" <> "no-sum" &then
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + {1}tqnty
                Pg-SumNoNDS = Pg-SumNoNDS + {1}SumNoNDS
                Pg-SumNDS = Pg-SumNDS + {1}SumNDS
                Pg-SumWithNDS = Pg-SumWithNDS + {1}SumWithNDS
            .
        &endif
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
    &endif
        do:
            put stream out-stream
                Line format "X(130)"
                skip
            .
            if    Pg-SumWithNDS <> 0
              and Pg-tqnty      <> 0
              and Pg-SumNoNDS   <> 0
              and Pg-SumNDS     <> 0
            then do:
                display stream out-stream
                    "Итого"       @ temp_gds-name.gds-name
                    Pg-tqnty      @ tqnty
                    Pg-SumNoNDS   @ SumNoNDS
                    Pg-SumWithNDS @ SumWithNDS
                with frame &if "{2}" = "doc" &then f-doc-doc{3} &else f-doc-cost{3} &endif.
                down stream out-stream 1
                with frame &if "{2}" = "doc" &then f-doc-doc{3} &else f-doc-cost{3} &endif.
            end.
        end.
&endif

/* $Workfile$ e n d */