&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-FRAME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-FRAME
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание значений по суммам итогов по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/041/06
Author: Bakhtadze Natalya
Creation date: 06/04/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
/*last-change current-values */
DEFINE INPUT-OUTPUT PARAMETER p-sum-id-type AS CHARACTER NO-UNDO.
define INPUT-OUTPUT parameter p-dt-code   AS integer no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
define INPUT-OUTPUT parameter p-r-b AS character no-undo .
define INPUT-OUTPUT parameter p-field AS character no-undo .
define INPUT-OUTPUT parameter p-cond as character no-undo .
define INPUT-OUTPUT parameter p-last-change-date as date no-undo .
define output parameter p-field-des as character no-undo .
define OUTPUT parameter p-low as decimal no-undo .
define OUTPUT parameter p-high as decimal no-undo .
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание значений по суммам итогов по ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/operlist.i }
{ gbl/dct-algo.i }
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
define variable is-temp as logical no-undo .

define variable v-obj-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help Rs-sum-id-type B-sum-id ~
RS-range B-host CB-obj-type B-obj rs-r-b f-low rs-field f-high ~
f-last-change-date rs-cond f-sum-id F-host-name F-obj-name
&Scoped-Define DISPLAYED-OBJECTS Rs-sum-id-type RS-range f-host-code ~
CB-obj-type f-obj-code rs-r-b f-low rs-field f-high f-last-change-date ~
rs-cond f-sum-id F-host-name F-obj-name

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
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

DEFINE BUTTON B-sum-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2"
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-high AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
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

DEFINE VARIABLE f-last-change-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата последнего изменения"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-low AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
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
      VIEW-AS TEXT
     SIZE 46 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE rs-cond AS CHARACTER INITIAL ">"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "=", "=",
">", ">",
"<", "<",
">=", ">=",
"<=", "<="
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-field AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Количество чеков", "num-chk",
"Сумма оплат", "pay-tot-rubl",
"Сумма покупок брутто", "gds-tot-rubl",
"Сумма скидок", "gds-dis-rubl"
     SIZE 26 BY 6.5 NO-UNDO.

DEFINE VARIABLE rs-r-b AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нац. валюта", "rubl",
"Баз.вал.", "base"
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-range AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", "global",
"Фирма", "firm",
"Объект", "object"
     SIZE 36 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-sum-id-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Общие итоги", "general-sum-id",
"Частные итоги", "partial-sum-id"
     SIZE 31 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-FRAME
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     Rs-sum-id-type AT ROW 2.5 COL 2 NO-LABEL
     B-sum-id AT ROW 2.5 COL 33
     RS-range AT ROW 4 COL 2 NO-LABEL
     f-host-code AT ROW 5.5 COL 13 COLON-ALIGNED
     B-host AT ROW 5.5 COL 23
     CB-obj-type AT ROW 7 COL 2.5 NO-LABEL
     f-obj-code AT ROW 7 COL 13 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 7 COL 23
     rs-r-b AT ROW 8.5 COL 2 NO-LABEL
     f-low AT ROW 9 COL 49 COLON-ALIGNED
     rs-field AT ROW 10 COL 3 NO-LABEL
     f-high AT ROW 11 COL 49 COLON-ALIGNED
     f-last-change-date AT ROW 12.73 COL 61.5 COLON-ALIGNED
     rs-cond AT ROW 14.6 COL 50.5 NO-LABEL
     f-sum-id AT ROW 2.5 COL 36 COLON-ALIGNED NO-LABEL
     F-host-name AT ROW 5.77 COL 24 COLON-ALIGNED NO-LABEL
     F-obj-name AT ROW 7.27 COL 24 COLON-ALIGNED NO-LABEL
     SPACE(2.37) SKIP(9.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задание диапазона значений общих или частных итогов по ДК"
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
/* SETTINGS FOR DIALOG-BOX DIALOG-FRAME
                                                                        */
ASSIGN
       FRAME DIALOG-FRAME:SCROLLABLE       = FALSE
       FRAME DIALOG-FRAME:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX CB-obj-type IN FRAME DIALOG-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-host-code IN FRAME DIALOG-FRAME
   NO-ENABLE                                                            */
ASSIGN
       f-host-code:READ-ONLY IN FRAME DIALOG-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN f-obj-code IN FRAME DIALOG-FRAME
   NO-ENABLE                                                            */
ASSIGN
       f-obj-code:READ-ONLY IN FRAME DIALOG-FRAME        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME DIALOG-FRAME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DIALOG-FRAME DIALOG-FRAME
ON WINDOW-CLOSE OF FRAME DIALOG-FRAME /* Задание диапазона значений общих или частных итогов по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit DIALOG-FRAME
ON CHOOSE OF B-exit IN FRAME DIALOG-FRAME /* Ввод */
DO:

  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  p-ok = YES
  p-host-code = (if p-host-code <> f-host-code then f-host-code else p-host-code)
  p-obj-type = (if p-obj-type <> cb-obj-type then cb-obj-type else p-obj-type)
  p-obj-code = (if p-obj-code <> f-obj-code then f-obj-code else p-obj-code)
  p-sum-id-type = (if p-sum-id-type <> rs-sum-id-type then rs-sum-id-type else p-sum-id-type)
  p-dt-code = (if p-dt-code <> integer(f-sum-id:private-data) then integer(f-sum-id) else p-dt-code)
  .
  CASE p-mode:
    WHEN 'last-change' THEN DO:
        ASSIGN
        p-cond = rs-cond
        p-last-change-date = f-last-change-date
        p-field-des = substitute("Дата последнего изменения")
        .

    END.
    WHEN 'current-values' THEN DO:
        ASSIGN
        p-field = (if p-field <> rs-field then rs-field else p-field)
        p-r-b = (if p-r-b <> rs-r-b then rs-r-b else p-r-b)
        p-low = f-low
        p-high = f-high
        p-field-des = substitute("&1 &2"
                                ,  radio-label (
                                    input p-field
                                   ,input rs-field:radio-buttons in frame {&frame-name} )
                               ,  (if p-field = 'num-chk'
                                    then '':U
                                    else radio-label (
                                                      input p-r-b
                                                      ,input rs-r-b:radio-buttons in frame {&frame-name} ) ))
        .

    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-host DIALOG-FRAME
ON CHOOSE OF B-host IN FRAME DIALOG-FRAME /* Btn 1 */
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj DIALOG-FRAME
ON CHOOSE OF B-obj IN FRAME DIALOG-FRAME /* Btn 1 */
DO:
  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sum-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sum-id DIALOG-FRAME
ON CHOOSE OF B-sum-id IN FRAME DIALOG-FRAME /* Btn 1 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input 'dis-tot':U
              ,input 0
              ,input '':U /**/
              ,input '':U /*p-call-id*/
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
ASSIGN
f-sum-id:PRIVATE-DATA = string(buf_prop-ref.dt-code)
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-field
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-field DIALOG-FRAME
ON VALUE-CHANGED OF rs-field IN FRAME DIALOG-FRAME
DO:
  IF rs-field = 'num-chk'
  OR INPUT FRAME {&frame-name} rs-field = 'num-chk' THEN DO:
      ASSIGN
      f-low =0.0
      f-high = 0.0
      .
      HIDE
      f-low
      f-high
      IN FRAME {&FRAME-NAME}.
  END.
  ASSIGN
  rs-field.
  CASE rs-field:
      WHEN "num-chk" THEN DO:
          ASSIGN
          f-low:FORMAT IN FRAME {&FRAME-NAME} = '->>>>>>>>9'
          f-high:FORMAT IN FRAME {&FRAME-NAME} = '->>>>>>>>9'
          .

      END.
      OTHERWISE DO:
          ASSIGN
          f-low:FORMAT IN FRAME {&FRAME-NAME} = '->>>,>>>,>>>,>>9.99'
          f-high:FORMAT IN FRAME {&FRAME-NAME} = '->>>,>>>,>>>,>>9.99'
          .
      END.
  END CASE.
  display
  f-low
  f-high
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-range DIALOG-FRAME
ON VALUE-CHANGED OF RS-range IN FRAME DIALOG-FRAME
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
         f-obj-name = '':U.
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
      WHEN "firm":U THEN DO:
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

      WHEN "object":U THEN DO:
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


&Scoped-define SELF-NAME Rs-sum-id-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-sum-id-type DIALOG-FRAME
ON VALUE-CHANGED OF Rs-sum-id-type IN FRAME DIALOG-FRAME
DO:
ASSIGN
rs-sum-id-type.
CASE rs-sum-id-type:
  WHEN 'general-sum-id':U THEN DO:
    f-sum-id = '':U.
    DISABLE
    b-sum-id
    WITH FRAME {&FRAME-NAME}.
    DISPLAY f-sum-id
    WITH FRAME {&FRAME-NAME}.
  END.
  WHEN 'partial-sum-id':U THEN DO:
    ENABLE
    b-sum-id
    WITH FRAME {&FRAME-NAME}.
  END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-FRAME


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-FRAME  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-FRAME.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-FRAME  _DEFAULT-ENABLE
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
  DISPLAY Rs-sum-id-type RS-range f-host-code CB-obj-type f-obj-code rs-r-b
          f-low rs-field f-high f-last-change-date rs-cond f-sum-id F-host-name
          F-obj-name
      WITH FRAME DIALOG-FRAME.
  ENABLE B-exit b-quit B-Help Rs-sum-id-type B-sum-id RS-range B-host
         CB-obj-type B-obj rs-r-b f-low rs-field f-high f-last-change-date
         rs-cond f-sum-id F-host-name F-obj-name
      WITH FRAME DIALOG-FRAME.
  VIEW FRAME DIALOG-FRAME.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-FRAME}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable DIALOG-FRAME
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
v-tab-order = "b-exit,b-quit,b-help,rs-sum-id,b-sum-id,rs-range,b-host,b-obj,rs-r-b,rs-field,f-low,f-high," +
              "f-last-change-date,rs-cond"
.
ASSIGN
rs-r-b:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "{&abbr_rub}" + {&comma-char} + {&r-b-rubl} + {&comma-char} +
                                              "Баз.вал." + {&comma-char} + {&r-b-base}
CB-obj-type:list-items = '':U + {&comma-char} + {&shop} + {&comma-char} + {&stock}
.

ASSIGN
rs-sum-id-type = (IF p-sum-id-type = '':U THEN 'general-sum-id' ELSE p-sum-id-type).

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
ASSIGN
rs-field = (IF p-field = '':U THEN 'pay-tot-rubl' ELSE p-field).
ASSIGN
rs-r-b = (IF p-r-b = '':U THEN {&r-b-rubl} ELSE p-r-b)
.

if rs-sum-id-type = 'partial-sum-id' then do:
  define variable v-sum-id as character no-undo .
   v-sum-id = dct-algo-get-sum-id-from-dt-code (input p-dt-code).
   if p-dt-code <> 0
  AND CAN-FIND (FIRST ub.prop-ref WHERE
                    ub.prop-ref.sum-id = v-sum-id)
  THEN
  ASSIGN
  f-sum-id:PRIVATE-DATA = string(p-dt-code)
  f-sum-id = dct-algo-get-description-sum-id(input p-dt-code)
  .
end.
IF f-obj-code > 0 THEN DO:
    ASSIGN
    rs-range = "object":U.
END.
ELSE do:
   IF f-host-code > 0 THEN DO:
     ASSIGN
     rs-range = "firm":U.
   END.
   ASSIGN
   rs-range ="global":U.
END.
ASSIGN
f-last-change-date = p-last-change-date
rs-cond = p-cond.

DISPLAY
rs-range
rs-sum-id-type
f-sum-id
f-host-code
CB-obj-type
f-obj-code
rs-r-b
rs-field
rs-cond
f-last-change-date
WITH FRAME {&FRAME-NAME}
.
ENABLE
B-exit
b-quit
B-Help
b-host
b-obj
b-sum-id when p-sum-id-type <> 'general-sum-id':U
rs-r-b
f-low
f-high
rs-field
rs-sum-id-type when p-sum-id-type = '':U
rs-range
rs-cond
f-last-change-date
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" to rs-range.
APPLY "VALUE-CHANGED" to rs-field.
if RS-sum-id-type:SENSITIVE In FRAME {&frame-name} THEN DO:
  APPLY "VALUE-CHANGED" to rs-sum-id-type.
end.
RUN process-mode-interface IN THIS-PROCEDURE ( INPUT p-mode).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-host DIALOG-FRAME
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-obj DIALOG-FRAME
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save DIALOG-FRAME
PROCEDURE proc-save :
DEFINE BUFFER buf_clients for ub.clients.
DEFINE BUFFER buf_sysconf     FOR ub.sysconf.
DEFINE BUFFER buf_prop-ref    FOR ub.prop-ref.
ASSIGN FRAME {&FRAME-NAME}
f-host-code when f-host-code:sensitive in frame {&frame-name}
CB-obj-type when cb-obj-type:sensitive in frame {&frame-name}
f-obj-code   when f-obj-code:sensitive in frame {&frame-name}
rs-sum-id-type when rs-sum-id-type:sensitive in frame {&frame-name}
f-sum-id   when f-sum-id:sensitive in frame {&frame-name}
rs-field   when (rs-field:sensitive in frame {&frame-name} AND rs-field:visible in frame {&frame-name})
rs-r-b  when (rs-r-b:sensitive in frame {&frame-name} AND rs-r-b:visible in frame {&frame-name})
f-low WHEN f-low:VISIBLE IN FRAME {&FRAME-NAME}
f-high WHEN f-high:VISIBLE IN FRAME {&FRAME-NAME}
f-last-change-date WHEN (f-last-change-date:SENSITIVE IN FRAME {&FRAME-NAME} AND f-last-change-date:visible IN FRAME {&FRAME-NAME})
rs-cond WHEN (rs-cond:SENSITIVE IN FRAME {&FRAME-NAME} AND rs-cond:visible IN FRAME {&FRAME-NAME})
.
IF f-host-code <> 0  THEN DO:
find FIRST buf_sysconf NO-LOCK WHERE
         buf_sysconf.host-code = f-host-code  NO-ERROR.
    IF NOT AVAILABLE buf_sysconf THEN DO:
        MESSAGE
        "Неверный номер фирмы"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
END.
IF NOT (cb-obj-type = '':U AND f-obj-code = 0) THEN DO:
  find FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = cb-obj-type
       AND buf_clients.obj-code = f-obj-code NO-ERROR.
    IF NOT AVAILABLE buf_clients THEN DO:
        MESSAGE
        "Неверный номер объекта"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
    IF NOT (buf_clients.obj-type = {&Shop}
            OR
            buf_clients.obj-type = {&Stock})
            THEN DO:
    message
    "Неверный тип объекта"
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.

  END.

END.
IF rs-sum-id-type = 'partial-sum-id':U THEN do:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
             buf_prop-ref.sum-id = f-sum-id NO-ERROR.
   IF NOT AVAILABLE buf_prop-ref THEN DO:
       MESSAGE
       substitute("Неверный частный итог &1", f-sum-id)
       VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
   END.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-mode-interface DIALOG-FRAME
PROCEDURE process-mode-interface :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
CASE p-mode:
  WHEN "last-change" THEN DO:
    HIDE
    f-high IN FRAME {&frame-name}
    f-low
    rs-field
    rs-r-b
    IN FRAME {&frame-name}.
  END.
  WHEN "current-values" THEN DO:
    HIDE
    f-last-change-date IN FRAME {&frame-name}
    rs-cond
    IN FRAME {&frame-name}.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME