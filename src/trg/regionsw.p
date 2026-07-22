block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись в справочник регионов

Автор: Хныкин Павел Андреевич
Дата создания: 01/15/07
Author: Pavel Khnykin
Creation date: 01/15/07

*/
trigger procedure for write of ub.regions old buffer old_regions.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись в справочник регионов".
{ cmp/vssrevis.i "substitute('&1', regions.reg-code)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_c-regions for ub.c-regions.

define variable v-date    as date      no-undo .
define variable v-time    as integer   no-undo .
define variable v-key-rec as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run cur-time in this-procedure ( output v-date , output v-time ).
  create buf_c-regions.
  buffer-copy old_regions
    except reg-code
    to buf_c-regions
    assign
        buf_c-regions.reg-code         = ub.regions.reg-code
        buf_c-regions.chip-num         = next-value( s-region , {&db-name_schema} )
        buf_c-regions.corr-time        = v-time
        buf_c-regions.corr-date        = v-date
        buf_c-regions.corr-user-db-num = g#db-num
        buf_c-regions.corr-user-name   = g#userid
    .
  if not g#news then do:
    run str/callnews.p ( input {&table_regions}
                       , input (buffer ub.regions :handle)
                       ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче в новости Региона" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        return error.
    end.
  end.



    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_regions}
        , input ( buffer ub.regions:handle )
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