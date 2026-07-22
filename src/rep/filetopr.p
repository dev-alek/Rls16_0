block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: filetopr.p $
$Archive: rep/filetopr.p $

Отчета, сохраненного в файле

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06


*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filetopr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/filetopr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }

define variable InputFileName    as  char     no-undo.
define variable g#report-num as integer no-undo .

define stream  i_inp1.

define variable  text-string     as  char    FORMAT "x({&DOS_CW_2})" no-undo .
define variable  CurrPrinterName as  char    no-undo .

define variable  PageSize as  integer initial 0 no-undo .

define variable  ExitCode as  logical initial no no-undo .
define variable glog as logical no-undo .

SYSTEM-DIALOG GET-FILE InputFileName
TITLE      "Укажите файл ..."
FILTERS "Текстовый файл (*.txt)"   "*.txt",
                "Все файлы (*.*)"   "*.*"
MUST-EXIST
USE-FILENAME
UPDATE glog.
if glog = true then    do:
  InputFileName = trim( string( InputFileName ) ) .
  INPUT stream i_inp1 FROM value ( InputFileName ).

  MM1:
  REPEAT on endkey undo, leave :
    DO on endkey undo, leave:
        IMPORT stream  i_inp1 UNFORMATTED text-string NO-ERROR.
    END.
    IF ERROR-STATUS:ERROR THEN UNDO, LEAVE.

    if integer ( asc ( substring ( text-string, 1, 1 ) ) ) = 12 then     /* = 0C (hex) = 14 (octal) */  do:
      ExitCode = yes .
      LEAVE MM1 .
    end.
    text-string = "".
    PageSize = PageSize + 1 .
  END.
  INPUT stream i_inp1 CLOSE.

  if not ExitCode then  PageSize = {&CS_PS} .
  RUN get-report-num IN PARPARENTPROC (OUTPUT g#report-num).
  OS-COPY value( InputFileName )
                value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) ) .

  if PageSize = {&LS_PS_A4} then
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 12
                                          ).

  else
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 4
                                          ).
end. /*if glog = true then    do:*/
