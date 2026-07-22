block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита импорта конфигурации атрибутов

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
define variable vss-description as character no-undo init "Утилита импорта конфигурации атрибутов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/attrprps.i }
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

&global-define table-name attr-prop
{&create-static-table}.


define buffer buf_tt-attr-prop for tt-attr-prop.


run waitfram-show in this-procedure ("Реинициализация конфигурации атрибутов").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-ap-version in this-procedure (output v-check).
  end.
  if v-check
  or p-forced
  then do:
    if v-check
    and p-read-only
    then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}).

    end.
    run gbl/md5.p (
       input  "cmp/fixattrp.txt"     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .
    if v-md5-signature <> "{&ap-md5}" then do:
      message
      substitute("Несовпадение файла эталонных записей по конфиг. атрибутов (fixattrp.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixattrp.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по конфиг. атрибутов (fixattrp.txt)")
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
      substitute("Ошибка при чтении в память файла кофигурации атрибутов (fixattrp.txt)&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check
    or p-forced
    then do:
      find first buf_tt-attr-prop no-lock where
                buf_tt-attr-prop.table-name = '':U
            and buf_tt-attr-prop.templ-rl-root = 0
            and buf_tt-attr-prop.node-code = 0 no-error.
      if not available buf_tt-attr-prop
      or buf_tt-attr-prop.property-value <> {&ap-revision} then do:
        message
        substitute("Версии конфиг. атрибутов в r-кодах и файле конфигурации (fixattrp.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , {&new-line}
                   , {&ap-revision}
                   , buf_tt-attr-prop.property-value
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-attr-prop in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации конфигурации атрибутов:&1&2 &3"
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


procedure add-attr-prop :
/*добавление конфигурации настриваемых полей*/
define variable v-cmp as logical no-undo .
define variable v-error as logical no-undo .
define buffer buf_tt-attr-prop for tt-attr-prop.
define buffer buf2_tt-attr-prop for tt-attr-prop.
define buffer buf_attr-prop for ub.attr-prop.
define buffer buf2_attr-prop for ub.attr-prop.

main-block:
do
on error undo, return error
:
  _for:
  for each buf_tt-attr-prop
  where buf_tt-attr-prop.table-name > '':U
  break
  by buf_tt-attr-prop.table-name
  by buf_tt-attr-prop.templ-rl-root
  by buf_tt-attr-prop.node-code
  on error  undo _for, retry _for
  on stop   undo _for, retry _for
  on endkey undo _for, retry _for
  :
    if retry then do:
      v-error = yes.
      leave _for.
    end.
    if first-of(buf_tt-attr-prop.templ-rl-root) then do:
      for each buf2_tt-attr-prop where
              buf2_tt-attr-prop.table-name = buf_tt-attr-prop.table-name
          and buf2_tt-attr-prop.templ-rl-root = buf_tt-attr-prop.templ-rl-root
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        find first buf_attr-prop exclusive-lock where
                  buf_attr-prop.table-name = buf2_tt-attr-prop.table-name
              and buf_attr-prop.templ-rl-root = buf2_tt-attr-prop.templ-rl-root
              and buf_attr-prop.node-code = buf2_tt-attr-prop.node-code    no-error.
        v-cmp = yes.
        if not available buf_attr-prop then do:
          create buf_attr-prop.
          v-cmp = no.
        end.
        else do:
          buffer-compare buf_attr-prop to buf2_tt-attr-prop
          case-sensitive
          save result in v-cmp.
        end.
        if not v-cmp then do:
          buffer-copy buf2_tt-attr-prop to buf_attr-prop.
        end.
      end. /*      for each buf2_tt-attr-prop where*/
    end. /*if first-of(buf_tt-attr-prop.call-point) then do:*/
  end. /*    for each buf_tt-dis-rule where*/
  if not v-error  then do:
    _for2:
    for each buf_attr-prop no-lock
    on error  undo _for2, retry _for2
    on stop   undo _for2, retry _for2
    on endkey undo _for2, retry _for2
    :
      if retry then do:
        v-error = yes.
        leave _for2.
      end.
      find first buf2_tt-attr-prop where
                buf2_tt-attr-prop.table-name = buf_attr-prop.table-name
            and buf2_tt-attr-prop.templ-rl-root = buf_attr-prop.templ-rl-root
            and buf2_tt-attr-prop.node-code = buf_attr-prop.node-code no-error.
      if not available buf2_tt-attr-prop then do:
        find first buf2_attr-prop exclusive-lock where
                  recid(buf2_attr-prop) = recid(buf_attr-prop).
        delete buf2_attr-prop.
      end.
    end.
  end.
  if not v-error then do:
    find first buf_tt-attr-prop where
              buf_tt-attr-prop.table-name = '':U
          and buf_tt-attr-prop.templ-rl-root = 0
          and buf_tt-attr-prop.node-code = 0 no-error .
    find first buf_attr-prop where
              buf_attr-prop.table-name = '':U
          and buf_attr-prop.templ-rl-root = 0
          and buf_attr-prop.node-code = 0  no-error.
    if not available buf_attr-prop then do:
      create buf_attr-prop.
    end.
    if buf_attr-prop.property-value <> buf_tt-attr-prop.property-value then do:
      buffer-copy buf_tt-attr-prop to buf_attr-prop.
      release buf_tt-attr-prop no-error .
      if error-status:error then do:
        return error substitute("Ошибка при обновлении головной записи конфигурации атрибутов &1&2&3"
                                , error-status:get-message(1)
                                , return-value ).
      end.
    end.
  end.
  else do:
     return error substitute("Ошибка при обновлении конфигурации атрибутов &1&2&3"
                             , error-status:get-message(1)
                             , return-value ).
  end.
end. /*doe*/

end procedure. /* add-attr-prop */