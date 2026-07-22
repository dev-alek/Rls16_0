/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация фискального регистратора (выставление данных из контекста)

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-set

do:
  {&run_proc_fr-lib}
    ( input  {1}  /* v-pay-names */
    , input  {2}  /* v-z-zero    */
    , input  {3}  /* v-cashier-name */
    , input  {4}  /* v-cash-drawer-plug */
    , input  {5}  /* v-cash-drawer-plug-imp */
    , input  {6}  /* v-cutter */
    , input  {7}  /* v-cash-drawer-level */
    , input  {8}  /* v-advert-text */
    , input  {9}  /* v-cliche-lines   */
    , input  {10} /*  v-print-good-code  */
    , input  {11} /*  v-max-netto */
    , input  {12} /*  v-cash-shift   */
    , input  {13} /*  v-cash-drawer-open */
    , input  {14} /*  v-cash-drawer-limit   */
    , input  {15} /*  v-clear-cash-counter   */
    , output {16} /* p-err-message         */
    , output {17} /* p-ok               */
    ) {18} .
end.

/* $Workfile$ e n d */