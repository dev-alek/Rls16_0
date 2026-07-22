block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ppath.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ppath.p $":U .
define variable vss-description as character no-undo init "".
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
DEFINE VARIABLE c_it AS CHARACTER NO-UNDO FORMAT "x(60)":U.
DEFINE VARIABLE cwd  AS CHARACTER NO-UNDO INITIAL ?.
DEFINE VARIABLE ctd  AS CHARACTER NO-UNDO INITIAL ?.
DEFINE VARIABLE cc   AS CHARACTER NO-UNDO.
DEFINE VARIABLE rr   AS RECID     NO-UNDO.
DEFINE VARIABLE jj   AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll   AS LOGICAL   NO-UNDO.
DEFINE TEMP-TABLE tt_ppth NO-UNDO
  FIELD number  AS INTEGER   FORMAT ">>9":U   COLUMN-LABEL "Н-р"
  FIELD it-name AS CHARACTER FORMAT "x(40)":U COLUMN-LABEL "Каталог"
  INDEX tt_pi   IS PRIMARY   UNIQUE number    ASCENDING.
DEFINE BUTTON Btn_Up     LABEL "&Up"     SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Down   LABEL "Do&wn"   SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Top    LABEL "&Top"    SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Bottom LABEL "&Bottom" SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Exit   LABEL "E&xit"   SIZE-CHARS 7.50 BY 1.00 DEFAULT AUTO-END-KEY.
DEFINE BUTTON Btn_Add    LABEL "&Add"    SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Edit   LABEL "&Edit"   SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Delete LABEL "&Del"    SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Save   LABEL "&Save"   SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Help   LABEL "&Help"   SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_Info   LABEL "&Info"   SIZE-CHARS 7.50 BY 1.00 DEFAULT.
DEFINE BUTTON Btn_OK     LABEL "&OK"     SIZE-CHARS 7.50 BY 1.00 DEFAULT AUTO-GO.
DEFINE RECTANGLE r-rect-0 EDGE-PIXELS 3 GRAPHIC-EDGE NO-FILL SIZE-CHARS 56.38 BY  1.50.
DEFINE RECTANGLE r-rect-1 EDGE-PIXELS 3 GRAPHIC-EDGE NO-FILL SIZE-CHARS 60.00 BY  1.50.
DEFINE RECTANGLE r-rect-2 EDGE-PIXELS 3 GRAPHIC-EDGE NO-FILL SIZE-CHARS  9.25 BY 13.75.
DEFINE QUERY br-tt FOR tt_ppth SCROLLING.
DEFINE BROWSE br-tt QUERY br-tt NO-LOCK DISPLAY
  tt_ppth.number
  tt_ppth.it-name
WITH SEPARATORS SIZE-CHARS 46.50 BY 13.75.
DEFINE FRAME ff
  br-tt      AT ROW  1.25 COL  1.50
  r-rect-2   AT ROW  1.25 COL 48.50
  Btn_Up     AT ROW  1.50 COL 49.38
  Btn_Down   AT ROW  3.00 COL 49.38
  Btn_Top    AT ROW  6.00 COL 49.38
  Btn_Bottom AT ROW  7.50 COL 49.38
  Btn_Help   AT ROW 12.04 COL 49.38
  Btn_Info   AT ROW 13.58 COL 49.38
  r-rect-0   AT ROW 15.25 COL  1.50
  Btn_Exit   AT ROW 15.50 COL  2.50
  Btn_Add    AT ROW 15.50 COL 24.25
  Btn_Edit   AT ROW 15.50 COL 32.25
  Btn_Delete AT ROW 15.50 COL 40.25
  Btn_Save   AT ROW 15.50 COL 49.38
WITH VIEW-AS DIALOG-BOX NO-LABEL TITLE "Propath" THREE-D DEFAULT-BUTTON Btn_Edit CANCEL-BUTTON Btn_Exit.
DEFINE FRAME ff-upd
  c_it     AT ROW 1.50 COL  1.50 NO-LABEL VIEW-AS FILL-IN SIZE-CHARS 60.00 BY 1.00
  r-rect-1 AT ROW 3.00 COL  1.50
  Btn_Exit AT ROW 3.25 COL  2.50
  Btn_OK   AT ROW 3.25 COL 53.50
WITH VIEW-AS DIALOG-BOX SIDE-LABELS TITLE "Propath" THREE-D SCROLLABLE KEEP-TAB-ORDER
     DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Exit.
ON CHOOSE OF Btn_Add IN FRAME ff DO:
  ASSIGN FRAME ff-upd :TITLE = "Propath: Adding...".
  IF AVAILABLE tt_ppth THEN DO:
    ASSIGN c_it = tt_ppth.it-name
           jj   = tt_ppth.number
           rr   = RECID( tt_ppth ).
  END.
  IF c_it = cwd + " | <Рабочий каталог>" THEN DO: ASSIGN c_it = ".". END.
  DO ON ENDKEY UNDO, LEAVE
     ON ERROR  UNDO, LEAVE :
    DISPLAY  c_it WITH FRAME ff-upd.
    ENABLE   ALL  WITH FRAME ff-upd.
    WAIT-FOR GO     OF FRAME ff-upd.
    ASSIGN c_it.
    FIND FIRST tt_ppth NO-LOCK WHERE tt_ppth.it-name = c_it NO-ERROR.
    IF AVAILABLE tt_ppth THEN DO:
      MESSAGE 'Повторно указан путь "' + c_it + '"!' SKIP "( см.п." tt_ppth.number ")." VIEW-AS ALERT-BOX ERROR.
      UNDO, RETRY.
    END.
    CREATE tt_ppth.
    ASSIGN tt_ppth.number  = jj
           tt_ppth.it-name = c_it
           rr              = RECID( tt_ppth ).
    IF tt_ppth.it-name = "." THEN DO: ASSIGN tt_ppth.it-name = cwd + " | <Рабочий каталог>". END.
    FOR EACH tt_ppth WHERE tt_ppth.number >= jj AND RECID( tt_ppth ) <> rr BY tt_ppth.number DESCENDING :
      ASSIGN tt_ppth.number = tt_ppth.number + 1.
    END.
  END.
  HIDE FRAME ff-upd NO-PAUSE.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Edit IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  ASSIGN FRAME ff-upd :TITLE = "Propath: Updating...".
  ASSIGN c_it = tt_ppth.it-name
         rr   = RECID( tt_ppth ).
  IF c_it = cwd + " | <Рабочий каталог>" THEN DO: ASSIGN c_it = ".". END.
  DO ON ENDKEY UNDO, LEAVE
     ON ERROR  UNDO, LEAVE :
    DISPLAY  c_it WITH FRAME ff-upd.
    ENABLE   ALL  WITH FRAME ff-upd.
    WAIT-FOR GO     OF FRAME ff-upd.
    ASSIGN c_it.
    ASSIGN tt_ppth.it-name = c_it
           rr              = RECID( tt_ppth ).
    IF tt_ppth.it-name = "." THEN DO: ASSIGN tt_ppth.it-name = cwd + " | <Рабочий каталог>". END.
  END.
  HIDE FRAME ff-upd NO-PAUSE.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Delete IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  IF tt_ppth.it-name = cwd + " | <Рабочий каталог>" THEN DO:
    ASSIGN ll = NO.
    MESSAGE "Вы уверены, что хотите удалить рабочую директорию?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ll.
  END.
  ASSIGN jj = tt_ppth.number.
  DELETE tt_ppth.
  FIND FIRST tt_ppth NO-LOCK WHERE tt_ppth.number = jj + 1 NO-ERROR.
  IF NOT AVAILABLE tt_ppth THEN DO: FIND FIRST tt_ppth NO-LOCK WHERE tt_ppth.number = jj - 1 NO-ERROR. END.
  IF AVAILABLE tt_ppth THEN DO: ASSIGN rr = RECID( tt_ppth ). END.
  FOR EACH tt_ppth WHERE tt_ppth.number > jj :
    ASSIGN tt_ppth.number = tt_ppth.number - 1.
  END.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Down IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  ASSIGN jj = tt_ppth.number
         rr = RECID( tt_ppth ).
  FIND LAST tt_ppth NO-LOCK USE-INDEX tt_pi.
  IF tt_ppth.number = jj THEN DO: RETURN NO-APPLY. END.
  DO TRANSACTION ON ERROR UNDO, LEAVE :
    FIND FIRST tt_ppth WHERE tt_ppth.number = jj + 1 NO-ERROR.
    ASSIGN tt_ppth.number = jj.
    FIND tt_ppth WHERE RECID( tt_ppth ) = rr.
    ASSIGN tt_ppth.number = jj + 1.
  END.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Up IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  ASSIGN jj = tt_ppth.number
         rr = RECID( tt_ppth ).
  FIND FIRST tt_ppth NO-LOCK USE-INDEX tt_pi.
  IF tt_ppth.number = jj THEN DO: RETURN NO-APPLY. END.
  DO TRANSACTION ON ERROR UNDO, LEAVE :
    FIND FIRST tt_ppth WHERE tt_ppth.number = jj - 1 NO-ERROR.
    ASSIGN tt_ppth.number = jj.
    FIND tt_ppth WHERE RECID( tt_ppth ) = rr.
    ASSIGN tt_ppth.number = jj - 1.
  END.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Top IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  ASSIGN jj = tt_ppth.number
         rr = RECID( tt_ppth ).
  ASSIGN tt_ppth.number = 0.
  FOR EACH tt_ppth WHERE tt_ppth.number < jj BY tt_ppth.number DESCENDING :
    ASSIGN tt_ppth.number = tt_ppth.number + 1.
  END.
  RUN UI-On IN THIS-PROCEDURE.
END.
ON CHOOSE OF Btn_Bottom IN FRAME ff DO:
  IF NOT AVAILABLE tt_ppth THEN DO: RETURN NO-APPLY. END.
  ASSIGN jj = tt_ppth.number
         rr = RECID( tt_ppth ).
  FIND LAST tt_ppth NO-LOCK USE-INDEX tt_pi.
  IF jj = tt_ppth.number THEN DO: RETURN NO-APPLY. END.
  ASSIGN c_it = STRING( tt_ppth.number ).
  FOR EACH tt_ppth WHERE tt_ppth.number > jj BY tt_ppth.number :
    ASSIGN tt_ppth.number = tt_ppth.number - 1.
  END.
  FIND tt_ppth WHERE RECID( tt_ppth ) = rr.
  ASSIGN tt_ppth.number = INT( c_it ).
  RUN UI-On IN THIS-PROCEDURE.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-tt DO:
  APPLY "CHOOSE":U TO Btn_Edit IN FRAME ff.
END.
ON CHOOSE OF Btn_Info IN FRAME ff DO:
  ASSIGN rr = ( IF AVAIL tt_ppth THEN RECID( tt_ppth ) ELSE ? )
         jj = 0.
  FOR EACH tt_ppth NO-LOCK :
    ASSIGN jj = jj + 1.
  END.
  FIND tt_ppth WHERE RECID( tt_ppth ) = rr NO-ERROR.
  IF cwd = ? OR cwd = "":U OR ctd = ? OR ctd = "":U THEN DO: RUN GetWorkingDirectory IN THIS-PROCEDURE. END.
  MESSAGE
    "Текущий рабочий каталог:"   cwd SKIP
    "Текущий временный каталог:" ctd SKIP
    "Элементов списка PROPATH:"  jj  SKIP
  VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF Btn_Save IN FRAME ff DO:
  RUN MakeListFromBrowse IN THIS-PROCEDURE.
  IF cc <> PROPATH THEN DO:
    ASSIGN ll = NO.
    MESSAGE "Записать PROPATH в PROGRESS.INI ?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ll.
    IF NOT ll THEN DO: RETURN NO-APPLY. END.
    ASSIGN cc = PROPATH.
    IF LENGTH( cc ) > 128 THEN DO:
      MESSAGE "Слишком длинный PROPATH, не могу записать в PROGRESS.INI !" VIEW-AS ALERT-BOX INFORMATION.
      RETURN NO-APPLY.
    END.
    PUT-KEY-VALUE SECTION "Startup" KEY "PROPATH" VALUE cc NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      MESSAGE "Не удается сохранить PROPATH !" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
  END.
END.
IF CURRENT-WINDOW :WINDOW-STATE = WINDOW-MINIMIZED THEN DO: CURRENT-WINDOW :WINDOW-STATE = WINDOW-NORMAL. END.
ON WINDOW-CLOSE OF FRAME ff APPLY "END-ERROR":U TO SELF.
DO ON END-KEY UNDO, LEAVE
   ON ERROR   UNDO, LEAVE :
  RUN GetWorkingDirectory IN THIS-PROCEDURE.
  RUN MakeBrowseFromList  IN THIS-PROCEDURE.
  RUN UI-On               IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME ff.
END.
RUN MakeListFromBrowse IN THIS-PROCEDURE.
HIDE FRAME ff NO-PAUSE.
PROCEDURE UI-On :
  OPEN QUERY br-tt FOR EACH tt_ppth NO-LOCK USE-INDEX tt_pi.
  ENABLE ALL WITH FRAME ff.
  FIND tt_ppth NO-LOCK WHERE RECID( tt_ppth ) = rr NO-ERROR.
  IF AVAILABLE tt_ppth THEN REPOSITION br-tt TO RECID RECID( tt_ppth ) NO-ERROR.
  IF NOT AVAIL tt_ppth OR ERROR-STATUS :ERROR THEN DO: REPOSITION br-tt TO ROW 1 NO-ERROR. END.
  APPLY "ENTRY":U TO br-tt IN FRAME ff.
END PROCEDURE.
PROCEDURE MakeBrowseFromList :
  REPEAT jj = 1 TO NUM-ENTRIES( PROPATH ) :
    CREATE tt_ppth.
    ASSIGN tt_ppth.number  = jj
           tt_ppth.it-name = ENTRY( jj, PROPATH ).
    IF tt_ppth.it-name = "." THEN DO: ASSIGN tt_ppth.it-name = cwd + " | <Рабочий каталог>". END.
  END.
END PROCEDURE.
PROCEDURE MakeListFromBrowse :
  ASSIGN cc = "":U.
  FOR EACH tt_ppth :
    ASSIGN c_it = tt_ppth.it-name.
    IF c_it = cwd + " | <Рабочий каталог>" THEN DO: ASSIGN c_it = ".". END.
    ASSIGN cc = cc + ( IF cc = "":U THEN "":U ELSE ",":U ) + c_it.
  END.
  IF cc <> PROPATH THEN DO:
    ASSIGN ll = NO.
    MESSAGE "Изменить PROPATH?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ll.
    IF ll THEN DO: PROPATH = cc. END.
  END.
END PROCEDURE.
PROCEDURE GetWorkingDirectory :
  ASSIGN FILE-INFO :FILE-NAME = ".".
  ASSIGN ctd = CAPS( SESSION :TEMP-DIRECTORY )
         cwd = FILE-INFO :FULL-PATHNAME.
END PROCEDURE.
