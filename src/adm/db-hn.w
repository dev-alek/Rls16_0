&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_hist-nws-option FOR ub.hist-nws-option.
DEFINE TEMP-TABLE tt-hist-nws-option NO-UNDO LIKE ub.hist-nws-option
       field hist-to-nws-is-on as logical
       field nws-to-hist-is-on as logical
       field get-hist-from-nws-is-on as logical
       field hist-to-nws-can as logical
       field nws-to-hist-can as logical
       field get-hist-from-nws-can as logical.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опции записи истории и маршрутизации для БД

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
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-db-num AS integer NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Опции записи истории и маршрутизации для БД".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }


&SCOPED-DEFINE LABEL0 "Группа данных"
&SCOPED-DEFINE LABEL1 "Пересылка ист.!в другие БД"
&SCOPED-DEFINE label2 "Создание ист.!при приеме!по СПН"
&SCOPED-DEFINE label3 "Прием истории!из другой!УБД"
define variable v-col as widget-handle extent 3.
DEFINE VARIABLE v-groups AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-subject-group AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-col-tbl-name AS WIDGET-HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-option

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-hist-nws-option

/* Definitions for BROWSE BR-option                                     */
&Scoped-define FIELDS-IN-QUERY-BR-option get-hn-group-label(tt-hist-nws-option.subject-group) tt-hist-nws-option.option-descr get-hn-label(tt-hist-nws-option.hist-to-nws) tt-hist-nws-option.hist-to-nws-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt-hist-nws-option.nws-to-hist) tt-hist-nws-option.nws-to-hist-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt-hist-nws-option.get-hist-from-nws) tt-hist-nws-option.get-hist-from-nws-is-on VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-option tt-hist-nws-option.hist-to-nws-is-on tt-hist-nws-option.nws-to-hist-is-on tt-hist-nws-option.get-hist-from-nws-is-on
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-option tt-hist-nws-option
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-option tt-hist-nws-option
&Scoped-define SELF-NAME BR-option
&Scoped-define QUERY-STRING-BR-option FOR EACH tt-hist-nws-option WHERE          (v-subject-group = '':U           AND tt-hist-nws-option.table-name = '':U)          OR (tt-hist-nws-option.subject-group = v-subject-group              AND tt-hist-nws-option.table-name > '':U)
&Scoped-define OPEN-QUERY-BR-option OPEN QUERY {&SELF-NAME} FOR EACH tt-hist-nws-option WHERE          (v-subject-group = '':U           AND tt-hist-nws-option.table-name = '':U)          OR (tt-hist-nws-option.subject-group = v-subject-group              AND tt-hist-nws-option.table-name > '':U).
&Scoped-define TABLES-IN-QUERY-BR-option tt-hist-nws-option
&Scoped-define FIRST-TABLE-IN-QUERY-BR-option tt-hist-nws-option


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-option}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit CB-subject-group b-copyrdb ~
b-hist B-Help last-modify BR-option
&Scoped-Define DISPLAYED-OBJECTS CB-subject-group last-modify

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-hn-group-label Dialog-Frame
FUNCTION get-hn-group-label RETURNS CHARACTER
  ( INPUT p-subject-group AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-hn-label Dialog-Frame
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-copyrdb
     LABEL "&Копир.на все УБД"
     SIZE 20 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CB-subject-group AS CHARACTER FORMAT "X(256)":U
     LABEL "Группы данных"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE last-modify AS CHARACTER FORMAT "X(256)":U
     LABEL "Дата и время посл. обновления"
     VIEW-AS FILL-IN
     SIZE 21 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-option FOR
      tt-hist-nws-option SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-option Dialog-Frame _FREEFORM
  QUERY BR-option DISPLAY
      get-hn-group-label(tt-hist-nws-option.subject-group) FORMAT "X(40)" COLUMN-LABEL {&label0}
tt-hist-nws-option.option-descr FORMAT "X(40)" COLUMN-LABEL "Сущность"
get-hn-label(tt-hist-nws-option.hist-to-nws) FORMAT "X(15)" COLUMN-LABEL {&label1}
tt-hist-nws-option.hist-to-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
get-hn-label(tt-hist-nws-option.nws-to-hist) FORMAT "X(15)" COLUMN-LABEL {&label2}
tt-hist-nws-option.nws-to-hist-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
get-hn-label(tt-hist-nws-option.get-hist-from-nws) FORMAT "X(15)" COLUMN-LABEL {&label3}
tt-hist-nws-option.get-hist-from-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
ENABLE
tt-hist-nws-option.hist-to-nws-is-on
tt-hist-nws-option.nws-to-hist-is-on
tt-hist-nws-option.get-hist-from-nws-is-on
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.37 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     CB-subject-group AT ROW 1 COL 35 COLON-ALIGNED WIDGET-ID 4
     b-copyrdb AT ROW 1 COL 69
     b-hist AT ROW 1 COL 92 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     last-modify AT ROW 2.07 COL 74 COLON-ALIGNED WIDGET-ID 6
     BR-option AT ROW 3.27 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции записи истории и маршрутизации для БД"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_hist-nws-option B "?" ? ub hist-nws-option
      TABLE: tt-hist-nws-option T "?" NO-UNDO ub hist-nws-option
      ADDITIONAL-FIELDS:
          field hist-to-nws-is-on as logical
          field nws-to-hist-is-on as logical
          field get-hist-from-nws-is-on as logical
          field hist-to-nws-can as logical
          field nws-to-hist-can as logical
          field get-hist-from-nws-can as logical
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-option last-modify Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       CB-subject-group:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       last-modify:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-option
/* Query rebuild information for BROWSE BR-option
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-hist-nws-option WHERE
         (v-subject-group = '':U
          AND tt-hist-nws-option.table-name = '':U)
         OR (tt-hist-nws-option.subject-group = v-subject-group
             AND tt-hist-nws-option.table-name > '':U).
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-option */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции записи истории и маршрутизации для БД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copyrdb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copyrdb Dialog-Frame
ON CHOOSE OF b-copyrdb IN FRAME Dialog-Frame /* Копир.на все УБД */
DO:
  IF NOT AVAILABLE tt-hist-nws-option THEN RETURN NO-APPLY.
  RUN proc-copy-udb IN THIS-PROCEDURE ( BUFFER tt-hist-nws-option) NO-ERROR.
  if error-status:error then do:
    message
    error-status:get-message(1)
    substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    view-as alert-box error .
    return no-apply.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    message
    error-status:get-message(1)
    substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    view-as alert-box error .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE tt-hist-nws-option THEN RETURN NO-APPLY.
  IF tt-hist-nws-option.table-name = '':U  THEN DO:
     run ref/hstcnws.w ( INPUT parparentproc
                        ,INPUT "":U /*bttns*/
                        ,INPUT "subject-group-db"
                        ,INPUT tt-hist-nws-option.db-num
                        ,INPUT tt-hist-nws-option.subject-group
                        ,INPUT '':U /*table-name*/
                        ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  END.
  ELSE DO:
      run ref/hstcnws.w ( INPUT parparentproc
                         ,INPUT "":U /*bttns*/
                         ,INPUT "one-db"
                         ,INPUT tt-hist-nws-option.db-num
                         ,INPUT '':U /*subject-group*/
                         ,INPUT tt-hist-nws-option.table-name /*table-name*/
                         ,INPUT-OUTPUT v-rid-list ) NO-ERROR.

  END.
  APPLY "ENTRY" TO br-option.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-subject-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-subject-group Dialog-Frame
ON VALUE-CHANGED OF CB-subject-group IN FRAME Dialog-Frame /* Группы данных */
DO:
 RUN switch-subject IN THIS-PROCEDURE .
 RUN Openbr IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-option
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

ON "leave" OF tt-hist-nws-option.hist-to-nws-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.hist-to-nws-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.hist-to-nws-is-on = (IF tt-hist-nws-option.hist-to-Nws = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.hist-to-nws-is-on
    with browse br-option.
  END.
END.
ON "leave" OF tt-hist-nws-option.nws-to-hist-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.nws-to-hist-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.nws-to-hist-is-on = (IF tt-hist-nws-option.nws-to-hist = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.nws-to-hist-is-on
    with browse br-option.
  END.
END.
ON "leave" OF tt-hist-nws-option.get-hist-from-nws-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.get-hist-from-nws-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.get-hist-from-nws-is-on = (IF tt-hist-nws-option.get-hist-from-nws = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.get-hist-from-nws-is-on
    with browse br-option.
  END.
END.




/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
IF NOT (p-mode = {&update}
        OR p-mode = {&lookup}) THEN  DO:
   MESSAGE
   vss-workfile vss-revision vss-description skip
   "Неверное значение параметра p-mode" p-mode
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
if g#db-num <> 0
and p-db-num <> G#db-num
and p-mode <> {&lookup}
then do:
  MESSAGE
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра p-db-num" p-db-num skip
  "Нельзя работать с настройками записи истории и машрутизации в чужой УБД"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
end.
IF p-mode = {&UPDATE} THEN DO:
  DO ON ERROR UNDO, RETURN ERROR
     ON STOP UNDO, RETURN ERROR:
    FIND FIRST locked_hist-nws-option EXCLUSIVE-LOCK WHERE
            locked_hist-nws-option.db-num = p-db-num
        AND locked_hist-nws-option.hn-id = 0 NO-WAIT NO-ERROR .
    IF NOT AVAILABLE LOCKED_hist-nws-option
    AND NOT LOCKED LOCKED_hist-nws-option THEN DO:
        CREATE locked_hist-nws-option.
        ASSIGN
        locked_hist-nws-option.db-num = p-db-num
        locked_hist-nws-option.hn-id = 0
        .

    END.
    ELSE DO:
        FIND FIRST locked_hist-nws-option EXCLUSIVE-LOCK WHERE
                locked_hist-nws-option.db-num = p-db-num
            AND locked_hist-nws-option.hn-id = 0 NO-ERROR .

    END.
  END.
END.
IF p-mode = {&lookup} THEN DO:
    FIND FIRST locked_hist-nws-option no-LOCK WHERE
            locked_hist-nws-option.db-num = p-db-num
        AND locked_hist-nws-option.hn-id = 0 NO-ERROR.
   IF NOT AVAILABLE locked_hist-nws-option THEN DO:
      CREATE locked_hist-nws-option.
      ASSIGN
      locked_hist-nws-option.db-num = p-db-num
      locked_hist-nws-option.hn-id = 0
      .
   END.
END.
  RUN fill-table IN THIS-PROCEDURE ( INPUT '':U).
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
  DISPLAY CB-subject-group last-modify
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit CB-subject-group b-copyrdb b-hist B-Help last-modify
         BR-option
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE INPUT PARAMETER p-subject-group AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
run waitfram-show in this-procedure ( "Ждите ... ").
FOR EACH buf_hist-nws-option NO-LOCK WHERE
       buf_hist-nws-option.db-num = p-db-num
   and buf_hist-nws-option.hn-id > 0
   :
  if buf_hist-nws-option.charkey_one <> '':U
  or buf_hist-nws-option.charkey_two <> '':U
  or buf_hist-nws-option.charkey_three <> '':U
  or buf_hist-nws-option.key#_one <> 0
  or buf_hist-nws-option.key#_two <> 0
  or buf_hist-nws-option.key#_three <> 0
  or buf_hist-nws-option.host-code <> 0
  or buf_hist-nws-option.obj-type <> '':U
  or buf_hist-nws-option.obj-code <> 0 then next.
  CREATE tt-hist-nws-option.
  buffer-copy buf_hist-nws-option to tt-hist-nws-option.
  ASSIGN
  tt-hist-nws-option.hist-to-nws-is-on = (tt-hist-nws-option.hist-to-nws >= 0)
  tt-hist-nws-option.nws-to-hist-is-on = (tt-hist-nws-option.nws-to-hist >= 0)
  tt-hist-nws-option.get-hist-from-nws-is-on = (tt-hist-nws-option.get-hist-from-nws >= 0)
  tt-hist-nws-option.hist-to-nws-can = NOT ((tt-hist-nws-option.hist-to-nws = INTEGER({&hn-is-on-blocked})) OR
                                            (tt-hist-nws-option.hist-to-nws = INTEGER({&hn-is-off-blocked})))
  tt-hist-nws-option.nws-to-hist-can = NOT ((tt-hist-nws-option.nws-to-hist = INTEGER({&hn-is-on-blocked})) OR
                                            (tt-hist-nws-option.nws-to-hist = INTEGER({&hn-is-off-blocked})))
  tt-hist-nws-option.get-hist-from-nws-can = NOT ((tt-hist-nws-option.get-hist-from-nws = INTEGER({&hn-is-on-blocked})) OR
                                                  (tt-hist-nws-option.get-hist-from-nws = INTEGER({&hn-is-off-blocked})))

  .
  IF LOOKUP(buf_hist-nws-option.subject-group, v-groups) = 0  THEN DO:
    ASSIGN
    v-groups = v-groups + {&comma-char} +
                buf_hist-nws-option.subject-group
    v-groups = TRIM(v-groups, {&comma-char})
    .

  END.
END.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.

ASSIGN
cb-subject-group:LIST-ITEMS IN FRAME {&FRAME-NAME} = '':U + {&comma-char} + v-groups.
DO v-ii = 1 TO BROWSE br-option:NUM-COLUMNS:
   v-h = BROWSE br-option:GET-BROWSE-COLUMN(v-ii).
   IF v-h:LABEL = {&label1} THEN DO:
       ASSIGN
       v-col[1] = v-h
       .
   END.
   IF v-h:LABEL = {&label2} THEN DO:
       ASSIGN
       v-col[2] = v-h
       .
   END.
   IF v-h:LABEL = {&label3} THEN DO:
       ASSIGN
       v-col[3] = v-h
       .
   END.
   IF v-h:LABEL = {&label0} THEN DO:
       ASSIGN
       v-col-tbl-name = v-h
       .
   END.
END.
DISPLAY
locked_hist-nws-option.option-descr @ last-modify
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit
b-quit
B-Help
b-copyrdb WHEN (p-mode = {&UPDATE} AND (g#db-num = p-db-num OR g#db-num = 0 ))
b-hist
BR-option
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
   HIDE
   b-exit IN FRAME {&FRAME-NAME}.
   ASSIGN
   b-quit:LABEL = "&Выход"
   b-quit:COLUMN = 1
   FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2", FRAME {&FRAME-NAME}:TITLE, p-db-num)
   tt-hist-nws-option.hist-to-nws-is-on:READ-ONLY in browse br-option = YES
   tt-hist-nws-option.nws-to-hist-is-on :READ-ONLY in browse br-option = YES
   tt-hist-nws-option.get-hist-from-nws-is-on:READ-ONLY in browse br-option = YES
   .
END.
APPLY "Value-changed" TO cb-subject-group.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
IF v-subject-group = '':U THEN DO:
    OPEN QUERY br-option
    FOR EACH tt-hist-nws-option WHERE
            tt-hist-nws-option.db-num = p-db-num
        and tt-hist-nws-option.hn-id > 0
        and tt-hist-nws-option.table-name = '':U.
END.
ELSE DO:
    OPEN QUERY br-oprion
    FOR EACH tt-hist-nws-option WHERE
            tt-hist-nws-option.db-num = p-db-num
        and tt-hist-nws-option.hn-id > 0
        and  (tt-hist-nws-option.subject-group = v-subject-group
                 AND tt-hist-nws-option.table-name > '':U).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy-udb Dialog-Frame
PROCEDURE proc-copy-udb :
DEFINE PARAMETER BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE glog as LOGICAL no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER bufo_tt-hist-nws-option for TT-hist-nws-option.
IF g#db-num > 0 THEN DO:
  UNDO, RETURN ERROR.
END.
MESSAGE
SUBSTITUTE("Вы действительно хотите скопировать&1" +
           "настройки записи истории и маршрутизации &2 на все УБД?&1" +
           "Измения будут сохранены в момент сохранения изменений для опций БД &3&1" +
           "(Нажатие клавиши ВВОД"
           , {&NEW-LINE}
           , buf_tt-hist-nws-option.option-descr
           , p-db-num)
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN DO:
    UNDO, RETURN NO-APPLY.
END.
do TRANSACTION
ON ERROR UNDO, RETURN ERROR:
    FOR EACH buf_db NO-LOCK WHERE
            buf_db.db-num > 0
    ON error undo, return error :
      FIND FIRST bufo_tt-hist-nws-option WHERE
                bufo_tt-hist-nws-option.db-num = buf_db.db-num
           AND  bufo_tt-hist-nws-option.hn-id = buf_tt-hist-nws-option.hn-id NO-ERROR.

      IF NOT AVAILABLE bufo_tt-hist-nws-option THEN DO:
         CREATE bufo_tt-hist-nws-option.
         BUFFER-COPY buf_tt-hist-nws-option
         except db-num
         TO bufo_tt-hist-nws-option
         assign
         bufo_tt-hist-nws-option.db-num = buf_db.db-num
         .
      END.
      else do:
        BUFFER-COPY buf_tt-hist-nws-option
        except db-num
        TO bufo_tt-hist-nws-option
        .
      end.
    END.
END.
run openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER main_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER subject_hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER last_hist-nws-option FOR ub.hist-nws-option.
define buffer main_hist-nws-option for ub.hist-nws-option.
if g#db-num = p-db-num then do:
  message
  "Сделанные Вами изменения вступят в силу для всех пользователей не позже, чем через полчаса" skip
  "(или сразу же после перезагрузки IBS TH)"
  view-as alert-box .
end.
_hist-nws-option:
FOR EACH buf_tt-hist-nws-option
ON error UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if buf_tt-hist-nws-option.hn-id = 0 then next _hist-nws-option.
  FIND FIRST buf_hist-nws-option WHERE
            buf_hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
        and buf_hist-nws-option.hn-id = buf_tt-hist-nws-option.hn-id NO-ERROR.
  IF NOT AVAILABLE buf_hist-nws-option THEN DO:
    next _hist-nws-option.
  END.
  if buf_tt-hist-nws-option.db-num <> p-db-num then do:
    find first main_tt-hist-nws-option where
              main_tt-hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
         and  main_tt-hist-nws-option.hn-id = 0 no-error.
    if not available main_tt-hist-nws-option then do:
      create main_tt-hist-nws-option.
      assign
      main_tt-hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
      main_tt-hist-nws-option.hn-id  = 0
      .
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    main_tt-hist-nws-option.option-descr = substitute("&1 &2", string(v-today, "99/99/9999"), string(v-time, "HH:MM:SS")).
  end.
  IF v-subject-group = '':U THEN DO:
    FIND FIRST subject_hist-nws-option WHERE
              subject_hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
        AND  subject_hist-nws-option.subject-group = buf_tt-hist-nws-option.subject-group
        AND  subject_hist-nws-option.table-name = '':U NO-ERROR.
    IF AVAILABLE subject_hist-nws-option THEN DO:
      assign
      buf_hist-nws-option.hist-to-nws = (IF buf_tt-hist-nws-option.hist-to-nws-can
                                        THEN (IF subject_hist-nws-option.hist-to-nws-is-on
                                              THEN INTEGER({&hn-is-on})
                                              ELSE INTEGER({&hn-is-off})
                                              )
                                        ELSE buf_hist-nws-option.hist-to-nws)
      buf_hist-nws-option.nws-to-hist = (IF buf_tt-hist-nws-option.nws-to-hist-can
                                          THEN (IF subject_hist-nws-option.nws-to-hist-is-on
                                                  THEN INTEGER({&hn-is-on})
                                                  ELSE INTEGER({&hn-is-off})
                                                  )
                                          ELSE buf_hist-nws-option.nws-to-hist)
      buf_hist-nws-option.get-hist-from-nws = (IF buf_tt-hist-nws-option.get-hist-from-nws-can
                                          THEN (IF subject_hist-nws-option.get-hist-from-nws-is-on
                                                  THEN INTEGER({&hn-is-on})
                                                  ELSE INTEGER({&hn-is-off})
                                                  )
                                          ELSE buf_hist-nws-option.get-hist-from-nws)
      .
    END.
  END.
  ELSE DO:
    assign
    buf_hist-nws-option.hist-to-nws = (IF buf_tt-hist-nws-option.hist-to-nws-can
                                        THEN (IF buf_tt-hist-nws-option.hist-to-nws-is-on
                                              THEN INTEGER({&hn-is-on})
                                              ELSE INTEGER({&hn-is-off})
                                            )
                                        ELSE buf_hist-nws-option.hist-to-nws)
    buf_hist-nws-option.nws-to-hist = (IF buf_tt-hist-nws-option.nws-to-hist-can
                                        THEN (IF buf_tt-hist-nws-option.nws-to-hist-is-on
                                                  THEN INTEGER({&hn-is-on})
                                                  ELSE INTEGER({&hn-is-off})
                                                )
                                        ELSE buf_hist-nws-option.nws-to-hist)
    buf_hist-nws-option.get-hist-from-nws = (IF buf_tt-hist-nws-option.get-hist-from-nws-can
                                        THEN (IF buf_tt-hist-nws-option.get-hist-from-nws-is-on
                                                  THEN INTEGER({&hn-is-on})
                                                  ELSE INTEGER({&hn-is-off})
                                                )
                                        ELSE buf_hist-nws-option.get-hist-from-nws)
    .
  END.
END.
run cur-time in this-procedure ( output v-today, output v-time).
ASSIGN
locked_hist-nws-option.option-descr = STRING(v-today, "99/99/9999") + {&space-char} + STRING(v-time, "HH:MM:SS")
.
_main-hist-nws-option:
FOR EACH main_tt-hist-nws-option
ON error UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if main_tt-hist-nws-option.hn-id <> 0
  or main_tt-hist-nws-option.db-num = p-db-num
  then next _main-hist-nws-option.
  FIND FIRST buf_hist-nws-option WHERE
            buf_hist-nws-option.db-num = main_tt-hist-nws-option.db-num
        and buf_hist-nws-option.hn-id = main_tt-hist-nws-option.hn-id NO-ERROR.
  IF NOT AVAILABLE buf_hist-nws-option THEN DO:
    next _main-hist-nws-option.
  END.
  buffer-copy main_tt-hist-nws-option to buf_hist-nws-option.
end. /*_main-hist-nws-option:*/
run gbl/clearlib.p .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Switch-subject Dialog-Frame
PROCEDURE Switch-subject :
IF cb-subject-group = '':U THEN DO:
    ASSIGN
    v-col[1]:VISIBLE = NO
    tt-hist-nws-option.hist-to-nws-is-on:LABEL IN BROWSE br-option = {&label1}
    tt-hist-nws-option.hist-to-nws-is-on:width IN BROWSE br-option = 15
    v-col[2]:VISIBLE = NO
    tt-hist-nws-option.nws-to-hist-is-on:LABEL IN BROWSE br-option = {&label2}
    tt-hist-nws-option.nws-to-hist-is-on:width IN BROWSE br-option = 15
    v-col[3]:VISIBLE = NO
    tt-hist-nws-option.get-hist-from-nws-is-on:LABEL IN BROWSE br-option = {&label3}
    tt-hist-nws-option.get-hist-from-nws-is-on:width IN BROWSE br-option = 15
    v-col-tbl-name:VISIBLE  = NO
    tt-hist-nws-option.option-descr:LABEL  = "Группа данных"
    .
  END.
  ELSE DO:
     ASSIGN
     v-col[1]:VISIBLE = YES
     tt-hist-nws-option.hist-to-nws-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.hist-to-nws-is-on:width IN BROWSE br-option = 4
     v-col[2]:VISIBLE = YES
     tt-hist-nws-option.nws-to-hist-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.nws-to-hist-is-on:width IN BROWSE br-option = 4
     v-col[3]:VISIBLE = YES
     tt-hist-nws-option.get-hist-from-nws-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.get-hist-from-nws-is-on:width IN BROWSE br-option = 4
     v-col-tbl-name:VISIBLE  = YES
     tt-hist-nws-option.option-descr:label  = "Сущность"
     .
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-hn-group-label Dialog-Frame
FUNCTION get-hn-group-label RETURNS CHARACTER
  ( INPUT p-subject-group AS CHARACTER ) :

RETURN p-subject-group.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-hn-label Dialog-Frame
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer ) :

&SCOPED-DEFINE hn-option-val-code string(p-hn-option)
  RETURN {&hn-option-val-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME