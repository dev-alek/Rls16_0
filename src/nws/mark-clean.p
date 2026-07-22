block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чистка marking с датой последнего изменения более 1 года

Автор: Ростовцев Александр Михайлович
Дата создания: 07/05/23
Author: Aleksandr Rostovtsev
Creation date: 07/05/23

*/
using ibs.th.gbl.sys.objsrv.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Чистка marking с датой последнего изменения более 1 года".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ nws/nws-def.i  }
{ utl/gtin.i     }

define variable thMarkSts      as class ibs.th.str.marking.sts.mark no-undo.
define variable timeMunisYear  as datetime no-undo.     /* значение даты со смещение назад на 1 год) */
define variable datePlus2Year  as date     no-undo .    /* значение даты, с которой удаляются марки с пустой датой изменения статуса) */
define variable maxDelMarks    as integer  no-undo.
define variable cntDelMarks    as integer  no-undo.
define variable currentTime    as character no-undo .

define variable v-tth             as handle    no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-param-type      as character no-undo .

define buffer buf_db      for ub.db.
define buffer buf_marking for ub.marking.
define buffer buf_marking_lock for ub.marking.

delete object v-tth no-error.

run adm/shattri.p
  ( input "get":U
   ,input  "":U
   ,input  0
   ,input  {&attr-auto-task}
/*   ,input  {&attr-auto-task_send-msg-to-email}*/
   ,input  {&attr-auto-task_maxColMarks}
   ,output v-value-character
   ,output v-value-date
   ,output v-value-decimal
   ,output v-value-integer
   ,output v-value-logical
   ,output v-param-type
   ,input-output table-handle v-tth
  ) no-error .
maxDelMarks = if not error-status :error then v-value-integer else 1000.
delete object v-tth no-error.


assign
  thMarkSts     = ObjSrv:Env:Marking:Sts:Mark
  currentTime   = string(time,"HH:MM:SS")
  datePlus2Year = 04/01/2026
.

if month(today) = 2 and day(today) = 29 then 
   timeMunisYear = datetime(month(today), 28, year(today) - 1,
                           integer(entry(1,currentTime,":")),integer(entry(2,currentTime,":")),
                           integer(entry(3,currentTime,":"))).
else timeMunisYear = datetime(month(today), day(today), year(today) - 1,
                           integer(entry(1,currentTime,":")),integer(entry(2,currentTime,":")),
                           integer(entry(3,currentTime,":"))).

run write-to-log( "Удаление марок, измененных до " +  string(timeMunisYear,"99/99/9999 HH:MM:SS")) .
if maxDelMarks > 0 then
do:
  DEL_MARK_1:
  for each buf_marking where 
           (buf_marking.sts = thMarkSts:SaleLock:KeyIntDB and
            buf_marking.last-change < timeMunisYear) or
           (buf_marking.sts = thMarkSts:OutZone:KeyIntDB and 
            buf_marking.last-change < timeMunisYear) or
           (buf_marking.sts = thMarkSts:Ungrouped:KeyIntDB and 
            buf_marking.last-change < timeMunisYear) 
      no-lock:
    find first buf_marking_lock where
               rowid(buf_marking_lock) = rowid(buf_marking)
         exclusive-lock no-error.
    if available buf_marking_lock then do:
      delete buf_marking_lock.
      cntDelMarks = cntDelMarks + 1.
      if cntDelMarks >= maxDelMarks then leave DEL_MARK_1.
    end.
  end.
end.  
run write-to-log( substitute("Удалено &1 марок.", cntDelMarks ) ) .

/* удаление марок с пустой датой изменения */
run write-to-log( "Удаление марок с пустой датой изменения" ) .
cntDelMarks = 0.
if maxDelMarks > 0 and today >= datePlus2Year then
do:
  DEL_MARK_2:
  for each buf_marking where
           buf_marking.last-change = ?
      no-lock:
    find first buf_marking_lock where
               rowid(buf_marking_lock) = rowid(buf_marking)
         exclusive-lock no-error.
    if available buf_marking_lock then do:
      delete buf_marking_lock.
      cntDelMarks = cntDelMarks + 1.
      if cntDelMarks >= maxDelMarks then leave DEL_MARK_2.
    end.
  end.
end.  
run write-to-log( substitute("Удалено &1 марок.", cntDelMarks ) ) .
