block-level on error undo, throw.
/*

$Revision: 228d0892697a, 495, rls $
$Author: SShalanin $
$Date: Sun Feb 28 19:23:24 2016 +0400 $
$Workfile: r-zpost.p $
$Archive: rep/r-zpost.p $

"Состояние запаса поставщикам"

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

 16.04.01

*/

define variable vss-revision    as character no-undo init "$Revision: 228d0892697a, 495, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Sun Feb 28 19:23:24 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-zpost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-zpost.p $":U .
define variable vss-description as character no-undo init "Состояние запаса поставщикам".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
define  input parameter x-store-code like ub.clients.obj-code   no-undo.
define  input parameter x-store-type like ub.clients.obj-type   no-undo.
define  input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define  input parameter x-base-code  like ub.currency.curr-code no-undo.
define  input parameter x-Cli-art      as character no-undo .
define  input parameter x-date1Rash    as date no-undo .
define  input parameter x-date2Rash    as date no-undo .
define  input parameter x-PostName     as character no-undo .
define  input parameter x-RADIO-Anal   as logical no-undo .
define  input parameter x-RADPost      as logical no-undo .
define  input parameter x-Showcliprice  as logical no-undo .
define  input parameter x-ShowParts     as logical no-undo .
define  input parameter xClassify  as char no-undo.
define  input parameter xSortType  as char no-undo.
define  input parameter xSumsOnly  as log  no-undo.
define  input parameter xShowZero  as log  no-undo.
define  input parameter xTog-obj   as log no-undo.
define  input parameter  xShowCost as log no-undo.
define  input parameter  xtype-stor as int no-undo.
define  input parameter  xtog-lavel as log no-undo.
define  input parameter  xvar-lavel as int no-undo.
define  input parameter  xtog-lavel-2 as log no-undo.
define  input parameter  xvar-lavel-2 as int no-undo.

{ rep/r-defpst.i  &df = new  &framename = 'zapas':U }
{ rep/f-fdec.i }
{ trg/factord.i }
{ rep/lkp-font.i }
define variable  zap-date   as date no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    FirstLine         as  logical  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable v-file-name as char.
/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable rid-list as character no-undo .

define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.


define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.

/*===================================================================================================================*/
   FIND First ub.clients where x-store-type = ub.clients.obj-type AND
            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
     assign
        i = 0
        zap-date      = x-Date-Alone
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        x-date-start  =  x-Date-Alone
        x-date-end    =  x-Date-Alone
        type-stor     =  xtype-stor
        xtogobj = xtog-obj
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.

 { rep/r-val.i }

xLavel = 0.
if  xtog-lavel    then  xLavel        =  xvar-lavel .
if  xtog-lavel-2  then  xLavel        =  xvar-lavel-2 .

/*run get-report-num in parParentProc(output g#report-num).*/
   os-delete value(string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".t-t")   .

Run report-execute.

/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
  Run CalcItog.
  RUN waitfram-show( {&MyWaitMess} ) .
  if ReportPageHeight = 0 then ReportPageHeight  = {&LS_PS_A4}.
  { cmp/open-out.i stream OutStream  " " ReportPageHeight}

  FORM with FRAME zapas .
  Line = fill("-", 189).
  { rep/r-formh.i X(189) {&DOS_cw_2}}
  Run Print-Header.
  run rep/extitle.p (1) .
/*      run gbl/_tmpfile.p ( "ipp", ".txt", output v-file-name) .*/
   /* проход по списку товаров 1 2 3-№ поиска */
  case RetSortType :
      when "sort-code":U then do:
        if not can-find(first g#post no-lock)
          Then   run rep/r-zps-1.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
          Else   run rep/r-zps-2.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
      end.
      when "sort-article":U then do:
        if not can-find(first g#post no-lock)
          Then   run rep/r-zps-3.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
          Else   run rep/r-zps-4.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
      end.
      when "sort-name":U then do:
        if not can-find(first g#post no-lock)
          Then   run rep/r-zps-5.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
          Else   run rep/r-zps-6.p (x-store-code,x-store-type,x-base-type ,x-base-code ).
      end.

  end case.

  HIDE stream OutStream FRAME BottomFrame .
  Run Print-footer.
  HIDE STREAM OutStream FRAME ZAPAS .
  Output stream OutStream close.
  {&CloseExcel}
  RUN waitfram-hide .
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
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num  ) 
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
      
END PROCEDURE.

PROCEDURE print-header :
   PUT stream OutStream  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
       AT 50 format "X(85)" SKIP(2)
          "С О С Т О Я Н И Е    З А П А С А    на  "
                AT 35  format "X(41)"   zap-date format "99.99.9999" SKIP(2)
            Trim(str3)  AT 35 format "X(75)" SKIP(1) .

     PUT stream OutStream str2 AT 35 format "x(200)"  SKIP.

     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
       PUT stream OutStream  Entry(i,str4,chr(10))  AT 1 format "X(170)" SKIP.
     End.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
       PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
     i=0.
      FirstLine = TRUE .
       FORM with FRAME zapas .
       DOWN stream  OutStream 1 with FRAME zapas.

   Assign
      Tot-1=0   Tot-1-1=0  Tot-2-1=0
      Tot-2=0   Tot-1-2=0  Tot-2-2=0
      Tot-3=0   Tot-1-3=0  Tot-2-3=0
      Tot-4=0   Tot-1-4=0  Tot-2-4=0
      Tot-5=0   Tot-1-5=0  Tot-2-5=0
      .
   END PROCEDURE.
PROCEDURE Print-Footer :
     /*последняя строка*/
      If RetClassify = "no-classify":U  then Run U-line.

      DISPLAY stream  OutStream
                      sym1
                    " ИТОГО" @ gds-zap-b-code
                      sym4
                      sym5
                      Tot-1  @ gds-zap-qnty
                      sym6
                      Tot-2  @ gds-zap-stoim-base
                      sym7
                      sym8
                      Tot-4  @ gds-zap-nds
                      sym9
                      Tot-5  @ gds-zap-nP
                      sym10
                      Tot-3  @ tot_tqnty
                      sym11
                      sym12
                      with FRAME zapas.

      DOWN stream  OutStream 1 with FRAME zapas.
      {&PutExcel}
          " ИТОГО" {&tabulation} {&tabulation} {&tabulation}  {&tabulation}  {&tabulation}
            excel-qnty(Tot-1)  {&tabulation} {&tabulation}
            excel-sum(Tot-2)  {&tabulation}
            excel-sum(Tot-4)  {&tabulation}
            excel-sum(Tot-5)  {&tabulation}
            excel-sum(Tot-3)  skip.

      Run U-line.
      Put stream  OutStream UNFORMATTED
        "Итого "
        Tot-1
        " единиц , "
         string(i)
          " наименований,"
         " на сумму "
        trim( string(tot-2,"->>>>>>>>>>>>9.99"))
         "(" + (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) + ")" skip.

       END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream
        sym1
        gds-zap-b-code
        sym2
        gds-zap-artic
        sym3
        gds-post-artic
        sym12
        gds-zap-gds-name
        sym4
        gds-zap-unit-base
        sym5
        gds-zap-qnty
        sym6
        gds-zap-price-base
        sym7
        gds-zap-stoim-base
        sym8
        gds-zap-Nds
        sym9
        gds-zap-NP
        sym10
        tot_tqnty
        sym11
        with FRAME zapas .
        DOWN stream  OutStream 1 with FRAME zapas.
        END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream
        sym3
        gds-post-artic
        sym12
        gds-zap-gds-name
        sym4
        gds-zap-unit-base
        sym5
        gds-zap-qnty
        sym6
        gds-zap-price-base
        sym7
        gds-zap-stoim-base
        sym8
        gds-zap-Nds
        sym9
        gds-zap-NP
        sym10
        tot_tqnty
        sym11

        with FRAME zapas .
        DOWN stream  OutStream 1 with FRAME zapas.
        END PROCEDURE.

PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти  на начало и конец  FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
    xTog-obj = false .
    run factord-end-day (input zap-date, output fact-order-2 ).
    fact-order-1 = 0 .
xTog-obj = xtogobj .
END PROCEDURE.
{ rep/ostatok.i }
/* $Workfile: r-zpost.p $ e n d */