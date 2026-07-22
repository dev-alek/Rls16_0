block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthtrg12.p $
$Archive: rep/wthtrg12.p $

Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:
    rec_id       as recid       - recid( trn-doc ) документа
    Invers       as logical     -  =?       - печатать партии для возврата поставщику
    p-mode       as integer     -  ="mag"   - не печатать номер документа, и форма без двух последних колонок (для Магамакса)
    p-from-check as logical     -  печатать данные продаж по чекам
Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter Invers               as logical          no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-round              as character        no-undo.
define input parameter p-reverse              as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthtrg12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wthtrg12.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ cmp/breakstr.i    }
{ gbl/cur-time.i    }
{ rep/fmtcli.i      }
{ rep/torgconf.i    }
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ str/getctxtp.i def}
{ rep/p-fmt.i       }
{ str/wthgds.i      }
{ gbl/paramls.i     }
{ rep/torg12xl.i    }
{ str/wthcalib.i    }

define stream out-stream .

define shared variable PrintScale   as logical                          no-undo.
define shared variable CostPrice    as logical                          no-undo.
define shared variable sort-name    as logical                          no-undo.
define shared variable sort-gr      as logical                          no-undo.
define shared variable print-graft  as logical                          no-undo.


    define variable tdoc-prt            as logical                          no-undo.

    define variable v-rootnode-code     as integer                          no-undo.

    define variable v-line-counter      as integer                          no-undo.
    define variable v-doc-line-counter  as integer                          no-undo.
    define variable txt-LC              as char                             no-undo.
    define variable s1                  as char                             no-undo.
    define variable s2                  as char                             no-undo.

    define variable v-node-code         like    ub.gds-prt.upper-code          no-undo.
    define variable v-artic             as character    no-undo.

    define variable price-noNDS         like ub.doc-line.price-base            no-undo.
    define variable price-withNDS       like ub.doc-line.price-base            no-undo.
    define variable tqnty               like ub.doc-line.doc-qnty              no-undo.
    define variable stoim-noNDS         like ub.doc-line.price-base            no-undo.
    define variable stoim               like ub.doc-line.price-base            no-undo.
    define variable prt-tqnty           like ub.doc-line.doc-qnty              no-undo.
    define variable prt-VAT-gds         like ub.ot-line.VAT-base               no-undo.
    define variable prt-SLT-gds         like ub.ot-line.SLT-base               no-undo.
    define variable prt-stoim-noNDS     like ub.doc-line.price-base            no-undo.
    define variable prt-stoim           like ub.doc-line.price-base            no-undo.

    define variable  v-sum-tot-qnty     as decimal                          no-undo.

    define variable v-VAT-gds           like ub.ot-line.VAT-base               no-undo.
    define variable v-SLT-gds           like ub.ot-line.SLT-base               no-undo.
    define variable v-price-withNDS     like ub.doc-line.price-base            no-undo.

    define variable Pg-tqnty            like ub.doc-line.doc-qnty      init 0  no-undo.
    define variable Pg-VAT-gds          like ub.ot-line.VAT-base       init 0  no-undo.
    define variable Pg-SLT-gds          like ub.ot-line.SLT-base       init 0  no-undo.
    define variable Pg-stoim-noNDS      like ub.doc-line.price-base    init 0  no-undo.
    define variable Pg-stoim            like ub.doc-line.price-base    init 0  no-undo.
    define variable PrevPage            as integer                  init 0  no-undo.

    define variable VAT-gds             like ub.ot-line.VAT-base               no-undo.
    define variable SLT-gds             like ub.ot-line.SLT-base               no-undo.

    define variable v-prt-name          as char                             no-undo.

    define variable v-okei                as char                             no-undo.
    define variable tb-code             as char                             no-undo.
    define variable pack-type           as char                             no-undo.
    define variable qnty-opl            like ub.doc-line.doc-qnty              no-undo.
    define variable qnty-pl             like ub.doc-line.doc-qnty              no-undo.
    define variable mass                as decimal     decimals 10          no-undo.

    define variable v-tax-name          as char                             no-undo.
    define variable v-tax-price         like ub.doc-line.road-tax      init 0  no-undo.
    define variable v-tax               like ub.doc-line.road-tax      init 0  no-undo.
    define variable v-tax-sum           like ub.doc-line.road-tax      init 0  no-undo.
    define variable v-parts-tax-qnty    like ub.doc-line.doc-qnty      init 0  no-undo.
    define variable v-tax-parts-price   like ub.doc-line.road-tax      init 0  no-undo.
    define variable v-gds-name          as character    no-undo.

    define variable sym1                as char     init ":" no-undo.
    define variable sym2                as char     init ":" no-undo.
    define variable sym3                as char     init ":" no-undo.
    define variable sym4                as char     init ":" no-undo.
    define variable sym5                as char     init ":" no-undo.
    define variable sym6                as char     init ":" no-undo.
    define variable sym7                as char     init ":" no-undo.
    define variable sym8                as char     init ":" no-undo.
    define variable sym9                as char     init ":" no-undo.
    define variable sym10               as char     init ":" no-undo.
    define variable sym11               as char     init ":" no-undo.
    define variable sym12               as char     init ":" no-undo.
    define variable sym13               as char     init ":" no-undo.
    define variable sym14               as char     init ":" no-undo.
    define variable sym15               as char     init ":" no-undo.
    define variable sym16               as char     init ":" no-undo.
    define variable sym17               as char     init ":" no-undo.
    define variable sym18               as char     init ":" no-undo.
    define variable sym19               as char     init ":" no-undo.

    define variable v-single-line       as char              no-undo.
    define variable v-underline         as char              no-undo.
    define variable v-char-counter      as int               no-undo.

    define variable gds-str             as char              no-undo.
    define variable gds-str1            as char              no-undo.
    define variable gds-str2            as char              no-undo.
    define variable unit-str            as char              no-undo.
    define variable val-str             as char              no-undo.
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
    define variable v-par-type                  as character                no-undo.
    define variable v-host-code                 as integer                  no-undo.
    define variable v-curr-code                 as integer                  no-undo.
    define variable tmp-var                     as character                no-undo.
    define variable FullGdsName                 as logical                  no-undo.
    define variable v-sort-artic                as logical                  no-undo.
         /* Определение переменных для грузополучателя */
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo.
define variable v-print-doc                 as character                 no-undo.


    define buffer buf_tax_parts     for ub.parts.
    define buffer buf_clients       for ub.clients .
    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_currency      for ub.currency.
    define buffer buf_shop          for ub.shop.

do
for buf_tax_parts
  , buf_clients
  , buf_wth-doc
  , buf_currency
  , buf_shop
on error undo, return error
:
{ gbl/working.i }
run wthgds-calc-price-group in this-procedure (
    input p-doc-code
).
find first temp_wthgds_price-group no-error.
if not available temp_wthgds_price-group
then do:
    { gbl/stopwork.i }
    undo, return.
end.
assign
    v-sort-artic = print-graft
.
assign
    p-mode = caps( p-mode )
.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
{ str/getctxtp.i get p-mainmenu-handle }
find first buf_wth-doc no-lock
     where buf_wth-doc.doc-code = p-doc-code
.
assign
    v-torgconf-ext-doc-type = buf_wth-doc.ext-doc-type
.
/*if buf_wth-doc.doc-type = {&income}*/
/*and buf_wth-doc.exter_  = yes*/
/*then do:*/
/*    assign*/
/*        Invers = yes*/
/*    .*/
/*end.*/
{ gbl/hostcode.i
    buf_wth-doc.obj-type
    buf_wth-doc.obj-code
    v-host-code
}
/* Не убирать. Пока МЦ печатаются только в р_ублях */
ASSIGN
   printRubl = YES
.
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
      input "wthtrg12"
    , input v-host-code
    , input buf_wth-doc.obj-type
    , input buf_wth-doc.obj-code
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
      input buf_wth-doc.obj-type
    , input buf_wth-doc.obj-code
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
/*То что нужно для Грузополучателя */

run torgconf-get-wthrecepient-param (
    input  buf_wth-doc.doc-code
  , output v-code-rec
  , output v-type-rec
  , output v-codefirm-rec
  , output v-curcode-rec
    ).
run torgconf-get-sup-param in this-procedure (
      input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
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
run torgconf-get-ship-param in this-procedure (
      input buf_wth-doc.host-code
    , input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
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

run torgconf-get-cli-param in this-procedure (
      input buf_wth-doc.host-code
    , input buf_wth-doc.cli-type
    , input buf_wth-doc.cli-code
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


{ gbl/getsect.i run buf_wth-doc.obj-type buf_wth-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .


{ gbl/getsect.i run buf_wth-doc.obj-type buf_wth-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .


&scop gds-len 27
&scop gds-len-m 52
define frame f-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len})" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-okei COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!  НДС! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        SLT-gds column-label "Сумма!НП! ! ! " format "->>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-withNDS COLUMN-LABEL "Цена!с учетом!  НДС! ! " format "->>>>>>>9.99" space(0)
        sym18 column-label ":!:!:!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_wth-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_wth-doc.status_ )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

define frame f-doc-m
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len-m})" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-okei COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!  НДС! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_wth-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_wth-doc.status_ )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    run torg12xl-init in this-procedure .

    assign
        v-single-line = fill("-", 230)
        v-underline = fill("_", 230)
        v-line-counter = 1
        v-doc-line-counter = 1
    .
    find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    run print-header in this-procedure (
        input buf_currency.curr-abbr
    ).
    if v-torgconf-outt12 = yes
    then do:
        form with frame f-doc-m .
        if sort-gr = yes
        then do:
            down stream out-stream 1 with frame f-doc-m .
        end.
    end.        /* v-torgconf-outt12 = yes */
    else do:
        form with frame f-doc .
        if sort-gr = yes
        then do:
            down stream out-stream 1 with frame f-doc .
        end.
    end.        /* NOT ( v-torgconf-outt12 = yes ) */

    for each temp_wthgds_price-group
    :
        run print-line in this-procedure (
              input temp_wthgds_price-group.gds-code
            , input temp_wthgds_price-group.price-rubl
            , input temp_wthgds_price-group.vat-pc
        ).
        accumulate
            tqnty ( TOTAL )
            VAT-gds ( TOTAL )
            SLT-gds ( TOTAL )
            stoim-noNDS ( TOTAL )
            stoim ( TOTAL )
        .
    end.

    if line-counter( out-stream ) + 14 > page-size( out-stream ) then
        do:
            { rep/wthtrg12.i itog }
            page stream out-stream .
        end.
    hide stream out-stream frame BottomFrame .


    { rep/wthtrg12.i itog }

    assign
        v-sum-tot-qnty = (accum total tqnty)
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-it_qnty}
        , input string( v-sum-tot-qnty )
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-it_SumNoVAT}
        , input string(accum total stoim-noNDS)
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-it_VATsum}
        , input string(accum total VAT-gds)
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-it_sum}
        , input string( (accum total stoim) + (accum total SLT-gds) )
    ).
    if v-torgconf-outt12 = yes
    then do:
        display stream out-stream
            "Всего по накладной" @ v-gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
        with frame f-doc-m .
        down stream out-stream 2 with frame f-doc-m .
    end.        /* v-torgconf-outt12 = yes */
    else do:
        display stream out-stream
            "Всего по накладной" @ v-gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
            (accum total SLT-gds)  @ SLT-gds
        with frame f-doc .
        down stream out-stream 2 with frame f-doc .
    end.        /* NOT ( v-torgconf-outt12 = yes ) */

    if PrintRubl then
        run rep/wp-rub.p ( ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    else
        run rep/wp.p ( input p-mainmenu-handle, ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
    put stream out-stream
        space(10) "  Всего на сумму:        "
            trim( string( ( ( accum total stoim ) + (accum total SLT-gds) ), "->>>,>>>,>>>,>>>,>>9.99") ) format "X(25)"
            " ("
            trim( ( if Invers then buf_currency.curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) ) format "X(7)"
            ")"
    .
    put stream out-stream
        space(30) string( "НДС: " + trim( string( (accum total VAT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                    " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
    .
    define variable v-doc-places    as character    no-undo.
    assign
        v-doc-places = v-underline
    .
    put stream out-stream
        skip
        space(10) string( "Товарная накладная имеет приложение на " + v-underline ) format "X(125)" skip
        space(10) string( "и содержит " + CAPS( txt-LC ) + " порядковый(ых) номер(ов) записей") format "X(180)" skip
        v-underline format "X(29)" at 151 skip
        string( "Масса груза (нетто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        space(10) string( "Всего мест " + v-doc-places ) format "X(45)"
                string( "Масса груза (брутто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( v-underline, "X(42)" ) + " листах" ) format "X(95)" "|" at 97
            string( "По доверенности N " +
            IF p-torgconf-ndovwho = "":U
            THEN
            (string( v-underline, "X(39)" ) + " от " + v-underline)
            ELSE
            p-torgconf-ndovwho
            ) format "X(100)" at 99 skip
        "Всего отпущено на сумму " format "X(95)" "|" at 97
            IF p-torgconf-ndovwho = "":U
            THEN
            string( "выданной " + v-underline )
            ELSE
            "":U

         format "X(100)" at 99 skip
        space(2) CAPS(s1) format "X(93)" "|" at 97 skip
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-N_ndovwho}
        , input(p-torgconf-ndovwho)
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_lineAmount}
        , input CAPS( txt-LC )
    ).
    assign
        s1 = breakstr( s1, {&torg12xl-f_sumLiteral1-length}, input-output s1, input-output s2)
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_sumLiteral1}
        , input s1
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_sumLiteral2}
        , input s2
    ).
    if trim(v-torgconf-main-buh) = ""
    or v-torgconf-outsubs <> no
    then do:
      v-torgconf-main-buh = "________________________":U.
    end.

    put stream out-stream
        "Отпуск разрешил: "
    .
    if trim(v-torgconf-ogr-post) = "":U
    or v-torgconf-outsubs <> no
    then do:
        put stream out-stream
            ": _____________"
        .
    end.
    else do:
        put stream out-stream
        space(6)   string( v-torgconf-ogr-post) format "X(19)"
        .
    end.
   if trim(v-torgconf-ogr-name) = ""
    or v-torgconf-outsubs <> no
    then do:
      v-torgconf-ogr-name = "________________________":U.
    end.

    define variable v-deliver    as character    no-undo.
    define variable v-deliv      as character    no-undo.
    define variable v-accept       as character    no-undo.

    FIND FIRST buf_clients
         WHERE buf_clients.obj-type = {&prs}
           AND buf_clients.obj-code = buf_wth-doc.deliver
         NO-LoCK
         NO-ERROR
         .
    IF AVAILABLE buf_clients
    THEN DO:
      ASSIGN
         v-deliver = buf_clients.obj-name
      .
    END.
    ASSIGN
      v-deliv = IF  buf_wth-doc.doc-type = {&income}
               OR  buf_wth-doc.doc-type = {&return}
               THEN v-underline
               ELSE IF v-deliver = "":U
                    OR v-torgconf-outsubs = yes
                                    THEN v-underline
                                    ELSE v-deliver
    .
    ASSIGN
      v-accept  = IF  buf_wth-doc.doc-type = {&income}
               OR  buf_wth-doc.doc-type = {&return}
               THEN IF v-deliver = "":U
                    OR v-torgconf-outsubs = yes
                                    THEN v-underline
                                    ELSE v-deliver
               ELSE IF p-torgconf-accept-fname = "":U
                    OR v-torgconf-outsubs = yes
                                    THEN v-underline
                                    ELSE p-torgconf-accept-fname
    .
    put stream out-stream
        string( "___________________ / " +  v-torgconf-ogr-name ) format "X(52)" "/ |":U at 95 skip
        string( "Главный бухгалтер: ________________________________ / " +  v-torgconf-main-buh ) format "X(93)" "/ |" at 95 skip
        string( "Отпуск груза произвел кладовщик: " + v-deliv ) format "X(95)" "|" at 97
        /*"|" at 97*/ string( "Груз принял: " + v-accept
                                    ) format "X(100)" at 99 skip

        v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99 skip
        "М.П." at 15  "|" at 97 "М.П." at 99 skip
    .
    run torg12xl-write-cell-data in this-procedure (
           input {&torg12xl-f_permitterStatus}
         , input ( if v-torgconf-outsubs = no then v-torgconf-ogr-post else "":U )
      ).

    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_permitterName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-ogr-name else "":U )
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_buhName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
    ).

    IF  buf_wth-doc.doc-type = {&income}
    OR  buf_wth-doc.doc-type = {&return}
    THEN DO:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-accept_fname}
        , input ( if v-torgconf-outsubs = no  then v-deliver else "":U )
      ).
    END.
    ELSE DO:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_wkr_name}
        , input ( if v-torgconf-outsubs = no  then v-deliver else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-accept_fname}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-fname else "":U )
      ).
    END.
    run torg12xl-close in this-procedure (input p-mode) .

    output stream out-stream close.
    { gbl/stopwork.i }
    { rep/q-print.i 8}

end.


/*====================================================================*/
procedure print-line :
define input parameter p-gds-code   as integer          no-undo.
define input parameter p-price-rubl as decimal          no-undo.
define input parameter p-vat-pc     as decimal          no-undo.

    define variable v-price-is-changed      as logical  no-undo.

    define variable v-sum-prt-qnty                  as decimal      no-undo.
    define variable v-avg-prt-price                 as decimal      no-undo.
    define variable v-avg-prt-price-no-tax          as decimal      no-undo.
    define variable v-sum-SLT                       as decimal      no-undo.
    define variable v-sum-VAT                       as decimal      no-undo.
    define variable v-avg-VAT                       as decimal      no-undo.
    define variable v-sum-prt-sum-with-tax          as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax          as decimal      no-undo.
    define variable v-sum-prt-sum-without-tax       as decimal      no-undo.
    define variable v-avg-prt-sum-without-tax       as decimal      no-undo.
    define variable v-gds-name-length               as integer      no-undo.
    define variable v-void-decimal                  as decimal      no-undo.
    define variable v-price-no-VAT                  as decimal      no-undo.
    define variable v-VAT-pc                        as decimal      no-undo.
    define variable v-SLT-pc                        as decimal      no-undo.

    define buffer buf_temp_wthgds_price-group       for temp_wthgds_price-group.
    define buffer buf_country                       for ub.country.
    define buffer buf_units                         for ub.units.
    define buffer buf_goods                         for ub.goods.
do
for buf_temp_wthgds_price-group
  , buf_country
  , buf_units
  , buf_goods
on error undo, return error
:
    find first buf_temp_wthgds_price-group
         where buf_temp_wthgds_price-group.gds-code   = p-gds-code
           and buf_temp_wthgds_price-group.price-rubl = p-price-rubl
           and buf_temp_wthgds_price-group.vat-pc     = p-vat-pc
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = buf_temp_wthgds_price-group.gds-code
    .
    assign
        v-gds-name-length = ( if v-torgconf-outt12 = yes then {&gds-len-m} else {&gds-len} )
    .
    run get-okei in this-procedure (
          input buf_goods.unit-base
        , output v-okei
    ).
    if FullGdsName
    then do:
        gds-str1 = breakstr(buf_goods.gds-name, v-gds-name-length, input-output gds-str1, input-output gds-str2).
        assign v-char-counter = 0.
        do while gds-str2 <> "" :
            assign
                gds-str = gds-str2
                gds-str1 = breakstr(gds-str, v-gds-name-length, input-output gds-str1, input-output gds-str2)
                v-char-counter = v-char-counter + 1
            .
        end. /* do while ... */
        if line-counter( out-stream ) + v-char-counter > page-size( out-stream )
        then do:
            { rep/wthtrg12.i itog }
            PAGE stream out-stream.
        end.
        assign
            gds-str1 = breakstr(buf_goods.gds-name, v-gds-name-length, input-output gds-str1, input-output gds-str2)
        .
    end.
    else do:
        assign
            gds-str1 = buf_goods.gds-name
        .
    end.
    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = buf_goods.prt-root
    .
    assign
        v-rootnode-code = ub.gds-prt.node-code
    .
    { gbl/gdsbcode.i
        buf_goods.gds-code
        v-rootnode-code
        tb-code
    }
    assign
        tqnty    = buf_temp_wthgds_price-group.qnty
        unit-str = buf_goods.unit-base
    .
    if Invers
    then do:
        assign
            VAT-gds       = varprice-vat
            SLT-gds       = varprice-slt
            price-withNDS = varprice-no-vat-slt + VAT-gds + SLT-gds
        .
    end.
    else do:
        assign
            VAT-gds         = ( if tqnty = 0.0
                                then 0.0
                                else ( if PrintRubl
                                then buf_temp_wthgds_price-group.sum-vat-rubl / tqnty
                                else buf_temp_wthgds_price-group.sum-vat-base / tqnty ) )
            SLT-gds         = 0.0
            v-tax-price     = 0.0
            price-withNDS   = ( if PrintRubl
                                then buf_temp_wthgds_price-group.price-rubl
                                else buf_temp_wthgds_price-group.price-base )
            v-tax           = 0.0
            v-tax-sum       = 0.0
        .
    end.
    if VAT-gds = ? then assign VAT-gds = 0.
    if SLT-gds = ? then assign SLT-gds = 0.
    assign
        price-noNDS = price-withNDS - VAT-gds - SLT-gds
    .
    if p-round = "round":U
    then do:
        run p-fmt-round in this-procedure (
              input tqnty
            , input price-noNDS
            , input VAT-gds
            , input SLT-gds
            , input 0
            , output price-noNDS
            , output v-VAT-pc
            , output v-void-decimal  /* v-SLT-pc */
            , output VAT-gds
            , output v-void-decimal  /* SLT-gds  */
            , output v-void-decimal
            , output stoim-noNDS
            , output stoim
        ).
        assign
            stoim           = stoim - SLT-gds
            price-withNDS   = stoim / tqnty
        .
    end.
    else do:
        assign
            VAT-gds     = VAT-gds * tqnty
            SLT-gds     = SLT-gds * tqnty
            stoim-noNDS = price-noNDS * tqnty
            stoim       = stoim-noNDS + VAT-gds
        .
    end.
    assign
        v-artic = buf_goods.artic
    .
    if v-torgconf-outt12 = yes
    then do:
        display stream out-stream
            v-doc-line-counter
            v-artic
            gds-str1 @ v-gds-name
            tb-code
            unit-str @ ub.goods.unit-base
            v-okei
            tqnty
            price-noNDS
            stoim-noNDS
            p-vat-pc @ ub.doc-line.VAT-pc
            VAT-gds when tqnty <> 0
            stoim
            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
            sym11 sym12 sym13 sym14 sym15 sym16 sym19
        with frame f-doc-m.
        down stream out-stream 1 with frame f-doc-m.
    end.        /* v-torgconf-outt12 = yes */
    else do:
        display stream out-stream
            v-doc-line-counter
            v-artic
            gds-str1 @ v-gds-name
            tb-code
            unit-str @ ub.goods.unit-base
            v-okei
            tqnty
            price-noNDS
            stoim-noNDS
            p-vat-pc @ ub.doc-line.VAT-pc
            VAT-gds when tqnty <> 0
            stoim
            SLT-gds when tqnty <> 0
            price-withNDS
            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19
        with frame f-doc.
        down stream out-stream 1 with frame f-doc.
    end.        /* NOT ( v-torgconf-outt12 = yes ) */
    run torg12xl-write-line-data in this-procedure (
          input v-doc-line-counter
        , input substitute( "&1 &2", buf_goods.artic, buf_goods.gds-name )
        , input string( tb-code )
        , input unit-str
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input string( tqnty )
        , input string( price-noNDS )
        , input string( stoim-noNDS )
        , input string( p-vat-pc    )
        , input string( VAT-gds )
        , input string( stoim + SLT-gds )
    ).
    { rep/wthtrg12.i " " v-gds-name-length }
    assign
        v-line-counter     = v-line-counter + 1
        v-doc-line-counter = v-doc-line-counter + 1
    .
end.
end procedure. /* print-line */


/*==========================================================================*/
procedure print-header :
define input parameter p-currency-curr-abbr as character        no-undo.

    define variable v-print-doc                 as character                no-undo.

    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_clients       for ub.clients.
    define buffer buf_shop          for ub.shop.
    define buffer buf_temp_p-fmt_string-part    for temp_p-fmt_string-part.

do
for buf_wth-doc
  , buf_clients
  , buf_shop
on error undo, return error
:
    find first buf_wth-doc no-lock
         where buf_wth-doc.doc-code = p-doc-code
    .
    run gbl/conf-rd.p (
          input "factur01":U
        , input ""
        , input ""
        , input 0
        , input ""
        , input ""
        , input ""
        , input no
        , output v-print-doc
        , output v-par-type
    ) no-error.
    if error-status :error
    then do:
        assign
            v-print-doc = "no"
        .
    end.
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_wth-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_wth-doc.doc-date
        , input buf_wth-doc.fact-date
        , input buf_wth-doc.doc-type
        , input buf_wth-doc.status_
        , input p-reverse
        , input no
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_docCode}
        , input v-torgconf-doc-code
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_tbl_docCode}
        , input v-torgconf-doc-code
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_docDate}
        , input v-torgconf-doc-date
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_tbl_docDate}
        , input v-torgconf-doc-date
    ).
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_wth-doc.obj-type
           and buf_clients.obj-code = buf_wth-doc.obj-code
    no-error.
    case buf_clients.obj-type :
        when {&shop}
        then do:
            find first ub.shop where ub.shop.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = ub.shop.doc-prt.
        end.
        when {&stock}
        then do:
            find first ub.store where ub.store.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = ub.store.doc-prt .
        end.
    end case.
    if not tdoc-prt or Invers = yes
    then do:
        assign
            PrintScale = no
        .
    end.
    form header
        v-single-line format "X(198)" at 1 SKIP
        "Продолжение - на следующей странице" at 30 SKIP
        with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
    view stream out-stream frame BottomFrame .
    /*
    if not buf_wth-doc.print-rubl and not Invers then
        message "Документ печатать в {&abbr_rublyah_allshift} ?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
    else
        assign PrintRubl = yes .
    */
    assign
        val-str = ( if Invers then p-currency-curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) )
    .
    if v-torgconf-outappr = yes
    then do:
        put stream out-stream
                 "Унифицированная форма № ТОРГ-12"                                at 137
            skip "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137
        .
    end.
    put stream out-stream
        space(5) v-single-line          format  "X(19)"     at 180 skip
        space(5) "| "                                       at 180
            {&g___code}                                     at 188
            "|"                                             at 198 skip
        space(5) "Форма по ОКУД"        format "X(14)"      at 166
        "| "                                                at 180
        "0330212"
        "|"                                                 at 198 skip
    .
    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input v-torgconf-organization
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
            if buf_temp_p-fmt_string-part.str-key = 1
            then do:
                put stream out-stream
                    space(5) buf_temp_p-fmt_string-part.string-part format "X(160)"
                            "по ОКПО"                               format "X(7)"   at 172
                            "| "                                        at 180
                            v-torgconf-okpo                         format "X(16)"
                            "|"                                         at 198 skip
                .
            end.
            else do:
                put stream out-stream
                    space(16) buf_temp_p-fmt_string-part.string-part format "X(149)"
                            "       "                               format "X(7)"   at 172
                            "| "                                        at 180
                            " "                                     format "X(16)"
                            "|"                                         at 198 skip
                .
            end.
        end.
    end.
    else do:
        put stream out-stream
        space(5) v-torgconf-organization    format "X(160)"
                 "по ОКПО"                  format "X(7)"   at 172
                 "| "                                       at 180
                 v-torgconf-okpo            format "X(16)"
                 "|"                                        at 198 skip
        .
    end.
       put stream out-stream

        space(5)  v-torgconf-client-from    format "X(160)"
                 "| "                                       at 180
                 "|"                                        at 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)"  at 155
                 "| "                                       at 180
                 "|"                                        at 198 skip
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_OKPO_0}
        , input v-torgconf-okpo
    ).
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_orgFrom}
        , input v-torgconf-organization
    ).
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_cliFrom}
        , input v-torgconf-client-from
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoTo}
        , input v-torgconf-torg12-cargo-label
    ).
   /* run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input v-torgconf-torg12-cargo-value
    ).*/
   if ( buf_wth-doc.doc-type = {&income}
   or buf_wth-doc.doc-type = {&return} )
   and buf_wth-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
   and buf_wth-doc.ext-doc-type <> {&WDEDT_Put_Cli}
   then do:
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input v-torgconf-torg12-cargo-value
    ).
   end.
   else do:
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input v-torgconf-consignee
    ).

   end.

    if v-torgconf-self-obj-type = {&shop}
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = v-torgconf-self-obj-code
        no-error.
        if available buf_shop
        then do:
            case buf_wth-doc.doc-type
            :
                when {&expense}
                then do:
/*                    assign*/
/*                        v-torgconf-torg12-cargo-string = substitute( "Грузополучатель : &1, &2", v-torgconf-self-obj-name, buf_shop.addres1 )*/
/*                    .*/
                end.        /* when {&expense} */
                when {&return}
                then do:
/*                    assign*/
/*                        v-torgconf-torg12-cargo-string = substitute( "Грузополучатель : &1, &2", v-torgconf-self-obj-name, buf_shop.addres1 )*/
/*                    .*/
/*                    assign*/
/*                        v-torgconf-torg12-cargo-string = substitute( "Грузоотправитель: &1, &2", v-torgconf-self-obj-name, buf_shop.addres1 )*/
/*                    .*/
                end.        /* when {&income} */
            end case.       /* case buf_wth-doc.doc-type */
        end.
    end.
    put stream out-stream
        space(5) v-torgconf-torg12-cargo-string      format "X(160)"
                "по ОКПО"          format "X(7)"       at 172
                "| "                                   at 180
                v-torgconf-torg12-cargo-okpo         format "X(16)"
                "|"                                    at 198
        skip
    .
    put stream out-stream
        space(5) string( "Поставщик: " + v-torgconf-supplier )      format "X(160)"
                 "по ОКПО"                                          format "X(7)"   at 172
                 "| "                                                               at 180
                 v-torgconf-supplier-okpo                            format "X(16)"
                 "|"                                                                at 198 skip
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_OKPO}
        , input v-torgconf-torg12-cargo-okpo
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_OKPO2}
        , input v-torgconf-supplier-okpo
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_OKPO3}
        , input v-torgconf-saler-okpo
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_supplier}
        , input v-torgconf-supplier
    ).
    define variable v-attr-value  as character no-undo .
    define variable v-attr-type   as character no-undo .
    define variable v-osnov       as character initial "" no-undo .
/*    if buf_wth-doc.doc-type = {&income}*/
/*    then  do:*/
/*        run gbl/trdcat-v.p (input buf_wth-doc.doc-code,input {&trdcattr-nids},output v-attr-value,output v-attr-type) .*/
/*        assign v-osnov = v-attr-value .*/
/*        run gbl/trdcat-v.p (input buf_wth-doc.doc-code,input {&trdcattr-dids},output v-attr-value,output v-attr-type) .*/
/*        assign v-osnov = v-osnov + " от " + v-attr-value .*/
/*    end.*/
    { str/wthatval.i
        buf_wth-doc.doc-code
        {&wthcattr-reason}
        v-osnov
        v-attr-type
    }
    put stream out-stream
        space(5) string( "Плательщик: " + v-torgconf-saler )                                 format "X(160)"
                        "по ОКПО" format "X(7)" at 172 "| " at 180 v-torgconf-saler-okpo format "X(16)" "|" at 198 skip
        space(5) string( "Основание: " + v-osnov ) format "X(160)"
                        "номер" format "X(5)" at 174 "| " at 180  "|" at 198 skip
    .
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_saler}
        , input v-torgconf-saler
    ).
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_reason}
        , input v-osnov
    ).
    if v-torgconf-outprim = yes
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "MAG"  */
    else do:
        put stream out-stream
            space(5) string( "Примечание: " + ( if not( buf_wth-doc.PS begins "@" )
                                                then replace( buf_wth-doc.PS, {&new-line}, " " )
                                                else "" ) )                         format "X(163)"
        .
    end.        /* NOT ( p-mode = "MAG"  ) */
    put stream out-stream
                        "дата" format "X(4)" at 175 "| " at 180 "|" at 198 skip
        space(5) string( "Вид оплаты: " ) format "X(130)"
                        string( "Транспортная накладная " ) format "X(23)" at 147
                        "номер" format "X(5)" at 174 "| " at 180 v-torgconf-doc-code format "X(16)" "|" at 198 skip
        space(64) v-single-line format "X(33)"
        space(5) "дата" format "X(4)" at 175 "| " at 180 v-torgconf-doc-date format "X(10)" "|" at 198 skip
    .
    define variable v-operation-type    as character    no-undo.
/*if buf_wth-doc.doc-type = {&income}*/
/*and buf_wth-doc.exter_  = yes*/
    assign
        v-operation-type = ( if buf_wth-doc.doc-type = {&income} and not Invers and buf_wth-doc.exter_  = no
                                    then " приход"
                                    else ( if buf_wth-doc.doc-type = {&income} and buf_wth-doc.exter_
                                           then " возврат"
                                           else " расход" ) )
    .
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_operationType}
        , input v-operation-type
    ).
    put stream out-stream
        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                    + string( v-torgconf-doc-code, "X(16)") + " | "
                                    + v-torgconf-doc-date
                                    + " | " + (if buf_wth-doc.status_ <> {&fact} then string( "(" + CAPS(buf_wth-doc.status_) + ")" ) else "")
                                    ) format "X(100)"
        space(5) "Вид операции"   format "X(12)"    at 167
                 "| "                               at 180
                 v-operation-type format "X(16)"
                 "|"                                at 198 skip
        space(64) v-single-line format "X(33)"
        space(5) v-single-line format  "X(19)" at 180 skip

/*        space(64) v-single-line format "X(33)" skip*/
/*        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "*/
/*                                    + string( v-torgconf-doc-code, "X(16)") + " | "*/
/*                                    + v-torgconf-doc-date*/
/*                                    + " | " + (if buf_wth-doc.status_ <> {&fact} then string( "(" + CAPS(buf_wth-doc.status_) + ")" ) else "")*/
/*                                    ) format "X(100)" skip*/
/*        space(64) v-single-line format "X(33)"*/
        .
end.
end procedure. /* print-header */


/*==========================================================================*/
procedure get-okei :
define input parameter p-unit-base as character        no-undo.
define output parameter p-okei as character        no-undo.

    define buffer buf_units         for ub.units.
do
for buf_units
on error undo, return error
:
    find first buf_units no-lock
         where buf_units.unit-name = p-unit-base
    no-error.
    if available buf_units
    and buf_units.OKEI <> 0
    then do:
        assign
            p-okei = string( buf_units.OKEI, ">999":U )
        .
    end.
    else do:
        assign
            p-okei = "":U
        .
    end.
end.
end procedure. /* get-okei */