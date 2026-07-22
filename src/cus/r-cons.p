block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cons.p $
$Archive: cus/r-cons.p $

Совокупная заявка по бензину EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 09/13/05
Author: Svetlana Chernova
Creation date: 09/13/05

04/17/02 1:07

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter c-rc as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cons.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cons.p $":U .
define variable vss-description as character no-undo init " Совокупная заявка по бензину EXCEL   ".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i new }
{ cmp/r-pril.i NEW  }
{ gbl/cur-time.i    }
{ rep/repfrm.i def  }
{ rep/f-fdec.i }
{ gbl/getcntxt.i def }


define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
{ gbl/getcntxt.i get }

define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define buffer bf_ord-cons for ub.ord-cons .
define buffer bf_ord-cons-gds for ub.ord-gds-cons .
define buffer bf_ord-doc for ub.ord-doc .
define buffer loc_ord-doc for ub.ord-doc.
define buffer loc_ord-line for ub.ord-line.
define buffer b-goods for ub.goods.
define buffer b_clients for ub.clients.
define buffer loc_ord-doc-rcv for ub.ord-doc-rcv.
define buffer loc_ord-line-rcv for ub.ord-line-rcv.
define buffer z_ord-doc for ub.ord-doc.
define buffer z_ord-line for ub.ord-line.

define variable l-ord-code as character no-undo .
define variable l-rcv-code as character no-undo .
define variable  l-max  like ub.place.max-qnty no-undo .
define variable  l-ost  like ub.place.max-qnty no-undo .
define variable  l-free like ub.place.max-qnty no-undo .
define variable  l-temp-sale like ub.place.max-qnty no-undo .

define variable l-qnty-of   like ub.place.max-qnty no-undo .
define variable l-time-of   as integer no-undo .
define variable g-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-fp   like ub.place.max-qnty no-undo .
define variable l-qnty-rcv  like ub.place.max-qnty no-undo .
define variable l-time-fp   as integer no-undo .
define variable l-time-rcv  as integer no-undo .
define variable l-cli-code  as character no-undo .
define variable l-cli-name  as character no-undo .
define variable ii      as integer no-undo .
define variable l-nn    as integer no-undo .
define variable kk      as integer no-undo .
define variable max-str as integer no-undo .
define variable old-l-ord-code as character no-undo .

define variable  s-max-qnty   as decimal no-undo .
define variable  s-measure-qnty  as decimal no-undo .
define variable  s-free-qnty    as decimal no-undo .
define variable  s-qnty-of      as decimal no-undo .
define variable  s-qnty-fp      as decimal no-undo .
define variable  s-qnty-rcv     as decimal no-undo .

define temp-table temp-tt no-undo
field obj-type    like ub.clients.obj-type
field obj-name    like ub.clients.obj-name

field gds-code    like ub.goods.gds-code
field max-qnty    like ub.place.max-qnty                 /*Общий объем складских мест"                  */
field measure-qnty like ub.rvs-line.state-measure-qnty  /*Фактический остаток по складским местам"     */
field free-qnty   like ub.rvs-line.state-measure-qnty  /*Свободный объем складских мест"              */
field temp-sale   as decimal                          /*Темп продаж на объекте"                      */
field qnty-of     like ub.ord-line.qnty               /*Заявленное количество"                       */
field time-of     as char                          /*Предполагаемое время завоза"                 */

field ord-code    as character                      /*ЗАКАЗЫ                                       */
field qnty-fp     like ub.ord-line.qnty             /*Заказанное у поставщика кол-во"              */
field cli-cod     as character                      /*Код поставщика"                              */
field cli-name    as character                      /*Наименование поставщика "                    */

field rcv-code    as character                      /*ПОСТАВКА                                     */
field time-rcv    as char                           /*Согласованное время завоза (поставок)"       */
field qnty-rcv    like ub.ord-line.qnty             /*Количество в поставке"                       */
field nnn as integer                                /*Количество в поставке"                       */
INDEX pi IS UNIQUE PRIMARY
  obj-type
  nnn
  gds-code
  ord-code
  rcv-code
      .



&scop for-each-gds-cons for each ~
 bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,~
    first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic                         ~
                      and bf_ord-cons-gds.prod-type = ub.goods.prod-type             ~
                      and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :

FUNCTION excel-qnty-null RETURNS char (INPUT p-dec as decimal ).
if p-dec = 0 then Return ("").
   else RETURN(format-excel-text(excel-format-dec-to-char(Round(p-dec,3)))) .
END FUNCTION.



main-block :
do on error undo main-block, return error
:

find first  bf_ord-cons where recid(bf_ord-cons) = c-rc no-lock no-error .
for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code :
 ii = ii + 1.
 if ii > 23 then leave.
end.

if ii > 23 then do:
    message "Отчет не может быть выполнен на такое количество товаров !  "
    skip
    "Воспользуйтесь отчетом 'Совокупная заявка по товарам ' "
    view-as alert-box error.
    return error.
end.

{ rep/repfrm.i on 50 }

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

  os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( g#report-num ) + ".txt":U ) .
  os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( g#report-num ) + ".frm":U ) .
  output stream forexcel to value( string( session:temp-directory ) +
                              {&df_name} + string( g#report-num ) + ".txt":u ) .
Make-Excel = true .

/*ШАПКА*/
reportname =  "Совокупная заявка по нефтепродуктам по фирме № " + bf_ord-cons.cons-code + " от " + string(bf_ord-cons.doc-date,"99/99/9999").
reportheader =   cur-time-print() .
Sheetf.Excel-Column-Lable = "Код объекта ,Наименование объекта  ,".
Sheetf.Sizes = "8,20,".

/*Первая строка*/
{&for-each-gds-cons}
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable + " Арт " + ub.goods.artic + "," + string(ub.goods.gds-name) + ",,,,,,,,,," .
     Sheetf.Sizes = Sheetf.Sizes + Fill("12,", 5) .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .
     Sheetf.Sizes = Sheetf.Sizes + ("8,") .
     Sheetf.Sizes = Sheetf.Sizes + ("20,") .
     Sheetf.Sizes = Sheetf.Sizes + ("8,") .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .
End.

     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable  + {&new-line} +  ",".


/*Вторая строка*/
{&for-each-gds-cons}
     Sheetf.Excel-Column-Lable = Sheetf.Excel-Column-Lable +
      ",Общий объем складских мест"
    + ",Фактический остаток по складским местам"
    + ",Свободный объем складских мест"
    + ",Заявленное количество"
    + ",Предполагаемое время завоза"
    + ",Заказанное у поставщика кол-во от фирмы в целом"
    + ",Код поставщика"
    + ",Наименование поставщика "
    + ",Согласованное время завоза (поставок)"
    + ",Количество в поставке"
    + ",№ поставки"
      .
End.
sheetf.make-correct =  "".
run rep/extitle.p (1) .
run make-tt .

/* по объектам заявок */
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code,
     first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                     and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                     break by ub.clients.obj-type by ub.clients.obj-code:

     if last-of(ub.clients.obj-code) then do:
       old-l-ord-code = "".
       run max-col (input ub.clients.obj-code, input  ub.clients.obj-type ,output  max-str) .
       do kk = 1 to max-str :
            if kk = 1 then do:
            {&PutExcel}
              format-excel-text(ub.clients.obj-type + " " + string(ub.clients.obj-code))  {&tabulation}
              format-excel-text(ub.clients.obj-name) {&tabulation}
            .
            end.
            else do:
            {&PutExcel}
               {&tabulation}
               {&tabulation}
            .
            end.

         {&for-each-gds-cons}
            find first   temp-tt where temp-tt.obj-type = ub.clients.obj-type + " " + string(ub.clients.obj-code) and
                                    temp-tt.gds-code = ub.goods.gds-code and
                                    temp-tt.nnn = kk no-error .
                    if avail temp-tt then do:
                    {&PutExcel}
                      excel-qnty-null(temp-tt.max-qnty)    {&tabulation}
                      excel-qnty-null(temp-tt.measure-qnty) {&tabulation}
                      excel-qnty-null(temp-tt.free-qnty)   {&tabulation}
                      excel-qnty-null(temp-tt.qnty-of  )   {&tabulation}
                      format-excel-text(temp-tt.time-of)   {&tabulation}
                      excel-qnty-null (temp-tt.qnty-fp  )  {&tabulation}
                      format-excel-text(temp-tt.cli-cod)   {&tabulation}
                      format-excel-text(temp-tt.cli-name)  {&tabulation}
                      format-excel-text(temp-tt.time-rcv)  {&tabulation}
                      excel-qnty-null(temp-tt.qnty-rcv)    {&tabulation}
                      format-excel-text(temp-tt.rcv-code)    {&tabulation}
                    .
                    end.
                    else do:
                      {&PutExcel}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                      .
                    end.
         end.  /* проход по всем товарам */
         {&PutExcel} {&new-line} . /* конец строки */
       end.
     end.
end.
/*-----------------------------------------------------------------------------------------------------------------------*/
{&PutExcel}  "Итого"    {&tabulation}
                        {&tabulation}
                        .
         {&for-each-gds-cons}
          assign
              s-max-qnty    = 0
              s-measure-qnty = 0
              s-free-qnty   = 0
              s-qnty-of     = 0
              s-qnty-fp     = 0
              s-qnty-rcv    = 0
              .
            for each   temp-tt where temp-tt.gds-code = ub.goods.gds-code :
            assign
              s-max-qnty    = s-max-qnty    + temp-tt.max-qnty
              s-measure-qnty = s-measure-qnty + temp-tt.measure-qnty
              s-free-qnty   = s-free-qnty   + temp-tt.free-qnty
              s-qnty-of     = s-qnty-of     + temp-tt.qnty-of
              s-qnty-fp     = g-qnty-fp
              s-qnty-rcv    = s-qnty-rcv    + temp-tt.qnty-rcv
              .
            end.

            {&PutExcel}
                s-max-qnty    {&tabulation}
                s-measure-qnty {&tabulation}
                s-free-qnty   {&tabulation}
                s-qnty-of     {&tabulation}
                              {&tabulation}
                s-qnty-fp     {&tabulation}
                              {&tabulation}
                              {&tabulation}
                              {&tabulation}
                s-qnty-rcv    {&tabulation}
                              {&tabulation}
              .

         end.  /* проход по всем товарам */

 {&PutExcel} {&new-line} {&new-line}. /* конец строки */

run cur-time in this-procedure ( output v-today, output v-time ).
  {&PutExcel} " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.
  {&CloseExcel}
  { rep/repfrm.i off}
  run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
 end.  /* main */



procedure make-tt :
define variable tt-line  as logical no-undo .
define variable ttt-line as logical no-undo .


for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code
                                and bf_ord-doc.doc-type = {&o-f}  ,
  first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                  and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                  break by ub.clients.obj-type by ub.clients.obj-code:
  if first-of(ub.clients.obj-code) then do:
     ii = 0 .
      /* товары ------------------------------------------------------------------------------------------------*/
    for each  bf_ord-cons-gds no-lock  where bf_ord-cons-gds.cons-code = bf_ord-cons.cons-code,
      first ub.goods where bf_ord-cons-gds.artic = ub.goods.artic
            and bf_ord-cons-gds.prod-type = ub.goods.prod-type
            and bf_ord-cons-gds.prod-code = ub.goods.prod-code no-lock :
            assign
              l-nn = 0
              l-qnty-of = 0
              l-time-of = 0
            .
       /* заявки -------------------------------------------------------------------------------------*/
        for each  z_ord-doc no-lock  where z_ord-doc.cons-code = bf_ord-cons.cons-code
                                            and z_ord-doc.doc-type = {&o-f}
                                            and ub.clients.obj-code =  z_ord-doc.obj-code
                                            and ub.clients.obj-type =  z_ord-doc.obj-type
                                           ,
                each z_ord-line no-lock where z_ord-doc.doc-code   = z_ord-line.doc-code and
                                                z_ord-line.artic     = bf_ord-cons-gds.artic      and
                                                z_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                                z_ord-line.prod-code = bf_ord-cons-gds.prod-code :
                  l-qnty-of = l-qnty-of + z_ord-line.qnty.
                  l-time-of =  z_ord-doc.ship-time.
        end.
        /* заказ ---------------------------------------------------------------------------------------*/
        assign
        l-cli-code  = ""
        l-cli-name  = ""
        l-ord-code  = ""
        ttt-line = false
        l-qnty-fp = 0
        g-qnty-fp = 0
        .
        for each loc_ord-doc no-lock  where loc_ord-doc.cons-code =  bf_ord-cons.cons-code
                                        and loc_ord-doc.doc-type = {&f-p}
                                  ,
        first b_clients  where b_clients.obj-code =  loc_ord-doc.cli-code
                          and  b_clients.obj-type =  loc_ord-doc.cli-type no-lock ,
        each loc_ord-line no-lock where loc_ord-doc.doc-code   = loc_ord-line.doc-code and
                                        loc_ord-line.artic     = bf_ord-cons-gds.artic      and
                                        loc_ord-line.prod-type = bf_ord-cons-gds.prod-type  and
                                        loc_ord-line.prod-code = bf_ord-cons-gds.prod-code
                      break by  loc_ord-doc.doc-code   :

            l-qnty-fp = l-qnty-fp + loc_ord-line.qnty.
            g-qnty-fp = g-qnty-fp + loc_ord-line.qnty.
            if first-of ( loc_ord-doc.doc-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-ord-code  = loc_ord-line.doc-code.

            /* Поставка ----------------------------------------------------------------------*/
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                    and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                    and loc_ord-doc-rcv.obj-code   = ub.clients.obj-code
                                                    and loc_ord-doc-rcv.obj-type   = ub.clients.obj-type   ,

                      each loc_ord-line-rcv no-lock where loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code and
                            loc_ord-doc-rcv.rcv-code   = loc_ord-line-rcv.rcv-code and
                            loc_ord-line-rcv.artic     = bf_ord-cons-gds.artic      and
                            loc_ord-line-rcv.prod-type = bf_ord-cons-gds.prod-type  and
                            loc_ord-line-rcv.prod-code = bf_ord-cons-gds.prod-code  :

                            l-rcv-code  = loc_ord-line-rcv.rcv-code.
                            l-time-rcv  = loc_ord-doc-rcv.ship-time.
                            l-qnty-rcv =  loc_ord-line-rcv.qnty.
                        run create-tt-line.
                        assign
                          tt-line = true
                          l-rcv-code = ""
                          l-time-rcv = 0
                          l-qnty-rcv = 0
                        .

                end.
              if tt-line = false then run create-tt-line.
            end.  /*1 заказа*/
          ttt-line = true .
          if last-of ( loc_ord-doc.doc-code ) then l-qnty-fp = 0.
        end. /* заказы */
          if ttt-line = false then  run create-tt-line.
    end. /* товары */
  end.  /* объекты */
end.   /*заявки */
end procedure .

procedure create-tt-line :
ii = ii + 1.
{ rep/repfrm.i disp ii  reportname ub.clients.obj-name ub.goods.gds-name}
 l-nn = l-nn + 1 .

create temp-tt .
assign
 temp-tt.nnn         = l-nn         /* N строки */
 temp-tt.obj-type    = ub.clients.obj-type + " " + string(ub.clients.obj-code)
 temp-tt.obj-name    = ub.clients.obj-name
 temp-tt.gds-code    = ub.goods.gds-code
 .
 If l-nn = 1 then Do:
    run calc-var in this-procedure (input ub.clients.obj-type,
                 input ub.clients.obj-code,
                 input ub.goods.gds-code,
                 output l-max,
                 output l-ost,
                 output l-temp-sale).
      assign
          temp-tt.max-qnty    = l-max     /*place.max-qnty  */            /*Общий объем складских мест"              */
          temp-tt.measure-qnty = l-ost     /*rvs-line.state-measure-qnty */ /*Фактический остаток по складским местам" */
          temp-tt.free-qnty   = temp-tt.max-qnty  - temp-tt.measure-qnty   /*Свободный объем складских мест"          */
          temp-tt.temp-sale   = l-temp-sale                               /*Темп продаж на объекте"                 */
          temp-tt.qnty-of     = l-qnty-of                                 /*Заявленное количество"*/
          temp-tt.time-of     = (if l-time-of  = 0 then " " else string(l-time-of,"HH:MM"))
          .
       end.
 else
      assign
          temp-tt.max-qnty    = 0
          temp-tt.measure-qnty = 0
          temp-tt.free-qnty   = 0
          temp-tt.temp-sale   = 0
          temp-tt.qnty-of     = 0
          temp-tt.time-of     = " "
          .
 if old-l-ord-code <> l-ord-code then do:
    assign
        temp-tt.qnty-fp     = l-qnty-fp        /* Заказанное у поставщика кол-во"              */
        temp-tt.cli-cod     = l-cli-code
        temp-tt.cli-name    = l-cli-name       /* Наименование поставщика "                    */
        .
 end.
 else do:
    assign
        temp-tt.qnty-fp     = 0
        temp-tt.cli-cod     = ""
        temp-tt.cli-name    = ""
        .
 end.

 assign
    temp-tt.ord-code    = l-ord-code       /* ЗАКАЗЫ                                       */
    old-l-ord-code      = l-ord-code
    temp-tt.rcv-code    = l-rcv-code       /* ПОСТАВКА                                     */
    temp-tt.time-rcv    = (if l-time-rcv  = 0 then  " " else string(l-time-rcv,"HH:MM"))
    temp-tt.qnty-rcv    = l-qnty-rcv       /* Количество в поставке"                       */
.

end procedure .


procedure max-col :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define output parameter p-max as integer no-undo .
     p-max = 0 .
     for each temp-tt where temp-tt.obj-type = p-obj-type  + " " + string(p-obj-code)
       break by temp-tt.nnn DESCENDING :
       p-max = temp-tt.nnn.
       leave.
     end.
end procedure .


procedure calc-var :
define input  parameter  m-type   like ub.clients.obj-type   no-undo .
define input  parameter  m-code   like ub.clients.obj-code   no-undo .
define input  parameter  m-gds-code  like ub.goods.gds-code  no-undo .
define output parameter  m-max       like l-max           no-undo .
define output parameter  m-ost       like l-ost           no-undo .
define output parameter  m-temp-sale like l-temp-sale     no-undo .
for each ub.place no-lock where
      ub.place.obj-code =  m-code and
      ub.place.obj-type =  m-type ,
      first ub.pl-gds no-lock where
            ub.pl-gds.gds-code = m-gds-code and
            ub.pl-gds.obj-code = ub.place.obj-code          and
            ub.pl-gds.obj-type = ub.place.obj-type          and
            ub.pl-gds.pl-code  = ub.place.pl-code          :

      m-max = m-max + ub.place.max-qnty.
      find last ub.rvs-line no-lock where
      ub.rvs-line.gds-code = ub.pl-gds.gds-code  and
      ub.rvs-line.obj-code = ub.pl-gds.obj-code  and
      ub.rvs-line.obj-type = ub.pl-gds.obj-type  and
      ub.rvs-line.pl-code  = ub.pl-gds.pl-code
      use-index gds-pl-code no-error .
      if avail ub.rvs-line then
         m-ost = m-ost +  ub.rvs-line.state-measure-qnty.
end.






end procedure .


/* $Workfile: r-cons.p $ e n d */