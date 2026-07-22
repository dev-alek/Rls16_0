block-level on error undo, throw.
define input  parameter p-file-name         as character no-undo .
define input  parameter p-file-position     as integer   no-undo .
define input  parameter p-bytes-to-read     as integer   no-undo .
define input  parameter p-block-data-memptr as memptr    no-undo .
define output parameter p-read-bytes        as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: readbin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/readbin.p $":U .
define variable vss-description as character no-undo init "Считать двоичную информацию из файла".
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
define variable v-memptr-file-name  as memptr    no-undo .
define variable v-memptr-read-bytes as memptr    no-undo .
define variable v-file-handle       as integer   no-undo .
define variable v-error-value       as integer   no-undo .
define variable v-result            as integer   no-undo .
do
on error undo, return error return-value
:
  if p-file-name = ?
  or p-file-name = '':u
  then do:
    undo, return error "Ошибка задания входных параметров. Не задано имя файла" .
  end.
  if length(p-file-name) > 260
  then do:
    undo, return error
      substitute("Ошибка задания входных параметров. Имя файла превышает максимально возможную длину. Имя файла &1"
                ,p-file-name
                ) .
  end.
  if p-file-position = ?
  then do:
    undo, return error "Ошибка задания входных параметров. Не задана позиция файла" .
  end.
  if p-file-position < 0
  then do:
    undo, return error substitute("Ошибка задания входных параметров. Позиция в файле не может быть отрицательной. Задана позиция файла &1."
                                 ,p-file-position
                                 ) .
  end.
  if p-bytes-to-read = ?
  then do:
    undo, return error "Ошибка задания входных параметров. Не задано количество байт для считывания" .
  end.
  if p-bytes-to-read < 0
  then do:
    undo, return error substitute("Ошибка задания входных параметров. Количество данных для чтения не может быть отрицательным. Задано количество данных для чтения &1"
                                 ,p-bytes-to-read
                                 ) .
  end.
  if get-size(p-block-data-memptr) < p-bytes-to-read
  then do:
    undo, return error substitute("Ошибка задания входных параметров. Область памяти меньше запрошенной длины для чтения. Задано количество данных для чтения &1. Длина блока &2"
                                 ,p-bytes-to-read
                                 ,get-size(p-block-data-memptr)
                                 ) .
  end.
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
  if v-file-handle = -1
  then do:
    run GetLastError
      (output v-error-value
      ) .
  end.
  assign
    set-size(v-memptr-file-name) = 0
  .
  if v-file-handle = -1
  then do:
    undo, return error
      substitute("Ошибка открытия файла &1. Номер ошибки &2"
                ,p-file-name
                ,v-error-value
                ) .
  end.
  run SetFilePointer
    (input v-file-handle
    ,input p-file-position
    ,input 0
    ,input 0
    ,output v-result
    ) .
  if v-result = -1
  then do:
    run GetLastError
      (output v-error-value
      ) .
    if v-error-value <> 0
    then do:
      if v-file-handle <> -1
      then do:
        run CloseHandle
          (input  v-file-handle
          ,output v-result
          ) .
        assign
          v-file-handle = -1
        .
      end.
      undo, return error
        substitute("Ошибка позиционирования по смещению &1 файла &2. Номер ошибки &3"
                  ,p-file-position
                  ,p-file-name
                  ,v-error-value
                  ) .
    end.
  end.
  assign
    set-size(v-memptr-read-bytes) = 4
  .
  run ReadFile
    (input  v-file-handle
    ,input  get-pointer-value(p-block-data-memptr)
    ,input  p-bytes-to-read
    ,input  get-pointer-value(v-memptr-read-bytes)
    ,input  0
    ,output v-result
    ) .
  assign
    p-read-bytes = get-long(v-memptr-read-bytes, 1)
  .
  assign
    set-size(v-memptr-read-bytes) = 0
  .
  run CloseHandle
    (input  v-file-handle
    ,output v-result
    ) .
end.
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
PROCEDURE ReadFile EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hFile                AS LONG .
    DEFINE INPUT        PARAMETER lpBuffer             AS LONG .
    DEFINE INPUT        PARAMETER nNumberOfBytesToRead AS LONG .
    DEFINE INPUT        PARAMETER lpNumberOfBytesRead  AS LONG .
    DEFINE INPUT        PARAMETER lpOverlapped         AS LONG .
    DEFINE RETURN       PARAMETER RetParam             AS LONG .
END PROCEDURE .
PROCEDURE SetFilePointer EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hFile                AS LONG .
    DEFINE INPUT        PARAMETER lDistanceToMove      AS LONG .
    DEFINE INPUT        PARAMETER lpDistanceToMoveHigh AS LONG .
    DEFINE INPUT        PARAMETER dwMoveMethod         AS LONG .
    DEFINE RETURN       PARAMETER RetParam             AS LONG .
END PROCEDURE .
