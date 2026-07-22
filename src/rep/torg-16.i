/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формы для ТОРГ-16

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
    def frame {2}doc-lst
            sym1 column-label ":!:!:!:!:" format "X(1)"
            date-in column-label "Дата!поступления!товара! ! " format "99/99/9999"
            sym3 column-label ":!:!:!:!:" format "X(1)"
            parts.fact-date column-label "Дата!списания!товара! ! " format "99/99/9999"
            sym4 column-label ":!:!:!:!:" format "X(1)"
            parts.in-code column-label "Товарная!накладная!номер! ! " format "X(16)"
            sym5 column-label ":!:!:!:!:" format "X(1)"
            b-trn-doc.fact-date column-label "Товарная!накладная!дата! ! " format "99/99/9999"
            sym6 column-label ":!:!:!:!:" format "X(1)"
            v-reason column-label "Признаки понижения качества (причины списания)! !наименование! ! " format "X(112)"
            sym10 column-label ":!:!:!:!:" format "X(1)"
            s2 column-label " ! Код ! ! ! " format "X(20)"
            sym11 column-label ":!:!:!:!:" format "X(1)"
        header
            string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) at 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
            else
                " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) ) at 180 format "X(13)" skip
            Line format "X(198)" at 1
        with width {&DOS_CW} down stream-io.
    def frame {2}f-doc
            sym1 column-label ":!:!:!:!:" format "X(1)"
            goods.gds-name column-label "Наименование товара! ! ! ! " format "X(100)" /* "X(30)" */ space(0)
            sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
            tb-code column-label "Код товара! ! ! ! " format "X(13)" space(0)
            sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
            goods.unit-base column-label "Наим!ед.!изм.! ! " format "X(4)" space(0)
            sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
            OKEI column-label "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
            sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
            tqnty column-label "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
            sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
            mass-b column-label "Масса!брут-!то! ! " format ">>9.<" space(0)
            sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
            mass-n column-label "Масса!нетто! ! ! " format ">>9.<" space(0)
            sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
            &if "{2}" = "no-vat-" &then
                price column-label "Цена!без НДС! ! ! " format "->>,>>>,>>9.99" space(0)
            &else
                price column-label "Цена!с НДС! ! ! " format "->>,>>>,>>9.99" space(0)
            &endif
            sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
            &if "{2}" = "no-vat-" &then
                stoim column-label "Сумма !без НДС ! ! ! " format "->,>>>,>>>,>>9.99" space(0)
            &else
                stoim column-label "Сумма !с НДС ! ! ! " format "->,>>>,>>>,>>9.99" space(0)
            &endif
            sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
            gds-PS column-label "Примечание! ! ! ! " format "X(41)" space(0)
            sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        header
            string( "Цены и суммы " + (if CostPrice then "(учетные)" else "") + " указаны в " + trim( val-str ) ) format "X(40)"
            string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) at 45 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
            else
                " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) ) at 180 format "X(13)" skip
            Line format "X(198)" at 1
        with width {&DOS_CW} down stream-io.
&else
    if page-number( Out-Stream ) > PrevPage then do:
        assign
            Pg-tqnty = 0
            Pg-stoim = 0
/*            Pg-stoim-VAT = 0*/
        .
    end.
    &if "{1}" <> "itog" &then

        &if "{1}" <> "no-sum" &then
            assign
                PrevPage = page-number( Out-Stream )
                Pg-tqnty = Pg-tqnty + {1}tqnty
                Pg-stoim = Pg-stoim + {1}stoim
/*                Pg-stoim-VAT = Pg-stoim-VAT + {1}stoim-VAT*/
            .
        &endif
        if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
    &endif
        do:
            PUT STREAM Out-Stream Line format "X(198)" SKIP.
            if lineCounter <> 1
            then do:
                DISPLAY STREAM Out-Stream
                    "Итого" @ goods.gds-name
                    Pg-tqnty @ tqnty
                    Pg-stoim @ stoim
                    with frame {2}f-doc .
                DOWN STREAM Out-Stream 1 with FRAME {2}f-doc .
            end.
            else do:
                page stream Out-Stream.
            end.
        end.
&endif

/* $Workfile$ e n d */