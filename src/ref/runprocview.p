block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 мая 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 мая 2019 г.

*/
define input  parameter IWorkdir as character no-undo.
define input  parameter iviewdir as character no-undo.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Просмотор процессов".
{ cmp/vssrevis.i }
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
   define variable v-old-propath   as character        no-undo .
   mAsyncHelper = new ibs.th.file.AsyncHelperth().
   
   mAsyncHelper:MyBachMode =no.
   mAsyncHelper:MyWorkDir          = IWorkdir.
   file-information:file-name = Iviewdir.
   mAsyncHelper:AsyncProc("ref/proc-view-proc", file-information:full-pathname, 1).
   mAsyncHelper:WaitFor("proc-view-proc", 1).
   delete object mAsyncHelper.
