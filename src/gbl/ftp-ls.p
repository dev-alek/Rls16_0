block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ftp-ls.p $
$Archive: gbl/ftp-ls.p $

Получение списка файлов с FTP

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/21/08
Author: Bakhtadze Natalya
Creation date: 10/21/08

*/

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
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/filelist.i }
{ gbl/ftp-df.i }
{ gbl/ftp-pdf.i }
{ gbl/ftp-fl.i }

/* handle to internet session */
define variable hInternetSession   as  integer  no-undo.
/* handle to the ftp session inside the internet connection */
define variable hFTPSession        as  integer  no-undo.
/* current directory which we are processing */
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

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


do
on error undo, return error
:
   /*todo проверка параметров*/
    if num-entries(p-parameter, {&delim-par} ) <> 7 then do:
      &scop my-message substitute("&1 &2 &3 Неверно переданы параметры" ~
                                  ,vss-workfile  ~
                                  ,vss-revision  ~
                                  ,vss-description)
      {&display-message}.
      undo, return error ''.
    end.
    assign
    p-ftp-ip = entry(1, p-parameter, {&delim-par})
    p-ftp-login = entry(2, p-parameter, {&delim-par})
    p-ftp-password = entry(3, p-parameter, {&delim-par})
    p-flags =  integer(entry(4, p-parameter, {&delim-par}))
    p-rdir = entry(5, p-parameter, {&delim-par})
    v-cb-proc = entry(6, p-parameter, {&delim-par})
    log-file-name = entry(7, p-parameter, {&delim-par})
    .
    &scop my-message substitute("Соединяюсь с &1... ", p-ftp-ip)
    {&display-message}.
    if not ConnectWinInet ( output hInternetSession  ) then do:
      &scop my-message substitute("Не могу установить соединение с &1", p-ftp-ip)
      {&display-message}.
      undo,  return error ''.
    end.
    else  do:
      /*-----------------------------------------------------------------------
        Start and FTP Sesion.
      ------------------------------------------------------------------------*/
      if FTPConnect ( input hInternetSession
                     ,input p-ftp-ip
                     ,input p-ftp-login
                     ,input p-ftp-password
                     ,input p-flags
                     ,output hFTPsession
                     ,output v-mes
                     )
      then do:
        /*-----------------------------------------------------------------------
         If hFTPSession is a valid handle, then read the contents of the FTP
         site.
        ------------------------------------------------------------------------*/
        &scop my-message substitute("Получаю список файлов в директории  &1 ", p-rdir)
        {&display-message}.
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
        &scop my-message v-mes
        {&display-message}.
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
end. /*doe*/
