/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт переоценки ТАП-1-ДО (расчет)

Автор: Белоусов Илья Александрович
Дата создания: 01/14/09
Author: Ilia Belousov
Creation date: 01/14/09

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
    def var v-price-list-doc-num            like ub.price-list.doc-num     no-undo.
    def var v-price-list-price-sale         like ub.price-list.price-sale  no-undo.
    def var v-price-list-price-sale_old     like ub.price-list.price-sale  no-undo.
    def var v-price-list-road-tax           like ub.price-list.road-tax    no-undo.
    def var v-price-list-excise             like ub.price-list.excise      no-undo.

    def var v-price-list-b-code             like ub.bar-code.b-code        no-undo.

    def var v-gds-obj-last-price            like ub.gds-obj.last-rubl      no-undo.

    def var v-gds-prt-node-code             like ub.gds-prt.node-code      no-undo.
    def var v-gds-prt-node-name             like ub.gds-prt.node-name      no-undo.

    def var v-code-is-main                  as logical                  no-undo.

    def var v-not-main-unit-cli             like ub.bar-code.unit-cli      no-undo.
    def var v-not-main-cli-base-rate        like ub.bar-code.cli-base-rate no-undo.
    def var v-not-main-b-code               like ub.bar-code.cli-base-rate no-undo.

    def var v-taxname                       as char                     no-undo.
    def var v-tax                           as decimal  init 0          no-undo.
    def var v-tax-sum                       as decimal  init 0          no-undo.
    def var v-tax-parts-qnty                as decimal  init 0          no-undo.

&endif
&if "{1}" = "calc" &then
        /*---S----------- Имя товара с шкалой --------------------------------*/
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = buf_price-list.b-code
            .

            if buf_bar-code.unit-cli = buf_goods.unit-base
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
                    v-not-main-unit-cli       = buf_bar-code.unit-cli
                    v-not-main-cli-base-rate  = buf_bar-code.cli-base-rate
                    v-not-main-b-code         = buf_bar-code.b-code
                .
            end.

            find first buf_gds-prt no-lock
                 where buf_gds-prt.node-code = buf_bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if buf_gds-prt.upper-code = buf_goods.prt-root
                then if buf_bar-code.in-code = ''
                    then buf_goods.gds-name
                    else buf_bar-code.in-code + '    ' + buf_bar-code.part-code
                else
                    &if "{2}" = "not-main" &then
                        buf_goods.gds-name + "//" + buf_gds-prt.f-name
                    &else
                        '    ' + buf_gds-prt.f-name
                    &endif
              )
            .
        /*---E----------- Имя товара с шкалой --------------------------------*/
            find first buf_gds-obj no-lock
                 where buf_gds-obj.obj-type  = buf_price-list.obj-type
                   and buf_gds-obj.obj-code  = buf_price-list.obj-code
                   and buf_gds-obj.prod-type = buf_price-list.prod-type
                   and buf_gds-obj.prod-code = buf_price-list.prod-code
                   and buf_gds-obj.artic     = buf_price-list.artic
            no-error.
            if available buf_gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then buf_gds-obj.last-base else buf_gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
            end.

            find first buf_gds-prt no-lock
                 where buf_gds-prt.upper-code = buf_goods.prt-root
            .
            assign
                v-gds-prt-node-code = buf_gds-prt.node-code
            .

            { gbl/bcodeprc.i
                buf_price-list.obj-type
                buf_price-list.obj-code
                buf_price-list.b-code
                0
                buf_price-list.fact-order
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

            { gbl/gdsbcode.i
                buf_goods.gds-code
                buf_bar-code.node-code
                v-price-list-b-code
            }

            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = v-price-list-b-code
            .

            accumulate buf_bar-code.b-code ( count ) .

&endif

&if "{1}" = "third-tax" &then

    if hvrdtax (recid(buf_goods))
    then do:
        run tax-name (  input {&road-tax}
                      , output v-taxname
                     ).
        assign
            v-tax       = buf_price-list.road-tax * buf_price-list.doc-qnty
            v-tax-sum   = v-tax-sum + v-tax
        .

         for each buf_parts
         where buf_parts.obj-type         = buf_price-list.obj-type
               and buf_parts.obj-code     = buf_price-list.obj-code
               and buf_parts.artic        = buf_price-list.artic
               and buf_parts.prod-type    = buf_price-list.prod-type
               and buf_parts.prod-code    = buf_price-list.prod-code
               and buf_parts.out-code     = buf_price-list.doc-num
         break by buf_parts.road-tax-rubl
         :
               if first-of( buf_parts.road-tax-rubl )
               then do:
                  assign
                     v-tax-parts-qnty  = 0
                  .
               end.
               assign
                  v-tax-parts-qnty    = v-tax-parts-qnty  + buf_parts.fact-qnty
               .
               if last-of( buf_parts.road-tax-rubl )
               then do:
                  display stream outstream
                     "     В том числе"                                  @ buf_price-list.artic
                     v-taxname                                           @ buf_goods.gds-name
                     v-tax-parts-qnty          @ buf_price-list.doc-qnty
                     buf_goods.unit-base
                     buf_parts.road-tax-rubl                             @ buf_price-list.price-sale
                     v-tax-parts-qnty * buf_parts.road-tax-rubl              @ v-new-sum
                     sym1
                     sym2
                     sym3
                     sym4
                     sym5
                     sym6
                     sym7
                     sym8
                     sym9
                     sym10
                     sym11
                     sym12
                  with frame f-tap
                  .
                  down stream outstream 1
                  with frame f-tap  .
                  RUN tap1-sheet1-write-line-data IN THIS-PROCEDURE
                     ( INPUT "":U
                     , INPUT "В том числе"
                     , INPUT v-taxname
                     , INPUT "":U
                     , INPUT buf_goods.unit-base
                     , INPUT v-tax-parts-qnty
                     , INPUT "":U
                     , INPUT "":U
                     , INPUT buf_parts.road-tax-rubl
                     , INPUT ( v-tax-parts-qnty * buf_parts.road-tax-rubl )
                     , INPUT "":U
                     ) .

               end.
         end.
    end.

&endif

/* $Workfile$ e n d */