/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания истории на остатки по МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/05
Author: Bakhtadze Natalya
Creation date: 08/15/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure wth-obj-hist :
define parameter buffer buf_wth-obj for ub.wth-obj.
define input parameter p-obj-type like ub.wth-obj.obj-type no-undo .
define input parameter p-obj-code like ub.wth-obj.obj-code no-undo .
define input parameter p-wth-code like ub.wth-obj.wth-code no-undo .
define input parameter p-action-type as character no-undo .
define input  parameter p-source-type        as character no-undo .
define input  parameter p-source-ref         as character no-undo .
define input  parameter p-source-date        as date      no-undo .
define input  parameter p-corr-user-db-num   as integer   no-undo .
define input  parameter p-corr-user-name     as character no-undo .
define input  parameter p-corr-date          as date      no-undo .
define input  parameter p-corr-time          as integer   no-undo .
define input  parameter p-corr-time-str      as character no-undo .

define variable v-new-chip-num as integer   no-undo .

define buffer buf_c-wth-obj for ub.c-wth-obj .

  do
  for buf_c-wth-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-wth-obj exclusive-lock
      where buf_c-wth-obj.obj-type = buf_wth-obj.obj-type
        and buf_c-wth-obj.obj-code = buf_wth-obj.obj-code
        and buf_c-wth-obj.wth-code = buf_wth-obj.wth-code
        and buf_c-wth-obj.corr-user-db-num = p-corr-user-db-num
      use-index pi
      no-error .
    if available buf_c-wth-obj
    then do:
      assign
        v-new-chip-num = buf_c-wth-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.

    create buf_c-wth-obj .
    if p-action-type = {&c-gds-obj_delete}
    and
    not available buf_wth-obj then do:
      assign
      buf_c-wth-obj.obj-type = p-obj-type
      buf_c-wth-obj.obj-code = p-obj-code
      buf_c-wth-obj.wth-code = p-wth-code
      .
    end.
    else do:
      buffer-copy buf_wth-obj to
      buf_c-wth-obj.
    end.
    assign
      buf_c-wth-obj.chip-num          = v-new-chip-num
      buf_c-wth-obj.action-type       = p-action-type
      buf_c-wth-obj.source-type       = p-source-type
      buf_c-wth-obj.source-ref        = p-source-ref
      buf_c-wth-obj.source-date       = p-source-date
      buf_c-wth-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-wth-obj.corr-user-name    = p-corr-user-name
      buf_c-wth-obj.corr-date         = p-corr-date
      buf_c-wth-obj.corr-time         = p-corr-time
      buf_c-wth-obj.corr-time-str     = p-corr-time-str
    .
  end.

end procedure. /* wth-obj-hist */


/* $Workfile$ e n d */