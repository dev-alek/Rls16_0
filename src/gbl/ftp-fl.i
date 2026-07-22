/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/21/08
Author: Bakhtadze Natalya
Creation date: 10/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure ftp-fl_CreateFileList :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:       iFileSize should be converted to a decimal so that it can
              support very large file sizes.  Currently we are only looking
              at the low value and not taking the high value into
              consideration.
------------------------------------------------------------------------------*/
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
              buf_temp-dirlist.dir-full-name = pcSearchDir + {&slash-char} + v-file-name no-error.
    if not available buf_temp-dirlist then do:
      create buf_temp-dirlist.
      assign
      buf_temp-dirlist.dir-full-name = pcSearchDir + {&slash-char} + v-file-name
      buf_temp-dirlist.dir-short-name = v-file-name
      .
    end.
  end.
  else do:
    assign
    iFileSize = get-long(lpFindData,33)  /* nFileSizeLow */
    .
    v-file-name = get-string(lpFindData,45).
    if v-file-name <> '' then do:
      find first buf_temp-filelist where
                buf_temp-filelist.full-name = pcSearchDir + {&slash-char} + v-file-name no-error.
      if not available buf_temp-filelist then do:
        create buf_temp-filelist.
        assign
        buf_temp-filelist.full-name = pcSearchDir + {&slash-char} + v-file-name
        buf_temp-filelist.directory-name = pcSearchDir
        buf_temp-filelist.file-name = v-file-name
        .
      end.
    end.
  end.
end.
end procedure. /* CreateFileList */


/* $Workfile$ e n d */