block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: objprtat.p $
$Archive: utl/objprtat.p $

Создание атрибутов партий

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 05/28/03

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-install     as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: objprtat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/objprtat.p $":U .
define variable vss-description as character no-undo init "Создание атрибутов партий".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .

do
on error undo, return error
:

  define variable v-num as integer no-undo .

  { gbl/getcntxt.i get }

  if p-install = true then do:
    assign
      v-num = 1
    .
  end.
  else do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "Создать атрибуты партий" + {&new-line}
      ,input "|^"
      ,input "Все объекты^confirm|Выбрать объекты|Отмена"
      ,input "|"
          + "|"
          + ""
      ,input 1
      ,input 3
      ,output v-num
      ).
  end.

  case v-num :
    when 1 then do:
      for each buf_db no-lock
      on error undo, return error
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
            and buf_clients.stts   = 0
        on error undo, return error
        :
          run utl/objatrcr.p
            (input buf_clients.obj-type
            ,input buf_clients.obj-code
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании атрибутов партий" skip
              "Объект" buf_clients.obj-type buf_clients.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    when 2 then do:
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
      :
        run utl/objatrcr.p
          (input buf_userobjs_temp-user-obj.obj-type
          ,input buf_userobjs_temp-user-obj.obj-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании атрибутов партий" skip
            "Объект" buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    when 3 then do:
      return . /* --->>>--- */
    end.
  end.

  if p-install = false then do:
    message
      "Создание атрибутов партий закончено" skip
      view-as alert-box information .
  end.

  return . /* --->>>--- */
end.