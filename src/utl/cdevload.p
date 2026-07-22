block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdevload.p $
$Archive: utl/cdevload.p $

Загрузка справочника событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 12/01/08
Author: Ilia Belousov
Creation date: 12/01/08

Input:

Output:

*/
/* !!! */
define input        parameter parparentproc as widget-handle  no-undo .
define input-output parameter p-base-version as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdevload.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdevload.p $":U .
define variable vss-description as character no-undo init "Загрузка справочника событий на кассе".

define buffer bf_cd-events      for ub.cd-events .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .
DEFINE VARIABLE v-count-2    AS INTEGER   NO-UNDO .
define variable v-file-version    as integer   no-undo.
define variable v-file-name    as character    no-undo.

DEFINE STREAM st-in .


do
on error undo, return error
:
   SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").

   assign
      v-file-name    = search("cmp/cd-event.enc").
   .
   if v-file-name = ?
   or v-file-name = "":U
   then do:
      return error "Не найден файл со списком событий на кассе".
   end.

   INPUT STREAM st-in FROM VALUE(v-file-name) .

   IMPORT STREAM st-in UNFORMATTED
      v-in-string
      .

   { gbl/pdecrypt.i v-in-string v-out-string }

   ASSIGN
      v-file-version = INTEGER(v-out-string)
   .
   IF v-file-version = p-base-version
   THEN DO:
      RETURN.
   END.
   else IF v-file-version < p-base-version
   THEN DO:
      RETURN SUBSTITUTE( "В файле более старая версия &1, текущая &2" , v-file-version, p-base-version) .
   END.

   do
   TRANSACTION
   on error undo, return error
   :

      FOR EACH bf_cd-events
         EXCLUSIVE-LOCK
         :
         DELETE bf_cd-events.
      END.

      ASSIGN
         v-count     = 0
         v-count-2   = 0
      .

      SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
      REPEAT:
         ASSIGN
            v-out-string = ""
            v-in-string  = ""
         .

         IMPORT STREAM st-in UNFORMATTED
            v-in-string
            .

         { gbl/pdecrypt.i v-in-string v-out-string NO-ERROR}

         IF (NUM-ENTRIES(v-out-string, {&delim-par}) < 6)
         THEN DO:
            IF NUM-ENTRIES(v-out-string, {&delim-par}) = 1
            THEN DO:
               ASSIGN
                  v-count-2 = INTEGER(v-out-string)
               NO-ERROR
               .
               IF ERROR-STATUS:ERROR
               THEN DO:
                  RETURN ERROR SUBSTITUTE( "Неправильный конец файла &1" , v-out-string) .
               END.

               IF v-count-2 <> v-count
               THEN DO:
                  RETURN ERROR SUBSTITUTE( "Неправильное количество строк в файле &1, должно быть &2" , v-count, v-count-2) .
               END.

            END.
            ELSE DO:
               RETURN ERROR "Не хватает параметров " + v-out-string.
            END.
         END.

         RUN load-line ( INPUT v-file-version, INPUT v-out-string ) .
         ASSIGN
            v-count = v-count + 1
         .
      END.

   END.

end.

/*==========================================================================*/
procedure load-line :
define input parameter p-file-version    as integer          no-undo.
define input parameter p-line       as character        no-undo.

define VARIABLE p-id            as integer          no-undo.
define VARIABLE p-level         as integer          no-undo.
define VARIABLE p-name          as character        no-undo.
define VARIABLE p-status        as integer          no-undo.
define VARIABLE p-type          as character        no-undo.
define VARIABLE p-description   as character        no-undo.

define buffer buf_cd-events      for ub.cd-events .

do
on error undo, return error
:
   ASSIGN
      p-id          = INTEGER(ENTRY(1, p-line, {&delim-par}))
      p-level       = INTEGER(ENTRY(2, p-line, {&delim-par}))
      p-name        = ENTRY(3, p-line, {&delim-par})
      p-status      = INTEGER(ENTRY(4, p-line, {&delim-par}))
      p-type        = ENTRY(5, p-line, {&delim-par})
      p-description = ENTRY(6, p-line, {&delim-par})
   NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Ошибка типов данных &1&2" , {&new-line}, ERROR-STATUS:GET-MESSAGE (1)) .
   END.

   FIND FIRST buf_cd-events
        WHERE buf_cd-events.event-id = p-id
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_cd-events
   THEN DO:
      RETURN ERROR SUBSTITUTE("Уже есть событие с номером &1", p-id).
   END.

   CREATE buf_cd-events.
   ASSIGN
      buf_cd-events.version           = p-file-version
      buf_cd-events.event-id          = p-id
      buf_cd-events.event-level       = p-level
      buf_cd-events.event-name        = p-name
      buf_cd-events.event-status      = p-status
      buf_cd-events.event-type        = p-type
      buf_cd-events.event-description = p-description
   NO-ERROR .
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE("Ошибка создания записи &1&2&3", p-id, {&new-line}, error-status :get-message (1)).
   END.

   RETURN.
end. /* do on error */
end procedure. /* load-line */