block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-12p.p $
$Archive: rep/torg-12p.p $

Топливная накладная.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: torg-12p.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/torg-12p.p $":U .
define variable vss-description as character no-undo initial "Топливная накладная.":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/dtm.i      }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ rep/r-cliprp.i def }
{ str/writelog.i def "''" }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/clcprtsl.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ rep/torgconf.i }


def buffer t-doc            for trn-doc.
def buffer buf_tax_parts    for parts.
def buffer buf_goods        for goods.

def stream out-stream .

def shared var sort-name    as logical                          no-undo.
def shared var sort-gr      as logical                          no-undo.

def buffer buf_clients for clients .

def var tdoc-prt            as logical                          no-undo.
def var tdoc-code           like trn-doc.doc-code               no-undo.
def var tdoc-date           like trn-doc.doc-date               no-undo.

def var v-line-counter      as integer                          no-undo.
def var v-doc-line-counter  as integer                          no-undo.
def var txt-LC              as char                             no-undo.
def var s1                  as char                             no-undo.
def var s2                  as char                             no-undo.

def var v-prt-name          as char                             no-undo.

def var v-tax-name          as char                             no-undo.
def var v-tax               like doc-line.road-tax      init 0  no-undo.
def var v-tax-sum           like doc-line.road-tax      init 0  no-undo.
def var v-parts-tax-qnty    like doc-line.doc-qnty      init 0  no-undo.
def var v-tax-parts-price   like doc-line.road-tax      init 0  no-undo.

define variable v-b-code                    as   character             no-undo.
define variable v-price                     like ub.gds-dtl.price-base no-undo.
define variable v-price-kg                  like ub.gds-dtl.price-base no-undo.
define variable v-qnty-kg                   like ub.doc-line.fact-qnty no-undo.
define variable v-sum-without-vat-slt       like ub.gds-dtl.price-base no-undo.
define variable v-sum-vat                   like ub.gds-dtl.price-base no-undo.
define variable v-sum-without-slt           like ub.gds-dtl.price-base no-undo.
define variable v-itogo-qnty                like ub.doc-line.fact-qnty no-undo.
define variable v-itogo-qnty-kg             like ub.doc-line.fact-qnty no-undo.
define variable v-itogo-sum-without-vat-slt like ub.gds-dtl.price-base no-undo.
define variable v-itogo-sum-vat             like ub.gds-dtl.price-base no-undo.
define variable v-itogo-sum-without-slt     like ub.gds-dtl.price-base no-undo.
define variable v-itogo-sum                 like ub.gds-dtl.price-base no-undo.
define variable v-page-qnty                 like ub.doc-line.fact-qnty no-undo.
define variable v-page-qnty-kg              like ub.doc-line.fact-qnty no-undo.
define variable v-page-sum-without-vat-slt  like ub.gds-dtl.price-base no-undo.
define variable v-page-sum-vat              like ub.gds-dtl.price-base no-undo.
define variable v-page-sum-without-slt      like ub.gds-dtl.price-base no-undo.
define variable v-print-doc                 as   character             no-undo.
define variable v-no-print-discnt           as   character             no-undo.
define variable prevpage                    as   integer initial 1     no-undo.

def var sym1                as char     init ":" no-undo.
def var sym2                as char     init ":" no-undo.
def var sym3                as char     init ":" no-undo.
def var sym4                as char     init ":" no-undo.
def var sym5                as char     init ":" no-undo.
def var sym6                as char     init ":" no-undo.
def var sym7                as char     init ":" no-undo.
def var sym8                as char     init ":" no-undo.
def var sym9                as char     init ":" no-undo.
def var sym10               as char     init ":" no-undo.
def var sym11               as char     init ":" no-undo.
def var sym12               as char     init ":" no-undo.
def var sym13               as char     init ":" no-undo.
def var sym14               as char     init ":" no-undo.
def var sym15               as char     init ":" no-undo.

def var v-single-line       as char              no-undo.
def var v-underline         as char              no-undo.
def var v-char-counter      as int               no-undo.

def var gds-str             as char              no-undo.
def var gds-str1            as char              no-undo.
def var gds-str2            as char              no-undo.
def var unit-str            as char              no-undo.
def var val-str             as char              no-undo.

define variable v-host-code     as integer       no-undo.
define variable v-curr-code     as integer       no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

find first t-doc where recid( t-doc ) = rec_id  no-lock .

define variable tmp-var     as character no-undo .
define variable type-par    as character no-undo .
define variable FullGdsName as logical   no-undo .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

run gbl/conf-rd.p ( "factur02", "", "", 0, "", "", "", no, output v-no-print-discnt, output type-par ) no-error.
if error-status :error
then do:
    assign
        v-no-print-discnt = "no"
    .
end.
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
run torgconf-read in this-procedure (
      input "torg12n"
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
run torgconf-get-form-header in this-procedure (
      input no
    , input t-doc.doc-code
    , input ( v-print-doc = "yes" )
    , input t-doc.doc-date
    , input t-doc.fact-date
    , input t-doc.doc-type
    , input t-doc.status_
    , input no
    , input no
).
&scop gds-len 29
define frame f-doc
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! ! ! " format ">>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len})" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-b-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-price-kg COLUMN-LABEL "Цена!реал-ии!за кг! ! " format "->>>>>9.99" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-price COLUMN-LABEL "Цена!реал-ии!за литр! ! " format "->>>>>>>9.99" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.fact-qnty COLUMN-LABEL "Количество!в литрах! ! ! " format "->>>>>9.<<<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.fact-density COLUMN-LABEL "Плотность!по замеру!в автоцист.!кг/л! " format "9.999" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.temperature COLUMN-LABEL "Температура!по замеру!в автоцист.!град! " format "->9.999" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-qnty-kg COLUMN-LABEL "Количество!в кг! ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        doc-line.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-sum-without-vat-slt column-label "Сумма!без!НДС! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-sum-vat column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-sum-without-slt column-label "Сумма!с учетом!  НДС! ! " format "->>>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
         header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + string(tdoc-date, "99/99/9999") ) at 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then
                  string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
              else
                  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(189)" at 1
    with width {&DOS_CW} down stream-io.


assign
    v-single-line = fill("-", 221)
    v-underline = fill("_", 221)
    v-line-counter = 1
    v-doc-line-counter = 0
.
assign
    val-str = ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" )
.

assign tdoc-code = t-doc.doc-code.
assign tdoc-date =  ( if t-doc.status_ <> {&fact} or v-print-doc = "yes"
                    then t-doc.doc-date
                    else t-doc.fact-date
                    )
.

find first buf_clients where buf_clients.obj-type = t-doc.obj-type and
                             buf_clients.obj-code = t-doc.obj-code no-lock no-error.
find first pay-type no-lock
     where pay-type.obj-code = t-doc.pay-code no-error .

{ gbl/working.i }

os-delete log-file-name.
run writelog in this-procedure (log-file-name, 0, "&Line").

{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

form header
    v-single-line format "X(198)" at 1 SKIP
    "Продолжение - на следующей странице" at 30 SKIP
    with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
view stream out-stream frame BottomFrame .

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.
{ rep/r-cliprp.i }
put stream out-stream
    space(5) v-single-line format  "X(19)" at 180 skip
    space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
    space(5) "Форма по ОКУД" format "X(14)" at 166 "| " at 180 "       " "|" at 198 skip
    space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" at 172 "| " at 180 t-okpo format "X(16)" "|" at 198 skip
    space(5) ( if t-doc.doc-type <> {&income} then
                       string( CAPS( buf_clients.obj-name ) + " (" + string(buf_clients.obj-code) + ")" )
                     else
                        " "
                    ) format "X(160)" "| " at 180  "|" at 198 skip
    space(5) "Вид деятельности по ОКДП" format "X(25)" at 155 "| " at 180 "|" at 198 skip
    .
    put stream out-stream
        space(5) v-torgconf-torg12-cargo-string    format "X(160)"
                "по ОКПО"                          format "X(7)"       at 172
                "| "                                                   at 180
                t-okpo                             format "X(16)"
                "|"                                                    at 198
        skip
    .
    define variable v-supplier    as character    no-undo.
    run fmtcli-get-bank in this-procedure (
          input v-host-code
        , input clients.obj-type
        , input clients.obj-code
        , input v-curr-code
    ).
    assign
        v-supplier = clients.obj-name
    .
    if v-fmtcli-schet-exists = yes
    then do:
        assign
            v-supplier = v-supplier
                + substitute( ", р/с &1 к/с &2"
                            , v-fmtcli-bank-r-schet
                            , v-fmtcli-bank-c-schet
                            )
        .
        if v-fmtcli-bank-exists = yes
        then do:
            assign
                v-supplier = v-supplier
                    + substitute( " БИК &1 в &2, &3"
                                , v-fmtcli-bank-bik
                                , v-fmtcli-bank-name
                                , v-fmtcli-bank-addres
                                )
            .
        end.
    end.
    put stream out-stream
        space(5)
            substitute( "Поставщик: &1", v-supplier ) format "X(160)"
            "по ОКПО" format "X(7)" at 172 "| " at 180 t-okpo format "X(16)" "|" at 198
        skip
    .
define variable v-attr-value  as character no-undo .
define variable v-attr-type   as character no-undo .
define variable v-osnov       as character initial "" no-undo .
if t-doc.doc-type = {&income} then  do:
  { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
  assign v-osnov = v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
  assign v-osnov = v-osnov + " от " + v-attr-value .
end.
find first clients no-lock
     where clients.obj-type = t-doc.cli-type
       and clients.obj-code = t-doc.cli-code
.
define variable v-saler    as character    no-undo.

    run fmtcli-get-bank in this-procedure (
          input v-host-code
        , input clients.obj-type
        , input clients.obj-code
        , input v-curr-code
    ).
    assign
        v-saler = clients.obj-name
    .
    if v-fmtcli-schet-exists = yes
    then do:
        assign
            v-saler = v-saler
                + substitute( ", р/с &1 к/с &2"
                            , v-fmtcli-bank-r-schet
                            , v-fmtcli-bank-c-schet
                            )
        .
        if v-fmtcli-bank-exists = yes
        then do:
            assign
                v-saler = v-saler
                    + substitute( " БИК &1 в &2, &3"
                                , v-fmtcli-bank-bik
                                , v-fmtcli-bank-name
                                , v-fmtcli-bank-addres
                                )
            .
        end.
    end.

put stream out-stream
    space(5) substitute( "Плательщик: &1", v-saler ) format "X(160)"
                    "по ОКПО" format "X(7)" at 172 "| " at 180 t-okpo format "X(16)" "|" at 198 skip
    space(5) string( "Основание: " + v-osnov ) format "X(160)"
                    "номер" format "X(5)" at 174 "| " at 180  "|" at 198 skip
    space(5) string( "Примечание: " + (if not( t-doc.PS BEGINS "@" ) then t-doc.PS else "" ) ) format "X(160)"
                    "дата" format "X(4)" at 175 "| " at 180 "|" at 198 skip
    space(5) string( "Вид оплаты: " + ( if available pay-type then pay-type.obj-name else "?" ) ) format "X(130)"
                    string( "Накладная на перемещение" ) format "X(24)" at 147
                    "номер" format "X(5)" at 174 "| " at 180 tdoc-code format "X(16)" "|" at 198 skip
    space(5) "дата" format "X(4)" at 175 "| " at 180 (if t-doc.status_ = {&fact} then t-doc.fact-date else ? ) format "99/99/9999" "|" at 198 skip
    space(5) "Вид операции" format "X(12)" at 167 "| " at 180 "расход" "|" at 198 skip
    space(5) v-single-line format  "X(19)" at 180 skip
    space(65) v-single-line format "X(33)" skip
    space(45) string( "РАСХОДНАЯ НАКЛАДНАЯ | "
                                + string( tdoc-code, "X(16)") + " | "
                                + string( tdoc-date, "99/99/9999")
                                + " | " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                ) format "X(100)" skip
    space(65) v-single-line format "X(33)"
    .
form with frame f-doc .
assign
  v-itogo-qnty                 = 0
  v-itogo-qnty-kg              = 0
  v-itogo-sum-without-vat-slt  = 0
  v-itogo-sum-vat              = 0
  v-itogo-sum-without-slt      = 0
.

if sort-gr = yes
then do:
    down stream out-stream 1 with frame f-doc .
end.
if sort-name = yes              /*Включена сортировка по имени*/
then do:
    if sort-gr = yes
    then do:
      run writelog in this-procedure (log-file-name, 1, "Сортировка по имени и группе").
      for each doc-line no-lock
          where doc-line.doc-code = t-doc.doc-code,
            each goods no-lock
          where goods.artic     = doc-line.artic
            and goods.prod-type = doc-line.prod-type
            and goods.prod-code = doc-line.prod-code
        break by goods.grp-name
              by goods.gds-name
        :
            if first-of (goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            assign v-doc-line-counter = v-doc-line-counter + 1.
            run print-line in this-procedure.
            assign
              v-itogo-qnty                = v-itogo-qnty                + doc-line.fact-qnty
              v-itogo-qnty-kg             = v-itogo-qnty-kg             + v-qnty-kg
              v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt + v-sum-without-vat-slt
              v-itogo-sum-vat             = v-itogo-sum-vat             + v-sum-vat
              v-itogo-sum-without-slt     = v-itogo-sum-without-slt     + v-sum-without-slt
            .
        end.
    end.
    else do:
        run writelog in this-procedure (log-file-name, 1, "Сортировка по имени (по группе нет)").
        for each doc-line no-lock
          where doc-line.doc-code = t-doc.doc-code,
            each goods no-lock
          where goods.artic     = doc-line.artic
            and goods.prod-type = doc-line.prod-type
            and goods.prod-code = doc-line.prod-code
        break by goods.gds-name
        :
            assign v-doc-line-counter = v-doc-line-counter + 1.
            run print-line in this-procedure.
            assign
              v-itogo-qnty                = v-itogo-qnty                + doc-line.fact-qnty
              v-itogo-qnty-kg             = v-itogo-qnty-kg             + v-qnty-kg
              v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt + v-sum-without-vat-slt
              v-itogo-sum-vat             = v-itogo-sum-vat             + v-sum-vat
              v-itogo-sum-without-slt     = v-itogo-sum-without-slt     + v-sum-without-slt
            .
        end.
    end.
end.                           /*Включена сортировка по имени*/
else do:                       /*Сортировка по имени выключена*/
    if sort-gr = yes
    then do:
        run writelog in this-procedure (log-file-name, 1, "Сортировка по группе (по имени нет)").
        for each doc-line no-lock
          where doc-line.doc-code = t-doc.doc-code,
            each goods no-lock
          where goods.artic     = doc-line.artic
            and goods.prod-type = doc-line.prod-type
            and goods.prod-code = doc-line.prod-code
          break by goods.grp-name
                by doc-line.artic
        :
            if first-of (goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            assign v-doc-line-counter = v-doc-line-counter + 1.
            run print-line in this-procedure.
            assign
              v-itogo-qnty                = v-itogo-qnty                + doc-line.fact-qnty
              v-itogo-qnty-kg             = v-itogo-qnty-kg             + v-qnty-kg
              v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt + v-sum-without-vat-slt
              v-itogo-sum-vat             = v-itogo-sum-vat             + v-sum-vat
              v-itogo-sum-without-slt     = v-itogo-sum-without-slt     + v-sum-without-slt
            .
        end.
    end.
    else do:
        run writelog in this-procedure (log-file-name, 1, "Сортировок по группе и по имени нет").
        for each doc-line no-lock
          where doc-line.doc-code = t-doc.doc-code,
            each goods no-lock
          where goods.artic     = doc-line.artic
            and goods.prod-type = doc-line.prod-type
            and goods.prod-code = doc-line.prod-code
          break by doc-line.line-num
        :
            assign v-doc-line-counter = v-doc-line-counter + 1.
            run print-line in this-procedure.
            assign
              v-itogo-qnty                = v-itogo-qnty                + doc-line.fact-qnty
              v-itogo-qnty-kg             = v-itogo-qnty-kg             + v-qnty-kg
              v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt + v-sum-without-vat-slt
              v-itogo-sum-vat             = v-itogo-sum-vat             + v-sum-vat
              v-itogo-sum-without-slt     = v-itogo-sum-without-slt     + v-sum-without-slt
            .
        end.
    end.
end.                           /*Сортировка по имени выключена*/

if line-counter( out-stream ) + 2 > page-size( out-stream ) then
do:
  { rep/torg-12p.i itog }
  page stream out-stream .
end.
{ rep/torg-12p.i itog }
hide stream out-stream frame BottomFrame .
display stream out-stream
    "Всего по накладной" @ goods.gds-name
    with frame f-doc .
down stream out-stream 2 with frame f-doc .

if PrintRubl then
    run rep/wp-rub.p ( v-itogo-sum, output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, v-itogo-sum , output s1, output s2 ) .
run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).

put stream out-stream
    space(10) "  Всего на сумму:        "
         trim( string( v-itogo-sum ), "->>>,>>>,>>>,>>>,>>9.99" ) format "X(25)"
         " ("
         ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) format "X(6)"
         ")"
.
if v-no-print-discnt = "no"
then do:
    put stream out-stream
                        string( if (if PrintRubl then t-doc.discnt-rubl else t-doc.tot-calc ) < 0
                        then ", наценка: "
                        else ", скидка: "
                        )
                        + (trim( string( ABS( ( if PrintRubl
                                                    then t-doc.discnt-rubl
                                                    else t-doc.tot-calc
                                                    )
                                                ), ">>>,>>>,>>>,>>>,>>9.99"
                                            )
                                    )
                          )
                        + " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")"

                                                                                            format "X(100)"
    .
end.
put stream out-stream
    skip
    space(15) string( "В том числе: " ) format "X(160)"
    skip
.
put stream out-stream
    skip
    space(30) string( "НДС: " + trim( string( (v-itogo-sum-vat), "->>>,>>>,>>>,>>>,>>9.99") ) +
                                " (" + trim( ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" ) ) + ")" ) format "X(160)" skip
.
run print-footer in this-procedure ( input v-host-code, input v-underline ).

{ gbl/stopwork.i }

output stream out-stream close.

{ rep/q-print.i 8 }

/*====================================================================*/
/*---S---------------- Печать линии в документе ----------------------*/
procedure print-line :
def var v-rootnode-code     as integer                          no-undo.
do
on error undo, return error return-value
:
run writelog in this-procedure (log-file-name, 1, "Печать строки товара").
if FullGdsName
then do:
    gds-str1 = breakstr(goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).
    assign v-char-counter = 0.
    do while gds-str2 <> "" :
        assign
            gds-str = gds-str2
            gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2)
            v-char-counter = v-char-counter + 1
        .
    end. /* do while ... */

    if line-counter( out-stream ) + v-char-counter > page-size( out-stream )
    then do:
        { rep/torg-12p.i itog}
        PAGE stream out-stream.
    end.

    assign
        gds-str1 = breakstr(goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
end.
else do:
    assign
        gds-str1 = goods.gds-name
    .
end.
find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
assign
  v-rootnode-code = gds-prt.node-code .
find first bar-code no-lock
     where bar-code.gds-code = goods.gds-code
       and bar-code.unit-cli = goods.unit-base
       and bar-code.node-code = v-rootnode-code
       and bar-code.part-code = ""
       and bar-code.in-code = ""
.

for each tt-allsum-line :
  delete tt-allsum-line.
end.
for each tt-allsum :
  delete tt-allsum.
end.
run clcprtsl_calc-line (recid(doc-line)).
find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error.
if available tt-allsum-line then do:
  if PrintRubl then do:
    display stream out-stream
    v-doc-line-counter
    goods.artic
    gds-str1 @ goods.gds-name
    string( bar-code.b-code ) @ v-b-code
    tt-allsum-line.sum-dsc-rubl-doc / tt-allsum-line.fact-qnty / doc-line.fact-density               @ v-price-kg
    tt-allsum-line.sum-dsc-rubl-doc / tt-allsum-line.fact-qnty                                       @ v-price
    tt-allsum-line.fact-qnty                                                                         @ doc-line.fact-qnty
    doc-line.fact-density
    doc-line.temperature
    tt-allsum-line.fact-qnty * doc-line.fact-density                                                 @ v-qnty-kg
    doc-line.VAT-pc
    tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.vat-rubl-doc - tt-allsum-line.slt-rubl-doc @ v-sum-without-vat-slt
    tt-allsum-line.vat-rubl-doc                                                                 @ v-sum-vat
    tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.slt-rubl-doc                               @ v-sum-without-slt
    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15
    with frame f-doc
    .
    assign
      v-itogo-qnty                = v-itogo-qnty                 + tt-allsum-line.fact-qnty
      v-itogo-qnty-kg             = v-itogo-qnty-kg              + tt-allsum-line.fact-qnty * doc-line.fact-density
      v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt  + tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.vat-rubl-doc - tt-allsum-line.slt-rubl-doc
      v-itogo-sum-vat             = v-itogo-sum-vat              + tt-allsum-line.vat-rubl-doc
      v-itogo-sum-without-slt     = v-itogo-sum-without-slt      + tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.slt-rubl-doc
      v-itogo-sum                 = v-itogo-sum                  + tt-allsum-line.sum-dsc-rubl-doc
      v-page-qnty                 = v-page-qnty                  + tt-allsum-line.fact-qnty
      v-page-qnty-kg              = v-page-qnty-kg               + tt-allsum-line.fact-qnty * doc-line.fact-density
      v-page-sum-without-vat-slt  = v-page-sum-without-vat-slt   + tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.vat-rubl-doc - tt-allsum-line.slt-rubl-doc
      v-page-sum-vat              = v-page-sum-vat               + tt-allsum-line.vat-rubl-doc
      v-page-sum-without-slt      = v-page-sum-without-slt       + tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.slt-rubl-doc
    .
  end.
  else do:
    display stream out-stream
    v-doc-line-counter
    goods.artic
    gds-str1 @ goods.gds-name
    string( bar-code.b-code ) @ v-b-code
    tt-allsum-line.sum-dsc-base-doc / tt-allsum-line.fact-qnty / doc-line.fact-density               @ v-price-kg
    tt-allsum-line.sum-dsc-base-doc / tt-allsum-line.fact-qnty                                       @ v-price
    tt-allsum-line.fact-qnty                                                                         @ doc-line.fact-qnty
    doc-line.fact-density
    doc-line.temperature
    tt-allsum-line.fact-qnty * doc-line.fact-density                                                 @ v-qnty-kg
    doc-line.VAT-pc
    tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.vat-base-doc - tt-allsum-line.slt-base-doc @ v-sum-without-vat-slt
    tt-allsum-line.vat-base-doc                                                                 @ v-sum-vat
    tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.slt-base-doc                               @ v-sum-without-slt
    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15
    with frame f-doc
    .
    assign
      v-itogo-qnty                = v-itogo-qnty                 + tt-allsum-line.fact-qnty
      v-itogo-qnty-kg             = v-itogo-qnty-kg              + tt-allsum-line.fact-qnty * doc-line.fact-density
      v-itogo-sum-without-vat-slt = v-itogo-sum-without-vat-slt  + tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.vat-base-doc - tt-allsum-line.slt-base-doc
      v-itogo-sum-vat             = v-itogo-sum-vat              + tt-allsum-line.vat-base-doc
      v-itogo-sum-without-slt     = v-itogo-sum-without-slt      + tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.slt-base-doc
      v-itogo-sum                 = v-itogo-sum                  + tt-allsum-line.sum-dsc-base-doc
      v-page-qnty                 = v-page-qnty                  + tt-allsum-line.fact-qnty
      v-page-qnty-kg              = v-page-qnty-kg               + tt-allsum-line.fact-qnty * doc-line.fact-density
      v-page-sum-without-vat-slt  = v-page-sum-without-vat-slt   + tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.vat-base-doc - tt-allsum-line.slt-base-doc
      v-page-sum-vat              = v-page-sum-vat               + tt-allsum-line.vat-base-doc
      v-page-sum-without-slt      = v-page-sum-without-slt       + tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.slt-base-doc
    .

  end.
  down stream out-stream 1 with frame f-doc .
end.
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-footer :
do
on error undo, return error
:
define input parameter p-host-code   as integer    no-undo.
define input parameter p-underline   as character    no-undo.

    define buffer buf_clients   for clients.
    define buffer buf_firm      for firm.
    define buffer buf_sysconf       for sysconf.

    define variable v-main-boss  as character     no-undo.
    define variable v-main-buh   as character     no-undo.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = p-host-code
    .
    find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
    .
    assign
        v-main-boss = buf_firm.director
        v-main-buh  = buf_firm.gen-acct
    .
    find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
    .
    assign
        v-main-buh  = buf_sysconf.snr-accnt
    .
    put stream out-stream
        "|" at 97 string( "Груз принял " + p-underline ) format "X(100)" at 99 skip
        "|" at 97 string( "М.П. " ) format "X(100)" at 99 skip
        string( "Отпуск разрешил_________________________________________________________________________________|" ) format "X(97)" skip
        "(менеджер по обеспечению нефтепродуктами)" at 40  "|" at 97 string( "Груз получил " + p-underline ) format "X(100)" at 99 skip
        string( "________________________________________________________________________________________________|" ) format "X(97)" skip
        "М.П." at 15  "|" at 97 "М.П." at 99 skip
   .
end.
end procedure. /* print-footer */

 /*==============================================================*/
/*---S-------- Печать линии группы в документе -----------------*/
procedure print-group-line :
do
on error undo, return error
:
  run writelog in this-procedure (log-file-name, 2, "Печать имени группы ( " + dtm-char(goods.grp-name) + " )" ).
  put stream out-stream
      skip
      ":" space(5)
      "Группа:" space(2)
      goods.grp-name
  .
end.
end procedure. /* print-group-line */
/*---E-------- Печать линии группы в документе -----------------*/