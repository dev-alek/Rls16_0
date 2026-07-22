block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cd-event-first-load.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cd-event-first-load.p $":U .
define variable vss-description as character no-undo init "Загрузка справочника событий на кассе".
define buffer bf_cd-events      for ub.cd-events .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
do
TRANSACTION
on error undo, return error
:
   FOR EACH bf_cd-events
       EXCLUSIVE-LOCK
       :
       DELETE bf_cd-events.
   END.
   RUN load-line IN THIS-PROCEDURE ( "1", "2", "Запрос на авторизацию", "", "U", "Логин")  .
   RUN load-line IN THIS-PROCEDURE ( "2", "1", "Авторизация", "", "S", "Логин")  .
   RUN load-line IN THIS-PROCEDURE ( "3", "1", "Отказ в авторизации", "", "E", "логин")  .
   RUN load-line IN THIS-PROCEDURE ( "4", "0", "Системные ошибки", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "5", "2", "Попытка перехода в режим", "", "U", "Тип платежа, валюта, тип чека МЦ, тип скидки")  .
   RUN load-line IN THIS-PROCEDURE ( "6", "2", "Смена режима", "", "S", "Описание режима")  .
   RUN load-line IN THIS-PROCEDURE ( "7", "2", "Отказ в смене режима", "", "E", "Описание режима")  .
   RUN load-line IN THIS-PROCEDURE ( "8", "2", "Попытка выхода из режима", "", "U", "Описание режима")  .
   RUN load-line IN THIS-PROCEDURE ( "9", "2", "Выход из режима", "", "S", "Описание режима")  .
   RUN load-line IN THIS-PROCEDURE ( "10", "2", "Отказ в выходе из режима", "", "E", "Описание режима")  .
   RUN load-line IN THIS-PROCEDURE ( "11", "1", "Сканирование товара", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "12", "0", "Ручной ввод товара", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "13", "0", "Выбор товара из справочника", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "14", "1", "Сохранение товарной линии", "", "U", "Наименование товара")  .
   RUN load-line IN THIS-PROCEDURE ( "15", "1", "Ошибка ввода штрих-кода", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "16", "0", "Запрос на изменение количества", "", "U", "Редактирование количества <старое количество> товара <Наименование товара>")  .
   RUN load-line IN THIS-PROCEDURE ( "17", "0", "Изменено количество в товарной строке", "", "S", "Изменено количество товара <Наименование>")  .
   RUN load-line IN THIS-PROCEDURE ( "18", "0", "Ошибка изменения количества", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "19", "0", "Ввод оплаты", "", "U", "Тип платежа, валюта")  .
   RUN load-line IN THIS-PROCEDURE ( "20", "0", "Сохранение линии оплаты", "", "S", "Тип платежа, валюта")  .
   RUN load-line IN THIS-PROCEDURE ( "21", "0", "Отказ в сохранении платежа", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "22", "0", "Запрос на проведение операции в СБП", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "23", "0", "Проведение операции в СБП", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "24", "0", "Отказ в проведении операции", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "25", "0", "Отмена платежа в СПБ", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "26", "0", "Ошибка отмены платежа", "", "E", "")  .
   RUN load-line IN THIS-PROCEDURE ( "27", "0", "Попытка удаления товарной линии", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "28", "0", "Удаление товарной линии", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "29", "0", "Отказ в удалении товарной линии", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "30", "0", "Попытка удаления линии оплаты", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "31", "0", "Удаление линии оплаты", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "32", "0", "Отказ в удалении линии оплаты", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "33", "0", "Ввод пароля для конкретного права", "", "U", "Проверка на наличие права <Описание права>. Логин <Логин>")  .
   RUN load-line IN THIS-PROCEDURE ( "34", "0", "Отказ при проверке прав", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "35", "0", "Положительный ответ при проверке права", "", "S", "Подтверждение наличия права <Описание права>. Логин <Логин>")  .
   RUN load-line IN THIS-PROCEDURE ( "36", "0", "Попытка регистрации ДК", "", "U", "Регистрация ДК")  .
   RUN load-line IN THIS-PROCEDURE ( "37", "0", "Регистрация ДК", "", "S", "Регистрация ДК. Клиент: <Номер>, <название клиента>")  .
   RUN load-line IN THIS-PROCEDURE ( "38", "0", "Отказ в регистрации ДК", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "39", "1", "Попытка регистрации продавца", "", "U", "Попытка регистрации продавца. Код <Код продавца>")  .
   RUN load-line IN THIS-PROCEDURE ( "40", "1", "Регистрация продавца", "", "S", "Регистрация продавца. <Номер продавца>, <Фамилия И.О>.")  .
   RUN load-line IN THIS-PROCEDURE ( "41", "1", "Отказ в регистрации продавца", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "42", "0", "Попытка установки ручной скидки на линию", "", "U", "Тип скидки")  .
   RUN load-line IN THIS-PROCEDURE ( "43", "0", "Установка ручной скидки на линию", "", "S", "Тип скидки")  .
   RUN load-line IN THIS-PROCEDURE ( "44", "0", "Отказ установки ручной скидки на линию", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "45", "0", "Попытка установки ручной скидки на итог", "", "U", "Тип скидки")  .
   RUN load-line IN THIS-PROCEDURE ( "46", "0", "Установка ручной скидки на итог", "", "S", "Тип скидки")  .
   RUN load-line IN THIS-PROCEDURE ( "47", "0", "Отказ в установке ручной скидки на итог", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "48", "2", "Поиск по чеку", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "49", "0", "Ввод цены пользователем", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "50", "0", "Установка новой цены", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "51", "0", "Отказ в установке новой цены на товар", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "52", "1", "Блокировка пользователем", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "53", "1", "Снятие блокировки пользователем", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "54", "0", "Попытка аннуляции чека", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "55", "0", "Аннуляция чека", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "56", "0", "Отказ в аннуляции чека", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "57", "0", "Попытка отложить чек", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "58", "1", "Перевод чека в отложенные", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "59", "1", "Отказ в переводе чека в отложенные", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "60", "1", "Выбор отложенного чека", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "61", "1", "Выбор прямого чека", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "62", "1", "Открыть ДЯ", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "63", "0", "попытка закрыть чек продажи", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "64", "0", "Закрытие чека продажи", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "65", "0", "Отказ в закрытии чека продажи", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "66", "0", "Печать чека", "", "", "")  .
   RUN load-line IN THIS-PROCEDURE ( "67", "0", "Ошибка печати ", "", "", "")  .
   RUN load-line IN THIS-PROCEDURE ( "68", "0", "Сдача", "", "", "")  .
   RUN load-line IN THIS-PROCEDURE ( "69", "0", "Попытка открыть чек возврата", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "70", "0", "Открыт чек возврата", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "71", "0", "Отказ в открытии чека возврата", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "72", "0", "Закрыть чек возврата", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "73", "0", "Закрыт чек возврата", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "74", "0", "Отказ в закрытии чека возврата", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "75", "1", "Запрошена информация о наличности в ДЯ", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "76", "2", "Запрошена информация о товаре", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "77", "1", "Х-отчет", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "78", "0", "Попытка снять Z-отчет", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "79", "0", "Z-отчет", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "80", "0", "Отказ или ошибка при снятиии отчета", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "81", "0", "Попытка закрыть день СБП", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "82", "0", "Закрыт день в СПБ", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "83", "0", "Отказ или ошибка при закрытии дня в СПБ", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "84", "0", "Попытка инкассации", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "85", "0", "Закрытие чека инкассации", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "86", "0", "Отказ в инкассации", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "87", "0", "Попытка внести кассовый фонд", "", "U", "")  .
   RUN load-line IN THIS-PROCEDURE ( "88", "0", "Внесен кассовый фонд", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "89", "0", "Отказ во внесении кассового фонда", "", "E", "Описание ошибки")  .
   RUN load-line IN THIS-PROCEDURE ( "90", "1", "Декларация", "", "S", "")  .
   RUN load-line IN THIS-PROCEDURE ( "91", "0", "Выход из системы", "", "U", "")  .
end.
procedure load-line :
define input parameter p-id            as integer          no-undo.
define input parameter p-level         as integer          no-undo.
define input parameter p-name          as character        no-undo.
define input parameter p-status        as integer          no-undo.
define input parameter p-type          as character        no-undo.
define input parameter p-description   as character        no-undo.
define buffer buf_cd-events      for ub.cd-events .
do
on error undo, return error
:
   FIND FIRST buf_cd-events
        WHERE buf_cd-events.event-id = p-id
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_cd-events
   THEN DO:
      RETURN ERROR SUBSTITUTE("Уже есть событие с номером &1", p-id).
   END.
   CREATE buf_cd-events.
   ASSIGN
      buf_cd-events.event-id          = p-id
      buf_cd-events.event-level       = p-level
      buf_cd-events.event-name        = p-name
      buf_cd-events.event-status      = p-status
      buf_cd-events.event-type        = p-type
      buf_cd-events.event-description = p-description
   NO-ERROR .
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE("Ошибка создания записи &1&2&3", p-id, chr(10), error-status :get-message (1)).
   END.
   RETURN.
end.
end procedure.
