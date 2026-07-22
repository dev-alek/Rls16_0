/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Шальнев Иван Сергеевич
Дата создания: 23/07/10
Author: Shalnev ivan
Creation date: 23/07/10

Creation date: 23/07/10 14:26

*/
{cmp/library.i}
{str/specattr.i}


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_contract-specif for ub.contract-specif.
define input parameter x-cont-code like contract.contract-code no-undo.

PROCEDURE Goods-start :

END PROCEDURE.


PROCEDURE Goods-end :

END PROCEDURE.


PROCEDURE display-line :
find first ub.contract-specif no-lock where
  ub.contract-specif.contract-num = x-cont-code                    and
  ub.contract-specif.gds-code     = temp-t-post-stk-line.gds-code  and
  ub.contract-specif.gds-name     = temp-t-post-stk-line.gds-name  and
  ub.contract-specif.artic        = temp-t-post-stk-line.artic     and
  ub.contract-specif.prod-type    = temp-t-post-stk-line.prod-type and
  ub.contract-specif.prod-code    = temp-t-post-stk-line.prod-code no-error.
if available ub.contract-specif then do :
      i = i + 1.
    { rep/r-mess.i i 10 }
    run clear-item.
    assign
      gds-zap-gds-name   = temp-t-post-stk-line.gds-name
      gds-zap-unit-base  = temp-t-post-stk-line.unit-base
      gds-zap-prt-root   = temp-t-post-stk-line.prt-root
      gds-zap-prod-type  = temp-t-post-stk-line.prod-type
      gds-zap-prod-code  = temp-t-post-stk-line.prod-code
      gds-zap-artic      = temp-t-post-stk-line.artic
      gds-zap-grp-name   = temp-t-post-stk-line.Goods-grp-name
      gds-zap-b-code     = temp-t-post-stk-line.gds-code
      gds-zap-type       = temp-t-post-stk-line.gds-type
      pos-cli-type       = temp-t-post-stk-line.Cli-type
      pos-cli-code       = temp-t-post-stk-line.Cli-code
      pos-cli-grp-name   = temp-t-post-stk-line.Clients-grp-name.
    run ob-line
    (temp-t-post-stk-line.obj-code    ,
      temp-t-post-stk-line.obj-type    ,
      temp-t-post-stk-line.cli-code    ,
      temp-t-post-stk-line.cli-type    ,
      temp-t-post-stk-line.artic       ,
      temp-t-post-stk-line.prod-code   ,
      temp-t-post-stk-line.prod-type   ,
      temp-t-post-stk-line.gds-code    ,
      ub.contract-specif.host-code     ,
      Fact-order-1     ,
      Fact-order-2     ,
      t#sum-type       ,
      t#cat-id         ,
      ""               ,
      yes) .
    run display-str1.
    run clear-item   in this-procedure .
end.
END PROCEDURE.


PROCEDURE display-str1  :
run di-qnty  ( "", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,"","").
/*run u-line.*/
run clear-item in this-procedure .
END PROCEDURE.

PROCEDURE p-line :
 underline stream outstream {&all-sym9}
  gds-zap-b-code
  gds-zap-artic
  gds-zap-gds-name
  F-bonus
  F-price-sale
  F-kassa
  F-bonus-dohod
  F-nacenka
  {&wfz}.
  {&frame-d} .
END PROCEDURE.


PROCEDURE Di :

END PROCEDURE.

PROCEDURE Di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
CASE CAPS ( p7) :
 WHEN  ""  Then DO :
  { rep/ex-obrt.i 'bonus' 'nex' }
  { rep/ex-obrt.i 'bonus' 'ex'  }
 End.
End case.
{&FRAME-d}.
END PROCEDURE.

PROCEDURE Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
run p-line.
END PROCEDURE.

PROCEDURE Clear-item :
define var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   v-bonus        [kk]  = 0
   v-price-sale   [kk]  = 0
   v-kassa        [kk]  = 0
   v-bonus-dohod  [kk]  = 0
   v-nacenka      [kk]  = 0
   s-kassa        [kk]  = 0
   s-bonus-dohod  [kk]  = 0
   s-nacenka      [kk]  = 0
   .
 End.
END PROCEDURE.

PROCEDURE ob-line :
define input  parameter x-store-code     like ub.clients.obj-code                no-undo.
define input  parameter x-store-type     like ub.clients.obj-type                no-undo.
define input  parameter x-cli-code       like ub.clients.obj-code                no-undo.
define input  parameter x-cli-type       like ub.clients.obj-type                no-undo.
define INPUT  parameter x-artic          like post-ot-line.artic              no-undo.
define INPUT  parameter x-prod-code      like post-ot-line.prod-code          no-undo.
define INPUT  parameter x-prod-type      like post-ot-line.prod-type          no-undo.
define input  parameter x-b-code         like temp-t-post-stk-line.gds-code   no-undo.
define input  parameter x-host-code      like ub.contract-specif.host-code    no-undo.
define INPUT  parameter x-Fact-order-1   like post-ot-line.Fact-order         no-undo.
define INPUT  parameter x-Fact-order-2   like post-ot-line.Fact-order         no-undo.
define input  parameter x-sum-type       like post-ot-line.sum-type           no-undo.
define input  parameter x-cat-id         like post-ot-line.cat-id             no-undo.
define input  parameter x-ext-doc-type   like post-ot-line.ext-doc-type       no-undo.
define input  parameter xTog-obj           as logical                         no-undo.
define        variable  bonus              as decimal                         no-undo.
define        variable  num-cont           as decimal                         no-undo.
define        variable  v-doc-num          as character                       no-undo.
define        variable  price-sale         as decimal                         no-undo.
define        variable  v-road-tax         as decimal                         no-undo.
define        variable  v-excise           as decimal                         no-undo.
FOR each post-ot-line where
        post-ot-line.artic        = x-artic
  and   post-ot-line.fact-order  <= x-fact-order-2
  and   post-ot-line.fact-order  >= x-fact-order-1
  and   post-ot-line.obj-code     = x-store-code
  and   post-ot-line.obj-type     = x-store-type
  and   post-ot-line.prod-code    = x-prod-code
  and   post-ot-line.prod-type    = x-prod-type
  and   post-ot-line.cli-code     = x-cli-code
  and   post-ot-line.cli-type     = x-cli-type
  and   post-ot-line.sum-type     = {&arh-sale}
  and   post-ot-line.cat-id       = x-cat-id
          no-lock :
  CASE post-ot-line.ext-doc-type:
  /* касса */
   WHEN       {&TDEDT_Ras_Vnesh_Kass}  OR
   WHEN       {&TDEDT_Vozvrat_Vnesh_Kass}
   THEN  DO :
    ASSIGN v-kassa[1] = v-kassa[1] - post-ot-line.sum-rubl
           v-kassa[2] = v-kassa[2] - post-ot-line.fact-qnty
          .
   End.
  End CASE.
END. /*FOR each post-ot-line*/

FOR each post-ot-line where
        post-ot-line.artic        = x-artic
  and   post-ot-line.fact-order  <= x-fact-order-2
  and   post-ot-line.fact-order  >= x-fact-order-1
  and   post-ot-line.obj-code     = x-store-code
  and   post-ot-line.obj-type     = x-store-type
  and   post-ot-line.prod-code    = x-prod-code
  and   post-ot-line.prod-type    = x-prod-type
  and   post-ot-line.cli-code     = x-cli-code
  and   post-ot-line.cli-type     = x-cli-type
  and   post-ot-line.sum-type     = {&arh-cost}
  and   post-ot-line.cat-id       = x-cat-id
          no-lock :

  CASE post-ot-line.ext-doc-type:
  /* касса */
   WHEN       {&TDEDT_Ras_Vnesh_Kass}  OR
   WHEN       {&TDEDT_Vozvrat_Vnesh_Kass}
   THEN  DO :
    ASSIGN
    v-kassa[3] = v-kassa[3] - post-ot-line.sum-rubl.
   End.
  End CASE.
END. /*FOR each post-ot-line*/

run read-bonus in this-procedure
  (input x-cont-code
  ,input x-host-code
  ,input x-b-code
  ,output bonus )
  .
v-bonus[1] = bonus.
  {gbl/bcodeprc.i
    x-store-type
    x-store-code
    x-b-code
    0
    0
    v-doc-num
    price-sale
    v-road-tax
    v-excise
  }
v-price-sale[1] = price-sale.
assign
  v-bonus-dohod[1] = ( v-price-sale[1] * v-kassa[2] ) * v-bonus[1] / 100
  v-nacenka[1] = ( v-kassa[1] - v-kassa[3] ) / v-kassa[1] * 100

  s-kassa[1] =  s-kassa[1] + v-kassa[1]
  s-bonus-dohod[1] =  s-bonus-dohod[1] + v-bonus-dohod[1]
  s-nacenka[1] = s-nacenka[1] + v-nacenka[1]
  .
find first tmp-itog where tmp-gds-code = x-b-code no-error.
if not available tmp-itog then do :
  create tmp-itog.
   assign
    tmp-itog.tmp-gds-code             = x-b-code
    tmp-itog.tmp-artic                = x-artic
    tmp-itog.tmp-gds-name             = temp-t-post-stk-line.gds-name
    tmp-itog.tmp-goods-grp-name       = temp-t-post-stk-line.goods-grp-name
    tmp-itog.tmp-clients-grp-name     = temp-t-post-stk-line.clients-grp-name
    tmp-itog.tmp-fact-order           = temp-t-post-stk-line.fact-order
    tmp-itog.tmp-prod-type            = temp-t-post-stk-line.prod-type
    tmp-itog.tmp-prod-code            = temp-t-post-stk-line.prod-code
    tmp-itog.tmp-cli-type             = temp-t-post-stk-line.cli-type
    tmp-itog.tmp-cli-code             = temp-t-post-stk-line.cli-code
    tmp-itog.tmp-prod-cli-obj-name    = temp-t-post-stk-line.prod-cli-obj-name
    tmp-itog.tmp-prod-cli-obj-type    = temp-t-post-stk-line.prod-cli-obj-type
    tmp-itog.tmp-prod-cli-obj-code    = temp-t-post-stk-line.prod-cli-obj-code
    tmp-itog.bn-col                   = 1
    tmp-itog.bonus                    = v-bonus[1]
    tmp-itog.sum-kassa                = s-kassa[1]
    tmp-itog.sum-bonus-dohod          = s-bonus-dohod[1]
    tmp-itog.sum-nacenka              = s-nacenka[1]
    .
end.
else do :
   assign
    tmp-itog.bn-col          = tmp-itog.bn-col + 1
    tmp-itog.sum-kassa       = tmp-itog.sum-kassa + s-kassa[1]
    tmp-itog.sum-bonus-dohod = tmp-itog.sum-bonus-dohod + s-bonus-dohod[1]
    tmp-itog.sum-nacenka     = tmp-itog.sum-nacenka + s-nacenka[1]
    .
end.
END PROCEDURE.


PROCEDURE U-LINE :
UNDERLINE stream OutStream  {&all-sym9}
  gds-zap-b-code
  gds-zap-artic
  gds-zap-gds-name
  F-bonus
  F-price-sale
  F-kassa
  F-bonus-dohod
  F-nacenka
  {&wFz} .
  {&FRAME-d}.
END PROCEDURE.

PROCEDURE display-str :
DISPLAY stream  OutStream  {&ALL-Sym9}
                tmp-itog.tmp-gds-code @  gds-zap-b-code
                tmp-itog.tmp-artic    @  gds-zap-artic
                tmp-itog.tmp-gds-name @  gds-zap-gds-name
                v-bonus[2]            @  F-bonus
                "----------------"    @  F-price-sale
                s-kassa[2]            @  F-kassa
                s-bonus-dohod[2]      @  F-bonus-dohod
                s-nacenka[2]          @  F-nacenka
                {&WFz} .
                {&FRAME-d}.

  {&PutExcel}   tmp-itog.tmp-gds-code   {&tabulation}
                tmp-itog.tmp-artic      {&tabulation}
                tmp-itog.tmp-gds-name   {&tabulation}
                v-bonus       [2] FORMAT ">>9.99"        +  {&tabulation}
                s-kassa       [2] FORMAT "->>>>>>>>9.99"  +  {&tabulation}
                s-bonus-dohod [2] FORMAT "->>>>>>>>9.99"  +  {&tabulation}
                s-nacenka     [2] FORMAT "->>9.99"        +  {&tabulation}
                {&new-line}.
END PROCEDURE.


PROCEDURE Goods-start-O :

END PROCEDURE.

PROCEDURE Goods-end-O :

END PROCEDURE.

Procedure Tmp-create :

END PROCEDURE.


Procedure Tmp-clear :

END PROCEDURE.

Procedure Tmp-assign :

END PROCEDURE.

/* $Workfile$ e n d */