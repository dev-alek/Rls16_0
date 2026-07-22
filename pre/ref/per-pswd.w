define output parameter per-pswd as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ввода пароля".
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
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1.17
     BGCOLOR 8 .
DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 11.5 BY .29
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE PSWD AS CHARACTER FORMAT "X(24)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 24 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     PSWD AT ROW 2 COL 13 COLON-ALIGNED BLANK
     Btn_OK AT ROW 6.33 COL 10.5
     fi-screen-pass AT ROW 1.9 COL 13.4 COLON-ALIGNED NO-LABEL
     SPACE(1.08) SKIP(7.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подтвердите пароль"
         DEFAULT-BUTTON Btn_OK.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    assign PSWD.
    per-pswd = PSWD .
END.
ON ANY-KEY OF PSWD IN FRAME Dialog-Frame
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(pswd :screen-value )).
END.
ON VALUE-CHANGED OF PSWD IN FRAME Dialog-Frame
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(pswd :screen-value )).
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY PSWD fi-screen-pass
      WITH FRAME Dialog-Frame.
  ENABLE PSWD Btn_OK fi-screen-pass
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME Dialog-Frame = pswd:WIDTH-CHARS IN FRAME Dialog-Frame - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME Dialog-Frame = pswd:HEIGHT-CHARS IN FRAME Dialog-Frame - 0.6
 fi-screen-pass:row IN FRAME Dialog-Frame = pswd:row IN FRAME Dialog-Frame + 0.2
 fi-screen-pass:COL IN FRAME Dialog-Frame = pswd:col IN FRAME Dialog-Frame + 0.2
 .
 DISPLAY
 PSWD
 fi-screen-pass
 WITH FRAME Dialog-Frame.
 ENABLE
 PSWD
 Btn_OK
 fi-screen-pass
 WITH FRAME Dialog-Frame.
 VIEW FRAME Dialog-Frame.
END PROCEDURE.
