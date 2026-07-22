block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0010.p $
$Archive: utl/mig_0010.p $

Модификация тфблиц о БД

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0010.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0010.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц о БД".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Базы данных") ).

on write of ub.db           override do: end .
on write of ub.db-attr      override do: end .
on write of ub.db-rec-attr  override do: end .
on write of ub.db-status    override do: end .
on write of ub.sys-ctrl     override do: end .
on write of ub.hist-nws-option override do: end.
on write of ub.c-hist-nws-option override do: end.

on delete of ub.db           override do: end .
on delete of ub.db-attr      override do: end .
on delete of ub.db-rec-attr  override do: end .
on delete of ub.db-status    override do: end .
on delete of ub.hist-nws-option override do: end.
on delete of ub.c-hist-nws-option override do: end.

  do
  on error undo, return error return-value
  :
  find first ub.sys-ctrl exclusive-lock.
             ub.sys-ctrl.db-num = 0 .

    for each ub.db exclusive-lock WHERE
            ub.db.db-num <> p-db-num :
            for each ub.db-attr exclusive-lock where
                     ub.db-attr.db-num    = ub.db.db-num :
                     delete ub.db-attr.
            end.
            for each ub.db-rec-attr exclusive-lock where
                     ub.db-rec-attr.db-num    = ub.db.db-num :
                     delete ub.db-rec-attr.
            end.
            for each ub.db-status exclusive-lock where
                     ub.db-status.db-num    = ub.db.db-num :
                     delete ub.db-status.
            end.

            delete ub.db.

    end.
    for each ub.db no-lock
             :
            for each ub.db-attr exclusive-lock where
                     ub.db-attr.db-num    = ub.db.db-num  :
                     ub.db-attr.db-num = 0 .
            end.
            for each ub.db-rec-attr exclusive-lock where
                     ub.db-rec-attr.db-num    = ub.db.db-num :
                     ub.db-rec-attr.db-num = 0 .
            end.
            for each ub.db-status exclusive-lock where
                     ub.db-status.db-num    = ub.db.db-num :
                     ub.db-status.db-num = 0 .
            end.
    end.
    for each ub.db exclusive-lock
             :
            ub.db.db-num = 0 .
    end.
    /*опции истории и маршрутизации оставляем из ГБД - как правильные!*/
    for each ub.hist-nws-option exclusive-lock :
      if ub.hist-nws-option.db-num > 0 then delete ub.hist-nws-option.
    end.
    for each ub.c-hist-nws-option exclusive-lock :
      if ub.c-hist-nws-option.db-num > 0 then delete ub.c-hist-nws-option.
    end.

end.