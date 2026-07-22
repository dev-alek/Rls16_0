/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

временная таблица для ABC XYZ  анализов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 05/19/05
*/
define temp-table temp-oborot no-undo
field gds-code       as integer
field obj-type       as char
field obj-code       as integer
field sum-crit       as decimal
field qnty           as decimal
field price-crc      as decimal
field price-cost     as decimal
field reserve-day    as integer
field stock-qnty     as decimal
field sum-acc        as decimal
field sum-cur        as decimal
field sum-doc        as decimal
field vat-acc        as decimal
field vat-cur        as decimal
field vat-doc        as decimal
field transport-acc  as decimal
field transport-cur  as decimal
field transport-doc  as decimal
field other-acc      as decimal
field other-cur      as decimal
field other-doc      as decimal
field road-tax-acc   as decimal
field road-tax-cur   as decimal
field road-tax-doc   as decimal
field slt-acc        as decimal
field slt-cur        as decimal
field slt-doc        as decimal
field order-qnty     as decimal
field temp-sale-goods  as decimal
index pi as unique primary  gds-code obj-type obj-code
.
define temp-table temp-goods no-undo
field gds-code       as integer
field sum-crit       as decimal
field crit-pr        as decimal
field crit           as char
field kol-period     as int
field average-qnty   as decimal
field sigma          as decimal
field K_V            as decimal
field qnty           as decimal
field price-crc      as decimal
field reserve-day    as integer
field sum-acc        as decimal
field sum-cur        as decimal
field sum-doc        as decimal
field vat-acc        as decimal
field vat-cur        as decimal
field vat-doc        as decimal
field transport-acc  as decimal
field transport-cur  as decimal
field transport-doc  as decimal
field other-acc      as decimal
field other-cur      as decimal
field other-doc      as decimal
field road-tax-acc   as decimal
field road-tax-cur   as decimal
field road-tax-doc   as decimal
field slt-acc        as decimal
field slt-cur        as decimal
field slt-doc        as decimal
field order-qnty       as decimal
field stock-price-acc  as decimal
field stock-price-sale as decimal
field stock-qnty       as decimal
field temp-sale-goods  as decimal
field prcnt-account as decimal
index pi as UNIQUE primary  gds-code
index pi-1 crit-pr desc
.

define temp-table temp-xyz no-undo
field gds-code       as integer
field num-per        as integer
field sum-crit-p     as decimal
index pi2 as UNIQUE primary   gds-code num-per
.