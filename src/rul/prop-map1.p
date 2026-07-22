block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение prop-map

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-node-code            as integer no-undo .
define input parameter        p-upper-node-code      as integer no-undo .
define input parameter        p-upper-node-name      as character no-undo .
define input parameter        p-node-type            as integer no-undo .
define input parameter        p-is-collection        as logical no-undo .
define input parameter        p-rw-option            as character no-undo .
define input parameter        p-node-name            as character no-undo .
define input parameter        p-node-label           as character no-undo .
define input parameter        p-node-value-type      as character no-undo .
define input parameter        p-node-format          as character no-undo .
define input parameter        p-node-description     as character no-undo .
define input parameter        p-is-term              as logical no-undo .
define input parameter        p-init-value-character as character no-undo .
define input parameter        p-init-value-date      as date no-undo .
define input parameter        p-init-value-decimal   as decimal no-undo .
define input parameter        p-init-value-integer   as integer no-undo .
define input parameter        p-init-value-logical   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-map".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf2_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
define buffer last_prop-map for ub.prop-map.

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
do for buf_prop-map
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
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code no-error.
  if not available buf_prop-head then do:
    assign
    v-mess = "Неверный код объекта-операнда".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if p-node-name = '':u then do:
    assign
    v-mess = "Имя свойства не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'prop-name':U).
  end.
  if p-node-label = '':u then do:
    assign
    v-mess = "Лейбл свойства не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'node-label':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_prop-map no-lock where
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code = p-node-code no-error.

    if available buf_prop-map then do:
      assign
      v-mess = "Уже существует свойство c таким кодом для данного объекта".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'node-code':U).
    end.
    find first buf_prop-map no-lock where
          buf_prop-map.node-name = p-node-name
      and buf_prop-map.dtm-code = p-dtm-code no-error.
    if available buf_prop-map
    and buf_prop-map.node-code <> p-node-code
    then do:
      assign
      v-mess = "Уже существует свойство с таким именем для данного объекта".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'node-name':U).
    end.
    create buf_prop-map.
    assign
    buf_prop-map.dtm-code = p-dtm-code
    buf_prop-map.node-code = p-node-code
    .
  end.
  if p-mode = {&update} then do:
    find first buf_prop-map exclusive-lock where
              recid(buf_prop-map) = p-rec .
    if buf_prop-map.dtm-code <> p-dtm-code
    or buf_prop-map.node-code <> p-node-code
    then do:
      assign
      v-mess = substitute("Для уже существующего свойства невозможно изменение кода и принадлежности к объекту&1" +
                              "старые значения кода объекта и кода свойства: &2 и &3"
                              , {&new-line}
                              , buf_prop-map.dtm-code
                              , buf_prop-map.node-code
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dtm-code':U).
    end.
    find first buf2_prop-map no-lock where
          buf2_prop-map.node-name = p-node-name
      and buf2_prop-map.dtm-code = p-dtm-code
      no-error.
    if available buf2_prop-map
    and buf2_prop-map.node-code <> p-node-code
    then do:
      assign
      v-mess = "Уже существует свойство c таким именем для данного объекта операнда".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'node-name':U).
    end.
  end.
  if p-mode = {&add-def}
  or (p-mode = {&update} and buf_prop-map.ordinal = 0) then do:
    find last last_prop-map no-lock where
            last_prop-map.dtm-code = p-dtm-code
        and last_prop-map.upper-node-code = p-upper-node-code no-error.
  end.
  assign
  buf_prop-map.node-name            = p-node-name
  buf_prop-map.node-label           = p-node-label
  buf_prop-map.upper-node-code      = p-upper-node-code
  buf_prop-map.upper-node-name      = p-upper-node-name
  buf_prop-map.node-type            = p-node-type
  buf_prop-map.is-collection        = p-is-collection
  buf_prop-map.rw-option            = p-rw-option
  buf_prop-map.node-value-type      = p-node-value-type
  buf_prop-map.node-format          = p-node-format
  buf_prop-map.node-description     = p-node-description
  buf_prop-map.is-term              = p-is-term
  buf_prop-map.init-value-character = p-init-value-character
  buf_prop-map.init-value-date      = p-init-value-date
  buf_prop-map.init-value-decimal   = p-init-value-decimal
  buf_prop-map.init-value-integer   = p-init-value-integer
  buf_prop-map.init-value-logical   = p-init-value-logical
  buf_prop-map.ordinal              = (if available  last_prop-map
                                       then last_prop-map.ordinal + 1
                                       else 1)
  p-rec = recid(buf_prop-map)
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
      p-mess = substitute("Свойство объекта: код объекта &1 код свойства &2:&3 &4"
                         , p-dtm-code
                         , p-node-code
                         , {&new-line}
                         , p-mess
                         )
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.