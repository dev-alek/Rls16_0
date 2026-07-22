block-level on error undo, throw.
define input        parameter parparentproc as widget-handle  no-undo .
define input-output parameter p-base-version as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdevdown.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cdevdown.p $":U .
define variable vss-description as character no-undo init "Выгрузка списка событий на кассе".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-str-enc
  ,output v-str
  )  .
   END.
   ASSIGN
      v-file-version = INTEGER(v-str)
   NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      RETURN ERROR SUBSTITUTE( "Не верный номер версии &1&2&3" , v-str, chr(10), ERROR-STATUS:GET-MESSAGE (1)) .
   END.
   IF v-file-version > p-base-version
   THEN DO:
      RETURN ERROR SUBSTITUTE( "В файле номер версии №&1 больше текущей №&2", v-file-version, p-base-version) .
   END.
   output stream st-out to "cmp/cd-event.enc" .
   ASSIGN
      v-new-version = p-base-version + 1
      v-str = STRING(v-new-version)
   .
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pencrypt in g#library2
  (input  v-str
  ,output v-str-enc
  )  .
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
                              , chr(4)
                              , bf_cd-events.event-level
                              , chr(4)
                              , bf_cd-events.event-name
                              , chr(4)
                              , bf_cd-events.event-status
                              , chr(4)
                              )
         .
         ASSIGN
            v-str = SUBSTITUTE( "&1&2&3&4"
                              , v-str
                              , bf_cd-events.event-type
                              , chr(4)
                              , bf_cd-events.event-description
                              )
         .
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pencrypt in g#library2
  (input  v-str
  ,output v-str-enc
  )  .
         PUT stream st-out UNFORMATTED
             v-str-enc SKIP
         .
         ASSIGN
            v-count = v-count + 1
         .
   END.
   ASSIGN
      v-str = STRING(v-count)
   .
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pencrypt in g#library2
  (input  v-str
  ,output v-str-enc
  )  .
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
