block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
PROCEDURE CreateDCA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER lpszDriver   AS CHARACTER.
  DEFINE INPUT  PARAMETER lpszDevice   AS CHARACTER.
  DEFINE INPUT  PARAMETER lpszOutput   AS long.
  DEFINE INPUT  PARAMETER lpInitData   AS long.
  DEFINE RETURN PARAMETER hDC          AS long.
END PROCEDURE.
PROCEDURE DeleteDC EXTERNAL "gdi32" :
   DEFINE INPUT  PARAMETER hdc         AS LONG.
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE DocumentPropertiesA EXTERNAL "winspool.drv" :
  DEFINE INPUT  PARAMETER HWND           AS LONG.
  DEFINE INPUT  PARAMETER hPrinter       AS LONG.
  DEFINE INPUT  PARAMETER pDeviceName    AS CHARACTER.
  DEFINE INPUT  PARAMETER pDevmodeOutput AS LONG.
  DEFINE INPUT  PARAMETER pDevmodeInput  AS LONG.
  DEFINE INPUT  PARAMETER fMode          AS LONG.
  DEFINE RETURN PARAMETER ReturnValue    AS LONG.
END PROCEDURE.
PROCEDURE GetProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpAppName        AS CHAR.
  DEFINE INPUT  PARAMETER lpKeyName        AS CHAR.
  DEFINE INPUT  PARAMETER lpDefault        AS CHAR.
  DEFINE OUTPUT PARAMETER lpReturnedString AS CHAR.
  DEFINE INPUT  PARAMETER nSize            AS LONG.
  DEFINE RETURN PARAMETER nReturnedChars   AS LONG.
END PROCEDURE.
PROCEDURE StartDocA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc   AS LONG.
  DEFINE INPUT  PARAMETER lpdi  AS LONG.
  DEFINE RETURN PARAMETER JobId AS LONG.
END PROCEDURE.
PROCEDURE EndDoc EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE StartPage EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE EndPage EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE TextOutA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE INPUT  PARAMETER nXstart     AS LONG.
  DEFINE INPUT  PARAMETER nYstart     AS LONG.
  DEFINE INPUT  PARAMETER lpString    AS CHAR.
  DEFINE INPUT  PARAMETER cbString    AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE SetTextAlign EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc           AS LONG.
  DEFINE INPUT  PARAMETER fMode         AS LONG.
  DEFINE RETURN PARAMETER fPreviousMode AS LONG.
END PROCEDURE.
PROCEDURE GetDeviceCaps EXTERNAL "GDI32" :
   DEFINE INPUT  PARAMETER hdc    AS LONG.
   DEFINE INPUT  PARAMETER nIndex AS LONG.
   DEFINE RETURN PARAMETER dwCaps AS LONG.
END PROCEDURE.
PROCEDURE MoveToEx EXTERNAL "gdi32" :
   DEFINE INPUT  PARAMETER hdc         AS LONG.
   DEFINE INPUT  PARAMETER X           AS LONG.
   DEFINE INPUT  PARAMETER Y           AS LONG.
   DEFINE INPUT  PARAMETER lpPoint     AS LONG.
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE LineTo EXTERNAL "gdi32" :
   DEFINE INPUT  PARAMETER hdc         AS LONG.
   DEFINE INPUT  PARAMETER X           AS LONG.
   DEFINE INPUT  PARAMETER Y           AS LONG.
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE SelectObject EXTERNAL "gdi32" :
   DEFINE INPUT  PARAMETER hdc         AS LONG.
   DEFINE INPUT  PARAMETER hgdiobj     AS LONG.
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE DeleteObject EXTERNAL "gdi32" :
   DEFINE INPUT  PARAMETER hObject     AS LONG.
   DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE GetTextMetricsA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE INPUT  PARAMETER lpTm        AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE CreateFontA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER nHeight            AS LONG.
  DEFINE INPUT  PARAMETER nWidth             AS LONG.
  DEFINE INPUT  PARAMETER nEscapement        AS LONG.
  DEFINE INPUT  PARAMETER nOrientation       AS LONG.
  DEFINE INPUT  PARAMETER fnWeight           AS LONG.
  DEFINE INPUT  PARAMETER fdwItalic          AS LONG.
  DEFINE INPUT  PARAMETER fdwUnderline       AS LONG.
  DEFINE INPUT  PARAMETER fdwStrikeOut       AS LONG.
  DEFINE INPUT  PARAMETER fdwCharSet         AS LONG.
  DEFINE INPUT  PARAMETER fdwOutputPrecision AS LONG.
  DEFINE INPUT  PARAMETER fdwClipPrecision   AS LONG.
  DEFINE INPUT  PARAMETER fdwQuality         AS LONG.
  DEFINE INPUT  PARAMETER fdwPitchAndFamily  AS LONG.
  DEFINE INPUT  PARAMETER lpszFace           AS CHAR.
  DEFINE RETURN PARAMETER hFont              AS LONG.
END PROCEDURE.
PROCEDURE MulDiv EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER nNumber      AS LONG.
  DEFINE INPUT  PARAMETER nNumerator   AS LONG.
  DEFINE INPUT  PARAMETER nDenominator AS LONG.
  DEFINE RETURN PARAMETER ReturnValue  AS LONG.
END PROCEDURE.
define input  parameter  p-fontname as character no-undo .
define input  parameter  p-fontsize as integer   no-undo .
define input  parameter  p-fonttype as character no-undo .
define output parameter  p-LineHeight as integer no-undo .
define output parameter  p-LineWidth  as integer no-undo .
define variable devcap           as integer no-undo.
define variable emheight         as integer no-undo.
define variable hPrinterDC       as integer no-undo.
define variable hBodyFont        as integer no-undo.
define variable ReturnValue      as integer no-undo.
define variable p-Devicename     as character    no-undo init "" .
define variable lpDevmode        as memptr  no-undo.
define variable devicespecs      as character    no-undo.
define variable p-docname        as character no-undo .
define variable lpdocname        as memptr  no-undo.
define variable lpdocinfo        as memptr  no-undo.
define variable lpDefaultDevmode as memptr  no-undo.
define variable p-Landscape      as logical   no-undo init false .
define variable hStockFont       as integer no-undo.
define variable v-ft as integer   no-undo .
define variable v-italic as integer   no-undo init 0.
define stream fontt .
p-docname = "font.ttt" .
output stream fontt to value (p-docname) .
put stream fontt unformatted "":U skip.
output stream fontt close.
  FILE-INFO:FILE-NAME = p-docname .
  IF FILE-INFO:FULL-PATHNAME = ? THEN RETURN error "file_not_found" .
    if p-devicename = "" then do:
        devicespecs = fill("x", 255).
        run GetProfileStringA
          ( "windows":U,
            "device":U,
            "-unknown-,,":U,
            output devicespecs,
            length (devicespecs),
            output ReturnValue )
            .
        p-devicename = entry (1, devicespecs).
    end.
    SET-SIZE(lpdocname)     = LENGTH(p-docname) + 1.
    PUT-STRING(lpdocname,1) = p-docname.
    SET-SIZE(lpdocinfo)     = 12.
    PUT-LONG(lpdocinfo, 1)  = GET-SIZE(lpdocinfo).
    PUT-LONG(lpdocinfo, 5)  = GET-POINTER-VALUE(lpdocname).
    PUT-LONG(lpdocinfo, 9)  = 0.
    run DocumentPropertiesA
      ( 0,
        0,
        p-devicename,
        0,
        0,
        0,
        output ReturnValue)
        .
    SET-SIZE(lpDefaultDevMode) = ReturnValue.
    SET-SIZE(lpDevMode)        = ReturnValue.
    RUN DocumentPropertiesA
       (0,
        0,
        p-devicename,
        GET-POINTER-VALUE(lpDefaultDevMode),
        0,
        2,
        output ReturnValue )
        .
    PUT-LONG (lpDefaultDevMode, 32 +  9) = 1.
    IF p-Landscape THEN
       PUT-SHORT(lpDefaultDevMode, 32 + 13) = 2.
    ELSE
       PUT-SHORT(lpDefaultDevMode, 32 + 13) = 1.
    RUN DocumentPropertiesA
       (0,
        0,
        p-devicename,
        GET-POINTER-VALUE(lpDevMode),
        GET-POINTER-VALUE(lpDefaultDevMode),
        8 + 2,
        output ReturnValue)
        .
    RUN CreateDCA
      ("WINSPOOL":U,
        p-devicename,
        0,
        GET-POINTER-VALUE(lpDevMode),
        OUTPUT hPrinterDC)
        .
    SET-SIZE(lpDefaultDevMode)    = 0.
    SET-SIZE(lpDevMode) = 0.
    SET-SIZE(lpdocinfo) = 0.
    SET-SIZE(lpdocname) = 0.
  run GetDeviceCaps (hPrinterDC, 90, OUTPUT devcap).
  run MulDiv (p-fontsize, devcap, 72, OUTPUT emheight).
  emheight = 0 - emheight.
  if caps (p-fonttype) = "BOLD" or caps (p-fonttype) begins "BOLD"
    then  v-ft = 700 .
    else  v-ft = 400 .
  if lookup ( "ITALIC" , caps(p-fonttype)) > 0 then v-italic = 1.
  RUN CreateFontA
    ( emheight,
      0,
      0,
      0,
      v-ft,
      v-italic,
      0,
      0,
      0,
      0,
      0,
      2,
      1 + 0,
      p-fontname ,
      OUTPUT hBodyFont)
      .
  IF hBodyFont <> 0 then do:
     run SelectObject  ( input  hPrinterDC, input  hBodyFont, output hStockFont ).
     run GetSimbolSize ( output p-LineHeight , output p-LineWidth ).
  end.
  run DeleteObject (input hBodyFont,  OUTPUT ReturnValue ).
  run DeleteDC     (input hPrinterDC, OUTPUT ReturnValue ).
  hPrinterDC = 0.
  os-delete value( p-docname  ) .
PROCEDURE GetSimbolSize :
define output parameter p-h as integer.
define output parameter p-w as integer.
define variable  lpTm AS MEMPTR NO-UNDO.
  SET-SIZE(lpTM) = 15 * 4 + 5.
  run GetTextMetricsA
       (INPUT  hPrinterDC,
        INPUT  GET-POINTER-VALUE(lpTM),
        OUTPUT ReturnValue)
        .
  p-h  = GET-LONG(lpTM, 1).
  p-w  = GET-LONG(lpTM, 21).
  SET-SIZE(lpTM)=0.
END PROCEDURE.
