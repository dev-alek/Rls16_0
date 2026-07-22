block-level on error undo, throw.
/*

$Revision: 504acad51c75, 1685, rls $
$Author: EShklyar $
$Date: Tue Dec 11 10:07:22 2018 +0300 $
$Workfile: orl-aktn.p $
$Archive: rep/orl-aktn.p $

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

define variable vss-revision    as character no-undo init "$Revision: 504acad51c75, 1685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 11 10:07:22 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: orl-aktn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/orl-aktn.p $":U .
define variable vss-description as character no-undo init "Печать акта формирования продажной цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ str/get-pr.i def }
{ cmp/r-pril.i   }
{ str/in-vatp.i def }
{ str/out-vatp.i def }
{ str/trdcalib.i }
{ str/getctxtp.i def }

/*&scop ext-rubl-base {&rb}*/
&scop rate-calc-rubl-base * 1
/*дорожный налог объявим один лишь раз в базовой валюте*/
&scop temp-road-tax {&road-tax-cur}
&glob SLT-calc-ov (price-lst - ~{&road-tax-cur}) * t-doc-line.SLT-pc / (100 + t-doc-line.SLT-pc)
&scop slt-temp {&slt-calc}

do
on error undo, return error
:
define buffer t-doc for ub.trn-doc.
define temp-table t-doc-line no-undo like ub.doc-line.

define variable sum-no-NDS              as decimal     no-undo.
define variable doc-sum                 as decimal     no-undo.
define variable obj-sum                 as decimal     no-undo.
define variable v-tax-sum               as decimal     no-undo. /*Третий налог (road-tax)*/
define variable SLT-sum                 as decimal     no-undo.
define variable VAT-sum                 as decimal     no-undo.
define variable VAT-gds                 as decimal     no-undo.
define variable marg                    as decimal     no-undo.
define variable price-doc               as decimal     no-undo.
define variable price-lst               as decimal     no-undo.
define variable v-sum-sale              as decimal     no-undo.
define variable v-sum-cost-without-vat  as decimal     no-undo.

define variable v-dids          like ub.doc-line-attr.attr-value no-undo.
define variable v-nids          like ub.doc-line-attr.attr-value no-undo.
define variable v-attr-type     as character                  no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable v-expl-name     as character            no-undo.
define variable v-store-man     as character            no-undo.
define variable v-main-boss     as character            no-undo.
define variable v-main-buh      as character            no-undo.

define variable propis          as char                 no-undo.
define variable abbr            as char                 no-undo.
define variable UpFact          as char                 no-undo.
define variable Delt            as char                 no-undo.

define variable Lines_Counter   as int                  no-undo.
define variable Line            as char                 no-undo.

define variable v-rb-is-base        as logical      no-undo.
define variable v-price-rb          as decimal      no-undo.
define variable v-delta-price-rb    as decimal      no-undo.
define variable v-sum-price-rb      as decimal      no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

def var sym1 as char init ":"   no-undo.
def var sym2 as char init ":"   no-undo.
def var tb-code     as char no-undo.

def var tdoc-date    like    ub.trn-doc.doc-date    no-undo.
def var tdoc-code    like ub.trn-doc.doc-code no-undo.

define buffer buf_host_clients  for ub.clients.
define buffer buf_obj_clients   for ub.clients.
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.

DEFINE FRAME Akt
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        ub.gds-dtl.artic column-label "Артикул! " format "X(16)"
        ub.goods.gds-name column-label "Название товара! " format "X(22)"
        ub.gds-dtl.fact-qnty column-label "Количество ! " format ">>>>>>9.<<<"
        price-doc column-label "Цена без!НДС" format ">>>>>>9.99"
        sum-no-NDS column-label "Сумма без!НДС" format "->>>>>>>>9.99"
        doc-sum column-label "Сумма по!докум." format "->>>>>>>>9.99"
        price-lst column-label "Цена по!объекту" format ">>>>>>9.99"
        obj-sum column-label "Сумма по!объекту" format "->>>>>>>>9.99"
        SLT-sum column-label "Налог с!прод." format "->>>>>9.99"
        UpFact column-label "Торговая!наценка" format "X(8)"
        Delt column-label "Процент!разницы" format "X(8)"
        t-doc-line.vat-pc column-label "Ставка!НДС" format ">>9.<<%"
        VAT-sum column-label "Сумма НДС от!прод.цен" format "->>>>>>>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
    HEADER
            cur-time-print() AT 5 format "X(35)"
            "Акт приемки-передачи товаров народного потребления по документу N "
            string( tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) format "X(25)"
            string( (if prod-price then "(Прод. цены на момент печати)" else "" ) ) format "X(31)"
            string( "Страница " + string(PAGE-NUMBER) ) format "X(15)" SKIP
        Line format "X(180)" AT 1
    with width {&DOS_CW} stream-io.

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
{ gbl/rbisbase.i
    v-rb-is-base
}
Line = fill("-", 200).
find first t-doc where recid( t-doc ) = rec_id  no-lock.
assign
    tdoc-date   = t-doc.doc-date
    tdoc-code   = t-doc.doc-code
.
find first buf_host_clients no-lock
     where buf_host_clients.obj-type = {&cmp}
       and buf_host_clients.obj-code = t-doc.host-code
.
find first buf_obj_clients no-lock
     where buf_obj_clients.obj-type = t-doc.obj-type
       and buf_obj_clients.obj-code = t-doc.obj-code
no-error.
case buf_obj_clients.obj-type :
    when {&shop}
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = buf_obj_clients.obj-code
        .
        assign
            v-expl-name = buf_shop.director
            v-store-man = buf_shop.store-man
        .
    end.
    when {&stock}
    then do:
        find first buf_store no-lock
             where buf_store.obj-code = buf_obj_clients.obj-code
        .
        assign
            v-expl-name = buf_store.store-boss
            v-store-man = buf_store.store-man
        .
    end.
end case.
{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-dids}
    v-dids
    v-attr-type
}
{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-nids}
    v-nids
    v-attr-type
}

{ cmp/open-out.i " " " " " " {&LS_PS_A4} }

put
    space(90) buf_host_clients.obj-name format "x(40)" skip(2)
    space(20) "А К Т приемки-передачи товаров народного потребления по документу N " format "x(80)"
        t-doc.doc-code format "x(10)"
        "  от  " t-doc.doc-date format "99.99.9999"
    skip(1)
    space(20) "Основание: накладная поставщика"
    string( "N " + v-nids + " от " + v-dids )
                                    format "X(40)"         at 55
    skip(1)
    space(20) "АГЕНТ : " v-expl-name format "X(40)"
.

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

FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = t-doc.doc-code NO-LOCK ,
        EACH ub.gds-dtl WHERE ub.gds-dtl.doc-code = t-doc.doc-code AND
                                            ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
                                            ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
                                            ub.gds-dtl.artic = ub.doc-line.artic NO-LOCK,
        EACH ub.goods WHERE ub.goods.prod-type = ub.gds-dtl.prod-type AND
                                           ub.goods.prod-code = ub.gds-dtl.prod-code AND
                                           ub.goods.artic = ub.gds-dtl.artic NO-LOCK
            BREAK BY ub.gds-dtl.artic BY ub.gds-dtl.prt-code with FRAME Akt :

       FOR EACH t-doc-line :
          delete t-doc-line.
       END.
       CREATE t-doc-line.
       BUFFER-COPY doc-line TO t-doc-line.
       { gbl/hostcode.i doc-line.obj-type doc-line.obj-code v-host-code }
       
       
       { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} tdoc-date v-host-code doc-line.obj-type doc-line.obj-code v-vat-pc no-error }
       { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code doc-line.obj-type doc-line.obj-code v-slt-pc no-error }
       assign
           t-doc-line.vat-pc = v-vat-pc
           t-doc-line.slt-pc = v-slt-pc
       .
       FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                       AND ub.bar-code.unit-cli = ub.goods.unit-base
                       AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                       AND ub.bar-code.part-code = ""
                       AND ub.bar-code.in-code = ""
                           NO-LOCK no-error.

        if prod-price then
            do:
                { str/get-pr.i calc t-doc.obj-type t-doc.obj-code goods.gds-code bar-code.node-code }
                assign price-lst = gp-price-sale.
            end.
        else
            assign price-lst = gds-dtl.cur-base.

/*        &scop ext-rubl-base {&rb}*/
        if t-doc.doc-type = {&income}
        then do:
            { str/in-vatp.i calc doc-line. t-doc. g }
            if road-tax-rubl-loc = ? then assign road-tax-rubl-loc = 0.
            if road-tax-base-loc = ? then assign road-tax-base-loc = 0.
            assign
                price-doc = (if v-rb-is-base = yes
                            then (price-base-with-tax-loc - vat-base-loc)
                            else (price-rubl-with-tax-loc - vat-rubl-loc) )
                v-tax-sum = (if v-rb-is-base = yes
                            then road-tax-base-loc
                            else road-tax-rubl-loc )
            .
        end.
        else do:
            { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
            assign
                price-doc = ( if v-rb-is-base = yes
                            then price-base-with-tax-sale - vat-rubl-sale
                            else price-rubl-with-tax-sale - vat-rubl-sale
                )
/*              price-doc = gds-dtl.price-{&rb} - {&VAT-calc} */
            .
        end.
        assign
            Vat-gds = ( price-lst - {&SLT-calc-ov} - v-tax-sum) * t-doc-line.vat-pc / ( 100 + t-doc-line.vat-pc )
            marg = price-lst - price-doc - Vat-gds - {&SLT-calc-ov}
        .

        ACCUMULATE bar-code.b-code ( COUNT )
                gds-dtl.fact-qnty ( TOTAL )
                marg * gds-dtl.fact-qnty ( TOTAL )
                gds-dtl.fact-qnty * {&SLT-calc-ov} ( TOTAL )
                gds-dtl.fact-qnty * VAT-gds ( TOTAL )
                ( gds-dtl.fact-qnty * price-lst ) ( TOTAL )
                ( gds-dtl.fact-qnty * price-doc ) ( TOTAL )
/*                ( gds-dtl.fact-qnty * gds-dtl.price-{&rb} ) ( TOTAL )*/
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( TOTAL )
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( TOTAL )
/*                ( ( price-lst - gds-dtl.price-{&rb} ) * gds-dtl.fact-qnty ) ( TOTAL )*/
                ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( TOTAL )
                ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( TOTAL )
        .
        assign
            v-price-rb = ( if v-rb-is-base = yes then gds-dtl.price-base else gds-dtl.price-rubl )
        .
        DISPLAY sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                price-doc
                ( gds-dtl.fact-qnty * price-doc ) @ sum-no-NDS
                ( if v-rb-is-base = yes
                then gds-dtl.fact-qnty * gds-dtl.price-base
                else gds-dtl.fact-qnty * gds-dtl.price-rubl ) @ doc-sum
                price-lst
                ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                ( gds-dtl.fact-qnty * {&SLT-calc-ov} ) @ SLT-sum
                t-doc-line.vat-pc
                ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                string( string( marg / price-doc * 100, "->>>9.9" ) + "%" ) @ UpFact
                string( string( ( price-lst - v-price-rb ) / v-price-rb * 100, "->>>9.9" ) + "%" ) @ Delt
                sym2
        .
        if LAST( gds-dtl.artic )
        then do:
                DOWN 1 .
                PUT Line format "X(180)" SKIP .

                assign
                    v-sum-cost-without-vat = ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc )
                    v-sum-sale             = ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst )
                .
                assign
                    v-sum-price-rb      = ( if v-rb-is-base = yes
                                            then ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-base )
                                            else ACCUM TOTAL ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) )
                    v-delta-price-rb    = ( if v-rb-is-base = yes
                                            then ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-base ) * gds-dtl.fact-qnty ) )
                                            else ( ACCUM TOTAL ( ( price-lst - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ) )
                .
                DISPLAY "  ИТОГО"    @ goods.gds-name
                    ACCUM TOTAL gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc ) @ sum-no-NDS
                    v-sum-price-rb @ doc-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * price-lst ) @ obj-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * {&SLT-calc-ov} ) @ SLT-sum
                    ACCUM TOTAL ( gds-dtl.fact-qnty * VAT-gds ) @ VAT-sum
                    string( string( ( ACCUM TOTAL ( marg * gds-dtl.fact-qnty ) ) /
                                           ( ACCUM TOTAL ( gds-dtl.fact-qnty * price-doc ) ) * 100, "->>>9.9" ) + "%" )
                                    @ UpFact
                    string( string( v-delta-price-rb / v-sum-price-rb * 100, "->>>9.9" ) + "%" )
                                    @ Delt .
                UNDERLINE goods.gds-name gds-dtl.fact-qnty sum-no-NDS obj-sum SLT-sum UpFact .
                DOWN 2 .
        end.
END.                  /* FOR EACH price-list WHERE ... */

HIDE FRAME BottomFrame .

if v-rb-is-base = yes
then do:
    run rep/wp.p (
          input p-mainmenu-handle
        , input ACCUM TOTAL ( ub.gds-dtl.fact-qnty * price-lst )
        , output propis
        , output abbr
    ).
end.        /* if v-rb-is-base = yes */
else do:
    run rep/wp-rub.p (
          input ACCUM TOTAL ( ub.gds-dtl.fact-qnty * price-lst )
        , output propis
        , output abbr
    ).
end.        /* NOT ( if v-rb-is-base = yes ) */

PUT SPACE(10) "Всего  " ( ACCUM COUNT ub.bar-code.b-code ) format ">>>>9"
    " наименований." format "X(15)"
    SKIP(1)
    SPACE(10)
    string( "Сумма цен по объекту составила : "
               + trim( string( ACCUM TOTAL ( ub.gds-dtl.fact-qnty * price-lst ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", в том числе налог с продаж : "
               + trim( string( ACCUM TOTAL ( ub.gds-dtl.fact-qnty * {&SLT-calc-ov} ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
               + ", НДС : "
               + trim( string( ACCUM TOTAL ( ub.gds-dtl.fact-qnty * VAT-gds ), "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
              ) format "X(126)"
    skip(1)
    space(10) "Разница между суммой в продажных ценах по объекту и суммой в ценах документа без НДС составила: "
               + trim( string( v-sum-sale - v-sum-cost-without-vat, "->>>,>>>,>>>,>>>,>>9.99" ) )
               + " " + trim( abbr )
                                                        format "X(126)"
    skip(1)

.

if line-counter + 4 > page-size then
    PAGE .

PUT
    space(10) string( "ИТОГО по акту передано товаров на сумму  "
            + CAPS( ( if trim(propis) begins trim( abbr ) then string( "0 " + propis ) else propis ) ) )
                                                        format "X(126)"
    skip(1)
.
run get-boss-and-buh in this-procedure (
      input t-doc.obj-type
    , input t-doc.obj-code
    , output v-main-boss
    , output v-main-buh
).
PUT
    space(20) "От владельца : "
              "От эксплуататора : "  at 80
              v-store-man  format "X(20)"
    skip (1)
    space(20) "Руководитель предприятия:                                             / "
              string( v-main-boss  + " /" ) format "X(40)"
    skip (1)
    space(20) "Главный бухгалтер:                                                    / "
              string( v-main-buh  + " /" ) format "X(40)"
.
output CLOSE.
{ rep/q-print.i 8}

end.

/*==========================================================================*/
procedure get-boss-and-buh :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define output parameter p-main-boss as character    no-undo.
define output parameter p-main-buh  as character    no-undo.

    define variable v-host-code     as integer       no-undo.

    define buffer buf_clients       for ub.clients.
    define buffer buf_firm          for ub.firm.
    define buffer buf_sysconf       for ub.sysconf.

    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    .
    find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
    .
    assign
        p-main-boss = buf_firm.director
    .
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-host-code
    .
    assign
        p-main-buh  = buf_sysconf.snr-accnt
    .
end.
end procedure. /* get-boss-and-buh */