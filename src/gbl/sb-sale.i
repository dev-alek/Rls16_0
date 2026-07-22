/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оплата продажи через Сбербанка

Автор: Белоусов Илья Александрович
Дата создания: 09/12/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name sb-sale
do:
  {&run_proc_sb-lib}
    ( input  {1}  /* p-summ */
    , output {2}  /* p-slip         */
    , output {3}  /* p-card-num               */
    , output {4}  /* p-err-message               */
    , output {5}  /* p-ok               */
    ) {6} .
end.

/* $Workfile$ e n d */