block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории связки профайл-профайл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/09
Author: Bakhtadze Natalya
Creation date: 10/19/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-profile-by-profile.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись истории связки профайл-профайл".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-profile-by-profile.profile_id
                         , ub.c-profile-by-profile.child-profile_id
                         , ub.c-profile-by-profile.corr-user-db-num
                         , ub.c-profile-by-profile.chip-num
                         ) " }

{ cmp/trg-def.i }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-profile-by-profile}
        , input ( buffer ub.c-profile-by-profile:handle )
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