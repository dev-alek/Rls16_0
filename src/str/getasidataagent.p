block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 10 июля 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 10 июля 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "agent asi".
{ cmp/vssrevis.i }


/* ***************************  Definitions  ************************** */

{bge/place-def.i}
define input parameter p-loclist as character no-undo .
define input parameter p-no-waitfram as logical no-undo .
define output parameter table for tt-place bind.

{ gbl/db-attr.i }
{ str/lib-rvs.i }
{ str/rvsttdef.i }
{ bge/socet.i}
{ utl/search.i}
{ str/revis.i }

define variable v-parsesub        as character  no-undo .


define variable curl-path         as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-addr            as character  no-undo .
define variable v-log-file-name   as character  no-undo .

define variable v-asi-ip  as character no-undo .
define variable v-asi-port as character no-undo .
define variable v-attr-type as character no-undo .

define variable v-asi-error-code as integer no-undo initial 0 .
define variable v-asi-error-message as character no-undo .

define variable old-BM as logical no-undo .

/* ***************************  Main Block  *************************** */

v-log-file-name = substitute('&1rvs.log', ibs.th.gbl.gbl-inipar:logDir) .

if p-loclist = '0':U then p-loclist = "all" .

find first sys-ctrl no-lock.
run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
mFileLogSocet = v-log-file-name.
{gbl/objsrv.i}
if     objSrv:SystemSetting:asifile ne ?
     and objSrv:SystemSetting:asifile ne ""
     and search(objSrv:SystemSetting:asifile) ne ?
then do:
   copy-lob from file search(objSrv:SystemSetting:asifile) to mWebResp no-convert no-error.
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") " Прочитан файл  " skip .
   output close .
end.
else do:
   old-BM = mBatchMode .
   if p-no-waitfram
   then do :
     mBatchMode = yes .
   end .
   run ConectSocet (v-asi-ip,
                    v-asi-port,
                    ("getmeas/?loclist=" + p-loclist),
                    "",
                    "xml",
                    180,
                    no,
                    "Получение данных от АСИ. ").
   mBatchMode = old-BM .
end.
empty temp-table tt-place .

if length(mWebResp) >0
then do:
   
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") " Разбираем полученные данныи  " skip .
   output close .
   copy-lob from mWebResp to file v-log-file-name append no-convert no-error.
   output to value (  v-log-file-name  ) append .
   put unformatted skip .
   output close .
   run parse-xml (input mWebResp) .
end.
else do:
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") "  Неудалось получить ответ  " skip .
   output close .
end.


/*if v-asi-error-code > 0             */
/*then do :                           */
/*  return error v-asi-error-message .*/
/*end .                               */

