block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcv-clos.p $
$Archive: cus/rcv-clos.p $

Закрытие поставок

Автор: Чернова Светлана Александровна
Дата создания: 10/07/05
Author: Svetlana Chernova
Creation date: 10/07/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcv-clos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/rcv-clos.p $":U .
define variable vss-description as character no-undo init "Закрытие поставок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ cus/str-edi.i  }
{ cus/ord-outp.i def }

define input parameter parparentproc  as widget-handle no-undo .
define input parameter p-rcv-doc-code as character no-undo . /* Номер поставки */
define input parameter p-auto-ord     as logical   no-undo .  /* нужно ли автоматом закрыть и заказ по поставке */
define input parameter p-store-type   as character no-undo .  /* текущий объект , где закрывается поставка */
define input parameter p-store-code   as integer   no-undo .  /* текущий объект  */
define input parameter p-ask          as logical   no-undo . /* задавать вопросы или молча=false */

define buffer buf_ord-doc      for ub.ord-doc      .
define buffer bufs_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer t-trn-line       for ub.doc-line     .
define buffer buf_contract     for ub.contract  .
define variable sum-trn like ub.doc-line.fact-qnty.
define variable sum-rcv like ub.ord-line-rcv.qnty.
define variable t-sum   like ub.ord-line-rcv.qnty.
define variable v-log   as   logical   no-undo .
define variable to-day  as   date      no-undo .
define variable v-Ok    as   logical   no-undo .
define variable v-mess  as   character no-undo .
define variable v-erase as   logical   no-undo .

{ gbl/curobjdt.i p-store-type p-store-code to-day }

/* Проверка на активный объект */
define variable v-obj-active  as character no-undo .
{ gbl/objat.i
  p-store-type
  p-store-code
  'active=request':u
  v-obj-active
  }

find first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code = p-rcv-doc-code no-error .
if error-status :error then return error-status :get-message (1)  .


  /* проверка АМ и ИЖТ */
  if bufs_ord-doc-rcv.obj-type = {&shop} or bufs_ord-doc-rcv.obj-type = {&stock} then do:
      for each ub.ord-line-rcv no-lock where
              ub.ord-line-rcv.rcv-code = bufs_ord-doc-rcv.rcv-code and
              ub.ord-line-rcv.doc-code = bufs_ord-doc-rcv.doc-code :
        { gbl/goassizt.i
          'rcv'
          ub.ord-line-rcv.gds-code
          bufs_ord-doc-rcv.obj-type
          bufs_ord-doc-rcv.obj-code
          false
          v-Ok
          v-mess
          no-error }
            if v-Ok = false then do:
            run creat-tt (ub.ord-line-rcv.gds-code , v-mess ) .
            v-erase = true.
          end.
      end.
      if v-erase then do:
          run view-exept-gds ( substitute("В поставке есть некорректные линии !&1Просмотреть список ?", {&new-line})) .
                return.
            end.
      end.
  if bufs_ord-doc-rcv.cli-type = {&shop} or bufs_ord-doc-rcv.cli-type = {&stock} then do:
      for each ub.ord-line-rcv no-lock where
              ub.ord-line-rcv.rcv-code = bufs_ord-doc-rcv.rcv-code and
              ub.ord-line-rcv.doc-code = bufs_ord-doc-rcv.doc-code :
        { gbl/goassizt.i
          'cli_rcv'
          ub.ord-line-rcv.gds-code
          bufs_ord-doc-rcv.cli-type
          bufs_ord-doc-rcv.cli-code
          false
          v-Ok
          v-mess
          no-error }
            if v-Ok = false then do:
            run creat-tt (ub.ord-line-rcv.gds-code , v-mess ) .
            v-erase = true.
          end.
      end.
      if v-erase then do:
          run view-exept-gds ( substitute("В поставках есть некорректные линии !&1Просмотреть список ?", {&new-line})) .
                return.
            end.
      end.

find first buf_ord-doc no-lock where buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code no-error .

if available buf_ord-doc and buf_ord-doc.doc-type = {&o-o} then return.

  if available bufs_ord-doc-rcv then do:
      for each ub.ord-line-rcv no-lock
         where ub.ord-line-rcv.rcv-code = bufs_ord-doc-rcv.rcv-code
           and ub.ord-line-rcv.doc-code = bufs_ord-doc-rcv.doc-code
           and ub.ord-line-rcv.qnty     = 0
           :
            run creat-tt (ub.ord-line-rcv.gds-code , "Нулевое количество по строке ! " ) .
            v-erase = true.
      end.
      if v-erase then do:
          run view-exept-gds ( substitute("В поставках есть нулевые количества в строках !&1Просмотреть список ?", {&new-line})) .
          return.
                      end.

     if available buf_ord-doc then do:
      if buf_ord-doc.doc-type = {&f-p} then do:
          if  g#db-num <> 0  and v-obj-active <> "yes" and   bufs_ord-doc-rcv.status_ = {&g___new}  then do:
              return error  substitute (
              "Поставку № &1  &2   нельзя закрыть на неактивном объекте УБД ." , bufs_ord-doc-rcv.rcv-code ,bufs_ord-doc-rcv.status_ ) .
          end.
      end.
   end.


   find first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code = p-rcv-doc-code no-error .
            if avail bufs_ord-doc-rcv then do:
               if p-ask then  do:
                  message "Закрыть поставку "  bufs_ord-doc-rcv.rcv-code "?" view-as alert-box
                            question buttons yes-no title "Вопрос" update v-log.
                end.
                else v-log = true .

                    if v-log then do:
                       find current bufs_ord-doc-rcv exclusive-lock no-error.
                          case bufs_ord-doc-rcv.status_:
                          when {&g___new} then do:

                            /* проверка признаков */
                                for each ub.ord-line-rcv where
                                    ub.ord-line-rcv.rcv-code = bufs_ord-doc-rcv.rcv-code and
                                    ub.ord-line-rcv.doc-code = bufs_ord-doc-rcv.doc-code  :
                                  t-sum = 0.
                                  for each ub.ord-dtl-rcv where
                                      ub.ord-dtl-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and
                                      ub.ord-dtl-rcv.doc-code  = ub.ord-line-rcv.doc-code  and
                                      ub.ord-dtl-rcv.artic     = ub.ord-line-rcv.artic and
                                      ub.ord-dtl-rcv.prod-type = ub.ord-line-rcv.prod-type and
                                      ub.ord-dtl-rcv.prod-code = ub.ord-line-rcv.prod-code  :
                                      t-sum = t-sum + ub.ord-dtl-rcv.qnty.
                                  end.
                                  if t-sum > ub.ord-line-rcv.qnty then do:
                                      return error substitute  ("Количество по признакам больше чем по строке товара !  &1  &2 ", ub.ord-line-rcv.artic,t-sum ) .
                                  end.
                                end.

                            Assign
                              bufs_ord-doc-rcv.status_   = {&ord-rcv}
                              .
                          end.
                          when {&ord-rcv} then do:
                                  if  v-obj-active <> "yes"  then do :
                                      return error "Закрыть до факта можно только на АКТИВНОМ объекте!!!" .
                                  end.
                                /* проверка на закрытие */
                          for each ub.ord-chain no-lock where
                                    ub.ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and
                                    ub.ord-chain.doc-type = 'rcv'                  and
                                    ub.ord-chain.rel-doc-type = 'trn'
                                    :

                                for each ub.trn-doc no-lock where
                                          ub.trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                                          ub.trn-doc.status_   <> {&fact}
                                          :
                                  return error substitute  ("Документ ПН  &1  имеет статус  &2 , закрыть поставку до статуса ФАКТ невозможно ! Закройте ПН до статуса ФАКТ " , ub.trn-doc.doc-code , CAPS (ub.trn-doc.status_)).
                                end.

                                for each ub.trn-doc no-lock where
                                        ub.trn-doc.out-code  = ub.ord-chain.rel-doc-code and
                                        ub.trn-doc.status_   = {&fact} and
                                        ub.trn-doc.doc-type  <> {&income} and
                                        ub.trn-doc.doc-type  <> {&inventory}
                                        :
                                  return error substitute  ( "Документ РН  &1 не имеет парной ПН ! Сформируйте ПН и закройте ее до статуса ФАКТ " , ub.trn-doc.out-code ).
                                end.
                            end.
                      assign
                          sum-trn = 0
                          sum-rcv = 0
                      .
                      for each  buf_ord-line-rcv where buf_ord-line-rcv.doc-code = bufs_ord-doc-rcv.doc-code and
                                                       buf_ord-line-rcv.rcv-code = bufs_ord-doc-rcv.rcv-code no-lock :
                      for each ub.ord-chain no-lock where
                                ub.ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and
                                ub.ord-chain.doc-type = 'rcv'                  and
                                ub.ord-chain.rel-doc-type = 'trn'
                                :
                        for each  t-trn-line where
                                  t-trn-line.doc-code = ub.ord-chain.rel-doc-code and
                                  buf_ord-line-rcv.artic      = t-trn-line.artic        and
                                  buf_ord-line-rcv.prod-type  = t-trn-line.prod-type   and
                                  buf_ord-line-rcv.prod-code  = t-trn-line.prod-code  no-lock :

                              sum-trn = sum-trn + t-trn-line.fact-qnty.
                          end.
                          end.
                          sum-rcv = sum-rcv + buf_ord-line-rcv.qnty.
                      end.
                    bufs_ord-doc-rcv.flag_ = true .
                    if  sum-trn = 0  then do:
                        if p-ask then do:
                            message  "Поставка"  bufs_ord-doc-rcv.rcv-code " не имеет ПН (или полностью ей не соответствует) ! Закрыть в статус  (ФАКТ-) ? "
                              view-as alert-box question
                              buttons yes-no
                              title "Закрыть поставку "
                              update v-log
                            .
                            if not v-log then return.
                        end.
                        else do:
                          v-log = false .
                          return error substitute ( "Поставка  &1  не имеет ПН (или полностью ей не соответствует) ! " , bufs_ord-doc-rcv.rcv-code).
                        end.
                        bufs_ord-doc-rcv.flag_ = false .
                    end.

                    if  sum-rcv > sum-trn then do:
                        if p-ask then do:
                            message  " Поставка "  bufs_ord-doc-rcv.rcv-code
                             "не покрыта ПН полностью !"
                             "Закрыть в статус  (ФАКТ-) ? "
                              view-as alert-box question
                              buttons yes-no
                              title "Закрыть поставку"
                              update v-log
                            .

                            if not v-log then return.
                        end.
                        else do:
                          v-log = true  .
                        end.
                        bufs_ord-doc-rcv.flag_ = false .
                    end.

                    /* проставим по договору необходимость создания ФО */
                    find first buf_ord-doc no-lock where buf_ord-doc.doc-code =  bufs_ord-doc-rcv.doc-code no-error .
                    if available buf_ord-doc and  buf_ord-doc.contract-code <> 0 then do:
                        find first buf_contract no-lock where
                                  buf_contract.host-code = buf_ord-doc.host-code and
                                  buf_contract.contract-code = buf_ord-doc.contract-code no-error .
                        if available buf_contract and
                             ( buf_contract.usl-opl = {&contr-pay-rcv}
                            or buf_contract.usl-opl = {&contr-pay-rcv-delay}) then do:
                            bufs_ord-doc-rcv.need-fo = 1 .
                            bufs_ord-doc-rcv.cr-fo = no .
                        end.
                    end.

                    Assign
                      bufs_ord-doc-rcv.fact-date = to-day
                      bufs_ord-doc-rcv.status_   = {&fact}
                      .
                  end.
                  when {&fact} then do:
                      return error substitute ( "Поставка  &1  Уже закрыта до факта " , bufs_ord-doc-rcv.rcv-code).
                  end.
                  end case.
           end.
      end.
  end.

  if  p-auto-ord then do:
      if available buf_ord-doc then do:
          run cus/ord-clos.p  (
              input    parparentproc
              ,input   recid (buf_ord-doc)       /* recid  заказа  */
              ,input   p-store-type     /* текущий объект , где закрывается поставка */
              ,input   p-store-code     /* текущий объект  */
              ,input   g#db-num         /*  текущая база данных */
              ,input   false            /* задавать вопросы или молча=false */
              , input  "no" /*p-param-list пока тока один параметр, говорит что edi или не edi*/
              ) no-error .
      end.
  end.