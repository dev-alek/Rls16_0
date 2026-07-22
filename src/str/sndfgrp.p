block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndfgrp.p $
$Archive: str/sndfgrp.p $

пересылка групп блюд на кассу - пускальник0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
define input parameter mode as char no-undo .

/*"U' "D" */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndfgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sndfgrp.p $":U .
define variable vss-description as character no-undo init "Пересылка групп блюд на кассу - пускальник".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/defc-fgr.i "NEW SHARED" }

 run str/diallog.w (
        input parParentProc
      , input this-procedure
      , input "str/sendfgrp.p":U
      , input (string(i-obj-code) + {&delim-par} + mode)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка групп блюд на кассы магазина &1", i-obj-code)
  ) no-error.