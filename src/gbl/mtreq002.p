block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mtreq002.p $
$Archive: gbl/mtreq002.p $

Мобильный терминал. Открытие чека на кассе

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
define input  parameter p-pos-num       as integer   no-undo .
define output parameter p-send-message  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq002.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq002.p $":U .
define variable vss-description as character no-undo init "Мобильный терминал. Открытие чека на кассе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/integerm.i }
{ str/libthpos.i }

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
  define variable v-doc-code          as character no-undo .
  define variable v-exch-rate         as decimal   no-undo .
  define variable v-exch-scale        as integer   no-undo .
  define variable v-cash-rate         as decimal   no-undo .
  define variable v-cash-scale        as integer   no-undo .


  run check-data in this-procedure ( output v-ok
                                   , output v-err-message
                                   , output v-doc-code
                                   , output v-exch-rate
                                   , output v-exch-scale
                                   , output v-cash-rate
                                   , output v-cash-scale
                                   ) .

  create x-document hdocument.
  create x-noderef hroot.
  create x-noderef hchild.
  create x-noderef htext.

  hdocument:encoding = "UTF-8" .
  hdocument:CREATE-NODE(hRoot,"msg","ELEMENT").
  hdocument:APPEND-CHILD(hRoot).
  /* < */
  hdocument:create-node(hChild, "stts", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1" , (if v-ok then 0 else 1)).

  /* < */
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

  /* < */
  hdocument:create-node(hChild, "chkcode", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = v-doc-code .

  /* < */
  hdocument:create-node(hChild, "exchrate", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-exch-rate) .

  /* < */
  hdocument:create-node(hChild, "exchscale", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-exch-scale) .

  /* < */
  hdocument:create-node(hChild, "cashrate", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-cash-rate) .

  /* < */
  hdocument:create-node(hChild, "cashscale", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-cash-scale) .

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
  define output parameter p-doc-code      as character no-undo .
  define output parameter p-exch-rate     as decimal   no-undo .
  define output parameter p-exch-scale    as integer   no-undo .
  define output parameter p-cash-rate     as decimal   no-undo .
  define output parameter p-cash-scale    as integer   no-undo .



  define buffer buf_clients       for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_sys-ctrl      for ub.sys-ctrl .
  define buffer buf_user-login    for ub.user-login .
  define buffer buf_user-account  for ub.user-account.
  define buffer buf_staff         for ub.staff.

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
                                  , p-user-login
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

  define variable v-serial-code       as character no-undo .
  define variable v-r-b               as character no-undo .
  define variable v-base-code         as integer   no-undo .
  define variable v-cash-num          as integer   no-undo .
  define variable v-pos-type          as character no-undo .
  define variable v-chk-type          as integer   no-undo .
  define variable v-cashier           as integer   no-undo .
  define variable v-cashier-psn-code  as integer   no-undo .
  define variable v-doc-code          as character no-undo .
  define variable v-exch-rate         as decimal   no-undo .
  define variable v-exch-scale        as integer   no-undo .
  define variable v-cash-rate         as decimal   no-undo .
  define variable v-cash-scale        as integer   no-undo .


  assign
    v-pos-type = {&cd-type-IBS-TH-MOB}
    v-cash-num = p-pos-num
    v-chk-type = integer({&rcpt-ord-sale})
  .

  main-block :
  do transaction
  :
    { str/libthpos_create-context.i
      parparentproc
      ?
      buf_sys-ctrl.db-num
      buf_clients.obj-code
      v-pos-type
      p-pos-num
      v-serial-code
      v-r-b
      v-base-code
      no-error
    }
    if error-status :error
    then do:
      assign
        p-error-message = substitute( "Ошибка создания контекста кассы.&1&2&1&3&1&4&1&5"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    )
      .
      undo main-block , return . /* --->>>--- */
    end.

   find first buf_user-account no-lock
    where buf_user-account.user-id = buf_user-login.user-id
   no-error .
   if not available buf_user-account
   then do:
      assign
        p-error-message = substitute( "Не найдена запись user-acount для пользователя id = &1"
                                    , buf_user-login.user-id
                                    )
      .
      undo main-block , return . /* --->>>--- */
   end.

   find first buf_staff no-lock
    where buf_staff.role        = {&role-cashier}
      and buf_staff.role-level  = {&role-level-db}
      and buf_staff.date-start  <= today
      and buf_staff.date-end    >= today
      and buf_staff.psn-code    = buf_user-account.psn-code
      and buf_staff.db-num      = buf_sys-ctrl.db-num
   no-error.
   if not available buf_staff
   then do:
      assign
        p-error-message = substitute( "Пользователь&1id:&2&1Фамилия:&3&1Псевдоним:&4&1БД:&5&1не является кассиром. Работа с кассой невозможна."
                                    , {&new-line}
                                    , buf_user-account.user-id
                                    , buf_user-account.last-name
                                    , buf_user-account.nik
                                    , buf_sys-ctrl.db-num
                                    )
      .
      undo main-block , return . /* --->>>--- */
   end.

   assign
      v-cashier          = buf_staff.staff-code
      v-cashier-psn-code = buf_user-account.psn-code
   .

    { str/libthpos_create-chk-doc.i
      buf_sys-ctrl.db-num
      buf_clients.obj-code
      v-pos-type
      v-cash-num
      v-chk-type
      v-cashier
      v-cashier-psn-code
      v-doc-code
      v-exch-rate
      v-exch-scale
      v-cash-rate
      v-cash-scale
      no-error
    }

    if error-status:error then do:
      assign
        p-error-message = substitute( "Ошибка открытия чека.&1&2&1&3&1&4&1&5"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    )
      .
      undo main-block , return . /* --->>>--- */
    end.

  end.

  assign
    p-data-valid    = true
    p-error-message = ""
    p-doc-code      = v-doc-code
    p-exch-rate     = v-exch-rate
    p-exch-scale    = v-exch-scale
    p-cash-rate     = v-cash-rate
    p-cash-scale    = v-cash-scale
  .

end.

end procedure. /* check-data */