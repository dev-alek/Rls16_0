block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории номинала МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-wth-place.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории номинала МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&7'
                           , ub.c-wth-place.host-code
                           , ub.c-wth-place.obj-type
                           , ub.c-wth-place.obj-code
                           , ub.c-wth-place.w-p-code
                           , ub.c-wth-place.corr-user-db-num
                           , ub.c-wth-place.chip-num
                           ) " }
{ cmp/trg-def.i }

define buffer buf_wth-place for ub.wth-place.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_wth-place no-lock where
               buf_wth-place.host-code = c-wth-place.host-code
            AND buf_wth-place.obj-type = c-wth-place.obj-type
            AND buf_wth-place.obj-code = c-wth-place.obj-code
            AND buf_wth-place.w-p-code = c-wth-place.w-p-code  no-error .
    if not available buf_wth-place then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на МХ МЦ" skip
      "Фирма" c-wth-place.host-code skip
      "Объект" c-wth-place.obj-type c-wth-place.obj-code skip
      "код МХ МЦ" c-wth-place.w-p-code skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  then
  run str/callnews.p
    (input "c-wth-place"
    ,input (buffer ub.c-wth-place:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-wth-place}
        , input ( buffer ub.c-wth-place:handle )
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