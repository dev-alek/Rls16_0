block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на удаление сезона.

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

Но сезон сейчас не удаляется меняется только статус.
08/19/04 11:23

*/
TRIGGER PROCEDURE FOR DELETE OF ub.season.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "    ".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.season.sea-code, ub.season.db-num, ub.season.sea-name) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_c-season for ub.c-season.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define variable v-time1 as character no-undo .
define variable v-str as character no-undo .
define variable v-gds-name as character no-undo .

define frame a
  v-str              format "x(60)"      no-labels     skip
  v-gds-name         format "x(60)"      no-labels     skip
  v-time1            format "x(60)" label     "Время"     skip
  with view-as dialog-box side-labels three-d
  title "Удаление привязки товара к СЕЗОНУ/КОЛЛЕКЦИИ"
  .

main-block :
do transaction
on error undo main-block, return error
:
  if session:set-wait-state( "compiler" ) then .
  run cur-time in this-procedure(output v-date, output v-time).
  v-time1 = string(v-time, 'HH:MM:SS':U)  .
  v-str = "Удаление сезона" .

      view frame a.
      display
        v-str
        v-time1
        with frame a.



  create buf_c-season.
  buffer-copy ub.season to buf_c-season
  assign
    buf_c-season.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-season.corr-time          = v-time
    buf_c-season.corr-user-db-num   = g#db-num
    buf_c-season.corr-user-name     = g#userid
    buf_c-season.corr-date          = v-date
  .

for each ub.gds-season exclusive-lock
     where  ub.gds-season.sea-code = ub.season.sea-code
      and   ub.gds-season.db-num   = ub.season.db-num
      :
      find first buf_goods no-lock where buf_goods.gds-code = ub.gds-season.gds-code no-error .
      run cur-time in this-procedure ( output v-date , output v-time ).

      v-time1 = string(v-time, 'HH:MM:SS':U)  .
      v-str = "Удаляется товар с Кодом " + string(ub.gds-season.gds-code) + " из сезона  " + string(ub.gds-season.sea-code) .
      v-gds-name = if available buf_goods then buf_goods.gds-name else "".
      display
        v-str
        v-gds-name
        v-time1
        with frame a.

     delete ub.gds-season.
end.

    find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
        and ub.season-attr.db-num =  ub.season.db-num 
        and ub.season-attr.attr-code =  {&seaattr-obj} no-error.
    
    if not g#news then do:
      if not available ub.season-attr or g#db-num <> 0 then do:  
    run nws/cmd-del.p
          ( input {&table_season}
       ,input (buffer ub.season:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      else do:
        find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
          and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
        if buf_clients.db-num <> 0 then do:
          run nws/cmd-del.p
            ( input {&table_season}
             ,input (buffer ub.season:handle)
             ,input string(buf_clients.db-num)
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
        end.
      end.
    end.

    for each ub.season-attr exclusive-lock where ub.season-attr.sea-code = ub.season.sea-code /*не удаляем пока атрибут seaattr-obj для того, чтобы правильно маршрутизировать season-attr*/
        and ub.season-attr.db-num =  ub.season.db-num 
        and ub.season-attr.attr-value <> {&seaattr-obj}:
      delete ub.season-attr.
    end.
    for each ub.season-attr exclusive-lock where ub.season-attr.sea-code = ub.season.sea-code
        and ub.season-attr.db-num =  ub.season.db-num 
        and ub.season-attr.attr-value = {&seaattr-obj}:
      delete ub.season-attr.
    end.

 hide frame a .
 if session:set-wait-state( "" ) then .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_season}
        , input ( buffer ub.season:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.