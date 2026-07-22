block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cnsgds.p $
$Archive: cus/r-cnsgds.p $

Совокупная заявка по товарам EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 04/18/02
Author: Svetlana Chernova
Creation date: 04/18/02

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter c-rc as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cnsgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cnsgds.p $":U .
define variable vss-description as character no-undo init " Совокупная заявка по товарам EXCEL   ".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new  }
{ gbl/cur-time.i    }
{ rep/repfrm.i def  }
{ rep/f-fdec.i      }


define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).


define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define buffer bf_ord-cons       for ub.ord-cons .
define buffer bf_ord-cons-gds   for ub.ord-gds-cons .
define buffer bf_ord-doc        for ub.ord-doc .
define buffer loc_ord-doc       for ub.ord-doc.
define buffer loc_ord-line      for ub.ord-line.
define buffer b-goods           for ub.goods.
define buffer b_clients         for ub.clients.
define buffer loc_ord-doc-rcv   for ub.ord-doc-rcv.
define buffer loc_ord-line-rcv  for ub.ord-line-rcv.
define buffer z_ord-doc         for ub.ord-doc.
define buffer z_ord-line        for ub.ord-line.

define variable l-ord-code as character no-undo .
define variable l-rcv-code as character no-undo .
define variable  l-max  like ub.place.max-qnty no-undo .
define variable  l-ost  like ub.place.max-qnty no-undo .
define variable  l-free like ub.place.max-qnty no-undo .
define variable  l-temp-sale like ub.place.max-qnty no-undo .

define variable l-qnty-of   like ub.place.max-qnty no-undo .
define variable l-time-of   as integer no-undo .
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
define variable last-line as logical no-undo .

define variable  s-max-qnty   as decimal no-undo .
define variable  s-brutto-qnty  as decimal no-undo .
define variable  s-free-qnty    as decimal no-undo .
define variable  s-qnty-of      as decimal no-undo .
define variable  s-qnty-fp      as decimal no-undo .
define variable  s-qnty-rcv     as decimal no-undo .

define temp-table temp-tt no-undo
field obj-type    like ub.clients.obj-type
field obj-name    like ub.clients.obj-name

field gds-code    like ub.goods.gds-code
field max-qnty    like ub.place.max-qnty                 /*Общий объем складских мест"                  */
field brutto-qnty like ub.rvs-line.state-brutto-qnty  /*Фактический остаток по складским местам"     */
field free-qnty   like ub.rvs-line.state-brutto-qnty  /*Свободный объем складских мест"              */
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

{ rep/repfrm.i on 50 }

  os-delete value( string( session:temp-directory ) +
                               {&DF_Name} + string( g#report-num ) + ".txt":U ) .
  os-delete value( string( session:temp-directory ) +
                               {&DF_Name} + string( g#report-num ) + ".frm":U ) .
  output stream forexcel to value( string( session:temp-directory ) +
                               {&DF_Name} + string( g#report-num ) + ".txt":U ) .
Make-Excel = true .

/* ШАПКА */
find first  bf_ord-cons where recid(bf_ord-cons) = c-rc no-lock no-error .
Reportname   =  "Совокупная заявка по товарам по фирме № " + bf_ord-cons.cons-code + " от " + string(bf_ord-cons.doc-date,"99/99/9999").
Reportheader =   cur-time-print() .
     Sheetf.Sizes = "16,30," .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .
     Sheetf.Sizes = Sheetf.Sizes + ("8,")  .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .
     Sheetf.Sizes = Sheetf.Sizes + ("8,")  .
     Sheetf.Sizes = Sheetf.Sizes + ("20,") .
     Sheetf.Sizes = Sheetf.Sizes + ("8,")  .
     Sheetf.Sizes = Sheetf.Sizes + ("12,") .

     Sheetf.Excel-Column-Lable =  "Артикл ,Наименование товара"
    + ",Заявленное количество"
    + ",Предполагаемое время завоза"
    + ",Заказанное у поставщика кол-во в целом от фирмы "
    + ",Код поставщика"
    + ",Наименование поставщика "
    + ",Согласованное время завоза (поставок)"
    + ",Количество в поставке"
      .
sheetf.make-correct =  "" .

run rep/extitle.p (1) .
run make-tt .

/* по объектам заявок */
for each  bf_ord-doc no-lock  where bf_ord-doc.cons-code = bf_ord-cons.cons-code,
     first ub.clients  where ub.clients.obj-code =  bf_ord-doc.obj-code
                     and  ub.clients.obj-type =  bf_ord-doc.obj-type no-lock
                     break by ub.clients.obj-type by ub.clients.obj-code:


     if first-of(ub.clients.obj-code) then do:
       old-l-ord-code = "".
            {&PutExcel}
              format-excel-text(ub.clients.obj-type + " " + string(ub.clients.obj-code))  {&tabulation}
              format-excel-text(ub.clients.obj-name) {&new-line}
            .

         {&for-each-gds-cons}
            last-line = false .
            for each   temp-tt where temp-tt.obj-type = ub.clients.obj-type + " " + string(ub.clients.obj-code) and
                                    temp-tt.gds-code = ub.goods.gds-code break by temp-tt.gds-code:
                    if first (temp-tt.gds-code) then do:
                        {&PutExcel} ub.goods.artic {&tabulation}
                                    ub.goods.gds-name {&tabulation}
                                    .
                    end.
                    else do:
                    last-line = true  .
                    {&PutExcel}
                      {&tabulation}
                      {&tabulation}
                      .
                      end.
                     {&PutExcel}
                      excel-qnty-null(temp-tt.qnty-of  )   {&tabulation}
                      format-excel-text(temp-tt.time-of)   {&tabulation}
                      excel-qnty-null (temp-tt.qnty-fp  )  {&tabulation}
                      format-excel-text(temp-tt.cli-cod)   {&tabulation}
                      format-excel-text(temp-tt.cli-name)  {&tabulation}
                      format-excel-text(temp-tt.time-rcv)  {&tabulation}
                      excel-qnty-null(temp-tt.qnty-rcv)    {&new-line}
                    .

                    if last (temp-tt.gds-code) and last-line = true  then do:

                      run sub-gds.
                      end.

                    end.
         end.  /* проход по всем товарам */
     end.
     if last-of(ub.clients.obj-code) then do:
        run sub-itog.
     end.
end.
/*-----------------------------------------------------------------------------------------------------------------------*/
{&PutExcel}  "ИТОГО"    {&tabulation}
                        {&tabulation}
                        .
          assign
              s-max-qnty    = 0
              s-brutto-qnty = 0
              s-free-qnty   = 0
              s-qnty-of     = 0
              s-qnty-fp     = 0
              s-qnty-rcv    = 0
              .

            for each   temp-tt  :
            assign
              s-max-qnty    = s-max-qnty    + temp-tt.max-qnty
              s-brutto-qnty = s-brutto-qnty + temp-tt.brutto-qnty
              s-free-qnty   = s-free-qnty   + temp-tt.free-qnty
              s-qnty-of     = s-qnty-of     + temp-tt.qnty-of
              s-qnty-fp     = s-qnty-fp     + temp-tt.qnty-fp
              s-qnty-rcv    = s-qnty-rcv    + temp-tt.qnty-rcv
              .
            end.

            {&PutExcel}
                s-qnty-of     {&tabulation}
                              {&tabulation}
           /* s-qnty-fp*/     {&tabulation}
                              {&tabulation}
                              {&tabulation}
                              {&tabulation}
                s-qnty-rcv    {&new-line}
              .

 {&PutExcel}  {&new-line}.

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
            if first-of ( loc_ord-doc.doc-code ) then do:
            l-cli-code  =  b_clients.obj-type + " "  + string( b_clients.obj-code).
            l-cli-name  =  b_clients.obj-name.
            l-ord-code  = loc_ord-line.doc-code.

            /* Поставка ----------------------------------------------------------------------*/
                tt-line = false  .
                for each loc_ord-doc-rcv no-lock  where loc_ord-doc-rcv.cons-code =  bf_ord-cons.cons-code
                                                  and loc_ord-doc-rcv.doc-code   = loc_ord-line.doc-code
                                                  and ub.clients.obj-code = loc_ord-doc-rcv.obj-code
                                                  and ub.clients.obj-type = loc_ord-doc-rcv.obj-type
                                                  ,
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
    run calc-var(input ub.clients.obj-type,
                 input ub.clients.obj-code,
                 input ub.goods.gds-code,
                 output l-max,
                 output l-ost,
                 output l-temp-sale).
      assign
          temp-tt.max-qnty    = l-max     /*place.max-qnty  */            /*Общий объем складских мест"              */
          temp-tt.brutto-qnty = l-ost     /*rvs-line.state-brutto-qnty */ /*Фактический остаток по складским местам" */
          temp-tt.free-qnty   = temp-tt.max-qnty  - temp-tt.brutto-qnty   /*Свободный объем складских мест"          */
          temp-tt.temp-sale   = l-temp-sale                               /*Темп продаж на объекте"                 */
          temp-tt.qnty-of     = l-qnty-of                                 /*Заявленное количество"*/
          temp-tt.time-of     = (if l-time-of  = 0 then " " else string(l-time-of,"HH:MM"))
          .
       end.
 else
      assign
          temp-tt.max-qnty    = 0
          temp-tt.brutto-qnty = 0
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
      if avail rvs-line then
         m-ost = m-ost +  ub.rvs-line.state-brutto-qnty.
end.
end procedure .


procedure sub-itog :
define variable m-max-qnty    like  l-max         no-undo .
define variable m-brutto-qnty like  l-ost         no-undo .
define variable m-free-qnty   like  l-free        no-undo .
define variable m-qnty-of     like  l-qnty-of     no-undo .
define variable m-qnty-fp     like  l-qnty-fp     no-undo .
define variable m-qnty-rcv    like  l-qnty-rcv    no-undo .
define buffer temp-ll for temp-tt.
{&PutExcel}  "Итого по объекту"    {&tabulation}
             ub.clients.obj-name      {&tabulation}
                        .
          assign
              m-max-qnty    = 0
              m-brutto-qnty = 0
              m-free-qnty   = 0
              m-qnty-of     = 0
              m-qnty-fp     = 0
              m-qnty-rcv    = 0
              .

            for each   temp-ll where temp-ll.obj-type = ub.clients.obj-type + " " + string(ub.clients.obj-code) :
            assign
              m-max-qnty    = m-max-qnty    + temp-ll.max-qnty
              m-brutto-qnty = m-brutto-qnty + temp-ll.brutto-qnty
              m-free-qnty   = m-free-qnty   + temp-ll.free-qnty
              m-qnty-of     = m-qnty-of     + temp-ll.qnty-of
              m-qnty-fp     = m-qnty-fp     + temp-ll.qnty-fp
              m-qnty-rcv    = m-qnty-rcv    + temp-ll.qnty-rcv
              .
            end.

            {&PutExcel}
                m-qnty-of     {&tabulation}
                              {&tabulation}
                m-qnty-fp     {&tabulation}
                              {&tabulation}
                              {&tabulation}
                              {&tabulation}
                m-qnty-rcv    {&new-line}
              .

end procedure.


procedure sub-gds :
define variable m-max-qnty    like  l-max         no-undo .
define variable m-brutto-qnty like  l-ost         no-undo .
define variable m-free-qnty   like  l-free        no-undo .
define variable m-qnty-of     like  l-qnty-of     no-undo .
define variable m-qnty-fp     like  l-qnty-fp     no-undo .
define variable m-qnty-rcv    like  l-qnty-rcv    no-undo .
define buffer temp-ll for temp-tt.
{&PutExcel}                                     {&tabulation}
             "Итого по :" + ub.goods.gds-name      {&tabulation}
                        .
          assign
              m-max-qnty    = 0
              m-brutto-qnty = 0
              m-free-qnty   = 0
              m-qnty-of     = 0
              m-qnty-fp     = 0
              m-qnty-rcv    = 0
              .

            for each   temp-ll where temp-ll.obj-type = ub.clients.obj-type + " " + string(ub.clients.obj-code)
                                 and temp-ll.gds-code = ub.goods.gds-code :
            assign
              m-max-qnty    = m-max-qnty    + temp-ll.max-qnty
              m-brutto-qnty = m-brutto-qnty + temp-ll.brutto-qnty
              m-free-qnty   = m-free-qnty   + temp-ll.free-qnty
              m-qnty-of     = m-qnty-of     + temp-ll.qnty-of
              m-qnty-fp     = m-qnty-fp     + temp-ll.qnty-fp
              m-qnty-rcv    = m-qnty-rcv    + temp-ll.qnty-rcv
              .
            end.

            {&PutExcel}
                m-qnty-of     {&tabulation}
                              {&tabulation}
                m-qnty-fp     {&tabulation}
                              {&tabulation}
                              {&tabulation}
                              {&tabulation}
                m-qnty-rcv    {&new-line}
              .

end procedure.

/* $Workfile: r-cnsgds.p $ e n d */