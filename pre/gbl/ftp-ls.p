block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ftp-ls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/ftp-ls.p $":U .
define variable vss-description as character no-undo init "Получение списка файлов с FTP".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .
define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical
    index xpk is primary unique dir-full-name
.
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical
  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .
define stream dir-list .
procedure filelist-get-file-num :
  define output parameter p-file-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.
end procedure.
procedure filelist-clear :
  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .
    assign
      v-filelist-total-file-num = 0
    .
    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.
end procedure.
procedure filelist-init :
  do
  on error undo, return error
  :
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .
    define buffer buf_temp-filelist for temp-filelist .
    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-dir-name ).
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
      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next .
        end.
      end.
      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .
      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
    input stream dir-list close .
    return.
  end.
end procedure.
procedure filelist-dirlist-init-by-list :
  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .
    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :
      define variable v-curr-dir  as character no-undo .
      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.
end procedure.
procedure filelist-dirlist-clear :
  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .
    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.
end procedure.
procedure filelist-dirlist-subdir-init :
define input parameter p-dir-name   as character no-undo .
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory.
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    input stream dir-list close .
end.
end procedure.
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .
    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure.
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.
    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure.
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure.
procedure filelist-build-by-dirlist :
    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.
end.
end procedure.
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.
do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE InternetConnectA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszServerName    as  char.
  define input parameter  nServerPort       as  long.
  define input parameter  lpszUserName      as  char.
  define input parameter  lpszPassword      as  char.
  define input parameter  dwService         as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter hInternetConnect  as  long.
END.
PROCEDURE InternetGetLastResponseInfoA EXTERNAL "wininet.dll" PERSISTENT:
  define output parameter lpdwError          as  long.
  define output parameter lpszBuffer         as  char.
  define input-output  parameter lpdwBufferLength   as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenUrlA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszUrl           as  char.
  define input parameter  lpszHeaders       as  char.
  define input parameter  dwHeadersLength   as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  sAgent            as  char.
  define input parameter  lAccessType       as  long.
  define input parameter  sProxyName        as  char.
  define input parameter  sProxyBypass      as  char.
  define input parameter  lFlags            as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetReadFile EXTERNAL "wininet.dll" PERSISTENT:
  define input  parameter  hFile            as  long.
  define output parameter  sBuffer          as  char.
  define input  parameter  lNumBytesToRead  as  long.
  define output parameter  lNumOfBytesRead  as  long.
  define return parameter  iResultCode      as  long.
END.
PROCEDURE InternetCloseHandle EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInet             as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE FtpFindFirstFileA EXTERNAL "wininet.dll" PERSISTENT :
    define input parameter  hFtpSession as  long.
    define input parameter  lpFileName as char.
    define input parameter  lpFindFileData as memptr.
    define input parameter  dwFlags        as long.
    define input parameter  dwContext      as long.
    define return parameter hSearch as long.
END PROCEDURE.
PROCEDURE InternetFindNextFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hSearch as long.
    define input parameter  lpFindFileData as memptr.
    define return parameter found as long.
END PROCEDURE.
PROCEDURE FtpGetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszCurrentDirectory as long.
    define input-output parameter lpdwCurrentDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpSetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpOpenFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession  as long.
    define input parameter  lpszFileName as long.
    define input parameter  dwAccess     as long.
    define input parameter  dwFlags      as long.
    define input parameter  dwContext    as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpPutFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession       as long.
    define input parameter  lpszLocalFile     as long.
    define input parameter  lpszNewRemoteFile as long.
    define input parameter  dwFlags           as long.
    define input parameter  dwContext         as long.
    define return parameter iRetCode          as long.
END PROCEDURE.
PROCEDURE FtpGetFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define input parameter  lpszNewFile          as long.
    define input parameter  fFailIfExists        as long.
    define input parameter  dwFlagsAndAttributes as long.
    define input parameter  dwFlags              as long.
    define input parameter  dwContext            as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE FtpDeleteFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE GetLastError external "kernel32.dll" :
  define return parameter dwMessageID as long.
END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION ConnectWinInet RETURNS LOGICAL (
                                           output hInternetSession as integer
                                        ) :
  run InternetOpenA(input  'WebBasedAgent',
                    input  0,
                    input  '',
                    input  '',
                    input  0,
                    output hInternetSession).
  RETURN hInternetSession <> 0.
END FUNCTION.
FUNCTION CloseInternetConnection rETURNS LOGICAL  (
                                                 input phInternetSession as integer
                                                 ) :
define variable iRetCode      as  integer no-undo.
run InternetCloseHandle(input  phInternetSession,
                        output iRetCode).
RETURN iRetCode > 0.
END FUNCTION.
FUNCTION InternetGetLastResponseInfo RETURNS CHARACTER ( ) :
define variable cBuffer            as  character no-undo.
define variable iBufferSz          as  integer init 4096 no-undo.
define variable iResultCode        as  integer no-undo.
define variable iTemp              as  integer no-undo.
assign
cBuffer = fill(' ', iBufferSz).
run InternetGetLastResponseInfoA (output iResultCode,
                                  output cBuffer,
                                  input-output iBufferSz,
                                  output iTemp).
RETURN substitute('Error (&1):  &2',
                    iResultCode,
                    substr(cBuffer,1,iBufferSz)) .
END FUNCTION.
FUNCTION FtpConnect RETURNS LOGICAL (
                                       input hInternetSession as integer
                                      ,input p-ftp-ip as character
                                      ,input p-ftp-login as character
                                      ,input p-ftp-password  as character
                                      ,input p-flags as integer
                                      ,output hFTPsession as integer
                                      ,output p-mes as character
                                      ):
define variable ierror as integer no-undo .
define variable v-mes1             as character no-undo .
define variable v-server as character no-undo .
define variable v-port as integer no-undo .
case num-entries(p-ftp-ip, ":"):
   when 1 then do:
     v-server = p-ftp-ip.
     v-port = 21.
   end.
   when 2 then do:
    if entry(1, p-ftp-ip, ":") = "ftp" then do:
      assign
      v-server = p-ftp-ip
      v-port = 21
      .
    end.
    else do:
      assign
      v-server = entry(1, p-ftp-ip, ":")
      v-port = integer(entry(2, p-ftp-ip, ":"))
      .
    end.
  end.
  when 3 then do:
    if entry(1, p-ftp-ip, ":") <> "ftp" then do:
    end.
    assign
    v-server = entry(2, p-ftp-ip, ":")
    v-port = integer(entry(3, p-ftp-ip, ":"))
    .
  end.
end case.
run InternetConnectA (
                      input  hInternetSession
                    , input  v-server
                    , input  v-port
                    , input  p-ftp-login
                    , input  p-ftp-password
                    , input  1
                    , input  p-flags
                    , input  0
                    , output hFTPSession).
IF hFTPSession = 0 then
do:
  run GetLastError (output iError).
  p-mes = substitute("Ошибка при FTP соединении: &1", ierror).
  assign
  v-mes1 = InternetGetLastResponseInfo( )
  no-error .
  if v-mes1 <> ?
  and v-mes1 <> ''
  then do:
    p-mes = substitute("&1&2&3", p-mes, chr(10), v-mes1).
  end.
  RETURN FALSE.
end.
RETURN TRUE.
END FUNCTION.
FUNCTION FTPListDir RETURNS INTEGER (
                                    INPUT cSearchDir      as character
                                    ,INPUT cSearchFileSpec as character
                                    ,INPUT hFTPSession     as integer
                                    ,INPUT cProgCallBack   as character
                                    ,INPUT hCallProc       as HANDLE
  ):
define variable lpFindData   as memptr    no-undo.
define variable hSearch      as integer   no-undo.
define variable iFound       as integer   no-undo initial 1.
define variable iFileSpec    as integer   no-undo.
define variable cFileList    as char      no-undo.
define variable iRetCode     as integer   no-undo.
assign
set-size(lpFindData) = 4                                 + 8                                 + 8                                 + 8                                 + 4                                 + 4                                 + 4                                 + 4                                 + 260                       + 14.
do iFileSpec = 1 to num-entries(cSearchFileSpec):
  iFound = 1.
  run FtpFindFirstFileA (input  hFtpSession,
                          input  cSearchDir + '/' +
                                entry(iFileSpec, cSearchFileSpec),
                          input  lpFindData,
                          input  536870912,
                          input  0,
                          output hSearch).
  if hSearch <> -1 then
  repeat while iFound <> 0:
    run value(cProgCallBack) in hCallProc
          (input lpFindData,
            input  cSearchDir).
    run InternetFindNextFileA (input  hSearch,
                                input  lpFindData,
                                output iFound).
  end.
  else
    iRetCode = 5.
end.
set-size(lpFindData) = 0.
run InternetCloseHandle (input hSearch, OUTPUT iRetCode).
return iRetCode.
END FUNCTION.
FUNCTION FtpGetFile RETURNS logical
  (
    input hFtpSession as integer
   ,input p-rfilename as character
   ,input p-lFilename as character
   ,output p-mes as character
  ) :
define variable lpRemoteFile   as  memptr  no-undo.
define variable lpNewFile      as  memptr  no-undo.
define variable fOverwirte     as  log     no-undo.
define variable iRetCode       as  integer no-undo.
define variable cRemoteFile    as  char    no-undo.
assign
set-size(lpRemoteFile)     = length(p-Rfilename) + 1
put-string(lpRemoteFile,1) = p-rfilename
set-size(lpNewFile)        = length(p-lfilename) + 1
put-string(lpNewFile,1)    = p-lfilename.
run FtpGetFileA(input hFtpSession,
                input get-pointer-value(lpRemoteFile),
                input get-pointer-value(lpNewFile),
                input 0,
                input 128,
                input 2,
                input 0,
                output iRetCode).
assign
set-size(lpRemoteFile)     = 0
set-size(lpNewFile)        = 0.
if iRetCode = 0 then do:
  p-mes = InternetGetLastResponseInfo().
  return no.
end.
else do:
  p-mes = ''.
  return yes.
end.
END FUNCTION.
FUNCTION FtpDeleteFile RETURNS LOGICAL (
                                           input hFtpSession as integer
                                          ,input p-rfilename as character
                                          ,output p-mes as character
                                         ) :
define variable lpRemoteFile   as  memptr  no-undo.
define variable iRetCode       as  integer no-undo.
define variable cRemoteFile    as  char    no-undo.
assign
set-size(lpRemoteFile)     = length(p-rfilename) + 1
put-string(lpRemoteFile,1) = p-rfilename.
run FtpDeleteFileA(input hFtpSession,
                    input get-pointer-value(lpRemoteFile),
                    output iRetCode).
assign
set-size(lpRemoteFile)     = 0.
if iRetCode = 0 then do:
  p-mes = InternetGetLastResponseInfo().
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION FtpPutFile RETURNS logical (
                                       input hFTPsession as integer
                                      ,input p-LFilename as character
                                      ,input p-rfilename as character
                                      ,output p-mes as character
                                      ) :
define variable lpLocalFile        as  memptr  no-undo.
define variable  lpNewRemoteFile    as  memptr  no-undo.
define variable  fOverwirte         as  log     no-undo.
define variable  iRetCode           as  integer no-undo.
assign
set-size(lpNewRemoteFile)     = length(p-RFilename) + 1
put-string(lpNewRemoteFile,1) = p-RFilename
set-size(lpLocalFile)         = length(p-LFilename) + 1
put-string(lpLocalFile,1)     = p-LFilename.
run FtpPutFileA(input hFtpSession,
                input get-pointer-value(lpLocalFile),
                input get-pointer-value(lpNewRemoteFile),
                input 2,
                input 0,
                output iRetCode).
assign
set-size(lpNewRemoteFile)     = 0
set-size(lpLocalFile)         = 0.
if iRetCode = 0 then do:
  p-mes = InternetGetLastResponseInfo().
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ftp-fl_CreateFileList :
define input parameter lpFindData   as  memptr no-undo.
define input parameter pcSearchDir  as  char   no-undo.
define variable iFileSize           as  integer no-undo.
define variable lResult             as  logical no-undo.
define variable v-file-name as character no-undo .
define buffer buf_temp-dirlist for temp-dirlist.
define buffer buf_temp-filelist for temp-filelist.
do
on error undo, return error
:
    if get-long(lpFindData, 1) = 16 then do:
    v-file-name = get-string(lpFindData,45).
    find first buf_temp-dirlist where
              buf_temp-dirlist.dir-full-name = pcSearchDir + chr(47) + v-file-name no-error.
    if not available buf_temp-dirlist then do:
      create buf_temp-dirlist.
      assign
      buf_temp-dirlist.dir-full-name = pcSearchDir + chr(47) + v-file-name
      buf_temp-dirlist.dir-short-name = v-file-name
      .
    end.
  end.
  else do:
    assign
    iFileSize = get-long(lpFindData,33)
    .
    v-file-name = get-string(lpFindData,45).
    if v-file-name <> '' then do:
      find first buf_temp-filelist where
                buf_temp-filelist.full-name = pcSearchDir + chr(47) + v-file-name no-error.
      if not available buf_temp-filelist then do:
        create buf_temp-filelist.
        assign
        buf_temp-filelist.full-name = pcSearchDir + chr(47) + v-file-name
        buf_temp-filelist.directory-name = pcSearchDir
        buf_temp-filelist.file-name = v-file-name
        .
      end.
    end.
  end.
end.
end procedure.
define variable hInternetSession   as  integer  no-undo.
define variable hFTPSession        as  integer  no-undo.
define variable cCurrentDir        as  character no-undo.
define variable log-file-name as character no-undo .
define variable p-ftp-ip as character no-undo .
define variable p-ftp-login as character no-undo .
define variable p-ftp-password as character no-undo .
define variable p-rdir as character no-undo .
define variable p-flags as integer no-undo .
define variable v-mes as character no-undo .
define variable v-cb-proc as character no-undo .
define buffer buf_temp-filelist for temp-filelist.
do
on error undo, return error
:
    if num-entries(p-parameter, chr(4) ) <> 7 then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("&1 &2 &3 Неверно переданы параметры"                                   ,vss-workfile                                    ,vss-revision                                    ,vss-description)).
      undo, return error ''.
    end.
    assign
    p-ftp-ip = entry(1, p-parameter, chr(4))
    p-ftp-login = entry(2, p-parameter, chr(4))
    p-ftp-password = entry(3, p-parameter, chr(4))
    p-flags =  integer(entry(4, p-parameter, chr(4)))
    p-rdir = entry(5, p-parameter, chr(4))
    v-cb-proc = entry(6, p-parameter, chr(4))
    log-file-name = entry(7, p-parameter, chr(4))
    .
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Соединяюсь с &1... ", p-ftp-ip)).
    if not ConnectWinInet ( output hInternetSession  ) then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не могу установить соединение с &1", p-ftp-ip)).
      undo,  return error ''.
    end.
    else  do:
      if FTPConnect ( input hInternetSession
                     ,input p-ftp-ip
                     ,input p-ftp-login
                     ,input p-ftp-password
                     ,input p-flags
                     ,output hFTPsession
                     ,output v-mes
                     )
      then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Получаю список файлов в директории  &1 ", p-rdir)).
        FTPListDir (
                   INPUT (if p-rdir > '' then p-rdir else '.')
                 , INPUT '*.*'
                 , INPUT hFTPSession
                 , INPUT (if v-cb-proc > '' then v-cb-proc else 'ftp-fl_CreateFileList')
                 , INPUT (if v-cb-proc > ''
                          then p-parent-handle
                          else THIS-PROCEDURE)
                   ).
      end.
      else do:
        CloseInternetConnection(hInternetSession).
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-mes).
        undo, return error ''.
      end.
      CloseInternetConnection(hInternetSession).
    end.
    if v-cb-proc  = '' then do:
      for each buf_temp-filelist:
        message
        buf_temp-filelist.full-name
        view-as alert-box .
      end.
   end.
end.
