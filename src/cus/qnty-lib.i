/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение временной таблицы по товару за период времени (мини архив ost-line)


Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/03/03 8:28

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ trg/factord.i  }
define temp-table temp-gds-qnty no-undo
field day as date
field prih as decimal
field rash as decimal
field ost  as decimal
field qnty-day as integer
index pi is unique primary day
index by-ost ost .
define variable qnty-lib-v-fact-order-2 as decimal no-undo .

procedure qnty-lib-clear-tt :
 do
 on error undo, return error return-value
 :
 for each temp-gds-qnty :
     delete temp-gds-qnty .
 end.

 end. /* do */
end procedure. /* qnty-lib-create-tt */


procedure qnty-lib-create-tt :
 do
 on error undo, return error return-value
 :
define input parameter p-fact-order-1 as decimal no-undo .
define input parameter p-fact-order-2 as decimal no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable p-include-fact-order as logical no-undo .
define buffer buf_goods for ub.goods .
define variable quantity      as decimal no-undo .
define variable p-fact-date   as date no-undo .
define variable p-fact-date-0 as date no-undo .
define variable p-fact-date-2 as date no-undo .
define buffer p-doc-line for ub.doc-line .
define variable p-prih as decimal no-undo .
define variable p-rash as decimal no-undo .


qnty-lib-v-fact-order-2 = p-fact-order-2.
p-include-fact-order = true .


find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
     if error-status :error then return error .

       run prdoclib-init-prt-obj-by-factord in this-procedure
            (input  p-obj-type
            ,input  p-obj-code
            ,input  buf_goods.artic
            ,input  buf_goods.prod-type
            ,input  buf_goods.prod-code
            ,input  p-fact-order-1  + 0.99
            ,input  p-include-fact-order
            ) .
      for each temp-prt-obj :
          quantity   = quantity + temp-prt-obj.fact-qnty.
      end.
      run prdoclib-clear-temp-prt-obj in this-procedure .   /* зачистка временной таблицы */

     /* первая запись */
    run factord-to-date in this-procedure
                        (  input  p-fact-order-1  ,
                           output p-fact-date-0     ).
    find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date-0 no-error .
     if not available temp-gds-qnty then do:

          create temp-gds-qnty.
          assign
            temp-gds-qnty.day      = p-fact-date-0
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      = quantity
            temp-gds-qnty.qnty-day = 0
          .
          /* message quantity "quantity" p-fact-date-0. */
     end.
     else do:
          assign
            temp-gds-qnty.day      = p-fact-date-0
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      =  temp-gds-qnty.ost + quantity
            temp-gds-qnty.qnty-day = 0
          .

    end.
  /* последняя запись */
  run factord-to-date in this-procedure
                      (  input  p-fact-order-2  ,
                         output p-fact-date     ).

   find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date no-error .
     if not available temp-gds-qnty then do:
          create temp-gds-qnty.
          assign
            temp-gds-qnty.day      = p-fact-date
            temp-gds-qnty.prih     = 0
            temp-gds-qnty.rash     = 0
            temp-gds-qnty.ost      = 0
            temp-gds-qnty.qnty-day = 0
          .
     end.


   /* остальные  дни */
assign
  p-prih  = 0
  p-rash  = 0
.
define variable i as integer no-undo .
       for each p-doc-line no-lock where
                p-doc-line.obj-type    = p-obj-type
            and p-doc-line.obj-code    = p-obj-code
            and p-doc-line.artic       = buf_goods.artic
            and p-doc-line.prod-type   = buf_goods.prod-type
            and p-doc-line.prod-code   = buf_goods.prod-code
            and p-doc-line.status_     = {&fact}
            and p-doc-line.fact-order >= p-fact-order-1
            and p-doc-line.fact-order <= p-fact-order-2 break by integer(p-doc-line.fact-order) :

        case p-doc-line.ext-doc-type:
        /* разбивка по типам документов */
        /* приход */
             when   {&tdedt_pri_vnesh}  or
             when   {&tdedt_pri_prvo  }     then
               do:
                  assign p-prih   = p-prih  +  p-doc-line.fact-qnty.
               end.

        /* расход */
              when  {&tdedt_spi_vnesh}      then if  p-t-sp      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_spi_prvo}       then if  p-t-sppv    then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_ras_prvo}       then if  p-t-sppv-2  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_ras_perem}      then if  p-t-sppv-3  then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_perem}  then if  p-t-sppv-4  then assign p-rash = p-rash   -  p-doc-line.fact-qnty.
              when  {&tdedt_ras_vnesh}      then if  p-t-rv      then assign p-rash = p-rash   +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_vnesh}  then if  p-t-rvz     then assign p-rash   = p-rash  -  p-doc-line.fact-qnty.
              when  {&tdedt_ras_vnesh_kass}     then if p-t-rvc  then assign p-rash  = p-rash  +  p-doc-line.fact-qnty.
              when  {&tdedt_vozvrat_vnesh_kass} then if p-t-rvzc then assign p-rash  = p-rash  -  p-doc-line.fact-qnty.
          end case.
          assign
            p-rash  = p-rash
          .
          if last-of(integer(p-doc-line.fact-order)) then do:
            run factord-to-date in this-procedure (  input  p-doc-line.fact-order  ,
                                   output p-fact-date-2   ).
                find first temp-gds-qnty where temp-gds-qnty.day      = p-fact-date-2 no-error .
                if not available temp-gds-qnty then do:
                    create temp-gds-qnty.
                    assign
                      temp-gds-qnty.day      = p-fact-date-2
                      temp-gds-qnty.prih     = p-prih
                      temp-gds-qnty.rash     = p-rash
                      temp-gds-qnty.ost      = 0
                      temp-gds-qnty.qnty-day = 0
                    .
                end.
                else do:
                    assign
                      temp-gds-qnty.prih     = temp-gds-qnty.prih + p-prih
                      temp-gds-qnty.rash     = temp-gds-qnty.rash + p-rash
                      temp-gds-qnty.ost      = temp-gds-qnty.ost
                      temp-gds-qnty.qnty-day = 0
                    .
                end.

                /* Создадим заранее пустую запись на следующий день */
                if temp-gds-qnty.rash <> 0  and
                   p-fact-date-2 + 1  <  p-fact-date then  do:
                   find first temp-gds-qnty where
                              temp-gds-qnty.day      = p-fact-date-2 + 1 no-error .
                    if not available temp-gds-qnty then do:
                        create temp-gds-qnty.
                        assign
                          temp-gds-qnty.day      = p-fact-date-2 + 1
                          temp-gds-qnty.prih     = 0
                          temp-gds-qnty.rash     = 0
                          temp-gds-qnty.ost      = 0
                          temp-gds-qnty.qnty-day = 0
                        .
                    end.
                 end.


                assign
                  p-prih  = 0
                  p-rash  = 0
                .

          end.
    end.

 /* второй  проход по таблице - рассчитывает остаток по дням  */
 define variable old-ost as decimal no-undo .
 old-ost = 0 .

 for each temp-gds-qnty break by temp-gds-qnty.day :
    if  temp-gds-qnty.day      <> p-fact-date-0 then do:
              assign
                 temp-gds-qnty.ost    = old-ost +    temp-gds-qnty.prih  - temp-gds-qnty.rash
              .
              end.

    assign
      old-ost = temp-gds-qnty.ost
    .
 end.

 end. /* do */
end procedure. /* qnty-lib-create-tt */




procedure qnty-lib-2 :
 do
 on error undo, return error return-value
 :
define variable p-fact-date-3 as date no-undo .
define variable old-day as date no-undo .

run factord-to-date in this-procedure (  input  qnty-lib-v-fact-order-2  ,
                       output p-fact-date-3   ).

 old-day = p-fact-date-3 + 1.
 for each temp-gds-qnty break by temp-gds-qnty.day DESCENDING :
    assign
      temp-gds-qnty.qnty-day  =  old-day - temp-gds-qnty.day
      old-day = temp-gds-qnty.day
    .

 end .
/*
for each temp-gds-qnty  break by temp-gds-qnty.day :
         message      "c кол-вом"        skip
                      tmp#zakaz.gds-name skip
                "day" temp-gds-qnty.day skip
                "prih" temp-gds-qnty.prih skip
                "rash" temp-gds-qnty.rash skip
                "obor" temp-gds-qnty.prih - temp-gds-qnty.rash skip
                "ost"  temp-gds-qnty.ost skip
                "qnty-day" temp-gds-qnty.qnty-day skip
                .
end.
*/
 end. /* do */
end procedure. /* qnty-lib-2 */






/* $Workfile$ e n d */