block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-16.p $
$Archive: rep/torg-16.p $

Печатные формы. Торг-16 для списания.

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:
    rec_id          as recid        - recid складского документа (trn-doc)
    p-mode           as character   - 'suz' - нет первой таблички и основание - "Потеря первоначального качества"

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
define variable vss-workfile    as character no-undo init "$Workfile: torg-16.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-16.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-16 для списания ".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ rep/r-cliprp.i def    }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ rep/torgconf.i        }
{ str/getctxtp.i def    }

define stream Out-stream.

define buffer t-doc          for trn-doc.
define buffer b-trn-doc      for trn-doc.
define buffer OurObject      for clients.
define buffer buf_trn-reason for ub.trn-reason .

define shared variable PrintScale      as logical                   no-undo.
define shared variable CostPrice       as logical                   no-undo.
define shared variable no-vat          as logical                   no-undo.

define variable v-base-code     as integer                          no-undo.

define variable rootnode_code   as integer                          no-undo.

define variable LineCounter     as integer                          no-undo.
define variable PrLineCounter   as integer                          no-undo.

define variable s1              as character                        no-undo.
define variable s2              as character                        no-undo.

define variable Node_Code       like gds-prt.upper-code             no-undo.

define variable tqnty           like ot-line.fact-qnty              no-undo.
define variable price           like ot-line.sum-base               no-undo.
define variable price-Vat       like ot-line.VAT-base               no-undo.
define variable v-old-price     like ot-line.sum-base               no-undo.
/*define variable v-old-price-Vat like ot-line.VAT-base               no-undo.*/
define variable v-prices-are-different as logical                   no-undo.

define variable stoim           like ot-line.sum-base               no-undo.
/*define variable stoim-Vat       like ot-line.VAT-base               no-undo.*/

define variable parts-cost      like ot-line.sum-base               no-undo.
define variable parts-Vat       like ot-line.VAT-base               no-undo.
define variable v-reason        as character                        no-undo. /*Причины списания. Должны браться из trn-doc.PS,*/
                                                                     /*если первый символ не равен "@"*/
define variable prt-tqnty       like ot-line.fact-qnty              no-undo.
define variable prt-stoim       like ot-line.sum-base               no-undo.
/*define variable prt-stoim-Vat   like ot-line.VAT-base               no-undo.*/

define variable Pg-tqnty        like ot-line.fact-qnty      init 0  no-undo.
define variable Pg-stoim        like ot-line.sum-base       init 0  no-undo.
/*define variable Pg-stoim-Vat    like ot-line.VAT-base       init 0  no-undo.*/
define variable PrevPage        as int      init 0                  no-undo.

define variable stoim-totl      like ot-line.sum-base               no-undo.

define variable PrtName         as character                        no-undo.
define variable PrtNameXL         as character                        no-undo.

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

define variable Line                as character           no-undo.
define variable UndLine             as character           no-undo.

define variable unit-str            as character           no-undo.
define variable val-str             as character           no-undo.
define variable tdoc-code           like trn-doc.doc-code  no-undo.
define variable v-doc-date-string   as character           no-undo.
define variable v-host-code         as integer             no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

{ gbl/paramls.i         }
{ rep/torg16xl.i        }

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
run torgconf-read in this-procedure (
      input "torg16"
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

{ rep/torg-16.i def }
{ rep/torg-16.i def no-vat- }
assign
    Line = fill("-", 230)
    UndLine = fill("_", 230)
.
if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        tdoc-code = t-doc.doc-code
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
run torg16xl-init.
find first currency no-lock
     where currency.curr-code = v-base-code
no-error.

assign val-str = ( if PrintRubl then "{&abbr_rublyah}" else (if available currency then currency.curr-abbr else "?") ) .

if session:set-wait-state("compiler") then.
{ cmp/open-out.i stream Out-stream " " {&LS_PS_A4} }

form header
    Line format "X(198)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-stream frame Bottomframe .

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.

{ rep/r-cliprp.i }
if v-torgconf-outappr = yes
then do:
    put stream out-stream
        "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137
    .
end.
put stream Out-stream
    space(5) Line format  "X(19)" at 180 skip
    space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
    space(5) "Форма по ОКУД" format "X(14)" at 166 "| " at 180 "0330216" "|" at 198 skip
    space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + caps( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" at 172 "| " at 180 t-okpo format "X(16)" "|" at 198 skip
    space(5) string( caps( OurObject.obj-name ) + " (" + string(OurObject.obj-code) + ")" ) format "X(160)" "| " at 180  "|" at 198 skip
    space(5) "Вид деятельности по ОКДП" format "X(25)" at 155 "| " at 180 "|" at 198 skip
    space(5) "Основание для составления акта:"
.
    put stream Out-stream
        string( "                    приказ   распоряжение " ) format "X(129)"
                    "номер" format "X(5)" at 174 "| " at 180 "|" at 198 skip
        space(5) string( "(ненужное зачеркнуть)" ) format "X(21)" at 57
    .
put stream Out-stream
                   "дата" format "X(4)" at 175 "| " at 180 "|" at 198 skip
    space(5) "Вид операции" format "X(12)" at 167 "| " at 180 " списание" format "X(16)" "|" at 198 skip

    space(58) Line format "X(33)" Line format  "X(19)" at 180 skip
    space(58) "|     Номер       |    Дата     |" "УТВЕРЖДАЮ" at 180 skip
    space(58) "|   Документа     | составления |" "Руководитель" at 179 skip
    space(58) Line format "X(33)" UndLine format "X(28)" at 171 skip
    space(54) string( "АКТ | "
                                + string( tdoc-code , "X(16)") + " | "
                                + v-doc-date-string + " | "
                                + (if t-doc.status_ <> {&fact} then string( "(" + caps(t-doc.status_) + ")" ) else "")
                                ) format "X(100)" "должность" at 180 skip
    space(58) Line format "X(33)" "_______  ___________________" at 171 skip
    space(46) "О СПИСАНИИ ТОВАРОВ" format "X(50)" "подпись  расшифровка подписи" at 171 skip
    "<<    >>  ______________года" at 171 skip
.
run torg16xl-write-cell-data ( input {&torg16xl-h_obj} , input ( caps (OurObject.obj-name) + " (" + string (OurObject.obj-code) + ")" ) ) .
run torg16xl-write-cell-data ( input {&torg16xl-h_orgname} ,
                               input string( "{&abbr_inn_allshift} " + t-inn + " " + caps( clients.obj-name ) +
                                  " (" + string(clients.obj-code) + ")"
                                  + t-addres + t-phone) )
.
run torg16xl-write-cell-data ( input {&torg16xl-h_t-okpo} , input t-okpo ) .
run torg16xl-write-cell-data ( input {&torg16xl-h_TDocCode} , input trim ( tdoc-code ) ) .
run torg16xl-write-cell-data ( input {&torg16xl-h_DocDate} , input v-doc-date-string ) .

run torg16xl-write-cell-data ( input {&torg16xl-hp_DocInfo} ,
                               input if t-doc.status_ <> {&fact}
                                      then string( tdoc-code + " от " + v-doc-date-string + "Статус документа: " +
                                                   t-doc.status_ + " " + string(t-doc.flag_, "+/-")
                                                 )
                                      else string( tdoc-code + " от " + v-doc-date-string )
                              )
.
run torg16xl-write-cell-data ( input {&torg16xl-hp_DocInfo3} ,
                               input if t-doc.status_ <> {&fact}
                                      then string( tdoc-code + " от " + v-doc-date-string + "Статус документа: " +
                                                   t-doc.status_ + " " + string(t-doc.flag_, "+/-")
                                                 )
                                      else string( tdoc-code + " от " + v-doc-date-string )
                              )
.
run torg16xl-write-cell-data ( input {&torg16xl-hp_DocInfo2} ,
                               input if CostPrice
                                      then "Цены и суммы (учетные) указаны в " + trim( val-str )
                                      else "Цены и суммы указаны в " + trim( val-str )
                             )
.
if no-vat then do:
    form with frame no-vat-doc-lst .
    run torg16xl-write-cell-data ( input {&torg16xl-hp_VAT1} , input "без НДС" ) .
    run torg16xl-write-cell-data ( input {&torg16xl-hp_VAT2} , input "без НДС" ) .
end.
else do:
    form with frame doc-lst.
    run torg16xl-write-cell-data ( input {&torg16xl-hp_VAT1} , input "с НДС" ) .
    run torg16xl-write-cell-data ( input {&torg16xl-hp_VAT2} , input "с НДС" ) .
end.

assign
    LineCounter = 1
.

for each doc-line no-lock
where doc-line.doc-code = t-doc.doc-code
break by doc-line.artic
:
  find first ub.goods no-lock where ub.goods.artic = doc-line.artic and
    ub.goods.prod-code = doc-line.prod-code and
    ub.goods.prod-type = doc-line.prod-type no-error .
      
  find first ub.doc-line-attr no-lock where ub.doc-line-attr.doc-code = t-doc.doc-code and
    ub.doc-line-attr.gds-code = ub.goods.gds-code and
    ub.doc-line-attr.attr-code = "reasonSpisan" no-error .
  if available (ub.doc-line-attr) then 
  do:
    for first buf_trn-reason no-lock where buf_trn-reason.reason-code = integer(ub.doc-line-attr.attr-value):
      v-reason = buf_trn-reason.reason-name .
    end.
    end.
      else v-reason = "" .
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
            parts-cost = parts.fact-qnty * ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            parts-Vat = parts.fact-qnty * ( if PrintRubl then vat-rubl-loc else vat-base-loc )
        .
        if no-vat then do:
            assign
                parts-cost = parts-cost - parts-Vat
            .
        end.
        find first b-trn-doc no-lock
            where b-trn-doc.doc-code = parts.in-code
        no-error.
        if available b-trn-doc then assign date-in = b-trn-doc.fact-date.

        accumulate
            parts.fact-qnty (total)
            parts-cost (total)
/*                parts-Vat (total)*/
        .
        if no-vat then do:
            display stream Out-stream
                    date-in when available b-trn-doc
                    parts.fact-date
                    parts.in-code
                    b-trn-doc.fact-date when available b-trn-doc
                    v-reason            when v-torgconf-outprim = no
                    sym1 sym3 sym4 sym5 sym6 sym10 sym11
                    with frame no-vat-doc-lst.
            down stream Out-stream 1 with frame no-vat-doc-lst .
            run torg16xl-sheet1-write-line-data (  input if available b-trn-doc then string ( date-in, "99/99/9999" ) else ""
                                                  , input string ( parts.fact-date, "99/99/9999" )
                                                  , input parts.in-code
                                                  , input if available b-trn-doc then string ( b-trn-doc.fact-date, "99/99/9999" ) else ""
                                                  , input if v-torgconf-outprim = no then v-reason else "")
            .
        end.
        else do:
            display stream Out-stream
                    date-in when available b-trn-doc
                    parts.fact-date
                    parts.in-code
                    b-trn-doc.fact-date when available b-trn-doc
                    v-reason            when v-torgconf-outprim = no
                    sym1 sym3 sym4 sym5 sym6 sym10 sym11
                    with frame doc-lst.
            down stream Out-stream 1 with frame doc-lst .
            run torg16xl-sheet1-write-line-data ( input if available b-trn-doc then string ( date-in, "99/99/9999" ) else ""
                                                , input string ( parts.fact-date, "99/99/9999" )
                                                , input parts.in-code
                                                , input if available b-trn-doc then string ( b-trn-doc.fact-date, "99/99/9999" ) else ""
                                                , input if v-torgconf-outprim = no then v-reason else "")
            .
        end.
        assign
            PrLineCounter = LineCounter
        .
    end.
    assign LineCounter = LineCounter + 1.
end.
put stream Out-stream Line format "X(198)" skip.
/*put stream Out-stream " " skip.*/
/*---START--------- Списание по товарам документа ---------------------*/
if no-vat then do:
    form with frame no-vat-f-doc .
end.
else do:
    form with frame f-doc .
end.

assign LineCounter = 1.
for  each doc-line no-lock
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

    if CostPrice
    then do:
        { str/in-vatp.i calc doc-line. t-doc. g }
        assign
            price = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            price-Vat = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
        .
        if price-Vat = ? then assign price-Vat = 0 .
        if no-vat then do:
            assign
                price = price - price-Vat
            .
        end.
    end.

    if ( ( gds-prt.node-name <> {&empty-scale} ) and v-cntxp-doc-prt = yes )
    then do:     /* Т.е. не пустая шкала */
            if PrintScale
            then do:
                if no-vat then do:
                    display stream Out-stream
                            goods.gds-name
                            sym1 sym4 sym5 sym6 sym7 sym8 sym10
                            sym11 sym12 sym13 sym15
                            with frame no-vat-f-doc .
                    down stream Out-stream 1 with frame no-vat-f-doc .
                    { rep/torg-16.i no-sum no-vat- }
                    run torg16xl-sheet2-write-line-data (
                                                          input goods.gds-name ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input ""
                                                          )
                        .
                end.
                else do:
                    display stream Out-stream
                            goods.gds-name
                            sym1 sym4 sym5 sym6 sym7 sym8 sym10
                            sym11 sym12 sym13 sym15
                            with frame f-doc .
                    down stream Out-stream 1 with frame f-doc .
                    { rep/torg-16.i no-sum }
                    run torg16xl-sheet2-write-line-data (
                                                          input goods.gds-name ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input "" ,
                                                          input ""
                                                          )
                    .
                end.
            end.
            { gbl/working.i }
            for each gds-dtl no-lock
               where gds-dtl.prod-type = doc-line.prod-type
                 and gds-dtl.prod-code = doc-line.prod-code
                 and gds-dtl.artic = doc-line.artic
                 and gds-dtl.doc-code = doc-line.doc-code
            break by gds-dtl.artic
            :
                find gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock.

                if not CostPrice
                then do:
                    { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
                    assign
                        price = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                        price-Vat = ( if PrintRubl then vat-rubl-sale else vat-base-sale )
                    .
                    if first (gds-dtl.artic)
                    then do:
                        assign
                            v-prices-are-different  = no
                            v-old-price             = price
/*                            v-old-price-Vat         = price-Vat*/
                        .
                    end.
                    else do:
                        if v-prices-are-different  = no
                            and price <> v-old-price
                        then do:
                            assign
                                v-prices-are-different = yes
                            .
                        end.
                        else do:
                            assign
                                v-old-price             = price
/*                                v-old-price-Vat         = price-Vat*/
                            .
                        end.
                    end.
                    if no-vat then do:
                        assign
                            price = price - price-Vat
                        .
                    end.

                end.   /* if not CostPrice */

                assign
                    prt-tqnty =  gds-dtl.fact-qnty
                    prt-stoim = price * prt-tqnty
/*                    prt-stoim-Vat = price-Vat * prt-tqnty*/
                .
                accumulate
                    prt-tqnty (total)
                    prt-stoim ( total )
/*                    prt-stoim-Vat ( total )*/
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
                                PrtNameXL = "\" + gds-prt.node-name + PrtNameXl
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
                    if no-vat then do:
                        display stream Out-stream
                                PrtName @     goods.gds-name
                                string( bar-code.b-code ) @ tb-code
                                goods.unit-base
                                prt-tqnty @ tqnty
                                price
                                prt-stoim @ stoim
                                sym1 sym4 sym5 sym6 sym7 sym8 sym10
                                sym11 sym12 sym13 sym15
                                with frame no-vat-f-doc .
                        down stream Out-stream 1 with frame no-vat-f-doc .
                        { rep/torg-16.i prt- no-vat- }
                        run torg16xl-sheet2-write-line-data (
                                                              input /*"Группа товаров: " +*/ PrtNameXL /*goods.gds-name ,*/ ,
                                                              input string( bar-code.b-code ) ,
                                                              input goods.unit-base ,
                                                              input "" ,
                                                              input string ( prt-tqnty ) ,
                                                              input "" ,
                                                              input "" ,
                                                              input "" ,
                                                              input string ( price ) ,
                                                              input string ( prt-stoim ) ,
                                                              input ""
                                                              )
                        .
                    end.
                    else do:
                        display stream Out-stream
                                PrtName @     goods.gds-name
                                string( bar-code.b-code ) @ tb-code
                                goods.unit-base
                                prt-tqnty @ tqnty
                                price
                                prt-stoim @ stoim
                                sym1 sym4 sym5 sym6 sym7 sym8 sym10
                                sym11 sym12 sym13 sym15
                                with frame f-doc .
                        down stream Out-stream 1 with frame f-doc .
                        { rep/torg-16.i prt- }
                        run torg16xl-sheet2-write-line-data (
                                                              input /*"Группа товаров: " +*/ PrtNameXL /*goods.gds-name ,*/ ,
                                                              input string( bar-code.b-code ) ,
                                                              input goods.unit-base ,
                                                              input "" ,
                                                              input string ( prt-tqnty ) ,
                                                              input "" ,
                                                              input "" ,
                                                              input string ( price ) ,
                                                              input string ( prt-stoim ) ,
                                                              input ""
                                                              )
                        .
                    end.
                end.        /* if PrintScale = yes */
            end.        /*for each gds-dtl ...*/

            assign
                tqnty = ( accum total prt-tqnty )
                stoim = ( accum total prt-stoim )
/*                stoim-Vat = ( accum total prt-stoim-Vat )*/
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
                    if no-vat then do:
                        display stream Out-stream
                                goods.gds-name
                                string( bar-code.b-code ) @ tb-code
                                goods.unit-base
                                tqnty
                                price               when v-prices-are-different = no
                                stoim
                                sym1 sym4 sym5 sym6 sym7 sym8 sym10
                                sym11 sym12 sym13 sym15
                                with frame no-vat-f-doc .
                        down stream Out-stream 1 with frame no-vat-f-doc .
                        { rep/torg-16.i " " no-vat-}
                        run torg16xl-sheet2-write-line-data (
                                                              input goods.gds-name ,
                                                              input string( bar-code.b-code ) ,
                                                              input goods.unit-base ,
                                                              input "" ,
                                                              input string ( tqnty ) ,
                                                              input "" ,
                                                              input "" ,
                                                              input if v-prices-are-different = no then string ( price ) else "" ,
                                                              input string ( stoim ) ,
                                                              input ""
                                                             )
                        .
                    end.
                    else do:
                        display stream Out-stream
                                goods.gds-name
                                string( bar-code.b-code ) @ tb-code
                                goods.unit-base
                                tqnty
                                price               when v-prices-are-different = no
                                stoim
                                sym1 sym4 sym5 sym6 sym7 sym8 sym10
                                sym11 sym12 sym13 sym15
                                with frame f-doc .
                        down stream Out-stream 1 with frame f-doc .
                        { rep/torg-16.i }
                        run torg16xl-sheet2-write-line-data (
                                                              input goods.gds-name ,
                                                              input string( bar-code.b-code ) ,
                                                              input goods.unit-base ,
                                                              input "" ,
                                                              input string ( tqnty ) ,
                                                              input "" ,
                                                              input "" ,
                                                              input if v-prices-are-different = no then string ( price ) else "" ,
                                                              input string ( stoim ) ,
                                                              input ""
                                                             )
                        .
                    end.
            end.        /* if not PrintScale */
    end.            /* не пустая шкала */
    else do:    /* пустая шкала */

            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = rootnode_code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
            .

            if not CostPrice
            then do:
                    { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
                    assign
                        price = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                        price-Vat = ( if PrintRubl then vat-rubl-sale else vat-base-sale )
                    .
                    if no-vat then do:
                        assign
                            price = price - price-Vat
                        .
                    end.
            end.

            assign
                tqnty = gds-dtl.fact-qnty
                unit-str = goods.unit-base
                stoim = price * tqnty
/*                stoim-Vat = price-Vat * tqnty*/
            .

            if no-vat then do:
                display stream Out-stream
                    goods.gds-name
                    string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    tqnty
                    price
                    stoim
                    sym1 sym4 sym5 sym6 sym7 sym8 sym10
                    sym11 sym12 sym13 sym15
                    with frame no-vat-f-doc .
                down stream Out-stream 1 with frame no-vat-f-doc .
                { rep/torg-16.i " " no-vat-}
                run torg16xl-sheet2-write-line-data (
                                                      input goods.gds-name ,
                                                      input string( bar-code.b-code ) ,
                                                      input unit-str ,
                                                      input "" ,
                                                      input string ( tqnty ) ,
                                                      input "" ,
                                                      input "" ,
                                                      input string ( price ) ,
                                                      input string ( stoim ) ,
                                                      input ""
                                                      )
                .
            end.
            else do:
                display stream Out-stream
                    goods.gds-name
                    string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    tqnty
                    price
                    stoim
                    sym1 sym4 sym5 sym6 sym7 sym8 sym10
                    sym11 sym12 sym13 sym15
                    with frame f-doc .
                down stream Out-stream 1 with frame f-doc .
                { rep/torg-16.i }
                run torg16xl-sheet2-write-line-data (
                                                      input goods.gds-name ,
                                                      input string( bar-code.b-code ) ,
                                                      input unit-str ,
                                                      input "" ,
                                                      input string ( tqnty ) ,
                                                      input "" ,
                                                      input "" ,
                                                      input string ( price ) ,
                                                      input string ( stoim ) ,
                                                      input ""
                                                      )
                .
            end.
    end.

    accumulate
        tqnty (total)
        stoim (total)
/*        stoim-Vat (total)*/
        .
    assign LineCounter = LineCounter + 1.
end.        /*for  each doc-line ...*/

if line-counter( Out-stream ) + 17 > page-size( Out-stream )
then do:
    if no-vat then do:
        { rep/torg-16.i itog no-vat- }
    end.
    else do:
        { rep/torg-16.i itog }
    end.
    page stream Out-stream .
end.

hide stream Out-stream frame Bottomframe .

if no-vat then do:
    { rep/torg-16.i itog no-vat- }
    display stream Out-stream
        "Итого по всем" @ goods.gds-name
        t-doc.fact-qnty @ tqnty
        ( accum total stoim ) @ stoim
/*        ( accum total stoim-Vat ) @ stoim-Vat*/
        with frame no-vat-f-doc .
 end.
 else do:
    { rep/torg-16.i itog}
    display stream Out-stream
        "Итого по всем" @ goods.gds-name
        t-doc.fact-qnty @ tqnty
        ( accum total stoim ) @ stoim
/*        ( accum total stoim-Vat ) @ stoim-Vat*/
        with frame f-doc .
 end.
run torg16xl-write-cell-data ( input {&torg16xl-sheet2-it-Tqnty} , input string ( t-doc.fact-qnty ) ) .
run torg16xl-write-cell-data ( input {&torg16xl-sheet2-it-parts-Stoimt} , input string ( accum total stoim ) ) .
/*run torg16xl-write-cell-data ( input {&torg16xl-sheet2-it-parts-StoimVat} , string ( accum total stoim-Vat ) ) .*/

/*---END----------- Списание по товарам документа ---------------------*/

put stream Out-stream " " skip.

if PrintRubl then
    run rep/wp-rub.p ( (accum total stoim), output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, (accum total stoim), output s1, output s2 ) .
run torg16xl-write-cell-data ( input {&torg16xl-f_sumstr}, s1  ) .
put stream Out-stream
    string( "Сумма списания: " + caps(s1) ) format "X(198)" skip
    string( "Все члены комиссии предупреждены об ответственности за подписание акта, " +
               "содержащего данные, несоответствующие действительности." ) format "X(198)" skip
    string( "Председатель комиссии " ) format "X(31)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(29)" skip
    space(35)
        string( "должность" ) format "X(19)" string( " " ) format "X(1)"
        string( "подпись" ) format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)" skip
    string( "Члены комиссии " ) format "X(31)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(29)" skip
    space(35)
        string( "должность" ) format "X(19)" string( " " ) format "X(1)"
        string( "подпись" ) format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)" skip
    space(31)
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(29)" skip
    space(35)
        string( "должность" ) format "X(19)" string( " " ) format "X(1)"
        string( "подпись" ) format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)" skip
    string( "Материально ответственное лицо " ) format "X(31)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(19)" string( " " ) format "X(1)"
        UndLine format "X(29)" skip
    space(35)
        string( "должность" ) format "X(19)" string( " " ) format "X(1)"
        string( "подпись" ) format "X(19)" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X(29)" skip
    string( "Решение руководителя " ) format "X(31)" skip
    string( "Cтоимость списанного товара отнести на счет " + UndLine ) format "X(198)" skip
    space(80) string( "указать источник (себестоимость, прибыль, материально ответственное лицо и т.д.)" ) format "X(83)" skip
.
run torg16xl-close.
output stream Out-stream close.
{ rep/q-print.i 8}

end.