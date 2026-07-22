block-level on error undo, throw.

/*------------------------------------------------------------------------
    Description : Экспорт 1C ERP RN

  ----------------------------------------------------------------------*/
/*
Маршрутизация во ВС
*/
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 7 янв. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 7 янв. 2023 г.

*/
{ gbl/objsrv.i }
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define input  parameter parparentproc    as handle                         no-undo .
define input  parameter p-parent-handle  as handle                         no-undo .
define input  parameter p-log-handle     as handle                         no-undo .
define input  parameter i-process        as character                      no-undo .
define input  parameter p-oldbh          as handle                         no-undo .
define input  parameter p-newbh          as handle                         no-undo .
define input  parameter p-paranms        as ibs.th.gbl.collection.paramCol no-undo.

define variable mexport as ibs.th.bge.1crn.export.send1cerp no-undo.
mexport = new ibs.th.bge.1crn.export.send1cerp(parparentproc,p-parent-handle,p-log-handle,i-process,p-oldbh,p-newbh,p-paranms).
if mexport:Msg ne ""
then
   return error mexport:Msg.
   
 finally:
    if valid-object (mexport)
    then 
       delete object mexport.       
 end finally.