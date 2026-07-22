block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndpckp.p $
$Archive: nws/sndpckp.p $

Подготовка пакета обновлений

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/06
Author: Bakhtadze Natalya
Creation date: 08/06/06

*/

define input parameter p-manifest-file as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndpckp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/sndpckp.p $":U .
define variable vss-description as character no-undo init "Подготовка пакета обновлений".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ adm/ipck-mf.i "shared" }

/*ищем файл манифеста*/

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE v-md5-signature AS CHARACTER NO-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .



define stream Instream.

DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.

do
on error undo, return error return-value
:

  run gbl/filename.p (
                  input  p-manifest-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error  = ? then do:
    undo, return error return-value .
  end.

  run ipck-mf-process-manifest-file in this-procedure ( input p-manifest-file
                                               ,input "send" ) no-error.
  /*имя файл манифеста должно быть именем обновления*/
  /*на выходе должна быть временная таблица*/
  /*в моде send в содержимом таблицы должны быть файлы которые ПЕРЕСЫЛАЕМ - а не файлы самого пакета*/
  /*пересылать можем архив или diff*/
  /*олжна быть и запись для файла манифеста*/
  /*теперь сравним ее с содержимым директории*/
  for each buf_tt-ext-file no-lock
  on error undo, return error
  :
    file-info:file-name = v-path + {&slash-char} + buf_tt-ext-file.file-name.
    if FILE-INFO:FULL-PATHNAME = ? then do:
      /**/
      run clear-temp-table in this-procedure .
      return error substitute("Отсутствует файл &1", buf_tt-ext-file.file-name).
    end.

        run gbl/md5.p (
      input  v-full-path
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if
    not
    (
    buf_tt-ext-file.create-sys-date      = file-info:FILE-CREATE-DATE
    AND
    buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-create-TIME, "HH:MM:SS")
    AND
    buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-create-TIME
    AND
    buf_tt-ext-file.update-sys-date      = file-info:FILE-MOD-DATE
    AND
    buf_tt-ext-file.update-sys-time      = STRING(file-info:FILE-MOD-TIME, "HH:MM:SS")
    AND
    buf_tt-ext-file.update-sys-time-INT  = file-info:FILE-MOD-TIME
    AND
    buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
    AND
    buf_tt-ext-file.crc-field            = v-md5-signature
    and
    buF_tt-ext-file.file-name <> buf_tt-ext-file.file-type
    ) then do:
      run clear-temp-table in this-procedure .
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_tt-ext-file.file-name).
    end.
    if buF_tt-ext-file.file-name <> buf_tt-ext-file.file-type
    and not (
              buf_tt-ext-file.create-sys-date      = file-info:FILE-MOD-DATE
              AND
              buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
              AND
              buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
              AND
              buf_tt-ext-file.update-sys-date      = file-info:FILE-MOD-DATE
              AND
              buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
              AND
              buf_tt-ext-file.crc-field            = v-md5-signature
           )
    then do:
      run clear-temp-table in this-procedure .
      return error substitute("Файл &1 не соответствует описанию в манифесте", buf_tt-ext-file.file-name).
    end.
    if buF_tt-ext-file.file-name = buf_tt-ext-file.file-type /*это манифест*/  then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      buf_tt-ext-file.update-sys-date = v-today
      buf_tt-ext-file.update-sys-time = string(v-time,  "HH:MM:SS")
      buf_tt-ext-file.update-sys-time-int = v-time
      buf_tt-ext-file.update-user-name = g#userid.
      buf_tt-ext-file.status_ = {&auto}
      .
    end.
  end.
end. /*doe*/

procedure clear-temp-table :
define buffer buf_tt-ext-file for tt-ext-file.

  do
  on error undo, return error return-value
  :

     for each buf_tt-ext-file :
       delete buf_tt-ext-file.
     end.

  end.

end procedure. /* clear temp-table. */