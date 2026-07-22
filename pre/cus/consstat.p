block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: consstat.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/consstat.p $":u .
define variable vss-description as character no-undo init "Переход по графу статусов   ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: consstat.p $ $Revision: aea5316774be, 0, rls $".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-rec          as recid no-undo .
define variable store-type as character no-undo .
define variable store-code  as integer   no-undo .
define variable g#log as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
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
main-block :
do transaction
on error undo main-block, return error
:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
 find first t-ord-cons where recid (t-ord-cons) = p-rec exclusive-lock no-error.
 assign
  old-state = t-ord-cons.status_
  old-flag  = t-ord-cons.flag_
  .
 case t-ord-cons.status_ :
      when 'факт':U then do :
         message "СЗФП закрыт до факта ! " view-as alert-box .
         return.
      end.
      when 'новый':U then do :
            message "Закрывать СЗФП до статуса " caps('распределение':U) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .
            if v-ok = false then return.
            for each t-ord-doc   where t-ord-doc.cons-code  = t-ord-cons.cons-code
                                 and   t-ord-doc.doc-type   = 'ОФ':U  exclusive-lock :
               t-ord-doc.status_ = 'поставка':U.
               if not g#news then do:  run str/callnews.p     (input "ord-doc"      ,input (buffer t-ord-doc:handle)     ) no-error .        if error-status:error then do:     assign t-ord-doc.flag_ = old-flag  t-ord-doc.status_ = old-state .     message                                                      vss-workfile vss-revision vss-description skip             "Ошибка при передаче СЗФП (ord-doc) в новости" skip        "Возвращает процедура callnews.p" skip                      " - " error-status :get-message(1) skip                   "Документ" t-ord-doc.doc-code skip                         view-as alert-box error.                                   return no-apply.                                       end. end.
            end.
            assign
              t-ord-cons.status_ = 'распределение':U
              .
              if not g#news then do:  run str/callnews.p     (input "ord-cons"      ,input (buffer t-ord-cons:handle)     ) no-error .        if error-status:error then do:     assign t-ord-cons.flag_ = old-flag  t-ord-cons.status_ = old-state .     message                                                       vss-workfile vss-revision vss-description skip              "Ошибка при передаче СЗФП (ord-cons) в новости" skip        "Возвращает процедура callnews.p" skip                       " - "    error-status :get-message(1) skip                 "Документ" t-ord-cons.cons-code skip                        view-as alert-box error .                                   return no-apply.                                        end. end.
        end.
       when 'распределение':U then do :
            message "Закрывать СЗФП до статуса " caps('закрыто':U) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .
            if v-ok = false then return.
         assign
           sum-ord = 0
           sum-rcv = 0
          .
           for each t-ord-doc           where
                                             (t-ord-doc.cons-code     = t-ord-cons.cons-code  and  t-ord-doc.doc-type = 'ФП':U)
                                        and (not ( t-ord-doc.status_ = 'закрыто':U   OR
                                              t-ord-doc.status_ = 'факт':U))
                                         no-lock   :
                  message "Заказ 'Фирма поставщик'  " t-ord-doc.doc-code " имеет статус " CAPS(t-ord-doc.status_)
                          ", закрыть СЗФП до статуса ЗАКРЫТО невозможно ! Закройте заказ ФП " t-ord-doc.doc-code
                          "до статуса ЗАКРЫТО " view-as alert-box error Title "Закрытие СЗФП" .
                  return.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.cons-code     = t-ord-cons.cons-code
                                               and NOT ( t-ord-doc-rcv.status_   = 'поставка':U
                                                   or t-ord-doc-rcv.status_   = 'запрос':U
                                                   OR  t-ord-doc-rcv.status_   = 'факт':U ) no-lock :
                  message "Поставка " t-ord-doc-rcv.rcv-code " имеет статус " CAPS(t-ord-doc-rcv.status_)
                          ", закрыть СЗФП до статуса ЗАКРЫТО невозможно ! Закройте поставку " t-ord-doc-rcv.rcv-code
                          "до статуса ПОСТАВКА " view-as alert-box error  Title "Закрытие СЗФП" .
                  return.
            end.
           for each t-ord-doc           where t-ord-doc.cons-code     = t-ord-cons.cons-code
                                        and  t-ord-doc.doc-type = 'ФП':U
                                        and ( t-ord-doc.status_ = 'закрыто':U   OR
                                              t-ord-doc.status_ = 'факт':U)
                                         no-lock   :
             for each t-ord-line        where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
               for each  t-ord-line-rcv where t-ord-line-rcv.doc-code = t-ord-line.doc-code and
                        t-ord-line-rcv.artic      = t-ord-line.artic         and
                        t-ord-line-rcv.prod-type  = t-ord-line.prod-type   and
                        t-ord-line-rcv.prod-code  = t-ord-line.prod-code  no-lock  ,
                        first  t-ord-doc-rcv where  t-ord-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                                               and  t-ord-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                                               and ( t-ord-doc-rcv.status_   = 'поставка':U
                                               OR  t-ord-doc-rcv.status_   = 'факт':U )
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
              t-ord-cons.status_ = 'закрыто':U
              .
           for each t-ord-doc where t-ord-doc.cons-code     = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = 'ОФ':U
                              and not ( t-ord-doc.status_ = 'закрыто':U   OR
                                        t-ord-doc.status_ = 'факт':U)
                               exclusive-lock   :
             sum-ord = 0.
             sum-rcv = 0.
             for each t-ord-line       where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
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
            t-ord-doc.status_ = 'закрыто':U.
            if  sum-ord > sum-rcv then  t-ord-doc.flag_ = false .
                                  else  t-ord-doc.flag_ = true  .
            if t-ord-cons.flag_ = true then  t-ord-doc.flag_ = true  .
           if not g#news then do:  run str/callnews.p     (input "ord-doc"      ,input (buffer t-ord-doc:handle)     ) no-error .        if error-status:error then do:     assign t-ord-doc.flag_ = old-flag  t-ord-doc.status_ = old-state .     message                                                      vss-workfile vss-revision vss-description skip             "Ошибка при передаче СЗФП (ord-doc) в новости" skip        "Возвращает процедура callnews.p" skip                      " - " error-status :get-message(1) skip                   "Документ" t-ord-doc.doc-code skip                         view-as alert-box error.                                   return no-apply.                                       end. end.
           end.
          if not g#news then do:  run str/callnews.p     (input "ord-cons"      ,input (buffer t-ord-cons:handle)     ) no-error .        if error-status:error then do:     assign t-ord-cons.flag_ = old-flag  t-ord-cons.status_ = old-state .     message                                                       vss-workfile vss-revision vss-description skip              "Ошибка при передаче СЗФП (ord-cons) в новости" skip        "Возвращает процедура callnews.p" skip                       " - "    error-status :get-message(1) skip                 "Документ" t-ord-cons.cons-code skip                        view-as alert-box error .                                   return no-apply.                                        end. end.
      end.
      when 'закрыто':U then do :
            old-flag_ = t-ord-cons.flag_ .
            message "Закрывать СЗФП до статуса " caps('факт':U) " ?"
                    view-as alert-box question
                    button yes-no  update v-ok
                    .
            if v-ok = false then return.
              define variable v-obj-active  as character no-undo .
              define variable v-office      as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  store-type
  ,input  store-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currdbat in g#library
  (input  'office=request':u
  ,output v-office
  )  .
              if  v-obj-active <> "yes"  then do:
                                message "Закрыть до факта можно только на АКТИВНОМ объекте!!!"
                                        view-as alert-box information              .
                                return.
              end.
           for each t-ord-doc           where t-ord-doc.cons-code     = t-ord-cons.cons-code
                                        and  t-ord-doc.doc-type = 'ФП':U
                                        and not ( t-ord-doc.status_ = 'факт':U)
                                         no-lock   :
                  message "Заказ 'Фирма поставщик'  " t-ord-doc.doc-code " имеет статус " CAPS(t-ord-doc.status_)
                          ", закрыть СЗФП до статуса ФАКТ невозможно ! Закройте заказ ФП " t-ord-doc.doc-code
                          "до статуса ФАКТ " view-as alert-box error  Title "Закрытие СЗФП" .
                  return.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.cons-code     = t-ord-cons.cons-code
                                               and NOT ( t-ord-doc-rcv.status_   = 'факт':U ) no-lock :
                  message "Поставка " t-ord-doc-rcv.rcv-code " имеет статус " CAPS(t-ord-doc-rcv.status_)
                          ", закрыть СЗФП до статуса ФАКТ невозможно ! Закройте поставку " t-ord-doc-rcv.rcv-code
                          "до статуса ФАКТ " view-as alert-box error  Title "Закрытие СЗФП" .
                  return.
            end.
         assign
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
          .
           for each t-ord-doc where t-ord-doc.cons-code = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = 'ФП':U
                              and (t-ord-doc.status_ = 'факт':U)
                              no-lock   :
             for each t-ord-line  where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
               for each  t-ord-line-rcv where t-ord-line-rcv.doc-code = t-ord-line.doc-code and
                        t-ord-line-rcv.artic      = t-ord-line.artic     and
                        t-ord-line-rcv.prod-type  = t-ord-line.prod-type and
                        t-ord-line-rcv.prod-code  = t-ord-line.prod-code no-lock  ,
                        first  t-ord-doc-rcv where  t-ord-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                                               and  t-ord-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                                               and (  t-ord-doc-rcv.status_   = 'факт':U )
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
                                                        and (  t-trn-doc.status_   = 'факт':U ) no-lock  :
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
                   t-ord-cons.status_ = 'факт':U
                   t-ord-cons.fact-date = to-day.
              .
             if old-flag_ = false then t-ord-cons.flag_ = false  .
             if can-find (first t-ord-doc-rcv where t-ord-doc-rcv.cons-code = t-ord-cons.cons-code and t-ord-doc-rcv.flag_ = false no-lock )
                then t-ord-cons.flag_ = false  .
           for each t-ord-doc where t-ord-doc.cons-code     = t-ord-cons.cons-code
                              and  t-ord-doc.doc-type = 'ОФ':U
                              and not ( t-ord-doc.status_ = 'отказ':U   OR
                                        t-ord-doc.status_ = 'факт':U)
                               exclusive-lock   :
             sum-ord = 0.
             sum-rcv = 0.
             sum-trn = 0.
             for each t-ord-line       where t-ord-line.doc-code     = t-ord-doc.doc-code  no-lock :
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
                                                      and  t-trn-doc.status_  = 'факт':U  no-lock :
                                        sum-trn = sum-trn + t-trn-line.fact-qnty.
                                    end.
                            end.
                        if t-ord-doc-rcv.status_ <> 'факт':U then do:
                            t-ord-doc-rcv.status_ = 'факт':U.
                            if  sum-rcv > sum-trn  or  ( sum-rcv = sum-trn  and  sum-trn = 0 )  then  t-ord-doc-rcv.flag_ = false .
                                                  else  t-ord-doc-rcv.flag_ = true  .
                            if not g#news then do:  run str/callnews.p     (input "ord-doc-rcv"      ,input (buffer t-ord-doc-rcv:handle)     ) no-error .        if error-status:error then do:     assign t-ord-doc-rcv.flag_ = old-flag  t-ord-doc-rcv.status_ = old-state .     message                                                      vss-workfile vss-revision vss-description skip             "Ошибка при передаче СЗФП (ord-doc-rcv) в новости" skip                  "Возвращает процедура callnews.p" skip                                   " - " error-status :get-message(1) skip                                  "Документ" t-ord-doc-rcv.rcv-code (t-ord-doc-rcv.doc-code) skip          view-as alert-box error .                                  return no-apply.                                       end. end.
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
            t-ord-doc.status_ = 'факт':U.
            if  sum-rcv > sum-trn  or  ( sum-rcv = sum-trn  and  sum-trn = 0 )  then  t-ord-doc.flag_ = false .
                                  else  t-ord-doc.flag_ = true  .
            if t-ord-cons.flag_ = true then  t-ord-doc.flag_ = true  .
            if not g#news then do:  run str/callnews.p     (input "ord-doc"      ,input (buffer t-ord-doc:handle)     ) no-error .        if error-status:error then do:     assign t-ord-doc.flag_ = old-flag  t-ord-doc.status_ = old-state .     message                                                      vss-workfile vss-revision vss-description skip             "Ошибка при передаче СЗФП (ord-doc) в новости" skip        "Возвращает процедура callnews.p" skip                      " - " error-status :get-message(1) skip                   "Документ" t-ord-doc.doc-code skip                         view-as alert-box error.                                   return no-apply.                                       end. end.
           end.
       if not g#news then do:  run str/callnews.p     (input "ord-cons"      ,input (buffer t-ord-cons:handle)     ) no-error .        if error-status:error then do:     assign t-ord-cons.flag_ = old-flag  t-ord-cons.status_ = old-state .     message                                                       vss-workfile vss-revision vss-description skip              "Ошибка при передаче СЗФП (ord-cons) в новости" skip        "Возвращает процедура callnews.p" skip                       " - "    error-status :get-message(1) skip                 "Документ" t-ord-cons.cons-code skip                        view-as alert-box error .                                   return no-apply.                                        end. end.
      end.
 end case.
 end.
procedure calc-rcv-in :
do
on error undo, return error return-value
:
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
  for each  locb-z-doc no-lock where
                              locb-z-doc.cons-code = t-ord-cons.cons-code   and
                              locb-z-doc.doc-type  = 'ОФ':U
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
  for each  locb-z-doc no-lock where
            locb-z-doc.cons-code = t-ord-cons.cons-code   and
            locb-z-doc.doc-type  = 'ОФ':U
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
end.
end procedure.
