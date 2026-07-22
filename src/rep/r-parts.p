block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-parts.p $
$Archive: rep/r-parts.p $

Отчет по остаткам товаров

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-parts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-parts.p $":U .
define variable vss-description as character no-undo init "Отчет по остаткам товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ str/in-vatp.i def }
{ rep/v-suppl.i new new }
{ cmp/r-page1.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


DEFINE BUFFER buf-parts FOR ub.parts.
DEFINE BUFFER b-trn-doc FOR ub.trn-doc.
DEFINE BUFFER b-clients FOR ub.clients.

define variable counter as int init 0 no-undo.
define variable s-pay as char init "" no-undo.
define variable CliAll as log init NO no-undo.
define variable ri-list as char init "" no-undo.

define variable v-date AS CHARACTER NO-UNDO.
define variable rest-date AS DATE NO-UNDO.


define variable in-sum0 AS decimal no-undo.
define variable out-sum0 AS decimal no-undo.
define variable free-noNDS0 AS decimal no-undo.
define variable free-NDS0 AS decimal no-undo.
define variable free-sum0 AS decimal no-undo.
define variable in-sum AS decimal no-undo.
define variable out-sum AS decimal no-undo.
define variable free-sum AS decimal no-undo.

define variable avrg-price-rubl AS decimal no-undo.
define variable avrg-price-base AS decimal no-undo.
define variable sale-price-rubl AS decimal no-undo.
define variable sale-price-base AS decimal no-undo.

define variable fact-order1 like ub.stk-tot.fact-order no-undo .

define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.

define variable Line as char no-undo.

define variable v-today as date      no-undo.
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable base-type as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable glog as logical no-undo .
define buffer buf_rep_currency for ub.currency.


{ gbl/getcntxt.i get }
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
find first buf_rep_currency no-lock
where buf_rep_currency.curr-code = v-base-code
no-error .
if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
            else base-type = "б.в." .

DEFINE FRAME supp-gds
sym1 column-label ":!:" format "X(1)"
s-pay column-label " ! " format "X(20)"
sym2 column-label ":!:" format "X(1)"
suppl-gds.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<"
sym3 column-label ":!:" format "X(1)"
in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99"
sym4 column-label ":!:" format "X(1)"
in-sum COLUMN-LABEL "Приход сумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
sym5 column-label ":!:" format "X(1)"
suppl-gds.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<"
sym6 column-label ":!:" format "X(1)"
free-noNDS0 COLUMN-LABEL "Остаток сумма!уч. цен без НДС" FORMAT "->>>,>>>,>>9.99"
sym7 column-label ":!:" format "X(1)"
free-NDS0 COLUMN-LABEL "Остаток сумма!НДС" FORMAT "->>>,>>>,>>9.99"
sym8 column-label ":!:" format "X(1)"
free-sum0 COLUMN-LABEL "Остаток сумма!уч. цен c НДС" FORMAT "->>>,>>>,>>9.99"
sym9 column-label ":!:" format "X(1)"
free-sum COLUMN-LABEL "Остаток cумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
sym10 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Отчет по остаткам товаров" ) AT 45 format "X(95)"
string( "Cуммы указаны в " + (if PrintRubl then "{&abbr_rub}" else base-type) ) AT 145 format "X(20)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io.


assign PrintRubl = yes .
/*
if base-code <> 0 AND v-curr-r-b = {&r-b-base} then
    assign PrintRubl = no .
*/



run gbl/get-per.w (output glog, input-output v-from-date, input-output v-to-date) .
if NOT glog then  return.

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }

assign v-date = string( v-today ) .

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}

run gbl/d-prompt.w ( 'title=Введите дату\'
                             + 'text1=на которую требуется получить остаток\'
                             + 'format=99/99/9999\'
                             + 'type=date\'
                             + 'fillin_row=2.5\'
                             + 'fillin_col=17\'
                             ,input-output v-date
                           ).
if return-value = 'false':u then do:
  return .
end.
{ cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }
assign rest-date = date( v-date ).
  /* найдем fact-order  по дате */
define variable tmp#var  like ub.stk-tot.fact-qnty   no-undo.
Run ostatok  (
    input  v-cntxt-obj-code ,
    input  v-cntxt-obj-type ,
    input  false   ,
    input  rest-date ,
    input  ""        ,
    input  ?          ,
    input  ?           ,
    input  {&arh-crsa} ,
    input  {&root-cat-id} ,
    input  false     ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  tmp#var  ,
    output  Fact-order1 ).
message
"Печатать по всем поставщикам?"
view-as alert-box QUESTION BUTTONS YES-NO TITLE "" UPDATE CliAll.

if NOT CliAll then do:
  run ref/cli-all.w ( input parparentproc
                ,input "b-sel"
                ,input {&all}
                ,input {&all}
                ,input {&current}
                ,input ?
                ,input "yes,yes,yes,,,,ИЛИ"
                ,input ?
                ,output ri-list ) .

  if ri-list = "" then assign CliAll = no.
  else do:
      find b-clients where recid ( b-clients ) = integer( ri-list ) no-lock .
  end.
end.

run waitfram-show in this-procedure ( "Подождите..." ).
FOR EACH ub.trn-doc WHERE
        ub.trn-doc.host-code = v-cntxt-host-code-obj
    AND ub.trn-doc.status_ = {&fact}
    AND ub.trn-doc.fact-date >= v-from-date
    AND ub.trn-doc.fact-date <= v-to-date
    AND ub.trn-doc.doc-type = {&income}
    AND
        ( ub.trn-doc.internal = no
          OR ( ub.trn-doc.internal = yes AND ub.trn-doc.discnt-type = {&manufactured} )
        )
    OR
        ub.trn-doc.host-code = v-cntxt-host-code-obj
    AND ub.trn-doc.status_ = {&fact}
    AND ub.trn-doc.fact-date >= v-from-date
    AND ub.trn-doc.fact-date <= v-to-date
    AND ub.trn-doc.doc-type = {&inventory}
    NO-LOCK:
  if NOT CliAll AND NOT( ub.trn-doc.cli-type = b-clients.obj-type AND ub.trn-doc.cli-code = b-clients.obj-code ) then
        NEXT.
  FOR EACH ub.doc-line WHERE
          ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK:
    if ub.trn-doc.doc-type = {&inventory} and ub.doc-line.fact-qnty <= 0 then next.
    FIND ub.goods WHERE ub.goods.artic = ub.doc-line.artic
                                      AND ub.goods.prod-type = ub.doc-line.prod-type
                                      AND ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK.
    FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    assign
    sale-price-rubl = 0
    sale-price-base = 0
    .
    FIND LAST ub.price-list WHERE ub.price-list.obj-type = ub.trn-doc.obj-type
                                                    AND ub.price-list.obj-code = ub.trn-doc.obj-code
                                                    AND ub.price-list.artic = ub.goods.artic
                                                    AND ub.price-list.prod-type =  ub.goods.prod-type
                                                    AND ub.price-list.prod-code = ub.goods.prod-code
                                                    AND ub.price-list.b-code = ub.goods.gds-code
                                                    AND ub.price-list.fact-order <= fact-order1
                                                    USE-INDEX fact-close
                                                    NO-LOCK NO-ERROR.
    if available ub.price-list then do:
      if v-curr-r-b = {&r-b-rubl} then do:
          assign sale-price-rubl = ub.price-list.price-sale.
      end.
      else do:
          assign sale-price-base = ub.price-list.price-sale.
      end.
    end.

    FOR EACH ub.gds-dtl WHERE
            ub.gds-dtl.doc-code = ub.trn-doc.doc-code
        AND ub.gds-dtl.artic = ub.doc-line.artic
        AND ub.gds-dtl.prod-type = ub.doc-line.prod-type
        AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
        NO-LOCK:
      ACCUMULATE
      ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty (TOTAL)
      ub.gds-dtl.fact-qnty (TOTAL)
      .
    END. /* FOR EACH ub.gds-dtl WHERE ... */
    if v-curr-r-b = {&r-b-rubl} then do:
      assign
      avrg-price-rubl = ( ACCUM TOTAL ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ) / ( ACCUM TOTAL ub.gds-dtl.fact-qnty )
      avrg-price-base = avrg-price-rubl / ( ub.trn-doc.base-rate * ub.trn-doc.base-scale )
      .
    end.
    else do:
      assign
      avrg-price-base = ( ACCUM TOTAL ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ) / ( ACCUM TOTAL ub.gds-dtl.fact-qnty )
      avrg-price-rubl = avrg-price-base * ( ub.trn-doc.base-rate * ub.trn-doc.base-scale )
      .
    end.
    FOR EACH ub.parts WHERE
            ub.parts.obj-type = ub.trn-doc.obj-type
          AND ub.parts.obj-code = ub.trn-doc.obj-code
          AND ub.parts.artic = ub.doc-line.artic
          AND ub.parts.prod-type = ub.doc-line.prod-type
          AND ub.parts.prod-code = ub.doc-line.prod-code
          AND ub.parts.in-code = ub.trn-doc.doc-code
          AND ub.parts.out-code = ub.trn-doc.doc-code
          NO-LOCK:
      if ub.trn-doc.discnt-type = {&manufactured} then
      assign s-pay = {&manufacturing}.
      else do:
        if ub.parts.pay-code = integer({&consignation-code}) then
            assign s-pay = "консигнация".
        else
            assign s-pay = "выкуп".
      end.
      { str/in-vatp.i calc-parts parts. " " g }
      FIND suppl-gds WHERE
           suppl-gds.artic = ub.doc-line.artic
        AND suppl-gds.prod-type = ub.doc-line.prod-type
        AND suppl-gds.prod-code = ub.doc-line.prod-code
        AND suppl-gds.s-pay-type = s-pay NO-LOCK NO-ERROR.
      if NOT available suppl-gds then do:
        CREATE suppl-gds.
        assign
        suppl-gds.artic = ub.goods.artic
        suppl-gds.prod-type = ub.goods.prod-type
        suppl-gds.prod-code = ub.goods.prod-code
        suppl-gds.gds-name = ub.goods.gds-name
        suppl-gds.unit-base = ub.goods.unit-base
        suppl-gds.s-pay-type = s-pay
        suppl-gds.in-qnty = ub.parts.fact-qnty
        suppl-gds.in-NDS0-rubl = ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.in-NDS0-base = ub.parts.fact-qnty * vat-base-loc
        suppl-gds.in-sum0-rubl = ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.in-sum0-base = ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.out-qnty = 0
        suppl-gds.out-NDS0-rubl = 0
        suppl-gds.out-NDS0-base = 0
        suppl-gds.out-sum0-rubl = 0
        suppl-gds.out-sum0-base = 0
        suppl-gds.free-qnty = ub.parts.fact-qnty
        suppl-gds.free-NDS0-rubl = ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.free-NDS0-base = ub.parts.fact-qnty * vat-base-loc
        suppl-gds.free-sum0-rubl = ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.free-sum0-base = ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.in-sum-rubl = ub.parts.fact-qnty * avrg-price-rubl
        suppl-gds.in-sum-base = ub.parts.fact-qnty * avrg-price-base
        suppl-gds.out-sum-rubl = 0
        suppl-gds.out-sum-base = 0
        suppl-gds.price-sale = (if v-curr-r-b = {&r-b-base} then sale-price-base else sale-price-rubl)
        .
      end.
      else do:
        assign
        suppl-gds.in-qnty = suppl-gds.in-qnty + ub.parts.fact-qnty
        suppl-gds.in-NDS0-rubl = suppl-gds.in-NDS0-rubl + ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.in-NDS0-base = suppl-gds.in-NDS0-base + ub.parts.fact-qnty * vat-base-loc
        suppl-gds.in-sum0-rubl = suppl-gds.in-sum0-rubl + ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.in-sum0-base = suppl-gds.in-sum0-base + ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.free-qnty = suppl-gds.free-qnty + ub.parts.fact-qnty
        suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl + ub.parts.fact-qnty * vat-rubl-loc
        suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base + ub.parts.fact-qnty * vat-base-loc
        suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl + ub.parts.fact-qnty * price-rubl-with-tax-loc
        suppl-gds.free-sum0-base = suppl-gds.free-sum0-base + ub.parts.fact-qnty * price-base-with-tax-loc
        suppl-gds.in-sum-rubl = suppl-gds.in-sum-rubl + ub.parts.fact-qnty * avrg-price-rubl
        suppl-gds.in-sum-base = suppl-gds.in-sum-base + ub.parts.fact-qnty * avrg-price-base
        .
      end.

      FOR EACH buf-parts WHERE
              buf-parts.artic = ub.parts.artic
          AND buf-parts.prod-type = ub.parts.prod-type
          AND buf-parts.prod-code = ub.parts.prod-code
          AND buf-parts.in-code = ub.parts.in-code
          AND buf-parts.out-code <> ub.parts.out-code
          AND buf-parts.part-code = ub.parts.part-code
          AND buf-parts.rsrv-free = ?
          AND buf-parts.doc-type <> {&act-overvalue}
          AND buf-parts.status_ = yes
          NO-LOCK:

        FIND b-trn-doc WHERE b-trn-doc.doc-code = buf-parts.out-code NO-LOCK.
        if ( b-trn-doc.internal = no
             OR ( b-trn-doc.doc-type = {&write-off}
                 AND b-trn-doc.internal = yes
                 AND b-trn-doc.discnt-type = {&manufactured} ) )
            AND b-trn-doc.fact-date < rest-date then  do:
            { str/in-vatp.i calc-parts buf-parts. " " g }
            CASE b-trn-doc.doc-type:
              WHEN {&expense}
              OR WHEN {&write-off}
              THEN do:
                  assign
                  suppl-gds.out-qnty = suppl-gds.out-qnty + buf-parts.fact-qnty
                  suppl-gds.out-NDS0-rubl = suppl-gds.out-NDS0-rubl + buf-parts.fact-qnty * vat-rubl-loc
                  suppl-gds.out-NDS0-base = suppl-gds.out-NDS0-base + buf-parts.fact-qnty * vat-base-loc
                  suppl-gds.out-sum0-rubl = suppl-gds.out-sum0-rubl + buf-parts.fact-qnty * price-rubl-with-tax-loc
                  suppl-gds.out-sum0-base = suppl-gds.out-sum0-base + buf-parts.fact-qnty * price-base-with-tax-loc
                  suppl-gds.free-qnty = suppl-gds.free-qnty - buf-parts.fact-qnty
                  suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl - buf-parts.fact-qnty * vat-rubl-loc
                  suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base - buf-parts.fact-qnty * vat-base-loc
                  suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl - buf-parts.fact-qnty * price-rubl-with-tax-loc
                  suppl-gds.free-sum0-base = suppl-gds.free-sum0-base - buf-parts.fact-qnty * price-base-with-tax-loc
                  .
              end.
              WHEN {&income}
              OR
              WHEN {&return}
              OR
              WHEN {&inventory}
              THEN do:
                assign
                suppl-gds.out-qnty = suppl-gds.out-qnty - buf-parts.fact-qnty
                suppl-gds.out-NDS0-rubl = suppl-gds.out-NDS0-rubl - buf-parts.fact-qnty * vat-rubl-loc
                suppl-gds.out-NDS0-base = suppl-gds.out-NDS0-base - buf-parts.fact-qnty * vat-base-loc
                suppl-gds.out-sum0-rubl = suppl-gds.out-sum0-rubl - buf-parts.fact-qnty * price-rubl-with-tax-loc
                suppl-gds.out-sum0-base = suppl-gds.out-sum0-base - buf-parts.fact-qnty * price-base-with-tax-loc
                suppl-gds.free-qnty = suppl-gds.free-qnty + buf-parts.fact-qnty
                suppl-gds.free-NDS0-rubl = suppl-gds.free-NDS0-rubl + buf-parts.fact-qnty * vat-rubl-loc
                suppl-gds.free-NDS0-base = suppl-gds.free-NDS0-base + buf-parts.fact-qnty * vat-base-loc
                suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl + buf-parts.fact-qnty * price-rubl-with-tax-loc
                suppl-gds.free-sum0-base = suppl-gds.free-sum0-base + buf-parts.fact-qnty * price-base-with-tax-loc
                .
              end.
            END CASE.
          end.
        END. /* FOR EACH buf-parts WHERE ... */
      END. /* FOR EACH ub.parts WHERE ... */
    END. /* FOR EACH ub.doc-line WHERE ... */
    assign counter = counter + 1.
    run waitfram-show in this-procedure ( string( "Просмотрено документов: " + string( counter ) ) ).
  END.

/* Печать */

if session:set-wait-state("COMPILER") then.

assign Line = fill("-", {&DOS_CW_2}).

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM with FRAME supp-gds.

FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width {&DOS_CW_2}
PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .

PUT STREAM PrnLibStream
string( "О Т Ч Е Т   П О   О С Т А Т К А М  на: " + string(rest-date,"99/99/9999") ) AT 62 format "X(198)"
SKIP
string( "Период поставок с: " + string(v-from-date,"99/99/9999") + " по: " + string(v-to-date,"99/99/9999") )
            AT 62 format "X(198)"
SKIP(1)
.
PUT STREAM PrnLibStream " " SKIP.


FOR EACH suppl-gds NO-LOCK,
        EACH ub.goods WHERE
            ub.goods.artic = suppl-gds.artic
        AND ub.goods.prod-type = suppl-gds.prod-type
        AND ub.goods.prod-code = suppl-gds.prod-code
        NO-LOCK
BREAK
BY ub.goods.grp-name
BY suppl-gds.s-pay-type:

  if FIRST-OF (ub.goods.grp-name) then do:
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
    PUT STREAM PrnLibStream SPACE(20) string("Группа: " + ub.goods.grp-name) format "X(100)".
  end.

  ACCUMULATE
  suppl-gds.in-qnty (TOTAL)
  suppl-gds.in-NDS0-rubl (TOTAL)
  suppl-gds.in-NDS0-base (TOTAL)
  suppl-gds.in-sum0-rubl (TOTAL)
  suppl-gds.in-sum0-base (TOTAL)
  suppl-gds.in-sum-rubl (TOTAL)
  suppl-gds.in-sum-base (TOTAL)
  suppl-gds.out-qnty (TOTAL)
  suppl-gds.out-NDS0-rubl (TOTAL)
  suppl-gds.out-NDS0-base (TOTAL)
  suppl-gds.out-sum0-rubl (TOTAL)
  suppl-gds.out-sum0-base (TOTAL)
  suppl-gds.free-qnty (TOTAL)
  suppl-gds.free-NDS0-rubl (TOTAL)
  suppl-gds.free-NDS0-base (TOTAL)
  suppl-gds.free-sum0-rubl (TOTAL)
  suppl-gds.free-sum0-base (TOTAL)
  (suppl-gds.free-qnty * suppl-gds.price-sale) (TOTAL)

  suppl-gds.in-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.in-sum-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.out-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-qnty (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-NDS0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-NDS0-base (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-sum0-rubl (SUB-TOTAL BY ub.goods.grp-name )
  suppl-gds.free-sum0-base (SUB-TOTAL BY ub.goods.grp-name )
  (suppl-gds.free-qnty * suppl-gds.price-sale) (SUB-TOTAL BY ub.goods.grp-name )

  suppl-gds.in-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.in-sum-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.out-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-qnty (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-NDS0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-NDS0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-sum0-rubl (SUB-TOTAL BY suppl-gds.s-pay-type )
  suppl-gds.free-sum0-base (SUB-TOTAL BY suppl-gds.s-pay-type )
  (suppl-gds.free-qnty * suppl-gds.price-sale) (SUB-TOTAL BY suppl-gds.s-pay-type )
  .

  if LAST-OF (suppl-gds.s-pay-type) then do:
    if PrintRubl then do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum0-rubl)
      in-sum = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum-rubl)
      out-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.out-sum0-rubl)
      free-NDS0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-NDS0-rubl)
      free-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-sum0-rubl)
      free-sum = if v-curr-r-b = {&r-b-rubl}
                  then  (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    else do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum0-base)
      in-sum = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-sum-base)
      out-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.out-sum0-base)
      free-NDS0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-NDS0-base)
      free-sum0 = (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-sum0-base)
      free-sum = if v-curr-r-b = {&r-b-base}
                  then (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    DISPLAY STREAM PrnLibStream
    sym1
    suppl-gds.s-pay-type @ s-pay
    sym2
    (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.in-qnty) @ suppl-gds.in-qnty
    sym3
    in-sum0
    sym4
    in-sum
    sym5
    (ACCUM SUB-TOTAL BY suppl-gds.s-pay-type suppl-gds.free-qnty) @ suppl-gds.free-qnty
    sym6
    free-noNDS0
    sym7
    free-NDS0
    sym8
    free-sum0
    sym9
    free-sum
    sym10
    with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
  end.

  if LAST-OF (ub.goods.grp-name) then do:
    if PrintRubl then do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum0-rubl)
      in-sum = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum-rubl)
      out-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.out-sum0-rubl)
      free-NDS0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-NDS0-rubl)
      free-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-sum0-rubl)
      free-sum = if v-curr-r-b = {&r-b-rubl}
                  then (ACCUM SUB-TOTAL BY ub.goods.grp-name (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    else do:
      assign
      in-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum0-base)
      in-sum = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-sum-base)
      out-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.out-sum0-base)
      free-NDS0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-NDS0-base)
      free-sum0 = (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-sum0-base)
      free-sum = (if v-curr-r-b = {&r-b-base}
                  then (ACCUM SUB-TOTAL BY ub.goods.grp-name (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0)
      free-noNDS0 = free-sum0 - free-NDS0
      .
    end.
    DISPLAY STREAM PrnLibStream
    "Итого" @ s-pay
    (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.in-qnty) @ suppl-gds.in-qnty
    in-sum0
    in-sum
    (ACCUM SUB-TOTAL BY ub.goods.grp-name suppl-gds.free-qnty) @ suppl-gds.free-qnty
    free-noNDS0
    free-NDS0
    free-sum0
    free-sum
    with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
  end.
END.

if PrintRubl then do:
  assign
  in-sum0 = (ACCUM TOTAL suppl-gds.in-sum0-rubl)
  in-sum = (ACCUM TOTAL suppl-gds.in-sum-rubl)
  out-sum0 = (ACCUM TOTAL suppl-gds.out-sum0-rubl)
  free-NDS0 = (ACCUM TOTAL suppl-gds.free-NDS0-rubl)
  free-sum0 = (ACCUM TOTAL suppl-gds.free-sum0-rubl)
  free-sum = (if v-curr-r-b = {&r-b-rubl}
              then (ACCUM TOTAL (suppl-gds.free-qnty * suppl-gds.price-sale) )
              else 0)
  free-noNDS0 = free-sum0 - free-NDS0
  .
end.
else do:
  assign
  in-sum0 = (ACCUM TOTAL suppl-gds.in-sum0-base)
  in-sum = (ACCUM TOTAL suppl-gds.in-sum-base)
  out-sum0 = (ACCUM TOTAL suppl-gds.out-sum0-base)
  free-NDS0 = (ACCUM TOTAL suppl-gds.free-NDS0-base)
  free-sum0 = (ACCUM TOTAL suppl-gds.free-sum0-base)
  free-sum = (if v-curr-r-b = {&r-b-base}
                  then (ACCUM TOTAL (suppl-gds.free-qnty * suppl-gds.price-sale) )
                  else 0)
  free-noNDS0 = free-sum0 - free-NDS0
  .
end.

DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
DISPLAY STREAM PrnLibStream
"Итого по всем" @ s-pay
(ACCUM TOTAL suppl-gds.in-qnty) @ suppl-gds.in-qnty
in-sum0
in-sum
(ACCUM TOTAL suppl-gds.free-qnty) @ suppl-gds.free-qnty
free-noNDS0
free-NDS0
free-sum0
free-sum
with FRAME supp-gds .
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .

OUTPUT STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


{ rep/ostatok.i }