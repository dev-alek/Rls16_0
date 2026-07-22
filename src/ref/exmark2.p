block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exmark2.p $
$Archive: ref/exmark2.p $

Изменение статуса акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06


*/

define input parameter p-db-num    as integer no-undo.
define input parameter p-mark-code as integer no-undo.
define input parameter p-new-stts  as integer no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exmark2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/exmark2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса акцизной или специальной марки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-msg-text as char no-undo.

define buffer buf_ex-mark for ub.ex-mark.
define buffer sch_ex-mark for ub.ex-mark.

main-block :
do
on error undo, return error substitute( "&1 &2", return-value, error-status :get-message( error-status :num-messages ) )
:
  find buf_ex-mark exclusive-lock
    where buf_ex-mark.db-num    = p-db-num
      and buf_ex-mark.mark-code = p-mark-code
    no-error no-wait.
  if not available buf_ex-mark then do:
    if locked (buf_ex-mark) then do:
      assign
        v-msg-text = "Запись редактируется другим пользователем"
      .
    end.
    else do:
      assign
        v-msg-text = "Не найдена запись акцизной или специальной марки~n"
                   + substitute ("db-num = &1 ; mark-code = &2", p-db-num, p-mark-code)
      .
    end.
    return error v-msg-text.
  end.

  /* Нельзя восстановить удаленную запись, если существует текущая с таким же кодом марки */
  if buf_ex-mark.stts = integer({&deleted-status-int}) then do:
    find first sch_ex-mark no-lock
      where sch_ex-mark.mark-name = buf_ex-mark.mark-name
        and sch_ex-mark.stts      = integer({&current-status-int})
      no-error.
    if available sch_ex-mark then do:
      assign
        v-msg-text = "Восстановление записи невозможно, поскольку существует запись~n" +
                     "с тем же кодом марки в статусе 'Текущий'"
      .
      return error v-msg-text.
    end.
  end.

  assign
    buf_ex-mark.stts = p-new-stts
  .
  release buf_ex-mark no-error .
  if error-status:error then do:
    assign
      v-msg-text = "Ошибка при сохранении записи АКЦИЗНОЙ ИЛИ СПЕЦИАЛЬНОЙ МАРКИ~n"
                 + error-status:get-message(1) + "~n"
                 + return-value
    .
    undo main-block, return error v-msg-text.
  end.
end.

return.