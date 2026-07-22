block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frcnwsdr.p $
$Archive: utl/frcnwsdr.p $

Форсированная передача  правил скидок, созданных в процессе upgrade

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/22/06
Author: Bakhtadze Natalya
Creation date: 12/22/06

*/

define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwsdr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwsdr.p $":U .
define variable vss-description as character no-undo init "Форсированная передача правил скидок, созданных в процессе upgrade".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/disrules.i def }


run utl/startrun.w ( input this-procedure:handle
                   , input "main-proc"
                   , input "no"
                   , input "Форсированная передача правил скидок, созданных в процессе upgrade").


procedure main-proc :
define input parameter p-handle-callback    as handle    no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_code-range for ub.code-range.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_c-dis-rule for ub.c-dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_Dis-card-type for ub.dis-card-type.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-start-rule-num as integer no-undo extent 5.
define variable v-end-rule-num as integer no-undo extent 5.
define variable v-stop-run  as logical   no-undo .
define variable v-pause-run as logical   no-undo .
define variable v-error-ind  as integer   no-undo .
define variable v-warn-ind   as integer   no-undo .
define variable kk as integer no-undo .
define variable v-rule-address as integer no-undo .

define variable p-install as logical no-undo .

define variable acc as integer no-undo .
define variable need-acc as integer no-undo .
define variable v-attr-code as character no-undo extent 4.
define variable v-attr-code2 as character no-undo extent 4.
define buffer buf_rep-start for ub.rep.
define buffer buf_rep-end for ub.rep.
define buffer buf_clients for ub.clients.


  main-block:
  do
  on error undo, return error
  :
  assign
  p-install = if entry(1, p-parameters, {&delim-par}) = "yes" then yes else no
  .
  if not p-install then do:
    message
    "Вы уверены, что хотите запустить пересылку данных по правилам скидок по новостям"
    view-as alert-box question buttons yes-no update loc#log as logical  .
    if not loc#log then return.
  end.
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature('callback-set-start-run-time') <> ""
  then do:
    run callback-set-start-run-time in p-handle-callback .
  end.
  do kk = 1 to 4 :
    /*считаем start-rule-num */
    CASE kk:
      when 1 then do:
        assign
        v-rule-address = 061112030
        .
      end.
      when 2 then do:
        assign
        v-rule-address = 060811070
        .
      end.
      when 3 then do:
        assign
        v-rule-address = 061211050
        .
      end.
      when 4 then do:
        assign
        v-rule-address = 061213060
        .
      end.
     END CASE.

    run read-rule-num in this-procedure (input v-rule-address, 0, output v-start-rule-num[kk], buffer buf_rep-start).
    /*считаем end-rule-num для tax-rate-gds*/
    run read-rule-num in this-procedure (input v-rule-address + 1, 1, output v-end-rule-num[kk],  buffer buf_rep-end).
    assign
    need-acc = need-acc + v-end-rule-num[kk] - v-start-rule-num[kk]
    .
  end.
  do kk = 1 to 4 :
    _buf_dis-rule:
    for each buf_dis-rule no-lock
    :
      if buf_dis-rule.rule-num <= v-start-rule-num[kk]
      OR buf_dis-rule.rule-num >  v-end-rule-num[kk]
      or buf_dis-rule.upper-rule-num > {&max-num-dr-template}
      then next _buf_dis-rule.
      find first buf_code-range no-lock where
                buf_code-range.range-type = {&gbl-dr-code}
           and  buf_code-range.first-code >= buf_Dis-rule.rule-num
           and  buf_code-range.last-code <= buf_Dis-rule.rule-num
           and  buf_code-range.db-num = g#db-num no-error.
      if not available buf_Code-range then next _buf_dis-rule.

      process events.
      if valid-handle(p-handle-callback)
      and p-handle-callback :get-signature('callback-check-stop-run') <> ""
      then do:
        run callback-check-stop-run in p-handle-callback
          (output v-stop-run
          ,output v-pause-run
          ) .
        if v-stop-run = true
        then do:
          define variable v-ok as logical   no-undo .
          message
            "Завершить процесс пересылки?"
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            leave _buf_dis-rule . /* --->>>--- */
          end.
        end.
        if v-pause-run = true
        then do:
          message
            "Нажмите ОК, чтобы продолжить процесс пересылки" skip
            view-as alert-box information .
        end.
      end.
      assign
      acc = acc + 1.
      if valid-handle(p-handle-callback)
      and p-handle-callback :get-signature('callback-display-run') <> ""
      then do:
        run callback-display-run in p-handle-callback
          (input acc                       /* p-run-ind      */
          ,input need-acc - acc            /* p-need-run-ind */
          ,input v-error-ind + v-warn-ind                 /* p-error-ind        */
          ) .
      end.
      run str/callnews.p
          (input {&table_dis-rule}
          ,input (buffer buf_dis-rule:handle)
          )  no-error .
      if error-status:error then do:
        run write-log in this-procedure (
                                          input substitute("Ошибка при пересылке по СПН записи правила скидок: " + {&new-line} +
                                                          "номер правила &1", buf_dis-rule.rule-num)
                                        ,input p-handle-callback).
        assign
          v-error-ind = v-error-ind + 1
        .
        undo _buf_dis-rule, next  _buf_dis-rule .
      end.
      if (buf_dis-rule.templ-rl-root >= 57
      and buf_dis-rule.templ-rl-root <= 66)
      or  (buf_dis-rule.templ-rl-root >= 69
      and buf_dis-rule.templ-rl-root <= 71)
      then do:
        for each buf_dis-dct-rule no-lock where
                buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num,
            first buf_dis-card-type no-lock where
                buf_dis-card-type.type = buf_dis-dct-rule.type
            and buf_dis-card-type.emitent-host-code = buf_dis-dct-rule.emitent-host-code
         on error undo, next:
            run str/callnews.p
                (input {&table_dis-dct-rule}
                ,input (buffer buf_dis-dct-rule:handle)
                )  no-error .
            if error-status:error then do:
              run write-log in this-procedure (
                                                input substitute("Ошибка при пересылке по СПН записи скидки на тип ДК: " + {&new-line} +
                                                                "тип ДК &1 эмитент &2 номер правила &3"
                                                                , buf_dis-dct-rule.type
                                                                , buf_dis-dct-rule.emitent-host-code
                                                                , buf_dis-dct-rule.rule-num)
                                              ,input p-handle-callback).
              assign
                v-error-ind = v-error-ind + 1
              .
              undo _buf_dis-rule, next  _buf_dis-rule .
            end.
           for each buf_rule-by-call no-lock where
                   buf_rule-by-call.call_id = buf_dis-card-type.uniq-key-rec,
               each  buf_rule-call-param no-lock where
                  buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and  buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.call_id = buf_rule-by-call.call_id
                 :
             if  (buf_rule-call-param.param-name = "p-rule-num"
                   or
                 buf_rule-call-param.param-name = "p-prev-rule-num")
              and buf_rule-call-param.param-value-int = buf_dis-dct-rule.rule-num then do:
              run str/callnews.p
                  (input {&table_rule-call-param}
                  ,input (buffer buf_rule-call-param:handle)
                  )  no-error .
              if error-status:error then do:
                run write-log in this-procedure (
                                                  input substitute("Ошибка при пересылке по СПН записи параметра вызова правла расетча алгоритма по ДК: " + {&new-line} +
                                                                  "тип ДК &1 эмитент &2 параметр &3&4место вызова: кодекс &5 набор правил &6 порядок &7"
                                                                  , buf_dis-dct-rule.type
                                                                  , buf_dis-dct-rule.emitent-host-code
                                                                  , buf_rule-call-param.param-name
                                                                  , {&new-line}
                                                                  , buf_rule-by-call.codex_id
                                                                  , buf_rule-by-call.ruleset_id
                                                                  , buf_rule-by-call.order_id
                                                                  )

                                                ,input p-handle-callback).
                assign
                  v-error-ind = v-error-ind + 1
                .
                undo _buf_dis-rule, next  _buf_dis-rule .
              end.
             end. /*if  (buf_rule-call-param.param-name = "p-rule-num"*/
           end.
        end.
      end.
      if g#db-num = 0
      and kk = 1 then do:
        _dis-gds-rule:
        for each buf_dis-gds-rule no-lock where
                buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input {&table_dis-gds-rule}
              ,input (buffer buf_dis-gds-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки товара на объекте: " + {&new-line} +
                                                              "товар &1 объект &2&3 номер правила &4"
                                                              , buf_dis-gds-rule.gds-code
                                                              , buf_dis-gds-rule.obj-type
                                                              , buf_dis-gds-rule.obj-code
                                                              , buf_dis-gds-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end. /*for each buf_dis-gds-rule no-lock where*/
      end. /*if g#db-num = 0:*/
      if g#db-num = 0
      and kk = 1 then do:
        _dis-dct-rule:
        for each buf_dis-dct-rule no-lock where
                buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input {&table_dis-dct-rule}
              ,input (buffer buf_dis-dct-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по типам ДК: " + {&new-line} +
                                                              "тип карты &1 эмитент &2 правило скидки &3"
                                                              , buf_dis-dct-rule.type
                                                              , buf_dis-dct-rule.emitent-host-code
                                                              , buf_dis-dct-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end. /*for each buf_dis-dct-rule no-lock where*/
      end. /*if g#db-num = 0:*/
      if g#db-num = 0
      and kk = 3 then do:
        _dis-grp-rule:
        for each buf_dis-grp-rule no-lock where
                buf_dis-grp-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input {&table_dis-grp-rule}
              ,input (buffer buf_dis-grp-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по группам: " + {&new-line} +
                                                              "классификатор &1 код группы &2 правило скидки &3"
                                                              , buf_dis-grp-rule.classif-type
                                                              , buf_dis-grp-rule.node-code
                                                              , buf_dis-grp-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end. /*for each buf_dis-dct-rule no-lock where*/
      end. /*if g#db-num = 0:*/
      if g#db-num = 0
      and kk = 4 then do:
        _dis-cp-rule:
        for each buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input {&table_dis-cp-rule}
              ,input (buffer buf_dis-cp-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по типам касс. платежей: " + {&new-line} +
                                                              "тип касс платежа &1 код валюты 2 правило скидки &3"
                                                              , buf_dis-cp-rule.cdpay-code
                                                              , buf_dis-cp-rule.curr-code
                                                              , buf_dis-cp-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end. /*for each buf_dis-dct-rule no-lock where*/
      end. /*if g#db-num = 0:*/


      for each buf_c-dis-rule no-lock where
              buf_c-dis-rule.rule-num = buf_dis-rule.rule-num
          AND buf_c-dis-rule.corr-user-db-num   = g#db-num:
        if buf_c-dis-rule.corr-user-name = {&hn-source-upgrade} then do:
          run str/callnews.p
              (input {&table_c-dis-rule}
              ,input (buffer buf_c-dis-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи истории правила скидок: " + {&new-line} +
                                                              "номер правила &1", buf_dis-rule.rule-num)
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
          else do:
          if available buf_rep-start then do:
            buf_rep-start.name1 = string(buf_dis-rule.rule-num).
            .
          end.
          end.
        end.
      end.
    end. /*for each buf_dis-rule*/
  end. /*do kk*/
  FOR EACH buf_rule-call-param NO-LOCK
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if  not (buf_rule-call-param.param-name = "p-rule-num"
          or
        buf_rule-call-param.param-name = "p-prev-rule-num")
    and buf_rule-call-param.param-value-int = buf_dis-dct-rule.rule-num then do:

      run str/callnews.p ( input {&table_rule-call-param}
                          ,input buffer buf_rule-call-param:handle).
    end.
  END.
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature('callback-display-run') <> ""
  then do:
    run callback-display-run in p-handle-callback
      (input acc                       /* p-run-ind      */
      ,input need-acc - acc            /* p-need-run-ind */
      ,input v-error-ind + v-warn-ind                 /* p-error-ind        */
      ) .
  end.
end. /*doe*/
if not p-install then do:
  message "Завершилась утилита пересылки правил скидок"
  view-as alert-box .
end.

end procedure. /* main-proc */


procedure read-rule-num :
/* чтение rule-num*/
  define input parameter p-repnum as integer no-undo .
  define input parameter p-start-end as integer no-undo . /*start = 0 end = 1*/
  define output parameter p-rule-num as integer no-undo .
  define parameter buffer buf_rep for ub.rep.


  do
  on error undo, return error
  :

    find buf_rep
      where buf_rep.rep-num = p-repnum
      no-error
    .
    if not available buf_rep then do:
      assign
      p-rule-num = (if p-start-end = 0 then 0 else current-value(s-drgb-code, {&db-name_schema}))
      .
      return .
    end.
    assign
    p-rule-num = integer(buf_rep.name1) no-error.
    if error-status:error then do:
      assign
      p-rule-num = (if p-start-end = 0 then 0 else current-value(s-drgb-code, {&db-name_schema}))
      .
      release buf_rep.
    end.
    if p-start-end = 1 then release buf_rep.

  end.

end procedure. /* save-rule-num */


procedure write-log :

  do
  on error undo, return error
  :
    define input parameter p-message   as character no-undo .
    define input parameter p-call-back as handle    no-undo .

    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
    and p-call-back <> this-procedure :handle
    then do:
      run callback-write-to-log in p-call-back
        (input p-message
        ) no-error .
    end.
  end.

end procedure. /* write-log */