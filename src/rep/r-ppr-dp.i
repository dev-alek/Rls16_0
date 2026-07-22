/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/20/01
*/

procedure Goods-start :
END PROCEDURE.

procedure Goods-end :
END PROCEDURE.

PROCEDURE display-line :
  i = i + 1.
  { rep/r-mess.i i 10 }
  run clear-item in this-procedure .
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
     run ob-line  in this-procedure
          (  temp-t-post-stk-line.gds-code,
             temp-t-post-stk-line.obj-code    ,
             temp-t-post-stk-line.obj-type    ,
             temp-t-post-stk-line.cli-code    ,
             temp-t-post-stk-line.cli-type    ,
             temp-t-post-stk-line.artic       ,
             temp-t-post-stk-line.prod-code   ,
             temp-t-post-stk-line.prod-type   ,
             Fact-order-1   ,
             Fact-order-2   ,
             t#sum-type     ,
             t#cat-id       ,
             ""             ,
             yes) .
   if Show-Sale or Show-Sale-vat Then  run ob-line  in this-procedure (
             temp-t-post-stk-line.gds-code    ,
             temp-t-post-stk-line.obj-code    ,
             temp-t-post-stk-line.obj-type    ,
             temp-t-post-stk-line.cli-code    ,
             temp-t-post-stk-line.cli-type    ,
             temp-t-post-stk-line.artic       ,
             temp-t-post-stk-line.prod-code   ,
             temp-t-post-stk-line.prod-type   ,
             Fact-order-1   ,
             Fact-order-2   ,
             {&arh-Sale}    ,
             {&single-cat-id} ,
             ""             ,
             yes) .
         run calc-sub-itog in this-procedure  ( 0 ).
            if Show-Sale Then run calc-sub-itog in this-procedure ( 3 ).
         /* IF  NOT  ( NOT Show-Negativ  AND  (
                                       Prih         [1] = 0  AND
                                       RAsh         [1] = 0  AND
                                       KAssa        [1] = 0  AND
                                       Inv          [1] = 0  AND
                                       vzvr         [1] = 0  AND
                                       vzvr-post    [1] = 0
                                       )) then DO: */

           IF NOT Sums-Only then DO:
              run display-str1 in this-procedure .
           End.
         /* end. */
         /* run clear-item. */
  END PROCEDURE.

PROCEDURE display-str1  :
     run di-qnty ( "кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if show-cost        then do: run di ( "учет."  , 2 , "","", "", "", "":u).  end.
         if show-cost-vat    then do: run di ( "уч.НДС" , 3 , "","", "", "", "":u).  end.
         if show-sale        then do: run di ( "док-т." , 5 , "","", "", "", "":u).  end.
         if show-sale-vat    then do: run di ( "д. НДС" , 6 , "","", "", "", "":u).  end.
END PROCEDURE.

PROCEDURE Di :
def input parameter p1 as char no-undo.
def input parameter p2 as int no-undo.
def input parameter p3 as char no-undo.
def input parameter p4 as char no-undo.
def input parameter p5 as char no-undo.
def input parameter p6 as char no-undo.
def input parameter p7 as char no-undo.
 CASE CAPS ( p7) :
   WHEN "P":U  Then
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< p-  }
   WHEN "O":U  Then
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< o-  }
   WHEN "B1":U  Then
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< b1-  }
   WHEN "B2":U  Then
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< b2-  }
   WHEN "BI":U Then
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< bi-  }
   WHEN ""  Then DO:
             { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>>9.<<     }
              End.
   End case.
               {&FRAME-d}.
 END PROCEDURE.
PROCEDURE Di-qnty :
def input parameter p1 as char no-undo.
def input parameter p2 as int no-undo.
def input parameter p3 as char no-undo.
def input parameter p4 as char no-undo.
def input parameter p5 as char no-undo.
def input parameter p6 as char no-undo.
def input parameter p7 as char no-undo.
 CASE CAPS ( p7) :
   WHEN "P":U  Then DO :
              { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< p-}
              { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< p-}
                End.
   WHEN "O":U  Then DO :
             { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< o-}
             { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< o-}
             End.
   WHEN "B1":U  Then DO :
              { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< b1-}
              { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< b1-}
                End.
   WHEN "B2":U  Then DO :
             { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< b2-}
             { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< b2-}
             End.

   WHEN "BI":U Then  DO :
             { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< bi-}
             { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< bi-}
             End.
   WHEN ""  Then     DO :
              { rep/di-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< }
              { rep/ex-obrt.i 'oborot-pri'  ->>>>>>>>>>>9.<<< }
              End.
   End case.
               {&FRAME-d}.
 END PROCEDURE.


PROCEDURE Clear-item :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
    prih             [kk]  = 0
    rash             [kk]  = 0
    kassa            [kk]  = 0
    Inv              [kk]  = 0
    vzvr-post        [kk]  = 0
    vzvr             [kk]  = 0
    sm               [kk]  = 0
    spis             [kk]  = 0 .
       End.
 END PROCEDURE.


PROCEDURE ob-line :
def input  parameter x-gds-code     like goods.gds-code     no-undo.
def input  parameter x-store-code   like ub.clients.obj-code     no-undo.
def input  parameter x-store-type   like ub.clients.obj-type     no-undo.
def input  parameter x-cli-code     like ub.clients.obj-code     no-undo.
def input  parameter x-cli-type     like ub.clients.obj-type     no-undo.
def INPUT  parameter x-artic        like post-ot-line.artic        no-undo.
def INPUT  parameter x-prod-code    like post-ot-line.prod-code    no-undo.
def INPUT  parameter x-prod-type    like post-ot-line.prod-type    no-undo.
def INPUT  parameter x-Fact-order-1   like post-ot-line.Fact-order   no-undo.
def INPUT  parameter x-Fact-order-2   like post-ot-line.Fact-order   no-undo.
def input  parameter x-sum-type       like post-ot-line.sum-type     no-undo.
def input  parameter x-cat-id         like post-ot-line.cat-id       no-undo.
def input  parameter x-ext-doc-type   like post-ot-line.ext-doc-type no-undo.
def input  parameter xTog-obj           as log no-undo .
def var  tt#          as   int                 no-undo .
def var tt-cost like  ub.gds-dtl.price-rubl no-undo .
def var tt-sale like  ub.gds-dtl.price-rubl no-undo .

define buffer a-supp         for ub.ot-supp-line .
define buffer buf_parts-attr for ub.parts-attr .

 if x-sum-type = {&arh-cost}   then tt# = 0.
 if x-sum-type = {&arh-sale}   then tt# = 3.
 if x-sum-type = {&arh-crsa}   then tt# = 6.

     FOR each post-ot-line where
              post-ot-line.artic        = x-artic
        AND   post-ot-line.fact-order  <= x-fact-order-2  AND   post-ot-line.fact-order  >= x-fact-order-1
        AND   post-ot-line.obj-code     = x-store-code
        AND   post-ot-line.obj-type     = x-store-type
        AND   post-ot-line.prod-code    = x-prod-code
        AND   post-ot-line.prod-type    = x-prod-type
        AND   post-ot-line.cli-code     = x-cli-code
        AND   post-ot-line.cli-type     = x-cli-type
        AND   post-ot-line.sum-type     = x-sum-type
        AND   post-ot-line.cat-id       = x-cat-id
        and   post-ot-line.ext-doc-type  =  {&TDEDT_Pri_Vnesh}
        no-lock :

         /* приход */
           ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  post-ot-line.fact-qnty
                  prih[2 + tt#]   = prih[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  prih[3 + tt#]   = prih[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 .
     End.
     FOR each post-ot-line where
              post-ot-line.artic        = x-artic
        AND   post-ot-line.fact-order  <= fact-order-4  AND   post-ot-line.fact-order  >= fact-order-3
        AND   post-ot-line.obj-code     = x-store-code
        AND   post-ot-line.obj-type     = x-store-type
        AND   post-ot-line.prod-code    = x-prod-code
        AND   post-ot-line.prod-type    = x-prod-type
        AND   post-ot-line.cli-code     = x-cli-code
        AND   post-ot-line.cli-type     = x-cli-type
        AND   post-ot-line.sum-type     = x-sum-type
        AND   post-ot-line.cat-id       = x-cat-id
        and   post-ot-line.ext-doc-type <> {&TDEDT_Pri_Vnesh}
        no-lock :
        /* по партиям */
         /* message x-sum-type  post-ot-line.doc-code. */
        For each ub.parts no-lock where
                   ub.parts.artic      =  post-ot-line.artic
              AND  ub.parts.prod-code  =  post-ot-line.prod-code
              AND  ub.parts.prod-type  =  post-ot-line.prod-type
              AND  ub.parts.supp-code  =  post-ot-line.cli-code
              AND  ub.parts.supp-type  =  post-ot-line.cli-type
              AND  ub.parts.obj-code   =  post-ot-line.obj-code
              AND  ub.parts.obj-type   =  post-ot-line.obj-type
              AND  ub.parts.out-code   =  post-ot-line.doc-code
              and  ub.parts.out-code   <>  ub.parts.in-code

              ,
       first buf_parts-attr no-lock where
              buf_parts-attr.in-code   = ub.parts.in-code
          and buf_parts-attr.gds-code  = x-gds-code
          and buf_parts-attr.part-code = ub.parts.part-code        ,
       first a-supp no-lock  where
            a-supp.doc-code     = buf_parts-attr.income-in-code and
            a-supp.artic        = x-artic        and
            a-supp.fact-order  <= fact-order-2   AND
            a-supp.fact-order  >= fact-order-1   and
            a-supp.obj-code     = x-store-code   and
            a-supp.obj-type     = x-store-type   and
            a-supp.prod-code    = x-prod-code    and
            a-supp.prod-type    = x-prod-type    and
            a-supp.cli-code     = x-cli-code     and
            a-supp.cli-type     = x-cli-type     and
            a-supp.sum-type     = x-sum-type     and
            a-supp.cat-id       = x-cat-id      and
             (  a-supp.ext-doc-type = {&TDEDT_Pri_Vnesh}  or
                a-supp.ext-doc-type = {&TDEDT_Inv}        or
                a-supp.ext-doc-type = {&TDEDT_Peresort}      )                 :
              if tt# = 0  then DO: /* cost */ end.
              if tt# = 3  then DO: /* sale */ end.
              if tt# = 6  then DO: /* crsa */ end.
              /*
              message post-ot-line.ext-doc-type    skip
                      ub.parts.out-code  skip
                      ub.parts.in-code   skip
                      ub.parts.fact-qnty skip
                      a-supp.doc-code skip
                      a-supp.ext-doc-type

                      .
                      */
        CASE post-ot-line.ext-doc-type:
        /* разбивка по типам документов */
        /* возврат */
             WHEN         {&TDEDT_Vozvrat_Vnesh}      THEN DO :
           ASSIGN vzvr[1 + tt#]   = vzvr[1 + tt#]   +  ub.parts.fact-qnty
                  vzvr[2 + tt#]   = vzvr[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.sum-rubl else   ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.sum-base
                  vzvr[3 + tt#]   = vzvr[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.vat-rubl else   ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.vat-base  .
                 End.

        /* возврат пост*/
             WHEN       {&TDEDT_RAS_Vnesh_VP}    Then DO:
           ASSIGN vzvr-post[1 + tt#]   = vzvr-post[1 + tt#]   +  ub.parts.fact-qnty
                  vzvr-post[2 + tt#]   = vzvr-post[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.sum-base
                  vzvr-post[3 + tt#]   = vzvr-post[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.vat-rubl else   ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.vat-base  .
                  End.
        /* расход */
             WHEN       {&TDEDT_Ras_Vnesh}       THEN  DO:
           ASSIGN rash[1 + tt#]   = rash[1 + tt#]   +  ub.parts.fact-qnty
                  rash[2 + tt#]   = rash[2 + tt#]   +  if tprintrubl then   ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-base
                  rash[3 + tt#]   = rash[3 + tt#]   +  if tprintrubl then   ( ub.parts.fact-qnty / post-ot-line.fact-qnty) * post-ot-line.vat-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-base  .
                 End.
        /* списание */
             WHEN      {&TDEDT_Spi_Vnesh}       THEN  DO:
           ASSIGN spis[1 + tt#]   = spis[1 + tt#]   +  ub.parts.fact-qnty
                  spis[2 + tt#]   = spis[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-base
                  spis[3 + tt#]   = spis[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-base  .
                 End.

       /* касса */
             WHEN       {&TDEDT_Ras_Vnesh_Kass}  OR
             WHEN       {&TDEDT_Vozvrat_Vnesh_Kass} THEN  DO:
           ASSIGN kassa[1 + tt#]   = kassa[1 + tt#]   +  ub.parts.fact-qnty
                  kassa[2 + tt#]   = kassa[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-base
                  kassa[3 + tt#]   = kassa[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-base .
                 End.
      /* инвентаризация */
             when       {&tdedt_inv}              or
             when       {&tdedt_peresort}         or
             when       {&tdedt_corr_acc_price}   or
             when       {&tdedt_corr_minus_parts} then  do:
             /* message ub.parts.fact-qnty  a-supp.ext-doc-type . */
           ASSIGN INV[1 + tt#]   = INV[1 + tt#]   +  ub.parts.fact-qnty
                  inv[2 + tt#]   = inv[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-base
                  Inv[3 + tt#]   = Inv[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-base  .
                 End.
          WHEN   {&TDEDT_Chg_Purch_Code}      THEN  DO:
           ASSIGN sm[1 + tt#]   = sm[1 + tt#]   +  ub.parts.fact-qnty
                  sm[2 + tt#]   = sm[2 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.sum-base
                  sm[3 + tt#]   = sm[3 + tt#]   +  if tprintrubl then  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-rubl else  ( ub.parts.fact-qnty / post-ot-line.fact-qnty) *  post-ot-line.vat-base  .
             end.
          End CASE.
     End.
   End.

END PROCEDURE.
PROCEDURE Calc-Sub-itog :                                            /* подсчет под итогов */
def input parameter tt as int no-undo.
def var b as int init 0 no-undo.
repeat b = 1 to 3 :
  Assign
  B1-sm[b + TT]    = B1-sm[b + TT]    +  sm[b + TT]
  B2-sm[b + TT]    = B2-sm[b + TT]    +  sm[b + TT]
  Bi-sm[b + TT]    = Bi-sm[b + TT]    +  sm[b + TT]
   p-sm[b + TT]    =  p-sm[b + TT]    +  sm[b + TT]
   o-sm[b + TT]    =  o-sm[b + TT]    +  sm[b + TT]

  B1-Prih[b + TT]    = B1-Prih[b + TT]    +  Prih[b + TT]
  B2-Prih[b + TT]    = B2-Prih[b + TT]    +  Prih[b + TT]
  Bi-Prih[b + TT]    = Bi-Prih[b + TT]    +  Prih[b + TT]
  p-Prih[b + TT]     = p-Prih[b + TT]     +  Prih[b + TT]
  o-Prih[b + TT]     = o-Prih[b + TT]     +  Prih[b + TT]

  B1-RAsh[b + TT]    = B1-RAsh[b + TT]    +  RAsh[b + TT]
  B2-RAsh[b + TT]    = B2-RAsh[b + TT]    +  RAsh[b + TT]
  Bi-RAsh[b + TT]    = Bi-RAsh[b + TT]    +  RAsh[b + TT]
  p-RAsh[b + TT]     = p-RAsh[b + TT]      +  RAsh[b + TT]
  o-RAsh[b + TT]     = o-RAsh[b + TT]      +  RAsh[b + TT]

  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT]
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT]
  Bi-kassa[b + TT]    = Bi-kassa[b + TT]     +  kassa[b + TT]
  p-kassa[b + TT]     = p-kassa[b + TT]      +  kassa[b + TT]
  o-kassa[b + TT]     = o-kassa[b + TT]      +  kassa[b + TT]

  B1-Inv[b + TT]    = B1-Inv[b + TT]    +  Inv[b + TT]
  B2-Inv[b + TT]    = B2-Inv[b + TT]    +  Inv[b + TT]
  Bi-Inv[b + TT]    = Bi-Inv[b + TT]    +  Inv[b + TT]
  p-Inv[b + TT]    = p-Inv[b + TT]    +  Inv[b + TT]
  o-Inv[b + TT]    = o-Inv[b + TT]    +  Inv[b + TT]

  B1-vzvr[b + TT]    = B1-vzvr[b + TT]    + vzvr[b + TT]
  B2-vzvr[b + TT]    = B2-vzvr[b + TT]    + vzvr[b + TT]
  Bi-vzvr[b + TT]    = Bi-vzvr[b + TT]    + vzvr[b + TT]
  p-vzvr[b + TT]    = p-vzvr[b + TT]    + vzvr[b + TT]
  o-vzvr[b + TT]    = o-vzvr[b + TT]    + vzvr[b + TT]

  B1-vzvr-post[b + TT]    = B1-vzvr-post[b + TT]    + vzvr-post[b + TT]
  B2-vzvr-post[b + TT]    = B2-vzvr-post[b + TT]    + vzvr-post[b + TT]
  Bi-vzvr-post[b + TT]    = Bi-vzvr-post[b + TT]    + vzvr-post[b + TT]
  p-vzvr-post[b + TT]    = p-vzvr-post[b + TT]    + vzvr-post[b + TT]
  o-vzvr-post[b + TT]    = o-vzvr-post[b + TT]    + vzvr-post[b + TT]
.
End.
END PROCEDURE.


PROCEDURE U-LINE :
UNDERLINE stream OutStream  {&ALL-Sym} sym13
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-vzvr
        F-vzvr-post
        F-spis
        F-sm
        {&wFz} .
        {&FRAME-d}.
        END PROCEDURE.


procedure Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
    if Nx = 1 Then DO:
         run di-qnty  ( "кол-во", 1,"","Итого по : ",trim ( name),"","b1").
         if show-cost then do :     run di  (  "учет." , 2, "","","","","b1" ).  end.
         if show-cost-vat then do : run di  (  "уч.НДС", 3, "","","","","b1" ).  end.
         if show-sale then do :     run di  (  "док-т.", 5, "","","","","b1" ).  end.
         if show-sale-vat then do : run di  (  "д. НДС", 6, "","","","","b1" ).  end.
         if not sums-only then run u-line.
         run clear-itemb1-.
         end.
 if nx = 2 then do:
         run di-qnty  ( "кол-во", 1,"","","Итого по : " + trim ( name),"","b2").
         if show-cost then do :      run di  (  "учет." , 2, "","","","","b2" ).  end.
         if show-cost-vat  then do : run di  (  "уч.НДС", 3, "","","","","b2" ).  end.
         if show-sale then do :      run di  (  "док-т.", 5, "","","","","b2" ).  end.
         if show-sale-vat  then do : run di  (  "д. НДС", 6, "","","","","b2" ).  end.
         if not sums-only then run u-line.
         run clear-itemb2-.
        end.
 if nx = 3 then do:
         if not sums-only then run u-line.
         run di-qnty  ( "кол-во", 1,"","Итого по пост-ку" , trim ( name),"","p").
         if show-cost then do :      run di  (  "учет." , 2, "","","","","p" ).  end.
         if show-cost-vat  then do : run di  (  "уч.НДС", 3, "","","","","p" ).  end.
         if show-sale then do :      run di  (  "док-т.", 5, "","","","","p" ).  end.
         if show-sale-vat  then do : run di  (  "д. НДС", 6, "","","","","p" ).  end.
         if not sums-only then run u-line.
         run clear-itemp-.
          end.
 if nx = 0 then do:
         run di-qnty  ( "кол-во", 1,"","Итого  объект: " , trim ( name),"","o").
         if show-cost then do :      run di  (  "учет." , 2, "","","","","o" ).  end.
         if show-cost-vat  then do : run di  (  "уч.НДС", 3, "","","","","o" ).  end.
         if show-sale then do :      run di  (  "док-т.", 5, "","","","","o" ).  end.
         if show-sale-vat  then do : run di  (  "д. НДС", 6, "","","","","o" ).  end.
         if not sums-only then run u-line.
         run clear-itemo-.
          end.
 END PROCEDURE.


PROCEDURE Clear-itemb1- :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b1-prih             [kk]  = 0
   b1-rash             [kk]  = 0
   b1-kassa            [kk]  = 0
   b1-Inv              [kk]  = 0
   b1-vzvr             [kk]  = 0
   b1-vzvr-post        [kk]  = 0
   b1-sm        [kk]  = 0
   .
       End.
 END PROCEDURE.


PROCEDURE Clear-itemb2- :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b2-prih             [kk]  = 0
   b2-rash             [kk]  = 0
   b2-kassa            [kk]  = 0
   b2-Inv              [kk]  = 0
   b2-vzvr             [kk]  = 0
   b2-vzvr-post        [kk]  = 0
   b2-sm        [kk]  = 0
   .
   End.
 END PROCEDURE.
PROCEDURE Clear-itemp- :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   p-prih             [kk]  = 0
   p-rash             [kk]  = 0
   p-kassa            [kk]  = 0
   p-Inv              [kk]  = 0
   p-vzvr             [kk]  = 0
   p-vzvr-post        [kk]  = 0
   p-sm               [kk]  = 0
   .
   End.
 END PROCEDURE.


PROCEDURE Clear-itemo- :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   o-prih             [kk]  = 0
   o-rash             [kk]  = 0
   o-kassa            [kk]  = 0
   o-Inv              [kk]  = 0
   o-vzvr             [kk]  = 0
   o-vzvr-post        [kk]  = 0
   o-sm        [kk]  = 0
   .
   End.
 END PROCEDURE.
/*-------------------------------------------------для объекты раздельно-------------------------------------------------*/
Procedure Tmp-create :
define input parameter p1   like ub.clients.obj-code  no-undo .
define input parameter p2   like ub.clients.obj-type  no-undo .
define input parameter Name like ub.clients.obj-name  no-undo .
define input parameter p3   like obj-list.obj-code no-undo .
define input parameter p4   like obj-list.obj-type no-undo .
  Create tmp-cli-gds.
 def var kk as int no-undo.
 REPEAT kk = 1 to 9 :
   Assign
      tmp-cli-gds.p-prih[kk]           = p-prih[kk]
      tmp-cli-gds.p-rash[kk]           = p-rash[kk]
      tmp-cli-gds.p-kassa[kk]          = p-kassa[kk]
      tmp-cli-gds.p-Inv[kk]            = p-Inv[kk]
      tmp-cli-gds.p-spis[kk]           = p-spis[kk]
      tmp-cli-gds.p-vzvr[kk]           = p-vzvr[kk]
      tmp-cli-gds.p-vzvr-post[kk]      = p-vzvr-post[kk]
      tmp-cli-gds.p-sm[kk]             = p-sm[kk]
      .
 end.
      assign
      tmp-cli-gds.cli-code         = p1
      tmp-cli-gds.cli-type         = p2
      tmp-cli-gds.Name             = Name
      tmp-cli-gds.obj-code         = p3
      tmp-cli-gds.obj-type         = p4
      .
 END PROCEDURE.


Procedure Tmp-clear :
 def var kk as int no-undo.
 REPEAT kk = 1 to 9 :
 Assign
     p-prih[kk]          = 0
     p-rash[kk]          = 0
     p-kassa[kk]         = 0
     p-Inv[kk]           = 0
     p-spis[kk]          = 0
     p-vzvr[kk]          = 0
     p-vzvr-post[kk]     = 0
     p-sm[kk]     = 0
    .
    end.

END PROCEDURE.


Procedure Tmp-assign :
 def var kk as int no-undo.
 REPEAT kk = 1 to 9 :
    Assign
    p-prih[kk]           = p-prih[kk]            + tmp-cli-gds.p-prih[kk]
    p-rash[kk]           = p-rash[kk]            + tmp-cli-gds.p-rash[kk]
    p-kassa[kk]          = p-kassa[kk]           + tmp-cli-gds.p-kassa[kk]
    p-Inv[kk]            = p-Inv[kk]             + tmp-cli-gds.p-Inv[kk]
    p-spis[kk]           = p-spis[kk]            + tmp-cli-gds.p-spis[kk]
    p-vzvr[kk]           = p-vzvr[kk]            + tmp-cli-gds.p-vzvr[kk]
    p-vzvr-post[kk]      = p-vzvr-post[kk]       + tmp-cli-gds.p-vzvr-post[kk]
    p-sm[kk]             = p-sm[kk]       + tmp-cli-gds.p-sm[kk]
    .
 end.
END PROCEDURE.

 /* $Workfile$ e n d */