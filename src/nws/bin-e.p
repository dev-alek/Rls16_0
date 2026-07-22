block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bin-e.p $
$Archive: nws/bin-e.p $

Отсылка бинарного файла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/06
Author: Bakhtadze Natalya
Creation date: 07/28/06

*/

define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .
define input parameter p-full-path-name as character no-undo .
define input parameter p-path-type as integer no-undo .
define input parameter p-path as character no-undo .
define input parameter p-mode as character no-undo .

/*
p-mode может быть
save-package save-db save-disk save-db-and-run save-disk-and-run save-this-db
save-this-db  сохранить файл в текущей БД
save-package передать файла вместе с шапкой и установить в директорию  - шапка остается в БД строки удаляем
save-dv передать файла вместе с шапкой  и оставить храниться в БД
save-disk - использовать для временных утилит и т.д.
save-db-and-run передать файла вместе с шапкой запустить и оставить храниться в БД
save-disk-and-run - использовать для временных утилит и т.д. и запустить
*/

define input parameter p-md5-signature as character no-undo .
define parameter buffer buf_ext-file for ub.ext-file.
/*save-db install save-disk save-db-and-run save-disk-and-run */
DEFINE TEMP-TABLE tt-ext-file-par NO-UNDO LIKE ub.ext-file-par.
define input parameter table for tt-ext-file-par.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bin-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/bin-e.p $":U .
define variable vss-description as character no-undo init "Передача бинарного файла по СПН".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
define stream sinp .
{ gbl/binfile.i  &stream-name=sinp }

define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-md5-signature as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-rec-ord                 as integer                  no-undo .


define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_tt-ext-file-par for tt-ext-file-par.
define buffer buf_ext-file-par for ub.ext-file-par.
define buffer buf_ext-file-line for ub.ext-file-line.


/*считаем файл во временную таблицу или в БД*/
main-block:
do
on error undo, return error return-value
:

  run gbl/filename.p (
                  input p-full-path-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при определении имени файла &5&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,p-full-path-name
                                        ,error-status:get-message(1)
                                        ,return-value ).

  end.


  if p-mode = {&save-this-db} then do:
    run binfile_read-to-db in this-procedure (
      input  p-db-num
      ,input p-from-db-num
      ,input  p-file-num
      ,input  p-full-path-name
      ) .
    if buf_ext-file.file-type begins ({&table_cash-desk} + {&delim-key})
    then do:
      for each buf_tt-ext-file-par no-lock:
          find first buf_ext-file-par where
                    buf_ext-file-par.db-num = 0
                and buf_ext-file-par.from-db-num = 0
                and buf_ext-file-par.file-num = 0
                and buf_ext-file-par.param-num = buf_tt-ext-file-par.param-num  no-error.
          if not available buf_ext-file-par then do:
            create buf_ext-file-par.
          end.
          buffer-copy buf_tt-ext-file-par except db-num from-db-num file-num
          to buf_ext-file-par
          assign
          buf_ext-file-par.from-db-num = p-from-db-num
          buf_ext-file-par.db-num = p-db-num
          buf_ext-file-par.file-num = buf_Ext-file.file-num
          buf_ext-file-par.user-db-num = p-from-db-num
          .
      end.
    end.
    return.
  end.
  else do:
    if p-md5-signature = '':U then do:

      run gbl/md5.p (
        input  p-full-path-name
        ,output p-md5-signature /* p-md5-signature */
        ) .
    end.
    run binfile_read in this-procedure (
       input  p-db-num
      ,input  p-from-db-num
      ,input  p-file-num
      ,input  p-full-path-name
      ) .
  end.
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
                                                input  ({&cmd-send-binary} + {&delim-cmd}
                                                      + p-mode  + {&delim-cmd}
                                                      + string(p-file-num) + {&delim-cmd}
                                                      + v-file-name + {&delim-cmd}
                                                      + string(p-path-type) + {&delim-cmd}
                                                      + p-path + {&delim-cmd}
                                                      + p-md5-signature  )
                                                      /* p-command-name */
                                                ,INPUT  string(if p-db-num > 0 then p-db-num else 0)
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
  run add-dump in v-cmd-proc-handle
    (input v-cmd-code
    ,input {&table_ext-file}
    ,input '+update'
    ,input (buffer buf_ext-file:handle)
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
                                        ,{&table_ext-file}
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value

                                        ).                                                       ~
  end.

  /*набъем в новости */
  for each buf_temp-ext-file-line no-lock:
      find first buf_ext-file-line where
                buf_ext-file-line.db-num = p-db-num
            and buf_ext-file-line.from-db-num = p-from-db-num
            and buf_ext-file-line.file-num = p-file-num
            and buf_ext-file-line.line-num = buf_temp-ext-file-line.line-num
            and buf_ext-file-line.sub-line-num = buf_temp-ext-file-line.sub-line-num
            no-error.
      if not available buf_ext-file-line then do:
        create buf_ext-file-line.
      end.
      buffer-copy buf_temp-ext-file-line except db-num from-db-num file-num
      to buf_ext-file-line
      assign
      buf_ext-file-line.from-db-num = p-from-db-num
      buf_ext-file-line.db-num = p-db-num
      buf_ext-file-line.file-num = p-file-num
      .

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
                                          ,{&table_ext-file-line}
                                          ,v-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value

                                          ).                                                       ~
    end.
  end.
  if p-mode = {&save-disk-and-run}
  or p-mode = {&save-db-and-run}
  or buf_ext-file.file-type begins ({&table_cash-desk} + {&delim-key})
  then do:
  for each buf_tt-ext-file-par no-lock:
      find first buf_ext-file-par where
                buf_ext-file-par.db-num = 0
            and buf_ext-file-par.from-db-num = 0
            and buf_ext-file-par.file-num = 0
            and buf_ext-file-par.param-num = buf_tt-ext-file-par.param-num  no-error.
      if not available buf_ext-file-par then do:
        create buf_ext-file-par.
      end.
      buffer-copy buf_tt-ext-file-par except db-num from-db-num file-num
      to buf_ext-file-par
      assign
      buf_ext-file-par.from-db-num = p-from-db-num
      buf_ext-file-par.db-num = p-db-num
      buf_ext-file-par.file-num = buf_Ext-file.file-num
      buf_ext-file-par.user-db-num = p-from-db-num
      .
      run add-dump in v-cmd-proc-handle
        (input v-cmd-code
        ,input {&table_ext-file-par}
        ,input '+update'
        ,input (buffer buf_ext-file-par:handle)
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
                                            ,{&table_ext-file-par}
                                            ,v-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value

                                            ).                                                       ~
      end.
    end.

  end.
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code  /* p-command-code */
      ,input string(if p-db-num > 0 then p-db-num else 0)
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
                                        ,p-db-num
                                        ).
  end.
  delete procedure v-cmd-proc-handle .
end. /*doe*/