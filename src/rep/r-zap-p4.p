block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zap-p4.p $
$Archive: rep/r-zap-p4.p $

ÎÒ×ÅÒ Î ÑÎÑÒÎßÍÈÈ ÇÀÏÀÑÀ È ÏĞÎÄÀÆÀÕ

Àâòîğ: Äåìèí Àëåêñåé Ñåğãååâè÷
Äàòà ñîçäàíèÿ: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
define var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define var vss-author      as character no-undo init "$Author: expertek $":U .
define var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define var vss-workfile    as character no-undo init "$Workfile: r-zap-p4.p $":U .
define var vss-archive     as character no-undo init "$Archive: rep/r-zap-p4.p $":U .
define var vss-description as character no-undo init "ÎÒ×ÅÒ Î ÑÎÑÒÎßÍÈÈ ÇÀÏÀÑÀ È ÏĞÎÄÀÆÀÕ".
{ cmp/vssrevis.i }

{ rep/r-zap-pr.i base gds-list }