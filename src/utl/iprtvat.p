block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: iprtvat.p $
$Archive: utl/iprtvat.p $

Инициализация процента НДС в партиях в сооветствии с текущим НДС

Автор: Суслов Алексей Юрьевич
Дата создания: 04/13/06
Author: Alexey Suslov
Creation date: 04/13/06


*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: iprtvat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/iprtvat.p $":U .
define variable vss-description as character no-undo init "Инициализация процента НДС в партиях в сооветствии с текущим НДС".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/temphost.i }

run init-temphost .


{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i get }
{ gbl/userobjs.i }

run str/gds-list.w
  (input parparentproc
  ,input v-cntxt-host-code-obj
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ) .

define variable lok as logical no-undo init false .

message
  "Проинициализировать партии свобоной и расходной зон для выбранных товаров." skip
  "значениями НДС из справочника товаров"
  "Да - все объекты" skip
  "Нет - выбрать объекты" skip
  view-as alert-box question buttons yes-no-cancel update lok
  .

if lok = ? then do:
  return .
end.

if lok = true then do:
  for each temp-obj
  :
    run initialise-parts-vat-pc
      (input temp-obj.obj-type
      ,input temp-obj.obj-code
      ).
  end.
end.

if lok = false
then do:


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
  on error undo, return error return-value
  :
    run initialise-parts-vat-pc
      (input buf_userobjs_temp-user-obj.obj-type
      ,input buf_userobjs_temp-user-obj.obj-code
      ).
  end.
end.


procedure initialise-parts-vat-pc :
  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

  define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
  define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
  define variable v-host-code     like ub.sysconf.host-code  no-undo.

  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }

  for each gds-list
  :
    find first ub.goods no-lock
      where ub.goods.artic     = gds-list.artic
        and ub.goods.prod-type = gds-list.prod-type
        and ub.goods.prod-code = gds-list.prod-code
      .

    find first ub.gds-obj exclusive-lock
      where ub.gds-obj.obj-type  = p-obj-type
        and ub.gds-obj.obj-code  = p-obj-code
        and ub.gds-obj.artic     = ub.goods.artic
        and ub.gds-obj.prod-type = ub.goods.prod-type
        and ub.gds-obj.prod-code = ub.goods.prod-code
      no-error .

    /* зарезервированные партии не изменяются */
    for each ub.parts
      where ub.parts.obj-type     = p-obj-type
        and ub.parts.obj-code     = p-obj-code
        and ub.parts.artic        = ub.goods.artic
        and ub.parts.prod-type    = ub.goods.prod-type
        and ub.parts.prod-code    = ub.goods.prod-code
        and ub.parts.status_      = no
        and (ub.parts.rsrv-free   = yes
             or ub.parts.rsrv-free = no
            )
    :
      { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code v-vat-pc no-error }
      assign
      ub.parts.VAT-pc = v-vat-pc
      .
    end.
  end.

end procedure. /* initialise-parts-vat-pc */