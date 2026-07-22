/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/20/09
Author: Bakhtadze Natalya
Creation date: 07/20/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/tmpcxmlr.i tables-def {1} }


define {2} temp-table shift{1} no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field base-code as integer
field curr-abbr as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define {2}  temp-table shift-pgds{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field gds-name as character
field start-state-qnty as decimal /*на начало смены факт 1.2*/
field start-system-qnty as decimal /*на начало смены расч-книжн 1.2*/
field start-state-qnty-2 as decimal /*на начало смены факт кг 1.2*/
field start-system-qnty-2 as decimal /*на начало смены расч-книжн кг 1.2*/
field end-state-qnty as decimal /*на конец смены факт 1.15*/
field end-system-qnty as decimal /*на конец смены расч-книжн 1.16*/
field end-state-qnty-2 as decimal /*на конец смены факт кг 1.15.1*/
field end-system-qnty-2 as decimal /*на конец смены расч-книжн кг 1.16*/
field in-qnty as decimal /*поступило 1.3*/
field in-qnty-2 as decimal /*поступило 1.3*/
field icnt-out-qnty as decimal /*расход по счетным механизмам*/
field end-price-sale as decimal /*цена на конец смены*/
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
.

define {2}  temp-table shift-pgds-in{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal /*л*/
field fact-qnty-2 as decimal /*кг*/
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
doc-code
.

define {2}  temp-table shift-pgds-out{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal /*л*/
field fact-qnty-2 as decimal /*кг*/
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
pay-code
curr-code
.


define {2} temp-table shift-grp{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field full-grp-name as character
field start-qnty as decimal
field start-sum as decimal
field end-qnty as decimal
field end-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
.

define {2} temp-table shift-grp-in{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-cost-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
doc-code
.

define {2} temp-table shift-grp-out{1} no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal /*л*/
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
pay-code
curr-code
.



define dataset shift-1{1}
for shift{1}, shift-pgds{1}, shift-pgds-in{1}, shift-pgds-out{1}, shift-grp{1}, shift-grp-in{1}, shift-grp-out{1},
report-header{1}, report-parameters{1}, report-errors{1}
data-relation r1 for shift{1}, shift-pgds{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for shift{1}, shift-grp{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r11 for shift-pgds{1}, shift-pgds-out{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r12 for shift-pgds{1}, shift-pgds-in{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r21 for shift-grp{1}, shift-grp-out{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation r22 for shift-grp{1}, shift-grp-in{1}
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation rh1 for report-header{1}, report-parameters{1}
relation-fields (report-id, report-id) nested
data-relation rh2 for report-header{1}, report-errors{1}
relation-fields (report-id, report-id) nested
.


/* $Workfile$ e n d */