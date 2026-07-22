block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на удаления товара в списке сезонов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/19/04 11:23

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-season.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на удаления товара в списке сезонов    ".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.gds-season.sea-code, ub.gds-season.db-num , ub.gds-season.gds-code) "}
{ cmp/trg-def.i   }
{ gbl/cur-time.i  }
{ nws/lib-nws.i }

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_c-gds-season for ub.c-gds-season.
define buffer buf_c-gds-hist                for ub.c-gds-hist.
  define buffer buf_clients      for ub.clients.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

  if g#news then 
  do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_gds-season}
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
    or v-send >= 0 then 
  do:
    run cur-time in this-procedure(output v-date, output v-time).

    create buf_c-gds-season.
    buffer-copy ub.gds-season to buf_c-gds-season
    assign
    buf_c-gds-season.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-gds-season.corr-time          = v-time
    buf_c-gds-season.corr-user-db-num   = g#db-num
    buf_c-gds-season.corr-user-name     = g#userid
    buf_c-gds-season.corr-date          = v-date
    .

    create buf_c-gds-hist.
    buffer-copy buf_c-gds-season to buf_c-gds-hist
    assign
    buf_c-gds-hist.action  =  integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_gds-season}
    buf_c-gds-hist.is-news           = g#news
    buf_c-gds-hist.source-type       = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref        = (if g#news then string(g#news-source-db) else "":U)
    .
 end.

  for each ub.gds-season-attr exclusive-lock where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
    and ub.gds-season-attr.db-num =  ub.gds-season.db-num 
    and ub.gds-season-attr.gds-code = ub.gds-season.gds-code :
    delete ub.gds-season-attr.
  end.

  find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.gds-season.sea-code
      and ub.season-attr.db-num =  ub.gds-season.db-num 
      and ub.season-attr.attr-code =  {&seaattr-obj} no-error.

  if not g#news then do:
    if not available ub.season-attr or g#db-num <> 0 then do:
 run nws/cmd-del.p
   ( input {&table_gds-season}
    ,input (buffer ub.gds-season:handle)
    ,input "":U
   ) no-error .
      if error-status :error then 
      do:
        undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
    else do:
      find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
        and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
      if buf_clients.db-num <> 0 then do:      
        run nws/cmd-del.p
          ( input {&table_gds-season}
           ,input (buffer ub.gds-season:handle)
           ,input string(buf_clients.db-num)
          ) no-error .
 if error-status :error then do:
   undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
 end.
 end.
    end.
  end.
    if g#oxml = yes
    then 
  do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_gds-season}
        , input ( buffer ub.gds-season:handle )
    ) no-error.
    if error-status :error
      then 
    do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.