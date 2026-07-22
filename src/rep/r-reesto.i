/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Реестр документов по объектам

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/03/05

*/

define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter CostSum      as log no-undo.
define input parameter DispUpFact   as log no-undo  .
define input parameter Serv     as log no-undo.
define input parameter RetServ  as log no-undo.
define input parameter NullPer  as log no-undo.
define input parameter CalcRest as log no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ str/trdcalib.i }
{ rep/ostatok.i  }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }
define variable v-log as logical   no-undo .
define variable sliv# as log init true no-undo. /*если TRUE будет сливать в кассу */

/*поля формы*/
define variable F-fact-date      as char no-undo.
define variable F-qnty           as char no-undo.
define variable F-VAT_pc         as char no-undo.
define variable F-SLT_pc         as char no-undo.
define variable F-doc-code       as char no-undo.
define variable F-cli-name       as char no-undo.
define variable F-SumWithNDS     as char no-undo.
define variable F-SumWithoutNDS  as char no-undo.
define variable F-discnt-sum     as char no-undo.
define variable F-ov-sum         as char no-undo.
define variable F-sale-sum       as char no-undo.
define variable F-VAT-Sum        as char no-undo.
define variable F-SLT-sum        as char no-undo.
define variable  v-col-1 as integer no-undo .
define variable  v-col-2 as integer no-undo .
define variable  v-col-3 as integer no-undo .
define variable  v-col-4 as integer no-undo .
define variable  ff like ub.stk-tot.Fact-order init 0 no-undo.

define variable     fact-date            as date no-undo.
define variable     doc-code             as char no-undo.
define variable     cli-name             as char no-undo.
define variable     qnty                 as decimal format "->>>,>>>,>>9.999" no-undo.
define variable     SumWithNDS           as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     discnt-sum           as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     ov-sum               as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     sale-sum             as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     VAT_pc               as decimal format "->9.99"           no-undo.
define variable     VAT-Sum              as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SLT_pc               as decimal format "->9.99"           no-undo.
define variable     SLT-sum              as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithNDS-coast     as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS-coast  as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     VAT-Sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SLT-sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithNDS-disp      as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS-disp   as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     sale-sum-ot          as decimal format "->>>,>>>,>>9.99"  no-undo.

define variable  Fact-order-1-C like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-1-P like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat1     like ub.stk-tot.sum-rubl   no-undo.

define variable  Fact-order-2-C like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-2-P like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat2     like ub.stk-tot.sum-rubl   no-undo.

define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-VAT   like ub.stk-tot.vat-rubl   no-undo.

define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat6       like ub.stk-tot.sum-rubl   no-undo.

define variable  Coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat4         like ub.stk-tot.sum-rubl   no-undo.

define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.

define  stream  OutStream .

define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.

define variable Coast_R1  as decimal no-undo .
define variable VAT_R1    as decimal no-undo .
define variable Coast_R2  as decimal no-undo .
define variable VAT_R2    as decimal no-undo .
define variable Coast_R3  as decimal no-undo .
define variable VAT_R3    as decimal no-undo .
define variable Coast_R4  as decimal no-undo .
define variable VAT_R4    as decimal no-undo .
define variable Coast_V1  as decimal no-undo .
define variable VAT_V1    as decimal no-undo .
define variable Coast_V2  as decimal no-undo .
define variable VAT_V2    as decimal no-undo .
define variable Coast_V3  as decimal no-undo .
define variable VAT_V3    as decimal no-undo .
define variable Coast_V4  as decimal no-undo .
define variable VAT_V4    as decimal no-undo .
define variable xTog-obj as logical no-undo .
define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define variable    iI        as   integer no-undo.
define variable    i         as   integer no-undo .
define variable    j         as   integer no-undo.
define variable    K         as   integer no-undo.
define variable    acc-i     as   integer no-undo .
define variable    acc-j     as   integer no-undo.
define variable   v-vat_pc   as   char no-undo.
define variable   v-vat_sum    as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable   v-vat_sum_f  as   decimal format "->>>,>>>,>>>.<<" no-undo.
define variable   v-slt_pc   as   char no-undo.
define variable   v-slt_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable tmpact as decimal format "->>>>>>>>9.999" no-undo.
/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .

define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.

define variable listtd as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .

define buffer b-stk-tot for ub.stk-tot .


define work-table tmp#taxvat no-undo
field type       like ub.ot-tot.sum-type
field pc         as char
field sum        like ub.ot-tot.vat-base
field sum_full   like ub.ot-tot.sum-base
.

define work-table tmp#taxslt no-undo
field type       like ub.ot-tot.sum-type
field pc         as char
field sum        like ub.ot-tot.vat-base
field sum_full   like ub.ot-tot.sum-base
.


define work-table acc#taxvat no-undo
field type      like ub.ot-tot.sum-type
field pc        as char
field sum       like ub.ot-tot.vat-base
field sum_full  like ub.ot-tot.sum-base
.

define work-table acc#taxslt no-undo
field type      like ub.ot-tot.sum-type
field pc        as char
field sum       like ub.ot-tot.vat-base
field sum_full  like ub.ot-tot.sum-base
.


define temp-table tmp-doc no-undo
field  doc-code      as character
field  ext-doc-type  as character
field  nn as integer
index pi as primary  doc-code
index ind2 nn  doc-code
.

define buffer crsa-ot-tot     for ub.ot-tot.
define buffer cost-ot-tot-inv for ub.ot-tot.
define buffer sale-ot-tot-inv for ub.ot-tot.

/* ************** frame для формы **************** */
DEFINE FRAME DocsRep
    sym1 column-label ":!:" format "X(1)" space(0)
    F-fact-date column-label "Дата!закрытия" format "x(10)" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    f-doc-code column-label "Номер!документа" format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    f-cli-name column-label "Контрагент! " format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    F-qnty column-label "Количество! " format  "x(15)" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    f-SumWithNDS column-label "Сумма!с НДС" format "->>>,>>>,>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    f-SumWithoutNDS column-label "Сумма!без НДС" format "->>>,>>>,>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    f-discnt-sum column-label "Сумма!скидки" format "->>>,>>>,>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    f-ov-sum column-label "Сумма авт.!переоценки" format "->>>,>>>,>>9.99" space(0)
    sym9 column-label ":!:" format "X(1)" space(0)
    f-sale-sum column-label "Сумма!прод. цен" format "->>>,>>>,>>9.99" space(0)
    sym10 column-label ":!:" format "X(1)" space(0)
    F-VAT_pc column-label "Ставка!НДС" format "x(6)" space(0)
    sym11 column-label ":!:" format "X(1)" space(0)
    f-VAT-Sum column-label "Сумма!НДС" format "->>,>>>,>>9.99" space(0)
    sym12 column-label ":!:" format "X(1)" space(0)
    F-SLT_pc column-label "Ставка!НП" format "x(6)" space(0)
    sym13 column-label ":!:" format "X(1)" space(0)
    f-SLT-sum column-label "Сумма налога!с продаж" format "->>,>>>,>>9.99" space(0)
    sym14 column-label ":!:" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в " + (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9" ) ) AT 155 format "X(15)" SKIP
        Line format "X(194)" AT 1
    with width {&dos_CW_2} down stream-io use-text NO-BOX.

/*===================================================================================================================*/
   { rep/repfrm.i def}
   { rep/repfrm.i on 50}

     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        xTog-obj      = true
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

   curr-rep = (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) .
  /* IF (x-base-code <>  (ValType - 1) )  THEN NO-PRISE = false  . */
   NO-PRISE = true .
  if var-report-r-b = "rubl"  then do:
    if  x-base-code <> 0 and valtype = 2  then no-prise = false  .
  end.
  else do:
   if  x-base-code <> 0 and valtype = 1  then no-prise = false  .
  end.

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME DocsRep .
  { rep/r-formh.i x(194) {&dos_CW_2}}
   Line = fill("-", 194).
   run calcitog in this-procedure.
   run print-header in this-procedure.
   run foreach in this-procedure.
  HIDE stream OutStream FRAME BottomFrame .
  run print-footer in this-procedure.
  HIDE STREAM OutStream FRAME DocsRep .
  Output stream OutStream close.
  { rep/repfrm.i off}
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
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

END PROCEDURE.

PROCEDURE print-header :
/*------------------------------------------------------------------------------
  Purpose: Печать шапки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   PUT stream OutStream  string( v-cntxt-host-name-obj)
         AT 50 format "X(85)" SKIP(2)
         "Р Е Е С Т Р   Д О К У М Е Н Т О В  " +
         &If "{1}" = "" &Then "( Т О В А Р Н Ы Й   О Т Ч Е Т )" &else "( У С Л У Г И )" &endif
         AT 35  format "X(100)" skip.

     Repeat i = 1 to NUM-ENTRIES(STR1,chr(10)) :
        PUT stream OutStream  Entry(i,STR1,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
        PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
        PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(160)" SKIP.
     End.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
     End.
    i=0.
/*если есть подсчет остатков */
if CalcRest then
    do:
        { rep/r-reer.i 1 vat}

        if NO-PRISE THEN DO:
           { rep/r-reer2.i 3 vat}
           End.
    end.

   END PROCEDURE.


PROCEDURE Print-Footer :
/*------------------------------------------------------------------------------
  Purpose:  Печать общих итогов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  /* выводим завершающую информацию, свидетельствующую о том, что отчет завершен */
  /* run on-same-page in this-procedure (input 6) . */
  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  run on-same-page in this-procedure (input (13 + v-col-3 + v-col-4 )) .
/*Печать оборота*/
&if "{1}" = "" &then
    Quantity = Quantity2 - Quantity1.
    Coast = Coast2 - Coast1 .
    Coast-vat = Coast-vat2 - Coast-vat1 .
  { rep/r-reer.i " " vat}
     Coast = Coast4 - Coast3 .
     Coast-vat = Coast-vat4 - Coast-vat3 .
  { rep/r-reer2.i " "  vat}
&else
     Quantity = Quantity3.
     Coast = Coast5.
     Coast-vat = Coast-vat5.
     { rep/r-reer.i " "  vat}
     Coast = Coast6.
     Coast-vat = Coast-vat6.
     { rep/r-reer2.i " "  vat}

&Endif
/*Печать остатков на конец*/
if CalcRest then
    do:
        { rep/r-reer.i 2 vat}

        if NO-PRISE THEN DO:
           { rep/r-reer2.i 4 vat}
           End.
    end.
PUT STREAM OutStream " " SKIP(3)
    SPACE(20) "Заведующий __________________"   format "X(32)"
    SPACE(20) "Ст. продавец __________________" format "X(32)"
    SPACE(20) "Бухгалтер __________________"    format "X(32)"
    SKIP .
   run on-same-page in this-procedure (input (13 + v-col-1 + v-col-2 )) .
   END PROCEDURE.

PROCEDURE U-LINE :
UNDERLINE stream OutStream
        sym1
        f-fact-date
        sym2
        f-doc-code
        sym3
        f-cli-name
        sym4
        f-qnty
        sym5
        f-SumWithNDS
        sym6
        f-SumWithoutNDS
        sym7
        f-discnt-sum
        sym8
        f-ov-sum /* when ( NO-PRISE = true ) */
        sym9
        f-sale-sum
        sym10
        f-VAT_pc
        sym11
        f-VAT-Sum
        sym12
        f-SLT_pc
        sym13
        f-SLT-sum
        sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
        END PROCEDURE.

PROCEDURE P-LINE :
UNDERLINE stream OutStream
        sym3
        f-cli-name
        sym4
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
        END PROCEDURE.


PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти Остатки на начало и конец и соответстенные FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ
------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
    Assign
      Coast1        = 0
      Coast-vat1    = 0
      Coast2        = 0
      Coast-vat2    = 0
      Coast3        = 0
      Coast-vat3    = 0
      Coast4        = 0
      Coast-vat4    = 0
   .
   define buffer buf_obj-list for obj-list.
   find first buf_obj-list no-error .
    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input false   ,
        output  Quantity1   ,
        output  Coast_R1    ,
        output  Coast_V1    ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-1-C ).


    run ostatok  in this-procedure(
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  Quantity1  ,
        output  Coast_R3   ,
        output  Coast_V3   ,
        output  VAT_R3     ,
        output  VAT_V3     ,
        output  Fact-order-1-P ).

        Fact-order-1 = Fact-order-1-P .

    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input false ,

        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  Fact-order-2-C ).

    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start , x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false      ,

        output  Quantity2  ,
        output  Coast_R4   ,
        output  Coast_V4   ,
        output  VAT_R4     ,
        output  VAT_V4     ,
        output  Fact-order-2-P ).

        Fact-order-2 = Fact-order-2-P .

    Assign
      Coast1        =  if tPrintRubl then Coast_R1 else  Coast_V1
      Coast-vat1    =  if tPrintRubl then VAT_R1   else  VAT_V1
      Coast2        =  if tPrintRubl then Coast_R2 else  Coast_V2
      Coast-vat2    =  if tPrintRubl then VAT_R2   else  VAT_V2
      Coast3        =  if tPrintRubl then Coast_R3 else  Coast_V3
      Coast-vat3    =  if tPrintRubl then VAT_R3   else  VAT_V3
      Coast4        =  if tPrintRubl then Coast_R4 else  Coast_V4
      Coast-vat4    =  if tPrintRubl then VAT_R4   else  VAT_V4
      .
END PROCEDURE.


PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose:  просмотр оборотов в промежутке факт-ордеров по
  ------------------------------------------------------------------------------*/
  run pre-foreach-intmove.

  If sliv# Then run pre-foreach.
  for each tdedt where tdedt.id  <> {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  no-lock :

      if tdedt.id = {&TDEDT_Overturn} Then find-str = {&arh-crsa{1}} + ','.  /* если переоценка */
                                      Else find-str = temp-find-str.
      for each obj-list ,
          each  ub.ot-tot no-lock where
                ub.ot-tot.obj-type     = obj-list.obj-type
            and ub.ot-tot.obj-code     = obj-list.obj-code
            and ub.ot-tot.ext-doc-type = tdedt.id
            and ub.ot-tot.fact-order   >  fact-order-1
            and ub.ot-tot.fact-order   <= fact-order-2
            and lookup  (ub.ot-tot.sum-type  , find-str ) <> 0
            and can-find (first tmp-doc where tmp-doc.doc-code = ub.ot-tot.doc-code) = false
            break by ub.ot-tot.ext-doc-type
                  by ub.ot-tot.fact-order
                  by ub.ot-tot.doc-code
                  :
         { rep/ree-fe.i ub.ot-tot.ext-doc-type {1} }
      end.  /*  for each ub.ot-tot */
  end.      /*  for each tdedt  */

  If sliv#  Then run runkassa in this-procedure.
  run run-intmove.
END PROCEDURE.


PROCEDURE Break-H-1 :
Display stream OutStream
    sym1
    sym2
    sym3
    CAPS (tdedt.name)  @ F-cli-name
    sym4
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
    with FRAME DocsRep .
    DOWN stream  OutStream 1 with FRAME DocsRep.
  /*  run p-line. */
END PROCEDURE.


PROCEDURE Break-F-1 :
 run u-line.
 Assign
   fact-date = date('')
   doc-code  = ''
   cli-name  = "ИТОГО " +  tdedt.name .
   run break-1str.
   if costsum then run break-cost.
 run break-2str.
 if dispupfact then run break-disp .
 run u-line.
 run erase-var1.
 run erase-var.
END PROCEDURE.


PROCEDURE Break-1str :
Display stream OutStream
    sym1
    fact-date format "99/99/9999" @ f-fact-date
    sym2
    doc-code @ f-doc-code
    sym3
    cli-name @ f-cli-name
    sym4
    qnty format "->>>>>>>9.999"   @ F-qnty
     sym5
     sym6
     sym7
     sym8
     sym9
     sym10
     sym11
     sym12
     sym13
     sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.


PROCEDURE Break-ot :
if NOT (NOT NullPer And sale-sum-ot = 0 And VAT-Sum = 0 and VAT-Sum-coast = 0) THEN DO:
Display stream OutStream
    sym1
    fact-date format "99/99/9999" @ f-fact-date
    sym2
    doc-code @ f-doc-code
    sym3
    cli-name @ f-cli-name
    sym4
    qnty format "->>>>>>>9.999"   @ F-qnty
    sym5
    sym6
    sym7
    sym8
    sym9
    sale-sum-ot @ F-sale-sum
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
 End .
END PROCEDURE.


PROCEDURE Break-2str :             /* по документу */
  define variable str-inv  as character initial "" no-undo .
  define variable str-inv1 as character initial "" no-undo .
  define buffer buf_doc-attr for ub.doc-attr.
  str-inv1 = "".
  If Available ub.trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-nids}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .

      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-dids}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 =  str-inv1  +  ( if  buf_doc-attr.attr-value <> ? and buf_doc-attr.attr-value <> ""  then (  " от " + buf_doc-attr.attr-value ) else " " ).

      if trim(str-inv1) <> "" then assign str-inv = "Основ. " .
    end.
  end.

  Display stream OutStream
    sym1
    sym2    str-inv                           @ f-doc-code
    sym3    str-inv1                          @ f-cli-name
    sym4    "По документу"                    @ f-qnty
    sym5    SumWithNDS                        @ F-SumWithNDS
    sym6    SumWithoutNDS                     @ f-SumWithoutNDS
    sym7    discnt-sum                        @ f-discnt-sum
    sym8    ov-sum  when ( NO-PRISE = true )  @ f-ov-sum
    sym9    sale-sum                          @ f-sale-sum
    sym10   "итого"                           @ f-VAT_PC
    sym11   VAT-Sum                           @ f-vat-sum
    sym12
    sym13   SLT-sum                           @ f-slt-sum
    sym14
  with FRAME DocsRep .
  DOWN stream  OutStream 1 with FRAME DocsRep.
  str-inv1 = "" .
  If Available ub.trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-ndog}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .

      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-ddog}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 =  str-inv1  +  ( if  buf_doc-attr.attr-value <> ? and buf_doc-attr.attr-value <> ""  then (  " от " + buf_doc-attr.attr-value ) else " " ).
          if trim(str-inv1) <> "" then assign str-inv = "Договор " .
    end.
  end.
  if trim(str-inv1) <> "" then do:
      display stream outstream
        sym1
        sym2    str-inv                           @ f-doc-code
        sym3    str-inv1                          @ f-cli-name
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
        sym11
        sym12
        sym13
        sym14
      with frame docsrep .
      down stream  outstream 1 with frame docsrep.
  end.
END PROCEDURE.


PROCEDURE Break-cost :             /* УЧЕТ */
Display stream OutStream
    sym1
    sym2
    sym3
    sym4
    "Учет" @ F-qnty
    sym5
    SumWithNDS-coast    @  f-SumWithNDS
    sym6
    SumWithoutNDS-coast @ F-SumWithoutNDS
    sym7
    sym8
    sym9
    sym10
    "итого"            @ f-vat_PC
    sym11
    VAT-Sum-coast      @ f-VAT-Sum
    sym12
    space(6)
    sym13
    SLT-sum-coast      @ f-slt-sum
    sym14
    with FRAME DocsRep .
    DOWN stream  OutStream 1 with FRAME DocsRep.

END PROCEDURE.


PROCEDURE Break-Akt :
 tmpact = ABSOLUTE (If Available  ub.trn-doc then ub.trn-doc.doc-qnty else 0 )
         - ABSOLUTE (If Available ub.trn-doc then  ub.trn-doc.fact-qnty else 0).
Display stream OutStream
    sym1
    sym2
    sym3
    "Акт несоответствия" @ f-cli-name
    sym4
    tmpact @ f-qnty
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.


PROCEDURE Break-disp :   /* НАЦЕНКА */
  /* наценка */
  Assign
  SumWithNDS-disp     = sale-sum - SumWithoutNDS-coast
  SumWithoutNDS-disp  = SumWithNDS - VAT-Sum - SLT-Sum - SumWithoutNDS-coast.
Display stream OutStream
    sym1
    sym2
    sym3
    sym4
    "Наценка" @ f-qnty
    sym5
    SumWithNDS-disp   @ f-SumWithNDS
    sym6
    SumWithoutNDS-disp @ f-SumWithoutNDS
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.

END PROCEDURE.

PROCEDURE Erase-var :   /* очистка вр таблиц и переменных по документу*/
  Assign
     qnty                  = 0
     SumWithNDS            = 0
     SumWithoutNDS         = 0
     discnt-sum            = 0
     ov-sum                = 0
     sale-sum              = 0
     sale-sum-ot           = 0
     VAT_pc                = 0
     VAT-Sum               = 0
     SLT_pc                = 0
     SLT-sum               = 0
     SumWithNDS-coast      = 0
     SumWithoutNDS-coast   = 0
     VAT-Sum-coast         = 0
     SLT-sum-coast         = 0
     SumWithNDS-disp       = 0
     SumWithoutNDS-disp    = 0
      .
END PROCEDURE.


PROCEDURE pre-foreach :   /* подготовка переменных перед FOR EACH*/
  /*объединение по кассе*/
  if can-find (first tdedt where tdedt.id = {&TDEDT_Vozvrat_Vnesh_Kass}) AND
     can-find (first tdedt where tdedt.id = {&TDEDT_Ras_Vnesh_Kass})  Then  DO:
     Find  First tdedt where tdedt.id = {&TDEDT_Vozvrat_Vnesh_Kass} no-error.
     delete tdedt no-error.
     Find  First tdedt where tdedt.id = {&TDEDT_Ras_Vnesh_Kass} no-error.
     delete tdedt no-error.
     create tdedt.
     Assign  tdedt.id   = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}
             tdedt.name = 'касса' .
  End.
/*-----------------------------------------------------------------------------------------------------------------------*/
/*строка для поиска */
 find-str = {&arh-crsa{1}} + ',' + {&arh-sale{1}} + ',' +
       if CostSum Then              /* если есть учетная цена расшифровка */
             {&arh-cost{1}} + ','
             Else "".
 temp-find-str = find-str.
END PROCEDURE.


PROCEDURE erase-var1 :
  acc-i=0.
  acc-J=0.
  For each acc#taxSLT : delete acc#taxSLT . End.
  For each acc#taxVAt : delete acc#taxVAT . End.
END PROCEDURE.


procedure runkassa :
  find-str = temp-find-str.
    for each obj-list ,
       each ub.ot-tot where
               ub.ot-tot.obj-type = obj-list.obj-type
          and  ub.ot-tot.obj-code = obj-list.obj-code
          and  ub.ot-tot.fact-order >  fact-order-1
          and  ub.ot-tot.fact-order <= fact-order-2
          and  lookup (ub.ot-tot.sum-type  , find-str ) <> 0
          and  (ub.ot-tot.ext-doc-type = {&tdedt_vozvrat_vnesh_kass}
          or    ub.ot-tot.ext-doc-type = {&tdedt_ras_vnesh_kass}) no-lock,
                first tdedt where tdedt.id  = {&tdedt_vozvrat_vnesh_kass} + ',' + {&tdedt_ras_vnesh_kass}  no-lock
                            break by tdedt.id
                                  by ub.ot-tot.fact-order
                                  by ub.ot-tot.doc-code
                                  :
         { rep/ree-fe.i tdedt.id {1} }
      end.  /*  for each ub.ot-tot tdedt*/
end procedure.


PROCEDURE on-same-page :
/* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer  no-undo .

  if p-line-number > page-size( OutStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure. /* on-same-page */
/* $Workfile$ e n d */


procedure pre-foreach-intmove :

  do
  on error undo, return error return-value
  :
define buffer pri_trn-doc  for ub.trn-doc.
define buffer Vz_trn-doc   for ub.trn-doc.
define buffer buf_ot-tot   for ub.ot-tot.
define buffer buf_obj-list for obj-list.

define variable v-nn as integer   no-undo .
v-nn = 0.
  if not ( can-find (first tdedt where tdedt.id = {&TDEDT_Pri_Perem} )  and
           can-find (first tdedt where tdedt.id = {&TDEDT_Ras_Perem} ) and
           can-find (first tdedt where tdedt.id = {&TDEDT_Vozvrat_Perem}) ) then return.

      for each obj-list ,
          each  buf_ot-tot no-lock where
                buf_ot-tot.obj-type      = obj-list.obj-type
            and buf_ot-tot.obj-code      = obj-list.obj-code
            and buf_ot-tot.ext-doc-type  = {&TDEDT_Ras_Perem}
            and buf_ot-tot.fact-order   >  fact-order-1
            and buf_ot-tot.fact-order   <= fact-order-2
            and buf_ot-tot.sum-type      = {&arh-crsa{1}}
            :
                find first  Pri_trn-doc no-lock where
                            Pri_trn-doc.ext-doc-type =  {&TDEDT_Pri_Perem}
                        and Pri_trn-doc.out-code     = buf_ot-tot.doc-code
                        and Pri_trn-doc.status_      = {&fact}
                        and Pri_trn-doc.fact-order   >  fact-order-1
                        and Pri_trn-doc.fact-order   <= fact-order-2 no-error .
                        if available   Pri_trn-doc  and
                           can-find (first buf_obj-list where
                           Pri_trn-doc.fact-qnty <> 0 and
                           Pri_trn-doc.obj-type      = buf_obj-list.obj-type and
                           Pri_trn-doc.obj-code      = buf_obj-list.obj-code   ) then do:
                           v-nn = v-nn + 1.
                           create tmp-doc.
                           assign
                              tmp-doc.doc-code =  buf_ot-tot.doc-code
                              tmp-doc.ext-doc-type =  {&TDEDT_Ras_Perem}
                              tmp-doc.nn = v-nn
                           .
                           create tmp-doc.
                           assign
                              tmp-doc.doc-code =  Pri_trn-doc.doc-code
                              tmp-doc.ext-doc-type =  {&TDEDT_Pri_Perem}
                              tmp-doc.nn = v-nn
                           .
                            find first  Vz_trn-doc no-lock where
                                        Vz_trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Perem}
                                    and Vz_trn-doc.out-code     = Pri_trn-doc.doc-code
                                    and Vz_trn-doc.status_      = {&fact}
                                    and Vz_trn-doc.fact-order   >  fact-order-1
                                    and Vz_trn-doc.fact-order   <= fact-order-2 no-error .
                                    if available   vz_trn-doc then do:
                                        create tmp-doc.
                                        assign
                                            tmp-doc.doc-code =  vz_trn-doc.doc-code
                                            tmp-doc.ext-doc-type =  {&TDEDT_Vozvrat_Perem}
                                            tmp-doc.nn = v-nn
                                        .
                                    end.
                        end.
      end.

  end.
end procedure. /* pre-foreach-intmove */


procedure run-intmove :

  do
  on error undo, return error return-value
  :
  create tdedt.
  assign
    tdedt.name = "ВНУТРЕННЕЕ ПЕРЕМЕЩЕНИЕ"
    tdedt.id =    {&TDEDT_Pri_Perem} + "," +
                  {&TDEDT_Ras_Perem}   + "," +
                  {&TDEDT_Vozvrat_Perem}
  .
       for each  tmp-doc ,
        each ub.ot-tot no-lock where
             ub.ot-tot.doc-code = tmp-doc.doc-code and
             lookup ( ub.ot-tot.sum-type  , find-str ) <> 0
             break
                   by tdedt.id
                   by tmp-doc.nn
                   by ub.ot-tot.fact-order
                   by ub.ot-tot.doc-code :
                    { rep/ree-fe.i tdedt.id {1} }
        end.
  end.
end procedure. /* run-intmove */

/* $Workfile$   E n d */