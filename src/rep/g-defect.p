block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-defect.p $
$Archive: rep/g-defect.p $

Отчет по ФиБ

Автор: Чернова Светлана Александровна
Дата создания: 11/20/09
Author: Svetlana Chernova
Creation date: 11/20/09


*/

define input parameter p-mainmenu-handle as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-defect.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-defect.p $":U .
define variable vss-description as character no-undo init "Отчет по ФиБ".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/r-page1.i new }

do
on error undo, return error
:
define variable v-date1 as date   no-undo .

v-date1 = date( month(today) , day(today) , year(today) - 1 ).
    run rep/d-report.w (
      input p-mainmenu-handle
    , input "rep/e-defect.w"
    , input "Отчет по фальсифицированным и забракованным партиям"
    , input 2
    , input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-grp-prod}":U
    , input "*"
    , input ""
    , input ""
    , input substitute("all,{&format-folder},{&Excel-yes},{&customer-yes},X-DATE-START=&1,X-CUSTOMER-NAME=Выбор Поставщиков", string( v-date1, "99/99/9999" ))
    , input no
    ).
end.