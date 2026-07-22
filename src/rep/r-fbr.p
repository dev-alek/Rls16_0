block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fbr.p $
$Archive: rep/r-fbr.p $

Акт производства готовой продукции

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle    no-undo.
define input parameter p-fbr-doc-recid      as recid     no-undo.
define input parameter p-print-in-rubl      as logical   no-undo.
define input parameter p-print-details      as logical   no-undo.
define input parameter p-fat                as logical   no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fbr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fbr.p $":U .
define variable vss-description as character no-undo init "Акт производства готовой продукции".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i new   }
{ ref/gds-attr.i     }
{ ref/gdsoattr.i     }
{ gbl/getcntxt.i def }
{ gbl/nutro.i        }

do
on error undo, return error return-value
:

&scoped-define r-fbr-form-width-rb 163
&scoped-define r-fbr-form-width-not-rb 127
&scoped-define r-fbr-width 160
&scoped-define r-fbr-form-width-rb-fat 198
&scoped-define r-fbr-form-width-not-rb-fat 162

    define variable type-det as character init {&write-off} no-undo.

    define variable v-title                             as character    no-undo.
    define variable v-prices-string                     as character    no-undo.
    define variable v-write-off-title                   as character    no-undo.
    define variable v-income-title                      as character    no-undo.
    define variable v-write-off-doc                     as character    no-undo.
    define variable v-income-doc                        as character    no-undo.
    define variable v-doc-code                          as character    no-undo.
    define variable v-doc-date                          as date         no-undo.
    define variable v-barcode                           as character    no-undo.
    define variable v-is-waste                          as character    no-undo.
    define variable v-counter                           as integer      no-undo.
    define variable v-line-string                       as character    no-undo.
    define variable v-host-code                         as integer      no-undo.
    define variable v-print-sale                        as logical      no-undo.

    define variable v-sum-qnty                          as decimal      no-undo.
    define variable v-price-cost-rb                     as decimal      no-undo.
    define variable v-price-cost-not-rb                 as decimal      no-undo.
    define variable v-sum-cost-rb                       as decimal      no-undo.
    define variable v-sum-cost-not-rb                   as decimal      no-undo.
    define variable v-sum-cost-vat-rb                   as decimal      no-undo.
    define variable v-sum-cost-vat-not-rb               as decimal      no-undo.
    define variable v-price-sale                        as decimal      no-undo.
    define variable v-sum-sale                          as decimal      no-undo.
    define variable v-tot-sum-write-off-cost-rubl       as decimal      no-undo.
    define variable v-tot-sum-write-off-cost-base       as decimal      no-undo.
    define variable v-tot-sum-write-off-costvat-rubl    as decimal      no-undo.
    define variable v-tot-sum-write-off-costvat-base    as decimal      no-undo.
    define variable v-tot-sum-write-off-price           as decimal      no-undo.
    define variable v-tot-sum-income-cost-rubl          as decimal      no-undo.
    define variable v-tot-sum-income-cost-base          as decimal      no-undo.
    define variable v-tot-sum-income-cost-vat-rubl      as decimal      no-undo.
    define variable v-tot-sum-income-cost-vat-base      as decimal      no-undo.
    define variable v-tot-sum-income-price              as decimal      no-undo.
    define variable v-fat                               as decimal      no-undo.
    define variable v-calories                          as decimal      no-undo.
    define variable v-protein                           as decimal      no-undo.
    define variable v-carbohydrate                      as decimal      no-undo.


    define variable v-artic                             as character        no-undo.
    define variable v-gds-name                          as character        no-undo.
    define variable v-unit-base                         as character        no-undo.
    define variable v-rb-is-base                        as logical init no  no-undo.

    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_goods     for ub.goods.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_clients for ub.clients.

define variable sym1  as character init "|"   no-undo.
define variable sym2  as character init "|"   no-undo.
define variable sym3  as character init "|"   no-undo.
define variable sym4  as character init "|"   no-undo.
define variable sym5  as character init "|"   no-undo.
define variable sym6  as character init "|"   no-undo.
define variable sym7  as character init "|"   no-undo.
define variable sym8  as character init "|"   no-undo.
define variable sym9  as character init "|"   no-undo.
define variable sym10 as character init "|"   no-undo.
define variable sym11 as character init "|"   no-undo.
define variable sym12 as character init "|"   no-undo.
define variable sym13 as character init "|"   no-undo.
define variable sym14 as character init "|"   no-undo.
define variable sym15 as character init "|"   no-undo.
define variable sym16 as character init "|"   no-undo.
define variable sym17 as character init "|"   no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define stream Outstream.

define frame fbr-in-rb
    sym1                    column-label "|!|"                      format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                    format ">>9"            space(0)
    sym2                    column-label "|!|"                      format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                    format "X(3)"           space(0)
    sym3                    column-label "|!|"                      format "X(1)"           space(0)
    v-barcode               column-label "Код! "                    format "X({&BarCode_Length})" space(0)
    sym4                    column-label "|!|"                      format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                format "X(16)"          space(0)
    sym5                    column-label "|!|"                      format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "        format "X(39)"          space(0)
    sym6                    column-label "|!|"                      format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                  format "X(3)"           space(0)
    sym7                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "             format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                      format "X(1)"           space(0)
    v-price-cost-rb         column-label "Уч.цена!без НДС"          format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-rb           column-label "Сумма уч.цен!без НДС"     format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-vat-rb       column-label "Сумма НДС! "              format ">>>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                      format "X(1)"           space(0)
    v-price-sale            column-label "Прод. цена! "             format ">,>>>,>>9.99"   space(0)
    sym12                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-sale              column-label "Сумма прод.!цен "         format ">>>,>>>,>>9.99" space(0)
    sym13                   column-label "|!|"                      format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           v-prices-string at 112 format "X(30)"
           string( "Страница " + string( page-number( OutStream ), ">>9" ) ) at  150 format "X(14)"
    skip v-line-string format  "X({&r-fbr-form-width-rb})" AT 1
with width {&DOS_CW} down stream-io NO-BOX.

define frame fbr-not-in-rb
    sym1                    column-label "|!|"                          format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                        format ">>9"            space(0)
    sym2                    column-label "|!|"                          format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                        format "X(3)"           space(0)
    sym3                    column-label "|!|"                          format "X(1)"           space(0)
    v-barcode               column-label "Код! "                        format "X({&BarCode_Length})" space(0)
    sym4                    column-label "|!|"                          format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                    format "X(16)"          space(0)
    sym5                    column-label "|!|"                          format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "            format "X(31)"          space(0)
    sym6                    column-label "|!|"                          format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                      format "X(3)"           space(0)
    sym7                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "                 format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                          format "X(1)"           space(0)
    v-price-cost-not-rb     column-label "Уч.цена!без НДС"              format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-not-rb       column-label "Сумма уч.цен!без НДС"         format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-vat-not-rb   column-label "Сумма НДС! "                  format ">>>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                          format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>9" ) ) at 114 format "X(14)"
    skip v-prices-string at 5 format "X(30)"
    skip v-line-string format  "X({&r-fbr-form-width-not-rb})" AT 1
with width {&A4_CW0} down stream-io NO-BOX.

define frame fbr-in-rb-fat
    sym1                    column-label "|!|"                      format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                    format ">>9"            space(0)
    sym2                    column-label "|!|"                      format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                    format "X(3)"           space(0)
    sym3                    column-label "|!|"                      format "X(1)"           space(0)
    v-barcode               column-label "Код! "                    format "X({&BarCode_Length})" space(0)
    sym4                    column-label "|!|"                      format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                format "X(16)"          space(0)
    sym5                    column-label "|!|"                      format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "        format "X(39)"          space(0)
    sym6                    column-label "|!|"                      format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                  format "X(3)"           space(0)
    sym7                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "             format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                      format "X(1)"           space(0)
    v-price-cost-rb         column-label "Уч.цена!без НДС"          format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-rb           column-label "Сумма уч.цен!без НДС"     format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-cost-vat-rb       column-label "Сумма НДС! "              format ">>,>>>,>>9.99" space(0)
    sym11                   column-label "|!|"                      format "X(1)"           space(0)
    v-price-sale            column-label "Прод. цена! "             format ">,>>>,>>9.99"   space(0)
    sym12                   column-label "|!|"                      format "X(1)"           space(0)
    v-sum-sale              column-label "Сумма прод.!цен "         format ">>>,>>>,>>9.99" space(0)
    sym13                   column-label "|!|"                      format "X(1)"           space(0)
    v-calories              column-label "Калории! "                format ">>>>>>>9"       space(0)
    sym14                   column-label "|!|"                      format "X(1)"           space(0)
    v-protein               column-label "Белки! "                  format ">>>>>9.9"       space(0)
    sym15                   column-label "|!|"                      format "X(1)"           space(0)
    v-fat                   column-label "Жиры! "                   format ">>>>>9.9"       space(0)
    sym16                   column-label "|!|"                      format "X(1)"           space(0)
    v-carbohydrate          column-label "Углеводы! "               format ">>>>>9.9"       space(0)
    sym17                   column-label "|!|"                      format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           v-prices-string at 112 format "X(30)"
           string( "Страница " + string( page-number( OutStream ), ">>9" ) ) at  150 format "X(14)"
    skip v-line-string format  "X({&r-fbr-form-width-rb-fat})" AT 1
with width {&A4_LS} down stream-io NO-BOX.

define frame fbr-not-in-rb-fat
    sym1                    column-label "|!|"                          format "X(1)"           space(0)
    v-counter               column-label "N!п/п"                        format ">>9"            space(0)
    sym2                    column-label "|!|"                          format "X(1)"           space(0)
    v-is-waste              column-label "Отх! "                        format "X(3)"           space(0)
    sym3                    column-label "|!|"                          format "X(1)"           space(0)
    v-barcode               column-label "Код! "                        format "X({&BarCode_Length})" space(0)
    sym4                    column-label "|!|"                          format "X(1)"           space(0)
    v-artic                 column-label "Артикул! "                    format "X(16)"          space(0)
    sym5                    column-label "|!|"                          format "X(1)"           space(0)
    v-gds-name              column-label "Название товара! "            format "X(31)"          space(0)
    sym6                    column-label "|!|"                          format "X(1)"           space(0)
    v-unit-base             column-label "Ед.!изм"                      format "X(3)"           space(0)
    sym7                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-qnty              column-label "Количество! "                 format ">>,>>9.999"     space(0)
    sym8                    column-label "|!|"                          format "X(1)"           space(0)
    v-price-cost-not-rb     column-label "Уч.цена!без НДС"              format ">,>>>,>>9.99"   space(0)
    sym9                    column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-not-rb       column-label "Сумма уч.цен!без НДС"         format ">>>,>>>,>>9.99" space(0)
    sym10                   column-label "|!|"                          format "X(1)"           space(0)
    v-sum-cost-vat-not-rb   column-label "Сумма НДС! "                  format ">>,>>>,>>9.99"  space(0)
    sym11                   column-label "|!|"                          format "X(1)"           space(0)
    v-calories              column-label "Калории! "                    format ">>>>>>>9"       space(0)
    sym12                   column-label "|!|"                          format "X(1)"           space(0)
    v-protein               column-label "Белки! "                      format ">>>>>9.9"       space(0)
    sym13                   column-label "|!|"                          format "X(1)"           space(0)
    v-fat                   column-label "Жиры! "                       format ">>>>>9.9"       space(0)
    sym14                   column-label "|!|"                          format "X(1)"           space(0)
    v-carbohydrate          column-label "Углеводы! "                   format ">>>>>9.9"       space(0)
    sym15                   column-label "|!|"                          format "X(1)"           space(0)
HEADER
    cur-time-print() at 5  format "X(35)"
           v-title at 45 format "X(60)"
           string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>9" ) ) at 114 format "X(14)"
    skip v-prices-string at 5 format "X(30)"
    skip v-line-string format  "X({&r-fbr-form-width-not-rb-fat})" AT 1
with width {&A4_LS} down stream-io NO-BOX.


do
on error undo, return error
:
{ gbl/getcntxt.i get " " p-mainmenu-handle }

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_fbr-doc no-lock
     where recid( buf_fbr-doc ) = p-fbr-doc-recid
.
{ gbl/rbisbase.i
    v-rb-is-base
}
{ gbl/hostcode.i
    buf_fbr-doc.obj-type
    buf_fbr-doc.obj-code
    v-host-code
}

if ( v-rb-is-base = no  and p-print-in-rubl = yes )
or ( v-rb-is-base = yes and p-print-in-rubl = no  )
then do:
    assign
        v-print-sale = yes
    .
end.
else do:
    assign
        v-print-sale = no
    .
end.

if ( p-print-in-rubl = no and p-fat = no )
then do:
    { cmp/open-out.i stream Outstream " " {&CS_PS} }
end.
else do:
    { cmp/open-out.i stream Outstream " " {&LS_PS_A4} }
end.

{ gbl/working.i }

if p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      assign
         v-line-string = fill( "-", {&r-fbr-form-width-rb-fat} )
      .
   end.
   else do:
      assign
         v-line-string = fill( "-", {&r-fbr-form-width-not-rb-fat} )
      .
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      assign
         v-line-string = fill( "-", {&r-fbr-form-width-rb} )
      .
   end.
   else do:
      assign
         v-line-string = fill( "-", {&r-fbr-form-width-not-rb} )
      .
   end.
END.

form header
    v-line-string format "X({&r-fbr-form-width-not-rb})" at 1 skip
    "Продолжение - на следующей странице" at 30
with frame Bottomframe width {&A4_CW0} page-bottom no-labels no-box .
view stream Outstream frame Bottomframe .

find first buf_trn-doc no-lock
     where buf_trn-doc.out-code = buf_fbr-doc.doc-code
no-error.
assign
    v-doc-code      = buf_fbr-doc.doc-code
    v-doc-date      = ( if buf_fbr-doc.status_ = {&fact} then buf_fbr-doc.fact-date else buf_fbr-doc.doc-date )
    v-write-off-doc = (if buf_fbr-doc.status_ = {&fact} then string( "(по накладной N " + buf_fbr-doc.doc-code + ")" ) else "" )
    v-income-doc    = (if buf_fbr-doc.status_ = {&fact} and available buf_trn-doc then string( "(по накладной N " + buf_trn-doc.doc-code + ")" ) else "" )
.

case buf_fbr-doc.doc-type:
    when {&dressing}
    then do:
            assign
                v-title = "Акт производства полуфабрикатов N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары, списанные для производства"
                type-det = {&income}
            .
    end.
    when "Разукомплектация"
    then do:
            assign
                v-title = "Акт разукомплектации N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары списанные"
                type-det = {&income}
            .
    end.
    when {&manufacturing}
    then do:
            assign
                v-title = "Акт производства готовой продукции N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары, списанные для производства"
                type-det = {&write-off}
            .
    end.
    when {&gathering}
    then do:
            assign
                v-title = "Акт комплектации N: " + v-doc-code + " от " +  string( v-doc-date, "99/99/9999" )
                v-write-off-title = "Товары списанные"
                type-det = {&write-off}
            .
    end.
end case.
assign
    v-prices-string = "Цены указаны в " + ( if p-print-in-rubl = yes then "{&abbr_rublyah}" else "базовой валюте" )
    v-income-title  = "Товары произведенные"
.

find first buf_clients no-lock
     where buf_clients.obj-type = buf_fbr-doc.obj-type
       and buf_clients.obj-code = buf_fbr-doc.obj-code
.
put stream Outstream
    string( "Объект: (" + buf_fbr-doc.obj-type + " " + string(buf_fbr-doc.obj-code) + ") " + '"' + trim(buf_clients.obj-name) + '"' ) format "X({&r-fbr-width})"
    skip(2) space( 30 )
        caps( v-title ) format "X({&r-fbr-width})"
    skip(2)
        string( caps( v-write-off-title ) + " " + v-write-off-doc )         format "X({&r-fbr-width})"
    skip(1)
.
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      form with frame fbr-in-rb-fat.
   end.
   else do:
      form with frame fbr-not-in-rb-fat.
   end.
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      form with frame fbr-in-rb.
   end.
   else do:
      form with frame fbr-not-in-rb.
   end.
END.
if p-print-details = yes
and type-det = {&write-off}
then do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = {&write-off}
    break by buf_fbr-line.recipe-code
    :
        assign
            v-counter = v-counter + 1
        .
        IF p-fat
        THEN DO:
            run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                           , input  buf_fbr-line.prod-type
                                                           , input  buf_fbr-line.prod-code
                                                           , input  v-cntxt-obj-type
                                                           , input  v-cntxt-obj-code
                                                           , output v-calories
                                                           , output v-protein
                                                           , output v-carbohydrate
                                                           , output v-fat
                                                           ).

        END.
        ELSE DO:
            ASSIGN
              v-fat          = 0
              v-calories     = 0
              v-protein      = 0
              v-carbohydrate = 0
            .
        END.
        run print-fbr-line in this-procedure (
              input recid( buf_fbr-line )
            , input v-counter
            , input p-print-in-rubl
            , input buf_fbr-line.is-waste
            , input buf_fbr-line.fact-qnty
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            , input ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
            , input v-print-sale
            , input v-fat
            , input v-calories
            , input v-protein
            , input v-carbohydrate
        ).
        assign
            v-tot-sum-write-off-cost-rubl      = v-tot-sum-write-off-cost-rubl    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-tot-sum-write-off-cost-base      = v-tot-sum-write-off-cost-base    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-tot-sum-write-off-costvat-rubl   = v-tot-sum-write-off-costvat-rubl + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-tot-sum-write-off-costvat-base   = v-tot-sum-write-off-costvat-base + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-tot-sum-write-off-price          = v-tot-sum-write-off-price        + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
    end.
end.        /* if p-print-details = yes and type-det = {&write-off} */
else do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = {&write-off}
    break by string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) )
    :
        if first-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-sum-qnty              = 0
                v-sum-cost-rb           = 0
                v-sum-cost-not-rb       = 0
                v-sum-cost-vat-rb       = 0
                v-sum-cost-vat-not-rb   = 0
                v-sum-sale              = 0
            .
        end.
        assign
            v-sum-qnty          = v-sum-qnty            + buf_fbr-line.fact-qnty
            v-sum-cost-rb     = v-sum-cost-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-sum-cost-not-rb     = v-sum-cost-not-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-sum-cost-vat-rb = v-sum-cost-vat-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-sum-cost-vat-not-rb = v-sum-cost-vat-not-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-sum-sale          = v-sum-sale            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
        if last-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-tot-sum-write-off-cost-rubl       = v-tot-sum-write-off-cost-rubl     + v-sum-cost-rb
                v-tot-sum-write-off-cost-base       = v-tot-sum-write-off-cost-base     + v-sum-cost-not-rb
                v-tot-sum-write-off-costvat-rubl    = v-tot-sum-write-off-costvat-rubl  + v-sum-cost-vat-rb
                v-tot-sum-write-off-costvat-base    = v-tot-sum-write-off-costvat-base  + v-sum-cost-vat-not-rb
                v-tot-sum-write-off-price           = v-tot-sum-write-off-price         + v-sum-sale
                v-counter = v-counter + 1
            .
            IF p-fat
            THEN DO:
              run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                             , input  buf_fbr-line.prod-type
                                                             , input  buf_fbr-line.prod-code
                                                             , input  v-cntxt-obj-type
                                                             , input  v-cntxt-obj-code
                                                             , output v-calories
                                                             , output v-protein
                                                             , output v-carbohydrate
                                                             , output v-fat
                                                             ).

            END.
            ELSE DO:
                  ASSIGN
                     v-fat          = 0
                     v-calories     = 0
                     v-protein      = 0
                     v-carbohydrate = 0
                  .
            END.
            run print-fbr-line in this-procedure (
                  input recid( buf_fbr-line )
                , input v-counter
                , input p-print-in-rubl
                , input buf_fbr-line.is-waste
                , input v-sum-qnty
                , input v-sum-cost-rb
                , input v-sum-cost-not-rb
                , input v-sum-cost-vat-rb
                , input v-sum-cost-vat-not-rb
                , input v-sum-sale
                , input v-print-sale
                , input v-calories
                , input v-protein
                , input v-carbohydrate
                , input v-fat
            ).
        end.        /* if last-of( */
    end.        /* for each buf_fbr-line */
end.        /* if p-print-details <> yes or type-det <> {&write-off} */
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      put stream outstream
         v-line-string   format "X({&r-fbr-form-width-rb-fat})"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-write-off-price               @ v-sum-sale
         with frame fbr-in-rb-fat.
      down stream outstream 1 with frame fbr-in-rb-fat.
   end.        /* if if p-print-in-rubl = yes */
   else do:
      put stream outstream
         v-line-string   format "X({&r-fbr-form-width-not-rb-fat})"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb-fat.
      down stream outstream 1 with frame fbr-not-in-rb-fat.
   end.        /* if p-print-in-rubl <> yes */
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      put stream outstream
         v-line-string   format "X({&r-fbr-form-width-rb})"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-write-off-price               @ v-sum-sale
         with frame fbr-in-rb.
      down stream outstream 1 with frame fbr-in-rb.
   end.        /* if if p-print-in-rubl = yes */
   else do:
      put stream outstream
         v-line-string   format "X({&r-fbr-form-width-not-rb})"
      .
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-cost-rubl
         else v-tot-sum-write-off-cost-base )    @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-write-off-costvat-rubl
         else v-tot-sum-write-off-costvat-base ) @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb.
      down stream outstream 1 with frame fbr-not-in-rb.
   end.        /* if p-print-in-rubl <> yes */
END.

assign
    v-counter = 0
.
IF p-fat
THEN DO:
   if v-print-sale
   then do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X({&r-fbr-form-width-rb-fat})"
         skip(1)
         v-line-string   format "X({&r-fbr-form-width-rb-fat})"
      .
      form with frame fbr-in-rb-fat.
   end.
   else do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X({&r-fbr-form-width-not-rb-fat})"
         skip(1)
         v-line-string   format "X({&r-fbr-form-width-not-rb-fat})"
      .
      form with frame fbr-not-in-rb-fat.
   end.
end.
ELSE DO:
   if v-print-sale
   then do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X({&r-fbr-form-width-rb})"
         skip(1)
         v-line-string   format "X({&r-fbr-form-width-rb})"
      .
      form with frame fbr-in-rb.
   end.
   else do:
      put stream Outstream
         skip
         string( caps( v-income-title ) + " " + v-income-doc ) format "X({&r-fbr-form-width-not-rb})"
         skip(1)
         v-line-string   format "X({&r-fbr-form-width-not-rb})"
      .
      form with frame fbr-not-in-rb.
   end.
END.

if p-print-details = yes
and type-det = {&income}
then do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = {&income}
    break by buf_fbr-line.recipe-code
    :
        assign
            v-counter = v-counter + 1
        .
         IF p-fat
         THEN DO:
            run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                           , input  buf_fbr-line.prod-type
                                                           , input  buf_fbr-line.prod-code
                                                           , input  v-cntxt-obj-type
                                                           , input  v-cntxt-obj-code
                                                           , output v-calories
                                                           , output v-protein
                                                           , output v-carbohydrate
                                                           , output v-fat
                                                           ).

         END.
         ELSE DO:
               ASSIGN
                  v-fat          = 0
                  v-calories     = 0
                  v-protein      = 0
                  v-carbohydrate = 0
               .
         END.
        run print-fbr-line in this-procedure (
              input recid( buf_fbr-line )
            , input v-counter
            , input p-print-in-rubl
            , input buf_fbr-line.is-waste
            , input buf_fbr-line.fact-qnty
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            , input ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            , input ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale )
            , input v-print-sale
            , input v-fat
            , input v-calories
            , input v-protein
            , input v-carbohydrate
        ).
        assign
            v-tot-sum-income-cost-rubl      = v-tot-sum-income-cost-rubl        + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-tot-sum-income-cost-base      = v-tot-sum-income-cost-base        + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-tot-sum-income-cost-vat-rubl  = v-tot-sum-income-cost-vat-rubl    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-tot-sum-income-cost-vat-base  = v-tot-sum-income-cost-vat-base    + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-tot-sum-income-price          = v-tot-sum-income-price            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
    end.
end.        /* if p-print-details = yes and type-det = {&income} */
else do:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
         and buf_fbr-line.trn-type = {&income}
    break by string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) )
    :
        if first-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-sum-qnty          = 0
                v-sum-cost-rb     = 0
                v-sum-cost-not-rb     = 0
                v-sum-cost-vat-rb = 0
                v-sum-cost-vat-not-rb = 0
                v-sum-sale          = 0
            .
        end.
        assign
            v-sum-qnty          = v-sum-qnty            + buf_fbr-line.fact-qnty
            v-sum-cost-rb     = v-sum-cost-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-rubl     )
            v-sum-cost-not-rb     = v-sum-cost-not-rb       + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-base     )
            v-sum-cost-vat-rb = v-sum-cost-vat-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-rubl )
            v-sum-cost-vat-not-rb = v-sum-cost-vat-not-rb   + ( if buf_fbr-line.is-waste = yes then 0 else buf_fbr-line.price-sum-vat-base )
            v-sum-sale          = v-sum-sale            + ( if buf_fbr-line.price-sale = ? then 0 else buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
        if last-of( string( buf_fbr-line.artic + buf_fbr-line.prod-type + string( buf_fbr-line.prod-code ) ) )
        then do:
            assign
                v-tot-sum-income-cost-rubl      = v-tot-sum-income-cost-rubl        + v-sum-cost-rb
                v-tot-sum-income-cost-base      = v-tot-sum-income-cost-base        + v-sum-cost-not-rb
                v-tot-sum-income-cost-vat-rubl  = v-tot-sum-income-cost-vat-rubl    + v-sum-cost-vat-rb
                v-tot-sum-income-cost-vat-base  = v-tot-sum-income-cost-vat-base    + v-sum-cost-vat-not-rb
                v-tot-sum-income-price          = v-tot-sum-income-price            + v-sum-sale
                v-counter                       = v-counter + 1
            .
            IF p-fat
            THEN DO:
              run nutro_get-nutrition-info in this-procedure ( input  buf_fbr-line.artic
                                                             , input  buf_fbr-line.prod-type
                                                             , input  buf_fbr-line.prod-code
                                                             , input  v-cntxt-obj-type
                                                             , input  v-cntxt-obj-code
                                                             , output v-calories
                                                             , output v-protein
                                                             , output v-carbohydrate
                                                             , output v-fat
                                                             ).
            END.
            ELSE DO:
                  ASSIGN
                     v-fat          = 0
                     v-calories     = 0
                     v-protein      = 0
                     v-carbohydrate = 0
                  .
            END.
            run print-fbr-line in this-procedure (
                  input recid( buf_fbr-line )
                , input v-counter
                , input p-print-in-rubl
                , input buf_fbr-line.is-waste
                , input v-sum-qnty
                , input v-sum-cost-rb
                , input v-sum-cost-not-rb
                , input v-sum-cost-vat-rb
                , input v-sum-cost-vat-not-rb
                , input v-sum-sale
                , input v-print-sale
                , input v-calories
                , input v-protein
                , input v-carbohydrate
                , input v-fat
            ).
        end.        /* if last-of( */
    end.        /* for each buf_fbr-line */
end.        /* if p-print-details <> yes or type-det <> {&income} */
IF p-fat
THEN DO:
   if v-print-sale = yes
   then do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X({&r-fbr-form-width-rb-fat})"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-income-price                @ v-sum-sale
         with frame fbr-in-rb-fat.
      down stream outstream 2 with frame fbr-in-rb-fat.
   end.        /* if p-print-in-rubl = no */
   else do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X({&r-fbr-form-width-not-rb-fat})"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base )  @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb-fat.
      down stream outstream 2 with frame fbr-not-in-rb-fat.
   end.        /* if p-print-in-rubl <> no */
END.
ELSE DO:
   if v-print-sale = yes
   then do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X({&r-fbr-form-width-rb})"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base ) @ v-sum-cost-vat-rb
         v-tot-sum-income-price                @ v-sum-sale
         with frame fbr-in-rb.
      down stream outstream 2 with frame fbr-in-rb.
   end.        /* if p-print-in-rubl = no */
   else do:
      if line-counter( Outstream ) <> 1
      then do:
        put stream outstream
          v-line-string format "X({&r-fbr-form-width-not-rb})"
        .
      end.
      display stream outstream
         "ИТОГО" @ v-gds-name
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-rubl
         else v-tot-sum-income-cost-base )     @ v-sum-cost-not-rb
         ( if p-print-in-rubl = yes
         then v-tot-sum-income-cost-vat-rubl
         else v-tot-sum-income-cost-vat-base )  @ v-sum-cost-vat-not-rb
      with frame fbr-not-in-rb.
      down stream outstream 2 with frame fbr-not-in-rb.
   end.        /* if p-print-in-rubl <> no */
END.
if v-print-sale = yes
then do:
    if line-counter( Outstream ) + 11 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.
end.
else do:
    if line-counter( Outstream ) + 8 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.
end.
put stream Outstream
    "Всего списано товаров (в учетных ценах) на сумму" ": " at 57
    ( if p-print-in-rubl = no
      then v-tot-sum-write-off-cost-base + v-tot-sum-write-off-costvat-base
      else v-tot-sum-write-off-cost-rubl + v-tot-sum-write-off-costvat-rubl
    ) format ">>>,>>>,>>>,>>>,>>9.99"
    skip
    "Всего произведено товаров (в учетных ценах) на сумму" ": " at 57
    ( if p-print-in-rubl = no
      then v-tot-sum-income-cost-base + v-tot-sum-income-cost-vat-base
      else v-tot-sum-income-cost-rubl + v-tot-sum-income-cost-vat-rubl
    ) format ">>>,>>>,>>>,>>>,>>9.99"
    skip(1)
.
if v-print-sale = yes
then do:
    put stream Outstream
        "Всего списано товаров (в продажных ценах) на сумму" ": " at 57 v-tot-sum-write-off-price format ">>>,>>>,>>>,>>>,>>9.99"
        skip
        "Всего произведено товаров (в продажных ценах) на сумму" ": " at 57 v-tot-sum-income-price  format ">>>,>>>,>>>,>>>,>>9.99"
        skip(1)
    .
end.
    put stream Outstream
        "Материально ответственное лицо: ____________________ "
        skip(1)
        "Бухгалтер: ____________________ "
        skip(1)
        "Обработал: ____________________ "
        skip(1)
    .
    hide stream Outstream frame Bottomframe .
    output stream Outstream close.
    { gbl/stopwork.i  }
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    if v-print-sale = yes or p-fat = yes
    then do:
        run gbl/prnfilen.w (
              input "":U
            , input 8
            , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
            , input 7
            , output v-user-action
            , output v-printed
        ) .
    end.
    else do:
        run gbl/prnfilen.w (
              input "":U
            , input 0
            , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
            , input 7
            , output v-user-action
            , output v-printed
        ) .
    end.
end.
end.
/*==========================================================================*/
procedure print-fbr-line :
do
on error undo, return error
:
define input parameter p-fbr-line-recid     as recid        no-undo.
define input parameter p-counter            as integer      no-undo.
define input parameter p-print-in-rubl      as logical      no-undo.
define input parameter p-is-waste           as logical      no-undo.
define input parameter p-fact-qnty          as decimal      no-undo.
define input parameter p-sum-cost-rubl      as decimal      no-undo.
define input parameter p-sum-cost-base      as decimal      no-undo.
define input parameter p-sum-cost-vat-rubl  as decimal      no-undo.
define input parameter p-sum-cost-vat-base  as decimal      no-undo.
define input parameter p-sum-sale           as decimal      no-undo.
define input parameter p-print-price-sale   as logical      no-undo.
define input parameter p-calories           as decimal      no-undo.
define input parameter p-protein            as decimal      no-undo.
define input parameter p-carbohydrate       as decimal      no-undo.
define input parameter p-fat-1              as decimal      no-undo.

    define variable v-bar-code              as character     no-undo.
    define variable v-print-sum-cost        as decimal       no-undo.
    define variable v-print-sum-cost-vat    as decimal       no-undo.

    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_goods     for ub.goods.

    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_fbr-line.artic
           and buf_goods.prod-type  = buf_fbr-line.prod-type
           and buf_goods.prod-code  = buf_fbr-line.prod-code
    .
    { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }.
    if p-print-in-rubl = yes
    then do:
        assign
            v-print-sum-cost        =  p-sum-cost-rubl
            v-print-sum-cost-vat    =  p-sum-cost-vat-rubl
        .
    end.
    else do:
        assign
            v-print-sum-cost        = p-sum-cost-base
            v-print-sum-cost-vat    = p-sum-cost-vat-base
        .
    end.
    IF p-fat
    THEN DO:
      if p-print-price-sale = yes
      then do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-rb
               sym11
               sym12 p-sum-sale                                                @ v-sum-sale
               sym13 p-calories     @ v-calories
               sym14 p-protein      @ v-protein
               sym15 p-fat-1        @ v-fat
               sym16 p-carbohydrate @ v-carbohydrate
               sym17

         with frame fbr-in-rb-fat.
         down stream OutStream 1 with frame fbr-in-rb-fat.
      end.        /* if p-print-in-rubl = yes */
      else do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-not-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-not-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-not-rb
               sym11 p-calories     @ v-calories
               sym12 p-protein      @ v-protein
               sym13 p-fat-1        @ v-fat
               sym14 p-carbohydrate @ v-carbohydrate
               sym15
         with frame fbr-not-in-rb-fat.
         down stream OutStream 1 with frame fbr-not-in-rb-fat.
      end.        /* if p-print-in-rubl <> yes */
    END.
    ELSE DO:
      if p-print-price-sale = yes
      then do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-rb
               sym11 p-sum-sale / p-fact-qnty                                  @ v-price-sale
               sym12 p-sum-sale                                                @ v-sum-sale
               sym13
         with frame fbr-in-rb.
         down stream OutStream 1 with frame fbr-in-rb.
      end.        /* if p-print-in-rubl = yes */
      else do:
         display stream OutStream
               sym1 p-counter                                                  @ v-counter
               sym2 " О"                       when p-is-waste = yes           @ v-is-waste
               sym3 string( v-bar-code )                                       @ v-barcode
               sym4 buf_fbr-line.artic                                         @ v-artic
               sym5 buf_goods.gds-name                                         @ v-gds-name
               sym6 buf_goods.unit-base                                        @ v-unit-base
               sym7 p-fact-qnty                                                @ v-sum-qnty
               sym8 v-print-sum-cost / p-fact-qnty                              @ v-price-cost-not-rb
               sym9 v-print-sum-cost                                            @ v-sum-cost-not-rb
               sym10 v-print-sum-cost-vat                                       @ v-sum-cost-vat-not-rb
               sym11
         with frame fbr-not-in-rb.
         down stream OutStream 1 with frame fbr-not-in-rb.
      end.        /* if p-print-in-rubl <> yes */
    END.
    if line-counter( Outstream ) + 2 > page-size( Outstream )
    then do:
      if p-fat
      then do:
        if v-print-sale = yes
        then do:
          put stream outstream
            v-line-string format "X({&r-fbr-form-width-rb-fat})"
          .
        end.
        else do:
          put stream outstream
            v-line-string format "X({&r-fbr-form-width-not-rb-fat})"
          .
        end.
      end.
      else do:
        if v-print-sale = yes
        then do:
          put stream outstream
            v-line-string format "X({&r-fbr-form-width-rb})"
          .
        end.
        else do:
          put stream outstream
            v-line-string format "X({&r-fbr-form-width-not-rb})"
          .
        end.
      end.
      page stream Outstream .
    end.
end.
end procedure. /* print-fbr-line */