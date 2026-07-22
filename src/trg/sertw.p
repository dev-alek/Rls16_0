block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы сертификат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.sert OLD old-sert.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы сертификат".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                             , ub.sert.cli-type
                             , ub.sert.cli-code
                             , ub.sert.sert-code
                             ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-sert for ub.c-sert.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run str/callnews.p
    (input "sert"
    ,input (buffer ub.sert:handle)
    ).
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-sert.
    buffer-copy old-sert
    except
    cli-type
    cli-code
    sert-code
    to buf_c-sert
    assign
    buf_c-sert.cli-type = ub.sert.cli-type
    buf_c-sert.cli-code = ub.sert.cli-code
    buf_c-sert.sert-code = ub.sert.sert-code
    buf_c-sert.chip-num           = next-value (s-sert-chip, {&db-name_schema})
    buf_c-sert.corr-time          = v-time
    buf_c-sert.corr-user-db-num   = g#db-num
    buf_c-sert.corr-user-name     = g#userid
    buf_c-sert.corr-date          = v-today
    buf_c-sert.subject            = {&table_sert}
    buf_c-sert.action             = (if new(ub.sert)
                                    then  integer({&hn-create})
                                    else  integer({&hn-update})
                                    )
    buf_c-sert.is-news            = g#news
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_sert}
        , input ( buffer ub.sert:handle )
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
END.