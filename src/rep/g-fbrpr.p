block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-fbrpr.p $
$Archive: rep/g-fbrpr.p $

Отчет по промежуточным ингредиентам производства.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-fbrpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-fbrpr.p $":U .
define variable vss-description as character no-undo init "Отчет по промежуточным ингредиентам производства.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i     }
{ cmp/r-page1.i new }

do
on error undo, return error
:
    run rep/d-report.w (
          input p-mainmenu-handle
        , input substitute( "rep/r-fbrpr.p &1,&2":U, p-obj-type, p-obj-code )
        , input "Промежуточные ингредиенты производства"
        , input 2
        , input "":U
        , input "":U
        , input "":U
        , input "{&v-rubl},{&v-base}":U
        , input "":U
        , input yes
    ).
end.