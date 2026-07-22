block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на запись pck-sent

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/97
Author: Dmitry Ukhanov
Creation date: 03/22/97

*/

TRIGGER PROCEDURE FOR WRITE OF ub.pck-sent.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "триггер на запись pck-sent".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.pck-sent.db-num,ub.pck-sent.pack-num,ub.pck-sent.rcvd)" }
{ cmp/trg-def.i  }

do
on error undo, return error
:

/*    if g#oxml = yes*/
/*    then do:*/
/*    run str/calloxml.p (*/
/*          input {&nwsdochs_action_update}*/
/*        , input {&table_pck-sent}*/
/*        , input ( buffer ub.pck-sent:handle )*/
/*    ) no-error.*/
/*    if error-status :error*/
/*    then do:*/
/*        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"*/
/*                             , {&new-line}*/
/*                             , vss-workfile*/
/*                             , return-value*/
/*                             , error-status :get-message ( 1 ) ).*/
/*    end.*/
/*    end.*/

end.