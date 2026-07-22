/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление sr-izmerenia

Автор: Молотков Сергей Михайлович
Дата создания: 30/11/17
Author: Molotkov Sergey
Creation date: 30/11/17

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR DELETE OF ub.sr-izmerenia.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление sr-izmerenia".
{ cmp/vssrevis.i "substitute('&1', ub.sr-izmerenia.node-code)" }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define buffer buf_c-sr-izmerenia for ub.c-sr-izmerenia .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .


  if not g#news then do:
    run nws/cmd-del.p
      (input "sr-izmerenia":U
      ,input (buffer ub.sr-izmerenia:handle)
      ,input ""
      ) no-error .
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
    substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4",
      vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages )
              )
      ) .
    end.

    run cur-time in this-procedure (output v-date, output v-time).

    /* пишем историю */
    create buf_c-sr-izmerenia.
    buffer-copy ub.sr-izmerenia to buf_c-sr-izmerenia
    assign
      buf_c-sr-izmerenia.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
      buf_c-sr-izmerenia.corr-date          = v-date
      buf_c-sr-izmerenia.corr-time          = v-time
      buf_c-sr-izmerenia.corr-user-db-num   = g#db-num
      buf_c-sr-izmerenia.corr-user-name     = g#userid
      buf_c-sr-izmerenia.action             = {&hn-delete}
      buf_c-sr-izmerenia.is-del             = true
    .
  end. /* end_of not-g-news */


  if g#oxml then do:
      run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_sr-izmerenia}
        , input ( buffer ub.sr-izmerenia:handle )
      ) no-error.
      if error-status :error then do:
        undo, throw new Progress.Lang.AppError(
    substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 )
              )
        ) .
      end.
  end.
  
  /* буффер для записи истории buf_c-sr-izmerenia валидный только при условии (not g#news) */
  if not g#news then do:
        run trg/userlog.p (
            input {&nwsdochs_action_delete}
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
  end. /* end_of not-g-news */
