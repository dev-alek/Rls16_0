block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление prop-map

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
define variable vss-description as character no-undo init "Удаление prop-map".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_prop-map  for dictdb.prop-map.
define buffer buf_prop-script for ub.prop-script.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    /*удалим записи словаря*/
  find first buf_prop-map exclusive-lock where
          recid(buf_prop-map) = p-rec .
  for each buf_ruledict where
          buf_ruledict.uniq-key-rec = buf_prop-map.uniq-key-rec
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
   for each buf_ruledict-param where
           buf_ruledict-param.entry-id = buf_ruledict.entry-id
   on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_ruledict-param.
   end.
   delete buf_Ruledict.
  end.
  delete buf_prop-map no-error.
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
      p-mess = substitute("Свойство объекта: код объекта &1 код свойства &2:&3 &4"
                         , buf_prop-map.dtm-code
                         , buf_prop-map.node-code
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
