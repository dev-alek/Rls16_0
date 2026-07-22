block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка команды отсылки настроек машины правил (для объекта TH)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/20/08
Author: Bakhtadze Natalya
Creation date: 05/20/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-counter  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка команды отсылки настроек машины правил (для объекта TH)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/waitfram.i }
{ cmp/strcodec.i }

&glob add-dump ~
if v-run-parovoz then do : ~
run add-dump in v-cmd-proc-handle                                                                            ~
  (input v-cmd-code                                                                                          ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input '':U                                                                                                ~
  ,output v-rec-ord                                                                                          ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure v-cmd-proc-handle .                                                                         ~
  undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,v-cmd-code                                                            ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end.                                                                                                         ~
end



define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo .
define variable v-action as character no-undo .
define variable v-curr-rowid as rowid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-db-list     as character no-undo .
define variable v-command     as character no-undo .
define variable v-cmd-code    as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-run-parovoz as logical no-undo .
define variable v-rec-ord as recid no-undo .
define variable v-is-obj as logical no-undo .
define variable v-obj-db-num as integer no-undo .
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code v-cmd-code
define buffer buf_schedule for ub.schedule.
define buffer buf_db for ub.db.

define temp-table temp-thbj-attr no-undo like ub.thbj-attr
field action  as integer
.
define buffer buf_temp-thbj-attr for temp-thbj-attr.
define buffer buf_thbj-attr for ub.thbj-attr.

define temp-table temp-prop-ref-call no-undo like ub.prop-ref-call
field action as integer
.

define temp-table temp-rule-call-param no-undo like ub.rule-call-param
field action as integer
.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.


define temp-table temp-rule-by-call no-undo like ub.rule-by-call
field action as integer
.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.


define temp-table temp-rp-by-call no-undo like ub.rp-by-call
field action as integer
.
define buffer buf_temp-rp-by-call for temp-rp-by-call .
define buffer buf_rp-by-call for ub.rp-by-call.


define buffer buf_temp-prop-ref-call for temp-prop-ref-call.
define buffer buf_prop-ref-call for ub.prop-ref-call.

main-block:
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run waitfram-show in this-procedure
      (input substitute("Получение настроек машины правил. &1 Получено записей: &2"
                        , p-uniq-key-rec
                        , counter)
      ) .
    /*заблокируем основную запись*/
    if counter = 1 then do:
    run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                          ,input  "ub"
                                          ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                          ,input  EXCLUSIVE-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name   ) .

    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
      v-action = entry(2, rec-full, {&delim-nws})
    .
    CASE v-rec-name :
      when {&table_thbj-attr}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_thbj-attr}
            ,input '':U
            ,input (buffer buf_temp-thbj-attr:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        define variable v-field-list as character no-undo .
        define variable v-value-list as character no-undo .
        define variable v-obj-type as character no-undo .
        define variable v-obj-code as integer no-undo .
        run  gen-key-fv in this-procedure ( input p-uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        if lookup("obj-type", v-field-list, {&delim-key}) > 0 then do:
          assign
          v-obj-type = entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
          v-obj-code = integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) )
          v-is-obj = not (v-obj-type = '' and v-obj-code = 0)
          .
        end.
      end.
      when {&table_rule-call-param}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rule-call-param}
            ,input '':U
            ,input (buffer buf_temp-rule-call-param:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-call-param where
                    rowid(buf_temp-rule-call-param) = v-curr-rowid.
          buf_temp-rule-call-param.action = integer({&hn-delete}).
        end.
      end.
      when {&table_rule-by-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rule-by-call}
            ,input '':U
            ,input (buffer buf_temp-rule-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-by-call where
                    rowid(buf_temp-rule-by-call) = v-curr-rowid.
          buf_temp-rule-by-call.action = integer({&hn-delete}).
        end.
      end.
      when {&table_rp-by-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rp-by-call}
            ,input '':U
            ,input (buffer buf_temp-rp-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rp-by-call where
                    rowid(buf_temp-rp-by-call) = v-curr-rowid.
          buf_temp-rp-by-call.action = integer({&hn-delete}).
        end.
      end.
      when {&table_prop-ref-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_prop-ref-call}
            ,input '':U
            ,input (buffer buf_temp-prop-ref-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-prop-ref-call where
                    rowid(buf_temp-prop-ref-call) = v-curr-rowid.
          buf_temp-prop-ref-call.action = integer({&hn-delete}).
        end.
      end.
      otherwise do:
        run waitfram-hide in this-procedure .
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          "в составе команды" {&cmd-dct-send} skip
          view-as alert-box error .
        return error .
      end.

    END CASE.
  end. /*do counter*/
  run waitfram-show in this-procedure ( substitute("           Обновление информации по &1:"
                                                   , p-uniq-key-rec
                                                   )
                                       ).
  if p-uniq-key-rec begins {&table_schedule}
  or (p-uniq-key-rec begins {&table_thbj-attr} and v-is-obj)
  and p-counter > 0
  then do:
    /*найдем schedule*/
    case entry(1, p-uniq-key-rec, {&delim-key}):
      when {&table_schedule} then do:
        find first buf_schedule no-lock where
                  rowid(buf_schedule) = v-tbl-row no-error.
        /*првоерим нужно ли запускать паровоз*/
        if not available buf_schedule
        and g#db-num = 0
        then do:
          v-run-parovoz = no.   /* Убран паровоз как засоряющий эфир*/
        end.
        else do:
          if g#db-num = 0 then do:
            if buf_schedule.cre-db-num = g#news-source-db
            then do:
              /*нолвости пришли из той бд где поменяли настройки*/
              v-run-parovoz = no.  /* Убран паровоз как засоряющий эфир*/
            end.
            else do:
              v-run-parovoz = no.
            end.
          end. /*if g#db-num = 0 then do:*/
        end.
      end.
      when {&table_thbj-attr} then do:
        find first buf_thbj-attr no-lock where
                  rowid(buf_thbj-attr) = v-tbl-row no-error.
        /*првоерим нужно ли запускать паровоз*/
        if not available buf_thbj-attr
        and g#db-num = 0
        then do:
          v-run-parovoz = yes.
        end.
        else do:
          if g#db-num = 0 then do:
            { gbl/objdbnum.i buf_thbj-attr.obj-type buf_thbj-attr.obj-code v-obj-db-num }
            if v-obj-db-num = g#news-source-db
            then do:
              /*нолвости пришли из той бд где поменяли настройки*/
              v-run-parovoz = yes.
            end.
            else do:
              v-run-parovoz = no.
            end.
          end. /*if g#db-num = 0 then do:*/
        end.
      end.
    end.
    if v-run-parovoz then do:
      if not valid-handle(v-cmd-proc-handle ) then dO:
        /* инициализируем библиотеку формирования команды */
        run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                              "&5&4&6"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,error-status:get-message(1)
                                              ,return-value ).
        end. /*if error-status:error then do:*/
      end. /*if not valid-handle(v-cmd-proc-handle ) then dO:*/
      assign
      v-command =  substitute("&2&1&3&1"
                            , {&delim-cmd}
                            , {&cmd-rum-send}
                            ,  str-encode( p-uniq-key-rec
                                          , "" /*p-encode-char*/
                                          , {&delim-key})
                            ).
      if g#db-num = 0 then do:
        for each buf_db no-lock:
          if buf_db.db-num = 0 then next.
          if g#news
           and buf_db.db-num = g#news-source-db 
          then next.
          assign
          v-db-list = v-db-list + {&delim-nws} + string(buf_db.db-num).
          v-db-list = trim(v-db-list, {&delim-nws}).
        end.
      end.
      else do:
        assign
        v-db-list = string(0)
        .
      end.
      run begin-create-command in v-cmd-proc-handle
        (input  v-command /* p-command-name */
        ,INPUT  v-db-list
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
                                            ,{&cmd-rum-send}
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end. /*if error-status :error*/
    end. /*if v-run-parovoz then do:*/
  end. /*if p-uniq-key-rec begins {&table_schedule} then do*/

  for each buf_temp-rp-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rp-by-call where
              buf_rp-by-call.call#_id = buf_temp-rp-by-call.call#_id
          and buf_rp-by-call.profile_id = buf_temp-rp-by-call.profile_id
          and buf_rp-by-call.once-more = buf_temp-rp-by-call.once-more
          no-error .
    if buf_temp-rp-by-call.action = integer({&hn-delete}) then do:
      if not available buf_rp-by-call then do:
      end.
      else do:
  &scop table__  ~{&table_rp-by-call~}
  &scop buffer-handle  buffer buf_rp-by-call:handle
  &scop action__ '+delete'
      {&add-dump}.

        delete buf_rp-by-call.
      end.
    end.
    else do:
      if not available buf_rp-by-call then do:
          find first buf_rp-by-call where
              buf_rp-by-call.call_id = buf_temp-rp-by-call.call_id
          and buf_rp-by-call.profile_id = buf_temp-rp-by-call.profile_id
          and buf_rp-by-call.once-more = buf_temp-rp-by-call.once-more
          no-error .
          if not available buf_rp-by-call then
          create buf_rp-by-call.
      end.
      buffer-copy buf_temp-rp-by-call to buf_rp-by-call.
  &scop table__  ~{&table_rp-by-call~}
  &scop buffer-handle  buffer buf_rp-by-call:handle
  &scop action__ '+update'
      {&add-dump}.
    end.
  end.
  for each buf_temp-rule-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-by-call where
              buf_rule-by-call.call#_id = buf_temp-rule-by-call.call#_id
          and buf_rule-by-call.codex_id = buf_temp-rule-by-call.codex_id
          and buf_rule-by-call.ruleset_id = buf_temp-rule-by-call.ruleset_id
          and buf_rule-by-call.order_id = buf_temp-rule-by-call.order_id  no-error .
    if buf_temp-rule-by-call.action = integer({&hn-delete}) then do:
      if not available buf_rule-by-call then do:
      end.
      else do:
  &scop table__  ~{&table_rule-by-call~}
  &scop buffer-handle  buffer buf_rule-by-call:handle
  &scop action__ '+delete'
      {&add-dump}.
        delete buf_rule-by-call.
      end.
    end.
    else do:
      if not available buf_rule-by-call then do:
          create buf_rule-by-call.
      end.
      buffer-copy buf_temp-rule-by-call to buf_rule-by-call.
  &scop table__  ~{&table_rule-by-call~}
  &scop buffer-handle  buffer buf_rule-by-call:handle
  &scop action__ '+update'
      {&add-dump}.
    end.
  end.
  for each buf_temp-rule-call-param
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-call-param where
              buf_rule-call-param.call#_id = buf_temp-rule-call-param.call#_id
          and buf_rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and buf_rule-call-param.param-name = buf_temp-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_temp-rule-call-param.p-index    no-error .
    if buf_temp-rule-call-param.action = integer({&hn-delete}) then do:
      if not available buf_rule-call-param then do:
      end.
      else do:
  &scop table__  ~{&table_rule-call-param~}
  &scop buffer-handle  buffer buf_rule-call-param:handle
  &scop action__ '+delete'
      {&add-dump}.
        delete buf_rule-call-param.
      end.
    end.
    else do:
      if not available buf_rule-call-param then do:
         find first buf_rule-call-param where
              buf_rule-call-param.call_id = buf_temp-rule-call-param.call_id
          and buf_rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and buf_rule-call-param.param-name = buf_temp-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_temp-rule-call-param.p-index    no-error .
          if not available buf_rule-call-param then
          create buf_rule-call-param.
      end.
      buffer-copy buf_temp-rule-call-param to buf_rule-call-param.
  &scop table__  ~{&table_rule-call-param~}
  &scop buffer-handle  buffer buf_rule-call-param:handle
  &scop action__ '+update'
      {&add-dump}.
    end.
  end.
  for each buf_temp-prop-ref-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_prop-ref-call where
              buf_prop-ref-call.call#_id = buf_temp-prop-ref-call.call#_id
          and buf_prop-ref-call.dt-code = buf_temp-prop-ref-call.dt-code no-error .
    if buf_temp-prop-ref-call.action = integer({&hn-delete}) then do:
      if not available buf_prop-ref-call then do:
      end.
      else do:
  &scop table__  ~{&table_prop-ref-call~}
  &scop buffer-handle  buffer buf_prop-ref-call:handle
  &scop action__ '+delete'
      {&add-dump}.

        delete buf_prop-ref-call.
      end.
    end.
    else do:
      if not available buf_prop-ref-call then do:
          create buf_prop-ref-call.
      end.
      buffer-copy buf_temp-prop-ref-call to buf_prop-ref-call.
  &scop table__  ~{&table_prop-ref-call~}
  &scop buffer-handle  buffer buf_prop-ref-call:handle
  &scop action__ '+update'
      {&add-dump}.

    end.
  end.
  for each buf_temp-thbj-attr
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_thbj-attr where
             buf_thbj-attr.upper-prop-code = buf_temp-thbj-attr.upper-prop-code
         and buf_thbj-attr.prop-code = buf_temp-thbj-attr.prop-code
         and buf_thbj-attr.obj-type = buf_temp-thbj-attr.obj-type
         and buf_thbj-attr.obj-code = buf_temp-thbj-attr.obj-code no-error.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
    end.
    buffer-copy buf_temp-thbj-attr to buf_thbj-attr.
  &scop table__  ~{&table_thbj-attr~}
  &scop buffer-handle  buffer buf_thbj-attr:handle
  &scop action__ '+update'
      {&add-dump}.
  end.
  if v-run-parovoz then do:
    run send-command in v-cmd-proc-handle
       ( input v-cmd-code  /* p-command-code */
        ,input v-db-list
        ) no-error .
    if error-status:error then do:
      delete procedure v-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", {&cmd-rum-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    delete procedure v-cmd-proc-handle .
  end.
  run waitfram-hide in this-procedure .
  return ''.
end. /*doe*/

procedure write-to-log : /*не удалять!!!*/
define input parameter p-mess as character no-undo .

  do
  on error undo, return error
  :

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.

end procedure. /* write-to-log */