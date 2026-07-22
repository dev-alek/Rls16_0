block-level on error undo, throw.
/*

$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Импорт серийных номеров для параметра tsd-list из excel 

Автор: Морозов Александр Сергеевич
Дата создания: 04/27/2014
Author: Toporets Aleksandr
Creation date: 04/27/2014

*/
&IF PROVERSION >= "10.1C":U &THEN
routine-level on error undo, throw.
&ENDIF

define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: xlssn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/xlssn.p $":U .
define variable vss-description as character no-undo initial "Импорт серийных номеров для параметра tsd-list из excel".
{ cmp/vssrevis.i }
{ cmp/library.i }


define output parameter pOutSN as character no-undo.


define variable mExcelApplication as component-handle no-undo. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
define variable mWorkBook         as component-handle no-undo. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
define variable mWorkSheet        as component-handle no-undo. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
define variable mMaxNoLine        as integer          initial 10 no-undo. /* Максимально пропусков */
define variable mFileName         as character        no-undo.

&IF PROVERSION >= "10.1C":U &THEN
run proc-main in this-procedure.
catch mError as Progress.Lang.Error:
  return error
    (if mError:GetMessage(1) > "":U then mError:GetMessage(1) 
    else
    (if return-value > "":U then return-value 
    else "Неизвестная системная ошибка")).
end catch.   
finally:
  mWorkbook:Close(false) no-error.
  release object mWorkSheet no-error.
  release object mWorkbook no-error.
  mExcelApplication:QUIT() no-error.
  release object mExcelApplication no-error.
end finally.
&ELSE
define variable mError as character no-undo.
run proc-main in this-procedure no-error.
if error-status:error then mError =
    (if error-status:get-message(1) > "":U then error-statu:get-message(1) 
    else
    (if return-value > "":U then return-value 
    else "Неизвестная системная ошибка")).
mWorkbook:Close(false) no-error.
release object mWorkSheet no-error.
release object mWorkbook no-error.
mExcelApplication:QUIT() no-error.
release object mExcelApplication no-error.
if length(mError) > 0 then return error mError.
&ENDIF


procedure proc-main:
  /* Основной блок */
  define variable vFileName as character no-undo.
  define variable varlog    as logical   no-undo.

  system-dialog get-file mFileName
    title "Выберите файл заказа"
    filters "Excel"         "*.xls",
    "Все файлы"      "*.*"
    update varlog.
  if not varlog then return error.

  vFilename = search(mFileName) .
  
  if vFileName <> ? then .
  else return error substitute("Не найден файл &1", mFileName).
    
  create "Excel.Application":U mExcelApplication no-error.
      if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
  assign
    mExcelApplication:DisplayAlerts = no
    mWorkbook                       = mExcelApplication:WorkBooks:Add(vFileName)
    mWorkSheet                      = mWorkbook:Sheets:Item(1)
    .
    
  run proc-read-tt in this-procedure.
    
  /*  TEMP-TABLE ttFin-doc:WRITE-XML("LONGCHAR":U, oXML, YES, "windows-1251":U).  */
  /*COPY-LOB oXml TO FILE "c:\temp\pp.xml".*/ 
        
  mWorkbook:Close(true) no-error.
  release object mWorkSheet no-error.
  release object mWorkbook no-error.
  mExcelApplication:QUIT() no-error.
  release object mExcelApplication no-error.
  pOutSN = trim (pOutSN,";").
   
end procedure.

procedure proc-read-tt:
  /* Чтение временной таблицы */
   
  define variable vLine   as integer   no-undo.
  define variable vstr    as character no-undo.
  define variable vChLine as character no-undo.
    
  loopbl:
  do vLine = 5 to 1000000:
    assign
      vChLine = string(vLine)
      .
    vstr = mWorkSheet:Range("B":U + vChLine):text.
    if not (vstr = "" or vstr = ?)
    then pOutSN   = pOutSN + ";" + mWorkSheet:Range("B":U + vChLine):value no-error.
    else leave loopbl.                
  end.   

end procedure.    
