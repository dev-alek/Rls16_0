/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/08
Author: Bakhtadze Natalya
Creation date: 02/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure clbdattd_two-commit-del :
define parameter buffer buf_clob-data for ub.clob-data.
define input parameter p-error-mode as integer no-undo .
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
define variable v-ext-prg-handle as handle no-undo .
define variable v-rec as recid no-undo .
define variable l-is-used as logical   no-undo init yes.
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-curr-db as integer   no-undo .
define buffer buf2_clob-data for ub.clob-data.
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db-rec-attr for ub.db-rec-attr .
main-block:
do
on error undo, return error return-value
:

  if can-find(first ub.db where ub.db.db-num > 0) then do:
    run gen-key-rec( input {&table_clob-data}
                    ,input (buffer buf_clob-data:handle )
                    ,output v-key-rec
                  ) no-error.
    if error-status :error then do:
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при генерации уникального ключа для clob-data4&5&6&5&7"
                                                ,vss-workfile
                                                ,vss-revision
                                                ,vss-description
                                                , buf_clob-data.file-name_
                                                ,{&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).
    end.
    assign
    v-param = string(buf_clob-data.db-num) + {&delim-par} +
              string(buf_clob-data.int64-id) + {&delim-par} +
              buf_clob-data.crc-field
    v-db-num = buf_clob-data.db-num
    v-int64-id = buf_clob-data.int64-id
    .
    run nws/db-rec.p (
                        input {&delete_nu-clob-data}
                        ,input v-key-rec
                        ,input v-param
                      ) no-error .
    if error-status:error then do:
      if p-error-mode = 0 then do:
        find first buf_sys-ctrl no-lock .
        assign
          v-curr-db  = buf_sys-ctrl.db-num.

        find first buf_db-rec-attr exclusive-lock
          where buf_db-rec-attr.db-num       = v-curr-db
            and buf_db-rec-attr.uniq-key-rec = v-key-rec
            and buf_db-rec-attr.attr-code    = {&delete_nu-clob-data}
          no-wait no-error.

        if available buf_db-rec-attr
          or ( not available buf_db-rec-attr
              and locked buf_db-rec-attr
            )
        then do:
          return.
        end.
      end.
      else do:
      undo, return error substitute("&1&2&3"
                                     ,error-status:get-message(1)
                                     ,{&new-line}
                                     , return-value ).
    end.
    end.
    find first buf2_clob-data no-lock where
              buf2_clob-data.db-num = buf_clob-data.db-num
          and buf2_clob-data.int64-id = buf_clob-data.int64-id no-error.
    if available buf2_clob-data
    and buf2_clob-data.crc-field > '':U
    and p-error-mode = 1
    then do:
      message return-value
      view-as alert-box .
    end.
  end. /*для системы с удаленками        */
  else do:
    run trg/clobdatt.p persistent set v-ext-prg-handle .
    find current buf_clob-data  exclusive-lock.
    assign
    v-rec = recid(buf_clob-data)
    buf_clob-data.crc-field = '':U
    .
    release buf_clob-data.
    find first buf_clob-data where
            recid(buf_clob-data) = v-rec.
    run value( "proc-is-used-clob-data" ) in v-ext-prg-handle (
                                                                buffer buf_clob-data
                                                              , input g#db-num
                                                              , output l-is-used) no-error .
    if not error-status:error
    and not l-is-used then do:
      delete buf_clob-data no-error .
    end.
    if valid-handle(v-ext-prg-handle) then do:
      delete procedure v-ext-prg-handle  .
    end.
    find first buf2_clob-data no-lock where
              buf2_clob-data.db-num = buf_clob-data.db-num
          and buf2_clob-data.int64-id = buf_clob-data.int64-id no-error.
    if available buf2_clob-data
    and buf2_clob-data.crc-field > '':U
    and p-error-mode = 1
    then do:
      message return-value
      view-as alert-box .
    end.
    else do:
      error-status:error = no.
    end.

  end.
  if error-status :error then do:
    undo, return error substitute("Ошибка при запуске удаления clob-data &1&2&3&4&3&5"
                                  ,v-db-num
                                  ,v-int64-id
                                  ,{&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
  end.
end.
end procedure. /* clbdattd_two-commit-del */

/* $Workfile$ e n d */