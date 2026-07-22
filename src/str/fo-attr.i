/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты ФО

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/13/03 11:44

*/


/* Дата инкрементальной выгрузки ФО */
&glob fo-bge-date  'bge-date':U


procedure create-fin-ob-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-ob-attr.host-code  no-undo .
define input parameter p-doc-code      like ub.fin-ob-attr.doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-ob-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-ob-attr.attr-value no-undo .


define buffer buf_fin-ob-attr for ub.fin-ob-attr.



find first buf_fin-ob-attr  exclusive-lock  where
  buf_fin-ob-attr.attr-code    = p-attr-code    and
  buf_fin-ob-attr.host-code    = p-host-code    and
  buf_fin-ob-attr.doc-code     = p-doc-code  no-error .
  if not available  buf_fin-ob-attr then do:
      create buf_fin-ob-attr.
      assign
        buf_fin-ob-attr.attr-code    = p-attr-code
        buf_fin-ob-attr.attr-value   = p-attr-value
        buf_fin-ob-attr.host-code    = p-host-code
        buf_fin-ob-attr.doc-code     = p-doc-code
      .

  end.
  else do:
        buf_fin-ob-attr.attr-value   = p-attr-value .
  end.
 end. /* do */
end procedure. /* create-fin-ob-attr */



procedure view-fin-ob-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-ob-attr.host-code    no-undo .
define input  parameter p-doc-code     like ub.fin-ob-attr.doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-ob-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-ob-attr.attr-value   no-undo .

define buffer buf_fin-ob-attr for ub.fin-ob-attr.


find first buf_fin-ob-attr no-lock where
  buf_fin-ob-attr.attr-code    = p-attr-code    and
  buf_fin-ob-attr.doc-code      = p-doc-code      no-error .
  if available  buf_fin-ob-attr then do:
      assign
        p-attr-value = buf_fin-ob-attr.attr-value

      .
  end.
  else do:
        p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* view-fin-ob-attr */


/* $Workfile$ e n d */