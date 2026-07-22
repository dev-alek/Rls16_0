/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Остатки товара по объекту

Автор: Чернова Светлана Александровна
Дата создания: 14/12/00
Author: Svetlana Chernova
Creation date: 14/12/00

*/
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify    as character            no-undo.
define input parameter xSortType    as character            no-undo.
define input parameter xSumsOnly    as logical              no-undo.
define input parameter xShowZero    as logical              no-undo.
define input parameter xTog-obj     as logical              no-undo.
define input parameter  xtog-lavel  as logical              no-undo.
define input parameter  xvar-lavel  as integer              no-undo.

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Остатки товара по объекту ".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/waitfram.i }
{ rep/rep-bt.i   }

define variable v-dop-bc    as character no-undo .
define variable flag-dop-bc as logical no-undo .
define variable tPrintRubl  as logical no-undo.

define  stream  OutStream.
define  stream  OutStream2.
/*общий итог*/

define variable    ObjName           as   character  no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   character   no-undo.
define variable    RetSortType       as   character   no-undo.
define variable    Show-Negativ      as   logical  no-undo.
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   character         no-undo.
define variable    FirstLine         as   logical     no-undo.

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* Local Variable Definitions ---                                       */

define variable stat      as logical no-undo .
define variable InpError  as logical no-undo .
define variable i         as integer init 0  no-undo .
define variable R         as integer init 0  no-undo .
define variable ii        as integer init 0  no-undo .
define variable rr        as integer init 0 no-undo .
define variable f-ii      as character  no-undo .
define variable p         as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable rid-list  as character no-undo .
define  variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define  variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define  variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define  variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define  variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define  variable gds-zap-artic         like ub.goods.artic        no-undo .
define  variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define  variable gds-type              as character  no-undo.
define  variable gds-zap-type          like ub.goods.gds-type     no-undo .
define  variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define  variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define  variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define  variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define  variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define  variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define  variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.
define  variable F-ostatok-start    as   character   no-undo.
define  variable F-ostatok-End      as   character   no-undo.
define  variable ostatok-start      as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable ostatok-End        as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable B1-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable B1-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable B2-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable B2-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable Bi-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable Bi-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define  variable F-prih             as   character   no-undo.
define  variable F-rash             as   character   no-undo.
define  variable F-kassa1            as   character   no-undo.
define  variable F-kassa2            as   character   no-undo.
define  variable F-kassa3            as   character   no-undo.
define  variable F-kassa4            as   character   no-undo.
define  variable F-kassa5            as   character   no-undo.
define  variable F-kassa6            as   character   no-undo.
define  variable F-Inv              as   character   no-undo.
define  variable F-Overturn         as   character   no-undo.
define  variable f-zakaz            as   decimal  no-undo.
define  variable F-Center-stock     as   decimal  no-undo.
define  variable F-avr              as   decimal  no-undo.
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
define variable  temp-str as character  no-undo.

define variable str as character  format "X(60)" no-undo.
define variable i#i as integer   no-undo.
define variable xLavel as integer   no-undo.
define variable list-field as character  no-undo.
define variable str10 as character  no-undo.
define BUFFER stk-line2 FOR ub.stk-line  .

define  temp-table tmp#obj-list  NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field B1-ostatok-end   as   decimal EXTENT 6
    field BI-ostatok-end   as   decimal EXTENT 6
    field    ostatok-end   as   decimal EXTENT 6
.
define variable type-a as character no-undo .


     assign
        i             = 0
        xlavel        = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        FirstLine     = FALSE.
        Line          = fill("-", {&DOS_CW_2}).
        x-SelectObject = "":U .
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        xTog-obj = false
        .
        if PayType  = 2  then do:
           type-a = {&arh-cost}.
        end.
        else do:
           type-a = {&arh-crsa} .
        end.
        find first sheetf where sheetf.colformat = "2=@;3=@;4=@":U no-lock no-error .
        if available sheetf then do:
           flag-dop-bc = true .
        end.
        else do:
           flag-dop-bc = false  .
           v-dop-bc = ""     .
           find first sheetf .
        end.

        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-flav.i }
{ rep/f-fdec.i }
{ rep/procobor.i func-vat }

{ rep/obr-runn.i {1} no  }   /*Нужно по всем - поэтому no */
{ rep/ost-line.i yes yes }
{ rep/ostatok.i          }


/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE report-execute :

  If (ValType = 0 and var-report-r-b = 'rubl' )  Or ValType = 1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

  run waitfram-show ( {&mywaitmess} ) .
  output stream OutStream to value( string( session:temp-directory +
                            {&DF_Name} + string( g#report-num ) ) )      .
   run report-exec1.
   Output stream OutStream close.
   run waitfram-hide.
  {&CloseExcel}
  run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

END PROCEDURE.


PROCEDURE foreach :
define variable tt# as integer no-undo .
define buffer buf-obj-list  for obj-list .
 R = R + 1.
 { rep/r-mess.i R 25 }
  run clear-item.
 tt# = 0 .

define variable gds-zap-b-code-ed as integer no-undo .
   if flag-dop-bc = true then do:
    { gbl/gdsbcode.i gds-zap-b-code ? gds-zap-b-code-ed }
      v-dop-bc = ""   .
        for each ub.prod-bc no-lock where
            ub.prod-bc.b-code = gds-zap-b-code-ed
            on error undo, return error :
            v-dop-bc = v-dop-bc + ub.prod-bc.b-str + {&comma-char} .
        end. /* for each */
        v-dop-bc = substring(v-dop-bc, 1 , length(v-dop-bc) - 1 ) .
   end.

For each  buf-obj-list no-lock :
  run ost-line (  input   buf-obj-list.obj-code ,
                  input   buf-obj-list.obj-type ,
                  INPUT   gds-zap-artic     ,
                  INPUT   gds-zap-prod-code ,
                  INPUT   gds-zap-prod-type ,
                  input   x-tog-shift       ,
                  INPUT   fact-order-2      ,
                  input   type-a       ,
                  input   {&root-cat-id}    ,
                  input   true        ,
                  output  Quantity    ,
                  output  Coast_R     ,
                  output  Coast_V     ,
                  output  VAT_R       ,
                  output  VAT_V       ,
                  output  SLT_R       ,
                  output  SLT_V       ) .
   If not can-find  (tmp#obj-list where
      buf-obj-list.obj-code = tmp#obj-list.obj-code and
      buf-obj-list.obj-type = tmp#obj-list.obj-type  ) then do:
            create tmp#obj-list.
            Assign
              tmp#obj-list.obj-code = buf-obj-list.obj-code
              tmp#obj-list.obj-type = buf-obj-list.obj-type .
        End.

  Find first tmp#obj-list where
      buf-obj-list.obj-code = tmp#obj-list.obj-code and
      buf-obj-list.obj-type = tmp#obj-list.obj-type
  share-lock no-error .
  Assign
  tmp#obj-list.ostatok-end [1 + tt#]  = Quantity
  tmp#obj-list.ostatok-end [2 + tt#]  = if tprintrubl then Coast_R else Coast_V

  /* подсчет итогов */
  tmp#obj-list.b1-ostatok-end [1 + tt# ] =  tmp#obj-list.b1-ostatok-end [1 + tt#] + tmp#obj-list.ostatok-end [1 + tt#]
  tmp#obj-list.b1-ostatok-end [2 + tt# ] =  tmp#obj-list.b1-ostatok-end [2 + tt#] + tmp#obj-list.ostatok-end [2 + tt#]

  tmp#obj-list.bi-ostatok-end [1 + tt# ] =  tmp#obj-list.bi-ostatok-end [1 + tt#] + tmp#obj-list.ostatok-end [1 + tt#]
  tmp#obj-list.bi-ostatok-end [2 + tt# ] =  tmp#obj-list.bi-ostatok-end [2 + tt#] + tmp#obj-list.ostatok-end [2 + tt#]
  .
End.

END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE display-line :
/*------------------------------------------------------------------------------
  Purpose: Display  for frame  & Accumulate
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

        IF NOT Sums-Only then DO:
           ii = ii + 1.
           run display-str1.
          End.
  END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE print-header :
/*------------------------------------------------------------------------------
  Purpose: Печать шапки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if NOT FirstLine Then  run display-title.
    FirstLine = TRUE .

      run clear-b1 .
      run clear-bi .
      run clear-item.
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
     /*последняя строка*/
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       END PROCEDURE.
/*-----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE U-LINE :
/*   if xtog-lavel = true then
        {&PutExcel}  temp-str "ГРУППА : " + str  SKIP.
        */
        END PROCEDURE.
/*-------------------------------*/
PROCEDURE P-LINE :
        END PROCEDURE.

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
        input date('')      , x-Shift-Start,x-Shift-End,
        input type-a   ,
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
        input x-store-type  ,x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input type-a   ,
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
           run di ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
END PROCEDURE.

PROCEDURE display-Bi  :
   v-dop-bc = ""     .
   run di ("кол-во",1,  "", gds-zap-artic ,"" ,"", "BI":U).
END PROCEDURE.

PROCEDURE display-B1  :
   v-dop-bc = ""     .
   run di ("кол-во"  ,1, (s-bar-code + " " + caps( gds-zap-artic + gds-zap-gds-name)), "" ,"","","b1":u).
END PROCEDURE.


PROCEDURE Clear-B1  :
 For each tmp#obj-list  :
    REPEAT kk = 1 to 6 :
     tmp#obj-list.b1-ostatok-end    [kk]    = 0
     .
    End.
  End.
 END PROCEDURE.


PROCEDURE Clear-B2  :
 For each tmp#obj-list :
    REPEAT kk = 1 to 6 :
     tmp#obj-list.b1-ostatok-end    [kk]    = 0
     .
    End.
  End.

END PROCEDURE.

PROCEDURE Clear-Bi  :
 For each tmp#obj-list :
    REPEAT kk = 1 to 6 :
     tmp#obj-list.bi-ostatok-end    [kk]    = 0
     .
    End.
  End .

END PROCEDURE.

PROCEDURE Display-title :
    i = 0.
    run rep/extitle.p (1) .
END PROCEDURE.


PROCEDURE report-exec1  :

   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
  run calcitog.
  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   CASE RetClassify :
    &if {1}  = 1 &then    when "no-classify":u  then            run run1. &endif
    &if {1}  = 2 &then    when "grp-goods":u    then            run run2. &endif
    &if {1}  = 3 &then    when "prod":u         then            run run3. &endif
    otherwise do:
      message "Ошибка вызова!" view-as alert-box error .
    end.
   end case.
   run print-footer.
  END PROCEDURE.

PROCEDURE Clear-item :
 For each tmp#obj-list :
    REPEAT kk = 1 to 6 :
     ostatok-end                                     [kk]    = 0
     .
    End.
  End.

 END PROCEDURE.
/*-----------------------------------------------------------------------------------------*/
PROCEDURE Item-Goods :
 define input parameter  par-3 as character  no-undo.
 define input parameter  par-4 as character  no-undo.


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
/*-----------------------------------------------------------------------------------------*/
    If  break_group = true  and par-3 <> "1"  then DO :
         FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
         gds-zap-prod-name  = clients.obj-name.

          If break_group1 = true  THEN  DO :
            if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.

            if NOT xSumsOnly or (par-3 = "4" Or par-3 = "5" ) THEN DO :
                        fr0 = true .
                tmp#stroka0 = temp-str.
                {&PutExcel} tmp#stroka0  skip.
            End.
          End.

          IF (par-3 = "4"  OR  par-3 = "5")  THEN DO:
            if par-3 = "4"
              then Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name .
              else Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name.

            if NOT xSumsOnly THEN DO:
                fr = true .
                {&PutExcel} {&tabulation} temp-str  skip.
            End.

            break_group1 = false.
          END.
       break_group = false.
    End.


    run display-line.

 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as character  no-undo.
define input parameter p2 as integer   no-undo.
define input parameter p3 as character  no-undo.
define input parameter p4 as character  no-undo.
define input parameter p5 as character  no-undo.
define input parameter p6 as character  no-undo.
define input parameter p7 as character  no-undo.

define variable tot-qnty as decimal no-undo .
define variable tot-sum as decimal no-undo .

assign
  tot-qnty = 0
  tot-sum  = 0
.

 CASE CAPS(p7) :
   WHEN "B1":U  Then DO:
      {&PutExcel}
          p3   {&tabulation}
          ( if flag-dop-bc = true   then  {&tabulation} else "" )
          p4   {&tabulation}
          p5   {&tabulation}
          p6   {&tabulation}
          .
          For each tmp#obj-list :
          {&PutExcel}
          excel-qnty (tmp#obj-list.b1-ostatok-end[1] ) {&tabulation}
          excel-sum  (tmp#obj-list.b1-ostatok-end[2] ) {&tabulation}.
          assign
            tot-qnty = tot-qnty + decimal(tmp#obj-list.b1-ostatok-end[1])
            tot-sum  = tot-sum  + decimal(tmp#obj-list.b1-ostatok-end[2])
          .
          End.

          {&PutExcel}
          excel-qnty (tot-qnty ) {&tabulation}
          excel-sum  (tot-sum  ) {&tabulation}
          Skip.
          run clear-b1 .

      End.

   WHEN "BI":U Then DO:
      {&PutExcel}
          p3   {&tabulation}
          ( if flag-dop-bc = true   then  {&tabulation} else "" )
          p4   {&tabulation}
          p5   {&tabulation}
          p6   {&tabulation}
          .

          For each tmp#obj-list :
          {&PutExcel}
          excel-qnty  (tmp#obj-list.bi-ostatok-end[1] ) {&tabulation}
          excel-sum   (tmp#obj-list.bi-ostatok-end[2] ) {&tabulation}.
          assign
            tot-qnty = tot-qnty + decimal(tmp#obj-list.bi-ostatok-end[1])
            tot-sum  = tot-sum  + decimal(tmp#obj-list.bi-ostatok-end[2])
          .

          End.
          {&PutExcel}
          excel-qnty (tot-qnty ) {&tabulation}
          excel-sum  (tot-sum  ) {&tabulation}
          Skip.
      End.

   WHEN ""  Then DO:
     if Show-Negativ = true OR  (Show-Negativ = false and NOT can-find ( first tmp#obj-list where tmp#obj-list.ostatok-end[1] = 0 and
                                                       tmp#obj-list.ostatok-end[2] = 0 ))
             THEN  DO:
               {&PutExcel}
               ( p3)   {&tabulation}
               ( if flag-dop-bc = true   then ( v-dop-bc + {&tabulation}) else "" )
               ( p4)   {&tabulation}
               ( p5)   {&tabulation}
               ( p6)   {&tabulation}
                .
                assign
                  tot-qnty = 0
                  tot-sum  = 0
                .

               For each tmp#obj-list :
               {&PutExcel}
                excel-qnty ( tmp#obj-list.ostatok-end[1] ) {&tabulation}
                excel-sum  ( tmp#obj-list.ostatok-end[2] ) {&tabulation}.
                assign
                  tot-qnty = tot-qnty + decimal(tmp#obj-list.ostatok-end[1])
                  tot-sum  = tot-sum  + decimal(tmp#obj-list.ostatok-end[2])
                .

               End.
               {&PutExcel}
                excel-qnty (tot-qnty ) {&tabulation}
                excel-sum  (tot-sum  ) {&tabulation}
               Skip.
            End.
   End.
  End case.

 END PROCEDURE.