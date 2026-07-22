block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление ruledict-param

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
define variable vss-description as character no-undo init "Удаление ruledict-param".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .

define buffer buf_ruledict-param  for ub.ruledict-param.

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
  find first buf_ruledict-param exclusive-lock where
        recid(buf_ruledict-param) = p-rec .
  if buf_ruledict-param.param-data-type = {&abl-datatype-character}
  and buf_ruledict-param.param-2-data-type = "xsd"
  then do:
    run rul/rdp-clob.p ( buffer buf_ruledict-param
                        ,input {&deletion}) no-error.
    if error-status:error then do:
      v-mess = substitute("Не удалось удалить CLOB &1:&2&3&2&4"
                          ,buf_ruledict-param.init-value-character
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  delete buf_ruledict-param.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Параметр термина: &1 № пар-ра &2 (назв параметра &3):&4&5"
                         , buf_ruledict-param.entry-id
                         , buf_ruledict-param.param-num
                         , buf_ruledict-param.param-name
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