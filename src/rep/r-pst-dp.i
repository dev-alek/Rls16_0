/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок специализированной обороток пол поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 04/08/02 3:43

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure Goods-start :
 def buffer  b-post-stk-line for ub.stk-supp-line .
 define variable p-fact-order as decimal no-undo .
  p-fact-order = fact-order-1 .
  Find last temp2-post-stk-line  no-lock where
                                    temp2-post-stk-line.artic       =  temp-t-post-stk-line.artic        and
                                    temp2-post-stk-line.prod-type   =  temp-t-post-stk-line.prod-type    and
                                    temp2-post-stk-line.prod-code   =  temp-t-post-stk-line.prod-code    and
                                    temp2-post-stk-line.cli-type    =  temp-t-post-stk-line.cli-type     and
                                    temp2-post-stk-line.cli-code    =  temp-t-post-stk-line.cli-code     and
                                    temp2-post-stk-line.obj-type    =  temp-t-post-stk-line.obj-type     and
                                    temp2-post-stk-line.obj-code    =  temp-t-post-stk-line.obj-code     and
                                    temp2-post-stk-line.fact-order <=  fact-order-1               and
                                    temp2-post-stk-line.sum-type    =  {&arh-cost}                and
                                    temp2-post-stk-line.cat-id      =  {&single-cat-id}
                                    no-error .
  Find Last a-post-stk-line  where
      a-post-stk-line.fact-order =   ( if avail temp2-post-stk-line then temp2-post-stk-line.fact-order else 0)  and
      a-post-stk-line.cat-id     =  t#cat-id      and
      a-post-stk-line.Sum-type   =  t#sum-type    and
      a-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
      a-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
      a-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
      a-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
      a-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code  and
      a-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type  and
      a-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code
      no-lock no-error .
      if avail  a-post-stk-line Then
      Assign
        p-fact-order     = a-post-stk-line.fact-order
        Ostatok-start[1] = a-post-stk-line.fact-qnty
        Ostatok-start[2] = IF tPrintRubl THEN  a-post-stk-line.sum-rubl
                                         else a-post-stk-line.sum-base.
        Else
      Assign
        Ostatok-start[1] = 0
        Ostatok-start[2] = 0
      Ostatok-start[8] = 0.


     IF Show-Sale  then do: /* sale */
             For each b-post-stk-line where
                                         b-post-stk-line.fact-order = p-fact-order and
                                         b-post-stk-line.cat-id     = t#cat-id   and
                                         b-post-stk-line.Sum-type   begins {&arh-sadt}         and
                                         b-post-stk-line.artic      = temp-t-post-stk-line.artic      and
                                         b-post-stk-line.prod-type  = temp-t-post-stk-line.prod-type  and
                                         b-post-stk-line.prod-code  = temp-t-post-stk-line.prod-code  and
                                         b-post-stk-line.cli-type   = temp-t-post-stk-line.cli-type   and
                                         b-post-stk-line.cli-code   = temp-t-post-stk-line.cli-code   and
                                         b-post-stk-line.obj-type   = temp-t-post-stk-line.obj-type   and
                                         b-post-stk-line.obj-code   = temp-t-post-stk-line.obj-code
                                         no-lock :
                      IF  tPrintRubl  THEN
                           ASSIGN  Ostatok-start[8] = Ostatok-start[8]  + b-post-stk-line.sum-rubl .
                        ELSE
                           ASSIGN  Ostatok-start[8] = Ostatok-start[8]  +  b-post-stk-line.sum-base.

              End. /* for each */
      End.
 END PROCEDURE.

procedure Goods-end :
 def buffer  b-post-stk-line for ub.stk-supp-line .
 define variable p-fact-order as decimal no-undo .
  p-fact-order = fact-order-2 .

  Find last temp2-post-stk-line  no-lock where
                                    temp2-post-stk-line.artic       =  temp-t-post-stk-line.artic        and
                                    temp2-post-stk-line.prod-type   =  temp-t-post-stk-line.prod-type    and
                                    temp2-post-stk-line.prod-code   =  temp-t-post-stk-line.prod-code    and
                                    temp2-post-stk-line.cli-type    =  temp-t-post-stk-line.cli-type     and
                                    temp2-post-stk-line.cli-code    =  temp-t-post-stk-line.cli-code     and
                                    temp2-post-stk-line.obj-type    =  temp-t-post-stk-line.obj-type     and
                                    temp2-post-stk-line.obj-code    =  temp-t-post-stk-line.obj-code     and
                                    temp2-post-stk-line.fact-order <=  fact-order-2               and
                                    temp2-post-stk-line.sum-type    =  {&arh-cost}                and
                                    temp2-post-stk-line.cat-id      =  {&single-cat-id}
                                    no-error .
  Find Last a-post-stk-line  where
      a-post-stk-line.fact-order =   ( if avail temp2-post-stk-line then temp2-post-stk-line.fact-order else 0)  and
      a-post-stk-line.cat-id     =  t#cat-id       and
      a-post-stk-line.Sum-type   =  t#sum-type     and
      a-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
      a-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
      a-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
      a-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
      a-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code    and
      a-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
      a-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code
      no-lock no-error .

  if avail  a-post-stk-line Then do :
      Assign
        p-fact-order     = a-post-stk-line.fact-order
        ostatok-end[1] = a-post-stk-line.fact-qnty
        ostatok-end[2] = if tprintrubl then  a-post-stk-line.sum-rubl
                                       else  a-post-stk-line.sum-base.
        end.
        Else
      Assign
        Ostatok-end[1] = 0
        Ostatok-end[2] = 0.

        Ostatok-end[8] = 0.

     IF Show-Sale  then do: /* sale */
             For each b-post-stk-line where
                                         b-post-stk-line.fact-order = p-fact-order and
                                         b-post-stk-line.cat-id     = t#cat-id   and
                                         b-post-stk-line.Sum-type    begins {&arh-sadt}         and                                         b-post-stk-line.artic      = post-stk-line.artic      and
                                         b-post-stk-line.prod-type  = temp-t-post-stk-line.prod-type  and
                                         b-post-stk-line.prod-code  = temp-t-post-stk-line.prod-code  and
                                         b-post-stk-line.cli-type   = temp-t-post-stk-line.cli-type   and
                                         b-post-stk-line.cli-code   = temp-t-post-stk-line.cli-code   and
                                         b-post-stk-line.obj-type   = temp-t-post-stk-line.obj-type   and
                                         b-post-stk-line.obj-code   = temp-t-post-stk-line.obj-code
                                         no-lock :
                      IF  tPrintRubl  THEN
                           ASSIGN  Ostatok-end[8] = Ostatok-end[8]  + b-post-stk-line.sum-rubl .
                        ELSE
                           ASSIGN  Ostatok-end[8] = Ostatok-end[8]  +  b-post-stk-line.sum-base.

              End.  /* for each */
      End.

END PROCEDURE.


PROCEDURE display-line :
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

    run ob-line  (
             temp-t-post-stk-line.obj-code    ,
             temp-t-post-stk-line.obj-type    ,
             temp-t-post-stk-line.cli-code    ,
             temp-t-post-stk-line.cli-type    ,
             temp-t-post-stk-line.artic       ,
             temp-t-post-stk-line.prod-code   ,
             temp-t-post-stk-line.prod-type   ,
             Fact-order-1     ,
             Fact-order-2     ,
             t#sum-type       ,
             t#cat-id         ,
             ""               ,
             yes) .

   if Show-Sale Then  run ob-line  (
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
         run calc-sub-itog ( 0).
             if Show-Sale Then
                run calc-sub-itog ( 6).
       IF  NOT  ( ( ostatok-start[1] = 0  AND /* это нулевые строки */
                                       Prih         [1] = 0  AND
                                       RAsh         [1] = 0  AND
                                       KAssa        [1] = 0  AND
                                       Inv          [1] = 0  AND
                                       vzvr         [1] = 0  AND
                                       vzvr-post    [1] = 0  AND
                                       Ostatok-end  [1] = 0)) then DO:

         IF NOT Sums-Only then DO:
            run display-str1 in this-procedure .
            run clear-item in this-procedure .
         End.
       End.
  END PROCEDURE.


PROCEDURE display-str1  :

if   Show-Negativ = true or not  (
    Prih         [1] = 0  AND
    RAsh         [1] = 0  AND
    KAssa        [1] = 0  AND
    Inv          [1] = 0  AND
    vzvr         [1] = 0  AND
    spis         [1] = 0  AND
    vzvr-post    [1] = 0     /* это нулевые обороты */
    ) then DO:
    if not  (  not Show-zero-ost   and
            (  ostatok-end[1] = 0  and
             ostatok-end[2] = 0  and
             ostatok-end[8] = 0 ))  then DO:
         run di-qnty  ( "кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if show-cost then do : run di  (  "учет." , 2, "","","","","" ).  end.
         if show-sale then do : run di  (  "док-т.", 8, "","","","","" ).  end.
       end.
end.
run clear-item in this-procedure .
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
   WHEN "B1":U  Then do:
         { rep/ex-obrt.i 'oborot' 'nex' b1-} end.
   WHEN "B2":U  Then do:
         { rep/ex-obrt.i 'oborot' 'nex' b2-} end.
   WHEN "BI":U Then do:
         { rep/ex-obrt.i 'oborot' 'nex' bi-} end.
   WHEN "P":U Then do:
         { rep/ex-obrt.i 'oborot' 'nex' p-} end.
   WHEN "O"  Then     DO :
       { rep/ex-obrt.i 'oborot' 'nex' o- }    End.
   WHEN ""  Then DO:
         { rep/ex-obrt.i 'oborot' 'nex' }    End.
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

   WHEN "B1":U  Then DO :
               { rep/ex-obrt.i 'oborot' 'nex' b1-}
               { rep/ex-obrt.i 'oborot' 'ex' b1-}
                End.
   WHEN "B2":U  Then DO :
                 { rep/ex-obrt.i 'oborot' 'nex'  b2-}
                 { rep/ex-obrt.i 'oborot' 'ex'  b2-}
             End.
   WHEN "BI":U Then  DO :
              { rep/ex-obrt.i 'oborot' 'nex' bi-}
              { rep/ex-obrt.i 'oborot' 'ex' bi-}
             End.
   WHEN ""  Then     DO :
       { rep/ex-obrt.i 'oborot' 'nex' }
       { rep/ex-obrt.i 'oborot' 'ex' }
              End.
   WHEN "P"  Then     DO :
       { rep/ex-obrt.i 'oborot' 'nex' p- }
       { rep/ex-obrt.i 'oborot' 'ex' p- }
              End.
   WHEN "O"  Then     DO :
       { rep/ex-obrt.i 'oborot' 'nex' o- }
       { rep/ex-obrt.i 'oborot' 'ex' o- }
              End.
    End case.
               {&FRAME-d}.
 END PROCEDURE.


procedure Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
    if Nx = 1 Then DO:
         run di-qnty  ( "кол-во", 1,"","Итого по : ",trim ( name),"","b1").
         if show-cost then do : run di  (  "учет." , 2, "","","","","b1" ).  end.
         if show-sale then do : run di  (  "док-т.", 8, "","","","","b1" ).  end.
         if not sums-only then
            run u-line.
         run clear-itemb1- in this-procedure .
         End.
 if Nx = 2 Then DO:
         run di-qnty  ( "кол-во", 1,"","","Итого по : " + trim ( name),"","b2").
         if show-cost then do : run di  (  "учет." , 2, "","","","","b2" ).  end.
         if show-sale then do : run di  (  "док-т.", 8, "","","","","b2" ).  end.
         if not sums-only then run u-line.
         run clear-itemb2-.
        end.
 if nx = 3 then do:
         if not sums-only then run u-line.
         run di-qnty  ( "кол-во", 1,"","Итого по пост-ку" , trim ( name),"","p").
         if show-cost then do : run di  (  "учет." , 2, "","","","","p" ).  end.
         if show-sale then do : run di  (  "док-т.", 8, "","","","","p" ).  end.
         if not sums-only then run u-line.
         run clear-itemp-.
          end.
 if nx = 0 then do:
         run di-qnty  ( "кол-во", 1,"","Итого  объект: " , trim ( name),"","o").
         if show-cost then do : run di  (  "учет." , 2, "","","","","o" ).  end.
         if show-sale then do : run di  (  "док-т.", 8, "","","","","o" ).  end.
         if not sums-only then run u-line.
         run clear-itemo-.
          end.
 END PROCEDURE.


PROCEDURE Clear-item :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
    prih             [kk]  = 0
    rash             [kk]  = 0
    kassa            [kk]  = 0
    spis             [kk]  = 0
    Inv              [kk]  = 0
    vzvr             [kk]  = 0
    vzvr-post        [kk]  = 0
     .
       End.
 END PROCEDURE.


PROCEDURE Clear-itemb1- :
def var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b1-prih             [kk]  = 0
   b1-rash             [kk]  = 0
   b1-kassa            [kk]  = 0
   b1-spis              [kk]  = 0
   b1-Inv              [kk]  = 0
   b1-vzvr             [kk]  = 0
   b1-vzvr-post        [kk]  = 0
   b1-ostatok-end      [kk]  = 0
   b1-ostatok-start    [kk]  = 0
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
   b2-spis             [kk]  = 0
   b2-Inv              [kk]  = 0
   b2-vzvr             [kk]  = 0
   b2-vzvr-post        [kk]  = 0
   b2-ostatok-end      [kk]  = 0
   b2-ostatok-start    [kk]  = 0
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
   p-spis             [kk]  = 0
   p-Inv              [kk]  = 0
   p-vzvr             [kk]  = 0
   p-vzvr-post        [kk]  = 0
   p-ostatok-end      [kk]  = 0
   p-ostatok-start    [kk]  = 0
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
   o-Spis             [kk]  = 0
   o-Inv              [kk]  = 0
   o-vzvr             [kk]  = 0
   o-vzvr-post        [kk]  = 0
   o-ostatok-end      [kk]  = 0
   o-ostatok-start    [kk]  = 0
   .
   End.
 END PROCEDURE.



PROCEDURE ob-line :
def input  parameter x-store-code     like ub.clients.obj-code          no-undo.
def input  parameter x-store-type     like ub.clients.obj-type          no-undo.
def input  parameter x-cli-code       like ub.clients.obj-code          no-undo.
def input  parameter x-cli-type       like ub.clients.obj-type          no-undo.
def INPUT  parameter x-artic          like post-ot-line.artic        no-undo.
def INPUT  parameter x-prod-code      like post-ot-line.prod-code    no-undo.
def INPUT  parameter x-prod-type      like post-ot-line.prod-type    no-undo.
def INPUT  parameter x-Fact-order-1   like post-ot-line.Fact-order   no-undo.
def INPUT  parameter x-Fact-order-2   like post-ot-line.Fact-order   no-undo.
def input  parameter x-sum-type       like post-ot-line.sum-type     no-undo.
def input  parameter x-cat-id         like post-ot-line.cat-id       no-undo.
def input  parameter x-ext-doc-type   like post-ot-line.ext-doc-type no-undo.
def input  parameter xTog-obj           as log no-undo .
def var  tt#          as   int                 no-undo .
 if  ( x-sum-type = {&arh-cost} ) then tt# = 0.
 if  ( x-sum-type = {&arh-sale} ) then tt# = 6.



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
        AND   post-ot-line.sum-type     = x-sum-type
        AND   post-ot-line.cat-id       = x-cat-id
               no-lock :

        CASE post-ot-line.ext-doc-type:
        /* разбивка по типам документов */
        /* приход */
             WHEN        {&TDEDT_Pri_Perem}      OR
             WHEN        {&TDEDT_Vozvrat_Perem}  OR
             WHEN        {&TDEDT_Pri_Prvo  }     THEN     DO:
           if t-in then
           ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  post-ot-line.fact-qnty
                  prih[2 + tt#]   = prih[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  prih[3 + tt#]   = prih[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

             WHEN        {&TDEDT_Pri_Vnesh}   THEN     DO:
           ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  post-ot-line.fact-qnty
                  prih[2 + tt#]   = prih[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  prih[3 + tt#]   = prih[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

         /* возврат внеш */
             WHEN        {&TDEDT_Vozvrat_Vnesh}  THEN DO:
           ASSIGN vzvr[1 + tt#]   = vzvr[1 + tt#]   +  post-ot-line.fact-qnty
                  vzvr[2 + tt#]   = vzvr[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  vzvr[3 + tt#]   = vzvr[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

         /* возврат пост */
             WHEN       {&TDEDT_RAS_Vnesh_VP}  THEN DO:
           ASSIGN vzvr-post[1 + tt#]   = vzvr-post[1 + tt#]   +  post-ot-line.fact-qnty
                  vzvr-post[2 + tt#]   = vzvr-post[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  vzvr-post[3 + tt#]   = vzvr-post[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

        /* расход */
             WHEN       {&TDEDT_Ras_Vnesh}          THEN  DO:
             ASSIGN rash[1 + tt#]   = rash[1 + tt#]   +  post-ot-line.fact-qnty
                  rash[2 + tt#]   = rash[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  rash[3 + tt#]   = rash[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

             WHEN       {&TDEDT_Ras_Perem}       OR
             WHEN       {&TDEDT_Ras_Prvo}        THEN  DO:
           if t-in then
           ASSIGN rash[1 + tt#]   = rash[1 + tt#]   +  post-ot-line.fact-qnty
                  rash[2 + tt#]   = rash[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  rash[3 + tt#]   = rash[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

       /* касса */
             WHEN       {&TDEDT_Ras_Vnesh_Kass}  OR
             WHEN       {&TDEDT_Vozvrat_Vnesh_Kass} THEN  DO:
           ASSIGN kassa[1 + tt#]   = kassa[1 + tt#]   +  post-ot-line.fact-qnty
                  kassa[2 + tt#]   = kassa[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  kassa[3 + tt#]   = kassa[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base .
                 End.
      /* инвентаризация */
             WHEN       {&TDEDT_Inv}      or
             when       {&TDEDT_Peresort}   or
             when       {&TDEDT_Corr_Acc_Price}   or
             when       {&TDEDT_Corr_Minus_Parts} or
             when       {&TDEDT_Chg_Purch_Code}
     THEN  DO:
           ASSIGN INV[1 + tt#]   = INV[1 + tt#]   +  post-ot-line.fact-qnty
                  Inv[2 + tt#]   = Inv[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  Inv[3 + tt#]   = Inv[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.
        /* Списание*/
             WHEN       {&TDEDT_Spi_Vnesh}       THEN  DO:
           ASSIGN spis[1 + tt#]   = spis[1 + tt#]   +  post-ot-line.fact-qnty
                  spis[2 + tt#]   = spis[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  spis[3 + tt#]   = spis[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

             WHEN       {&TDEDT_Spi_Prvo}       THEN  DO:
           if t-in then
           ASSIGN spis[1 + tt#]   = spis[1 + tt#]   +  post-ot-line.fact-qnty
                  spis[2 + tt#]   = spis[2 + tt#]   +  if tprintrubl then post-ot-line.sum-rubl else post-ot-line.sum-base
                  spis[3 + tt#]   = spis[3 + tt#]   +  if tprintrubl then post-ot-line.vat-rubl else post-ot-line.vat-base  .
                 End.

          End CASE.
   End.
END PROCEDURE.


PROCEDURE Calc-Sub-itog :                                            /* подсчет под итогов */
def input parameter tt as int no-undo.
def var b as int no-undo.
repeat b = 1 to 3 :
  Assign
  B1-Prih[b + TT]    = B1-Prih[b + TT]    +  Prih[b + TT]
  B2-Prih[b + TT]    = B2-Prih[b + TT]    +  Prih[b + TT]
  Bi-Prih[b + TT]    = Bi-Prih[b + TT]    +  Prih[b + TT]
  p-Prih[b + TT]     = p-Prih[b + TT]    +  Prih[b + TT]
  o-Prih[b + TT]     = o-Prih[b + TT]    +  Prih[b + TT]

  B1-RAsh[b + TT]    = B1-RAsh[b + TT]    +  RAsh[b + TT]
  B2-RAsh[b + TT]    = B2-RAsh[b + TT]    +  RAsh[b + TT]
  Bi-RAsh[b + TT]    = Bi-RAsh[b + TT]    +  RAsh[b + TT]
  p-RAsh[b + TT]    = p-RAsh[b + TT]    +  RAsh[b + TT]
  o-RAsh[b + TT]    = o-RAsh[b + TT]    +  RAsh[b + TT]

  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT]
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT]
  Bi-kassa[b + TT]     = Bi-kassa[b + TT]     +  kassa[b + TT]
  p-kassa[b + TT]      = p-kassa[b + TT]      +  kassa[b + TT]
  o-kassa[b + TT]      = o-kassa[b + TT]      +  kassa[b + TT]

  B1-Inv[b + TT]    = B1-Inv[b + TT]    +  Inv[b + TT]
  B2-Inv[b + TT]    = B2-Inv[b + TT]    +  Inv[b + TT]
  Bi-Inv[b + TT]    = Bi-Inv[b + TT]    +  Inv[b + TT]
  p-Inv[b + TT]    = p-Inv[b + TT]    +  Inv[b + TT]
  o-Inv[b + TT]    = o-Inv[b + TT]    +  Inv[b + TT]

  B1-spis[b + TT]    = B1-spis[b + TT]    +  spis[b + TT]
  B2-spis[b + TT]    = B2-spis[b + TT]    +  spis[b + TT]
  Bi-spis[b + TT]    = Bi-spis[b + TT]    +  spis[b + TT]
   p-spis[b + TT]    =  p-spis[b + TT]    +  spis[b + TT]
   o-spis[b + TT]    =  o-spis[b + TT]    +  spis[b + TT]


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

  B1-ostatok-start[b + TT]    = B1-ostatok-start[b + TT]    + ostatok-start[b + TT]
  B2-ostatok-start[b + TT]    = B2-ostatok-start[b + TT]    + ostatok-start[b + TT]
  Bi-ostatok-start[b + TT]    = Bi-ostatok-start[b + TT]    + ostatok-start[b + TT]
  p-ostatok-start[b + TT]    = p-ostatok-start[b + TT]    + ostatok-start[b + TT]
  o-ostatok-start[b + TT]    = o-ostatok-start[b + TT]    + ostatok-start[b + TT]

  B1-ostatok-end[b + TT]    = B1-ostatok-end[b + TT]    + ostatok-end[b + TT]
  B2-ostatok-end[b + TT]    = B2-ostatok-end[b + TT]    + ostatok-end[b + TT]
  Bi-ostatok-end[b + TT]    = Bi-ostatok-end[b + TT]    + ostatok-end[b + TT]
  p-ostatok-end[b + TT]    = p-ostatok-end[b + TT]    + ostatok-end[b + TT]
  o-ostatok-end[b + TT]    = o-ostatok-end[b + TT]    + ostatok-end[b + TT]
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
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-spis
        F-vzvr
        F-vzvr-post
        F-ostatok-end
        {&wFz} .
        {&FRAME-d}.
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
      tmp-cli-gds.p-ostatok-start[kk]  = p-ostatok-start[kk]
      tmp-cli-gds.p-ostatok-End[kk]    = p-ostatok-End[kk]
      tmp-cli-gds.p-prih[kk]           = p-prih[kk]
      tmp-cli-gds.p-rash[kk]           = p-rash[kk]
      tmp-cli-gds.p-kassa[kk]          = p-kassa[kk]
      tmp-cli-gds.p-Inv[kk]            = p-Inv[kk]
      tmp-cli-gds.p-spis[kk]           = p-spis[kk]
      tmp-cli-gds.p-vzvr[kk]           = p-vzvr[kk]
      tmp-cli-gds.p-vzvr-post[kk]      = p-vzvr-post[kk]
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
     p-ostatok-start[kk] = 0
     p-ostatok-End[kk]   = 0
     p-prih[kk]          = 0
     p-rash[kk]          = 0
     p-kassa[kk]         = 0
     p-Inv[kk]           = 0
     p-spis[kk]          = 0
     p-vzvr[kk]          = 0
     p-vzvr-post[kk]     = 0
    .
    end.

END PROCEDURE.


Procedure Tmp-assign :
 def var kk as int no-undo.
 REPEAT kk = 1 to 9 :
    Assign
    p-ostatok-start[kk]  = p-ostatok-start[kk]   + tmp-cli-gds.p-ostatok-start[kk]
    p-ostatok-End[kk]    = p-ostatok-End[kk]     + tmp-cli-gds.p-ostatok-End[kk]
    p-prih[kk]           = p-prih[kk]            + tmp-cli-gds.p-prih[kk]
    p-rash[kk]           = p-rash[kk]            + tmp-cli-gds.p-rash[kk]
    p-kassa[kk]          = p-kassa[kk]           + tmp-cli-gds.p-kassa[kk]
    p-Inv[kk]            = p-Inv[kk]             + tmp-cli-gds.p-Inv[kk]
    p-spis[kk]           = p-spis[kk]            + tmp-cli-gds.p-spis[kk]
    p-vzvr[kk]           = p-vzvr[kk]            + tmp-cli-gds.p-vzvr[kk]
    p-vzvr-post[kk]      = p-vzvr-post[kk]       + tmp-cli-gds.p-vzvr-post[kk]
    .
 end.
END PROCEDURE.
procedure Goods-start-O :
 def buffer  b-post-stk-line for ub.stk-supp-line .
 define variable p-fact-order as decimal no-undo .
  p-fact-order = fact-order-1 .
  Find last temp2-post-stk-line  no-lock where
    temp2-post-stk-line.artic       =  temp-t-post-stk-line.artic        and
    temp2-post-stk-line.prod-type   =  temp-t-post-stk-line.prod-type    and
    temp2-post-stk-line.prod-code   =  temp-t-post-stk-line.prod-code    and
    temp2-post-stk-line.cli-type    =  temp-t-post-stk-line.cli-type     and
    temp2-post-stk-line.cli-code    =  temp-t-post-stk-line.cli-code     and
    temp2-post-stk-line.obj-type    =  OBJ-LIST.obj-type     and
    temp2-post-stk-line.obj-code    =  obj-list.obj-code     and
    temp2-post-stk-line.fact-order <=  fact-order-1               and
    temp2-post-stk-line.sum-type    =  {&arh-cost}                and
    temp2-post-stk-line.cat-id      =  {&single-cat-id}
    no-error .
  Find Last a-post-stk-line  where
      a-post-stk-line.fact-order =  (if avail temp2-post-stk-line then temp2-post-stk-line.fact-order else 0)  and
      a-post-stk-line.cat-id     =  t#cat-id      and
      a-post-stk-line.Sum-type   =  t#sum-type    and
      a-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
      a-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
      a-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
      a-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
      a-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code  and
      a-post-stk-line.obj-type   =  obj-list.obj-type  and
      a-post-stk-line.obj-code   =  obj-list.obj-code
      no-lock no-error .
      if avail  a-post-stk-line Then do:
        p-fact-order     = a-post-stk-line.fact-order .
        Ostatok-start[1] = Ostatok-start[1] +  a-post-stk-line.fact-qnty   .
        ostatok-start[2] = ostatok-start[2] +  if tprintrubl then  a-post-stk-line.sum-rubl
                                                  else a-post-stk-line.sum-base .
        end.
     IF Show-Sale  then do: /* sale */
             For each b-post-stk-line where
                                         b-post-stk-line.fact-order = p-fact-order and
                                         b-post-stk-line.cat-id     = t#cat-id   and
                                         b-post-stk-line.Sum-type   begins {&arh-sadt}         and
                                         b-post-stk-line.artic      = temp-t-post-stk-line.artic      and
                                         b-post-stk-line.prod-type  = temp-t-post-stk-line.prod-type  and
                                         b-post-stk-line.prod-code  = temp-t-post-stk-line.prod-code  and
                                         b-post-stk-line.cli-type   = temp-t-post-stk-line.cli-type   and
                                         b-post-stk-line.cli-code   = temp-t-post-stk-line.cli-code   and
                                         b-post-stk-line.obj-type   = obj-list.obj-type   and
                                         b-post-stk-line.obj-code   = obj-list.obj-code
                                         no-lock :
                      IF  tPrintRubl  THEN
                           ASSIGN  Ostatok-start[8] = Ostatok-start[8]  + b-post-stk-line.sum-rubl .
                        ELSE
                           ASSIGN  Ostatok-start[8] = Ostatok-start[8]  +  b-post-stk-line.sum-base.

              End. /* for each */
      End.
END PROCEDURE.

procedure Goods-end-O :
 def buffer  b-post-stk-line for ub.stk-supp-line .
 define variable p-fact-order as decimal no-undo .
  p-fact-order = fact-order-2 .
  Find last temp2-post-stk-line  no-lock where
    temp2-post-stk-line.artic       =  temp-t-post-stk-line.artic        and
    temp2-post-stk-line.prod-type   =  temp-t-post-stk-line.prod-type    and
    temp2-post-stk-line.prod-code   =  temp-t-post-stk-line.prod-code    and
    temp2-post-stk-line.cli-type    =  temp-t-post-stk-line.cli-type     and
    temp2-post-stk-line.cli-code    =  temp-t-post-stk-line.cli-code     and
    temp2-post-stk-line.obj-type    =  obj-list.obj-type     and
    temp2-post-stk-line.obj-code    =  obj-list.obj-code     and
    temp2-post-stk-line.fact-order <=  fact-order-2               and
    temp2-post-stk-line.sum-type    =  {&arh-cost}                and
    temp2-post-stk-line.cat-id      =  {&single-cat-id}
    no-error .
  Find Last a-post-stk-line  where
      a-post-stk-line.fact-order =  (if avail temp2-post-stk-line then temp2-post-stk-line.fact-order else 0)  and
      a-post-stk-line.cat-id     =  t#cat-id       and
      a-post-stk-line.Sum-type   =  t#sum-type     and
      a-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
      a-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
      a-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
      a-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
      a-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code    and
      a-post-stk-line.obj-type   =  obj-list.obj-type    and
      a-post-stk-line.obj-code   =  obj-list.obj-code
      no-lock no-error .

  if avail  a-post-stk-line Then do :
      Assign
        p-fact-order     = a-post-stk-line.fact-order
        ostatok-end[1] = ostatok-end[1] + a-post-stk-line.fact-qnty
        ostatok-end[2] = ostatok-end[2] + if tprintrubl then  a-post-stk-line.sum-rubl
                                          else  a-post-stk-line.sum-base.
  end.

     IF Show-Sale  then do: /* sale */
             For each b-post-stk-line where
                  b-post-stk-line.fact-order = p-fact-order and
                  b-post-stk-line.cat-id     = t#cat-id   and
                  b-post-stk-line.Sum-type    begins {&arh-sadt}         and
                  b-post-stk-line.artic      = post-stk-line.artic      and
                  b-post-stk-line.prod-type  = temp-t-post-stk-line.prod-type  and
                  b-post-stk-line.prod-code  = temp-t-post-stk-line.prod-code  and
                  b-post-stk-line.cli-type   = temp-t-post-stk-line.cli-type   and
                  b-post-stk-line.cli-code   = temp-t-post-stk-line.cli-code   and
                  b-post-stk-line.obj-type   = obj-list.obj-type   and
                  b-post-stk-line.obj-code   = obj-list.obj-code
                  no-lock :
                      IF  tPrintRubl  THEN
                           ASSIGN  Ostatok-end[8] = Ostatok-end[8]  + b-post-stk-line.sum-rubl .
                        ELSE
                           ASSIGN  Ostatok-end[8] = Ostatok-end[8]  +  b-post-stk-line.sum-base.
              End.  /* for each */
      End.
END PROCEDURE.

/* $Workfile$ e n d */