block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-l2.p $
$Archive: ref/stop-l2.p $

Закрытие стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rec as recid no-undo .
define input parameter p-silent as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-l2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-l2.p $":U .
define variable vss-description as character no-undo init "Закрытие стоплиста".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ gbl/getcntxt.i def }

define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-fact-time as integer no-undo .
define variable v-status_ as character no-undo .
define variable v-stop-list-value as character no-undo .
DEFINE VARIABLE d-fact-ord  LIKE ub.stop-list.fact-order NO-UNDO.
DEFINE VARIABLE d-shift-ord LIKE ub.stop-list.fact-order NO-UNDO.
DEFINE VARIABLE day-end-ord LIKE ub.stop-list.fact-order NO-UNDO.
define variable v-fact-num as integer no-undo .
define variable v-status as character no-undo .

define buffer buf_stop-list  for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_Dis-card for ub.dis-card.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедура не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_stop-list exclusive-lock where
        recid(buf_stop-list) = p-rec .
  if buf_stop-list.status_ = {&fact} then do:
    v-mess = substitute("Стоплист &1 уже закрыт до статуса &2"
                        , buf_stop-list.stop-list-code
                        , buf_stop-list.status_
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  { gbl/getcntxt.i get }
  run cur-time in this-procedure ( output v-today, output v-time).
  v-fact-num = NEXT-VALUE( s-stop-list-fact, {&db-name_schema} ).
  RUN factord IN THIS-PROCEDURE (
                                  INPUT v-today
                                 ,INPUT v-time
                                 ,INPUT v-fact-num
                                 ,INPUT ? /*shift-date*/
                                 ,INPUT 0 /*shift-num*/
                                 ,INPUT no /*l-shift-on*/
                                 ,OUTPUT d-fact-ord
                                 ,OUTPUT d-shift-ord
                                 ,OUTPUT day-end-ord
                                ) NO-ERROR.
  IF ERROR-STATUS:ERROR OR
      d-fact-ord = ? OR
      d-fact-ord = 0 THEN DO:
    v-mess   = substitute("Ошибка при определении фактического номера стоплиста&1"
                          ,{&new-line}).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  END.
  if buf_stop-list.classif-type = {&table_dis-card} then do:
    for each buf_stop-list-line no-lock where
           buf_stop-list-line.classif-type = buf_stop-list.classif-type
       and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_stop-list-line.resource_id begins {&table_dis-card}
      and buf_stop-list-line.key#_one = integer({&delete-card}) then do:
        find first buf_dis-card no-lock where
                 buf_dis-card.d-card = buf_stop-list-line.charkey_one no-error.
        if not available buf_dis-card then do:
          v-mess = substitute("!!!Не найдена карта &1 (строка &2)"
                               , buf_stop-list-line.charkey_one
                               , buf_stop-list-line.line-num).
          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else '':U).
        end.
        v-status = {&deleted-status}.
        run ref/dcardi02.p (
                           input parparentproc
                          ,input recid(buf_dis-card)
                          ,input yes /*p-silent */
                          ,input yes  /*p-has-right-to-restore*/
                          ,input "":U /*p-mode2*/
                          ,input {&hn-source-stop-l}
                          ,input buf_stop-list.stop-list-code
                          ,input v-cntxt-obj-type
                          ,input v-cntxt-obj-code
                          ,input-output v-status ) no-error .
        if error-status:error then do:
          v-mess =  substitute("!!!Ошибка при изменении статуса ДК &1 для клиента &2&3&4" +
                                  "&5&4&6"
                                  ,buf_dis-card.d-card
                                  ,buf_dis-card.cli-type
                                  ,buf_dis-card.cli-code
                                  ,{&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).

          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else '':U).
        end. /*if error-status:error then do:*/
      end. /*      if buf_stop-list-line.resource_id begins {&table_dis-card}*/
    end. /*    for each buf_stop-list-line no-lock where*/
  end. /*if p-classif-type = {&table_dis-card} then do:*/
  assign
  buf_stop-list.fact-num   = v-fact-num
  buf_stop-list.fact-order = d-fact-ord
  buf_stop-list.fact-date = v-today
  buf_stop-list.status_ = {&fact}
  .
  release buf_stop-list no-error.
  if error-status:error then do:
    v-mess =  substitute("Ошибка при записи шапки стоплиста &1&2" +
                            "&3&2&4"
                            ,buf_stop-list.stop-list-code
                            ,{&new-line}
                            ,error-status:get-message(1)
                            ,return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Стоплист &1"
                         , buf_stop-list.stop-list-code
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.