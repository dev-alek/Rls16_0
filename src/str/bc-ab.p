block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-ab.p $
$Archive: str/bc-ab.p $

Анализ бар-кодов

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Created:  Суслов Алексей Юрьевич  27 Dec 1999


*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter  b-c       as char no-undo.              /* код для анализа, если ? - запрашивается */
define output parameter parb-code like bar-code.b-code initial ? no-undo.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/anlz-bc.i new }
def var rate LIKE doc-line.cli-base-rate NO-UNDO. /* коэффициент для единиц из бар-кода */
DEF var ret-mode AS CHAR                 NO-UNDO. /* режим обработки бар-кода */
DEF var add-scan AS LOG INITIAL NO       NO-UNDO.
def var bar-str  LIKE prod-bc.b-str      NO-UNDO. /* строка для чтения бар-кода из файла */
def var is-err   as log                  no-undo.

if b-c = ? then do:
  /* цикл сделан для того, чтоб удобно было смотреть несколько кодов, не выходя из chs-bc.w */
  REPEAT:
    run str/chs-bc.w (input parparentproc,
                  "Анализ бар-кода", ?, ?, NO,
                  output b-c,
                  output rate,
                  output ret-mode,
                  input-output add-scan,
                  input-output bar-str) no-error.
    if error-status :error then do:
      message "Неверный выбор бар-кода."
              view-as alert-box.
      return error.
    end.
    if b-c = ? THEN
      LEAVE.
    run analize-one no-error.
  END.
end.
else do:
  run analize-one no-error.
  if error-status:error then
  message "Ошибка при поиске бар-кода."
  view-as alert-box error.
end.

procedure analize-one:
  FOR EACH un-bc:
    DELETE un-bc.
  END.
  run str/bc-anlz.p (parparentproc, "code-add", b-c, yes, output is-err, output table in-bc) no-error.
  if error-status:error then do:
    message "Неверный анализ бар-кода."
            view-as alert-box error.
    return error.
  end.
  FIND LAST un-bc NO-ERROR.
  IF AVAILABLE un-bc then do:
     ASSIGN parb-code = un-bc.b-c.
     run str/bc-inf.w (
                    input parparentproc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,recid (un-bc)
                   ,output table in-bc) no-error.
  end.
  else return error.
end.