/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

информация о банковской карте

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name sb-cardinfo
do:
  {&run_proc_sb-lib}
    ( output {1}  /* p-card-num         */
    , output {2}  /* p-card-type        */
    , output {3}  /* p-err-message      */
    , output {4}  /* p-ok               */
    ) {5} .
end.

/* $Workfile$ e n d */