block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приведение гейтов лежащих в CLOB соответствие с текущей версией

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/08
Author: Bakhtadze Natalya
Creation date: 02/02/08

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Приведение гейтов лежащих в CLOB соответствие с текущей версией".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/gateconf.i }
{ gbl/key-rec.i }
{ nws/db-rec.i   }
define stream imp-stream.
{ utl/upgimptt.i def "new shared" }
{ trg/clbdattd.i }

define variable v-check1 as logical no-undo .

define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .

&global-define shared-option new shared

&global-define table-name clob-data
{&create-static-table}.

&global-define table-name clob-bind
{&create-static-table}.

define buffer buf_tt-clob-data for tt-clob-data.
define buffer buf_tt-clob-bind for tt-clob-bind.
define buffer buf_clob-bind for ub.clob-bind.


run waitfram-show in this-procedure ("Реинициализация конфигурации GATE").
if ( g#db-num > 0 ) then return.
if not p-forced then do:
  run check-gate-version in this-procedure (output v-check1).
end.

if v-check1
or p-forced
then do:
   if v-check1
   and p-read-only then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}).

   end.
    run gbl/md5.p (
      input  "cmp/fix-gate.txt"     /* p-file-name     */
    ,output v-md5-signature /* p-md5-signature */
    ) .

  if v-md5-signature <> "{&gate-md5}" then do:
    message
    substitute("Несовпадение файла эталонных записей по конфигурации GATE (fix-date.txt) с контрольным числом")
    view-as alert-box error .
    undo, return error .
  end.

  run gbl/filename.p ( input "cmp/fix-gate.txt"
                      ,output v-full-path
                      ,output v-path
                      ,output v-file-name
                      ,output v-file-name-no-ext
                      ,output v-file-name-ext
                      ) no-error .
  if error-status:error then do:
    message
    substitute("Не найден файл эталонных записей по конфигурации гейтов (fix-gate.txt)")
    view-as alert-box error .
    undo, return error .
  end.
  run str/diallog.w (
        input ? /*parparentproc*/
      ,input this-procedure
      ,input ('utl/upgimptt.p' + {&delim-par}  +
              '1' + {&delim-par} +
              '1' + {&delim-par} +
              '1' + {&delim-par} +
              '1')
      ,input v-full-path
      ,input yes /*p-auto-go*/
      ,input 'Прервать'
      ,input 'Чтение файла в память') no-error .
  if error-status:error then do:
    for each buf_temp-tables
    :
      if valid-handle(buf_temp-tables.tbl-handle) then do:
        delete object buf_temp-tables.tbl-handle.
      end.
    end.
    message
    substitute("Ошибка при чтении в память файла эталонных записей по гейтам (fix-gate.txt)&1&2&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
    view-as alert-box error .
    undo, return error .
  end.
  find first buf_tt-clob-bind no-lock where
            buf_tt-clob-bind.db-num = 0
        and buf_tt-clob-bind.int64-id = 0  no-error.
  if not available buf_tt-clob-bind
  or buf_tt-clob-bind.descr <> {&gate-revision} then do:
    message
    substitute("Версии шаблонов скидок в r-кодах и файле эталонных записей по гейтам (fix-gate.txt) НЕ СОВПАДАЮТ&1" +
                "в r-кодах - &2&1" +
                "в файле - &3"
                , {&new-line}
                , {&gate-revision}
                , buf_tt-clob-bind.descr
                )
    view-as alert-box error .
    undo, return error .
  end.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    run check-gates in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации гейтов:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
    find first buf_tt-clob-bind where
              buf_tt-clob-bind.db-num = 0
          and buf_tt-clob-bind.int64-id = 0.
    find first buf_clob-bind where
              buf_clob-bind.db-num = 0
          and buf_clob-bind.int64-id = 0 no-error.
    if not available buf_clob-bind then do:
      create buf_clob-bind.
    end.
    buffer-copy buf_tt-clob-bind to buf_clob-bind.
  end. /*doe*/
end. /*if v-check1*/
for each buf_temp-tables
:
  if valid-handle(buf_temp-tables.tbl-handle) then do:
    delete object buf_temp-tables.tbl-handle.
  end.
end.
run waitfram-hide in this-procedure .


procedure check-gates :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-md5-signature           as character no-undo .
define variable v-found as logical   no-undo .
define variable v-clob-db-num             as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-cmp-log as logical   no-undo .
define variable v-part-num as integer   no-undo .

define buffer buf_tt-clob-bind for tt-clob-bind.
define buffer buf_tt-clob-data for tt-clob-data.
define buffer buf_clob-data for ub.clob-data.
define buffer buf2_clob-data for ub.clob-data.



main-block:
do
on error undo, return error return-value
:

    /*сначала проверим что лежат правильные файлы*/

    for each buf_tt-clob-data
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      run gbl/filename.p (
                      input buf_tt-clob-data.file-name_
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        undo main-block, return error substitute("Не удается найти файл &1",  buf_tt-clob-data.file-name_).
      end.
      run gbl/md5.p (
                              input  v-full-path    /* p-file-name     */
                              ,output v-md5-signature /* p-md5-signature */
                              ) no-error .
      if error-status:error then do:
        undo main-block, return error substitute("&1 &2 &3&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value ).

      end.
      if v-md5-signature <> buf_tt-clob-data.crc-field then do:
        undo main-block, return error substitute("Не совпадает md5 &1 для описания в конфигурации (fix-gate.txt) и файла, лежащего в пути",  buf_tt-clob-data.file-name_).
      end.
    end. /*for each buf_tt-clob-data*/
    /*прверим сслыки - вдруг есть новые*/
    for each buf_tt-clob-bind where
            buf_tt-clob-bind.db-num = 0
        and buf_tt-clob-bind.int64-id > 0
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_clob-bind where
                buf_clob-bind.resource-type = buf_tt-clob-bind.resource-type
            and buf_clob-bind.uniq-key-rec = buf_tt-clob-bind.uniq-key-rec
            and buf_clob-bind.field-name = buf_tt-clob-bind.field-name
            and buf_clob-bind.part-num = buf_tt-clob-bind.part-num no-error.
      if not available buf_clob-bind then do:
        assign
        v-clob-db-num = ?
        v-int64-id = 0
        .
        run gbl/file2clb.p ( input {&add-def}
                            ,input "override" /*p-clob-mode*/
                            ,input ? /*p-bh*/
                            ,input buf_tt-clob-bind.uniq-key-rec
                            ,input buf_tt-clob-bind.field-name
                            ,input buf_tt-clob-bind.descr
                            ,input-output buf_tt-clob-bind.part-num
                            ,input {&lob-res-gate} /*p-resource-type*/
                            ,input-output v-clob-db-num
                            ,input-output v-int64-id
                            ,input buf_tt-clob-bind.uniq-key-rec
                            ,input ? /*p-src-encoding*/
                            ) no-error .
      if error-status :error then do:
        undo main-block, return error substitute("Ошибка при записи clob-data &1&2&3&2&4"
                                                  ,buf_tt-clob-bind.uniq-key-rec
                                                  ,{&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).
      end.
     end.
     else do:
      do transaction
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

        find first buf_tt-clob-data where
                  buf_tt-clob-data.db-num = buf_tt-clob-bind.db-num
              and buf_tt-clob-data.int64-id = buf_tt-clob-bind.int64-id.
        v-found = no.
        _cdata:
        for each buf_clob-data no-lock where buf_clob-data.file-name_ = buf_tt-clob-data.file-name_
        by buf_clob-data.db-num
        by buf_clob-data.int64-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf2_clob-data exclusive-lock where
                  rowid(buf2_clob-data) = rowid(buf_clob-data).
          if buf_tt-clob-data.crc-field <> buf2_clob-data.crc-field
          or buf_tt-clob-data.file-size <> buf2_clob-data.file-size then do:
            run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 0) no-error.
            if error-status :error then do:
              undo main-block, return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (1)(&2&3)&4&5&4&6"
                                                       ,buf_clob-data.file-name_
                                                       ,buf_clob-data.db-num
                                                       ,buf_clob-data.int64-id
                                                       ,{&new-line}
                                                       , error-status:get-message(1)
                                                       , return-value ).
            end.
            else do:
              undo _cdata,  next _cdata.
            end.
          end. /*two-commit*/
          else do:
            v-found = yes.
          end.
        end.
        if not v-found then do:
          assign
          v-clob-db-num = ?
          v-int64-id = 0
          .

          /*надо положить в БД правильный файл*/
          run gbl/file2clb.p ( input {&update}
                              ,input "add-new" /*p-clob-mode*/
                              ,input ? /*p-bh*/
                              ,input buf_tt-clob-bind.uniq-key-rec
                              ,input buf_tt-clob-bind.field-name
                              ,input buf_tt-clob-bind.descr
                              ,input-output buf_tt-clob-bind.part-num
                              ,input {&lob-res-gate} /*p-resource-type*/
                              ,input-output v-clob-db-num
                              ,input-output v-int64-id
                              ,input buf_tt-clob-bind.uniq-key-rec
                              ,input ? /*p-src-encoding*/
                              ) no-error .
          if error-status:error then do:
            undo main-block, return error return-value .
          end.
        end.
        else do:
          /*проверим описание*/
          buffer-compare buf_clob-bind
          using descr
          to buf_tt-clob-bind
          save result in v-cmp-log.
          if v-cmp-log = no then do:
            assign
            buf_clob-bind.descr = buf_tt-clob-bind.descr.
          end.
        end.
      end.  /*do transaction*/
    end. /*else */
  end. /*for each buf_tt-clob-bind where*/
  for each buf_clob-bind no-lock where
          buf_clob-bind.resource-type = {&lob-res-gate}
     and buf_clob-bind.db-num = 0
     and buf_clob-bind.int64-id > 0
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-clob-bind no-lock where
              buf_tt-clob-bind.uniq-key-rec = buf_clob-bind.uniq-key-rec
          and buf_tt-clob-bind.field-name_ = buf_clob-bind.field-name_
          and buf_tt-clob-bind.part-num = buf_clob-bind.part-num no-error.
   if not available buf_tt-clob-bind then do:
     find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.

      assign
      v-clob-db-num = ?
      v-int64-id = 0
      v-part-num = buf_clob-bind.part-num
      .
      run gbl/file2clb.p ( input {&deletion}
                          ,input "leave" /*p-clob-mode*/
                          ,input ? /*p-bh*/
                          ,input buf_clob-bind.uniq-key-rec
                          ,input buf_clob-bind.field-name
                          ,input '':U
                          ,input-output v-part-num
                          ,input {&lob-res-gate} /*p-resource-type*/
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input buf_clob-bind.uniq-key-rec
                          ,input ? /*p-src-encoding*/
                          ) no-error .
     if error-status :error then do:
       undo main-block, return error return-value .
     end.
     if available buf_clob-data then do:
        run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 0) no-error.
        if error-status :error then do:
          undo main-block, return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (&2&3)(2)&4&5&4&6"
                                                    ,buf_clob-data.file-name_
                                                    ,buf_clob-data.db-num
                                                    ,buf_clob-data.int64-id
                                                    ,{&new-line}
                                                    , error-status:get-message(1)
                                                    , return-value ).
        end.
     end.
   end.
  end.
end. /*doe*/

end procedure. /* check-gates */