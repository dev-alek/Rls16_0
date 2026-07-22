block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ПЕРСОНАЛА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/23/06
Author: Bakhtadze Natalya
Creation date: 05/23/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-staff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ПЕРСОНАЛА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         ,  ub.c-staff.role
                         ,  ub.c-staff.role-level
                         ,  ub.c-staff.work-place
                         ,  ub.c-staff.staff-code
                         ,  ub.c-staff.date-start
                         ,  ub.c-staff.corr-user-db-num
                         ,  ub.c-staff.chip-num
                         ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news
  or g#db-num > 0 then do:
    run str/callnews.p (
                        input {&table_c-staff}
                        ,input (buffer ub.c-staff:handle)
                        ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-staff}
        , input ( buffer ub.c-staff:handle )
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