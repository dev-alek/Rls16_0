/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Молотков Сергей
Дата создания: 25/02/19
Author: Molotkov Sergey
Creation date: 25/02/19

*/
block-level on error undo, throw.

define input parameter parparentproc   as handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle    as handle no-undo .
define input parameter p-parameter      as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение {&main-tbl}". 
{ cmp/vssrevis.i }

define variable v-pack-data    as memptr no-undo .
define variable v-full-path    as character no-undo .
define variable v-err-msg      as character no-undo .
define variable v-step-msg     as character no-undo .
define variable parseSubObj    as class ibs.th.bge.1crn.import.parsesub no-undo.
define variable impSubObj      as class ibs.th.bge.1crn.import.impsubject no-undo.


  if not valid-handle (p-log-handle) then
    undo, throw new Progress.Lang.AppError ("Отсутствует указатель на процедуру записи в лог.") .
  if not can-do (p-log-handle:internal-entries, "write-log":U) then
    undo, throw new Progress.Lang.AppError ("Отсутствует функция записи в лог в процедуре записи в лог.") .
      
  v-full-path = search("nws/kass-books.xml") .
  if v-full-path > "" then do :
    v-err-msg = substitute("импорт кассовых книг из файла &1", v-full-path) .
    run write-log in p-log-handle ( input 2, input v-err-msg ).
  end .
  else do :
    v-err-msg = substitute("отсутствует файл импорта кассовых книг &1", "nws/kass-books.xml") .
    run write-log in p-log-handle ( input 2, input v-err-msg ).
    return .
  end .
  
  v-step-msg = "чтение файла" .
  set-size(v-pack-data) = 0 .
  COPY-LOB FROM FILE v-full-path TO OBJECT v-pack-data NO-CONVERT .
  
  v-step-msg = "создание разбора пакета" .
  parseSubObj = new ibs.th.bge.1crn.import.parsesub () .
  v-step-msg = "установка указателей в разборе пакета" .
  parseSubObj:setParent(parparentproc, p-parent-handle, p-log-handle) .
  v-step-msg = "создание импорта пакета" .
  impSubObj = new ibs.th.bge.1crn.import.impsubject (parseSubObj).
  v-step-msg = "импорт пакета" .
  parseSubObj:Parse1CRNSub(v-pack-data).
  v-step-msg = "импорт завершён" .

  v-err-msg = substitute("пакет из файла &1 обработан без ошибок", v-full-path) .
  run write-log in p-log-handle ( input 2, input v-err-msg ).
  v-err-msg = "" .
  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    v-err-msg = v-step-msg + " " + v-err-msg .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
  end catch .
  finally:
    if valid-object(impSubObj)   then delete object impSubObj .
    if valid-object(parseSubObj) then delete object parseSubObj .
    set-size(v-pack-data) = 0 .
    if v-err-msg > "" then do :
      run write-log in p-log-handle ( input 2, input v-err-msg ).
      undo.
    end .
  end finally.
