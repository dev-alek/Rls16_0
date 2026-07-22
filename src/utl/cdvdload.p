block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdvdload.p $
$Archive: utl/cdvdload.p $

Загрузка справочника связей событий на кассе с событиями в СВ

Автор: Белоусов Илья Александрович
Дата создания: 12/02/08
Author: Ilia Belousov
Creation date: 12/02/08

Input:

Output:

*/
/* !!! */
define input parameter parparentproc as widget-handle  no-undo .
define input-OUTPUT parameter p-version as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdvdload.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdvdload.p $":U .
define variable vss-description as character no-undo init "Загрузка справочника связей касс с СВ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

define buffer bf_cd-video-link      for ub.cd-video-link .

DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .
/* !!! */
DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .

DEFINE STREAM st-in .

do
TRANSACTION
on error undo, return error
:
   FOR EACH bf_cd-video-link
       EXCLUSIVE-LOCK
       :
       DELETE bf_cd-video-link.
   END.

   INPUT STREAM st-in FROM "cmp/cd-video.enc" .

   SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
   REPEAT:
      ASSIGN
         v-out-string = ""
         v-in-string  = ""
      .

      IMPORT STREAM st-in UNFORMATTED
         v-in-string
         .

      { gbl/pdecrypt.i v-in-string v-out-string }

      RUN load-line ( INPUT v-out-string ) .

   END.

end.


/* ============================================== */
procedure load-line :
define input parameter p-line          as character        no-undo.

define VARIABLE v-event-id       as integer          no-undo .
define VARIABLE v-video-id       as character        no-undo .
define VARIABLE v-video-event-id as character        no-undo .

define buffer buf_cd-video-link      for ub.cd-video-link .

do
on error undo, return error
:
   IF NUM-ENTRIES(p-line, {&delim-par}) < 3
   THEN DO:
      RETURN ERROR "Не хватает параметров " + p-line.
   END.

   ASSIGN
      v-event-id       = INTEGER(ENTRY(1, p-line, {&delim-par}))
      v-video-id       = ENTRY(2, p-line, {&delim-par})
      v-video-event-id = ENTRY(3, p-line, {&delim-par})
   NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Ошибка типов данных &1&2" , {&new-line}, ERROR-STATUS:GET-MESSAGE (1)) .
   END.

   FIND FIRST buf_cd-video-link
        WHERE buf_cd-video-link.event-id        = v-event-id
          AND buf_cd-video-link.video-id        = v-video-id
          AND buf_cd-video-link.video-event-id  = v-video-event-id
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_cd-video-link
   THEN DO:
      RETURN ERROR SUBSTITUTE ( "Уже есть связка: &1&2&3&4&5"
                              , v-video-id
                              , {&new-line}
                              , v-event-id
                              , {&new-line}
                              , v-video-event-id
                              ) .
   END.

   CREATE buf_cd-video-link.
   ASSIGN
      buf_cd-video-link.video-id       = v-video-id
      buf_cd-video-link.event-id       = v-event-id
      buf_cd-video-link.video-event-id = v-video-event-id
   NO-ERROR .
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE(" Ошибка создания записи: &1&2&3&4&5&6"
                              , v-video-id
                              , {&new-line}
                              , v-event-id
                              , {&new-line}
                              , v-video-event-id
                              , error-status :get-message (1)
                              ) .
   END.

   RETURN.

end. /* do on error */
end procedure. /* load-line */