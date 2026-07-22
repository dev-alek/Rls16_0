block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: r-o-good.p $
$Archive: rep/r-o-good.p $

Оборотная ведомость отчет по документам

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Created: 14/11/00

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-o-good.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-o-good.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет".
{ cmp/vssrevis.i }
/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ rep/r-gl.i     }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ trg/partrqst.i }
{ rep/procobor.i func-vat }
{ gbl/cur-time.i }
{ rep/lkp-font.i }

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xCOMBO-node as char no-undo.
define input parameter xtog-inv as logical no-undo .
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xType  as char no-undo.

define variable inv-fact-order like ub.stk-tot.Fact-order init 0 no-undo.
define variable inv-str        as character init "" no-undo .
define variable Discnt-rubl# as decimal init 0  no-undo .
define variable Discnt-base# as decimal init 0  no-undo .
define variable tot-ov#      as decimal init 0  no-undo .
define variable v-ii as integer no-undo  .
define variable sums-only as logical no-undo .
define  variable  tPrintRubl as log no-undo.
define variable v-log as logical   no-undo .

define  stream  OutStream.
define  stream  OutStream2.
/*общий итог*/

define    variable    ObjName           as   char no-undo.
define    variable    Select-Good       as   integer no-undo.
define    variable    ChosedType        as   integer no-undo.
define    variable    PayType           as   integer no-undo.
define    variable    ValType           as   integer no-undo.
define    variable    Line              as   char        no-undo.
define    variable    FirstLine         as   logical     no-undo.

/* Local Variable Definitions ---                                       */

define variable tow-unit  as log no-undo .
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define  variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define  variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define  variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define  variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define  variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define  variable gds-zap-artic         like ub.goods.artic        no-undo .
define  variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define  variable gds-type              as char no-undo.
define  variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define  variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define  variable gds-zap-price-base    like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-stoim-base    like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define  variable gds-zap-Nds           like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-Np            like ub.stk-tot.sum-rubl  no-undo.




define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.

define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.


define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat1   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat2   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat3   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat4   like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V1       like ub.stk-tot.sum-rubl   no-undo.


define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.

define variable  temp-str as char no-undo.

define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable LL as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define variable curr-rep as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable s1 as decimal  FORMAT "->>>>>>>>9.<<<" no-undo .
define variable s2 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s3 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s4 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s5 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s6 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s7 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s8 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .

define variable s#1 as decimal FORMAT "->>>>>>>>9.<<<" no-undo .
define variable s#2 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#3 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#4 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#5 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#6 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#7 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#8 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .


define variable     F-fact-date  as char  no-undo.
define variable     f-doc-code   as char  no-undo.
define variable     f-type-doc   as char  no-undo.
define variable     f-cli-name   as char  no-undo.
define variable     F-qnty       as decimal FORMAT "->>>>>>>>9.<<<" no-undo.
define variable     f-SumSALE    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumCOST    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumCRSA    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-discnt-sum as decimal FORMAT "->>>>>>9.<<"  no-undo.
define variable     f-ov-sum     as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     F-VAT_pc     as char no-undo.
define variable     f-VAT-Sum    as decimal FORMAT "->>>>>>>9.99" no-undo.
define variable     F-SLT_pc     as char no-undo.
define variable     f-SLT-sum    as decimal FORMAT "->>>>>>>9.99" no-undo.

define variable     h-F-kol-1   AS WIDGET-HANDLE.
define variable     h-F-kol-2   AS WIDGET-HANDLE.
define variable     h-kol-1   AS WIDGET-HANDLE.
define variable     h-kol-2   AS WIDGET-HANDLE.

define variable     h-fact-date  AS WIDGET-HANDLE.
define variable     h-doc-code   AS WIDGET-HANDLE.
define variable     h-type-doc   AS WIDGET-HANDLE.
define variable     h-cli-name   AS WIDGET-HANDLE.
define variable     h-qnty       AS WIDGET-HANDLE.
define variable     h-SumSALE    AS WIDGET-HANDLE.
define variable     h-SumCOST    AS WIDGET-HANDLE.
define variable     h-SumCRSA    AS WIDGET-HANDLE.
define variable     h-discnt-sum AS WIDGET-HANDLE.
define variable     h-ov-sum     AS WIDGET-HANDLE.
define variable     h-VAT_pc     AS WIDGET-HANDLE.
define variable     h-VAT-Sum    AS WIDGET-HANDLE.
define variable     h-SLT_pc     AS WIDGET-HANDLE.
define variable     h-SLT-sum    AS WIDGET-HANDLE.

define variable     h-15     AS WIDGET-HANDLE.
define variable     h-16     AS WIDGET-HANDLE.


define variable     startdate  as date  no-undo.
define variable     enddate    as date  no-undo.

define variable     fact-date  as date  no-undo.
define variable     type-doc   as char  no-undo.
define variable     doc-code   as char  no-undo.
define variable     cli-name   as char  no-undo.
define variable     qnty       as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-1     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-2     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     SumSALE    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumCOST    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumCRSA    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     discnt-sum as decimal FORMAT "->>>>>>>>>9.<<"  no-undo.
define variable     ov-sum     as decimal FORMAT "->>>>>>>>>>9.<<"  no-undo.
define variable     VAT_pc     as char no-undo.
define variable     VAT-Sum    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SLT_pc     as char no-undo.
define variable     SLT-sum    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.

define variable TOT-SumCRSA   like SumCRSA no-undo.
define variable TOT-VAT-Sum   like VAT-Sum no-undo.
define variable TOT-SLT-sum   like SLT-sum no-undo.
define variable TOT-SumCOST   like SumCOST no-undo.
define variable TOT-SumSALE   like SumSALE no-undo.
define variable TOT-qnty      like qnty    no-undo.
define variable TOT-discnt-sum  like discnt-sum no-undo.
define variable TOT-ov-sum      like ov-sum     no-undo.
define variable cc as logical no-undo .

DEFINE BUFFER ot-line-Cost FOR ub.ot-line.
DEFINE BUFFER ot-line-Sale FOR ub.ot-line.

DEFINE VARIABLE sym1Handle AS WIDGET-HANDLE.
DEFINE VARIABLE sym1-ed AS CHARACTER INITIAL "::"
     VIEW-AS EDITOR
     SIZE 1 BY 2 NO-UNDO.
{ rep/repfrm.i def }
{ rep/repfrm.i on 50 }

/* ************** frame 1 для формы ************************************************************************************ */

DEFINE FRAME top-frame
    sym1-ed AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        x-store-type format "X(5)"
        ObjName format "X(35)" "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        Line format "X(198)" AT 1
     WITH {&DOS_CW_2} DOWN stream-io  use-text NO-BOX
         NO-UNDERLINE
         AT COL 1 ROW 1
         SIZE 198 BY 15  .


DEFINE FRAME zapas
    F-fact-date column-label "1":C8 format "x(8)" space(0)
    sym1 column-label ":" format "X(1)" space(0)
    f-doc-code column-label "2":C10 format "X(10)" space(0)
    sym2 column-label ":" format "X(1)" space(0)
    f-type-doc column-label "3":C3 format "X(3)" space(0)
    sym3 column-label ":" format "X(1)" space(0)
    f-cli-name column-label "4":C30 format "X(30)" space(0)
    sym4 column-label ":" format "X(1)" space(0)
    F-qnty column-label "5":C10    space(0)
    sym5 column-label ":" format "X(1)" space(0)
    f-SumSALE column-label "6":C13  space(0)
    sym6 column-label ":" format "X(1)" space(0)
    f-SumCOST column-label "7":C13 space(0)
    sym7 column-label ":" format "X(1)" space(0)
    f-discnt-sum column-label "8":C9 space(0)
    sym8 column-label ":" format "X(1)" space(0)
    f-ov-sum column-label "9":C10  space(0)
    sym9 column-label ":" format "X(1)" space(0)
    f-SumCRSA column-label "10":C13 space(0)
    sym10 column-label ":" format "X(1)" space(0)
    F-VAT_pc column-label "11" format "x(2)" space(0)
    sym11 column-label ":" format "X(1)" space(0)
    f-VAT-Sum column-label "12":C10       space(0)
    sym12 column-label ":" format "X(1)" space(0)
    F-SLT_pc column-label "13" format "x(2)" space(0)
    sym13 column-label ":" format "X(1)" space(0)
    f-SLT-sum column-label "14":C12 space(0)
    sym17 column-label ":" format "X(1)" space(0)
    sym14 Format "X(13)"  column-label "15":C13  space(0)
    sym15 column-label ":" format "X(1)" space(0)
    sym16 column-label "16":C15 format "X(15)" space(0)
    HEADER
        Line format "X(198)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX .
     assign
        i=0
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        FirstLine     = FALSE.
        Line          = fill("-", {&DOS_CW_2}).
        startdate     = x-Date-Start           .
        enddate       = x-Date-End             .
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        tow-unit = false .
        if Num-entries(xType) = 3 then
           If entry(3,xType) = 'yes' Then tow-unit = true .
        sums-only = (if entry(2,xtype) = "yes" then  true
                                               else false )  no-error .

        if sums-only = ? then sums-only = false .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_lookup-cost':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  v-log
}
  cc = v-log.


     CREATE WIDGET-POOL "qq" PERSISTENT.
        { rep/r-o-cre.i h-fact-date    "'Дата закрытия'"    8  1 }
        { rep/r-o-cre.i h-doc-code     "'Номер документа'"  10 10 }
        { rep/r-o-cre.i h-type-doc     "'Тип'"              3 21  }
        { rep/r-o-cre.i h-cli-name     "'Контрагент'" 30      25 }
        { rep/r-o-cre.i h-qnty         "'Количество'" 10      56 }
        { rep/r-o-cre.i h-SumSALE      "'Сумма по документу'" 13 68 }
        { rep/r-o-cre.i h-SumCOST      "'Сумма по учетной цене'" 13 83 }
        { rep/r-o-cre.i h-discnt-sum   "'Сумма скидки'"          10 98 }
        { rep/r-o-cre.i h-ov-sum       "'Сумма авт. переоценки'" 10 108 }
        { rep/r-o-cre.i h-SumCRSA      "'Сумма прод. цен'"       10 123 }
        { rep/r-o-cre.i h-VAT_pc       "'НДС %'"                 2 138 }
        { rep/r-o-cre.i h-VAT-Sum      "'Сумма НДС'"             9 141 }
        { rep/r-o-cre.i h-SLT_pc       "'НП %'"                  2 154 }
        { rep/r-o-cre.i h-SLT-sum      "'Сумма НП'"             9  157 }

     IF  tow-unit = true THEN DO:
             { rep/r-o-cre.i h-f-kol-1    "'Количество в шт.'" 10  171}
             { rep/r-o-cre.i h-f-kol-2    "'Количество вес'" 10  183 }

            CREATE FILL-IN h-kol-1 IN WIDGET-POOL "qq"
              ASSIGN
                FRAME = FRAME zapas:HANDLE
                DATA-TYPE = "DECIMAL"
                FORMAT = "->>>>>>>9.<<<"
                COLUMN =  171
                .
            CREATE FILL-IN h-kol-2 IN WIDGET-POOL "qq"
              ASSIGN
                FRAME = FRAME zapas:HANDLE
                DATA-TYPE = "DECIMAL"
                FORMAT = "->>>>>>>9.<<<"
                COLUMN =  181
                .
       End.
       else do:
         Assign
            sym14:label in frame zapas = ''
            sym15:label in frame zapas = ''
            sym16:label in frame zapas = ''
            Line         = fill("-", {&DOS_CW_2} - 28).
            .
       End.
    run report-execute.


PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
  NO-PRISE = true .
    if var-report-r-b = "rubl"  Then    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
                                else    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}


  FORM HEADER
      string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 170 format "x(24)" SKIP
    with FRAME BottomFrame2 width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
 VIEW STREAM OutStream FRAME BottomFrame2 .
  /*---------------------------------------------------------------------------------------------------------------------*/
   run Display-main-title.
   ll = 0.
   FOR EACH OBJ-list no-lock :
   ll = ll + 1 .
      x-store-code = obj-list.obj-code.
      x-store-type = obj-list.obj-type.
      if ll > 1 THEN Page stream OutStream.
      run Display-object.
      Case xClassify :
      When  "no-classify":U THEN DO:
            For each gds-list  no-lock :
                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
            End.
        End.
      When  "prod":U THEN DO:
            For each gds-list no-lock break by gds-list.prod-type by gds-list.prod-code   :
                if first-of (gds-list.prod-code) Then
                run subtit-prod (1).
                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate  tot-qnty            (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate  tot-SumSALE         (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SumCOST          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SumCRSA          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-discnt-sum       (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-ov-sum           (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-VAT-Sum          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SLT-sum          (total by  gds-list.prod-code by gds-list.prod-type) .

                if last-of (gds-list.prod-code) Then
                DO:
                  s#1 = accum total by gds-list.prod-code tot-qnty.
                  s#2 = accum total by gds-list.prod-code tot-SumSALE.
                  s#3 = accum total by gds-list.prod-code tot-SumCOST.
                  s#4 = accum total by gds-list.prod-code tot-SumCRSA .
                  s#5 = accum total by gds-list.prod-code tot-discnt-sum .
                  s#6 = accum total by gds-list.prod-code tot-ov-sum .
                  s#7 = accum total by gds-list.prod-code tot-VAT-Sum.
                  s#8 = accum total by gds-list.prod-code tot-SLT-sum.

                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0) then  run subfoot-prod (1).
                  End.
            End.           End.

      When  "grp-goods":U  Then Do:
            For each gds-list no-lock break by gds-list.grp-name  :
                if first-of (gds-list.grp-name) Then
                run subtit-grp (1).

                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate tot-qnty             (total by  gds-list.grp-name) .
                accumulate tot-SumSALE          (total by  gds-list.grp-name) .
                accumulate tot-SumCOST          (total by  gds-list.grp-name) .
                accumulate tot-SumCRSA          (total by  gds-list.grp-name) .
                accumulate tot-discnt-sum       (total by  gds-list.grp-name) .
                accumulate tot-ov-sum           (total by  gds-list.grp-name) .
                accumulate tot-VAT-Sum          (total by  gds-list.grp-name) .
                accumulate tot-SLT-sum          (total by  gds-list.grp-name) .

                if last-of (gds-list.grp-name) Then DO:
                            s1 = accum total by gds-list.grp-name tot-qnty.
                            s2 = accum total by gds-list.grp-name tot-SumSALE.
                            s3 = accum total by gds-list.grp-name tot-SumCOST.
                            s4 = accum total by gds-list.grp-name tot-SumCRSA .
                            s5 = accum total by gds-list.grp-name tot-discnt-sum .
                            s6 = accum total by gds-list.grp-name tot-ov-sum .
                            s7 = accum total by gds-list.grp-name tot-VAT-Sum.
                            s8 = accum total by gds-list.grp-name tot-SLT-sum.

                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (1).
            End.            End.
          end.
      When  "prod/grp-goods":U Then DO:
            for each gds-list no-lock  break by gds-list.prod-type by gds-list.prod-code  by gds-list.grp-name:
                if first-of (gds-list.prod-code) then run subtit-prod (1).
                if first-of (gds-list.grp-name)  then
                   if not sums-only  then run subtit-grp (2).
                run report-exec1.
                hide stream outstream frame zapas .
                  s#1 = s#1 + tot-qnty.          s1 = s1 + tot-qnty.
                  s#2 = s#2 + tot-SumSALE.       s2 = s2 + tot-SumSALE.
                  s#3 = s#3 + tot-SumCOST.       s3 = s3 + tot-SumCOST.
                  s#4 = s#4 + tot-SumCRSA .      s4 = s4 + tot-SumCRSA .
                  s#5 = s#5 + tot-discnt-sum .   s5 = s5 + tot-discnt-sum .
                  s#6 = s#6 + tot-ov-sum .       s6 = s6 + tot-ov-sum .
                  s#7 = s#7 + tot-VAT-Sum.       s7 = s7 + tot-VAT-Sum.
                  s#8 = s#8 + tot-SLT-sum.       s8 = s8 + tot-SLT-sum.

                if last-of (gds-list.grp-name)  Then DO:
                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (2).
                  Assign s1 = 0 s2 = 0 s3 = 0  s4 = 0  s5 = 0 s6 = 0 s7 = 0 s8 = 0.
                End.
                if last-of (gds-list.prod-code) Then DO:
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-prod (1).
                  Assign s#1 = 0 s#2 = 0 s#3 = 0  s#4 = 0  s#5 = 0 s#6 = 0 s#7 = 0 s#8 = 0.
                  End.

            End.           End.

      When  "grp-goods/prod":U Then DO:
            For each gds-list no-lock  break  by gds-list.grp-name   by gds-list.prod-type by gds-list.prod-code :

                if first-of (gds-list.grp-name)  then run subtit-grp (1).
                if first-of (gds-list.prod-code) then
                   if not sums-only  then run subtit-prod (2).
                run report-exec1.
                hide stream outstream frame zapas .
                  s#1 = s#1 + tot-qnty.          s1 = s1 + tot-qnty.
                  s#2 = s#2 + tot-SumSALE.       s2 = s2 + tot-SumSALE.
                  s#3 = s#3 + tot-SumCOST.       s3 = s3 + tot-SumCOST.
                  s#4 = s#4 + tot-SumCRSA .      s4 = s4 + tot-SumCRSA .
                  s#5 = s#5 + tot-discnt-sum .   s5 = s5 + tot-discnt-sum .
                  s#6 = s#6 + tot-ov-sum .       s6 = s6 + tot-ov-sum .
                  s#7 = s#7 + tot-VAT-Sum.       s7 = s7 + tot-VAT-Sum.
                  s#8 = s#8 + tot-SLT-sum.       s8 = s8 + tot-SLT-sum.
                if last-of (gds-list.prod-code) Then DO:
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-prod (2).
                  assign s#1 = 0 s#2 = 0 s#3 = 0  s#4 = 0  s#5 = 0 s#6 = 0 s#7 = 0 s#8 = 0.
                  end.
                  if last-of (gds-list.grp-name)  then do:
                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (1).
                    Assign s1 = 0 s2 = 0 s3 = 0  s4 = 0  s5 = 0 s6 = 0 s7 = 0 s8 = 0.
                    End.
                End.   End.
      When  "sort":U THEN DO:
            For each gds-list no-lock break by gds-list.sort   :
                if first-of (gds-list.sort) Then
                    if not sums-only  then run subtit-vat-sort (1).
                run report-exec1.
                hide stream outstream frame zapas .
                accumulate  tot-qnty            (total by  gds-list.sort) .
                accumulate  tot-sumsale         (total by  gds-list.sort) .
                accumulate tot-sumcost          (total by  gds-list.sort) .
                accumulate tot-sumcrsa          (total by  gds-list.sort) .
                accumulate tot-discnt-sum       (total by  gds-list.sort) .
                accumulate tot-ov-sum           (total by  gds-list.sort) .
                accumulate tot-vat-sum          (total by  gds-list.sort) .
                accumulate tot-slt-sum          (total by  gds-list.sort) .

                if last-of (gds-list.sort) Then
                DO:
                  s#1 = accum total by gds-list.sort tot-qnty.
                  s#2 = accum total by gds-list.sort tot-SumSALE.
                  s#3 = accum total by gds-list.sort tot-SumCOST.
                  s#4 = accum total by gds-list.sort tot-SumCRSA .
                  s#5 = accum total by gds-list.sort tot-discnt-sum .
                  s#6 = accum total by gds-list.sort tot-ov-sum .
                  s#7 = accum total by gds-list.sort tot-VAT-Sum.
                  s#8 = accum total by gds-list.sort tot-SLT-sum.
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-vat-sort (1).
                  End.
            End.           End.
      When  "vat-ps":U THEN DO:
            For each gds-list no-lock ,
               first ub.gds-obj where
                     ub.gds-obj.gds-code = gds-list.gds-code and
                     ub.gds-obj.obj-code = x-store-code and
                     ub.gds-obj.obj-type = x-store-type
                     :
                gds-list.qnty = {&break-vat} .
             end.

            For each gds-list no-lock , first ub.gds-obj where ub.gds-obj.gds-code = gds-list.gds-code and
                ub.gds-obj.obj-code = x-store-code and
                ub.gds-obj.obj-type = x-store-type
            break by gds-list.qnty   :

                if first-of (gds-list.qnty) Then run subtit-vat-sort (2).
                Run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate tot-qnty             (total by  gds-list.qnty) .
                accumulate tot-SumSALE          (total by  gds-list.qnty) .
                accumulate tot-SumCOST          (total by  gds-list.qnty) .
                accumulate tot-SumCRSA          (total by  gds-list.qnty) .
                accumulate tot-discnt-sum       (total by  gds-list.qnty) .
                accumulate tot-ov-sum           (total by  gds-list.qnty) .
                accumulate tot-VAT-Sum          (total by  gds-list.qnty) .
                accumulate tot-SLT-sum          (total by  gds-list.qnty) .

                if last-of (gds-list.qnty) Then
                DO:
                  s#1 = accum total by gds-list.qnty tot-qnty.
                  s#2 = accum total by gds-list.qnty tot-SumSALE.
                  s#3 = accum total by gds-list.qnty tot-SumCOST.
                  s#4 = accum total by gds-list.qnty tot-SumCRSA .
                  s#5 = accum total by gds-list.qnty tot-discnt-sum .
                  s#6 = accum total by gds-list.qnty tot-ov-sum .
                  s#7 = accum total by gds-list.qnty tot-VAT-Sum.
                  s#8 = accum total by gds-list.qnty tot-SLT-sum.

                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then run subfoot-vat-sort (2).
                  End.
            End.           End.
      End case.
  End. /* for each */
  HIDE STREAM OutStream FRAME top-Frame .
  Output stream OutStream close.
  DELETE WIDGET-POOL "qq".
  { rep/repfrm.i off }
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .



  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
END PROCEDURE.

/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line :
/*------------------------------------------------------------------------------
  Purpose: Display  for frame  & Accumulate
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   i = i + 1.
   v-ii = v-ii + 1.
  { rep/repfrm.i disp v-ii reportname ObjName }
  if NOT (xtype begins "all") OR
    entry(2,xtype) = "no"    then DO:
           DISPLAY stream  OutStream {&ALL-Sym} sym13
           fact-date  @  F-fact-date
           type-doc   @  f-type-doc
           doc-code   @  f-doc-code
           cli-name   @  f-cli-name
           qnty       @  F-qnty
           SumSALE    @  f-SumSALE
           SumCOST when (cc = true )    @  f-SumCOST
           SumCRSA    @  f-SumCRSA
           discnt-sum @  f-discnt-sum
           ov-sum      when ( NO-PRISE = true ) @  f-ov-sum
           VAT_pc     @  F-VAT_pc
           VAT-Sum    @  f-VAT-Sum
           SLT_pc     @  F-SLT_pc
           SLT-sum    @  f-SLT-sum
           {&WFz} . {&FRAME-d}.
           End.
END PROCEDURE.


PROCEDURE print-header :
   If xtype begins "all":U OR xtype = "goods":U  Then  run display-title-mgds.
   i = 0.
    If NOT (xtype begins "all":U) Then DO:
        run display-title.
        { rep/r-reer.i 1}
        if no-prise then do:  { rep/r-reer2.i 3} end.
        if xtype =  "" then  do: display stream outstream  with frame top-frame . end.
    End.
END PROCEDURE.


PROCEDURE Print-Footer :
/*Печать оборота*/
IF NOT ( tot-qnty       = 0  and
   tot-SumSALE    = 0  and
   tot-SumCOST    = 0  and
   tot-SumCRSA    = 0  and
   tot-discnt-sum = 0  and
   tot-ov-sum     = 0  and
   tot-VAT-Sum    = 0  and
   tot-SLT-sum    = 0 ) Then do:
   /* if NOT (xtype begins "all") OR  entry(2,xtype) = "no"    then    run u-line. */
      DISPLAY stream  OutStream {&ALL-Sym} sym13
           "ИТОГО"  @  F-fact-date
           gds-list.artic     @  f-doc-code
           gds-list.gds-name  @  f-cli-name
           tot-qnty       @  F-qnty
           tot-SumSALE    @  f-SumSALE
           tot-SumCOST  when (cc = true )   @  f-SumCOST
           tot-SumCRSA    @  f-SumCRSA
           tot-discnt-sum @  f-discnt-sum
           tot-ov-sum  when (NO-PRISE = true )   @  f-ov-sum
           ""     @  F-VAT_pc
           tot-VAT-Sum    @  f-VAT-Sum
           ""     @  F-SLT_pc
           tot-SLT-sum    @  f-SLT-sum
           {&WFz} . {&FRAME-d}.
End.

 If NOT (xtype begins "all":U) Then DO:
        Quantity = Quantity2 - Quantity1.
        Coast = Coast2 - Coast1 .
        Coast-vat = Coast-vat2 - Coast-vat1 .
      { rep/r-reer.i }
        Coast = Coast4 - Coast3 .
        Coast-vat = Coast-vat4 - Coast-vat3 .
      { rep/r-reer2.i }
    /* Печать остатков на конец*/
      { rep/r-reer.i 2}
      if NO-PRISE Then DO: { rep/r-reer2.i 4}  End.
   End.
   /*!!!*/
END PROCEDURE.


PROCEDURE U-LINE :
UNDERLINE stream OutStream  {&ALL-Sym} Sym13 sym17
F-fact-date
f-type-doc
f-doc-code
f-cli-name
F-qnty
f-SumSALE
f-SumCOST
f-SumCRSA
f-discnt-sum
f-ov-sum
F-VAT_pc
F-VAT-Sum
F-SLT_pc
F-SLT-sum
sym14 when  (h-kol-1 <> ?)
sym15 when  (h-kol-1 <> ?)
sym16 when  (h-kol-1 <> ?)
{&wFz} .
{&FRAME-d}.
END PROCEDURE.


PROCEDURE P-LINE :
UNDERLINE stream OutStream        {&wFz}.        {&FRAME-d} .
END PROCEDURE.


PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input true ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input true ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).

    if xtog-inv and inv-fact-order > 0 then  Fact-order-1 = inv-fact-order. /* с момента инвентаризации */

    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-1 ,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input YES ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast1 =  IF tPrintRubl then  Coast_R1
                                else  Coast_V1 .
        Coast-vat1 =  IF tPrintRubl then  vat_R1
                                    else  vat_V1 .

        run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type   ,
        input x-TOG-Shift ,
        input Fact-order-1 ,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input YES ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast3 =  IF tPrintRubl then  Coast_R1
                                else  Coast_V1 .
        Coast-vat3 =  IF tPrintRubl then  vat_R1
                                    else  vat_V1 .

/*----------------------------------------------------------------------------------------------------------------*/
/* номер последнего Fact-ordera и остатки на конец интервала   */
/* номерa  Fact-ordera - ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ    */
define variable Quantity2-1 as decimal   no-undo .

    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-2 ,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input YES ,

        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  slt_R1     ,
        output  slt_V1     ).

        Coast2 =  IF tPrintRubl then  Coast_R2
                                else  Coast_V2 .
        Coast-vat2 =  IF tPrintRubl then  vat_R2
                                else  vat_V2 .

    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-2 ,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input YES ,


        output  Quantity2-1  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  slt_R1     ,
        output  slt_V1     ).


        Coast4 =  IF tPrintRubl then  Coast_R2
                                else  Coast_V2 .
        Coast-vat4 =  IF tPrintRubl then  vat_R2
                                else  vat_V2 .



END PROCEDURE.


PROCEDURE Display-main-title :
   {&PUT-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
End procedure.


PROCEDURE Display-title :
     {&PUT-u1} "Товар  : "
              + gds-list.artic + " "
              + gds-list.gds-name
              AT 1 format "X(170)" SKIP.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      {&PUT-u1}  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    if xtog-inv and inv-fact-order > 0  then do:
            {&PUT-u1}  inv-str AT 1 format "X(170)" SKIP. end.
    i=0.
END PROCEDURE.


PROCEDURE Display-object :
   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
     if xtype <> "" then  do:
     display STREAM OutStream  with frame top-Frame .
     run U-line.
     End.
     {&PUT-u1}  "Объект  : " + ObjName FORMAT "X(170)" skip.
end procedure.


PROCEDURE Display-title-mgds :
     {&PUT-u1}  "Товар  : " + gds-list.artic + " " + gds-list.gds-name + " " +  gds-list.PS  + " (" + gds-list.sort  + "*)"
                 AT 1 format "X(198)" .
     if xtog-inv and inv-fact-order > 0  then do : {&PUT-u1}  inv-str AT 1 format "X(170)". end.
     {&PUT-u1}  SKIP.
     run u-line.
     i = 0.
END PROCEDURE.


PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic          like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as   log                  no-undo.


&scop partrqst-prefix v-total-parts-
 {&partrqst-var}


 FOR each ub.ot-line
                   where ub.ot-line.artic        = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.prod-code     = x-prod-code
                  AND   ub.ot-line.prod-type     = x-prod-type
                  AND   ub.ot-line.obj-code      = x-store-code
                  AND   ub.ot-line.obj-type      = x-store-type
                  AND   (ub.ot-line.sum-type     = {&arh-crsa} OR ub.ot-line.sum-type = {&arh-crsa-service})
                  And   ((x-ext-doc-type = {&all}) OR (ub.ot-line.ext-doc-type  = x-ext-doc-type ))
                        no-lock break by ub.ot-line.artic  :

         Find First ot-line-Cost where
                        ot-line-Cost.artic        = x-artic
                  AND   ot-line-Cost.fact-order   = ub.ot-line.fact-order
                  AND   ot-line-Cost.obj-code     = ub.ot-line.obj-code
                  AND   ot-line-Cost.obj-type     = ub.ot-line.obj-type
                  AND   ot-line-Cost.prod-code    = x-prod-code
                  AND   ot-line-Cost.prod-type    = x-prod-type
                  AND   (ot-line-Cost.sum-type    = {&arh-cost} OR ot-line-cost.sum-type = {&arh-cost-service})
                  And   ot-line-Cost.doc-code     = ub.ot-line.doc-code
                    no-lock use-Index pi  no-error.

        Find First ot-line-Sale where
                        ot-line-Sale.artic        = x-artic
                  AND   ot-line-Sale.fact-order   = ub.ot-line.fact-order
                  AND   ot-line-Sale.obj-code     = ub.ot-line.obj-code
                  AND   ot-line-Sale.obj-type     = ub.ot-line.obj-type
                  AND   ot-line-Sale.prod-code    = x-prod-code
                  AND   ot-line-Sale.prod-type    = x-prod-type
                  AND   (ot-line-Sale.sum-type    = {&arh-sale} OR ot-line-sale.sum-type = {&arh-sale-service})
                  And   ot-line-Sale.doc-code     = ub.ot-line.doc-code
                    no-lock use-Index pi  no-error.

          Assign
            doc-code   = ub.ot-line.doc-code
            qnty       = ub.ot-line.fact-qnty
            .

           If ub.ot-line.ext-doc-type  <> {&TDEDT_Overturn} Then DO:
                  Find Last ub.trn-doc  where ub.trn-doc.doc-code = ub.ot-line.doc-code no-lock no-error.
                    If Available ub.trn-doc then DO:
                    Find First ub.doc-line  where ub.trn-doc.doc-code = ub.doc-line.doc-code
                  AND   ub.doc-line.prod-code    = x-prod-code
                  AND   ub.doc-line.prod-type    = x-prod-type
                  AND   ub.doc-line.artic        = x-artic   no-lock no-error.
                    Assign
                    type-doc   =  ub.trn-doc.doc-type
                    fact-date  =  ub.trn-doc.fact-date
                    cli-name   =  ub.trn-doc.cli-name
                    discnt-sum = if avail ot-line-Sale then
                                 ( if tPrintRubl then ot-line-Sale.other-rubl
                                                Else ot-line-Sale.other-base )
                                  Else 0

                    .

                    if  ub.ot-line.ext-doc-type  = {&TDEDT_Inv} or ub.ot-line.ext-doc-type  = {&TDEDT_Peresort} Then DO:
                        Assign  discnt-sum = 0  .
                        End.
                    End.
                  End.
              Else DO:
                 /* если переоценка */
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-line.doc-code no-lock no-error.
                  If Available ub.price-doc then
                    Assign
                    type-doc   = 'пер'
                    fact-date  = ub.price-doc.fact-date
                    cli-name   =  ""
                    discnt-sum = 0
                    qnty       = if available ot-line-Cost then ot-line-Cost.fact-qnty else 0

                    .
              End.
     If Available ot-line-sale Then
       Assign
                SumSALE    = if tPrintRubl then ot-line-sale.sum-rubl else ot-line-sale.sum-base
                VAT-Sum    = if tPrintRubl then ot-line-sale.VAT-rubl else ot-line-sale.VAT-base
                SLT-sum    = if tPrintRubl then ot-line-sale.SLT-rubl else ot-line-sale.SLT-base
                VAT_pc     = (Entry(1,ot-line-sale.cat-id))
                SLT_pc     = (Entry(2,ot-line-sale.cat-id))
              .
         Else
               Assign
                SumSALE    = 0
                VAT-Sum    = if tPrintRubl then ub.ot-line.VAT-rubl else ub.ot-line.VAT-base
                SLT-sum    = if tPrintRubl then ub.ot-line.SLT-rubl else ub.ot-line.SLT-base
                VAT_pc     = (Entry(1,ot-line.cat-id))
                SLT_pc     = (Entry(2,ot-line.cat-id))
              .

     If Available ot-line-cost Then
        SumCOST    = if tPrintRubl then ot-line-cost.sum-rubl else ot-line-cost.sum-base.
         Else  SumCOST    = 0.
     Assign
     SumCRSA    = if tPrintRubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
     .
     If (ub.ot-line.ext-doc-type  = {&TDEDT_Overturn}  OR
         ub.ot-line.ext-doc-type  = {&TDEDT_Inv}       OR
         ub.ot-line.ext-doc-type  = {&TDEDT_Peresort}  )
        Then ov-sum      = 0.
        Else ov-sum      = SumCRSA   - discnt-sum - SumSALE.

/*----------------- штуки вес --------------------------------------*/
  Assign qnty-1 = 0   qnty-2 = 0 .
  IF  tow-unit = true THEN DO :
       FIND FIRST ub.units no-LOCK WHERE  ub.units.unit-name = gds-list.unit-base No-ERROR.
       define variable var1 as integer no-undo .
     var1 = 0 .
     IF  LOOKUP({&twounit}, ub.units.type ) > 0  THEN  var1 = 1.
     IF  LOOKUP({&altunit}, ub.units.type) > 0   THEN  var1 = 2.
    CASE var1:
        when 0 then DO : Assign qnty-1 = 0   qnty-2 = 0 .                              End.
        when 1 then DO :  If avail ub.doc-line then
                          run partrqst in this-procedure
                            (input  ub.doc-line.doc-code        /* p-doc-code               */
                            ,input  ub.doc-line.obj-type        /* p-obj-type               */
                            ,input  ub.doc-line.obj-code        /* p-obj-code               */
                            ,input  ub.doc-line.artic           /* p-artic                  */
                            ,input  ub.doc-line.prod-type       /* p-prod-type              */
                            ,input  ub.doc-line.prod-code       /* p-prod-code              */
                            &scop partrqst-prefix v-total-parts-
                            {&partrqst-param}
                            ).

                            Assign qnty-1 = (If avail ub.doc-line
                                            then  (If  qnty  = 0 Then 0
                                                       Else (If  qnty  < 0
                                                                Then (-1) * ABSOLUTE(v-total-parts-fact-cli-qnty)
                                                                Else v-total-parts-fact-cli-qnty)
                                                   )
                                            else  0)
                                   qnty-2 = qnty .
                    End.
        when 2 then DO : Assign qnty-1 = qnty
                                qnty-2 = gds-list.wt-cart * qnty-1.
                   End.
    End.

     IF h-kol-1 <> ?  THEN h-kol-1:screen-value =  string(qnty-1)  .
     IF h-kol-2 <> ?  THEN h-kol-2:screen-value =  string(qnty-2)  .
     ov-sum      = SumCRSA   - discnt-sum - SumSALE.
     If ub.ot-line.ext-doc-type  = {&TDEDT_Overturn} Then ov-sum = 0.
End.
/*-------------------------------------------------------*/
    Assign
        TOT-SumCRSA    = TOT-SumCRSA + SumCRSA
        TOT-VAT-Sum    = TOT-VAT-Sum + VAT-Sum
        TOT-SLT-sum    = TOT-SLT-sum + SLT-sum
        TOT-SumCOST    = TOT-SumCOST + SumCOST
        TOT-SumSALE    = TOT-SumSALE + SumSALE
        TOT-discnt-sum = TOT-discnt-sum + discnt-sum
        TOT-ov-sum     = TOT-ov-sum     + ov-sum    .

    /*If ub.ot-line.ext-doc-type  <> {&TDEDT_Overturn} Then  */   TOT-qnty  = TOT-qnty  + qnty .


 if first-of(ub.ot-line.artic)  then DO:
      if not sums-only then run print-header.
  End.

  run display-line in this-procedure .
End.
END PROCEDURE.

{ rep/ost-line.i }
/*-----------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-exec1  :
        if xtog-inv then DO:
          For each ub.trn-doc where
            ub.trn-doc.doc-type = {&inventory} and
            ub.trn-doc.ext-doc-type = {&TDEDT_Inv} and
            ub.trn-doc.fact-date >= startdate and
            ub.trn-doc.obj-code   = x-store-code and
            ub.trn-doc.obj-type   = x-store-type and
            ub.trn-doc.status_    = {&fact}
            no-lock,
            first ub.doc-line where
                ub.doc-line.artic      = gds-list.artic     and
                ub.doc-line.prod-type  = gds-list.prod-type and
                ub.doc-line.prod-code  = gds-list.prod-code and
                ub.doc-line.doc-code   = ub.trn-doc.doc-code   no-lock :
                Assign
                   inv-fact-order = ub.trn-doc.fact-order
                   inv-str        = 'Последняя инвентаризация ' +  string(ub.trn-doc.fact-date ,"99/99/9999" ) + " документ № " + ub.doc-line.doc-code.
          End.
         End.

Assign TOT-SumCRSA = 0
       TOT-VAT-Sum = 0
       TOT-SLT-sum = 0
       TOT-SumCOST = 0
       TOT-SumSALE = 0
       TOT-qnty    = 0
       TOT-discnt-sum = 0
       TOT-ov-sum     = 0.

   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                            x-store-code = ub.clients.obj-code no-lock no-error.

           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".


  run calcitog.
  form with frame zapas .
  { rep/r-formh.i x(197) {&dos_cw_2}}
  /* run print-header. */

  run ob-line  in this-procedure (
      input   x-store-code   ,
      input   x-store-type   ,
      input   gds-list.artic       ,
      input   gds-list.prod-code   ,
      input   gds-list.prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   {&arh-crsa},
      input   {&root-cat-id},
      input   xcombo-node ,
      input   yes ) .

   hide stream outstream frame bottomframe2 .
  run print-footer.
  end procedure.

{ rep/ostatok.i }

procedure calc-discnt-base.
discnt-rubl# =  0.
discnt-base# =  0.
for each ub.gds-dtl where ub.gds-dtl.doc-code = ub.trn-doc.doc-code and
                ub.gds-dtl.artic      = ub.doc-line.artic     and
                ub.gds-dtl.prod-type  = ub.doc-line.prod-type and
                ub.gds-dtl.prod-code  = ub.doc-line.prod-code no-lock :
  discnt-rubl# = discnt-rubl# + (ub.gds-dtl.discnt-rubl * ub.gds-dtl.doc-qnty ).
  discnt-base# = discnt-base# + (ub.gds-dtl.discnt-base * ub.gds-dtl.doc-qnty ).
  tot-ov#      = tot-ov#      + ((ub.gds-dtl.cur-base - ub.gds-dtl.price-base ) * ub.gds-dtl.fact-qnty ).
  if discnt-rubl# = ? then discnt-rubl# = 0.
  if discnt-base# = ? then discnt-base# = 0.
  if tot-ov# = ?      then tot-ov#      = 0.
end.
end procedure.


procedure subtit-prod.
   define input parameter x-ord  as integer no-undo .
   find first ub.clients where ub.clients.obj-code = gds-list.prod-code and
                            ub.clients.obj-type = gds-list.prod-type no-lock.
   {&put-u1} "Производитель : " + ub.clients.obj-name  at  (x-ord * 10) - 10   format "x(100)" skip.
end procedure.

procedure subfoot-prod.
   define input parameter x-ord  as integer no-undo .
   find first ub.clients where ub.clients.obj-code = gds-list.prod-code and
                            ub.clients.obj-type = gds-list.prod-type no-lock.
   {&put-u1} "Итого по пр-лю : " + ub.clients.obj-name at  (x-ord * 10) - 10    format "x(" + string (53 - ((x-ord * 10) - 10) ) + ")"
   s#1 at 56   format "->>>>>>>>>9.<<<"
   s#2 at 68   format "->>>>>>>>>>9.<<"
   s#3 at 83   format "->>>>>>>>>>9.<<"
   s#4 at 123  format "->>>>>>>>>>9.<<"
   s#7 at 141  format "->>>>>>>>>9.<<"
   s#8 at 157  format "->>>>>>>>>9.<<"
   skip.
end procedure.


procedure subfoot-grp.
   define input parameter x-ord  as integer no-undo .
   {&put-u1}  "Итого по группе  " +  gds-list.grp-name at  (x-ord * 10) - 10   format "x(" + string (53 - ((x-ord * 10) - 10) ) + ")"
   s1 at 56  format "->>>>>>>>>9.<<<"
   s2 at 68   format "->>>>>>>>>>9.<<"
   s3 at 83   format "->>>>>>>>>>9.<<"
   s4 at 123  format "->>>>>>>>>>9.<<"
   s7 at 141  format "->>>>>>>>>9.<<"
   s8 at 157  format "->>>>>>>>>9.<<"
   skip.
end procedure.

procedure subtit-grp.
   define input parameter x-ord  as integer no-undo .
   {&put-u1} "Группа : " + gds-list.grp-name at  (x-ord * 10) - 10   format "x(100)" skip.
end procedure.


procedure subfoot-vat-sort.
   define input parameter x-ord  as integer no-undo .
   case x-ord:
   when 1 then str = "Итого по пробе ".
   when 2 then str = "Итого по НДС   ".
   end case.
   {&put-u1}  str + (if x-ord=1 then  gds-list.sort  else string(gds-list.qnty)  )  at  1   format "x(52)"
   s#1 at 56   format "->>>>>>>>>>>9.<<<"
   s#2 at 68   format "->>>>>>>>>>>9.<<"
   s#3 at 83   format "->>>>>>>>>>>9.<<"
   s#4 at 123  format "->>>>>>>>>>>9.<<"
   s#7 at 141  format "->>>>>>>>>>9.<<"
   s#8 at 157  format "->>>>>>>>>>9.<<"
   skip.
end procedure.

procedure subtit-vat-sort.
   define input parameter x-ord  as integer no-undo .
   case x-ord:
   when 1 then str = "Проба ".
   when 2 then str = "НДС   ".
   end case.
   {&put-u1}  str + (if x-ord=1 then  gds-list.sort  else string(gds-list.qnty))  at  1   format "x(100)" skip.
end procedure.