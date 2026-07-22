block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdevdown.p $
$Archive: utl/cdevdown.p $

Выгрузка списка событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 12/04/08
Author: Ilia Belousov
Creation date: 12/04/08

Input:

Output:

*/
define input        parameter parparentproc as widget-handle  no-undo .
define input-output parameter p-base-version as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdevdown.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdevdown.p $":U .
define variable vss-description as character no-undo init "Выгрузка списка событий на кассе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

define buffer bf_cd-events      for ub.cd-events .
define buffer buf_cd-events      for ub.cd-events .

define stream st-out .
DEFINE STREAM st-in .

define variable v-str      as character    no-undo.
define variable v-str-enc  as character    no-undo.
define variable v-file-version    as integer      no-undo.
define variable v-new-version    as integer      no-undo.
DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .

do
on error undo, return error
:
   DO
   TRANSACTION
   :
      FIND LAST buf_cd-events
         EXCLUSIVE-LOCK
         NO-ERROR
         NO-WAIT
         .
      IF NOT AVAILABLE buf_cd-events
      AND LOCKED buf_cd-events
      THEN DO:
         RETURN ERROR "Список событий в данный момент выгружает другой пользователь".
      END.
   END.

   /* Читаем номер версии в файле,
      если он не совпадает с номером при редактировании,
      то ругаемся    */

   input stream st-out from "cmp/cd-event.enc".
   IMPORT STREAM st-in UNFORMATTED
      v-str-enc
      NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-str = "0"
      .
   END.
   ELSE DO:
      input stream st-out close .
      { gbl/pdecrypt.i v-str-enc v-str }
   END.

   ASSIGN
      v-file-version = INTEGER(v-str)
   NO-ERROR.

   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Не верный номер версии &1&2&3" , v-str, {&new-line}, ERROR-STATUS:GET-MESSAGE (1)) .
   END.
   IF v-file-version > p-base-version
   THEN DO:
      RETURN ERROR SUBSTITUTE( "В файле номер версии №&1 больше текущей №&2", v-file-version, p-base-version) .
   END.

   /* выгружаем */
   output stream st-out to "cmp/cd-event.enc" .

   ASSIGN
      v-new-version = p-base-version + 1
      v-str = STRING(v-new-version)
   .

   { gbl/pencrypt.i v-str v-str-enc }

   PUT stream st-out UNFORMATTED
      v-str-enc SKIP
   .

   ASSIGN
      v-count = 0
   .
   FOR EACH bf_cd-events
       no-lock
       :
         ASSIGN
            v-str = SUBSTITUTE( "&1&2&3&4&5&6&7&8"
                              , bf_cd-events.event-id
                              , {&delim-par}

                              , bf_cd-events.event-level
                              , {&delim-par}

                              , bf_cd-events.event-name
                              , {&delim-par}

                              , bf_cd-events.event-status
                              , {&delim-par}
                              )
         .
         ASSIGN
            v-str = SUBSTITUTE( "&1&2&3&4"
                              , v-str
                              , bf_cd-events.event-type
                              , {&delim-par}
                              , bf_cd-events.event-description
                              )
         .
         { gbl/pencrypt.i v-str v-str-enc }

         PUT stream st-out UNFORMATTED
             v-str-enc SKIP
         .
         ASSIGN
            v-count = v-count + 1
         .
   END.

   /* количество записей */
   ASSIGN
      v-str = STRING(v-count)
   .

   { gbl/pencrypt.i v-str v-str-enc }

   PUT stream st-out UNFORMATTED
      v-str-enc SKIP
   .
   DO
   TRANSACTION
   :
      FOR EACH bf_cd-events
         EXCLUSIVE-lock
         :
         ASSIGN
            bf_cd-events.version = v-new-version
         .
      END.
   END.

end.