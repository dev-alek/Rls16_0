block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление платежа закрытого до факт с пересчетом всяких там архивов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-code like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-fact-delete as logical no-undo . /*yes - удаление закрытого на факт*/
define input parameter p-silent as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление платежа закрытого до факт".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ str/lib-farh.i }
{ ref/fd-attr.i }
{ trg/fin-doch.i }
{ gbl/thbjattr.i }
{ str/lib-farh.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-mes as character no-undo .
  define variable v-ret-mess as character no-undo .
  define variable v-status_ like ub.fin-doc.status_ no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-pmnt-code as character no-undo .
  define variable v-full-pmnt-code as character no-undo .

  define buffer buf_fin-doc for ub.fin-doc .
  define buffer buf_fin-connect for ub.fin-connect.
  define buffer buf_fin-statement-line for ub.fin-statement-line.
  define buffer buf_payment for ub.payment.
  define buffer buf0_payment for ub.payment.
  define buffer buf_fin-ob for ub.fin-ob.

  find first buf_fin-doc exclusive-lock where
            buf_fin-doc.host-code = p-host-code
        AND buf_fin-doc.fin-doc-code = p-fin-doc-code
    no-error .
  if not available buf_fin-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Фирма" p-host-code
      "Платеж" p-fin-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if (buf_fin-doc.status_ = {&fin-fact}
  and p-fact-delete = no)
  or
    (buf_fin-doc.status_ <> {&fin-fact}
  and p-fact-delete = yes)
  or (not g#news and p-fact-delete = ?)
    then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Фирма" p-host-code
      "Платеж" p-fin-doc-code skip
      "Статус" buf_fin-doc.status_
      "Параметр p-fact-delete" p-fact-delete
      view-as alert-box error .
    undo main-block, return error .
  end.
/*  define variable v-log as logical no-undo .                                                     */
/*  define variable v-out-mess as character no-undo .                                              */
/*  define variable v-cash-book-place as character no-undo .                                       */
/*  v-cash-book-place = buf_fin-doc.trn-doc-code.                                                  */
/*  if not g#news then do:                                                                         */
/*  { str/finchkdb.i                                                                               */
/*    buf_fin-doc.host-code                                                                        */
/*    buf_fin-doc.fin-doc-code                                                                     */
/*    buf_fin-doc.obj-type                                                                         */
/*    buf_fin-doc.obj-code                                                                         */
/*    buf_fin-doc.fin-ext-doc-type                                                                 */
/*    v-cash-book-place                                                                            */
/*    ?                                                                                            */
/*    v-log                                                                                        */
/*    v-out-mess                                                                                   */
/*    no-error }                                                                                   */
/*  if error-status:error then do:                                                                 */
/*    v-mes =  substitute("Ошибка при проверке возможности удаления документа в данной БД &1&2&1&3"*/
/*                                                , {&new-line}                                    */
/*                                                , error-status:get-message(1)                    */
/*                                                , return-value                                   */
/*                                                ).                                               */
/*    run err-mess in this-procedure (  input v-mes, output v-ret-mess).                           */
/*    undo main-block, return error v-ret-mess.                                                    */
/*  end.                                                                                           */
/*  if not v-log then do:                                                                          */
/*    v-mes = substitute("Невозможно удалить документ в данной БД:&1&2", {&new-line}, v-out-mess). */
/*    run err-mess in this-procedure (  input v-mes, output v-ret-mess).                           */
/*    undo main-block, return error v-ret-mess.                                                    */
/*  end.                                                                                           */
/*  end.                                                                                           */
  if p-fact-delete = yes then do:
    find first buf_fin-connect NO-LOCK
      where buf_fin-connect.host-code = buf_fin-doc.host-code
        and buf_fin-connect.fin-doc-code = buf_fin-doc.fin-doc-code
    no-error .

    if available buf_fin-connect then do:
      define variable  v-delcnavt        as logical no-undo .
      define variable  par-type          as character no-undo .
      define variable  v-found           as logical   no-undo .
      define variable  v-value-date      as date   no-undo .
      define variable  v-value-decimal   as decimal   no-undo .
      define variable  v-value-integer   as integer   no-undo .
      define variable  v-value-logical   as logical   no-undo .
      define variable  v-value-character as character no-undo .

      run thbjattr_value in this-procedure  (
        input   "",
        input   0 ,
        input   {&attr-fin-global} ,
        input   'del-conn-avt'  ,
        output  v-value-character ,
        output  v-value-date      ,
        output  v-value-decimal   ,
        output  v-value-integer   ,
        output  v-delcnavt  ,
        output  par-type            ,
        output  v-found
        ) no-error
        .
      if error-status :error then v-delcnavt = false .
      if v-delcnavt = no then do: /* параметр, удалять ли связи автоматом */
        assign
        v-mes = substitute("Нельзя удалять платеж: код фирмы &1, вн № &2: платеж связан с фин. обязательствами."
                          , p-host-code , p-fin-doc-code) .
        run err-mess in this-procedure (  input v-mes, output v-ret-mess).
        undo main-block, return error v-ret-mess.
      end.
      else do:
        for each buf_fin-connect exclusive-lock
          where buf_fin-connect.host-code = buf_fin-doc.host-code
            and buf_fin-connect.fin-doc-code = buf_fin-doc.fin-doc-code
       on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
       on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
       on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
       :
          find first buf_fin-ob exclusive-lock where
                    buf_fin-ob.host-code = buf_fin-connect.host-code
                and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code .
          assign
            buf_fin-ob.con-sum-rubl  = buf_fin-ob.con-sum-rubl  - buf_fin-connect.sum-rubl
            buf_fin-ob.con-sum-base  = buf_fin-ob.con-sum-base  - buf_fin-connect.sum-base
            buf_fin-ob.con-sum-doc   = buf_fin-ob.con-sum-doc   - buf_fin-connect.sum-doc
            buf_fin-ob.con-sum-contr = buf_fin-ob.con-sum-contr - buf_fin-connect.sum-contr
          .
          if buf_fin-ob.con-sum-contr = 0 then assign buf_fin-ob.con-stat = 0 .
          else                             assign buf_fin-ob.con-stat = 1 .
          delete buf_fin-connect .
        end.
      end.
    end. /*if available buf_fin-connect then do:*/
    find first buf_fin-statement-line NO-LOCK
      where buf_fin-statement-line.host-code = buf_fin-doc.host-code
        and buf_fin-statement-line.fin-doc-code = buf_fin-doc.fin-doc-code
    no-error .
    if available buf_fin-statement-line then do:
      for each buf_fin-statement-line where
                buf_fin-statement-line.host-code = buf_fin-doc.host-code
           and  buf_fin-statement-line.fin-doc-code = buf_fin-doc.fin-doc-code
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        assign
        buf_fin-statement-line.fin-doc-code = 0
        buf_fin-statement-line.fin-doc-type = '':U
        .
      end.
    end.
    assign
    buf_fin-doc.is-del = true
    /*простановка ? в атрибут где bde-date осуществляется fin-doch.i */
    .

    /*создаем копию*/
    if not g#news then do:
      run write-fin-doc-history in this-procedure (buffer buf_fin-doc) no-error .
      if error-status :error then do:
        run err-mess in this-procedure (  input "Ошибка при копировании в историю удаляемых платежей", output v-ret-mess).
        undo main-block, return error v-ret-mess.
      end.
    end.
    /* пересчет архивов по платежам */
    { str/taskclcd.i p-host-code p-fin-doc-code "'all':U" g#userid "'delete':u" no-error }
    if error-status :error then do:
      run err-mess in this-procedure (  input "Ошибка при пересчете остатков по платежам", output v-ret-mess).
      undo main-block, return error v-ret-mess.
    end.
    if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_cash}
    or buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_cashless}
    or buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_payoff}
    then do:
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
          run cur-time in this-procedure( output v-today, output v-time).
          if v-pmnt-code = '':U then do:
            find first buf0_payment no-lock where
                    buf0_payment.source-type = {&pmnt-fin-doc}
                AND buf0_payment.source-ref = substitute("-&1", string(p-fin-doc-code)) no-error.
            if available buf0_payment then do:
              assign
              v-pmnt-code = entry(1, buf0_payment.pmnt-code, "_").
            end.
          end.
          assign
          v-full-pmnt-code  = substitute("&1_&2", v-pmnt-code, entry(2, buf_payment.pmnt-code, "_"))
          .
          run ref/payment1.p (
                             input {&add-def}
                            ,input  yes /*p-silent*/
                            ,input-output v-full-pmnt-code
                            ,input buf_payment.cli-type
                            ,input buf_payment.cli-code
                            ,input buf_payment.payer-type
                            ,input buf_payment.payer-code
                            ,input buf_payment.host-code
                            ,input - buf_payment.tot-cli
                            ,input - buf_payment.tot-base
                            ,input - buf_payment.tot-rubl
                            ,input buf_payment.exch-date
                            ,input buf_payment.exch-code
                            ,input buf_payment.exch-rate
                            ,input buf_payment.exch-scale
                            ,input buf_payment.base-rate
                            ,input buf_payment.base-scale
                            ,input buf_payment.due-date
                            ,input v-today
                            ,input buf_payment.source-type
                            ,input substitute("-&1", buf_payment.source-ref)
                            ,input buf_payment.d-card
                            ,input buf_payment.pay-code
                            ,input buf_payment.status_
                            ,input buf_payment.PS
                            ,INPUT buf_fin-doc.user-name-fact
                            ,INPUT buf_fin-doc.user-name-fact
                            ) no-error .
          if error-status:error then do:
            run err-mess in this-procedure (  input substitute("Ошибка при порождении ОТРИЦАТЕЛЬНЫХ привязок по ДК&1&2&1&3"
                                                                , {&new-line}
                                                                , error-status:get-message(1)
                                                                , return-value )
                                            , output v-ret-mess).
            undo main-block, return error v-ret-mess.
          end.
        end.
        run str/saledc.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input ? /*p-log-handle*/
          ,input {&dct-proc_delete-fin-doc-from-card}
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
          run err-mess in this-procedure (  input "Ошибка при пересчете итогов по ДК, привязанным к платежу", output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end. /*v-num-dc > 0*/
    end. /*if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_cash}*/
  end. /*p-fact-delete*/
  delete buf_fin-doc no-error .
  if error-status:error then do:
    run err-mess in this-procedure (  input substitute("Ошибка при удалении платежа:&1&2&1&3"
                                                      , {&new-line}
                                                      , error-status:get-message(1)
                                                      , return-value )
                                    , output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&4 вн. № &5&4 статус &6&4&7"
                            , buf_fin-doc.fin-doc-type
                            , p-host-code
                            , buf_fin-doc.prn-doc-code
                            , {&new-line}
                            , p-fin-doc-code
                            , v-status_
                            , p-mess
                            ).

  CASE p-silent:
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.