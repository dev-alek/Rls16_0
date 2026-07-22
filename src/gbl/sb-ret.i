/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выплаза по возврату через Сбербанка

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name sb-ret
do:
  {&run_proc_sb-lib}
    ( input  {1}  /* p-summ */
    , input  {2}  /* p-card-num               */
    , output {3}  /* p-slip         */
    , output {4}  /* p-err-message               */
    , output {5}  /* p-ok               */
    ) {6} .
end.

/* $Workfile$ e n d */