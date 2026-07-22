block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11, набор 10

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/09
Author: Bakhtadze Natalya
Creation date: 10/12/09

---------------------------&start-codex_id=11;ruleset_id=10;-------------------------------
Операции с товарами
Операции с товарами в автоматическом режиме
---------------------------&end-codex_id=11;ruleset_id=10;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11, набор 10".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/key-rec.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/obj-list.i new }
{ str/runanlst.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code as integer no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "shd-free.log".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-err-mess as character no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define stream ext-file.

{ str/dia2auto.i }
{ rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


&scop send-message ~
          if valid-handle(p-log-handle) then ~
          run send-msg-to-email in p-log-handle ( ~
                input substitute( "ТН БД &1. Операции с товарами в автоматическом режиме - пересылка/удаление на кассу/с укассы" ~
                                        , g#db-num) ~
              , input ~{&my-message} ~
              , input ~{&attach-file-list}~)



/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-method as character no-undo.
  define variable p-action as character no-undo .
  define variable p-list as character no-undo .
  define variable p-list-macro as character no-undo .

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/



/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

define variable v-err as logical no-undo .
define variable f-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable imp-type as character no-undo .
define variable imp-code  as integer no-undo .
define variable imp-art as character no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-ii as integer no-undo .
define variable v-host-code as integer no-undo .


define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_goods for ub.goods.



/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/

/* чистим лог файл */
run gbl/filename.p
  (input "send-cd.txt"
  ,output v-full-path         /* p-full-path        */
  ,output v-path              /* p-path             */
  ,output v-file-name         /* p-file-name        */
  ,output v-file-name-no-ext  /* p-file-name-no-ext */
  ,output v-file-name-ext     /* p-file-name-ext    */
  ) no-error .
os-delete value(v-full-path).

case p-method:
  when {&lob-res-list} then do:
    find first buf_clob-bind no-lock where
              buf_clob-bind.resource-type = p-method
         and  buf_clob-bind.uniq-key-rec = entry(1, p-list, "_")
         and  buf_clob-bind.field-name_ = entry(2, p-list, "_") no-error.
    if not available buf_clob-bind then do:
      &scop my-message substitute("Не найдена ссылка на хранимый в БД список товаров &1", p-list)
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return error.
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      &scop my-message substitute("Не найден хранимый в БД список товаров &1", p-list)
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return error.
    end.
    run gbl/_tmpfile.p ( input ""
                  ,input "tmp"
                  ,output f-name) .
    copy-lob from object buf_clob-data.cdata
    to file f-name.
    run gbl/filename.p
      (input  f-name
      ,output v-full-path         /* p-full-path        */
      ,output v-path              /* p-path             */
      ,output v-file-name         /* p-file-name        */
      ,output v-file-name-no-ext  /* p-file-name-no-ext */
      ,output v-file-name-ext     /* p-file-name-ext    */
      ) no-error .
    if error-status:error then do:
      &scop my-message substitute("Не удалось получить хранимый в БД список товаров &1 из временного файла &2&3&4&3&5" ~
                                  , p-list ~
                                  , f-name ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1)  ~
                                  , return-value  )
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return error.
    end.
    input stream ext-file from value (v-full-path).
    repeat:
      imp-type = ''.
      v-ii = v-ii + 1.
      import stream ext-file imp-type imp-code imp-art no-error.
      if error-status:error
      and (imp-type <> ''
           or v-ii = 1) then do:
        input stream ext-file close.
        &scop my-message substitute("Не удалось загрузить хранимый в БД список товаров &1 из временного файла &2&3&4Неверный формат" ~
                                    , p-list ~
                                    , f-name ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1) )
        &scop attach-file-list ''
        {&display-message}.

        {&send-message}.
        return error.
      end.
      find first buf_goods where buf_goods.prod-type = imp-type
                  and buf_goods.prod-code = imp-code
                  and buf_goods.artic     = imp-art no-lock no-error.
      if available buf_goods then do:
         { cmp/gds-list.i gds-list assign " " buf_goods}
      end.
    end.
    input stream ext-file close.
    os-delete value(v-full-path) .
    if can-find(first gds-list no-lock) then do:
      for each obj-list:
        run str/diallog.w ( input parparentproc
                    , input this-procedure
                    , input (if p-action = "U" then 'str/send-gds.p':U else "str/del-gds.p ")
                    , input (if p-action = "U"
                             then ( string( - obj-list.obj-code) + {&delim-par} +  "no":U)
                             else string(obj-list.obj-code) + {&delim-par} + {&question-mark})
                    , input yes /*p-auto-go*/
                    , input ''
                    , input (if p-action = "U"
                      then substitute('Отсылка товаров на кассу маг &1', obj-list.obj-code)
                      else substitute("Удаление товаров с кассы маг &1", obj-list.obj-code)
                          )
                      ) no-error .
        if error-status:error
        then do:
          &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы списка товаров по расписанию: Ошибка в процессе отсылки на кассы маг&1"  ~
                                          , obj-list.obj-code )
          v-full-path = ''.
          run gbl/filename.p (
                        input "send-cd.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .

          &scop attach-file-list v-full-path
          {&display-message}.
          {&send-message}.
        end.
      end. /*for each obj-list:*/
    end. /*if can-find(first gds-list no-lock) then do:*/
    else do:
      &scop my-message substitute(" При отсылке/удалении на кассу/с кассы списка товаров по расписанию в списке не было обнаружено товаров: Ошибка в процессе отсылки на кассы маг&1"  ~
                                          , obj-list.obj-code )
      {&display-message}.
  end.
  end. /*when {&lob-res-list} then do:*/
  when {&lob-res-list-macro} then do:
    define variable v-id as integer no-undo .
    for each macro-list-hist:
      delete macro-list-hist.
    end.
    for each gds-list-hist:
      delete gds-list-hist.
    end.
    find first buf_clob-bind no-lock where
              buf_clob-bind.resource-type = p-method
         and  buf_clob-bind.uniq-key-rec = entry(1, p-list-macro, "_")
         and  buf_clob-bind.field-name_ = entry(2, p-list-macro, "_") no-error.
    if not available buf_clob-bind then do:
      &scop my-message substitute("Не найдена ссылка на хранимый в БД макрос формирования списка товаров &1", p-list-macro)
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return ''.
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      &scop my-message substitute("Не найден хранимый в БД макрос формирования списка товаров &1", p-list-macro)
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return error.
    end.
    run gbl/_tmpfile.p ( input ""
                  ,input "tmp"
                  ,output f-name) .
    copy-lob from object buf_clob-data.cdata
    to file f-name.
    run gbl/filename.p
      (input  f-name
      ,output v-full-path         /* p-full-path        */
      ,output v-path              /* p-path             */
      ,output v-file-name         /* p-file-name        */
      ,output v-file-name-no-ext  /* p-file-name-no-ext */
      ,output v-file-name-ext     /* p-file-name-ext    */
      ) no-error .
    if error-status:error then do:
      &scop my-message substitute("Не удалось получить хранимый в БД макрос формирования списка товаров &1 из временного файла &2&3&4&3&5" ~
                                  , p-list-macro ~
                                  , f-name ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1)  ~
                                  , return-value  )
      &scop attach-file-list ''
      {&display-message}.
      {&send-message}.
      return error.
    end.
    input stream ext-file from value (v-full-path).
    _macro:
    repeat:
      v-ii = v-ii + 1.
      create macro-list-hist.
      import stream ext-file macro-list-hist no-error.
      if error-status:error then do:
        &scop my-message substitute("Не удалось загрузить хранимый в БД список товаров &1 из временного файла &2&3&4Неверный формат" ~
                                    , p-list ~
                                    , f-name ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1) )
        &scop attach-file-list ''
        input stream ext-file close.
        {&display-message}.
        {&send-message}.
        return error .
      end.
      assign
      macro-list-hist.num-rec = 0
      macro-list-hist.num-add = 0
      macro-list-hist.num-ignored = 0
      v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
      macro-list-hist.done = no
      .
    end. /*repeat*/
    find first macro-list-hist where
            macro-list-hist.id = 0.
    delete macro-list-hist.
    input stream ext-file close.
    os-delete value(v-full-path).
    for each obj-list:
      empty temp-table gds-list.
      { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
      run str/gdsqlist.w (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input v-host-code
                      ,input obj-list.obj-type
                      ,input obj-list.obj-code
                      ,input 'hide' /*bttns*/
                      ,input substitute("Товары, отобранные макросом из файла &1", v-file-name)
                      ,input yes
                      ) no-error.
      if error-status:error then do:
        &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы списка товаров по расписанию: Ошибка при заполнении списка товаров согласно макросу&1&2"  ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) )
        &scop attach-file-list ''
        {&display-message}.
        {&send-message}.
        input stream ext-file close.
        return error .
      end.
      if can-find (first gds-list) then do:
        run str/diallog.w ( input parparentproc
                    , input this-procedure
                    , input (if p-action = "U" then 'str/send-gds.p':U else "str/del-gds.p ")
                    , input (if p-action = "U"
                             then ( string( - obj-list.obj-code) + {&delim-par} +  "no":U)
                             else string(obj-list.obj-code) + {&delim-par} + {&question-mark})
                    , input yes /*p-auto-go*/
                    , input ''
                    , input (if p-action = "U"
                              then substitute('Отсылка товаров на кассу маг&1', obj-list.obj-code)
                              else substitute('Удаление товаров с кассы маг&1', obj-list.obj-code)
                          )
                      ) no-error .
       if error-status:error
       then do:
        &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы списка товаров по расписанию: Ошибка в процессе отсылки на кассы маг&1"  ~
                                        , obj-list.obj-code )
        v-full-path = ''.
        run gbl/filename.p (
                      input "send-cd.txt"
                      ,output v-full-path
                      ,output v-path
                      ,output v-file-name
                      ,output v-file-name-no-ext
                      ,output v-file-name-ext
                      ) no-error .

        &scop attach-file-list v-full-path
        {&display-message}.
        {&send-message}.
        end. /*        if error-status:error*/
      end. /*if can-find (first gds-list) then do:*/
      else do:
      &scop my-message substitute(" При отсылке/удалении на кассу/с кассы списка товаров по расписанию после формирования списка в список не попало ни одного товара: Ошибка в процессе отсылки на кассы маг&1"  ~
                                          , obj-list.obj-code )
      {&display-message}.
      end.
    end. /*for each obj-list:*/
  end. /*when {&lob-res-list-macro} then do:*/
end case.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_clients for ub.clients.

do
on error undo, return error
:

  /*---------------------------&start-process-rule-call-param&-------------------------------*/

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-method"
 no-error.
if available buf_rule-call-param then do:
  assign p-method = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-action"
 no-error.
if available buf_rule-call-param then do:
  assign p-action = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-list"
 no-error.
if available buf_rule-call-param then do:
  assign p-list = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-list-macro"
 no-error.
if available buf_rule-call-param then do:
  assign p-list-macro = buf_rule-call-param.param-value-character.
end.

for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-shops"
and buf_rule-call-param.p-index > 0:
  create buf_temp-rule-call-param.
  buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
  release buf_temp-rule-call-param.
end.


  if not can-find(first temp-rule-call-param where
                 temp-rule-call-param.param-name = "p-shops") then do:
    for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        and buf_clients.db-num = g#db-num:
      run create_obj-list in this-procedure ( input buf_clients.obj-type
                                              ,input buf_clients.obj-code).
    end.
  end.
  else do:
    for each buf_temp-rule-call-param where
           buf_temp-rule-call-param.param-name = "p-shops":
      find first buf_clients no-lock
        where buf_clients.obj-type  = {&shop}
          and buf_clients.obj-code = buf_temp-rule-call-param.param-value-integer
      no-error.
      if not available buf_clients
      then do:
          &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы списка товаров по расписанию&3: Не найден заданный объект &1&2"  ~
                                          , ~{&shop~} ~
                                          , buf_temp-rule-call-param.param-value-integer ~
                                          , ~{&new-line~})
          &scop attach-file-list ''
          {&display-message}.
          {&send-message}.
          undo, return error .
      end.
      else do:
        if buf_clients.db-num = g#db-num
        and buf_clients.obj-type = {&shop}
        then do:
          run create_obj-list in this-procedure ( input buf_clients.obj-type
                                                  ,input buf_clients.obj-code).
        end.
      end.
    end.
  end.


/*---------------------------&end-process-rule-call-param&-------------------------------*/

    case p-ruleset-id:
      when 10 then do:
      end.
      otherwise do:
        undo, return error substitute("Вызов процедуры &1 в неверном контексте", p-rule-id).
      end.
    end case.


end. /*doe*/

end procedure. /* load-ruleset-context */

procedure cb_get-gds-list :
define input parameter p-handle as handle no-undo .
for each gds-list:
  run cb_set-gds-list in p-handle ( input (buffer gds-list:handle)).
end.
end procedure. /* set-gds-list */

procedure cb_set-view-log :
define input parameter p-view-log as logical no-undo .

v-view-log = yes.
end procedure. /* cb_set-view-log */
