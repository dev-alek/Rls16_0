/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация фискального регистратора

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name fr-init
do:
  {&run_proc_fr-lib}
    ( input  {1}
    , input  {2}
    , input  {3}
    , input  {4}   /*  Тип фискального регистратора  */
    , input  {5}   /*   фр подключен ком-порту       */
    , output {6}  /* p-fr-model         */
    , output {7}  /* p-err-message         */
    , output {8}  /* p-ok               */
    ) {9} .
end.

/* $Workfile$ e n d */