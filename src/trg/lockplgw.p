block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокировка и разблокировка МЦ на МХ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Параметры:
p-obj-type - объект
p-obj-code
p-w-p-code   - МХ
p-wth-code  - код МЦ
p-action    - действие, которое необходимо выполнить
  Возможные значения:
  assign-doc-on=true   установить блокировку на wth-pobj
  assign-doc-on=false  снять блокировку c wth-pobj
  check-doc-on=true    проверить, что wth-pobj заблокирован
  check-doc-on=false   проверить, что wth-pobj не заблокирован
p-no-check-doc-code -  документ, которая может находится в статусе разрешен,
                      при разблокировке товаров

*/

define input parameter p-obj-type          like ub.wth-pobj.obj-type no-undo .
define input parameter p-obj-code          like ub.wth-pobj.obj-code no-undo .
define input parameter p-wth-code          like ub.wth-pobj.wth-code  no-undo .
define input parameter p-w-p-code          like ub.wth-pobj.w-p-code  no-undo .
define input parameter p-action            as character no-undo .
define input parameter p-no-check-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка и разблокировка МЦ на МХ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define buffer buf_wth-obj  for ub.wth-obj .
define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup( p-action
    , "assign-doc-on=true"  + ","
    + "assign-doc-on=false" + ","
    + "check-doc-on=true"   + ","
    + "check-doc-on=false" ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение p-action" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  find first ub.wealth no-lock
    where ub.wealth.wth-code = p-wth-code
    no-error .
  if not available ub.wealth then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Код МЦ" p-wth-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* блокируем товар на объекте */
  { gbl/wthpobjc.i
    p-obj-type
    p-obj-code
    ub.wealth.wth-code
    p-w-p-code
    ub.wth-pobj
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при поиске МЦ на МХ объекта" skip
      "obj-type"  p-obj-type skip
      "obj-code"  p-obj-code skip
      "wth-code"  p-wth-code skip
      "w-p-code"  p-w-p-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* блокируем товар на объекте */
  { gbl/wthobjcr.i
    p-obj-type
    p-obj-code
    ub.wealth.wth-code
    buf_wth-obj
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при поиске МЦ на объекте" skip
      "obj-type"  p-obj-type skip
      "obj-code"  p-obj-code skip
      "wth-code"  p-wth-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* блокируем товар на объекте */
  find current buf_wth-obj exclusive-lock .
  release buf_wth-obj .

  find current ub.wth-pobj exclusive-lock .

  if ub.wth-pobj.doc-on = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "МЦ на МХ имеет неопределенный статус" skip
      "Объект" p-obj-type p-obj-code skip
      "МХ" p-w-p-code skip
      "Код МЦ" ub.wealth.wth-code skip
      "ub.wth-pobj.doc-on" ub.wth-pobj.doc-on skip
      view-as alert-box error .
    undo main-block, return error .
  end.


  /* производим действие, запрошенное пользователем */
  case p-action :
    when "assign-doc-on=true" then do:
      if ub.wth-pobj.doc-on = false then do:
        do
        on error undo main-block, return error
        :
          assign
            ub.wth-pobj.doc-on = true
          .
        end.
      end.
      else do:
        for each buf_wth-doc no-lock
          where buf_wth-doc.obj-type = ub.wth-pobj.obj-type
            and buf_wth-doc.obj-code = ub.wth-pobj.obj-code
            and buf_wth-doc.status_  = {&permitted}
        on error undo main-block, return error
        :

          for each buf_wth-line no-lock
            where buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.obj-type = ub.wth-pobj.obj-type
              and buf_wth-line.obj-code = ub.wth-pobj.obj-code
              and buf_wth-line.w-p-code  = ub.wth-pobj.w-p-code
              and buf_wth-line.wth-code = ub.wth-pobj.wth-code
          on error undo main-block, return error
          :
            message
              "Невозможно заблокировать МЦ на МХ" skip
              "МЦ уже является заблокированной" skip
              "Объект" p-obj-type p-obj-code skip
              "МХ" p-w-p-code skip
              "Код МЦ" ub.wealth.wth-code skip
              "Существует документ МЦ" buf_wth-doc.doc-code skip
              "Статус документа" buf_wth-doc.status_ skip
              view-as alert-box information .
            undo main-block, return error .
          end.
        end.
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно заблокировать МЦ на МХ" skip
          "МЦ уже является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    when "assign-doc-on=false" then do:
      if ub.wth-pobj.doc-on = true then do:
        /* проверяем, что не существует документов МЦ */
        /* в статусах {&permitted} */
        for each buf_wth-doc no-lock
          where buf_wth-doc.obj-type = ub.wth-pobj.obj-type
            and buf_wth-doc.obj-code = ub.wth-pobj.obj-code
            and ( buf_wth-doc.status_  = {&permitted}
                )
            and buf_wth-doc.doc-code <> p-no-check-doc-code
        on error undo main-block, return error
        :
          for each buf_wth-line no-lock
            where buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.obj-type = ub.wth-pobj.obj-type
              and buf_wth-line.obj-code = ub.wth-pobj.obj-code
              and buf_wth-line.w-p-code  = ub.wth-pobj.w-p-code
              and buf_wth-line.wth-code = ub.wth-pobj.wth-code
          on error undo main-block, return error
          :
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно снять блокировку на МЦ на МХ" skip
              "Объект" p-obj-type p-obj-code skip
              "МХ" p-w-p-code skip
              "Код МЦ" ub.wealth.wth-code skip
              "Существует документ МЦ" buf_wth-doc.doc-code skip
              "Статус документа" buf_wth-doc.status_ skip
              view-as alert-box information .
            undo main-block, return error .
          end.
        end.
        do
        on error undo main-block, return error
        :
          assign
            ub.wth-pobj.doc-on = false
          .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно разблокировать МЦ на МХ" skip
          "МЦ не является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    when "check-doc-on=true" then do:
      if ub.wth-pobj.doc-on <> true then do:
        message
          vss-workfile vss-revision vss-description skip
          "МЦ на МХ не является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "Место хранения" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    when "check-doc-on=false" then do:
      if ub.wth-pobj.doc-on <> false then do:
        message
          vss-workfile vss-revision vss-description skip
          "МЦ на МХ является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутрення ошибка" skip
        "Неизвестное значение p-action" skip
        "p-action" p-action skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end case .

end.