/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формы для Торг-16а

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
    define frame f-doc
            sym1                column-label ":" format "X(1)"
            v-line-counter      column-label "1 " format ">>>9"
            sym2                column-label ":" format "X(1)" space(0)
            v-artic             column-label "        2" format "X(17)" space(0)
            sym3                column-label ":" format "X(1)" space(0)
            v-gds-name          column-label "                   3" format "X(39)" /* "X(30)" */ space(0)
            sym4                column-label ":" format "X(1)" space(0)
            v-unit-base         column-label " 4" format "X(4)" space(0)
            sym5                column-label ":" format "X(1)" space(0)
            v-parts-qnty        column-label "5      " format ">>>>>>9.999" space(0)
            sym6                column-label ":" format "X(1)" space(0)
            v-parts-price       column-label "6       " format "->>,>>>,>>9.99" space(0)
            sym7                column-label ":" format "X(1)" space(0)
            v-parts-sum-price   column-label "7        " format "->,>>>,>>>,>>9.99" space(0)
            sym8                column-label ":" format "X(1)" space(0)
            v-qnty              column-label "5      " format ">>>>>>9.999" space(0)
            sym9                column-label ":" format "X(1)" space(0)
            v-price             column-label "6       " format "->>,>>>,>>9.99" space(0)
            sym10               column-label ":" format "X(1)" space(0)
            v-sum-price         column-label "7        " format "->,>>>,>>>,>>9.99" space(0)
            sym11               column-label ":" format "X(1)" space(0)
            v-void              column-label "                  8" format "X(36)" space(0)
            sym12               column-label ":" format "X(1)" space(0)
        with width {&DOS_CW} down stream-io use-text no-box no-labels.
&else
    if page-number( Out-Stream ) > PrevPage
    then do:
        assign
            Pg-tqnty        = 0
            Pg-stoim        = 0
            Pg-stoim-VAT    = 0
        .
    end.
    &if "{1}" <> "itog" &then
        &if "{1}" <> "no-sum" &then
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + v-qnty
                Pg-stoim = Pg-stoim + v-sum-price
            .
        &endif
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
    &endif
        do:
            PUT STREAM Out-Stream v-line-string format "X(198)" SKIP.
            if v-line-counter <> 1
            then do:
                DISPLAY STREAM Out-Stream
                    "Итого"         @ v-gds-name
                    Pg-tqnty        @ v-qnty
                    Pg-stoim        @ v-sum-price
                    with frame f-doc .
                DOWN STREAM Out-Stream 1 with FRAME f-doc .
                &if "{1}" <> "itog" &then
                    put stream out-stream
                        string( "Цены и суммы " + (if CostPrice then "(учетные)" else "") + " указаны в " + trim( val-str ) ) format "X(40)"
                        string( "Документ N: " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(50)"
                        ( if t-doc.status_ <> {&fact} then
                            string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
                        else
                            " " ) at 100 format "X(30)"
                        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) ) at 180 format "X(13)" skip
                    .
                    run write-header in this-procedure (
                        input no
                    ).
                &endif
            end.
            else do:
                page stream Out-Stream.
            end.
        end.
&endif

/* $Workfile$ e n d */