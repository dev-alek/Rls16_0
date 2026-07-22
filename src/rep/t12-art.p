block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: t12-art.p $
$Archive: rep/t12-art.p $

Печатные формы. Торг-12  без двух последних столбцов и с артикулом поставщика

Автор: Хныкин Павел Андреевич
Дата создания: 11/28/05
Author: Pavel Khnykin
Creation date: 11/28/05

Input:
    rec_id       as recid       - recid( trn-doc ) документа

*/

define input parameter parparentproc as handle    no-undo.
define input parameter rec_id        as recid     no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: t12-art.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/t12-art.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-12  без двух последних столбцов и с артикулом поставщика".
{ cmp/vssrevis.i    }

do
on error undo, return error return-value
:
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ cmp/breakstr.i    }
{ gbl/cur-time.i    }
{ cmp/croslist.i    }
{ str/hvrdtax.i     }
{ rep/fmtcli.i      }
{ str/trdcalib.i    }
{ gbl/clntattr.i    }
{ rep/torgconf.i    }
{ rep/r-sym.i       }
{ str/clcprtsl.i " " doc }
{ str/out-vatp.i def}
{ str/in-vatp.i def }
{ gbl/tax-name.i    }
{ str/getctxtp.i def}

define buffer t-doc             for ub.trn-doc.
define buffer buf_tax_parts     for ub.parts.
define buffer buf_goods         for ub.goods.
define buffer buf_clients       for ub.clients .
define buffer buf_firm          for ub.firm.
define buffer buf_sysconf       for ub.sysconf.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_cli-gds       for ub.cli-gds.
define buffer buf_parts         for ub.parts.
define buffer buf_rep_currency  for ub.currency.
define buffer buf_trn-doc       for ub.trn-doc.

define stream out-stream .

/* шареные параметры отчета */
define shared var PrintScale   as logical                          no-undo.
define shared var CostPrice    as logical                          no-undo.
define shared var sort-name    as logical                          no-undo.
define shared var sort-gr      as logical                          no-undo.

define variable g#report-num        as integer                          no-undo.
define variable g#quest-print       as logical                          no-undo.
define variable g#log               as logical                          no-undo.
define variable g#doc-prt           as logical                          no-undo.

define variable tdoc-prt            as logical                          no-undo.

define variable v-rootnode-code     as integer                          no-undo.

define variable v-line-counter      as integer                          no-undo.
define variable v-doc-line-counter  as integer                          no-undo.
define variable txt-LC              as char                             no-undo.
define variable s1                  as char                             no-undo.
define variable s2                  as char                             no-undo.
define variable base-type           like ub.currency.curr-abbr          no-undo.
define variable v-node-code         like ub.gds-prt.upper-code          no-undo.

define variable price-noNDS         like ub.doc-line.price-base         no-undo.
define variable price-withNDS       like ub.doc-line.price-base         no-undo.
define variable tqnty               like ub.doc-line.doc-qnty           no-undo.
define variable stoim-noNDS         like ub.doc-line.price-base         no-undo.
define variable stoim               like ub.doc-line.price-base         no-undo.
define variable prt-tqnty           like ub.doc-line.doc-qnty           no-undo.
define variable prt-VAT-gds         like ub.ot-line.VAT-base            no-undo.
define variable prt-SLT-gds         like ub.ot-line.SLT-base            no-undo.
define variable prt-stoim-noNDS     like ub.doc-line.price-base         no-undo.
define variable prt-stoim           like ub.doc-line.price-base         no-undo.

define variable  v-sum-tot-qnty     as decimal                          no-undo.

define variable v-VAT-gds           like ub.ot-line.VAT-base               no-undo.
define variable v-SLT-gds           like ub.ot-line.SLT-base               no-undo.
define variable v-price-withNDS     like ub.doc-line.price-base            no-undo.

define variable Pg-tqnty            like ub.doc-line.doc-qnty      init 0  no-undo.
define variable Pg-VAT-gds          like ub.ot-line.VAT-base       init 0  no-undo.
define variable Pg-SLT-gds          like ub.ot-line.SLT-base       init 0  no-undo.
define variable Pg-stoim-noNDS      like ub.doc-line.price-base    init 0  no-undo.
define variable Pg-stoim            like ub.doc-line.price-base    init 0  no-undo.
define variable PrevPage            as int     init 0   no-undo.

define variable VAT-gds             like ub.ot-line.VAT-base               no-undo.
define variable SLT-gds             like ub.ot-line.SLT-base               no-undo.

define variable v-prt-name          as char                             no-undo.

define variable OKEI                as char                             no-undo.
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
define variable v-ext-doc-type              as character                no-undo.
define variable v-first-part-for-goods      as logical                  no-undo.
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo .



find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
assign
    v-ext-doc-type = t-doc.ext-doc-type
.
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

find first buf_rep_currency no-lock where buf_rep_currency.curr-code = v-curr-code no-error .
if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
    run torgconf-get-recepient-param (
    input  t-doc.doc-code
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
      input t-doc.host-code
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

run torgconf-read in this-procedure (
      input "torg12"
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

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

&scop gds-len 40
define frame f-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(16)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len})" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код!товара! ! ! " format "X(9)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.cli-gds.cli-art COLUMN-LABEL "Артикул!поставщика! ! ! " format "X(14)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>9.<<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        price-withNDS COLUMN-LABEL "Цена!с учетом!  НДС и НП! ! " format "->>>>>>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС И НП! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym17 column-label ":!:!:!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС (без НП)! ! " format "->>>,>>>,>>9.99" space(0)
        sym18 column-label ":!:!:!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                  string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 186 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
with width {&DOS_CW} down stream-io.
form header
        v-single-line format "X(198)" at 1 SKIP
        "Продолжение - на следующей странице" at 30 SKIP
with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .

{ gbl/working.i }
run get-report-num in parparentproc (output g#report-num).
run get-quest-print in parparentproc ( output g#quest-print ) .
{ str/getctxtp.i get parparentproc }

{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

assign
    v-single-line = fill("-", 230)
    v-underline = fill("_", 230)
    v-line-counter = 1
    v-doc-line-counter = 1
.

find first ub.currency no-lock
  where ub.currency.curr-code = t-doc.exch-code
.
run print-header in this-procedure .
form with frame f-doc .
if sort-gr = yes
then do:
  down stream out-stream 1 with frame f-doc .
end.
if sort-name = yes              /*Включена сортировка по имени*/
then do:
  if sort-gr = yes
  then do:
    for each ub.doc-line no-lock  /*сортировка по имени и группе*/
          where ub.doc-line.doc-code = t-doc.doc-code,
        each ub.goods no-lock
          where ub.goods.artic     = ub.doc-line.artic
            and ub.goods.prod-type = ub.doc-line.prod-type
            and ub.goods.prod-code = ub.doc-line.prod-code
        break by ub.goods.grp-name
              by ub.goods.gds-name
    :
      if first-of (ub.goods.grp-name)
      then do:
        run print-group-line in this-procedure.
      end.
      run print-line in this-procedure.
      accumulate
        tqnty ( TOTAL )
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
      .
    end.
  end.
  else do:
    for each ub.doc-line no-lock /*сортировка по имени */
          where ub.doc-line.doc-code = t-doc.doc-code,
        each ub.goods no-lock
          where ub.goods.artic     = ub.doc-line.artic
            and ub.goods.prod-type = ub.doc-line.prod-type
            and ub.goods.prod-code = ub.doc-line.prod-code
        break by ub.goods.gds-name
    :
      run print-line in this-procedure.
      accumulate
        tqnty ( TOTAL )
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
      .
    end.
  end.
end.                           /*Включена сортировка по имени*/
else do:                       /*Сортировка по имени выключена*/
  if sort-gr = yes
  then do:
    for each ub.doc-line no-lock /*сортировка по группе*/
          where ub.doc-line.doc-code = t-doc.doc-code,
        each ub.goods no-lock
          where ub.goods.artic     = ub.doc-line.artic
            and ub.goods.prod-type = ub.doc-line.prod-type
            and ub.goods.prod-code = ub.doc-line.prod-code
        break by ub.goods.grp-name
              by ub.doc-line.line-num
    :
      if first-of (goods.grp-name)
      then do:
        run print-group-line in this-procedure.
      end.
      run print-line in this-procedure.
      accumulate
        tqnty ( TOTAL )
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
      .
    end.
  end.
  else do:
    for each ub.doc-line no-lock /*без сортировки*/
          where ub.doc-line.doc-code = t-doc.doc-code,
        each ub.goods no-lock
          where ub.goods.artic     = ub.doc-line.artic
            and ub.goods.prod-type = ub.doc-line.prod-type
            and ub.goods.prod-code = ub.doc-line.prod-code
        break by ub.doc-line.line-num
    :
      run print-line in this-procedure.
      accumulate
        tqnty ( TOTAL )
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
      .
    end.
  end.
end.                           /*Сортировка по имени выключена*/

run print-itog in this-procedure
    (
        input accum TOTAL stoim-noNDS
      , input accum TOTAL VAT-gds
      , input accum TOTAL SLT-gds
      , input accum TOTAL stoim
    )
.
output stream out-stream close.
{ gbl/stopwork.i }
{ rep/q-print.i 8 }
end. /* main do*/


procedure print-header :
/*
  печать шапки документа
*/
define variable v-is-prt  as logical   no-undo .
do
on error undo, return error return-value
:
    define variable v-attr-value        as character              no-undo .
    define variable v-attr-type         as character              no-undo .
    define variable v-osnov             as character initial ""   no-undo .
    define variable v-operation-type    as character              no-undo .

    run torgconf-get-form-header in this-procedure (
          input no
        , input t-doc.doc-code
        , input "yes"
        , input t-doc.doc-date
        , input t-doc.fact-date
        , input t-doc.doc-type
        , input t-doc.status_
        , input no
        , input no
    ).
    find first buf_clients no-lock
         where buf_clients.obj-type = t-doc.obj-type
           and buf_clients.obj-code = t-doc.obj-code
    no-error.

    run gbl/conf-rd.p ("is-prt", t-doc.host-code, t-doc.obj-type, t-doc.obj-code, "", "", "", no, output tmp-var, output v-par-type ) no-error.
    IF error-status:error
    then do:
        assign
            v-is-prt = no
        .
    end.
    else do:
        assign
            v-is-prt = ( tmp-var = "yes" )
        .
    end.

    case buf_clients.obj-type :
        when {&shop}
        then do:
            find first ub.shop where ub.shop.obj-code = buf_clients.obj-code no-lock .
            assign
              tdoc-prt  = ub.shop.doc-prt
              g#doc-prt = (v-is-prt = yes ) and ub.shop.doc-prt
            .
        end.
        when {&stock}
        then do:
            find first ub.store where ub.store.obj-code = buf_clients.obj-code no-lock .
            assign
              tdoc-prt = ub.store.doc-prt
              g#doc-prt= (v-is-prt = yes ) and ub.store.doc-prt
            .
        end.
    end case.

    if not tdoc-prt
    then do:
        assign
            PrintScale = no
        .
    end.
    view stream out-stream frame BottomFrame .

    assign
        val-str = ( if PrintRubl then "{&abbr_rublyah}" else base-type )
    .
    find first ub.pay-type no-lock
         where ub.pay-type.obj-code = t-doc.pay-code
    no-error .

    if t-doc.doc-type = {&income}
    then  do:
        run gbl/trdcat-v.p (input t-doc.doc-code,input {&trdcattr-nids},output v-attr-value,output v-attr-type) .
        assign v-osnov = v-attr-value .
        run gbl/trdcat-v.p (input t-doc.doc-code,input {&trdcattr-dids},output v-attr-value,output v-attr-type) .
        assign v-osnov = v-osnov + " от " + v-attr-value .
    end.

    put stream out-stream
          skip(2) space(5) v-torgconf-organization                            format "X(160)"   skip
                  space(5)  v-torgconf-client-from                            format "X(160)"
          skip(2) space(5) v-torgconf-torg12-cargo-string                     format "X(160)"   skip
                  space(5) string( "Поставщик: " + v-torgconf-suppi )      format "X(160)"   skip
                  space(5) string( "Плательщик: " + v-torgconf-saler )        format "X(160)"   skip
                  space(5) string( "Основание: " + v-osnov )                  format "X(160)"   skip
    .

    if v-torgconf-outprim = no
    then do: /* печатать примечание. */
        put stream out-stream
            space(5) string( "Примечание: " + ( if not( t-doc.PS begins "@" ) then replace( t-doc.PS, {&new-line}, " " ) else "" ) ) format "X(163)"
        .
    end.
    assign
        v-operation-type = ( if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                             then "возврат пост-ку"
                             else ( if t-doc.doc-type = {&income} then " приход"
                                    else ( if t-doc.doc-type = {&return}
                                           then " возврат"
                                           else " расход" ) )
                           )
    .
    put stream out-stream
        skip space(5) string( "Вид оплаты: " + ( if available pay-type and ( index( pay-type.obj-name, "озврат":U ) = 0 ) then pay-type.obj-name else "":U ) ) format "X(130)"
        skip space(5) "Вид операции: "   format "X(14)" v-operation-type format "X(16)"
        skip(2) space(64) v-single-line format "X(33)" skip
        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                    + string( v-torgconf-doc-code, "X(16)") + " | "
                                    + v-torgconf-doc-date
                                    + " | " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(64) v-single-line format "X(33)"
    .

    if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        put stream out-stream
           skip space(10) "Возврат товара поставщику" format "X(120)"
        .
    end.
end.
end procedure. /* print-header */


procedure print-group-line :
/*
  Печать строки с названием группы
*/
do
on error undo, return error return-value
:
  put stream out-stream skip ":" space(5) "Группа:" space(2) ub.goods.grp-name.
end.
end procedure. /* print-group-line */


procedure print-line :
/*
  Печать линии документа (может разбиваться на несколько строк по партиям либо шкалам)
*/
do
on error undo, return error return-value
:
  define variable v-gds-name-length               as integer      no-undo.
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
  define variable v-void-decimal                  as decimal      no-undo.
  define variable v-price-no-VAT                  as decimal      no-undo.
  define variable v-VAT-pc                        as decimal      no-undo.
  define variable v-SLT-pc                        as decimal      no-undo.
  define variable v-gds-goods                     as logical      no-undo .

  assign
    v-gds-name-length = {&gds-len}
  .
  /*---S--------- Определили наименование товара -------------------*/
  if FullGdsName
  then do:
    gds-str1 = breakstr(ub.goods.gds-name, v-gds-name-length, input-output gds-str1, input-output gds-str2).
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
      { rep/t12-art.i itog }
      PAGE stream out-stream.
    end.
    assign
      gds-str1 = breakstr(ub.goods.gds-name, v-gds-name-length, input-output gds-str1, input-output gds-str2)
    .
  end.
  else do:
    assign
      gds-str1 = ub.goods.gds-name
    .
  end.
  /*---E--------- Определили наименование товара -------------------*/
  run get-okei in this-procedure ( input ub.goods.unit-base , output OKEI ) no-error.
  /*---S--------- Печать по шкалам или нет -------------------------*/
  find first ub.gds-prt no-lock
        where ub.gds-prt.upper-code = ub.goods.prt-root
  .
  assign
    v-rootnode-code = ub.gds-prt.node-code
  .
  if ( gds-prt.node-name <> {&empty-scale} ) and g#doc-prt = yes
  then do:
    /*---S--------- Не пустая шкала ----------------------------------*/
    find first ub.gds-dtl no-lock
          where ub.gds-dtl.prod-type = ub.doc-line.prod-type
            and ub.gds-dtl.prod-code = ub.doc-line.prod-code
            and ub.gds-dtl.artic     = ub.doc-line.artic
            and ub.gds-dtl.doc-code  = ub.doc-line.doc-code
    no-error.
    if not available (gds-dtl)     /*Если новый товар по шкалам еще не разбит, цены пока неизвестны*/
    then do:
      assign
        price-noNDS   = 0
        price-withNDS = 0
      .
    end.
    if PrintScale = yes
    then do:
      find first ub.parts no-lock
            where ub.parts.obj-type  = t-doc.obj-type
              and ub.parts.obj-code  = t-doc.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = t-doc.doc-code no-error.
      find first buf_cli-gds no-lock
            where buf_cli-gds.artic = ub.doc-line.artic
              and buf_cli-gds.prod-code = ub.doc-line.prod-code
              and buf_cli-gds.prod-type = ub.doc-line.prod-type
              and buf_cli-gds.cli-code = ub.parts.supp-code
              and buf_cli-gds.cli-type = ub.parts.supp-type
              and buf_cli-gds.host-code = v-host-code no-error.
      display stream out-stream
        v-doc-line-counter
        gds-str1 @ goods.gds-name
        ub.goods.artic
        buf_cli-gds.cli-art when available buf_cli-gds @ ub.cli-gds.cli-art
        OKEI
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
        sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
      with frame f-doc .
      down stream out-stream 1 with frame f-doc .
      assign
        v-line-counter = v-line-counter + 1
        v-doc-line-counter = v-doc-line-counter + 1
      .
    end. /* PrintScale = yes */

    for each gds-dtl no-lock                        /*Средняя цена для всех признаков. Если расход, то печатать ее*/
      where gds-dtl.prod-type  = doc-line.prod-type
        and gds-dtl.prod-code  = doc-line.prod-code
        and gds-dtl.artic      = doc-line.artic
        and gds-dtl.doc-code   = doc-line.doc-code
    :
      find first gds-prt no-lock
            where gds-prt.node-code = gds-dtl.prt-code.
      { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
      assign
         v-sum-prt-qnty  = v-sum-prt-qnty + gds-dtl.fact-qnty
         VAT-gds         = ( if PrintRubl then vat-rubl-buyer            else vat-base-buyer           )
         SLT-gds         = ( if PrintRubl then slt-rubl-sale             else slt-base-sale            )
         price-withNDS   = ( if PrintRubl then price-rubl-with-tax-sale  else price-base-with-tax-sale )
      .
      if VAT-gds = ?       then assign  VAT-gds       = 0.
      if SLT-gds = ?       then assign  SLT-gds       = 0.
      if price-withNDS = ? then assign  price-withNDS = 0.
      assign
        v-sum-VAT                 = v-sum-VAT                   + VAT-gds * gds-dtl.fact-qnty
        v-sum-prt-sum-with-tax    = v-sum-prt-sum-with-tax      + ( price-withNDS * gds-dtl.fact-qnty )
        v-sum-prt-sum-without-tax = v-sum-prt-sum-without-tax   + ( ( price-withNDS - VAT-gds - SLT-gds ) * gds-dtl.fact-qnty )
      .
    end.
    assign
       v-avg-VAT                   = ( if v-sum-VAT = ? or v-sum-VAT = 0
                                     then 0
                                     else v-sum-VAT / v-sum-prt-qnty )

       v-avg-prt-price             = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                     then 0
                                     else v-sum-prt-sum-with-tax / v-sum-prt-qnty )

       v-avg-prt-price-no-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                     then 0
                                     else v-sum-prt-sum-without-tax / v-sum-prt-qnty )

       v-avg-prt-sum-with-tax      = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                     then 0
                                     else v-sum-prt-sum-with-tax / v-sum-prt-qnty )

       v-avg-prt-sum-without-tax   = ( if v-sum-prt-qnty = ? or v-sum-prt-qnty = 0
                                     then 0
                                     else v-sum-prt-sum-without-tax / v-sum-prt-qnty )
   .

   run print-line-dtl in this-procedure
        (
              recid( doc-line )
            , input-output v-avg-VAT
            , input-output v-avg-prt-price
            , input-output v-avg-prt-price-no-tax
            , input-output v-avg-prt-sum-with-tax
            , input-output v-avg-prt-sum-without-tax
            , output prt-tqnty
            , output prt-VAT-gds
            , output prt-SLT-gds
            , output prt-stoim-noNDS
            , output prt-stoim
        ).
   { rep/t12-art.i prt- }
   accumulate
       prt-tqnty ( TOTAL )
       prt-VAT-gds ( TOTAL )
       prt-SLT-gds ( TOTAL )
       prt-stoim-noNDS ( TOTAL )
       prt-stoim ( TOTAL )
   .
   /*---S--------- Собираем все суммы -------------------------------*/
   assign
       tqnty = ( ACCUM TOTAL prt-tqnty )
       VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
       SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
       stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
       stoim = ( ACCUM TOTAL prt-stoim )
   .
   /*---E--------- Собираем все суммы -------------------------------*/

    if not PrintScale
    then do:
    /*---S--------- Если не надо печатать по признакам ---------------*/
      find first ub.bar-code no-lock
           where ub.bar-code.gds-code = ub.goods.gds-code
             and ub.bar-code.unit-cli = ub.goods.unit-base
             and ub.bar-code.node-code = v-rootnode-code
             and ub.bar-code.part-code = ""
             and ub.bar-code.in-code = ""
      .
      find first ub.parts no-lock
            where ub.parts.obj-type  = t-doc.obj-type
              and ub.parts.obj-code  = t-doc.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = t-doc.doc-code no-error.
      find first buf_cli-gds no-lock
            where buf_cli-gds.artic = ub.doc-line.artic
              and buf_cli-gds.prod-code = ub.doc-line.prod-code
              and buf_cli-gds.prod-type = ub.doc-line.prod-type
              and buf_cli-gds.cli-code = ub.parts.supp-code
              and buf_cli-gds.cli-type = ub.parts.supp-type
              and buf_cli-gds.host-code = v-host-code no-error.
      display stream out-stream
        v-doc-line-counter
        gds-str1 @ ub.goods.gds-name
        string( ub.bar-code.b-code ) @ tb-code
        ub.goods.artic
        buf_cli-gds.cli-art when available buf_cli-gds @ ub.cli-gds.cli-art
        ub.goods.unit-base
        tqnty
        stoim-noNDS
        ub.doc-line.VAT-pc
        VAT-gds when tqnty <> 0
        stoim
        price-withNDS
        OKEI
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
        sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
      with frame f-doc .
      down stream out-stream 1 with frame f-doc .
      assign
        v-line-counter     = v-line-counter + 1
        v-doc-line-counter = v-doc-line-counter + 1
      .
      if line-counter( out-stream ) + 1 > page-size( out-stream )
      then do:
        { rep/t12-art.i itog }
      end.
        /*---E--------- Если не надо печатать по признакам ---------------*/
    end.
        /*---E--------- Не пустая шкала ----------------------------------*/
  end.
  else do:
        /*---S--------- Пустая шкала -------------------------------------*/
    find first ub.bar-code no-lock
        where ub.bar-code.gds-code     = ub.goods.gds-code
            and ub.bar-code.unit-cli   = ub.goods.unit-base
            and ub.bar-code.node-code  = v-rootnode-code
            and ub.bar-code.part-code  = ""
            and ub.bar-code.in-code    = ""
        .
        { gbl/gdscdat.i
          ub.goods.gds-code
          'gds-goods=request':u
          v-gds-goods
        }
        if v-gds-goods = yes
        then do:
            for each ub.parts
               where ub.parts.obj-type     = ub.doc-line.obj-type
                 and ub.parts.obj-code     = ub.doc-line.obj-code
                 and ub.parts.artic        = ub.goods.artic
                 and ub.parts.prod-type    = ub.goods.prod-type
                 and ub.parts.prod-code    = ub.goods.prod-code
                 and ub.parts.out-code     = ub.doc-line.doc-code
            :
                /*---S--------- Для каждой партии --------------------------------*/
                if hvrdtax (recid(ub.goods)) and line-counter( Out-Stream ) + 2 > page-size( Out-Stream ) then
                do:
                    { rep/t12-art.i itog }
                    page stream out-stream .
                end.
                run print-line-parts in this-procedure
                    (
                        recid( ub.doc-line )
/*                      , input-output v-VAT-gds*/
/*                      , input-output v-SLT-gds*/
/*                      , input-output v-price-withNDS*/
/*                      , input-output v-tax*/
/*                      , input-output v-tax-price*/
/*                      , input-output v-tax-sum*/
                      , output prt-tqnty
                      , output prt-VAT-gds
                      , output prt-SLT-gds
                      , output prt-stoim-noNDS
                      , output prt-stoim
                    )
                .
                accumulate
                    prt-tqnty       ( TOTAL )
                    prt-VAT-gds     ( TOTAL )
                    prt-SLT-gds     ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim       ( TOTAL )
                .
                { rep/t12-art.i prt- v-gds-name-length }
                assign
                    v-line-counter     = v-line-counter + 1
                    v-doc-line-counter = v-doc-line-counter + 1
                .
                /*---E--------- Для каждой партии --------------------------------*/
            end.
            assign
                tqnty       = ( ACCUM TOTAL prt-tqnty )
                VAT-gds     = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds     = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim       = ( ACCUM TOTAL prt-stoim )
            .
            /*---E--------- Возврат поставщику: печать по партиям или стеклопосуды ------------*/
        end.
        else do:
                find first ub.gds-dtl no-lock
                     where ub.gds-dtl.doc-code    = ub.doc-line.doc-code
                       and ub.gds-dtl.prod-type   = ub.doc-line.prod-type
                       and ub.gds-dtl.prod-code   = ub.doc-line.prod-code
                       and ub.gds-dtl.artic       = ub.doc-line.artic
                       and ub.gds-dtl.prt-code    = v-rootnode-code
                no-error.
                if available ub.gds-dtl
                then do:
                    assign
                        tqnty    = ub.gds-dtl.fact-qnty
                    .
                end.
                else do:
                    assign
                        tqnty    = ub.doc-line.fact-qnty
                    .
                end.
                assign
                    unit-str = ub.goods.unit-base
                .
                if t-doc.doc-type = {&income}
                or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                or CostPrice
                then do:
                    { str/in-vatp.i calc ub.doc-line. t-doc. g }
                    assign
                        VAT-gds         = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                        SLT-gds         = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                        v-tax-price     = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
                        price-withNDS   = ( if PrintRubl
                                            then price-rubl-with-tax-loc - v-tax-price
                                            else price-base-with-tax-loc - v-tax-price
                                          )
                        v-tax           = v-tax-price * tqnty
                        v-tax-sum       = v-tax-sum + v-tax
                    .
                end.
                else do:
                    { str/out-vatp.i calc-gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
                    assign
                        VAT-gds         = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                        SLT-gds         = ( if PrintRubl then slt-rubl-sale  else slt-base-sale  )
                        v-tax-price     = ( if PrintRubl then road-tax-rubl-sale else road-tax-base-sale )
                        price-withNDS   = ( if PrintRubl
                                            then price-rubl-with-tax-sale - v-tax-price
                                            else price-base-with-tax-sale - v-tax-price
                                          )
                        v-tax           = v-tax-price * tqnty
                        v-tax-sum       = v-tax-sum + v-tax
                    .
                end.
                if VAT-gds = ? then assign VAT-gds = 0.
                if SLT-gds = ? then assign SLT-gds = 0.
                assign
                    price-noNDS = price-withNDS - VAT-gds - SLT-gds
                    VAT-gds     = VAT-gds * tqnty
                    SLT-gds     = SLT-gds * tqnty
                    stoim-noNDS = price-noNDS * tqnty
                    stoim       = stoim-noNDS + VAT-gds
                .
                display stream out-stream
                    v-doc-line-counter
                    ub.goods.artic
                    gds-str1 @ ub.goods.gds-name
                    string( ub.bar-code.b-code ) @ tb-code
                    unit-str @ ub.goods.unit-base
                    tqnty
                    stoim-noNDS
                    ub.doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    price-withNDS
                    OKEI
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                with frame f-doc.
                { rep/t12-art.i }
        end.
        /*---E--------- Пустая шкала -------------------------------------*/
  end.
end.
end procedure. /* print-line */


procedure print-line-dtl :

define input parameter p-doc-line-recid                     as recid            no-undo.
define input-output parameter p-avg-VAT                     as decimal          no-undo.
define input-output parameter p-avg-prt-price               as decimal          no-undo.
define input-output parameter p-avg-prt-price-no-tax        as decimal          no-undo.
define input-output parameter p-avg-prt-sum-with-tax        as decimal          no-undo.
define input-output parameter p-avg-prt-sum-without-tax     as decimal          no-undo.
define output parameter p-prt-tqnty                         as decimal          no-undo.
define output parameter p-prt-VAT-gds                       as decimal          no-undo.
define output parameter p-prt-SLT-gds                       as decimal          no-undo.
define output parameter p-prt-stoim-noNDS                   as decimal          no-undo.
define output parameter p-prt-stoim                         as decimal          no-undo.

define variable v-avg-prt-sum-without-tax-out               as decimal          no-undo.
define variable v-avg-prt-sum-with-tax-out                  as decimal          no-undo.
define variable v-avg-VAT-out                               as decimal          no-undo.
define variable v-VAT-pc                                    as decimal          no-undo.
define variable v-SLT-pc                                    as decimal          no-undo.
define variable v-void-decimal                              as decimal          no-undo.
define variable v-num-page                                    as integer          no-undo .
do
on error undo, return error return-value
:
    define buffer buf_doc-line for ub.doc-line.
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
        for each ub.gds-dtl no-lock
           where ub.gds-dtl.prod-type = buf_doc-line.prod-type
             and ub.gds-dtl.prod-code = buf_doc-line.prod-code
             and ub.gds-dtl.artic     = buf_doc-line.artic
             and ub.gds-dtl.doc-code  = buf_doc-line.doc-code
        :
            /*---S--------- Для каждого признака -----------------------------*/
            find first ub.gds-prt no-lock
                 where ub.gds-prt.node-code = ub.gds-dtl.prt-code
            .
            if CostPrice = yes
            then do:
                { str/in-vatp.i calc buf_doc-line. t-doc. g }
                assign
                    VAT-gds = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                    SLT-gds = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                    price-withNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
                .
            end.
            else do:
                { str/out-vatp.i calc-gds-dtl buf_doc-line. t-doc. ub.gds-dtl. }
                assign
                    VAT-gds = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    SLT-gds = ( if PrintRubl then slt-rubl-sale  else slt-base-sale  )
                    price-withNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
                .
            end.
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                price-noNDS     = price-withNDS - VAT-gds - SLT-gds
                prt-tqnty       = gds-dtl.fact-qnty
            .
            assign
                prt-VAT-gds       = VAT-gds           * prt-tqnty
                prt-SLT-gds       = SLT-gds           * prt-tqnty
                prt-stoim-noNDS   = price-noNDS       * prt-tqnty
                prt-stoim         = prt-stoim-noNDS   + prt-VAT-gds
                p-prt-tqnty       = p-prt-tqnty       + prt-tqnty
                p-prt-VAT-gds     = p-prt-VAT-gds     + prt-VAT-gds
                p-prt-SLT-gds     = p-prt-SLT-gds     + prt-SLT-gds
                p-prt-stoim-noNDS = p-prt-stoim-noNDS + prt-stoim-noNDS
                p-prt-stoim       = p-prt-stoim       + prt-stoim
            .
            if PrintScale
            then do:
                /*---S--------- Стоит галочка печати по признакам ----------------*/
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code  = ub.goods.gds-code
                       and ub.bar-code.unit-cli  = ub.goods.unit-base
                       and ub.bar-code.node-code = ub.gds-dtl.prt-code
                       and ub.bar-code.part-code = ""
                       and ub.bar-code.in-code = ""
                .
                v-prt-name = "".
                do while available ub.gds-prt:
                    if available ub.gds-prt
                    then assign
                        v-prt-name = "\" + string( ub.gds-prt.node-name, "x(10)" ) + v-prt-name
                    .
                    assign
                        v-node-code = ub.gds-prt.upper-code
                    .
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = v-node-code
                           and ub.gds-prt.root <> yes
                    no-error.
                end.
                if line-counter( Out-Stream ) + 3 > page-size( Out-Stream ) then
                do:
                    assign
                      v-num-page = page-number( out-stream )
                    .
                    { rep/t12-art.i itog }
                    if page-number( out-stream ) = v-num-page then page stream out-stream.
                    assign
                        Pg-tqnty = 0
                        Pg-VAT-gds = 0
                        Pg-SLT-gds = 0
                        Pg-stoim-noNDS = 0
                        Pg-stoim = 0
                        .
                end.
                if t-doc.doc-type = {&income}
                then assign
                    p-avg-prt-price             = price-withNDS
                    p-avg-prt-price-no-tax      = price-noNDS
                    p-avg-VAT                   = prt-VAT-gds
                    p-avg-prt-sum-with-tax      = prt-stoim
                    p-avg-prt-sum-without-tax   = prt-stoim-noNDS
                .
                else assign
                    v-avg-VAT-out                 = p-avg-VAT                  * ub.gds-dtl.fact-qnty
                    v-avg-prt-sum-with-tax-out    = p-avg-prt-sum-with-tax     * ub.gds-dtl.fact-qnty
                    v-avg-prt-sum-without-tax-out = p-avg-prt-sum-without-tax  * ub.gds-dtl.fact-qnty
                .
                if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                then do:
                    display stream out-stream
                        v-prt-name @ goods.gds-name
                        string( bar-code.b-code ) @ tb-code
                        ub.goods.unit-base
                        prt-tqnty                       @ tqnty
                        v-avg-prt-sum-without-tax-out   @ stoim-noNDS
                        buf_doc-line.VAT-pc             @ ub.doc-line.VAT-pc
                        v-avg-VAT-out                   @ VAT-gds
                        v-avg-prt-sum-with-tax-out      @ stoim
                        p-avg-prt-price                 @ price-withNDS
                        OKEI
                        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                        sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                    with frame f-doc.
                    down stream out-stream 1 with frame f-doc .
                end.        /* if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} */
                else do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            prt-tqnty @ tqnty
                            prt-stoim-noNDS @ stoim-noNDS
                            buf_doc-line.VAT-pc             @ ub.doc-line.VAT-pc
                            prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                            prt-stoim @ stoim
                            price-withNDS
                            OKEI
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                        with frame f-doc.
                        down stream out-stream 1 with frame f-doc .
                end.        /* if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} */
                /*---E--------- Стоит галочка печати по признакам ----------------*/
            end.
            /*---E--------- Для каждого признака -----------------------------*/
        end.
end.
end procedure. /* print-line-dtl */



procedure print-line-parts :
define input        parameter p-doc-line-recid       as recid   no-undo .

define output parameter p-prt-tqnty                         as decimal          no-undo.
define output parameter p-prt-VAT-gds                       as decimal          no-undo.
define output parameter p-prt-SLT-gds                       as decimal          no-undo.
define output parameter p-prt-stoim-noNDS                   as decimal          no-undo.
define output parameter p-prt-stoim                         as decimal          no-undo.

define variable p-VAT-gds         as decimal no-undo.
define variable p-SLT-gds         as decimal no-undo.
define variable p-price-withNDS   as decimal no-undo.
define variable p-tax             as decimal no-undo.
define variable p-tax-price       as decimal no-undo.
define variable p-tax-sum         as decimal no-undo.

    define variable v-tax-name          as character    no-undo.
    define variable v-VAT-pc            as decimal      no-undo.
    define variable v-SLT-pc            as decimal      no-undo.
    define variable v-void-decimal      as decimal      no-undo.
    define buffer buf_doc-line for ub.doc-line.
do
on error undo, return error
:
    find first buf_cli-gds no-lock
      where buf_cli-gds.artic     = ub.doc-line.artic
        and buf_cli-gds.prod-code = ub.doc-line.prod-code
        and buf_cli-gds.prod-type = ub.doc-line.prod-type
        and buf_cli-gds.cli-code  = ub.parts.supp-code
        and buf_cli-gds.cli-type  = ub.parts.supp-type
        and buf_cli-gds.host-code = v-host-code no-error.

    find first buf_doc-line no-lock
      where  recid(buf_doc-line) = p-doc-line-recid no-error.


    create tt-clcparts.
    buffer-copy parts to tt-clcparts.
    run clcprtsl_calc-parts (
                              input recid( tt-clcparts )
                            , input yes
                            , input no
                            , input buf_doc-line.road-tax
                            , input buf_doc-line.excise
                            , input buf_doc-line.vat-pc
                            , input buf_doc-line.cons-vat-pc
                            , input buf_doc-line.slt-pc
                            , input t-doc.base-rate
                            , input t-doc.base-scale
                            , input ( if PrintRubl then {&r-b-rubl} else {&r-b-base} )
                            , input 0
                            , input 0
                            , input 0
                            , input 0
                            , input 0
                            , input 0
                          ) .
    find first tt-allsum
        where tt-allsum.sum-type = {&sum-general}
    .
    if PrintRubl = yes then do:
        assign /* price-base-with-tax-loc - transport-base-loc - other-base-loc - p-tax-price */
          p-SLT-gds       = if CostPrice = no then
                                tt-allsum.slt-rubl-doc
                            else
                                tt-allsum.slt-rubl-acc
          p-tax-price     = if CostPrice = no then
                                tt-allsum.road-tax-rubl-doc
                            else
                                tt-allsum.road-tax-rubl-acc
          p-tax           = p-tax-price
          p-tax-sum       = p-tax-sum + p-tax
        .

          if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
            assign
              p-price-withNDS =   tt-allsum.sum-dsc-rubl-acc
                                - tt-allsum.transport-rubl-acc
                                - tt-allsum.other-rubl-acc
                                - p-tax-price
              p-VAT-gds       =   tt-allsum.vat-rubl-acc
            .
          end.
          else do:
            assign
              p-price-withNDS = if CostPrice = no then
                                  tt-allsum.sum-dsc-rubl-doc - p-tax-price
                                else
                                  tt-allsum.sum-dsc-rubl-acc - p-tax-price
              p-VAT-gds       = if CostPrice = no then
                                  tt-allsum.vat-rubl-doc
                                else
                                  tt-allsum.vat-rubl-acc
            .
          end.
    end.
    else do: /* PrintRubl <> yes */
        assign
          p-SLT-gds       = if CostPrice = no then
                                tt-allsum.slt-base-doc
                            else
                                tt-allsum.slt-base-acc
          p-tax-price     = if CostPrice = no then
                                tt-allsum.road-tax-base-doc
                            else
                                tt-allsum.road-tax-base-acc
          p-tax           = p-tax-price
          p-tax-sum       = p-tax-sum + p-tax
        .
          if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
            assign
              p-price-withNDS =   tt-allsum.sum-dsc-base-acc
                                - tt-allsum.transport-base-acc
                                - tt-allsum.other-base-acc
                                - p-tax-price
              p-VAT-gds       =   tt-allsum.vat-base-acc
            .
          end.
          else do:
            assign
              p-price-withNDS = if CostPrice = no then
                                    tt-allsum.sum-dsc-base-doc - p-tax-price
                                else
                                    tt-allsum.sum-dsc-base-acc - p-tax-price
              p-VAT-gds       = if CostPrice = no then
                                    tt-allsum.vat-base-doc
                                else
                                    tt-allsum.vat-base-acc
            .
          end.
    end.
    if VAT-gds = ? then VAT-gds = 0.
    if SLT-gds = ? then SLT-gds = 0.
    assign
        tqnty           = ub.parts.fact-qnty
        unit-str        = ub.goods.unit-base
        price-noNDS     = ( p-price-withNDS - p-VAT-gds - p-SLT-gds )
        VAT-gds         = p-VAT-gds
        SLT-gds         = p-SLT-gds
        stoim-noNDS     = price-noNDS
        stoim           = stoim-noNDS + VAT-gds
        price-withNDS   = p-price-withNDS / ub.parts.fact-qnty
        v-vat-pc        = if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then parts.vat-pc else buf_doc-line.vat-pc
    .
    display stream out-stream
        v-doc-line-counter
        ub.goods.artic
        gds-str1                    @ ub.goods.gds-name
        string( ub.bar-code.b-code )   @ tb-code
        buf_cli-gds.cli-art when available buf_cli-gds @ ub.cli-gds.cli-art
        unit-str @ goods.unit-base
        tqnty
        stoim-noNDS
        v-vat-pc                @ ub.doc-line.VAT-pc
        VAT-gds
        stoim
        price-withNDS
        OKEI
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
        sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
    with frame f-doc.
    down stream out-stream 1 with frame f-doc.
    assign
        p-prt-tqnty =  tqnty
        p-prt-VAT-gds = VAT-gds
        p-prt-SLT-gds = SLT-gds
        p-prt-stoim-noNDS = price-noNDS
        p-prt-stoim = stoim
    .
    if hvrdtax (recid(goods))
    then do:
        /*---S--------- Третий налог выводится отдельной строкой ---------*/
        run tax-name in this-procedure (  input {&road-tax}
                                        , output v-tax-name
                                       ).
          find first buf_tax_parts
              where buf_tax_parts.obj-type     = ub.parts.obj-type
                and buf_tax_parts.obj-code     = ub.parts.obj-code
                and buf_tax_parts.artic        = ub.parts.artic
                and buf_tax_parts.prod-type    = ub.parts.prod-type
                and buf_tax_parts.prod-code    = ub.parts.prod-code
                and buf_tax_parts.in-code      = ub.parts.in-code
                and buf_tax_parts.out-code     = ub.parts.out-code
                and buf_tax_parts.part-code    = ub.parts.part-code no-error.
          assign
            v-tax-parts-price   =  ( if PrintRubl
                                     then buf_tax_parts.road-tax-rubl
                                     else buf_tax_parts.road-tax-base )
            v-parts-tax-qnty    = buf_tax_parts.fact-qnty
            v-tax               = ( v-tax-parts-price * buf_tax_parts.fact-qnty )
          .
          display stream out-stream
                fill(" ", 2) + v-tax-name   @ ub.goods.gds-name
                v-parts-tax-qnty            @ tqnty
                0                           @ VAT-gds
                v-tax                       @ stoim-noNDS
                v-tax-parts-price           @ price-withNDS
                v-tax                       @ stoim
                sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
          with frame f-doc.
          down stream out-stream 1 with frame f-doc.
          assign
              p-prt-VAT-gds = p-prt-VAT-gds
              p-prt-stoim-noNDS = p-prt-stoim-noNDS + v-tax
              p-prt-stoim = p-prt-stoim + v-tax
          .
    /*---E--------- Третий налог выводится отдельной строкой ---------*/
    end.
end.
end procedure. /* print-line-parts */


procedure print-itog :

define input parameter p-stoim-noNDS                 as decimal          no-undo.
define input parameter p-VAT-gds                     as decimal          no-undo.
define input parameter p-SLT-gds                     as decimal          no-undo.
define input parameter p-stoim                       as decimal          no-undo.

define variable v-doc-places    as character    no-undo.
define variable v-attr-type     as character    no-undo.

do
on error undo, return error return-value
:
    if line-counter( out-stream ) + 20 > page-size( out-stream ) then
        do:
            { rep/t12-art.i itog }
            page stream out-stream .
        end.
    hide stream out-stream frame BottomFrame .


    { rep/t12-art.i itog }

    assign
        v-sum-tot-qnty =  t-doc.fact-qnty
    .
    display stream out-stream
      "Всего по накладной" @ goods.gds-name
      v-sum-tot-qnty @ tqnty
      p-stoim-noNDS @ stoim-noNDS
      p-VAT-gds  @ VAT-gds
      p-stoim @ stoim
    with frame f-doc .
    down stream out-stream 2 with frame f-doc .
    if PrintRubl then do:
        run rep/wp-rub.p ( input (  p-stoim + p-SLT-gds ), output s1, output s2 ) .
    end.
    else do:
        run rep/wp.p ( input parparentproc , input ( p-stoim + p-SLT-gds ), output s1, output s2 ) .
    end.
    run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
    put stream out-stream
        space(10) "  Всего на сумму:        "
            trim( string( ( p-stoim + p-SLT-gds ), "->>>,>>>,>>>,>>>,>>9.99") ) format "X(25)"
            " ("
            trim( ( ( if PrintRubl then "{&abbr_rub_allshift}" else base-type ) ) ) format "X(6)"
            ")"
    .
    if v-torgconf-outdisc = no
    then do:
        put stream out-stream
                            string( ( if ( if PrintRubl then t-doc.discnt-rubl else t-doc.tot-calc ) < 0
                                    then ", наценка: "
                                    else ", скидка: " )
                                + ( if ( v-ext-doc-type <> {&TDEDT_Pri_Vnesh} )
                                    then trim( string( ABS( ( if PrintRubl
                                                                then t-doc.discnt-rubl
                                                                else t-doc.tot-calc ) ), ">>>,>>>,>>>,>>>,>>9.99" ) )
                                    else "0.00" )
                                + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else base-type ) ) + ")"
                            ) format "X(100)"
        .
    end.
    if t-doc.doc-type <> {&income}
    then do:
        put stream out-stream
            skip
            space(15) string( "В том числе: " ) format "X(160)"
            skip
        .
        if v-tax-sum <> 0
        then do:
            put stream out-stream
                space(21) v-tax-name + ":" + fill(" ", 1) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else base-type ) ) + ")"
                                                                                                format "X(160)"
            .
        end.
    end.
    else do:
        if v-tax-sum <> 0
        then do:
            put stream out-stream
                skip
                space(15) "В том числе " + v-tax-name + ":" + fill(" ", 3) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else base-type ) ) + ")"
                                                                                                format "X(160)"
            .
        end.
    end.
    put stream out-stream
        skip
        space(30) string( "НДС: " + trim( string( p-VAT-gds, "->>>,>>>,>>>,>>>,>>9.99") ) +
                                    " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else base-type ) ) + ")" ) format "X(160)"
    .

    run gbl/trdcat-v.p (
          input t-doc.doc-code
        , input {&trdcattr-qntyplace}
        , output v-doc-places
        , output v-attr-type
    ).
    if v-doc-places = "":U
    then do:
        assign
            v-doc-places = v-underline
        .
    end.
    put stream out-stream
        skip(2)
        space(10) string( "Товарная накладная имеет приложение на " + v-underline ) format "X(125)" skip
        space(10) string( "и содержит " + CAPS( txt-LC ) + " порядковый(ых) номер(ов) записей") format "X(180)" skip
        v-underline format "X(29)" at 151 skip
        string( "Масса груза (нетто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        space(10) string( "Всего мест " + v-doc-places ) format "X(45)"
                string( "Масса груза (брутто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip(1)
        string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( v-underline, "X(42)" ) + " листах" ) format "X(95)" "|" at 97
            string( "По доверенности N " + string( v-underline, "X(39)" ) + " от " + v-underline ) format "X(100)" at 99 skip
        "Всего отпущено на сумму " format "X(95)" "|" at 97 string( "выданной " + v-underline ) format "X(100)" at 99 skip
        space(2) CAPS(s1) format "X(93)" "|" at 97 skip
    .
    put stream out-stream
        "Отпуск разрешил  "
    .
    put stream out-stream
        ": _____________"
    .
    put stream out-stream
        string( "___________________ / " + ( if v-torgconf-outsubs = no then v-torgconf-main-boss else "" ) ) format "X(60)" "/ |":U at 95 skip
        string( "Главный бухгалтер: ________________________________ / " + ( if v-torgconf-outsubs = no then v-torgconf-main-buh  else "" ) ) format "X(93)" "/ |" at 95 skip
        string( "Отпуск груза произвел кладовщик: " + v-underline  ) format "X(95)" "|" at 97
        "|" at 97 string( "Груз принял " + v-underline ) format "X(100)" at 99 skip
        v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99 skip
        "М.П." at 15  "|" at 97 "М.П." at 99 skip
    .
end.
end procedure. /* print-itog */


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