block-level on error undo, throw.
define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт конфигурации rule-машины в формате СПН".
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
define variable v-rum-exp-tables as character no-undo .
define variable v-rum-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .
define variable v-fix-file-name as character no-undo .
if num-entries(p-file-name, ".") > 1 then do:
  v-fix-file-name = entry(num-entries(p-file-name, ".") - 1 , p-file-name, ".") + ".fix".
end.
else do:
  v-fix-file-name = entry(num-entries(p-file-name, ".") , p-file-name, ".") + ".fix".
end.
if search(v-fix-file-name) = ? then do:
  message
  substitute("Не найден ПОПРАВОЧНЫЙ файл &1", v-fix-file-name)
  view-as alert-box error .
  return error .
end.
assign
v-rum-exp-tables =  'rule-process':U +
                    ";" + 'ruleset':U +
                    ";" + 'prop-head':U +
                    ";" + 'prop-ruleset':U +
                    ";" + 'prop-map':U +
                    ";" + 'prop-script':U +
                    ";" + 'pscript-ruleset':U +
                    ";" + 'ruledict':U +
                    ";" + 'ruledict-param':U +
                    ";" + 'rule-script':U  +
                    ";" + 'rule-i-script':U  +
                    ";" + 'rule':U  +
                    ";" + 'rule-by-set':U +
                    ";" + 'prop-ref':U  +
                    ";" + 'rule-profile':U +
                    ";" + 'profile-by-profile':U +
                    ";" + 'rule-by-profile':U +
                    ";" + 'rp-rule-param':U +
                    ";" + "fixing" +
                    ";" + ('ruledict':U + chr(44) + 'ruledict':U)
                    .
assign
v-rum-exp-table-names = 'Звено процесса':U +
                        ";" + 'Кодексы и наборы правил':U +
                        ";" + 'Объекты-операнды машины правил':U +
                        ";" + 'Объекты - наборы правил':U +
                        ";" + 'Структура свойств данных':U +
                        ";" + 'Скрипты RULE-машины':U +
                        ";" + 'Свойства объ.<->набор правил':U +
                        ";" + 'Словарь RULE-машины':U +
                        ";" + 'Параметры статей словаря правил':U +
                        ";" + 'Текст правил':U  +
                        ";" + 'Скрипт объекта-правило':U  +
                        ";" + 'Правила RULE-машины':U      +
                        ";" + 'Привязка правил к наборам':U +
                        ";" + 'Типы срезов хранилища':U  +
                        ";" + 'Профайлы правил':U +
                        ";" + 'Привязка профайлов к профайлу':U +
                        ";" + 'rule-by-profile':U +
                        ";" + 'Параметры профайла-правила':U +
                        ";" + "fixing" +
                        ";" + 'Словарь RULE-машины':U
                        .
do v-ii = 1 to num-entries( v-rum-exp-tables, ";"):
  CASE entry(v-ii, v-rum-exp-tables, ";"):
    when 'prop-ref':U then do:
      v-prepare-phrase = substitute(" for each &1 where &1.dt-code = 0 ", entry(v-ii, v-rum-exp-tables, ";")).
    end.
    when 'ruledict':U then do:
      v-prepare-phrase = substitute(' for each &1 where &1.entry-id > 0 and ((&1.entry-type > "&2") or (&1.entry-type < "&2")) use-index imain'
                                   , entry(v-ii, v-rum-exp-tables, ";")
                                   , 'sum-id':U
                                   ).
    end.
    when ('ruledict':U + chr(44) + 'ruledict':U) then do:
      v-prepare-phrase = substitute(' for each &1 where &1.entry-id = 0'
                                   , entry(1, entry(v-ii, v-rum-exp-tables, ";"))
                                   ).
      entry(v-ii, v-rum-exp-tables, ";") = entry(1, entry(v-ii, v-rum-exp-tables, ";")).
    end.
    when "fixing" then do:
      v-prepare-phrase = v-fix-file-name.
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-rum-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes)
                     ,input (if v-ii = 1 then yes else no)
                     ,input ( if v-ii = num-entries(v-rum-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-rum-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-rum-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-rum-exp-tables, ";"))
                             else 1)
                     ,input v-prepare-phrase
                     ,input-output rec-count
                     ,input-output err-count
                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
  else do:
    message
    substitute("Ошибка при экспорте &1", entry(v-ii, v-rum-exp-tables, ";"))
    view-as alert-box error .
    return.
  end.
end.
message
"Экспорт конфигурации завершен"
view-as alert-box .
