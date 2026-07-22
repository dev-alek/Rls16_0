/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Все комбинации сумм с НДС и НП из линии документа

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

-no-taxes  означает без НДС и НП
Для продажных цен, sum-transport = 0 и sum-other = discnt (скидка)

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

def temp-table temp_r-getsum no-undo
    field row-number        as integer
    field qnty              like ub.doc-line.fact-qnty
    field vat-pc            like ub.doc-line.vat-pc
    field slt-pc            like ub.doc-line.slt-pc
    field sum-with-taxes    like ub.ot-line.sum-base
    field sum-vat           like ub.ot-line.vat-base
    field sum-slt           like ub.ot-line.slt-base
    field sum-road-tax      like ub.ot-line.road-tax-base
    field sum-transport     like ub.ot-line.transport-base
    field sum-other         like ub.ot-line.other-base
    field sum-excise        like ub.ot-line.excise-base
    field sum-no-taxes      like ub.ot-line.sum-base
    field sum-no-vat        like ub.ot-line.sum-base
    field sum-no-slt        like ub.ot-line.sum-base
    field price-no-taxes    like ub.doc-line.price-base
    field price-no-vat      like ub.doc-line.price-base
    field price-no-slt      like ub.doc-line.price-base
    index rn is primary unique row-number
.
{ rep/r-cost.i          }
{ rep/r-sale.i          }

/*==========================================================================*/
procedure r-getsum :
do
on error undo, return error
:
def input parameter p-doc-line-recid    as recid    no-undo.
def input parameter p-cost-prices       as logical  no-undo.
def input parameter p-rubl-prices       as logical  no-undo.

{ str/in-vatp.i def     }
{ str/out-vatp.i def    }

def buffer buf_doc-line     for ub.doc-line.
def buffer buf_trn-doc      for ub.trn-doc.

def var v-void-output-parameter         as decimal  no-undo.

find first buf_doc-line    where recid( buf_doc-line ) = p-doc-line-recid.
find first buf_trn-doc     where buf_trn-doc.doc-code  = buf_doc-line.doc-code.

find first temp_r-getsum
     where temp_r-getsum.row-number = 1
no-error.
if not available temp_r-getsum
then do:
    for each temp_r-getsum
    :
        delete temp_r-getsum.
    end.
    create temp_r-getsum.
    assign
        temp_r-getsum.row-number = 1
    .
end.

if p-cost-prices = yes
then do:
    if buf_doc-line.status_ = {&fact}
    then do:
        if p-rubl-prices = no
        then do:
            run r-cost in this-procedure ( input buf_doc-line.doc-code
                                         , input buf_doc-line.artic
                                         , input buf_doc-line.prod-type
                                         , input buf_doc-line.prod-code
                                         , output temp_r-getsum.qnty
                                         , output temp_r-getsum.vat-pc
                                         , output temp_r-getsum.slt-pc
                                         , output temp_r-getsum.sum-with-taxes
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-vat
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-slt
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-road-tax
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-transport
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-other
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-excise
                                         , output v-void-output-parameter
                                         ).
        end.        /* if p-rubl-prices = no */
        else do:
            run r-cost in this-procedure ( input buf_doc-line.doc-code
                                        , input buf_doc-line.artic
                                        , input buf_doc-line.prod-type
                                        , input buf_doc-line.prod-code
                                        , output temp_r-getsum.qnty
                                        , output temp_r-getsum.vat-pc
                                        , output temp_r-getsum.slt-pc
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-with-taxes
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-vat
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-slt
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-road-tax
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-transport
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-other
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-excise
                                        ).
        end.        /* if p-rubl-prices <> no */
    end.        /* buf_doc-line.status_ = {&fact} */
    else do:
        { str/in-vatp.i calc buf_doc-line. buf_trn-doc. }
        assign
            temp_r-getsum.qnty              = buf_doc-line.fact-qnty
            temp_r-getsum.vat-pc            = vat-pc-loc
            temp_r-getsum.slt-pc            = slt-pc-loc
            temp_r-getsum.sum-with-taxes    = (if p-rubl-prices = no
                                                    then price-base-with-tax-loc
                                                    else price-rubl-with-tax-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-vat           = (if p-rubl-prices = no
                                                    then vat-base-loc
                                                    else vat-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-slt           = (if p-rubl-prices = no
                                                    then slt-base-loc
                                                    else slt-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-road-tax      = (if p-rubl-prices = no
                                                    then road-tax-base-loc
                                                    else road-tax-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-transport     = (if p-rubl-prices = no
                                                    then transport-base-loc
                                                    else transport-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-other         = (if p-rubl-prices = no
                                                    then other-base-loc
                                                    else other-rubl-loc) * temp_r-getsum.qnty
            temp_r-getsum.sum-excise        = 0
        .
    end.        /* buf_doc-line.status_ <> {&fact} */
end.        /* if p-cost-prices = yes */
else do:
    if buf_doc-line.status_ = {&fact}
    then do:
        if p-rubl-prices = no
        then do:
            run r-sale in this-procedure ( input buf_doc-line.doc-code
                                         , input buf_doc-line.artic
                                         , input buf_doc-line.prod-type
                                         , input buf_doc-line.prod-code
                                         , output temp_r-getsum.qnty
                                         , output temp_r-getsum.vat-pc
                                         , output temp_r-getsum.slt-pc
                                         , output temp_r-getsum.sum-with-taxes
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-vat
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-slt
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-road-tax
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-transport
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-other
                                         , output v-void-output-parameter
                                         , output temp_r-getsum.sum-excise
                                         , output v-void-output-parameter
                                         ).
        end.        /* if p-rubl-prices = no */
        else do:
            run r-sale in this-procedure ( input buf_doc-line.doc-code
                                        , input buf_doc-line.artic
                                        , input buf_doc-line.prod-type
                                        , input buf_doc-line.prod-code
                                        , output temp_r-getsum.qnty
                                        , output temp_r-getsum.vat-pc
                                        , output temp_r-getsum.slt-pc
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-with-taxes
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-vat
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-slt
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-road-tax
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-transport
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-other
                                        , output v-void-output-parameter
                                        , output temp_r-getsum.sum-excise
                                        ).
        end.        /* if p-rubl-prices <> no */
    end.        /* buf_doc-line.status_ = {&fact} */
    else do:
        { str/out-vatp.i calc buf_doc-line. buf_trn-doc. }
        assign
            temp_r-getsum.qnty              = buf_doc-line.fact-qnty
            temp_r-getsum.vat-pc            = buf_doc-line.vat-pc
            temp_r-getsum.slt-pc            = buf_doc-line.slt-pc
            temp_r-getsum.sum-with-taxes    = (if p-rubl-prices = no
                                                    then price-base-with-tax-sale
                                                    else price-rubl-with-tax-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-vat           = (if p-rubl-prices = no
                                                    then vat-base-sale
                                                    else vat-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-slt           = (if p-rubl-prices = no
                                                    then slt-base-sale
                                                    else slt-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-road-tax      = (if p-rubl-prices = no
                                                    then road-tax-base-sale
                                                    else road-tax-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-transport     = 0
            temp_r-getsum.sum-other         = (if p-rubl-prices = no
                                                    then discnt-base-sale
                                                    else discnt-rubl-sale) * buf_doc-line.fact-qnty
            temp_r-getsum.sum-excise        = (if p-rubl-prices = no
                                                    then excise-base-sale
                                                    else excise-rubl-sale) * buf_doc-line.fact-qnty
        .
    end.        /* buf_doc-line.status_ <> {&fact} */
end.        /* if p-cost-prices <> yes */

assign
    temp_r-getsum.sum-no-taxes      = temp_r-getsum.sum-with-taxes
                                      - temp_r-getsum.sum-vat
                                      - temp_r-getsum.sum-slt
    temp_r-getsum.sum-no-vat        = temp_r-getsum.sum-with-taxes - temp_r-getsum.sum-vat
    temp_r-getsum.sum-no-slt        = temp_r-getsum.sum-with-taxes - temp_r-getsum.sum-slt
.
if temp_r-getsum.qnty = 0 or temp_r-getsum.qnty = ?
then do:
    assign
        temp_r-getsum.price-no-taxes    = 0
        temp_r-getsum.price-no-vat      = 0
        temp_r-getsum.price-no-slt      = 0
    .
end.
else do:
    assign
        temp_r-getsum.price-no-taxes    = temp_r-getsum.sum-no-taxes / temp_r-getsum.qnty
        temp_r-getsum.price-no-vat      = temp_r-getsum.sum-no-vat   / temp_r-getsum.qnty
        temp_r-getsum.price-no-slt      = temp_r-getsum.sum-no-vat   / temp_r-getsum.qnty
    .
end.

end.
end procedure. /* r-getsum */

/* $Workfile$ e n d */