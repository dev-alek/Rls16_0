/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация дисплея покупателя.

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name disp-init
do:
  {&run_proc_disp-lib}
    ( input  {1}
    , input  {2}
    , input  {3}
    , input  {4}
    , output {5}  /* p-err-message         */
    , output {6}  /* p-ok               */
    ) {7} .
end.

/* $Workfile$ e n d */