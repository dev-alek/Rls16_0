block-level on error undo, throw.
define input  parameter p-file-name            as character no-undo .
define input  parameter p-write-string         as longchar  no-undo .
define input  parameter p-time-to-wait-seconds as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fileapnd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/fileapnd.p $":U .
define variable vss-description as character no-undo init "Записать информацию в файл в режиме добавления. Версия с позиционированием на конец файла".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3',p-file-name,p-write-string,p-time-to-wait-seconds)
    .
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
define variable v-memptr-file-name       as memptr    no-undo .
define variable v-memptr-write-string    as memptr    no-undo .
define variable v-file-handle            as integer   no-undo .
define variable v-error-value            as integer   no-undo .
define variable v-result                 as integer   no-undo .
define variable v-random-wait-time       as integer   no-undo .
define variable v-start-time             as int64     no-undo .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
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
  if p-write-string = ?
  then do:
    undo, return error "Ошибка задания входных параметров. Не задана строка" .
  end.
  if p-write-string = '':u
  then do:
    return .
  end.
  if p-time-to-wait-seconds = ?
  then do:
    undo, return error "Ошибка задания входных параметров. Не задано время ожидания" .
  end.
  if p-time-to-wait-seconds < 0
  then do:
    undo, return error substitute("Ошибка задания входных параметров. Время ожидания не может быть отрицательным. Задано время ожидания &1"
                                 ,p-time-to-wait-seconds
                                 ) .
  end.
  assign
    v-start-time = etime
  .
  wait_block:
  do while true
  :
    run CreateFileA
      (input  p-file-name
      ,input  1073741824
      ,input  1
      ,input  0
      ,input  4
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
    if v-file-handle <> -1
    then do:
      leave wait_block .
    end.
    if v-file-handle = -1
    then do:
      case v-error-value
      :
        when 32
        then do:
          if p-time-to-wait-seconds <> 0
          and (etime - v-start-time) / 1000 > p-time-to-wait-seconds
          then do:
            undo, return error
              substitute("Запись в файл &1. Превышено допустимое время ожидания открытия файла &2"
                        ,p-file-name
                        ,p-time-to-wait-seconds
                        ) .
          end.
          assign
            v-random-wait-time = random(50, 300)
          .
          run Sleep
            (input v-random-wait-time
            ) .
        end.
        otherwise do:
          undo, return error
            substitute("Ошибка открытия файла &1. Номер ошибки &2"
                      ,p-file-name
                      ,v-error-value
                      ) .
        end.
      end case .
    end.
  end.
  define variable v-bytes-to-write as int64   no-undo .
  define variable v-written-bytes  as int64   no-undo .
  assign
    v-bytes-to-write = length(p-write-string)
  .
  run SetFilePointer
    (input v-file-handle
    ,input 0
    ,input 0
    ,input 2
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
        substitute("Ошибка позиционирования в конец файла &1. Номер ошибки &2"
                  ,p-file-name
                  ,v-error-value
                  ) .
    end.
  end.
  assign
    set-size(v-memptr-write-string) = v-bytes-to-write + 5
  .
  assign
    put-string(v-memptr-write-string, 5) = p-write-string
  .
  run WriteFile
    (input  v-file-handle
    ,input  get-pointer-value(v-memptr-write-string) + 4
    ,input  v-bytes-to-write
    ,input  get-pointer-value(v-memptr-write-string)
    ,input  0
    ,output v-result
    ) .
  assign
    v-written-bytes = get-long(v-memptr-write-string, 1)
  .
  if v-written-bytes <> v-bytes-to-write
  then do:
    run GetLastError
      (output v-error-value
      ) .
  end.
  assign
    set-size(v-memptr-write-string) = 0
  .
  run CloseHandle
    (input  v-file-handle
    ,output v-result
    ) .
  if v-written-bytes <> v-bytes-to-write
  then do:
    undo, return error
      substitute("Ошибка при записи данных в файл &1. Была запрошена запись &2 байт. Записано &3 байт. Номер ошибки &4."
                ,p-file-name
                ,v-bytes-to-write
                ,v-written-bytes
                ,v-error-value
                ) .
  end.
end.
PROCEDURE CreateFileA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpFileName            as character .
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
PROCEDURE WriteFile EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hFile                  AS LONG .
    DEFINE INPUT        PARAMETER lpBuffer               AS LONG .
    DEFINE INPUT        PARAMETER nNumberOfBytesToWrite  AS LONG .
    DEFINE INPUT        PARAMETER lpNumberOfBytesWritten AS LONG .
    DEFINE INPUT        PARAMETER lpOverlapped           AS LONG .
    DEFINE RETURN       PARAMETER RetParam               AS LONG .
END PROCEDURE .
PROCEDURE SetFilePointer EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hFile                AS LONG .
    DEFINE INPUT        PARAMETER lDistanceToMove      AS LONG .
    DEFINE INPUT        PARAMETER lpDistanceToMoveHigh AS LONG .
    DEFINE INPUT        PARAMETER dwMoveMethod         AS LONG .
    DEFINE RETURN       PARAMETER RetParam             AS LONG .
END PROCEDURE .
