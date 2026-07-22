block-level on error undo, throw.
define input parameter p-metka as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ttq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ttq.p $":U .
define variable vss-description as character no-undo init "Отлов мусорных tt".
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
        IF VALID-HANDLE(hdataset:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hdataset:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
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
        IF VALID-HANDLE(hdataset:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hdataset:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
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
        IF VALID-HANDLE(hBuffer:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hBuffer:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
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
        IF VALID-HANDLE(hBuffer:INSTANTIATING-PROCEDURE) THEN
          PUT stream LogStream "procedure" hBuffer:INSTANTIATING-PROCEDURE:FILE-NAME FORMAT "x(40)".
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
