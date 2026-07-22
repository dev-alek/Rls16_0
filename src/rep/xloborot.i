/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет Excel

Автор: Чернова Светлана Александровна
Дата создания: 19/01/01
Author: Svetlana Chernova
Creation date: 19/01/01

*/
define input  parameter x-store-code  like ub.clients.obj-code   no-undo .
define input  parameter x-store-type  like ub.clients.obj-type   no-undo .
define input  parameter x-base-type   like ub.currency.curr-abbr no-undo .
define input  parameter x-base-code   like ub.currency.curr-code no-undo .
define input  parameter xclassify     as character  no-undo .
define input  parameter xsorttype     as character  no-undo .
define input  parameter xsumsonly     as logical    no-undo .
define input  parameter xshowzero     as logical    no-undo .
define input  parameter xshowzero-2   as logical    no-undo .
define input  parameter xtog-obj      as logical    no-undo .
define input  parameter xshowcost     as logical    no-undo .
define input  parameter xshowcostnds  as logical    no-undo .
define input  parameter xshowcrsa     as logical    no-undo .
define input  parameter xshowcrsands  as logical    no-undo .
define input  parameter xshowsale     as logical    no-undo .
define input  parameter xshowsalends  as logical    no-undo .
define input  parameter xtog-lavel    as logical    no-undo .
define input  parameter xvar-lavel    as integer    no-undo .
define input  parameter xserv         as character  no-undo .
define input  parameter xshowmediator as logical    no-undo .
define input  parameter xshowsaleslt  as logical    no-undo .
define input  parameter x-vat         as logical    no-undo .
define input  parameter xlongname     as logical    no-undo .
define input  parameter x-tog-wt      as logical    no-undo .
define input  parameter x-tog-ms      as logical    no-undo .
define input  parameter p-is-petrol   as logical    no-undo .
define input  parameter xDens         as logical    no-undo .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость Execl".
{ cmp/vssrevis.i }

&scop e-col 13

/* parameters definitions ---                                           */
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i {3} }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ rep/rep-bt.i   }

define variable x-db-num    like ub.clients.db-num   no-undo.
define variable v-nn        as integer   no-undo .
define variable v-name-type as character no-undo .
define variable long-p      as logical   no-undo .

define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int.


define variable m         as integer no-undo.
define variable l         as integer no-undo.
define variable i-str     as integer no-undo.
define variable icolumn   as integer no-undo.
define variable ccolumn   as character no-undo.
define variable crange    as character no-undo.
define variable allcol    as int no-undo.


&scop max-col-rep 27
&scop const-col-rep 8

define variable  null-str#      as decimal  no-undo.
define variable  null-str2#     as decimal  no-undo.
define variable  b1-null-str#   as decimal  no-undo.
define variable  b1-null-str2#  as decimal  no-undo.
define variable  b2-null-str#   as decimal  no-undo.
define variable  b2-null-str2#  as decimal  no-undo.
define variable t-time   as integer  no-undo .

define variable  tprintrubl as log no-undo.


define stream  instream  .
define stream  outstream  .
define stream  outstream2  .

make-excel-com = false .
make-excel     = true  .

define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

define variable c-c      as integer no-undo .
define variable c-str    as character no-undo .
define variable str--1   as character format "x(60)" no-undo.
define variable str--2   as integer no-undo .
define variable c-i      as integer no-undo .
define variable p-var    as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .

define variable objname        as   char no-undo.
define variable select-good    as   integer no-undo.
define variable chosedtype     as   integer no-undo.
define variable paytype        as   integer no-undo.
define variable retclassify    as   char  no-undo.
define variable retsorttype    as   char  no-undo.
define variable show-negativ   as   logical  no-undo.
define variable show-negativ-2 as   logical  no-undo.
define variable sums-only      as   logical  no-undo.
define variable valtype        as   integer no-undo.
define variable line           as   char        no-undo.
define variable firstline      as   logical     no-undo.
define variable nk as integer no-undo .
define variable lp as int no-undo.
define variable mp as int no-undo.
define variable mp-1 as int no-undo.

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk       as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base    no-undo .
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-gds-long-name  as character format "x(120)" no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo .
define variable gds-zap-type          like ub.goods.gds-type    no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name    no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name  no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo .
define variable gds-zap-nds           like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-np            like ub.stk-tot.sum-base  no-undo .

define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent {&e-col}  format "->>>>>>>>>>>9.<<<" no-undo.

define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .
define variable v-gds-num          as integer no-undo .
define variable gds-wt-base        like ub.goods.wt-base      no-undo .
define variable gds-ms-base        like ub.goods.ms-base      no-undo .

define buffer kg-obj-list for obj-list .

{ rep/repfrm.i def}


 &glob bef-disc disc
 &glob bef-eff  eff
 &glob bef-prc  prc


 &glob bef-sum-cost sum-cost
 &glob bef-sum-crsa sum-crsa
 &glob bef-sum-sale sum-sale

{ rep/def-ob.i tdedt_pri_vnesh}
{ rep/def-ob.i tdedt_ras_vnesh}
{ rep/def-ob.i tdedt_ras_vnesh_vp}
{ rep/def-ob.i tdedt_ras_vnesh_kass}
{ rep/def-ob.i tdedt_vozvrat_vnesh}
{ rep/def-ob.i tdedt_vozvrat_vnesh_kass}
{ rep/def-ob.i tdedt_spi_vnesh}
{ rep/def-ob.i tdedt_inv}
{ rep/def-ob.i tdedt_pri_perem}
{ rep/def-ob.i tdedt_ras_perem}
{ rep/def-ob.i tdedt_vozvrat_perem}
{ rep/def-ob.i tdedt_ras_prvo}
{ rep/def-ob.i tdedt_spi_prvo}
{ rep/def-ob.i tdedt_pri_prvo}
{ rep/def-ob.i tdedt_overturn}
{ rep/def-ob.i TDEDT_Chg_Purch_Code }
{ rep/def-ob.i TDEDT_Corr_Acc_Price }

{ rep/def-ob.i disc}
{ rep/def-ob.i eff}
{ rep/def-ob.i prc}

{ rep/def-ob.i sum-cost}
{ rep/def-ob.i sum-crsa}
{ rep/def-ob.i sum-sale}
{ rep/procobor.i def-tt }
{ rep/procobor.i func-vat }
{ rep/r-libmcr.i macr_excel         }


define variable nn      as   int  no-undo.
define variable report1 as int no-undo.
define variable report2 as int no-undo.
define variable errorlevel as int no-undo.
define variable first-lavel as integer no-undo .
define variable sf1 as handle .
define variable sf2 as handle .
create editor sf1 .
create editor sf2 .

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
define variable  temp-str-2 as char no-undo.

define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define variable rn as character no-undo .

  rn = "Оборотная ведомость по всем типам в excel" .
  allcol = num-entries(sizes) - 1 .

&glob f-q "->>>>>>>>>9.999"
&glob f-s "->>>>>>>>>>9.99"

{ rep/repfrm.i on 25}
{ rep/repfrm.i disp i-str rn  objname}


 t-time = time.
     assign
        number-list    = 1
        i              = 0
        xlavel         = xvar-lavel
        select-good    = x-selectgood
        paytype        = x-set_pay_type
        retclassify    = xclassify
        retsorttype    = xsorttype
        sums-only      = xsumsonly
        show-negativ   = xshowzero
        show-negativ-2   = xshowzero-2
        x-selectobject = "".
        firstline      = false.
        valtype        = if (paytype = 1) then 0  else x-set_val_type.

  if p-is-petrol = true  then
  assign
    Select-Good  = {&g-choice}
    x-SelectGood = {&g-choice}
  .

    if x-vat then x-vat = false .
            else x-vat = true .

    if x-vat then v-name-type = "учет.".
    else  v-name-type = "учет-НДС".

  if  x-date-end  - x-date-start > 400
      then long-p = true    .
      else  long-p = false     .

  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if available ub.gds-grp then  first-lavel = ub.gds-grp.node-code.
                          else first-lavel = 0.

  valtype  = if (paytype = 1) then 0  else x-set_val_type.

  if (valtype = 0 and x-base-code = 0)  or valtype = 1
    then assign tprintrubl = yes .
    else assign tprintrubl = no .

  run make-tt-ed in this-procedure .
  run find-mediator  in this-procedure ( input v-cntxt-host-code-obj ,input xshowmediator, output mediator-host-code, output f-flag) .
  if f-flag = false then return.

        run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------*/
{ rep/f-flav.i }
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

    p-file-name =  string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) + ".txt" ) .

    output stream outstream to value( string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) ) )      .
    output stream outstream2 to value(p-file-name).

    /* создаем временный файл */
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
                put stream  outstream  "1" format "x(100)" skip .
    v-ind = 1    .
    num#str# = 0 .

      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format( reportname , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */

define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

&scop var-print-n  v-nn = num-entries( ~{&var-str-n} , "~{&new-line}"  )   .   do l-ii = 1 to v-nn  :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format(                                                          ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }



  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format(
        cur-time-print() +
      " Цены указаны в " +
      (if tprintrubl then "{&abbr_rub_allshift}" else x-base-type )
      , num#str#
      , num#col#
        ) .
/*Печать шапки */
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
assign
old-s =   num#str#
.

run make-col.
assign
old-s2 =   num#str#
.

   num#str# = old-s + 1.
   run proc-print-header.
   num#str# = old-s2.

   define variable gj as integer no-undo init 0.
   if xtog-obj /* раздельно по объектам */ then do:
      for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          run report-exec1 in this-procedure .
          gj = gj + 1 .
      end.
      if gj > 1 then   run display-bo in this-procedure .
      end.
   else  run report-exec1 in this-procedure .

/*   message  " Время составления отчета " + string((time - t-time),"hh:mm:ss" ) . */
   output stream outstream close.
   output stream outstream2 close.
  output stream macr_excel  close .
  { rep/repfrm.i off}
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
  define variable v-temp-str as character no-undo .
  define variable v-ii    as integer no-undo .
  define variable v-jj    as integer no-undo .
  v-temp-str = "" .
  v-jj = 0 .
  if use-column [1] then
    assign
     v-jj = 1
    .

  repeat v-ii = 2 to 5 :
   if use-column [v-ii] then do :
      v-jj = v-jj + 1 .
      v-temp-str = v-temp-str + string(v-jj) + "," .
      end.
  end.

  v-temp-str = substring(v-temp-str , 1 , LENGTH(v-temp-str) - 1 ) .
    if v-temp-str <> "" then do:
        run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input v-temp-str
        ) .

   end.

  run end-proc .
  { rep/repfrm.i off}
  run rep/runexcel.p (p-file-name ).
end procedure.


procedure foreach :
define buffer buf_goods for ub.goods  .
find first  buf_goods no-lock where buf_goods.gds-code = gds-zap-b-code no-error .

  assign
    gds-zap-gds-long-name = substring ((if buf_goods.engl-name <> ? then trim(buf_goods.engl-name) else "" ) +
                          ( if buf_goods.label-name <> ? then trim(buf_goods.label-name) else ""), 1,120)
    p-price-med = 0
    i-str = i-str + 1
    null-str# = 1
    null-str2# = 1
    gds-ms-base        = if buf_goods.ms-base = ? then 0 else buf_goods.ms-base
    gds-wt-base        = if buf_goods.wt-base = ? then 0 else buf_goods.wt-base
  .

  /* Найдем цену посредника по этому товару */
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
          .
    end.

 { rep/repfrm.i disp i-str rn objname}

  run clear-item  in this-procedure .
{ rep/io.i fact-order-1 arh-cost 0 start}
  if p-is-petrol then do: /* Топливо */
  { rep/iop.i fact-order-1 'no' 0 start }
  end.

if xshowcrsa or xshowcrsands or use-column[23] or use-column[24] or xshowmediator then do:
   { rep/io.i fact-order-1 arh-crsa 3 start}
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
   { rep/io.i fact-order-1 arh-crsa 6 start}
   end.


{ rep/io.i fact-order-2 arh-cost 0 end}
    if p-is-petrol then do: /* Топливо */
    { rep/iop.i fact-order-2 'no' 0 end }
    end.
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator then do:
   { rep/io.i fact-order-2 arh-crsa 3 end}
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
   { rep/io.i fact-order-2 arh-crsa 6 end}
   end.


   if gds-zap-type = {&gds-goods} then { rep/r-ob-ln.i {&arh-cost} ''}
                                  else { rep/r-ob-ln.i {&arh-cost-service} ''}
   run calc-sub-itog  in this-procedure (0).
   if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator   then do:
      if gds-zap-type = {&gds-goods}  then { rep/r-ob-ln.i {&arh-crsa} ''}
                                      else { rep/r-ob-ln.i {&arh-crsa-service} ''}
     run calc-sub-itog in this-procedure  (3).
  end.
   if xshowsale or xshowsalends
      or use-column[21] or use-column[23] or use-column[24]   or xshowmediator  then do:
      if gds-zap-type = {&gds-goods}  then { rep/r-ob-ln.i {&arh-sale} ''}
                                      else { rep/r-ob-ln.i {&arh-sale-service} ''}
     run calc-sub-itog in this-procedure  (6).
  end.

    if not show-negativ then  run null-str-pr in this-procedure .
    if not show-negativ-2 then  run null-str-pr2  in this-procedure .

&scop run-calc-ms-wt run calc-ms-wt in this-procedure ( input ~{&var-name}[1] ~
                                    , input ~{&gds-base} ~
                                    , input-output    ~{&var-name}[~{&col-num}] ~
                                    , input-output bi-~{&var-name}[~{&col-num}] ~
                                    , input-output bo-~{&var-name}[~{&col-num}] ~
                                    , input-output b1-~{&var-name}[~{&col-num}] ~
                                    , input-output b2-~{&var-name}[~{&col-num}] ~
                                    ) .

&scop run-calc-dens run calc-dens in this-procedure ( input ~{&var-name}[1] ~
                                    , input ~{&var-name}[11] ~
                                    , input-output    ~{&var-name}[~{&col-num}] ~
                                    , input-output bi-~{&var-name}[~{&col-num}] ~
                                    , input-output bo-~{&var-name}[~{&col-num}] ~
                                    , input-output b1-~{&var-name}[~{&col-num}] ~
                                    , input-output b2-~{&var-name}[~{&col-num}] ~
                                    ) .

&scop run-calc-pt-ob run calc-pt-ob in this-procedure ( input '~{&n-p}' ~
, input x-store-type ~
, input x-store-code  ~
, input gds-zap-artic     ~
, input gds-zap-prod-type ~
, input gds-zap-prod-code ~
, input-output    ~{&var-name}[~{&col-num}] ~
, input-output bi-~{&var-name}[~{&col-num}] ~
, input-output bo-~{&var-name}[~{&col-num}] ~
, input-output b1-~{&var-name}[~{&col-num}] ~
, input-output b2-~{&var-name}[~{&col-num}] ~
) .

&scop run-calc-density run calc-density in this-procedure ( input '~{&n-p}' ~
, input x-store-type ~
, input x-store-code  ~
, input gds-zap-artic     ~
, input gds-zap-prod-type ~
, input gds-zap-prod-code ~
, input-output    ~{&var-name}[~{&col-num}] ~
, input-output bi-~{&var-name}[~{&col-num}] ~
, input-output bo-~{&var-name}[~{&col-num}] ~
, input-output b1-~{&var-name}[~{&col-num}] ~
, input-output b2-~{&var-name}[~{&col-num}] ~
) .

if x-tog-wt then do :
  &scop col-num 11
  &scop gds-base gds-wt-base

  &scop var-name ostatok-start
  {&run-calc-ms-wt}
  &scop var-name ostatok-end
  {&run-calc-ms-wt}
  &scop var-name oborot-~{&n-p}

  &scop  n-p {&bef-TDEDT_Pri_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_RAS_Vnesh_VP}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh_Kass}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh_Kass}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Spi_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Inv}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Pri_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Prvo}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Pri_Prvo}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Overturn}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Corr_Acc_Price}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Chg_Purch_Code}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
end. /* if x-tog-wt */

if x-tog-ms then do :
  &scop col-num 12
  &scop gds-base gds-ms-base

  &scop var-name ostatok-start
  {&run-calc-ms-wt}
  &scop var-name ostatok-end
  {&run-calc-ms-wt}

  &scop var-name oborot-~{&n-p}

  &scop  n-p {&bef-TDEDT_Pri_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_RAS_Vnesh_VP}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh_Kass}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh_Kass}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Spi_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Inv}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Pri_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Prvo}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Pri_Prvo}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Overturn}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Corr_Acc_Price}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Chg_Purch_Code}
  {&run-calc-ms-wt}
end. /*if x-tog-ms*/

if xDens then do :
  &scop col-num 13
  &scop var-name ostatok-start
  {&run-calc-dens}
  &scop var-name ostatok-end
  {&run-calc-dens}

  &scop var-name oborot-~{&n-p}

  &scop  n-p {&bef-TDEDT_Pri_Vnesh}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_RAS_Vnesh_VP}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh_Kass}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh_Kass}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Spi_Vnesh}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Inv}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Pri_Perem}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Ras_Perem}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Vozvrat_Perem}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Ras_Prvo}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Pri_Prvo}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Overturn}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Corr_Acc_Price}
  {&run-calc-density}
  &scop  n-p {&bef-TDEDT_Chg_Purch_Code}
  {&run-calc-density}
end. /*if xDens*/

end procedure.


procedure display-line :
  i = i + 1.
   if not  (not show-negativ and null-str# = 0 ) then do:
       if not  (not show-negativ-2 and null-str2# = 0  ) then do:
        if not sums-only then do:
            if fr0 = true then do:
              num#str# = num#str# + 1.
              num#col# = 1.

              run macr_excel_char_with_format( string(tmp#stroka0)  , num#str# , num#col#  ) .
              run macr_cell_format
              ( 10    ,      /* p-size     */
                true  ,      /* p-bold     */
                true  ,      /* p-italic   */
                33    ,      /* p-color-bg */
                num#str# ,   /* p-row      */
                num#col# ,   /* p-col      */
                num#str# ,   /* p-row-2    */
                5 ) .        /* p-col-2    */

              fr0 = false .
            end.

            if fr = true then do:
                num#str# = num#str# + 1.
                num#col# = 2.

                run macr_excel_char_with_format( string(caps(temp-str))  , num#str# , num#col#  ) .
                run macr_cell_format
                  ( 10    ,      /* p-size     */
                    true  ,      /* p-bold     */
                    true  ,      /* p-italic   */
                    36    ,      /* p-color-bg */
                    num#str# ,   /* p-row      */
                    num#col# ,   /* p-col      */
                    num#str# ,   /* p-row-2    */
                    5 ) .        /* p-col-2    */

              fr = false .
            end.

            run display-str1 in this-procedure .
            run new-tmp-page .
            end.
        end.
    end.
end procedure.


procedure print-header :
if not firstline then   do: end.


    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
     num#str# = num#str# + 1.
     num#col# = 1.
     run macr_excel_char_with_format(
     string(  "ПО ОБЪЕКТУ : " + ObjName)
      , num#str# , num#col#  ) .

     num#col# = num#col# + 3.
     run macr_excel_char_with_format(
     string(  x-store-type + " " + string(x-store-code)  )
      , num#str# , num#col#  ) .

     num#col# = num#col# + 1.
     run macr_excel_char_with_format(
     string( "УБД " + string(x-db-num)  )
      , num#str# , num#col#  ) .


    end.

      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
      run clear-bi in this-procedure .
      break_group = true.
      break_group1 = true.
   end procedure.


procedure print-footer :
     num#str# = num#str# + 1.
     num#col# = 1.
     run macr_excel_char_with_format( string("ИТОГО"  )  , num#str# , num#col#  ) .
     run display-bi in this-procedure .
end procedure.

{ rep/obr-runn.i {1} {2} {3}}

procedure calcitog :
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xtog-obj ,

        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
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
procedure display-str1  :
define variable ll as int no-undo.
  assign
    num#str# = num#str# + 1
    num#col# = 0
    v-gds-num = v-gds-num + 1
  .
  if use-column[28] then do: assign num#col#  = num#col# + 1 .   run macr_excel_dec ( v-gds-num , num#str# , num#col#   ) .   end.
  if use-column[1]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_dec ( gds-zap-b-code , num#str# , num#col#   ) .   end.
  if use-column[2]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-artic, num#str# , num#col#   )   .   end.
  if use-column[3]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( if xlongName then gds-zap-gds-long-name else gds-zap-gds-name, num#str# , num#col#   ) .  end.
  if use-column[4]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-unit-base, num#str# , num#col#   ) . end.
  if use-column[5]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-type, num#str# , num#col#   ) .      end.
  { rep/xl-obstr.i }
end procedure.


procedure display-bi  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .

  run macr_cell_format
                              ( 10    ,      /* p-size     */
                                true  ,      /* p-bold     */
                                false ,      /* p-italic   */
                                ?    ,       /* p-color-bg */
                                num#str# ,   /* p-row      */
                                1 ,          /* p-col      */
                                num#str# ,   /* p-row-2    */
                                (mp + ll + (kk * ({&max-col-rep} - {&const-col-rep})))   /* p-col-2    */
                                ) .

{ rep/xl-obstr.i bi-}
end procedure.

procedure display-bo  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( string("ИТОГО ПО ОБЪЕКТАМ")  , num#str# , num#col#  ) .

  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
  run macr_cell_format
      ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        false ,      /* p-italic   */
        ?    ,       /* p-color-bg */
        num#str# ,   /* p-row      */
        1 ,          /* p-col      */
        num#str# ,   /* p-row-2    */
        (mp + ll + (kk * ({&max-col-rep} - {&const-col-rep})))   /* p-col-2    */
        ) .

   { rep/xl-obstr.i bo-}
end procedure.


procedure display-b1  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  b1-null-str# = 1.
  b1-null-str2# = 1.

  if not show-negativ   then  run b1-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b1-null-str-pr2  in this-procedure .

   if not     ( not show-negativ   and b1-null-str#  = 0  ) then do :
      if not  ( not show-negativ-2 and b1-null-str2# = 0  ) then do :
              /*шапка для верхней группы  когда только итоги ++++  */
              if sums-only then do:
                  if fr0 = true then do:
                        num#str# = num#str# + 1     .
                        num#col# = 1.
                        run macr_excel_char_with_format(  caps(tmp#stroka0)  , num#str# , num#col#  ) .
                        run macr_cell_format
                        ( 10    ,      /* p-size     */
                          true  ,      /* p-bold     */
                          true  ,      /* p-italic   */
                          36    ,      /* p-color-bg */
                          num#str# ,   /* p-row      */
                          num#col# ,   /* p-col      */
                          num#str# ,   /* p-row-2    */
                          5 ) .        /* p-col-2    */

                      fr0 = false .
                    end.
               end.


  num#str# = num#str# + 1     .
  num#col# = 2 .
  if substitute( "&1", sf1:screen-value )  <> "?" then
    run macr_excel_char_with_format(  string(s-bar-code +
                                 sf1:screen-value +
                                 gds-zap-artic +
                                 sf2:screen-value +
                                 gds-zap-gds-name +
                                 temp-str-2    )  , num#str# , num#col#  ) .

   else
    run macr_excel_char_with_format(  string(s-bar-code +
                                 gds-zap-artic +
                                 gds-zap-gds-name +
                                 temp-str-2    )  , num#str# , num#col#  ) .

  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .


  { rep/xl-obstr.i b1-}
     run macr_cell_format
                        ( 10    ,       /* p-size     */
                          true  ,       /* p-bold     */
                          true  ,       /* p-italic   */
                          36    ,       /* p-color-bg */
                          num#str# ,    /* p-row      */
                          2,            /* p-col      */
                          num#str# ,    /* p-row-2    */
                          num#col#  ) . /* p-col-2    */

  end.
  end.
end procedure.

procedure display-b2  :
define variable ll as int no-undo.
define variable kk as int no-undo.

b2-null-str#  = 1 .
b2-null-str2# = 1 .

  if not show-negativ   then  run b2-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b2-null-str-pr2  in this-procedure .

   if not  (not show-negativ   and b2-null-str#  = 0  ) then do :
      if not  (not show-negativ-2 and b2-null-str2# = 0  ) then do :


assign
  num#str# = num#str# + 1
  num#col# = 1.
  run macr_excel_char_with_format( string( s-bar-code + ' ' + gds-zap-artic + ' ' + gds-zap-gds-name)  , num#str# , num#col#  ) .
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .

  { rep/xl-obstr.i b2-}
  run macr_cell_format
  ( 10    ,      /* p-size     */
    true  ,      /* p-bold     */
    true  ,      /* p-italic   */
    33    ,      /* p-color-bg */
    num#str# ,   /* p-row      */
    1 ,          /* p-col      */
    num#str# ,   /* p-row-2    */
    num#col# ) . /* p-col-2    */

  end.
  end.

end procedure.


procedure clear-b1  :
 { rep/o-clear.i b1}
end procedure.
procedure clear-b2  :
 { rep/o-clear.i b2}
end procedure.
procedure clear-bi  :
 { rep/o-clear.i bi}
end procedure.

procedure ob-line  :
 { rep/ob-line.i }
end procedure.
 { rep/ost-line.i {2} {2}}
 { rep/ostatok.i }
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code
                            no-lock no-error.

           if available clients then assign  objname = clients.obj-name
                                             x-db-num     = clients.db-num.
                                         else  objname="объект не определен".
  run calcitog in this-procedure .
  run print-header in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */   case retclassify :
   &if {1} = 1 &then   when "no-classify":u    then  run run1 in this-procedure . &endif
   &if {1} = 2 &then   when "grp-goods":u      then  run run2 in this-procedure . &endif
   &if {1} = 3 &then   when "prod":u           then  run run3 in this-procedure . &endif
   &if {1} = 4 &then   when "prod/grp-goods":u then  run run4 in this-procedure . &endif
   &if {1} = 5 &then   when "grp-goods/prod":u then  run run5 in this-procedure . &endif
   &if {1} = 7 &then   when "vat-ps":u         then  run run7 in this-procedure . &endif
   otherwise do:
     message "Ошибка вызова" view-as alert-box error .
   end.
   end case.

  run print-footer in this-procedure .
  end procedure.

procedure calc-sub-itog :
define input parameter tt as int no-undo.
define variable tt2 as integer no-undo .

  if tt = 6 then tt2 = 7 .
            else tt2 = tt.

repeat i# = 1 + tt to 3 + tt2 :
  { rep/run-ii.i tdedt_inv                 tdedt_pri_vnesh          tt }
  { rep/run-ii.i tdedt_pri_perem           tdedt_ras_vnesh          tt }
  { rep/run-ii.i tdedt_ras_perem           tdedt_ras_vnesh_vp       tt }
  { rep/run-ii.i tdedt_vozvrat_perem       tdedt_ras_vnesh_kass     tt }
  { rep/run-ii.i tdedt_ras_prvo            tdedt_vozvrat_vnesh      tt }
  { rep/run-ii.i tdedt_pri_prvo            tdedt_vozvrat_vnesh_kass tt }
  { rep/run-ii.i tdedt_overturn            tdedt_spi_vnesh          tt }
  { rep/run-ii.i TDEDT_Corr_Acc_Price      TDEDT_Chg_Purch_Code     tt }
  b1-oborot-{&bef-tdedt_ras_prvo}[ i#] = b1-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  b2-oborot-{&bef-tdedt_ras_prvo}[ i#] = b2-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  bi-oborot-{&bef-tdedt_ras_prvo}[ i#] = bi-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].
  bo-oborot-{&bef-tdedt_ras_prvo}[ i#] = bo-oborot-{&bef-tdedt_ras_prvo}[ i#] + oborot-{&bef-tdedt_spi_prvo}[ i#].

  bo-ostatok-start[ i#]  = bo-ostatok-start[i#]  + ostatok-start[ i#]  .
  bo-ostatok-end[ i#]    = bo-ostatok-end[i#]    + ostatok-end[ i#]    .

  if i# = 7 then b1-oborot-{&bef-disc}[1 ]  = b1-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
  if i# = 7 then b2-oborot-{&bef-disc}[1 ]  = b2-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
  if i# = 7 then bi-oborot-{&bef-disc}[1 ]  = bi-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .
  if i# = 7 then bo-oborot-{&bef-disc}[1 ]  = bo-oborot-{&bef-disc}[1]  + oborot-{&bef-disc}[1]  .


  if i# = 8 then
    assign
      bi-oborot-sum-sale[ i#]  = bi-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              bi-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              bi-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

      b1-oborot-sum-sale[ i#]  = b1-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              b1-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              b1-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

      b2-oborot-sum-sale[ i#]  = b2-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              b2-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              b2-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
      bo-oborot-sum-sale[ i#]  = bo-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                              bo-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                              bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                              bo-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
      .
  if  xshowmediator = true  then do:
      if i# = 8 then b1-oborot-sum-cost[2 ]  = b1-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then b2-oborot-sum-cost[2 ]  = b2-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bi-oborot-sum-cost[2 ]  = bi-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bo-oborot-sum-cost[2 ]  = bo-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  end.

  if i# = 2 and xshowmediator = false  then
      assign
        bi-oborot-sum-cost[ i#]  = bi-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                bi-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                bi-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                bi-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

        b1-oborot-sum-cost[ i#]  = b1-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                b1-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                b1-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]

        b2-oborot-sum-cost[ i#]  = b2-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                b2-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                b2-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
        bo-oborot-sum-cost[ i#]  = bo-oborot-{&bef-tdedt_ras_vnesh}[ i#] +
                                bo-oborot-{&bef-tdedt_vozvrat_vnesh}[ i#]         +
                                bo-oborot-{&bef-tdedt_vozvrat_vnesh_kass}[ i#]    +
                                bo-oborot-{&bef-tdedt_ras_vnesh_kass}[ i#]
        .

  if i# = 8 then b1-oborot-{&bef-eff}[1 ]  = b1-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .
  if i# = 8 then b2-oborot-{&bef-eff}[1 ]  = b2-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .
  if i# = 8 then bi-oborot-{&bef-eff}[1 ]  = bi-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .
  if i# = 8 then bo-oborot-{&bef-eff}[1 ]  = bo-oborot-{&bef-eff}[1]  + oborot-{&bef-eff}[1]  .

  if i# = 8 then    if  bi-oborot-sum-cost[2] <>  0 then
                        bi-oborot-{&bef-prc}[1] = 100 * (bi-oborot-sum-sale[8] - bi-oborot-sum-cost[2] ) / bi-oborot-sum-cost[2] .
                   else bi-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  bo-oborot-sum-cost[2] <>  0 then
                        bo-oborot-{&bef-prc}[1] = 100 * (bo-oborot-sum-sale[8] - bo-oborot-sum-cost[2] ) / bo-oborot-sum-cost[2] .
                   else bo-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  b1-oborot-sum-cost[2] <>  0 then
                        b1-oborot-{&bef-prc}[1] = 100 * (b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
                   else b1-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  b2-oborot-sum-cost[2] <>  0 then
                        b2-oborot-{&bef-prc}[1] = 100 * (b2-oborot-sum-sale[8] - b2-oborot-sum-cost[2] ) / b2-oborot-sum-cost[2] .
                   else b2-oborot-{&bef-prc}[1] = 0.
 end.
end procedure.


procedure sum-i :
define input parameter ob like oborot-{&bef-tdedt_overturn}[1] no-undo.
define input parameter tt as int  no-undo.
define input-output parameter b1 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b2 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bi like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bo like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input parameter ob2 like oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b1- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b2- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bi- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bo- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
assign
 b1  = b1 + ob
 b2  = b2 + ob
 b1- = b1- + ob2
 b2- = b2- + ob2
 .
    assign
    bi = bi + ob
    bo = bo + ob
    bi- = bi- + ob2
    bo- = bo- + ob2
    .
end procedure.

procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to {&e-col} :
 assign
    oborot-{&bef-tdedt_pri_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh_vp }              [kk]    = 0
    oborot-{&bef-tdedt_ras_vnesh_kass }            [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_vnesh }             [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [kk]    = 0
    oborot-{&bef-tdedt_spi_vnesh }                 [kk]    = 0
    oborot-{&bef-tdedt_inv }                       [kk]    = 0
    oborot-{&bef-tdedt_pri_perem }                 [kk]    = 0
    oborot-{&bef-tdedt_ras_perem }                 [kk]    = 0
    oborot-{&bef-tdedt_vozvrat_perem }             [kk]    = 0
    oborot-{&bef-tdedt_ras_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_spi_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_pri_prvo }                  [kk]    = 0
    oborot-{&bef-tdedt_overturn }                  [kk]    = 0
    oborot-{&bef-disc}                             [kk]    = 0
    oborot-{&bef-eff}                              [kk]    = 0
    oborot-{&bef-prc}                              [kk]    = 0
    oborot-{&bef-TDEDT_Corr_Acc_Price }            [kk]    = 0
    oborot-{&bef-TDEDT_Chg_Purch_Code }            [kk]    = 0
    ostatok-end                                    [kk]    = 0
    ostatok-start                                  [kk]    = 0
  .
 end.
end procedure.

procedure item-goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then  assign
                                    gds-zap-unit-base  = goods.unit-base
                                    gds-zap-prt-root   = goods.prt-root
                                    gds-zap-prod-type  = goods.prod-type
                                    gds-zap-prod-code  = goods.prod-code
                                    gds-zap-artic      = goods.artic
                                    gds-zap-type       = goods.gds-type
                                    gds-zap-grp-name   = goods.grp-name
                                    gds-zap-b-code     = goods.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then goods.engl-name
                                                                       else goods.gds-name
                                    gds-zap-gds-long-name = substring ((if goods.engl-name <> ? then trim(goods.engl-name) else "" ) +
                                                            ( if goods.label-name <> ? then trim(goods.label-name) else "" ),1,120).

     if par-4 = "gds-list":u  then  assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-type       = gds-list.gds-type
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then gds-list.engl-name
                                                                       else gds-list.gds-name
                                    gds-zap-gds-long-name = substring ((if gds-list.engl-name <> ? then trim(gds-list.engl-name) else "" ) +
                                                            ( if gds-list.label-name <> ? then trim(gds-list.label-name) else ""), 1,120).


    run foreach in this-procedure .
    { rep/r-obreak.i &par1=1 }
    run display-line in this-procedure .
 end procedure.
procedure b1-null-str-pr :
 if (
     b1-oborot-{&bef-tdedt_pri_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_spi_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_pri_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0 and
     b1-oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_inv}                       [1] = 0 and
     b1-oborot-{&bef-tdedt_pri_perem }                [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_perem }                [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0 and
     b1-oborot-{&bef-tdedt_overturn }                 [2] = 0 and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price }           [1] = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code }           [1] = 0 and
     b1-ostatok-end[1]                                    = 0 and
     b1-ostatok-start[1]                                  = 0 and
     b1-oborot-{&bef-tdedt_pri_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_spi_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_pri_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0 and
     b1-oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_inv}                       [2] = 0 and
     b1-oborot-{&bef-tdedt_pri_perem }                [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_perem }                [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0 and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price }           [2] = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code }           [2] = 0 and
     b1-ostatok-end[2]                                    = 0 and
     b1-ostatok-start[2]                                  = 0

     ) then  b1-null-str# = 0    .
end procedure.


procedure b1-null-str-pr2 :
 if (
     b1-oborot-{&bef-tdedt_pri_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_spi_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_prvo }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_pri_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0 and
     b1-oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0 and
     b1-oborot-{&bef-tdedt_inv}                       [1] = 0 and
     b1-oborot-{&bef-tdedt_pri_perem }                [1] = 0 and
     b1-oborot-{&bef-tdedt_ras_perem }                [1] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0 and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price }           [1] = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code }           [1] = 0 and
     b1-oborot-{&bef-tdedt_overturn }                 [1] = 0 and
     b1-oborot-{&bef-tdedt_overturn }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_pri_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_spi_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_prvo }                 [2] = 0 and
     b1-oborot-{&bef-tdedt_pri_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0 and
     b1-oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0 and
     b1-oborot-{&bef-tdedt_inv}                       [2] = 0 and
     b1-oborot-{&bef-tdedt_pri_perem }                [2] = 0 and
     b1-oborot-{&bef-tdedt_ras_perem }                [2] = 0 and
     b1-oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0 and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price }           [2] = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code }           [2] = 0
      ) then   b1-null-str2# = 0    .
    end procedure.
procedure b2-null-str-pr :
 if (
     b2-oborot-{&bef-tdedt_pri_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_spi_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_pri_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0 and
     b2-oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_inv}                       [1] = 0 and
     b2-oborot-{&bef-tdedt_pri_perem }                [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_perem }                [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0 and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price }           [1] = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code }           [1] = 0 and
     b2-oborot-{&bef-tdedt_overturn }                 [2] = 0 and
     b2-ostatok-end[1]                                    = 0 and
     b2-ostatok-start[1]                                  = 0 and
     b2-oborot-{&bef-tdedt_pri_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_spi_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_pri_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0 and
     b2-oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_inv}                       [2] = 0 and
     b2-oborot-{&bef-tdedt_pri_perem }                [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_perem }                [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0 and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price }           [2] = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code }           [2] = 0 and
     b2-ostatok-end[2]                                    = 0 and
     b2-ostatok-start[2]                                  = 0
          ) then  b2-null-str# = 0    .
end procedure.


procedure b2-null-str-pr2 :
 if (
     b2-oborot-{&bef-tdedt_pri_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_spi_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_prvo }                 [1] = 0 and
     b2-oborot-{&bef-tdedt_pri_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_vp}              [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_kass}            [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh}             [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [1] = 0 and
     b2-oborot-{&bef-tdedt_spi_vnesh}                 [1] = 0 and
     b2-oborot-{&bef-tdedt_inv}                       [1] = 0 and
     b2-oborot-{&bef-tdedt_pri_perem }                [1] = 0 and
     b2-oborot-{&bef-tdedt_ras_perem }                [1] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_perem }            [1] = 0 and
     b2-oborot-{&bef-tdedt_overturn }                 [1] = 0 and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price }           [1] = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code }           [1] = 0 and
     b2-oborot-{&bef-tdedt_overturn }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_pri_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_spi_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_prvo }                 [2] = 0 and
     b2-oborot-{&bef-tdedt_pri_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_vp}              [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_vnesh_kass}            [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh}             [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_vnesh_kass}        [2] = 0 and
     b2-oborot-{&bef-tdedt_spi_vnesh}                 [2] = 0 and
     b2-oborot-{&bef-tdedt_inv}                       [2] = 0 and
     b2-oborot-{&bef-tdedt_pri_perem }                [2] = 0 and
     b2-oborot-{&bef-tdedt_ras_perem }                [2] = 0 and
     b2-oborot-{&bef-tdedt_vozvrat_perem }            [2] = 0 and
     b2-oborot-{&bef-tdedt_overturn }                 [2] = 0 and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price }           [2] = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code }           [2] = 0
     ) then   b2-null-str2# = 0    .
end procedure.


Procedure Null-str-pr :
 if (
     oborot-{&bef-TDEDT_Pri_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0 and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_Inv}                       [1] = 0 and
     oborot-{&bef-TDEDT_Pri_Perem }                [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Perem }                [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [1] = 0 and
     oborot-{&bef-TDEDT_Overturn }                 [2] = 0 and
     oborot-{&bef-TDEDT_Corr_Acc_Price}            [1] = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [1] = 0 and
     ostatok-end[1]                                    = 0 and
     ostatok-start[1]                                  = 0 and
     oborot-{&bef-TDEDT_Pri_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0 and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_Inv}                       [2] = 0 and
     oborot-{&bef-TDEDT_Pri_Perem }                [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Perem }                [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [2] = 0 and
      oborot-{&bef-TDEDT_Corr_Acc_Price}           [2] = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [2] = 0 and
     ostatok-end[2]                                    = 0 and
     ostatok-start[2]                                  = 0

      ) then   Null-str# = 0    .
END PROCEDURE.


Procedure Null-str-pr2 :
 if (
     oborot-{&bef-TDEDT_Pri_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0 and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0 and
     oborot-{&bef-TDEDT_Inv}                       [1] = 0 and
     oborot-{&bef-TDEDT_Pri_Perem }                [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Perem }                [1] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [1] = 0 and
     oborot-{&bef-TDEDT_Overturn }                 [1] = 0 and
     oborot-{&bef-TDEDT_Overturn }                 [2] = 0 and
     oborot-{&bef-TDEDT_Corr_Acc_Price}            [1] = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [1] = 0 and
     oborot-{&bef-TDEDT_Pri_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0 and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0 and
     oborot-{&bef-TDEDT_Inv}                       [2] = 0 and
     oborot-{&bef-TDEDT_Pri_Perem }                [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Perem }                [2] = 0 and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [2] = 0 and
     oborot-{&bef-TDEDT_Corr_Acc_Price}            [2] = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [2] = 0

     ) then   Null-str2# = 0    .
END PROCEDURE.


procedure ex-display :
define input parameter par-1 as int no-undo.
define input parameter par-2 like  ostatok-start[1] no-undo.
define input parameter par-i as int no-undo.
  assign num#col#  = par-1.
  if par-i = 13 then do: /*плотность*/
    run macr_excel_dec ( round (par-2 ,4)  , num#str# , num#col#   ).
  end.
  else do:
    if par-i = 1 or par-i = 11 or par-i = 12 then do : /* количества, вес, объем */
      run macr_excel_dec ( round (par-2 ,3)  , num#str# , num#col#   ).
    end.
    else do :
      run macr_excel_dec ( round (par-2 ,2)  , num#str# , num#col#   ).
    end.
  end.
end procedure.

procedure u-line:
end procedure.

procedure p-line:
end procedure.

procedure make-col :
 define variable l#1 as int  no-undo.
 define variable l#2 as int  no-undo.
 define variable l as int  no-undo.

  assign
    nk = 0
    kk = 0
  .
  if xshowcost     then do: kk = kk + 1. end.
  if xshowcostnds  then do: kk = kk + 1. end.
  if xshowcrsa     then do: kk = kk + 1. end.
  if xshowcrsands  then do: kk = kk + 1. end.
  if xshowsale     then do: kk = kk + 1. end.
  if xshowsalends  then do: kk = kk + 1. end.
  if xshowsaleslt  then do: kk = kk + 1. end.
  if xshowmediator then do: kk = kk + 1. end.
  if x-tog-wt      then do: kk = kk + 1. end.
  if x-tog-ms      then do: kk = kk + 1. end.
  if xDens         then do: kk = kk + 1. end.


 /* Шапка таблицы */
 assign
  num#str# = num#str# + 1
  num#col#  = 0
 .
 if use-column[28] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "№ "              , num#str# , num#col# ) . run macr_cell_size (10, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[1]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Код "            , num#str# , num#col# ) . run macr_cell_size (10, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[2]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Артикул"         , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[3]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Название товара" , num#str# , num#col# ) . run macr_cell_size (60, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[4]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Ед.изм "         , num#str# , num#col# ) . run macr_cell_size (7 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[5]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "т/у"             , num#str# , num#col# ) . run macr_cell_size (4 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[21] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Скидка"          , num#str# , num#col# ) . run macr_cell_size (15, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[23] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Эффективность"   , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[24] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "% наценки"       , num#str# , num#col# ) . run macr_cell_size (13, ? , num#str# , num#col# , num#str# , num#col# ). end.

    mp = num#col#  + 1.
    mp-1 = num#col#  .
 if use-column[6]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Остаток на начало "               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[7]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[8]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[9]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[10] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[11] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[12] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[13] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  списание"                 , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[14] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот касса продажа "            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[15] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот касса возврат"             , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[16] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат внешний"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[17] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат поставщику"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[18] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат перемещение"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[19] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  инвентаризация"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[20] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  переоценка"               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[22] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Остаток на конец "                , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[25] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format({&TDEDT_Corr_Acc_Price-full}       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[26] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format({&TDEDT_Chg_Purch_Code-full}       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[27] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Расход-Возврат"                   , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
    run macr_cell_size (16, ? , num#str# , mp, num#str# , (num#col#  + (kk * (num#col#  - mp)) + kk) ).

    /* Склеивание колонок */
    /*
        repeat l = 2 to (nk + (kk * (nk - mp)) + kk) :
           if  chworksheet:range (col-name[l] + string(num#str)):value = "" or
               chworksheet:range (col-name[l] + string(num#str)):value = ?
           then do:
               chworksheet:range (col-name[l] + string(num#str)):value = ? .
               chworksheet:range (col-name[l - 1] + string(num#str) + ":" + col-name[l] + string(num#str)):mergecells = true .
           end.
        end.
   */

   num#str# = num#str# + 1.
   repeat l#1 = mp to nk :
         l#2 = 0.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "количество"  , num#str# , num#col#  ) .
         if xshowcost    then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "учетн. сумма"  , num#str# , num#col#  ) .
             end.
         if xshowcostnds then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "учетн.НДС"  , num#str# , num#col#  ) .
            end.

         if xshowmediator then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "цены поср."  , num#str# , num#col#  ) .
            end.

         if xshowcrsa    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "продаж. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowcrsands then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "продаж.НДС"  , num#str# , num#col#  ) .
            end.
          if xshowsale    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowsalends then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док.НДС"  , num#str# , num#col#  ) .
            end.

         if xshowsaleslt then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док.НсП"  , num#str# , num#col#  ) .
         end.
         if x-tog-wt then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "вес"  , num#str# , num#col#  ) .
         end.
         if x-tog-ms then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "объем"  , num#str# , num#col#  ) .
         end.
         if xDens then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "плотность"  , num#str# , num#col#  ) .
         end.

     end.
         /* Склеивание колонок */
         /*
         repeat l = 1 to (nk + (kk * (nk - mp))) :
          if  chworksheet:range (col-name[l] + string(num#str)):value = ""
              or chworksheet:range (col-name[l] + string(num#str)):value = ? then do :
          chworksheet:range (col-name[l] + string(num#str)):value =  ?  .
          chworksheet:range (col-name[l] + string(num#str) + ":" + col-name[l] + string(num#str# - 1)):mergecells = true .
          end.
        end.
        */

end procedure .
procedure make-tt-ed :
/* 0 */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Inv               } temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 11. create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 12 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 12 . create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 13 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 14 .
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Corr_Acc_Price    } temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-csdt} + {&TDEDT_Chg_Purch_Code    } temp#sum-type.xi = 16 .

/* 100  crsa */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Inv               } temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 110 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 111 . create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 112 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 112 . create temp#sum-type.

assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 113 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Overturn          } temp#sum-type.xi = 114 .

create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Corr_Acc_Price    } temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-cgdt} + {&TDEDT_Chg_Purch_Code    } temp#sum-type.xi = 116 .

/* 200 sale */
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Vnesh         } temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh         } temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_RAS_Vnesh_VP      } temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass    } temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh     } temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Vnesh         } temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Inv               } temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Perem         } temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Perem         } temp#sum-type.xi = 210 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Vozvrat_Perem     } temp#sum-type.xi = 211 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Ras_Prvo          } temp#sum-type.xi = 212 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Spi_Prvo          } temp#sum-type.xi = 212 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Pri_Prvo          } temp#sum-type.xi = 213 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Overturn          } temp#sum-type.xi = 214 .
create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Corr_Acc_Price    } temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = {&arh-sadt} + {&TDEDT_Chg_Purch_Code    } temp#sum-type.xi = 216 .

end procedure.

procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >=  63000  then do:
        output stream macr_excel  close .
        /* Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  macr_excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
         /* снова шапку */
/*Печать шапки */
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
    assign
    old-s =   num#str#
    .

    run make-col .
    assign
      old-s2 =   num#str#
    .

   num#str# = old-s + 1  .
   run proc-print-header .
   num#str# = old-s2     .

    end.

 end. /* do */
end procedure. /* new-tmp-page */


{ rep/procobor.i pp {3} }
{ rep/procobor.i find-last-prise-med }
{ rep/procobor.i find-mediator }
{ rep/procobor.i ob-line-stk }

procedure calc-ms-wt :

define input        parameter p-oborot-num      as decimal   no-undo .
define input        parameter p-gds-wt-ms-base  as decimal   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .

do
on error undo, return error return-value
:
if p-is-petrol = true then return .
  assign
    p-oborot    = p-oborot-num * p-gds-wt-ms-base
    p-bi-oborot = p-bi-oborot + p-oborot
    p-bo-oborot = p-bo-oborot + p-oborot
    p-b1-oborot = p-b1-oborot + p-oborot
    p-b2-oborot = p-b2-oborot + p-oborot
  .


end.
end procedure. /* calc-ms-wt */

procedure calc-dens :

define input        parameter p-ostatok-wt       as decimal   no-undo .
define input        parameter p-ostatok          as decimal   no-undo .
define input-output parameter p-density          as decimal   no-undo .
define input-output parameter p-bi-density       as decimal   no-undo .
define input-output parameter p-bo-density       as decimal   no-undo .
define input-output parameter p-b1-density       as decimal   no-undo .
define input-output parameter p-b2-density       as decimal   no-undo .

do
on error undo, return error return-value
:

if p-is-petrol = false then return .

  assign
    p-density    = if abs(p-ostatok) < abs(p-ostatok-wt) then abs(p-ostatok / p-ostatok-wt) else 0
    p-bi-density = 0
    p-bo-density = 0
    p-b1-density = 0
    p-b2-density = 0
  .
end.
end procedure. /* calc-dens */


procedure calc-pt-ob :
define input  parameter p-ext-doc-type    as character no-undo .
define input  parameter x-store-type      as character no-undo .
define input  parameter x-store-code      as integer   no-undo .
define input  parameter p-artic           as character no-undo .
define input  parameter p-prod-type       as character no-undo .
define input  parameter p-prod-code       as integer   no-undo .
define input-output parameter p-oborot    as decimal   no-undo .
define input-output parameter p-bi-oborot as decimal   no-undo .
define input-output parameter p-bo-oborot as decimal   no-undo .
define input-output parameter p-b1-oborot as decimal   no-undo .
define input-output parameter p-b2-oborot as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot as decimal   no-undo .
define buffer buf_doc-line  for ub.doc-line  .
define buffer buf_inv-line  for ub.inv-line  .
define buffer buf1_obj-list for obj-list .
assign
  v-oborot = 0
.
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :
   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.

    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = {&fact}        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          for each buf_inv-line  no-lock where
              buf_inv-line.doc-code     = buf_doc-line.doc-code and
              buf_inv-line.artic        = buf_doc-line.artic and
              buf_inv-line.prod-type    = buf_doc-line.prod-type and
              buf_inv-line.prod-code    = buf_doc-line.prod-code
              :
              if p-ext-doc-type = {&tdedt_inv}  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                  else do:
                  if p-ext-doc-type = {&tdedt_Spi_Vnesh}    or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh}    or
                     p-ext-doc-type = {&tdedt_Ras_Perem}    or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh_VP} or
                     p-ext-doc-type = {&tdedt_Ras_Prvo}     or
                     p-ext-doc-type = {&tdedt_Spi_Prvo}     or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh_Kass}   then
                        v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                        else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .

                  end.
          end.
    end.
end.
assign
  p-oborot    = v-oborot
  p-bi-oborot = p-bi-oborot + v-oborot
  p-bo-oborot = p-bo-oborot + v-oborot
  p-b1-oborot = p-b1-oborot + v-oborot
  p-b2-oborot = p-b2-oborot + v-oborot
.

end.
end procedure. /* calc-pt-ob */

procedure calc-density :
define input        parameter p-ext-doc-type  as character no-undo .
define input        parameter x-store-type    as character no-undo .
define input        parameter x-store-code    as integer   no-undo .
define input        parameter p-artic         as character no-undo .
define input        parameter p-prod-type     as character no-undo .
define input        parameter p-prod-code     as integer   no-undo .
define input-output parameter p-density       as decimal   no-undo .
define input-output parameter p-bi-density    as decimal   no-undo .
define input-output parameter p-bo-density    as decimal   no-undo .
define input-output parameter p-b1-density    as decimal   no-undo .
define input-output parameter p-b2-density    as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot    as decimal   no-undo .
define variable v-fact-qnty as decimal   no-undo .
define buffer buf_doc-line  for ub.doc-line  .
define buffer buf_inv-line  for ub.inv-line  .
define buffer buf1_obj-list for obj-list .
assign
  v-oborot     = 0
  v-fact-qnty  = 0
.
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :
   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.

    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = {&fact}        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          assign v-fact-qnty = v-fact-qnty + buf_doc-line.fact-qnty.
          for each buf_inv-line  no-lock where
              buf_inv-line.doc-code     = buf_doc-line.doc-code and
              buf_inv-line.artic        = buf_doc-line.artic and
              buf_inv-line.prod-type    = buf_doc-line.prod-type and
              buf_inv-line.prod-code    = buf_doc-line.prod-code
              :
              if p-ext-doc-type = {&tdedt_inv}  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                  else do:
                  if p-ext-doc-type = {&tdedt_Spi_Vnesh}    or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh}    or
                     p-ext-doc-type = {&tdedt_Ras_Perem}    or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh_VP} or
                     p-ext-doc-type = {&tdedt_Ras_Prvo}     or
                     p-ext-doc-type = {&tdedt_Spi_Prvo}     or
                     p-ext-doc-type = {&tdedt_Ras_Vnesh_Kass}   then
                        v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                        else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .

                  end.
          end.
    end.

    assign
      p-density    = if ( v-fact-qnty <> 0 and ABS(v-oborot) < ABS(v-fact-qnty)) then ABS(v-oborot / v-fact-qnty) else 0
    .
    assign
      p-bi-density = p-density
      p-bo-density = 0
      p-b1-density = 0
      p-b2-density = 0
    .

end.
end.
end procedure. /* calc-density */


/* $workfile: xloborot.i $ e n d */