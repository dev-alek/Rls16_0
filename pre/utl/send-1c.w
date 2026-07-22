DEFINE NEW GLOBAL SHARED VARIABLE appSrvUtils AS HANDLE                NO-UNDO.
IF NOT VALID-HANDLE(appSrvUtils) THEN
  RUN adecomm/as-utils.w PERSISTENT SET appSrvUtils.
THIS-PROCEDURE:ADD-SUPER-PROCEDURE(appSrvUtils).
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Повторная выгрузка данных для 1С ERP".
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
define new shared stream vProtTest.
define new shared variable testId as rowid no-undo.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE BUTTON b-close AUTO-END-KEY
     LABEL "Отменить"
     SIZE 15 BY 1.13.
DEFINE BUTTON b-start
     LABEL "Запустить"
     SIZE 15 BY 1.13.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 54 BY 11.75.
DEFINE VARIABLE T-1 AS LOGICAL INITIAL no
     LABEL "Документа (накл., инв., перес.)"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-2 AS LOGICAL INITIAL no
     LABEL "Смены"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-3 AS LOGICAL INITIAL no
     LABEL "Сверки"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-4 AS LOGICAL INITIAL no
     LABEL "Переоценки"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-5 AS LOGICAL INITIAL no
     LABEL "Фин.документа"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-6 AS LOGICAL INITIAL no
     LABEL "Документа производства"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-7 AS LOGICAL INITIAL no
     LABEL "Документа электронного документооборота"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-8 AS LOGICAL INITIAL no
     LABEL "Общая выгрузка"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE T-9 AS LOGICAL INITIAL no
     LABEL "Текущая топология"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-10 AS LOGICAL INITIAL no
     LABEL "Контрольная плотность НП"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .83 NO-UNDO.
DEFINE FRAME gDialog
     b-start AT ROW 1.25 COL 2 WIDGET-ID 8
     b-close AT ROW 1.25 COL 42
     T-1 AT ROW 4 COL 13.5 WIDGET-ID 54
     T-2 AT ROW 5 COL 13.5 WIDGET-ID 56
     T-3 AT ROW 6 COL 13.5 WIDGET-ID 58
     T-4 AT ROW 7 COL 13.5 WIDGET-ID 60
     T-5 AT ROW 8 COL 13.5 WIDGET-ID 62
     T-6 AT ROW 9 COL 13.5 WIDGET-ID 64
     T-7 AT ROW 10 COL 13.5 WIDGET-ID 68
     T-9 AT ROW 11 COL 13.5 WIDGET-ID 70
     T-10 AT ROW 12 COL 13.5 WIDGET-ID 70
     T-8 AT ROW 13 COL 13.5 WIDGET-ID 66
     "Выгрузка:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3 COL 4.5 WIDGET-ID 52
     RECT-3 AT ROW 3.25 COL 3 WIDGET-ID 50
     SPACE(2.12) SKIP(1.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Повторная выгрузка данных для 1С ERP"
         CANCEL-BUTTON b-close WIDGET-ID 100.
ASSIGN
       FRAME gDialog:SCROLLABLE       = FALSE
       FRAME gDialog:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME gDialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-start IN FRAME gDialog
DO:
  ASSIGN
  t-1
  t-2
  t-3
  t-4
  t-5
  t-6
  t-7
  t-8
  t-9
  t-10
    .
if t-1 then do:
run  utl/send1c.p.
end.
if t-2 then do:
  run utl/send2c.p (parparentproc).
end.
if t-3 then do:
  run utl/send3c.p.
end.
if t-4 then do:
  run utl/send4c.p.
end.
if t-5 then do:
  run utl/send5c.p.
end.
if t-6 then do:
  run utl/send6c.p.
end.
if t-7 then do:
  run utl/send7c.p.
end.
if t-9 then do:
  run utl/send9c.p.
end.
if t-10 then do:
  run utl/send10c.p .
end.
if t-8 then do:
  run utl/all-send1c.p (parparentproc).
end.
END.
ON VALUE-CHANGED OF T-1 IN FRAME gDialog
DO:
  assign
  t-1
  .
END.
ON VALUE-CHANGED OF T-2 IN FRAME gDialog
DO:
  assign
  t-2
  .
END.
ON VALUE-CHANGED OF T-3 IN FRAME gDialog
DO:
  assign
  t-3
  .
END.
ON VALUE-CHANGED OF T-4 IN FRAME gDialog
DO:
  assign
  t-4
  .
END.
ON VALUE-CHANGED OF T-5 IN FRAME gDialog
DO:
  assign
  t-5
  .
END.
ON VALUE-CHANGED OF T-6 IN FRAME gDialog
DO:
  assign
  t-6
  .
END.
ON VALUE-CHANGED OF T-7 IN FRAME gDialog
DO:
  assign
  t-7
  .
END.
ON VALUE-CHANGED OF T-8 IN FRAME gDialog
DO:
  assign
  t-8
  .
END.
ON VALUE-CHANGED OF T-9 IN FRAME gDialog
DO:
  assign
  t-9
  .
END.
ON VALUE-CHANGED OF T-10 IN FRAME gDialog
DO:
  assign
  t-10
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME gDialog:PARENT eq ?
THEN FRAME gDialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME gDialog.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME gDialog.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-1 T-2 T-3 T-4 T-5 T-6 T-7 T-9 T-10 T-8
      WITH FRAME gDialog.
  ENABLE RECT-3 b-start b-close T-1 T-2 T-3 T-4 T-5 T-6 T-7 T-9 T-10 T-8
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
END PROCEDURE.
