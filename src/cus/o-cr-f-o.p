block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: o-cr-f-o.p $
$Archive: cus/o-cr-f-o.p $

Сбор заказов ФП из заказов ОФ

Автор: Чернова Светлана Александровна
Дата создания: 09/07/05
Author: Svetlana Chernova
Creation date: 09/07/05

*/
define input parameter t-sale as logical no-undo .
define input parameter p-date-sale-1 as date no-undo .
define input parameter p-date-sale-2 as date no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: o-cr-f-o.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/o-cr-f-o.p $":u .
define variable vss-description as character no-undo init " Сбор заказов ФП из заказов ОФ   ".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i      }
{ rep/repfrm.i def   }
{ rep/repfrm.i on 1  }
{ rep/rep-bt.i       }
{ cus/ord-code.i def}


define variable i-i as integer no-undo .
define variable i-m as integer no-undo .

define buffer of-ord-doc  for ub.ord-doc.
define buffer of-ord-line for ub.ord-line.
define buffer of-ord-dtl  for ub.ord-dtl.

define buffer cz-ord-doc  for ub.ord-cons.
define buffer cz-ord-line for ub.ord-gds-cons.
define buffer cz-ord-dtl  for ub.ord-dtl-cons.

define variable loc-ord-num    like ub.ord-doc.doc-code no-undo .
define variable loc-sum-qnty   as   decimal init 0 no-undo .
define variable loc-sum-qnty-2 as   decimal init 0 no-undo .
define variable v-i-doc as character no-undo .

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }


/*  признаки  */

for each obj-list no-lock ,
    each of-ord-doc  where
    of-ord-doc.obj-code   = obj-list.obj-code  and
    of-ord-doc.obj-type   = obj-list.obj-type  and
    of-ord-doc.status_    = {&ord-accept}   and
    of-ord-doc.doc-date  >= x-date-start and
    of-ord-doc.doc-date  <= x-date-end   and
    of-ord-doc.doc-type   = {&o-f}       and
    of-ord-doc.cons-code  =    ""       and
    of-ord-doc.host-code  =  v-cntxt-host-code-obj  and
    ( (t-sale = false)  or
      (of-ord-doc.date-sale-1  >= p-date-sale-1   and
       of-ord-doc.date-sale-2  <= p-date-sale-2 ))
    no-lock :
    i-i = i-i + 1 .
end.

/*  сделаем строки */
      loc-sum-qnty = 0.
      loc-sum-qnty-2 = 0.

for each obj-list no-lock ,
  each of-ord-doc  where
    of-ord-doc.obj-code   = obj-list.obj-code   and
    of-ord-doc.obj-type   = obj-list.obj-type   and
    of-ord-doc.status_    = {&ord-accept}       and
    of-ord-doc.doc-date  >= x-date-start        and
    of-ord-doc.doc-date  <= x-date-end          and
    of-ord-doc.doc-type   = {&o-f}              and
    of-ord-doc.cons-code  =    ""               and
    of-ord-doc.host-code  =  v-cntxt-host-code-obj        and
    ( (t-sale = false)                          or
      (of-ord-doc.date-sale-1  >= p-date-sale-1   and
       of-ord-doc.date-sale-2  <= p-date-sale-2 ))  no-lock  ,
    each  of-ord-dtl where
          of-ord-dtl.doc-code     = of-ord-doc.doc-code        NO-LOCK  break
              by of-ord-dtl.node-code :
                    assign
                      loc-sum-qnty-2 = loc-sum-qnty-2  + of-ord-dtl.qnty
                    .
                    if last-of (of-ord-dtl.node-code) then do:

                    find first cz-ord-dtl  exclusive-lock  where
                      cz-ord-dtl.cons-code = loc-ord-num   and
                      cz-ord-dtl.artic     = of-ord-dtl.artic and
                      cz-ord-dtl.prod-code = of-ord-dtl.prod-code  and
                      cz-ord-dtl.prod-type = of-ord-dtl.prod-type  and
                      cz-ord-dtl.node-code = of-ord-dtl.node-code  no-error .

                    if not available cz-ord-dtl then do:
                       create cz-ord-dtl. /*Строка аккум */
                       end.

                    assign
                      cz-ord-dtl.cons-code = loc-ord-num
                      cz-ord-dtl.artic     = of-ord-dtl.artic
                      cz-ord-dtl.prod-code = of-ord-dtl.prod-code
                      cz-ord-dtl.prod-type = of-ord-dtl.prod-type
                      cz-ord-dtl.node-code = of-ord-dtl.node-code
                      cz-ord-dtl.sum-qnty  = cz-ord-dtl.sum-qnty + loc-sum-qnty-2
                      loc-sum-qnty-2 = 0
                      .
                    end.

     { rep/repfrm.i disp i-m }
end.

i-m = 0 .

/* Захватываю заявки и делаю СЗ */
      loc-sum-qnty = 0.
      loc-sum-qnty-2 = 0.
/*  сделаем строки */
for each obj-list no-lock ,
  each of-ord-doc  where
    of-ord-doc.obj-code   = obj-list.obj-code  and
    of-ord-doc.obj-type   = obj-list.obj-type  and
    of-ord-doc.status_    = {&ord-accept}   and
    of-ord-doc.doc-date  >= x-date-start and
    of-ord-doc.doc-date  <= x-date-end   and
    of-ord-doc.doc-type   = {&o-f}       and
    of-ord-doc.cons-code  =    ""       and
    of-ord-doc.host-code  =  v-cntxt-host-code-obj and
    ( (t-sale = false)  or
      (of-ord-doc.date-sale-1  >= p-date-sale-1   and
       of-ord-doc.date-sale-2  <= p-date-sale-2 ))
    exclusive-lock ,
    each of-ord-line where
          of-ord-doc.doc-code = of-ord-line.doc-code
          exclusive-lock
          break by of-ord-line.prod-code
                by of-ord-line.prod-type
                by of-ord-line.artic

    :

    assign

      loc-sum-qnty = loc-sum-qnty  + of-ord-line.qnty
    .

    if last-of (of-ord-line.artic) then do:
    create cz-ord-line. /*Строка аккум */
    assign
      cz-ord-line.cons-code = loc-ord-num
      cz-ord-line.artic     = of-ord-line.artic
      cz-ord-line.prod-code = of-ord-line.prod-code
      cz-ord-line.prod-type = of-ord-line.prod-type
      cz-ord-line.sum-qnty  = loc-sum-qnty
      loc-sum-qnty = 0
      i-m = i-m + 1
       .
     { rep/repfrm.i disp i-m }
    end.

end.

if  i-m  <> 0 then do:
    create cz-ord-doc.  /*Шапка*/
    assign
        cz-ord-doc.cons-code  = loc-ord-num
        cz-ord-doc.creid      = v-cntxt-userid
        cz-ord-doc.doc-date   = to-day
        cz-ord-doc.host-code  = v-cntxt-host-code-obj
        cz-ord-doc.input-obj-type = v-cntxt-obj-type
        cz-ord-doc.input-obj-code = v-cntxt-obj-code
        cz-ord-doc.status_    = {&g___new}
        cz-ord-doc.PS         = str1 + " " + str2 + " " + str3 + " " + str4 + " " + ReportHeader
        .
        /* doc-rec = recid(cz-ord-doc). */
end.

for each obj-list no-lock ,
    each of-ord-doc  where
    of-ord-doc.obj-code   = obj-list.obj-code  and
    of-ord-doc.obj-type   = obj-list.obj-type  and
    of-ord-doc.status_    = {&ord-accept}   and
    of-ord-doc.doc-date  >= x-date-start and
    of-ord-doc.doc-date  <= x-date-end   and
    of-ord-doc.doc-type   = {&o-f}       and
    of-ord-doc.cons-code  =  ""          and
    of-ord-doc.host-code  =  v-cntxt-host-code-obj and
    ( (t-sale = false)  or
      (of-ord-doc.date-sale-1  >= p-date-sale-1   and
       of-ord-doc.date-sale-2  <= p-date-sale-2 ))
    exclusive-lock :
    assign
      /* пометка в заявках */
      /* of-ord-doc.status_    = {&ord-accept} */
      of-ord-doc.cons-code  = loc-ord-num
      .
end.

{ rep/repfrm.i off }

if i-i = 0 then
    message "Нет заявок ОФ " view-as alert-box .
else
   message "Формирование закончено! " skip
           "Согласовано" i-i "заявок  ОФ." skip
           "cоздана заявка n " loc-ord-num view-as alert-box .

/* $workfile: o-cr-f-o.p $ e n d */