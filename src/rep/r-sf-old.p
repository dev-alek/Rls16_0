block-level on error undo, throw.
/*

$Revision: c93cbc1375c4, 1081, rls $
$Author: SMMolotkov $
$Date: Thu Oct 12 16:32:18 2017 +0300 $
$Workfile: r-sf-old.p $
$Archive: rep/r-sf-old.p $

Печать счета-фактуры

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter invers           as logical              no-undo.
define input parameter p-mode           as character            no-undo.   /* используется для анализа sys-key */
define input parameter p-round          as character            no-undo.   /* 'round' включает округление */
define input parameter p-no-slt         as logical              no-undo .  /* yes - не печатаем строку НП */
define input parameter p-reverse        as logical              no-undo .  /* Меняем местами грузополучателя и плательщика */

&scoped-define gds-len 54
&scoped-define footer-tab-stop1 40

do
on error undo, return error
:

define variable vss-revision    as character no-undo initial "$Revision: c93cbc1375c4, 1081, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Oct 12 16:32:18 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-sf-old.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-sf-old.p $":U .
define variable vss-description as character no-undo initial "Печать счета-фактуры.":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i       }
{ cmp/breakstr.i     }
{ str/trdcalib.i     }
{ str/in-vatp.i def  }
{ str/out-vatp.i def }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ rep/r-factur.i def }
{ rep/fmtcli.i       }
{ rep/torgconf.i     }
{ rep/p-fmt.i        }
{ gbl/clntattr.i     }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/paramls.i      }
{ rep/sf-old-xl.i     }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }

define stream Out-stream .

define shared variable PrintScale   as logical              no-undo.
define shared variable CostPrice    as logical              no-undo.

/* define temp-table temp-gtd no-undo  /* для списка ГТД */ */
/*    field artic     like ub.goods.artic */
/*    field prod-code like ub.goods.prod-code */
/*    field prod-type like ub.goods.prod-type */
/*    field gtd       as character */
/*    INDEX pi  IS PRIMARY artic  prod-type  prod-code */
/*  . */

define variable v-must-print-scale      as logical              no-undo.
define variable tdoc-prt                as logical              no-undo.
define variable p-sf-par                as logical              no-undo.
define variable PrevPage                as integer   initial 0  no-undo.

define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.
define variable rootnode_code           as integer              no-undo.

define variable v-lines-counter         as integer              no-undo.
define variable v-node-code             like ub.gds-prt.upper-code no-undo.

define variable v-qnty                  as decimal              no-undo.
define variable v-price                 as decimal              no-undo.
define variable v-price-no-VAT          as decimal              no-undo.
define variable v-sum                   as decimal              no-undo.
define variable v-sum-no-VAT            as decimal              no-undo.
define variable v-sum-actciz            as decimal              no-undo.
define variable v-VAT                   as decimal              no-undo.
define variable v-SLT                   as decimal              no-undo.
define variable v-vat-pc                as decimal              no-undo.
define variable v-slt-pc                as decimal              no-undo.

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

/* define variable Pg-tqnty                as decimal     initial 0   no-undo. */
/* define variable Pg-Vat-gds              as decimal     initial 0   no-undo. */
/* define variable Pg-SLT-gds              as decimal     initial 0   no-undo. */
/* define variable Pg-stoim-noNDS          as decimal     initial 0   no-undo. */
/* define variable Pg-stoim                as decimal     initial 0   no-undo. */

define variable sym1  as character initial ":" no-undo.
define variable sym2  as character initial ":" no-undo.
define variable sym3  as character initial ":" no-undo.
define variable sym4  as character initial ":" no-undo.
define variable sym5  as character initial ":" no-undo.
define variable sym6  as character initial ":" no-undo.
define variable sym7  as character initial ":" no-undo.
define variable sym8  as character initial ":" no-undo.
define variable sym9  as character initial ":" no-undo.
define variable sym10 as character initial ":" no-undo.
define variable sym11 as character initial ":" no-undo.
define variable sym12 as character initial ":" no-undo.
define variable sym13 as character initial ":" no-undo.

define variable v-prt-name       as character            no-undo.
define variable v-country        as character            no-undo.
define variable v-GTD            as character            no-undo.
define variable v-single-line    as character            no-undo.
define variable v-propis         as character            no-undo.
define variable v-propis-cop     as character            no-undo.

define variable t-addres         as character            no-undo.
define variable t-phone          as character            no-undo.
define variable t-inn            as character            no-undo.
define variable t-num            as character            no-undo.
define variable v-print-doc      as character            no-undo.
define variable v-par-type       as character            no-undo.
define variable v-curr-abbr      as character            no-undo.
define variable v-void-decimal   as decimal              no-undo.
define variable v-sum-VAT        as decimal              no-undo.
define variable v-sum-SLT        as decimal              no-undo.
define variable v-sum-tax        as decimal              no-undo.

define variable v-host-code     as integer              no-undo.
define variable v-curr-code     as integer              no-undo.
define variable v-r-factur-is-vozvrat-vnesh  as logical      no-undo.
define variable tmp-var         as character             no-undo.
define variable FullGdsName     as logical               no-undo.

    /* Определение переменных для грузополучателя */
define variable  v-trdcattr-type            as character                 no-undo .
define variable  v-code-rec                 as integer                   no-undo .
define variable  v-type-rec                 as character                 no-undo .
define variable  v-recipient-code           as character                 no-undo .
define variable  v-codefirm-rec             as character                 no-undo .
define variable  v-curcode-rec              as integer                   no-undo .
define variable  v-out-name                 as character                 no-undo .

define variable v-outhdobj      as logical  init no    no-undo .   /* для межфирменных документов печатать в поле грузополучатель объект получателя*/
define variable v-outhdobj-str  as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-is-hold-doc   as logical   no-undo .

define buffer buf_trn-doc               for ub.trn-doc.
define buffer buf_our_clients           for ub.clients.
define buffer buf_clients               for ub.clients.
define buffer buf_firm                  for ub.firm.
define buffer buf_sysconf               for ub.sysconf.
define buffer buf_country               for ub.country.
define buffer buf_parts-attr            for ub.parts-attr.

define frame factur
        sym1               column-label ":!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name  column-label "Наименование товара (описание выполненных работ, ! оказанных услуг), имущественного права ! ":C54 format "X(54)" space(0)
        sym2               column-label ":!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base column-label "Ед.!изм.! " format "X(4)" space(0)
        sym3               column-label ":!:!:!:" format "X(1)" space(0)
        v-qnty             column-label "Количество! ! " format ">>>>>>9.<<<" space(0)
        sym4               column-label ":!:!:!:" format "X(1)" space(0)
        v-price-no-VAT     column-label "Цена (тариф)!за ед.изм.! ":C12 format "->>>>>>>9.99" space(0)
        sym5               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum-no-VAT       column-label "Стоимость товаров!(работ, услуг),!имуществ. прав!всего без налога":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum-actciz       column-label "в т.ч.!акциз! ":C9 format ">>>>>9.99" space(0)
        sym7               column-label ":!:!:!:" format "X(1)" space(0)
        ub.doc-line.Vat-pc column-label "Ставка!налога":C6 format ">9.9<%" space(0)
        sym8               column-label ":!:!:!:" format "X(1)" space(0)
        v-VAT              column-label "Сумма!налога! ":C12 format "->>>>>>>9.99" space(0)
        sym9               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum              column-label "Ст-ть товаров!(работ, услуг),!имуществ. прав!с учетом налога":c15 format "->>>>>>>>>>9.99" space(0)
/*        sym10 column-label ":!:!:!:" format "X(1)" space(0)*/
/*        v-SLT column-label "Сумма!НП":C12 format "->>>>>>>9.99" space(0)*/
        sym11              column-label ":!:!:!:" format "X(1)" space(0)
        v-country          column-label "Страна!происхождения! ":C15 format "X(15)" space(0)
        sym12              column-label ":!:!:!:" format "X(1)" space(0)
        v-GTD              column-label "Номер таможенной!декларации! ":C31 format "X(31)" space(0)
        sym13              column-label ":!:!:!:" format "X(1)" space(0)
header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U )                                                       at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X(198)" at 1
with width {&DOS_CW} down stream-io.

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
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
    view-as alert-box error.
end.
/*То что нужно для Грузополучателя */
{ gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc }
if  v-is-hold-doc then do:          /*если документ межфирменного перемещения, то смотрим что писать а грузополучатель . параметр outhdobj */
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

/*else do: */
  assign
    v-cli-type = buf_trn-doc.cli-type
    v-cli-code = buf_trn-doc.cli-code
  .
/*end.*/

 /* есть ли атрибут Грузополучатель*/
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
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
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
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
    view-as alert-box warning.
end.
assign
    v-single-line   = fill("-", 198)
    v-lines-counter = 1
.
{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.

assign
    FullGdsName = ( tmp-var = "yes" )
.

{ cmp/open-out.i stream Out-stream " " {&LS_PS_A4} }

run facturxl-init in this-procedure .

run print-header in this-procedure (
      input buf_trn-doc.doc-code
    , output v-curr-abbr
).
form header
    v-single-line format "X(198)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-stream frame Bottomframe .

form with frame factur .

/*---S---------------- По строке документа -----------------------*/
for each ub.doc-line no-lock
   where ub.doc-line.doc-code = buf_trn-doc.doc-code
break &if "{&sort-prod}" = "yes" &then by ( ub.doc-line.prod-type + string( ub.doc-line.prod-code ) ) &endif by ub.doc-line.artic
:
    run print-line in this-procedure .
end.        /*for  each ub.doc-line ...*/
/*---E---------------- По строке документа -----------------------*/

run print-footer in this-procedure .

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
    { rep/q-print.i 8 }
end.
else do:
    { rep/q-print.i 0 }
end.

end.

/*===============================================================================================*/
procedure print-more:
do
on error undo, return error
:
    define variable v-start-string as character no-undo.
    define variable v-add-string as character no-undo.
    assign
        v-start-string = gds-str2
    .

    do while trim(v-start-string) <> "" :
        assign gds-str = v-start-string.
        v-add-string = breakstr(gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string).
        display stream Out-stream
            sym1 fill(" ",17) + v-add-string @ ub.goods.gds-name
            sym2 sym3 sym4 sym5 sym6 sym7 sym8
            sym9 /*sym10*/ sym11 sym12 sym13
            with frame factur .
        down stream Out-stream 1 with frame factur .
    end. /* DO WHILE ... */
end.
end procedure.

/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
define variable v-print-parts     as logical    init no       no-undo.

    find first ub.goods no-lock
         where ub.goods.prod-type = ub.doc-line.prod-type
           and ub.goods.prod-code = ub.doc-line.prod-code
           and ub.goods.artic = ub.doc-line.artic
    .
    find first ub.country no-lock
         where ub.country.alpha1 = ub.goods.alpha1
    no-error.
    if lookup( "zum", p-mode ) <> 0
    then do:
        assign
            v-country = ub.goods.engl-name
        .
    end.
    else do:
        if available ub.country
        then do:
            assign
                v-country = ub.country.short-name
            .
        end.
        else do:
            assign
                v-country = ""
            .
        end.
    end.
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
    .
    find first ub.Units no-lock
         where ub.units.unit-name = ub.goods.unit-base
    .
    if (units.type = "{&bef-divisional},{&bef-twounit}"  or  ub.units.type = "{&bef-divisional},{&bef-altunit}" )
    then do:
        assign
            str =  string(ub.goods.artic,"x(16)") +  " "  + string(ub.goods.Sort,"x(5)") + " " + trim(ub.goods.gds-name)
                                                                                 + " " + trim(ub.goods.PS)
        .
    end.
    else do:
        assign
            str = string(ub.goods.artic,"x(16)") +  " "  + trim(ub.goods.gds-name)
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

    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = ub.doc-line.prt-root
    .
    assign
        rootnode_code = ub.gds-prt.node-code
    .
    if ( ub.gds-prt.node-name <> {&empty-scale} )
/*    and ( not invers )*/
    then do:
        /*---S------------- Не пустая шкала и не от поставщика ---------------------*/
        assign
            v-tot-prt-qnty          = 0
            v-tot-prt-VAT           = 0
            v-tot-prt-SLT           = 0
            v-tot-prt-sum-no-VAT    = 0
            v-tot-prt-sum           = 0
            v-must-print-scale      = PrintScale
        .
        if v-must-print-scale = yes
        then do:
          define variable is-printed as logical initial no no-undo .
          for each ub.parts no-lock
             where ub.parts.out-code  = ub.doc-line.doc-code
               and ub.parts.obj-type  = ub.doc-line.obj-type
               and ub.parts.obj-code  = ub.doc-line.obj-code
               and ub.parts.artic     = ub.doc-line.artic
               and ub.parts.prod-type = ub.doc-line.prod-type
               and ub.parts.prod-code = ub.doc-line.prod-code
          :
            /*---S------------- По партиям - для печати ГТД ---------------------*/
            assign v-GTD = ub.parts.cst-code.
            if available ub.country
            and ub.country.alpha1 = "RU":U
            then do:
                assign
                    v-GTD       = "-":U
                    v-country   = "-":U
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
                        .
                       if buf_country.alpha1 = "RU":U
                       then do :
                          assign
                            v-country = "-":U
                            v-GTD     = "-":U
                          .
                       end .
                  end.
            end.

            /*---S------------- Печатать по шкале ---------------------*/
            if is-printed = no then do:
              assign is-printed = yes .
              display stream Out-stream sym1 gds-str1 @ ub.goods.gds-name sym2 v-country sym3 v-GTD
                                        sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
              down stream Out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input gds-str1        /*  p-Name     */
                    , input "":U            /*  p-UAES     */
                    , input "":U            /*  p-EI       */
                    , input "":U            /*  p-qnty     */
                    , input "":U            /*  p-price    */
                    , input "":U            /*  p-SumNoVAT */
                    , input "":U            /*  p-SumActciz*/
                    , input "":U            /*  p-VATpc    */
                    , input "":U            /*  p-VATsum   */
                    , input "":U            /*  p-sum      */
                    , input v-country       /*  p-country  */
                    , input v-GTD           /*  p-GTD      */
                ).
            end.
            else do:
              if v-GTD <> "" then do:
                display stream Out-stream sym1 sym2  sym3 v-GTD sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
                down stream Out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input "":U            /*  p-Name     */
                    , input "":U            /*  p-UAES     */
                    , input "":U            /*  p-EI       */
                    , input "":U            /*  p-qnty     */
                    , input "":U            /*  p-price    */
                    , input "":U            /*  p-SumNoVAT */
                    , input "":U            /*  p-SumActciz*/
                    , input "":U            /*  p-VATpc    */
                    , input "":U            /*  p-VATsum   */
                    , input "":U            /*  p-sum      */
                    , input "":U            /*  p-country  */
                    , input v-GTD           /*  p-GTD      */
                ).
              end.
            end.
          end.
          if is-printed = no then do:
            display stream Out-stream sym1 gds-str1 @ ub.goods.gds-name sym2 v-country sym3 sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
            down stream Out-stream 1 with frame factur .
            run facturxl-write-line-data in this-procedure (
                  input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name  /*  p-Name     */
                , input "":U            /*  p-UAES     */
                , input "":U            /*  p-EI       */
                , input "":U            /*  p-qnty     */
                , input "":U            /*  p-price    */
                , input "":U            /*  p-SumNoVAT */
                , input "":U            /*  p-SumActciz*/
                , input "":U            /*  p-VATpc    */
                , input "":U            /*  p-VATsum   */
                , input "":U            /*  p-sum      */
                , input v-country       /*  p-country  */
                , input "":U            /*  p-GTD      */
            ).
            if FullGdsName
            and gds-str1 <> "":U then do :
               run print-more in this-procedure.
            end.
          end.
          /*  run print-more in this-procedure. */
          /*---E------------- Печатать по шкале ---------------------*/
        end.        /* if v-must-print-scale = yes */
        for each ub.gds-dtl no-lock
           where ub.gds-dtl.prod-type  = ub.doc-line.prod-type
             and ub.gds-dtl.prod-code  = ub.doc-line.prod-code
             and ub.gds-dtl.artic      = ub.doc-line.artic
             and ub.gds-dtl.doc-code   = ub.doc-line.doc-code
        :
            /*---S------------- for each ub.gds-dtl ---------------------*/
            find first ub.gds-prt no-lock
                 where ub.gds-prt.node-code = ub.gds-dtl.prt-code
            .
            if CostPrice = yes
            then do:
                { str/in-vatp.i calc ub.doc-line. buf_trn-doc. g }
                assign
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
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
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
                        , input 0
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
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-pc, 2 )*/
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
                { str/out-vatp.i calc-gds-dtl ub.doc-line. buf_trn-doc. ub.gds-dtl. }
                assign
                    v-VAT = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    v-SLT = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
                .
                if v-VAT = ? then assign v-VAT = 0.
                if v-SLT = ? then assign v-SLT = 0.
                assign
                    v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale ) - v-VAT - v-SLT
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
                .
                if p-round = 'round':U
                then do:
                    run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input 0
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
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-pc, 2 )*/
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
            if v-must-print-scale
            then do:
                /*---S------------- Печатать шкалу ---------------------*/
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code    = ub.goods.gds-code
                       and ub.bar-code.unit-cli    = ub.goods.unit-base
                       and ub.bar-code.node-code   = ub.gds-dtl.prt-code
                       and ub.bar-code.part-code   = ""
                       and ub.bar-code.in-code     = ""
                .
                assign
                    v-prt-name = ""
                .
                do while available ub.gds-prt:
                    if available ub.gds-prt
                    then do:
                        assign
                            v-prt-name     = "\" + string( ub.gds-prt.node-name, "X(10)" ) + v-prt-name
                            v-node-code   = ub.gds-prt.upper-code
                        .
                    end.
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = v-node-code
                           and ub.gds-prt.root <> yes
                    no-error.
                end.
                display stream out-stream
                        sym1 v-prt-name @ ub.goods.gds-name
                        sym2 ub.goods.unit-base
                        sym3 v-prt-qnty @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-prt-sum-no-VAT @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)" @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-prt-VAT when v-prt-qnty <> 0 @ v-VAT
                        sym9 v-prt-sum @ v-sum
    /*                            sym10 v-prt-SLT when v-prt-qnty <> 0 @ v-SLT*/
                        sym11 sym12 sym13
                        with frame factur .
                v-lines-counter = v-lines-counter + 1 .
                down stream out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input v-prt-name                  /*  p-Name     */
                    , input "":U                        /*  p-UAES     */
                    , input ub.goods.unit-base          /*  p-EI       */
                    , input string( v-prt-qnty )        /*  p-qnty     */
                    , input string( v-price-no-VAT )    /*  p-price    */
                    , input string( v-prt-sum-no-VAT )  /*  p-SumNoVAT */
                    , input "   ---":U                  /*  p-SumActciz*/
                    , input string( ub.doc-line.Vat-pc )   /*  p-VATpc    */
                    , input string( v-prt-VAT )         /*  p-VATsum   */
                    , input string( v-prt-sum )         /*  p-sum      */
                    , input "":U                        /*  p-country  */
                    , input "":U                        /*  p-GTD      */
                ).
                /*---E------------- Печатать шкалу ---------------------*/
            end.
            /*---E------------- for each ub.gds-dtl ---------------------*/
        end.

        assign
            v-qnty          = v-tot-prt-qnty
            v-VAT           = v-tot-prt-VAT
            v-SLT           = v-tot-prt-SLT
            v-sum-no-VAT    = v-tot-prt-sum-no-VAT
            v-sum           = v-tot-prt-sum
        .

        if not v-must-print-scale
        then do:
            /*---S------------- Не печатать признаки ---------------------*/
            assign v-price-no-VAT = v-sum-no-VAT / v-qnty.
            find first ub.bar-code no-lock
                    where ub.bar-code.gds-code = ub.goods.gds-code
                    and ub.bar-code.unit-cli = ub.goods.unit-base
                    and ub.bar-code.node-code = rootnode_code
                    and ub.bar-code.part-code = ""
                    and ub.bar-code.in-code = ""
            .
            for each ub.parts no-lock
                where ub.parts.out-code = ub.doc-line.doc-code
                    and ub.parts.obj-type = ub.doc-line.obj-type
                    and ub.parts.obj-code = ub.doc-line.obj-code
                    and ub.parts.artic = ub.doc-line.artic
                    and ub.parts.prod-type = ub.doc-line.prod-type
                    and ub.parts.prod-code = ub.doc-line.prod-code
            :
                    /*---S------------- По партиям ---------------------*/
                    assign v-GTD = ub.parts.cst-code.
                    if available ub.country
                    and ub.country.alpha1 = "RU":U
                    then do:
                        assign
                            v-GTD       = "-":U
                            v-country   = "-":U
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
                                .
                              if buf_country.alpha1 = "RU":U
                              then do :
                                  assign
                                    v-country = "-":U
                                    v-GTD     = "-":U
                                  .
                              end .
                          end.
                    end.
                    display stream Out-stream
                            sym1 string(ub.goods.artic,"X(16)") + " " + ub.goods.gds-name @ ub.goods.gds-name
                            sym2 ub.goods.unit-base
                            sym3 ub.parts.fact-qnty @ v-qnty
                            sym4 v-price-no-VAT
                            sym5 (if v-qnty <> 0 then v-sum-no-VAT * ub.parts.fact-qnty / v-qnty else 0 ) @ v-sum-no-VAT
                            sym6 "   ---" format "x(6)" @ v-sum-actciz
                            sym7 ub.doc-line.Vat-pc
                            sym8 v-VAT * ub.parts.fact-qnty / v-qnty when v-qnty <> 0 @ v-VAT
                            sym9 (if v-qnty <> 0 then v-sum * ub.parts.fact-qnty / v-qnty else 0 ) @ v-sum
/*                                sym10 v-SLT * ub.parts.fact-qnty / v-qnty when v-qnty <> 0 @ v-SLT*/
                            sym11 v-country
                            sym12 v-GTD
                            sym13
                            with frame factur .
                    down stream Out-stream 1 with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name   /*  p-Name     */
                        , input "":U            /*  p-UAES     */
                        , input ub.goods.unit-base                                         /*  p-EI       */
                        , input string( ub.parts.fact-qnty )                               /*  p-qnty     */
                        , input string( v-price-no-VAT )                                   /*  p-price    */
                        , input (if v-qnty <> 0 then v-sum-no-VAT * ub.parts.fact-qnty / v-qnty else 0 )            /*  p-SumNoVAT */
                        , input "   ---":U                                                 /*  p-SumActciz*/
                        , input string( ub.doc-line.Vat-pc )                               /*  p-VATpc    */
                        , input ( if v-qnty = 0 then "":U else string( v-VAT * ub.parts.fact-qnty / v-qnty ) )      /*  p-VATsum   */
                        , input string( if v-qnty <> 0 then v-sum * ub.parts.fact-qnty / v-qnty else 0 )            /*  p-sum      */
                        , input v-country                                                  /*  p-country  */
                        , input v-GTD                                                      /*  p-GTD      */
                    ).
                    if FullGdsName
                    and goods.gds-name <> "":U then do :
                      run print-more in this-procedure.
                    end.

                    v-lines-counter = v-lines-counter + 1 .
                    /*---E------------- По партиям ---------------------*/
            end.
            /*---E------------- Не печатать признаки ---------------------*/
        end.
        /*---E------------- Не пустая шкала и не от поставщика ---------------------*/
    end.
    else do:
        /*---S------------- Пустая шкала или от поставщика ---------------------*/
        find first ub.bar-code no-lock
                where ub.bar-code.gds-code = ub.goods.gds-code
                and ub.bar-code.unit-cli = ub.goods.unit-base
                and ub.bar-code.node-code = rootnode_code
                and ub.bar-code.part-code = ""
                and ub.bar-code.in-code = ""
        .
        if CostPrice = yes
        then do:
            /*---S------------------- Счет-фактура от поставщика -----------------*/
            assign v-qnty = ub.doc-line.doc-qnty.

            { str/in-vatp.i calc ub.doc-line. buf_trn-doc. g }
            assign
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
            find first ub.gds-dtl no-lock
                 where ub.gds-dtl.doc-code = ub.doc-line.doc-code
                   and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                   and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                   and ub.gds-dtl.artic = ub.doc-line.artic
                   and ub.gds-dtl.prt-code = rootnode_code
            .
            assign
                v-qnty = ub.gds-dtl.fact-qnty
            .
            { str/out-vatp.i calc-gds-dtl ub.doc-line. buf_trn-doc. ub.gds-dtl. }
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
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( round( v-price-no-VAT * v-vat-pc, 2 ) * v-qnty, 2 )*/
/*                        v-SLT               = round( ( v-price-no-VAT * v-qnty + v-VAT ) * v-slt-pc, 2 )*/
/*                        v-sum-no-VAT        = round( v-price-no-VAT * v-qnty, 2 )*/
/*                        v-tax               = round( v-tax-price * v-qnty, 2 )*/
/*            .*/
        end.        /* p-round = 'round':U */
        else do:
            assign
                v-VAT           = v-VAT * v-qnty
                v-SLT           = v-SLT * v-qnty
                v-sum-no-VAT    = v-price-no-VAT * v-qnty
                v-tax           = v-tax-price * v-qnty
            .
        end.        /* NOT ( p-round = 'round':U ) */
        assign
            v-sum           = v-sum-no-VAT + v-VAT
        .
        if ub.goods.gds-type = {&gds-office}
        or PrintScale
        then do:
            /*---S------------- Услуга ---------------------*/
            display stream Out-stream
                sym1 gds-str1 @ ub.goods.gds-name
                sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base ) @ ub.goods.unit-base
                sym3 v-qnty
                sym4 v-price-no-VAT
                sym5 v-sum-no-VAT
                sym6 "   ---" format "x(6)" @ v-sum-actciz
                sym7 ub.doc-line.Vat-pc
                sym8 v-VAT
                sym9 v-sum
/*                  sym10 v-SLT*/
                sym11 v-country
                sym12
                sym13
            with frame factur .
            down stream Out-stream 1 with frame factur .
            run facturxl-write-line-data in this-procedure (
                  input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name        /*  p-Name     */
                , input "":U            /*  p-UAES     */
                , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )            /*  p-EI       */
                , input string( v-qnty          )            /*  p-qnty     */
                , input string( v-price-no-VAT  )            /*  p-price    */
                , input string( v-sum-no-VAT    )            /*  p-SumNoVAT */
                , input "   ---":U                           /*  p-SumActciz*/
                , input string( ub.doc-line.Vat-pc  )           /*  p-VATpc    */
                , input string( v-VAT            )           /*  p-VATsum   */
                , input string( v-sum            )           /*  p-sum      */
                , input v-country                            /*  p-country  */
                , input "":U                                 /*  p-GTD      */
            ).
            if FullGdsName
            and gds-str1 <> "":U then do :
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
            for each ub.parts no-lock
               where ub.parts.out-code  = ub.doc-line.doc-code
                 and ub.parts.obj-type  = ub.doc-line.obj-type
                 and ub.parts.obj-code  = ub.doc-line.obj-code
                 and ub.parts.artic     = ub.doc-line.artic
                 and ub.parts.prod-type = ub.doc-line.prod-type
                 and ub.parts.prod-code = ub.doc-line.prod-code
            :
                /*---S------------- Для каждой партии ---------------------*/
                assign
                    v-GTD       = ub.parts.cst-code
                    v-prt-qnty  = ub.parts.fact-qnty
                .
                if available ub.country
                and ub.country.alpha1 = "RU":U
                then do:
                    assign
                        v-GTD       = "-":U
                        v-country   = "-":U
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
                            .
                          if buf_country.alpha1 = "RU":U
                          then do :
                              assign
                                v-country = "-":U
                                v-GTD     = "-":U
                              .
                          end .
                      end.
                end.
                if CostPrice = yes
                then do:
/* Если приход, то цену по партиям не осреднять, печатать как есть */
                    { str/in-vatp.i calc-parts ub.parts. buf_trn-doc. g }
                    assign
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
/*                            v-vat-pc                = v-parts-VAT / v-parts-price-no-VAT*/
/*                            v-slt-pc                = v-parts-SLT / ( v-parts-price-no-VAT + v-parts-VAT )*/
/*                            v-parts-price-no-VAT    = round( v-parts-price-no-VAT, 2 )*/
/*                            v-parts-VAT             = round( v-parts-price-no-VAT * v-vat-pc, 2 )*/
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
                    display stream Out-stream
                        sym1 gds-str1                                                           @ ub.goods.gds-name
                        sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )          @ ub.goods.unit-base
                        sym3 v-prt-qnty                                                         @ v-qnty
                        sym4 v-parts-price-no-VAT                                               @ v-price-no-VAT
                        sym5 v-parts-price-no-VAT * v-prt-qnty                                  @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)"                                             @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-parts-VAT * v-prt-qnty  when v-qnty <> 0                         @ v-VAT
                        sym9 v-parts-sum                                                        @ v-sum
                        sym11 v-country
                        sym12 v-GTD
                        sym13
                    with frame factur .
                    down stream Out-stream 1
                    with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name                /*  p-Name     */
                        , input "":U            /*  p-UAES     */
                        , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )            /*  p-EI       */
                        , input string( v-prt-qnty                        )     /*  p-qnty     */
                        , input string( v-parts-price-no-VAT              )     /*  p-price    */
                        , input string( v-parts-price-no-VAT * v-prt-qnty )     /*  p-SumNoVAT */
                        , input "   ---":U                                      /*  p-SumActciz*/
                        , input string( ub.doc-line.Vat-pc          )              /*  p-VATpc    */
                        , input ( if v-qnty = 0 then "":U else string( v-parts-VAT * v-prt-qnty ) )           /*  p-VATsum   */
                        , input string( v-parts-sum              )              /*  p-sum      */
                        , input v-country                                       /*  p-country  */
                        , input v-GTD                                           /*  p-GTD      */
                    ).
                end.
                else do:
                    display stream Out-stream
                        sym1 gds-str1                                                           @ ub.goods.gds-name
                        sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )       @ ub.goods.unit-base
                        sym3 v-prt-qnty                                                         @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-price-no-VAT * v-prt-qnty                                        @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)"                                             @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-VAT / v-qnty * v-prt-qnty when v-qnty <> 0                       @ v-VAT
                        sym9  ( v-price-no-VAT + v-VAT / v-qnty ) * v-prt-qnty when v-qnty <> 0 @ v-sum
                        sym11 v-country
                        sym12 v-GTD
                        sym13
                    with frame factur .
                    down stream Out-stream 1
                    with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name         /*  p-Name     */
                        , input "":U            /*  p-UAES     */
                        , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )     /*  p-EI       */
                        , input string( v-prt-qnty                        )     /*  p-qnty     */
                        , input string( v-price-no-VAT              )           /*  p-price    */
                        , input string( v-price-no-VAT * v-prt-qnty )           /*  p-SumNoVAT */
                        , input "   ---":U                                      /*  p-SumActciz*/
                        , input string( ub.doc-line.Vat-pc          )           /*  p-VATpc    */
                        , input ( if v-qnty = 0 then "":U else string( v-VAT / v-qnty * v-prt-qnty ) )           /*  p-VATsum   */
                        , input ( if v-qnty = 0 then "":U else string( ( v-price-no-VAT + v-VAT / v-qnty ) * v-prt-qnty ) )             /*  p-sum      */
                        , input v-country                                       /*  p-country  */
                        , input v-GTD                                           /*  p-GTD      */
                    ).
                end.
                if FullGdsName
                and gds-str1 <> "":U then do :
                   run print-more in this-procedure.
                end.

                { rep/r-factur.i tax prt-}

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
    define variable v-plat-rasch-doc as character    no-undo.
    define variable v-curr-name      as character           no-undo.
    define variable v-base-name      as character           no-undo.
    define variable v-base-abbr      as character           no-undo.
    define variable v-rubl-name      as character           no-undo.
    define variable t-currency       as character           no-undo.

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
        v-curr-name = buf_currency.curr-name
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
        v-base-name = buf_currency.curr-name
        v-base-abbr = buf_currency.curr-abbr
    .
    find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        v-rubl-name = buf_currency.curr-name
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
         space(108) "               к Правилам ведения журналов учета полученных и выставленных счетов-фактур," skip
         space(108) "               книг покупок и книг продаж при расчетах по налогу на добавленную стоимость" skip
         space(108) "                              (в ред. Постановлений Правительства РФ от 15.03.2001 № 189," skip
         space(108) "       от 27.07.2002 № 575, от 16.02.2004 № 84, от 11.05.2006 № 283, от 26.05.2009 № 451)" skip
      .
    END.

    put stream Out-stream
        space(25) string( "СЧЕТ-ФАКТУРА N" + ( if p-round = 'round':U then ":" else " " ) + t-num ) format "X(190)"
        skip(1) space(5) string( "Продавец" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 31 ) + v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name )) format "X(190)"
        skip    space(5) string( "Адрес"    + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-supplier-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + ( if p-round = 'round':U then ":" else " " ) + t-inn ) format "X(190)"
        .
        /*то что было в оригинале
        skip    space(5) string( "Грузоотправитель и его адрес"
                                + ( if p-round = 'round':U then ":" else " " )
                                + fill( " ", 11 )
                                + ( if buf_trn-doc.office = yes
                                    then "---"
                                    else v-torgconf-cargo-from-name
                                         + "  "
                                         + ( if invers
                                             or ( v-torgconf-outobj = no
                                                and ( not invers )
                                                and ( buf_trn-doc.doc-type <> {&income} ) )
                                            then v-torgconf-cargo-from-addres
                                            else v-torgconf-self-obj-addres ) ) ) format "X(190)" skip
    .*/

   /* вывод на экран грузоотправителя*/
   /*
   IF v-torgconf-torg12-cargo-code =  v-torgconf-supplier-code
   THEN v-out-name = "Он же":U.
   ELSE
   */

  /* message     v-torgconf-cargo-from-name skip v-torgconf-organization skip v-torgconf-cargo-from-sf-value view-as alert-box.*/
   if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
   else if
   buf_trn-doc.doc-type <> {&income}
   and ( not invers )
   and buf_trn-doc.office = no
   and v-torgconf-outobj = no
   and v-torgconf-outasend = no
   and v-torgconf-outsend = no
   then v-out-name = "Он же".
   else
/*   v-out-name =  if buf_trn-doc.office = yes
                              then "---"
                              else v-torgconf-cargo-from-name
                                    + "  "
                                    + ( if invers
                                       or ( v-torgconf-outobj = no
                                          and ( not invers )
                                          and ( buf_trn-doc.doc-type <> {&income} ) )
                                       then v-torgconf-cargo-from-addres
                                       else '':U ) .  */
 /*                                      else v-torgconf-self-obj-addres ) . */
   v-out-name =  v-torgconf-cargo-from-sf-value.
   run facturxl-write-cell-data in this-procedure (
        input {&facturxl-h_cargoFrom}
      , input v-out-name
   ).

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
/*    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_cargoFrom}
        , input ( if buf_trn-doc.office = yes
                  then "---"
                  else v-torgconf-cargo-from-name
                      + "  "
                      + ( if invers
                          or ( v-torgconf-outobj = no
                             and ( not invers )
                             and ( buf_trn-doc.doc-type <> {&income} ) )
                         then v-torgconf-cargo-from-addres
                         else v-torgconf-self-obj-addres ) )
    ). */
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
         /*
         IF v-torgconf-organization-code =  v-torgconf-saler-code
         THEN v-out-name = "Он же":U.
         ELSE
         */
         /*v-out-name =  v-torgconf-cargo-to-value .  */
        /* Здесь какая-то кривизна, видимо v-torgconf-consignee был создан когда появился атрибут грузополучатель для документов, но не работает для приходов.  */
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
               skip space(45) SUBSTRING(v-out-name, 146) format "X(145)"
            .
         end.
         else do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + v-out-name)   format "X(190)"
            .
         end.

        put stream Out-stream
        skip    space(5) string( "К платежно-расчетному документу" + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 29 ) + v-torgconf-saler-name +
                                                if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-saler-code )
                                                else "":U  ) format "X(190)"
        skip    space(5) string( "Адрес" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-saler-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер покупателя ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + ( if p-round = 'round':U then ": " else " " ) + t-inn ) format "X(190)"
        skip    space(5) "Дополнение (условия оплаты по договору (контракту), способ отправления и т.п." format "X(190)"
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
        t-currency = ( trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) + "." )
    .
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-h_currency}
        , input t-currency
    ).
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
        put stream Out-stream
            space(10) "Возврат товара поставщику." format "X(120)" skip
        .
    end.
    if v-torgconf-outrubl = no
    then do:
        put stream Out-stream
            space(10)
                string( "Валюта : " +
                trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) + "." ) format "X(120)"
        .
    end.
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
    put stream Out-stream
        skip
    .
end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-footer :

define variable v-base-code as integer     no-undo .
define variable v-base-abbr as character   no-undo .

define buffer buf_currency      for ub.currency.

do
on error undo, return error
:
    put stream Out-stream
        v-single-line format "X(198)"
    /* skip */
    .
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
    display stream Out-stream
        "Всего" @ ub.goods.gds-name
    /*    ( accum total v-sum-no-VAT ) @ v-sum-no-VAT*/
    /*    ( accum total v-VAT ) @ v-VAT*/
    /*    ( accum total v-sum ) @ v-sum*/
        v-tot-sum-no-VAT  @ v-sum-no-VAT
        v-tot-VAT         @ v-VAT
        v-tot-sum         @ v-sum
    with frame factur .
    down stream Out-stream 2 with frame factur .

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

    if abs( v-tot-SLT ) >= 0.005
    or ( not invers and abs( buf_trn-doc.discnt-rubl ) >= 0.005 )
    then do:
        put stream Out-stream
            space(5) "Итого по документу: "
            trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
            + " ("
            + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
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
                + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                + ")"
                                                                        format "X(150)"     at {&footer-tab-stop1}
        .
    end.
    put stream Out-stream
        skip space(5) "Итого к оплате: "
                        string( trim( string( v-tot-sum + v-tot-SLT, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
                        + " ("
                        + trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-abbr else ( if PrintRubl then "{&abbr_rub_allshift}" else v-base-abbr ) ) )
                        + ")" )
                                                                        format "X(150)"     at {&footer-tab-stop1}
    .

    if PrintRubl
    and v-torgconf-outprops = yes
    then do:        /* Если в  р у б л я х ,  то сумму прописью */
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

        put stream Out-stream
            skip(2) space(10) "Руководитель организации   " format "X(28)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(36)" "/"
            "      Главный бухгалтер   " format "X(25)"fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-buh format "X(36)" "/"
            skip space(45) "(подпись)" space(30) "(Ф.И.О)"  space(47) "(подпись)" space(30) "(Ф.И.О)"
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
              skip (1) space(10) substitute( "Индивидуальный предприниматель   &1  / &2 / ЕГРИП N &3 от &4 ", fill( "_", 26 ) , string(v-torgconf-self-host-name, "x(42)") , v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date ) format "X(174)"

              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
          run facturxl-write-cell-data in this-procedure (
                input {&facturxl-f_ownerName}
              , input v-torgconf-self-host-name
          ).
          run facturxl-write-cell-data in this-procedure (
              input {&facturxl-f_ownerReg}
            , input substitute ("N &1 от &2 ", v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date )
          ).

      end.
      else do :
          put stream Out-stream
              skip (1) space(10) substitute( "Индивидуальный предприниматель   &1  / &2 /  &3  ", fill( "_", 26 ) , fill("_", 42) , fill( "_", 50 ) ) format "X(174)"

              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
      end.
    end.
    put stream Out-stream  skip "Примечание. Первый экземпляр - покупателю, второй экземпляр - продавцу"   format "X(90)"
    .
end.
end procedure. /* print-footer */