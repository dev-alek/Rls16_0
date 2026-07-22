block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cntxtchk.p $
$Archive: gbl/cntxtchk.p $

Проверить контекст

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/06

*/

define input  parameter p-cntxt-db-num          as integer   no-undo .
define input  parameter p-cntxt-user-id         as character no-undo .
define input  parameter p-cntxt-menu-code       as integer   no-undo .
define input  parameter p-cntxt-menu-group-code as integer   no-undo .
define input  parameter p-cntxt-level           as character no-undo .
define input  parameter p-cntxt-host-code-obj   as integer   no-undo .
define input  parameter p-cntxt-obj-type        as character no-undo .
define input  parameter p-cntxt-obj-code        as integer   no-undo .
define input  parameter p-cntxt-db-num-obj      as integer   no-undo .
define output parameter p-cntxt-valid           as logical   no-undo .
define output parameter p-cntxt-error-message   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cntxtchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cntxtchk.p $":U .
define variable vss-description as character no-undo init "Проверить контекст".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define buffer buf_user-login for ub.user-login .
define buffer buf_menu-group for ub.menu-group .
define buffer buf_sysconf    for ub.sysconf .
define buffer buf_clients    for ub.clients .

do
on error undo, return error return-value
:
  assign
    p-cntxt-valid = false
  .

  find first buf_user-login no-lock
    where buf_user-login.db-num  = p-cntxt-db-num
      and buf_user-login.user-id = p-cntxt-user-id
    no-error .
  if not available buf_user-login
  then do:
    assign
      p-cntxt-error-message = substitute("Не найден логин пользователя &1 &2"
                                        ,p-cntxt-db-num
                                        ,p-cntxt-user-id
                                        )
    .
    return . /* --->>>--- */
  end.

  find first buf_menu-group no-lock
    where buf_menu-group.menu-code       = p-cntxt-menu-code
      and buf_menu-group.menu-group-code = p-cntxt-menu-group-code
    no-error .
  if not available buf_menu-group
  then do:
    assign
      p-cntxt-error-message = substitute("Не найдена группа меню &1 &2"
                                        ,p-cntxt-menu-code
                                        ,p-cntxt-menu-group-code
                                        )
    .
    return . /* --->>>--- */
  end.

  if p-cntxt-host-code-obj = ?
  then do:
    assign
      p-cntxt-error-message = substitute("Код фирмы имеет неопределенное значение. Это недопустимо для любого контекста. Код фирмы &1"
                                        ,p-cntxt-host-code-obj
                                        )
    .
    return . /* --->>>--- */
  end.

  case p-cntxt-level
  :
    when {&cntxt-global}
    then do:
      if p-cntxt-host-code-obj <> 0
      then do:
        assign
          p-cntxt-error-message = substitute("Для глобального контекста код фирмы должен быть неопределен. Код фирмы &1"
                                            ,p-cntxt-host-code-obj
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-obj-type <> '':U
      or p-cntxt-obj-code <> 0
      then do:
        assign
          p-cntxt-error-message = substitute("Для глобального контекста код объекта должен быть неопределен. Код объекта &1 &2"
                                            ,p-cntxt-obj-type
                                            ,p-cntxt-obj-code
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-db-num-obj    <> ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для глобального контекста код базы данных объекта должен быть неопределен. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return . /* --->>>--- */
      end.
    end.
    when {&cntxt-firm}
    then do:
      find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-cntxt-host-code-obj
        no-error .
      if not available buf_sysconf
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста фирмы код фирмы должен быть определен. Код фирмы &1"
                                            ,p-cntxt-host-code-obj
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-obj-type <> '':U
      or p-cntxt-obj-code <> 0
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста фирмы код объекта должен быть неопределен. Код объекта &1 &2"
                                            ,p-cntxt-obj-type
                                            ,p-cntxt-obj-code
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-db-num-obj    <> ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста фирмы код базы данных объекта должен быть неопределен. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return . /* --->>>--- */
      end.
    end.
    when {&cntxt-object}
    then do:
      find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-cntxt-host-code-obj
        no-error .
      if not available buf_sysconf
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста объекта код фирмы должен быть определен. Код фирмы &1"
                                            ,p-cntxt-host-code-obj
                                            )
        .
        return . /* --->>>--- */
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = p-cntxt-obj-type
          and buf_clients.obj-code = p-cntxt-obj-code
        no-error .
      if not available buf_clients
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста объекта должен быть определен объект. Код объекта &1 &2"
                                            ,p-cntxt-obj-type
                                            ,p-cntxt-obj-code
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-db-num-obj = ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста объекта должен быть определен фирмы код базы объекта. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return . /* --->>>--- */
      end.
      if p-cntxt-db-num-obj <> buf_clients.db-num
      then do:
        assign
          p-cntxt-error-message = substitute("Код базы данных объекта не совпадает с базой данных объекта. Код базы данных объекта &1. Объект &2 &3. Должен быть код базы данных объекта &4."
                                            ,p-cntxt-db-num-obj
                                            ,buf_clients.obj-type
                                            ,buf_clients.obj-code
                                            ,buf_clients.db-num
                                            )
        .
        return . /* --->>>--- */
      end.
    end.
    otherwise do:
      assign
        p-cntxt-error-message = substitute("Неизвестное значение контекста &1"
                                          ,p-cntxt-level
                                          )
      .
      return . /* --->>>--- */
    end.
  end case .

  define variable v-enable-item as logical   no-undo .

  { gbl/usmgrava.i
    p-cntxt-db-num
    {&action-head-code-main}
    p-cntxt-user-id
    p-cntxt-menu-code
    p-cntxt-menu-group-code
    p-cntxt-level
    p-cntxt-host-code-obj
    p-cntxt-obj-type
    p-cntxt-obj-code
    v-enable-item
  }
  if v-enable-item <> true
  then do:
    assign
      p-cntxt-error-message = substitute("Недоступна группа меню &1 &2 для контекста &3 &4 &5 &6"
                                        ,p-cntxt-menu-code
                                        ,p-cntxt-menu-group-code
                                        ,p-cntxt-level
                                        ,p-cntxt-host-code-obj
                                        ,p-cntxt-obj-type
                                        ,p-cntxt-obj-code
                                        )
    .
    return . /* --->>>--- */
  end.


  assign
    p-cntxt-valid = true
  .
end.