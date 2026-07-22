block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obpsd1.p $
$Archive: rep/r-obpsd1.p $

ѕродолжение  ќборотна€ ведомость по поставщикам по дкументам

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 09/10/03
Author: Svetlana Chernova
Creation date: 09/10/03

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obpsd1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obpsd1.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
&glob fr-name "&framename='oborot-doc':U"
define input parameter x-store-code like clients.obj-code   no-undo.
define input parameter x-store-type like clients.obj-type   no-undo.
define input parameter x-base-type  like currency.curr-abbr no-undo.
define input parameter x-base-code  like currency.curr-code no-undo.
define input parameter x-type-itog as integer no-undo .
define input parameter xshowgoods as logical no-undo .

{ rep/r-defpst.i &framename='oborot-doc':U }
{ rep/f-fdec.i   }
{ rep/f-flav.i   }
{ rep/gn-extp.i  }
{ gbl/waitfram.i }

define variable full-prih       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-rash       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-kassa      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-Inv2       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-Inv        as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-spis       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-vzvr       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-vzvr-post  as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

define variable ii like i init 0 no-undo .
define buffer buf_parts for parts.

define temp-table temp_oborot_parts no-undo like parts
field ext-doc-type as character
field sum-rubl as decimal
field vat-rubl as decimal
field sum-base as decimal
field vat-base as decimal
.

define temp-table temp_oborot_parts-2 no-undo like parts
field ext-doc-type as character
field sum-rubl as decimal
field vat-rubl as decimal
field sum-base as decimal
field vat-base as decimal
.

define temp-table temp-null no-undo like temp-t-post-stk-line.
define variable p-first as logical no-undo .

p-first = true .
/* сортировки */

if cli-art = "yes" then do:
 gds-zap-artic:label in frame zapas = "јрт.ѕостав."  .
end.
case RetClassify :
      when "no-classify":U then do:
        for each g#post-f :
            run one-post in this-procedure .

            run run1 in this-procedure .
        end.
      end.
    when "post":U then do:
      run run2 in this-procedure .
    end.
    when "post/grp-goods":U then do:
      run run2 in this-procedure .
    end.
end case.

if xtogobj =  true then do:
   find first obj-list.
    if available obj-list then do:
      run print-footer in this-procedure  ( 0 , obj-list.obj-name ).
      run clear-itemo- in this-procedure .
    end.
end.
/*-----------------------------------------------------------------------*/
procedure one-post :
 do
 on error undo, return error return-value
 :

  run waitfram-show in this-procedure  (g#post-f.obj-name) .

  for each obj-list :
    for each buf_parts no-lock where
        buf_parts.host-code = v-cntxt-host-code-obj      and
        buf_parts.obj-code = obj-list.obj-code and
        buf_parts.obj-type = obj-list.obj-type and
        buf_parts.supp-type = g#post-f.obj-type  and
        buf_parts.supp-code = g#post-f.obj-code  and
        buf_parts.status_   = true             and
        buf_parts.fact-date >= x-date-start    and
        buf_parts.fact-date <= x-date-end

    :
        if type-stor <> 1 then do:
           /* по типам приобретени€ */
           if buf_parts.purch-code <>  type-stor - 1 then next.
        end.
      find first goods no-lock where goods.artic      = buf_parts.artic     and
                                     goods.prod-type = buf_parts.prod-type and
                                     goods.prod-code = buf_parts.prod-code no-error .

        if not available goods then next.
        find first trn-doc no-lock where
              trn-doc.doc-code     = buf_parts.out-code
               no-error .
        if not available trn-doc then next.

        create temp_oborot_parts.
        BUFFER-COPY buf_parts  to temp_oborot_parts
            assign
              temp_oborot_parts.ext-doc-type = trn-doc.ext-doc-type
              temp_oborot_parts.sum-rubl = buf_parts.fact-qnty * buf_parts.price-rubl
              temp_oborot_parts.sum-base = buf_parts.fact-qnty * buf_parts.price-base
            .
        find first temp-t-post-stk-line where
                   temp-t-post-stk-line.artic     = temp_oborot_parts.artic     and
                   temp-t-post-stk-line.prod-type = temp_oborot_parts.prod-type and
                   temp-t-post-stk-line.prod-code = temp_oborot_parts.prod-code  no-error .
                   if not available temp-t-post-stk-line then do:
                      create temp-t-post-stk-line.
                      assign
                        temp-t-post-stk-line.artic     = temp_oborot_parts.artic
                        temp-t-post-stk-line.prod-type = temp_oborot_parts.prod-type
                        temp-t-post-stk-line.prod-code = temp_oborot_parts.prod-code
                        temp-t-post-stk-line.gds-name  = goods.gds-name
                        temp-t-post-stk-line.unit-base = goods.unit-base
                        temp-t-post-stk-line.prt-root  = 0
                        temp-t-post-stk-line.Goods-grp-name   = goods.grp-name
                        temp-t-post-stk-line.gds-code         = goods.gds-code
                        temp-t-post-stk-line.gds-type         = goods.gds-type
                        temp-t-post-stk-line.Cli-type         = g#post-f.obj-type
                        temp-t-post-stk-line.Cli-code         = g#post-f.obj-code
                        temp-t-post-stk-line.Clients-grp-name = g#post-f.obj-name
                      .
                   end.
    end. /* parts */
  end. /* obj-list */
 end. /* do */
end procedure. /* one-post */

procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
    {&PUT-u1} trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
    {&PutExcel} fill(" " + {&tabulation}, N - 1) trim(Name) skip.
END PROCEDURE.

PROCEDURE display-line :
  i = i + 1.
  { rep/r-mess.i i 10 }
  run clear-item  in this-procedure .
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
          if cli-art = "yes" then do:
              gds-post-artic     = "" .
              find first ub.ext-artic no-lock where
                      ub.ext-artic.gds-code = temp-t-post-stk-line.gds-code and
                      ub.ext-artic.cli-type = temp-t-post-stk-line.Cli-type and
                      ub.ext-artic.cli-code = temp-t-post-stk-line.Cli-code and
                      ub.ext-artic.status_   =  {&current-status} no-error .
              if available ub.ext-artic then do:
                    assign
                      gds-post-artic     = ub.ext-artic.ext-artic
                    .
              end.

             gds-zap-artic = gds-post-artic .
          end.

run ob-line in this-procedure
      ( INPUT temp-t-post-stk-line.artic     ,
        INPUT temp-t-post-stk-line.prod-code ,
        INPUT temp-t-post-stk-line.prod-type  ).
run ost-line in this-procedure
      ( INPUT temp-t-post-stk-line.artic     ,
        INPUT temp-t-post-stk-line.prod-code ,
        INPUT temp-t-post-stk-line.prod-type  ) .

         run calc-sub-itog in this-procedure (0).
         run calc-sub-itog in this-procedure (6).
       if  not ( (ostatok-start[1] = 0  and
                 prih         [1] = 0  and
                 rash         [1] = 0  and
                 kassa        [1] = 0  and
                 inv          [1] = 0  and
                 vzvr         [1] = 0  and
                 spis         [1] = 0  and
                 vzvr-post    [1] = 0  and
                 ostatok-end  [1] = 0)) then do:

         IF NOT Sums-Only then DO:
            run display-str1 in this-procedure .
            run clear-item in this-procedure .
         End.
       End.
  END PROCEDURE.


PROCEDURE display-str1  :

      run di-qnty ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if show-cost then do : run di ( "учет." , 2, "","","","","" ).  end.
         if xshowgoods then do : run di ( "в пути", 7, "","","","","" ).  end.
      run clear-item.
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
   WHEN "B1":U  Then do:
         { rep/ex-obrt.i 'oborot-doc' 'nex' b1-} end.
   WHEN "B2":U  Then do:
         { rep/ex-obrt.i 'oborot-doc' 'nex' b2-} end.
   WHEN "BI":U Then do:
         { rep/ex-obrt.i 'oborot-doc' 'nex' bi-} end.
   WHEN "P":U Then do:
         { rep/ex-obrt.i 'oborot-doc' 'nex' p-} end.
   WHEN "O"  Then     DO :
       { rep/ex-obrt.i 'oborot-doc' 'nex' o- }    End.
   WHEN ""  Then DO:
         { rep/ex-obrt.i 'oborot-doc' 'nex' }    End.
   End case.

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

   WHEN "B1":U  Then DO :
               { rep/ex-obrt.i 'oborot-doc' 'nex' b1-}
               { rep/ex-obrt.i 'oborot-doc' 'ex' b1-}
                End.
   WHEN "B2":U  Then DO :
                 { rep/ex-obrt.i 'oborot-doc' 'nex'  b2-}
                 { rep/ex-obrt.i 'oborot-doc' 'ex'  b2-}
             End.
   WHEN "BI":U Then  DO :
              { rep/ex-obrt.i 'oborot-doc' 'nex' bi-}
              { rep/ex-obrt.i 'oborot-doc' 'ex' bi-}
             End.
   WHEN ""  Then     DO :
       { rep/ex-obrt.i 'oborot-doc' 'nex' }
       { rep/ex-obrt.i 'oborot-doc' 'ex' }
              End.
   WHEN "P"  Then     DO :
       { rep/ex-obrt.i 'oborot-doc' 'nex' p- }
       { rep/ex-obrt.i 'oborot-doc' 'ex' p- }
              End.
   WHEN "O"  Then     DO :
       { rep/ex-obrt.i 'oborot-doc' 'nex' o- }
       { rep/ex-obrt.i 'oborot-doc' 'ex' o- }
              End.
    End case.
 END PROCEDURE.


procedure Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
    if Nx = 1 Then DO:
         run di-qnty  in this-procedure ("кол-во", 1,"","»того по : ",trim(name),"","b1").
         if show-cost then do : run di  in this-procedure ( "учет." , 2, "","","","","b1" ).  end.
         if xshowgoods then do : run di in this-procedure  ( "в пути", 7, "","","","","b1" ).  end.
         if not sums-only then run u-line in this-procedure .
         run clear-itemb1- in this-procedure .
         End.
 if Nx = 2 Then DO:
         run di-qnty ("кол-во", 1,"","","»того по : " + trim(name),"","b2").
         if show-cost then do : run di ( "учет." , 2, "","","","","b2" ).  end.
         if xshowgoods then do : run di ( "в пути", 8, "","","","","b2" ).  end.
         if not sums-only then run u-line.
         run clear-itemb2-.
        End.
 if nx = 3 then do:
    if  not ((p-ostatok-start[1] = 0  and
              p-prih         [1] = 0  and
              p-rash         [1] = 0  and
              p-kassa        [1] = 0  and
              p-inv          [1] = 0  and
              p-vzvr         [1] = 0  and
              p-vzvr-post    [1] = 0  and
              p-ostatok-end  [1] = 0)) then do:
        if not sums-only then run u-line.
        run di-qnty ("кол-во", 1,"","»того по пост-ку" , trim(name),"","p").
        if show-cost then do : run di ( "учет." , 2, "","","","","p" ).  end.
        if xShowGoods then do : run di ( "в пути", 7, "","","","","p" ).  end.
        if not sums-only then run u-line.
      end.
      run clear-itemp- in this-procedure .
 End.
 if Nx = 0 Then DO:
         run di-qnty ("кол-во", 1,"","»того  объект: " , trim(name),"","o").
         if show-cost then do : run di ( "учет." , 2, "","","","","o" ).  end.
         if xshowgoods then do : run di ( "в пути", 8, "","","","","o" ).  end.
         if not sums-only then run u-line.
         run clear-itemo-.
          End.
 END PROCEDURE.


PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
    prih             [kk]  = 0
    rash             [kk]  = 0
    kassa            [kk]  = 0
    spis             [kk]  = 0
    Inv              [kk]  = 0
    Inv2             [kk]  = 0
    vzvr             [kk]  = 0
    vzvr-post        [kk]  = 0
    full-prih             [kk]  = 0
    full-rash             [kk]  = 0
    full-kassa            [kk]  = 0
    full-spis             [kk]  = 0
    full-Inv              [kk]  = 0
    full-Inv2             [kk]  = 0
    full-vzvr             [kk]  = 0
    full-vzvr-post        [kk]  = 0
    ostatok-start         [kk]  = 0
    ostatok-end           [kk]  = 0

     .
       End.
 END PROCEDURE.


PROCEDURE Clear-itemb1- :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b1-prih             [kk]  = 0
   b1-rash             [kk]  = 0
   b1-kassa            [kk]  = 0
   b1-spis             [kk]  = 0
   b1-Inv              [kk]  = 0
   b1-vzvr             [kk]  = 0
   b1-vzvr-post        [kk]  = 0
   b1-ostatok-end      [kk]  = 0
   b1-ostatok-start    [kk]  = 0
   .
       End.
 END PROCEDURE.


PROCEDURE Clear-itemb2- :
define variable kk as int no-undo.
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
define variable kk as int no-undo.
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
define variable kk as int no-undo.
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
define INPUT  parameter x-artic          like goods.artic        no-undo.
define INPUT  parameter x-prod-code      like goods.prod-code    no-undo.
define INPUT  parameter x-prod-type      like goods.prod-type    no-undo.
     FOR each temp_oborot_parts where
              temp_oborot_parts.artic        = x-artic
        AND   temp_oborot_parts.prod-code    = x-prod-code
        AND   temp_oborot_parts.prod-type    = x-prod-type
               no-lock :
        CASE temp_oborot_parts.ext-doc-type:
        /* разбивка по типам документов */
        /* приход */
             WHEN        {&TDEDT_Pri_Perem}      OR
             WHEN        {&TDEDT_Vozvrat_Perem}  OR
             WHEN        {&TDEDT_Pri_Prvo  }     THEN     DO:
           if t-in then
           ASSIGN prih[1 ]   = prih[1 ]   +  temp_oborot_parts.fact-qnty
                  prih[2 ]   = prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  prih[3 ]   = prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

           ASSIGN full-prih[1 ]   = full-prih[1 ]   +  temp_oborot_parts.fact-qnty
                  full-prih[2 ]   = full-prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-prih[3 ]   = full-prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
              end.

             WHEN        {&TDEDT_Pri_Vnesh}   THEN     DO:
           ASSIGN prih[1 ]   = prih[1 ]   +  temp_oborot_parts.fact-qnty
                  prih[2 ]   = prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  prih[3 ]   = prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-prih[1 ]   = full-prih[1 ]   +  temp_oborot_parts.fact-qnty
                  full-prih[2 ]   = full-prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-prih[3 ]   = full-prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.

         /* возврат внеш */
             WHEN        {&TDEDT_Vozvrat_Vnesh}  THEN DO:
           ASSIGN vzvr[1 ]   = vzvr[1 ]   +  temp_oborot_parts.fact-qnty
                  vzvr[2 ]   = vzvr[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  vzvr[3 ]   = vzvr[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-vzvr[1 ]   = full-vzvr[1 ]   +  temp_oborot_parts.fact-qnty
                  full-vzvr[2 ]   = full-vzvr[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-vzvr[3 ]   = full-vzvr[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.

         /* возврат пост */
             WHEN       {&TDEDT_RAS_Vnesh_VP}  THEN DO:
           ASSIGN vzvr-post[1 ]   = vzvr-post[1 ]   +  temp_oborot_parts.fact-qnty
                  vzvr-post[2 ]   = vzvr-post[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  vzvr-post[3 ]   = vzvr-post[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-vzvr-post[1 ]   = full-vzvr-post[1 ]   +  temp_oborot_parts.fact-qnty
                  full-vzvr-post[2 ]   = full-vzvr-post[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-vzvr-post[3 ]   = full-vzvr-post[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.

        /* расход */
             WHEN       {&TDEDT_Ras_Vnesh}          THEN  DO:
             ASSIGN rash[1 ]   = rash[1 ]   +  temp_oborot_parts.fact-qnty
                    rash[2 ]   = rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                    rash[3 ]   = rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                    .
             ASSIGN full-rash[1 ]   = full-rash[1 ]   +  temp_oborot_parts.fact-qnty
                    full-rash[2 ]   = full-rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                    full-rash[3 ]   = full-rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                    .

                 End.

             WHEN       {&TDEDT_Ras_Perem}       OR
             WHEN       {&TDEDT_Ras_Prvo}        THEN  DO:
           if t-in then
           ASSIGN rash[1 ]   = rash[1 ]   +  temp_oborot_parts.fact-qnty
                  rash[2 ]   = rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  rash[3 ]   = rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-rash[1 ]   = full-rash[1 ]   +  temp_oborot_parts.fact-qnty
                  full-rash[2 ]   = full-rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-rash[3 ]   = full-rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.

       /* касса */
             WHEN       {&TDEDT_Ras_Vnesh_Kass}  then
           ASSIGN kassa[1 ]   = kassa[1 ]   +  temp_oborot_parts.fact-qnty
                  kassa[2 ]   = kassa[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  kassa[3 ]   = kassa[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  full-kassa[1 ]   = full-kassa[1 ]   +  temp_oborot_parts.fact-qnty
                  full-kassa[2 ]   = full-kassa[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-kassa[3 ]   = full-kassa[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
             WHEN       {&TDEDT_Vozvrat_Vnesh_Kass} THEN  DO:
           ASSIGN kassa[1 ]   = kassa[1 ]   -  temp_oborot_parts.fact-qnty
                  kassa[2 ]   = kassa[2 ]   -  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  kassa[3 ]   = kassa[3 ]   -  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-kassa[1 ]   = full-kassa[1 ]   -  temp_oborot_parts.fact-qnty
                  full-kassa[2 ]   = full-kassa[2 ]   -  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-kassa[3 ]   = full-kassa[3 ]   -  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.
      /* инвентаризаци€ */
             WHEN       {&TDEDT_Inv}               or
             WHEN       {&TDEDT_Corr_Minus_Parts}  or
             WHEN       {&TDEDT_Peresort}          then do:
                ASSIGN  INV[1 ]   = INV[1 ]   +  temp_oborot_parts.fact-qnty
                        Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                        Inv[3 ]   = Inv[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base

                        INV2[1 ]   = INV2[1 ]   +  temp_oborot_parts.fact-qnty
                        INV2[2 ]   = INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base

                        full-INV2[1 ]   = full-INV2[1 ]   +  temp_oborot_parts.fact-qnty
                        full-INV2[2 ]   = full-INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base

                        .

             end.

             WHEN       {&TDEDT_Chg_Purch_Code}      THEN  DO:
           ASSIGN INV[1 ]   = INV[1 ]   +  temp_oborot_parts.fact-qnty
                  Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  Inv[3 ]   = Inv[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.
           when {&TDEDT_Corr_Acc_Price}  then do:
              ASSIGN
                  Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  Inv2[2 ]   = Inv2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-INV2[2 ]   = full-INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  .

           end.
        /* —писание */
             WHEN       {&TDEDT_Spi_Vnesh}       THEN  DO:
           ASSIGN spis[1 ]   = spis[1 ]   +  temp_oborot_parts.fact-qnty
                  spis[2 ]   = spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  spis[3 ]   = spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-spis[1 ]   = full-spis[1 ]   +  temp_oborot_parts.fact-qnty
                  full-spis[2 ]   = full-spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-spis[3 ]   = full-spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.

             WHEN       {&TDEDT_Spi_Prvo}       THEN  DO:
           if t-in then
           ASSIGN spis[1 ]   = spis[1 ]   +  temp_oborot_parts.fact-qnty
                  spis[2 ]   = spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  spis[3 ]   = spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-spis[1 ]   = full-spis[1 ]   +  temp_oborot_parts.fact-qnty
                  full-spis[2 ]   = full-spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-spis[3 ]   = full-spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .

                 End.
          End CASE.
   End.


END PROCEDURE.


procedure ost-line :
 do
 on error undo, return error return-value
 :
define INPUT  parameter x-artic          like goods.artic        no-undo.
define INPUT  parameter x-prod-code      like goods.prod-code    no-undo.
define INPUT  parameter x-prod-type      like goods.prod-type    no-undo.

 define variable ostatok-today as decimal EXTENT 10  no-undo .
 ostatok-today[1] = 0 .
 ostatok-today[2] = 0 .
 define buffer ost_parts for parts .
 for each obj-list :
    for each ost_parts no-lock where
        ost_parts.artic     = x-artic             and
        ost_parts.prod-type = x-prod-type         and
        ost_parts.prod-code = x-prod-code         and
        ost_parts.host-code = v-cntxt-host-code-obj         and
        ost_parts.supp-type = g#post-f.obj-type     and
        ost_parts.supp-code = g#post-f.obj-code     and
        ost_parts.status_   =  false              and
        ost_parts.obj-type  =  obj-list.obj-type  and
        ost_parts.obj-code  =  obj-list.obj-code  and
        ost_parts.in-code   <> ost_parts.out-code and
        ost_parts.rsrv-free = true    :

        if type-stor <> 1 then do:  /* по типам приобретени€ */
           if ost_parts.purch-code <>  type-stor - 1 then next.
        end.


        if ost_parts.out-code = {&free-code} then do:
           ostatok-today[1] = ostatok-today[1] + ost_parts.fact-qnty .
           ostatok-today[2] = ostatok-today[2] + ost_parts.fact-qnty  * (if tprintrubl  = true then ost_parts.price-rubl else ost_parts.price-base).
        end.
        else do:
            ostatok-today[1] = ostatok-today[1] + abs(ost_parts.fact-qnty) .
            ostatok-today[2] = ostatok-today[2] + abs(ost_parts.fact-qnty) * (if tprintrubl  = true then ost_parts.price-rubl else ost_parts.price-base) .
        end.
    end.
  end.


 define variable oborot1  as decimal no-undo .
 define variable oborot12 as decimal no-undo .
 define variable oborot2  as decimal no-undo .
 define variable oborot22 as decimal no-undo .
 assign
  oborot1  = 0
  oborot12 = 0
  oborot2  = 0
  oborot22 = 0
  .

  if type-stor <> 1 then do:  /* по типам приобретени€ */
      assign
        oborot1  = full-prih[1] - full-rash[1] - full-kassa[1] - full-vzvr-post[1] + full-vzvr[1] - full-spis[1] + inv[1]
        oborot12 = full-prih[2] - full-rash[2] - full-kassa[2] - full-vzvr-post[2] + full-vzvr[2] - full-spis[2] + inv[2]
      .
  end.
  else
    assign
        oborot1  = full-prih[1] - full-rash[1] - full-kassa[1] - full-vzvr-post[1] + full-vzvr[1] - full-spis[1] + full-inv2[1]
        oborot12 = full-prih[2] - full-rash[2] - full-kassa[2] - full-vzvr-post[2] + full-vzvr[2] - full-spis[2] + full-inv2[2]

    .


 if x-date-start = today then  do:
    ostatok-end  [1]  = ostatok-today [1].
    ostatok-end  [2]  = ostatok-today [2].
    ostatok-start[1]  = ostatok-today [1] .
    ostatok-start[2]  = ostatok-today [2] .
    end.
 if x-date-end   = today then do:
    ostatok-end  [1]    = ostatok-today [1] .
    ostatok-end  [2]    = ostatok-today [2] .
    ostatok-start[1]    = ostatok-today [1]  - oborot1 .
    ostatok-start[2]    = ostatok-today [2]  - oborot12 .
    end.

 if x-date-end   < today then do:
   /* оборот от x-date-end + 1 до today  */
   oborot2  = 0 .
   oborot22 = 0 .

    run ob-line2 in this-procedure ( input x-artic     ,
                  input x-prod-code ,
                  input x-prod-type ,
                  input x-date-end + 1 ,
                  input today   ,
                  output oborot2 ,
                  output oborot22
                    ) .
    ostatok-end  [1]    = ostatok-today [1] - oborot2 .
    ostatok-end  [2]    = ostatok-today [2] - oborot22 .
    ostatok-start[1]    = ostatok-today [1] - (oborot1 + oborot2)  .
    ostatok-start[2]    = ostatok-today [2] - (oborot12 + oborot22)  .
 end.
  if xShowGoods Then DO :
      run goods-way in this-procedure (
        input x-artic     ,
        input x-prod-code ,
        input x-prod-type ,
        input 1 ,
        output ostatok-start  [7] ) .
      run goods-way in this-procedure (
        input x-artic     ,
        input x-prod-code ,
        input x-prod-type ,
        input 2 ,
        output ostatok-end  [7] ) .
  end.

 end. /* do */
end procedure. /* ost-line */

PROCEDURE Calc-Sub-itog :                                            /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.
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


procedure display-part :
 do
 on error undo, return error return-value
 :
 define variable t-str as character no-undo .
 define variable t-str-tp as character no-undo .

 run get-name-from-ext-type in this-procedure  (
      input  temp_oborot_parts.ext-doc-type ,
      input  false                          ,
      output t-str                          )
      .
 t-str-tp  = entry (lookup (string(temp_oborot_parts.purch-code), {&purchase-codes}), {&purchase-codes-full}) .

   DISPLAY stream  OutStream {&ALL-Sym} sym11 sym12 sym13
    string(temp_oborot_parts.fact-date,"99/99/99")  @ gds-zap-b-code
    string(temp_oborot_parts.in-code  + if temp_oborot_parts.part-code <> ""  then ( "/" + temp_oborot_parts.part-code) else " ")  @ gds-zap-artic
    temp_oborot_parts.out-code + " " + t-str  @ gds-zap-gds-name
    "---"      @ gds-zap-unit-base
    t-str-tp   @ gds-type
    string(temp_oborot_parts.fact-qnty,"->>>>>>>>9.99") @ F-ostatok-start
    string(temp_oborot_parts.obj-code) +  " " + temp_oborot_parts.obj-type @ F-prih
    {&WFz} .
    DOWN stream OutStream 1 with FRAME ZAPAS.

  {&PutExcel}
    "от " + string(temp_oborot_parts.fact-date,"99.99.99")  {&tabulation}
    string(temp_oborot_parts.in-code  + if temp_oborot_parts.part-code <> ""  then ( "/" + temp_oborot_parts.part-code) else " ")  {&tabulation}
    temp_oborot_parts.out-code + " " + t-str                                                                                       {&tabulation}
    t-str-tp   {&tabulation}
    string(temp_oborot_parts.fact-qnty,"->>>>>>>>9.99") {&tabulation}
    string(temp_oborot_parts.obj-code) +  " " + temp_oborot_parts.obj-type  {&tabulation}
   {&new-line}.
 end. /* do */
end procedure. /* display-part. */


procedure ob-line2 :
 do
 on error undo, return error return-value
 :
define input parameter  x-artic     as character no-undo .
define input parameter  x-prod-code as integer no-undo .
define input parameter  x-prod-type as character no-undo .
define input parameter  p-date-1 as date no-undo .
define input parameter  p-date-2  as date no-undo .
define output parameter proc-oborot  as decimal no-undo .
define output parameter proc-oborot-2 as decimal no-undo .
proc-oborot   = 0 .
proc-oborot-2 = 0 .
define buffer buf-2_temp_oborot_parts for temp_oborot_parts-2.
define buffer buf_parts2 for parts.


for each buf-2_temp_oborot_parts : delete buf-2_temp_oborot_parts. end.

  for each obj-list :
    for each buf_parts2 no-lock where
        buf_parts2.host-code = v-cntxt-host-code-obj        and
        buf_parts2.obj-code  = obj-list.obj-code  and
        buf_parts2.obj-type  = obj-list.obj-type  and
        buf_parts2.supp-type = g#post-f.obj-type  and
        buf_parts2.supp-code = g#post-f.obj-code  and
        buf_parts2.status_   = true               and
        buf_parts2.artic        = x-artic         and
        buf_parts2.prod-code    = x-prod-code     and
        buf_parts2.prod-type    = x-prod-type     and
        buf_parts2.fact-date >= p-date-1          and
        buf_parts2.fact-date <= p-date-2

    :

        find first trn-doc no-lock where trn-doc.doc-code     = buf_parts2.out-code   no-error .
            if not available trn-doc then next.

        create buf-2_temp_oborot_parts.
        BUFFER-COPY buf_parts2  to buf-2_temp_oborot_parts
            assign
              buf-2_temp_oborot_parts.ext-doc-type = trn-doc.ext-doc-type.
     end.
     end.


     FOR each buf-2_temp_oborot_parts no-lock :
        if type-stor <> 1 then do:
           /* по типам приобретени€ */
           if buf-2_temp_oborot_parts.purch-code <>  type-stor - 1 then next.
        end.
        CASE buf-2_temp_oborot_parts.ext-doc-type:
        /* разбивка по типам документов */
        /* приход */
             WHEN        {&TDEDT_Pri_Perem}      OR
             WHEN        {&TDEDT_Vozvrat_Perem}  OR
             WHEN        {&TDEDT_Pri_Prvo  }     THEN     DO:
           ASSIGN proc-oborot   = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .

                 End.

             WHEN        {&TDEDT_Inv}       or
             WHEN        {&TDEDT_Pri_Vnesh} or
             WHEN        {&TDEDT_Peresort}  THEN     DO:
           ASSIGN proc-oborot   = proc-oborot   +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .


                 End.

         /* возврат внеш */
             WHEN        {&TDEDT_Vozvrat_Vnesh}  THEN DO:
           ASSIGN proc-oborot   = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .


                 End.

         /* возврат пост */
             WHEN       {&TDEDT_RAS_Vnesh_VP}  THEN DO:
           ASSIGN proc-oborot   = proc-oborot  -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .


                 End.

        /* расход */
             WHEN       {&TDEDT_Ras_Vnesh}          THEN  DO:
             ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                    .

                 End.

             WHEN       {&TDEDT_Ras_Perem}       OR
             WHEN       {&TDEDT_Ras_Prvo}        THEN  DO:
           ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .

                 End.

       /* касса */
             WHEN       {&TDEDT_Ras_Vnesh_Kass}  then
                     ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                            proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                            .
             WHEN       {&TDEDT_Vozvrat_Vnesh_Kass} THEN
                      ASSIGN proc-oborot   = proc-oborot   +  buf-2_temp_oborot_parts.fact-qnty
                             proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                             .

        /* —писание */
             WHEN       {&TDEDT_Spi_Vnesh}       THEN  DO:
           ASSIGN proc-oborot  = proc-oborot  -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .

                 End.

             WHEN       {&TDEDT_Spi_Prvo}       THEN  DO:
           ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  - buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .

                 End.

             WHEN       {&TDEDT_Chg_Purch_Code}       THEN  DO:
             if type-stor <> 1 then do:
                 ASSIGN proc-oborot  = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                        proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .

                 End.
              end.

             WHEN       {&TDEDT_Corr_Acc_Price}       THEN  DO:
                 ASSIGN
                   proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
              end.

          End CASE.
   End.
 end. /* do */
end procedure. /* ob-line2 */


procedure dobor :
 do
 on error undo, return error return-value
 :
 /* товары с нулевыми оборотами но с остатками  */
 define buffer buf1_parts for parts.
 for each obj-list :
    for each buf1_parts no-lock where
        buf1_parts.host-code = v-cntxt-host-code-obj         and
        buf1_parts.supp-type = g#post-f.obj-type     and
        buf1_parts.supp-code = g#post-f.obj-code     and
        buf1_parts.status_   =  false              and
        buf1_parts.obj-type  =  obj-list.obj-type  and
        buf1_parts.obj-code  =  obj-list.obj-code  and
        buf1_parts.in-code   <> buf1_parts.out-code and
        buf1_parts.rsrv-free = true    :

        if type-stor <> 1 then do: /* по типам приобретени€ */
           if buf1_parts.purch-code <>  type-stor - 1 then next.
        end.

        if not can-find ( first temp-t-post-stk-line where
                                  temp-t-post-stk-line.artic     = buf1_parts.artic     and
                                  temp-t-post-stk-line.prod-type = buf1_parts.prod-type and
                                  temp-t-post-stk-line.prod-code = buf1_parts.prod-code /* and
                                  temp-t-post-stk-line.cli-type = buf1_parts.supp-type and
                                  temp-t-post-stk-line.cli-code = buf1_parts.supp-code    */
                                  ) and
             not can-find ( first temp-null where
                                  temp-null.artic     = buf1_parts.artic     and
                                  temp-null.prod-type = buf1_parts.prod-type and
                                  temp-null.prod-code = buf1_parts.prod-code /* and
                                  temp-null.cli-type  = buf1_parts.supp-type and
                                  temp-null.cli-code  = buf1_parts.supp-code    */
                                  )
                   then do:
                      find first goods no-lock where goods.artic    = buf1_parts.artic     and
                                                    goods.prod-type = buf1_parts.prod-type and
                                                    goods.prod-code = buf1_parts.prod-code no-error .
                      if not available goods then next.

                      create temp-null.
                      assign
                        temp-null.artic     = buf1_parts.artic
                        temp-null.prod-type = buf1_parts.prod-type
                        temp-null.prod-code = buf1_parts.prod-code
                        temp-null.gds-name  = goods.gds-name
                        temp-null.unit-base = goods.unit-base
                        temp-null.prt-root  = 0
                        temp-null.Goods-grp-name   = goods.grp-name
                        temp-null.gds-code         = goods.gds-code
                        temp-null.gds-type         = goods.gds-type
                        temp-null.Cli-type         = g#post-f.obj-type
                        temp-null.Cli-code         = g#post-f.obj-code
                        temp-null.Clients-grp-name = g#post-f.obj-name
                      .
                     end.
    end.
end.
run super-dobor in this-procedure .
for each temp-null :
   run clear-item in this-procedure .
   run ost-line in this-procedure  (
   temp-null.artic    ,
   temp-null.prod-code,
   temp-null.prod-type  )  .
   run calc-sub-itog (0).
   run calc-sub-itog (6).
      if x-type-itog <> 1 then do:

        gds-post-artic =  temp-null.artic .
        if Show-Negativ = true then do:
              gds-post-artic = "".
              find first ub.ext-artic no-lock where
                      ub.ext-artic.gds-code = temp-null.gds-code and
                      ub.ext-artic.cli-type = temp-null.Cli-type and
                      ub.ext-artic.cli-code = temp-null.Cli-code and
                      ub.ext-artic.status_   =  {&current-status} no-error .
              if available ub.ext-artic then do:
                    assign
                      gds-post-artic     = ub.ext-artic.ext-artic
                    .
        end.

         run di-qnty ("кол-во", 1, temp-null.gds-code,gds-post-artic,temp-null.gds-name,temp-null.unit-base,"").
         if show-cost then do : run di ( "учет." , 2, "","","","","" ).  end.
         if xshowgoods then do : run di ( "в пути" , 7, "","","","","" ).  end.
        end.
      end.
  run clear-item in this-procedure .
end.

 end. /* do */
end procedure. /* dobor */



procedure goods-way :
 do
 on error undo, return error return-value
 :
    /*“овар в пути на конец заданной даты.*/
define input  parameter x-artic          like goods.artic        no-undo.
define input  parameter x-prod-code      like goods.prod-code    no-undo.
define input  parameter x-prod-type      like goods.prod-type    no-undo.
define input parameter x-date as integer no-undo .
define output parameter x-qnty as decimal no-undo .
define buffer way_parts for parts.
define buffer way_trn-doc for trn-doc.
define buffer way_doc-line for doc-line.
x-qnty = 0 .

if x-date = 1 then do:     /* перва€ точка ------------------------------------------------------------------------------*/
      /* закрытые документы ««««««««««««««««««««« */
      for each obj-list :
            /* приход */
            for each way_doc-line no-lock where
                      way_doc-line.obj-type   = obj-list.obj-type       and
                      way_doc-line.obj-code   = obj-list.obj-code       and
                      way_doc-line.prod-type  = x-prod-type             and
                      way_doc-line.prod-code  = x-prod-code             and
                      way_doc-line.artic       = x-artic                and
                      way_doc-line.ext-doc-type  = {&TDEDT_Pri_Perem}   and
                      way_doc-line.status_     = {&fact}                and
                      way_doc-line.fact-order  > fact-order-1
                      :
                      if can-find (first way_trn-doc no-lock  where
                              way_trn-doc.doc-code  = way_doc-line.doc-code and
                              way_trn-doc.fact-date > way_trn-doc.doc-date  and
                              way_trn-doc.doc-date  < x-date-start )
                              then do:
                                for each way_parts no-lock where
                                      way_parts.out-code = way_doc-line.doc-code   and
                                      way_parts.supp-type = g#post-f.obj-type   and
                                      way_parts.supp-code = g#post-f.obj-code   and
                                      way_parts.obj-type = way_doc-line.obj-type   and
                                      way_parts.obj-code = way_doc-line.obj-code   and
                                      way_parts.prod-type  = way_doc-line.prod-type   and
                                      way_parts.prod-code  = way_doc-line.prod-code   and
                                      way_parts.artic      = way_doc-line.artic     and
                                      way_parts.status_    = true
                                      :
                                      x-qnty = x-qnty + way_parts.fact-qnty.
                                end.  /* партии */
                      end. /* нужный документ */
            end.
            /* возврат */
            for each way_doc-line no-lock where
                way_doc-line.obj-type   = obj-list.obj-type                and
                way_doc-line.obj-code   = obj-list.obj-code                and
                way_doc-line.prod-type  = x-prod-type                      and
                way_doc-line.prod-code  = x-prod-code                      and
                way_doc-line.artic       = x-artic                         and
                way_doc-line.ext-doc-type  = {&TDEDT_Vozvrat_Perem}        and
                way_doc-line.status_     = {&fact}                         and
                way_doc-line.fact-order  > fact-order-1
                :

                if can-find (first way_trn-doc no-lock  where
                      way_trn-doc.doc-code  = way_doc-line.doc-code and
                      way_trn-doc.fact-date >= way_trn-doc.doc-date  and
                      way_trn-doc.doc-date  < x-date-start
                      ) then do:
                          for each way_parts no-lock where
                              way_parts.out-code = way_doc-line.doc-code   and
                              way_parts.supp-type = g#post-f.obj-type   and
                              way_parts.supp-code = g#post-f.obj-code   and
                              way_parts.obj-type = way_doc-line.obj-type   and
                              way_parts.obj-code = way_doc-line.obj-code   and
                              way_parts.prod-type  = way_doc-line.prod-type   and
                              way_parts.prod-code  = way_doc-line.prod-code   and
                              way_parts.artic      = way_doc-line.artic     and
                              way_parts.status_    = true
                              :
                              x-qnty = x-qnty - way_parts.fact-qnty.
                          end.  /* партии */
                      end.
            end.
            /* открытые документы ќќќќќќќќќќќќќќќќќќ */
            for each way_trn-doc no-lock  where
                    (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                    way_trn-doc.status_ = {&wayb}            and
                    way_trn-doc.fact-order = 0               and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = {&income}         and
                    way_trn-doc.doc-date  < x-date-start     and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem})
                      or
                    (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                    way_trn-doc.status_ = {&wayb}            and
                    way_trn-doc.fact-order = 0               and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = {&return}         and
                    way_trn-doc.doc-date  < x-date-start     and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = {&TDEDT_Vozvrat_Perem} )
                    :
                      if can-find ( first  way_doc-line no-lock where
                          way_doc-line.doc-code   = way_trn-doc.doc-code   and
                          way_doc-line.prod-type  = x-prod-type            and
                          way_doc-line.prod-code  = x-prod-code            and
                          way_doc-line.artic       = x-artic ) then do:
                            for each way_parts no-lock where
                                      way_parts.out-code   = way_trn-doc.doc-code   and
                                      way_parts.supp-type  = g#post-f.obj-type   and
                                      way_parts.supp-code  = g#post-f.obj-code   and
                                      way_parts.obj-type   = way_trn-doc.obj-type   and
                                      way_parts.obj-code   = way_trn-doc.obj-code   and
                                      way_parts.prod-type  = x-prod-type   and
                                      way_parts.prod-code  = x-prod-code   and
                                      way_parts.artic      = x-artic     and
                                      way_parts.status_    = false
                                      :
                                      if way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem} then
                                          x-qnty = x-qnty + way_parts.fact-qnty.
                                      else
                                          x-qnty = x-qnty - way_parts.fact-qnty.
                                      end.
                            end.  /* партии */
                      end.  /*товар найден */
      end. /* по объектам */
end. /* 1 point */

else do: /* 2 point -----------------------------------------------------------------------------------------------------*/
   if x-date-end < today then do:
      /* закрытые документы  «««««««««««««««««««««  */
      for each obj-list :
            for each way_trn-doc no-lock  where
                    (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                    way_trn-doc.status_ = {&fact}            and
                    way_trn-doc.fact-order > fact-order-2    and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = {&income}         and
                    way_trn-doc.doc-date  <= x-date-end      and
                    way_trn-doc.fact-date  > x-date-end      and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem})
                      or
                    (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                    way_trn-doc.status_ = {&fact}            and
                    way_trn-doc.fact-order > fact-order-2    and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = {&return}         and
                    way_trn-doc.doc-date  <= x-date-end      and
                    way_trn-doc.fact-date  > x-date-end      and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = {&TDEDT_Vozvrat_Perem} )
                    :
                    if can-find( first  way_doc-line no-lock where
                        way_doc-line.doc-code   = way_trn-doc.doc-code   and
                        way_doc-line.prod-type  = x-prod-type            and
                        way_doc-line.prod-code  = x-prod-code            and
                        way_doc-line.artic       = x-artic  )
                        then do:
                          for each way_parts no-lock where
                                    way_parts.out-code   = way_trn-doc.doc-code   and
                                    way_parts.supp-type  = g#post-f.obj-type   and
                                    way_parts.supp-code  = g#post-f.obj-code   and
                                    way_parts.obj-type   = obj-list.obj-type   and
                                    way_parts.obj-code   = obj-list.obj-code   and
                                    way_parts.prod-type  = x-prod-type   and
                                    way_parts.prod-code  = x-prod-code   and
                                    way_parts.artic      = x-artic     and
                                    way_parts.status_    = true
                                    :
                                    if way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem} then
                                        x-qnty = x-qnty + way_parts.fact-qnty.
                                    else
                                        x-qnty = x-qnty - way_parts.fact-qnty.
                                    end.
                          end.  /* партии */
                    end. /* товар найден */
      end. /* по объектам */

   end.

   if x-date-end <= today then do:
      /* открытые документы ќќќќќќќќќќќќќќќќќќ */
      for each obj-list :
            for each way_trn-doc no-lock  where
                      (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                      way_trn-doc.status_ = {&wayb}            and
                      way_trn-doc.fact-order = 0               and
                      way_trn-doc.internal = true              and
                      way_trn-doc.doc-type = {&income}         and
                      way_trn-doc.doc-date  <= x-date-end       and
                      way_trn-doc.obj-type = obj-list.obj-type and
                      way_trn-doc.obj-code = obj-list.obj-code and
                      way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem})
                        or
                      (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                      way_trn-doc.status_ = {&wayb}            and
                      way_trn-doc.fact-order = 0               and
                      way_trn-doc.internal = true              and
                      way_trn-doc.doc-type = {&return}         and
                      way_trn-doc.doc-date  <= x-date-end       and
                      way_trn-doc.obj-type = obj-list.obj-type and
                      way_trn-doc.obj-code = obj-list.obj-code and
                      way_trn-doc.ext-doc-type  = {&TDEDT_Vozvrat_Perem} )
                      :
                        if can-find (first  way_doc-line no-lock where
                            way_doc-line.doc-code   = way_trn-doc.doc-code   and
                            way_doc-line.prod-type  = x-prod-type            and
                            way_doc-line.prod-code  = x-prod-code            and
                            way_doc-line.artic       = x-artic ) then do:
                              for each way_parts no-lock where
                                        way_parts.out-code   = way_trn-doc.doc-code   and
                                        way_parts.supp-type  = g#post-f.obj-type   and
                                        way_parts.supp-code  = g#post-f.obj-code   and
                                        way_parts.obj-type   = obj-list.obj-type   and
                                        way_parts.obj-code   = obj-list.obj-code   and
                                        way_parts.prod-type  = x-prod-type   and
                                        way_parts.prod-code  = x-prod-code   and
                                        way_parts.artic      = x-artic     and
                                        way_parts.status_    = false
                                        :
                                        if way_trn-doc.ext-doc-type  = {&TDEDT_Pri_Perem} then
                                            x-qnty = x-qnty + way_parts.fact-qnty.
                                        else
                                            x-qnty = x-qnty - way_parts.fact-qnty.
                                        end.
                              end.  /* партии */
                        end. /* товар найден */
      end. /* по объектам */
    end. /* today */
end.


 end. /* do */
end procedure. /* goods-way */

procedure clear-tt :
 do
 on error undo, return error return-value
 :
  for each temp-t-post-stk-line :
      delete  temp-t-post-stk-line.
  end.
  for each temp_oborot_parts :
      delete temp_oborot_parts.
  end.
  for each temp_oborot_parts-2 :
      delete temp_oborot_parts-2.
  end.

  for each temp-null :
      delete temp-null.
  end.
 end. /* do */
end procedure. /* clear-tt */


procedure first-line-p :
 do
 on error undo, return error return-value
 :
    if x-type-itog = 3  and p-first = true  then DO:
      DISPLAY stream  OutStream {&ALL-Sym} sym11 sym12 sym13
        "ƒата"          @ gds-zap-b-code
        "Ќомер партии"  @ gds-zap-artic
          "ƒокумент"     @ gds-zap-gds-name
          " "            @ gds-zap-unit-base
        "“ип пр"        @ gds-type
        " ол-во партии" @ F-ostatok-start
        "ќбъект"        @ F-prih
        {&WFz} .
        DOWN stream OutStream 1 with FRAME ZAPAS.
        run u-line in this-procedure .
        p-first = false  .
    end.

 end. /* do */
end procedure. /* first-line-p */

procedure run1 :
 do
 on error undo, return error return-value
 :
  run clear-itemp-  in this-procedure .
  /* только по поставщику */
    if x-type-itog = 1 then do:
      for each temp-t-post-stk-line :
            run ob-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run ost-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .

            run calc-sub-itog in this-procedure  (0).
            run calc-sub-itog in this-procedure  (6).
            run clear-item in this-procedure .
      end.
      run dobor in this-procedure .
    end.
  /* по товарам */
  /* название поставщика */
  if x-type-itog <> 1 then DO:
    if can-find ( first temp-t-post-stk-line ) then do:
           run first-line-p in this-procedure .
           run print-header in this-procedure ( 3 , g#post-f.obj-name) .
     end.

      for each temp-t-post-stk-line :
          run display-line in this-procedure .
          /* по парти€м */
              if x-type-itog = 3 then do :
                  for each temp_oborot_parts where
                      temp_oborot_parts.artic     = temp-t-post-stk-line.artic      and
                      temp_oborot_parts.prod-type = temp-t-post-stk-line.prod-type  and
                      temp_oborot_parts.prod-code = temp-t-post-stk-line.prod-code
                  :
                      run display-part in this-procedure .
                  end.
              end.
      end.
      run dobor in this-procedure .
  end.
  /* итого по поставщику */
  run print-footer in this-procedure ( 3 , g#post-f.obj-name ).
  run clear-tt in this-procedure .
 end. /* do */
end procedure. /* run1 */




procedure run2 :
 do
 on error undo, return error return-value
 :
define variable ng as character no-undo .
define variable v-new as character no-undo .
define variable v-old as character no-undo .
define variable ff as logical   no-undo .

v-old = "" .
ff = true .
  if  xLavel > 0 then  do:
      for each g#post-f
               break by g#post-f.grp-name
               :
        ng = n-lavel (g#post-f.grp-name ,  xLavel )  .
        v-new = n-lavel (g#post-f.grp-name ,  xLavel )  .
        if v-new <> v-old and ff = true   then do:
          run print-header ( 1 , ng ).
          ff = false .
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if v-new <> v-old and ff = false then do:
            run print-footer in this-procedure ( 1 , ng ).
            run clear-itemb1-  in this-procedure .
            ff = true .
        end.
        v-old = n-lavel (g#post-f.grp-name,xLavel ).
      end.
  end.
  else do:
      for each g#post-f break by g#post-f.grp-name :
        if first-of(g#post-f.grp-name) then do:
           run print-header in this-procedure ( 1 , g#post-f.grp-name ).
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if last-of(g#post-f.grp-name) then do:
           run print-footer in this-procedure ( 1 , g#post-f.grp-name ).
           run clear-itemb1-  in this-procedure .
        end.
      end.
  end.


 end. /* do */
end procedure. /* run2 */



procedure run3 :
do
on error undo, return error return-value
:
define variable ng as character no-undo .
define variable v-new as character no-undo .
define variable v-old as character no-undo .
define variable ff as logical   no-undo .

v-old = "" .
ff = true .

  if  xLavel > 0 then  do:
      for each g#post-f break by g#post-f.grp-name  :
        v-new = n-lavel (g#post-f.grp-name ,  xLavel )  .
        ng = n-lavel (g#post-f.grp-name ,  xLavel )  .
        if v-new <> v-old and ff = true then do:
           run Print-Header  in this-procedure ( 1 , ng ).
           ff = false .
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if v-new <> v-old and ff = false  then do:
            run print-footer in this-procedure ( 1 , ng ).
            run clear-itemb1- in this-procedure .
            ff = true .
        end.
        v-old = n-lavel (g#post-f.grp-name ,  xLavel )  .
      end.

  end.
  else do:
      for each g#post-f break by g#post-f.grp-name :
        if first-of(g#post-f.grp-name) then do:
           run print-header in this-procedure  ( 1 , g#post-f.grp-name ).
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if last-of(g#post-f.grp-name) then do:
           run print-footer in this-procedure ( 1 , g#post-f.grp-name ).
           run clear-itemb1-  in this-procedure .
        end.
      end.
  end.


 end. /* do */
end procedure. /* run3 */

procedure run1-grp :
 do
 on error undo, return error return-value
 :
  run Clear-itemp-  in this-procedure .
  /* только по поставщику */
    if x-type-itog = 1 then do:
      for each temp-t-post-stk-line :
            run ob-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run ost-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .

            run Calc-Sub-itog  in this-procedure (0).
            run Calc-Sub-itog  in this-procedure (6).
            run Clear-item in this-procedure .
      end.
      run dobor in this-procedure .
    end.
  /* по товарам */
  /* название поставщика */
  if x-type-itog <> 1 then DO:
    if can-find ( first temp-t-post-stk-line ) then do:
           run first-line-p in this-procedure .
           Run Print-Header in this-procedure ( 3 , g#post-f.obj-name) .
     end.

      for each temp-t-post-stk-line :
          run display-line in this-procedure .
          /* по парти€м */
              if x-type-itog = 3 then do :
                  for each temp_oborot_parts where
                      temp_oborot_parts.artic     = temp-t-post-stk-line.artic      and
                      temp_oborot_parts.prod-type = temp-t-post-stk-line.prod-type  and
                      temp_oborot_parts.prod-code = temp-t-post-stk-line.prod-code
                  :
                      run display-part in this-procedure .
                  end.
              end.
      end.
      run dobor in this-procedure .
  end.
  /* итого по поставщику */
  run print-footer in this-procedure ( 3 , g#post-f.obj-name ).
  run clear-tt in this-procedure .
 end. /* do */
end procedure. /* run-grp */




procedure super-dobor :
 do
 on error undo, return error return-value
 :
 /* товары с date-start - today */

 define buffer buf1_parts for parts.
 if x-date-end >= today then return.

  for each obj-list :
    for each buf1_parts no-lock where
        buf1_parts.host-code = v-cntxt-host-code-obj         and
        buf1_parts.supp-type = g#post-f.obj-type   and
        buf1_parts.supp-code = g#post-f.obj-code   and
        buf1_parts.status_   =  true               and
        buf1_parts.obj-type  =  obj-list.obj-type  and
        buf1_parts.obj-code  =  obj-list.obj-code  and
        buf1_parts.fact-date >= x-date-start      :
        if type-stor <> 1 then do: /* по типам приобретени€ */
           if buf1_parts.purch-code <>  type-stor - 1 then next.
        end.

        if not can-find ( first temp-t-post-stk-line where
                                  temp-t-post-stk-line.artic     = buf1_parts.artic     and
                                  temp-t-post-stk-line.prod-type = buf1_parts.prod-type and
                                  temp-t-post-stk-line.prod-code = buf1_parts.prod-code /* and
                                  temp-t-post-stk-line.cli-type = buf1_parts.supp-type and
                                  temp-t-post-stk-line.cli-code = buf1_parts.supp-code    */
                                  ) and
             not can-find ( first temp-null where
                                  temp-null.artic     = buf1_parts.artic     and
                                  temp-null.prod-type = buf1_parts.prod-type and
                                  temp-null.prod-code = buf1_parts.prod-code /* and
                                  temp-null.cli-type  = buf1_parts.supp-type and
                                  temp-null.cli-code  = buf1_parts.supp-code    */
                                  )
                   then do:
                      find first goods no-lock where goods.artic    = buf1_parts.artic     and
                                                    goods.prod-type = buf1_parts.prod-type and
                                                    goods.prod-code = buf1_parts.prod-code no-error .
                      if not available goods then next.

                      create temp-null.
                      assign
                        temp-null.artic     = buf1_parts.artic
                        temp-null.prod-type = buf1_parts.prod-type
                        temp-null.prod-code = buf1_parts.prod-code
                        temp-null.gds-name  = goods.gds-name
                        temp-null.unit-base = goods.unit-base
                        temp-null.prt-root  = 0
                        temp-null.Goods-grp-name   = goods.grp-name
                        temp-null.gds-code         = goods.gds-code
                        temp-null.gds-type         = goods.gds-type
                        temp-null.Cli-type         = g#post-f.obj-type
                        temp-null.Cli-code         = g#post-f.obj-code
                        temp-null.Clients-grp-name = g#post-f.obj-name
                      .
                     end.
    end.
  end.
 end. /* do */
end procedure. /* super-dobor */