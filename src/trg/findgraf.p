block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Стандартный граф переходов финансовых документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03


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
|        remote         |      remote  |          remote               /работаем стандартно        |
|-----------------------|--------------|-------------------------------/---------------------------|
|        remote         |another remote|          remote               /ошибка документа           |
|-----------------------|--------------|-------------------------------/---------------------------|


Стандартный граф переходов -
работа на БД, которая является главной БАЗОЙ фирмы - все объекты принадлежат этой базе

|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|
|Документы/Статусы                    |  нов   |      | разр |       | банк  |      | факт |     | отказ |
|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|
|Приход наличные                      | start> |      |  >f  |       |       |      |      |     |       |
|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|
|Приход безналичные                   | start> |      | <>   |       |  <>   |      |  >   |     |  ][   |
|                                     | gen  > |      | <>   |       |  <>   |      |  >   |     |  ][   |
|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|
|Расход наличные                      | start> |      |  >f  |       |       |      |      |     |       |
|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|
|Расход безналичные                   | start> |      |  <>  |       |   <>  |      |   >  |     |  ][   |
|                                     | gen  > |      |  <>  |       |   <>  |      |   >  |     |  ][   |
|-------------------------------------|--------|------|------|-------|-------|------|------|-----|-------|


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

define input  parameter p-host-code           like ub.fin-doc.host-code    no-undo .
define input  parameter p-fin-doc-code        like ub.fin-doc.fin-doc-code no-undo .
define input  parameter p-mode                as character                 no-undo .
define input  parameter p-author             as character                 no-undo .
/*
{&close-doc}
{&open-doc}
{&close-fact}
{&reject-doc}
*/
define input  parameter p-status-current      like ub.fin-doc.status_      no-undo .
define input  parameter p-status-date         like ub.fin-doc.fact-date    no-undo .
define output parameter p-status_             like ub.fin-doc.status_      no-undo . /*в какой перейдет*/
define output parameter p-ask-date            as logical                   no-undo .
define output parameter p-ask-message         as character                 no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов финансовых документов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/lib-farh.i }


define variable v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num as integer no-undo init -1.
define variable v-author as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-doc for ub.fin-doc.
define buffer bf_clients for ub.clients.
define buffer bf_db for ub.db .

do on error undo, return error substitute ("Ошибка при вызове программы findgraf.p: &1 &2 &3 &4 при работе с документом &4.", error-status:get-message(1), error-status:get-message(2), return-value, p-host-code, p-fin-doc-code):
  if p-mode <> {&close-doc}
  AND p-mode <> {&open-doc}
  AND p-mode <> {&close-fact}
  AND p-mode <> {&reject-doc}
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
     return error substitute ("Не найдена фирма с номером &1 для платежа", p-host-code, p-fin-doc-code).
  end.
  find first buf_fin-doc where
            buf_fin-doc.host-code = p-host-code
        AND buf_fin-doc.fin-doc-code = p-fin-doc-code no-lock no-error.
  if not available buf_fin-doc then do:
     return error substitute ("Не найден платеж: фирма &1 с номером &2.", p-host-code, p-fin-doc-code).
  end.
  if buf_sysconf.firm-db-num = ? or
     buf_sysconf.firm-db-num < 0 then do:
     return error substitute ("Неверный номер базы данных &1 фирмы &2.", buf_sysconf.firm-db-num, buf_sysconf.host-code).
  end.
  find first bf_db where bf_db.db-num = buf_sysconf.firm-db-num no-lock no-error.
  if not available bf_db then do:
     return error substitute("Не найдена БД &1 документа &2 для фирмы &3.", buf_sysconf.firm-db-num, p-fin-doc-code, buf_sysconf.host-code).
  end.
  if buf_fin-doc.obj-type <> ''
  or buf_fin-doc.obj-code <> 0 then do:
    { gbl/objdbnum.i buf_fin-doc.obj-type buf_fin-doc.obj-code v-obj-db-num }
  end.
  if not (v-db-num = buf_sysconf.firm-db-num
         or
         v-db-num = v-obj-db-num)
  then do:
    return error substitute("Нельзя изменять запись ПЛАТЕЖА в БД, отличной от главной БД фирмы и/или БД объекта:&1" +
                             "платеж &2&1" +
                             "номер текущей БД &3, номер главной БД фирмы &4, номер БД объекта &5"
                             , {&new-line}
                             , buf_fin-doc.fin-doc-code
                             , v-db-num
                             , buf_sysconf.firm-db-num
                             , (if v-obj-db-num = -1 then "неопределена" else string(v-obj-db-num))
                             ).
  end.

/*  define variable v-log as logical no-undo .                                                                        */
/*  define variable v-out-mess as character no-undo .                                                                 */
/*  define variable v-cash-book-place as character no-undo .                                                          */
/*  v-cash-book-place = buf_fin-doc.trn-doc-code.                                                                     */
/*  { str/finchkdb.i                                                                                                  */
/*    buf_fin-doc.host-code                                                                                           */
/*    buf_fin-doc.fin-doc-code                                                                                        */
/*    buf_fin-doc.obj-type                                                                                            */
/*    buf_fin-doc.obj-code                                                                                            */
/*    buf_fin-doc.fin-ext-doc-type                                                                                    */
/*    v-cash-book-place                                                                                               */
/*    ?                                                                                                               */
/*    v-log                                                                                                           */
/*    v-out-mess                                                                                                      */
/*    no-error }                                                                                                      */
/*  if error-status:error then do:                                                                                    */
/*    undo, return error  substitute("Ошибка при проверке корректности создания документа в данной БД &1&2&1&3"       */
/*                                                , {&new-line}                                                       */
/*                                                , error-status:get-message(1)                                       */
/*                                                , return-value                                                      */
/*                                                ).                                                                  */
/*                                                                                                                    */
/*  end.                                                                                                              */
/*  if not v-log then do:                                                                                             */
/*    undo, return error substitute("Невозможно создать/изменить документ в данной БД:&1&2", {&new-line}, v-out-mess).*/
/*  end.                                                                                                              */



  find first bf_clients where bf_clients.obj-type = buf_fin-doc.payer-type and
                              bf_clients.obj-code = buf_fin-doc.payer-code no-lock no-error.
  if not available bf_clients then do:
     return error substitute ("Не найден плательщик &1 &2 для платежа &3.", buf_fin-doc.payer-type, buf_fin-doc.payer-code, buf_fin-doc.fin-doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = buf_fin-doc.receiver-type and
                              bf_clients.obj-code = buf_fin-doc.receiver-code no-lock no-error.
  if not available bf_clients then do:
     return error substitute ("Не найден получатель &1 &2 для платежа &3.", buf_fin-doc.receiver-type, buf_fin-doc.receiver-code, buf_fin-doc.fin-doc-code).
  end.
  if buf_fin-doc.status_ = {&fact} then do:
     return error substitute ("Платеж &1 для фирмы &2 закрыт до факта. " + {&new-line} + "Операции с ним не допустимы.", buf_fin-doc.prn-doc-code, buf_sysconf.host-code).
  end.
  run trg/findgrfp.p (
                   input this-procedure:handle
                  ,input  buf_fin-doc.fin-doc-type
                  ,input  buf_fin-doc.fin-ext-doc-type
                  ,input  buf_fin-doc.status_
                  ,input  p-mode
                  ,input  p-author
                  ,input  p-status-date
                  ,output p-status_
                  ,output p-ask-date
                  ,output p-ask-message
                  ) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1"          + {&new-line}
                              + "по операции: &2"    + {&new-line}
                              + "номер документа &3" + {&new-line}
                              + "тип &4"             + {&new-line}
                              + "расш.тип &5"        + {&new-line}
                              + "статус &6"          + {&new-line}
                              ,
                              return-value,
                              p-mode,
                              buf_fin-doc.fin-doc-code,
                              buf_fin-doc.fin-doc-type,
                              buf_fin-doc.fin-ext-doc-type,
                              buf_fin-doc.status_
                              ).
  end.

end. /*do on error*/

procedure check-cl-bank :
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank  for ub.fin-bank.


  do
  on error undo, return error
  :
  CASE buf_fin-doc.fin-ext-doc-type:
    when {&FDEDT_Income_Cashless} then do:
      find first buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_fin-doc.host-code
            AND buf_fin-schet.code-schet = buf_fin-doc.receiver-code-schet .
    end.
    when {&FDEDT_Expense_Cashless} then do:
      find first buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_fin-doc.host-code
            AND buf_fin-schet.code-schet = buf_fin-doc.payer-code-schet .
    end.
  END CASE.
  find first buf_fin-bank no-lock where
            buf_fin-bank.host-code = buf_fin-doc.host-code
        AND buf_fin-bank.code-bank = buf_fin-schet.code-bank.
  if buf_fin-bank.cl-bank <> '':U then do:
    return error substitute("Платеж &1 для фирмы &2 проходит по счету банка&3 &4, который подключен к системе КЛИЕНТ-БАНК. ВРУЧНУЮ обработать невозможно"
                            , buf_fin-doc.prn-doc-code
                            , buf_sysconf.host-code
                            , {&new-line}
                            , buf_fin-bank.bank-name).
  end.

  end. /*doe*/

end procedure. /* check-cl-bank */