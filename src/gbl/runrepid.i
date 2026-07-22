/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращение -1 или код возврата exe

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/02/06
Author: Bakhtadze Natalya
Creation date: 05/02/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&GLOBAL-DEFINE PROCESS_QUERY_INFORMATION 1024
&GLOBAL-DEFINE PROCESS_TERMINATE 1
&GLOBAL-DEFINE STILL_ACTIVE 259


{ def/funcmet.i IsProcessRunning integer } (PID AS INTEGER) :
  DEFINE VARIABLE IsRunning   AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE hProcess    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ExitCode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  define variable rv          as integer no-undo .

  RUN OpenProcess in hpapi
                  ( {&PROCESS_QUERY_INFORMATION},
                    0,
                    PID,
                    OUTPUT hProcess).
  IF hProcess NE 0 THEN DO:
     RUN GetExitcodeProcess in hpapi
                  ( hProcess,
                    OUTPUT ExitCode,
                    OUTPUT ReturnValue).
     rv = (if (ExitCode={&STILL_ACTIVE}) AND (ReturnValue NE 0)
          then  - 1
          else ReturnValue).
     RUN CloseHandle in hpapi (hProcess, OUTPUT ReturnValue).
  END.
  RETURN rv.
end.

/* $Workfile$ e n d */
