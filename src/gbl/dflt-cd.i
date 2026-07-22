/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение значения КАССЫ по УМОЛЧАНИЮ для объекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/07
Author: Bakhtadze Natalya
Creation date: 01/16/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-integer{&vssseq} as INTEGER no-undo .
define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
define variable v-tth{&vssseq} as handle no-undo .

run adm/shattri.p (
    input "get":U
    ,input  {1}
    ,input  {2}
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_dflt-cd} /*p-param-code*/
    ,output {3}
    ,output v-value-date{&vssseq}
    ,output v-value-decimal{&vssseq}
    ,output v-value-integer{&vssseq}
    ,output v-value-logical{&vssseq}
    ,output v-param-type{&vssseq}
    ,INPUT-OUTPUT table-handle v-tth{&vssseq}
    ) {4} .

delete object v-tth{&vssseq} no-error.

/* $Workfile$ */