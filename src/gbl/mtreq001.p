block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mtreq001.p $
$Archive: gbl/mtreq001.p $

Мобильный терминал. Валидация настроек мягких чеков

Автор: Хныкин Павел Андреевич
Дата создания: 07/21/08
Author: Pavel Khnykin
Creation date: 07/21/08

*/

define input  parameter parparentproc   as handle    no-undo .
define input  parameter p-device-id     as character no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as integer   no-undo .
define output parameter p-send-message  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq001.p $":U .
define variable vss-description as character no-undo init "Мобильный терминал. Валидация настроек мягких чеков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/integerm.i }

define variable v-user-login    as character no-undo .

do
on error undo, return error return-value
:

  define variable v-sendmemptr  as memptr   no-undo .

  define variable hdocument as handle    no-undo .
  define variable hroot     as handle    no-undo .
  define variable hchild    as handle    no-undo .
  define variable htext     as handle    no-undo .

  define variable icounter        as integer   no-undo .

  define variable v-ok          as logical   no-undo .
  define variable v-message     as longchar  no-undo .
  define variable v-err-message as character no-undo .


  run check-data in this-procedure ( output v-ok , output v-err-message ) .

  create x-document hdocument.
  create x-noderef hroot.
  create x-noderef hchild.
  create x-noderef htext.

  hdocument:encoding = "UTF-8" .
  hdocument:CREATE-NODE(hRoot,"msg","ELEMENT").
  hdocument:APPEND-CHILD(hRoot).

  /* <--------------------- */
  hdocument:create-node(hChild, "stts", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1" , (if v-ok then 0 else 1)).

  /* <--------------------- */
  hdocument:create-node(hChild, "errmsg", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = v-err-message .

  /* <--------------------- */
  hdocument:create-node(hChild, "deviceid", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = p-device-id.


  hdocument:save("LONGCHAR", v-message).

  delete object hdocument .
  delete object hroot     .
  delete object hchild    .
  delete object htext     .
  assign
    hdocument      = ?
    hroot          = ?
    hchild         = ?
    htext          = ?
    p-send-message = v-message
  .

end.


procedure check-data :
  define output parameter p-data-valid    as logical   no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .

do
on error undo, return error return-value
:
  find first buf_sys-ctrl no-lock .
  find first buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = {&uls-normal}
      and buf_user-login.user-login = p-user-login
    no-error .
  if not available buf_user-login
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Неизвестный пользователь &1"
                                  , v-user-login
                                  )
    .
    return . /* --->>>--- */
  end.

  define variable v-obj-code      as integer   no-undo .
  define variable v-data-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .


  find first buf_clients no-lock
    where buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code
    no-error .
  if not available buf_clients
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute( "Не найден объект &1 &2"
                                  , p-obj-type
                                  , p-obj-code
                                  )
    .
    return . /* --->>>--- */
  end.

  if  p-obj-type <> {&shop}
  and p-obj-type <> {&stock}
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Неправильный тип объекта &1 &2"
                                  , p-obj-type
                                  , p-obj-code
                                  )
    .
    return . /* --->>>--- */
  end.

  define variable v-host-code as integer   no-undo .

  { gbl/hostcode.i
    buf_clients.obj-type
    buf_clients.obj-code
    v-host-code
  }

  /* проверить что объект доступен пользователю */
  define variable v-object-available as logical   no-undo .
  { gbl/usobjava.i
    buf_sys-ctrl.db-num
    {&action-head-code-main}
    buf_user-login.user-id
    buf_clients.obj-type
    buf_clients.obj-code
    v-object-available
  }
  if v-object-available <> true
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                  ,buf_clients.obj-type
                                  ,buf_clients.obj-code
                                  )
    .
    return . /* --->>>--- */
  end.

  assign
    p-data-valid    = true
    p-error-message = ""
  .

end.

end procedure. /* check-data */