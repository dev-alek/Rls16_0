block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибута складского места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-place-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибута складского места".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        , ub.c-place-attr.obj-type
                        , ub.c-place-attr.obj-code
                        , ub.c-place-attr.pl-code
                        , ub.c-place-attr.attr-code
                        , ub.c-place-attr.corr-user-db-num
                        , ub.c-place-attr.chip-num
                        ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run str/callnews.p
    (input "c-place-attr"
    ,input (buffer ub.c-place-attr:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-place-attr}
        , input ( buffer ub.c-place-attr:handle )
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