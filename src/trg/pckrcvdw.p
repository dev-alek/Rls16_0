block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на запись pck-rcvd

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/97
Author: Dmitry Ukhanov
Creation date: 03/22/97

*/

TRIGGER PROCEDURE FOR WRITE OF ub.pck-rcvd .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "триггер на запись pck-rcvd".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:

/*    if g#oxml = yes*/
/*    then do:*/
/*    run str/calloxml.p (*/
/*          input {&nwsdochs_action_update}*/
/*        , input {&table_pck-rcvd}*/
/*        , input ( buffer ub.pck-rcvd:handle )*/
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