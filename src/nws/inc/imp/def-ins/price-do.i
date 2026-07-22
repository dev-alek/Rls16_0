/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_price-list      for ub.price-list.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_price-list-attr      for ub.price-list-attr.

def var counter  as   integer            no-undo.
def var rec-full as   character          no-undo.
def var rec-name as   character          no-undo.
def var bar_code like ub.bar-code.b-code no-undo .

define buffer buf_bar-code for ub.bar-code .

for each locb-price-list
on error  undo, return error
:
  delete locb-price-list.
end.

for each locb-doc-attr
on error  undo, return error
:
  delete locb-doc-attr.
end.

for each locb-price-list-attr
on error  undo, return error
:
  delete locb-price-list-attr.
end.