define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод уникального идентификатора записи".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define input  parameter iLabel as character no-undo.
define input  parameter iTypes as character no-undo.
define output parameter oIdent as character no-undo.
define temp-table ttFill no-undo
  field fLabel  as handle
  field fFill   as handle
  field fType   as character
  field fFormat as character
.
DEFINE BUTTON b-exit
     LABEL "Выход"
     SIZE 15 BY 1.14.
DEFINE BUTTON b-input
     LABEL "Ввод"
     SIZE 15 BY 1.14.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 2.38.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.48 COL 3 WIDGET-ID 2
     b-input AT ROW 1.48 COL 19 WIDGET-ID 8
     RECT-1 AT ROW 2.91 COL 2 WIDGET-ID 10
     SPACE(1.79) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите значения для идентификации записи" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON RETURN OF FRAME Dialog-Frame
anywhere DO:
  if focus:type = "FILL-IN" then
  do:
    find first ttFill where ttFill.fFill = focus:handle.
    find next ttFill no-error.
    if avail ttFill then
      apply "ENTRY":U to ttFill.fFill.
    else
      apply "CHOOSE":U to b-input.
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-input IN FRAME Dialog-Frame
DO:
  oIdent = "".
  for each ttFill:
    if (ttFill.fType = "CHARACTER" and ttFill.fFill:screen-value = "") then
    do:
      message "Не все поля заполнены." view-as alert-box.
      apply "entry":U to ttFill.fFill.
      return no-apply.
    end.
    oIdent = oIdent + "," + ttFill.fFill:screen-value.
  end.
  oIdent = substring(oIdent,2).
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run buildFill in this-procedure.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE buildFill :
define variable vCount as integer no-undo.
define variable vFillIn as handle no-undo.
define variable vStep   as decimal no-undo.
do with frame Dialog-Frame:
  do vCount = 1 to num-entries(iLabel):
    vStep = (vCount - 1) * 1.1.
    create ttFill.
    ttFill.fType = entry(vCount,iTypes).
    ttFill.fFormat = if entry(vCount,iTypes) = "integer" or entry(vCount,iTypes) = "int64" then ">>>>>>>>9" else
                     if entry(vCount,iTypes) = "decimal" then ">>>>>>>>9.9<<<<<" else "X(100)".
    CREATE TEXT ttFill.fLabel
    ASSIGN
      FRAME = FRAME Dialog-Frame:HANDLE
      DATA-TYPE = "CHARACTER"
      FORMAT = "x(" + string(length(entry(vCount,iLabel)) + 2) + ")"
      SCREEN-VALUE = entry(vCount,iLabel) + ":"
      ROW = 3.3 + vStep
      COLUMN = 25 - 2 - length(entry(vCount,iLabel))
    .
    CREATE FILL-IN ttFill.fFill
    ASSIGN
      ROW = 3.3 + vStep
      COLUMN = 25
      DATA-TYPE = ttFill.fType
      FORMAT = ttFill.fFormat
      WIDTH = 45
      FRAME = frame Dialog-Frame:HANDLE
      SENSITIVE = yes
      VISIBLE = TRUE
      SIDE-LABEL-HANDLE = ttFill.fLabel
    .
    frame Dialog-Frame:height = frame Dialog-Frame:height + vStep.
    rect-1:height = rect-1:height + vStep.
  end.
  find first ttFill.
  apply "ENTRY":U to ttFill.fFill.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE RECT-1 b-exit b-input
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
