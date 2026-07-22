block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Стандартный граф переходов банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/06
Author: Bakhtadze Natalya
Creation date: 11/19/06

parmode - {&close-doc}, {&open-doc}, {&close-fact}, {&reject-doc}, {&update-doc}

|-----------------------|--------------/-------------------------------/--------------------------|
|БД на которой работаем | БД документа |   Главная БД фирмы            /Вывод о работе             |
|-----------------------|--------------|-------------------------------/---------------------------|
|        main           |      main    |          main                 /работаем стандартно        |
|-----------------------|--------------|-------------------------------/---------------------------|
|        main           |      remote  |          main                 /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |      main    |          main                 /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |      remote  |          remote               /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |another remote|          remote               /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|


Стандартный граф переходов -
работа на БД, которая является главной БАЗОЙ фирмы - все объекты принадлежат этой базе

|-------------------------------------|--------|------|-------|------|------|
|Документы/Статусы                    |  нов   |      | банк  |      | факт |
|-------------------------------------|--------|------|-------|------|------|
|Приход безналичные                   | start> |      |  <>   |      |  ][  |
|                                     | gen  > |      |  <>   |      |  ][  |
|-------------------------------------|--------|------|-------|------|------|
|Расход безналичные                   | start> |      |   <>  |      |  ][  |
|                                     | gen  > |      |   <>  |      |  ][  |
|-------------------------------------|--------|------|-------|------|------|


start - добавляется вручную
gen - генериться из финобязательств
(
genp  - автоматически генерится на основании внутреннего расхода
genr  - автоматически генерится на основании внутреннего прихода
)
> - изменяется, переходит в след.статус
>? - перехода может не быть
f - переходит сразу в статус факт
news - отправляется по новостям, если мы в удаленной базе данных или документ не нашей БД
][ - остается в данном статусе, не редактируется.
"-" - не обрабатывется.

*/

define input  parameter p-host-code           like ub.fin-statement.host-code    no-undo .
define input  parameter p-fin-sttm-code       like ub.fin-statement.sttm-code    no-undo .
define input  parameter p-mode                as character                 no-undo .
define input  parameter p-author              as character                 no-undo .
/*
{&close-doc}
{&open-doc}
{&close-fact}
*/
define input  parameter p-status-current      like ub.fin-statement.status_      no-undo .
define input  parameter p-status-date         like ub.fin-statement.fact-date    no-undo .
define output parameter p-status_             like ub.fin-statement.status_      no-undo . /*в какой перейдет*/
define output parameter p-ask-date            as logical                   no-undo .
define output parameter p-ask-message         as character                 no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов банковских выписок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }



define variable v-db-num like ub.db.db-num no-undo .
define variable v-author as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-statement for ub.fin-statement.
define buffer bf_clients for ub.clients.
define buffer bf_db for ub.db .


do on error undo, return error substitute ("Ошибка при вызове программы finsgraf.p: &1 &2 &3 &4 при работе с документом &4.", error-status:get-message(1), error-status:get-message(2), return-value, p-host-code, p-fin-sttm-code):
  if p-mode <> {&close-doc}
  AND p-mode <> {&open-doc}
  AND p-mode <> {&close-fact}
     then do:
     return error substitute ("Неверный режим обработки документа &1.", p-mode).
  end.

  { gbl/curdbnum.i v-db-num no-error }
  if error-status:error then do:
    return error "Ошибка при определении номер текущей БД".
  end.

  find first buf_sysconf where
             buf_sysconf.host-code = p-host-code no-error.
  if not available buf_sysconf then do:
     return error substitute ("Не найдена фирма с номером &1 для платежа", p-host-code, p-fin-sttm-code).
  end.
  find first buf_fin-statement where
            buf_fin-statement.host-code = p-host-code
        AND buf_fin-statement.sttm-code = p-fin-sttm-code no-lock no-error.
  if not available buf_fin-statement then do:
     return error substitute ("Не найдена выписка: фирма &1 с номером &2.", p-host-code, p-fin-sttm-code).
  end.
  if buf_sysconf.firm-db-num = ? or
     buf_sysconf.firm-db-num < 0 then do:
     return error substitute ("Неверный номер базы данных &1 фирмы &2.", buf_sysconf.firm-db-num, buf_sysconf.host-code).
  end.
  find first bf_db where bf_db.db-num = buf_sysconf.firm-db-num no-lock no-error.
  if not available bf_db then do:
     return error substitute("Не найдена БД &1 документа &2 для фирмы &3.", buf_sysconf.firm-db-num, p-fin-sttm-code, buf_sysconf.host-code).
  end.
  if v-db-num <> buf_sysconf.firm-db-num then do:
    return error substitute("Нельзя изменять запись БАНКОВСКОЙ ВЫПИСКИ в БД, отличной от главной БД фирмы:&3" +
                            "номер текущей БД &1, номер главной БД фирмы &2"
                            , v-db-num
                            , buf_sysconf.firm-db-num
                            , {&new-line}
                            ).
  end.
  if buf_fin-statement.status_ = {&fact} then do:
     return error substitute ("Банковская выписка &1 для фирмы &2 закрыта до факта.&3"
                              + "Операции с ней не допустимы."
                              , buf_fin-statement.prn-doc-code
                              , buf_sysconf.host-code
                              , {&new-line}
                              ).
  end.
  run trg/finsgrfp.p (
                   input this-procedure:handle
                  ,input  buf_fin-statement.fins-doc-type
                  ,input  buf_fin-statement.fins-ext-doc-type
                  ,input  buf_fin-statement.status_
                  ,input  p-mode
                  ,input  p-author
                  ,input  p-status-date
                  ,output p-status_
                  ,output p-ask-date
                  ,output p-ask-message
                  ) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1&2"
                              + "по операции: &3&2"
                              + "номер документа &4&2"
                              + "тип &5&2"
                              + "расш.тип &6&2"
                              + "статус &7"
                              ,return-value
                              ,{&new-line}
                              ,p-mode
                              ,buf_fin-statement.sttm-code
                              ,buf_fin-statement.fins-doc-type
                              ,buf_fin-statement.fins-ext-doc-type
                              ,buf_fin-statement.status_
                              ).
  end.
end. /*do on error*/


procedure check-cl-bank :
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank  for ub.fin-bank.


  do
  on error undo, return error
  :
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = buf_fin-statement.host-code
        AND buf_fin-schet.code-schet = buf_fin-statement.code-schet .
  find first buf_fin-bank no-lock where
            buf_fin-bank.host-code = buf_fin-statement.host-code
        AND buf_fin-bank.code-bank = buf_fin-statement.code-bank.
  if buf_fin-bank.cl-bank <> '':U then do:
    return error substitute("Выписка &1 (вн.№ &2) для фирмы &3 проходит по счету банка &4,&5" +
                            "который подключен к системе КЛИЕНТ-БАНК. ВРУЧНУЮ обработать невозможно"
                            , buf_fin-statement.prn-doc-code
                            , buf_fin-statement.sttm-code
                            , buf_fin-statement.host-code
                            , {&new-line}
                            , buf_fin-bank.bank-name).
  end.

  end. /*doe*/

end procedure. /* check-cl-bank */
