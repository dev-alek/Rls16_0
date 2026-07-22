define input-output parameter p-diff           as character     no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод комментария по расхождению".
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
DEFINE BUTTON B-cancel AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON B-ok AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 250 SCROLLBAR-VERTICAL
     SIZE 50 BY 6.75 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-ok AT ROW 1.25 COL 2 WIDGET-ID 4
     B-cancel AT ROW 1.25 COL 12 WIDGET-ID 8
     EDITOR-1 AT ROW 4.58 COL 2 NO-LABEL WIDGET-ID 12
     "Причина расхождения:" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 3.25 COL 2 WIDGET-ID 14
     SPACE(15.12) SKIP(8.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выявленные отклонения" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF B-cancel IN FRAME Dialog-Frame
DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF B-ok IN FRAME Dialog-Frame
DO:
        assign
            EDITOR-1 .
        p-diff = EDITOR-1 .
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
    EDITOR-1 = p-diff .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME Dialog-Frame focus EDITOR-1.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE B-ok B-cancel EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
