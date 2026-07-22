/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Реестр документов

Автор: Чернова Светлана Александровна
Дата создания: 09/27/01
Author: Svetlana Chernova
Creation date: 09/27/01

*/

define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter VAT-SLT      as logical no-undo.
define input parameter VAT-SLT-s    as logical no-undo.
define input parameter CostSum      as logical no-undo.
define input parameter DispUpFact   as logical no-undo  .
define input parameter Serv     as logical no-undo.
define input parameter RetServ  as logical no-undo.
define input parameter NullPer  as logical no-undo.
define input parameter CalcRest as logical no-undo.

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
{ rep/rep-bt.i   }
{ rep/ostatok.i yes yes}
{ rep/lkp-font.i }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }

define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var as integer   no-undo .

define variable v-log as logical   no-undo .
define variable g#log as logical   no-undo .
define variable sliv# as logical init true no-undo. /*если TRUE будет сливать в кассу */

/*поля формы*/
define variable     F-fact-date      as character no-undo.
define variable     F-qnty           as character no-undo.
define variable     F-VAT_pc         as character no-undo.
define variable     F-SLT_pc         as character no-undo.
define variable     F-doc-code       as character no-undo.
define variable     F-cli-name       as character no-undo.
define variable     F-SumWithNDS     as character no-undo.
define variable     F-SumWithoutNDS  as character no-undo.
define variable     F-discnt-sum     as character no-undo.
define variable     F-ov-sum         as character no-undo.
define variable     F-sale-sum       as character no-undo.
define variable     F-VAT-Sum        as character no-undo.
define variable     F-SLT-sum        as character no-undo.
define variable v-col-1 as integer no-undo .
define variable v-col-2 as integer no-undo .
define variable v-col-3 as integer no-undo .
define variable v-col-4 as integer no-undo .
define variable ff like ub.stk-tot.Fact-order init 0 no-undo.

define variable     fact-date      as date no-undo.
define variable     doc-code       as character no-undo.
define variable     cli-name       as character no-undo.
define variable     qnty           as decimal format "->>>,>>>,>>9.999" no-undo.
define variable     SumWithNDS     as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS  as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     discnt-sum     as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     ov-sum         as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     sale-sum       as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     VAT_pc         as decimal format "->9.99"           no-undo.
define variable     VAT-Sum        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SLT_pc         as decimal format "->9.99"           no-undo.
define variable     SLT-sum        as decimal format "->>>,>>>,>>9.99"  no-undo.
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

define variable  Quantity   like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast      like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-VAT  like ub.stk-tot.vat-rubl   no-undo.

define variable  Quantity3  like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat5 like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat6 like ub.stk-tot.sum-rubl   no-undo.

define variable  Coast3     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat3 like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat4 like ub.stk-tot.sum-rubl   no-undo.

define variable  find-str       as character no-undo.
define variable  temp-find-str  as character no-undo .
define variable  tPrintRubl     as logical no-undo .
define variable  startdate      as date no-undo.
define variable  enddate        as date no-undo.

define stream  OutStream .
define stream  macr_excel .

define variable ObjName as  character no-undo.
define variable PayType as  integer   no-undo.
define variable ValType as  integer   no-undo.
define variable Line    as  character no-undo.

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
define variable iI          as integer no-undo.
define variable i           as integer no-undo .
define variable j           as integer no-undo.
define variable K           as integer no-undo.
define variable acc-i       as integer no-undo .
define variable acc-j       as integer no-undo.
define variable v-vat_pc    as character no-undo.
define variable v-vat_sum   as decimal format "->>>,>>>,>>9.99" no-undo.
define variable v-vat_sum_f as decimal format "->>>,>>>,>>>.<<" no-undo.
define variable v-slt_pc    as character no-undo.
define variable v-slt_sum   as decimal format "->>>,>>>,>>9.99" no-undo.
define variable tmpact      as decimal format "->>>>>>>>9.999" no-undo.
define variable stat     as logical no-undo .
define variable InpError as logical no-undo .
define variable rid-list as character no-undo .
define variable curr-rep as character no-undo.
define variable listtd as character no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .

define buffer b-stk-tot for stk-tot .


define work-table tmp#taxVAT NO-UNDO
   Field type Like ub.ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.ot-tot.VAT-base
   Field       sum_full  like ub.ot-tot.sum-base
   .

define work-table tmp#taxSLT NO-UNDO
   Field type Like ub.ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.ot-tot.VAT-base
   Field       sum_full  like ub.ot-tot.sum-base
   .


define work-table acc#taxVAT NO-UNDO
   Field type Like ub.ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.ot-tot.VAT-base
   Field       sum_full  like ub.ot-tot.sum-base
   .

define work-table acc#taxSLT NO-UNDO
   Field type Like ub.ot-tot.sum-type
   Field       pc   as char
   Field       sum  like ub.ot-tot.VAT-base
   Field       sum_full  like ub.ot-tot.sum-base
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

       FIND first clients where clients.obj-type = x-store-type AND
                                clients.obj-code = x-store-code no-lock no-error .
           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName = "объект не определен".
     assign
        i             = 0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        xTog-obj      = true
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   curr-rep = (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type ) .
   NO-PRISE = true .
  if var-report-r-b = "rubl"  then do:
    if  x-base-code <> 0 and valtype = 2  then no-prise = false  .
  end.
  else do:
   if  x-base-code <> 0 and valtype = 1  then no-prise = false  .
  end.

  /* создаем временный файл */
  run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
  output stream macr_excel to value(v-file-name)   .
  v-ind = 1    .
  num#str# = 0 .

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME DocsRep .
  { rep/r-formh.i x(194) {&dos_CW_2}}
   Line = fill("-", 194).
      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format( ReportNAme , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */


define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format(                                                          ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }


  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( string(
      cur-time-print()  +
      " Цены указаны в " +
      (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )  )
      , num#str#
      , num#col#
        ) .
/*Печать шапки */

   Run CalcItog in this-procedure.
   Run Print-Header in this-procedure.
   run proc-print-header-my in this-procedure .
  run foreach in this-procedure.
  HIDE stream OutStream FRAME BottomFrame .
  Run Print-footer in this-procedure.

  put stream macr_excel unformatted
      substitute('select("c&1:c&2")', 5 , 13 ) + {&new-line} .
  put stream macr_excel unformatted 'format.number("### ### ### ##0.00")' + {&new-line} .

  HIDE STREAM OutStream FRAME DocsRep .
  Output stream OutStream close.
  Output stream Macr_Excel  close .
  { rep/repfrm.i off }
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,10,12"
        ) .


  /* run paramls-show-temp-table. */
  run end-proc .
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
    ,input  session:temp-directory + {&DF_Name} + string( g#report-num )
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
         "Р Е Е С Т Р   Д О К У М Е Н Т О В  " +
         &If "{1}" = "" &Then "( Т О В А Р Н Ы Й   О Т Ч Е Т )" &else "( У С Л У Г И )" &endif
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
        { rep/r-reer.i 1 vat}
        { rep/r-reexl.i 1 vat}
        run decode-vat in this-procedure (input {&arh-vat}, input {&arh-cost} ,input fact-order-1-C , output  v-col-3) .
        if NO-PRISE THEN DO:
           { rep/r-reer2.i 3 vat}
           { rep/r-reexl2.i 3 vat}
           run decode-vat in this-procedure  (input {&arh-vat},input  {&arh-crsa},input  fact-order-1-P , output v-col-4) .
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
  { rep/r-reexl.i " " vat}
     Coast = Coast4 - Coast3 .
     Coast-vat = Coast-vat4 - Coast-vat3 .
  { rep/r-reer2.i " "  vat}
  { rep/r-reexl2.i " "  vat}
&else
     Quantity = Quantity3.
     Coast = Coast5.
     Coast-vat = Coast-vat5.
     { rep/r-reer.i " "  vat}
     { rep/r-reexl.i " "  vat}
     Coast = Coast6.
     Coast-vat = Coast-vat6.
     { rep/r-reer2.i " "  vat}
     { rep/r-reexl2.i " "  vat}

&Endif
/*Печать остатков на конец*/
if CalcRest then
    do:
        { rep/r-reer.i 2 vat}
        { rep/r-reexl.i 2 vat}
        run decode-vat in this-procedure ( input {&arh-vat},input  {&arh-cost},input  fact-order-2-C, output v-col-1) .
        if NO-PRISE THEN DO:
           { rep/r-reer2.i 4 vat}
           { rep/r-reexl2.i 4 vat}
           run decode-vat in this-procedure  (input {&arh-vat},input  {&arh-crsa},input  fact-order-2-P, output v-col-2) .
           End.
    end.
PUT STREAM OutStream " " SKIP(3)
    SPACE(20) "Заведующий __________________"   format "X(32)"
    SPACE(20) "Ст. продавец __________________" format "X(32)"
    SPACE(20) "Бухгалтер __________________"    format "X(32)"
    SKIP .
num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char(  "Заведующий"  , num#str# , num#col#   ) .
num#col# = 3.
run macr_excel_char(  "Ст. продавец"  , num#str# , num#col#   ) .
num#col# = 5.
run macr_excel_char(  "Бухгалтер"  , num#str# , num#col#   ) .
num#str# = num#str# + 1.

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
    run ostatok  in this-procedure(
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1-C ).


    run ostatok  in this-procedure(
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R3   ,
        output  Coast_V3   ,
        output  VAT_R3     ,
        output  VAT_V3     ,
        output  Fact-order-1-P ).

        Fact-order-1 = Fact-order-1-P .

    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input {&arh-cost}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  Fact-order-2-C ).

    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start , x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj      ,

        output  Quantity2  ,
        output  Coast_R4   ,
        output  Coast_V4   ,
        output  VAT_R4     ,
        output  VAT_V4     ,
        output  Fact-order-2-P ).

        Fact-order-2 = Fact-order-2-P .

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
  If sliv# Then run pre-foreach in this-procedure .
  for each tdedt where tdedt.id  <> {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  no-lock :

/*      listtd =  tdedt.id + ',' . */
      if tdedt.id = {&TDEDT_Overturn} Then find-str = {&arh-crsa{1}} + ','.  /* если переоценка */
      Else  find-str = temp-find-str.
      For each ot-tot WHERE  ot-tot.obj-type = x-store-type
                            AND ot-tot.obj-code    = x-store-code
                            AND ot-tot.Fact-order >  fact-order-1
                            AND ot-tot.Fact-order <= fact-order-2
                            AND Lookup (ot-tot.sum-type  , find-str ) <> 0
                            AND ot-tot.ext-doc-type = tdedt.id no-lock
                            BREAK BY ot-tot.ext-doc-type BY ot-tot.fact-order BY ot-tot.doc-code :

         { rep/ree-fe.i ot-tot.ext-doc-type {1}}
      END.  /*  For each ot-tot */
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
    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 3.
    run macr_excel_char( CAPS (tdedt.name)  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_cell_format (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        num#str# , /*p-row       */
        3        , /*p-col       */
        num#str# , /*p-row-2     */
        3 ) /*p-col-2     */
        .

END PROCEDURE.

PROCEDURE Break-F-1 :
 run u-line in this-procedure .
 assign
   fact-date = date('')
   doc-code  = ''
   cli-name  = "ИТОГО " +  tdedt.name .
   run break-1str in this-procedure .
   if costsum then run break-cost in this-procedure .
 run break-2str in this-procedure .
 if dispupfact then
    run break-disp in this-procedure .
 run u-line in this-procedure .
 run erase-var1 in this-procedure .
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

    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char (if fact-date = ? then "" else  string( fact-date ,  "99/99/9999") , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (doc-code , num#str# , num#col#    ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (cli-name , num#str# , num#col#    ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec  (qnty     , num#str# , num#col#    ) . assign    num#col# = num#col# + 1 .

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
    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char( if fact-date = ? then "" else  string( fact-date, "99/99/9999") , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(doc-code , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(cli-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec(qnty      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    num#col# = 9.
    run macr_excel_dec(sale-sum-ot, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 End .
END PROCEDURE.


PROCEDURE Break-2str :             /* по документу */
  define variable str-inv  as character initial "" no-undo .
  define variable str-inv1 as character initial "" no-undo .
  define buffer buf_doc-attr for doc-attr.
  str-inv1 = "".
  If Available trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-nids}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .

      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = trn-doc.doc-code
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

    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char ( ""                               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( str-inv                          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( str-inv1                         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( "По документу"                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( SumWithNDS                       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( SumWithoutNDS                    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( discnt-sum                       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( (if NO-PRISE = true then string(ov-sum)  else "" ), num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( sale-sum                         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( "итого"                          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( VAT-Sum                          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( ""                               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( SLT-sum                          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

  str-inv1 = "" .
  If Available trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = trn-doc.doc-code
          and buf_doc-attr.attr-code = {&trdcattr-ndog}
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .

      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = trn-doc.doc-code
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
    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( str-inv  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( str-inv1 , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
  end.

  if vat-slt   then run break-vat  in this-procedure ( {&arh-sale{1}}) .
  if vat-slt-s then run break-vat-sub in this-procedure  ( {&arh-sale{1}}) .

  if vat-slt   then run break-vat  in this-procedure ( {&arh-crsa{1}}) .
  if vat-slt-s then run break-vat-sub in this-procedure  ( {&arh-crsa{1}}) .

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
    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 4.
    run macr_excel_char("Учет"     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(SumWithNDS-coast          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(SumWithoutNDS-coast       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(""                        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(""                        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(""                        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char("итого"                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(VAT-Sum-coast             , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char( ""                       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(SLT-sum-coast             , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

    if vat-slt then   run break-vat  in this-procedure ( {&arh-cost{1}}) .
    if vat-slt-s then   run break-vat-sub in this-procedure  ( {&arh-cost{1}}) .
END PROCEDURE.

PROCEDURE Break-Akt :
 tmpact = ABSOLUTE (If Available  trn-doc then trn-doc.doc-qnty else 0 )
         - ABSOLUTE (If Available trn-doc then  trn-doc.fact-qnty else 0).
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

    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 3.
    run macr_excel_char("Акт несоответствия"     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(tmpact                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

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

    run new-tmp-page .
    num#str# = num#str# + 1.
    num#col# = 4.
    run macr_excel_char("Наценка"         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(SumWithNDS-disp   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char(SumWithoutNDS-disp, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

END PROCEDURE.


PROCEDURE Break-VAT :   /* расшифровка НДС и НП */
define input parameter par1 as char.

define variable x-pc_vat as integer no-undo .
define variable x-pc_slt as integer no-undo .
define variable x-vat-sum  as decimal format "->>,>>>,>>9.99" no-undo .
define variable x-vat    as decimal format "->>,>>>,>>9.99" no-undo .
define variable x-slt    as decimal format "->>,>>>,>>9.99" no-undo .

DEFINE buffer buff-ot-line-tax for ub.ot-line .

Find first tmp#taxVAt where tmp#taxVAt.type BEGINS par1 no-error .
Find first tmp#taxSLT where tmp#taxSLT.type BEGINS par1 no-error .

        Display stream OutStream
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
            sym7
            sym8
            sym9
            (if par1  begins {&arh-crsa} then 'В прод.ценах'  else '') @ f-qnty
            sym10
            "---------------" @ f-SumWithNDS
            "---------------" @ f-SumWithoutNDS
            "---------------" @ f-discnt-sum
            "---------------" @ f-ov-sum
            "---------------" @ f-sale-sum
            "------"         @ f-vat_PC
            "-"              @ sym11
            "Итоги по ставка" @ f-VAT-Sum
            "м"              @ sym12
            " налог"         @ f-SLT_PC
            "о"              @ sym13
            "в--------------" @ f-slt-sum
            "-"              @ sym14
            with FRAME DocsRep .
            DOWN stream  OutStream 1 with FRAME DocsRep.
            run new-tmp-page .
            num#str# = num#str# + 1.
            num#col# = 10.
            run macr_excel_char("Итоги по ставкам налогов"         , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

    Repeat k = 1 to  maximum(i,j) :
        If Available tmp#taxVAt then
            Assign  v-vat_pc   = tmp#taxVAt.pc
                    v-vat_sum  = tmp#taxVAt.sum
                    v-vat_sum_f  = tmp#taxVAt.sum_full
                    .
            Else
            Assign  v-vat_pc   = ''
                    v-vat_sum  = 0
                    v-vat_sum_f  = 0 .

        If available tmp#taxSLT  then
            Assign v-SLT_pc    = tmp#taxSLT.pc
                    v-SLT_sum  = tmp#taxSLT.sum.
            Else
            Assign v-SLT_pc   = ''
                   v-SLT_sum  = 0 .

        if NOT (decimal(v-SLT_pc) = 0 And decimal(v-vat_pc) = 0 ) THEN DO :
            Display stream OutStream
                sym1 sym2 sym3 sym4
                ">" @ sym5
                v-VAT_sum_f     @ f-SumWithNDS
                "<" @ sym6
                sym7
                sym8
                sym9
                sym10
                string(integer(v-VAT_pc),">9") + '%'    @ f-vat_PC
                sym11
                v-VAT_sum      @ f-VAT-Sum
                sym12
                string(integer(v-SLT_pc),">9") + '%'     @ f-SLT_PC
                sym13
                v-SLT_sum      @ f-slt-sum
                sym14
                with FRAMe DocsRep .
                DOWN stream  OutStream 1 with FRAME DocsRep.
                run new-tmp-page .
                num#str# = num#str# + 1.
                num#col# = 5.
                run macr_excel_char(v-VAT_sum_f        , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                num#col# = 10.
                run macr_excel_char(string(integer(v-VAT_pc),">9") + '%', num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char(v-VAT_sum             , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char(string(integer(v-SLT_pc),">9") + '%'    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char(v-SLT_sum    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
              End.
        find NEXT tmp#taxVAt where tmp#taxVAt.type BEGINS par1 no-error.
        find NEXT tmp#taxSLT where tmp#taxSLT.type BEGINS par1 no-error.
    End.
END PROCEDURE.


PROCEDURE Erase-var :   /* очистка вр таблиц и переменных по документу*/
  If vat-slt then DO:
    For each tmp#taxVAt : delete tmp#taxVAT . End.
    For each tmp#taxSLT : delete tmp#taxSLT . End.
    assign
      v-VAT_pc  = ''
      v-VAT_sum = 0
      v-VAT_sum_f = 0
      v-SLT_pc  = ''
      v-SLT_sum = 0
      i = 0
      J = 0
    .
    End.
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
 find-str = find-str +
       if VAT-SLT Then              /* если есть расшифровка */
                  {&arh-cost{1}} + {&arh-VAT} + ','
                + {&arh-cost{1}} + {&arh-SLT} + ','
                + {&arh-sale{1}} + {&arh-VAT} + ','
                + {&arh-sale{1}} + {&arh-SLT} + ','
                + {&arh-crsa{1}} + {&arh-VAT} + ','
                + {&arh-crsa{1}} + {&arh-SLT} + ','
                + {&arh-crsa} + ','

              Else ""   .
 temp-find-str = find-str.
END PROCEDURE.


PROCEDURE erase-var1 :
    acc-i=0.
    acc-J=0.
    For each acc#taxSLT : delete acc#taxSLT . End.
    For each acc#taxVAt : delete acc#taxVAT . End.
END PROCEDURE.
&ANALYZE-RESUME

procedure runkassa :
  find-str = temp-find-str.
      For each ot-tot WHERE  ot-tot.obj-type = x-store-type
                                      AND ot-tot.obj-code    = x-store-code
                                      AND ot-tot.Fact-order >  fact-order-1
                                      AND ot-tot.Fact-order <= fact-order-2
                                      AND Lookup (ot-tot.sum-type  , find-str ) <> 0
                                      AND (ot-tot.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                                      OR ot-tot.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) no-lock,
                      First tdedt where tdedt.id  = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}  no-lock
                                      BREAK BY tdedt.id BY ot-tot.fact-order BY ot-tot.doc-code :
         { rep/ree-fe.i tdedt.id {1}}
      END.  /*  For each ot-tot tdedt*/
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


procedure decode-vat :
define input parameter p-vv as character no-undo .
define input parameter p-arh as character no-undo .
define input parameter p-fact-order like ub.stk-tot.fact-order no-undo .
define output parameter p-calc as integer no-undo .
define variable p-i as integer no-undo .

p-calc = 0.
If vat-slt then DO:
    if p-vv = {&arh-vat} then p-i = 1.
    if p-vv = {&arh-slt} then p-i = 2.

    for each b-stk-tot no-lock
    where
    b-stk-tot.obj-code   = x-store-code and
    b-stk-tot.obj-type   = x-store-type and
    b-stk-tot.fact-order = p-fact-order and
    b-stk-tot.sum-type = trim(p-arh) + trim(p-vv) :
        p-calc = p-calc + 1.
        PUT STREAM OutStream
        SPACE(32)
            "в том числе со ставкой : " +
            entry(p-i,b-stk-tot.cat-id)  +
            " % " + String ( Round (( if tprintrubl then b-stk-tot.vat-rubl else b-stk-tot.vat-base )    , 2) )
            /*+ " с суммы " + String ( Round (( if tprintrubl then b-stk-tot.sum-rubl else b-stk-tot.sum-base )    , 2) ) */
            format "x(100)"

            SKIP.
            run new-tmp-page .
            num#str# = num#str# + 1.
            num#col# = 1.
            run macr_excel_char(
            "в том числе со ставкой : " +
            entry(p-i,b-stk-tot.cat-id)  +
            " % " + String( Round(( if tprintrubl then b-stk-tot.vat-rubl else b-stk-tot.vat-base ), 2) )
            /*+ " с суммы " + String ( Round (( if tprintrubl then b-stk-tot.sum-rubl else b-stk-tot.sum-base )    , 2) )*/
          , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    End.
End.
end procedure .

PROCEDURE Break-VAT-sub :   /* расшифровка НДС и НП */
define input parameter par1 as char.
define variable x-pc_vat as integer no-undo .
define variable x-pc_slt as integer no-undo .
define variable x-vat-sum    as decimal format "->>,>>>,>>9.99" no-undo .
define variable x-vat    as decimal format "->>,>>>,>>9.99" no-undo .
define variable x-slt    as decimal format "->>,>>>,>>9.99" no-undo .

DEFINE buffer buff-ot-line-tax for ot-tot .
   /* а теперь совместная расшифровка */
define variable vv-par as character no-undo .
 vv-par =  (par1 + {&arh-VATSLT}).

  for each buff-ot-line-tax where
      buff-ot-line-tax.doc-code   = doc-code             and
      buff-ot-line-tax.sum-type   = vv-par

      no-lock
      break  by buff-ot-line-tax.sum-type
             by buff-ot-line-tax.cat-id
            :
      if first-of(buff-ot-line-tax.sum-type) then do:
        Display stream OutStream
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
            sym7
            sym8
            sym9
            (if par1  begins {&arh-crsa} then 'В прод.ценах'  else '') @ f-qnty
            sym10
            "---------------" @ f-SumWithNDS
            "---------------" @ f-SumWithoutNDS
            "---------------" @ f-discnt-sum
            "---------------" @ f-ov-sum
            "---------------" @ f-sale-sum
            "------"          @ F-vat_Pc
            "-"               @ Sym11
            "Распределение--" @ F-vat-sum
            "-"               @ Sym12
            "налого"          @ F-slt_Pc
            "в"               @ Sym13
            "---------------" @ F-slt-sum
            "-"               @ Sym14
            with FRAME DocsRep .
            DOWN stream  OutStream 1 with FRAME DocsRep.
            run new-tmp-page .
            num#str# = num#str# + 1.
            num#col# = 10.
            run macr_excel_char("Распределение налогов"  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

      End.

      if first-of(buff-ot-line-tax.cat-id) then do:
       Assign
          x-pc_vat  = 0
          x-pc_slt  = 0
          x-vat-sum = 0
          x-vat     = 0
          x-slt     = 0
          .
      End.

  Assign
   x-pc_vat  = integer(entry(1,buff-ot-line-tax.cat-id ))
   x-pc_slt  = integer(entry(2,buff-ot-line-tax.cat-id ))
   x-vat-sum = x-vat-sum + if tPrintRubl then buff-ot-line-tax.sum-rubl else buff-ot-line-tax.sum-base
   x-vat     = x-vat + if tPrintRubl then buff-ot-line-tax.vat-rubl else buff-ot-line-tax.vat-base
   x-slt     = x-slt + if tPrintRubl then buff-ot-line-tax.slt-rubl else buff-ot-line-tax.slt-base
   no-error
   .
   if error-status :error
      then Assign
                  x-pc_vat  = 0
                  x-pc_slt  = 0
                  x-vat-sum = 0
                  x-vat     = 0
                  x-slt     = 0
                  .

      if last-of (buff-ot-line-tax.cat-id) then  do :
            Display stream OutStream
                sym1
                sym2
                sym3
                sym4
                "<" @ sym5
                x-VAT-sum     @ f-SumWithNDS
                ">" @ sym6
                sym7
                sym8
                sym9
                sym10
                string(integer(x-pc_vat),">9") + '%'    @ f-vat_PC
                sym11
                x-vat      @ f-VAT-Sum
                sym12
                string(integer(x-pc_slt),">9") + '%'     @ f-SLT_PC
                sym13
                x-slt      @ f-slt-sum
                sym14
                with FRAME DocsRep .
                DOWN stream  OutStream 1 with FRAME DocsRep.

                run new-tmp-page .
                num#str# = num#str# + 1.
                num#col# = 5.
                run macr_excel_char( x-VAT-sum  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                num#col# = 10.
                run macr_excel_char( string(integer(x-pc_vat),">9") + '%'    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char( x-vat                                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char( string(integer(x-pc_slt),">9") + '%'    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                run macr_excel_char( x-slt                                   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
         End.
  end.
END PROCEDURE.

procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >= 63000 then do:

        Output stream Macr_Excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header-my. /* снова шапку */
    end.

 end. /* do */
end procedure. /* new-tmp-page */
procedure proc-print-header-my :
 do
 on error undo, return error return-value
 :
/* Шапка */

   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,{&new-line}) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , {&new-line} ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .

     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, {&new-line}) , {&comma-char} ) .

     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, {&new-line}) , {&comma-char}) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.

    c-i = 0.
    end.

    run macr_cell_format (
        10       , /*p-size-font */
        true     , /*p-bold      */
        false    , /*p-italic    */
        35       , /*p-color-bg  */
        var-1 + 1, /*p-row       */
        1        , /*p-col       */
        num#str# , /*p-row-2     */
        num#col# ) /*p-col-2     */
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .


 end. /* do */
end procedure. /* proc-print-header-my */

{ rep/r-libmcr.i macr_excel         }
/* $Workfile$ e n d */