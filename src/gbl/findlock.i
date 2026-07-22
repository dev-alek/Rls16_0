/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица информации о блокировках записи

Автор: Перваков Михаил Сергеевич
Дата создания: 01/28/05
Author: Mikhail Pervakov
Creation date: 01/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-lock no-undo
  field lock-conn-id   as integer   label "Номер Подключения"
  field user-name      as character label "Пользователь"
  field lock-flag      as character label "Флаг"
  field trans-id       as integer   label "Транзакция"
  field trans-txtime   as character
  field trans-state    as character
  field trans-dur      as integer
  field connect-type   as character label "Подключение"
  field connect-time   as character format "x(20)"
  field connect-device as character format "x(40)" label "Устройство"
  .

/* $Workfile$ e n d */