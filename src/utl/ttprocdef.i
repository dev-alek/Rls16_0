define temp-table ttRun no-undo
   field task         as character
   field proc         as character
   field runproc      as character
   field num          as integer
   field item         as integer
   field olditem      as integer
   field fmaxitem     as integer 
   field fpid         as integer 
   field fmax         as integer
   field favail       as logical
   field runtime      as datetime-tz
   field runnum       as int64
   field fstatus      as char
   field Filelog      as integer
   field fstatusItem  as char
   field fparam       as char
   field UserDB       as logical
   field fuser        as character 
   field fpasw        as character 
   field StartAfter   as datetime-tz
   field cmd          as char 
index task is unique primary task num 
index taskst task fstatusItem runnum
index statusItem fstatusItem StartAfter.

define temp-table ttTimeOutProc no-undo
   field task         as character
   field timeOut      as integer
   index task is unique primary task 
.
