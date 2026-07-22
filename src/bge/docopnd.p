block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docopnd.p $
$Archive: bge/docopnd.p $

Экспорт не закрытых на факт документов прихода и расхода.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-host-code       as integer                 no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-cst             as logical                 no-undo.
define input parameter p-parts           as logical                 no-undo.
define input parameter sOutFile          as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter p-parent-handle   as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docopnd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/docopnd.p $":U .
define variable vss-description as character no-undo init "Экспорт не закрытых на факт документов прихода и расхода.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bgelib.i   }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ rep/r-sale.i   }
{ rep/r-cost.i   }

do
on error undo, return error
:


    define buffer buf_trn-doc       for ub.trn-doc.

    output stream stmxmlout to value( soutfile + {&bgelib-temp-extension}  ) convert target "1251" append.

    run bgelib-write-cnt( input hCNT, "" ).
    run bgelib-write-edt( input hEDT, 4, "Операция: Выгрузка незакрытых документов прихода и расхода." ).
    run bgelib-write-log( input sLogFile, 0, "&Line" ).
    run bgelib-write-log( input sLogFile, 1, "XML - Вывод операции: Выгрузка незакрытых документов прихода и расхода." ).

    for each buf_trn-doc no-lock
       where buf_trn-doc.obj-type   = p-obj-type
         and buf_trn-doc.obj-code   = p-obj-code
         and buf_trn-doc.status_    = {&wayb}
         or ( buf_trn-doc.obj-type   = p-obj-type
            and buf_trn-doc.obj-code   = p-obj-code
            and buf_trn-doc.status_    = {&permitted} )
    :
        if buf_trn-doc.is-flora = yes
        then do:
            /* Букеты не выгружать */
        end.        /* if buf_trn-doc.is-flora = yes */
        else do:
            if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
            or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
            then do:
                run bgelib-write-cnt( input hCNT, string( buf_trn-doc.doc-date, "99/99/9999" ) + "  " + buf_trn-doc.doc-code ).
                run export-trn-doc in this-procedure (
                    input buf_trn-doc.doc-code
                    , input buf_trn-doc.ext-doc-type
                    , input p-host-code
                    , input buf_trn-doc.ext-doc-type
                    , input ( if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then 1 else -1 )
                ) no-error.
                if error-status :error
                then do:
                    undo, return error vss-description + "Ошибка вывода документа " + buf_trn-doc.doc-code.
                end.
            end.
         end.        /* NOT ( if buf_trn-doc.is-flora = yes ) */
   end.

    output stream stmxmlout close.

end.

/*==========================================================================*/
procedure export-trn-doc :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-ext-doc-type   as character    no-undo.
define input parameter p-host-code      as integer      no-undo.
define input parameter p-oper-name      as character    no-undo.
define input parameter p-sign           as integer      no-undo.

    define variable v-fact-qnty       as decimal       no-undo.
    define variable v-vat-pc          as decimal       no-undo.
    define variable v-slt-pc          as decimal       no-undo.
    define variable v-sum-base        as decimal       no-undo.
    define variable v-sum-rubl        as decimal       no-undo.
    define variable v-vat-base        as decimal       no-undo.
    define variable v-vat-rubl        as decimal       no-undo.
    define variable v-slt-base        as decimal       no-undo.
    define variable v-slt-rubl        as decimal       no-undo.
    define variable v-road-tax-base   as decimal       no-undo.
    define variable v-road-tax-rubl   as decimal       no-undo.
    define variable v-transport-base  as decimal       no-undo.
    define variable v-transport-rubl  as decimal       no-undo.
    define variable v-other-base      as decimal       no-undo.
    define variable v-other-rubl      as decimal       no-undo.
    define variable v-excise-base     as decimal       no-undo.
    define variable v-excise-rubl     as decimal       no-undo.

    define variable v-tot-cost-sum-base         as decimal       no-undo.
    define variable v-tot-cost-sum-rubl         as decimal       no-undo.
    define variable v-tot-cost-vat-base         as decimal       no-undo.
    define variable v-tot-cost-vat-rubl         as decimal       no-undo.
    define variable v-tot-cost-slt-base         as decimal       no-undo.
    define variable v-tot-cost-slt-rubl         as decimal       no-undo.
    define variable v-tot-cost-road-tax-base    as decimal       no-undo.
    define variable v-tot-cost-road-tax-rubl    as decimal       no-undo.
    define variable v-tot-cost-transport-base   as decimal       no-undo.
    define variable v-tot-cost-transport-rubl   as decimal       no-undo.
    define variable v-tot-cost-other-base       as decimal       no-undo.
    define variable v-tot-cost-other-rubl       as decimal       no-undo.
    define variable v-tot-cost-excise-base      as decimal       no-undo.
    define variable v-tot-cost-excise-rubl      as decimal       no-undo.

    define variable v-tot-sale-sum-base         as decimal       no-undo.
    define variable v-tot-sale-sum-rubl         as decimal       no-undo.
    define variable v-tot-sale-vat-base         as decimal       no-undo.
    define variable v-tot-sale-vat-rubl         as decimal       no-undo.
    define variable v-tot-sale-slt-base         as decimal       no-undo.
    define variable v-tot-sale-slt-rubl         as decimal       no-undo.
    define variable v-tot-sale-road-tax-base    as decimal       no-undo.
    define variable v-tot-sale-road-tax-rubl    as decimal       no-undo.
    define variable v-tot-sale-transport-base   as decimal       no-undo.
    define variable v-tot-sale-transport-rubl   as decimal       no-undo.
    define variable v-tot-sale-other-base       as decimal       no-undo.
    define variable v-tot-sale-other-rubl       as decimal       no-undo.
    define variable v-tot-sale-excise-base      as decimal       no-undo.
    define variable v-tot-sale-excise-rubl      as decimal       no-undo.

    define variable v-base-code     as integer        no-undo.
    define variable v-good-code     as character      no-undo.
    define variable v-good-type     as character      no-undo.

    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_goods     for ub.goods.
    define buffer buf_units     for ub.units.

    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    { gbl/basecode.i p-host-code v-base-code }
    run bgelib-tag-open in this-procedure ( input 0, input "doc", input "").
    run bgelib-tag-put in this-procedure ( input 1, input "docID"           , input buf_trn-doc.doc-code                                  , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "codeOperation"   , input string( p-ext-doc-type )                              , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "status"          , input string( buf_trn-doc.status_ )                         , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "host"            , input string( p-host-code )                                 , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "store"           , input buf_trn-doc.obj-type + string( buf_trn-doc.obj-code ) , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "dateDoc"         , input string( buf_trn-doc.doc-date, "99.99.9999")           , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "dateFact"        , input string( buf_trn-doc.fact-date, "99.99.9999")          , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "valutCode"       , input string( v-base-code )                                 , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "firm"            , input buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)   , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "extNumber"       , input string(buf_trn-doc.ord-num)                           , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "outNumber"       , input string( buf_trn-doc.ship-num )                        , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "outDate"         , input string( buf_trn-doc.ship-date, "99.99.9999" )         , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "paymentCode"     , input string(buf_trn-doc.pay-code)                          , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "factOrder"       , input string( buf_trn-doc.fact-order                       ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "sysDate"         , input string( buf_trn-doc.sys-date, "99.99.9999"           ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "sysTime"         , input string( buf_trn-doc.sys-time                         ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "reasonCode"      , input string( buf_trn-doc.reason-code                      ), input 2 ).
    run bgelib-tag-put in this-procedure ( input 1, input "comment"         , input buf_trn-doc.PS                                        , input 0 ).
    run bgelib-tag-close in this-procedure ( input 0, input "doc").

    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    :
        run bgelib-tag-open in this-procedure (3, "line","").
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        if available buf_goods
        then do:
            assign
                v-good-code = string( buf_goods.gds-code )
                v-good-type = string( buf_goods.gds-type )
            .
            run fill_bgelib_goods in this-procedure (
                  input p-parent-handle
                , input buf_goods.gds-code
            ).
        end.
        else do:
            assign
                v-good-code = ""
                v-good-type = ""
            .
        end.
        run bgelib-tag-put in this-procedure ( input 1, input "goodID", input v-good-code, input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "type", input v-good-type, input 0 ).
        find first buf_units no-lock
             where buf_units.unit-name  = buf_goods.unit-base
        no-error.
        if available buf_units
        then do:
            run bgelib-tag-put in this-procedure ( input 1, "unitType",   string(buf_units.type),             0 ).
        end.      /* available units */
        else do:
            run bgelib-tag-put in this-procedure ( input 1, "unitType",   "",                             0 ).
        end.      /* NOT available units */
        run bgelib-tag-put in this-procedure ( input 1, "wait",       string( buf_doc-line.wt-brutto ), 0 ).
        run bgelib-tag-put in this-procedure ( input 1, "place",      string( buf_doc-line.num-place ), 0 ).
        run r-sale in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , output v-fact-qnty
            , output v-vat-pc
            , output v-slt-pc
            , output v-sum-base
            , output v-sum-rubl
            , output v-vat-base
            , output v-vat-rubl
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
        assign
            v-fact-qnty      = v-fact-qnty      * p-sign
            v-sum-base       = v-sum-base       * p-sign
            v-sum-rubl       = v-sum-rubl       * p-sign
            v-vat-base       = v-vat-base       * p-sign
            v-vat-rubl       = v-vat-rubl       * p-sign
            v-slt-base       = v-slt-base       * p-sign
            v-slt-rubl       = v-slt-rubl       * p-sign
            v-road-tax-base  = v-road-tax-base  * p-sign
            v-road-tax-rubl  = v-road-tax-rubl  * p-sign
            v-transport-base = v-transport-base * p-sign
            v-transport-rubl = v-transport-rubl * p-sign
            v-other-base     = v-other-base     * p-sign
            v-other-rubl     = v-other-rubl     * p-sign
            v-excise-base    = v-excise-base    * p-sign
            v-excise-rubl    = v-excise-rubl    * p-sign
        .
        run bgelib-tag-put in this-procedure ( input 1, "qnty", string( v-fact-qnty ), 0 ).
        run bgelib-tag-close in this-procedure ( 0, "line").

        run bgelib-tag-open in this-procedure ( input 0, "lineDocSum","").
        run bgelib-tag-put in this-procedure ( input 1, input "docID",      input buf_trn-doc.doc-code , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID", input v-good-code, input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "rateVAT",    input string( v-vat-pc ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "rateSLT",    input string( v-slt-pc ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb",       input v-sum-base        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumr",       input v-sum-rubl        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb",       input v-vat-base        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr",       input v-vat-rubl        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb",       input v-slt-base        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr",       input v-slt-rubl        , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb",   input v-road-tax-base   , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr",   input v-road-tax-rubl   , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportb", input v-transport-base  , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportr", input v-transport-rubl  , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherb",     input v-other-base      , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherr",     input v-other-rubl      , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciseb",    input v-excise-base     , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciser",    input v-excise-rubl     , input 2 ).
        run bgelib-tag-close in this-procedure ( 0, "lineDocSum" ).
        assign
            v-tot-sale-sum-base       = v-tot-sale-sum-base       + v-sum-base
            v-tot-sale-sum-rubl       = v-tot-sale-sum-rubl       + v-sum-rubl
            v-tot-sale-vat-base       = v-tot-sale-vat-base       + v-vat-base
            v-tot-sale-vat-rubl       = v-tot-sale-vat-rubl       + v-vat-rubl
            v-tot-sale-slt-base       = v-tot-sale-slt-base       + v-slt-base
            v-tot-sale-slt-rubl       = v-tot-sale-slt-rubl       + v-slt-rubl
            v-tot-sale-road-tax-base  = v-tot-sale-road-tax-base  + v-road-tax-base
            v-tot-sale-road-tax-rubl  = v-tot-sale-road-tax-rubl  + v-road-tax-rubl
            v-tot-sale-transport-base = v-tot-sale-transport-base + v-transport-base
            v-tot-sale-transport-rubl = v-tot-sale-transport-rubl + v-transport-rubl
            v-tot-sale-other-base     = v-tot-sale-other-base     + v-other-base
            v-tot-sale-other-rubl     = v-tot-sale-other-rubl     + v-other-rubl
            v-tot-sale-excise-base    = v-tot-sale-excise-base    + v-excise-base
            v-tot-sale-excise-rubl    = v-tot-sale-excise-rubl    + v-excise-rubl
        .
        run r-cost in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , output v-fact-qnty
            , output v-vat-pc
            , output v-slt-pc
            , output v-sum-base
            , output v-sum-rubl
            , output v-vat-base
            , output v-vat-rubl
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
        assign
            v-fact-qnty      = v-fact-qnty      * p-sign
            v-sum-base       = v-sum-base       * p-sign
            v-sum-rubl       = v-sum-rubl       * p-sign
            v-vat-base       = v-vat-base       * p-sign
            v-vat-rubl       = v-vat-rubl       * p-sign
            v-slt-base       = v-slt-base       * p-sign
            v-slt-rubl       = v-slt-rubl       * p-sign
            v-road-tax-base  = v-road-tax-base  * p-sign
            v-road-tax-rubl  = v-road-tax-rubl  * p-sign
            v-transport-base = v-transport-base * p-sign
            v-transport-rubl = v-transport-rubl * p-sign
            v-other-base     = v-other-base     * p-sign
            v-other-rubl     = v-other-rubl     * p-sign
            v-excise-base    = v-excise-base    * p-sign
            v-excise-rubl    = v-excise-rubl    * p-sign
        .
        run bgelib-tag-open in this-procedure ( input 0, input "lineCostSum","").
        run bgelib-tag-put in this-procedure ( input 1, input "docID",      input buf_trn-doc.doc-code , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID", input v-good-code, input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "rateVAT",    input string( v-vat-pc ), input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "rateSLT",    input string( v-slt-pc ), input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb",       input v-sum-base        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "sumr",       input v-sum-rubl        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb",       input v-vat-base        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr",       input v-vat-rubl        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb",       input v-slt-base        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr",       input v-slt-rubl        , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb",   input v-road-tax-base   , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr",   input v-road-tax-rubl   , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "transportb", input v-transport-base  , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "transportr", input v-transport-rubl  , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "otherb",     input v-other-base      , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "otherr",     input v-other-rubl      , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "exciseb",    input v-excise-base     , input 2).
        run bgelib-tag-put in this-procedure ( input 1, input "exciser",    input v-excise-rubl     , input 2).
        run bgelib-tag-close in this-procedure ( input 0, input "lineCostSum" ).
        assign
            v-tot-cost-sum-base       = v-tot-cost-sum-base       + v-sum-base
            v-tot-cost-sum-rubl       = v-tot-cost-sum-rubl       + v-sum-rubl
            v-tot-cost-vat-base       = v-tot-cost-vat-base       + v-vat-base
            v-tot-cost-vat-rubl       = v-tot-cost-vat-rubl       + v-vat-rubl
            v-tot-cost-slt-base       = v-tot-cost-slt-base       + v-slt-base
            v-tot-cost-slt-rubl       = v-tot-cost-slt-rubl       + v-slt-rubl
            v-tot-cost-road-tax-base  = v-tot-cost-road-tax-base  + v-road-tax-base
            v-tot-cost-road-tax-rubl  = v-tot-cost-road-tax-rubl  + v-road-tax-rubl
            v-tot-cost-transport-base = v-tot-cost-transport-base + v-transport-base
            v-tot-cost-transport-rubl = v-tot-cost-transport-rubl + v-transport-rubl
            v-tot-cost-other-base     = v-tot-cost-other-base     + v-other-base
            v-tot-cost-other-rubl     = v-tot-cost-other-rubl     + v-other-rubl
            v-tot-cost-excise-base    = v-tot-cost-excise-base    + v-excise-base
            v-tot-cost-excise-rubl    = v-tot-cost-excise-rubl    + v-excise-rubl
        .
        if p-cst = yes
        or p-parts = yes
        then do:        /* Надо экспортировать номера ГТД или партии */
            run export-parts in this-procedure (
                  input buf_doc-line.doc-code
                , input ( if available buf_goods then buf_goods.gds-code else 0 )
                , input buf_doc-line.obj-type
                , input buf_doc-line.obj-code
                , input buf_doc-line.prod-type
                , input buf_doc-line.prod-code
                , input buf_doc-line.artic
            ).
        end.        /* if p-ext-doc-type <> {&TDEDT_Overturn} */
    end.
    run bgelib-tag-open in this-procedure (input 0, input "docSum", input "" ).
    run bgelib-tag-put in this-procedure ( input 1, input "docID",      input buf_trn-doc.doc-code , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "sumb",       input v-tot-sale-sum-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "sumr",       input v-tot-sale-sum-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "VATb",       input v-tot-sale-vat-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "VATr",       input v-tot-sale-vat-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "SLTb",       input v-tot-sale-slt-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "SLTr",       input v-tot-sale-slt-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb",   input v-tot-sale-road-tax-base  , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr",   input v-tot-sale-road-tax-rubl  , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "transportb", input v-tot-sale-transport-base , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "transportr", input v-tot-sale-transport-rubl , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "otherb",     input v-tot-sale-other-base     , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "otherr",     input v-tot-sale-other-rubl     , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "exciseb",    input v-tot-sale-excise-base    , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "exciser",    input v-tot-sale-excise-rubl    , input 2).
    run bgelib-tag-close in this-procedure ( input 0, input "docSum" ).
    run bgelib-tag-open in this-procedure( input 0, input "docCostSum", input "").
    run bgelib-tag-put in this-procedure ( input 1, input "docID",      input buf_trn-doc.doc-code , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "sumb",       input v-tot-cost-sum-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "sumr",       input v-tot-cost-sum-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "VATb",       input v-tot-cost-vat-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "VATr",       input v-tot-cost-vat-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "SLTb",       input v-tot-cost-slt-base       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "SLTr",       input v-tot-cost-slt-rubl       , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb",   input v-tot-cost-road-tax-base  , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr",   input v-tot-cost-road-tax-rubl  , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "transportb", input v-tot-cost-transport-base , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "transportr", input v-tot-cost-transport-rubl , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "otherb",     input v-tot-cost-other-base     , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "otherr",     input v-tot-cost-other-rubl     , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "exciseb",    input v-tot-cost-excise-base    , input 2).
    run bgelib-tag-put in this-procedure ( input 1, input "exciser",    input v-tot-cost-excise-rubl    , input 2).
    run bgelib-tag-close in this-procedure ( input 0, input "docCostSum" ).
end.
end procedure. /* export-trn-doc */



/*==========================================================================*/
procedure export-parts :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
define input parameter p-artic      as character    no-undo.

    define variable v-parts-cst-code    as character    no-undo.

    define variable v-fact-qnty      as decimal     no-undo.
    define variable v-sum-rubl       as decimal     no-undo.
    define variable v-vat-rubl       as decimal     no-undo.
    define variable v-slt-rubl       as decimal     no-undo.
    define variable v-road-tax-rubl  as decimal     no-undo.
    define variable v-transport-rubl as decimal     no-undo.
    define variable v-other-rubl     as decimal     no-undo.
    define variable v-excise-rubl    as decimal     no-undo.
    define variable v-sum-base       as decimal     no-undo.
    define variable v-vat-base       as decimal     no-undo.
    define variable v-slt-base       as decimal     no-undo.
    define variable v-road-tax-base  as decimal     no-undo.
    define variable v-transport-base as decimal     no-undo.
    define variable v-other-base     as decimal     no-undo.
    define variable v-excise-base    as decimal     no-undo.

    define variable v-supp-type      as character   no-undo.
    define variable v-supp-code      as integer     no-undo.
    define variable v-in-code        as character   no-undo.
    define variable v-cst-code       as character   no-undo.
    define variable v-parts-host-code      as integer       no-undo.
    define variable v-parts-contract-code  as integer       no-undo.


    define buffer buf_parts                for ub.parts.
    define buffer buf_parts-attr           for ub.parts-attr.

    assign
        v-parts-cst-code = ""
    .
    for each buf_parts no-lock
        where buf_parts.out-code   = p-doc-code
          and buf_parts.obj-type   = p-obj-type
          and buf_parts.obj-code   = p-obj-code
          and buf_parts.prod-type  = p-prod-type
          and buf_parts.prod-code  = p-prod-code
          and buf_parts.artic      = p-artic
/*          and buf_parts.status_    = true*/
    on error undo, return error return-value
    :
        if p-parts = yes
        then do:
            { str/in-vatp.i calc-parts buf_parts. " " loc}
            ASSIGN
                v-fact-qnty           = buf_parts.fact-qnty
                v-sum-rubl            = price-rubl-with-tax-loc * v-fact-qnty
                v-vat-rubl            = vat-rubl-loc            * v-fact-qnty
                v-slt-rubl            = slt-rubl-loc            * v-fact-qnty
                v-road-tax-rubl       = road-tax-rubl-loc       * v-fact-qnty
                v-transport-rubl      = transport-rubl-loc      * v-fact-qnty
                v-other-rubl          = other-rubl-loc          * v-fact-qnty
                v-excise-rubl         = 0
                v-sum-base            = price-base-with-tax-loc * v-fact-qnty
                v-vat-base            = vat-base-loc            * v-fact-qnty
                v-slt-base            = slt-base-loc            * v-fact-qnty
                v-road-tax-base       = road-tax-base-loc       * v-fact-qnty
                v-transport-base      = transport-base-loc      * v-fact-qnty
                v-other-base          = other-base-loc          * v-fact-qnty
                v-excise-base         = 0
                v-parts-host-code     = buf_parts.host-code
                v-parts-contract-code = buf_parts.contract-code
            .
            if p-gds-code <> 0
            then do:
                find first buf_parts-attr no-lock
                     where buf_parts-attr.in-code   = buf_parts.in-code
                       and buf_parts-attr.gds-code  = p-gds-code
                       and buf_parts-attr.part-code = buf_parts.part-code
                no-error .
                if available buf_parts-attr
                then do:
                    assign
/*                                        v-is-attr      = yes*/
/*                                        v-parts-VAt-pc = buf_parts-attr.vat-pc*/
/*                                        v-parts-SLT-pc = buf_parts-attr.SLT-pc*/
/*                                        v-purch-code = buf_parts-attr.purch-code*/
/*                                        v-fact-date = buf_parts-attr.fact-date*/
                        v-supp-type = buf_parts-attr.supp-type
                        v-supp-code = buf_parts-attr.supp-code
                        v-in-code   = buf_parts-attr.income-in-code
                        v-cst-code  = buf_parts-attr.cst-code
                    .
                end.        /* if available buf_parts-attr */
                else do:
                    assign
/*                                    v-is-attr      = no*/
/*                                    v-parts-VAt-pc = buf_parts.vat-pc*/
/*                                    v-parts-SLT-pc = buf_parts.SLT-pc*/
/*                                    v-purch-code = buf_parts.purch-code*/
/*                                    v-fact-date = ?*/
                        v-supp-type = buf_parts.supp-type
                        v-supp-code = buf_parts.supp-code
                        v-in-code   = buf_parts.in-code
                        v-cst-code  = buf_parts.cst-code
                    .
                end.        /* NOT ( if available buf_parts-attr ) */
            end.        /* if p-gds-code <> 0 */
            else do:
                assign
                    v-supp-type = buf_parts.supp-type
                    v-supp-code = buf_parts.supp-code
                    v-in-code   = buf_parts.in-code
                    v-cst-code  = buf_parts.cst-code
                .
            end.        /* NOT ( p-gds-code <> 0 ) */
            run bgelib-tag-open in this-procedure ( input 0, input "linePart", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-doc-code                 , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "inputDocID"  , input string( v-in-code          ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-fact-qnty        ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "cst"         , input string( v-cst-code         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "supp"        , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "hostCode"    , input string( v-parts-host-code       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractCode", input string( v-parts-contract-code   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-sum-rubl         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , input string( v-vat-rubl         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , input string( v-slt-rubl         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , input string( v-road-tax-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , input string( v-transport-rubl   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , input string( v-other-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , input string( v-excise-rubl      ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-sum-base         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , input string( v-vat-base         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , input string( v-slt-base         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , input string( v-road-tax-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , input string( v-transport-base   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , input string( v-other-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , input string( v-excise-base      ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "linePart" ).
        end.        /* p-parts = yes */
        if p-cst = yes
        then do:
            assign
                v-parts-cst-code = v-parts-cst-code
                                    + ( if ( v-cst-code <> ?
                                        and trim( v-cst-code )   <> ""
                                        and trim( v-parts-cst-code ) <> "" )
                                        then "; "
                                        else ""  )
                                    + v-cst-code
            .
        end.        /* p-cst = yes */
    end.
    if p-cst = yes
    and v-parts-cst-code <> ""
    then do:
        run bgelib-tag-open in this-procedure ( input 0, input "lineCST", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID"  , input p-doc-code       , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID" , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "CST"      , input v-parts-cst-code , input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "lineCST" ).
    end.        /* if p-cst = yes */
end.
end procedure. /* export-parts */



/*==========================================================================*/
procedure fill_bgelib_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bgelib_goods" ) <> "":U
    then do:
        run cb-fill_bgelib_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure. /* fill_bgelib_goods */