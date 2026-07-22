/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок отчета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
procedure Goods-start :
END PROCEDURE.

procedure Goods-end :
END PROCEDURE.

PROCEDURE display-line :
  i = i + 1.
  { rep/r-mess.i i 200 }
  Run Clear-item.
    assign
          gds-zap-gds-name = if g#gds-engl then Goods.engl-name else Goods.gds-name
          gds-zap-unit-base  = Goods.unit-base
          gds-zap-prt-root   = Goods.prt-root
          gds-zap-prod-type  = Goods.prod-type
          gds-zap-prod-code  = Goods.prod-code
          gds-zap-artic      = Goods.artic
          gds-zap-grp-name   = Goods.grp-name
          gds-zap-b-code     = Goods.gds-code
          gds-zap-type       = Goods.gds-type
          pos-cli-type       = ub.clients.obj-type
          pos-cli-code       = ub.clients.obj-code
          pos-cli-grp-name   = ub.clients.grp-name.

   if Show-Cost Then  RUN ob-line (
             post-stk-line.obj-code    ,
             post-stk-line.obj-type    ,
             post-stk-line.cli-code    ,
             post-stk-line.cli-type    ,
             post-stk-line.artic       ,
             post-stk-line.prod-code   ,
             post-stk-line.prod-type   ,
             Fact-order-1   ,
             Fact-order-2   ,
             {&arh-COST}    ,
             {&root-cat-id} ,
             ""             ,
             yes) .
   if Show-Sale Then  RUN ob-line (
             post-stk-line.obj-code    ,
             post-stk-line.obj-type    ,
             post-stk-line.cli-code    ,
             post-stk-line.cli-type    ,
             post-stk-line.artic       ,
             post-stk-line.prod-code   ,
             post-stk-line.prod-type   ,
             Fact-order-1   ,
             Fact-order-2   ,
             {&arh-Sale}    ,
             {&root-cat-id} ,
             ""             ,
             yes) .
         Run Display-str1.
         Run Clear-item.
  END PROCEDURE.

PROCEDURE display-str1  :
     Run di-qnty ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if Show-Cost Then DO : Run di ( "учет." , 2, "","","","","" ).  End.
         if Show-Sale Then DO : Run di ( "док-т.", 8, "","","","","" ).  End.
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
/*   WHEN "B1":U  Then
              { rep/di-ob-s.i ->>>>>>>>>>>>9.<< b1-}
   WHEN "B2":U  Then
             { rep/di-ob-s.i ->>>>>>>>>>>>9.<< b2-}
   WHEN "BI":U Then
             { rep/di-ob-s.i ->>>>>>>>>>>>9.<< bi-}

   WHEN ""  Then DO:
              { rep/di-ob-s.i ->>>>>>>>>>>>9.<< }
              End.
              */
   End case.
               {&FRAME-d}.
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
/*
   WHEN "B1":U  Then DO :
              { rep/di-ob-s.i ->>>>>>>>>>>9.<<< b1-}
              { rep/ex-ob-s.i ->>>>>>>>>>>9.<<< b1-}
                End.
   WHEN "B2":U  Then DO :
             { rep/di-ob-s.i ->>>>>>>>>>>9.<<< b2-}
             { rep/ex-ob-s.i ->>>>>>>>>>>9.<<< b2-}
             End.
   WHEN "BI":U Then  DO :
             { rep/di-ob-s.i ->>>>>>>>>>>9.<<< bi-}
             { rep/ex-ob-s.i ->>>>>>>>>>>9.<<< bi-}
             End.

   WHEN ""  Then     DO :
              { rep/di-ob-s.i ->>>>>>>>>>>9.<<< }
              { rep/ex-ob-s.i ->>>>>>>>>>>9.<<< }
              End.
              */
   End case.
               {&FRAME-d}.
 END PROCEDURE.
procedure Print-Footer :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
    {&PUT-u1}    "Итого по : " + trim(Name) AT ((N - 1) * 10 ) format "x(100)"  {&new-line}.
    {&PutExcel}  "Итого по : " +  trim(Name) {&new-line}.

 END PROCEDURE.
PROCEDURE Clear-item :
 END PROCEDURE.

PROCEDURE ob-line :
define input  parameter x-store-code     like ub.clients.obj-code          no-undo.
define input  parameter x-store-type     like ub.clients.obj-type          no-undo.
define input  parameter x-cli-code       like ub.clients.obj-code          no-undo.
define input  parameter x-cli-type       like ub.clients.obj-type          no-undo.
define INPUT  parameter x-artic          like post-ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like post-ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like post-ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like post-ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like post-ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like post-ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like post-ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like post-ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as logical no-undo .

define variable tt# as int no-undo .
 if (x-sum-type = {&arh-cost}  or x-sum-type = {&arh-cost-service}) then tt# = 0.
 if (x-sum-type = {&arh-crsa}  or x-sum-type = {&arh-crsa-service}) then tt# = 3.
 if (x-sum-type = {&arh-sale}  or x-sum-type = {&arh-sale-service}) then tt# = 6.
     FOR each post-ot-line where
              post-ot-line.artic        = x-artic
        AND   post-ot-line.fact-order  <= x-fact-order-2
        AND   post-ot-line.fact-order  >= x-fact-order-1
        AND   post-ot-line.obj-code     = x-store-code
        AND   post-ot-line.obj-type     = x-store-type
        AND   post-ot-line.prod-code    = x-prod-code
        AND   post-ot-line.prod-type    = x-prod-type
        AND   post-ot-line.cli-code     = x-cli-code
        AND   post-ot-line.cli-type     = x-cli-type
        AND   post-ot-line.sum-type     = x-sum-type   no-lock :

    CASE post-ot-line.ext-doc-type:
        /*разбивка по типам документов */
        /* приход */
             WHEN        {&TDEDT_Pri_Vnesh}      THEN     DO:
           ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  post-ot-line.fact-qnty
                  prih[2 + tt#]   = prih[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  prih[3 + tt#]   = prih[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

        /* расход */
             WHEN       {&TDEDT_Ras_Vnesh}       THEN     DO:
           ASSIGN rash[1 + tt#]   = rash[1 + tt#]   +  post-ot-line.fact-qnty
                  rash[2 + tt#]   = rash[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  rash[3 + tt#]   = rash[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.
       /* возврат */
             WHEN        {&TDEDT_Vozvrat_Vnesh}  THEN     DO:
           ASSIGN vzvr[1 + tt#]        = vzvr[1 + tt#]   +  post-ot-line.fact-qnty
                  vzvr[2 + tt#]   = vzvr[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  vzvr[3 + tt#]   = vzvr[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base .
                 End.
      /* возврат пост */
             WHEN       {&TDEDT_RAS_Vnesh_VP}    THEN     DO:
           ASSIGN vzvr-post[1 + tt#]   = vzvr-post[1 + tt#]   +  post-ot-line.fact-qnty
                  vzvr-post[2 + tt#]   = vzvr-post[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  vzvr-post[3 + tt#]   = vzvr-post[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.
       /* наценка */
             WHEN       {&TDEDT_Overturn} THEN   DO:    /* ???? */
             /*
           ASSIGN discnt[1 + tt#]   = discnt[1 + tt#]   +  post-ot-line.fact-qnty
                  discnt[2 + tt#]   = discnt[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  discnt[3 + tt#]   = discnt[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
               */
                  End.
          End CASE.
   End.
END PROCEDURE.

procedure tmp-assign :
end procedure. /* tmp-assign */
procedure tmp-clear :
end procedure. /* tmp-clear */
procedure tmp-create :
define input parameter p-cli-code as integer   no-undo .
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-name as character no-undo .
define input parameter p-obj-code as integer   no-undo .
define input parameter p-obj-type as character no-undo .
end procedure. /* tmp-create */