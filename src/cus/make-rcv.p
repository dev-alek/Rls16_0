block-level on error undo, throw.
/*

$Revision: 2a79bf27b012, 291, rls $
$Author: ASMorozov $
$Date: Tue Dec 01 19:11:26 2015 +0300 $
$Workfile: make-rcv.p $
$Archive: cus/make-rcv.p $

Процедура генерации поставок по заказу  по объектам.

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/29/02 2:19

*/
define temp-table temp-dates no-undo
field exch-date as date
index pi is unique primary   exch-date .

define input parameter parParentProc  as widget-handle no-undo.
define input parameter fp-recid       as recid no-undo .
define input parameter xdate-1        as date no-undo .      /* Период расчета темпа продаж */
define input parameter xdate-2        as date no-undo .
define input parameter t-action       as character no-undo . /* if t-action = "calc":u then есть вопрос об изменении qnty */
define input parameter var#import     as logical  no-undo .  /* var#import = да -  если был импорт пересчитывать не надо */
define input parameter p-r-algoritm   as integer no-undo . /* Метод расчета 1 2 3 */
define input parameter p-code         as character no-undo   .   /* Номер списка готовых темпов продаж */
define input parameter p-t-rv         as logical no-undo .   /* что входит в продажу */
define input parameter p-t-rvz        as logical no-undo .
define input parameter p-t-rvc        as logical no-undo .
define input parameter p-t-rvzc       as logical no-undo .
define input parameter p-t-sp         as logical no-undo .
define input parameter p-t-sppv       as logical no-undo .
define input parameter p-t-sppv-2     as logical no-undo .
define input parameter p-t-sppv-3     as logical no-undo .
define input parameter p-t-sppv-4     as logical no-undo .
define input parameter p-t-way        as logical no-undo .
define input parameter p-t-rcv        as logical no-undo .
define input parameter p-t-clos       as logical no-undo .
define input parameter TABLE for  temp-dates.

define variable vss-revision    as character no-undo init "$Revision: 2a79bf27b012, 291, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:26 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: make-rcv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/make-rcv.p $":U .
define variable vss-description as character no-undo init "Процедура генерации поставок по заказу  по объектам. ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cus/df-zakaz.i new }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ trg/prdoclib.i     }
{ gbl/dtm.i          }
{ cus/qnty-lib.i     }

&glob l-out 'out':U



{ gbl/getcntxt.i get  }


define var  fact-order-1       like UB.stk-tot.fact-order no-undo.
define var  fact-order-2       like UB.stk-tot.fact-order no-undo.
define var  fact-order-today   like UB.stk-tot.fact-order no-undo.

define buffer buf-fp_ord-doc  for UB.ord-doc .
define buffer buf-fp_ord-line for UB.ord-line .
define buffer buf-fp_ord-dtl  for UB.ord-dtl .

define variable t-temp as decimal no-undo .
define variable doc-rcv-recid as recid no-undo .
define var all-day     as int init 0 no-undo.
define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.

define new global shared temp-table tt-obj-gds no-undo
field obj-type  like ub.clients.obj-type
field obj-code  like ub.clients.obj-code
field artic     like ub.ord-line.artic
field prod-type like ub.ord-line.prod-type
field prod-code like ub.ord-line.prod-code
field t-temp    as decimal
index pi obj-type
         obj-code
         artic
         prod-type
         prod-code
         .

define temp-table tt-gds no-undo
field artic     like ub.ord-line.artic
field prod-type like ub.ord-line.prod-type
field prod-code like ub.ord-line.prod-code
field t-temp    as decimal
index pi prod-type
         prod-code
         .


find first  buf-fp_ord-doc where recid(buf-fp_ord-doc ) = fp-recid no-lock no-error .
if not available buf-fp_ord-doc then return error.

  IF p-r-algoritm = 1 Then do:
    all-day = xdate-2 - xdate-1  + 1.
  end.

  IF p-r-algoritm = 3 Then do:
    all-day = 0 .
    for each temp-dates :
        all-day = all-day  + 1.
    end.
  end.

   assign
     fact-order-1 = integer( xdate-1 - 1 ) + 0.99
     fact-order-2 = integer( xdate-2 ) + 0.99
   .

if not can-find ( first obj-list ) then do:
    message "Ни задан ни один объект для расчета" view-as alert-box error .
    return.
end.


define variable p-R-algoritm2 as integer   no-undo .

case p-r-algoritm :
  when 1 then do:
      p-R-algoritm = 1 .
      p-R-algoritm2 = 1 .
  end.
  when 4 then do:
    p-R-algoritm = 1 .
    p-R-algoritm2 = 2 .
  end.
  when 2 then do:
      p-R-algoritm = 2 .
      p-R-algoritm2 = 1 .
  end.
  when 3 then do:
      p-R-algoritm = 1 .
      p-R-algoritm2 = 3 .
  end.
end.



empty temp-table tmp#zakaz .
for each buf-fp_ord-line where buf-fp_ord-line.doc-code = buf-fp_ord-doc.doc-code no-lock :
    create tmp#zakaz.
    buffer-copy buf-fp_ord-line to tmp#zakaz .
end.

run cus/qnty-obj.p (
    input parparentproc ,
    input ?    ,
    input ?    ,
    input buf-fp_ord-doc.e-method   ,
    input "rcv-ord"    ,
    input buf-fp_ord-doc.doc-code  ,
    input xdate-1    ,
    input xdate-2    ,
    input "calc":U      ,
    input yes           ,
    input p-R-algoritm  ,
    input p-R-algoritm2  ,
    input 1  ,
    input no ,
    input p-code     ,
    input p-t-rv     ,
    input p-t-rvz    ,
    input p-t-rvc    ,
    input p-t-rvzc   ,
    input p-t-sp     ,
    input p-t-sppv-2 ,
    input p-t-sppv-2 ,
    input p-t-sppv-3 ,
    input p-t-sppv-4 ,
    input p-t-way      ,
    input p-t-rcv      ,
    input p-t-clos     ,
    input table temp-dates ,
    input table temp-abc-day ,
    input no    ,
    input no    ,
    input no    ,
    input no    ,
    input no    ,
    v-cntxt-obj-type,
    v-cntxt-obj-code,
    {&f-p}          ,
    input no
        ) no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.

/* временные таблицы с темпами */


for each buf-fp_ord-line where buf-fp_ord-line.doc-code = buf-fp_ord-doc.doc-code no-lock :
     run make-gds in this-procedure
                  ( input buf-fp_ord-line.artic ,
                    input buf-fp_ord-line.prod-type ,
                    input buf-fp_ord-line.prod-code   )
                    no-error  .

end.
/*создание поставок */

for each buf-fp_ord-line where buf-fp_ord-line.doc-code = buf-fp_ord-doc.doc-code no-lock :
    /*  по объектам фирмы */
     for each obj-list  no-lock :
            for each tt-obj-gds where
              tt-obj-gds.obj-type  = obj-list.obj-type and
              tt-obj-gds.obj-code  = obj-list.obj-code and
              tt-obj-gds.artic     = buf-fp_ord-line.artic and
              tt-obj-gds.prod-type = buf-fp_ord-line.prod-type and
              tt-obj-gds.prod-code = buf-fp_ord-line.prod-code  and
              tt-obj-gds.t-temp    > 0  no-lock :
                  run create-ord-doc-rcv in this-procedure
                                         (input tt-obj-gds.obj-type ,
                                          input tt-obj-gds.obj-code ,
                                          output loc-ord-num ) .

                  find first tt-gds where
                      tt-gds.artic     = buf-fp_ord-line.artic and
                      tt-gds.prod-type = buf-fp_ord-line.prod-type and
                      tt-gds.prod-code = buf-fp_ord-line.prod-code no-lock no-error .
                  IF not AVAILABLE TT-GDS then next.
                  /* строка */
                  run create-ord-line-rcv in this-procedure
                  (   input tt-obj-gds.t-temp ,
                      input tt-gds.t-temp ,
                      input loc-ord-num  ).

                  /* шкала*/
                  run create-ord-dtl-rcv in this-procedure .
            end.
     end.
end.




procedure make-gds :
 do
 on error undo, return error return-value
 :
define input  parameter p-artic     like ub.ord-line.artic     no-undo .
define input  parameter p-prod-type like ub.ord-line.prod-type no-undo .
define input  parameter p-prod-code like ub.ord-line.prod-code no-undo .
define variable l-ppp as decimal no-undo .
l-ppp = 0.

 for each tt-obj-gds where
    tt-obj-gds.artic      = p-artic      and
    tt-obj-gds.prod-type  = p-prod-type  and
    tt-obj-gds.prod-code  = p-prod-code  :
     l-ppp = l-ppp + tt-obj-gds.t-temp .
  end.

  if l-ppp <=0 or l-ppp = ? then return.

  create tt-gds.
  assign
    tt-gds.artic      = p-artic
    tt-gds.prod-type  = p-prod-type
    tt-gds.prod-code  = p-prod-code
    tt-gds.t-temp     = l-ppp
  .
  /*
  message "tt-gds." skip
           tt-gds.artic    tt-gds.t-temp .

    */
 end. /* do */
end procedure. /* make-temp */




procedure create-ord-doc-rcv :
 do
 on error undo, return error return-value
 :
define input parameter  p-obj-type like ub.clients.obj-type no-undo .
define input parameter  p-obj-code like ub.clients.obj-code no-undo .
define output parameter loc-ord-num as character no-undo .

{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
loc-ord-num = "" .
find first  ub.ord-doc-rcv where
      ub.ord-doc-rcv.doc-code  = buf-fp_ord-doc.doc-code and
      ub.ord-doc-rcv.obj-code  = p-obj-code and
      ub.ord-doc-rcv.obj-type  = p-obj-type no-lock no-error  .

if available ub.ord-doc-rcv  then do:
  loc-ord-num = ub.ord-doc-rcv.rcv-code .
  return.
end.

define variable i-doc-code as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    p-obj-type
    p-obj-code
    i-doc-code
    loc-ord-num
    }

   create ub.ord-doc-rcv.
   buffer-copy buf-fp_ord-doc to ub.ord-doc-rcv.
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-type  = {&l-out}
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.creid     = v-cntxt-userid
      ub.ord-doc-rcv.status_   = {&g___new}
      ub.ord-doc-rcv.obj-code  = p-obj-code
      ub.ord-doc-rcv.obj-type  = p-obj-type
   .

 end. /* do */
end procedure. /* create-ord-doc-rcv */




procedure create-ord-line-rcv :
 do
 on error undo, return error return-value
 :
 define input parameter tt-gds as decimal no-undo .
 define input parameter tt-all-gds as decimal no-undo .
 define input parameter p-rcv-code as character no-undo .
 define buffer b-ord-doc-rcv for ub.ord-doc-rcv.
 define buffer b-ord-line-rcv for ub.ord-line-rcv.
 define buffer buf_goods for ub.goods.


find first buf_goods where
    buf_goods.artic      = buf-fp_ord-line.artic      and
    buf_goods.prod-type  = buf-fp_ord-line.prod-type  and
    buf_goods.prod-code  = buf-fp_ord-line.prod-code
    no-lock no-error .

 create b-ord-line-rcv .
 BUFFER-COPY buf-fp_ord-line to b-ord-line-rcv
 assign
   b-ord-line-rcv.gds-code  = buf_goods.gds-code
   b-ord-line-rcv.rcv-code  = p-rcv-code
   b-ord-line-rcv.qnty      = ( buf-fp_ord-line.qnty * tt-gds ) / tt-all-gds
   .
  /*
    message
      "artic           :"  b-ord-line-rcv.artic             skip
      "поставка №      :"  b-ord-line-rcv.rcv-code         skip
      "рассчитанное кол-во :"  b-ord-line-rcv.qnty.


     */


 if can-find(first ub.units where ub.units.unit-name = buf_goods.unit-base
    and lookup({&pieces}, ub.units.type) > 0)
    and trunc( b-ord-line-rcv.qnty, 0 ) <> b-ord-line-rcv.qnty then do:
        b-ord-line-rcv.qnty = trunc( b-ord-line-rcv.qnty, 0 ) + 1 .
    end.

   b-ord-line-rcv.cli-qnty  = b-ord-line-rcv.qnty / b-ord-line-rcv.cli-base-rate .
 end. /* do */
end procedure. /* create-ord-line-rcv */




procedure create-ord-dtl-rcv :
 do
 on error undo, return error return-value
 :


 end. /* do */
end procedure. /* create-ord-dtl-rcv */