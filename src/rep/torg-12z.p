block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: torg-12z.p $
$Archive: rep/torg-12z.p $

Форма Torg-12 со спецификой ювелирных товаров

Автор: Демин Алексей Сергеевич
Дата создания: 04/08/03
Author: Alexey Demin
Creation date: 04/08/03

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: torg-12z.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/torg-12z.p $":U .
define variable vss-description as character no-undo initial "Форма Torg-12 со спецификой ювелирных товаров":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i       }
{ cmp/breakstr.i     }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ trg/partrqst.i     }
{ rep/r-cliprp.i def }
{ str/lib-trn.i      }
{ rep/fmtcli.i       }
{ rep/torgconf.i     }
{ str/getctxtp.i def }

   &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

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
DEFINE SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

DEFINE Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

&Scop Sort-pole  if sort-gr then  goods.grp-name Else goods.artic


define shared variable CostPrice    as logical      no-undo.
define shared variable PrintScale   as logical      no-undo.

DEFINE STREAM Out-Stream .


define buffer t-doc for trn-doc.
define buffer OurObject   for clients .
define buffer SecObject   for clients .

define variable FullNameGds         as character            no-undo .
define variable tdoc-prt            as logical              no-undo.

define variable tdoc-code           like trn-doc.doc-code   no-undo.
define variable v-doc-date-string   as character            no-undo.

define variable rootnode_code       as integer              no-undo.

define variable LineCounter         as integer              no-undo.
define variable txt-LC              as character            no-undo.
define variable s1                  as character            no-undo.
define variable s2                  as character            no-undo.

define variable Node_Code       like    gds-prt.upper-code  no-undo.

define variable price-noNDS     as decimal     no-undo.
define variable price-withNDS   as decimal     no-undo.
define variable tqnty                  as decimal     no-undo.
define variable stoim-noNDS     as decimal     no-undo.
define variable stoim                  as decimal     no-undo.
define variable prt-tqnty                  as decimal     no-undo.
define variable prt-VAT-gds        as decimal     no-undo.
define variable prt-SLT-gds        as decimal     no-undo.
define variable prt-stoim-noNDS     as decimal     no-undo.
define variable prt-stoim                  as decimal     no-undo.

define variable Pg-tqnty                as decimal     init 0 no-undo.
define variable Pg-VAT-gds      as decimal     init 0 no-undo.
define variable Pg-SLT-gds      as decimal     init 0 no-undo.
define variable Pg-stoim-noNDS   as decimal     init 0 no-undo.
define variable Pg-stoim               as decimal     init 0 no-undo.
define variable PrevPage              as integer             init 0 no-undo.

define variable VAT-gds          as decimal     no-undo.
define variable SLT-gds          as decimal     no-undo.

define variable PrtName      as character    no-undo.

define variable OKEI      as integer    no-undo.
define variable tb-code      as character    no-undo.
define variable pack-type      as character    no-undo.
define variable qnty-opl          as decimal    no-undo.
define variable qnty-pl          as decimal     no-undo.
define variable mass          as decimal     no-undo.

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

define variable v-single-line      as character    no-undo.
define variable UndLine      as character    no-undo.
define variable v-print-doc         as character                no-undo.
define variable v-par-type          as character                no-undo.

define variable gds-str as character no-undo.
define variable gds-str1 as character no-undo.
define variable gds-str2 as character no-undo.
define variable unit-str as character no-undo.
define variable val-str as character no-undo.

define variable i as integer no-undo.
define variable j as integer no-undo.

define variable v-no-print-last-col         as logical       no-undo.
define variable v-host-code                 as integer       no-undo.
define variable v-curr-code                 as integer       no-undo.

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

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
define variable FullGdsName        as logical   no-undo .
FullGdsName = true .

&scop gds-len 26
DEFINE FRAME f-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        LineCounter COLUMN-LABEL " N !п/п! ! ! " format ">>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(16)" space(0)
        goods.gds-name COLUMN-LABEL "Наименование товара ! ! ! ! " format "X({&gds-len})" space(1)
        goods.sort COLUMN-LABEL "Проба! ! ! ! " format "X(5)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(10)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL  "Ед.!----!Наим!енов!ание" format "X(4)" space(0)
        sym5 column-label               " !-!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL            "изм.!----!Код !по!ОКЕИ":C4 format ">>>>" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Колич!-----!в!одном!месте":C5 format ">>9.<" space(0)
        sym8 column-label "е!-!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "ство  !------!мест! ! ":C6 format ">>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! ":C5 format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество! ! ! ! ":C11 format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!НДС и НП! ! ! ":C10 format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!НДС и НП! ! ! ":C14 format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.VAT-pc column-label " !-----!Став-! ка !% ":C5 format ">9.9<" space(0)
        sym14 column-label  " !-!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "НДС         !--------------!Сумма!НДС! ":C14 format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!НДС (без НП)! ! ":C14 format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SLT-gds column-label "Сумма!НП! ! ! ":C11 format "->>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-withNDS COLUMN-LABEL "Цена!с учетом!НДС и НП! ! ":C12 format "->>>>>>>9.99" space(0)
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
        LineCounter COLUMN-LABEL " N !п/п! ! ! " format ">>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(16)" space(0)
        goods.gds-name COLUMN-LABEL "Наименование товара ! ! ! ! " format "X({&gds-len})" space(1)
        goods.sort COLUMN-LABEL "Проба! ! ! ! " format "X(5)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(10)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.unit-base COLUMN-LABEL  "Ед.!----!Наим!енов!ание" format "X(4)" space(0)
        sym5 column-label               " !-!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL            "изм.!----!Код !по!ОКЕИ":C4 format ">>>>" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Колич!-----!в!одном!месте":C5 format ">>9.<" space(0)
        sym8 column-label "е!-!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "ство  !------!мест! ! ":C6 format ">>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! ":C5 format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество! ! ! ! ":C11 format ">>>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!НДС и НП! ! ! ":C10 format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!НДС и НП! ! ! ":C14 format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.VAT-pc column-label " !-----!Став-! ка !% ":C5 format ">9.9<" space(0)
        sym14 column-label  " !-!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "НДС         !--------------!Сумма!НДС! ":C14 format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!НДС (без НП)! ! ":C14 format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SLT-gds column-label "Сумма!НП! ! ! ":C11 format "->>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-withNDS COLUMN-LABEL "Цена!с учетом!НДС и НП! ! ":C12 format "->>>>>>>9.99" space(0)
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
      input "torg12z"
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
{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

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
assign
    v-single-line = fill("-", 230)
    UndLine = fill("_", 230)
    LineCounter = 1
.
if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = "          "
    .
end.        /* v-torgconf-outnum = yes  */
else do:
    if invers
    then do:
        assign
            tdoc-code = entry( 1, t-doc.doc-code, "-" )
        no-error.
        if tdoc-code = ""
        then do:
            assign
                tdoc-code = substr( t-doc.doc-code, 1, 2 )
                            + string( month( t-doc.doc-date ), "99" )
                            + string( day( t-doc.doc-date ), "99" )
            .
        end.
        else
            assign
                tdoc-code = string( month( t-doc.doc-date ), ">9" )
                            + trim( string( day( t-doc.doc-date ), ">9" ) )
                            + string( integer( tdoc-code ))
            .
    end.
    else do:
        assign
            tdoc-code = t-doc.doc-code
        .
    end.
end.        /* NOT ( v-torgconf-outnum = yes  ) */
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = "          "
    .
end.        /* v-torgconf-outdate = yes  */
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> {&fact}
                            then string( t-doc.doc-date, "99/99/9999")
                            else string( t-doc.fact-date, "99/99/9999") )
    .
end.        /* NOT ( v-torgconf-outdate = yes  ) */


find first OurObject no-lock
     where OurObject.obj-type = t-doc.obj-type
       and OurObject.obj-code = t-doc.obj-code
no-error.

CASE OurObject.obj-type :
    when {&shop}
    then do:
            find first shop no-lock
                 where shop.obj-code = OurObject.obj-code
            .
            assign
                tdoc-prt = shop.doc-prt
            .
    end.
    when {&stock}
    then do:
            find first store no-lock
                 where store.obj-code = OurObject.obj-code
            .
            assign
                tdoc-prt = store.doc-prt
            .
    end.
end case.


if Invers
then do:
    find first SecObject no-lock
        where SecObject.obj-type = t-doc.cli-type
          and SecObject.obj-code = t-doc.cli-code
    no-error.
end.
else do:
    find first SecObject no-lock
        where SecObject.obj-type = t-doc.obj-type
          and SecObject.obj-code = t-doc.obj-code
    no-error.
end.

if tdoc-prt = no
then do:
    assign
        PrintScale = no
    .
end.

{ gbl/working.i }
{ cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4} }

FORM HEADER
    v-single-line format "X(198)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM Out-Stream FRAME BottomFrame .

FIND currency WHERE currency.curr-code = t-doc.exch-code NO-LOCK.
assign val-str = ( if Invers then currency.curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) ).



FIND pay-type WHERE pay-type.obj-code = t-doc.pay-code NO-LOCK NO-ERROR .


if Invers then
    FIND clients WHERE clients.obj-type = t-doc.cli-type AND
                                       clients.obj-code = t-doc.cli-code NO-LOCK .
else
    FIND clients WHERE clients.obj-type = {&cmp} AND
                                       clients.obj-code = t-doc.host-code NO-LOCK .

{ rep/r-cliprp.i }


PUT STREAM Out-Stream
    space(5) v-single-line format  "X(19)" AT 180 skip
    space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
    space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0330212" "|" AT 198 skip
    space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                              + t-addres + t-phone)
                              + (if t-doc.internal = yes and t-doc.doc-type = {&income}
                                then ", " + SecObject.obj-name + " (" + string(SecObject.obj-code) + ")"
                                else "")                        format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
    space(5) ( if t-doc.doc-type <> {&income} then
                       string( CAPS( OurObject.obj-name ) + " (" + string(OurObject.obj-code) + ")" )
                     else
                        " "
                    ) format "X(160)" "| " AT 180  "|" AT 198 skip
    space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
    .

if Invers
then do:
    find first clients no-lock
         where clients.obj-type = {&cmp}
           and clients.obj-code = t-doc.host-code
    .
end.
else do:
    find first clients no-lock
         where clients.obj-type = t-doc.cli-type
           and clients.obj-code = t-doc.cli-code
    .
end.
{ rep/r-cliprp.i }
PUT STREAM Out-Stream
    space(5) string( (if t-doc.doc-type = {&income} AND NOT Invers then "Грузоотправитель: " else "Грузополучатель: ")
                              + "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ") "
                              + t-addres + " " + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 v-torgconf-torg12-cargo-okpo format "X(16)" "|" AT 198 skip
    .

if t-doc.doc-type = {&income} then
    FIND clients WHERE clients.obj-type = t-doc.cli-type AND
                                       clients.obj-code = t-doc.cli-code NO-LOCK .
else
    FIND clients WHERE clients.obj-type = {&cmp} AND
                                       clients.obj-code = t-doc.host-code NO-LOCK .

put stream out-stream
    space(5) string( "Поставщик: " + v-torgconf-suppi )      format "X(160)"
                "по ОКПО"                                          format "X(7)"   at 172
                "| "                                                               at 180
                v-torgconf-supplier-okpo                            format "X(16)"
                "|"                                                                at 198 skip
.


if t-doc.doc-type <> {&income} then
    FIND clients WHERE clients.obj-type = t-doc.cli-type AND
                                       clients.obj-code = t-doc.cli-code NO-LOCK .
else
    FIND clients WHERE clients.obj-type = {&cmp} AND
                                       clients.obj-code = t-doc.host-code NO-LOCK .

  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-osnov       as character initial "" no-undo .
  if t-doc.doc-type = {&income} then  do:
    run gbl/trdcat-v.p (
          input t-doc.doc-code
        , input {&trdcattr-nids}
        , output v-attr-value
        , output v-attr-type
    ).
    assign v-osnov = v-attr-value .
    run gbl/trdcat-v.p (
          input t-doc.doc-code
        , input {&trdcattr-dids}
        , output v-attr-value
        , output v-attr-type
    ).
    assign v-osnov = v-osnov + " от " + v-attr-value .
  end.

put stream out-stream
    space(5) string( "Плательщик: " + v-torgconf-saler )                                 format "X(160)"
                    "по ОКПО" format "X(7)" at 172 "| " at 180 v-torgconf-saler-okpo format "X(16)" "|" at 198 skip
    space(5) string( "Основание: " + v-osnov ) format "X(160)"
                    "номер" format "X(5)" AT 174 "| " AT 180  "|" AT 198 skip
    space(5) string( "Примечание: " + (if NOT( t-doc.PS BEGINS "@" ) then t-doc.PS else "" ) ) format "X(160)"
                    "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
    space(5) string( "Вид оплаты: " + ( if available pay-type then pay-type.obj-name else "?" ) ) format "X(130)"
                    string( "Транспортная накладная " ) format "X(23)" AT 147
                    "номер" format "X(5)" AT 174 "| " AT 180 v-torgconf-vdoc-code format "X(16)" "|" AT 198 skip
    space(5) "дата" format "X(4)" AT 175 "| " AT 180 /*(if t-doc.status_ = {&fact} and v-torgconf-outdate = no then t-doc.fact-date else ? ) format "99/99/9999"*/v-torgconf-vdoc-date "|" AT 198 skip
    space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180
                    ( if t-doc.doc-type = {&income} AND NOT Invers then " приход" else " расход" ) format "X(16)" "|" AT 198 skip
    space(5) v-single-line format  "X(19)" AT 180 skip
    space(64) v-single-line format "X(33)" skip
    space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                + string( tdoc-code, "X(16)") + " | "
                                + v-doc-date-string
                                + " | " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                ) format "X(100)" skip
    space(64) v-single-line format "X(33)"
    .

if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
then do:
    PUT STREAM Out-Stream skip space(10) "Возврат товара поставщику." format "X(120)".
end.

assign
    v-torgconf-outt12 = no
.
if v-torgconf-outt12 = yes
then do:
    form with frame f-doc-m .
end.        /* v-no-print-last-col = yes */
else do:
    form with frame f-doc .
end.        /* NOT ( v-no-print-last-col = yes ) */
/*-----------------------------------------------------------------------------------------------------------------------*/
FOR  EACH doc-line where doc-line.doc-code = t-doc.doc-code NO-LOCK,
    FIRST goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK
                         BREAK BY {&Sort-pole} &if "{&sort-prod}" = "yes" &then BY ( doc-line.prod-type + string( doc-line.prod-code ) ) &endif BY doc-line.artic   :
/* полное название на несколько строк */
     FullNameGds = Trim(goods.gds-name) + " " + Trim(goods.PS) .
    gds-str1 = breakstr(FullNameGds,  {&gds-len}, input-output gds-str1, input-output gds-str2).
    assign j = 0.
    DO WHILE gds-str2 <> "" :
        assign gds-str = gds-str2.
        gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
        assign j = j + 1.
    END. /* DO WHILE ... */
    if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then
        do:
            { rep/torg-12n.i itog " " torg-12z }
            PAGE STREAM Out-Stream.
        end.
    gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output gds-str1, input-output gds-str2).

        FIND first bar-code WHERE bar-code.gds-code = goods.gds-code
                            AND bar-code.unit-cli = goods.unit-base
                            AND bar-code.part-code = ""
                            AND bar-code.in-code = ""
                          NO-LOCK .
        FIND first Units   WHERE units.unit-name = goods.unit-base  NO-LOCK .
        assign OKEI = Units.OKEI
               mass = doc-line.wt-brutto .

            if Invers then
                do:
                define variable old-qnty like  tqnty no-undo.
                    assign
                        tqnty = doc-line.fact-qnty
                        unit-str = doc-line.unit-cli
                        old-qnty = tqnty .

                    if units.type = "{&bef-divisional},{&bef-twounit}" then DO:
                          run partrqst in this-procedure
                            (input  doc-line.doc-code        /* p-doc-code               */
                            ,input  doc-line.obj-type        /* p-obj-type               */
                            ,input  doc-line.obj-code        /* p-obj-code               */
                            ,input  doc-line.artic           /* p-artic                  */
                            ,input  doc-line.prod-type       /* p-prod-type              */
                            ,input  doc-line.prod-code       /* p-prod-code              */
                            &scop partrqst-prefix v-total-parts-
                            {&partrqst-param}
                            ).
                            Assign
                              qnty-pl = v-total-parts-fact-cli-qnty /* doc-line.cli-qnty */
                              tqnty    = qnty-pl
                              .
                            End.
                      Else   qnty-pl = goods.wt-cart     .
                   { str/in-vat.i
                    t-doc.doc-code
                    t-doc.base-rate
                    t-doc.base-scale
                    t-doc.exch-rate
                    t-doc.exch-scale
                    t-doc.vat-type
                    t-doc.slt-type
                    doc-line.artic
                    doc-line.prod-type
                    doc-line.prod-code
                    doc-line.price-cli
                    doc-line.cli-base-rate
                    doc-line.price-rubl
                    doc-line.vat-pc
                    doc-line.slt-pc
                    doc-line.road-tax
                    doc-line.transport-rubl
                    doc-line.other-rubl
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
                    assign
                        VAT-gds = varprice-vat
                        SLT-gds = varprice-slt
                        price-withNDS = varprice-no-vat-slt + VAT-gds + SLT-gds
                        .
                end.
            else /* ПРИХОДЫ */
                do:
                    if units.type = "{&bef-divisional},{&bef-twounit}" then   DO:
                          run partrqst in this-procedure
                            (input  doc-line.doc-code        /* p-doc-code               */
                            ,input  doc-line.obj-type        /* p-obj-type               */
                            ,input  doc-line.obj-code        /* p-obj-code               */
                            ,input  doc-line.artic           /* p-artic                  */
                            ,input  doc-line.prod-type       /* p-prod-type              */
                            ,input  doc-line.prod-code       /* p-prod-code              */
                            &scop partrqst-prefix v-total-parts-
                            {&partrqst-param}
                            ).

                    qnty-pl = v-total-parts-fact-cli-qnty /* doc-line.cli-qnty */ .
                    End.
                    Else    qnty-pl = goods.wt-cart.
                    assign
                        tqnty = doc-line.fact-qnty
                        unit-str = goods.unit-base
                        .
                      if t-doc.doc-type = {&income} and CostPrice then
                          do:
                          { str/in-vatp.i calc doc-line. t-doc. g }
                          assign
                              VAT-gds = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                              SLT-gds = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                              price-withNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
                              .
                            End.
                       Else do:
                            { str/out-vatp.i calc doc-line. t-doc.  }
                            assign
                                VAT-gds = ( if PrintRubl then vat-rubl-sale else vat-base-sale )
                                SLT-gds = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
                                price-withNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                                .
                        end.

                end.
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                price-noNDS = price-withNDS - VAT-gds - SLT-gds
                VAT-gds = VAT-gds * tqnty
                SLT-gds = SLT-gds * tqnty
                stoim-noNDS = price-noNDS * tqnty
                stoim = stoim-noNDS + VAT-gds
                .
                if Invers then tqnty = old-qnty.

    if sort-gr = true  and first-of ({&Sort-pole}) THEN DO:
      DOWN stream Out-Stream 1 with FRAME f-doc .
      PUT stream Out-Stream UNFORMATTED
           String("_Группа : " + TRIM(CAPS(goods.grp-name))) Format "x(198)"
           Skip .
           End.

            DISPLAY STREAM Out-Stream
                LineCounter
                gds-str1 @ goods.gds-name
                goods.artic
                goods.sort
                string( bar-code.b-code ) @ tb-code
                unit-str @ goods.unit-base
                OKEI       when (units.okei > 0 )
                qnty-opl   when (qnty-opl > 0 )
                qnty-pl    when (qnty-pl > 0 )
                mass  when (mass > 0)
                tqnty
                price-noNDS
                stoim-noNDS
                doc-line.VAT-pc
                VAT-gds when tqnty <> 0
                stoim
                SLT-gds when tqnty <> 0
                price-withNDS
                sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                with frame f-doc .
            DOWN STREAM Out-Stream 1 with FRAME f-doc .
            { rep/torg-12n.i " " {&gds-len} torg-12z }
            LineCounter = LineCounter + 1.

    ACCUMULATE
        tqnty (TOTAL)
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
        qnty-pl ( TOTAL )
        .
END.        /*FOR  EACH doc-line ...*/

if line-counter( Out-Stream ) + 20 > page-size( Out-Stream ) then
    do:
        { rep/torg-12n.i itog " " torg-12z }
        page STREAM Out-Stream .
    end.
HIDE STREAM Out-Stream FRAME BottomFrame .
{ rep/torg-12n.i itog " " torg-12z }

DISPLAY STREAM Out-Stream
    "Всего по накладной" @ goods.gds-name
    t-doc.fact-qnty @ tqnty
    (accum total qnty-pl) @ qnty-pl
    (accum total stoim-noNDS) @ stoim-noNDS
    (accum total VAT-gds)  @ VAT-gds
    (accum total stoim) @ stoim
    (accum total SLT-gds)  @ SLT-gds
    with frame f-doc .
DOWN STREAM Out-Stream 2 with FRAME f-doc .

if PrintRubl then
    run rep/wp-rub.p ( ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
run rep/wp-qnty.p ( input ( LineCounter - 1 ), output txt-LC).
PUT STREAM Out-Stream
    space(10) string( "Всего на сумму: " + trim( string( ( ( accum total stoim ) + (accum total SLT-gds) ), "->>>,>>>,>>>,>>>,>>9.99") ) + " (" +
                                trim( ( if Invers then currency.curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) ) + ")" ) format "X(180)"
.
if t-doc.doc-type <> {&income}
and v-torgconf-outdisc = no
then do:
    put stream out-stream
        skip
        space(15) string( "В том числе "
                        + ( if not invers and ( if printrubl then t-doc.discnt-rubl else t-doc.tot-calc ) < 0
                            then "наценка: "
                            else "скидка: " )
                        + ( if not invers
                            then trim( string( abs( ( if printrubl
                                                    then t-doc.discnt-rubl
                                                    else t-doc.tot-calc ) ), ">>>,>>>,>>>,>>>,>>9.99") )
                            else "0.00" )
                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"
                ) format "X(160)"
    .
end.
PUT STREAM Out-Stream
    skip
    space(30) string( "НДС: " + trim( string( (accum total VAT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
.
if (accum total SLT-gds) <> 0
then do:
    PUT STREAM Out-Stream
        SKIP
        space(19) string( "налог с продаж: " + trim( string( (accum total SLT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                    " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
    .
end.
define variable v-doc-places    as character    no-undo.
run gbl/trdcat-v.p (
      input t-doc.doc-code
    , input {&trdcattr-qntyplace}
    , output v-doc-places
    , output v-attr-type
).
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
{ gbl/stopwork.i }
{ rep/q-print.i 8 }