block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-16a.p $
$Archive: rep/torg-16a.p $

Печатные формы. Торг-16 для списания.

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-16a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-16a.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-16 для списания.".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ rep/r-cliprp.i def    }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ str/trdcalib.i        }
{ rep/torgconf.i        }
{ str/in-vatp.i def     }
{ str/getctxtp.i def    }

&scop P1-X 198
&scop P1-X0 196 /* длина внутренней линии = {&P2-X} - 2*/
&scop P1-X1-X 89 /* длина линии от начала 5-й колонки до начала 11-й */
&scop P1-C2-S 8
&scop P1-C3-S 26
&scop P1-C4-S 66
&scop P1-C5-S 71
&scop P1-C6-S 83
&scop P1-C7-S 98
&scop P1-C8-S 116
&scop P1-C9-S 128
&scop P1-C10-S 143
&scop P1-C11-S 161
&scop P1-E 198

define stream Out-stream.

define variable p-price-type    as character      no-undo.

define shared variable PrintScale      as logical                   no-undo.
define shared variable CostPrice       as logical                   no-undo.

define variable v-base-code     as integer                          no-undo.

define variable rootnode_code   as integer                          no-undo.

define variable v-line-counter     as integer                          no-undo.
define variable Prv-line-counter   as integer                          no-undo.

define variable s1              as character                        no-undo.
define variable s2              as character                        no-undo.

define variable Node_Code       like gds-prt.upper-code             no-undo.

define variable v-artic                 as character      no-undo.
define variable v-gds-name              as character      no-undo.
define variable v-parts-qnty            as decimal        no-undo.
define variable v-parts-price           as decimal        no-undo.
define variable v-parts-sum-price       like ot-line.sum-base               no-undo.
define variable v-qnty                  as decimal        no-undo.
define variable v-price                 as decimal        no-undo.
define variable v-sum-price           like ot-line.sum-base               no-undo.
define variable v-void                  as character      no-undo.
define variable price-Vat               as decimal        no-undo.
define variable v-old-price             as decimal        no-undo.
define variable v-old-price-Vat         as decimal        no-undo.
define variable v-prices-are-different  as logical        no-undo.

define variable stoim-Vat       like ot-line.VAT-base               no-undo.

define variable parts-cost      like ot-line.sum-base               no-undo.
define variable parts-Vat       like ot-line.VAT-base               no-undo.
define variable v-reason        as character                        no-undo. /*Причины списания. Должны браться из trn-doc.PS,*/
                                                                     /*если первый символ не равен "@"*/
define variable prt-tqnty       like ot-line.fact-qnty              no-undo.
define variable prt-stoim       like ot-line.sum-base               no-undo.
define variable prt-stoim-Vat   like ot-line.VAT-base               no-undo.

define variable Pg-tqnty        like ot-line.fact-qnty      init 0  no-undo.
define variable Pg-stoim        like ot-line.sum-base       init 0  no-undo.
define variable Pg-stoim-Vat    like ot-line.VAT-base       init 0  no-undo.
define variable PrevPage        as int      init 0                  no-undo.

define variable stoim-totl      like ot-line.sum-base               no-undo.

define variable PrtName         as character                        no-undo.

define variable OKEI            as character                        no-undo.
define variable tb-code         as character                        no-undo.
define variable qnty-pl         like ot-line.fact-qnty              no-undo.
define variable mass-b          as decimal  decimals 10             no-undo.
define variable mass-n          as decimal  decimals 10             no-undo.
define variable gds-PS          as character                        no-undo.
define variable date-in         as date                             no-undo.

define variable sym1 as character init ":" no-undo.
define variable sym2 as character init ":" no-undo.
define variable sym3 as character init ":" no-undo.
define variable sym4 as character init ":" no-undo.
define variable sym5 as character init ":" no-undo.
define variable sym6 as character init ":" no-undo.
define variable sym7 as character init ":" no-undo.
define variable sym8 as character init ":" no-undo.
define variable sym9 as character init ":" no-undo.
define variable sym10 as character init ":" no-undo.
define variable sym11 as character init ":" no-undo.
define variable sym12 as character init ":" no-undo.
define variable sym13 as character init ":" no-undo.
define variable sym14 as character init ":" no-undo.
define variable sym15 as character init ":" no-undo.

define variable v-line-string                as character           no-undo.
define variable v-underline-string             as character           no-undo.

define variable v-unit-base            as character           no-undo.
define variable val-str             as character           no-undo.
define variable v-doc-code           like trn-doc.doc-code  no-undo.
define variable v-doc-date-string   as character           no-undo.
define variable v-host-code         as integer             no-undo.
define variable v-main-boss         as character           no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define buffer t-doc         for trn-doc.
define buffer b-trn-doc     for trn-doc.
define buffer OurObject     for clients.
define buffer buf_firm      for firm.

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
run torgconf-read in this-procedure (
      input "torg16a"
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.

assign
    v-line-string = fill("-", 230)
    v-underline-string = fill("_", 230)
.
{ rep/torg-16a.i def }
if v-torgconf-outnum = yes
then do:
    assign
        v-doc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-code = t-doc.doc-code
    .
end.
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> {&fact}
                            then string( t-doc.doc-date,  "99/99/9999" )
                            else string( t-doc.fact-date, "99/99/9999" )
                            )
    .
end.
find first OurObject no-lock
     where OurObject.obj-type = t-doc.obj-type
       and OurObject.obj-code = t-doc.obj-code
no-error.

/*run r-qdocs.w( input rec_id, output PrintRubl, output CostPrice, output PrintScale).*/

/*if PrintRubl = ? and CostPrice = ? and PrintScale = ?*/
/*then return.*/

{ gbl/basecode.i
  t-doc.host-code
  v-base-code
}

find first currency no-lock
     where currency.curr-code = v-base-code
no-error.

assign val-str = ( if PrintRubl then "{&abbr_rublyah}" else (if available currency then currency.curr-abbr else "?") ) .

if session:set-wait-state("compiler") then.
{ cmp/open-out.i stream Out-stream " " {&LS_PS_A4} }

form header
    v-line-string format "X(198)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-stream frame Bottomframe .

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.
find first buf_firm no-lock
     where buf_firm.firm-code = clients.obj-code
.
assign
    v-main-boss = buf_firm.director
.
put stream out-stream
    "Наименование организации:   "
            clients.obj-name           format "X(100)"
            "УТВЕРЖДАЮ"                                at 180
    skip "Генеральный директор"                     at 173
    skip "Наименование структурного подразделения:   "
            OurObject.obj-name         format "X(60)"
            fill("_", 40)              format "X(40)"  at 129
            "/ "
            v-main-boss           format "X(26)"
            " /"
    skip(1)
    skip fill("_", 38)              format "X(38)"  at 161
    skip ": Номер документа : Дата составления :"   at 161
    skip "АКТ"                                      at 60
         fill("_", 38)              format "X(38)"  at 161
    skip "о списании материалов"                    at 50
            ": "                                       at 161
            t-doc.doc-code format "X(15)"
            " :   "
            t-doc.doc-date format "99/99/9999"
            "     :"
    skip fill("_", 38)              format "X(38)"  at 161
.
run write-header in this-procedure (
    input yes
).
/*---START--------- Списание по товарам документа ---------------------*/
form with frame f-doc .

assign v-line-counter = 1.
for each doc-line no-lock
   where doc-line.doc-code = t-doc.doc-code
break by doc-line.artic
:
    find first goods no-lock
         where goods.prod-type = doc-line.prod-type
           and goods.prod-code = doc-line.prod-code
           and goods.artic = doc-line.artic
    .
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code
    .
    { str/in-vatp.i calc doc-line. t-doc. g }
    assign
        price-Vat = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
    .
    if price-Vat = ? then assign price-Vat = 0 .
    assign
        v-price = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc ) - price-Vat
    .
    if gds-prt.node-name <> {&empty-scale}
    and v-cntxp-doc-prt = yes
    then do:     /* Т.е. не пустая шкала */
            if PrintScale
            then do:
                if v-line-counter <> 1
                then do:
                    put stream out-stream
                        skip ":" v-line-string format "X({&P1-X0})" ":"
                        skip
                    .
                end.
                display stream Out-stream
                        v-line-counter
                        goods.gds-name @ v-gds-name
                        goods.artic    @ v-artic
                        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                        with frame f-doc .
                down stream Out-stream 1 with frame f-doc .
                { rep/torg-16a.i no-sum }
            end.
            { gbl/working.i }
            for each gds-dtl no-lock
               where gds-dtl.prod-type = doc-line.prod-type
                 and gds-dtl.prod-code = doc-line.prod-code
                 and gds-dtl.artic = doc-line.artic
                 and gds-dtl.doc-code = doc-line.doc-code
            break by gds-dtl.artic
            :
                find first gds-prt no-lock
                     where gds-prt.node-code = gds-dtl.prt-code
                .
                assign
                    prt-tqnty     =  gds-dtl.fact-qnty
                    prt-stoim     = v-price * prt-tqnty
                    prt-stoim-Vat = price-Vat * prt-tqnty
                .
                accumulate
                    prt-tqnty (total)
                    prt-stoim ( total )
                    prt-stoim-Vat ( total )
                .
                if PrintScale = yes
                then do:
                    find first bar-code no-lock
                         where bar-code.gds-code = goods.gds-code
                           and bar-code.unit-cli = goods.unit-base
                           and bar-code.node-code = gds-dtl.prt-code
                           and bar-code.part-code = ""
                           and bar-code.in-code = ""
                    .
                    assign
                        PrtName = ""
                    .
                    do while available gds-prt:
                        if available gds-prt
                        then do:
                            assign
                                PrtName = "\" + string( gds-prt.node-name, "x(10)" ) + PrtName
                            .
                        end.
                        assign
                            Node_Code = gds-prt.upper-code
                        .
                        find first gds-prt no-lock
                                where gds-prt.node-code = Node_Code
                                and gds-prt.root <> yes
                        no-error.
                    end.
                    display stream Out-stream
                            PrtName         @ v-gds-name
                            goods.unit-base @ v-unit-base
                            prt-tqnty       @ v-parts-qnty
                            v-price         @ v-parts-price
                            prt-stoim       @ v-parts-sum-price
                            prt-tqnty       @ v-qnty
                            v-price
                            prt-stoim       @ v-sum-price
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                    with frame f-doc .
                    down stream Out-stream 1 with frame f-doc .
                    { rep/torg-16a.i prt- }
                end.        /* if PrintScale = yes */
            end.        /*for each gds-dtl ...*/
            assign
                v-qnty      = ( accum total prt-tqnty )
                v-sum-price = ( accum total prt-stoim )
            .
            if not PrintScale
            then do:
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = rootnode_code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                if v-line-counter <> 1
                then do:
                    put stream out-stream
                        skip ":" v-line-string format "X({&P1-X0})" ":"
                        skip
                    .
                end.
                display stream Out-stream
                        v-line-counter
                        goods.gds-name      @ v-gds-name
                        goods.artic         @ v-artic
                        goods.unit-base     @ v-unit-base
                        v-qnty                                                 @ v-parts-qnty
                        v-price             when v-prices-are-different = no   @ v-parts-price
                        v-sum-price                                            @ v-parts-sum-price
                        v-qnty
                        v-price             when v-prices-are-different = no
                        v-sum-price
                        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                        with frame f-doc .
                down stream Out-stream 1 with frame f-doc .
                { rep/torg-16a.i }
            end.        /* if not PrintScale */
    end.            /* не пустая шкала */
    else do:    /* пустая шкала */
            find first gds-dtl no-lock
                 where gds-dtl.doc-code     = doc-line.doc-code
                   and gds-dtl.prod-type    = doc-line.prod-type
                   and gds-dtl.prod-code    = doc-line.prod-code
                   and gds-dtl.artic        = doc-line.artic
                   and gds-dtl.prt-code     = rootnode_code
            .
            assign
                v-qnty      = gds-dtl.fact-qnty
                v-unit-base = goods.unit-base
                v-sum-price = v-price * v-qnty
            .
            if v-line-counter <> 1
            then do:
                put stream out-stream
                    skip ":" v-line-string format "X({&P1-X0})" ":"
                    skip
                .
            end.
            for each parts no-lock
            where parts.obj-type  = t-doc.obj-type
                and parts.obj-code  = t-doc.obj-code
                and parts.artic     = doc-line.artic
                and parts.prod-type = doc-line.prod-type
                and parts.prod-code = doc-line.prod-code
                and parts.out-code  = t-doc.doc-code
            :
                { str/in-vatp.i calc-parts parts. " " g }
                assign
                    v-parts-qnty      = parts.fact-qnty
                    v-parts-price     = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
                                        - ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                    v-parts-sum-price = v-parts-qnty * v-parts-price
                    v-qnty            = v-parts-qnty
                    v-sum-price       = v-parts-qnty * v-price
                .
                display stream Out-stream
                    v-line-counter
                    goods.artic      @ v-artic
                    goods.gds-name   @ v-gds-name
                    v-unit-base
                    v-parts-qnty
                    v-parts-price
                    v-parts-sum-price
                    v-qnty
                    v-price
                    v-sum-price
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                    with frame f-doc .
                down stream Out-stream 1 with frame f-doc .
                { rep/torg-16a.i }

            end.
    end.
    accumulate
        v-qnty (total)
        v-sum-price (total)
    .
    assign
        v-line-counter = v-line-counter + 1
    .
end.        /*for  each doc-line ...*/

if line-counter( Out-stream ) + 12 > page-size( Out-stream )
then do:
    { rep/torg-16a.i itog }
    page stream Out-stream .
end.

hide stream Out-stream frame Bottomframe .

    { rep/torg-16a.i itog }
    display stream Out-stream
        "Итого по всем"             @ v-gds-name
        t-doc.fact-qnty             @ v-qnty
        ( accum total v-sum-price ) @ v-sum-price
        with frame f-doc
    .

/*---END----------- Списание по товарам документа ---------------------*/

put stream Out-stream " " skip.

if PrintRubl then
    run rep/wp-rub.p ( (accum total v-sum-price), output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, (accum total v-sum-price), output s1, output s2 ) .

put stream Out-stream
    string( "Сумма списания: " + caps(s1) ) format "X(198)"
    skip(1)
    skip "Вышеперечисленные материалы израсходованы:"
         v-underline-string format "X(156)"
    skip(1)
    skip v-underline-string format "X(198)"
    skip(1)
    skip "Комиссия в составе:"
    skip "Начальник Управления технического обеспечения:"
         v-underline-string format "X(20)"      at 80
         v-underline-string format "X(30)"      at 103
    skip(1)
    skip "Инженер:"
         v-underline-string format "X(20)"      at 80
         v-underline-string format "X(30)"      at 103
/*    skip(1)*/
/*    skip "Техник-сметчик:"*/
/*         v-underline-string format "X(20)"      at 140*/
/*         v-underline-string format "X(30)"      at 163*/
.
output stream Out-stream close.
{ rep/q-print.i 8}

end.

/*==========================================================================*/
procedure write-header :
do
on error undo, return error
:
define input parameter p-print-line-after   as logical      no-undo.

    put stream out-stream
        skip v-line-string format "X({&P1-X})"
        skip ": N"
            ": Артикул"                          at {&P1-C2-S}
            ": Наименование "                    at {&P1-C3-S}
            ":Ед."                               at {&P1-C4-S}
            ":                Приход "           at {&P1-C5-S}
            ":                Расход "           at {&P1-C8-S}
            ": Объект "                          at {&P1-C11-S}
            ":"                                  at {&P1-E}
        skip ": пп"
            ": Артикул"                          at {&P1-C2-S}
            ": материала "                       at {&P1-C3-S}
            ":изм."                              at {&P1-C4-S}
            ":--------------------------------------------:--------------------------------------------"                          at {&P1-C5-S}
            ": расхода материала "               at {&P1-C11-S}
            ":"                                  at {&P1-E}
        skip ": "
            ": "                                 at {&P1-C2-S}
            ": "                                 at {&P1-C3-S}
            ": "                                 at {&P1-C4-S}
            ": Кол"                              at {&P1-C5-S}
            ": Цена"                             at {&P1-C6-S}
            ": Сумма"                            at {&P1-C7-S}
            ": Кол"                              at {&P1-C8-S}
            ": Цена"                             at {&P1-C9-S}
            ": Сумма"                            at {&P1-C10-S}
            ": "                                 at {&P1-C11-S}
            ":"                                  at {&P1-E}
    .
    if p-print-line-after = yes
    then do:
        put stream out-stream
            skip v-line-string format "X({&P1-X})"
        .
    end.
end.
end procedure. /* write-header */

/*        header*/
/*            string( "Цены и суммы " + (if CostPrice then "(учетные)" else "") + " указаны в " + trim( val-str ) ) format "X(40)"*/
/*            string( "Документ N: " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(50)"*/
/*            ( if t-doc.status_ <> {&fact} then*/
/*                string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )*/
/*            else*/
/*                " " ) at 100 format "X(30)"*/
/*            string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) ) at 180 format "X(13)" skip*/
/*            v-line-string format "X(198)" at 1*/