block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: req-serv.p $
$Archive: gbl/req-serv.p $

Программа разбора запросов

Автор: Хныкин Павел Андреевич
Дата создания:
Author: Pavel Khnykin
Creation date:

create: Перваков Михаил Сергеевич
Дата создания: 09/09/05

*/

define input  parameter p-callback-handle as handle    no-undo .
define input  parameter p-in-directory    as character no-undo .
define input  parameter p-out-directory   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: req-serv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/req-serv.p $":U .
define variable vss-description as character no-undo init "Программа разбора запросов".
{ cmp/vssrevis.i }


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

      /* проверяем, что найден файл */
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
        /* это обычный файл */
      end.
      else do:
        next . /* --->>>--- */
      end.

      if num-entries(v-file, '.':u) > 1
      then do:
        /* файл имеет расширение */
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        /* файл имеет пустое расширение */
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
          /* не удается открыть файл */
          /* переходим к следующему файлу */
          next file_scan .
        end.
        /* попытка открытия файла */
        /* в случае неудачной попытки происходит задержка 10 миллисекунд */
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
&scoped-define GENERIC_READ -2147483648
&scoped-define FILE_SHARE_READ 1
&scoped-define OPEN_EXISTING 3
&scoped-define FILE_ATTRIBUTE_NORMAL 128
&scoped-define INVALID_HANDLE_VALUE -1

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
      (input  get-pointer-value(v-memptr-file-name) /* lpFileName            */
      ,input  {&GENERIC_READ}                       /* dwDesiredAccess       */
      ,input  {&FILE_SHARE_READ}                    /* dwShareMode           */
      ,input  0                                     /* lpSecurityAttributes  */
      ,input  {&OPEN_EXISTING}                      /* dwCreationDisposition */
      ,input  {&FILE_ATTRIBUTE_NORMAL}              /* dwFlagsAndAttributes  */
      ,input  0                                     /* hTemplateFile         */
      ,output v-file-handle                         /* RetParam              */
      ) .

    assign
      set-size(v-memptr-file-name) = 0
    .

    if v-file-handle = {&INVALID_HANDLE_VALUE}
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

end procedure. /* check-open */


/* HANDLE CreateFile( */
/*   LPCTSTR lpFileName, */
/*   DWORD dwDesiredAccess, */
/*   DWORD dwShareMode, */
/*   LPSECURITY_ATTRIBUTES lpSecurityAttributes, */
/*   DWORD dwCreationDisposition, */
/*   DWORD dwFlagsAndAttributes, */
/*   HANDLE hTemplateFile */
/* ); */

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


/* BOOL CloseHandle( */
/*   HANDLE hObject */
/* ); */

PROCEDURE CloseHandle EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hObject   AS LONG .
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE. /* CloseHandle */

/* DWORD GetLastError(void); */
PROCEDURE GetLastError EXTERNAL "kernel32.dll"
:
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE. /* GetLastError */

PROCEDURE Sleep EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER pMilliseconds AS LONG .
END PROCEDURE. /* CloseHandle */