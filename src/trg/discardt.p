block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для распределенной обработки ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/09/06
Author: Bakhtadze Natalya
Creation date: 05/09/06

*/


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }
{ trg/discardh.i }


&scop btpr-act-blocked-for-delete 'blocked-for-delete':U
&scop btpr-act-blocked-for-chown  'blocked-for-chown':U


procedure block-del-dis-card :
/*блокирование ДК признака для последующего удаления*/
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
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-status as character no-undo .
    define variable v-return-value as character no-undo .

    define buffer buf_dis-card for ub.dis-card.


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

    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.

    find first buf_dis-card
      where rowid( buf_dis-card ) = v-rowid
      no-error .

    if not available buf_dis-card then do:
      return error substitute( "&1. Нет необходимой ДК &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_dis-card.status_ = {&nonused-status}
    or buf_dis-card.status_ = {&chown-status} then do:
      assign
      pc-err-msg = substitute( "ДК &1 уже заблокирована или удалена!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      run discardh_write-dis-card-proc in this-procedure  (
                                                    buffer buf_dis-card
                                                    ,input (if g#news
                                                            then {&hn-source-db}
                                                            else (if g#esys
                                                                  then {&hn-source-esys}
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                  ) .


      /*взводим статус*/
      assign
      v-old-status = buf_dis-card.status_
      buf_dis-card.status_ = {&nonused-status}
      .
      /*проверяем на использование*/
      run proc-is-used-dis-card in this-procedure ( buffer buf_dis-card
                                                 , input pc-db-num
                                                 , output l-is-used) no-error .
      v-return-value = return-value.
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                      , vss-workfile
                                      , buf_dis-card.d-card
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                      ,input (if g#news
                                                              then {&hn-source-db}
                                                              else (if g#esys
                                                                    then {&hn-source-esys}
                                                                    else "":U)
                                                              )
                                                      ,input  (if g#news
                                                                then string(g#news-source-db)
                                                                else (if g#esys
                                                                      then string(g#esys-source-esys)
                                                                      else "":U)
                                                                )
                                                    ) .
        assign
        buf_dis-card.status_  = v-old-status
        pc-err-msg = substitute( "&1. ДК &2 используется:&3&4"
                                 , vss-workfile
                                 , buf_dis-card.d-card
                                 , {&new-line}
                                 , v-return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-dis-card */


procedure delete-dis-card :
/*удаление несипользуемой ДК*/
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
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-return-value     as character no-undo .

    define buffer buf_dis-card         for ub.dis-card .
    define buffer buf_c-dc-hist        for ub.c-dc-hist .
    define buffer buf_dis-card-property    for ub.dis-card-property .

    define buffer buf_c-dis-card-property  for ub.c-dis-card-property .
    define buffer buf_dis-obj          for ub.dis-obj .
    define buffer buf_c-dis-obj        for ub.c-dis-obj .
    define buffer buf_dis-host         for ub.dis-host .
    define buffer buf_c-dis-host       for ub.c-dis-host .

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
    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pe-parameters, {&delim-par})
    v-old-status_ = entry(2, pe-parameters, {&delim-par})
    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.

    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.

    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.

    /*проверим что карта заблокирована*/
    if buf_dis-card.status_ <> {&nonused-status} then do:
      return error substitute( "&1. ДК &2 не заблокирована для удаления", vss-workfile, buf_dis-card.d-card ).
    end.
    /*проверяем на использование*/
    run proc-is-used-dis-card in this-procedure ( buffer buf_dis-card, input pe-db-num, output l-is-used) no-error .
    v-return-value = return-value .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                     , vss-workfile
                                     , buf_dis-card.d-card
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. ДК &2 используется &3&4"
                                    , vss-workfile
                                    , buf_dis-card.d-card
                                    , {&new-line}
                                    , v-return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      delete buf_dis-card.
    end.
  end.
end procedure. /* delete-dis-card */


procedure undo-delete-dis-card :
/*откат блокировки ДК*/
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
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable v-new              as logical no-undo .
    define variable v-old-status_      as character no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_dis-card       for ub.dis-card    .
    define buffer buf_c-dis-card     for ub.c-dis-card.

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
    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pr-parameters, {&delim-par})
    v-old-status_ = entry(2, pr-parameters, {&delim-par})
    .

    find first buf_dis-card exclusive-lock where
               rowid(buf_dis-card) = v-rowid no-error  .
    if not available buf_dis-card then do:
      find first buf_dis-card exclusive-lock where
                 buf_dis-card.d-card = v-d-card no-error no-wait.
      if not available buf_dis-card
      AND not LOCKED(buf_dis-card)
      then do:
        find first buf_dis-card no-lock where
                 buf_dis-card.d-card = v-d-card no-error.
        if not available buf_dis-card then do:
          /*проверим она вообще была?*/
          find last buf_c-dis-card no-lock where
                    buf_c-dis-card.d-card = v-d-card
                and buf_c-dis-card.corr-user-db-num = g#db-num no-error.
          if available buf_c-dis-card then do:
             create buf_dis-card.
             buffer-copy buf_c-dis-card to buf_dis-card.
              run discardh_write-dis-card-proc in this-procedure  (
                                                            buffer buf_dis-card
                                                          ,input (if g#news
                                                                  then {&hn-source-db}
                                                                  else (if g#esys
                                                                        then {&hn-source-esys}
                                                                        else "":U)
                                                                  )
                                                          ,input  (if g#news
                                                                    then string(g#news-source-db)
                                                                    else (if g#esys
                                                                          then string(g#esys-source-esys)
                                                                          else "":U)
                                                                    )
                                                          ) .

             assign
             buf_dis-card.status_ = v-old-status_
             .
             return.
          end.
        end.
        return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
      end.
    end.


    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :

      if buf_dis-card.status_ = {&nonused-status} then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                    ,input (if g#news
                                                            then {&hn-source-db}
                                                            else (if g#esys
                                                                  then {&hn-source-esys}
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                    ) .
        assign
        buf_dis-card.status_ = v-old-status_
        .
        release buf_dis-card.
      end.
    end.
  end.

end procedure. /* undo-delete-prt-bar-code */


procedure proc-is-used-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

  do
  on error undo, return error return-value
  :

    define buffer buf_dis-card-property for ub.dis-card-property.
    define buffer buf_dis-obj for ub.dis-obj.
    define buffer buf2_dis-card for ub.dis-card.
    define buffer buf_dis-host for ub.dis-host.
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_clients for ub.clients.
    define buffer buf_payment for ub.payment.
    define buffer buf_sysconf for ub.sysconf.

    for each buf2_dis-card no-lock where
            buf2_dis-card.card-num = buf_dis-card.card-num:
      if buf2_dis-card.d-card = buf_dis-card.d-card then next.
      return substitute("dis-card Перевыпущенная карта &1 для карты &2", buf2_dis-card.d-card, buf_dis-card.d-card).
    end.

    for each buf_sysconf,
        each buf_payment no-lock where
            buf_payment.cli-type = buf_dis-card.cli-type
        and buf_payment.cli-code = buf_dis-card.cli-code
        and buf_payment.d-card = buf_dis-card.d-card :
      return substitute("payment Платеж &1 на фирму &2 для карты &2", buf_payment.pmnt-code, buf_payment.host-code, buf_dis-card.d-card).
    end.
    for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        and buf_clients.db-num = g#db-num:
       find first buf_chk-doc no-lock where
                buf_chk-doc.obj-type = buf_Clients.obj-type
            and buf_chk-doc.obj-code = buf_Clients.obj-code
            and buf_chk-doc.d-card = buf_dis-card.d-card no-error.
       if available buf_chk-doc then do:
         return substitute("chk-doc Чек &1 для карты &2", buf_chk-doc.doc-code, buf_dis-card.d-card).
       end.
    end.
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = buf_dis-card.d-card:
      if buf_dis-obj.pay-tot-rubl <> 0
      or buf_dis-obj.num-chk <> 0
      or buf_dis-obj.gds-tot-rubl <> 0  then do:
        return substitute("dis-obj Итоги на объекте &1&2 для карты &3", buf_dis-obj.obj-type, buf_dis-obj.obj-code, buf_dis-card.d-card).
      end.
    end.
    for each buf_dis-host no-lock where
            buf_dis-host.d-card = buf_dis-card.d-card:
      if buf_dis-host.pay-tot-rubl <> 0
      or buf_dis-host.num-chk <> 0
      or buf_dis-host.gds-tot-rubl <> 0  then do:
        if buf_dis-host.host-code > 0 then
        return substitute("dis-host Итоги на фирме &1 для карты &2", buf_dis-host.host-code, buf_dis-card.d-card).
        else
        return substitute("dis-host Глобальные итоги").
      end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-used-dis-card */

procedure block-chown-dis-card :
/*блокирование ДК для смены держателя*/
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
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-status as character no-undo .
    define variable v-return-value as character no-undo .


    define buffer buf_dis-card for ub.dis-card.


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

    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.

    find first buf_dis-card
      where rowid( buf_dis-card ) = v-rowid
      no-error .

    if not available buf_dis-card then do:
      return error substitute( "&1. Нет необходимой ДК &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_dis-card.status_ = {&chown-status}
    or buf_dis-card.status_ = {&nonused-status}
    then do:
      assign
      pc-err-msg = substitute( "ДК &1 уже заблокирована или удалена!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      run discardh_write-dis-card-proc in this-procedure  (
                                                    buffer buf_dis-card
                                                    ,input (if g#news
                                                            then {&hn-source-db}
                                                            else (if g#esys
                                                                  then {&hn-source-esys}
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                  ) .

      /*взводим статус*/
      assign
      v-old-status = buf_dis-card.status_
      buf_dis-card.status_ = {&nonused-status}
      .

      /*проверяем на использование*/
      run proc-is-used-trn-doc-dis-card in this-procedure ( buffer buf_dis-card
                                                          , input pc-db-num
                                                          , output l-is-used) no-error .
      v-return-value = return-value .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                      , vss-workfile
                                      , buf_dis-card.d-card
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                    ,input (if g#news
                                                            then {&hn-source-db}
                                                            else (if g#esys
                                                                  then {&hn-source-esys}
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                    ) .
        assign
        buf_dis-card.status_  = v-old-status
        pc-err-msg = substitute( "&1. ДК &2 используется:&3&4"
                                  , vss-workfile
                                  , buf_dis-card.d-card
                                  , {&new-line}
                                  , v-return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-dis-card */


procedure chown-dis-card :
/*смена держателя ДК*/
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
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.
    define variable v-return-value     as character no-undo .

    define buffer buf_dis-card         for ub.dis-card .

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
    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pe-parameters, {&delim-par})
    v-old-status_ = entry(2, pe-parameters, {&delim-par})
    v-cli-type = entry(3, pe-parameters, {&delim-par})
    v-cli-code = integer(entry(4, pe-parameters, {&delim-par}))
    v-old-cli-type = entry(5, pe-parameters, {&delim-par})
    v-old-cli-code = integer(entry(6, pe-parameters, {&delim-par}))
    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.

    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.

    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.

    /*проверим что карта заблокирована*/
    if buf_dis-card.status_ <> {&chown-status} then do:
      return error substitute( "&1. ДК &2 не заблокирована для смены владельца", vss-workfile, buf_dis-card.d-card ).
    end.
    /*проверяем на использование*/
    run proc-is-used-trn-doc-dis-card in this-procedure ( buffer buf_dis-card, input pe-db-num, output l-is-used) no-error .
    v-return-value = return-value .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                     , vss-workfile
                                     , buf_dis-card.d-card
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. ДК &2 используется &3&4"
                                    , vss-workfile
                                    , buf_dis-card.d-card
                                    , {&new-line}
                                    , v-return-value
                                    ).
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
       /**/
       run proc-chown-dis-card in this-procedure ( buffer buf_dis-card
                                                  ,input v-cli-type
                                                  ,input v-cli-code
                                                  ).
    end.
  end.
end procedure. /* chown-dis-card */


procedure undo-chown-dis-card :
/*откат блокировки ДК*/
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
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable v-new              as logical no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.


    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_dis-card       for ub.dis-card    .

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
    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pr-parameters, {&delim-par})
    v-old-status_ = entry(2, pr-parameters, {&delim-par})
    v-cli-type = entry(3, pr-parameters, {&delim-par})
    v-cli-code = integer(entry(4, pr-parameters, {&delim-par}))
    v-old-cli-type = entry(5, pr-parameters, {&delim-par})
    v-old-cli-code = integer(entry(6, pr-parameters, {&delim-par}))
    .

    find first buf_dis-card exclusive-lock where
               rowid(buf_dis-card) = v-rowid no-error  .
    if not available buf_dis-card then do:
      find first buf_dis-card exclusive-lock where
                 buf_dis-card.d-card = v-d-card no-error no-wait.
      if not available buf_dis-card
      AND not LOCKED(buf_dis-card)
      then do:
        find first buf_dis-card no-lock where
                 buf_dis-card.d-card = v-d-card no-error.
        if not available buf_dis-card then do:
          return .
        end.
        return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
      end.
    end.


    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      if not (buf_dis-card.cli-type = v-old-cli-type
        and    buf_dis-card.cli-code = v-old-cli-code) then do:
        run proc-chown-dis-card in this-procedure ( buffer buf_dis-card
                                                    ,input v-old-cli-type
                                                    ,input v-old-cli-code
                                                    ).
      end.
      /*вся разблокировка в after
      if buf_dis-card.status_ = {&chown-status} then do:
        assign
        buf_dis-card.status_ = v-old-status_
        .
        release buf_dis-card.
      end.
      */
    end.
  end.

end procedure. /* undo-chown-dis-card */

procedure after-chown-dis-card :
/*после смены держателя ДК - возвратим статус*/
define input  parameter pa-action       as character no-undo .
define input  parameter pa-uniq-key-rec as character no-undo .
define input  parameter pa-db-init      as integer   no-undo .
define input  parameter pa-parameters   as character no-undo .
define output parameter pa-err-msg      as character no-undo .

  do
  on error undo, return error return-value
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.


    define buffer buf_dis-card         for ub.dis-card .

    run gen-row-keyr in this-procedure
      ( input  pa-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pa-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_dis-card} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pa-parameters, {&delim-par})
    v-old-status_ = entry(2, pa-parameters, {&delim-par})
    v-cli-type = entry(3, pa-parameters, {&delim-par})
    v-cli-code = integer(entry(4, pa-parameters, {&delim-par}))
    v-old-cli-type = entry(5, pa-parameters, {&delim-par})
    v-old-cli-code = integer(entry(6, pa-parameters, {&delim-par}))

    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.

    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.

    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.

    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
       /**/
       if buf_dis-card.status_ = {&chown-status} then do:
          run discardh_write-dis-card-proc in this-procedure  (
                                                        buffer buf_dis-card
                                                      ,input (if g#news
                                                              then {&hn-source-db}
                                                              else (if g#esys
                                                                    then {&hn-source-esys}
                                                                    else "":U)
                                                              )
                                                      ,input  (if g#news
                                                                then string(g#news-source-db)
                                                                else (if g#esys
                                                                      then string(g#esys-source-esys)
                                                                      else "":U)
                                                                )
                                                      ) .
        assign
        buf_dis-card.status_ = v-old-status_
        .
      end.
    end.
  end.
end procedure. /* chown-dis-card */



procedure proc-is-used-trn-doc-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

  do
  on error undo, return error return-value
  :

    define buffer buf_dis-card-property for ub.dis-card-property.
    define buffer buf_dis-obj for ub.dis-obj.
    define buffer buf2_dis-card for ub.dis-card.
    define buffer buf_clients for ub.clients.
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_payment for ub.payment.
    define buffer buf_trn-doc for ub.trn-doc.

    for each buf2_dis-card no-lock where
            buf2_dis-card.card-num = buf_dis-card.card-num:
      if buf2_dis-card.d-card = buf_dis-card.d-card then next.
      return substitute("dis-card Перевыпущенная карта &1 для карты &2", buf2_dis-card.d-card, buf_dis-card.d-card).
    end.
    for each buf_sysconf,
        each buf_payment no-lock where
            buf_payment.cli-type = buf_dis-card.cli-type
        and buf_payment.cli-code = buf_dis-card.cli-code
        and buf_payment.d-card = buf_dis-card.d-card :
      if buf_payment.source-type <> {&pmnt-cash-desk} then do:
        return substitute("payment Платеж &1 на фирму &2 для документа &3 для карты &4"
                         , buf_payment.pmnt-code
                         , buf_payment.host-code
                         , buf_payment.source-ref
                         , buf_dis-card.d-card
                         ).
      end.
    end.

    for each buf_clients no-lock where
           buf_clients.db-num = g#db-num:
       for each buf_trn-doc no-lock where
                buf_trn-doc.obj-type = buf_Clients.obj-type
            and buf_trn-doc.obj-code = buf_Clients.obj-code
            and buf_trn-doc.cli-type = buf_dis-card.cli-type
            and buf_trn-doc.cli-code = buf_dis-card.cli-code:
         if buf_trn-doc.d-card = buf_dis-card.d-card then do:
           return substitute("trn-doc Документ &1 для карты &2", buf_trn-doc.doc-code, buf_dis-card.d-card).
         end.
       end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-trn-doc-dis-card */


procedure proc-chown-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-cli-type like ub.dis-card.cli-type no-undo .
define input parameter p-cli-code like ub.dis-card.cli-code no-undo .

define variable v-is-update as logical no-undo .
define variable v-chip-num as integer no-undo .

define buffer buf_chk-doc          for ub.chk-doc .
define buffer buf_chk-gds          for ub.chk-gds .
define buffer buf_clients          for ub.clients.
define buffer buf_sysconf          for ub.sysconf.
define buffer buf_payment          for ub.payment.


  do
  on error undo, return error return-value
  :

    for each buf_sysconf,
        each buf_payment where
            buf_payment.host-code = buf_sysconf.host-code
        and buf_payment.d-card = buf_dis-card.d-card
    on error undo, return error return-value
        :
      if buf_payment.source-type = {&pmnt-cash-desk} then do:
        if buf_payment.payer-type = buf_payment.cli-type
        and buf_payment.payer-code = buf_payment.cli-code
        then
        assign
        buf_payment.payer-type = p-cli-type
        buf_payment.payer-code = p-cli-code
        .
        assign
        buf_payment.cli-type = p-cli-type
        buf_payment.cli-code = p-cli-code
        .

      end.
    end.
    for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}:
      for each buf_chk-doc where
                buf_chk-doc.obj-type = buf_Clients.obj-type
            and buf_chk-doc.obj-code = buf_Clients.obj-code
            and buf_chk-doc.d-card = buf_dis-card.d-card:
          run trg/chk-doch.p (
                          buffer buf_chk-doc
                        , input no
                        , input no /*p-add*/
                        , input no /*p-del*/
                        , input-output v-chip-num
                        , output v-is-update).

        for each buf_chk-gds where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          if buf_chk-gds.d-card = buf_dis-card.d-card
          then
          assign
          buf_chk-gds.cli-type = p-cli-type
          buf_chk-gds.cli-code = p-cli-code
          .
        end.
        assign
        buf_chk-doc.cli-type = p-cli-type
        buf_chk-doc.cli-code = p-cli-code
        .
        run trg/chk-doch.p (
                        buffer buf_chk-doc
                      , input yes
                      , input no /*p-add*/
                      , input no /*p-del*/
                      , input-output v-chip-num
                      , output v-is-update).

      end.
      assign
      buf_dis-card.cli-type = p-cli-type
      buf_dis-card.cli-code = p-cli-code
      .
    end. /*      for each buf_clients no-lock where*/
  end. /*dow*/

end procedure. /* proc-chown-dis-card */