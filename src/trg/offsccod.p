block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выключение локального весового кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-silence as logical no-undo .
define input parameter p-action as character no-undo . /*off del*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выключение локального весового кода".
{ cmp/vssrevis.i }

DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-msg as character no-undo .
DEFINE VARIABLE v-main-b-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE VARIABLE v-attr-type as character no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-prod-bc-glob as logical no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_sys-ctrl for ub.sys-ctrl.
define buffer buf_clients for ub.clients.


{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/gdsoattr.i }


do
on error undo, return error
:

  find first buf_sys-ctrl no-lock .
  assign
  v-db-num = buf_sys-ctrl.db-num
  .

  find first buf_goods No-LOCK where
             buf_goods.gds-code = p-gds-code.
  find first buf_units No-lock where
             buf_units.unit-name = buf_goods.unit-base.
  if lookup({&weight}, buf_units.type) = 0
  and lookup({&pieces}, buf_units.type) = 0
  then do:
    assign
    v-msg = substitute("Товар код товара: &1 не весовой и не штучный", buf_goods.gds-code)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.

  { gbl/gdsbcode.i buf_goods.gds-code ? v-main-b-code }

  find first buf_prod-bc share-lock where
             buf_prod-bc.b-str = p-b-str.
  { gbl/prodbcat.i
    buf_prod-bc
    "'glogbal=request':u"
    l-prod-bc-glob
    no-error
  }
  if error-status:error or
  not l-prod-bc-glob then do:
    assign
    v-msg = substitute("Товар код товара: &1 ДопБК &2 ГЛОБАЛЬНЫЙ", buf_goods.gds-code, buf_prod-bc.b-str)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.

  if lookup({&weight}, buf_units.type) > 0 then do:
    { gbl/prodbcat.i
      buf_prod-bc
      "'weight=request':u"
      l-prod-bc-weight
      no-error
    }
    if error-status:error or
    not l-prod-bc-weight then do:
      assign
      v-msg = substitute("Товар код товара: &1 ДопБК &2 не весовой", buf_goods.gds-code, buf_prod-bc.b-str)
      .
      run log-msg in this-procedure ( input-output (v-msg)).
      return error v-msg.
    end.
  end.
  if lookup({&pieces}, buf_units.type) > 0 then do:
    { gbl/prodbcat.i
      buf_prod-bc
      "'pgweight=request':u"
      l-prod-bc-pgweight
      no-error
    }
    if error-status:error or
    not l-prod-bc-weight then do:
      assign
      v-msg = substitute("Товар код товара: &1 ДопБК &2 не штучный для весов", buf_goods.gds-code, buf_prod-bc.b-str)
      .
      run log-msg in this-procedure ( input-output (v-msg)).
      return error v-msg.
    end.
  end.

  if buf_prod-bc.b-code <>  v-main-b-code then do:
    assign
    v-msg = substitute("Товар код товара: &1 не имеет ДопБК &2"
                        ,buf_goods.gds-code
                       ,buf_prod-bc.b-str)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.
  if buf_prod-bc.bc-on = false
  and p-action = "off"
  then do:
    assign
    v-msg = substitute("Товар код товара: &1 ДопБк &2 уже выключен"
                       ,buf_goods.gds-code
                       ,buf_prod-bc.b-str)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.
  if buf_prod-bc.bc-on = true
  and p-action = "del"
  then do:
    assign
    v-msg = substitute("Товар код товара: &1 ДопБк &2 еще не выключен"
                      , buf_goods.gds-code
                       ,buf_prod-bc.b-str)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.

  for each buf_clients no-lock where
          buf_clients.db-num = v-db-num:
    assign
    v-deleted = no
    .
    run gdsoattr-value in this-procedure (
     input  {&attr-scales-code-o}
    ,input buf_goods.gds-code
    ,input buf_clients.obj-type
    ,input buf_clients.obj-code
    ,output v-attr-value
    ,output v-attr-type
    ).
    if v-attr-value = p-b-str then do:
      find first buf_scales-gds No-lock where
                buf_scales-gds.b-code = v-main-b-code
            and buf_scales-gds.obj-type = buf_clients.obj-type
            and buf_scales-gds.obj-code = buf_clients.obj-code
            AND buf_scales-gds.db-num = v-db-num
                no-error .
      if available buf_scales-gds then do:
        assign
        v-msg = substitute("Товар код товара: &1 есть товар на весах &2 БД № &3 &4&5"
                          , buf_goods.gds-code
                          , buf_scales-gds.scales-num
                          , buf_scales-gds.db-num
                          , buf_scales-gds.obj-type
                          , buf_scales-gds.obj-code
                          )
        .
        run log-msg in this-procedure ( input-output (v-msg)).
        return error v-msg.
      end.
        run gdsoattr-delete in this-procedure (
      input buf_goods.gds-code
      ,input buf_clients.obj-type
      ,input buf_clients.obj-code
      ,input {&attr-scales-code-o}
      ,output v-deleted
      ).
      if not v-deleted then do:
         /*не смогли стереть*/
        assign
        v-msg = substitute("Товар код товара: &1 объект: &2 &3 не удалось удалить атрибут товара на объекте &4"
                          ,buf_goods.gds-code
                          ,buf_clients.obj-type
                          ,buf_clients.obj-code
                          ,{&attr-scales-code-o})
        .
        run log-msg in this-procedure ( input-output (v-msg)).
        return error v-msg.
      end.
    end. /*в этом магазине взвешивалос именно по этому prod-bc*/
  end. /*for each buf_clients*/
  /*тепрь можно выключить prod-bc*/
  run trg/bc-upd.p (
                input parparentproc
               ,input buf_prod-bc.b-code
               ,input buf_prod-bc.b-str
               ,input no /*выключить*/
               ,input p-silence
               ,input yes /*send-ref*/
               ,input ?
               ,input ?
              ) no-error.
  if error-status:error then do:
    assign
    v-msg = substitute("Товар код товара: &1 лок. вес. код: &2 не удалось выключить"
                       , buf_goods.gds-code
                       , buf_prod-bc.b-str)
    .
    run log-msg in this-procedure ( input-output (v-msg)).
    return error v-msg.
  end.
  assign
  v-msg = substitute("Товар код товара: &1 лок. вес. код:  &2 успешно выключен"
                   ,buf_goods.gds-code
                   ,buf_prod-bc.b-str)

  .
  run log-msg in this-procedure ( input-output (v-msg)).
end. /*doe*/


procedure log-msg :
define input-output parameter p-msg as character no-undo .

  do
  on error undo, return error
  :

    if not p-silence then do:
      message
      p-msg
      view-as alert-box error .
    end.
    p-msg = substitute("&1&2&3"
                         , return-value
                         , {&new-line}
                         , p-msg).
  end.
end procedure. /* err-msg */
