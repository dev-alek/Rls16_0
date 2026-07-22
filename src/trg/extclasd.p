block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ext-classif

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/28/06
Author: Bakhtadze Natalya
Creation date: 11/28/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ext-classif .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ext-classif".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                        , ub.ext-classif.classif-subject
                        , ub.ext-classif.classif-name
                        , ub.ext-classif.key#_one
                        , ub.ext-classif.key#_two
                        , ub.ext-classif.key#_three
                        , ub.ext-classif.charkey_one
                        , ub.ext-classif.charkey_two
                        , ub.ext-classif.charkey_three
                        , ub.ext-classif.nonunique
                        ) " }
{ cmp/trg-def.i }

{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/key-rec.i }
{ ref/extclass.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .

define buffer buf_c-ext-classif for ub.c-ext-classif.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-cli-hist for ub.c-cli-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup(ub.ext-classif.classif-name, {&extclass_no-hist}) > 0
  and lookup(ub.ext-classif.classif-name, {&extclass_no-news}) > 0
  then return.

  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_ext-classif}
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
  if (not g#news
  or v-send >= 0 )
  and lookup(ub.ext-classif.classif-name, {&extclass_no-hist}) = 0
  then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-ext-classif.
    buffer-copy ub.ext-classif to buf_c-ext-classif
    assign
    buf_c-ext-classif.corr-time          = v-time
    buf_c-ext-classif.corr-user-db-num   = g#db-num
    buf_c-ext-classif.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                 then {&esys-user}
                                                 else g#userid)
                                            )
    buf_c-ext-classif.corr-date          = v-date
    .
    if lookup(ub.ext-classif.classif-name, {&extclass_extended-data-list}) = 0 then /* Проверка: в списке {&extclass_extended-data-list} - перечень данных без привязки к физическим таблицам ТН. Если находим таковые записи, то обходим формирование ключа, который ищет физические таблицы в ТН. */
        do: /* A-1 */
            run gen-key-fv in this-procedure ( input ub.ext-classif.uniq-key-rec
                                                , output v-field-list
                                                , output v-value-list
                                                ).
            end. /* A-1 */
            
    case ub.ext-classif.classif-subject :
      when {&table_clients} then do:
        assign
        v-obj-type = entry(lookup("obj-type":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key})
        v-obj-code = integer(entry(lookup("obj-code":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key}))
        no-error .

        buf_c-ext-classif.chip-num           = next-value (s-cli-chip, {&db-name_schema}).
        create buf_c-cli-hist.
        buffer-copy buf_c-ext-classif
        to buf_c-cli-hist
        assign
        buf_c-cli-hist.subject  = {&table_ext-classif}
        buf_c-cli-hist.obj-type = v-obj-type
        buf_c-cli-hist.obj-code = v-obj-code
        buf_c-cli-hist.action   = integer( {&hn-delete} )
        .
      end.
      when {&table_goods} then do:
        if ub.ext-classif.uniq-key-rec begins {&table_goods} then
        do:
          assign
            v-gds-code = integer(entry(lookup("gds-code":U
                                              , v-field-list
                                              , {&delim-key})
                                        , v-value-list, {&delim-key}))
            buf_c-ext-classif.chip-num           = next-value (s-gds-chip, {&db-name_schema})
          .
          create buf_c-gds-hist.
          buffer-copy buf_c-ext-classif
            to buf_c-gds-hist
            assign
            buf_c-gds-hist.subject = {&table_ext-classif}
            buf_c-gds-hist.gds-code = v-gds-code
          .
        end.
        else 
          buf_c-ext-classif.chip-num = next-value (s-ref-corr-chip, {&db-name_schema}).
      end.
      otherwise do:
        buf_c-ext-classif.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema}).
      end.
    end case.

  end.
  if lookup(ub.ext-classif.classif-name, {&extclass_no-news}) = 0 then do:
  run nws/cmd-del.p
    ( input {&table_ext-classif}
      ,input (buffer ub.ext-classif:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ext-classif}
        , input ( buffer ub.ext-classif:handle )
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
end.