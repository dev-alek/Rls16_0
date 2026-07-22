block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : runproc-cdn.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Belova Marina
    Created     : Mon Apr 08 11:31:14 MSK 2024
    Notes       :
  ----------------------------------------------------------------------*/
  
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Асинхронные процессы" .
{ cmp/vssrevis.i }

{cmp\str-glbl.i}

{utl/asuncprocauto.i}

define input param iTypeUpd as integer no-undo. /* 1 - обновить все площадки, 2 - обновить только время заблокированной более 15 мин */

def buffer buf_code for ub.code.

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

run AddTask in this-procedure("utl/proc-gismtcdn", string(iTypeUpd)).

 
