block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Белова Марина Михайловна 
Дата создания: 10 апреля 2024 г.
Author:  Belova Marina 
Creation date: 10 april 2024 г.

*/ 
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

def buffer buf_code for ub.code.
define input param iTypeUpd as integer no-undo. /* 1 - обновить все площадки, 2 - обновить только время заблокированной более 15 мин */

pub-run:
do 
on error undo, retry pub-run:                 
find first buf_code where 
           buf_code.parent = "CDN_GisMt" 
       and buf_code.code = "CDN_Upd"              
        exclusive-lock no-wait no-error.
 if not avail buf_code then do:
        if locked(buf_code) then return.
        else do:         
   create buf_code.
   assign
      buf_code.parent = "CDN_GisMt" 
      buf_code.code = "CDN_Upd"
      buf_code.codename = "Запущен процесс обновления площадок ГИС МТ"
      buf_code.codeval = string(now)   
      .          
           validate buf_code no-error.
           if error-status:error then do:
               return .
           end.
        end.
    
        find current buf_code no-lock no-error.
                                       
        publish "runCdn" (iTypeUpd).     
end.
/* если флаг висит больше 20 минут, то игнорируем его */
else if datetime-tz(buf_code.codeval) < (now - 20 * 60000) 
then do:       
        buf_code.codeval = string(now).
        validate buf_code no-error.
        if error-status:error then do:
           return .
        end.            
        find current buf_code no-lock no-error.   
        publish "runCdn" (iTypeUpd).  
    end.              
    else find current buf_code no-lock no-error.
end.
if retry then do:
    return .
end.          

