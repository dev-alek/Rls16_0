block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение изменений RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/20/08
Author: Bakhtadze Natalya
Creation date: 05/20/08

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.

define input parameter par-mode as character no-undo .
define input parameter p-profile-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter parhost-code like ub.dis-card-type.host-code no-undo .
define input parameter parobj-type like ub.dis-card-type.obj-type no-undo .
define input parameter parobj-code like ub.dis-card-type.obj-code no-undo .
define input parameter p-value-logical as logical no-undo .
define input parameter table for tt0-rp-by-call.
define input parameter table for tt0-rule-by-call.
define input parameter table for tt0-rule-call-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение изменений в для привязки профайла и т.д.".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/key-rec.i }
{ cmp/strcodec.i }

&glob add-dump ~
if v-to-send then do:                                                                                      ~
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
  undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
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

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE VAR-ENTRY as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
define variable vardeleted   as logical   no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-ok as logical no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-cmp as logical no-undo .
define variable v-cmp-loc as logical no-undo .
define variable v-last as integer no-undo .
define variable v-rec-ord as integer no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-to-send as logical no-undo .
define variable v-db-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-call-id-list as character no-undo .
define variable v-profile-type-list as character no-undo .
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_db for ub.db.
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_schedule for ub.schedule.

if g#db-num > 0
and not(p-uniq-key-rec begins {&table_schedule})
then do:
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
    .
  end.
  if v-obj-type = '' and v-obj-code = 0 then do:
  message  vss-workfile vss-revision vss-description skip
            "Вызов процедуры сохранения привязкок машины правил в глобальном контексте в УБД запрещен"
  view-as alert-box ERROR.
  return error '':u.
end.
end.

if par-mode <> {&add-def} AND par-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.

_MAIN:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  run gen-row-keyr in this-procedure (
                                        input  p-uniq-key-rec
                                      ,input  ? /* p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                      ,input  "ub"
                                      ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                      ,input  EXCLUSIVE-LOCK
                                      ,output v-tbl-row
                                      ,output v-tbl-name
                                      ).
   case entry(1, p-uniq-key-rec, {&delim-key}):
     when {&table_thbj-attr} then do:
      find first buf_thbj-attr EXclusive-lock where
                  rowid(buf_thbj-attr) = v-tbl-row no-wait no-error.
     end.
     when {&table_schedule} then do:
      find first buf_schedule EXclusive-lock where
                  rowid(buf_schedule) = v-tbl-row no-wait no-error.
     end.
     otherwise do:
       message
       substitute("Неизвестный тип привязки для RUM=&1", entry(1, p-uniq-key-rec, {&delim-key}))
       view-as alert-box error .
       undo _main, return error ''.
     end.
   end case.
    if entry(1, p-uniq-key-rec, {&delim-key}) = {&table_schedule} then do:
      if available buf_schedule
      then do :
        if buf_schedule.cre-db-num > 0 then do:
          if g#db-num > 0 then do:
            v-db-list = string(0).
          end.
          else do:
            v-db-list = string(buf_schedule.cre-db-num).
          end.
          v-to-send = yes.
        end.
        else do:
          /*не шлем никуда*/
        end.
      end.
      else do :
        if integer(entry(2, p-uniq-key-rec, {&delim-key})) > 0 then do :
          if g#db-num > 0 then do:
            v-db-list = string(0).
          end.
          else do:
            v-db-list = entry(2, p-uniq-key-rec, {&delim-key}).
          end.
          v-to-send = yes.
        end.
        else do :
          /*не шлем никуда*/
        end.
      end.
    end.
    else do:
    if g#db-num = 0 then do:
      for each buf_db no-lock
      where buf_db.db-num > 0
      :
        assign
        v-db-list = v-db-list + {&delim-nws} + string(buf_db.db-num).
      end.
    end.
    else do:
      v-db-list = string(0).
    end.
    v-db-list = trim(v-db-list, {&delim-nws}).
    v-to-send = yes.
   end.
   if v-to-send then do:
   if not valid-handle(v-cmd-proc-handle ) then dO:
    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo _main, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.

  /* начало формирования команды */
  assign
  v-command =  substitute("&2&1&3&1"
                         , {&delim-cmd}
                         , {&cmd-rum-send}
                         ,  str-encode( p-uniq-key-rec
                                       , "" /*p-encode-char*/
                                       , {&delim-key})
                         ).
  run begin-create-command in v-cmd-proc-handle
    (input v-command /* p-command-name */
    ,input "":U                /* p-db-list      */
    ,output v-cmd-code        /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", {&cmd-rum-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo _main, return error return-value .
  end.
  end.
  assign
  v-call-id-list = p-uniq-key-rec
  v-profile-type-list = p-profile-type
  .
  if p-profile-type = {&cmb} then do:
    define variable v-cmb-profile-id as integer no-undo .
    define variable v-current-uniq-key-rec as character no-undo .
    define buffer buf_rp-by-call for ub.rp-by-call.
    define buffer buf2_rule-profile for ub.rule-profile.
    define buffer tt02-rp-by-call for tt0-rp-by-call.
    define buffer buf_profile-by-profile for ub.profile-by-profile.
    /*если былыо добавление изменение такого профайла*/
    for each tt0-rp-by-call where tt0-rp-by-call.call_id = p-uniq-key-rec,
        first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = tt0-rp-by-call.profile_id:
      if buf_rule-profile.profile-type = {&cmb} then do:
        v-cmb-profile-id = buf_rule-profile.profile_id.
      end.
      for each tt02-rp-by-call where
               tt02-rp-by-call.parent-profile_id = v-cmb-profile-id
           and tt02-rp-by-call.parent-once-more = tt0-rp-by-call.once-more ,
          first buf2_rule-profile no-lock where
                buf2_rule-profile.profile_id = tt02-rp-by-call.profile_id:
        if lookup(tt02-rp-by-call.call_id, v-call-id-list, {&delim-par}) = 0
        or (lookup(tt02-rp-by-call.call_id, v-call-id-list, {&delim-par}) > 0
        and entry(lookup(tt02-rp-by-call.call_id, v-call-id-list, {&delim-par}), v-profile-type-list) <> buf_rule-profile.profile-type
        )
        then
        assign
        v-call-id-list = v-call-id-list +  {&delim-par} + tt02-rp-by-call.call_id
        v-profile-type-list = v-profile-type-list + {&comma-char} + buf2_rule-profile.profile-type
        .
      end.
    end.
    /*если было удаление такого профайла*/
    for each buf_rp-by-call where buf_rp-by-call.call_id = p-uniq-key-rec,
        first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = buf_rp-by-call.profile_id:
      if buf_rule-profile.profile-type = {&cmb} then do:
        v-cmb-profile-id = buf_rule-profile.profile_id.
      end.
      for each buf_profile-by-profile no-lock where
              buf_profile-by-profile.profile_id = v-cmb-profile-id,
          first buf2_rule-profile no-lock where
                buf2_rule-profile.profile_id = buf_profile-by-profile.child-profile_id:
        assign
        v-current-uniq-key-rec = p-uniq-key-rec.
        entry(lookup({&cmb}, p-uniq-key-rec, {&delim-key}), v-current-uniq-key-rec, {&delim-key}) = buf2_rule-profile.profile-type.
        if lookup(v-current-uniq-key-rec, v-call-id-list, {&delim-par}) = 0
        or (lookup(v-current-uniq-key-rec, v-call-id-list, {&delim-par}) > 0
        and entry(lookup(v-current-uniq-key-rec, v-call-id-list, {&delim-par}), v-profile-type-list) <> buf2_rule-profile.profile-type
        )
        then
        assign
        v-call-id-list = v-call-id-list +  {&delim-par} + v-current-uniq-key-rec
        v-profile-type-list = v-profile-type-list + {&comma-char} + buf2_rule-profile.profile-type
        .
      end.
    end.
  end. /*if p-profile-type = {&cmb} then do */
  do v-ii = 1 to num-entries(v-call-id-list, {&delim-par}):
  run rul/ruprcall.p (
                         input entry(v-ii, v-profile-type-list)
                        ,input entry(v-ii, v-call-id-list, {&delim-par} )
                      ,input ({&table_rp-by-call} + {&comma-char} + {&table_rule-by-call} + {&comma-char} + {&table_rule-call-param})
                      ,input v-cmd-proc-handle
                      ,input v-cmd-code
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    if valid-handle(v-cmd-proc-handle) then do:
    delete procedure v-cmd-proc-handle .
    end.
    message
    substitute("Ошибка при сохранении привязок профайлов и/правил для записи &1", p-uniq-key-rec)
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo _main, return error .
  end.
    define buffer term_thbj-attr for ub.thbj-attr.
    if p-value-logical = yes
    and p-profile-type = {&cmb}
    then do:
      case entry(1, entry(v-ii, v-call-id-list, {&delim-par} ), {&delim-key}):
        when {&table_thbj-attr} then do:
          /*найдем*/
          run gen-row-keyr in this-procedure (
                                               input   entry(v-ii, v-call-id-list, {&delim-par} )
                                              ,input  ?
                                              ,input  "ub"
                                              ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                              ,input  EXCLUSIVE-LOCK
                                              ,output v-tbl-row
                                              ,output v-tbl-name  ) .
          find first term_thbj-attr where
                    rowid(term_thbj-attr) = v-tbl-row.
          assign
          term_thbj-attr.property-value-logical = p-value-logical
          .
      &scop table__  ~{&table_thbj-attr~}
      &scop buffer-handle  buffer term_thbj-attr:handle
      &scop action__ '+update'
          {&add-dump}.
        end.
      end case.
    end.
  end.
  case entry(1, p-uniq-key-rec, {&delim-key}):
    when {&table_thbj-attr} then do:
      assign
      buf_thbj-attr.property-value-logical = p-value-logical
      .
&scop table__  ~{&table_thbj-attr~}
&scop buffer-handle  buffer buf_thbj-attr:handle
&scop action__ '+update'
    {&add-dump}.
    end.
  end case.

  if v-to-send then do:
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
    undo _main, return error .
  end.
    delete procedure v-cmd-proc-handle no-error.
  end.
END. /*transaction*/
RETURN '':u.