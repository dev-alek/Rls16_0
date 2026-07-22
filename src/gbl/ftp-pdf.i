/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции для работы FTP

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/21/08
Author: Bakhtadze Natalya
Creation date: 10/21/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


FUNCTION ConnectWinInet RETURNS LOGICAL (
                                           output hInternetSession as integer
                                        ) :
/*------------------------------------------------------------------------------
  Purpose:  connect to specified website and exchange information.
    Notes:
------------------------------------------------------------------------------*/

  /*--------------------------------------------------------------------------
    Call to establish an Internet session.  The handle, hInternetSession,
    will be used when connecting to the URL.
  ---------------------------------------------------------------------------*/
  run InternetOpenA(input  'WebBasedAgent',
                    input  {&INTERNET_OPEN_TYPE_PRECONFIG},
                    input  '',
                    input  '',
                    input  0,
                    output hInternetSession).

  RETURN hInternetSession <> 0. /* Function return value. */

END FUNCTION.


FUNCTION CloseInternetConnection rETURNS LOGICAL  (
                                                 input phInternetSession as integer
                                                 ) :
/*------------------------------------------------------------------------------
  Purpose:  Close the handle the InternetSession.  Since all other handles are
            leafs of this handle, the will also be closed when the root is
            closed. (i.e. hFTPSession. )

    Notes:
------------------------------------------------------------------------------*/
define variable iRetCode      as  integer no-undo.

run InternetCloseHandle(input  phInternetSession,
                        output iRetCode).


RETURN iRetCode > 0.   /* Function return value. */

END FUNCTION.


FUNCTION InternetGetLastResponseInfo RETURNS CHARACTER ( ) :
/*------------------------------------------------------------------------------
  Purpose:  If an error is encountered then display what the last response
            was.
    Notes:
------------------------------------------------------------------------------*/
define variable cBuffer            as  character no-undo.
define variable iBufferSz          as  integer init 4096 no-undo.
define variable iResultCode        as  integer no-undo.
define variable iTemp              as  integer no-undo.

/* allocate for the buffer */
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
     v-port = {&INTERNET_DEFAULT_FTP_PORT}.
   end.
   when 2 then do:
    if entry(1, p-ftp-ip, ":") = "ftp" then do:
      assign
      v-server = p-ftp-ip
      v-port = {&INTERNET_DEFAULT_FTP_PORT}
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
                    , input  {&INTERNET_SERVICE_FTP}
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
    p-mes = substitute("&1&2&3", p-mes, {&new-line}, v-mes1).
  end.
  RETURN FALSE.
end.
RETURN TRUE.   /* Function return value. */
END FUNCTION.


FUNCTION FTPListDir RETURNS INTEGER (
                                    INPUT cSearchDir      as character
                                    ,INPUT cSearchFileSpec as character
                                    ,INPUT hFTPSession     as integer
                                    ,INPUT cProgCallBack   as character
                                    ,INPUT hCallProc       as HANDLE
  ):
/*------------------------------------------------------------------------

  Function:    DirList

  Description: Returns integer corresponding to the error:
                   0 - if there were no errors.
                   1 - file list buffer is too small
                   2 - file list buffer is too big
                   3 - invalid path given
                   5 - directory on drive is invaild


               cSearchDir:
                 Directory to search in, can be relative, use /../../, etc.

               cSearchFileSpec:
                 comma delimited list of file types, can have trailing
                 comma e.g: " foo?ar.*  ,  *.p, "

               hFTPSession - handle to an open ftp session.

               cProgCallBack:
                 Program to be called if a file is found passing in
                 to input parameters, the directory being searched,
                 and the filename found.

               hCallProc
                 Handle to the calling program where call back process
                 is to execute.

  Notes:       FtpFindFirstFile can only occur once within a given FTP
               session.  To issue another one, a call must be made
               InternetCloseHandle.

  History:

------------------------------------------------------------------------*/
define variable lpFindData   as memptr    no-undo.
define variable hSearch      as integer   no-undo.
define variable iFound       as integer   no-undo initial 1.
define variable iFileSpec    as integer   no-undo.
define variable cFileList    as char      no-undo.
define variable iRetCode     as integer   no-undo.

&SCOPE  FIND_DATA-SIZE 4           /* dwFileAttributes       */~
                      + 8           /* ftCreationTime         */~
                      + 8           /* ftLastAccessTime       */~
                      + 8           /* ftLastWriteTime        */~
                      + 4           /* nFileSizeHigh          */~
                      + 4           /* nFileSizeLow           */~
                      + 4           /* dwReserved0            */~
                      + 4           /* dwReserved1            */~
                      + {&MAX_PATH} /* cFileName[MAX_PATH]    */~
                      + 14          /* cAlternateFileName[14] */

/* allocate the memory for the find_data structure */
assign
set-size(lpFindData) = {&FIND_DATA-SIZE}.

do iFileSpec = 1 to num-entries(cSearchFileSpec):

  iFound = 1.
  run FtpFindFirstFileA (input  hFtpSession,
                          input  cSearchDir + '/' +
                                entry(iFileSpec, cSearchFileSpec),
                          input  lpFindData,
                          input  {&INTERNET_FLAG_EXISITING_CONNECT},
                          input  0,
                          output hSearch).

  if hSearch <> -1 then
  repeat while iFound <> 0:

    run value(cProgCallBack) in hCallProc
          (input lpFindData,
            input  cSearchDir).                 /* current directory */

    run InternetFindNextFileA (input  hSearch,
                                input  lpFindData,
                                output iFound).

  end. /* repeat while ifound <> 0... */

  /* set error for invalid file specification */
  else
    iRetCode = 5.

end. /* do iFileSpec = 1 to ... */

set-size(lpFindData) = 0.

/* close file handle now so we can do a find again */
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
/*------------------------------------------------------------------------------
  Purpose:  Retrieves a file from the FTP Server and stores it under the
            specified file name, creating a new local file in the process.
    Notes:
------------------------------------------------------------------------------*/

define variable lpRemoteFile   as  memptr  no-undo.
define variable lpNewFile      as  memptr  no-undo.
define variable fOverwirte     as  log     no-undo.
define variable iRetCode       as  integer no-undo.
define variable cRemoteFile    as  char    no-undo.

assign
/* remove the file size from the file name */
set-size(lpRemoteFile)     = length(p-Rfilename) + 1
put-string(lpRemoteFile,1) = p-rfilename
set-size(lpNewFile)        = length(p-lfilename) + 1
put-string(lpNewFile,1)    = p-lfilename.

run FtpGetFileA(input hFtpSession,
                input get-pointer-value(lpRemoteFile),
                input get-pointer-value(lpNewFile),
                input 0, /* 1 - fail if file exists, 0 - overwrite */
                input {&FILE_ATTRIBUTE_NORMAL},
                input {&FTP_TRANSFER_TYPE_BINARY},
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
/*------------------------------------------------------------------------------
  Purpose:  Deletes a file from the FTP Server if you have permissions.
    Notes:
------------------------------------------------------------------------------*/

define variable lpRemoteFile   as  memptr  no-undo.
define variable iRetCode       as  integer no-undo.
define variable cRemoteFile    as  char    no-undo.

assign
/* remove the file size from the file name */
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
/*------------------------------------------------------------------------------
  Purpose:  Sends a file to the FTP Server and stores it under the
            specified file name, creating a new remote file in the process
            if you have the appropriate permissions.  If not you will be told
            so via InternetGetLastResponse.
    Notes:
------------------------------------------------------------------------------*/

define variable lpLocalFile        as  memptr  no-undo.
define variable  lpNewRemoteFile    as  memptr  no-undo.
define variable  fOverwirte         as  log     no-undo.
define variable  iRetCode           as  integer no-undo.

assign
/* remove the file size from the file name */
set-size(lpNewRemoteFile)     = length(p-RFilename) + 1
put-string(lpNewRemoteFile,1) = p-RFilename
set-size(lpLocalFile)         = length(p-LFilename) + 1
put-string(lpLocalFile,1)     = p-LFilename.

run FtpPutFileA(input hFtpSession,
                input get-pointer-value(lpLocalFile),
                input get-pointer-value(lpNewRemoteFile),
                input {&FTP_TRANSFER_TYPE_BINARY},
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


