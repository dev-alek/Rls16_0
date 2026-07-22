block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление смены по объекту

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.shift-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление смены по объекту".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,ub.shift-obj.obj-type,ub.shift-obj.obj-code,ub.shift-obj.shift-date,ub.shift-obj.shift-num,ub.shift-obj.status_)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define variable v-vid-action        as integer no-undo .
define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .

define variable v-shift-staff-list  as character no-undo .
define variable v-shift-manager     as character no-undo .

define buffer buf_shift-staff for ub.shift-staff.
define buffer buf_c-shift-obj for ub.c-shift-obj.
define buffer buf_c-sht-hist  for ub.c-sht-hist.
/*история маршрутизируется по кусту c-shift-obj после ее удаления и взведения фдага is-del*/


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    if ub.shift-obj.status_ <> ""
      and ub.shift-obj.status_ <> {&sht-expected}
    then do:
      message
        "Не может быть удалена смена со статусом:" ub.shift-obj.status_ skip
        "Дата смены:" ub.shift-obj.shift-date skip
        "Номер смены:" ub.shift-obj.shift-name skip
        "Порядок смены:" ub.shift-obj.shift-num
        view-as alert-box error.
      undo main-block, return error.
    end.

    if g#db-num <> 0 then do :
      run nws/cmd-del.p
        ( input {&table_shift-obj}
        ,input (buffer ub.shift-obj:handle)
        ,input "0":U
        ) no-error .
      if error-status :error then do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  end.

  for each buf_shift-staff
    where buf_shift-staff.obj-type   = ub.shift-obj.obj-type
      and buf_shift-staff.obj-code   = ub.shift-obj.obj-code
      and buf_shift-staff.shift-date = ub.shift-obj.shift-date
      and buf_shift-staff.shift-num  = ub.shift-obj.shift-num
  on error undo main-block, return error return-value
  :
    
    if not buf_shift-staff.next-shift
    then do :
        if buf_shift-staff.staff-role
        then
        assign
            v-shift-manager = buf_shift-staff.name
        .
        else
        assign
            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + buf_shift-staff.name
        .
    end.
    /*в триггер на delete напишем историю в c-sht-hist и c-shift-staff*/     
    delete buf_shift-staff.
  end.

  if not g#news then do:
    run cur-time in this-procedure
      ( output v-today
       ,output v-time
      ).

    create buf_c-shift-obj.
    buffer-copy ub.shift-obj to buf_c-shift-obj
      assign
        buf_c-shift-obj.chip-num           = next-value (s-shift-chip, {&db-name_schema})
        buf_c-shift-obj.corr-time          = v-time
        buf_c-shift-obj.corr-user-db-num   = g#db-num
        buf_c-shift-obj.corr-user-name     = g#userid
        buf_c-shift-obj.corr-date          = v-today
        buf_c-shift-obj.is-del             = yes
    .
    create buf_c-sht-hist.
    buffer-copy buf_c-shift-obj to buf_c-sht-hist
      assign
        buf_c-sht-hist.action     = integer( {&hn-delete})
        buf_c-sht-hist.subject    = {&table_shift-obj}
        buf_c-sht-hist.is-news    = g#news
    .
    
    v-vid-action = 54 .
    v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + {&delim-par} +
                  "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + {&delim-par} +
                  "ShiftManager=" + v-shift-manager + {&delim-par} +
                  "ShiftStaff=" + v-shift-staff-list + {&delim-par} +
                  "RESULT=0" + {&delim-par} + 
                  "Description=".
                  
    run trg/userlog.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-sht-hist}
        , input ( buffer buf_c-sht-hist :handle )
        , input v-vid-action
        , input v-vid-param
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

  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_shift-obj}
        , input ( buffer ub.shift-obj:handle )
    ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                    ,{&new-line}
                                    ,vss-workfile
                                    ,return-value
                                    ,error-status :get-message ( 1 ) ).
    end.
  end.
  
  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&edoc-proc_event_shift}
    " buffer ub.shift-obj:handle "
    ''
    ''
    ''
    no-error
  }
  if error-status :error
  then
  do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
          , {&new-line}
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
  end.
  
  
end.