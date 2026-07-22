/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов функции привязанной к функциональной клавише

Автор: Белоусов Илья Александрович
Дата создания: 07/21/08
Author: Ilia Belousov
Creation date: 07/21/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name func-pr
do:
  {&run_proc_fr-lib}
    ( input       {1}   /* p-func-name         */
    , output       {2}  /* p-ok               */
    ) {3} .
end.

/* $Workfile$ e n d */