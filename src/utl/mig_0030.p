block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0030.p $
$Archive: utl/mig_0030.p $

Модификация тфблиц  раздела Бар-коды Кассы

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0030.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0030.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Кассы".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Кассы") ).

on write of ub.cash-desk       override do: end .
on write of ub.cash-desk-attr  override do: end .
on delete of ub.cash-desk      override do: end .
on delete of ub.cash-desk-attr override do: end .
on delete of ub.c-cash-desk      override do: end .
on delete of ub.c-cash-desk-attr override do: end .


  do
  on error undo, return error return-value
  :
    for each ub.cash-desk exclusive-lock WHERE
            ub.cash-desk.db-num <> p-db-num :
            for each ub.cash-desk-attr exclusive-lock where
                      ub.cash-desk-attr.cash-num  = ub.cash-desk.cash-num  and
                      ub.cash-desk-attr.db-num    = ub.cash-desk.db-num    and
                      ub.cash-desk-attr.obj-code  = ub.cash-desk.obj-code  and
                      ub.cash-desk-attr.pos-type  = ub.cash-desk.pos-type  :
                     for each ub.c-cash-desk-attr exclusive-lock where
                              ub.c-cash-desk-attr.cash-num  = ub.cash-desk-attr.cash-num  and
                              ub.c-cash-desk-attr.db-num    = ub.cash-desk-attr.db-num    and
                              ub.c-cash-desk-attr.obj-code  = ub.cash-desk-attr.obj-code  and
                              ub.c-cash-desk-attr.pos-type  = ub.cash-desk-attr.pos-type and
                              ub.c-cash-desk-attr.attr-code = ub.cash-desk-attr.attr-code
                     :
                         delete ub.c-cash-desk-attr.
                     end.
                     delete ub.cash-desk-attr.
            end.
            for each ub.c-cash-desk exclusive-lock where
                    ub.c-cash-desk.cash-num  = ub.cash-desk.cash-num  and
                    ub.c-cash-desk.db-num    = ub.cash-desk.db-num    and
                    ub.c-cash-desk.obj-code  = ub.cash-desk.obj-code  and
                    ub.c-cash-desk.pos-type  = ub.cash-desk.pos-type
            :
                delete ub.c-cash-desk.
            end.

            delete ub.cash-desk.
    end.

    for each ub.cash-desk no-lock
             :
            for each ub.cash-desk-attr exclusive-lock where
                     ub.cash-desk-attr.cash-num  = ub.cash-desk.cash-num  and
                     ub.cash-desk-attr.db-num    = ub.cash-desk.db-num    and
                     ub.cash-desk-attr.obj-code  = ub.cash-desk.obj-code  and
                     ub.cash-desk-attr.pos-type  = ub.cash-desk.pos-type  :

                     ub.cash-desk-attr.db-num = 0 .
            end.
    end.

    for each ub.cash-desk exclusive-lock
             :
            ub.cash-desk.db-num = 0 .
    end.


end.