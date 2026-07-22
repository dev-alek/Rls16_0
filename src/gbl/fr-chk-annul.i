/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Аннулирование открытого чека

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-chk-annul
do:
  {&run_proc_fr-lib}
    ( output       {1}  /* p-chk-fr-num         */
    , output       {2}  /* p-err-message               */
    , output       {3}  /* p-ok               */
    ) {4} .
end.

/* $Workfile$ e n d */