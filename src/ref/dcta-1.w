&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-hist-nws-option NO-UNDO LIKE ub.hist-nws-option.
DEFINE TEMP-TABLE tt0-hist-nws-option NO-UNDO LIKE ub.hist-nws-option
       field get-hist-from-nws-is-on as logical
       field smart-nws-is-on as character
       field hist-to-nws-is-on as logical
       field hist-from-prim-is-on as logical
       field nws-to-cd-is-on as logical
       field nws-to-hist-is-on as logical
       field get-hist-from-nws-can as logical
       field smart-nws-can as logical
       field hist-to-nws-can as logical
       field hist-from-prim-can as logical
       field nws-to-cd-can as logical
       field nws-to-hist-can as logical.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опции записи истории и маршрутизации для типа ДК

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
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
define input parameter p-type like ub.dis-card-type.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
define INPUT-OUTPUT parameter table for tt-hist-nws-option.
define output parameter p-ok as logical no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Опции записи истории и маршрутизации для типа ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ ref/dcthnfll.i extended }

&SCOPED-DEFINE LABEL1 "Создание ист.!при изменении"
&SCOPED-DEFINE LABEL2 "Пересылка ист.!в другие БД"
&SCOPED-DEFINE label3 "Создание ист.!при приеме!по СПН"
&SCOPED-DEFINE label4 "Прием истории!из другой!УБД"
&SCOPED-DEFINE label5 "Смарт-!передача!по СПН"
&SCOPED-DEFINE label6 "Активация пер-чи!на кассы!из СПН"
/*&glob hn-option-val-codes-full 'Да,Нет,Смарт2,Всегда,Никогда'*/
&glob hn-option-val entry (lookup (~{&hn-option-label~}, ~{&hn-option-val-codes-full~}) + 1, ',' + ~{&hn-option-val-codes~})



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-hn

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-hist-nws-option

/* Definitions for BROWSE BR-hn                                         */
&Scoped-define FIELDS-IN-QUERY-BR-hn tt0-hist-nws-option.option-descr get-hn-label(tt0-hist-nws-option.hist-from-prim) tt0-hist-nws-option.hist-from-prim-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt0-hist-nws-option.hist-to-nws) tt0-hist-nws-option.hist-to-nws-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt0-hist-nws-option.nws-to-hist) tt0-hist-nws-option.nws-to-hist-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt0-hist-nws-option.get-hist-from-nws) tt0-hist-nws-option.get-hist-from-nws-is-on VIEW-AS TOGGLE-BOX get-hn-label(tt0-hist-nws-option.smart-nws) tt0-hist-nws-option.smart-nws-is-on VIEW-AS COMBO-BOX drop-down get-hn-label(tt0-hist-nws-option.nws-to-cd) tt0-hist-nws-option.nws-to-cd-is-on VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-hn tt0-hist-nws-option.hist-from-prim-is-on tt0-hist-nws-option.hist-to-nws-is-on tt0-hist-nws-option.nws-to-hist-is-on tt0-hist-nws-option.get-hist-from-nws-is-on tt0-hist-nws-option.smart-nws-is-on tt0-hist-nws-option.nws-to-cd-is-on
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-hn tt0-hist-nws-option
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-hn tt0-hist-nws-option
&Scoped-define SELF-NAME BR-hn
&Scoped-define QUERY-STRING-BR-hn FOR EACH tt0-hist-nws-option NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-hn OPEN QUERY {&SELF-NAME} FOR EACH tt0-hist-nws-option NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-hn tt0-hist-nws-option
&Scoped-define FIRST-TABLE-IN-QUERY-BR-hn tt0-hist-nws-option


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-hn}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BR-hn

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-hn-label Dialog-Frame
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-hn-value Dialog-Frame
FUNCTION get-hn-value RETURNS integer
  ( INPUT p-hn-label AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prop-head-label Dialog-Frame
FUNCTION get-prop-head-label RETURNS CHARACTER
  ( INPUT p-dtm-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-hn FOR
      tt0-hist-nws-option SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-hn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-hn Dialog-Frame _FREEFORM
  QUERY BR-hn NO-LOCK DISPLAY
      tt0-hist-nws-option.option-descr FORMAT "X(255)":U WIDTH 35
get-hn-label(tt0-hist-nws-option.hist-from-prim) FORMAT "X(15)" COLUMN-LABEL {&label1}
tt0-hist-nws-option.hist-from-prim-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX

get-hn-label(tt0-hist-nws-option.hist-to-nws) FORMAT "X(15)" COLUMN-LABEL {&label2}
tt0-hist-nws-option.hist-to-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX

get-hn-label(tt0-hist-nws-option.nws-to-hist) FORMAT "X(15)" COLUMN-LABEL {&label3}
tt0-hist-nws-option.nws-to-hist-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX

get-hn-label(tt0-hist-nws-option.get-hist-from-nws) FORMAT "X(15)" COLUMN-LABEL {&label4}
tt0-hist-nws-option.get-hist-from-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX

get-hn-label(tt0-hist-nws-option.smart-nws) FORMAT "X(15)" COLUMN-LABEL {&label5}
tt0-hist-nws-option.smart-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS COMBO-BOX


get-hn-label(tt0-hist-nws-option.nws-to-cd) FORMAT "X(15)" COLUMN-LABEL {&label6}
tt0-hist-nws-option.nws-to-cd-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX

ENABLE
tt0-hist-nws-option.hist-from-prim-is-on
tt0-hist-nws-option.hist-to-nws-is-on
tt0-hist-nws-option.nws-to-hist-is-on
tt0-hist-nws-option.get-hist-from-nws-is-on
tt0-hist-nws-option.smart-nws-is-on
tt0-hist-nws-option.nws-to-cd-is-on
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 21 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     BR-hn AT ROW 2 COL 1 WIDGET-ID 100
     SPACE(0.74) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции пересылки на кассу, создания истории и маршрутизации"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-hist-nws-option T "?" NO-UNDO ub hist-nws-option
      TABLE: tt0-hist-nws-option T "?" NO-UNDO ub hist-nws-option
      ADDITIONAL-FIELDS:
          field get-hist-from-nws-is-on as logical
          field smart-nws-is-on as character
          field hist-to-nws-is-on as logical
          field hist-from-prim-is-on as logical
          field nws-to-cd-is-on as logical
          field nws-to-hist-is-on as logical
          field get-hist-from-nws-can as logical
          field smart-nws-can as logical
          field hist-to-nws-can as logical
          field hist-from-prim-can as logical
          field nws-to-cd-can as logical
          field nws-to-hist-can as logical
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-hn B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-hn
/* Query rebuild information for BROWSE BR-hn
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-hist-nws-option NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-hn */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции пересылки на кассу, создания истории и маршрутизации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
DEFINE buffer buf_tt0-hist-nws-option FOR tt0-hist-nws-option.
IF p-mode = {&LOOKUP} THEN RETURN NO-APPLY.
RUN proc-save IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-hn
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON "leave" OF tt0-hist-nws-option.hist-to-nws-is-on  IN BROWSE br-hn
DO:
   IF tt0-hist-nws-option.hist-to-nws-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.hist-to-nws-is-on = (IF tt0-hist-nws-option.hist-to-Nws = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt0-hist-nws-option.hist-to-nws-is-on
    with browse br-hn.
  END.
END.
ON "leave" OF tt0-hist-nws-option.nws-to-hist-is-on  IN BROWSE br-hn
DO:
   IF tt0-hist-nws-option.nws-to-hist-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.nws-to-hist-is-on = (IF tt0-hist-nws-option.nws-to-hist = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt0-hist-nws-option.nws-to-hist-is-on
    with browse br-hn.
  END.
END.
ON "leave" OF tt0-hist-nws-option.get-hist-from-nws-is-on  IN BROWSE br-hn
DO:
   IF tt0-hist-nws-option.get-hist-from-nws-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.get-hist-from-nws-is-on = (IF tt0-hist-nws-option.get-hist-from-nws = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    DISPLAY
    tt0-hist-nws-option.get-hist-from-nws-is-on
    with browse br-hn.
  END.
END.
ON "leave" OF tt0-hist-nws-option.hist-from-prim-is-on  IN BROWSE br-hn
DO:
   IF tt0-hist-nws-option.hist-from-prim-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.hist-from-prim-is-on = (IF tt0-hist-nws-option.hist-from-prim = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt0-hist-nws-option.hist-from-prim-is-on
    with browse br-hn.
  END.
END.
ON "leave" OF tt0-hist-nws-option.nws-to-cd-is-on  IN BROWSE br-hn
DO:
   IF tt0-hist-nws-option.nws-to-cd-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.nws-to-cd-is-on = (IF tt0-hist-nws-option.nws-to-cd = integer({&hn-is-on-blocked})
                                            THEN YES
                                            ELSE NO).
    display
    tt0-hist-nws-option.nws-to-cd-is-on
    with browse br-hn.
  END.
END.

ON "value-changed" OF tt0-hist-nws-option.smart-nws-is-on  IN BROWSE br-hn
OR "leave" OF tt0-hist-nws-option.smart-nws-is-on  IN BROWSE br-hn
DO:
&scop hn-option-val-code        string(tt0-hist-nws-option.smart-nws)
   IF tt0-hist-nws-option.smart-nws-can = NO
   or p-mode = {&lookup}
   THEN DO:
    BELL.
    assign
    tt0-hist-nws-option.smart-nws-is-on = {&hn-option-val-name}
    .
    message
    tt0-hist-nws-option.smart-nws-is-on
        tt0-hist-nws-option.smart-nws-can
    view-as alert-box .

    display
    tt0-hist-nws-option.smart-nws-is-on
    with browse br-hn.
  END.
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN fill-tt0 IN THIS-PROCEDURE.
  RUN Myenable.
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
  ENABLE B-exit b-quit B-Help BR-hn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt0 Dialog-Frame
PROCEDURE fill-tt0 :
DEFINE BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
define buffer  buf_tt0-hist-nws-option for tt0-hist-nws-option.
FOR EACH buf_tt-hist-nws-option:
  CREATE buf_tt0-hist-nws-option.
  BUFFER-COPY buf_tt-hist-nws-option TO buf_tt0-hist-nws-option.
END.
run fill-tt0-hist-nws-option in this-procedure ( input p-emitent-host-code
                                                ,input p-type).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
tt0-hist-nws-option.option-descr:RESIZABLE IN BROWSE br-hn = YES
tt0-hist-nws-option.hist-to-nws-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
tt0-hist-nws-option.nws-to-hist-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
tt0-hist-nws-option.hist-from-prim-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
tt0-hist-nws-option.get-hist-from-nws-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
tt0-hist-nws-option.nws-to-cd-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
tt0-hist-nws-option.smart-nws-is-on:READ-ONLY in BROWSE br-hn = (p-mode = {&LOOKUP})
.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
br-hn
WITH FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
VIEW FRAME {&frame-name}.
assign
tt0-hist-nws-option.smart-nws-is-on:LIST-ITEMs  = {&hn-option-val-codes-to-change-full}
tt0-hist-nws-option.smart-nws-is-on:INNER-LINES in BROWSE br-hn = 5
.
frame {&frame-name}:title = substitute("&1: тип ДК &2, эмитент &3"
                                       , frame {&frame-name}:title
                                       , p-type
                                       , p-emitent-host-code).
{&OPEN-QUERY-br-hn}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER buf_tt0-hist-nws-option FOR tt0-hist-nws-option.
p-ok = yes.
FOR EACH buf_tt0-hist-nws-option
ON error UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  FIND FIRST buf_tt-hist-nws-option WHERE
            buf_tt-hist-nws-option.table-name = buf_tt0-hist-nws-option.table-name
         and buf_tt-hist-nws-option.host-code = p-emitent-host-code
         and buf_tt-hist-nws-option.obj-type = '':U
         and buf_tt-hist-nws-option.obj-code = 0
         and buf_tt-hist-nws-option.key#_one = buf_tt0-hist-nws-option.key#_one
         and buf_tt-hist-nws-option.charkey_one = p-type no-error.
  IF NOT AVAILABLE buf_tt-hist-nws-option THEN DO:
    CREATE buf_tt-hist-nws-option.
    BUFFER-COPY buf_tt0-hist-nws-option TO buf_tt-hist-nws-option.
  END.
  assign
  buf_tt-hist-nws-option.hist-to-nws = (IF buf_tt0-hist-nws-option.hist-to-nws-can
                                    THEN (IF buf_tt0-hist-nws-option.hist-to-nws-is-on
                                          THEN INTEGER({&hn-is-on})
                                          ELSE INTEGER({&hn-is-off})
                                          )
                                    ELSE buf_tt-hist-nws-option.hist-to-nws)
  buf_tt-hist-nws-option.nws-to-hist = (IF buf_tt0-hist-nws-option.nws-to-hist-can
                                      THEN (IF buf_tt0-hist-nws-option.nws-to-hist-is-on
                                              THEN INTEGER({&hn-is-on})
                                              ELSE INTEGER({&hn-is-off})
                                              )
                                      ELSE buf_tt-hist-nws-option.nws-to-hist)
  buf_tt-hist-nws-option.get-hist-from-nws = (IF buf_tt0-hist-nws-option.get-hist-from-nws-can
                                      THEN (IF buf_tt0-hist-nws-option.get-hist-from-nws-is-on
                                              THEN INTEGER({&hn-is-on})
                                              ELSE INTEGER({&hn-is-off})
                                              )
                                      ELSE buf_tt-hist-nws-option.get-hist-from-nws)
  buf_tt-hist-nws-option.hist-from-prim = (IF buf_tt0-hist-nws-option.hist-from-prim-can
                                      THEN (IF buf_tt0-hist-nws-option.hist-from-prim-is-on
                                                THEN INTEGER({&hn-is-on})
                                                ELSE INTEGER({&hn-is-off})
                                                )
                                      ELSE buf_tt-hist-nws-option.hist-from-prim)
  buf_tt-hist-nws-option.nws-to-cd = (IF buf_tt0-hist-nws-option.nws-to-cd-can
                                          THEN (IF buf_tt0-hist-nws-option.nws-to-cd-is-on
                                                  THEN INTEGER({&hn-is-on})
                                                  ELSE INTEGER({&hn-is-off})
                                                  )
                                          ELSE buf_tt-hist-nws-option.nws-to-cd).
  buf_tt-hist-nws-option.smart-nws = (IF buf_tt0-hist-nws-option.smart-nws-can
                                              THEN  integer(get-hn-value(buf_tt0-hist-nws-option.smart-nws-is-on))
                                              ELSE buf_tt-hist-nws-option.smart-nws)

      .
END.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-hn-label Dialog-Frame
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer ) :
&SCOPED-DEFINE hn-option-val-code string(p-hn-option)
  RETURN {&hn-option-val-name}.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-hn-value Dialog-Frame
FUNCTION get-hn-value RETURNS integer
  ( INPUT p-hn-label AS character ) :
&SCOPED-DEFINE hn-option-label p-hn-label
  RETURN integer({&hn-option-val}).   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prop-head-label Dialog-Frame
FUNCTION get-prop-head-label RETURNS CHARACTER
  ( INPUT p-dtm-code AS INTEGER ) :
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FIND FIRST buf_prop-head NO-LOCK WHERE
        buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
IF NOT AVAILABLE buf_prop-head THEN  RETURN {&question-mark}.
RETURN buf_prop-head.prop-label.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME