/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Зависшие товары

Автор: Чернова Светлана Александровна
Дата создания: 06/12/00
Author: Svetlana Chernova
Creation date: 06/12/00

*/

define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter x-host-code  like ub.clients.obj-code   no-undo.
define input parameter xcrit        as integer no-undo.
define input parameter xsort        as integer no-undo.
define input parameter xclassify    as character no-undo.
define input parameter xbsamount    as integer no-undo.
define input parameter xsc_name     as integer no-undo.
define input parameter x-upper-code as integer no-undo.
define input parameter tog-scale    as logical no-undo.
define input parameter tog-sale     as logical no-undo.

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Зависшие товары".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }
{ cmp/r-pril.i  }
{ rep/r-sym.i   }
{ rep/r-gl.i    }
{ rep/f-fdec.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ rep/lkp-font.i }

define variable xsorttype  as character init "sort-code":u no-undo.
define variable xsumsonly  as logical  init false no-undo.
define variable xshowzero  as logical  init false no-undo.
define variable xtog-obj   as logical  init false no-undo.
define variable  xshowcost as logical  init false no-undo.
define variable  xshowsale as logical  init false no-undo.
define variable  xtog-lavel as logical  init false no-undo.
define variable  xvar-lavel as integer no-undo. .
define variable x-sale-code like ub.clients.obj-code   no-undo.
define variable x-sale-type like ub.clients.obj-type   no-undo.
define variable q1 as decimal  no-undo.
define variable q2 as decimal  no-undo.
define variable q3 as decimal  no-undo.

define variable  tprintrubl as logical no-undo.

define  stream  outstream.
define  stream  outstream2.
/*общий итог*/

define variable    objname           as   character no-undo.
define variable    select-good       as   integer no-undo.
define variable    chosedtype        as   integer no-undo.
define variable    paytype           as   integer no-undo.
define variable    retclassify       as   character  no-undo.
define variable    retsorttype       as   character  no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer no-undo.
define variable    line              as   character        no-undo.
define variable    firstline         as   logical     no-undo.


define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

/* local variable definitions ---                                       */

define variable stat     as logical no-undo .
define variable inperror as logical no-undo .
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
define variable gds-type              as character no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-line.fact-qnty no-undo.
define variable gds-zap-nds           like ub.stk-line.fact-qnty no-undo.
define variable gds-zap-np            like ub.stk-line.fact-qnty no-undo.

define variable f-ostatok-start    as   character  no-undo.
define variable f-ostatok-end      as   character  no-undo.
define variable ostatok-start      as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable ostatok-end        as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.

define variable f-sumcost          as   character  no-undo.
define variable f-sumcrsa          as   character  no-undo.
define variable f-kassacost        as   character  no-undo.
define variable f-kassacrsa        as   character  no-undo.
define variable f-effect           as   character  no-undo.
define variable f-percent          as  decimal format "->>9.99"  no-undo.
define variable f-prih             as   character  no-undo.
define variable f-rash             as   character  no-undo.
define variable f-kassa            as   character  no-undo.
define variable f-inv              as   character  no-undo.
define variable f-overturn         as   character  no-undo.
define variable prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.

define variable b1-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.

define variable b2-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.

define variable bi-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.

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
define variable  temp-str as character no-undo.

define variable str as character format "x(60)" no-undo.
define variable i#i as integer no-undo.
define variable xlavel as integer  no-undo.
define variable list-field as character no-undo.
define variable str10 as character no-undo.

define temp-table tmp#bs no-undo
    field qnty      like ub.ot-line.fact-qnty
    field sumcost   like ub.ot-line.sum-rubl
    field sumcrsa   like ub.ot-line.sum-rubl
    field kassacost like ub.ot-line.sum-rubl
    field kassacrsa like ub.ot-line.sum-rubl
    field effect    like ub.ot-line.sum-rubl
    field b-code    like ub.bar-code.b-code
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field prt-root  like ub.goods.prt-root
    field grp-name  like ub.goods.grp-name
    field gds-name  like ub.goods.gds-name
    field unit-base like ub.goods.unit-base
    field  percent#1      like ub.ot-line.sum-rubl   format "->>9.99"
    index byqnty     qnty ascending
    index bysumcost  sumcost  ascending
    index bysumcrsa  sumcrsa  ascending
    index byeffect   effect   ascending .

define buffer  stk-line-crsa for ub.stk-line.
define buffer  ot-line-crsa  for ub.ot-line.

define variable control-sum  like ub.ot-line.sum-rubl no-undo.

define variable  v#qnty         like ub.ot-line.fact-qnty       no-undo.
define variable  v#sumcost      like ub.ot-line.sum-rubl        no-undo.
define variable  v#sumcrsa      like ub.ot-line.sum-rubl        no-undo.
define variable  v#kassacost    like ub.ot-line.sum-rubl        no-undo.
define variable  v#kassacrsa    like ub.ot-line.sum-rubl        no-undo.
define variable  v#effect       like ub.ot-line.sum-rubl        no-undo.
define variable  v#b-code       like ub.bar-code.b-code      no-undo.
define variable  v#artic        like ub.goods.artic          no-undo.
define variable  v#prod-code    like ub.goods.prod-code      no-undo.
define variable  v#prod-type    like ub.goods.prod-type      no-undo.
define variable  v#prt-root     like ub.goods.prt-root       no-undo.
define variable  v#grp-name     like ub.goods.grp-name       no-undo.
define variable  v#gds-name     like ub.goods.gds-name       no-undo.
define variable  v#unit-base    like ub.goods.unit-base      no-undo.
define variable  percent#all    like ub.ot-line.sum-rubl   format "->>>>>>>>>>>>9.99"  no-undo.
define variable  prtroot        like ub.gds-prt.node-code no-undo.
define variable  tot-fact-qnty  like ub.ot-line.fact-qnty  no-undo.
define variable  tot-sum-rubl-cost  like ub.ot-line.fact-qnty  no-undo.
define variable  tot-sum-rubl-crsa  like ub.ot-line.fact-qnty  no-undo.


/* ************** frame 1 для формы ************************************************************************************ */
define frame zapas
        sym1 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "     Код ! ! " space(0)
        sym2 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул        ! ! " format "x(16)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! " format "x(38)" space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "x(3)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)"                                     space(0)
        f-ostatok-end  column-label "Количество! ! " format "x(15)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        f-sumcost     column-label "Сумма в!учетных!ценах" label "Сумма в учетных ценах" format "x(15)"           space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        f-sumcrsa    column-label "Сумма в!продажных!ценах" format "x(15)"           space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        f-percent           column-label "%!по!критерию"  format "->>9.99"   space(0)
        sym9 column-label ":!:!:" format "x(1)" space(0)
    header
       cur-time-print() at 5 format "x(35)"
        "Цены указаны в" (if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( page-number( outstream ), ">>>>9") ) at 120 format "x(53)" skip
        line format "x(146)" at 1
   with width {&dos_cw_2} down stream-io use-text no-box.
/*===================================================================================================================*/
        find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
        if available  ub.gds-prt then   prtroot = ub.gds-prt.node-code.
                              else   prtroot = 0.
        find first ub.sysconf where ub.sysconf.host-code = x-host-code no-lock no-error.
        if available  ub.sysconf then   assign x-sale-code = ub.sysconf.sale-code
                                            x-sale-type = ub.sysconf.sale-type.
                              else   return error.
/*===================================================================================================================*/
     assign
        i = 0
        xlavel = xvar-lavel
        select-good   = x-selectgood
        paytype       = x-set_pay_type
        retclassify   = xclassify
        retsorttype   = xsorttype
        sums-only     = xsumsonly
        show-negativ  = xshowzero
        firstline     = false.
        line          = fill("-", {&dos_cw_2}).
        x-selectobject = "all":u .
        valtype       = if (paytype = 1) then 0  else x-set_val_type.

        run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/
function n-lavel returns character (input grp-name as char, input lavel# as integer ).
define variable str  as character format "x(60)"  no-undo.
define variable str2 as character  no-undo.
define variable i#i as integer no-undo.
str = "".


  repeat i#i = 1 to lavel#:
      if i#i = 1 then str = entry ( 1,grp-name, {&delim-grp}) .
      else do:
          str2 = entry(i#i,grp-name, {&delim-grp}) no-error.
          if not error-status:error  and str2 <> "":u then  str = str +  {&delim-grp} +  entry(i#i,grp-name, {&delim-grp}) .
          end.
  end.

    return (str + {&delim-grp}).
end function.

/*-------------------------------------------------------------------------------------------------------------------*/
procedure report-execute :
/*------------------------------------------------------------------------------
  purpose: Сбор и выполнение отчета
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
  if (valtype = 0 and x-base-code = 0)  or valtype = 1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

  run waitfram-show in this-procedure ( {&mywaitmess} ) .

  { cmp/open-out.i stream outstream  " " ReportPageHeight}

  /*----------------------------------------------------------------*/
   if xtog-obj /* раздельно по объектам */ then do:
            for each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                run report-exec1 in this-procedure .
            end.
                                               end.
  else run report-exec1 in this-procedure .
  run printtemptable in this-procedure .
  hide stream outstream frame bottomframe .
  run print-footer in this-procedure .
  hide   stream outstream frame zapas .
  output stream outstream close.
  {&closeexcel}
  run waitfram-hide in this-procedure .
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
/*------------------------------------------------------------------------------
  purpose: Поиск по итогам по строкам документов
------------------------------------------------------------------------------*/
 { rep/r-mess.i i 25 }
  run clear-item in this-procedure .
/* на конец ------------------------------------------------------------------------------------------------------*/
{ rep/io.i fact-order-2 arh-cost 0 end}
   if ostatok-end [1]   > 0 then do :
/* обороты ------------------------------------------------------------------------------------------------------*/
   run ob-line in this-procedure (
      input   x-store-code   ,
      input   x-store-type   ,
      input   gds-zap-artic       ,
      input   gds-zap-prod-code   ,
      input   gds-zap-prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   {&arh-cost}    ,
      input   {&root-cat-id},
      input   ""      ,
      input   xtog-obj ).
    /* if control-sum <> 0 then return. */
      if control-sum = 0 then do:
       { rep/io.i fact-order-2 arh-crsa 3 end}
       i = i + 1.
        run maketemptable in this-procedure
            (ostatok-end [1] ,
            ostatok-end [2] ,
            ostatok-end [5] ,
            gds-zap-artic   ,
            gds-zap-prod-code    ,
            gds-zap-prod-type   ) .
      run clear-item in this-procedure .
  end.
 end.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure print-header :
/*------------------------------------------------------------------------------
  purpose: Печать шапки отчета
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
if not firstline then  run display-title in this-procedure .
    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          {&put-u1}  "ПО ОБЪЕКТУ : " + caps(objname)  at 30 format "x(170)" skip.
    end.
    form {&wfz} .
    {&frame-d} .
     run rep/extitle.p (1) .
      break_group = true.
      break_group1 = true.

   end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/
procedure print-footer :
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/

procedure u-line :
underline stream outstream  {&all-sym9}
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        f-ostatok-end
        f-sumcost
        f-sumcrsa
        f-percent {&wfz} .
        {&frame-d}.
        end procedure.
/*-------------------------------*/

{ rep/obr-runn.i {1} no}
procedure calcitog :
/*------------------------------------------------------------------------------
  purpose:  Найти  на начало и конец  fact-order
  номерА  fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  ------------------------------------------------------------------------------*/
/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/

    run ostatok in this-procedure (
        input x-store-code  ,
        input x-store-type  ,
        input x-tog-shift,
        input x-date-start - 1 ,
        input date('')      ,
        input x-shift-start,
        input x-shift-end,
        input {&arh-cost}   ,
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
    run ostatok in this-procedure (
        input x-store-code  ,
        input x-store-type  ,
        input x-tog-shift,
        input x-date-start  ,
        input x-date-end    ,
        input x-shift-start,
        input x-shift-end,
        input {&arh-cost}   ,
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
/*------------------------------------------------------------------------------*/
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

end procedure.

procedure ob-line  :
define input  parameter x-store-code    like ub.clients.obj-code     no-undo.
define input  parameter x-store-type    like ub.clients.obj-type     no-undo.
define input  parameter x-artic         like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code     like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type     like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1  like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2  like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type      like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id        like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type  like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj        as logical no-undo.

define variable  tt# as integer  no-undo.

 if x-sum-type = {&arh-cost} then tt# = 0.
                                   else tt# = 3 .
  for each obj-list no-lock:
   if  xtog-obj then
       if   not(    x-store-type     = obj-list.obj-type
            and    x-store-code      = obj-list.obj-code ) then next.
     for each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  and   ub.ot-line.fact-order   <= x-fact-order-2
                  and   ub.ot-line.fact-order   >= x-fact-order-1
                  and   ub.ot-line.obj-code     = obj-list.obj-code
                  and   ub.ot-line.obj-type     = obj-list.obj-type
                  and   ub.ot-line.prod-code    = x-prod-code
                  and   ub.ot-line.prod-type    = x-prod-type
                  and   ub.ot-line.sum-type     = x-sum-type
                    no-lock :
                  if tog-sale then do:
                      run sale-all in this-procedure .
                    end.
                    else do:
                          if x-selectobject = {&all} then run move-all in this-procedure .
                                                     else run move-current in this-procedure . /* Движение по текущему объекту*/
                    end.
                        end.
  end.
  if tog-sale then control-sum = absolute(rash[1]).
              else control-sum = absolute(prih[1]) + absolute(rash[1]).


end procedure.
 { rep/ost-line.i no no}
 { rep/ostatok.i }
/*----------------------------------------------------------------*/
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.

           if available clients then  objname = clients.obj-name.
                                         else  objname="объект не определен".

  form with frame zapas .
  { rep/r-formh.i x(194) {&dos_cw_2}}
  run calcitog in this-procedure .

  run print-header in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */
   case retclassify :
     &if {1} = 1 &then  when "no-classify":u  then            run run1 in this-procedure .     &endif
     &if {1} = 2 &then  when "grp-goods":u then               run run2 in this-procedure .     &endif
     &if {1} = 3 &then  when "prod":u  then                   run run3 in this-procedure .     &endif
     &if {1} = 4 &then  when "prod/grp-goods":u then  run run4 in this-procedure .             &endif
     &if {1} = 5 &then  when "grp-goods/prod":u then  run run5 in this-procedure .             &endif
     &if {1} = 7 &then  when "vat-ps":u                   then  run run7 in this-procedure .   &endif
     otherwise do:
       message "Ошибка вызова!" view-as alert-box error .
     end.
   end case.

  end procedure.

/*-----------------------------------------------------------------------------------------*/
procedure clear-item :
define variable kk as integer no-undo.
 repeat kk = 1 to 6:
 assign
    prih             [kk] = 0
    rash             [kk] = 0
    kassa            [kk] = 0
    inv              [kk] = 0
    overturn         [kk] = 0
    ostatok-end      [kk] = 0
    ostatok-start    [kk] = 0   .
       end.
 end procedure.
/*-----------------------------------------------------------------------------------------*/
procedure item-goods :
 define input parameter  par-3 as character no-undo.
 define input parameter  par-4 as character no-undo.

     if par-4 = "goods":u  then do:
          find first clients where clients.obj-type = goods.prod-type and
                              clients.obj-code = goods.prod-code use-index pi no-lock .
                                assign
                                    gds-zap-unit-base  = goods.unit-base
                                    gds-zap-prt-root   = goods.prt-root
                                    gds-zap-prod-type  = goods.prod-type
                                    gds-zap-prod-code  = goods.prod-code
                                    gds-zap-artic      = goods.artic
                                    gds-zap-grp-name   = goods.grp-name
                                    gds-zap-b-code     = goods.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = goods.engl-name.
                                else
                                    assign gds-zap-gds-name = goods.gds-name.
                            end.

     if par-4 = "gds-list":u  then do:
          find first clients where clients.obj-type = gds-list.prod-type and
                              clients.obj-code = gds-list.prod-code use-index pi no-lock .
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
                            end.


    run foreach in this-procedure .
 return "not-u-line":u.
 end procedure.
 /*-----------------------------------------------------------------------------------------------------------------*/
procedure move-current :
define variable  tt#          as   integer                 no-undo.
i = 0.
         case ub.ot-line.ext-doc-type: /*разбивка по типам документов */
        /*пн*/
            when {&tdedt_pri_vnesh  }              or
            when {&tdedt_vozvrat_vnesh  }          or
            when {&tdedt_vozvrat_vnesh_kass  }     or
            when {&tdedt_pri_perem  }              or
            when {&tdedt_vozvrat_perem  }          or
            when {&tdedt_pri_prvo  }              then do:
                                                        prih[1 + tt#] = prih[1 + tt#] + ub.ot-line.fact-qnty.
                                                        prih[2 + tt#] = prih[2 + tt#] + ub.ot-line.sum-rubl.
                                                       end.
         /*РН*/
            when {&tdedt_ras_vnesh  }             or
            when {&tdedt_ras_vnesh_vp  }          or
            when {&tdedt_ras_vnesh_kass  }        or
            when {&tdedt_spi_vnesh  }             or
            when {&tdedt_inv  }                   or
            when {&tdedt_peresort  }              or
            when {&tdedt_ras_perem  }             or
            when {&tdedt_ras_prvo  }              or
            when {&tdedt_spi_prvo}                then do:
                                                       rash[1 + tt#] = rash[1 + tt#] + ub.ot-line.fact-qnty.
                                                       rash[2 + tt#] = rash[2 + tt#] + ub.ot-line.sum-rubl.
                                                       end.
          end case.
 end procedure.
 /*----------------------------------------------------------------------------------------------------------------*/
procedure maketemptable :
define input parameter dec1 like ub.stk-line.fact-qnty no-undo.
define input parameter dec2 like ub.stk-line.sum-rubl no-undo.
define input parameter dec3 like ub.stk-line.sum-rubl no-undo.
define input parameter a1 like ub.stk-line.artic     no-undo.
define input parameter a2 like ub.stk-line.prod-code no-undo.
define input parameter a3 like ub.stk-line.prod-type no-undo.
   assign
    v#qnty      = dec1
    v#sumcost   = dec2
    v#sumcrsa   = dec3
    v#artic     = a1
    v#prod-type = a3
    v#prod-code = a2
    v#effect    = v#sumcrsa - v#sumcost
    v#b-code    = 0
    v#prt-root  = 0
    v#gds-name  = ""
    v#unit-base = ""  no-error.

 if i <= xbsamount or true then do:
   create tmp#bs.
   run eqq in this-procedure .
 end.
 else do:
     case xcrit:
        when 1 then do:
           find first tmp#bs  use-index byqnty.
           if available tmp#bs and v#qnty > tmp#bs.qnty then run eqq in this-procedure .
           end.
        when 2 then do:
           find first tmp#bs  use-index bysumcost.
           if available tmp#bs and v#sumcost > tmp#bs.sumcost then run eqq in this-procedure .
           end.
        when 3 then do:
           find first tmp#bs  use-index bysumcrsa.
           if available tmp#bs and v#sumcrsa > tmp#bs.sumcrsa then run eqq in this-procedure .
           end.
    end case.
 end.

end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure eqq :
   assign
    tmp#bs.qnty      = v#qnty
    tmp#bs.sumcost   = v#sumcost
    tmp#bs.sumcrsa   = v#sumcrsa
    tmp#bs.effect    = v#effect
    tmp#bs.b-code    = v#b-code
    tmp#bs.artic     = v#artic
    tmp#bs.prod-code = v#prod-code
    tmp#bs.prod-type = v#prod-type
    tmp#bs.prt-root  = v#prt-root
    tmp#bs.gds-name  = v#gds-name
    tmp#bs.unit-base = v#unit-base.

end procedure.
/*----------------------------------------------------------------*/
procedure printtemptable :
      percent#all = 0.
      for each tmp#bs no-lock:
        find first goods where
                      goods.artic     = tmp#bs.artic
                  and goods.prod-type = tmp#bs.prod-type
                  and goods.prod-code = tmp#bs.prod-code use-index pi no-lock.
              case xcrit:
               when 1 then  percent#all = percent#all + tmp#bs.qnty .
               when 2 then  percent#all = percent#all + tmp#bs.sumcost .
               when 3 then  percent#all = percent#all + tmp#bs.sumcrsa .
              end.
          assign
          tmp#bs.b-code    = goods.gds-code
          tmp#bs.prt-root  = goods.prt-root
          tmp#bs.gds-name  = goods.gds-name
          tmp#bs.grp-name  = goods.grp-name
          tmp#bs.unit-base = goods.unit-base.
      end.
      for each tmp#bs no-lock by tmp#bs.artic  descending  :
                  if percent#all <> 0 then
                  case  xcrit:
                    when 1 then  tmp#bs.percent#1 = tmp#bs.qnty * 100 / percent#all .
                    when 2 then  tmp#bs.percent#1 = tmp#bs.sumcost * 100 / percent#all .
                    when 3 then  tmp#bs.percent#1 = tmp#bs.sumcrsa  * 100 / percent#all .
                  end case.
      end.
     case xsort:
        when 1 then do:
            { rep/r-nosale.i tmp#bs.b-code}
           end.
        when 2 then do:
            { rep/r-nosale.i tmp#bs.artic}
            end.
        when 3 then do:
            { rep/r-nosale.i tmp#bs.gds-name}
           end.
    end case.

end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure display-str  :
  display stream  outstream {&all-sym9}
    tmp#bs.b-code    @ gds-zap-b-code
    tmp#bs.artic     @ gds-zap-artic
    tmp#bs.gds-name  @ gds-zap-gds-name
    tmp#bs.unit-base @ gds-zap-unit-base
    tmp#bs.qnty      @ f-ostatok-end
    tmp#bs.sumcost   @ f-sumcost
    tmp#bs.sumcrsa   @ f-sumcrsa
    tmp#bs.percent#1 @  f-percent   {&wfz} . {&frame-d}.

    {&putexcel}
        tmp#bs.b-code     {&tabulation}
        tmp#bs.artic      {&tabulation}
        tmp#bs.gds-name   {&tabulation}
        tmp#bs.unit-base  {&tabulation}
        excel-qnty (tmp#bs.qnty)     {&tabulation}
        excel-sum(tmp#bs.sumcost)    {&tabulation}
        excel-sum(tmp#bs.sumcrsa )   {&tabulation}
        excel-sum(tmp#bs.percent#1)  skip.

    if  tog-scale and tmp#bs.prt-root <> prtroot and tmp#bs.prt-root <> 0 then
         if xsc_name = 0 then run print_scala in this-procedure .
                          else  if tmp#bs.prt-root = x-upper-code then run print_scala in this-procedure .

end procedure.
/*-------------------------------------------------------------------------------------------------------------------*/
procedure print_scala  :
define variable  tt#          as   integer                 no-undo.
/* xsc_name   */
run clear-item in this-procedure .
  for each ub.prt-obj where
                        ub.prt-obj.obj-code     = x-store-code
                  and   ub.prt-obj.obj-type     = x-store-type
                  and   ub.prt-obj.artic        = tmp#bs.artic
                  and   ub.prt-obj.prod-code    = tmp#bs.prod-code
                  and   ub.prt-obj.prod-type    = tmp#bs.prod-type
                 no-lock
                 break by ub.prt-obj.prt-code :
                 assign kassa[1] = ub.prt-obj.fact-qnty
                        kassa[2] = 0
                        kassa[3] = ub.prt-obj.fact-qnty * ub.prt-obj.price-sale .

  if last-of(prt-obj.prt-code) then do:
      find first ub.gds-prt  where ub.gds-prt.node-code = ub.prt-obj.prt-code no-lock no-error .
      { gbl/gdsbcode.i tmp#bs.b-code ub.gds-prt.node-code v-bar-code  }
      if tmp#bs.b-code <> v-bar-code then do:
      display stream  outstream {&all-sym9}
        v-bar-code                              @ gds-zap-b-code
        ""                                           @ gds-zap-artic
        ub.gds-prt.f-name                               @ gds-zap-gds-name
        tmp#bs.unit-base                             @ gds-zap-unit-base
         kassa[1] format "->>>>>>>>>9.999"           @ f-ostatok-end
         kassa[2]                                    @ f-sumcost
         kassa[3]                                    @ f-sumcrsa
        ""                                           @ f-percent
       {&wfz} . {&frame-d}.

    {&putexcel}
        v-bar-code                                                   {&tabulation}
        ""                                                           {&tabulation}
        ub.gds-prt.f-name                                               {&tabulation}
        tmp#bs.unit-base                                             {&tabulation}
       excel-qnty( kassa[1])         {&tabulation}
       excel-sum( kassa[2] )         {&tabulation}
       excel-sum (kassa[3] )         {&tabulation}
        " "     skip.
        end.

      end.
   end.
end procedure.

procedure print-sub-head :
define input parameter str1 as character no-undo.
define input parameter str2 as character no-undo.
   display stream  outstream {&all-sym9}
    ''          @ gds-zap-b-code
    str1             @ gds-zap-artic
    str2             @ gds-zap-gds-name
/*                     @ gds-zap-unit-base
                     @ f-qnty
    tmp#bs.sumcost   @ f-sumcost
    tmp#bs.sumcrsa   @ f-sumcrsa
    percent#1        @  f-percent  */
     {&wfz} .
     {&frame-d}.

    {&putexcel}
              {&tabulation}
    str1      {&tabulation}
    str2      {&tabulation}
              {&tabulation}
              {&tabulation}
              {&tabulation}
              {&tabulation}
    skip.
  run u-line in this-procedure .
end procedure.

procedure print-sub-itog :
define input parameter str1 as character no-undo.
define input parameter str2 as character no-undo.
define input parameter q1 like ub.stk-tot.fact-qnty  no-undo.
define input parameter q2 like ub.stk-tot.sum-rubl   no-undo.
define input parameter q3 like ub.stk-tot.sum-rubl   no-undo.

  run u-line in this-procedure .
  display stream  outstream {&all-sym9}
    'ИТОГО' @ gds-zap-b-code
    str1    @ gds-zap-artic
    str2    @ gds-zap-gds-name
    q1      @ f-ostatok-end
    q2      @ f-sumcost
    q3      @ f-sumcrsa
    {&wfz} .
    {&frame-d}.

    {&putexcel}
        'ИТОГО'     {&tabulation}
        str1        {&tabulation}
        str2        {&tabulation}
                    {&tabulation}
     excel-qnty(q1) {&tabulation}
     excel-sum(q2)  {&tabulation}
     excel-sum(q3)  {&tabulation}
                  skip.
 run u-line in this-procedure .
end procedure.
/*----------------------------------------------------------------------------------*/
procedure move-all :
define variable  tt#          as   integer                 no-undo.
        case ub.ot-line.ext-doc-type: /*разбивка по типам документов */
        /*пн*/
            when {&tdedt_pri_vnesh  }              or
            when {&tdedt_pri_prvo  }              then do:
                                                        prih[1 + tt#] = prih[1 + tt#] + ub.ot-line.fact-qnty.
                                                        prih[2 + tt#] = prih[2 + tt#] + ub.ot-line.sum-rubl.
                                                       end.
         /*РН*/

            when {&tdedt_vozvrat_vnesh_kass  }
                                                       then do:
                                                       rash[1 + tt#] = rash[1 + tt#] - ub.ot-line.fact-qnty.
                                                       rash[2 + tt#] = rash[2 + tt#] - ub.ot-line.sum-rubl.
                                                       end.

            when {&tdedt_vozvrat_vnesh  }
                                                       then do:
                                                       if can-find (first ub.trn-doc where ub.trn-doc.doc-code = ub.ot-line.doc-code
                                                          and ub.trn-doc.cli-code =  x-sale-code
                                                          and ub.trn-doc.cli-type =  x-sale-type
                                                          and ub.trn-doc.discnt-type <> {&cash-desk}
                                                          and ub.trn-doc.doc-type = {&return} no-lock) then do:
                                                              rash[1 + tt#] = rash[1 + tt#] - ub.ot-line.fact-qnty.
                                                              rash[2 + tt#] = rash[2 + tt#] - ub.ot-line.sum-rubl.
                                                              end.
                                                         else
                                                         assign
                                                              rash[1 + tt#] = rash[1 + tt#] + ub.ot-line.fact-qnty
                                                              rash[2 + tt#] = rash[2 + tt#] + ub.ot-line.sum-rubl.
                                                         end.

            when {&tdedt_ras_vnesh_kass  }         or
            when {&tdedt_ras_vnesh  }             or
            when {&tdedt_ras_vnesh_vp }           or
            when {&tdedt_spi_vnesh  }             or
            when {&tdedt_inv  }                   or
            when {&tdedt_peresort  }              or
            when {&tdedt_ras_prvo  }              or
            when {&tdedt_spi_prvo}                then do:
                                                       rash[1 + tt#] = rash[1 + tt#] + ub.ot-line.fact-qnty.
                                                       rash[2 + tt#] = rash[2 + tt#] + ub.ot-line.sum-rubl.
                                                       end.
          end case.
end procedure.
/*----------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------*/
procedure sale-all :
define variable  tt#          as   integer                 no-undo.
        case ub.ot-line.ext-doc-type: /*разбивка по типам документов */
         /*РН*/

            when {&tdedt_vozvrat_vnesh_kass}
                                                       then do:
                                                       rash[1 + tt#] = rash[1 + tt#] - ub.ot-line.fact-qnty.
                                                       rash[2 + tt#] = rash[2 + tt#] - ub.ot-line.sum-rubl.
                                                       end.

            when {&tdedt_vozvrat_vnesh}
                                                       then do:
                                                       if can-find (first ub.trn-doc where ub.trn-doc.doc-code = ub.ot-line.doc-code
                                                          and ub.trn-doc.cli-code =  x-sale-code
                                                          and ub.trn-doc.cli-type =  x-sale-type
                                                          and ub.trn-doc.discnt-type <> {&cash-desk}
                                                          and ub.trn-doc.doc-type = {&return} no-lock) then do:
                                                              rash[1 + tt#] = rash[1 + tt#] - ub.ot-line.fact-qnty.
                                                              rash[2 + tt#] = rash[2 + tt#] - ub.ot-line.sum-rubl.
                                                              end.
                                                         end.
            when {&tdedt_ras_vnesh_kass}
                                                          then do:
                                                       rash[1 + tt#] = rash[1 + tt#] + ub.ot-line.fact-qnty.
                                                       rash[2 + tt#] = rash[2 + tt#] + ub.ot-line.sum-rubl.
                                                       end.
          end case.

end procedure.
procedure Display-b1 :
end procedure. /* Display-b1 */
procedure Display-line :
end procedure. /* Display-line */
procedure Clear-b1  :
end procedure. /* Clear-b1  */
procedure Clear-b2  :
end procedure. /* Clear-b2  */


/* $Workfile$ e n d */