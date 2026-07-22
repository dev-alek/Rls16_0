block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06


*/

trigger procedure for write of ub.c-ex-mark old old_c-ex-mark.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории акцизной или специальной марки".
{ cmp/vssrevis.i "substitute('&1|&2'
                            , ub.c-ex-mark.db-num
                            , ub.c-ex-mark.mark-code
                            , ub.c-ex-mark.corr-user-db-num
                            , ub.c-ex-mark.chip-num
                            ) " }
{ cmp/trg-def.i }

define buffer buf_ex-mark for ub.ex-mark.

main-block :
do transaction
on error undo main-block, return error return-value
:
  if not g#news then do:
    /*проверим реляционность*/
    find first buf_ex-mark no-lock
         where buf_ex-mark.db-num    = ub.c-ex-mark.db-num
           and buf_ex-mark.mark-code = ub.c-ex-mark.mark-code
         no-error .
    if not available buf_ex-mark then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на акцизную или специальную марку" skip
        substitute("код &1|&2", ub.c-ex-mark.db-num, ub.c-ex-mark.mark-code)
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-ex-mark"
    ,input (buffer ub.c-ex-mark:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-ex-mark}
        , input ( buffer ub.c-ex-mark:handle )
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