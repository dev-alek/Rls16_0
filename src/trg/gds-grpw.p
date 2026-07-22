block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы gds-grp-obj-attr

Автор: Чернова Светлана Александровна
Дата создания: 10/28/08
Author: Svetlana Chernova
Creation date: 10/28/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-grp-obj-attr old old-gds-grp-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы gds-grp-obj-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-list-db-for-send as character no-undo .
  define variable v-need-send        as logical   no-undo .
  define variable v-obj-code         as integer   no-undo .
  v-list-db-for-send = "" .

  define buffer buf_assortment-matrix for ub.assortment-matrix .
  define buffer buf_clients for ub.clients .
  define buffer bf_clients for ub.clients .
  
  assign
    v-need-send = false
  .
  if g#db-num <> 0
    and g#news = false
  then do:
    assign
      v-list-db-for-send = "0"
      v-need-send        = true
    .
  end.
  if g#db-num = 0 then do:
    if ub.gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
    then do:
      find first buf_assortment-matrix no-lock
        where buf_assortment-matrix.asmt-id = integer(ub.gds-grp-obj-attr.obj-type)
          and buf_assortment-matrix.db-num  = ub.gds-grp-obj-attr.obj-code
        no-error .
      if available buf_assortment-matrix then do:
        if buf_assortment-matrix.obj-code = 0 then do:
          assign
            v-list-db-for-send = ""
            v-need-send        = true
          .
        end.
        else do:
          find first buf_clients no-lock
            where buf_clients.obj-code = buf_assortment-matrix.obj-code
              and buf_clients.obj-type = buf_assortment-matrix.obj-type
            no-error .
          if available buf_clients then do:
            if buf_clients.db-num <> 0 then do:
              assign
                v-list-db-for-send = string( buf_clients.db-num )
                v-need-send        = true
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      if  ub.gds-grp-obj-attr.attr-code  <> {&ggoattr-QntyAssMat} and ub.gds-grp-obj-attr.obj-code > 0 then do:
          find first buf_clients no-lock
            where buf_clients.obj-code = ub.gds-grp-obj-attr.obj-code
              and buf_clients.obj-type = ub.gds-grp-obj-attr.obj-type
            no-error .
          if available buf_clients then do:
            if buf_clients.db-num <> 0 then do:
              assign
                v-list-db-for-send = string( buf_clients.db-num )
                v-need-send        = true
              .
            end.
          end.
          else do:
              assign
                v-list-db-for-send = ""
                v-need-send        = true
              .
          end.
    end.
        else if  ub.gds-grp-obj-attr.attr-code  <> {&ggoattr-QntyAssMat} then do:
            assign
                v-list-db-for-send = ""
                v-need-send        = true
              .
        end.
    else do:
       v-need-send = false .
    end.
    end.
  end.

  if  v-need-send = true then do:
     /*
      run str/callnews.p
        (input "gds-grp-obj-attr"
        ,input (buffer ub.gds-grp-obj-attr:handle)
        ) no-error .
     */

    run nws/cr-route.p
      (input {&send-tbl}
      ,input {&table_gds-grp-obj-attr}
      ,input (buffer ub.gds-grp-obj-attr:handle)
      ,input v-list-db-for-send
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать gds-grp-obj-attr для отправки в новости" skip
        substitute( "Объект &1 &2", ub.gds-grp-obj-attr.obj-type, ub.gds-grp-obj-attr.obj-code ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error return-value .
    end.
  end.
  if g#oxml = yes then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_update}
      , input {&table_gds-grp-obj-attr}
      , input ( buffer ub.gds-grp-obj-attr:handle )
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                                      , {&new-line}
                                      , vss-workfile
                                      , return-value
                                      , error-status :get-message ( 1 )
                                      ).
    end.
  end.
end. /* main-block */