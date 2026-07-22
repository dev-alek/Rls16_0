/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сдвиг чека на p-count строк

Автор: Белоусов Илья Александрович
Дата создания: 07/30/08
Author: Ilia Belousov
Creation date: 07/30/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&scop proc-name fr-FeedDocument
do:
  {&run_proc_fr-lib}
    ( input       {1} /* p-count           */
    , output      {2} /* p-err-message     */
    , output      {3} /* p-ok              */
    ) {4} .
end.


/* $Workfile$ e n d */