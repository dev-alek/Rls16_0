block-level on error undo, throw.
define input  parameter p-callback-handle    as handle    no-undo .
define input  parameter p-callback-procedure as character no-undo .
define input  parameter p-directory-name     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dirwatch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dirwatch.p $":U .
define variable vss-description as character no-undo init "Программа ожидания файла".
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
define variable v-proc-signature  as character no-undo .
define variable v-directory-name  as character no-undo .
define variable v-change-handle   as integer   no-undo .
define variable v-result          as integer   no-undo .
define variable v-memptr-dir-name as memptr    no-undo .
define variable v-ret-param       as integer   no-undo .
define variable v-terminate-watch as logical   no-undo .
do
on error undo, return error return-value
:
  if valid-handle(p-callback-handle) <> true
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задан указатель на процедуру &1", p-callback-handle) .
  end.
  assign
    v-proc-signature = p-callback-handle :get-signature(p-callback-procedure)
  .
  if v-proc-signature = ""
  or v-proc-signature = ?
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя процедуры &1", p-callback-procedure) .
  end.
  assign
    file-info :file-name = p-directory-name
    v-directory-name     = file-info :full-pathname
  .
  if v-directory-name = ?
  or v-directory-name = ""
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя директории &1.", p-directory-name) .
  end.
  if index(file-info :file-type, "D") = 0
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя директории &1.", p-directory-name) .
  end.
  assign
    set-size(v-memptr-dir-name) = length(v-directory-name) + 1
  .
  assign
    put-string(v-memptr-dir-name, 1) = v-directory-name
  .
  run FindFirstChangeNotificationA
    (input v-memptr-dir-name
    ,input 0
    ,input 1
    ,output v-change-handle
    ) .
  if v-change-handle = -1
  then do:
    undo, return error "Ошибка при вызове функции FindFirstChangeNotificationA" .
  end.
  run value(p-callback-procedure) in p-callback-handle
    (output v-terminate-watch
    ) .
  if v-terminate-watch <> true
  then do:
    watch_cycle:
    do while true
    :
      run WaitForSingleObject
        (input  v-change-handle
        ,input  1000
        ,output v-result
        ) .
      if v-result = 0
      then do:
        run FindNextChangeNotification
          (input  v-change-handle
          ,output v-result
          ) .
        if v-result = 0
        then do:
          run FindCloseChangeNotification
            (input  v-change-handle
            ,output v-result
            ) .
          undo, return error "Ошибка при вызове функции FindNextChangeNotification" .
        end.
      end.
      run value(p-callback-procedure) in p-callback-handle
        (output v-terminate-watch
        ) .
      if v-terminate-watch = true
      then do:
        leave watch_cycle .
      end.
    end.
  end.
  run FindCloseChangeNotification
    (input  v-change-handle
    ,output v-result
    ) .
end.
PROCEDURE FindFirstChangeNotificationA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpPathName       AS MEMPTR .
    DEFINE INPUT        PARAMETER bWatchSubtree    AS LONG   .
    DEFINE INPUT        PARAMETER dwNotifyFilter   AS LONG   .
    DEFINE RETURN       PARAMETER RetParam         AS LONG   .
END PROCEDURE.
PROCEDURE FindNextChangeNotification EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle    AS LONG   .
    DEFINE RETURN       PARAMETER RetParam         AS LONG   .
END PROCEDURE.
PROCEDURE FindCloseChangeNotification EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle    AS LONG.
    DEFINE RETURN       PARAMETER RetParam         AS LONG.
END PROCEDURE.
PROCEDURE WaitForSingleObject EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle  AS LONG.
    DEFINE INPUT        PARAMETER dwMilliseconds AS LONG.
    DEFINE RETURN       PARAMETER RetParam       AS LONG.
END PROCEDURE.
