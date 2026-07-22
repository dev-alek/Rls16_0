block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: consstat.p $
$Archive: cus/consstat.p $

Переход по графу статусов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/11/02 1:06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: consstat.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/consstat.p $":u .
define variable vss-description as character no-undo init "Переход по графу статусов   ".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: consstat.p $ $Revision: aea5316774be, 0, rls $".

{ cmp/trg-def.i      }
{ cmp/df-sub.i       }
{ gbl/getcntxt.i def }

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-rec          as recid no-undo .

define variable store-type as character no-undo .
define variable store-code  as integer   no-undo .
define variable g#log as logical   no-undo .
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.

define variable  v-ok as logical no-undo .
define buffer t-ord-cons    for ub.ord-cons.

define buffer t-ord-doc for ub.ord-doc.
define buffer t-ord-line for ub.ord-line.

define buffer t-ord-doc-rcv for ub.ord-doc-rcv.
define buffer t-ord-line-rcv for ub.ord-line-rcv.

define buffer t-trn-doc for ub.trn-doc.
define buffer t-trn-line for ub.doc-line.

define variable            sum-ord like ub.ord-gds-cons.sum-qnty no-undo .
define variable            sum-rcv like ub.ord-gds-cons.sum-qnty no-undo .
define variable            sum-trn like ub.ord-gds-cons.sum-qnty no-undo .
define variable            old-flag_ as logical no-undo .


define variable old-state like ub.ord-cons.status_ no-undo .
define variable old-flag like ub.ord-cons.flag_ no-undo .
define variable sum-rcv-in as decimal no-undo .
define variable sum-trn-in as decimal no-undo .




&glob send-to-news-cons if not g#news then do:~
  run str/callnews.p ~
    (input "ord-cons"  ~
    ,input (buffer t-ord-cons:handle) ~
    ) no-error .      ~
  if error-status:error then do: ~
    assign t-ord-cons.flag_ = old-flag  t-ord-cons.status_ = old-state . ~
    message                                                 ~
      vss-workfile vss-revision vss-description skip        ~
      "Ошибка при передаче СЗФП (ord-cons) в новости" skip  ~
      "Возвращает процедура callnews.p" skip                ~
       " - "    error-status :get-message(1) skip           ~
      "Документ" t-ord-cons.cons-code skip                  ~
      view-as alert-box error .                             ~
      return no-apply.                                      ~
  end. end.

&glob send-to-news-ord if not g#news then do:~
  run str/callnews.p ~
    (input "ord-doc"  ~
    ,input (buffer t-ord-doc:handle) ~
    ) no-error .      ~
  if error-status:error then do: ~
    assign t-ord-doc.flag_ = old-flag  t-ord-doc.status_ = old-state . ~
    message                                                ~
      vss-workfile vss-revision vss-description skip       ~
      "Ошибка при передаче СЗФП (ord-doc) в новости" skip  ~
      "Возвращает процедура callnews.p" skip               ~
       " - " error-status :get-message(1) skip             ~
      "Документ" t-ord-doc.doc-code skip                   ~
      view-as alert-box error.                             ~
      return no-apply.                                     ~
  end. end.

&glob send-to-news-rcv if not g#news then do:~
  run str/callnews.p ~
    (input "ord-doc-rcv"  ~
    ,input (buffer t-ord-doc-rcv:handle) ~
    ) no-error .      ~
  if error-status:error then do: ~
    assign t-ord-doc-rcv.flag_ = old-flag  t-ord-doc-rcv.status_ = old-state . ~
    message                                                ~
      vss-workfile vss-revision vss-description skip       ~
      "Ошибка при передаче СЗФП (ord-doc-rcv) в новости" skip            ~
      "Возвращает процедура callnews.p" skip                             ~
      " - " error-status :get-message(1) skip                            ~
      "Документ" t-ord-doc-rcv.rcv-code (t-ord-doc-rcv.doc-code) skip    ~
      view-as alert-box error .                            ~
      return no-apply.                                     ~
  end. end.

/*----------------------------------------------------------------------------------------------------------------------*/
main-block :
do transaction
on error undo main-block, return error
:
{ cmp/df-sub.i pr }
 find first t-ord-cons where recid (t-ord-cons) = p-rec exclusive-lock no-error.
 assign
  old-state = t-ord-cons.status_
  old-flag  = t-ord-cons.flag_
  .

 case t-ord-cons.status_ :
      when {&fact} then do :
         message "СЗФП закрыт до факта ! " view-as alert-box .
         return.
      end.

/*НОВЫЙ - РАСПРЕДЕЛЕНО ------------------------------------------------------------------------------------------------*/
      when {&g___new} then do :
            /*заявки ОФ  = статус ПОСТАВКА */
            message "Закрывать СЗФП до статуса " caps({&ord-alloc}) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .

            if v-ok = false then return.

            for each t-ord-doc   where t-ord-doc.cons-code  = t-ord-cons.cons-code
                                 and   t-ord-doc.doc-type   = {&o-f}  exclusive-lock :
               t-ord-doc.status_ = {&ord-rcv}.
               {&send-to-news-ord}
            end.
            assign
              t-ord-cons.status_ = {&ord-alloc}
              .
              /* передаем документ в новости */
              {&send-to-news-cons}

        end.

/*РАСПРЕДЕЛЕНО - ЗАКРЫТО------------------------------------------------------------------------------------------------*/
       when {&ord-alloc} then do : /* поставка */
            message "Закрывать СЗФП до статуса " caps({&ord-close}) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .

            if v-ok = false then return.

         assign          /* сверка количеств по заказу и поставке */
           sum-ord = 0
           sum-rcv = 0
          .
          /* проверка на закрытие */
           for each t-ord-doc           where
                                             (t-ord-doc.cons-code     = t-ord-cons.cons-code  and  t-ord-doc.doc-type = {&f-p})
                                        and (not ( t-ord-doc.status_ = {&ord-close}   OR
                                              t-ord-doc.status_ = {&fact}))  /* Заказы со статусом закрыто и выше */
                                         no-lock   :
                  message "Заказ 'Фирма поставщик'  " t-ord-doc.doc-code " имеет статус " CAPS(t-ord-doc.status_)
                          ", закрыть СЗФП до статуса ЗАКРЫТО невозможно ! Закройте заказ ФП " t-ord-doc.doc-code
                          "до статуса ЗАКРЫТО " view-as alert-box error Title "Закрытие СЗФП" .

                  return.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.cons-code     = t-ord-cons.cons-code
                                               and NOT ( t-ord-doc-rcv.status_   = {&ord-rcv}
                                                   or t-ord-doc-rcv.status_   = {&ord-req}
                                                   OR  t-ord-doc-rcv.status_   = {&fact} ) no-lock :
                  message "Поставка " t-ord-doc-rcv.rcv-code " имеет статус " CAPS(t-ord-doc-rcv.status_)
                          ", закрыть СЗФП до статуса ЗАКРЫТО невозможно ! Закройте поставку " t-ord-doc-rcv.rcv-code
                          "до статуса ПОСТАВКА " view-as alert-box error  Title "Закрытие СЗФП" .

                  return.
            end.



           for each t-ord-doc           where t-ord-doc.cons-code     = t-ord-cons.cons-code
                                        and  t-ord-doc.doc-type = {&f-p}
                                        and ( t-ord-doc.status_ = {&ord-close}   OR
                                              t-ord-doc.status_ = {&fact})  /* Заказы со статусом закрыто и выше */
                                         no-lock   :
             for each t-ord-line        where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
               for each  t-ord-line-rcv where t-ord-line-rcv.doc-code = t-ord-line.doc-code and
                        t-ord-line-rcv.artic      = t-ord-line.artic         and
                        t-ord-line-rcv.prod-type  = t-ord-line.prod-type   and
                        t-ord-line-rcv.prod-code  = t-ord-line.prod-code  no-lock  ,
                        first  t-ord-doc-rcv where  t-ord-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                                               and  t-ord-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                                               and ( t-ord-doc-rcv.status_   = {&ord-rcv}
                                               OR  t-ord-doc-rcv.status_   = {&fact} )
                                               /*поставки со статусом поставка и выше*/
                        no-lock :

                  sum-rcv = sum-rcv + t-ord-line-rcv.qnty.
                end.
                sum-ord = sum-ord + t-ord-line.qnty.
             end.

            run calc-rcv-in in this-procedure (
                input t-ord-line.artic    ,
                input t-ord-line.prod-type,
                input t-ord-line.prod-code,
                output sum-rcv-in ,
                output sum-trn-in   ) no-error .
                sum-rcv = sum-rcv  + sum-rcv-in.
           end.
           if  sum-rcv = 0 then do:
               message "В Заказе " t-ord-cons.cons-code " не закрыто ни одной внешней поставки ! Закрыть в статус (ЗАКРЫТО-) ? "
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть СЗФП"
                  update g#log
                .
                if not g#log then return.
                t-ord-cons.flag_ = false .
            end.
            if  sum-ord > sum-rcv then do:
                message "Заказ " t-ord-cons.cons-code " не покрыт поставками полностью ! Закрыть в статус (ЗАКРЫТО-) ? "
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть СЗФП"
                  update g#log
                .
                if not g#log then return.
                t-ord-cons.flag_ = false .
            end.

            if  sum-ord =  sum-rcv  and  sum-rcv > 0 then do:
                t-ord-cons.flag_ = true  .
            end.
            if  sum-ord <  sum-rcv then do:
                message "На Заказ " t-ord-cons.cons-code " превышено количество по поставками  ! Закрыть в статус (ЗАКРЫТО+) ? "
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть СЗФП"
                  update g#log
                .
                if not g#log then return.
                t-ord-cons.flag_ = true  .
            end.

            assign
              t-ord-cons.status_ = {&ord-close}
              .
/* для ОФ*/
           for each t-ord-doc where t-ord-doc.cons-code     = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = {&o-f}
                              and not ( t-ord-doc.status_ = {&ord-close}   OR
                                        t-ord-doc.status_ = {&fact})
                               exclusive-lock   :  /* Заявки со статусом <> закрыто и выше */
             sum-ord = 0.
             sum-rcv = 0.
             for each t-ord-line       where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
                  /* поставки все по совокупке и по товару и по объекту */
                  for each  t-ord-doc-rcv where  t-ord-doc-rcv.obj-code  = t-ord-doc.obj-code
                            and t-ord-doc-rcv.obj-type  = t-ord-doc.obj-type
                            and t-ord-doc-rcv.cons-code = t-ord-doc.cons-code
                            no-lock ,
                     each t-ord-line-rcv where t-ord-line-rcv.doc-code = t-ord-doc-rcv.doc-code and
                          t-ord-line-rcv.rcv-code   = t-ord-doc-rcv.rcv-code  and
                          t-ord-line-rcv.artic      = t-ord-line.artic       and
                          t-ord-line-rcv.prod-type  = t-ord-line.prod-type   and
                          t-ord-line-rcv.prod-code  = t-ord-line.prod-code   no-lock :

                          sum-rcv = sum-rcv + t-ord-line-rcv.qnty .


                  end.
                sum-ord = sum-ord + t-ord-line.qnty.
                run calc-rcv-in in this-procedure (
                    input t-ord-line.artic    ,
                    input t-ord-line.prod-type,
                    input t-ord-line.prod-code,
                    output sum-rcv-in ,
                    output sum-trn-in   ) no-error .

                sum-rcv = sum-rcv  + sum-rcv-in.


             end.

            /* проставим статусы заявкам */
            t-ord-doc.status_ = {&ord-close}.
            if  sum-ord > sum-rcv then  t-ord-doc.flag_ = false .
                                  else  t-ord-doc.flag_ = true  .
            if t-ord-cons.flag_ = true then  t-ord-doc.flag_ = true  .
           {&send-to-news-ord}
           end.

          {&send-to-news-cons} /* передаем документ в новости */
      end.

/* ЗАКРЫТО - ФАКТ -------------------------------------------------------------------------------------------------------*/
      when {&ord-close} then do :
          /* проверка на закрытие */
            old-flag_ = t-ord-cons.flag_ .
            message "Закрывать СЗФП до статуса " caps({&fact}) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .

            if v-ok = false then return.
          /* Проверка на активный объект */
              define variable v-obj-active  as character no-undo .
              define variable v-office      as character no-undo .
              { gbl/objat.i
              store-type
              store-code
                'active=request':u
                v-obj-active
              }

              { gbl/currdbat.i
                'office=request':u
                v-office
              }


              if  v-obj-active <> "yes"  then do:
                                message "Закрыть до факта можно только на АКТИВНОМ объекте!!!"
                                        view-as alert-box information              .
                                return.
              end.


           for each t-ord-doc           where t-ord-doc.cons-code     = t-ord-cons.cons-code
                                        and  t-ord-doc.doc-type = {&f-p}
                                        and not ( t-ord-doc.status_ = {&fact})  /* Заказы со статусом закрыто и выше */
                                         no-lock   :
                  message "Заказ 'Фирма поставщик'  " t-ord-doc.doc-code " имеет статус " CAPS(t-ord-doc.status_)
                          ", закрыть СЗФП до статуса ФАКТ невозможно ! Закройте заказ ФП " t-ord-doc.doc-code
                          "до статуса ФАКТ " view-as alert-box error  Title "Закрытие СЗФП" .

                  return.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.cons-code     = t-ord-cons.cons-code
                                               and NOT ( t-ord-doc-rcv.status_   = {&fact} ) no-lock :
                  message "Поставка " t-ord-doc-rcv.rcv-code " имеет статус " CAPS(t-ord-doc-rcv.status_)
                          ", закрыть СЗФП до статуса ФАКТ невозможно ! Закройте поставку " t-ord-doc-rcv.rcv-code
                          "до статуса ФАКТ " view-as alert-box error  Title "Закрытие СЗФП" .

                  return.
            end.

/* сверка количеств по заказу и поставке */
         assign
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
          .
           for each t-ord-doc where t-ord-doc.cons-code = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = {&f-p}
                              and (t-ord-doc.status_ = {&fact})  /* Заказы со статусом факт */
                              no-lock   :
             for each t-ord-line  where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
               for each  t-ord-line-rcv where t-ord-line-rcv.doc-code = t-ord-line.doc-code and
                        t-ord-line-rcv.artic      = t-ord-line.artic     and
                        t-ord-line-rcv.prod-type  = t-ord-line.prod-type and
                        t-ord-line-rcv.prod-code  = t-ord-line.prod-code no-lock  ,
                        first  t-ord-doc-rcv where  t-ord-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                                               and  t-ord-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                                               and (  t-ord-doc-rcv.status_   = {&fact} )
                                               /*поставки со статусом fact */
                        no-lock :
                          for each ub.ord-chain no-lock where
                                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                                   ub.ord-chain.doc-type = 'rcv'                  and
                                   ub.ord-chain.rel-doc-type = 'trn'
                                   :
                            for each  t-trn-line where t-trn-line.doc-code  = ub.ord-chain.rel-doc-code and
                                                       t-trn-line.artic     = t-ord-line-rcv.artic        and
                                                       t-trn-line.prod-type = t-ord-line-rcv.prod-type    and
                                                       t-trn-line.prod-code = t-ord-line-rcv.prod-code
                                                       no-lock  ,
                                     first  t-trn-doc where    t-trn-doc.doc-code  = t-trn-line.doc-code
                                                        and (  t-trn-doc.status_   = {&fact} ) no-lock  :
                                                  /*ПН со статусом fact */
                                sum-trn = sum-trn + t-trn-line.fact-qnty.
                            end.
                          end.

                  sum-rcv = sum-rcv + t-ord-line-rcv.qnty .

                end.
                sum-ord = sum-ord + t-ord-line.qnty.
                run calc-rcv-in in this-procedure (
                    input t-ord-line.artic    ,
                    input t-ord-line.prod-type,
                    input t-ord-line.prod-code,
                    output sum-rcv-in ,
                    output sum-trn-in   ) no-error .

                sum-rcv = sum-rcv  + sum-rcv-in.
                sum-trn = sum-trn  + sum-trn-in.

             end.
           end.

            if  sum-rcv > sum-trn then do:
                message "СЗФП  " t-ord-cons.cons-code " не покрыт ПН полностью ! Закрыть в статус (ФАКТ-) ? " skip
                  "Поставок " sum-rcv              skip
                  "из них Внутренних "  sum-rcv-in skip
                  "Накладных" sum-trn              skip
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть СЗФП"
                  update g#log
                .
                if not g#log then return.
                t-ord-cons.flag_ = false .
            end.
            if  sum-rcv =  sum-trn then do:
                t-ord-cons.flag_ = true  .
            end.
            if  sum-rcv <  sum-trn then do:
                message "На СЗФП  " t-ord-cons.cons-code " превышено количество по ПН ! Закрыть в статус (ФАКТ+) ? "
                  "Поставок " sum-rcv  skip
                  "Накладных" sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть СЗФП"
                  update g#log
                .

                if not g#log then return.

                t-ord-cons.flag_ = true  .
            end.
            assign
                   t-ord-cons.status_ = {&fact}
                   t-ord-cons.fact-date = to-day.
              .
             if old-flag_ = false then t-ord-cons.flag_ = false  .
             if can-find (first t-ord-doc-rcv where t-ord-doc-rcv.cons-code = t-ord-cons.cons-code and t-ord-doc-rcv.flag_ = false no-lock )
                then t-ord-cons.flag_ = false  .


 /* для ОФ */
           for each t-ord-doc where t-ord-doc.cons-code     = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = {&o-f}
                              and not ( t-ord-doc.status_ = {&ord-rejection}   OR
                                        t-ord-doc.status_ = {&fact})
                               exclusive-lock   :  /* Заявки со статусом <> закрыто  */
             sum-ord = 0.
             sum-rcv = 0.
             sum-trn = 0.
             for each t-ord-line       where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
                  /* поставки все по совокупке и по товару и по объекту */
                  for each  t-ord-doc-rcv where  t-ord-doc-rcv.obj-code  = t-ord-doc.obj-code
                            and t-ord-doc-rcv.obj-type  = t-ord-doc.obj-type
                            and t-ord-doc-rcv.cons-code = t-ord-doc.cons-code
                            exclusive-lock   ,
                     each t-ord-line-rcv where
                          t-ord-line-rcv.doc-code   = t-ord-doc-rcv.doc-code and
                          t-ord-line-rcv.rcv-code   = t-ord-doc-rcv.rcv-code and
                          t-ord-line-rcv.artic      = t-ord-line.artic       and
                          t-ord-line-rcv.prod-type  = t-ord-line.prod-type   and
                          t-ord-line-rcv.prod-code  = t-ord-line.prod-code   no-lock :

                            sum-rcv = sum-rcv + t-ord-line-rcv.qnty.
                          for each ub.ord-chain no-lock where
                                   ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                                   ub.ord-chain.doc-type = 'rcv'                  and
                                   ub.ord-chain.rel-doc-type = 'trn'
                                   :
                                    for each  t-trn-line where t-trn-line.doc-code  = ub.ord-chain.rel-doc-code and
                                                        t-trn-line.artic     = t-ord-line-rcv.artic         and
                                                        t-trn-line.prod-type = t-ord-line-rcv.prod-type     and
                                                        t-trn-line.prod-code = t-ord-line-rcv.prod-code
                                                        no-lock ,
                                    first  t-trn-doc where  t-trn-doc.doc-code = t-trn-line.doc-code
                                                      and  t-trn-doc.status_  = {&fact}  no-lock :
                                                      /* ПН со статусом fact */
                                        sum-trn = sum-trn + t-trn-line.fact-qnty.
                                    end.
                            end.

                        /* проставим статусы прставкам */
                        if t-ord-doc-rcv.status_ <> {&fact} then do:
                            t-ord-doc-rcv.status_ = {&fact}.
                            if  sum-rcv > sum-trn  or  ( sum-rcv = sum-trn  and  sum-trn = 0 )  then  t-ord-doc-rcv.flag_ = false .
                                                  else  t-ord-doc-rcv.flag_ = true  .

                            {&send-to-news-rcv}
                        end.

                  end.
                  sum-ord = sum-ord + t-ord-line.qnty.
                run calc-rcv-in in this-procedure (
                    input t-ord-line.artic    ,
                    input t-ord-line.prod-type,
                    input t-ord-line.prod-code,
                    output sum-rcv-in ,
                    output sum-trn-in   ) no-error .

                sum-rcv = sum-rcv  + sum-rcv-in.
                sum-trn = sum-trn  + sum-trn-in.
             end.
            /* проставим статусы заявкам */
            t-ord-doc.status_ = {&fact}.
            if  sum-rcv > sum-trn  or  ( sum-rcv = sum-trn  and  sum-trn = 0 )  then  t-ord-doc.flag_ = false .
                                  else  t-ord-doc.flag_ = true  .
            if t-ord-cons.flag_ = true then  t-ord-doc.flag_ = true  .
            {&send-to-news-ord}
           end.
       {&send-to-news-cons} /* передаем документ в новости */
      end.
 end case.

 end. /* main */



procedure calc-rcv-in :
do
on error undo, return error return-value
:
/*------------------------------------------------------------------------------
  Purpose:     Пересчет количеств по совокупному заказу
------------------------------------------------------------------------------*/
define buffer locb-ord-doc  for ub.ord-doc .
define buffer locb-ord-line for ub.ord-line .
define buffer locb-ord-dtl  for ub.ord-dtl .

define buffer locb-rcv-doc  for ub.ord-doc-rcv .
define buffer locb-rcv-line for ub.ord-line-rcv .
define buffer locb-rcv-dtl  for ub.ord-dtl-rcv .

define buffer locb-z-doc    for ub.ord-doc .
define buffer locb-z-line   for ub.ord-line .
define buffer locb-z-dtl    for ub.ord-dtl .

define buffer locb-t-doc    for ub.trn-doc .
define buffer locb-t-line   for ub.doc-line .
define buffer locb-t-dtl    for ub.gds-dtl  .

define input parameter p-artic     like ub.goods.artic     no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define output parameter l-sum-rcv-in as decimal no-undo .
define output parameter l-sum-trn-in as decimal no-undo .

l-sum-trn-in  = 0 .
l-sum-rcv-in  = 0 .

/* Поступления */
  for each  locb-z-doc no-lock where
                              locb-z-doc.cons-code = t-ord-cons.cons-code   and
                              locb-z-doc.doc-type  = {&o-f}
                              ,
      each locb-z-line no-lock where
                                locb-z-doc.doc-code = locb-z-line.doc-code    and
                                p-artic        = locb-z-line.artic     and
                                p-prod-code    = locb-z-line.prod-code and
                                p-prod-type    = locb-z-line.prod-type
                                ,
      each  locb-rcv-doc no-lock where
                              locb-rcv-doc.cons-code = t-ord-cons.cons-code   and
                              locb-rcv-doc.doc-type  = "in":U              and
                              locb-rcv-doc.obj-code  = locb-z-doc.obj-code and
                              locb-rcv-doc.obj-type  = locb-z-doc.obj-type
                              ,
      each locb-rcv-line no-lock  where
                                locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                p-artic        = locb-rcv-line.artic     and
                                p-prod-code    = locb-rcv-line.prod-code and
                                p-prod-type    = locb-rcv-line.prod-type
                                :
    assign
      l-sum-rcv-in  = l-sum-rcv-in + locb-rcv-line.qnty
    .
    for each ub.ord-chain no-lock where
             ub.ord-chain.doc-code =  locb-rcv-doc.rcv-code and
             ub.ord-chain.doc-type = 'rcv'                  and
             ub.ord-chain.rel-doc-type = 'trn'
             :
              for each  locb-t-line where
                        locb-t-line.doc-code     = ub.ord-chain.rel-doc-code   and
                        locb-t-line.artic        = locb-rcv-line.artic     and
                        locb-t-line.prod-code    = locb-rcv-line.prod-code and
                        locb-t-line.prod-type    = locb-rcv-line.prod-type
                        :
                assign
                  l-sum-trn-in  = l-sum-trn-in + locb-t-line.fact-qnty
                .
       end.
       end.
  end.
/* Расход */
  for each  locb-z-doc no-lock where
            locb-z-doc.cons-code = t-ord-cons.cons-code   and
            locb-z-doc.doc-type  = {&o-f}
            ,
      each locb-z-line no-lock where
          locb-z-doc.doc-code = locb-z-line.doc-code    and
          p-artic        = locb-z-line.artic     and
          p-prod-code    = locb-z-line.prod-code and
          p-prod-type    = locb-z-line.prod-type
          ,
      each  locb-rcv-doc no-lock where
            locb-rcv-doc.cons-code = t-ord-cons.cons-code   and
            locb-rcv-doc.doc-type  = "in":U              and
            locb-rcv-doc.cli-code  = locb-z-doc.obj-code and
            locb-rcv-doc.cli-type  = locb-z-doc.obj-type
            ,
      each locb-rcv-line no-lock  where
           locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
           locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
           p-artic        = locb-rcv-line.artic     and
           p-prod-code    = locb-rcv-line.prod-code and
           p-prod-type    = locb-rcv-line.prod-type
          :
    assign
      l-sum-rcv-in  = l-sum-rcv-in - locb-rcv-line.qnty
    .
    for each ub.ord-chain no-lock where
             ub.ord-chain.doc-code =  locb-rcv-doc.rcv-code and
             ub.ord-chain.doc-type = 'rcv'                  and
             ub.ord-chain.rel-doc-type = 'trn'
             :
       for each  locb-t-line where
                 locb-t-line.doc-code     = ub.ord-chain.rel-doc-code and
                 locb-t-line.artic        = locb-rcv-line.artic     and
                 locb-t-line.prod-code    = locb-rcv-line.prod-code and
                 locb-t-line.prod-type    = locb-rcv-line.prod-type
                :
            assign
              l-sum-trn-in  = l-sum-trn-in + locb-t-line.fact-qnty
            .
       end.
     end.
  end.
end. /* do */
end procedure. /* calc-rcv-in */