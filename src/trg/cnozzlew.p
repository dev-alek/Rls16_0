block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории пистолета

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-nozzle OLD BUFFER oldb.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись истории пистолета":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-nozzle.obj-type
                         , ub.c-nozzle.obj-code
                         , ub.c-nozzle.nozzle-code
                         , ub.c-nozzle.chip-num
                         ) " }

{ cmp/trg-def.i  }

Main-Block:
do transaction on error   undo Main-Block, return error return-value
               on end-key undo Main-Block, return error return-value
               on stop    undo Main-Block, return error return-value :

  run str/callnews.p
    (input "c-nozzle"
    ,input (buffer ub.c-nozzle:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-nozzle}
        , input ( buffer ub.c-nozzle:handle )
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