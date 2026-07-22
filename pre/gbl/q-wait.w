define input  parameter p-msg          as character no-undo .
define input  parameter p-default-answ as logical   no-undo .
define input  parameter p-timeout      as integer   no-undo .
define output parameter p-answer       as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вопрос с автоответом через промежуток времени".
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
define variable log-exit as logical   no-undo .
DEFINE BUTTON b-no AUTO-END-KEY DEFAULT
     LABEL "&Нет"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-yes AUTO-GO DEFAULT
     LABEL "&Да"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39 BY .67 NO-UNDO.
DEFINE VARIABLE f-wait AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Ожидание ответа (сек)"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-yes AT ROW 4.25 COL 11
     b-no AT ROW 4.25 COL 22.5
     f-msg AT ROW 1.5 COL 2.5 NO-LABEL
     f-wait AT ROW 3 COL 27.5 COLON-ALIGNED
     SPACE(6.49) SKIP(2.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER NO-HELP
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Вопрос"
         CANCEL-BUTTON b-no.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ASSIGN
       f-msg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-wait:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE
       f-wait:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-no IN FRAME Dialog-Frame
DO:
  assign
    log-exit = TRUE
    p-answer = FALSE
  .
END.
ON CHOOSE OF b-yes IN FRAME Dialog-Frame
DO:
  assign
    log-exit = TRUE
    p-answer = TRUE
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable start-time as int64     no-undo .
  define variable v-length   as integer   no-undo .
  define variable lh         as handle    no-undo .
  define variable v-delta    as integer   no-undo .
  assign
    v-length = length( p-msg )
  .
  if v-length > 90 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Сообщение должно быть не больше 90 символов!" ) skip
      substitute( "Ваше сообщение длиной &1 символов.", v-length ) skip
      view-as alert-box error .
    return error "Сообщение должно быть не больше 90 символов!".
  end.
  if v-length > 39 then do:
    assign
      v-delta                         = ( v-length - 39 ) / 2
      f-msg:width-chars               = v-length
      frame Dialog-Frame:width-chars = f-msg:width-chars + 4
      b-yes:column                    = b-yes:column + v-delta
      b-no:column                     = b-no:column + v-delta
      f-wait:column                   = f-wait:column + v-delta
    .
    if valid-handle(f-wait:side-label-handle) then do:
      assign
        lh        = f-wait:side-label-handle
        lh:column = lh:column + v-delta
      .
    end.
  end.
  assign
    f-msg    = p-msg
    log-exit = false
    p-answer = p-default-answ
  .
  RUN enable_UI.
  assign
    start-time = etime
  .
  do while not log-exit:
    display
      ( p-timeout - ( etime - start-time ) / 1000 ) @ f-wait
      with frame Dialog-Frame
      no-error
    .
    wait-for
      go of frame Dialog-Frame
      or close of this-procedure
      or choose of b-yes in frame Dialog-Frame
      or choose of b-no in frame Dialog-Frame
      focus frame Dialog-Frame
      pause 1
    .
    if etime - start-time > p-timeout * 1000 then do:
      leave .
    end.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-msg f-wait
      WITH FRAME Dialog-Frame.
  ENABLE b-yes b-no f-wait
      WITH FRAME Dialog-Frame.
END PROCEDURE.
