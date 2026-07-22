/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка состояния ФР

Автор: Белоусов Илья Александрович
Дата создания: 07/23/08
Author: Ilia Belousov
Creation date: 07/23/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-ctrl
do:
  {&run_proc_fr-lib}
    ( input        {1}
    , output       {2}  /* p-err-message         */
    , output       {3}  /* p-ok               */
    , output       {4}  /* p-fr-mode */
    , output       {5}  /* p-fr-time */
    , output       {6}  /* p-fr-date */
    , output       {7}  /* p-fr-last-shift-date */
    , output       {8}  /* p-fr-last-shift-num */
    , output       {9}  /* p-fr-lic */
    , output       {10} /* p-fr-shift-open */
    , output       {11} /* p-fr-serial */
    ) {12} .
end.

/* $Workfile$ e n d */