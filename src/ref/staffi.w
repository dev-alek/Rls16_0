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

Редактирование данных по персоналу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-role AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-level as CHARACTEr no-undo .
define INPUT-OUTPUT parameter p-db-num like ub.db.db-num no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-staff-code-label AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-staff-code-format AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-password-option AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-password-label AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-password-format AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-notes  AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-staff-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-password AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-start AS date NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-end AS date NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование данных по персоналу".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
define variable is-temp as logical no-undo .
define variable glog as logical no-undo .

define variable v-obj-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-modified AS LOGICAL NO-UNDO.
define buffer buf_role-db for ub.db.
define buffer buf_role-sysconf for ub.sysconf.
define buffer buf_role-clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-db B-host CB-obj-type ~
B-obj f-staff-code f-password f-date-start f-date-end E-notes F-host-name ~
F-obj-name fi-screen-pass
&Scoped-Define DISPLAYED-OBJECTS f-db-num f-host-code CB-obj-type ~
f-obj-code f-staff-code f-password f-date-start f-date-end E-notes ~
F-host-name F-obj-name fi-screen-pass

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

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

DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2"
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE E-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 65.5 BY 3.75 NO-UNDO.

DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Работает с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "№ БД"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-password AS CHARACTER FORMAT "X(10)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-staff-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код персонала"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 12 BY .29
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-db-num AT ROW 3 COL 13 COLON-ALIGNED
     B-db AT ROW 3 COL 23
     f-host-code AT ROW 4.5 COL 13 COLON-ALIGNED
     B-host AT ROW 4.5 COL 23
     CB-obj-type AT ROW 6 COL 2.5 NO-LABEL
     f-obj-code AT ROW 6 COL 13 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 6 COL 23
     f-staff-code AT ROW 8.5 COL 37 COLON-ALIGNED
     f-password AT ROW 10.5 COL 37 COLON-ALIGNED BLANK
     f-date-start AT ROW 12 COL 37 COLON-ALIGNED
     f-date-end AT ROW 12 COL 54 COLON-ALIGNED
     E-notes AT ROW 14 COL 1.5 NO-LABEL
     F-host-name AT ROW 4.75 COL 24 COLON-ALIGNED NO-LABEL
     F-obj-name AT ROW 6.25 COL 24 COLON-ALIGNED NO-LABEL
     fi-screen-pass AT ROW 10.58 COL 37 COLON-ALIGNED NO-LABEL
     SPACE(33.87) SKIP(7.50)
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX CB-obj-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       E-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-db-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-db-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-host-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-obj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-obj-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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


&Scoped-define SELF-NAME B-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-db Dialog-Frame
ON CHOOSE OF B-db IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run proc-b-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF p-mode = {&LOOKUP} THEN RETURN NO-APPLY.
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  p-ok = YES
  p-staff-code = f-staff-code
  p-password = f-password
  p-date-start = f-date-start
  p-date-end = (IF f-date-end:VISIBLE IN FRAME {&FRAME-NAME} THEN f-date-end ELSE p-date-end)
  p-db-num = (if p-db-num <> f-db-num then f-db-num else p-db-num)
  p-host-code = (if p-host-code <> f-host-code then f-host-code else p-host-code)
  p-obj-type = (if p-obj-type <> cb-obj-type then cb-obj-type else p-obj-type)
  p-obj-code = (if p-obj-code <> f-obj-code then f-obj-code else p-obj-code)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-host Dialog-Frame
ON CHOOSE OF B-host IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-password Dialog-Frame
ON ANY-KEY OF f-password IN FRAME Dialog-Frame /* Пароль */
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-password Dialog-Frame
ON VALUE-CHANGED OF f-password IN FRAME Dialog-Frame /* Пароль */
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-staff-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-staff-code Dialog-Frame
ON ANY-PRINTABLE OF f-staff-code IN FRAME Dialog-Frame /* Код персонала */
DO:
  v-modified = YES.
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

{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order }
{ gbl/ed_date.i f-date-start }
{ gbl/ed_date.i f-date-end }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
  IF lookup(p-mode, {&add-def} + {&delim-par} +
                    {&UPDATE} + {&delim-par} +
                    {&LOOKUP} +  {&delim-par} +
                    {&add-def}  + {&comma-char} + 'temp'
                    , {&delim-par} ) = 0  THEN DO:
      MESSAGE
      "Неверный параметр p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
  END.
  if p-mode = {&add-def} + {&comma-char} + 'temp':U then do:
      assign
      p-mode = {&add-def}
      is-temp = yes.
  end.
  CASE p-level :
     when {&role-level-db} then do:
       if p-db-num <> ? then do:
        find first buf_role-db no-lock where
                  buf_role-db.db-num = p-db-num no-error .
        if not available buf_role-db then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-db-num &5 - нет такой БД"
                      , vss-workfile
                      , {&new-line}
                      , vss-revision
                      , vss-description
                      , p-db-num)
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
     when {&role-level-firm} then do:
       if p-host-code <> 0 then do:
        find first buf_role-sysconf no-lock where
                  buf_role-sysconf.host-code = p-host-code no-error .
        if not available buf_role-sysconf then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-host-code &5 - нет такой ФИРМЫВ"
                      , vss-workfile
                      , {&new-line}
                      , vss-revision
                      , vss-description
                      , p-host-code)
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
     when {&role-level-object} then do:
       if p-obj-type <> "":U
       or p-obj-code <> 0 then do:
        find first buf_role-clients no-lock where
                  buf_role-clients.obj-type = p-obj-type
              and buf_role-clients.obj-code = p-obj-code no-error .
        if not available buf_role-clients then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-obj-type p-obj-code &5&6 - нет такого ОБЪЕКТА"
                      , vss-workfile
                      , {&new-line}
                      , vss-revision
                      , vss-description
                      , p-obj-type
                      , p-obj-code
                      )
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
  END CASE.
  ASSIGN
  f-staff-code = p-staff-code
  f-password = p-password
  f-date-start = p-date-start
  .
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY f-db-num f-host-code CB-obj-type f-obj-code f-staff-code f-password
          f-date-start f-date-end E-notes F-host-name F-obj-name fi-screen-pass
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-db B-host CB-obj-type B-obj f-staff-code
         f-password f-date-start f-date-end E-notes F-host-name F-obj-name
         fi-screen-pass
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-codes Dialog-Frame
PROCEDURE fill-codes :
DEFINE VARIABLE v-last-staff-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-work-place AS character NO-UNDO.

  if p-mode = {&add-def} then do:
  IF f-staff-code:SCREEN-VALUE IN FRAME {&FRAME-NAME} <> '':U AND v-modified THEN do:
      return.
  END.
  CASE p-level:
    WHEN {&role-level-db} THEN DO:
      ASSIGN
      v-work-place = STRING(f-db-num, '99999').
    END.
    WHEN {&role-level-firm} THEN DO:
      ASSIGN
      v-work-place = STRING(f-host-code, '99999').
    END.
    WHEN {&role-level-object} THEN DO:
      ASSIGN
      v-work-place = cb-obj-type +  STRING(f-obj-CODE, '999999999').
    END.
    WHEN {&role-level-global} THEN DO:
      ASSIGN
      v-work-place = '':U.
    END.
  END CASE.
  IF v-work-place = ?
  OR (v-work-place = '':U AND p-level <> {&role-level-global}) THEN DO:
    ASSIGN
    v-work-place = {&question-mark}.
  END.
  ASSIGN
  v-last-staff-code = gbclcode-get-level-last-code ( INPUT p-role
                                  , INPUT p-level
                                  , INPUT v-work-place
                                  , input ?
                                  ) NO-ERROR.

  IF length(STRING(v-last-staff-code + 1)) <= LENGTH(p-staff-code-format) THEN
  display
  v-last-staff-code + 1 @ f-staff-code
  with frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME {&frame-name} = f-password:WIDTH-CHARS IN FRAME {&frame-name} - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME {&frame-name} = f-password:HEIGHT-CHARS IN FRAME {&frame-name} - 0.6
 fi-screen-pass:row IN FRAME {&frame-name} = f-password:row IN FRAME {&frame-name} + 0.20
 fi-screen-pass:COL IN FRAME {&frame-name} = f-password:col IN FRAME {&frame-name} + 0.25
 .
ASSIGN
v-tab-order = "b-exit,b-quit,b-help,b-db,b-host,b-obj,f-staff-code,f-password,f-date-start,f-date-end"
FRAME {&FRAME-NAME}:TITLE = p-title
f-staff-code:LABEL = p-staff-code-label
f-staff-code:format = p-staff-code-format
f-password:LABEL = p-password-label
f-password:format = p-password-format
e-notes:SCREEN-VALUE = p-notes
f-date-start = p-date-start
f-date-end = p-date-end
.
if p-level = {&role-level-object}
and  available buf_role-clients then do:
  assign
  v-obj-db-num = buf_role-clients.db-num.
end.
DISPLAY
f-staff-code
f-password WHEN p-password-option > 0
f-date-start
f-date-end WHEN p-date-end <> {&end-of-age}
WITH FRAME {&frame-name}.
IF p-notes = '':U THEN DO:
    HIDE
    E-notes
    IN FRAME {&FRAME-NAME}.
END.
ENABLE
B-exit
b-quit
B-Help
b-db WHEN (p-mode = {&add-def} AND p-level = {&role-level-db} and v-cntxt-db-num = 0)
b-host WHEN (p-mode <> {&add-def} AND p-level = {&role-level-firm} and v-cntxt-db-num = 0)
b-obj WHEN (p-mode <> {&add-def} AND p-level = {&role-level-object} and
            (v-cntxt-db-num = 0 or v-cntxt-db-num = v-obj-db-num))
f-staff-code WHEN p-mode = {&add-def}
f-password  WHEN (p-mode <> {&LOOKUP} AND p-password-option > 0)
f-date-start WHEN p-mode = {&add-def}
f-date-end WHEN (p-mode = {&UPDATE} AND p-date-end <> {&end-of-age})
e-notes WHEN p-notes <> '':U
WITH FRAME {&FRAME-NAME}.
IF p-mode = {&LOOKUP} THEN DO:
    ASSIGN
    b-quit:LABEL = "&Выход".
    HIDE b-exit
    IN FRAME {&FRAME-NAME}.
END.
if p-level = {&role-level-db} then do:
  assign
  f-db-num = p-db-num.
  display
  f-db-num
  with frame {&frame-name} .
end.
else do:
  hide
  b-db
  f-db-num
  in frame {&frame-name} .
end.
if p-date-end = {&end-of-age} then do:
   hide
   f-date-end
   in frame {&frame-name} .
end.
if p-level = {&role-level-firm} then do:
  assign
  f-host-code = p-host-code.
  find first buf_clients no-lock where
            buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-host-code.
  f-host-name = buf_clients.obj-name.
  display
  f-host-code
  f-host-name
  with frame {&frame-name} .
end.
else do:
  hide
  b-host
  f-host-code
  f-host-name
  in frame {&frame-name} .
end.
if p-level = {&role-level-object} then do:
  assign
  CB-obj-type = p-obj-type
  f-obj-code = p-obj-code
  f-obj-name = buf_role-clients.obj-name.
  display
  f-obj-name
  f-obj-code
  CB-obj-type
  with frame {&frame-name} .
end.
else do:
  hide
  b-obj
  cb-obj-type
  f-obj-code
  f-obj-name
  in frame {&frame-name} .
end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
if p-role = {&role-cashier}
then do :
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_client-reference_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  glog
  }
  if not glog
  then do :
    disable
      b-db
      b-host
      b-obj
      CB-obj-type
      f-date-start
      f-date-end
    with frame {&frame-name} .
  end.
end .
VIEW FRAME {&FRAME-NAME}.
APPLY "TAB" TO b-help.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-db Dialog-Frame
PROCEDURE proc-b-db :
define variable v-ri as recid no-undo .

define buffer buf_db  for ub.db.

  do
  on error undo, return error
  :

  run adm/dbs.w (
             input parparentproc
           , INPUT {&lookup}
           , output v-ri).
  if v-ri <> ?
  then do:
    find buf_db where recid (buf_db) = v-ri .
    assign
    f-db-num = buf_db.db-num
    .
    DISPLAY
    f-db-num
    WITH FRAME {&FRAME-NAME}.
  END.
end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
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
run fill-codes IN THIS-PROCEDURE NO-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-obj Dialog-Frame
PROCEDURE proc-b-obj :
define variable v-rid-list as character no-undo .

define buffer buf_clients  for ub.clients.

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
  end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable psw-buf as character no-undo .
DEFINE BUFFER buf_clients for ub.clients.
DEFINE BUFFER buf_db     FOR ub.db.
DEFINE BUFFER buf_sysconf     FOR ub.sysconf.
ASSIGN FRAME {&FRAME-NAME}
f-db-num when (f-db-num:visible in frame {&frame-name}
               and p-mode <> {&lookup})
f-host-code when (f-host-code:visible in frame {&frame-name}
               and p-mode <> {&lookup})
CB-obj-type when (cb-obj-type:visible in frame {&frame-name}
               and p-mode <> {&lookup})
f-obj-code when (f-obj-code:visible in frame {&frame-name}
               and p-mode <> {&lookup})
f-staff-code
f-date-start WHEN f-date-start:SENSITIVE IN FRAME {&frame-name}
f-date-end   WHEN (f-date-end:visible IN FRAME {&frame-name}
                  and
                  f-date-end:SENSITIVE IN FRAME {&frame-name})
.
if f-date-start:sensitive IN FRAME {&frame-name}
and f-date-end:SENSITIVE IN FRAME {&frame-name} then do:
  if f-date-end < f-date-start then do:
    message
    "Дата начала работы в данной поли должна быть не больше  даты конца работы в данной роли!"
    view-as alert-box error .
    apply "ENTRY" to f-date-end.
    return error.
  end.
end.


IF f-password:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    f-password.
    if f-password = '' or f-password = ? then do:
        message
        "Пароль НЕ заполнен!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame {&frame-name}.
        return error.       
    end.   
    if integer(f-password) < 1000 or integer(f-password) > 32767 then do:
        message
        "Пароль должен быть от 1000 до 32767!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame {&frame-name}.
        return error.          
    end.   
    if p-password-option > 1
    or f-password <> '':U
    then do:
      run ref/per-pswd.w ( output psw-buf ) .
      if f-password <> psw-buf then do:
        message
        "Пароль НЕ подтвержден!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame {&frame-name}.
        return error.
      end.
   end.
END.
/*
run validate-staff-code-password IN p-parent-handle NO-ERROR.
IF ERROR-STATUS:ERROR  THEN UNDO, RETURN ERROR.
*/
CASE p-level:
    WHEN {&role-level-db} THEN DO:
       FIND FIRST buf_db NO-LOCK WHERE
               buf_db.db-num = f-db-num NO-ERROR.
       IF NOT AVAILABLE buf_db THEN DO:
          MESSAGE
          "Неверный номер БД"
          VIEW-AS ALERT-BOX.
          UNDO, RETURN ERROR.

       END.

    END.
    WHEN {&role-level-firm} THEN DO:
        find FIRST buf_sysconf NO-LOCK WHERE
            buf_sysconf.host-code = f-host-code  NO-ERROR.
        IF NOT AVAILABLE buf_sysconf THEN DO:
            MESSAGE
            "Неверный номер фирмы"
            VIEW-AS ALERT-BOX.
            UNDO, RETURN ERROR.

        END.
    END.
    WHEN {&role-level-object} THEN DO:
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

END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME