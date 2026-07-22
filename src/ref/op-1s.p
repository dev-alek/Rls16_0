block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: op-1s.p $
$Archive: ref/op-1s.p $

Печать калькуляционной карточки по оценочным учетным ценам ингредиентов

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recipe-code        as character        no-undo.
define input parameter p-store-type         as character        no-undo.
define input parameter p-store-code         as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-1s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/op-1s.p $":U .
define variable vss-description as character no-undo init "Печать калькуляционной карточки по оценочным учетным ценам ингредиентов".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ str/lib-trn.i     }
{ cmp/r-pril.i      }
{ str/get-pr.i def  }
{ rep/p-fmt.i       }
{ rep/r-cliprp.i def}
{ ref/gdsoattr.i    }
{ gbl/cur-time.i    }

def stream out-stream .

define buffer  buf_recipe        for recipe.
define buffer  buf_recipe-gds    for recipe-gds.
define buffer  buf_goods         for goods.
define buffer  buf_clients       for clients.
define buffer  buf_units         for units.

define variable v-line-counter      as integer      no-undo.

define variable v-organization      as char         no-undo.
define variable v-org-name          as char         no-undo.
define variable v-recipe-name       as char         no-undo.
define variable v-doc-code          as char         no-undo.
define variable v-fact-date         as date         no-undo.
define variable v-goods-unit        as char         no-undo.

define variable v-goods-artic       as char         no-undo.
define variable v-goods-name        as char         no-undo.
define variable v-bar-code          as integer      no-undo.
define variable v-mass              as decimal      no-undo.
define variable v-cost              as decimal      no-undo.
define variable v-sum               as decimal      no-undo.

define variable v-sum-cost          as decimal      no-undo.
define variable v-sum-prc           as decimal      no-undo.
define variable v-sum-sale          as decimal      no-undo.
define variable v-sum-mass          as decimal      no-undo.
define variable v-sum-mass-doc      as decimal      no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

define variable sym1  as char init "|" no-undo.
define variable sym2  as char init ":" no-undo.
define variable sym3  as char init ":" no-undo.
define variable sym4  as char init ":" no-undo.
define variable sym5  as char init ":" no-undo.
define variable sym6  as char init ":" no-undo.
define variable sym7  as char init ":" no-undo.
define variable sym8  as char init "|" no-undo.

define variable v-attr-value            as character            no-undo.
define variable v-attr-type             as character            no-undo.
define variable v-single-line           as character            no-undo.
define variable v-underline             as character            no-undo.
define variable v-no-printable-recipe   as logical init no      no-undo.
define variable v-need-page-break       as logical init no      no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/*---S----- Таблицы --------------------------------*/
&scop P-S 10
&scop P-X 119        /*длина линии*/
&scop P-X0 117       /*длина внутренней линии = длина линии - 2*/
&scop P-X1 74        /*длина внутренней линии от начала  2-й колонки до начала  5-й*/
&scop P-C2-S    {&P-S} + 5
&scop P-C3-S    {&P-S} + 22
&scop P-C4-S    {&P-S} + 70
&scop P-C5-S    {&P-S} + 80
&scop P-C6-S    {&P-S} + 90
&scop P-C7-S    {&P-S} + 104
&scop P-E       {&P-S} + 119

/*Маленькая верхняя таблица */
&scop P2-S 114

/*Блок документа*/
&scop P3-X 46         /*длина линии*/
&scop P3-X0 44       /*длина внутренней линии = длина линии - 2*/
&scop P3-S      50
&scop P3-C2-S   {&P3-S} + 20
&scop P3-C3-S   {&P3-S} + 33
&scop P3-E      {&P3-S} + 46

/*---E----- Таблицы --------------------------------*/

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_recipe no-lock
     where buf_recipe.recipe-code = p-recipe-code
no-error.
if not available buf_recipe
then do:
    message
      "Форму OP-1 напечатать невозможно."
      skip "Неверно задан код рецепта."
    view-as alert-box.
    return.
end.

DEFINE frame f-op-1
        space({&P-S})
        sym1  format "X(1)" space(0)   v-line-counter      format ">>9"     space(0)
        sym2  format "X(1)" space(0)   v-goods-artic       format "X(16)"     space(0)
        sym3  format "X(1)" space(0)   v-goods-name        format "X(47)"     space(0)
        sym4  format "X(1)" space(0)   v-bar-code          format ">>>>>>>>9" space(0)
        sym5  format "X(1)" space(0)   v-mass              format ">,>>9.999"  space(0)
        sym6  format "X(1)" space(0)   v-cost              format ">>,>>>,>>9.99"  space(0)
        sym7  format "X(1)" space(0)   v-sum               format ">>>,>>>,>>9.99"  space(0)
        sym8  format "X(1)" space(0)
with width {&DOS_CW} down stream-io.

do
on error undo, return error
:
    assign
        v-single-line  = fill("-", 230)
        v-underline    = fill("_", 230)
    .
    run cur-time in this-procedure (
        output v-today
        , output v-time
    ).
    assign
        v-doc-code     = buf_recipe.recipe-code
        v-fact-date    = v-today
    .

    /*---S------ Находим подразделение - хозяина документа -------------*/
    find first buf_clients no-lock
         where buf_clients.obj-type = p-store-type
           and buf_clients.obj-code = p-store-code
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

    { gbl/working.i }
    { cmp/open-out.i stream Out-Stream " " {&CS_PS} }

    form header
        v-single-line format "X({&P-X})" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
    view stream Out-Stream frame BottomFrame .

    define variable v-host-code    as integer      no-undo.
    { gbl/hostcode.i
        p-store-type
        p-store-code
        v-host-code
    }
    find first clients no-lock
        where clients.obj-type = {&cmp}
        and clients.obj-code = v-host-code
    .
    { rep/r-cliprp.i }
    assign
        v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                    + t-addres + t-phone)
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
           and buf_goods.prod-type  = buf_recipe.prod-type
           and buf_goods.prod-code  = buf_recipe.prod-code
    .
    { gbl/gdsbcode.i
        buf_goods.gds-code
        ?
        v-bar-code
    no-error }.
    run check-all-weight-kg in this-procedure (
          input buf_recipe.recipe-code
        , output v-no-printable-recipe
    ).
/*    if v-no-printable-recipe = yes*/
/*    then do:*/
/*        message*/
/*            "Калькуляционная карточка может быть распечатана "*/
/*            skip "только для рецептов с весовыми ингредиентами "*/
/*            skip "(единица измерения - кг)."*/
/*            skip(1)*/
/*            skip "В рецепте товара"*/
/*                    buf_goods.artic*/
/*                    buf_goods.gds-name*/
/*                    buf_goods.gds-code*/
/*            skip "есть невесовой товар."*/
/*            skip "Рецепт номер:" buf_recipe.recipe-code*/
/*            skip (1)*/
/*            skip "Печать калькуляционной карточки невозможна."*/
/*        view-as alert-box error.*/
/*        next.*/
/*    end.*/
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    { str/get-pr.i
        " "
        p-store-type
        p-store-code
        buf_goods.gds-code
        ?
        " "
    }       /*Цена составного товара*/
    assign
        v-recipe-name     = string( buf_goods.artic ) + fill( " ", 2 ) + buf_goods.gds-name
                                                        + fill( " ", 2 ) + string( v-bar-code )
        v-sum-mass-doc    = buf_recipe.qnty
        v-goods-unit      = buf_goods.unit-base
        v-line-counter    = 0
        v-sum-cost        = 0
        v-need-page-break = yes
        v-sum-sale        = gp-price-sale
        v-sum-mass        = 0
    .
    run print-title in this-procedure.

    form with frame f-op-1 .
    view stream Out-Stream frame BottomFrame .
    down stream Out-Stream 1 with frame f-op-1 no-labels.

    run print-header in this-procedure.
    run print-header-numbers (
          input v-single-line
        , input no
    ).
    for each buf_recipe-gds no-lock
       where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe-gds.artic
               and buf_goods.prod-type  = buf_recipe-gds.prod-type
               and buf_goods.prod-code  = buf_recipe-gds.prod-code
        .
        { gbl/gdsbcode.i
            buf_goods.gds-code
            ?
            v-bar-code
        no-error }.
        assign
            v-line-counter  = v-line-counter + 1
            v-goods-artic   = string( buf_goods.artic )
            v-goods-name    = buf_goods.gds-name
            v-mass          = buf_recipe-gds.brutto-qnty / buf_recipe.qnty
            v-sum-mass      = v-sum-mass + ( if buf_recipe-gds.is-waste = yes then 0.0 else v-mass )
        .
        if buf_recipe-gds.is-waste <> yes
        then do:
            run gdsoattr-value in this-procedure (
                input {&attr-fbr-cost-rubl}
                , input buf_goods.gds-code
                , input p-store-type
                , input p-store-code
                , output v-attr-value
                , output v-attr-type
            ).
            assign
                v-cost = decimal( v-attr-value )
            no-error.
            if error-status :error
            then do:
                assign
                    v-cost = 0.0
                .
            end.
            assign
                v-sum           = v-cost * v-mass
                v-sum-cost      = v-sum-cost + v-sum
            .
        end.
        else do:
            assign
                v-cost          = 0
                v-sum           = 0
            .
        end.
        display stream out-stream
            sym1  v-line-counter
            sym2  v-goods-artic
            sym3  v-goods-name
            sym4  v-bar-code
            sym5  v-mass
            sym6  v-cost
            sym7  v-sum
            sym8
        with frame f-op-1.
        down stream out-stream 1 with frame f-op-1.
    end.        /* for each buf_recipe-gds no-lock */
    assign
        v-sum-prc       = ( v-sum-sale - v-sum-cost ) / v-sum-cost * 100
    .
    put stream out-stream
        skip space({&P-S})
        "|"
        v-single-line             format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space (1)
        "Общая стоимость сырьевого набора"
        ":"                                               at {&P-C5-S}
        v-sum-cost                format ">>>,>>>,>>9.99" at right-field({&P-E}, 14)
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line             format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space (1)
        substitute( "Наценка &1%, {&abbr_rub}. {&abbr_kop}", string( v-sum-prc, "->>9.99") )
                                    format "X({&P-X1})"
        ":"                                               at {&P-C5-S}
        ( v-sum-sale - v-sum-cost ) format "->>,>>>,>>9.99" at right-field({&P-E}, 14)
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line   format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space (1)
        "Цена продажи блюда, {&abbr_rub}. {&abbr_kop}"
        ":"                                               at {&P-C5-S}
        v-sum-sale                format ">>>,>>>,>>9.99" at right-field({&P-E}, 14)
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line             format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space (1)
        "Выход одного блюда в готовом виде, грамм"
        ":"                                               at {&P-C5-S}
        string( buf_recipe.portion-weight * 1000, ">>>,>>>,>>9.99" )
                                    format "X(14)"          at right-field({&P-E}, 14)
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line   format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space(1)
        "Заведующий производством"
        ":"                                               at {&P-C4-S}
        space(1) "подпись"
        ":"                                               at {&P-C5-S}
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line   format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space(1)
        "Калькуляцию составил"
        ":"                                               at {&P-C4-S}
        space(1) "подпись"
        ":"                                               at {&P-C5-S}
        "|"                                               at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line   format "X({&P-X0})"
        "|"
        skip space({&P-S})
        "|" space (1)
        "УТВЕРЖДАЮ. Руководитель организации"
        ":"                                               at {&P-C4-S}
        space(1) "подпись"
        ":"                                               at {&P-C5-S}
        "|"                                               at {&P-E}
        skip space({&P-S})
        v-single-line   format "X({&P-X})"
    .
    hide stream Out-Stream frame BottomFrame .
    output stream Out-Stream close.
    { gbl/stopwork.i }
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    run gbl/prnfilen.w (
          input "":U
        , input 4
        , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ) .
end.

/*============================================================================*/
/*                    Шапка с цифрами для каждой новой страницы               */
/*============================================================================*/
procedure print-header-numbers :
do
on error undo, return error
:
def input parameter p-single-line as char    no-undo.
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
          "7"                  at center-field( {&P-C7-S}, {&P-E}, 1)
          "|"                  at {&P-E}
        skip space({&P-S})
          "|"
          p-single-line format "X({&P-X0})"
          "|"                  at {&P-E}

    .
end.
end procedure. /* print-header-numbers */

/*============================================================================*/
/*                    Итоги для каждой страницы и общие                       */
/*============================================================================*/
procedure write-itog :
do
on error undo, return error
:
    def input parameter p-type          as char no-undo.     /*"Итого" или "Всего"*/
    def input parameter p-in-mass       as decimal no-undo.
    def input parameter p-in-sum        as decimal no-undo.
    def input parameter p-out-norm-mass as decimal no-undo.
    def input parameter p-out-fact-mass as decimal no-undo.
    def input parameter p-out-fact-sum  as decimal no-undo.

    put stream Out-Stream
      skip space({&P-S})
        v-single-line format "X({&P-X})"
    .
/*    display stream out-stream*/
/*              p-type                              @ v-in-price*/
/*      sym7    p-in-mass       format ">>>9.99"    @ v-in-mass*/
/*      sym8    p-in-sum        format ">>>>>9.99"  @ v-in-sum*/
/*      sym13   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass*/
/*      sym14*/
/*      sym15   p-out-norm-mass format ">>>9.99"    @ v-out-sum-norm-mass*/
/*      sym16   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass*/
/*      sym17*/
/*      sym18   p-out-fact-mass format ">>>9.99"    @ v-out-fact-mass*/
/*      sym19   p-out-fact-sum  format ">>>>>9.99"  @ v-out-sum*/
/*      sym21*/
/*    with frame f-op-1.*/

end.
end procedure. /* write-itog */

/*==========================================================================*/
procedure check-all-weight-kg :
do
on error undo, return error
:
define input parameter p-recipe-code            as character    no-undo.
define output parameter p-no-printable-recipe   as logical      no-undo.

    define variable v-is-weight     as logical init no    no-undo.

    def buffer  buf_recipe-gds  for recipe-gds.
    def buffer  buf_goods       for goods.
    def buffer  buf_units       for units.

        assign
            p-no-printable-recipe = no
        .
        for each buf_recipe-gds
           where buf_recipe-gds.recipe-code  = p-recipe-code
        :
            find first buf_goods
                 where buf_goods.artic      = buf_recipe-gds.artic
                   and buf_goods.prod-type  = buf_recipe-gds.prod-type
                   and buf_goods.prod-code  = buf_recipe-gds.prod-code
            .
            if buf_goods.gds-type <> {&gds-office} /*Для услуг проверки на единицу измерения нет*/
            then do:                                    /*Остальные ингредиенты должны быть весовыми*/
                assign
                    v-is-weight = no
                .
                for each buf_units no-lock
                   where buf_units.type = {&weight}
                :
                    if buf_goods.unit-base = buf_units.unit-name
                    then do:
                        assign
                            v-is-weight = yes
                        .
                    end.
                end.
                if v-is-weight = no
                then do:
                    assign
                        p-no-printable-recipe = yes
                    .
                    leave.
                end.
            end.
        end.
end.
end procedure. /* check-all-weight-kg */

/*==========================================================================*/
procedure print-title :
do
on error undo, return error
:
        put stream Out-Stream
          skip
            string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
          skip
            space({&P-S}) v-single-line format  "X(16)"             at {&P2-S}
          skip
            space({&P-S}) "| "                                      at {&P2-S}
                          {&g___code}                               at center-field({&P2-S}, {&P-E}, length({&g___code}))
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Форма по ОКУД" format "X(14)"            at right-field({&P2-S}, 13)
                          "| "                                      at {&P2-S}
                          "0330501"                                 at center-field({&P2-S}, {&P-E}, 7)
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Организация:               "
                    v-organization                format "X(60)"
                    "по ОКПО"                                      at right-field({&P2-S}, 7)
                    "|"                                            at {&P2-S}
                    trim(t-okpo)                  format "X(10)"   at right-field( {&P-E}, 10)
                    "|"                                            at {&P-E}
          skip
            space({&P-S}) "Структурное подразделение: "
                          v-org-name              format "X(60)"
                          "|"                                       at {&P2-S}
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Вид деятельности по ОКДП"
                                                  format "X(25)"    at right-field({&P2-S}, 25)
                          "|"                                       at {&P2-S}
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Наименование блюда:        "
                          v-recipe-name           format "X(60)"
                          "|"                                       at {&P2-S}
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Номер блюда по сборнику рецептур"
                                                  format "X(32)"    at right-field({&P2-S}, 32)
                          "|"                                       at {&P2-S}
                          buf_recipe.recipe-code  format "X(8)"     at center-field({&P2-S}, {&P-E}, 8)
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) "Вид операции"          format "X(12)"    at right-field({&P2-S}, 12)
                          "|"                                       at {&P2-S}
                          buf_recipe.recipe-type  format "X(12)"    at center-field({&P2-S}, {&P-E}, 12)
                          "|"                                       at {&P-E}
          skip
            space({&P-S}) v-single-line           format  "X(16)"   at {&P2-S}
        .

        put stream Out-Stream
          skip space({&P-S})
              v-single-line   format  "X({&P3-X})"   at {&P3-S} + 1
          skip space({&P3-S})
              "|"
              "Номер"                           at  center-field({&P3-S}, {&P3-C2-S}, 5)
              "|"                               at {&P3-C2-S}
              "Номер"                           at  center-field({&P3-C2-S}, {&P3-C3-S}, 5)
              "|"                               at {&P3-C3-S}
              "Дата"                            at  center-field({&P3-C3-S}, {&P3-E}, 4)
              "|"                               at {&P3-E}
          skip space({&P3-S})
              "|"
              "документа"     format "X(9)"     at  center-field({&P3-S}, {&P3-C2-S}, 9)
              "|"                               at {&P3-C2-S}
              "рецепта"       format "X(7)"     at  center-field({&P3-C2-S}, {&P3-C3-S}, 7)
              "|"                               at {&P3-C3-S}
              "составления"   format "X(11)"    at  center-field({&P3-C3-S}, {&P3-E}, 11)
              "|"                               at {&P3-E}
          skip space({&P3-S})
              "|"
              v-single-line   format "X({&P3-X0})"
              "|"  at {&P3-E}
          skip
              space(25) "КАЛЬКУЛЯЦИОННАЯ КАРТОЧКА | "
              v-doc-code format "X(16)"
              " | "
              fill( " ", 10 - length(buf_recipe.recipe-code)) + buf_recipe.recipe-code
                              format "X(10)"            at  right-field( {&P3-C3-S}, 10)
              "| "                                      at {&P3-C3-S}
              v-fact-date     format "99/99/9999"
              "|"                                       at {&P3-E}
          skip space({&P-S})
              v-single-line   format  "X({&P3-X})"      at {&P3-S} + 1
        .
end.
end procedure. /* print-title */

/*==========================================================================*/
procedure print-header :
do
on error undo, return error
:
    put stream Out-Stream
        skip space({&P-S})
            v-single-line format "X({&P-X})"
        skip space({&P-S})
            "|"
            ":"                                  at {&P-C2-S}
            "Продукты"                           at center-field( {&P-C2-S}, {&P-C5-S}, 8)
            ":"                                  at {&P-C5-S}
            ":"                                  at {&P-C6-S}
            ":"                                  at {&P-C7-S}
        "|"                                  at {&P-E}
        skip space({&P-S})
            "|"
            "Но-"
            ":"                                  at {&P-C2-S}
            v-single-line format "X({&P-X1})"
            ":"                                  at {&P-C5-S}
            "норма,"                             at center-field( {&P-C5-S}, {&P-C6-S}, 6)
            ":"                                  at {&P-C6-S}
            "цена,"                              at center-field( {&P-C6-S}, {&P-C7-S}, 5)
            ":"                                  at {&P-C7-S}
            "сумма,"                             at center-field( {&P-C7-S}, {&P-E}, 6)
            "|"                                  at {&P-E}
        skip space({&P-S})
            "|"
            "мер"
            ":"                                  at {&P-C2-S}
            "Артикул"                            at center-field( {&P-C2-S}, {&P-C3-S}, 7)
            ":"                                  at {&P-C3-S}
            "Наименование"                       at center-field( {&P-C3-S}, {&P-C4-S}, 12)
            ":"                                  at {&P-C4-S}
            "Код"                                at center-field( {&P-C4-S}, {&P-C5-S}, 3)
            ":"                                  at {&P-C5-S}
            ":"                                  at {&P-C6-S}
            "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C6-S}, {&P-C7-S}, 7)
            ":"                                  at {&P-C7-S}
            "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C7-S}, {&P-E}, 7)
            "|"                                  at {&P-E}
        skip space({&P-S})
        "|"
        v-single-line format "X({&P-X0})"
        "|" at {&P-E}
    .
end.
end procedure. /* print-header */