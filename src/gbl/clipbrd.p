block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clipbrd.p $
$Archive: gbl/clipbrd.p $

Записать строку в буфер обмена (clipboard)

Автор: Перваков Михаил Сергеевич
Дата создания: 06/23/05
Author: Mikhail Pervakov
Creation date: 06/23/05

Строка помещается в двух форматах - в ANSI и в UNICODE
Используется факт, что Trade House по умолчанию работает
в кодировке ANSI (Windows 1251 для русских пользователей).

#define CF_TEXT 1
#define CF_UNICODETEXT  13
#define GMEM_MOVEABLE 2


    if (!OpenClipboard(hwndMain))
        return FALSE;
    EmptyClipboard();

    // Allocate a global memory object for the text.

    hglbCopy = GlobalAlloc(GMEM_MOVEABLE, (cch + 1) * sizeof(TCHAR));
    if (hglbCopy == NULL)
    {
        CloseClipboard();
        return FALSE;
    }

    // Lock the handle and copy the text to the buffer.
    lptstrCopy = GlobalLock(hglbCopy);
    memcpy(lptstrCopy, &pbox->atchLabel[ich1], cch * sizeof(TCHAR));
    lptstrCopy[cch] = (TCHAR) 0;    // null character
    GlobalUnlock(hglbCopy);

    // Place the handle on the clipboard.
    SetClipboardData(CF_TEXT, hglbCopy);

    // Close the clipboard.
    CloseClipboard();

    return TRUE;

*/

define input  parameter p-text as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clipbrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/clipbrd.p $":U .
define variable vss-description as character no-undo init "Записать строку в буфер обмена (clipboard)".
{ cmp/vssrevis.i }
{ gbl/winfunc.i  }

define variable v-return-value as integer   no-undo .

do
on error undo, return error return-value
:
  run OpenClipboard
    (input  0
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции OpenClipboard" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run EmptyClipboard
    (output v-return-value
    ) .

  define variable hMem-unicode          as integer   no-undo .
  define variable hMem-ansi             as integer   no-undo .
  define variable hGlobal-unicode       as integer   no-undo .
  define variable hGlobal-ansi          as integer   no-undo .
  define variable v-buffer-size-unicode as integer   no-undo .
  define variable v-buffer-size-ansi    as integer   no-undo .

  assign
    v-buffer-size-unicode = (length(p-text) + 1) * 2
    v-buffer-size-ansi    = length(p-text) + 1
  .

  run GlobalAlloc
    (input  2   /* GMEM_MOVEABLE */
    ,input  v-buffer-size-unicode
    ,output hMem-unicode
    ) .
  if hMem-unicode = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции GlobalAlloc" skip
      ShowLastError() skip
      view-as alert-box error .
    run CloseClipboard
      (output v-return-value
      ) .
    undo, return error return-value .
  end.

  run GlobalAlloc
    (input  2   /* GMEM_MOVEABLE */
    ,input  v-buffer-size-ansi
    ,output hMem-ANSI
    ) .
  if hMem-ANSI = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции GlobalAlloc" skip
      ShowLastError() skip
      view-as alert-box error .
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    undo, return error return-value .
  end.


  run GlobalLock
    (input  hMem-unicode
    ,output hGlobal-unicode
    ) .
  run GlobalLock
    (input  hMem-ansi
    ,output hGlobal-ansi
    ) .

  define variable v-data as memptr no-undo .
  define variable v-data-ansi as memptr no-undo .
  assign
    set-size(v-data) = length(p-text) + 1
    set-pointer-value(v-data-ansi) = hGlobal-ansi
  .
  assign
    put-string(v-data, 1) = p-text
    put-string(v-data-ansi, 1) = p-text
  .

  run MultiByteToWideChar
    (input  0 /* CP_ACP */             /* code page */
    ,input  0                          /* performance and mapping flags */
    ,input  get-pointer-value(v-data)  /* address of wide-character string */
    ,input  -1                         /* number of characters in string */
    ,input  hGlobal-unicode            /* address of buffer for new string */
    ,input  v-buffer-size-unicode      /* size of buffer */
    ,output v-return-value             /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
    ) .
  if v-return-value = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры MultiByteToWideChar" skip
      view-as alert-box error .
  end.

  assign
    set-size(v-data) = 0
  .

  run GlobalUnlock
    (input  hMem-unicode
    ,output v-return-value
    ) .
  run GlobalUnlock
    (input  hMem-ansi
    ,output v-return-value
    ) .

  run SetClipboardData
    (input  1 /* CF_TEXT */
    ,input  hMem-ansi
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    run GlobalFree
      (input  hMem-ansi
      ,output v-return-value
      ) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции SetClipboardData" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run SetClipboardData
    (input  13 /* CF_UNICODETEXT */
    ,input  hMem-unicode
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции SetClipboardData" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run CloseClipboard
    (output v-return-value
    ) .
end.

PROCEDURE MultiByteToWideChar EXTERNAL "kernel32.dll" :
  define input  parameter uCodePage      as long . /* code page */
  define input  parameter dwFlags        as long . /* performance and mapping flags */
  define input  parameter lpMultiByteStr as long . /* address of wide-character string */
  define input  parameter cbMubtiByte    as long . /* number of characters in string */
  define input  parameter lpWideCharStr  as long . /* address of buffer for new string */
  define input  parameter cbMultiByte    as long . /* size of buffer */
  define return parameter iRetCode       as long . /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
END.

PROCEDURE GlobalAlloc EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER uFlags     AS LONG .
  DEFINE INPUT  PARAMETER dwBytes    AS LONG .
  DEFINE RETURN PARAMETER hMem       AS LONG .
END PROCEDURE.

PROCEDURE GlobalFree EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hMem   AS LONG .
  DEFINE RETURN PARAMETER Result AS LONG .
END PROCEDURE.

PROCEDURE GlobalLock EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hMem       AS LONG .
  DEFINE RETURN PARAMETER hGlobal    AS LONG .
END PROCEDURE.

PROCEDURE GlobalUnlock EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hGlobal     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.

PROCEDURE OpenClipboard EXTERNAL "user32.dll" :
  DEFINE INPUT  PARAMETER hWnd        AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.

PROCEDURE SetClipboardData EXTERNAL "user32.dll" :
  DEFINE INPUT  PARAMETER uFormat     AS LONG .
  DEFINE INPUT  PARAMETER hMem        AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.

PROCEDURE EmptyClipboard EXTERNAL "user32.dll" :
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.

PROCEDURE CloseClipboard EXTERNAL "user32.dll" :
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.