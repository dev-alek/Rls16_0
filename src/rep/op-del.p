block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: op-del.p $
$Archive: rep/op-del.p $

Акт отклонения.

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define input parameter p-print-in-rubl      as logical          no-undo.
define input parameter p-print-details      as logical          no-undo.
define input parameter p-fat                as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-del.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-del.p $":U .
define variable vss-description as character no-undo init "Акт отклонения.".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ str/fbrcode.i         }
{ cmp/r-pril.i          }
{ str/get-pr.i def      }
{ rep/p-fmt.i           }
{ rep/r-cliprp.i def    }
{ str/doc-code.i        }
{ trg/partslib.i        }
{ rep/fbrrep.i          }
{ gbl/getcntxt.i def    }

do
on error undo, return error
:

    define variable v-doc-code like fbr-doc.doc-code no-undo.

    def stream out-stream .

    def buffer  buf_fbr-doc       for fbr-doc.

    def buffer  buf_goods         for goods.
    def buffer  buf_clients       for clients.

    define variable v-line-counter      as integer                  no-undo.

    define variable v-organization      as character                    no-undo.
    define variable v-org-name          as character                    no-undo.
    define variable v-recipe-name       as character                    no-undo.
    define variable v-doc-code1         as character                    no-undo.
    define variable v-goods-unit        as character                    no-undo.

    define variable v-goods-artic       as character                    no-undo.
    define variable v-goods-name        as character                    no-undo.
    define variable v-bar-code          as integer                  no-undo.

    define variable out-code            as character                    no-undo.
    define variable in-code             as character                    no-undo.

    /*  !!!!!!!!!!!!!!!!!! */
    define variable v-fbr-qnty          as decimal                  no-undo.
    define variable v-trn-qnty          as decimal                  no-undo.
    define variable delta_value         as decimal                  no-undo.
    define variable v-delta             as decimal                  no-undo.
    define variable v-delta-vat         as decimal                  no-undo.
    define variable v-sum-fbr-qnty      as decimal                  no-undo.
    define variable v-sum-trn-qnty      as decimal                  no-undo.
    define variable v-sum-delta         as decimal                  no-undo.
    define variable v-sum-delta-vat     as decimal                  no-undo.
    /*  !!!!!!!!!!!!!!!!!! */

    define variable sym1  as character init "|" no-undo.
    define variable sym2  as character init ":" no-undo.
    define variable sym3  as character init ":" no-undo.
    define variable sym4  as character init ":" no-undo.
    define variable sym5  as character init ":" no-undo.
    define variable sym6  as character init ":" no-undo.
    define variable sym7  as character init ":" no-undo.
    define variable sym8  as character init ":" no-undo.
    define variable sym9  as character init ":" no-undo.
    define variable sym10  as character init ":" no-undo.
    define variable sym11 as character init "|" no-undo.

    define variable v-single-line         as character               no-undo.
    define variable v-underline           as character               no-undo.
    define variable v-need-page-break     as logical init no    no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    /*---S----- Таблицы --------------------------------*/
    &scop P-S 10
    &scop P-X  178        /*длина линии*/
    &scop P-X1 180        /*длина линии*/
    &scop P-C2-S    {&P-S} + 5
    &scop P-C3-S    {&P-S} + 22
    &scop P-C4-S    {&P-S} + 70
    &scop P-C5-S    {&P-S} + 80
    &scop P-C6-S    {&P-S} + 84
    &scop P-C7-S    {&P-S} + 104
    &scop P-C8-S    {&P-S} + 124
    &scop P-C9-S    {&P-S} + 144
    &scop P-C10-S   {&P-S} + 162
    &scop P-E       {&P-S} + 180

    /*    output to "d:\ww\111.txt".*/
    /*    for each temp_fbr-gds*/
    /*    :*/
    /*        export temp_fbr-gds.artic temp_fbr-gds.in-qnty temp_fbr-gds.out-qnty.*/
    /*    end.*/
    /*    output close.*/
    /*---E----- Таблицы --------------------------------*/
    DEFINE frame f-doc
            space({&P-S})
            sym1  format "X(1)" space(0)   v-line-counter      format ">>9"                     space(0)
            sym2  format "X(1)" space(0)   v-goods-artic       format "X(16)"                   space(0)
            sym3  format "X(1)" space(0)   v-goods-name        format "X(47)"                   space(0)
            sym4  format "X(1)" space(0)   v-bar-code          format ">>>>>>>>9"               space(0)
            sym5  format "X(1)" space(0)   v-goods-unit        format "X(3)"                    space(0)
            sym6  format "X(1)" space(0)   v-fbr-qnty          format "->>>>,>>>,>>9.99999"     space(0)
            sym7  format "X(1)" space(0)   v-trn-qnty          format "->>>>,>>>,>>9.99999"     space(0)
            sym8  format "X(1)" space(0)   delta_value         format "->>>>,>>>,>>9.99999"     space(0)
            sym9  format "X(1)" space(0)   v-delta             format "->>>>,>>>,>>9.999"     space(0)
            sym10 format "X(1)" space(0)   v-delta-vat         format "->>>>,>>>,>>9.999"     space(0)
            sym11 format "X(1)" space(0)
    with width {&DOS_CW} down stream-io.
    { gbl/working.i }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    assign
        v-single-line  = fill("-", 230)
        v-underline    = fill("_", 230)
    .
    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-recid
    .
    assign
        v-doc-code = buf_fbr-doc.doc-code
    .
    /*---S------ Находим подразделение - хозяина документа -------------*/
    find first buf_clients no-lock
        where buf_clients.obj-type = buf_fbr-doc.obj-type
        and buf_clients.obj-code = buf_fbr-doc.obj-code
    no-error.
    case buf_clients.obj-type :
        when {&shop} then
            do:
                find first shop no-lock
                    where shop.obj-code = buf_clients.obj-code
                .
            end.
        when {&stock} then
            do:
                find first store no-lock
                    where store.obj-code = buf_clients.obj-code
                .
            end.
    end case.
    assign
        v-org-name = buf_clients.obj-name
    .
    /*---E------ Находим подразделение - хозяина документа -------------*/
    { cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }
    form header
        v-single-line format "X({&P-X})" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
    view stream Out-Stream frame BottomFrame .

    find first clients no-lock
         where clients.obj-type = {&cmp}
           and clients.obj-code = buf_fbr-doc.host-code
    .
    { rep/r-cliprp.i }
    assign
        v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                    + t-addres + t-phone)
    .
  /*---S----- Шапка документа ------------------------*/

    run fbrrep-fill-for-op-del in this-procedure (
          input buf_fbr-doc.doc-code
        , input ( v-cntxt-db-num <> 0 )
    ) .

    define variable v-need-print    as logical       no-undo.
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
       where temp_fbrrep-goods.income-qnty < temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input no
            , input yes
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    if round( v-sum-fbr-qnty - v-sum-trn-qnty , 5 ) <> 0
    or round( v-sum-delta    , 3 ) <> 0
    or round( v-sum-delta-vat, 3 ) <> 0
    then do:
        assign
            v-need-print = yes
        .
    end.
    if v-need-print = no
    then do:
        assign
            v-sum-fbr-qnty  = 0
            v-sum-trn-qnty  = 0
            v-sum-delta     = 0
            v-sum-delta-vat = 0
        .
        for each temp_fbrrep-goods
           where temp_fbrrep-goods.income-qnty >= temp_fbrrep-goods.write-off-qnty
        on error undo, return error
        :
            run print-table-line in this-procedure (
                  input temp_fbrrep-goods.gds-code
                , input no
                , input yes
                , output v-fbr-qnty
                , output v-trn-qnty
                , output v-delta
                , output v-delta-vat
            ).
            assign
                v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
                v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
                v-sum-delta     = v-sum-delta     + v-delta
                v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
            .
        end.
        if round( v-sum-fbr-qnty - v-sum-trn-qnty , 5 ) <> 0
        or round( v-sum-delta    , 3 ) <> 0
        or round( v-sum-delta-vat, 3 ) <> 0
        then do:
            assign
                v-need-print = yes
            .
        end.
    end.
    if v-need-print = no
    then do:
        return.
    end.
    put stream Out-Stream
      skip
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
      skip
        space({&P-S}) "Организация:               "
                 v-organization                format "X(60)"
      skip
        space({&P-S}) "Структурное подразделение: "
                 v-org-name              format "X(60)"
      skip(2)
        space({&P-S}) "                                АКТ ОТКЛОНЕНИЯ по документу производства №: " + v-doc-code format "X(100)"
    .

    form with frame f-doc .
    view stream Out-Stream frame BottomFrame .
    down stream Out-Stream 1 with frame f-doc no-labels.

    run fbrcode-trn-doc in this-procedure (
          input {&manufacturing}
        , input v-doc-code
        , input {&expense}
        , output v-doc-code1
    ).
    run print-title in this-procedure(
        input "Товары списанные по накладной N " + v-doc-code1
    ).
    run print-header (
          input v-single-line
        , input no
    ).
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
    where temp_fbrrep-goods.income-qnty < temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input no
            , input no
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    run print-itog in this-procedure (
          input v-sum-fbr-qnty
        , input v-sum-trn-qnty
        , input v-sum-delta
        , input v-sum-delta-vat
    ).
    form with frame f-doc .
    view stream Out-Stream frame BottomFrame .
    down stream Out-Stream 1 with frame f-doc no-labels.
    run fbrcode-trn-doc in this-procedure (
        input {&manufacturing}
        , input v-doc-code
        , input {&income}
        , output v-doc-code1
    ).
    run print-title in this-procedure(
        input "Товары произведенные по накладной N " + v-doc-code1
    ).
    run print-header (
        input v-single-line
        , input no
    ).
    assign
        v-sum-fbr-qnty  = 0
        v-sum-trn-qnty  = 0
        v-sum-delta     = 0
        v-sum-delta-vat = 0
    .
    for each temp_fbrrep-goods
    where temp_fbrrep-goods.income-qnty >= temp_fbrrep-goods.write-off-qnty
    on error undo, return error
    :
        run print-table-line in this-procedure (
              input temp_fbrrep-goods.gds-code
            , input yes
            , input no
            , output v-fbr-qnty
            , output v-trn-qnty
            , output v-delta
            , output v-delta-vat
        ).
        assign
            v-sum-fbr-qnty  = v-sum-fbr-qnty  + v-fbr-qnty
            v-sum-trn-qnty  = v-sum-trn-qnty  + v-trn-qnty
            v-sum-delta     = v-sum-delta     + v-delta
            v-sum-delta-vat = v-sum-delta-vat + v-delta-vat
        .
    end.
    run print-itog in this-procedure (
          input v-sum-fbr-qnty
        , input v-sum-trn-qnty
        , input v-sum-delta
        , input v-sum-delta-vat
    ).
    hide stream out-stream frame BottomFrame .
    output stream Out-Stream close.
    { gbl/stopwork.i }
    { rep/q-print.i 8}
end.

/*============================================================================*/
/*                    Шапка с цифрами для каждой новой страницы               */
/*============================================================================*/

procedure print-header :
do
on error undo, return error
:
def input parameter p-single-line as character    no-undo.
def input parameter p-need-line   as logical no-undo.

    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
        skip space({&P-S})
          p-single-line format "X({&P-X})"
    .
    put stream out-stream
        skip space({&P-S})
          "|"
          "1"                  at center-field( {&P-S} + 1, {&P-C2-S}, 1)
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
          "10"                 at center-field( {&P-C10-S}, {&P-E}, 2)
          "|"                  at {&P-E}
        skip space({&P-S})
          "|"
          p-single-line format "X({&P-X})"
          "|"                  at {&P-E}

    .
end.
end procedure. /* print-header */

/*==========================================================================*/
procedure print-table-line :
do
on error undo, return error
:
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-is-income      as logical      no-undo.
define input parameter p-calc-only      as logical      no-undo.
define output parameter p-fbr-qnty      as decimal      no-undo.
define output parameter p-trn-qnty      as decimal      no-undo.
define output parameter p-delta         as decimal      no-undo.
define output parameter p-delta-vat     as decimal      no-undo.


    define variable v-unit-base as character     no-undo.
    define variable v-gds-name  as character     no-undo.

    define buffer buf_temp_fbrrep-goods     for temp_fbrrep-goods.

    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.gds-code = p-gds-code
    .
    { gbl/unitbase.i
        p-gds-code
        v-goods-unit
    }
    { gbl/gds-cdnm.i
        p-gds-code
        v-goods-name
    }
    { gbl/gdsbcode.i
        p-gds-code
        ?
        v-bar-code
    }.
    assign
        v-line-counter  = v-line-counter    + 1
        v-goods-artic   = string( buf_temp_fbrrep-goods.artic )
        delta_value     = buf_temp_fbrrep-goods.fact-qnty
        v-delta       = ( if p-print-in-rubl
                            then buf_temp_fbrrep-goods.sum-cost-rubl
                            else buf_temp_fbrrep-goods.sum-cost-base )
        v-delta-vat   = ( if p-print-in-rubl
                            then buf_temp_fbrrep-goods.sum-vat-cost-rubl
                            else buf_temp_fbrrep-goods.sum-vat-cost-base )
        v-fbr-qnty      = ( if p-is-income = yes
                            then buf_temp_fbrrep-goods.income-qnty
                            else buf_temp_fbrrep-goods.write-off-qnty )
        v-trn-qnty      = v-fbr-qnty - buf_temp_fbrrep-goods.fact-qnty
    .
    if buf_temp_fbrrep-goods.fact-qnty = 0
    and v-delta     = 0
    and v-delta-vat = 0
    then do:
        assign
            buf_temp_fbrrep-goods.deleted = yes
        .
    end.
    else do:
        if v-need-page-break = yes
        and p-calc-only = no
        then do:
            page stream out-stream.
        end.
        if p-calc-only = no
        then do:
            display stream out-stream
                sym1  v-line-counter
                sym2  v-goods-artic
                sym3  v-goods-name
                sym4  v-bar-code
                sym5  v-goods-unit
                sym6  v-fbr-qnty
                sym7  v-trn-qnty
                sym8  v-fbr-qnty - v-trn-qnty   @ delta_value
                sym9  v-delta
                sym10 v-delta-vat
                sym11
            with frame f-doc.
            down stream out-stream with frame f-doc .
        end.
        assign
            p-fbr-qnty  = v-fbr-qnty
            p-trn-qnty  = v-trn-qnty
            p-delta     = v-delta
            p-delta-vat = v-delta-vat
        .
    end.
end.
end procedure. /* print-table-line */

/*==========================================================================*/
procedure print-itog :
do
on error undo, return error
:
define input parameter p-sum-fbr-qnty   as decimal      no-undo.
define input parameter p-sum-trn-qnty   as decimal      no-undo.
define input parameter p-delta-sum      as decimal      no-undo.
define input parameter p-delta-vat-sum  as decimal      no-undo.
    put stream Out-Stream
        skip space({&P-S})
            "|"
            v-single-line format "X({&P-X})"
            "|" at {&P-E}
        skip space({&P-S})
            "|"
            "ИТОГО"                         at right-field( {&P-C6-S}, 6)
            ":"                             at {&P-C6-S}
            p-sum-fbr-qnty                  format "->>>,>>9.99999"  at right-field( {&P-C7-S}, 13)
            ":"                             at {&P-C7-S}
            p-sum-trn-qnty                  format "->>>,>>9.99999"  at right-field( {&P-C8-S}, 13)
            ":"                             at {&P-C8-S}
            p-sum-fbr-qnty - p-sum-trn-qnty format "->>>,>>9.99999"  at right-field( {&P-C9-S}, 13)
            ":"                             at {&P-C9-S}
            p-delta-sum                     format "->>>,>>9.999"    at right-field( {&P-C10-S}, 11)
            ":"                             at {&P-C10-S}
            p-delta-vat-sum                 format "->>>,>>9.999"    at right-field( {&P-E}, 11)
            "|"                             at {&P-E}
        skip space({&P-S})
            "|"
            v-single-line format "X({&P-X})"
            "|" at {&P-E}
    .
end.
end procedure. /* print-itog */

/*==========================================================================*/
procedure print-title :
do
on error undo, return error
:
define input parameter p-header-string as character    no-undo.

    put stream Out-Stream
        skip
            space({&P-S}) p-header-string format "X(80)"
        skip space({&P-S})
            v-single-line format "X({&P-X1})"
        skip space({&P-S})
            "|"
            "Но-"
            ":"                                  at {&P-C2-S}
            "Артикул"                            at center-field( {&P-C2-S}, {&P-C3-S}, 7)
            ":"                                  at {&P-C3-S}
            "Наименование"                       at center-field( {&P-C3-S}, {&P-C4-S}, 12)
            ":"                                  at {&P-C4-S}
            "Код"                                at center-field( {&P-C4-S}, {&P-C5-S}, 3)
            ":"                                  at {&P-C5-S}
            "Ед."                                at center-field( {&P-C5-S}, {&P-C6-S}, 3)
            ":"                                  at {&P-C6-S}
            "Количество"                         at center-field( {&P-C6-S}, {&P-C7-S}, 10)
            ":"                                  at {&P-C7-S}
            "Количество"                         at center-field( {&P-C7-S}, {&P-C8-S}, 10)
            ":"                                  at {&P-C8-S}
            "Разность"                           at center-field( {&P-C8-S}, {&P-C9-S}, 8)
            ":"                                  at {&P-C9-S}
            "Разность сумм"                      at center-field( {&P-C9-S}, {&P-C10-S}, 13)
            ":"                                  at {&P-C10-S}
            "Разность сумм"                      at center-field( {&P-C10-S}, {&P-E}, 15)
            "|"                                  at {&P-E}
        skip space({&P-S})
            "|"
            "мер"
            ":"                                  at {&P-C2-S}
            ":"                                  at {&P-C3-S}
            ":"                                  at {&P-C4-S}
            ":"                                  at {&P-C5-S}
            "изм"                                at center-field( {&P-C5-S}, {&P-C6-S}, 3)
            ":"                                  at {&P-C6-S}
            "в производстве"                     at center-field( {&P-C6-S}, {&P-C7-S}, 14)
            ":"                                  at {&P-C7-S}
            "по накладной"                       at center-field( {&P-C7-S}, {&P-C8-S}, 12)
            ":"                                  at {&P-C8-S}
            "количеств"                          at center-field( {&P-C8-S}, {&P-C9-S}, 9)
            ":"                                  at {&P-C9-S}
            "учет. цен"                          at center-field( {&P-C9-S}, {&P-C10-S}, 9)
            ":"                                  at {&P-C10-S}
            "НДС уч.цен"                         at center-field( {&P-C10-S}, {&P-E}, 10)
            "|"                                  at {&P-E}
        skip space({&P-S})
            "|"
            v-single-line format "X({&P-X})"
            "|" at {&P-E}
    .
end.
end procedure. /* print-title */
