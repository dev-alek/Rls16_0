/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать счёт-фактуры. Библиотека.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 03/23/06
Author: Victor Guntner
Creation date: 03/23/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
    def var v-tax-name      as char                         no-undo.
    def var v-tax-price     as decimal      init 0          no-undo.
    def var v-tax           as decimal      init 0          no-undo.
    def var v-tot-tax       as decimal      init 0          no-undo.
&endif

&if "{1}" = "tax" &then
        if hvrdtax (recid(goods))
        then do:
                    /*---S--------- Третий налог выводится отдельной строкой ---------*/
                    run tax-name (  input {&road-tax}
                                , output v-tax-name
                                ).

/*                    display stream out-stream                                                       */
/*                        fill(" ", 19) + v-tax-name @ goods.gds-name                                 */
/*                        v-{2}qnty                                                   @ v-qnty        */
/*                        &if "{2}" = "prt-" &then                                                    */
/*                            ( if PrintRubl then parts.road-tax-rubl else parts.road-tax-base )      */
/*                        &else                                                                       */
/*                            v-tax-price                                                             */
/*                        &endif                                                                      */
/*                                                                                    @ v-price-no-VAT*/
/*                        &if "{2}" = "prt-" &then                                                    */
/*                            ( if PrintRubl then parts.road-tax-rubl * v-{2}qnty                     */
/*                                           else parts.road-tax-base * v-{2}qnty )                   */
/*                        &else                                                                       */
/*                            (if v-qnty <> 0 then v-tax * v-{2}qnty / v-qnty else 0 )                */
/*                        &endif                                                                      */
/*                                                                                    @ v-sum-no-VAT  */
/*                        "   ---" format "x(6)"                                      @ v-sum-actciz  */
/*                        0                                                           @ v-VAT         */
/*                        &if "{2}" = "prt-" &then                                                    */
/*                            ( if PrintRubl then parts.road-tax-rubl * v-{2}qnty                     */
/*                                           else parts.road-tax-base * v-{2}qnty )                   */
/*                        &else                                                                       */
/*                            (if v-qnty <> 0 then v-tax * v-{2}qnty / v-qnty else 0 )                */
/*                        &endif                                                                      */
/*                                                                                    @ v-sum         */
/*                        sym1 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym11 sym13                         */
/*                    with frame factur.                                                              */
/*                    down stream out-stream 1                                                        */
/*                    with frame factur.                                                              */
                run facturxl-write-line-data in this-procedure (
                      input fill(" ", 19) + v-tax-name          /*  p-Name     */
                    , input "  -  ":U                           /*  p-UAES     */
                    , input "":U                                /*  p-EI       */
                    , input string( v-{2}qnty )                 /*  p-qnty     */
                    , input &if "{2}" = "prt-" &then
                                ( if PrintRubl then parts.road-tax-rubl else parts.road-tax-base )
                            &else
                                v-tax-price
                            &endif
                    , input &if "{2}" = "prt-" &then
                            ( if PrintRubl then parts.road-tax-rubl * v-{2}qnty
                                           else parts.road-tax-base * v-{2}qnty )
                            &else
                                (if v-qnty <> 0 then v-tax * v-{2}qnty / v-qnty else 0 )
                            &endif
                    , input "   ---":U          /*  p-SumActciz*/
                    , input "":U                /*  p-VATpc    */
                    , input "0":U               /*  p-VATsum   */
                    , input &if "{2}" = "prt-" &then
                            ( if PrintRubl then parts.road-tax-rubl * v-{2}qnty
                                           else parts.road-tax-base * v-{2}qnty )
                              &else
                                  (if v-qnty <> 0 then v-tax * v-{2}qnty / v-qnty else 0 )
                              &endif
                    , input "":U                /*  p-country  */
                    , input "":U                /*  p-GTD      */
                ).
                    assign
                        v-lines-counter = v-lines-counter   + 1
                    .
                    /*---E--------- Третий налог выводится отдельной строкой ---------*/
        end.
        else do:
            if v-tax-price <> 0
            then do:
                message
                  "Значение третьего налога (стеклопосуда) в документе отлично от нуля для товара " + goods.artic
                  + ", хотя для этого товара система не позволяет задать третий налог. Возможны ошибки в накладной"
                view-as alert-box error.
            end.
        end.
&endif

/* $Workfile$ e n d */
