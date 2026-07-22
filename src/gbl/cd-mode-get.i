/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить режим ФР

Автор: Белоусов Илья Александрович
Дата создания: 07/24/08
Author: Ilia Belousov
Creation date: 07/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name cd-mode-get
do:
  {&run_proc_fr-lib}
    ( output       {1}  /* v-mode                      */
    , output       {2}  /* v-submode                   */
    , output       {3}  /* p-err-message               */
    , output       {4}  /* p-ok                        */
    ) {5} .
end.

/* $Workfile$ e n d */