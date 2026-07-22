block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sumgrp01.p $
$Archive: ref/sumgrp01.p $

Сохранение изменений в карточке суммовой группы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/14/06
Author: Bakhtadze Natalya
Creation date: 08/14/06

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!


*/

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
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-err-mess as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.
define buffer buf_sys-ctrl for ub.sys-ctrl.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode <> {&add-def}
  AND p-mode <> {&update} then do:
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
                  AND p-mode = {&add-def} ) then do:
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
  if p-mode = {&add-def} then do:
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
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end. /*doe*/

PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
p-mess = substitute("Ошибка при сохранении/изменении СУММОВОЙ ГРУППЫ с кодом № &1&2&3"
                  , p-grp-code
                  , {&new-line}
                  , p-mess) .
if not p-silent then
message
p-mess
view-as alert-box error .
END PROCEDURE.

