block-level on error undo, throw.
/*

$Revision: c93cbc1375c4, 1081, rls $
$Author: SMMolotkov $
$Date: Thu Oct 12 16:32:18 2017 +0300 $
$Workfile: wthfct.p $
$Archive: rep/wthfct.p $

Печать счета-фактуры.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:
    rec_id      - recid документа wth-doc
    p-ovr       - печать переоценки учетной цены
    invers      - для поставщика
    p-mode      - SYSKEY
    p-round     - округлять
    p-no-slt    - без НП

*/



&scoped-define gds-len 45
&scoped-define footer-tab-stop1 40

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter invers           as logical              no-undo.
define input parameter p-mode           as character            no-undo.
define input parameter p-round          as character            no-undo.   /* 'round' включает округление */
define input parameter p-reverse            as logical          no-undo .  /* Меняем местами грузополучателя и плательщика */

define variable vss-revision    as character no-undo initial "$Revision: c93cbc1375c4, 1081, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Oct 12 16:32:18 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: wthfct.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/wthfct.p $":U .
define variable vss-description as character no-undo initial "Печать счета-фактуры.":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i       }
{ rep/p-fmt.i        }
{ cmp/breakstr.i     }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ rep/fmtcli.i       }
{ str/trdcalib.i     }
{ rep/torgconf.i     }
{ str/wthgds.i       }
{ str/wthcalib.i     }
{ gbl/thbjattr.i     }


define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ rep/tmp-tab.i      }
{ gbl/paramls.i      }
{ rep/facturxl.i     }

define stream Out-stream .

define shared variable PrintScale   as logical              no-undo.
define shared variable CostPrice    as logical              no-undo.
define shared variable sort-name    as logical              no-undo.
define shared variable sort-gr      as logical              no-undo.

define variable rep-artic           as logical              no-undo.

define variable tdoc-prt                as logical              no-undo.
define variable PrevPage                as integer     init 0   no-undo.

define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.
define variable rootnode_code           as integer              no-undo.

define variable v-lines-counter         as integer              no-undo.
define variable v-node-code             like ub.gds-prt.upper-code no-undo.
define variable v-curr-abbr             as character      no-undo.

define variable v-qnty                  as decimal              no-undo.
define variable v-price                 as decimal              no-undo.
define variable v-price-no-VAT          as decimal              no-undo.
define variable v-sum                   as decimal              no-undo.
define variable v-sum-no-VAT            as decimal              no-undo.
define variable v-sum-actciz            as decimal              no-undo.
define variable v-VAT                   as decimal              no-undo.
define variable v-SLT                   as decimal              no-undo.

define variable v-void-decimal          as decimal              no-undo.
define variable v-sum-VAT               as decimal              no-undo.
define variable v-sum-SLT               as decimal              no-undo.
define variable v-sum-tax               as decimal              no-undo.

define variable v-parts-price           as decimal              no-undo.
define variable v-parts-price-no-VAT    as decimal              no-undo.
define variable v-parts-sum             as decimal              no-undo.
define variable v-parts-sum-no-VAT      as decimal              no-undo.
define variable v-parts-sum-actciz      as decimal              no-undo.
define variable v-parts-VAT             as decimal              no-undo.
define variable v-parts-SLT             as decimal              no-undo.

define variable v-tot-sum               as decimal              no-undo.
define variable v-tot-VAT               as decimal              no-undo.
define variable v-tot-SLT               as decimal              no-undo.
define variable v-tot-sum-no-VAT        as decimal              no-undo.

define variable v-prt-qnty              as decimal              no-undo.
define variable v-prt-VAT               as decimal              no-undo.
define variable v-prt-SLT               as decimal              no-undo.
define variable v-prt-sum-no-VAT        as decimal              no-undo.
define variable v-prt-sum               as decimal              no-undo.

define variable v-tot-prt-qnty          as decimal              no-undo.
define variable v-tot-prt-VAT           as decimal              no-undo.
define variable v-tot-prt-SLT           as decimal              no-undo.
define variable v-tot-prt-sum-no-VAT    as decimal              no-undo.
define variable v-tot-prt-sum           as decimal              no-undo.

/*define variable Pg-tqnty                as decimal     init 0   no-undo.*/
/*define variable Pg-Vat-gds              as decimal     init 0   no-undo.*/
/*define variable Pg-SLT-gds              as decimal     init 0   no-undo.*/
/*define variable Pg-stoim-noNDS          as decimal     init 0   no-undo.*/
/*define variable Pg-stoim                as decimal     init 0   no-undo.*/

define variable sym1 as char init ":" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
define variable sym5 as char init ":" no-undo.
define variable sym6 as char init ":" no-undo.
define variable sym7 as char init ":" no-undo.
define variable sym8 as char init ":" no-undo.
define variable sym9 as char init ":" no-undo.
define variable sym10 as char init ":" no-undo.
define variable sym11 as char init ":" no-undo.
define variable sym12 as char init ":" no-undo.
define variable sym13 as char init ":" no-undo.
define variable sym14 as char init ":" no-undo.
define variable sym15 as char init ":" no-undo.

define variable v-prt-name       as character            no-undo.
define variable v-country        as character            no-undo.
define variable v-GTD            as character            no-undo.
define variable v-single-line    as character            no-undo.
define variable v-propis         as character            no-undo.
define variable v-propis-cop     as character            no-undo.
define variable v-VAT-prc        as decimal              no-undo .

define variable v-unit-code     as character            no-undo.
define variable v-country-code  as character            no-undo.
define variable v-host-code     as integer              no-undo.
define variable v-curr-code     as integer              no-undo.
define variable v-is-return     as logical  init no     no-undo.

define variable v-tax-name      as char                         no-undo.
define variable v-tax-price     as decimal      init 0          no-undo.
define variable v-tax           as decimal      init 0          no-undo.
define variable v-tot-tax       as decimal      init 0          no-undo.
define variable v-wthfct-is-vozvrat-vnesh  as logical      no-undo.
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo .


define buffer buf_wth-doc       for ub.wth-doc.
define buffer buf_our_clients   for ub.clients.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
define buffer buf_sysconf       for ub.sysconf.
define buffer buf_parts-root    for ub.parts-root.
define buffer buf_goods         for ub.goods.
define buffer buf_parts         for ub.parts.

define frame factur
        sym1               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        goods.gds-name     column-label "Наименование товара (описание выполненных!работ, оказанных услуг),!имущественного права! ! ":C45 format "X(45)" space(0)
        sym2               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-unit-code        column-label "   Е!  из!----! !код ! " format "X(3)" space(0)
        sym14              column-label "д!м!-!:!:!:" format "X(1)" space(0)
        goods.unit-base    column-label "иница   !ерения  !--------!условное!обозна- ! чение  ":C8 format "X(8)" space(0)
        sym3               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-qnty             column-label "Количество! ! ! " format ">>>>>>9.<<<" space(0)
        sym4               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-price-no-VAT     column-label "Цена (тариф)!за ед.изм.! ! ":C12 format "->>>>>>>9.99" space(0)
        sym5               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-no-VAT       column-label "Стоимость товаров!(работ, услуг),!имуществ. прав!всего без налога! ":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-actciz       column-label "в т.ч.!акциз! ! ":C10 format ">>>>>>9.99" space(0)
        sym7               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        doc-line.Vat-pc    column-label "Ставка!налога! ! ":C6 format ">9.9<%" space(0)
        sym8               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-VAT              column-label "Сумма!налога! ! ":C12 format "->>>>>>>9.99" space(0)
        sym9               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum              column-label "Ст-ть товаров!(работ, услуг),!имуществ. прав!с учетом налога! ":c15 format "->>>>>>>>>>9.99" space(0)
/*        sym10 column-label ":!:!:!:" format "X(1)" space(0)*/
/*        v-SLT column-label "Сумма!НП":C12 format "->>>>>>>9.99" space(0)*/
        sym11              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-country-code     column-label "     С!  прои!------!цифро-! вой  ! код  " format "x(6)" space(0)
        sym15              column-label "т!с!-!:!:!:" format "X(1)" space(0)
        v-country          column-label "рана      !хождения !----------! краткое  !наименова-!   ние    " format "X(10)" space(0)
        sym12              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-GTD              column-label "Номер таможенной!декларации! ! ":C30 format "X(30)" space(0)
        sym13              column-label ":!:!:!:!:!:" format "X(1)" space(0)
header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U  )                                                      at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X({&A4_LS})" at 1
with width {&DOS_CW} down stream-io.

do
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
{ gbl/getcntxt.i get " " p-mainmenu-handle }
{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_wth-doc no-lock
     where buf_wth-doc.doc-code = p-doc-code
.
if buf_wth-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
then do:
    assign
        v-wthfct-is-vozvrat-vnesh = yes
    .
end.
else do:
    assign
        v-wthfct-is-vozvrat-vnesh = yes
    .
end.
{ gbl/hostcode.i
    buf_wth-doc.obj-type
    buf_wth-doc.obj-code
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
assign
    v-torgconf-ext-doc-type = buf_wth-doc.ext-doc-type
.
run torgconf-read in this-procedure (
      input "wthfct"
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
run torgconf-get-wthrecepient-param (
    input buf_wth-doc.doc-code
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

define variable v-param-type as character no-undo .
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

assign
    v-single-line   = fill("-", 220)
    v-lines-counter = 1
.

{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

run facturxl-init in this-procedure .

run print-header in this-procedure (
      input buf_wth-doc.doc-code
    , output v-curr-abbr
).
form header
    v-single-line format "X({&A4_LS})" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-stream frame Bottomframe .

form with frame factur .


for each temp_wthgds_price-group
:
    run print-line in this-procedure (
          input temp_wthgds_price-group.gds-code
        , input temp_wthgds_price-group.price-rubl
        , input temp_wthgds_price-group.vat-pc
    ).
end.

run print-footer in this-procedure (
      input buf_wth-doc.doc-code
    , input v-curr-abbr
).
run facturxl-close in this-procedure .

hide stream Out-stream frame Bottomframe .
output stream Out-stream close.

{ gbl/stopwork.i }
def var Log-Res as logical no-undo .
{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_waybills-to-file_print':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    Log-Res
}
if Log-Res
then do:
    { rep/q-print.i 8}
end.
else do:
    { rep/q-print.i 0}
end.

end.

/*===============================================================================================*/
procedure print-more:
do
on error undo, return error
:
    define variable v-start-string  as character        no-undo.
    define variable v-add-string    as character        no-undo.
    assign
        v-start-string = gds-str2
    .

    do while trim(v-start-string) <> "" :
        assign gds-str = v-start-string.
        v-add-string = breakstr(gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string).
        display stream Out-stream
            sym1 (fill(" ",17) + v-add-string) @ buf_goods.gds-name
            sym14 sym2 sym3 sym4 sym5 sym6 sym7 sym8
            sym9 /*sym10*/ sym11 sym15 sym12 sym13
            with frame factur .
        down stream Out-stream 1 with frame factur .
    end. /* DO WHILE ... */
end.
end procedure.

/*==========================================================================*/
procedure print-line :
define input parameter p-gds-code   as integer          no-undo.
define input parameter p-price-rubl as decimal          no-undo.
define input parameter p-vat-pc     as decimal          no-undo.

    define buffer buf_temp_wthgds_price-group       for temp_wthgds_price-group.
    define buffer buf_country                       for ub.country.
    define buffer buf_units                         for ub.units.
do
for buf_temp_wthgds_price-group
  , buf_country
  , buf_units
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
    find first buf_country no-lock
         where buf_country.alpha1 = buf_goods.alpha1
    no-error.
    if available buf_country
    then do:
        assign
            v-country-code = " " + string(country.num-code)
            v-country = buf_country.short-name
        .
    end.
    else do:
        assign
            v-country-code = ""
            v-country = ""
        .
    end.
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    v-unit-code = (if units.OKEI = 0 then "-" else string(units.OKEI)) .
    if ( buf_units.type = "{&bef-divisional},{&bef-twounit}"
    or buf_units.type = "{&bef-divisional},{&bef-altunit}" )
    then do:
        assign
            str =  (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "")  + string(buf_goods.Sort,"x(5)") + " " + trim(buf_goods.gds-name)
                                                                                 + " " + trim(buf_goods.PS)
        .
    end.
    else do:
        assign
            str = (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "")  + trim(buf_goods.gds-name)
        .
    end.
    assign
        Gds-str1 = breakstr(str, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
    do while trim(gds-str2) <> "" :
        assign
            gds-str = gds-str2
            gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2)
        .
    end.
    assign
        gds-str1 = breakstr(str, {&gds-len}, input-output gds-str1, input-output gds-str2).
    .
    assign
        v-qnty = buf_temp_wthgds_price-group.qnty
        v-VAT  = ( if PrintRubl
                   then buf_temp_wthgds_price-group.sum-vat-rubl
                   else buf_temp_wthgds_price-group.sum-vat-base ) / buf_temp_wthgds_price-group.qnty
    .
    assign
        v-price-no-VAT = ( if PrintRubl
                            then buf_temp_wthgds_price-group.price-rubl
                            else buf_temp_wthgds_price-group.price-base ) - v-VAT
    .
    /*---E---------------------- Обычный счет-фактура --------------------*/
    if p-round = 'round':U
    then do:
        define variable v-void-decimal    as decimal      no-undo.
        run p-fmt-round in this-procedure (
              input v-qnty
            , input v-price-no-VAT
            , input v-VAT
            , input 0.0       /* SLT */
            , input 0.0       /* road-tax */
            , output v-price-no-VAT
            , output v-void-decimal
            , output v-void-decimal
            , output v-VAT
            , output v-void-decimal
            , output v-void-decimal
            , output v-sum-no-VAT
            , output v-void-decimal
        ).
        assign
            v-sum               = v-sum-no-VAT + v-VAT
        .
    end.        /* p-round = 'round':U */
    else do:
        assign
            v-VAT           = v-VAT * v-qnty
            v-SLT           = v-SLT * v-qnty
            v-sum-no-VAT    = v-price-no-VAT * v-qnty
            v-tax           = 0.0
            v-sum           = v-sum-no-VAT + v-VAT
        .
    end.        /* NOT ( p-round = 'round':U ) */
    display stream Out-stream
        sym1 gds-str1 @ buf_goods.gds-name
        sym2 v-unit-code
        sym14 buf_goods.unit-base @ buf_goods.unit-base
        sym3 v-qnty
        sym4 v-price-no-VAT
        sym5 v-sum-no-VAT
        sym6 "без акциза" format "x(6)" @ v-sum-actciz
        sym7 p-vat-pc @ v-VAT-prc
        sym8 v-VAT
        sym9 v-sum
/*                  sym10 v-SLT*/
        sym11 v-country-code
        sym15 v-country
        sym12
        sym13
    with frame factur .
    down stream Out-stream 1 with frame factur .
    run facturxl-write-line-data in this-procedure (
          input gds-str1        /*  p-Name     */
        , input "  -   ":U            /*  p-UAES     */
        , input v-unit-code                       /*  p-OKEI     */
        , input ( if invers then ub.doc-line.unit-cli else buf_goods.unit-base )        /*  p-EI       */
        , input string( v-qnty              )     /*  p-qnty     */
        , input string( v-price-no-VAT      )     /*  p-price    */
        , input string( v-sum-no-VAT        )     /*  p-SumNoVAT */
        , input "без акциза":U                        /*  p-SumActciz*/
        , input string( p-vat-pc            )     /*  p-VATpc    */
        , input string( v-VAT               )     /*  p-VATsum   */
        , input string( v-sum               )     /*  p-sum      */
        , input v-country-code                    /*  p-countrycode  */
        , input v-country                         /*  p-country  */
        , input "":U                              /*  p-GTD      */
    ).
    run print-more in this-procedure.
    assign v-lines-counter = v-lines-counter + 1.
    assign
        v-tot-sum-no-VAT    = v-tot-sum-no-VAT  + v-sum-no-VAT  + v-tax
        v-tot-VAT           = v-tot-VAT         + v-VAT
        v-tot-SLT           = v-tot-SLT         + v-SLT
        v-tot-tax           = v-tot-tax         + v-tax
        v-tot-sum           = v-tot-sum         + v-sum         + v-tax
    .
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-header :
define input parameter p-doc-code           as character    no-undo.
define output parameter p-curr-abbr         as character    no-undo.

    define variable v-print-doc      as character           no-undo.
    define variable v-par-type       as character           no-undo.
    define variable t-num            as character           no-undo.
    define variable v-obj-prt-on     as logical             no-undo.
    define variable t-inn            as character           no-undo.
    define variable v-plat-rasch-doc as character           no-undo.
    define variable v-attr-type      as character    no-undo.

    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_currency      for ub.currency.
    define buffer buf_shop          for ub.shop.
do
for buf_wth-doc
  , buf_currency
  , buf_shop
on error undo, return error
:
    find first buf_wth-doc no-lock
         where buf_wth-doc.doc-code = p-doc-code
    .
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_wth-doc.doc-code
        , input yes
        , input buf_wth-doc.doc-date
        , input buf_wth-doc.fact-date
        , input buf_wth-doc.doc-type
        , input buf_wth-doc.status_
        , input p-reverse
        , input no
    ).
    find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        p-curr-abbr = buf_currency.curr-abbr + ", код " + string(buf_currency.okv-code)
    .
    assign
        t-num = substitute( "&1         от &2 &3"
                        , v-torgconf-doc-code
                        , v-torgconf-doc-date
                        , ( if buf_wth-doc.status_ <> {&fact}
                            then string( "(" + caps( buf_wth-doc.status_ ) + ")" )
                            else "":U )
                )
    .
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-supplier-inn, ( if v-torgconf-supplier-kpp = "":U then "":U else "/":U ), v-torgconf-supplier-kpp )
    .
    assign
        v-torgconf-cargo-from-name = v-torgconf-cargo-from-name
                                         + "  "
                                         + ( if invers
                                             or ( v-torgconf-outobj = no
                                                and ( not invers ) )
                                            then v-torgconf-cargo-from-addres
                                            else v-torgconf-self-obj-addres )
    .
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
                    assign
                        v-torgconf-cargo-from-name = substitute( "&1&2, &3"
                                                            , v-torgconf-self-obj-name
                                                            , ( if v-torgconf-outprncd = yes
                                                                then substitute( " (&1 &2)", v-torgconf-self-obj-type, v-torgconf-self-obj-code )
                                                                else "":U )
                                                            , buf_shop.addres1 )
                    .
                end.        /* when {&expense} */
                when {&income}
                or when {&return}
                then do:
                    assign
                        v-torgconf-cargo-to-value = substitute( "&1&2, &3"
                                                , v-torgconf-self-obj-name
                                                , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1 &2)", v-torgconf-self-obj-type, v-torgconf-self-obj-code )
                                                    else "":U )
                                                , buf_shop.addres1 )
                    .
                end.        /* when {&income} */
            end case.       /* case buf_wth-doc.doc-type */
        end.
    end.
    put stream Out-stream
         space(108) "                                                                           Приложение № 1" skip
          space(108) "                                                            к постановлению Правительства" skip
          space(108) "                                                                     Российской Федерации" skip
          space(108) "                                                                    от 26.12.2011 № 1137," skip
      .

    put stream Out-stream
        space(25) string( "СЧЕТ-ФАКТУРА N" + ( if p-round = 'round':U then ":" else " " ) + t-num ) format "X(190)" skip
        space(23) 'ИСПРАВЛЕНИЕ N   -   от " - "    -   '
        skip(1) space(5) string( "Продавец" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 31 ) + v-torgconf-supplier-name ) format "X(190)"
        skip    space(5) string( "Адрес"    + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-supplier-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + ( if p-round = 'round':U then ":" else " " ) + t-inn ) format "X(190)"
          .
     /* вывод на экран грузоотправителя*/
   if ( buf_wth-doc.doc-type = {&income}
   or buf_wth-doc.doc-type = {&return} )
      then do:
         run facturxl-write-cell-data in this-procedure (
            input {&facturxl-h_cargoFrom}
          , input ( v-torgconf-torg12-cargo-value )
         ).

         if LENGTH(v-torgconf-torg12-cargo-value) > 145
            then do:
               put stream Out-stream
        skip    space(5) string( "Грузоотправитель и его адрес"
                                + ( if p-round = 'round':U then ":" else " " )
                                + fill( " ", 11 )
                                       + ( SUBSTRING(v-torgconf-torg12-cargo-value,1,145))) format "X(190)"
                  skip    space(45) SUBSTRING(v-torgconf-torg12-cargo-value,146) format "X(145)" skip
               .
            end.
            else do:
               put stream Out-stream
                  skip    space(5) string( "Грузоотправитель и его адрес"
                                          + ( if p-round = 'round':U then ":" else " " )
                                          + fill( " ", 11 )
                                          + ( v-torgconf-torg12-cargo-value)) format "X(190)" skip
               .
            end.
      end.
      else do:
         run facturxl-write-cell-data in this-procedure (
            input {&facturxl-h_cargoFrom}
          , input ( v-torgconf-organization )
         ).

         if LENGTH(v-torgconf-organization) > 145
            then do:
               put stream Out-stream
                  skip    space(5) string( "Грузоотправитель и его адрес"
                                       + ( if p-round = 'round':U then ":" else " " )
                                       + fill( " ", 11 )
                                       + (SUBSTRING(v-torgconf-organization,1,145))) format "X(190)"
                  skip    space(45) SUBSTRING(v-torgconf-organization,146) format "X(145)" skip
               .
            end.
            else do:
               put stream Out-stream
                  skip    space(5) string( "Грузоотправитель и его адрес"
                                       + ( if p-round = 'round':U then ":" else " " )
                                       + fill( " ", 11 )
                                       + (v-torgconf-organization)) format "X(190)" skip
    .
            end.
      end.

    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_docCode}
        , input v-torgconf-doc-code
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_docDate}
        , input v-torgconf-doc-date
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_supplier}
        , input v-torgconf-supplier-name
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_supplierAddr}
        , input v-torgconf-supplier-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_supplierINN}
        , input t-inn
    ).
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-saler-inn, ( if v-torgconf-saler-kpp = "":U then "":U else "/":U ), v-torgconf-saler-kpp )
        v-plat-rasch-doc    = " N ":U + ( if p-round = 'round':U then ": ":U else " ":U ) + fill( " ", 6 ) + v-torgconf-plat-rasch-doc
    .
/* Вывод на экран грузополучателя */
   if ( buf_wth-doc.doc-type = {&income}
   or buf_wth-doc.doc-type = {&return} )
      then do:
         run facturxl-write-cell-data in this-procedure (
               input {&facturxl-h_cargoTo}
             , input v-torgconf-organization
         ).

        if LENGTH(v-torgconf-organization) > 145
         then do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + SUBSTRING(v-torgconf-organization,1,145))   format "X(190)"
               skip space(45) SUBSTRING(v-torgconf-organization,146) format "X(145)"
            .
         end.
         else do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + v-torgconf-organization)   format "X(190)"
            .
         end.
      end.
      else do:
         run facturxl-write-cell-data in this-procedure (
               input {&facturxl-h_cargoTo}
             , input v-torgconf-consignee
         ).
        if LENGTH(v-torgconf-consignee) > 145
         then do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + SUBSTRING(v-torgconf-consignee,1,145))   format "X(190)"
               skip space(45) SUBSTRING(v-torgconf-consignee,146) format "X(145)"
            .
         end.
         else do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + v-torgconf-consignee)   format "X(190)"
            .
        end.
      end.
    put stream Out-stream
        skip    space(5) string( "К платежно-расчетному документу" + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 29 ) + v-torgconf-saler-name + "(" + string( v-torgconf-saler-code ) + ")" ) format "X(190)"
        skip    space(5) string( "Адрес" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-saler-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер покупателя ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + ( if p-round = 'round':U then ": " else " " ) + t-inn ) format "X(190)"
        skip    space(5) string( fill( "_", 130 ) ) format "X(130)"
        skip
    .
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_platDoc}
        , input v-torgconf-plat-rasch-doc
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_saler}
        , input v-torgconf-saler-name + "(":U + string( v-torgconf-saler-code ) + ")":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_salerAddr}
        , input v-torgconf-saler-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_salerINN}
        , input t-inn
    ).
    if buf_wth-doc.doc-type = {&income} and buf_wth-doc.exter_
    then do:
        assign
            v-is-return = yes
        .
    end.
    if v-is-return = yes
    then do:
        put stream Out-stream
            space(10) "Возврат товара поставщику." format "X(120)" skip
        .
    end.
    if v-torgconf-outrubl = no
    then do:
    /*    put stream Out-stream
            space(10)
                string( "Цены и суммы указаны в " +
                trim( ( if invers and buf_wth-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал"  ) ) ) + "." ) format "X(120)"
        .
    end. */
    put stream Out-stream
        space(5)  /*  space(10)    */
            string( "Валюта: наименование, код  " +
            trim( ( if invers and buf_wth-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал"  ) ) ) ) format "X(120)"
    .
    end.
    if v-torgconf-outprim = no
    then do:
        put stream Out-stream
            skip space(10)
            ( if not( buf_wth-doc.PS begins "@" )
            then string( "Примечание : " + substr( buf_wth-doc.PS, 1, 120 ) )
            else ""
            ) format "X(120)"
        .
    end.
    /*
    put stream Out-stream
        skip(1)
    .
    */
end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-footer :
define input parameter p-doc-code   as character    no-undo.
define input parameter p-curr-abbr  as character    no-undo.

    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_shop          for ub.shop.
do
for buf_wth-doc
  , buf_shop
on error undo, return error
:
    find first buf_wth-doc no-lock
         where buf_wth-doc.doc-code = p-doc-code
    .
    put stream Out-stream
        v-single-line format "X({&A4_LS})"
    /* skip */
    .
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream Out-stream.
    end.
    define variable v-out-str      as character no-undo extent 2.
    define variable propissumall   as character format "x(100)" no-undo .
    define variable v-kop          as integer               no-undo .

    run rep/wp-qnty.p ( TRUNCATE(v-tot-sum-no-VAT,0)
                      , output PropisSumAll
                      ) .
    if PropisSumAll = '':U
    then do:
      assign
         PropisSumAll = 'Ноль'
      .
    end.
    assign
       v-kop = ABSOLUTE(INTEGER((v-tot-sum-no-VAT - TRUNCATE(v-tot-sum-no-VAT,0)) * 100))
    .
    v-out-str[1] =  PropisSumall + " {&abbr_rub}. " + STRING(v-kop,"99") + " {&abbr_kop}.".

    run facturxl-write-cell-data in this-procedure (
          input "h_summ_prop":U
        , input v-out-str[1]
    ).

    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-it_VATsum}
        , input string( v-tot-VAT )
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-it_sum}
        , input string( v-tot-sum )
    ).
    display stream Out-stream
        "Всего" @ buf_goods.gds-name
    /*    ( accum total v-sum-no-VAT ) @ v-sum-no-VAT*/
    /*    ( accum total v-VAT ) @ v-VAT*/
    /*    ( accum total v-sum ) @ v-sum*/
        v-tot-sum-no-VAT  @ v-sum-no-VAT
        v-tot-VAT         @ v-VAT
        v-tot-sum         @ v-sum
    with frame factur .
    down stream Out-stream with frame factur .

    if not invers
    then do:
        put stream Out-stream
            space(5) "Итого по документу: "
            trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
            + " ("
            + trim( ( if invers and buf_wth-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) )
            + ")"
                                                                        format "X(120)"     at {&footer-tab-stop1}
        .
    end.
    put stream Out-stream
        skip space(5) "Итого к оплате: "
                        string( trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
                        + " ("
                        + trim( ( if invers and buf_wth-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) )
                        + ")" )
                                                                        format "X(150)"     at {&footer-tab-stop1}
    .
    if PrintRubl
    and v-torgconf-outprops = yes
    then do:        /* Если в р_у_блях, то сумму прописью */
        run rep/wp-rub.p (
            input v-tot-sum
            , output v-propis
            , output v-propis-cop
        ).
        put stream out-stream
            skip space(25) v-propis
                                                                            format "X(150)"  at {&footer-tab-stop1}
            skip(1)
        .
    end.
   /* if v-torgconf-self-obj-type = {&shop}
    and v-torgconf-ext-doc-type <> {&WDEDT_Put_Cli}
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = v-torgconf-self-obj-code
        no-error.
        if available buf_shop
        then do:
            assign
                v-torgconf-main-boss = buf_shop.director
                v-torgconf-main-buh  = entry(1,buf_shop.acct,"|")
            .
        end.
        else do:
            assign
                v-torgconf-main-boss = "":U
                v-torgconf-main-buh  = "":U
            .
        end.
    end.*/
    if v-torgconf-outsubs = no
    then do:
        run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_bossName}
            , input v-torgconf-main-boss
        ).
        run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_buhName}
            , input v-torgconf-main-buh
        ).

    end.

    if v-torgconf-outsubs = no
    and trim(v-torgconf-main-boss) = "":U
    or v-torgconf-outsubs = yes
      then do:
            v-torgconf-main-boss = fill( "_", 36 ).
      end.
    if v-torgconf-outsubs = no
    and trim(v-torgconf-main-buh) = "":U
    or v-torgconf-outsubs = yes
      then do:
         v-torgconf-main-buh = fill( "_", 36 ).
      end.

   /* put stream Out-stream
       skip(1) space(10) "Руководитель предприятия   " format "X(28)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(36)" "/"
       "          Гл. бухгалтер   " format "X(25)"fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-buh format "X(36)" "/"
            skip space(45) "(подпись)" space(30) "(Ф.И.О)"  space(47) "(подпись)" space(30) "(Ф.И.О)"  skip
    .  */

    if v-torgconf-self-host-egrip-date <> "":U
    or v-torgconf-self-host-egrip-num  <> "":U
    then do:
        put stream Out-stream
            skip(1) space(10) "Руководитель организации" format "X(25)" space(75)
            "Главный бухгалтер" format "X(25)" skip
            space(10) "или иное уполномоченное  " format "X(25)" space(75)
            "или иное уполномоченное  " format "X(25)" skip
            space(10) "лицо" format "X(25)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(33)" "/"
            space(10) "лицо" format "X(25)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-buh format "X(31)" "/"
            skip space(43) "(подпись)" space(27) "(Ф.И.О)"  space(57) "(подпись)" space(27) "(Ф.И.О)"
        .
        if v-torgconf-outegrp = no
        then do:
            put stream Out-stream
                skip    space(100)
                     space(10) substitute( "ЕГРИП N &1 от &2", v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date ) format "X(50)"
        .
        end.

        run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_bossName}
            , input "":U
        ).
        run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_buhName}
            , input "":U
        ).

        if v-torgconf-outegrp = yes
        then do:
            assign
                  v-torgconf-self-host-name = fill("_",42)
            .
        end.
        else do:
           if trim(v-torgconf-self-host-name) = "":U
           then do:
               v-torgconf-self-host-name = fill("_", 42).
           end.

           run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_ownerName}
            , input v-torgconf-self-host-name
           ) .
        end.

    end.
end.
end procedure. /* print-footer */

/*==========================================================================*/