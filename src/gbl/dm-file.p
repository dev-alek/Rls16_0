block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dm-file.p $
$Archive: gbl/dm-file.p $

Диалог выбора нескольких файлов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/06
Author: Bakhtadze Natalya
Creation date: 08/06/06

*/

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
{ cmp/vssrevis.i }


DEFINE VARIABLE Flags           AS INTEGER NO-UNDO.
DEFINE VARIABLE lpOfn           AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrFilter     AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrTitle      AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrInitialDir AS MEMPTR  NO-UNDO.
DEFINE VARIABLE lpstrFile       AS MEMPTR  NO-UNDO.
DEFINE VARIABLE offset          AS INTEGER NO-UNDO.


&GLOBAL-DEFINE OFN_OVERWRITEPROMPT  2
&GLOBAL-DEFINE OFN_HIDEREADONLY     4
&GLOBAL-DEFINE OFN_NOCHANGEDIR      8
&GLOBAL-DEFINE OFN_ALLOWMULTISELECT 512
&GLOBAL-DEFINE OFN_PATHMUSTEXIST    2048
&GLOBAL-DEFINE OFN_FILEMUSTEXIST    4096
&GLOBAL-DEFINE OFN_NOREADONLYRETURN 32768
&GLOBAL-DEFINE OFN_EXPLORER         524288

PROCEDURE GetOpenFileNameA EXTERNAL "comdlg32.dll" :
  DEFINE INPUT  PARAMETER lpOfn   AS LONG.
  DEFINE RETURN PARAMETER pReturn AS LONG.
END PROCEDURE.


  /* Flags controls the behaviour and appearance of the dialog-box.
           There is much room for experiments. This combination works nice: */
  Flags = {&OFN_ALLOWMULTISELECT} +
          {&OFN_EXPLORER} +
          {&OFN_NOCHANGEDIR}.

  /* convert the "|"-separated list of filters to a CHR(0)-separated
     list and make sure it's terminated with a double CHR(0): */
  FilterList = TRIM(FilterList,"|") + "|". /* this will cause the double CHR(0) */
  SET-SIZE(lpstrFilter)      = LENGTH(FilterList) + 1.
  PUT-STRING(lpstrFilter, 1) = FilterList.
  DO offset=1 TO GET-SIZE(lpstrFilter) :
     IF GET-BYTE(lpstrFilter,offset)=124 /* =ASC("|") */ THEN
        PUT-BYTE(lpstrFilter,offset)=0.
  END.

  /* get memory-pointers to the string parameters: */
  SET-SIZE(lpstrFile)   = 1024. /* room for a couple of files...     */
  PUT-BYTE(lpstrFile,1) = 0.    /* don't initialize dialog to a file */

  SET-SIZE(lpstrTitle) = LENGTH(DialogTitle) + 1.
  PUT-STRING(lpstrTitle,1) = DialogTitle.

  IF InitialDirectory NE ? THEN DO:
     SET-SIZE(lpstrInitialDir) = LENGTH(InitialDirectory) + 1.
     PUT-STRING(lpstrInitialDir,1) = InitialDirectory.
  END.

  /* create and initialize an OPENFILENAME structure: */
  SET-SIZE(lpOfn) = 76. /* = {&OPENFILENAME_SIZE_VERSION_400}
                             to be used in NT4 and Windows 95/98.
                             Windows 2000 supports a couple more fields. */

/* size */              PUT-LONG (lpOfn, 1) = GET-SIZE(lpOfn).
/* hwndOwner */         PUT-LONG (lpOfn, 5) = (if window-hwnd = ? then CURRENT-WINDOW:HWND else window-hwnd).
/* hInstance */         PUT-LONG (lpOfn, 9) = 0.
/* lpstrFilter */       PUT-LONG (lpOfn,13) = GET-POINTER-VALUE(lpstrFilter).
/* lpstrCustomFilter */ PUT-LONG (lpOfn,17) = 0.
/* nMaxCustFilter */    PUT-LONG (lpOfn,21) = 0.
/* nFilterIndex */      PUT-LONG (lpOfn,25) = 0.
/* lpstrFile */         PUT-LONG (lpOfn,29) = GET-POINTER-VALUE(lpstrFile).
/* nMaxFile */          PUT-LONG (lpOfn,33) = GET-SIZE(lpstrFile).
/* lpstrFileTitle */    PUT-LONG (lpOfn,37) = 0.
/* nMaxFileTitle */     PUT-LONG (lpOfn,41) = 0.
/* lpstrInitialDir */   PUT-LONG (lpOfn,45) = GET-POINTER-VALUE(lpstrInitialDir).
/* lpstrTitle */        PUT-LONG (lpOfn,49) = GET-POINTER-VALUE(lpstrTitle).
/* flags */             PUT-LONG (lpOfn,53) = Flags.

/* nFileOffset */       PUT-SHORT(lpOfn,57) = 0.
/* nFileExtension */    PUT-SHORT(lpOfn,59) = 0.
/* lpstrDefExt */       PUT-LONG (lpOfn,61) = 0.
/* lCustData */         PUT-LONG (lpOfn,65) = 0.
/* lpfnHook */          PUT-LONG (lpOfn,69) = 0.
/* lpTemplateName */    PUT-LONG (lpOfn,73) = 0.

  /* run the dialog: */
  RUN GetOpenFileNameA (GET-POINTER-VALUE(lpOfn), OUTPUT OK).

  /* release memory: */
  SET-SIZE(lpstrFilter)     = 0.
  SET-SIZE(lpOfn)           = 0.
  SET-SIZE(lpstrTitle)      = 0.
  SET-SIZE(lpstrInitialDir) = 0.

  /* lpstrFilter now contains a path, followed by CHR(0), followed
     by a CHR(0)-separated list of filenames, terminated by a double CHR(0).
     Unless the user selected only one file: then lpstrFilter will simply
     contain the fully-qualified filename.
     Either way, let's convert the result to a comma-separated list of
     fully-qualified filenames: */

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