block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rundcdel.p $
$Archive: utl/rundcdel.p $

Çàïóñê óòèëèòû ÎÊÎÍ×ÀÒÅËÜÍÎÃÎ ÓÄÀËÅÍÈß ÄÊ

Àâòîğ: Áàõòàäçå Íàòàëüÿ Âèêòîğîâíà
Äàòà ñîçäàíèÿ: 05/12/06
Author: Bakhtadze Natalya
Creation date: 05/12/06

*/

define input parameter parparentproc as widget-handle.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rundcdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rundcdel.p $":U .
define variable vss-description as character no-undo init "Çàïóñê óòèëèòû ÎÊÎÍ×ÀÒÅËÜÍÎÃÎ ÓÄÀËÅÍÈß ÄÊ".
{ cmp/vssrevis.i }

run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'utl/dc-del.p':U
                , input '':U
                , input no /*p-auto-go*/
                , input 'Ïğåğâàòü'
                , input 'ÎÊÎÍ×ÀÒÅËÜÍÎÅ ÓÄÀËÅÍÈÅ ÍÅÈÑÏÎËÜÇÎÂÀÍÍÛÕ È ÎØÈÁÎ×ÍÎ ÂÂÅÄÅÍÍÛÕ ÄÈÑÊÎÍÒÍÛÕ ÊÀĞÒ') no-error .