/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать заголовка документа

Автор: Белоусов Илья Александрович
Дата создания: 12/09/08
Author: Ilia Belousov
Creation date: 12/09/08

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&scop proc-name fr-DocTitle
do:
  {&run_proc_fr-lib}
    ( input       {1} /* p-doc-num           */
    , input       {2} /* p-doc-name          */
    , output      {3} /* p-err-message       */
    , output      {4} /* p-ok                */
    ) {5} .
end.


/* $Workfile$ e n d */