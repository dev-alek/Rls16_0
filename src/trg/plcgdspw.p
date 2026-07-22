block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории связки ТОВАР-РЕЗЕРВУАР-ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-pl-gds-pump OLD BUFFER oldb.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись истории связки ТОВАР-РЕЗЕРВУАР-ТРК":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-pl-gds-pump.obj-type
                         , ub.c-pl-gds-pump.obj-code
                         , ub.c-pl-gds-pump.gds-code
                         , ub.c-pl-gds-pump.pump-code
                         , ub.c-pl-gds-pump.pl-code
                         , ub.c-pl-gds-pump.chip-num
                         ) " }

{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  run str/callnews.p
    (input "c-pl-gds-pump"
    ,input (buffer ub.c-pl-gds-pump:handle)
    ).


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-pl-gds-pump}
        , input ( buffer ub.c-pl-gds-pump:handle )
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
end. /* Main-Block */