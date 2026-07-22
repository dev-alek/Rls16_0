block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/15/06
Author: Pavel Khnykin
Creation date: 02/15/06

*/

trigger procedure for write of ub.ext-artic new buffer new-ext-artic old buffer old-ext-artic.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись таблицы внешних артикулов":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        , new-ext-artic.cli-type
                        , new-ext-artic.cli-code
                        , new-ext-artic.gds-code
                        ) "
}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_c-ext-artic for ub.c-ext-artic.
define buffer buf_c-gds-hist  for ub.c-gds-hist.

define variable v-date    as date      no-undo .
define variable v-time    as integer   no-undo .
define variable v-key-rec as character no-undo .

main-block:
do on error   undo main-block, return error return-value
   on endkey  undo main-block, return error return-value
   on stop    undo main-block, return error return-value
   :
      run str/callnews.p
        (input {&table_ext-artic}
        ,input (buffer new-ext-artic :handle)
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
        create buf_c-ext-artic.
        buffer-copy old-ext-artic
          except cli-type cli-code gds-code
          to buf_c-ext-artic
          assign
             buf_c-ext-artic.cli-type = new-ext-artic.cli-type
             buf_c-ext-artic.cli-code = new-ext-artic.cli-code
             buf_c-ext-artic.gds-code = new-ext-artic.gds-code
             buf_c-ext-artic.chip-num = next-value( s-gds-chip , {&db-name_schema} )
             buf_c-ext-artic.corr-time = v-time
             buf_c-ext-artic.corr-date = v-date
             buf_c-ext-artic.corr-user-db-num = g#db-num
             buf_c-ext-artic.corr-user-name = g#userid
             buf_c-ext-artic.action = ( if new new-ext-artic then integer( {&hn-create} ) else integer( {&hn-update} ) )
          .
      create buf_c-gds-hist.
      buffer-copy buf_c-ext-artic to buf_c-gds-hist
      assign
        buf_c-gds-hist.action       = (if new new-ext-artic then integer({&hn-create}) else integer({&hn-update}))
        buf_c-gds-hist.subject      = {&table_ext-artic}
        buf_c-gds-hist.is-news      = g#news
        buf_c-gds-hist.source-type  = (if g#news
                                        then {&hn-source-db}
                                        else (if g#esys
                                              then {&hn-source-esys}
                                              else "":U)
                                        )
        buf_c-gds-hist.source-ref =  (if g#news
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
        , input {&table_ext-artic}
        , input ( buffer ub.ext-artic:handle )
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