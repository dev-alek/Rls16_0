block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: winfunc.p $
$Archive: gbl/winfunc.p $

WINFUNC.P

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

   by      : Jurjen Dijkstra, 1997
             mailto:jurjen.dijkstra@wxs.nl
             http://www.pugcentral.org/api
   purpose : implementation of functions that call windows API procedures

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: winfunc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/winfunc.p $":U .
define variable vss-description as character no-undo init "Функции windows".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
&GLOB DONTRUN-WINFUNC
{ gbl/windows.i }


/* this CreateProcess function is a simplified version of the
   CreateProcess API definition.
   Parameters:
   1. Commandline, for example "notepad.exe c:\config.sys"
   2. CurrentDir,  is default directory for new process
   3. wShowWindow, 0=hidden, 1=normal, 2=minimized, 3=maximized
   r. return       if <>0 then handle of new process
                   if  =0 then failed, check GetLastError  */

FUNCTION CreateProcess RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER) :

   define variable lpStartupInfo as memptr.
   set-size(lpStartupInfo)     = 68.
   put-long(lpStartupInfo,1)   = 68.
   put-long (lpStartupInfo,45) = 1. /* = STARTF_USESHOWWINDOW */
   put-short(lpStartupInfo,49) = wShowWindow.

   define variable lpProcessInformation as memptr.
   set-size(lpProcessInformation)   = 16.

   define variable lpCurrentDirectory as memptr.
   if CurrentDir<>"" then do:
      set-size(lpCurrentDirectory)     = 256.
      put-string(lpCurrentDirectory,1) = CurrentDir.
   end.

   define variable bResult as integer.

   run CreateProcess{&A} in hpApi
     ( 0,
       CommandLine,
       0,
       0,
       0,
       0,
       0,
       if CurrentDir=""
          then 0
          else get-pointer-value(lpCurrentDirectory),
       get-pointer-value(lpStartupInfo),
       get-pointer-value(lpProcessInformation),
       output bResult
     ).

  define variable hProcess as integer no-undo.
  define variable hThread  as integer no-undo.
  hProcess = get-long(lpProcessInformation,1).
  hThread  = get-long(lpProcessInformation,5).

  /* I am pretty sure you are not interested in hThread
     so let's invalidate the handle right now.
     This does not mean the thread is terminated, it just
     means that Kernel doesn't need to keep the object for US. */
  define variable ReturnValue as INTEGER NO-UNDO.
  RUN CloseHandle in hpApi(hThread, output ReturnValue).

  set-size(lpStartupInfo)        = 0.
  set-size(lpProcessInformation) = 0.
  set-size(lpCurrentDirectory)   = 0.

  return ( hProcess ).

END FUNCTION.


/* GetLastError returns the Error code, set by the most recently
   failed api-call. */

/* PROBLEM : GetLastError will always return 127. The reason is that
   Progress will have called some api function AFTER the one you have
   called. (29 januari 1998) */

FUNCTION GetLastError RETURNS INTEGER :
  define variable dwMessageID as integer no-undo.
  run GetLastError in hpApi (output dwMessageID).
  RETURN (dwMessageID).
END FUNCTION.


/* GetParent returns the hWnd of the parent window */

FUNCTION GetParent RETURNS INTEGER
         (input hWnd as INTEGER) :
  define variable hParent as integer no-undo.
  run GetParent in hpApi (hWnd, output hParent).
  RETURN (hParent).
END FUNCTION.


/* ShowLastError calls GetLastError and shows the message text in a
   alert-box. The Message text is simply only searched in the system
   module, using the default language and does not insert any
   arguments (like in the P4GL 'substitute' function) */

/* Note: can't work because GetLastError doesn't work with Progress */
FUNCTION ShowLastError RETURNS INTEGER :
  define variable ErrorId as integer no-undo.
  define variable txt as char no-undo.
  define variable TxtLength as integer no-undo.

  ErrorId = GetLastError().
  txt = fill(" ",300).
  run FormatMessage{&A} in hpApi (512 + 4096,  /* = FORMAT_MESSAGE_IGNORE_INSERTS
                                                  + FORMAT_MESSAGE_FROM_SYSTEM */
                        0,
                        ErrorId,
                        0,
                        output txt,
                        length(txt),
                        0,
                        output TxtLength).
   message  txt view-as alert-box error.
   RETURN ( ErrorId ).

END FUNCTION.