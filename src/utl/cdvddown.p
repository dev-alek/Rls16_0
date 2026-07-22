block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdvddown.p $
$Archive: utl/cdvddown.p $

Выгрузка связок событий на кассе с СВ

Автор: Белоусов Илья Александрович
Дата создания: 12/05/08
Author: Ilia Belousov
Creation date: 12/05/08

Input:

Output:

*/
define input        parameter parparentproc as widget-handle  no-undo .
define input-output parameter p-version as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdvddown.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdvddown.p $":U .
define variable vss-description as character no-undo init "Выгрузка связок событий на кассе с СВ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

define buffer bf_cd-video-link      for ub.cd-video-link .
define buffer buf_cd-video-link      for ub.cd-video-link .

define stream st-out .
DEFINE STREAM st-in .

define variable v-str      as character    no-undo.
define variable v-str-enc  as character    no-undo.
define variable v-version    as integer      no-undo.
DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .

do
on error undo, return error
:
   FIND FIRST buf_cd-video-link
        EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF NOT AVAILABLE buf_cd-video-link
   AND LOCKED buf_cd-video-link
   THEN DO:
       RETURN ERROR "Список событий в данный момент выгружает другой пользователь".
   END.

   /* Читаем номер версии в файле,
      если он не совпадает с номером при редактировании,
      то ругаемся    */
   IMPORT STREAM st-in UNFORMATTED
      v-str-enc
      .

   { gbl/pdecrypt.i v-str-enc v-str }
   ASSIGN
      v-version = INTEGER(v-str)
   NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Не верный номер версии &1&2&3" , v-str, {&new-line}, ERROR-STATUS:GET-MESSAGE (1)) .
   END.
   IF v-version > p-version
   THEN DO:
      RETURN ERROR SUBSTITUTE( "В файле номер версии №&1 больше текущей №&2", v-version, p-version) .
   END.

   /* выгружаем */
   output stream st-out to "cmp/cd-video.enc" .

   ASSIGN
      p-version = p-version + 1
      v-str = STRING(p-version)
   .

   { gbl/pencrypt.i v-str v-str-enc }

   PUT stream st-out
         UNFORMATTED v-str-enc .

   ASSIGN
      v-count = 0
   .
   FOR EACH bf_cd-video-link
       no-lock
       :
         ASSIGN
            v-str = SUBSTITUTE( "&1&2&3&4&5"
                              , bf_cd-video-link.event-id
                              , {&delim-par}
                              , bf_cd-video-link.video-id
                              , {&delim-par}
                              , bf_cd-video-link.video-event-id
                              )
         .
         { gbl/pencrypt.i v-str v-str-enc }

         PUT stream st-out
               UNFORMATTED v-str-enc .
         ASSIGN
            v-count = v-count + 1
         .
   END.

   /* количество записей */
   ASSIGN
      v-str = STRING(v-count)
   .

   { gbl/pencrypt.i v-str v-str-enc }

   PUT stream st-out
         UNFORMATTED v-str-enc .

end.