block-level on error undo, throw.
/*

$Revision: ba90cb26dd49, 1888, rls $
$Author: druban $
$Date: Fri Jun 07 16:26:45 2019 +0300 $
$Workfile: factur.p $
$Archive: rep/factur.p $

Печать счета-фактуры.

Автор: Комаров Иван Сергеевич
Дата создания: 06/22/10
Author: Ivan Komarov
Creation date: 06/22/10

Автор1: Гюнтнер Виктор Арнольдович
Дата создания1: 04/12/06

Input:
    rec_id      - recid документа trn-doc
    p-ovr       - печать переоценки учетной цены
    invers      - для поставщика
    p-mode      - SYSKEY
    p-round     - округлять
    p-no-slt    - без НП

*/

&scoped-define gds-len 45
&scoped-define footer-tab-stop1 40

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter p-ovr            as logical              no-undo.
define input parameter invers           as logical              no-undo.
define input parameter p-mode           as character            no-undo.   /* используется для анализа sys-key */
define input parameter p-round          as character            no-undo.   /* 'round' включает округление */
define input parameter p-no-slt         as logical              no-undo .  /* yes - не печатаем строку НП */

define variable vss-revision    as character no-undo initial "$Revision: ba90cb26dd49, 1888, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Jun 07 16:26:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: factur.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/factur.p $":U .
define variable vss-description as character no-undo initial "Печать счета-фактуры.":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i       }
{ rep/p-fmt.i        }
{ cmp/breakstr.i     }
{ str/in-vatp.i def  }
{ str/out-vatp.i def }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ rep/fmtcli.i       }
{ str/trdcalib.i     }
{ rep/torgconf.i     }
{ str/clcprtsl.i     }
{ gbl/clntattr.i     }
{ gbl/thbjattr.i     }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/paramls.i      }
{ rep/facturxl.i     }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ rep/tmp-tab.i      }
define stream Out-stream .

define shared variable PrintScale   as logical              no-undo.
define shared variable CostPrice    as logical              no-undo.
define shared variable sort-name    as logical              no-undo.
define shared variable sort-gr      as logical              no-undo.

DEFINE temp-table gds-prop no-undo
    field   artic            as char
    field   prod-type        as char
    field   prod-code        as integer
    field   part-code        like ub.parts.part-code
    field   in-code          like ub.parts.in-code
    field   gds-code         as integer
    field   gds-name         as char
    field   gds-name1        as char
    field   grp-name         as char
    field   unit-code        as char
    field   unit-base        as char
    field   b-code           as integer
    field   qnty             as decimal
    field   price-no-VAT     as decimal
    field   sum-no-VAT       as decimal
    field   VAT-pc           as decimal
    field   sum-actciz       as decimal
    field   VAT              as decimal
    field   stoim            as decimal
    field   sum              as decimal
    field   gds-type         as character
    field   country          as character
    field   country-code     as character
    field   GTD              as character

    index pi  is primary   artic  prod-type prod-code
    index pi1              gds-name
    index pi2              grp-name
.
/* define temp-table temp-gtd no-undo  /* для списка ГТД */*/
/*    field artic     like ub.goods.artic*/
/*    field prod-code like ub.goods.prod-code*/
/*    field prod-type like ub.goods.prod-type*/
/*    field gtd       as character*/
/*    INDEX pi  IS PRIMARY artic  prod-type  prod-code*/
/*  .*/

define variable tdoc-prt                as logical              no-undo.
define variable PrevPage                as integer     init 0   no-undo.

define variable rep-artic               as logical              no-undo.

define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.
define variable rootnode_code           as integer              no-undo.

define variable v-lines-counter         as integer              no-undo.
define variable v-node-code             like ub.gds-prt.upper-code no-undo.
define variable v-curr-abbr             as character            no-undo.

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

define variable v-outhdobj              as logical  init no     no-undo .   /* для межфирменных документов печатать в поле грузополучатель объект получателя*/
define variable v-outhdobj-str          as character            no-undo .
define variable v-is-hold-doc           as logical              no-undo .
define variable v-par-type              as character            no-undo .

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
define variable sym16 as character initial ":" no-undo.

define variable v-prt-name      as character            no-undo.
define variable v-country       as character            no-undo.
define variable v-GTD           as character            no-undo.
define variable v-single-line   as character            no-undo.
define variable v-propis        as character            no-undo.
define variable v-propis-cop    as character            no-undo.
define variable v-VAT-prc       as decimal              no-undo .

define variable v-unit-code     as character            no-undo.
define variable v-country-code  as character            no-undo.
define variable v-host-code     as integer              no-undo.
define variable v-curr-code     as integer              no-undo.

define variable v-tax-name      as character            no-undo.
define variable v-tax-price     as decimal      init 0          no-undo.
define variable v-tax           as decimal      init 0          no-undo.
define variable v-tot-tax       as decimal      init 0          no-undo.
define variable v-r-factur-is-vozvrat-vnesh  as logical      no-undo.
define variable  tmp-var                    as character                 no-undo.
define variable  FullGdsName                as logical                   no-undo.

define variable v-uaes-code     as character             no-undo. /* Код вида товара в соответствии с единой Товарной номенклатурой внешнеэкономической деятельности ЕАЭС */

define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer                   no-undo.
define variable  v-out-name                 as character                 no-undo.


define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_our_clients   for ub.clients.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
define buffer buf_sysconf       for ub.sysconf.
define buffer buf_parts-root    for ub.parts-root.
define buffer buf_goods         for ub.goods.
define buffer buf_parts         for ub.parts.
define buffer buf_country       for ub.country.
define buffer buf_parts-attr    for ub.parts-attr.

define frame factur
        sym1               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        buf_goods.gds-name     column-label "Наименование товара (описание выполненных ! работ, оказанных услуг),! имущественного права ! ! ":C45 format "X(45)" space(0)
        sym2               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-uaes-code        column-label "!Код!вида!товара":C6 format "x(6)" space(0)
        sym16              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-unit-code        column-label "   Е!  из!----! !код ! " format "X(3)" space(0)
        sym14              column-label "д!м!-!:!:!:" format "X(1)" space(0)
        buf_goods.unit-base    column-label "иница   !ерения  !--------!условное!обозна- ! чение  ":C8 format "X(8)" space(0)
        sym3               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-qnty             column-label "Количество! (объем)  ! ! " format ">>>>>>9.<<<" space(0)
        sym4               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-price-no-VAT     column-label "Цена (тариф)!за ед.изм.! ! ":C12 format "->>>>>>>9.99" space(0)
        sym5               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-no-VAT       column-label "Стоимость товаров!(работ, услуг),!имуществ. прав!без налога -!всего":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-actciz       column-label "в т.ч.!сумма!акциза! ":C10 format ">>>>>>9.99" space(0)
        sym7               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-vat-prc          column-label "Налог-!овая!ставка! ":C6 format ">9.9<%" space(0)
        sym8               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-VAT              column-label "Сумма!налога,!предъявляе-!мая!покупателю":C12 format "->>>>>>>9.99" space(0)
        sym9               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum              column-label "Ст-ть товаров!(работ, услуг),!имуществ. прав!с налогом -!всего":c15 format "->>>>>>>>>>9.99" space(0)
        sym11              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-country-code     column-label "     С!  прои!------!цифро-! вой  ! код  " format "x(6)" space(0)
        sym15              column-label "т!с!-!:!:!:" format "X(1)" space(0)
        v-country          column-label "рана      !хождения !----------! краткое  !наименова-!   ние    " format "X(10)" space(0)
        sym12              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-GTD              column-label "Регистра-!ционный!номер!таможенной!декларации":C30 format "X(30)" space(0)
        sym13              column-label ":!:!:!:!:!:" format "X(1)" space(0)
header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U  )                                                      at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X(199)" at 1
with width {&DOS_CW} down stream-io.



define frame factur-10
    /*    sym1               column-label ":!:!:!:!:!:" format "X(1)" space(0)   */
        buf_goods.gds-name     column-label "Наименование товара (описание выполненных работ, ! оказанных услуг), имущественного права ! ! ":C54 format "X(54)" space(0)
        sym2               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-uaes-code        column-label "!Код!вида!товара":C6 format "x(6)" space(0)
        sym16              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-unit-code        column-label "   Е!  из!----! !код ! " format "X(3)" space(0)
        sym14              column-label "д!м!-!:!:!:" format "X(1)" space(0)
        buf_goods.unit-base    column-label "иница   !ерения  !--------!условное!обозна- ! чение  ":C8 format "X(8)" space(0)
        sym3               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-qnty             column-label "Количество! ! ! " format ">>>>>>9.<<<" space(0)
        sym4               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-price-no-VAT     column-label "Цена (тариф)!за ед.изм.! ! ":C12 format "->>>>>>>9.99" space(0)
        sym5               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-no-VAT       column-label "Стоимость товаров!(работ, услуг),!имуществ. прав!всего без налога! ":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum-actciz       column-label "в т.ч.!акциз! ! ":C10 format ">>>>>>9.99" space(0)
        sym7               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-Vat-prc          column-label "Ставка!налога! ! ":C6 format ">9.9<%" space(0)
        sym8               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-VAT              column-label "Сумма!налога! ! ":C12 format "->>>>>>>9.99" space(0)
        sym9               column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-sum              column-label "Ст-ть товаров!(работ, услуг),!имуществ. прав!с учетом налога! ":c15 format "->>>>>>>>>>9.99" space(0)
        sym11              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-country-code     column-label "     С!  прои!------!цифро-! вой  ! код  " format "x(6)" space(0)
        sym15              column-label "т!с!-!:!:!:" format "X(1)" space(0)
        v-country          column-label "рана      !хождения !----------! краткое  !наименова-!   ние    " format "X(10)" space(0)
        sym12              column-label ":!:!:!:!:!:" format "X(1)" space(0)
        v-GTD              column-label "Номер таможенной!декларации! ! ":C30 format "X(30)" space(0)
    /*    sym13              column-label ":!:!:!:!:!:" format "X(1)" space(0)    */
header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U  )                                                      at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "x(232)" at 1
with width {&DOS_CW} down stream-io.

do
on error undo, return error
:
{ gbl/working.i }
{ gbl/getcntxt.i get " " p-mainmenu-handle }
{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
then do:
    assign
        v-r-factur-is-vozvrat-vnesh = yes
    .
end.
else do:
    assign
        v-r-factur-is-vozvrat-vnesh = no
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
run torgconf-read in this-procedure (
      input "factur"
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
  if lookup( "factur", v-outhdobj-str ) <> 0
  then do:
    assign
      v-outhdobj = yes
    .
  end.
end.

{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.

assign
    FullGdsName = ( tmp-var = "yes" )
.
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
end.
run torgconf-get-cli-param in this-procedure (
      input buf_trn-doc.host-code
    , input buf_trn-doc.cli-type
    , input buf_trn-doc.cli-code
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


/* Код вида товара в соответствии с единой Товарной номенклатурой внешнеэкономической деятельности ЕАЭС.
   При отсутствии данных в новой графе «Код вида товара» с 1 октября 2017 года проставляется прочерк. */ 
v-uaes-code = "  -   " .


IF LOOKUP( "dec10", p-mode ) <> 0
THEN DO:
  assign
      v-single-line   = fill("-", 232)
      v-lines-counter = 1
  .
END.
ELSE DO:
  assign
      v-single-line   = fill("-", 208)
      v-lines-counter = 1
  .
END.
if p-ovr = yes
then do:
    for each buf_parts-root no-lock
       where buf_parts-root.doc-code = buf_trn-doc.doc-code
    :
            create gds-prop .
            if invers
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = buf_parts-root.orig-gds-code
                .
                find first buf_parts no-lock
                     where buf_parts.artic     = buf_goods.artic
                       and buf_parts.prod-code = buf_goods.prod-code
                       and buf_parts.prod-type = buf_goods.prod-type
                       and buf_parts.part-code = buf_parts-root.orig-part-code
                       and buf_parts.in-code   = buf_parts-root.orig-in-code
                       and buf_parts.out-code  = buf_trn-doc.doc-code
                       and buf_parts.obj-code  = buf_trn-doc.obj-code
                       and buf_parts.obj-type  = buf_trn-doc.obj-type
                no-error .
            end.
            else do:
                find first buf_goods no-lock
                    where buf_goods.gds-code = buf_parts-root.gds-code
                .
                find first buf_parts no-lock
                     where buf_parts.artic     = buf_goods.artic
                       and buf_parts.prod-code = buf_goods.prod-code
                       and buf_parts.prod-type = buf_goods.prod-type
                       and buf_parts.part-code = buf_parts-root.part-code
                       and buf_parts.in-code   = buf_parts-root.in-code
                       and buf_parts.out-code  = buf_trn-doc.doc-code
                       and buf_parts.obj-code  = buf_trn-doc.obj-code
                       and buf_parts.obj-type  = buf_trn-doc.obj-type
                no-error .
            end.

            { gbl/gdsbcode.i  buf_goods.gds-code  ?  gds-prop.b-code  no-error }
            if error-status :error
            then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при определении бар-кода товара"
                    skip  "Код товара" buf_goods.gds-code
                view-as alert-box error .
            end.
            create tt-clcparts.
            buffer-copy buf_parts to tt-clcparts.
            run clcprtsl_calc-parts (
                  input recid( tt-clcparts )
                , input no
                , input no
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
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
            assign
                gds-prop.artic     = buf_goods.artic
                gds-prop.prod-type = buf_goods.prod-type
                gds-prop.prod-code = buf_goods.prod-code
                gds-prop.gds-code  = buf_goods.gds-code
                gds-prop.gds-name1 = buf_goods.gds-name
                gds-prop.grp-name  = buf_goods.grp-name
                gds-prop.unit-base = buf_goods.unit-base
                gds-prop.gds-type  = buf_goods.gds-type
                gds-prop.part-code = buf_parts-root.part-code
                gds-prop.in-code   = buf_parts-root.in-code
                gds-prop.qnty      = ABSOLUTE(buf_parts.fact-qnty)
                gds-prop.VAT-pc    = buf_parts.VAT-pc
                gds-prop.GTD       = buf_parts.cst-code
            .
            find first ub.country no-lock
                 where ub.country.alpha1 = buf_goods.alpha1
            no-error.
            if available ub.country
            then do:
                assign
                    gds-prop.country-code = " " + string(ub.country.num-code)
                    gds-prop.country = ub.country.short-name
                .
            end.
            else do:
                assign
                    gds-prop.country-code = ""
                    gds-prop.country = ""
                .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = buf_goods.gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
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
                          gds-prop.country-code = " " + string(buf_country.num-code)
                          gds-prop.country = buf_country.short-name
                        .
                  end.
            end.

            find first ub.Units no-lock
                 where ub.units.unit-name = buf_goods.unit-base
            .
            gds-prop.unit-code = string(ub.units.OKEI).
            if ub.Units.type = "{&bef-divisional},{&bef-twounit}"
            or ub.Units.type = "{&bef-divisional},{&bef-altunit}"
            then do:
                assign
                    gds-prop.gds-name = (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "")
                                              + string(buf_goods.Sort,"x(5)")
                                        + " " + trim(buf_goods.gds-name)
                                        + " " + trim(buf_goods.PS)
                .
            end.
            else do:
                assign
                    gds-prop.gds-name = (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "")
                                          + trim(buf_goods.gds-name)
                .
            end.
            if PrintRubl
            then do:
                assign
                    gds-prop.price-no-VAT = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc - tt-allsum.road-tax-rubl-acc) / gds-prop.qnty
                    gds-prop.sum-no-VAT   = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc - tt-allsum.road-tax-rubl-acc)
                    gds-prop.VAT          = ABSOLUTE(tt-allsum.vat-rubl-acc)
                    gds-prop.stoim        = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc)
                    gds-prop.sum          = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc)
                    v-tot-tax             = v-tot-tax + ABSOLUTE(tt-allsum.road-tax-rubl-acc)
                    v-tot-SLT             = v-tot-SLT + ABSOLUTE(tt-allsum.slt-rubl-acc)
                .
            end.
            else do:
                assign
                    gds-prop.price-no-VAT = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc - tt-allsum.road-tax-base-acc) / gds-prop.qnty
                    gds-prop.sum-no-VAT  = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc - tt-allsum.road-tax-base-acc)
                    gds-prop.VAT         = ABSOLUTE(tt-allsum.vat-base-acc)
                    gds-prop.sum         = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc)
                    gds-prop.stoim       = ABSOLUTE(tt-allsum.sum-dsc-base-acc)
                    v-tot-tax            = v-tot-tax + ABSOLUTE(tt-allsum.road-tax-base-acc)
                    v-tot-SLT            = v-tot-SLT + ABSOLUTE(tt-allsum.slt-base-acc)
                .
            end.
    end.      /* for each buf_parts-root no-lock */
end.        /* if p-ovr = yes  */

{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

run facturxl-init in this-procedure .

run print-header in this-procedure (
      input buf_trn-doc.doc-code
    , output v-curr-abbr
).
if lookup( "dec10", p-mode ) <> 0
THEN DO:
  form header
      v-single-line format "x(232)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame Bottomframe-10 width {&DOS_CW} page-bottom no-labels no-box .
  view stream Out-stream frame Bottomframe-10 .
form with frame factur-10 .
END.
ELSE DO:
  form header
      v-single-line format "X(199)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
  view stream Out-stream frame Bottomframe .

form with frame factur .
END.
/*---S---------------- По строке документа -----------------------*/

if p-ovr = yes
then do:
    if sort-name = yes
    then do:        /*Включена сортировка по имени*/
        if sort-gr = yes
        then do:
            for each gds-prop
            break by gds-prop.grp-name
                  by gds-prop.gds-name
            :
                if first-of( gds-prop.grp-name )
                then do:
                    put stream out-stream
                        skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name
                    .
                end.
                run print-line-po in this-procedure .
            end.
        end.
        else do:
            for each gds-prop
            break by gds-prop.gds-name
            :
                run print-line-po in this-procedure .
            end.
        end.
    end.                           /*Включена сортировка по имени*/
    else do:        /*Сортировка по имени выключена*/
        if sort-gr = yes
        then do:
            for each gds-prop
            break by gds-prop.grp-name
                  by gds-prop.artic
            :
                if first-of( gds-prop.grp-name )
                then do:
                    put stream out-stream
                        skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name
                    .
                end.
                run print-line-po in this-procedure .
            end.
        end.
        else do:
            for each gds-prop
            break by gds-prop.artic
            :
                run print-line-po in this-procedure .
            end.
        end.
    end.                           /*Сортировка по имени выключена*/
end.        /* if p-ovr = yes */
else do:
    for each ub.doc-line no-lock
       where ub.doc-line.doc-code = buf_trn-doc.doc-code
    break &if "{&sort-prod}" = "yes" &then by ( ub.doc-line.prod-type + string( ub.doc-line.prod-code ) ) &endif by ub.doc-line.artic
    :
        run print-line in this-procedure .
    end.        /*for  each ub.doc-line ...*/
end.        /* NOT ( if p-ovr = yes ) */
/*---E---------------- По строке документа -----------------------*/
run print-footer in this-procedure (
      input buf_trn-doc.doc-code
    , input v-curr-abbr
).
case p-mode :
  when "dec10" then do:
    run facturxl-close-10 in this-procedure .
  end.
  when "vat-itog" then do:
    run facturxl-close-vat-itog in this-procedure .
  end.
  otherwise do:
    run facturxl-close in this-procedure .
  end.
end case .

if lookup( "dec10", p-mode ) <> 0
THEN DO:
  hide stream Out-stream frame Bottomframe-10 .
end.
ELSE DO:
  hide stream Out-stream frame Bottomframe .
end.
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
    def var v-start-string as character no-undo.
    def var v-add-string as character no-undo.
    assign
        v-start-string = gds-str2
    .

    do while trim(v-start-string) <> "" :
        assign gds-str = v-start-string.
        v-add-string = breakstr(gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string).
        if lookup( "dec10", p-mode ) <> 0
        THEN DO:
          display stream Out-stream
            /*sym1*/ ((if rep-artic then fill(" ",17) else "") + v-add-string) @ buf_goods.gds-name
            sym16 sym14 sym2 sym3 sym4 sym5 sym6 sym7 sym8
            sym9 /*sym10*/ sym11 sym15 sym12 /*sym13*/
            with frame factur-10 .
          down stream Out-stream 1 with frame factur-10 .
        END.
        ELSE DO:
          display stream Out-stream
            sym1 ((if rep-artic then fill(" ",17) else "") + v-add-string) @ buf_goods.gds-name
            sym16 sym14 sym2 sym3 sym4 sym5 sym6 sym7 sym8
            sym9 /*sym10*/ sym11 sym15 sym12 sym13
            with frame factur .
          down stream Out-stream 1 with frame factur .
        END.
    end. /* DO WHILE ... */
end.
end procedure.

/*==========================================================================*/
procedure print-line :

    define variable v-print-parts     as logical    init no       no-undo.

do
on error undo, return error
:
    assign v-VAT-prc = ub.doc-line.VAT-pc . /* в общем случае так, в ценах закупки поменяем */
    find first buf_goods no-lock
         where buf_goods.prod-type = ub.doc-line.prod-type
           and buf_goods.prod-code = ub.doc-line.prod-code
           and buf_goods.artic = ub.doc-line.artic
    .
    find first ub.country no-lock
         where ub.country.alpha1 = buf_goods.alpha1
    no-error.
    if lookup( "zum", p-mode ) <> 0
    then do:
        assign
            v-country = buf_goods.engl-name
        .
    end.
    else do:
        if available ub.country
        then do:
            assign
                v-country-code = " " + string(ub.country.num-code)
                v-country = ub.country.short-name
            .
        end.
        else do:
            assign
                v-country-code = ""
                v-country = ""
            .
        end.
    end.
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
    .
    find first Units no-lock
         where units.unit-name = buf_goods.unit-base
    .
    v-unit-code = (if units.OKEI = 0 then "-" else string(units.OKEI)) .
    if (units.type = "{&bef-divisional},{&bef-twounit}"  or  units.type = "{&bef-divisional},{&bef-altunit}" )
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

    find first gds-prt no-lock
         where gds-prt.upper-code = doc-line.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code
    .
    if ( gds-prt.node-name <> {&empty-scale} )
/*    and ( not invers )*/
    then do:
        /*---S------------- Не пустая шкала и не от поставщика ---------------------*/
       assign
           v-tot-prt-qnty          = 0
           v-tot-prt-VAT           = 0
           v-tot-prt-SLT           = 0
           v-tot-prt-sum-no-VAT    = 0
           v-tot-prt-sum           = 0
       .
       if PrintScale = yes
       then do:
          define variable is-printed as logical initial no no-undo .
          for each parts no-lock
             where parts.out-code  = doc-line.doc-code
               and parts.obj-type  = doc-line.obj-type
               and parts.obj-code  = doc-line.obj-code
               and parts.artic     = doc-line.artic
               and parts.prod-type = doc-line.prod-type
               and parts.prod-code = doc-line.prod-code
          :
             /*---S------------- По партиям - для печати ГТД ---------------------*/
              assign v-GTD = parts.cst-code.
              if     available country
                 and country.alpha1 = "RU":U
              then do:
                 assign
                     v-GTD       = "":U
                     v-country-code = "":U
                     v-country   = "":U
                .
              end.
              find first buf_parts-attr no-lock
                   where buf_parts-attr.in-code   = parts.in-code
                     and buf_parts-attr.gds-code  = goods.gds-code
                     and buf_parts-attr.part-code = parts.part-code
              no-error .
              if available buf_parts-attr
                 and buf_parts-attr.country-code <> 0
              then do:
                 find first buf_country
                 where buf_country.num-code = buf_parts-attr.country-code
                 no-error.
                 if available buf_country
                    and buf_country.num-code <> country.num-code
                    and buf_country.short-name <> ""
                 then do :
                    assign
                       v-country-code = " " + string(buf_country.num-code)
                       v-country = buf_country.short-name
                    .
                    if buf_country.alpha1 = "RU":U
                    then do :
                       assign
                           v-country-code = "":U
                           v-country = "":U
                           v-GTD     = "":U
                       .
                    end .
                 end.
              end.
            /*---S------------- Печатать по шкале ---------------------*/
            if is-printed = no 
              then do:
              assign is-printed = yes .
                 if lookup( "dec10", p-mode ) <> 0
                 THEN DO:
                    display stream Out-stream /*sym1*/ gds-str1 @ buf_goods.gds-name sym16 sym14 sym2 v-country sym3 v-GTD
                                             sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 /*sym13*/ with frame factur-10 .
                    down stream Out-stream 1 with frame factur-10 .
                 END.
                 ELSE DO:
                    display stream Out-stream sym1 gds-str1 @ buf_goods.gds-name sym16 sym14 sym2 v-country sym3 v-GTD
                                              sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 sym13 with frame factur .
                    down stream Out-stream 1 with frame factur .
                 END.
                 run facturxl-write-line-data in this-procedure (
                      input gds-str1        /*  p-Name     */
                    , input "":U            /*  p-UAES     */  
                    , input "":U            /*  p-OKEI     */
                    , input "":U            /*  p-EI       */
                    , input "":U            /*  p-qnty     */
                    , input "":U            /*  p-price    */
                    , input "":U            /*  p-SumNoVAT */
                    , input "":U            /*  p-SumActciz*/
                    , input "":U            /*  p-VATpc    */
                    , input "":U            /*  p-VATsum   */
                    , input "":U            /*  p-sum      */
                    , input v-country-code  /*  p-countrycode  */
                    , input v-country       /*  p-country  */
                    , input v-GTD           /*  p-GTD      */
                ).
              end.
              else do:
                 if v-GTD <> "" 
                 then do:
                    if lookup( "dec10", p-mode ) <> 0
                    THEN DO:
                       display stream Out-stream /*sym1*/ sym16 sym14 sym2  sym3 v-GTD sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 /*sym13*/ with frame factur-10 .
                       down stream Out-stream 1 with frame factur-10 .
                    END.
                    ELSE DO:
                       display stream Out-stream sym1 sym16 sym14 sym2  sym3 v-GTD sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 sym13 with frame factur .
                       down stream Out-stream 1 with frame factur .
                    END.
                    run facturxl-write-line-data in this-procedure (
                          input "":U            /*  p-Name     */
                        , input "":U            /*  p-UAES     */  
                        , input "":U            /*  p-OKEI     */
                        , input "":U            /*  p-EI       */
                        , input "":U            /*  p-qnty     */
                        , input "":U            /*  p-price    */
                        , input "":U            /*  p-SumNoVAT */
                        , input "":U            /*  p-SumActciz*/
                        , input "":U            /*  p-VATpc    */
                        , input "":U            /*  p-VATsum   */
                        , input "":U            /*  p-sum      */
                        , input "":U            /*  p-countrycode  */
                        , input "":U            /*  p-country  */
                        , input v-GTD           /*  p-GTD      */
                    ).
                 end.
              end.
          end.
          if is-printed = no 
          then do:
             if lookup( "dec10", p-mode ) <> 0
             THEN DO:
                display stream Out-stream /*sym1*/ gds-str1 @ buf_goods.gds-name sym16 sym14 sym2 v-country sym3 sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 /*sym13*/ with frame factur-10 .
                down stream Out-stream 1 with frame factur-10 .
             END.
             ELSE DO:
                display stream Out-stream sym1 gds-str1 @ buf_goods.gds-name sym16 sym14 sym2 v-country sym3 sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym15 sym12 sym13 with frame factur .
                down stream Out-stream 1 with frame factur .
             END.
             run facturxl-write-line-data in this-procedure (
                      input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name  /*  p-Name     */
                    , input "":U            /*  p-UAES     */  
                    , input "":U            /*  p-OKEI     */
                    , input "":U            /*  p-EI       */
                    , input "":U            /*  p-qnty     */
                    , input "":U            /*  p-price    */
                    , input "":U            /*  p-SumNoVAT */
                    , input "":U            /*  p-SumActciz*/
                    , input "":U            /*  p-VATpc    */
                    , input "":U            /*  p-VATsum   */
                    , input "":U            /*  p-sum      */
                    , input v-country-code  /*  p-countrycode  */
                    , input v-country       /*  p-country  */
                    , input "":U            /*  p-GTD      */
                ).
             if FullGdsName
               and gds-str1 <> "":U 
             then do :
                run print-more in this-procedure.
             end.
          end.
          /*---E------------- Печатать по шкале ---------------------*/
       end.        /* if PrintScale = yes */
       for each gds-dtl no-lock
           where gds-dtl.prod-type  = doc-line.prod-type
             and gds-dtl.prod-code  = doc-line.prod-code
             and gds-dtl.artic      = doc-line.artic
             and gds-dtl.doc-code   = doc-line.doc-code
       :
            /*---S------------- for each gds-dtl ---------------------*/
           find first gds-prt no-lock
                 where gds-prt.node-code = gds-dtl.prt-code
           .
           if CostPrice = yes
           then do:
              { str/in-vatp.i calc doc-line. buf_trn-doc. g }
              assign
                 v-VAT-prc   = vat-pc-loc
                 v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                 v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
              .
              if v-VAT = ?        then assign v-VAT       = 0.
              if v-SLT = ?        then assign v-SLT       = 0.
              assign
/*                        v-price-no-VAT = ( if PrintRubl*/
/*                                        then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc*/
/*                                        else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc)*/
                  v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc ) - v-VAT - v-SLT
                    v-prt-qnty       = gds-dtl.fact-qnty
              .
              if v-r-factur-is-vozvrat-vnesh = yes
              then do:
                 assign
                    v-price-no-VAT = v-price-no-VAT -
                                  ( if PrintRubl
                                            then ( transport-rubl-loc + other-rubl-loc )
                                            else ( transport-base-loc + other-base-loc ) )
                    .
              end.
              if p-round = 'round':U
              then do:
                 run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input v-void-decimal
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
/*                    assign*/
/*                        v-vat-prc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-prc, 2 )*/
/*                        v-prt-SLT           = round( ( v-price-no-VAT + v-VAT ) * v-prt-qnty * v-slt-pc, 2 )*/
/*                        v-prt-VAT           = round( v-VAT          * v-prt-qnty, 2 )*/
/*                        v-prt-sum-no-VAT    = round( v-price-no-VAT * v-prt-qnty, 2 )*/
/*                    .*/
              end.        /* if p-round = 'round':U */
              else do:
                 assign
                    v-prt-VAT       =  v-VAT            * v-prt-qnty
                    v-prt-SLT        = v-SLT            * v-prt-qnty
                    v-prt-sum-no-VAT = v-price-no-VAT   * v-prt-qnty
                 .
              end.        /* if NOT( p-round = 'round':U ) */
              assign
                 v-price          = v-price-no-VAT + v-VAT
                 v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
              .
              assign
                 v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                 v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                 v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                 v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                 v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
              .
           end.        /* CostPrice = yes  */
           else do:
              { str/out-vatp.i calc-gds-dtl doc-line. buf_trn-doc. gds-dtl. }
              assign
                 v-VAT = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                 v-SLT = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
              .
              if v-VAT = ? then assign v-VAT = 0.
              if v-SLT = ? then assign v-SLT = 0.
              assign
                 v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale ) - v-VAT - v-SLT
                 v-prt-qnty       = gds-dtl.fact-qnty
              .
              if p-round = 'round':U
              then do:
                 run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input v-void-decimal
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
/*                    assign*/
/*                        v-vat-prc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-prc, 2 )*/
/*                        v-prt-SLT           = round( ( v-price-no-VAT + v-VAT ) * v-prt-qnty * v-slt-pc, 2 )*/
/*                        v-prt-VAT           = round( v-VAT          * v-prt-qnty, 2 )*/
/*                        v-prt-sum-no-VAT    = round( v-price-no-VAT * v-prt-qnty, 2 )*/
/*                    .*/
              end.        /* p-round = 'round':U */
              else do:
                 assign
                    v-prt-VAT        = v-VAT          * v-prt-qnty
                    v-prt-SLT        = v-SLT          * v-prt-qnty
                    v-prt-sum-no-VAT = v-price-no-VAT * v-prt-qnty
                 .
              end.        /* NOT ( p-round = 'round':U ) */
              assign
                 v-price          = v-price-no-VAT + v-VAT
                 v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
              .
              assign
                 v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                 v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                 v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                 v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                 v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
              .
           end.        /* NOT ( CostPrice = yes  ) */
           if PrintScale
           then do:
              /*---S------------- Печатать шкалу ---------------------*/
              find first bar-code no-lock
                   where bar-code.gds-code    = buf_goods.gds-code
                     and bar-code.unit-cli    = buf_goods.unit-base
                     and bar-code.node-code   = gds-dtl.prt-code
                     and bar-code.part-code   = ""
                     and bar-code.in-code     = ""
              .
              assign
                 v-prt-name = ""
              .
              do while available gds-prt:
                 if available gds-prt
                 then do:
                    assign
                       v-prt-name     = "\" + string( gds-prt.node-name, "X(10)" ) + v-prt-name
                       v-node-code   = gds-prt.upper-code
                    .
                 end.
                 find first gds-prt no-lock
                      where gds-prt.node-code = v-node-code
                        and gds-prt.root <> yes
                 no-error.
              end.
              if lookup( "dec10", p-mode ) <> 0
              THEN DO:
                 display stream out-stream
                       /*sym1*/ v-prt-name                 @ buf_goods.gds-name
                        sym2 "  -   " @ v-uaes-code
                        sym16 v-unit-code
                        sym14 "  " + buf_goods.unit-base
                        sym3 v-prt-qnty                     @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-prt-sum-no-VAT               @ v-sum-no-VAT
                        sym6 "без акциза" format "x(10)"         @ v-sum-actciz
                        sym7 v-VAT-prc
                        sym8 v-prt-VAT when v-prt-qnty <> 0 @ v-VAT
                        sym9 v-prt-sum                      @ v-sum
    /*                            sym10 v-prt-SLT when v-prt-qnty <> 0 @ v-SLT*/
                        sym11 sym15 sym12 /*sym13*/
                        with frame factur-10 .
                 assign v-lines-counter = v-lines-counter + 1 .
                 down stream out-stream 1 with frame factur-10 .
              END.
              ELSE DO:
                 display stream out-stream
                        sym1 v-prt-name                     @ buf_goods.gds-name
                        sym2 "  -   " @ v-uaes-code
                        sym16 v-unit-code
                        sym14 "  " + buf_goods.unit-base
                        sym3 v-prt-qnty                     @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-prt-sum-no-VAT               @ v-sum-no-VAT
                        sym6 "без акциза" format "x(10)"         @ v-sum-actciz
                        sym7 v-VAT-prc
                        sym8 v-prt-VAT when v-prt-qnty <> 0 @ v-VAT
                        sym9 v-prt-sum                      @ v-sum
    /*                            sym10 v-prt-SLT when v-prt-qnty <> 0 @ v-SLT*/
                        sym11 sym15 sym12 sym13
                        with frame factur .
                  assign v-lines-counter = v-lines-counter + 1 .
                  down stream out-stream 1 with frame factur .
              END.
              run facturxl-write-line-data in this-procedure (
                      input v-prt-name                  /*  p-Name     */
                    , input v-uaes-code                 /*  p-UAES     */  
                    , input v-unit-code                 /*  p-OKEI     */
                    , input buf_goods.unit-base         /*  p-EI       */
                    , input string( v-prt-qnty )        /*  p-qnty     */
                    , input string( v-price-no-VAT )    /*  p-price    */
                    , input string( v-prt-sum-no-VAT )  /*  p-SumNoVAT */
                    , input "без акциза":U                  /*  p-SumActciz*/
                    , input string( v-VAT-prc )         /*  p-VATpc    */
                    , input string( v-prt-VAT )         /*  p-VATsum   */
                    , input string( v-prt-sum )         /*  p-sum      */
                    , input "":U                        /*  p-countrycode  */
                    , input "":U                        /*  p-country  */
                    , input "":U                        /*  p-GTD      */
                ).
                /*---E------------- Печатать шкалу ---------------------*/
           end.
            /*---E------------- for each gds-dtl ---------------------*/
        end.
        assign
            v-qnty          = v-tot-prt-qnty
            v-VAT           = v-tot-prt-VAT
            v-SLT           = v-tot-prt-SLT
            v-sum-no-VAT    = v-tot-prt-sum-no-VAT
            v-sum           = v-tot-prt-sum
        .
        if not PrintScale
        then do:
            /*---S------------- Не печатать признаки ---------------------*/
           assign v-price-no-VAT = v-sum-no-VAT / v-qnty.
           find first bar-code no-lock
                where bar-code.gds-code = buf_goods.gds-code
                  and bar-code.unit-cli   = buf_goods.unit-base
                  and bar-code.node-code  = rootnode_code
                  and bar-code.part-code  = ""
                  and bar-code.in-code    = ""
           .
           for each parts no-lock
                where parts.out-code    = doc-line.doc-code
                  and parts.obj-type  = doc-line.obj-type
                   and parts.obj-code  = doc-line.obj-code
                   and parts.artic     = doc-line.artic
                   and parts.prod-type = doc-line.prod-type
                   and parts.prod-code = doc-line.prod-code
           :
                    /*---S------------- По партиям ---------------------*/
              assign v-GTD = parts.cst-code.
              if available country
                 and country.alpha1 = "RU":U
              then do:
                 assign
                    v-GTD       = "":U
                    v-country-code = "":U
                    v-country   = "":U
                 .
              end.
              find first buf_parts-attr no-lock
                   where buf_parts-attr.in-code   = parts.in-code
                     and buf_parts-attr.gds-code  = goods.gds-code
                     and buf_parts-attr.part-code = parts.part-code
              no-error .
              if available buf_parts-attr
                 and buf_parts-attr.country-code <> 0
              then do:
                 find first buf_country
                      where buf_country.num-code = buf_parts-attr.country-code
                 no-error.
                 if available buf_country
                    and buf_country.num-code <> country.num-code
                    and buf_country.short-name <> ""
                 then do :
                    assign
                       v-country-code = " " + string(buf_country.num-code)
                       v-country = buf_country.short-name
                    .
                    if buf_country.alpha1 = "RU":U
                    then do :
                       assign
                          v-country-code = "":U
                          v-country = "":U
                          v-GTD     = "":U
                       .
                    end .
                 end.
              end.
              if lookup( "dec10", p-mode ) <> 0
              THEN DO:
                 display stream Out-stream
                           /*sym1*/ ((if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name)      @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 "  " + buf_goods.unit-base
                            sym3 parts.fact-qnty                                                       @ v-qnty
                            sym4 v-price-no-VAT
                            sym5 (if v-qnty <> 0 then v-sum-no-VAT * parts.fact-qnty / v-qnty else 0 ) @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                             @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-VAT * parts.fact-qnty / v-qnty when v-qnty <> 0                     @ v-VAT
                            sym9 (if v-qnty <> 0 then v-sum * parts.fact-qnty / v-qnty else 0 )        @ v-sum
/*                                sym10 v-SLT * parts.fact-qnty / v-qnty when v-qnty <> 0 @ v-SLT*/
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            /*sym13*/
                            with frame factur-10 .
                 down stream Out-stream 1 with frame factur-10 .
              END.
              ELSE DO:
                 display stream Out-stream
                             sym1 ((if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name)          @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 "  " + buf_goods.unit-base
                            sym3 parts.fact-qnty                                                       @ v-qnty
                            sym4 v-price-no-VAT
                            sym5 (if v-qnty <> 0 then v-sum-no-VAT * parts.fact-qnty / v-qnty else 0 ) @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)" @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-VAT * parts.fact-qnty / v-qnty when v-qnty <> 0                     @ v-VAT
                            sym9 (if v-qnty <> 0 then v-sum * parts.fact-qnty / v-qnty else 0 )        @ v-sum
/*                                sym10 v-SLT * parts.fact-qnty / v-qnty when v-qnty <> 0 @ v-SLT*/
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            sym13
                            with frame factur .
                 down stream Out-stream 1 with frame factur .
              END.
              run facturxl-write-line-data in this-procedure (
                          input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name                 /*  p-Name     */
                        , input v-uaes-code                                                                   /*  p-UAES     */  
                        , input v-unit-code                                                                   /*  p-OKEI     */
                        , input buf_goods.unit-base                                                           /*  p-EI       */
                        , input string( parts.fact-qnty )                                                     /*  p-qnty     */
                        , input string( v-price-no-VAT )                                                      /*  p-price    */
                        , input (if v-qnty <> 0 then v-sum-no-VAT * parts.fact-qnty / v-qnty else 0 )         /*  p-SumNoVAT */
                        , input " без акциза":U                                                                    /*  p-SumActciz*/
                        , input string( v-VAT-prc )                                                           /*  p-VATpc    */
                        , input ( if v-qnty = 0 then "":U else string( v-VAT * parts.fact-qnty / v-qnty ) )   /*  p-VATsum   */
                        , input string( if v-qnty <> 0 then v-sum * parts.fact-qnty / v-qnty else 0 )         /*  p-sum      */
                        , input v-country-code                                                                /*  p-countrycode  */
                        , input v-country                                                                     /*  p-country  */
                        , input v-GTD                                                                         /*  p-GTD      */
                    ).
              v-lines-counter = v-lines-counter + 1 .
                    /*---E------------- По партиям ---------------------*/
           end.
            /*---E------------- Не печатать признаки ---------------------*/
        end.
        /*---E------------- Не пустая шкала и не от поставщика ---------------------*/
    end.
    else do:
        /*---S------------- Пустая шкала или от поставщика ---------------------*/
       find first bar-code no-lock
               where bar-code.gds-code = buf_goods.gds-code
                and bar-code.unit-cli   = buf_goods.unit-base
                and bar-code.node-code  = rootnode_code
                and bar-code.part-code  = ""
                and bar-code.in-code    = ""
       .
       if CostPrice = yes
       then do:
            /*---S------------------- Счет-фактура от поставщика -----------------*/
          assign v-qnty = doc-line.doc-qnty.

          { str/in-vatp.i calc doc-line. buf_trn-doc. g }
          assign
             v-VAT-prc   = vat-pc-loc
             v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
             v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
             v-tax-price = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
          .
          if v-VAT = ?        then assign v-VAT       = 0.
          if v-SLT = ?        then assign v-SLT       = 0.
          if v-tax-price = ?  then assign v-tax-price = 0.
          assign
             v-price-no-VAT = ( if PrintRubl
                                        then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                        else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc)
          .
          if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          then do:
             assign
                v-price-no-VAT = v-price-no-VAT -
                                   ( if PrintRubl
                                        then ( transport-rubl-loc + other-rubl-loc )
                                         else ( transport-base-loc + other-base-loc ) )
             .
          end.
          if v-r-factur-is-vozvrat-vnesh = yes
          then do:
             assign
                v-price-no-VAT = v-price-no-VAT
                                     - ( if PrintRubl
                                        then ( transport-rubl-loc + other-rubl-loc )
                                        else ( transport-base-loc + other-base-loc ) )
             .
          end.
            /*---E------------------- Счет-фактура от поставщика -----------------*/
       end.
       else do:
            /*---S---------------------- Обычный счет-фактура --------------------*/
          find first gds-dtl no-lock
                 where gds-dtl.doc-code  = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic     = doc-line.artic
                   and gds-dtl.prt-code  = rootnode_code
                   
          .
          assign
             v-qnty = gds-dtl.fact-qnty
          .
          { str/out-vatp.i calc-gds-dtl doc-line. buf_trn-doc. gds-dtl. }
          assign
             v-VAT       = ( if PrintRubl then vat-rubl-buyer        else vat-base-buyer )
             v-SLT       = ( if PrintRubl then slt-rubl-sale         else slt-base-sale )
             v-tax-price = ( if PrintRubl then road-tax-rubl-sale    else road-tax-base-sale )
          .
          if v-VAT = ?        then assign v-VAT       = 0.
          if v-SLT = ?        then assign v-SLT       = 0.
          if v-tax-price = ?  then assign v-tax-price = 0.

          assign
             v-price-no-VAT = ( if PrintRubl
                                   then price-rubl-with-tax-sale
                                   else price-base-with-tax-sale ) - v-VAT - v-SLT - v-tax-price
          .
            /*---E---------------------- Обычный счет-фактура --------------------*/
       end.
       if p-round = 'round':U
       then do:
          run p-fmt-round in this-procedure (
                  input v-qnty
                , input v-price-no-VAT
                , input v-VAT
                , input v-SLT
                , input v-tax-price
                , output v-price-no-VAT
                , output v-void-decimal
                , output v-void-decimal
                , output v-VAT
                , output v-SLT
                , output v-tax
                , output v-sum-no-VAT
                , output v-void-decimal
          ).
/*            assign*/
/*                        v-vat-prc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( round( v-price-no-VAT * v-vat-prc, 2 ) * v-qnty, 2 )*/
/*                        v-SLT               = round( ( v-price-no-VAT * v-qnty + v-VAT ) * v-slt-pc, 2 )*/
/*                        v-sum-no-VAT        = round( v-price-no-VAT * v-qnty, 2 )*/
/*                        v-tax               = round( v-tax-price * v-qnty, 2 )*/
/*            .*/
          assign
             v-sum               = v-sum-no-VAT + v-VAT
          .
       end.        /* p-round = 'round':U */
       else do:
          assign
             v-VAT           = v-VAT * v-qnty
             v-SLT           = v-SLT * v-qnty
             v-sum-no-VAT    = v-price-no-VAT * v-qnty
             v-tax           = v-tax-price * v-qnty
             v-sum           = v-sum-no-VAT + v-VAT
          .
       end.        /* NOT ( p-round = 'round':U ) */
       if buf_goods.gds-type = {&gds-office}
       then do:
            /*---S------------- Услуга ---------------------*/
          if lookup( "dec10", p-mode ) <> 0
          THEN DO:
             display stream Out-stream
                /*sym1*/ gds-str1                                                  @ buf_goods.gds-name
                sym2 "  -   " @ v-uaes-code
                sym16 v-unit-code
                sym14 ( if invers then ("  " + doc-line.unit-cli) else ("  " + buf_goods.unit-base) ) @ buf_goods.unit-base
                sym3 v-qnty
                sym4 v-price-no-VAT
                sym5 v-sum-no-VAT
                sym6 "без акциза" format "x(10)"                                      @ v-sum-actciz
                sym7 v-VAT-prc
                sym8 v-VAT
                sym9 v-sum
/*                  sym10 v-SLT*/
                sym11 v-country-code
                sym15 v-country
                sym12
                /*sym13*/
             with frame factur-10 .
             down stream Out-stream 1 with frame factur-10 .
          END.
          ELSE DO:
             display stream Out-stream
                sym1 gds-str1                                                      @ buf_goods.gds-name
                sym2 "  -   " @ v-uaes-code
                sym16 v-unit-code
                sym14 ( if invers then ("  " + doc-line.unit-cli) else ("  " + buf_goods.unit-base) ) @ buf_goods.unit-base
                sym3 v-qnty
                sym4 v-price-no-VAT
                sym5 v-sum-no-VAT
                sym6 "без акциза" format "x(10)"                                      @ v-sum-actciz
                sym7 v-VAT-prc
                sym8 v-VAT
                sym9 v-sum
/*                  sym10 v-SLT*/
                sym11 v-country-code
                sym15 v-country
                sym12
                sym13
             with frame factur .
             down stream Out-stream 1 with frame factur .
          END.
          run facturxl-write-line-data in this-procedure (
                  input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name        /*  p-Name     */
                , input v-uaes-code                          /*  p-UAES     */  
                , input v-unit-code                          /*  p-OKEI     */
                , input ( if invers then ub.doc-line.unit-cli else buf_goods.unit-base )     /*  p-EI       */
                , input string( v-qnty          )            /*  p-qnty     */
                , input string( v-price-no-VAT  )            /*  p-price    */
                , input string( v-sum-no-VAT    )            /*  p-SumNoVAT */
                , input "без акциза":U                           /*  p-SumActciz*/
                , input string( v-VAT-prc       )            /*  p-VATpc    */
                , input string( v-VAT            )           /*  p-VATsum   */
                , input string( v-sum            )           /*  p-sum      */
                , input v-country-code                       /*  p-countrycode  */
                , input v-country                            /*  p-country  */
                , input "":U                                 /*  p-GTD      */
          ).
          if FullGdsName
             and gds-str1 <> "":U 
          then do :
             run print-more in this-procedure.
          end.
          assign v-lines-counter = v-lines-counter + 1.
            /*---E------------- Услуга ---------------------*/
       end.
       else do:
            /*---S------------- Не услуга ---------------------*/
          define variable v-first-parts   as logical     no-undo.
          assign
             v-first-parts = yes
          .
          block-parts:
          for each parts no-lock
                where parts.out-code = doc-line.doc-code
                and parts.obj-type   = doc-line.obj-type
                and parts.obj-code   = doc-line.obj-code
                and parts.artic      = doc-line.artic
                and parts.prod-type  = doc-line.prod-type
                and parts.prod-code  = doc-line.prod-code
          :
                /*---S------------- Для каждой партии ---------------------*/
              
             assign
                v-GTD       = parts.cst-code
                v-prt-qnty  = parts.fact-qnty
             .
             if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
             then do:
                assign
                   v-prt-qnty  = parts.cli-qnty
                .
             end.
             if available country
                and country.alpha1 = "RU":U
             then do:
                assign
                   v-GTD       = "":U
                   v-country-code   = "":U
                   v-country   = "":U
                .
             end.
             find first buf_parts-attr no-lock
                  where buf_parts-attr.in-code   = parts.in-code
                    and buf_parts-attr.gds-code  = goods.gds-code
                    and buf_parts-attr.part-code = parts.part-code
             no-error .
             if available buf_parts-attr
                 and buf_parts-attr.country-code <> 0
             then do:
                find first buf_country
                      where buf_country.num-code = buf_parts-attr.country-code
                no-error.
                if available buf_country
                      and buf_country.num-code <> country.num-code
                      and buf_country.short-name <> ""
                then do :
                   assign
                      v-country-code = " " + string(buf_country.num-code)
                      v-country = buf_country.short-name
                   .
                   if buf_country.alpha1 = "RU":U
                   then do :
                      assign
                         v-country = "":U
                         v-country-code   = "":U
                         v-GTD     = "":U
                      .
                   end.
                end.
             end.
             if CostPrice = yes
             then do:
/* Если приход, то цену по партиям не осреднять, печатать как есть */
                { str/in-vatp.i calc-parts parts. buf_trn-doc. g }

                assign
                   v-VAT-prc         = vat-pc-loc
                   v-parts-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                   v-parts-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                   v-tax-price       = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
                .
                if v-parts-VAT = ?  then assign v-parts-VAT = 0.
                if v-parts-SLT = ?  then assign v-parts-SLT = 0.
                if v-tax-price = ?  then assign v-tax-price = 0.
                assign
                   v-parts-price-no-VAT    =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                          else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc )
                   v-parts-sum             =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc
                                          else price-base-with-tax-loc ) * v-prt-qnty
                .
                if v-r-factur-is-vozvrat-vnesh = yes
                    or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}

                then do:
                   assign
                      v-parts-price-no-VAT = v-parts-price-no-VAT
                                            - ( if PrintRubl
                                                then ( transport-rubl-loc + other-rubl-loc )
                                                else ( transport-base-loc + other-base-loc ) )
                      v-parts-sum          = v-parts-sum
                                            - ( ( if PrintRubl
                                                  then ( transport-rubl-loc + other-rubl-loc )
                                                  else ( transport-base-loc + other-base-loc ) ) * v-prt-qnty )
                   .
                end.
                if p-round = 'round':U
                then do:
                   if v-first-parts = yes
                   then do:
                      assign
                         v-first-parts   = no
                         v-sum-no-VAT    = 0
                         v-VAT           = 0
                         v-SLT           = 0
                         v-tax           = 0
                         v-sum           = 0
                      .
                   end.
                  
                   run p-fmt-round in this-procedure (
                              input v-prt-qnty
                            , input v-parts-price-no-VAT
                            , input v-parts-VAT
                            , input v-parts-SLT
                            , input v-tax-price
                            , output v-parts-price-no-VAT
                            , output v-parts-VAT
                            , output v-parts-SLT
                            , output v-sum-VAT
                            , output v-sum-SLT
                            , output v-sum-tax
                            , output v-parts-sum-no-VAT
                            , output v-parts-sum
                   ).
/*                        assign*/
/*                            v-vat-prc                = v-parts-VAT / v-parts-price-no-VAT*/
/*                            v-slt-pc                = v-parts-SLT / ( v-parts-price-no-VAT + v-parts-VAT )*/
/*                            v-parts-price-no-VAT    = round( v-parts-price-no-VAT, 2 )*/
/*                            v-parts-VAT             = round( v-parts-price-no-VAT * v-vat-prc, 2 )*/
/*                            v-parts-SLT             = round( ( v-parts-price-no-VAT * v-prt-qnty + v-parts-VAT ) * v-slt-pc, 2 )*/
/*                            v-parts-sum             = round( ( v-parts-price-no-VAT + v-parts-VAT + v-parts-SLT*/
/*                                                                + ( if PrintRubl*/
/*                                                                    then road-tax-rubl-loc*/
/*                                                                    else road-tax-base-loc )*/
/*                                                             ) * v-prt-qnty, 2 )*/
/*                        .*/
                assign
                      v-sum-no-VAT    = v-sum-no-VAT  + v-parts-sum-no-VAT
                      v-VAT           = v-VAT         + v-sum-VAT
                      v-SLT           = v-SLT         + v-sum-SLT
                      v-tax           = v-tax         + v-sum-tax
                      v-sum           = v-sum         + v-parts-sum
                   .
                end.        /* p-round = 'round':U */
                
                
                if lookup( "dec10", p-mode ) <> 0
                THEN DO:
                   if invers 
                   then do :   /*в единицах поставщика */
                      display stream Out-stream
                            /*sym1*/ gds-str1                                                       @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 ub.doc-line.unit-cli                                               @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty                  @ v-price-no-VAT
                            sym5 v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty     @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100  when v-qnty <> 0   @ v-VAT
                            sym9 ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )
                            + ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            /*sym13*/
                      with frame factur-10 .
                      down stream Out-stream 1 with frame factur-10 .

                   end.  /*в единицах поставщика */
                   else do :
                      display stream Out-stream
                            /*sym1*/ gds-str1                                                       @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 buf_goods.unit-base                                                @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-parts-price-no-VAT                                               @ v-price-no-VAT
                            sym5 v-parts-price-no-VAT * v-prt-qnty                                  @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-parts-VAT * v-prt-qnty                                           @ v-VAT
                            sym9 v-parts-sum                                                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            /*sym13*/
                      with frame factur-10 .
                      down stream Out-stream 1 with frame factur-10 .
                   end.
                END.
                ELSE DO:
                   if invers then do :  /*в единицах поставщика */
                      display stream Out-stream
                            sym1 gds-str1                                                           @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 doc-line.unit-cli                                                  @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty                  @ v-price-no-VAT
                            sym5 v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty     @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100  when v-qnty <> 0   @ v-VAT
                            sym9 ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )
                            + ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            sym13
                      with frame factur .
                      down stream Out-stream 1 with frame factur .
                   end.  /*в единицах поставщика */
                   else do :
                      display stream Out-stream
                            sym1 gds-str1                                                           @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 buf_goods.unit-base                                                @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-parts-price-no-VAT                                               @ v-price-no-VAT
                            sym5 v-parts-price-no-VAT * v-prt-qnty                                  @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-parts-VAT * v-prt-qnty                                           @ v-VAT
                            sym9 v-parts-sum                                                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            sym13
                      with frame factur .
                      down stream Out-stream 1 with frame factur .
                   end.
                END.
                if invers then do : /*в единицах поставщика */
                   run facturxl-write-line-data in this-procedure (
                              input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name                /*  p-Name     */
                            , input v-uaes-code                                                                  /*  p-UAES     */  
                            , input v-unit-code                                                                  /*  p-OKEI     */
                            , input ( doc-line.unit-cli )                                                        /*  p-EI       */
                            , input string( v-prt-qnty                        )                                  /*  p-qnty     */
                            , input string( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty )                  /*  p-price    */
                            , input string( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )     /*  p-SumNoVAT */
                            , input " без акциза":U                                                                   /*  p-SumActciz*/
                            , input string( v-VAT-prc          )                                                 /*  p-VATpc    */
                            , input ( if v-prt-qnty = 0 or v-qnty = 0 then "":U                                  /*  p-VATsum   */
                            else string( ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100 ) )
                            , input ( if v-prt-qnty = 0 or v-qnty = 0 then "":U                                  /*  p-sum      */
                            else string( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty + ( v-parts-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100 ) )
                            , input v-country-code                                                               /*  p-countrycode  */
                            , input v-country                                                                    /*  p-country  */
                            , input v-GTD                                                                        /*  p-GTD      */
                   ).
                end.    /*в единицах поставщика */
                else do :
                   run facturxl-write-line-data in this-procedure (
                          input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name        /*  p-Name     */
                        , input v-uaes-code                                     /*  p-UAES     */  
                        , input v-unit-code                                     /*  p-OKEI     */
                        , input ( buf_goods.unit-base )                         /*  p-EI       */
                        , input string( v-prt-qnty                        )     /*  p-qnty     */
                        , input string( v-parts-price-no-VAT              )     /*  p-price    */
                        , input string( v-parts-price-no-VAT * v-prt-qnty )     /*  p-SumNoVAT */
                        , input " без акциза":U                                      /*  p-SumActciz*/
                        , input string( v-VAT-prc          )                    /*  p-VATpc    */
                        , input ( if v-qnty = 0 then "":U else string( v-parts-VAT * v-prt-qnty ) )  /*  p-VATsum   */
                        , input string( v-parts-sum              )              /*  p-sum      */
                        , input v-country-code                                  /*  p-countrycode  */
                        , input v-country                                       /*  p-country  */
                        , input v-GTD                                           /*  p-GTD      */
                   ).
                end.
             end. 
             else do:
 
                if v-first-parts = yes
                then do:
                   v-first-parts   = no.
                end.
                else do:
                   if     not invers                       /* не в ед. поставщика */
                  /* то нам нужна только первая строка  чтобы просто вывести информацию, все остальные это дубль */
                   then
                      leave block-parts.
                end.
                
                if lookup( "dec10", p-mode ) <> 0
                THEN DO:
                   if invers then do :   /*в единицах поставщика */
                      display stream Out-stream
                            /*sym1*/ gds-str1                                                       @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 doc-line.unit-cli                                                  @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-price-no-VAT * v-qnty / doc-line.cli-qnty                        @ v-price-no-VAT
                            sym5 v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty           @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100  when v-qnty <> 0   @ v-VAT
                            sym9 ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )
                            + ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            /*sym13*/
                      with frame factur-10 .
                      down stream Out-stream 1 with frame factur-10 .

                   end.  /*в единицах поставщика */
                   else do :
                      display stream Out-stream
                            /*sym1*/ gds-str1                                                       @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 buf_goods.unit-base                                                @ buf_goods.unit-base
                            sym3 v-qnty                                                             @ v-qnty
                            sym4 v-price-no-VAT                                                     @ v-price-no-VAT
                            sym5 v-price-no-VAT * v-qnty                                            @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-VAT                                                              @ v-VAT
                            sym9 v-price-no-VAT * v-qnty + v-VAT                                    @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            /*sym13*/
                      with frame factur-10 .
                      down stream Out-stream 1 with frame factur-10 .
                   end.
                END.
                ELSE DO:
                   if invers then do :   /*в единицах поставщика */
                      display stream Out-stream
                            sym1 gds-str1                                                           @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 doc-line.unit-cli                                                  @ buf_goods.unit-base
                            sym3 v-prt-qnty                                                         @ v-qnty
                            sym4 v-price-no-VAT * v-qnty / ub.doc-line.cli-qnty                     @ v-price-no-VAT
                            sym5 v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty           @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100  when v-qnty <> 0   @ v-VAT
                            sym9 ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )
                            + ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100                        @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            sym13
                      with frame factur .
                      down stream Out-stream 1 with frame factur .
                   end.  /*в единицах поставщика */
                   else do :
/* -------------------------------------------------------                       c*/
                      
                      display stream Out-stream
                            sym1 gds-str1                                                           @ buf_goods.gds-name
                            sym2 "  -   " @ v-uaes-code
                            sym16 v-unit-code
                            sym14 buf_goods.unit-base                                                @ buf_goods.unit-base
                            sym3 v-qnty                                                             @ v-qnty
                            sym4 v-price-no-VAT                                                     @ v-price-no-VAT
                            sym5 v-price-no-VAT * v-qnty                                            @ v-sum-no-VAT
                            sym6 "без акциза" format "x(10)"                                           @ v-sum-actciz
                            sym7 v-VAT-prc
                            sym8 v-VAT                                                              @ v-VAT
                            sym9 v-price-no-VAT * v-qnty + v-VAT                                    @ v-sum
                            sym11 v-country-code
                            sym15 v-country
                            sym12 v-GTD
                            sym13
                      with frame factur .
                      down stream Out-stream 1 with frame factur .
                     
                   end.
                END.
                if invers then do : /*в единицах поставщика */
                   run facturxl-write-line-data in this-procedure (
                              input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name                /*  p-Name     */
                            , input v-uaes-code                                                                  /*  p-UAES     */  
                            , input v-unit-code                                                                  /*  p-OKEI     */
                            , input ( doc-line.unit-cli )                                                        /*  p-EI       */
                            , input string( v-prt-qnty                        )                                  /*  p-qnty     */
                            , input string( v-price-no-VAT * v-qnty / doc-line.cli-qnty )                        /*  p-price    */
                            , input string( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty )           /*  p-SumNoVAT */
                            , input " без акциза":U                                                                   /*  p-SumActciz*/
                            , input string( v-VAT-prc          )                                                 /*  p-VATpc    */
                            , input ( if v-prt-qnty = 0 or v-qnty = 0 then "":U                                  /*  p-VATsum   */
                            else string( ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100 ) )
                            , input ( if v-prt-qnty = 0 or v-qnty = 0 then "":U                                  /*  p-sum      */
                            else string( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty + ( v-price-no-VAT * v-qnty / doc-line.cli-qnty * v-prt-qnty ) * v-VAT-prc / 100 ) )
                            , input v-country-code                                                               /*  p-countrycode  */
                            , input v-country                                                                    /*  p-country  */
                            , input v-GTD                                                                        /*  p-GTD      */
                   ).
                end.  /*в единицах поставщика */
                else do :
                   run facturxl-write-line-data in this-procedure (
                              input (if rep-artic then (string( buf_goods.artic, "x(16)" ) + " ") else "") + buf_goods.gds-name         /*  p-Name     */
                            , input v-uaes-code                                                           /*  p-UAES     */  
                            , input v-unit-code                                                           /*  p-OKEI     */
                            , input ( buf_goods.unit-base )                                               /*  p-EI       */
                            , input string( v-qnty )                                                      /*  p-qnty     */
                            , input string( v-price-no-VAT              )                                 /*  p-price    */
                            , input string( v-price-no-VAT * v-qnty )                                     /*  p-SumNoVAT */
                            , input "без акциза":U                                                        /*  p-SumActciz*/
                            , input string( v-VAT-prc          )                                          /*  p-VATpc    */
                            , input string( v-VAT )                                                       /*  p-VATsum   */
                            , input string( ( v-price-no-VAT * v-qnty ) + v-VAT )                         /*  p-sum      */
                            , input v-country-code                                                        /*  p-countrycode  */
                            , input v-country                                                             /*  p-country  */
                            , input v-GTD                                                                 /*  p-GTD      */
                   ).
                end.
             end.
             if FullGdsName
                and gds-str1 <> "":U 
             then do :
                run print-more in this-procedure.
             end.

             run print-tax in this-procedure (
                    input recid( buf_goods )
             ).
             assign v-lines-counter = v-lines-counter + 1.
                /*---E------------- Для каждой партии ---------------------*/
          end.
            /*---E------------- Не услуга ---------------------*/
       end.
        /*---E------------- Пустая шкала или от поставщика ---------------------*/
    end.
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
    define variable v-curr-name      as character           no-undo.
    define variable v-base-name      as character           no-undo.
    define variable v-base-abbr      as character           no-undo.
    define variable v-rubl-name      as character           no-undo.
    define variable t-currency       as character           no-undo.  
    define variable v-idContr        as character           no-undo. 
    define variable v-attr-type      as character           no-undo.  

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_currency      for ub.currency.

do
for buf_trn-doc
  , buf_currency
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-firm} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
    end.
    if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .


    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input no
        , input yes
    ).
    { gbl/objat.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        "'doc-prt=request'"
        v-obj-prt-on
    }
    if v-obj-prt-on = no
    or invers
    then do:
        assign
            PrintScale = no
        .
    end.
    find first buf_currency no-lock
         where buf_currency.curr-code = buf_trn-doc.exch-code
    .
    assign
        p-curr-abbr = buf_currency.curr-abbr
        v-curr-name = buf_currency.curr-name + ", код " + string(buf_currency.okv-code)
    .
    define variable v-base-code as integer   no-undo .
    { gbl/basecode.i
      v-cntxt-host-code-obj
      v-base-code
    }
    find first buf_currency no-lock
         where buf_currency.curr-code = v-base-code
    .
    assign
        v-base-name = buf_currency.curr-name + ", код " + string(buf_currency.okv-code)
        v-base-abbr = buf_currency.curr-abbr
    .
    find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        v-rubl-name = buf_currency.curr-name + ", код " + string(buf_currency.okv-code)
    .

    assign
        t-num = substitute( "&1         от &2 &3"
                        , v-torgconf-doc-code
                        , v-torgconf-doc-date
                        , ( if buf_trn-doc.status_ <> {&fact}
                            then string( "(" + caps( buf_trn-doc.status_ ) + ")" )
                            else "":U )
                )
    .
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-supplier-inn, ( if ((v-torgconf-supplier-kpp = "":U) AND (v-torgconf-supplier-inn = "":U)) then "":U else "/":U ), v-torgconf-supplier-kpp )
    .
    if v-torgconf-outappr = yes
    then do:
      put stream Out-stream
          space(108) "                                                                           Приложение № 1" skip
          space(108) "                                                            к постановлению Правительства" skip
          space(108) "                                                                     Российской Федерации" skip
          space(108) "                                                                     от 26.12.2011 № 1137" skip
          space(108) "                              (в ред. Постановления Правительства РФ от 19.08.2017 № 981)" skip
      .
    END.
    put stream Out-stream
        space(25) string( "СЧЕТ-ФАКТУРА N" + ( if p-round = 'round':U then ":" else " " ) + t-num ) format "X(190)" skip
        space(23) 'ИСПРАВЛЕНИЕ N   -   от " - "    -   '
        skip(1) space(5) string( "Продавец" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 31 ) + v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name )) format "X(190)"
        skip    space(5) string( "Адрес"    + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-supplier-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + ( if p-round = 'round':U then ":" else " " ) + t-inn ) format "X(190)"
    .

    /* вывод на экран грузоотправителя*/

   if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
   else if buf_trn-doc.doc-type <> {&income}
   and ( not invers )
   and buf_trn-doc.office = no
   and v-torgconf-outobj = no
   and v-torgconf-outasend = no
   and v-torgconf-outsend = no
   then v-out-name = "Он же".
   else
   v-out-name =  v-torgconf-cargo-from-sf-value.

      run facturxl-write-cell-data in this-procedure (
           input {&facturxl-h_cargoFrom}
         , input v-out-name
         ) .
      if LENGTH(v-out-name) > 145
         then do:
            put stream Out-stream
               skip    space(5) string( "Грузоотправитель и его адрес"
                                    + ( if p-round = 'round':U then ":" else " " )
                                    + fill( " ", 11 )
                                    + ( if buf_trn-doc.office = yes
                                          then "---"
                                          else SUBSTRING(v-out-name,1,145))) format "X(190)"
               skip    space(45) SUBSTRING(v-out-name,146) format "X(145)" skip
            .
         end.
         else do:
            put stream Out-stream
               skip    space(5) string( "Грузоотправитель и его адрес"
                                       + ( if p-round = 'round':U then ":" else " " )
                                       + fill( " ", 11 )
                                       + ( if buf_trn-doc.office = yes
                                             then "---"
                                             else v-out-name)) format "X(190)" skip
            .
         end.
         
    { str/tdat-val.i p-doc-code {&trdcattr-idCountryContr} v-idContr v-attr-type no-error }     

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
        , input v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name )
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_supplierAddr}
        , input v-torgconf-supplier-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_supplierINN}
        , input t-inn
    ).
    run facturxl-write-cell-data in this-procedure (                                
          input {&facturxl-h_idContract}
        , input v-idContr
    ).    
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-saler-inn, ( if v-torgconf-saler-kpp = "":U then "":U else "/":U ), v-torgconf-saler-kpp )
    .
    if lookup( "GreenL", p-mode ) <> 0
    then do:
        assign
            v-plat-rasch-doc    = "":U
        .
    end.
    else do:
        assign
            v-plat-rasch-doc    = " N ":U + ( if p-round = 'round':U then ": ":U else " ":U ) + fill( " ", 6 ) + v-torgconf-plat-rasch-doc
        .
    end.
      /* Вывод на экран грузополучателя */
      if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
      else if     buf_trn-doc.doc-type <> {&income}
            and buf_trn-doc.doc-type <> {&return}
      then v-out-name =  v-torgconf-consignee.
      else v-out-name =  v-torgconf-cargo-to-value .

      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-h_cargoTo}
            , input v-out-name
      ).
      if LENGTH(v-out-name) > 145
      then do:
         put stream Out-stream
            space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + SUBSTRING(v-out-name,1,145))   format "X(190)"
            skip space(45) SUBSTRING(v-out-name,146) format "X(145)"
         .
      end.
      else do:
         put stream Out-stream
            space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + v-out-name)   format "X(190)"
         .
      end.
     put stream Out-stream
        /*space(5) string( "Грузополучатель и его адрес"
                        + ( if p-round = 'round':U
                            then ": "
                            else " " )
                        + fill( " ", 12 )
                        + v-torgconf-consignee )   format "X(190)"*/
        skip    space(5) string( "К платежно-расчетному документу" + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 29 ) + v-torgconf-saler-name +
                                                if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-saler-code )
                                                else "":U  ) format "X(190)"
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
        , input v-torgconf-saler-name + if v-torgconf-outprncd = yes
                                        then substitute( " (&1)", v-torgconf-saler-code )
                                        else "":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_salerAddr}
        , input v-torgconf-saler-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_salerINN}
        , input t-inn
    ).
    assign
        t-currency = ( trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) )
    .
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_currency}
        , input t-currency
    ).
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
        put stream Out-stream
            space(10) "Возврат товара поставщику." format "X(120)" skip
        .
    end.
    if v-torgconf-outrubl = no
    then do:
        put stream Out-stream
        space(5)  /*  space(10)    */
            string( "Валюта:  " +
            trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) ) format "X(120)" skip
        .
    end.

    put stream Out-stream
        space(5)  
        "Идентификатор государственного контракта, договора (соглашения) (при наличии): "                                                                       
         /*skip  space(5)*/ 
         + trim(v-idContr) format "X(120)" "(8)" at 196 skip(0)
    .
    

    if v-torgconf-outprim = no
    then do:
        put stream Out-stream
            skip space(10)
            ( if not( buf_trn-doc.PS begins "@" )
            then string( "Примечание : " + substr( buf_trn-doc.PS, 1, 120 ) )
            else ""
            ) format "X(120)"
        .
    end.
/*    put stream Out-stream
        skip
    .*/
end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-footer :
define input parameter p-doc-code   as character    no-undo.
define input parameter p-curr-abbr  as character    no-undo.

define variable v-base-code as integer     no-undo .
define variable v-base-abbr as character   no-undo .

define buffer buf_trn-doc       for trn-doc.
define buffer buf_currency      for ub.currency.

do
for buf_trn-doc
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    IF LOOKUP( "dec10", p-mode ) <> 0
    THEN DO:
        put stream Out-stream
            v-single-line format "X(232)"
        /* skip */
        .
    end.
    ELSE DO:
        put stream Out-stream
            v-single-line format "X(199)"
        /* skip */
        .
    end.
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream Out-stream.
    end.
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-it_SumNoVAT}
        , input string( v-tot-sum-no-VAT )
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-it_VATsum}
        , input string( v-tot-VAT )
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-it_sum}
        , input string( v-tot-sum )
    ).
    if lookup( "dec10", p-mode ) <> 0
    THEN DO:
      display stream Out-stream
          "Всего к оплате"  @ buf_goods.gds-name
      /*    ( accum total v-sum-no-VAT ) @ v-sum-no-VAT*/
      /*    ( accum total v-VAT ) @ v-VAT*/
      /*    ( accum total v-sum ) @ v-sum*/
          v-tot-sum-no-VAT  @ v-sum-no-VAT
          v-tot-VAT         @ v-VAT
          v-tot-sum         @ v-sum
      with frame factur-10 .
      down stream Out-stream 2 with frame factur-10 .
    END.
    ELSE DO:
      display stream Out-stream
          "Всего к оплате"  @ buf_goods.gds-name
      /*    ( accum total v-sum-no-VAT ) @ v-sum-no-VAT*/
      /*    ( accum total v-VAT ) @ v-VAT*/
      /*    ( accum total v-sum ) @ v-sum*/
          v-tot-sum-no-VAT  @ v-sum-no-VAT
          v-tot-VAT         @ v-VAT
          v-tot-sum         @ v-sum
      with frame factur .
      down stream Out-stream with frame factur .
    END.

    run print-vat-itog-by-perc in this-procedure .

    { gbl/basecode.i
      v-cntxt-host-code-obj
      v-base-code
    }
    find first buf_currency no-lock
         where buf_currency.curr-code = v-base-code
    .
    assign
        v-base-abbr = buf_currency.curr-abbr
    .

    if lookup( "dec10", p-mode ) <> 0
    then do:
      if abs( v-tot-SLT ) >= 0.005
      or ( not invers and abs( buf_trn-doc.discnt-rubl ) >= 0.005 )
      then do:
         put stream Out-stream
               space(5) "Итого по документу: "
               trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.9999999999" ) )
               + " ("
               + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
               + ")"
                                                                           format "X(120)"     at {&footer-tab-stop1}
         .
         if v-tot-SLT <> 0 and p-no-slt = false
         then do:

               put stream Out-stream
                  skip space(10) "Налог с продаж: "
                           trim( string( v-tot-SLT, "->>>,>>9.9999999999" ) )
                           + " ("
                           + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) )
                           + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
               .
         end.
         if buf_trn-doc.discnt-rubl <> 0
         and not invers
         and v-torgconf-outdisc = no
         then do:
               put stream Out-stream
                  skip space(14) "Скидка:"
                           trim( string( ( if PrintRubl
                                          then buf_trn-doc.discnt-rubl
                                          else buf_trn-doc.tot-calc ), "->>>,>>>,>>>,>>9.9999999999" ) )
                           + " ("
                           + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) )
                           + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
               .
         end.
      end.
      if v-tot-tax <> 0
      then do:
         put stream Out-stream
               skip space(10)  v-tax-name + ": "                                   format "X(20)"
                  trim( string( v-tot-tax, "->>>,>>>,>>>,>>9.9999999999" ) )
                  + " ("
                  + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                  + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
         .
      end.
      put stream Out-stream
         skip space(5) "Итого к оплате: "
                           string( trim( string( v-tot-sum + v-tot-SLT, "->,>>>,>>>,>>>,>>>,>>9.9999999999" ) )
                           + " ("
                           + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                           + ")" )
                                                                           format "X(150)"     at {&footer-tab-stop1}
      .
      if PrintRubl
      and v-torgconf-outprops = yes
      then do:        /* Если в р_у_блях, то сумму прописью */
         run rep/wp-rub.p (
               input v-tot-sum + v-tot-SLT
               , output v-propis
               , output v-propis-cop
         ).
         put stream out-stream
               skip space(25) v-propis
                                                                              format "X(150)"  at {&footer-tab-stop1}
               skip(1)
         .
      end.
    end. /* dec10 */
    else do:
      if abs( v-tot-SLT ) >= 0.005
      or ( not invers and abs( buf_trn-doc.discnt-rubl ) >= 0.005 )
      then do:
         put stream Out-stream
               space(5) "Итого по документу: "
               trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
               + " ("
               + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
               + ")"
                                                                           format "X(120)"     at {&footer-tab-stop1}
         .
         if v-tot-SLT <> 0 and p-no-slt = false
         then do:

               put stream Out-stream
                  skip space(10) "Налог с продаж: "
                           trim( string( v-tot-SLT, "->>>,>>9.99" ) )
                           + " ("
                           + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) )
                           + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
               .
         end.
         if buf_trn-doc.discnt-rubl <> 0
         and not invers
         and v-torgconf-outdisc = no
         then do:
               put stream Out-stream
                  skip space(14) "Скидка:"
                           trim( string( ( if PrintRubl
                                          then buf_trn-doc.discnt-rubl
                                          else buf_trn-doc.tot-calc ), "->>>,>>>,>>>,>>9.99" ) )
                           + " ("
                           + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) )
                           + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
               .
         end.
      end.
      if v-tot-tax <> 0
      then do:
         put stream Out-stream
               skip space(10)  v-tax-name + ": "                                   format "X(20)"
                  trim( string( v-tot-tax, "->>>,>>>,>>>,>>9.99" ) )
                  + " ("
                  + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                  + ")"
                                                                           format "X(150)"     at {&footer-tab-stop1}
         .
      end.
      put stream Out-stream
         skip space(5) "Итого к оплате: "
                           string( trim( string( v-tot-sum + v-tot-SLT, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
                           + " ("
                           + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then p-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                           + ")" )
                                                                           format "X(150)"     at {&footer-tab-stop1}
      .
      if PrintRubl
      and v-torgconf-outprops = yes
      then do:        /* Если в р_у_блях, то сумму прописью */
         run rep/wp-rub.p (
               input v-tot-sum + v-tot-SLT
               , output v-propis
               , output v-propis-cop
         ).
         put stream out-stream
               skip space(25) v-propis
                                                                              format "X(150)"  at {&footer-tab-stop1}
               skip(1)
         .
       run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_summ_prop}
        , input v-propis
       ).

      end.
    end.
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

/*        put stream Out-stream
            skip(2) space(10) "Руководитель организации   " format "X(28)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(36)" "/"
            "          Гл. бухгалтер   " format "X(25)"fill( "_", 25 ) format "X(25)" "    /" v-torgconf-main-buh format "X(36)" "/"
            skip space(45) "(подпись)" space(30) "(Ф.И.О)"  space(47) "(подпись)" space(30) "(Ф.И.О)"
        .     */
        put stream Out-stream
            skip(2) space(10) "Руководитель организации" format "X(25)" space(75)
            "Главный бухгалтер" format "X(25)" skip
            space(10) "или иное уполномоченное  " format "X(25)" space(75)
            "или иное уполномоченное  " format "X(25)" skip
            space(10) "лицо" format "X(25)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(33)" "/"
            space(10) "лицо" format "X(25)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-buh format "X(31)" "/"
            skip space(43) "(подпись)" space(27) "(Ф.И.О)"  space(57) "(подпись)" space(27) "(Ф.И.О)"
        .
    if v-torgconf-outegrp = no
    then do :
      if trim(v-torgconf-self-host-name) = "":U
      then do:
          v-torgconf-self-host-name = fill("_", 42).
      end.
      if v-torgconf-self-host-egrip-date <> "":U
       or v-torgconf-self-host-egrip-num  <> "":U
       then do:
          put stream Out-stream
              skip (1) space(10) "Индивидуальный предприниматель"
              skip (0) space(10) substitute( "или иное уполномоченное лицо     &1  / &2 / ЕГРИП N &3 от &4 ", fill( "_", 26 ) , string(v-torgconf-self-host-name, "x(42)") , v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date ) format "X(174)"

              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
          run facturxl-write-cell-data in this-procedure (
                input {&facturxl-f_ownerName}
              , input string(v-torgconf-self-host-name, "x(42)")
          ).
          run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_ownerReg}
            , input substitute ("N &1 от &2 ", v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date )
          ).
      end.
      else do :
          put stream Out-stream
              skip (1) space(10) "Индивидуальный предприниматель"
              skip (0) space(10) substitute( "или иное уполномоченное лицо     &1  / &2 /  &3  ", fill( "_", 26 ) , fill("_", 42) , fill( "_", 50 ) ) format "X(174)"

              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
      end.
    end.
    put stream Out-stream  skip "Примечание. Первый экземпляр - покупателю, второй экземпляр - продавцу"   format "X(90)"
    skip
    .

end.
end procedure. /* print-footer */

/*==========================================================================*/
procedure print-line-po :

do
on error undo, return error
:
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
        Gds-str1 = breakstr(gds-prop.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
    do while trim(gds-str2) <> ""
    :
        assign
            gds-str = gds-str2
            gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2)
        .
    end.
    assign
        gds-str1 = breakstr(gds-prop.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
    if gds-prop.gds-type = {&gds-office}
    then do:        /*---S------------- Услуга ---------------------*/
        if lookup( "dec10", p-mode ) <> 0
        THEN DO:
          display stream Out-stream
            /*sym1*/  gds-str1              @ buf_goods.gds-name
            sym2  "  -   "                  @ v-uaes-code
            sym16 gds-prop.unit-code        @ v-unit-code
            sym14 gds-prop.unit-base        @ buf_goods.unit-base
            sym3  gds-prop.qnty             @ v-qnty
            sym4  gds-prop.price-no-VAT     @ v-price-no-vat
            sym5  gds-prop.sum-no-VAT       @ v-sum-no-vat
            sym6  "без акциза" format "x(10)"  @ v-sum-actciz
            sym7  gds-prop.Vat-pc           @ v-VAT-prc
            sym8  gds-prop.VAT              @ v-vat
            sym9  gds-prop.sum              @ v-sum
            sym11 gds-prop.country-code     @ v-country-code
            sym15 gds-prop.country          @ v-country
            sym12
            /*sym13*/
          with frame factur-10 .
          down stream Out-stream 1 with frame factur-10 .
        END.
        ELSE DO:
          display stream Out-stream
            sym1  gds-str1                  @ buf_goods.gds-name
            sym2  "  -   "                  @ v-uaes-code
            sym16 gds-prop.unit-code        @ v-unit-code
            sym14 gds-prop.unit-base        @ buf_goods.unit-base
            sym3  gds-prop.qnty             @ v-qnty
            sym4  gds-prop.price-no-VAT     @ v-price-no-vat
            sym5  gds-prop.sum-no-VAT       @ v-sum-no-vat
            sym6  "без акциза" format "x(10)"  @ v-sum-actciz
            sym7  gds-prop.Vat-pc           @ v-VAT-prc
            sym8  gds-prop.VAT              @ v-vat
            sym9  gds-prop.sum              @ v-sum
            sym11 gds-prop.country-code     @ v-country-code
            sym15 gds-prop.country          @ v-country
            sym12
            sym13
          with frame factur .
          down stream Out-stream 1 with frame factur .
        END.
        if FullGdsName
        and gds-str1 <> "":U then do :
          run print-more-po in this-procedure.
        end.
        assign
            v-lines-counter = v-lines-counter + 1
        .
    end.
    else do:        /*---S------------- Не услуга ---------------------*/
        if lookup( "dec10", p-mode ) <> 0
        THEN DO:
          display stream Out-stream
            /*sym1*/  gds-str1              @ buf_goods.gds-name
            sym2  "  -   "                  @ v-uaes-code
            sym16 gds-prop.unit-code        @ v-unit-code
            sym14 gds-prop.unit-base        @ buf_goods.unit-base
            sym3  gds-prop.qnty             @ v-qnty
            sym4  gds-prop.price-no-VAT     @ v-price-no-vat
            sym5  gds-prop.sum-no-VAT       @ v-sum-no-vat
            sym6  "без акциза" format "x(10)"  @ v-sum-actciz
            sym7  gds-prop.Vat-pc           @ v-VAT-prc
            sym8  gds-prop.VAT              @ v-vat
            sym9  gds-prop.sum              @ v-sum
            sym11 gds-prop.country-code     @ v-country-code
            sym15 gds-prop.country          @ v-country
            sym12 gds-prop.GTD              @ v-gtd
            /*sym13*/
          with frame factur-10 .
          down stream Out-stream 1 with frame factur-10 .
        END.
        ELSE DO:
          display stream Out-stream
            sym1  gds-str1                  @ buf_goods.gds-name
            sym2  "  -   "                  @ v-uaes-code
            sym16 gds-prop.unit-code        @ v-unit-code
            sym14 gds-prop.unit-base        @ buf_goods.unit-base
            sym3  gds-prop.qnty             @ v-qnty
            sym4  gds-prop.price-no-VAT     @ v-price-no-vat
            sym5  gds-prop.sum-no-VAT       @ v-sum-no-vat
            sym6  "без акциза" format "x(10)"  @ v-sum-actciz
            sym7  gds-prop.Vat-pc           @ v-VAT-prc
            sym8  gds-prop.VAT              @ v-vat
            sym9  gds-prop.sum              @ v-sum
            sym11 gds-prop.country-code     @ v-country-code
            sym15 gds-prop.country          @ v-country
            sym12 gds-prop.GTD              @ v-gtd
            sym13
          with frame factur .
          down stream Out-stream 1 with frame factur .
        END.
        if FullGdsName
        and gds-str1 <> "":U then do :
          run print-more-po in this-procedure.
        end.
        assign
            v-lines-counter = v-lines-counter + 1
        .
    end.
    /*---E------------- Пустая шкала или от поставщика ---------------------*/
    assign
        v-tot-sum-no-VAT    = v-tot-sum-no-VAT  + gds-prop.sum-no-VAT
        v-tot-VAT           = v-tot-VAT         + gds-prop.VAT
        v-tot-sum           = v-tot-sum         + gds-prop.sum
    .
end.
end procedure. /* print-line-po */

/*===============================================================================================*/
procedure print-more-po:
  do on error undo, return error :
    def var v-start-string as character no-undo.
    def var v-add-string as character no-undo.
    assign v-start-string = gds-str2 .

    do while trim(v-start-string) <> ""
    :
        assign
            gds-str         = v-start-string
            v-add-string    = breakstr( gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string )
        .
        if lookup( "dec10", p-mode ) <> 0
        THEN DO:
          display stream Out-stream
            /*sym1*/
            ((if rep-artic then fill(" ",17) else "") + v-add-string)     @ buf_goods.gds-name
            sym16 sym14 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 /*sym10*/ sym11 sym15 sym12 /*sym13*/
          with frame factur-10 .
          down stream Out-stream 1 with frame factur-10 .
        END.
        ELSE DO:
          display stream Out-stream
            sym1
            ((if rep-artic then fill(" ",17) else "") + v-add-string)     @ buf_goods.gds-name
            sym16 sym14 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 /*sym10*/ sym11 sym15 sym12 sym13
          with frame factur .
          down stream Out-stream 1 with frame factur .
        END.
    end. /* DO WHILE ... */
  end.
end procedure.

/*==========================================================================*/
procedure print-tax :
define input parameter p-goods-recid    as recid        no-undo.

define buffer buf_tax_goods     for ub.goods.
do
on error undo, return error
:
    find first buf_tax_goods no-lock
        where recid( buf_tax_goods ) = p-goods-recid
    .
    if hvrdtax( p-goods-recid )
    then do:        /* Третий налог выводится отдельной строкой */
            run tax-name (
                  input {&road-tax}
                , output v-tax-name
            ).
            if lookup( "dec10", p-mode ) <> 0
            THEN DO:
              display stream out-stream
                ( fill(" ", 19) + v-tax-name )                                            @ buf_goods.gds-name
                v-prt-qnty                                                                @ v-qnty
                ( if PrintRubl then ub.parts.road-tax-rubl else ub.parts.road-tax-base )  @ v-price-no-VAT
                ( if PrintRubl then ub.parts.road-tax-rubl * v-{2}qnty else ub.parts.road-tax-base * v-{2}qnty )
                                                                                          @ v-sum-no-VAT
                "без акциза" format "x(10)"                                                    @ v-sum-actciz
                0                                                                         @ v-VAT
                ( if PrintRubl then ub.parts.road-tax-rubl * v-{2}qnty else ub.parts.road-tax-base * v-{2}qnty )
                                                                                          @ v-sum
                /*sym1*/ sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym11 /*sym13*/
              with frame factur-10.
              down stream out-stream 1 with frame factur-10.
            END.
            ELSE DO:
              display stream out-stream
                ( fill(" ", 19) + v-tax-name )                                            @ buf_goods.gds-name
                v-prt-qnty                                                                @ v-qnty
                ( if PrintRubl then ub.parts.road-tax-rubl else ub.parts.road-tax-base )  @ v-price-no-VAT
                ( if PrintRubl then ub.parts.road-tax-rubl * v-{2}qnty else ub.parts.road-tax-base * v-{2}qnty )
                                                                                          @ v-sum-no-VAT
                "без акциза" format "x(10)"                                                    @ v-sum-actciz
                0                                                                         @ v-VAT
                ( if PrintRubl then ub.parts.road-tax-rubl * v-{2}qnty else ub.parts.road-tax-base * v-{2}qnty )
                                                                                          @ v-sum
                sym1 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym11 sym13
              with frame factur.
              down stream out-stream 1 with frame factur.
            END.
            assign
                v-lines-counter = v-lines-counter   + 1
            .
    end.
    else do:
        if v-tax-price <> 0
        then do:
            message
                "Значение третьего налога (стеклопосуда) в документе отлично от нуля для товара " + buf_tax_goods.artic
                + ", хотя для этого товара система не позволяет задать третий налог. Возможны ошибки в накладной"
            view-as alert-box error.
        end.
    end.
end.
end procedure. /* print-tax */

procedure print-vat-itog-by-perc :
/* ====== ИТОГИ С РАЗБИВКОЙ НАЛОГОВ ====== */
  define buffer buf_doc-line for ub.doc-line.

  define variable stoim        as  decimal     no-undo.
  define variable SLT-sum      as  decimal     no-undo.
  define variable VAT-sum      as  decimal     no-undo.
  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .
  define variable v-slt-pc     like ub.doc-line.slt-pc         no-undo .

  define variable v-sum-no-VAT-10 as decimal   no-undo .
  define variable v-VAT-10        as decimal   no-undo .
  define variable v-sum-10        as decimal   no-undo .
  define variable v-sum-no-VAT-18 as decimal   no-undo .
  define variable v-VAT-18        as decimal   no-undo .
  define variable v-sum-18        as decimal   no-undo .

do
on error undo, return error return-value
:

    if lookup( 'vat-itog' , p-mode ) <> 0 then do:
      empty temp-table temp-nalog.
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
      :
        run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).
        find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
        if available tt-allsum-line then do :
          if not CostPrice then do:
            if PrintRubl then do:
              assign stoim = tt-allsum-line.sum-dsc-rubl-doc  SLT-sum = tt-allsum-line.slt-rubl-doc  VAT-sum = tt-allsum-line.vat-rubl-buyer-doc .
            end.
            else do:
              assign stoim = tt-allsum-line.sum-dsc-base-doc  SLT-sum = tt-allsum-line.slt-base-doc  VAT-sum = tt-allsum-line.vat-base-buyer-doc .
            end.
          end.
          else do:
            if PrintRubl then do:
              assign stoim = tt-allsum-line.sum-dsc-rubl-acc  SLT-sum = tt-allsum-line.slt-rubl-acc  VAT-sum = tt-allsum-line.vat-rubl-acc .
            end.
            else do:
              assign stoim = tt-allsum-line.sum-dsc-base-acc   SLT-sum = tt-allsum-line.slt-base-acc  VAT-sum = tt-allsum-line.vat-base-acc .
            end.
          end.
        end.
        assign
          v-vat-pc = round ( ( if costprice then ( VAT-sum / ( stoim - VAT-sum ) ) * 100 else buf_doc-line.vat-pc ) , 1 )
          v-slt-pc = round ( ( if costprice then ( SLT-sum / ( stoim - SLT-sum ) ) * 100 else buf_doc-line.slt-pc ) , 1 )
        .
        find first temp-nalog where temp-nalog.vat-prc = v-vat-pc and temp-nalog.slt-prc = v-slt-pc no-error .
        if not available temp-nalog then do:
          create temp-nalog .
          assign  temp-nalog.vat-prc = v-vat-pc  temp-nalog.slt-prc = v-slt-pc  .
        end.
        assign
          temp-nalog.vat-sum = temp-nalog.vat-sum + VAT-sum
          temp-nalog.slt-sum = temp-nalog.slt-sum + SLT-sum
          temp-nalog.from-sum = temp-nalog.from-sum + stoim
        .

      end. /* for each buf_doc-line no-lock */

      for each temp-nalog no-lock break by temp-nalog.slt-prc by temp-nalog.vat-prc
      :
        if temp-nalog.vat-prc = 10 then do:
          assign
            v-sum-no-VAT-10 = v-sum-no-VAT-10 + ( temp-nalog.from-sum - temp-nalog.vat-sum )
            v-VAT-10        = v-VAT-10        + temp-nalog.vat-sum
            v-sum-10        = v-sum-10        + temp-nalog.from-sum
          .
        end.
        if temp-nalog.vat-prc = 18 or temp-nalog.vat-prc = 20 then do:
          assign
            v-sum-no-VAT-18 = v-sum-no-VAT-18 + ( temp-nalog.from-sum - temp-nalog.vat-sum )
            v-VAT-18        = v-VAT-18        + temp-nalog.vat-sum
            v-sum-18        = v-sum-18        + temp-nalog.from-sum
          .
        end.
      end. /* for each temp-nalog */
      if lookup( "dec10", p-mode ) <> 0
      THEN DO:
         display stream Out-stream
            "Итого по ставке 10%" @ buf_goods.gds-name
            v-sum-no-VAT-10       @ v-sum-no-VAT
            v-VAT-10              @ v-VAT
            v-sum-10              @ v-sum
         with frame factur-10 .
         down stream Out-stream with frame factur-10 .
         display stream Out-stream
            "Итого по ставке 18/20%" @ buf_goods.gds-name
            v-sum-no-VAT-18       @ v-sum-no-VAT
            v-VAT-18              @ v-VAT
            v-sum-18              @ v-sum
         with frame factur-10 .
         down stream Out-stream with frame factur-10 .
      END.
      ELSE DO:
         display stream Out-stream
            "Итого по ставке 10%" @ buf_goods.gds-name
            v-sum-no-VAT-10       @ v-sum-no-VAT
            v-VAT-10              @ v-VAT
            v-sum-10              @ v-sum
         with frame factur .
         down stream Out-stream with frame factur .
         display stream Out-stream
            "Итого по ставке 18/20%" @ buf_goods.gds-name
            v-sum-no-VAT-18       @ v-sum-no-VAT
            v-VAT-18              @ v-VAT
            v-sum-18              @ v-sum
         with frame factur .
         down stream Out-stream with frame factur .
      END.
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_labelVat10}
          , input "Итого по ставке 10%":U
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumNoVat10}
          , input v-sum-no-VAT-10
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumVat10}
          , input v-VAT-10
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumWithVat10}
          , input v-sum-10
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_labelVat18}
          , input "Итого по ставке 18/20%":U
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumNoVat18}
          , input v-sum-no-VAT-18
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumVat18}
          , input v-VAT-18
      ).
      run facturxl-write-cell-data in this-procedure (
            input {&facturxl-f_sumWithVat18}
          , input v-sum-18
      ).
    end.  /* lookup( 'nds-itog' , p-mode ) <> 0 */
/*    down stream Out-stream 2 with frame factur .*/
end.

end procedure. /* print-vat-itog-by-perc */