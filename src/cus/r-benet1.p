block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-benet1.p $
$Archive: cus/r-benet1.p $

Движение товара по месту хранени

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Created: 14/12/00
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-benet1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-benet1.p $":U .
define variable vss-description as character no-undo init "Движение товара по месту хранения ".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/f-flav.i   }
{ rep/repfrm.i def }
{ rep/rep-bt.i    }
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.

define input parameter xClassify    as char no-undo.
define input parameter xSortType    as char no-undo.
define input parameter xSumsOnly    as log  no-undo.
define input parameter xShowZero    as log  no-undo.
define input parameter xTog-obj     as log no-undo.
define input parameter xShowCost    as log no-undo.
define input parameter xShowSale    as log no-undo.
define input parameter xtog-lavel   as log no-undo.
define input parameter xvar-lavel   as int no-undo.

define input parameter fo0    like ub.ot-tot.fact-order no-undo.
define input parameter fo02   like ub.ot-tot.fact-order no-undo.
define input parameter fo1    like ub.ot-tot.fact-order no-undo.
define input parameter fo12   like ub.ot-tot.fact-order no-undo.
define input parameter fo2    like ub.ot-tot.fact-order no-undo.
define input parameter fo22   like ub.ot-tot.fact-order no-undo.
define input parameter fo3    like ub.ot-tot.fact-order no-undo.
define input parameter fo32   like ub.ot-tot.fact-order no-undo.
define input parameter fo4    like ub.ot-tot.fact-order no-undo.
define input parameter fo42   like ub.ot-tot.fact-order no-undo.
define input parameter fo5    like ub.ot-tot.fact-order no-undo.
define input parameter fo52   like ub.ot-tot.fact-order no-undo.
define input parameter Tog-Qnty  as log no-undo.
define input parameter xbsamount as int no-undo.
define input parameter Tog-voz  as log no-undo.
define input parameter ShowOrders  as log no-undo.
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define  variable  tPrintRubl as log no-undo.

define stream  instream    .
define stream  outstream   .
define stream  outstream2  .

make-excel-com = false .
make-excel     = true  .

define stream  macr_excel .

/*общий итог*/

define variable ObjName           as   char no-undo.
define variable Select-Good       as   integer no-undo.
define variable ChosedType        as   integer no-undo.
define variable PayType           as   integer no-undo.
define variable RetClassify       as   char  no-undo.
define variable RetSortType       as   char  no-undo.
define variable Show-Negativ      as   logical  no-undo.
define variable Sums-Only         as   logical  no-undo.
define variable ValType           as   integer no-undo.
define variable Line              as   char        no-undo.
define variable FirstLine         as   logical     no-undo.
define variable Number-Orders as character no-undo .
define variable QNTY-Orders as character no-undo .

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* Local Variable Definitions ---                                       */

define variable stat      as log no-undo .
define variable InpError  as log no-undo .
define variable i         as integer init 0 no-undo .
define variable R         as integer init 0 no-undo .
define variable ii        as integer init 0 no-undo .
define variable rr        as integer init 0 no-undo .
define variable f-ii      as char no-undo .
define variable p         as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable rid-list  as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.

define variable F-ostatok-start    as   char  no-undo.
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable ostatok-End        as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable F-prih             as   char  no-undo.
define variable F-rash             as   char  no-undo.
define variable F-kassa1            as   char  no-undo.
define variable F-kassa2            as   char  no-undo.
define variable F-kassa3            as   char  no-undo.
define variable F-kassa4            as   char  no-undo.
define variable F-kassa5            as   char  no-undo.
define variable F-kassa6            as   char  no-undo.
define variable F-Inv              as   char  no-undo.
define variable F-Overturn         as   char  no-undo.
define variable f-zakaz            as   decimal  no-undo.
define variable F-Center-stock     as   decimal  no-undo.
define variable F-avr              as   decimal  no-undo.

define variable prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.

define variable B1-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable b1-f-zakaz            as   decimal  no-undo.
define variable b1-F-Center-stock     as   decimal  no-undo.
define variable b1-F-avr              as   decimal  no-undo.


define variable B2-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable b2-f-zakaz            as   decimal  no-undo.
define variable b2-F-Center-stock     as   decimal  no-undo.
define variable b2-F-avr              as   decimal  no-undo.

define variable Bi-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable bi-f-zakaz            as   decimal  no-undo.
define variable bi-F-Center-stock     as   decimal  no-undo.
define variable bi-F-avr              as   decimal  no-undo.


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

define variable str as char format "X(60)" no-undo.
define variable i3#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define BUFFER stk-line2 FOR ub.stk-line  .

define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int
    .

define temp-table tmp#bs no-undo
    FIELD   b-code         LIKE gds-zap-b-code
    FIELD   artic          LIKE gds-zap-artic
    FIELD   prod-code      LIKE gds-zap-prod-code
    FIELD   prod-type      LIKE gds-zap-prod-type
    FIELD   prt-root       LIKE gds-zap-prt-root
    FIELD   grp-name       LIKE gds-zap-grp-name
    FIELD   F-zakaz        LIKE F-zakaz
    FIELD   F-center-stock LIKE F-center-stock
    FIELD   Prih           like ub.stk-tot.fact-qnty
    FIELD   ostatok-end    like ub.stk-tot.fact-qnty
    FIELD   f-avr          LIKE f-avr
    FIELD   kASSA1         like ub.stk-tot.fact-qnty
    FIELD   KAssa2         like ub.stk-tot.fact-qnty
    FIELD   KAssa3         like ub.stk-tot.fact-qnty
    FIELD   KAssa4         like ub.stk-tot.fact-qnty
    FIELD   KAssa5         like ub.stk-tot.fact-qnty
    FIELD   KAssa6         like ub.stk-tot.fact-qnty
    INDEX Byf-avr   f-avr ASCENDING
    .

define variable     v#b-code         LIKE gds-zap-b-code no-undo.
define variable     v#artic          LIKE gds-zap-artic  no-undo.
define variable     v#prod-code      LIKE gds-zap-prod-code  no-undo.
define variable     v#prod-type      LIKE gds-zap-prod-type  no-undo.
define variable     v#prt-root       LIKE gds-zap-prt-root   no-undo.
define variable     v#grp-name       LIKE gds-zap-grp-name   no-undo.
define variable     v#F-zakaz        LIKE F-zakaz            no-undo.
define variable     v#F-center-stock LIKE F-center-stock     no-undo.
define variable     v#Prih           like ub.stk-tot.fact-qnty  no-undo.
define variable     v#ostatok-end    like ub.stk-tot.fact-qnty  no-undo.
define variable     v#f-avr          LIKE f-avr              no-undo.
define variable     v#kASSA1         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa2         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa3         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa4         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa5         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa6         like ub.stk-tot.fact-qnty  no-undo.

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

define variable c-c      as integer no-undo .
define variable c-str    as character no-undo .
define variable str--1   as character format "x (60)" no-undo.
define variable str--2   as integer no-undo .
define variable c-i      as integer no-undo .
define variable p-var    as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .

/*===================================================================================================================*/
{ rep/repfrm.i on 25}



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
        Line          = fill ("-", {&DOS_CW_2}).

        ValType       = IF  (PayType = 1) Then 0  else x-SET_val_TYPE.

        run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :
define variable l as integer no-undo .
define variable lL as integer no-undo .
    { rep/r-val.i }
    p-file-name =  string ( session:temp-directory +
                                  {&df_name} + string ( g#report-num ) + ".txt" ) .

     output stream outstream to value ( string ( session:temp-directory +
                                  {&df_name} + string ( g#report-num ) ) )      .

    /* output stream outstream2 to value (p-file-name). */

    run maket in this-procedure .

    /* создаем временный файл */
    run gbl/_tmpfile.p  ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value (v-file-name)   .
                put stream  outstream  "1" format "x (100)" skip .
    v-ind = 1    .
    num#str# = 0 .

      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format ( reportname , num#str# , num#col#  ).
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
define variable v-nn as integer   no-undo .
&scop var-print-n  v-nn = num-entries ( ~{&var-str-n} , "~{&new-line}"  ) .  do l-ii = 1 to v-nn   :  ~
      l-len = length  (entry ( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer ( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format (                                                          ~
              substring (entry ( l-ii , ~{&var-str-n}  , "~{&new-line}") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
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
  run macr_excel_char_with_format (
        "Дата печати : " + string (today,"99.99.9999") +  " , "     +
      " Цены указаны в " +
       (if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
      , num#str#
      , num#col#
        ) .
/*Печать шапки */
run make-col in this-procedure .
run proc-print-header in this-procedure .

   define variable gj as integer no-undo init 0.
   if xtog-obj /* раздельно по объектам */ then do:
      for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          run report-exec1 in this-procedure .
          gj = gj + 1 .
      end.
      if gj > 1 then   run display-bo in this-procedure .
      end.
   else  run report-exec1 in this-procedure .
   output stream outstream close.
   output stream outstream2 close.
  output stream macr_excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
       (input "file"
      ,input string (v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
       (input "charcol"
      ,input ""
      ,input "2"
      ) .


  run end-proc in this-procedure .
  { rep/repfrm.i off}
  run rep/runexcel.p  (p-file-name ).
end procedure.

/*----------------------------------------------------------------------------------*/
PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose: Поиск по итогам по строкам документов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*   по 1 товару  */
 R = R + 1.
 { rep/repfrm.i disp r objname}
  run clear-item in this-procedure .
  run zakaz in this-procedure . /* заказ */

  IF NOT Show-Negativ  AND  f-zakaz  = 0 THEN RETURN.  /* Нулевые заказы */
 { rep/io.i Fact-order-2 arh-crsa 0 end} /* ОСТАТОК на конец  */
 /* Приход */
   run ob-line in this-procedure ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code   ,
      input   gds-zap-prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   {&arh-crsa}    ,  input   {&root-cat-id}, input   "", input   xtog-obj ,
      input   1 ,
      output prih[1]   ).
f-center-stock = f-zakaz - prih[1].
/* Касса 1 */
   run ob-line-1 in this-procedure ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo0,
      input   fo02,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[1]   ).


 If Showorders = false THEN DO:
/* Касса 2 */
   run ob-line-1 in this-procedure ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo1,
      input   fo12,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[2]   ).
/* Касса 3 */
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo2,
      input   fo22,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[3]   ).
/* Касса 4 */
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo3,
      input   fo32,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[4]   ).
/* Касса 5 */
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo4,
      input   fo42,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[5]   ).
/* Касса 6*/
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo5,
      input   fo52,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[6]   ).
end.

   f-avr = round ( kassa[1] / if integer (fo02 - fo0) = 0 then 1 else integer (fo02 - fo0) , 3) .
/* подсчет подитогов */
   if not tog-qnty then  run calc-sub-itog in this-procedure   (0).
      else do :
           rr = rr + 1 .
           run maketemptable in this-procedure   .
            return error.
      end.


END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line :
/*------------------------------------------------------------------------------
  Purpose: Display  for frame  & Accumulate
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

     IF  NOT  (NOT Show-Negativ  AND   f-zakaz  = 0  aND PRIH[1] = 0  AND kassa[1] = 0 ) then DO:
        IF NOT Sums-Only then DO:
           ii = ii + 1.
           run display-str1 in this-procedure .
          End.
     END.
  END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE print-header :
define variable l-name as character no-undo .
define variable mm as integer no-undo .
define variable RANGES as character no-undo .


if Showorders = false then
    if NOT FirstLine Then  run display-title in this-procedure .

    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
       l-name =  "ПО ОБЪЕКТУ : " + CAPS (ObjName).
          { cus/r-ben1.i  l-name  1 bold WrapText=false }.

          End.
  if showOrders then do :
      /* num#str#  = num#str#  - 1. */
      Number-Orders = "" .
        run macr_excel_char_with_format ( string ("№/№"                    )  , num#str# , 1) .
        run macr_excel_char_with_format ( string ("Артикул"                )  , num#str# , 2) .
        run macr_excel_char_with_format ( string ("Суммарный Заказ"        )  , num#str# , 3) .
        run macr_excel_char_with_format ( string ("Центр. склад"           )  , num#str# , 4) .
        run macr_excel_char_with_format ( string ("Приход"                 )  , num#str# , 5) .
        run macr_excel_char_with_format ( string ("Остаток"                )  , num#str# , 6) .
        run macr_excel_char_with_format ( string ("Реализ. Среднесуточная" )  , num#str# , 7) .
        run macr_excel_char_with_format ( string ("Касса за месяц"         )  , num#str# , 8) .
        run macr_cell_format  (
                        10       , /*p-size-font */
                        true     , /*p-bold      */
                        false    , /*p-italic    */
                        35       , /*p-color-bg  */
                        num#str#, /*p-row       */
                        1        , /*p-col       */
                        num#str# , /*p-row-2     */
                        8 ) /*p-col-2     */
                        .
          mm = 8  .
          For each ub.trn-doc where
                  ub.trn-doc.doc-date <= x-date-end
            AND   ub.trn-doc.doc-date >= x-date-start
            AND   ub.trn-doc.status_   = {&inquiry}
            AND   ub.trn-doc.internal  = false
            AND   ub.trn-doc.obj-code   = x-store-code
            AND   ub.trn-doc.obj-type   = x-store-type
            no-lock :
                  Number-Orders = Number-orders +  ub.trn-doc.doc-code  + {&tabulation}.
                  sheetf.Sizes = sheetf.sizes + "15," .
                  mm = mm + 1 .
                    run macr_excel_char_with_format in this-procedure  ( ub.trn-doc.doc-code  , num#str# , mm ) .
                    run macr_cell_format in this-procedure   (
                        10       , /*p-size-font */
                        true     , /*p-bold      */
                        false    , /*p-italic    */
                        35       , /*p-color-bg  */
                        num#str#, /*p-row       */
                        mm        , /*p-col       */
                        num#str# , /*p-row-2     */
                        mm ) /*p-col-2     */
                        .



          End.
      End.

      run clear-b1 in this-procedure  .
      run clear-b2 in this-procedure .
      run clear-bi in this-procedure  .
      run clear-item in this-procedure .
      break_group = true.
      break_group1 = true.
      num#str#  = num#str#  + 1 .
   END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Print-Footer :
/*------------------------------------------------------------------------------
  Purpose: Печать итогов отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
     /*последняя строка*/
      if retclassify = "no-classify":u  then run u-line in this-procedure .
/*-----КОЛИЧЕСТВО----------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       run display-bi in this-procedure .
       run u-line in this-procedure .
       END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
        END PROCEDURE.
/*-------------------------------*/
PROCEDURE P-LINE :
        END PROCEDURE.
/*-------------------------------*/
{ rep/procobor.i func-vat }
{ rep/obr-runn.i 1 yes }
{ rep/obr-runn.i 2 yes }
{ rep/obr-runn.i 3 yes }
{ rep/obr-runn.i 4 yes }
{ rep/obr-runn.i 5 yes }
{ rep/obr-runn.i 7 yes }

PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти  на начало и конец  FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run ostatok in this-procedure
    (   input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date ('')      , x-Shift-Start,x-Shift-End,
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
    run ostatok in this-procedure
    (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
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
define variable i as integer no-undo .
define variable v-nn as integer   no-undo .
 qnty-orders = "" .
if showorders = true then DO:
    v-nn = num-entries (Number-Orders,{&tabulation})  .
    repeat i = 1 to v-nn :
    If entry (i,Number-Orders,{&tabulation}) <> ?
       and entry (i,Number-Orders,{&tabulation}) <> ""
       and entry (i,Number-Orders,{&tabulation}) <> "0" Then DO:
      Find first ub.doc-line where
            entry (i,Number-Orders,{&tabulation}) =  ub.doc-line.doc-code
            AND   ub.doc-line.obj-code   = x-store-code
            AND   ub.doc-line.obj-type   = x-store-type
            AND   ub.doc-line.prod-code  = gds-zap-prod-code
            AND   ub.doc-line.prod-type  = gds-zap-prod-type
            AND   ub.doc-line.status_    = {&inquiry}
            AND   ub.doc-line.artic      = gds-zap-artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                       (if avail ub.doc-line then
                      string (ub.doc-line.fact-qnty)  Else "0")  +  "," .
     End.
    End.

 End.
 Else qnty-orders = "".

 run di  ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
END PROCEDURE.
PROCEDURE display-Bi  :
   qnty-orders = "".
   run di ("кол-во",1,  "", gds-zap-artic ,"" ,"", "BI":U).
       run macr_cell_format  (
          10       , /*p-size-font */
          true     , /*p-bold      */
          false    , /*p-italic    */
          ?        , /*p-color-bg  */
          num#str# , /*p-row       */
          1        , /*p-col       */
          num#str# , /*p-row-2     */
          14 )        /*p-col-2     */
          .

END PROCEDURE.
PROCEDURE display-B1  :
    qnty-orders = "".
    run di ("кол-во"  ,1,  ( s-bar-code + ' ' + CAPS (gds-zap-artic + gds-zap-gds-name)) , "" ,"","","B1":U).
       run macr_cell_format  (
          10       , /*p-size-font */
          true     , /*p-bold      */
          false    , /*p-italic    */
          ?        , /*p-color-bg  */
          num#str# , /*p-row       */
          1        , /*p-col       */
          num#str# , /*p-row-2     */
          14 )        /*p-col-2     */
          .

END PROCEDURE.
PROCEDURE display-Bo  :
END PROCEDURE.
PROCEDURE display-B2  :
    qnty-orders = "".
    run di  ( "кол-во", 1 , ( s-bar-code + ' ' + caps (gds-zap-artic + gds-zap-gds-name)), "" ,"", "","b2":u).
       run macr_cell_format  (
          10       , /*p-size-font */
          true     , /*p-bold      */
          false    , /*p-italic    */
          36        , /*p-color-bg  */
          num#str# , /*p-row       */
          1        , /*p-col       */
          num#str# , /*p-row-2     */
          14 )        /*p-col-2     */
          .

END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------*/
PROCEDURE Clear-B1  :

 REPEAT kk = 1 to 6 :
 Assign
    b1-Prih                                            [kk]    = 0
    b1-Rash                                            [kk]    = 0
    b1-KAssa                                           [kk]    = 0
    b1-Inv                                             [kk]    = 0
    b1-Overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0
    b1-f-zakaz        = 0
    b1-F-Center-stock = 0
    b1-F-avr          = 0  .


   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
 REPEAT kk = 1 to 6 :
 Assign
    b2-Prih                                            [kk]    = 0
    b2-Rash                                            [kk]    = 0
    b2-KAssa                                           [kk]    = 0
    b2-Inv                                             [kk]    = 0
    b2-Overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0
    b2-f-zakaz        = 0
    b2-F-Center-stock = 0
    b2-F-avr          = 0  .

   End.

END PROCEDURE.
PROCEDURE Clear-Bi  :
 REPEAT kk = 1 to 6 :
 Assign
    bi-Prih                                            [kk]    = 0
    bi-Rash                                            [kk]    = 0
    bi-KAssa                                           [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0
    bi-f-zakaz                                                = 0
    bi-F-Center-stock                                         = 0
    bi-F-avr                                                  = 0  .
   End.

END PROCEDURE.

PROCEDURE Display-title :

    i=0.
 /* run rep/extitle.p (1) . */
END PROCEDURE.

PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as log no-undo.
define input  parameter xi               as int no-undo.

define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.

define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
  Assign First-sum = 0 Second-sum = 0 Quntity = 0 .
  For EAch obj-list  where  x-store-type = obj-list.obj-type  AND  x-store-code = obj-list.obj-code
   no-lock:
   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      FIND LAST ub.stk-line where
                              ub.stk-line.artic         = x-artic
                        AND   ub.stk-line.fact-order   <= x-fact-order-1
                        AND   ub.stk-line.obj-code     = obj-list.obj-code
                        AND   ub.stk-line.obj-type     = obj-list.obj-type
                        AND   ub.stk-line.prod-code    = x-prod-code
                        AND   ub.stk-line.prod-type    = x-prod-type
                        AND   ub.stk-line.sum-type     = temp#sum-type.sum-type
                        AND   ub.stk-line.cat-id       = {&root-cat-id}
                              no-lock use-index pi no-error.
           if available ub.stk-line THEN First-sum = First-sum + ub.stk-line.fact-qnty.
      FIND LAST STK-line2 where
                              STK-line2.artic         = x-artic
                        AND   STK-line2.fact-order   <= x-fact-order-2
                        AND   STK-line2.obj-code     = obj-list.obj-code
                        AND   STK-line2.obj-type     = obj-list.obj-type
                        AND   STK-line2.prod-code    = x-prod-code
                        AND   STK-line2.prod-type    = x-prod-type
                        AND   STK-line2.sum-type     = temp#sum-type.sum-type
                        AND   STK-line2.cat-id       = {&root-cat-id}
                              no-lock use-index pi  no-error.
           if available STK-LINE2 THEN Second-sum = Second-sum + Stk-line2.fact-qnty.
   End.
   End.
   Quntity = Second-sum - first-sum.
END PROCEDURE.
 { rep/ost-line.i }
 { rep/ostatok.i }
/*----------------------------------------------------------------*/
PROCEDURE report-exec1  :
for each TMP#bs share-lock: delete TMP#bs. end.

   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName = "объект не определен".


  run calcitog.
  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   case retclassify :
      when "no-classify":u    then  run run1.
      when "grp-goods":u      then  run run2.
      when "prod":u           then  run run3.
      when "prod/grp-goods":u then  run run4.
      when "grp-goods/prod":u then  run run5.
      when "vat-ps":u         then  run run7.
   end case.
   if tog-qnty then
      run printtemptable in this-procedure .
      else run print-footer in this-procedure  .
  END PROCEDURE.

/*-----------------------------------------------------------------------------------------*/
PROCEDURE Calc-Sub-itog :     /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.
  Assign
  B1-Prih[1]    = B1-Prih[1]    +  Prih[1]
  B2-Prih[1]    = B2-Prih[1]    +  Prih[1]
  Bi-Prih[1]    = Bi-Prih[1]    +  Prih[1]

  B1-f-zakaz    = B1-f-zakaz   + f-zakaz
  B2-f-zakaz    = B2-f-zakaz   + f-zakaz
  Bi-f-zakaz    = Bi-f-zakaz   + f-zakaz

  B1-F-Center-stock = B1-F-Center-stock  +  F-Center-stock
  B2-F-Center-stock = B2-F-Center-stock  +  F-Center-stock
  Bi-F-Center-stock = Bi-F-Center-stock  +  F-Center-stock

  B1-F-avr = B1-F-avr  +  F-avr
  B2-F-avr = B2-F-avr  +  F-avr
  Bi-F-avr = Bi-F-avr  +  F-avr.


repeat b = 1 to 6:

  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT] .
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT] .
  Bi-Kassa[b + TT]    = Bi-Kassa[b + TT]    +  Kassa[b + TT] .

End.
END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 6:
 Assign
    prih                 [kk]    = 0
    rash                 [kk]    = 0
    kassa               [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
 END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
      if par-4 = "goods":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = Goods.prod-type AND
                              clients.obj-code = Goods.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = Goods.unit-base
                                    gds-zap-prt-root   = Goods.prt-root
                                    gds-zap-prod-type  = Goods.prod-type
                                    gds-zap-prod-code  = Goods.prod-code
                                    gds-zap-artic      = Goods.artic
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
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = gds-list.engl-name.
                                else
                                    assign gds-zap-gds-name = gds-list.gds-name.
                            End.


   run foreach.
    if  break_group = true  and par-3 <> "1"  then do :
         find first clients where clients.obj-type = gds-zap-prod-type and clients.obj-code = gds-zap-prod-code use-index pi no-lock .
         gds-zap-prod-name  = clients.obj-name.

          If break_group1 = true  THEN  DO :
            if  (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string ("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string ("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
              if par-3 = "6"  then  DO:
                        var-vat-pc = {&break-vat} .
                        assign
                            temp-str = string ( "СТАВКА НДС : " + string (var-vat-pc) + "%" )

                            b1-name = temp-str.
              end.

               if NOT xSumsOnly or  (par-3 = "4" Or par-3 = "5" ) THEN DO :
                fr0 = true .
                tmp#stroka0 = temp-str.
                { cus/r-ben1.i  tmp#stroka0 1 }
                run macr_cell_format  (
                              10       , /*p-size-font */
                              true     , /*p-bold      */
                              true     , /*p-italic    */
                              36       , /*p-color-bg  */
                              num#str#, /*p-row       */
                              1        , /*p-col       */
                              num#str# , /*p-row-2     */
                              14 ) /*p-col-2     */
                              .

               End.
          End.

          IF  (par-3 = "4"  OR  par-3 = "5")  THEN DO:
            if par-3 = "4"
              then Assign temp-str = string ("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name .
              else Assign temp-str = string ("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name.

            if NOT xSumsOnly THEN DO:
                fr = true .
                { cus/r-ben1.i  temp-str 1 }  .
                run macr_cell_format  (
                              10       , /*p-size-font */
                              true     , /*p-bold      */
                              true     , /*p-italic    */
                              37       , /*p-color-bg  */
                              num#str#, /*p-row       */
                              1        , /*p-col       */
                              num#str# , /*p-row-2     */
                              14 ) /*p-col-2     */
                              .

            End.

            break_group1 = false.
          END.
       break_group = false.
    End.
    If NOT Tog-Qnty THEN run display-line.

 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS (p7) :
   WHEN "B1":U  Then
            run display-str-ex  ( '',
                p3                  ,
                p4                  ,
                b1-F-zakaz          ,
                b1-F-center-stock   ,
                b1-Prih       [1]   ,
                b1-ostatok-end[1]   ,
                b1-F-avr            ,
                b1-KAssa      [1]   ,
                b1-KAssa      [2]   ,
                b1-KAssa      [3]   ,
                b1-KAssa      [4]   ,
                b1-KAssa      [5]   ,
                b1-KAssa      [6]   ).

   WHEN "B2":U  Then
             run display-str-ex  ( '',
                p3                  ,
                p4                  ,
                b2-F-zakaz          ,
                b2-F-center-stock   ,
                b2-Prih [1]         ,
                b2-ostatok-end[1]   ,
                b2-F-avr            ,
                b2-KAssa      [1]   ,
                b2-KAssa      [2]   ,
                b2-KAssa      [3]   ,
                b2-KAssa      [4]   ,
                b2-KAssa      [5]   ,
                b2-KAssa      [6]   ).

   WHEN "BI":U Then
             run display-str-ex  ( '',
                ''                   ,
                p4                   ,
                bi-f-zakaz           ,
                bi-f-center-stock    ,
                bi-prih          [1] ,
                bi-ostatok-end   [1] ,
                bi-f-avr             ,
                bi-kassa       [1]   ,
                bi-kassa         [2] ,
                bi-kassa         [3] ,
                bi-kassa         [4] ,
                bi-kassa         [5] ,
                bi-kassa         [6] ).
   when ""  then
             run display-str-ex  ( ':',
                ii                    ,
                p4                    ,
                f-zakaz               ,
                f-center-stock        ,
                prih          [1]     ,
                ostatok-end   [1]     ,
                f-avr                 ,
                kassa         [1]     ,
                kassa         [2]     ,
                kassa         [3]     ,
                kassa         [4]     ,
                kassa         [5]     ,
                kassa         [6]     ).

       end case.
 end procedure.
 procedure zakaz :
   f-zakaz = 0.
   for each ub.trn-doc where
          ub.trn-doc.doc-date <= x-date-end
    and   ub.trn-doc.doc-date >= x-date-start
    and   ub.trn-doc.status_   = {&inquiry}
    and   ub.trn-doc.internal  = false
    and   ub.trn-doc.obj-code   = x-store-code
    and   ub.trn-doc.obj-type   = x-store-type
     no-lock :
      for each ub.doc-line where
              ub.trn-doc.doc-code =  ub.doc-line.doc-code
        and   ub.doc-line.obj-code   = x-store-code
        and   ub.doc-line.obj-type   = x-store-type
        and   ub.doc-line.prod-code  = gds-zap-prod-code
        and   ub.doc-line.prod-type  = gds-zap-prod-type
        and   ub.doc-line.status_    = {&inquiry}
        and   ub.doc-line.artic      = gds-zap-artic    no-lock :
              f-zakaz = f-zakaz  +  ub.doc-line.doc-qnty   .
      end.
   end.
end procedure.

procedure maket :
/* Приход */
  create temp#sum-type no-error.
  assign temp#sum-type.sum-type = {&arh-cgdt} + {&tdedt_Pri_perem}       temp#sum-type.xi = 1      .
  create temp#sum-type no-error.
  assign temp#sum-type.sum-type = {&arh-cgdt} +  {&tdedt_ras_perem}       temp#sum-type.xi = 1      .

/* касса */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  {&TDEDT_Ras_Vnesh_Kass}       temp#sum-type.xi = 2      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  {&TDEDT_Vozvrat_Vnesh_Kass}   temp#sum-type.xi = 2      .
 If tog-voz then do:
    Create temp#sum-type no-error.
    Assign temp#sum-type.sum-type =  {&TDEDT_Vozvrat_Vnesh}        temp#sum-type.xi = 2      .
  End.

 End procedure.

Procedure Display-str-ex :
 define input parameter  p0  as char no-undo.
 define input parameter  p1  as char no-undo.
 define input parameter  p2  as char no-undo.
 define input parameter  p3  as decimal no-undo.
 define input parameter  p4  as decimal no-undo.
 define input parameter  p5  as decimal no-undo.
 define input parameter  p6  as decimal no-undo.
 define input parameter  p7  as decimal no-undo.
 define input parameter  p8  as decimal no-undo.
 define input parameter  p9  as decimal no-undo.
 define input parameter  p10 as decimal no-undo.
 define input parameter  p11 as decimal no-undo.
 define input parameter  p12 as decimal no-undo.
 define input parameter  p13 as decimal no-undo.
define variable l as integer no-undo .
define variable m as integer no-undo .
define variable v-nnn as integer   no-undo .
if Showorders = false THEN DO:
               { cus/r-ben1.i  p1   1   }.
               { cus/r-ben1.i  p2   2   }.
               { cus/r-ben1.i  p3   3   }.
               { cus/r-ben1.i  p4   4   }.
               { cus/r-ben1.i  p5   5   }.
               { cus/r-ben1.i  p6   6   }.
               { cus/r-ben1.i  p7   7   }.
               { cus/r-ben1.i  p8   8   }.
               { cus/r-ben1.i  p9   9   }.
               { cus/r-ben1.i  p10  10  }.
               { cus/r-ben1.i  p11   11 }.
               { cus/r-ben1.i  p12   12 }.
               { cus/r-ben1.i  p13    13 } .
End.
Else DO:
               { cus/r-ben1.i  p1   1   }.
               { cus/r-ben1.i  p2   2   }.
               { cus/r-ben1.i  p3   3   }.
               { cus/r-ben1.i  p4   4   }.
               { cus/r-ben1.i  p5   5   }.
               { cus/r-ben1.i  p6   6   }.
               { cus/r-ben1.i  p7   7   }.
               { cus/r-ben1.i  p8   8   }.
               v-nnn = num-entries (qnty-orders).
               repeat l = 1 to v-nnn :
                   m = 8 + l .
                  { cus/r-ben1.i  entry(l,qnty-orders) m }.
               End.

End.
/*if p2 = "ИТОГО" then bold */
End procedure.
PROCEDURE MAketemptable :
   Assign
    v#b-code        = gds-zap-b-code
    v#artic         = gds-zap-artic
    v#prod-code     = gds-zap-prod-code
    v#prod-type     = gds-zap-prod-type
    v#prt-root      = gds-zap-prt-root
    v#grp-name      = gds-zap-grp-name
    v#F-zakaz       =  F-zakaz
    v#F-center-stock=  F-center-stock
    v#Prih          =  Prih          [1]
    v#ostatok-end   =  ostatok-end   [1]
    v#f-avr         =  f-avr
    v#kASSA1        =  kAssa         [1]
    v#KAssa2        =  KAssa         [2]
    v#KAssa3        =  KAssa         [3]
    v#KAssa4        =  KAssa         [4]
    v#KAssa5        =  KAssa         [5]
    v#KAssa6        =  KAssa         [6]      no-error.
   If RR <= xBSAmount Then DO:
   Create TMP#bs.
   run eqq.
   End.

 Else DO:
      Find Last TMP#bs  use-index Byf-avr.
      If available TMP#bs AND ABSOLUTE (v#f-avr ) > ABSOLUTE (TMP#bs.f-avr ) Then run eqq.
 End.

END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Eqq :
   Assign
    TMP#bs.b-code        = v#b-code
    TMP#bs.artic         = v#artic
    TMP#bs.prod-code     = v#prod-code
    TMP#bs.prod-type     = v#prod-type
    TMP#bs.prt-root      = v#prt-root
    TMP#bs.grp-name      = v#grp-name
    TMP#bs.F-zakaz       = v#F-zakaz
    TMP#bs.F-center-stock= v#F-center-stock
    TMP#bs.Prih          = v#Prih
    TMP#bs.ostatok-end   = v#ostatok-end
    TMP#bs.f-avr         = v#f-avr
    TMP#bs.kASSA1        = v#kASSA1
    TMP#bs.KAssa2        = v#KAssa2
    TMP#bs.KAssa3        = v#KAssa3
    TMP#bs.KAssa4        = v#KAssa4
    TMP#bs.KAssa5        = v#KAssa5
    TMP#bs.KAssa6        = v#KAssa6
    .
END PROCEDURE.
/*----------------------------------------------------------------*/
PROCEDURE PrintTempTAble :
define variable i as int init 0  no-undo.
define variable l as integer no-undo .
define variable v-nn as integer   no-undo .
    For each TMP#bs  where TMP#bs.f-avr <> 0 by
     (if xSorttype = "sort-code":U  THEN string (TMP#bs.b-code)
       ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
            ELSE  string (TMP#bs.f-avr,"9999999999.999"))   :
                i = i + 1 .

 qnty-orders = "".
    v-nn = num-entries (Number-Orders,{&tabulation}) .
if showorders = true then DO:
    repeat l = 1 to v-nn :
    If entry (l,Number-Orders,{&tabulation}) <> ?
       and entry (l,Number-Orders,{&tabulation}) <> ""
       and entry (l,Number-Orders,{&tabulation}) <> "0" Then DO:
      Find first ub.doc-line where
            entry (l,Number-Orders,{&tabulation}) =  ub.doc-line.doc-code
            AND   ub.doc-line.obj-code   = x-store-code
            AND   ub.doc-line.obj-type   = x-store-type
            AND   ub.doc-line.prod-code  = TMP#bs.prod-code
            AND   ub.doc-line.prod-type  = TMP#bs.prod-type
            AND   ub.doc-line.status_    = {&inquiry}
            AND   ub.doc-line.artic      = TMP#bs.artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                       (if avail ub.doc-line then
                      string (ub.doc-line.fact-qnty)  Else "0")  +  "," .
     End.
    End.

 End.
 Else qnty-orders = "".

                run display-line-tmp (i).
    End.
    run u-line.
    qnty-orders = "".
end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure display-line-tmp :
define input parameter i as int no-undo.
             run display-str-ex  ( ':',
                i                    ,
                tmp#bs.artic            ,
                tmp#bs.f-zakaz             ,
                tmp#bs.f-center-stock      ,
                tmp#bs.prih                ,
                tmp#bs.ostatok-end         ,
                tmp#bs.f-avr               ,
                tmp#bs.kassa1              ,
                tmp#bs.kassa2              ,
                tmp#bs.kassa3              ,
                tmp#bs.kassa4              ,
                tmp#bs.kassa5              ,
                tmp#bs.kassa6              ).
end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure ob-line-1  :
define input  parameter x-store-code     like clients.obj-code      no-undo.
define input  parameter x-store-type     like clients.obj-type      no-undo.
define input  parameter x-artic          like ub.stk-line.artic        no-undo.
define input  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.stk-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.stk-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj         as log no-undo.
define input  parameter xi               as int no-undo.

define output  parameter quntity         like ub.stk-line.fact-qnty   no-undo.

define variable  first-sum   like ub.stk-line.fact-qnty   no-undo.
  assign
    first-sum = 0
    quntity = 0
    .
    for each obj-list  where
             obj-list.obj-type = x-store-type  and
             obj-list.obj-code = x-store-code
             :
      for each temp#sum-type where
               temp#sum-type.xi = xi
               :
      for each  ub.ot-line no-lock where
                ub.ot-line.artic         = x-artic                and
                ub.ot-line.fact-order   <= x-fact-order-2         and
                ub.ot-line.fact-order   >= x-fact-order-1         and
                ub.ot-line.obj-code     = obj-list.obj-code       and
                ub.ot-line.obj-type     = obj-list.obj-type       and
                ub.ot-line.prod-code    = x-prod-code             and
                ub.ot-line.prod-type    = x-prod-type             and
                ub.ot-line.sum-type     = {&arh-crsa}             and
                ub.ot-line.ext-doc-type = temp#sum-type.sum-type
               :
            assign
              first-sum = first-sum + ub.ot-line.fact-qnty
              .
      end.
    end.
 end.
 Quntity = first-sum.
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
{ rep/r-libmcr.i macr_excel         }

procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >=  63000  then do:
        output stream macr_excel  close .
        /* Запишем в файл параметров */
        run paramls-write in this-procedure
           (input "file"
          ,input string (v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  macr_excel to value (v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
         /* снова шапку */
/*Печать шапки */
   run make-col .
   run proc-print-header .
  end.

 end. /* do */
end procedure. /* new-tmp-page */



procedure make-col :
do
on error undo, return error return-value
:
  num#str# = num#str# + 2.

end. /* do */
end procedure. /* make-col */
/* $Workfile: r-benet1.p $ e n d */