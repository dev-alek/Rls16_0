block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ft1old.p $
$Archive: rep/r-ft1old.p $

Печатные формы. Типовая межотраслевая форма № 1-Т для внешнего расхода

Автор: Морозов Александр Сергеевич
Дата создания: 28/03/11
Author: Alexandr Morozov
Creation date: 28/03/11

Author1: Alexandr Morozov
Creation date: 04/12/11

Input:
    rec_id       as recid       - recid( trn-doc ) документа
    Invers       as logical     -  =?       - печатать партии для возврата поставщику
    p-mode       as integer     -  ="mag"   - не печатать номер документа, и форма без двух последних колонок (для Магамакса)
    p-from-check as logical     -  печатать данные продаж по чекам
    p-reverse    as logical     -  менять местами грузополучателя и плательщика
*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-round              as character        no-undo.
define input parameter p-from-check         as logical          no-undo.
define input parameter p-reverse            as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ft1old.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ft1old.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Типовая межотраслевая форма № 1-Т для внешнего расхода".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ str/lib-trn.i     }
{ cmp/r-pril.i      }
{ cmp/breakstr.i    }
{ gbl/cur-time.i    }
{ gbl/dtm.i         }
{ str/in-vatp.i def }
{ str/out-vatp.i def}
{ cmp/croslist.i    }
{ str/hvrdtax.i     }
{ gbl/tax-name.i    }
{ rep/fmtcli.i      }
{ rep/torgconf.i    }
{ str/writelog.i def "''" }
{ gbl/paramls.i     }
{ gbl/std-func.i  }
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ rep/r-ft1oxl.i    }
{ str/sj-t12.i      }
{ str/getctxtp.i def}
{ rep/p-fmt.i       }
{ str/mpl-auto.i    }

&scoped-define gds-len 37
&scoped-define gds-len-m 52

define temp-table temp_gds-name no-undo
    field gdn-key   as integer
    field gdnString as character

    index pi is primary unique
        gdn-key
.
define stream out-stream .

define shared variable PrintScale   as logical                          no-undo.
define shared variable CostPrice    as logical                          no-undo.
define shared variable sort-name    as logical                          no-undo.
define shared variable sort-gr      as logical                          no-undo.
define shared variable print-graft  as logical                          no-undo.

    define variable v-torg-12-gds-name-key    as integer      no-undo.
    define variable v-torg-12-gds-name-length as integer      no-undo.

define variable tdoc-prt            as logical                          no-undo.

define variable v-rootnode-code     as integer                          no-undo.

define variable v-line-counter      as integer                          no-undo.
define variable v-doc-line-counter  as integer                          no-undo.
define variable txt-LC              as char                             no-undo.
define variable s1                  as char                             no-undo.
define variable s2                  as char                             no-undo.

define variable v-node-code         like    gds-prt.upper-code          no-undo.

define variable price-noNDS         like doc-line.price-base            no-undo.
define variable price-withNDS       like doc-line.price-base            no-undo.
define variable tqnty               like doc-line.doc-qnty              no-undo.
define variable stoim-noNDS         like doc-line.price-base            no-undo.
define variable stoim               like doc-line.price-base            no-undo.
define variable prt-tqnty           like doc-line.doc-qnty              no-undo.
define variable prt-VAT-gds         like ot-line.VAT-base               no-undo.
define variable prt-SLT-gds         like ot-line.SLT-base               no-undo.
define variable prt-stoim-noNDS     like doc-line.price-base            no-undo.
define variable prt-stoim           like doc-line.price-base            no-undo.

define variable  v-sum-tot-qnty     as decimal                          no-undo.

define variable v-VAT-gds           like ot-line.VAT-base               no-undo.
define variable v-SLT-gds           like ot-line.SLT-base               no-undo.
define variable v-price-withNDS     like doc-line.price-base            no-undo.

define variable Pg-tqnty            like doc-line.doc-qnty      init 0  no-undo.
define variable Pg-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
define variable Pg-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
define variable Pg-stoim-noNDS      like doc-line.price-base    init 0  no-undo.
define variable Pg-stoim            like doc-line.price-base    init 0  no-undo.
    define variable PrevPage            as int     init 0   no-undo.

define variable VAT-gds             like ot-line.VAT-base               no-undo.
define variable SLT-gds             like ot-line.SLT-base               no-undo.

define variable v-prt-name          as char                             no-undo.

define variable v-okei                as char                             no-undo.
define variable tb-code             as char                             no-undo.
define variable pack-type           as char                             no-undo.
define variable qnty-opl            like doc-line.doc-qnty              no-undo.
define variable qnty-pl             like doc-line.doc-qnty              no-undo.
define variable mass                as decimal     decimals 10          no-undo.

define variable v-tax-name          as char                             no-undo.
define variable v-tax-price         like doc-line.road-tax      init 0  no-undo.
define variable v-tax               like doc-line.road-tax      init 0  no-undo.
define variable v-tax-sum           like doc-line.road-tax      init 0  no-undo.
define variable v-parts-tax-qnty    like doc-line.doc-qnty      init 0  no-undo.
define variable v-tax-parts-price   like doc-line.road-tax      init 0  no-undo.

define variable v-single-line       as char              no-undo.
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
define variable v-ext-artic                 like ub.ext-artic.ext-artic no-undo.
define variable v-par-type                  as character                no-undo.
define variable p-torgconf-post-head        as character                no-undo.
define variable v-host-code                 as integer                  no-undo.
define variable p-sf-par                    as logical                  no-undo.
define variable v-curr-code                 as integer                  no-undo.
define variable tmp-var                     as character                no-undo.
define variable FullGdsName                 as logical                  no-undo.
define variable v-ext-doc-type              as character                no-undo.
define variable v-sort-artic                as logical                  no-undo.
define variable v-bcode                      as integer                  no-undo.

     /* Определение переменных для грузополучателя */
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo.


define variable  p-torgconf-wrkr-name             as character    no-undo.
define variable  p-torgconf-post                  as character    no-undo.
define variable  month                            as integer      no-undo.
define variable  p-torgconf-date-char             as character    no-undo.
define variable  v-loadtplace                     as character    no-undo.
define variable  v-loadtname                      as character    no-undo.

define variable v-outhdobj      as logical  init no    no-undo .   /* для межфирменных документов печатать в поле грузополучатель объект получателя*/
define variable v-outhdobj-str  as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-is-hold-doc   as logical   no-undo .

define variable v-disc-mpl       as decimal   no-undo .
define variable v-price-all-mpl  as decimal   no-undo .

    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_temp_gds-name     for temp_gds-name.
do
for buf_trn-doc
  , buf_temp_gds-name
on error undo, return error
:

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
find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
assign
    v-ext-doc-type = buf_trn-doc.ext-doc-type
.
if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
and ( lookup( "NG":U , p-mode ) <> 0
   or lookup( "IAB":U, p-mode ) <> 0 )
then do:
    assign
        v-ext-doc-type = {&TDEDT_Ras_Vnesh}
    .
end.
{ gbl/hostcode.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
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
if lookup( "TOPAUKC":U, p-mode ) <> 0
then do:
  assign Costprice = false.
end.

assign
    v-torgconf-ext-doc-type = buf_trn-doc.ext-doc-type
.
run torgconf-read in this-procedure (
      input "torg12":U
    , input v-host-code
    , input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
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
      input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
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
    return error.
end.

/*То что нужно для Грузополучателя */
{ gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc }
if  v-is-hold-doc then do:          /*если документ межфирмекнного перемещения, то смотрим что писать а грузополучатель . параметр outhdobj */
  run gbl/conf-rd.p ("outhdobj" , v-host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no, output v-outhdobj-str , output v-par-type) no-error.
  if error-status :error
  then do:
    assign
      v-outhdobj-str = ""
    .
  end.
  if lookup( "torg12", v-outhdobj-str ) <> 0
  then do:
    assign
      v-outhdobj = yes
    .
  end.
end.

  assign
    v-cli-type = buf_trn-doc.cli-type
    v-cli-code = buf_trn-doc.cli-code
  .
 /* атрибут Грузополучатель*/
run torgconf-get-recepient-param (
    input buf_trn-doc.doc-code
  , output v-code-rec
  , output v-type-rec
  , output v-codefirm-rec
  , output v-curcode-rec
    ).
if v-code-rec = 0 and         /*Если не указан грузополучатель в атрибутах и для межфирм. перемещений настроен   outhdobj, то в грузополучатель кладем объект-получатель */
   v-outhdobj = yes and
   v-is-hold-doc = yes
then do:
  assign
    v-type-rec = buf_trn-doc.hold-obj-type
    v-code-rec = buf_trn-doc.hold-obj-code
  .
end.
else if v-code-rec = 0 then do:
    v-type-rec = buf_trn-doc.cli-type .
    v-code-rec = buf_trn-doc.cli-code .
end.
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

run torgconf-get-cli-param in this-procedure (
      input buf_trn-doc.host-code
    , input v-cli-type
    , input v-cli-code
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

run torgconf-get-ship-param in this-procedure (
      input buf_trn-doc.host-code
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
if p-from-check = yes
then do:
    if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
    and v-ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass}
    then do:
        message
            "Документ ТОРГ12 по чекам может быть напечатан"
            skip "только для документов расхода или возврата"
            skip "через кассу."
        view-as alert-box information.
        undo, return .
    end.
    run fill-sjt12 in this-procedure (
        input buf_trn-doc.doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка заполнения временной таблицы для продаж по чекам."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
run gbl/conf-rd.p ( "FGdsNinD", buf_trn-doc.host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no, output tmp-var, output v-par-type ) no-error.
IF error-status:error
then do:
    assign
        FullGdsName = no
    .
end.
else do:
    assign
        FullGdsName = ( tmp-var = "yes" )
    .
end.
run torgconf-get-post-head in this-procedure (
    input buf_trn-doc.obj-type
  , input buf_trn-doc.obj-code
  , output p-torgconf-post-head
).
run torgconf-get-storekeeper in this-procedure (
    input buf_trn-doc.wrkr
  , output p-torgconf-wrkr-name
  , output p-torgconf-post
).
run torgconf-get-warrant (
    input buf_trn-doc.doc-code
    ).
&scop gds-len 27
&scop gds-len-m 52
assign
    v-torg-12-gds-name-length       = ( if v-torgconf-outt12 = yes then {&gds-len-m} else {&gds-len} )
.
/*define frame f-doc*/
/*        sym1 column-label ":!:!:" format "X(1)" space(0)*/
/*        v-doc-line-counter COLUMN-LABEL "N!п/п! " format ">>>>9" space(0)*/
/*        sym2 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.artic COLUMN-LABEL "Артикул! ! " format "X(17)" space(0)*/
/*        sym19 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.gds-name COLUMN-LABEL "Наименование товара! ! " format "X({&gds-len})" space(0)*/
/*        sym3 column-label ":!:!:" format "X(1)" space(0)*/
/*        tb-code COLUMN-LABEL "Код товара! ! " format "X(17)" space(0)*/
/*        sym4 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.unit-base COLUMN-LABEL "Наим!ед.!изм." format "X(4)" space(0)*/
/*        sym5 column-label ":!:!:" format "X(1)" space(0)*/
/*        v-okei COLUMN-LABEL "Код ед.!изм. по!ОКЕИ" format "X(7)" space(0)*/
/*        sym6 column-label ":!:!:" format "X(1)" space(0)*/
/*        pack-type COLUMN-LABEL "Вид!уп.! " format "X(3)" space(0)*/
/*        sym7 column-label ":!:!:" format "X(1)" space(0)*/
/*        qnty-opl COLUMN-LABEL "Кол-во!в одном!месте" format ">>>>9.<" space(0)*/
/*        sym8 column-label ":!:!:" format "X(1)" space(0)*/
/*        qnty-pl COLUMN-LABEL "Кол-!во!мест" format ">>9.<" space(0)*/
/*        sym9 column-label ":!:!:" format "X(1)" space(0)*/
/*        mass COLUMN-LABEL "Масса!брут-!то" format ">>9.<" space(0)*/
/*        sym10 column-label ":!:!:" format "X(1)" space(0)*/
/*        tqnty COLUMN-LABEL "Количество ! ! " format "->>>>>9.<<<" space(0)*/
/*        sym11 column-label ":!:!:" format "X(1)" space(0)*/
/*        price-noNDS COLUMN-LABEL "Цена без!  НДС! " format "->>>>>9.99" space(0)*/
/*        sym12 column-label ":!:!:" format "X(1)" space(0)*/
/*        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! " format "->>,>>>,>>9.99" space(0)*/
/*        sym13 column-label ":!:!:" format "X(1)" space(0)*/
/*        doc-line.VAT-pc column-label "Став-!ка!НДС %" format ">9.9<" space(0)*/
/*        sym14 column-label ":!:!:" format "X(1)" space(0)*/
/*        VAT-gds column-label "Сумма!НДС! " format "->>,>>>,>>9.99" space(0)*/
/*        sym15 column-label ":!:!:" format "X(1)" space(0)*/
/*        stoim column-label "Сумма!с учетом!  НДС" format "->>>,>>>,>>9.99" space(0)*/
/*        sym16 column-label ":!:!:" format "X(1)" space(0)*/
/*        /**/
/*        SLT-gds column-label "Сумма!НП! ! ! " format "->>>,>>9.99" space(0)*/
/*        sym17 column-label ":!:!:" format "X(1)" space(0)*/
/*        */*/
/*        price-withNDS COLUMN-LABEL "Цена!с учетом!  НДС" format "->>>>>>>9.99" space(0)*/
/*        sym18 column-label ":!:!:" format "X(1)" space(0)*/
/*    header*/
/*        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"*/
/*        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"*/
/*            ( if buf_trn-doc.status_ <> {&fact} then*/
/*                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )*/
/*              else*/
/*                  " " ) at 100 format "X(30)"*/
/*            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP*/
/*        v-single-line format "X(198)" at 1*/
/*    with width {&DOS_CW}  down stream-io.*/

/*define frame f-doc-m*/
/*        sym1 column-label ":!:!:" format "X(1)" space(0)*/
/*        v-doc-line-counter COLUMN-LABEL "N!п/п! " format ">>>>9" space(0)*/
/*        sym2 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)*/
/*        sym19 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.gds-name COLUMN-LABEL "Наименование товара! ! " format "X({&gds-len-m})" space(0)*/
/*        sym3 column-label ":!:!:" format "X(1)" space(0)*/
/*        tb-code COLUMN-LABEL "Код товара! ! " format "X(17)" space(0)*/
/*        sym4 column-label ":!:!:" format "X(1)" space(0)*/
/*        goods.unit-base COLUMN-LABEL "Наим!ед.!изм." format "X(4)" space(0)*/
/*        sym5 column-label ":!:!:" format "X(1)" space(0)*/
/*        v-okei COLUMN-LABEL "Код ед.!изм. по!ОКЕИ" format "X(7)" space(0)*/
/*        sym6 column-label ":!:!:" format "X(1)" space(0)*/
/*        pack-type COLUMN-LABEL "Вид!уп.! " format "X(3)" space(0)*/
/*        sym7 column-label ":!:!:" format "X(1)" space(0)*/
/*        qnty-opl COLUMN-LABEL "Кол-во!в одном!месте! " format ">>>>9.<" space(0)*/
/*        sym8 column-label ":!:!:" format "X(1)" space(0)*/
/*        qnty-pl COLUMN-LABEL "Кол-!во!мест" format ">>9.<" space(0)*/
/*        sym9 column-label ":!:!:" format "X(1)" space(0)*/
/*        mass COLUMN-LABEL "Масса!брут-!то" format ">>9.<" space(0)*/
/*        sym10 column-label ":!:!:" format "X(1)" space(0)*/
/*        tqnty COLUMN-LABEL "Количество ! ! " format "->>>>>9.<<<" space(0)*/
/*        sym11 column-label ":!:!:" format "X(1)" space(0)*/
/*        price-noNDS COLUMN-LABEL "Цена без!  НДС! " format "->>>>>9.99" space(0)*/
/*        sym12 column-label ":!:!:" format "X(1)" space(0)*/
/*        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! " format "->>,>>>,>>9.99" space(0)*/
/*        sym13 column-label ":!:!:" format "X(1)" space(0)*/
/*        doc-line.VAT-pc column-label "Став-!ка!НДС %" format ">9.9<" space(0)*/
/*        sym14 column-label ":!:!:" format "X(1)" space(0)*/
/*        VAT-gds column-label "Сумма!НДС! " format "->>,>>>,>>9.99" space(0)*/
/*        sym15 column-label ":!:!:" format "X(1)" space(0)*/
/*        stoim column-label "Сумма!с учетом!  НДС" format "->>>,>>>,>>9.99" space(0)*/
/*        sym16 column-label ":!:!:" format "X(1)" space(0)*/
/*    header*/
/*        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"*/
/*        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"*/
/*            ( if buf_trn-doc.status_ <> {&fact} then*/
/*                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )*/
/*              else*/
/*                  " " ) at 100 format "X(30)"*/
/*            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP*/
/*        v-single-line format "X(198)" at 1*/
/*    with width {&DOS_CW} down stream-io.*/

    { gbl/working.i }
    os-delete log-file-name.
    run writelog in this-procedure (log-file-name, 0, "&Line").
    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    run r-f_t1xl-init in this-procedure .
    assign
        v-single-line = fill("-", 230)
        v-line-counter = 1
        v-doc-line-counter = 1
    .

    find first currency no-lock
        where currency.curr-code = buf_trn-doc.exch-code
    .
    run print-header in this-procedure (
        input buf_trn-doc.doc-code
    ).
    if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        assign      /* Возврат поставщику: всегда печать по партиям */
            Invers = yes
        .
    end.
    if p-from-check = yes
    then do:
        if sort-name = yes              /*Включена сортировка по имени*/
        then do:
            if sort-gr = yes
            then do:
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по имени и группе").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.grp-name
                      by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
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
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по имени (по группе нет)").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
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
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировка по группе (по имени нет)").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                break by goods.grp-name
                      by sj-t12.artic
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
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
                run writelog in this-procedure (log-file-name, 1, "По чекам: Сортировок по группе и по имени нет").
                for each sj-t12
                  , each goods no-lock
                   where goods.gds-code  = sj-t12.gds-code
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line-sj in this-procedure (
                          input buf_trn-doc.doc-code
                        , input sj-t12.b-code
                    ).
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
    end.        /* if p-from-check = yes */
    else do:
        if sort-name = yes              /*Включена сортировка по имени*/
        then do:
            if sort-gr = yes
            then do:
                run writelog in this-procedure (log-file-name, 1, "Сортировка по имени и группе").
                for each doc-line no-lock
                where doc-line.doc-code = buf_trn-doc.doc-code,
                    each goods no-lock
                   where goods.artic     = doc-line.artic
                     and goods.prod-type = doc-line.prod-type
                     and goods.prod-code = doc-line.prod-code
                break by goods.grp-name
                    by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                    ).
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
                run writelog in this-procedure (log-file-name, 1, "Сортировка по имени (по группе нет)").
                for each doc-line no-lock
                where doc-line.doc-code = buf_trn-doc.doc-code,
                    each goods no-lock
                where goods.artic     = doc-line.artic
                    and goods.prod-type = doc-line.prod-type
                    and goods.prod-code = doc-line.prod-code
                break by goods.gds-name
                :
                    run get-okei in this-procedure (
                          input goods.unit-base
                        , output v-okei
                    ).
                    run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                    ).
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
                if v-sort-artic = yes then do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировка по группе (по имени нет)").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by goods.grp-name
                        by doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end. /* сортировка по порядку */
                else do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировка по группе (по имени нет)").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by goods.grp-name
                        by doc-line.line-num
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.

                end. /* сортировка по артикулу */
            end. /* сортировка по группе */
            else do:
                if v-sort-artic = yes then do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировок по группе и по имени нет").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end. /* сортировка по порядку */
                else do:
                  run writelog in this-procedure (log-file-name, 1, "Сортировок по группе и по имени нет").
                  for each doc-line no-lock
                  where doc-line.doc-code = buf_trn-doc.doc-code,
                      each goods no-lock
                  where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code
                  break by doc-line.line-num
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      run print-line in this-procedure (
                          input buf_trn-doc.doc-code
                        , input "by-order"
                      ).
                      accumulate
                          tqnty ( TOTAL )
                          VAT-gds ( TOTAL )
                          SLT-gds ( TOTAL )
                          stoim-noNDS ( TOTAL )
                          stoim ( TOTAL )
                      .
                  end.
                end. /* сортировка по артикулу */
            end.
        end.                           /*Сортировка по имени выключена*/
    end.        /* if p-from-check <> yes */


    assign
        v-sum-tot-qnty = ( if p-from-check = yes
                           then (accum total tqnty)
                           else buf_trn-doc.fact-qnty )
    .
/*    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_qnty}
        , input string( v-sum-tot-qnty )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_SumNoVAT}
        , input string(accum total stoim-noNDS)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_VATsum}
        , input string(accum total VAT-gds)
    ).
*/

    if PrintRubl then
        run rep/wp-rub.p ( ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    else
        run rep/wp.p ( input p-mainmenu-handle, ( (accum total stoim) + (accum total SLT-gds) ), output s1, output s2 ) .
    run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      run disc-mpl in this-procedure (input buf_trn-doc.doc-code, output v-price-all-mpl ) .
      if v-price-all-mpl > ( accum total stoim ) + (accum total SLT-gds) then do:
        assign v-disc-mpl = v-price-all-mpl - ( accum total stoim ) + (accum total SLT-gds) .
      end.
      else do:
        assign v-disc-mpl = 0.
      end.
    end.

    define variable v-input-value           as character    no-undo.
    define variable v-doc-places            as character    no-undo.
    define variable v-attr-type             as character    no-undo.
    define variable v-attr-value            as character    no-undo.
    define variable v-autonum               as character    no-undo.
    define variable v-automark              as character    no-undo.
    define variable v-driver                as character    no-undo.
    define variable v-cargo-name            as character    no-undo.
    define variable v-cargo-desc            as character    no-undo.
    define variable v-cargo-pack            as character    no-undo.
    define variable v-carry-type            as character    no-undo.
    define variable v-cargo-mass-netto      as decimal      no-undo.
    define variable v-cargo-mass-brutto     as decimal      no-undo.
    define variable v-exp-trans             as decimal      no-undo.

      run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input {&trdcattr-qntyplace}
          , output v-doc-places
          , output v-attr-type
      ).

      /* новые атрибуты для 1-Т*/
        run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input {&trdcattr-auto}
          , output v-attr-value
          , output v-attr-type
      ).
      if v-attr-value <> "" then assign v-automark = entry (1 , v-attr-value)
                                  v-autonum = entry (2 , v-attr-value).
      v-attr-value = "".

      run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input {&trdcattr-driver}
          , output v-driver
          , output v-attr-type
      ).


    run gbl/trdcat-v.p (
            input buf_trn-doc.doc-code
          , input {&trdcattr-cargo-desc}
          , output v-attr-value
          , output v-attr-type
      ).


    if v-attr-value <> "" then assign v-cargo-name = entry (1 , v-attr-value)
                                      v-cargo-pack = entry (2 , v-attr-value).
    v-attr-value = "".

  /*вид перевозки*/
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input {&trdcattr-carry-type}
        , output v-carry-type
        , output v-attr-type
    ).
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input {&trdcattr-cargo-mass}
        , output v-attr-value
        , output v-attr-type
    ).
    if v-attr-value <> "" then assign v-cargo-mass-netto = decimal( entry (1 , v-attr-value))
                                      v-cargo-mass-brutto = decimal( entry (2 , v-attr-value)).
    /*message
      v-attr-value   v-cargo-mass-netto v-cargo-mass-brutto
    view-as alert-box error.*/
    v-attr-value = "".

    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input {&trdcattr-exp-trans}
        , output v-attr-value
        , output v-attr-type
        ).
    v-exp-trans = decimal (v-attr-value).
    v-attr-value = "".

    if v-doc-places <> "" then
      run rep\wp-qnty.p (
            input v-doc-places
          , output v-input-value
      ).

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_placeAmount}
        , input v-doc-places
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_placeAmount}
        , input v-input-value
    ).
    v-input-value = "".






    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_carrytype}
        , input (v-carry-type)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_driver}
        , input (v-driver)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_automark}
        , input (v-automark)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_autonum}
        , input (v-autonum)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoname}
        , input (v-cargo-name)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargopack}
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).

    /* ноль и пустое значение для масс не выводим*/
    if v-cargo-mass-netto <> 0 and v-cargo-mass-brutto <> ? then do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-f_massNetto}
          , input string (v-cargo-mass-netto)
      ).
      run rep\wp-qnty.p (
            input v-cargo-mass-netto
          , output v-input-value
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-f_massNettoSTR}
          , input (v-input-value)
      ).
      v-input-value = "".
    end.
    if v-cargo-mass-brutto <> 0 and v-cargo-mass-brutto <> ? then do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-f_massBrutto}
          , input string (v-cargo-mass-brutto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massBrutto}
          , input string (v-cargo-mass-brutto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massBrutto1}
          , input string (v-cargo-mass-brutto)
      ).
      run rep\wp-qnty.p (
            input v-cargo-mass-brutto
          , output v-input-value
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-f_massBruttoSTR}
          , input (v-input-value)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massBruttoSTR}
          , input (v-input-value)
      ).
      v-input-value = "".
    end.
    /* конец анализа на ноль и пустое значение масс*/

/*    run rep\wp-qnty.p (*/
/*          input v-doc-line-counter*/
/*        , output v-input-value*/
/*    ).*/
    if lookup( "TopAukc":U, p-mode ) <> 0 then do: /* для Бизнес Букета*/
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_qntyname}
        ,input "Одно"
    ).
    end.
    else do:
    if v-input-value = "Один" then v-input-value = "Одно".
    run r-f_t1xl-write-cell-data in this-procedure (
         input {&r-f_t1xl-f_qntyname}
        ,input txt-LC
    ).
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
      input {&r-f_t1xl-f_exptrans}
    , input (v-exp-trans)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_sum}
        , input string( (accum total stoim) + (accum total SLT-gds) + v-exp-trans )
    ).

              if lookup( "TopAukc":U, p-mode ) <> 0 then do: /*Вывод линии и др. для Бизнес Букета*/
                  run r-f_t1xl-sheet1-write-line-data in this-procedure (
                        input "1"
                      , input v-cargo-name
                      , input ""
                      , input (if v-cargo-pack = ""  then "паллет" else v-cargo-pack)
                      , input (if v-cargo-pack = ""  then "паллет" else v-cargo-pack)
                      , input v-doc-places
                      , input (if v-cargo-mass-netto <> 0 and v-cargo-mass-netto <> ? then string(v-cargo-mass-netto) else "")
                      , input "1"
                      , input string(accum total stoim-noNDS)
                      , input string(accum total stoim-noNDS)
                  ).
                  run r-f_t1xl-write-cell-data in this-procedure (
                       input {&r-f_t1xl-margin}
                      ,input string( round ( ((accum total VAT-gds) + (accum total SLT-gds)) / (accum total stoim), 4 ) )
                  ).
             end.


    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-N_warrant_char}
        , input ( p-torgconf-N-warrant)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-N_ndovwho}
        , input(p-torgconf-ndovwho)
    ).
    if p-torgconf-date-warrant <> ?
    then do:
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-Day_warrant}
        , input (DAY(p-torgconf-date-warrant) )
    ).
            run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-Date_warrant}
        , input (substitute("&1&2&3",MonthNameRusGen(MONTH ( p-torgconf-date-warrant )),"  ", YEAR(p-torgconf-date-warrant) ))
    ).
    end.

    if p-torgconf-date-warrant <> ?
    then do:
        assign
           month =  MONTH ( p-torgconf-date-warrant )
           p-torgconf-date-char = substitute( "&1&2&3&4&5&6", DAY(p-torgconf-date-warrant), "  ", MonthNameRusGen(month), " ", YEAR(p-torgconf-date-warrant), " года")
        .
    end.

    if lookup( "TopAukc":U, p-mode ) <> 0 then /*Для Бизнес Букета всегда Одно*/
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_lineAmount}
        , input "Один"
    ).
    else
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_lineAmount}
        , input ( txt-LC )
    ).
    assign
        s1 = breakstr( s1, {&r-f_t1xl-f_sumLiteral1-length}, input-output s1, input-output s2)
    .
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_sumLiteral1}
        , input s1
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_sumLiteral2}
        , input s2
    ).
    if v-ext-doc-type <> {&TDEDT_Pri_Vnesh}
    then do:
      run r-f_t1xl-write-cell-data in this-procedure (
           input {&r-f_t1xl-f_permitterStatus}
         , input ( if v-torgconf-outsubs = no then v-torgconf-ogr-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
           input {&r-f_t1xl-f_permitterName}
         , input ( if v-torgconf-outsubs = no  then v-torgconf-ogr-name else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
           input {&r-f_t1xl-f_buhName}
         , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-accept_position}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-position else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-accept_fname}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-fname else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_post}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_post}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_wkr_name}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_wkr_name}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
      end.
    else do:
      run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-loadtplace}
        , input (if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-loadtname}
         , input (if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
    end.

    v-loadtplace = p-torgconf-post.

    v-loadtname = p-torgconf-wrkr-name.


/*    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_permitterStatus}
        , input ( if lookup( "MAG":U, p-mode ) <> 0 then "Ген. директор" else "":U )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_permitterName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-main-boss else "":U )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_buhName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
    ).  */

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    run r-f_t1xl-close in this-procedure /* (input p-mode)*/.

/*  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
*/

  /*os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .*/

    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 8}
end.







/*====================================================================*/
/*---S---------------- Печать линии в документе ----------------------*/
procedure print-line :
define input parameter p-trn-doc-code   as character        no-undo.
define input parameter p-sort-type      as character        no-undo.

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
define variable v-gds-name                      as character    no-undo.
define variable v-void-decimal                  as decimal      no-undo.
define variable v-price-no-VAT                  as decimal      no-undo.
define variable v-VAT-pc                        as decimal      no-undo.
define variable v-SLT-pc                        as decimal      no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_tax_parts         for parts.
    define buffer buf_temp_gds-name for temp_gds-name.
do
for buf_trn-doc
  , buf_tax_parts
  , buf_temp_gds-name
on error undo, return error
:
    run writelog in this-procedure (log-file-name, 1, "Печать строки товара").
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    /*---S--------- Определили наименование товара -------------------*/
    empty temp-table buf_temp_gds-name.
    assign
        v-torg-12-gds-name-key  = 0
        v-gds-name              = goods.gds-name
    .
    if FullGdsName
    and v-gds-name <> "":U
    then do:
        do
        while v-gds-name <> "":U
        :
            assign
                v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
            .
            create buf_temp_gds-name.
            assign
                buf_temp_gds-name.gdn-key = v-torg-12-gds-name-key
            .
            run p-fmt-split-string in this-procedure (
                  input v-gds-name
                , input v-torg-12-gds-name-length
                , output buf_temp_gds-name.gdnString
                , output v-gds-name
            ).
        end.
        find first buf_temp_gds-name
             where buf_temp_gds-name.gdn-key = 1
        no-error.
        if available buf_temp_gds-name
        then do:
        assign
                v-gds-name    = buf_temp_gds-name.gdnString
        .
    end.
    else do:
        assign
                v-gds-name    = goods.gds-name
        .
    end.
    end.
    else do:
        assign
            v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
        .
        create buf_temp_gds-name.
        assign
            buf_temp_gds-name.gdn-key   = v-torg-12-gds-name-key
            buf_temp_gds-name.gdnString = v-gds-name
        .
    end.
/*    output to d:\111.txt append.*/
/*    put unformatted*/
/*        substitute( "&1&2", {&new-line}, fill( "-",80 ) )*/
/*    .*/
/*    for each buf_temp_gds-name*/
/*    :*/
/*        put unformatted*/
/*            substitute( "&1&2", {&new-line}, buf_temp_gds-name.gdnString )*/
/*        .*/
/*    end.*/
/*    output close.*/
    run writelog in this-procedure (
        log-file-name,
        2,
        substitute( "Определили наименование товара ( &1 )", v-gds-name )
                                        ).
    /*---E--------- Определили наименование товара -------------------*/
    /*---S--------- Печать по шкалам или нет -------------------------*/
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
    if ( ( gds-prt.node-name <> {&empty-scale} )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    then do:
        /*---S--------- Не пустая шкала ----------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first gds-dtl no-lock
            where gds-dtl.prod-type = doc-line.prod-type
              and gds-dtl.prod-code = doc-line.prod-code
              and gds-dtl.artic     = doc-line.artic
              and gds-dtl.doc-code  = doc-line.doc-code
        no-error.
        if not available (gds-dtl)     /*Если новый товар по шкалам еще не разбит, цены пока неизвестны*/
        then assign
            price-noNDS   = 0
            price-withNDS = 0
        .
        if PrintScale
        then do:
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
        for each gds-dtl no-lock                        /*Средняя цена для всех признаков. Если расход, то печатать ее*/
           where gds-dtl.prod-type  = doc-line.prod-type
             and gds-dtl.prod-code  = doc-line.prod-code
             and gds-dtl.artic      = doc-line.artic
             and gds-dtl.doc-code   = doc-line.doc-code
        :
            find first gds-prt no-lock
                    where gds-prt.node-code = gds-dtl.prt-code
            .
            { str/out-vatp.i calc-gds-dtl doc-line. buf_trn-doc. gds-dtl. }
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
                v-sum-prt-sum-without-tax = v-sum-prt-sum-without-tax   + ( ( price-withNDS - VAT-gds - SLT-gds )
                                                                            * gds-dtl.fact-qnty )
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
        run print-line-dtl in this-procedure (
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
            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = v-rootnode-code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            assign
              v-ext-artic = ""
            .
            find first ub.ext-artic no-lock
                 where ub.ext-artic.gds-code = bar-code.gds-code
                   and ub.ext-artic.cli-code = v-cli-code
                   and ub.ext-artic.cli-type = v-cli-type
                   and ub.ext-artic.status_  = {&current-status} no-error.
            if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input goods.unit-base
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( stoim / tqnty )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        /*---E--------- Если не надо печатать по признакам ---------------*/
        end.
        /*---E--------- Не пустая шкала ----------------------------------*/
    end.
    else do:
        /*---S--------- Пустая шкала -------------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Пустая шкала или отключена печать по шкалам или накладная от имени поставщика").
        find first bar-code no-lock
            where bar-code.gds-code = goods.gds-code
            and bar-code.unit-cli   = goods.unit-base
            and bar-code.node-code  = v-rootnode-code
            and bar-code.part-code  = ""
            and bar-code.in-code    = ""
        .
        assign
          v-ext-artic = ""
        .
        find first ub.ext-artic no-lock
             where ub.ext-artic.gds-code = bar-code.gds-code
               and ub.ext-artic.cli-code = v-cli-code
               and ub.ext-artic.cli-type = v-cli-type
               and ub.ext-artic.status_  = {&current-status} no-error.
        if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
        if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
/*            and PrintScale = no               */
/*           or hvrdtax (recid(goods)) = yes    */
        then do:
            /*---S--------- Возврат поставщику: печать по партиям или стеклопосуды ------------*/
            run writelog in this-procedure (log-file-name, 3, "Возврат поставщику при печати по партиям "
/*                                                                        + "или товар со стеклопосудой"*/
                                                ).
/*      При возврате поставщику до версии 12 цену в строке документа можно было изменить.
            define variable v-new-VAT-gds           as decimal      no-undo.
            define variable v-new-SLT-gds           as decimal      no-undo.
            define variable v-new-price-withNDS     as decimal      no-undo.
            run check-diff-doc-line-and-parts in this-procedure (
                  input rowid( doc-line )
                , input v-rootnode-code
                , output v-price-is-changed
                , output v-new-VAT-gds
                , output v-new-SLT-gds
                , output v-new-price-withNDS
            ).
            if v-price-is-changed = yes
            then do:
                assign
                    v-VAT-gds       = v-new-VAT-gds
                    v-SLT-gds       = v-new-SLT-gds
                    v-price-withNDS = v-new-price-withNDS
                .
            end.
*/
            assign      /* надо брать учетную цену из партий          */
                v-price-is-changed  =  no
            .
            for each parts
               where parts.obj-type     = doc-line.obj-type
                 and parts.obj-code     = doc-line.obj-code
                 and parts.artic        = goods.artic
                 and parts.prod-type    = goods.prod-type
                 and parts.prod-code    = goods.prod-code
                 and parts.out-code     = doc-line.doc-code
            :
                /*---S--------- Для каждой партии --------------------------------*/
                run print-line-parts in this-procedure (
                      input buf_trn-doc.doc-code
                    , input v-price-is-changed
                    , input v-gds-name
                    , input-output v-VAT-gds
                    , input-output v-SLT-gds
                    , input-output v-price-withNDS
                    , input-output v-tax
                    , input-output v-tax-price
                    , input-output v-tax-sum
                ).
                accumulate
                    prt-tqnty ( TOTAL )
                    prt-VAT-gds ( TOTAL )
                    prt-SLT-gds ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim ( TOTAL )
                .
                assign
                    v-line-counter     = v-line-counter + 1
                    v-doc-line-counter = v-doc-line-counter + 1
                .
                /*---E--------- Для каждой партии --------------------------------*/
            end.
            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
            .
            run writelog in this-procedure (log-file-name, 3,
                                                            "После цикла по партиям: Установили количество ( "
                                                            + dtm-char( string(tqnty) )
                                                            + " ) и сумму ( "
                                                            + dtm-char( string( stoim ) )
                                                            + " ) для общего итога "
                                                ).
            /*---E--------- Возврат поставщику: печать по партиям или стеклопосуды ------------*/
        end.
        else do:
            /*---S--------- Печать не по партиям -----------------------------*/
            if Invers
            then do:
                assign
                    tqnty    = doc-line.cli-qnty
                    unit-str = doc-line.unit-cli
                .
                { str/in-vat.i
                  buf_trn-doc.doc-code
                  buf_trn-doc.base-rate
                  buf_trn-doc.base-scale
                  buf_trn-doc.exch-rate
                  buf_trn-doc.exch-scale
                  buf_trn-doc.vat-type
                  buf_trn-doc.slt-type
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
                    VAT-gds       = varprice-vat
                    SLT-gds       = varprice-slt
                    price-withNDS = varprice-no-vat-slt + VAT-gds + SLT-gds
                .
            end.
            else do:
                find first gds-dtl no-lock
                     where gds-dtl.doc-code      = doc-line.doc-code
                       and gds-dtl.prod-type   = doc-line.prod-type
                       and gds-dtl.prod-code   = doc-line.prod-code
                       and gds-dtl.artic       = doc-line.artic
                       and gds-dtl.prt-code    = v-rootnode-code
                no-error.
                if available gds-dtl
                then do:
                    assign
                        tqnty    = gds-dtl.fact-qnty
                    .
                end.
                else do:
                    assign
                        tqnty    = doc-line.fact-qnty
                    .
                end.
                assign
                    unit-str = goods.unit-base
                .
                if buf_trn-doc.doc-type = {&income}
                or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                or CostPrice
                then do:
                    { str/in-vatp.i calc doc-line. buf_trn-doc. g }
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
                    if available gds-dtl
                    then do:
                      { str/out-vatp.i calc-gds-dtl doc-line. buf_trn-doc. gds-dtl. }
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
                end.
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
                    , output v-SLT-pc
                    , output VAT-gds
                    , output SLT-gds
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
            run writelog in this-procedure (log-file-name, 3, "Печать не по партиям. Стоимость с НДС ( "
                                                                        + dtm-char( string( stoim ) )
                                                                        + " ). Количество ( "
                                                                        + dtm-char( string( tqnty ) )
                                                                        + " ). Третий налог ( "
                                                                        + dtm-char( string( v-tax ) )
                                                                        + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            if hvrdtax (recid(goods))
            then do:
                /*---S--------- Третий налог выводится отдельными строками ---------*/
                run tax-name (  input {&road-tax}
                             , output v-tax-name
                             ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                parts-for-tax:
                for each buf_tax_parts
                   where buf_tax_parts.obj-type     = doc-line.obj-type
                     and buf_tax_parts.obj-code     = doc-line.obj-code
                     and buf_tax_parts.artic        = goods.artic
                     and buf_tax_parts.prod-type    = goods.prod-type
                     and buf_tax_parts.prod-code    = goods.prod-code
                     and buf_tax_parts.out-code     = doc-line.doc-code
                break by buf_tax_parts.road-tax-base
                :
                    if first-of (buf_tax_parts.road-tax-base)
                    then do:
                        assign
                            v-parts-tax-qnty    = 0
                            v-tax               = 0
                            v-tax-parts-price   =  ( if PrintRubl
                                                    then buf_tax_parts.road-tax-rubl
                                                    else buf_tax_parts.road-tax-base )
                        .
                    end.
                    assign
                        v-parts-tax-qnty    = v-parts-tax-qnty + buf_tax_parts.fact-qnty
                        v-tax               = v-tax + ( v-tax-parts-price * buf_tax_parts.fact-qnty )
                    .
                    if not last-of (buf_tax_parts.road-tax-base)
                    then do:
                        next parts-for-tax.
                    end.
                    if p-round = "round":U
                    then do:
                        run p-fmt-round in this-procedure (
                              input v-parts-tax-qnty
                            , input v-tax-parts-price
                            , input 0
                            , input 0
                            , input 0
                            , output v-tax-parts-price
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-void-decimal
                            , output v-tax
                            , output v-void-decimal
                        ).
                    end.
                end.
                if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                run r-f_t1xl-sheet1-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( v-parts-tax-qnty )
                    , input string( v-tax-parts-price )
                    , input string( v-tax )
                ).
                end.
                assign
                    v-tax           = v-tax-price * tqnty
                    price-noNDS     = price-noNDS + v-tax-price
                    stoim-noNDS     = price-noNDS * tqnty
                    stoim           = stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4,
                                        "Снова вычислили суммы для строки. Сумма с НДС ( "
                                        + dtm-char( string( stoim ) )
                                        + " )"
                                                    ).
                /*---E--------- Третий налог выводится отдельными строками ---------*/
            end.

            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
            /*---E--------- Печать не по партиям -----------------------------*/
        end.
        /*---E--------- Пустая шкала -------------------------------------*/
    end.
    /*---E--------- Печать по шкалам или нет -------------------------*/
end.
end procedure. /* print-line */
/*---E-------- Печать линии в документе -----------------*/











/*==========================================================================*/
procedure print-line-parts :
define input parameter p-trn-doc-code           as character        no-undo.
define input parameter p-price-is-changed       as logical          no-undo.
define input parameter p-gds-name               as character        no-undo.
define input-output parameter p-VAT-gds         as decimal          no-undo.
define input-output parameter p-SLT-gds         as decimal          no-undo.
define input-output parameter p-price-withNDS   as decimal          no-undo.
define input-output parameter p-tax             as decimal          no-undo.
define input-output parameter p-tax-price       as decimal          no-undo.
define input-output parameter p-tax-sum         as decimal          no-undo.

    define variable v-tax-name          as character    no-undo.
    define variable v-VAT-pc            as decimal      no-undo.
    define variable v-SLT-pc            as decimal      no-undo.
    define variable v-void-decimal      as decimal      no-undo.

    define buffer buf_trn-doc       for trn-doc.
do
for buf_trn-doc
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    if p-price-is-changed  =  no
    or CostPrice = yes
    then do:
        { str/in-vatp.i calc-parts parts. buf_trn-doc. }
        assign
            p-VAT-gds       = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
            p-SLT-gds       = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
            p-tax-price     = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
            p-price-withNDS = ( if PrintRubl
                              then price-rubl-with-tax-loc - transport-rubl-loc - other-rubl-loc - p-tax-price
                              else price-base-with-tax-loc - transport-base-loc - other-base-loc - p-tax-price )
            p-tax           = p-tax-price * parts.qnty
            p-tax-sum       = p-tax-sum + p-tax
        .
    end.

    if VAT-gds = ? then VAT-gds = 0.
    if SLT-gds = ? then SLT-gds = 0.

    assign
        tqnty           = parts.fact-qnty
        unit-str        = goods.unit-base
        price-noNDS     = p-price-withNDS - p-VAT-gds - p-SLT-gds
        VAT-gds         = p-VAT-gds * tqnty
        SLT-gds         = p-SLT-gds * tqnty
        stoim-noNDS     = price-noNDS * tqnty
        stoim           = stoim-noNDS + VAT-gds
        price-withNDS   = p-price-withNDS
    .
    run writelog in this-procedure (
          input log-file-name
        , input 5
        , input substitute( "Партия: Кол-во ( &1 ) c НДС ( &2 )"
                            , dtm-char( string( tqnty ) )
                            , dtm-char( string( price-withNDS ) ) )
    ).
    if p-round = "round":U
    then do:
        run p-fmt-round in this-procedure (
              input tqnty
            , input price-noNDS
            , input VAT-gds     / tqnty
            , input SLT-gds     / tqnty
            , input 0
            , output price-noNDS
            , output v-VAT-pc
            , output v-SLT-pc
            , output VAT-gds
            , output SLT-gds
            , output v-void-decimal
            , output stoim-noNDS
            , output stoim
        ).
        assign
            stoim           = stoim - SLT-gds
        .
    end.
    assign
      v-ext-artic = ""
    .
    find first ub.ext-artic no-lock
          where ub.ext-artic.gds-code = bar-code.gds-code
            and ub.ext-artic.cli-code = v-cli-code
            and ub.ext-artic.cli-type = v-cli-type
            and ub.ext-artic.status_  = {&current-status} no-error.
    if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
    run r-f_t1xl-sheet1-write-line-data in this-procedure (
          input v-doc-line-counter
        , input substitute( "&1 &2", goods.artic, goods.gds-name )
        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
        , input unit-str
        , input "":U
        , input "":U
        , input "":U
        , input string( tqnty )
        , input string( price-noNDS )
        , input string( stoim + SLT-gds )
    ).
    end.
    assign
        prt-tqnty =  tqnty
        prt-VAT-gds = VAT-gds
        prt-SLT-gds = SLT-gds
        prt-stoim-noNDS = price-noNDS * prt-tqnty
        prt-stoim = prt-stoim-noNDS + prt-VAT-gds
    .
    if hvrdtax (recid(goods))
    then do:
        /*---S--------- Третий налог выводится отдельной строкой ---------*/
        run tax-name (  input {&road-tax}
                    , output v-tax-name
                    ).
        run writelog in this-procedure (
              input log-file-name
            , input 4
            , input substitute( "Есть третий налог ( &1 ) сумма ( &2 )"
                                , dtm-char( v-tax-name )
                                , dtm-char( string( p-tax ) ) )
        ).
        if p-round = "round":U
        then do:
            run p-fmt-round in this-procedure (
                  input tqnty
                , input p-tax-price
                , input 0
                , input 0
                , input 0
                , output p-tax-price
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-decimal
                , output p-tax
                , output v-void-decimal
            ).
        end.
        if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
        run r-f_t1xl-sheet1-write-line-data in this-procedure (
              input 0
            , input v-tax-name
            , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
            , input unit-str
            , input "":U
            , input "":U
            , input "":U
            , input string( tqnty )
            , input string( p-tax-price )
            , input string( p-tax )
        ).
        end.
        assign
            price-withNDS   = p-price-withNDS + p-tax-price
            price-noNDS     = price-withNDS - p-VAT-gds - p-SLT-gds
            prt-stoim-noNDS = price-noNDS * tqnty
            prt-stoim       = prt-stoim-noNDS + VAT-gds
            v-line-counter  = v-line-counter + 1
        .
        run writelog in this-procedure (
              input log-file-name
            , input 4
            , input substitute( "Еще раз вычислили сумму с НДС ( &1 ) для общего итога"
                                , dtm-char( string(prt-stoim) ) )
        ).
        /*---E--------- Третий налог выводится отдельной строкой ---------*/
    end.

end.
end procedure. /* print-line-parts */

/*==========================================================================*/
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

    define variable v-avg-prt-sum-without-tax-out   as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax-out      as decimal      no-undo.
    define variable v-avg-VAT-out                   as decimal      no-undo.
    define variable v-VAT-pc                        as decimal      no-undo.
    define variable v-SLT-pc                        as decimal      no-undo.
    define variable v-void-decimal                  as decimal      no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
do
for buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
    assign
        p-prt-tqnty       = 0.0
        p-prt-VAT-gds     = 0.0
        p-prt-SLT-gds     = 0.0
        p-prt-stoim-noNDS = 0.0
        p-prt-stoim       = 0.0
    .
        for each gds-dtl no-lock
           where gds-dtl.prod-type = buf_doc-line.prod-type
             and gds-dtl.prod-code = buf_doc-line.prod-code
             and gds-dtl.artic     = buf_doc-line.artic
             and gds-dtl.doc-code  = buf_doc-line.doc-code
        :
            /*---S--------- Для каждого признака -----------------------------*/
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .
/*            if buf_trn-doc.doc-type = {&income}*/
            if CostPrice = yes
            then do:
                { str/in-vatp.i calc buf_doc-line. buf_trn-doc. g }
                assign
                    VAT-gds = ( if PrintRubl then vat-rubl-loc else vat-base-loc )
                    SLT-gds = ( if PrintRubl then slt-rubl-loc else slt-base-loc )
                    price-withNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
                .
            end.
            else do:
                { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. gds-dtl. }
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
            if p-round = "round":U
            then do:
                run p-fmt-round in this-procedure (
                      input prt-tqnty
                    , input price-noNDS
                    , input VAT-gds
                    , input SLT-gds
                    , input 0
                    , output price-noNDS
                    , output v-vat-pc
                    , output v-slt-pc
                    , output prt-VAT-gds
                    , output prt-SLT-gds
                    , output v-void-decimal
                    , output prt-stoim-noNDS
                    , output prt-stoim
                ).
                assign
                    prt-stoim       = prt-stoim - prt-SLT-gds
                .
            end.
            else do:
                assign
                    prt-VAT-gds     = VAT-gds * prt-tqnty
                    prt-SLT-gds     = SLT-gds * prt-tqnty
                    prt-stoim-noNDS = price-noNDS * prt-tqnty
                    prt-stoim       = prt-stoim-noNDS + prt-VAT-gds
                .
            end.
            assign
                p-prt-tqnty       = p-prt-tqnty       + prt-tqnty
                p-prt-VAT-gds     = p-prt-VAT-gds     + prt-VAT-gds
                p-prt-SLT-gds     = p-prt-SLT-gds     + prt-SLT-gds
                p-prt-stoim-noNDS = p-prt-stoim-noNDS + prt-stoim-noNDS
                p-prt-stoim       = p-prt-stoim       + prt-stoim
            .
            if PrintScale
            then do:
                /*---S--------- Стоит галочка печати по признакам ----------------*/
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = gds-dtl.prt-code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                assign
                 v-ext-artic = ""
                .
                find first ub.ext-artic no-lock
                     where ub.ext-artic.gds-code = bar-code.gds-code
                       and ub.ext-artic.cli-code = v-cli-code
                       and ub.ext-artic.cli-type = v-cli-type
                       and ub.ext-artic.status_  = {&current-status} no-error.
                if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
                v-prt-name = "".
                do while available gds-prt:
                    if available gds-prt
                    then assign
                        v-prt-name = "\" + string( gds-prt.node-name, "x(10)" ) + v-prt-name
                    .
                    assign
                        v-node-code = gds-prt.upper-code
                    .
                    find first gds-prt no-lock
                         where gds-prt.node-code = v-node-code
                           and gds-prt.root <> yes
                    no-error.
                end.
                if buf_trn-doc.doc-type = {&income}
                then assign
                    p-avg-prt-price             = price-withNDS
                    p-avg-prt-price-no-tax      = price-noNDS
                    p-avg-VAT                   = prt-VAT-gds
                    p-avg-prt-sum-with-tax      = prt-stoim
                    p-avg-prt-sum-without-tax   = prt-stoim-noNDS
                .
                else assign
                    v-avg-VAT-out                 = p-avg-VAT                  * gds-dtl.fact-qnty
                    v-avg-prt-sum-with-tax-out    = p-avg-prt-sum-with-tax     * gds-dtl.fact-qnty
                    v-avg-prt-sum-without-tax-out = p-avg-prt-sum-without-tax  * gds-dtl.fact-qnty
                .
                if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                then do:
                    if p-round = "round":U
                    then do:
                        run p-fmt-round in this-procedure (
                              input prt-tqnty
                            , input p-avg-prt-price-no-tax
                            , input v-avg-VAT-out     / tqnty
                            , input prt-SLT-gds       / tqnty
                            , input 0
                            , output p-avg-prt-price-no-tax
                            , output v-vat-pc
                            , output v-slt-pc
                            , output v-avg-VAT-out
                            , output prt-SLT-gds
                            , output v-void-decimal
                            , output v-avg-prt-sum-without-tax-out
                            , output v-avg-prt-sum-with-tax-out
                        ).
                        assign
                            v-avg-prt-sum-with-tax-out  = v-avg-prt-sum-with-tax-out - prt-SLT-gds
                            p-avg-prt-price             = v-avg-prt-sum-with-tax-out / prt-tqnty
                        .
                    end.
                    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input string( p-avg-prt-price-no-tax + v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                    end.
                end.        /* if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} */
                else do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS + prt-VAT-gds )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                    end.
                end.        /* if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} */

                /*---E--------- Стоит галочка печати по признакам ----------------*/
            end.
            /*---E--------- Для каждого признака -----------------------------*/
        end.
end.
end procedure. /* print-line-dtl */



/*==========================================================================*/
procedure print-header :
define input parameter p-trn-doc-code   as character        no-undo.

define variable v-print-doc                 as character                no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_clients           for clients .
    define buffer buf_temp_p-fmt_string-part    for temp_p-fmt_string-part.
do
for buf_trn-doc
  , buf_clients
  , buf_temp_p-fmt_string-part
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    run gbl/conf-rd.p ( "factur01", "", "", 0, "", "", "", no, output v-print-doc, output v-par-type ) no-error.
    if error-status :error
    then do:
        assign
            v-print-doc = "no"
        .
    end.
    assign
    p-sf-par = no
    .
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input p-reverse
        , input p-sf-par
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_docCode}
        , input v-torgconf-doc-code
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_tbl_docCode}
        , input v-torgconf-vdoc-code
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_docDate}
        , input v-torgconf-doc-date
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_tbl_docDate}
        , input v-torgconf-vdoc-date
    ).
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    no-error.
    case buf_clients.obj-type :
        when {&shop}
        then do:
            find first shop where shop.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = shop.doc-prt.
        end.
        when {&stock}
        then do:
            find first store where store.obj-code = buf_clients.obj-code no-lock .
            tdoc-prt = store.doc-prt .
        end.
    end case.
    if not tdoc-prt or Invers = yes
    then do:
        assign
            PrintScale = no
        .
    end.
    find first pay-type no-lock
         where pay-type.obj-code = buf_trn-doc.pay-code
    no-error .
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_orgFrom}
      , input v-torgconf-organization
    ).
    define var v-temp-phone as character.
    define var v-temp-addres as character.
    /*run inidebug.p.*/
    if  v-torgconf-organization matches "*" +   v-torgconf-self-host-phone   + "*"   and  v-torgconf-self-host-phone   <> ""  then  v-temp-phone =  v-torgconf-self-host-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-phone  + "*"   and  v-torgconf-sup-host-phone  <> ""  then  v-temp-phone =  v-torgconf-sup-host-phone .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-obj-phone  + "*"   and  v-torgconf-self-obj-phone  <> ""  then  v-temp-phone =  v-torgconf-self-obj-phone .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-obj-phone   + "*"   and  v-torgconf-sup-obj-phone   <> ""  then  v-temp-phone =  v-torgconf-sup-obj-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-phone   + "*"   and  v-torgconf-cli-phone   <> ""  then  v-temp-phone =  v-torgconf-cli-phone  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-phone  + "*"   and  v-torgconf-ship-phone  <> ""  then  v-temp-phone =  v-torgconf-ship-phone .

    if  v-torgconf-organization matches "*" +   v-torgconf-self-host-addres  + "*"   and  v-torgconf-self-host-addres  <> ""  then  v-temp-addres =  v-torgconf-self-host-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-host-post-addres               + "*"   and  v-torgconf-self-host-post-addres               <> ""  then  v-temp-addres =  v-torgconf-self-host-post-addres              .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-addres   + "*"   and  v-torgconf-sup-host-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-host-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-host-post-addres  + "*"   and  v-torgconf-sup-host-post-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-host-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-temp-post-addres  + "*"   and  v-torgconf-temp-post-addres  <> ""  then  v-temp-addres =  v-torgconf-temp-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-obj-addres   + "*"   and  v-torgconf-self-obj-addres   <> ""  then  v-temp-addres =  v-torgconf-self-obj-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-obj-addres  + "*"   and  v-torgconf-sup-obj-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-obj-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-self-bank-addres  + "*"   and  v-torgconf-self-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-self-bank-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sup-bank-addres   + "*"   and  v-torgconf-sup-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-bank-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-addres  + "*"   and  v-torgconf-cli-addres  <> ""  then  v-temp-addres =  v-torgconf-cli-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-post-addres   + "*"   and  v-torgconf-cli-post-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-post-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-addres   + "*"   and  v-torgconf-ship-addres   <> ""  then  v-temp-addres =  v-torgconf-ship-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-post-addres  + "*"   and  v-torgconf-ship-post-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-post-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cli-bank-addres   + "*"   and  v-torgconf-cli-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-bank-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-ship-bank-addres  + "*"   and  v-torgconf-ship-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-bank-addres .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cargo-to-addres   + "*"   and  v-torgconf-cargo-to-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-to-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-cargo-from-addres   + "*"   and  v-torgconf-cargo-from-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-from-addres  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-supplier-addr   + "*"   and  v-torgconf-supplier-addr   <> ""  then  v-temp-addres =  v-torgconf-supplier-addr  .
    else if  v-torgconf-organization matches "*" +   v-torgconf-saler-addr  + "*"   and  v-torgconf-saler-addr  <> ""  then  v-temp-addres =  v-torgconf-saler-addr .
    else if  v-torgconf-organization matches "*" +   v-torgconf-consignee-addr  + "*"   and  v-torgconf-consignee-addr  <> ""  then  v-temp-addres =  v-torgconf-consignee-addr .
    else if  v-torgconf-organization matches "*" +   v-torgconf-sf-buyer-addr   + "*"   and  v-torgconf-sf-buyer-addr   <> ""  then  v-temp-addres =  v-torgconf-sf-buyer-addr  .

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addrFrom}
        , input substitute( "&1&2&3",  v-temp-addres , ( if v-temp-phone   = "":U or v-temp-addres = "":U then "":U else ", " ), v-temp-phone)
    ).
     v-temp-addres = "".
     v-temp-phone  =  "".

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_OKPO_0}
        , input v-torgconf-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_cliFrom}
        , input v-torgconf-client-from
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoTo}
        , input v-torgconf-torg12-cargo-label
    ).

    if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-phone   + "*"   and  v-torgconf-self-host-phone   <> ""  then  v-temp-phone =  v-torgconf-self-host-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-phone  + "*"   and  v-torgconf-sup-host-phone  <> ""  then  v-temp-phone =  v-torgconf-sup-host-phone .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-obj-phone  + "*"   and  v-torgconf-self-obj-phone  <> ""  then  v-temp-phone =  v-torgconf-self-obj-phone .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-obj-phone   + "*"   and  v-torgconf-sup-obj-phone   <> ""  then  v-temp-phone =  v-torgconf-sup-obj-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-phone   + "*"   and  v-torgconf-cli-phone   <> ""  then  v-temp-phone =  v-torgconf-cli-phone  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-phone  + "*"   and  v-torgconf-ship-phone  <> ""  then  v-temp-phone =  v-torgconf-ship-phone .

    if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-addres  + "*"   and  v-torgconf-self-host-addres  <> ""  then  v-temp-addres =  v-torgconf-self-host-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-host-post-addres               + "*"   and  v-torgconf-self-host-post-addres               <> ""  then  v-temp-addres =  v-torgconf-self-host-post-addres              .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-addres   + "*"   and  v-torgconf-sup-host-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-host-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-host-post-addres  + "*"   and  v-torgconf-sup-host-post-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-host-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-temp-post-addres  + "*"   and  v-torgconf-temp-post-addres  <> ""  then  v-temp-addres =  v-torgconf-temp-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-obj-addres   + "*"   and  v-torgconf-self-obj-addres   <> ""  then  v-temp-addres =  v-torgconf-self-obj-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-obj-addres  + "*"   and  v-torgconf-sup-obj-addres  <> ""  then  v-temp-addres =  v-torgconf-sup-obj-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-self-bank-addres  + "*"   and  v-torgconf-self-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-self-bank-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sup-bank-addres   + "*"   and  v-torgconf-sup-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-sup-bank-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-addres  + "*"   and  v-torgconf-cli-addres  <> ""  then  v-temp-addres =  v-torgconf-cli-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-post-addres   + "*"   and  v-torgconf-cli-post-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-post-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-addres   + "*"   and  v-torgconf-ship-addres   <> ""  then  v-temp-addres =  v-torgconf-ship-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-post-addres  + "*"   and  v-torgconf-ship-post-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-post-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cli-bank-addres   + "*"   and  v-torgconf-cli-bank-addres   <> ""  then  v-temp-addres =  v-torgconf-cli-bank-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-ship-bank-addres  + "*"   and  v-torgconf-ship-bank-addres  <> ""  then  v-temp-addres =  v-torgconf-ship-bank-addres .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cargo-to-addres   + "*"   and  v-torgconf-cargo-to-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-to-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-cargo-from-addres   + "*"   and  v-torgconf-cargo-from-addres   <> ""  then  v-temp-addres =  v-torgconf-cargo-from-addres  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-supplier-addr   + "*"   and  v-torgconf-supplier-addr   <> ""  then  v-temp-addres =  v-torgconf-supplier-addr  .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-saler-addr  + "*"   and  v-torgconf-saler-addr  <> ""  then  v-temp-addres =  v-torgconf-saler-addr .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-consignee-addr  + "*"   and  v-torgconf-consignee-addr  <> ""  then  v-temp-addres =  v-torgconf-consignee-addr .
    else if  v-torgconf-torg12-cargo-value matches "*" +   v-torgconf-sf-buyer-addr   + "*"   and  v-torgconf-sf-buyer-addr   <> ""  then  v-temp-addres =  v-torgconf-sf-buyer-addr  .

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addrTo}
        , input substitute( "&1&2&3",  v-temp-addres , ( if v-temp-phone   = "":U or v-temp-addres = "":U then "":U else ", " ), v-temp-phone)
    ).

     v-temp-addres = "".
     v-temp-phone  =  "".


    if ( buf_trn-doc.doc-type = {&income}
    or   buf_trn-doc.doc-type = {&return} )
    and not invers
    and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
    then do:
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_from_to_uderline}
        , input "(организация-грузополучатель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.
    ELSE DO:
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_from_to_uderline}
        , input "(организация-грузоотправитель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.


    if ( buf_trn-doc.doc-type = {&income}
    or buf_trn-doc.doc-type = {&return} )
    and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
    and buf_trn-doc.ext-doc-type <> {&WDEDT_Put_Cli}
    then do:
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoToValue}
        , input v-torgconf-torg12-cargo-value
    ).
    end.
    else do:
/*    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoToValue}
        , input substitute( "&1 {&abbr_inn_allshift} &2 {&abbr_kpp_allshift} &3"
                                                      , v-torgconf-consignee
                                                      , v-torgconf-consignee-inn
                                                      , v-torgconf-consignee-kpp
                                                      )
    ). */
        run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoToValue}
        , input v-torgconf-torg12-cargo-value
        ).

    end.






    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_OKPO}
        , input v-torgconf-torg12-cargo-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_OKPO2}
        , input v-torgconf-supplier-okpo
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_OKPO3}
        , input v-torgconf-saler-okpo
    ).
    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input v-torgconf-suppi
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
        end.
    end.
    else do:
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_supplier}
        , input v-torgconf-suppi
    ).

    define variable v-attr-value       as character            no-undo .
    define variable v-attr-type        as character            no-undo .
    define variable v-osnov            as character initial "" no-undo .
    define variable v-osnov-doc        as character initial "" no-undo .
    define variable v-osnov-1          as character initial "" no-undo .
    define variable v-osnov-attr       as character initial "" no-undo .
    define variable v-osnov-num        as character initial ?  no-undo .
    define variable v-osnov-num-doc    as character initial "" no-undo .
    define variable v-osnov-date       as character initial ?  no-undo .
    define variable v-osnov-date-doc   as character initial "" no-undo .
    define variable v-osnov-num-attr   as character initial "" no-undo .
    define variable v-osnov-date-attr  as character initial "" no-undo .
    define variable v-is-fin           as character            no-undo .
    define variable v-osnov-num-1      as character initial "" no-undo .
    define variable v-osnov-date-1     as character initial "" no-undo .
    define variable v-ind              as integer              no-undo .
    define variable v-ind2             as integer              no-undo .


    define buffer bf_doc-line     for ub.doc-line .
    define buffer bf_parts        for ub.parts .
    define buffer bf_trn-doc      for ub.trn-doc .
    define buffer bf_goods        for ub.goods .
    define buffer buf_contract    for ub.contract .


        define variable v-income-doc-code like parts.in-code no-undo .


  /*1) Проверка атрибутов*/
  /* Номер договора */
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-ndog} v-osnov-num-attr v-attr-type no-error }
  /* Дата договора */
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-ddog} v-osnov-date-attr v-attr-type no-error }
  /*Документ-основание. Наименование*/
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nosn} v-osnov-attr v-attr-type no-error }


   if trim(v-osnov-num-attr)  = ""
   or trim(v-osnov-date-attr) = ""
   or trim(v-osnov-attr)      = ""
   then do:
    /*2*/
    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do:
        FIND FIRST buf_contract
                  WHERE buf_contract.contract-code = buf_trn-doc.contract-code
                  NO-LOCK
                  NO-ERROR
                  .
            IF AVAILABLE  buf_contract
            THEN DO:
            ASSIGN
               v-osnov-num-doc   = buf_contract.contract-prn-code
               v-osnov-date-doc  = STRING(buf_contract.contract-date)
               v-osnov-doc       = buf_contract.contract-name
            .
            END.

    end.
    /*2*/
    run gbl/conf-rd.p ( "is-fin"
                  , v-host-code
                  , buf_trn-doc.obj-type
                  , buf_trn-doc.obj-code
                  , ""
                  , ""
                  , ""
                  , no
                  , output v-is-fin
                  , output v-par-type
                  ) no-error .
    if error-status :error
    then  do:
       assign
             v-is-fin           = ""
       .
    end.
    IF v-is-fin = "yes"
    THEN DO:
      CASE buf_trn-doc.doc-type:
         WHEN {&income} then  do:
            FIND FIRST buf_contract
                  WHERE buf_contract.contract-code = buf_trn-doc.contract-code
                  NO-LOCK
                  NO-ERROR
                  .
            IF AVAILABLE  buf_contract
            THEN DO:
            ASSIGN
               v-osnov-num   = buf_contract.contract-prn-code
               v-osnov-date  = STRING(buf_contract.contract-date)
               v-osnov       = buf_contract.contract-name
            .
            END.
         end.
         WHEN {&expense} THEN DO:
         v-ind = 0.
            _single-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :
               assign
                  v-ind = v-ind + 1.
                  FIND FIRST buf_contract
                        WHERE buf_contract.contract-code = bf_parts.contract-code
                        NO-LOCK
                        NO-ERROR
                        .
                  IF AVAILABLE  buf_contract
                  THEN DO:
                  ASSIGN
                     v-osnov-num-1   = buf_contract.contract-prn-code
                     v-osnov-date    = STRING(buf_contract.contract-date)
                     v-osnov         = buf_contract.contract-name
                  .
                  END.
                  IF v-osnov-num = ?
                  and v-ind = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-reason.
                  END.
            END.

            IF v-osnov-num   = ?
            THEN
            _single-income-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :

                  FIND FIRST bf_trn-doc
                     WHERE bf_trn-doc.doc-code     = bf_parts.in-code
                     NO-LOCK
                     NO-ERROR
                     .

                  IF AVAILABLE bf_trn-doc THEN DO:
                     /* если партия порождена не внешним приходом,
                        то пытаемся найти порождающий документ для этой партии */
                     IF bf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
                     THEN DO:
                        run find-income-doc-code ( input bf_parts.in-code
                                                   , input bf_goods.gds-code
                                                   , input bf_parts.part-code
                                                   , output v-income-doc-code
                                                   ) .
                        if v-income-doc-code <> ? then do:
                           find first bf_trn-doc
                                 no-lock
                                 where bf_trn-doc.doc-code = v-income-doc-code
                                 no-error
                                 .
                           IF NOT AVAILABLE bf_trn-doc
                           THEN DO:
                              ASSIGN
                                 v-osnov-num   = ?
                                 v-osnov-date  = ?
                                 v-osnov       = ""
                              .
                              LEAVE _single-income-reason.
                           END.
                        END.
                     END.
                  END. /* AVAILABLE buf_trn-doc */
                  ELSE DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-income-reason.
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  {&trdcattr-ndog}
                                    , output v-osnov-num-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-num = ?
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input bf_trn-doc.doc-code
                                    , input {&trdcattr-ddog}
                                    , output v-osnov-date-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-date = ?
                  THEN DO:
                     ASSIGN
                        v-osnov-date = v-osnov-date-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  OR v-osnov-date <> v-osnov-date-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-income-reason.
                  END.
            END.
         END.
         OTHERWISE DO:

         END.
      END case.
    END.
    ELSE DO: /*Взаиморасчеты выкл*/
      CASE buf_trn-doc.doc-type:
         WHEN {&expense} THEN DO:
         v-ind2 = 0.
            _single-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic      = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type   = bf_doc-line.obj-type
               and bf_parts.obj-code     = bf_doc-line.obj-code
               and bf_parts.artic        = bf_doc-line.artic
               and bf_parts.prod-type    = bf_doc-line.prod-type
               and bf_parts.prod-code    = bf_doc-line.prod-code
               and bf_parts.out-code     = bf_doc-line.doc-code
               NO-LOCK
               :
               assign
               v-ind2 = v-ind2 + 1.
                  FIND FIRST bf_trn-doc
                     WHERE bf_trn-doc.doc-code   = bf_parts.in-code
                     NO-LOCK
                     NO-ERROR
                     .

                  IF AVAILABLE bf_trn-doc THEN DO:
                     /* если партия порождена не внешним приходом,
                        то пытаемся найти порождающий документ для этой партии */
                     IF bf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
                     THEN DO:
                        run find-income-doc-code ( input bf_parts.in-code
                                                   , input bf_goods.gds-code
                                                   , input bf_parts.part-code
                                                   , output v-income-doc-code
                                                   ) .
                        if v-income-doc-code <> ? then do:
                           find first bf_trn-doc
                                 no-lock
                                 where bf_trn-doc.doc-code = v-income-doc-code
                                 no-error
                                 .
                           IF NOT AVAILABLE bf_trn-doc
                           THEN DO:
                              ASSIGN
                                 v-osnov-num   = ?
                                 v-osnov-date  = ?
                                 v-osnov       = ""
                              .
                              LEAVE _single-reason.
                           END.
                        END.
                     END.
                  END. /* AVAILABLE buf_trn-doc */
                  ELSE DO:
                  ASSIGN
                     v-osnov-num   = ?
                     v-osnov-date  = ?
                     v-osnov       = ""
                  .
                  LEAVE _single-reason.
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  {&trdcattr-ndog}
                                    , output v-osnov-num-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-num = ?
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input bf_trn-doc.doc-code
                                    , input {&trdcattr-ddog}
                                    , output v-osnov-date-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-date = "":U
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov-date = v-osnov-date-1
                     .
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  {&trdcattr-nosn}
                                    , output v-osnov-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov = "":U
                  and v-ind2 = 1
                  THEN DO:
                     ASSIGN
                        v-osnov = v-osnov-1
                     .
                  END.
                  IF v-osnov-num  <> v-osnov-num-1
                  OR v-osnov-date <> v-osnov-date-1
                  or v-osnov      <> v-osnov-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ?
                        v-osnov-date  = ?
                        v-osnov       = ""
                     .
                     LEAVE _single-reason.
                  END.
            END.
         END.
         OTHERWISE DO:
         END.
      END CASE.
    END. /* NOT is-fin */
    end.

    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do:
        assign
         v-osnov-num  = v-osnov-num-doc
         v-osnov-date = v-osnov-date-doc
         v-osnov      = v-osnov-doc
        .
    end.

    if trim(v-osnov-num-attr)  <> ""
    then do:
        v-osnov-num = v-osnov-num-attr.
    end.
    if trim(v-osnov-date-attr)  <> ""
    then do:
        v-osnov-date = v-osnov-date-attr.
    end.
    if trim(v-osnov-attr)  <> ""
    then do:
        v-osnov = v-osnov-attr.
    end.

    IF v-osnov-date  = ?
    THEN DO:
      ASSIGN
         v-osnov-date  = ""
      .
    END.

    IF v-osnov-num   = ?
    THEN DO:
      ASSIGN
         v-osnov-num   = ""
         v-osnov-date  = ""
         v-osnov       = ""
      .
    END.


    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_saler}
        , input SUBSTITUTE( "&1 {&abbr_inn_allshift} &2 {&abbr_kpp_allshift} &3"
                                                          , v-torgconf-saler
                                                          , v-torgconf-saler-inn
                                                          , v-torgconf-saler-kpp
                                                          )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_saler1}
        , input SUBSTITUTE( "&1 {&abbr_inn_allshift} &2 {&abbr_kpp_allshift} &3"
                                                          , v-torgconf-saler
                                                          , v-torgconf-saler-inn
                                                          , v-torgconf-saler-kpp
                                                          )
    ).
    /*run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addrTo}
        , input v-torgconf-self-host-addres
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addrFrom}
        , input v-torgconf-consignee-addr
    ).*/
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_osn_doc_code}
        , input v-osnov-num
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_osn_doc_date}
        , input v-osnov-date
    ).

    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_reason}
        , input v-osnov
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_reason_num}
        , input v-osnov-num
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_reason_date}
        , input v-osnov-date
    ).
    define variable v-operation-type    as character    no-undo.
    assign
        v-operation-type = ( if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                             then ( if lookup( "MARI":U, p-mode ) = 0
                                    then "возврат пост-ку"
                                    else "":U )
                             else ( if buf_trn-doc.doc-type = {&income} and not Invers
                                    then " приход"
                                    else ( if buf_trn-doc.doc-type = {&return}
                                           then ( if lookup( "MARI":U, p-mode ) = 0
                                                  then " возврат"
                                                  else "":U )
                                           else " расход" ) )
                           )
    .
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_operationType}
        , input v-operation-type
    ).
end.
end procedure. /* print-header */


/*====================================================================
Печать строки документа по чекам

*/
procedure print-line-sj :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-sj-b-code      as integer          no-undo.

    define variable v-price-is-changed      as logical  no-undo.

    define variable v-sum-prt-qnty                  as decimal      no-undo.
    define variable v-avg-prt-price                 as decimal      no-undo.
    define variable v-avg-prt-price-no-tax          as decimal      no-undo.
    define variable v-sum-SLT                       as decimal      no-undo.
    define variable v-sum-VAT                       as decimal      no-undo.
    define variable v-avg-VAT                       as decimal      no-undo.
    define variable v-avg-VAT-out                   as decimal      no-undo.
    define variable v-sum-prt-sum-with-tax          as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax          as decimal      no-undo.
    define variable v-avg-prt-sum-with-tax-out      as decimal      no-undo.
    define variable v-sum-prt-sum-without-tax       as decimal      no-undo.
    define variable v-avg-prt-sum-without-tax       as decimal      no-undo.
    define variable v-avg-prt-sum-without-tax-out   as decimal      no-undo.
    define variable v-vat-pc                        as decimal      no-undo.
    define variable v-slt-pc                        as decimal      no-undo.
    define variable v-void-decimal                  as decimal      no-undo.
    define variable v-gds-name                      as character    no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_sj-t12        for sj-t12.
    define buffer buf_tax_parts     for parts.
    define buffer buf_temp_gds-name for temp_gds-name.
do
for buf_trn-doc
  , buf_sj-t12
  , buf_tax_parts
  , buf_temp_gds-name
on error undo, return error
:
    empty temp-table buf_temp_gds-name.
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    find first buf_sj-t12
         where buf_sj-t12.b-code = p-sj-b-code
    .
    run writelog in this-procedure (log-file-name, 1, "Печать строки товара по чекам").
    /*---S--------- Определили наименование товара -------------------*/
    assign
        v-torg-12-gds-name-key  = 0
        v-gds-name              = goods.gds-name
    .
    if FullGdsName
    and v-gds-name <> "":U
    then do:
        do
        while v-gds-name <> "":U
        :
            assign
                v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
            .
            create buf_temp_gds-name.
            assign
                buf_temp_gds-name.gdn-key = v-torg-12-gds-name-key
            .
            run p-fmt-split-string in this-procedure (
                  input v-gds-name
                , input v-torg-12-gds-name-length
                , output buf_temp_gds-name.gdnString
                , output v-gds-name
            ).
        end.
        assign
            v-gds-name    = goods.gds-name
        .
    end.
    else do:
        assign
            v-torg-12-gds-name-key = v-torg-12-gds-name-key + 1
        .
        create buf_temp_gds-name.
        assign
            buf_temp_gds-name.gdn-key   = v-torg-12-gds-name-key
            buf_temp_gds-name.gdnString = v-gds-name
        .
    end.
    run writelog in this-procedure( log-file-name, 2, substitute( "Товар: &1 &2 ", goods.artic, goods.gds-name ) ).
    /*---E--------- Определили наименование товара -------------------*/
    /*---S--------- Печать по шкалам или нет -------------------------*/
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
    if ( ( gds-prt.node-name <> {&empty-scale} )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    then do:
        /*---S--------- Не пустая шкала ----------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first gds-dtl no-lock
             where gds-dtl.prod-type = buf_sj-t12.prod-type
               and gds-dtl.prod-code = buf_sj-t12.prod-code
               and gds-dtl.artic     = buf_sj-t12.artic
               and gds-dtl.doc-code  = p-doc-code
        no-error.
        if not available gds-dtl     /*Если новый товар по шкалам еще не разбит, цены пока неизвестны*/
        then do:
            assign
                price-noNDS   = 0
                price-withNDS = 0
            .
        end.
        if PrintScale
        then do:
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
        for each gds-dtl no-lock                        /*Средняя цена для всех признаков. Если расход, то печатать ее*/
           where gds-dtl.prod-type  = buf_sj-t12.prod-type
             and gds-dtl.prod-code  = buf_sj-t12.prod-code
             and gds-dtl.artic      = buf_sj-t12.artic
             and gds-dtl.doc-code   = p-doc-code
        :
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .
            assign
                v-sum-prt-qnty  = v-sum-prt-qnty + buf_sj-t12.fact-qnty

                VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer            else buf_sj-t12.vat-base-buyer           )
                SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale             else buf_sj-t12.slt-base-sale            )
                price-withNDS   = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale  else buf_sj-t12.price-base-with-tax-sale )
            .
            run writelog in this-procedure (log-file-name, 1, substitute( "Цена НДС: &1 ", v-sum-VAT ) ).
            if VAT-gds = ?       then assign  VAT-gds       = 0.
            if SLT-gds = ?       then assign  SLT-gds       = 0.
            if price-withNDS = ? then assign  price-withNDS = 0.

            assign
                v-sum-VAT                 = v-sum-VAT                   + VAT-gds * buf_sj-t12.fact-qnty
                v-sum-prt-sum-with-tax    = v-sum-prt-sum-with-tax      + ( price-withNDS * buf_sj-t12.fact-qnty )
                v-sum-prt-sum-without-tax = v-sum-prt-sum-without-tax   + ( ( price-withNDS - VAT-gds - SLT-gds )
                                                                            * buf_sj-t12.fact-qnty )
            .
            run writelog in this-procedure (log-file-name, 1, substitute( "Сумма НДС: &1 ", v-sum-VAT ) ).
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

        for each gds-dtl no-lock
           where gds-dtl.prod-type  = buf_sj-t12.prod-type
             and gds-dtl.prod-code  = buf_sj-t12.prod-code
             and gds-dtl.artic      = buf_sj-t12.artic
             and gds-dtl.doc-code   = p-doc-code
        :
            /*---S--------- Для каждого признака -----------------------------*/
            find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
            .

            if buf_trn-doc.doc-type = {&income}
            or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            then do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-sale              else buf_sj-t12.vat-base-sale               )
                .
            end.
            else do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                .
            end.
            assign
                VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale              else buf_sj-t12.slt-base-sale               )
                price-withNDS   = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale   else buf_sj-t12.price-base-with-tax-sale    )
            .
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                price-noNDS     = price-withNDS - VAT-gds - SLT-gds
                prt-tqnty       = buf_sj-t12.fact-qnty
                prt-VAT-gds     = VAT-gds           * prt-tqnty
                prt-SLT-gds     = SLT-gds           * prt-tqnty
                prt-stoim-noNDS = price-noNDS       * prt-tqnty
                prt-stoim       = prt-stoim-noNDS   + prt-VAT-gds
            .
            if p-round = "round":U
            then do:
                run p-fmt-round in this-procedure (
                      input prt-tqnty
                    , input price-noNDS
                    , input VAT-gds
                    , input SLT-gds
                    , input 0
                    , output price-noNDS
                    , output v-vat-pc
                    , output v-slt-pc
                    , output prt-VAT-gds
                    , output prt-SLT-gds
                    , output v-void-decimal
                    , output prt-stoim-noNDS
                    , output prt-stoim
                ).
                assign
                    prt-stoim  = prt-stoim - prt-SLT-gds
                .
            end.
            accumulate
                prt-tqnty ( TOTAL )
                prt-VAT-gds ( TOTAL )
                prt-SLT-gds ( TOTAL )
                prt-stoim-noNDS ( TOTAL )
                prt-stoim ( TOTAL )
            .
            if PrintScale
            then do:
                /*---S--------- Стоит галочка печати по признакам ----------------*/
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = gds-dtl.prt-code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                assign
                 v-ext-artic = ""
                .
                find first ub.ext-artic no-lock
                     where ub.ext-artic.gds-code = bar-code.gds-code
                       and ub.ext-artic.cli-code = v-cli-code
                       and ub.ext-artic.cli-type = v-cli-type
                       and ub.ext-artic.status_  = {&current-status} no-error.
                if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
                v-prt-name = "".
                do while available gds-prt:
                    if available gds-prt
                    then assign
                        v-prt-name = "\" + string( gds-prt.node-name, "x(10)" ) + v-prt-name
                    .
                    assign
                        v-node-code = gds-prt.upper-code
                    .
                    find first gds-prt no-lock
                         where gds-prt.node-code = v-node-code
                           and gds-prt.root <> yes
                    no-error.
                end.

                if buf_trn-doc.doc-type = {&income}
                or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                then do:
                    assign
                        v-avg-prt-price             = price-withNDS
                        v-avg-prt-price-no-tax      = price-noNDS
                        v-avg-VAT                   = prt-VAT-gds
                        v-avg-prt-sum-with-tax      = prt-stoim
                        v-avg-prt-sum-without-tax   = prt-stoim-noNDS
                    .
                end.
                else do:
                    assign
                        v-avg-VAT-out                 = v-avg-VAT                  * buf_sj-t12.fact-qnty
                        v-avg-prt-sum-with-tax-out    = v-avg-prt-sum-with-tax     * buf_sj-t12.fact-qnty
                        v-avg-prt-sum-without-tax-out = v-avg-prt-sum-without-tax  * buf_sj-t12.fact-qnty
                    .
                end.
                if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                then do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty )
                        , input string( v-avg-prt-price-no-tax + v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                    end.
                end.        /* if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} */
                else do:
                    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input substitute( "&1 &2", goods.artic, v-prt-name )
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                        , input goods.unit-base
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS + prt-VAT-gds )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                    end.
                end.        /* if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} */

                /*---E--------- Стоит галочка печати по признакам ----------------*/
            end.
            /*---E--------- Для каждого признака -----------------------------*/
        end.
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
            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = v-rootnode-code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            assign
             v-ext-artic = ""
            .
            find first ub.ext-artic no-lock
                 where ub.ext-artic.gds-code = bar-code.gds-code
                   and ub.ext-artic.cli-code = v-cli-code
                   and ub.ext-artic.cli-type = v-cli-type
                   and ub.ext-artic.status_  = {&current-status} no-error.
            if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input goods.unit-base
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( stoim-noNDS / tqnty + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        /*---E--------- Если не надо печатать по признакам ---------------*/
        end.
        /*---E--------- Не пустая шкала ----------------------------------*/
    end.
    else do:
        /*---S--------- Пустая шкала -------------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Пустая шкала или отключена печать по шкалам или накладная от имени поставщика").
        find first bar-code no-lock
            where bar-code.gds-code = goods.gds-code
            and bar-code.unit-cli   = goods.unit-base
            and bar-code.node-code  = v-rootnode-code
            and bar-code.part-code  = ""
            and bar-code.in-code    = ""
        .
        assign
         v-ext-artic = ""
        .
        find first ub.ext-artic no-lock
             where ub.ext-artic.gds-code = bar-code.gds-code
               and ub.ext-artic.cli-code = v-cli-code
               and ub.ext-artic.cli-type = v-cli-type
               and ub.ext-artic.status_  = {&current-status} no-error.
        if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
        if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
        and PrintScale = no
        then do:
            /*---S--------- Возврат поставщику: печать по партиям или стеклопосуды ------------*/
            run writelog in this-procedure (log-file-name, 3, "Возврат поставщику при печати по партиям "
/*                                                                        + "или товар со стеклопосудой"*/
                                                ).
            find first gds-dtl no-lock
                 where gds-dtl.doc-code    = p-doc-code
                   and gds-dtl.artic       = buf_sj-t12.artic
                   and gds-dtl.prod-code   = buf_sj-t12.prod-code
                   and gds-dtl.prod-type   = buf_sj-t12.prod-type
                   and gds-dtl.prt-code    = v-rootnode-code
            no-error.
            if available gds-dtl
            and doc-line.price-rubl - doc-line.transport-rubl - doc-line.other-rubl <> gds-dtl.price-rubl
            then do:                                    /*Значит, цену в возврате поставщику изменяли */
                assign                                  /* по заказам - выдаем усредненную цену       */
                    v-price-is-changed  =  yes
                .
                assign
                    v-VAT-gds           = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer             else buf_sj-t12.vat-base-buyer              )
                    v-SLT-gds           = ( if PrintRubl then buf_sj-t12.slt-rubl-sale              else buf_sj-t12.slt-base-sale               )
                    v-price-withNDS     = ( if PrintRubl then buf_sj-t12.price-rubl-with-tax-sale   else buf_sj-t12.price-base-with-tax-sale    )
                .
                run writelog in this-procedure (log-file-name, 4, "В возврате поставщику изменяли цену ( с НДС -     "
                                                                         + dtm-char(string(v-price-withNDS)) + " )"
                                                    ).
            end.
            else do:
                assign                                  /* надо брать учетную цену из партий          */
                    v-price-is-changed  =  no
                .
            end.
/*            for each parts*/
/*               where parts.obj-type     = buf_sj-t12.obj-type*/
/*                 and parts.obj-code     = buf_sj-t12.obj-code*/
/*                 and parts.artic        = goods.artic*/
/*                 and parts.prod-type    = goods.prod-type*/
/*                 and parts.prod-code    = goods.prod-code*/
/*                 and parts.out-code     = p-doc-code*/
/*            :*/
                /*---S--------- Для каждой партии --------------------------------*/
            if v-price-is-changed  =  no
            or CostPrice = yes
            then do:
                assign
                    v-VAT-gds       = ( if PrintRubl then buf_sj-t12.vat-rubl-sale       else buf_sj-t12.vat-base-sale        )
                    v-SLT-gds       = ( if PrintRubl then buf_sj-t12.slt-rubl-sale       else buf_sj-t12.slt-base-sale        )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale  else buf_sj-t12.road-tax-base-sale   )
                    v-price-withNDS = ( if PrintRubl
                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
                                        )
                    v-tax           = v-tax-price * buf_sj-t12.fact-qnty
                    v-tax-sum       = v-tax-sum + v-tax
                .
            end.

            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.

            assign
                tqnty           = buf_sj-t12.fact-qnty
                unit-str        = goods.unit-base
                price-noNDS     = v-price-withNDS - v-VAT-gds - v-SLT-gds
                VAT-gds         = v-VAT-gds * tqnty
                SLT-gds         = v-SLT-gds * tqnty
                stoim-noNDS     = price-noNDS * tqnty
                stoim           = stoim-noNDS + VAT-gds
                price-withNDS   = v-price-withNDS
            .
            run writelog in this-procedure (log-file-name, 5, "Партия: Кол-во ( " + dtm-char ( string(tqnty) )
                                                        + " ) c НДС ( " + dtm-char( string(price-withNDS)) + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            assign
                prt-tqnty =  tqnty
                prt-VAT-gds = VAT-gds
                prt-SLT-gds = SLT-gds
                prt-stoim-noNDS = price-noNDS * prt-tqnty
                prt-stoim = prt-stoim-noNDS + prt-VAT-gds
            .
            if hvrdtax (recid(goods))
            then do:
                /*---S--------- Третий налог выводится отдельной строкой ---------*/
                run tax-name (  input {&road-tax}
                            , output v-tax-name
                            ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                run r-f_t1xl-sheet1-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( tqnty )
                    , input string( v-tax-price )
                    , input string( v-tax )
                ).
                end.
                assign
                    price-withNDS   = v-price-withNDS + v-tax-price
                    price-noNDS     = price-withNDS - v-VAT-gds - v-SLT-gds
                    prt-stoim-noNDS = price-noNDS * tqnty
                    prt-stoim       = prt-stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4, "Еще раз вычислили сумму с НДС ( "
                                                        + dtm-char( string(prt-stoim) )
                                                        + " ) для общего итога"
                                                    ).

                /*---E--------- Третий налог выводится отдельной строкой ---------*/
            end.
            accumulate
                prt-tqnty ( TOTAL )
                prt-VAT-gds ( TOTAL )
                prt-SLT-gds ( TOTAL )
                prt-stoim-noNDS ( TOTAL )
                prt-stoim ( TOTAL )
            .

            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
                /*---E--------- Для каждой партии --------------------------------*/
/*            end.*/
            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
            .
            run writelog in this-procedure (log-file-name, 3,
                                                            "После цикла по партиям: Установили количество ( "
                                                            + dtm-char( string(tqnty) )
                                                            + " ) и сумму ( "
                                                            + dtm-char( string( stoim ) )
                                                            + " ) для общего итога "
                                                ).
            /*---E--------- Возврат поставщику: печать по партиям или стеклопосуды ------------*/
        end.
        else do:
            /*---S--------- Печать не по партиям -----------------------------*/
            find first gds-dtl no-lock
                 where gds-dtl.doc-code    = p-doc-code
                   and gds-dtl.prod-type   = buf_sj-t12.prod-type
                   and gds-dtl.prod-code   = buf_sj-t12.prod-code
                   and gds-dtl.artic       = buf_sj-t12.artic
                   and gds-dtl.prt-code    = v-rootnode-code
            no-error.
            if available gds-dtl
            then do:
                assign
                    tqnty    = buf_sj-t12.fact-qnty
                .
            end.
            else do:
                assign
                    tqnty    = buf_sj-t12.fact-qnty
                .
            end.
            assign
                unit-str = goods.unit-base
            .

            if buf_trn-doc.doc-type = {&income}
            or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            then do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-sale       else buf_sj-t12.vat-base-sale        )
                    SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale       else buf_sj-t12.slt-base-sale        )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale  else buf_sj-t12.road-tax-base-sale   )
                    price-withNDS   = ( if PrintRubl
                                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
                                        )
                    v-tax           = v-tax-price * tqnty
                    v-tax-sum       = v-tax-sum + v-tax
                .
            end.
            else do:
                assign
                    VAT-gds         = ( if PrintRubl then buf_sj-t12.vat-rubl-buyer     else buf_sj-t12.vat-base-buyer      )
                    SLT-gds         = ( if PrintRubl then buf_sj-t12.slt-rubl-sale      else buf_sj-t12.slt-base-sale       )
                    v-tax-price     = ( if PrintRubl then buf_sj-t12.road-tax-rubl-sale else buf_sj-t12.road-tax-base-sale  )
                    price-withNDS   = ( if PrintRubl
                                        then buf_sj-t12.price-rubl-with-tax-sale - v-tax-price
                                        else buf_sj-t12.price-base-with-tax-sale - v-tax-price
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
            run writelog in this-procedure (log-file-name, 3, "Печать не по партиям. Стоимость с НДС ( "
                                                                        + dtm-char( string( stoim ) )
                                                                        + " ). Количество ( "
                                                                        + dtm-char( string( tqnty ) )
                                                                        + " ). Третий налог ( "
                                                                        + dtm-char( string( v-tax ) )
                                                                        + " )"
                                                ).
            if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
            run r-f_t1xl-sheet1-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input substitute( "&1 &2", goods.artic, goods.gds-name )
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( price-noNDS + VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            end.
            if hvrdtax (recid(goods))
            then do:
                /*---S--------- Третий налог выводится отдельными строками ---------*/
                run tax-name (  input {&road-tax}
                             , output v-tax-name
                             ).
                run writelog in this-procedure (log-file-name, 4, "Есть третий налог ( " + dtm-char( v-tax-name )
                                                        + " ) сумма ( " + dtm-char( string( v-tax ) ) + " )"
                                                    ).
                parts-for-tax:
                for each buf_tax_parts
                   where buf_tax_parts.obj-type     = doc-line.obj-type
                     and buf_tax_parts.obj-code     = doc-line.obj-code
                     and buf_tax_parts.artic        = goods.artic
                     and buf_tax_parts.prod-type    = goods.prod-type
                     and buf_tax_parts.prod-code    = goods.prod-code
                     and buf_tax_parts.out-code     = doc-line.doc-code
                break by buf_tax_parts.road-tax-base
                :
                    if first-of (buf_tax_parts.road-tax-base)
                    then do:
                        assign
                            v-parts-tax-qnty    = 0
                            v-tax               = 0
                            v-tax-parts-price   =  ( if PrintRubl
                                                    then buf_tax_parts.road-tax-rubl
                                                    else buf_tax_parts.road-tax-base )
                        .
                    end.
                    assign
                        v-parts-tax-qnty    = v-parts-tax-qnty + buf_tax_parts.fact-qnty
                        v-tax               = v-tax + ( v-tax-parts-price * buf_tax_parts.fact-qnty )
                    .
                    if not last-of (buf_tax_parts.road-tax-base)
                    then do:
                        next parts-for-tax.
                    end.
                    if lookup( "TopAukc":U, p-mode ) = 0 then do: /*Для Бизнес Букета не печатаем*/
                    run r-f_t1xl-sheet1-write-line-data in this-procedure (
                          input 0
                        , input v-tax-name
                        , input "":U
                        , input "":U
                        , input "":U
                        , input "":U
                        , input "":U
                        , input string( v-parts-tax-qnty  )
                        , input string( v-tax-parts-price )
                        , input string( v-tax )
                    ).
                    end.
                end.
                assign
                    v-tax           = v-tax-price * tqnty
                    price-noNDS     = price-noNDS + v-tax-price
                    stoim-noNDS     = price-noNDS * tqnty
                    stoim           = stoim-noNDS + VAT-gds
                    v-line-counter  = v-line-counter + 1
                .
                run writelog in this-procedure (log-file-name, 4,
                                        "Снова вычислили суммы для строки. Сумма с НДС ( "
                                        + dtm-char( string( stoim ) )
                                        + " )"
                                                    ).
            end.

            assign
                v-line-counter     = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
            /*---E--------- Печать не по партиям -----------------------------*/
        end.
        /*---E--------- Пустая шкала -------------------------------------*/
    end.
    /*---E--------- Печать по шкалам или нет -------------------------*/
end.
end procedure. /* print-line-sj */


/*==========================================================================*/
/*
procedure check-diff-doc-line-and-parts :
define input parameter p-doc-line-rowid     as rowid            no-undo.
define input parameter p-rootnode-code      as integer          no-undo.
define output parameter p-price-is-changed  as logical          no-undo.
define output parameter p-VAT-gds           as decimal          no-undo.
define output parameter p-SLT-gds           as decimal          no-undo.
define output parameter p-price-withNDS     as decimal          no-undo.

    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-dtl       for gds-dtl.
do
for buf_doc-line
  , buf_gds-dtl
on error undo, return error
:
    find first buf_doc-line
         where rowid( buf_doc-line ) = p-doc-line-rowid
    .
    find first buf_gds-dtl no-lock
         where buf_gds-dtl.doc-code    = buf_doc-line.doc-code
           and buf_gds-dtl.artic       = buf_doc-line.artic
           and buf_gds-dtl.prod-code   = buf_doc-line.prod-code
           and buf_gds-dtl.prod-type   = buf_doc-line.prod-type
           and buf_gds-dtl.prt-code    = p-rootnode-code
    no-error.
    if available buf_gds-dtl
    and buf_doc-line.price-rubl - buf_doc-line.transport-rubl - buf_doc-line.other-rubl <> buf_gds-dtl.price-rubl
    then do:                                    /*Значит, цену в возврате поставщику изменяли */
        assign                                  /* по заказам - выдаем усредненную цену       */
            p-price-is-changed  =  yes
        .
        { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
        assign
            p-VAT-gds           = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
            p-SLT-gds           = ( if PrintRubl then slt-rubl-sale  else slt-base-sale  )
            p-price-withNDS     = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
        .
        run writelog in this-procedure (
              input log-file-name
            , input 4
            , input substitute( "В во0зврате поставщику изменяли цену ( с НДС - &1 )", p-price-withNDS )
        ).
    end.
    else do:
        assign                                  /* надо брать учетную цену из партий          */
            p-price-is-changed  =  no
        .
    end.
end.
end procedure. /* check-diff-doc-line-and-parts */
*/

/*==========================================================================*/
procedure trdcattr-value :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.
define output parameter p-attr-type     as character        no-undo.
do
on error undo, return error
:
    run gbl/trdcat-v.p (
          input p-doc-code
        , input p-attr-code
        , output p-attr-value
        , output p-attr-type
    ).
end.
end procedure. /* trdcattr-value */

/*==========================================================================*/
procedure disc-mpl :

define input  parameter p-doc-code        as character      no-undo .
define output parameter v-price-sale-all  as decimal        no-undo .

define variable p-main-b-code             as integer        no-undo .
define variable v-fact-order              as decimal        no-undo .
define variable v-doc-num     like ub.price-list.doc-num    no-undo .
define variable v-price-sale  like ub.price-list.price-sale no-undo .
define variable v-road-tax    like ub.price-list.road-tax   no-undo .
define variable v-excise      like ub.price-list.excise     no-undo .

define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_goods       for ub.goods.
define buffer buf_price-doc   for ub.price-doc.


do
on error undo, return error
:


find first buf_trn-doc
     where buf_trn-doc.doc-code = p-doc-code
  no-error.
  if available buf_trn-doc then do:

    for each buf_doc-line
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
       no-lock :

         find first buf_goods
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            no-error.

            if available buf_goods then do:

              { gbl/gdsbcode.i buf_goods.gds-code ? p-main-b-code }

              assign v-fact-order = (if buf_trn-doc.fact-order <> ? then buf_trn-doc.fact-order else 0) .

              { gbl/bcodeprc.i
                buf_trn-doc.obj-type
                buf_trn-doc.obj-code
                p-main-b-code
                0
                v-fact-order
                v-doc-num
                v-price-sale
                v-road-tax
                v-excise
                no-error
              }

              if v-doc-num <> ? then do:
                find first buf_price-doc
                where buf_price-doc.doc-num = v-doc-num no-error.
                if available buf_price-doc then do:
                  if not printRubl then do :
                      assign v-price-sale = v-price-sale / buf_price-doc.base-rate .
                  end.
                end.
                else do:
                    assign v-price-sale = 0.
                end.
              end.
              else do:
                  assign v-price-sale = 0.
              end.

              assign v-price-sale-all = v-price-sale-all + v-price-sale * buf_doc-line.fact-qnty.
           end.
    end.
  end.
end.
end procedure. /* trdcattr-value */

/*==========================================================================*/
procedure get-okei :
define input parameter p-unit-base as character        no-undo.
define output parameter p-okei as character        no-undo.

    define buffer buf_units         for units.
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-income-doc-code C-Win
PROCEDURE find-income-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-in-code         like parts.in-code    no-undo .
define input  parameter p-gds-code        like goods.gds-code   no-undo .
define input  parameter p-part-code       like parts.part-code  no-undo .
define output parameter p-income-doc-code like parts.in-code    no-undo .

define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end. /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME