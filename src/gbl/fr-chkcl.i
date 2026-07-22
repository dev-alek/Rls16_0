/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

закрытие чека на ФР

Автор: Белоусов Илья Александрович
Дата создания: 08/01/08
Author: Ilia Belousov
Creation date: 08/01/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-chkcl

do:
  {&run_proc_fr-lib}
    (
      input       {1}  /* p-summ-1           */
    , input       {2}  /* p-summ-2           */
    , input       {3}  /* p-summ-3           */
    , input       {4}  /* p-summ-4           */
    , input       {5}  /* p-card             */
    , output      {6}  /* p-chk-num  */
    , output      {7}  /* p-rest-summ  */
    , output      {8}  /* p-err-message      */
    , output      {9}  /* p-ok               */
    ) {10} .
end.

/* $Workfile$ e n d */