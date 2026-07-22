CREATE WIDGET-POOL.
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE FRAME DEFAULT-FRAME
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 20.25 BY .71 WIDGET-ID 100.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Сообщение"
         HEIGHT             = .67
         WIDTH              = 20.25
         MAX-HEIGHT         = 42.38
         MAX-WIDTH          = 240
         VIRTUAL-HEIGHT     = 42.38
         VIRTUAL-WIDTH      = 240
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE C-Win = CURRENT-WINDOW.
ASSIGN
       FRAME DEFAULT-FRAME:HIDDEN           = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  define variable FullFileName  as character no-undo.
  define variable v-param       as character no-undo .
  define variable ind           as integer   no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-msg         as character no-undo .
  define stream   s-imp.
  if session:parameter <> "":U
    and session:parameter <> ?
  then do:
    assign
      v-num-entries = num-entries( session:parameter, ",":U )
    .
    do ind = 1 to v-num-entries :
      assign
        v-param = entry( ind, session:parameter, ",":U )
      .
        if v-param begins 'FullFileName' then do:
          assign
            FullFileName = entry( 2, v-param, "?":U )
          .
        end.
    end.
  end.
  if FullFileName = ? or FullFileName = ""
    then do:
      message "Не могу вывести сообщение" view-as alert-box.
      quit.
    end.
  input stream s-imp from value( FullFileName ).
  import stream s-imp unformatted v-msg no-error.
  message v-msg view-as alert-box information title "Информация.".
  quit.
END.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  VIEW FRAME DEFAULT-FRAME IN WINDOW C-Win.
  VIEW C-Win.
END PROCEDURE.
