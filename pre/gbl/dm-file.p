block-level on error undo, throw.
DEFINE INPUT  PARAMETER FilterList       AS CHARACTER NO-UNDO.
DEFINE INPUT  PARAMETER InitialDirectory AS CHARACTER NO-UNDO.
DEFINE INPUT  PARAMETER DialogTitle      AS CHARACTER NO-UNDO.
define input  parameter window-hwnd      as integer   no-undo .
DEFINE OUTPUT PARAMETER FileNames        AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER OK               AS INTEGER   NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dm-file.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dm-file.p $":U .
define variable vss-description as character no-undo init "Диалог выбора нескольких файлов".
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
DEFINE VARIABLE Flags           AS INTEGER NO-UNDO.
DEFINE VARIABLE lpOfn           AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrFilter     AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrTitle      AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrInitialDir AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrFile       AS MEMPTR  NO-UNDO.
DEFINE VARIABLE offset          AS INTEGER NO-UNDO.
PROCEDURE GetOpenFileNameA EXTERNAL "comdlg32.dll" :
  DEFINE INPUT  PARAMETER lpOfn   AS LONG.
  DEFINE RETURN PARAMETER pReturn AS LONG.
END PROCEDURE.
  Flags = 512 +
          524288 +
          8.
  FilterList = TRIM(FilterList,"|") + "|".
  SET-SIZE(lpstrFilter)      = LENGTH(FilterList) + 1.
  PUT-STRING(lpstrFilter, 1) = FilterList.
  DO offset=1 TO GET-SIZE(lpstrFilter) :
     IF GET-BYTE(lpstrFilter,offset)=124  THEN
        PUT-BYTE(lpstrFilter,offset)=0.
  END.
  SET-SIZE(lpstrFile)   = 1024.
  PUT-BYTE(lpstrFile,1) = 0.
  SET-SIZE(lpstrTitle) = LENGTH(DialogTitle) + 1.
  PUT-STRING(lpstrTitle,1) = DialogTitle.
  IF InitialDirectory NE ? THEN DO:
     SET-SIZE(lpstrInitialDir) = LENGTH(InitialDirectory) + 1.
     PUT-STRING(lpstrInitialDir,1) = InitialDirectory.
  END.
  SET-SIZE(lpOfn) = 76.
              PUT-LONG (lpOfn, 1) = GET-SIZE(lpOfn).
         PUT-LONG (lpOfn, 5) = (if window-hwnd = ? then CURRENT-WINDOW:HWND else window-hwnd).
         PUT-LONG (lpOfn, 9) = 0.
       PUT-LONG (lpOfn,13) = GET-POINTER-VALUE(lpstrFilter).
 PUT-LONG (lpOfn,17) = 0.
    PUT-LONG (lpOfn,21) = 0.
      PUT-LONG (lpOfn,25) = 0.
         PUT-LONG (lpOfn,29) = GET-POINTER-VALUE(lpstrFile).
          PUT-LONG (lpOfn,33) = GET-SIZE(lpstrFile).
    PUT-LONG (lpOfn,37) = 0.
     PUT-LONG (lpOfn,41) = 0.
   PUT-LONG (lpOfn,45) = GET-POINTER-VALUE(lpstrInitialDir).
        PUT-LONG (lpOfn,49) = GET-POINTER-VALUE(lpstrTitle).
             PUT-LONG (lpOfn,53) = Flags.
       PUT-SHORT(lpOfn,57) = 0.
    PUT-SHORT(lpOfn,59) = 0.
       PUT-LONG (lpOfn,61) = 0.
         PUT-LONG (lpOfn,65) = 0.
          PUT-LONG (lpOfn,69) = 0.
    PUT-LONG (lpOfn,73) = 0.
  RUN GetOpenFileNameA (GET-POINTER-VALUE(lpOfn), OUTPUT OK).
  SET-SIZE(lpstrFilter)     = 0.
  SET-SIZE(lpOfn)           = 0.
  SET-SIZE(lpstrTitle)      = 0.
  SET-SIZE(lpstrInitialDir) = 0.
  IF OK NE 0 THEN DO:
    DEFINE VARIABLE cPath AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cList AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFile AS CHARACTER NO-UNDO.
    ASSIGN cPath  = GET-STRING(lpstrFile,1)
           offset = LENGTH(cPath) + 2.
    REPEAT:
      cFile = GET-STRING(lpstrFile, offset).
      IF cFile = "" THEN LEAVE.
      ASSIGN cList  = cList + '|' + cPath +  '\' + cFile
             offset = offset + LENGTH(cFile) + 1.
    END.
    ASSIGN cList     = TRIM(cList, "|")
           FileNames = IF cList = "" THEN cPath ELSE cList.
  END.
  SET-SIZE(lpstrFile) = 0.
