/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать строки чека продажи

Автор: Белоусов Илья Александрович
Дата создания: 07/30/08
Author: Ilia Belousov
Creation date: 07/30/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&scop proc-name fr-add-ret
do:
  {&run_proc_fr-lib}
    ( input       {1}  /* p-barcode          */
    , input       {2}  /* p-name             */
    , input       {3}  /* p-price            */
    , input       {4}  /* p-qnty             */
    , input       {5}  /* p-unit-base        */
    , input       {6}  /* p-d-card        */
    , input       {7}  /* p-discount         */
    , output      {8} /* p-err-message         */
    , output      {9} /* p-ok               */
    ) {10} .
end.


/* $Workfile$ e n d */