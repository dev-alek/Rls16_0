/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/22/08
Author: Svetlana Chernova
Creation date: 04/22/08


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*
attr-code  = "obj"типкод  -список объектов  для исключени
attr-code  = pricedocI  шапка расчета нового ДНЦ

*/
&glob pdf-pricedocI  'pricedocI'




procedure del-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .


define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .

      if available buf_price-doc-forming-attr then do:
         delete buf_price-doc-forming-attr .
      end.
  end.

end procedure. /* del-pdf-attr-objdel */

procedure ins-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .


define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .

      if not available  buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             buf_price-doc-forming-attr.attr-value = ""
         .
      end.
  end.

end procedure. /* ins-pdf-attr-objdel */

procedure ex-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-exist      as logical   no-undo .


define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.

end procedure. /* ex-pdf-attr-objdel */


procedure pdf-exist :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define output parameter p-exist      as logical   no-undo .


define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.
end procedure.

procedure pdf-write :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .

define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .

  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .

      if not available buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = p-attr-code
         .
      end.
      buf_price-doc-forming-attr.attr-value = p-attr-value .

  end.

end procedure. /* pdf-write */

procedure pdf-value :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code  as character no-undo .
define output parameter p-attr-value as character no-undo .

define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-attr-value = "" .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-attr-value = buf_price-doc-forming-attr.attr-value .
      end.

  end.

end procedure. /* pdf-value */