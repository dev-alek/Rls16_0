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
define buffer buf_c-ord-line     for ub.c-ord-line.


def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-ord-line
on error  undo, return error
:
  delete locb-c-ord-line.
end.
