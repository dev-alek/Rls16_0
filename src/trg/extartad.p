block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы атрибутов внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/15/06
Author: Pavel Khnykin
Creation date: 02/15/06

*/

trigger procedure for delete of ub.ext-artic-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы атрибутов внешних артикулов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/ea-attr.i }

define buffer buf_c-ext-artic-attr for ub.c-ext-artic-attr.

define variable v-date as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-news as logical   no-undo .

main-block:
do on error   undo main-block , return error return-value
   on endkey  undo main-block , return error return-value
   on stop    undo main-block , return error return-value
   :
    run ext-artic-attr-news in this-procedure ( input ub.ext-artic-attr.attr-code , output v-news ) no-error .
    run cur-time in this-procedure ( output v-date , output v-time ) .
    create buf_c-ext-artic-attr.
    buffer-copy ub.ext-artic-attr to buf_c-ext-artic-attr
    assign
      buf_c-ext-artic-attr.chip-num         = next-value( s-gds-chip , {&db-name_schema} )
      buf_c-ext-artic-attr.corr-date        = v-date
      buf_c-ext-artic-attr.corr-time        = v-time
      buf_c-ext-artic-attr.corr-user-db-num = g#db-num
      buf_c-ext-artic-attr.corr-user-name   = g#userid
      buf_c-ext-artic-attr.action = integer( {&hn-delete} )
    .
    if v-news then do:
      run nws/cmd-del.p ( input "ext-artic-attr":u , input (buffer ext-artic-attr :handle) , input "":u ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ) .
      end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ext-artic-attr}
        , input ( buffer ub.ext-artic-attr:handle )
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