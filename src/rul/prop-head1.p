block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение prop-head

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-prop-name as character no-undo .
define input parameter        p-prop-label as character no-undo .
define input parameter        p-prop-des as character no-undo .
define input parameter        p-ref-type as character no-undo .
define input parameter        p-storage-place as character no-undo .
define input parameter        p-storage-place-host as character no-undo .
define input parameter        p-storage-place-obj as character no-undo .
define input parameter        p-hist-from-prim as integer no-undo .
define input parameter        p-hist-to-nws as integer no-undo .
define input parameter        p-get-hist-from-nws as integer no-undo .
define input parameter        p-nws-to-hist as integer no-undo .
define input parameter        p-smart-nws as integer no-undo .
define input parameter        p-nws-to-cd as integer no-undo .
define input parameter        p-general as character no-undo .
define input parameter        p-general-view as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-head".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf2_prop-head for ub.prop-head.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_prop-head
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-dtm-code = 0 then do:
    assign
    v-mess = "Код объекта-операнда не может = 0".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if p-prop-name = '':u then do:
    assign
    v-mess = "Имя объекта-операнда не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'prop-name':U).
  end.
  if p-prop-label = '':u then do:
    assign
    v-mess = "Лейбл объекта-операнда не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'prop-label':U).
  end.
  if p-storage-place <> {&question-mark}
  and p-storage-place <> '':U then do:
    find first _file no-lock where
              _file._file-name = p-storage-place
          and _file._hidden = no no-error.
    if not available _file then do:
      assign
      v-mess = "Неверно определено место хранения данных (глоб)".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'storage-place':U).
    end.
  end.
  if p-storage-place-host <> {&question-mark}
  and p-storage-place-host <> '':U then do:
    find first _file no-lock where
              _file._file-name = p-storage-place-host
          and _file._hidden = no no-error.
    if not available _file then do:
      assign
      v-mess = "Неверно опрeделено место хранения данных (фирма)".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'storage-place-host':U).
    end.
  end.
  if p-storage-place-obj <> {&question-mark}
  and p-storage-place-obj <> '':U then do:
    find first _file no-lock where
              _file._file-name = p-storage-place-obj
          and _file._hidden = no no-error.
    if not available _file then do:
      assign
      v-mess = "Неверно опрeделено место хранения данных (объект)".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'storage-place-obj':U).
    end.
  end.
  if p-general <> '':U then do:
    do v-ii = 1 to num-entries(p-general):
      if lookup(entry(v-ii, p-general), {&prop-head-general-list}) = 0 then do:
        assign
        v-mess = "Неверно опрeделено предназначение".
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'general':U).
      end.
    end.
  end.
  if p-general-view <> '':U then do:
    do v-ii = 1 to num-entries(p-general-view):
      if lookup(entry(v-ii, p-general-view), {&prop-head-general-view-list}) = 0 then do:
        assign
        v-mess = "Неверно опрeделено представление".
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'general-view':U).
      end.
    end.
  end.
  if p-ref-type <> '':U and
  LOOKUP(p-ref-type, {&sum-id-type-list}) = 0 then do:
      assign
      v-mess = "Неверно опрeделен тип итога/среза".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'ref-type':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code no-error.
    if available buf_prop-head then do:
      assign
      v-mess = "Уже существует Объект-операнд c таким кодом".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dtm-code':U).
    end.
    find first buf_prop-head no-lock where
          buf_prop-head.prop-name = p-prop-name no-error.
    if available buf_prop-head
    and buf_prop-head.dtm-code <> p-dtm-code
    then do:
      assign
      v-mess = "Уже существует Объект-операнд c таким именем".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'prop-name':U).
    end.
    create buf_prop-head.
    assign
    buf_prop-head.dtm-code = p-dtm-code
    .
  end.
  if p-mode = {&update} then do:
    find first buf_prop-head exclusive-lock where
              recid(buf_prop-head) = p-rec .
    if buf_prop-head.dtm-code <> p-dtm-code
    then do:
      assign
      v-mess = substitute("Для уже существующего Объекта-операнда невозможно изменение кода&1" +
                              "старые значения кода: &2"
                              , {&new-line}
                              , buf_prop-head.dtm-code)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dtm-code':U).
    end.
    find first buf2_prop-head no-lock where
          buf2_prop-head.prop-name = p-prop-name no-error.
    if available buf2_prop-head
    and buf2_prop-head.dtm-code <> p-dtm-code
    then do:
      assign
      v-mess = "Уже существует Объект-операнд c таким именем".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'prop-name':U).
    end.
  end.
  assign
  buf_prop-head.prop-name          = p-prop-name
  buf_prop-head.prop-label         = p-prop-label
  buf_prop-head.prop-des           = p-prop-des
  buf_prop-head.ref-type           = p-ref-type
  buf_prop-head.storage-place      = p-storage-place
  buf_prop-head.storage-place-host = p-storage-place-host
  buf_prop-head.storage-place-obj  = p-storage-place-obj
  buf_prop-head.hist-from-prim     = p-hist-from-prim
  buf_prop-head.hist-to-nws        = p-hist-to-nws
  buf_prop-head.get-hist-from-nws  = p-get-hist-from-nws
  buf_prop-head.nws-to-hist        = p-nws-to-hist
  buf_prop-head.smart-nws          = p-smart-nws
  buf_prop-head.nws-to-cd          = p-nws-to-cd
  buf_prop-head.general            = p-general
  buf_prop-head.general-view       = p-general-view
  p-rec = recid(buf_prop-head)
  .
  release buf_prop-head no-error.
  if error-status:error then do:
      assign
      v-mess = substitute("Ошибка при сохранении записи:&1&2&1&3", {&new-line}, error-status:get-message(1) , return-value ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'prop-name':U).
  end.

end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("prop-head код: &1 &2"
                         , p-dtm-code
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.