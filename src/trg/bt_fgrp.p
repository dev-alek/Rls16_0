block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка изменений группы меню

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input  parameter p-message-on as logical   no-undo .
*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка изменений группы меню".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ str/defc-fgr.i "New SHARED" }
{ gbl/waitfram.i }



define temp-table temp-fgrp-list no-undo
  field action-num  as integer
  field obj-type    like ub.fbr-gds-grp.obj-type
  field obj-code    like ub.fbr-gds-grp.obj-code
  field node-code   like ub.fbr-gds-grp.node-code
  field out-code    like ub.fbr-gds-grp.out-code
  field upper-code  like ub.fbr-gds-grp.upper-code
  field upper-out-code  like ub.fbr-gds-grp.out-code
  field lvl-num      like ub.fbr-gds-grp.lvl-num
  field action      as character
  field bp_rowid    as rowid
  index xpk is primary unique action-num
  index iobj obj-type obj-code
.
define variable  p-message-on as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U.
define variable v-view-log as logical no-undo .
define variable v-stop as logical no-undo .

main-block:
do
on error undo main-block, return error return-value
:

  assign
  p-message-on = (if entry(1, p-parameter, {&delim-par}) = "yes"
                  then yes
                  else (if entry(1, p-parameter, {&delim-par}) = "no"
                        then no
                        else ?)
                )

  no-error
  .
  if error-status:error or p-message-on = ? then return error.

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ждите... Поиск информации, подлежащей отправке на кассы...")
                                            ).

  run create-fgrp-list in this-procedure .

  run waitfram-hide in this-procedure .

  run process-fgrp-list in this-procedure .

  run close-fgrp-list in this-procedure .

end.


procedure create-fgrp-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-fgrp-list for temp-fgrp-list .

  do
  on error undo, return error return-value
  :
    /* выбираем все задания по данному объекту для отсылки на кассу сущности группы блюд по объекту */

    for each buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-fgrp}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
    on error undo, return error return-value
    :
      create buf_temp-fgrp-list .
      assign
        buf_temp-fgrp-list.action-num  = buf_BatchProcess.BatchProcess#
        buf_temp-fgrp-list.obj-type    = buf_BatchProcess.charkey_one
        buf_temp-fgrp-list.obj-code    = buf_BatchProcess.key#_one
        buf_temp-fgrp-list.node-code   = buf_BatchProcess.key#_two
        buf_temp-fgrp-list.upper-code  = buf_BatchProcess.key#_three
        buf_temp-fgrp-list.out-code    = integer(buf_BatchProcess.charkey_two)
        buf_temp-fgrp-list.upper-out-code = integer(entry(1, buf_BatchProcess.charkey_three))
        buf_temp-fgrp-list.lvl-num     = integer(entry(2, buf_BatchProcess.charkey_three))
        buf_temp-fgrp-list.action      = buf_BatchProcess.bp_execsystime
        buf_temp-fgrp-list.bp_rowid   = rowid(buf_BatchProcess)
      .
    end.
  end.

end procedure.


procedure process-fgrp-list :

  define buffer buf_temp-fgrp-list for temp-fgrp-list .
  define buffer cli_shops for ub.clients .
  define buffer buf_cash-desk for ub.cash-desk .
  define variable lns-cnt as integer no-undo .
  define variable line-rec as recid no-undo .
  define variable v-db-num like ub.db.db-num no-undo .
  define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
  define buffer buf_clients for ub.clients.

  do
  on error undo, return error return-value
  :

   { gbl/curdbnum.i v-db-num }
    _buf_temp-fgrp-list:
    for each buf_temp-fgrp-list
    break
    by buf_temp-fgrp-list.obj-type
    by buf_temp-fgrp-list.obj-code
    on error undo, return error return-value
    :
      if first-of(buf_temp-fgrp-list.obj-code) then do:
        run get-stop-state in p-log-handle (output v-stop).
        if v-stop then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Процедура пересылки остановлена пользователем"
                                  )
                                    ).
          leave _buf_temp-fgrp-list.
        end.
        for each cash-fgrp:
          delete cash-fgrp.
        end.
      end.
      find first cash-fgrp where
                cash-fgrp.out-code = buf_temp-fgrp-list.out-code no-error .
      if not avail cash-fgrp then do:
        create cash-fgrp.
        assign
        cash-fgrp.out-code = buf_temp-fgrp-list.out-code
        .
      end.
      assign
      cash-fgrp.node-code = buf_temp-fgrp-list.node-code
      cash-fgrp.upper-code = buf_temp-fgrp-list.upper-code
      cash-fgrp.upper-out-code = buf_temp-fgrp-list.upper-out-code
      cash-fgrp.stts = (if buf_temp-fgrp-list.action = "D":U then 1 else 0)
      cash-fgrp.lvl-num = buf_temp-fgrp-list.lvl-num
      cash-fgrp.action-code = buf_temp-fgrp-list.action-num
      .
      if last-of(buf_temp-fgrp-list.obj-code) then do:
        if can-find(first cash-fgrp)
        and can-find(first buf_cash-desk where
                          buf_cash-desk.db-num = v-db-num
                      AND buf_cash-desk.OBJ-CODE = buf_temp-fgrp-list.obj-code
                      AND buf_cash-desk.pos-type = {&cd-type-magia-XML}
                          ) then do:
           run str/send-fgr.p (
                             input parparentproc
                            ,input this-procedure
                            ,input p-log-handle
                            ,input(string(buf_temp-fgrp-list.obj-code) + {&delim-par} + "U":U + {&delim-par} + "yes":U)
                          ) no-error .
          if error-status:error then do:
            run set-view-log in p-log-handle(yes).
          end.
        end. /*if can-find(first cash-fgrp)*/
      end. /*if last-of(buf_temp-fgrp-list.obj-code) then do:*/
    end.  /*for each buf_temp-fgrp-list*/
  end. /*doe*/
end procedure. /* process-fgrp-list */



procedure close-fgrp-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-fgrp-list for temp-fgrp-list .

  do
  on error undo, return error return-value
  :

    /* помечаем задания как удаленные */
    for each buf_temp-fgrp-list
    on error undo, return error return-value
    :
      do transaction
      on error undo, return error return-value
      :
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="buf_batchprocess"
          &btpr-rowid="buf_temp-fgrp-list.bp_rowid"
        }
      end.
    end.
  end.

end procedure.