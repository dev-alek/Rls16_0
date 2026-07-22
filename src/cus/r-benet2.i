/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Движение товара по месту хранени

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Created: 14/12/00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Движение товара по месту хранения".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i  }
{ rep/r-sym.i   }
{ rep/r-gl.i    }
{ gbl/waitfram.i }
{ rep/rep-bt.i   }
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.

define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xTog-obj   as log no-undo.
define input parameter  xShowCost as log no-undo.
define input parameter  xShowSale as log no-undo.
define input parameter  xtog-lavel as log no-undo.
define input parameter  xvar-lavel as int no-undo. .
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
define input parameter x-host-code as integer no-undo .
define input parameter tog-voz as logical no-undo .
define input parameter ShowOrders  as log no-undo.
define input parameter  Number-Orders         as character no-undo .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define variable Number-Orders-empty   as character no-undo .
define variable QNTY-Orders as character no-undo .

&scop sum-format  Format "->>>>>>>>>>>>9.<<<"
define variable  tPrintRubl as log no-undo.

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
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable FirstLine         as   logical     no-undo.


define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* Local Variable Definitions ---                                       */

define variable stat      as log no-undo .
define variable InpError  as log no-undo .
define variable i         as integer init 0  no-undo .
define variable R         as integer init 0  no-undo .
define variable ii        as integer init 0  no-undo .
define variable rr        as integer init 0 no-undo .
define variable f-ii      as char no-undo .
define variable p         as integer no-undo init 0 .
define variable L         as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable c         as integer no-undo init 0 .
define variable rid-list  as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-line.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-line.VAT-base no-undo.
define variable gds-zap-Np            like ub.stk-line.SLT-base no-undo.

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

define variable prih             as   decimal EXTENT 6 Format "->>>>>>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal EXTENT 6 {&sum-format}  no-undo.

define variable kassa            as   decimal EXTENT 6  {&sum-format} no-undo.
define variable Inv              as   decimal EXTENT 6  {&sum-format} no-undo.
define variable Overturn         as   decimal EXTENT 6  {&sum-format} no-undo.
define variable  ret-str          as   char    EXTENT 8   no-undo.


define variable B1-prih             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B1-rash             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B1-kassa            as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B1-Overturn         as   decimal EXTENT 6 {&sum-format} no-undo.
define variable b1-ret-str          as   char EXTENT 8 {&sum-format} no-undo.
define variable b2-ret-str          as   char EXTENT 8 {&sum-format} no-undo.
define variable bi-ret-str          as   char EXTENT 8 {&sum-format} no-undo.

define variable f-zakaz             as   decimal {&sum-format}  no-undo.
define variable F-center-stock      as   decimal {&sum-format}  no-undo.
define variable f-avr               as   decimal {&sum-format}  no-undo.

define variable b1-f-zakaz            as   decimal {&sum-format}  no-undo.
define variable b1-F-Center-stock     as   decimal {&sum-format}  no-undo.
define variable b1-F-avr              as   decimal {&sum-format}  no-undo.


define variable B2-prih             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B2-rash             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B2-kassa            as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B2-Inv              as   decimal EXTENT 6 {&sum-format} no-undo.
define variable B2-Overturn         as   decimal EXTENT 6 {&sum-format} no-undo.
define variable b2-f-zakaz            as   decimal {&sum-format}  no-undo.
define variable b2-F-Center-stock     as   decimal {&sum-format}  no-undo.
define variable b2-F-avr              as   decimal {&sum-format}  no-undo.

define variable Bi-prih             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable Bi-rash             as   decimal EXTENT 6 {&sum-format} no-undo.
define variable Bi-kassa            as   decimal EXTENT 6 {&sum-format} no-undo.
define variable Bi-Inv              as   decimal EXTENT 6 {&sum-format} no-undo.
define variable Bi-Overturn         as   decimal EXTENT 6 {&sum-format} no-undo.
define variable bi-f-zakaz            as   decimal {&sum-format}  no-undo.
define variable bi-F-Center-stock     as   decimal {&sum-format}  no-undo.
define variable bi-F-avr              as   decimal {&sum-format}  no-undo.


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
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define BUFFER stk-line2 FOR ub.stk-line  .

define variable s#ret-str as char no-undo.

define WORK-TABLE temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int.

define shared  TEMP-TABLE temp#obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-name like ub.clients.grp-name
    Index byGR grp-name ASCENDING.

define TEMP-TABLE TMP#bs no-undo
    FIELD   b-code         LIKE gds-zap-b-code
    FIELD   Artic          LIKE gds-zap-artic
    FIELD   Prod-code      LIKE gds-zap-prod-code
    FIELD   Prod-type      LIKE gds-zap-prod-type
    FIELD   Prt-root       LIKE gds-zap-prt-root
    FIELD   Grp-name       LIKE gds-zap-grp-name
    FIELD   F-zakaz        LIKE ub.stk-tot.fact-qnty
    FIELD   F-center-stock LIKE ub.stk-tot.fact-qnty
    FIELD   Prih           like ub.stk-tot.fact-qnty
    FIELD   Ostatok-end    like ub.stk-tot.fact-qnty
    FIELD   f-avr          LIKE ub.stk-tot.fact-qnty
    FIELD   Kassa1         like ub.stk-tot.fact-qnty
    FIELD   Kassa2         like ub.stk-tot.fact-qnty
    FIELD   Kassa3         like ub.stk-tot.fact-qnty
    FIELD   Kassa4         like ub.stk-tot.fact-qnty
    FIELD   Kassa5         like ub.stk-tot.fact-qnty
    FIELD   Kassa6         like ub.stk-tot.fact-qnty
    FIELD   Ret-str        as   char    EXTENT 8

    INDEX By-B-code    B-code   ASCENDING
    INDEX By-Artic     Artic    ASCENDING
    INDEX By-Grp-Name  Grp-name ASCENDING
    INDEX Byf-Avr      F-avr    DESCENDING .

define variable     v#b-code         LIKE gds-zap-b-code no-undo.
define variable     v#artic          LIKE gds-zap-artic  no-undo.
define variable     v#prod-code      LIKE gds-zap-prod-code  no-undo.
define variable     v#prod-type      LIKE gds-zap-prod-type  no-undo.
define variable     v#prt-root       LIKE gds-zap-prt-root   no-undo.
define variable     v#grp-name       LIKE gds-zap-grp-name   no-undo.
define variable     v#F-zakaz        LIKE ub.stk-tot.fact-qnty           no-undo.
define variable     v#F-center-stock LIKE ub.stk-tot.fact-qnty     no-undo.
define variable     v#Prih           like ub.stk-tot.fact-qnty  no-undo.
define variable     v#ostatok-end    like ub.stk-tot.fact-qnty  no-undo.
define variable     v#f-avr          LIKE ub.stk-tot.fact-qnty              no-undo.
define variable     v#kASSA1         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa2         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa3         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa4         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa5         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa6         like ub.stk-tot.fact-qnty  no-undo.
define variable     V#ret-str        as   char    EXTENT 8    no-undo.
FUNCTION format-return  RETURNS decimal (INPUT orig as char ) .
define variable rtext AS CHARACTER no-undo .
define variable strt AS INTEGER no-undo .
define variable leng AS INTEGER no-undo .

Assign rtext = orig .
  leng = 1.
  strt =  index(rtext,'=').
  if strt = 0 then Return decimal(rtext).
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .

   strt =  index(rtext,'"').
  if strt > 0 then
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .


  strt =  index(rtext, v-delim).
  if strt > 0 then
     SUBSTRING(rtext,strt,leng,"CHARACTER") = "." .

  strt =  index(rtext,'"').
  if strt > 0 then
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .


Return decimal(rtext).
END FUNCTION.


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


    For each Temp#obj-list break by Temp#obj-list.grp-name:
        if last-of (Temp#obj-list.grp-name) THEN DO:
        s#ret-str = s#ret-str + {&tabulation}.
        END.
    End.


        For each obj-list share-lock :
           if NOT can-find (first Temp#obj-list where  Temp#obj-list.obj-code = obj-list.obj-code And
                                                       Temp#obj-list.obj-type = obj-list.obj-type)
             THEN DELETE obj-list no-error.
        End.
        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-flav.i }
{ rep/f-fdec.i }
PROCEDURE report-execute :
/*------------------------------------------------------------------------------
  Purpose: Сбор и выполнение отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

     { rep/r-val.i }

  run waitfram-show( {&mywaitmess} ) .
   output stream OutStream to value( string( session:temp-directory +
                            {&DF_Name} + string( g#report-num ) ) )      .

   run maket.
   run report-exec1.

  output stream outstream close.
  run waitfram-hide .
  {&closeexcel}

  run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt").

END PROCEDURE.
/*----------------------------------------------------------------------------------*/
PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose: Поиск по итогам по строкам документов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*   по 1 товару  */
 R = R + 1.
 { rep/r-mess.i R 10 }
  run clear-item.
  run zakaz. /* заказ */
  if not show-negativ  and  f-zakaz  = 0 then return.  /* Нулевые заказы */
 /* Остаток */

   run ob-line ( input   x-store-code,input   x-store-type,input   gds-zap-artic,input   gds-zap-prod-code ,
      INPUT   gds-zap-prod-type,
      INPUT   Fact-order-2,
      INPUT   Fact-order-2,
      input   {&arh-crsa} ,input   {&root-cat-id}, input   "", input   xTog-obj ,
      input   3 ,
      output  ostatok-end[1] ,
      output  ret-str[8] ) .


 /* Приход */
   run ob-line-1 ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code   ,
      INPUT   gds-zap-prod-type   ,
      INPUT   Fact-order-1,
      INPUT   Fact-order-2,
      input   {&arh-crsa}    ,  input   {&root-cat-id}, input   "", input   xTog-obj ,
      input   1 ,
      output prih[1] ,
      output ret-str[1]).
F-center-stock =  f-zakaz - prih[1].
/* Касса 1 */
   RUN ob-line-1 ( input   x-store-code   , input   x-store-type   , INPUT   gds-zap-artic       ,  INPUT   gds-zap-prod-code   ,      INPUT   gds-zap-prod-type   ,
      INPUT   Fo0,
      INPUT   Fo02,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xTog-obj ,
      input   2 ,
      output kassa[1] ,
      output ret-str[2]  ).
 if Showorders = false THEN DO:
/* Касса 2 */
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo1,
      input   fo12,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[2] ,
      output ret-str[3]  ).
/* Касса 3 */
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo2,
      input   fo22,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[3] ,
      output ret-str[4]  ).
/* Касса 4 */
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo3,
      input   fo32,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[4] ,
      output ret-str[5]  ).
/* Касса 5 */
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo4,
      input   fo42,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[5] ,
      output ret-str[6]  ).
/* Касса 6*/
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo5,
      input   fo52,
      input   {&arh-crsa}    ,   input   {&root-cat-id},   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[6] ,
      output ret-str[7]  ).
End.

   f-avr =  round(kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
     IF   f-zakaz  = 0 AND
          Prih[1] = 0 and
          kassa[1] = 0 and
          kassa[2] = 0 and
          kassa[3] = 0 and
          kassa[4] = 0 and
          kassa[5] = 0 and
          kassa[6] = 0 and
          ostatok-end[1] = 0
          THEN RETURN.  /* Пустая строка */
      rr = rr + 1 .
      run maketemptable  .
END PROCEDURE.

/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE print-header :
/*------------------------------------------------------------------------------
  Purpose: Печать шапки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if NOT FirstLine Then
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          {&PutExcel} "ПО ОБЪЕКТУ : " + CAPS(ObjName)  SKIP.
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
       run di ("bi", 1, "","ИТОГО","","","bi").
       END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
        END PROCEDURE.
PROCEDURE P-LINE :
        END PROCEDURE.
{ rep/obr-runn.i {1} no}
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
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
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
END PROCEDURE.
PROCEDURE display-Bi  :
END PROCEDURE.
PROCEDURE display-B1  :
END PROCEDURE.
PROCEDURE display-B2  :
END PROCEDURE.

PROCEDURE Clear-B1  :
 REPEAT kk = 1 to 6 :
 Assign
    b1-Prih           [kk]= 0
    b1-Rash           [kk]= 0
    b1-KAssa          [kk]= 0
    b1-Overturn       [kk]= 0
    b1-ostatok-end    [kk]= 0
    b1-ostatok-start  [kk]= 0
    b1-f-zakaz        = 0
    b1-F-Center-stock = 0
    b1-F-avr          = 0  .
   End.
   REPEAT kk = 1 to 8 :
     b1-ret-str[kk] = s#ret-str.
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

   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
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
   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
   End.

END PROCEDURE.

PROCEDURE Display-title :

    run rep/extitle.p (1) .
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
define output  parameter ret-str         as char  no-undo.

define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-First-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-Second-sum  like ub.stk-line.fact-qnty   no-undo.

  Assign First-sum = 0 Second-sum = 0 Temp-First-sum = 0 Temp-Second-sum = 0 ret-str = "".
  For EAch Temp#obj-list  no-lock BREAK by Temp#obj-list.grp-name :
      FIND LAST ub.stk-line where
                              ub.stk-line.artic         = x-artic
                        AND   ub.stk-line.fact-order   <= x-fact-order-2
                        AND   ub.stk-line.obj-code     = Temp#obj-list.obj-code
                        AND   ub.stk-line.obj-type     = Temp#obj-list.obj-type
                        AND   ub.stk-line.prod-code    = x-prod-code
                        AND   ub.stk-line.prod-type    = x-prod-type
                        AND   ub.stk-line.sum-type     = {&arh-crsa}
                        AND   ub.stk-line.cat-id       = {&root-cat-id}
                        USE-index category no-lock  no-error.

              if available ub.stk-LINE THEN Second-sum = Second-sum + ub.stk-line.fact-qnty.
              if available ub.stk-LINE THEN Temp-Second-sum = Temp-Second-sum + ub.stk-line.fact-qnty.

    if LAST-of (Temp#obj-list.grp-name) Then
      Assign ret-str = ret-str + excel-sum ( Temp-Second-sum )
             ret-str = ret-str + {&tabulation}
             Temp-First-sum  = 0
             Temp-Second-sum = 0.

   End.
   Quntity = Second-sum .

END PROCEDURE.
 { rep/ostatok.i }
/*----------------------------------------------------------------*/
PROCEDURE report-exec1  :
   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                               x-store-code = ub.clients.obj-code no-lock no-error.

           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
  run waitfram-show in this-procedure (objname) .

  run calcitog in this-procedure .
  run print-header in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */
  run run{1} in this-procedure .
  run printtemptable in this-procedure .
  run print-footer in this-procedure .
  END PROCEDURE.

/*-----------------------------------------------------------------------------------------*/
PROCEDURE Calc-Sub-itog :     /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.
define variable c as int no-undo.
define variable temp-sum1 as decimal no-undo .
define variable temp-sum2 as decimal no-undo .
define variable temp-sumi as decimal no-undo .
define variable temp-sum1# as decimal no-undo .
define variable temp-sum2# as decimal no-undo .
define variable temp-sumi# as decimal no-undo .

define variable ret-str-1 as character no-undo .
define variable ret-str-2 as character no-undo .
define variable ret-str-i as character no-undo .
define variable v-nn as integer   no-undo .

  b1-ostatok-end [1] =  b1-ostatok-end [1] + TMP#bs.ostatok-end.
  b2-ostatok-end [1] =  b2-ostatok-end [1] + TMP#bs.ostatok-end.
  bi-ostatok-end [1] =  bi-ostatok-end [1] + TMP#bs.ostatok-end.

  B1-Prih[1]    = B1-Prih[1]    + TMP#bs.Prih.
  B2-Prih[1]    = B2-Prih[1]    + TMP#bs.Prih .
  Bi-Prih[1]    = Bi-Prih[1]    + TMP#bs.Prih  .

  B1-f-zakaz    = B1-f-zakaz   + TMP#bs.f-zakaz.
  B2-f-zakaz    = B2-f-zakaz   + TMP#bs.f-zakaz.
  Bi-f-zakaz    = Bi-f-zakaz   + TMP#bs.f-zakaz.

  B1-F-Center-stock = B1-F-Center-stock  +  TMP#bs.F-Center-stock.
  B2-F-Center-stock = B2-F-Center-stock  +  TMP#bs.F-Center-stock.
  Bi-F-Center-stock = Bi-F-Center-stock  +  TMP#bs.F-Center-stock.

  B1-KAssa[1]    = B1-KAssa[1]   +  TMP#bs.KAssa1 .  B2-kassa[1]    = B2-kassa[1]   +  TMP#bs.kassa1 .  Bi-Kassa[1]    = Bi-Kassa[1]   +  TMP#bs.Kassa1 .
  B1-KAssa[2]    = B1-KAssa[2]   +  TMP#bs.KAssa2 .  B2-kassa[2]    = B2-kassa[2]   +  TMP#bs.kassa2 .  Bi-Kassa[2]    = Bi-Kassa[2]   +  TMP#bs.Kassa2 .
  B1-KAssa[3]    = B1-KAssa[3]   +  TMP#bs.KAssa3 .  B2-kassa[3]    = B2-kassa[3]   +  TMP#bs.kassa3 .  Bi-Kassa[3]    = Bi-Kassa[3]   +  TMP#bs.Kassa3 .
  B1-KAssa[4]    = B1-KAssa[4]   +  TMP#bs.KAssa4 .  B2-kassa[4]    = B2-kassa[4]   +  TMP#bs.kassa4 .  Bi-Kassa[4]    = Bi-Kassa[4]   +  TMP#bs.Kassa4 .
  B1-KAssa[5]    = B1-KAssa[5]   +  TMP#bs.KAssa5 .  B2-kassa[5]    = B2-kassa[5]   +  TMP#bs.kassa5 .  Bi-Kassa[5]    = Bi-Kassa[5]   +  TMP#bs.Kassa5 .
  B1-KAssa[6]    = B1-KAssa[6]   +  TMP#bs.KAssa6 .  B2-kassa[6]    = B2-kassa[6]   +  TMP#bs.kassa6 .  Bi-Kassa[6]    = Bi-Kassa[6]   +  TMP#bs.Kassa6 .

  B1-F-avr =  round(b1-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
  B2-F-avr =  round(b2-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
  Bi-F-avr =  round(bi-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .

  repeat   c = 1 to 8 :
      Assign
      Temp-sum1  = 0 ret-str-1 = ""
      Temp-sum2  = 0 ret-str-2 = ""
      Temp-sumi  = 0 ret-str-i = "" .
      v-nn = num-entries(tmp#bs.ret-str [c] , {&tabulation}) - 1 .
      repeat  b = 1 to v-nn :

          Temp-sum1# = format-return(entry(b,B1-Ret-str [c],{&tabulation})) no-error . if ERROR-STATUS :error then Temp-sum1# = 0.
          Temp-sum2# = format-return(entry(b,B2-Ret-str [c],{&tabulation})) no-error . if ERROR-STATUS :error then Temp-sum2# = 0.
          Temp-sumi# = format-return(entry(b,Bi-Ret-str [c],{&tabulation})) no-error . if ERROR-STATUS :error then Temp-sumi# = 0.

          Temp-sum1 = Temp-sum1# + format-return(entry(b,TMP#bs.Ret-str [c],{&tabulation})) no-error.
          Temp-sum2 = Temp-sum2# + format-return(entry(b,TMP#bs.Ret-str [c],{&tabulation})) no-error.
          Temp-sumi = Temp-sumi# + format-return(entry(b,TMP#bs.Ret-str [c],{&tabulation})) no-error.
          Assign
                 ret-str-1 = ret-str-1 + excel-sum((decimal(Temp-sum1) ))
                 ret-str-1 = ret-str-1 + {&tabulation}
                 ret-str-2 = ret-str-2 + excel-sum((decimal(Temp-sum2) ))
                 ret-str-2 = ret-str-2 + {&tabulation}
                 ret-str-i = ret-str-i + excel-sum((decimal(Temp-sumi) ))
                 ret-str-i = ret-str-i + {&tabulation}.
      End.
      b1-ret-str[c] =  ret-str-1.
      b2-ret-str[c] =  ret-str-2.
      bi-ret-str[c] =  ret-str-i.
  End.


END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 6:
 Assign
    prih                 [kk]    = 0
    rash                 [kk]    = 0
    kassa                [kk]    = 0
    Inv                  [kk]    = 0
    Overturn             [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
   B2-ret-str[kk] = s#ret-str.
   Bi-ret-str[kk] = s#ret-str.
   /*ret-str[kk] = s#ret-str.*/
   End.

 END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
      if par-4 = "goods":U  Then
                                assign
                                    gds-zap-prt-root   = ub.goods.prt-root
                                    gds-zap-prod-type  = ub.goods.prod-type
                                    gds-zap-prod-code  = ub.goods.prod-code
                                    gds-zap-artic      = ub.goods.artic
                                    gds-zap-grp-name   = ub.goods.grp-name
                                    gds-zap-b-code     = ub.goods.gds-code.

     if par-4 = "gds-list":U  Then
                                assign
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code.

          FIND FIRST ub.clients WHERE ub.clients.obj-type = gds-zap-prod-type AND
                                   ub.clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
                                   gds-zap-prod-name  = ub.clients.obj-name .

   if xtog-lavel = true  and  xLavel > 0 then
      gds-zap-grp-name = n-lavel(INPUT gds-zap-grp-name, Input xLavel ) .

   run foreach in this-procedure .

   Return error.
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
   WHEN "B1":U  Then
            run display-str-ex ( '' ,
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
                b1-KAssa      [6]  , "B1":U ).
   WHEN "B2":U  Then
             run display-str-ex ( '',
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
                b2-KAssa      [6]  , "B2":U ).

   WHEN "BI":U Then
             run display-str-ex ( '',
                ''                   ,
                p4                   ,
                bi-F-zakaz           ,
                bi-F-center-stock    ,
                bi-Prih          [1] ,
                bi-ostatok-end   [1] ,
                bi-f-avr             ,
                bi-kAssa       [1]   ,
                bi-KAssa         [2] ,
                bi-KAssa         [3] ,
                bi-KAssa         [4] ,
                bi-KAssa         [5] ,
                bi-KAssa         [6] , "BI":U).

   WHEN ""  Then
             run display-str-ex ( ':',
                ii                    ,
                p4                    ,
                F-zakaz               ,
                F-center-stock        ,
                Prih          [1]     ,
                ostatok-end   [1]     ,
                f-avr                 ,
                kASSA         [1]     ,
                KAssa         [2]     ,
                KAssa         [3]     ,
                KAssa         [4]     ,
                KAssa         [5]     ,
                KAssa         [6]    , "":U ).
       End case.
 END PROCEDURE.

procedure zakaz :
   F-zakaz = 0.
   For each Temp#obj-list :
   For each ub.trn-doc where
          ub.trn-doc.doc-date <= x-date-end
    AND   ub.trn-doc.doc-date >= x-date-start
    AND   ub.trn-doc.status_   = {&inquiry}
    AND   ub.trn-doc.internal  = false
    AND   ub.trn-doc.obj-code   = Temp#obj-list.obj-code
    AND   ub.trn-doc.obj-type   = Temp#obj-list.obj-type
     no-lock :
      For each ub.doc-line where
              ub.trn-doc.doc-code =  ub.doc-line.doc-code
        AND   ub.doc-line.obj-code   = Temp#obj-list.obj-code
        AND   ub.doc-line.obj-type   = Temp#obj-list.obj-type
        AND   ub.doc-line.prod-code  = gds-zap-prod-code
        AND   ub.doc-line.prod-type  = gds-zap-prod-type
        AND   ub.doc-line.status_    = {&inquiry}
        AND   ub.doc-line.artic      = gds-zap-artic    no-lock :
              F-zakaz = F-zakaz  +  ub.doc-line.doc-qnty   .
      End.
   End.
End.
End procedure.

Procedure maket :
/* Приход */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = /* {&arh-cgdt} + */  {&TDEDT_Pri_Vnesh}       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = /* {&arh-cgdt} + */  {&TDEDT_Pri_Perem}       temp#sum-type.xi = 1      .

/* Внутренний расход */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = /* {&arh-cgdt} + */ {&TDEDT_Ras_Perem}       temp#sum-type.xi = 1      .



/* касса */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  {&TDEDT_Ras_Vnesh_Kass}       temp#sum-type.xi = 2  .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  {&TDEDT_Vozvrat_Vnesh_Kass}   temp#sum-type.xi = 2  .

  if tog-voz then DO:
    Create temp#sum-type no-error.
    Assign temp#sum-type.sum-type =  {&TDEDT_Vozvrat_Vnesh}        temp#sum-type.xi = 2  .
  End.

/* Остатки */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = {&arh-crsa}  temp#sum-type.xi = 3  .


 End procedure.

Procedure Display-str-ex :
 define input parameter  p0  as char no-undo.
 define input parameter  p1  as char no-undo.
 define input parameter  p2  as char no-undo.
 define input parameter  p3  as decimal   no-undo.
 define input parameter  p4  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p5  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p6  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p7  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p8  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p9  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p10 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p11 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p12 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p13 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  B as char no-undo.
define variable v-nn as integer   no-undo .

 if p0 <> ':' THEN DO:
               {&PutExcel}
                p1   {&tabulation}
                p2   {&tabulation}
                excel-sum(p3)   {&tabulation}
                excel-sum(p4)   {&tabulation}
                excel-sum(p5)   {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[1])
                                ELSE string(bi-ret-str[1])
                excel-sum(p6)   {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[8])
                                ELSE string(bi-ret-str[8])
                excel-sum(p7)   {&tabulation}
                excel-sum(p8)   {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[2])
                                ELSE string(bi-ret-str[2])
                                .

                if Showorders = false THEN DO:
                {&putexcel}
                 excel-sum(p9)   {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[3])
                                ELSE string(bi-ret-str[3])
                 excel-sum(p10)  {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[4])
                                ELSE string(bi-ret-str[4])
                excel-sum(p11)  {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[5])
                                ELSE string(bi-ret-str[5])
                excel-sum(p12)  {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[6])
                                ELSE string(bi-ret-str[6])
                excel-sum(p13)  {&tabulation}
                 if b <> "BI":U THEN string(b1-ret-str[7])
                                ELSE string(bi-ret-str[7]) Skip.
                               End.
                  {&putexcel} Skip.
                 End.
               Else DO:
 define variable i as integer no-undo .
 qnty-orders = "".
if showorders = true then DO:
    v-nn = num-entries(Number-Orders) .
    repeat i = 1 to  v-nn :
    If entry(i,Number-Orders) <> ?
       and entry(i,Number-Orders) <> "."
       and entry(i,Number-Orders) <> ""
       and entry(i,Number-Orders) <> "0" Then DO:
      Find first ub.doc-line where
            entry(i,Number-Orders)    = ub.doc-line.doc-code
            AND   ub.doc-line.prod-code  = TMP#bs.prod-code
            AND   ub.doc-line.prod-type  = TMP#bs.prod-type
            AND   ub.doc-line.status_    = {&inquiry}
            AND   ub.doc-line.artic      = TMP#bs.artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                      (if avail ub.doc-line then
                      string(ub.doc-line.fact-qnty)  Else "0")  +  {&tabulation} .
     End.
    End.
 End.
 Else qnty-orders = "".

      {&PutExcel}
        p1   {&tabulation}
        p2   {&tabulation}
        excel-sum(p3)   {&tabulation}
        excel-sum(p4)   {&tabulation}
        excel-sum(p5)   {&tabulation}
        string(TMP#bs.ret-str[1])
        excel-sum(p6)   {&tabulation}
        string(TMP#bs.ret-str[8])
        excel-sum(p7)   {&tabulation}
        excel-sum(p8)   {&tabulation}
        string(TMP#bs.ret-str[2] )
        .
      if Showorders = false THEN DO:
      {&PutExcel}
        excel-sum(p9)   {&tabulation}
        string(TMP#bs.ret-str[3]  )
        excel-sum(p10)  {&tabulation}
        string(TMP#bs.ret-str[4])
        excel-sum(p11)  {&tabulation}
        string(TMP#bs.ret-str[5])
        excel-sum(p12)  {&tabulation}
        string(TMP#bs.ret-str[6])
        excel-sum(p13)  {&tabulation}
        string(TMP#bs.ret-str[7])
        Skip.
      End.
      if Showorders = true  THEN DO:
         {&PutExcel} qnty-orders       skip  .
      End.

      {&putexcel} Skip.
  End.

End procedure.
PROCEDURE Maketemptable :
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
    v#kASSA1        =  kASSA         [1]
    v#KAssa2        =  KAssa         [2]
    v#KAssa3        =  KAssa         [3]
    v#KAssa4        =  KAssa         [4]
    v#KAssa5        =  KAssa         [5]
    v#KAssa6        =  KAssa         [6]
    no-error.

     Repeat l = 1 to 8 :
       V#ret-str[l] = (ret-str[l]).
     End.

   Create TMP#bs no-error.
   run eqq no-error.

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
    TMP#bs.KAssa6        = v#KAssa6    no-error    .
     Repeat l = 1 to 8 :
       TMP#bs.ret-str[l] = v#ret-str[l] no-error.
     End.
END PROCEDURE.
/*----------------------------------------------------------------*/
PROCEDURE PrintTempTAble :
define variable i as int init 0  no-undo.

 Case RetClassify  :
  WHEN "no-classify":U then DO:
        For each TMP#bs   no-lock by
        (if xSorttype = "sort-code":U  THEN string(TMP#bs.b-code)
          ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
                ELSE  string( TMP#bs.f-avr,"-9999999999.999"))  :
                    i = i + 1 .

        If  Tog-Qnty = true   and  TMP#bs.f-avr = 0 then next.

        If  Tog-Qnty = true  and I <= xBSAmount Then DO:

             run display-line-tmp in this-procedure (i).  end.
        If  Tog-Qnty = false  Then  DO:

            run display-line-tmp in this-procedure (i). end.
        End.
    End.
/*-------------------------------------------------------------------------------------------------------------------*/
    when  "grp-goods":U then do:
      if xtog-lavel = false then do:
        For each TMP#bs where
        ( Tog-Qnty = false OR TMP#bs.f-avr <> 0 )
         no-lock  BREAK by TMP#bs.grp-name BY
        (if xSorttype = "sort-code":U  THEN string(TMP#bs.b-code)
          ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
                ELSE  string(TMP#bs.f-avr,"-9999999999.999"))  :
                    i = i + 1 .
            if First-of(TMP#bs.grp-name) then do:
              run sub-head in this-procedure (tmp#bs.grp-name).
              End.
            If  Tog-Qnty = true  and I <= xBSAmount Then  Run display-line-tMP(i).
            If  Tog-Qnty = false Then   Run display-line-tMP(i).
            if last-of(TMP#bs.grp-name) then do :
               i = 0.
               run sub-foot in this-procedure (tmp#bs.grp-name).
               End.
            End.
       end.
       else do:
        for each tmp#bs where
        ( tog-qnty = false or tmp#bs.f-avr <> 0 )
         no-lock  break
          by (n-lavel(tmp#bs.grp-name,xlavel))
          by str
          by (if xsorttype = "sort-code":u  then string(tmp#bs.b-code)
                                            else
                                              if xsorttype = "sort-artic":u
                                                 then tmp#bs.artic
                                                 else  string(tmp#bs.f-avr,"-9999999999.999"))  :
           str = n-lavel(input tmp#bs.grp-name, input xlavel ) .
           i = i + 1 .
            if First-of(str) then do:
              run sub-head in this-procedure (str).
              End.
            If  Tog-Qnty = true  and I <= xBSAmount Then  run display-line-tmp in this-procedure (i).
            If  Tog-Qnty = false Then   run display-line-tmp in this-procedure (i).
            if last-of(str) then do :
               i = 0.
               run sub-foot in this-procedure (str).
               End.
        end.
       end.
     end.
  End case.
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line-tMP :
define input parameter i as int no-undo.

run display-str-ex ( ':',
  i                     ,
  TMP#bs.artic          ,
  TMP#bs.F-zakaz        ,
  TMP#bs.F-center-stock ,
  TMP#bs.Prih           ,
  TMP#bs.ostatok-end    ,
  TMP#bs.f-avr          ,
  TMP#bs.kASSA1         ,
  TMP#bs.KAssa2         ,
  TMP#bs.KAssa3         ,
  TMP#bs.KAssa4         ,
  TMP#bs.KAssa5         ,
  TMP#bs.KAssa6
  , "":U).
run calc-sub-itog in this-procedure (0).
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE ob-line-1  :
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
define output  parameter ret-str         as char  no-undo.

define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-Second-sum  like ub.stk-line.fact-qnty   no-undo.
  if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
  Assign First-sum = 0 Second-sum = 0 Temp-First-sum = 0 Temp-Second-sum = 0 ret-str = "" .
  For each Temp#obj-list   no-lock BREAK by Temp#obj-list.grp-name :
    FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      For each  ub.ot-line where
                              ub.ot-line.artic         = x-artic
                        AND   ub.ot-line.fact-order   <= x-fact-order-2
                        AND   ub.ot-line.fact-order   >= x-fact-order-1

                        AND   ub.ot-line.obj-code     = Temp#obj-list.obj-code
                        AND   ub.ot-line.obj-type     = Temp#obj-list.obj-type
                        AND   ub.ot-line.prod-code    = x-prod-code
                        AND   ub.ot-line.prod-type    = x-prod-type
                        AND   ub.ot-line.sum-type     = {&arh-crsa}
                        AND   ub.ot-line.ext-doc-type = temp#sum-type.sum-type
                           no-lock  :
            Assign
            First-sum      = First-sum + ub.ot-line.fact-qnty
            Temp-First-sum = Temp-First-sum + ub.ot-line.fact-qnty.

      End.
    End.
    if LAST-of (Temp#obj-list.grp-name) Then
      Assign ret-str = ret-str + String(decimal(Temp-first-sum) )
             ret-str = ret-str + {&tabulation}
             Temp-First-sum  = 0 .
 End.
 Quntity = first-sum.
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
Procedure Sub-head :
define input parameter p1 as character no-undo .
  temp-str = string("ГРУППА : " + p1 ).
             {&PutExcel} temp-str format "X(100)" SKIP.
 End procedure.

Procedure Sub-Foot :
define input parameter p1 as character no-undo .
  temp-str = string("Итого по"+ {&tabulation} + " ГРУППА : " + p1 ).
  run di ("b1", 1, "Итого по",p1,"","","b1").
  run clear-b1.
 End procedure.


 procedure display-line :
  do
  on error undo, return error return-value
  :


  end. /* do */
 end procedure. /* display-line */
 /* $Workfile$ e n d */