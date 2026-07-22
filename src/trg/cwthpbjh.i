/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания истории на остатки по МЦ по МХ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/05
Author: Bakhtadze Natalya
Creation date: 08/15/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure wth-pobj-hist :
define parameter buffer buf_wth-pobj for ub.wth-pobj.
define input parameter p-obj-type like ub.wth-pobj.obj-type no-undo .
define input parameter p-obj-code like ub.wth-pobj.obj-code no-undo .
define input parameter p-wth-code like ub.wth-pobj.wth-code no-undo .
define input parameter p-w-p-code like ub.wth-pobj.w-p-code no-undo .
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

define buffer buf_c-wth-pobj for ub.c-wth-pobj .

  do
  for buf_c-wth-pobj
  transaction
  on error undo, return error return-value
  :
    find first buf_c-wth-pobj exclusive-lock
      where buf_c-wth-pobj.obj-type = buf_wth-pobj.obj-type
        and buf_c-wth-pobj.obj-code = buf_wth-pobj.obj-code
        and buf_c-wth-pobj.wth-code = buf_wth-pobj.wth-code
        and buf_c-wth-pobj.w-p-code = buf_wth-pobj.w-p-code
      use-index ishow
      no-error .
    if available buf_c-wth-pobj
    then do:
       assign
        v-new-chip-num = buf_c-wth-pobj.chip-num + 1
      .

    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.
    create buf_c-wth-pobj .
    if p-action-type = {&c-wth-obj_delete}
    and
    not available buf_wth-pobj then do:
      assign
      buf_c-wth-pobj.obj-type = p-obj-type
      buf_c-wth-pobj.obj-code = p-obj-code
      buf_c-wth-pobj.wth-code = p-wth-code
      buf_c-wth-pobj.w-p-code = p-w-p-code
      buf_c-wth-pobj.corr-user-db-num  = p-corr-user-db-num
      .
    end.
    else do:
      buffer-copy buf_wth-pobj to buf_c-wth-pobj
      assign buf_c-wth-pobj.corr-user-db-num  = p-corr-user-db-num
      .
    end.
    assign
      buf_c-wth-pobj.chip-num          = v-new-chip-num
      buf_c-wth-pobj.action-type       = p-action-type
      buf_c-wth-pobj.source-type       = p-source-type
      buf_c-wth-pobj.source-ref        = p-source-ref
      buf_c-wth-pobj.source-date       = p-source-date
      buf_c-wth-pobj.corr-user-name    = p-corr-user-name
      buf_c-wth-pobj.corr-date         = p-corr-date
      buf_c-wth-pobj.corr-time         = p-corr-time
      buf_c-wth-pobj.corr-time-str     = p-corr-time-str
    .
  end. /*doe*/

end procedure. /* wth-pobj-hist */



/* $Workfile$ e n d */