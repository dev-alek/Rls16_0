define input parameter  parparentproc as handle    no-undo .
define input parameter  p-user-id     as character no-undo .
define input parameter  p-db-num      as integer   no-undo .
define input parameter  p-action      as character        no-undo.
define input parameter  p-ask         as logical          no-undo.
define output parameter p-message     as character        no-undo.
define output parameter p-ok          as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка пароля".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#eventlib as handle no-undo.
define buffer buf_user-login     for ub.user-login .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(16)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     v-password AT ROW 2.75 COL 10.88 COLON-ALIGNED WIDGET-ID 4 AUTO-RETURN  PASSWORD-FIELD
     b-exit AT ROW 4.75 COL 10
     b-quit AT ROW 4.75 COL 21
     v-login AT ROW 1.5 COL 11 COLON-ALIGNED WIDGET-ID 2
     SPACE(11.62) SKIP(4.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите пароль"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign
    v-login
    v-password
  .
  RUN chk-action in this-procedure (OUTPUT p-ok)  .
END.
ON ENTER OF v-password IN FRAME Dialog-Frame
DO:
   APPLY "CHOOSE" TO b-exit in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
on "ENTRY" of b-exit do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-exit in frame Dialog-Frame.
  end.
end.
on "ESC" ANYWHERE do:
  if lastkey = keycode ("RETURN") then do:
    p-ok = FALSE.
    apply "CHOOSE" to b-quit in frame Dialog-Frame.
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  p-action
    ,input  'object':U
    ,input  0
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output p-ok
    )  .
end.
   IF p-ok
   AND NOT p-ask
   THEN DO:
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  35
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) NO-ERROR .
end.
      RETURN .
   END.
   assign
      p-ok = FALSE
   .
   FIND FIRST buf_user-login
        WHERE buf_user-login.db-num     = p-db-num
          AND buf_user-login.user-id    = p-user-id
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_user-login
   THEN DO:
      ASSIGN
         v-login = buf_user-login.user-login
      .
   END.
   RUN enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE chk-action :
define output parameter p-ok as logical          no-undo.
define variable v-user-password-enc    as character    no-undo.
do
on error undo, return error
:
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  33
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-login
    ) NO-ERROR .
end.
   FIND FIRST buf_user-login
        WHERE buf_user-login.db-num     = p-db-num
          AND buf_user-login.user-login = v-login
        NO-LOCK
        NO-ERROR
        .
   IF NOT AVAILABLE buf_user-login
   THEN DO:
      ASSIGN
         p-message = "Неправильный логин"
         p-ok      = FALSE
      .
      RETURN.
   END.
   run adm/pswd-enc.p
      (input  encode(v-password)
      ,output v-user-password-enc
      ) no-error .
   if error-status:error
   then do:
      return error substitute( "&1. Ошибка кодировки. &2", vss-workfile, return-value ).
   end.
   assign
      v-user-password-enc = encode(v-user-password-enc)
   .
   IF buf_user-login.user-password-encoded = v-user-password-enc
   THEN DO:
      IF p-action = "":U
      THEN DO:
         ASSIGN
            p-ok = TRUE
         .
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  35
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-login
    ) NO-ERROR .
end.
         RETURN.
      END.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  p-action
    ,input  'object':U
    ,input  0
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output p-ok
    )  .
end.
      IF NOT p-ok
      THEN DO:
         ASSIGN
            p-message = RETURN-VALUE
         NO-ERROR.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  34
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-login
    ) NO-ERROR .
end.
         RETURN .
      END.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  35
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-login
    ) NO-ERROR .
end.
   END.
   ELSE DO:
      ASSIGN
         p-message = "Неправильный пароль"
         p-ok      = FALSE
      .
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  p-action
    , input  0
    , input  '':U
    , input  0
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  34
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-login
    ) NO-ERROR .
end.
      RETURN.
   END.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-password v-login
      WITH FRAME Dialog-Frame.
  ENABLE v-password b-exit b-quit v-login
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
