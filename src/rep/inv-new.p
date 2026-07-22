block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-new.p $
$Archive: rep/inv-new.p $

Новая форма для инвентаризации.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:
    p-trn-doc-recid    as recid - recid документа инвентаризации

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-new.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-new.p $":U .
define variable vss-description as character no-undo initial "Новая форма для инвентаризации.":U .

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ rep/p-fmt.i       }
{ rep/fmtcli.i      }
{ gbl/cur-time.i    }
{ str/lib-trn.i     }
{ str/trdcalib.i    }

&scoped-define stream-width 230
&scoped-define P-S 5
&scoped-define max-width-from-start 193

&scoped-define P0-X 194
&scoped-define P0-X0 192 /* длина внутренней линии = {&P2-X} - 2*/
&scoped-define P0-C02-S 10
&scoped-define P0-C03-S 20
&scoped-define P0-C04-S 37
&scoped-define P0-C05-S 70
&scoped-define P0-C06-S 75
&scoped-define P0-C07-S 87
&scoped-define P0-C08-S 98
&scoped-define P0-C09-S 114
&scoped-define P0-C10-S 126
&scoped-define P0-C11-S 142
&scoped-define P0-C12-S 154
&scoped-define P0-C13-S 170
&scoped-define P0-C14-S 182
&scoped-define P0-E 198

&scoped-define P0-C01-F ">>>9"
&scoped-define P0-C02-F "999999999"
&scoped-define P0-C03-F "X(16)"
&scoped-define P0-C04-F "X(32)"
&scoped-define P0-C05-F "X(4)"
&scoped-define P0-C06-F "->>>,>>9.99"
&scoped-define P0-C07-F ">>>,>>9.99"
&scoped-define P0-C08-F "->>>,>>>,>>9.99"
&scoped-define P0-C09-F "->>>,>>9.99"
&scoped-define P0-C10-F "->>>,>>>,>>9.99"
&scoped-define P0-C11-F "->>>,>>9.99"
&scoped-define P0-C12-F "->>>,>>>,>>9.99"
&scoped-define P0-C13-F "->>>,>>9.99"
&scoped-define P0-C14-F "->>>,>>>,>>9.99"

    define stream out-stream.

    define variable v-inv-new-line-counter  as integer      no-undo.

    define variable v-single-line           as character    no-undo.
    define variable v-today                 as date         no-undo.
    define variable v-time                  as integer      no-undo.
    define variable v-print-rubl            as logical      no-undo.

    define variable v-page-after-sum        as decimal      no-undo.
    define variable v-page-before-sum       as decimal      no-undo.
    define variable v-page-surplus-sum      as decimal      no-undo.
    define variable v-page-lack-sum         as decimal      no-undo.

    define variable v-doc-after-sum         as decimal      no-undo.
    define variable v-doc-before-sum        as decimal      no-undo.
    define variable v-doc-surplus-sum       as decimal      no-undo.
    define variable v-doc-lack-sum          as decimal      no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.

do
on error undo, return error
:
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    no-error.
    if not available buf_trn-doc
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Неверно выбран документ."
        view-as alert-box error.
        undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
    then do:
        message
                "Ошибка выбора документа."
            skip(1)
            skip "Форма предназначена только для печати"
            skip "документов инвентаризации."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-single-line  = fill( "-", {&stream-width} )
        v-inv-new-line-counter = 0
        v-print-rubl   = ( if PrintRubl = yes then yes else no )
    .
    { gbl/working.i }
    { cmp/open-out.i stream out-stream " " {&stream-width} }

    run fmtcli-get-client in this-procedure (
          input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
    ).
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    put stream Out-Stream
        skip space({&P-S})
            substitute( "Объект: (&1 &2) &3"
                        , buf_trn-doc.obj-type
                        , buf_trn-doc.obj-code
                        , v-fmtcli-name      )              format "X({&max-width-from-start})"
        skip(1) space({&P-S})
            substitute( "Дата печати: &1"
                        , string( v-today, "99/99/9999" ) ) format "X(23)"
            "Инвентаризация"                                   at {&P-S} + 23 + 60
    .
    run print-header in this-procedure (
        input yes
    ).
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    by buf_doc-line.artic
    on error undo, return error
    :
        assign
            v-inv-new-line-counter  = v-inv-new-line-counter    + 1
        .
        run print-line in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , input v-print-rubl
        ).
    end.        /* for each buf_doc-line */
    run print-footer in this-procedure (
        input v-print-rubl
    ).
    output stream Out-Stream close.
    { gbl/stopwork.i  }
    { rep/q-print.i 8 }
end.


/*==========================================================================*/
procedure print-header :
define input parameter p-first  as logical      no-undo.

do
on error undo, return error
:
    if line-counter( Out-stream ) = 0
    or p-first = yes
    then do:
        put stream Out-Stream
            skip string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)"   at right-field( {&P0-E}, 13)
        .
        put stream Out-Stream
            skip
                v-single-line           format "X({&P0-X})"    at {&P-S}
            skip
                "|"                                     at {&P-S}
                "N"                                     at center-field( {&P-S}, {&P0-C02-S}, 1 )
                "|"                                     at {&P0-C02-S}
                "Код"                                   at center-field( {&P0-C02-S}, {&P0-C03-S}, 3 )
                "|"                                     at {&P0-C03-S}
                "Артикул"                               at center-field( {&P0-C03-S}, {&P0-C04-S}, 7 )
                "|"                                     at {&P0-C04-S}
                "Наименование товара"                   at {&P0-C04-S} + 2
                "|"                                     at {&P0-C05-S}
                "Ед."                                   at center-field( {&P0-C05-S}, {&P0-C06-S}, 3 )
                "|"                                     at {&P0-C06-S}
                "Учетный"                               at center-field( {&P0-C06-S}, {&P0-C07-S}, 7 )
                "|"                                     at {&P0-C07-S}
                "Продажная"                             at center-field( {&P0-C07-S}, {&P0-C08-S}, 9 )
                "|"                                     at {&P0-C08-S}
                "Сумма по ТН"                           at center-field( {&P0-C08-S}, {&P0-C09-S}, 11 )
                "|"                                     at {&P0-C09-S}
                "Количество"                            at center-field( {&P0-C09-S}, {&P0-C10-S}, 10 )
                "|"                                     at {&P0-C10-S}
                "Сумма"                                 at center-field( {&P0-C10-S}, {&P0-C11-S}, 5 )
                "|"                                     at {&P0-C11-S}
                "Излишки"                               at center-field( {&P0-C11-S}, {&P0-C12-S}, 7 )
                "|"                                     at {&P0-C12-S}
                "Сумма"                                 at center-field( {&P0-C12-S}, {&P0-C13-S}, 5 )
                "|"                                     at {&P0-C13-S}
                "Недостача"                             at center-field( {&P0-C13-S}, {&P0-C14-S}, 9 )
                "|"                                     at {&P0-C14-S}
                "Сумма"                                 at center-field( {&P0-C14-S}, {&P0-E}, 5 )
                "|"                                     at {&P0-E}
            skip
                "|"                                     at {&P-S}
                "п/п"                                   at center-field( {&P-S}, {&P0-C02-S}, 3 )
                "|"                                     at {&P0-C02-S}
                "|"                                     at {&P0-C03-S}
                "|"                                     at {&P0-C04-S}
                "|"                                     at {&P0-C05-S}
                "изм."                                  at center-field( {&P0-C05-S}, {&P0-C06-S}, 4 )
                "|"                                     at {&P0-C06-S}
                "остаток"                               at center-field( {&P0-C06-S}, {&P0-C07-S}, 7 )
                "|"                                     at {&P0-C07-S}
                "цена"                                  at center-field( {&P0-C07-S}, {&P0-C08-S}, 4 )
                "|"                                     at {&P0-C08-S}
                "|"                                     at {&P0-C09-S}
                "по факту"                              at center-field( {&P0-C09-S}, {&P0-C10-S}, 8 )
                "|"                                     at {&P0-C10-S}
                "по факту"                              at center-field( {&P0-C10-S}, {&P0-C11-S}, 8 )
                "|"                                     at {&P0-C11-S}
                "|"                                     at {&P0-C12-S}
                "излишков"                              at center-field( {&P0-C12-S}, {&P0-C13-S}, 8 )
                "|"                                     at {&P0-C13-S}
                "|"                                     at {&P0-C14-S}
                "недостачи"                             at center-field( {&P0-C14-S}, {&P0-E}, 9 )
                "|"                                     at {&P0-E}
            skip
                "|"                                     at {&P-S}
                v-single-line                           format "X({&P0-X0})"
                "|"
        .
    end.
end.
end procedure. /* print-header */



/*==========================================================================*/
procedure print-line :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.
define input parameter p-print-rubl as logical          no-undo.

    define variable v-price-sale            as decimal      no-undo.
    define variable v-before-qnty           as decimal      no-undo.
    define variable v-before-sum            as decimal      no-undo.
    define variable v-before-sum-rubl       as decimal      no-undo.
    define variable v-before-sum-base       as decimal      no-undo.
    define variable v-after-qnty            as decimal      no-undo.
    define variable v-after-sum             as decimal      no-undo.
    define variable v-after-sum-rubl        as decimal      no-undo.
    define variable v-after-sum-base        as decimal      no-undo.
    define variable v-surplus-qnty          as decimal      no-undo.
    define variable v-surplus-sum           as decimal      no-undo.
    define variable v-lack-qnty             as decimal      no-undo.
    define variable v-lack-sum              as decimal      no-undo.

/*    define variable v-price-sale-length     as integer      no-undo.*/
/*    define variable v-before-qnty-length    as integer      no-undo.*/
/*    define variable v-before-sum-length     as integer      no-undo.*/
/*    define variable v-after-qnty-length     as integer      no-undo.*/
/*    define variable v-after-sum-length      as integer      no-undo.*/

    define buffer buf_doc-line      for doc-line.
    define buffer buf_goods         for goods.
do
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    .
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code  = p-doc-code
           and buf_doc-line.artic     = buf_goods.artic
           and buf_doc-line.prod-type = buf_goods.prod-type
           and buf_doc-line.prod-code = buf_goods.prod-code
    .
    run print-header in this-procedure (
        input no
    ).
    run get-before-and-after-inv-qnty in this-procedure (
          input p-doc-code
        , input buf_goods.gds-code
        , output v-before-qnty
        , output v-before-sum-rubl
        , output v-before-sum-base
        , output v-after-qnty
        , output v-after-sum-rubl
        , output v-after-sum-base
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка вычисления сумм до и после инвентаризации."
            skip(1)
            skip "Документ:" p-doc-code
            skip "Товар:" buf_goods.artic buf_goods.gds-name
            skip(1)
            skip "Строка товара в форме может содержать неверные данные."
        view-as alert-box warning.
        assign
            v-price-sale  = 0
            v-before-qnty = 0
            v-before-sum  = 0
            v-after-qnty  = 0
            v-after-sum   = 0
        .
    end.
    if p-print-rubl
    then do:
        assign
            v-before-sum = v-before-sum-rubl
            v-after-sum  = v-after-sum-rubl
            v-price-sale = v-before-sum-rubl / v-before-qnty
        .
    end.
    else do:
        assign
            v-before-sum = v-before-sum-base
            v-after-sum  = v-after-sum-base
            v-price-sale = v-before-sum-base / v-before-qnty
        .
    end.
    assign
        v-surplus-qnty  = 0
        v-surplus-sum   = 0
        v-lack-qnty     = 0
        v-lack-sum      = 0
    .
    if v-before-qnty < v-after-qnty
    then do:
        assign
            v-surplus-qnty = v-after-qnty - v-before-qnty
            v-surplus-sum  = v-after-sum  - v-before-sum
        .
    end.
    if v-before-qnty > v-after-qnty
    then do:
        assign
            v-lack-qnty = v-before-qnty - v-after-qnty
            v-lack-sum  = v-before-sum  - v-after-sum
        .
    end.
    put stream out-stream
        skip
            "|"                                         at {&P-S}
            v-inv-new-line-counter  format {&P0-C01-F}  /*at center-field( {&P-S}, {&P0-C02-S}, 1 )*/
            "|"                                         at {&P0-C02-S}
            buf_goods.gds-code      format {&P0-C02-F}  /*at center-field( {&P0-C02-S}, {&P0-C03-S}, 3 )*/
            "|"                                         at {&P0-C03-S}
            p-artic                 format {&P0-C03-F}  /*at center-field( {&P0-C03-S}, {&P0-C04-S}, 7 )*/
            "|"                                         at {&P0-C04-S}
            buf_goods.gds-name      format {&P0-C04-F}  /*at {&P0-C04-S} + 2*/
            "|"                                         at {&P0-C05-S}
            buf_goods.unit-base     format {&P0-C05-F}  /*at center-field( {&P0-C05-S}, {&P0-C06-S}, 3 )*/
            "|"                                         at {&P0-C06-S}
            v-before-qnty           format {&P0-C06-F}  /*at center-field( {&P0-C06-S}, {&P0-C07-S}, 7 )*/
            "|"                                         at {&P0-C07-S}
            v-price-sale            format {&P0-C07-F}  /*at center-field( {&P0-C07-S}, {&P0-C08-S}, 9 )*/
            "|"                                         at {&P0-C08-S}
            v-before-sum            format {&P0-C08-F}  /*at center-field( {&P0-C08-S}, {&P0-C09-S}, 11 )*/
            "|"                                         at {&P0-C09-S}
            v-after-qnty            format {&P0-C09-F}  /*at center-field( {&P0-C09-S}, {&P0-C10-S}, 10 )*/
            "|"                                         at {&P0-C10-S}
            v-after-sum             format {&P0-C10-F}  /*at center-field( {&P0-C10-S}, {&P0-C11-S}, 5 ) */
            "|"                                         at {&P0-C11-S}
            v-surplus-qnty          format {&P0-C11-F}  /*at center-field( {&P0-C11-S}, {&P0-C12-S}, 7 )*/
            "|"                                         at {&P0-C12-S}
            v-surplus-sum           format {&P0-C12-F}  /*at center-field( {&P0-C12-S}, {&P0-C13-S}, 5 )*/
            "|"                                         at {&P0-C13-S}
            v-lack-qnty             format {&P0-C13-F}  /*at center-field( {&P0-C13-S}, {&P0-C14-S}, 9 )*/
            "|"                                         at {&P0-C14-S}
            v-lack-sum              format {&P0-C14-F}  /*at center-field( {&P0-C14-S}, {&P0-E}, 5 )*/
            "|"                                         at {&P0-E}

    .
    assign
        v-page-after-sum        = v-page-after-sum      + v-after-sum
        v-page-before-sum       = v-page-before-sum     + v-before-sum
        v-page-surplus-sum      = v-page-surplus-sum    + v-surplus-sum
        v-page-lack-sum         = v-page-lack-sum       + v-lack-sum
    .
    if line-counter( Out-stream ) + 2 > page-size( Out-stream )
    then do:
        run print-end-of-page in this-procedure (
            input yes
        ).
    end.
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-footer :
do
on error undo, return error
:
define input parameter p-print-rubl as logical      no-undo.

    define variable v-all-sum-cost as decimal       no-undo.

    run print-end-of-page in this-procedure (
        input no
    ).
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream out-stream.
    end.
    put stream Out-Stream
        skip (1)
            "Всего по документу:   "                        at {&P-S}
            v-doc-before-sum            format {&P0-C08-F}  at {&P0-C08-S} + 1
            v-doc-after-sum             format {&P0-C10-F}  at {&P0-C10-S} + 1
            v-doc-surplus-sum           format {&P0-C12-F}  at {&P0-C12-S} + 1
            v-doc-lack-sum              format {&P0-C14-F}  at {&P0-C14-S} + 1
    .
    put stream Out-Stream
        skip (2)
            "Гл. Бухгалтер:_______________________________________________________________ "                       at {&P-S}
        skip (1)
            "Начальник розничной сети:____________________________________________________ "                       at {&P-S}
    .
end.
end procedure. /* print-footer */

/*==========================================================================*/
procedure print-end-of-page :
do
on error undo, return error
:
define input parameter p-print-continue-line    as logical      no-undo.

    put stream Out-Stream
        skip
            v-single-line           format "X({&P0-X})"     at {&P-S}
        skip
            "Итого: "                                       at {&P0-C04-S}
            v-page-before-sum       format {&P0-C08-F}      at {&P0-C08-S} + 1
            v-page-after-sum        format {&P0-C10-F}      at {&P0-C10-S} + 1
            v-page-surplus-sum      format {&P0-C12-F}      at {&P0-C12-S} + 1
            v-page-lack-sum         format {&P0-C14-F}      at {&P0-C14-S} + 1
    .
    if p-print-continue-line = yes
    then do:
        put stream Out-Stream
            skip
                v-single-line           format "X({&P0-X})"    at {&P-S}
            skip
                "Продолжение - на следующей странице"               at 30
        .
    end.
    assign
        v-doc-after-sum     = v-doc-after-sum     + v-page-after-sum
        v-doc-before-sum    = v-doc-before-sum    + v-page-before-sum
        v-doc-surplus-sum   = v-doc-surplus-sum   + v-page-surplus-sum
        v-doc-lack-sum      = v-doc-lack-sum      + v-page-lack-sum
    .
    assign
        v-page-after-sum   = 0
        v-page-before-sum  = 0
        v-page-surplus-sum = 0
        v-page-lack-sum    = 0
    .
end.
end procedure. /* print-end-of-page */


/*==========================================================================*/
procedure get-before-and-after-inv-qnty :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define output parameter p-before-qnty       as decimal          no-undo.
define output parameter p-before-sum-rubl   as decimal          no-undo.
define output parameter p-before-sum-base   as decimal          no-undo.
define output parameter p-after-qnty        as decimal          no-undo.
define output parameter p-after-sum-rubl    as decimal          no-undo.
define output parameter p-after-sum-base    as decimal          no-undo.

    define variable v-attr-value    as character     no-undo.
    define variable v-attr-type     as character     no-undo.

    define buffer buf_trn-doc-sum       for trn-doc-sum.
    define buffer buf_doc-line-sum      for doc-line-sum.
do
on error undo, return error
:
    { str/tdat-val.i
        p-doc-code
        {&trdcattr-addsum}
        v-attr-value
        v-attr-type
    }
    if lookup( {&sum-before-doc}, v-attr-value ) <> 0
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-before-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            assign
                p-before-qnty       = buf_doc-line-sum.fact-qnty
                p-before-sum-rubl   = buf_doc-line-sum.crsa-sum-rubl
                p-before-sum-base   = buf_doc-line-sum.crsa-sum-base
            .
        end.
        else do:
            message
                skip "Не найдена запись trn-doc-sum"
                skip(1)
                skip "Номер документа:" p-doc-code
                skip "Код товара:" p-gds-code
            view-as alert-box error.
            undo, return error .
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if lookup( {&sum-before-doc}, v-attr-value ) <> 0 */
    if lookup( {&sum-after-doc}, v-attr-value ) <> 0
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-after-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            assign
                p-after-qnty       = buf_doc-line-sum.fact-qnty
                p-after-sum-rubl   = buf_doc-line-sum.crsa-sum-rubl
                p-after-sum-base   = buf_doc-line-sum.crsa-sum-base
            .
        end.
        else do:
            message
                skip "Не найдена запись trn-doc-sum"
                skip(1)
                skip "Номер документа:" p-doc-code
                skip "Код товара:" p-gds-code
            view-as alert-box error.
            undo, return error .
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if lookup( {&sum-after-doc}, v-attr-value ) <> 0 */
end.
end procedure. /* export-before-and-after-inv-trn */

