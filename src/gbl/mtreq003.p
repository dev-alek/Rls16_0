block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mtreq003.p $
$Archive: gbl/mtreq003.p $

Мобильный терминал. Ввод строки чека

Автор: Хныкин Павел Андреевич
Дата создания: 07/21/08
Author: Pavel Khnykin
Creation date: 07/21/08

*/

define input  parameter parparentproc       as handle    no-undo .
define input  parameter p-device-id         as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-line-num          as integer   no-undo .
define input  parameter p-mode              as character no-undo .
define input  parameter p-src-code          as character no-undo .
define input  parameter p-src-qnty          as decimal   no-undo .
define input  parameter p-pump              as integer   no-undo .
define input  parameter p-nozzle-code       as integer   no-undo .
define input  parameter p-pl-code           as integer   no-undo .
define input  parameter p-write-off-code    as integer   no-undo .
define input  parameter p-pass-gds          as integer   no-undo .
define input  parameter p-fbr-depart        as integer   no-undo .




define output parameter p-send-message  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq003.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq003.p $":U .
define variable vss-description as character no-undo init "Мобильный терминал. Ввод строки чека".
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

  define variable v-ok            as logical   no-undo .
  define variable v-message       as longchar  no-undo .
  define variable v-err-message   as character no-undo .
  define variable v-setted        as logical   no-undo .
  define variable v-b-code        as character no-undo .
  define variable v-gds-code      as integer   no-undo .
  define variable v-chk-name      as character no-undo .
  define variable v-second-name   as character no-undo .
  define variable v-src-price     as decimal   no-undo .
  define variable v-src-discnt    as decimal   no-undo .
  define variable v-src-sum       as decimal   no-undo .
  define variable v-src-sum-netto as decimal   no-undo .
  define variable v-tot-doc       as decimal   no-undo .
  define variable v-src-qnty-out  as decimal   no-undo .


  run check-data in this-procedure ( output v-ok
                                   , output v-err-message
                                   , output v-setted
                                   , output v-b-code
                                   , output v-gds-code
                                   , output v-chk-name
                                   , output v-second-name
                                   , output v-src-price
                                   , output v-src-discnt
                                   , output v-src-sum
                                   , output v-src-sum-netto
                                   , output v-tot-doc
                                   , output v-src-qnty-out
                                   ) .

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

  /* <--------------------- */
  hdocument:create-node(hChild, "setted", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1" , if v-setted then 0 else 1 ).

  /* <--------------------- */
  hdocument:create-node(hChild, "bcode", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-b-code) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "gdscode", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-gds-code) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "chkname", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", v-chk-name ).

  /* <--------------------- */
  hdocument:create-node(hChild, "secondname", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", v-second-name ).

  /* <--------------------- */
  hdocument:create-node(hChild, "srcprice", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-src-price)).

  /* <--------------------- */
  hdocument:create-node(hChild, "srcdiscnt", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-src-discnt) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "srcsum", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-src-sum) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "srcsumnetto", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-src-sum-netto) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "totdoc", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-tot-doc) ).

  /* <--------------------- */
  hdocument:create-node(hChild, "srcqnty", "ELEMENT").
  hRoot:append-child(hChild).

  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1", string(v-src-qnty-out) ).


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
  define output parameter p-setted        as logical   no-undo .
  define output parameter p-b-code        as integer   no-undo .
  define output parameter p-gds-code      as integer   no-undo .
  define output parameter p-chk-name      as character no-undo .
  define output parameter p-second-name   as character no-undo .
  define output parameter p-src-price     as decimal   no-undo .
  define output parameter p-src-discnt    as decimal   no-undo .
  define output parameter p-src-sum       as decimal   no-undo .
  define output parameter p-src-sum-netto as decimal   no-undo .
  define output parameter p-tot-doc       as decimal   no-undo .
  define output parameter p-src-qnty-out  as decimal   no-undo .

  define buffer buf_clients       for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_sys-ctrl      for ub.sys-ctrl .
  define buffer buf_user-login    for ub.user-login .

do
on error undo, return error return-value
:
/*  find first buf_sys-ctrl no-lock .
  find first buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = {&uls-normal}
      and buf_user-login.user-login = p-user-login
    no-error .
  if not available buf_user-login
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute( "Неизвестный пользователь &1"
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

  define variable v-doc-code          as character            no-undo .
  define variable v-line-num          as integer              no-undo .
  define variable v-mode              as character            no-undo .
  define variable v-src-code          as character            no-undo .
  define variable v-src-qnty          as decimal              no-undo .
  define variable v-pump              as integer              no-undo .
  define variable v-nozzle-code       as integer              no-undo .
  define variable v-pl-code           as integer              no-undo .
  define variable v-write-off-code    as integer              no-undo .
  define variable v-pass-gds          as integer              no-undo .
  define variable v-fbr-depart        as integer              no-undo .
  define variable v-setted            as logical              no-undo .
  define variable v-next              as character            no-undo .
  define variable v-b-code            as integer              no-undo .
  define variable v-gds-code          as integer              no-undo .
  define variable v-chk-name          as character            no-undo .
  define variable v-second-name       as character            no-undo .
  define variable v-src-price         as decimal   initial ?  no-undo .
  define variable v-src-discnt        as decimal              no-undo .
  define variable v-src-sum           as decimal              no-undo .
  define variable v-src-sum-netto     as decimal              no-undo .
  define variable v-unit-base         as character            no-undo .

  assign
    v-doc-code        = p-doc-code
    v-line-num        = p-line-num
    v-mode            = p-mode
    v-src-code        = p-src-code
    v-src-qnty        = p-src-qnty
    v-pump            = p-pump
    v-nozzle-code     = p-nozzle-code
    v-pl-code         = p-pl-code
    v-write-off-code  = p-write-off-code
    v-pass-gds        = p-pass-gds
    v-fbr-depart      = p-fbr-depart
  .

  main-block :
  do transaction
  :
    { str/libthpos_gds-line.i
      v-doc-code
      v-line-num
      v-mode
      1
      v-src-code
      v-src-qnty
      v-pump
      v-nozzle-code
      v-pl-code
      v-pass-gds
      v-write-off-code
      v-fbr-depart
      v-setted
      v-next
      v-b-code
      v-gds-code
      v-chk-name
      v-second-name
      v-src-price
      v-src-discnt
      v-src-sum
      v-src-sum-netto
      v-unit-base
      no-error
    }
    if error-status :error
    then do:
      assign
        p-error-message = substitute( "Ошибка создания строки чека &6.&1&2&1&3&1&4&1&5"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    , v-doc-code
                                    )
      .
      undo main-block , return . /* --->>>--- */
    end.

    define variable v-st-r-b  as decimal   no-undo .
    define variable v-st-rubl as decimal   no-undo .
    define variable v-st-base as decimal   no-undo .
    define variable v-tot-doc as decimal   no-undo .
    define variable v-discnt  as decimal   no-undo .

    { str/libthpos_sub-total.i
      v-doc-code
      ''
      v-setted
      v-st-r-b
      v-st-rubl
      v-st-base
      v-tot-doc
      v-discnt
      no-error
    }
    if error-status :error
    then do:
      assign
        p-error-message = substitute( "Ошибка расчета подитога чека &6.&1&2&1&3&1&4&1&5"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    , v-doc-code
                                    )
      .
      undo main-block , return . /* --->>>--- */
    end.

  end.

  assign
    p-data-valid    = true
    p-error-message = ""
    p-setted        = v-setted
    p-b-code        = v-b-code
    p-gds-code      = v-gds-code
    p-chk-name      = v-chk-name
    p-second-name   = v-second-name
    p-src-price     = v-src-price
    p-src-discnt    = v-src-discnt
    p-src-sum       = v-src-sum
    p-src-sum-netto = v-src-sum-netto
    p-tot-doc       = v-tot-doc
    p-src-qnty-out  = v-src-qnty
  .
                               */
end.

end procedure. /* check-data */