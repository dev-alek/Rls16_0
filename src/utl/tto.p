block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tto.p $
$Archive: utl/tto.p $

Отлов мусорных object

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/09/07
Author: Bakhtadze Natalya
Creation date: 06/09/07

*/

define input parameter p-metka as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tto.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/tto.p $":U .
define variable vss-description as character no-undo init "Отлов мусорных object".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE VARIABLE hBuffer    AS HANDLE     NO-UNDO.
define variable v-tth as handle no-undo .
define stream LogStream.

  ASSIGN hBuffer = SESSION:FIRST-query.
  DO WHILE VALID-HANDLE(hBuffer):
    OUTPUT stream LogStream TO "memdump.log" APPEND.
    PUT stream LogStream UNFORMATTED SKIP
      "** Dump: " TODAY STRING(TIME,'HH:MM:SS') SKIP
      "** OBJECT **" SKIP
      p-metka skip
      .
    PUT stream LogStream
    string(hBuffer:name) FORMAT "x(20)" {&space-char}
    "is-open=" hbuffer:is-open {&space-char}
    (if valid-handle (hbuffer:INSTANTIATING-PROCEDURE)
    then substitute("INSTANTIATING-PROCEDURE=&1", hbuffer:INSTANTIATING-PROCEDURE:FILE-NAME)
    else '') FORMAT "X(50)" skip
    string(if valid-handle (hbuffer)
    then ("PREPARE-STRING=" + REPLACE(hbuffer:PREPARE-STRING,"~n", "  "))
    else "PREPARE-STRING=")  FORMAT "X(200)" skip(0)
    (if valid-handle(hbuffer:get-buffer-handle(1))
    then substitute("buffer-name=&1", hbuffer:get-buffer-handle(1):name)
    else "") format "X(30)" skip.
    PUT stream LogStream SKIP.
    OUTPUT stream LogStream CLOSE.
    hBuffer = hBuffer:NEXT-SIBLING.
  END.