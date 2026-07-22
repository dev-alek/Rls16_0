/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись sr-izmerenia

Автор: Молотков Сергей Михайлович
Дата создания: 30/11/17
Author: Molotkov Sergey
Creation date: 30/11/17

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR WRITE OF ub.sr-izmerenia
  NEW BUFFER new-sr-izmerenia
  OLD BUFFER old-sr-izmerenia
.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись sr-izmerenia".
{ cmp/vssrevis.i "substitute('&1', new-sr-izmerenia.node-code)" }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define buffer buf_c-sr-izmerenia for ub.c-sr-izmerenia .
define variable v-field-chg as character no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .

   new-sr-izmerenia.node-code = if new-sr-izmerenia.node-code eq 0 then next-value (s-sr-izmerenia, {&db-name_schema}) else new-sr-izmerenia.node-code .
   buffer-compare new-sr-izmerenia to old-sr-izmerenia CASE-SENSITIVE save result in v-field-chg.
   if v-field-chg > "":U then . else return .

   run str/callnews.p
      (input {&table_sr-izmerenia}
      ,input (buffer new-sr-izmerenia:handle)
      ) no-error .
   if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
    substitute( "&1. Ошибка при отправке в новости команды на &5 записи. &2&3&2&4",
      vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ),
      if new(new-sr-izmerenia) then {&hn-create-full} else {&hn-update-full}
              )
      ) .
   end.


  /* 07/III-2018 в историю надо писать и из новостей, и из интерфейса
  if not g#news then do:
  */
    run cur-time in this-procedure (output v-date, output v-time).

    /* пишем историю */
    create buf_c-sr-izmerenia.
    /* в историю копируется запись до изменений; при создании в историю копирются начальные пустые значения */
    buffer-copy old-sr-izmerenia to buf_c-sr-izmerenia
    assign
      buf_c-sr-izmerenia.node-code          = new-sr-izmerenia.node-code
      buf_c-sr-izmerenia.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
      buf_c-sr-izmerenia.corr-date          = v-date
      buf_c-sr-izmerenia.corr-time          = v-time
      buf_c-sr-izmerenia.corr-user-db-num   = g#db-num
      buf_c-sr-izmerenia.corr-user-name     = g#userid
      buf_c-sr-izmerenia.action             = if new(new-sr-izmerenia) then {&hn-create} else {&hn-update}
      buf_c-sr-izmerenia.is-del             = false
    .
  /* end. */


  if g#oxml then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_sr-izmerenia}
        , input (buffer new-sr-izmerenia:handle)
    ) no-error.
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
    substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 )
              )
      ) .
    end.
  end.
  
  if not g#news then do:
        run trg/userlog.p (
            input if new(buf_c-sr-izmerenia) then {&nwsdochs_action_create} else {&nwsdochs_action_update}
            , input {&table_c-sr-izmerenia}
            , input ( buffer buf_c-sr-izmerenia :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
  end. /* end_of not_g#news */
