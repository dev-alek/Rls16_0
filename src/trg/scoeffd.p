block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление s-coeff

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/03
Author: Bakhtadze Natalya
Creation date: 08/21/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.s-coeff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление fbr-gds-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',ub.s-coeff.gds-code,ub.s-coeff.host-code,ub.s-coeff.obj-type,ub.s-coeff.obj-code,ub.s-coeff.s-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .


define buffer buf_clients for ub.clients.
define buffer buf_s-coeff for ub.s-coeff.
define buffer buf_c-s-coeff for ub.c-s-coeff.
define buffer buf_c-gds-hist for ub.c-gds-hist.


/*вообще-то пока не должно ничего удаляться!!!*/

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*даже если будет удалять то не корневую!!!!*/
  if ub.s-coeff.host-code = 0
  AND ub.s-coeff.obj-type = "":U
  AND ub.s-coeff.obj-code = 0
  AND ub.s-coeff.s-date = {&s-coeff-start-date}
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять корневую запись сезонного коэффициента"skip
    "товар" ub.s-coeff.gds-code
    view-as alert-box .
    undo main-block, return error.
  end.
  if not g#news then do:
    if g#db-num <> 0 and
    (ub.s-coeff.host-code = 0
    or ub.s-coeff.obj-type = "":U
    or ub.s-coeff.obj-code = 0) then do:
      if ub.s-coeff.host-code = 0 then do:
        message
        "Нельзя удалять глобальную запись о сезонном коэффициенте товара" skip
        "в удаленной БД"
        view-as alert-box .
        undo main-block, return error.
      end.
      else do:
        message
        "Нельзя удалять запись для фирмы о сезонном коэффициенте товара" skip
        "в удаленной БД"
        view-as alert-box .
        undo main-block, return error.
      end.
    end.
    if ub.s-coeff.obj-type <> "":U
    or ub.s-coeff.obj-code <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = ub.s-coeff.obj-type
            AND buf_clients.obj-code = ub.s-coeff.obj-code.
      if buf_clients.db-num <> g#db-num then do:
        message
        "Нельзя удалять запись о сезонном коэффициенте товара на объекте," skip
        "принадлежащем другой БД"
        view-as alert-box .
        undo main-block, return error.
      end.
    end.
  end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_s-coeff}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    {&nws-to-hist}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-s-coeff.
    buffer-copy ub.s-coeff to buf_c-s-coeff
    assign
    buf_c-s-coeff.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-s-coeff.corr-time          = v-time
    buf_c-s-coeff.corr-user-db-num   = g#db-num
    buf_c-s-coeff.corr-user-name     = (if g#news
                                     then {&nts-user}
                                     else (if g#esys
                                           then {&esys-user}
                                           else g#userid)
                                    )
    buf_c-s-coeff.corr-date          = v-date
    .
    if ub.s-coeff.host-code = 0
    and not (ub.s-coeff.obj-type = "":U and ub.s-coeff.obj-code = 0)
    then do:
      { gbl/hostcode.i ub.s-coeff.obj-type ub.s-coeff.obj-code v-host-code }
    end.
    else do:
      assign
      v-host-code = ub.s-coeff.host-code
      .
    end.
    create buf_c-gds-hist.
    buffer-copy buf_c-s-coeff to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_s-coeff}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
  /* посылаем команду на удаление сезонного коэффициента */
  run nws/cmd-del.p
    ( input {&table_s-coeff}
     ,input (buffer ub.s-coeff:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_s-coeff}
        , input ( buffer ub.s-coeff:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.