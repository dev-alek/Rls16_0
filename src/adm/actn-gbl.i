/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

включена ли в системе работа с правами по группам товаров

Автор: Волошина Ирина Юрьевна
Дата создания: 19/08/2018
Author: Voloshina Irina
Creation date: 19/08/18

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name actn-gbl
do:
  {&run_proc_library2}
    ( output {1} /* p-on               */
    ) {2} .
end.

/* $Workfile$ e n d */