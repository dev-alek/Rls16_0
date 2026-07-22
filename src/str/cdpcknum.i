/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

нахождение настройки количество записей в пакете на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-character{&vssseq} as date no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-integer{&vssseq} as INTEGER no-undo .
define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
define variable v-tth{&vssseq} as handle no-undo .
define variable cdpcknum as integer no-undo init 200.
run adm/shattri.p (
    input "get":U
    ,input  {1}
    ,input  {2}
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_cdpcknum} /*p-param-code*/
    ,output v-value-character{&vssseq}
    ,output v-value-date{&vssseq}
    ,output v-value-decimal{&vssseq}
    ,output cdpcknum
    ,output v-value-logical{&vssseq}
    ,output v-param-type{&vssseq}
    ,INPUT-OUTPUT table-handle v-tth{&vssseq}
    ) {4} .

delete object v-tth{&vssseq}.

/* $Workfile$ e n d */