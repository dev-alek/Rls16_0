/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Датасет для хранения отчета ДИНАМИКА ПРОДАЖ ПО АЗК ПО СМЕНЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/13/09
Author: Bakhtadze Natalya
Creation date: 07/13/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/tmpcxmlr.i tables-def {1} }

define temp-table obj-dyn-sal{1} no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field current-datetime as datetime
field report-num as integer
index pi is unique primary
obj-type
obj-code
.

define temp-table cd-dyn-sal{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field cash-num as integer
field start-date as date
field start-time as integer
field end-date as date
field end-time as integer
field report-num as integer
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
cash-num
.


define temp-table grp-dyn-sal{1} no-undo
field node-code as integer
field full-name as character
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
node-code
.

define temp-table gds-dyn-sal{1} no-undo
field gds-code as integer
field node-code as integer
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field unit-base as character
field gds-name as character
field fact-qnty as decimal
field fact-sum as decimal
field is-petrol as logical
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
index igrp
obj-type
obj-code
shift-date
shift-num
node-code
.

define dataset report-ptdysa-ds{1}
for report-header{1}, report-parameters{1}, report-errors{1},  obj-dyn-sal{1}, cd-dyn-sal{1}, grp-dyn-sal{1}, gds-dyn-sal{1}
data-relation r1 for obj-dyn-sal{1}, grp-dyn-sal{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for grp-dyn-sal{1}, gds-dyn-sal{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, node-code, node-code) nested
data-relation r3 for obj-dyn-sal{1}, cd-dyn-sal{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation rh1 for report-header{1}, report-parameters{1}
relation-fields (report-id, report-id) nested
data-relation rh2 for report-header{1}, report-errors{1}
relation-fields (report-id, report-id) nested
.



/* $Workfile$ e n d */