/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/24/06
Author: Michael Kochetkov
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

define buffer buf_c-schet-fact-line for ub.c-schet-fact-line.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-c-schet-fact-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-schet-fact-line.
end.
