/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕроцедуры расчета данных дл€ печатных форм производства.

јвтор: ƒемин јлексей —ергеевич
ƒата создани€: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_fbrrep-goods no-undo
    field gds-code                      as integer
    field artic                         as character
    field prod-type                     as character
    field prod-code                     as integer
    field gds-name                      as character
    field is-not-office                 as logical
    field is-waste                      as logical
    field unit-base                     as character
    field fact-qnty                     as decimal
    field write-off-qnty                as decimal
    field write-off-rsrv-qnty           as decimal
    field sum-write-off-rsrv-rubl       as decimal
    field sum-write-off-rsrv-base       as decimal
    field sum-write-off-rsrv-vat-rubl   as decimal
    field sum-write-off-rsrv-vat-base   as decimal
    field cost-rubl                     as decimal
    field cost-base                     as decimal
    field sum-cost-rubl                 as decimal
    field sum-cost-base                 as decimal
    field sum-vat-cost-rubl             as decimal
    field sum-vat-cost-base             as decimal
    field vat-cost-rubl                 as decimal
    field vat-cost-base                 as decimal
    field income-qnty                   as decimal
    field income-rsrv-qnty              as decimal
    field cost-income-rubl              as decimal
    field cost-income-base              as decimal
    field sum-cost-income-rubl          as decimal
    field sum-cost-income-base          as decimal
    field sum-vat-cost-income-rubl      as decimal
    field sum-vat-cost-income-base      as decimal
    field vat-cost-income-rubl          as decimal
    field vat-cost-income-base          as decimal
    field price-sale                    as decimal
    field deleted                       as logical

    index pi is primary unique gds-code
    index ar is unique artic prod-type prod-code
    index dd deleted
    index ws is-waste
.
{ rep/r-cost.i }

/*==========================================================================*/
procedure fbrrep-fill-qnty-and-prices :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code  as character    no-undo.

    define variable v-gds-code  as integer       no-undo.
    define variable v-gds-name  as character     no-undo.
    define variable v-sign      as decimal       no-undo.

    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.

    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first buf_temp_fbrrep-goods
             where buf_temp_fbrrep-goods.artic     = buf_fbr-line.artic
               and buf_temp_fbrrep-goods.prod-type = buf_fbr-line.prod-type
               and buf_temp_fbrrep-goods.prod-code = buf_fbr-line.prod-code
        use-index ar
        no-error.
        if not available buf_temp_fbrrep-goods
        then do:
            create buf_temp_fbrrep-goods.
            { gbl/gds-code.i
                buf_fbr-line.artic
                buf_fbr-line.prod-type
                buf_fbr-line.prod-code
                v-gds-code
            }
            { gbl/gds-arnm.i
                buf_fbr-line.artic
                buf_fbr-line.prod-type
                buf_fbr-line.prod-code
                v-gds-name
            }
            { gbl/gdsat.i
                buf_fbr-line.artic
                buf_fbr-line.prod-type
                buf_fbr-line.prod-code
                'gds-goods=request':u
                buf_temp_fbrrep-goods.is-not-office
            }
            assign
                buf_temp_fbrrep-goods.gds-code             = v-gds-code
                buf_temp_fbrrep-goods.artic                = buf_fbr-line.artic
                buf_temp_fbrrep-goods.prod-type            = buf_fbr-line.prod-type
                buf_temp_fbrrep-goods.prod-code            = buf_fbr-line.prod-code
                buf_temp_fbrrep-goods.gds-name             = v-gds-name
                buf_temp_fbrrep-goods.is-waste             = buf_fbr-line.is-waste
                buf_temp_fbrrep-goods.fact-qnty            = 0
                buf_temp_fbrrep-goods.write-off-rsrv-qnty  = 0
                buf_temp_fbrrep-goods.write-off-qnty       = 0
                buf_temp_fbrrep-goods.income-qnty          = 0
                buf_temp_fbrrep-goods.income-rsrv-qnty     = 0
                buf_temp_fbrrep-goods.cost-rubl            = 0
                buf_temp_fbrrep-goods.cost-base            = 0
                buf_temp_fbrrep-goods.sum-cost-rubl        = 0
                buf_temp_fbrrep-goods.sum-cost-base        = 0
                buf_temp_fbrrep-goods.vat-cost-rubl        = 0
                buf_temp_fbrrep-goods.vat-cost-base        = 0
                buf_temp_fbrrep-goods.sum-vat-cost-rubl    = 0
                buf_temp_fbrrep-goods.sum-vat-cost-base    = 0
                buf_temp_fbrrep-goods.price-sale           = buf_fbr-line.price-sale   /* ÷ены дл€ одного товара должны быть равны */
                buf_temp_fbrrep-goods.deleted              = no
            .
            { gbl/unitbase.i
                v-gds-code
                buf_temp_fbrrep-goods.unit-base
            }
        end.        /* if not available buf_temp_fbrrep-goods */
        case buf_fbr-line.trn-type
        :
            when {&income}
            then do:
                assign
                    v-sign                                  = 1
                    buf_temp_fbrrep-goods.income-qnty       = buf_temp_fbrrep-goods.income-qnty     + buf_fbr-line.fact-qnty
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.income-rsrv-qnty = buf_temp_fbrrep-goods.income-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
            when {&write-off}
            then do:
                assign
                    v-sign                                  = -1
                    buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty  + buf_fbr-line.fact-qnty
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.write-off-rsrv-qnty = buf_temp_fbrrep-goods.write-off-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
        end case.       /* buf_fbr-line.trn-type */
        assign
            buf_temp_fbrrep-goods.sum-cost-rubl        = buf_temp_fbrrep-goods.sum-cost-rubl     + v-sign * buf_fbr-line.price-sum-rubl
            buf_temp_fbrrep-goods.sum-cost-base        = buf_temp_fbrrep-goods.sum-cost-base     + v-sign * buf_fbr-line.price-sum-base
            buf_temp_fbrrep-goods.sum-vat-cost-rubl    = buf_temp_fbrrep-goods.sum-vat-cost-rubl + v-sign * buf_fbr-line.price-sum-vat-rubl
            buf_temp_fbrrep-goods.sum-vat-cost-base    = buf_temp_fbrrep-goods.sum-vat-cost-base + v-sign * buf_fbr-line.price-sum-vat-base
        .
    end.        /* for each buf_fbr-line */
    run test-temp-tables in this-procedure .
end.
end procedure. /* fbrrep-fill-qnty-and-prices */

/*==========================================================================*/
/* ¬ременна€ таблица заполн€етс€ товарами, которые производ€тс€ и списываютс€_
    только внутри документа производства. “о есть, это количества, которых нет
    в обороте по складским документам.
*/
procedure fbrrep-fill-for-fbr-actp :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code  as character    no-undo.

    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.
    define buffer buf_fbr-line          for ub.fbr-line.


    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-doc-code
    ).
    for each buf_temp_fbrrep-goods
    :
        assign
            buf_temp_fbrrep-goods.sum-cost-rubl     = 0
            buf_temp_fbrrep-goods.sum-cost-base     = 0
            buf_temp_fbrrep-goods.sum-vat-cost-rubl = 0
            buf_temp_fbrrep-goods.sum-vat-cost-base = 0
            buf_temp_fbrrep-goods.cost-rubl     = 0
            buf_temp_fbrrep-goods.cost-base     = 0
            buf_temp_fbrrep-goods.vat-cost-rubl = 0
            buf_temp_fbrrep-goods.vat-cost-base = 0
        .
        if buf_temp_fbrrep-goods.income-qnty = 0
        or buf_temp_fbrrep-goods.write-off-qnty = 0
        then do:        /* ƒвижение товара полностью отражено на складе */
            assign
                buf_temp_fbrrep-goods.deleted   = yes
                buf_temp_fbrrep-goods.fact-qnty = 0
            .
        end.
        else do:
            if buf_temp_fbrrep-goods.income-qnty <= buf_temp_fbrrep-goods.write-off-qnty
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty
                .
                for each buf_fbr-line no-lock
                   where buf_fbr-line.doc-code  = p-fbr-doc-doc-code
                     and buf_fbr-line.artic     = buf_temp_fbrrep-goods.artic
                     and buf_fbr-line.prod-type = buf_temp_fbrrep-goods.prod-type
                     and buf_fbr-line.prod-code = buf_temp_fbrrep-goods.prod-code
                     and buf_fbr-line.trn-type  = {&income}
                :
                    assign
                        buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     + buf_fbr-line.price-sum-rubl
                        buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base     + buf_fbr-line.price-sum-base
                        buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl + buf_fbr-line.price-sum-vat-rubl
                        buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base + buf_fbr-line.price-sum-vat-base
                    .
                end.
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / buf_temp_fbrrep-goods.fact-qnty
                .
            end.        /* if buf_temp_fbrrep-goods.income-qnty <= buf_temp_fbrrep-goods.write-off-qnty */
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty
                .
                for each buf_fbr-line no-lock
                   where buf_fbr-line.doc-code  = p-fbr-doc-doc-code
                     and buf_fbr-line.artic     = buf_temp_fbrrep-goods.artic
                     and buf_fbr-line.prod-type = buf_temp_fbrrep-goods.prod-type
                     and buf_fbr-line.prod-code = buf_temp_fbrrep-goods.prod-code
                     and buf_fbr-line.trn-type  = {&write-off}
                :
                    assign
                        buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     + buf_fbr-line.price-sum-rubl
                        buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base     + buf_fbr-line.price-sum-base
                        buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl + buf_fbr-line.price-sum-vat-rubl
                        buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base + buf_fbr-line.price-sum-vat-base
                    .
                end.
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / buf_temp_fbrrep-goods.fact-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / buf_temp_fbrrep-goods.fact-qnty
                .
            end.        /* if NOT( buf_temp_fbrrep-goods.income-qnty <= buf_temp_fbrrep-goods.write-off-qnty ) */
        end.
    end.        /* for each buf_temp_fbrrep-goods. */
    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.        /* for each buf_temp_fbrrep-goods */
    run test-temp-tables in this-procedure .
end.
end procedure. /* fbrrep-fill-for-fbr-actp */

/*==========================================================================*/
/* ¬ременна€ таблица заполн€етс€ товарами, которые попали в складские документы,
    но с другими суммами по продажным или учетным ценам. fbr-fact и суммы
    заполн€ютс€ разност€ми между документом производства и складскими документами.
    income-qnty и write-off-qnty - это количества по документу производства,
    цены - берутс€ из документа производства.
*/
procedure fbrrep-fill-for-op-del :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-db-remote          as logical          no-undo.

    define variable v-serv-code as character    no-undo.
    define variable v-in-code   as character    no-undo.
    define variable v-out-code  as character    no-undo.
    define variable v-trn-qnty  as decimal       no-undo.
    define variable v-sign      as decimal       no-undo.
    define variable v-qnty      as decimal       no-undo.

    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_goods             for ub.goods .
    define buffer buf_doc-line          for ub.doc-line .
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods .

    run fbrrep-fill-qnty-and-prices in this-procedure (
        input p-fbr-doc-doc-code
    ).
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
        if buf_temp_fbrrep-goods.income-qnty <> 0
        or buf_temp_fbrrep-goods.write-off-qnty <> 0
        then do:
            assign
                v-qnty  = ( buf_temp_fbrrep-goods.write-off-qnty - buf_temp_fbrrep-goods.income-qnty )
            .
            if v-qnty = 0
            then do:
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                       and buf_fbr-line.artic       = buf_temp_fbrrep-goods.artic
                       and buf_fbr-line.prod-type   = buf_temp_fbrrep-goods.prod-type
                       and buf_fbr-line.prod-code   = buf_temp_fbrrep-goods.prod-code
                       and buf_fbr-line.fact-qnty   <> 0
                no-error.
                if available buf_fbr-line
                then do:
                    assign
                        buf_temp_fbrrep-goods.cost-rubl     = buf_fbr-line.price-rubl
                        buf_temp_fbrrep-goods.cost-base     = buf_fbr-line.price-base
                        buf_temp_fbrrep-goods.vat-cost-rubl = buf_fbr-line.price-sum-vat-rubl / buf_fbr-line.fact-qnty
                        buf_temp_fbrrep-goods.vat-cost-base = buf_fbr-line.price-sum-vat-base / buf_fbr-line.fact-qnty
                    .
                end.        /* available buf_fbr-line */
                else do:
                    assign
                        buf_temp_fbrrep-goods.cost-rubl     = 0
                        buf_temp_fbrrep-goods.cost-base     = 0
                        buf_temp_fbrrep-goods.vat-cost-rubl = 0
                        buf_temp_fbrrep-goods.vat-cost-base = 0
                    .
                end.        /* NOT ( available buf_fbr-line ) */
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl     / v-qnty
                    buf_temp_fbrrep-goods.cost-base     = buf_temp_fbrrep-goods.sum-cost-base     / v-qnty
                    buf_temp_fbrrep-goods.vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl / v-qnty
                    buf_temp_fbrrep-goods.vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base / v-qnty
                .
            end.
        end.
        else do:
            assign
                buf_temp_fbrrep-goods.cost-rubl     = 0
                buf_temp_fbrrep-goods.cost-base     = 0
                buf_temp_fbrrep-goods.vat-cost-rubl = 0
                buf_temp_fbrrep-goods.vat-cost-base = 0
            .
        end.        /* buf_temp_fbrrep-goods.income-qnty = 0 and buf_temp_fbrrep-goods.write-off-qnty = 0 */
    end.        /* for each buf_temp_fbrrep-goods. */
    for each buf_temp_fbrrep-goods
    :
        if buf_temp_fbrrep-goods.is-waste = yes
        then do:
            assign
                buf_temp_fbrrep-goods.deleted = yes
            .
        end.        /* buf_temp_fbrrep-goods.is-waste = yes  */
        else do:
            if buf_temp_fbrrep-goods.write-off-qnty <> 0
            and buf_temp_fbrrep-goods.income-qnty <> 0
            then do:
                if buf_temp_fbrrep-goods.write-off-qnty = buf_temp_fbrrep-goods.income-qnty
                then do:
                    assign
                        buf_temp_fbrrep-goods.deleted = yes
                    .
                end.        /* buf_temp_fbrrep-goods.write-off-qnty = buf_temp_fbrrep-goods.write-off-qnty  */
                else do:
                    if buf_temp_fbrrep-goods.write-off-qnty > buf_temp_fbrrep-goods.income-qnty
                    then do:
                        assign
                            buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty - buf_temp_fbrrep-goods.income-qnty
                            buf_temp_fbrrep-goods.income-qnty       = 0
                        .
                    end.        /* buf_temp_fbrrep-goods.write-off-qnty > buf_temp_fbrrep-goods.write-off-qnty */
                    else do:
                        assign
                            buf_temp_fbrrep-goods.income-qnty       = buf_temp_fbrrep-goods.income-qnty - buf_temp_fbrrep-goods.write-off-qnty
                            buf_temp_fbrrep-goods.write-off-qnty    = 0
                        .
                    end.        /* NOT ( buf_temp_fbrrep-goods.write-off-qnty > buf_temp_fbrrep-goods.write-off-qnty ) */
                end.        /* NOT ( buf_temp_fbrrep-goods.write-off-qnty = buf_temp_fbrrep-goods.write-off-qnty  ) */
            end.
        end.        /* NOT ( buf_temp_fbrrep-goods.is-waste = yes  ) */
    end.        /* for each buf_temp_fbrrep-goods. */


    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.        /* for each buf_temp_fbrrep-goods */

    run test-temp-tables in this-procedure .

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    assign
        v-out-code = p-fbr-doc-doc-code
    .
    run doc-code in this-procedure (
          input  "pair"
        , input  buf_fbr-doc.obj-type
        , input  buf_fbr-doc.obj-code
        , input  v-out-code
        , output v-in-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "ќшибка вычислени€ номера приходной накладной."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run doc-code in this-procedure (
          input  "trio"
        , input  buf_fbr-doc.obj-type
        , input  buf_fbr-doc.obj-code
        , input  v-in-code
        , output v-serv-code
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "ќшибка вычислени€ номера накладной расхода."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_fbrrep-goods
    on error undo, return error
    :
        if buf_temp_fbrrep-goods.income-qnty > buf_temp_fbrrep-goods.write-off-qnty
        then do:        /* должен быть приход */
            find first buf_doc-line no-lock
                 where buf_doc-line.doc-code  = v-in-code
                   and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                   and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                   and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
            no-error.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty - buf_doc-line.doc-qnty
                .
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.income-qnty
                .
            end.
        end.
        else do:        /* ищем расход */
            if buf_temp_fbrrep-goods.is-not-office = no
            then do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = v-serv-code
                       and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                       and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
                no-error.
            end.
            else do:
                find first buf_doc-line no-lock
                     where buf_doc-line.doc-code  = v-out-code
                       and buf_doc-line.artic     = buf_temp_fbrrep-goods.artic
                       and buf_doc-line.prod-type = buf_temp_fbrrep-goods.prod-type
                       and buf_doc-line.prod-code = buf_temp_fbrrep-goods.prod-code
                no-error.
            end.
            if available buf_doc-line
            then do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty - buf_doc-line.doc-qnty
                .
            end.
            else do:
                assign
                    buf_temp_fbrrep-goods.fact-qnty = buf_temp_fbrrep-goods.write-off-qnty
                .
            end.
        end.
        if available buf_doc-line
        then do:
            define variable v-void              as decimal       no-undo.
            define variable v-fact-qnty         as decimal       no-undo.
            define variable v-sum-base          as decimal       no-undo.
            define variable v-sum-rubl          as decimal       no-undo.
            define variable v-vat-base          as decimal       no-undo.
            define variable v-vat-rubl          as decimal       no-undo.
            define variable v-slt-base          as decimal       no-undo.
            define variable v-slt-rubl          as decimal       no-undo.
            define variable v-road-tax-base     as decimal       no-undo.
            define variable v-road-tax-rubl     as decimal       no-undo.
            define variable v-transport-base    as decimal       no-undo.
            define variable v-transport-rubl    as decimal       no-undo.
            define variable v-other-base        as decimal       no-undo.
            define variable v-other-rubl        as decimal       no-undo.
            define variable v-excise-base       as decimal       no-undo.
            define variable v-excise-rubl       as decimal       no-undo.

            run r-cost in this-procedure (
                  input buf_doc-line.doc-code
                , input buf_doc-line.artic
                , input buf_doc-line.prod-type
                , input buf_doc-line.prod-code
                , output v-fact-qnty            /* v-fact-qnty          */
                , output v-void                 /* v-vat-pc             */
                , output v-void                 /* v-slt-pc             */
                , output v-sum-base             /* v-sum-base           */
                , output v-sum-rubl             /* v-sum-rubl           */
                , output v-vat-base             /* v-vat-base           */
                , output v-vat-rubl             /* v-vat-rubl           */
                , output v-slt-base             /* v-slt-base           */
                , output v-slt-rubl             /* v-slt-rubl           */
                , output v-road-tax-base        /* v-road-tax-base      */
                , output v-road-tax-rubl        /* v-road-tax-rubl      */
                , output v-transport-base       /* v-transport-base     */
                , output v-transport-rubl       /* v-transport-rubl     */
                , output v-other-base           /* v-other-base         */
                , output v-other-rubl           /* v-other-rubl         */
                , output v-excise-base          /* v-excise-base        */
                , output v-excise-rubl          /* v-excise-rubl        */
            ).
            assign
                v-sign = ( if v-fact-qnty >= 0 then 1 else -1 )
            .
            assign
                v-sum-rubl = v-sum-rubl - v-vat-rubl - v-slt-rubl - v-road-tax-rubl - v-transport-rubl - v-other-rubl - v-excise-rubl
                v-sum-base = v-sum-base - v-vat-base - v-slt-base - v-road-tax-base - v-transport-base - v-other-base - v-excise-base
                v-sum-rubl = v-sum-rubl   * v-sign
                v-sum-base = v-sum-base   * v-sign
                v-vat-rubl = v-vat-rubl   * v-sign
                v-vat-base = v-vat-base   * v-sign
                v-fact-qnty = v-fact-qnty * v-sign
            .
            output to "fbrrep.txt" append .
            put unformatted skip(1) v-fact-qnty "   " v-sum-rubl "    " v-vat-rubl.
            output close.
            assign
                buf_temp_fbrrep-goods.sum-cost-rubl     = absolute( buf_temp_fbrrep-goods.cost-rubl     * v-fact-qnty ) - absolute( v-sum-rubl )
                buf_temp_fbrrep-goods.sum-cost-base     = absolute( buf_temp_fbrrep-goods.cost-base     * v-fact-qnty ) - absolute( v-sum-base )
                buf_temp_fbrrep-goods.sum-vat-cost-rubl = absolute( buf_temp_fbrrep-goods.vat-cost-rubl * v-fact-qnty ) - absolute( v-vat-rubl )
                buf_temp_fbrrep-goods.sum-vat-cost-base = absolute( buf_temp_fbrrep-goods.vat-cost-base * v-fact-qnty ) - absolute( v-vat-base )
            .
            if buf_temp_fbrrep-goods.fact-qnty          = 0
            and buf_temp_fbrrep-goods.sum-cost-rubl     = 0
            and buf_temp_fbrrep-goods.sum-cost-base     = 0
            and buf_temp_fbrrep-goods.sum-vat-cost-rubl = 0
            and buf_temp_fbrrep-goods.sum-vat-cost-base = 0
            then do:
                assign
                    buf_temp_fbrrep-goods.deleted = yes
                .
            end.
        end.        /* if available buf_doc-line */
    end.        /* for each buf_temp_fbrrep-goods */
    for each buf_temp_fbrrep-goods
       where buf_temp_fbrrep-goods.deleted = yes
    on error undo, return error
    :
        delete buf_temp_fbrrep-goods.
    end.        /* for each buf_temp_fbrrep-goods */

    run test-temp-tables in this-procedure .

end.
end procedure. /* fbrrep-fill-for-op-del */

/*==========================================================================*/
procedure test-temp-tables :
do
on error undo, return error
:
    define variable v-str   as character     no-undo.
    assign
        v-str = ""
    .
    for each temp_fbrrep-goods
    :
        assign
            v-str = v-str
                + {&new-line} + temp_fbrrep-goods.artic
                + {&tabulation} + string( temp_fbrrep-goods.income-qnty )
                + {&tabulation} + string( temp_fbrrep-goods.write-off-qnty )
                + {&tabulation} + string( temp_fbrrep-goods.cost-rubl )
                + {&tabulation} + string( temp_fbrrep-goods.vat-cost-rubl )
                + {&tabulation} + string( temp_fbrrep-goods.sum-cost-rubl )
                + {&tabulation} + string( temp_fbrrep-goods.sum-vat-cost-rubl )
                + {&tabulation} + string( temp_fbrrep-goods.gds-name )
        .
    end.        /* for each temp_fbrrep-goods */
    output to "fbrrep.txt" append .
    put unformatted skip(2) v-str.
    output close.
end.
end procedure. /* test-temp-tables */

/*==========================================================================*/
/*
“естирование документа производства дл€ закрыти€ на факт.
Input:
    p-fbr-doc-doc-code - номер документа
    p-append-error     - не очищать temp-table ошибок
Output:
    p-bad-recipe - ошибки найдены.
    ѕри ошибках заполн€етс€ temp-table temp_fbrtest_recipe.
*/
procedure fbrrep-test-fbrdoc-for-fact :
do
on error undo, return error
:
define output parameter p-have-error        as logical      no-undo.

    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.

    for each buf_temp_fbrrep-goods
    on error undo, return error
    :

    end.        /* for each buf_temp_fbrrep-goods */

end.
end procedure. /* fbrtest-fbrdoc-for-fact */

/*==========================================================================*/
procedure fbrrep-fill-qnty-and-prices-gds :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.

    define variable v-sign      as decimal       no-undo.

    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_goods             for ub.goods.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.artic     = buf_goods.artic
           and buf_temp_fbrrep-goods.prod-type = buf_goods.prod-type
           and buf_temp_fbrrep-goods.prod-code = buf_goods.prod-code
    use-index ar
    no-error.
    if available buf_temp_fbrrep-goods
    then do:
        delete buf_temp_fbrrep-goods.
    end.
    create buf_temp_fbrrep-goods.
    { gbl/gdsat.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        'gds-goods=request':u
        buf_temp_fbrrep-goods.is-not-office
    }
    assign
        buf_temp_fbrrep-goods.gds-code             = p-gds-code
        buf_temp_fbrrep-goods.artic                = buf_goods.artic
        buf_temp_fbrrep-goods.prod-type            = buf_goods.prod-type
        buf_temp_fbrrep-goods.prod-code            = buf_goods.prod-code
        buf_temp_fbrrep-goods.gds-name             = buf_goods.gds-name
        buf_temp_fbrrep-goods.is-waste             = no
        buf_temp_fbrrep-goods.fact-qnty            = 0
        buf_temp_fbrrep-goods.write-off-rsrv-qnty  = 0
        buf_temp_fbrrep-goods.write-off-qnty       = 0
        buf_temp_fbrrep-goods.income-qnty          = 0
        buf_temp_fbrrep-goods.income-rsrv-qnty     = 0
        buf_temp_fbrrep-goods.cost-rubl            = 0
        buf_temp_fbrrep-goods.cost-base            = 0
        buf_temp_fbrrep-goods.sum-cost-rubl        = 0
        buf_temp_fbrrep-goods.sum-cost-base        = 0
        buf_temp_fbrrep-goods.vat-cost-rubl        = 0
        buf_temp_fbrrep-goods.vat-cost-base        = 0
        buf_temp_fbrrep-goods.sum-vat-cost-rubl    = 0
        buf_temp_fbrrep-goods.sum-vat-cost-base    = 0
        buf_temp_fbrrep-goods.price-sale           = 0
        buf_temp_fbrrep-goods.deleted              = no
    .
    { gbl/unitbase.i
        p-gds-code
        buf_temp_fbrrep-goods.unit-base
    }
    for each buf_fbr-line no-lock
       where buf_fbr-line.prod-type = buf_goods.prod-type
         and buf_fbr-line.prod-code = buf_goods.prod-code
         and buf_fbr-line.artic     = buf_goods.artic
         and buf_fbr-line.doc-code  = p-fbr-doc-doc-code
    on error undo, return error
    :
        case buf_fbr-line.trn-type
        :
            when {&income}
            then do:
                assign
                    v-sign                                          = 1
                    buf_temp_fbrrep-goods.income-qnty               = buf_temp_fbrrep-goods.income-qnty                 + buf_fbr-line.fact-qnty
                    buf_temp_fbrrep-goods.sum-cost-income-rubl      = buf_temp_fbrrep-goods.sum-cost-income-rubl        + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                    buf_temp_fbrrep-goods.sum-cost-income-base      = buf_temp_fbrrep-goods.sum-cost-income-base        + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-income-rubl  = buf_temp_fbrrep-goods.sum-vat-cost-income-rubl    + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-income-base  = buf_temp_fbrrep-goods.sum-vat-cost-income-base    + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.income-rsrv-qnty = buf_temp_fbrrep-goods.income-rsrv-qnty   + buf_fbr-line.rsrv-qnty
                    .
                end.
            end.
            when {&write-off}
            then do:
                assign
                    v-sign                                  = -1
                    buf_temp_fbrrep-goods.write-off-qnty    = buf_temp_fbrrep-goods.write-off-qnty      + buf_fbr-line.fact-qnty
                    buf_temp_fbrrep-goods.sum-cost-rubl     = buf_temp_fbrrep-goods.sum-cost-rubl       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                    buf_temp_fbrrep-goods.sum-cost-base     = buf_temp_fbrrep-goods.sum-cost-base       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-rubl = buf_temp_fbrrep-goods.sum-vat-cost-rubl   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                    buf_temp_fbrrep-goods.sum-vat-cost-base = buf_temp_fbrrep-goods.sum-vat-cost-base   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                .
                if buf_fbr-line.rsrv-qnty <> ?
                then do:
                    assign
                        buf_temp_fbrrep-goods.write-off-rsrv-qnty           = buf_temp_fbrrep-goods.write-off-rsrv-qnty           + buf_fbr-line.rsrv-qnty
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl       = buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-rubl        else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-base       = buf_temp_fbrrep-goods.sum-write-off-rsrv-base       + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-base        else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl   = buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-rubl    else 0 )
                        buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base   = buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base   + ( if buf_fbr-line.price-sum-rubl <> ? then buf_fbr-line.price-sum-vat-base    else 0 )
                    .
                end.
            end.
        end case.       /* buf_fbr-line.trn-type */
        assign
            buf_temp_fbrrep-goods.is-waste             = buf_fbr-line.is-waste
            buf_temp_fbrrep-goods.price-sale           = buf_fbr-line.price-sale
            buf_temp_fbrrep-goods.cost-income-rubl     = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-income-rubl      / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.cost-income-base     = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-income-base      / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.vat-cost-income-rubl = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-income-rubl  / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.vat-cost-income-base = ( if buf_temp_fbrrep-goods.income-qnty     = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-income-base  / buf_temp_fbrrep-goods.income-qnty    )
            buf_temp_fbrrep-goods.cost-rubl            = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-rubl             / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.cost-base            = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-cost-base             / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.vat-cost-rubl        = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-rubl         / buf_temp_fbrrep-goods.write-off-qnty )
            buf_temp_fbrrep-goods.vat-cost-base        = ( if buf_temp_fbrrep-goods.write-off-qnty  = 0 then 0 else buf_temp_fbrrep-goods.sum-vat-cost-base         / buf_temp_fbrrep-goods.write-off-qnty )
        .
    end.        /* for each buf_fbr-line */
    run test-temp-tables in this-procedure .
end.
end procedure. /* fbrrep-fill-qnty-and-prices */


/* $Workfile$ e n d */