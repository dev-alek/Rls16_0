/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение данных для пересылки bin

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/26/09
Author: Bakhtadze Natalya
Creation date: 06/26/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/fileslsh.i }
{ gbl/cur-time.i }

procedure bintrn_create-file-record :
define input parameter p-path as character no-undo .
define input parameter p-file-type as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-full-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE v-md5-signature AS CHARACTER NO-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-full-path2        as character no-undo .
define buffer buf_tt-ext-file for tt-ext-file.

do
on error undo, return error
:
  run gbl/filename.p (
                  input  p-path
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .

  if error-status:error  = yes then do:
    undo, return  substitute("Ошибка при поиске файла &1:&2&3&2&4"
                              , p-path
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
  end.
  assign
  v-full-path = prepare-path(v-full-path).
  v-full-path2 = prepare-path2(v-full-path).
  define variable v-unc as character no-undo .
  run gbl/get-unc.p ( input v-full-path2, output v-unc) no-error.
  if not error-status :error then do:
    assign
    v-full-path2 = v-unc.
  end.


  file-info:FILE-NAME = v-full-path.
  run gbl/md5.p (
      input  v-full-path
    ,output v-md5-signature /* p-md5-signature */
    ) no-error.
  if error-status:error then do:
    undo, return substitute("Ошибка при выполнении подсчета КС файла &1&2" +
                "&3&2&4"
                , v-full-path
                , {&new-line}
                , error-status:get-message(1)
                , return-value ).
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_tt-ext-file.
  ASSIGN
  buf_tt-ext-file.FILE-NAME = v-full-path
  buf_tt-ext-file.FILE-NAME-exec = v-full-path2
  buf_tt-ext-file.file-num = 1 /*потом само перепишется*/
  buf_tt-ext-file.create-sys-date      = file-info:FILE-mod-DATE
  buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
  buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
  buf_tt-ext-file.update-sys-date      = v-today
  buf_tt-ext-file.update-sys-time      = STRING(v-time, "HH:MM:SS")
  buf_tt-ext-file.update-sys-time-INT  = v-time
  buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
  buf_tt-ext-file.crc-field            = v-md5-signature
  buf_tt-ext-file.file-type            = p-file-type
  .
  release buf_tt-ext-file.
  p-full-name = v-full-path.
end.

end procedure. /* bintrn */


/* $Workfile$ e n d */