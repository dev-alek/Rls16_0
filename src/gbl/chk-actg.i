/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка прав доступа

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name chk-actg
do:
  {&run_proc_library2}
    (input  {1}  /* p-db-num           */
    ,input  {2}  /* p-user-id          */
    ,input  {3}  /* p-action-head-code */
    ,input  {4}  /* p-action-item-id   */
    ,input  {5}  /* p-action-context   */
    ,input  {6}  /* p-host-code        */
    ,input  {7}  /* p-obj-type         */
    ,input  {8}  /* p-obj-code         */
    ,input  {9}  /* p-cli-grp-code     */
    ,input  {10} /* p-gds-grp-code     */
    ,input  {11} /* p-gds-code         */
    ,input  {12} /* p-show-message     */
    ,output {13} /* p-ok               */
    ) {14} .
end.
/* $Workfile$ e n d */