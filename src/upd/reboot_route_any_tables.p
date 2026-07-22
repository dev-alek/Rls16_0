block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Ростовцев Александр 
Дата создания: 16 авг. 2023 г.
Author:  Rostovtsev Aleksandr
Creation date: 16 авг. 2023 г.
Comment: Доработка reboot_route_fin-doc.p для любых таблиц

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{gbl/key-rec.i }
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

define temp-table ttrecid no-undo
  field tableName as character
  field inumtab as int 
  field reckey as character 
  index pi inumtab reckey
.

define variable vi     as integer no-undo.
define variable vv     as integer no-undo.
define variable vTables as character no-undo. 
define variable vtable as character no-undo. 
define variable vHn as handle no-undo.

vTables = entry(2,iparam,{&delim-par}).

do trans:
  do vi = 1 to num-entries (vTables,"|"):
     vtable = entry(vi,vTables,"|").
     for each route where route.name-rec eq vtable exclusive-lock:
         find first ttrecid where ttrecid.inumtab eq vi
                              and ttrecid.reckey eq route.uniq-key-rec
         no-error.
         if not available ttrecid
         then do:
            create  ttrecid.
            assign
               ttrecid.inumtab = vi
               ttrecid.reckey  = route.uniq-key-rec
               ttrecid.tableName = route.name-rec
            .
         end.
         delete route.
      end.
   end.
   
   for each ttrecid:
      run gen-hn-keyr(input ttrecid.reckey,input ?,input "{&db-name_schema}" , input ? ,input no-lock , output vHn).
      if vHn:available
      then do:
         run str\callnews.p (ttrecid.tableName, vHn) no-error.
         if error-status:error then
         do:
           message 
            substitute("Ошибка при обновлении записи &1 таблицы &2.", ttrecid.reckey, ttrecid.tableName) skip
            error-status :get-message ( 1 ) skip
            "Обратитесь к разработчику!"
           view-as alert-box.
           undo, return error "Ошибка при выполнении reboot_route_any_tables.p".
         end.
      end.
      else
         message "Беда нет записи " ttrecid.reckey
         view-as alert-box.
      delete object vHn no-error.
   end.
end.
oOk = true.
