block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exfont.p $
$Archive: rep/exfont.p $

Получение размера шрифта

Автор: Чернова Светлана Александровна
Дата создания: 07/31/06
Author: Svetlana Chernova
Creation date: 07/31/06

*/
{ gbl/windows.i }
{ rep/fontapi.i } /*  WIN32 API definitions   */

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
define variable p-Devicename     as character    no-undo init "" .  /* if "" then default printer           */
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

    /* ask for the size of the devmode structure: */
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

    /* get the default contents of the devmode structure: */
    RUN DocumentPropertiesA
       (0,
        0,
        p-devicename,
        GET-POINTER-VALUE(lpDefaultDevMode),
        0,
        {&DM_OUT_BUFFER},
        output ReturnValue )
        .

    /* specify what you want to change: */
    PUT-LONG (lpDefaultDevMode, {&CCHDEVICENAME} +  9) = {&DM_ORIENTATION}.
    IF p-Landscape THEN
       PUT-SHORT(lpDefaultDevMode, {&CCHDEVICENAME} + 13) = {&DMORIENT_LANDSCAPE}.
    ELSE
       PUT-SHORT(lpDefaultDevMode, {&CCHDEVICENAME} + 13) = {&DMORIENT_PORTRAIT}.

    /* create a merged devmode: */
    RUN DocumentPropertiesA
       (0,
        0,
        p-devicename,
        GET-POINTER-VALUE(lpDevMode),
        GET-POINTER-VALUE(lpDefaultDevMode),
        {&DM_IN_BUFFER} + {&DM_OUT_BUFFER},
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

  run GetDeviceCaps (hPrinterDC, {&LOGPIXELSY}, OUTPUT devcap).
  run MulDiv (p-fontsize, devcap, 72, OUTPUT emheight).
  emheight = 0 - emheight.

  if caps (p-fonttype) = "BOLD" or caps (p-fonttype) begins "BOLD"
    then  v-ft = 700 .
    else  v-ft = 400 .
  if lookup ( "ITALIC" , caps(p-fonttype)) > 0 then v-italic = 1.

  RUN CreateFontA
    ( emheight,
      0,           /* width (0=default)                       */
      0,           /* escapement                              */
      0,           /* orientation                             */
      v-ft,        /* weight: LIGHT=300, NORMAL=400, BOLD=700 */
      v-italic,    /* italics                                 */
      0,           /* underline                               */
      0,           /* strikeout                               */
      {&ANSI_CHARSET},
      {&OUT_DEFAULT_PRECIS},
      {&CLIP_DEFAULT_PRECIS},
      {&PROOF_QUALITY},
      {&FIXED_PITCH} + {&FF_DONTCARE},
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
  /*
  message "ReturnValue" ReturnValue skip
     GET-LONG(lpTM, 1)  '  1 ' skip
     GET-LONG(lpTM, 2)  '  2 ' skip
     GET-LONG(lpTM, 3)  '  3 ' skip
     GET-LONG(lpTM, 4)  '  4 ' skip
     GET-LONG(lpTM, 5)  '  5 ' skip
     GET-LONG(lpTM, 6)  '  6 ' skip
     GET-LONG(lpTM, 7)  '  7 ' skip
     GET-LONG(lpTM, 8)  '  8 ' skip
     GET-LONG(lpTM, 9)  '  9 ' skip
     GET-LONG(lpTM,10)  ' 10 ' skip
     GET-LONG(lpTM,11)  ' 11 ' skip
     GET-LONG(lpTM,12)  ' 12 ' skip
     GET-LONG(lpTM,13)  ' 13 ' skip
     GET-LONG(lpTM,14)  ' 14 ' skip
     GET-LONG(lpTM,15)  ' 15 ' skip
     GET-LONG(lpTM,16)  ' 16 ' skip
     GET-LONG(lpTM,17)  ' 17 ' skip
     GET-LONG(lpTM,18)  ' 18 ' skip
     GET-LONG(lpTM,19)  ' 19 ' skip
     GET-LONG(lpTM,20)  ' 20 ' skip
     GET-LONG(lpTM,21)  ' 21 ' skip
     GET-LONG(lpTM,22)  ' 22 ' skip
     GET-LONG(lpTM,23)  ' 23 ' skip
     GET-LONG(lpTM,24)  ' 24 ' skip
     GET-LONG(lpTM,25)  ' 25 ' skip
     GET-LONG(lpTM,26)  ' 26 ' skip
     GET-LONG(lpTM,27)  ' 27 ' skip
     GET-LONG(lpTM,28)  ' 28 ' skip
     GET-LONG(lpTM,29)  ' 29 ' skip
     GET-LONG(lpTM,30)  ' 30 ' skip
     GET-LONG(lpTM,31)  ' 31 ' skip
     GET-LONG(lpTM,32)  ' 32 ' skip
     GET-LONG(lpTM,33)  ' 33 ' skip
     GET-LONG(lpTM,34)  ' 34 ' skip
     GET-LONG(lpTM,35)  ' 35 ' skip
     GET-LONG(lpTM,36)  ' 36 ' skip
     GET-LONG(lpTM,37)  ' 37 ' skip
     GET-LONG(lpTM,38)  ' 38 ' skip
     GET-LONG(lpTM,39)  ' 39 ' skip
     GET-LONG(lpTM,40)  ' 40 ' skip
     GET-LONG(lpTM,40)  ' 40 ' skip
     GET-LONG(lpTM,41)  ' 41 ' skip
     GET-LONG(lpTM,42)  ' 42 ' skip
     GET-LONG(lpTM,43)  ' 43 ' skip
     GET-LONG(lpTM,44)  ' 44 ' skip
     GET-LONG(lpTM,45)  ' 45 ' skip
     GET-LONG(lpTM,46)  ' 46 ' skip
     GET-LONG(lpTM,47)  ' 47 ' skip
     GET-LONG(lpTM,48)  ' 48 ' skip
     GET-LONG(lpTM,49)  ' 49 ' skip
     GET-LONG(lpTM,50)  ' 50 ' skip
     GET-LONG(lpTM,51)  ' 51 ' skip
     GET-LONG(lpTM,52)  ' 52 ' skip
     GET-LONG(lpTM,53)  ' 53 ' skip
     GET-LONG(lpTM,54)  ' 54 ' skip
     GET-LONG(lpTM,55)  ' 55 ' skip
     GET-LONG(lpTM,56)  ' 56 ' skip
     GET-LONG(lpTM,57)  ' 57 ' skip
     GET-LONG(lpTM,58)  ' 58 ' skip
     GET-LONG(lpTM,59)  ' 59 ' skip
     GET-LONG(lpTM,60)  ' 60 ' skip
     GET-LONG(lpTM,60)  ' 60 ' skip
     GET-LONG(lpTM,61)  ' 61 ' skip
     GET-LONG(lpTM,62)  ' 62 ' skip
    .
    */
  SET-SIZE(lpTM)=0.

END PROCEDURE.