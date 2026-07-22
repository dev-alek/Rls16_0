/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/25/10
Author: Bakhtadze Natalya
Creation date: 04/25/10

*/



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*
.old может подразумевать и v150 и v141 и ...!!!!

*/

define {1} temp-table temp-bind no-undo
field src-gds-code  as integer /*если товар в 15 версии не имеет соответствия с 14 то сюда пишем 0*/
field src-artic     as character
field src-prod-type as character
field src-prod-code as integer
field src-gds-name  as character
field src-unit-base as character
field src-stts as integer
field src-b-code as integer
field src-grp-name as character
field src-prod-name as character
field has-bind  as integer /*есть запись соответствия*/
field bind-producer as character initial " " /*соответствует ли производителя в 14 и в таблице соответствия*/
field bind-producer-name as character initial " " /*соответствует ли нвазание производителя в 14 и в таблице соответствия*/
field bind-artic as character initial " " /*соответствует ли артикул в 14 и в таблице соответствия*/
field bind-name as character initial " " /*соответствует ли название в 14 и в таблице соответствия*/
field bind-unit-base as character initial " " /*соответствует ли базовая ед изм в 14 и в таблице соответствия*/
field old-v151 as integer /*соответствие связано с товаром в 15: -1 - не связано; 0 - заполнено; 1-... кол-во товаров */
field trg-gds-code as integer
field trg-artic     as character
field trg-prod-type as character
field trg-prod-code as integer
field trg-gds-name  as character
field trg-unit-base as character
field trg-stts as integer
field trg-b-code as integer
field trg-grp-name as character
field trg-prod-name as character
field old-v151-producer as character initial " " /*соответствует ли производителя в 14 и в 15 через таблицу соответствия*/
field old-v151-artic as character initial " " /*соответствует ли артикул в 14 и в 15*/
field old-v151-name as character initial " " /*соответствует ли название в 14 и в 15*/
field old-v151-unit-base as character initial " " /*соответствует ли базовая ед изм в 14 и в 15*/
field old-v151-stts as character initial " " /*соответствует ли базовая ед изм в 14 и в 15*/
field old-v151-grp as character  initial " " /*соответствует ли группа в 14 и в 15*/
field old-v151-pbc as character initial " " /*гадости с допбк*/
field correct-bind as character index pi is unique primary
src-gds-code
trg-gds-code
index pi15
trg-gds-code
index icor
correct-bind

.

define {1} temp-table temp-prod-bc
field src-gds-code as integer
field src-root-code as integer
field src-b-code as integer
field src-unit-base as character
field src-unit-cli as character
field src-cli-base-rate as decimal
field src-b-str as character
field src-bc-on as logical
field old-gds-code as integer            /*поля дл язаписей из 15 уц которых нет свзяи*/
field old-root-code as integer
field old-b-code as integer
field old-unit-base as character
field old-unit-cli as character
field old-cli-base-rate as decimal
field old-b-str as character
field old-bc-on as logical
field trg-gds-code as integer            /*поля дл язаписей из 15 полученных по свзи*/
field trg-root-code as integer
field trg-b-code as integer
field trg-unit-base as character
field trg-unit-cli as character
field trg-cli-base-rate as decimal
field trg-b-str as character
field trg-bc-on as logical
field v151-gds-code as integer            /*поля дл язаписей из 14 полученныех не по связи*/
field v151-root-code as integer
field v151-b-code as integer
field v151-unit-base as character
field v151-unit-cli as character
field v151-cli-base-rate as decimal
field v151-b-str as character
field v151-bc-on as logical
field old-v151-bind as character
field old-v151-gds as character
field old-v151-unit-cli as character
field old-v151-cli-base-rate as character
field old-v151-bc-on as character
field correct-pbc-bind as character
index pi is unique primary
v151-gds-code
v151-b-code
v151-b-str
old-gds-code
old-b-code
old-b-str
index pisrc
src-gds-code
src-b-code
src-b-str
index pitrg
trg-gds-code
trg-b-code
trg-b-str
index pi15
v151-gds-code
v151-b-code
v151-b-str
index pi14
old-gds-code
old-b-code
old-b-str
index icor
correct-pbc-bind
.



/* $Workfile$ e n d */