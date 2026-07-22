block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка изменений товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input  parameter p-message-on as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка изменений товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ cmp/gds-list.i gds-list def "NEW SHARED" }
{ cmp/gdsolist.i gdsolist def  }
{ cmp/goa-list.i goa-list def "NEW SHARED" }
{ gbl/waitfram.i }


define temp-table temp-gds-list no-undo
  field action-num  as integer
  field gds-code    as integer
  field host-code   as integer
  field obj-type    as character
  field obj-code    as integer
  field action      as character
  field bp_rowid    as rowid
  index xpk is primary unique action-num
  index xie1 gds-code
.

define variable v-view-log as logical no-undo .
define variable v-stop as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U.



main-block:
do
on error undo main-block, return error return-value
:
  for each gdsolist:
    delete gdsolist.
  end.
  define buffer btpr-gds-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-btpr-gds}
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input ",,,,,,Обработка изменений товара"
    ,input p-message-on
    ,buffer btpr-gds-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if p-message-on = true
    or error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент происходит Обработка изменений товара" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент происходит Обработка изменений товара" .
  end.

  run waitfram-show in this-procedure ("Ждите... Поиск информации, подлежащей отправке на кассы..." ).

  run create-gds-list in this-procedure .

  run waitfram-hide in this-procedure .

  run process-gds-list in this-procedure .

  run close-gds-list in this-procedure .

end.


procedure create-gds-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-gds-list for temp-gds-list .

  do
  on error undo, return error return-value
  :
    /* выбираем все задания по данному объекту для отсылки на кассу сущности товаров */

    for each buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-gds}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
    on error undo, return error return-value
    :
      create buf_temp-gds-list .
      assign
        buf_temp-gds-list.action-num = buf_BatchProcess.BatchProcess#
        buf_temp-gds-list.gds-code   = buf_BatchProcess.key#_one
        buf_temp-gds-list.host-code  = buf_BatchProcess.key#_two
        buf_temp-gds-list.obj-type   = buf_BatchProcess.charkey_one
        buf_temp-gds-list.obj-code   = buf_BatchProcess.key#_three
        buf_temp-gds-list.action     = buf_BatchProcess.bp_execsystime
        buf_temp-gds-list.bp_rowid   = rowid(buf_BatchProcess)
      .
    end.
  end.

end procedure.


procedure process-gds-list :

  define buffer buf_temp-gds-list for temp-gds-list .
  define buffer cli_shops for ub.clients .
  define buffer buf_cash-desk for ub.cash-desk .
  define variable lns-cnt as integer no-undo .
  define variable line-rec as recid no-undo .
  define variable v-db-num like ub.db.db-num no-undo .

  do
  on error undo, return error return-value
  :

   { gbl/curdbnum.i v-db-num }
    for each buf_temp-gds-list
    on error undo, return error return-value
    :
      find first ub.goods no-lock where
                ub.goods.gds-code = buf_temp-gds-list.gds-code no-error .
      if avail ub.goods then do:
        if buf_temp-gds-list.obj-type = "":U
        AND buf_temp-gds-list.obj-code = 0 then do:
        /*предназначено всем объектам*/
            { cmp/gds-list.i gds-list assign }
            assign
            gds-list.to-del = buf_temp-gds-list.action = "D":U
            gds-list.order-num = action-num
            .
        end.
        else do:
         /*предназначено конкретному объекту*/
          find first gdsolist where
                     gdsolist.gds-code = buf_temp-gds-list.gds-code
                AND  gdsolist.obj-type = buf_temp-gds-list.obj-type
                and  gdsolist.obj-code = buf_temp-gds-list.obj-code
                no-error .
          if not avail gdsolist then do:
            create gdsolist.
            buffer-copy goods to gdsolist
            assign
            gdsolist.to-del = (buf_temp-gds-list.action = "D":U)
            gdsolist.order-num = lns-cnt + 1
            gdsolist.obj-type = buf_temp-gds-list.obj-type
            gdsolist.obj-code = buf_temp-gds-list.obj-code
            .
            assign
            lns-cnt = lns-cnt + 1
            line-rec = recid (gdsolist)
            .
          end.
          else do:
            assign
            gdsolist.to-del = (buf_temp-gds-list.action = "D":U)
            gdsolist.order-num =  buf_temp-gds-list.action-num
            .
          end.
        end.
      end. /*avail goods*/
    end.
    if (can-find(first gds-list)
        or can-find(first gdsolist) )
    and can-find(first buf_cash-desk where
                      buf_cash-desk.db-num = v-db-num ) then do:
      _cli-shops:
      FOR EACH cli_shops no-lock where
             cli_shops.obj-type = {&shop} and
             cli_shops.db-num = v-db-num,
             FIRST buf_cash-desk where
                   buf_cash-desk.obj-code = cli_shops.obj-code:
       /*сначала допишем в gds-list те записи которые предназначены ТОЛЬКО данному магазину*/
       for each gdsolist no-lock where
                gdsolist.obj-type = {&shop} and
                gdsolist.obj-code = cli_shops.obj-code:
          find first gds-list where
                     gds-list.gds-code = gdsolist.gds-code no-error .
          if avail gds-list
          and gds-list.order-num > gdsolist.order-num then NEXT.
          if not avail gds-list then do:
            find first goods no-lock where
                       goods.gds-code = gdsolist.gds-code no-error .
            if available goods then do:
              { cmp/gds-list.i gds-list assign }
            end.
          end.
          if avail gds-list then
          assign
          gds-list.order-num = gdsolist.order-num
          /*сигнал для send-gds.p чтобы стер эту запись*/
          gds-list.qnty = -1
          .
       END.
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        leave _cli-shops.
      end.
      run str/send-gds.p (
                      input parparentproc
                     ,input this-procedure
                     ,input p-log-handle
                     ,input (string(cli_shops.obj-code) + {&delim-par} + "yes":U)
                     ) no-error .
      if error-status:error then do:
          run set-view-log in p-log-handle(yes).
      end.
       /*стирание записей предназначенных только данному магазину производится в send-gds.i*/
    end.
  end.
  end.
end procedure. /* process-gds-list */



procedure close-gds-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-gds-list for temp-gds-list .

  do
  on error undo, return error return-value
  :

    /* помечаем задания как удаленные */
    for each buf_temp-gds-list
    on error undo, return error return-value
    :
      do transaction
      on error undo, return error return-value
      :
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="buf_batchprocess"
          &btpr-rowid="buf_temp-gds-list.bp_rowid"
        }
      end.
    end.
  end.

end procedure.