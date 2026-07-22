block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-prpost.p $
$Archive: rep/r-prpost.p $

Оборотная ведомость по контрагентам

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 11.04.01

*/
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter x-cli-art      as character no-undo .
define input parameter x-date1rash    as date no-undo .
define input parameter x-date2rash    as date no-undo .
define input parameter x-postname     as character no-undo .
define input parameter x-type-stor    as int no-undo .
define input parameter x-show-cost-vat  as logical no-undo .
define input parameter x-show-sale-vat  as logical no-undo .
define input parameter xclassify  as char no-undo.
define input parameter xsorttype  as char no-undo.
define input parameter xsumsonly  as log  no-undo.
define input parameter xtog-obj   as log no-undo.
define input parameter xtog-lavel as log no-undo.
define input parameter xvar-lavel as int no-undo.
define input parameter xtog-lavel-2 as log no-undo.
define input parameter xvar-lavel-2 as int no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-prpost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-prpost.p $":U .
define variable vss-description as character no-undo init "Оборо  прих партий ".
{ cmp/vssrevis.i }
{ rep/r-defpst.i  &df = new  &framename = 'oborot-pri':u }
{ rep/f-fdec.i }
{ rep/f-flav.i }
{ gbl/waitfram.i }
{ rep/lkp-font.i }

define variable xserv as char init {&all} no-undo.
define buffer a-clients for ub.clients.
define  stream  outstream2.

define variable    chosedtype        as   integer no-undo.
define variable    valtype           as   integer no-undo.
define variable    firstline         as   logical     no-undo.

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* local variable definitions ---                                       */

define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.

define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.

define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.

define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.

define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
/*===================================================================================================================*/

     assign
        i=0
        xlavel        = xvar-lavel
        select-good   = x-selectgood
        paytype       = x-set_pay_type
        retclassify   = xclassify
        retsorttype   = xsorttype
        sums-only     = xsumsonly
        type-stor      = x-type-stor
        cli-art       = x-cli-art
        show-cost-vat = x-show-cost-vat
        show-sale-vat = x-show-sale-vat
        date1rash     = x-date1rash
        date2rash     = x-date2rash
        postname      = x-postname
        firstline     = false
        xtogobj       = xtog-obj
        line          = fill("-", {&dos_cw_2})
        valtype       = if (paytype = 1) then 0  else x-set_val_type.
        xlavel = 0.
if  xtog-lavel    then  xlavel        =  xvar-lavel .
if  xtog-lavel-2  then  xlavel        =  xvar-lavel-2 .

        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

  run waitfram-show in this-procedure  ( {&mywaitmess} ) .
  { cmp/open-out.i stream outstream  " "  reportpageheight}
  /*---------------------------------------------------------------------------------------------------------------------*/
  run report-exec1.

  hide   stream outstream frame zapas .
  output stream outstream close.
  run waitfram-hide .
  {&closeexcel}
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable disabledoptions as integer   no-undo .
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
    ,input  disabledoptions
    ,input  string(session :temp-directory) + {&df_name} + string( g#report-num )
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-header :

if not firstline then  run display-title.
    firstline = true .
     form {&wfz} .  {&frame-d} .
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.

   end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-footer :
/*------------------------------------------------------------------------------------------------------------------------
  purpose: Печать итогов отчета
  parameters:  <none>
  notes:
-------------------------------------------------------------------------------------------------------------------------*/
     /*последняя строка*/
      if retclassify = "no-classify":u  then run u-line.
/*-----КОЛИЧЕСТВО--------------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       run u-line.
       end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure u-line :
underline stream outstream  {&all-sym}
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        f-vzvr
        f-prih
        f-rash
        f-kassa
        f-inv
        f-vzvr-post
        f-spis
        sym13
        {&wfz} .
        {&frame-d}.
        end procedure.
/*-------------------------------*/
procedure p-line :
underline stream outstream
        sym3
        gds-zap-gds-name
        sym4
        gds-zap-unit-base
        sym5
        {&wfz}.
        {&frame-d} .
        end procedure.
/*-------------------------------*/
procedure calcitog :
/*------------------------------------------------------------------------------
  purpose:  Найти  на начало и конец  fact-order
  номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
   xtog-obj = false .
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-tog-shift,
        input x-date-start - 1 ,
        input date('')      , x-shift-start,x-shift-end,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-tog-shift,
        input x-date-start  ,
        input x-date-end    , x-shift-start,x-shift-end,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-2 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , false ,
        input  date1rash - 1 ,
        input date('')      , ? , ?,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-3 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , false ,
        input date1rash  ,
        input date2rash    , ?, ?,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-4 ).

/*эти не нужны*/
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.
 xtog-obj = xtogobj .
end procedure.
/*-------------------------------------------------------------------------------------------------------------*/
procedure display-bi  :
                             run di-qnty ("кол-во" , 1 , "", gds-zap-artic ,"" ,"", "bi":u).
         if show-cost        then do: run di ("учет."  , 2 , "","", "", "", "bi":u).  end.
         if show-cost-vat    then do: run di ("уч.НДС" , 3 , "","", "", "", "bi":u).  end.
         if show-sale        then do: run di ("док-т." , 5 , "","", "", "", "bi":u).  end.
         if show-sale-vat    then do: run di ("д. НДС" , 6 , "","", "", "", "bi":u).  end.
end procedure.
procedure clear-b1  :
 repeat kk = 1 to 9 :
 assign
    b1-spis                                            [kk]    = 0
    b1-prih                                            [kk]    = 0
    b1-rash                                            [kk]    = 0
    b1-kassa                                           [kk]    = 0
    b1-inv                                             [kk]    = 0
    b1-vzvr-post                                       [kk]    = 0
    b1-vzvr                                            [kk]    = 0   .

   end.
 end procedure.
procedure clear-b2  :
 repeat kk = 1 to 9 :
 assign
    b2-spis                                            [kk]    = 0
    b2-prih                                            [kk]    = 0
    b2-rash                                            [kk]    = 0
    b2-kassa                                           [kk]    = 0
    b2-inv                                             [kk]    = 0
    b2-vzvr-post                                       [kk]    = 0
    b2-vzvr                                            [kk]    = 0   .
   end.

end procedure.
procedure clear-bi  :
 repeat kk = 1 to 9 :
 assign
    bi-spis                                            [kk]    = 0
    bi-prih                                            [kk]    = 0
    bi-rash                                            [kk]    = 0
    bi-kassa                                           [kk]    = 0
    bi-inv                                             [kk]    = 0
    bi-vzvr-post                                       [kk]    = 0
    bi-vzvr                                            [kk]    = 0   .
   end.

end procedure.

procedure display-title :
   {&put-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip(2)
          reportname  at 20 format "x(170)" skip
          trim(str1)  at 35 format "x(75)" skip.
     repeat i = 1 to num-entries(str2,chr(10)) :
      {&put-u1}  entry(i,str2,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.

       {&put-u1}  trim(str3)  at 35 format "x(75)" skip.

     repeat i = 1 to num-entries(str4,chr(10)) :
      {&put-u1}  entry(i,str4,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.


     repeat i = 1 to num-entries(reportheader,chr(10)) :
      {&put-u1}  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
    run rep/extitle.p (1) .
end procedure.
 { rep/ostatok.i }
procedure report-exec1  :
   find first a-clients where x-store-type = a-clients.obj-type and
                            x-store-code = a-clients.obj-code no-lock no-error.
           if available a-clients then  objname = a-clients.obj-name. else  objname = "объект не определен".

  run waitfram-show in this-procedure  (objname) .

  form with frame zapas .
  { rep/r-formh.i x(194) {&dos_cw_2}}
  run calcitog.
  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
  case retsorttype :
      when "sort-article":u  or when "sort-artic":u  then
      if not can-find(first g#post no-lock)
          then   run rep/r-ppr-1.p (x-store-code, x-store-type, x-base-type , x-base-code ).
          else   run rep/r-ppr-2.p (x-store-code, x-store-type, x-base-type , x-base-code ).
      when "sort-code":u  then
      if not can-find(first g#post no-lock)
          then   run rep/r-ppr-3.p (x-store-code, x-store-type, x-base-type , x-base-code ).
          else   run rep/r-ppr-4.p (x-store-code, x-store-type, x-base-type , x-base-code ).
  end case.
  hide stream outstream frame bottomframe .
  run print-footer.
  end procedure.
/*----------------------------------------------------------------------------------------------------------------------*/
procedure calc-sub-itog :     /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.
repeat b = 1 to 3:
  assign
  b1-prih[b + tt]    = b1-prih[b + tt]    +  prih[b + tt]
  b2-prih[b + tt]    = b2-prih[b + tt]    +  prih[b + tt]
  bi-prih[b + tt]    = bi-prih[b + tt]    +  prih[b + tt]

  b1-rash[b + tt]    = b1-rash[b + tt]    +  rash[b + tt]
  b2-rash[b + tt]    = b2-rash[b + tt]    +  rash[b + tt]
  bi-rash[b + tt]    = bi-rash[b + tt]    +  rash[b + tt]

  b1-kassa[b + tt]    = b1-kassa[b + tt]    +  kassa[b + tt]
  b2-kassa[b + tt]    = b2-kassa[b + tt]    +  kassa[b + tt]
  bi-kassa[b + tt]    = bi-kassa[b + tt]    +  kassa[b + tt]

  b1-inv[b + tt]    = b1-inv[b + tt]    +  inv[b + tt]
  b2-inv[b + tt]    = b2-inv[b + tt]    +  inv[b + tt]
  bi-inv[b + tt]    = bi-inv[b + tt]    +  inv[b + tt]
  .
end.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to 9:
 assign
    prih             [kk]  = 0
    rash             [kk]  = 0
    kassa            [kk]  = 0
    inv              [kk]  = 0
    vzvr-post        [kk]  = 0
    vzvr             [kk]  = 0
    spis             [kk]  = 0 .
       end.
 end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 case caps(p7) :
   when "bi":u then do:
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>>9.<< bi-}
             end.
   end case.
               {&frame-d}.
 end procedure.
procedure di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 case caps(p7) :
   when "bi":u then  do :
             { rep/di-obrt.i 'oborot-pri' ->>>>>>>>>>>9.<<< bi-}
              { rep/ex-obrt.i 'oborot-pri' ->>>>>>>>>>>9.<<< bi-}
             end.
   end case.
               {&frame-d}.
 end procedure.