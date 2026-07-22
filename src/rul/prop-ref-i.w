&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_prop-ref FOR ub.prop-ref.
DEFINE TEMP-TABLE tt-prop-ref NO-UNDO LIKE ub.prop-ref.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка prop-ref

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-dtm-code as integer no-undo .
DEFINE INPUT PARAMETER p-dt-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-caller-id AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-ref".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ rul/propreft.i }
{ gbl/key-rec.i }
{ cmp/operlist.i }
{ gbl/cur-time.i }
define variable is-elved as logical no-undo init yes.
define variable is-ef as logical no-undo init yes.
DEFINE BUFFER FIRST_prop-ref FOR dictdb.prop-ref.
DEFINE BUFFER buf_prop-ref FOR dictdb.prop-ref.
define buffer buf_prop-head for ub.prop-head.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-prop-ref

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-prop-ref.dt-code ~
tt-prop-ref.ref-type tt-prop-ref.sum-id tt-prop-ref.dtm-code ~
tt-prop-ref.Caller_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-prop-ref.dt-code ~
tt-prop-ref.ref-type tt-prop-ref.sum-id tt-prop-ref.dtm-code ~
tt-prop-ref.Caller_id
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-prop-ref
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-prop-ref
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-prop-ref SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-prop-ref SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-prop-ref
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-prop-ref


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-prop-ref.dt-code tt-prop-ref.ref-type ~
tt-prop-ref.sum-id tt-prop-ref.dtm-code tt-prop-ref.Caller_id
&Scoped-define ENABLED-TABLES tt-prop-ref
&Scoped-define FIRST-ENABLED-TABLE tt-prop-ref
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-date-from f-date-to ~
f-prefix f-sum-id-main-part b-main-part f-esys-id b-esys b-prop-head ~
f-prop-name
&Scoped-Define DISPLAYED-FIELDS tt-prop-ref.dt-code tt-prop-ref.ref-type ~
tt-prop-ref.sum-id tt-prop-ref.dtm-code tt-prop-ref.Caller_id
&Scoped-define DISPLAYED-TABLES tt-prop-ref
&Scoped-define FIRST-DISPLAYED-TABLE tt-prop-ref
&Scoped-Define DISPLAYED-OBJECTS f-date-from f-date-to f-prefix ~
f-sum-id-main-part f-esys-id f-prop-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 f-date-from f-date-to f-prefix f-sum-id-main-part ~
b-main-part f-esys-id b-esys tt-prop-ref.Caller_id

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-esys
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-main-part
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-prop-head
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-esys-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Код внешней системы"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-prefix AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 15.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-prop-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 97.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sum-id-main-part AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 19 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-prop-ref SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-prop-ref.dt-code AT ROW 3.27 COL 50.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tt-prop-ref.ref-type AT ROW 3.67 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "item1", "item1":U
          SIZE 22.5 BY 7.9
     tt-prop-ref.sum-id AT ROW 4.57 COL 50.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Мнемонический идентификатор" FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 40 BY 1
     f-date-from AT ROW 6 COL 50.5 COLON-ALIGNED WIDGET-ID 18
     f-date-to AT ROW 6 COL 69 COLON-ALIGNED WIDGET-ID 20
     f-prefix AT ROW 7.27 COL 50.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     f-sum-id-main-part AT ROW 7.27 COL 66.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     b-main-part AT ROW 7.27 COL 88 WIDGET-ID 26
     f-esys-id AT ROW 8.47 COL 50.5 COLON-ALIGNED WIDGET-ID 28
     b-esys AT ROW 8.47 COL 62.5 WIDGET-ID 30
     tt-prop-ref.dtm-code AT ROW 10.6 COL 50.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "Код объекта-операнда"
          VIEW-AS FILL-IN
          SIZE 15.5 BY 1
     b-prop-head AT ROW 10.6 COL 69 WIDGET-ID 8
     f-prop-name AT ROW 12.2 COL 1.5 NO-LABEL WIDGET-ID 16
     tt-prop-ref.Caller_id AT ROW 13.7 COL 16.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "доп.идент-тор"
          VIEW-AS FILL-IN NATIVE
          SIZE 63 BY 1
     "Тип итогов (среза)" VIEW-AS TEXT
          SIZE 26 BY 1 AT ROW 2.5 COL 1.5 WIDGET-ID 14
     SPACE(71.50) SKIP(11.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Срез данных по ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_prop-ref B "?" ? ub prop-ref
      TABLE: tt-prop-ref T "?" NO-UNDO ub prop-ref
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

/* SETTINGS FOR BUTTON b-esys IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON b-main-part IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN tt-prop-ref.Caller_id IN FRAME Dialog-Frame
   1 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-prop-ref.dt-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-ref.dtm-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-date-from IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       f-date-from:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-date-to IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       f-date-to:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-esys-id IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-prefix IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       f-prefix:HIDDEN IN FRAME Dialog-Frame           = TRUE
       f-prefix:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-prop-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-prop-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-sum-id-main-part IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       f-sum-id-main-part:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       tt-prop-ref.ref-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-prop-ref.sum-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-prop-ref"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Срез данных по ДК */
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Срез данных по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-esys Dialog-Frame
ON CHOOSE OF b-esys IN FRAME Dialog-Frame
DO:
  IF tt-prop-ref.dtm-code =?
  OR tt-prop-ref.dtm-code = 0 THEN DO:
     MESSAGE
     "Не выбран Объект-операнд"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  RUN proc-esys-id IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-main-part
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-main-part Dialog-Frame
ON CHOOSE OF b-main-part IN FRAME Dialog-Frame
DO:
  IF tt-prop-ref.dtm-code =?
  OR tt-prop-ref.dtm-code = 0 THEN DO:
     MESSAGE
     "Не выбран Объект-операнд"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  RUN proc-main-part IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop-head Dialog-Frame
ON CHOOSE OF b-prop-head IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FIND FIRST buf_prop-head NO-LOCK WHERE
          buf_prop-head.dtm-code = tt-prop-ref.dtm-code NO-ERROR.
IF AVAILABLE buf_prop-head THEN DO:
   v-rid-list = string(RECID(buf_prop-head)).
END.
  run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,INPUT "general-view"
                         ,input {&prop-head-gen-dc-storage} /*p-general-view*/
                         ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
     FIND FIRST buf_prop-head NO-LOCK WHERE
               recid(buf_prop-head) = INTEGER(v-rid-list).
     IF buf_prop-head.ref-type = '':U  THEN DO:
        MESSAGE
        "Для данного объекта операнда не предусмотрено создание срезов данных"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
     END.
     ASSIGN
     tt-prop-ref.dtm-code = buf_prop-head.dtm-code
     f-prop-name = buf_prop-head.prop-label
     tt-prop-ref.ref-type = buf_prop-head.ref-type
     .
     DISPLAY
     tt-prop-ref.dtm-code
     f-prop-name
     tt-prop-ref.ref-type
     WITH FRAME {&FRAME-NAME}.
     RUN display-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type, INPUT buf_prop-head.prop-name).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-prop-ref.ref-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-prop-ref.ref-type Dialog-Frame
ON VALUE-CHANGED OF tt-prop-ref.ref-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-ref.ref-type.
  if p-mode <> {&lookup} then do:
    RUN change-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  end.
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
{ gbl/ed_date.i f-date-from }
{ gbl/ed_date.i f-date-to }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK   :
  if p-dtm-code > 0 then do:
    find first buf_prop-head no-lock where
                        buf_prop-head.dtm-code = p-dtm-code no-error .
    if not available buf_prop-head then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Неверное значение параметра p-dtm-code=&1", p-dtm-code)
      view-as alert-box error .
      undo, return error .
    end.
  end.
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST first_prop-ref EXCLUSIVE-LOCK.
    CREATE tt-prop-ref.
    ASSIGN
    tt-prop-ref.caller_id = p-caller-id
    tt-prop-ref.dtm-code = p-dtm-code
    tt-prop-ref.ref-type = (if available buf_prop-head
                            then buf_prop-head.ref-type
                            else '':U)
    .
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_prop-ref EXCLUSIVE-LOCK WHERE
                LOCKED_prop-ref.dt-code = p-dt-code .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_prop-ref no-LOCK WHERE
                  LOCKED_prop-ref.dt-code = p-dt-code NO-ERROR.
    END.
    create tt-prop-ref.
    buffer-copy locked_prop-ref to tt-prop-ref.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-ref-type Dialog-Frame
PROCEDURE change-ref-type :
DEFINE INPUT PARAMETER p-ref-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE VARIABLE date-1 AS date NO-UNDO.
DEFINE VARIABLE date-2 AS date NO-UNDO.
DEFINE VARIABLE v-dop AS character NO-UNDO.
DEFINE VARIABLE v-dop1 AS character NO-UNDO.
DEFINE VARIABLE v-dop2 AS character NO-UNDO.
DEFINE VARIABLE v-m AS integer NO-UNDO.
DEFINE VARIABLE v-y AS integer NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ii as integer no-undo .
DEFINE VARIABLE v-ref-type as character no-undo .
DO v-ii = 1 TO NUM-ENTRIES(p-ref-type, ":"):
ASSIGN
v-ref-type = ENTRY(v-ii, p-ref-type, ":")
.
CASE v-ref-type:
  WHEN {&sum-id-type-esys-blank} THEN DO:
      enable
      b-esys
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      tt-prop-ref.caller_id
      WITH FRAME {&FRAME-NAME}.
      HIDE
      tt-prop-ref.caller_id
      b-main-part
      in FRAME {&FRAME-NAME}.
  END.
  WHEN {&sum-id-type-period} THEN DO:
    run cur-time in this-procedure ( output v-today, output v-time).
    ASSIGN
    v-m = MONTH(v-today)
    v-y = YEAR(v-today)
    .
    IF v-m = 12  THEN DO:
        ASSIGN
        v-m = 1
        v-y = v-y + 1
        .
    END.
    ELSE DO:
        ASSIGN
        v-m = v-m + 1
        .

    END.
    date-1 = DATE( v-m, 1, v-y).
    IF v-m = 12  THEN DO:
        ASSIGN
        v-m = 1
        v-y = v-y + 1
        .
    END.
    ELSE DO:
        ASSIGN
        v-m = v-m + 1
        .

    END.
    ASSIGN
    date-2 = DATE( v-m, 1, v-y)
    date-2 = date-2 - 1
    .
    run gbl/get-per.w ( output glog
                  , input-output date-1
                  , input-output date-2) .
    IF NOT glog THEN RETURN NO-APPLY.
    IF date-1 <= v-today
      OR date-2 <= v-today THEN DO:
        MESSAGE
        "Нельзя ввести частный итог для текущего периода времени"
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    ASSIGN
    v-dop1 = propreft-date-to-string(date-1) + '-' + propreft-date-to-string(date-1)
    v-dop2 = propreft-date-to-string(date-2) + '-' + propreft-date-to-string(date-2)
    v-dop = propreft-date-to-string(date-1) + '-' + propreft-date-to-string(date-2)
    .
    f-date-from = date-1.
    f-date-to = date-2.
     DISPLAY
     tt-prop-ref.caller_id
     WITH FRAME {&FRAME-NAME}.
     enable
     tt-prop-ref.caller_id WHEN p-mode <> {&lookup}
     WITH FRAME {&FRAME-NAME}.
     hIDE
     b-main-part
     in FRAME {&FRAME-NAME}.
  END.  /*WHEN {&sum-id-type-period} THEN DO:*/
  when {&sum-id-type-sel-goods} then do:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME {&FRAME-NAME}.
    HIDE
    tt-prop-ref.caller_id
    b-main-part
    in FRAME {&FRAME-NAME}.

  end.
  when {&sum-id-type-one-ptrl} then do:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME {&FRAME-NAME}.
    HIDE
    tt-prop-ref.caller_id
    in FRAME {&FRAME-NAME}.
    display
    b-main-part
    with frame {&frame-name} .
  end.
END CASE.
END. /*do v-ii*/
ASSIGN
tt-prop-ref.sum-id = v-dop.
DISPLAY
tt-prop-ref.sum-id
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-ref-type Dialog-Frame
PROCEDURE display-ref-type :
DEFINE INPUT PARAMETER p-ref-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-prop-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ref-type as character no-undo .
DEFINE VARIABLE v-ii AS integer no-undo .

HIDE
f-date-from
IN FRAME {&FRAME-NAME}.
HIDE
{&list-1}
IN FRAME {&FRAME-NAME}.
DO v-ii = 1 TO NUM-ENTRIES(p-ref-type, ":"):
ASSIGN
v-ref-type = ENTRY(v-ii, p-ref-type, ":")
.

CASE v-ref-type:
 WHEN {&sum-id-type-esys-blank} THEN DO:
    display
    f-esys-id
    WITH FRAME {&FRAME-NAME}.
    IF p-mode = {&add-def} THEN DO:
      ENABLE
      b-esys
      WITH FRAME {&FRAME-NAME}.
    END.
  END.
  WHEN {&sum-id-type-period} THEN DO:
    DISPLAY
    f-date-from f-date-to
    tt-prop-ref.Caller_id
    WITH FRAME {&FRAME-NAME}.
    IF p-mode = {&add-def} THEN DO:
       ENABLE
       f-date-from
       f-date-to
       WITH FRAME {&FRAME-NAME}.
    END.
    hide
    b-main-part in FRAME {&FRAME-NAME}.
  END.
  WHEN {&sum-id-type-sel-goods} THEN DO:
    DISPLAY
    "G":U @ f-prefix f-sum-id-main-part
    WITH FRAME {&FRAME-NAME}.
    IF p-mode = {&add-def} THEN DO:
      ENABLE
      f-sum-id-main-part
      WITH FRAME {&FRAME-NAME}.
    END.
    HIDE
    b-main-part IN FRAME {&FRAME-NAME}.
  END.
  WHEN {&sum-id-type-one-ptrl} THEN DO:
    DISABLE
    tt-prop-ref.caller_id
    WITH FRAME {&FRAME-NAME}.
    DISPLAY
    "petrol":U @ f-prefix f-sum-id-main-part b-main-part
    WITH FRAME {&FRAME-NAME}.
    IF p-mode = {&add-def} THEN DO:
      enable
      b-main-part
      WITH FRAME {&FRAME-NAME}.
    END.
  END.
  WHEN {&sum-id-type-blank} THEN DO:
      DISPLAY
      p-prop-name @ f-prefix
      WITH FRAME {&FRAME-NAME}.

  END.
END CASE.
END. /*v-ii*/
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY f-date-from f-date-to f-prefix f-sum-id-main-part f-esys-id
          f-prop-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-ref THEN
    DISPLAY tt-prop-ref.dt-code tt-prop-ref.ref-type tt-prop-ref.sum-id
          tt-prop-ref.dtm-code tt-prop-ref.Caller_id
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-prop-ref.dt-code tt-prop-ref.ref-type
         tt-prop-ref.sum-id f-date-from f-date-to f-prefix f-sum-id-main-part
         b-main-part f-esys-id b-esys tt-prop-ref.dtm-code b-prop-head
         f-prop-name tt-prop-ref.Caller_id
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
define variable dops as character no-undo .
define variable dopst as character no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DO v-ii = 1 TO NUM-ENTRIES({&sum-id-type-list}):
   ASSIGN
   v-dop = v-dop + ENTRY(v-ii, {&sum-id-type-list-full}) + {&comma-char} +
           ENTRY(v-ii, {&sum-id-type-list}) + {&comma-char}.
END.
ASSIGN
v-dop = TRIM(v-dop, {&comma-char}).
ASSIGN
tt-prop-ref.ref-type:radio-buttons IN FRAME {&FRAME-NAME} = v-dop.

/*проверим конф параметр is-elved*/
{ gbl/conf-rd.i
"'is-elved'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
if error-status:error
or logical(dops) = no then do:
  is-elved = no.
end.
dops = ''.
{ gbl/conf-rd.i
"'is-ef'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
if error-status:error
or logical(dops) = no then do:
  is-ef = no.
end.
if is-elved = no
and is-ef = no then do:
  tt-prop-ref.ref-type:disable(radio-label({&sum-id-type-one-ptrl}
                              , tt-prop-ref.ref-type:radio-buttons IN FRAME {&FRAME-NAME})) in frame {&frame-name} .
end.

IF p-mode = {&add-def}
and tt-prop-ref.dtm-code = 0
THEN DO:
   f-prop-name = {&question-mark}.
END.
ELSE DO:
  FIND FIRST buf_prop-head NO-LOCK WHERE
            buf_prop-head.dtm-CODE = tt-prop-ref.dtm-code.
 f-prop-name = buf_prop-head.prop-label.
END.
DISPLAY
f-prop-name
WITH FRAME {&frame-name}.
IF AVAILABLE tt-prop-ref THEN
DISPLAY
tt-prop-ref.dt-code
tt-prop-ref.dtm-code
tt-prop-ref.sum-id
tt-prop-ref.caller_id
tt-prop-ref.ref-type
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&lookup}
b-quit
B-Help
tt-prop-ref.sum-id  WHEN p-mode <> {&LOOKUP} AND p-mode <> {&add-def}
tt-prop-ref.caller_id  WHEN p-mode <> {&lookup}
b-prop-head WHEN p-mode = {&add-def} and tt-prop-ref.dtm-code = 0
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
if tt-prop-ref.dtm-code > 0
and p-mode = {&add-def} then do:
  apply "VALUE-CHANGED" to tt-prop-ref.ref-type.
  RUN display-ref-type IN THIS-PROCEDURE ( INPUT tt-prop-ref.ref-type, (if available buf_prop-head then buf_prop-head.prop-name else '')).
end.
/*пока не исполь такой тип итогов*/
hide
f-esys-id
b-esys
in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-esys-id Dialog-Frame
PROCEDURE proc-esys-id :
DEFINE INPUT PARAMETER p-ref-type AS character NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-ok as logical no-undo .
define variable v-value-integer as integer no-undo .
define buffer buf_ext-system for ub.ext-system.
DEFINE BUFFER buf_goods FOR ub.goods.
CASE entry(1, p-ref-type, ":"):
    WHEN {&sum-id-type-esys-blank} THEN DO:
      find first buf_ext-system no-lock where
                  buf_ext-system.db-num = 0
              and buf_ext-system.esys-id = integer(replace(entry(1, p-ref-type, ":"), "es", "")) no-error.
      if available buf_ext-system THEN DO:
          run gen-key-rec in this-procedure (
                                              input {&table_ext-system}
                                              ,input buffer buf_ext-system:handle
                                              ,output v-uniq-key-rec) .

      END.
      run bge/oxmlexts.p (
            input parparentproc
          , input 2                         /* Единичный выбор - 2. Множественный - 1*/
          , input substitute("esys-type > &1", {&openxml-type-ordinal}) /*p-where-string*/
          , input v-uniq-key-rec        /* То, что уже выбрано (список) */
          , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
          , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
      ).
      if v-ok then do:
        run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.
        if not (buf_ext-system.esys-type > integer({&openxml-type-ordinal})) then do:
          message
          "Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа СПЕЦИАЛЬНЫЙ"
          view-as alert-box error .
          undo, return error.
        end.
        assign
        v-value-integer = buf_Ext-system.esys-id.
        ASSIGN
        f-esys-id = SUBSTITUTE("es&1", buf_Ext-system.esys-id).
        DISPLAY f-esys-id
        WITH FRAME {&FRAME-NAME}.
    END.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-main-part Dialog-Frame
PROCEDURE proc-main-part :
DEFINE INPUT PARAMETER p-ref-type AS character NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
CASE p-ref-type:
    WHEN {&sum-id-type-one-ptrl} THEN DO:
      run ref/petrlref.p ( INPUT parparentproc
                          ,INPUT "b-sel"
                          ,OUTPUT v-rid-list ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-rid-list = '':U THEN DO:
         UNDO, RETURN ERROR.
      END.
      FIND FIRST buf_goods no-lock WHERE
                RECID(buf_goods) = INTEGER(v-rid-list) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
      ASSIGN
      f-sum-id-main-part = string(buf_goods.gds-code).
      DISPLAY f-sum-id-main-part
      WITH FRAME {&FRAME-NAME}.
    END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sum-id-all AS CHARACTER NO-UNDO.
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-ref.ref-type, ":"):
  CASE entry(v-ii, tt-prop-ref.ref-type, ":"):
    WHEN {&sum-id-type-esys-blank} THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
      f-esys-id.
      v-sum-id = f-esys-id.
    END.
    WHEN {&sum-id-type-period} THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
      f-date-from
      f-date-to
      .
     if f-date-from = ?
      or f-date-to = ? then do:
        message
        "Не выбраны дата(-ы) начала/конца периода!"
        view-as alert-box error .
        undo, return error .
      end.
      v-sum-id = SUBSTITUTE("&1/&2/&3-&4/&5/&6"
                                      ,string(YEAR(f-date-from), "9999")
                                      ,string(MONTH(f-date-from), "99")
                                      ,string(DAY(f-date-from), "99")
                                      ,string(YEAR(f-date-to), "9999")
                                      ,string(MONTH(f-date-to), "99")
                                      ,string(DAY(f-date-to), "99")).

    END.
    WHEN {&sum-id-type-sel-goods} THEN DO:
      ASSIGN
      f-sum-id-main-part.
      v-sum-id = SUBSTITUTE("&1-&2"
                                      ,f-prefix:SCREEN-VALUE
                                      ,f-sum-id-main-part
                                      ).
    END.
    WHEN {&sum-id-type-one-ptrl} THEN DO:
      if not is-elved
      and not is-ef
      then do:
         message
         'В Вашей конфигурации нельзя добавлять итоги(срезы) типа ТОПЛИВО,' skip
         'так как не включены конфигурационные параметры is-elved и/или is-ef'
         view-as alert-box error .
         undo, return error .
      end.
      ASSIGN
      f-sum-id-main-part.
      v-sum-id = SUBSTITUTE("&1-&2"
                                      ,f-prefix:SCREEN-VALUE
                                      ,f-sum-id-main-part
                                      ).
    END.
    WHEN {&sum-id-type-blank} THEN DO:
      v-sum-id = SUBSTITUTE("&1"
                                      ,f-prefix:SCREEN-VALUE
                                      ).
    END.
  END CASE.
  v-sum-id-all = v-sum-id-all + (IF v-sum-id-all = "":U THEN '':U ELSE ":") + v-sum-id.
END. /*do-v-ii*/
ASSIGN
FRAME {&FRAME-NAME}
tt-prop-ref.dt-code
tt-prop-ref.dtm-code
tt-prop-ref.caller_id
tt-prop-ref.ref-type
tt-prop-ref.sum-id = v-sum-id-all
.
run rul/prop-ref1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-ref.dt-code
                ,INPUT tt-prop-ref.sum-id
                ,INPUT tt-prop-ref.dtm-code
                ,INPUT tt-prop-ref.caller_id
                ,INPUT tt-prop-ref.ref-type
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME