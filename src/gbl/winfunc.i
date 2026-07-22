/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Windows functions

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


/* ===========================================================================
   file    : WINFUNC.I
   by      : Jurjen Dijkstra, 1997
             mailto:jurjen.dijkstra@wxs.nl
             http://www.pugcentral.org/api
   purpose : Forward declarations for functions that call API procedures.
             This include file is included in windows.i
   =========================================================================== */

/* prevent multiple inclusion: */
&IF DEFINED(WINFUNC_I)=0 &THEN
&GLOBAL-DEFINE WINFUNC_I

/* start persistent procedure holding the function implementations.
   The forward declarations are needed in winfunc.p, but the
   "run winfunc.p persistent" part must be prevented in winfunc.p : */

DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
&IF DEFINED(DONTRUN-WINFUNC)=0 &THEN
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
&ELSE
  hpWinFunc = this-procedure:handle.
&ENDIF

/* --- the forward declarations : --- */

FUNCTION GetLastError      /* 1:1 implementation of API */
         RETURNS INTEGER   /* = dwErrorID */
         ()
         IN hpWinFunc.

FUNCTION GetParent         /* 1:1 implementation of API */
         RETURNS INTEGER   /* = hWnd van parent */
         (input hwnd as INTEGER)
         IN hpWinFunc.

FUNCTION ShowLastError     /* calls GetLastError and views it as alert-box */
         RETURNS INTEGER   /* = dwErrorID */
         ()
         IN hpWinFunc.

FUNCTION CreateProcess     /* wrapper for the big API definition */
         RETURNS INTEGER   /* = if success then hProcess else 0  */
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.

&ENDIF  /* &IF DEFINED(WINFUNC_I)=0 */
