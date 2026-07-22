block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-specsg.p $
$Archive: rep/r-specsg.p $

Спецификация по срокам годности

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-specsg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-specsg.p $":U .
define variable vss-description as character no-undo init "Спецификация по срокам годности".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ str/clcprtsl.i }

&scoped-define left-margin 1
&scoped-define right-margin 140
&scoped-define max-width 138
&scoped-define tab-stop1 22
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

&scop max-width-from-tab1 86
&scop tab-stop2 60
&scop max-width-from-tab2 70
&scop tab-stop3 80
&scop tab-stop4 100
&scop note-line-size 12

/*----S----- Таблица --------------------------------*/
&GLOB P-S 1
&GLOB P-X 135        /*длина линии*/
&GLOB P-X0 133       /*длина внутренней линии = длина линии - 2*/
&GLOB P-C3-X  13     /*ширина колонки производителя (3+1+9)*/
&GLOB P-C4-X  35     /*ширина колонки названия товара*/

&GLOB P-C2-S  {&P-S} + 11
&GLOB P-C3-S  {&P-S} + 28
&GLOB P-C4-S  {&P-S} + 42
&GLOB P-C5-S  {&P-S} + 81
&GLOB P-C6-S  {&P-S} + 93
&GLOB P-C7-S  {&P-S} + 108
&GLOB P-C8-S  {&P-S} + 124
&GLOB P-E     {&P-S} + 135
/*----E----- Таблица --------------------------------*/

    define shared variable sort-name    as logical          no-undo.
    define shared variable sort-gr      as logical          no-undo.

    define stream out-stream .

    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.

    define variable v-cli-name      as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-income        as logical      no-undo.

    define variable v-host-code     as integer      no-undo.

    define variable v-first-line    as logical      no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_trn-doc   for trn-doc.
    define buffer buf_goods     for goods.
    define buffer buf_clients   for clients.
    define buffer buf_doc-line  for doc-line.
do
for buf_trn-doc
  , buf_goods
  , buf_clients
  , buf_doc-line
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
    .
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    .
    assign
        v-obj-name = string( buf_clients.obj-name )
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.cli-type
           and buf_clients.obj-code = buf_trn-doc.cli-code
    .
    if available buf_clients
    then do:
        assign
            v-cli-name = string( buf_clients.obj-name )
        .
    end.
    else do:
        assign
            v-cli-name = ""
        .
    end.
    assign
        v-income            = ( if buf_trn-doc.doc-type = {&income}
                                or buf_trn-doc.doc-type = {&return}
                                then yes
                                else no   )
        v-single-line       = fill( "-", {&right-margin} )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream out-stream " " {&CS_PS} }

    form header
        space({&P-S}) v-single-line format "X({&P-X})" skip
        'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream out-stream frame BottomFrame .

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    .

    { gbl/working.i }

    put stream out-stream
            buf_clients.obj-name format "X(60)" at {&P-S} + ( ( {&P-E} - {&P-S}) / 2 ) - ( length( buf_clients.obj-name ) / 2 )
        skip (1) space( {&tab-stop1} )
            "Приложение к документу. Тип: "
            buf_trn-doc.doc-type                                     format "X(20)"
            "   Номер: "
            buf_trn-doc.doc-code                                     format "X(14)"
            "   Дата: "
            string(buf_trn-doc.doc-date)                             format "X(10)"
            ( if buf_trn-doc.status_ <> {&fact} then "   Статус: " + caps(buf_trn-doc.status_) else " " )
                                                                        format "X(25)"
        skip space( {&tab-stop1} ) "Поставщик (отправитель): "
            (if v-income = yes then v-cli-name else v-obj-name )    format "X(60)"
        skip space( {&tab-stop1} ) "Покупатель (получатель): "
            (if v-income = yes then v-obj-name else v-cli-name )    format "X(60)"
        skip
    .
    run print-header in this-procedure .
    if sort-gr = yes
    then do:
        if sort-name = yes
        then do:
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code  = buf_trn-doc.doc-code
             , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_goods.grp-name
                  by buf_goods.gds-name
            :
                if first-of(buf_goods.grp-name)
                then do:
                    run print-group-line in this-procedure (
                        input buf_goods.gds-code
                    ).
                end.
                if last( buf_goods.gds-name )
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
                then do:
                    run print-page-result in this-procedure (
                        input ""
                    ).
                    if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                    then do:
                        put stream out-stream
                            skip space({&P-S})
                                "|" v-single-line format "X({&P-X0})" "|"
                        .
                    end.
                    page stream Out-Stream .
                    run print-header in this-procedure .
                end.
                run print-line in this-procedure (
                      input buf_trn-doc.doc-code
                    , input buf_doc-line.artic
                    , input buf_doc-line.prod-type
                    , input buf_doc-line.prod-code
                ).
            end.
        end.        /* sort-name = yes */
        else do:
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code  = buf_trn-doc.doc-code
             , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_goods.grp-name
                  by buf_doc-line.line-num
            :
                if first-of( buf_goods.grp-name )
                then do:
                    run print-group-line in this-procedure (
                        input buf_goods.gds-code
                    ).
                end.
                if last( buf_doc-line.line-num )
                    and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
                then do:
                    run print-page-result in this-procedure (
                        input ""
                    ).
                    if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                    then do:
                        put stream out-stream
                            skip space({&P-S})
                                "|" v-single-line format "X({&P-X0})" "|"
                        .
                    end.
                    page stream Out-Stream .
                    run print-header in this-procedure .
                end.
                run print-line in this-procedure (
                      input buf_trn-doc.doc-code
                    , input buf_doc-line.artic
                    , input buf_doc-line.prod-type
                    , input buf_doc-line.prod-code
                ).
            end.
        end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
        if sort-name = yes
        then do:
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code  = buf_trn-doc.doc-code
             , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_goods.gds-name
            :
                if last( buf_goods.gds-name )
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
                then do:
                    run print-page-result in this-procedure (
                        input ""
                    ).
                    if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                    then do:
                        put stream out-stream
                            skip space({&P-S})
                                "|" v-single-line format "X({&P-X0})" "|"
                        .
                    end.
                    page stream Out-Stream .
                    run print-header in this-procedure .
                end.
                run print-line in this-procedure (
                      input buf_trn-doc.doc-code
                    , input buf_doc-line.artic
                    , input buf_doc-line.prod-type
                    , input buf_doc-line.prod-code
                ).
            end.
        end.        /* sort-name = yes */
        else do:
            for each buf_doc-line no-lock
               where buf_doc-line.doc-code  = buf_trn-doc.doc-code
             , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_doc-line.line-num
            :
                if last( buf_doc-line.line-num )
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
                then do:
                    run print-page-result in this-procedure (
                        input ""
                    ).
                    if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                    then do:
                        put stream out-stream
                            skip space({&P-S})
                                "|" v-single-line format "X({&P-X0})" "|"
                        .
                    end.
                    page stream Out-Stream .
                    run print-header in this-procedure .
                end.
                run print-line in this-procedure (
                      input buf_trn-doc.doc-code
                    , input buf_doc-line.artic
                    , input buf_doc-line.prod-type
                    , input buf_doc-line.prod-code
                ).
            end.
        end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
    if page-number ( Out-Stream ) > 1
    then do:
        run print-page-result in this-procedure  ( input "" ) .
    end.        /* if page-number ( Out-Stream ) > 1  */
    else do:
        run print-page-result in this-procedure  ( input "no-line" ) .
    end.
    run print-total-result in this-procedure .

    hide stream Out-Stream frame BottomFrame .

    run print-note in this-procedure .


    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 4 }

end.






/*==========================================================================*/
procedure print-header :
do
on error undo, return error
:
assign
    v-first-line = yes
.
put stream out-stream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "Код"                   at center-field({&P-S} + 1, {&P-C2-S}, 3)
        "|"                     at {&P-C2-S}
        "Артикул"               at center-field({&P-C2-S}, {&P-C3-S}, 7)
        "|"                     at {&P-C3-S}
        "Производитель"         at center-field({&P-C3-S}, {&P-C4-S}, 13)
        "|"                     at {&P-C4-S}
        "Наименование товара"   at {&P-C4-S} + 2
        "|"                     at {&P-C5-S}
        "Количество"            at center-field({&P-C5-S}, {&P-C6-S}, 10)
        "|"                     at {&P-C6-S}
        "Цена"                  at center-field({&P-C6-S}, {&P-C7-S}, 4)
        "|"                     at {&P-C7-S}
        "Сумма"                 at center-field({&P-C7-S}, {&P-C8-S}, 10)
        "|"                     at {&P-C8-S}
        "Дата"                  at center-field({&P-C8-S}, {&P-E}, 4)
        "|"                     at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
.
end.
end procedure. /* print-header */









/*==========================================================================*/
procedure print-line :

define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.

    define variable v-last-date     as date         no-undo.
    define variable v-same-date     as logical      no-undo.
    define variable v-first-parts   as logical      no-undo.
    define variable v-qnty          as decimal      no-undo.
    define variable v-price         as decimal      no-undo.
    define variable v-sum-price     as decimal      no-undo.

    define buffer buf_doc-line  for doc-line.
    define buffer buf_parts     for parts.
    define buffer buf_goods     for goods.
do
for buf_parts
on error undo, return error
:
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = p-doc-code
           and buf_doc-line.artic       = p-artic
           and buf_doc-line.prod-type   = p-prod-type
           and buf_doc-line.prod-code   = p-prod-code
    .
    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    .
    assign
        v-first-parts   = yes
        v-same-date     = yes
    .
    check-same-date:
    for each buf_parts no-lock
       where buf_parts.out-code   = buf_doc-line.doc-code
         and buf_parts.obj-type   = buf_doc-line.obj-type
         and buf_parts.obj-code   = buf_doc-line.obj-code
         and buf_parts.prod-type  = buf_doc-line.prod-type
         and buf_parts.prod-code  = buf_doc-line.prod-code
         and buf_parts.artic      = buf_doc-line.artic
    on error undo, return error
    :
        if v-first-parts = yes
        then do:
            assign
                v-last-date     = buf_parts.last-date
                v-first-parts   = no
                v-same-date     = yes
                v-qnty          = buf_parts.fact-qnty
            .
        end.
        else do:
            if v-last-date <> buf_parts.last-date
            then do:        /* Будет печать по партиям */
                assign
                    v-same-date = no
                .
                leave check-same-date.
            end.
            else do:
                assign
                    v-qnty = v-qnty + buf_parts.fact-qnty
                .
            end.
        end.
    end.        /* for each buf_parts */
    if v-same-date = yes
    then do:
        run clcprtsl_calc-line in this-procedure (
            input recid( buf_doc-line )
        ).
        find first tt-allsum-line
             where tt-allsum-line.sum-type = {&sum-general}
        .
        if printrubl
        then do:
            assign
                v-sum-price = tt-allsum-line.sum-dsc-rubl-acc
                v-price     = v-sum-price / v-qnty

            .
        end.
        else do:
            assign
                v-sum-price = tt-allsum-line.sum-dsc-base-acc
                v-price     = v-sum-price / v-qnty
            .
        end.
        put stream out-stream
            skip space({&P-S})  "|"
                string( buf_goods.gds-code, "999999999" )       format "X(9)"
                "|"   at {&P-C2-S}
                string( buf_goods.artic )                       format "X(16)"
                "|"   at {&P-C3-S}
                substitute( "&1 &2", buf_goods.prod-type, buf_goods.prod-code )  format "X({&P-C3-X})"
                "|"   at {&P-C4-S}
                buf_goods.gds-name                              format "X({&P-C4-X})"
                "|"   at {&P-C5-S}
                v-qnty                                          format "->>>>>9.<<<"
                "|"   at {&P-C6-S}
                v-price                                         format "->>,>>>,>>9.99"
                "|"   at {&P-C7-S}
                v-sum-price                                     format "->>>,>>>,>>9.99"
                "|"   at {&P-C8-S}
                ( if v-last-date = ?
                  then "   нет"
                  else string( v-last-date, "99.99.9999" ) )    format "X(10)"
                "|"   at {&P-E}
        .
        assign
            v-line-counter      = v-line-counter    + 1
        .
        if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( Out-Stream )
        then do:
            run print-page-result in this-procedure (
                input ""
            ) .
            page stream Out-Stream .
            run print-header in this-procedure .
        end.
    end.        /* if v-same-date = no */
    else do:
        for each buf_parts no-lock
           where buf_parts.out-code   = buf_doc-line.doc-code
             and buf_parts.obj-type   = buf_doc-line.obj-type
             and buf_parts.obj-code   = buf_doc-line.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic
        on error undo, return error
        :
            if printrubl
            then do:
                assign
                    v-price     = buf_parts.price-rubl
                    v-sum-price = v-price * buf_parts.fact-qnty
                .
            end.
            else do:
                assign
                    v-price     = buf_parts.price-base
                    v-sum-price = v-price * buf_parts.fact-qnty
                .
            end.
            put stream out-stream
                skip space({&P-S})  "|"
                    string( buf_goods.gds-code, "999999999" )       format "X(9)"
                    "|"   at {&P-C2-S}
                    string( buf_goods.artic )                       format "X(16)"
                    "|"   at {&P-C3-S}
                    substitute( "&1 &2", buf_goods.prod-type, buf_goods.prod-code )  format "X({&P-C3-X})"
                    "|"   at {&P-C4-S}
                    buf_goods.gds-name                              format "X({&P-C4-X})"
                    "|"   at {&P-C5-S}
                    buf_parts.fact-qnty                             format "->>>>>9.<<<"
                    "|"   at {&P-C6-S}
                    v-price                                         format "->>,>>>,>>9.99"
                    "|"   at {&P-C7-S}
                    v-sum-price                                     format "->>>,>>>,>>9.99"
                    "|"   at {&P-C8-S}
                    ( if buf_parts.last-date = ?
                    then "   нет"
                    else string( buf_parts.last-date, "99.99.9999" ) )    format "X(10)"
                    "|"   at {&P-E}
            .
            assign
                v-line-counter      = v-line-counter    + 1
            .
            if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure (
                    input ""
                ) .
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
        end.        /* for each buf_parts */
    end.        /* if v-same-date <> no */
    assign
        v-first-line = no
    .
end.
end procedure. /* print-line */












/*==========================================================================*/
procedure print-group-line :
define input parameter p-gds-code   as integer          no-undo.

    define buffer buf_goods     for goods.
do
for buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( Out-Stream )
    then do:
        run print-page-result in this-procedure ( input "" ) .
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes
    then do:
        put stream out-stream
            skip space({&P-S})
                "|" v-single-line format "X({&P-X0})" "|"
        .
    end.        /* p-print-type <> "no-line" */
    put stream out-stream
        skip space({&P-S})
            "|   ***  Группа:  "  + buf_goods.grp-name format "X(150)"
            "|" at {&P-E}
    .
end.
end procedure. /* print-group-line */









/*==========================================================================*/
procedure print-page-result :
do
on error undo, return error
:
define input parameter p-print-type as character no-undo.

/*
if p-print-type <> "no-line"
then do:
    put stream out-stream
        skip space({&P-S})
            "|" v-single-line format "X({&P-X0})" "|"
        skip space({&P-S})  "|        Итого по странице "
            "|"                 at {&P-C4-S}
            v-pg-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-C5-S}
            "|"                 at {&P-C6-S}
            v-pg-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at {&P-C7-S}
            "|"                 at {&P-C8-S}
            v-pg-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at {&P-C9-S}
            "|"                 at {&P-C10-S}
            v-pg-sum-slt                        format "->>>9.99"
            "|"                 at {&P-C11-S}
            "|"                 at {&P-C12-S}
            v-pg-sum-vat                        format "->>>>9.99"
            "|"                 at {&P-C13-S}
            "|"                 at {&P-C14-S}
            v-pg-sum-doc                        format "->>,>>>,>>9.99"
            "|"                 at {&P-E}
    .
end.
assign
    v-tot-sum-qnty      = v-tot-sum-qnty        + v-pg-sum-qnty
    v-tot-sum-no-taxes  = v-tot-sum-no-taxes    + v-pg-sum-no-taxes
    v-tot-sum-no-vat    = v-tot-sum-no-vat      + v-pg-sum-no-vat
    v-tot-sum-slt       = v-tot-sum-slt         + v-pg-sum-slt
    v-tot-sum-vat       = v-tot-sum-vat         + v-pg-sum-vat
    v-tot-sum-doc       = v-tot-sum-doc         + v-pg-sum-doc
    v-pg-sum-qnty       = 0
    v-pg-sum-no-taxes   = 0
    v-pg-sum-no-vat     = 0
    v-pg-sum-slt        = 0
    v-pg-sum-vat        = 0
    v-pg-sum-doc        = 0
.
*/
end.
end procedure. /* print-page-result */







/*==========================================================================*/
procedure print-total-result :
do
on error undo, return error
:
/*
    put stream out-stream
        skip space({&P-S})
            "|" v-single-line format "X({&P-X0})" "|"
        skip space({&P-S})  "|        В С Е Г О "
            "|"                 at {&P-C4-S}
            v-tot-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-C5-S}
            "|"                 at {&P-C6-S}
            v-tot-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at {&P-C7-S}
            "|"                 at {&P-C8-S}
            v-tot-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at {&P-C9-S}
            "|"                 at {&P-C10-S}
            v-tot-sum-slt                        format "->>>9.99"
            "|"                 at {&P-C11-S}
            "|"                 at {&P-C12-S}
            v-tot-sum-vat                        format "->>>>9.99"
            "|"                 at {&P-C13-S}
            "|"                 at {&P-C14-S}
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
            "|"                 at {&P-E}
    .
*/
    put stream out-stream
        skip space({&P-S})
            v-single-line format "X({&P-X})"
    .
end.
end procedure. /* print-total-result */



















/*==========================================================================*/
procedure print-note :
do
on error undo, return error
:
    put stream out-stream
        skip(1) space({&tab-stop1})
            "Всего строк: "
            v-line-counter  format ">>>>>9"
    .
/*
    put stream out-stream
        skip space({&tab-stop1})
            "Сумма цен по документу составила: "
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
            ", в том числе налог с продаж: "
            v-tot-sum-slt                        format "->>>9.99"
            ", НДС: "
            v-tot-sum-vat                        format "->>>>9.99"
        skip(1) space({&tab-stop1})
            "Сдал:"
        skip space({&tab-stop1})
            "Зав.секцией/Зав.складом:            _______        ___________________"
        skip space({&tab-stop1})
            "                                    подпись        расшифровка подписи"
    .
    if buf_trn-doc.doc-type <> {&write-off}
    then do:
        put stream out-stream
            skip(1) space({&tab-stop1})
                "Принял:"
            skip space({&tab-stop1})
                "Зав.секцией/Зав.складом:            _______        ___________________"
            skip space({&tab-stop1})
                "                                    подпись        расшифровка подписи"

        .
    end.
*/
end.
end procedure. /* print-total-result */