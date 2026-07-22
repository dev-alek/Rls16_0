&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Группировка записей истории производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-sort-type      as integer      no-undo.
define input parameter p-doc-code       as character    no-undo.
define input parameter p-date-from      as date         no-undo.
define input parameter p-date-to        as date         no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-userid         as character    no-undo.
define output parameter p-out-sort-type as integer      no-undo.
define output parameter p-out-doc-code  as character    no-undo.
define output parameter p-out-date-from as date         no-undo.
define output parameter p-out-date-to   as date         no-undo.
define output parameter p-out-level     as integer      no-undo.
define output parameter p-out-userid    as character    no-undo.
define output parameter p-ok-pressed    as logical      no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Группировка записей истории производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/showinf.i  }

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help rs-group-type ~
fi-level fi-doc-code fi-date-from fi-date-to fi-userid bt-sel-obj
&Scoped-Define DISPLAYED-OBJECTS rs-group-type fi-level fi-doc-code ~
fi-date-from fi-date-to fi-userid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE VARIABLE fi-date-from AS DATE FORMAT "99.99.9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-to AS DATE FORMAT "99.99.9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-level AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "уровень"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE fi-userid AS CHARACTER FORMAT "X(256)":U
     LABEL "имя"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rs-group-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"По документу", 2,
"Диапазон дат", 3,
"Пользователь", 4
     SIZE 19.5 BY 5 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.25 COL 1.5
     b-cancel AT ROW 1.25 COL 11.5
     b-help AT ROW 1.25 COL 52
     rs-group-type AT ROW 2.75 COL 2.5 NO-LABEL
     fi-level AT ROW 2.75 COL 26 COLON-ALIGNED
     fi-doc-code AT ROW 4 COL 26 COLON-ALIGNED
     fi-date-from AT ROW 5.25 COL 26 COLON-ALIGNED
     fi-date-to AT ROW 5.25 COL 46 COLON-ALIGNED
     fi-userid AT ROW 6.5 COL 26 COLON-ALIGNED
     bt-sel-obj AT ROW 6.5 COL 42
     SPACE(17.11) SKIP(0.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группировка записей истории"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группировка записей истории */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-ok-pressed = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выбор */
DO:
    assign
        rs-group-type
        fi-doc-code
        fi-date-from
        fi-date-to
        fi-level
        fi-userid
    .
    run assign-out-param in this-procedure.
    assign
        p-ok-pressed = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-userid    as character  no-undo.
    define variable v-ok        as logical    no-undo.
    run str/fbrhstlu.w (
          output v-userid
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка выбора пользователя из списка."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        assign
            fi-userid       = v-userid
            rs-group-type   = 4
        .
        display
            fi-userid
            rs-group-type
        with frame {&frame-name}.
        apply "value-changed" to rs-group-type.
        apply "entry" to fi-level.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-group-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-group-type Dialog-Frame
ON VALUE-CHANGED OF rs-group-type IN FRAME Dialog-Frame
DO:
    assign
        rs-group-type
    .
    run ui-enable-all in this-procedure.
    run ui-disable in this-procedure.
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
{ gbl/ed_date.i fi-date-from }
{ gbl/ed_date.i fi-date-to   }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-enable-all in this-procedure.
    run ui-disable in this-procedure.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-out-param Dialog-Frame
PROCEDURE assign-out-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        p-out-sort-type   = rs-group-type
        p-out-doc-code    = fi-doc-code
        p-out-date-from   = fi-date-from
        p-out-date-to     = fi-date-to
        p-out-level       = fi-level
        p-out-userid      = fi-userid
    .
end.
END PROCEDURE. /* assign-out-param */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY rs-group-type fi-level fi-doc-code fi-date-from fi-date-to fi-userid
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help rs-group-type fi-level fi-doc-code fi-date-from
         fi-date-to fi-userid bt-sel-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    assign
        rs-group-type = ( if p-sort-type = 0 then 1 else p-sort-type )
        fi-doc-code   = p-doc-code
        fi-date-from  = ( if p-date-from = ? then v-today else p-date-from )
        fi-date-to    = ( if p-date-to = ?   then v-today else p-date-to   )
        fi-level      = p-level
        fi-userid     = p-userid
    .
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable Dialog-Frame
PROCEDURE ui-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    case rs-group-type
    :
        when 1
        then do:
            disable
                fi-doc-code
                fi-date-from
                fi-date-to
                fi-userid
            with frame {&frame-name}.
        end.        /* when 1 */
        when 2
        then do:
            disable
                fi-date-from
                fi-date-to
                fi-level
                fi-userid
            with frame {&frame-name}.
        end.        /* when 2 */
        when 3
        then do:
            disable
                fi-doc-code
                fi-userid
            with frame {&frame-name}.
        end.        /* when 3 */
        when 4
        then do:
            disable
                fi-date-from
                fi-date-to
                fi-doc-code
            with frame {&frame-name}.
        end.        /* when 4 */
    end case.       /* case rs-group-type */
end.
END PROCEDURE. /* ui-disable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable-all Dialog-Frame
PROCEDURE ui-enable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    enable
        rs-group-type
        fi-doc-code
        fi-date-from
        fi-date-to
        fi-level
        fi-userid
    with frame dialog-frame.
end.
END PROCEDURE. /* ui-enable-all */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
