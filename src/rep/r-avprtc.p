block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-avprtc.p $
$Archive: rep/r-avprtc.p $

Протокол согласования отпускных цен с округлением

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

Данная форма не работает при наличии налогов кроме НДС и НП.

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Discnt_Type          as integer          no-undo.
define input parameter NoProd               as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-avprtc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-avprtc.p $":U .
define variable vss-description as character no-undo init "Протокол согласования отпускных цен с округлением".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/breakstr.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i def }

define buffer t-doc      for ub.trn-doc.
DEFINE BUFFER cli-prod   for ub.clients .
DEFINE BUFFER Our_Host   for ub.clients .

DEFINE STREAM Out-Stream .


def     var     PriceWithTax    as   logical     no-undo.
def shared  var CostPrice as logical no-undo .
def shared  var PrintScale as logical no-undo .

def     buffer     OurObject   for       ub.clients .
def     var     tdoc-prt                as    logical      no-undo.

def     var     rootnode_code     as      integer       no-undo.

def     var     LineCounter   as      integer                 no-undo.
def     var     txt-LC   as      char                 no-undo.
def     var     s1   as      char                 no-undo.
def     var     s2   as      char                 no-undo.

def     var     Node_Code       like    ub.gds-prt.upper-code  no-undo.

def     var     price-noNDS     as  decimal     no-undo.
def     var     price-withNDS   as  decimal     no-undo.
def     var     tqnty                  as  decimal     no-undo.
def     var     stoim-noNDS     as  decimal     no-undo.
def     var     stoim                  as  decimal     no-undo.
def     var     prt-tqnty                  as  decimal     no-undo.
def     var     prt-VAT-gds        as  decimal     no-undo.
def     var     prt-SLT-gds        as  decimal     no-undo.
def     var     prt-stoim-noNDS     as  decimal     no-undo.
def     var     prt-stoim                  as  decimal     no-undo.

def     var     Pg-tqnty                as  decimal     init 0 no-undo.
def     var     Pg-VAT-gds      as  decimal     init 0 no-undo.
def     var     Pg-SLT-gds      as  decimal     init 0 no-undo.
def     var     Pg-stoim-noNDS   as  decimal     init 0 no-undo.
def     var     Pg-stoim               as  decimal     init 0 no-undo.
def     var     PrevPage              as  int             init 0 no-undo.

def     var     VAT-gds          as  decimal     no-undo.
def     var     SLT-gds          as  decimal     no-undo.

def     var     torg-SLT-pc       like  ub.doc-line.slt-pc  no-undo.


def var PrtName      as      char    no-undo.

def var OKEI      as      char    no-undo.
def var tb-code      as      char    no-undo.
def var pack-type      as      char    no-undo.
def var qnty-opl          as  decimal     no-undo.
def var qnty-pl          as  decimal     no-undo.
def var mass          as  decimal     no-undo.

def var sym1 as char init ":" no-undo.
def var sym2 as char init ":" no-undo.
def var sym3 as char init ":" no-undo.
def var sym4 as char init ":" no-undo.
def var sym5 as char init ":" no-undo.
def var sym6 as char init ":" no-undo.
def var sym7 as char init ":" no-undo.
def var sym8 as char init ":" no-undo.
def var sym9 as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.
def var sym12 as char init ":" no-undo.
def var sym13 as char init ":" no-undo.
def var sym14 as char init ":" no-undo.
def var sym15 as char init ":" no-undo.
def var sym16 as char init ":" no-undo.
def var sym17 as char init ":" no-undo.
def var sym18 as char init ":" no-undo.

def var Line      as      char    no-undo.
def var UndLine      as      char    no-undo.
def var B-DocCode     as      char            no-undo.
def var t-addres      as      char    no-undo.
def var t-phone      as      char    no-undo.
def var t-inn      as      char    no-undo.
def var t-okpo      as      char    no-undo.

def var gds-str as char no-undo.
def var gds-str1 as char no-undo.
def var gds-str2 as char no-undo.
def var unit-str as char no-undo.
def var prod-name as char no-undo.
def var val-str as char no-undo.

def var i as int no-undo.
def var j as int no-undo.
def var tdoc-date    like   ub.trn-doc.doc-date    no-undo.
def var tdoc-code    like   ub.trn-doc.doc-code    no-undo.

define variable v-sys-key as char no-undo.                  /* для чтения параметра конфигурации */
define variable tmp-var  as character no-undo .
define variable FullGdsName        as logical   no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

{ gbl/currsysk.i
  v-sys-key
  no-error
}


FIND t-doc WHERE recid( t-doc ) = rec_id  NO-LOCK .

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
FullGdsName = (tmp-var = "yes") .

&scop gds-len 30
DEFINE FRAME f-doc
        sym1 column-label ":!:" format "X(1)" space(0)
        LineCounter COLUMN-LABEL "N!п/п" format ">>9" space(0)
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(18)"
        ub.goods.gds-name COLUMN-LABEL "Наименование! " format "X({&gds-len})"
        cli-prod.obj-name COLUMN-LABEL "Производитель! " format "X(40)"
        sym9 column-label ":!:" format "X(1)"
        ub.units.long-name COLUMN-LABEL "Единица!измер. " format "X(7)"
        sym7 column-label ":!:" format "X(1)"
        price-withNDS COLUMN-LABEL "Цена за ед.! " format ">>>>>>>,>>9.99"
        sym8 column-label ":!:" format "X(1)" space(0)
    HEADER
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        tdoc-code AT 70 format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) AT 110 format "X(13)" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW} down stream-io.

Line = fill("-", 230) .
UndLine = fill("_", 230) .
LineCounter = 1 .
assign
  tdoc-code = t-doc.doc-code
  tdoc-date = (if t-doc.status_ <> {&fact} then t-doc.doc-date else t-doc.fact-date )
  .
  /*
message "Печатать цену с налогами ?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "" UPDATE PriceWithTax.
    */
FIND OurObject WHERE OurObject.obj-type = t-doc.obj-type AND
                                          OurObject.obj-code = t-doc.obj-code NO-LOCK NO-ERROR.
CASE OurObject.obj-type :
    when {&shop} then
        do:
            FIND ub.shop WHERE ub.shop.obj-code = OurObject.obj-code NO-LOCK .
            tdoc-prt = ub.shop.doc-prt.
        end.
    when {&stock} then
        do:
            FIND ub.store WHERE ub.store.obj-code = OurObject.obj-code NO-LOCK .
            tdoc-prt = ub.store.doc-prt .
        end.
END CASE.
FIND Our_Host WHERE Our_Host.obj-type = {&cmp} AND
                                       Our_Host.obj-code = t-doc.host-code NO-LOCK.

if NOT tdoc-prt then
    PrintScale = no .

if session:set-wait-state("compiler") then.
{ cmp/open-out.i STREAM Out-Stream } /* " " {&LS_PS_A4} */

FORM HEADER
    Line format "X(136)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM Out-Stream FRAME BottomFrame .


assign val-str = ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ).

FIND ub.clients WHERE ub.clients.obj-type = t-doc.cli-type AND
                   ub.clients.obj-code = t-doc.cli-code NO-LOCK.
PUT STREAM Out-Stream
    space(20)
    "П Р О Т О К О Л   СОГЛАСОВАНИЯ  СВОБОДНЫХ  ОТПУСКНЫХ  ЦЕН"
        format "X(100)" SKIP(1)
    SPACE(20) string( "между " + CAPS( Our_Host.obj-name ) + " и " + CAPS( ub.clients.obj-name ) )
        format "X(100)" SKIP(1)
    SPACE(40) string( "НАКЛАДНАЯ  N " + tdoc-code ) format "X(60)" SKIP(1) .
    .

FORM with frame f-doc .

FOR  EACH ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code NO-LOCK
                            BREAK &if "{&sort-prod}" = "yes" &then BY ( ub.doc-line.prod-type + string( ub.doc-line.prod-code ) ) &endif BY ub.doc-line.artic :
    FIND ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                     ub.goods.prod-code = ub.doc-line.prod-code AND
                     ub.goods.artic = ub.doc-line.artic NO-LOCK .
    FIND cli-prod WHERE cli-prod.obj-type = ub.doc-line.prod-type AND
                        cli-prod.obj-code = ub.doc-line.prod-code NO-LOCK .
    assign prod-name = (if NOT noprod then cli-prod.obj-name else "" ).

    FIND FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK no-error.

    if v-sys-key = "iab" then do:
      FIND ub.sysconf WHERE ub.sysconf.host-code = t-doc.host-code NO-LOCK.
      if t-doc.doc-type = {&expense} AND t-doc.internal = no AND t-doc.pay-code = ub.sysconf.cash-pay then
          assign torg-SLT-pc = 5.
      else
          assign torg-SLT-pc = 0.
    end.
    else do:
      assign torg-SLT-pc = ub.doc-line.SLT-pc.
    end.

    if FullGdsName then
        do:
            gds-str1 = breakstr(ub.goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).
            assign j = 0.
            DO WHILE gds-str2 <> "" :
                assign gds-str = gds-str2.
                gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
                assign j = j + 1.
            END. /* DO WHILE ... */
            if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then
              PAGE STREAM Out-Stream.
            gds-str1 = breakstr(ub.goods.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).
        end.
    else
        do:
            assign gds-str1 = ub.goods.gds-name.
        end.
    FIND ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
    rootnode_code = ub.gds-prt.node-code.

    if ( NOT can-do( {&empty-scale}, ub.gds-prt.node-name ) ) then
        do:     /* Т.е. не пустая шкала */
            if PrintScale then
                do:
                    DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            prod-name @ cli-prod.obj-name
                            sym1 sym2 sym7 sym8 sym9
                            with frame f-doc .
                    DOWN STREAM Out-Stream 1 with FRAME f-doc .
                    LineCounter = LineCounter + 1.
                end.
            if session:set-wait-state("compiler") then.
            FOR EACH ub.gds-dtl WHERE
                            ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
                            ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
                            ub.gds-dtl.artic = ub.doc-line.artic AND
                            ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK :
                FIND ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.

                if t-doc.doc-type = {&income} then
                    do:
                        { str/in-vatp.i calc ub.doc-line. t-doc. g }
                        assign price-noNDS = ( if PrintRubl then price-rubl-without-tax-loc else price-base-without-tax-loc ) .
                    end.
                else
                    do:
                        { str/out-vatp.i calc-ub.gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
                        assign price-noNDS = ( if PrintRubl then price-rubl-without-tax-sale else price-base-without-tax-sale ) .
                    end.
                assign
                  price-noNDS = round( price-noNDS , 2 )
                  prt-tqnty =  ub.gds-dtl.fact-qnty
                  VAT-gds = round( (price-noNDS * ub.doc-line.vat-pc / 100 ), 2 )
                  SLT-gds = round( ( (price-noNDS + VAT-gds) * prt-tqnty * torg-SLT-pc / 100 ), 2 )
                  price-withNDS = round( ( price-noNDS + VAT-gds + SLT-gds / prt-tqnty ) , 2 )
                  .
                if VAT-gds = ? then VAT-gds = 0.
                if SLT-gds = ? then SLT-gds = 0.
                assign
                    prt-VAT-gds = VAT-gds * prt-tqnty
                    prt-SLT-gds = SLT-gds
                    prt-stoim-noNDS = price-noNDS * prt-tqnty
                    prt-stoim = prt-stoim-noNDS + prt-VAT-gds
                    .
                ACCUMULATE
                    prt-tqnty (TOTAL)
                    prt-VAT-gds ( TOTAL )
                    prt-SLT-gds ( TOTAL )
                    prt-stoim-noNDS ( TOTAL )
                    prt-stoim ( TOTAL )
                    .
                if PrintScale then
                    do:
                        FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                                        AND ub.bar-code.unit-cli = ub.goods.unit-base
                                        AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                                        AND ub.bar-code.part-code = ""
                                        AND ub.bar-code.in-code = ""
                                      NO-LOCK .
                        PrtName = "".
                        DO WHILE available ub.gds-prt:
                            if available ub.gds-prt then
                                PrtName = "\" + string( ub.gds-prt.node-name, "x(10)" ) + PrtName.
                            Node_Code = ub.gds-prt.upper-code.
                            FIND ub.gds-prt WHERE ub.gds-prt.node-code = Node_Code
                                                               AND ub.gds-prt.root <> yes NO-LOCK NO-ERROR.
                        END.
                        DISPLAY STREAM Out-Stream
                                PrtName @ ub.goods.gds-name
                                string( ub.bar-code.b-code ) @ tb-code
                                ub.units.long-name
                                prod-name @ cli-prod.obj-name
                                (if PriceWithTax then price-withNDS else price-noNDS) @ price-withNDS
                                sym1 sym2 sym7 sym8 sym9
                                with frame f-doc .
                        DOWN STREAM Out-Stream 1 with FRAME f-doc .
                    end.

            END.        /*FOR EACH ub.gds-dtl ...*/

            assign
                tqnty = ( ACCUM TOTAL prt-tqnty )
                VAT-gds = ( ACCUM TOTAL prt-VAT-gds )
                SLT-gds = ( ACCUM TOTAL prt-SLT-gds )
                stoim-noNDS = ( ACCUM TOTAL prt-stoim-noNDS )
                stoim = ( ACCUM TOTAL prt-stoim )
                .

            if NOT PrintScale then
                do:
                    FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                                    AND ub.bar-code.unit-cli = ub.goods.unit-base
                                    AND ub.bar-code.node-code = rootnode_code
                                    AND ub.bar-code.part-code = ""
                                    AND ub.bar-code.in-code = ""
                                  NO-LOCK .
                    DISPLAY STREAM Out-Stream
                            LineCounter
                            gds-str1 @ ub.goods.gds-name
                            ub.goods.artic
                            string( ub.bar-code.b-code ) @ tb-code
                            prod-name @ cli-prod.obj-name
                            ub.units.long-name
                            (if PriceWithTax then price-withNDS else price-noNDS) @ price-withNDS
                            sym1 sym2 sym7 sym8 sym9
                            with frame f-doc .
                    DOWN STREAM Out-Stream 1 with FRAME f-doc .
                    LineCounter = LineCounter + 1 .
                end.
        end.
    else     /* пустая шкала */
        do:
            FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                            AND ub.bar-code.unit-cli = ub.goods.unit-base
                            AND ub.bar-code.node-code = rootnode_code
                            AND ub.bar-code.part-code = ""
                            AND ub.bar-code.in-code = ""
                          NO-LOCK .
                    FIND ub.gds-dtl where ub.gds-dtl.doc-code = ub.doc-line.doc-code
                                                    and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                                                    and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                                                    and ub.gds-dtl.artic = ub.doc-line.artic
                                                    and ub.gds-dtl.prt-code = rootnode_code NO-LOCK .
                    assign
                        tqnty = ub.gds-dtl.fact-qnty
                        unit-str = ub.goods.unit-base
                        .
                    if t-doc.doc-type = {&income} then
                        do:
                            { str/in-vatp.i calc ub.doc-line. t-doc. g }
                            assign price-noNDS = ( if PrintRubl then price-rubl-without-tax-loc else price-base-without-tax-loc ).
                        end.
                    else
                        do:
                            { str/out-vatp.i calc-ub.gds-dtl ub.doc-line. t-doc. ub.gds-dtl. }
                            assign price-noNDS = ( if PrintRubl then price-rubl-without-tax-sale else price-base-without-tax-sale ).
                        end.
                    assign
                      price-noNDS = round( price-noNDS , 2 )
                      VAT-gds = round( (price-noNDS * ub.doc-line.vat-pc / 100 ), 2 )
                      SLT-gds = round( ( (price-noNDS + VAT-gds) * tqnty * torg-SLT-pc / 100 ), 2 )
                      price-withNDS = round( ( price-noNDS + VAT-gds + SLT-gds / tqnty ) , 2 )
                      .
            if VAT-gds = ? then VAT-gds = 0.
            if SLT-gds = ? then SLT-gds = 0.
            assign
                VAT-gds = VAT-gds * tqnty
                stoim-noNDS = price-noNDS * tqnty
                stoim = stoim-noNDS + VAT-gds
                .

            DISPLAY STREAM Out-Stream
                LineCounter
                ub.goods.artic
                gds-str1 @ ub.goods.gds-name
                string( ub.bar-code.b-code ) @ tb-code
                prod-name @ cli-prod.obj-name
                ub.units.long-name
                (if PriceWithTax then price-withNDS else price-noNDS) @ price-withNDS
                sym1 sym2 sym7 sym8 sym9
                with frame f-doc .
            DOWN STREAM Out-Stream 1 with FRAME f-doc .
            LineCounter = LineCounter + 1.
        end.

    ACCUMULATE
        tqnty (TOTAL)
        VAT-gds ( TOTAL )
        SLT-gds ( TOTAL )
        stoim-noNDS ( TOTAL )
        stoim ( TOTAL )
        .
END.        /*FOR  EACH ub.doc-line ...*/

if line-counter( Out-Stream ) + 13 > page-size( Out-Stream ) then
    page STREAM Out-Stream .
PUT STREAM Out-Stream  Line format "X(136)" SKIP(1) SPACE(5) "Всего "
        ( LineCounter - 1 ) format ">,>>>,>>9" SPACE(2)
        "наименований" format "x(13)" SKIP(1) .

define variable v-user-name as character no-undo .

{ gbl/usrfulnm.i
  v-cntxt-userid
  v-user-name
}
PUT STREAM Out-Stream SKIP(1) SPACE(10) "Подписи сторон" format "x(100)" SKIP(1)
        SPACE(10) "Генеральный директор : " format "x(70)" SKIP(1)
        SPACE(10) "Планово-экономический отдел : " format "x(70)" SKIP(1)
        SPACE(10) "Управляющий  магазином : " format "x(70)" SKIP(3)
        SPACE(20) string( "Исполнитель : " + v-user-name ) format "x(70)" SKIP .

HIDE STREAM Out-Stream FRAME BottomFrame .
output STREAM Out-Stream CLOSE.

{ rep/q-print.i 0}