/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: op-1.p $
$Archive: rep/op-1.p $

Печатная форма ОП-1. Производство, калькуляционная карточка.

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Печатается только для рецептов, составленных для весовых товаров,
с компонентами - весовыми товарами.
Единица измерения весового товара - ТОЛЬКО кг.

*/
using Ibs.Th.Gbl.*.
block-level on error undo, throw.

define input parameter p-mainmenu-handle    as handle    no-undo.
define input parameter p-recid              as recid     no-undo.
define input parameter p-print-in-rubl      as logical   no-undo.
define input parameter p-print-details      as logical   no-undo.
define input parameter p-price-celection    as integer   no-undo.
define input parameter p-print-null-qnty    as logical   no-undo.
define input parameter p-sort-by-group      as logical   no-undo.
define input parameter p-price-from-doc     as logical   no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-1.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-1. Производство, калькуляционная карточка.".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ str/lib-trn.i     }
{ cmp/r-pril.i      }
{ str/get-pr.i   def}
{ rep/p-fmt.i       }
{ rep/r-cliprp.i def}
{ str/getctxtp.i def}

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

    define stream out-stream .

    define temp-table temp_recipe no-undo
        field recipe-code       as character
        field artic             as character
        field prod-type         as character
        field prod-code         as integer
        field gds-code          as integer
        field goods-unit        as character
        field recipe-type       as character
        field recipe-name       as character
        field qnty              as decimal
        field portion-weight    as decimal
        field portion-qnty      as decimal
        field sum-cost          as decimal
        field sum-sale          as decimal
        field sum-prc           as decimal

        index pi is primary unique
            recipe-code
    .

    define variable v-table-line-counter        as integer                  no-undo.
    define variable v-line-counter        as integer                  no-undo.
    define variable v-organization        as char                     no-undo.
    define variable v-org-name            as char                     no-undo.
    define variable v-recipe-name         as char                     no-undo.
    define variable v-doc-code            as char                     no-undo.
    define variable v-fact-date           as date                     no-undo.
    define variable v-goods-unit          as char                     no-undo.
    define variable v-goods-artic         as char                     no-undo.
    define variable v-goods-name          as char                     no-undo.
    define variable v-bar-code            as integer                  no-undo.
    define variable v-mass                as decimal                  no-undo.
    define variable v-cost                as decimal                  no-undo.
    define variable v-sum                 as decimal                  no-undo.
    define variable v-sum-cost            as decimal                  no-undo.
    define variable v-sum-prc             as decimal                  no-undo.
    define variable v-sum-sale            as decimal                  no-undo.
/*    define variable v-sum-mass            as decimal                  no-undo.*/
    define variable sym1  as char init "|" no-undo.
    define variable sym2  as char init ":" no-undo.
    define variable sym3  as char init ":" no-undo.
    define variable sym4  as char init ":" no-undo.
    define variable sym5  as char init ":" no-undo.
    define variable sym6  as char init ":" no-undo.
    define variable sym7  as char init ":" no-undo.
    define variable sym8  as char init "|" no-undo.
    define variable v-single-line         as char               no-undo.
    define variable v-underline           as char               no-undo.
    define variable v-no-printable-recipe as logical init no    no-undo.
    define variable v-need-page-break     as logical init no    no-undo.
    define variable v-first-recipe        as logical      no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods         for ub.goods.
    define buffer buf_clients       for ub.clients.
    define buffer buf_units         for ub.units.
    define buffer buf_temp_recipe   for temp_recipe.

/* для excel */        
def var v-rep-gen as class ReportXml no-undo.
def shared var v-rep-util as class ReportXsltUtil no-undo.

v-rep-gen = v-rep-util:get-data-generator().
    
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_clients
  , buf_units
  , buf_temp_recipe
on error undo, return error
:

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
define shared variable CostPrice    as logical                          no-undo.

    find first buf_fbr-doc no-lock
        where recid(buf_fbr-doc) = p-recid
    no-error.
    if not available buf_fbr-doc
    then do:
        message
            "Не найден документ производства."
            skip (1) "Форму ОП-1 напечатать невозможно."
        view-as alert-box.
        undo, return.
    end.
/*    if buf_fbr-doc.status_ <> {&fact}*/
/*    then do:*/
/*        message*/
/*            "Печать калькуляционной карточки возможна"*/
/*            skip "только после закрытия документа до статуса ФАКТ"*/
/*        view-as alert-box error.*/
/*        undo, return error .*/
/*    end.*/
    if buf_fbr-doc.is-free = yes
    then do:
        message
            "Калькуляционная карточка не может быть напечатана"
            skip "для документа производства без рецептов."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-single-line  = fill("-", 230)
        v-underline    = fill("_", 230)
    .
    assign
        v-doc-code     = buf_fbr-doc.doc-code
        v-fact-date    = buf_fbr-doc.fact-date
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

{ gbl/working.i }
{ cmp/open-out.i stream Out-Stream " " {&CS_PS} }

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
    fill-temp-recipe:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.is-comp  = yes
    :
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code     = buf_fbr-line.doc-code
               and buf_fbr-recipe.recipe-code  = buf_fbr-line.recipe-code
        no-error.
        
        if available buf_fbr-recipe
        and buf_fbr-recipe.recipe-type = {&manufacturing}
        then do:
            
            find first buf_temp_recipe no-lock
                 where buf_temp_recipe.recipe-code = buf_fbr-line.recipe-code
            no-error.
                if not available buf_temp_recipe
                then do:
/*                run check-all-weight-kg in this-procedure (*/
/*                      input buf_fbr-line.doc-code*/
/*                    , input buf_fbr-line.recipe-code*/
/*                    , output v-no-printable-recipe*/
/*                ).*/
/*                if v-no-printable-recipe = yes*/
/*                then do:*/
/*                    message*/
/*                        "Калькуляционная карточка может быть распечатана "*/
/*                        skip "только для рецептов с весовыми ингредиентами "*/
/*                        skip "(единица измерения - кг)."*/
/*                        skip(1)*/
/*                        skip "В рецепте есть невесовой товар."*/
/*                        skip "Рецепт номер:" buf_fbr-line.recipe-code*/
/*                        skip "Артикул товара рецепта: " buf_fbr-line.artic*/
/*                    view-as alert-box.*/
/*                    undo fill-temp-recipe, next fill-temp-recipe.*/
/*                end.*/

                create buf_temp_recipe.
                assign
                    buf_temp_recipe.recipe-code     = buf_fbr-line.recipe-code
                    buf_temp_recipe.artic           = buf_fbr-line.artic
                    buf_temp_recipe.prod-type       = buf_fbr-line.prod-type
                    buf_temp_recipe.prod-code       = buf_fbr-line.prod-code
                    buf_temp_recipe.portion-weight  = buf_fbr-recipe.portion-weight
                    buf_temp_recipe.portion-qnty    = buf_fbr-recipe.portion-qnty
                    buf_temp_recipe.recipe-type     = buf_fbr-recipe.recipe-type
                    buf_temp_recipe.qnty            = buf_fbr-recipe.qnty
                .
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_temp_recipe.artic
                       and buf_goods.prod-type  = buf_temp_recipe.prod-type
                       and buf_goods.prod-code  = buf_temp_recipe.prod-code
                no-error.
                if available buf_goods
                then do:
                    assign
                        buf_temp_recipe.gds-code = buf_goods.gds-code
                    .
                    { gbl/gdsbcode.i
                        buf_goods.gds-code
                        ?
                        v-bar-code
                    no-error }.
                    { str/get-pr.i
                        " "
                        buf_fbr-doc.obj-type
                        buf_fbr-doc.obj-code
                        buf_goods.gds-code
                        ?
                        " "
                    }       /*Цена составного товара*/
                    assign
                        buf_temp_recipe.recipe-name     = substitute( "&1  &2", buf_goods.artic, buf_goods.gds-name )
                        buf_temp_recipe.goods-unit      = buf_goods.unit-base
                        buf_temp_recipe.sum-cost        = 0
                        buf_temp_recipe.sum-sale        = ( if not p-price-from-doc then gp-price-sale else buf_fbr-line.price-sale ) * buf_temp_recipe.qnty
                    .
                end.
            end.        /* if not available buf_temp_recipe */
        end.        /* find first buf_fbr-recipe no-lock */
    end.
    assign
        v-first-recipe = yes
    .
    
    for each buf_temp_recipe
    :
        v-rep-util:begin-report().        
        v-rep-util:set-current-template("exe\op-1.xml").
               
/*        if v-need-page-break = yes*/
/*        then do:*/
/*            page stream out-stream.*/
/*        end.*/
/*        find first buf_units no-lock*/
/*            where buf_units.unit-name = buf_goods.unit-base*/
/*        .*/

        if v-first-recipe = no
        then do:
            page stream out-stream.
        end.
        assign
            v-first-recipe = no
        .
        run print-title in this-procedure (
              input buf_temp_recipe.recipe-code
            , input buf_fbr-doc.status_
        ).
        run print-header in this-procedure.
        run print-header-numbers (
              input v-single-line
            , input no
        ).
        view stream Out-Stream frame BottomFrame .
        assign
            v-line-counter    = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code      = buf_fbr-doc.doc-code
             and buf_fbr-line.is-comp       = no
             and buf_fbr-line.recipe-code   = buf_temp_recipe.recipe-code
        :
            assign
                v-line-counter  = v-line-counter + 1
                v-goods-artic   = string( buf_fbr-line.artic )
            .
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_fbr-line.artic
                   and buf_goods.prod-type  = buf_fbr-line.prod-type
                   and buf_goods.prod-code  = buf_fbr-line.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    v-goods-name    = buf_goods.gds-name
                .
            end.
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code    = buf_fbr-doc.doc-code
                   and buf_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                   and buf_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                   and buf_fbr-recipe-gds.artic       = buf_fbr-line.artic
            no-error.
            if available buf_fbr-recipe-gds
            then do:
/*                assign*/
/*                    v-sum-mass      = v-sum-mass + ( if buf_fbr-recipe-gds.is-waste = yes then 0 else v-mass )*/
/*                .*/

                assign
                    v-mass  = ( if not available buf_goods
                                or buf_goods.gds-type = {&gds-office}
                                then 0
                                else buf_fbr-recipe-gds.brutto-qnty
                              )
                .
                if buf_fbr-recipe-gds.is-waste <> yes /* отходы */
                then do:
                    if not costprice then
                        do:
                            if p-price-from-doc then
                                v-cost = buf_fbr-line.price-sale.
                            else
                                do: 
                                    { str/get-pr.i
                                        " "
                                        buf_fbr-doc.obj-type
                                        buf_fbr-doc.obj-code
                                        buf_goods.gds-code
                                        ?
                                        " "
                                    }
                                    v-cost = gp-price-sale.
                                end.
                        end.
                     else
                        v-cost = buf_fbr-line.price-rubl.
                        
                    assign                  
                    /*v-cost = ( if costprice then buf_fbr-line.price-rubl else buf_fbr-line.price-sale )
                    */
                    v-sum                       = round(v-cost * v-mass , 2)
                    buf_temp_recipe.sum-cost    = buf_temp_recipe.sum-cost + v-sum
                    .
                end.
                else do:
                  assign
                    v-cost          = 0
                    v-sum           = 0
                  .
                end.
            end.
            run print-line in this-procedure (
                  input v-line-counter
                , input v-goods-artic
                , input v-goods-name
                , input buf_goods.gds-code
                , input v-mass
                , input v-cost
                , input v-sum
            ).
        end.        /* for each buf_fbr-line no-lock */
        assign
            buf_temp_recipe.sum-prc       = ( if costprice
                                              then ( buf_temp_recipe.sum-sale - buf_temp_recipe.sum-cost ) / buf_temp_recipe.sum-cost * 100
                                              else 0.0 )
        .
                
        v-rep-gen:add-element("buf_temp_recipe.sum-cost", string(buf_temp_recipe.sum-cost, ">>>,>>>,>>9.99")).
        v-rep-gen:add-element("buf_temp_recipe.sum-sale", string(buf_temp_recipe.sum-sale, ">>>,>>>,>>9.99")).
        v-rep-gen:add-element("buf_temp_recipe.portion-weight", string( buf_temp_recipe.portion-weight * 1000, ">>>,>>>,>>9.99" )).
        
        def var mark-on-1 as char no-undo.
        mark-on-1 = substitute( "Наценка &1%, {&abbr_rub}. {&abbr_kop}", string( buf_temp_recipe.sum-prc, "->>9.99") ).
        
        def var mark-on-2 as char no-undo.
        mark-on-2 = (if costprice then
                        string( buf_temp_recipe.sum-sale - buf_temp_recipe.sum-cost, "->>,>>>,>>9.99")
                    else
                        "0.00").
        
        v-rep-gen:add-element("mark-on-1", mark-on-1).
        v-rep-gen:add-element("mark-on-2", mark-on-2).
                
        put stream out-stream
        skip space({&P-S})
            "|"
            v-single-line             format "X({&P-X0})"
            "|"
        skip space({&P-S})
            "|" space (1)
            /*substitute(*/ "Общая стоимость сырьевого набора  " /*на &1 порций*/ /*, string(buf_temp_recipe.portion-qnty) ) format "X({&P-X1})" */
            ":"                                               at {&P-C5-S}
            buf_temp_recipe.sum-cost                format ">>>,>>>,>>9.99" at right-field({&P-E}, 14)
            "|"                                               at {&P-E}
        skip space({&P-S})
            "|"
            v-single-line             format "X({&P-X0})"
            "|"
        skip space({&P-S})
            "|" space (1)
            mark-on-1
                                      format "X({&P-X1})"
            integer ( mark-on-2 ) format "->>,>>>,>>9.99" at right-field({&P-E}, 14)
            "|"                                               at {&P-E}
        skip space({&P-S})
            "|"
            v-single-line   format "X({&P-X0})"
            "|"
        skip space({&P-S})
            "|" space (1)
            "Цена продажи блюда, {&abbr_rub}. {&abbr_kop}"
            ":"                                               at {&P-C5-S}
            buf_temp_recipe.sum-sale /*/ buf_temp_recipe.portion-qnty*/  format ">>>,>>>,>>9.99" at right-field({&P-E}, 14)
            "|"                                               at {&P-E}
        skip space({&P-S})
            "|"
            v-single-line             format "X({&P-X0})"
            "|"
        skip space({&P-S})
            "|" space (1)
            "Выход одного блюда в готовом виде, грамм"
            ":"                                               at {&P-C5-S}
            string( buf_temp_recipe.portion-weight * 1000, ">>>,>>>,>>9.99" )
                                    format "X(14)"          at right-field({&P-E}, 14)
/*                    (if v-goods-unit = "кг"*/
/*                    then "       1000.00"*/
/*                    else string(v-sum-mass * 1000, ">>>,>>>,>>9.99"))*/
/*                                            format "X(14)"          at right-field({&P-E}, 14)*/
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
        hide stream out-stream frame BottomFrame .
        
        v-rep-util:end-report().
    end.        /* for each buf_temp_recipe */
    output stream Out-Stream close.
    { gbl/stopwork.i }
    { rep/q-print.i 4}

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

end.
end procedure. /* write-itog */

/*==========================================================================*/
procedure check-all-weight-kg :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code       as character    no-undo.
define input parameter p-recipe-code            as character    no-undo.
define output parameter p-no-printable-recipe   as logical      no-undo.

    define variable v-is-weight     as logical init no    no-undo.

    define buffer  buf_fbr-line for ub.fbr-line.
    define buffer  buf_goods    for ub.goods.
    define buffer  buf_units    for ub.units.

        assign
            p-no-printable-recipe = no
        .
        for each buf_fbr-line
           where buf_fbr-line.doc-code     = p-fbr-doc-doc-code
             and buf_fbr-line.is-comp      = no
             and buf_fbr-line.recipe-code  = p-recipe-code
        :
            find first buf_goods
                 where buf_goods.artic      = buf_fbr-line.artic
                   and buf_goods.prod-type  = buf_fbr-line.prod-type
                   and buf_goods.prod-code  = buf_fbr-line.prod-code
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
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-fbr-doc-status as character        no-undo.

    define buffer buf_temp_recipe       for temp_recipe.
do
for buf_temp_recipe
on error undo, return error
:
    find first buf_temp_recipe
         where buf_temp_recipe.recipe-code = p-recipe-code
    .
    
    v-rep-gen:add-element("v-organization", v-organization).
    v-rep-gen:add-element("t-okpo", t-okpo).
    v-rep-gen:add-element("v-org-name", v-org-name).
    v-rep-gen:add-element("buf_temp_recipe.recipe-name", buf_temp_recipe.recipe-name).
    v-rep-gen:add-element("buf_temp_recipe.recipe-code", buf_temp_recipe.recipe-code).
    v-rep-gen:add-element("buf_temp_recipe.recipe-type", buf_temp_recipe.recipe-type).
    v-rep-gen:add-element("v-doc-code", v-doc-code).
    v-rep-gen:add-element("p-recipe-code", p-recipe-code).
    v-rep-gen:add-element("v-fact-date", if v-fact-date = ? then "" else string(v-fact-date)).
    v-rep-gen:add-element("p-fbr-doc-status", p-fbr-doc-status).
    
    def var tmp1 as char no-undo.
    tmp1 = ( if p-fbr-doc-status <> {&fact} then substitute( " Статус: &1", p-fbr-doc-status ) else "":U ).
    
    def var tmp2 as char no-undo.
    tmp2 = (if CostPrice        =  no      then substitute( " Цены реализации" )              else "":U).
    
    v-rep-gen:add-element("status1", tmp1 + " " + tmp2).
    
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
                        buf_temp_recipe.recipe-name           format "X(60)"
                        "|"                                       at {&P2-S}
                        "|"                                       at {&P-E}
        skip
        space({&P-S}) "Номер блюда по сборнику рецептур"
                                                format "X(32)"    at right-field({&P2-S}, 32)
                        "|"                                       at {&P2-S}
                        buf_temp_recipe.recipe-code           format "X(8)"     at center-field({&P2-S}, {&P-E}, 8)
                        "|"                                       at {&P-E}
        skip
        space({&P-S}) "Вид операции"          format "X(12)"    at right-field({&P2-S}, 12)
                        "|"                                       at {&P2-S}
                        buf_temp_recipe.recipe-type           format "X(12)"    at center-field({&P2-S}, {&P-E}, 12)
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
            fill( " ", 10 - length( p-recipe-code ) ) + p-recipe-code
                            format "X(10)"            at  right-field( {&P3-C3-S}, 10)
            "| "                                      at {&P3-C3-S}
            v-fact-date     format "99/99/9999"
            "|"                                       at {&P3-E}
            ( tmp1 ) format "X(15)"
            ( tmp2 ) format "X(16)"
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
            "|"                                    at {&P-E}
          skip space({&P-S})
              "|"
              "Но-"
              ":"                                  at {&P-C2-S}
              v-single-line format "X({&P-X1})"
              ":"                                  at {&P-C5-S}
              "норма"                              at center-field( {&P-C5-S}, {&P-C6-S}, 5)
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
/*              "кг"                                 at center-field( {&P-C5-S}, {&P-C6-S}, 2)*/
              ":"                                  at {&P-C6-S}
              "{&abbr_rub}.{&abbr_kop}"            at center-field( {&P-C6-S}, {&P-C7-S}, 7)
              ":"                                  at {&P-C7-S}
              "{&abbr_rub}.{&abbr_kop}"            at center-field( {&P-C7-S}, {&P-E}, 7)
              "|"                                  at {&P-E}
          skip space({&P-S})
            "|"
            v-single-line format "X({&P-X0})"
            "|" at {&P-E}
        .

end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-line :
define input parameter p-line-counter as integer          no-undo.
define input parameter p-goods-artic  as character        no-undo.
define input parameter p-goods-name   as character        no-undo.
define input parameter p-bar-code     as character        no-undo.
define input parameter p-mass         as decimal          no-undo.
define input parameter p-cost         as decimal          no-undo.
define input parameter p-sum          as decimal          no-undo.

do
on error undo, return error
:
    v-rep-gen:start-element("table").
    v-rep-gen:add-element("p-line-counter", string(p-line-counter, ">>9")).
    v-rep-gen:add-element("p-goods-artic", p-goods-artic).
    v-rep-gen:add-element("p-goods-name", p-goods-name).
    v-rep-gen:add-element("p-bar-code", string(p-bar-code, "X(9)")).
    v-rep-gen:add-element("p-mass", string(p-mass, ">,>>9.999")).
    v-rep-gen:add-element("p-cost", string(p-cost, ">>,>>>,>>9.99")).
    v-rep-gen:add-element("p-sum", string(p-sum, ">>>,>>>,>>9.99")).
    v-rep-gen:end-element("table").
    
    put stream out-stream
        skip space({&P-S})
            "|"
            p-line-counter    format ">>9"
            ":"                                  at {&P-C2-S}
            p-goods-artic     format "X(16)"
            ":"                                  at {&P-C3-S}
            p-goods-name      format "X(47)"
            ":"                                  at {&P-C4-S}
            p-bar-code        format "X(9)"
            ":"                                  at {&P-C5-S}
            p-mass            format ">,>>9.999"
            ":"                                  at {&P-C6-S}
            p-cost            format ">>,>>>,>>9.99"
            ":"                                  at {&P-C7-S}
            p-sum             format ">>>,>>>,>>9.99"
            "|"                                  at {&P-E}
    .
end.
end procedure. /* print-line */
