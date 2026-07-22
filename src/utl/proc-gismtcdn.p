block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Белова Марина Михайловна 
Дата создания: 1 апреля 2024 г.
Author:  Belova Marina 
Creation date: 1 april 2024 г.

*/
using ibs.th.skt.ControlledClients.GisMtCDN.
 
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ utl/proc-async.i proc_def}
{ utl/search.i  class }

define variable thGisMtCdn as class GisMtCDN no-undo .      
define variable mParam     as character      no-undo.

def buffer buf_code for ub.code.

mParam = GetPARAMAsunc( 1).

if mParam eq ? then do:
   run PutMesAsunc( "error   Получение данных было прервано пользователем." ).
   { utl/proc-async.i proc_end}
   return.
end.

/* устанавливаем флаг обновления, если еще не установили раньше 
** (нужно при первом запуске сокета) */
find first buf_code where 
           buf_code.parent = "CDN_GisMt" 
       and buf_code.code = "CDN_Upd"              
    no-lock no-error.
 
if not avail buf_code then do:
   create buf_code.
   assign
      buf_code.parent = "CDN_GisMt" 
      buf_code.code = "CDN_Upd"
      buf_code.codename = "Запущен процесс обновления площадок ГИС МТ"
      buf_code.codeval = string(now)   
      .  
end.

thGisMtCdn =  new GisMtCDN().
case mParam:
    when "1" then thGisMtCdn:GetListCdn().
    when "2" then thGisMtCdn:UpdTimetCdn().
end case.
thGisMtCdn:DelCdnUpd(). /* удаляем флаг, что работает обновление площадок */

delete object thGisMtCdn.  
{ utl/proc-async.i proc_end}  