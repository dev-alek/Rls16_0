block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doc-opnd.p $
$Archive: bge/doc-opnd.p $

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
define variable vss-workfile    as character no-undo init "$Workfile: doc-opnd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-opnd.p $":U .
define variable vss-description as character no-undo init "Экспорт не закрытых на факт документов прихода и расхода.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }
{ str/in-vatp.i def}
{ str/out-vatp.i def}
{ rep/r-sale.i   }
{ rep/r-cost.i   }

do
on error undo, return error
:


    define buffer buf_trn-doc       for ub.trn-doc.

    output stream stmxmlout to value( soutfile + "xm1" ) convert target "1251" append.

    run wp-XMLWriteCNT( hCNT, "" ).
    run wp-XMLWriteEDT( hEDT, 4, "Операция: Выгрузка незакрытых документов прихода и расхода." ).
    run wp-XMLWriteLog( sLogFile, 0, "&Line" ).
    run wp-XMLWriteLog( sLogFile, 1, "XML - Вывод операции: Выгрузка незакрытых документов прихода и расхода." ).

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
                run wp-XMLWriteCNT( hCNT, string( buf_trn-doc.doc-date, "99/99/9999" ) + "  " + buf_trn-doc.doc-code ).
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

    define variable v-base-code                 as integer       no-undo.
    define variable v-base-code-okv             as integer       no-undo.

    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_goods     for ub.goods.
    define buffer buf_units     for ub.units.
    define buffer buf_parts     for ub.parts.
do
for buf_trn-doc
  , buf_doc-line
  , buf_goods
  , buf_units
  , buf_parts
on error undo, return error
:

    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    { gbl/basecode.i p-host-code v-base-code }
    run get-base-code-okv in this-procedure (
          input v-base-code
        , output v-base-code-okv
    ).
    run wp-xmltagopen(2, "operation","").
    run wp-xmltagput(3, "referenceNo",    buf_trn-doc.doc-code, 0).
    run wp-xmltagput(3, "codeOperation",  string( p-ext-doc-type ), 0).
    run wp-xmltagput(3, "status",         string( buf_trn-doc.status_ ), 0).
    run wp-xmltagput(3, "host",           string( p-host-code ), 0).
    run wp-xmltagput(3, "store",          buf_trn-doc.obj-type + string( buf_trn-doc.obj-code ), 0).
    run wp-xmltagput(3, "factOrder"    ,  string( buf_trn-doc.fact-order                        ), 0 ).
    run wp-xmltagput(3, "sysDate"      ,  string( buf_trn-doc.sys-date, "99.99.9999"            ), 0 ).
    run wp-xmltagput(3, "sysTime"      ,  string( buf_trn-doc.sys-time                          ), 0 ).
    run wp-xmltagput(3, "dateDoc",        string( buf_trn-doc.doc-date,"99.99.9999"), 0).
    run wp-xmltagput(3, "dateFact",       string( buf_trn-doc.fact-date,"99.99.9999"), 0).
    run wp-xmltagput(3, "valutCode",      string( v-base-code ), 0).
    run wp-xmltagput(3, "valutCodeOKV",   string( v-base-code-okv                      ), 0 ).
     run wp-xmltagput(3, "firm",           buf_trn-doc.cli-type + string(buf_trn-doc.cli-code), 0).
    run wp-xmltagput(3, "extNumber",      string(buf_trn-doc.ord-num), 0).
    run wp-xmltagput(3, "paymentCode",   string(buf_trn-doc.pay-code), 0).
    run wp-xmltagput(3, "outCode",       buf_trn-doc.out-code, 0).
    run wp-xmltagput(3, "reasonCode",     string( buf_trn-doc.reason-code ), 2 ).
    run wp-xmltagput(3, "comment",       buf_trn-doc.PS, 0).

    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    :
        run wp-xmltagopen(3, "linedoc","").
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        if available buf_goods
        then do:
            run wp-xmltagput( 4, "good",       string(buf_goods.gds-code),         0).
            run wp-xmltagput( 4, "type",       string(buf_goods.gds-type),         0).
            run fill_bge-xml_goods in this-procedure (
                  input p-parent-handle
                , input buf_goods.gds-code
            ).
        end.
        else do:
            run wp-xmltagput( 4, "good",       "",         0).
            run wp-xmltagput( 4, "type",       "",         0).
        end.
        find first buf_units no-lock
             where buf_units.unit-name  = buf_goods.unit-base
        no-error.
        if available buf_units
        then do:
            run wp-xmltagput( 4, "unitType",   string(buf_units.type),             0 ).
        end.      /* available units */
        else do:
            run wp-xmltagput( 4, "unitType",   "",                             0 ).
        end.      /* NOT available units */
        run wp-xmltagput( 4, "wait",       string( buf_doc-line.wt-brutto ), 0 ).
        run wp-xmltagput( 4, "place",      string( buf_doc-line.num-place ), 0 ).
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
        run wp-xmltagput( 4, "quantity",    string( v-fact-qnty ), 0 ).
        run wp-xmltagopen( 4, "docSum","").
        run wp-xmltagput( 5, "rateVAT",    string( v-vat-pc ), 2).
        run wp-xmltagput( 5, "rateSLT",    string( v-slt-pc ), 2).
        run wp-xmltagput( 5, "sumr",       v-sum-rubl       , 2).
        run wp-xmltagput( 5, "VATr",       v-vat-rubl       , 2).
        run wp-xmltagput( 5, "SLTr",       v-slt-rubl       , 2).
        run wp-xmltagput( 5, "roadTaxr",   v-road-tax-rubl  , 2).
        run wp-xmltagput( 5, "transportr", v-transport-rubl , 2).
        run wp-xmltagput( 5, "otherr",     v-other-rubl     , 2).
        run wp-xmltagput( 5, "exciser",    v-excise-rubl    , 2).
        run wp-xmltagput( 5, "sumb",       v-sum-base       , 2).
        run wp-xmltagput( 5, "VATb",       v-vat-base       , 2).
        run wp-xmltagput( 5, "SLTb",       v-slt-base       , 2).
        run wp-xmltagput( 5, "roadTaxb",   v-road-tax-base  , 2).
        run wp-xmltagput( 5, "transportb", v-transport-base , 2).
        run wp-xmltagput( 5, "otherb",     v-other-base     , 2).
        run wp-xmltagput( 5, "exciseb",    v-excise-base    , 2).
        run wp-xmltagclose( 4, "docSum" ).
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
        run wp-xmltagopen( 4, "costSum","").
        run wp-xmltagput( 5, "rateVAT",    string( v-vat-pc ), 2).
        run wp-xmltagput( 5, "rateSLT",    string( v-slt-pc ), 2).
        run wp-xmltagput( 5, "sumr",       v-sum-rubl       , 2).
        run wp-xmltagput( 5, "VATr",       v-vat-rubl       , 2).
        run wp-xmltagput( 5, "SLTr",       v-slt-rubl       , 2).
        run wp-xmltagput( 5, "roadTaxr",   v-road-tax-rubl  , 2).
        run wp-xmltagput( 5, "transportr", v-transport-rubl , 2).
        run wp-xmltagput( 5, "otherr",     v-other-rubl     , 2).
        run wp-xmltagput( 5, "exciser",    v-excise-rubl    , 2).
        run wp-xmltagput( 5, "sumb",       v-sum-base       , 2).
        run wp-xmltagput( 5, "VATb",       v-vat-base       , 2).
        run wp-xmltagput( 5, "SLTb",       v-slt-base       , 2).
        run wp-xmltagput( 5, "roadtaxb",   v-road-tax-base  , 2).
        run wp-xmltagput( 5, "transportb", v-transport-base , 2).
        run wp-xmltagput( 5, "otherb",     v-other-base     , 2).
        run wp-xmltagput( 5, "exciseb",    v-excise-base    , 2).
        run wp-xmltagclose( 4, "costSum" ).
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
        run wp-xmltagclose( 3, "linedoc").
    end.
    run wp-xmltagopen( 3, "docSum","").
    run wp-xmltagput( 4, "sumr",       v-tot-sale-sum-rubl       , 2).
    run wp-xmltagput( 4, "VATr",       v-tot-sale-vat-rubl       , 2).
    run wp-xmltagput( 4, "SLTr",       v-tot-sale-slt-rubl       , 2).
    run wp-xmltagput( 4, "roadTaxr",   v-tot-sale-road-tax-rubl  , 2).
    run wp-xmltagput( 4, "transportr", v-tot-sale-transport-rubl , 2).
    run wp-xmltagput( 4, "otherr",     v-tot-sale-other-rubl     , 2).
    run wp-xmltagput( 4, "exciser",    v-tot-sale-excise-rubl    , 2).
    run wp-xmltagput( 4, "sumb",       v-tot-sale-sum-base       , 2).
    run wp-xmltagput( 4, "VATb",       v-tot-sale-vat-base       , 2).
    run wp-xmltagput( 4, "SLTb",       v-tot-sale-slt-base       , 2).
    run wp-xmltagput( 4, "roadtaxb",   v-tot-sale-road-tax-base  , 2).
    run wp-xmltagput( 4, "transportb", v-tot-sale-transport-base , 2).
    run wp-xmltagput( 4, "otherb",     v-tot-sale-other-base     , 2).
    run wp-xmltagput( 4, "exciseb",    v-tot-sale-excise-base    , 2).
    run wp-xmltagclose( 3, "docSum" ).
    run wp-xmltagopen( 3, "costSum","").
    run wp-xmltagput( 4, "sumr",       v-tot-cost-sum-rubl       , 2).
    run wp-xmltagput( 4, "VATr",       v-tot-cost-vat-rubl       , 2).
    run wp-xmltagput( 4, "SLTr",       v-tot-cost-slt-rubl       , 2).
    run wp-xmltagput( 4, "roadTaxr",   v-tot-cost-road-tax-rubl  , 2).
    run wp-xmltagput( 4, "transportr", v-tot-cost-transport-rubl , 2).
    run wp-xmltagput( 4, "otherr",     v-tot-cost-other-rubl     , 2).
    run wp-xmltagput( 4, "exciser",    v-tot-cost-excise-rubl    , 2).
    run wp-xmltagput( 4, "sumb",       v-tot-cost-sum-base       , 2).
    run wp-xmltagput( 4, "VATb",       v-tot-cost-vat-base       , 2).
    run wp-xmltagput( 4, "SLTb",       v-tot-cost-slt-base       , 2).
    run wp-xmltagput( 4, "roadtaxb",   v-tot-cost-road-tax-base  , 2).
    run wp-xmltagput( 4, "transportb", v-tot-cost-transport-base , 2).
    run wp-xmltagput( 4, "otherb",     v-tot-cost-other-base     , 2).
    run wp-xmltagput( 4, "exciseb",    v-tot-cost-excise-base    , 2).
    run wp-xmltagclose( 3, "costSum" ).
    run wp-xmltagclose(2, "operation").
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
            run wp-xmltagopen in this-procedure ( input 5, input "part", input "" ).
            run wp-xmltagput in this-procedure ( input 6, input "doc_ID"    , input string( v-in-code          ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "qnty"      , input string( v-fact-qnty        ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "cst"       , input string( v-cst-code         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "supp"      , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "hostCode"      , input string( v-parts-host-code       ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "contractCode"  , input string( v-parts-contract-code   ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "sumr"      , input string( v-sum-rubl         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "VATr"      , input string( v-vat-rubl         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "SLTr"      , input string( v-slt-rubl         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "roadTaxr"  , input string( v-road-tax-rubl    ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "transportr", input string( v-transport-rubl   ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "otherr"    , input string( v-other-rubl       ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "exciser"   , input string( v-excise-rubl      ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "sumb"      , input string( v-sum-base         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "VATb"      , input string( v-vat-base         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "SLTb"      , input string( v-slt-base         ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "roadtaxb"  , input string( v-road-tax-base    ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "transportb", input string( v-transport-base   ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "otherb"    , input string( v-other-base       ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "exciseb"   , input string( v-excise-base      ), input 2 ).
            run wp-xmltagclose in this-procedure ( input 5, input "part" ).
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
        run wp-xmltagput in this-procedure ( input 4, input "CSTCode"      , input v-parts-cst-code , input 0 ).
    end.        /* if p-cst = yes */
end.
end procedure. /* export-parts */


/*==========================================================================*/
procedure fill_bge-xml_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_goods" ) <> "":U
    then do:
        run cb-fill_bge-xml_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure. /* fill_bge-xml_goods */


/*==========================================================================*/
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.

    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure. /* get-valutCode */