block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docprtob.p $
$Archive: ref/docprtob.p $

Показать обороты по признаку на объекте

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer  no-undo .
define input  parameter p-bar-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: docprtob.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: ref/docprtob.p $":U .
define variable vss-description as character no-undo initial "Показать обороты по признаку на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }
do
on error undo, return error return-value
:
find first ub.gds-obj where  ub.gds-obj.gds-code = p-gds-code and
                          ub.gds-obj.obj-type = p-obj-type and
                          ub.gds-obj.obj-code = p-obj-code
                          no-lock no-error .
define variable t-date as date no-undo .
if ub.gds-obj.first-doc <> ? then t-date = ub.gds-obj.first-doc.
   else t-date = today - 1.


run rep/d-report.w ( input parParentProc ,
input                   "r-iprt.p "    +
                                       "gds-code=" + string(p-gds-code) + ";"  +
                                       "b-code=" + string(p-bar-code)
                                         ,
input                       "Обороты по признаку на объекте",
input                        2,
input                        "":U,
input                        "{&o-currency}":U,
input                        "",
input                        "",
input                        "all,{&Excel-yes},X-DATE-START=" + string(t-date, "99/99/9999"),
input                        yes).
end.