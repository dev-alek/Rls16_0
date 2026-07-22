block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись s-coeff

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/03
Author: Bakhtadze Natalya
Creation date: 09/04/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.s-coeff OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись s-coeff".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',ub.s-coeff.gds-code,ub.s-coeff.host-code,ub.s-coeff.obj-type,ub.s-coeff.obj-code,ub.s-coeff.s-date)"}
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


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  /*при приеме новостей в ГБД из УБД если в УБД создалась глоб запись с коэф 1 - другой быть не может,
  а в УБД за это время пришла глоб запись с коэф 2 , так чтобы не переписать значение в ГБД значением в УБД сделаем так!!!!*/
  if g#news
  and g#db-num  = 0
  AND not new(ub.s-coeff)
  AND
  (ub.s-coeff.host-code = 0
  or ub.s-coeff.obj-type = "":U
  or ub.s-coeff.obj-code = 0)
  then do:
    assign
    ub.s-coeff.coeff-value = oldb.coeff-value
    .
  end.


  if not g#news then do:
    if g#db-num <> 0 and
    (ub.s-coeff.host-code = 0
    or ub.s-coeff.obj-type = "":U
    or ub.s-coeff.obj-code = 0
    )
    AND ub.s-coeff.coeff-value <> 0
    /*разрешаем глобальные записи только первоначальные*/
    then do:
      if ub.s-coeff.host-code = 0 then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя создавать/изменять глобальные записи сезонных коэффицентов" skip
        "в удаленной БД" skip
        "товар" ub.s-coeff.gds-code
        view-as alert-box error .
      end.
      else do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя создавать/изменять записи сезонных коэффицентов для фирмы" skip
        "в удаленной БД" skip
        "товар" ub.s-coeff.gds-code
        view-as alert-box error .
      end.
      undo main-block, return error.
    end.
    if ub.s-coeff.obj-type <> "":U
    or ub.s-coeff.obj-code <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = ub.s-coeff.obj-type
            AND buf_clients.obj-code = ub.s-coeff.obj-code.
      if buf_clients.db-num <> g#db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять запись сезонного коэффициента для товара на объекте," skip
        "принадлежащем другой БД" skip
        "товар" ub.s-coeff.gds-code skip
        ub.s-coeff.obj-type ub.s-coeff.obj-code
        view-as alert-box .
        undo  main-block, return error.
      end.
    end.
    if (ub.s-coeff.s-date <> {&s-coeff-start-date}
    OR ub.s-coeff.host-code <> 0
    OR ub.s-coeff.obj-type <> "":U
    OR ub.s-coeff.obj-code <> 0)
    AND
    not can-find (first buf_s-coeff where
                          buf_s-coeff.gds-code = ub.s-coeff.gds-code
                      AND buf_s-coeff.s-date = {&s-coeff-start-date}
                      AND buf_s-coeff.host-code = 0
                      AND buf_s-coeff.obj-type = "":U
                      AND buf_s-coeff.obj-code = 0)
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Отсутствует корневая запись сезонного коэффициента на товар" ub.s-coeff.gds-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  find first buf_s-coeff no-lock where
             buf_s-coeff.gds-code = ub.s-coeff.gds-code
         AND buf_s-coeff.host-code = ub.s-coeff.host-code
         AND buf_s-coeff.obj-type = ub.s-coeff.obj-type
         AND buf_s-coeff.obj-code = ub.s-coeff.obj-code
         AND buf_s-coeff.s-date = ub.s-coeff.s-date
         AND recid(buf_s-coeff) <> recid(ub.s-coeff)
         no-error .
  if available buf_s-coeff then do:
    message
    "Товар"  ub.s-coeff.gds-code skip
    "Уже есть сезонный коэффициент товара"
    "товар" ub.s-coeff.gds-code skip
    "фирма" ub.s-coeff.host-code "объект" ub.s-coeff.obj-type ub.s-coeff.obj-code "дата" ub.s-coeff.s-date
    view-as alert-box error .
    undo main-block, return error .
  end.

  run str/callnews.p
    ( input "s-coeff"
     ,input (buffer ub.s-coeff:handle)
    ) no-error .
  if error-status:error then undo main-block, return error return-value .

  run cur-time in this-procedure(output v-date, output v-time).
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
    create buf_c-s-coeff.
    buffer-copy oldb to buf_c-s-coeff
    assign
    buf_c-s-coeff.gds-code           = ub.s-coeff.gds-code
    buf_c-s-coeff.obj-type           = ub.s-coeff.obj-type
    buf_c-s-coeff.obj-code           = ub.s-coeff.obj-code
    buf_c-s-coeff.host-code          = v-host-code
    buf_c-s-coeff.s-date             = ub.s-coeff.s-date
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
    create buf_c-gds-hist.
    buffer-copy buf_c-s-coeff to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new ub.s-coeff then integer({&hn-create}) else integer({&hn-update}))
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
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_s-coeff}
        , input ( buffer ub.s-coeff:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.