block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prowstar.p $
$Archive: gbl/prowstar.p $

Запуск процедуры просмотра сессий Progress

Автор: Перваков Михаил Сергеевич
Дата создания: 06/06/03
Author: Mikhail Pervakov
Creation date: 06/06/03

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prowstar.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/prowstar.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
create widget-pool .
define var w-prowstar as widget-handle no-undo.
create window w-prowstar assign
        title              = "Сессии PROGRESS"
        column             = 2
        row                = 2
        height             = 1
        width              = 30
        resize             = false
        scroll-bars        = false
        status-area        = false
        three-d            = true
        message-area       = false
        sensitive          = true
        visible            = true
        .

assign
  current-window = w-prowstar
.

run gbl/prwnshow.p .
quit .