/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Движение товара по месту хранени

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 11/01/01
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет о реализации товара ".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/waitfram.i }
{ rep/rep-bt.i   }
def input parameter x-store-code like ub.clients.obj-code   no-undo.
def input parameter x-store-type like ub.clients.obj-type   no-undo.
def input parameter x-base-type  like ub.currency.curr-abbr no-undo.
def input parameter x-base-code  like ub.currency.curr-code no-undo.

def input parameter xClassify  as char no-undo.
def input parameter xSortType  as char no-undo.
def input parameter xSumsOnly  as log  no-undo.
def input parameter xShowZero  as log  no-undo.
def input parameter xTog-obj   as log no-undo.
def input parameter  xtog-lavel as log no-undo.
def input parameter  xvar-lavel as int no-undo.
def input parameter  RS-1       as int no-undo.
def input parameter  max-amount as int no-undo.
def input parameter  max-amount-2 as int no-undo.
def input parameter  min-sum  as decimal  Format "->>>>>>>>>>>9.99" no-undo.
def input parameter  tog-kass as log no-undo.
def input parameter  tog-ras  as log no-undo.
def input parameter  tog-voz  as log no-undo.
def input parameter fo1    like ub.ot-tot.fact-order no-undo.
def input parameter fo12   like ub.ot-tot.fact-order no-undo.
def input parameter fo2    like ub.ot-tot.fact-order no-undo.
def input parameter fo22   like ub.ot-tot.fact-order no-undo.
def input parameter fo3    like ub.ot-tot.fact-order no-undo.
def input parameter fo32   like ub.ot-tot.fact-order no-undo.
def input parameter fo4    like ub.ot-tot.fact-order no-undo.
def input parameter fo42   like ub.ot-tot.fact-order no-undo.
def input parameter fo5    like ub.ot-tot.fact-order no-undo.
def input parameter fo52   like ub.ot-tot.fact-order no-undo.
def input parameter  tog-1  as log no-undo.

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define variable xBSAmount as int no-undo.
define variable tPrintRubl as log no-undo.

&glob TMP-CLASSIFY (if xClassify = "grp-goods":U Then TMP#bs.grp-name  Else "1":U )

def  stream  OutStream.
def  stream  OutStream2.
/*общий итог*/

def    var    ObjName           as   char no-undo.
dEF    VAR    Select-Good       as   integer no-undo.
DEF    VAR    ChosedType        as   integer no-undo.
DEF    VAR    PayType           as   integer no-undo.
DEF    VAR    RetClassify       as   char  no-undo.
DEF    VAR    RetSortType       as   char  no-undo.
DEF    VAR    Show-Negativ      as   logical  no-undo.
DEF    VAR    Sums-Only         as   logical  no-undo.
DEF    VAR    ValType           as   integer no-undo.
DEF    VAR    Line              as   char        no-undo.
DEF    VAR    FirstLine         as   logical     no-undo.


define variable proc#     as decimal  Format "->>>>>>>>>>>9.99"  no-undo.
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
define variable rid-list  as character no-undo .

define variable type-arh as character no-undo .

def  var gds-zap-unit-base     like ub.goods.unit-base     no-undo.
def  var gds-zap-prt-root      like ub.goods.prt-root     no-undo .
def  var gds-zap-gds-name      like ub.goods.gds-name     no-undo .
def  var gds-zap-prod-type     like ub.goods.prod-type    no-undo .
def  var gds-zap-prod-code     like ub.goods.prod-code    no-undo .
def  var gds-zap-artic         like ub.goods.artic        no-undo .
def  var gds-zap-b-code        like ub.bar-code.b-code    no-undo .
def  var gds-type              as char no-undo.
def  var gds-zap-type          like ub.goods.gds-type     no-undo .
def  var gds-zap-grp-name      like ub.goods.grp-name     no-undo .
def  var gds-zap-prod-name     like ub.clients.obj-name   no-undo .
def  var gds-zap-price-base    like ub.stk-line.sum-base no-undo.
def  var gds-zap-stoim-base    like ub.stk-line.sum-base no-undo.
def  var gds-zap-qnty          like ub.stk-line.fact-qnty no-undo.
def  var gds-zap-Nds           like ub.stk-line.VAT-base no-undo.
def  var gds-zap-Np            like ub.stk-line.SLT-base no-undo.
def  var v#r-qnty              as   decimal EXTENT 6 Format "->>>>>>>>>>>9.<<<" no-undo.
def  var v#r-Sum               as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<" no-undo.

def  var F-ostatok-start    as   char  no-undo.
def  var F-ostatok-End      as   char  no-undo.
def  var ostatok-start      as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var ostatok-End        as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var B1-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var B1-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var B2-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var B2-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var Bi-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
def  var Bi-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.


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

define variable  Q3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Q4    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.

define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
def BUFFER stk-line2 FOR ub.stk-line  .

def WORK-TABLE temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int.

def TEMP-TABLE TMP#bs no-undo
    FIELD   sub-artic      LIKE gds-zap-artic
    FIELD   b-code         LIKE gds-zap-b-code
    FIELD   artic          LIKE gds-zap-artic
    FIELD   gds-name       LIKE gds-zap-gds-name
    FIELD   prod-name      LIKE gds-zap-prod-name
    FIELD   prt-root       LIKE gds-zap-prt-root
    FIELD   grp-name       LIKE gds-zap-grp-name
    FIELD   r-qnty         LIKE ub.stk-tot.fact-qnty
    FIELD   r-qnty2         LIKE ub.stk-tot.fact-qnty
    FIELD   r-qnty3         LIKE ub.stk-tot.fact-qnty
    FIELD   r-qnty4         LIKE ub.stk-tot.fact-qnty
    FIELD   r-qnty5         LIKE ub.stk-tot.fact-qnty
    FIELD   r-qnty6         LIKE ub.stk-tot.fact-qnty
    FIELD   avr-qnty       LIKE ub.stk-tot.fact-qnty
    FIELD   r-sum          LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   r-sum2         LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   r-sum3         LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   r-sum4         LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   r-sum5         LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   r-sum6         LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    FIELD   avr-sum        LIKE ub.stk-tot.sum-base  Format "->>>>>>>>>>>9.99"
    INDEX Bysub-artic   sub-artic ASCENDING
    INDEX Byb-code      b-code ASCENDING
    INDEX Byartic       artic ASCENDING
    INDEX Bygds-name    gds-name ASCENDING
    INDEX Byr-qnty   IS  PRIMARY  r-qnty DESCENDING.

     { cus/vr-kass.i def }
     assign
        i=0
        xlavel = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        x-SelectObject = ""
        FirstLine     = FALSE.
        Line          = fill("-", {&DOS_CW_2}).

        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        Case RS-1 :
           when 1 then xBSAmount = 999999999 .
           when 2 then xBSAmount = max-amount.
           when 3 then xBSAmount = max-amount-2.
        End case.


  case  PayType :
      when 2 Then type-arh =   {&arh-csdt}.
      when 3 Then type-arh =   {&arh-sadt}.
      when 1 Then type-arh =   {&arh-cgdt}.
  End case.
{ rep/r-val.i }
        run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-flav.i }
{ rep/f-fdec.i }
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :

  run waitfram-show ( {&mywaitmess} ) .
  output stream OutStream to value( string( session:temp-directory +
                            {&DF_Name} + string( g#report-num ) ) )      .

   run maket .
   if xTog-obj /* раздельно по объектам */ Then DO:
            FOR each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                run report-exec1 .
            End.
                                               End.
  Else run report-exec1 .

  output stream outstream close.
  run waitfram-hide .
  {&CloseExcel}

  run rep/runexcel.p
      (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
END PROCEDURE.
/*----------------------------------------------------------------------------------*/
PROCEDURE foreach :
/*------------------------------------------------------------------------------
  Purpose: Поиск по итогам по строкам документов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* по 1 товару  */
 R = R + 1.
 { rep/r-mess.i R 10 }
 /* Реализация */
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output v#r-qnty[1] ,
      output v#r-sum[1]).
      assign    q4 = q4 + v#r-qnty[1]
                 coast4  = coast4  + v#r-sum[1] .

if tog-1 then do:
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fo1  ,
      input   fo12 ,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output v#r-qnty[2] ,
      output v#r-sum[2]).
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fo2  ,
      input   fo22 ,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output  v#r-qnty[3] ,
      output  v#r-sum[3]).
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fo3  ,
      input   fo32 ,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output  v#r-qnty[4] ,
      output  v#r-sum[4]).
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fo4  ,
      input   fo42 ,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output v#r-qnty[5] ,
      output v#r-sum[5]  ).
    run ob-line ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code,      input   gds-zap-prod-type   ,
      input   fo5  ,
      input   fo52 ,
      input   type-arh,  input   {&root-cat-id}, input   "" , input   xtog-obj ,  input   1 ,
      output v#r-qnty[6] ,
      output v#r-sum[6]  ).
END.


/* подсчет подитогов */
if  v#r-qnty[1] <> 0 then
 case rs-1 :
  when 1 then do :
        rr = rr + 1 .
            create tmp#bs .
            run eqq .
            q3 = q3 + tmp#bs.r-qnty .
            coast3 = coast3 + tmp#bs.r-sum .
         end.
  when 2  then do:
        rr = rr + 1 .
        if rr <= xbsamount then do:
            create tmp#bs.
            run eqq.
            q3 = q3 + tmp#bs.r-qnty .
            coast3 = coast3 + tmp#bs.r-sum .
            end.
            else do:
                  find first tmp#bs  use-index byr-qnty.
                  if available tmp#bs and absolute(v#r-qnty[1] ) > absolute(tmp#bs.r-qnty ) then do:
                      q3 = q3 - tmp#bs.r-qnty + v#r-qnty[1] .
                      coast3 = coast3 - tmp#bs.r-sum + v#r-sum[1] .
                      run eqq.
                      end.
            end.
         end.

  when 3 then do:
    if absolute(v#r-sum[1]) >= min-sum then do:
        rr = rr + 1 .
        if rr <= xbsamount then do:
            create tmp#bs.
            run eqq.
            q3 = q3 + tmp#bs.r-qnty .
            coast3 = coast3 + tmp#bs.r-sum .
            end.
            else do:
                  find last tmp#bs  use-index byr-qnty.
                  if available tmp#bs and absolute(v#r-qnty[1] ) < absolute(tmp#bs.r-qnty ) then do:
                      q3 = q3 - tmp#bs.r-qnty + v#r-qnty[1] .
                      coast3 = coast3 - tmp#bs.r-sum + v#r-sum[1] .
                      run eqq.
                      end.
            end.
        end.
     end.
 end case.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure display-line :
           ii = ii + 1.
           run display-str1.
  end procedure.

procedure display-str1 :
 end procedure.

/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure print-header :
/*------------------------------------------------------------------------------
  purpose: Печать шапки отчета
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
if not firstline then  run display-title.
    firstline = true .
    if xtog-obj and    x-selectobject <> "currency":u   then  do:
          {&putexcel}  "ПО ОБЪЕКТУ : " + caps(objname)  format "x(170)" skip.
          end.
           break_group = true.
           break_group1 = true.
   end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure print-footer :
/*------------------------------------------------------------------------------
  purpose: Печать итогов отчета
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
     /*последняя строка*/
 if (q4 - q3) <> 0 then do:
        run u-line.
        {&putexcel}                                                             {&tabulation}
        'ОСТАЛЬНЫЕ'                                                             {&tabulation}
        excel-qnty(decimal( ((q4 - q3) / q4 ) * 100    ))                   {&tabulation}
        excel-qnty(decimal( q4 - q3                    ))             {&tabulation}
        excel-sum(decimal ( coast4 - coast3            ))            {&tabulation}
        excel-qnty(decimal( (q4 - q3) / (integer(x-date-end - x-date-start) + 1 )    ))           {&tabulation}
        excel-sum(decimal ( (coast4 - coast3) / (integer(x-date-end - x-date-start) + 1 ) ))         skip.
 end.

        {&putexcel}
        '          ИТОГО'                                                   {&tabulation}
        'по всем товарам'                                                   {&tabulation}
        100                                                                 {&tabulation}
        excel-qnty(decimal(q4                                                    ))      {&tabulation}
        excel-sum (decimal(coast4                                                ))     {&tabulation}
        excel-qnty( decimal( q4 / (integer(x-date-end - x-date-start) + 1 )       ))       {&tabulation}
        excel-sum(decimal(coast4 / (integer(x-date-end - x-date-start) + 1 )   ))
        skip.
       end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
        END PROCEDURE.
/*-------------------------------*/
PROCEDURE P-LINE :
        END PROCEDURE.
/*-------------------------------*/
{ rep/obr-runn.i 1 {1}}
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
/* ---------------------------------------------------------------------------------------------------------------- */
/* номер последнего Fact-ordera и остатки на конец интервала  */
/* номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ    */
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj      ,

        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  Fact-order-2 ).
END PROCEDURE.

PROCEDURE Display-title :
    i=0.
    run rep/extitle.p (1) .
END PROCEDURE.

PROCEDURE ob-line  :
def input  parameter x-store-code     like clients.obj-code      no-undo.
def input  parameter x-store-type     like clients.obj-type      no-undo.
def INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
def INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
def INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
def INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
def INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
def input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
def input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
def input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
def input  parameter xTog-obj         as log no-undo.
def input  parameter xi               as int no-undo.

def output  parameter Quntity          like ub.stk-line.fact-qnty   no-undo.
def output  parameter Summa            like ub.stk-line.sum-rubl   no-undo.

define variable  First-qnty  like ub.stk-line.fact-qnty  no-undo.
define variable  Second-qnty like ub.stk-line.fact-qnty  no-undo.
define variable  First-sum   like ub.stk-line.sum-rubl   no-undo.
define variable  Second-sum  like ub.stk-line.sum-rubl   no-undo.

  Assign First-sum = 0 Second-sum = 0 First-qnty = 0 second-qnty = 0.
  For EAch obj-list
  where
       (xTog-obj = TRUE AND (x-store-type     = obj-list.obj-type  AND  x-store-code     = obj-list.obj-code ) )
       OR
       (xTog-obj = FAlse AND ( can-find (first gds-obj where
                                    gds-obj.obj-type = obj-list.obj-type    and
                                    gds-obj.obj-code = obj-list.obj-code    AND
                                    gds-obj.artic        = x-artic         AND
                                    gds-obj.prod-code    = x-prod-code     AND
                                    gds-obj.prod-type    = x-prod-type   No-lock use-index pi ) = TRUE ))
            no-lock  :

   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      FIND LAST ub.stk-line where
                              ub.stk-line.artic        = x-artic
                        AND   ub.stk-line.fact-order  <= x-fact-order-1
                        AND   ub.stk-line.obj-code     = obj-list.obj-code
                        AND   ub.stk-line.obj-type     = obj-list.obj-type
                        AND   ub.stk-line.prod-code    = x-prod-code
                        AND   ub.stk-line.prod-type    = x-prod-type
                        AND   ub.stk-line.sum-type     = temp#sum-type.sum-type
                        AND   ub.stk-line.cat-id       = {&root-cat-id}
                              no-lock use-index pi no-error.
           if available ub.stk-LINE THEN Assign First-qnty = First-qnty + ub.stk-line.fact-qnty
                                             First-sum = First-sum
                                                      + ( if tPrintRubl then              ub.stk-line.sum-rubl
                                                                                     else ub.stk-line.sum-base    )
                                                                                     .

      FIND LAST STK-line2 where
                              STK-line2.artic        = x-artic
                        AND   STK-line2.fact-order  <= x-fact-order-2
                        AND   STK-line2.obj-code     = obj-list.obj-code
                        AND   STK-line2.obj-type     = obj-list.obj-type
                        AND   STK-line2.prod-code    = x-prod-code
                        AND   STK-line2.prod-type    = x-prod-type
                        AND   STK-line2.sum-type     = temp#sum-type.sum-type
                        AND   STK-line2.cat-id       = {&root-cat-id}
                              no-lock use-index pi  no-error.
           if available STK-LINE2 THEN DO:
                                              Assign Second-qnty = Second-qnty + Stk-line2.fact-qnty
                                                     Second-sum  = Second-sum
                                                      + ( if tPrintRubl then              Stk-line2.sum-rubl
                                                                                     else Stk-line2.sum-base    )
                                                                                     .


                                               End.
    End.

   End.
   Assign
   Quntity = Second-qnty - first-qnty
   Summa   = Second-sum  - first-sum .

END PROCEDURE.
 { rep/ost-line.i {1} {1}}
 { rep/ostatok.i }
/*----------------------------------------------------------------*/
PROCEDURE report-exec1  :
fOR EACH TMP#bs SHARE-LOCK:
    DELETE TMP#bs.
END.
ASSIGN
 RR = 0
 Q3 = 0
 Q4 = 0
 cOAST3 = 0
 cOAST4 = 0.

   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
run waitfram-show(objname) .

  FORM with FRAME zapas .
  run calcitog.
  run print-header.
  run run1.
  /*
   CASE RetClassify :
      when "no-classify":u  then    run run1  in this-procedure .
      when "grp-goods":u then       run run2  in this-procedure .
   End case.
  */
  run printtemptable.
  run print-footer.
 END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
 def input parameter  par-3 as char no-undo.
 def input parameter  par-4 as char no-undo.
      if par-4 = "goods":U  Then
                                assign
                                    gds-zap-prt-root   = Goods.prt-root
                                    gds-zap-prod-type  = Goods.prod-type
                                    gds-zap-prod-code  = Goods.prod-code
                                    gds-zap-artic      = Goods.artic
                                    gds-zap-grp-name   = Goods.grp-name
                                    gds-zap-b-code     = Goods.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then Goods.engl-name
                                                                       else Goods.gds-name.

     if par-4 = "gds-list":U  Then
                                assign
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then Gds-list.engl-name
                                                                       else Gds-list.gds-name.

          FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND
                                   clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
                                   gds-zap-prod-name  = clients.obj-name .
   run foreach.
END PROCEDURE.
Procedure maket :
if tog-ras then DO:
/* расход */
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = type-arh + {&TDEDT_Ras_Vnesh}       temp#sum-type.xi = 1      .
End.

if tog-voz then DO:
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = type-arh + {&TDEDT_Vozvrat_Vnesh}   temp#sum-type.xi = 1      .
End.
/* касса */
if tog-kass then DO:
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = type-arh + {&TDEDT_Ras_Vnesh_Kass}       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = type-arh + {&TDEDT_Vozvrat_Vnesh_Kass}   temp#sum-type.xi = 1      .
  End.
 End procedure.


PROCEDURE Eqq :
define variable TTT like TMP#bs.grp-name no-undo.
   Assign
    TMP#bs.sub-artic     = SUBSTRING (gds-zap-artic,2,3)
    TMP#bs.b-code        =  gds-zap-b-code
    TMP#bs.artic         =  gds-zap-artic
    TMP#bs.gds-name      =  gds-zap-gds-name
    TMP#bs.prod-name     =  gds-zap-prod-name
    TMP#bs.prt-root      =  gds-zap-prt-root
    TMP#bs.r-qnty        =  v#r-qnty[1]
    TMP#bs.r-qnty2       =  v#r-qnty[2]
    TMP#bs.r-qnty3       =  v#r-qnty[3]
    TMP#bs.r-qnty4       =  v#r-qnty[4]
    TMP#bs.r-qnty5       =  v#r-qnty[5]
    TMP#bs.r-qnty6       =  v#r-qnty[6]
    TMP#bs.avr-qnty      =  v#r-qnty[1] / (Integer(x-date-end - x-date-start) + 1 )
    TMP#bs.r-sum         =  v#r-sUM[1]
    TMP#bs.r-sum2        =  v#r-sUM[2]
    TMP#bs.r-sum3        =  v#r-sUM[3]
    TMP#bs.r-sum4        =  v#r-sUM[4]
    TMP#bs.r-sum5        =  v#r-sUM[5]
    TMP#bs.r-sum6        =  v#r-sUM[6]
    TMP#bs.avr-sum       =  v#r-sum[1] / (Integer( x-date-end - x-date-start) + 1 )
     .
     TTT     =  IF  xtog-lavel = False THEN gds-zap-grp-name  Else  n-lavel(INPUT gds-zap-grp-name, Input xLavel ).
     TMP#bs.grp-name      =  TTT.
END PROCEDURE.


PROCEDURE PrintTempTable :
define variable i as int init 0  no-undo.
    For each TMP#bs  where TMP#bs.r-qnty <> 0
    Break by {&TMP-CLASSIFY}
    by
    (if xSorttype = "sort-code":U  THEN string(TMP#bs.b-code)
       ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
          ELSE if xSorttype = "sort-qunty":U  THEN string(( TMP#bs.r-qnty),"-9999999999.999")
             ELSE if xSorttype = "sort-name":U  THEN TMP#bs.gds-name
                   ELSE  TMP#bs.sub-artic ) :
                i = i + 1 .
                proc# = 100.

    if xClassify = "grp-goods":U Then DO:
       Accumulate Tmp#bs.r-qnty (TOTAL BY {&TMP-CLASSIFY}  ).
       Accumulate Tmp#bs.r-sum (TOTAL BY {&TMP-CLASSIFY}  ).

      If FIRST-OF( {&TMP-CLASSIFY} ) Then DO:
             {&PutExcel}    'Группа ' {&tabulation} TMP#bs.grp-name skip.
            END.

   End.
       {&PutExcel}
        TMP#bs.artic                  {&tabulation}
        TMP#bs.gds-name               {&tabulation}
        excel-qnty(decimal(( TMP#bs.r-qnty / Q4 ) * 100 )) {&tabulation}
        excel-qnty(decimal(TMP#bs.r-qnty                )) {&tabulation}
        excel-sum(decimal (TMP#bs.r-sum                 )) {&tabulation}
        excel-qnty(decimal(TMP#bs.avr-qnty              )) {&tabulation}
        excel-sum(decimal (TMP#bs.avr-sum               )) {&tabulation}
        if tog-1  then
         (excel-qnty(decimal(TMP#bs.r-qnty2 )) + {&tabulation} +
          excel-qnty(decimal(TMP#bs.r-sum2  )) + {&tabulation} +
          excel-sum(decimal (TMP#bs.r-qnty3 )) + {&tabulation} +
          excel-qnty(decimal(TMP#bs.r-sum3  )) + {&tabulation} +
          excel-sum(decimal (TMP#bs.r-qnty4 )) + {&tabulation} +
          excel-qnty(decimal(TMP#bs.r-sum4  )) + {&tabulation} +
          excel-qnty(decimal(TMP#bs.r-qnty5 )) + {&tabulation} +
          excel-sum(decimal (TMP#bs.r-sum5  )) + {&tabulation} +
          excel-qnty(decimal(TMP#bs.r-qnty6 )) + {&tabulation} +
          excel-sum(decimal (TMP#bs.r-sum6  )) + {&tabulation} )
        else ""
        skip.
     if xClassify = "grp-goods":U Then DO:
        IF LAST-OF( {&TMP-CLASSIFY}  )  THEN DO:
            {&PutExcel}
            'ИТОГО по группе :'  {&tabulation}
            TMP#bs.grp-name      {&tabulation}
            excel-qnty(decimal( ((ACCUM TOTAL BY {&TMP-CLASSIFY} Tmp#bs.r-qnty) / Q4 ) * 100                                )) {&tabulation}
            excel-qnty(decimal( ACCUM   TOTAL BY {&TMP-CLASSIFY} Tmp#bs.r-qnty                                              )) {&tabulation}
            excel-sum(decimal ( ACCUM   TOTAL BY {&TMP-CLASSIFY} Tmp#bs.r-sum                                               )) {&tabulation}
            excel-qnty(decimal( (ACCUM  TOTAL BY {&TMP-CLASSIFY} Tmp#bs.r-qnty) / (Integer(x-date-end - x-date-start) + 1 ) )) {&tabulation}
            excel-sum(decimal ( (ACCUM  TOTAL BY {&TMP-CLASSIFY} Tmp#bs.r-sum) /  (Integer(x-date-end - x-date-start) + 1 ) )) {&tabulation}
            skip.
        End.
     End.
    End.
    run u-line.
END PROCEDURE.
/*-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line-tMP :
def input parameter i as int no-undo.
END PROCEDURE.
/* $Workfile$ e n d */