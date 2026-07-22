/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет (по типу приобретени )

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

created: 10/11/00
g - o t p s y . p

*/
/*
{2}  - yes -раздельно по объектам
       no  -слитно по объектам
*/
define input parameter x-type-pr as character no-undo .
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xclassify    as char    no-undo.
define input parameter xsorttype    as char    no-undo.
define input parameter xsumsonly    as log     no-undo.
define input parameter xshowzero    as log     no-undo.
define input parameter xshowzero-2  as log     no-undo.
define input parameter xtog-obj     as log     no-undo.
define input parameter xtog-lavel   as log     no-undo.
define input parameter xvar-lavel   as int     no-undo.
define input parameter vat-cost     as logical no-undo .
define input parameter vat-crsa     as logical no-undo .
define input parameter vat-sale     as logical no-undo .
define input parameter p-tpsy       as logical   no-undo .
define input parameter p-type-tpsy-goods as integer   no-undo . /* 2 -все 3-свои */

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Оборотная ведомость отчет (по типу приобретения)".
{ cmp/vssrevis.i }

/* parameters definitions ---              */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/f-flav.i   }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ gbl/paramls.i  }
{ rep/procobor.i def-tt   }
{ rep/procobor.i func-vat }
{ gbl/aht.i      }
{ rep/aht-fo.i   }
{ rep/repfrm.i def }
{ rep/repfrm.i on 50 }
{ rep/lkp-font.i }



define variable  xserv as char init {&all} no-undo.
define variable   tprintrubl as log no-undo.

define  stream  outstream.
define  stream  outstream2.
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

define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable   null-str#      as decimal  no-undo.
define variable   null-str2#     as decimal  no-undo.
define variable   b1-null-str#   as decimal  no-undo.
define variable   b1-null-str2#  as decimal  no-undo.
define variable   b2-null-str#   as decimal  no-undo.
define variable   b2-null-str2#  as decimal  no-undo.

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

define variable arh-type-sale as character no-undo .
define variable arh-type-crsa as character no-undo .
define variable arh-type-cost as character no-undo .
define variable arh-type-sadt as character no-undo .
define variable arh-type-cgdt as character no-undo .
define variable arh-type-csdt as character no-undo .
define variable arh-type-allsum  as character no-undo .


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
        f-inv               column-label "Инвентаризация!Смена типа!приобретения":c14  format "x(14)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        f-overturn         column-label "Переоценка!продажной и!учетной цен":c14  format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-other      column-label "Скидка! ! ":c13     space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        f-ostatok-end     column-label "Остаток!на конец! ":c14 format "x(14)"           space(0)
    header
        string( "Дата печати : " + string(today,"99.99.9999") +  " , " + string(time, "hh:mm") ) at 5 format "x(35)"
        "Цены указаны в" (if tprintrubl then "{&abbr_rub}" else x-base-type )
        string( "Страница " + string( page-number( outstream ), ">>>>>9") ) at 147 format "x(53)" skip
        line format "x(194)" at 1
   with width {&dos_cw_2} down stream-io use-text no-box.

/*===================================================================================================================*/
     assign
        i = 0
        xlavel        = xvar-lavel
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
/*
   run aht_get-sum-type (
        input   x-type-pr    ,
        output  arh-type-allsum ).
  */
   run report-execute.


procedure report-execute :
define variable gj as integer no-undo init 0.

  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .



  if reportpageheight = 0 then reportpageheight  = {&ls_ps_a4}.
  { cmp/open-out.i stream outstream  " " reportpageheight }
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
          run report-exec1.
      end.
      if gj > 1 then do:
        hide stream outstream frame bottomframe .
        run display-bo.
        run u-line.
      end.
&else
     run report-exec1.
&endif

  hide stream outstream frame bottomframe .
  hide   stream outstream frame zapas .
  output stream outstream close.
  { rep/repfrm.i off }
  {&closeexcel}
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
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
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input reportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.



procedure clear-line :
 do
 on error undo, return error return-value
 :
    assign
        ostatok-start[1]  = 0
        ostatok-start[2]  = 0
        ostatok-start[3]  = 0
        ostatok-start[4]  = 0
        ostatok-start[5]  = 0
        ostatok-start[6]  = 0
        ostatok-start[7]  = 0
        ostatok-start[8]  = 0
        ostatok-start[9]  = 0
        ostatok-start[10] = 0
        ostatok-end[1]  = 0
        ostatok-end[2]  = 0
        ostatok-end[3]  = 0
        ostatok-end[4]  = 0
        ostatok-end[5]  = 0
        ostatok-end[6]  = 0
        ostatok-end[7]  = 0
        ostatok-end[8]  = 0
        ostatok-end[9]  = 0
        ostatok-end[10] = 0
  .


 end. /* do */
end procedure. /* clear-line */


procedure ost-line :
do
on error undo, return error return-value
:
/* на начало ------------------------------------------------------------------------------------------------------------*/
/* остаток по товару на начало считывем все суммы crsa cost sale */

define input parameter p-store-type like ub.clients.obj-type no-undo .
define input parameter p-store-code like ub.clients.obj-code no-undo .

 find last  ub.aht-stk-line where
                        ub.aht-stk-line.gds-code   = gds-zap-b-code
                  and   ub.aht-stk-line.fact-order <= fact-order-1
                  and   ub.aht-stk-line.obj-code   = p-store-code
                  and   ub.aht-stk-line.obj-type   = p-store-type
                  and   ub.aht-stk-line.sum-type   = x-type-pr     /* тип приобретения */
                        use-index category no-lock no-error.
        if available ub.aht-stk-line then do:
            if  tprintrubl  then
                  assign
                        ostatok-start[1]  =ostatok-start[1] +  (if ub.aht-stk-line.sum-type <> "b" /* только если не выгода */
                                                                   then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                                          /* факт количество         1  */
                        ostatok-start[2]  =ostatok-start[2] +  round( ub.aht-stk-line.cost-sum-rubl ,2)      /* смма в учет ценах       2  */
                        ostatok-start[3]  =ostatok-start[3] +  round( ub.aht-stk-line.cost-vat-rubl ,2)      /* НДС  в учетных ценах    3  */
                        ostatok-start[4]  =ostatok-start[4] +  0                                          /* цены посредника         4  */
                        ostatok-start[5]  =ostatok-start[5]  + round( ub.aht-stk-line.crsa-sum-rubl ,2)      /* смма в прод ценах       5  */
                        ostatok-start[6]  =ostatok-start[6]  + round( ub.aht-stk-line.crsa-vat-rubl ,2)      /* НДС  в прод ценах       6  */
                        ostatok-start[7]  =ostatok-start[7]  + round( ub.aht-stk-line.sale-discnt-rubl ,2)   /* Скидка в ценах док      7  */
                        ostatok-start[8]  =ostatok-start[8]  + round( ub.aht-stk-line.crsa-sum-rubl ,2)      /* смма в док ценах        8  */
                        ostatok-start[9]  =ostatok-start[9]  + round( ub.aht-stk-line.crsa-vat-rubl ,2)      /* НДС  в док ценах        9  */
                        ostatok-start[10] =ostatok-start[10] + round( ub.aht-stk-line.crsa-slt-rubl ,2)      /* НсП в ценах док         10 */
                        .
              else
                  assign
                        ostatok-start[1]  = ostatok-start[1] + (if ub.aht-stk-line.sum-type <> "b" /* только если не выгода */
                                                                   then round( ub.aht-stk-line.fact-qnty,3) else 0 )

                                                         /* факт количество         1  */
                        ostatok-start[2]  = ostatok-start[2] +  round( ub.aht-stk-line.cost-sum-base ,2)      /* смма в учет ценах       2  */
                        ostatok-start[3]  = ostatok-start[3] +  round( ub.aht-stk-line.cost-vat-base ,2)      /* НДС  в учетных ценах    3  */
                        ostatok-start[4]  = ostatok-start[4] +  0                                          /* цены посредника         4  */
                        ostatok-start[5]  = ostatok-start[5]  + round( ub.aht-stk-line.crsa-sum-base ,2)      /* смма в прод ценах       5  */
                        ostatok-start[6]  = ostatok-start[6]  + round( ub.aht-stk-line.crsa-vat-base ,2)      /* НДС  в прод ценах       6  */
                        ostatok-start[7]  = ostatok-start[7]  + round( ub.aht-stk-line.sale-discnt-base ,2)   /* Скидка в ценах док      7  */
                        ostatok-start[8]  = ostatok-start[8]  + round( ub.aht-stk-line.crsa-sum-base ,2)      /* смма в док ценах        8  */
                        ostatok-start[9]  = ostatok-start[9]  + round( ub.aht-stk-line.crsa-vat-base ,2)      /* НДС  в док ценах        9  */
                        ostatok-start[10] = ostatok-start[10] + round( ub.aht-stk-line.crsa-slt-base ,2)      /* НсП в ценах док         10 */
                  .
             end.
/* на конец -------------------------------------------------------------------------------------------------------------*/
 find last  ub.aht-stk-line where
                        ub.aht-stk-line.gds-code   = gds-zap-b-code
                  and   ub.aht-stk-line.fact-order <= fact-order-2
                  and   ub.aht-stk-line.obj-code   = p-store-code
                  and   ub.aht-stk-line.obj-type   = p-store-type
                  and   ub.aht-stk-line.sum-type   = x-type-pr     /* тип приобретения */
                        use-index category no-lock no-error.
        if available ub.aht-stk-line then do:
            if  tprintrubl  then
                  assign
                        ostatok-end[1]  = ostatok-end[1] + (if ub.aht-stk-line.sum-type <> "b" /* только если не выгода */
                                                               then round( ub.aht-stk-line.fact-qnty,3) else 0 )

                                                         /* факт количество         1  */
                        ostatok-end[2]  = ostatok-end[2] + round( ub.aht-stk-line.cost-sum-rubl ,2)      /* смма в учет ценах       2  */
                        ostatok-end[3]  = ostatok-end[3] + round( ub.aht-stk-line.cost-vat-rubl ,2)      /* НДС  в учетных ценах    3  */
                        ostatok-end[4]  = ostatok-end[4] + 0                                          /* цены посредника         4  */
                        ostatok-end[5]  = ostatok-end[5] + round( ub.aht-stk-line.crsa-sum-rubl ,2)      /* смма в прод ценах       5  */
                        ostatok-end[6]  = ostatok-end[6] + round( ub.aht-stk-line.crsa-vat-rubl ,2)      /* НДС  в прод ценах       6  */
                        ostatok-end[7]  = ostatok-end[7] + round( ub.aht-stk-line.sale-discnt-rubl ,2)   /* Скидка в ценах док      7  */
                        ostatok-end[8]  = ostatok-end[8] + round( ub.aht-stk-line.crsa-sum-rubl ,2)      /* смма в док ценах        8  */
                        ostatok-end[9]  = ostatok-end[9] + round( ub.aht-stk-line.crsa-vat-rubl ,2)      /* НДС  в док ценах        9  */
                        ostatok-end[10] = ostatok-end[10] + round( ub.aht-stk-line.crsa-slt-rubl ,2)      /* НсП в ценах док         10 */
                        .
              else
                  assign
                        ostatok-end[1]  = ostatok-end[1] +  (if ub.aht-stk-line.sum-type <> "b" /* только если не выгода */
                                                                then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                                              /* факт количество         1  */
                        ostatok-end[2]  = ostatok-end[2] +  round( ub.aht-stk-line.cost-sum-base ,2)      /* смма в учет ценах       2  */
                        ostatok-end[3]  = ostatok-end[3] +  round( ub.aht-stk-line.cost-vat-base ,2)      /* НДС  в учетных ценах    3  */
                        ostatok-end[4]  = ostatok-end[4] +  0                                          /* цены посредника         4  */
                        ostatok-end[5]  = ostatok-end[5] +  round( ub.aht-stk-line.crsa-sum-base ,2)      /* смма в прод ценах       5  */
                        ostatok-end[6]  = ostatok-end[6] +  round( ub.aht-stk-line.crsa-vat-base ,2)      /* НДС  в прод ценах       6  */
                        ostatok-end[7]  = ostatok-end[7] +  round( ub.aht-stk-line.sale-discnt-base ,2)   /* Скидка в ценах док      7  */
                        ostatok-end[8]  = ostatok-end[8] +  round( ub.aht-stk-line.crsa-sum-base ,2)      /* смма в док ценах        8  */
                        ostatok-end[9]  = ostatok-end[9] +  round( ub.aht-stk-line.crsa-vat-base ,2)      /* НДС  в док ценах        9  */
                        ostatok-end[10] = ostatok-end[10] + round( ub.aht-stk-line.crsa-slt-base ,2)      /* НсП в ценах док         10 */
                  .
             end.



end. /* do */
end procedure. /* ost-line */

procedure foreach :
define variable old-type as character no-undo .
   old-type = x-type-pr.
  { rep/repfrm.i disp i  reportname objname }
  run clear-item.

&if "{2}" = "no"  &then
  run clear-line.
  for each obj-list  no-lock :
    if x-type-pr = "cb" then do:
       x-type-pr = "b".
       run ost-line (obj-list.obj-type , obj-list.obj-code ) .
       x-type-pr = "c".
       run ost-line (obj-list.obj-type , obj-list.obj-code ) .
       x-type-pr = old-type .
    end.
    else do:
       run ost-line (obj-list.obj-type , obj-list.obj-code ) .
    end.
  end.
&else
  run clear-line.
    if x-type-pr = "cb" then do:
       x-type-pr = "b".
       run ost-line (x-store-type , x-store-code ) .
       x-type-pr = "c".
       run ost-line (x-store-type , x-store-code ) .
       x-type-pr = old-type .
    end.
    else run ost-line (x-store-type , x-store-code ) .
&endif

/* обороты --------------------------------------------------------------------------------------------------------------*/
/* 1 товару  */
   run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-b-code ,
          input   fact-order-1,
          input   fact-order-2,
          input   x-type-pr     ,
          input   xtog-obj) .
/* подсчет подитогов */
   run calc-sub-itog .

end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure display-line :
     i = i + 1.
        if not( not show-negativ-2 and
         ( prih         [1]   = 0 and
          rash          [1]   = 0 and
          kassa         [1]   = 0 and
          inv           [1]   = 0 and
          overturn      [1]   = 0 and
          overturn      [5]   = 0 and
          overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              prih          [1]   = 0 and
              rash          [1]   = 0 and
              kassa         [1]   = 0 and
              inv           [1]   = 0 and
              overturn      [1]   = 0 and
              overturn      [5]   = 0 and
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
/*-----------------------------------------------------------------------------------------------------------------------*/


procedure print-header :
if not firstline then do:
   run display-title.
   form {&wfz} .  {&frame-d} .
end.

 firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          {&put-u1}     "ПО ОБЪЕКТУ : " + caps(clients.obj-name)  at 30 format "x(170)" skip.
          {&putexcel}   "ПО ОБЪЕКТУ : " + caps(clients.obj-name) format "x(170)" skip.
      end.
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.

   end procedure.
/*-----------------------------------------------------------------------------------------------------------------------*/
procedure print-footer :
/*------------------------------------------------------------------------------
  purpose: Печать итогов отчета
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
     /*последняя строка*/
      if retclassify = "no-classify":u  then run u-line.
/*-----КОЛИЧЕСТВО----------------------------------------------------------------------------------------------------*/
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       run u-line.
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

    run aht-ostatok (
        input x-store-code     ,
        input x-store-type     ,
        input x-tog-shift      ,
        input x-date-start - 1 ,
        input date('')         ,
        input x-shift-start    ,
        input x-shift-end      ,
        input "n"    ,
        input xtog-obj         ,
        output  fact-order-1 ) .
/*----------------------------------------------------------------------------------------------------------------*/
/*номер последнего fact-ordera и остатки на конец интервала  */
/* номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
    run aht-ostatok (
        input x-store-code  ,
        input x-store-type  , x-tog-shift,
        input x-date-start  ,
        input x-date-end    , x-shift-start,x-shift-end,
        input "n" ,
        input xtog-obj ,
        output  fact-order-2 ).


end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure display-str1  :
           run di-qnty ("кол-во", 1, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if xshowcost    then do: run di ( "учет.", 2,"","","","",""). end.
         if xshowcrsa    then do: run di ( "прод.", 5,"","","","","" ).  end.
         if xshowsale    then do: run di ( "док." , 8,"","","","","" ).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","" ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","" ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","" ).  end.

end procedure.
procedure display-bi  :
           run di-qnty("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bi":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bi":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bi":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bi":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bi":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bi":u ).  end.

end procedure.
procedure display-bo  :
           run di-qnty("кол-во",1,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bo":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bo":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bo":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bo":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bo":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bo":u ).  end.

end procedure.

procedure display-b1  :
/*      if not( not show-negativ-2 and
         ( b1-prih         [1]   = 0 and
           b1-rash          [1]   = 0 and
           b1-kassa         [1]   = 0 and
           b1-inv           [1]   = 0 and
           b1-overturn      [1]   = 0 and
           b1-overturn      [5]   = 0 and
           b1-overturn      [8]   = 0 ) ) then do: */
        if  not (not show-negativ  and (
              b1-prih          [1]   = 0 and
              b1-rash          [1]   = 0 and
              b1-kassa         [1]   = 0 and
              b1-inv           [1]   = 0 and
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
/* end. */

end procedure.

procedure display-b2  :
/*     if not( not show-negativ-2 and
         ( b2-prih         [1]   = 0 and
           b2-rash          [1]   = 0 and
           b2-kassa         [1]   = 0 and
           b2-inv           [1]   = 0 and
           b2-overturn      [1]   = 0 and
           b2-overturn      [5]   = 0 and
           b2-overturn      [8]   = 0 ) ) then do: */
        if  not (not show-negativ  and (
              b2-prih          [1]   = 0 and
              b2-rash          [1]   = 0 and
              b2-kassa         [1]   = 0 and
              b2-inv           [1]   = 0 and
              b2-overturn      [1]   = 0 and
              b2-overturn      [5]   = 0 and
              b2-ostatok-start [1]   = 0 and
              b2-ostatok-end   [1]   = 0   )) then do:

        run di-qnty( "кол-во", 1 ,s-bar-code,gds-zap-artic, gds-zap-gds-name,"", "b2":u).
        if xshowcost    then do: run di ("учет.", 2, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di ("прод.", 5 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di ("док.", 8 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","b2":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","b2":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","b2":u ).  end.

 end.
/* end. */
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
 b2-gds-zap-other      = 0.
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
define variable v-nn as integer   no-undo .
   {&put-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip(2)
          reportname  at 20 format "x(170)" skip
          trim(str1)  at 35 format "x(75)" skip.
     v-nn = num-entries(str2,chr(10)).
     repeat i = 1 to v-nn :
      {&put-u1}  entry(i,str2,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.

       {&put-u1}  trim(str3)  at 35 format "x(75)" skip.
     v-nn  = num-entries(str4,chr(10)) .
     repeat i = 1 to v-nn :
      {&put-u1}  entry(i,str4,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.

     v-nn = num-entries(reportheader,chr(10)) .
     repeat i = 1 to v-nn  :
      {&put-u1}  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
    run rep/extitle.p (1) .
end procedure.

procedure ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code         no-undo .
define input  parameter x-store-type     like ub.clients.obj-type         no-undo .
define input  parameter x-gds-code       like ub.aht-ot-line.gds-code     no-undo .
define input  parameter x-fact-order-1   like ub.aht-ot-line.fact-order   no-undo .
define input  parameter x-fact-order-2   like ub.aht-ot-line.fact-order   no-undo .
define input  parameter x-sum-type       like ub.aht-ot-line.sum-type     no-undo .
define input  parameter xtog-obj         as logical no-undo .
define variable      tt#              as integer no-undo .
define variable x-type-pr1 as character no-undo .
define variable x-type-pr2 as character no-undo .

 if x-sum-type = arh-type-cost then tt# = 0 .
 if x-sum-type = arh-type-crsa then tt# = 3 .
 if x-sum-type = arh-type-sale then tt# = 6 .
if  x-sum-type = "cb" then
 assign
    x-type-pr1 = "c"
    x-type-pr2 = "b"
 .
else
 assign
    x-type-pr1 = x-sum-type
    x-type-pr2 = x-sum-type
 .
&if "{2}" = "yes"  &then
     for each ub.aht-ot-line where
                  (      ub.aht-ot-line.gds-code     = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = x-store-code
                  and   ub.aht-ot-line.obj-type     = x-store-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr1)
                  or
                  (     ub.aht-ot-line.gds-code     = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = x-store-code
                  and   ub.aht-ot-line.obj-type     = x-store-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr2 )
                  no-lock :
&else
  for each obj-list  no-lock :
     for each ub.aht-ot-line where
                      ( ub.aht-ot-line.gds-code      = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = obj-list.obj-code
                  and   ub.aht-ot-line.obj-type     = obj-list.obj-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr1 )
                  OR  ( ub.aht-ot-line.gds-code      = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = obj-list.obj-code
                  and   ub.aht-ot-line.obj-type     = obj-list.obj-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr2 )
                  no-lock :
&endif
    case ub.aht-ot-line.ext-doc-type:
    /*разбивка по типам документов */
    /* приход */
              when        {&tdedt_pri_vnesh}  or
              when        {&tdedt_vozvrat_vnesh}  or
              when        {&tdedt_pri_perem}    or
              when        {&tdedt_vozvrat_perem} or
              when        {&tdedt_pri_prvo  }     then
              do:
              assign
                     prih[1 ]   = prih[1]   + (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                                                                                                                                     /* факт количество         1  */
                     prih[2 ]   = prih[2]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base /* смма в учет ценах       2  */
                     prih[3 ]   = prih[3]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base /* НДС  в учетных ценах    3  */
                     prih[4 ]   = prih[4]                                                                                   /* цены посредника         4  */
                     prih[5 ]   = prih[5]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base /* смма в прод ценах       5  */
                     prih[6 ]   = prih[6]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base /* НДС  в прод ценах       6  */
                     prih[7 ]   = prih[7]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base /* Скидка в ценах док      7  */
                     prih[8 ]   = prih[8]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base /* смма в док ценах        8  */
                     prih[9 ]   = prih[9]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base  /* НДС  в док ценах        9  */
                     gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
               .
              end.
    /* расход */
              when       {&tdedt_ras_vnesh}      or
              when       {&tdedt_ras_vnesh_vp}    or
              when       {&tdedt_ras_perem}     or
              when       {&tdedt_ras_prvo}       or
              when       {&tdedt_spi_prvo}       or
              when       {&tdedt_spi_vnesh}     then
              do:
                assign
                    rash[1 ]   = rash[1]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 ) /* факт количество         1  */
                    rash[2 ]   = rash[2]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base /* смма в учет ценах       2  */
                    rash[3 ]   = rash[3]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base /* НДС  в учетных ценах    3  */
                    rash[4 ]   = rash[4]                                                                                   /* цены посредника         4  */
                    rash[5 ]   = rash[5]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base /* смма в прод ценах       5  */
                    rash[6 ]   = rash[6]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base /* НДС  в прод ценах       6  */
                    rash[7 ]   = rash[7]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base /* Скидка в ценах док      7  */
                    rash[8 ]   = rash[8]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base /* смма в док ценах        8  */
                    rash[9 ]   = rash[9]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base  /* НДС  в док ценах        9  */
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
              .
              end.
    /* касса */
              when       {&tdedt_ras_vnesh_kass}  or
              when       {&tdedt_vozvrat_vnesh_kass} then
              do:
                  assign
                    kassa[1 ]   = kassa[1]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )  /* факт количество         1  */
                    kassa[2 ]   = kassa[2]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base /* смма в учет ценах       2  */
                    kassa[3 ]   = kassa[3]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base /* НДС  в учетных ценах    3  */
                    kassa[4 ]   = kassa[4]                                                                                   /* цены посредника         4  */
                    kassa[5 ]   = kassa[5]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base /* смма в прод ценах       5  */
                    kassa[6 ]   = kassa[6]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base /* НДС  в прод ценах       6  */
                    kassa[7 ]   = kassa[7]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base /* Скидка в ценах док      7  */
                    kassa[8 ]   = kassa[8]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base /* смма в док ценах        8  */
                    kassa[9 ]   = kassa[9]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base  /* НДС  в док ценах        9  */
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    .
              end.
  /* инвентаризация */
          when       {&tdedt_inv}            or
          when       {&tdedt_chg_purch_code} or
          when       {&tdedt_peresort}       then  do:
              assign
                inv[1 ]   = inv[1]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 ) /* факт количество         1  */
                inv[2 ]   = inv[2]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base /* смма в учет ценах       2  */
                inv[3 ]   = inv[3]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base /* НДС  в учетных ценах    3  */
                inv[4 ]   = inv[4]                                                                                   /* цены посредника         4  */
                inv[5 ]   = inv[5]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base /* смма в прод ценах       5  */
                inv[6 ]   = inv[6]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base /* НДС  в прод ценах       6  */
                inv[7 ]   = inv[7]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base /* Скидка в ценах док      7  */
                inv[8 ]   = inv[8]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base /* смма в док ценах        8  */
                inv[9 ]   = inv[9]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base  /* НДС  в док ценах        9  */
                gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                .

              end.
    /* переоценка */
          when       {&tdedt_overturn} or
          when       {&tdedt_corr_acc_price} then
              do:
                 assign
                    overturn[1 ]   = overturn[1]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )  /* факт количество         1  */
                    overturn[2 ]   = overturn[2]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base /* смма в учет ценах       2  */
                    overturn[3 ]   = overturn[3]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base /* НДС  в учетных ценах    3  */
                    overturn[4 ]   = overturn[4]                                                                                   /* цены посредника         4  */
                    overturn[5 ]   = overturn[5]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base /* смма в прод ценах       5  */
                    overturn[6 ]   = overturn[6]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base /* НДС  в прод ценах       6  */
                    overturn[7 ]   = overturn[7]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base /* Скидка в ценах док      7  */
                    overturn[8 ]   = overturn[8]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base /* смма в док ценах        8  */
                    overturn[9 ]   = overturn[9]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base  /* НДС  в док ценах        9  */
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    .
              end.
      end case.

   &if "{2}" = "no"  &then  end. &endif
  end.

  /* переоценка в ценах документа это разница между оборотами и разностью остатков */
  assign
    tt# = 6
    overturn[1 + tt#]   = (ostatok-end[1 + tt#]  - ostatok-start[1 + tt#] )  -  (inv[1 + tt#] + prih[1 + tt#] + kassa[1 + tt#] + rash[1 + tt#]  )
    overturn[2 + tt#]   = (ostatok-end[2 + tt#]  - ostatok-start[2 + tt#] )  -  (inv[2 + tt#] + prih[2 + tt#] + kassa[2 + tt#] + rash[2 + tt#]  )
    overturn[3 + tt#]   = (ostatok-end[3 + tt#]  - ostatok-start[3 + tt#] )  -  (inv[3 + tt#] + prih[3 + tt#] + kassa[3 + tt#] + rash[3 + tt#]  )
  .

end procedure.
/*----------------------------------------------------------------*/
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.

  run calcitog.

  run print-header.   /* проход по списку товаров 1 2 3-№ поиска */
   case retclassify :
      &if {1} = 1 &then when "no-classify":u  then            run run1 in this-procedure . &endif
      &if {1} = 2 &then when "grp-goods":u then               run run2 in this-procedure . &endif
      &if {1} = 3 &then when "prod":u  then                   run run3 in this-procedure . &endif
      &if {1} = 4 &then when "prod/grp-goods":u then          run run4 in this-procedure . &endif
      &if {1} = 5 &then when "grp-goods/prod":u then          run run5 in this-procedure . &endif
      &if {1} = 7 &then when "vat-ps":u                 then  run run7 in this-procedure . &endif
      otherwise do:
        message "error" view-as alert-box error .
      end.
   end case.
  run print-footer.
  end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure calc-sub-itog :                                  /* подсчет под итогов */
define variable b  as int no-undo.

assign
  b1-gds-zap-other = b1-gds-zap-other +  gds-zap-other
  b2-gds-zap-other = b2-gds-zap-other +  gds-zap-other
  bi-gds-zap-other = bi-gds-zap-other +  gds-zap-other
  bo-gds-zap-other = bo-gds-zap-other +  gds-zap-other
  .


repeat b = 1 to 10 :
  assign
  b1-ostatok-start[b ]    = b1-ostatok-start[b ]    +  ostatok-start[b ]
  b1-ostatok-end  [b ]    = b1-ostatok-end  [b ]    +  ostatok-end  [b ]
  b2-ostatok-start[b ]    = b2-ostatok-start[b ]    +  ostatok-start[b ]
  b2-ostatok-end  [b ]    = b2-ostatok-end  [b ]    +  ostatok-end  [b ]
  bi-ostatok-start[b ]    = bi-ostatok-start[b ]    +  ostatok-start[b ]
  bi-ostatok-end  [b ]    = bi-ostatok-end  [b ]    +  ostatok-end  [b ]
  bo-ostatok-start[b ]    = bo-ostatok-start[b ]    +  ostatok-start[b ]
  bo-ostatok-end  [b ]    = bo-ostatok-end  [b ]    +  ostatok-end  [b ]

  b1-prih[b ]    = b1-prih[b ]    +  prih[b ]
  b2-prih[b ]    = b2-prih[b ]    +  prih[b ]
  bi-prih[b ]    = bi-prih[b ]    +  prih[b ]
  bo-prih[b ]    = bo-prih[b ]    +  prih[b ]

  b1-rash[b ]    = b1-rash[b ]    +  rash[b ]
  b2-rash[b ]    = b2-rash[b ]    +  rash[b ]
  bi-rash[b ]    = bi-rash[b ]    +  rash[b ]
  bo-rash[b ]    = bo-rash[b ]    +  rash[b ]

  b1-kassa[b ]    = b1-kassa[b ]    +  kassa[b ]
  b2-kassa[b ]    = b2-kassa[b ]    +  kassa[b ]
  bi-kassa[b ]    = bi-kassa[b ]    +  kassa[b ]
  bo-kassa[b ]    = bo-kassa[b ]    +  kassa[b ]

  b1-inv[b ]    = b1-inv[b ]    +  inv[b ]
  b2-inv[b ]    = b2-inv[b ]    +  inv[b ]
  bi-inv[b ]    = bi-inv[b ]    +  inv[b ]
  bo-inv[b ]    = bo-inv[b ]    +  inv[b ]


  b1-overturn[b ]    = b1-overturn[b ]    +  overturn[b ]
  b2-overturn[b ]    = b2-overturn[b ]    +  overturn[b ]
  bi-overturn[b ]    = bi-overturn[b ]    +  overturn[b ]
  bo-overturn[b ]    = bo-overturn[b ]    +  overturn[b ]
  .
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
    run foreach.
    { rep/r-obreak.i }
    run display-line.
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
              { rep/di-ob-s.i ->>>>>>>>>>9.<<<  }
              { rep/ex-ob-s.i ->>>>>>>>>>9.<<<  }
              end.
   end case.
               {&frame-d}.
 end procedure.