/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура отчета Диспетчера

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/09
Author: Bakhtadze Natalya
Creation date: 07/16/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/tmpcxmlr.i tables-def {1} }

define temp-table obj-list no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field db-num as integer
field obj-address as character
field obj-phone as character
field obj-number as integer
index pi is unique primary
obj-type
obj-code
.

define temp-table tt-place no-undo
field obj-type as character
field obj-code as integer
field obj-number as integer
field gds-code as integer
field gds-name as character
field loc1 as character
field max-qnty as decimal
field add-qnty as decimal
field min-qnty as decimal
field current-sale  as decimal
field income as decimal
field sale-qnty-7 as decimal
field curr-qnty as decimal
field doc-qnty as decimal
field sale-qnty-1 as decimal
field curr-date as date
field curr-time-str as character
field level-water as decimal
field volume-water  as decimal
/*
index pi is unique primary
obj-type
obj-code
gds-code
loc1
*/
field obj-name           as character
field obj-address        as character
field obj-phone          as character
field sort-code          as integer
field pl-code            as integer
field found-in-rvs       as logical
field is-meas            as logical
field curr-time          as integer   /* время последней сверки */
index pu as primary unique
      obj-type
      obj-code
      sort-code
      gds-code
      pl-code
index i-print
      obj-number
      sort-code
      gds-code
      pl-code
INDEX rvs
      obj-type
      obj-code
      found-in-rvs
.

define dataset dispet-1
for obj-list, tt-place, report-header{1}, report-parameters{1}, report-errors{1}
data-relation r1 for obj-list, tt-place
relation-fields (obj-type, obj-type, obj-code, obj-code) nested
data-relation rh1 for report-header{1}, report-parameters{1}
relation-fields (report-id, report-id) nested
data-relation rh2 for report-header{1}, report-errors{1}
relation-fields (report-id, report-id) nested
.

/* $Workfile$ e n d */