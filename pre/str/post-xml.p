block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-news     as logical no-undo .
define input parameter p-auto     as logical no-undo .
define input parameter p-mode     as character no-undo .
define input parameter log-file-name as character no-undo .
define input parameter p-url as character no-undo .
define input parameter p-post-file-name as character no-undo .
define input parameter p-response-file-name as character no-undo .
define input parameter p-response-time   as integer no-undo .
DEFINE INPUT PARAMETER p-mess AS CHAR NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск на выполнение командной строки без экрана".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function IsProcessRunning return integer
  (PID AS INTEGER) :
  DEFINE VARIABLE IsRunning   AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE hProcess    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ExitCode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  define variable rv          as integer no-undo .
  RUN OpenProcess in hpapi
                  ( 1024,
                    0,
                    PID,
                    OUTPUT hProcess).
  IF hProcess NE 0 THEN DO:
     RUN GetExitcodeProcess in hpapi
                  ( hProcess,
                    OUTPUT ExitCode,
                    OUTPUT ReturnValue).
     rv = (if (ExitCode=259) AND (ReturnValue NE 0)
          then  - 1
          else ReturnValue).
     RUN CloseHandle in hpapi (hProcess, OUTPUT ReturnValue).
  END.
  RETURN rv.
end.
define variable Cmd                       AS CHARacter                No-UNDO.
define variable cmd-out                   as character                no-undo .
define variable v-result                  as character                no-undo .
define variable curl-path                 as character                no-undo .
define variable HiNSTANCE                 AS INTEGER                  NO-UNDO.
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-errrs                   as character                no-undo .
define variable v-std-err-file-name       as character                no-undo .
define variable bat-file                  as character                no-undo.
define variable v-size                    as integer                  no-undo .
define variable rv                        as integer                  no-undo .
define variable v-pid                     as integer                  no-undo .
define variable v-instant                 as logical                  no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
    curl-path = search("exe/curl.exe")
  .
  if curl-path = ? then do:
    undo main-block, return error "Не найден путь к файлу exe/curl.exe" .
  end.
  if num-entries(p-mode) > 1 then do:
    if entry(2,p-mode) = "instant" then do:
      v-instant = yes.
    end.
    p-mode = entry(1, p-mode).
  end.
  OS-DELETE value(p-response-file-name).
  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-mess      ).
  if (p-news or p-auto)
  and p-mode <>'get'
  then do:
    run gbl/_tmpfile.p (
                        input ""
                      , input "err"
                      , output v-std-err-file-name) .
    run gbl/_tmpfile.p (
                        input ""
                      , input "bat"
                      , output bat-file) .
    assign
    cmd = substitute('"&1" -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 --stderr &4 '
                    , curl-path
                    , p-post-file-name
                    , p-url
                    , v-std-err-file-name
                    )
    .
    output to value(bat-file) convert target "ibm866".
    PUT  UNFORMATTED cmd SKIP.
    output close.
  end.
  else do:
    run gbl/_tmpfile.p (
                        input ""
                      , input "bat"
                      , output bat-file) .
    assign
    cmd = substitute('"&1" -0 --trace-ascii test.txt -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                    , curl-path
                    , p-post-file-name
                    , p-url
                    , p-response-file-name)
    .
    output to value(bat-file) convert target "ibm866".
    PUT  UNFORMATTED cmd SKIP.
    output close.
  end.
  if (p-news = yes
  or p-auto = yes) then do:
    run gbl/run-gpid.p (
                      input bat-file
                     ,input '':U
                     ,output v-pid).
  end.
  else do:
    OS-COMMAND silent  value(bat-file).
  end.
  define variable v-time-count as integer no-undo .
  define variable v-err-file-found as logical no-undo .
  if v-instant then do:
    p-response-time = p-response-time * 2.
  end.
  if (not (p-news = yes or p-auto = yes) )
  or p-mode = 'get'
  then do:
    REPEAT:
      _repeat:
      REPEAT WHILE v-time-count < p-response-time :
        assign
          v-time-count = v-time-count + 1
        .
        run gbl/pause.p( 1000).
        assign
          FILE-INFO :FILE-NAME = p-response-file-name
        .
        if file-info = ? then do:
          v-time-count = v-time-count - 1.
          run gbl/pause.p( 1000).
          next _repeat.
        end.
        IF INDEX(FILE-INFO:FILE-TYPE, "F")  > 0 then  do:
          input from value(p-response-file-name).
          import unformatted v-result no-error .
          input close.
          if error-status:error
          or not (v-result begins "<?xml") then do:
            v-errrs = error-status:get-message(1) .
            OS-DELETE value(p-post-file-name).
            OS-DELETE value(p-response-file-name).
            OS-DELETE value(bat-file).
            return error.
          end.
          assign
            v-err-file-found = true
          .
          leave .
       end.
     END.
     if v-time-count > p-response-time
     or v-err-file-found = yes
     then leave.
     v-time-count = v-time-count + 1.
     if error-status:error then do:
        v-time-count = v-time-count + 1.
     end.
   end.
   if v-err-file-found <> true then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Превышено время ожидания &1&2Не найден файл с результатом выполнения задания &3&2&4"
                          , p-response-time
                          , chr(10)
                          , cmd
                          , v-errrs)
                           ).
      OS-DELETE value(bat-file).
      if not (p-news = ? and p-auto = ?) then
      OS-DELETE value(p-post-file-name).
    end.
    else do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Время ожидания выполнения задания на кассе - &1 c"
                          , v-time-count
                           )).
    end.
  end.
  else do:
    _nrepeat:
    REPEAT WHILE v-time-count < 14 :
      assign
        v-time-count = v-time-count + 1
      .
      pause 1 no-message .
      rv = IsProcessRunning(v-pid).
      if rv >= 0 then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Время ожидания выполнения задания на кассе - &1 с"
                            , v-time-count
                            )).
        assign
        FILE-INFO :FILE-NAME = v-std-err-file-name
        .
        if file-info:full-pathname = v-std-err-file-name  then do:
           run gbl/filesize.p ( input v-std-err-file-name
                           ,output v-size ) no-error .
           if v-size <> 0 then do:
             run gbl/filename.p (
                input p-post-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
            run copyto-log-and-file in p-log-handle ( input v-std-err-file-name
                                                    ,input 1
                                                    ,input log-file-name
                                                    ,input 1
                                                    ).
            os-delete value (v-std-err-file-name).
            if not v-instant then do:
            run gbl/dir-cre.p ( input v-path + '\undelivered\') no-error .
            if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute(
                                    "!!!Каталог &1 для хранения НЕДОСТАВЛЕННЫХ файлов не найден&2" +
                                    "и/или попытка его создания не удалась:&2&3 &4"
                                    , v-path + '\undelivered\'
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    )).
              return "error".
            end.
            else do:
              os-rename value( p-post-file-name  )  value( v-path + '\undelivered\' + v-file-name ) .
            end.
            end.
          end.
          else do:
            os-delete value (v-std-err-file-name).
          end.
        end.
        leave _nrepeat.
      end.
    end.
    if v-time-count >= 14 then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Время ожидания выполнения задания на кассе - &1 с"
                          , v-time-count
                          )).
    end.
  end.
  OS-DELETE value(bat-file).
  OS-DELETE value(p-post-file-name).
end.
