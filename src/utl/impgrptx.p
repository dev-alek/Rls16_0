block-level on error undo, throw.
/*

$Revision: 8d6ad4ee6014, 1102, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: impgrptx.p $
$Archive: utl/impgrptx.p $

Создание или изменение группы товара.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-mode           as character    no-undo . /*{&add-def} или {&update}*/
define input parameter p-node-code      as integer      no-undo .
define input parameter p-upper-code     as integer      no-undo .
define input parameter p-node-name      as character    no-undo .
define input parameter p-host-code      as integer      no-undo .
define input parameter p-obj-type       as character    no-undo .
define input parameter p-obj-code       as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8d6ad4ee6014, 1102, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impgrptx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impgrptx.p $":U .
define variable vss-description as character no-undo init "Создание или изменение группы товара.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/tt-tax.i "new shared" tt-tax full }

define new shared buffer goods for ub.goods.

    define variable v-node-code         as integer      no-undo.
    define variable v-upper-code        as integer      no-undo.
    define variable v-gds-grp-recid     as recid        no-undo.
do
on error undo, return error
:
            assign
                v-node-code  = p-node-code
                v-upper-code = p-upper-code
            .
            run ref/gdsgrp01.p (
                  input p-mode
                , input no
                , input (if p-mode = {&add-def} then yes else no) /*p-get-node-code*/
                , input no /*p-fill-tax-from-upper*/
                , input-output v-node-code
                , input-output v-upper-code
                , input p-node-name
                , input entry( 9, {&pr-calc-methods-grp-list} )
                , input 0
                , input ""
                , input entry( 5, {&pr-rounds} )
                , input 0
                , output v-gds-grp-recid
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания или изменения группы товаров."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            if p-mode = {&add-def}
            then do:
                run ref/dtaxgrps.p (
                      input 0               /* Налоги заполнятся из вышестоящей группы */
                    , input p-upper-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка заполнения таблицы налогов для групп товаров."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
/*                find first tt-tax*/
/*                     where tt-tax.tax-code = integer( {&vat-tax-code} )*/
/*                no-error.*/
/*                if available tt-tax*/
/*                then do:*/
/*                    assign*/
/*                        tt-tax.rate-code = p-vat-rate-code*/
/*                    .*/
/*                end.*/
/*                find first tt-tax*/
/*                     where tt-tax.tax-code = integer( {&slt-tax-code} )*/
/*                no-error.*/
/*                if available tt-tax*/
/*                then do:*/
/*                    assign*/
/*                        tt-tax.rate-code = p-slt-rate-code*/
/*                    .*/
/*                end.*/
            end.
            else do:
                for each tt-tax:
                    delete tt-tax.
                end.
            end.
            run ref/dtaxgrpu.p (
                  input p-node-code
                , input p-upper-code
                , input yes
                , input p-host-code
                , input p-obj-type
                , input p-obj-code
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка привязки налогов к группе товаров."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
end.