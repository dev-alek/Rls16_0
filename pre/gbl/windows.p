block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: windows.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/windows.p $":U .
define variable vss-description as character no-undo init "windows.p".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
on delete of this-procedure do:
  assign
    hpApi = ?
  .
end.
PROCEDURE AdjustWindowRect EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER lpRect       AS LONG.
  DEFINE INPUT  PARAMETER dwstyle      AS LONG.
  DEFINE INPUT  PARAMETER bMenu        AS long.
  DEFINE RETURN PARAMETER ReturnValue  AS long.
END PROCEDURE.
PROCEDURE ClientToScreen EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER win-handle  AS long.
  DEFINE INPUT  PARAMETER lppoint     AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE CreateProcessA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpApplicationName    AS LONG.
  DEFINE INPUT  PARAMETER lpCommandline        AS CHAR.
  DEFINE INPUT  PARAMETER lpProcessAttributes  AS LONG.
  DEFINE INPUT  PARAMETER lpThreadAttributes   AS LONG.
  DEFINE INPUT  PARAMETER bInheritHandles      AS long.
  DEFINE INPUT  PARAMETER dCreationFlags       AS LONG.
  DEFINE INPUT  PARAMETER lpEnvironment        AS LONG.
  DEFINE INPUT  PARAMETER lpCurrentDirectory   AS LONG.
  DEFINE INPUT  PARAMETER lpStartupInfo        AS LONG.
  DEFINE INPUT  PARAMETER lpProcessInformation AS LONG.
  DEFINE RETURN PARAMETER bResult              AS long.
END PROCEDURE.
PROCEDURE CreateWindowExA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER dwExStyle    AS LONG.
  DEFINE INPUT  PARAMETER lpClassName  AS CHAR.
  DEFINE INPUT  PARAMETER lpWindowName AS CHAR.
  DEFINE INPUT  PARAMETER dwStyle      AS LONG.
  DEFINE INPUT  PARAMETER x            AS LONG.
  DEFINE INPUT  PARAMETER y            AS LONG.
  DEFINE INPUT  PARAMETER nWidth       AS LONG.
  DEFINE INPUT  PARAMETER nHeight      AS LONG.
  DEFINE INPUT  PARAMETER hWndParent   AS LONG.
  DEFINE INPUT  PARAMETER hMenu        AS LONG.
  DEFINE INPUT  PARAMETER hInstance    AS LONG.
  DEFINE INPUT  PARAMETER lpParam      AS LONG.
  DEFINE RETURN PARAMETER hwndCreated  AS LONG.
END PROCEDURE.
PROCEDURE CloseHandle EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hObject     AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE ClosePrinter EXTERNAL "winspool.drv" :
  DEFINE INPUT  PARAMETER VH_PRINTER_HANDLE AS LONG.
  DEFINE RETURN PARAMETER VI_RETURN_VALUE   AS long.
END PROCEDURE.
PROCEDURE CreateMutexA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpMutexAttributes AS LONG.
  DEFINE INPUT  PARAMETER bInitialOwner     AS LONG.
  DEFINE INPUT  PARAMETER lpName            AS CHAR.
  DEFINE RETURN PARAMETER hMutex            AS LONG.
END PROCEDURE.
PROCEDURE DeleteMenu EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hMenu       AS long.
  DEFINE INPUT  PARAMETER uPosition   AS long.
  DEFINE INPUT  PARAMETER uFlags      AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE DrawMenuBar EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hMenu      AS  LONG.
  DEFINE RETURN PARAMETER iRetCode   AS  LONG.
END PROCEDURE.
PROCEDURE Ellipse EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc         AS LONG.
  DEFINE INPUT  PARAMETER nLeftRect   AS LONG.
  DEFINE INPUT  PARAMETER nTopRect    AS LONG.
  DEFINE INPUT  PARAMETER nRightRect  AS LONG.
  DEFINE INPUT  PARAMETER nBottomRect AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE EndDoc EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER  hdc AS LONG.
  DEFINE RETURN PARAMETER uRet AS LONG.
END PROCEDURE.
PROCEDURE EndPage EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc  AS LONG.
  DEFINE RETURN PARAMETER uRet AS LONG.
END PROCEDURE.
PROCEDURE EnumPrintersA EXTERNAL "winspool.drv" :
  DEFINE INPUT  PARAMETER Flags        AS LONG.
  DEFINE INPUT  PARAMETER Name         AS CHAR.
  DEFINE INPUT  PARAMETER Level        AS LONG.
  DEFINE INPUT  PARAMETER pPrinterEnum AS LONG.
  DEFINE INPUT  PARAMETER cbBuf        AS LONG.
  DEFINE OUTPUT PARAMETER pcbNeeded    AS LONG.
  DEFINE OUTPUT PARAMETER pcReturned   AS LONG.
  DEFINE RETURN PARAMETER RetValue     AS LONG.
END PROCEDURE.
PROCEDURE FindExecutableA EXTERNAL "shell32" :
  DEFINE INPUT        PARAMETER lpFile      AS CHAR.
  DEFINE INPUT        PARAMETER lpDirectory AS CHAR.
  DEFINE INPUT-OUTPUT PARAMETER lpResult    AS CHAR.
  DEFINE RETURN       PARAMETER hInstance   AS long.
END PROCEDURE.
PROCEDURE FlashWindow EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER bInvert     AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE FormatMessageA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER dwFlags      AS LONG.
  DEFINE INPUT  PARAMETER lpSource     AS LONG.
  DEFINE INPUT  PARAMETER dwMessageID  AS LONG.
  DEFINE INPUT  PARAMETER dwLanguageID AS LONG.
  DEFINE OUTPUT PARAMETER lpBuffer     AS CHAR.
  DEFINE INPUT  PARAMETER nSize        AS LONG.
  DEFINE INPUT  PARAMETER lpArguments  AS LONG.
  DEFINE RETURN PARAMETER nTextLength  AS LONG.
END PROCEDURE.
PROCEDURE FreeLibrary EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hproc       AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE GetClientRect EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER lpRect      AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE GetCursorPos EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER  lpPoint     AS LONG.
  DEFINE RETURN PARAMETER  ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE GetDateFormatA EXTERNAL "kernel32" :
  DEFINE INPUT        PARAMETER Locale      AS LONG.
  DEFINE INPUT        PARAMETER dwFlags     AS LONG.
  DEFINE INPUT        PARAMETER lpTime      AS LONG.
  DEFINE INPUT        PARAMETER lpFormat    AS LONG.
  DEFINE INPUT-OUTPUT PARAMETER lpDateStr   AS CHAR.
  DEFINE INPUT        PARAMETER cchDate     AS LONG.
  DEFINE RETURN       PARAMETER cchReturned AS LONG.
END PROCEDURE.
PROCEDURE GetDC EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd AS long.
  DEFINE RETURN PARAMETER hdc  AS long.
END PROCEDURE.
PROCEDURE GetDeviceCaps EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER  hdc        AS long.
  DEFINE INPUT  PARAMETER  nIndex     AS long.
  DEFINE RETURN PARAMETER  capability AS long.
END PROCEDURE.
PROCEDURE GetLastError EXTERNAL "kernel32" :
  DEFINE RETURN PARAMETER dwMessageID AS long.
END PROCEDURE.
PROCEDURE GetLocaleInfoA EXTERNAL "kernel32" :
  DEFINE INPUT        PARAMETER Locale      AS LONG.
  DEFINE INPUT        PARAMETER dwFlags     AS LONG.
  DEFINE INPUT-OUTPUT PARAMETER lpLCData    AS CHAR.
  DEFINE INPUT        PARAMETER cchData     AS LONG.
  DEFINE RETURN       PARAMETER cchReturned AS LONG.
END PROCEDURE.
PROCEDURE GetMenu EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER ProgHwnd AS LONG.
  DEFINE RETURN PARAMETER MenuHnd  AS LONG.
END PROCEDURE.
PROCEDURE GetMenuItemCount EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hMenu    AS  LONG.
  DEFINE RETURN PARAMETER iCount   AS  LONG.
END PROCEDURE.
PROCEDURE GetModuleFileNameA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hInst        AS long.
  DEFINE OUTPUT PARAMETER lpszFileName AS CHAR.
  DEFINE INPUT  PARAMETER cbFileName   AS long.
  DEFINE RETURN PARAMETER bSuccess     AS long.
END PROCEDURE.
PROCEDURE GetParent EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER thishwnd   AS long.
  DEFINE RETURN PARAMETER parenthwnd AS long.
END PROCEDURE.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS CHAR.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS long.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS long.
END PROCEDURE.
PROCEDURE GetProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpAppName        AS CHAR.
  DEFINE INPUT  PARAMETER lpKeyName        AS CHAR.
  DEFINE INPUT  PARAMETER lpDefault        AS CHAR.
  DEFINE OUTPUT PARAMETER lpReturnedString AS CHAR.
  DEFINE INPUT  PARAMETER nSize            AS long.
  DEFINE RETURN PARAMETER nReturnedChars   AS long.
END PROCEDURE.
PROCEDURE GetSubMenu EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER MenuHnd    AS LONG.
  DEFINE INPUT  PARAMETER nPos       AS LONG.
  DEFINE RETURN PARAMETER SubMenuHnd AS LONG.
END PROCEDURE.
PROCEDURE GetSysColor EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER nIndex     AS LONG.
  DEFINE RETURN PARAMETER dwRgbValue AS LONG.
END PROCEDURE.
PROCEDURE GetSystemMenu EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd    AS long.
  DEFINE INPUT  PARAMETER bRevert AS long.
  DEFINE RETURN PARAMETER hMenu   AS long.
END PROCEDURE.
PROCEDURE GetTimeFormatA EXTERNAL "kernel32" :
  DEFINE INPUT        PARAMETER Locale      AS LONG.
  DEFINE INPUT        PARAMETER dwFlags     AS LONG.
  DEFINE INPUT        PARAMETER lpTime      AS LONG.
  DEFINE INPUT        PARAMETER lpFormat    AS LONG.
  DEFINE INPUT-OUTPUT PARAMETER lpTimeStr   AS CHAR.
  DEFINE INPUT        PARAMETER cchTime     AS LONG.
  DEFINE RETURN       PARAMETER cchReturned AS LONG.
END PROCEDURE.
  PROCEDURE GetUserNameA EXTERNAL "advapi32" :
    DEFINE INPUT-OUTPUT PARAMETER lpBuffer    AS CHAR.
    DEFINE INPUT-OUTPUT PARAMETER nSize       AS LONG.
    DEFINE RETURN       PARAMETER ReturnValue AS long.
  END PROCEDURE.
PROCEDURE GetVersionExA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpVersionInfo AS LONG.
  DEFINE RETURN PARAMETER ReturnValue   AS long.
END PROCEDURE.
PROCEDURE GetWindowLongA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER phwnd       AS long.
  DEFINE INPUT  PARAMETER cindex      AS long.
  DEFINE RETURN PARAMETER currentlong AS LONG.
END PROCEDURE.
PROCEDURE GetWindowRect EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER lpRect      AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE GetWindowsDirectoryA EXTERNAL "kernel32" :
  DEFINE OUTPUT PARAMETER lpBuffer AS CHAR.
  DEFINE INPUT  PARAMETER uSize    AS LONG.
  DEFINE RETURN PARAMETER uRet     AS LONG.
END PROCEDURE.
PROCEDURE InvalidateRect EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd        AS long.
  DEFINE INPUT  PARAMETER lpRect      AS long.
  DEFINE INPUT  PARAMETER bErase      AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE LoadLibraryA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER libname AS CHAR.
  DEFINE RETURN PARAMETER hproc   AS long.
END PROCEDURE.
PROCEDURE MAPISendMail EXTERNAL "mapi32" :
  DEFINE INPUT  PARAMETER lhSession  AS LONG.
  DEFINE INPUT  PARAMETER ulUIParam  AS LONG.
  DEFINE INPUT  PARAMETER lpMessage  AS LONG.
  DEFINE INPUT  PARAMETER flFlags    AS LONG.
  DEFINE INPUT  PARAMETER ulReserved AS LONG.
  DEFINE RETURN PARAMETER wretcode   AS long.
END PROCEDURE.
PROCEDURE mciGetErrorStringA EXTERNAL "winmm" :
  DEFINE INPUT  PARAMETER mciError       AS long.
  DEFINE OUTPUT PARAMETER lpszErrorText  AS CHAR.
  DEFINE INPUT  PARAMETER cchErrorText   AS long.
  DEFINE RETURN PARAMETER ReturnValue    AS long.
END PROCEDURE.
PROCEDURE mciSendCommandA EXTERNAL "winmm" :
  DEFINE INPUT  PARAMETER IDDevice   AS long.
  DEFINE INPUT  PARAMETER uMsg       AS long.
  DEFINE INPUT  PARAMETER fdwCommand AS long.
  DEFINE INPUT  PARAMETER dwParam    AS LONG.
  DEFINE RETURN PARAMETER mciError   AS long.
END PROCEDURE.
PROCEDURE OpenPrinterA EXTERNAL "winspool.drv" :
  DEFINE INPUT  PARAMETER PC_PRINTER_NAME   AS CHAR.
  DEFINE INPUT  PARAMETER VM_PRINTER_HANDLE AS LONG.
  DEFINE INPUT  PARAMETER VM_DEFAULTS       AS LONG.
  DEFINE RETURN PARAMETER VI_RETURN_VALUE   AS long.
END PROCEDURE.
PROCEDURE PostMessageA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER umsg        AS long.
  DEFINE INPUT  PARAMETER wparam      AS long.
  DEFINE INPUT  PARAMETER lparam      AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE PrinterProperties EXTERNAL "winspool.drv" :
  DEFINE INPUT  PARAMETER VH_PARENT         AS LONG.
  DEFINE INPUT  PARAMETER VH_PRINTER_HANDLE AS LONG.
  DEFINE RETURN PARAMETER VI_RETURN_VALUE   AS long.
END PROCEDURE.
PROCEDURE RegOpenKeyA EXTERNAL "advapi32" :
  DEFINE INPUT  PARAMETER hkey       AS LONG.
  DEFINE INPUT  PARAMETER lpszSubKey AS CHAR.
  DEFINE OUTPUT PARAMETER phkResult  AS LONG.
  DEFINE RETURN PARAMETER lpResult   AS LONG.
END PROCEDURE.
PROCEDURE RegCloseKey EXTERNAL "advapi32" :
  DEFINE INPUT  PARAMETER hkey     AS LONG.
  DEFINE RETURN PARAMETER lpresult AS LONG.
END PROCEDURE.
PROCEDURE RegEnumKeyA EXTERNAL "advapi32" :
  DEFINE INPUT  PARAMETER hKey        AS LONG.
  DEFINE INPUT  PARAMETER iSubKey     AS LONG.
  DEFINE OUTPUT PARAMETER lpszName    AS CHAR.
  DEFINE INPUT  PARAMETER cchName     AS LONG.
  DEFINE RETURN PARAMETER lpresult    AS LONG.
END PROCEDURE.
PROCEDURE RegQueryValueExA EXTERNAL "advapi32" :
  DEFINE INPUT        PARAMETER hkey         AS LONG.
  DEFINE INPUT        PARAMETER lpValueName  AS CHAR.
  DEFINE INPUT        PARAMETER lpdwReserved AS LONG.
  DEFINE OUTPUT       PARAMETER lpdwType     AS LONG.
  DEFINE INPUT        PARAMETER lpbData      AS LONG.
  DEFINE INPUT-OUTPUT PARAMETER lpcbData     AS LONG.
  DEFINE RETURN       PARAMETER lpresult     AS LONG.
END PROCEDURE.
PROCEDURE RegSetValueExA EXTERNAL "advapi32" :
  DEFINE INPUT  PARAMETER hkey         AS LONG.
  DEFINE INPUT  PARAMETER lpValueName  AS CHAR.
  DEFINE INPUT  PARAMETER Reserved     AS LONG.
  DEFINE INPUT  PARAMETER dwType       AS LONG.
  DEFINE INPUT  PARAMETER lpData       AS LONG.
  DEFINE INPUT  PARAMETER cbData       AS LONG.
  DEFINE RETURN PARAMETER lpresult     AS LONG.
END PROCEDURE.
PROCEDURE ReleaseDC EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd AS long.
  DEFINE INPUT  PARAMETER hdc  AS long.
  DEFINE RETURN PARAMETER ok   AS long.
END PROCEDURE.
PROCEDURE RemoveMenu EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hMenu      AS  LONG.
  DEFINE INPUT  PARAMETER nPosition  AS  LONG.
  DEFINE INPUT  PARAMETER wFlags     AS  LONG.
  DEFINE RETURN PARAMETER iRetCode   AS  LONG.
END PROCEDURE.
PROCEDURE ScreenToClient EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd        AS LONG.
  DEFINE INPUT  PARAMETER lpPoint     AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE SendMessageA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER umsg        AS long.
  DEFINE INPUT  PARAMETER wparam      AS long.
  DEFINE INPUT  PARAMETER lparam      AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE SetCursorPos EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER x-pos       AS long.
  DEFINE INPUT  PARAMETER y-pos       AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE SetParent EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER  hwndChild     AS long.
  DEFINE INPUT  PARAMETER  hwndNewParent AS long.
  DEFINE RETURN PARAMETER hwndOldParent  AS long.
END PROCEDURE.
PROCEDURE SetSysColors EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER cDspElements   AS LONG.
  DEFINE INPUT  PARAMETER lpnDspElements AS LONG.
  DEFINE INPUT  PARAMETER lpdwRgbValues  AS LONG.
  DEFINE RETURN PARAMETER ReturnValue    AS long.
END PROCEDURE.
PROCEDURE SetWindowContextHelpId EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd        AS long.
  DEFINE INPUT  PARAMETER ContextID   AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE SetWindowLongA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER phwnd   AS long.
  DEFINE INPUT  PARAMETER cindex  AS long.
  DEFINE INPUT  PARAMETER newlong AS LONG.
  DEFINE RETURN PARAMETER oldlong AS LONG.
END PROCEDURE.
PROCEDURE SetWindowPos EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd            AS long.
  DEFINE INPUT  PARAMETER hwndInsertAfter AS long.
  DEFINE INPUT  PARAMETER x               AS long.
  DEFINE INPUT  PARAMETER y               AS long.
  DEFINE INPUT  PARAMETER cx              AS long.
  DEFINE INPUT  PARAMETER cy              AS long.
  DEFINE INPUT  PARAMETER fuFlags         AS LONG.
  DEFINE RETURN PARAMETER ReturnValue     AS long.
END PROCEDURE.
PROCEDURE SHBrowseForFolder EXTERNAL "shell32" :
  DEFINE INPUT  PARAMETER  lpbi         AS MEMPTR.
  DEFINE RETURN PARAMETER  lpItemIDList AS long.
END PROCEDURE.
PROCEDURE SHGetPathFromIDList EXTERNAL "shell32" :
  DEFINE INPUT  PARAMETER  lpItemIDList AS LONG.
  DEFINE INPUT-OUTPUT PARAMETER pszPath AS CHAR.
  DEFINE RETURN PARAMETER  ReturnValue  AS long.
END PROCEDURE.
PROCEDURE ShellExecuteA EXTERNAL "shell32" :
  DEFINE INPUT  PARAMETER hwnd          AS long.
  DEFINE INPUT  PARAMETER lpOperation   AS CHAR.
  DEFINE INPUT  PARAMETER lpFile        AS CHAR.
  DEFINE INPUT  PARAMETER lpParameters  AS CHAR.
  DEFINE INPUT  PARAMETER lpDirectory   AS CHAR.
  DEFINE INPUT  PARAMETER nShowCmd      AS long.
  DEFINE RETURN PARAMETER hInstance     AS long.
END PROCEDURE.
PROCEDURE ShellExecuteExA EXTERNAL "shell32" :
  DEFINE INPUT  PARAMETER lpExecInfo  AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE ShowScrollBar EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd        AS long.
  DEFINE INPUT  PARAMETER fnBar       AS long.
  DEFINE INPUT  PARAMETER fShow       AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE ShowWindow EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd        AS long.
  DEFINE INPUT  PARAMETER nCmdShow    AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE StartDocA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc   AS LONG.
  DEFINE INPUT  PARAMETER lpdi  AS LONG.
  DEFINE RETURN PARAMETER JobId AS LONG.
END PROCEDURE.
PROCEDURE StartPage EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc  AS LONG.
  DEFINE RETURN PARAMETER uRet AS LONG.
END PROCEDURE.
PROCEDURE SystemParametersInfoA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER uiAction    AS long.
  DEFINE INPUT  PARAMETER uiParam     AS long.
  DEFINE INPUT  PARAMETER pvParam     AS LONG.
  DEFINE INPUT  PARAMETER fWinIni     AS long.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE TextOutA EXTERNAL "gdi32" :
  DEFINE INPUT  PARAMETER hdc      AS LONG.
  DEFINE INPUT  PARAMETER nXstart  AS LONG.
  DEFINE INPUT  PARAMETER nYstart  AS LONG.
  DEFINE INPUT  PARAMETER lpString AS CHAR.
  DEFINE INPUT  PARAMETER cbString AS LONG.
  DEFINE RETURN PARAMETER uRet     AS LONG.
END PROCEDURE.
PROCEDURE WaitForSingleObject EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hObject     AS long.
  DEFINE INPUT  PARAMETER dwTimeout   AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE WinExec EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszCmdLine AS CHAR.
  DEFINE INPUT  PARAMETER fuCmdShow   AS long.
  DEFINE RETURN PARAMETER nTask       AS long.
END PROCEDURE.
PROCEDURE WinHelpA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwndmain    AS long.
  DEFINE INPUT  PARAMETER lpszHelp    AS CHAR.
  DEFINE INPUT  PARAMETER uCommand    AS long.
  DEFINE INPUT  PARAMETER dwData      AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS long.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS long.
END PROCEDURE.
PROCEDURE Sleep EXTERNAL "kernel32" :
  DEFINE INPUT PARAMETER dwMilliseconds AS LONG.
END PROCEDURE.
PROCEDURE OpenProcess EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER dwDesiredAccess AS LONG.
  DEFINE INPUT  PARAMETER bInheritHandle  AS LONG.
  DEFINE INPUT  PARAMETER dwProcessId     AS LONG.
  DEFINE RETURN PARAMETER hProcess        AS LONG.
END PROCEDURE.
PROCEDURE GetExitCodeProcess EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hProcess    AS LONG.
  DEFINE OUTPUT PARAMETER ExitCode    AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
PROCEDURE WaitForInputIdle EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hProcess        AS LONG.
  DEFINE INPUT  PARAMETER dwMilliseconds  AS LONG.
  DEFINE RETURN PARAMETER ReturnValue     AS LONG.
END PROCEDURE.
PROCEDURE TerminateProcess EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hProcess    AS LONG.
  DEFINE INPUT  PARAMETER uExitCode   AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.
