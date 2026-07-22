block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись маршрутизации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

TRIGGER PROCEDURE FOR WRITE OF ub.route NEW BUFFER buf-new_route OLD BUFFER buf-old_route .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись маршрутизации".
{ cmp/vssrevis.i "substitute('&1|&2|&3',buf-new_route.db-num,buf-new_route.last-pack,buf-new_route.tbl-ord)" }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable cre-date  as date      no-undo .
  define variable cre-time  as integer   no-undo .
  define variable v-msg     as character no-undo .
  define variable v-lock    as logical   no-undo .
  define variable v-ok      as logical   no-undo .
  define variable v-compare as logical   no-undo .

  define buffer buf_BatchProcess for ub.BatchProcess .
  define buffer buf_sys-ctrl     for ub.sys-ctrl .

  buffer-compare buf-new_route except last-pack to buf-old_route save result in v-compare no-error.
  if v-compare = true then do:
    if buf-old_route.last-pack = -1 then do:
      return .
    end.
    else do:
      return error substitute( "&1. Запрещено менять номер пакета в записи маршрутизации &2.&3Старый номер - &4, новый - &5"
                               ,vss-workfile
                               ,buf-new_route.name-rec
                               ,{&new-line}
                               ,buf-old_route.last-pack
                               ,buf-new_route.last-pack
                             ).
    end.
  end.

  find first buf_sys-ctrl no-lock .

  if buf-new_route.db-num = buf_sys-ctrl.db-num then do:
    return error substitute( "&1. Маршрутизация для БД &2 запрещена т.к. это текущая БД", vss-workfile, buf-new_route.db-num ) .
  end.

  if buf_sys-ctrl.db-num <> 0
    and buf-new_route.db-num <> 0
  then do:
    return error substitute( "&1. В УБД разрешена маршрутизация только для ГБД, а маршрутизируется для БД &2", vss-workfile, buf-new_route.db-num ) .
  end.


  if length( buf-new_route.name-rec ) > 1900 then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Длина поля 'имя команды' превышает допустимое значение!"
                             ,vss-workfile
                             ,buf-new_route.name-rec
                             ,{&new-line}
                           ).
  end.

  find first buf_BatchProcess no-lock
    where buf_BatchProcess.BP_Type = {&btpr-type-autoupg}
    no-error
  .
  if available buf_BatchProcess
    and not ( buf-new_route.name-rec begins string( "command":U + {&delim-nws} + "upgrade":U ) )
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&5"
                             ,vss-workfile
                             ,buf-new_route.name-rec
                             ,{&new-line}
                             ,buf-new_route.uniq-key-rec
                             ,{&new-line}
                           )
                + substitute( "Не завершен Upgrade! Отправка информации по СПН запрещена" ) .
  end.

  { nws/lock-rt.i
    "'check'"
    buf-new_route.db-num
    0
    "''"
    v-msg
    v-lock
    v-ok
    no-error
  }
  if error-status :error
    or v-lock = true
    or v-ok   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&5"
                             ,vss-workfile
                             ,buf-new_route.name-rec
                             ,{&new-line}
                             ,buf-new_route.uniq-key-rec
                             ,{&new-line}
                           )
                + substitute( "&1&2&3&4&5"
                              ,v-msg
                              ,{&new-line}
                              ,return-value
                              ,{&new-line}
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.

  if buf-new_route.CreDate = ?
    or buf-new_route.CreTimeInt = ?
  then do:
    run cur-time in this-procedure
      ( output cre-date
       ,output cre-time
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
    end.
    assign
      buf-new_route.CreDate    = cre-date
      buf-new_route.CreTimeInt = cre-time
      buf-new_route.CreTime    = string( cre-time, "HH:MM:SS":U )
    .
  end.
  if buf-new_route.CreUserName = "":U
    or buf-new_route.CreUserName = ?
  then do:
    if g#news = true then do:
      assign
        buf-new_route.CreUserName = substitute( "News-trg (&1)":U, g#userid )
      .
      if g#news-source-db > 0 then do:
        assign
          buf-new_route.CreUserName = substitute( "&1 from BD &2":U, buf-new_route.CreUserName, g#news-source-db )
        .
      end.
    end.
    else do:
      assign
        buf-new_route.CreUserName = g#userid
      .
    end.
  end.

end.