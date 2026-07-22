/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация терминала Сбербанка

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name sb-init
do:
  {&run_proc_sb-lib}
    ( input  {1}
    , output {2}  /* p-err-message         */
    , output {3}  /* p-ok               */
    ) {4} .
end.

/* $Workfile$ e n d */