/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

включена ли в системе работа с правами по группам товаров

Автор: Белоусов Илья Александрович
Дата создания: 05/06/08
Author: Ilia Belousov
Creation date: 05/06/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name actn-grp
do:
  {&run_proc_library2}
    ( output {1} /* p-on               */
    ) {2} .
end.

/* $Workfile$ e n d */