define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input  parameter Parparentproc  as handle    no-undo.
define input  parameter iMode          as character no-undo.
define input  parameter iParent        as character no-undo.
define input  parameter iCode          as character no-undo.
define input  parameter ititle         as character no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
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
define new global Shared variable opn_win as logical no-undo init NO.
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
mCodeTrg = new ibs.th.ref.code.code_trg('ПРОСМОТР':U).
mCodeTrg:formLable(1, 1, "Код").
mCodeTrg:formLable(1, 3, "Файл").
mCodeTrg:formLable(1, 6, "XML").
mCodeTrg:parparentproc = Parparentproc.
mCodeTrg:menuHandle = this-procedure.
mCodeTrg:addMenu(1, "Восстановление файла", ",Экспорт в XML,").
mCodeTrg:parent = "XML_backup".
mCodeTrg:startlevel = num-entries(mCodeTrg:parent, chr(4)).
mCodeTrg:MaxLevel = mCodeTrg:startlevel.
mCodeTrg:title = "Файл для восстановления".
mCodeTrg:filter = " and code.code = " + quoter(icode).
mCodeTrg:Mode = 'ПРОСМОТР':U.
if opn_win = YES then do:
    run menuitem_1_2  ( input this-procedure ).
end.
if opn_win = NO then do:
   opn_win = YES.
   mCodeTrg:brwcode().
end.
finally:
    opn_win = NO.
end finally.
procedure menuitem_1_2:
   define input  parameter iBuff as handle no-undo.
   define variable cSaveFile as character no-undo.
   define variable lCommit   as logical   no-undo.
   opn_win = YES.
   cSaveFile = substring(icode, r-index(icode, " ") + 1).
   SYSTEM-DIALOG GET-FILE cSaveFile
       TITLE "Сохранить XML-файл"
       FILTERS
           "XML-файлы (*.xml)" "*.xml",
           "Все файлы (*.*)"   "*.*"
       ASK-OVERWRITE
       SAVE-AS
       USE-FILENAME
       UPDATE lCommit
       DEFAULT-EXTENSION "xml".
   IF NOT lCommit THEN RETURN.
   cSaveFile = TRIM(cSaveFile).
   if index(cSaveFile, " ") > 0 then do:
     message "Имя файла не должно содержать пробелы" view-as alert-box .
    return.
   end.
  find first code where code.parent eq iparent and code.code eq icode no-lock no-error.
  if available code then do:
     define variable RXML as longchar no-undo.
     RXML = code.misc3.
     copy-lob from RXML to file cSaveFile.
     if error-status:error then
         message "Ошибка сохранения файла:" view-as alert-box.
     else  message  "Файл сохранён:" cSaveFile view-as alert-box .
   end.
end.
