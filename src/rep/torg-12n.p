block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-12n.p $
$Archive: rep/torg-12n.p $

Печать документа Торг-12 с округлением

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

Данная форма не работает при наличии налогов кроме НДС и НП.

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo .
define input parameter Invers               as logical          no-undo .
define input parameter p-mode               as character        no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: torg-12n.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/torg-12n.p $":U .
define variable vss-description as character no-undo initial "Печать документа Торг-12 с округлением":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ rep/r-cliprp.i def }
{ rep/fmtcli.i       }
{ gbl/clntattr.i     }
{ rep/torgconf.i     }
{ rep/p-fmt.i        }
{ str/getctxtp.i def }

do
on error undo, return error
:

define stream Out-Stream .

define shared variable PrintScale   as logical      no-undo.

define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.

define variable tdoc-prt            as logical      no-undo.

define variable tdoc-code           as character    no-undo.
define variable v-doc-date-string   as character    no-undo.

define variable v-rootnode-code     as integer      no-undo.

define variable LineCounter         as integer      no-undo.
define variable txt-LC              as character    no-undo.
define variable s1                  as character    no-undo.
define variable s2                  as character    no-undo.

define variable Node_Code       like    ub.gds-prt.upper-code  no-undo.

define variable price-noNDS         as decimal      no-undo.
define variable price-withNDS       as decimal      no-undo.
define variable tqnty               as decimal      no-undo.
define variable stoim-noNDS         as decimal      no-undo.
define variable stoim               as decimal      no-undo.
define variable prt-tqnty           as decimal      no-undo.
define variable prt-VAT-gds         as decimal      no-undo.
define variable prt-SLT-gds         as decimal      no-undo.
define variable prt-stoim-noNDS     as decimal      no-undo.
define variable prt-stoim           as decimal      no-undo.

define variable v-price-is-changed  as logical      no-undo.

define variable v-VAT-gds           as decimal      no-undo.
define variable v-SLT-gds           as decimal      no-undo.
define variable v-price-withNDS     as decimal      no-undo.

define variable Pg-tqnty            as decimal     init 0 no-undo.
define variable Pg-VAT-gds          as decimal     init 0 no-undo.
define variable Pg-SLT-gds          as decimal     init 0 no-undo.
define variable Pg-stoim-noNDS      as decimal     init 0 no-undo.
define variable Pg-stoim            as decimal     init 0 no-undo.
define variable PrevPage            as integer     init 0 no-undo.

define variable VAT-gds             as decimal      no-undo.
define variable SLT-gds             as decimal      no-undo.

define variable torg-SLT-pc         like ub.doc-line.slt-pc  no-undo.


define variable PrtName             as character    no-undo.

define variable OKEI                as character    no-undo.
define variable tb-code             as character    no-undo.
define variable pack-type           as character    no-undo.
define variable qnty-opl            as decimal      no-undo.
define variable qnty-pl             as decimal      no-undo.
define variable mass                as decimal      no-undo.

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
define variable sym16 as character init ":" no-undo.
define variable sym17 as character init ":" no-undo.
define variable sym18 as character init ":" no-undo.
define variable sym19 as character init ":" no-undo.

define variable v-single-line       as character    no-undo.
define variable UndLine             as character    no-undo.

define variable gds-str             as character    no-undo.
define variable gds-str1            as character    no-undo.
define variable gds-str2            as character    no-undo.
define variable unit-str            as character    no-undo.
define variable val-str             as character    no-undo.

define variable i                   as integer      no-undo.
define variable j                   as integer      no-undo.

define variable v-sys-key           as character    no-undo.                  /* для чтения параметра конфигурации */
define variable v-gds-name-length   as integer      no-undo.

define variable v-sum-stoim-noNDS   as decimal       no-undo.
define variable v-sum-VAT-gds       as decimal       no-undo.
define variable v-sum-stoim         as decimal       no-undo.
define variable v-sum-SLT-gds       as decimal       no-undo.
define variable v-host-code         as integer       no-undo.
define variable v-curr-code         as integer       no-undo.
define variable v-print-doc         as character     no-undo.
define variable tmp-var             as character     no-undo .
define variable v-void-decimal      as decimal       no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define buffer OurObject for ub.clients.
define buffer t-doc for ub.trn-doc.

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
{ gbl/currsysk.i
  v-sys-key
  no-error
}

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
if printRubl = yes
then do:
    assign
        v-curr-code = 0
    .
end.
else do:
    { gbl/basecode.i
        v-host-code
        v-curr-code
    }
end.
run torgconf-read in this-procedure (
      input "torg12n"
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
run torgconf-get-self-param in this-procedure (
      input t-doc.obj-type
    , input t-doc.obj-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-cli-param in this-procedure (
      input t-doc.host-code
    , input t-doc.cli-type
    , input t-doc.cli-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-form-header in this-procedure (
      input Invers
    , input t-doc.doc-code
    , input ( v-print-doc = "yes" )
    , input t-doc.doc-date
    , input t-doc.fact-date
    , input t-doc.doc-type
    , input t-doc.status_
    , input no
    , input no
).

define variable FullGdsName        as logical   no-undo .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

&scop gds-len 30
&scop gds-len-m 52
DEFINE FRAME f-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        LineCounter COLUMN-LABEL "N!п/п! ! ! " format ">>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len})" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!НДС и НП! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!НДС и НП! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!НДС (без НП)! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SLT-gds column-label "Сумма!НП! ! ! " format "->>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-withNDS COLUMN-LABEL "Цена!с учетом!НДС и НП! ! " format "->>>>>>>9.99" space(0)
        sym18 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) AT 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                  string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
              else
                  " " ) AT 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 180 format "X(13)" SKIP
        v-single-line format "X(198)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME f-doc-m
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        LineCounter COLUMN-LABEL "N!п/п! ! ! " format ">>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len-m})" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!НДС и НП! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!НДС и НП! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!НДС (без НП)! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) AT 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                  string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
              else
                  " " ) AT 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 180 format "X(13)" SKIP
        v-single-line format "X(198)" AT 1
    with width {&DOS_CW} down stream-io.
assign
    v-single-line   = fill("-", 230)
    UndLine         = fill("_", 230)
    LineCounter     = 1
.

assign
    v-torgconf-outt12 = ( p-mode = "mag" )
    v-gds-name-length   = ( if v-torgconf-outt12 = yes then {&gds-len-m} else {&gds-len} )
.

if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = "          "
    .
end.
else do:
    if Invers = yes
    then do:
        assign
            tdoc-code = entry( 1, t-doc.doc-code, "-" )
        no-error.
        if tdoc-code = ""
        then do:
            assign tdoc-code = substr( t-doc.doc-code, 1, 2 )
                                + string( month( t-doc.doc-date ),  "99" )
                                + string( day( t-doc.doc-date ),    "99" )
            .
        end.
        else do:
            assign tdoc-code = string( month( t-doc.doc-date ), ">9" )
                                + trim( string( day( t-doc.doc-date ), ">9" ) )
                                + string( integer( tdoc-code ))
            .
        end.
    end.        /* if Invers = yes */
    else do:
        assign
            tdoc-code = t-doc.doc-code
        .
    end.        /* if Invers <> yes */
end.
if v-torgconf-outdate = yes
then do:
    assign v-doc-date-string =  "          " .
end.
else do:
    assign v-doc-date-string =  ( if t-doc.status_ <> {&fact} or v-print-doc = "yes"
                        then string( t-doc.doc-date, "99/99/9999" )
                        else string( t-doc.fact-date, "99/99/9999" )
                        )
    .
end.
FIND OurObject WHERE OurObject.obj-type = t-doc.obj-type AND
                                          OurObject.obj-code = t-doc.obj-code NO-LOCK NO-ERROR.
CASE OurObject.obj-type :
    when {&shop} then
        do:
            FIND ub.shop WHERE ub.shop.obj-code = OurObject.obj-code NO-LOCK .
            tdoc-prt = ub.shop.doc-prt.
        end.
    when {&stock} then
        do:
            FIND ub.store WHERE ub.store.obj-code = OurObject.obj-code NO-LOCK .
            tdoc-prt = ub.store.doc-prt .
        end.
END CASE.

if NOT tdoc-prt OR Invers then
    PrintScale = no .
/*
else
    MM1:
    FOR EACH ub.gds-dtl WHERE ub.gds-dtl.doc-code = t-doc.doc-code NO-LOCK :
        if can-find( first ub.gds-prt where ub.gds-prt.node-code = ub.gds-dtl.prt-code and
                                                        ub.gds-prt.node-name <> {&empty-scale} and
                                                        not ub.gds-prt.root ) then
            do:
                message "Печатать с детальным разбиением по признакам ?"
                      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                      TITLE "Как напечатать шкалу ?" UPDATE PrintScale.
                LEAVE MM1.
            end.
    END .
*/

if session:set-wait-state("compiler") then.
{ cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4} }

FORM HEADER
    v-single-line format "X(198)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM Out-Stream FRAME BottomFrame .
/*
if NOT t-doc.print-rubl AND NOT Invers then
    message "Документ печатать в {&abbr_rublyah_allshift} ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
else
    assign PrintRubl = yes .
*/

run print-header in this-procedure .

FIND ub.currency WHERE ub.currency.curr-code = t-doc.exch-code NO-LOCK.

if v-torgconf-outt12 = yes
then do:
    form with frame f-doc-m .
end.        /* v-torgconf-outt12 = yes */
else do:
    form with frame f-doc .
end.        /* NOT ( v-torgconf-outt12 = yes ) */

run print-doc-line in this-procedure .

if line-counter( Out-Stream ) + 20 > page-size( Out-Stream ) then
    do:
        { rep/torg-12n.i itog }
        page STREAM Out-Stream .
    end.
HIDE STREAM Out-Stream FRAME BottomFrame .

{ rep/torg-12n.i itog }
if v-torgconf-outt12 = yes
then do:
    DISPLAY STREAM Out-Stream
        "Всего по накладной" @ ub.goods.gds-name
        t-doc.fact-qnty @ tqnty
        v-sum-stoim-noNDS @ stoim-noNDS
        v-sum-VAT-gds  @ VAT-gds
        v-sum-stoim @ stoim
    with frame f-doc-m .
    DOWN STREAM Out-Stream 2 with FRAME f-doc-m .
end.        /* v-torgconf-outt12 = yes */
else do:
    DISPLAY STREAM Out-Stream
        "Всего по накладной" @ ub.goods.gds-name
        t-doc.fact-qnty @ tqnty
        v-sum-stoim-noNDS @ stoim-noNDS
        v-sum-VAT-gds  @ VAT-gds
        v-sum-stoim @ stoim
        v-sum-SLT-gds  @ SLT-gds
    with frame f-doc .
    DOWN STREAM Out-Stream 2 with FRAME f-doc .
end.        /* NOT ( v-torgconf-outt12 = yes ) */

if PrintRubl then
    run rep/wp-rub.p ( ( v-sum-stoim + v-sum-SLT-gds ), output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, ( v-sum-stoim + v-sum-SLT-gds ), output s1, output s2 ) .
run rep/wp-qnty.p ( input ( LineCounter - 1 ), output txt-LC).
PUT STREAM Out-Stream
    space(10) string( "Всего на сумму: " + trim( string( ( v-sum-stoim + v-sum-SLT-gds ), "->>>,>>>,>>>,>>>,>>9.99") ) + " (" +
                                trim( ( if Invers then ub.currency.curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) ) + ")" ) format "X(180)"
.
if t-doc.doc-type <> {&income}
then put stream out-stream
    skip
    space(15) string( "В том числе " + (if NOT Invers AND ( if PrintRubl then t-doc.discnt-rubl else t-doc.tot-calc ) < 0 then "наценка: " else "скидка: " ) +
                                (if NOT Invers then trim( string( ABS( ( if PrintRubl then t-doc.discnt-rubl else t-doc.tot-calc ) ), ">>>,>>>,>>>,>>>,>>9.99") ) else "0.00" ) +
                                " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
.
PUT STREAM Out-Stream
    skip
    space(30) string( "НДС: " + trim( string( v-sum-VAT-gds, "->>>,>>>,>>>,>>>,>>9.99") ) +
                                " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
.
if v-sum-SLT-gds <> 0
then do:
    PUT STREAM Out-Stream
        SKIP
        space(19) string( "налог с продаж: " + trim( string( v-sum-SLT-gds, "->>>,>>>,>>>,>>>,>>9.99") ) +
                                    " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
    .
end.
define variable v-doc-places    as character    no-undo.
define variable v-attr-type     as character    no-undo.
{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-qntyplace}
    v-doc-places
    v-attr-type
}
if v-doc-places = "":U
then do:
    assign
        v-doc-places = UndLine
    .
end.
PUT STREAM Out-Stream
    SKIP(2)
    space(10) string( "Товарная накладная имеет приложение на " + UndLine ) format "X(125)" SKIP
    space(10) string( "и содержит " + CAPS( txt-LC ) + " порядковый(ых) номер(ов) записей") format "X(180)" SKIP
    UndLine format "X(29)" AT 151 SKIP
    string( "Масса груза (нетто) " + UndLine ) format "X(85)" AT 60
            string( "|" + UndLine ) format "X(30)" AT 150 "|" SKIP
    space(10) string( "Всего мест " + v-doc-places ) format "X(45)"
            string( "Масса груза (брутто) " + UndLine ) format "X(85)" AT 60
            string( "|" + UndLine ) format "X(30)" AT 150 "|" SKIP(1)
    string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( UndLine, "X(42)" ) + " листах" ) format "X(95)" "|" AT 97
        string( "По доверенности N " + string( UndLine, "X(39)" ) + " от " + UndLine ) format "X(100)" AT 99 SKIP
    "Всего отпущено на сумму " format "X(95)" "|" AT 97 string( "выданной " + UndLine ) format "X(100)" AT 99 SKIP
    space(2) CAPS(s1) format "X(93)" "|" AT 97 SKIP
    string( "Отпуск разрешил " + UndLine ) format "X(95)" "|" AT 97 SKIP
    "|" AT 97 string( "Груз принял " + UndLine ) format "X(100)" AT 99 SKIP
    UndLine format "X(95)" "|" AT 97 string( "Груз получил грузополучатель " + UndLine ) format "X(100)" AT 99 SKIP
    "М.П." AT 15  "|" AT 97 "М.П." AT 99 SKIP
    .

output STREAM Out-Stream CLOSE.
{ rep/q-print.i 8 }

end.

/*==========================================================================*/
procedure print-doc-line :
do
on error undo, return error
:
for each ub.doc-line no-lock
   where ub.doc-line.doc-code = t-doc.doc-code
break   &if "{&sort-prod}" = "yes"
        &then  BY ( ub.doc-line.prod-type + string( ub.doc-line.prod-code ) )
        &endif BY ub.doc-line.artic
:
    FIND ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                                      ub.goods.prod-code = ub.doc-line.prod-code AND
                                      ub.goods.artic = ub.doc-line.artic NO-LOCK .
    if v-sys-key = "iab" then do:
      FIND ub.sysconf WHERE ub.sysconf.host-code = t-doc.host-code NO-LOCK.
      if t-doc.doc-type = {&expense} AND t-doc.internal = no AND t-doc.pay-code = ub.sysconf.cash-pay then
          assign torg-SLT-pc = 5.
      else
          assign torg-SLT-pc = 0.
    end.
    else do:
      assign torg-SLT-pc = ub.doc-line.SLT-pc.
    end.

    if FullGdsName
    then do:
            gds-str1 = breakstr(ub.goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).
            assign j = 0.
            DO WHILE gds-str2 <> "" :
                assign gds-str = gds-str2.
                gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
                assign j = j + 1.
            END. /* DO WHILE ... */
            if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then
                do:
                    { rep/torg-12n.i itog }
                    PAGE STREAM Out-Stream.
                end.
            gds-str1 = breakstr(ub.goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).
    end.
    else do:
            assign gds-str1 = ub.goods.gds-name.
    end.

    FIND ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
    v-rootnode-code = ub.gds-prt.node-code.

    if ( NOT can-do( {&empty-scale}, ub.gds-prt.node-name ) ) AND ( NOT Invers )
    then do:                                                                    /* Т.е. не пустая шкала */
            if PrintScale then
                do:
                    if v-torgconf-outt12 = yes
                    then do:
                        DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16
                        with frame f-doc-m .
                        DOWN STREAM Out-Stream 1 with FRAME f-doc-m .
                        { rep/torg-12n.i no-sum {&gds-len-m} }
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                        with frame f-doc .
                        DOWN STREAM Out-Stream 1 with FRAME f-doc .
                        { rep/torg-12n.i no-sum {&gds-len} }
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    LineCounter = LineCounter + 1.
                end.
            if session:set-wait-state("compiler") then.
            FOR EACH ub.gds-dtl WHERE
                            ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
                            ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
                            ub.gds-dtl.artic = ub.doc-line.artic AND
                            ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK :
                FIND ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.

                if t-doc.doc-type = {&income} then
                    do:
                        run calc-in-vat-doc-line in this-procedure (
                            output price-noNDS
                        ).
                    end.
                else
                    do:
                        run calc-out-vat-gds-dtl in this-procedure (
                            output price-noNDS
                        ).
                    end.
                assign
                    prt-tqnty       = ub.gds-dtl.fact-qnty
                .
                run p-fmt-round in this-procedure (
                      input prt-tqnty
                    , input price-noNDS
                    , input price-noNDS * ub.doc-line.vat-pc / 100
                    , input price-noNDS * ( 1 + ( ub.doc-line.vat-pc / 100 ) ) * torg-SLT-pc / 100
                    , input v-void-decimal
                    , output price-noNDS
                    , output VAT-gds
                    , output v-void-decimal
                    , output v-void-decimal
                    , output SLT-gds
                    , output v-void-decimal
                    , output v-void-decimal
                    , output price-withNDS
                ).
/*                assign*/
/*                    price-noNDS     = round( price-noNDS , 2 )*/
/*                    VAT-gds         = round( (price-noNDS * ub.doc-line.vat-pc / 100 ), 2 )*/
/*                    SLT-gds         = round( ( (price-noNDS + VAT-gds) * prt-tqnty * torg-SLT-pc / 100 ), 2 )*/
/*                    price-withNDS   = round( ( price-noNDS + VAT-gds + SLT-gds / prt-tqnty ) , 2 )*/
/*                .*/
                if VAT-gds = ? then VAT-gds = 0.
                if SLT-gds = ? then SLT-gds = 0.
                assign
                    prt-VAT-gds = VAT-gds * prt-tqnty
                    prt-SLT-gds = SLT-gds
                    prt-stoim-noNDS = price-noNDS * prt-tqnty
                    prt-stoim = prt-stoim-noNDS + prt-VAT-gds
                    .
                ACCUMULATE
                    prt-tqnty (TOTAL)
                    prt-VAT-gds ( TOTAL )
                    prt-SLT-gds ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim ( TOTAL )
                    .
                if PrintScale then
                    do:
                        FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                                        AND ub.bar-code.unit-cli = ub.goods.unit-base
                                        AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                                        AND ub.bar-code.part-code = ""
                                        AND ub.bar-code.in-code = ""
                                      NO-LOCK .
                        PrtName = "".
                        DO WHILE available ub.gds-prt:
                            if available ub.gds-prt then
                                PrtName = "\" + string( ub.gds-prt.node-name, "x(10)" ) + PrtName.
                            Node_Code = ub.gds-prt.upper-code.
                            FIND ub.gds-prt WHERE ub.gds-prt.node-code = Node_Code
                                                               AND ub.gds-prt.root <> yes NO-LOCK NO-ERROR.
                        END.
                        if v-torgconf-outt12 = yes
                        then do:
                            DISPLAY STREAM Out-Stream
                                PrtName @ ub.goods.gds-name
                                string( ub.bar-code.b-code ) @ tb-code
                                ub.goods.unit-base
                                prt-tqnty @ tqnty
                                price-noNDS
                                prt-stoim-noNDS @ stoim-noNDS
                                ub.doc-line.VAT-pc
                                prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                                prt-stoim @ stoim
                                sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                sym11 sym12 sym13 sym14 sym15 sym16
                            with frame f-doc-m .
                            DOWN STREAM Out-Stream 1 with FRAME f-doc-m .
                        end.        /* v-torgconf-outt12 = yes */
                        else do:
                            DISPLAY STREAM Out-Stream
                                PrtName @ ub.goods.gds-name
                                string( ub.bar-code.b-code ) @ tb-code
                                ub.goods.unit-base
                                prt-tqnty @ tqnty
                                price-noNDS
                                prt-stoim-noNDS @ stoim-noNDS
                                ub.doc-line.VAT-pc
                                prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                                prt-stoim @ stoim
                                prt-SLT-gds when prt-tqnty <> 0 @ SLT-gds
                                price-withNDS
                                sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc .
                            DOWN STREAM Out-Stream 1 with FRAME f-doc .
                        end.        /* NOT ( v-torgconf-outt12 = yes ) */
                        { rep/torg-12n.i prt- }
                    end.

            END.        /*FOR EACH ub.gds-dtl ...*/

            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
                .

            if NOT PrintScale then
                do:
                    find first ub.bar-code no-lock
                         where ub.bar-code.gds-code    = ub.goods.gds-code
                           and ub.bar-code.unit-cli    = ub.goods.unit-base
                           and ub.bar-code.node-code   = v-rootnode-code
                           and ub.bar-code.part-code   = ""
                           and ub.bar-code.in-code     = ""
                    .
                    if v-torgconf-outt12 = yes
                    then do:
                        DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            tqnty
                            price-noNDS
                            stoim-noNDS
                            ub.doc-line.VAT-pc
                            VAT-gds when tqnty <> 0
                            stoim
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16
                        with frame f-doc-m .
                        DOWN STREAM Out-Stream 1 with FRAME f-doc-m .
                        { rep/torg-12n.i " " {&gds-len-m} }
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            tqnty
                            price-noNDS
                            stoim-noNDS
                            ub.doc-line.VAT-pc
                            VAT-gds when tqnty <> 0
                            stoim
                            SLT-gds when tqnty <> 0
                            price-withNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                        with frame f-doc .
                        DOWN STREAM Out-Stream 1 with FRAME f-doc .
                        { rep/torg-12n.i " " {&gds-len} }
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    LineCounter = LineCounter + 1 .
                end.
    end.
    else do:                                                            /* пустая шкала */
        FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                        AND ub.bar-code.unit-cli = ub.goods.unit-base
                        AND ub.bar-code.node-code = v-rootnode-code
                        AND ub.bar-code.part-code = ""
                        AND ub.bar-code.in-code = ""
                        NO-LOCK .
        if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
           and PrintScale = no
        then do:
            /*---S--------- Возврат поставщику: печать по партиям ------------*/
            find first ub.gds-dtl no-lock
                 where ub.gds-dtl.doc-code    = ub.doc-line.doc-code
                   and ub.gds-dtl.artic       = ub.doc-line.artic
                   and ub.gds-dtl.prod-code   = ub.doc-line.prod-code
                   and ub.gds-dtl.prod-type   = ub.doc-line.prod-type
                   and ub.gds-dtl.prt-code    = v-rootnode-code
            .

            if ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl <> ub.gds-dtl.price-rubl
            then do:                                    /*Значит, цену в возврате поставщику изменяли */
                assign                                  /* по заказам - выдаем усредненную цену       */
                    v-price-is-changed  =  yes
                .
                { str/out-vatp.i calc-gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
                assign
                    v-VAT-gds         = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    v-SLT-gds         = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
                    v-price-withNDS   = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                .
            end.
            else do:
                assign                                  /* надо брать учетную цену из партий          */
                    v-price-is-changed  =  no
                .
            end.

            for each ub.parts
               where ub.parts.obj-type     = ub.doc-line.obj-type
                 and ub.parts.obj-code     = ub.doc-line.obj-code
                 and ub.parts.artic        = ub.goods.artic
                 and ub.parts.prod-type    = ub.goods.prod-type
                 and ub.parts.prod-code    = ub.goods.prod-code
                 and ub.parts.out-code     = ub.doc-line.doc-code
            :
                /*---S--------- Для каждой партии --------------------------------*/
                if v-price-is-changed  =  no
                then do:
                    { str/in-vatp.i calc-parts ub.parts. t-doc.}
                    assign
                        v-VAT-gds        = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                        v-SLT-gds        = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                        v-price-withNDS  = ( if PrintRubl
                            then price-rubl-with-tax-loc - road-tax-rubl-loc - transport-rubl-loc - other-rubl-loc
                            else price-base-with-tax-loc - road-tax-base-loc - transport-base-loc - other-base-loc
                                          )
                    .
                end.

                if VAT-gds = ? then VAT-gds = 0.
                if SLT-gds = ? then SLT-gds = 0.

                assign
                    tqnty           = ub.parts.qnty
                    unit-str        = ub.goods.unit-base
                    price-noNDS     = v-price-withNDS - v-VAT-gds - v-SLT-gds
                    VAT-gds         = v-VAT-gds * tqnty
                    SLT-gds         = v-SLT-gds * tqnty
                    stoim-noNDS     = price-noNDS * tqnty
                    stoim           = stoim-noNDS + VAT-gds
                    price-withNDS   = v-price-withNDS
                .
                if v-torgconf-outt12 = yes
                then do:
                    display stream out-stream
                        LineCounter
                        ub.goods.artic
                        gds-str1                    @ ub.goods.gds-name
                        string( ub.bar-code.b-code )   @ tb-code
                        unit-str                    @ ub.goods.unit-base
                        tqnty
                        price-noNDS
                        stoim-noNDS
                        ub.parts.VAT-pc                @ ub.doc-line.VAT-pc
                        VAT-gds when tqnty <> 0
                        stoim
                        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                        sym11 sym12 sym13 sym14 sym15 sym16
                    with frame f-doc-m.
                    down stream out-stream 1 with frame f-doc-m.
                end.        /* v-torgconf-outt12 = yes */
                else do:
                    display stream out-stream
                        LineCounter
                        ub.goods.artic
                        gds-str1                    @ ub.goods.gds-name
                        string( ub.bar-code.b-code )   @ tb-code
                        unit-str                    @ ub.goods.unit-base
                        tqnty
                        price-noNDS
                        stoim-noNDS
                        ub.parts.VAT-pc                @ ub.doc-line.VAT-pc
                        VAT-gds when tqnty <> 0
                        stoim
                        SLT-gds when tqnty <> 0
                        price-withNDS
                        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                        sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                    with frame f-doc.
                    down stream out-stream 1 with frame f-doc.
                end.        /* NOT ( v-torgconf-outt12 = yes ) */
                assign
                    prt-tqnty =  tqnty
                    prt-VAT-gds = VAT-gds
                    prt-SLT-gds = SLT-gds
                    prt-stoim-noNDS = price-noNDS * prt-tqnty
                    prt-stoim = prt-stoim-noNDS + prt-VAT-gds
                .
                accumulate
                    prt-tqnty (TOTAL)
                    prt-VAT-gds ( TOTAL )
                    prt-SLT-gds ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim ( TOTAL )
                .

                { rep/torg-12n.i " " {&gds-len} }
                LineCounter = LineCounter + 1.
                /*---E--------- Для каждой партии --------------------------------*/
            end.
            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
            .
            ACCUMULATE
                tqnty (TOTAL)
                VAT-gds ( TOTAL )
                SLT-gds ( TOTAL )
                stoim-noNDS ( TOTAL )
                stoim ( TOTAL )
            .
            /*---E--------- Возврат поставщику: печать по партиям ------------*/
        end.
        else do:
            if Invers
            then do:
                    assign
                        tqnty = ub.doc-line.cli-qnty
                        unit-str = ub.doc-line.unit-cli
                    .
                    { str/in-vat.i
                    t-doc.doc-code
                    t-doc.base-rate
                    t-doc.base-scale
                    t-doc.exch-rate
                    t-doc.exch-scale
                    t-doc.vat-type
                    t-doc.slt-type
                    ub.doc-line.artic
                    ub.doc-line.prod-type
                    ub.doc-line.prod-code
                    ub.doc-line.price-cli
                    ub.doc-line.cli-base-rate
                    ub.doc-line.price-rubl
                    ub.doc-line.vat-pc
                    ub.doc-line.slt-pc
                    ub.doc-line.road-tax
                    ub.doc-line.transport-rubl
                    ub.doc-line.other-rubl
                    varprice-cli
                    varprice-cli-unit-base
                    varprice-road-tax
                    varprice-other-exp
                    varprice-transport-exp
                    varprice-without-abs
                    varprice-slt
                    varprice-no-slt
                    varprice-vat
                    varprice-no-vat-slt
                    varprice-rubl
                    varprice-road-tax-rubl
                    varprice-other-exp-rubl
                    varprice-transport-exp-rubl
                    varprice-without-abs-rubl
                    varprice-slt-rubl
                    varprice-no-slt-rubl
                    varprice-vat-rubl
                    varprice-no-vat-slt-rubl
                    varprice-base
                    varprice-road-tax-base
                    varprice-other-exp-base
                    varprice-transport-exp-base
                    varprice-without-abs-base
                    varprice-slt-base
                    varprice-no-slt-base
                    varprice-vat-base
                    varprice-no-vat-slt-base
                    no-error
                    }
                    if error-status:error then do:
                       return error "Ошибка при пересчете линии документа".
                    end.
                    run p-fmt-round in this-procedure (
                          input tqnty
                        , input varprice-no-vat-slt
                        , input varprice-vat
                        , input varprice-slt
                        , input v-void-decimal
                        , output price-noNDS
                        , output VAT-gds
                        , output v-void-decimal
                        , output v-void-decimal
                        , output SLT-gds
                        , output v-void-decimal
                        , output v-void-decimal
                        , output price-withNDS
                    ).
/*                    assign*/
/*                        VAT-gds = varprice-vat*/
/*                        SLT-gds = varprice-slt * tqnty*/
/*                        price-noNDS = varprice-no-vat-slt*/
/*                        price-noNDS = round( price-noNDS , 2 )*/
/*                        price-withNDS = round( ( price-noNDS + VAT-gds + SLT-gds / tqnty ) , 2 )*/
/*                        .*/
            end.
            else do:
                    FIND ub.gds-dtl where ub.gds-dtl.doc-code = ub.doc-line.doc-code
                                                    and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                                                    and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                                                    and ub.gds-dtl.artic = ub.doc-line.artic
                                                    and ub.gds-dtl.prt-code = v-rootnode-code NO-LOCK .
                    assign
                        tqnty = ub.gds-dtl.fact-qnty
                        unit-str = ub.goods.unit-base
                        .
                    if t-doc.doc-type = {&income} then
                        do:
                            { str/in-vatp.i calc ub.doc-line. t-doc. g }
                            assign price-noNDS = ( if PrintRubl then price-rubl-without-tax-loc else price-base-without-tax-loc ).
                        end.
                    else
                        do:
                            { str/out-vatp.i calc-gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
                            assign
                                price-noNDS = ( if PrintRubl
                                                then price-rubl-with-tax-sale - vat-rubl-buyer - slt-rubl-sale - road-tax-rubl-sale
                                                else price-base-with-tax-sale - vat-base-buyer - slt-base-sale - road-tax-base-sale  )

                            .
                        end.
                    run p-fmt-round in this-procedure (
                          input tqnty
                        , input price-noNDS
                        , input price-noNDS * ub.doc-line.vat-pc / 100
                        , input price-noNDS * ( 1 + ( ub.doc-line.vat-pc / 100 ) ) * torg-SLT-pc / 100
                        , input v-void-decimal
                        , output price-noNDS
                        , output VAT-gds
                        , output v-void-decimal
                        , output v-void-decimal
                        , output SLT-gds
                        , output v-void-decimal
                        , output v-void-decimal
                        , output price-withNDS
                    ).
/*                    assign*/
/*                        price-noNDS     = round( price-noNDS , 2 )*/
/*                        VAT-gds         = round( (price-noNDS * ub.doc-line.vat-pc / 100 ), 2 )*/
/*                        SLT-gds         = round( ( (price-noNDS + VAT-gds) * tqnty * torg-SLT-pc / 100 ), 2 )*/
/*                        price-withNDS   = round( ( price-noNDS + VAT-gds + SLT-gds / tqnty ) , 2 )*/
/*                    .*/
            end.
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                VAT-gds = VAT-gds * tqnty
                stoim-noNDS = price-noNDS * tqnty
                stoim = stoim-noNDS + VAT-gds
            .
            if v-torgconf-outt12 = yes
            then do:
                DISPLAY STREAM Out-Stream
                    LineCounter
                    ub.goods.artic
                    gds-str1 @ ub.goods.gds-name
                    string( ub.bar-code.b-code ) @ tb-code
                    unit-str @ ub.goods.unit-base
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    ub.doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16
                with frame f-doc-m .
                DOWN STREAM Out-Stream 1 with FRAME f-doc-m .
                { rep/torg-12n.i " " {&gds-len-m} }
            end.        /* v-torgconf-outt12 = yes */
            else do:
                DISPLAY STREAM Out-Stream
                    LineCounter
                    ub.goods.artic
                    gds-str1 @ ub.goods.gds-name
                    string( ub.bar-code.b-code ) @ tb-code
                    unit-str @ ub.goods.unit-base
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    ub.doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    SLT-gds when tqnty <> 0
                    price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                with frame f-doc .
                DOWN STREAM Out-Stream 1 with FRAME f-doc .
                { rep/torg-12n.i " " {&gds-len} }
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            assign
                LineCounter = LineCounter + 1
            .
            ACCUMULATE
                tqnty (TOTAL)
                VAT-gds ( TOTAL )
                SLT-gds ( TOTAL )
                stoim-noNDS ( TOTAL )
                stoim ( TOTAL )
            .
        end.
    end.
end.        /* for each ub.doc-line ... */
assign
    v-sum-VAT-gds       = (accum total VAT-gds)
    v-sum-SLT-gds       = (accum total SLT-gds)
    v-sum-stoim-noNDS   = (accum total stoim-noNDS)
    v-sum-stoim         = (accum total stoim)
.
end.
end procedure. /* print-doc-line */

/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
    FIND ub.currency WHERE ub.currency.curr-code = t-doc.exch-code NO-LOCK.

    assign val-str = ( if Invers then ub.currency.curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) ).

    FIND ub.pay-type WHERE ub.pay-type.obj-code = t-doc.pay-code NO-LOCK NO-ERROR .


    if Invers then
        FIND ub.clients WHERE ub.clients.obj-type = t-doc.cli-type AND
                                        ub.clients.obj-code = t-doc.cli-code NO-LOCK .
    else
        FIND ub.clients WHERE ub.clients.obj-type = {&cmp} AND
                                        ub.clients.obj-code = t-doc.host-code NO-LOCK .

    { rep/r-cliprp.i }
    if v-torgconf-outappr = yes
    then do:
        put stream out-stream
            "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137
        .
    end.
    PUT STREAM Out-Stream
        space(5) v-single-line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0330212" "|" AT 198 skip
        space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                                + t-addres + t-phone) format "X(160)"
                    "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) ( if t-doc.doc-type <> {&income} then
                        string( CAPS( OurObject.obj-name ) + " (" + string(OurObject.obj-code) + ")" )
                        else
                            " "
                        ) format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        .

    if Invers then
        FIND ub.clients WHERE ub.clients.obj-type = {&cmp} AND
                                        ub.clients.obj-code = t-doc.host-code NO-LOCK .
    else
        FIND ub.clients WHERE ub.clients.obj-type = t-doc.cli-type AND
                                        ub.clients.obj-code = t-doc.cli-code NO-LOCK .
    { rep/r-cliprp.i }
    PUT STREAM Out-Stream
        space(5) v-torgconf-torg12-cargo-string  format "X(160)"
        "по ОКПО"                       format "X(7)"       AT 172
        "| "                                                AT 180
        t-okpo                          format "X(16)"
        "|"                                                 AT 198
        skip
    .

    if t-doc.doc-type = {&income} then
        FIND ub.clients WHERE ub.clients.obj-type = t-doc.cli-type AND
                                        ub.clients.obj-code = t-doc.cli-code NO-LOCK .
    else
        FIND ub.clients WHERE ub.clients.obj-type = {&cmp} AND
                                        ub.clients.obj-code = t-doc.host-code NO-LOCK .

    define variable v-supplier    as character    no-undo.
    run fmtcli-get-bank in this-procedure (
          input v-host-code
        , input ub.clients.obj-type
        , input ub.clients.obj-code
        , input v-curr-code
    ).
    assign
        v-supplier = ub.clients.obj-name
    .
    if v-fmtcli-schet-exists = yes
    then do:
        assign
            v-supplier = v-supplier
                + substitute( ", р/с &1 к/с &2"
                            , v-fmtcli-bank-r-schet
                            , v-fmtcli-bank-c-schet
                            )
        .
        if v-fmtcli-bank-exists = yes
        then do:
            assign
                v-supplier = v-supplier
                    + substitute( " БИК &1 в &2, &3"
                                , v-fmtcli-bank-bik
                                , v-fmtcli-bank-name
                                , v-fmtcli-bank-addres
                                )
            .
        end.
    end.
    PUT STREAM Out-Stream
        space(5) substitute( "Поставщик: &1", v-supplier ) format "X(160)"
                        "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        .

    if t-doc.doc-type <> {&income}
    then do:
        find first ub.clients no-lock
             where ub.clients.obj-type = t-doc.cli-type
               and ub.clients.obj-code = t-doc.cli-code
        .
    end.
    else do:
        find first ub.clients no-lock
             where ub.clients.obj-type = {&cmp}
               and ub.clients.obj-code = t-doc.host-code
        .
    end.
    define variable v-attr-value  as character no-undo .
    define variable v-attr-type   as character no-undo .
    define variable v-osnov       as character initial "" no-undo .
    if t-doc.doc-type = {&income} then  do:
        { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
        assign v-osnov = v-attr-value .
        { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
        assign v-osnov = v-osnov + " от " + v-attr-value .
    end.

    define variable v-saler    as character    no-undo.

    run fmtcli-get-bank in this-procedure (
          input v-host-code
        , input ub.clients.obj-type
        , input ub.clients.obj-code
        , input v-curr-code
    ).
    assign
        v-saler = ub.clients.obj-name
    .
    if v-fmtcli-schet-exists = yes
    then do:
        assign
            v-saler = v-saler
                + substitute( ", р/с &1 к/с &2"
                            , v-fmtcli-bank-r-schet
                            , v-fmtcli-bank-c-schet
                            )
        .
        if v-fmtcli-bank-exists = yes
        then do:
            assign
                v-saler = v-saler
                    + substitute( " БИК &1 в &2, &3"
                                , v-fmtcli-bank-bik
                                , v-fmtcli-bank-name
                                , v-fmtcli-bank-addres
                                )
            .
        end.
    end.
    put stream out-stream
        space(5) substitute( "Плательщик: &1", v-saler ) format "X(160)"
                        "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) string( "Основание: " + v-osnov ) format "X(160)"
                        "номер" format "X(5)" AT 174 "| " AT 180  "|" AT 198 skip
    .
    if p-mode = "mag"
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "mag"  */
    else do:
        put stream out-stream
            space(5) string( "Примечание: " + ( if not( t-doc.PS begins "@" )
                                                then replace( t-doc.PS, {&new-line}, " " )
                                                else "" ) )                         format "X(163)"
        .
    end.        /* NOT ( p-mode = "mag"  ) */
    put stream out-stream
                        "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) string( "Вид оплаты: " + ( if available ub.pay-type and ( lookup( "Mari":U, p-mode ) = 0 or index( ub.pay-type.obj-name, "озврат":U ) = 0 ) then ub.pay-type.obj-name else "":U ) ) format "X(130)"
                        string( "Транспортная накладная " ) format "X(23)" AT 147
                        "номер" format "X(5)" AT 174 "| " AT 180
                        v-torgconf-vdoc-code format "X(16)" "|" AT 198 skip
    .
    if v-torgconf-outprim = yes
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "mag"  */
    else do:
        put stream out-stream
            space(5) string( "Примечание: " + (if not( t-doc.PS begins "@" ) then t-doc.PS else "" ) ) format "X(160)"
        .
    end.        /* NOT ( p-mode = "mag"  ) */
    put stream out-stream
        space(5) "дата" format "X(4)" AT 175 "| " AT 180 /*(if t-doc.status_ = {&fact} then t-doc.fact-date else ? ) format "99/99/9999"*/v-torgconf-vdoc-date "|" AT 198 skip

        space(5) "Вид операции" format "X(12)" at 167 "| " at 180
                        (if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                        then ( if lookup( "Mari":U, p-mode ) = 0
                            then "возврат пост-ку"
                            else "":U )
                        else ( if t-doc.doc-type = {&income} and not Invers
                            then " приход"
                            else ( if t-doc.doc-type = {&return}
                                    then ( if lookup( "Mari":U, p-mode ) = 0
                                            then " возврат"
                                            else "":U )
                                    else " расход" ) )
                        )                                                  format "X(16)" "|" at 198 skip

        space(5) v-single-line format  "X(19)" AT 180 skip
        space(64) v-single-line format "X(33)" skip
        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                    + string( tdoc-code, "X(16)") + " | "
                                    + v-doc-date-string
                                    + " | " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(64) v-single-line format "X(33)" skip
        .

    if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        if lookup( "Mari":U, p-mode ) = 0
        then do:
            PUT STREAM Out-Stream
                skip space(10) "Возврат товара поставщику." format "X(120)"
            .
        end.
    end.
end.
end procedure. /* print-header */



/*==========================================================================*/
procedure calc-in-vat-doc-line :
define output parameter p-price-no-vat  as decimal          no-undo.
do
on error undo, return error
:
    { str/in-vatp.i calc ub.doc-line. t-doc. g }
    assign
        p-price-no-vat = ( if PrintRubl
                           then price-rubl-without-tax-loc
                           else price-base-without-tax-loc ) .
end.
end procedure. /* calc-in-vat-doc-line */

/*==========================================================================*/
procedure calc-out-vat-gds-dtl :
define output parameter p-price-no-vat  as decimal          no-undo.
do
on error undo, return error
:
    { str/out-vatp.i calc-gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
    assign
        p-price-no-vat = ( if PrintRubl
                           then price-rubl-with-tax-sale - vat-rubl-buyer - slt-rubl-sale - road-tax-rubl-sale
                           else price-base-with-tax-sale - vat-base-buyer - slt-base-sale - road-tax-base-sale  )
    .
end.
end procedure. /* calc-out-vat-gds-dtl */