block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: fileapnd.p $
$Archive: gbl/fileapnd.p $

Записать информацию в файл в режиме добавления.

Автор: Перваков Михаил Сергеевич
Дата создания: 01/25/06
Author: Mikhail Pervakov
Creation date: 01/25/06

Если файл занят, то программа будет ожидать освобождения файла
в течение времени не более, чем указанное время ожидания.
При завершении по таймауту, программа вернет ошибку.

Если время ожидания 0 - то программа будет ждать неограниченно долго.

После каждой попытки программа будет ожидать случайное количество
времени и повторять попытку открытия файла.

p-file-name - имя файла, в который необходимо произвести запись
              Это должно быть полное имя файла с разделителями операционной системы windows
              В имени файл допускаются пробелы

p-write-string - данные, которые необходимо записать
                 символ новой строки следует задавать как
                 последовательность байт 0xD 0xA (CHR(13) CHR(10))
                ##################################
                #!!! ТОЛЬКО ТАК И НИКАК ИНАЧЕ !!!#
                #{&carriage-return} + {&new-line}#
                #!!! ТОЛЬКО ТАК И НИКАК ИНАЧЕ !!!#
                ##################################

p-time-to-wait-seconds максимальное время ожидания в секундах
                0 - ожидать бесконечно долго
                любое положительное целое число - ожидать не более
                    указанного количества секунд
*/

define input  parameter p-file-name            as character no-undo .
define input  parameter p-write-string         as longchar  no-undo .
define input  parameter p-time-to-wait-seconds as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fileapnd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/fileapnd.p $":U .
define variable vss-description as character no-undo init "Записать информацию в файл в режиме добавления. Версия с позиционированием на конец файла".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-file-name,p-write-string,p-time-to-wait-seconds)" }
{ cmp/str-glbl.i }
/*{ gbl/waitfram.i }*/

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

define variable v-memptr-file-name       as memptr    no-undo .
define variable v-memptr-write-string    as memptr    no-undo .
define variable v-file-handle            as integer   no-undo .
define variable v-error-value            as integer   no-undo .
define variable v-result                 as integer   no-undo .
define variable v-random-wait-time       as integer   no-undo .
define variable v-start-time             as int64     no-undo .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
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


  if p-write-string = ?
  then do:
    undo, return error "Ошибка задания входных параметров. Не задана строка" .
  end.

  if p-write-string = '':u
  then do:
    /* пустая строка - ничего не делаем */
    return . /* --->>>--- */
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
/*    assign*/
/*      set-size(v-memptr-file-name) = length(p-file-name) + 1*/
/*    .*/
/*    assign*/
/*      put-string(v-memptr-file-name, 1) = p-file-name*/
/*    .*/
/*    message*/
/*      "X"*/
/*      get-pointer-value(v-memptr-file-name)*/
/*      view-as alert-box.*/
    run CreateFileA
      (input  p-file-name /*get-pointer-value(v-memptr-file-name)*/ /* lpFileName            */
      ,input  {&GENERIC_WRITE}                      /* dwDesiredAccess       */
      ,input  {&FILE_SHARE_READ}                    /* dwShareMode           */
      ,input  0                                     /* lpSecurityAttributes  */
      ,input  {&OPEN_ALWAYS}                        /* dwCreationDisposition */
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

    if v-file-handle <> {&INVALID_HANDLE_VALUE}
    then do:
      leave wait_block .
    end.

    if v-file-handle = {&INVALID_HANDLE_VALUE}
    then do:
      case v-error-value
      :
        when 32
        then do:
          /* попытка одновременного открытия файла */
          /* Ошибка 32 - Процесс не может получить доступ к файлу, */
          /*             так как этот файл занят другим процессом. */
          if p-time-to-wait-seconds <> 0
          and (etime - v-start-time) / 1000 > p-time-to-wait-seconds
          then do:
            undo, return error
              substitute("Запись в файл &1. Превышено допустимое время ожидания открытия файла &2"
                        ,p-file-name
                        ,p-time-to-wait-seconds
                        ) .
          end.
/*          run waitfram-show in this-procedure                              */
/*            (input substitute("Файл &1 занят. Ожидание освобождения файла."*/
/*                            ,p-file-name                                   */
/*                            )                                              */
/*            ) .                                                            */
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
    (input v-file-handle /* hFile                */
    ,input 0             /* lDistanceToMove      */
    ,input 0             /* lpDistanceToMoveHigh */
    ,input {&FILE_END}   /* dwMoveMethod         */
    ,output v-result     /* RetParam             */
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
    (input  v-file-handle                                /* hFile                  */
    ,input  get-pointer-value(v-memptr-write-string) + 4 /* lpBuffer               */
    ,input  v-bytes-to-write                             /* nNumberOfBytesToWrite  */
    ,input  get-pointer-value(v-memptr-write-string)     /* lpNumberOfBytesWritten */
    ,input  0                                            /* lpOverlapped           */
    ,output v-result                                     /* RetParam               */
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