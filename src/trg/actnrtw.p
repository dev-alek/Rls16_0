block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись содержания роли

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.action-role-item old buffer old-action-role-item .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы action-role-item".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date    no-undo .
define variable v-time as integer no-undo .

define buffer buf_action-role        for ub.action-role .
define buffer buf_c-action-role      for ub.c-action-role .
define buffer buf_action-role-item   for ub.action-role-item .
define buffer buf_c-action-role-item for ub.c-action-role-item.


main-block:
do transaction
  on error   undo main-block, return error substitute('actnrtw error main-block,&1', return-value )
  on end-key undo main-block, return error substitute('actnrtw end-key main-block,&1', return-value )
  :
  if g#news then 
  do:  /* Переписываем item-code на всякий случай, если разъехались */

    find first ub.action-item
      where ub.action-item.action-head-code = ub.action-role-item.action-head-code
      and ub.action-item.action-item-id  = ub.action-role-item.action-item-id
      no-lock
      no-error
      .
    if available ub.action-item then 
    do:
      assign
        ub.action-role-item.action-item-code = ub.action-item.action-item-code
        .
    end.


  end.
  if not g#news then 
  do:

    run cur-time in this-procedure(output v-date, output v-time).
    define variable v-chip-num as integer no-undo .
    v-chip-num = next-value (s-action-role-chip, {&db-name_schema}) .
    find first buf_c-action-role-item exclusive-lock where buf_c-action-role-item.db-num =  ub.action-role-item.db-num and
      buf_c-action-role-item.action-head-code =  ub.action-role-item.action-head-code and
      buf_c-action-role-item.action-role-code =  ub.action-role-item.action-role-code and
      buf_c-action-role-item.action-role-item-code =  ub.action-role-item.action-role-item-code and
      buf_c-action-role-item.chip-num           =  v-chip-num and
      buf_c-action-role-item.corr-user-db-num   = g#db-num no-error .
    if not available (buf_c-action-role-item) then 
    do:
      create buf_c-action-role-item.
      buffer-copy old-action-role-item to buf_c-action-role-item
        assign
        buf_c-action-role-item.db-num           =  ub.action-role-item.db-num
        buf_c-action-role-item.action-head-code =  ub.action-role-item.action-head-code
        buf_c-action-role-item.action-role-code =  ub.action-role-item.action-role-code
        buf_c-action-role-item.action-role-item-code =  ub.action-role-item.action-role-item-code
        buf_c-action-role-item.chip-num           = v-chip-num
        buf_c-action-role-item.corr-user-db-num   = g#db-num
        .
    end.
    assign
      buf_c-action-role-item.corr-time      = v-time
      buf_c-action-role-item.corr-user-name = g#userid
      buf_c-action-role-item.corr-date      = v-date
      buf_c-action-role-item.subject        = {&table_action-role-item}
      buf_c-action-role-item.action         = integer(if new(ub.action-role-item) then {&hn-create} else {&hn-update})
      .
    find first buf_c-action-role exclusive-lock where buf_c-action-role.db-num =  buf_c-action-role-item.db-num and
      buf_c-action-role.action-head-code =  buf_c-action-role-item.action-head-code and
      buf_c-action-role.action-role-code =  buf_c-action-role-item.action-role-code and
      buf_c-action-role-item.chip-num           =  buf_c-action-role-item.chip-num and
      buf_c-action-role-item.corr-user-db-num   = buf_c-action-role-item.corr-user-db-num no-error .
    if not available (buf_c-action-role) then 
    do:            
      create buf_c-action-role.
      buffer-copy buf_c-action-role-item except buf_c-action-role-item.chip-num to buf_c-action-role .
    end.
    assign
      buf_c-action-role.subject = {&table_action-role-item}
      buf_c-action-role.action  = integer(if new(ub.action-role-item) then {&hn-create} else {&hn-update})
      .    
    if new(ub.action-role-item) = true then 
    do:   
      run trg/userlog.p (
        input {&nwsdochs_action_create}
        , input {&table_action-role-item}
        , input ( buffer ub.action-role-item :handle )
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
    end. 
    else 
    do:
      run trg/userlog.p (
        input {&nwsdochs_action_update}
        , input {&table_action-role-item}
        , input ( buffer ub.action-role-item :handle )
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

    end.      
    run str/callnews.p
      (input {&table_action-role-item}
      ,input (buffer ub.action-role-item :handle)
      ) no-error .
    if error-status:error then 
    do:
      undo main-block,  return error return-value .
    end.
  end.  
  if g#oxml = yes
    then 
  do:
    run str/calloxml.p (
      input {&nwsdochs_action_update}
      , input {&table_action-role-item}
      , input ( buffer ub.action-role-item:handle )
      ) no-error.
    if error-status :error
      then 
    do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
end.