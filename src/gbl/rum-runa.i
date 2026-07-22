/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов машины правил в событиях изменения сущностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/09
Author: Bakhtadze Natalya
Creation date: 10/07/09


define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-oldbh as handle no-undo .
define input  parameter p-newbh as handle no-undo .
define input  parameter p-changes-list as character no-undo .
define input  parameter p-doc-code-file-name as character no-undo .


*/

&scop proc-name rum-runa
{&run_proc_library}
  (input {1} /* parparentproc   */
  ,input {2} /* p-parent-handle */
  ,input {3} /* p-log-handle    */
  ,input {4} /* p-process       */
  ,input {5} /* p-oldbh         */
  ,input {6} /* p-new-bh        */
  ,input {7} /* p-changes-list  */
  ,input {8} /* p-doc-code-file-name    */
  ) {9} .

/* $Workfile$ e n d */