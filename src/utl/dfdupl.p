block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dfdupl.p $
$Archive: utl/dfdupl.p $

Создание дополнительных таблиц и полей для компиляции файлов

Автор: Перваков Михаил Сергеевич
Дата создания: 02/11/02
Author: Mikhail Pervakov
Creation date: 02/11/02

Таким образом можно будет определить все файлы, в которых указаны не полные имена
файлов или таблиц

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dfdupl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dfdupl.p $":U .
define variable vss-description as character no-undo init "Создание дополнительных таблиц и полей для компиляции файлов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define stream slog .

define variable lok as logical   no-undo .
message
  "Генерация структуры БД с повторяющимися полями и таблицами" skip
  "для компиляции с поиском сокращений имен таблиц и полей БД" skip
  "Продолжить?" skip
  view-as alert-box question buttons yes-no update lok .
if lok <> true then do:
  return .
end.

output stream slog to value('dfdupl.df':u) .

do
on error undo, return error return-value
:
  define variable v-extra-char as character no-undo .
  assign
    v-extra-char = '###':u
  .

  for each _File no-lock
    where _File._Hidden = False
  on error undo, return error
  :
    run waitfram-show in this-procedure
      (input _File._File-name
      ) .

    put stream slog unformatted
      'ADD TABLE "' + _File._File-Name + v-extra-char + '"' + {&new-line}
      + {&new-line}
      .


    for each _Field of _File no-lock
    on error undo, return error
    :

      put stream slog unformatted
        'ADD FIELD "' + _Field._Field-Name + '" OF "'
        +  _File._File-Name + v-extra-char + '" AS ' + _Field._Data-type + {&new-line}
        + {&new-line}
        .

      put stream slog unformatted
        'ADD FIELD "' + _Field._Field-Name + v-extra-char + '" OF "'
        +  _File._File-Name + '" AS ' + _Field._Data-type + {&new-line}
        + {&new-line}
        .

      put stream slog unformatted
        'ADD FIELD "' + _Field._Field-Name + v-extra-char + '" OF "'
        +  _File._File-Name + v-extra-char + '" AS ' + _Field._Data-type + {&new-line}
        + {&new-line}
        .
    end.

  end.

  run waitfram-hide in this-procedure .
end.

output stream slog close .

message
  "Генерация структуры БД успешно закончено" skip
  "Структура выведена в файл" 'dfdupl.df':u skip
  view-as alert-box information .