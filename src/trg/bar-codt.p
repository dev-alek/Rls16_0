block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для распределенной обработки бар-кодов

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
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки бар-кодов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ trg/prtbcdel.i }
{ str/bc-gnrt.i new bc }

&scop btpr-act-blocked-for-delete 'blocked-for-delete':U


procedure block-del-prt-bar-code :
/*блокирование бар-кода признака для последующего удаления*/
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-stts as integer no-undo .

    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_gds-prt for ub.gds-prt.

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

    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .

    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_bar-code.stts = integer({&hn-delete}) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    if buf_bar-code.stts_ <> 0
    and not (buf_bar-code.stts_ = integer({&hn-switch-off}))
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.

    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,output v-is-prt-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code ).
    end.

    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = buf_bar-code.node-code  no-error .

    if not available buf_gds-prt then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, buf_bar-code.b-code ).
    end.

    /* определяем признак терминальный или нет */
   { gbl/prtat.i buf_gds-prt.node-code 'terminal-prt=request':u l-terminal-prt no-error }
    if error-status :error
    then do:
      message return-value error-status:get-message(1) view-as alert-box .
      return error substitute( "&1. Ошибка при определении терминальности признака для бар-кода &2", vss-workfile, buf_bar-code.b-code ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      /*взводим статус*/
      assign
      v-old-stts = buf_bar-code.stts_
      buf_bar-code.stts_ = integer({&hn-delete})
      .
      /*проверяем на использование*/
      run proc-is-used-prt-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, input l-terminal-prt, output l-is-used) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_bar-code.stts_ = v-old-stts
        pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                 , vss-workfile
                                 , buf_bar-code.b-code
                                 , {&new-line}
                                 , return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-prt-bar-code */


procedure delete-prt-bar-code :
/*удаление несипользуемого бар-кода признака*/
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical    no-undo .

    define buffer buf_bar-code         for ub.bar-code .

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    assign
    v-b-code = integer(entry(1, pe-parameters, {&delim-par}))
    .
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.

    if not available buf_bar-code
    and not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.

    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.

    /*проверим что бар-код заблокирован*/
    if buf_bar-code.stts_ <> integer({&hn-delete}) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.
    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-prt-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code).
    end.

    /*проверяем на использование*/
    run proc-is-used-prt-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, input ?, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , {&new-line}
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. Бар-код &2 используется в товародвижении&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , {&new-line}
                                    , return-value
                                    ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure. /* delete-prt-bar-code */


procedure undo-delete-prt-bar-code :
/*откат блокировки бар-кода*/
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-node-code like ub.bar-code.node-code no-undo .
    define variable v-part-code like ub.bar-code.part-code no-undo .
    define variable v-in-code    like ub.bar-code.in-code no-undo .
    define variable v-unit-cli   like ub.bar-code.unit-cli no-undo .
    define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, {&delim-par}))
      v-old-stts = integer(entry(8, pr-parameters, {&delim-par}))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Нт найден или занят бакрод &2", vss-workfile, v-b-code ).
      end.
    end.


    do
    on error undo, return error
    on stop undo, return error
    :

      if buf_bar-code.stts_ = integer({&hn-delete}) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
    end.
  end.

end procedure. /* undo-delete-prt-bar-code */


procedure proc-is-used-prt-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define input parameter p-terminal-prt  as logical no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

  do
  on error undo, return error
  :

    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-prt-bar-code as logical no-undo .

    define buffer buf_goods for ub.goods.
    define buffer buf_prt-obj for ub.prt-obj.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_scales-gds for ub.scales-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_ord-dtl for ub.ord-dtl.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.
    define buffer buf_ord-dtl-rcv for ub.ord-dtl-rcv.
    define buffer buf_tmp-sale-dtl for ub.tmp-sale-dtl.

    /*нет ли чего в таблицах независящих от объекта*/

    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-prt-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.

    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code).
    end.

    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.

    find first buf_prt-obj no-lock where
               buf_prt-obj.artic = buf_goods.artic
           AND buf_prt-obj.prod-type = buf_goods.prod-type
           AND buf_prt-obj.prod-code = buf_goods.prod-code
           AND buf_prt-obj.prt-code  = buf_bar-code.node-code no-error .
    if available buf_prt-obj then
    return substitute("prt-obj объект &1&2", buf_prt-obj.obj-type, buf_prt-obj.obj-code).

    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).

    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1" + buf_prod-bc-db.b-str).

    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1" + buf_sert-join.sert-code).

    find first buf_ord-dtl no-lock where
               buf_ord-dtl.artic = buf_goods.artic
           AND buf_ord-dtl.prod-type = buf_goods.prod-type
           AND buf_ord-dtl.prod-code = buf_goods.prod-code
           AND buf_ord-dtl.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl then
    return substitute("ord-dtl Код заказа &1" + buf_ord-dtl.doc-code).

    find first buf_ord-dtl-cons no-lock where
               buf_ord-dtl-cons.artic = buf_goods.artic
           AND buf_ord-dtl-cons.prod-type = buf_goods.prod-type
           AND buf_ord-dtl-cons.prod-code = buf_goods.prod-code
           AND buf_ord-dtl-cons.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl-cons then
    return substitute("ord-dtl-cons Код заказа &1" + buf_ord-dtl-cons.cons-code).

    find first buf_ord-dtl-rcv no-lock where
               buf_ord-dtl-rcv.artic = buf_goods.artic
           AND buf_ord-dtl-rcv.prod-type = buf_goods.prod-type
           AND buf_ord-dtl-rcv.prod-code = buf_goods.prod-code
           AND buf_ord-dtl-rcv.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl-rcv then
    return substitute("ord-dtl-rcv Код заказа &1" + buf_ord-dtl-rcv.doc-code).

    find first buf_tmp-sale-dtl no-lock where
               buf_tmp-sale-dtl.artic = buf_goods.artic
           AND buf_tmp-sale-dtl.prod-type = buf_goods.prod-type
           AND buf_tmp-sale-dtl.prod-code = buf_goods.prod-code
           AND buf_tmp-sale-dtl.node-code = buf_bar-code.node-code   no-error .
    if available buf_tmp-sale-dtl then
    return substitute("tmp-sale-dtl Код типа темпов продаж &1", buf_tmp-sale-dtl.tmp-code).

    /*теперь пройдемся по объектам*/
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).
      find first buf_gds-dtl no-lock where
                 buf_gds-dtl.obj-type = buf_clients.obj-type
             AND buf_gds-dtl.obj-code = buf_clients.obj-code
             AND buf_gds-dtl.prod-type = buf_goods.prod-type
             AND buf_gds-dtl.prod-code = buf_goods.prod-code
             AND buf_gds-dtl.artic = buf_goods.artic
             AND buf_gds-dtl.prt-code = buf_bar-code.node-code no-error .
     if available buf_gds-dtl then
     return substitute("gds-dtl объект &1&2 Номер накладной &3",
                        buf_gds-dtl.obj-type, string(buf_gds-dtl.obj-code),  buf_gds-dtl.doc-code  ).

    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).
    find first buf_price-doc-forming-gds no-lock where
              buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.


    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-used-prt-bar-code */


procedure block-del-part-bar-code :
/*блокирование бар-кода партии для последующего удаления*/
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-part-bar-code as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-stts as integer no-undo .

    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_gds-prt for ub.gds-prt.

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .

    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
    end.

    if buf_bar-code.stts = integer({&hn-delete}) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    if buf_bar-code.stts_ <> 0
    and not (buf_bar-code.stts = integer({&hn-switch-off}))
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.

    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-part-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, buf_bar-code.b-code ).
    end.

    if buf_bar-code.stts_ <> 0
    and not buf_bar-code.stts_ = integer({&hn-switch-off})
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.

    do
    on error undo, return error
    on stop undo, return error
    :

      assign
      v-old-stts = buf_bar-code.stts_
      buf_bar-code.stts_ = integer({&hn-delete})
      .
      /*проверяем на использование*/
      run proc-is-used-part-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, output l-is-used) no-error .
      if error-status:error  then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_bar-code.stts_ = v-old-stts
        .
        assign
        pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                  , vss-workfile
                                  , buf_bar-code.b-code
                                  , {&new-line}
                                  , return-value
                                    )
        .
        return pc-err-msg.
      end.
    end.
  end.

end procedure. /* block-del-part-bar-code */


procedure delete-part-bar-code :
/*удаление неиспользуемого бар-кода партии*/
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-part-bar-code as logical no-undo .
    define variable v-b-code           like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical   no-undo .

    define buffer buf_bar-code         for ub.bar-code .

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    assign
    v-b-code = integer(entry(1, pe-parameters, {&delim-par}))
    .
    /*проверим что бар-код заблокирован*/
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.

    if not available buf_bar-code
    AND not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.

    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.

    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, v-b-code ).
    end.

    if buf_bar-code.stts_ <> integer({&hn-delete}) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.

    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_Bar-code.node-code
                                          ,input buf_Bar-code.part-code
                                          ,input buf_Bar-code.in-code
                                          ,input buf_Bar-code.unit-cli
                                          , output v-is-part-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, buf_bar-code.b-code).
    end.

    /*проверяем на использование*/
    run proc-is-used-part-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      ).
    end.
    if l-is-used then do:
      undo, return  error substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , {&new-line}
                                     , return-value
                                     ).
    end.

    do
    on error undo, return error
    on stop undo, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure. /* delete-part-bar-code */


procedure undo-delete-part-bar-code :
/*откат блокировки бар-кода партии*/
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-node-code like ub.bar-code.node-code no-undo .
    define variable v-part-code like ub.bar-code.part-code no-undo .
    define variable v-in-code    like ub.bar-code.in-code no-undo .
    define variable v-unit-cli   like ub.bar-code.unit-cli no-undo .
    define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, {&delim-par}))
      v-old-stts = integer(entry(8, pr-parameters, {&delim-par}))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
      end.
    end.

    do
    on error undo, return error
    on stop undo, return error
    :

      if buf_bar-code.stts_ = integer({&hn-delete}) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
      assign
      v-gds-code  = integer(entry(2, pr-parameters, {&delim-par}))
      v-node-code = integer(entry(3, pr-parameters, {&delim-par}))
      v-part-code = entry(4, pr-parameters, {&delim-par})
      v-in-code   = entry(5, pr-parameters, {&delim-par})
      v-unit-cli  = entry(6, pr-parameters, {&delim-par})
      v-cli-base-rate = integer(entry(7, pr-parameters, {&delim-par}))
      v-old-stts = integer(entry(8, pr-parameters, {&delim-par}))
      .
    end.

  end. /*doe*/

end procedure. /* undo-delete-part-bar-code */


procedure proc-is-used-part-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

  do
  on error undo, return error
  :

    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-part-bar-code as logical no-undo .

    define buffer buf_goods for ub.goods.
    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_doc-prts for ub.doc-prts.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.

    /*нет ли чего в таблицах независящих от объекта*/

    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,output v-is-part-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.

    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, string(buf_bar-code.b-code) ).
    end.

    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.

    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = buf_bar-code.in-code no-error .
    if available buf_trn-doc then
    return substitute("trn-doc объект &1&2 Номер документа &3",
                       buf_trn-doc.obj-type, string(buf_trn-doc.obj-code),  buf_trn-doc.doc-code   ).

    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1", buf_prod-bc.b-str).

    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1", buf_prod-bc-db.b-str).

    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1", buf_sert-join.sert-code).

    /*теперь пройдемся по объектам*/
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).
    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).
    find first buf_price-doc-forming-gds no-lock where
            buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.


    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-used-bar-code */


procedure block-del-ucli-bar-code :
/*блокирование бар-кода доп единицы измерения для последующего удаления*/
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .
    define variable l-terminal-prt     as logical no-undo .
    define variable l-is-used          as logical no-undo init yes.
    define variable v-prod-bc          as character no-undo .
    define variable v-bar-code         as integer   no-undo .
    define variable v-old-stts         as integer no-undo .

    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_prod-bc for ub.prod-bc .
    define buffer buf_gds-prt for ub.gds-prt.
    define buffer buf_units-base for ub.units.
    define buffer buf_units-cli for ub.units.
    define buffer buf_goods for ub.goods.


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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    assign
      v-bar-code = integer( entry( 2, pc-uniq-key-rec, {&delim-key} ) )
      v-old-stts = integer( entry( 8, pc-parameters, {&delim-par} ) )
    .

    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .

    if not available buf_bar-code then do:
      run gen-bc in this-procedure
        ( input v-bar-code
         ,output v-prod-bc
        ).
      find first buf_prod-bc exclusive-lock
        where buf_prod-bc.b-str = v-prod-bc
        no-error.
      if available buf_prod-bc then do:
        /* на всякий случай проверим, вдруг есть еще один prod-bc с таким же b-str */
        find next buf_prod-bc share-lock
          where buf_prod-bc.b-str = v-prod-bc
          no-error.
        if available buf_prod-bc then do:
          return error substitute( "&1. Системная ошибка!!! Найдено несколько порожденных Доп.БК с одинаковыми кодами (&2)", vss-workfile, v-prod-bc) .
        end.
        else do:
          assign
            pc-err-msg = substitute( "Бар-код &1 был преобразован в Доп.БК &2!", v-bar-code, v-prod-bc )
          .
          return .
        end.
      end.
      else do:
        return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
      end.
    end.

    if buf_bar-code.stts = integer({&hn-delete}) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.

    if buf_bar-code.stts_ <> 0
    and not buf_bar-code.stts_ = integer({&hn-switch-off})
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.

    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          ,output v-is-ucli-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп. ед.изм: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп.ед.изм.", vss-workfile, buf_bar-code.b-code ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
        /*взводим статус*/
        assign
        buf_bar-code.stts_ = integer({&hn-delete})
        .
        /*проверяем на использование*/
        run proc-is-used-ucli-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, output l-is-used) no-error .
        if error-status :error
        then do:
          undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                         , vss-workfile
                                         , buf_bar-code.b-code
                                         , {&new-line}
                                         , error-status:get-message(1)
                                         ).
        end.
        if l-is-used then do:
                  assign
          buf_bar-code.stts_ = v-old-stts
          pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , {&new-line}
                                    , return-value
                                     )
          .
          return pc-err-msg.
        end.
    end.
  end.

end procedure. /* block-del-prt-bar-code */


procedure delete-ucli-bar-code :
/*удаление несипользуемого бар-кода на доп ед изм*/
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .

  main-block:
  do
  on error undo main-block, return error
  :

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical   no-undo .

    define buffer buf_bar-code         for ub.bar-code .
    define buffer buf_bar-code-attr    for ub.bar-code-attr .
    define buffer buf_bar-code-obj-attr    for ub.bar-code-obj-attr .
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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
     assign
     v-b-code = integer(entry(1, pe-parameters, {&delim-par}))
     .
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.

    if not available buf_bar-code
    and not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.

    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.

    /*проверим что бар-код заблокирован*/
    if buf_bar-code.stts_ <> integer({&hn-delete}) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.
    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          , output v-is-ucli-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп.ед.изм.: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.

    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп.ед.изм.", vss-workfile, buf_bar-code.b-code).
    end.

    /*проверяем на использование*/
    run proc-is-used-ucli-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo main-block, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , {&new-line}
                                     , error-status:get-message(1)
                                     ).
    end.
    if l-is-used then do:
      undo main-block, return error substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , {&new-line}
                                    , return-value
                                    ).
    end.
    for each buf_bar-code-attr share-lock where
            buf_bar-code-attr.b-code = buf_bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-attr.
    end.
    for each buf_bar-code-obj-attr share-lock where
            buf_bar-code-obj-attr.b-code = buf_bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-obj-attr.
    end.
    do
    on error undo main-block, return error
    on stop undo main-block, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure. /* delete-ucli-bar-code */


procedure undo-delete-ucli-bar-code :
/*откат блокировки бар-кода*/
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .

    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .

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
    if v-tbl-name <> {&table_bar-code} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.

    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, {&delim-par}))
      v-old-stts = integer(entry(8, pr-parameters, {&delim-par}))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
      end.
    end.

    do
    on error undo, return error
    on stop undo, return error
    :

      if buf_bar-code.stts_ = integer({&hn-delete}) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
    end.
  end.

end procedure. /* undo-delete-ucli-bar-code */


procedure proc-is-used-ucli-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
/*по умолчанию всегда используется!!!!*/

  do
  on error undo, return error
  :

    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .

    define buffer buf_goods for ub.goods.
    define buffer buf_prt-obj for ub.prt-obj.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_scales-gds for ub.scales-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_ord-dtl for ub.ord-dtl.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.
    define buffer buf_ord-dtl-rcv for ub.ord-dtl-rcv.
    define buffer buf_tmp-sale-dtl for ub.tmp-sale-dtl.

    /*нет ли чего в таблицах независящих от объекта*/

    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          , output v-is-ucli-bar-code) no-error .

    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп.ед.изм.: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.

    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп ед.изм.", vss-workfile, buf_bar-code.b-code).
    end.

    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.

    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).

    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1" + buf_prod-bc-db.b-str).

    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1" + buf_sert-join.sert-code).

    /*теперь пройдемся по объектам*/
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).

    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).

    find first buf_price-doc-forming-gds no-lock where
              buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.


    assign
    p-is-used = no
    .
    return "":U.
  end.

end procedure. /* proc-is-used-ucli-bar-code */