block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-rsrv.p $
$Archive: rep/r-rsrv.p $

Печать товаров с истекающими сроками годности.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
define input parameter p-classificator  as character        no-undo.
define input parameter p-sort-type      as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rsrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rsrv.p $":U .
define variable vss-description as character no-undo init "Печать товаров с истекающими сроками годности.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ gbl/cur-time.i }
{ gbl/godendo.i  }
{ str/clcprtsl.i }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }

define temp-table temp_result-line no-undo
    field obj-type      as character
    field obj-code      as integer
    field line-order    as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field prod-string   as character
    field gds-code      as integer
    field gds-name      as character
    field grp-name      as character
    field rsrv-qnty     as decimal
    field cost-sum      as decimal
    field free-qnty     as decimal
    field doc-code      as character
    field doc-date      as date
    field cli-string    as character
    field duration      as integer
    field class-order   as integer

    index pi is primary unique
        line-order
    index gds-code
        gds-code
    index artic
        artic
    index gds-name
        gds-name
    index class
        class-order
    index obj
        obj-type
        obj-code
.
define temp-table temp_classificator no-undo
    field class-order   as integer
    field class-code    as character
    field obj-type      as character
    field obj-code      as integer
    field class1-key    as character
    field class2-key    as character
    field class1-value  as character
    field class2-value  as character
    field sum-rsrv-qnty as decimal
    field sum-cost      as decimal
    field sum-free-qnty as decimal

    index pi is primary unique
        class-order
        obj-type
        obj-code
    index obj
        obj-type
        obj-code
    index code
        class-code
        class1-key
        class2-key
    index alphabet
        class1-value
.
define variable v-r-rsrv-sum-rsrv-qnty    as decimal      no-undo.
define variable v-r-rsrv-sum-cost         as decimal      no-undo.
define variable v-r-rsrv-sum-free-qnty    as decimal      no-undo.
define variable v-ext-doc-type-list as character extent 42 init
[
      {&TDEDT_Ras_Vnesh}      , no  , {&wayb}
    , {&TDEDT_Ras_Vnesh}      , no  , {&permitted}
    , {&TDEDT_Ras_Vnesh_VP}   , no  , {&wayb}
    , {&TDEDT_Ras_Vnesh_VP}   , no  , {&permitted}
    , {&TDEDT_Ras_Vnesh_Kass} , no  , {&cash-desk}
    , {&TDEDT_Spi_Vnesh}      , no  , {&wayb}
    , {&TDEDT_Spi_Vnesh}      , no  , {&permitted}
    , {&TDEDT_Inv}            , no  , {&wayb}
    , {&TDEDT_Inv}            , no  , {&permitted}
    , {&TDEDT_Inv}            , no  , {&doc-froze}
    , {&TDEDT_Peresort}       , no  , {&wayb}
    , {&TDEDT_Ras_Perem}      , yes , {&wayb}
    , {&TDEDT_Ras_Perem}      , yes , {&permitted}
    , {&TDEDT_Spi_Prvo}       , yes , {&manufactured}
]                                                           no-undo.

&scoped-define left-margin 5
&scoped-define right-margin 200
&scoped-define max-width 193
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

&scoped-define tab-stop1 22

/*----S----- Таблица --------------------------------*/
&scoped-define P-S 2
&scoped-define P-X 195        /*длина линии*/
&scoped-define P-X0 193       /*длина внутренней линии = длина линии - 2*/

&scoped-define P-C3-X  35     /*ширина колонки названия товара*/

&scoped-define P-C2-S  {&P-S} + 11
&scoped-define P-C3-S  {&P-S} + 28
&scoped-define P-C4-S  {&P-S} + 42
&scoped-define P-C5-S  {&P-S} + 82
&scoped-define P-C6-S  {&P-S} + 96
&scoped-define P-C7-S  {&P-S} + 110
&scoped-define P-C8-S  {&P-S} + 125
&scoped-define P-C9-S  {&P-S} + 139
&scoped-define P-C10-S {&P-S} + 156
&scoped-define P-C11-S {&P-S} + 168
&scoped-define P-C12-S {&P-S} + 182
&scoped-define P-E     {&P-S} + 195

/*----E----- Таблица --------------------------------*/

    define stream out-stream .

    define variable v-r-rsrv-line-counter          as integer      no-undo.
    define variable v-r-rsrv-single-line           as character    no-undo.
    define variable v-r-rsrv-double-line           as character    no-undo.
    define variable v-r-rsrv-first-line-printed    as logical      no-undo.
    define variable v-r-rsrv-class-order            as integer      no-undo.

    define variable v-data-present                  as logical      no-undo.

    define variable v-internal                      as logical      no-undo.
    define variable v-doc-type                      as character    no-undo.
    define variable v-ext-doc-type                  as character    no-undo.
    define variable v-status                        as character    no-undo.

    define variable v-counter                       as integer      no-undo.

    define buffer buf_temp_result-line      for temp_result-line.
    define buffer buf_temp_classificator    for temp_classificator.
    define buffer buf_obj-list              for obj-list.
    define buffer buf_trn-doc               for trn-doc.
    define buffer buf_doc-line              for doc-line.

do
for buf_temp_result-line
  , buf_temp_classificator
  , buf_obj-list
  , buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    { rep/repfrm.i def   }
    { rep/repfrm.i on 20 }
    assign
        v-r-rsrv-line-counter  = 0
        v-r-rsrv-single-line   = fill( "-", {&P-X} )
        v-r-rsrv-double-line   = fill( "=", {&P-X} )
        v-r-rsrv-class-order   = 0
    .
    for each buf_obj-list
    on error undo, return error
    :
        do v-counter = 1 to 13
        on error undo, return error
        :
            assign
                v-ext-doc-type  = v-ext-doc-type-list[ v-counter * 3 - 2 ]
                v-internal      = ( v-ext-doc-type-list[ v-counter * 3 - 1 ] = "yes" )
                v-status        = v-ext-doc-type-list[ v-counter * 3 ]
            .
            { gbl/trnextdt.i
                v-ext-doc-type
                v-doc-type
            }
            for each buf_trn-doc no-lock
            where buf_trn-doc.obj-type       = buf_obj-list.obj-type
                and buf_trn-doc.obj-code     = buf_obj-list.obj-code
                and buf_trn-doc.internal     = v-internal
                and buf_trn-doc.doc-type     = v-doc-type
                and buf_trn-doc.ext-doc-type = v-ext-doc-type
                and buf_trn-doc.status_      = v-status
            on error undo, return error
            :
                for each buf_doc-line no-lock
                where buf_doc-line.doc-code = buf_trn-doc.doc-code
                on error undo, return error
                :
                    run out-selected-goods in this-procedure (
                          input rowid( buf_doc-line )
                        , input p-classificator
                    ).
                end.        /* for each buf_doc-line */
            end.        /* for each buf_trn-doc */
        end.        /* do v-counter = 1 to 13 */
    end.        /* for each buf_obj-list */
    run check-data-presence in this-procedure (
        output v-data-present
    ).
    if v-data-present = yes
    then do:
        { cmp/open-out.i stream out-stream " " ReportPageHeight }
        form header
            space({&P-S}) v-r-rsrv-single-line format "X({&P-X})"
            skip "Продолжение - на следующей странице" at 90
            with frame BottomFrame
                width {&DOS_CW_2}
                page-bottom
                no-labels
                no-box
        .
        view stream out-stream frame BottomFrame .
        run print-header in this-procedure.
    end.        /* v-data-present = yes */
    else do:
        message
            "Нет зарезервированных товаров."
        view-as alert-box information
        title "Нет строк для печати".
        undo, return .
    end.
    /*
        output to "111111.txt".
            for each temp_classificator
            :
                export temp_classificator.
            end.
            put unformatted skip (2) .
            for each temp_result-line
            :
                export temp_result-line.
            end.
        output close.
    */
    define variable v-first-object    as logical      no-undo.
    assign
        v-first-object = yes
    .
    for each buf_obj-list
    on error undo, return error
    :
        run print-object-string in this-procedure (
              input buf_obj-list.obj-type
            , input buf_obj-list.obj-code
            , input v-first-object
        ).
        assign
            v-first-object = no
        .
        for each buf_temp_classificator
           where buf_temp_classificator.class-code = p-classificator
             and buf_temp_classificator.obj-type   = buf_obj-list.obj-type
             and buf_temp_classificator.obj-code   = buf_obj-list.obj-code
        break by buf_temp_classificator.class1-value
        on error undo, return error
        :
            if first-of( buf_temp_classificator.class1-value )
            then do:
                run print-classificator in this-procedure (
                    input buf_temp_classificator.class-order
                ).
            end.
            case p-sort-type
            :
                when "sort-code":U
                then do:
                    for each buf_temp_result-line
                    where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                    by buf_temp_result-line.gds-code
                    on error undo, return error
                    :
                        run print-line in this-procedure (
                            input buf_temp_result-line.line-order
                        ).
                    end.        /* for each buf_temp_result-line */
                end.        /* when "sort-code":U */
                when "sort-artic":U
                then do:
                    for each buf_temp_result-line
                    where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                    by buf_temp_result-line.artic
                    on error undo, return error
                    :
                        run print-line in this-procedure (
                            input buf_temp_result-line.line-order
                        ).
                    end.        /* for each buf_temp_result-line */
                end.        /* when "sort-artic":U */
                when "sort-name":U
                then do:
                    for each buf_temp_result-line
                    where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                    by buf_temp_result-line.gds-name
                    on error undo, return error
                    :
                        run print-line in this-procedure (
                            input buf_temp_result-line.line-order
                        ).
                    end.        /* for each buf_temp_result-line */
                end.        /* when "sort-name":U */
            end case.       /* case p-sort-type */
            if last-of( buf_temp_classificator.class1-value )
            then do:
                run print-classificator-itog in this-procedure (
                      input buf_temp_classificator.sum-rsrv-qnty
                    , input buf_temp_classificator.sum-cost
                    , input buf_temp_classificator.sum-free-qnty
                ).
            end.
        end.        /* for each buf_temp_classificator */
    end.        /* for each buf_obj-list */
    run print-footer in this-procedure .
    hide stream out-stream frame BottomFrame .
    output stream out-stream close.
    { rep/repfrm.i off }
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    define variable v-orient-page as character no-undo .
    define variable DisabledOptions as integer   no-undo .
    run How-name in this-procedure (
        input ReportPageHeight,
        input ReportPageWidth,
        output v-orient-page )
        .
    if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                   else DisabledOptions = 0 .


    run gbl/prnfilen.w (
          input "":U
        , input DisabledOptions
        , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ) .
end.


/*==========================================================================*/
procedure fill-result-line :
define input parameter p-doc-line-rowid as rowid            no-undo.
define input parameter p-classificator  as character        no-undo.

    define variable v-today         as date         no-undo.
    define variable v-time          as integer      no-undo.
    define variable v-cost-sum      as decimal      no-undo.
    define variable v-free-qnty     as decimal      no-undo.
    define variable v-rsrv-qnty     as decimal      no-undo.
    define variable v-duration      as integer      no-undo.
    define variable v-ext-name      as character    no-undo.

    define variable v-class1-key    as character    no-undo.
    define variable v-class1-value  as character    no-undo.
    define variable v-class2-key    as character    no-undo.
    define variable v-class2-value  as character    no-undo.

    define buffer buf_doc-line              for doc-line.
    define buffer buf_trn-doc               for trn-doc.
    define buffer buf_goods                 for goods.
    define buffer buf_temp_result-line      for temp_result-line.
    define buffer buf_temp_classificator    for temp_classificator.
do
for buf_doc-line
  , buf_trn-doc
  , buf_goods
  , buf_temp_result-line
  , buf_temp_classificator
on error undo, return error
:
    find first buf_doc-line no-lock
         where rowid( buf_doc-line ) = p-doc-line-rowid
    .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run godendo-date-to-offset in this-procedure (
          input v-today
        , input buf_trn-doc.doc-date
        , output v-duration
    ).
    find first buf_goods no-lock
         where buf_goods.artic     = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
    .
    run get-price-and-qnty in this-procedure (
          input p-doc-line-rowid
        , output v-cost-sum
        , output v-rsrv-qnty
        , output v-free-qnty
    ).
    if v-rsrv-qnty <> 0
    then do:
        assign
            v-r-rsrv-line-counter = v-r-rsrv-line-counter + 1
        .
        { gbl/docextnm.i
            buf_trn-doc.doc-code
            v-ext-name
        }
        create buf_temp_result-line.
        assign
            buf_temp_result-line.line-order     = v-r-rsrv-line-counter * 10
            buf_temp_result-line.obj-type       = buf_trn-doc.obj-type
            buf_temp_result-line.obj-code       = buf_trn-doc.obj-code
            buf_temp_result-line.artic          = buf_doc-line.artic
            buf_temp_result-line.prod-type      = buf_doc-line.prod-type
            buf_temp_result-line.prod-code      = buf_doc-line.prod-code
            buf_temp_result-line.prod-string    = substitute( "&1 &2", buf_doc-line.prod-type, buf_doc-line.prod-code )
            buf_temp_result-line.gds-code       = buf_goods.gds-code
            buf_temp_result-line.gds-name       = buf_goods.gds-name
            buf_temp_result-line.grp-name       = buf_goods.grp-name
            buf_temp_result-line.rsrv-qnty      = v-rsrv-qnty
            buf_temp_result-line.cost-sum       = v-cost-sum
            buf_temp_result-line.free-qnty      = v-free-qnty
            buf_temp_result-line.doc-code       = substitute( "&1 &2", v-ext-name, buf_trn-doc.doc-code )
            buf_temp_result-line.doc-date       = buf_trn-doc.doc-date
            buf_temp_result-line.cli-string     = substitute( "&1 &2", buf_trn-doc.cli-type,  buf_trn-doc.cli-code  )
            buf_temp_result-line.duration       = ( -1 ) * v-duration
        .
        case p-classificator
        :
            when "no-classify":U
            then do:
                assign
                    v-class1-key   = ""
                    v-class1-value = ""
                    v-class2-key   = ""
                    v-class2-value = ""
                .
            end.        /* when "no-classify":U */
            when "grp-goods":U
            then do:
                assign
                    v-class1-key   = buf_temp_result-line.grp-name
                    v-class1-value = substitute( "    Группа: &1", buf_temp_result-line.grp-name )
                    v-class2-key   = ""
                    v-class2-value = ""
                .
            end.        /* when "grp-goods":U */
        end case.       /* case p-classificator */
        find first buf_temp_classificator
             where buf_temp_classificator.class-code   = p-classificator
               and buf_temp_classificator.obj-type     = buf_trn-doc.obj-type
               and buf_temp_classificator.obj-code     = buf_trn-doc.obj-code
               and buf_temp_classificator.class1-key   = v-class1-key
               and buf_temp_classificator.class2-key   = v-class2-key
        no-error.
        if not available buf_temp_classificator
        then do:
            assign
                v-r-rsrv-class-order = v-r-rsrv-class-order + 1
            .
            create buf_temp_classificator.
            assign
                buf_temp_classificator.class-order  = v-r-rsrv-class-order
                buf_temp_classificator.class-code   = p-classificator
                buf_temp_classificator.obj-type     = buf_trn-doc.obj-type
                buf_temp_classificator.obj-code     = buf_trn-doc.obj-code
                buf_temp_classificator.class1-key   = v-class1-key
                buf_temp_classificator.class2-key   = v-class2-key
                buf_temp_classificator.class1-value = v-class1-value
                buf_temp_classificator.class2-value = v-class2-value
            .
        end.
        assign
            buf_temp_classificator.sum-rsrv-qnty  = buf_temp_classificator.sum-rsrv-qnty  + buf_temp_result-line.rsrv-qnty
            buf_temp_classificator.sum-cost       = buf_temp_classificator.sum-cost       + buf_temp_result-line.cost-sum
            buf_temp_classificator.sum-free-qnty  = buf_temp_classificator.sum-free-qnty  + buf_temp_result-line.free-qnty
            v-r-rsrv-sum-rsrv-qnty                = v-r-rsrv-sum-rsrv-qnty                + buf_temp_result-line.rsrv-qnty
            v-r-rsrv-sum-cost                     = v-r-rsrv-sum-cost                     + buf_temp_result-line.cost-sum
            v-r-rsrv-sum-free-qnty                = v-r-rsrv-sum-free-qnty                + buf_temp_result-line.free-qnty
        .
        assign
            buf_temp_result-line.class-order = buf_temp_classificator.class-order
        .
        { rep/repfrm.i disp v-r-rsrv-line-counter reportname }
    end.        /* if v-rsrv-qnty <> 0 */
end.
end procedure. /* fill-result-line */


/*==========================================================================*/
procedure check-data-presence :
define output parameter p-data-present  as logical          no-undo.

    define buffer buf_temp_result-line      for temp_result-line.
do
for buf_temp_result-line
on error undo, return error
:
    find first buf_temp_result-line
    no-error.
    if available buf_temp_result-line
    then do:
        assign
            p-data-present = yes
        .
    end.
    else do:
        assign
            p-data-present = no
        .
    end.
end.
end procedure. /* check-data-presence */


/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
    put stream out-stream
        skip(1)
        skip space( {&tab-stop1} )
                "Отчет по зарезервированным товарам."
    .
    put stream out-stream unformatted
        skip(1)
            str2            format "X(100)"
        skip
            str4            format "X(100)"
        skip
            ReportHeader
        skip
            "Показано товаров:"
            v-r-rsrv-line-counter   format ">>>>>>>9"
        skip
            "Дата печати: "
            cur-time-string()       format "X(40)"
            "Цены и суммы указаны в "
            ( if x-SET_val_TYPE = 1
              then "{&abbr_rub_allshift}"
              else base-type )      format "X(10)"
    .
    put stream out-stream
        skip
        space({&P-S})
            v-r-rsrv-single-line   format "X({&P-X})"
        skip space({&P-S})  "|"
            "Код"                   at center-field({&P-S} + 1, {&P-C2-S}, 3)
            "|"                     at {&P-C2-S}
            "Артикул"               at center-field({&P-C2-S}, {&P-C3-S}, 7)
            "|"                     at {&P-C3-S}
            "Производитель"         at center-field({&P-C3-S}, {&P-C4-S}, 13)
            "|"                     at {&P-C4-S}
            "Наименование товара"   at {&P-C4-S} + 2
            "|"                     at {&P-C5-S}
            "Количество"            at {&P-C5-S} + 2
            "|"                     at {&P-C6-S}
            "Учетная"               at {&P-C6-S} + 2
            "|"                     at {&P-C7-S}
            "Сумма"                 at {&P-C7-S} + 2
            "|"                     at {&P-C8-S}
            "Свободное"             at {&P-C8-S} + 2
            "|"                     at {&P-C9-S}
            "Номер"                 at {&P-C9-S} + 2
            "|"                     at {&P-C10-S}
            "Дата"                  at {&P-C10-S} + 2
            "|"                     at {&P-C11-S}
            "Контрагент"            at {&P-C11-S} + 2
            "|"                     at {&P-C12-S}
            "Дней"                  at {&P-C12-S} + 2
            "|"                     at {&P-E}
        skip space({&P-S})  "|"
            "товара"                at center-field({&P-S} + 1, {&P-C2-S}, 6)
            "|"                     at {&P-C2-S}
            "|"                     at {&P-C3-S}
            "|"                     at {&P-C4-S}
            "|"                     at {&P-C5-S}
            "резерв"                at {&P-C5-S} + 2
            "|"                     at {&P-C6-S}
            "цена"                  at {&P-C6-S} + 2
            "|"                     at {&P-C7-S}
            "в уч.ц."               at {&P-C7-S} + 2
            "|"                     at {&P-C8-S}
            "количество"            at {&P-C8-S} + 2
            "|"                     at {&P-C9-S}
            "накладной"             at {&P-C9-S} + 2
            "|"                     at {&P-C10-S}
            "накладной"             at {&P-C10-S} + 2
            "|"                     at {&P-C11-S}
            "|"                     at {&P-C12-S}
            "в резерве"             at {&P-C12-S} + 2
            "|"                     at {&P-E}
        skip space({&P-S})
            "|" v-r-rsrv-single-line format "X({&P-X0})" "|"
    .
end.
end procedure. /* print-header */

/*==========================================================================*/
procedure print-line :

define input parameter p-line-order     as integer          no-undo.

    define buffer buf_temp_result-line          for temp_result-line.
do
for buf_temp_result-line
on error undo, return error
:
    find first buf_temp_result-line
         where buf_temp_result-line.line-order = p-line-order
    .
    put stream out-stream
        skip space({&P-S}) "|"
            buf_temp_result-line.gds-code        format "999999999"
            "|"                     at {&P-C2-S}
            buf_temp_result-line.artic           format "X(16)"
            "|"                     at {&P-C3-S}
            buf_temp_result-line.prod-string     format "X(13)"
            "|"                     at {&P-C4-S}
            buf_temp_result-line.gds-name        format "X(39)"
            "|"                     at {&P-C5-S}
            buf_temp_result-line.rsrv-qnty       format "->>>>>>9.99"
            "|"                     at {&P-C6-S}
            buf_temp_result-line.cost-sum / buf_temp_result-line.rsrv-qnty
                                                 format "->,>>>,>>9.99"
            "|"                     at {&P-C7-S}
            buf_temp_result-line.cost-sum        format "->,>>>,>>9.99"
            "|"                     at {&P-C8-S}
            buf_temp_result-line.free-qnty       format "->>>>>>9.99"
            "|"                     at {&P-C9-S}
            buf_temp_result-line.doc-code        format "X(13)"
            "|"                     at {&P-C10-S}
            buf_temp_result-line.doc-date        format "99.99.9999"
            "|"                     at {&P-C11-S}
            buf_temp_result-line.cli-string      format "X(13)"
            "|"                     at {&P-C12-S}
            buf_temp_result-line.duration        format "->>>>>9"
            "|"                     at {&P-E}
    .
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-classificator :
define input parameter p-class-order    as integer          no-undo.

    define buffer buf_temp_classificator        for temp_classificator.
do
for buf_temp_classificator
on error undo, return error
:
    find first buf_temp_classificator
         where buf_temp_classificator.class-order = p-class-order
    .
    if buf_temp_classificator.class-code = "no-classify":U
    then do:
        undo, return .
    end.
    if v-r-rsrv-first-line-printed = no
    then do:
        assign
            v-r-rsrv-first-line-printed = yes
        .
    end.        /* if v-r-rsrv-first-line-printed = no */
    else do:
        put stream out-stream
            skip space({&P-S})
                "|" v-r-rsrv-single-line format "X({&P-X0})" "|"
        .
    end.        /* NOT ( if v-r-rsrv-first-line-printed = no ) */
    put stream out-stream
        skip space({&P-S})
                "|"
                buf_temp_classificator.class1-value format "X({&max-width})"
                "|"             at {&P-E}
    .
    if buf_temp_classificator.class2-key <> ""
    then do:
        put stream out-stream
            skip space({&P-S})
                "|" v-r-rsrv-single-line format "X({&P-X0})" "|"
            skip space({&P-S})
                "|"
                buf_temp_classificator.class2-value format "X({&max-width})"
                "|"             at {&P-E}
        .
    end.

end.
end procedure. /* print-classificator */

/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:
    put stream out-stream
        skip space({&P-S})
            "|" v-r-rsrv-single-line format "X({&P-X0})" "|"
        skip space({&P-S}) "|     Всего                  "
            "|"                     at {&P-C5-S}
            v-r-rsrv-sum-rsrv-qnty                     format "->>>>>>9.99"
            "|"                     at {&P-C6-S}
            "|"                     at {&P-C7-S}
            v-r-rsrv-sum-cost                          format "->,>>>,>>9.99"
            "|"                     at {&P-C8-S}
            v-r-rsrv-sum-free-qnty                     format "->>>>>>9.99"
            "|"                     at {&P-C9-S}
            "|"                     at {&P-E}
        skip space({&P-S})
            v-r-rsrv-single-line   format "X({&P-X})"

    .
end.
end procedure. /* print-footer */


/*==========================================================================*/
procedure out-selected-goods :
define input parameter p-doc-line-rowid as rowid            no-undo.
define input parameter p-classificator  as character        no-undo.

    define buffer buf_doc-line              for doc-line.
    define buffer buf_goods                 for goods.
    define buffer buf_temp_goods            for gds-list.
    define buffer buf_temp_goods-grp        for tmp#grp.
do
for buf_doc-line
  , buf_goods
  , buf_temp_goods
  , buf_temp_goods-grp
on error undo, return error
:
    find first buf_doc-line no-lock
         where rowid( buf_doc-line ) = p-doc-line-rowid
    .
    find first buf_goods no-lock
         where buf_goods.artic     = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
    .
    if buf_goods.gds-type = {&gds-goods}
    then do:
        case x-SelectGood
        :
            when {&g-all}
            then do:        /* Выбирать по всем товарам */
                run fill-result-line in this-procedure (
                      input p-doc-line-rowid
                    , input p-classificator
                ).
            end.        /* when 1 */
            when {&g-grp}
            then do:        /* Товары выбирать по группам */
                find first buf_temp_goods-grp
                     where buf_temp_goods-grp.node-code = buf_goods.grp-code
                no-error.
                if available buf_temp_goods-grp
                then do:
                    run fill-result-line in this-procedure (
                          input p-doc-line-rowid
                        , input p-classificator
                    ).
                end.
            end.        /* when 2 */
            when {&g-choice}
            or when {&g-one}
            then do:
                find first buf_temp_goods
                     where buf_temp_goods.artic     = buf_doc-line.artic
                       and buf_temp_goods.prod-type = buf_doc-line.prod-type
                       and buf_temp_goods.prod-code = buf_doc-line.prod-code
                no-error.
                if available buf_temp_goods
                then do:
                    run fill-result-line in this-procedure (
                          input p-doc-line-rowid
                        , input p-classificator
                    ).
                end.
            end.
        end case.       /* case x-SelectGood */
    end.        /* if buf_goods.gds-type = {&gds-goods}  */
end.
end procedure. /* out-selected-goods */


/*==========================================================================*/
procedure get-price-and-qnty :
define input parameter p-doc-line-rowid     as rowid            no-undo.
define output parameter p-cost-sum          as decimal          no-undo.
define output parameter p-rsrv-qnty         as decimal          no-undo.
define output parameter p-free-qnty         as decimal          no-undo.

    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-obj       for gds-obj.
do
for buf_doc-line
  , buf_gds-obj
on error undo, return error
:
    find first buf_doc-line no-lock
         where rowid( buf_doc-line ) = p-doc-line-rowid
    .
    run clcprtsl_calc-line in this-procedure (
        input recid( buf_doc-line )
    ).
    find first tt-allsum-line
         where tt-allsum-line.sum-type = {&sum-general}
    no-error.
    if available tt-allsum-line
    then do:
        assign
            p-cost-sum   = ( if x-SET_val_TYPE = 1 then tt-allsum-line.sum-dsc-rubl-acc else tt-allsum-line.sum-dsc-base-acc )
            p-rsrv-qnty  = tt-allsum-line.fact-qnty
        .
    end.
    else do:
        assign
            p-cost-sum   = 0
            p-rsrv-qnty  = 0
        .
    end.
    find first buf_gds-obj no-lock
         where buf_gds-obj.obj-type     = buf_doc-line.obj-type
           and buf_gds-obj.obj-code     = buf_doc-line.obj-code
           and buf_gds-obj.artic        = buf_doc-line.artic
           and buf_gds-obj.prod-type    = buf_doc-line.prod-type
           and buf_gds-obj.prod-code    = buf_doc-line.prod-code
    no-error.
    if available buf_gds-obj
    then do:
        assign
            p-free-qnty = buf_gds-obj.fact-qnty
        .
    end.
    else do:
        assign
            p-free-qnty = 0
        .
    end.
end.
end procedure. /* get-price-and-qnty */


/*==========================================================================*/
procedure print-object-string :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-first-object   as logical          no-undo.
do
on error undo, return error
:
    if p-first-object = no
    then do:
        put stream out-stream
            skip space({&P-S})
                "|" v-r-rsrv-double-line format "X({&P-X0})" "|"
        .
    end.
    put stream out-stream
        skip space({&P-S})
            "|"
            substitute( "Объект: &1 &2", p-obj-type, p-obj-code )  format "X({&max-width})"
            "|"             at {&P-E}
        skip space({&P-S})
            "|" v-r-rsrv-double-line format "X({&P-X0})" "|"
    .

end.
end procedure. /* print-object-string */


/*==========================================================================*/
procedure print-classificator-itog :
define input parameter p-sum-rsrv-qnty  as decimal          no-undo.
define input parameter p-sum-cost       as decimal          no-undo.
define input parameter p-sum-free-qnty  as decimal          no-undo.

do
on error undo, return error
:

    put stream out-stream
        skip space({&P-S}) "|     Итого по классификатору"
            "|"                     at {&P-C5-S}
            p-sum-rsrv-qnty                     format "->>>>>>9.99"
            "|"                     at {&P-C6-S}
            "|"                     at {&P-C7-S}
            p-sum-cost                          format "->,>>>,>>9.99"
            "|"                     at {&P-C8-S}
            p-sum-free-qnty                     format "->>>>>>9.99"
            "|"                     at {&P-C9-S}
            "|"                     at {&P-E}
    .
end.
end procedure. /* print-classificator-itog */