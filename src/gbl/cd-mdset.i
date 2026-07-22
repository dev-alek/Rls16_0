/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание режима работы кассы

Автор: Белоусов Илья Александрович
Дата создания: 07/21/08
Author: Ilia Belousov
Creation date: 07/21/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name cd-mode-set
do:
  {&run_proc_fr-lib}
    ( input       {1}  /* p-err-message         */
    , input       {2}  /* p-ok               */
    ) {3} .
end.

/* $Workfile$ e n d */