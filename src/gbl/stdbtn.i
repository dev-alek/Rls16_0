/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Стандартное действие, которое происходит при выборе кнопки.

Автор: Перваков Михаил Сергеевич
Дата создания: 05/02/00
Author: Mikhail Pervakov
Creation date: 05/02/00



Решаемая задача:
  Передать фокус кнопке с тем чтобы сработали триггеры on leave, on row-leave
  других объектов в окне
Если фокус не передался, то происходит возврат из триггера

Использование в составе триггера на нажатие кнопки:
  { gbl/stdbtn.i }

Использование в составе триггера на выбор пункта меню:
  { gbl/stdbtn.i object-name }
  { gbl/stdbtn.i object-name "in frame {&frame-name}" }

  Где object-name, например, имя родительской кнопки

  Если указан только один параметр, то второй принимает значение
   in frame {&frame-name}
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "" &then
  &scop stdbtn-apply-entry self
&else
  &scop stdbtn-apply-entry {1}

  &if "{2}" = "" &then
    &scop stdbtn-frame-name in frame {&frame-name}
  &else
    &scop stdbtn-frame-name {2}
  &endif
&endif

if lookup({&stdbtn-apply-entry} :type {&stdbtn-frame-name}
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name {&stdbtn-frame-name} skip
    "Тип" self :type {&stdbtn-frame-name} skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to {&stdbtn-apply-entry} {&stdbtn-frame-name} .
  if focus :handle <> {&stdbtn-apply-entry} :handle {&stdbtn-frame-name} then do:
    return no-apply .
  end.
end.

/* $Workfile$ e n d */