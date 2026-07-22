block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: readbin.p $
$Archive: gbl/readbin.p $

Считать двоичную информацию из файла

Автор: Перваков Михаил Сергеевич
Дата создания: 01/25/06
Author: Mikhail Pervakov
Creation date: 01/25/06

!!! ВНИМАНИЕ !!!
Блок памяти p-block-data-memptr
должен быть выделен, а после вызова программы освобожден

Пример использования программы

define variable v-read-data-memptr as memptr    no-undo .
define variable v-data-read        as integer   no-undo .
define variable v-index            as integer   no-undo .
define variable v-block-length     as integer   no-undo .

assign
  v-block-length = 4
  set-size(v-read-data-memptr) = v-block-length
.

run gbl/readbin.p
  (input  'd:\test.bin':U
  ,input  15
  ,input  v-block-length
  ,input  v-read-data-memptr
  ,output v-data-read
  ) no-error .
if error-status :error
then do:
  assign
    set-size(v-read-data-memptr) = 0
  .
  message
    "Ошибка чтения данных из файла" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  if v-data-read <> v-block-length
  then do:
    message
      "Прочитано данных менее чем запрашивалось" skip
      "Запрошено" v-block-length skip
      "Прочитано" v-data-read skip
      view-as alert-box information .
  end.

  do v-index = 1 to v-data-read
  :
    message
      v-index skip
      get-byte(v-read-data-memptr, v-index) skip
      view-as alert-box information .
  end.
  assign
    set-size(v-read-data-memptr) = 0
  .
end.

*/


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
{ cmp/vssrevis.i }

&scoped-define FILE_APPEND_DATA 4
&scoped-define GENERIC_READ -2147483648
&scoped-define GENERIC_WRITE 1073741824
&scoped-define FILE_SHARE_READ 1
&scoped-define CREATE_NEW 1
&scoped-define CREATE_ALWAYS 2
&scoped-define OPEN_EXISTING 3
&scoped-define OPEN_ALWAYS 4
&scoped-define FILE_ATTRIBUTE_NORMAL 128
&scoped-define INVALID_HANDLE_VALUE -1
&scoped-define FILE_BEGIN 0
&scoped-define FILE_CURRENT 1
&scoped-define FILE_END 2
&scoped-define FILE_SHARE_READ 1
&scoped-define MAX_PATH 260
&scoped-define NO_ERROR 0
&scoped-define INVALID_FILE_POINTER -1

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

  if length(p-file-name) > {&MAX_PATH}
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
    (input  get-pointer-value(v-memptr-file-name) /* lpFileName            */
    ,input  {&GENERIC_READ}                       /* dwDesiredAccess       */
    ,input  {&FILE_SHARE_READ}                    /* dwShareMode           */
    ,input  0                                     /* lpSecurityAttributes  */
    ,input  {&OPEN_EXISTING}                      /* dwCreationDisposition */
    ,input  {&FILE_ATTRIBUTE_NORMAL}              /* dwFlagsAndAttributes  */
    ,input  0                                     /* hTemplateFile         */
    ,output v-file-handle                         /* RetParam              */
    ) .
  if v-file-handle = {&INVALID_HANDLE_VALUE}
  then do:
    run GetLastError
      (output v-error-value
      ) .
  end.

  assign
    set-size(v-memptr-file-name) = 0
  .

  if v-file-handle = {&INVALID_HANDLE_VALUE}
  then do:
    undo, return error
      substitute("Ошибка открытия файла &1. Номер ошибки &2"
                ,p-file-name
                ,v-error-value
                ) .
  end.

  run SetFilePointer
    (input v-file-handle   /* hFile                */
    ,input p-file-position /* lDistanceToMove      */
    ,input 0               /* lpDistanceToMoveHigh */
    ,input {&FILE_BEGIN}   /* dwMoveMethod         */
    ,output v-result       /* RetParam             */
    ) .
  if v-result = {&INVALID_FILE_POINTER}
  then do:
    run GetLastError
      (output v-error-value
      ) .
    if v-error-value <> {&NO_ERROR}
    then do:
      if v-file-handle <> {&INVALID_HANDLE_VALUE}
      then do:
        run CloseHandle
          (input  v-file-handle
          ,output v-result
          ) .
        assign
          v-file-handle = {&INVALID_HANDLE_VALUE}
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
    (input  v-file-handle                          /* hFile                */
    ,input  get-pointer-value(p-block-data-memptr) /* lpBuffer             */
    ,input  p-bytes-to-read                        /* nNumberOfBytesToRead */
    ,input  get-pointer-value(v-memptr-read-bytes) /* lpNumberOfBytesRead  */
    ,input  0                                      /* lpOverlapped         */
    ,output v-result                               /* RetParam             */
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
END PROCEDURE. /* CreateFileA */

PROCEDURE CloseHandle EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hObject   AS LONG .
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE. /* CloseHandle */

PROCEDURE GetLastError EXTERNAL "kernel32.dll"
:
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE. /* GetLastError */

PROCEDURE Sleep EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER pMilliseconds AS LONG .
END PROCEDURE. /* CloseHandle */

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