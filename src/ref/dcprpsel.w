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

Выбор объекта, среза, свойства ДК


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code as integer no-undo .
define input parameter p-curr-obj-type as character no-undo .
define input parameter p-curr-obj-code as integer no-undo .
define input-output parameter p-dtm-code as integer no-undo .
define input-output parameter p-dt-code as integer no-undo .
define input-output parameter p-node-code as integer no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
define INPUT-OUTPUT parameter p-cond as character no-undo .
DEFINE output PARAMETER p-value-character-low AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-value-character-high AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-value-date-low AS date NO-UNDO.
DEFINE output PARAMETER p-value-date-high AS date NO-UNDO.
DEFINE output PARAMETER p-value-decimal-low AS decimal NO-UNDO.
DEFINE output PARAMETER p-value-decimal-high AS decimal NO-UNDO.
DEFINE output PARAMETER p-value-integer-low AS integer NO-UNDO.    
DEFINE output PARAMETER p-value-integer-high AS integer NO-UNDO.    
DEFINE output PARAMETER p-value-logical-low AS logical NO-UNDO.
DEFINE output PARAMETER p-value-logical-high AS logical NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объекта, среза, свойства ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/operlist.i }

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-short-mode as logical no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
define buffer buf_prop-map for ub.prop-map .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-Help b-dtm-code b-dt-code ~
RS-range CB-obj-type f-low-decimal f-low-logical f-low-date f-low-integer ~
f-low-character f-high-logical f-high-integer f-high-character f-high-date ~
f-high-decimal rs-cond F-host-name F-obj-name 
&Scoped-Define DISPLAYED-OBJECTS f-dtm-code f-dtm-name f-dt-code f-sum-id ~
f-node-code f-node-label RS-range f-host-code CB-obj-type f-obj-code ~
f-low-decimal f-low-logical f-low-date f-low-integer f-low-character ~
f-high-logical f-high-integer f-high-character f-high-date f-high-decimal ~
rs-cond F-host-name F-obj-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dt-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON b-dtm-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-host 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-node-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3" 
     SIZE 3 BY 1.

DEFINE BUTTON B-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2" 
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-dt-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код среза" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код объ-та" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-high-character AS CHARACTER FORMAT "X(256)":U 
     LABEL "Верхняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-high-date AS DATE FORMAT "99/99/9999":U INITIAL ? 
     LABEL "Верхняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-high-decimal AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Верхняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-high-integer AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Верхняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Фирма" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-host-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 56.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-low-character AS CHARACTER FORMAT "X(256)":U 
     LABEL "Нижняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-low-date AS DATE FORMAT "99/99/9999":U INITIAL ? 
     LABEL "Нижняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-low-decimal AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Нижняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-low-integer AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Нижняя граница" 
     VIEW-AS FILL-IN 
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-node-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код св-ва" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-node-label AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 56.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-cond AS CHARACTER INITIAL ">" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "=", "=",
">", ">",
"<", "<",
">=", ">=",
"<=", "<="
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-range AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Глобально", "global",
"Фирма", "firm",
"Объект", "object"
     SIZE 36 BY 1 NO-UNDO.

DEFINE VARIABLE f-high-logical AS LOGICAL INITIAL no 
     LABEL "Верхняя граница" 
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-low-logical AS LOGICAL INITIAL no 
     LABEL "Нижняя граница" 
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 76
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-dtm-code AT ROW 2.6 COL 1.5 WIDGET-ID 34
     b-dtm-code AT ROW 2.6 COL 22 WIDGET-ID 32
     f-dtm-name AT ROW 2.6 COL 25 NO-LABEL WIDGET-ID 30
     f-dt-code AT ROW 3.6 COL 2.5 WIDGET-ID 36
     b-dt-code AT ROW 3.6 COL 22 WIDGET-ID 38
     f-sum-id AT ROW 3.6 COL 25 NO-LABEL WIDGET-ID 40
     f-node-code AT ROW 4.6 COL 2.5 WIDGET-ID 44
     b-node-code AT ROW 4.6 COL 22 WIDGET-ID 42
     f-node-label AT ROW 4.6 COL 25 NO-LABEL WIDGET-ID 46
     RS-range AT ROW 6.33 COL 25.5 NO-LABEL WIDGET-ID 58
     f-host-code AT ROW 7.67 COL 12 COLON-ALIGNED WIDGET-ID 54
     B-host AT ROW 7.67 COL 22 WIDGET-ID 48
     CB-obj-type AT ROW 9.17 COL 1.5 NO-LABEL WIDGET-ID 52
     f-obj-code AT ROW 9.17 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     B-obj AT ROW 9.17 COL 22 WIDGET-ID 50
     f-low-decimal AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 68
     f-low-logical AT ROW 10.6 COL 21.5 WIDGET-ID 90
     f-low-date AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 86
     f-low-integer AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 80
     f-low-character AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 82
     f-high-logical AT ROW 12.47 COL 21.5 WIDGET-ID 92
     f-high-integer AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 78
     f-high-character AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 84
     f-high-date AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 88
     f-high-decimal AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 66
     rs-cond AT ROW 14.33 COL 21.5 NO-LABEL WIDGET-ID 70
     F-host-name AT ROW 7.67 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     F-obj-name AT ROW 9.17 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     SPACE(15.99) SKIP(7.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выбор свойств ДК"
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
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-host IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-node-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-obj IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX CB-obj-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-dt-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       f-high-character:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-high-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-high-decimal:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-high-integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-host-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       f-low-character:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-low-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-low-decimal:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       f-low-integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-node-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-node-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-obj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       f-obj-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-sum-id IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор свойств ДК */
DO:
  assign
  p-dtm-code  = f-dtm-code
  p-dt-code   = f-dt-code
  p-node-code = f-node-code
  p-host-code = f-host-code
  p-obj-type  = cb-obj-type
  p-obj-code  = f-obj-code
  p-value-character-low = f-low-character
  p-value-character-high = f-high-character
  p-value-date-low = f-low-date
  p-value-date-high = f-high-date
  p-value-decimal-low = f-low-decimal
  p-value-decimal-high = f-high-decimal
  p-value-integer-low = f-low-integer
  p-value-integer-high = f-high-integer
  p-value-logical-low = f-low-logical
  p-value-logical-high = f-high-logical
  p-cond = rs-cond
  p-ok = YES
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор свойств ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dt-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dt-code Dialog-Frame
ON CHOOSE OF b-dt-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
if f-dtm-code = ?
or f-dtm-code = 0
then do:
  message
  "Не выбран объект-операнд"
  view-as alert-box error .
  undo, return no-apply.
end.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input (if f-dtm-code = ?
                      then {&table_dis-card-property}
                      else "dtm-code")
              ,input (if f-dtm-code = ? then 0 else f-dtm-code)
              ,input '':U
              ,input '':U /*p-caller-id*/
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  assign
  f-dt-code = ?
  f-sum-id = '':U.
  DISPLAY
  f-sum-id
  f-dt-code
  WITH FRAME {&FRAME-NAME}.
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
if buf_prop-ref.dt-code = f-dt-code then return no-apply.
ASSIGN
f-dt-code = buf_prop-ref.dt-code
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
f-dt-code
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dtm-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dtm-code Dialog-Frame
ON CHOOSE OF b-dtm-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
 run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,input "general-view"
                         ,input {&prop-head-gen-dc-prop}
                         ,input-output v-rid-list ) NO-ERROR.
 IF ERROR-STATUS:error OR v-rid-list = '':U THEN DO:
    UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_prop-head NO-LOCK WHERE
           recid(buf_prop-head) = INTEGER(v-rid-list) NO-ERROR.
 IF NOT AVAILABLE buf_prop-head  THEN DO:
    assign
    f-dt-code = ?
    f-sum-id = '':U
    f-dtm-code = ?
    f-dtm-name = '':U
    f-node-code = ?
    f-node-label = '':U
    .
    DISABLE
    b-node-code
    WITH FRAME {&FRAME-NAME}.
    DISPLAY
    f-sum-id
    f-dtm-code
    f-dtm-name
    f-dt-code
    f-node-code
    f-node-label
    WITH FRAME {&FRAME-NAME}.
   RETURN.
 END.
 if buf_prop-head.dtm-code = f-dtm-code then return no-apply.
 assign
 f-dtm-code = buf_prop-head.dtm-code
 f-dtm-name = buf_prop-head.prop-label
 .
 display
 f-dtm-code
 f-dtm-name
 with frame {&frame-name} .
 ENABLE
 b-node-code
 WITH FRAME {&FRAME-NAME}.
 RUN enable-disable-rs-range IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-host Dialog-Frame
ON CHOOSE OF B-host IN FRAME Dialog-Frame /* Btn 1 */
DO:
  IF f-dtm-code = ?
  OR f-dtm-code = 0 THEN DO:
    MESSAGE
    "Не выбран объект-операнд"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
  END.
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-node-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-node-code Dialog-Frame
ON CHOOSE OF b-node-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
IF f-dtm-code = ?
OR f-dtm-code = 0  THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.
run rul/prop-map-s.w (
                input parparentproc
              ,input 'b-sel'
              ,input "dtm-code"
              ,input f-dtm-code
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  assign
  f-node-code = ?
  f-node-label = '':U.
  DISPLAY
  f-node-code
  f-node-label
  WITH FRAME {&FRAME-NAME}.
  return.
end.
find first buf_prop-map no-lock where
          recid(buf_prop-map) = integer(v-ref-list) no-error.
if not available buf_prop-map then return.
if buf_prop-map.dtm-code = f-dtm-code
AND buf_prop-map.node-code = f-node-code then return no-apply.
ASSIGN
f-node-code = buf_prop-map.node-code
f-node-label = buf_prop-map.node-label.
DISPLAY
f-node-code
f-node-label
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Btn 1 */
DO:
IF f-dtm-code = ?
OR f-dtm-code = 0 THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.

  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-range Dialog-Frame
ON VALUE-CHANGED OF RS-range IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-range.
  CASE rs-range:
      WHEN "GLOBAL":U THEN DO:
         ASSIGN
         f-host-code = 0
         f-host-name = '':U
         cb-obj-type = '':U
         f-obj-code = 0
         f-obj-name = '':U
         .
         DISABLE
         b-host
         b-obj
         WITH FRAME {&FRAME-NAME}.
         DISPLAY
         f-host-code
         f-host-name
         cb-obj-type
         f-obj-code
         f-obj-name
         WITH FRAME {&FRAME-NAME}.

      END.
      WHEN {&company} THEN DO:
          ASSIGN
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-obj
          WITH FRAME {&FRAME-NAME}.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          b-host
          WITH FRAME {&FRAME-NAME}.
      END.
      WHEN {&g___object} THEN DO:
          ASSIGN
          f-host-code = 0
          f-host-name = '':U
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-host
          WITH FRAME {&FRAME-NAME}.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          b-obj
          WITH FRAME {&FRAME-NAME}.
      END.
  END CASE.

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
  { gbl/getcntxt.i get }
  if p-dtm-code <> ? then do:
    FIND FIRST buf_prop-head NO-LOCK WHERE
            buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-head THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dtm-code" p-dtm-code SKIP
        "Нет объекта-операнда c кодом"  p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-dt-code <> ? then do:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dt-code = p-dt-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-ref THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Нет среза c кодом"  p-dt-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
    if p-dtm-code = ? then do:
      p-dtm-code = buf_prop-ref.dtm-code .
    end.
    else do:
      if buf_prop-ref.dtm-code <> p-dtm-code then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Срез c кодом"  p-dt-code "принадлежит объекту-операнду" buf_prop-ref.dtm-code skip
        "а код объекта-операнда (p-dtm-code) = " p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
      end.
    end.
    if p-node-code <> ?
    then do:
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = p-dtm-code
            and buf_prop-map.node-code = p-node-code no-error.
      if not available buf_prop-map then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-node-code" p-node-code SKIP
        substitute("Не найдейно свойство &1 для объекта-операнда &2"
                    ,p-node-code
                    ,p-dtm-code) skip
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
      end.
    end.
  end.
  run Myenable in this-procedure .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-disable-rs-range Dialog-Frame 
PROCEDURE enable-disable-rs-range :
DEFINE VARIABLE v-range AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
v-range = "global" + {&delim-par} + {&company} + {&delim-par} + {&g___object}.
ASSIGN
f-host-code = 0
cb-obj-type = '':U
f-obj-code = 0
f-host-name = '':U
f-obj-name = '':U
.
DISPLAY
f-host-code
cb-obj-type
f-obj-code
f-host-name
f-obj-name
WITH FRAME {&FRAME-NAME}.
ENABLE
b-host
b-obj
WITH FRAME {&FRAME-NAME}.
FIND FIRST buf_prop-head NO-LOCK WHERE 
         buf_prop-head.dtm-code = f-dtm-code NO-ERROR.
if available buf_prop-head then do:
  if buf_prop-head.storage-place = '':U
  or buf_prop-head.storage-place = {&question-mark}
  or buf_prop-head.storage-place = ? then do:
    rs-range:disable(radio-label("global", rs-range:radio-buttons)) IN FRAME {&FRAME-NAME}.
    entry(lookup("global", v-range, {&delim-par}), v-range,  {&delim-par}) = '':U.
  end.
  if buf_prop-head.storage-place-host = '':U
  or buf_prop-head.storage-place-host = {&question-mark}
  or buf_prop-head.storage-place-host = ? then do:
    rs-range:disable(radio-label({&company}, rs-range:radio-buttons))  IN FRAME {&FRAME-NAME}.
    DISABLE b-host WITH FRAME {&FRAME-NAME}.
    entry(lookup({&company}, v-range, {&delim-par}), v-range,  {&delim-par}) = '':U.
  end.
  if buf_prop-head.storage-place-obj = '':U
  or buf_prop-head.storage-place-obj = {&question-mark}
  or buf_prop-head.storage-place-obj = ? then do:
    rs-range:disable(radio-label({&g___object}, rs-range:radio-buttons))  IN FRAME {&FRAME-NAME}.
    DISABLE b-obj WITH FRAME {&FRAME-NAME}.
    entry(lookup({&g___object}, v-range, {&delim-par}), v-range,  {&delim-par}) = '':U.
  end.
  v-range = REPLACE(v-range, {&delim-par} + {&delim-par}, {&delim-par}).
  rs-range = ENTRY(1, v-range, {&delim-par}).
  DISPLAY rs-range WITH FRAME {&frame-name}.
end.
ELSE DO:
  rs-range:disable(radio-label("global", rs-range:radio-buttons)).
  rs-range:disable(radio-label({&company}, rs-range:radio-buttons)).
  rs-range:disable(radio-label({&g___object}, rs-range:radio-buttons)).
END.

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
  DISPLAY f-dtm-code f-dtm-name f-dt-code f-sum-id f-node-code f-node-label 
          RS-range f-host-code CB-obj-type f-obj-code f-low-decimal 
          f-low-logical f-low-date f-low-integer f-low-character f-high-logical 
          f-high-integer f-high-character f-high-date f-high-decimal rs-cond 
          F-host-name F-obj-name 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-Help b-dtm-code b-dt-code RS-range CB-obj-type 
         f-low-decimal f-low-logical f-low-date f-low-integer f-low-character 
         f-high-logical f-high-integer f-high-character f-high-date 
         f-high-decimal rs-cond F-host-name F-obj-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
rs-range:RADIO-BUTTONS IN FRAME {&FRAME-NAME}  = "Объекты" + {&comma-char} + {&g___object} + {&comma-char} +
                        "Фирмы" + {&comma-char} + {&company} + {&comma-char} +
                        "Глобально" + {&comma-char} + "global"
CB-obj-type:list-items = '':U + {&comma-char} + {&shop} + {&comma-char} + {&stock}
rs-range = "global"
f-dtm-code = p-dtm-code
f-dt-code = p-dt-code
f-node-code = p-node-code
.
if available buf_prop-head then do:
  assign
  f-dtm-name = buf_prop-head.prop-name
  .
end.
if available buf_prop-head then do:
  assign
  f-sum-id = buf_prop-ref.sum-id
  .
end.
if available buf_prop-map then do:
  assign
  f-node-label = buf_prop-map.node-label
  .
end.
rs-cond = p-cond.
IF p-host-code <> 0  THEN DO:
FIND FIRST buf_clients NO-LOCK WHERE
         buf_clients.obj-code = p-host-code
      AND buf_clients.obj-type = {&cmp} NO-ERROR.
if available buf_clients then do:
    assign
    f-host-CODE = p-host-code
    f-host-name = buf_clients.obj-name
    .
    DISPLAY
    f-host-code
    f-host-name
    WITH FRAME {&FRAME-NAME}.
END.
END.
IF NOT ( p-obj-type = '':U
         AND p-obj-code = 0) THEN DO:

    FIND FIRST buf_clients NO-LOCK WHERE
           buf_clients.obj-type = p-obj-type
       AND  buf_clients.obj-code = p-obj-code NO-ERROR.
    if available buf_clients then do:
        assign
        f-obj-CODE = buf_clients.obj-code
        CB-obj-type = buf_clients.obj-type
        f-obj-name = buf_clients.obj-name
        .
        DISPLAY
        f-obj-code
        cb-obj-type
        f-obj-name
        WITH FRAME {&FRAME-NAME}.

    END.
END.

ASSIGN
CB-obj-type = p-obj-type
f-obj-code = p-obj-code
.
IF f-obj-code > 0 THEN DO:
    ASSIGN
    rs-range = {&g___object}.
END.
ELSE do:
   IF f-host-code > 0 THEN DO:
     ASSIGN
     rs-range = {&company}.
   END.
   ASSIGN
   rs-range ="global":U.
END.

display
f-dtm-code
f-dtm-name
f-dt-code
f-sum-id
f-node-code
f-node-label
with frame {&frame-name} .
ENABLE
b-quit
b-exit
B-Help
b-dtm-code
b-dt-code
b-node-code
rs-cond
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN enable-disable-rs-range IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-host Dialog-Frame 
PROCEDURE proc-b-host :
define VARIABLE v-host-code LIKE ub.sysconf.host-code no-undo .

define variable v-rid-list as character no-undo .

define buffer buf_clients  for ub.clients.

  do
  on error undo, return error
  :

        run adm/sconfs.w (
              input parParentProc
            , input "b-sel":U
            , input no
            , input v-cntxt-host-code-obj
            , output v-host-code
            , input-output v-rid-list
        ) no-error.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.

      FIND FIRST buf_clients NO-LOCK WHERE
                 buf_clients.obj-code = v-host-code
              AND buf_clients.obj-type = {&cmp} NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      assign
      f-host-CODE = v-host-code
      f-host-name = buf_clients.obj-name
      .
      DISPLAY
      f-host-code
      f-host-name
      WITH FRAME {&FRAME-NAME}.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-obj Dialog-Frame 
PROCEDURE proc-b-obj :
define variable v-rid-list as character no-undo .

define buffer buf_clients  for ub.clients.
define buffer buf_clients-host  for ub.clients.

  do
  on error undo, return error
  :

       run ref/cli-all.w (
                 INPUT parparentproc
                ,INPUT "b-sel"
                ,INPUT {&g___object}
                ,INPUT {&all}
                ,INPUT {&current}
                ,INPUT ?
                ,INPUT ",,,,,,NO,,"
                ,INPUT "lock-cli-type"
                ,output v-rid-list ) NO-ERROR.
     IF v-rid-list = '':U THEN RETURN error.
      FIND FIRST buf_clients NO-LOCK WHERE
          RECID( buf_clients) = INTEGER( v-rid-list ) NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      IF NOT (buf_clients.obj-type = {&shop}
              OR
              buf_clients.obj-type = {&stock})
              THEN DO:
          MESSAGE
          substitute("Неверный тип объекта &1", buf_clients.obj-type)
          VIEW-AS ALERT-BOX ERROR.
          RETURN ERROR.
      END.
      FIND FIRST buf_clients-host NO-LOCK WHERE
                buf_clients-host.obj-type = {&cmp}
          AND   buf_clients-host.obj-code = buf_clients.host-code NO-ERROR.
         IF NOT AVAILABLE buf_clients-host THEN DO:
             MESSAGE
             SUBSTITUTE("Не найдена фирма &1 для объекта &2&3"
                        , buf_clients.host-code
                        , buf_clients.obj-type
                        , buf_clients.obj-code)
              VIEW-AS ALERT-BOX ERROR.
             RETURN ERROR.
         END.
      assign
      f-obj-CODE = buf_clients.obj-code
      CB-obj-type = buf_clients.obj-type
      f-obj-name = buf_clients.obj-name
      f-host-code = buf_clients.host-code
      f-host-name = buf_clients-host.obj-name
      .
      DISPLAY
      f-obj-code
      cb-obj-type
      f-obj-name
      f-host-name
      f-host-code
      WITH FRAME {&FRAME-NAME}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

