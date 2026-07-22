block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ordoocls.p $
$Archive: cus/ordoocls.p $

Смена статусов у заказов OO  Переход по графу статусов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/22/04 3:32

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-rec as recid no-undo .
define input  parameter p-ask as logical no-undo .   /* задавать вопросы или молча=false */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordoocls.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordoocls.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов" .
{ cmp/vssrevis.i }
{ cmp/df-sub.i   }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cus/ord-outp.i def }

&scop v-screen  ' экран':L
&scop v-printer ' принтер':L
&glob order-type-gbd 2
&glob order-type-ubd 3
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

define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
.

define variable v-num-chip as character no-undo .
define variable  sum-ord like ub.ord-line.qnty no-undo .
define variable  sum-rcv like ub.ord-line.qnty no-undo .
define variable  sum-trn like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream  errStream  .

define variable v-log as logical   no-undo .
define variable v-Ok as logical   no-undo .
define variable v-mess as character no-undo .
define variable g#log as logical   no-undo .
define variable sum-trn1 as decimal   no-undo .
define variable f-TBAGN  as logical   no-undo init false .
define variable v-erase  as logical   no-undo .

 /*----------------------------------------------------------------------------------------------------------------------*/

 { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
 find first buf_ord-doc where recid (buf_ord-doc) = p-rec exclusive-lock no-error.
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
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .

  run cur-time in this-procedure ( output  t-date , output  t-time ).



  if buf_ord-doc.date-sale-1 > buf_ord-doc.date-sale-2 then do:
      if p-ask then
      Message "Не верно задан интервал продаж !  "
      skip
      "Документ" buf_ord-doc.doc-code skip
      view-as alert-box error .
      return.
  end.


  for each t-doc-line no-lock
     where t-doc-line.doc-code  = buf_ord-doc.doc-code
       and ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)
       :
          run creat-tt (t-doc-line.gds-code , substitute("В заказе есть строки с количеством равным 0 или ? ! Документ &1", buf_ord-doc.doc-code )) .
          v-erase = true.
  end.
  if v-erase then do:
      if p-ask then do:
        run view-exept-gds ( substitute("В заказе есть строки с количеством равным 0 или ? ! !&1Просмотреть список ?", {&new-line})) .
        return.
      end.
      else do:
        return.
      end.
  end.

  /* проверка АМ и ИЖТ */
    if  buf_ord-doc.status_ = {&ord-req} and
        buf_ord-doc.status_ = {&g___new} then do:
      for each ub.ord-line no-lock where
              ub.ord-line.doc-code = buf_ord-doc.doc-code :
        { gbl/goassizt.i
          buf_ord-doc.doc-type
          ub.ord-line.gds-code
          buf_ord-doc.obj-type
          buf_ord-doc.obj-code
          false
          v-Ok
          v-mess
          no-error }
            if v-Ok = false then do:
                run creat-tt (ub.ord-line.gds-code , v-mess ) .
                v-erase = true.
            end.
      end.
      if v-erase then do:
          if p-ask then do:
            run view-exept-gds ( substitute("В заказе есть некорректные линии !&1Просмотреть список ?", {&new-line})) .
            return.
          end.
          else do:
                return.
            end.
      end.
    end.


 case buf_ord-doc.status_ :
      when {&ord-rejection} then do :
        if p-ask then
        Message
          "Нельзя закрыть заказ"
          "в статусе " caps(buf_ord-doc.status_)
          skip
          "Документ" buf_ord-doc.doc-code view-as alert-box information

          .
        return.
      end.
      when {&g___new} then do :
        /*НОВЫЙ-  -- > НОВЫЙ+ */
        if buf_ord-doc.flag_ = false  then do:
            for each ub.ord-line no-lock where
                    ub.ord-line.doc-code = buf_ord-doc.doc-code :
                if (ub.ord-line.cli-qnty * ub.ord-line.cli-base-rate <> ub.ord-line.qnty) then do:
                  run creat-tt (ub.ord-line.gds-code ,
                      substitute (
                      " Документ &1, По товару неправильное соотношение количеств в единицах поставщика &2 &8 (коэфф.&3)  и в базовых единицах измерения &4 ! Товар &5 &6&7",
                      buf_ord-doc.doc-code ,
                      ub.ord-line.cli-qnty ,
                      ub.ord-line.cli-base-rate ,
                      ub.ord-line.qnty  ,
                      ub.ord-line.artic ,
                      ub.ord-line.prod-type ,
                      ub.ord-line.prod-code ,
                      ub.ord-line.unit-cli )) .
                  v-erase = true.
                end.
            end.
            if v-erase then do:
                if p-ask then do:
                  run view-exept-gds ( substitute("В заказе есть некорректные линии !&1Просмотреть список ?", {&new-line})) .
                  return.
                end.
                else do:
                   return .
                end.
            end.

              if buf_ord-doc.ship-date < t-date then do:
                  g#log  = false .
                  if p-ask then
                      Message "Дата заказа меньше текущей даты ! " skip
                          string(buf_ord-doc.ship-date, "99/99/9999" ) skip
                          "Сегодня" string(t-date, "99/99/9999" )
                          skip
                          "Документ" buf_ord-doc.doc-code skip
                        " Будем закрывать ? "
                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть заказ "
                          update g#log
                        .

                  if not g#log then return.
               end.

              /* Проверка на пустой */
              find first  t-doc-line where t-doc-line.doc-code  = buf_ord-doc.doc-code no-lock no-error .
              if not available t-doc-line then do:
                  if p-ask then
                  message   "Заказ"  buf_ord-doc.doc-code  "  не содержит ни одной записи ! "
                  view-as alert-box information
                  title "Внимание!!! "
                .
                  return.
               end.

              /* Проверка на 0 цены */
              for each t-doc-line no-lock
                 where t-doc-line.doc-code  = buf_ord-doc.doc-code
                 and ( t-doc-line.price-rubl <= 0 or t-doc-line.price-rubl = ? )
                 :
                    run creat-tt (t-doc-line.gds-code , substitute("В заказе &1 цена ({&abbr_rub}) на товар &2 не определена ! ", buf_ord-doc.doc-code, t-doc-line.gds-code) ) .
                    v-erase = true.
              end.
              if v-erase then do:
                 if p-ask then do:
                    run view-exept-gds ( substitute("В заказе &2 есть товары с неопределенной ценой ({&abbr_rub}) !&1Просмотреть список ?", {&new-line}, buf_ord-doc.doc-code)) .
                    return.
                 end.
                 else do:
                    return.
                 end.
              end.

              /* Проверка совпадения периода продаж  */
              define variable v_ok as logical no-undo .

              run verif_1 in this-procedure ( output v_ok ) no-error .
              if not v_ok then do:
                  v-log = false .
                  if p-ask then
                  message "В "  (if buf_ord-doc.doc-type  =  {&o-f} then " Заявке " else " Заказе" ) buf_ord-doc.doc-code " есть  повторный заказ на товары в пути ! Закрывать такой документ ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                    update v-log
                  .

                  if not v-log then return.
              end.
          define buffer buf_clients for ub.clients .
          find first buf_clients no-lock where
                     buf_clients.obj-code = buf_ord-doc.obj-code and
                     buf_clients.obj-type = buf_ord-doc.obj-type no-error .

          if v-cntxt-db-num = 0 and
             buf_ord-doc.order-type = {&order-type-ubd}  and
             buf_clients.db-num = 0
          then do:
                  if p-ask then
                  message "В Заказе"  buf_ord-doc.doc-code
                  "Указано распределение по запросам в УБД. "
                  "После закрытия , Заказ будет направлен по СПН и "
                  "дальнейшее закрытие и распределение "
                  "становится невозможным в текущей БД ." skip
                  "Но объект принадлежит главной базе !!!  "
                  "Перенаправьте распределение в ГБД ."
                    view-as alert-box error
                    title "Закрыть заказ "
                  .
                  return.

          end.

          if v-cntxt-db-num = 0 and buf_ord-doc.order-type = {&order-type-ubd} then do:
                  v-log = false .
                  if p-ask then
                  message "В Заказе"  buf_ord-doc.doc-code
                  "Указано распределение по запросам в УБД. "
                  "После закрытия , Заказ будет направлен по СПН и "
                  "дальнейшее закрытие и распределение "
                  "становится невозможным в текущей БД " skip
                  "Закрывать заказ ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть заказ "
                    update v-log
                  .
                  if not v-log then return.

          end.
          if v-cntxt-db-num <> 0 and buf_ord-doc.order-type = {&order-type-gbd} then do:
                  v-log = false .
                  if p-ask then
                  message "В Заказе"  buf_ord-doc.doc-code
                  "Указано распределение по запросам в ГБД. "
                  "После закрытия , Заказ будет направлен по СПН и "
                  "дальнейшее закрытие и распределение "
                  "становится невозможным в текущей БД " skip
                  "Закрывать заказ ? "

                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть заказ "
                    update v-log
                  .
                  if not v-log then return.

          end.


          assign
              buf_ord-doc.status_ = {&g___new}
              buf_ord-doc.flag_ = true
              .
              return.
        end.

        /* НОВЫЙ+   --> в ЗАПРОС- */
        if buf_ord-doc.flag_ = true  then do:

          if v-cntxt-db-num = 0  and buf_ord-doc.order-type = {&order-type-ubd} or
             v-cntxt-db-num <> 0 and buf_ord-doc.order-type = {&order-type-gbd}
          then do:
                  if p-ask then
                  message "В Заказе"  buf_ord-doc.doc-code
                      "Указано распределение по запросам в "  entry ( buf_ord-doc.order-type , " ,ГБД,УБД")
                      "Нельзя перейти в следующий статус в текущей БД !"
                      view-as alert-box information
                      .
                  return .
          end.

          assign
              buf_ord-doc.status_ = {&ord-req}
              buf_ord-doc.flag_ = false
           .
        end.

       end.
       when {&ord-req} then do : /* ЗАПРОС */
        /* ЗАПРОС-   --> в ЗАПРОС+ */
        if buf_ord-doc.flag_ = false   then do:

           if not can-find(first t-ord-doc-rcv no-lock where t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code ) = true
           then do:
            if p-ask then
              message "Закрыть до статуса ЗАПР+ нельзя ! Нет созданных запросов ." skip
                skip
                "Заказ " buf_ord-doc.doc-code skip
                view-as alert-box error .
              return.
           end.


            assign
                buf_ord-doc.status_ = {&ord-req}
                buf_ord-doc.flag_ = true
                .
            /* НОВЫЙ + */
           run cus/ord-shoo.p
              ( parParentProc ,
                recid(buf_ord-doc) ,
                output v-num-chip )
                no-error .
           if error-status :error then
           message vss-workfile vss-revision vss-description skip
                  "Ошибка ord-shoo.p " skip
                   skip
                   error-status :get-message(1) skip
                   return-value skip
                   view-as alert-box error
           .
           buf_ord-doc.out-code = v-num-chip .
          return .
        end.
        if buf_ord-doc.flag_ = true  then do:
          /* проверка на закрытие */
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = buf_ord-doc.doc-code no-lock :
            for each ub.ord-chain no-lock where
                      ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                      ub.ord-chain.doc-type = 'rcv'                  and
                      ub.ord-chain.rel-doc-type = 'trn'
                      :
                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = {&expense} and
                          t-trn-doc.status_  <> {&fact}  :

                  if p-ask then
                  message "Документ РН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте РН до статуса ФАКТ " view-as alert-box error
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
           sum-trn1 = 0
           f-TBAGN = false
          .
           for each t-doc-line     where t-doc-line.doc-code     = buf_ord-doc.doc-code  no-lock :
               for each  t-doc-line-rcv where t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                                         t-doc-line-rcv.artic      = t-doc-line.artic         and
                                         t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                                         t-doc-line-rcv.prod-code  = t-doc-line.prod-code no-lock ,
                 first t-doc-rcv where t-doc-line-rcv.doc-code = t-doc-rcv.doc-code  and
                                       t-doc-line-rcv.rcv-code = t-doc-rcv.rcv-code  no-lock :
                for each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = t-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :
                 find first t-trn-doc no-lock where
                            t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                            t-trn-doc.obj-type  = t-doc-rcv.obj-type and
                            t-trn-doc.obj-code  = t-doc-rcv.obj-code and
                            t-trn-doc.status_     = {&fact}   and
                            ( t-trn-doc.doc-type  = {&expense} or
                              t-trn-doc.doc-type  = {&income}) and
                              t-trn-doc.internal  = true
                              no-error .

                   if not available  t-trn-doc then next .
                   for each  t-trn-line where
                             t-trn-line.doc-code  = t-trn-doc.doc-code          and
                             t-trn-line.obj-code  = buf_ord-doc.obj-code        and
                             t-trn-line.obj-type  = buf_ord-doc.obj-type        and
                             t-trn-line.artic     = t-doc-line-rcv.artic        and
                             t-trn-line.prod-type = t-doc-line-rcv.prod-type    and
                             t-trn-line.prod-code = t-doc-line-rcv.prod-code    no-lock :

                      sum-trn = sum-trn + t-trn-line.fact-qnty.
                      sum-trn1 = sum-trn1 + t-trn-line.fact-qnty.
                   end.
                   end.
                  sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
                end.
                sum-ord = sum-ord + t-doc-line.qnty.
                if t-doc-line.qnty <>  sum-trn1 then  f-TBAGN = true .
                sum-trn1 = 0 .
           end.
            if  sum-trn = 0  then do:
                  v-log = false .
                  if p-ask then
                    message  "Заказ "  buf_ord-doc.doc-code " не имеет внутренних РН/ПН !" skip
                    "Закрыть в статус (ФАКТ-) ? " skip
                      view-as alert-box question
                      buttons yes-no
                      title "Закрыть заказ"
                      update v-log
                    .

                if not v-log then return.
                buf_ord-doc.flag_ = false .
            end.

            if  sum-ord > sum-trn then do:
                  v-log = false .
                  if p-ask then
                message  "Заказ "  buf_ord-doc.doc-code " не покрыт внутренними РН/ПН полностью !" skip
                  "Закрыть в статус (ФАКТ-) ? " skip
                  "Сумма заказа               " sum-ord skip
                  "Сумма накл. перемещения    " sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .

                if not v-log then return.
                buf_ord-doc.flag_ = false .
            end.

            if  sum-ord =  sum-trn  and f-TBAGN = false then do:
                buf_ord-doc.flag_ = true  .
            end.

            if  sum-ord = sum-trn  and f-TBAGN = true then do:
                  v-log = false .
                  if p-ask then
                message "На  Заказ"  buf_ord-doc.doc-code " расходится количество по заказу и накладной по строкам !" skip
                  "Закрыть в статус (ФАКТ-) ? " skip
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .

                if not v-log then return.
                buf_ord-doc.flag_ = false  .
            end.


            if  sum-ord <  sum-trn then do:
                  v-log = false .
                  if p-ask then
                message "На  Заказ"  buf_ord-doc.doc-code " превышено количество по РН/ПН !" skip
                  "Закрыть в статус (ФАКТ-) ? " skip
                  sum-ord skip
                  sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .

                if not v-log then return.
                buf_ord-doc.flag_ = false  .
            end.
            assign
                   buf_ord-doc.status_ = {&fact}
                   buf_ord-doc.fact-date = to-day.
              .
            for each t-ord-doc-rcv   exclusive-lock  where  t-ord-doc-rcv.doc-code     = buf_ord-doc.doc-code :
                for each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :

                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          (t-trn-doc.doc-type  = {&expense} or
                          t-trn-doc.doc-type  = {&income}  )and
                          t-trn-doc.status_   = {&fact}  :
                        assign
                              t-ord-doc-rcv.status_   = {&fact}
                              t-ord-doc-rcv.fact-date = to-day.
                          .
                 end.
                 end.
            end.
       end.
      end.
 end case.



procedure verif_1 :
do
on error undo, return error return-value
:
define output parameter v-ret as logical no-undo .
 v-ret = true .

/* Проверка совпадения периода продаж  */
define buffer later-ord-doc  for  ub.ord-doc  .
define buffer later-ord-line for  ub.ord-line .
define buffer today-ord-line for  ub.ord-line .

define variable v-qnty as decimal no-undo .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .

{ cmp/open-out.i stream  errStream  " " }
v-exis = false .
 for each  temp-obj-list : delete temp-obj-list . end.

define variable str-pos as integer no-undo .
define variable str-pos2 as integer no-undo .
define variable str-1 as character no-undo .
define variable i as integer no-undo .
define variable e1 as character no-undo .
define variable e2 as integer no-undo .
define variable k1 as integer no-undo .

if buf_ord-doc.doc-type = {&f-p} then do:
    k1 = 0 .

    str-pos = index (  buf_ord-doc.e-method , "&" ) .
    str-pos2 = LENGTH ( buf_ord-doc.e-method ) - str-pos .

    str-1 = substring (buf_ord-doc.e-method , str-pos + 1 , str-pos2 ).
    define variable v-nn as integer   no-undo .
    v-nn = num-entries (str-1).
    do i = 1 to v-nn :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
          k1 = k1 + 1.
          create temp-obj-list.
          assign
            temp-obj-list.obj-type = e1
            temp-obj-list.obj-code = e2
          .
    end .

    if k1 < 1 then do :
       /* все объекты фирмы */
       run sss in this-procedure .
    end.
end.
else do:
   create temp-obj-list.
   assign
     temp-obj-list.obj-type = buf_ord-doc.obj-type
     temp-obj-list.obj-code = buf_ord-doc.obj-code
   .
end.


for each today-ord-line where today-ord-line.doc-code = buf_ord-doc.doc-code and today-ord-line.qnty > 0 no-lock :
      v-qnty = 0.
      v-txt  = "" .
        for each later-ord-line where
                                later-ord-line.artic     = today-ord-line.artic     and
                                later-ord-line.prod-type = today-ord-line.prod-type and
                                later-ord-line.prod-code = today-ord-line.prod-code no-lock ,
            each  later-ord-doc where  later-ord-line.doc-code = later-ord-doc.doc-code and
                              ( later-ord-doc.status_ = {&ord-accept} or
                                later-ord-doc.status_ = {&ord-rcv} or
                                later-ord-doc.status_ = {&ord-close}
                                ) and
                                later-ord-doc.doc-code <> today-ord-line.doc-code and

                                ( if buf_ord-doc.cons-code <> "" then
                                   later-ord-doc.cons-code <> buf_ord-doc.cons-code
                                   else
                                   true = true )
                                 and
                                later-ord-doc.date-sale-1 <= buf_ord-doc.date-sale-2  and
                                later-ord-doc.date-sale-2 >= buf_ord-doc.date-sale-1   and
                                later-ord-doc.host-code = buf_ord-doc.host-code   no-lock ,
             each temp-obj-list where temp-obj-list.obj-code = later-ord-doc.obj-code and
                                      temp-obj-list.obj-type = later-ord-doc.obj-type no-lock :
          v-qnty = v-qnty +  later-ord-line.qnty .
          v-txt  = v-txt  + trim( later-ord-line.doc-code) + ";" .
        end.

        if v-qnty > 0 then do:
          find first ub.goods where
                today-ord-line.artic     = ub.goods.artic      and
                today-ord-line.prod-type = ub.goods.prod-type  and
                today-ord-line.prod-code = ub.goods.prod-code  no-lock no-error.
          Put  stream  errStream unformatted
          "По объекту :"  buf_ord-doc.obj-type buf_ord-doc.obj-code  skip
          "По товару :"  today-ord-line.artic       today-ord-line.prod-type       today-ord-line.prod-code skip
          ub.goods.gds-name skip
          "По документам :"    v-txt skip
          "Уже заказано (в пути) :" v-qnty    " "    ub.goods.unit-base   skip
          skip
          "По текущему документу № " buf_ord-doc.doc-code  " кол-во заказа : " today-ord-line.qnty " " ub.goods.unit-base skip
          "Анализируемый период продаж с " buf_ord-doc.date-sale-1 " по " buf_ord-doc.date-sale-2 skip
          "Итого :"  ( v-qnty  + today-ord-line.qnty )   skip
          "--------------------------------------------------------------------"
          skip.
          v-exis = true.
        end.

end. /* foreach */

/* есть err */
if v-exis = true then do:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical no-undo .
     if p-ask then do:

      message
       "При проверке товаров по периоду продаж были обнаружены повторы ! " skip
       "Вы можете просмотреть и распечатать их список . "
        skip
        "Документ" buf_ord-doc.doc-code skip

       view-as alert-box error .

   Output stream errStream   close .
    run gbl/prnfilen.w
      (input  "Повторы, обнаруженные при проверке товаров по периоду продаж"
      ,input  0
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .

       if not ( lookup( {&v-screen}, v-user-action ,";")  > 0 or
                lookup( {&v-printer}, v-user-action ,";")  > 0  ) then do:
                   message "Внимание вы не просмотрели список повторных заказов ! "  .
                end.

      v-ret = false .
      return.
end.
end.

v-ret = true .
return.

end. /* do */
end procedure. /* verif_1 */




procedure sss :

  define variable v-object-available as logical   no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    /* все объекты по фирме g#host-code,
       для всех объектов (если в ГБД) или только по объектам УБД,
       для объектов у которых у пользователя есть права */

    for each buf_clients no-lock
      where buf_clients.host-code = v-cntxt-host-code-obj
        and ( ( buf_clients.db-num = v-cntxt-db-num ) or v-cntxt-db-num = 0 )
    on error undo, return error return-value
    :
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        buf_clients.obj-type
        buf_clients.obj-code
        v-object-available
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры gbl/usobjava.i" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return no-apply .
      end.

      if v-object-available = true
      then do:
        create temp-obj-list.
        assign
          temp-obj-list.obj-type = buf_clients.obj-type
          temp-obj-list.obj-code = buf_clients.obj-code
        .
      end.
    end.
  end.
end procedure. /* sss */