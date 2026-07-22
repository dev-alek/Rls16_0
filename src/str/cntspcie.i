/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица для импорта-экспорта спецификаций - поля лежат НЕ В ТОМ ПОРЯДКЕ В КОТОРОМ ИМПОРТИРУЮТСЯ.ЭКСПОРТИРУЮТСЯ!!!

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/10
Author: Bakhtadze Natalya
Creation date: 07/15/10

*/

define temp-table cntspcie no-undo
field has-line-num as logical initial yes
field line-num as integer
field has-artic as logical initial no
field artic as character column-label "Артикул в IBS TH"
field has-prod-type as logical initial no
field prod-type as character column-label "Тип производителя в IBS TH"
field has-prod-code as logical initial no
field prod-code as integer  column-label "Код производителя в IBS TH"
field has-price-cli as logical initial no
field price-cli as decimal column-label "Цена поставщика"
field has-prc as logical initial no
field prc as decimal column-label "% отклонения в большую сторону"
field has-qnty as logical initial no
field qnty as decimal column-label "Количество"
field has-cli-base-rate as logical initial no
field cli-base-rate as decimal initial 1 column-label "Коэфф.ед.изм"
field has-vat-type as logical initial no
field vat-type as character initial {&inc-VAT} column-label "Тип НДС"
field has-vat-pc as logical initial no
field vat-pc as decimal column-label "НДС"
field has-bonus as logical initial no
field bonus as decimal column-label "Бонус"
field has-gds-name as logical initial no
field gds-name as character  column-label "Наименование в IBS TH"
field has-qnty-cart as logical initial no
field qnty-cart as decimal column-label "Кол-во в упаковке"
field has-ext-artic as logical initial no
field ext-artic as character column-label "Артикул поставщика"
field has-price-sale as logical initial no
field price-sale as decimal column-label "Текущая цена в IBS TH"
field has-b-str as logical initial no
field b-str as character column-label "ДопБК"
/* #2095 Добавляем 2 поля  */
FIELD has-DeadLine AS LOGICAL   INITIAL NO
FIELD DeadLine     AS INTEGER   COLUMN-LABEL "Срок хранения (дней)"
FIELD has-Obj-Name AS LOGICAL   INITIAL NO
FIELD Obj-Name     AS CHARACTER COLUMN-LABEL "Наименование производителя"
FIELD has-prc-min AS LOGICAL   INITIAL NO
FIELD prc-min     AS decimal COLUMN-LABEL "% отклонения в меньшую сторону"
index pi is unique primary line-num
.

/* $Workfile$ e n d */