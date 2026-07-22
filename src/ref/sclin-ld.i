/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение значения способ установки СРОКА ГОДНОСТИ  при закрытии накладной или переоценки для объекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/08
Author: Bakhtadze Natalya
Creation date: 12/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-character{&vssseq} as character no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
define variable v-tth{&vssseq} as handle no-undo .

run adm/shattri.p (
    input "get":U
    ,input  {1}
    ,input  {2}
    ,input  {&attr-scale-inf}
    ,input  {&attr-scale-inf_sclin-ld} /*p-param-code*/
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