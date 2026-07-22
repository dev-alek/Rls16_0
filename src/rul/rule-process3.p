block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление rule-process

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/22/08
Author: Bakhtadze Natalya
Creation date: 07/22/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление rule-process".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_rule-process  for dictdb.rule-process.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-process exclusive-lock where
          recid(buf_rule-process) = p-rec .

  delete buf_rule-process no-error.
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
      p-mess = substitute("Звено процесса: тип &1 id &2 Старт из &3 link-id &4&5:&6"
                         , buf_rule-process.pchain-type
                         , buf_rule-process.pchain-id
                         , buf_rule-process.start-from
                         , buf_rule-process.link-id
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