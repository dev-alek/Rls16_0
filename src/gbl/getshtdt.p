block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getshtdt.p $
$Archive: gbl/getshtdt.p $

Определение даты конца смены

Автор: Перваков Михаил Сергеевич
Дата создания: 12/16/03
Author: Mikhail Pervakov
Creation date: 12/16/03

Если смена закрыта - то возвращается дата завершения смены .
Если смена открыта - то возвращается текущая дата на объекте .

*/


define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-shift-date as date      no-undo .
define input  parameter p-shift-num  as integer   no-undo .
define output parameter p-fact-date  as date      no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: getshtdt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/getshtdt.p $":U .
define variable vss-description as character no-undo initial "Определение даты конца смены".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_shift-obj for ub.shift-obj .

do
on error undo, return error return-value
:
  find first buf_shift-obj no-lock
    where buf_shift-obj.obj-type   = p-obj-type
      and buf_shift-obj.obj-code   = p-obj-code
      and buf_shift-obj.shift-date = p-shift-date
      and buf_shift-obj.shift-num  = p-shift-num
    no-error .
  if not available buf_shift-obj
  then do:
    undo, return error substitute("Не найдена смена. Объект &1 &2. Смена &3 &4."
                                 ,p-obj-type
                                 ,p-obj-code
                                 ,p-shift-date
                                 ,p-shift-num
                                 ) .
  end.

  if buf_shift-obj.status_ = {&sht-closed}
  then do:
    assign
      p-fact-date = buf_shift-obj.close-date
    .
  end.
  else do:
    { gbl/curobjdt.i
      p-obj-type
      p-obj-code
      p-fact-date
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении даты на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end.