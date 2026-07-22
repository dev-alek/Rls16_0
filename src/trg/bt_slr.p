block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка изменений клиента-продавца

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

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
define variable vss-description as character no-undo init "Обработка изменений клиента-продавца".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ str/defc-csh.i "New SHARED" }
{ gbl/gbclcode.i }

define temp-table temp-slr-list no-undo
  field action-num  as integer
  field seller      as integer
  field s-password  as character
  field psn-code    like ub.person.psn-code
  field host-code   as integer
  field obj-type    as character
  field obj-code    as integer
  field action      as character
  field bp_rowid    as rowid
  index xpk is primary unique action-num
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




  define buffer btpr-dc-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-btpr-seller}
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input ",,,,,,Обработка изменений клиента-продавца"
    ,input p-message-on
    ,buffer btpr-dc-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("В данный момент происходит Обработка изменений клиента-продавца" )
                                              ).

    undo, return error "В данный момент происходит Обработка изменений клиента-продавца" .
  end.

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ждите... Поиск информации, подлежащей отправке на кассы...")
                                            ).

  run create-slr-list in this-procedure .

  run process-slr-list in this-procedure .

  run close-slr-list in this-procedure .

end.


procedure create-slr-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-slr-list for temp-slr-list .

  do
  on error undo, return error return-value
  :
    /* выбираем все задания по данному объекту для отсылки на кассу сущности продавцы */

    for each buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-seller}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
    on error undo, return error return-value
    :
      create buf_temp-slr-list .
      assign
        buf_temp-slr-list.action-num = buf_BatchProcess.BatchProcess#
        buf_temp-slr-list.seller     = integer(buf_BatchProcess.charkey_one)
        buf_temp-slr-list.s-password = buf_BatchProcess.charkey_three
        buf_temp-slr-list.psn-code   = buf_BatchProcess.key#_one
        buf_temp-slr-list.host-code  = buf_BatchProcess.key#_two
        buf_temp-slr-list.obj-type   = buf_BatchProcess.charkey_two
        buf_temp-slr-list.obj-code   = buf_BatchProcess.key#_three
        buf_temp-slr-list.action     = buf_BatchProcess.bp_execsystime
        buf_temp-slr-list.bp_rowid   = rowid(buf_BatchProcess)
      .
    end.
  end.

end procedure.


procedure process-slr-list :

  define buffer buf_temp-slr-list for temp-slr-list .
  define buffer cli_shops for ub.clients .
  define buffer buf_cash-desk for ub.cash-desk .
  define variable lns-cnt as integer no-undo .
  define variable line-rec as recid no-undo .
  define variable v-db-num like ub.db.db-num no-undo .
  define variable v-c-password as character no-undo .
  define variable v-s-password as character no-undo .
  define variable v-cashier-code as integer no-undo .
  define variable v-seller-code as integer no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define buffer buf_person for ub.person.
  define buffer buf_clients for ub.clients.

  do
  on error undo, return error return-value
  :

   { gbl/curdbnum.i v-db-num }
    for each buf_temp-slr-list
    on error undo, return error return-value
    :
      find first buf_person no-lock where
                 buf_person.psn-code = buf_temp-slr-list.psn-code no-error .
      if avail buf_person then do:
        find first buf_clients no-lock where
                   buf_clients.obj-type = {&prs}
              AND  buf_clients.obj-code = buf_person.psn-code.
        find first cash-cash where
                   cash-cash.slr-code = buf_temp-slr-list.seller no-error .
        if not avail cash-cash then do:
          create cash-cash.
          assign
          cash-cash.slr-code = buf_temp-slr-list.seller
          cash-cash.psn-code = buf_temp-slr-list.psn-code
          .
          v-seller-code = gbclcode-get-db-role (
                                                  input {&role-seller}
                                                 ,input v-db-num
                                                 ,input cash-cash.psn-code
                                                 ,input ? /*todo*/
                                                 ,output v-s-password ).

          v-cashier-code = gbclcode-get-db-role (
                                                  input {&role-cashier}
                                                 ,input v-db-num
                                                 ,input cash-cash.psn-code
                                                 ,input ? /*todo*/
                                                 ,output v-c-password ).
        end.
        assign
        cash-cash.cash-name = buf_clients.obj-name
        cash-cash.stts      = (if buf_temp-slr-list.action = "D":U
                               or v-seller-code = 0
                               then 1
                               else 0 )
        cash-cash.s-psswd   = v-s-password
        cash-cash.cash-code  = v-cashier-code
        cash-cash.psswd     = v-c-password
        cash-cash.ident-type  = 1
        .
      end. /*avail person*/
    end.
    if can-find(first cash-cash)
    and can-find(first buf_cash-desk where
                      buf_cash-desk.db-num = v-db-num ) then do:
      _cli-shops:
      FOR EACH cli_shops no-lock where
             cli_shops.obj-type = {&shop} and
             cli_shops.db-num = v-db-num,
             FIRST buf_cash-desk where
                   buf_cash-desk.obj-code = cli_shops.obj-code:
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
        run str/send-slr.p (  input parparentproc
                            ,input this-procedure
                            ,input p-log-handle
                            ,input(string(cli_shops.obj-code) + {&delim-par} + "U":U + {&delim-par} + "yes":U)
                          ) no-error .
        if error-status:error then do:
          run set-view-log in p-log-handle(yes).
        end.
      end.
    end.
    if not v-stop then do:
      find first buf_cash-desk no-lock where
                  buf_cash-desk.db-num = g#db-num
              AND buf_cash-desk.cash-on = yes
              AND buf_cash-desk.pos-type = {&cd-type-MAGIA-XML} no-error .
      if available buf_cash-desk then do:
        run str/send-stf.p (    input parparentproc
                          ,input this-procedure
                          ,input p-log-handle
                          ,input({&shop} + {&delim-par} + string(buf_cash-desk.obj-code) + {&delim-par} + "U":U +
                                {&delim-par} + "yes":U)
                                                    ) .
      end.
    end.
  end.
end procedure. /* process-gds-list */



procedure close-slr-list :

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-slr-list for temp-slr-list .

  do
  on error undo, return error return-value
  :

    /* помечаем задания как удаленные */
    for each buf_temp-slr-list
    on error undo, return error return-value
    :
      do transaction
      on error undo, return error return-value
      :
        /* update batchprocess record status as executing and deleted */
        { trg/btpr_upd.i
          &btpr-status="executing_deleted"
          &btpr-table="buf_batchprocess"
          &btpr-rowid="buf_temp-slr-list.bp_rowid"
        }
      end.
    end.
  end.

end procedure.