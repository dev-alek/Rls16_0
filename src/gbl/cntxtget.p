block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cntxtget.p $
$Archive: gbl/cntxtget.p $

Получить контекст по умолчанию при входе в систему

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/06

*/

define input  parameter p-cntxt-db-num          as integer   no-undo .
define input  parameter p-cntxt-user-id         as character no-undo .
define output parameter p-cntxt-valid           as logical   no-undo .
define output parameter p-cntxt-menu-code       as integer   no-undo .
define output parameter p-cntxt-menu-group-code as integer   no-undo .
define output parameter p-cntxt-level           as character no-undo .
define output parameter p-cntxt-host-code-obj   as integer   no-undo .
define output parameter p-cntxt-obj-type        as character no-undo .
define output parameter p-cntxt-obj-code        as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cntxtget.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cntxtget.p $":U .
define variable vss-description as character no-undo init "Получить контекст по умолчанию при входе в систему".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_menu-group           for ub.menu-group .
define buffer buf_user-context-history for ubflt.user-context-history .

do
on error undo, return error return-value
:

  find last buf_user-context-history no-lock
    where buf_user-context-history.db-num  = p-cntxt-db-num
      and buf_user-context-history.user-id = p-cntxt-user-id
    no-error .
  if available buf_user-context-history
  then do:
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = buf_user-context-history.cntxt-menu-code
        and buf_menu-group.menu-group-id = buf_user-context-history.cntxt-menu-group-id
      no-error .
    if available buf_menu-group
    then do:
      assign
        p-cntxt-valid           = true
        p-cntxt-level           = buf_user-context-history.cntxt-level
        p-cntxt-host-code-obj   = buf_user-context-history.cntxt-host-code
        p-cntxt-obj-type        = buf_user-context-history.cntxt-obj-type
        p-cntxt-obj-code        = buf_user-context-history.cntxt-obj-code
        p-cntxt-menu-code       = buf_user-context-history.cntxt-menu-code
        p-cntxt-menu-group-code = buf_menu-group.menu-group-code
      .
    end.
    else do:
      assign
        p-cntxt-valid         = false
      .
    end.
  end.
  else do:
    assign
      p-cntxt-valid         = false
    .
  end.
end.