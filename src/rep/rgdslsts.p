block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rgdslsts.p $
$Archive: rep/rgdslsts.p $

Печать списка scn-list

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/04
Author: Bakhtadze Natalya
Creation date: 06/24/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-sorttype as character no-undo .
define input parameter p-classify as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: rgdslsts.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/rgdslsts.p $":U .
def var vss-description as character no-undo init "Печать списка scn-list".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/gds-list.i scn-list def shared }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/wt-zap.i   }
{ ref/gdsoattr.i }
{ gbl/waitfram.i }

{ rep/rgdslst0.i scn-list }