block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-f_t1.p $
$Archive: rep/r-f_t1.p $

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
define input parameter p-reverse            as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-f_t1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-f_t1.p $":U .
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
{ rep/r-f_t1xl.i    }
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

define variable v-rootnode-code     as integer                          no-undo.

define variable v-line-counter      as integer                          no-undo.
define variable v-doc-line-counter  as integer                          no-undo.
define variable txt-LC              as char                             no-undo.
define variable s1                  as char                             no-undo.
define variable s2                  as char                             no-undo.
define variable s3                  as char                             no-undo.
define variable s4                  as char                             no-undo.
define variable s5                  as char                             no-undo.
define variable s6                  as char                             no-undo.

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

define variable v-SLT-gds           like ot-line.SLT-base               no-undo.
define variable v-price-withNDS     like doc-line.price-base            no-undo.

define variable Pg-tqnty            like doc-line.doc-qnty      init 0  no-undo.
define variable Pg-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
define variable Pg-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
define variable Pg-stoim-noNDS      like doc-line.price-base    init 0  no-undo.
define variable Pg-stoim            like doc-line.price-base    init 0  no-undo.
    define variable PrevPage            as int     init 0   no-undo.

define variable VAT-gds             like ot-line.VAT-base               no-undo.
define variable VAT-gds-total       like ot-line.VAT-base               no-undo.
define variable v-VAT-gds           like ot-line.VAT-base               no-undo.
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
    for each doc-line no-lock
    where doc-line.doc-code = buf_trn-doc.doc-code,
        each goods no-lock
        where goods.artic     = doc-line.artic
          and goods.prod-type = doc-line.prod-type
          and goods.prod-code = doc-line.prod-code
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

    assign
        v-sum-tot-qnty = buf_trn-doc.fact-qnty
    .
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
    define variable v-stoim                 as decimal      no-undo.
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
    v-attr-value = "".

    run gbl/trdcat-v.p (
          input buf_trn-doc.doc-code
        , input {&trdcattr-exp-trans}
        , output v-attr-value
        , output v-attr-type
        ).
    v-exp-trans = decimal (v-attr-value).
    v-attr-value = "".
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_placeAmount}
        , input v-doc-places
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_placeAmount1}
        , input v-doc-places
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_placeAmount2}
        , input v-doc-places + " " + (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_driver}
        , input (v-driver)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_driver}
        , input (v-driver)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-f_automark}
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
    find first clients where clients.obj-code = buf_trn-doc.boss and clients.obj-type = {&prs} no-lock no-error.
    if available clients
    then do:
          for first person where person.psn-code = buf_trn-doc.boss no-lock .
          run r-f_t1xl-write-cell-data in this-procedure (
                input {&r-f_t1xl-h_manFrom}
              , input (substitute("&1 &2 &3 &4", clients.obj-name, person.name1, person.name2, person.phone1))
          ).
          run r-f_t1xl-write-cell-data in this-procedure (
                input {&r-f_t1xl-h_manFrom1}
              , input substitute("/ &1 /", clients.obj-name)
          ).
          run r-f_t1xl-write-cell-data in this-procedure (
                input {&r-f_t1xl-f_manFromDate}
              , input substitute("/ &1 /   &2", clients.obj-name, v-torgconf-vdoc-date)
          ).
          run r-f_t1xl-write-cell-data in this-procedure (
                input {&r-f_t1xl-h_phoneFrom}
              , input if person.phone1 <> ? then person.phone1 else ""
          ).
          run r-f_t1xl-write-cell-data in this-procedure (
                input {&r-f_t1x1-h_manFromPos}
              , input person.position
          ).
      end.
    end.
    else do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-f_manFromDate}
          , input "                                       ," + v-torgconf-vdoc-date
      ).
    end.
    
    /* если внутренние перемещения, то пишем директора */
    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} then do:
        find first shop where shop.obj-code = buf_trn-doc.cli-code.
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-h_manTo}
            , input shop.director
        ).
    end.
    else
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-h_manTo}
            , input v-torgconf-cli-name
        ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_phoneTo}
        , input v-torgconf-cli-phone
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addressTo}
        , input v-torgconf-cli-addres
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_addressFrom}
        , input v-torgconf-self-obj-addres
    ).

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargopack}
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargopack1}
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_EI}
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_EI1}
        , input (if lookup( "TopAukc":U, p-mode ) <> 0 and v-cargo-pack = "" then "палетт"  else v-cargo-pack)
    ).

    /* ноль и пустое значение для масс не выводим*/

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_placeAmount}
        , input v-doc-places
    ).
    if v-cargo-mass-netto <> 0 and v-cargo-mass-brutto <> ?
    then do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massNetto}
          , input string (v-cargo-mass-netto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massNetto1}
          , input string (v-cargo-mass-netto)
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massBruttoNetto}
          , input string (v-cargo-mass-netto) + if v-cargo-mass-brutto <> 0 and
                                                v-cargo-mass-brutto <> ? then " (" + string (v-cargo-mass-brutto) + ")" else ""
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_cargoInfo}
          , input string (v-cargo-mass-netto) + ", " + v-doc-places
      ).
    end.
    else do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_massBruttoNetto}
          , input if v-cargo-mass-brutto <> 0 and v-cargo-mass-brutto <> ? then "                     (" + string (v-cargo-mass-brutto) + ")" else ""
      ).
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_cargoInfo}
          , input "                   , " + v-doc-places
      ).
    end.
    v-stoim = accum total stoim.
    VAT-gds-total = accum total VAT-gds.
    if PrintRubl
    then do:
      { rep/rub-cop.i v-stoim s3 "{&abbr_rub}" "{&abbr_kop}" }
      { rep/rub-cop.i VAT-gds-total s4 "{&abbr_rub}" "{&abbr_kop}" }
      { rep/rub-cop.i v-exp-trans s5 "{&abbr_rub}" "{&abbr_kop}" }
    end.
    else do:
      run r-f_t1xl-write-cell-data in this-procedure (
            input {&r-f_t1xl-h_lableSum}
          , input "Сумма, баз. вал."
      ).
      for first currency where currency.curr-code = v-curr-code no-lock .
        assign
          s3 = trim( substitute( "&1 &2 &3 &4":U
                                ,substring( string( v-stoim , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                                , currency.curr-abbr
                                ,substring( string( v-stoim , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                                , currency.part-abbr
                                )
                    )
          .
        assign
          s4 = trim( substitute( "&1 &2 &3 &4":U
                                ,substring( string( VAT-gds-total , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                                , currency.curr-abbr
                                ,substring( string( VAT-gds-total , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                                , currency.part-abbr
                                )
                    )
          .
        assign
          s5 = trim( substitute( "&1 &2 &3 &4":U
                                ,substring( string( v-exp-trans , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                                , currency.curr-abbr
                                ,substring( string( v-exp-trans , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                                , currency.part-abbr
                                )
                    )
          .
      end.
    end.
    /* расходы, транспортные и НДС */
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_sumStr}
        , input s3 + " (" + s1 + ") " + "в том числе НДС " + if s4 <> "" and s4 <> ? then s4 + (if v-exp-trans <> 0 then " (транспортные расходы " + s5 + ")" else "") else ""
    ).

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_sum}
        , input string( (accum total stoim) + (accum total SLT-gds) )
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-it_sum1}
        , input string( (accum total stoim) + (accum total SLT-gds) )
    ).

    v-loadtplace = p-torgconf-post.

    v-loadtname = p-torgconf-wrkr-name.

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    run r-f_t1xl-close in this-procedure /* (input p-mode)*/.

    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 8}
end.

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
          input {&r-f_t1xl-h_Date}
        , input v-torgconf-vdoc-date
    ).

    assign
        s1 = breakstr( v-torgconf-organization, {&r-f_t1xl-h_orgFrom-length}, input-output s1, input-output s2)
    .

    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_orgFrom}
      , input s1
    ).
    
    /* тут только название, юридический и кажэтся еще и почтовый адрес */
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-h_orgFrom1}
      , input substitute("&1 &2", v-torgconf-self-host-name, v-torgconf-self-host-post-addres)
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
        input {&r-f_t1xl-f_orgNameFrom}
      , input v-torgconf-self-host-name
    ).
    
    define var v-temp-phone as character.
    define var v-temp-addres as character.
    
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


/*    if ( buf_trn-doc.doc-type = {&income}*/
/*    or   buf_trn-doc.doc-type = {&return} )*/
/*    and not invers*/
/*    and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}*/
/*    then do:*/
/*    run r-f_t1xl-write-cell-data in this-procedure (*/
/*          input {&r-f_t1xl-h_from_to_uderline}*/
/*        , input "(организация-грузополучатель, адрес, телефон, факс, банковские реквизиты)"*/
/*    ).*/
/*    end.*/
/*    ELSE DO:*/
/*    run r-f_t1xl-write-cell-data in this-procedure (*/
/*          input {&r-f_t1xl-h_from_to_uderline}*/
/*        , input "(организация-грузоотправитель, адрес, телефон, факс, банковские реквизиты)"*/
/*    ).*/
/*    end.*/

    assign
        s1 = breakstr( v-torgconf-torg12-cargo-value, {&r-f_t1xl-h_orgFrom-length}, input-output s1, input-output s2)
    .
    
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoToValue}
        , input s1
    ).
    
    /* пишем название и адреса */
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-h_cargoToValue1}
        , input substitute("&1 &2", v-torgconf-cli-name, v-torgconf-cli-post-addres)
    ).


/*    if v-torgconf-outrecv = yes*/
/*    then do:*/
/*        run p-fmt-split in this-procedure (*/
/*              input v-torgconf-suppi*/
/*            , input 150*/
/*        ).*/
/*        for each buf_temp_p-fmt_string-part*/
/*        :*/
/*        end.*/
/*    end.*/
/*    else do:*/
/*    end.*/

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
end.
end procedure. /* print-header */

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
    run writelog in this-procedure (
        log-file-name,
        2,
        substitute( "Определили наименование товара ( &1 )", v-gds-name )
                                        ).
    /*---E--------- Определили наименование товара -------------------*/
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        v-rootnode-code = gds-prt.node-code
    .
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
        assign
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
    assign
      v-ext-artic = ""
    .
    find first ub.ext-artic no-lock
          where ub.ext-artic.gds-code = bar-code.gds-code
            and ub.ext-artic.cli-code = v-cli-code
            and ub.ext-artic.cli-type = v-cli-type
            and ub.ext-artic.status_  = {&current-status} no-error.
    if available ub.ext-artic then v-ext-artic = ub.ext-artic.ext-artic.
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