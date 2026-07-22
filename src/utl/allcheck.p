block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: allcheck.p $
$Archive: utl/allcheck.p $

Проверка целостности всех товаров

Автор: Чернова Светлана Александровна
Дата создания: 06/23/08
Author: Svetlana Chernova
Creation date: 06/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: allcheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/allcheck.p $":U .
define variable vss-description as character no-undo init "Проверка целостности всех товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


define variable v-total-err as integer   no-undo .
define variable v-curr-err  as integer   no-undo .

run init-temphost .

define variable lok as logical no-undo init false .

message
  "Проверить целостность товаров." skip
  "Да - все объекты" skip
  "Нет - выбрать объекты" skip
  "Результат проверки записывается в файлы" skip
  "gdscheck.txt, gdscheck.lst, objcheck.txt" skip
  view-as alert-box question buttons yes-no-cancel update lok
  .

if lok = ? then do:
  return .
end.
{ gbl/getcntxt.i get }

if lok = true then do:
  for each temp-obj
  :
    run utl/objcheck.p
      (input temp-obj.obj-type
      ,input temp-obj.obj-code
      ).
    assign
      v-curr-err = integer(return-value) no-error
    .
    if v-curr-err <> ?
    then do:
      assign
        v-total-err = v-total-err + v-curr-err
      .
    end.
  end.
end.

if lok = false then do:

  define variable v-user-select as logical   no-undo .
  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  for each buf_userobjs_temp-user-obj
  on error undo, return error return-value
  :
    run utl/objcheck.p
      (input buf_userobjs_temp-user-obj.obj-type
      ,input buf_userobjs_temp-user-obj.obj-code
      ) .
    assign
      v-curr-err = integer(return-value) no-error
    .
    if v-curr-err <> ?
    then do:
      assign
        v-total-err = v-total-err + v-curr-err
      .
    end.
  end.
end.


/* возвращаем общее количество ошибок */
return string(v-total-err) .