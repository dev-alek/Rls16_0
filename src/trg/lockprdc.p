block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Наложение блокировки на все товары переоценки

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
define input parameter p-doc-num like ub.price-doc.doc-num no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Наложение блокировки на все товары переоценки".
{ cmp/vssrevis.i "substitute('&1',p-doc-num)" }
{ cmp/library.i }

define buffer buf_price-list for ub.price-list .
define buffer buf_gds-obj  for ub.gds-obj .

main-block :
do transaction
on error undo main-block, return error
:
  for each buf_price-list no-lock
    where buf_price-list.doc-num    = p-doc-num
      and buf_price-list.main-price = true
  on error undo main-block, return error
  :
    { gbl/gdsobjcr.i
      buf_price-list.obj-type
      buf_price-list.obj-code
      buf_price-list.artic
      buf_price-list.prod-type
      buf_price-list.prod-code
      buf_gds-obj
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно найти gds-obj" skip
        "Объект" buf_price-list.obj-type buf_price-list.obj-code skip
        "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box.
      undo main-block, return error .
    end.

    find current buf_gds-obj exclusive-lock .
    release buf_gds-obj .

    /* проверяем целостность товара */
    { gbl/gdscheck.i
      buf_price-list.obj-type
      buf_price-list.obj-code
      buf_price-list.artic
      buf_price-list.prod-type
      buf_price-list.prod-code
      ?
      "''"
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "Объект" buf_price-list.obj-type buf_price-list.obj-code skip
        "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
        error-status :get-message(1) skip
        view-as alert-box .
      undo main-block, return error .
    end.
  end.
end.