block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkprtob.p $
$Archive: utl/chkprtob.p $

Процедура очистки таблицы prt-obj

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

Проходим по всем записям таблицы prt-obj и удаляем все записи,
которые не имеют соответсвующей записи gds-obj

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $".
define variable vss-author      as character no-undo init "$Author: expertek $".
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $".
define variable vss-workfile    as character no-undo init "$Workfile: chkprtob.p $".
define variable vss-archive     as character no-undo init "$Archive: utl/chkprtob.p $".
define variable vss-description as character no-undo init "Проверка целостности всех товаров".
{ cmp/vssrevis.i }

define variable v-ind as integer no-undo init 0 .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/temphost.i }
{ gbl/userobjs.i }

run init-temphost .

define variable lok as logical no-undo init false .

message
  "Удалить лишние записи prt-obj." skip
  "ВНИМАНИЕ! ВСЕМ ПОЛЬЗОВАТЕЛЯМ НЕОБХОДИМО ВЫЙТИ ИЗ СИСТЕМЫ!" skip
  "Да - все объекты" skip
  "Нет - выбрать объекты" skip
  "Отмена - отказаться от запуска утилиты"
  "Удаленные записи prt-obj записываются в текстовый файл chkprtob.txt." skip
  view-as alert-box question buttons yes-no-cancel update lok
  .

if lok = ? then do:
  return .
end.

{ gbl/getcntxt.i get }

if lok = true then do:
  for each temp-obj
  :
    run object-check-prt-obj
      (input temp-obj.obj-type
      ,input temp-obj.obj-code
      ).
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
    run object-check-prt-obj
      (input buf_userobjs_temp-user-obj.obj-type
      ,input buf_userobjs_temp-user-obj.obj-code
      ).
  end.
end.

if v-ind = 0
then do:
  message
    "Просмотр выбранных объектов закончен." skip
    "Ошибок не найдено." skip
    view-as alert-box information.
end.
else do:
  message
    "Просмотр выбранных объектов закончен." skip
    "Найдено" v-ind "ошибок." skip
    view-as alert-box error .
end.

procedure object-check-prt-obj :
  define input parameter p-obj-type like prt-obj.obj-type no-undo .
  define input parameter p-obj-code like prt-obj.obj-code no-undo .

  for each prt-obj
    where prt-obj.obj-type = p-obj-type
      and prt-obj.obj-code = p-obj-code
  :
    find first gds-obj no-lock
      where gds-obj.obj-type  = p-obj-type
        and gds-obj.obj-code  = p-obj-code
        and gds-obj.artic     = prt-obj.artic
        and gds-obj.prod-type = prt-obj.prod-type
        and gds-obj.prod-code = prt-obj.prod-code
      no-error .
    if not available gds-obj then do:
      output to chkprtobj.txt append .
      export prt-obj .
      output close .

      delete prt-obj .

      assign
        v-ind = v-ind + 1
      .
    end.
  end.


end procedure. /* object-check-prt-obj */