/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение настройки ВИРТУАЛЬНЫЕ СМЕНЫ для объекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/07
Author: Bakhtadze Natalya
Creation date: 01/16/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-character{&vssseq} as character no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-logical{&vssseq} as INTEGER no-undo .
define variable v-tth{&vssseq} as handle no-undo .

run adm/shattri.p (
    input "get":U
    ,input  {1}
    ,input  {2}
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_cas-shft} /*p-param-code*/
    ,output v-value-character{&vssseq}
    ,output v-value-date{&vssseq}
    ,output v-value-decimal{&vssseq}
    ,output {3}
    ,output v-value-logical{&vssseq}
    ,output v-param-type{&vssseq}
    ,INPUT-OUTPUT table-handle v-tth{&vssseq}
    ) {4} .

delete object v-tth{&vssseq}.

/* $Workfile$ */