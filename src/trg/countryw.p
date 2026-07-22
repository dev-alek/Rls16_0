block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись справочника страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.country OLD oldcountry.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись справочника страны".
{ cmp/vssrevis.i "substitute('&1', ub.country.num-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-units for ub.c-units.

define buffer buf_c-country for ub.c-country.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run str/callnews.p
    (input {&table_country}
    ,input (buffer ub.country:handle)
    ).
  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    " ( if new(ub.country) then {&thref-proc_recadd} else {&thref-proc_recupdate} )"
    " buffer oldcountry:handle "
    " buffer ub.country:handle "
    ''
    ''
    no-error
    }
  if error-status:error
  then do:
    if not g#news then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры rum-runa.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo main-block,  return error return-value .
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-country.
    buffer-copy oldcountry to buf_c-country
    assign
    buf_c-country.num-code           = ub.country.num-code
    buf_c-country.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-country.corr-time          = v-time
    buf_c-country.corr-user-db-num   = g#db-num
    buf_c-country.corr-user-name     = g#userid
    buf_c-country.corr-date          = v-date
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_country}
        , input ( buffer ub.country:handle )
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