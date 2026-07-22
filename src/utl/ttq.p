block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ttq.p $
$Archive: utl/ttq.p $

Отлов мусорных tt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/09/07
Author: Bakhtadze Natalya
Creation date: 06/09/07

*/

define input parameter p-metka as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ttq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ttq.p $":U .
define variable vss-description as character no-undo init "Отлов мусорных tt".
{ cmp/vssrevis.i }

DEFINE VARIABLE hBuffer    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hDATASET   AS HANDLE     NO-UNDO.
define variable v-tth as handle no-undo .
define stream LogStream.
  ASSIGN hdataset = SESSION:FIRST-DATASET.
  DO WHILE VALID-HANDLE(hdataset):
    IF VALID-HANDLE((hdataset)) THEN DO:
      v-tth = hdataset.
      OUTPUT stream LogStream TO "memdump.log" APPEND.
      PUT stream LogStream UNFORMATTED SKIP
        "** Dump:" space TODAY space STRING(TIME,'HH:MM:SS') SKIP
        "** Dynamic dataset **" SKIP
        "** label" space p-metka skip
        .
      do
      on error undo, leave
      :
        PUT stream LogStream
          hdataset:NAME FORMAT "x(20)" AT 2
            " "

            " ".
      end.

      &IF PROVERSION BEGINS "1" &THEN
        IF VALID-HANDLE(hdataset:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hdataset:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
      &ENDIF
      PUT stream LogStream SKIP.
      OUTPUT stream LogStream CLOSE.
    END.
    else do:
      OUTPUT stream LogStream TO "memdump.log" APPEND.
      PUT stream LogStream UNFORMATTED SKIP
        "** Dump: " space TODAY space STRING(TIME,'HH:MM:SS') SKIP
        "** STATIC TABLE **" SKIP
        "** label" space p-metka skip
        .
      do
      on error undo, leave
      :
        PUT stream LogStream
          string(hdataset:NAME) FORMAT "x(20)" AT 2
            " "
          string(hdataset) FORMAT "x(20)"
            " ".
      end.

      &IF PROVERSION BEGINS "1" &THEN
        IF VALID-HANDLE(hdataset:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hdataset:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
      &ENDIF
      PUT stream LogStream SKIP.
      OUTPUT stream LogStream CLOSE.

    end.
    hdataset = hdataset:NEXT-SIBLING.
    if valid-handle(v-tth) then do:
      delete object v-tth no-error.
      if error-status:error then do:
         OUTPUT stream LogStream TO "memdump.log" APPEND.
         PUT stream LogStream "error on deleting" skip.
         OUTPUT stream LogStream CLOSE.
      end.
      v-tth = ?.
    end.
  END.


  ASSIGN hBuffer = SESSION:FIRST-BUFFER.
  DO WHILE VALID-HANDLE(hBuffer):
    IF VALID-HANDLE((hBuffer:TABLE-HANDLE)) THEN DO:
      v-tth = hBuffer:TABLE-HANDLE.
      OUTPUT stream LogStream TO "memdump.log" APPEND.
      PUT stream LogStream UNFORMATTED SKIP
        "** Dump:" space TODAY space STRING(TIME,'HH:MM:SS') SKIP
        "** Dynamic temp-tables **" SKIP
        "** label" space p-metka skip
        .
      do
      on error undo, leave
      :
        PUT stream LogStream
          hBuffer:TABLE-HANDLE:NAME FORMAT "x(20)" AT 2
            " "
          string(hBuffer:TABLE-HANDLE) FORMAT "x(20)"
            " ".
      end.

      &IF PROVERSION BEGINS "1" &THEN
        IF VALID-HANDLE(hBuffer:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hBuffer:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
      &ENDIF
      PUT stream LogStream SKIP.
      OUTPUT stream LogStream CLOSE.
    END.
    else do:
      OUTPUT stream LogStream TO "memdump.log" APPEND.
      PUT stream LogStream UNFORMATTED SKIP
        "** Dump: " space TODAY space STRING(TIME,'HH:MM:SS') SKIP
        "** STATIC TABLE **" SKIP
        "** label" space p-metka skip
        .
      do
      on error undo, leave
      :
        PUT stream LogStream
          string(hBuffer:TABLE) FORMAT "x(20)" AT 2
            " "
          string(hBuffer) FORMAT "x(20)"
            " ".
      end.

      &IF PROVERSION BEGINS "1" &THEN
        IF VALID-HANDLE(hBuffer:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hBuffer:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
      &ENDIF
      PUT stream LogStream SKIP.
      OUTPUT stream LogStream CLOSE.

    end.
    hBuffer = hBuffer:NEXT-SIBLING.
    if valid-handle(v-tth) then do:
      delete object v-tth no-error.
      if error-status:error then do:
         OUTPUT stream LogStream TO "memdump.log" APPEND.
         PUT stream LogStream "error on deleting" skip.
         OUTPUT stream LogStream CLOSE.
      end.
      v-tth = ?.
    end.
  END.