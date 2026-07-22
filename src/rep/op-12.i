/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печатная форма ОП-12. Обработка строк.

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "var" &then
    if page-number( Out-Stream ) > PrevPage
    then assign
            v-pg-need-qnty     = 0
            v-pg-places-amount = 0
            v-pg-qnty-all      = 0
            v-pg-cost-sum      = 0
            v-pg-sale-sum      = 0
        .

    &if "{2}" <> "itog" &then
        &if "{2}" <> "no-sum" &then
            assign
                PrevPage           = page-number( Out-Stream )
                v-pg-need-qnty     = v-pg-need-qnty + v-{2}need-qnty
                v-pg-places-amount = 0
                v-pg-qnty-all      = v-pg-qnty-all + v-{2}qnty-all
                v-pg-cost-sum      = v-pg-cost-sum + v-{2}cost-sum
                v-pg-sale-sum      = v-pg-sale-sum + v-{2}sale-sum
            .
        &endif
        if line-counter( Out-Stream ) + 2 > page-size( Out-Stream ) then
    &endif
            do:
                PUT stream Out-Stream  skip space({&P-S}) v-single-line format "X({&P-X})"  .
                display stream Out-Stream
                  skip space({&P-S})
                    "Итого"             @ v-goods-name
/*                    v-pg-need-qnty      @ v-need-qnty*/
    /*                v-pg-places-amount @ v-places-amount*/
                    v-pg-qnty-all       @ v-qnty-all
                    v-pg-cost-sum       @ v-cost-sum
                    v-pg-sale-sum       @ v-sale-sum
                with frame f-doc.
    &if "{2}" <> "itog" &then
                page stream Out-Stream.
                put stream Out-Stream
                    skip space({&P-S})
                    v-single-line format "X({&P-X0})"
                    skip space({&P-S})
                    "|  1"
                    ":"                  at {&P-C2-S}
                    "2"                  at center-field( {&P-C2-S}, {&P-C3-S}, 1)
                    ":"                  at {&P-C3-S}
                    "3"                  at center-field( {&P-C3-S}, {&P-C4-S}, 1)
                    ":"                  at {&P-C4-S}
                    "4"                  at center-field( {&P-C4-S}, {&P-C5-S}, 1)
                    ":"                  at {&P-C5-S}
                    "5"                  at center-field( {&P-C5-S}, {&P-C6-S}, 1)
                    ":"                  at {&P-C6-S}
                    "6"                  at center-field( {&P-C6-S}, {&P-C7-S}, 1)
                    ":"                  at {&P-C7-S}
                    "7"                  at center-field( {&P-C7-S}, {&P-C8-S}, 1)
                    ":"                  at {&P-C8-S}
                    "8"                  at center-field( {&P-C8-S}, {&P-C9-S}, 1)
                    ":"                  at {&P-C9-S}
                    "9"                  at center-field( {&P-C9-S}, {&P-C10-S}, 1)
                    ":"                  at {&P-C10-S}
                    "10"                 at center-field( {&P-C10-S}, {&P-C11-S}, 2)
                    "|"                  at {&P-E}
                    skip space({&P-S})
                    "|"
                    v-single-line format "X({&P-X0})"
                    "|"                  at {&P-E}
                .
    &endif
            end.
&endif

&if "{1}" = "head" &then
        &if "{2}" <> "no-line" &then
            if page-number( Out-Stream ) <> 1 then do:
                PUT stream Out-Stream  skip space({&P-S})
                        "Документ " + string( tdoc-code ) + " от " + string( tdoc-date, "99/99/9999" ) format "X(60)"
                        "Страница " + string( page-number( Out-Stream ) ) format "X(13)" at right-field( {&P-E}, 13 )
                .
            end.
            PUT stream Out-Stream skip space({&P-S}) v-single-line format "X({&P-X})" .
        &endif
        PUT stream Out-Stream
            skip space({&P-S})
              "|  1"
              ":"                  at {&P-C2-S}
              "2"                  at center-field( {&P-C2-S}, {&P-C3-S}, 1)
              ":"                  at {&P-C3-S}
              "3"                  at center-field( {&P-C3-S}, {&P-C4-S}, 1)
              ":"                  at {&P-C4-S}
              "4"                  at center-field( {&P-C4-S}, {&P-C5-S}, 1)
              ":"                  at {&P-C5-S}
              "5"                  at center-field( {&P-C5-S}, {&P-C6-S}, 1)
              ":"                  at {&P-C6-S}
              "6"                  at center-field( {&P-C6-S}, {&P-C7-S}, 1)
              ":"                  at {&P-C7-S}
              "7"                  at center-field( {&P-C7-S}, {&P-C8-S}, 1)
              ":"                  at {&P-C8-S}
              "8"                  at center-field( {&P-C8-S}, {&P-C9-S}, 1)
              ":"                  at {&P-C9-S}
              "9"                  at center-field( {&P-C9-S}, {&P-C10-S}, 1)
              ":"                  at {&P-C10-S}
              "10"                 at center-field( {&P-C10-S}, {&P-C11-S}, 2)
              "|"                  at {&P-E}
            skip space({&P-S})
              "|"
              v-single-line format "X({&P-X0})"
              "|"                  at {&P-E}
        .
&endif

/* $Workfile$ e n d */