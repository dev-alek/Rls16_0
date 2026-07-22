/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения фреймов для отчета о выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}


&if not "{1}" = "tot" &then

DEFINE FRAME Benefit-{1}
        sym1 column-label ":"format "X(1)"
        benefits.date_ column-label "Дата " format "99.99.99"
        sym2 column-label ":" format "X(1)"
        benefits.pay-name column-label "Вид оплаты" format "X(41)"
        sym6 column-label ":" format "X(1)"
        benefits.tot-r-b column-label  "Сумма (вал.продаж)"   format "->,>>>,>>>,>>>,>>9.99"
        sym7 column-label ":" format "X(1)"
        benefits.pcnt column-label "% от суммы" format "->>>>9.99%"
        sym8 column-label ":" format "X(1)"
    HEADER  date_string format "X(35)" AT 5
                &if "{1}" = "base" &then
                        string( "( Б.Вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)" AT 42
                &else
                        string( " " ) format "X(20)" AT 42
                &endif
                        "Страница " AT 65 PAGE-NUMBER( PrnLibStream )  AT 75 FORMAT ">>9" SKIP
                    Line format "X(82)" AT 1
    with width {&A4_CW} down stream-io use-text .

DEFINE FRAME PayCodes-{1}
        sym1 column-label ":" format "X(1)"
        benefits.pay-name column-label "Вид оплаты" format "X(41)"
        sym6 column-label ":" format "X(1)"
        benefits.tot-r-b column-label  "Сумма (вал.продаж)."  format "->,>>>,>>>,>>>,>>9.99"
        sym7 column-label ":" format "X(1)"
        benefits.pcnt column-label "% от суммы" format "->>>>9.99%"
        sym8 column-label ":" format "X(1)"
    HEADER  date_string format "X(35)" AT 5
                &if "{1}" = "base" &then
                        string( "( Б.Вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)" AT 42
                &else
                        string( " " ) format "X(20)" AT 42
                &endif
                        "Страница " AT 65 PAGE-NUMBER( PrnLibStream )  AT 75 FORMAT ">>9" SKIP
                    Line format "X(82)" AT 1
    with width {&A4_CW} down stream-io use-text .


DEFINE FRAME ZUM-PayCodes-{1}
        sym1 column-label ":" format "X(1)"
        benefits.pay-name column-label "Вид оплаты" format "X(41)"
        sym6 column-label ":" format "X(1)"
        benefits.tot-r-b column-label "Сумма (вал.продаж)"  format "->,>>>,>>>,>>>,>>9.99"
        sym7 column-label ":" format "X(1)"
        benefits.pcnt column-label "% от суммы" format "->>>>9.99%"
        sym8 column-label ":" format "X(1)"
    with width {&A4_CW} down stream-io use-text NO-LABELS.

&endif

&if "{1}" = "tot" &then

DEFINE FRAME Benefit-Tot
        sym1 column-label ":!:" format "X(1)"
        benefits.date_ column-label "Дата ! " format "99.99.99"
        sym2 column-label ":!:" format "X(1)"
        benefits.pay-name column-label "Вид !оплаты" format "X(20)"
        sym3 column-label ":!:" format "X(1)"
        benefits.curr-name column-label "Валюта ! " format "X(19)"
        sym4 column-label ":!:" format "X(1)"
        benefits.tot-sum column-label "Сумма!в валюте" format "->>>>,>>>,>>>,>>9.99"
        sym5 column-label ":!:" format "X(1)"
        benefits.tot-base column-label "Сумма!в Б.Вал."
                format "->>>>>,>>>,>>9.99"
        sym6 column-label ":!:" format "X(1)"
        benefits.tot-rubl column-label "Сумма!в {&abbr_rublyah}" format "->>>>,>>>,>>>,>>9.99"
        sym7 column-label ":!:" format "X(1)"
        benefits.pcnt column-label "% от суммы!в Б.Вал." format "->>9.99"
        sym8 column-label ":!:" format "X(1)"
    HEADER  date_string format "X(35)" AT 5
                        string( "( Б.Вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)" AT 42
                        "Страница " AT 115 PAGE-NUMBER( PrnLibStream ) AT 125 FORMAT ">>9" SKIP
                    Line format "X(136)" AT 1
    with width {&A4_CW} down stream-io use-text .

DEFINE FRAME PayCodes-Tot
        sym1 column-label ":!:" format "X(1)"
        benefits.pay-name column-label "Вид !оплаты" format "X(30)"
        sym3 column-label ":!:" format "X(1)"
        benefits.curr-name column-label "Валюта ! " format "X(19)"
        sym4 column-label ":!:" format "X(1)"
        benefits.tot-sum column-label "Сумма!в валюте" format "->>>>,>>>,>>>,>>9.99"
        sym5 column-label ":!:" format "X(1)"
        benefits.tot-base column-label "Сумма!в Б.Вал."
                format "->>>>>,>>>,>>9.99"
        sym6 column-label ":!:" format "X(1)"
        benefits.tot-rubl column-label "Сумма!в {&abbr_rublyah}" format "->,>>>,>>>,>>>,>>9.99"
        sym7 column-label ":!:" format "X(1)"
        benefits.pcnt column-label "% от суммы!в Б.Вал." format "->>9.99"
        sym8 column-label ":!:" format "X(1)"
    HEADER  date_string format "X(35)" AT 5
                        string( "( Б.Вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)" AT 42
                        "Страница " AT 115 PAGE-NUMBER( PrnLibStream ) AT 125 FORMAT ">>9" SKIP
                    Line format "X(136)" AT 1
    with width {&A4_CW} down stream-io use-text .

DEFINE FRAME ZUM-PayCodes-Tot
        sym1 column-label ":!:" format "X(1)"
        benefits.pay-name column-label "Вид !оплаты" format "X(30)"
        sym3 column-label ":!:" format "X(1)"
        benefits.curr-name column-label "Валюта ! " format "X(19)"
        sym4 column-label ":!:" format "X(1)"
        benefits.tot-sum column-label "Сумма!в валюте" format "->>>>,>>>,>>>,>>9.99"
        sym5 column-label ":!:" format "X(1)"
        benefits.tot-base column-label "Сумма!в Б.Вал."
                format "->>>>>,>>>,>>9.99"
        sym6 column-label ":!:" format "X(1)"
        benefits.tot-rubl column-label "Сумма!в {&abbr_rublyah}" format "->,>>>,>>>,>>>,>>9.99"
        sym7 column-label ":!:" format "X(1)"
        benefits.pcnt column-label "% от суммы!в Б.Вал." format "->>9.99"
        sym8 column-label ":!:" format "X(1)"
    with width {&A4_CW} down stream-io use-text NO-LABELS.

&endif
/* $Workfile$ e n d */