block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись базы данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

trigger procedure for write of ub.db old buffer old-db.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись базы данных".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/conf-enc.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-message as character no-undo .
  define variable par-type  as character no-undo .  /* тип параметра конфигурации */
  define variable v-ok      as logical   no-undo .
  define variable v-ii      as integer   no-undo .
  define variable v-date    as date      no-undo .
  define variable v-time    as integer   no-undo .

  define buffer buf_sys-ctrl         for ub.sys-ctrl .
  define buffer buf_hist-nws-option  for ub.hist-nws-option.
  define buffer buf2_hist-nws-option for ub.hist-nws-option.
  define buffer buf_c-db             for ub.c-db .

  if g#news = false then do:
    /* проверка уникальности ключа базы данных нельзя проверять в новостях*/
    if ub.db.db-key <> "":U
      and ub.db.db-key <> ?
      and ub.db.db-key <> old-db.db-key
    then do:
      define buffer buf_db for ub.db.
      find first buf_db
        where buf_db.db-key = ub.db.db-key
          and rowid(buf_db) <> rowid(ub.db)
        no-error .
      if available buf_db then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ключ базы должен уникальным" skip
          "Ключ записываемый для базы данных" ub.db.db-num skip
          "Совпадает с ключом для базы данных" buf_db.db-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      run check-enc in this-procedure
        ( input ub.db.db-num
        ,input ub.db.db-key
        ,input ""
        ,input ""
        ,input ?
        ,input ?
        ,input ub.db.db-key-enc
        ,output v-ok
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке кодирования ключа" skip
          "Номер базы данных" ub.db.db-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error.
      end.
      if v-ok <> true then do:
        message
          vss-workfile vss-revision vss-description skip
          "Нарушение кодировки ключа базы" skip
          "Номер базы данных" ub.db.db-num skip
          view-as alert-box error .
        undo main-block, return error.
      end.
    end.


    if new(ub.db)
      and ub.db.db-num <> 0
    then do:
      run waitfram-show in this-procedure ( input "Ждите... идет копирование опций маршрутизации и истории" ).
            /*скопируем настройки маршрутизации*/
      for each buf_hist-nws-option no-lock
        where buf_hist-nws-option.db-num = 0
      on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
        create buf2_hist-nws-option.
        if buf_hist-nws-option.subject-group = {&table_c-dc-hist} then do:
          buffer-copy buf_hist-nws-option
          except db-num
          to buf2_hist-nws-option
          assign
          buf2_hist-nws-option.db-num = ub.db.db-num
          .
        end.
        else do:

          buffer-copy buf_hist-nws-option
          except
          db-num
          get-hist-from-nws
          hist-from-prim
          hist-to-nws
          nws-to-cd
          nws-to-hist
          smart-nws
          to buf2_hist-nws-option
          assign
          buf2_hist-nws-option.db-num = ub.db.db-num
          buf2_hist-nws-option.get-hist-from-nws = ( if buf_hist-nws-option.get-hist-from-nws = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.get-hist-from-nws = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.get-hist-from-nws
                                                    else integer({&hn-is-on}))
          buf2_hist-nws-option.hist-from-prim = ( if buf_hist-nws-option.hist-from-prim = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.hist-from-prim = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.hist-from-prim
                                                    else integer({&hn-is-on}))
          buf2_hist-nws-option.hist-to-nws = ( if buf_hist-nws-option.hist-to-nws = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.hist-to-nws = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.hist-to-nws
                                                    else integer({&hn-is-on}))
          buf2_hist-nws-option.nws-to-cd = ( if buf_hist-nws-option.nws-to-cd = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.nws-to-cd = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.nws-to-cd
                                                    else integer({&hn-is-off}))
          buf2_hist-nws-option.nws-to-hist = ( if buf_hist-nws-option.nws-to-hist = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.nws-to-hist = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.nws-to-hist
                                                    else integer({&hn-is-on}))
          buf2_hist-nws-option.smart-nws = ( if buf_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})
                                                    or buf_hist-nws-option.smart-nws = integer({&hn-is-off-blocked})
                                                    then buf_hist-nws-option.smart-nws
                                                    else integer({&hn-is-off}))
          .
        end.
        v-ii = v-ii + 1.
        if v-ii modulo 10 = 0 then do:
          run waitfram-show in this-procedure ( input substitute("Ждите... идет копирование опций маршрутизации и истории: &1", v-ii) ).
        end.
      end.
      run waitfram-hide in this-procedure .
    end.
  end.

  find first buf_sys-ctrl no-lock .
  run cur-time in this-procedure
    ( output v-date
    , output v-time
    ).
  create buf_c-db.
  if new(ub.db) then do:
    assign
      buf_c-db.db-num = ub.db.db-num
    .
  end.
  else do:
    buffer-copy old-db to buf_c-db .
  end.
  assign
    buf_c-db.action           = integer(if new(ub.db) then {&hn-create} else {&hn-update})
    buf_c-db.chip-num         = dynamic-next-value ( "s-db-chip", "{&db-name_schema}")
    buf_c-db.corr-time        = v-time
    buf_c-db.corr-date        = v-date
    buf_c-db.corr-user-db-num = buf_sys-ctrl.db-num
    buf_c-db.corr-user-name   = (if g#news = true then "СПН" else g#userid )
  .
  if trim( buf_c-db.corr-user-name ) = "":U then do:
    assign
      buf_c-db.corr-user-name = userid( "ub":U )
    .
  end.

  run str/callnews.p
    (input {&table_db}
    ,input (buffer ub.db:handle)
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Невозможно маршрутизировать информацию по БД (db) для отправки в новости. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
    .
    if g#news = false then do:
      message
        v-message
        view-as alert-box error.
    end.
    undo main-block,  return error .
  end.
  if g#oxml = yes then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_update}
       ,input {&table_db}
       ,input ( buffer ub.db:handle )
      ) no-error.
    if error-status :error then do:
        undo main-block, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                                                  ,{&new-line}
                                                  ,vss-workfile
                                                  ,return-value
                                                  ,error-status :get-message ( 1 )
                                                ).
    end.
  end.
end.