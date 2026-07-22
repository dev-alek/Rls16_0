block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: idxinact.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/idxinact.p $":U .
define variable vss-description as character no-undo init "Проверяет что все индексы активны и выдает список неактивных индексов".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
        then "ВНИМАНИЕ! В базе данных есть неактивные word индексы." + chr(10)
           + "Проверте правила разбиения на слова в базе данных."
        else ""
       ) skip
    "Для активизации индексов необходимо:" skip
    "1." + chr(9) + "Остановить базу данных" skip
    "2." + chr(9) + "Сделать архивную копию базы данных. ЭТО ОБЯЗАТЕЛЬНО." skip
    "3." + chr(9) + "Проверить внутренние настройки базы данных" skip
    chr(9) + "Кодовые страницы, правила преобразования регистра, правила разбиения на слова и т.д." skip
    "4." + chr(9) + "Запустить перестройку индексов" skip
    chr(9) + "_proutil " + v-database-name + ".db -C idxbuild" skip
    "5." + chr(9) + "Указать таблицы и индексы, которые требуют активизации" skip
    "6." + chr(9) + "Для завершения выбора индексов необходимо" skip
    chr(9) + "указать восклицательный знак '!'." skip
    view-as alert-box error.
end.
else do:
  message
    "Все индексы активны"
    view-as alert-box information .
end.
