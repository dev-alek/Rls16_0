block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита импорта конфигурации настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/07
Author: Bakhtadze Natalya
Creation date: 09/04/07

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита импорта конфигурации настраиваемых полей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cstmlabs.i }
{ gbl/waitfram.i }
define stream imp-stream.
{ utl/upgimptt.i def "new shared" }

define variable v-check as logical no-undo .

define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .

&global-define shared-option new shared

&global-define table-name custom-labels
{&create-static-table}.


define buffer buf_tt-custom-labels for tt-custom-labels.


run waitfram-show in this-procedure ("Реинициализация конфигурации настраиваемых полей").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-cl-version in this-procedure (output v-check).
  end.
  if v-check
  or p-forced
  then do:
    if v-check
    and p-read-only then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}).
    end.
    run gbl/md5.p (
       input  "cmp/fixcstml.txt"     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> "{&cl-md5}" then do:
      message
      substitute("Несовпадение файла эталонных записей по настраиваемым полям (fixcstml.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixcstml.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по настраиваемым полям (fixcstml.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ? /*parparentproc*/
        ,input this-procedure
        ,input ('utl/upgimptt.p' + {&delim-par}  +
                '1' + {&delim-par} +
                '1' + {&delim-par} +
                '1' + {&delim-par} +
                '1')
        ,input v-full-path
        ,input yes /*p-auto-go*/
        ,input 'Прервать'
        ,input 'Чтение файла в память') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении в память файла кофигурации настраиваемых полей (fixcstml.txt)&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check
    or p-forced
    then do:
      find first buf_tt-custom-labels no-lock where
                buf_tt-custom-labels.tbl-name = '':U
            and buf_tt-custom-labels.fld-name = '':U
            and buf_tt-custom-labels.call-type = '':U
            and buf_tt-custom-labels.call-point = '':U  no-error.
      if not available buf_tt-custom-labels
      or buf_tt-custom-labels.custom-tooltip <> {&cl-revision} then do:
        message
        substitute("Версии конфиг. настраив полей в r-кодах и файле конфигурации (fixcmstl.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , {&new-line}
                   , {&cl-revision}
                   , buf_tt-custom-labels.custom-tooltip
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-custom-labels in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации конфигурации настраиваемых полей:&1&2 &3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
  end.
  for each buf_temp-tables
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-tables.tbl-handle) then do:
      delete object buf_temp-tables.tbl-handle.
     end.
  end.
end. /*doe*/

run waitfram-hide in this-procedure .


procedure add-custom-labels :
/*добавление конфигурации настриваемых полей*/
define variable v-cmp as logical no-undo .
define variable v-error as logical no-undo .
define buffer buf_tt-custom-labels for tt-custom-labels.
define buffer buf2_tt-custom-labels for tt-custom-labels.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf2_custom-labels for ub.custom-labels.

main-block:
do
on error undo, return error
:
  _for:
  for each buf_tt-custom-labels
  where buf_tt-custom-labels.language > '':U
  break
  by buf_tt-custom-labels.language
  by buf_tt-custom-labels.call-type
  by buf_tt-custom-labels.call-point
  on error  undo _for, retry _for
  on stop   undo _for, retry _for
  on endkey undo _for, retry _for
  :
    if retry then do:
      v-error = yes.
      leave _for.
    end.
    if first-of(buf_tt-custom-labels.call-point) then do:
      for each buf2_tt-custom-labels where
              buf2_tt-custom-labels.language = buf_tt-custom-labels.language
          and buf2_tt-custom-labels.call-type = buf_tt-custom-labels.call-type
          and buf2_tt-custom-labels.call-point = buf_tt-custom-labels.call-point
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        find first buf_custom-labels exclusive-lock where
                  buf_custom-labels.language = buf2_tt-custom-labels.language
              and buf_custom-labels.call-type = buf2_tt-custom-labels.call-type
              and buf_custom-labels.call-point = buf2_tt-custom-labels.call-point
              and buf_custom-labels.tbl-name = buf2_tt-custom-labels.tbl-name
              and buf_custom-labels.fld-name = buf2_tt-custom-labels.fld-name no-error.
        v-cmp = yes.
        if not available buf_custom-labels then do:
          create buf_custom-labels.
          v-cmp = no.
        end.
        else do:
          buffer-compare
          buf_custom-labels to buf2_tt-custom-labels
          case-sensitive
          save result in v-cmp.
        end.
        if not v-cmp then do:
          buffer-copy buf2_tt-custom-labels to buf_custom-labels.
        end.
      end. /*      for each buf2_tt-custom-labels where*/
    end. /*if first-of(buf_tt-custom-labels.call-point) then do:*/
  end. /*    for each buf_tt-dis-rule where*/
  if not v-error  then do:
    _for2:
    for each buf_custom-labels no-lock
    on error  undo _for2, retry _for2
    on stop   undo _for2, retry _for2
    on endkey undo _for2, retry _for2
    :
      if retry then do:
        v-error = yes.
        leave _for2.
      end.
      find first buf2_tt-custom-labels where
                buf2_tt-custom-labels.language = buf_custom-labels.language
            and buf2_tt-custom-labels.call-type = buf_custom-labels.call-type
            and buf2_tt-custom-labels.call-point = buf_custom-labels.call-point
            and buf2_tt-custom-labels.tbl-name = buf_custom-labels.tbl-name
            and buf2_tt-custom-labels.fld-name = buf_custom-labels.fld-name no-error.
      if not available buf2_tt-custom-labels then do:
        find first buf2_custom-labels exclusive-lock where
                  recid(buf2_custom-labels) = recid(buf_custom-labels).
        delete buf2_custom-labels.
      end.
    end.
  end.
  if not v-error then do:
    find first buf_tt-custom-labels where
              buf_tt-custom-labels.language = '':U
          and buf_tt-custom-labels.call-type = '':U
          and buf_tt-custom-labels.call-point = '':U
          and buf_tt-custom-labels.tbl-name = '':U
          and buf_tt-custom-labels.fld-name = '':U no-error .
    find first buf_custom-labels where
              buf_custom-labels.language = '':U
          and buf_custom-labels.call-type = '':U
          and buf_custom-labels.call-point = '':U
          and buf_custom-labels.tbl-name = '':U
          and buf_custom-labels.fld-name = '':U no-error.
    if not available buf_custom-labels then do:
      create buf_custom-labels.
    end.
    buffer-copy buf_tt-custom-labels to buf_custom-labels.
    release buf_tt-custom-labels no-error .
    if error-status:error then do:
      return error substitute("Ошибка при обновлении головной записи конфигурации настраиваемых полей &1&2&3"
                              , error-status:get-message(1)
                              , return-value ).
    end.
  end.
  else do:
     return error substitute("Ошибка при обновлении конфигурации настраиваемых полей &1&2&3"
                             , error-status:get-message(1)
                             , return-value ).
  end.
end. /*doe*/

end procedure. /* add-custom-labels */