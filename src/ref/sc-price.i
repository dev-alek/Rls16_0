/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция получения цены для справочника весовых товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-price RETURNS decimal
  (buffer loc-good for ub.goods,  shop-type as char , shop-code as integer, bcode as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  находит цену
    Notes:
------------------------------------------------------------------------------*/
define variable scale-price as decimal no-undo.
define buffer buf_shop  for ub.shop.

  { str/get-pr.i calc shop-type shop-code loc-good.gds-code ? "return ?." }

  if  gp-price-sale <> ? then do:
    define variable l-in-ov as logical no-undo .
    { gbl/gdsobjat.i
      shop-type
      shop-code
      loc-good.artic
      loc-good.prod-type
      loc-good.prod-code
      '"in-ov=request"'
      l-in-ov
      no-error
      }
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка получения признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    find first buf_shop no-lock where buf_shop.obj-code = shop-code .
    if not (buf_shop.in-ov AND l-in-ov) then do:
      /* существует цена и товар не находится в переоценке */
      assign
        scale-price = gp-price-sale
      .
    end.
    else do:
      assign
        scale-price = ?
      .
    end.
  end.
  else do:
    assign
      scale-price = ?
    .
  end.


  RETURN scale-price.   /* Function return value. */

END FUNCTION.

/* $Workfile$ e n d */