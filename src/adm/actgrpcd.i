/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка прав на товарные группы по списку node-code

Автор: Белоусов Илья Александрович
Дата создания: 05/07/08
Author: Ilia Belousov
Creation date: 05/07/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name actgrpcd
do:
  {&run_proc_library2}
    ( input        {1}  /* p-db-num              */
    , input        {2}  /* p-user-id             */
    , input        {3}  /* p-action-head-code    */
    , input        {4}  /* p-action-item-id      */
    , input        {5}  /* p-obj-type            */
    , input        {6}  /* p-obj-code            */
    , input-output {7}  /* p-gds-grp-code-list   */
    , output       {8}  /* p-not-list         */
    , output       {9}  /* p-ok               */
    ) {10} .
end.

/* $Workfile$ e n d */