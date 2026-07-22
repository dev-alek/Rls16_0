/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

переопределение процедур окна diallog.w на процедуры окна automain.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/05
Author: Bakhtadze Natalya
Creation date: 01/21/05

необходимо для того чтобы одни и те же процедуры корректно вызывались как из окна diallog.w так и
из окна автоматического запуска по расписанию

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-loc-counter as integer no-undo .
define variable v-counter-visible as logical no-undo .
define variable v-view-log as logical no-undo .

&scoped-define LogLineSize 80

&if "{1}" = "" &then
&scop highest-window-handle parparentproc
&else
&scop highest-window-handle {1}
&endif

&if defined(tab-shift) = 0 &then
  &scoped-define tab-shift 1
&endif

define stream auto2dia.

 /*процедура - заменяющая одноименную в diallog*/
PROCEDURE write-log-and-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .

  run write-to-screen in this-procedure( input ( fill( {&space-char}, p-tab-position) + p-log-string)) .
  if p-file-name <> '':U then do:
    do v-jj = 1 to num-entries(p-file-name, {&delim-nws}):
      run  auto2dia-writefile in this-procedure (
                                      input entry(v-jj, p-file-name, {&delim-nws})
                                      ,input p-log-level
                                      ,input (p-log-string + {&new-line})
                                    ) no-error .
    end.
  end.
  if writelogvalue eq "AsyncProc" 
  then 
     run write-to-log in this-procedure( p-log-string) .
  
end.

END PROCEDURE.

PROCEDURE get-title :
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.
end.
END PROCEDURE.


PROCEDURE set-title :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.
run write-to-log in this-procedure( input ( fill( {&space-char}, 15) + p-title)) .

end.
END PROCEDURE.

PROCEDURE get-counter-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.

    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.


PROCEDURE set-counter-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.

    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.

PROCEDURE show-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
    assign
    v-counter-visible = true
    .
    process events.
end.
END PROCEDURE. /* show-counter */

PROCEDURE hide-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
    assign
    v-counter-visible = false
    .
    run hide-message in {&highest-window-handle} .
    process events.
end.
END PROCEDURE. /* hide-counter */

PROCEDURE write-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
if v-counter-visible then
run write-message in {&highest-window-handle} ( input p-counter-string) .
process events.
end.
END PROCEDURE. /* write-counter */


PROCEDURE get-stop-state :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
end.
END PROCEDURE. /* get-stop-state */

PROCEDURE set-view-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*экранируем процедуры diallog*/
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.
    assign
    v-view-log = p-view-log
    .
end.
END PROCEDURE.


PROCEDURE get-view-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.

    assign
    p-view-log = v-view-log
    .
end.

END PROCEDURE.

PROCEDURE write-log :
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.

run write-to-log in this-procedure( input ( fill( {&space-char}, {&tab-shift}  * p-tab-position)  +
                                    (IF p-log-string = "&Line" THEN FILL("-", {&LogLineSize})
                                    ELSE IF p-log-string = "&DLine" THEN FILL("=", {&LogLineSize})
                                    ELSE p-log-string))).
end.
END PROCEDURE. /* write-log */


procedure writelog :

do
on error undo, return error
:
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.

  if p-file-name <> "" then
  run  auto2dia-Writefile in this-procedure (
                                    input p-file-name
                                  ,input p-log-level
                                  ,input p-log-string
                                ) no-error .

   process events.
end.

end procedure. /* writelog */

PROCEDURE auto2dia-writefile:
  define input parameter sFileName AS CHAR     NO-UNDO.
  define input parameter iLogLevel AS INTEGER  NO-UNDO.
  define input parameter sToWrite  AS CHAR     NO-UNDO.
/*
  Процедура делает запись в файле, определенном параметром sFileName.
  Запись выглядит следующим образом:
     <Пробелы, определяемые параметром iLogLevel><Текущая дата><sToWrite>
  Специальные значения для iLogLevel:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для sToWrite:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/

  define variable v-SlashPos  as integer no-undo .
  define variable v-lDirName  as character no-undo .
  define variable v-lDirName2 as character no-undo .
  v-SlashPos  = maximum (  r-index(sFileName, "\"),  r-index(sFileName, "/")  ) .
  v-lDirName  = if v-SlashPos > 0 then substring (sFileName, 1, v-SlashPos - 1) else "".
  FILE-INFO:FILE-NAME = v-lDirName .
  v-lDirName2 = FILE-INFO:FULL-PATHNAME .
  if v-lDirName2 <> ? then do :
  /* в операции output to ... отсутствует no-error, поэтому доступность файла проверяется перед обращением:
     1) проверить наличие директории
     2) файл в директории либо есть, либо создастся
     3) если директория есть, но писать в неё нельзя - то опаньки
     4) если файл есть, но писать в него нельзя - аналогично
  */
OUTPUT STREAM auto2dia TO VALUE(sFileName) APPEND.
    PUT STREAM auto2dia UNFORMATTED {&new-line}.
    PUT STREAM auto2dia UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM auto2dia UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", {&LogLineSize})
             ELSE IF sToWrite = "&DLine" THEN FILL("=", {&LogLineSize})
             ELSE sToWrite).
OUTPUT STREAM auto2dia CLOSE.
  end .

END PROCEDURE.



/* $Workfile$ e n d */