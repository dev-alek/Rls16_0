block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документа истории по производству

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fbr-doc old buffer old-c-fbr-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа истории по производству ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

main-block:
do
on error undo main-block, return error
:
  run str/callnews.p
   (input "c-fbr-doc"
   ,input (buffer ub.c-fbr-doc:handle)
   ) no-error .
  if error-status:error then do:
    message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче документа истории по производству в новости" skip
        "Документ" ub.c-fbr-doc.doc-code skip
        view-as alert-box .
    undo main-block, return error.
  end.
    if g#oxml = yes
    then do:
        run str/calloxml.p (
              input {&nwsdochs_action_update}
            , input {&table_c-fbr-doc}
            , input ( buffer ub.c-fbr-doc:handle )
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
    if g#news <> yes
    then do:
        run trg/userlog.p (
              input {&nwsdochs_action_update}
            , input {&table_c-fbr-doc}
            , input ( buffer ub.c-fbr-doc :handle )
            , input ?
            , input ""
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                , {&new-line}
                                , vss-workfile
                                , return-value
                                , error-status :get-message ( 1 ) ).
        end.
    end.
end.