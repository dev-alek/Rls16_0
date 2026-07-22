block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление prop-ref

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление prop-ref".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/calldscr.i }

define variable v-mess as character no-undo .
define buffer buf_prop-ref  for dictdb.prop-ref.
define buffer buf_prop-script for ub.prop-script.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref-call for ub.prop-ref-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_prop-ref exclusive-lock where
          recid(buf_prop-ref) = p-rec .
  if buf_prop-ref.sum-id = '':U
  or buf_prop-ref.dt-code = 0 then do:
    v-mess = substitute("Нельзя удалить главный срез (с кодом 0 и пустым идентификатором)" ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  define variable v-ok as logical no-undo .
  define variable v-mwss as character no-undo .

  /*проверим что нет записей*/
  find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = buf_prop-ref.dtm-code.
  run rul/pref-chk.p ( input {&deletion}
                      ,input "prop-ref3"
                      ,input buf_prop-ref.dtm-code
                      ,input buf_prop-ref.dt-code
                      ,output v-ok
                      ,output v-mess) no-error .

  if error-status:error
  or not v-ok then do:
    v-mess = substitute("Нельзя удалить cрез/итог: &1", v-mess ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  /*удалим записи словаря*/
  for each buf_ruledict where
          buf_ruledict.uniq-key-rec = buf_prop-ref.uniq-key-rec
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
   for each buf_ruledict-param where
           buf_ruledict-param.entry-id = buf_ruledict.entry-id
   on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_ruledict-param.
   end.
   delete buf_Ruledict.
  end.

  delete buf_prop-ref no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Срез данных по ДК: код объекта &1 код среза &2:&3&4"
                         , buf_prop-ref.dtm-code
                         , buf_prop-ref.dt-code
                         , {&new-line}
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