/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать акта и протокола переоценки. Библиотека.

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
    def var v-price-list-doc-num            like price-list.doc-num     no-undo.
    def var v-price-list-price-sale         like price-list.price-sale  no-undo.
    def var v-price-list-price-sale_old     like price-list.price-sale  no-undo.
    def var v-price-list-road-tax           like price-list.road-tax    no-undo.
    def var v-price-list-excise             like price-list.excise      no-undo.

    def var v-price-list-b-code             like bar-code.b-code        no-undo.

    def var v-gds-obj-last-price            like gds-obj.last-rubl      no-undo.

    def var v-gds-prt-node-code             like gds-prt.node-code      no-undo.
    def var v-gds-prt-node-name             like gds-prt.node-name      no-undo.

    def var v-code-is-main                  as logical                  no-undo.

    def var v-not-main-unit-cli             like bar-code.unit-cli      no-undo.
    def var v-not-main-cli-base-rate        like bar-code.cli-base-rate no-undo.
    def var v-not-main-b-code               like bar-code.cli-base-rate no-undo.

    def var v-taxname                       as char                     no-undo.
    def var v-tax                           as decimal  init 0          no-undo.
    def var v-tax-sum                       as decimal  init 0          no-undo.
    def var v-tax-parts-qnty                as decimal  init 0          no-undo.

&endif
&if "{1}" = "calc" &then
        /*---S----------- Имя товара с шкалой --------------------------------*/
            find first bar-code no-lock
                 where bar-code.b-code = price-list.b-code
            .

            if bar-code.unit-cli = goods.unit-base
            then do:
                assign
                    v-code-is-main = yes
                .
            end.
            else do:
                assign
                    v-code-is-main = no
                .
            end.

            if not (v-code-is-main = yes)
            then do:
                assign
                    v-not-main-unit-cli       = bar-code.unit-cli
                    v-not-main-cli-base-rate  = bar-code.cli-base-rate
                    v-not-main-b-code         = bar-code.b-code
                .
            end.

            find first gds-prt no-lock
                 where gds-prt.node-code = bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if gds-prt.upper-code = goods.prt-root
                then if bar-code.in-code = ''
                    then goods.gds-name
                    else bar-code.in-code + '    ' + bar-code.part-code
                else
                    &if "{2}" = "not-main" &then
                        goods.gds-name + "//" + gds-prt.f-name
                    &else
                        '    ' + gds-prt.f-name
                    &endif
              )
            .
            run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Определили имя товара со шкалой ( "
                                                + dtm-char(v-gds-prt-node-name)
                                                + " )").
        /*---E----------- Имя товара с шкалой --------------------------------*/
            find first gds-obj no-lock
                 where gds-obj.obj-type  = price-list.obj-type
                   and gds-obj.obj-code  = price-list.obj-code
                   and gds-obj.prod-type = price-list.prod-type
                   and gds-obj.prod-code = price-list.prod-code
                   and gds-obj.artic     = price-list.artic
            no-error.
            if available gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then gds-obj.last-base else gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Нашли товар ( "
                                + string(gds-obj.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Определили цену закупки ( "
                                + dtm-char(string(v-gds-obj-last-price)) + " )"
                                                    ).
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Не нашли товара ( "
                                + string(price-list.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Назначили цену закупки ( 0 )"
                                                    ).
            end.

            find first gds-prt no-lock
                 where gds-prt.upper-code = goods.prt-root
            .
            assign
                v-gds-prt-node-code = gds-prt.node-code
            .

            { gbl/bcodeprc.i
                price-list.obj-type
                price-list.obj-code
                price-list.b-code
                0
                price-list.fact-order
                v-price-list-doc-num
                v-price-list-price-sale
                v-price-list-road-tax
                v-price-list-excise
            }

            if v-price-list-price-sale = ?
            then do:
                assign
                    v-price-list-price-sale = 0
                .
            end.

            if v-price-list-road-tax = ?
            then do:
                assign
                    v-price-list-road-tax = 0
                .
            end.


            assign
                v-price-list-price-sale_old = v-price-list-price-sale
            .

            run writelog in this-procedure (log-file-name, 4,
                                                        "R-AKT.i   Определили продажную цену из прайс-листа ( "
                                                        + dtm-char(string(v-price-list-price-sale)) + " )"
                                                ).

/*            find first bar-code no-lock*/
/*                 where bar-code.b-code = price-list.b-code*/
/*            .*/

            { gbl/gdsbcode.i
                goods.gds-code
                bar-code.node-code
                v-price-list-b-code
            }

            find first bar-code no-lock
                 where bar-code.b-code = v-price-list-b-code
            .

            accumulate bar-code.b-code ( count ) .

&endif

&if "{1}" = "group" &then
    if v-shift-down = yes
    then do:
        down stream AktStr 1
           with frame &if "{2}" = "cost" &then Akt-Cost &else Akt &endif
        .
        assign
            v-shift-down = no
        .
    end.
    if v-print-group = yes
    then do:
        run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Печать имени группы ( " + goods.grp-name + " )").
        put stream aktstr
            goods.grp-name format "X({&A4_CW0})" AT 1
        .
    end.
&endif

&if "{1}" = "third-tax" &then

    if hvrdtax (recid(goods))
    then do:
        run tax-name (  input {&road-tax}
                      , output v-taxname
                     ).
        assign
            v-tax       = price-list.road-tax * price-list.doc-qnty
            v-tax-sum   = v-tax-sum + v-tax
        .

        run writelog in this-procedure (log-file-name, 5, "R-AKT.i   Товар с третьим налогом ( "
                                                    + dtm-char(v-taxname) + " ), определили значение ( " + dtm-char(string(v-tax))
                                                    + " ) и сумму всего ( " + dtm-char(string(v-tax-sum)) + " )"
                                            ).
        &if "{2}" = "fact" &then
            for each parts
            where parts.obj-type     = price-list.obj-type
                and parts.obj-code     = price-list.obj-code
                and parts.artic        = price-list.artic
                and parts.prod-type    = price-list.prod-type
                and parts.prod-code    = price-list.prod-code
                and parts.out-code     = price-list.doc-num
            break by parts.road-tax-rubl
            :
                if first-of( parts.road-tax-rubl )
                then do:
                    assign
                        v-tax-parts-qnty  = 0
                    .
                end.
                assign
                    v-tax-parts-qnty    = v-tax-parts-qnty  + parts.fact-qnty
                .
                if last-of( parts.road-tax-rubl )
                then do:
                    display stream AktStr
                        "     В том числе"                                  @ price-list.artic
                        v-taxname                                           @ goods.gds-name
                        v-tax-parts-qnty   when v-tax-parts-qnty <> ?       @ price-list.doc-qnty
                        parts.road-tax-rubl                                 @ price-list.price-sale
                        v-tax-parts-qnty * parts.road-tax-rubl              @ v-new-sum
                        sym1
                        sym7
                    with frame &if "{3}" = "cost" &then Akt-Cost &else Akt &endif
                    .
                    down stream AktStr 1
                    with frame &if "{3}" = "cost" &then Akt-Cost &else Akt &endif .
                    assign
                        v-line-counter = v-line-counter + 1
                    .
                end.
            end.
        &else
            display stream AktStr
                "     В том числе"                                  @ price-list.artic
                v-taxname                                           @ goods.gds-name
                price-list.doc-qnty  when price-list.doc-qnty <> ?
                price-list.road-tax                                 @ price-list.price-sale
                sym1
                sym7
            with frame &if "{3}" = "cost" &then Prik-Cost &else Prik &endif
            .

            down stream AktStr 1
            with frame &if "{3}" = "cost" &then Prik-Cost &else Prik &endif .
            assign
                v-line-counter = v-line-counter + 1
            .
        &endif
    end.

&endif

/* $Workfile$ e n d */