block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.c-PromoGift.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления c-PromoGift".
  undo, throw new Progress.Lang.AppError(
    substitute(  "&1: Ошибка удаления истории промо-акций [&2]." +
                " Запрещено уделание истории из таблицы c-PromoGift [id=&3]",
                 vss-workfile, ub.c-PromoGift.idAction, ub.c-PromoGift.id  )
  ) .
