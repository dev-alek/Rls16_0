block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: avt-akt1.p $
$Archive: rep/avt-akt1.p $

Печать акта формирования продажной цены

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter prod-price           as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: avt-akt1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/avt-akt1.p $":U .
define variable vss-description as character no-undo init "Печать акта формирования продажной цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i }
{ gbl/cur-time.i }
{ str/get-pr.i def }
{ cmp/r-pril.i   }
{ str/in-vatp.i def }
{ cmp/library.i  }
{ str/trdcalib.i }
{ str/getctxtp.i def }
{ gbl/getsect.i  def }
/*дорожный налог объявим один лишь раз в базовой валюте*/

&scop rate-calc-rubl-base * 1
&scop temp-road-tax {&road-tax-cur}
&glob SLT-calc-ov (price-lst - ~{&road-tax-cur}) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc)
&scop slt-temp {&slt-calc}

def buffer t-doc for trn-doc.
def temp-table t-doc-line no-undo like doc-line.

define variable sum-no-NDS              as decimal     no-undo.
define variable doc-sum                 as decimal     no-undo.
define variable obj-sum                 as decimal     no-undo.
define variable v-tax-sum               as decimal     no-undo. /*Третий налог (road-tax)*/
define variable SLT-sum                 as decimal     no-undo.
define variable VAT-sum                 as decimal     no-undo.
define variable VAT-gds                 as decimal     no-undo.
define variable VAT-gds-pc              as decimal     no-undo.
define variable VAT-prod                as decimal     no-undo.
define variable marg                    as decimal     no-undo.
define variable price-doc               as decimal     no-undo.
define variable price-lst               as decimal     no-undo.
define variable v-sum-sale              as decimal     no-undo.
define variable v-sum-cost-without-vat  as decimal     no-undo.
define variable v-nids                  as character   no-undo.
define variable v-parameter-type        as character   no-undo.

define variable v-vat-pc        like doc-line.vat-pc    no-undo.
define variable v-slt-pc        like doc-line.slt-pc    no-undo.
define variable v-host-code     like sysconf.host-code  no-undo.


define variable propis          as character        no-undo.
define variable abbr            as character        no-undo.
define variable UpFact          as character        no-undo.
define variable Delt            as character        no-undo.

define variable Lines_Counter   as integer          no-undo.
define variable Line            as character        no-undo.

define variable sym1       as character init ":"    no-undo.
define variable sym2       as character init ":"    no-undo.
define variable tb-code    as character             no-undo.

define variable tdoc-date  like    trn-doc.doc-date no-undo.
define variable tdoc-code  like trn-doc.doc-code    no-undo.

define variable v-curr-r-b as character         no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
{ str/getctxtp.i get p-mainmenu-handle }

def buffer Our_Host for clients.

{ gbl/curr-r-b.i v-curr-r-b }

DEFINE FRAME Akt
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(20)"
        gds-dtl.fact-qnty column-label "Количество ! " format ">>>>>>9.<<<"
        price-doc column-label "Цена без!НДС" format ">>>>>>9.99"
        sum-no-NDS column-label "Сумма без!НДС" format "->>>>>>>>9.99"
        VAT-prod column-label "НДС по!докум." format "->>>>>>>9.99"
        doc-sum column-label "Сумма по!докум." format "->>>>>>>>9.99"
        price-lst column-label "Цена по!объекту" format ">>>>>>9.99"
        obj-sum column-label "Сумма по!объекту" format "->>>>>>>>9.99"
        UpFact column-label "Торговая!наценка" format "X(8)"
        Delt column-label "Процент!разницы" format "X(8)"
        t-doc-line.vat-pc column-label "Ставка!НДС" format ">>9.<<%"
        VAT-sum column-label "Сумма НДС от!прод.цен" format "->>>>>>>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
    HEADER
            cur-time-print() AT 5 format "X(35)"
            string( "Акт формирования прод. цены по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) AT 40 format "X(80)"
            string( (if prod-price then "(Прод. цена на момент печати)" else "" ) ) AT 125 format "X(35)"
            string( "Страница " + string(PAGE-NUMBER) ) AT 164 format "X(15)" SKIP
        Line format "X(180)" AT 1
    with width {&DOS_CW} stream-io.

Line = fill("-", 200).
FIND t-doc WHERE recid(t-doc) = rec_id  NO-LOCK.

define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .
{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

assign
    tdoc-date = IF t-doc.fact-date = ? THEN t-doc.doc-date ELSE t-doc.fact-date
    tdoc-code    = t-doc.doc-code
.
FIND Our_Host WHERE Our_Host.obj-type = {&cmp} AND
                                        Our_Host.obj-code = t-doc.host-code NO-LOCK.

{ cmp/open-out.i " " " " " " {&LS_PS_A4} }

PUT SPACE(90) Our_Host.obj-name format "x(40)" SKIP(2)
        SPACE(20) "А К Т  формирования продажной цены по документу  N " format "x(80)"
        t-doc.doc-code format "X(10)"
        "  от  " t-doc.doc-date format "99.99.9999" SKIP(1).

if t-doc.doc-type = {&income}
and not t-doc.internal
then do:
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-nids}
        v-nids
        v-parameter-type
    }
    if v-nids <> ""
    and v-nids <> ?
    then do:
        put
                    space(20)   "Основание: накладная поставщика N: "
                                v-nids format "x(110)"
            skip(1)
        .
    end.
end.

if t-doc.doc-type = {&income} OR
   ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} ) OR
   ( t-doc.doc-type = {&expense} AND ( NOT t-doc.internal ) ) then
    do:
        PUT SPACE(20) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)" SKIP(1) .
    end.

FORM HEADER
    Line format "X(180)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW FRAME BottomFrame .

FOR EACH doc-line WHERE doc-line.doc-code = t-doc.doc-code NO-LOCK ,
        EACH gds-dtl WHERE gds-dtl.doc-code = t-doc.doc-code AND
                                            gds-dtl.prod-type = doc-line.prod-type AND
                                            gds-dtl.prod-code = doc-line.prod-code AND
                                            gds-dtl.artic = doc-line.artic NO-LOCK,
        EACH goods WHERE goods.prod-type = gds-dtl.prod-type AND
                                           goods.prod-code = gds-dtl.prod-code AND
                                           goods.artic = gds-dtl.artic NO-LOCK
            BREAK BY gds-dtl.artic BY gds-dtl.prt-code with FRAME Akt :

       FOR EACH t-doc-line :
          delete t-doc-line.
       END.
       CREATE t-doc-line.
       BUFFER-COPY doc-line TO t-doc-line.
       { gbl/hostcode.i doc-line.obj-type doc-line.obj-code v-host-code }
/*       { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code doc-line.obj-type doc-line.obj-code v-vat-pc no-error }*/
/*       { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code doc-line.obj-type doc-line.obj-code v-slt-pc no-error }*/
/*       assign*/
/*           t-doc-line.vat-pc = v-vat-pc*/
/*           t-doc-line.slt-pc = v-slt-pc*/
/*       .*/
       FIND bar-code WHERE bar-code.gds-code = goods.gds-code
                       AND bar-code.unit-cli = goods.unit-base
                       AND bar-code.node-code = gds-dtl.prt-code
                       AND bar-code.part-code = ""
                       AND bar-code.in-code = ""
                           NO-LOCK no-error.
        if prod-price = yes
        then do:
                { str/get-pr.i calc t-doc.obj-type t-doc.obj-code goods.gds-code bar-code.node-code }
                assign price-lst = gp-price-sale.
            end.
        else do:
            assign price-lst = gds-dtl.cur-base.
        end.

        if t-doc.doc-type = {&income}
        then do:
            { str/in-vatp.i calc doc-line. t-doc. g }
            if road-tax-rubl-loc = ? then assign road-tax-rubl-loc = 0.
            if road-tax-base-loc = ? then assign road-tax-base-loc = 0.
            assign
                price-doc = ( if v-curr-r-b = {&r-b-base}
                              then ( price-base-with-tax-loc - vat-base-loc )
                              else ( price-rubl-with-tax-loc - vat-rubl-loc ) )
                v-tax-sum = ( if v-curr-r-b = {&r-b-base}
                              then road-tax-base-loc
                              else road-tax-rubl-loc )
            .
        end.
        else do:
            if v-curr-r-b = {&r-b-base}
            then do:
                assign
                    price-doc = gds-dtl.price-base - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
            else do:
                assign
                    price-doc = gds-dtl.price-rubl - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1 - (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - ub.doc-line.road-tax * 1)                           * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc))                           * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
                .
            end.
        end.
        if prod-price = yes
        then do:
            { gbl/pftxvalg.i
                goods.gds-code
                {&vat-tax-code}
                ?
                v-host-code
                doc-line.obj-type
                doc-line.obj-code
                Vat-gds-pc
                no-error
            }
        end.
        else do:
            { gbl/pftxvalg.i
                goods.gds-code
                {&vat-tax-code}
                t-doc.fact-date
                v-host-code
                doc-line.obj-type
                doc-line.obj-code
                Vat-gds-pc
                no-error
            }
        end.
        assign
            Vat-gds     = ( price-lst - {&SLT-calc-ov} - v-tax-sum) * Vat-gds-pc / ( 100 + Vat-gds-pc )
            Vat-prod    = ( gds-dtl.fact-qnty * ( if v-curr-r-b = {&r-b-base} then gds-dtl.price-base else gds-dtl.price-rubl ) )
                            - ( gds-dtl.fact-qnty * price-doc )
            marg        = price-lst - price-doc - Vat-gds - {&SLT-calc-ov}
        .
        ACCUMULATE
            bar-code.b-code ( COUNT )
            gds-dtl.fact-qnty ( TOTAL )
            marg * gds-dtl.fact-qnty ( TOTAL )
            gds-dtl.fact-qnty * {&SLT-calc-ov} ( TOTAL )
            gds-dtl.fact-qnty * VAT-gds ( TOTAL )
            ( gds-dtl.fact-qnty * price-lst ) ( TOTAL )
            ( gds-dtl.fact-qnty * price-doc ) ( TOTAL )
        .
        if v-curr-r-b = {&r-b-base}
        then do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        else do:
            ACCUMULATE
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( TOTAL )
            .
        end.
        assign
             delt = ( if v-curr-r-b = {&r-b-base}
                      then string( ( price-lst - gds-dtl.price-base ) / gds-dtl.price-base * 100, "->>>9.9" )
                      else string( ( price-lst - gds-dtl.price-rubl ) / gds-dtl.price-rubl * 100, "->>>9.9" )
                    ) + "%"
        .
        DISPLAY sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                price-doc
                ( gds-dtl.fact-qnty * price-doc ) @ sum-no-NDS
                VAT-prod
                ( gds-dtl.fact-qnty * ( if v-curr-r-b = {&r-b-base} then gds-dtl.price-base else gds-dtl.price-rubl ) ) @ doc-sum
                price-lst
                ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                t-doc-line.vat-pc
                ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                string( string( marg / price-doc * 100, "->>>9.9" ) + "%" ) @ UpFact
                Delt
                sym2
        .
        IF LENGTH(goods.gds-name, "CHARACTER") > 20 and FullGdsName THEN  do:
          assign propis = SUBSTRING(goods.gds-name,21) .
          DOWN 1 .
          DISPLAY sym1 propis @ goods.gds-name  sym2     .
        end.
        if LAST( gds-dtl.artic ) then
            do:
                DOWN 1 .
                PUT Line format "X(180)" SKIP .

                assign
                    v-sum-cost-without-vat = ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc )
                    v-sum-sale             = ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst )
                .
                assign
                    Delt = ( if v-curr-r-b = {&r-b-base}
                            then string( ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) )
                                       / ( ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-base ) ) * 100, "->>>9.9" ) + "%"
                            else string( ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) )
                                       / ( ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ) * 100, "->>>9.9" ) + "%"
                           )
                .
                DISPLAY "  ИТОГО"    @ goods.gds-name
                    ACCUM TOTAL gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc )   @ sum-no-NDS
                    ( if v-curr-r-b = {&r-b-base}
                      then ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-base )
                      else ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-rubl )
                    )                                               @ doc-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                    string( string( ( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ) /
                                           ( ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc ) ) * 100, "->>>9.9" ) + "%" )
                                    @ UpFact
                    Delt .
                UNDERLINE goods.gds-name gds-dtl.fact-qnty sum-no-NDS obj-sum UpFact .
                DOWN 2 .
            end.
END.                  /* FOR EACH price-list WHERE ... */

HIDE FRAME BottomFrame .

if v-curr-r-b = {&r-b-base}
then do:
    run rep/wp.p ( input p-mainmenu-handle, input absolute( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
end.
else do:
    run rep/wp-rub.p ( input absolute( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
end.

PUT SPACE(10) "Всего  " ( ACCUM COUNT bar-code.b-code ) format ">>>>9"
    " наименований." format "X(15)"
    SKIP(1)
    SPACE(10)
    string( "Сумма цен по объекту составила : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", в том числе налог с продаж : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * {&SLT-calc-ov} ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", НДС : "
               + trim( string( ACCUM TOTAL ( gds-dtl.fact-qnty * VAT-gds ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
              ) format "X(126)"
    skip(1)
    space(10) "Разница между суммой в продажных ценах по объекту и суммой в ценах документа без НДС составила: "
               + trim( string( v-sum-sale - v-sum-cost-without-vat, "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
                                                        format "X(126)"
    skip(1)
    space(10) string( "Торговая наценка составила : "
               + trim( string( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
              ) format "X(126)"
    SKIP(1)
    .

if line-counter + 4 > page-size then
    PAGE .

PUT SPACE(10)
        ( if trim(propis) begins trim( abbr ) then string( "0 " + propis ) else propis )
        format "X(120)" SKIP(2).

PUT SPACE(20) "Зав. складом/Зав. секцией : " format "X(30)" SKIP.

output CLOSE.
{ rep/q-print.i 8}