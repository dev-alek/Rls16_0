/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/18/08
Author: Bakhtadze Natalya
Creation date: 12/18/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table goods-01 no-undo
field gds-code as integer
field src-gds-code as integer
field artic as character
field src-artic as character
field prod-type as character
field prod-code as integer
field src-prod-type as character
field src-prod-code as integer
field prod-name as character
field alpha1 as character
field attrib as character
field calc-method as character
field chk-name as character
field cond-keep-code as integer
field cli-base-rate as decimal
field cst-base-rate as decimal
field deadline as integer
field destin as character
field engl-name as character
field fbr-grp-code as integer
field fbr-grp-name as character
field gds-name as character
field gds-type as character
field grp-code as integer
field src-grp-code as integer
field grp-name as character
field increase-pc as decimal
field label-name as character
field max-rate as decimal
field min-rate as decimal
field ms-base as decimal
field ms-cart as decimal
field nationality as character
field negative-Rest as logical
field prt-root as integer
field prt-root-name as character
field normal-wastage as decimal
field normal-waste as decimal
field okdp as character
field PS as character
field qnty-cart as decimal
field sert as character
field sort as character
field struct as character
field tnved as character
field unit-base as character
field unit-cli as character
field unit-cst as character
field user-rule as character
field wt-base as decimal
field wt-cart as decimal
field attr-15x80 as character
field attr-8x50 as character
field attr-6x50 as character
field gds-obj-price-base as decimal
field gds-obj-price-rubl as decimal
field vat-pc-code as integer
field slt-pc-code as integer
index pi is unique primary
src-gds-code
index iprod
src-prod-type
src-prod-code
.
define {1} temp-table bar-code-01 no-undo
field b-code as integer
field src-b-code as integer
field gds-code as integer
field src-gds-code as integer
field cli-base-rate as decimal
/*field in-code as character  код док-та не импорт не экспорт*/
field node-code as integer
/*field part-code as character код партии не импорт не экспорт*/
field unit-cli as character
index pi as unique primary
src-b-code
.

define {1} temp-table prod-bc-01 no-undo
field b-str as character
field b-code as integer
field src-b-code as integer
field bc-on as logical
index pi is unique primary
src-b-code
b-str.

define {1} temp-table temp-tax-rate no-undo
field rate-code as integer
field src-rate-code as integer
field tax-code as integer
field tax-rate-value as decimal
index pi is unique primary
tax-code rate-code
index isrc src-rate-code
.



/* $Workfile$ e n d */