block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись curr-shop

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.curr-shop OLD old-curr-shop .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись curr-shop".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.curr-shop.obj-type
                         , ub.curr-shop.obj-code
                         , ub.curr-shop.curr-code
                         , ub.curr-shop.exch-date
                         , ub.curr-shop.exch-time) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if Year(ub.curr-shop.exch-date ) <> 9999 then do:
    if not g#news then do:
      run str/callnews.p
        ( input "curr-shop"
        ,input (buffer ub.curr-shop:handle)
        ) .
      run cur-time in this-procedure(output v-today, output v-time).
      assign
      ub.curr-shop.cre-date = v-today
      ub.curr-shop.cre-time = v-time
      ub.curr-shop.corr-user-name = g#userid
      .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_curr-shop}
        , input ( buffer ub.curr-shop:handle )
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