block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывести информацию о товаре на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

p-action :
  ov-on  - выдача сообщение о переоценке, в которую входит товар

*/

define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
define input  parameter p-artic            like ub.gds-obj.artic     no-undo .
define input  parameter p-prod-type        like ub.gds-obj.prod-type no-undo .
define input  parameter p-prod-code        like ub.gds-obj.prod-code no-undo .
define input  parameter p-action           as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вывести информацию о товаре на объекте".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

case p-action :

  when "ov-on" then do:
    define buffer buf_goods      for ub.goods .
    define buffer buf_price-doc  for ub.price-doc .
    define buffer buf_price-list for ub.price-list .

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    for each buf_price-doc no-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_  = {&permitted}
    ,first buf_price-list no-lock
      where buf_price-list.doc-num   = buf_price-doc.doc-num
        and buf_price-list.artic     = p-artic
        and buf_price-list.prod-type = p-prod-type
        and buf_price-list.prod-code = p-prod-code
    on error undo, return error
    :
      message
        "Для товара сейчас идет переоценка" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        "Переоценка" buf_price-doc.doc-num skip
        "Включить переоценку невозможно."
        view-as alert-box .
      return . /* --->>>--- */
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Установлен признак того, что для товара идет переоценка" skip
      "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
      buf_goods.gds-name skip
      "Переоценка в статусе" {&permitted} "не найдена" skip
      view-as alert-box error .
  end.

  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-action " skip
      "p-action" p-action skip
      view-as alert-box error .
    undo, return error .
  end.
end.