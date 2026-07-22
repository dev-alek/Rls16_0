&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма задания типа/кода объекта во внешней системе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/10/08
Author: Bakhtadze Natalya
Creation date: 10/10/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-esys-type AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-ext-obj-type AS CHARACTER .
DEFINE INPUT-OUTPUT PARAMETER p-ext-obj-code AS CHARACTER .
DEFINE INPUT-OUTPUT PARAMETER p-ext-guid     AS CHARACTER .
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма задания типа/кода объекта во внешней системе".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/checkmerq.i }

define variable ii            as integer   no-undo .
define variable v-ext-guidobj as character no-undo .
define variable v-ext-guid    as character no-undo .

DEFINE BUFFER X_ext-classif FOR ub.ext-classif.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rs-ext-obj-type ~
f-ext-obj-code f-ext-obj-guidobj f-ext-obj-guid 
&Scoped-Define DISPLAYED-OBJECTS rs-ext-obj-type f-ext-obj-code ~
f-ext-obj-guidobj f-ext-obj-guid 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
  LABEL "&Ввод" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-Help 
  LABEL "Помо&щь" 
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
  LABEL "&Отмена" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE f-ext-obj-code    AS CHARACTER FORMAT "X(16)" 
  LABEL "Код объекта во внешней системе" 
  VIEW-AS FILL-IN 
  SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-ext-obj-guid    AS CHARACTER FORMAT "X(39)" 
  LABEL "GUID площадки" 
  VIEW-AS FILL-IN 
  SIZE 40.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-ext-obj-guidobj AS CHARACTER FORMAT "X(39)" 
  LABEL "GUID хоз. Субъекта" 
  VIEW-AS FILL-IN 
  SIZE 40.88 BY 1 NO-UNDO.

DEFINE VARIABLE rs-ext-obj-type   AS CHARACTER 
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS 
  "Item 1", "1",
  "Item 2", "2",
  "Item 3", "3"
  SIZE 64 BY 1.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11
  B-Help AT ROW 1 COL 71.5
  rs-ext-obj-type AT ROW 2.5 COL 6.88 NO-LABEL WIDGET-ID 4
  f-ext-obj-code AT ROW 4.25 COL 31.75 COLON-ALIGNED WIDGET-ID 2
  f-ext-obj-guidobj AT ROW 5.42 COL 31.63 COLON-ALIGNED WIDGET-ID 8
  f-ext-obj-guid AT ROW 6.5 COL 31.63 COLON-ALIGNED WIDGET-ID 10
  SPACE(0.23) SKIP(0.66)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE ""
  DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
  DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ext-obj-guid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ext-obj-guid Dialog-Frame
ON LEAVE OF f-ext-obj-guid IN FRAME Dialog-Frame /* GUID площадки */
  DO:
    define variable Msg as character no-undo .
  
    assign f-ext-obj-guid .
    run checkguid(INPUT-OUTPUT f-ext-obj-guid, OUTPUT Msg) no-error .
    if Msg <> "" then 
    do:
      MESSAGE Msg
        VIEW-AS ALERT-BOX.
      RETURN NO-APPLY .
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ext-obj-guidobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ext-obj-guidobj Dialog-Frame
ON LEAVE OF f-ext-obj-guidobj IN FRAME Dialog-Frame /* GUID хоз. Субъекта */
  DO:
    define variable Msg as character no-undo .
  
    assign f-ext-obj-guidobj .
    run checkguid(INPUT-OUTPUT f-ext-obj-guidobj, OUTPUT Msg) no-error .
    if Msg <> "" then 
    do:
      MESSAGE Msg
        VIEW-AS ALERT-BOX.
      RETURN NO-APPLY .
    end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-ext-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-ext-obj-type Dialog-Frame
ON VALUE-CHANGED OF rs-ext-obj-type IN FRAME Dialog-Frame
  DO:
    ASSIGN
      rs-ext-obj-type.
    CASE rs-ext-obj-type:
      WHEN "+100000" THEN 
        DO:
          ASSIGN
            f-ext-obj-code = string( integer(p-ext-obj-code) + 100000 ) no-error.
          DISPLAY
            f-ext-obj-code
            WITH FRAME {&FRAME-NAME}.
        END.
      OTHERWISE 
      DO:
        ASSIGN
          f-ext-obj-code = p-ext-obj-code.
        DISPLAY
          f-ext-obj-code
          WITH FRAME {&FRAME-NAME}.
      END.
    END CASE.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(p-mode, {&UPDATE} + {&comma-char} + {&add-def} + {&comma-char} + {&lookup} ) = 0  THEN 
  DO:
    MESSAGE
      SUBSTITUTE("Неверное значение параметра p-mode=&1", p-mode)
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
  /*------------------------------------------------------------------------------
    Purpose:     DISABLE the User Interface
    Parameters:  <none>
    Notes:       Here we clean-up the user-interface by deleting
                 dynamic widgets we have created and/or hide 
                 frames.  This procedure is usually called when
                 we are ready to "clean-up" after running.
  ------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
  /*------------------------------------------------------------------------------
    Purpose:     ENABLE the User Interface
    Parameters:  <none>
    Notes:       Here we display/view/enable the widgets in the
                 user-interface.  In addition, OPEN all queries
                 associated with each FRAME and BROWSE.
                 These statements here are based on the "Other 
                 Settings" section of the widget Property Sheets.
  ------------------------------------------------------------------------------*/
  DISPLAY rs-ext-obj-type f-ext-obj-code f-ext-obj-guidobj f-ext-obj-guid 
    WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-ext-obj-type f-ext-obj-code f-ext-obj-guidobj 
    f-ext-obj-guid 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
  ASSIGN
    rs-ext-obj-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = {&shop} + {&comma-char} + {&shop} + {&comma-char} +
    {&stock} + {&comma-char} + {&stock} + {&comma-char} +
    "Нет деления на типы объектов" + {&comma-char} + "" +
    (if p-ext-obj-type = {&stock}
    then  ({&comma-char} +
    "+100000 (для DKlink)" + {&comma-char} + "+100000")
    else '')
    .
  if p-esys-type = integer({&openxml-type-mercury}) then 
  do:

    if p-ext-guid <> "" then 
    do:
      do ii = 1 to NUM-ENTRIES (p-ext-guid,{&delim-cmd}):
        if ii = 1 then v-ext-guidobj = ENTRY (ii,p-ext-guid,{&delim-cmd}) .
        else v-ext-guid = ENTRY (ii,p-ext-guid,{&delim-cmd}) .
      end.  
    end. 
  
    ASSIGN
      rs-ext-obj-type           = ''
      f-ext-obj-code            = p-ext-obj-code
      f-ext-obj-guidobj         = v-ext-guidobj
      f-ext-obj-guid            = v-ext-guid
      FRAME {&FRAME-NAME}:TITLE = p-title
      .

    DISPLAY
      rs-ext-obj-type
      f-ext-obj-code
      f-ext-obj-guid
      f-ext-obj-guidobj
      WITH FRAME {&frame-name}.
    ENABLE
      B-exit
      b-quit
      B-Help
      WITH FRAME {&frame-name}.

    if p-mode = {&lookup} then 
    do:
      DISABLE
        rs-ext-obj-type
        f-ext-obj-code
        f-ext-obj-guid
        f-ext-obj-guidobj
        WITH FRAME {&frame-name}.
    end.
    else 
    do:
      DISABLE
        rs-ext-obj-type
        f-ext-obj-code
        WITH FRAME {&frame-name}.
  
      if p-ext-obj-type = {&shop} or p-ext-obj-type = {&stock} then 
      do:
        ENABLE
          f-ext-obj-guid
          WITH FRAME {&frame-name}.
        HIDE
          f-ext-obj-guidobj
          IN frame {&frame-name} .
      end.
      else 
      do:
        if p-ext-obj-type = {&cmp} and p-ext-obj-code = STRING (v-cntxt-host-code-obj) then 
        do:
          ENABLE
            f-ext-obj-guidobj
            WITH FRAME {&frame-name}.
          HIDE
            f-ext-obj-guid
            IN frame {&frame-name} .
        end.
        else 
        do:
          ENABLE
            f-ext-obj-guid
            f-ext-obj-guidobj
            WITH FRAME {&frame-name}.
        end.
      end.  
      VIEW FRAME {&frame-name}.
    end.   
  end.
  else 
  do:
    ASSIGN
      rs-ext-obj-type           = ''
      f-ext-obj-code            = p-ext-obj-code
      FRAME {&FRAME-NAME}:TITLE = p-title
      .
    DISPLAY
      rs-ext-obj-type
      f-ext-obj-code
      WITH FRAME {&frame-name}.

    ENABLE
      B-exit
      b-quit
      B-Help
      WITH FRAME {&frame-name}.

    if p-mode = {&lookup} then 
    do:
      DISABLE
        rs-ext-obj-type
        f-ext-obj-code
        WITH FRAME {&frame-name}.
    end.
    else 
    do:
      ENABLE
        rs-ext-obj-type
        f-ext-obj-code
        WITH FRAME {&frame-name}.
    end.  
    HIDE
      f-ext-obj-guid
      f-ext-obj-guidobj
      IN frame {&frame-name} .
  end.
  VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
  ASSIGN
    FRAME {&FRAME-NAME}
    rs-ext-obj-type
    f-ext-obj-code
    f-ext-obj-guid
    f-ext-obj-guidobj
    .
  if p-ext-obj-type = {&stock}
    and rs-ext-obj-type = "+100000"
    and f-ext-obj-code <> string ( integer(p-ext-obj-code) + 100000 ) then 
  do:
    MESSAGE
      "Неверно определен код объекта во внешней системе" skip
      "Для склада он должен равняться номеру склада + 100000"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  end.
  if p-ext-obj-type = {&shop}
    and rs-ext-obj-type = "+100000"
    and f-ext-obj-code <> p-ext-obj-code then 
  do:
    MESSAGE
      "Неверно определен код объекта во внешней системе" skip
      "Для магазина он должен равняться номеру магазина"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  end.
  IF f-ext-obj-code = ?
    OR f-ext-obj-code = "" THEN 
  DO:
    MESSAGE
      "Неверно определен код объекта во внешней системе"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.

  END.
  
  ASSIGN
    p-ext-obj-type = (if rs-ext-obj-type = "+100000"
                  then ""
                  ELSE rs-ext-obj-type)
    p-ext-obj-code = f-ext-obj-code
    p-ext-guid     = f-ext-obj-guidobj + {&delim-cmd} + f-ext-obj-guid
    p-ok           = YES
    .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

