/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчёт сумм по товару в материальных ценностях

Автор: Белоусов Илья Александрович
Дата создания: 08/23/07
Author: Ilia Belousov
Creation date: 08/23/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_wthgds_price-group no-undo
    field gds-code      as integer
    field price-rubl    as decimal
    field vat-pc        as decimal
    field sum-rubl      as decimal
    field sum-base      as decimal
    field sum-vat-rubl  as decimal
    field sum-vat-base  as decimal
    field price-base    as decimal
    field qnty          as decimal
    field fact-qnty     as decimal

    index pi is primary unique
        gds-code
        price-rubl
        vat-pc
.
define temp-table temp_wthgds_price-goods   no-undo
    field gds-code      as integer
    field sum-rubl      as decimal
    field sum-base      as decimal
    field sum-vat-rubl  as decimal
    field sum-vat-base  as decimal
    field vat-pc        as decimal
    field qnty          as decimal
    field fact-qnty     as decimal
    field price-rubl    as decimal
    field price-base    as decimal

    index pi is primary unique
        gds-code
.
procedure wthgds-calc-price-group:
define input parameter p-doc-code as character no-undo.

    define variable v-gds-qnty          as decimal      no-undo.
    define variable v-gds-price-rubl    as decimal      no-undo.

    define buffer buf_wth-parts                 for ub.wth-parts.
    define buffer buf_wth-par                   for ub.wth-par.
    define buffer buf_temp_wthgds_price-group   for temp_wthgds_price-group.
do
for buf_wth-parts
  , buf_wth-par
  , buf_temp_wthgds_price-group
on error undo, return error
:
    empty temp-table temp_wthgds_price-group.

    for each buf_wth-parts no-lock
       where buf_wth-parts.out-code = p-doc-code
    :
        find first buf_wth-par no-lock
             where buf_wth-par.wth-code = buf_wth-parts.wth-code
               and buf_wth-par.par-code = buf_wth-parts.par-code
        .
        assign
            v-gds-qnty          = buf_wth-par.par-val * buf_wth-parts.fact-qnty
            v-gds-price-rubl    = round( ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl ) / v-gds-qnty, 2 )
        .
        find first buf_temp_wthgds_price-group no-lock
             where buf_temp_wthgds_price-group.gds-code     = buf_wth-parts.gds-code
               and buf_temp_wthgds_price-group.price-rubl   = v-gds-price-rubl
               and buf_temp_wthgds_price-group.vat-pc       = buf_wth-parts.vat-pc
        no-error.
        if not available buf_temp_wthgds_price-group
        then do:
            create buf_temp_wthgds_price-group.
            assign
                buf_temp_wthgds_price-group.gds-code        = buf_wth-parts.gds-code
                buf_temp_wthgds_price-group.price-rubl      = v-gds-price-rubl
                buf_temp_wthgds_price-group.vat-pc          = buf_wth-parts.vat-pc
                buf_temp_wthgds_price-group.price-base      = round( ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base ) / v-gds-qnty, 2 )
                buf_temp_wthgds_price-group.qnty            = 0.0
                buf_temp_wthgds_price-group.fact-qnty       = 0.0
                buf_temp_wthgds_price-group.sum-rubl        = 0.0
                buf_temp_wthgds_price-group.sum-base        = 0.0
                buf_temp_wthgds_price-group.sum-vat-rubl    = 0.0
                buf_temp_wthgds_price-group.sum-vat-base    = 0.0
            .
        end.
        assign
            buf_temp_wthgds_price-group.qnty            = buf_temp_wthgds_price-group.qnty          + v-gds-qnty
            buf_temp_wthgds_price-group.fact-qnty       = buf_temp_wthgds_price-group.fact-qnty     + buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-group.sum-rubl        = buf_temp_wthgds_price-group.sum-rubl      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl )
            buf_temp_wthgds_price-group.sum-base        = buf_temp_wthgds_price-group.sum-base      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base )
            buf_temp_wthgds_price-group.sum-vat-rubl    = buf_temp_wthgds_price-group.sum-vat-rubl  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-group.sum-vat-base    = buf_temp_wthgds_price-group.sum-vat-base  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base * buf_wth-parts.vat-pc / 100.0 )
        .
    end.
end.
end procedure.


procedure wthgds-calc-price-goods:
define input parameter p-doc-code as character no-undo.

    define variable v-gds-qnty          as decimal      no-undo.

    define buffer buf_wth-parts                 for ub.wth-parts.
    define buffer buf_wth-par                   for ub.wth-par.
    define buffer buf_temp_wthgds_price-goods   for temp_wthgds_price-goods.
do
for buf_wth-parts
  , buf_wth-par
  , buf_temp_wthgds_price-goods
on error undo, return error
:
    empty temp-table buf_temp_wthgds_price-goods.

    for each buf_wth-parts no-lock
       where buf_wth-parts.out-code = p-doc-code
    :
        find first buf_wth-par no-lock
             where buf_wth-par.wth-code = buf_wth-parts.wth-code
               and buf_wth-par.par-code = buf_wth-parts.par-code
        .
        find first buf_temp_wthgds_price-goods no-lock
             where buf_temp_wthgds_price-goods.gds-code     = buf_wth-parts.gds-code
        no-error.
        if not available buf_temp_wthgds_price-goods
        then do:
            create buf_temp_wthgds_price-goods.
            assign
                buf_temp_wthgds_price-goods.gds-code        = buf_wth-parts.gds-code
                buf_temp_wthgds_price-goods.qnty            = 0.0
                buf_temp_wthgds_price-goods.fact-qnty       = 0.0
                buf_temp_wthgds_price-goods.sum-rubl        = 0.0
                buf_temp_wthgds_price-goods.sum-base        = 0.0
                buf_temp_wthgds_price-goods.sum-vat-rubl    = 0.0
                buf_temp_wthgds_price-goods.sum-vat-base    = 0.0
            .
        end.
        assign
            v-gds-qnty                                  = buf_wth-par.par-val * buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-goods.qnty            = buf_temp_wthgds_price-goods.qnty          + v-gds-qnty
            buf_temp_wthgds_price-goods.fact-qnty       = buf_temp_wthgds_price-goods.fact-qnty     + buf_wth-parts.fact-qnty
            buf_temp_wthgds_price-goods.sum-rubl        = buf_temp_wthgds_price-goods.sum-rubl      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl )
            buf_temp_wthgds_price-goods.sum-base        = buf_temp_wthgds_price-goods.sum-base      + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base )
            buf_temp_wthgds_price-goods.sum-vat-rubl    = buf_temp_wthgds_price-goods.sum-vat-rubl  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-goods.sum-vat-base    = buf_temp_wthgds_price-goods.sum-vat-base  + ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base * buf_wth-parts.vat-pc / 100.0 )
            buf_temp_wthgds_price-goods.vat-pc          = buf_wth-parts.vat-pc
            buf_temp_wthgds_price-goods.price-rubl      = ( buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl ) / v-gds-qnty
            buf_temp_wthgds_price-goods.price-base      = ( buf_wth-parts.fact-qnty * buf_wth-parts.price-base ) / v-gds-qnty
        .
    end.
end.
end procedure.

/* $Workfile$ e n d */