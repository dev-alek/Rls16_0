/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка видимости группы меню

Автор: Белоусов Илья Александрович
Дата создания: 08/15/07
Author: Ilia Belousov
Creation date: 08/15/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name chkmngr
{&run_proc_library2}
  (input  {1}  /* p-menu-group-id */
  ,input  {2}  /* p-context       */
  ,input  {3}  /* p-cntxt-obj-type      */
  ,input  {4}  /* p-cntxt-obj-code      */
  ,input  {5}  /* p-cntxt-db-num        */
  ,output {6}  /* p-ok            */
  ) {7} .


/* $Workfile$ e n d */