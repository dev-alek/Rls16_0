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

Калькулятор

Автор: Перваков Михаил Сергеевич
Дата создания: 12/21/01
Author: Mikhail Pervakov
Creation date: 12/21/01

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input-output parameter p-calc-value    as character no-undo .
define input        parameter p-result-format as character no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Калькулятор".
{ cmp/vssrevis.i "substitute('&1|&2',p-calc-value,p-result-format)" }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help FILL-IN-operand1 ~
cb-operation FILL-IN-operand2 fi-operation-description ~
fi-operation-description-2
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-operand1 cb-operation ~
FILL-IN-operand2 FILL-IN-result fi-operation-description ~
fi-operation-description-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-operation AS CHARACTER FORMAT "X(256)":U INITIAL "+"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "+","-","*","/"
     DROP-DOWN-LIST
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-operation-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 54 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-operation-description-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Равняется:"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-operand1 AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-operand2 AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-result AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     FILL-IN-operand1 AT ROW 3 COL 12.38 COLON-ALIGNED NO-LABEL
     cb-operation AT ROW 4.25 COL 3 COLON-ALIGNED NO-LABEL
     FILL-IN-operand2 AT ROW 5.5 COL 12.5 COLON-ALIGNED NO-LABEL
     FILL-IN-result AT ROW 7.5 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-operation-description AT ROW 4.5 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-operation-description-2 AT ROW 7.75 COL 2.5 NO-LABEL
     SPACE(70.99) SKIP(1.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Калькулятор"
         CANCEL-BUTTON b-quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-operation-description-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-result IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Калькулятор */
DO:
  define variable v-result-value as character no-undo .
  define variable v-calc-value   as decimal   no-undo .

  assign
    v-calc-value   = decimal(FILL-IN-result :screen-value )
    v-result-value = string(v-calc-value
                           ,p-result-format
                           ) no-error
  .
  if index(v-result-value, '?') > 0
  then do:
    message
      "Рассчитанное значение не может быть присвоено" skip
      "Результат" FILL-IN-result :screen-value skip
      "Формат числа" p-result-format skip
      view-as alert-box error .
    return no-apply .
  end.
  if decimal(entry(1,v-result-value, '%':u)) <> v-calc-value
  then do:
    define variable v-ok as logical   no-undo .
    assign
      v-ok = false
    .
    message
      "Рассчитанное значение" FILL-IN-result :screen-value skip
      "Будет округлено до" v-result-value skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true then do:
      return no-apply .
    end.
  end.

  assign
    p-calc-value = v-result-value
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Калькулятор */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-operation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-operation Dialog-Frame
ON RETURN OF cb-operation IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'entry':u to fill-in-operand2 .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-operation Dialog-Frame
ON VALUE-CHANGED OF cb-operation IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-operand1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand1 Dialog-Frame
ON ANY-PRINTABLE OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand1 Dialog-Frame
ON LEAVE OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand1 Dialog-Frame
ON RETURN OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'entry':u to cb-operation .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand1 Dialog-Frame
ON VALUE-CHANGED OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-operand2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand2 Dialog-Frame
ON ANY-PRINTABLE OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand2 Dialog-Frame
ON LEAVE OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand2 Dialog-Frame
ON RETURN OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'go':u to frame {&frame-name} .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-operand2 Dialog-Frame
ON VALUE-CHANGED OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  do with frame {&frame-name}:
    assign
      fill-in-operand1 :screen-value = string(decimal(p-calc-value)
                                       , fill-in-operand1 :format
                                       )
    .
  end. /* do with frame */

  run make-operation in this-procedure .
  apply 'entry':u to fill-in-operand1 in frame {&frame-name} .

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
  DISPLAY FILL-IN-operand1 cb-operation FILL-IN-operand2 FILL-IN-result
          fi-operation-description fi-operation-description-2
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help FILL-IN-operand1 cb-operation FILL-IN-operand2
         fi-operation-description fi-operation-description-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-operation Dialog-Frame
PROCEDURE make-operation :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}:
    case cb-operation :screen-value
    :
      when '+':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         +
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "ПЛЮС"
        .
      end.
      when '-':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         -
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "МИНУС"
        .
      end.
      when '*':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         *
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "УМНОЖИТЬ НА"
        .
      end.
      when '/':u then do:
        assign
          fill-in-result :screen-value = string(
                                        decimal(fill-in-operand1 :screen-value)
                                        /
                                        decimal(fill-in-operand2 :screen-value)
                                        , fill-in-operand1 :format
                                        )
          fi-operation-description :screen-value = "РАЗДЕЛИТЬ НА"
        .
      end.
    end case .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME