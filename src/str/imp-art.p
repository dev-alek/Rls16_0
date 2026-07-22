block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imp-art.p $
$Archive: str/imp-art.p $

Импорт доп. БК, внеш. ПН

Автор: Суслов Алексей Юрьевич
Дата создания: 03/15/05
Author: Alexey Suslov
Creation date: 03/15/05

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter parchoice        as integer             no-undo.
define input parameter parInputFileName as character           no-undo.
define input parameter parInputCoding   as character           no-undo.
define input parameter pare-code        like trn-doc.exch-code no-undo.
define input parameter pardoc-code      like trn-doc.doc-code  no-undo.
define input parameter parcli-type   like ub.trn-doc.cli-type  no-undo. /*поставщик*/
define input parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input parameter parhost-code  like ub.trn-doc.host-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-art.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-art.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

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
def var e-code  like trn-doc.exch-code no-undo.  /* код валюты поставщика для ПН */
def var doc-num like price-doc.doc-num no-undo.  /* номер переоценки */
define variable vartemp-ext as character no-undo.
v-message-text =
    "Форматы файла импорта <параметр в угловых скобках требуется не во всех импортах>[параметр в квадратных скобках может быть опущен][[параметр обязателен при условии импорта в определенную цель]]:" + {&new-line}
  + {&new-line}
  + "<артикул>;[доп-бар-код];<количество>;<цена>;[ГТД];[едизм];[коэффициент];[НДС]" + {&new-line}
  + {&new-line}
  + "Описание параметров:"                                                                                                     + {&new-line}
  + "Артикул поставщика - внешний артикул товара - ОБЯЗАТЕЛЬНОЕ ПОЛЕ."                                                                                                + {&new-line}
  + "Доп-бар-код - любой собственный или дополнительный бар-код или код товара, признака для которой импортируется товар."  + {&new-line}
  + "цена и количество- ОБЯЗАТЕЛЬНЫЕ ПОЛЯ."                                                                    + {&new-line}
  + "НДС - проценты НДС поставщика."                                                                    + {&new-line}
  + "После последней строки требуется Enter."                                                                                  + {&new-line}
  + {&new-line}
  + "Импорт внешней ПН :"                       + {&new-line}
  + "Если едизм не указан, будут использованы едизм и коэффициент из карточки товара."                                 + {&new-line}
  + "Если данный товар (признак) уже есть в ПН, то будут переписаны заново: цена, едизм, коэффициент, НДС, НСП."       + {&new-line}
  + "Количество в этом случае суммируется."                                                                                    + {&new-line}
  + {&new-line}
  + "Пример :"                                     + {&new-line}
  + "арт-1;3249443208100;10000;3;ГТД;шт;1;18"      + {&new-line}
  + "арт-1;;10000;3;;;;"                           + {&new-line}
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
def var count-upd   as int init 0     no-undo.  /* изменено */
def var counter     as int init 0     no-undo.  /* закачано */
def var count-all   as int init 0     no-undo.  /* просмотрено */
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
       /* выбираем валюту поставщика */
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