/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

скидка

Автор: Белоусов Илья Александрович
Дата создания: 07/30/08
Author: Ilia Belousov
Creation date: 07/30/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&scop proc-name fr-discount
do:
  {&run_proc_fr-lib}
    ( input       {1}  /* p-discount          */
    , input       {2}  /* p-name             */
    , output      {3} /* p-err-message         */
    , output      {4} /* p-ok               */
    ) {5} .
end.


/* $Workfile$ e n d */