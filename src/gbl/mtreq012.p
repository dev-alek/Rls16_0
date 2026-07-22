block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mtreq012.p $
$Archive: gbl/mtreq012.p $

Авторизация пользователя МТ

Автор: Хныкин Павел Андреевич
Дата создания: 07/21/08
Author: Pavel Khnykin
Creation date: 07/21/08

*/
define input  parameter p-parparentproc as handle    no-undo .
define input  parameter p-device-id     as character no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define output parameter p-logged-in     as logical   no-undo .
define output parameter p-send-message  as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq012.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq012.p $":U .
define variable vss-description as character no-undo init "Авторизация пользователя МТ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


do
on error undo, return error return-value
:


  define variable hdocument     as handle    no-undo .
  define variable hroot         as handle    no-undo .
  define variable hchild        as handle    no-undo .
  define variable htext         as handle    no-undo .
  define variable v-ok          as logical   no-undo .
  define variable v-message     as longchar  no-undo .
  define variable v-err-message as character no-undo .

  run check-data in this-procedure ( output v-ok , output v-err-message ) .

  create x-document hdocument.
  create x-noderef hroot.
  create x-noderef hchild.
  create x-noderef htext.

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
    hdocument = ?
    hroot     = ?
    hchild    = ?
    htext     = ?
    p-send-message = v-message
    p-logged-in    = v-ok
  .

end.

procedure check-data :
  define output parameter p-data-valid    as logical   no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_user        for ub._user.
  define buffer buf_user-login  for ub.user-login.

  define variable v-check-password as character no-undo .

do
on error undo, return error return-value
:

  run adm/pswd-enc.p ( input encode(p-user-password)
                      , output v-check-password
                      ).

  assign
    v-check-password = encode(v-check-password)
  .

  find first buf_user no-lock
    where buf_user._userid = p-user-login
    no-error .
  if not available buf_user
  then do:
    assign
      p-data-valid = false
      p-error-message  = substitute( "Неизвестный пользователь &1" , p-user-login )
    .
    return . /* --->>>--- */
  end.

  if buf_user._Password <> v-check-password
  then do:
    assign
      p-data-valid = false
      p-error-message  = "Неправильный пароль. "
    .
    return . /* --->>>--- */
  end.

  find first buf_user-login no-lock
    where buf_user-login.user-login = p-user-login
  no-error .
  if available buf_user-login
  then do:
    assign
      p-data-valid = true
    .
  end.
  else do:
      assign
          p-data-valid    = false
          p-error-message = substitute( "Не найден пользователь &1", p-user-login)
      .
      return . /* --->>>--- */
  end.

  assign
    p-data-valid = true
  .

end.

end procedure. /* check-data */