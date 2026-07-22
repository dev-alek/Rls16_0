/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запасы по признакам

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Запасы по признакам".
{ cmp/vssrevis.i }
/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter itog as logical no-undo .
define input parameter p-cost as logical no-undo .
define input parameter p-sale as logical no-undo .
define input parameter p-dis as logical no-undo .

define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .

define temp-table temp-goods no-undo
  field gds-code like ub.goods.gds-code
  field b-code   like ub.goods.gds-code
  field artic    like ub.goods.artic
  field cli      like ub.clients.obj-name
  field grp-name like ub.goods.grp-name
  field vat-pc   like ub.doc-line.vat-pc

  field prod-code like ub.goods.prod-code
  field prod-type like ub.goods.prod-type
  field prt-root  like ub.goods.prt-root
  field gds-name  like ub.goods.gds-name

.

/*поля формы*/
define  variable     f-fact-date      as char no-undo.

define variable  fact-order-1 like ub.stk-tot.fact-order no-undo.
define variable  quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.

define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.

define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.

define variable  fact-order-2 like ub.stk-tot.fact-order no-undo.
define variable  quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2       like ub.stk-tot.sum-rubl   no-undo.

define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.

define variable  quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast6       like ub.stk-tot.sum-rubl   no-undo.

define variable  coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str no-undo.
define variable  tprintrubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xtog-obj as logical no-undo init true .

define  stream  outstream .

define    variable    objname           as char no-undo.
define    variable    paytype           as   integer no-undo.
define    variable    valtype           as   integer no-undo.
define    variable    line              as  char     no-undo.


define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define    variable    ii        as   integer no-undo.
define    variable    i         as   integer no-undo .
define    variable    j         as   integer no-undo.
define    variable    k         as   integer no-undo.
/* local variable definitions ---                                       */

define variable stat     as log no-undo .
define variable inperror as log no-undo .

define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.

define variable listtd as char no-undo.
define variable no-prise as logical no-undo  init true .
define variable discnt-base# as decimal init 0  no-undo .
define variable n-nn as integer init 0 no-undo .
define variable n-nm as integer init 0 no-undo .
define variable n-no as integer init 0 no-undo .
define variable var-client as character no-undo .
define variable  prtroot        like ub.gds-prt.node-code no-undo.


define variable    nn              as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-b-code        as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-prt-name      as character no-undo .




define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-prt-name    as character no-undo .

define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-prt-name      as character no-undo .


 { cus/r-z-alld.i }
define work-table temp-gds-prt no-undo
field v-p-qnty       like p-qnty
field v-p-cost-sum   like p-cost-sum
field v-p-sale-sum   like p-sale-sum
field v-p-sale-other like p-sale-other
field obj-code like ub.goods.prod-code
field obj-type like ub.goods.prod-type
.
define variable pp as  integer no-undo .
define variable x-time as integer no-undo .
define variable fix-doc-code  like ub.ot-tot.doc-code no-undo .

/* ************** frame для формы **************** */
&scop l-frame 300
&scop l-frame-1 198


{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
x-date-end     = to-day.
x-date-start   = x-date-alone.
x-time = time .
find last ub.ot-tot  no-lock use-index pi .
if avail  ub.ot-tot then fix-doc-code = ub.ot-tot.doc-code.
                 else fix-doc-code = "".
/*===================================================================================================================*/
   find first ub.clients where x-store-type = ub.clients.obj-type and
            x-store-code = ub.clients.obj-code no-lock no-error.
           if available ub.clients then  objname = ub.clients.obj-name.
                                         else  objname="объект не определен".
     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        paytype       = x-set_pay_type
        valtype       = if (paytype = 1) then 0  else x-set_val_type.

        find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
        if available  ub.gds-prt then   prtroot = ub.gds-prt.prt-root.
                              else   prtroot = 0.

        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }
{ gbl/dtm.i    }
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .

   no-prise = true .
  if var-report-r-b = "rubl"  then do:
    if  x-base-code <> 0 and valtype = 2  then no-prise = false  .
    end.
  else do:
    if  x-base-code <> 0 and valtype = 1  then no-prise = false  .
  end.

  run waitfram-show( {&mywaitmess} ) .

  run calcitog in this-procedure.          /*Поиск fact-order*/
  run print-header in this-procedure.      /*Печать шапки*/
  run prep-file in this-procedure.         /*Печать шапки*/

    case classify :
      when 1 then do:
        run foreach1 in this-procedure.    /*Обработка строк*/
      end.
      when 2 then do:
        run foreach2 in this-procedure.    /*Обработка строк*/
      end.
      when 3 then do:
        run foreach3 in this-procedure.    /*Обработка строк*/
      end.
      when 4 then do:
        run foreach4 in this-procedure.    /*Обработка строк*/
      end.
    end case.

  run print-footer in this-procedure.         /*Печать подвала */
  {&closeexcel}
  run waitfram-hide .
  run rep/runexcel.p (string( session:temp-directory) + {&df_name} + string( g#report-num ) + ".txt").
end procedure.


procedure print-header :
         reportname = reportname +
        "на "  + cur-time-string-sec()  .
  run rep/extitle.p (1) .    /*11.1*/
end procedure.


procedure print-footer :
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  {&putexcel} " Печать закончена : " + string(v-time,"hh:mm:ss") skip.
  {&putexcel} " За время формирования отчета были закрыты документы : " skip.
  for each obj-list no-lock :
      for each ub.trn-doc no-lock where
          ub.trn-doc.status_ = {&fact} and
          ub.trn-doc.flag_= true and
          ub.trn-doc.host-code = v-cntxt-host-code-obj and
          ub.trn-doc.obj-code = obj-list.obj-code and
          ub.trn-doc.obj-type = obj-list.obj-type

          by ub.trn-doc.fact-order descending :
          if ub.trn-doc.fact-order <= fact-order-2 then leave.
          {&putexcel} ub.trn-doc.doc-code skip.
      end.
  end.
  {&putexcel} " ______________________________________________________" skip.
   end procedure.


procedure calcitog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-tog-shift,
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
/*эти не нужны*/
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.
end procedure.


procedure foreach1 :
{ cus/r-z-all1.i no-classify "''" "''" 0 {1} {2} }
end procedure.

procedure foreach2 :
{ cus/r-z-all1.i prod-code  temp-goods.cli  "'по произв.'"  0  {1}  {2} }
end procedure.

procedure foreach3 :
{ cus/r-z-all1.i grp-goods  temp-goods.grp-name "'по группе '"  0  {1}  {2} }
end procedure.

procedure foreach4 :
{ cus/r-z-all1.i vat-pc  temp-goods.vat-pc "'по ставке НДС '"  0  {1}  {2} }
end procedure.


procedure display-prt :
if itog = false  then do:
   { cus/r-z-all1.i display  "''" "''"  0   {1}  {2} }
end.
end procedure.

procedure prep-file :
for each obj-list no-lock :
   for each ub.gds-obj where not (
            ub.gds-obj.fact-qnty = 0 and
            ub.gds-obj.avrg-qnty = 0 and
            ub.gds-obj.fact-sale = 0 )
            and
            ub.gds-obj.obj-code  = obj-list.obj-code and
            ub.gds-obj.obj-type  = obj-list.obj-type no-lock
          &if '{2}' = 'gds-list'  &then
          , first gds-list where  ub.gds-obj.prod-type = gds-list.prod-type and
                                  ub.gds-obj.prod-code = gds-list.prod-code and
                                  ub.gds-obj.artic     = gds-list.artic no-lock
                                              &endif

            :
            find first ub.goods   where
                               ub.goods.gds-code = ub.gds-obj.gds-code no-lock no-error .
            find first ub.clients where
                               ub.clients.obj-code = ub.gds-obj.prod-code and
                               ub.clients.obj-type = ub.gds-obj.prod-type no-lock no-error .
            if avail ub.goods and
                avail ub.clients and
                not can-find (temp-goods where temp-goods.gds-code = ub.gds-obj.gds-code no-lock ) then do:
               create temp-goods.
               { gbl/hostcode.i ub.gds-obj.obj-type ub.gds-obj.obj-code v-host-code }
               { gbl/pftxvalg.i ub.gds-obj.gds-code {&vat-tax-code} ? v-host-code ub.gds-obj.obj-type ub.gds-obj.obj-code v-vat-pc no-error }
               assign
                  temp-goods.gds-code  = ub.goods.gds-code
                  temp-goods.b-code    = ub.goods.gds-code
                  temp-goods.artic     = ub.goods.artic
                  temp-goods.cli       = ub.clients.obj-name
                  temp-goods.grp-name  = ub.goods.grp-name
                  temp-goods.vat-pc    = v-vat-pc
                  temp-goods.prod-code = ub.goods.prod-code
                  temp-goods.prod-type = ub.goods.prod-type
                  temp-goods.prt-root  = ub.goods.prt-root
                  temp-goods.gds-name  = ub.goods.gds-name

                  .
            end.
   end.
end.

end procedure.


{ rep/ostatok.i }

/* $Workfile$ e n d */