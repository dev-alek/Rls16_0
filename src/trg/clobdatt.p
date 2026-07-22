block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для распределенной обработки clob-data с resource-type = gate

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/08
Author: Bakhtadze Natalya
Creation date: 02/03/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки clob-data с resource-type = gate".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }



&scop btpr-act-blocked-for-delete 'blocked-for-delete':U



procedure block-del-clob-data :
/*блокирование clob-dataа для последующего удаления*/
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error return-value
  :

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-crc-field as character no-undo .
    define variable v-return-value as character no-undo .

    define buffer buf_clob-data for ub.clob-data.


    run gen-row-keyr in this-procedure
      ( input  pc-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. &3 &4", vss-workfile, pc-uniq-key-rec, {&new-line}, return-value ).
    end.

    if v-tbl-name <> {&table_clob-data} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей clob-data", vss-workfile ).
    end.

    find first buf_clob-data
      where rowid( buf_clob-data ) = v-rowid
      no-error .

    if not available buf_clob-data then do:
      l-is-used = no.
      return ''.
    end.

    if buf_clob-data.crc-field = '':U then do:
      assign
      pc-err-msg = substitute( "clob-data &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :

      /*взводим статус*/
      assign
      v-old-crc-field = buf_clob-data.crc-field
      buf_clob-data.crc-field = '':U
      .
      /*проверяем на использование*/
      run proc-is-used-clob-data in this-procedure ( buffer buf_clob-data
                                                 , input pc-db-num
                                                 , output l-is-used) no-error .
      v-return-value = return-value.
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование clob-data &2:&3&4"
                                      , vss-workfile
                                      , buf_clob-data.file-name_
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_clob-data.crc-field  = v-old-crc-field
        pc-err-msg = substitute( "&1. CLOB-DATA &2 используется:&3&4"
                                 , vss-workfile
                                 , buf_clob-data.file-name_
                                 , {&new-line}
                                 , v-return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-clob-data */


procedure delete-clob-data :
/*удаление неиcпользуемой CLOB_DATA*/
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .


  do
  on error undo, return error return-value
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-file-name_           like ub.clob-data.file-name_ no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-crc-field      as character no-undo .
    define variable v-return-value     as character no-undo .
    define variable v-db-num as integer   no-undo .
    define variable v-int64-id as int64 no-undo .

    define buffer buf_clob-data         for ub.clob-data .

    run gen-row-keyr in this-procedure
      ( input  pe-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pe-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_clob-data} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей CLOB-DATA", vss-workfile ).
    end.
    assign
    v-db-num = integer(entry(1, pe-parameters, {&delim-par}))
    v-int64-id = int64(entry(2, pe-parameters, {&delim-par}))
    v-old-crc-field = entry(3, pe-parameters, {&delim-par})
    .
    find first buf_clob-data exclusive-lock where
              buf_clob-data.db-num = v-db-num
          and buf_clob-data.int64-id = v-int64-id   no-wait no-error.

    if not available buf_clob-data
    and not locked(buf_clob-data) then do:
      find first buf_clob-data no-lock where
              buf_clob-data.db-num = v-db-num
          and buf_clob-data.int64-id = v-int64-id  no-error.
      if not available buf_clob-data then return '':U.
    end.

    if not available buf_clob-data then do:
      return error substitute( "&1. Не найден или занят CLOB-DATA &2", vss-workfile, v-file-name_ ).
    end.

    /*проверим что clob-data заблокирован*/
    if buf_clob-data.crc-field <> '':U then do:
      return error substitute( "&1. CLOB-DATA &2 не заблокирована для удаления", vss-workfile, buf_clob-data.file-name_ ).
    end.
    /*проверяем на использование*/
    run proc-is-used-clob-data in this-procedure ( buffer buf_clob-data, input pe-db-num, output l-is-used) no-error .
    v-return-value = return-value .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование CLOB-DATA &2:&3&4"
                                     , vss-workfile
                                     , buf_clob-data.file-name_
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. CLOB-DATA &2 используется &3&4"
                                    , vss-workfile
                                    , buf_clob-data.file-name_
                                    , {&new-line}
                                    , v-return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      delete buf_clob-data.
    end.
  end.
end procedure. /* delete-clob-data */


procedure undo-delete-clob-data :
/*откат блокировки CLOB-DATA*/
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-file-name_           like ub.clob-data.file-name_ no-undo .
    define variable v-new              as logical no-undo .
    define variable v-old-crc-field      as character no-undo .
    define variable v-db-num as integer   no-undo .
    define variable v-int64-id as int64 no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_clob-data       for ub.clob-data    .

    run gen-row-keyr in this-procedure
      ( input  pr-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pr-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_clob-data} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей CLOB-DATA", vss-workfile ).
    end.
    assign
    v-db-num = integer(entry(1, pr-parameters, {&delim-par}))
    v-int64-id = int64(entry(2, pr-parameters, {&delim-par}))
    v-old-crc-field = entry(3, pr-parameters, {&delim-par})
    .

    find first buf_clob-data exclusive-lock where
               rowid(buf_clob-data) = v-rowid no-error  .
    if not available buf_clob-data then do:
      find first buf_clob-data exclusive-lock where
                 buf_clob-data.db-num = v-db-num
             and buf_clob-data.int64-id = v-int64-id  no-error no-wait.
      if not available buf_clob-data
      AND not LOCKED(buf_clob-data)
      then do:
        find first buf_clob-data no-lock where
                 buf_clob-data.db-num = v-db-num
             and buf_clob-data.int64-id = v-int64-id  no-error.
        if not available buf_clob-data then do:
           return error substitute( "&1. Не найдена или занята CLOB-DATA &2", vss-workfile, v-file-name_ ).
        end.
      end.
    end.


    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :

      if buf_clob-data.crc-field = '':U then do:
        assign
        buf_clob-data.crc-field = v-old-crc-field
        .
        release buf_clob-data.
      end.
    end.
  end.

end procedure. /* undo-delete-clob-data */


procedure proc-is-used-clob-data :
define parameter buffer buf_clob-data for ub.clob-data.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/
define variable v-key-rec as character no-undo .
define buffer buf_route for ub.route.
define buffer buf_route-dump for ub.route-dump.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.


  do
  on error undo, return error return-value
  :

    run gen-key-rec in this-procedure ( input {&table_clob-data}
                                       ,input buffer buf_clob-data:handle
                                       ,output v-key-rec).
    for each buf_esys-route no-lock where
            buf_esys-route.uniq-gate-rec = v-key-rec :
      return substitute("&1 используется для маршрутизации во внешнюю систему&2Удаление невозможно"
                  ,v-key-rec
                  ,{&new-line}).
    end.
    for each buf_esys-route-dump no-lock where
            buf_esys-route-dump.uniq-gate-rec = v-key-rec :
      return
      substitute("&1 используется для маршрутизации во внешнюю систему&2Удаление невозможно"
                  ,v-key-rec
                  ,{&new-line}).
    end.
    for each buf_route no-lock where
            buf_route.uniq-gate-rec = v-key-rec :
      return
      substitute("&1 используется для маршрутизации СПН&2Удаление невозможно"
                  ,v-key-rec
                  ,{&new-line}).
    end.
    for each buf_route-dump no-lock where
            buf_route-dump.uniq-gate-rec = v-key-rec :
      return
      substitute("&1 используется для маршрутизации СПН&2Удаление невозможно"
                  ,v-key-rec
                  ,{&new-line}).
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-used-clob-data */
