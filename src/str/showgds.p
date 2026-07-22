block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showgds.p $
$Archive: str/showgds.p $

Показать или редактировать товар

Автор: Перваков Михаил Сергеевич
Дата создания: 06/26/00
Author: Mikhail Pervakov
Creation date: 06/26/00

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-gds-code    as integer   no-undo .
define input parameter p-mode        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/showgds.p $":U .
define variable vss-description as character no-undo init "Показать или редактировать товар".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-gds-code,p-mode)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable v-gds-rec as recid no-undo .

do
on error undo, return error return-value
:
  define variable loc#log as logical no-undo .
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден товар" skip
      "Код товара" p-gds-code skip
      view-as alert-box error .
    undo, return error .
  end.

  { gbl/getcntxt.i get }

  if p-mode = {&update}
  then do:
    case buf_goods.gds-type
    :
      when {&gds-goods}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update':U
          {&cntxt-global}
          0
          '':U
          0
          0
          buf_goods.grp-code
          0
          true
          loc#log
        }
      end.
      when {&gds-office}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference-services_update':U
          {&cntxt-global}
          0
          '':U
          0
          0
          buf_goods.grp-code
          0
          true
          loc#log
        }
      end.
    end case.

    if not loc#log
    then do:
      undo, return error .
    end.
  end.

  if v-cntxt-level = {&cntxt-object}
  then do:
    assign
    v-gds-rec = recid(buf_goods)
        .
    run ref/gds-form.w
      (input parparentproc
      ,input p-mode
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input p-call-handle
      ,input-output v-gds-rec
      ).
  end.
  else do:
    message
      "Невозможно открыть окно просмотра товара" skip
      "так как не задан текущий объект" skip
      view-as alert-box information .
  end.
end.