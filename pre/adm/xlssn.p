block-level on error undo, throw.
routine-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: xlssn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/xlssn.p $":U .
define variable vss-description as character no-undo initial "Импорт серийных номеров для параметра tsd-list из excel".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define output parameter pOutSN as character no-undo.
define variable mExcelApplication as component-handle no-undo.
define variable mWorkBook         as component-handle no-undo.
define variable mWorkSheet        as component-handle no-undo.
define variable mMaxNoLine        as integer          initial 10 no-undo.
define variable mFileName         as character        no-undo.
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
procedure proc-main:
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
  mWorkbook:Close(true) no-error.
  release object mWorkSheet no-error.
  release object mWorkbook no-error.
  mExcelApplication:QUIT() no-error.
  release object mExcelApplication no-error.
  pOutSN = trim (pOutSN,";").
end procedure.
procedure proc-read-tt:
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
