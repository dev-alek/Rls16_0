block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: avt-akt0.p $
$Archive: rep/avt-akt0.p $

Печать акта автоматической переоценки

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-mode               as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$date: 12.09.03 15:57 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: avt-akt0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/avt-akt0.p $":U .
define variable vss-description as character no-undo init "Печать акта автоматической переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ str/trdcalib.i }
{ str/getctxtp.i def }
{ gbl/getsect.i  def }

def buffer t-doc for trn-doc.

define variable price-doc           as decimal      no-undo.
define variable doc-sum             as decimal      no-undo.
define variable obj-sum             as decimal      no-undo.

define variable propis              as character    no-undo.
define variable abbr                as character    no-undo.
define variable Delt                as character    no-undo.

define variable v-single-line       as character    no-undo.

define variable sym1                as character init ":"    no-undo.
define variable sym2                as character init ":"    no-undo.
define variable tb-code             as character             no-undo.

define variable tdoc-date           as date         no-undo.
define variable tdoc-code           as character    no-undo.
define variable v-nids              as character    no-undo.
define variable v-parameter-type    as character    no-undo.

define variable v-rb-is-base        as logical      no-undo.

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
def buffer Our_Host for clients.

{ gbl/rbisbase.i
    v-rb-is-base
}

define frame Akt-base
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(30)"
        gds-dtl.fact-qnty column-label "Количество  ! " format "->>>>>>9.<<<"
        price-doc column-label "Цена по!докум.(Вал)" format ">>>>>>9.99"
        doc-sum column-label "Сумма по!докум.(Вал)" format "->>>>>>>>9.99"
        gds-dtl.cur-base column-label "Цена по!объекту(Вал)" format ">>>>>>9.99"
        obj-sum column-label "Сумма цен по!объекту(Вал)" format "->>>>>>>>9.99"
        Delt column-label "Процент!разницы" format "X(8)"
        sym2 column-label ":!:" format "X(1)" space(0)
    header
            cur-time-print() at 5 format "X(35)"
            string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) at 40 format "X(80)"
            string( "Страница " + string(PAGE-NUMBER) ) at 120 format "X(15)" skip
        v-single-line format "X(136)" at 1
with width {&doS_CW} down stream-io .
define frame Akt-rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        gds-dtl.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(30)"
        gds-dtl.fact-qnty column-label "Количество  ! " format "->>>>>>9.<<<"
        price-doc column-label "Цена по!докум.({&abbr_rub_firstshift})" format ">>>>>>9.99"
        doc-sum column-label "Сумма по!докум.({&abbr_rub_firstshift})" format "->>>>>>>>9.99"
        gds-dtl.cur-base column-label "Цена по!объекту({&abbr_rub_firstshift})" format ">>>>>>9.99"
        obj-sum column-label "Сумма цен по!объекту({&abbr_rub_firstshift})" format "->>>>>>>>9.99"
        Delt column-label "Процент!разницы" format "X(8)"
        sym2 column-label ":!:" format "X(1)" space(0)
    header
            cur-time-print() at 5 format "X(35)"
            string( "Акт автоматической переоценки по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) at 40 format "X(80)"
            string( "Страница " + string(PAGE-NUMBER) ) at 120 format "X(15)" skip
        v-single-line format "X(136)" at 1
with width {&doS_CW} down stream-io .

{ cmp/open-out.i " " " " " " {&LS_PS_A4} }

v-single-line = fill("-", 200).
find first t-doc no-lock
     where recid(t-doc) = rec_id
.

define variable FullGdsName as logical   no-undo .
define variable tmp-var  as character no-undo .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .


assign
    tdoc-date   = t-doc.doc-date
    tdoc-code   = t-doc.doc-code
.
find first Our_Host no-lock
     where Our_Host.obj-type = {&cmp}
       and Our_Host.obj-code = t-doc.host-code
.
put
    space(90) Our_Host.obj-name format "x(40)"
    skip(2) space(20) "А К Т   П Е Р Е О Ц Е Н К И   ( автоматической ) по документу  N " format "x(80)"
        t-doc.doc-code format "X(10)"
        "  от  " t-doc.doc-date format "99.99.9999" skip(1)
.
if lookup( "ParCom":U, p-mode ) <> 0
then do:
    if t-doc.doc-type = {&income}
    and not t-doc.internal
    then do:
        put
            substitute( "Основание: накладная поставщика N &1 от &2"
                        , t-doc.ord-num
                        , string( t-doc.ship-date, "99.99.9999" )
            )   format "x(110)"
            skip(1)
        .
    end.
end.
else do:
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
end.

if t-doc.doc-type = {&income}
or ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} )
/*   or ( t-doc.doc-type = {&expense} and ( not t-doc.internal ) )*/
then do:
        put space(20) string( "ПОСТАВЩИК : " + t-doc.cli-name ) format "x(90)" skip(1) .
end.

form header
    v-single-line format "X(136)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&doS_CW} page-bottom no-labels no-box .
view frame Bottomframe .

if v-rb-is-base = yes
then do:
    form with frame Akt-base .
end.        /* if v-rb-is-base = yes */
else do:
    form with frame Akt-rubl .
end.        /* NOT ( if v-rb-is-base = yes ) */
for each doc-line no-lock
   where doc-line.doc-code = t-doc.doc-code
  , each gds-dtl no-lock
   where gds-dtl.doc-code = t-doc.doc-code
     and gds-dtl.prod-type = doc-line.prod-type
     and gds-dtl.prod-code = doc-line.prod-code
     and gds-dtl.artic = doc-line.artic
     and gds-dtl.ov = yes
  , each goods no-lock
   where goods.prod-type = gds-dtl.prod-type
     and goods.prod-code = gds-dtl.prod-code
     and goods.artic = gds-dtl.artic
break by gds-dtl.artic
      by gds-dtl.prt-code
:
        find first bar-code no-lock
             where bar-code.gds-code = goods.gds-code
               and goods.unit-base = bar-code.unit-cli
               and gds-dtl.prt-code = bar-code.node-code
               and bar-code.part-code = ""
               and bar-code.in-code = ""
        no-error.
        accumulate
            bar-code.b-code ( COUNT )
            gds-dtl.fact-qnty ( total )
            ( gds-dtl.fact-qnty * gds-dtl.cur-base ) ( total )
            ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ( total )
            ( gds-dtl.fact-qnty * gds-dtl.price-base ) ( total )
            ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ( total )
            ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ( total )
        .
        if v-rb-is-base = yes
        then do:
            display
                sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                gds-dtl.price-base @ price-doc
                ( gds-dtl.fact-qnty * gds-dtl.price-base ) @ doc-sum
                gds-dtl.cur-base
                ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                string( string( ( gds-dtl.cur-base - gds-dtl.price-base ) / gds-dtl.price-base * 100, "->>>9.9" ) + "%" ) @ Delt
                sym2
            with frame Akt-base .
            down 1 with frame Akt-base .
            IF LENGTH(goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
              assign propis = SUBSTRING(goods.gds-name,31) .
              DISPLAY sym1 propis @ goods.gds-name  sym2   with frame Akt-base .
              down 1 with frame Akt-base .
            end.
        end.        /* if v-rb-is-base = yes */
        else do:
            display
                sym1
                trim( string( bar-code.b-code ) ) @ tb-code
                gds-dtl.artic
                goods.gds-name
                gds-dtl.fact-qnty
                gds-dtl.price-rubl @ price-doc
                ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) @ doc-sum
                gds-dtl.cur-base
                ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                string( string( ( gds-dtl.cur-base - gds-dtl.price-rubl ) / gds-dtl.price-rubl * 100, "->>>9.9" ) + "%" ) @ Delt
                sym2
            with frame Akt-rubl .
            down 1 with frame Akt-rubl .
            IF LENGTH(goods.gds-name, "CHARACTER") > 30 and FullGdsName THEN  do:
              assign propis = SUBSTRING(goods.gds-name,31) .
              DISPLAY sym1 propis @ goods.gds-name  sym2   with frame Akt-rubl .
              down 1 with frame Akt-rubl .
            end.
        end.        /* NOT ( if v-rb-is-base = yes ) */
        if last( gds-dtl.artic )
        then do:
            if v-rb-is-base = yes
            then do:
/*                down 1 with frame Akt-base .*/
                put
                    v-single-line format "X(136)" skip
                .
                display "  ИТОГО"    @ goods.gds-name
                    accum total gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    accum total ( gds-dtl.fact-qnty * gds-dtl.price-base ) @ doc-sum
                    accum total ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                    string( string( ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ) /
                                            ( accum total ( gds-dtl.fact-qnty * gds-dtl.price-base ) ) * 100, "->>>9.9" ) + "%" )
                                    @ Delt
                with frame Akt-base.
                underline
                    goods.gds-name
                    gds-dtl.fact-qnty
                    doc-sum
                    obj-sum
                    Delt
                with frame Akt-base.
                down 2
                with frame Akt-base.
            end.        /* if v-rb-is-base = yes */
            else do:
/*                down 1 with frame Akt-rubl .*/
                put
                    v-single-line format "X(136)" skip
                .
                display "  ИТОГО"    @ goods.gds-name
                    accum total gds-dtl.fact-qnty @ gds-dtl.fact-qnty
                    accum total ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) @ doc-sum
                    accum total ( gds-dtl.fact-qnty * gds-dtl.cur-base ) @ obj-sum
                    string( string( ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ) /
                                            ( accum total ( gds-dtl.fact-qnty * gds-dtl.price-rubl ) ) * 100, "->>>9.9" ) + "%" )
                                    @ Delt
                with frame Akt-rubl.
                underline
                    goods.gds-name
                    gds-dtl.fact-qnty
                    doc-sum
                    obj-sum
                    Delt
                with frame Akt-rubl.
                down 2
                with frame Akt-rubl.
            end.        /* NOT ( if v-rb-is-base = yes ) */
        end.
end.                  /* for each price-list where ... */
hide frame Bottomframe .
if v-rb-is-base = yes
then do:
    run rep/wp.p ( input p-mainmenu-handle, input absolute( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
    put space(10) "Всего  " ( accum COUNT bar-code.b-code ) format ">>>>9"
        " наименований." format "X(15)"
        skip(1) space(10)
        "Разница в суммах составила :  " format "X(35)"
            ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-base ) * gds-dtl.fact-qnty ) )
            format "->,>>>,>>>,>>9.99" space(2) trim( abbr ) format "X(3)"
        skip(1)
    .
end.
else do:
    run rep/wp-rub.p ( input absolute( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) ), output propis, output abbr ) .
    put space(10) "Всего  " ( accum COUNT bar-code.b-code ) format ">>>>9"
        " наименований." format "X(15)"
        skip(1) space(10)
        "Разница в суммах составила :  " format "X(35)"
            ( accum total ( ( gds-dtl.cur-base - gds-dtl.price-rubl ) * gds-dtl.fact-qnty ) )
            format "->,>>>,>>>,>>9.99" space(2) trim( abbr ) format "X(3)"
        skip(1)
    .
end.

if line-counter + 4 > page-size then
    page .

put space(10) ( if trim(propis) begins trim( abbr ) then string( "0 " + propis ) else propis ) format "X(120)" skip(2).
put space(20) "Зав. складом/Зав. секцией : " format "X(30)" skip.


output close.

{ rep/q-print.i 8 }