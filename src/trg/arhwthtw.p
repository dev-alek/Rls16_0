block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись архива Баланс МЦ на объекте

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/07/07
Author: Polina Gridchina
Creation date: 05/07/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.arh-wth-tot.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись архива Баланс МЦ на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
/*Архивы пересчитваюися при приеме новосей */
/*    if not g#news then do:
      run str/callnews.p
        ( INPUT "arh-wth-tot"
         ,INPUT (buffer arh-wth-tot:handle)
        ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description                    SKIP
        "Невозможно маршрутизировать wth-doc для отправки в новости" SKIP
        ERROR-STATUS:GET-MESSAGE( 1 ) SKIP RETURN-VALUE             SKIP
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
    END.  */

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_arh-wth-tot}
        , input ( buffer ub.arh-wth-tot:handle )
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