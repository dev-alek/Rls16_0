DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter s-pole   as integer   no-undo .
  define output parameter min-sum  as decimal   no-undo .
  define output parameter v-nedost as logical   no-undo .
  define output parameter all-grp  as integer   no-undo .
  define output parameter list-grp as character no-undo .
  def var vss-revision    as character no-undo init "$Revision$":U .
  def var vss-author      as character no-undo init "$Author$":U .
  def var vss-date        as character no-undo init "$Date$":U .
  def var vss-workfile    as character no-undo init "$Workfile$":U .
  def var vss-archive     as character no-undo init "$Archive$":U .
  def var vss-description as character no-undo init "Формы по инвентаризации ".
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
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Ра&зница сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по &наименованию", 1,
"по &артикулу", 2,
"по &разнице сумм", 3
     SIZE 20.88 BY 3 NO-UNDO.
DEFINE VARIABLE RADIO-SET-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Не&достача", 1,
"&Излишки", 2
     SIZE 14.5 BY 1.92 NO-UNDO.
DEFINE VARIABLE RADIO-SET-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 14.13 BY 1.75 NO-UNDO.
DEFINE FRAME Dialog-Frame
     FILL-IN-1 AT ROW 1.54 COL 15.75 COLON-ALIGNED
     RADIO-SET-1 AT ROW 2.67 COL 36.88 NO-LABEL
     RADIO-SET-2 AT ROW 3.96 COL 3.25 NO-LABEL
     RADIO-SET-3 AT ROW 4.13 COL 18.5 NO-LABEL
     Btn_OK AT ROW 6.79 COL 20.13
     "Группы:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3.08 COL 18.88
          FGCOLOR 4
     "Сортировка:" VIEW-AS TEXT
          SIZE 13.13 BY .67 AT ROW 1.79 COL 37.88
          FGCOLOR 4
     "Анализ:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3.08 COL 5.13
          FGCOLOR 4
     SPACE(43.13) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризация (анализ отклонений)"
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
  assign FILL-IN-1  RADIO-SET-1  RADIO-SET-2  RADIO-SET-3 .
  assign
    s-pole  = RADIO-SET-1
    min-sum = FILL-IN-1
    all-grp = RADIO-SET-3
  .
  if RADIO-SET-2 = 1 then assign v-nedost = yes .
  else                    assign v-nedost = no .
END.
ON VALUE-CHANGED OF RADIO-SET-3 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-3 .
  if RADIO-SET-3 = 2 then do:
    run ref/gds-grp.w ( input parparentproc
                 , input "b-sel,b-mark"
                 , input p-obj-type
                 , input p-obj-code
                 , input-output list-grp ).
    if list-grp = "" then assign RADIO-SET-3 = 1 .
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign  RADIO-SET-1 = s-pole .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-1 RADIO-SET-1 RADIO-SET-2 RADIO-SET-3
      WITH FRAME Dialog-Frame.
  ENABLE FILL-IN-1 RADIO-SET-1 RADIO-SET-2 RADIO-SET-3 Btn_OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
