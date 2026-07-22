block-level on error undo, throw.
 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
                                                                             o
Библиотека процедур для распределенной обработки  dis-rult


Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/03
Author: Bakhtadze Natalya
Creation date: 10/31/03

*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки dis-rult".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }


&scop btpr-act-blocked-for-delete 'blocked-for-delete':U


procedure block-del-dis-rule :
/*блокирование dis-rule для последующего удаления*/
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

    define buffer buf_dis-rule for ub.dis-rule.

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

    if v-tbl-name <> {&table_dis-rule} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей правила скидок", vss-workfile ).
    end.

    find first buf_dis-rule
      where rowid( buf_dis-rule ) = v-rowid
      no-error .

    if not available buf_dis-rule then do:
      assign
      pc-err-msg = substitute( "Нет необходимого правила скидок &2", pc-uniq-key-rec ).
      .
      return .
    end.


    if buf_dis-rule.sts = integer({&to-delete-status-int}) then do:
      assign
      pc-err-msg = substitute( "Правило скидок &1 уже заблокировано или удалено!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      /*взводим статус*/
      assign
      old-sts = buf_dis-rule.sts
      buf_dis-rule.sts = integer({&to-delete-status-int})
      .
      /*проверяем на использование*/
      run proc-is-used-dis-rule in this-procedure (buffer buf_dis-rule, input pc-db-num, output l-is-used) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование правила скидок &2:&3&4"
                                      , vss-workfile
                                      , buf_dis-rule.rule-num
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_dis-rule.sts = old-sts
        pc-err-msg = substitute( "&1. Правило скидок &2 используется:&3&4"
                                 , vss-workfile
                                 , buf_dis-rule.rule-num
                                 , {&new-line}
                                 , return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-dis-rule */


procedure delete-dis-rule :
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
    define variable v-is-prt-bar-code as logical no-undo .
    define variable v-rule-num like ub.dis-rule.rule-num no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-sts          as integer no-undo .

    define buffer buf_dis-rule         for ub.dis-rule .
    define buffer buf_dis-rule2         for ub.dis-rule .
    define buffer buf_c-dis-rule        for ub.c-dis-rule.


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
    if v-tbl-name <> {&table_dis-rule} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей правил скидок", vss-workfile ).
    end.
    assign
    v-rule-num = integer(entry(1, pe-parameters, {&delim-par}))
    v-old-sts  = integer(entry(2, pe-parameters, {&delim-par}))
    .
    find first buf_dis-rule exclusive-lock where
              buf_dis-rule.rule-num = v-rule-num no-wait no-error.

    if not available buf_dis-rule
    and not locked(buf_dis-rule) then do:
      find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num no-error.
      if not available buf_dis-rule then return.
    end.

    if not available buf_dis-rule then do:
      return error substitute( "&1. Не найдено или занято правило скидок &2"
                            , vss-workfile
                            , v-rule-num
                            ).
    end.

    /*проверим что dis-rule заблокировано*/
    if buf_dis-rule.sts <> integer({&to-delete-status-int}) then do:
      return error substitute( "&1. Правило скидок &2 не заблокировано для удаления"
                             , vss-workfile
                             , buf_dis-rule.rule-num
                             ).
    end.
    /*проверяем на использование*/
    run proc-is-used-dis-rule in this-procedure (buffer buf_dis-rule, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование правила скидок &2:&3&4"
                                     , vss-workfile
                                     , buf_dis-rule.rule-num
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. Правило скидок &2 используется &3&4"
                                    , vss-workfile
                                    , buf_dis-rule.rule-num
                                    , {&new-line}
                                    , return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      define variable v-can as logical no-undo .
      run ref/dis-rul3.p (
                       buffer buf_dis-rule
                      ,input no /*p-sts-mode удаление а не проверка*/
                      ,input yes /*p-silent*/
                      ,output v-can
                      ) no-error .
      if error-status:error then do:
        undo, return error substitute("Ошибка при удалении ПРАВИЛА СКИДОК №&1&2&3&2&4"
                            , buf_dis-rule.rule-num
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
      end.
    end.
  end.
end procedure. /* delete-dis-rule */


procedure undo-delete-dis-rule :
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
    define variable v-rule-num         like ub.dis-rule.rule-num no-undo .
    define variable old-sts as integer no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_c-dis-rule for ub.c-dis-rule.

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
    if v-tbl-name <> {&table_dis-rule} then do:
      return error substitute( "&1. Данная процедура может работать только с правил скидок", vss-workfile ).
    end.

    find first buf_dis-rule exclusive-lock where
               rowid(buf_dis-rule) = v-rowid no-error  .
    if not available buf_dis-rule then do:
      assign
      v-rule-num = integer(entry(1, pr-parameters, {&delim-par}))
      old-sts    = integer(entry(2, pr-parameters, {&delim-par}))
      .
      find first buf_dis-rule exclusive-lock where
                 buf_dis-rule.rule-num = v-rule-num no-error no-wait.
      if not available buf_dis-rule
      AND not LOCKED(buf_dis-rule)
      then do:
        find first buf_dis-rule no-lock where
                 buf_dis-rule.rule-num = v-rule-num no-error .
        if not available buf_dis-rule then do:
          /*проверим она вообще была?*/
          find last buf_c-dis-rule no-lock where
                    buf_c-dis-rule.rule-num = v-rule-num
                and buf_c-dis-rule.corr-user-db-num = g#db-num no-error.
          if available buf_c-dis-rule then do:
            create buf_dis-rule.
            buffer-copy buf_c-dis-rule to buf_dis-rule
            assign
            buf_dis-rule.sts = old-sts
            .
            return.
          end.
        end.
        return error substitute( "&1. Не найдено или занято правило скидок &2"
                                , vss-workfile
                                , v-rule-num
                                ).
      end.
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :

      if buf_dis-rule.sts = integer({&to-delete-status-int}) then do:
        assign
        buf_dis-rule.sts = old-sts.
        release buf_dis-rule.
      end.
    end.
  end.

end procedure. /* undo-delete-dis-rule */


procedure proc-is-used-dis-rule :
define parameter buffer buf_dis-rule for ub.dis-rule.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

define variable v-mess as character no-undo .
define variable v-can as logical no-undo .


  _main:
  do
  on error undo, return error return-value
  :

    run ref/dis-rul3.p (
                   buffer buf_dis-rule
                  ,input yes
                  ,input yes /*p-silent*/
                  ,output v-can
                  ) no-error.
    if error-status:error then do:
      v-mess = substitute("ПРАВИЛО СКИДОК №&1 не может быть удалено &2&3&2&4"
                            , buf_dis-rule.rule-num
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
      undo _main, return error v-mess .
    end.
    if not v-can then do:
      p-is-used = yes.
      return return-value .
    end.
    assign
    p-is-used = no.
  end.
end procedure. /* proc-is-used-dis-rule */