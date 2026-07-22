/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод строки на дисплей покупателя.

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name disp-str
do:
  {&run_proc_disp-lib}
    ( INPUT  {1}  /* p-first-string    */
    , INPUT  {2}  /* p-second-string   */
    , output {3}  /* p-err-message     */
    , output {4}  /* p-ok              */
    ) {5} .
end.

/* $Workfile$ e n d */