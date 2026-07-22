block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перевод статусов для банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/06
Author: Bakhtadze Natalya
Creation date: 11/19/06

*/

define input parameter p-host-code      like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code      like ub.fin-statement.sttm-code no-undo .
define input parameter p-close-mode     as character no-undo .
define input parameter p-author         as character no-undo . /*может быть пусто или cl-bank*/
define input parameter p-status_        as character no-undo . /*тот что будет*/
define input-output parameter p-status-date    like ub.fin-statement.fact-date no-undo .
define input parameter p-silent                       as logical no-undo .
/*если = ?, то сегодня*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перевод статусов для банковских выписок".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ ref/fnstmip.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-fact-order as decimal no-undo .
define variable v-fact-order-start as decimal no-undo .
define variable v-fact-order-end as decimal no-undo .
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
define variable v-prn-doc-code like ub.fin-statement.prn-doc-code no-undo .
define variable v-fins-doc-type like ub.fin-statement.fins-doc-type no-undo .

define buffer buf_fin-statement for ub.fin-statement.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_fin-statement exclusive-lock where
            buf_fin-statement.host-code = p-host-code
         AND buf_fin-statement.sttm-code = p-sttm-code .
  /*проверим еще раз!!! findgraf.p*/
  assign
  v-prn-doc-code = buf_fin-statement.prn-doc-code
  v-fins-doc-type = buf_fin-statement.fins-doc-type
  .
  run trg/finsgraf.p (
                  input  buf_fin-statement.host-code
                  ,input  buf_fin-statement.sttm-code
                  ,input  p-close-mode
                  ,input  p-author
                  ,input  buf_fin-statement.status_
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
  v-pre-status_ = buf_fin-statement.status_
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
  CASE buf_fin-statement.fins-doc-type:
    when {&standard-sttm} then do:
      run check-standard-sttm in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
  END CASE.
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
      buf_fin-statement.status_ = p-status_
      buf_fin-statement.fact-date = ?
      buf_fin-statement.bank-date = ?
      buf_fin-statement.fact-order-start = 0
      buf_fin-statement.fact-order-end = 0
      .
    end.
    when {&fin-bank} then do:
      assign
      buf_fin-statement.status_ = p-status_
      buf_fin-statement.fact-date = ?
      buf_fin-statement.bank-date = v-date
      buf_fin-statement.fact-order-start = 0
      buf_fin-statement.fact-order-end = 0
      .
    end.
    when {&fin-fact} then do:
      run factord in this-procedure (
                                       input  buf_fin-statement.start-date
                                      ,input  v-time
                                      ,input  next-value(s-fin-sttm-fact , {&db-name_schema})
                                      ,input  ? /*p-shift-date*/
                                      ,input  0 /*p-shift-num*/
                                      ,input  no
                                      ,output v-fact-order-start
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).
      run factord in this-procedure (
                                       input  buf_fin-statement.end-date
                                      ,input  v-time
                                      ,input  next-value(s-fin-sttm-fact , {&db-name_schema})
                                      ,input  ? /*p-shift-date*/
                                      ,input  0 /*p-shift-num*/
                                      ,input  no
                                      ,output v-fact-order-end
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).

      assign
      buf_fin-statement.status_ = p-status_
      buf_fin-statement.fact-date = v-date
      buf_fin-statement.fact-order = v-fact-order
      buf_fin-statement.fact-order-start = v-fact-order-start
      buf_fin-statement.fact-order-end = v-fact-order-end
      .
    end.
  END CASE.
  release buf_fin-statement no-error .
  if error-status:error then do:
    run err-mess (substitute("Ошибка при смене статуса на &1", p-status_), output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
end. /*doe*/

procedure check-standard-sttm :

  do
  on error undo, return error
  :
    &scop prfx buf_fin-statement.
    run ref/finstm01.p (
                    input {&update}
                    ,input p-close-mode
                    {&all-fin-statement-params-doc-status-transfer}
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности выписки типа &1 при переводе на статус &2: &3", buf_fin-statement.fins-doc-type, p-status_, v-err-mess).
     end.
  end.

end procedure. /* check-standard-sttm */




PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("БАНКОВСКАЯ ВЫПИСКА &1: фирма: &2 N: &3,&5вн.код выписки &4&5&6"
                            , buf_fin-statement.prn-doc-code
                            , buf_fin-statement.host-code
                            , buf_fin-statement.fins-doc-type
                            , buf_fin-statement.sttm-code
                            , {&new-line}
                            , p-mess
                            ).

  CASE p-silent:
    when yes then do:
      if available buf_fin-statement then
      assign
      p-ret-mess =  substitute("БАНКОВСКАЯ ВЫПИСКА &1: фирма: &2 N: &3,&5вн.код выписки &4&5&6"
                                , buf_fin-statement.prn-doc-code
                                , buf_fin-statement.host-code
                                , buf_fin-statement.fins-doc-type
                                , buf_fin-statement.sttm-code
                                , {&new-line}
                                , p-mess
                                ).

      else
      assign
      p-ret-mess =  substitute("БАНКОВСКАЯ ВЫПИСКА &1: фирма: &2 N: &3,&5вн.код выписки &4&5&6"
                                , v-prn-doc-code
                                , p-host-code
                                , v-fins-doc-type
                                , p-sttm-code
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