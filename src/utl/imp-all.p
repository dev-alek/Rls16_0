block-level on error undo, throw.
/*

$Revision: f5e72f13272f, 2363, rls $
$Author: druban $
$Date: Ср июн 10 21:13:42 2020 +0300 $
$Workfile: imp-all.p $
$Archive: utl/imp-all.p $

Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла

Автор: Чернова Светлана Александровна
Дата создания: 11/21/06
Author: Svetlana Chernova
Creation date: 11/21/06

create2: Суслов Алексей Юрьевич
Дата создания: 09/20/05

create1 : Андрей Исаков 12.05.98

*/

define input parameter parparentproc    as handle              no-undo.
define input parameter parchoice        as integer             no-undo.
define input parameter parInputFileName as character           no-undo.
define input parameter parInputCoding   as character           no-undo.
define input parameter pare-code        like ub.trn-doc.exch-code no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.
define input parameter parcli-type      like ub.trn-doc.cli-type  no-undo. /*поставщик*/
define input parameter parcli-code      like ub.trn-doc.cli-code  no-undo.
define input parameter parhost-code     like ub.trn-doc.host-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-all.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-all.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define new shared stream inp.
define new shared stream err.
define new shared stream wrn.


define variable InputFileName  as character         no-undo.
define variable InputCoding    as character         no-undo.
define variable InputMode      as character         no-undo.
define variable v-message-text as character         no-undo.
define variable choice         as integer           no-undo.
define variable e-code         like      ub.trn-doc.exch-code no-undo.  /* код валюты поставщика для ПН */
define variable dfc-recid   as recid     no-undo . /* Документ назначения цены */
define variable vartemp-ext as character no-undo.
define variable varlog      as logical   no-undo.
define variable ref-rec     as recid     no-undo.
define variable doc-rec     as recid     no-undo.
define variable mark-list       as   character            no-undo.
define buffer buf_trn-doc for ub.trn-doc  .

v-message-text =
    "Форматы файла импорта <параметр в угловых скобках требуется не во всех импортах>[параметр в квадратных скобках может быть опущен][[параметр обязателен при условии импорта в определенную цель]]:" + {&new-line}
  + {&new-line}
  + "ITEM: артикул;[код-производителя];;;              [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + {&new-line}
  + "SCALE:артикул;[код-производителя];признак;;       [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + {&new-line}
  + "PART: артикул;[код-производителя];документ;партия;[[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]" + {&new-line}
  + "CODE: код;;;;                                     доп-бар-код;цена;количество;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[Тип маркировки]"
  + {&new-line}
  + "Описание параметров:"                                                                                                     + {&new-line}
  + "ITEM - товар, SCALE - признак, PART - партию, CODE - на любое из перечисленного по коду."                                 + {&new-line}
  + "Если код-производителя не указан, будет взят ПЕРВЫЙ попавшийся товар с данным артикулом."                                 + {&new-line}
  + "Артикул - артикул товара."                                                                                                + {&new-line}
  + "Код - любой собственный или дополнительный бар-код или код товара, признака, партии, для которой импортируется доп. БК."  + {&new-line}
  + "Код производителя - числовой код производителя из справочника клиентов (до 9 разрядов). Тип подразумевается 'орг'."       + {&new-line}
  + "Признак - полный путь к терминальному признаку, узлы перечислены сверху вниз без корневого через '/'."                    + {&new-line}
  + "Документ - номер складского документа, создавшего партию (обычно номер ПН)."                                              + {&new-line}
  + "Партия - номер партии."                                                                                                   + {&new-line}
  + "Доп-бар-код - импортируемый доп. БК. Должен быть длиннее 5 разрядов, или импорт 1,2-разрядных топливных кодов."           + {&new-line}
  + "НДС, НСП - проценты НДС и налога с продаж поставщика."                                                                    + {&new-line}
  + "включен/выключен(yes/no) - включен или выключен дополнительный бар-код (необходим при импорте доп. бар-кодов)"            + {&new-line}
  + "После последней строки требуется Enter."                                                                                  + {&new-line}
  + "Тип маркировки (0 - Тип неопределен, 1 - Табак,2 - Обувь)."                                                               + {&new-line}
  + {&new-line}
  + "Импорт дополнительных БК: Параметры для режима: Доп-бар-код, едизм, коэффициент, скидка, включен/выключен."               + {&new-line}
  + "Если данный доп. БК уже есть в БД, то будут переписаны новыми значениями: едизм, коэффициент, скидка, если они указаны."  + {&new-line}
  + {&new-line}
  + "Импорт внешней ПН (запроса): Параметры для режима: Цена, количество, едизм, коэффициент, НДС, НСП."                       + {&new-line}
  + "Если едизм не указан, будут использованы едизм и коэффициент из бар-кода (только с типом CODE)."                          + {&new-line}
  + "Если данный товар (признак, партия) уже есть в ПН, то будут переписаны заново: цена, едизм, коэффициент, НДС, НСП."       + {&new-line}
  + "Количество в этом случае суммируется."                                                                                    + {&new-line}
  + {&new-line}
  + "Примеры :"                                                                                                                + {&new-line}
  + "ITEM:арт-1;118;;;3249443208100;;;;;;;yes"                                                                                           + {&new-line}
  + "ITEM:арт-1;118;;;3249443208100;;;уп;12;5;;yes"                                                                                   + {&new-line}
  + "ITEM:арт-1;;;;3249443208100;;;уп;12;5;;yes"                                                                                      + {&new-line}
  + "SCALE:арт-1;118;синий;;3249443208100;;;уп;12;5;;yes"                                                                             + {&new-line}
  + "SCALE:арт-1;118;синий/54;;3249443208100;;;уп;12;5;;yes"                                                                          + {&new-line}
  + "PART:арт-1;118;4657-500с;777;3249443208100;;;уп;12;5;;yes"                                                                       + {&new-line}
  + "CODE:8901055006042;;;;3249443208100;;;уп;12;5;;yes;1"                                                                            + {&new-line}
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
define variable count-upd   as integer init 0     no-undo.  /* изменено */
define variable counter     as integer init 0     no-undo.  /* закачано */
define variable count-all   as integer init 0     no-undo.  /* просмотрено */
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
       /* выбираем валюту поставщика */
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
    /* выбираем ДНЦ  */
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
    if price-doc-forming.stts <> integer({&pdf-new}) then do:
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