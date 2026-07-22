block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка изменений клиента-карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input  parameter p-message-on as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка изменений клиента-карты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list def "NEW SHARED" }
{ cmp/dcp-list.i dcp-list def "NEW SHARED" }
{ str/defc-cli.i "New SHARED" }
{ gbl/waitfram.i }


define temp-table temp-dc-list no-undo
  field action-num  as integer
  field d-card      as character
  field host-code   as integer
  field obj-type    as character
  field obj-code    as integer
  field action      as character
  field bp_rowid    as rowid
  index xpk is primary unique action-num
  index xie1 d-card
.

define variable v-stop as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U.



main-block:
do
on error undo main-block, return error return-value
:
  define buffer btpr-dc-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-btpr-dcard}
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input ",,,,,,Обработка изменений клиента-карты"
    ,input p-message-on
    ,buffer btpr-dc-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if p-message-on = true
    or error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент происходит Обработка изменений клиента-карты" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент происходит Обработка изменений клиента-карты" .
  end.

  run waitfram-show in this-procedure ("Ждите... Поиск информации, подлежащей отправке на кассы..." ).

  run create-dc-list in this-procedure .

  run waitfram-hide in this-procedure .

  run process-dc-list in this-procedure .

  run close-dc-list in this-procedure .

end.


procedure create-dc-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-dc-list for temp-dc-list .

  do
  on error undo, return error return-value
  :
    /* выбираем все задания по данному объекту для отсылки на кассу сущности товаров */

    for each buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-dcard}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
    on error undo, return error return-value
    :
      create buf_temp-dc-list .
      assign
        buf_temp-dc-list.action-num = buf_BatchProcess.BatchProcess#
        buf_temp-dc-list.d-card      = buf_BatchProcess.charkey_one
        buf_temp-dc-list.host-code  = buf_BatchProcess.key#_one
        buf_temp-dc-list.obj-type   = buf_BatchProcess.charkey_two
        buf_temp-dc-list.obj-code   = buf_BatchProcess.key#_two
        buf_temp-dc-list.action     = buf_BatchProcess.bp_execsystime
        buf_temp-dc-list.bp_rowid   = rowid(buf_BatchProcess)
      .
    end.
  end.

end procedure.


procedure process-dc-list :

  define buffer buf_temp-dc-list for temp-dc-list .
  define buffer cli_shops for ub.clients .
  define buffer buf_cash-desk for ub.cash-desk .
  define variable lns-cnt as integer no-undo .
  define variable line-rec as recid no-undo .
  define variable v-db-num like ub.db.db-num no-undo .

  do
  on error undo, return error return-value
  :

   { gbl/curdbnum.i v-db-num }
    for each buf_temp-dc-list
    on error undo, return error return-value
    :
      find first ub.dis-card no-lock where
                ub.dis-card.d-card = buf_temp-dc-list.d-card no-error .
      if avail ub.dis-card then do:
        if buf_temp-dc-list.obj-type = "":U
        AND buf_temp-dc-list.obj-code = 0 then do:
        /*предназначено всем объектам*/
            { cmp/dc-list.i dc-list assign }
            assign
            dc-list.to-del = buf_temp-dc-list.action = "D":U
            dc-list.order-num = action-num
            .
        end.
        else do:
         /*предназначено конкретному объекту*/
         /*пока не обрабатываем потому как таких атрибутов пока нет !!!*/
          find first dcp-list where
                     dcp-list.d-card   = buf_temp-dc-list.d-card
                AND  dcp-list.host-code = buf_temp-dc-list.host-code
                AND  dcp-list.obj-type = buf_temp-dc-list.obj-type
                and  dcp-list.obj-code = buf_temp-dc-list.obj-code
                and  dcp-list.dt-code = 0
                and  dcp-list.node-code = 0
                no-error .
          if not avail dcp-list then do:
            create dcp-list.
            assign
            dcp-list.d-card = buf_temp-dc-list.d-card
            dcp-list.host-code = buf_temp-dc-list.host-code
            dcp-list.obj-type = buf_temp-dc-list.obj-type
            dcp-list.obj-code = buf_temp-dc-list.obj-code
            .
          end.
          assign
          dcp-list.to-del = (buf_temp-dc-list.action = "D":U)
          dcp-list.order-num =  buf_temp-dc-list.action-num
          .
        end.
      end. /*avail dis-card*/
    end.
    if (can-find(first dc-list)
        or can-find(first dcp-list) )
    and can-find(first buf_cash-desk where
                      buf_cash-desk.db-num = v-db-num ) then do:
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        return.
      end.
      run str/sendclia.p (
                      input parparentproc
                    , input this-procedure
                    , input p-log-handle
                    , (string(g#db-num) + {&delim-par} + "optimize":U + {&delim-par} + "yes":U + {&delim-par} + "S":U)
                    )
      no-error .
      if error-status:error then do:
          run set-view-log in p-log-handle(yes).
      end.

       /*стирание записей предназначенных только данному магазину производится в send-cli.i*/
    end.
  end.
end procedure. /* process-gds-list */



procedure close-dc-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-dc-list for temp-dc-list .

  do
  on error undo, return error return-value
  :

    /* помечаем задания как удаленные */
    for each buf_temp-dc-list
    on error undo, return error return-value
    :
      do transaction
      on error undo, return error return-value
      :
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="buf_batchprocess"
          &btpr-rowid="buf_temp-dc-list.bp_rowid"
        }
      end.
    end.
  end.

end procedure.