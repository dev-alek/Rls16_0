block-level on error undo, throw.
define input parameter parparentproc    as handle              no-undo.
define input parameter parchoice        as integer             no-undo.
define input parameter parInputFileName as character           no-undo.
define input parameter parInputCoding   as character           no-undo.
define input parameter pare-code        like ub.trn-doc.exch-code no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.
define input parameter parcli-type      like ub.trn-doc.cli-type  no-undo.
define input parameter parcli-code      like ub.trn-doc.cli-code  no-undo.
define input parameter parhost-code     like ub.trn-doc.host-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-all.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-all.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define new shared stream inp.
define new shared stream err.
define new shared stream wrn.
define variable InputFileName  as character         no-undo.
define variable InputCoding    as character         no-undo.
define variable InputMode      as character         no-undo.
define variable v-message-text as character         no-undo.
define variable choice         as integer           no-undo.
define variable e-code         like      ub.trn-doc.exch-code no-undo.
define variable dfc-recid   as recid     no-undo .
define variable vartemp-ext as character no-undo.
define variable varlog      as logical   no-undo.
define variable ref-rec     as recid     no-undo.
define variable doc-rec     as recid     no-undo.
define variable mark-list       as   character            no-undo.
define buffer buf_trn-doc for ub.trn-doc  .
v-message-text =
    "Форматы файла импорта <параметр в угловых скобках требуется не во всех импортах>[параметр в квадратных скобках может быть опущен][[параметр обязателен при условии импорта в определенную цель]]:" + chr(10)
  + chr(10)
  + "ITEM: артикул;[код-производителя];;;              [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + chr(10)
  + "SCALE:артикул;[код-производителя];признак;;       [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + chr(10)
  + "PART: артикул;[код-производителя];документ;партия;[[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + chr(10)
  + "CODE: код;;;;                                     доп-бар-код;цена;количество;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[Тип маркировки]"
  + chr(10)
  + "Описание параметров:"                                                                                                     + chr(10)
  + "ITEM - товар, SCALE - признак, PART - партию, CODE - на любое из перечисленного по коду."                                 + chr(10)
  + "Если код-производителя не указан, будет взят ПЕРВЫЙ попавшийся товар с данным артикулом."                                 + chr(10)
  + "Артикул - артикул товара."                                                                                                + chr(10)
  + "Код - любой собственный или дополнительный бар-код или код товара, признака, партии, для которой импортируется доп. БК."  + chr(10)
  + "Код производителя - числовой код производителя из справочника клиентов (до 9 разрядов). Тип подразумевается 'орг'."       + chr(10)
  + "Признак - полный путь к терминальному признаку, узлы перечислены сверху вниз без корневого через '/'."                    + chr(10)
  + "Документ - номер складского документа, создавшего партию (обычно номер ПН)."                                              + chr(10)
  + "Партия - номер партии."                                                                                                   + chr(10)
  + "Доп-бар-код - импортируемый доп. БК. Должен быть длиннее 5 разрядов, или импорт 1,2-разрядных топливных кодов."           + chr(10)
  + "НДС, НСП - проценты НДС и налога с продаж поставщика."                                                                    + chr(10)
  + "включен/выключен(yes/no) - включен или выключен дополнительный бар-код (необходим при импорте доп. бар-кодов)"            + chr(10)
  + "После последней строки требуется Enter."                                                                                  + chr(10)
  + "Тип маркировки (0 - Тип неопределен, 1 - Табак,2 - Обувь)."                                                               + chr(10)
  + chr(10)
  + "Импорт дополнительных БК: Параметры для режима: Доп-бар-код, едизм, коэффициент, скидка, включен/выключен."               + chr(10)
  + "Если данный доп. БК уже есть в БД, то будут переписаны новыми значениями: едизм, коэффициент, скидка, если они указаны."  + chr(10)
  + chr(10)
  + "Импорт внешней ПН (запроса): Параметры для режима: Цена, количество, едизм, коэффициент, НДС, НСП."                       + chr(10)
  + "Если едизм не указан, будут использованы едизм и коэффициент из бар-кода (только с типом CODE)."                          + chr(10)
  + "Если данный товар (признак, партия) уже есть в ПН, то будут переписаны заново: цена, едизм, коэффициент, НДС, НСП."       + chr(10)
  + "Количество в этом случае суммируется."                                                                                    + chr(10)
  + chr(10)
  + "Примеры :"                                                                                                                + chr(10)
  + "ITEM:арт-1;118;;;3249443208100;;;;;;;yes"                                                                                           + chr(10)
  + "ITEM:арт-1;118;;;3249443208100;;;уп;12;5;;yes"                                                                                   + chr(10)
  + "ITEM:арт-1;;;;3249443208100;;;уп;12;5;;yes"                                                                                      + chr(10)
  + "SCALE:арт-1;118;синий;;3249443208100;;;уп;12;5;;yes"                                                                             + chr(10)
  + "SCALE:арт-1;118;синий/54;;3249443208100;;;уп;12;5;;yes"                                                                          + chr(10)
  + "PART:арт-1;118;4657-500с;777;3249443208100;;;уп;12;5;;yes"                                                                       + chr(10)
  + "CODE:8901055006042;;;;3249443208100;;;уп;12;5;;yes;1"                                                                            + chr(10)
  .
if parInputFileName <> ? then do:
  assign InputFileName = parInputFileName.
end.
else do:
   run gbl/d-prompt.w (
       'title=Импорт доп. БК из внешнего текстового файла для товаров, признаков, партий\'
     + 'type=editor\'
     + 'fillin_width=96\'
     + 'fillin_height=15\'
     + 'readonly=yes\'
     , input-output v-message-text).
   if return-value = 'false':u then do:
     return error.
   end.
   SYSTEM-DIALOG GET-FILE InputFileName
                 TITLE   "Файл с Доп. бар-кодами"
                 FILTERS "Текстовый файл (*.adb)"   "*.adb",
                         "Текстовый файл (*.txt)"   "*.txt",
                         "Все файлы (*.*)"          "*.*"
                 MUST-EXIST
                 USE-FILENAME
                 default-extension ".txt"
                 UPDATE varlog.
   if not varlog then return error.
end.
InputFileName = trim (string (InputFileName)) .
assign
vartemp-ext = entry (2, InputFileName, ".") no-error.
if error-status:error then do:
  message "Файл без расширения не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if entry (2, InputFileName, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if entry (2, InputFileName, ".") = "wrn" then do:
  message "Файл с расширением '.wrn' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if parInputCoding <> ? then do:
   if parInputCoding <> "1251"   and
      parInputCoding <> "KOI8-R" then do:
      message "Указан неверный формат файла: " parInputCoding " ." view-as alert-box.
      return error.
   end.
   assign InputCoding = parInputCoding.
end.
else do:
   varlog = yes.
   message "Выберите входной формат файла: YES - 1251, NO - KOI8-R" view-as alert-box question
           buttons YES-NO update varlog.
   if varlog then
      InputCoding = "1251".
   else
      InputCoding = "KOI8-R".
end.
if parchoice <> ? then do:
   if parchoice < 1 or
      parchoice > 4 then do:
      message "Неверно выбран параметр информации для импорта: " parchoice " ."
      view-as alert-box error.
      return error.
   end.
   assign choice = parchoice.
end.
else do:
   run gbl/d-askw.w (input "Что импортируем",
                 input "Выберите, какую информацию нужно импортировать из выбранного файла",
                 input "|",
                 input "Доп. БК|Внешняя ПН|ДНЦ|Все",
                 input "|||",
                 input 1,
                 input 4,
                 output choice).
end.
define variable mFileName as character no-undo.
define variable vi as integer no-undo.
do vi = 1 to Num-entries(InputFileName,".") - 1:
mFilename = mFilename + "." + entry(vi,InputFileName,".").
end.
mFilename = substring(mFilename,2).
output stream err TO value (mFilename + ".err").
output stream wrn TO value (mFilename + ".wrn").
if choice = 4 then do:
  run run-choice (1) no-error.
  if error-status:error then
    return error.
  run run-choice (2) no-error.
  if error-status:error then
    return error.
  run run-choice (3) no-error.
  if error-status:error then
    return error.
  message
    "Работа утилиты закончена."
    view-as alert-box.
end.
else do:
  run run-choice (choice) no-error.
  if error-status:error then
    return error.
end.
output stream err close.
output stream wrn close.
procedure run-choice:
define input parameter choice-num as integer no-undo.
define variable frame-title as character          no-undo.
define variable count-upd   as integer init 0     no-undo.
define variable counter     as integer init 0     no-undo.
define variable count-all   as integer init 0     no-undo.
DEFINE VARIABLE loc-ref-list as character no-undo .
case InputCoding :
  when "1251" then
    input stream inp FROM value (InputFileName) convert source "1251".
  when "KOI8-R" then
    input stream inp FROM value (InputFileName) convert source "KOI8-R".
  otherwise
    return error.
end case.
case choice-num:
  when 1 then
    assign
      InputMode = "prod-bc"
      frame-title = "доп. БК"
      .
  when 2 then do:
    assign
      InputMode = "input-way-bill"
      frame-title = "внешней ПН (запроса)"
      .
    if pare-code <> ? then do:
       find first currency where currency.curr-code = pare-code no-lock no-error.
       if not available currency then do:
          message "Задан неверный код валюты: " pare-code " ." view-as alert-box error.
          return error.
       end.
       assign e-code = pare-code.
    end.
    else do:
       assign
       ref-rec = ?.
       run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec).
       if ref-rec = ? then
         return error.
       find currency where recid (currency) = ref-rec no-lock.
       e-code = currency.curr-code.
    end.
  end.
  when 3 then do:
    assign
      InputMode = "overvalue"
      frame-title = "Документ назначения цены"
      .
    run str/docsprls.w
     (input parparentproc ,
      input "all":U ,
      input ?,
      input ?,
      input "b-sel,b-add":U ,
      input-output loc-ref-list
      ) .
    doc-rec = integer (loc-ref-list) .
    find first  price-doc-forming  where recid (price-doc-forming) = doc-rec no-error .
    if not available price-doc-forming then do:
      message "Документ назначения цены не выбран."
              view-as alert-box error.
      return error.
    end.
    if price-doc-forming.stts <> integer('0':U) then do:
      message "Статус Документа назначения цены должен быть 'новый'."
              view-as alert-box error.
      return error.
    end.
    dfc-recid = recid(price-doc-forming).
  end.
end case.
frame-title = "Импорт "      + frame-title +
              " из файла: "  + InputFileName +
              " Кодировка: " + InputCoding +
              " Дата: "      + cur-time-string()
              .
run utl/imd-all.p
    ( input  parparentproc,
      input  InputMode,
      input  frame-title,
      input  dfc-recid,
      input  e-code,
      input  (if pardoc-code = ? then "import" else pardoc-code),
      input  parcli-type,
      input  parcli-code,
      input  parhost-code,
      output count-upd,
      output counter,
      output count-all) no-error.
if error-status:error then
  return error.
input  stream inp close.
output stream err close.
output stream wrn close.
if parInputFileName = ? then do:
  message frame-title skip (2)
          "Просмотрено :" count-all skip
          "Закачано :"    counter skip
          "Изменено :"    count-upd skip (2)
          "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
          "Информация о предупреждениях находится в файле :" entry (1, InputFileName, ".") + ".wrn"
          view-as alert-box .
  define variable varuser-action as character no-undo.
  define variable varis-printed  as logical   no-undo.
  run gbl/prnfilen.w
    (input  "Ошибки"
    ,input  0
    ,input  mFilename + ".err"
    ,input  7
    ,output varuser-action
    ,output varis-printed
    ).
  run gbl/prnfilen.w
    (input  "Замечания"
    ,input  0
    ,input  mFilename + ".wrn"
    ,input  7
    ,output varuser-action
    ,output varis-printed
    ).
end.
end procedure.
