&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE dis-card-property
       field rw-option as character
       field prop-label as character
       field node-label as character
       field data-type as character
       field range as integer
       INDEX attrc is
       UNIQUE PRIMARY
       prop-label
       node-label
       dt-code
       host-code
       obj-type
       obj-code
       INDEX attrcl is UNIQUE
       dt-code
       node-code
       host-code
       obj-type
       obj-code
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Классы ограничений для ДК

Автор: Шкляр Елена Львовна
Дата создания: 15/11/03
Author: Elena Shklyar
Creation date: 15/11/03

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-sum-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dt-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-emitent-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-d-card AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR temp-dis-card-property.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Классы ограничений для ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ ref/dc-prop.i }
{ gbl/getcntxt.i DEF }
define variable is-elved-chr as character no-undo .
define variable par-type as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-for f-to 
&Scoped-Define DISPLAYED-OBJECTS f-for f-to 

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

DEFINE VARIABLE f-for AS DECIMAL FORMAT ">>>>>>>>>>>>>>>>>>>9":U INITIAL 0 
     LABEL "от" 
     VIEW-AS FILL-IN 
     SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE f-to AS DECIMAL FORMAT ">>>>>>>>>>>>>>>>>>>9":U INITIAL 0 
     LABEL "до" 
     VIEW-AS FILL-IN 
     SIZE 50 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 78
     f-for AT ROW 4 COL 9 COLON-ALIGNED
     f-to AT ROW 6 COL 9 COLON-ALIGNED
     "Диапазон номеров карт:" VIEW-AS TEXT
          SIZE 38 BY 1.04 AT ROW 2.46 COL 11.13 WIDGET-ID 4
     SPACE(32.49) SKIP(5.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Классы ограничений для ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-dis-card-property T "?" NO-UNDO ub dis-card-property
      ADDITIONAL-FIELDS:
          field rw-option as character
          field prop-label as character
          field node-label as character
          field data-type as character
          field range as integer
          INDEX attrc is
          UNIQUE PRIMARY
          prop-label
          node-label
          dt-code
          host-code
          obj-type
          obj-code
          INDEX attrcl is UNIQUE
          dt-code
          node-code
          host-code
          obj-type
          obj-code
          
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Классы ограничений для ДК */
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
{ gbl/getcntxt.i get }
  IF p-mode <> {&add-def}
  AND p-mode <> {&UPDATE}
  AND p-mode <> {&lookup} THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code.

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
  DISPLAY f-for f-to 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-for f-to 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.

FOR EACH temp-dis-card-property where
       temp-dis-card-property.dtm-code = p-dtm-code
    and temp-dis-card-property.sum-id = p-sum-id
    and temp-dis-card-property.host-code = p-host-code
    and temp-dis-card-property.obj-type = p-obj-type
    and temp-dis-card-property.obj-code = p-obj-code
    :
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_dc-limit_minnum} THEN DO:
        f-for = temp-dis-card-property.property-value-decimal.
     END.
     WHEN {&dc_prop_dc-limit_maxnum} THEN DO:
        f-to = temp-dis-card-property.property-value-decimal.
     END.
  END CASE.
END.

DISPLAY
f-for
f-to
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-for WHEN p-mode <> {&LOOKUP}
f-to WHEN p-mode <> {&LOOKUP}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP}  THEN DO:
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  .
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
ASSIGN
FRAME {&FRAME-NAME}
f-for
f-to
.
IF f-for = ?
or f-to = ?
THEN DO:
  MESSAGE
  "Не задан диапазон номеров ДК"
  view-as ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.

FOR EACH buf_prop-map NO-LOCK WHERE
        buf_prop-map.dtm-code = p-dtm-code
     and buf_prop-map.node-code > 0:
  FIND FIRST temp-dis-card-property WHERE
            temp-dis-card-property.d-card = p-d-card
      AND   temp-dis-card-property.dt-code = p-dt-code
      AND   temp-dis-card-property.node-code = buf_prop-map.node-code
      AND   temp-dis-card-property.host-code = p-host-code
      AND   temp-dis-card-property.obj-type = p-obj-type
      AND   temp-dis-card-property.obj-code = p-obj-code NO-ERROR.
  IF NOT AVAILABLE temp-dis-card-property THEN DO:
    CREATE temp-dis-card-property.
    ASSIGN
    temp-dis-card-property.d-card = p-d-card
    temp-dis-card-property.dt-code = p-dt-code
    temp-dis-card-property.dtm-code = p-dtm-code
    temp-dis-card-property.sum-id = p-sum-id
    temp-dis-card-property.node-code = buf_prop-map.node-code
    temp-dis-card-property.host-code = p-host-code
    temp-dis-card-property.obj-type = p-obj-type
    temp-dis-card-property.obj-code = p-obj-code
    temp-dis-card-property.prop-label = buf_prop-head.prop-label
    temp-dis-card-property.node-label = buf_prop-map.node-label
    temp-dis-card-property.data-type = buf_prop-map.node-value-type
    .
  END.
END.
FOR EACH temp-dis-card-property
   where temp-dis-card-property.d-card = p-d-card
and temp-dis-card-property.dtm-code = p-dtm-code
and temp-dis-card-property.dt-code = p-dt-code
and temp-dis-card-property.host-code = p-host-code
and temp-dis-card-property.obj-type = p-obj-type
and temp-dis-card-property.obj-code = p-obj-code
   :
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_dc-limit_minnum} THEN DO:
        temp-dis-card-property.property-value-decimal = f-for .
     END.
     WHEN {&dc_prop_dc-limit_maxnum} THEN DO:
        temp-dis-card-property.property-value-decimal = f-to .
     END.
  END CASE.
END.
ASSIGN
p-setted = YES
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

