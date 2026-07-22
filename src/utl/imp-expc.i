/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия файлов в выбранной директории - экспорт-импорт локальных таблиц БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/24/05
Author: Bakhtadze Natalya
Creation date: 09/24/05

*/

Procedure check-iefile:
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
find first ub.sys-ctrl No-LOCK No-ERROR.
if not avail ub.sys-ctrl then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Отсутствует информация в таблице sys-ctrl"
                          )
                                          ).
    return error.
end.
FIND FIRST ub.db No-LOCK WHERE
           ub.db.db-num = ub.sys-ctrl.db-num NO-ERROR.
if not avail ub.db then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Отсутствует информация в таблице db"
                          )
                                          ).
    return error.
end.
full_name = p-dir-name + "\":U + corr-file-name(string(ub.db.db-key)) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не найден файл данных &1", full_name
                            )
                                            ).
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message substitute("Уже имеется в выбранной директории файл с именем &1&2" +
                       "совпадающим с именем одного из файлов экспорта&2" +
                       "Перезаписывать?"
                       ,full_name
                       , {&new-line})
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
end.

END PROCEDURE.

/* $Workfile$ e n d */