/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

УТД/UTD документы

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_utd                    for ub.utd.
define buffer buf_utd-attr               for ub.utd-attr.
define buffer buf_utd-lines              for ub.utd-lines.
define buffer buf_utd-lines-attr         for ub.utd-lines-attr.
define buffer buf_utd-marking-lines      for ub.utd-marking-lines.
define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
define buffer buf_utd-err                for ub.utd-err.
define buffer buf_utd-err-attr           for ub.utd-err-attr.
define buffer buf_marking                for ub.marking.
define buffer buf_marking-attr           for ub.marking-attr.


define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
define variable v-send-to-cash as logical no-undo .
define variable gtin           as character no-undo.

for each locb-utd
on error  undo, return error
:
  delete locb-utd.
end.


for each locb-utd-lines
on error  undo, return error
:
  delete locb-utd-lines.
end.

for each locb-utd-marking-lines
on error  undo, return error
:
  delete locb-utd-marking-lines.
end.

for each locb-utd-err
on error  undo, return error
:
  delete locb-utd-err.
end.

for each locb-marking
on error  undo, return error
:
  delete locb-marking.
end.

for each locb-utd-attr
on error  undo, return error
:
  delete locb-utd-attr.
end.


for each locb-utd-lines-attr
on error  undo, return error
:
  delete locb-utd-lines-attr.
end.

for each locb-utd-marking-lines-attr
on error  undo, return error
:
  delete locb-utd-marking-lines-attr.
end.

for each locb-utd-err-attr
on error  undo, return error
:
  delete locb-utd-err-attr.
end.

for each locb-marking-attr
on error  undo, return error
:
  delete locb-marking-attr.
end.
