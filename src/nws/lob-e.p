block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lob-e.p $
$Archive: nws/lob-e.p $

Отсылка CLOB-DATA или BLOB-DATA по СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/08
Author: Bakhtadze Natalya
Creation date: 01/06/08


*/

define input parameter p-lob-bh as handle no-undo .
define input  parameter p-db-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lob-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/lob-e.p $":U .
define variable vss-description as character no-undo init "Отсылка CLOB-DATA или BLOB-DATA по СПН".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ nws/lobfile.i  }

define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-rec-ord as integer   no-undo .
define variable v-ii as integer   no-undo .
define buffer buf_db for ub.db.

define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-ext-file-line for temp-ext-file-line.



main-block:
do
on error undo, return error return-value
:


  if p-lob-bh:available = no then do:
     message
     vss-workfile vss-revision vss-description skip
     "Передан буфер без записи"
     view-as alert-box error .
     undo main-block, return error .
  end.
  if not (p-lob-bh:table = {&table_clob-data}
          or
          p-lob-bh:table = {&table_blob-data}) then do:
     message
     vss-workfile vss-revision vss-description skip
     substitute("Работает только для &1 или &2", {&table_clob-data}, {&table_blob-data})
     view-as alert-box error .
     undo main-block, return error .
  end.
  if p-db-list = '':U then do:
    if g#db-num > 0 then do:
       assign
       p-db-list = string(0).
    end.
    else do:
      for each buf_db where buf_db.db-num > 0 no-lock
      on error  undo,  return  error :
        assign p-db-list = p-db-list + {&delim-nws} + string(buf_db.db-num).
      end.
      assign
      p-db-list = trim(p-db-list, {&delim-nws})
      .
    end.
  end.
  run lob_read in this-procedure (
     input  p-lob-bh
    ) .

  if not valid-handle(v-cmd-proc-handle ) then dO:
    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.


  run begin-create-command in v-cmd-proc-handle (
                                                input  ({&cmd-send-lob}  + {&delim-cmd}
                                                      + p-lob-bh:table + {&delim-cmd}
                                                      + string(p-lob-bh::db-num) + {&delim-cmd}
                                                      + string(p-lob-bh::int64-id) )
                                                      /* p-command-name */
                                                ,INPUT  p-db-list
                                                ,output v-cmd-code                 /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,{&cmd-send-binary}
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  create buf_temp-nws-outline.
  assign
  buf_temp-nws-outline.outline-type = p-lob-bh:table
  buf_temp-nws-outline.no-id = 0
  .
  do v-ii = 1 to p-lob-bh:num-fields:
    if not (p-lob-bh:buffer-field(v-ii):data-type = {&abl-datatype-clob}
            or
            p-lob-bh:buffer-field(v-ii):data-type = {&abl-datatype-blob}) then do:
      assign
      buf_temp-nws-outline.charkey_one = buf_temp-nws-outline.charkey_one +
                                         (if v-ii = 1 then '':U else {&delim-key}) +
                                         string((if p-lob-bh:buffer-field(v-ii):buffer-value = ? then {&question-mark} else p-lob-bh:buffer-field(v-ii):buffer-value)).
    end.
  end.
  run add-dump in v-cmd-proc-handle
    (input v-cmd-code
    ,input {&table_nws-outline}
    ,input '+update'
    ,input buffer buf_temp-nws-outline:handle
    ,input '':U
    ,output v-rec-ord
    ) no-error .
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3Ошибка при добавлении записи &4 в команду с кодом &5 &6&3" +
                                        "&7&3БД"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,{&new-line}
                                        ,p-lob-bh:table
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value

                                        ).                                                       ~
  end.

  /*набъем в новости */
  for each buf_temp-ext-file-line
  by buf_temp-ext-file-line.db-num
  by buf_temp-ext-file-line.file-num
  by buf_temp-ext-file-line.from-db-num
  by buf_temp-ext-file-line.line-num:
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code
      ,input {&table_ext-file-line}
      ,input '+update'
      ,input (buffer buf_temp-ext-file-line:handle)
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3Ошибка при добавлении записи &4 в команду с кодом &5 &6&3" +
                                          "&7&3БД"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,{&new-line}
                                          ,p-lob-bh:table
                                          ,v-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value

                                          ).                                                       ~
    end.
  end.
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code  /* p-command-code */
      ,input p-db-list
      ) no-error .

  if error-status :error then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при отправке в новости команды с кодом &5 БД &8&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        ,p-lob-bh::db-num
                                        ).
  end.
  delete procedure v-cmd-proc-handle .
end. /*doe*/