block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdviddel.p $
$Archive: ref/cdviddel.p $

Удаление связки события на кассе с СВ

Автор: Белоусов Илья Александрович
Дата создания: 12/05/08
Author: Ilia Belousov
Creation date: 12/05/08

Input:

Output:

*/
define input  parameter parparentproc as widget-handle  no-undo .
define input  parameter p-id          as integer        no-undo .
define input  parameter p-video-id    as character      no-undo .
define input  parameter p-system-id   as character      no-undo .
define output parameter p-ok          as logical        no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdviddel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cdviddel.p $":U .
define variable vss-description as character no-undo init "Удаление связки события на кассе с СВ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
do
TRANSACTION
on error undo, return error
:
   define buffer buf_cd-video-link      for ub.cd-video-link .
   FIND FIRST buf_cd-video-link
        WHERE buf_cd-video-link.event-id        = p-ID
          AND buf_cd-video-link.video-event-id  = p-video-id
          AND buf_cd-video-link.video-id        = p-system-id
        EXCLUSIVE-LOCK
        .
   DELETE buf_cd-video-link.
   ASSIGN
      p-ok = TRUE
   .
end.