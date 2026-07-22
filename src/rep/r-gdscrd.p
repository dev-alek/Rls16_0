block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gdscrd.p $
$Archive: rep/r-gdscrd.p $

Карточка товара

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 12/27/01 1:40

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdscrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdscrd.p $":U .
define variable vss-description as character no-undo init "Карточка товара".
{ cmp/vssrevis.i }
/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/r-gl.i    }
{ cmp/r-pril.i  }
{ rep/r-sym.i   }
{ gbl/cur-time.i     }
{ str/out-vatp.i def }
{ str/in-vatp.i  def }
{ rep/rep-bt.i }
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter x-type-dog as integer no-undo .
define input parameter xtog-inv   as logical no-undo .
define input parameter xtog-ov    as logical no-undo.

define variable make-one as logical no-undo .
make-one =  false    .

define variable inv-fact-order like ub.stk-tot.Fact-order init 0 no-undo.
define variable inv-fact-date as date no-undo .
define variable inv-str        as character init "" no-undo .
define variable v-ii as integer no-undo  .

define  shared var   v-x-artic      like   ub.goods.artic    no-undo  .
define  shared var   v-x-prod-type  like   ub.goods.prod-type no-undo .
define  shared var   v-x-prod-code  like   ub.goods.prod-code no-undo .
define buffer b-goods for ub.goods .

define variable cur-dn1 as character no-undo .

define variable  tPrintRubl as log no-undo.
define variable t-char as character no-undo .

define  stream  OutStream.
define  stream  OutStream2.
/*общий итог*/

define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.
define variable f-o as decimal format "->>>>>>>>9.999999999"no-undo .
define variable f-o1 as decimal format "->>>>>>>>9.999999999"no-undo .
/* define variable v-bar-code    like bar-code.b-code no-undo  .*/
/* Local Variable Definitions ---                                       */

define variable v-p as logical no-undo .
define variable tow-unit  as log no-undo .
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable ii        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-rubl  no-undo.

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
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.


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


define variable     F-fact-date  as char                            no-undo.
define variable     f-doc-code   as char                            no-undo.
define variable     f-type-doc   as char                            no-undo.
define variable     f-cli-name   as char                            no-undo.
define variable     F-qnty       as decimal FORMAT "->>>>>>>>9.<<<" no-undo.
define variable     F-qnty-o     as decimal FORMAT "->>>>>>>>>>>9.<<<" no-undo.
define variable     f-SumSALE    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumSALE-o  as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-PriceSALE  as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-discnt-sum as decimal FORMAT "->>>>>>9.<<"  no-undo.
define variable     vvv as decimal  FORMAT "->>>>>>>>>>>9.99"  no-undo.

define variable     h-F-kol-1   AS WIDGET-HANDLE.
define variable     h-F-kol-2   AS WIDGET-HANDLE.
define variable     h-kol-1     AS WIDGET-HANDLE.
define variable     h-kol-2     AS WIDGET-HANDLE.

define variable     h-fact-date   AS WIDGET-HANDLE.
define variable     h-doc-code    AS WIDGET-HANDLE.
define variable     h-type-doc    AS WIDGET-HANDLE.
define variable     h-cli-name    AS WIDGET-HANDLE.
define variable     h-qnty        AS WIDGET-HANDLE.
define variable     h-qnty-o      AS WIDGET-HANDLE.
define variable     h-SumSALE     AS WIDGET-HANDLE.
define variable     h-SumSALE-o   AS WIDGET-HANDLE.
define variable     h-PriceSALE   AS WIDGET-HANDLE.
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
define variable     qnty-o     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-1     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-2     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     SumSALE    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumSALE-o  as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     PriceSALE  as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     discnt-sum as decimal FORMAT "->>>>>>>>>9.<<"  no-undo.

define variable TOT-SumSALE     like SumSALE no-undo.
define variable TOT-qnty        like qnty    no-undo.
define variable TOT-discnt-sum  like discnt-sum no-undo.

define buffer sale-ot-line  for  ub.ot-line .
DEFINE VARIABLE sym1Handle AS WIDGET-HANDLE.
DEFINE VARIABLE sym1-ed AS CHARACTER INITIAL "::"
     VIEW-AS EDITOR
     SIZE 1 BY 2 NO-UNDO.

DEFINE VARIABLE OpenedDocs AS LOGICAL INITIAL yes.
DEFINE VARIABLE PriceDocs AS LOGICAL INITIAL yes.
DEFINE VARIABLE ClosedDocs AS LOGICAL INITIAL yes.

define variable start-date as date no-undo .
define variable end-date   as date no-undo .
define variable rest-qnty as dec no-undo.
define variable rest-base as dec no-undo.
define variable rest-qnty1 as dec no-undo.
define variable rest-base1 as dec no-undo.

define buffer b-price-doc for ub.price-doc.
define buffer p-price-doc for ub.price-doc.
define buffer p-price-list for ub.price-list.
define buffer b-price-list for ub.price-list.
define buffer old-price-list for ub.price-list.
define buffer prev-price-list for ub.price-list.
define buffer  curr-price-list for ub.price-list .
define buffer b-doc-line for ub.doc-line.
define variable  Prtroot        like ub.gds-prt.node-code no-undo.
define variable BadResults      as      log     no-undo.
define variable q1 as decimal no-undo .
define variable q2 as decimal no-undo .


&scop p "пер"

define temp-table gds-rep   no-undo
      field ii as integer
      field nn as integer
      field doc-code as char format "x(13)" label "Номер"
      field doc-num as char format "x(13)" label "Номер"
      field doc-type as char format "x(1)" label {&gds-goods}
      field fact-num as dec format "999999" label "fact-num"
      field fact-order as dec format "->>>>>>>>>9.9999999999"
      field obj as char format "x(9)" label {&g___object}
      field clients as char  format "x(30)" label "Контрагент"
      field fact-date like ub.trn-doc.fact-date
      field fact-qnty as dec format "->>,>>>,>>9.99" label "Кол-во"
      field rest-qnty as dec format "->>,>>>,>>9.99" label "Остаток"
      field sale-base as dec format "->>,>>>,>>9.99" label "Цена/разница  "
      field tot-base as dec format "->>,>>>,>>9.99" label "Сумма (Б.вал.)"
      field rest-base as dec format "->>,>>>,>>9.99" label "Остаток(Б.вал)"
      field discnt-pc as dec format "->>9.99%" label "% ск."
      field discnt-tot as dec format "->>,>>>,>>9.99" label "Сумма ск."
      field netto as dec format "->>,>>>,>>9.99" label "Сумма нетто"
      field sale as dec format "->>,>>>,>>9.99" label {&price}
      field vv as dec format "->>,>>>,>>9.99" label "расчет"
      field ext-doc-type as character
      INDEX i-fact-ord fact-order ASCENDING
           .

define variable nn as integer no-undo .
define buffer gds-rep-p for gds-rep.
define buffer buf-gds-rep-2 for gds-rep.
define buffer buf-gds-rep-3 for gds-rep.
define buffer gds-dtl-ch for ub.gds-dtl.
define temp-table gds-rep-befor no-undo   like gds-rep .
define buffer buf-gds-rep-befor for gds-rep-befor .
 define variable v-total-tot-ov as decimal no-undo .
 define variable old-main-price as decimal no-undo .

{ rep/repfrm.i def  }
{ rep/repfrm.i on 1 }
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
    F-qnty-o column-label "6":C13    space(0)
    sym6 column-label ":" format "X(1)" space(0)
    f-PriceSALE column-label "7":C13  space(0)
    sym7 column-label ":" format "X(1)" space(0)
    f-discnt-sum column-label "8":C9 space(0)
    sym8 column-label ":" format "X(1)" space(0)
    f-SumSALE column-label "9":C13  space(0)
    sym9 column-label ":" format "X(1)" space(0)
    f-SumSALE-o column-label "10":C13  space(0)
    sym10 column-label ":" format "X(1)" space(0)
    HEADER
        Line format "X(198)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX .
     assign
        i=0
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        FirstLine     = FALSE
        Line          = fill("-",138)
        startdate     = x-Date-Start
        enddate       = x-Date-End
        start-date    = x-Date-Start
        end-date      = x-Date-End
        OpenedDocs    = if (x-type-dog <> 1 ) then true else false
        PriceDocs     = xtog-ov
        ClosedDocs    = if (x-type-dog <> 2 ) then true else false

        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE
        tow-unit = false

        .

{ rep/r-val.i }

if paytype = 2 then PriceDocs = true .
curr-rep = (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) .
t-char = 'Остаток ,' + (if tPrintRubl then '{&abbr_rub_allshift}' else x-base-type) .
     DELETE WIDGET-POOL "qq" no-error  .
     CREATE WIDGET-POOL "qq" PERSISTENT.
        { rep/r-o-cre.i h-fact-date    "'Дата закрытия'"           8  1  }
        { rep/r-o-cre.i h-doc-code     "'Номер документа'"         10 10 }
        { rep/r-o-cre.i h-type-doc     "'Тип'"                     3  21 }
        { rep/r-o-cre.i h-cli-name     "'Контрагент'"              30 25 }
        { rep/r-o-cre.i h-qnty         "'Количество'"              10 56 }
        { rep/r-o-cre.i h-qnty-o       "'Остаток (количество)'"    13 70 }
        { rep/r-o-cre.i h-PriceSALE    "'Цена/разница'"            13 84 }
        { rep/r-o-cre.i h-discnt-sum   "'Сумма скидки'"            10 98 }
        { rep/r-o-cre.i h-SumSALE      "'Сумма по документу'"      13 109 }
        if PriceDocs = true then do:
            { rep/r-o-cre.i h-SumSALE-o    t-char                  13 123 }
            End.
            else f-SumSALE-o:label in frame zapas = " ".

        Find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
        If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                              Else   Prtroot = 0.

    run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------*/
{ trg/prdoclib.i }
{ str/prl-vat.i  }


PROCEDURE report-execute :
  NO-PRISE = true .
  if var-report-r-b = "rubl"  Then do:
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  end.
  else do:
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  end.


  if  ReportPageHeight = 0 then  ReportPageHeight = 43.
  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}

  find first ub.goods where
                        ub.goods.prod-code    = v-x-prod-code
                  AND   ub.goods.prod-type    = v-x-prod-type
                  AND   ub.goods.artic        = v-x-artic no-lock no-error .
  find first b-goods where
                        b-goods.prod-code    = v-x-prod-code
                  AND   b-goods.prod-type    = v-x-prod-type
                  AND   b-goods.artic        = v-x-artic no-lock no-error .

  IF ub.goods.prt-root = Prtroot Then make-one = true .
  { gbl/gdsbcode.i b-goods.gds-code ? v-bar-code  }
  run display-title in this-procedure .
  display STREAM OutStream  with frame top-Frame .
    FORM HEADER
      string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 100 format "x(24)" SKIP
    with FRAME BottomFrame2 width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
 VIEW STREAM OutStream FRAME BottomFrame2 .
/*---------------------------------------------------------------------------------------------------------------------*/
   ll = 0.
   FOR EACH OBJ-list no-lock :
   ll = ll + 1 .
      x-store-code = obj-list.obj-code.
      x-store-type = obj-list.obj-type.
      Quantity = 0 .
      Coast    = 0 .
      if ll > 1 THEN Page stream OutStream.
      run report-exec1.
  /* HIDE STREAM OutStream FRAME ZAPAS .     */
  End. /* for each */

  HIDE STREAM OutStream FRAME ZAPAS .
  HIDE STREAM OutStream FRAME top-Frame .
  Output stream OutStream close.
  DELETE WIDGET-POOL "qq".
  { rep/repfrm.i off }
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 8 .

  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
  eND PROCEDURE.


PROCEDURE display-line :
   i = i + 1.
   v-ii = v-ii + 1.
  { rep/repfrm.i disp v-ii reportname ub.goods.gds-name}
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    qnty       @  F-qnty
    qnty-o     @  F-qnty-o
    PriceSALE  @  f-PriceSALE
    SumSALE    @  f-SumSALE
    SumSALE-o when ( PriceDocs = true ) @  f-SumSALE-o
    discnt-sum @  f-discnt-sum
    {&WFz} . {&FRAME-d}.
END PROCEDURE.

PROCEDURE display-line-ext :

define input parameter v-doc-code as character no-undo .
define buffer bf_doc-line for ub.doc-line.
define variable l-qnty as decimal no-undo .
define variable l-pr   as decimal no-undo .
find first bf_doc-line no-lock where bf_doc-line.doc-code = v-doc-code
                  and   ub.goods.prod-code    = bf_doc-line.prod-code
                  AND   ub.goods.prod-type    = bf_doc-line.prod-type
                  AND   ub.goods.artic        = bf_doc-line.artic
                  no-error .

   i = i + 1.
   v-ii = v-ii + 1.
   run local-fchg-qnty in this-procedure (input  recid(bf_doc-line), output l-qnty) no-error.
   l-pr    = if ( SumSALE / l-qnty) <> ? then SumSALE / l-qnty else 0.
  { rep/repfrm.i disp v-ii reportname ub.goods.gds-name}
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    l-qnty     @  F-qnty
    qnty-o     @  F-qnty-o
    l-pr       @  f-PriceSALE
    SumSALE    @  f-SumSALE
    SumSALE-o when ( PriceDocs = true ) @  f-SumSALE-o
    discnt-sum @  f-discnt-sum
    {&WFz} . {&FRAME-d}.
END PROCEDURE.


PROCEDURE display-line2 :
   i = i + 1.
   v-ii = v-ii + 1.
  { rep/repfrm.i disp v-ii reportname ub.goods.gds-name}
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    qnty       @  F-qnty
    PriceSALE  @  f-PriceSALE
    SumSALE    @  f-SumSALE
    discnt-sum @  f-discnt-sum
    {&WFz} . {&FRAME-d}.
END PROCEDURE.


PROCEDURE Print-Footer :
/*Печать оборота*/

  Quantity2 =  rest-qnty .
  Coast2    =  rest-base .
  run U-LINE in this-procedure .
  if x-type-dog <> 2  then do:
    TEMPSTR =  string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
    PUT STREAM OutStream
      SKIP
      SPACE(5)
      TEMPSTR format "x(72)"
      SKIP
      SPACE(32) string( "Количество: " + trim( string( Quantity2, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
      SKIP.

      PUT STREAM OutStream
      SPACE(32)
      if PriceDocs = true  then
        string( "Cумма  цен: " +
        trim( string( Coast2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
        curr-rep )
      else    ""
      format "x(72)"  SKIP
      .


    end.


  END PROCEDURE.


PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
F-fact-date
f-type-doc
f-doc-code
f-cli-name
F-qnty-o
F-qnty
f-priceSALE
f-SumSALE
f-SumSALE-o
f-discnt-sum
{&wFz} .
{&FRAME-d}.
END PROCEDURE.


PROCEDURE Display-title :
     {&PUT-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
      CAPS(REPORTNAME) + {&new-line} +
      ub.goods.artic + " " + ub.goods.gds-name + " " +  ub.goods.PS  +
      (if ub.goods.sort <> "" then  " (" + ub.goods.sort  + "*)"   else " ")

        AT 20 format "X(170)" SKIP
      Trim(str1)  AT 35 format "X(75)" SKIP
      Trim(str3)  AT 35 format "X(75)" SKIP.
      Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
          PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
      End.
      i = 0 .
      FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                                x-store-code = ub.clients.obj-code no-lock no-error.
      If available ub.clients then  ObjName    = ub.clients.obj-name.
                           else  ObjName    = "объект не определен" .
     {&PUT-u1}  "Объект  : " + ObjName FORMAT "X(170)" skip.
       TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .

    run make-temp-table-befor in this-procedure .
    Quantity1 = rest-qnty .
    Coast1    = rest-base .
    if x-type-dog <> 2  then do:
    PUT STREAM OutStream
    SKIP
    SPACE(5)
    TEMPSTR format "x(72)"
    SKIP
    SPACE(32) string( "Количество: " + trim( string( Quantity1, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
    SKIP
      SPACE(32)
      string( "Cумма  цен: " +
                   trim( string( Coast1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                   curr-rep ) format "x(72)"
        SKIP
       .
    end.
end procedure.


PROCEDURE Print-temp-t  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic          like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter xTog-obj         as   log                  no-undo.

define variable first-rec as logical init true no-undo .
define variable t-qnty like Quantity no-undo .
define variable t-cost like Coast    no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
 run make-temp-table in this-procedure .
        if ClosedDocs OR PriceDocs then
            do:
                FOR EACH gds-rep WHERE ( ( ClosedDocs AND gds-rep.doc-type <> {&P} ) OR
                                                               ( PriceDocs AND gds-rep.doc-type = {&P} ) ) AND
                                                               gds-rep.fact-num <> 0
                            BY gds-rep.fact-order  by gds-rep.nn:

                    ACCUMULATE gds-rep.doc-code ( COUNT ) .
                    assign
                      type-doc   = gds-rep.doc-type
                      fact-date  = gds-rep.fact-date
                      cli-name   = gds-rep.clients
                      discnt-sum = gds-rep.discnt-tot
                      doc-code   = gds-rep.doc-code
                      qnty       = gds-rep.fact-qnty
                      SumSALE    = gds-rep.netto
                      PriceSALE  = gds-rep.sale-base
                      qnty-o     = gds-rep.rest-qnty
                      SumSALE-o  = gds-rep.rest-base
                      vvv        = gds-rep.vv

                      .
                    /*
                    message gds-rep.doc-code v2 gds-rep.rest-base gds-rep.fact-order .
                    */
                    if gds-rep.ext-doc-type = {&TDEDT_Corr_Acc_Price} then do:
                      run display-line-ext in this-procedure (input  doc-code) .
                    end.
                    else do:
                       run display-line in this-procedure .
                    end.

                    rest-qnty = gds-rep.rest-qnty .
                    rest-base = gds-rep.rest-base .
                END .
                if ( ACCUM COUNT gds-rep.doc-code ) <> 0 then
                    BadResults = FALSE .
            end.
        if OpenedDocs AND
           can-find( first gds-rep where gds-rep.fact-num = 0 ) then    /* открытые документы */
            do:
                DISPLAY stream  OutStream
                "--------"  @  F-fact-date
                string( "Открытые документы !" )   @  f-cli-name
                {&WFz} . {&FRAME-d} .
                FOR EACH gds-rep where gds-rep.fact-num = 0 BY gds-rep.fact-date :
                    ACCUMULATE gds-rep.doc-code ( COUNT ) .
                    assign
                      type-doc   = gds-rep.doc-type
                      fact-date  = gds-rep.fact-date
                      cli-name   = gds-rep.clients
                      discnt-sum = gds-rep.discnt-tot
                      doc-code   = gds-rep.doc-code
                      qnty       = gds-rep.fact-qnty
                      SumSALE    = gds-rep.netto
                      PriceSALE  = gds-rep.sale-base
                      qnty-o     = gds-rep.rest-qnty
                      SumSALE-o  = gds-rep.rest-base
                      .

                    run display-line2 in this-procedure  .
                END .
                if ( ACCUM COUNT gds-rep.doc-code ) <> 0 then
                    BadResults = FALSE .
            end.
END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-exec1 :
        if xtog-inv then DO:
          For each ub.trn-doc where ub.trn-doc.doc-type = {&inventory} and
            ub.trn-doc.fact-date >= startdate and
            ub.trn-doc.obj-code   = x-store-code and
            ub.trn-doc.obj-type   = x-store-type and
            ub.trn-doc.status_    = {&fact}
            no-lock,
            first ub.doc-line where
                ub.doc-line.artic      = v-x-artic     and
                ub.doc-line.prod-type  = v-x-prod-type and
                ub.doc-line.prod-code  = v-x-prod-code and
                ub.doc-line.doc-code   = ub.trn-doc.doc-code   no-lock :
                Assign
                   inv-fact-order = ub.trn-doc.fact-order
                   inv-fact-date  = ub.trn-doc.fact-date
                   inv-str        = "Последняя инвентаризация " +  string(trn-doc.fact-date ,"99/99/9999" ) + " документ № " + ub.doc-line.doc-code.
          End.
         End.
Assign
       TOT-SumSALE    = 0
       TOT-qnty       = 0
       TOT-discnt-sum = 0
       .
   FIND FIRST ub.clients where ub.clients.obj-type = x-store-type AND
                            ub.clients.obj-code = x-store-code no-lock no-error .
           If available ub.clients then  ObjName = ub.clients.obj-name .
                                else  ObjName = "объект не определен" .
  FORM with FRAME zapas .
  { rep/r-formh.i X(197) {&DOS_cw_2}}

  run print-temp-t in this-procedure (
      input   x-store-code   ,
      input   x-store-type   ,
      INPUT   v-x-artic      ,
      INPUT   v-x-prod-code  ,
      INPUT   v-x-prod-type  ,
      INPUT   Fact-order-1   ,
      INPUT   Fact-order-2   ,
      input   {&arh-crsa}    ,
      input   {&root-cat-id} ,
      input   YES ) .

  HIDE stream OutStream FRAME BottomFrame2 .
  run print-footer in this-procedure .
END PROCEDURE.


Procedure make-temp-table :
define variable cur-dn as character no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable f-o as decimal no-undo .

define variable price-old like ub.price-list.price-sale no-undo .
define variable t-dec as decimal no-undo .
define variable cost-sum-base as decimal no-undo  .
define variable cost-sum-rubl  as decimal no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
define variable v11 as decimal no-undo .
define variable v21 as decimal no-undo .

define variable sum-rest-base as decimal no-undo .
define variable sum-rest-base1 as decimal no-undo .
define variable             v-fact-qnty  as decimal no-undo .
define variable             v-sale-base  as decimal no-undo .
define variable             v-netto      as decimal no-undo .
define variable             v-tot-base   as decimal no-undo .

/*-------------------------------------------------------------------------*/
if ClosedDocs then
    FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code = b-goods.prod-code
                   AND ub.doc-line.prod-type = b-goods.prod-type
                   AND ub.doc-line.obj-type = x-store-type
                   AND ub.doc-line.obj-code = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                                    AND ub.trn-doc.fact-date >= start-date
                                    AND ub.trn-doc.fact-date <= end-date
                                    AND ub.trn-doc.fact-num <> 0
                        NO-LOCK BY ub.trn-doc.fact-order :
      { str/out-vatp.i doc-line doc-line. trn-doc. }
      { str/in-vatp.i  calc     doc-line. trn-doc. }
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .

        CREATE gds-rep.
        assign
            gds-rep.ii        = 0
            gds-rep.doc-code  = ub.trn-doc.doc-code
            gds-rep.doc-num   = ub.trn-doc.doc-code
            gds-rep.doc-type  = ub.trn-doc.doc-type
            gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
            gds-rep.fact-num  = ub.trn-doc.fact-num
            gds-rep.fact-order = ub.trn-doc.fact-order
            gds-rep.fact-date = ub.trn-doc.fact-date
            gds-rep.fact-qnty = ( if can-do({&expense_write-off}, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .
            case ub.trn-doc.ext-doc-type :
             when {&TDEDT_Chg_Purch_Code} then do:
                 gds-rep.clients   = "Смена типа приобретения" .
             end.
             when {&TDEDT_Corr_Acc_Price} then do:
                 gds-rep.clients   = "Коррекция учетной цены"   .
             end.
             OTHERWISE do:
                gds-rep.clients   = ub.trn-doc.cli-name .
             end.
            end case.


            If PayType = 2 then do:
                Assign
                    gds-rep.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep.fact-qnty
                    gds-rep.discnt-tot = 0 .
            end.
            Else do:
                if var-report-r-b = "rubl" then
                    Assign
                        gds-rep.sale-base  = price-rubl-with-tax-sale + ( discnt-rubl-sale  )
                        gds-rep.discnt-tot = discnt-rubl-sale *  abs(gds-rep.fact-qnty)  .
                else
                    Assign
                        gds-rep.sale-base  = price-base-with-tax-sale + ( discnt-base-sale  )
                        gds-rep.discnt-tot = discnt-base-sale *  abs(gds-rep.fact-qnty)  .

            end.

            if gds-rep.sale-base = ? then
                gds-rep.sale-base = 0 .

            if gds-rep.discnt-tot = ? then
                gds-rep.discnt-tot = 0 .


            If PayType = 2 then
                gds-rep.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
              Else do:
                 if var-report-r-b  = "rubl" then gds-rep.tot-base = gds-rep.fact-qnty * price-rubl-with-tax-sale.
                                             else gds-rep.tot-base = gds-rep.fact-qnty * price-base-with-tax-sale.
              end.
            if gds-rep.tot-base = ? then
               gds-rep.tot-base = 0 .

        if  ub.trn-doc.doc-type = {&inventory}  Then do:
                assign
                    rest-qnty = rest-qnty + gds-rep.fact-qnty
                    rest-base = rest-base + gds-rep.tot-base.
            end.
         Else do:
                assign
                    rest-qnty = rest-qnty + gds-rep.fact-qnty
                    rest-base = rest-base + ( gds-rep.fact-qnty * gds-rep.sale-base ) .

         end.

         assign
            gds-rep.rest-qnty = rest-qnty
            gds-rep.rest-base = rest-base
            gds-rep.netto = gds-rep.tot-base  .
            v-total-tot-ov = 0 .


        if gds-rep.netto = ? then
            gds-rep.netto = 0 .

            for each gds-dtl-ch where gds-dtl-ch.doc-code  = ub.doc-line.doc-code  and
                                      gds-dtl-ch.artic     = ub.doc-line.artic     and
                                      gds-dtl-ch.prod-type = ub.doc-line.prod-type and
                                      gds-dtl-ch.prod-code = ub.doc-line.prod-code no-lock :
                assign
                      v-total-tot-ov  = v-total-tot-ov
                                      + (gds-dtl-ch.cur-base -
                                      ( if var-report-r-b  = "rubl" then gds-dtl-ch.price-rubl
                                                                  else gds-dtl-ch.price-base )
                                      ) * gds-dtl-ch.fact-qnty.

            end.

        if ( v-total-tot-ov  <> 0  and  PayType <> 2 ) then
            do:
                CREATE gds-rep.
                assign
                    gds-rep.ii = 1
                    gds-rep.doc-code = "------>"  /* ub.trn-doc.doc-code */
                    gds-rep.doc-type = 'а'
                    gds-rep.fact-num = ub.trn-doc.fact-num
                    gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
                    gds-rep.fact-order = ub.trn-doc.fact-order
                    gds-rep.clients  = "переоценка оборотов"
                    gds-rep.fact-date = ub.trn-doc.fact-date
                    gds-rep.fact-qnty = abs( ub.doc-line.fact-qnty ) .

               if can-do({&expense_write-off},trn-doc.doc-type) then
                    assign
                        gds-rep.sale-base = ( v-total-tot-ov ) / ( - ub.doc-line.fact-qnty )
                        .
                else
                    assign
                        gds-rep.sale-base = ( v-total-tot-ov ) / ub.doc-line.fact-qnty
                        .

                if gds-rep.sale-base = ? then
                    gds-rep.sale-base = 0 .

                rest-base = rest-base + ub.doc-line.fact-qnty * gds-rep.sale-base.
                assign
                    gds-rep.discnt-tot = 0
                    gds-rep.tot-base = gds-rep.fact-qnty * gds-rep.sale-base
                    gds-rep.rest-qnty = rest-qnty
                    gds-rep.rest-base = rest-base
                    gds-rep.netto = ub.doc-line.fact-qnty * gds-rep.sale-base
                .
            end.

            run price-prt in this-procedure ( input (gds-rep.fact-order) , output v1, output v2) .
            gds-rep.vv = v2.
            v-ii = v-ii  + 1 .

        { rep/repfrm.i disp v-ii reportname }
    END. /* for each */

/*------------------------------------------------------------------------------------------------------------*/
/*********  Нет разбиения по признакам !!! ***********/

if PayType <> 2 Then  DO:
if PriceDocs then
    FOR EACH p-price-list WHERE
                   p-price-list.obj-type  = x-store-type
               AND p-price-list.obj-code  = x-store-code
               AND p-price-list.artic     = b-goods.artic
               AND p-price-list.prod-type = b-goods.prod-type
               AND p-price-list.prod-code = b-goods.prod-code
               NO-LOCK,
        EACH p-price-doc WHERE p-price-doc.doc-num = p-price-list.doc-num
                                    AND p-price-doc.fact-date >= start-date
                                    AND p-price-doc.fact-date <= end-date
                                    AND p-price-doc.fact-num <> 0
                        NO-LOCK break BY p-price-doc.fact-order by p-price-list.doc-num by p-price-list.main-price desc :

       f-o1  = p-price-doc.fact-order  .
       if first-of(p-price-list.doc-num) then DO:
          Assign
                v-fact-qnty  = 0
                v-sale-base  = 0
                v-netto      = 0
                v-tot-base   = 0
                v-p = true

                .

            f-o = p-price-doc.fact-order .
          { gbl/bcodeprc.i
            p-price-list.obj-type
            p-price-list.obj-code
            p-price-list.b-code
            0
            f-o
            cur-dn
            cur-pr
            cur-rt
            cur-ex }
            if cur-pr = ? then cur-pr = 0 .
            price-old = cur-pr .
          end.

          if p-price-list.doc-qnty <> ? then do:
            Assign
                v-fact-qnty  = v-fact-qnty + p-price-list.doc-qnty
                v-sale-base  = v-sale-base + (p-price-list.price-sale - price-old )
                v-netto      = v-netto     + (p-price-list.doc-qnty * (p-price-list.price-sale - price-old ))
                v-tot-base   = v-tot-base  + (p-price-list.doc-qnty * (p-price-list.price-sale - price-old ))
                .
                if main-price = false then v-p = false .
                /* несколько записей */
                If make-one = false  then do:
                CREATE gds-rep.
                assign
                    gds-rep.ii  = ii
                    gds-rep.doc-code  = p-price-list.doc-num
                    gds-rep.fact-date = p-price-doc.fact-date
                    gds-rep.doc-type  = {&P}
                    gds-rep.fact-num  = p-price-doc.fact-num
                    gds-rep.fact-order  = f-o1
                    gds-rep.clients   = {&overvalue}   +
                    (if p-price-list.main-price = false then
                    " " + string(p-price-list.b-code) else " " )
                    gds-rep.fact-qnty = p-price-list.doc-qnty
                    gds-rep.sale-base = p-price-list.price-sale - price-old
                    gds-rep.discnt-tot = 0
                    gds-rep.netto      = gds-rep.fact-qnty  * gds-rep.sale-base
                    gds-rep.tot-base   = gds-rep.fact-qnty  * gds-rep.sale-base
                    ii = II + 1
                    .

                  end.
          end.
          if last-of(p-price-list.doc-num) then DO:

            If make-one then do:
            CREATE gds-rep.
            assign
                gds-rep.ii  = ii
                gds-rep.doc-code  = p-price-list.doc-num
                gds-rep.fact-date = p-price-doc.fact-date
                gds-rep.doc-type  = {&P}
                gds-rep.fact-num  = p-price-doc.fact-num
                gds-rep.fact-order  = f-o1
                gds-rep.clients   = {&overvalue}
                gds-rep.fact-qnty = v-fact-qnty
                gds-rep.sale-base = If (v-netto / v-fact-qnty ) <> ? then (v-netto / v-fact-qnty ) else 0
                gds-rep.discnt-tot = 0
                gds-rep.netto      = v-netto
                gds-rep.tot-base   = v-tot-base
                ii = II + 1
                .

             end.
             else do:
                  IF ub.goods.prt-root <> Prtroot Then DO:

                   run price-prt in this-procedure ( input (f-o ) , output v1, output v2) .
                   CREATE gds-rep.
                   assign
                    gds-rep.ii  = ii
                    gds-rep.doc-code = "----->>"
                    gds-rep.doc-type = 'п'
                    gds-rep.fact-num = p-price-doc.fact-num
                    gds-rep.fact-order = f-o1
                    gds-rep.clients  = "переоценка признаков"
                    gds-rep.fact-date = p-price-doc.fact-date
                    gds-rep.fact-qnty  = 0
                    gds-rep.sale-base  = 0
                    gds-rep.discnt-tot = 0
                    gds-rep.tot-base = 0
                    gds-rep.netto = v-netto
                    ii = II + 1
                  .
                  end.
             end.
            { rep/repfrm.i disp v-ii reportname "'Переоценки'" }
          end. /* if last*/
END.   /* for each */

/* Пересчет остатков */
for each gds-rep :
    run price-prt in this-procedure ( input (gds-rep.fact-order) , output v1, output v2) .
    gds-rep.vv = v2 .
end.


Assign
    rest-base = rest-base1
    rest-qnty = rest-qnty1.

 FOR  EACH buf-gds-rep-3 where buf-gds-rep-3.fact-num <> 0
                             BY buf-gds-rep-3.fact-order
                             by buf-gds-rep-3.ii :
    if buf-gds-rep-3.doc-type  = 'п' then do:
             assign
              buf-gds-rep-3.rest-base = buf-gds-rep-3.vv
              buf-gds-rep-3.netto = buf-gds-rep-3.vv - rest-base
            .
          if buf-gds-rep-3.netto = 0 then do:
             delete buf-gds-rep-3 .
             next.
             end.
    end.

    if buf-gds-rep-3.doc-type  = {&P}
      then do :
            If make-one then do:

                    run price-prt in this-procedure ( input buf-gds-rep-3.fact-order , output v1, output v2) .
                    assign  buf-gds-rep-3.rest-qnty = v1
                            buf-gds-rep-3.rest-base = buf-gds-rep-3.vv .
            end.
            else do: /* много строк */
              IF ub.goods.prt-root <> Prtroot Then DO:
                    assign  buf-gds-rep-3.rest-qnty = rest-qnty
                            buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto .
              end.
            end.
      end.

      else do :  /* остальные документы */
          assign
                buf-gds-rep-3.rest-qnty = rest-qnty + buf-gds-rep-3.fact-qnty
                buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto - buf-gds-rep-3.discnt-tot .
                if  buf-gds-rep-3.rest-base <> buf-gds-rep-3.rest-qnty * buf-gds-rep-3.sale-base  then do:
                    if buf-gds-rep-3.doc-type  = {&return} then
                       buf-gds-rep-3.rest-base = buf-gds-rep-3.rest-qnty * buf-gds-rep-3.sale-base .
                 end.
      end.

   if buf-gds-rep-3.doc-type = 'а' then Assign
                                buf-gds-rep-3.rest-qnty = rest-qnty
                                buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto .
    nn = nn + 1.
    buf-gds-rep-3.nn = nn.
    rest-base = buf-gds-rep-3.rest-base.
    rest-qnty = buf-gds-rep-3.rest-qnty.
END .  /*for each*/
end.  /* if PayType <> 2 */



if OpenedDocs then do:
    FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code = b-goods.prod-code
                   AND ub.doc-line.prod-type = b-goods.prod-type
                   AND ub.doc-line.obj-type = x-store-type
                   AND ub.doc-line.obj-code = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                                    AND ub.trn-doc.doc-date >= start-date
                                    AND ub.trn-doc.doc-date <= end-date
                                    AND ub.trn-doc.fact-num = 0
                        NO-LOCK BY ub.trn-doc.doc-date :
      { str/out-vatp.i doc-line doc-line. trn-doc. }
      { str/in-vatp.i  calc     doc-line. trn-doc. }
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .

        CREATE gds-rep.
        assign
            gds-rep.doc-code  = ub.trn-doc.doc-code
            gds-rep.doc-num   = ub.trn-doc.doc-code
            gds-rep.doc-type  = ub.trn-doc.doc-type
            gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
            gds-rep.fact-num  = ub.trn-doc.fact-num
            gds-rep.fact-order= ub.trn-doc.fact-order
            gds-rep.fact-date = ub.trn-doc.doc-date
            gds-rep.fact-qnty = ( if can-do({&expense_write-off}, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .

            case ub.trn-doc.ext-doc-type :
             when {&TDEDT_Chg_Purch_Code} then do:
                 gds-rep.clients   = "Смена типа приобретения" .
             end.
             when {&TDEDT_Corr_Acc_Price} then do:
                 gds-rep.clients   = "Коррекция учетной цены"   .
             end.

             OTHERWISE do:
                gds-rep.clients   = ub.trn-doc.cli-name .
             end.
            end case.

       If PayType = 2 then
       Assign
          gds-rep.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep.fact-qnty
          gds-rep.discnt-tot = 0 .
       Else do:
         if var-report-r-b  = "rubl" then
            Assign
                gds-rep.sale-base  = price-rubl-with-tax-sale + discnt-rubl-sale
                gds-rep.discnt-tot = discnt-rubl-sale  .
         else
            Assign
                gds-rep.sale-base  = price-base-with-tax-sale + discnt-base-sale
                gds-rep.discnt-tot = discnt-base-sale  .

        end.

        if gds-rep.sale-base = ? then
            gds-rep.sale-base = 0 .

        if gds-rep.discnt-tot = ? then
            gds-rep.discnt-tot = 0 .

        If PayType = 2 then
            gds-rep.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
           Else do:
           if var-report-r-b  = "rubl" then
                gds-rep.tot-base = gds-rep.fact-qnty * price-rubl-with-tax-sale.
                else
                gds-rep.tot-base = gds-rep.fact-qnty * price-base-with-tax-sale.
           end.
        if gds-rep.tot-base = ? then
           gds-rep.tot-base = 0 .

         assign
            gds-rep.rest-qnty = rest-qnty
            gds-rep.rest-base = rest-base
            gds-rep.netto = gds-rep.tot-base  .
         v-total-tot-ov = 0.

        if gds-rep.netto = ? then
            gds-rep.netto = 0 .


            v-ii = v-ii + 1 .
            { rep/repfrm.i disp v-ii reportname "'Открытые накладные'" }
    END.
end.
End procedure.


procedure make-temp-table-befor :
/*-----------------------------------------------------------------------------------------------------------------------*/
/*  Надо отматать кол-ва на нужную дату от текущей */
define variable price-old like ub.price-list.price-sale no-undo.
define variable cur-dn as character no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable f-o as decimal no-undo .
define variable t-dec as decimal no-undo .
define variable cost-sum-base as decimal no-undo .
define variable cost-sum-rubl  as decimal no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
/*  на сегодня */
define buffer buff_gds-obj for ub.gds-obj .

find first  buff_gds-obj no-lock where
      buff_gds-obj.artic     = v-x-artic         and
      buff_gds-obj.prod-type = v-x-prod-type     and
      buff_gds-obj.prod-code = v-x-prod-code     and
      buff_gds-obj.obj-code  = x-store-code      and
      buff_gds-obj.obj-type  = x-store-type no-error
      .
      if not available buff_gds-obj  then do:
      message "Товара" v-x-artic
              v-x-prod-type
              v-x-prod-code   skip
              "нет на объекте "
              x-store-code
              x-store-type
             view-as alert-box information .
      return.
      end.

assign
rest-qnty = buff_gds-obj.fact-qnty
.
if paytype = 2 then do:
   if var-report-r-b  = "rubl" then
            rest-base =  buff_gds-obj.fact-rubl .
      else  rest-base =  buff_gds-obj.fact-base .
   end.
else rest-base =  buff_gds-obj.fact-sale .

     FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code  = b-goods.prod-code
                   AND ub.doc-line.prod-type  = b-goods.prod-type
                   AND ub.doc-line.obj-type   = x-store-type
                   AND ub.doc-line.obj-code   = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                      AND ub.trn-doc.fact-date >= start-date
                      AND ub.trn-doc.fact-num <> 0
                        NO-LOCK BY ub.trn-doc.fact-order DESCENDING :
      { str/out-vatp.i doc-line doc-line. trn-doc. }
      { str/in-vatp.i  calc     doc-line. trn-doc. }
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .

        CREATE gds-rep-befor.
        assign
            gds-rep-befor.doc-code  = ub.trn-doc.doc-code
            gds-rep-befor.doc-num   = ub.trn-doc.doc-code
            gds-rep-befor.doc-type  = ub.trn-doc.doc-type
            gds-rep-befor.fact-num  = ub.trn-doc.fact-num
            gds-rep-befor.fact-order= ub.trn-doc.fact-order
            gds-rep-befor.fact-date = ub.trn-doc.fact-date
            gds-rep-befor.fact-qnty = ( if can-do({&expense_write-off}, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .
            case ub.trn-doc.ext-doc-type :
             when {&TDEDT_Chg_Purch_Code} then do:
                 gds-rep-befor.clients   = "Смена типа приобретения" .
             end.
             when {&TDEDT_Corr_Acc_Price} then do:
                 gds-rep-befor.clients   = "Коррекция учетной цены"   .
             end.

             OTHERWISE do:
                gds-rep-befor.clients   = ub.trn-doc.cli-name .
             end.
            end case.

       If PayType = 2 then
       Assign
          gds-rep-befor.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep-befor.fact-qnty
          gds-rep-befor.discnt-tot = 0 .
       else do:
          if var-report-r-b  = "rubl" then
              assign
                  gds-rep-befor.sale-base = price-rubl-with-tax-sale + discnt-rubl-sale
                  gds-rep-befor.discnt-tot = discnt-rubl-sale  .
              else
              assign
                  gds-rep-befor.sale-base = price-base-with-tax-sale + discnt-base-sale
                  gds-rep-befor.discnt-tot = discnt-base-sale  .


        end.

        if gds-rep-befor.sale-base = ? then
            gds-rep-befor.sale-base = 0 .


        if gds-rep-befor.discnt-tot = ? then
           gds-rep-befor.discnt-tot = 0 .


        If PayType = 2 then
            gds-rep-befor.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
           Else do:
            if var-report-r-b  = "rubl" then
                 gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * price-rubl-with-tax-sale.
            else
                 gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * price-base-with-tax-sale.
            end.

        if gds-rep-befor.tot-base = ? then
           gds-rep-befor.tot-base = 0 .

        if  ub.trn-doc.doc-type = {&inventory}  Then
                assign
                    rest-qnty = rest-qnty - gds-rep-befor.fact-qnty
                    rest-base = rest-base - gds-rep-befor.tot-base.
            Else
                assign
                    rest-qnty = rest-qnty - gds-rep-befor.fact-qnty
                    rest-base = rest-base - (gds-rep-befor.fact-qnty * gds-rep-befor.sale-base ).

        assign
            gds-rep-befor.rest-qnty = rest-qnty
            gds-rep-befor.rest-base = rest-base
            gds-rep-befor.netto = gds-rep-befor.tot-base
            v-total-tot-ov = 0
            .

            for each gds-dtl-ch where gds-dtl-ch.doc-code  = ub.doc-line.doc-code  and
                                      gds-dtl-ch.artic     = ub.doc-line.artic     and
                                      gds-dtl-ch.prod-type = ub.doc-line.prod-type and
                                      gds-dtl-ch.prod-code = ub.doc-line.prod-code no-lock :
                assign
                      v-total-tot-ov  = v-total-tot-ov
                                      + (gds-dtl-ch.cur-base -
                                      ( if var-report-r-b  = "rubl" then
                                         gds-dtl-ch.price-rubl
                                         else gds-dtl-ch.price-base)
                                      ) * gds-dtl-ch.fact-qnty.

            end.
        if ( v-total-tot-ov  <> 0  and  PayType <> 2 ) then
            do:
                CREATE gds-rep-befor.
                assign
                    gds-rep-befor.doc-code = "------>"  /* ub.trn-doc.doc-code */
                    gds-rep-befor.doc-type = 'а'
                    gds-rep-befor.fact-num = ub.trn-doc.fact-num
                    gds-rep-befor.fact-order = ub.trn-doc.fact-order
                    gds-rep-befor.clients  = "переоценка оборотов"
                    gds-rep-befor.fact-date = ub.trn-doc.fact-date
                    gds-rep-befor.fact-qnty = abs( ub.doc-line.fact-qnty ) .

               if can-do({&expense_write-off},trn-doc.doc-type) then
                    assign
                        gds-rep-befor.sale-base = ( v-total-tot-ov ) / ( - ub.doc-line.fact-qnty )
                        .
                else
                    assign
                        gds-rep-befor.sale-base = ( v-total-tot-ov ) / ub.doc-line.fact-qnty
                        .

                if gds-rep-befor.sale-base = ? then
                    gds-rep-befor.sale-base = 0 .

                rest-base = rest-base - ( ub.doc-line.fact-qnty * gds-rep-befor.sale-base ).
                assign
                    gds-rep-befor.discnt-tot = 0
                    gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * gds-rep-befor.sale-base
                    gds-rep-befor.rest-qnty = rest-qnty
                    gds-rep-befor.rest-base = rest-base
                    gds-rep-befor.netto = ub.doc-line.fact-qnty * gds-rep-befor.sale-base
                .
            end.

            v-ii = v-ii  + 1 .
        { rep/repfrm.i disp v-ii reportname }
    END.

if PayType <> 2 Then DO:
define variable v-price-sale as decimal no-undo .
  run price-prt in this-procedure ( input  integer(startdate) , output v1, output v-price-sale) .
  rest-base = v-price-sale .
end.
  rest-base1 = rest-base.
  rest-qnty1 = rest-qnty.
end procedure.

{ rep/r-cost.i }

procedure calc-price-sale-for-prt :
define input parameter fact-order-doc as decimal no-undo .
define input parameter v-bar-code     as character no-undo .

define output parameter v-cur-base as decimal no-undo .
define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define var parrecid-prl as recid no-undo .
{ str/out-vatp.i def " " " " " " -prl " " }
/*   определяем сумму в продажных ценах    */
/* определяем продажную цену на дату инициализации архива */
/*
        { gbl/bcodepls.i
          x-store-type
          x-store-code
          v-bar-code
          0
          fact-order-doc
          parrecid-prl
          v-cli-base-rate
          no-error
        }
*/
        run bcodepls-price in this-procedure (
            input  x-store-type,
            input  x-store-code,
            input  v-bar-code  ,
            input  0           ,
            input  fact-order-doc,
            output  parrecid-prl ,
            output  v-cli-base-rate )
        no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении цены бар-кода" skip
                  "Объект" ub.gds-obj.obj-type ub.gds-obj.obj-code skip
                  "Бар-код" v-bar-code skip
                  "fact-order" fact-order-doc skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
                 if parrecid-prl <> ? then do:
          run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процеды prl-vat" skip
                    "Документ" ub.doc-line.doc-code skip
                    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
          .
        end.

  assign

    v-cur-base =  if var-report-r-b  = "rubl" then price-rubl-with-tax-sale-prl
                                              else  price-base-with-tax-sale-prl
  .
end procedure.


procedure price-prt :

define input parameter fact-order-doc    as decimal no-undo .
define output parameter p-qnty       as decimal no-undo .
define output parameter p-sale-sum   as decimal no-undo .
define variable v-price-sale as decimal no-undo .
  Assign
    p-qnty      = 0
    p-sale-sum  = 0   .


/* а есть ли у него шкала ? */
IF ub.goods.prt-root <> Prtroot or true = true  Then DO:
  run prdoclib-init-prt-obj-by-factord in this-procedure
( input x-store-type  ,
  input x-store-code  ,
  input ub.goods.artic     ,
  input ub.goods.prod-type ,
  input ub.goods.prod-code ,
  input fact-order-doc ,
  input false ) .

  for each ub.prt-obj where
      ub.prt-obj.artic     = ub.goods.artic     and
      ub.prt-obj.prod-type = ub.goods.prod-type and
      ub.prt-obj.prod-code = ub.goods.prod-code and
      ub.prt-obj.obj-code  = x-store-code and
      ub.prt-obj.obj-type  = x-store-type and
      ub.prt-obj.IS-term   =  true no-lock
            BREAK BY ub.prt-obj.prt-code  :

    IF last-of(ub.prt-obj.prt-code) THEN DO:

              { gbl/gdsbcode.i ub.goods.gds-code ub.prt-obj.prt-code v-bar-code  } /* бар-код признака*/
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                     if avail temp-prt-obj then do :
                       run calc-price-sale-for-prt in this-procedure  (input fact-order-doc , input v-bar-code ,output v-price-sale) .
                        Assign
                          p-qnty      = p-qnty     + temp-prt-obj.fact-qnty
                          p-sale-sum  = p-sale-sum + temp-prt-obj.fact-qnty * v-price-sale  .
                     End.
    End.
  End.
End.
end procedure.

procedure bcodepls-price :
/*

  Процедура получения продажной цены бар-кода
  и всех компонентов продажной цены

  v-fact-order = 0 Получить текущую продажную цену признака

  v-fact-order <> 0 Для получения цены, действовавшей на определенный момент
                  обычно в качестве v-fact-order следует передавать
                  ub.trn-doc.fact-order документа закрытого по факту

  v-root-b-code   указатель на корневую шкалу
                  Не обязательный параметр.
р.
                  Следует указывать для ускорения поиска цены

  Возвращаемой значение:
  v-recid-price-list  - указатель на запись, если цена найдена
                        ?, если цена не найдена

  */
  define input  parameter v-obj-type         like ub.price-list.obj-type    no-undo .
  define input  parameter v-obj-code         like ub.price-list.obj-code    no-undo .
  define input  parameter v-b-code           like ub.bar-code.b-code        no-undo .
  define input  parameter v-root-b-code      like ub.bar-code.b-code        no-undo .
  define input  parameter v-fact-order       like ub.price-doc.fact-order   no-undo .
  define output parameter v-recid-price-list as recid                       no-undo .
  define output parameter v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .


  define variable vss-description as character no-undo init "bcodepls-01: записи продажной цены признака".

  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .

  do
  on error undo, return error
  :

    /* находим бар-код для которого необходимо определить цену */
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-cli-base-rate = buf_bar-code.cli-base-rate
    .

    if v-fact-order = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан порядковый номер документа" skip
        "Для определения текущей цены он должен быть равен 0" skip
        "Порядковый номер документа" v-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-root-b-code = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равено 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-root-b-code = 0 then do:
      /* определяем бар-код корневого признака товара */
      { gbl/gdsbcode.i buf_bar-code.gds-code ? v-root-b-code no-error}
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error . /* --->>>--- */
      end.
    end.
    else do:
      /* todo - временная мера, проверяем что нам передали действительно */
      /* корневой бар-код товара                                         */
      define variable v-check-root-b-code like ub.bar-code.b-code no-undo .
      { gbl/gdsbcode.i
          buf_bar-code.gds-code
          ?
          v-check-root-b-code
          no-error }

      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error . /* --->>>--- */
      end.
      if v-root-b-code <> v-check-root-b-code then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Код товара" buf_bar-code.gds-code skip
          "Основной бар-код товара" v-check-root-b-code skip
          "В качестве параметра передано" v-root-b-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    /* находим бар-код корневого признака */
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.

    /* гру-бая проверка целостности */
    /* проверяем, что бар-коды принадлежат одно му и тому же товару */
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качеcтве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-fact-order = 0 then do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
        use-index fact-close
        no-error.
    end.
    else do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
          and buf_root_price-list.fact-order <= v-fact-order
        use-index fact-close
        no-error.
    end.
    if  available buf_root_price-list
    and buf_root_price-list.fact-order <> 0 then do:
      /* у товара существует цена */
      if v-b-code = v-root-b-code then do:
        /* требуется цена бар-кода корневого признака */
        assign
          v-recid-price-list = recid(buf_root_price-list)
          v-cli-base-rate    = 1
        .
        return . /* --->>>--- */
      end.
      else do:
        /* нам требуется цена не корневого признака */
        /* необходимо производить поиск наличия специальной цены на бар-код */
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = buf_root_price-list.doc-num
            and buf_price-list.b-code     = v-b-code
            and buf_price-list.price-type = ""
          no-error.
        if available buf_price-list then do:
          assign
            v-recid-price-list = recid(buf_price-list)
            v-cli-base-rate    = 1
          .
          return . /* --->>>--- */
        end.
        if buf_bar-code.unit-cli = buf_root_bar-code.unit-cli then do:
          assign
            v-recid-price-list = recid(buf_root_price-list)
            v-cli-base-rate    = 1
          .
          return . /* --->>>--- */
        end.
        else do:
          /* ищем бар-код с основной единицей измерения */
          /* если его нет, то создаем его */
          define variable v-is-new as logical no-undo .
          { gbl/barcodcr.i
            buf_bar-code.gds-code
            buf_bar-code.node-code
            buf_bar-code.part-code
            buf_bar-code.in-code
            buf_root_bar-code.unit-cli
            1
            v-is-new
            buf_main_bar-code
            no-error }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при поиске бар-кода" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = buf_root_price-list.doc-num
              and buf_price-list.b-code     = buf_main_bar-code.b-code
              and buf_price-list.price-type = ""
            no-error.
          if available buf_price-list then do:
            assign
              v-recid-price-list = recid(buf_price-list)
              /* v-cli-base-rate = cli-base-rate запрашиваемого бар-кода */
            .
            return . /* --->>>--- */
          end.
          else do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
              /* v-cli-base-rate = cli-base-rate запрашиваемого бар-кода */
            .
            return . /* --->>>--- */
          end.
        end.
      end.
    end.
    else do:
      /* цена не задана */
      assign
        v-recid-price-list = ?
        v-cli-base-rate    = ?
      .
      return . /* --->>>--- */
    end.

    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении цены бар-кода" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      "recid(root_price-list)" recid(buf_root_price-list) skip
      "recid(price-list)"      recid(buf_price-list) skip
      view-as alert-box error .
    undo, return error .

  end.

end procedure. /* bcodepls */

procedure local-fchg-qnty :
define input  parameter parrec-line as   recid              no-undo.
define output parameter parqnty     like ub.parts.fact-qnty no-undo.
define buffer local-doc-line for ub.doc-line.
define buffer local-parts     for ub.parts.
find first local-doc-line where recid(local-doc-line) = parrec-line no-lock.
for each local-parts where
         local-parts.out-code  = local-doc-line.doc-code
     and local-parts.obj-type  = local-doc-line.obj-type
     and local-parts.obj-code  = local-doc-line.obj-code
     and local-parts.artic     = local-doc-line.artic
     and local-parts.prod-type = local-doc-line.prod-type
     and local-parts.prod-code = local-doc-line.prod-code
     and local-parts.in-code   = local-doc-line.doc-code   no-lock :
   assign
     parqnty = parqnty + local-parts.fact-qnty.
end.
end procedure.