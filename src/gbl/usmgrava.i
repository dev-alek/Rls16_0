/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверить, доступно ли пользователю группа пунктов меню для указанного контекста

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usmgrava
{&run_proc_library2}
  (input  {1}  /* p-db-num               */
  ,input  {2}  /* p-action-head-code     */
  ,input  {3}  /* p-user-id              */
  ,input  {4}  /* p-menu-code            */
  ,input  {5}  /* p-menu-group-code      */
  ,input  {6}  /* p-cntxt-level          */
  ,input  {7}  /* p-cntxt-host-code-obj  */
  ,input  {8}  /* p-cntxt-obj-type       */
  ,input  {9}  /* p-cntxt-obj-code       */
  ,output {10} /* p-menu-group-available */
  ) {11} .
/* $Workfile$ e n d */