/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$
*/
{ cmp/str-glbl.i }
{ ref/codepar.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define new global Shared variable opn_win as logical no-undo init NO. 
define variable mCodeTrg as class ibs.th.ref.code.code_trg no-undo.
mCodeTrg = new ibs.th.ref.code.code_trg({&lookup}).
mCodeTrg:formLable(1, 1, "Код").              
mCodeTrg:formLable(1, 3, "Файл").              
mCodeTrg:formLable(1, 6, "XML").
mCodeTrg:parparentproc = Parparentproc.
mCodeTrg:menuHandle = this-procedure.  
mCodeTrg:addMenu(1, "Восстановление файла", ",Экспорт в XML,").
mCodeTrg:parent = "XML_backup".
mCodeTrg:startlevel = num-entries(mCodeTrg:parent, {&delim-par}).
mCodeTrg:MaxLevel = mCodeTrg:startlevel.
mCodeTrg:title = "Файл для восстановления".
mCodeTrg:filter = " and code.code = " + quoter(icode).
mCodeTrg:Mode = {&lookup}. 

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

