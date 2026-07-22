block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ordopcls.p $
$Archive: cus/ordopcls.p $

Переход по графу статусов заказы ОП

Автор: Комаров Иван Сергеевич
Дата создания: 05/11/11
Author: Ivan Komarov
Creation date: 05/11/11

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-rec as recid no-undo .
define input  parameter p-ask as logical no-undo .   /* задавать вопросы или молча=false */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordopcls.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordopcls.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов заказы покупателей" .
{ cmp/vssrevis.i }
{ cmp/df-sub.i   }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable g#report-num as integer   no-undo .
run get-report-num in parParentProc ( output g#report-num ).

define  buffer buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer buf_contract   for ub.contract.

define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
.

define variable sum-ord    like ub.ord-line.qnty   no-undo .
define variable sum-rcv    like ub.ord-line.qnty   no-undo .
define variable sum-trn    like ub.ord-line.qnty   no-undo .
define variable old-state  like ub.ord-doc.status_ no-undo .
define variable old-flag   like ub.ord-doc.flag_   no-undo .

define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-param-type      as character  no-undo .
define variable v-tth             as handle     no-undo .

define stream  errStream  .

define variable v-log as logical   no-undo .
 /*-------------------------------------------------------------*/

 { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
 find first buf_ord-doc exclusive-lock
 where recid (buf_ord-doc) = p-rec  no-error.
 assign
  old-state = buf_ord-doc.status_
  old-flag  = buf_ord-doc.flag_
  .

  if buf_ord-doc.ship-date = ? then do:
      if p-ask then
      Message "Не задана дата заказа ! "
      skip
      "Документ" buf_ord-doc.doc-code skip
      view-as alert-box error .
      return.
  end.

  if buf_ord-doc.transport-contract  <> 0 and buf_ord-doc.transport-contract  <> ? then do:
    find first buf_contract no-lock where
                buf_contract.host-code     =  buf_ord-doc.transport-host-code and
                buf_contract.contract-code =  buf_ord-doc.transport-contract no-error .
    if not available buf_contract then do:
        message
          "Неверно задан договор грузоперевозчика" skip
          "Грузоперевозчик: " buf_ord-doc.transport-host-code      skip
          "Договор:         " buf_ord-doc.transport-contract  skip
          view-as alert-box error
        .
        return error  .
        end.
  end.


  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .

  run cur-time in this-procedure ( output  t-date , output  t-time ).

  if can-find
    ( first t-doc-line no-lock where
            t-doc-line.doc-code = buf_ord-doc.doc-code and
          ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
      if p-ask then
      Message "В заказе есть строки с количеством равным 0 или ? ! "
      skip
      "Документ" buf_ord-doc.doc-code skip
      view-as alert-box error .
      return.
  end.
 case buf_ord-doc.status_ :
        when {&ord-close}
        or when {&ord-rcv}
        then do :

            /* проверка и закрытие поставки по накладной*/
            for each t-ord-doc-rcv exclusive-lock
               where t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code
                 and t-ord-doc-rcv.status_ = {&ord-rcv}
                      :
              assign          /* сверка количеств по поставке и накладной */
                sum-rcv = 0
                sum-trn = 0
                .
              for each t-doc-line-rcv no-lock
                 where t-doc-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                  and  t-doc-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                        :
                for each ub.ord-chain no-lock
                   where ub.ord-chain.doc-code     = t-doc-line-rcv.rcv-code
                     and ub.ord-chain.doc-type     = 'rcv'
                     and ub.ord-chain.rel-doc-type = 'trn'
                        :
                 find first t-trn-doc no-lock
                    where t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code
                      and t-trn-doc.status_   = {&fact}
                      and t-trn-doc.doc-type  = {&income}
                      and t-trn-doc.internal  = false
                        no-error.
                      if not available  t-trn-doc then next .
                        for each t-trn-line no-lock
                           where t-trn-line.doc-code  = t-trn-doc.doc-code
                             and t-trn-line.artic     = t-doc-line-rcv.artic
                             and t-trn-line.prod-type = t-doc-line-rcv.prod-type
                             and t-trn-line.prod-code = t-doc-line-rcv.prod-code
                             :
                            assign sum-trn = sum-trn + t-trn-line.fact-qnty.
                        end.
                end.
                assign sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
              end.

              /*найдена поставка, в статусе поставка,   */
              if sum-trn >= sum-rcv /*покрытая накладной*/
              and sum-rcv <> 0
              then do:
                assign
                  t-ord-doc-rcv.status_   = {&fact}
                  t-ord-doc-rcv.fact-date = to-day
                .
              end.
            end.


          /* проверка на закрытие - все ли накладные закрыты до факта*/
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = buf_ord-doc.doc-code no-lock :
              for each ub.ord-chain no-lock
                 where ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code
                   and ub.ord-chain.doc-type = 'rcv'
                   and ub.ord-chain.rel-doc-type = 'trn'
                     :
                for each t-trn-doc no-lock
                   where t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code
                     and t-trn-doc.doc-type  = {&income}
                     and t-trn-doc.status_  <> {&fact}
                      :

                  if p-ask then
                  message "Документ ПН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте ПН до статуса ФАКТ " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return.
                 end.
              end.
            end.

         assign          /* сверка количеств по заказу и поставке */
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
          .
           for each t-doc-line no-lock
              where t-doc-line.doc-code = buf_ord-doc.doc-code
               :
              for each t-doc-line-rcv no-lock
                where t-doc-line-rcv.doc-code  = t-doc-line.doc-code
                  and t-doc-line-rcv.artic     = t-doc-line.artic
                  and t-doc-line-rcv.prod-type = t-doc-line.prod-type
                  and t-doc-line-rcv.prod-code = t-doc-line.prod-code,
                    first t-doc-rcv no-lock
                    where t-doc-line-rcv.doc-code = t-doc-rcv.doc-code
                     and  t-doc-line-rcv.rcv-code = t-doc-rcv.rcv-code
                        :

                for each ub.ord-chain no-lock
                   where ub.ord-chain.doc-code     = t-doc-line-rcv.rcv-code
                     and ub.ord-chain.doc-type     = 'rcv'
                     and ub.ord-chain.rel-doc-type = 'trn'
                        :
                 find first t-trn-doc no-lock
                    where t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code
                      and t-trn-doc.status_   = {&fact}
                      and t-trn-doc.doc-type  = {&income}
                      and t-trn-doc.internal  = false
                        no-error.
                      if not available  t-trn-doc then next .
                        for each t-trn-line no-lock
                           where t-trn-line.doc-code  = t-trn-doc.doc-code
                             and t-trn-line.artic     = t-doc-line-rcv.artic
                             and t-trn-line.prod-type = t-doc-line-rcv.prod-type
                             and t-trn-line.prod-code = t-doc-line-rcv.prod-code
                             :
                            assign sum-trn = sum-trn + t-trn-line.fact-qnty.
                        end.
                end.
                assign sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
              end.
              assign sum-ord = sum-ord + t-doc-line.qnty.
           end.

           if sum-trn = 0  then do:
              v-log = false .
              if p-ask then
                message "Заказ " buf_ord-doc.doc-code " не имеет внешней ПН !" skip
                "Закрыть в статус (ФАКТ-) ? " skip
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .

              if not v-log then return.
              assign buf_ord-doc.flag_ = false .
           end.
          run adm/shattri.p ( input "get":U
                            , input  buf_ord-doc.obj-type
                            , input  buf_ord-doc.obj-code
                            , input  {&attr-ord-obj}
                            , input  {&attr-ord-obj_ord-comp-prc}
                            , output v-value-character
                            , output v-value-date
                            , output v-value-decimal
                            , output v-value-integer
                            , output v-value-logical
                            , output v-param-type
                            , input-output table-handle v-tth
                            ) no-error .
           if  sum-ord > sum-trn 
           then do:
                v-log = false .
                if p-ask then
                  message  "Заказ "  buf_ord-doc.doc-code " не покрыт внешней ПН полностью !" skip
                    "Закрыть в статус (ФАКТ-) ? " skip
                    "Сумма заказа               " sum-ord skip
                    "Сумма накладной            " sum-trn
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть заказ"
                    update v-log
                  .
                else do:
                  if  v-value-decimal <> 0  and v-value-decimal <> ?
                    and v-value-decimal * sum-ord / 100.0 <= sum-trn
                  then assign v-log = yes.
                  else assign v-log = no.
                end.
                if not v-log then return.
                buf_ord-doc.flag_ = false .
           end.
           if  sum-ord =  sum-trn then do:
                buf_ord-doc.flag_ = true  .
           end.
           if  sum-ord <  sum-trn then do:
                  v-log = false .
                  if p-ask then

                message "На  Заказ"  buf_ord-doc.doc-code " превышено количество по ПН !" skip
                  "Закрыть в статус (ФАКТ+) ? " skip
                  sum-ord skip
                  sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .

                if not v-log then return.

                buf_ord-doc.flag_ = true  .
           end.
           assign
              buf_ord-doc.status_ = {&fact}
              buf_ord-doc.fact-date = to-day
           .

           for each t-ord-doc-rcv exclusive-lock
              where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code
                and t-ord-doc-rcv.status_ <> {&fact}
               :
              for each ub.ord-chain no-lock
                 where ub.ord-chain.doc-code     = t-ord-doc-rcv.rcv-code
                   and ub.ord-chain.doc-type     = 'rcv'
                   and ub.ord-chain.rel-doc-type = 'trn'
                    :
                 for each t-trn-doc no-lock
                    where t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code
                      and t-trn-doc.doc-type  = {&income}
                      and t-trn-doc.status_   = {&fact}  :
                        assign
                          t-ord-doc-rcv.status_   = {&fact}
                          t-ord-doc-rcv.fact-date = to-day
                        .
                 end.
              end.
           end.
      end.
 end case.