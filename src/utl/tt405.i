/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вспомагательные таблицы для импорта Договора со спецификации

Автор: Чернова Светлана Александровна
Дата создания: 02/05/09
Author: Svetlana Chernova
Creation date: 02/05/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp_contract no-undo
field contract-code as integer
field exch-code     as integer
field contract-date as date
field contract-type as character
field host-code     as integer
field cli-type      as character
field cli-code      as integer
field status_       as character
index pi
contract-code
.

define temp-table temp_contract-specif no-undo
field line-num as integer
field contract-code as integer
field exch-code     as integer
field gds-code      as integer
field vat-pc        as decimal
field vat-type      as character
field prc           as decimal
field price-cli     as decimal
field status_       as character
index pi
line-num
contract-code
gds-code

index pi2
contract-code
line-num
gds-code
  .

/* $Workfile$ e n d */