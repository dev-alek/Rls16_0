block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перевод статусов для платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/03
Author: Bakhtadze Natalya
Creation date: 11/17/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-code      like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code   like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-close-mode     as character no-undo .
define input parameter p-author         as character no-undo . /*может быть пусто или cl-bank*/
define input parameter p-status_        as character no-undo . /*тот что будет*/
define input-output parameter p-status-date    like ub.fin-doc.fact-date no-undo .
/*если = ?, то сегодня*/
define input parameter p-silent                       as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перевод статусов для платежей".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ ref/fndocip.i }
{ str/lib-farh.i }
{ ref/fd-attr.i }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }
{ gbl/key-rec.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-fact-order as decimal no-undo .
define variable v-shift-fact-order as decimal no-undo .
define variable v-fact-num as integer no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order as decimal no-undo .
define variable v-pre-status_ as character no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo.
define variable v-status_ as character no-undo .
define variable v-ask-date as logical no-undo .
define variable v-ask-message as character no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-ret-mess as character no-undo .
define variable v-datestr as character no-undo .
define variable v-prn-doc-code like ub.fin-doc.prn-doc-code no-undo .
define variable v-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define variable v-line-rec as recid no-undo .
define variable v-update-counter-flag as logical no-undo .
define variable v-update-counter as integer no-undo .
define variable mValue as character no-undo .
define variable MParam as character no-undo.
  
define variable mask-pko as character no-undo .
define variable mask-rko as character no-undo .
define variable current-pko-rko as character no-undo .
define variable current-ruleID as character no-undo .
define variable v-current-num as integer no-undo .
define variable v-prev-prn-doc-code as character no-undo .
define variable v-matches as character no-undo .
define variable v-key     as character no-undo.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer locked_fin-statement-line for ub.fin-statement-line.
define buffer buf_payment for ub.payment.
define buffer buf_thbj-attr for ub.thbj-attr.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_fin-doc exclusive-lock where
            buf_fin-doc.host-code = p-host-code
         AND buf_fin-doc.fin-doc-code = p-fin-doc-code .
  /*проверим еще раз!!! findgraf.p*/
  assign
  v-prn-doc-code = buf_fin-doc.prn-doc-code
  v-fin-doc-type = buf_fin-doc.fin-doc-type
  .
  run trg/findgraf.p (
                  input  buf_fin-doc.host-code
                  ,input  buf_fin-doc.fin-doc-code
                  ,input  p-close-mode
                  ,input  p-author
                  ,input  buf_fin-doc.status_
                  ,input  ?                     /*p-status-date*/
                  ,output v-status_
                  ,output v-ask-date
                  ,output v-ask-message
                  ) no-error.
  if error-status:error
  or v-status_ <> p-status_
  or (v-ask-date and p-status-date = ?)
  then do:
    run err-mess ("Ошибка при проверке возможности открытия/закрытия/отказа", output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
  /*навесим перевод статусов*/
  assign
  v-pre-status_ = buf_fin-doc.status_
  .
  if p-status-date = ? and v-ask-date then do:
    run gbl/d-prompt.w (
      'title=':u + "Дата смены статуса" + '\':u
    + 'text1=':u + "Введите дату" + '\':u
    + 'format=99/99/9999' + '\':u
    + 'type=' + {&type-date} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no' + '\':u
    , input-output v-datestr
    ).
    if return-value = 'false':u then undo main-block, return error v-ret-mess.
    assign
    v-date = date(integer(substr(v-datestr, 4, 2))
                ,integer(substr(v-datestr, 1, 2))
                ,integer(substr(v-datestr, 7, 4)))
    no-error .
    if error-status:error then do:
      message
      "Вы ввели неверную дату"
      view-as alert-box error .
      undo main-block, return error .
    end.
    assign
    p-status-date = v-date
    .
  end.
  else do:
    if p-status-date = ? then do:
      run cur-time in this-procedure(output v-date, output v-time).
    end.
    if p-status-date <> ? then do:
      assign
      v-date = p-status-date
      .
    end.
  end.
  /*проверим корректность документа для перевода статуса*/
  CASE buf_fin-doc.fin-doc-type:
    when {&income-cash} then do:
      run check-income-cash in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when {&expense-cash} then do:
      run check-expense-cash in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when {&income-cashless} then do:
      run check-income-cashless in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when {&expense-cashless} then do:
      run check-expense-cashless in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when {&income-payoff} then do:
      run check-income-payoff in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when {&expense-payoff} then do:
      run check-expense-payoff in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
  END CASE.
  { gbl/baserate.i  buf_fin-doc.host-code v-date buf_fin-doc.actual-base-rate buf_fin-doc.actual-base-scale no-error  }
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  { gbl/exchrate.i  buf_fin-doc.curr-code v-date buf_fin-doc.actual-exch-rate buf_fin-doc.actual-exch-scale v-curr-abbr no-error }
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  { gbl/exchrate.i  buf_fin-doc.contract-curr v-date buf_fin-doc.actual-contract-rate buf_fin-doc.actual-contract-scale v-curr-abbr no-error }
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  CASE p-status_:
    when {&fin-new} then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-perm = ?
      buf_fin-doc.user-name-perm = "":U
      buf_fin-doc.perm-date = ?
      buf_fin-doc.user-db-num-pl = ?
      buf_fin-doc.user-name-pl = "":U
      buf_fin-doc.pay-date = ?
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      .
    end.
    when {&fin-permitted} then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-perm = g#db-num
      buf_fin-doc.user-name-perm = g#userid
      buf_fin-doc.perm-date = (if p-close-mode = {&open-doc} then buf_fin-doc.perm-date else v-date)
      buf_fin-doc.user-db-num-pl = ?
      buf_fin-doc.user-name-pl = "":U
      buf_fin-doc.pay-date = ?
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      .
      if not (buf_fin-doc.obj-type = ''
      and buf_fin-doc.obj-code = 0)
      and p-close-mode = {&open-doc}
      and lookup(buf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
      then do:
        run fill-shift in this-procedure ( buffer buf_fin-doc
                                        ) no-error.
        if error-status :error then do:
          run err-mess in this-procedure ( substitute( "Ошибка при заполнении даты и номера смены&1&2&1&3"
                                                    ,{&new-line}, error-status :get-message (1), return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.

        end.
      end. /*if not (buf_fin-doc.obj-type = ''*/
    end.
    when {&fin-bank} then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-pl = g#db-num
      buf_fin-doc.user-name-pl = g#userid
      buf_fin-doc.pay-date = (if p-close-mode = {&open-doc} then buf_fin-doc.pay-date else v-date)
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      buf_fin-doc.fact-author = '':U
      .
      /*удалим из fin-statement*/
      if p-close-mode = {&open-doc} then do:
        for each buf_fin-statement-line no-lock where
              buf_fin-statement-line.host-code = buf_fin-doc.host-code
          and buf_fin-statement-line.fin-doc-code = buf_fin-doc.fin-doc-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find first locked_fin-statement-line exclusive-lock where
                    recid(locked_fin-statement-line) = recid(buf_fin-statement-line).
          v-line-rec = RECID(buf_fin-statement-line).
          run ref/finsttml.p (
                        INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT v-line-rec
                        ,INPUT {&deletion}
                        ,INPUT buf_fin-statement-line.host-code
                        ,INPUT buf_fin-statement-line.sttm-code
                        ,INPUT buf_fin-statement-line.fin-doc-code
                        ,INPUT buf_fin-statement-line.pay-date /*p-fact-date*/
                        ,INPUT buf_fin-statement-line.prn-doc-code
                        ,INPUT buf_fin-statement-line.fin-ext-doc-type
                        ,input buf_fin-statement-line.rp-bik
                        ,input buf_fin-statement-line.rp-bank-name
                        ,input buf_fin-statement-line.rp-bank-city
                        ,input buf_fin-statement-line.rp-c-schet
                        ,input buf_fin-statement-line.rp-r-schet
                        ,input buf_fin-statement-line.rp-name
                        ,input buf_fin-statement-line.rp-inn
                        ,input buf_fin-statement-line.rp-kpp
                        ,INPUT buf_fin-statement-line.sum-doc
                        ,input p-author
                        ,INPUT buf_fin-statement-line.ps /*ps*/
                          )
              no-error.
          if error-status:error then do:
            run err-mess in this-procedure ( substitute( "Ошибка при удалении строки банковской выписки &1&2&3"
                                                      ,return-value, {&new-line}, error-status :get-message (1) )
                                                      ,output v-ret-mess).
            undo main-block, return error v-ret-mess.
          end.
        end. /*for each buf_fin-statement-line no-lock where*/
      end. /*if p-close-mode = {&close-doc} then do:*/
    end.
    when {&fin-rejected} then do:
      run get-fact-num in this-procedure ( input buf_fin-doc.host-code
                                          ,output v-fact-num).
      run factord in this-procedure (
                                       input  v-date
                                      ,input  v-time
                                      ,input  v-fact-num
                                      ,input  ? /*p-shift-date*/
                                      ,input  0 /*p-shift-num*/
                                      ,input  no
                                      ,output v-fact-order
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).
      if buf_fin-doc.shift-date <> ? then do:
        run factord in this-procedure (
                                        input  v-date
                                        ,input  v-time
                                        ,input  v-fact-num
                                        ,input  buf_fin-doc.shift-date
                                        ,input  buf_fin-doc.shift-num
                                        ,input  yes
                                        ,output v-shift-fact-order
                                        ,output v-shift-end-fact-order
                                        ,output v-day-end-fact-order
                                        ).
      end.
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-fact = g#db-num
      buf_fin-doc.user-name-fact = g#userid
      buf_fin-doc.fact-date = v-date
      buf_fin-doc.fact-order = v-fact-order
      buf_fin-doc.fact-order = v-shift-fact-order
      buf_fin-doc.fact-num = v-fact-num
      .



    end.
    when {&fin-fact} then do:

      run get-fact-num in this-procedure ( input buf_fin-doc.host-code
                                          ,output v-fact-num).
      /*фактордер всегда календарный*/
      run factord in this-procedure (
                                       input  v-date
                                      ,input  v-time
                                      ,input  v-fact-num
                                      ,input  ? /*p-shift-date*/
                                      ,input  0 /*p-shift-num*/
                                      ,input  no
                                      ,output v-fact-order
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).
      if buf_fin-doc.shift-date <> ? then do:
        run factord in this-procedure (
                                        input  v-date
                                        ,input  v-time
                                        ,input  v-fact-num
                                        ,input  buf_fin-doc.shift-date
                                        ,input  buf_fin-doc.shift-num
                                        ,input  yes
                                        ,output v-shift-fact-order
                                        ,output v-shift-end-fact-order
                                        ,output v-day-end-fact-order
                                        ).
      end.

      /*установим атрибуты смены*/
      define variable varobj-shift-date as date no-undo .
      define variable varobj-shift-num as integer no-undo .
      define variable varobj-shift-name as character no-undo .

      if not (buf_fin-doc.obj-type = ''
      and buf_fin-doc.obj-code = 0)
      and p-close-mode = {&open-doc}
      and lookup(buf_fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
      then do:
        run fill-shift in this-procedure ( buffer buf_fin-doc
                                        ) no-error.
        if error-status :error then do:
          run err-mess in this-procedure ( substitute( "Ошибка при заполнении даты и номера смены&1&2&1&3"
                                                    ,{&new-line}, error-status :get-message (1), return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.

        end.
      end. /*if not (buf_fin-doc.obj-type = ''*/
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-fact = g#db-num
      buf_fin-doc.user-name-fact = g#userid
      buf_fin-doc.fact-date = v-date
      buf_fin-doc.fact-order = v-fact-order
      buf_fin-doc.shift-fact-order = v-shift-fact-order
      buf_fin-doc.fact-author = p-author
      buf_fin-doc.fact-num = v-fact-num
      .
      define variable v-today as date no-undo .
      run cur-time in this-procedure ( output v-today, output v-time).
      if buf_fin-doc.fact-date < v-today then do:
        assign
        buf_fin-doc.is-back-date = yes.
      end.
      else do:
        if buf_fin-doc.shift-flag = integer({&fin-flag-shift})
        and buf_fin-doc.shift-date <> ? then do:
          { gbl/curshift.i
            buf_fin-doc.obj-type
            buf_fin-doc.obj-code
            varobj-shift-date
            varobj-shift-num
            varobj-shift-name
          }
          if not (buf_fin-doc.shift-date = varobj-shift-date and
                  buf_fin-doc.shift-num  = varobj-shift-num  )   then do:
            assign
              buf_fin-doc.is-back-date = yes.
          end.
        end.
      end.
      if not p-author = {&auto}
      and buf_fin-doc.shift-flag = integer({&fin-flag-shift})
      and buf_fin-doc.is-back-date = yes
      then do:
        define variable var-log as logical no-undo .
        { gbl/chk-actg.i
          g#db-num
          g#userid
          {&action-head-code-main}
          'actn_fin-doc_create-back-shift':U
          {&cntxt-object}
          buf_fin-doc.host-code
          buf_fin-doc.obj-type
          buf_fin-doc.obj-code
          0
          0
          0
          false
          var-log
        }
        if not var-log then do:
          run err-mess in this-procedure ( substitute( "Ошибка про проверке возможности изменения статуса задней сменой&1&2&1&3"
                                                    ,{&new-line}
                                                    , error-status :get-message (1)
                                                    , return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.

      if buf_fin-doc.contract-code > 0 then do: /* пересчитаем баланс по договору */
        run str/calc-bal.p (
                             input "findoc"
                            ,input yes
                            ,input buf_fin-doc.fin-ext-doc-type
                            ,input buf_fin-doc.host-code
                            ,input buf_fin-doc.contract-code
                            ,input buf_fin-doc.sum-contr
                            ,input buf_fin-doc.sum-rubl
                            ,input buf_fin-doc.sum-base) no-error .
        if error-status:error then do:
          run err-mess in this-procedure ( substitute("Ошибка при расчете баланса по договору&1&2&1&3"
                                                      ,{&new-line}
                                                      , error-status:get-message(1)
                                                      , return-value )
                                         ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.
      if buf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cash}
      or buf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cashless}
      or buf_fin-doc.fin-ext-doc-type = {&FDEDT_income_payoff} then do:
        define variable v-num-dc as integer no-undo .
        run str/lock-dc.p ( input ? /*p-log-handle*/
                    ,input this-procedure:handle
                    ,input {&table_fin-doc}
                    ,input string(buf_fin-doc.fin-doc-code)
                    ,input '':U
                    ,input 1 /*p-step*/
                    ,input no /*is-news*/
                    ,input '':U /*log-file-name*/
                    ,output v-num-dc) no-error.
        if error-status:error then do:
          run err-mess in this-procedure ( substitute("Ошибка при блокировании ДК, к котоым привязан платеж&1&2&1&3"
                                                      ,{&new-line}
                                                      , error-status:get-message(1)
                                                      , return-value )
                                         ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
        if v-num-dc > 0 then do:
          for each buf_payment exclusive-lock where
                  buf_payment.source-type = {&pmnt-fin-doc}
              and buf_payment.source-ref = string(buf_fin-doc.fin-doc-code)
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            buf_payment.fact-date = buf_fin-doc.fact-date
            buf_payment.closid = buf_fin-doc.user-name-fact
            buf_payment.status_ = {&fact}
            .
          end.
          run str/saledc.p
            (
            input parparentproc
            ,input this-procedure :handle
            ,input ? /*p-log-handle*/
            ,input {&dct-proc_fin-doc-on-card}
            ,input ? /*p-emitent-host-code*/
            ,input "" /*p-type*/
            ,input 0 /*p-profile-id*/
            ,input 0 /*p-codex-id*/
            ,input 0 /*p-ruleset-id*/
            ,input g#db-num
            ,input string(buf_fin-doc.fin-doc-code)
            ,input buf_fin-doc.doc-date
            ,input buf_fin-doc.fact-date
            ,input 0 /*cre-pay*/
            ,input 1 /*par-sign*/
            ,input ? /*par-direction*/
            ,input yes /*p-save*/
            ) no-error .
          if error-status:error then do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  END CASE.
  release buf_fin-doc no-error .
  if error-status:error then do:
    run err-mess (substitute("Ошибка при смене статуса на &1", p-status_), output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
  if p-status_ = {&fin-fact} then do:
    { str/taskclcd.i p-host-code p-fin-doc-code "'all':U" g#userid "'close':u" no-error }
    if error-status:error then do:
      run err-mess (substitute("Ошибка при расчете архивов по платежу: &1 &2", return-value, error-status:get-message(1)), output v-ret-mess).
      undo main-block, return error v-ret-mess.
    end.
    run release-auto-fill-prn-doc-code in this-procedure (input v-update-counter-flag, input v-update-counter).
  end.
end. /*doe*/

procedure check-income-cash :

  do
  on error undo, return error return-value
  :
    if p-close-mode = {&close-doc} and buf_fin-doc.doc-date <> v-date then do:
       run err-mess (substitute("Для платежа типа &1 дата &2 должна равняться дате док", buf_fin-doc.fin-doc-type, p-status_), output v-ret-mess).
       undo, return error (if p-silent = ? then v-ret-mess else '':U).
    end.
    if p-status_ = {&fin-fact} then do:
      run auto-fill-prn-doc-code in this-procedure (output v-update-counter-flag, output v-update-counter).
    end.
    &scop prfx buf_fin-doc.
    run ref/findoc01.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-income-cash */
procedure check-expense-cash :

  do
  on error undo, return error
  :
    if p-close-mode = {&close-doc} and buf_fin-doc.doc-date <> v-date then do:
       run err-mess (substitute("Для платежа типа &1 дата &2 должна равняться дате док", buf_fin-doc.fin-doc-type, p-status_)
                      ,output v-ret-mess).
       undo, return error (if p-silent = ? then v-ret-mess else '':U).
    end.
    if p-status_ = {&fin-fact} then do:
      run auto-fill-prn-doc-code in this-procedure (output v-update-counter-flag, output v-update-counter).
    end.
    &scop prfx buf_fin-doc.
    run ref/findoc02.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-expense-cash */


procedure check-income-cashless :

  do
  on error undo, return error
  :
    &scop prfx buf_fin-doc.
    run ref/findoc03.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-income-cashless */

procedure check-expense-cashless :

  do
  on error undo, return error
  :
    &scop prfx buf_fin-doc.
    run ref/findoc04.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-expense-cashless */

procedure check-income-payoff :

  do
  on error undo, return error
  :
    &scop prfx buf_fin-doc.
    run ref/findoc05.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-income-payoff */
procedure check-expense-payoff :

  do
  on error undo, return error
  :
    &scop prfx buf_fin-doc.
    run ref/findoc06.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-expense-payoff */


PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      if available buf_fin-doc then
      assign
      p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&5вн.код платежа &4 Статус &5&6&7"
                                , buf_fin-doc.prn-doc-code
                                , buf_fin-doc.host-code
                                , buf_fin-doc.fin-doc-type
                                , buf_fin-doc.fin-doc-code
                                , buf_fin-doc.status_
                                , {&new-line}
                                , p-mess
                                ).

      else
      assign
      p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&5вн.код платежа &4&5&6"
                                , v-prn-doc-code
                                , p-host-code
                                , v-fin-doc-type
                                , p-fin-doc-code
                                , {&new-line}
                                , p-mess
                                ).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.


procedure auto-fill-prn-doc-code :
define output parameter p-update-counter-flag as logical no-undo .
define output parameter p-update-counter as integer no-undo .

define variable glog as logical no-undo .
define variable choice as integer no-undo .
define variable v-sl as integer no-undo .
define variable v-pl as integer no-undo .
define variable v-loc-update-counter-flag as logical no-undo .
define variable v-my-counter as integer no-undo .
define variable v-obj-db-num as integer   no-undo .
define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .

/*заполним сами если это auto */
if buf_fin-doc.trn-doc-code <> ''
and not (buf_fin-doc.obj-type = ''
          and
          buf_fin-doc.obj-code = 0)
then do:
  { gbl/objdbnum.i buf_fin-doc.obj-type buf_fin-doc.obj-code v-obj-db-num }
  if    v-obj-db-num <> g#db-num 
     or (buf_fin-doc.prn-doc-code <> "" and buf_fin-doc.prn-doc-code <> ? and buf_fin-doc.prn-doc-code <> "тех_") 
  then do:
    return.
  end .
  
  mCashBook = new ibs.th.ref.cashbookstorage () .
      
  mask-pko = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "PkoMask") .
  mask-rko = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "RkoMask") .
  
  
  
  if mask-pko > ""
  then.
  else mask-pko = "[NNNN]/[obj-code]" .
  if mask-rko > ""
  then.
  else mask-rko = "[NNNN]/[obj-code]" .
/*  run adm/shattri.p (                                                                                                           */
/*      input "get":U                                                                                                             */
/*      ,input  buf_fin-doc.obj-type                                                                                              */
/*      ,input  buf_fin-doc.obj-code                                                                                              */
/*      ,input  {&attr-fin-doc}                                                                                                   */
/*      ,input  "":U /*p-param-code*/                                                                                             */
/*      ,output v-value-character                                                                                                 */
/*      ,output v-value-date                                                                                                      */
/*      ,output v-value-decimal                                                                                                   */
/*      ,output v-value-integer                                                                                                   */
/*      ,output v-value-logical                                                                                                   */
/*      ,output v-param-type                                                                                                      */
/*      ,INPUT-OUTPUT table-handle v-tth                                                                                          */
/*      ) no-error .                                                                                                              */
/*  IF error-status:error then do:                                                                                                */
/*    &scop my-message  substitute("Ошибка при получении настроек фин.документов НА ОБЪЕКТЕ &1&2:&3&4 &5" ~                       */
/*            , buf_fin-doc.obj-type ~                                                                                            */
/*            , buf_fin-doc.obj-code ~                                                                                            */
/*            , ~{&new-line~}   ~                                                                                                 */
/*            , error-status:get-message(1) ~                                                                                     */
/*            , return-value )                                                                                                    */
/*                                                                                                                                */
/*  end.                                                                                                                          */
/*  for each  thbjattr_thbj-attr where                                                                                            */
/*            thbjattr_thbj-attr.obj-type = buf_fin-doc.obj-type                                                                  */
/*        and thbjattr_thbj-attr.obj-code = buf_fin-doc.obj-code                                                                  */
/*        and thbjattr_thbj-attr.upper-prop-code = {&attr-fin-doc}                                                                */
/*  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):*/
/*    case thbjattr_thbj-attr.prop-code:                                                                                          */
/*      when {&attr-fin-doc_suffix-pko} then do:                                                                                  */
/*        suffix-pko = thbjattr_thbj-attr.property-value-character.                                                               */
/*      end.                                                                                                                      */
/*      when {&attr-fin-doc_suffix-rko} then do:                                                                                  */
/*        suffix-rko = thbjattr_thbj-attr.property-value-character.                                                               */
/*      end.                                                                                                                      */
/*      when {&attr-fin-doc_prefix-pko} then do:                                                                                  */
/*        prefix-pko = thbjattr_thbj-attr.property-value-character.                                                               */
/*      end.                                                                                                                      */
/*      when {&attr-fin-doc_prefix-rko} then do:                                                                                  */
/*        prefix-rko = thbjattr_thbj-attr.property-value-character.                                                               */
/*      end.                                                                                                                      */
/*    end case.                                                                                                                   */
/*  end. /*for each  thbjattr_thbj-attr where*/                                                                                   */
  MParam = if mCashBook:getSinglRule(buf_fin-doc.cashbookId, buf_fin-doc.obj-type,buf_fin-doc.obj-code, "uchet") eq "1"
           then "year," + string(year(buf_fin-doc.shift-date))
           else "".                                      
  delete object mCashBook no-error .
  subscribe   to "getCounter" anywhere run-procedure "Mycounter". 
   
  case buf_fin-doc.fin-ext-doc-type:
    when {&FDEDT_Income_Cash} then do:
      find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
                                           and ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
                                           and ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
                                           and ub.CashBookRule.Code = "currPko"
                                           no-error .
      if not available ub.CashBookRule
      then do :
        create ub.CashBookRule .
        assign
          ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
          ub.CashBookRule.Obj-type = buf_fin-doc.obj-type    
          ub.CashBookRule.Obj-code = buf_fin-doc.obj-code    
          ub.CashBookRule.Code = "currPko"    
          ub.CashBookRule.Status_ = 0
          ub.CashBookRule.RuleValue = "1"                       
        .
      end.  
      run gen-key-rec in this-procedure ( input {&table_CashBookRule}
                                         ,input (buffer CashBookRule:handle)
                                         ,output v-key).                                     
                                        
      assign
        current-pko-rko = "currPKO" 
        current-ruleID = v-key
      .
      run utl/maskproc.p(parparentproc, mask-pko, "cashbook", buf_fin-doc.CashBookId, output mValue).
      
    end.
    when {&FDEDT_expense_cash} then do:
      find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
                                           and ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
                                           and ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
                                           and ub.CashBookRule.Code = "currRko"
                                           no-error .
      if not available ub.CashBookRule
      then do :
        create ub.CashBookRule .
        assign
          ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
          ub.CashBookRule.Obj-type = buf_fin-doc.obj-type    
          ub.CashBookRule.Obj-code = buf_fin-doc.obj-code    
          ub.CashBookRule.Code = "currRko"  
          ub.CashBookRule.Status_ = 0 
          ub.CashBookRule.RuleValue = "1"                         
        .
      end.
      
      run gen-key-rec in this-procedure ( input {&table_CashBookRule}
                                         ,input (buffer CashBookRule:handle)
                                         ,output v-key).                                     
      assign
        current-pko-rko = "currRKO" 
        current-ruleID = v-key
      .
      run utl/maskproc.p(parparentproc, mask-rko, "cashbook", buf_fin-doc.CashBookId, output mValue).
      
    end.
  end case.
  
  unsubscribe to "getCounter".
  
/*                                                                      */
/*  find first buf_thbj-attr exclusive-lock where                       */
/*          buf_thbj-attr.upper-prop-code = {&attr-fin-doc}             */
/*      and buf_thbj-attr.prop-code = current-pko-rko                   */
/*      and buf_thbj-attr.obj-type = buf_fin-doc.obj-type               */
/*      and buf_thbj-attr.obj-code = buf_fin-doc.obj-code no-error.     */
/*  if not available buf_thbj-attr then do:                             */
/*    find first thbjattr_thbj-attr where                               */
/*        thbjattr_thbj-attr.obj-type = buf_fin-doc.obj-type            */
/*    and thbjattr_thbj-attr.obj-code = buf_fin-doc.obj-code            */
/*    and thbjattr_thbj-attr.upper-prop-code = {&attr-fin-doc}          */
/*    and thbjattr_thbj-attr.prop-code = current-pko-rko.               */
/*    run thbjattr_write in this-procedure (                            */
/*                                            input buf_fin-doc.obj-type*/
/*                                          ,input buf_fin-doc.obj-code */
/*                                          ,input {&attr-fin-doc}      */
/*                                          ,input current-pko-rko      */
/*                                          ,input ''                   */
/*                                          ,input ?                    */
/*                                          ,input 0.0                  */
/*                                          ,input 0                    */
/*                                          ,input no ).                */
/*    find first buf_thbj-attr exclusive-lock where                     */
/*            buf_thbj-attr.upper-prop-code = {&attr-fin-doc}           */
/*        and buf_thbj-attr.prop-code = current-pko-rko                 */
/*        and buf_thbj-attr.obj-type = buf_fin-doc.obj-type             */
/*        and buf_thbj-attr.obj-code = buf_fin-doc.obj-code .           */
/*  end.                                                                */
/*  assign                                                              */
/*  v-current-num = buf_thbj-attr.property-value-integer.               */
  
  v-prn-doc-code = v-prn-doc-code + mValue.
/*  case buf_fin-doc.fin-ext-doc-type:                 */
/*    when {&FDEDT_income_cash} then do:               */
/*      assign                                         */
/*      v-prn-doc-code = substitute("&1&2&3"           */
/*                                  ,prefix-pko        */
/*                                  ,v-current-num  + 1*/
/*                                  ,suffix-pko        */
/*                                  )                  */
/*      v-prev-prn-doc-code = substitute("&1&2&3"      */
/*                              ,prefix-pko            */
/*                              ,v-current-num         */
/*                              ,suffix-pko            */
/*                              )                      */
/*      v-matches = substitute("&1*&2"                 */
/*                                ,prefix-rko          */
/*                                ,suffix-rko          */
/*                                )                    */
/*      v-pl = length(prefix-pko)                      */
/*      v-sl = length(suffix-pko)                      */
/*      .                                              */
/*    end.                                             */
/*    when {&FDEDT_expense_cash} then do:              */
/*      assign                                         */
/*      current-pko-rko = {&attr-fin-doc_current-pko}. */
/*      assign                                         */
/*      v-prn-doc-code = substitute("&1&2&3"           */
/*                                  ,prefix-rko        */
/*                                  ,v-current-num  + 1*/
/*                                  ,suffix-rko        */
/*                                  )                  */
/*      v-prev-prn-doc-code = substitute("&1&2&3"      */
/*                              ,prefix-rko            */
/*                              ,v-current-num         */
/*                              ,suffix-rko            */
/*       )                                             */
/*       v-matches = substitute("&1*&2"                */
/*                                  ,prefix-rko        */
/*                                  ,suffix-rko        */
/*                                  )                  */
/*      v-pl = length(prefix-rko)                      */
/*      v-sl = length(suffix-rko)                      */
/*      .                                              */
/*    end.                                             */
/*  end case.                                          */
  if buf_fin-doc.doc-author = {&auto} then do:
    assign
    buf_fin-doc.prn-doc-code = v-prn-doc-code.
    p-update-counter-flag = yes.
/*    p-update-counter = v-current-num + 1.*/
  end.
/*  if buf_fin-doc.doc-author = {&manual} then do:                                                                                                                            */
/*    if v-prn-doc-code <> buf_fin-doc.prn-doc-code then do:                                                                                                                  */
/*      if buf_fin-doc.prn-doc-code matches v-matches then do:                                                                                                                */
/*        define variable v-dop as character no-undo .                                                                                                                        */
/*        v-dop = buf_fin-doc.prn-doc-code.                                                                                                                                   */
/*        if v-pl > 0 then do:                                                                                                                                                */
/*          v-dop = substring(buf_fin-doc.prn-doc-code, v-pl + 1).                                                                                                            */
/*        end.                                                                                                                                                                */
/*        if v-sl > 0 then do:                                                                                                                                                */
/*          v-dop = substring(v-dop, 1, length(v-dop) - v-sl)      .                                                                                                          */
/*        end.                                                                                                                                                                */
/*        if trim(v-dop, "01234567890") = ""                                                                                                                                  */
/*        and length(v-dop) < 9                                                                                                                                               */
/*        then do:                                                                                                                                                            */
/*          v-loc-update-counter-flag = yes.                                                                                                                                  */
/*          v-my-counter = integer(v-dop).                                                                                                                                    */
/*        end.                                                                                                                                                                */
/*      end.                                                                                                                                                                  */
/*      run gbl/d-askw.w (input "Уточнение"                                                                                                                                   */
/*                      ,input  substitute("Введенный Вами НОМЕР платежа - &1&2" +                                                                                            */
/*                                            "номер предущего платежа - &3&2" +                                                                                              */
/*                                            "Какой НОМЕР назначить ПЛАТЕЖУ?"                                                                                                */
/*                                            , buf_fin-doc.prn-doc-code                                                                                                      */
/*                                            , {&new-line}                                                                                                                   */
/*                                            , v-prn-doc-code                                                                                                                */
/*                                            )                                                                                                                               */
/*                      ,input "|^"                                                                                                                                           */
/*                      ,input substitute("&1|&1-->&3|&2-->|Отменить"                                                                                                         */
/*                                      , buf_fin-doc.prn-doc-code                                                                                                            */
/*                                      , v-prn-doc-code                                                                                                                      */
/*                                      , (if not v-loc-update-counter-flag then "^disable" else ""))                                                                         */
/*                      ,input substitute("Оставить &1|Оставить &1 и соответственно сдвинуть счетчик|Следующий по порядку - &2 и сдвинуть счетчик номеров|Не закрывать платеж"*/
/*                                        , buf_fin-doc.prn-doc-code                                                                                                          */
/*                                        , v-prn-doc-code                                                                                                                    */
/*                                        )                                                                                                                                   */
/*                      ,input 1                                                                                                                                              */
/*                      ,input 4                                                                                                                                              */
/*                      ,output choice) no-error.                                                                                                                             */
/*                                                                                                                                                                            */
/*    if choice = 4 then do:                                                                                                                                                  */
/*        undo, return error .                                                                                                                                                */
/*      end.                                                                                                                                                                  */
/*      case choice:                                                                                                                                                          */
/*        when 1 then do:                                                                                                                                                     */
/*          /*ничего не надо делать*/                                                                                                                                         */
/*        end.                                                                                                                                                                */
/*        when 2 then do:                                                                                                                                                     */
/*          p-update-counter-flag = yes.                                                                                                                                      */
/*          p-update-counter = integer(v-dop).                                                                                                                                */
/*        end.                                                                                                                                                                */
/*        when 3 then do:                                                                                                                                                     */
/*          assign                                                                                                                                                            */
/*          buf_fin-doc.prn-doc-code = v-prn-doc-code                                                                                                                         */
/*          .                                                                                                                                                                 */
/*          p-update-counter-flag = yes.                                                                                                                                      */
/*          p-update-counter = v-current-num + 1.                                                                                                                             */
/*        end.                                                                                                                                                                */
/*      end case.                                                                                                                                                             */
/*    end.                                                                                                                                                                    */
/*    else do:                                                                                                                                                                */
/*      run gbl/d-askw.w (input "Уточнение"                                                                                                                                   */
/*                      ,input "Сдвинуть счетчик номеров документов?"                                                                                                         */
/*                      ,input "|"                                                                                                                                            */
/*                      ,input substitute("Да|Нет|Отменить")                                                                                                                  */
/*                      ,input substitute("Сдвинуть счетчик|Не сдвигать|Не закрывать платеж")                                                                                 */
/*                      ,input 1                                                                                                                                              */
/*                      ,input 3                                                                                                                                              */
/*                      ,output choice) no-error.                                                                                                                             */
/*      if choice = 4 then do:                                                                                                                                                */
/*        undo, return error .                                                                                                                                                */
/*      end.                                                                                                                                                                  */
/*      case choice:                                                                                                                                                          */
/*        when 1 then do:                                                                                                                                                     */
/*          p-update-counter-flag = yes.                                                                                                                                      */
/*          p-update-counter = v-current-num + 1.                                                                                                                             */
/*        end.                                                                                                                                                                */
/*      end case.                                                                                                                                                             */
/*    end.                                                                                                                                                                    */
/*  end.                                                                                                                                                                      */
end. /*if p-doc-author = {&auto}*/
end procedure. /* auto-fill-prn-doc-code */

procedure release-auto-fill-prn-doc-code :
define input parameter p-update as logical no-undo .
define input parameter p-counter as integer no-undo .
/*if available buf_thbj-attr then do:                  */
/*  if p-update then do:                               */
/*    buf_thbj-attr.property-value-integer = p-counter.*/
/*  end.                                               */
/*  release buf_thbj-attr.                             */
/*end.                                                 */
end procedure. /* release-auto-fill-prn-doc-code */


procedure fill-shift :
define parameter buffer buf_fin-doc for ub.fin-doc.
define variable v-obj-db-num as integer no-undo .
define variable l-shift-on as logical no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  { gbl/objdbnum.i buf_fin-doc.obj-type buf_fin-doc.obj-code v-obj-db-num }
  if v-obj-db-num = g#db-num then do:
    { gbl/objat.i
      buf_fin-doc.obj-type
      buf_fin-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }
    if l-shift-on
    and buf_fin-doc.shift-flag = integer({&fin-flag-shift})
    then do:
      /*найдем смены если их нет - создадим*/
      if buf_fin-doc.shift-date = ?
      or buf_fin-doc.shift-num = 0
      or buf_fin-doc.shift-name = ''
      then do:
        { gbl/curshift.i
          buf_fin-doc.obj-type
          buf_fin-doc.obj-code
          varobj-shift-date
          varobj-shift-num
          varobj-shift-name
        }

        run gbl/chk-date.p
        ( input buf_fin-doc.obj-type
        , input buf_fin-doc.obj-code
        , input buf_fin-doc.fact-date
        , input v-time
        , input varobj-shift-date
        , input varobj-shift-num
        , input no) no-error.
        if error-status:error then do:
          undo main-block, return error substitute( "Ошибка при проверке сменной даты&1&2&1&3"
                                            ,{&new-line}, error-status :get-message (1), return-value  )   .

        end.
        assign
        buf_fin-doc.shift-date = varobj-shift-date
        buf_fin-doc.shift-num = varobj-shift-num
        buf_fin-doc.shift-name = varobj-shift-name
        .
      end. /*if buf_fin-doc.shift-date = ?*/
    end.
    else do:
      l-shift-on = no.
    end.
  end. /*if v-obj-db-num = g#db-num then do:*/
end.

end procedure. /* fill-shifr */

procedure get-fact-num :
define input parameter p-host-code as integer no-undo .
define output parameter p-fact-num as integer no-undo .
define buffer buf_sysconf for ub.sysconf.

find first buf_sysconf no-lock where
          buf_sysconf.host-code = p-host-code.

do while true:
  p-fact-num =  next-value(s-fin-doc-fact , {&db-name_schema}).
  if g#db-num = buf_sysconf.firm-db-num
  and p-fact-num modulo 10 > 0 then do:
    leave.
  end.
  if g#db-num <> buf_sysconf.firm-db-num
  and p-fact-num modulo 10 = 0 then do:
    leave.
  end.
end.
end procedure. /* get-fact-num */

procedure Mycounter:
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define output parameter oCount    as int64 no-undo.
run utl/getnextcount.p ("cashbookrule", current-ruleID, current-pko-rko, mparam  ,output oCount    ). 
end procedure.

