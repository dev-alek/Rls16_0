block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg12pl.p $
$Archive: rep/torg12pl.p $

Печать накладной в группировке по складским местам.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.
define input parameter p-mode               as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg12pl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg12pl.p $":U .
define variable vss-description as character no-undo init "Печать накладной в группировке по складским местам.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ str/clcprtsl.i }
{ gbl/thbjattr.i }

&scoped-define gds-len 48
&scoped-define gds-len-m 70

define stream out-stream .

    define shared variable PrintScale   as logical      no-undo.
    define shared variable CostPrice    as logical      no-undo.
    define shared variable sort-name    as logical      no-undo.
    define shared variable sort-gr      as logical      no-undo.


    define temp-table temp_place_parts no-undo
        field plp-key       as integer
        field gds-code      as integer
        field part-code     as character
        field pl-code       as integer
        field artic         as character
        field prod-type     as character
        field prod-code     as integer
        field in-code       as character
        field out-code      as character
        field gds-name      as character
        field unit-base     as character
        field okei          as character
        field pack-type     as character
        field qnty-opl      as decimal
        field qnty-pl       as decimal
        field mass          as decimal
        field pl-name       as character
        field loc1          as character
        field loc2          as character
        field loc3          as character
        field loc4          as character

        index pi is primary unique plp-key
        index gpl gds-code part-code pl-code
        index l1 loc1
        index l2 loc2
        index l3 loc3
        index l4 loc4
    .
    define temp-table temp_place_parts-sum no-undo
        field gds-code      as integer
        field part-code     as character
        field pl-code       as integer
        field qnty-all      as decimal
        field price-no-VAT  as decimal
        field sum-no-VAT    as decimal
        field vat-pc        as decimal
        field sum-vat       as decimal
        field sum-all       as decimal
        field sum-slt       as decimal
        field price-all     as decimal
        field loc1          as character
        field loc2          as character
        field loc3          as character
        field loc4          as character
    .
    define temp-table temp_locations no-undo
        field loc1          as character
        field loc2          as character
        field loc3          as character
        field loc4          as character
        field pl-code       as integer
        field pl-name       as character
        index pi is primary unique
              loc1
              loc2
              loc3
              loc4
    .

    define variable rep-artic           as logical                  no-undo.

    define variable sym1                as character    init ":"    no-undo.
    define variable sym2                as character    init ":"    no-undo.
    define variable sym3                as character    init ":"    no-undo.
    define variable sym4                as character    init ":"    no-undo.
    define variable sym5                as character    init ":"    no-undo.
    define variable sym6                as character    init ":"    no-undo.
    define variable sym7                as character    init ":"    no-undo.
    define variable sym8                as character    init ":"    no-undo.
    define variable sym9                as character    init ":"    no-undo.
    define variable sym10               as character    init ":"    no-undo.
    define variable sym11               as character    init ":"    no-undo.
    define variable sym12               as character    init ":"    no-undo.
    define variable sym13               as character    init ":"    no-undo.
    define variable sym14               as character    init ":"    no-undo.
    define variable sym15               as character    init ":"    no-undo.
    define variable sym16               as character    init ":"    no-undo.
    define variable sym17               as character    init ":"    no-undo.
    define variable sym18               as character    init ":"    no-undo.
    /*define variable sym19               as character    init ":"    no-undo.*/

    define variable v-doc-line-counter  as integer      no-undo.
    define variable v-line-counter      as integer      no-undo.
    define variable v-goods-artic       as character    no-undo.
    define variable v-gds-name          as character    no-undo.
    define variable v-unit-base         as character    no-undo.
    define variable v-gds-code          as integer      no-undo.
    define variable v-okei              as character    no-undo.
    define variable v-pack-type         as character    no-undo.
    define variable v-qnty-opl          as decimal      no-undo.
    define variable v-qnty-pl           as decimal      no-undo.
    define variable v-price-no-VAT      as decimal      no-undo.
    define variable v-sum-no-VAT        as decimal      no-undo.
    define variable v-vat-pc            as decimal      no-undo.
    define variable v-sum-vat           as decimal      no-undo.
    define variable v-sum-all           as decimal      no-undo.
    define variable v-sum-slt           as decimal      no-undo.
    define variable v-mass              as decimal      no-undo.
    define variable v-qnty-all          as decimal      no-undo.
    define variable v-price-all         as decimal      no-undo.

    define variable v-itog-qnty-all     as decimal      no-undo.
    define variable v-itog-sum-no-VAT   as decimal      no-undo.
    define variable v-itog-sum-vat      as decimal      no-undo.
    define variable v-itog-sum-all      as decimal      no-undo.

    define variable v-single-line       as character    no-undo.
    define variable v-underline         as character    no-undo.
    define variable v-valute-abbr       as character    no-undo.
    define variable v-doc-date-string   as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-doc-status        as character    no-undo.
    define variable v-doc-flag          as logical      no-undo.
    define variable v-par-value         as character    no-undo.
    define variable v-par-type          as character    no-undo.

    define variable v-host-code         as integer      no-undo.
    define variable v-rb-is-base        as logical      no-undo.
    define variable v-print-doc-date    as logical      no-undo.
    define variable v-print-full-gds-name  as logical   no-undo .

    define variable v-curr-code         as integer      no-undo.
    define variable v-saler             as character    no-undo.
    define variable v-osnov             as character init "" no-undo .

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
     /* Определение переменных для грузополучателя */
define variable  v-trdcattr-type            as character                 no-undo.
define variable  v-code-rec                 as integer                   no-undo.
define variable  v-type-rec                 as character                 no-undo.
define variable  v-recipient-code           as character                 no-undo.
define variable  v-codefirm-rec             as character                 no-undo.
define variable  v-curcode-rec              as integer   no-undo .


    define frame f-doc
        sym1                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-doc-line-counter  column-label "N!п/п! ! ! "                      format ">>>>9"              space(0)
        sym2                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        /*v-goods-artic       column-label "Артикул! ! ! ! "                  format "X(17)"              space(0)
        sym19               column-label ":!:!:!:!:"                        format "X(1)"               space(0)*/
        v-gds-name          column-label "Наименование товара! ! ! ! "      format "X({&gds-len})"      space(0)
        sym3                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-gds-code          column-label "Код товара! ! ! ! "               format "999999999"          space(0)
        sym4                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-unit-base         column-label "Наим!ед.!изм.! ! "                format "X(4)"               space(0)
        sym5                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-okei              column-label "Код!ед.!изм.!по!ОКЕИ"             format "X(4)"               space(0)
        sym6                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-pack-type         column-label "Вид!уп.! ! ! "                    format "X(3)"               space(0)
        sym7                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-opl          column-label "Кол-!во в!одном!месте! "          format ">>9.<"              space(0)
        sym8                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-pl           column-label "Кол-!во!мест! ! "                 format ">>9.<"              space(0)
        sym9                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-mass              column-label "Масса!брут-!то! ! "               format ">>9.<"              space(0)
        sym10               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-all          column-label "Количество ! ! ! ! "              format "->>>>>9.<<<"        space(0)
        sym11               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-price-no-VAT      column-label "Цена без!  НДС! ! ! "          format "->>>>>9.99"         space(0)
        sym12               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-no-VAT        column-label "Сумма без!  НДС! ! ! "         format "->>,>>>,>>9.99"     space(0)
        sym13               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-vat-pc            column-label "Став-!ка!НДС!%! "                 format ">9.9<"              space(0)
        sym14               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-vat           column-label "Сумма!НДС! ! ! "                  format "->>,>>>,>>9.99"     space(0)
        sym15               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-all           column-label "Сумма!с учетом!  НДС! ! "  format "->>>,>>>,>>9.99"    space(0)
        sym16               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-slt           column-label "Сумма!НП! ! ! "                   format "->>>,>>9.99"        space(0)
        sym17               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-price-all         column-label "Цена!с учетом!  НП! ! "       format "->>>>>>>9.99"       space(0)
        sym18               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
    header
        string( "Цены и суммы указаны в " + trim( v-valute-abbr ) ) format "X(30)"
        string( "Документ N: " + v-doc-code + " от " + v-doc-date-string ) at 40 format "X(50)"
            ( if v-doc-status <> {&fact} then
                    string( "Статус документа: " + v-doc-status + " " + string( v-doc-flag, "+/-" ) )
                else
                    " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

    define frame f-doc-m
        sym1                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-doc-line-counter  column-label "N!п/п! ! ! "                      format ">>>>9"              space(0)
        sym2                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        /*v-goods-artic       column-label "Артикул! ! ! ! "                  format "X(17)"              space(0)
        sym19               column-label ":!:!:!:!:"                        format "X(1)"               space(0)*/
        v-gds-name          column-label "Наименование товара! ! ! ! "      format "X({&gds-len-m})"    space(0)
        sym3                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-gds-code          column-label "Код товара! ! ! ! "               format "999999999"          space(0)
        sym4                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-unit-base         column-label "Наим!ед.!изм.! ! "                format "X(4)"               space(0)
        sym5                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-okei              column-label "Код!ед.!изм.!по!ОКЕИ"             format "X(4)"               space(0)
        sym6                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-pack-type         column-label "Вид!уп.! ! ! "                    format "X(3)"               space(0)
        sym7                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-opl          column-label "Кол-!во в!одном!месте! "          format ">>9.<"              space(0)
        sym8                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-pl           column-label "Кол-!во!мест! ! "                 format ">>9.<"              space(0)
        sym9                column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-mass              column-label "Масса!брут-!то! ! "               format ">>9.<"              space(0)
        sym10               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-qnty-all          column-label "Количество ! ! ! ! "              format "->>>>>9.<<<"        space(0)
        sym11               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-price-no-VAT      column-label "Цена без!  НДС! ! ! "          format "->>>>>9.99"         space(0)
        sym12               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-no-VAT        column-label "Сумма без!  НДС! ! ! "         format "->>,>>>,>>9.99"     space(0)
        sym13               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-vat-pc            column-label "Став-!ка!НДС!%! "                 format ">9.9<"              space(0)
        sym14               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-vat           column-label "Сумма!НДС! ! ! "                  format "->>,>>>,>>9.99"     space(0)
        sym15               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
        v-sum-all           column-label "Сумма!с учетом!  НДС! ! "  format "->>>,>>>,>>9.99"    space(0)
        sym16               column-label ":!:!:!:!:"                        format "X(1)"               space(0)
    header
        string( "Цены и суммы указаны в " + trim( v-valute-abbr ) ) format "X(30)"
        string( "Документ N: " + v-doc-code + " от " + v-doc-date-string ) at 40 format "X(50)"
            ( if v-doc-status <> {&fact} then
                    string( "Статус документа: " + v-doc-status + " " + string( v-doc-flag, "+/-" ) )
                else
                    " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_pay-type      for pay-type.
do
on error undo, return error
:
    { gbl/working.i }

    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc-date =  thbjattr_thbj-attr.property-value-logical .
end.

{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then v-print-full-gds-name =  thbjattr_thbj-attr.property-value-logical .
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
    run torgconf-get-recepient-param (
    input buf_trn-doc.doc-code
  , output v-code-rec
  , output v-type-rec
  , output v-codefirm-rec
  , output v-curcode-rec
    ).

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


    run torgconf-read in this-procedure (
          input "torg12"
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
    run torgconf-get-form-header in this-procedure (
          input no
        , input buf_trn-doc.doc-code
        , input no
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input no
        , input no

    ).
    { gbl/rbisbase.i
        v-rb-is-base
    }
    assign
        v-doc-status        = buf_trn-doc.status_
        v-doc-flag          = buf_trn-doc.flag_
        v-single-line       = fill("-", 230)
        v-underline         = fill("_", 230)
        v-line-counter      = 1
        v-doc-line-counter  = 0
    .
    if v-torgconf-outnum = yes
    then do:
        assign
            v-doc-code = "          "
        .
    end.
    else do:
        assign
            v-doc-code = buf_trn-doc.doc-code
        .
    end.
    if v-torgconf-outdate = yes
    then do:
        assign v-doc-date-string =  "          " .
    end.
    else do:
        assign v-doc-date-string =  ( if buf_trn-doc.status_ <> {&fact} or v-print-doc-date = yes
                                    then string( buf_trn-doc.doc-date, "99/99/9999" )
                                    else string( buf_trn-doc.fact-date, "99/99/9999" ) )
        .
    end.

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    form header
        skip v-single-line format "X(198)" at 1
        skip "Продолжение - на следующей странице" at 30
        with frame BottomFrame
        width {&DOS_CW}
        PAGE-BOTTOM
        NO-LABELS
        NO-BOX
    .
    view stream out-stream frame BottomFrame .

    assign
        v-valute-abbr = ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" )
    .
    if v-torgconf-outappr = yes
    then do:
        put stream out-stream
            "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137
        .
    end.
    put stream out-stream
        skip space(5) v-single-line format  "X(19)" at 180
        skip space(5)
            "| "                                        at 180
            {&g___code}                                 at 188
            "|"                                         at 198
        skip space(5)
            "Форма по ОКУД" format "X(14)"              at 166
            "| "                                        at 180
            "0330212" "|"                               at 198
        skip space(5)
            substitute( "{&abbr_inn_allshift} &1 &2 (&3) &4 &5"
                    , v-torgconf-self-host-inn
                    , CAPS( v-torgconf-self-host-name )
                    , v-torgconf-self-host-code
                    , v-torgconf-self-host-addres
                    , v-torgconf-self-host-phone
            )               format "X(160)"
            "по ОКПО"       format "X(7)"               at 172
            "| "                                        at 180
            v-torgconf-self-host-okpo     format "X(16)" "|"          at 198
    .
    put stream out-stream
        skip space(5)
            ( if buf_trn-doc.doc-type <> {&income}
            then string( CAPS( v-torgconf-self-obj-name ) + " (" + string( buf_trn-doc.obj-code ) + ")" )
            else " " )      format "X(160)"
            "| "                                        at 180
            "|"                                         at 198
        skip space(5)
            "Вид деятельности по ОКДП"  format "X(25)"  at 155
            "| "                                        at 180
            "|"                                         at 198
    .
    put stream out-stream
        skip space(5)
                v-torgconf-torg12-cargo-string  format "X(160)"
                "по ОКПО"                       format "X(7)"   at 172
                "| "                                       at 180
                v-torgconf-self-host-okpo       format "X(16)"
                "|"                                        at 198

    .
    put stream out-stream
        skip
        space(5) string( "Поставщик: " + v-torgconf-suppi )  format "X(160)"
                 "по ОКПО"                                      format "X(7)" at 172 "| " at 180
                 v-torgconf-self-host-okpo                      format "X(16)" "|" at 198 skip
    .
    if buf_trn-doc.doc-type = {&income}
    then do:
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-nids}
            v-par-value
            v-par-type
        }
        assign
            v-osnov = v-par-value
        .
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-dids}
            v-par-value
            v-par-type
        }
        assign
            v-osnov = v-osnov + " от " + v-par-value
        .
    end.
    put stream out-stream
        space(5) string( "Плательщик: " + v-torgconf-saler )    format "X(160)"
                        "по ОКПО"                               format "X(7)"       at 172
                        "| "                                                        at 180
                        v-torgconf-self-host-okpo               format "X(16)"
                        "|"                                                         at 198 skip
        space(5) string( "Основание: " + v-osnov )              format "X(160)"
                        "номер"                                 format "X(5)"       at 174
                        "| "                                                        at 180
                        "|"                                                         at 198 skip
    .
    if v-torgconf-outprim = yes
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "mag"  */
    else do:
        put stream out-stream
            skip space(5)
                substitute( "Примечание: &1"
                    , ( if not( buf_trn-doc.PS begins "@" )
                        then replace( buf_trn-doc.PS, {&new-line}, " " )
                        else "" ) )     format "X(163)"
        .
    end.        /* NOT ( p-mode = "mag"  ) */
    find first buf_pay-type no-lock
         where buf_pay-type.obj-code = buf_trn-doc.pay-code
    no-error .
    put stream out-stream
            "дата" format "X(4)"                            at 175
            "| "                                            at 180
            "|"                                             at 198
        skip space(5)
            substitute( "Вид оплаты: &1"
                , ( if available buf_pay-type
                  then buf_pay-type.obj-name
                  else "?" ) )                      format "X(130)"
            string( "Транспортная накладная " )     format "X(23)"      at 147
            "номер"                                 format "X(5)"       at 174
            "| "                                                        at 180
            v-torgconf-vdoc-code                    format "X(16)"
            "|"                                                         at 198
        skip space(5)
            "дата"                                  format "X(4)"       at 175
            "| "                                                        at 180
            v-torgconf-vdoc-date                    format "X(10)"
            "|"                                                         at 198
        skip space(5)
            "Вид операции"                          format "X(12)"      at 167
            "| "                                                        at 180
            ( if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
              then "возврат пост-ку"
              else ( if buf_trn-doc.doc-type = {&income}
                     then " приход"
                     else ( if buf_trn-doc.doc-type = {&return}
                            then " возврат"
                            else " расход" ) ) )
                                                    format "X(16)" "|"  at 198
        skip space(5)
            v-single-line                           format  "X(19)"     at 180
        skip space(64)
            v-single-line                           format "X(33)"
        skip space(45)
            string( "ТОВАРНАЯ НАКЛАДНАЯ | "
                    + string( v-doc-code, "X(16)") + " | "
                    + v-doc-date-string
                    + " | "
                    + ( if buf_trn-doc.status_ <> {&fact}
                        then string( "(" + CAPS( buf_trn-doc.status_ ) + ")" )
                        else "" )
            )                                       format "X(100)"
        skip space(64)
            v-single-line                           format "X(33)"
    .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then put stream out-stream
        skip space(10)
            "Возврат товара поставщику"             format "X(120)"
    .
    if v-torgconf-outt12 = yes
    then do:
        form with frame f-doc-m .
        down stream out-stream 1 with frame f-doc-m .

    end.        /* v-torgconf-outt12 = yes */
    else do:
        form with frame f-doc .
        down stream out-stream 1 with frame f-doc .
    end.        /* NOT ( v-torgconf-outt12 = yes ) */
    run fill-temp_place_parts in this-procedure (
          input buf_trn-doc.doc-code
        , input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
    ).
    run fill-temp_locations in this-procedure .
    if CostPrice = yes
    then do:
        run fill-temp-parts-cost in this-procedure (
              input v-rb-is-base
            , input buf_trn-doc.doc-code
            , input buf_trn-doc.obj-type
            , input buf_trn-doc.obj-code
        ).
    end.
    else do:
        run fill-temp-parts-doc in this-procedure (
              input v-rb-is-base
            , input buf_trn-doc.doc-code
            , input buf_trn-doc.obj-type
            , input buf_trn-doc.obj-code
        ).
    end.
/*    output to "d:\ww\1\123\1.txt".*/
/*    for each temp_place_parts no-lock*/
/*    on error undo, return error*/
/*    :*/
/*        export temp_place_parts.*/
/*    end.*/
/*    for each temp_place_parts-sum no-lock*/
/*    on error undo, return error*/
/*    :*/
/*        export temp_place_parts-sum.*/
/*    end.*/
/*    output close.*/
    for each temp_locations
    break by temp_locations.loc1
          by temp_locations.loc2
          by temp_locations.loc3
          by temp_locations.loc4
    on error undo, return error
    :
        if first-of( temp_locations.loc4 )
        then do:
            run print-location in this-procedure (
                  input substitute( "Складское место: &1 &2. &3 &4 &5 &6"
                                    , temp_locations.pl-code
                                    , temp_locations.pl-name
                                    , temp_locations.loc1
                                    , temp_locations.loc2
                                    , temp_locations.loc3
                                    , temp_locations.loc4
                  )
                , input v-single-line
            ).
        end.
        run print-location-lines in this-procedure (
              input temp_locations.loc1
            , input temp_locations.loc2
            , input temp_locations.loc3
            , input temp_locations.loc4
            , input v-itog-qnty-all
            , input v-itog-sum-no-VAT
            , input v-itog-sum-vat
            , input v-itog-sum-all
            , output v-itog-qnty-all
            , output v-itog-sum-no-VAT
            , output v-itog-sum-vat
            , output v-itog-sum-all
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка печати строки товара."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* for each temp_place_parts-sum */
    if line-counter( out-stream ) + 20 > page-size( out-stream )
    then do:
        run print-sub-itog in this-procedure (
              input v-itog-qnty-all
            , input v-itog-sum-no-VAT
            , input v-itog-sum-vat
            , input v-itog-sum-all
            , input v-single-line
        ).
        page stream out-stream .
        hide stream out-stream frame BottomFrame .
    end.
    else do:
        page stream out-stream .
        hide stream out-stream frame BottomFrame .
        run print-sub-itog in this-procedure (
              input v-itog-qnty-all
            , input v-itog-sum-no-VAT
            , input v-itog-sum-vat
            , input v-itog-sum-all
            , input v-single-line
        ).
    end.
    run print-footer in this-procedure (
          input buf_trn-doc.doc-code
        , input v-itog-qnty-all
        , input v-itog-sum-no-VAT
        , input v-itog-sum-vat
        , input v-itog-sum-all
    ).

    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 8 }
end.

/*==========================================================================*/
procedure fill-temp_place_parts :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.

    define variable v-parts-counter     as integer    no-undo.

    define buffer buf_parts             for parts.
    define buffer buf_goods             for goods.
    define buffer buf_place             for place.
    define buffer buf_temp_place_parts  for temp_place_parts.
do
for buf_parts
  , buf_goods
  , buf_place
  , buf_temp_place_parts
on error undo, return error
:
    assign
        v-parts-counter = 0
    .
    for each buf_parts
       where buf_parts.out-code     = p-doc-code
         and buf_parts.obj-type     = p-obj-type
         and buf_parts.obj-code     = p-obj-code
    :
        assign
            v-parts-counter = v-parts-counter + 1
        .
        find first buf_goods no-lock
             where buf_goods.artic      = buf_parts.artic
               and buf_goods.prod-type  = buf_parts.prod-type
               and buf_goods.prod-code  = buf_parts.prod-code
        .
        create buf_temp_place_parts.
        assign
            buf_temp_place_parts.plp-key        = v-parts-counter
            buf_temp_place_parts.gds-code       = buf_goods.gds-code
            buf_temp_place_parts.part-code      = buf_parts.part-code
            buf_temp_place_parts.artic          = buf_parts.artic
            buf_temp_place_parts.prod-type      = buf_parts.prod-type
            buf_temp_place_parts.prod-code      = buf_parts.prod-code
            buf_temp_place_parts.in-code        = buf_parts.in-code
            buf_temp_place_parts.out-code       = buf_parts.out-code
            buf_temp_place_parts.gds-name       = (if rep-artic then (string(buf_parts.artic,"x(16)") +  " ") else "")  + buf_goods.gds-name
            buf_temp_place_parts.unit-base      = buf_goods.unit-base
            buf_temp_place_parts.okei           = "":U
            buf_temp_place_parts.pack-type      = "":U
            buf_temp_place_parts.qnty-opl       = ?
            buf_temp_place_parts.qnty-pl        = ?
            buf_temp_place_parts.mass           = ?
            buf_temp_place_parts.pl-code        = buf_parts.pl-code
        .
        find first buf_place no-lock
             where buf_place.obj-type = p-obj-type
               and buf_place.obj-code = p-obj-code
               and buf_place.pl-code  = buf_parts.pl-code
        no-error.
        if available buf_place
        then do:
            assign
                buf_temp_place_parts.pl-name = buf_place.pl-name
                buf_temp_place_parts.loc1    = buf_place.loc1
                buf_temp_place_parts.loc2    = buf_place.loc2
                buf_temp_place_parts.loc3    = buf_place.loc3
                buf_temp_place_parts.loc4    = buf_place.loc4
            .
        end.
    end.        /* for each buf_parts */
end.
end procedure. /* fill-temp_place_parts */


/*==========================================================================*/
procedure fill-temp-parts-doc :
define input parameter p-rb-is-base         as logical          no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.

    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_doc-line          for doc-line.
    define buffer buf_parts             for parts.
    define buffer buf_temp_place_parts  for temp_place_parts.
do
for buf_trn-doc
  , buf_doc-line
  , buf_parts
  , buf_temp_place_parts
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    for each buf_temp_place_parts
    break by buf_temp_place_parts.gds-code
          by buf_temp_place_parts.loc1
          by buf_temp_place_parts.loc2
          by buf_temp_place_parts.loc3
          by buf_temp_place_parts.loc4
    on error undo, return error
    :
        find first buf_parts no-lock
             where buf_parts.obj-type   = p-obj-type
               and buf_parts.obj-code   = p-obj-code
               and buf_parts.artic      = buf_temp_place_parts.artic
               and buf_parts.prod-type  = buf_temp_place_parts.prod-type
               and buf_parts.prod-code  = buf_temp_place_parts.prod-code
               and buf_parts.in-code    = buf_temp_place_parts.in-code
               and buf_parts.out-code   = buf_temp_place_parts.out-code
               and buf_parts.part-code  = buf_temp_place_parts.part-code
        .
        create tt-clcparts.
        buffer-copy buf_parts to tt-clcparts.
        if last-of( buf_temp_place_parts.loc4 )
        then do:
            find first buf_doc-line no-lock
                 where buf_doc-line.doc-code    = p-doc-code
                   and buf_doc-line.artic       = buf_temp_place_parts.artic
                   and buf_doc-line.prod-type   = buf_temp_place_parts.prod-type
                   and buf_doc-line.prod-code   = buf_temp_place_parts.prod-code
            .
            run clcprtsl_calc-ttable in this-procedure (
                  input yes
                , input no
                , input buf_doc-line.road-tax                                   /* ub.doc-line.road-tax     */
                , input buf_doc-line.excise                                     /* ub.doc-line.excise       */
                , input buf_doc-line.vat-pc                                     /* ub.doc-line.vat-pc       */
                , input buf_doc-line.cons-vat-pc                                /* ub.doc-line.cons-vat-pc  */
                , input buf_doc-line.slt-pc                                     /* ub.doc-line.slt-pc       */
                , input buf_trn-doc.base-rate                                   /* ub.trn-doc.base-rate     */
                , input buf_trn-doc.base-scale                                  /* ub.trn-doc.base-scale    */
                , input ( if p-rb-is-base = yes then "base":U else "rubl":U )   /* character r-b            */
                , input 0                                                       /* ub.gds-dtl.cur-base      */
                , input 0                                                       /* ub.doc-line.road-tax     */
                , input 0                                                       /* ub.doc-line.excise       */
                , input 0                                                       /* ub.doc-line.vat-pc       */
                , input 0                                                       /* ub.doc-line.cons-vat-pc  */
                , input 0                                                       /* ub.doc-line.slt-pc       */
            ) no-error.
            find first tt-allsum-line
                    where tt-allsum-line.sum-type = {&sum-general}
            .
            create temp_place_parts-sum.
            assign
                temp_place_parts-sum.gds-code     = buf_temp_place_parts.gds-code
                temp_place_parts-sum.part-code    = buf_temp_place_parts.part-code
                temp_place_parts-sum.pl-code      = buf_temp_place_parts.pl-code
                temp_place_parts-sum.qnty-all     = tt-allsum-line.fact-qnty
                temp_place_parts-sum.loc1         = buf_temp_place_parts.loc1
                temp_place_parts-sum.loc2         = buf_temp_place_parts.loc2
                temp_place_parts-sum.loc3         = buf_temp_place_parts.loc3
                temp_place_parts-sum.loc4         = buf_temp_place_parts.loc4
            .
            if PrintRubl = yes
            then do:
                assign
                    temp_place_parts-sum.sum-no-VAT   = tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.vat-rubl-doc - tt-allsum-line.slt-rubl-doc
                    temp_place_parts-sum.price-no-VAT = temp_place_parts-sum.sum-no-VAT / tt-allsum-line.fact-qnty
                    temp_place_parts-sum.sum-vat      = tt-allsum-line.vat-rubl-doc
                    temp_place_parts-sum.sum-all      = tt-allsum-line.sum-dsc-rubl-doc
                    temp_place_parts-sum.sum-slt      = tt-allsum-line.slt-rubl-doc
                    temp_place_parts-sum.vat-pc       = temp_place_parts-sum.sum-vat / temp_place_parts-sum.sum-no-VAT * 100
                    temp_place_parts-sum.price-all    = temp_place_parts-sum.sum-all / tt-allsum-line.fact-qnty
                .
            end.        /* if PrintRubl = yes */
            else do:
                assign
                    temp_place_parts-sum.sum-no-VAT   = tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.vat-base-doc - tt-allsum-line.slt-base-doc
                    temp_place_parts-sum.price-no-VAT = temp_place_parts-sum.sum-no-VAT / tt-allsum-line.fact-qnty
                    temp_place_parts-sum.sum-vat      = tt-allsum-line.vat-base-doc
                    temp_place_parts-sum.sum-all      = tt-allsum-line.sum-dsc-base-doc
                    temp_place_parts-sum.sum-slt      = tt-allsum-line.slt-base-doc
                    temp_place_parts-sum.vat-pc       = temp_place_parts-sum.sum-vat / temp_place_parts-sum.sum-no-VAT * 100
                    temp_place_parts-sum.price-all    = temp_place_parts-sum.sum-all / tt-allsum-line.fact-qnty
                .
            end.        /* NOT ( if PrintRubl = yes ) */
            for each tt-clcparts
            on error undo, return error
            :
                delete tt-clcparts.
            end.
        end.
    end.        /* for each buf_temp_place_parts */
end.
end procedure. /* fill-temp-parts-doc */


/*==========================================================================*/
procedure fill-temp-parts-cost :
define input parameter p-rb-is-base         as logical          no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.

    define buffer buf_parts             for parts.
    define buffer buf_goods             for goods.
    define buffer buf_place             for place.
    define buffer buf_temp_place_parts  for temp_place_parts.
do
for buf_parts
  , buf_goods
  , buf_place
  , buf_temp_place_parts
on error undo, return error
:
    for each buf_temp_place_parts
    on error undo, return error
    :
        find first buf_parts no-lock
             where buf_parts.obj-type   = p-obj-type
               and buf_parts.obj-code   = p-obj-code
               and buf_parts.artic      = buf_temp_place_parts.artic
               and buf_parts.prod-type  = buf_temp_place_parts.prod-type
               and buf_parts.prod-code  = buf_temp_place_parts.prod-code
               and buf_parts.in-code    = buf_temp_place_parts.in-code
               and buf_parts.out-code   = buf_temp_place_parts.out-code
               and buf_parts.part-code  = buf_temp_place_parts.part-code
        .
        for each tt-clcparts
        :
            delete tt-clcparts.
        end.
        create tt-clcparts.
        buffer-copy buf_parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure (
              input recid( tt-clcparts )
            , input no
            , input no
            , input 0                                                       /* ub.doc-line.road-tax     */
            , input 0                                                       /* ub.doc-line.excise       */
            , input 0                                                       /* ub.doc-line.vat-pc       */
            , input 0                                                       /* ub.doc-line.cons-vat-pc  */
            , input 0                                                       /* ub.doc-line.slt-pc       */
            , input 0                                                       /* ub.trn-doc.base-rate     */
            , input 0                                                       /* ub.trn-doc.base-scale    */
            , input ( if p-rb-is-base = yes then "base":U else "rubl":U )   /* character r-b            */
            , input 0                                                       /* ub.gds-dtl.cur-base      */
            , input 0                                                       /* ub.doc-line.road-tax     */
            , input 0                                                       /* ub.doc-line.excise       */
            , input 0                                                       /* ub.doc-line.vat-pc       */
            , input 0                                                       /* ub.doc-line.cons-vat-pc  */
            , input 0                                                       /* ub.doc-line.slt-pc       */
        ) no-error.
/*    output to "d:\ww\1\123\1.txt".*/
/*    for each tt-allsum no-lock*/
/*    on error undo, return error*/
/*    :*/
/*        export tt-allsum.*/
/*    end.*/
/*    output close.*/
        find first tt-allsum
             where tt-allsum.sum-type = {&sum-general}
        .
        create temp_place_parts-sum.
        assign
            temp_place_parts-sum.gds-code     = buf_temp_place_parts.gds-code
            temp_place_parts-sum.part-code    = buf_temp_place_parts.part-code
            temp_place_parts-sum.pl-code      = buf_temp_place_parts.pl-code
            temp_place_parts-sum.qnty-all     = tt-allsum.fact-qnty
            temp_place_parts-sum.loc1         = buf_temp_place_parts.loc1
            temp_place_parts-sum.loc2         = buf_temp_place_parts.loc2
            temp_place_parts-sum.loc3         = buf_temp_place_parts.loc3
            temp_place_parts-sum.loc4         = buf_temp_place_parts.loc4
        .
        if PrintRubl = yes
        then do:
            assign
                temp_place_parts-sum.sum-no-VAT   = tt-allsum.sum-dsc-rubl-acc - tt-allsum.vat-rubl-acc - tt-allsum.slt-rubl-acc
                temp_place_parts-sum.price-no-VAT = temp_place_parts-sum.sum-no-VAT / tt-allsum.fact-qnty
                temp_place_parts-sum.sum-vat      = tt-allsum.vat-rubl-acc
                temp_place_parts-sum.sum-all      = tt-allsum.sum-dsc-rubl-acc
                temp_place_parts-sum.sum-slt      = tt-allsum.slt-rubl-acc
                temp_place_parts-sum.vat-pc       = temp_place_parts-sum.sum-vat / temp_place_parts-sum.sum-no-VAT * 100
                temp_place_parts-sum.price-all    = temp_place_parts-sum.sum-all / tt-allsum.fact-qnty
            .
        end.        /* if PrintRubl = yes */
        else do:
            assign
                temp_place_parts-sum.sum-no-VAT   = tt-allsum.sum-dsc-base-acc - tt-allsum.vat-base-acc - tt-allsum.slt-base-acc
                temp_place_parts-sum.price-no-VAT = temp_place_parts-sum.sum-no-VAT / tt-allsum.fact-qnty
                temp_place_parts-sum.sum-vat      = tt-allsum.vat-base-acc
                temp_place_parts-sum.sum-all      = tt-allsum.sum-dsc-base-acc
                temp_place_parts-sum.sum-slt      = tt-allsum.slt-base-acc
                temp_place_parts-sum.vat-pc       = temp_place_parts-sum.sum-vat / temp_place_parts-sum.sum-no-VAT * 100
                temp_place_parts-sum.price-all    = temp_place_parts-sum.sum-all / tt-allsum.fact-qnty
            .
        end.        /* NOT ( if PrintRubl = yes ) */
    end.        /* for each buf_parts */
end.
end procedure. /* fill-temp-parts */

/*==========================================================================*/
procedure fill-temp_locations :

    define buffer buf_temp_place_parts      for temp_place_parts.
    define buffer buf_temp_locations        for temp_locations.
do
for buf_temp_place_parts
  , buf_temp_locations
on error undo, return error
:
    for each buf_temp_place_parts
    break by buf_temp_place_parts.loc1
          by buf_temp_place_parts.loc2
          by buf_temp_place_parts.loc3
          by buf_temp_place_parts.loc4
    on error undo, return error
    :
        if first-of( buf_temp_place_parts.loc4 )
        then do:
            create buf_temp_locations.
            assign
                buf_temp_locations.loc1     = buf_temp_place_parts.loc1
                buf_temp_locations.loc2     = buf_temp_place_parts.loc2
                buf_temp_locations.loc3     = buf_temp_place_parts.loc3
                buf_temp_locations.loc4     = buf_temp_place_parts.loc4
                buf_temp_locations.pl-code  = buf_temp_place_parts.pl-code
                buf_temp_locations.pl-name  = buf_temp_place_parts.pl-name
            .
        end.
    end.        /* for each buf_temp_place_parts */
end.
end procedure. /* fill-temp_locations */

/*==========================================================================*/
procedure print-location :
define input parameter p-loc-name       as character        no-undo.
define input parameter p-single-line    as character        no-undo.
do
on error undo, return error
:
    if p-loc-name = "":U
    then do:
/*        put stream out-stream*/
/*            skip p-single-line format "X(198)" at 1*/
/*        .*/
    end.        /* if p-loc-name = "":U */
    else do:
        if v-doc-line-counter <> 0
        then do:
            put stream out-stream
                skip p-single-line  format "X(198)" at 1
            .
        end.
        put stream out-stream
            skip p-loc-name     format "X(160)"
            skip p-single-line  format "X(198)" at 1
        .
    end.        /* NOT ( if p-loc-name = "":U ) */
end.
end procedure. /* print-location */

/*==========================================================================*/
procedure print-location-lines :
define input parameter p-loc1                   as character        no-undo.
define input parameter p-loc2                   as character        no-undo.
define input parameter p-loc3                   as character        no-undo.
define input parameter p-loc4                   as character        no-undo.
define input parameter p-itog-qnty-all          as decimal          no-undo.
define input parameter p-itog-sum-no-VAT        as decimal          no-undo.
define input parameter p-itog-sum-vat           as decimal          no-undo.
define input parameter p-itog-sum-all           as decimal          no-undo.
define output parameter p-out-itog-qnty-all     as decimal          no-undo.
define output parameter p-out-itog-sum-no-VAT   as decimal          no-undo.
define output parameter p-out-itog-sum-vat      as decimal          no-undo.
define output parameter p-out-itog-sum-all      as decimal          no-undo.

    define buffer buf_temp_place_parts-sum      for temp_place_parts-sum.
    define buffer buf_temp_place_parts          for temp_place_parts.
do
for buf_temp_place_parts-sum
  , buf_temp_place_parts
on error undo, return error
:
    assign
        p-out-itog-qnty-all   = p-itog-qnty-all
        p-out-itog-sum-no-VAT = p-itog-sum-no-VAT
        p-out-itog-sum-vat    = p-itog-sum-vat
        p-out-itog-sum-all    = p-itog-sum-all
    .
    for each buf_temp_place_parts-sum
       where buf_temp_place_parts-sum.loc1 = p-loc1
         and buf_temp_place_parts-sum.loc2 = p-loc2
         and buf_temp_place_parts-sum.loc3 = p-loc3
         and buf_temp_place_parts-sum.loc4 = p-loc4
    on error undo, return error
    :
        find first buf_temp_place_parts
             where buf_temp_place_parts.gds-code  = buf_temp_place_parts-sum.gds-code
               and buf_temp_place_parts.part-code = buf_temp_place_parts-sum.part-code
               and buf_temp_place_parts.pl-code   = buf_temp_place_parts-sum.pl-code
        .
        assign
            v-doc-line-counter = v-doc-line-counter + 1
        .
        if v-torgconf-outt12 = yes
        then do:
            display stream out-stream
                sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 /*sym19*/
                v-doc-line-counter
                /*buf_temp_place_parts.artic              @ v-goods-artic*/
                buf_temp_place_parts.gds-name           @ v-gds-name
                buf_temp_place_parts.gds-code           @ v-gds-code
                buf_temp_place_parts.unit-base          @ v-unit-base
                buf_temp_place_parts.okei               @ v-okei
                buf_temp_place_parts.pack-type          @ v-pack-type
                buf_temp_place_parts.qnty-opl           when buf_temp_place_parts.qnty-opl <> ? @ v-qnty-opl
                buf_temp_place_parts.qnty-pl            when buf_temp_place_parts.qnty-pl <> ?  @ v-qnty-pl
                buf_temp_place_parts.mass               when buf_temp_place_parts.mass <> ?     @ v-mass
                buf_temp_place_parts-sum.qnty-all       @ v-qnty-all
                buf_temp_place_parts-sum.price-no-VAT   @ v-price-no-VAT
                buf_temp_place_parts-sum.sum-no-VAT     @ v-sum-no-VAT
                buf_temp_place_parts-sum.vat-pc         @ v-vat-pc
                buf_temp_place_parts-sum.sum-vat        @ v-sum-vat
                buf_temp_place_parts-sum.sum-all        @ v-sum-all
            with frame f-doc-m.
            down stream out-stream 1 with frame f-doc-m .
        end.        /* if v-torgconf-outt12 = yes */
        else do:
            display stream out-stream
                sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 /*sym19*/
                v-doc-line-counter
                /*buf_temp_place_parts.artic              @ v-goods-artic*/
                buf_temp_place_parts.gds-name           @ v-gds-name
                buf_temp_place_parts.gds-code           @ v-gds-code
                buf_temp_place_parts.unit-base          @ v-unit-base
                buf_temp_place_parts.okei               @ v-okei
                buf_temp_place_parts.pack-type          @ v-pack-type
                buf_temp_place_parts.qnty-opl           when buf_temp_place_parts.qnty-opl <> ? @ v-qnty-opl
                buf_temp_place_parts.qnty-pl            when buf_temp_place_parts.qnty-pl <> ?  @ v-qnty-pl
                buf_temp_place_parts.mass               when buf_temp_place_parts.mass <> ?     @ v-mass
                buf_temp_place_parts-sum.qnty-all       @ v-qnty-all
                buf_temp_place_parts-sum.price-no-VAT   @ v-price-no-VAT
                buf_temp_place_parts-sum.sum-no-VAT     @ v-sum-no-VAT
                buf_temp_place_parts-sum.vat-pc         @ v-vat-pc
                buf_temp_place_parts-sum.sum-vat        @ v-sum-vat
                buf_temp_place_parts-sum.sum-all        @ v-sum-all
                buf_temp_place_parts-sum.sum-slt        @ v-sum-slt
                buf_temp_place_parts-sum.price-all      @ v-price-all
            with frame f-doc.
            down stream out-stream 1 with frame f-doc .
        end.        /* NOT ( if v-torgconf-outt12 = yes ) */
        assign
            p-out-itog-qnty-all   = p-out-itog-qnty-all   + buf_temp_place_parts-sum.qnty-all
            p-out-itog-sum-no-VAT = p-out-itog-sum-no-VAT + buf_temp_place_parts-sum.sum-no-VAT
            p-out-itog-sum-vat    = p-out-itog-sum-vat    + buf_temp_place_parts-sum.sum-vat
            p-out-itog-sum-all    = p-out-itog-sum-all    + buf_temp_place_parts-sum.sum-all
        .
    end.        /* for each buf_temp_place_parts-sum */
end.
end procedure. /* print-location-lines */

/*==========================================================================*/
procedure print-footer :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-itog-qnty-all      as decimal          no-undo.
define input parameter p-itog-sum-no-VAT    as decimal          no-undo.
define input parameter p-itog-sum-vat       as decimal          no-undo.
define input parameter p-itog-sum-all       as decimal          no-undo.

    define variable v-string-1          as character    no-undo.
    define variable v-string-2          as character    no-undo.
    define variable v-line-counter-text as character    no-undo.

    define buffer buf_clients   for clients.
    define buffer buf_firm      for firm.
    define buffer buf_sysconf   for sysconf.
    define buffer buf_trn-doc   for trn-doc.
do
for buf_clients
  , buf_firm
  , buf_sysconf
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    if PrintRubl
    then do:
        run rep/wp-rub.p (
              input p-itog-sum-all
            , output v-string-1
            , output v-string-2
        ).
    end.
    else do:
        run rep/wp.p (
              input p-mainmenu-handle
            , input p-itog-sum-all
            , output v-string-1
            , output v-string-2
        ).
    end.
    run rep/wp-qnty.p (
          input v-doc-line-counter
        , output v-line-counter-text
    ).
    put stream out-stream
        space(10) "  Всего на сумму:        "
            trim( string( p-itog-sum-all, "->>>,>>>,>>>,>>>,>>9.99") )  format "X(25)"
            " ("
            trim( if PrintRubl then "{&abbr_rub}" else "баз.вал" )              format "X(6)"
            ")"
    .
    if v-torgconf-outdisc = no
    then do:
        put stream out-stream
            substitute( "&1 &2 ( &3 )"
                , ( if ( if PrintRubl then buf_trn-doc.discnt-rubl else buf_trn-doc.tot-calc ) < 0
                         then ", наценка: "
                         else ", скидка: "  )
                , trim( string( absolute( ( if PrintRubl
                                            then buf_trn-doc.discnt-rubl
                                            else buf_trn-doc.tot-calc ) ), ">>>,>>>,>>>,>>>,>>9.99" ) )
                , trim( ( if PrintRubl then "{&abbr_rub}" else "баз.вал" ) )
             )                                                          format "X(100)"
        .
    end.
    put stream out-stream
        skip space(30)
            substitute( "НДС: &1 ( &2 )"
                        , trim( string( p-itog-sum-vat, "->>>,>>>,>>>,>>>,>>9.99") )
                        , trim( ( if PrintRubl then "{&abbr_rub}" else "баз.вал" ) )
            )                                                           format "X(160)"
    .
    define variable v-doc-places    as character    no-undo.
    define variable v-attr-type     as character    no-undo.
    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-qntyplace}
        v-doc-places
        v-attr-type
    }
    if v-doc-places = "":U
    then do:
        assign
            v-doc-places = v-underline
        .
    end.
    put stream out-stream
        skip(2)
        space(10) string( "Товарная накладная имеет приложение на " + v-underline ) format "X(125)" skip
        space(10) string( "и содержит " + CAPS( v-line-counter-text ) + " порядковый(ых) номер(ов) записей") format "X(180)" skip
        v-underline format "X(29)" at 151 skip
        string( "Масса груза (нетто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip
        space(10) string( "Всего мест " + v-doc-places ) format "X(45)"
                string( "Масса груза (брутто) " + v-underline ) format "X(85)" at 60
                string( "|" + v-underline ) format "X(30)" at 150 "|" skip(1)
        string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( v-underline, "X(42)" ) + " листах" ) format "X(95)" "|" at 97
            string( "По доверенности N " + string( v-underline, "X(39)" ) + " от " + v-underline ) format "X(100)" at 99 skip
        "Всего отпущено на сумму " format "X(95)" "|" at 97 string( "выданной " + v-underline ) format "X(100)" at 99 skip
        space(2) CAPS( v-string-1 ) format "X(93)" "|" at 97 skip
    .
/*    if p-mode = "mag"*/
/*    then do:*/
        define variable v-main-boss  as character     no-undo.
        define variable v-main-buh   as character     no-undo.
        find first buf_clients no-lock
             where buf_clients.obj-type = {&cmp}
               and buf_clients.obj-code = buf_trn-doc.host-code
        .
        find first buf_firm no-lock
                where buf_firm.firm-code = buf_clients.obj-code
        .
        assign
            v-main-boss = buf_firm.director
            v-main-buh  = buf_firm.gen-acct
        .
        find first buf_sysconf no-lock
             where buf_sysconf.host-code = v-host-code
        .
        assign
            v-main-buh  = buf_sysconf.snr-accnt
        .
        put stream out-stream
            string( "Отпуск разрешил  Ген. директор: ___________________ / " + ( if v-torgconf-outsubs = no then v-main-boss else "" ) ) format "X(93)" "/ |" at 95 skip
            string( "Главный бухгалтер: ________________________________ / " + ( if v-torgconf-outsubs = no then v-main-buh  else "" ) ) format "X(93)" "/ |" at 95 skip
            string( "Отпуск груза произвел кладовщик: " + v-underline  ) format "X(95)" "|" at 97
            "|" at 97 string( "Груз принял " + v-underline ) format "X(100)" at 99 skip
            v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99 skip
            "М.П." at 15  "|" at 97 "М.П." at 99 skip
        .
/*    end.*/
/*    else do:*/
/*        put stream out-stream*/
/*            string( "Отпуск разрешил " + v-underline ) format "X(95)" "|" at 97*/
/*            skip "|" at 97 string( "Груз принял " + v-underline ) format "X(100)" at 99*/
/*            skip v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99*/
/*            skip "М.П." at 15  "|" at 97 "М.П." at 99*/
/*        .*/
/*    end.*/

end.
end procedure. /* print-footer */

/*==========================================================================*/
procedure print-sub-itog :
define input parameter p-itog-qnty-all      as decimal          no-undo.
define input parameter p-itog-sum-no-VAT    as decimal          no-undo.
define input parameter p-itog-sum-vat       as decimal          no-undo.
define input parameter p-itog-sum-all       as decimal          no-undo.
define input parameter p-single-line        as character        no-undo.
do
on error undo, return error
:
    put stream out-stream
        skip p-single-line  format "X(198)" at 1
    .
    if v-torgconf-outt12 = yes
    then do:
        display stream out-stream
            "Всего по накладной"    @ v-gds-name
            p-itog-qnty-all         @ v-qnty-all
            p-itog-sum-no-VAT       @ v-sum-no-VAT
            p-itog-sum-vat          @ v-sum-VAT
            p-itog-sum-all          @ v-sum-all
        with frame f-doc-m.
        down stream out-stream 1 with frame f-doc-m .
    end.        /* if v-torgconf-outt12 = yes */
    else do:
        display stream out-stream
            "Всего по накладной"    @ v-gds-name
            p-itog-qnty-all         @ v-qnty-all
            p-itog-sum-no-VAT       @ v-sum-no-VAT
            p-itog-sum-vat          @ v-sum-VAT
            p-itog-sum-all          @ v-sum-all
        with frame f-doc.
        down stream out-stream 1 with frame f-doc .
    end.        /* NOT ( if v-torgconf-outt12 = yes ) */

end.
end procedure. /* print-sub-itog */