block-level on error undo, throw.
/*

$Revision: c017d5c290b6, 968, rls $
$Author: SSlivenko $
$Date: Tue Apr 18 18:36:56 2017 +0300 $
$Workfile: sjbysale.p $
$Archive: str/sjbysale.p $

Печать одной продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter ptwounit as logical no-undo .
define input parameter cas-shft as logical no-undo .
define output parameter p-frame-width as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: c017d5c290b6, 968, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 18 18:36:56 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sjbysale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sjbysale.p $":U .
define variable vss-description as character no-undo init "Печать одной продажи".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
my-handle = parparentproc.
{ rep/rep-bt.i }
{ rep/opclexcl.i }
{ cmp/breakstr.i }
{ str/sj-temp.i }
{ rep/r-cost.i }
{ gbl/cur-time.i }
{ rep/dincol.i def }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ str/shftnmef.i inkas shift-name }

define variable g#quest-print as logical no-undo .
define variable g#log as logical no-undo .

DEFINE VARIABLE Line                as character                    no-undo .
DEFINE VARIABLE cash_string         as character                    no-undo .
DEFINE VARIABLE sale_string         as character                     no-undo .
DEFINE VARIABLE date_string         as character                    no-undo .
DEFINE VARIABLE namebuf1            as character                    no-undo .
DEFINE VARIABLE namebuf2            as character                    no-undo .
DEFINE VARIABLE prodbuf1            as character                    no-undo .
DEFINE VARIABLE prodbuf2            as character                    no-undo .
DEFINE VARIABLE tdoc-code           like ub.trn-doc.doc-code        no-undo .
define variable ret-doc-code        like ub.trn-doc.doc-code        no-undo .
define variable v-doc-code          like ub.trn-doc.doc-code        no-undo .
DEFINE VARIABLE s-price             as decimal                      no-undo .
DEFINE VARIABLE cur-discnt          as decimal                      no-undo .
define variable wo-sum              as decimal                      no-undo .
DEFINE VARIABLE twounit-good        as logical                      no-undo .
DEFINE VARIABLE vat-value           like ub.doc-line.vat-pc         no-undo .
DEFINE VARIABLE slt-value           like ub.doc-line.slt-pc         no-undo .
DEFINE VARIABLE last-date           like ub.chk-doc.chk-date        no-undo .
DEFINE VARIABLE last-time           like ub.chk-doc.chk-time        no-undo .
define variable v-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v-other-base        like ub.ot-line.other-base      no-undo .
define variable v-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
DEFINE VARIABLE v-uchet-price       as decimal                      no-undo .
DEFINE VARIABLE v-lookup-cost       as logical                      no-undo .
DEFINE VARIABLE fill6               as character                    no-undo .
DEFINE VARIABLE fill10              as character                    no-undo .
DEFINE VARIABLE fill9               as character                    no-undo .
DEFINE VARIABLE fill11              as character                    no-undo .
DEFINE VARIABLE fill12              as character                    no-undo .
DEFINE VARIABLE fill13              as character                    no-undo .
DEFINE VARIABLE fill14              as character                    no-undo .
DEFINE VARIABLE fill15              as character                    no-undo .
DEFINE VARIABLE fill16              as character                    no-undo .
DEFINE VARIABLE fill44              as character                    no-undo .
DEFINE VARIABLE for-b-code          like ub.bar-code.b-code         no-undo .
DEFINE VARIABLE for-artic           like ub.goods.artic             no-undo .
DEFINE VARIABLE for-name            like ub.goods.gds-name          no-undo .
DEFINE VARIABLE for-prod-name       like ub.clients.obj-name        no-undo .
DEFINE VARIABLE for-qnty            as decimal                      no-undo .
DEFINE VARIABLE for-qnty-2          as decimal                      no-undo .
DEFINE VARIABLE for-obj-price       as decimal                      no-undo .
DEFINE VARIABLE for-brutto-sum      as decimal                      no-undo .
DEFINE VARIABLE for-discnt-sum      as decimal                      no-undo .
DEFINE VARIABLE for-pcnt            as decimal                      no-undo .
DEFINE VARIABLE for-netto-sum       as decimal                      no-undo .
DEFINE VARIABLE for-SLT-pc          like ub.doc-line.SLT-pc         no-undo .
DEFINE VARIABLE for-uchet-sum       as decimal                      no-undo .
define variable v-db-num            like ub.db.db-num               no-undo .



define buffer buf_inkas for ub.inkas .
define buffer b-tr-doc for ub.trn-doc .
define buffer buf_currency for ub.currency .
define buffer buf_curr-shop for ub.curr-shop .
define buffer buf_db for ub.db.
define buffer buf_sale-doc for ub.sale-doc.

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
    string( " , " ) format "X(3)" string(TIME, "HH:MM")
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME Doc
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.




&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-b-code fill9 ~} ~
      ~{ rep/dincol.i un 2 for-artic fill16~} ~
      ~{ rep/dincol.i un 3 for-name fill44~} ~
      ~{ rep/dincol.i un 4 for-prod-name fill15~} ~
      ~{ rep/dincol.i un 5 for-qnty fill11~} ~
      ~{ rep/dincol.i un 6 for-qnty-2 fill11~} ~
      ~{ rep/dincol.i un 7 for-obj-price fill11~} ~
      ~{ rep/dincol.i un 8 for-brutto-sum fill14~} ~
      ~{ rep/dincol.i un 9 for-discnt-sum fill12~} ~
      ~{ rep/dincol.i un 10 for-pcnt fill10~} ~
      ~{ rep/dincol.i un 11 for-netto-sum fill13~} ~
      ~{ rep/dincol.i un 12 for-SLT-pc fill6~} ~
      ~{ rep/dincol.i un 13 for-uchet-sum fill13~} ~
      DISPLAY stream  PrnLibStream with frame Doc. ~
      DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-b-code fill9 ~} ~
      ~{ rep/dincol.i unx 2 for-artic fill16~} ~
      ~{ rep/dincol.i unx 3 for-name fill44~} ~
      ~{ rep/dincol.i unx 4 for-prod-name fill15~} ~
      ~{ rep/dincol.i unx 5 for-qnty fill11~} ~
      ~{ rep/dincol.i unx 6 for-qnty-2 fill11~} ~
      ~{ rep/dincol.i unx 7 for-obj-price fill11~} ~
      ~{ rep/dincol.i unx 8 for-brutto-sum fill14~} ~
      ~{ rep/dincol.i unx 9 for-discnt-sum fill12~} ~
      ~{ rep/dincol.i unx 10 for-pcnt fill10~} ~
      ~{ rep/dincol.i unx 11 for-netto-sum fill13~} ~
      ~{ rep/dincol.i unx 12 for-SLT-pc fill6~} ~
      ~{ rep/dincol.i unx 13 for-uchet-sum fill13~} ~
      skip.


&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame Doc. ~
                                     DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.







do
on error undo, return error
:
  find first buf_inkas no-lock where
              buf_inkas.inkas-code = p-inkas-code no-error .
  if NOT available buf_inkas then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неправильный выбор кассового отчета."
    view-as alert-box WARNING .
    return error .
  end.
  { gbl/objdbnum.i buf_inkas.obj-type buf_inkas.obj-code v-db-num }

  if v-db-num <> v-cntxt-db-num then do:
    find first buf_db no-lock where
              buf_db.db-num = v-db-num .
    if buf_db.send-check = no then do:
      message
      string(substitute(
                        ("Отчет о продаже &1 создан в БД &2, из которой чеки по СПН не пересылаются" +
                          {&new-line} + "печать отчета о продаже невозможна")
                       , buf_inkas.inkas-code, v-db-num
                       )
           )
      view-as alert-box WARNING.

      return.
    end.
  end.
  run get-report-num in parparentproc ( output g#report-num).
  Line = fill("-", 250).
  run waitfram-show in this-procedure ( input "Подождите ..." ).

  FOR EACH sj-goods :
      delete sj-goods .
  END .
  FOR EACH d-slt-vat :
      delete d-slt-vat .
  END .
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }


  FIND b-tr-doc WHERE
      b-tr-doc.doc-code = buf_inkas.inkas-code NO-LOCK .
  assign
  tdoc-code = b-tr-doc.out-code
  .
  FIND b-tr-doc WHERE
       b-tr-doc.doc-code = tdoc-code NO-LOCK no-error .
  /*для старых*/
  if available b-tr-doc then
   ret-doc-code = b-tr-doc.out-code.
  _chk-doc:
  FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = buf_inkas.obj-type AND
            ub.chk-doc.obj-code = buf_inkas.obj-code AND
            ub.chk-doc.out-code = buf_inkas.inkas-code,
      EACH ub.chk-gds WHERE
            ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK,
      FIRST ub.bar-code WHERE
            ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK,
      FIRST ub.goods WHERE
            ub.goods.gds-code = ub.bar-code.gds-code
    by ub.chk-doc.obj-type
    by ub.chk-doc.obj-code
	by ub.chk-gds.b-code
    by ub.chk-doc.chk-date
    by ub.chk-doc.chk-time:
      v-doc-code = '':U.
      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      if num-entries(ub.chk-gds.line-type, {&delim-par}) > 1 then do:
        find first buf_sale-doc no-lock where
                  buf_sale-doc.inkas-code = buf_inkas.inkas-code
              and buf_sale-doc.doc-kind = entry(1, entry(2, ub.chk-gds.line-type, {&delim-par})) no-error .
        if available buf_sale-doc then do:
          assign
          v-doc-code = buf_sale-doc.doc-code.
        end.
      end.
      if v-doc-code = '':U then do:
        if chk-doc.netto >= 0 then
        v-doc-code = tdoc-code.
        else
        v-doc-code = ret-doc-code.
      end.

      assign
      last-date = ub.chk-doc.chk-date
      last-time = ub.chk-doc.chk-time
      .

      FIND FIRST ub.gds-dtl WHERE
                ub.gds-dtl.doc-code = v-doc-code AND
                ub.gds-dtl.artic = ub.goods.artic AND
                ub.gds-dtl.prod-type = ub.goods.prod-type AND
                ub.gds-dtl.prod-code = ub.goods.prod-code AND
                ub.gds-dtl.prt-code = ub.bar-code.node-code NO-LOCK NO-ERROR .
      if NOT available ub.gds-dtl then
      assign
      s-price = ub.chk-gds.price-base .
      FIND  FIRST ub.doc-line WHERE
                  ub.doc-line.doc-code = ub.gds-dtl.doc-code AND
                  ub.doc-line.prod-type = ub.gds-dtl.prod-type AND
                  ub.doc-line.prod-code = ub.gds-dtl.prod-code  AND
                  ub.doc-line.artic = ub.gds-dtl.artic NO-LOCK NO-ERROR.
      IF avail ub.gds-dtl then
      assign
      s-price = (if v-curr-r-b = {&r-b-base}
                 then ub.gds-dtl.price-base
                 else ub.gds-dtl.price-rubl).
      assign
      cur-discnt = ub.chk-gds.discnt + ( s-price - chk-gds.price-base )
      wo-sum = (if ub.chk-gds.write-off-code > 0 then 1 else - 1) *
               ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt)
      .

      .
      if ptwounit then do:
        FIND FIRSt ub.units No-LOCK WHERE
                  ub.units.unit-name = ub.goods.unit-base No-ERROR.
        if avail ub.units and (LOOKUP({&twounit}, ub.units.type) > 0 OR
                            LOOKUP({&altunit}, ub.units.type) > 0) then twounit-good = yes.
        else twounit-good = no.
      end.

      FIND FIRST sj-goods WHERE
                sj-goods.b-code = ub.bar-code.b-code AND
                sj-goods.obj-price = s-price AND
                sj-goods.discnt = cur-discnt AND
                sj-goods.is-out = (lookup(string(ub.chk-doc.chk-type), {&sale-out-receipt-codes}) > 0
                                  or
                                  ((ub.chk-doc.chk-type = ? or chk-doc.chk-type = 0)
                                    and ub.chk-doc.netto >= 0)
                                  )
                                    NO-ERROR .
      if NOT available sj-goods or twounit-good then do:
        FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.goods.prod-type AND
                  ub.clients.obj-code = ub.goods.prod-code NO-LOCK .
        { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ub.chk-doc.shift-date buf_inkas.host-code buf_inkas.obj-type buf_inkas.obj-code vat-value no-error }
        { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} ub.chk-doc.shift-date buf_inkas.host-code buf_inkas.obj-type buf_inkas.obj-code slt-value no-error }
        CREATE sj-goods.
        assign
        sj-goods.b-code = ub.bar-code.b-code
        sj-goods.artic = ub.goods.artic
        sj-goods.name = ub.goods.gds-name
        sj-goods.prod-name = trim( ub.clients.obj-name, '"' )
        sj-goods.obj-price = s-price
        sj-goods.discnt = cur-discnt
        sj-goods.VAT-pc = IF available(ub.doc-line) then ub.doc-line.VAT-pc else vat-value
        sj-goods.SLT-pc = IF available(ub.doc-line) then ub.doc-line.SLT-pc else SLT-value
        sj-goods.dop-rowid = IF twounit-good then rowid(ub.chk-gds) else sj-goods.dop-rowid
        .
        if available doc-line then do:
          run r-cost in this-procedure (
                                       input ub.doc-line.doc-code
                                      ,input ub.goods.artic
                                      ,input ub.goods.prod-type
                                      ,input ub.goods.prod-code
                                      ,output v-fact-qnty
                                      ,output v-vat-pc
                                      ,output v-slt-pc
                                      ,output v-sum-base
                                      ,output v-sum-rubl
                                      ,output v-vat-base
                                      ,output v-vat-rubl
                                      ,output v-slt-base
                                      ,output v-slt-rubl
                                      ,output v-road-tax-base
                                      ,output v-road-tax-rubl
                                      ,output v-transport-base
                                      ,output v-transport-rubl
                                      ,output v-other-base
                                      ,output v-other-rubl
                                      ,output v-excise-base
                                      ,output v-excise-rubl
                                      ).
          assign
          v-uchet-price = (if v-curr-r-b = {&r-b-base}
                           then v-sum-base
                           else v-sum-rubl)
                           / v-fact-qnty
          .
        end.
        else do:
          assign
          v-uchet-price = 0
          .
        end.
      end.
      assign
      sj-goods.qnty = sj-goods.qnty + ub.chk-gds.doc-qnty
      sj-goods.uchet-sum = sj-goods.uchet-sum + ub.chk-gds.doc-qnty * v-uchet-price
      sj-goods.qnty-2 = IF twounit-good
                        then (IF lookup({&twounit}, units.type) > 0
                              then (if ub.chk-gds.doc-qnty >= 0 then 1 else - 1 )
                              else goods.wt-cart * (if ub.chk-gds.doc-qnty >= 0 then 1 else - 1 )
                            )
                        else 0
      sj-goods.brutto-sum = sj-goods.brutto-sum + ( ub.chk-gds.doc-qnty * s-price )
      sj-goods.discnt-sum = sj-goods.discnt-sum + ( cur-discnt * ub.chk-gds.doc-qnty )
      sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt-sum
      sj-goods.write-off-sum = sj-goods.write-off-sum + wo-sum
      sj-goods.pcnt = round( ( sj-goods.discnt-sum / sj-goods.brutto-sum ) * 100, 1 )
      sj-goods.is-out = (lookup( string(ub.chk-doc.chk-type), {&sale-out-receipt-codes}) > 0
                         OR ((ub.chk-doc.chk-type = ?
                             or
                             ub.chk-doc.chk-type = 0)
                             and
                             ub.chk-doc.netto >= 0 ))
      .
      FIND FIRST d-slt-vat where d-slt-vat.SLT-pc = sj-goods.SLT-pc NO-LOCK NO-ERROR.
      IF NOT AVAILABLE d-slt-vat then do:
            create d-slt-vat.
            assign d-slt-vat.SLT-pc = sj-goods.SLT-pc.
      end.
      assign
      d-slt-vat.SLT-r-b-brutto =  d-slt-vat.SLT-r-b-brutto +  ub.chk-gds.doc-qnty * (s-price - cur-discnt) .

      ACCUMULATE ub.chk-doc.doc-code ( COUNT ) .
      if ( ( ACCUM COUNT ub.chk-doc.doc-code ) modulo 10 ) = 0 AND
            ( ACCUM COUNT ub.chk-doc.doc-code ) >= 10 then
      run waitfram-show in this-procedure ( input "Обработано строк чеков : " + string( ACCUM COUNT ub.chk-doc.doc-code ) ) .
  END.
  assign
  date_string = cur-time-print() .
  .
  for each d-slt-vat:
          ACCUMULATE d-slt-vat.slt-pc (COUNT).
  end.
  run waitfram-hide in this-procedure .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    buf_inkas.host-code
    buf_inkas.obj-type
    buf_inkas.obj-code
    0
    0
    0
    false
    v-lookup-cost
  }


  /*теперь напечатаем*/
  assign
  use-column[1] = yes
  use-column[2] = yes
  use-column[3] = yes
  use-column[4] = yes
  use-column[5] = yes
  use-column[6] = if ptwounit then yes else no
  use-column[7] = yes
  use-column[8] = yes
  use-column[9] = yes
  use-column[10] = yes
  use-column[11] = yes
  use-column[12] = no
  use-column[13] = if v-lookup-cost and buf_inkas.status_ = {&fact}
                   then yes
                   else no
  Make-excel = yes
  fill6  = fill("-", 6)
  fill10 = fill("-", 10)
  fill9  = fill("-", 9)
  fill11 = fill("-", 11)
  fill12 = fill("-", 12)
  fill13 = fill("-", 13)
  fill14 = fill("-", 14)
  fill15 = fill("-", 15)
  fill16 = fill("-", 16)
  fill44 = fill("-", 44)
  .

  FOR EACH sheetf where sheetf.sheet-num > 1:
    delete sheetf.
  end.

  FIND FIRST sheetf where
            sheetf.sheet-num = 1 No-ERROR.
  assign
  ReportName =
              fill({&space-char}, 25)  +
             substitute("ПРОДАЖИ   /   ВОЗВРАТЫ  по  отчету  N &1 за &2 &3 &4 &5"
                        ,buf_inkas.inkas-code
                        ,string(buf_inkas.doc-date, "99/99/9999")
                        ,(IF cas-shft
                          then substitute(", смена N &1", shift-name-no-err(buffer buf_inkas))
                          else "")
                        , substitute("факт. дата &1&2"
                                     , string(buf_inkas.fact-date)
                                     ,(if buf_inkas.status_ <> {&fact} and buf_inkas.status_ <> {&inquiry}
                                     then "(ожидается) "
                                     else '':U)
                                    )
                        ,(if buf_inkas.status_ <> {&fact} and buf_inkas.status_ <> {&inquiry}
                          then "(Отчет не закрыт)"
                          else ""
                         )
                       )
             + {&new-line} +
             fill({&space-char}, 25) +
             substitute("( по накладным &1, &2)"
                       ,buf_inkas.inkas-code
                       ,tdoc-code)
  sheetf.Excel-Column-Lable =  ""
  sheetf.colformat = "2=0":U
  sheetf.sizes = "".

  CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

  l-col-pos = 1.
  Assign l-col-type="integer" l-col-len=9 l-col-format= ">>>>>>>>9"     l-col-lable="Код".
    { rep/dincol.i cr  1    for-b-code  Doc                 }
    { rep/dincol.i crx 1 }
  Assign l-col-type="character" l-col-len=16 l-col-format= "X(16)"     l-col-lable="Артикул".
    { rep/dincol.i cr  2    for-artic  Doc                 }
    { rep/dincol.i crx 2 }
  Assign l-col-type="character" l-col-len=44 l-col-format= "X(44)"     l-col-lable="Наименование".
    { rep/dincol.i cr  3    for-name  Doc                 }
    { rep/dincol.i crx 3 }
  Assign l-col-type="character" l-col-len=15 l-col-format= "X(15)"     l-col-lable="Производитель".
    { rep/dincol.i cr  4    for-prod-name  Doc                 }
    { rep/dincol.i crx 4 }
  Assign l-col-type="decimal" l-col-len=11 l-col-format= "->>>>>9.<<<"     l-col-lable=
  if ptwounit
  then "Количество уч.ед.изм. "
  else "Количество"
  .

    { rep/dincol.i cr  5    for-qnty  Doc                 }
    { rep/dincol.i crx 5 }
  Assign l-col-type="decimal" l-col-len=11 l-col-format= "->>>>>9.<<<"     l-col-lable= "Количество доп.ед.изм.".
    { rep/dincol.i cr  6    for-qnty-2  Doc                 }
    { rep/dincol.i crx 6 }
  Assign l-col-type="decimal" l-col-len=11 l-col-format= ">>>>>>>9.99"     l-col-lable=
        (IF v-curr-r-b = {&r-b-base}
        then  "Цена (в Б.Вал.)"
        else  "Цена (в {&abbr_rublyah})")
  .
    { rep/dincol.i cr  7    for-obj-price  Doc                 }
    { rep/dincol.i crx 7 }
  Assign l-col-type="decimal" l-col-len=14 l-col-format= "->>>>>>>>>9.99"     l-col-lable=
       (IF v-curr-r-b = {&r-b-base}
        then    "Сумма (в Б.Вал.)"
        else  "Сумма (в {&abbr_rublyah})")
  .
    { rep/dincol.i cr  8    for-brutto-sum  Doc                 }
    { rep/dincol.i crx 8 }

  Assign l-col-type="decimal" l-col-len=12 l-col-format= "->>>>>>>9.99"     l-col-lable=
       (IF v-curr-r-b = {&r-b-base}
       then  "Скидка (в Б.Вал.)"
       else  "Скидка (в {&abbr_rublyah})")
  .
    { rep/dincol.i cr  9    for-discnt-sum  Doc                 }
    { rep/dincol.i crx 9 }
  Assign l-col-type="decimal" l-col-len=10 l-col-format= "->>>>>9.9%"     l-col-lable= "% скидки" .
    { rep/dincol.i cr  10    for-pcnt  Doc                 }
    { rep/dincol.i crx 10 }
  Assign l-col-type="decimal" l-col-len=13 l-col-format= "->>>>>>>>9.99"     l-col-lable=
       (IF v-curr-r-b = {&r-b-base}
        then "Нетто сумма (в Б.Вал.)"
        else "Нетто сумма (в {&abbr_rublyah})")
  .
    { rep/dincol.i cr  11    for-netto-sum  Doc                 }
    { rep/dincol.i crx 11 }
  Assign l-col-type="decimal" l-col-len=6 l-col-format= ">9.9%"     l-col-lable= "НП%" .
    { rep/dincol.i cr  12    for-SLT-pc  Doc                 }
    { rep/dincol.i crx 12 }

  Assign l-col-type="decimal" l-col-len=13 l-col-format= "->>>>>>>>9.99"     l-col-lable=
        (IF v-curr-r-b = {&r-b-base}
         then "Сумма уч.цен (в Б.Вал.)"
         else "Сумма уч.цен (в {&abbr_rublyah})")
  .
    { rep/dincol.i cr  13    for-uchet-sum  Doc                 }
    { rep/dincol.i crx 13}

  assign
  Line = fill( "-" , 250 )
  p-frame-width = l-col-pos - 1
  .

  run prn-lib-open-stream  in this-procedure (
                                               input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  if Make-Excel then
  RUN OpenForExcel in this-procedure .

  run waitfram-show in this-procedure ( input "Ждите...").
  run rep/extitle.p ( input 1).

  FORM with FRAME Doc .
  FORM HEADER
  Line format "X(60)" AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
  with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME NBottomFrame .
  PUT stream PrnLibStream UNFORMATTED
  Reportname
  SKIP(1).

  IF v-curr-r-b = {&r-b-rubl}  AND
   base-code = 0 then do:
  end.
  else do:

    PUT stream PrnLibStream UNFORMATTED
    "Курсы валют на дату/время последнего чека" {&space-char}
    "(":U
    string(last-date, "99/99/9999") {&space-char}
    string(last-time, "HH:MM")
    "):":U
    skip
    .
    {&PutExcel}
    "Курсы валют на дату/время последнего чека" {&space-char}
    "(":U
    string(last-date, "99/99/9999") {&space-char}
    string(last-time, "HH:MM")
    "):":U {&tabulation}
    skip
    .

    FOR EACH buf_currency No-LOCK where
            buf_currency.curr-code > 0 :
      FIND LAST buf_curr-shop WHERE
                buf_curr-shop.obj-type = buf_inkas.obj-type
            AND buf_curr-shop.obj-code = buf_inkas.obj-code
            AND buf_curr-shop.curr-code = buf_currency.curr-code
            AND ( ( buf_curr-shop.exch-date = last-date
                    AND
                    buf_curr-shop.exch-time <= last-time )
                    OR  buf_curr-shop.exch-date < last-date ) NO-ERROR .
      if available buf_curr-shop then do:
        PUT stream PrnLibStream unformatted
        buf_currency.curr-abbr {&space-char} "-":U {&space-char}
        buf_curr-shop.exch-rate {&space-char}
        "за" {&space-char} buf_curr-shop.exch-scale
        skip.
        {&PutExcel}
        buf_currency.curr-abbr {&tabulation}
        {&tabulation}
        string(buf_curr-shop.exch-rate) {&tabulation}
        "за" {&space-char} buf_curr-shop.exch-scale
        skip.
      end.
    END.
    {&putExcel}
    skip(2).
  end.

  display STREAM PrnLibStream with frame top-Frame .

  FOR EACH sj-goods
  use-index p2
  BREAK
  BY sj-goods.is-out DESCENDING :
    assign
    namebuf1 = breakstr(sj-goods.name, 18, input-output namebuf1, input-output  namebuf2)
    prodbuf1 = trim( breakstr(sj-goods.prod-name, 15, input-output prodbuf1, input-output prodbuf2), '"' )
    .

    { rep/dincol.i di 1 for-b-code sj-goods.b-code }
    { rep/dincol.i di 2 for-artic sj-goods.artic }
    { rep/dincol.i di 3 for-name namebuf1 }
    { rep/dincol.i di 4 for-prod-name prodbuf1 }
    { rep/dincol.i di 5 for-qnty sj-goods.qnty }
    { rep/dincol.i di 6 for-qnty-2 sj-goods.qnty-2 }
    { rep/dincol.i di 7 for-obj-price sj-goods.obj-price }
    { rep/dincol.i di 8 for-brutto-sum sj-goods.brutto-sum }
    if sj-goods.discnt-sum <> 0 then do:
      { rep/dincol.i di 9 for-discnt-sum sj-goods.discnt-sum }
    end.
    if sj-goods.discnt-sum <> 0 then do:
      { rep/dincol.i di 10 for-pcnt sj-goods.pcnt }
    end.
    { rep/dincol.i di 11 for-netto-sum sj-goods.netto-sum }
    { rep/dincol.i di 12 for-SLT-pc sj-goods.SLT-pc }
    { rep/dincol.i di 13 for-uchet-sum sj-goods.uchet-sum }
    {&DISPLAY-FRAME}

    {&PutExcel}
    { rep/dincol.i dix 1 for-b-code sj-goods.b-code }
    { rep/dincol.i dix 2 for-artic sj-goods.artic }
    { rep/dincol.i dix 3 for-name sj-goods.name }
    { rep/dincol.i dix 4 for-prod-name sj-goods.prod-name }
    { rep/dincol.i dix 5 for-qnty sj-goods.qnty }
    { rep/dincol.i dix 6 for-qnty-2 sj-goods.qnty-2 }
    { rep/dincol.i dix 7 for-obj-price sj-goods.obj-price }
    { rep/dincol.i dix 8 for-brutto-sum sj-goods.brutto-sum }
    { rep/dincol.i dix 9 for-discnt-sum sj-goods.discnt-sum }
    { rep/dincol.i dix 10 for-pcnt sj-goods.pcnt }
    { rep/dincol.i dix 11 for-netto-sum sj-goods.netto-sum }
    { rep/dincol.i dix 12 for-SLT-pc sj-goods.SLT-pc }
    { rep/dincol.i dix 13 for-uchet-sum sj-goods.uchet-sum }
    skip.

    prodbuf2 = trim( prodbuf2, '"' ).
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then do:
      { rep/dincol.i di 3 for-name namebuf2 }
      { rep/dincol.i di 4 for-prod-name prodbuf2 }
      {&DISPLAY-FRAME}
    end.
    ACCUMULATE
    sj-goods.qnty (TOTAL)
    sj-goods.qnty-2 (TOTAL)
    sj-goods.brutto-sum (TOTAL)
    sj-goods.discnt-sum (TOTAL)
    sj-goods.netto-sum (TOTAL)
    sj-goods.uchet-sum (TOTAL)
    sj-goods.qnty ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.qnty-2 ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.brutto-sum ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.discnt-sum ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.netto-sum ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.uchet-sum ( SUB-TOTAL BY sj-goods.is-out )
    .
    if last-of( sj-goods.is-out ) then do:
      {&UNDERLINE-FRAME}
      { rep/dincol.i di 3 for-name "string( 'Итого ' + ( if sj-goods.is-out then 'продажи' else 'возвраты' ) ) }
      { rep/dincol.i di 5 for-qnty "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty)" }
      { rep/dincol.i di 6 for-qnty-2 "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty-2)" }
      { rep/dincol.i di 8 for-brutto-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum)" }
      { rep/dincol.i di 9 for-discnt-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum)" }
      { rep/dincol.i di 10 for-pcnt

        "round( ( ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum) * 100 , 1 )"
         }
      { rep/dincol.i di 11 for-netto-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum)" }
      { rep/dincol.i di 13 for-uchet-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum)" }
      {&DISPLAY-FRAME}


      {&UNDERLINE-Excel}
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      { rep/dincol.i dix 3 for-name "string( 'Итого ' + ( if sj-goods.is-out then 'продажи' else 'возвраты' ) ) }
      {&tabulation}
      { rep/dincol.i dix 5 for-qnty "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty)" }
      { rep/dincol.i dix 6 for-qnty-2 "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty-2)" }
      {&tabulation}
      { rep/dincol.i dix 8 for-brutto-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum)" }
      { rep/dincol.i dix 9 for-discnt-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum)" }
      { rep/dincol.i dix 10 for-pcnt

        "round( ( ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum) * 100 , 1 )"
         }
      { rep/dincol.i dix 11 for-netto-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum)" }
      {&tabulation}
      { rep/dincol.i dix 13 for-uchet-sum "(ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum)" }
      skip.

      if NOT last( sj-goods.is-out ) then do:
        {&UNDERLINE-FRAME}
        {&UNDERLINE-Excel}
      end.
    end.
  END.


  PUT STREAM PrnLibStream Line format "X(":U + string(p-frame-width) + ")":U
  SKIP.
  {&PutExcel}
  Line format "X(":U + string(p-frame-width) + ")":U
  SKIP.

  if ( line-counter + 7 + 3 + ACCUM COUNT d-slt-vat.SLT-pc ) > page-size(PrnLibStream)
  then page stream PrnLibStream.

  { rep/dincol.i di 1 for-b-code "'':U" }
  { rep/dincol.i di 2 for-artic "'':U" }
  { rep/dincol.i di 3 for-name "'Списания'" }
  { rep/dincol.i di 11 for-netto-sum "(- buf_inkas.sub-discnt)" }
  {&DISPLAY-FRAME}
  {&UNDERLINE-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 1 for-b-code "'':U" }
  { rep/dincol.i dix 2 for-artic "'':U" }
  { rep/dincol.i dix 3 for-name "'Списания'" }
  {&tabulation}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  { rep/dincol.i dix 11 for-netto-sum "(- buf_inkas.sub-discnt)" }
  skip.


  { rep/dincol.i di 3 for-name "'ИТОГО'" }
  { rep/dincol.i di 5 for-qnty "(ACCUM TOTAL sj-goods.qnty)" }
  { rep/dincol.i di 6 for-qnty-2 "(ACCUM TOTAL sj-goods.qnty-2)" }
  { rep/dincol.i di 7 for-obj-price "'':U" }
  { rep/dincol.i di 8 for-brutto-sum "(ACCUM TOTAL sj-goods.brutto-sum)" }
  { rep/dincol.i di 9 for-discnt-sum "(ACCUM TOTAL sj-goods.discnt-sum)" }
  { rep/dincol.i di 10 for-pcnt
    "(round( ( ACCUM TOTAL sj-goods.discnt-sum ) /
          (ACCUM TOTAL sj-goods.brutto-sum ) * 100 , 1 ))"
   }
  { rep/dincol.i di 11 for-netto-sum "((ACCUM TOTAL sj-goods.netto-sum ))" }
  { rep/dincol.i di 13 for-uchet-sum "(ACCUM TOTAL sj-goods.uchet-sum)" }
  {&DISPLAY-FRAME}
  {&UNDERLINE-FRAME}

  {&PutExcel}
  {&tabulation}
  {&tabulation}
  { rep/dincol.i dix 3 for-name "'ИТОГО'" }
  {&tabulation}
  { rep/dincol.i dix 5 for-qnty "(ACCUM TOTAL sj-goods.qnty)" }
  { rep/dincol.i dix 6 for-qnty-2 "(ACCUM TOTAL sj-goods.qnty-2)" }
  { rep/dincol.i dix 7 for-obj-price "'':U" }
  { rep/dincol.i dix 8 for-brutto-sum "(ACCUM TOTAL sj-goods.brutto-sum)" }
  { rep/dincol.i dix 9 for-discnt-sum "(ACCUM TOTAL sj-goods.discnt-sum)" }
  { rep/dincol.i dix 10 for-pcnt
    "(round( ( ACCUM TOTAL sj-goods.discnt-sum ) /
          (ACCUM TOTAL sj-goods.brutto-sum ) * 100 , 1 ))"
   }
  { rep/dincol.i dix 11 for-netto-sum "((ACCUM TOTAL sj-goods.netto-sum ))" }
  {&tabulation}
  { rep/dincol.i dix 13 for-uchet-sum "(ACCUM TOTAL sj-goods.uchet-sum)" }
  skip.
  {&Underline-Excel}
/*
  {&DISPLAY-FRAME}
  { rep/dincol.i di 3 for-name "'   Сумма по ставке  '" }
  { rep/dincol.i di 4 for-prod-name "' Сумма  налога '" }
  {&DISPLAY-FRAME}

  {&PutExcel}
  skip(2)
  {&tabulation}
  {&tabulation}
  { rep/dincol.i dix 3 for-name "'   Сумма по ставке  '" }
  { rep/dincol.i dix 4 for-prod-name "' Сумма  налога '" }
  skip.

  FOR EACH  d-slt-vat
  break
  by d-slt-vat.slt-pc:
    assign
    d-slt-vat.SLT-r-b = d-slt-vat.SLT-r-b-brutto * d-slt-vat.SLT-pc / (100 + d-slt-vat.SLT-pc)
    .
    ACCUMULATE
    d-slt-vat.slt-r-b (TOTAL)
    d-slt-vat.slt-r-b-brutto (TOTAL)  .

    { rep/dincol.i di 2 for-artic "('НП' + {&space-char} + string( d-slt-vat.slt-pc, '>>9.<<%'))" }
    { rep/dincol.i di 3 for-name "string(d-slt-vat.slt-r-b-brutto, '->>,>>>,>>>,>>9.99' )" }
    { rep/dincol.i di 4 for-prod-name "string( d-slt-vat.SLT-r-b, '->>>,>>>,>>9.99' )" }
    {&DISPLAY-FRAME}

    {&putExcel}
    {&tabulation}
    { rep/dincol.i dix 2 for-artic "('НП' + {&space-char} + string( d-slt-vat.slt-pc, '>>9.<<%'))" }
    { rep/dincol.i dix 3 for-name "string(d-slt-vat.slt-r-b-brutto, '->>,>>>,>>>,>>9.99' )" }
    { rep/dincol.i dix 4 for-prod-name "string( d-slt-vat.SLT-r-b, '->>>,>>>,>>9.99' )" }
    skip.


  end.

  { rep/dincol.i un 2 for-artic fill16 }
  { rep/dincol.i un 3 for-name fill44 }
  { rep/dincol.i un 4 for-prod-name fill15 }
  {&display-frame}

  {&PutExcel}
  { rep/dincol.i unx 1 for-b-code fill9 }
  { rep/dincol.i unx 2 for-artic fill16 }
  { rep/dincol.i unx 3 for-name fill44 }
  { rep/dincol.i unx 4 for-prod-name fill15 }
  skip.

  { rep/dincol.i di 2 for-artic "'Итого по налогам'" }
  { rep/dincol.i di 3 for-name "string((ACCUM TOTAL d-slt-vat.slt-r-b-brutto ), '->>,>>>,>>>,>>9.99')" }
  { rep/dincol.i di 4 for-prod-name "string((ACCUM TOTAL d-slt-vat.SLT-r-b) , '->>>,>>>,>>9.99')" }
  {&display-frame}

  {&PutExcel}
  {&tabulation}
  { rep/dincol.i dix 2 for-artic "'Итого по налогам'" }
  { rep/dincol.i dix 3 for-name "string((ACCUM TOTAL d-slt-vat.slt-r-b-brutto ), '->>,>>>,>>>,>>9.99')" }
  { rep/dincol.i dix 4 for-prod-name "string((ACCUM TOTAL d-slt-vat.SLT-r-b ) , '->>>,>>>,>>9.99')" }
  skip.
*/
  {&display-frame}
  {&display-frame}
  { rep/dincol.i di 2 for-artic "'Директор'" }
  { rep/dincol.i di 4 for-prod-name "'Кассир'" }
  {&display-frame}


  {&PutExcel}
  skip(2)
  {&tabulation}
  { rep/dincol.i dix 2 for-artic "'Директор'" }
  {&tabulation}
  { rep/dincol.i dix 4 for-prod-name "'Кассир'" }
  skip.



  HIDE STREAM PrnLibStream FRAME DOc .
  HIDE STREAM PrnLibStream FRAME top-Frame .
  HIDE stream PrnLibStream FRAME NBottomFrame .
  output stream PrnLibStream CLOSE .

  {&CloseExcel}
  run waitfram-hide in this-procedure .
  DELETE WIDGET-POOL "My-pool".
  run get-quest-print in parparentproc ( output g#quest-print).
  { rep/q-print.i 8 }
end.