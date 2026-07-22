block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-syscnf.p $
$Archive: utl/del-syscnf.p $

Удаление объектов из sysconf

Автор: Шальнев Иван Сергеевич
Дата создания: 4/10/11
Author: Shalnev Ivan
Creation date: 4/10/11

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-syscnf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-syscnf.p $":U .
define variable vss-description as character no-undo init "Удаление объектов из sysconf".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
DISABLE TRIGGERS FOR LOAD OF sysconf.

FOR EACH sysconf EXCLUSIVE-LOCK :
  IF NOT CAN-FIND (FIRST clients WHERE clients.obj-code = sysconf.host-code
  AND clients.obj-type = {&cmp}) THEN DO:
    DELETE sysconf.
  END.
END.