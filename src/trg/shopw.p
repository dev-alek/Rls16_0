block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись магазина

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.shop OLD old-shop.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись магазина".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-shop for ub.c-shop.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_sysconf no-lock where
             buf_sysconf.host-code = ub.shop.host-code.
  if buf_sysconf.firm-db-num <> 0 then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = {&shop}
           AND buf_clients.obj-code = ub.shop.obj-code no-error.
    if buf_clients.db-num <> buf_sysconf.firm-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Главная БД фирмы не совпадает с БД, к которой относится объект" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if  not new(ub.shop)
  and ub.shop.doc-prt <> old-shop.doc-prt then do:
    run trg/objatchk.p
      (input {&shop}          /* p-obj-type  */
      ,input ub.shop.obj-code /* p-obj-code  */
      ,input "doc-prt":u      /* p-action    */
      ,input ub.shop.doc-prt  /* p-new-value */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при изменении поля doc-prt" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if  not new(ub.shop)
  and ub.shop.shift-on <> old-shop.shift-on then do:
    run trg/objatchk.p
      (input {&shop}          /* p-obj-type  */
      ,input ub.shop.obj-code /* p-obj-code  */
      ,input "shift-on":u     /* p-action    */
      ,input ub.shop.shift-on /* p-new-value */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при изменении поля shift-on" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
   end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_shop~}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
    ~{&nws-to-hist~}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-shop.
    buffer-copy old-shop to buf_c-shop
    assign
    buf_c-shop.obj-code           = ub.shop.obj-code
    buf_c-shop.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-shop.corr-time          = v-time
    buf_c-shop.corr-user-db-num   = g#db-num
    buf_c-shop.corr-user-name     = (if g#news
                                     then {&nts-user}
                                     else (if g#esys
                                           then {&esys-user}
                                           else g#userid)
                                    )
    buf_c-shop.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-shop to buf_c-cli-hist
    assign
    buf_c-cli-hist.obj-type = {&shop}
    buf_c-cli-hist.obj-code = ub.shop.obj-code
    buf_c-cli-hist.action = (if new (ub.shop )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-cli-hist.subject = {&table_shop}
    buf_c-cli-hist.host-code = ub.shop.host-code
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-cli-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
  run str/callnews.p
    (input {&table_shop}
    ,input (buffer ub.shop:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_shop}
        , input ( buffer ub.shop:handle )
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