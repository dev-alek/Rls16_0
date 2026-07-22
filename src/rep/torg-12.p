block-level on error undo, throw.
/*

$Revision: c2e03acbfec4, 3152, rls $
$Author: VSpiridonov $
$Date: 2022/12/27 12:54:22 $
$Workfile: torg-12.p $
$Archive: rep/torg-12.p $

Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику

Автор: Демин Алексей Сергеевич
Дата создания: 10/14/08
Author: Alexey Demin
Creation date: 10/14/08

Author1: Victor Guntner
Creation date: 09/15/05

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

define variable vss-revision    as character no-undo init "$Revision: c2e03acbfec4, 3152, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:22 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-12.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику".

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
{ gbl/attr-lib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get '' p-mainmenu-handle }
{ ref/extclass.i }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ rep/torg12xl.i    }
{ str/sj-t12.i      }
{ str/getctxtp.i def}
{ rep/p-fmt.i       }
{ str/mpl-auto.i    }
define variable v-Uvd           as character no-undo.
{str/contattr.i     }
{ gbl/thbjattr.i    }

&scoped-define gds-len 58
&scoped-define gds-len-m 73

define temp-table temp_gds-name no-undo
    field gdn-key   as integer
    field gdnString as character

    index pi is primary unique
        gdn-key
.
define stream out-stream .

function w-date returns character ( input p-date as date ) forward .

define shared variable PrintScale   as logical                          no-undo.
define shared variable CostPrice    as logical                          no-undo.
define shared variable sort-name    as logical                          no-undo.
define shared variable sort-gr      as logical                          no-undo.
define shared variable print-graft  as logical                          no-undo.

    define variable v-torg-12-gds-name-key    as integer      no-undo.
    define variable v-torg-12-gds-name-length as integer      no-undo.

define variable rep-artic           as logical                          no-undo.

define variable tdoc-prt            as logical                          no-undo.

define variable v-rootnode-code     as integer                          no-undo.

define variable v-line-counter      as integer                          no-undo.
define variable v-doc-line-counter  as integer                          no-undo.
define variable txt-LC              as char                             no-undo.
define variable s1                  as char                             no-undo.
define variable s2                  as char                             no-undo.

define variable v-node-code         like    ub.gds-prt.upper-code          no-undo.

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
define variable v-cst-code          as character    no-undo.
define variable v-country-code      as character    no-undo.
define variable v-country           as character    no-undo.

define variable  v-sum-tot-qnty     as decimal                             no-undo.

define variable v-VAT-gds           like ub.ot-line.VAT-base               no-undo.
define variable v-SLT-gds           like ub.ot-line.SLT-base               no-undo.
define variable v-price-withNDS     like ub.doc-line.price-base            no-undo.

define variable Pg-tqnty            like ub.doc-line.doc-qnty      init 0  no-undo.
define variable Pg-VAT-gds          like ub.ot-line.VAT-base       init 0  no-undo.
define variable Pg-SLT-gds          like ub.ot-line.SLT-base       init 0  no-undo.
define variable Pg-stoim-noNDS      like ub.doc-line.price-base    init 0  no-undo.
define variable Pg-stoim            like ub.doc-line.price-base    init 0  no-undo.
define variable PrevPage            as int     init 0   no-undo.

define variable VAT-gds             like ub.ot-line.VAT-base            no-undo.
define variable SLT-gds             like ub.ot-line.SLT-base            no-undo.

define variable v-prt-name          as char                             no-undo.

define variable v-okei              as char                             no-undo.
define variable tb-code             as char                             no-undo.
define variable pack-type           as char                             no-undo.
define variable qnty-opl            like ub.doc-line.doc-qnty           no-undo.
define variable qnty-pl             like ub.doc-line.doc-qnty           no-undo.
define variable mass                as decimal     decimals 10          no-undo.

define variable v-tax-name          as char                             no-undo.
define variable v-tax-price         like ub.doc-line.road-tax      init 0  no-undo.
define variable v-tax               like ub.doc-line.road-tax      init 0  no-undo.
define variable v-tax-sum           like ub.doc-line.road-tax      init 0  no-undo.
define variable v-parts-tax-qnty    like ub.doc-line.doc-qnty      init 0  no-undo.
define variable v-tax-parts-price   like ub.doc-line.road-tax      init 0  no-undo.

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
    /*
define variable sym17               as char     init ":" no-undo.
    */
define variable sym18               as char     init ":" no-undo.
/*define variable sym19               as char     init ":" no-undo.*/
define variable sym20               as char     init ":" no-undo.
define variable sym21               as char     init ":" no-undo.

define variable sym22               as char     init ":" no-undo.

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
define variable v-bcode                     as integer                  no-undo.

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


    define buffer buf_trn-doc           for ub.trn-doc.
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

if lookup( "TOPAUKC":U, p-mode, ";" ) <> 0
then do:
  define variable ix        as integer   no-undo .
  define variable p-t-mode  as character no-undo .
  repeat ix = 1 to num-entries (p-mode, ";") :
    assign
      p-t-mode = p-t-mode + entry (ix, p-mode, ";") + ","
    .
  end.
  assign
    p-mode = right-trim (p-t-mode, ",") .
  .
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

define variable v-param-type as character no-undo .
/*define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-character AS character no-undo .*/
define variable v-tth as handle no-undo .

run adm/shattri.p (
    input "get":U
    ,input  '' /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-prt-glob}
    ,input  {&attr-prt-glob_rep-artic} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-artic
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error or rep-artic = ? then do:
  delete object v-tth no-error.
  define variable v-tooltip as character no-undo .
  define variable v-label as character no-undo .
  define variable v-tooltip-code as character no-undo .
  run thbjattr_tooltip in this-procedure (
                                            input  {&attr-prt-glob}
                                           ,input  {&attr-prt-glob_rep-artic}
                                           ,output v-tooltip
                                           ,output v-label
                                           ,output v-tooltip-code ) no-error.
  if error-status:error then do:
    assign
    v-tooltip-code = {&attr-prt-glob_rep-artic}
    v-tooltip = {&attr-prt-glob}
    .
  end.
  message
  substitute("Не найден или незаполнен параметр:&2&1&2Секция <&3>"
             , v-tooltip-code
             , {&new-line}
             ,v-tooltip)
  view-as alert-box error .
  return .
end.

delete object v-tth no-error.

{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.

assign
    FullGdsName = ( tmp-var = "yes" )
.
/*end.*/

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
&scop gds-len 48
&scop gds-len-m 73
assign
    v-torg-12-gds-name-length       = ( if v-torgconf-outt12 = yes then {&gds-len-m} else {&gds-len} )
.
define frame f-doc
        sym1 column-label ":!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! " format ">>>>9" space(0)
        sym2 column-label ":!:!:" format "X(1)" space(0)
        /*ub.goods.artic COLUMN-LABEL "Артикул! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:" format "X(1)" space(0)*/
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! " format "X({&gds-len})" space(0)
        sym3 column-label ":!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! " format "X(17)" space(0)
        sym4 column-label ":!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм." format "X(4)" space(0)
        sym5 column-label ":!:!:" format "X(1)" space(0)
        v-okei COLUMN-LABEL "Код ед.!изм. по!ОКЕИ" format "X(7)" space(0)
        sym6 column-label ":!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! " format "X(3)" space(0)
        sym7 column-label ":!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-во!в одном!месте" format ">>>>9.<" space(0)
        sym8 column-label ":!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест" format ">>9.<" space(0)
        sym9 column-label ":!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то" format ">>9.<" space(0)
        sym10 column-label ":!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!  НДС! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС %" format ">9.9<" space(0)
        sym14 column-label ":!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС" format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:" format "X(1)" space(0)
        /*
        SLT-gds column-label "Сумма!НП! ! ! " format "->>>,>>9.99" space(0)
        sym17 column-label ":!:!:" format "X(1)" space(0)
        */
        price-withNDS COLUMN-LABEL "Цена!с учетом!  НДС" format "->>>>>>>9.99" space(0)
        sym18 column-label ":!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_trn-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW}  down stream-io.

define frame f-doc-m
        sym1 column-label ":!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! " format ">>>>9" space(0)
        sym2 column-label ":!:!:" format "X(1)" space(0)
        /*ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:" format "X(1)" space(0)*/
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! " format "X({&gds-len-m})" space(0)
        sym3 column-label ":!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! " format "X(17)" space(0)
        sym4 column-label ":!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм." format "X(4)" space(0)
        sym5 column-label ":!:!:" format "X(1)" space(0)
        v-okei COLUMN-LABEL "Код ед.!изм. по!ОКЕИ" format "X(7)" space(0)
        sym6 column-label ":!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! " format "X(3)" space(0)
        sym7 column-label ":!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-во!в одном!месте! " format ">>>>9.<" space(0)
        sym8 column-label ":!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест" format ">>9.<" space(0)
        sym9 column-label ":!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то" format ">>9.<" space(0)
        sym10 column-label ":!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!  НДС! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС %" format ">9.9<" space(0)
        sym14 column-label ":!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС" format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_trn-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

define frame f-doc-m-bb
        sym1 column-label ":!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! " format ">>>>9" space(0)
        sym2 column-label ":!:!:" format "X(1)" space(0)
        /*ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:" format "X(1)" space(0)*/
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! " format "X({&gds-len-m})" space(0)
        sym3 column-label ":!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! " format "X(17)" space(0)
        sym4 column-label ":!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм." format "X(4)" space(0)
        sym5 column-label ":!:!:" format "X(1)" space(0)
        v-okei COLUMN-LABEL "Код ед.!изм. по!ОКЕИ" format "X(7)" space(0)
        sym6 column-label ":!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! " format "X(3)" space(0)
        sym7 column-label ":!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-во!в одном!месте! " format ">>>>9.<" space(0)
        sym8 column-label ":!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест" format ">>9.<" space(0)
        sym9 column-label ":!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то" format ">>9.<" space(0)
        sym10 column-label ":!:!:" format "X(1)" space(0)
        tqnty COLUMN-LABEL "Количество ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:" format "X(1)" space(0)
        price-noNDS COLUMN-LABEL "Цена без!  НДС! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:" format "X(1)" space(0)
        stoim-noNDS COLUMN-LABEL "Сумма без!  НДС! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:" format "X(1)" space(0)
        ub.doc-line.VAT-pc column-label "Став-!ка!НДС %" format ">9.9<" space(0)
        sym14 column-label ":!:!:" format "X(1)" space(0)
        VAT-gds column-label "Сумма!НДС! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:" format "X(1)" space(0)
        stoim column-label "Сумма!с учетом!  НДС" format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:" format "X(1)" space(0)
        v-country COLUMN-LABEL "Страна! ! " format "X(17)" space(0)
        sym20 column-label ":!:!:" format "X(1)" space(0)
        v-cst-code COLUMN-LABEL "Номер!ГТД! " format "X(26)" space(0)
        sym21 column-label ":!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_trn-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    with width 320 down stream-io.

define frame f-doc-bb
        sym1 no-label format "X(1)" space(0)
        v-doc-line-counter no-label format ">>>>9" space(0)
        sym2 no-label format "X(1)" space(0)
        ub.goods.gds-name no-label format "X(30)" space(0)
        sym3 no-label format "X(1)" space(0)
        tb-code no-label format "X(10)" space(0)
        sym4 no-label format "X(1)" space(0)
        ub.goods.unit-base no-label format "X(4)" space(0)
        sym5 no-label format "X(1)" space(0)
        v-okei no-label format "X(7)" space(0)
        sym6 no-label format "X(1)" space(0)
        pack-type no-label format "X(3)" space(0)
        sym7 no-label format "X(1)" space(0)
        qnty-opl no-label format ">>>>>9.<" space(0)
        sym8 no-label format "X(1)" space(0)
        qnty-pl no-label format ">>9.<" space(0)
        sym9 no-label format "X(1)" space(0)
        mass no-label format ">>>>9.<" space(0)
        sym10 no-label format "X(1)" space(0)
        tqnty no-label format "->>>>>9.<<<" space(0)
        sym11 no-label format "X(1)" space(0)
        price-noNDS no-label format "->>>>>9.99" space(0)
        sym12 no-label format "X(1)" space(0)
        stoim-noNDS no-label format "->>,>>>,>>9.99" space(0)
        sym13 no-label format "X(1)" space(0)
        ub.doc-line.VAT-pc no-label format ">>>9.9<" space(0)
        sym14 no-label format "X(1)" space(0)
        VAT-gds no-label format "->>>,>>9.99" space(0)
        sym15 no-label format "X(1)" space(0)
        stoim no-label format "->>>,>>>,>>9.99" space(0)
        sym16 no-label format "X(1)" space(0)
        price-withNDS no-label format "->>>>>>>9.99" space(0)
        sym18 no-label format "X(1)" space(1)
        v-country-code no-label format "X(3)" space(0)
        sym22 no-label format "X(1)" space(0)
        v-country no-label format "X(10)" space(0)
        sym20 no-label format "X(1)" space(0)
        v-cst-code no-label format "X(26)" space(0)
        sym21 no-label format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if buf_trn-doc.status_ <> {&fact} then
                  string( "Статус документа: " + buf_trn-doc.status_ + " " + string( buf_trn-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
            /*fill ( "-", 270)*/
"--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
":    N:Наименование товара           :Код товара:Наим:Код ед.:Вид: Кол-во:Кол-:Масса : Кол-во :  Цена без:     Сумма без: Став-:     Сумма :         Сумма :       Цена :  Страна       :Номер                      " skip
":  п/п:                              :          :ед. :изм. по:уп.:в одном:  во: брут-:        :       НДС:           НДС:    ка:       НДС :       с учетом:    с учетом: Код: Название :ГТД                        " skip
":     :                              :          :изм.:ОКЕИ   :   :  месте:мест:    то:        :          :              : НДС %:           :            НДС:         НДС:    :          :                           " skip
"--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
   with width {&DOS_CW}  down stream-io no-underline no-labels no-box.

    { gbl/working.i }
    os-delete log-file-name.
    run writelog in this-procedure (log-file-name, 0, "&Line").
    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    run torg12xl-init in this-procedure .
    if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        if lookup( "MARI":U, p-mode ) = 0
        then do:
            put stream out-stream
                skip space(10) "Возврат товара поставщику" format "X(120)"
            .
        end.
    end.
    assign
        v-single-line = fill("-", 230)
        v-underline = fill("_", 230)
        v-line-counter = 1
        v-doc-line-counter = 1
    .

    find first ub.currency no-lock
        where ub.currency.curr-code = buf_trn-doc.exch-code
    .
    run print-header in this-procedure (
        input buf_trn-doc.doc-code
    ).

    /*
    if v-torgconf-outt12 = yes
    then do:
        form with frame f-doc-m .
        if sort-gr = yes
        then do:
            down stream out-stream  with frame f-doc-m .
        end.
    end.        /* v-torgconf-outt12 = yes */
    else do:
        form with frame f-doc .
        if sort-gr = yes
        then do:
            down stream out-stream  with frame f-doc .
        end.
    end.        /* NOT ( v-torgconf-outt12 = yes ) */
    */

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
                  , each ub.goods no-lock
                   where ub.goods.gds-code  = sj-t12.gds-code
                break by ub.goods.grp-name
                      by ub.goods.gds-name
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
                        , output v-okei
                    ).
                    if first-of (goods.grp-name)
                    then do:
                        run print-group-line in this-procedure.
                    end.
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
                  , each ub.goods no-lock
                   where ub.goods.gds-code  = sj-t12.gds-code
                break by ub.goods.gds-name
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
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
                  , each ub.goods no-lock
                   where ub.goods.gds-code  = sj-t12.gds-code
                break by ub.goods.grp-name
                      by sj-t12.artic
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
                        , output v-okei
                    ).
                    if first-of (ub.goods.grp-name)
                    then do:
                        run print-group-line in this-procedure.
                    end.
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
                  , each ub.goods no-lock
                   where ub.goods.gds-code  = sj-t12.gds-code
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
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
                for each ub.doc-line no-lock
                where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                    each ub.goods no-lock
                   where ub.goods.artic     = ub.doc-line.artic
                     and ub.goods.prod-type = ub.doc-line.prod-type
                     and ub.goods.prod-code = ub.doc-line.prod-code
                break by ub.goods.grp-name
                    by ub.goods.gds-name
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
                        , output v-okei
                    ).
                    if first-of (ub.goods.grp-name)
                    then do:
                        run print-group-line in this-procedure.
                    end.
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
                for each ub.doc-line no-lock
                where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                    each ub.goods no-lock
                where ub.goods.artic     = doc-line.artic
                    and ub.goods.prod-type = doc-line.prod-type
                    and ub.goods.prod-code = doc-line.prod-code
                break by ub.goods.gds-name
                :
                    run get-okei in this-procedure (
                          input ub.goods.unit-base
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
                  for each ub.doc-line no-lock
                  where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                      each ub.goods no-lock
                  where ub.goods.artic     = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code
                  break by ub.goods.grp-name
                        by ub.doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input ub.goods.unit-base
                          , output v-okei
                      ).
                      if first-of (ub.goods.grp-name)
                      then do:
                          run print-group-line in this-procedure.
                      end.
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
                  for each ub.doc-line no-lock
                  where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                      each ub.goods no-lock
                  where ub.goods.artic     = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code
                  break by ub.goods.grp-name
                        by ub.doc-line.line-num
                  :
                      run get-okei in this-procedure (
                          input goods.unit-base
                          , output v-okei
                      ).
                      if first-of (ub.goods.grp-name)
                      then do:
                          run print-group-line in this-procedure.
                      end.
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
                  for each ub.doc-line no-lock
                  where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                      each ub.goods no-lock
                  where ub.goods.artic     = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code
                  break by ub.doc-line.artic
                  :
                      run get-okei in this-procedure (
                          input ub.goods.unit-base
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
                  for each ub.doc-line no-lock
                  where ub.doc-line.doc-code = buf_trn-doc.doc-code,
                      each ub.goods no-lock
                  where ub.goods.artic     = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code
                  break by ub.doc-line.line-num
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
    if line-counter( out-stream ) + 17 > page-size( out-stream ) then
        do:
            { rep/torg-12.i itog }
            page stream out-stream .
        end.
    hide stream out-stream frame BottomFrame .

    { rep/torg-12.i itog }

    assign
        v-sum-tot-qnty = ( if p-from-check = yes
                           then (accum total tqnty)
                           else buf_trn-doc.fact-qnty )
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
      if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
      then do:
        display stream out-stream
            "Всего по накладной" @ ub.goods.gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
        with frame f-doc-m-bb .
        down stream out-stream with frame f-doc-m-bb .
      end.
      else do:
        display stream out-stream
            "Всего по накладной" @ ub.goods.gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
        with frame f-doc-m .
        down stream out-stream with frame f-doc-m .
      end.
    end.        /* v-torgconf-outt12 = yes */
    else do:
      if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
      then do:
        display stream out-stream
            "Всего по накладной" @ ub.goods.gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
            /*
            (accum total SLT-gds)  @ SLT-gds
            */
        with frame f-doc-bb .
        down stream out-stream with frame f-doc-bb .
      end.
      else do:
        display stream out-stream
            "Всего по накладной" @ ub.goods.gds-name
            v-sum-tot-qnty @ tqnty
            (accum total stoim-noNDS) @ stoim-noNDS
            (accum total VAT-gds)  @ VAT-gds
            (accum total stoim) @ stoim
            /*
            (accum total SLT-gds)  @ SLT-gds
            */
        with frame f-doc .
        down stream out-stream with frame f-doc .
      end.
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
            trim( ( if Invers then currency.curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) ) format "X(7)"
            ")"
    .

    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      run disc-mpl in this-procedure (input buf_trn-doc.doc-code, output v-price-all-mpl ) .
      if v-price-all-mpl > ( accum total stoim ) + (accum total SLT-gds) then do:
        assign v-disc-mpl = v-price-all-mpl - ( accum total stoim ) + (accum total SLT-gds) .
      end.
      else do:
        assign v-disc-mpl = 0.
      end.
    end.
    if v-torgconf-outdisc = no
    then do:
        if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
          put stream out-stream
                              string( ", скидка: "
                                  + ( trim( string( ABS( v-disc-mpl ), ">>>,>>>,>>>,>>>,>>9.99" ) ) )

                                  + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"
                              ) format "X(100)"
          .
        end.
        else do:
          put stream out-stream
                              string( ( if not Invers and ( if PrintRubl then buf_trn-doc.discnt-rubl else buf_trn-doc.tot-calc ) < 0
                                      then ", наценка: "
                                      else ", скидка: " )
                                  + ( if  ( not Invers )
                                      and ( v-ext-doc-type <> {&TDEDT_Pri_Vnesh} )
                                      then trim( string( ABS( ( if PrintRubl
                                                                  then buf_trn-doc.discnt-rubl
                                                                  else buf_trn-doc.tot-calc ) ), ">>>,>>>,>>>,>>>,>>9.99" ) )
                                      else "0.00" )
                                  + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"
                              ) format "X(100)"
          .
        end.
    end.

    if buf_trn-doc.doc-type <> {&income}
    then do:
        put stream out-stream
            skip
            space(15) string( "В том числе: " ) format "X(16)"
            space(3)
        .
        if v-tax-sum <> 0
        then do:
            put stream out-stream
                space(2) v-tax-name + ":" + fill(" ", 1) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"
                                                                                                format "X(160)"
               skip
            .
        end.
    end.
    else do:
        if v-tax-sum <> 0
        then do:
            put stream out-stream
                space(15) "В том числе " + v-tax-name + ":" + fill(" ", 3) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"
                                                                                                format "X(160)"
            .
        end.
        put stream out-stream
            skip
            space(30)
        .
    end.
    put stream out-stream
        string( "НДС: " + trim( string( (accum total VAT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                    " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
    .
    if (accum total SLT-gds) <> 0
    then do:
        put stream out-stream
            skip
            space(19) string( "налог с продаж: " + trim( string( (accum total SLT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                        " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)"
        .
    end.

    define variable v-doc-places    as character    no-undo.
    define variable v-attr-type     as character    no-undo.
    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
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
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-N_warrant_char}
        , input ( p-torgconf-N-warrant)
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-N_ndovwho}
        , input(p-torgconf-ndovwho)
    ).
    if p-torgconf-date-warrant <> ?
    then do:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-Day_warrant}
        , input (DAY(p-torgconf-date-warrant) )
    ).
            run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-Date_warrant}
        , input (substitute("&1&2&3",MonthNameRusGen(MONTH ( p-torgconf-date-warrant )),"  ", YEAR(p-torgconf-date-warrant) ))
    ).
    end.
    if trim(p-torgconf-N-warrant) = ""
    then do:
      assign
         p-torgconf-N-warrant = "_______________________________________":U
         .
    end.
    if p-torgconf-date-warrant <> ?
    then do:
        assign
           month =  MONTH ( p-torgconf-date-warrant )
           p-torgconf-date-char = substitute( "&1&2&3&4&5&6", DAY(p-torgconf-date-warrant), "  ", MonthNameRusGen(month), " ", YEAR(p-torgconf-date-warrant), " года")
        .
    end.
    else do:
        assign
         p-torgconf-date-char = '"___" __________ года'
        .
    end.
    if trim(p-torgconf-ndovwho) = ""
    then do:
        assign
         p-torgconf-ndovwho = string(v-underline, "X(92)").
    end.
    put stream out-stream
        skip
        space(10) string( "Товарная накладная имеет приложение на " + v-underline ) format "X(125)" skip
        space(10) string( "и содержит " + CAPS( txt-LC ) + " порядковый(ых) номер(ов) записей") format "X(140)"
        v-underline format "X(29)" at 151 skip
        string( "Масса груза (нетто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        space(10) string( "Всего мест " + v-doc-places ) format "X(45)"
                string( "Масса груза (брутто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( v-underline, "X(42)" ) + " листах" ) format "X(95)" "|" at 97
            string( "По доверенности N " + string( p-torgconf-N-warrant, "X(39)" ) + " от "/*___" __________ года'*/ + p-torgconf-date-char  ) format "X(100)" at 99 skip
        "(прописью)" AT 66  "|" at 97 string( "выданной " + p-torgconf-ndovwho ) format "X(100)" at 99  skip

        Substitute("Всего отпущено на сумму &1", CAPS(s1)) format "X(95)" "|" at 97  "(кем, кому (организация, место работы, должность, фамилия, и., о.))" at 109  skip
/*         "|" at 97 skip*/
    .
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
    if v-ext-doc-type <> {&TDEDT_Pri_Vnesh}
    then do:
      run torg12xl-write-cell-data in this-procedure (
           input {&torg12xl-f_permitterStatus}
         , input ( if v-torgconf-outsubs = no then v-torgconf-ogr-post else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
           input {&torg12xl-f_permitterName}
         , input ( if v-torgconf-outsubs = no  then v-torgconf-ogr-name else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
           input {&torg12xl-f_buhName}
         , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-accept_position}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-position else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-accept_fname}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-accept-fname else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_post}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_wkr_name}
        , input ( if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
    end.
    else do:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-loadtplace}
        , input (if v-torgconf-outsubs = no  then p-torgconf-post else "":U )
      ).
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-loadtname}
         , input (if v-torgconf-outsubs = no  then p-torgconf-wrkr-name else "":U )
      ).
    end.
       put stream out-stream
        "Отпуск разрешил: "
    .

    if trim(v-torgconf-ogr-post) = "":U
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    or v-torgconf-outsubs = yes
    then do:
        put stream out-stream
            "       ____________            "
        .
    end.
    else do:
        put stream out-stream
        space(6)   string( v-torgconf-ogr-post) format "X(25)"
        .
    end.
    v-loadtplace = p-torgconf-post.
    if trim(v-loadtplace) = ""
    or v-ext-doc-type <> {&TDEDT_Pri_Vnesh}
    or v-torgconf-outsubs <> no
    then do:
      v-loadtplace = "_________________":U.
    end.
    v-loadtname = p-torgconf-wrkr-name.
    if trim(v-loadtname) = ""
    or v-ext-doc-type <> {&TDEDT_Pri_Vnesh}
    or v-torgconf-outsubs <> no
    then do:
        v-loadtname = "________________________":U.
    end.
    if trim(v-torgconf-ogr-name) = ""
    or v-torgconf-outsubs <> no
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      v-torgconf-ogr-name = "________________________":U.
    end.
    if trim(v-torgconf-main-buh) = ""
    or v-torgconf-outsubs <> no
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      v-torgconf-main-buh = "________________________":U.
    end.
    if trim(p-torgconf-accept-position) = ""
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    or v-torgconf-outsubs <> no
    then do:
      p-torgconf-accept-position = "_________________" .
    end.
    if trim(p-torgconf-accept-fname) = ""
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    or v-torgconf-outsubs <> no
    then do:
      p-torgconf-accept-fname = "________________________" .
    end.
    if trim(p-torgconf-wrkr-name) = ""
    or v-torgconf-outsubs <> no
    or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
        p-torgconf-wrkr-name = "________________________" .
    end.
    put stream out-stream
        string( " _________________  " + v-torgconf-ogr-name) format "X(47)" " |":U at 96  v-underline  format "X(101)"/*at 192 */skip
                 "(должность)                  (подпись)       (расшифровка подписи)" at 25 "|" at 97 skip.
    if lookup( "KEDR":U, p-mode ) <> 0
    then do:
        put stream out-stream
                "по приказу №            ____________             _________________  ________________________"   "|" at 97 skip
                "                        (должность)                  (подпись)       (расшифровка подписи))"   "|" at 97 skip
        .
    end.
    put stream out-stream
        string( "Главный бухгалтер:                               _________________  " + v-torgconf-main-buh ) format "X(93)" " |"
        at 96 string( "Груз принял:                   " + string(p-torgconf-accept-position,"X(17)") + "  ___________________ " + string(p-torgconf-accept-fname,"X(24)")) format "X(100)" at 99 skip
                 "                             (подпись)       (расшифровка подписи)" at 25 "|" at 97  "     (должность)       (подпись)        (расшифровка подписи)" at 131 skip.
    if lookup( "KEDR":U, p-mode ) <> 0
    then do:
        put stream out-stream
                "по приказу №            ____________             _________________  ________________________"   "|" at 97 skip
                "                        (должность)                  (подпись)       (расшифровка подписи)"   "|" at 97 skip
        .
    end.
    put stream out-stream

    "Отпуск груза произвел: "
    .
      if trim(p-torgconf-post) = ""
      or v-torgconf-outsubs <> no
      or v-ext-doc-type = {&TDEDT_Pri_Vnesh}
      then do:
        put stream out-stream
            " ____________ " format "X(25)"
        .
      end.
      else do:
        put stream out-stream
            p-torgconf-post format "X(25)"
        .
      end.
    put stream out-stream

        string(  " _________________  " + p-torgconf-wrkr-name ) format "X(48)" "|" at 97  "Груз получил грузополучатель:    " v-loadtplace Format "x(17)" " ___________________ " v-loadtname Format "X(26)"/* format "X(100)"*//* at 99*/ skip
                 "(должность)                  (подпись)       (расшифровка подписи)" at 25 "|" at 97  "     (должность)       (подпись)        (расшифровка подписи)" at 131 skip
/*        " " format "X(95)" "|" at 97 skip*/
        "М.П." at 15  '    "___"___________ ___ года' "|" at 97 "М.П." at 99  '     "___"___________ ___ года' skip
    .
/*    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_permitterStatus}
        , input ( if lookup( "MAG":U, p-mode ) <> 0 then "Ген. директор" else "":U )
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_permitterName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-main-boss else "":U )
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-f_buhName}
        , input ( if v-torgconf-outsubs = no then v-torgconf-main-buh else "":U )
    ).  */
    run torg12xl-close in this-procedure  (input p-mode).

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

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_tax_parts     for ub.parts.
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
        v-gds-name              = (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
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
        if line-counter( out-stream ) + v-torg-12-gds-name-key > page-size( out-stream )
        then do:
            { rep/torg-12.i itog }
            PAGE stream out-stream.
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
                    v-gds-name    = (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
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
    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = ub.goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
    if ( ( gds-prt.node-name <> {&empty-scale} )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    and ( lookup( "TOPAUKC":U, p-mode ) = 0 and lookup( "GTD":U, p-mode ) = 0 )
    then do:
        /*---S--------- Не пустая шкала ----------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first ub.gds-dtl no-lock
            where ub.gds-dtl.prod-type = ub.doc-line.prod-type
              and ub.gds-dtl.prod-code = doc-line.prod-code
              and ub.gds-dtl.artic     = doc-line.artic
              and ub.gds-dtl.doc-code  = doc-line.doc-code
        no-error.
        if not available (gds-dtl)     /*Если новый товар по шкалам еще не разбит, цены пока неизвестны*/
        then assign
            price-noNDS   = 0
            price-withNDS = 0
        .
        if PrintScale
        then do:
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                    with frame f-doc-m .
                down stream out-stream  with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym17*/ sym18 /*sym19*/
                    with frame f-doc .
                down stream out-stream  with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            { rep/torg-12.i no-sum v-torg-12-gds-name-length }
            assign
                v-line-counter = v-line-counter + 1
                v-doc-line-counter = v-doc-line-counter + 1
            .
        end.
        for each ub.gds-dtl no-lock                        /*Средняя цена для всех признаков. Если расход, то печатать ее*/
           where ub.gds-dtl.prod-type  = ub.doc-line.prod-type
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
            find first ub.bar-code no-lock
                 where bar-code.gds-code = ub.goods.gds-code
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
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ goods.gds-name
                    /*goods.artic*/
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    stoim-noNDS / tqnty       @ price-noNDS
                    stoim-noNDS
                    doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                with frame f-doc-m .
                down stream out-stream  with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*goods.artic*/
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    stoim-noNDS / tqnty       @ price-noNDS
                    stoim-noNDS
                    doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    /*
                    SLT-gds when tqnty <> 0
                    */
                    price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                with frame f-doc .
                down stream out-stream  with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(goods.artic) + " ") else "") + goods.gds-name
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input goods.unit-base
                , input v-okei
                , input "-":U
                , input "-":U
                , input "-":U
                , input "-":U
                , input string( tqnty )
                , input string( stoim-noNDS / tqnty )
                , input string( stoim-noNDS )
                , input string( doc-line.VAT-pc )
                , input string( VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            { rep/torg-12.i " " v-torg-12-gds-name-length }
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
        if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or ( lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0 )
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
            for each ub.parts
               where ub.parts.obj-type     = doc-line.obj-type
                 and ub.parts.obj-code     = doc-line.obj-code
                 and ub.parts.artic        = goods.artic
                 and ub.parts.prod-type    = goods.prod-type
                 and ub.parts.prod-code    = goods.prod-code
                 and ub.parts.out-code     = doc-line.doc-code
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
                { rep/torg-12.i prt- v-torg-12-gds-name-length }
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
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                with frame f-doc-m.
                down stream out-stream  with frame f-doc-m.
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    /*
                    SLT-gds when tqnty <> 0
                    */
                    price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                with frame f-doc.
                down stream out-stream  with frame f-doc.
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(goods.artic) + " ") else "") + goods.gds-name
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input v-okei
                , input "-":U
                , input "-":U
                , input "-":U
                , input "-":U
                , input string( tqnty )
                , input string( price-noNDS )
                , input string( stoim-noNDS )
                , input string( doc-line.VAT-pc )
                , input string( VAT-gds )
                , input string( stoim + SLT-gds )
            ).
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
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            fill(" ", 2) + v-tax-name   @ goods.gds-name
                            v-parts-tax-qnty            @ tqnty
                            0                           @ VAT-gds
                            v-tax-parts-price           @ price-noNDS
                            v-tax                       @ stoim-noNDS
                            v-tax                       @ stoim
                            sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m.
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            fill(" ", 2) + v-tax-name   @ goods.gds-name
                            v-parts-tax-qnty            @ tqnty
                            0                           @ VAT-gds
                            /*
                            0                           @ SLT-gds
                            */
                            v-tax-parts-price           @ price-noNDS
                            v-tax                       @ stoim-noNDS
                            v-tax-parts-price           @ price-withNDS
                            v-tax                       @ stoim
                            sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18
                        with frame f-doc.
                        down stream out-stream  with frame f-doc.
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                end.
                run torg12xl-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "-":U
                    , input "-":U
                    , input "-":U
                    , input "-":U
                    , input "-":U
                    , input "-":U
                    , input string( v-parts-tax-qnty )
                    , input string( v-tax-parts-price )
                    , input string( v-tax )
                    , input "":U
                    , input "":U
                    , input string( v-tax )
                ).
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

            { rep/torg-12.i " " v-torg-12-gds-name-length }
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








/*==============================================================*/
/*---S-------- Печать линии группы в документе -----------------*/
procedure print-group-line :
do
on error undo, return error
:
    run writelog in this-procedure (
          input log-file-name
        , input 2
        , input substitute( "Печать имени группы ( &1 )"
                            , dtm-char( ub.goods.grp-name ) )
    ).
    put stream out-stream
        skip
        ":" space(5)
        "Группа:" space(2)
        goods.grp-name
    .
    /*  down stream out-stream  with frame f-doc .*/
end.
end procedure. /* print-group-line */
/*---E-------- Печать линии группы в документе -----------------*/






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

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_parts-attr    for ub.parts-attr.
    define buffer buf_country       for ub.country.
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
        { str/in-vatp.i calc-parts ub.parts. buf_trn-doc. }
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

    if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
        then do:
            find first country where country.alpha1 = goods.alpha1.
            v-cst-code = ( if avail country and country.alpha1 <> "RU"
                then parts.cst-code else "" ).
        end.

    assign
        tqnty           = ub.parts.fact-qnty
        unit-str        = ub.goods.unit-base
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
    if v-torgconf-outt12 = yes
    then do:
        if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
        then do:
          find first ub.country no-lock
            where ub.country.alpha1 = ub.goods.alpha1
            no-error.
          if available ub.country
          then do:
            assign
              v-country = ub.country.short-name
              v-country-code = string(ub.country.num-code).
            .
          end.
          else do:
            assign
              v-country = ""
              v-country-code = ""
            .
          end.
          
          if v-country-code = "0" then v-country-code = "".

          display stream out-stream
              v-doc-line-counter
              /*ub.goods.artic*/
              p-gds-name                  @ ub.goods.gds-name
              if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )   @ tb-code
              unit-str                    @ ub.goods.unit-base
              v-okei
              tqnty
              price-noNDS
              stoim-noNDS
              parts.VAT-pc                @ ub.doc-line.VAT-pc
              VAT-gds when tqnty <> 0
              stoim
              v-cst-code
              v-country-code
              v-country
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/ sym20 sym21
          with frame f-doc-m-bb.
          down stream out-stream  with frame f-doc-m-bb.
        end.
        else do:
          display stream out-stream
              v-doc-line-counter
              /*ub.goods.artic*/
              p-gds-name                  @ ub.goods.gds-name
              if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )   @ tb-code
              unit-str                    @ ub.goods.unit-base
              v-okei
              tqnty
              price-noNDS
              stoim-noNDS
              parts.VAT-pc                @ ub.doc-line.VAT-pc
              VAT-gds when tqnty <> 0
              stoim
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
          with frame f-doc-m.
          down stream out-stream  with frame f-doc-m.
        end.
    end.        /* v-torgconf-outt12 = yes  */
    else do:
        if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
        then do:
          find first ub.country no-lock
            where ub.country.alpha1 = ub.goods.alpha1
            no-error.
            /* скрыть Россию в текстовом отчете */
          if available ub.country AND ub.country.alpha1 <> "RU" 
          then do:
            assign
              v-country = ub.country.short-name
              v-country-code = string(ub.country.num-code)
            .
          end.
          else do:
            assign
              v-country = ""
              v-country-code = ""
            .
          end.

          if v-country-code = "0" then v-country-code = "".

          display stream out-stream
              v-doc-line-counter
              /*ub.goods.artic*/
              p-gds-name                  @ ub.goods.gds-name
              if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )   @ tb-code
              unit-str                    @ ub.goods.unit-base
              v-okei
              tqnty
              price-noNDS
              stoim-noNDS
              ub.parts.VAT-pc             @ ub.doc-line.VAT-pc
              VAT-gds when tqnty <> 0
              stoim
              /*
              SLT-gds when tqnty <> 0
              */
              ( stoim + SLT-gds ) / tqnty               @ price-withNDS
              v-cst-code
              v-country-code
              v-country
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 sym22 /*sym19*/ sym20 sym21
          with frame f-doc-bb.
          down stream out-stream  with frame f-doc-bb.
        end.
        else do:
          display stream out-stream
            v-doc-line-counter
              /*ub.goods.artic*/
              p-gds-name                  @ ub.goods.gds-name
              if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )   @ tb-code
              unit-str                    @ ub.goods.unit-base
              v-okei
              " -":C   @ pack-type
              "  -":C   @ qnty-opl
              " -":C   @ qnty-pl
              " -":C   @ mass
              tqnty
              price-noNDS
              stoim-noNDS
              ub.parts.VAT-pc             @ ub.doc-line.VAT-pc
              VAT-gds when tqnty <> 0
              stoim
              /*
              SLT-gds when tqnty <> 0
              */
              ( stoim + SLT-gds ) / tqnty               @ price-withNDS
              sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
              sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
          with frame f-doc.
          down stream out-stream  with frame f-doc.
        end.
    end.        /* NOT ( v-torgconf-outt12 = yes  ) */
    if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
    then do:
      find first ub.country no-lock
            where ub.country.alpha1 = goods.alpha1
      no-error.
      if available country
      then do:
          assign
              v-country = ub.country.short-name
              v-country-code = string(ub.country.num-code)
          .
      end.
      else do:
          assign
              v-country = ""
              v-country-code = ""
          .
      end.
      
      /* скрыть Россию в Ексель отчете */
      if available country
      and ub.country.alpha1 = "RU":U
      then do:
          assign
              v-country   = "":U
              v-country-code = ""
          .
      end.
      
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = ub.parts.in-code
          and buf_parts-attr.gds-code  = ub.goods.gds-code
          and buf_parts-attr.part-code = ub.parts.part-code
      no-error .
      if available buf_parts-attr
        and buf_parts-attr.country-code <> 0
        then do:
            find first buf_country
            where buf_country.num-code = buf_parts-attr.country-code
            no-error.
            if available buf_country
            and buf_country.num-code <> ub.country.num-code
            and buf_country.short-name <> ""
            then do :
                assign
                    v-country = buf_country.short-name
                    v-country-code = string(buf_country.num-code)
                  .
                if buf_country.alpha1 = "RU":U
                then do :
                    assign
                      v-country   = "":U
                      v-country-code = ""
                    .
                end .
            end.
      end.

      if v-country-code = "0" then v-country-code = "".

      run torg12bbxl-write-line-data in this-procedure (
            input v-doc-line-counter
          , input (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
          , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
          , input unit-str
          , input v-okei
          , input "":U
          , input "":U
          , input "":U
          , input "":U
          , input string( tqnty )
          , input string( price-noNDS )
          , input string( stoim-noNDS )
          , input string( parts.VAT-pc )
          , input string( VAT-gds )
          , input string( VAT-gds )
          , input v-country-code
          , input v-country
          , input v-cst-code
      ).
    end.
    else do:
      run torg12xl-write-line-data in this-procedure (
            input v-doc-line-counter
          , input (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
          , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
          , input unit-str
          , input v-okei
          , input "-":U
          , input "-":U
          , input "-":U
          , input "-":U
          , input string( tqnty )
          , input string( price-noNDS )
          , input string( stoim-noNDS )
          , input string( parts.VAT-pc )
          , input string( VAT-gds )
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
        if v-torgconf-outt12 = yes
        then do:
            display stream out-stream
                fill(" ", 2) + v-tax-name @ ub.goods.gds-name
                "  -":C   @ v-okei
                " -":C   @ pack-type
                "  -":C   @ qnty-opl
                " -":C   @ qnty-pl
                " -":C   @ mass
                tqnty
                0             @ VAT-gds
                p-tax-price   @ price-noNDS
                p-tax         @ stoim-noNDS
                p-tax         @ stoim
                sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16
            with frame f-doc-m.
            down stream out-stream  with frame f-doc-m.
        end.     /* v-torgconf-outt12 = yes */
        else do:
            display stream out-stream
                fill(" ", 2) + v-tax-name @ ub.goods.gds-name
                tqnty
                0             @ VAT-gds
                /*
                0             @ SLT-gds
                */
                p-tax-price   @ price-noNDS
                p-tax         @ stoim-noNDS
                p-tax-price   @ price-withNDS
                p-tax         @ stoim
                sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18
            with frame f-doc.
            down stream out-stream  with frame f-doc.
        end.     /* NOT ( v-torgconf-outt12 = yes ) */
        if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
        then do:
          run torg12xl-write-line-data in this-procedure (
                input 0
              , input v-tax-name
              , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
              , input unit-str
              , input "":U
              , input "":U
              , input "":U
              , input "":U
              , input "":U
              , input string( tqnty )
              , input string( p-tax-price )
              , input string( p-tax )
              , input "":U
              , input "":U
              , input string( p-tax )
              , input "":U
              , input "":U
          ).
        end.
        else do:
          run torg12xl-write-line-data in this-procedure (
                input 0
              , input v-tax-name
              , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
              , input unit-str
              , input "-":U
              , input "-":U
              , input "-":U
              , input "-":U
              , input "-":U
              , input string( tqnty )
              , input string( p-tax-price )
              , input string( p-tax )
              , input "":U
              , input "":U
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

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
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
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code = ub.goods.gds-code
                       and ub.bar-code.unit-cli = ub.goods.unit-base
                       and ub.bar-code.node-code = ub.gds-dtl.prt-code
                       and ub.bar-code.part-code = ""
                       and ub.bar-code.in-code = ""
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
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            prt-tqnty                       @ tqnty
                            p-avg-prt-price-no-tax          @ price-noNDS
                            v-avg-prt-sum-without-tax-out   @ stoim-noNDS
                            buf_doc-line.VAT-pc             @ ub.doc-line.VAT-pc
                            v-avg-VAT-out                   @ VAT-gds
                            v-avg-prt-sum-with-tax-out      @ stoim
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m .
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty                       @ tqnty
                            p-avg-prt-price-no-tax          @ price-noNDS
                            v-avg-prt-sum-without-tax-out   @ stoim-noNDS
                            buf_doc-line.VAT-pc             @ doc-line.VAT-pc
                            v-avg-VAT-out                   @ VAT-gds
                            v-avg-prt-sum-with-tax-out      @ stoim
                            /*
                            prt-SLT-gds when prt-tqnty <> 0 @ SLT-gds
                            */
                            p-avg-prt-price                 @ price-withNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                        with frame f-doc.
                        down stream out-stream  with frame f-doc .
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    run torg12xl-write-line-data in this-procedure (
                          input 0
                        , input (if rep-artic then string(ub.goods.artic) + " " else "") + v-prt-name
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
                        , input ub.goods.unit-base
                        , input v-okei
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input string( prt-tqnty )
                        , input string( p-avg-prt-price-no-tax )
                        , input string( v-avg-prt-sum-without-tax-out )
                        , input string( buf_doc-line.VAT-pc )
                        , input string( v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                end.        /* if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} */
                else do:
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty @ tqnty
                            price-noNDS
                            prt-stoim-noNDS @ stoim-noNDS
                            buf_doc-line.VAT-pc             @ doc-line.VAT-pc
                            prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                            prt-stoim @ stoim
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m .
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty @ tqnty
                            price-noNDS
                            prt-stoim-noNDS @ stoim-noNDS
                            buf_doc-line.VAT-pc             @ ub.doc-line.VAT-pc
                            prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                            prt-stoim @ stoim
                            /*
                            prt-SLT-gds when prt-tqnty <> 0 @ SLT-gds
                            */
                            price-withNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                        with frame f-doc.
                        down stream out-stream  with frame f-doc .
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    run torg12xl-write-line-data in this-procedure (
                          input 0
                        , input (if rep-artic then string(ub.goods.artic) + " " else "") + v-prt-name
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
                        , input ub.goods.unit-base
                        , input v-okei
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS             )
                        , input string( prt-stoim-noNDS         )
                        , input string( buf_doc-line.VAT-pc     )
                        , input string( prt-VAT-gds             )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                end.        /* if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} */

                { rep/torg-12.i prt- }
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

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_clients           for ub.clients .
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

    { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-firm} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
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
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_docCode}
        , input v-torgconf-doc-code
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_tbl_docCode}
        , input v-torgconf-vdoc-code
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_docDate}
        , input v-torgconf-doc-date
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_tbl_docDate}
        , input v-torgconf-vdoc-date
    ).
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
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
    if not buf_trn-doc.print-rubl and not Invers then
        message "Документ печатать в {&abbr_rublyah_allshift} ?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
    else
        assign PrintRubl = yes .
    */
        assign
        val-str = ( if Invers then ub.currency.curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) )
    .
    find first ub.pay-type no-lock
         where ub.pay-type.obj-code = buf_trn-doc.pay-code
    no-error .
    if lookup( "TOPAUKC":U, p-mode ) <> 0
    then do:
      assign
        v-Uvd = Get-contract-attr(
                  buf_trn-doc.Host-code,
                  buf_trn-doc.Contract-code,
                  v-gl-Uvedomlenie)
        v-Uvd = replace (v-Uvd, chr(10), " ")
      .
      if v-Uvd <> ? and v-Uvd <> ""
      then do:
        run torg12xl-write-cell-data in this-procedure (
              input {&torg12xl-h_uvd}
            , input v-Uvd
        ).
        run p-fmt-split in this-procedure (
              input v-Uvd
            , input 110
        ) .
        for each buf_temp_p-fmt_string-part
        :
          put stream out-stream space(30) buf_temp_p-fmt_string-part.string-part format "X(110)" skip .
        end.
      end.
    end.
    if v-torgconf-outappr = yes
    then do:
        put stream out-stream
                 "Унифицированная форма № ТОРГ-12 Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 105
        .
    end.
    put stream out-stream
        space(5) v-single-line          format  "X(19)"     at 180 skip
/*        space(5) "| "                                       at 180*/
/*            {&g___code}                                     at 188*/
/*            "|"                                             at 198 skip*/
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

    if ( buf_trn-doc.doc-type = {&income}
    or   buf_trn-doc.doc-type = {&return} )
    and not invers
    and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
    then do:
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_from_to_uderline}
        , input "(организация-грузополучатель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.
    ELSE DO:
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_from_to_uderline}
        , input "(организация-грузоотправитель, адрес, телефон, факс, банковские реквизиты)"
    ).
    end.

    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input v-torgconf-torg12-cargo-string
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
            if buf_temp_p-fmt_string-part.str-key = 1
            then do:
                put stream out-stream
                    space(5) buf_temp_p-fmt_string-part.string-part     format "X(160)"
                            "по ОКПО"                                   format "X(7)"       at 172
                            "| "                                                            at 180
                            v-torgconf-torg12-cargo-okpo                format "X(16)"
                            "|"                                                             at 198
                    skip
                .
            end.
            else do:
                put stream out-stream
                    space(16) buf_temp_p-fmt_string-part.string-part    format "X(149)"
                            "       "                                   format "X(7)"       at 172
                            "| "                                                            at 180
                            " "                                         format "X(16)"
                            "|"                                                             at 198
                    skip
                .
            end.
        end.
    end.
    else do:
    put stream out-stream
        space(5) (
                    if lookup("TOPAUKC", p-mode) = 0
                        then
                            v-torgconf-torg12-cargo-string
                        else
                            "Грузополучатель: " + v-torgconf-cargo-to-value
                 )      format "X(160)"
                "по ОКПО"          format "X(7)"       at 172
                "| "                                   at 180
                v-torgconf-torg12-cargo-okpo         format "X(16)"
                "|"                                    at 198
        skip
    .
    end.

   if ( buf_trn-doc.doc-type = {&income}
   or buf_trn-doc.doc-type = {&return} )
   and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
   and buf_trn-doc.ext-doc-type <> {&WDEDT_Put_Cli}
   then do:
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input v-torgconf-torg12-cargo-value
    ).
   end.
   else do:
/*    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input substitute( "&1 {&abbr_inn_allshift} &2 {&abbr_kpp_allshift} &3"
                                                      , v-torgconf-consignee
                                                      , v-torgconf-consignee-inn
                                                      , v-torgconf-consignee-kpp
                                                      )
    ). */
       run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_cargoToValue}
        , input ( if lookup("TOPAUKC", p-mode) = 0
             then
                v-torgconf-torg12-cargo-value
             else
                v-torgconf-cargo-to-value
                )
    ).

   end.
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
    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input v-torgconf-suppi
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
            if buf_temp_p-fmt_string-part.str-key = 1
            then do:
                put stream out-stream
                    space(5) string( "Поставщик: " + buf_temp_p-fmt_string-part.string-part)            format "X(160)"
                            "по ОКПО"                                          format "X(7)"   at 172
                            "| "                                                               at 180
                            v-torgconf-supplier-okpo                            format "X(16)"
                            "|"                                                                at 198 skip
                .
            end.
            else do:
                put stream out-stream
                    space(16) buf_temp_p-fmt_string-part.string-part           format "X(149)"
                            "       "                                          format "X(7)"   at 172
                            "| "                                                               at 180
                            " "                                                format "X(16)"
                            "|"                                                                at 198 skip
                .
            end.
        end.
    end.
    else do:
    put stream out-stream
        space(5) string( "Поставщик: " +  v-torgconf-suppi   )      format "X(160)"
                 "по ОКПО"                                          format "X(7)"   at 172
                 "| "                                                               at 180
                 v-torgconf-supplier-okpo                            format "X(16)"
                 "|"                                                                at 198 skip
    .
    end.
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_supplier}
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
    define variable v-num-zak          as character            no-undo .
    define variable v-mag-number       as character            no-undo .
    define variable v-post-number      as character            no-undo .

    define buffer bf_doc-line     for ub.doc-line .
    define buffer bf_parts        for ub.parts .
    define buffer bf_trn-doc      for ub.trn-doc .
    define buffer bf_goods        for ub.goods .
    define buffer buf_contract    for ub.contract .
    define buffer buf_ext-classif for ub.ext-classif.

    define variable v-income-doc-code like ub.parts.in-code no-undo .
    define variable v-torg12-saler as char no-undo.

  /*1) Проверка атрибутов*/
  /* Номер договора */
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-ndog} v-osnov-num-attr v-attr-type no-error }


  run gbl/trdcat-v.p  ( input buf_trn-doc.doc-code
                              , input {&trdcattr-ddog}    /* Дата договора */
                              , output v-osnov-date-attr
                              , output v-attr-type
                       ) .
 run gbl/trdcat-v.p  ( input buf_trn-doc.doc-code       /*Документ-основание. Наименование*/
                              , input {&trdcattr-nosn}
                              , output v-osnov-attr
                              , output v-attr-type
                       ) .
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
                  /* IF v-osnov-num = "":U*/ 
                  IF v-osnov-num = ?
                  THEN DO:
                     ASSIGN
                        v-osnov-num = v-osnov-num-1
                     .
                  END.

                  IF v-osnov-num  <> v-osnov-num-1
                  THEN DO:
                     ASSIGN
                        v-osnov-num   = ""
                        v-osnov-date  = ""
                        v-osnov       = ""
        .
                     LEAVE _single-reason.
                  END.
            END.
         END.
         OTHERWISE DO:

         END.
      END case.
    END.
    ELSE DO:
      CASE buf_trn-doc.doc-type:
        /* WHEN {&income} then  do:
            run gbl/trdcat-v.p  ( input  buf_trn-doc.doc-code
                              , input  {&trdcattr-ndog}
                              , output v-osnov-num
                              , output v-attr-type
                              ) .
            run gbl/trdcat-v.p  ( input buf_trn-doc.doc-code
                              , input {&trdcattr-ddog}
                              , output v-osnov-date
                              , output v-attr-type
                              ) .
    end.*/
         WHEN {&expense} THEN DO:
            _single-reason:
            FOR EACH bf_doc-line
               WHERE bf_doc-line.doc-code = buf_trn-doc.doc-code
               NO-LOCK
               ,
               FIRST bf_goods
               WHERE bf_goods.artic        = bf_doc-line.artic
               and bf_goods.prod-type    = bf_doc-line.prod-type
               and bf_goods.prod-code    = bf_doc-line.prod-code
               NO-LOCK
               ,
               EACH bf_parts
               where bf_parts.obj-type     = bf_doc-line.obj-type
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
                                 v-osnov-num   = ""
                                 v-osnov-date  = ""
                                 v-osnov       = ""
                              .
                              LEAVE _single-reason.
                           END.
                        END.
                     END.
                  END. /* AVAILABLE buf_trn-doc */
                  ELSE DO:
                  ASSIGN
                     v-osnov-num   = ""
                     v-osnov-date  = ""
                     v-osnov       = ""
                  .
                  LEAVE _single-reason.
                  END.
                  run gbl/trdcat-v.p  ( input  bf_trn-doc.doc-code
                                    , input  {&trdcattr-ndog}
                                    , output v-osnov-num-1
                                    , output v-attr-type
                                    ) .
                  IF v-osnov-num = "":U
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
                        v-osnov-num   = ""
                        v-osnov-date  = ""
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

    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      if v-osnov-num > "" and v-osnov-date > "" then do:
        v-osnov = substitute( "&1 &2 от &3"
                              , (if v-osnov = '' then "Договор" else "" )
                              , v-osnov-num
                              , w-date( date( v-osnov-date ) )
                            ).
      end.
      run gbl/trdcat-v.p( input  buf_trn-doc.doc-code
                        , input  {&trdcattr-zakaz-number}
                        , output v-num-zak
                        , output v-attr-type
                        ) .
      &scop proc-name clntattr-value
      {&run_proc_attr-lib}
        ( input v-torgconf-sup-obj-type
         ,input v-torgconf-sup-obj-code
         ,input {&attr-division-code}
         ,output v-mag-number
         ,output v-attr-type
        ).

      for each buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = {&table_clients}
          and buf_ext-classif.classif-name = {&extclass_code_firm_in_ext_client}
          and buf_ext-classif.db-num = -1
          and buf_ext-classif.Key#_One = v-torgconf-self-host-code
          and buf_ext-classif.Key#_Two = v-torgconf-sup-obj-code
          and buf_ext-classif.Key#_Three = 0
          and buf_ext-classif.CharKey_One = ''
          and buf_ext-classif.CharKey_Two = v-torgconf-sup-obj-type
      :
        v-post-number = buf_ext-classif.CharKey_Three.
      end.
    end.

    v-torg12-saler = v-torgconf-saler.
    if lookup("TOPAUKC", p-mode) = 0 then
        do:
            v-torg12-saler =
                v-torg12-saler +
                " {&abbr_inn_allshift} " +
                v-torgconf-saler-inn +
                " {&abbr_kpp_allshift} " +
                v-torgconf-saler-kpp.
        end.

    if v-torgconf-outrecv = yes
    then do:
        run p-fmt-split in this-procedure (
              input string( "Плательщик: " + v-torg12-saler )
            , input 150
        ).
        for each buf_temp_p-fmt_string-part
        :
            if buf_temp_p-fmt_string-part.str-key = 1
            then do:
                put stream out-stream
                    space(5) buf_temp_p-fmt_string-part.string-part            format "X(160)"
                            "по ОКПО"                                          format "X(7)"   at 172
                            "| "                                                               at 180
                            v-torgconf-saler-okpo                              format "X(16)"
                            "|"                                                                at 198 skip
                .
            end.
            else do:
                put stream out-stream
                    space(16) buf_temp_p-fmt_string-part.string-part           format "X(149)"
                            "       "                                          format "X(7)"   at 172
                            "| "                                                               at 180
                            " "                                                format "X(16)"
                            "|"                                                                at 198 skip
                .
            end.
        end.
    end.
    else do:
        put stream out-stream
            space(5) string( "Плательщик: " + v-torg12-saler )        format "X(160)"
                    "по ОКПО"                                           format "X(7)"   at 172
                    "| "                                                                at 180
                    v-torgconf-saler-okpo                               format "X(16)"
                    "|"                                                                 at 198 skip
        .
    end.
    put stream out-stream
        space(5) string( "Основание: " + v-osnov ) format "X(160)"
                        "номер" format "X(5)" at 174 "| " at 180  v-osnov-num FORMAT "x(16)" "|" at 198 skip
    .
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_saler}
        , input v-torg12-saler
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_osn_doc_code}
        , input v-osnov-num
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_osn_doc_date}
        , input v-osnov-date
    ).

    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_reason}
        , input v-osnov
    ).
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_reason_num}
        , input v-osnov-num
    ).
    run torg12xl-write-cell-data in this-procedure (
        input {&torg12xl-h_reason_date}
        , input v-osnov-date
    ).
    if v-num-zak > '' then do:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_number_zak}
          , input v-num-zak
      ).
    end.
    if v-mag-number > '' then do:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_number_mag}
          , input v-mag-number
      ).
    end.
    if v-post-number > '' then do:
      run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_number_post}
          , input v-post-number
      ).
    end.

    if v-torgconf-outprim = yes
    OR ( buf_trn-doc.PS begins "@" )
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "MAG"  */
    else do:
        put stream out-stream
               space(5) string( "Примечание: " + replace( buf_trn-doc.PS, {&new-line}, " " ))   format "X(163)"
        .
    end.        /* NOT ( p-mode = "MAG"  ) */
    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      put stream out-stream
        space(5) substitute( "Номер магазина: &1", v-mag-number )  format "X(130)"
                        "дата" format "X(4)" at 175 "| " at 180 v-osnov-date FORMAT "X(16)" "|" at 198 skip
        space(5) substitute( "Номер поставщика: &1", v-post-number )  format "X(130)"
                        string( "Транспортная накладная " ) format "X(23)" at 147 "номер" format "X(5)" at 174 "| " at 180 v-torgconf-vdoc-code format "X(16)" "|" at 198 skip
        space(5) substitute( "Номер заказа: &1", v-num-zak )  format "X(130)"
                        "дата" format "X(4)" at 175 "| " at 180 v-torgconf-vdoc-date format "X(10)" "|" at 198 skip
        space(64) v-single-line format "X(33)"
      .
    end.
    else do:
      put stream out-stream
                        "дата" format "X(4)" at 175 "| " at 180 v-osnov-date FORMAT "X(16)" "|" at 198 skip
        space(5) "" /* string( "Вид оплаты: " + ( if available pay-type and ( lookup( "MARI":U, p-mode ) = 0 or index( pay-type.obj-name, "озврат":U ) = 0 ) then pay-type.obj-name else "":U ) ) */ format "X(130)"
                        string( "Транспортная накладная " ) format "X(23)" at 147
                        "номер" format "X(5)" at 174 "| " at 180 v-torgconf-vdoc-code format "X(16)" "|" at 198 skip
        space(64) v-single-line format "X(33)"
        space(5) "дата" format "X(4)" at 175 "| " at 180 v-torgconf-vdoc-date format "X(10)" "|" at 198 skip
      .
    end.
    define variable v-operation-type    as character    no-undo.
    assign
        v-operation-type = ( if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                             then ( if lookup( "MARI":U, p-mode ) = 0 and lookup( "KEDR":U, p-mode ) = 0
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
    if lookup( "KEDR":U, p-mode ) = 0 then
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-h_operationType}
        , input v-operation-type
    ).
    if lookup( "TOPAUKC":U, p-mode ) <> 0 then do:
      put stream out-stream
        space(5) "Вид операции"   format "X(12)"    at 167
                 "| "                               at 180
                 v-operation-type format "X(16)"
                 "|"                                at 198 skip
        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                    + string( v-torgconf-doc-code, "X(16)") + " | "
                                    + v-torgconf-doc-date
                                    + " | " + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" space(5) v-single-line format  "X(19)" at 180 skip
        space(64) v-single-line format "X(33)"
      .
    end.
    else do:
      put stream out-stream
        space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                                    + string( v-torgconf-doc-code, "X(16)") + " | "
                                    + v-torgconf-doc-date
                                    + " | " + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)"
        space(5) "Вид операции"   format "X(12)"    at 167
                 "| "                               at 180
                 v-operation-type format "X(16)"
                 "|"                                at 198 skip
        space(64) v-single-line format "X(33)"
        space(5) v-single-line format  "X(19)" at 180
      .
    end.
    /*if can-do( {&expense} , buf_trn-doc.doc-type ) and ( not buf_trn-doc.internal ) and ( buf_trn-doc.pay-code = g#ret-sup-pay ) then*/
    if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        if lookup( "MARI":U, p-mode ) = 0
        then do:
            put stream out-stream
                skip space(10) "Возврат товара поставщику" format "X(120)"
            .
        end.
    end.
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

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_sj-t12        for sj-t12.
    define buffer buf_tax_parts     for ub.parts.
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
        v-gds-name              = (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
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
        if line-counter( out-stream ) + v-torg-12-gds-name-key > page-size( out-stream )
        then do:
            { rep/torg-12.i itog }
            PAGE stream out-stream.
        end.
        assign
            v-gds-name    = (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
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
    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = ub.goods.prt-root
    .
    assign
        v-rootnode-code = ub.gds-prt.node-code
    .
    if ( ( ub.gds-prt.node-name <> {&empty-scale} )
        and v-cntxp-doc-prt = yes )
    and ( not Invers )
    then do:
        /*---S--------- Не пустая шкала ----------------------------------*/
        run writelog in this-procedure (log-file-name, 2, "Не пустая шкала, не отключена печать по шкалам и накладная не от имени поставщика").
        find first ub.gds-dtl no-lock
             where ub.gds-dtl.prod-type = buf_sj-t12.prod-type
               and ub.gds-dtl.prod-code = buf_sj-t12.prod-code
               and ub.gds-dtl.artic     = buf_sj-t12.artic
               and ub.gds-dtl.doc-code  = p-doc-code
        no-error.
        if not available ub.gds-dtl     /*Если новый товар по шкалам еще не разбит, цены пока неизвестны*/
        then do:
            assign
                price-noNDS   = 0
                price-withNDS = 0
            .
        end.
        if PrintScale
        then do:
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name      @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                    with frame f-doc-m .
                down stream out-stream  with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                    with frame f-doc .
                down stream out-stream  with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
            { rep/torg-12.i no-sum v-torg-12-gds-name-length }
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
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code = ub.goods.gds-code
                       and ub.bar-code.unit-cli = ub.goods.unit-base
                       and ub.bar-code.node-code = gds-dtl.prt-code
                       and ub.bar-code.part-code = ""
                       and ub.bar-code.in-code = ""
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
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = v-node-code
                           and ub.gds-prt.root <> yes
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
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty                       @ tqnty
                            v-avg-prt-price-no-tax          @ price-noNDS
                            v-avg-prt-sum-without-tax-out   @ stoim-noNDS
                            buf_sj-t12.VAT-pc               @ ub.doc-line.VAT-pc
                            v-avg-VAT-out                   @ VAT-gds
                            v-avg-prt-sum-with-tax-out      @ stoim
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m .
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty                       @ tqnty
                            v-avg-prt-price-no-tax          @ price-noNDS
                            v-avg-prt-sum-without-tax-out   @ stoim-noNDS
                            buf_sj-t12.VAT-pc               @ ub.doc-line.VAT-pc
                            v-avg-VAT-out                   @ VAT-gds
                            v-avg-prt-sum-with-tax-out      @ stoim
                            /*
                            prt-SLT-gds when prt-tqnty <> 0 @ SLT-gds
                            */
                            v-avg-prt-price                 @ price-withNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                        with frame f-doc.
                        down stream out-stream  with frame f-doc .
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    run torg12xl-write-line-data in this-procedure (
                          input 0
                        , input (if rep-artic then string(ub.goods.artic) + " " else "") + v-prt-name
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
                        , input ub.goods.unit-base
                        , input v-okei
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input string( prt-tqnty )
                        , input string( v-avg-prt-price-no-tax )
                        , input string( v-avg-prt-sum-without-tax-out )
                        , input string( buf_sj-t12.VAT-pc )
                        , input string( v-avg-VAT-out )
                        , input string( v-avg-prt-sum-with-tax-out + prt-SLT-gds )
                    ).
                end.        /* if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} */
                else do:
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty @ tqnty
                            price-noNDS
                            prt-stoim-noNDS @ stoim-noNDS
                            buf_sj-t12.VAT-pc           @ ub.doc-line.VAT-pc
                            prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                            prt-stoim @ stoim
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m .
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            v-prt-name @ ub.goods.gds-name
                            if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                            ub.goods.unit-base
                            v-okei
                            " -":C   @ pack-type
                            "  -":C   @ qnty-opl
                            " -":C   @ qnty-pl
                            " -":C   @ mass
                            prt-tqnty @ tqnty
                            price-noNDS
                            prt-stoim-noNDS @ stoim-noNDS
                            buf_sj-t12.VAT-pc           @ ub.doc-line.VAT-pc
                            prt-VAT-gds when prt-tqnty <> 0 @ VAT-gds
                            prt-stoim @ stoim
                            /*
                            prt-SLT-gds when prt-tqnty <> 0 @ SLT-gds
                            */
                            price-withNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                        with frame f-doc.
                        down stream out-stream  with frame f-doc .
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    run torg12xl-write-line-data in this-procedure (
                          input 0
                        , input (if rep-artic then string(ub.goods.artic) + " " else "") + v-prt-name
                        , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
                        , input ub.goods.unit-base
                        , input v-okei
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input string( prt-tqnty               )
                        , input string( price-noNDS             )
                        , input string( prt-stoim-noNDS         )
                        , input string( buf_sj-t12.VAT-pc       )
                        , input string( prt-VAT-gds             )
                        , input string( prt-stoim + prt-SLT-gds )
                    ).
                end.        /* if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} */

                { rep/torg-12.i prt- }
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
            find first ub.bar-code no-lock
                 where ub.bar-code.gds-code = goods.gds-code
                   and ub.bar-code.unit-cli = goods.unit-base
                   and ub.bar-code.node-code = v-rootnode-code
                   and ub.bar-code.part-code = ""
                   and ub.bar-code.in-code = ""
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
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                    goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    stoim-noNDS / tqnty       @ price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                with frame f-doc-m .
                down stream out-stream  with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    v-gds-name @ ub.goods.gds-name
                    /*ub.goods.artic*/
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code ) @ tb-code
                    ub.goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    stoim-noNDS / tqnty       @ price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    /*
                    SLT-gds when tqnty <> 0
                    */
                    ( stoim + SLT-gds )  / tqnty           @ price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                with frame f-doc .
                down stream out-stream  with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(ub.goods.artic) + " ") else "") + ub.goods.gds-name
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( ub.bar-code.b-code )
                , input goods.unit-base
                , input v-okei
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( tqnty )
                , input string( stoim-noNDS / tqnty )
                , input string( stoim-noNDS )
                , input string( buf_sj-t12.VAT-pc )
                , input string( VAT-gds )
                , input string( stoim + SLT-gds )
            ).
            { rep/torg-12.i " " v-torg-12-gds-name-length }
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
        find first ub.bar-code no-lock
            where ub.bar-code.gds-code = ub.goods.gds-code
            and ub.bar-code.unit-cli   = ub.goods.unit-base
            and ub.bar-code.node-code  = v-rootnode-code
            and ub.bar-code.part-code  = ""
            and ub.bar-code.in-code    = ""
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
            find first ub.gds-dtl no-lock
                 where ub.gds-dtl.doc-code    = p-doc-code
                   and ub.gds-dtl.artic       = buf_sj-t12.artic
                   and ub.gds-dtl.prod-code   = buf_sj-t12.prod-code
                   and ub.gds-dtl.prod-type   = buf_sj-t12.prod-type
                   and ub.gds-dtl.prt-code    = v-rootnode-code
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
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name                  @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )   @ tb-code
                    unit-str                    @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                with frame f-doc-m.
                down stream out-stream  with frame f-doc-m.
            end.        /* v-torgconf-outt12 = yes  */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name                    @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )   @ tb-code
                    unit-str                    @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    /*
                    SLT-gds when tqnty <> 0
                    */
                    ( stoim + SLT-gds ) / tqnty               @ price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                with frame f-doc.
                down stream out-stream  with frame f-doc.
            end.        /* NOT ( v-torgconf-outt12 = yes  ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(goods.artic) + " ") else "") + goods.gds-name
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input v-okei
                , input "-":U
                , input "-":U
                , input "-":U
                , input "-":U
                , input string( tqnty )
                , input string( price-noNDS )
                , input string( stoim-noNDS )
                , input string( buf_sj-t12.VAT-pc )
                , input string( VAT-gds )
                , input string( stoim + SLT-gds )
            ).
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
                if v-torgconf-outt12 = yes
                then do:
                    display stream out-stream
                        fill(" ", 2) + v-tax-name @ goods.gds-name
                        tqnty
                        0             @ VAT-gds
                        v-tax-price   @ price-noNDS
                        v-tax         @ stoim-noNDS
                        v-tax         @ stoim
                        sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16
                    with frame f-doc-m.
                    down stream out-stream  with frame f-doc-m.
                end.     /* v-torgconf-outt12 = yes */
                else do:
                    display stream out-stream
                        fill(" ", 2) + v-tax-name @ goods.gds-name
                        tqnty
                        0             @ VAT-gds
                        /*
                        0             @ SLT-gds
                        */
                        v-tax-price   @ price-noNDS
                        v-tax         @ stoim-noNDS
                        v-tax-price   @ price-withNDS
                        v-tax         @ stoim
                        sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18
                    with frame f-doc.
                    down stream out-stream  with frame f-doc.
                end.     /* NOT ( v-torgconf-outt12 = yes ) */
                run torg12xl-write-line-data in this-procedure (
                      input 0
                    , input v-tax-name
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input string( tqnty )
                    , input string( v-tax-price )
                    , input string( v-tax )
                    , input "":U
                    , input "":U
                    , input string( v-tax )
                ).
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

            { rep/torg-12.i prt- v-torg-12-gds-name-length }
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
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                with frame f-doc-m.
                down stream out-stream  with frame f-doc-m.
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    v-doc-line-counter
                    /*goods.artic*/
                    v-gds-name @ goods.gds-name
                    if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code ) @ tb-code
                    unit-str @ goods.unit-base
                    v-okei
                    " -":C   @ pack-type
                    "  -":C   @ qnty-opl
                    " -":C   @ qnty-pl
                    " -":C   @ mass
                    tqnty
                    price-noNDS
                    stoim-noNDS
                    buf_sj-t12.VAT-pc           @ doc-line.VAT-pc
                    VAT-gds when tqnty <> 0
                    stoim
                    /*
                    SLT-gds when tqnty <> 0
                    */
                    price-withNDS
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18 /*sym19*/
                with frame f-doc.
                down stream out-stream  with frame f-doc.
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
            run torg12xl-write-line-data in this-procedure (
                  input v-doc-line-counter
                , input (if rep-artic then (string(goods.artic) + " ") else "") + goods.gds-name
                , input if lookup( "VNESH_ART":U, p-mode ) <> 0 then v-ext-artic else string( bar-code.b-code )
                , input unit-str
                , input v-okei
                , input "-":U
                , input "-":U
                , input "-":U
                , input "-":U
                , input string( tqnty )
                , input string( price-noNDS )
                , input string( stoim-noNDS )
                , input string( buf_sj-t12.VAT-pc )
                , input string( VAT-gds )
                , input string( stoim + SLT-gds )
            ).
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
                    if v-torgconf-outt12 = yes
                    then do:
                        display stream out-stream
                            fill(" ", 2) + v-tax-name   @ goods.gds-name
                            v-parts-tax-qnty            @ tqnty
                            0                           @ VAT-gds
                            v-tax-parts-price           @ price-noNDS
                            v-tax                       @ stoim-noNDS
                            v-tax                       @ stoim
                            sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16
                        with frame f-doc-m.
                        down stream out-stream  with frame f-doc-m.
                    end.        /* v-torgconf-outt12 = yes */
                    else do:
                        display stream out-stream
                            fill(" ", 2) + v-tax-name   @ goods.gds-name
                            v-parts-tax-qnty            @ tqnty
                            0                           @ VAT-gds
                            /*
                            0                           @ SLT-gds
                            */
                            v-tax-parts-price           @ price-noNDS
                            v-tax                       @ stoim-noNDS
                            v-tax-parts-price           @ price-withNDS
                            v-tax                       @ stoim
                            sym1 sym10 sym11 sym12 sym13 sym14 sym15 sym16 /* sym17 */ sym18
                        with frame f-doc.
                        down stream out-stream  with frame f-doc.
                    end.        /* NOT ( v-torgconf-outt12 = yes ) */
                    run torg12xl-write-line-data in this-procedure (
                          input 0
                        , input v-tax-name
                        , input "":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input "-":U
                        , input string( v-parts-tax-qnty  )
                        , input string( v-tax-parts-price )
                        , input string( v-tax )
                        , input "":U
                        , input "":U
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
            end.

            { rep/torg-12.i " " v-torg-12-gds-name-length }
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
            , input substitute( "В возврате поставщику изменяли цену ( с НДС - &1 )", p-price-withNDS )
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-income-doc-code C-Win
PROCEDURE find-income-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-in-code         like ub.parts.in-code    no-undo .
define input  parameter p-gds-code        like ub.goods.gds-code   no-undo .
define input  parameter p-part-code       like ub.parts.part-code  no-undo .
define output parameter p-income-doc-code like ub.parts.in-code    no-undo .

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

function w-date returns character ( input p-date as date ) .
/* Переводит дату в строку с месяцем прописью  01.01.2005 -> 01 января 2006 г. */
do
on error undo, return error
:
  return ( string( DAY( p-date ) ) + " " + MonthNameRusGen( month( p-date ) ) + " " + string( year( p-date ) ) + " г." ).

end.
end function. /* w-date */