block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr-actp.p $
$Archive: rep/fbr-actp.p $

Акт производства промежуточных ингредиентов

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbr-doc-recid      as recid            no-undo.
define input parameter p-print-in-rubl      as logical          no-undo.
define input parameter p-print-details      as logical          no-undo.
define input parameter p-fat                as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-actp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/fbr-actp.p $":U .
define variable vss-description as character no-undo init "Акт производства промежуточных ингредиентов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/fmtcli.i   }
{ gbl/cur-time.i }
{ trg/partslib.i }
{ rep/fbrrep.i   }

&scop stream-width 230
&scop left-margin 10
&scop right-margin 220
&scop max-width 200
&scop tab-stop1 54
&scop max-width-from-start 190
&scop max-width-from-tab1 76
&scop tab-stop2 70
&scop max-width-from-tab2 60
&scop tab-stop3 90
&scop tab-stop4 110

/*----S----- Таблица --------------------------------*/
&scoped-define P-S 3
&scoped-define P-X 191        /*длина линии*/
&scoped-define P-X0 189       /*длина внутренней линии = длина линии - 2*/
&scoped-define P-E    {&P-S}  + 190
&scoped-define P-C2-S {&P-S}  + 5
&scoped-define P-C3-S {&P-S}  + 15
&scoped-define P-C4-S {&P-S}  + 32
&scoped-define P-C5-S {&P-S}  + 83
&scoped-define P-C6-S {&P-S}  + 88
&scoped-define P-C7-S {&P-S}  + 100
&scoped-define P-C8-S {&P-S}  + 111
&scoped-define P-C9-S {&P-S}  + 128
&scoped-define P-C10-S {&P-S} + 145
&scoped-define P-C11-S {&P-S} + 162
&scoped-define P-C12-S {&P-S} + 173

&scoped-define P-C1-F ">>>9"
&scoped-define P-C2-F "999999999"
&scoped-define P-C3-F "X(16)"
&scoped-define P-C4-F "X(48)"
&scoped-define P-C5-F "X(4)"
&scoped-define P-C6-F "->>,>>9.99"
&scoped-define P-C7-F ">>,>>9.99"
&scoped-define P-C8-F "->>>,>>>,>>9.99"
&scoped-define P-C9-F "->>>,>>>,>>9.99"
&scoped-define P-C10-F "->>>,>>>,>>9.99"
&scoped-define P-C11-F ">>,>>9.99"
&scoped-define P-C12-F "->>>,>>>,>>9.99"

/*----E----- Таблица --------------------------------*/

define stream out-stream.

do
on error undo, return error
:
    define variable v-single-line   as character    no-undo.
    define variable v-underline     as character    no-undo.
    define variable v-organization  as character    no-undo.
    define variable v-line-counter  as integer      no-undo.
    define variable v-today         as date         no-undo.
    define variable v-time          as integer      no-undo.
    define variable v-have-transit  as logical      no-undo.

    define variable v-page-sum-rubl         as decimal       no-undo.
    define variable v-page-sum-base         as decimal       no-undo.
    define variable v-page-sum-vat-rubl     as decimal       no-undo.
    define variable v-page-sum-vat-base     as decimal       no-undo.
    define variable v-page-sum-sale-rubl    as decimal       no-undo.

    define variable v-doc-sum-rubl          as decimal       no-undo.
    define variable v-doc-sum-base          as decimal       no-undo.
    define variable v-doc-sum-vat-rubl      as decimal       no-undo.
    define variable v-doc-sum-vat-base      as decimal       no-undo.
    define variable v-doc-sum-sale-rubl     as decimal       no-undo.
    define variable v-is-base               as logical       no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_fbr-line              for fbr-line.
    define buffer buf_temp_fbrrep-goods    for temp_fbrrep-goods.

    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    { gbl/rbisbase.i
        v-is-base
    }
    assign v-single-line = fill( "-", {&max-width} ).
    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    { gbl/working.i }
    { cmp/open-out.i stream out-stream " " {&stream-width} }
    assign
        v-single-line  = fill( "-", {&stream-width} )
        v-underline    = fill( "_", {&stream-width} )
        v-line-counter = 0
    .
    run fmtcli-get-client in this-procedure (
          input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
    ).
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    put stream Out-Stream
        skip space({&P-S})
            string( "Объект:   ("
                    + buf_fbr-doc.obj-type
                    + " " + string( buf_fbr-doc.obj-code )
                    + ")    " + v-fmtcli-name )                        format "X({&max-width-from-start})"
        skip(1) space({&P-S})
            "Дата печати: "
            string( v-today, "99/99/9999" )                 format "X(10)"
            "Акт производства промежуточных ингредиентов"                                   at {&P-S} + 10 + 40
    .
    run print-header in this-procedure (
        input yes
    ).
    run fbrrep-fill-for-fbr-actp in this-procedure (
        input buf_fbr-doc.doc-code
    ).
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
        assign
            v-have-transit          = yes
            v-line-counter          = v-line-counter + 1
            v-page-sum-rubl         = v-page-sum-rubl      + buf_temp_fbrrep-goods.sum-cost-rubl
            v-page-sum-base         = v-page-sum-base      + buf_temp_fbrrep-goods.sum-cost-base
            v-page-sum-vat-rubl     = v-page-sum-vat-rubl  + buf_temp_fbrrep-goods.sum-vat-cost-rubl
            v-page-sum-vat-base     = v-page-sum-vat-base  + buf_temp_fbrrep-goods.sum-vat-cost-base
            v-page-sum-sale-rubl    = v-page-sum-sale-rubl + ( buf_temp_fbrrep-goods.price-sale * buf_temp_fbrrep-goods.fact-qnty )
        .
        run print-line in this-procedure (
              input buf_temp_fbrrep-goods.gds-code
            , input p-print-in-rubl
            , input v-is-base
        ).
    end.        /* for each buf_fbr-line */
    if v-have-transit = no
    then do:    /* Нет транзитных ингредиентов, нечего печатать */
        output stream Out-Stream close.
        { gbl/stopwork.i }
    end.        /* if v-have-transit = no */
    else do:
        run print-footer in this-procedure (
              input p-print-in-rubl
            , input v-is-base
        ).
        output stream Out-Stream close.
        { gbl/stopwork.i }
        { rep/q-print.i 8 }
    end.
end.

/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-print-rubl as logical      no-undo.
define input parameter p-is-base as logical      no-undo.

    define variable v-qnty           as decimal       no-undo.
    define variable v-cost           as decimal       no-undo.   /* Уч. цена */
    define variable v-sum-cost       as decimal       no-undo.
    define variable v-sum-vat-cost   as decimal       no-undo.
    define variable v-sum-all-cost   as decimal       no-undo.   /* Сумма с НДС */
    define variable v-price-sale     as decimal       no-undo.
    define variable v-sum-price-sale as decimal       no-undo.

    define variable v-qnty-length           as integer       no-undo.
    define variable v-cost-length           as integer       no-undo.   /* Уч. цена */
    define variable v-sum-cost-length       as integer       no-undo.
    define variable v-sum-vat-cost-length   as integer       no-undo.
    define variable v-sum-all-cost-length   as integer       no-undo.   /* Сумма с НДС */
    define variable v-price-sale-length     as integer       no-undo.
    define variable v-sum-price-sale-length as integer       no-undo.

    define buffer buf_temp_fbrrep-goods        for temp_fbrrep-goods.

    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.gds-code = p-gds-code
    .
    run print-header in this-procedure (
        input no
    ).
    assign
        v-qnty           = buf_temp_fbrrep-goods.fact-qnty
        v-price-sale     = buf_temp_fbrrep-goods.price-sale
        v-sum-price-sale = buf_temp_fbrrep-goods.price-sale * buf_temp_fbrrep-goods.fact-qnty
    .
    if p-print-rubl = yes
    then do:
        assign
            v-cost           = buf_temp_fbrrep-goods.sum-cost-rubl / buf_temp_fbrrep-goods.fact-qnty
            v-sum-cost       = buf_temp_fbrrep-goods.sum-cost-rubl
            v-sum-vat-cost   = buf_temp_fbrrep-goods.sum-vat-cost-rubl
            v-sum-all-cost   = buf_temp_fbrrep-goods.sum-cost-rubl + buf_temp_fbrrep-goods.sum-vat-cost-rubl
        .
    end.        /* p-print-rubl = yes */
    else do:
        assign
            v-cost           = buf_temp_fbrrep-goods.sum-cost-base / buf_temp_fbrrep-goods.fact-qnty
            v-sum-cost       = buf_temp_fbrrep-goods.sum-cost-base
            v-sum-vat-cost   = buf_temp_fbrrep-goods.sum-vat-cost-base
            v-sum-all-cost   = buf_temp_fbrrep-goods.sum-cost-base + buf_temp_fbrrep-goods.sum-vat-cost-base
        .
    end.        /* NOT ( p-print-rubl = yes ) */
    assign
        v-qnty-length           = length( string( v-qnty          , {&P-C6-F}  ) )
        v-cost-length           = length( string( v-cost          , {&P-C7-F}  ) )
        v-sum-cost-length       = length( string( v-sum-cost      , {&P-C8-F}  ) )
        v-sum-vat-cost-length   = length( string( v-sum-vat-cost  , {&P-C9-F}  ) )
        v-sum-all-cost-length   = length( string( v-sum-all-cost  , {&P-C10-F} ) )
        v-price-sale-length     = length( string( v-price-sale    , {&P-C11-F} ) )
        v-sum-price-sale-length = length( string( v-sum-price-sale, {&P-C12-F} ) )
    .
    put stream Out-Stream
        skip
            "|"                                                     at {&P-S}
            v-line-counter                      format {&P-C1-F}
            "|"                                                     at {&P-C2-S}
            buf_temp_fbrrep-goods.gds-code     format {&P-C2-F}
            "|"                                                     at {&P-C3-S}
            buf_temp_fbrrep-goods.artic        format {&P-C3-F}
            "|"                                                     at {&P-C4-S}
            buf_temp_fbrrep-goods.gds-name     format {&P-C4-F}
            "|"                                                     at {&P-C5-S}
            buf_temp_fbrrep-goods.unit-base    format {&P-C5-F}
            "|"                                                     at {&P-C6-S}
            v-qnty                       format {&P-C6-F}    at right-field( {&P-C7-S} , v-qnty-length               )
            "|"                                                     at {&P-C7-S}
            v-cost                       format {&P-C7-F}    at right-field( {&P-C8-S} , v-cost-length               )
            "|"                                                     at {&P-C8-S}
            v-sum-cost                   format {&P-C8-F}    at right-field( {&P-C9-S} , v-sum-cost-length           )
            "|"                                                     at {&P-C9-S}
            v-sum-vat-cost               format {&P-C9-F}    at right-field( {&P-C10-S}, v-sum-vat-cost-length       )
            "|"                                                     at {&P-C10-S}
            v-sum-all-cost               format {&P-C10-F}   at right-field( {&P-C11-S}, v-sum-all-cost-length       )
            "|"                                                     at {&P-C11-S}
    .
    if ( p-is-base   = no
        and p-print-rubl = yes )
    or ( p-is-base   = yes
        and p-print-rubl = no )
    then do:
        put stream Out-Stream
                v-price-sale                 format {&P-C11-F}   at right-field( {&P-C12-S}, v-price-sale-length         )
        .
    end.
    put stream Out-Stream
            "|"                                             at {&P-C12-S}
    .
    if ( p-is-base   = no
        and p-print-rubl = yes )
    or ( p-is-base   = yes
        and p-print-rubl = no )
    then do:
        put stream Out-Stream
                v-sum-price-sale             format {&P-C12-F}   at right-field( {&P-E}    ,     v-sum-price-sale-length )
        .
    end.
    put stream Out-Stream
            "|"                                                     at {&P-E}
    .
    if line-counter( Out-stream ) + 2 > page-size( Out-stream )
    then do:
        run print-end-of-page in this-procedure (
              input p-print-rubl
            , input yes
            , input p-is-base
        ).
    end.
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-header :
do
on error undo, return error
:
define input parameter p-first  as logical      no-undo.
    if line-counter( Out-stream ) = 0
    or p-first = yes
    then do:
        put stream Out-Stream
            skip string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)"   at right-field( {&P-E}, 13)
        .
        put stream Out-Stream
            skip
                v-single-line           format "X({&P-X})"    at {&P-S}
            skip
                "|"                                                 at {&P-S}
                "N"                                                 at center-field( {&P-S}, {&P-C2-S}, 1 )
                "|"                                                 at {&P-C2-S}
                "Код"                                               at center-field( {&P-C2-S}, {&P-C3-S}, 3 )
                "|"                                                 at {&P-C3-S}
                "Артикул"                                           at center-field( {&P-C3-S}, {&P-C4-S}, 7 )
                "|"                                                 at {&P-C4-S}
                "Название товара"                                   at {&P-C4-S} + 2
                "|"                                                 at {&P-C5-S}
                "Ед."                                               at center-field( {&P-C5-S}, {&P-C6-S}, 3 )
                "|"                                                 at {&P-C6-S}
                "Количество"                                        at center-field( {&P-C6-S}, {&P-C7-S}, 10 )
                "|"                                                 at {&P-C7-S}
                "Уч.цена"                                           at center-field( {&P-C7-S}, {&P-C8-S}, 7 )
                "|"                                                 at {&P-C8-S}
                "Сумма уч.цен"                                      at center-field( {&P-C8-S}, {&P-C9-S}, 12 )
                "|"                                                 at {&P-C9-S}
                "Сумма НДС"                                         at center-field( {&P-C9-S}, {&P-C10-S}, 9 )
                "|"                                                 at {&P-C10-S}
                "Сумма уч.цен"                                      at center-field( {&P-C10-S}, {&P-C11-S}, 12 )
                "|"                                                 at {&P-C11-S}
                "Продажная"                                         at center-field( {&P-C11-S}, {&P-C12-S}, 9 )
                "|"                                                 at {&P-C12-S}
                "Сумма"                                             at center-field( {&P-C12-S}, {&P-E}, 5 )
                "|"                                                 at {&P-E}
            skip
                "|"                                                 at {&P-S}
                "п/п"                                               at center-field( {&P-S}, {&P-C2-S}, 3 )
                "|"                                                 at {&P-C2-S}
                "|"                                                 at {&P-C3-S}
                "|"                                                 at {&P-C4-S}
                "|"                                                 at {&P-C5-S}
                "изм."                                              at center-field( {&P-C5-S}, {&P-C6-S}, 4 )
                "|"                                                 at {&P-C6-S}
                "|"                                                 at {&P-C7-S}
                "без НДС"                                           at center-field( {&P-C7-S}, {&P-C8-S}, 7 )
                "|"                                                 at {&P-C8-S}
                "без НДС"                                           at center-field( {&P-C8-S}, {&P-C9-S}, 7 )
                "|"                                                 at {&P-C9-S}
                "|"                                                 at {&P-C10-S}
                "с НДС"                                             at center-field( {&P-C10-S}, {&P-C11-S}, 5 )
                "|"                                                 at {&P-C11-S}
                "цена"                                              at center-field( {&P-C11-S}, {&P-C12-S}, 4 )
                "|"                                                 at {&P-C12-S}
                "прод.цен"                                          at center-field( {&P-C12-S}, {&P-E}, 8 )
                "|"                                                 at {&P-E}
            skip
                v-single-line           format "X({&P-X})"    at {&P-S}
        .
    end.
end.
end procedure. /* print-header */

/*==========================================================================*/
procedure print-footer :
do
on error undo, return error
:
define input parameter p-print-rubl as logical      no-undo.
define input parameter p-is-base    as logical      no-undo.

    define variable v-all-sum-cost as decimal       no-undo.

    if p-print-rubl = yes
    then do:
        assign
            v-all-sum-cost = v-doc-sum-rubl + v-page-sum-rubl + v-doc-sum-vat-rubl + v-page-sum-vat-rubl
        .
    end.
    else do:
        assign
            v-all-sum-cost = v-doc-sum-base + v-page-sum-base + v-doc-sum-vat-base + v-page-sum-vat-base
        .
    end.
    run print-end-of-page in this-procedure (
          input p-print-rubl
        , input no
        , input p-is-base
    ).
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream out-stream.
    end.
    put stream Out-Stream
        skip (1)
            "Всего промежуточных ингредиентов на сумму (в учетных ценах):   "                       at {&P-S}
            v-all-sum-cost                                                      format {&P-C10-F}
    .
    if ( p-is-base   = no
        and p-print-rubl = yes )
    or ( p-is-base   = yes
        and p-print-rubl = no )
    then do:
        put stream Out-Stream
            skip (1)
                "Всего промежуточных ингредиентов на сумму (в продажных ценах): "                       at {&P-S}
                v-doc-sum-sale-rubl + v-page-sum-sale-rubl                          format {&P-C10-F}
        .
    end.
    put stream Out-Stream
        skip (2)
            "Материально ответственное лицо:_______________________________ "                       at {&P-S}
        skip (1)
            "Бухгалтер:____________________________________________________ "                       at {&P-S}
        skip (1)
            "Обработал:____________________________________________________ "                       at {&P-S}
    .
end.
end procedure. /* print-footer */

/*==========================================================================*/
procedure print-end-of-page :
do
on error undo, return error
:
define input parameter p-print-rubl             as logical      no-undo.
define input parameter p-print-continue-line    as logical      no-undo.
define input parameter p-is-base                as logical      no-undo.

    define variable v-sum-cost       as decimal       no-undo.
    define variable v-sum-vat-cost   as decimal       no-undo.
    define variable v-sum-all-cost   as decimal       no-undo.   /* Сумма с НДС */
    define variable v-sum-price-sale as decimal       no-undo.

    define variable v-sum-cost-length       as integer       no-undo.
    define variable v-sum-vat-cost-length   as integer       no-undo.
    define variable v-sum-all-cost-length   as integer       no-undo.   /* Сумма с НДС */
    define variable v-sum-price-sale-length as integer       no-undo.

    if p-print-rubl = yes
    then do:
        assign
            v-sum-cost       = v-page-sum-rubl
            v-sum-vat-cost   = v-page-sum-vat-rubl
            v-sum-all-cost   = v-page-sum-rubl + v-page-sum-vat-rubl
        .
    end.        /* p-print-rubl = yes  */
    else do:
        assign
            v-sum-cost       = v-page-sum-base
            v-sum-vat-cost   = v-page-sum-vat-base
            v-sum-all-cost   = v-page-sum-base + v-page-sum-vat-base
        .
    end.        /* NOT ( p-print-rubl = yes  ) */
    assign
        v-sum-price-sale        = v-page-sum-sale-rubl
        v-sum-cost-length       = length( string( v-sum-cost      , {&P-C8-F}  ) )
        v-sum-vat-cost-length   = length( string( v-sum-vat-cost  , {&P-C9-F}  ) )
        v-sum-all-cost-length   = length( string( v-sum-all-cost  , {&P-C10-F} ) )
        v-sum-price-sale-length = length( string( v-sum-price-sale, {&P-C12-F} ) )
    .
    put stream Out-Stream
        skip
            v-single-line           format "X({&P-X})"    at {&P-S}
        skip
            "Итого: "                                           at {&P-C4-S}
            v-sum-cost              format {&P-C8-F}    at right-field( {&P-C9-S} , v-sum-cost-length       )
            v-sum-vat-cost          format {&P-C9-F}    at right-field( {&P-C10-S}, v-sum-vat-cost-length   )
            v-sum-all-cost          format {&P-C10-F}   at right-field( {&P-C11-S}, v-sum-all-cost-length   )
    .
    if ( p-is-base   = no
        and p-print-rubl = yes )
    or ( p-is-base   = yes
        and p-print-rubl = no )
    then do:
        put stream Out-Stream
                v-sum-price-sale        format {&P-C12-F}   at right-field( {&P-E}    , v-sum-price-sale-length )
        .
    end.
    if p-print-continue-line = yes
    then do:
        put stream Out-Stream
            skip
                v-single-line           format "X({&P-X})"    at {&P-S}
            skip
                "Продолжение - на следующей странице"               at 30
        .
    end.
    assign
        v-doc-sum-rubl      = v-doc-sum-rubl      + v-page-sum-rubl
        v-doc-sum-base      = v-doc-sum-base      + v-page-sum-base
        v-doc-sum-vat-rubl  = v-doc-sum-vat-rubl  + v-page-sum-vat-rubl
        v-doc-sum-vat-base  = v-doc-sum-vat-base  + v-page-sum-vat-base
        v-doc-sum-sale-rubl = v-doc-sum-sale-rubl + v-page-sum-sale-rubl
    .
    assign
        v-page-sum-rubl      = 0
        v-page-sum-base      = 0
        v-page-sum-vat-rubl  = 0
        v-page-sum-vat-base  = 0
        v-page-sum-sale-rubl = 0
    .
end.
end procedure. /* print-end-of-page */