block-level on error undo, throw.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
    return .
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
    return .
  end.
  if p-cntxt-host-code-obj = ?
  then do:
    assign
      p-cntxt-error-message = substitute("Код фирмы имеет неопределенное значение. Это недопустимо для любого контекста. Код фирмы &1"
                                        ,p-cntxt-host-code-obj
                                        )
    .
    return .
  end.
  case p-cntxt-level
  :
    when 'global':U
    then do:
      if p-cntxt-host-code-obj <> 0
      then do:
        assign
          p-cntxt-error-message = substitute("Для глобального контекста код фирмы должен быть неопределен. Код фирмы &1"
                                            ,p-cntxt-host-code-obj
                                            )
        .
        return .
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
        return .
      end.
      if p-cntxt-db-num-obj    <> ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для глобального контекста код базы данных объекта должен быть неопределен. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return .
      end.
    end.
    when 'firm':U
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
        return .
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
        return .
      end.
      if p-cntxt-db-num-obj    <> ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста фирмы код базы данных объекта должен быть неопределен. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return .
      end.
    end.
    when 'object':U
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
        return .
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
        return .
      end.
      if p-cntxt-db-num-obj = ?
      then do:
        assign
          p-cntxt-error-message = substitute("Для контекста объекта должен быть определен фирмы код базы объекта. Код базы данных объекта &1"
                                            ,p-cntxt-db-num-obj
                                            )
        .
        return .
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
        return .
      end.
    end.
    otherwise do:
      assign
        p-cntxt-error-message = substitute("Неизвестное значение контекста &1"
                                          ,p-cntxt-level
                                          )
      .
      return .
    end.
  end case .
  define variable v-enable-item as logical   no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usmgrava in g#library2
  (input  p-cntxt-db-num
  ,input  0
  ,input  p-cntxt-user-id
  ,input  p-cntxt-menu-code
  ,input  p-cntxt-menu-group-code
  ,input  p-cntxt-level
  ,input  p-cntxt-host-code-obj
  ,input  p-cntxt-obj-type
  ,input  p-cntxt-obj-code
  ,output v-enable-item
  )  .
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
    return .
  end.
  assign
    p-cntxt-valid = true
  .
end.
