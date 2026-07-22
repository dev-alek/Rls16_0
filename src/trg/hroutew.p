block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись маршрутизации OpenXML

Автор: Белоусов Илья Александрович
Дата создания: 11/15/06
Author: Ilia Belousov
Creation date: 11/15/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.h-route .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись маршрутизации OpenXML".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.h-route.db-num,ub.h-route.last-pack,ub.h-route.tbl-ord)" }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
    define variable cre-date as date      no-undo .
    define variable cre-time as integer   no-undo .
    define variable v-msg    as character no-undo .
    define variable v-lock   as logical   no-undo .
    define variable v-ok     as logical   no-undo .

    { nws/lock-rt.i
      "'check'"
      ub.h-route.db-num
      0
      "''"
      v-msg
      v-lock
      v-ok
      no-error
    }
    if error-status :error
    or v-lock = true
    or v-ok   = false
    then do:
        return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&5"
                                ,vss-workfile
                                ,ub.h-route.name-rec
                                ,{&new-line}
                                ,ub.h-route.uniq-key-rec
                                ,{&new-line}
                            )
                    + substitute( "&1&2&3&4&5"
                                ,v-msg
                                ,{&new-line}
                                ,return-value
                                ,{&new-line}
                                ,error-status :get-message( error-status :num-messages )
                                ) .
    end.
    if ub.h-route.CreDate = ?
    or ub.h-route.CreTimeInt = ?
    then do:
        run cur-time in this-procedure (
              output cre-date
            , output cre-time
        ) no-error.
        if error-status :error
        then do:
            return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
        end.
        assign
            ub.h-route.CreDate    = cre-date
            ub.h-route.CreTimeInt = cre-time
            ub.h-route.CreTime    = string( cre-time, "HH:MM:SS":U )
        .
    end.
    if ub.h-route.CreUserName = "":U
    or ub.h-route.CreUserName = ?
    then do:
        if g#news = true
        then do:
            assign
                ub.h-route.CreUserName = substitute( "News-trg (&1)":U, g#userid )
            .
        end.
        else do:
            assign
                ub.h-route.CreUserName = g#userid
            .
        end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_h-route}
        , input ( buffer ub.h-route:handle )
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