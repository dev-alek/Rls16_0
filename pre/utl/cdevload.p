block-level on error undo, throw.
define input        parameter parparentproc as widget-handle  no-undo .
define input-output parameter p-base-version as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdevload.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdevload.p $":U .
define variable vss-description as character no-undo init "Загрузка справочника событий на кассе".
define buffer bf_cd-events      for ub.cd-events .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-in-string
  ,output v-out-string
  )  .
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-in-string
  ,output v-out-string
  ) NO-ERROR .
         IF (NUM-ENTRIES(v-out-string, chr(4)) < 6)
         THEN DO:
            IF NUM-ENTRIES(v-out-string, chr(4)) = 1
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
      p-id          = INTEGER(ENTRY(1, p-line, chr(4)))
      p-level       = INTEGER(ENTRY(2, p-line, chr(4)))
      p-name        = ENTRY(3, p-line, chr(4))
      p-status      = INTEGER(ENTRY(4, p-line, chr(4)))
      p-type        = ENTRY(5, p-line, chr(4))
      p-description = ENTRY(6, p-line, chr(4))
   NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Ошибка типов данных &1&2" , chr(10), ERROR-STATUS:GET-MESSAGE (1)) .
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
      RETURN ERROR SUBSTITUTE("Ошибка создания записи &1&2&3", p-id, chr(10), error-status :get-message (1)).
   END.
   RETURN.
end.
end procedure.
