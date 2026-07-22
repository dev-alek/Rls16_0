/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перемещение по документам next, prev

Автор: Чернова Светлана Александровна
Дата создания: 03/01/07
Author: Svetlana Chernova
Creation date: 03/01/07

create: Суслов Алексей Юрьевич


*/
&if "{&bf-trn-doc}" = "" &then
&scop bf-trn-doc t-doc
&endif
&if "{&doc-rec}" = "" &then
&scop doc-rec doc-rec
&endif

ON CHOOSE OF b-next IN FRAME {&frame-name}
DO:
  RUN step-next in this-procedure .
END.

procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .

case {&bf-trn-doc}.doc-type:
  when {&income} then
    cur-form = if {&bf-trn-doc}.internal then {&expense} else {&income}.
  when {&expense} or when {&return} or when {&write-off} then
    cur-form = {&expense}.
  when {&inventory} then cur-form = {&inventory}.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .

  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when {&income} then
    new-form = if new_trn-doc.internal then {&expense} else {&income}.
  when {&expense} or when {&return} or when {&write-off} then
    new-form = {&expense}.
  when {&inventory} then new-form = {&inventory}.
end case.
assign
    {&doc-rec}   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case {&bf-trn-doc}.doc-type:
  when {&income} then if {&bf-trn-doc}.internal then cur-form = {&expense}. else cur-form = {&income}.
  when {&expense} or when {&return} or when {&write-off} then cur-form = {&expense}.
  when {&inventory} then cur-form = {&inventory}.
end case.

if bf-handle = ? then return .

if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.

case new_trn-doc.doc-type :
  when {&income} then if new_trn-doc.internal then new-form = {&expense}. else new-form = {&income}.
  when {&expense} or when {&return} or when {&write-off} then  new-form = {&expense}.
  when {&inventory} then new-form = {&inventory}.
end case.
assign
  {&doc-rec}   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
/* n - p - l . i */