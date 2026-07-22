block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с записями code-range

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "библиотека для работы с записями code-range".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/tbl-name.i }
{ gbl/key-rec.i  }
define temp-table temp-clients no-undo like ub.clients.

procedure comm-crush-cdrg :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_code-range  for ub.code-range .

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
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
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_code-range.range-type = entry( 1, pc-parameters, {&delim-par} )
       and buf_code-range.first-code = integer( entry( 2, pc-parameters, {&delim-par} ) )
       and buf_code-range.last-code = integer( entry( 3, pc-parameters, {&delim-par} ) )
    then do:
      if buf_code-range.stts = "u":U then do:
        assign
          buf_code-range.PS   = buf_code-range.stts + {&delim-par} + "Диапазон заблокирован" + {&delim-par} + buf_code-range.PS
          buf_code-range.stts = "c":U
        .
      end.
      else do:
        if buf_code-range.stts = "c":U
          and num-entries( buf_code-range.PS, {&delim-par} ) >= 3
        then do:
          assign
            pc-err-msg = substitute( "Диапазон &1 уже заблокирован!!! Блокировка невозможна!!!", pc-uniq-key-rec )
          .
        end.
        else do:
          assign
            pc-err-msg = substitute( "Диапазон &1 имеет статус &2. Блокировка невозможна!!!", pc-uniq-key-rec, buf_code-range.stts )
          .
        end.
      end.
    end.
    else do:
      return error substitute( "&1. Обнаружено фатальное отличие диапазонов", vss-workfile )
                   + {&new-line}
                   + substitute( "Должно быть: тип &1 начало &2 конец &3", entry( 1, pc-parameters, {&delim-par} )
                                                                         , entry( 2, pc-parameters, {&delim-par} )
                                                                         , entry( 3, pc-parameters, {&delim-par} ) )
                   + {&new-line}
                   + substitute( "В текущей БД: тип &1 начало &2 конец &3", buf_code-range.range-type
                                                                          , buf_code-range.first-code
                                                                          , buf_code-range.last-code )
      .
    end.

  end.
  return.
end procedure. /* comm-crush-cdrg */

procedure exec-crush-cdrg :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-new_code-range for ub.code-range .

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-new-range-length as integer   no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-old-first-code   as integer   no-undo .
    define variable v-old-last-code    as integer   no-undo .
    define variable v-new-first-code   as integer   no-undo .
    define variable v-new-last-code    as integer   no-undo .


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
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pe-uniq-key-rec ).
    end.

    if buf_code-range.stts <> "c":U then do:
      return error substitute( "&1. Диапазон кодов &2 не заблокирован", vss-workfile, pe-uniq-key-rec ).
    end.

    assign
      v-range-type             = entry( 1, pe-parameters, {&delim-par} )
      v-old-first-code         = integer( entry( 2, pe-parameters, {&delim-par} ) )
      v-old-last-code          = integer( entry( 3, pe-parameters, {&delim-par} ) )
      v-new-range-length       = integer( entry( 4, pe-parameters, {&delim-par} ) )
      buf_code-range.last-code = buf_code-range.first-code - 1 + v-new-range-length
      v-new-first-code         = buf_code-range.last-code + 1
      v-new-last-code          = v-new-first-code - 1 + v-new-range-length
    .
    do while v-new-first-code < v-old-last-code
    on error undo, return error
    :
      if v-new-last-code > v-old-last-code then do:
        assign
          v-new-last-code = v-old-last-code
        .
      end.
      create buf-new_code-range .
      buffer-copy buf_code-range to buf-new_code-range
        assign
          buf-new_code-range.stts       = "c":U
          buf-new_code-range.first-code = v-new-first-code
          buf-new_code-range.last-code  = v-new-last-code
      .
      assign
        v-new-first-code = buf-new_code-range.last-code + 1
        v-new-last-code  = v-new-first-code - 1 + v-new-range-length
      .
    end.
    /* возвращаем статус в исходное состояние */
    for each buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.first-code >= v-old-first-code
        and buf_code-range.first-code <  v-old-last-code
    on error undo, return error
    :
      assign
        buf_code-range.stts = entry( 1, buf_code-range.PS, {&delim-par} )
        buf_code-range.PS   = "Диапазон получен разбиением"
      .
    end.
  end.
  return.
end procedure. /* exec-crush-cdrg */

procedure rcvr-crush-cdrg :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-del_code-range for ub.code-range .

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-old-first-code   as integer   no-undo .
    define variable v-old-last-code    as integer   no-undo .
    define variable v-update-cdrg      as logical   no-undo .

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
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pr-uniq-key-rec ).
    end.

    assign
      v-range-type             = entry( 1, pr-parameters, {&delim-par} )
      v-old-first-code         = integer( entry( 2, pr-parameters, {&delim-par} ) )
      v-old-last-code          = integer( entry( 3, pr-parameters, {&delim-par} ) )
    .

    assign
      v-update-cdrg = false
    .

    if buf_code-range.stts = "c":U then do:
      assign
        v-update-cdrg = true
      .
    end.
    else do:
      if buf_code-range.last-code <> v-old-last-code then do:
        /* возвращаем code-range в исходное состояние */
        for each buf-del_code-range
          where buf-del_code-range.range-type = v-range-type
            and buf-del_code-range.first-code > v-old-first-code
            and buf-del_code-range.first-code < v-old-last-code
        on error undo, return error
        :
          assign
            buf-del_code-range.stts = "c":U
          .
          delete buf-del_code-range .
        end.
        assign
          buf_code-range.PS        = buf_code-range.stts + {&delim-par} + {&delim-par} + buf_code-range.PS
          buf_code-range.stts      = "c":U
          buf_code-range.last-code = v-old-last-code
          v-update-cdrg            = true
        .
      end.
    end.
    if v-update-cdrg = true then do:
      assign
        buf_code-range.stts = entry( 1, buf_code-range.PS, {&delim-par} )
        buf_code-range.PS   = entry( 3, buf_code-range.PS, {&delim-par} )
      .
    end.

  end.
  return.
end procedure. /* rcvr-crush-cdrg */


procedure comm-del-cdrg :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr for ub.db-rec-attr .
    define buffer buf_code-range  for ub.code-range .

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-old-stts as character no-undo .
    define variable v-old-ps as character no-undo .
    define variable l-has-prevention as logical no-undo .


    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num       = pc-db-num
        and buf_db-rec-attr.uniq-key-rec = pc-uniq-key-rec
        and buf_db-rec-attr.attr-code    = pc-attr-code
    no-error.

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
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pc-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_code-range.range-type = entry( 1, pc-parameters, {&delim-par} )
       and buf_code-range.first-code = integer( entry( 2, pc-parameters, {&delim-par} ) )
       and buf_code-range.last-code = integer( entry( 3, pc-parameters, {&delim-par} ) )
    then do:
      if ( buf_code-range.stts = "u":U
          or buf_code-range.stts = "f":U
          or buf_code-range.stts = "a":U
        )
      then do:
        assign
        v-old-stts = buf_code-range.stts
          buf_code-range.stts = "c":U
        .
        /*проверяем на использование*/
        l-has-prevention = yes.
        run proc-has-prevention in this-procedure ( buffer buf_code-range, output l-has-prevention) no-error.
        if error-status:error then do:
          undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                        , vss-workfile
                                        , buf_code-range.range-type
                                        , buf_code-range.db-num
                                        , buf_code-range.first-code
                                        , buf_code-range.last-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        if l-has-prevention then do:
          assign
          buf_code-range.stts = v-old-stts
          buf_code-range.ps = v-old-ps
          pc-err-msg = substitute( "&1. Есть препятствия удалению диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                  , vss-workfile
                                  , buf_code-range.range-type
                                  , buf_code-range.db-num
                                  , buf_code-range.first-code
                                  , buf_code-range.last-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
          return pc-err-msg.
      end.
      end.  /*buf_code-range.stts = "u":U*/
      else do:
        assign
          pc-err-msg = substitute( "Блокировка записи &1 невозможна!!!", pc-uniq-key-rec )
        .
      end.
    end.
    else do:
      return error substitute( "&1. Обнаружено фатальное отличие диапазонов", vss-workfile )
                   + {&new-line}
                   + substitute( "Должно быть: тип &1 начало &2 конец &3", entry( 1, pc-parameters, {&delim-par} )
                                                                         , entry( 2, pc-parameters, {&delim-par} )
                                                                         , entry( 3, pc-parameters, {&delim-par} ) )
                   + {&new-line}
                   + substitute( "В текущей БД: тип &1 начало &2 конец &3", buf_code-range.range-type
                                                                          , buf_code-range.first-code
                                                                          , buf_code-range.last-code )
      .
    end.

  end.
  return.
end procedure. /* comm-del-cdrg */

procedure exec-del-cdrg :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-new_code-range for ub.code-range .

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-new-range-length as integer   no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-stts         as character no-undo .
    define variable v-db-num as integer no-undo .
    define variable v-ps as character no-undo .
    define variable v-first-code   as integer   no-undo .
    define variable v-last-code    as integer   no-undo .
    define variable l-has-prevention as logical no-undo .


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
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pe-uniq-key-rec ).
    end.

    if buf_code-range.stts <> "c":U then do:
      return error substitute( "&1. Диапазон кодов &2 не заблокирован", vss-workfile, pe-uniq-key-rec ).
    end.

    assign
    v-range-type         = entry( 1, pe-parameters, {&delim-par} )
    v-first-code         = integer( entry( 2, pe-parameters, {&delim-par} ) )
    v-last-code          = integer( entry( 3, pe-parameters, {&delim-par} ) )
    v-stts               = entry( 4, pe-parameters, {&delim-par} )
    v-db-num             = integer( entry( 5, pe-parameters, {&delim-par} ) )
    v-ps                 = entry( 6, pe-parameters, {&delim-par} )
    .
    /*проверяем на использование*/
    l-has-prevention = yes.
    run proc-has-prevention in this-procedure ( buffer buf_code-range, output l-has-prevention) no-error.
    if error-status:error then do:
      undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    if l-has-prevention then do:
      assign
      buf_code-range.stts = v-stts
      pe-err-msg = substitute( "&1. Есть препятствия удалению диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                              , buf_code-range.range-type
                              , buf_code-range.db-num
                              , buf_code-range.first-code
                              , buf_code-range.last-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ).
      undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    on delete of ub.code-range override do: end.
    delete buf_code-range no-error.
    if error-status:error then do:
      undo, return error substitute( "&1. Ошибка при удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    on delete of ub.code-range revert.
  end.
  return.
end procedure. /* exec-del-cdrg */


procedure rcvr-del-cdrg :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-del_code-range for ub.code-range .

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-first-code   as integer   no-undo .
    define variable v-last-code    as integer   no-undo .
    define variable v-db-num as integer no-undo .
    define variable v-stts as character no-undo .
    define variable v-ps as character no-undo .
    define variable v-update-cdrg      as logical   no-undo .

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
    if v-tbl-name <> {&table_code-range} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.

    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .

    assign
    v-range-type        = entry( 1, pr-parameters, {&delim-par} )
    v-first-code        = integer( entry( 2, pr-parameters, {&delim-par} ) )
    v-last-code         = integer( entry( 3, pr-parameters, {&delim-par} ) )
    v-stts              =  entry( 4, pr-parameters, {&delim-par} )
    v-db-num            = integer(entry( 5, pr-parameters, {&delim-par} ))
    v-ps                = entry( 6, pr-parameters, {&delim-par} )
    .
    if not available buf_code-range then do:
      find first buf_code-range exclusive-lock where
                 buf_code-range.range-type = v-range-type
             and buf_code-range.first-code = v-first-code     no-error no-wait.

      if not available buf_code-range
      AND not LOCKED(buf_code-range)
      then do:
        find first buf_code-range no-lock where
                 buf_code-range.range-type = v-range-type
            and  buf_code-range.first-code = v-first-code  no-error.
        if not available buf_code-range then do:
          create buf_code-range.
          assign
          buf_code-range.range-type = v-range-type
          buf_code-range.db-num = v-db-num
          buf_code-range.first-code = v-first-code
          buf_code-range.last-code = v-last-code
          buf_code-range.ps = v-ps
          .
          release buf_code-range no-error.
          if error-status:error then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
          end.
          return .
        end.
        else do:
           /*првоерим что диапазон не изменился*/
          if buf_code-range.db-num <> v-db-num
          or buf_code-range.last-code <> v-last-code then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6" +
                                           "Восстанавливаемый диапазон отличается от исходного (БД = &7 верхняя граница 8)"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , {&new-line}
                                          , v-db-num
                                          , v-last-code
                                          ).
          end.
        end.
      end. /*if not available buf_code-range*/
    end. /*if not available buf_code-range then do:*/
    else do:
        /*првоерим что диапазон не изменился*/
      if buf_code-range.db-num <> v-db-num
      or buf_code-range.last-code <> v-last-code then do:
        undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6" +
                                        "Имеющийся восстанавливаемый диапазон отличается от исходного (БД = &7 верхняя граница 8)"
                                      , vss-workfile
                                      , v-range-type
                                      , v-db-num
                                      , v-first-code
                                      , v-last-code
                                      , {&new-line}
                                      , v-db-num
                                      , v-last-code
                                      ).
      end.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_code-range.stts <> v-stts then do:
        assign
        buf_code-range.stts = v-stts
        .
        release buf_code-range no-error.
        if error-status:error then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
        end.
      end.
    end.
  end.
  return.
end procedure. /* rcvr-del-cdrg */


procedure proc-has-prevention :
define parameter buffer buf_code-range for ub.code-range.
define output parameter p-has-prevention as logical no-undo init yes.

define buffer buf_clients for ub.clients.
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-global as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl.
define buffer buf_prod-bc for ub.prod-bc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not available buf_code-range then do:
    undo, return error substitute("Не определен диапазон").
  end.
  find first buf_sys-ctrl.
  case buf_code-range.range-type:
    when {&loc-sc-code}
    or when {&loc-pg-code}
    or when {&gbl-sc-code}
    then do:
      empty temp-table temp-clients.
      for each buf_clients no-lock where
              buf_clients.db-num = buf_sys-ctrl.db-num
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        create temp-clients.
        buffer-copy buf_clients to temp-clients.
        release temp-clients.
      end.
      for each buf_prod-bc no-lock where
              buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
          and buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
          and length(buf_prod-bc.b-str) = 5
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        assign
        l-prod-bc-global = ?
        l-prod-bc-weight = ?
        l-prod-bc-pgweight = ?
        .
       /*проверим*/
        { gbl/prodbcat.i
          buf_prod-bc
          "'global=request':u"
          l-prod-bc-global
          no-error
        }
        if buf_code-range.range-type = {&gbl-sc-code}
        or buf_code-range.range-type = {&loc-sc-code} then do:
          { gbl/prodbcat.i
            buf_prod-bc
            "'weight=request':u"
            l-prod-bc-weight
            no-error
          }
        end.
        if buf_code-range.range-type = {&loc-pg-code} then do:
          { gbl/prodbcat.i
            buf_prod-bc
            "'pgweight=request':u"
            l-prod-bc-weight
            no-error
          }
        end.
        case buf_code-range.range-type:
          when {&loc-sc-code} then do:
            if l-prod-bc-weight = yes
            and l-prod-bc-global = no then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
          when {&loc-pg-code} then do:
            if l-prod-bc-pgweight = yes
            and l-prod-bc-global = no then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
          when {&gbl-sc-code} then do:
            if l-prod-bc-weight = yes
            and l-prod-bc-global = yes then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
        end case.
      end. /*      for each buf_prod-bc no-lock where*/
      p-has-prevention = no.
    end. /*when {&loc-sc-code}*/
    otherwise do:
      return.
    end.
  end case.
end.

end procedure. /* proc-has-prevention */


/* $Workfile$ end */