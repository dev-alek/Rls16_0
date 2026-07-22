block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ordorcls.p $
$Archive: cus/ordorcls.p $

Смена статусов у заказов ORC  Переход по графу статусов

Автор: Чернова Светлана Александровна
Дата создания: 04/27/06
Author: Svetlana Chernova
Creation date: 04/27/06

*/

define input parameter parparentproc as handle no-undo .
define input parameter p-rec as recid   no-undo .
define input parameter p-ask as logical no-undo .   /* задавать вопросы или молча=false */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordorcls.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordorcls.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/df-sub.i   }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/cont-ms-def.i }

&scop v-screen  ' экран':L
&scop v-printer ' принтер':L
&glob order-type-gbd 2
&glob order-type-ubd 3
/* message "Смена статусов у заказов ORC" . */
define  buffer buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer obj_clients     for ub.clients .
define  buffer cli_clients     for ub.clients .
define  buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define  buffer buf_trn-doc     for ub.trn-doc .
define  buffer buf_doc-line    for ub.doc-line .
define  buffer buf_ord-line    for ub.ord-line .

define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi obj-type obj-code
.

define variable v-num-chip as character no-undo .
define variable sum-ord like ub.ord-line.qnty no-undo .
define variable sum-rcv like ub.ord-line.qnty no-undo .
define variable sum-trn like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream   errStream  .

define variable v-flaf-n as logical   no-undo .
define variable g#log  as logical   no-undo .
define variable v-Ok as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-event-code as character no-undo .


 /*----------------------------------------------------------------------------------------------------------------------*/
  { gbl/curobjdt.i  v-cntxt-obj-type v-cntxt-obj-code to-day }
 find first buf_ord-doc where recid (buf_ord-doc) = p-rec exclusive-lock no-error.
 if error-status :error then return error 'не найден заказ'.
 assign
  old-state = buf_ord-doc.status_
  old-flag  = buf_ord-doc.flag_
  .


  if buf_ord-doc.ship-date = ? then do:
     if p-ask then
      message "Не задана дата заказа ! "
              skip
              "Документ" buf_ord-doc.doc-code skip
              view-as alert-box error .
      return error.
  end.
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .

  run cur-time in this-procedure (output  t-date , output  t-time ).

  if buf_ord-doc.date-sale-1 > buf_ord-doc.date-sale-2 then do:
     if p-ask then
        message "Не верно задан интервал продаж !  "
                skip
                "Документ" buf_ord-doc.doc-code skip
                view-as alert-box error .
      return error.
  end.

define buffer bf_contract-specif for ub.contract-specif  .

      /* Проверка по договору */
      if buf_ord-doc.contract-code > 0 then do:
/*
          find first bf_contract-specif where bf_contract-specif.host-code    = buf_ord-doc.host-code     and
                                              bf_contract-specif.contract-num = buf_ord-doc.contract-code no-lock no-error.
*/
          {str/cont-slave-inc.i
              &FIND_FIRST = YES
              &BUFFER_SPECIF  = bf_contract-specif
              &P_HOST_CODE    = buf_ord-doc.host-code
              &P_CONTRACT_NUM = buf_ord-doc.contract-code
              &NO_LOCK=YES
              &NO_ERROR=YES
          }

          if available bf_contract-specif then do: /* спецификация есть */
             for each ub.ord-line no-lock where
                      ub.ord-line.doc-code = buf_ord-doc.doc-code :
                if not
/*
                can-find (first bf_contract-specif no-lock where
                                       bf_contract-specif.host-code    = buf_ord-doc.host-code and
                                       bf_contract-specif.contract-num = buf_ord-doc.contract-code and
                                       bf_contract-specif.gds-code     = ub.ord-line.gds-code   )
*/
                Can-Find-Spec  (buf_ord-doc.host-code,
                                buf_ord-doc.contract-code ,
                                ub.ord-line.gds-code)
                then do:
                                          if p-ask then
                                          message
                                            "Выбран Договор со спецификацией !!!" skip
                                            "Несоответствие списка товаров заказа и спецификации " skip
                                            "Заказ      :" buf_ord-doc.doc-code        skip
                                            "код товара :" ub.ord-line.gds-code skip
                                            "артикл     :" ub.ord-line.artic skip
                                            view-as alert-box error .
                                            return error.
                                       end.
             end.
          end.
      end.

/* проверка АМ и ИЖТ  до ЗАПР после бесполезно */
     if buf_ord-doc.status_ = {&g___new}
       then do:
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
              if p-ask then
              message
                v-mess skip
                "Товар не может быть включен в заказ " skip
                "Заказ      :" buf_ord-doc.doc-code        skip
                "код товара :" ub.ord-line.gds-code skip
                "артикул    :" ub.ord-line.artic skip
                view-as alert-box error .
                return error substitute("izt &1" ,v-mess ) .
            end.
            v-event-code = substitute("cli_&1",buf_ord-doc.doc-type) .
          { gbl/goassizt.i
            v-event-code
            ub.ord-line.gds-code
            buf_ord-doc.cli-type
            buf_ord-doc.cli-code
            false
            v-ok
            v-mess
            no-error }
              if v-ok = false then do:
                if p-ask then
                message
                  v-mess skip
                  "Товар не может быть включен в заказ " skip
                  "Заказ      :" buf_ord-doc.doc-code        skip
                  "код товара :" ub.ord-line.gds-code skip
                  "артикул    :" ub.ord-line.artic skip
                  view-as alert-box error .
                  return error substitute("izt &1" ,v-mess ) .
              end.
        end.
  end.

define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .
define variable o-base-code as integer   no-undo .
define variable c-base-code as integer   no-undo .
define variable v-find      as logical   no-undo .

{ gbl/hostcode.i buf_ord-doc.obj-type buf_ord-doc.obj-code o-host-code }
{ gbl/hostcode.i buf_ord-doc.cli-type buf_ord-doc.cli-code c-host-code }
{ gbl/basecode.i o-host-code o-base-code }
{ gbl/basecode.i c-host-code c-base-code }

if o-base-code <> c-base-code then do:
  if p-ask then
  message "Контрагенты имеют разную базовую валюту. Создание заказа не возможно ! " view-as alert-box error .
  return error.
end.

 case buf_ord-doc.status_ :
      when {&ord-rejection} then do:
      if p-ask then
        message
          "Нельзя закрыть заказ"
          "в статусе " caps(buf_ord-doc.status_)
          skip
          "Документ" buf_ord-doc.doc-code view-as alert-box information
          .
        return .
      end.
      when {&g___new} then do:
        /*НОВЫЙ-  -- > ЗАПРОС+ */
              if can-find
                ( first   t-doc-line no-lock where t-doc-line.doc-code  = buf_ord-doc.doc-code    and
                        ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
                  if p-ask then
                      Message "В заказе есть строки с количеством равным 0 или ? ! "
                              skip
                              "Документ" buf_ord-doc.doc-code skip
                              view-as alert-box error .
                  return error.
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
                  message "Заказ"  buf_ord-doc.doc-code  " не содержит ни одной записи ! "
                          view-as alert-box information  title "Внимание!!! " .
                  return.
               end.

              for each buf_ord-line exclusive-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                  buf_ord-line.order-qnty =  buf_ord-line.qnty . /* запомнить сколько заказала АКТИВНАЯ сторона */
              end.
              assign
                  buf_ord-doc.status_ = {&ord-req}
                  buf_ord-doc.flag_ = true
                  .
              return.
        end.

       when {&ord-req} then do : /* ЗАПРОС */
        /* ЗАПРОС+   --> в РАЗРЕШЕНО+- */
        find first obj_clients no-lock where
                   obj_clients.obj-type = buf_ord-doc.obj-type and
                   obj_clients.obj-code = buf_ord-doc.obj-code no-error .
        find first cli_clients no-lock where
                   cli_clients.obj-type = buf_ord-doc.cli-type and
                   cli_clients.obj-code = buf_ord-doc.cli-code no-error .

         if obj_clients.db-num = v-cntxt-db-num  and obj_clients.db-num <> cli_clients.db-num then do:
                  if p-ask then
                  message "Заказ передан на сторону контрагента. Перевод в другой статус невозможен" .
                  return.
         end.

         v-find = false .
         v-flaf-n = true .

          for each buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' ,
              first buf_trn-doc     no-lock where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code :
                for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                    find first buf_doc-line no-lock where
                          buf_doc-line.doc-code  = buf_trn-doc.doc-code and
                          buf_doc-line.artic     = buf_ord-line.artic      and
                          buf_doc-line.prod-type = buf_ord-line.prod-type  and
                          buf_doc-line.prod-code = buf_ord-line.prod-code

                    no-error .
                    if not available buf_doc-line then v-flaf-n = false .
                    else do:
                        if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                    end.
                end.

                v-find = true  .
                leave.
          end.

          if v-find = true then
            assign
                buf_ord-doc.status_ = {&ord-per}
                buf_ord-doc.flag_ = v-flaf-n
                .
          else do:
                if p-ask then
                   message "Расходная Накладная не создана !!!" view-as alert-box information .
                   return.
          end.
          return .
        end.

       when {&ord-per} then do : /* РАЗРЕШЕН */
        /* РАЗРЕШЕН   --> в ОТГРУЖЕНО  */
            find first obj_clients no-lock where
                      obj_clients.obj-type = buf_ord-doc.obj-type and
                      obj_clients.obj-code = buf_ord-doc.obj-code no-error .
            find first cli_clients no-lock where
                      cli_clients.obj-type = buf_ord-doc.cli-type and
                      cli_clients.obj-code = buf_ord-doc.cli-code no-error .

            if obj_clients.db-num = v-cntxt-db-num and obj_clients.db-num <> cli_clients.db-num then do:
                      if p-ask then
                        message "Заказ передан на сторону контрагента. Перевод в другой статус невозможен"  .
                return.
            end.

        /* найдена закрытая накладная */
         define variable v-find2 as logical   no-undo .
         v-find2 = false .
          for each  buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' ,
              first buf_trn-doc     no-lock where
                    buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                    buf_trn-doc.status_ = {&fact}
                    :
              v-find2 = true  .
              leave.
           end.

          if v-find2  = true then do:
             v-find   = false .
             v-flaf-n = true  .

                for each buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ,
                    each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                    and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                    first buf_trn-doc     no-lock where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                                                        buf_trn-doc.status_ = {&fact}
                    :
                      for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                          find first buf_doc-line no-lock where
                                buf_doc-line.doc-code  = buf_trn-doc.doc-code and
                                buf_doc-line.artic     = buf_ord-line.artic      and
                                buf_doc-line.prod-type = buf_ord-line.prod-type  and
                                buf_doc-line.prod-code = buf_ord-line.prod-code

                          no-error .
                          if not available buf_doc-line then v-flaf-n = false .
                          else do:
                              if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                          end.
                      end.

                      v-find = true  .
                      leave.
                end.

            assign
                buf_ord-doc.status_ = {&ord-ship}
                buf_ord-doc.flag_ = v-flaf-n
                .
          end.
          else do:
                if p-ask then
                   message "Приходная Накладная не создана !!!" view-as alert-box information .
                   return.
          end.
          return .
        end.
       when {&ord-ship} then do : /* ОТГРУЖЕНО */
        /* ОТГРУЖЕНО   --> в ФАКТ  */
          /* проверка на закрытие */

            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :

                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = {&income} and
                          t-trn-doc.status_  <> {&fact}  :
                  if p-ask then
                  message "Документ ПН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте ПН до статуса ФАКТ " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return error.
                 end.
            end.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :

                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = {&expense} and
                          t-trn-doc.status_  <> {&fact}  :
                  if p-ask then
                  message "Документ РН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте РН до статуса ФАКТ (создайте ПН) " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return error.
                 end.
            end.
            end.

            v-flaf-n = true .
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn' :

                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = {&income} and
                          t-trn-doc.status_  = {&fact}  :
                    for each buf_ord-line no-lock where buf_ord-line.doc-code = buf_ord-doc.doc-code :
                        find first buf_doc-line no-lock where
                                   buf_doc-line.doc-code  = t-trn-doc.doc-code and
                                   buf_doc-line.artic     = buf_ord-line.artic      and
                                   buf_doc-line.prod-type = buf_ord-line.prod-type  and
                                   buf_doc-line.prod-code = buf_ord-line.prod-code
                                   no-error .
                        if not available buf_doc-line then v-flaf-n = false .
                        else do:
                            if buf_doc-line.fact-qnty <> buf_ord-line.qnty then  v-flaf-n = false .
                        end.
                    end.
                 end.
              end.
            end.
            assign
              buf_ord-doc.status_ = {&fact}
              buf_ord-doc.flag_   = v-flaf-n
              buf_ord-doc.fact-date = to-day.
            .
            for each t-ord-doc-rcv   exclusive-lock  where  t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code :
                assign
                  t-ord-doc-rcv.status_   = {&fact}
                  t-ord-doc-rcv.fact-date = to-day
                .
            end.
          return .
        end.
 end case.