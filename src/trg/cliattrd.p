block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление clients-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.clients-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление clients-attr".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,clients-attr.obj-type,clients-attr.obj-code,clients-attr.attr-code)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable p-news as logical no-undo.
define variable v-archive-attr-list as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer buf_c-clients-attr for ub.c-clients-attr.
define buffer buf_c-cli-hist for ub.c-cli-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  run clntattr-news in this-procedure(input ub.clients-attr.attr-code,
                                      output p-news) no-error.


  run clntattr-get-archive-attr in this-procedure (output v-archive-attr-list ) .
  if LOOKUP(ub.clients-attr.attr-code, v-archive-attr-list) = 0  then do:
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_clients-attr}
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
      create buf_c-clients-attr.
      buffer-copy ub.clients-attr to buf_c-clients-attr
      assign
      buf_c-clients-attr.chip-num           = next-value (s-cli-chip, {&db-name_schema})
      buf_c-clients-attr.corr-time          = v-time
      buf_c-clients-attr.corr-user-db-num   = g#db-num
      buf_c-clients-attr.corr-user-name     = (if g#news
                                       then {&nts-user}
                                       else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )

      buf_c-clients-attr.corr-date          = v-date
      .
      if ub.clients-attr.obj-type = {&shop}
      or ub.clients-attr.obj-type = {&stock} then do:
        { gbl/hostcode.i ub.clients-attr.obj-type ub.clients-attr.obj-code v-host-code }
      end.
      create buf_c-cli-hist.
      buffer-copy buf_c-clients-attr to buf_c-cli-hist
      assign
      buf_c-cli-hist.action = integer({&hn-delete})
      buf_c-cli-hist.subject = {&table_clients-attr}
      buf_c-cli-hist.host-code = v-host-code
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
  end.
  if p-news then do:
    run nws/cmd-del.p
      ( input {&table_clients-attr}
       ,input (buffer ub.clients-attr:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_clients-attr}
        , input ( buffer ub.clients-attr:handle )
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
end. /*doe*/