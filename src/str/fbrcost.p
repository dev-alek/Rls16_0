block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrcost.p $
$Archive: str/fbrcost.p $

Суммы по строке документа для использования в производстве

Автор: Хныкин Павел Андреевич
Дата создания: 02/17/09
Author: Pavel Khnykin
Creation date: 02/17/09

Input:
    p-qnty - для услуги количество берется из документа производства

Output:

*/

define input parameter p-doc-line-recid    as recid     no-undo .
define input parameter p-sign              as integer   no-undo.
define input parameter p-qnty              as decimal   no-undo.
define output parameter p-sum-base         as decimal   no-undo .
define output parameter p-sum-rubl         as decimal   no-undo .
define output parameter p-vat-base         as decimal   no-undo .
define output parameter p-vat-rubl         as decimal   no-undo .
define output parameter p-vat-pc           as decimal   no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbrcost.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbrcost.p $":U .
define variable vss-description as character no-undo init "Суммы по строке документа для использования в производстве".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rep/r-cost.i   }

do
on error undo, return error return-value
:
    define variable v-fact-qnty      as decimal       no-undo.
    define variable v-vat-pc         as decimal       no-undo.
    define variable v-slt-pc         as decimal       no-undo.
    define variable v-slt-base       as decimal       no-undo.
    define variable v-slt-rubl       as decimal       no-undo.
    define variable v-road-tax-base  as decimal       no-undo.
    define variable v-road-tax-rubl  as decimal       no-undo.
    define variable v-transport-base as decimal       no-undo.
    define variable v-transport-rubl as decimal       no-undo.
    define variable v-other-base     as decimal       no-undo.
    define variable v-other-rubl     as decimal       no-undo.
    define variable v-excise-base    as decimal       no-undo.
    define variable v-excise-rubl    as decimal       no-undo.

    define buffer buf_doc-line  for doc-line.
    define buffer buf_goods     for goods.
    define buffer buf_gds-obj   for gds-obj.

    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic     = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
    .
    if buf_goods.gds-type = {&gds-office}
    then do:
        find first buf_gds-obj no-lock
             where buf_gds-obj.obj-type  = buf_doc-line.obj-type
               and buf_gds-obj.obj-code  = buf_doc-line.obj-code
               and buf_gds-obj.artic     = buf_doc-line.artic
               and buf_gds-obj.prod-type = buf_doc-line.prod-type
               and buf_gds-obj.prod-code = buf_doc-line.prod-code
        .
        assign
            p-sum-base = buf_gds-obj.price-base     * ( -1 ) * p-qnty
            p-sum-rubl = buf_gds-obj.price-rubl     * ( -1 ) * p-qnty
            p-vat-base = 0
            p-vat-rubl = 0
        .
/* Если понадобятся для услуги значения учетного НДС 20%, то вместо последних двух строк следует прописать:*/
/*            p-vat-base = buf_gds-obj.price-base / 6 * ( -1 )*/
/*            p-vat-rubl = buf_gds-obj.price-rubl / 6 * ( -1 )*/
    end.
    else do:
        run r-cost in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , output v-fact-qnty
            , output v-vat-pc
            , output v-slt-pc
            , output p-sum-base
            , output p-sum-rubl
            , output p-vat-base
            , output p-vat-rubl
            , output v-slt-base
            , output v-slt-rubl
            , output v-road-tax-base
            , output v-road-tax-rubl
            , output v-transport-base
            , output v-transport-rubl
            , output v-other-base
            , output v-other-rubl
            , output v-excise-base
            , output v-excise-rubl
        ).
    end.
    assign
      p-sum-base = p-sign * p-sum-base
      p-sum-rubl = p-sign * p-sum-rubl
      p-vat-base = p-sign * p-vat-base
      p-vat-rubl = p-sign * p-vat-rubl
      p-vat-pc   = v-vat-pc
    .
end.