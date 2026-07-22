/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/13/03 11:44


*/

/* Цена продажи рассчитанная без округления по формату >>>>>>>9.99                                          */
/* "full-price-sale":U - полное не округленное значение поля ub.price-list.price-sale                          */
/*                      рассчитано для автоматических переоценок , нужен для проверки интервала наценки.     */
/*                      иначе процент наценки рассчитывается не точно.                                        */
&glob full-price-sale  'full-price-sale':U


/* Средняя учетная цена по товару на объекте на момент закрытия переоценки                                  */
&glob cost-price-fact  'cost-price-fact':U


procedure create-price-list-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define input parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.



find first buf_price-list-attr  exclusive-lock  where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if not available  buf_price-list-attr then do:
      create buf_price-list-attr.
      assign
        buf_price-list-attr.attr-code    = p-attr-code
        buf_price-list-attr.attr-value   = p-attr-value
        buf_price-list-attr.b-code       = p-b-code
        buf_price-list-attr.doc-num      = p-doc-num
        buf_price-list-attr.price-type   = p-price-type
      .

  end.
  else do:
        buf_price-list-attr.attr-value   = p-attr-value .
  end.
 end. /* do */
end procedure. /* create-price-list-attr */



procedure view-price-list-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input  parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input  parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input  parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define output parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .

define buffer buf_price-list-attr for ub.price-list-attr.


find first buf_price-list-attr no-lock where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if available  buf_price-list-attr then do:
      assign
        p-attr-value = buf_price-list-attr.attr-value

      .
  end.
  else do:
        p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* view-price-list-attr */

procedure pdoc-forming-attr :

define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db       as integer   no-undo .
define input  parameter p-attr-code    as character no-undo .
define input  parameter p-val          as character no-undo .

  do
  on error undo, return error return-value
  :

  find first  ub.price-doc-forming-attr exclusive-lock where
              ub.price-doc-forming-attr.plt-id       = p-plt-id       and
              ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
              ub.price-doc-forming-attr.pdf-db       = p-pdf-db       and
              ub.price-doc-forming-attr.attr-code    = p-attr-code
              no-error .
    if not available  ub.price-doc-forming-attr then create ub.price-doc-forming-attr.
    assign
      ub.price-doc-forming-attr.plt-id       = p-plt-id
      ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num
      ub.price-doc-forming-attr.pdf-id       = p-pdf-id
      ub.price-doc-forming-attr.pdf-db       = p-pdf-db
      ub.price-doc-forming-attr.attr-code    = p-attr-code
      ub.price-doc-forming-attr.attr-value   = p-val
    .

  end.

end procedure. /* pdoc-forming-attr */


/* $Workfile$ e n d */