/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры создания переоценок и Ден-таблицы по объектам из x_obj-group

Автор: Чернова Светлана Александровна
Дата создания: 06/13/06
Author: Svetlana Chernova
Creation date: 06/13/06


*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure create-price-all :
/* СОЗДАНИЕ ДЕН-таблицы */
define input  parameter p-main                   as integer   no-undo .
define input  parameter p-plt-id                 as integer   no-undo .
define input  parameter p-plt-db-num             as integer   no-undo .
define input  parameter p-pdf-id                 as integer   no-undo .
define input  parameter p-pdf-db-num             as integer   no-undo .
define input  parameter p-b-code                 as integer   no-undo .
define input  parameter p-gds-code               as integer   no-undo .
define input  parameter p-type-price             as integer   no-undo .
define input  parameter p-qnty-from              like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-qnty-to                like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-sum-from               as decimal   no-undo .
define input  parameter p-sum-to                 as decimal   no-undo .
define input  parameter p-turnover-from          as decimal   no-undo .
define input  parameter p-turnover-to            as decimal   no-undo .
define input  parameter p-fact-order-shift-from  as decimal   no-undo .
define input  parameter p-fact-order-shift-to    as decimal   no-undo .
define input  parameter p-fact-order-sys-from    as decimal   no-undo .
define input  parameter p-fact-order-sys-to      as decimal   no-undo .
define input  parameter p-price-sale             as decimal   no-undo . /* ПРОДАЖНАЯ ЦЕНА */


define buffer b_price-list-type            for ub.price-list-type  .
define buffer b_price-list-type-cash-pay   for ub.price-list-type-cash-pay  .
define buffer b_price-list-type-pay-type   for ub.price-list-type-pay-type  .
define buffer b_price-doc-forming for ub.price-doc-forming .
define variable v-curr-obj-date as date   no-undo .

  do
  on error undo, return error return-value
  :
find first b_price-list-type no-lock where
           b_price-list-type.plt-id     = p-plt-id   and
           b_price-list-type.plt-db-num = p-plt-db-num
           no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка: &1 &2 " , error-status :get-message(1) , return-value)).
            end.

find first b_price-doc-forming no-lock where
           b_price-doc-forming.pdf-db     = p-pdf-db-num and
           b_price-doc-forming.pdf-id     = p-pdf-id     and
           b_price-doc-forming.plt-db-num = p-plt-db-num and
           b_price-doc-forming.plt-id     = p-plt-id
           no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка: &1 &2 " , error-status :get-message(1) , return-value)).
            end.


  for each x_obj-group:
         { gbl/curobjdt.i
           x_obj-group.obj-type
           x_obj-group.obj-code
           v-curr-obj-date no-error }
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Неправильная дата на объекте: &1 &2  &3 &4" , x_obj-group.obj-type , x_obj-group.obj-code, error-status :get-message(1) , return-value)).
                delete x_obj-group.
                next.
            end.
      /* проверка на принадлежность текущей БД */
      if b_price-list-type.main = true  then do:
         if x_obj-group.db-num <> v-cntxt-db-num and  v-cntxt-db-num <> 0 then next .
      end.

      if b_price-list-type.use-cash-pay = 1 then do:
         for each b_price-list-type-cash-pay no-lock where
                  b_price-list-type-cash-pay.plt-id     = p-plt-id   and
                  b_price-list-type-cash-pay.plt-db-num = p-plt-db-num
                  :
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  0
                  ,input  b_price-list-type-cash-pay.cdpay-code
                  ,input  b_price-list-type-cash-pay.curr-code
                  ).
         end.
      end.
      if b_price-list-type.use-pay-type = 1 then do:
         for each b_price-list-type-pay-type no-lock where
                  b_price-list-type-pay-type.plt-id     = p-plt-id   and
                  b_price-list-type-pay-type.plt-db-num = p-plt-db-num
                  :
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  b_price-list-type-pay-type.pay-code
                  ,input  0
                  ,input  0
                  ).
         end.
      end.
      if b_price-list-type.use-pay-type = 0 and b_price-list-type.use-cash-pay = 0 then do:
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  0
                  ,input  0
                  ,input  0
                  ).
      end.
   end.
 end.
end procedure. /* create-price-all */


procedure create-price-list-mpl : /* Создание переоценок по ДНЦ */

define input  parameter p-pdf-db-num  as integer   no-undo .
define input  parameter p-pdf-id      as integer   no-undo .
define input  parameter p-plt-db-num  as integer   no-undo .
define input  parameter p-plt-id      as integer   no-undo .
define output parameter p-price-doc-recid as recid no-undo .
define output parameter p-list-recid as character no-undo .

define buffer b_price-list-type   for ub.price-list-type   .
define buffer b_price-doc-forming for ub.price-doc-forming .
define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_price-all         for ub.price-all .
define buffer b_price-doc         for ub.price-doc .
define buffer bufnew_price-list   for ub.price-list  .
define variable v-base as logical   no-undo .

define variable p-first-ie as integer   no-undo .
define variable p-first-iv as integer   no-undo .
define variable p-first-im as integer   no-undo .
define variable p-second-ie as integer   no-undo .
define variable p-second-iv as integer   no-undo .
define variable p-second-im as integer   no-undo .


  do
  on error undo, return error return-value
  :
{ gbl/rbisbase.i v-base }
p-list-recid = "".
find first b_price-list-type no-lock where
           b_price-list-type.plt-id     = p-plt-id   and
           b_price-list-type.plt-db-num = p-plt-db-num
           no-error .
           if error-status :error then message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             "price-list-type"
             view-as alert-box error
           .
IF not ( b_price-list-type.main = true  and
         b_price-list-type.create-price-doc = 1 /* yes */ ) then return .

find first b_price-doc-forming no-lock where
           b_price-doc-forming.pdf-db     = p-pdf-db-num and
           b_price-doc-forming.pdf-id     = p-pdf-id     and
           b_price-doc-forming.plt-db-num = p-plt-db-num and
           b_price-doc-forming.plt-id     = p-plt-id
           no-error .
           if error-status :error then message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             ""
             view-as alert-box error
           .
define variable v-make as logical   no-undo .
v-make = true  .

define buffer buf_trn-doc for ub.trn-doc  .

/* автопереоценки */

find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = b_price-doc-forming.out-code no-error .
if available buf_trn-doc then do:
  { gbl/gtpl-fs.i
    parparentproc
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    p-first-ie
    p-first-iv
    p-first-im
    p-second-ie
    p-second-iv
    p-second-im
    no-error
   }

   define buffer bb_price-doc-forming-attr for ub.price-doc-forming-attr  .

   find first bb_price-doc-forming-attr exclusive-lock where
              bb_price-doc-forming-attr.plt-id       = p-plt-id       and
              bb_price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              bb_price-doc-forming-attr.pdf-id       = p-pdf-id       and
              bb_price-doc-forming-attr.pdf-db       = p-pdf-db-num   and
              bb_price-doc-forming-attr.attr-code    = {&trdcattr-first-price}   no-error .
      if available bb_price-doc-forming-attr then do:
       /* первая */
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} and p-first-ie = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Perem} and p-first-iv = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Prvo}  and p-first-im = 0 then v-make = false .
      end.
      else do:
      /* вторая */
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Vnesh} and p-second-ie = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Perem} and p-second-iv = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = {&tdedt_Pri_Prvo}  and p-second-im = 0 then v-make = false .
      end.
end.

define variable p-update as logical   no-undo .
define buffer   b_bar-code for ub.bar-code  .
define variable p-recid-str as recid no-undo .

  for each x_obj-group where v-make = true or (x_obj-group.obj-code = v-cntxt-obj-code and x_obj-group.obj-type = v-cntxt-obj-type) no-lock :
      if x_obj-group.db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 then next .
      run prcreate-new-price-doc in this-procedure
          ( input v-cntxt-db-num ,
            input x_obj-group.obj-type  ,
            input x_obj-group.obj-code   ,
            input p-plt-id      ,
            input p-plt-db-num  ,
            input p-pdf-id      ,
            input p-pdf-db-num  ,
            output p-price-doc-recid

            ) .

        p-list-recid = p-list-recid + string(p-price-doc-recid) + "," .
        find first b_price-doc no-lock where recid(b_price-doc) = p-price-doc-recid no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "3"
          view-as alert-box error
        .
        /* копирование атрибутов */
        for each  ub.price-doc-forming-attr exclusive-lock where
                  ub.price-doc-forming-attr.plt-id       = p-plt-id       and
                  ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
                  ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
                  ub.price-doc-forming-attr.pdf-db       = p-pdf-db-num :
              find first ub.doc-attr exclusive-lock where
                         ub.doc-attr.doc-code  = b_price-doc.doc-num  and
                         ub.doc-attr.attr-code = ub.price-doc-forming-attr.attr-code no-error .
                     if not available ub.doc-attr then create ub.doc-attr.
                     assign
                        ub.doc-attr.doc-code   = b_price-doc.doc-num
                        ub.doc-attr.attr-code  = ub.price-doc-forming-attr.attr-code
                        ub.doc-attr.attr-value = ub.price-doc-forming-attr.attr-value
                     .
        end.

        for each b_price-all exclusive-lock where
           b_price-all.pdf-db     = p-pdf-db-num and
           b_price-all.pdf-id     = p-pdf-id     and
           b_price-all.plt-db-num = p-plt-db-num and
           b_price-all.plt-id     = p-plt-id and
           b_price-all.obj-type   =  x_obj-group.obj-type and
           b_price-all.obj-code   =  x_obj-group.obj-code and
           b_price-all.main-indication <= {&bef-mpl-nomain} :

           find first b_price-doc-forming-gds no-lock where
                      b_price-doc-forming-gds.b-code     = b_price-all.b-code and
                      b_price-doc-forming-gds.pdf-db     = p-pdf-db-num and
                      b_price-doc-forming-gds.pdf-id     = p-pdf-id     and
                      b_price-doc-forming-gds.plt-db-num = p-plt-db-num and
                      b_price-doc-forming-gds.plt-id     = p-plt-id
                      no-error .
           find first b_bar-code no-lock where  b_bar-code.b-code = b_price-all.b-code no-error .
           if available b_bar-code then do:
                  run cre-pr-list in this-procedure
                  ( input  b_price-all.b-code
                  , input  b_price-doc.doc-num
                  , output p-recid-str).
                  find first bufnew_price-list exclusive-lock where
                      recid(bufnew_price-list) = p-recid-str no-error .
                      if available bufnew_price-list then do:
                          bufnew_price-list.calc-method =  b_price-doc-forming-gds.calc-method .
                          bufnew_price-list.d-pcnt      =  b_price-doc-forming-gds.d-pcnt.
                          if v-base then assign
                            bufnew_price-list.road-tax   =  b_price-doc-forming-gds.road-tax-base
                            bufnew_price-list.price-sale =  b_price-doc-forming-gds.price-sale-base
                            bufnew_price-list.price-calc =  b_price-doc-forming-gds.price-calc-base
                            bufnew_price-list.price-prev =  b_price-doc-forming-gds.price-prev-base
                          .
                          else assign
                            bufnew_price-list.road-tax   =  b_price-doc-forming-gds.road-tax-rubl
                            bufnew_price-list.price-sale =  b_price-doc-forming-gds.price-sale-rubl
                            bufnew_price-list.price-calc =  b_price-doc-forming-gds.price-calc-rubl
                            bufnew_price-list.price-prev =  b_price-doc-forming-gds.price-prev-rubl
                          .
                      end.
                  if available b_price-doc then do:
                      b_price-all.out-code   =  b_price-doc.doc-num .
                  end.
           end.
        end.
  end.
  p-list-recid = trim (p-list-recid, "," ) .
end.
end procedure. /* create-price-list-mpl */

procedure proc-mpl-create-price-all :
DEFINE PARAMETER BUFFER b_price-list-type FOR ub.price-list-type         .
DEFINE PARAMETER BUFFER b_price-doc-forming FOR ub.price-doc-forming      .
define input  parameter v-curr-obj-date as date   no-undo .
define input  parameter p-main                   as integer   no-undo .
define input  parameter p-plt-id                 as integer   no-undo .
define input  parameter p-plt-db-num             as integer   no-undo .
define input  parameter p-pdf-id                 as integer   no-undo .
define input  parameter p-pdf-db-num             as integer   no-undo .
define input  parameter p-b-code                 as integer   no-undo .
define input  parameter p-gds-code               as integer   no-undo .
define input  parameter p-type-price             as integer   no-undo .
define input  parameter p-qnty-from              like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-qnty-to                like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-sum-from               as decimal   no-undo .
define input  parameter p-sum-to                 as decimal   no-undo .
define input  parameter p-turnover-from          as decimal   no-undo .
define input  parameter p-turnover-to            as decimal   no-undo .
define input  parameter p-fact-order-shift-from  as decimal   no-undo .
define input  parameter p-fact-order-shift-to    as decimal   no-undo .
define input  parameter p-fact-order-sys-from    as decimal   no-undo .
define input  parameter p-fact-order-sys-to      as decimal   no-undo .
define input  parameter p-price-sale             as decimal   no-undo .
define input  parameter p-pay-code               as integer   no-undo .
define input  parameter p-cdpay-code             as integer   no-undo .
define input  parameter p-curr-pay-code          as integer   no-undo .

  do
  on error undo, return error return-value
  :
         create ub.price-all.
         assign
            ub.price-all.main-indication           = p-main
            ub.price-all.status_                   = if b_price-list-type.main = false then {&act-overvalue} else ""
            ub.price-all.type-price                = p-type-price
            ub.price-all.pal-db-num                = v-cntxt-db-num
            ub.price-all.pal-id                    = next-value ( s-pal , {&db-name_schema} )
            ub.price-all.b-code                    = p-b-code
            ub.price-all.gds-code                  = p-gds-code
            ub.price-all.obj-code                  = x_obj-group.obj-code
            ub.price-all.obj-type                  = x_obj-group.obj-TYPE
            ub.price-all.bgr-db-num                = b_price-list-type.bgr-db-num
            ub.price-all.bgr-id                    = b_price-list-type.bgr-id
            ub.price-all.curr-code                 = b_price-list-type.curr-code
            ub.price-all.pdf-id                    = p-pdf-id
            ub.price-all.pdf-db                    = p-pdf-db-num
            ub.price-all.pdf-base-rate             = b_price-doc-forming.base-rate
            ub.price-all.pdf-base-scale            = b_price-doc-forming.base-scale
            ub.price-all.pdf-exch-rate             = b_price-doc-forming.exch-rate
            ub.price-all.pdf-exch-scale            = b_price-doc-forming.exch-scale
            ub.price-all.plt-id                    = p-plt-id
            ub.price-all.plt-db-num                = p-plt-db-num
            ub.price-all.plt-fix-cource-crc-base   = b_price-list-type.fix-cource-crc-base
            ub.price-all.plt-fix-cource-crc-doc    = b_price-list-type.fix-cource-crc-doc
            ub.price-all.plt-priority              = b_price-list-type.priority
            ub.price-all.plt-work-date             = b_price-list-type.work-date
            ub.price-all.qnty-from                 = p-qnty-from
            ub.price-all.qnty-to                   = p-qnty-to
            ub.price-all.sum-from                  = p-sum-from
            ub.price-all.sum-to                    = p-sum-to
            ub.price-all.turnover-from             = p-turnover-from
            ub.price-all.turnover-to               = p-turnover-to
            ub.price-all.tog-db-num                = b_price-list-type.tog-db-num
            ub.price-all.tog-id                    = b_price-list-type.tog-id
            ub.price-all.use-cash-pay              = b_price-list-type.use-cash-pay
            ub.price-all.use-pay-type              = b_price-list-type.use-pay-type
            ub.price-all.price-sale                = p-price-sale

            ub.price-all.start-date                =  if b_price-list-type.main = true then  v-curr-obj-date else b_price-doc-forming.start-date
            ub.price-all.start-shift-date          =  b_price-doc-forming.start-shift-date
            ub.price-all.start-shift-name          =  b_price-doc-forming.start-shift-name
            ub.price-all.start-shift-num           =  b_price-doc-forming.start-shift-num
            ub.price-all.start-sys-date            =  b_price-doc-forming.start-sys-date
            ub.price-all.start-sys-time            =  b_price-doc-forming.start-sys-time
            ub.price-all.end-date                  =  b_price-doc-forming.end-date
            ub.price-all.end-shift-date            =  b_price-doc-forming.end-shift-date
            ub.price-all.end-shift-name            =  b_price-doc-forming.end-shift-name
            ub.price-all.end-shift-num             =  b_price-doc-forming.end-shift-num
            ub.price-all.end-sys-date              =  b_price-doc-forming.end-sys-date
            ub.price-all.end-sys-time              =  b_price-doc-forming.end-sys-time

            ub.price-all.fact-order-shift-from     = p-fact-order-shift-from
            ub.price-all.fact-order-shift-to       = p-fact-order-shift-to
            ub.price-all.fact-order-sys-from       = p-fact-order-sys-from
            ub.price-all.fact-order-sys-to         = p-fact-order-sys-to
            ub.price-all.pay-code      = p-pay-code
            ub.price-all.cdpay-code    = p-cdpay-code
            ub.price-all.curr-pay-code = p-curr-pay-code
            ub.price-all.extra-pcnt            = ?
            ub.price-all.extra-round           = ?
            ub.price-all.work-acc-price        = ?
            no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка при создании таблицы цен для товара бар-код &5 на объекте &1 &2 &3 &4" , x_obj-group.obj-type , x_obj-group.obj-code, error-status :get-message(1) , return-value, p-b-code )).
            end.
  end.

end procedure. /* proc-mpl-create-price-all */