block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0060.p $
$Archive: utl/mig_0060.p $

Модификация таблиц  раздела Опции печати

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0060.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0060.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Опции печати".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Опции печати") ).

on write  of ubflt.rpt-option      override do: end .
on delete of ubflt.rpt-option      override do: end .
  do
  on error undo, return error return-value
  :
    for each ubflt.rpt-option exclusive-lock WHERE
            ubflt.rpt-option.user-db-num <> p-db-num :
            delete ubflt.rpt-option .
    end.
    for each ubflt.rpt-option exclusive-lock WHERE
             ubflt.rpt-option.user-db-num = 0 .
    end.
  end.