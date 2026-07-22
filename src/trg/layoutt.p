block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
                                                                             o
Библиотека процедур для распределенной обработки  layoutt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/27/08
Author: Bakhtadze Natalya
Creation date: 10/27/08

*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки layoutt".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ gbl/get-regf.i }
{ adm/layoutus.i }

&scop btpr-act-blocked-for-delete 'blocked-for-delete':U


procedure block-del-layout :
/*блокирование layout для последующего удаления*/
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
    define variable old-sts as integer no-undo .

    define buffer buf_layout for ub.layout.

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

    if v-tbl-name <> {&table_layout} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей РАСКЛАДОК", vss-workfile ).
    end.

    find first buf_layout
      where rowid( buf_layout ) = v-rowid
      no-error .

    if not available buf_layout then do:
      assign
      pc-err-msg = substitute( "Нет необходимой РАСКЛАДКИ &2", pc-uniq-key-rec ).
      .
      return .
    end.


    if buf_layout.sts = integer({&to-delete-status-int}) then do:
      assign
      pc-err-msg = substitute( "РАСКЛАДКА &1 уже заблокирована или удалена!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      /*взводим статус*/
      assign
      old-sts = buf_layout.sts
      buf_layout.sts = integer({&to-delete-status-int})
      .
      /*проверяем на использование*/
      run proc-is-used-layout in this-procedure (buffer buf_layout, input pc-db-num, output l-is-used) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование РАСКЛАДКИ &2:&3&4"
                                      , vss-workfile
                                      , buf_layout.layout-id
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_layout.sts = old-sts
        pc-err-msg = substitute( "&1. РАСКЛАДКА &2 используется:&3&4"
                                 , vss-workfile
                                 , buf_layout.layout-id
                                 , {&new-line}
                                 , return-value
                                  )
        .
        release buf_layout.
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-layout */


procedure delete-layout :
/*удаление неиcпользуемого правила скидок*/
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
    define variable v-layout-id like ub.layout.layout-id no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-sts          as integer no-undo .

    define buffer buf_layout         for ub.layout .
    define buffer buf_layout2         for ub.layout .
    define buffer buf_c-layout        for ub.c-layout.


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
    if v-tbl-name <> {&table_layout} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей РАСКЛАДОК", vss-workfile ).
    end.
    assign
    v-layout-id = entry(1, pe-parameters, {&delim-par})
    v-old-sts  = integer(entry(2, pe-parameters, {&delim-par}))
    .
    find first buf_layout exclusive-lock where
              buf_layout.layout-id = v-layout-id no-wait no-error.

    if not available buf_layout
    and not locked(buf_layout) then do:
      find first buf_layout no-lock where
            buf_layout.layout-id = v-layout-id no-error.
      if not available buf_layout then return.
    end.

    if not available buf_layout then do:
      return error substitute( "&1. Не найдена или занята РАСКЛАДКА &2"
                            , vss-workfile
                            , v-layout-id
                            ).
    end.

    /*проверим что layout заблокировано*/
    if buf_layout.sts <> integer({&to-delete-status-int}) then do:
      return error substitute( "&1. РАСКЛАДКА &2 не заблокирована для удаления"
                             , vss-workfile
                             , buf_layout.layout-id
                             ).
    end.
    /*проверяем на использование*/
    run proc-is-used-layout in this-procedure (buffer buf_layout, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование РАСКЛАДКИ &2:&3&4"
                                     , vss-workfile
                                     , buf_layout.layout-id
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. РАСКЛАДКА &2 используется &3&4"
                                    , vss-workfile
                                    , buf_layout.layout-id
                                    , {&new-line}
                                    , return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      run adm/layout3.p (
                       input yes /*p-silent*/
                      ,input recid(buf_layout)
                      ) no-error .
      if error-status:error then do:
        undo, return error substitute("Ошибка при удалении РАСКЛАДОК №&1&2&3&2&4"
                            , buf_layout.layout-id
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
      end.
    end.
  end.
end procedure. /* delete-layout */


procedure undo-delete-layout :
/*откат блокировки товара на объекте*/
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
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-new  as logical no-undo .
    define variable v-layout-id         like ub.layout.layout-id no-undo .
    define variable old-sts as integer no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_layout for ub.layout.
    define buffer buf_c-layout for ub.c-layout.

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
    if v-tbl-name <> {&table_layout} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей РАСЛКАДОК", vss-workfile ).
    end.

    find first buf_layout exclusive-lock where
               rowid(buf_layout) = v-rowid no-error  .
    if not available buf_layout then do:
      assign
      v-layout-id = entry(1, pr-parameters, {&delim-par})
      old-sts    = integer(entry(2, pr-parameters, {&delim-par}))
      .
      find first buf_layout exclusive-lock where
                 buf_layout.layout-id = v-layout-id no-error no-wait.
      if not available buf_layout
      AND not LOCKED(buf_layout)
      then do:
        find first buf_layout no-lock where
                 buf_layout.layout-id = v-layout-id no-error .
        if not available buf_layout then do:
          /*проверим она вообще была?*/
          find last buf_c-layout no-lock where
                    buf_c-layout.layout-id = v-layout-id
                and buf_c-layout.corr-user-db-num = g#db-num no-error.
          if available buf_c-layout then do:
            create buf_layout.
            buffer-copy buf_c-layout to buf_layout
            assign
            buf_layout.sts = old-sts
            .
            return.
          end.
        end.
        return error substitute( "&1. Не найдена или занята РАСКЛАДКА &2"
                                , vss-workfile
                                , v-layout-id
                                ).
      end.
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :

      if buf_layout.sts = integer({&to-delete-status-int}) then do:
        assign
        buf_layout.sts = old-sts.
        release buf_layout.
      end.
    end.
  end.

end procedure. /* undo-delete-layout */


procedure proc-is-used-layout :
define parameter buffer buf_layout for ub.layout.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

define variable v-mess as character no-undo .


  _main:
  do
  on error undo, return error return-value
  :

    run  layoutus_is-used in this-procedure (
                                              input buf_layout.layout-type
                                            ,input buf_layout.layout-id
                                            ,output p-is-used
                                            ,output v-mess) no-error .
    if error-status:error then do:
      v-mess = substitute("РАСКЛАДКА №&1 не может быть удалена &2&3&2&4"
                            , buf_layout.layout-id
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
      undo _main, return error v-mess .
    end.
    if p-is-used then do:
      return v-mess .
    end.
    assign
    p-is-used = no.
  end.
end procedure. /* proc-is-used-layout */