/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет (совокупная)

Автор: Чернова Светлана Александровна
Дата создания: 10/11/00
Author: Svetlana Chernova
Creation date: 10/11/00

*/
/*
{2}  - yes -раздельно по объектам
       no  -слитно по объектам
*/
define input parameter p-access as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет (совокупная)".
{ cmp/vssrevis.i }

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/ost-line.i {2} {2} }
{ rep/ostatok.i  }
{ rep/f-fdec.i   p-access }
{ rep/procobor.i func-vat }
{ gbl/cur-time.i }
{ rep/lkp-font.i }

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.

define input parameter  xclassify  as char no-undo.
define input parameter  xsorttype  as char no-undo.
define input parameter  xsumsonly  as log  no-undo.
define input parameter  xshowzero  as log  no-undo.
define input parameter  xshowzero-2  as log  no-undo.
define input parameter  xtog-obj   as log no-undo.
define input parameter  xtog-lavel as log no-undo.
define input parameter  xvar-lavel as int no-undo.
define input parameter  vat-cost   as logical no-undo .
define input parameter  vat-crsa   as logical no-undo .
define input parameter  vat-sale   as logical no-undo .

define variable   null-str#      as decimal  no-undo.
define variable   null-str2#     as decimal  no-undo.
define variable   b1-null-str#   as decimal  no-undo.
define variable   b1-null-str2#  as decimal  no-undo.
define variable   b2-null-str#   as decimal  no-undo.
define variable   b2-null-str2#  as decimal  no-undo.

define variable xserv as char init {&all} no-undo.


define variable  tprintrubl as log no-undo.

define stream  outstream.
define stream  outstream2.
/*общий итог*/

define variable    objname           as   char no-undo.
define variable    select-good       as   integer no-undo.
define variable    chosedtype        as   integer no-undo.
define variable    paytype           as   integer no-undo.
define variable    retclassify       as   char  no-undo.
define variable    retsorttype       as   char  no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    show-negativ-2    as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer no-undo.
define variable    line              as   char        no-undo.
define variable    firstline         as   logical     no-undo.


define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* local variable definitions ---                                       */

    /* приход */
define variable m-prih as character extent 5 no-undo .
assign
m-prih[1] =  {&tdedt_pri_vnesh}
m-prih[2] =  {&tdedt_vozvrat_vnesh}
m-prih[3] =  {&tdedt_pri_perem}
m-prih[4] =  {&tdedt_vozvrat_perem}
m-prih[5] =  {&tdedt_pri_prvo}
.

define variable m-rash as character extent 6 no-undo .
assign
m-rash[1] = {&tdedt_ras_vnesh}
m-rash[2] = {&tdedt_ras_vnesh_vp}
m-rash[3] = {&tdedt_ras_perem}
m-rash[4] = {&tdedt_ras_prvo}
m-rash[5] = {&tdedt_spi_prvo}
m-rash[6] = {&tdedt_spi_vnesh}
.

define variable m-kassa as character extent 2 no-undo .
assign
m-kassa[1] = {&tdedt_ras_vnesh_kass}
m-kassa[2] = {&tdedt_vozvrat_vnesh_kass}
.


define variable m-inv as character extent 2 no-undo .
assign
m-inv[1] = {&tdedt_inv}
m-inv[2] = {&tdedt_peresort}
.

define variable m-overturn as character extent 1 no-undo .
assign
m-overturn[1] = {&tdedt_overturn}
.

&scop v-par1 (input  x-store-code , input  x-store-type , input  x-artic ,~
input  x-prod-code  ,~
input  x-prod-type  ,~
input  x-tog-shift  ,~
input  fact-order-1 ,~
input  fact-order-2 ,

&scop v-par2  input l-cat-id , input xtog-obj     ,~
    output quantity#1   ,~
    output coast_r#1    ,~
    output coast_v#1    ,~
    output vat_r#1      ,~
    output vat_v#1      ,~
    output slt_r#1      ,~
    output slt_v#1      ,~
    output other_r#1    ,~
    output other_v#1    )

define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-np            like ub.stk-tot.sum-base no-undo.

define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable f-prih             as   char  no-undo.
define variable f-rash             as   char  no-undo.
define variable f-kassa            as   char  no-undo.
define variable f-inv              as   char  no-undo.
define variable f-overturn         as   char  no-undo.
define variable prih             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable kassa            as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable inv              as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable overturn         as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable b1-prih             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-rash             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-kassa            as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-inv              as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-overturn         as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable b2-prih             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-rash             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-kassa            as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-inv              as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-overturn         as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable bi-prih             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-rash             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-kassa            as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-inv              as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-overturn         as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable bo-prih             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-rash             as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-kassa            as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-inv              as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-overturn         as   decimal extent 10 format "->>>>>>>>>>9.<<<" no-undo.

define variable gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bo-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bi-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b1-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b2-gds-zap-other         like ub.stk-tot.sum-base no-undo.


define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.

define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
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
define variable xshowcost as logical no-undo .
define variable xshowsale as logical no-undo .
define variable xshowcrsa as logical no-undo .


define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
/* ************** frame 1 для формы ************************************************************************************ */
define frame zapas
        s-bar-code column-label  "Код! ! ":c9 space(0)
        sym1 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":c16 format "x(16)" space(0)
        sym2 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":c36 format "x(36)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "x(3)"                  space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-type column-label "Тип!данных! ":c6 format "x(6)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)" space(0)
        f-ostatok-start     column-label "Остаток на!начало! ":c14 format "x(14)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        f-prih       column-label "Приход! ! ":c14     format "x(14)"     space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        f-rash       column-label "Расход! ! ":c14  format "x(14)"   space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        f-kassa             column-label "Касса! ! ":c14  format "x(14)"   space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        f-inv               column-label "Инвентаризация! ! ":c14  format "x(14)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        f-overturn         column-label "Переоценка! ! ":c14  format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-other      column-label "Скидка! ! ":c13     space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        f-ostatok-end     column-label "Остаток!на конец! ":c14 format "x(14)"           space(0)
    header
         cur-time-print() at 5 format "x(35)"
        "Цены указаны в" (if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( page-number( outstream ), ">>>>>9") ) at 147 format "x(53)" skip
        line format "x(194)" at 1
   with width {&dos_cw_2} down stream-io use-text no-box.
{ rep/repfrm.i def}
/*===================================================================================================================*/
     assign
        i=0
        xlavel = xvar-lavel
        select-good   = x-selectgood
        paytype       = x-set_pay_type
        retclassify   = xclassify
        retsorttype   = xsorttype
        sums-only     = xsumsonly
        show-negativ  = xshowzero
        show-negativ-2  = xshowzero-2
        xshowcost     = show-cost
        xshowsale     = show-sale
        xshowcrsa     = show-crsa
        firstline     = false
        line          = fill("-", {&dos_cw_2})
        valtype       = if (paytype = 1) then 0  else x-set_val_type.

     run report-execute  in this-procedure .
{ rep/f-flav.i }


procedure report-execute :
define variable gj as integer no-undo init 0.

  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

  { rep/repfrm.i on 30}

  if reportpageheight = 0 then reportpageheight  = {&ls_ps_a4}.
  { cmp/open-out.i stream outstream  " " reportpageheight}
/*----------------------------------------------------------------*/
  find first clients where x-store-type = clients.obj-type and
                           x-store-code = clients.obj-code no-lock no-error.
  if available clients then  objname = clients.obj-name.
                                else  objname="объект не определен".
  /* form with frame zapas . */

  { rep/r-formh.i x(194) {&dos_cw_2}}
 &if "{2}" = "yes"  &then
       for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          gj = gj + 1.
          run report-exec1  in this-procedure.
      end.
      if gj > 1 then do:
        hide stream outstream frame bottomframe .
        run display-bo in this-procedure.
        run u-line in this-procedure.
      end.
&else
     run report-exec1 in this-procedure.
&endif

  hide stream outstream frame bottomframe .
  hide   stream outstream frame zapas .
  output stream outstream close.
  { rep/repfrm.i off }
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
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.
/*----------------------------------------------------------------------------------*/


procedure foreach :
  { rep/repfrm.i disp i  }
  run clear-item  in this-procedure.
/* на начало ------------------------------------------------------------------------------------------*/
{ rep/io.i fact-order-1 arh-cost 0 start}

if  xshowcrsa or vat-crsa then do:
   { rep/io.i fact-order-1 arh-crsa 3 start}
   end.

if xshowsale or vat-sale then do:
   { rep/io.i fact-order-1 arh-crsa 6 start}
   end.

/* на конец ------------------------------------------------------------------------------------------------------*/
{ rep/io.i fact-order-2 arh-cost 0 end}
if  xshowcrsa or vat-crsa then do:
   { rep/io.i fact-order-2 arh-crsa 3 end}
   end.

if xshowsale or vat-sale then do:
   { rep/io.i fact-order-2 arh-crsa 6 end}
   end.

/* обороты ------------------------------------------------------------------------------------------------------*/
/* учетная цена  по 1 товару  */
    case  gds-zap-type :
    when {&gds-office} then do:
      run ob-line  in this-procedure(
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-artic       ,
          input   gds-zap-prod-code   ,
          input   gds-zap-prod-type   ,
          input   fact-order-1,
          input   fact-order-2,
          input   {&arh-cost-service}     ,
          input   {&root-cat-id},
          input   ""    ,
          input   xtog-obj) .
     end.
    when {&gds-goods} then do:
      run ob-line  in this-procedure(
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-artic       ,
          input   gds-zap-prod-code   ,
          input   gds-zap-prod-type   ,
          input   fact-order-1,
          input   fact-order-2,
          input   {&arh-cost}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xtog-obj) .
      end.
      end case.

/* подсчет подитогов */
   run calc-sub-itog  in this-procedure(0).
/* продажная цена */
  if xshowcrsa or  xshowsale or vat-crsa or vat-sale then do:
    case  gds-zap-type :
    when {&gds-office} then do:
          RUN ob-line  in this-procedure(
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   {&arh-CRSA-service}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xTog-obj) .
     end.
    when {&gds-goods} then do:
      run ob-line  in this-procedure(
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-artic       ,
          input   gds-zap-prod-code   ,
          input   gds-zap-prod-type   ,
          input   fact-order-1,
          input   fact-order-2,
          input   {&arh-crsa}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xtog-obj) .
      end.
          end case.
    /* подсчет подитогов */
     run calc-sub-itog  in this-procedure(3).
     end.
/* продажная цена документа */
  if xshowsale  then do:
    case  gds-zap-type :
    when {&gds-office} then do:
          RUN ob-line  in this-procedure (
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-artic       ,
          input   gds-zap-prod-code   ,
          input   gds-zap-prod-type   ,
          input   fact-order-1,
          input   fact-order-2,
          input   {&arh-sale-service}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xtog-obj
          ).
          end.
    when {&gds-goods} then do:
      run ob-line  in this-procedure (
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-artic       ,
          input   gds-zap-prod-code   ,
          input   gds-zap-prod-type   ,
          input   fact-order-1,
          input   fact-order-2,
          input   {&arh-sale}    ,
          input   {&root-cat-id},
          input   ""    ,
          input   xtog-obj) .
      end.
          end case.
    /* подсчет подитогов */
     run calc-sub-itog  in this-procedure (6).
     end.

end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure display-line :
     i = i + 1.

        if not( not show-negativ-2 and
         ( prih         [1]   = 0 and
          rash          [1]   = 0 and
          kassa         [1]   = 0 and
          inv           [1]   = 0 and
          overturn      [1]   = 0 and
          overturn      [5]   = 0 and
          gds-zap-other       = 0 and
          overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              prih          [1]   = 0 and
              rash          [1]   = 0 and
              kassa         [1]   = 0 and
              inv           [1]   = 0 and
              overturn      [1]   = 0 and
              overturn      [5]   = 0 and
              gds-zap-other       = 0 and
              ostatok-start [1]   = 0 and
              ostatok-end   [1]   = 0   )) then do:

        if not sums-only then do:
            if fr0 = true then do:
              put stream  outstream  tmp#stroka0 format "x(100)" skip.
              {&putexcel} string(tmp#stroka0) skip.
              fr0 = false .
            end.

            if fr = true then do:
              put stream outstream space(10) temp-str format "x(100)" skip.
              {&putexcel} {&tabulation} string(temp-str) skip.
              fr = false .
            end.

           run display-str1 in this-procedure.

          end.
        end.
     end.
  end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/


procedure print-header :
if not firstline then do:
   run display-title  in this-procedure.
   form {&wfz} .  {&frame-d} .
end.

 firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          {&put-u1}     "ПО ОБЪЕКТУ : " + caps(clients.obj-name)  at 30 format "x(170)" skip.
          {&putexcel}   "ПО ОБЪЕКТУ : " + caps(clients.obj-name) format "x(170)" skip.
      end.
      run clear-b1  in this-procedure.
      run clear-b2  in this-procedure.
      run clear-bi  in this-procedure.
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
      if retclassify = "no-classify":u  then run u-line in this-procedure.
/*-----КОЛИЧЕСТВО----------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       run display-bi  in this-procedure.
       run u-line in this-procedure.
       end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure u-line :
underline stream outstream  {&all-sym}
        s-bar-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        f-ostatok-start
        f-prih
        f-rash
        f-kassa
        f-inv
        f-overturn
        f-ostatok-end
        gds-zap-other
        {&wfz} .
        {&frame-d}.
        end procedure.
procedure p-line :
underline stream outstream  {&all-sym}
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        f-ostatok-start
        f-prih
        f-rash
        f-kassa
        f-inv
        f-overturn
        f-ostatok-end
        gds-zap-other
        {&wfz} .
        {&frame-d}.

 end procedure.

{ rep/obr-runn.i {1} {2} }
procedure calcitog :
/*------------------------------------------------------------------------------
  purpose:  Найти  на начало и конец  fact-order
  номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run ostatok  in this-procedure(
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
/*----------------------------------------------------------------------------------------------------------------*/
/*номер последнего fact-ordera и остатки на конец интервала  */
/* номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
    run ostatok  in this-procedure (
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
/*эти не нужны*/
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.

end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure display-str1  :
           run di-qnty  in this-procedure("кол-во", 1, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if xshowcost    then do: run di  in this-procedure( "учет.", 2,"","","","",""). end.
         if xshowcrsa    then do: run di  in this-procedure( "прод.", 5,"","","","","" ).  end.
         if xshowsale    then do: run di  in this-procedure( "док." , 8,"","","","","" ).  end.
         if vat-cost    then do: run di  in this-procedure( "уч.НДС", 3,"","","","","" ). end.
         if vat-crsa    then do: run di  in this-procedure( "пр.НДС", 6,"","","","","" ).  end.
         if vat-sale    then do: run di  in this-procedure( "дк.НДС", 9,"","","","","" ).  end.

end procedure.
procedure display-bi  :
           run di-qnty in this-procedure ("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).
         if xshowcost    then do: run di in this-procedure ("учет." , 2 , "","", "", "", "bi":u).  end.
         if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "",  "bi":u).  end.
         if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "",  "bi":u).  end.
         if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","bi":u ). end.
         if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","bi":u ).  end.
         if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","bi":u ).  end.

end procedure.
procedure display-bo  :
           run di-qnty in this-procedure ("кол-во",1,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         if xshowcost    then do: run di in this-procedure ("учет." , 2 , "","", "", "", "bo":u).  end.
         if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "",  "bo":u).  end.
         if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "",  "bo":u).  end.
         if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","bo":u ). end.
         if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","bo":u ).  end.
         if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","bo":u ).  end.

end procedure.

procedure display-b1  :
     if not( not show-negativ-2 and
         ( b1-prih         [1]   = 0 and
           b1-rash          [1]   = 0 and
           b1-kassa         [1]   = 0 and
           b1-inv           [1]   = 0 and
           b1-overturn      [1]   = 0 and
           b1-overturn      [5]   = 0 and
           b1-gds-zap-other       = 0 and
           b1-overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              b1-prih          [1]   = 0 and
              b1-rash          [1]   = 0 and
              b1-kassa         [1]   = 0 and
              b1-inv           [1]   = 0 and
              b1-gds-zap-other       = 0 and
              b1-overturn      [1]   = 0 and
              b1-overturn      [5]   = 0 and
              b1-ostatok-start [1]   = 0 and
              b1-ostatok-end   [1]   = 0   )) then do:

              /*шапка для верхней группы */
              if sums-only then do:
                  if fr0 = true then do:
                      put stream  outstream  tmp#stroka0 format "x(100)" skip.
                      {&putexcel} string(tmp#stroka0) skip.
                      fr0 = false .
                    end.
               end.

        run di-qnty in this-procedure ("кол-во"  ,1, s-bar-code, gds-zap-artic, gds-zap-gds-name ,"","b1":u).
        if xshowcost    then do: run di in this-procedure ("учет." ,2 ,"","", "", "", "b1":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "", "b1":u).  end.
        if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "", "b1":u).  end.
        if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","b1":u ). end.
        if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","b1":u ).  end.
        if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","b1":u ).  end.
       if not sums-only then run p-line.

 end.
 end.
end procedure.

procedure display-b2  :
     if not( not show-negativ-2 and
         ( b2-prih         [1]   = 0 and
           b2-rash          [1]   = 0 and
           b2-kassa         [1]   = 0 and
           b2-inv           [1]   = 0 and
           b2-gds-zap-other       = 0 and
           b2-overturn      [1]   = 0 and
           b2-overturn      [5]   = 0 and
           b2-overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              b2-prih          [1]   = 0 and
              b2-rash          [1]   = 0 and
              b2-kassa         [1]   = 0 and
              b2-inv           [1]   = 0 and
              b2-gds-zap-other       = 0 and
              b2-overturn      [1]   = 0 and
              b2-overturn      [5]   = 0 and
              b2-ostatok-start [1]   = 0 and
              b2-ostatok-end   [1]   = 0   )) then do:

        run di-qnty( "кол-во", 1 ,s-bar-code,gds-zap-artic, gds-zap-gds-name,"", "b2":u).
        if xshowcost    then do: run di in this-procedure ("учет.", 2, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод.", 5 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di in this-procedure ("док.", 8 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","b2":u ). end.
         if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","b2":u ).  end.
         if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","b2":u ).  end.
         if not sums-only then run u-line.
 end.
end.

end procedure.
/*-------------------------------------------------------------------------------------------------------------*/
procedure clear-b1  :
 b1-gds-zap-other           = 0.
 repeat kk = 1 to 9 :
 assign
    b1-prih                                            [kk]    = 0
    b1-rash                                            [kk]    = 0
    b1-kassa                                           [kk]    = 0
    b1-inv                                             [kk]    = 0
    b1-overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0   .

   end.
 end procedure.
procedure clear-b2  :
 b2-gds-zap-other           = 0.
 repeat kk = 1 to 9 :
 assign
    b2-prih                                            [kk]    = 0
    b2-rash                                            [kk]    = 0
    b2-kassa                                           [kk]    = 0
    b2-inv                                             [kk]    = 0
    b2-overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0   .
   end.

end procedure.
procedure clear-bi  :
 bi-gds-zap-other           = 0.
 repeat kk = 1 to 9 :
 assign
    bi-prih                                            [kk]    = 0
    bi-rash                                            [kk]    = 0
    bi-kassa                                           [kk]    = 0
    bi-inv                                             [kk]    = 0
    bi-overturn                                        [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0   .
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

procedure ob-line  :
define input  parameter x-store-code   like ub.clients.obj-code     no-undo.
define input  parameter x-store-type   like ub.clients.obj-type     no-undo.
define input  parameter x-artic        like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code    like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type    like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj           as log no-undo.

define variable  tt#          as   int                 no-undo.
define variable  quantity#1    like ub.stk-line.fact-qnty   no-undo.
define variable  coast_r#1     like ub.stk-line.sum-rubl    no-undo.
define variable  coast_v#1     like ub.stk-line.sum-rubl    no-undo.
define variable  vat_r#1       like ub.stk-line.sum-rubl    no-undo.
define variable  vat_v#1       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_r#1       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_v#1       like ub.stk-line.sum-rubl    no-undo.
define variable  other_r#1     like ub.stk-line.sum-rubl    no-undo.
define variable  other_v#1     like ub.stk-line.sum-rubl    no-undo.
define variable  l-sum-type as character no-undo .
define variable  l-cat-id   as character no-undo .
define variable v-s# as character no-undo .

 if (x-sum-type = {&arh-sale} ) then assign tt# = 6 v-s# = {&arh-sadt} .
 if (x-sum-type = {&arh-crsa} ) then assign tt# = 3 v-s# = {&arh-cgdt} .
 if (x-sum-type = {&arh-cost} ) then assign tt# = 0 v-s# = {&arh-csdt} .

 if (x-sum-type = {&arh-sale-service}) then assign tt# = 6 v-s# = {&arh-sadt-service} .
 if (x-sum-type = {&arh-crsa-service}) then assign tt# = 3 v-s# = {&arh-cgdt-service} .
 if (x-sum-type = {&arh-cost-service}) then assign tt# = 0 v-s# = {&arh-csdt-service} .

define variable v-i as integer no-undo .

repeat v-i = 1 to  extent(m-prih) :
 run oborot-stk in this-procedure {&v-par1} input v-s# + m-prih[v-i] , {&v-par2} .
    assign prih[1 + tt#]   = prih[1 + tt#] + quantity#1
           prih[2 + tt#]   = prih[2 + tt#] + if tprintrubl then coast_r#1 else coast_v#1
           prih[3 + tt#]   = prih[3 + tt#] + if tprintrubl then vat_r#1   else vat_v#1 .
    if tt# = 6 then gds-zap-other  = gds-zap-other + if tprintrubl then other_r#1  else other_v#1  .
end.
repeat v-i = 1 to  extent(m-rash) :
 run oborot-stk in this-procedure {&v-par1} input  v-s# + m-rash[v-i] , {&v-par2} .
    assign rash[1 + tt#]   = rash[1 + tt#] +  quantity#1
           rash[2 + tt#]   = rash[2 + tt#] +  if tprintrubl then coast_r#1 else coast_v#1
           rash[3 + tt#]   = rash[3 + tt#] +  if tprintrubl then vat_r#1   else vat_v#1 .
    if tt# = 6 then gds-zap-other  = gds-zap-other + if tprintrubl then other_r#1  else other_v#1  .
end.
repeat v-i = 1 to  extent(m-kassa) :
 run oborot-stk in this-procedure {&v-par1} input  v-s# + m-kassa[v-i] , {&v-par2} .
    assign kassa[1 + tt#]   = kassa[1 + tt#] + quantity#1
           kassa[2 + tt#]   = kassa[2 + tt#] + if tprintrubl then coast_r#1 else coast_v#1
           kassa[3 + tt#]   = kassa[3 + tt#] + if tprintrubl then vat_r#1   else vat_v#1 .
    if tt# = 6 then gds-zap-other  = gds-zap-other + if tprintrubl then other_r#1  else other_v#1  .
 end.

repeat v-i = 1 to  extent(m-inv) :
 run oborot-stk in this-procedure {&v-par1} input  v-s# + m-inv[v-i] , {&v-par2} .
    assign inv[1 + tt#]   = inv[1 + tt#] + quantity#1
           inv[2 + tt#]   = inv[2 + tt#] + if tprintrubl then coast_r#1 else coast_v#1
           inv[3 + tt#]   = inv[3 + tt#] + if tprintrubl then vat_r#1   else vat_v#1 .
    if tt# = 6 then gds-zap-other  = gds-zap-other + if tprintrubl then other_r#1  else other_v#1  .
end.
repeat v-i = 1 to  extent(m-overturn) :
 run oborot-stk in this-procedure {&v-par1} input  v-s# + m-overturn[v-i] , {&v-par2} .
    assign overturn[1 + tt#]   = overturn[1 + tt#] + quantity#1
           overturn[2 + tt#]   = overturn[2 + tt#] + if tprintrubl then coast_r#1 else coast_v#1
           overturn[3 + tt#]   = overturn[3 + tt#] + if tprintrubl then vat_r#1   else vat_v#1 .
    if tt# = 6 then gds-zap-other  = gds-zap-other + if tprintrubl then other_r#1  else other_v#1  .

end.
  if tt# = 6 then do:
       if (x-sum-type = {&arh-sale-service}) then do:
           assign
           prih[1 ]   = prih[7 ]
           rash[1 ]   = rash[7 ]
           kassa[1]   = kassa[7]
           inv[1]     = inv[7  ]
           .
           end.

           assign overturn[1 + tt#]   = (ostatok-end[1 + tt#]  - ostatok-start[1 + tt#] )  -  (inv[1 + tt#] + prih[1 + tt#]   +  kassa[1 + tt#]  +  rash[1 + tt#]  )
                  overturn[2 + tt#]   = (ostatok-end[2 + tt#]  - ostatok-start[2 + tt#] )  -  (inv[2 + tt#] + prih[2 + tt#]   +  kassa[2 + tt#]  +  rash[2 + tt#]  +  gds-zap-other )
                  overturn[3 + tt#]   = (ostatok-end[3 + tt#]  - ostatok-start[3 + tt#] )  -  (inv[3 + tt#] + prih[3 + tt#]   +  kassa[3 + tt#]  +  rash[3 + tt#]  )  .
  end.
end procedure.

/*----------------------------------------------------------------*/
procedure report-exec1  :

   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.



  { rep/repfrm.i disp i clients.obj-name }
  run calcitog.

  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   case retclassify :
     &if {1} = 1 &then  when "no-classify":u  then   run run1.  &endif
     &if {1} = 2 &then  when "grp-goods":u then      run run2.  &endif
     &if {1} = 3 &then  when "prod":u  then          run run3.  &endif
     &if {1} = 4 &then  when "prod/grp-goods":u then run run4.  &endif
     &if {1} = 5 &then  when "grp-goods/prod":u then run run5.  &endif
     &if {1} = 7 &then  when "vat-ps":u         then run run7.  &endif
   end case.
  run print-footer.
  end procedure.

/*-----------------------------------------------------------------------------------------*/
procedure calc-sub-itog :     /* подсчет под итогов */
define input parameter tt as int no-undo.
define variable b as int no-undo.

if tt = 6  then assign
  b1-gds-zap-other = b1-gds-zap-other +  gds-zap-other
  b2-gds-zap-other = b2-gds-zap-other +  gds-zap-other
  bi-gds-zap-other = bi-gds-zap-other +  gds-zap-other
  bo-gds-zap-other = bo-gds-zap-other +  gds-zap-other
  .


repeat b = 1 to 3:
  assign
  b1-prih[b + tt]    = b1-prih[b + tt]    +  prih[b + tt]
  b2-prih[b + tt]    = b2-prih[b + tt]    +  prih[b + tt]
  bi-prih[b + tt]    = bi-prih[b + tt]    +  prih[b + tt]
  bo-prih[b + tt]    = bo-prih[b + tt]    +  prih[b + tt]
  bo-ostatok-start[b + tt]    = bo-ostatok-start[b + tt]    +  ostatok-start[b + tt]
  bo-ostatok-end[b + tt]      = bo-ostatok-end[b + tt]      +  ostatok-end[b + tt]

  b1-rash[b + tt]    = b1-rash[b + tt]    +  rash[b + tt]
  b2-rash[b + tt]    = b2-rash[b + tt]    +  rash[b + tt]
  bi-rash[b + tt]    = bi-rash[b + tt]    +  rash[b + tt]
  bo-rash[b + tt]    = bo-rash[b + tt]    +  rash[b + tt]

  b1-kassa[b + tt]    = b1-kassa[b + tt]    +  kassa[b + tt]
  b2-kassa[b + tt]    = b2-kassa[b + tt]    +  kassa[b + tt]
  bi-kassa[b + tt]    = bi-kassa[b + tt]    +  kassa[b + tt]
  bo-kassa[b + tt]    = bo-kassa[b + tt]    +  kassa[b + tt]

  b1-inv[b + tt]    = b1-inv[b + tt]    +  inv[b + tt]
  b2-inv[b + tt]    = b2-inv[b + tt]    +  inv[b + tt]
  bi-inv[b + tt]    = bi-inv[b + tt]    +  inv[b + tt]
  bo-inv[b + tt]    = bo-inv[b + tt]    +  inv[b + tt]


  b1-overturn[b + tt]    = b1-overturn[b + tt]    +  overturn[b + tt]
  b2-overturn[b + tt]    = b2-overturn[b + tt]    +  overturn[b + tt]
  bi-overturn[b + tt]    = bi-overturn[b + tt]    +  overturn[b + tt]
  bo-overturn[b + tt]    = bo-overturn[b + tt]    +  overturn[b + tt] .
end.
end procedure.
/*-----------------------------------------------------------------------------------------*/
procedure clear-item :
define variable kk as int no-undo.
 gds-zap-other = 0 .
 repeat kk = 1 to 9 :
 assign
    prih            [kk]    = 0
    rash            [kk]    = 0
    kassa           [kk]    = 0
    inv             [kk]    = 0
    overturn        [kk]    = 0
    ostatok-end     [kk]    = 0
    ostatok-start   [kk]    = 0 .
       end.
 end procedure.
/*-----------------------------------------------------------------------------------------*/
procedure item-goods :
   define input parameter  par-3 as char no-undo.
   define input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then do:
        assign
            gds-zap-unit-base  = goods.unit-base
            gds-zap-prt-root   = goods.prt-root
            gds-zap-prod-type  = goods.prod-type
            gds-zap-prod-code  = goods.prod-code
            gds-zap-artic      = goods.artic
            gds-zap-grp-name   = goods.grp-name
            gds-zap-b-code     = goods.gds-code
            gds-zap-type       = goods.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = goods.engl-name.
        else
            assign gds-zap-gds-name = goods.gds-name.
     end.

     if par-4 = "gds-list":u  then do:
        assign
            gds-zap-unit-base  = gds-list.unit-base
            gds-zap-prt-root   = gds-list.prt-root
            gds-zap-prod-type  = gds-list.prod-type
            gds-zap-prod-code  = gds-list.prod-code
            gds-zap-artic      = gds-list.artic
            gds-zap-grp-name   = gds-list.grp-name
            gds-zap-b-code     = gds-list.gds-code
            gds-zap-type       = gds-list.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = gds-list.engl-name.
        else
            assign gds-zap-gds-name = gds-list.gds-name.
    end.
    run foreach  in this-procedure.
    { rep/r-obreak.i }
    run display-line  in this-procedure.

 end procedure.


procedure di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 case caps(p7) :
   when "b1":u  then do:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< b1-}
               {&frame-d}.
                end.
   when "b2":u  then  do:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< b2-}
               {&frame-d}.
              end.
   when "bi":u then  do:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< bi-}
               {&frame-d}.
              end.
   when "bo":u then  do:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< bo-}
               {&frame-d}.
              end.

   when ""  then  do:
               { rep/di-ob-s.i ->>>>>>>>>>9.<< }
               {&frame-d}.
              end.
   end case.

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
   when "b1":u  then do :
              { rep/di-ob-s.i ->>>>>>>>>>9.<<< b1-}
              { rep/ex-ob-s.i ->>>>>>>>>>9.<<< b1-}
                end.
   when "b2":u  then do :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< b2-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< b2-}
             end.
   when "bi":u then  do :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< bi-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< bi-}
             end.
   when "bo":u then  do :
             { rep/di-ob-s.i ->>>>>>>>>>9.<<< bo-}
             { rep/ex-ob-s.i ->>>>>>>>>>9.<<< bo-}
             end.

   when ""  then     do :
              { rep/di-ob-s.i ->>>>>>>>>>9.<<< }
              { rep/ex-ob-s.i ->>>>>>>>>>9.<<< }
              end.
   end case.
               {&frame-d}.
 end procedure.


procedure oborot-stk :
define input  parameter l-store-code   like ub.clients.obj-code      no-undo.
define input  parameter l-store-type   like ub.clients.obj-type      no-undo.
define input  parameter l-artic        like ub.stk-line.artic        no-undo.
define input  parameter l-prod-code    like ub.stk-line.prod-code    no-undo.
define input  parameter l-prod-type    like ub.stk-line.prod-type    no-undo.
define input  parameter l-tog-shift    as   logical                  no-undo.
define input  parameter l-fact-order-1   like ub.stk-line.fact-order   no-undo.
define input  parameter l-fact-order-2   like ub.stk-line.fact-order   no-undo.
define input  parameter l-sum-type     like ub.stk-line.sum-type     no-undo.
define input  parameter l-cat-id       like ub.stk-line.cat-id       no-undo.
define input  parameter l-tog-obj       as log no-undo.

define output parameter quantity    like ub.stk-line.fact-qnty   no-undo.
define output parameter coast_r     like ub.stk-line.sum-rubl    no-undo.
define output parameter coast_v     like ub.stk-line.sum-rubl    no-undo.
define output parameter vat_r       like ub.stk-line.sum-rubl    no-undo.
define output parameter vat_v       like ub.stk-line.sum-rubl    no-undo.
define output parameter slt_r       like ub.stk-line.sum-rubl    no-undo.
define output parameter slt_v       like ub.stk-line.sum-rubl    no-undo.
define output parameter other_r     like ub.stk-line.sum-rubl    no-undo.
define output parameter other_v     like ub.stk-line.sum-rubl    no-undo.

define variable  quantity#1    like ub.stk-line.fact-qnty   no-undo.
define variable  coast_r#1     like ub.stk-line.sum-rubl    no-undo.
define variable  coast_v#1     like ub.stk-line.sum-rubl    no-undo.
define variable  vat_r#1       like ub.stk-line.sum-rubl    no-undo.
define variable  vat_v#1       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_r#1       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_v#1       like ub.stk-line.sum-rubl    no-undo.
define variable  other_r#1     like ub.stk-line.sum-rubl    no-undo.
define variable  other_v#1     like ub.stk-line.sum-rubl    no-undo.

define variable  quantity#2    like ub.stk-line.fact-qnty   no-undo.
define variable  coast_r#2     like ub.stk-line.sum-rubl    no-undo.
define variable  coast_v#2     like ub.stk-line.sum-rubl    no-undo.
define variable  vat_r#2       like ub.stk-line.sum-rubl    no-undo.
define variable  vat_v#2       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_r#2       like ub.stk-line.sum-rubl    no-undo.
define variable  slt_v#2       like ub.stk-line.sum-rubl    no-undo.
define variable  other_r#2     like ub.stk-line.sum-rubl    no-undo.
define variable  other_v#2     like ub.stk-line.sum-rubl    no-undo.

run ost-lineother-tax  in this-procedure
 (  input   l-store-code  ,
    input   l-store-type  ,
    input   l-artic       ,
    input   l-prod-code   ,
    input   l-prod-type   ,
    input   l-tog-shift   ,
    input   l-fact-order-1,
    input   l-sum-type    ,
    input   l-cat-id      ,
    input   l-tog-obj     ,
    output  quantity#1 ,
    output  coast_r#1  ,
    output  coast_v#1  ,
    output  vat_r#1    ,
    output  vat_v#1    ,
    output  slt_r#1    ,
    output  slt_v#1    ,
    output  other_r#1  ,
    output  other_v#1  ).

run ost-lineother-tax  in this-procedure
 (  input   l-store-code  ,
    input   l-store-type  ,
    input   l-artic       ,
    input   l-prod-code   ,
    input   l-prod-type   ,
    input   l-tog-shift   ,
    input   l-fact-order-2,
    input   l-sum-type    ,
    input   l-cat-id      ,
    input   l-tog-obj     ,
    output  quantity#2 ,
    output  coast_r#2  ,
    output  coast_v#2  ,
    output  vat_r#2    ,
    output  vat_v#2    ,
    output  slt_r#2    ,
    output  slt_v#2    ,
    output  other_r#2  ,
    output  other_v#2  ).

    assign
      quantity =   quantity#2 -  quantity#1
      coast_r  =   coast_r#2  -  coast_r#1
      coast_v  =   coast_v#2  -  coast_v#1
      vat_r    =   vat_r#2    -  vat_r#1
      vat_v    =   vat_v#2    -  vat_v#1
      slt_r    =   slt_r#2    -  slt_r#1
      slt_v    =   slt_v#2    -  slt_v#1
      other_r  =   other_r#2  -  other_r#1
      other_v  =   other_v#2  -  other_v#1
      .

 end procedure.
 /* $Workfile$ e n d */