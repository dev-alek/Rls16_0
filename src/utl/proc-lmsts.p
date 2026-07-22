block-level on error undo, throw.
/*
File        : proc-lmsts.p
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Белова Марина Михайловна 
Дата создания: 8 сентября 2024 г.
Author:  Belova Marina 
Creation date: 8 september 2024 г.

*/
using ibs.th.skt.ControlledClients.GisMtOffline.
 
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Проверка состояния ЛМ ЧЗ".
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ utl/proc-async.i proc_def}
{ utl/search.i  class }

define variable thGisMtOff as class GisMtOffline no-undo .      
define variable mParam     as character      no-undo.

mParam = GetPARAMAsunc( 1).
if mParam eq ? then do:    
   run PutMesAsunc( "error   Получение данных было прервано пользователем." ).
   { utl/proc-async.i proc_end}
   return.
end.

thGisMtOff =  new GisMtOffline() no-error.
thGisMtOff:ChkStsOffline() no-error.

delete object thGisMtOff no-error.  
{ utl/proc-async.i proc_end}  