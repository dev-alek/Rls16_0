/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка выполняющихся распределенных команд по СПН

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/05
Author: Dmitry Ukhanov
Creation date: 10/06/05

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/db-rec.i }

define temp-table temp_db-rec-attr no-undo like ub.db-rec-attr
  field db-list as character
.

procedure fill-two-commit-command :

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-main-prog-name      as character no-undo .
    define variable v-list-db-proc-name   as character no-undo .
    define variable v-commit-proc-name    as character no-undo .
    define variable v-execution-proc-name as character no-undo .
    define variable v-recover-proc-name   as character no-undo .
    define variable v-after-proc-name     as character no-undo .

    define buffer buf_db-rec-attr for ub.db-rec-attr .

    for each buf_db-rec-attr exclusive-lock
      break by buf_db-rec-attr.db-num
    on error undo, return error return-value
    :
      find first temp_db-rec-attr
        where temp_db-rec-attr.uniq-key-rec = buf_db-rec-attr.uniq-key-rec
          and temp_db-rec-attr.attr-code    = buf_db-rec-attr.attr-code
        no-error.
      if not available temp_db-rec-attr then do:
        create temp_db-rec-attr.
        buffer-copy buf_db-rec-attr to temp_db-rec-attr
          assign
            temp_db-rec-attr.db-list = string( buf_db-rec-attr.db-num )
        .
        run progs-name in this-procedure
          ( input buf_db-rec-attr.attr-code
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

        run value( v-list-db-proc-name )
          ( input buf_db-rec-attr.attr-code
           ,input buf_db-rec-attr.uniq-key-rec
           ,output temp_db-rec-attr.db-list
          ) no-error .
        if error-status :error then do:
          return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
        end.
      end.
/*      else do:*/
/*        assign*/
/*          temp_db-rec-attr.db-list = temp_db-rec-attr.db-list + substitute( ",&1", buf_db-rec-attr.db-num )*/
/*        .*/
/*      end.*/
      if temp_db-rec-attr.db-num <> 0 then do:
        if buf_db-rec-attr.db-num = 0 then do:
          assign
            temp_db-rec-attr.db-num = buf_db-rec-attr.db-num
          .
        end.
        else do:
          assign
            temp_db-rec-attr.db-num = ?
          .
        end.
      end.
    end.
    return.
  end.
end procedure. /* fill-two-commit-command */

/* $Workfile$ e n d */