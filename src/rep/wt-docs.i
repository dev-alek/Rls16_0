/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица документов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06


*/
DEFINE {1} shared TEMP-TABLE wt-docs no-undo
  field ext-doc-type as character
  FIELD acc-date    AS DATE      COLUMN-LABEL "Дата проводки"
  FIELD agnt        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Исполнитель"
  FIELD base-rate   AS DECIMAL   FORMAT ">>,>>9.99" COLUMN-LABEL "Курс"
  FIELD base-scale  AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Масштаб"
  FIELD boss        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Менеджер"
  FIELD cli-code    AS INTEGER   FORMAT "99999" COLUMN-LABEL "Код"
  FIELD cli-name    AS CHARACTER FORMAT "X(40)" COLUMN-LABEL "Контрагент"
  FIELD cli-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент"
  FIELD creid       AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Создал"
  FIELD ctr-num     AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент! !"
  FIELD discnt-pc   AS DECIMAL   FORMAT "->9.9%" COLUMN-LABEL "Скидка"
  FIELD discnt-rubl AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка"
  FIELD discnt-type AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Скидка"
  FIELD doc-code    AS CHARACTER FORMAT "X(14)" COLUMN-LABEL "Номер"
  FIELD doc-date    AS DATE      COLUMN-LABEL "Дата"
  FIELD doc-qnty    AS DECIMAL   FORMAT "->>,>>>,>>9.<<<" COLUMN-LABEL "Заявлено"
  FIELD doc-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Тип"
  FIELD exch-code   AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Валюта"
  FIELD exch-date   AS DATE      COLUMN-LABEL "Таможня"
  FIELD exch-rate   AS DECIMAL   FORMAT ">>,>>9.99"
  COLUMN-LABEL "Курс"
  FIELD exch-scale  AS INTEGER   FORMAT ">>9"
  COLUMN-LABEL "Масштаб"
  FIELD fact-base   AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD fact-date   AS DATE
  COLUMN-LABEL "факт"
  FIELD fact-num    AS INTEGER
  FIELD fact-qnty   AS DECIMAL   FORMAT "->>,>>>,>>9.<<<"
  COLUMN-LABEL "Фактически"
  FIELD fact-rubl   AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD flag_       AS LOGICAL   COLUMN-LABEL "Закр"
  FIELD internal    AS LOGICAL   COLUMN-LABEL "Внутр"
  FIELD inv-num     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Инвойс"
  FIELD obj-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Код"
  FIELD obj-type    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "ПО ОБЪЕКТАМ"
  FIELD office      AS LOGICAL
  FIELD ord-num     AS CHAR FORMAT "x(14)"
  COLUMN-LABEL "заказ"
  FIELD out-code    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Номер РН"
  FIELD ov          AS LOGICAL   FORMAT "+/-"
  COLUMN-LABEL "Акт переоценки"
  FIELD pay-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Оплата"
  FIELD print-rubl  AS LOGICAL
  COLUMN-LABEL "{&abbr_rublevaya_firstshift}"
  FIELD PS          AS CHARACTER FORMAT "X(50)"
  COLUMN-LABEL "Примечание"
  FIELD ship-date   AS DATE      COLUMN-LABEL "Дата"
  FIELD ship-num    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Отгрузка"
  FIELD status_     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "статус"
  FIELD tot-calc    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "Расчет"
  FIELD tot-cli     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По ТТН"
  FIELD tot-doc     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-fact    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD tot-ov      AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По акту"
  FIELD tot-rubl    AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-sale    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD wrkr        AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Кладовщик"
  FIELD host-code AS INTEGER   FORMAT "99999" COLUMN-LABEL "Фирма"
    field vat-type      as character
    field vat-base      as decimal
    field vat-rubl      as decimal
    field vat18-base    as decimal
    field vat18-rubl    as decimal
    field vat10-base    as decimal
    field vat10-rubl    as decimal
    field vat-on        as logical
    field doc-attr      as character
    field OurObjectName like ub.clients.obj-name
    field pay-name      like ub.pay-type.obj-name
    field Oper_Name     as character
    field Mngr_Name     as character
    field Wrkr_name     as character
    field Course        as decimal
    field pay-waitdate  as date
    field Isp-Name      as character
    field SLT-base      like ub.trn-doc.SLT-base
    field SLT-rubl      like ub.trn-doc.SLT-rubl
    .
/* $Workfile$ e n d */