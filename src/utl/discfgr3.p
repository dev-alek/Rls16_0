block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: discfgr3.p $
$Archive: utl/discfgr3.p $

Удаление dis-cfg-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discfgr3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/discfgr3.p $":U .
define variable vss-description as character no-undo init "Удаление dis-cfg-rule".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .

define buffer buf_dis-cfg-rule  for ub.dis-cfg-rule.

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
  find first buf_dis-cfg-rule exclusive-lock where
        recid(buf_dis-cfg-rule) = p-rec .

  delete buf_dis-cfg-rule no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении"
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("dis-cfg-rule&1Таблица связи &2 Место использ. &3&1" +
                         "Шаблон прaвила скидок &4 Шаблон расписаний &5 Поле уникальности &6"
                         ,{&new-line}
                         , buf_dis-cfg-rule.table-name
                         , buf_dis-cfg-rule.pos-type
                         , buf_dis-cfg-rule.templ-rl-root
                         , buf_dis-cfg-rule.time-templ-rl-root
                         , buf_dis-cfg-rule.self-nonunique
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