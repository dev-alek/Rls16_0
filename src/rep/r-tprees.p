block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-tprees.p $
$Archive: rep/r-tprees.p $

Реестр документов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 09/27/01

*/

define input parameter  x-type-pr as character no-undo .
define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter VAT-SLT      as log no-undo.
define input parameter VAT-SLT-s    as log no-undo.
define input parameter CostSum      as log no-undo.
define input parameter DispUpFact   as log no-undo  .
define input parameter Serv     as log no-undo.
define input parameter RetServ  as log no-undo.
define input parameter NullPer  as log no-undo.
define input parameter CalcRest as log no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tprees.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tprees.p $":U .
define variable vss-description as character no-undo init "Реестр документов по типу приобретения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/ostatok.i yes yes }
{ gbl/aht.i      }
{ rep/aht-fo.i   }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }

define variable sliv# as log init true no-undo. /*если TRUE будет сливать в кассу */
define variable v-log as logical   no-undo .
/*поля формы*/
define variable     F-fact-date      as char no-undo.
define variable     F-qnty           as char no-undo.
define variable     F-VAT_pc         as char no-undo.
define variable     F-SLT_pc         as char no-undo.
define variable     F-doc-code       as char no-undo.
define variable     F-cli-name       as char no-undo.
define variable     F-SumWithNDS     as char no-undo.
define variable     F-SumWithoutNDS  as char no-undo.
define variable     F-discnt-sum     as char no-undo.
define variable     F-ov-sum         as char no-undo.
define variable     F-sale-sum       as char no-undo.
define variable     F-VAT-Sum        as char no-undo.
define variable     F-SLT-sum        as char no-undo.
define variable v-col-1 as integer no-undo .
define variable v-col-2 as integer no-undo .
define variable v-col-3 as integer no-undo .
define variable v-col-4 as integer no-undo .
define variable ff like ub.stk-tot.Fact-order init 0 no-undo.

define  variable     fact-date      as date no-undo.
define  variable     doc-code       as char no-undo.
define  variable     cli-name       as char no-undo.
define  variable     qnty           as decimal format "->>>,>>>,>>9.999" no-undo.
define  variable     SumWithNDS     as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SumWithoutNDS  as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     discnt-sum     as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     ov-sum         as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     sale-sum       as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     VAT_pc         as decimal format "->9.99"           no-undo.
define  variable     VAT-Sum        as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SLT_pc         as decimal format "->9.99"           no-undo.
define  variable     SLT-sum        as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SumWithNDS-coast     as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SumWithoutNDS-coast  as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     VAT-Sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SLT-sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SumWithNDS-disp      as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     SumWithoutNDS-disp   as decimal format "->>>,>>>,>>9.99"  no-undo.
define  variable     sale-sum-ot          as decimal format "->>>,>>>,>>9.99"  no-undo.

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

define stream  OutStream .

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

define  variable    iI        as   integer no-undo.
define  variable    i         as   integer no-undo .
define  variable    j         as   integer no-undo.
define  variable    K         as   integer no-undo.
define  variable    acc-i     as   integer no-undo .
define  variable    acc-j     as   integer no-undo.
define  variable   v-vat_pc   as   char no-undo.
define  variable   v-vat_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define  variable   v-slt_pc   as   char no-undo.
define  variable   v-slt_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define  variable tmpact as decimal format "->>>>>>>>9.999" no-undo.
/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .

define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.

define variable listtd as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .

define buffer b-stk-tot for ub.stk-tot .


define work-table tmp#taxVAT NO-UNDO
   Field type Like ub.aht-ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.aht-ot-tot.cost-VAT-base.

define work-table tmp#taxSLT NO-UNDO
   Field type Like ub.aht-ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.aht-ot-tot.cost-VAT-base.

define work-table acc#taxVAT NO-UNDO
   Field type Like ub.aht-ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.aht-ot-tot.cost-VAT-base.

define work-table acc#taxSLT NO-UNDO
   Field type Like ub.aht-ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.aht-ot-tot.cost-VAT-base.

define buffer crsa-OT-tot FOR ub.aht-ot-tot.
define buffer cost-ot-tot-inv FOR ub.aht-ot-tot.
define buffer sale-ot-tot-inv FOR ub.aht-ot-tot.

define variable arh-type-sale as character no-undo .
define variable arh-type-crsa as character no-undo .
define variable arh-type-cost as character no-undo .
define variable arh-type-sadt as character no-undo .
define variable arh-type-cgdt as character no-undo .
define variable arh-type-csdt as character no-undo .
define variable arh-type-allsum  as character no-undo .

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
   { rep/repfrm.i on 10}

       FIND first ub.clients where ub.clients.obj-type = x-store-type AND
                                ub.clients.obj-code = x-store-code no-lock no-error .
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName = "объект не определен".
     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        xTog-obj      = true
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.


   run aht_get-sum-type (
        input   x-type-pr    ,
        output  arh-type-allsum ).

   run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   curr-rep = (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) .
  /* IF (x-base-code <>  (ValType - 1) )  THEN NO-PRISE = false  . */
   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .


  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME DocsRep .
  { rep/r-formh.i x(194) {&dos_CW_2}}
   Line = fill("-", 194).
   run calcitog in this-procedure.
   run print-header in this-procedure.

  run foreach in this-procedure.
  hide stream outstream frame bottomframe .
  run print-footer in this-procedure.
  hide stream outstream frame docsrep .
  output stream outstream close.
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
   PUT stream OutStream  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         reportname
         AT 35  format "X(100)" skip.

     Repeat i = 1 to NUM-ENTRIES(STR1,chr(10)) :
        PUT stream OutStream  Entry(i,STR1,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
     End.
    i=0.
/*если есть подсчет остатков */
if CalcRest then
    do:
        { rep/r-reer.i 1 }
        if NO-PRISE THEN DO:
           { rep/r-reer2.i 3 }
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
    Quantity = Quantity2 - Quantity1.
    Coast = Coast2 - Coast1 .
    Coast-vat = Coast-vat2 - Coast-vat1 .
  { rep/r-reer.i " " vat}
     Coast = Coast4 - Coast3 .
     Coast-vat = Coast-vat4 - Coast-vat3 .
  { rep/r-reer2.i " "  vat}
/*Печать остатков на конец*/
if CalcRest then
    do:
        { rep/r-reer.i 2 }
        if NO-PRISE THEN DO:
           { rep/r-reer2.i }
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
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run aht-ostatok (
        input x-store-code     ,
        input x-store-type     ,
        input x-tog-shift      ,
        input x-date-start - 1 ,
        input date('')         ,
        input x-shift-start    ,
        input x-shift-end      ,
        input "n"    ,
        input xtog-obj         ,
        output  fact-order-1 ) .
/*----------------------------------------------------------------------------------------------------------------*/
/*номер последнего fact-ordera и остатки на конец интервала  */
/* номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
    run aht-ostatok (
        input x-store-code  ,
        input x-store-type  , x-tog-shift,
        input x-date-start  ,
        input x-date-end    , x-shift-start,x-shift-end,
        input "n" ,
        input xtog-obj ,
        output  fact-order-2 ).

  find last  ub.aht-stk-tot where
            ub.aht-stk-tot.obj-type   = x-store-type and
            ub.aht-stk-tot.obj-code   = x-store-code and
            ub.aht-stk-tot.sum-type   = x-type-pr    and
            ub.aht-stk-tot.fact-order <= fact-order-1
            no-lock use-index pi  no-error .
     if available ub.aht-stk-tot then do:
     assign
        Quantity1  = ub.aht-stk-tot.fact-qnty
        Coast_R1   = ub.aht-stk-tot.cost-sum-rubl
        Coast_V1   = ub.aht-stk-tot.cost-sum-base
        VAT_R1     = ub.aht-stk-tot.cost-vat-rubl
        VAT_V1     = ub.aht-stk-tot.cost-vat-base

        Coast_R3   = ub.aht-stk-tot.crsa-sum-rubl
        Coast_V3   = ub.aht-stk-tot.crsa-sum-base
        VAT_R3     = ub.aht-stk-tot.crsa-vat-rubl
        VAT_V3     = ub.aht-stk-tot.crsa-vat-base
     .
     end.
  find last  ub.aht-stk-tot where
             ub.aht-stk-tot.obj-type   = x-store-type and
             ub.aht-stk-tot.obj-code   = x-store-code and
             ub.aht-stk-tot.sum-type   = x-type-pr    and
             ub.aht-stk-tot.fact-order <=  fact-order-2
             no-lock use-index pi no-error .
       if available ub.aht-stk-tot then do:

       assign
          Quantity2 = ub.aht-stk-tot.fact-qnty
          Coast_R2  = ub.aht-stk-tot.cost-sum-rubl
          Coast_V2  = ub.aht-stk-tot.cost-sum-base
          VAT_R2    = ub.aht-stk-tot.cost-vat-rubl
          VAT_V2    = ub.aht-stk-tot.cost-vat-base

          Coast_R4  = ub.aht-stk-tot.crsa-sum-rubl
          Coast_V4  = ub.aht-stk-tot.crsa-sum-base
          VAT_R4    = ub.aht-stk-tot.crsa-vat-rubl
          VAT_V4    = ub.aht-stk-tot.crsa-vat-base
       .
      end.

    Assign
      Coast1        = if tPrintRubl then Coast_R1 else  Coast_V1
      Coast-vat1    = if tPrintRubl then VAT_R1   else  VAT_V1
      Coast2        = if tPrintRubl then Coast_R2 else  Coast_V2
      Coast-vat2    = if tPrintRubl then VAT_R2   else  VAT_V2
      Coast3        = if tPrintRubl then Coast_R3 else  Coast_V3
      Coast-vat3    = if tPrintRubl then VAT_R3   else  VAT_V3
      Coast4        = if tPrintRubl then Coast_R4 else  Coast_V4
      Coast-vat4    = if tPrintRubl then VAT_R4   else  VAT_V4

      .

END PROCEDURE.
PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose:  просмотр оборотов в промежутке факт-ордеров по
  ------------------------------------------------------------------------------*/
  If sliv# Then run pre-foreach.
  for each tdedt where tdedt.id  <> {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  no-lock :
      For each ub.aht-ot-tot WHERE ub.aht-ot-tot.obj-type     = x-store-type
                            AND ub.aht-ot-tot.obj-code     = x-store-code
                            AND ub.aht-ot-tot.Fact-order  >= fact-order-1
                            AND ub.aht-ot-tot.Fact-order  <= fact-order-2
                            AND ub.aht-ot-tot.sum-type     = x-type-pr
                            AND ub.aht-ot-tot.ext-doc-type = tdedt.id no-lock
                            BREAK BY ub.aht-ot-tot.ext-doc-type BY ub.aht-ot-tot.fact-order BY ub.aht-ot-tot.doc-code :

         { rep/tpree-fe.i ub.aht-ot-tot.ext-doc-type }
      END.  /*  For each ub.aht-ot-tot */
  End.     /* for each tdedt */
  If sliv#  Then run runkassa in this-procedure.
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
   run break-1str in this-procedure .
   if costsum then run break-cost in this-procedure .
 run break-2str in this-procedure .
 if dispupfact then run break-disp in this-procedure .
 run u-line in this-procedure .
 /* run erase-var1 . */
 run erase-var in this-procedure .
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
Display stream OutStream
    sym1
    sym2
    If Available ub.trn-doc then
     (if (trim(string(ub.trn-doc.ord-num)) <> "" and not(cli-name begins "ИТОГО")) then "Заказ"   else "" )
                         else ""   @ f-doc-code
    sym3
    If Available ub.trn-doc then
    (if (trim(string(ub.trn-doc.ord-num)) <> ""  and not(cli-name begins "ИТОГО") ) then String(ub.trn-doc.ord-num)  else "" )
                         else ""  @ f-cli-name
    sym4
    "По документу" @ f-qnty
    sym5
      SumWithNDS  @  F-SumWithNDS
        sym6
        SumWithoutNDS @ f-SumWithoutNDS
        sym7
        discnt-sum    @ f-discnt-sum
        sym8
         ov-sum   when ( NO-PRISE = true )     @ f-ov-sum

        sym9
        sale-sum     @ f-sale-sum
        sym10
        "итого"     @ f-VAT_PC
        sym11
        VAT-Sum      @ f-vat-sum
        sym12
        sym13
        SLT-sum      @ f-slt-sum
        sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
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
 find-str = arh-type-crsa + ',' + arh-type-sale + ',' +
       if CostSum Then              /* если есть учетная цена расшифровка */
             arh-type-cost + ','
             Else "".
 temp-find-str = find-str.
 END PROCEDURE.


procedure runkassa :
  find-str = temp-find-str.
      For each ub.aht-ot-tot WHERE  ub.aht-ot-tot.obj-type = x-store-type
          AND ub.aht-ot-tot.obj-code    = x-store-code
          AND ub.aht-ot-tot.sum-type    = x-type-pr
          AND ub.aht-ot-tot.Fact-order >  fact-order-1
          AND ub.aht-ot-tot.Fact-order <= fact-order-2
          AND (aht-ot-tot.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
          OR ub.aht-ot-tot.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) no-lock,
          First tdedt where tdedt.id  = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  no-lock
          BREAK BY tdedt.id BY ub.aht-ot-tot.fact-order BY ub.aht-ot-tot.doc-code :
         { rep/tpree-fe.i tdedt.id }
      END.  /*  For each ub.aht-ot-tot tdedt*/
END PROCEDURE.


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



/* $Workfile: r-tprees.p $ e n d */