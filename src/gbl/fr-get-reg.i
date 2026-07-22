/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

содержимое регистра

Автор: Белоусов Илья Александрович
Дата создания: 07/30/08
Author: Ilia Belousov
Creation date: 07/30/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&scop proc-name fr-get-reg
do:
  {&run_proc_fr-lib}
    ( input       {1} /* p-reg-type           */
    , input       {2} /* p-reg-num               */
    , output      {3} /* p-reg-value  */
    , output      {4} /* p-reg-name  */
    , output      {5} /* p-err-message         */
    , output      {6} /* p-ok               */
    ) {7} .
end.


/* $Workfile$ e n d */