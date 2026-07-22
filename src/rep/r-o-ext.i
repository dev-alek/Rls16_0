/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет

Автор: Чернова Светлана Александровна
Дата создания: 14/11/00
Author: Svetlana Chernova
Creation date: 14/11/00

*/

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xCOMBO-node as char no-undo.
define input parameter xTog-obj    as log no-undo.
define input parameter  xtog-lavel as log no-undo.
define input parameter  xvar-lavel as int no-undo. .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет по 1 типу документа".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/tax-name.i }
{ gbl/cur-time.i }
{ rep/procobor.i func-vat }
{ rep/lkp-font.i }

define variable rdtaxname as character no-undo.


define variable  tPrintRubl as log no-undo.

define variable  KOLSTR as integer no-undo .

define  stream  OutStream.
define  stream  OutStream2.
/*общий итог*/

define variable ObjName       as   char no-undo.
define variable Select-Good   as   integer no-undo.
define variable ChosedType    as   integer no-undo.
define variable PayType       as   integer no-undo.
define variable RetClassify   as   char  no-undo.
define variable RetSortType   as   char  no-undo.
define variable Show-Negativ  as   logical  no-undo.
define variable Sums-Only     as   logical  no-undo.
define variable ValType       as   integer no-undo.
define variable Line          as   char        no-undo.
define variable FirstLine     as   logical     no-undo.

define variable rdtaxcdvalue  as character initial ? no-undo.
define variable rdtaxcdtype   as character initial ? no-undo.
define buffer   rt_tax        for ub.tax.

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

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable type-Sum              as char no-undo.

define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.

 define variable  F-qnty          as   char   no-undo.
 define variable  F-Summ          as   char   no-undo.
 define variable  F-Vat           as   char   no-undo.
 define variable  F-eff           as   char   no-undo.
 define variable  F-excise        as   char   no-undo.
 define variable  F-road-tax      as   char   no-undo.
 define variable  F-transport     as   char   no-undo.
 define variable  F-Other         as   char   no-undo.

 define variable  qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  Summ          as   decimal EXTENT 3 Format "->>>>>>>>>>9.99" no-undo.
 define variable  Vat           as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  eff           as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  excise        as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  road-tax      as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  transport     as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  Other         as   decimal EXTENT 3 Format "->>>>>>>>>>9.<<" no-undo.

 define variable  b1-qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  b1-Summ          as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-Vat           as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-eff           as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-excise        as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-road-tax      as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-transport     as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-Other         as   decimal EXTENT 3  Format "->>>>>>>>>9.<<" no-undo.
 define variable  b2-qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  b2-Summ          as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-Vat           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-eff           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-excise        as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-road-tax      as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-transport     as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-Other         as   decimal  EXTENT 3 Format "->>>>>>>>>9.<<" no-undo.
 define variable  bi-qnty          as   decimal  EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  bi-Summ          as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-Vat           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-eff           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-excise        as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-road-tax      as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-transport     as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-Other         as   decimal  EXTENT 3 Format "->>>>>>>>>9.<<" no-undo.



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
define variable  slt_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.


define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.

define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
{ rep/repfrm.i def }
{ rep/repfrm.i on 50 }
/* ************** frame 1 для формы ************************************************************************************ */
DEFINE FRAME zapas
        gds-zap-b-code column-label  "Код! ":C10 format ">>>>>>>>>>" space(0)
        sym1 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ":C33 format "X(33)" space(0)
        sym3 column-label ":!:" format "x(1)"                                 space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                 space(0)
        sym4 column-label ":!:" format "x(1)"                                   space(0)
        type-Sum column-label  "Тип!цен":C4 format "X(4)" space(0)
        sym5 column-label ":!:" format "x(1)" space(0)
        F-qnty   column-label "Количество! ":C15     Format "x(15)"     space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Summ    column-label "Сумма!  ":C15     Format "x(15)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Vat   column-label "НДС! ":C15     Format "x(15)"     space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-excise             column-label "Акциз!  ":C15  Format "x(15)"   space(0)
        sym9 column-label ":!:" format "x(1)" space(0)
        F-road-tax               column-label "Дорожный налог!  ":C15  Format "x(15)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-transport           column-label "Транспортный!налог":C15  Format "x(15)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
        F-Other         column-label "Скидка! ":C12  Format "x(12)"   space(0)
        sym12 column-label ":!:" format "x(1)" space(0)
        F-eff      column-label "Эффективность!% ":C15  Format "x(15)"   space(0)

    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(198)" AT 1
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
        FirstLine     = FALSE.
        Line          = fill("-", {&DOS_CW_2}).

        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.

        run tax-name (input {&road-tax}, output rdtaxname ).
        assign F-road-tax :label = rdtaxname .
        if not ( show-sale and show-cost ) then  do:
             F-eff :label = "" .
             F-eff :hidden = true  .
            end .
        Run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable str  as char format "X(60)"  no-undo.
define variable str2 as char  no-undo.
STR ="".
define variable i#i as int no-undo.

  REPEAT i#i =1 to lavel#:
      If i#i =1 then STR   = entry(1,grp-name, {&delim-grp}) .
      Else DO:
          STR2 =   entry(i#i,grp-name, {&delim-grp}) no-error.
          IF NOT ERROR-STATUS:ERROR  and str2 <> "":U then  STR = STR + {&delim-grp} +  entry(i#i,grp-name, {&delim-grp}) .
          End.
  End.

    RETURN (str + {&delim-grp}).
END FUNCTION.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
/*------------------------------------------------------------------------------
  Purpose: Сбор и выполнение отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

  { cmp/open-out.i stream OutStream  " " ReportPageHeight}
  /*--------------------------------------------------------------------------*/
   if xTog-obj /* раздельно по объектам */ Then DO:
            FOR each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                Run report-exec1.
            End.
                                               End.
  Else Run report-exec1.

  HIDE   STREAM OutStream FRAME ZAPAS .
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
/*----------------------------------------------------------------------------------*/

PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
  FORM with FRAME zapas .
  Line = fill("-", 198).
  { rep/r-formh.i X(198) {&DOS_cw_2}}
  run calcitog in this-procedure .
  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   case RetClassify :
    &if {1} = 123 or {1} = 1 &then when "no-classify":U    then  run run1 in this-procedure . &endif
    &if {1} = 123 or {1} = 2 &then when "grp-goods":U      then  run run2 in this-procedure . &endif
    &if {1} = 123 or {1} = 3 &then when "prod":U           then  run run3 in this-procedure . &endif
    &if {1} = 457 or {1} = 4 &then when "prod/grp-goods":U then  run run4 in this-procedure . &endif
    &if {1} = 457 or {1} = 5 &then when "grp-goods/prod":U then  run run5 in this-procedure . &endif
    &if {1} = 457 or {1} = 7 &then when "vat-ps":U         then  run run7 in this-procedure . &endif
    otherwise do:
      message "Ошибка вызова!" view-as alert-box error .
    end.
   end case.
  hide stream outstream frame bottomframe .
  run print-footer.
  end procedure.
/*----------------------------------------------------------------*/

PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose: Поиск по итогам по строкам документов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 { rep/repfrm.i disp i reportname objname }
/* обороты ------------------------------------------------------------------------------------------------------*/

 If Show-cost /* учетные цены */ then DO:
   RUN Clear-item(1).
   if gds-zap-type = {&gds-goods} THEN  { rep/r-ob-ln.i {&arh-cost} xCOMBO-node}
   if gds-zap-type = {&gds-office} THEN  { rep/r-ob-ln.i {&arh-cost-service} xCOMBO-node}
   Run CAlc-Sub-itog (1).
   End.
 If Show-crsa  then DO:
   RUN Clear-item(2).
   if gds-zap-type = {&gds-goods} THEN  { rep/r-ob-ln.i {&arh-crsa} xCOMBO-node}
   if gds-zap-type = {&gds-office} THEN  { rep/r-ob-ln.i {&arh-crsa-service} xCOMBO-node}
   Run CAlc-Sub-itog (2).
   End.

  RUN Clear-item(3).
   if gds-zap-type = {&gds-goods} THEN  { rep/r-ob-ln.i {&arh-sale} xCOMBO-node}
   if gds-zap-type = {&gds-office} THEN  { rep/r-ob-ln.i {&arh-sale-service} xCOMBO-node}
   Run CAlc-Sub-itog (3).
END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line :
/*------------------------------------------------------------------------------
  Purpose: Display  for frame  & Accumulate
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    i = i + 1.
    IF  NOT (NOT Show-Negativ  AND
      ( qnty     [1]    = 0 and  qnty     [2]    = 0 and  qnty     [3]    = 0 and
        Summ     [1]    = 0 and  Summ     [2]    = 0 and  Summ     [3]    = 0 and
        Vat      [1]    = 0 and  Vat      [2]    = 0 and  Vat      [3]    = 0 and
        excise   [1]    = 0 and  excise   [2]    = 0 and  excise   [3]    = 0 and
        road-tax [1]    = 0 and  road-tax [2]    = 0 and  road-tax [3]    = 0 and
        transport[1]    = 0 and  transport[2]    = 0 and  transport[3]    = 0 and
        Other    [1]    = 0 and  Other    [2]    = 0 and  Other    [3]    = 0 )) Then dO:
        IF NOT Sums-Only then   do:
                if fr0 = true then do:
                    PUT stream  OutStream
                        tmp#stroka0
                        format "X(100)" SKIP.

                    fr0 = false .
                end.
              if fr = true then do:
                PUT stream  OutStream   space(10)
                        (if xtog-lavel = false then tmp#stroka
                                            else  str )
                    format "X(100)" SKIP.
                fr = false .
              end.
            Run Display-str1.
        end.
     END.
  END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE print-header :
/*------------------------------------------------------------------------------
  Purpose: Печать шапки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if NOT FirstLine Then  Run Display-Title.
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> {&obj-currency}   Then  DO:
          {&PUT-u1}  "ПО ОБЪЕКТУ : " + CAPS(ObjName)  AT 30 format "X(170)" SKIP.

          End.

     FORM {&WFz} .  {&FRAME-d} .
      RUN clear--B1 (1) . RUN clear--B1 (2) . RUN clear--B1 (3) .
      RUN clear--B2 (1) .  RUN clear--B2 (2).  RUN clear--B2 (3).
      RUN clear--Bi (1) . RUN clear--Bi (2) . RUN clear--Bi (3) .
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
      If RetClassify = "no-classify":U  then Run U-line.
/*-----КОЛИЧЕСТВО----------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       Run display-BI.
       Run U-line.
       END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
UNDERLINE stream OutStream  {&ALL-Sym}
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        F-qnty
        F-Summ
        F-Vat
        F-eff
        F-excise
        F-road-tax
        F-transport
        F-Other
        type-Sum
        {&wFz} .
        {&FRAME-d}.
        END PROCEDURE.
/*-------------------------------*/
PROCEDURE P-LINE :
UNDERLINE stream OutStream
        sym3
        gds-zap-gds-name
        sym4
        gds-zap-unit-base
        sym5
        {&wFz}.
        {&FRAME-d} .
        END PROCEDURE.
/*-------------------------------*/
{ rep/obr-runn.i {1} {2}}
/*----------------------------------------------------------------------------------------------------------------*/
PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти  на начало и конец  FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
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
/*------------------------------------------------------------------------------*/
PROCEDURE display-str1  :
define variable jjj as integer no-undo init 0.
if show-cost and show-sale then
   assign
      eff[1] = Summ[3]  - Summ[1]
      eff[3] = if Summ[1] <> 0 then ((Summ[3]  - Summ[1]) * 100 / Summ[1] )  else 0
    .
           if show-cost then DO:  Run di (1,"учет", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").  jjj = jjj + 1. End.
           if show-crsa then DO:
             if jjj = 0
                then   Run di (2,"прод", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
                Else   Run di (2,"прод", 1, "","","","","").
               jjj = jjj + 1. End.
           if show-sale then DO:  if jjj = 0
              then Run di (3,"док.", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
              Else Run di (3,"док.", 1, "","","","","").
              jjj = jjj + 1. End.
END PROCEDURE.

PROCEDURE display-Bi  :
if show-cost and show-sale then
   assign
      bi-eff[1] = bi-Summ [3]  - bi-Summ  [1]
      bi-eff[3] = if bi-Summ  [1] <> 0 then ((bi-Summ [3]  - bi-Summ  [1]) * 100 / bi-Summ  [1] )
                                else 0
    .

           if show-cost then run di(1,"учет",1,  "", gds-zap-artic ,"" ,"", "BI":U).
           if show-crsa then run di(2,"прод",1,  "", gds-zap-artic ,"" ,"", "BI":U).
           if show-sale then run di(3,"док.",1,  "", gds-zap-artic ,"" ,"", "BI":U).
END PROCEDURE.


PROCEDURE display-B1  :
IF  NOT (NOT Show-Negativ  AND
 (
b1-qnty     [1]    = 0 and  b1-qnty     [2]    = 0 and b1-qnty     [3]    = 0  and
b1-Summ     [1]    = 0 and  b1-Summ     [2]    = 0 and  b1-Summ     [3]    = 0 and
b1-Vat      [1]    = 0 and  b1-Vat      [2]    = 0 and  b1-Vat      [3]    = 0 and
b1-excise   [1]    = 0 and  b1-excise   [2]    = 0 and  b1-excise   [3]    = 0 and
b1-road-tax [1]    = 0 and  b1-road-tax [2]    = 0 and  b1-road-tax [3]    = 0 and
b1-transport[1]    = 0 and  b1-transport[2]    = 0 and  b1-transport[3]    = 0 and
b1-Other    [1]    = 0 and  b1-Other    [2]    = 0 and  b1-Other    [3]    = 0 )) Then DO:
    /*шапка для верхней группы */
  if Sums-Only THEN do:
      if fr0 = true then do:
          PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
          {&PutExcel} String(tmp#stroka0) skip.
          fr0 = false .

        end.
    end.
    assign
     gds-zap-artic = "Итого"
     gds-zap-gds-name = temp-str
    .

        if show-cost and show-sale then
          assign
              b1-eff[1] = b1-Summ [3]  - b1-Summ  [1]
              b1-eff[3] = if b1-Summ  [1] <> 0 then ((b1-Summ [3]  - b1-Summ  [1]) * 100 / b1-Summ  [1] )
                                        else 0
            .


         if show-cost then  Run di(1,"учет"  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
         if show-crsa then  Run di(2,"прод"  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
         if show-sale then  Run di(3,"док."  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
  Run u-line.
  End.

END PROCEDURE.
PROCEDURE display-B2  :
IF  NOT (NOT Show-Negativ  AND
  ( b2-qnty     [1]    = 0 and  b2-qnty     [2]    = 0 and  b2-qnty     [3]    = 0 and
    b2-Summ     [1]    = 0 and  b2-Summ     [2]    = 0 and  b2-Summ     [3]    = 0 and
    b2-Vat      [1]    = 0 and  b2-Vat      [2]    = 0 and  b2-Vat      [3]    = 0 and
    b2-excise   [1]    = 0 and  b2-excise   [2]    = 0 and  b2-excise   [3]    = 0 and
    b2-road-tax [1]    = 0 and  b2-road-tax [2]    = 0 and  b2-road-tax [3]    = 0 and
    b2-transport[1]    = 0 and  b2-transport[2]    = 0 and  b2-transport[3]    = 0 and
    b2-Other    [1]    = 0 and  b2-Other    [2]    = 0 and  b2-Other    [3]    = 0 ) )Then dO:
   /*
    message 1 gds-zap-artic skip
    2 tmp#stroka0 skip
    3 tmp#stroka skip
    4 temp-str skip

    .
   */
    assign
     gds-zap-artic = ""
     gds-zap-gds-name = tmp#stroka0
    .
        if show-cost and show-sale then
        assign
            b2-eff[1] = b2-Summ [3]  - b2-Summ  [1]
            b2-eff[3] = if b2-Summ  [1] <> 0 then ((b2-Summ [3]  - b2-Summ  [1]) * 100 / b2-Summ  [1] )
                                      else 0
          .



       if show-cost then  Run di (1, "учет", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       if show-crsa then  Run di (2, "прод", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       if show-sale then  Run di (3, "док.", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       Run u-line.
end.
END PROCEDURE.
/*------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Clear--B1  :
define input parameter tt#          as   int                 no-undo.
 Assign
    b1-qnty     [tt#]   = 0
    b1-Summ     [tt#]    = 0
    b1-Vat      [tt#]    = 0
    b1-eff      [tt#]    = 0
    b1-excise   [tt#]    = 0
    b1-road-tax [tt#]    = 0
    b1-transport[tt#]    = 0
    b1-Other    [tt#]    = 0  .
 END PROCEDURE.
PROCEDURE Clear--B2  :
define input parameter tt#          as   int                 no-undo.
 Assign
    b2-qnty         = 0
    b2-Summ        [tt#]  = 0
    b2-Vat         [tt#]  = 0
    b2-eff         [tt#]  = 0
    b2-excise      [tt#]  = 0
    b2-road-tax    [tt#]  = 0
    b2-transport   [tt#]  = 0
    b2-Other       [tt#]  = 0  .

END PROCEDURE.
PROCEDURE Clear--Bi  :
define input parameter tt#          as   int                 no-undo.
 Assign
    bi-qnty         = 0
    bi-Summ        [tt#]  = 0
    bi-Vat         [tt#]  = 0
    bi-eff         [tt#]  = 0
    bi-excise      [tt#]  = 0
    bi-road-tax    [tt#]  = 0
    bi-transport   [tt#]  = 0
    bi-Other       [tt#]  = 0  .
END PROCEDURE.

PROCEDURE Display-title :
   {&PUT-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(str2,chr(10)) :
      {&PUT-u1}  Entry(i,str2,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

     Repeat i = 1 to NUM-ENTRIES(str3,chr(10)) :
      {&PUT-u1}  Entry(i,str3,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
      {&PUT-u1}  Entry(i,str4,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      {&PUT-u1}  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.

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

define variable  tt#          as   int                 no-undo.

 if x-sum-type = {&arh-cost}  OR x-sum-type = {&arh-cost-service}  then tt# = 1.
  if x-sum-type = {&arh-crsa}  OR x-sum-type = {&arh-crsa-service}  then tt# = 2.
  if x-sum-type = {&arh-sale}  OR x-sum-type = {&arh-sale-service}  then tt# = 3.

  For EAch obj-list no-lock:
   if  xTog-obj THEN
       if   NOT(    x-store-type     = obj-list.obj-type
            AND    x-store-code      = obj-list.obj-code ) Then NEXT.
     IF x-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  Then DO:
       FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = obj-list.obj-code
                  AND   ub.ot-line.obj-type     = obj-list.obj-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                  And   (ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                         OR ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass})
                    no-lock :
           If tPrintRubl = yes Then
           ASSIGN qnty       [tt#]     = qnty     [tt#]        +  ub.ot-line.fact-qnty
                  Summ     [tt#]     = Summ      [tt#]      +  ub.ot-line.sum-rubl
                  Vat      [tt#]     = Vat       [tt#]      +  ub.ot-line.VAT-rubl
                  excise   [tt#]     = excise    [tt#]      +  ub.ot-line.excise-rubl
                  road-tax [tt#]     = road-tax  [tt#]      +  ub.ot-line.road-tax-rubl
                  transport[tt#]     = transport [tt#]      +  ub.ot-line.transport-rubl
                  Other    [tt#]     = Other     [tt#]      +  ub.ot-line.Other-rubl           .
           Else
           ASSIGN qnty       [tt#]     = qnty       [tt#]      +  ub.ot-line.fact-qnty
                  Summ      [tt#]     = Summ        [tt#]    +  ub.ot-line.sum-base
                  Vat       [tt#]     = Vat         [tt#]    +  ub.ot-line.VAT-base
                  excise    [tt#]     = excise      [tt#]    +  ub.ot-line.excise-base
                  road-tax  [tt#]     = road-tax    [tt#]    +  ub.ot-line.road-tax-base
                  transport [tt#]     = transport   [tt#]    +  ub.ot-line.transport-base
                  Other     [tt#]     = Other       [tt#]    +  ub.ot-line.Other-base           .

        End.

     End.
     Else DO:
       FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = obj-list.obj-code
                  AND   ub.ot-line.obj-type     = obj-list.obj-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                  And   ub.ot-line.ext-doc-type = x-ext-doc-type
                    no-lock :
           If tPrintRubl = yes Then
           ASSIGN qnty  [tt#]          = qnty    [tt#]         +  ub.ot-line.fact-qnty
                  Summ       [tt#]    = Summ       [tt#]     +  ub.ot-line.sum-rubl
                  Vat        [tt#]    = Vat        [tt#]     +  ub.ot-line.VAT-rubl
                  excise     [tt#]    = excise     [tt#]     +  ub.ot-line.excise-rubl
                  road-tax   [tt#]    = road-tax   [tt#]     +  ub.ot-line.road-tax-rubl
                  transport  [tt#]    = transport  [tt#]     +  ub.ot-line.transport-rubl
                  Other      [tt#]    = Other      [tt#]     +  ub.ot-line.Other-rubl           .
           Else
           ASSIGN qnty    [tt#]        = qnty     [tt#]        +  ub.ot-line.fact-qnty
                  Summ       [tt#]    = Summ        [tt#]    +  ub.ot-line.sum-base
                  Vat        [tt#]    = Vat         [tt#]    +  ub.ot-line.VAT-base
                  excise     [tt#]    = excise      [tt#]    +  ub.ot-line.excise-base
                  road-tax   [tt#]    = road-tax    [tt#]    +  ub.ot-line.road-tax-base
                  transport  [tt#]    = transport   [tt#]    +  ub.ot-line.transport-base
                  Other      [tt#]    = Other       [tt#]    +  ub.ot-line.Other-base           .

        End.
      End.
  END.

END PROCEDURE.

 { rep/ostatok.i }
/*-----------------------------------------------------------------------------------------*/
  PROCEDURE Calc-Sub-itog :     /* подсчет под итогов */
  define input parameter tt#          as   int                 no-undo.
  Assign
  B1-qnty     [tt#] = B1-qnty       [tt#] + qnty            [tt#]
  B1-Summ     [tt#]  = B1-Summ     [tt#]    + Summ          [tt#]
  B1-Vat      [tt#]  = B1-Vat      [tt#]    + Vat           [tt#]
  B1-excise   [tt#]  = B1-excise   [tt#]    + excise        [tt#]
  B1-road-tax [tt#]  = B1-road-tax [tt#]    + road-tax      [tt#]
  B1-transport[tt#]  = B1-transport[tt#]    + transport     [tt#]
  B1-Other    [tt#]  = B1-Other    [tt#]    + Other         [tt#]


  B2-qnty     [tt#]   = B2-qnty      [tt#]  + qnty        [tt#]
  B2-Summ     [tt#]  = B2-Summ       [tt#]  + Summ       [tt#]
  B2-Vat      [tt#]  = B2-Vat        [tt#]  + Vat        [tt#]
  B2-excise   [tt#]  = B2-excise     [tt#]  + excise     [tt#]
  B2-road-tax [tt#]  = B2-road-tax   [tt#]  + road-tax   [tt#]
  B2-transport[tt#]  = B2-transport  [tt#]  + transport  [tt#]
  B2-Other    [tt#]  = B2-Other      [tt#]  + Other      [tt#]

  Bi-qnty     [tt#]  = Bi-qnty      [tt#]   + qnty     [tt#]
  Bi-Summ     [tt#]  = Bi-Summ      [tt#]   + Summ     [tt#]
  Bi-Vat      [tt#]  = Bi-Vat       [tt#]   + Vat      [tt#]
  Bi-excise   [tt#]  = Bi-excise    [tt#]   + excise   [tt#]
  Bi-road-tax [tt#]  = Bi-road-tax  [tt#]   + road-tax [tt#]
  Bi-transport[tt#]  = Bi-transport [tt#]   + transport[tt#]
  Bi-Other    [tt#]  = Bi-Other     [tt#]   + Other    [tt#]    .

END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Clear-item :
 define input parameter tt#          as   int                 no-undo.
 Assign
  Qnty      [tt#]   = 0
  Summ      [tt#]  = 0
  Vat       [tt#]  = 0
  eff       [tt#]  = 0
  Excise    [tt#]  = 0
  Road-tax  [tt#]  = 0
  Transport [tt#]  = 0
  Other     [tt#]  = 0 .

 END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.

 define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
 define variable v-host-code     like ub.sysconf.host-code  no-undo.
 define variable v-gds-code      like ub.goods.gds-code     no-undo.

     if par-4 = "goods":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = Goods.prod-type AND
                              clients.obj-code = Goods.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = Goods.unit-base
                                    gds-zap-prt-root   = Goods.prt-root
                                    gds-zap-prod-type  = Goods.prod-type
                                    gds-zap-prod-code  = Goods.prod-code
                                    gds-zap-artic      = Goods.artic
                                    gds-zap-type       = Goods.gds-type
                                    gds-zap-grp-name   = Goods.grp-name
                                    gds-zap-b-code     = Goods.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = Goods.engl-name.
                                else
                                    assign gds-zap-gds-name = Goods.gds-name.
                            End.

     if par-4 = "gds-list":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = gds-list.prod-type AND
                              clients.obj-code = gds-list.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-type       = gds-list.gds-type
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = gds-list.engl-name.
                                else
                                    assign gds-zap-gds-name = gds-list.gds-name.
                            End.


    Run foreach .
/*-----------------------------------------------------------------------------------------*/
      If  break_group = true and par-3 <> "1"  then DO:
                     If break_group1 = True THEN  DO:
                               if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
                                  then temp-str = string("ГРУППА : " + gds-zap-grp-name ).
                                  else temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) .
                               if par-3 = "6"  then do:
                                  assign
                                      v-gds-code = ( if par-4 = "gds-list" then Gds-list.gds-code
                                                                           else goods.gds-code )
                                  .
                                  { gbl/hostcode.i x-store-type x-store-code v-host-code }
                                  { gbl/pftxvalg.i v-gds-code
                                               {&vat-tax-code}
                                               ?
                                               v-host-code
                                               x-store-type
                                               x-store-code
                                               v-vat-pc
                                  no-error }
                                  assign
                                    temp-str = string( "СТАВКА НДС : " + string(v-vat-pc) + "%" )
                                  .
                               end.

                             fr0 = true .
                             tmp#stroka0 = temp-str.
                     End.
                     IF  (par-3 = "4"  OR  par-3 = "5")  THEN DO:
                         temp-str =
                             ( if par-3 = "4"
                                  then string("ГРУППА : " + gds-zap-grp-name )
                                  else string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) ).


                              if NOT xSumsOnly THEN DO :
                              tmp#stroka = temp-str.
                              fr = true .
                              end.

                              break_group1 = false.
                     END.
                      break_group = false.
    End.
          Run display-line.
 END PROCEDURE.
PROCEDURE Di :
define input parameter tt# as int no-undo.
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then  DO:
   IF  NOT (NOT Show-Negativ  AND
     (b1-qnty  [tt#]           = 0 and
       b1-Summ     [tt#] = 0 and
       b1-Vat      [tt#] = 0 and
       b1-excise   [tt#] = 0 and
       b1-road-tax [tt#] = 0 and
       b1-transport[tt#] = 0 and
       b1-Other    [tt#] = 0 ))  THEN DO:

             DISPLAY stream  OutStream {&ALL-Sym}
                p1   @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                b1-qnty      @ F-qnty
                b1-Summ     [tt#]  @ F-Summ
                b1-Vat      [tt#]  @ F-Vat
                b1-eff      [tt#] when b1-eff[tt#] <> 0  @ F-eff
                b1-excise   [tt#]  @ F-excise
                b1-road-tax [tt#]  @ F-road-tax
                b1-transport[tt#]  @ F-transport
                b1-Other    [tt#]  @ F-Other
               {&WFz} .          {&FRAME-d}. End.
    End.
   WHEN "B2":U  Then do:
   IF  NOT (NOT Show-Negativ  AND
   (b2-qnty  [tt#]           = 0 and
       b2-Summ     [tt#] = 0 and
       b2-Vat      [tt#] = 0 and
       b2-excise   [tt#] = 0 and
       b2-road-tax [tt#] = 0 and
       b2-transport[tt#] = 0 and
       b2-Other    [tt#] = 0 ))  THEN  DO:
      DISPLAY stream  OutStream {&ALL-Sym}
                p1 @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                b2-qnty    [tt#]    @ F-qnty
                b2-Summ     [tt#]  @ F-Summ
                b2-Vat      [tt#]  @ F-Vat
                b2-eff      [tt#] when b2-eff[tt#] <> 0  @ F-eff
                b2-excise   [tt#]  @ F-excise
                b2-road-tax [tt#]  @ F-road-tax
                b2-transport[tt#]  @ F-transport
                b2-Other    [tt#]  @ F-Other
                {&WFz} .          {&FRAME-d}. End.
       End.
   WHEN "BI":U Then DO:
             DISPLAY stream  OutStream {&ALL-Sym}
                p1   @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                bi-qnty    [tt#]    @ F-qnty
                bi-Summ     [tt#]  @ F-Summ
                bi-Vat      [tt#]  @ F-Vat
                bi-eff      [tt#] when bi-eff[tt#] <> 0 @ F-eff
                bi-excise   [tt#]  @ F-excise
                bi-road-tax [tt#]  @ F-road-tax
                bi-transport[tt#]  @ F-transport
                bi-Other    [tt#]  @ F-Other
               {&WFz} .        {&FRAME-d}.
            End.
   WHEN ""  Then DO:
             DISPLAY stream  OutStream {&ALL-Sym}
                p1   @ type-Sum
                p3   @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                qnty     [tt#]  @ F-qnty
                Summ     [tt#]  @ F-Summ
                Vat      [tt#]  @ F-Vat
                eff      [tt#]  when eff[tt#] <> 0   @ F-eff
                excise   [tt#]  @ F-excise
                road-tax [tt#]  @ F-road-tax
                transport[tt#]  @ F-transport
                Other    [tt#]  @ F-Other
               {&WFz} .        {&FRAME-d}.
             End.
   End case.

 END PROCEDURE.
PROCEDURE Clear-B1  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    b1-qnty      = 0
    b1-Summ     [tt#]    = 0
    b1-Vat      [tt#]    = 0
    b1-eff      [tt#]    = 0
    b1-excise   [tt#]    = 0
    b1-road-tax [tt#]    = 0
    b1-transport[tt#]    = 0
    b1-Other    [tt#]    = 0  .
   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    b2-qnty         = 0
    b2-Summ        [tt#]  = 0
    b2-Vat         [tt#]  = 0
    b2-eff         [tt#]  = 0
    b2-excise      [tt#]  = 0
    b2-road-tax    [tt#]  = 0
    b2-transport   [tt#]  = 0
    b2-Other       [tt#]  = 0  .
    End.
END PROCEDURE.
PROCEDURE Clear-Bi  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    bi-qnty         = 0
    bi-Summ        [tt#]  = 0
    bi-Vat         [tt#]  = 0
    bi-eff         [tt#]  = 0
    bi-excise      [tt#]  = 0
    bi-road-tax    [tt#]  = 0
    bi-transport   [tt#]  = 0
    bi-Other       [tt#]  = 0  .
    End.
END PROCEDURE.

/* $Workfile$ e n d */