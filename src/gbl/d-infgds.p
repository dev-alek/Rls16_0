block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: d-infgds.p $
$Archive: gbl/d-infgds.p $

Подробная информация о товаре для разработчиков

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: d-infgds.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/d-infgds.p $":U .
define variable vss-description as character no-undo initial "Подробная информация о товаре для разработчиков".
{ cmp/vssrevis.i }
{ cmp/library.i  }

define buffer buf_goods for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .

define variable v-bad-gds as logical   no-undo .
define variable v-message as character no-undo .

do
on error undo, return error return-value
:

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Товар не найден" skip
      "Код товара" p-gds-code skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable v-artic     as character no-undo .
  define variable v-prod-type as character no-undo .
  define variable v-prod-code as integer   no-undo .

  assign
    v-artic     = buf_goods.artic
    v-prod-type = buf_goods.prod-type
    v-prod-code = buf_goods.prod-code
  .

  find first buf_gds-obj exclusive-lock
    where buf_gds-obj.obj-type  = p-obj-type
      and buf_gds-obj.obj-code  = p-obj-code
      and buf_gds-obj.artic     = v-artic
      and buf_gds-obj.prod-type = v-prod-type
      and buf_gds-obj.prod-code = v-prod-code
    no-error .
  if available buf_gds-obj
  then do:
    { gbl/gdscheck.i
      p-obj-type
      p-obj-code
      v-artic
      v-prod-type
      v-prod-code
      ?
      "'return'"
      no-error
    }
    if error-status :error
    then do:
      assign
        v-bad-gds = true
      .
      assign
        v-message = return-value
      .
    end.
  end.

  if v-bad-gds
  then do:
    message
      "Код товара" p-gds-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Объект" p-obj-type p-obj-code skip
      "Товар испорчен" skip
      v-message skip
      view-as alert-box error .
  end.
  else do:
    message
      "Код товара" p-gds-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Объект" p-obj-type p-obj-code skip
      "Товар целостный"
      view-as alert-box information .
  end.
end.