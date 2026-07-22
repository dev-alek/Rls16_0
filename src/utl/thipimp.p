block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Белова Марина Михайловна 
Дата создания: 27.01.2026
Author:  Belova Marina
Creation date: 27.01.2026

*/
using ibs.th.bge.execlimpexp.

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
/*{ utl/runpro.i}*/

define variable vfileLog as character no-undo init "Log_THIPImp.log".
define variable mFileName as character no-undo init "THIPImp.xslx".

{ cmp/str-glbl.i }
{ utl/search.i }
{ cmp/trg-def.i }
{ gbl/is-num.i }

define temp-table tt-th_ip no-undo
    field th_obj  as character label "Объект"  
    field th_ip   as character label "IP адрес"  
    index th_obj th_obj.

if g#db-num ne 0
then do:
   message "Импорт возможен только на ГБД" view-as alert-box.
   return error.
end.

define variable varlog as logical no-undo.
define variable mFileFullPath as character no-undo.
system-dialog get-file mFileName title "Выберите файл для загрузки ip станций"
    filters "MS Excel (*.xls,*.xlsx)" "*.xls,*.xlsx",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist             
    update varlog.
if not varlog then return error "Отказ от импорта" .

assign
   file-info:file-name = mFileName
   mFileFullPath           = file-info:full-pathname
.
if length(mFileFullPath) > 0 then .
else return error substitute("Не найден файл &1", mFileName).   

define variable exlim as class ibs.th.bge.execlimpexp no-undo.

do:
   exlim = new ibs.th.bge.execlimpexp (this-procedure).
   subscribe "WriteLogExel" anywhere run-procedure "WriteLog".
   subscribe "WorkLineExel" anywhere.
   exlim:impExcel(mFileFullPath, temp-table tt-th_ip:handle).
   
   delete object exlim.
   unsubscribe "WorkLineExel".
   unsubscribe "WriteLogExel".
end.

define variable mStrLoad as integer no-undo.
define variable mStrAll  as integer no-undo.
 
if searchfile(vfileLog) ne ?
then
   message "Сформирован лог " searchfile(vfileLog) skip
           "Обработано строк: " mStrAll - 1 skip
           "Изменено записей: " mStrLoad
   view-as alert-box.
else
   message "Нет данных для обработки."
   view-as alert-box.

define stream Slog.
define variable mfirst as logical no-undo init true.
procedure WriteLog:
   define input  parameter itext as character no-undo.
   if mfirst
   then do:
      mFirst = false.
      output stream Slog to value(vfileLog).
   end.
   else
      output stream Slog to value(vfileLog) append.
   put stream Slog unformatted itext skip.
   output stream Slog close. 
end.

procedure WorkLineExel:
   define input  parameter iBuffer as handle no-undo.
   define output parameter oDelRec as logical no-undo.
   
   define variable vdb-num as integer   no-undo.
      
   /* будем считать что запись нам больше не нужна */
   oDelRec = yes.
   mStrAll = mStrAll + 1.
   /* Не красиво но*/
   if not iBuffer:available then return.
   /* Первую строку пропускаем - это заголовок */
   if mStrAll = 1 then return .
   vdb-num = int(iBuffer::th_obj) no-error. 
   /* ищем БД */
   if vdb-num <> 0 then do: 
       
       find first thbj-attr where thbj-attr.upper-prop-code        eq {&attr-gisMT}
                                     and thbj-attr.obj-type        eq {&db}
                                     and thbj-attr.obj-code        eq vdb-num
                                     and thbj-attr.prop-code       eq {&attr-gisMT_TH_IP}                     
                exclusive-lock no-wait no-error.
       if available thbj-attr then do:
          thbj-attr.property-value-character =  iBuffer::th_ip.
          mStrLoad = mStrLoad + 1.
          run WriteLog(substitute ("БД &1 IP &2 - загружено успешно",vdb-num,iBuffer::th_ip) 
                       ).  
       end.            
       else do:
          run WriteLog(substitute ("БД &1 IP &2 - пропущено, отсутствует секция для данной БД",vdb-num,iBuffer::th_ip) 
                       ).
       end.      
   end.                      
end.
