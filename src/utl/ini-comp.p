block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-comp.p $
$Archive: utl/ini-comp.p $

Инициализация поля fbr-line.is-comp

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-comp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-comp.p $":U .
define variable vss-description as character no-undo init "Инициализация поля fbr-line.is-comp".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable ii as integer no-undo .
define variable glog as logical no-undo .
def frame b
ii label "Обработано строк производства"
with side-labels view-as dialog-box.

glog = yes.
message "Инициализация составных товаров / ингридиентов в производстве ?  Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.

view frame b.

ii = 0.
for each ub.fbr-line:
  disp ii with frame b.
  ii = ii + 1.
  find ub.recipe where ub.recipe.recipe-code = ub.fbr-line.recipe-code no-lock no-error.
  if available ub.recipe then
    if ub.recipe.artic = ub.fbr-line.artic and
       ub.recipe.prod-type = ub.fbr-line.prod-type and
       ub.recipe.prod-code = ub.fbr-line.prod-code then
      ub.fbr-line.is-comp = yes.
    else
      ub.fbr-line.is-comp = no.
  else
    if ub.fbr-line.recipe-code = "" then
      if ub.fbr-line.trn-type = {&income} then
        ub.fbr-line.is-comp = yes.
      else
        ub.fbr-line.is-comp = no.
    else do:
      find ub.fbr-doc where ub.fbr-doc.doc-code = ub.fbr-line.doc-code no-lock.
      case ub.fbr-doc.doc-type :
        when {&gathering} then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = {&income}).
        when "разукомплектация" then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = {&write-off}).
        when {&dressing} then
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = {&write-off}).
        when {&manufacturing} then do:
          message "Не найден рецепт с номером:" ub.fbr-line.recipe-code skip
                          "Документ:" ub.fbr-line.doc-code skip
                          "Считаем, что приходные строки соответствуют составным товарам, строки списания - ингридиентам." skip
                          "Это будет неправильно, если в документе производства использован рецепт разделки."
                          view-as alert-box error.
          ub.fbr-line.is-comp = (ub.fbr-line.trn-type = {&income}).
        end.
      end case.
    end.
  process events.
end.

message "Инициализация закончена успешно.".


