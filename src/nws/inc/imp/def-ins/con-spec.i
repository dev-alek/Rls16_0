/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_contract-specif-attr for ub.contract-specif-attr.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-contract-specif-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-contract-specif-attr.
end.