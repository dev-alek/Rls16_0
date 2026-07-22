/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с чужими ini

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/03/06
Author: Bakhtadze Natalya
Creation date: 01/03/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* ********************************************************
   privateprofile.i
   example of using the Windows API GetPrivateProfileString and
   WritePrivateProfileString. This code does not require
   windows.i to work.
 ********************************************************** */

/* EXAMPLE OF HOW TO USE THE CODE */
/*
define variable v-return as character no-undo .

 RUN alienini-getkey
   (input  "target_est_hrs_prod_daily.csv",    /* The section name */
    input  "",           /* The key name - if blank then enumerate key names */
    input  "c:\tmp\schema.ini",    /* Name of ini file */
    output v-return).     /* Returned stuff - comma separated keys or key value */

 /* Write a key use this code */
 RUN alienini-putkey
   (input "target_est_hrs_prod_daily.csv",  /* section name  */
    input "Col8",                          /* key name      */
    input "c:\tmp\schema.ini",            /* INI file name */
    input "F8 Integer").                 /* key value     */
                             /* put key does not return anything useful */

 */

/* ****** END EXAMPLE ***************************** */

/* ------------- internal procedures ------------ */

procedure alienini-getkey :

define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.

define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.

assign
set-size(mem1)  = 4000
mem1size = 4000.

if i-key = "" then EntryPointer = 0.

else do:
  /* Must fill memory with desired key name and EntryPointer must point to
it */

  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.

run getprivateprofilestringA /*in hpApi*/
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).

/* if i-key was "", Windows will return a list of all keys in i-section.
   This list is not comma-separated but separated by CHR(0). Progress
   can not handle that easily so we'll now replace every 0 by a comma: */

do ii = 1 to cbReturnSize:
  /* If this is a list convert null character into a comma to generate a csv
     type variable */
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.

  set-size(mem1) = 0.
  set-size(mem2) = 0.

end procedure.


procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.

define variable cbReturnSize as integer.

run writeprivateprofilestringA /*in hpApi*/
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).

end procedure.

PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG. /* memptr */
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.

PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.


 /* $Workfile$ */