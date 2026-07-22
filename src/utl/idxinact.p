block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: idxinact.p $
$Archive: utl/idxinact.p $

Проверяет что все индексы активны и выдает список неактивных индексов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/09/09
Author: Dmitry Ukhanov
Creation date: 12/09/09

Author1: Mikhail Pervakov
Creation date: 10/31/00

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: idxinact.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/idxinact.p $":U .
define variable vss-description as character no-undo init "Проверяет что все индексы активны и выдает список неактивных индексов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable l-wordidx-inactive as logical no-undo init false .

find first _index
  where _index._active = false
  no-error .
if not available _index then do:
  message
    "Все индексы активны"
    view-as alert-box information .
  return .
end.



define variable v-database-name as character no-undo .

assign
  v-database-name = dbname
.

run gbl/d-prompt.w (
    'title=\'
    + 'text1=Enter database name\'
    + 'text2=without .db extension\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output v-database-name
    ).

if return-value = 'false':u then do:
  return .
end.

define variable v-file-name as character no-undo .

assign
  v-file-name = v-database-name + "_inact.txt"
.

output to value(v-file-name) .

define variable i-ind as integer no-undo .

for each _index
  where _index._active = false
:
  assign
    i-ind = i-ind + 1
  .

  if _index._Wordidx <> ? then do:
    assign
      l-wordidx-inactive = true
    .
  end.

  find first _file of _index .

  display _file._file-name _index._index-name .
end.

output close .

if i-ind <> 0 then do:
  message
    "Неактивно" i-ind "индексов" skip
    "Список неактивных индексов указан в файле" v-file-name skip
    "" (if l-wordidx-inactive
        then "ВНИМАНИЕ! В базе данных есть неактивные word индексы." + {&new-line}
           + "Проверте правила разбиения на слова в базе данных."
        else ""
       ) skip
    "Для активизации индексов необходимо:" skip
    "1." + {&tabulation} + "Остановить базу данных" skip
    "2." + {&tabulation} + "Сделать архивную копию базы данных. ЭТО ОБЯЗАТЕЛЬНО." skip
    "3." + {&tabulation} + "Проверить внутренние настройки базы данных" skip
    {&tabulation} + "Кодовые страницы, правила преобразования регистра, правила разбиения на слова и т.д." skip
    "4." + {&tabulation} + "Запустить перестройку индексов" skip
    {&tabulation} + "_proutil " + v-database-name + ".db -C idxbuild" skip
    "5." + {&tabulation} + "Указать таблицы и индексы, которые требуют активизации" skip
    "6." + {&tabulation} + "Для завершения выбора индексов необходимо" skip
    {&tabulation} + "указать восклицательный знак '!'." skip
    view-as alert-box error.
end.
else do:
  message
    "Все индексы активны"
    view-as alert-box information .

end.