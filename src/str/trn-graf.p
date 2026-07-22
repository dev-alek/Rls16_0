block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-graf.p $
$Archive: str/trn-graf.p $

Стандартный граф переходов складских документов

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06



parmode - {&close-doc}, {&open-doc}, {&close-fact}, {&reserv-doc}, {&frozze-doc}, {&update-doc}

|-----------------------|--------------|---------------------------|----------------------------|
|БД на которой работаем | БД документа |  Акт/пас объект документа | Вывод о работе             |
|-----------------------|--------------|---------------------------|----------------------------|
|        main           |      main    |         активный          | работаем стандартно        |
|-----------------------|--------------|---------------------------|----------------------------|
|        main           |      main    |         пассивный         | ошибка объекта             |
|-----------------------|--------------|---------------------------|----------------------------|
|        main           |      remote  |         активный          | работаем с ограничениями   |
|-----------------------|--------------|---------------------------|----------------------------|
|        main           |      remote  |         пассивный         | работаем стандартно        |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |      main    |         активный          | ошибка документа           |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |      main    |         пассивный         | ошибка объекта и документа |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |      remote  |         активный          | работаем стандартно        |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |      remote  |         пассивный         | только просмотр            |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |another remote|         активный          | ошибка документа           |
|-----------------------|--------------|---------------------------|----------------------------|
|        remote         |another remote|         пассивный         | ошибка документа           |
-------------------------------------------------------------------------------------------------

Стандартный граф переходов -
работа в объекте своей базы данных на активном объекте или
в главной базе данных с номером 0 для пассивного объекта другой базы > 0

|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Документы/Статусы                    |запр- |---->|запр+|накл-  |---->|накл+|<----|разр-|---->|разр+|---->|факт|
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Приход внешний                       |start>|news | <>  |start>f|news | <>  |  -  |  -  |  -  |  -  |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Расход внешний                       |start>|  -  | <>  |start> |news | <>  |news |  -  |news |  <> |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Возврат внеший(возврат от покупателя)|start>|  -  | <>  |start> |news | <>  |news |  -  |news |  <> |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Списание                             |start>|  -  | <>  |start> |news | <>  |news |  -  |news |  <> |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Инвентаризация                       |  -   |  -  |  -  |start> |news | <>  |news | <>f |news | <n+>|news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Коррекция учетных цен                |  -   |  -  |  -  |start>f|     |     |     |     |     |     |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Приход внутренний                    |start>|news | ][  |   -   | -   |genp>| -   |  -  |  -  |  -  |news | ][ |
|                                     |      |     |     |       |     |news |     |     |     |     |     |    |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Расход внутренний                    |start>|     | <>  |start> |news |  <> |news |  -  |news |  <> |news | ][ |
|-------------------------------------|------|-----|-----|-------|-----|-----|-----|-----|-----|-----|-----|----|
|Возврат внутренний                   |  -   |  -  |  -  |   -   |  -  |genr>|news |  -  |news |  <> |news | ][ |
|                                     |      |     |     |       |     |news |     |     |     |     |     |    |
-----------------------------------------------------------------------------------------------------------------

Работа в главной базе данных с номером 0 для активного объекта чужой базы данных с номером > 0

|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Документы/Статусы                    |запр- |---->|запр+|накл-       |---->|накл+|разр-|разр+|факт|
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Приход внешний                       |start>|news | ][  |start>      |news | ][  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Расход внешний                       |start>|news | ][  |  -         |  -  |  -  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Возврат внеший(возврат от покупателя)|start>|news | ][  |  -         |  -  | -   |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Списание                             |start>|news | ][  |  -         |  -  |  -  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Инвентаризация                       |  -   | -   |  -  |start>      |news | ][  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Приход внутренний                    |start>|news | ][  |  -         |  -  |  -  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Расход внутренний                    |start>|news | ][  |  -         |  -  |  -  |  -  |  -  |  - |
|-------------------------------------|------|-----|-----|------------|-----|-----|-----|-----|----|
|Возврат внутренний                   |  -   |  -  |  -  |  -         |  -  |  -  |  -  |  -  |  - |
----------------------------------------------------------------------------------------------------

start - добавляется вручную
genp  - автоматически генерится на основании внутреннего расхода
genr  - автоматически генерится на основании внутреннего прихода
> - изменяется, переходит в след.статус
f - переходит сразу в статус факт
n+ - переход в статус 'накл+'
news - отправляется по новостям, если мы в удаленной базе данных или документ не нашей БД
][ - остается в данном статусе, не редактируется.
"-" - не обрабатывется.

*/


define input    parameter pardoc-code   like ub.trn-doc.doc-code no-undo. /*номер документа*/
define input    parameter parcur-db-num like ub.db.db-num        no-undo. /*БД на которой работает*/
define input    parameter parmode       as   character           no-undo. /*режим обработки документа*/
define output   parameter parstatus     like ub.trn-doc.status_  no-undo. /*статус в который документ перейдет*/
define output   parameter parflag       like ub.trn-doc.flag_    no-undo. /*флаг в который документ перейдет*/
define output   parameter parcopystatus like ub.trn-doc.status_  no-undo. /*статус документа в который будет копироваться данный*/
define output   parameter parcopyflag   like ub.trn-doc.flag_    no-undo. /*флаг документа в который будет копироваться*/
define buffer   bf_cur-db       for  ub.db.
define buffer   bf_db           for  ub.db.
define buffer   bf_trn-doc      for  ub.trn-doc.
define buffer   bf_clients      for  ub.clients.
define buffer   bf_store        for  ub.store.
define variable varactive       like ub.store.active no-undo.
define variable varext-oper     as   character       no-undo.
define variable p-is-hold as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-graf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/trn-graf.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов складских документов".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,pardoc-code,parcur-db-num,parmode)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
do on error undo, return error substitute ("Ошибка при вызове программы trn-graf.p: &1 &2 &3 при работе с документом &4.", error-status:get-message(1), error-status:get-message(2), return-value, pardoc-code):
  if parmode <> {&close-doc}      and
     parmode <> {&open-doc}       and
     parmode <> {&close-fact}     and
     parmode <> {&reserv-doc}     then do:
     return error substitute ("Неверный режим обработки документа &1.", parmode).
  end.
  if parcur-db-num = ? or
     parcur-db-num < 0 then do:
     return error substitute ("Неверный номер &1 текущей БД.", parcur-db-num).
  end.
  find first bf_cur-db where bf_cur-db.db-num = parcur-db-num no-lock no-error.
  if not available bf_cur-db then do:
     return error substitute ("Не найдена текущая БД с номером &1.", parcur-db-num).
  end.
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if not available bf_trn-doc then do:
     return error substitute ("Не найден документ с номером &1 .", bf_trn-doc.doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                              bf_clients.obj-code = bf_trn-doc.obj-code no-lock no-error.
  if not available bf_clients then do:
     return error substitute ("Не найден объект &1 &2 для документа &3.", bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf_trn-doc.doc-code).
  end.
  if bf_clients.db-num = ? or
     bf_clients.db-num < 0 then do:
     return error substitute ("Неверный номер базы данных &1 объекта &2 &3.", bf_clients.db-num, bf_clients.obj-type, bf_clients.obj-code).
  end.
  find first bf_db where bf_db.db-num = bf_clients.db-num no-lock no-error.
  if not available bf_db then do:
     return error substitute("Не найдена БД &1 документа &2.", bf_clients.db-num, pardoc-code).
  end.
  case bf_clients.obj-type:
    when {&shop} then do:
       assign varactive = yes.
    end.
    when {&stock} then do:
      find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock no-error.
      if not available bf_store then do:
        return error substitute ("Ошибка при поиске склада с номером &1.", bf_clients.obj-code).
      end.
      assign varactive = bf_store.active.
    end.
    otherwise do:
      return error substitute ("Неверный тип объекта &1 документа.", bf_trn-doc.obj-type, bf_trn-doc.doc-code).
    end.
  end case.
  if varactive = ? then do:
     return error substitute ("Неизвестный признак '?' активности объекта &1 &2", bf_trn-doc.obj-type, bf_trn-doc.obj-code).
  end.

  if bf_trn-doc.internal = ? then do:
      return error substitute ("Неверный указан признак документа внешний/внутренний &1 - '?'.", bf_trn-doc.doc-code).
  end.
  if bf_trn-doc.flag_ = ? then do:
     return error substitute ("Неверный флаг документа &1 - '?'.", bf_trn-doc.doc-code).
  end.
  if bf_trn-doc.status_ = {&fact} then do:
     return error substitute ("Документ &1 закрыт до факта. " + {&new-line} + "Операции с ним не допустимы.", bf_trn-doc.doc-code).
  end.

 { gbl/hold-doc.i
   bf_trn-doc.doc-code
   p-is-hold
  }
  run str/trn-grfp.p (input  bf_trn-doc.doc-type,
                  input  bf_trn-doc.ext-doc-type,
                  input  bf_trn-doc.status_,
                  input  bf_trn-doc.flag_,
                  input  bf_trn-doc.internal,
                  input  parmode,
                  input  parcur-db-num,
                  input  bf_trn-doc.cr-db-num,
                  input  bf_cur-db.db-name,
                  input  bf_clients.db-num,
                  input  bf_db.db-name,
                  input  bf_clients.obj-type,
                  input  bf_clients.obj-code,
                  input  varactive,
                  input  p-is-hold ,
                  output parstatus,
                  output parflag,
                  output parcopystatus,
                  output parcopyflag) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1"          + {&new-line}
                              + "по операции: &2"        + {&new-line}
                              + "номер документа &3" + {&new-line}
                              + "тип &4"             + {&new-line}
                              + "статус &5"          + {&new-line}
                              + "флаг &6.",
                              return-value,
                              parmode,
                              bf_trn-doc.doc-code,
                              bf_trn-doc.doc-type,
                              bf_trn-doc.status_,
                              bf_trn-doc.flag_).
  end.
end. /*do on error*/