block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mtreq005.p $
$Archive: gbl/mtreq005.p $

Мобильный терминал. Аннуляция чека

Автор: Хныкин Павел Андреевич
Дата создания: 07/21/08
Author: Pavel Khnykin
Creation date: 07/21/08

*/

define input  parameter parparentproc       as handle    no-undo .
define input  parameter p-device-id         as character no-undo .
define input  parameter p-doc-code          as character no-undo .
define output parameter p-send-message      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq005.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq005.p $":U .
define variable vss-description as character no-undo init "Мобильный терминал. Аннуляция чека".
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


  run check-data in this-procedure ( output v-ok
                                   , output v-err-message
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


do
on error undo, return error return-value
:
  main-block :
  do transaction
  :
    { str/libthpos_annulate.i
      p-doc-code
      0
      no-error
    }
    if error-status :error
    then do:
      assign
        p-error-message = substitute( "Ошибка аннуляции чека &6.&1&2&1&3&1&4&1&5"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    , p-doc-code
                                    )
      .
      undo main-block , return . /* --->>>--- */
    end.
  end.

  assign
    p-data-valid    = true
    p-error-message = ""
  .

end.

end procedure. /* check-data */