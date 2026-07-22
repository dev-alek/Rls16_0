block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: $
$Archive: $

Утилита создания и заполнения ссылков на расписание ВСЕГДА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/09/10
Author: Bakhtadze Natalya
Creation date: 06/09/10

*/


define input parameter p-install as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Утилита создания и заполнения ссылков на расписание ВСЕГДА".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/disrules.i "work" }
{ gbl/distruls.i "work" }

define variable start-time     as integer no-undo .
define variable current-time   as integer   no-undo .
define variable v-ind          as integer no-undo .
define variable v-err-count    as integer no-undo .
define variable v-file-name    as char no-undo .
define variable v-ii as integer no-undo .
define variable v-template as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer buf_sys-ctrl for ub.sys-ctrl.
DEFINE TEMP-TABLE tt0-term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.


v-file-name = substitute("&1.txt", entry(1, this-procedure:file-name, ".")).

def frame a
  "Пересылка заполненных time-rule-num  и time-templ-rl-root таблицы dis-rule"
  v-ind        format "->>>>>>>>9" label "Количество записей" skip
  current-time format "->>>>>>>>9" label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Обработка правил скидок"
  .


if p-install = false then do:
  define variable lok as logical no-undo .
  message
    vss-description skip(0)
    "Переслать на УБД заполненные поля time-rule-num и time-templ-rl-root таблицы dis-rule" skip(0)
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.
end.


do
on error undo, return error
:
  assign
    start-time = time
  .
  view frame a .
  find first ub.sys-ctrl No-LOCK.
  if ub.sys-ctrl.db-num > 0 then do:
    message
    "На УБД утилиту запускать не надо!"
    view-as alert-box warning.
    return ''.
  end.
&scop templates "5,6,8,9,20,42,48,49,55,56,76"
  do v-ii = 1 to num-entries({&templates}):
    assign
    v-template = integer(entry(v-ii, {&templates})).
    _dis-rule:
    for each ub.dis-rule where ub.dis-rule.templ-rl-root = v-template
    and ub.dis-rule.rule-num > {&max-num-dr-template}
    on error undo, return error
    :
      define variable v-found as logical no-undo .
      v-found = yes.
    end.
  end.
  if v-found then do:
    do v-ii = 1 to num-entries({&templates}):
      assign
      v-template = integer(entry(v-ii, {&templates})).
      _dis-rule:
      for each ub.dis-rule where ub.dis-rule.templ-rl-root = v-template
      and ub.dis-rule.rule-num > {&max-num-dr-template}
      and ub.dis-rule.root = yes
      on error undo, return error
      :

        assign
          v-ind        = v-ind + 1
          current-time = time - start-time
        .
        if v-ind mod 10 = 0 then do:
          display
          v-ind current-time with frame a .
        end.
        run str/callnews.p
          (input {&table_dis-rule}
          ,input (buffer ub.dis-rule:handle)
          ) no-error.
      end. /*    for each ub.dis-rule where ub.dis-rule.templ-rl-root = v-template*/
    end. /*  do v-ii = 1 to num-entries({&templates}):*/
  end. /*if  v-found then do:*/

  if p-install = false then do:
    message
      vss-description skip
      "Утилита завершила работу" skip
      view-as alert-box information .
  end.
END.


procedure err-mess :
define input parameter p-err-mess as character no-undo .

  do
  on error undo, return error
  :
    output to value(v-file-name) append.
    put unformatted p-err-mess skip.
    output close.

  end.

end procedure. /* err-mess */

