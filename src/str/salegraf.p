block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salegraf.p $
$Archive: str/salegraf.p $
Стандартный граф переходов  продаж
parmode - {&close-doc}, {&open-doc}, {&close-fact}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

|-----------------------|--------------/-------------------------------/--------------------------|
|БД на которой работаем | БД документа |   Главная БД фирмы            /Вывод о работе             |
|-----------------------|--------------|-------------------------------/---------------------------|
|        main           |      main    |          main                 /работаем стандартно        |
|-----------------------|--------------|-------------------------------/---------------------------|
|        main           |      remote  |          main                 /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |      main    |          main                 /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |      remote  |          remote               /работаем стандартно        |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |another remote|          remote               /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|


Стандартный граф переходов -
работа на БД объекта

|-------------------------------------|--------|------|------|-------|----------|------|------|
|Статусы  (продажа)                   |  нов-  |      | нов  |       | нередакт |      | факт |
|Статусы  (накладные)                 |  касс- |      | касс+|       | нередакт |      | факт |
|-------------------------------------|--------|------|------|-------|----------|------|------|
|Вручную                              | start>f|      |  -   |       |     -    |      |  -   |
|-------------------------------------|--------|------|------|-------|----------|------|------|
|                                     | закачка|      |      |       |          |      |      |
|                                     | чеков  |      |      |       |          |      |      |
|                                     | резерв |      |      |       |          |      |      |
|                                     | закрыт |      |      |       |          |      |      |
|-------------------------------------|--------|------|------|-------|----------|------|------|
|по расписанию                        | gen>   |      | <>   |       |    <>    |      |  >   |
|-------------------------------------|--------|------|------|-------|----------|------|------|
|                                     | закачка|      |резерв|       | закрытие |      |      |
|                                     | чеков  |      |      |       |          |      |      |
|-------------------------------------|--------|------|------|-------|----------|------|------|


start - добавляется вручную
gen - генериться автоматически по шаблонам
> - изменяется, переходит в след.статус
>? - перехода может не быть
f - переходит сразу в статус факт
][ - остается в данном статусе, не редактируется.
"-" - не обрабатывется.

*/

define input  parameter p-inkas-code          like ub.inkas.inkas-code     no-undo .
define input  parameter p-mode                as character                 no-undo .
/*
{&close-doc}
{&open-doc}
{&close-fact}
*/
define input  parameter p-status-current      like ub.inkas.status_        no-undo .
define input  parameter p-flag-current        like ub.trn-doc.flag_        no-undo .

define output parameter p-status_             like ub.inkas.status_        no-undo . /*в какой перейдет*/
define output parameter p-flag_               like ub.trn-doc.flag_        no-undo . /*в какой перейдет*/
define output parameter p-ask-message         as character                 no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salegraf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salegraf.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }


define variable v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_clients for ub.clients.
define buffer bf_db for ub.db .

do on error undo, return error
substitute ("Ошибка при вызове программы salegraf.p:&1&2&1&3&1&4 при работе с документом &4."
, {&new-line}
, error-status:get-message(1)
, error-status:get-message(2)
, return-value
, p-inkas-code):
  if p-mode <> {&close-doc}
  AND p-mode <> {&open-doc}
  AND p-mode <> {&close-fact}
     then do:
     return error substitute ("Неверный режим обработки документа &1.", p-mode).
  end.

  find first buf_inkas where
            buf_inkas.inkas-code = p-inkas-code no-lock no-error.
  if not available buf_inkas then do:
     return error substitute ("Не найдена продажа с номером &1.", p-inkas-code).
  end.
  find first buf_trn-doc where
            buf_trn-doc.doc-code = p-inkas-code no-lock no-error .
  if not available buf_trn-doc then do:
    return error substitute("Не найдена накладная расхода по продаже &1", p-inkas-code).
  end.

  { gbl/curdbnum.i v-db-num no-error }
  if error-status:error then do:
    return error "Ошибка при определении номер текущей БД".
  end.

  { gbl/objdbnum.i buf_inkas.obj-type buf_inkas.obj-code v-obj-db-num }

  if v-db-num <> v-obj-db-num then do:
   return error  substitute("Нельзя изменять запись ПРОДАЖИ в БД, отличной от БД объекта продажи:&1" +
                            "номер продажи &6" +
                            "номер текущей БД &2, номер БД объекта &3&4 - &5"
                             , {&new-line}
                             , v-db-num
                             , buf_inkas.obj-type
                             , buf_inkas.obj-code
                             , v-obj-db-num
                             , buf_inkas.inkas-code
                             ).
  end.
  find first buf_clients where buf_clients.obj-type = buf_trn-doc.cli-type and
                              buf_clients.obj-code = buf_trn-doc.cli-code no-lock no-error.
  if not available buf_clients then do:
     return error substitute ("Не найден КОНТРАГЕНТ-РЕАЛИЗАЦИЯ В МАГАЗИНЕ &1 &2 для продажи &3.", buf_trn-doc.cli-type, buf_trn-doc.cli-code, buf_inkas.inkas-code).
  end.
  { gbl/hostcode.i buf_inkas.obj-type buf_inkas.obj-code v-host-code }
  find first buf_sysconf where
             buf_sysconf.host-code = v-host-code no-error.
  if not available buf_sysconf then do:
     return error substitute ("Не найдена фирма с номером &1 для продажи &2", v-host-code, p-inkas-code).
  end.

  if not (buf_clients.obj-type = buf_sysconf.sale-type AND
         buf_clients.obj-code = buf_sysconf.sale-code ) then do:
    return error substitute ("КОНТРАГЕНТ для накладных продажи &1 = &2&3 а настройки для фирмы &4 КОНТРАГЕНТ-РЕАЛИЗАЦИЯ В МАГАЗИНЕ = &5&6."
                            , buf_inkas.inkas-code
                            , buf_trn-doc.cli-type
                            , buf_trn-doc.cli-code
                            , buf_sysconf.host-code
                            , buf_sysconf.sale-type
                            , buf_sysconf.sale-code
                            ).
  end.
  if buf_inkas.status_ = {&fact}
  or buf_inkas.status_ = {&inquiry}
  then do:
    return error substitute ("Продажа &1 для &2&3 закрыта до статуса. &4&5" +
                                "Операции с ней недопустимы."
                                , buf_inkas.inkas-code
                                , buf_inkas.obj-type
                                , buf_inkas.obj-code
                                , buf_inkas.status_
                                , {&new-line}
                                ).
  end.
  run str/salegrfp.p (
                   input  buf_inkas.status_
                  ,input  buf_inkas.flag_
                  ,input  buf_trn-doc.status_
                  ,input  p-mode
                  ,output p-status_
                  ,output p-flag_
                  ,output p-ask-message
                  ) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1"          + {&new-line}
                              + "по операции: &2"    + {&new-line}
                              + "номер документа &3" + {&new-line}
                              + "статус &4&5"
                              ,
                              return-value,
                              p-mode,
                              buf_inkas.inkas-code,
                              buf_inkas.status_,
                              string(buf_inkas.flag_, "+/")
                              ).
  end.
  return ''.
end. /*do on error*/