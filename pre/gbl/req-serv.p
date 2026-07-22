block-level on error undo, throw.
define input  parameter p-callback-handle as handle    no-undo .
define input  parameter p-in-directory    as character no-undo .
define input  parameter p-out-directory   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: req-serv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/req-serv.p $":U .
define variable vss-description as character no-undo init "Программа разбора запросов".
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
define stream dir-list .
define stream sinp .
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  index xpk is unique primary file-name
  index xie1 file-name-no-ext
  .
do
on error undo, return error return-value
:
  define variable v-num-request as integer no-undo .
  run w-reqsrv_show-description in p-callback-handle
    (input  "Сервер запущен"
    ) .
  run gbl/dirwatch.p
    (input  this-procedure
    ,input  "check-directory"
    ,input  p-in-directory
    ) .
end.
procedure check-directory :
  define output parameter p-terminate-watch as logical no-undo .
  define buffer buf_temp-filelist for temp-filelist .
  do
  on error undo, return error return-value
  :
    for each buf_temp-filelist
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-in-directory ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .
    repeat
    on error undo, return error
    :
      import stream dir-list v-file v-path v-mask .
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
      end.
      else do:
        next .
      end.
      if num-entries(v-file, '.':u) > 1
      then do:
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.
      if v-extension = 'txt':u
      then do:
        create buf_temp-filelist .
        assign
          buf_temp-filelist.file-name        = v-file
          buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
          buf_temp-filelist.file-extension   = v-extension
        .
      end.
    end.
    input stream dir-list close .
    define variable v-ip-address     as character no-undo .
    define variable v-request        as character no-undo .
    define variable v-post-data      as character no-undo .
    define variable v-request-ok     as logical   no-undo .
    define variable v-error-message  as character no-undo .
    file_scan :
    for each buf_temp-filelist
    :
      assign
        v-num-request = v-num-request + 1
        v-request-ok  = true
      .
      define variable v-check-file-name as character no-undo .
      define variable v-open-ok         as logical   no-undo .
      define variable v-error-code      as integer   no-undo .
      assign
        v-check-file-name = p-in-directory + '/':u + buf_temp-filelist.file-name
      .
      define variable v-try-index as integer   no-undo .
      assign
        v-try-index = 0
      .
      define variable v-show-error as logical   no-undo .
      assign
        v-show-error = true
      .
      wait_open :
      do while true
      :
        assign
          v-try-index = v-try-index + 1
        .
        if v-try-index > 1000
        then do:
          next file_scan .
        end.
        run check-open in this-procedure
          (input  v-check-file-name
          ,output v-open-ok
          ,output v-error-code
          ) .
        if v-open-ok = true
        then do:
          leave wait_open .
        end.
        if v-show-error = true
        then do:
          assign
            v-show-error = false
          .
          run w-reqsrv_show-request in p-callback-handle
            (input  substitute("&1 Ошибка открытия файла &2"
                              ,buf_temp-filelist.file-name
                              ,v-error-code
                              )
            ) .
        end.
      end.
      run w-reqsrv_process-request in p-callback-handle
        (input  buf_temp-filelist.file-name
        ) .
    end.
    run w-reqsrv_check-stop in p-callback-handle
      (output p-terminate-watch
      ) .
  end.
end procedure .
procedure check-open :
  define input  parameter p-file-name  as character no-undo .
  define output parameter p-open-ok    as logical   no-undo .
  define output parameter p-error-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-memptr-file-name as memptr no-undo .
    define variable v-file-handle      as integer   no-undo .
    define variable v-error-value      as integer   no-undo .
    define variable v-result           as integer   no-undo .
    assign
      set-size(v-memptr-file-name) = length(p-file-name) + 1
    .
    assign
      put-string(v-memptr-file-name, 1) = p-file-name
    .
    run CreateFileA
      (input  get-pointer-value(v-memptr-file-name)
      ,input  -2147483648
      ,input  1
      ,input  0
      ,input  3
      ,input  128
      ,input  0
      ,output v-file-handle
      ) .
    assign
      set-size(v-memptr-file-name) = 0
    .
    if v-file-handle = -1
    then do:
      run GetLastError
        (output v-error-value
        ) .
      run Sleep
        (input 10
        ) .
      assign
        p-open-ok    = false
        p-error-code = v-error-value
      .
    end.
    else do:
      assign
        p-open-ok    = true
        p-error-code = 0
      .
    end.
    run CloseHandle
      (input  v-file-handle
      ,output v-result
      ) .
  end.
end procedure.
PROCEDURE CreateFileA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpFileName            AS LONG .
    DEFINE INPUT        PARAMETER dwDesiredAccess       AS LONG .
    DEFINE INPUT        PARAMETER dwShareMode           AS LONG .
    DEFINE INPUT        PARAMETER lpSecurityAttributes  AS LONG .
    DEFINE INPUT        PARAMETER dwCreationDisposition AS LONG .
    DEFINE INPUT        PARAMETER dwFlagsAndAttributes  AS LONG .
    DEFINE INPUT        PARAMETER hTemplateFile         AS LONG .
    DEFINE RETURN       PARAMETER RetParam              AS LONG .
END PROCEDURE.
PROCEDURE CloseHandle EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hObject   AS LONG .
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE.
PROCEDURE GetLastError EXTERNAL "kernel32.dll"
:
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE.
PROCEDURE Sleep EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER pMilliseconds AS LONG .
END PROCEDURE.
