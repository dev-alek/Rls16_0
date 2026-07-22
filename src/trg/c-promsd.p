/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR DELETE OF c-promo-schedule.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления с-promo-schedule". 
{ cmp/vssrevis.i }


  undo, throw new Progress.Lang.AppError(
    substitute(  "&1: Ошибка удаления истории промо-акций (расписание промо-акций)." +
                " Запрещено уделание истории из таблицы c-promo-schedule [id=&2]",
                 vss-workfile, ub.c-promo-schedule.id  )
  ) .
