/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает истину, если триггер on-leave сработал по нажатию любой из указанных кнопок

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Необходимо использовать в случае, если пользователю необходимо
покинуть поле без проверок, например, по нажатию кнопки Cancel

Также триггер можно использовать для организации проверки после заведени
группы полей.

Пример:
ON LEAVE OF parts.part-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "b-undo,b-rest,b-help":u
    )
  then do:
    сделать необходимые проверки
  end.
end.

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function chkleave returns logical
(input p-widget-enter as handle
,input p-button-list  as character
).
  if  valid-handle(p-widget-enter)
  and can-query(p-widget-enter, "name":u)
  and lookup(p-widget-enter :name, p-button-list) > 0
  then do:
    return false .
  end.

  return true .

end function.

/* $Workfile$ e n d */