block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dbrecaft.p $
$Archive: nws/dbrecaft.p $

Запуск процедуры выполняемой после окончания two-commit

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/07/05
Author: Dmitry Ukhanov
Creation date: 09/07/05

*/

define input parameter p-db-source as integer   no-undo .
define input parameter p-command   as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dbrecaft.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/dbrecaft.p $":U .
def var vss-description as character no-undo init "Запуск процедуры выполняемой после окончания two-commit".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ nws/db-rec.i   }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-action            as character no-undo .
  define variable v-uniq-key-rec      as character no-undo .
  define variable v-db-init           as integer   no-undo .
  define variable v-parameters        as character no-undo .

  define variable v-ext-prg-handle      as handle    no-undo .
  define variable v-main-prog-name      as character no-undo .
  define variable v-list-db-proc-name   as character no-undo .
  define variable v-commit-proc-name    as character no-undo .
  define variable v-execution-proc-name as character no-undo .
  define variable v-recover-proc-name   as character no-undo .
  define variable v-after-proc-name     as character no-undo .

  define variable v-err-msg as character no-undo .

  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .

  define variable v-send-db-list as character no-undo .
  define variable v-all-db-list  as character no-undo .
  define variable v-db-for-send  as character no-undo .
  define variable v-curr-db      as integer   no-undo .
  define variable v-db-num-char  as character no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db      = buf_sys-ctrl.db-num
    v-action       = entry(3, p-command, {&delim-nws})
    v-uniq-key-rec = entry(4, p-command, {&delim-nws})
    v-db-init      = integer( entry(5, p-command, {&delim-nws}) )
    v-parameters   = entry(6, p-command, {&delim-nws})
  .


  run progs-name( input v-action
                 ,output v-main-prog-name
                 ,output v-list-db-proc-name
                 ,output v-commit-proc-name
                 ,output v-execution-proc-name
                 ,output v-recover-proc-name
                 ,output v-after-proc-name
                ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
  end.

  if trim( v-after-proc-name ) = "":U then do:
    return .
  end.

  run value( v-list-db-proc-name )
    ( input v-action
     ,input v-uniq-key-rec
     ,output v-all-db-list
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
  end.

  assign
    v-send-db-list = get-send-db-list( v-curr-db, v-all-db-list )
    v-db-for-send  = "":U
  .

  if v-curr-db = 0 then do:
    assign
      v-num-entries = num-entries( v-send-db-list, {&comma-char} )
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-db-num-char = entry( v-ind, v-send-db-list, {&comma-char} )
      .
      if v-db-num-char = "0":U
          or ( p-db-source <> ?
               and v-db-num-char = string( p-db-source )
             )
      then do:
        next.
      end.
      if v-db-for-send = "":U then do:
        assign
          v-db-for-send = v-db-num-char
        .
      end.
      else do:
        assign
          v-db-for-send =  v-db-for-send + {&delim-nws} + v-db-num-char
        .
      end.
    end.
  end.
  else do:
    if v-curr-db = v-db-init
      and p-db-source = ?
    then do:
      assign
        v-db-for-send = "0":U
      .
    end.
  end.

  if v-db-for-send <> "":U then do:
    run nws/cr-route.p ( input {&send-cmd}
                   ,input p-command
                   ,input ?
                   ,input v-db-for-send
                  ) no-error .
    if error-status :error then do:
      return error return-value.
    end.
  end.

  run value( v-main-prog-name ) persistent
      set v-ext-prg-handle .

  run value( v-after-proc-name ) in v-ext-prg-handle
    ( input v-action
     ,input v-uniq-key-rec
     ,input v-db-init
     ,input v-parameters
     ,output v-err-msg
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при выполнении команды после операции над записью &2.&3&4&5&6"
                              , vss-workfile
                              , v-uniq-key-rec
                              , {&new-line}
                              , return-value
                              , {&new-line}
                              , error-status :get-message(1)
                            ).
  end.
  if v-err-msg <> "":U then do:
    return v-err-msg.
  end.

  delete procedure v-ext-prg-handle .

end.

/* $Workfile: dbrecaft.p $ e n d */