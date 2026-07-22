block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wndpar_r.p $
$Archive: gbl/wndpar_r.p $

Чтение пользовательских параметров настройки интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/05

*/

define input  parameter p-db-num        as integer   no-undo .
define input  parameter p-user-id       as character no-undo .
define input  parameter p-param-code    as character no-undo .
define output parameter p-param-value   as logical   no-undo .
define output parameter p-default-value as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wndpar_r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/wndpar_r.p $":U .
define variable vss-description as character no-undo init "Чтение пользовательских параметров настройки интерфейса".
{ cmp/vssrevis.i "substitute('&1|&2|&3':U,p-db-num,p-user-id,p-param-code)" }
{ cmp/str-glbl.i }

do
on error undo, return error return-value
:
  define variable v-param-value           as character no-undo .
  define variable v-param-type            as character no-undo .
  define variable v-config-parameter-code as character no-undo .

  define buffer buf_user-login for ub.user-login .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_config     for ub.config .

  find first buf_sys-ctrl no-lock .

  if p-db-num = ? then do:
    assign
      p-db-num = buf_sys-ctrl.db-num
    .
  end.

  if p-user-id = "":U then do:
    assign
      p-user-id = userid( "DICTDB":U )
    .
  end.

  assign
    p-param-value   = ?
    p-default-value = false
  .

  find first buf_user-login no-lock
    where buf_user-login.db-num  = p-db-num
      and buf_user-login.user-id = p-user-id
    no-error .
  if available buf_user-login then do:
    case p-param-code :
      when {&user-window-maximize}
      then do:
        assign
          p-param-value = buf_user-login.user-window-maximize
        .
      end.
      when {&user-window-size-store}
      then do:
        assign
          p-param-value = buf_user-login.user-window-size-store
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Неизвестное значение параметра p-param-code" skip
          "p-param-code" p-param-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

  case p-param-code :
    when {&user-window-maximize}
    then do:
      assign
        v-config-parameter-code = {&attr-wnd-size_max}
      .
    end.
    when {&user-window-size-store}
    then do:
      assign
        v-config-parameter-code = {&attr-wnd-size_store}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-param-code" skip
        "p-param-code" p-param-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  if p-param-value = ? then do:
    assign
      p-default-value = FALSE
    .

    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-tth             as handle     no-undo .

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-wnd-size}
                      , input  v-config-parameter-code
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output p-param-value
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        p-param-value   = NO
      .
    end.
    delete object v-tth.

  end.
end.