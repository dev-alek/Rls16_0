block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы атрибутов внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/15/06
Author: Pavel Khnykin
Creation date: 02/15/06

 */

trigger procedure for write of ub.ext-artic-attr new buffer new-ext-artic-attr old buffer old-ext-artic-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы атрибутов внешних артикулов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                        , new-ext-artic-attr.cli-type
                        , new-ext-artic-attr.cli-code
                        , new-ext-artic-attr.gds-code
                        , new-ext-artic-attr.attr-code
                        ) "
}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_c-ext-artic-attr for ub.c-ext-artic-attr.

define variable v-date as date      no-undo .
define variable v-time as integer   no-undo .

main-block:
do on error   undo main-block , return error return-value
   on endkey  undo main-block , return error return-value
   on stop    undo main-block , return error return-value
   :
      run str/callnews.p
        (input "ext-artic-attr"
        ,input (buffer new-ext-artic-attr :handle)
        ) no-error .
      if error-status:error then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры callnews.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo main-block, return error return-value.
      end.
      if g#news <> yes then do:
        run cur-time in this-procedure ( output v-date , output v-time ).
        create buf_c-ext-artic-attr.
        buffer-copy old-ext-artic-attr
          except cli-type cli-code gds-code attr-code
          to buf_c-ext-artic-attr
          assign
            buf_c-ext-artic-attr.cli-type = new-ext-artic-attr.cli-type
            buf_c-ext-artic-attr.cli-code = new-ext-artic-attr.cli-code
            buf_c-ext-artic-attr.gds-code = new-ext-artic-attr.gds-code
            buf_c-ext-artic-attr.attr-code = new-ext-artic-attr.attr-code
            buf_c-ext-artic-attr.chip-num = next-value( s-gds-chip , {&db-name_schema} )
            buf_c-ext-artic-attr.corr-date = v-date
            buf_c-ext-artic-attr.corr-time = v-time
            buf_c-ext-artic-attr.corr-user-db-num = g#db-num
            buf_c-ext-artic-attr.corr-user-name = g#userid
            buf_c-ext-artic-attr.action = ( if new new-ext-artic-attr then integer( {&hn-create} ) else integer( {&hn-update} ) )
          .
      end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ext-artic-attr}
        , input ( buffer ub.ext-artic-attr:handle )
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