block-level on error undo, throw.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter parchoice        as integer             no-undo.
define input parameter parInputFileName as character           no-undo.
define input parameter parInputCoding   as character           no-undo.
define input parameter pare-code        like trn-doc.exch-code no-undo.
define input parameter pardoc-code      like trn-doc.doc-code  no-undo.
define input parameter parcli-type   like ub.trn-doc.cli-type  no-undo.
define input parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input parameter parhost-code  like ub.trn-doc.host-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-art.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-art.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН".
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
define new shared stream inp.
define new shared stream err.
define new shared stream wrn.
define variable g#log as logical   no-undo .
define variable ref-rec as recid no-undo .
def var InputFileName  as char         no-undo.
def var InputCoding    as char         no-undo.
def var InputMode      as char         no-undo.
def var v-message-text as char         no-undo.
def var choice         as integer      no-undo.
def var e-code  like trn-doc.exch-code no-undo.
def var doc-num like price-doc.doc-num no-undo.
define variable vartemp-ext as character no-undo.
v-message-text =
    "Форматы файла импорта <параметр в угловых скобках требуется не во всех импортах>[параметр в квадратных скобках может быть опущен][[параметр обязателен при условии импорта в определенную цель]]:" + chr(10)
  + chr(10)
  + "<артикул>;[доп-бар-код];<количество>;<цена>;[ГТД];[едизм];[коэффициент];[НДС]" + chr(10)
  + chr(10)
  + "Описание параметров:"                                                                                                     + chr(10)
  + "Артикул поставщика - внешний артикул товара - ОБЯЗАТЕЛЬНОЕ ПОЛЕ."                                                                                                + chr(10)
  + "Доп-бар-код - любой собственный или дополнительный бар-код или код товара, признака для которой импортируется товар."  + chr(10)
  + "цена и количество- ОБЯЗАТЕЛЬНЫЕ ПОЛЯ."                                                                    + chr(10)
  + "НДС - проценты НДС поставщика."                                                                    + chr(10)
  + "После последней строки требуется Enter."                                                                                  + chr(10)
  + chr(10)
  + "Импорт внешней ПН :"                       + chr(10)
  + "Если едизм не указан, будут использованы едизм и коэффициент из карточки товара."                                 + chr(10)
  + "Если данный товар (признак) уже есть в ПН, то будут переписаны заново: цена, едизм, коэффициент, НДС, НСП."       + chr(10)
  + "Количество в этом случае суммируется."                                                                                    + chr(10)
  + chr(10)
  + "Пример :"                                     + chr(10)
  + "арт-1;3249443208100;10000;3;ГТД;шт;1;18"      + chr(10)
  + "арт-1;;10000;3;;;;"                           + chr(10)
  .
run gbl/d-prompt.w (
    'title=Импорт ПН из внешнего текстового файла для товаров\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + 'readonly=yes\'
  , input-output v-message-text).
if return-value = 'false':u then
  return error.
if parInputFileName <> ? then assign InputFileName = parInputFileName.
else do:
   SYSTEM-DIALOG GET-FILE InputFileName
                 TITLE   "Файл с Доп. бар-кодами"
                 FILTERS "Текстовый файл (*.adb)"   "*.adb",
                         "Текстовый файл (*.txt)"   "*.txt",
                         "Все файлы (*.*)"          "*.*"
                 MUST-EXIST
                 USE-FILENAME
                 default-extension ".txt"
                 UPDATE g#log.
   if not g#log then return error.
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
   g#log = yes.
   message "Выберите входной формат файла: YES - 1251, NO - KOI8-R" view-as alert-box question
           buttons YES-NO update g#log.
   if g#log then
      InputCoding = "1251".
   else
      InputCoding = "KOI8-R".
end.
output stream err TO value (entry (1, InputFileName, ".") + ".err").
output stream wrn TO value (entry (1, InputFileName, ".") + ".wrn").
run run-choice no-error.
if error-status:error then return error.
output stream err close.
output stream wrn close.
procedure run-choice:
def var frame-title as char           no-undo.
def var count-upd   as int init 0     no-undo.
def var counter     as int init 0     no-undo.
def var count-all   as int init 0     no-undo.
DEFINE VARIABLE loc-ref-list as character no-undo .
case InputCoding :
  when "1251" then
    input stream inp FROM value (InputFileName) convert source "1251".
  when "KOI8-R" then
    input stream inp FROM value (InputFileName) convert source "KOI8-R".
  otherwise
    return error.
end case.
    assign
      InputMode = "input-way-bill"
      frame-title = "внешней ПН (артикул поставщика)"
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
       run ref/currency.w (input parParentProc, "b-sel", input-output ref-rec).
       if ref-rec = ? then
         return error.
       find currency where recid (currency) = ref-rec no-lock.
       e-code = currency.curr-code.
    end.
frame-title = "Импорт "      + frame-title +
              " из файла: "  + InputFileName +
              " Кодировка: " + InputCoding +
              " Дата: "      + cur-time-string()
              .
run str/imd-art.p (input  parParentProc ,
               input  frame-title,
               input  doc-num,
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
  ,input  entry (1, InputFileName, ".") + ".err"
  ,input  7
  ,output varuser-action
  ,output varis-printed
  ).
run gbl/prnfilen.w
  (input  "Замечания"
  ,input  0
  ,input  entry (1, InputFileName, ".") + ".wrn"
  ,input  7
  ,output varuser-action
  ,output varis-printed
  ).
end procedure.
