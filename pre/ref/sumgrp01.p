block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode         as character no-undo .
define input parameter p-silent       as logical no-undo .
define input parameter p-grp-code     as integer no-undo .
define input parameter p-grp-name     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sumgrp01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/sumgrp01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке суммовой группы".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-err-mess as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.
define buffer buf_sys-ctrl for ub.sys-ctrl.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode <> 'ДОБАВЛЕНИЕ':U
  AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр p-mode" p-mode
    view-as alert-box error .
    undo main-block, return error '':u.
  end.
  find first buf_sys-ctrl no-lock.
  if buf_sys-ctrl.db-num <> 0 then do:
    v-err-mess = "Создание и редактирование суммовых групп разрешено только в ГБД".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else '':U).
  end.
  if p-grp-code <= 0
  OR p-grp-code = ?  then do:
    v-err-mess = "Код группы товаров должен быть больше 0 !".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else 'grp-code':U).
  end.
  if p-grp-code >= 1000 then do:
    v-err-mess = "Код группы товаров должен быть меньше 1000 !".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else 'grp-code':U).
  end.
  if can-find( FIRST ub.sum-grp WHERE
                      ub.sum-grp.grp-code = p-grp-code
                  AND p-mode = 'ДОБАВЛЕНИЕ':U ) then do:
    v-err-mess = substitute("Суммовая группа с кодом &1 уже существует"
                           ,p-grp-code ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else 'grp-code':U).
  end.
  if p-grp-name = ""  then do:
    v-err-mess = substitute("Название суммовой группы не может быть пустым").
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else 'grp-name':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_sum-grp.
    assign
    buf_sum-grp.grp-code = p-grp-code
    buf_sum-grp.grp-name = p-grp-name
    p-doc-rec = recid(buf_sum-grp)
    .
  end.
  else do:
    FIND FIRST buf_sum-grp where
              recid(buf_sum-grp) = p-doc-rec No-ERROR.
    if p-grp-code <> buf_sum-grp.grp-code then do:
      assign
      v-err-mess = "Нельзя изменять код группы для уже имеющейся записи".
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else 'grp-code':U).
    end.
    assign
    buf_sum-grp.grp-name    = p-grp-name
    .
  end.
  release buf_Sum-grp no-error.
  if error-status:error then do:
    v-err-mess = substitute("&1 &2 &3&4" +
                            "Ошибка при сохранении записи СУММОВОЙ ГРУППЫ&4" +
                            "&5&4&6&4"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,chr(10)
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end.
PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
p-mess = substitute("Ошибка при сохранении/изменении СУММОВОЙ ГРУППЫ с кодом № &1&2&3"
                  , p-grp-code
                  , chr(10)
                  , p-mess) .
if not p-silent then
message
p-mess
view-as alert-box error .
END PROCEDURE.
