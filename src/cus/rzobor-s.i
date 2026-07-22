/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет (совокупная)

Автор: Чернова Светлана Александровна
Дата создания: 10/11/00
Author: Svetlana Chernova
Creation date: 10/11/00


*/
/*
{2}  - yes -раздельно по объектам
       no  -слитно по объектам
*/
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xShowZero-2  as log  no-undo.
define input parameter xTog-obj   as log no-undo.
define input parameter xtog-lavel as log no-undo.
define input parameter xvar-lavel as int no-undo.
define input parameter vat-cost as logical no-undo .
define input parameter vat-crsa as logical no-undo .
define input parameter vat-sale as logical no-undo .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет (совокупная)".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ rep/r-gl.i }
{ rep/f-flav.i }
{ rep/f-fdec.i }
{ rep/procobor.i def-tt   }
{ rep/procobor.i func-vat }
{ gbl/waitfram.i }
{ rep/lkp-font.i }


define variable xserv as char init {&all} no-undo.
define variable   tPrintRubl as log no-undo.

define  stream  OutStream.
define  stream  OutStream2.
/*общий итог*/

define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   char  no-undo.
define variable    RetSortType       as   char  no-undo.
define variable    Show-Negativ      as   logical  no-undo.
define variable    Show-Negativ-2    as   logical  no-undo.
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.


define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable   Null-str#      as decimal  no-undo.
define variable   Null-str2#     as decimal  no-undo.
define variable   b1-Null-str#   as decimal  no-undo.
define variable   b1-Null-str2#  as decimal  no-undo.
define variable   b2-Null-str#   as decimal  no-undo.
define variable   b2-Null-str2#  as decimal  no-undo.

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.

define variable F-ostatok-start    as   char  no-undo.
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable ostatok-End        as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable F-prih             as   char  no-undo.
define variable F-rash             as   char  no-undo.
define variable F-kassa            as   char  no-undo.
define variable F-Inv              as   char  no-undo.
define variable F-Overturn         as   char  no-undo.
define variable prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable B1-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable B2-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable Bi-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable Bo-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.

define variable gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bo-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bi-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b1-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b2-gds-zap-other         like ub.stk-tot.sum-base no-undo.


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
define variable  temp-str as char no-undo.
define variable xShowCost as logical no-undo .
define variable xShowSale as logical no-undo .
define variable xShowcrsa as logical no-undo .


define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
/* ************** frame 1 для формы ************************************************************************************ */
DEFINE FRAME zapas
        s-bar-code column-label  "Код! ! ":C9 space(0)
        sym1 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":C36 format "X(36)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "X(3)"                  space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-type column-label "Тип!данных! ":C6 format "X(6)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)" space(0)
        F-ostatok-start     column-label "Остаток на!начало! ":C14 format "x(14)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        F-Prih       column-label "Приход! ! ":C14     Format "x(14)"     space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        F-Rash       column-label "Расход! ! ":C14  Format "x(14)"   space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        F-kassa             column-label "Касса! ! ":C14  Format "x(14)"   space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        F-Inv               column-label "Инвентаризация! ! ":C14  Format "x(14)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        F-Overturn         column-label "Переоценка! ! ":C14  Format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-other      column-label "Скидка! ! ":C13     space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        F-ostatok-end     column-label "Остаток!на конец! ":C14 format "x(14)"           space(0)
    HEADER
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

/*===================================================================================================================*/
     assign
        i=0
        xlavel = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        Show-Negativ-2  = xShowZero-2
        xShowCost     = Show-Cost
        xShowSale     = Show-Sale
        xShowcrsa     = Show-crsa
        FirstLine     = FALSE
        Line          = fill("-", {&DOS_CW_2})
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.

     run report-execute.


PROCEDURE report-execute :
define variable gj as integer no-undo init 0.

  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

  run waitfram-show( {&mywaitmess} ) .

  if ReportPageHeight = 0 then ReportPageHeight  = {&LS_PS_A4}.
  { cmp/open-out.i stream OutStream  " " ReportPageHeight}
/*----------------------------------------------------------------*/
  FIND FIRST clients where x-store-type = clients.obj-type AND
                           x-store-code = clients.obj-code no-lock no-error.
  If available clients then  ObjName = clients.obj-name.
                                else  ObjName="объект не определен".
  /* FORM with FRAME zapas . */

  { rep/r-formh.i X(194) {&DOS_cw_2}}
 &if "{2}" = "yes"  &then
       FOR each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          gj = gj + 1.
          run report-exec1.
      End.
      if gj > 1 then do:
        HIDE stream OutStream FRAME BottomFrame .
        run display-bo.
        run u-line.
      End.
&Else
     run report-exec1.
&endif

  HIDE stream OutStream FRAME BottomFrame .
  HIDE   STREAM OutStream FRAME ZAPAS .
  Output stream OutStream close.
  run waitfram-hide .
  {&CloseExcel}
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
/*----------------------------------------------------------------------------------*/


PROCEDURE foreach :
 { rep/r-mess.i i 50 }
  run clear-item.
/* на начало ------------------------------------------------------------------------------------------*/
{ rep/io.i Fact-order-1 arh-cost 0 start}

If  xshowcrsa or vat-crsa Then DO:
   { rep/io.i Fact-order-1 arh-crsa 3 start}
   End.

If xshowsale or vat-sale Then DO:
   { rep/io.i Fact-order-1 arh-crsa 6 start}
   End.

/* на конец ------------------------------------------------------------------------------------------------------*/
{ rep/io.i Fact-order-2 arh-cost 0 end}
If  xshowcrsa or vat-crsa Then DO:
   { rep/io.i Fact-order-2 arh-crsa 3 end}
   End.

If xshowsale or vat-sale Then DO:
   { rep/io.i Fact-order-2 arh-crsa 6 end}
   End.

/* обороты ------------------------------------------------------------------------------------------------------*/
/* учетная цена  по 1 товару  */
    case  gds-zap-type :
    when {&gds-office} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-COST-service}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
     End.
    when {&gds-goods} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-COST}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
      End.
      End case.

/* подсчет подитогов */
   run calc-sub-itog (0).
/* продажная цена */
  If xshowcrsa OR  xshowsale or vat-crsa or vat-sale Then DO:
    case  gds-zap-type :
    when {&gds-office} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-CRSA-service}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
     End.
    when {&gds-goods} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-CRSA}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
      End.
          End case.
    /* подсчет подитогов */
     run calc-sub-itog (3).
     End.
/* продажная цена документа */
  If xshowsale  Then DO:
    case  gds-zap-type :
    when {&gds-office} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-sale-service}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
     End.
    when {&gds-goods} THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-sale}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
      End.
          End case.
    /* подсчет подитогов */
     run calc-sub-itog (6).
     End.

END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line :
     i = i + 1.
        if NOT( NOT Show-Negativ-2 and
         ( prih         [1]   = 0 AND
          rash          [1]   = 0 AND
          kassa         [1]   = 0 AND
          Inv           [1]   = 0 AND
          Overturn      [1]   = 0 AND
          Overturn      [5]   = 0 AND
          Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              prih          [1]   = 0 AND
              rash          [1]   = 0 AND
              kassa         [1]   = 0 AND
              Inv           [1]   = 0 AND
              Overturn      [1]   = 0 AND
              Overturn      [5]   = 0 AND
              ostatok-start [1]   = 0 AND
              ostatok-End   [1]   = 0   )) then DO:

        IF NOT Sums-Only then DO:
            if fr0 = true then do:
              PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
              {&PutExcel} String(tmp#stroka0) skip.
              fr0 = false .
            end.

            if fr = true then dO:
              PUT stream OutStream space(10) temp-str format "X(100)" SKIP.
              {&PutExcel} {&tabulation} String(temp-str) skip.
              fr = false .
            end.

           run display-str1 in this-procedure.

          End.
        End.
     END.
  END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/


PROCEDURE print-header :
if NOT FirstLine Then DO:
   run display-title.
   FORM {&WFz} .  {&FRAME-d} .
End.

 FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          {&PUT-u1}     "ПО ОБЪЕКТУ : " + CAPS(clients.obj-name)  AT 30 format "X(170)" SKIP.
          {&PutExcel}   "ПО ОБЪЕКТУ : " + CAPS(clients.obj-name) format "X(170)" SKIP.
      End.
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.

   END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Print-Footer :
/*------------------------------------------------------------------------------
  Purpose: Печать итогов отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
     /*последняя строка*/
      If RetClassify = "no-classify":U  then run u-line.
/*-----КОЛИЧЕСТВО----------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       run u-line.
       END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
UNDERLINE stream OutStream  {&ALL-Sym}
        s-bar-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-Overturn
        F-ostatok-end
        gds-zap-other
        {&wFz} .
        {&FRAME-d}.
        END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream  {&ALL-Sym}
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-Overturn
        F-ostatok-end
        gds-zap-other
        {&wFz} .
        {&FRAME-d}.

        END PROCEDURE.
{ rep/obr-runn.i {1} {2} }
PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти  на начало и конец  FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
/*----------------------------------------------------------------------------------------------------------------*/
/*номер последнего Fact-ordera и остатки на конец интервала  */
/* номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
/*эти не нужны*/
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.

END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-str1  :
           run di-qnty ("кол-во", 1, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if xshowcost    then do: run di ( "учет.", 2,"","","","",""). end.
         if xshowcrsa    then do: run di ( "прод.", 5,"","","","","" ).  end.
         if xshowsale    then do: run di ( "док." , 8,"","","","","" ).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","" ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","" ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","" ).  end.

end procedure.
procedure display-bi  :
           run di-qnty("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bi":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bi":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bi":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bi":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bi":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bi":u ).  end.

END PROCEDURE.
PROCEDURE display-Bo  :
           run di-qnty("кол-во",1,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bo":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bo":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bo":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bo":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bo":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bo":u ).  end.

end procedure.

PROCEDURE display-B1  :
      if NOT( NOT Show-Negativ-2 and
         ( b1-prih         [1]   = 0 AND
           b1-rash          [1]   = 0 AND
           b1-kassa         [1]   = 0 AND
           b1-Inv           [1]   = 0 AND
           b1-Overturn      [1]   = 0 AND
           b1-Overturn      [5]   = 0 AND
           b1-Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              b1-prih          [1]   = 0 AND
              b1-rash          [1]   = 0 AND
              b1-kassa         [1]   = 0 AND
              b1-Inv           [1]   = 0 AND
              b1-Overturn      [1]   = 0 AND
              b1-Overturn      [5]   = 0 AND
              b1-ostatok-start [1]   = 0 AND
              b1-ostatok-End   [1]   = 0   )) then DO:

              /*шапка для верхней группы */
              if Sums-Only THEN do:
                  if fr0 = true then do:
                      PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
                      {&PutExcel} String(tmp#stroka0) skip.
                      fr0 = false .
                    end.
               end.

        run di-qnty in this-procedure ("кол-во"  ,1, s-bar-code, gds-zap-artic, gds-zap-gds-name ,"","b1":u).
        if xshowcost    then do: run di in this-procedure ("учет." ,2 ,"","", "", "", "b1":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "", "b1":u).  end.
        if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "", "b1":u).  end.
        if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","b1":u ). end.
        if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","b1":u ).  end.
        if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","b1":u ).  end.
       if not sums-only then run p-line.

 End.
 end.

END PROCEDURE.

PROCEDURE display-B2  :
     if NOT( NOT Show-Negativ-2 and
         ( b2-prih         [1]   = 0 AND
           b2-rash          [1]   = 0 AND
           b2-kassa         [1]   = 0 AND
           b2-Inv           [1]   = 0 AND
           b2-Overturn      [1]   = 0 AND
           b2-Overturn      [5]   = 0 AND
           b2-Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              b2-prih          [1]   = 0 AND
              b2-rash          [1]   = 0 AND
              b2-kassa         [1]   = 0 AND
              b2-Inv           [1]   = 0 AND
              b2-Overturn      [1]   = 0 AND
              b2-Overturn      [5]   = 0 AND
              b2-ostatok-start [1]   = 0 AND
              b2-ostatok-End   [1]   = 0   )) then DO:

        run di-qnty( "кол-во", 1 ,s-bar-code,gds-zap-artic, gds-zap-gds-name,"", "b2":u).
        if xshowcost    then do: run di ("учет.", 2, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di ("прод.", 5 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di ("док.", 8 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","b2":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","b2":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","b2":u ).  end.

 End.
end.
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------*/
PROCEDURE Clear-B1  :
 b1-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    b1-Prih                                            [kk]    = 0
    b1-Rash                                            [kk]    = 0
    b1-KAssa                                           [kk]    = 0
    b1-Inv                                             [kk]    = 0
    b1-Overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0   .

   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
 b2-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    b2-Prih                                            [kk]    = 0
    b2-Rash                                            [kk]    = 0
    b2-KAssa                                           [kk]    = 0
    b2-Inv                                             [kk]    = 0
    b2-Overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0   .
   End.

END PROCEDURE.
PROCEDURE Clear-Bi  :
 bi-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    bi-Prih                                            [kk]    = 0
    bi-Rash                                            [kk]    = 0
    bi-KAssa                                           [kk]    = 0
    bi-Inv                                             [kk]    = 0
    bi-Overturn                                        [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0   .
   End.

END PROCEDURE.

PROCEDURE Display-title :
define variable v-nn as integer   no-undo .
   {&PUT-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     v-nn = NUM-ENTRIES(str2,chr(10)) .
     Repeat i = 1 to v-nn:
      {&PUT-u1}  Entry(i,str2,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

       {&PUT-u1}  Trim(str3)  AT 35 format "X(75)" SKIP.
     v-nn = NUM-ENTRIES(str4,chr(10)).
     Repeat i = 1 to v-nn :
      {&PUT-u1}  Entry(i,str4,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

     v-nn = NUM-ENTRIES(ReportHeader,chr(10)) .
     Repeat i = 1 to v-nn :
      {&PUT-u1}  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
    run rep/extitle.p (1) .
END PROCEDURE.

PROCEDURE ob-line  :
define input  parameter x-store-code   like ub.clients.obj-code     no-undo.
define input  parameter x-store-type   like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic        like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code    like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type    like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj           as log no-undo.

define variable  tt#          as   int                 no-undo.


 if (x-sum-type = {&arh-cost}  or x-sum-type = {&arh-cost-service}) then tt# = 0.
 if (x-sum-type = {&arh-crsa}  or x-sum-type = {&arh-crsa-service}) then tt# = 3.
 if (x-sum-type = {&arh-sale}  or x-sum-type = {&arh-sale-service}) then tt# = 6.

&if "{2}" = "yes"  &then
     FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = x-store-code
                  AND   ub.ot-line.obj-type     = x-store-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                    no-lock :
&else
  For EAch obj-list  no-lock :
     FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = obj-list.obj-code
                  AND   ub.ot-line.obj-type     = obj-list.obj-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                    no-lock :
&endif
    CASE ub.ot-line.ext-doc-type:
    /*разбивка по типам документов */
    /* приход */
              WHEN        {&TDEDT_Pri_Vnesh}  OR
              WHEN        {&TDEDT_Vozvrat_Vnesh}  OR
              WHEN        {&TDEDT_Pri_Perem}    OR
              WHEN        {&TDEDT_Vozvrat_Perem} OR
              WHEN        {&TDEDT_Pri_Prvo  }     THEN
              DO:
              ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  ub.ot-line.fact-qnty
                     prih[2 + tt#]   = prih[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                     prih[3 + tt#]   = prih[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
    /* расход */
              WHEN       {&TDEDT_Ras_Vnesh}      OR
              WHEN       {&TDEDT_RAS_Vnesh_VP}    OR
              WHEN       {&TDEDT_Ras_Perem}     OR
              WHEN       {&TDEDT_Ras_Prvo}       OR
              WHEN       {&TDEDT_Spi_Prvo}       OR
              WHEN       {&TDEDT_Spi_Vnesh}     THEN
              DO:
              ASSIGN  rash[1 + tt#]   = rash[1 + tt#]   +  ub.ot-line.fact-qnty
                      rash[2 + tt#]   = rash[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                      rash[3 + tt#]   = rash[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
    /* касса */
              WHEN       {&TDEDT_Ras_Vnesh_Kass}  OR
              WHEN       {&TDEDT_Vozvrat_Vnesh_Kass} THEN
              DO:
              ASSIGN kassa[1 + tt#]   = kassa[1 + tt#]   +  ub.ot-line.fact-qnty
                     kassa[2 + tt#]   = kassa[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                     kassa[3 + tt#]   = kassa[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.

  /* инвентаризация */
          WHEN  {&TDEDT_Inv} or when {&TDEDT_Peresort}     THEN
              DO:
              ASSIGN INV[1 + tt#]   = INV[1 + tt#]   +  ub.ot-line.fact-qnty
                    inv[2 + tt#]   = inv[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                    Inv[3 + tt#]   = Inv[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.vat-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
    /* переоценка */
          WHEN       {&TDEDT_Overturn} THEN
              DO:
              ASSIGN Overturn[1 + tt#]   = Overturn[1 + tt#]   +  ub.ot-line.fact-qnty
                    Overturn[2 + tt#]   = Overturn[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                    Overturn[3 + tt#]   = Overturn[3 + tt#]   +  if tPrintRubl then ub.ot-line.vat-rubl Else  ub.ot-line.vat-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
      End CASE.

   &if "{2}" = "no"  &then  End. &endif
  END.

  if tt# = 6 then DO:
           ASSIGN Overturn[1 + tt#]   = (Ostatok-end[1 + tt#]  - Ostatok-start[1 + tt#] )  -  (INV[1 + tt#] + prih[1 + tt#]   +  kassa[1 + tt#]  +  rash[1 + tt#]  )
                  Overturn[2 + tt#]   = (Ostatok-end[2 + tt#]  - Ostatok-start[2 + tt#] )  -  (inv[2 + tt#] + prih[2 + tt#]   +  kassa[2 + tt#]  +  rash[2 + tt#]  )
                  Overturn[3 + tt#]   = (Ostatok-end[3 + tt#]  - Ostatok-start[3 + tt#] )  -  (Inv[3 + tt#] + prih[3 + tt#]   +  kassa[3 + tt#]  +  rash[3 + tt#]  )  .
  End.
END PROCEDURE.
 { rep/ost-line.i  {2} {2}}
 { rep/ostatok.i }
/*----------------------------------------------------------------*/
PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

  run waitfram-show(clients.obj-name) .
  run calcitog.

  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   case retclassify :
     &if {1} = 1 &then when "no-classify":u     then run run1. &endif
     &if {1} = 2 &then  when "grp-goods":u      then run run2. &endif
     &if {1} = 3 &then  when "prod":u           then run run3. &endif
     &if {1} = 4 &then  when "prod/grp-goods":u then run run4. &endif
     &if {1} = 5 &then  when "grp-goods/prod":u then run run5. &endif
     &if {1} = 7 &then  when "vat-ps":u         then run run7. &endif
     otherwise do:
       message "Ошибка вызова!"  view-as alert-box error .
     end.
   end case.
  run print-footer.
  END PROCEDURE.

/*-----------------------------------------------------------------------------------------*/
PROCEDURE Calc-Sub-itog :     /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.

if tt = 6  then Assign
  B1-gds-zap-other = B1-gds-zap-other +  gds-zap-other
  B2-gds-zap-other = B2-gds-zap-other +  gds-zap-other
  Bi-gds-zap-other = Bi-gds-zap-other +  gds-zap-other
  Bo-gds-zap-other = Bo-gds-zap-other +  gds-zap-other
  .


repeat b = 1 to 3:
  Assign
  B1-Prih[b + TT]    = B1-Prih[b + TT]    +  Prih[b + TT]
  B2-Prih[b + TT]    = B2-Prih[b + TT]    +  Prih[b + TT]
  Bi-Prih[b + TT]    = Bi-Prih[b + TT]    +  Prih[b + TT]
  Bo-Prih[b + TT]    = Bo-Prih[b + TT]    +  Prih[b + TT]
  Bo-ostatok-start[b + TT]    = Bo-ostatok-start[b + TT]    +  ostatok-start[b + TT]
  Bo-ostatok-end[b + TT]      = Bo-ostatok-end[b + TT]      +  ostatok-end[b + TT]

  B1-RAsh[b + TT]    = B1-RAsh[b + TT]    +  RAsh[b + TT]
  B2-RAsh[b + TT]    = B2-RAsh[b + TT]    +  RAsh[b + TT]
  Bi-RAsh[b + TT]    = Bi-RAsh[b + TT]    +  RAsh[b + TT]
  Bo-RAsh[b + TT]    = Bo-RAsh[b + TT]    +  RAsh[b + TT]

  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT]
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT]
  Bi-Kassa[b + TT]    = Bi-Kassa[b + TT]    +  Kassa[b + TT]
  Bo-Kassa[b + TT]    = Bo-Kassa[b + TT]    +  Kassa[b + TT]

  B1-Inv[b + TT]    = B1-Inv[b + TT]    +  Inv[b + TT]
  B2-Inv[b + TT]    = B2-Inv[b + TT]    +  Inv[b + TT]
  Bi-Inv[b + TT]    = Bi-Inv[b + TT]    +  Inv[b + TT]
  Bo-Inv[b + TT]    = Bo-Inv[b + TT]    +  Inv[b + TT]


  B1-Overturn[b + TT]    = B1-Overturn[b + TT]    +  Overturn[b + TT]
  B2-Overturn[b + TT]    = B2-Overturn[b + TT]    +  Overturn[b + TT]
  Bi-Overturn[b + TT]    = Bi-Overturn[b + TT]    +  Overturn[b + TT]
  Bo-Overturn[b + TT]    = Bo-Overturn[b + TT]    +  Overturn[b + TT] .
End.
END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Clear-item :
define variable kk as int no-undo.
 gds-zap-other = 0 .
 REPEAT kk = 1 to 9 :
 Assign
    prih            [kk]    = 0
    rash            [kk]    = 0
    kassa           [kk]    = 0
    Inv             [kk]    = 0
    Overturn        [kk]    = 0
    ostatok-end     [kk]    = 0
    ostatok-start   [kk]    = 0 .
       End.
 END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
   define input parameter  par-3 as char no-undo.
   define input parameter  par-4 as char no-undo.
     if par-4 = "goods":U  Then DO:
        assign
            gds-zap-unit-base  = Goods.unit-base
            gds-zap-prt-root   = Goods.prt-root
            gds-zap-prod-type  = Goods.prod-type
            gds-zap-prod-code  = Goods.prod-code
            gds-zap-artic      = Goods.artic
            gds-zap-grp-name   = Goods.grp-name
            gds-zap-b-code     = Goods.gds-code
            gds-zap-type       = Goods.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = Goods.engl-name.
        else
            assign gds-zap-gds-name = Goods.gds-name.
     End.

     if par-4 = "gds-list":U  Then DO:
        assign
            gds-zap-unit-base  = gds-list.unit-base
            gds-zap-prt-root   = gds-list.prt-root
            gds-zap-prod-type  = gds-list.prod-type
            gds-zap-prod-code  = gds-list.prod-code
            gds-zap-artic      = gds-list.artic
            gds-zap-grp-name   = gds-list.grp-name
            gds-zap-b-code     = gds-list.gds-code
            gds-zap-type       = gds-list.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = gds-list.engl-name.
        else
            assign gds-zap-gds-name = gds-list.gds-name.
     End.
    run foreach.
    { rep/r-obreak.i }
    run display-line.
 END PROCEDURE.


PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then DO:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< b1- }
               {&FRAME-d}.
                End.
   WHEN "B2":U  Then  DO:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< b2-}
               {&FRAME-d}.
              End.
   WHEN "BI":U Then  DO:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< bi-}
               {&FRAME-d}.
              End.
   WHEN "BO":U Then  DO:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< bo-}
               {&FRAME-d}.
              End.

   WHEN ""  Then  DO:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< }
               {&FRAME-d}.
              End.
   End case.

 END PROCEDURE.
PROCEDURE Di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then DO :
              { rep/di-ob-s.i ->>>>>>>>>>9.<<< b1-}
              { rep/ex-ob-s.i ->>>>>>>>>>9.<<< b1-}
                End.
   WHEN "B2":U  Then DO :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< b2-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< b2-}
             End.
   WHEN "BI":U Then  DO :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< bi-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< bi-}
             End.
   WHEN "BO":U Then  DO :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< bo-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< bo-}
             End.

   WHEN ""  Then     DO :
              { rep/di-ob-s.i ->>>>>>>>>>9.<<< }
              { rep/ex-ob-s.i ->>>>>>>>>>9.<<< }
              End.
   End case.
               {&FRAME-d}.
 END PROCEDURE.