/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с манифестом пракета обновлений

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/06
Author: Bakhtadze Natalya
Creation date: 08/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table tt-ext-file no-undo like ub.ext-file.
{ gbl/cur-time.i }

procedure ipck-mf-process-manifest-file :
define input parameter p-manifest-file  as character no-undo .
define input parameter p-action as character no-undo .

  do
  on error undo, return error
  :

    /*имя файл манифеста должно быть именем обновления*/
    /*на выходе должна быть временная таблица*/
    /*в моде send в содержимом таблицы должны быть файлы которые ПЕРЕСЫЛАЕМ - а не файлы самого пакета*/
    /*пересылать можем архив или diff*/
    /*олжна быть и запись для файла манифеста*/

  end.

end procedure. /* ipck-mf-process-manifest-file */



procedure ipck-mf-check-ipck :
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-manifest-file as character no-undo .

define variable v-md5-signature as character no-undo .
define variable v-path as character no-undo .
define variable v-full-path as character no-undo .

define buffer buf_Ext-file for ub.ext-file.



  do
  on error undo, return error return-value
  :

  for each buf_ext-file no-lock where
         buf_Ext-file.db-num = p-db-num
     and buf_Ext-file.from-db-num = p-from-db-num
     and  buf_Ext-file.file-type = p-manifest-file
  on error undo, return error
  :
    file-info:file-name = v-path + {&slash-char} + buf_ext-file.file-name.
    if FILE-INFO:FULL-PATHNAME = ? then do:
      return error substitute("Отсутствует файл &1", buf_ext-file.file-name).
    end.
        run gbl/md5.p (
       input  v-full-path
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if
    not
    (
    buf_ext-file.create-sys-date      = file-info:FILE-CREATE-DATE
    AND
    buf_ext-file.create-sys-time      = STRING(file-info:FILE-create-TIME, "HH:MM:SS")
    AND
    buf_ext-file.create-sys-time-INT  = file-info:FILE-create-TIME
    AND
    buf_ext-file.update-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.update-sys-time      = STRING(file-info:FILE-MOD-TIME, "HH:MM:SS")
    AND
    buf_ext-file.update-sys-time-INT  = file-info:FILE-MOD-TIME
    AND
    buf_ext-file.file-size            = FILE-INFO:FILE-SIZE
    AND
    buf_ext-file.crc-field            = v-md5-signature
    )
    then do:
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_ext-file.file-name).
    end.
    if
    not
    (
    buf_ext-file.create-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
    AND
    buf_ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
    AND
    buf_ext-file.update-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_ext-file.file-size            = FILE-INFO:FILE-SIZE
    AND
    buf_ext-file.crc-field            = v-md5-signature
    and
    buF_ext-file.file-name = buf_ext-file.file-type
    ) then do:
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_ext-file.file-name).
    end.
  end.
  end. /*doe*/

end procedure. /* ipck-mf-check-ipck */


/* $Workfile$ e n d */