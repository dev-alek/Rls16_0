&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_custom-labels FOR ub.custom-labels.
DEFINE TEMP-TABLE tt-custom-labels NO-UNDO LIKE ub.custom-labels.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание пользовательских лейблов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-field-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-point AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE input-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание пользовательских лейблов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable v-is-copy as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-custom-labels.call-point ~
tt-custom-labels.call-type tt-custom-labels.tbl-name ~
tt-custom-labels.language tt-custom-labels.fld-name ~
tt-custom-labels.fld-data-type tt-custom-labels.custom-label ~
tt-custom-labels.custom-format tt-custom-labels.widget-width ~
tt-custom-labels.widget-type tt-custom-labels.widget-list-items ~
tt-custom-labels.custom-view-func tt-custom-labels.reference-proc ~
tt-custom-labels.custom-tooltip tt-custom-labels.init-value-character ~
tt-custom-labels.init-value-date tt-custom-labels.init-value-integer ~
tt-custom-labels.init-value-decimal tt-custom-labels.init-value-logical
&Scoped-define ENABLED-TABLES tt-custom-labels
&Scoped-define FIRST-ENABLED-TABLE tt-custom-labels
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-custom-labels.call-point ~
tt-custom-labels.call-type tt-custom-labels.tbl-name ~
tt-custom-labels.language tt-custom-labels.fld-name ~
tt-custom-labels.fld-data-type tt-custom-labels.custom-label ~
tt-custom-labels.custom-format tt-custom-labels.widget-width ~
tt-custom-labels.widget-type tt-custom-labels.widget-list-items ~
tt-custom-labels.custom-view-func tt-custom-labels.reference-proc ~
tt-custom-labels.custom-tooltip tt-custom-labels.init-value-character ~
tt-custom-labels.init-value-date tt-custom-labels.init-value-integer ~
tt-custom-labels.init-value-decimal tt-custom-labels.init-value-logical
&Scoped-define DISPLAYED-TABLES tt-custom-labels
&Scoped-define FIRST-DISPLAYED-TABLE tt-custom-labels


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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-custom-labels.call-point AT ROW 2.77 COL 13.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "call-point" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-custom-labels.call-type AT ROW 2.77 COL 54.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "call-type" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     tt-custom-labels.tbl-name AT ROW 4 COL 13.5 COLON-ALIGNED WIDGET-ID 20
          LABEL "tbl-name"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN
          SIZE 31 BY 1
     tt-custom-labels.language AT ROW 4 COL 57.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "language"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-custom-labels.fld-name AT ROW 5.27 COL 13.5 COLON-ALIGNED WIDGET-ID 22
          LABEL "fld-name"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN
          SIZE 31.5 BY 1
     tt-custom-labels.fld-data-type AT ROW 5.27 COL 62 COLON-ALIGNED WIDGET-ID 40
          LABEL "fld-data-type" FORMAT "x(10)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-custom-labels.custom-label AT ROW 7 COL 13.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "custom-label" FORMAT "x(40)"
          VIEW-AS FILL-IN
          SIZE 29.5 BY 1
     tt-custom-labels.custom-format AT ROW 7 COL 60.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "custom-format" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 27 BY 1
     tt-custom-labels.widget-width AT ROW 8.2 COL 60.5 COLON-ALIGNED WIDGET-ID 46 FORMAT "->>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-custom-labels.widget-type AT ROW 8.47 COL 13.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42 FORMAT "x(12)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 29.5 BY 1
     tt-custom-labels.widget-list-items AT ROW 9.53 COL 16 NO-LABEL WIDGET-ID 48
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 76 BY 2.93
     tt-custom-labels.custom-view-func AT ROW 12.73 COL 17.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "custom-view-func" FORMAT "x(32)"
          VIEW-AS FILL-IN
          SIZE 28 BY 1
     tt-custom-labels.reference-proc AT ROW 14.07 COL 18 COLON-ALIGNED WIDGET-ID 44 FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 54.5 BY 1
     tt-custom-labels.custom-tooltip AT ROW 15.17 COL 1.5 NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN
          SIZE 98 BY 1
     tt-custom-labels.init-value-character AT ROW 16.43 COL 1 WIDGET-ID 26
          LABEL "Начальное значение (char)"
          VIEW-AS FILL-IN
          SIZE 45.5 BY 1
     tt-custom-labels.init-value-date AT ROW 17.93 COL 26 COLON-ALIGNED WIDGET-ID 28
          LABEL "Начальное значение (date)"
          VIEW-AS FILL-IN
          SIZE 18.5 BY 1
     tt-custom-labels.init-value-integer AT ROW 19.13 COL 29 COLON-ALIGNED WIDGET-ID 32
          LABEL "Начальное значение (integer)"
          VIEW-AS FILL-IN
          SIZE 23.5 BY 1
     tt-custom-labels.init-value-decimal AT ROW 20.57 COL 29 COLON-ALIGNED WIDGET-ID 30
          LABEL "Начальное значение (decimal)"
          VIEW-AS FILL-IN
          SIZE 37.5 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-custom-labels.init-value-logical AT ROW 21.93 COL 31 WIDGET-ID 36
          LABEL "Начальное значение (logical)"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     "Listitems" VIEW-AS TEXT
          SIZE 12.5 BY 1 AT ROW 9.53 COL 2 WIDGET-ID 50
     SPACE(85.19) SKIP(12.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_custom-labels B "?" ? ub custom-labels
      TABLE: tt-custom-labels T "?" NO-UNDO ub custom-labels
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

/* SETTINGS FOR FILL-IN tt-custom-labels.call-point IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-custom-labels.call-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-custom-labels.custom-format IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-custom-labels.custom-label IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-custom-labels.custom-tooltip IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-custom-labels.custom-view-func IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-custom-labels.fld-data-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-custom-labels.fld-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-custom-labels.init-value-character IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-custom-labels.init-value-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-custom-labels.init-value-decimal IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-custom-labels.init-value-integer IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-custom-labels.init-value-logical IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-custom-labels.language IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-custom-labels.reference-proc IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR COMBO-BOX tt-custom-labels.tbl-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-custom-labels.widget-list-items:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR COMBO-BOX tt-custom-labels.widget-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-custom-labels.widget-width IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
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
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-custom-labels.tbl-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-custom-labels.tbl-name Dialog-Frame
ON VALUE-CHANGED OF tt-custom-labels.tbl-name IN FRAME Dialog-Frame /* tbl-name */
DO:
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_field FOR ub._field.
DEFINE BUFFER buf_file FOR ub._file.
ASSIGN
tt-custom-labels.tbl-name.
DO v-ii = 1 TO tt-custom-labels.fld-name:NUM-ITEMS IN FRAME {&FRAME-NAME}:
  tt-custom-labels.fld-name:DELETE(tt-custom-labels.fld-name:ENTRY(v-ii)).
END.

FIND FIRST buf_file NO-LOCK WHERE
        buf_file._HIDDEN  = NO
     AND buf_file._file-name = tt-custom-labels.tbl-name NO-ERROR.
IF AVAILABLE buf_file THEN DO:

FOR EACH buf_field NO-LOCK WHERE
        buf_field._file-recid = RECID(buf_file):
  tt-custom-labels.fld-name:ADD-LAST( buf_field._field-name) IN FRAME {&FRAME-NAME}.
END.
END.

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
  IF p-mode = {&add-def} THEN DO:
    CREATE tt-custom-labels.
  END.
  ELSE DO:
     IF p-mode = {&UPDATE} THEN DO:
         FIND FIRST LOCKED_custom-labels EXCLUSIVE-LOCK WHERE
                   LOCKED_custom-labels.tbl-name = p-tbl-name
               AND LOCKED_custom-labels.fld-name = p-field-name
               AND LOCKED_custom-labels.call-type = p-call-type
               AND LOCKED_custom-labels.call-point = p-call-point
               AND LOCKED_custom-labels.language = p-language NO-ERROR.

     END.
     IF p-mode = {&lookup}
     or p-mode = {&add-copy}
     THEN DO:
         FIND FIRST LOCKED_custom-labels no-LOCK WHERE
                   LOCKED_custom-labels.tbl-name = p-tbl-name
               AND LOCKED_custom-labels.fld-name = p-field-name
               AND LOCKED_custom-labels.call-type = p-call-type
               AND LOCKED_custom-labels.call-point = p-call-point
               AND LOCKED_custom-labels.language = p-language NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_custom-labels THEN DO:
         MESSAGE
         "Не найдена запись"
         VIEW-AS ALERT-BOX ERROR.
       return error.
     END.
     CREATE tt-custom-labels.
     BUFFER-COPY LOCKED_custom-labels TO tt-custom-labels.
     if p-mode = {&add-copy} then do:
       assign
       v-is-copy = yes
       p-mode = {&add-def}.
     end.
  END.
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
  IF AVAILABLE tt-custom-labels THEN
    DISPLAY tt-custom-labels.call-point tt-custom-labels.call-type
          tt-custom-labels.tbl-name tt-custom-labels.language
          tt-custom-labels.fld-name tt-custom-labels.fld-data-type
          tt-custom-labels.custom-label tt-custom-labels.custom-format
          tt-custom-labels.widget-width tt-custom-labels.widget-type
          tt-custom-labels.widget-list-items tt-custom-labels.custom-view-func
          tt-custom-labels.reference-proc tt-custom-labels.custom-tooltip
          tt-custom-labels.init-value-character tt-custom-labels.init-value-date
          tt-custom-labels.init-value-integer
          tt-custom-labels.init-value-decimal
          tt-custom-labels.init-value-logical
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-custom-labels.call-point
         tt-custom-labels.call-type tt-custom-labels.tbl-name
         tt-custom-labels.language tt-custom-labels.fld-name
         tt-custom-labels.fld-data-type tt-custom-labels.custom-label
         tt-custom-labels.custom-format tt-custom-labels.widget-width
         tt-custom-labels.widget-type tt-custom-labels.widget-list-items
         tt-custom-labels.custom-view-func tt-custom-labels.reference-proc
         tt-custom-labels.custom-tooltip tt-custom-labels.init-value-character
         tt-custom-labels.init-value-date tt-custom-labels.init-value-integer
         tt-custom-labels.init-value-decimal
         tt-custom-labels.init-value-logical
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_file FOR _file.
FOR EACH buf_file NO-LOCK WHERE
        buf_file._HIDDEN  = NO:
  tt-custom-labels.tbl-name:ADD-LAST( buf_file._file-name) IN FRAME {&FRAME-NAME}.
END.
tt-custom-labels.fld-data-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&ABL-simple-datatype-list}.
tt-custom-labels.widget-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = "fill-in,toggle-box,combo-box".
IF AVAILABLE tt-custom-labels THEN
DISPLAY
tt-custom-labels.call-type
tt-custom-labels.call-point
tt-custom-labels.custom-format
tt-custom-labels.custom-label
tt-custom-labels.custom-view-func
tt-custom-labels.reference-proc
tt-custom-labels.language
tt-custom-labels.tbl-name
tt-custom-labels.fld-name
tt-custom-labels.fld-data-type
tt-custom-labels.custom-tooltip
tt-custom-labels.init-value-character
tt-custom-labels.init-value-date
tt-custom-labels.init-value-decimal
tt-custom-labels.init-value-integer
tt-custom-labels.init-value-logical
tt-custom-labels.widget-type
tt-custom-labels.widget-width
WITH FRAME {&frame-name}.
tt-custom-labels.widget-list-items:screen-value = tt-custom-labels.widget-list-items.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
tt-custom-labels.call-type WHEN p-mode = {&add-def}
tt-custom-labels.call-point WHEN p-mode = {&add-def}
tt-custom-labels.custom-format WHEN p-mode <> {&LOOKUP}
tt-custom-labels.custom-label WHEN p-mode <> {&LOOKUP}
tt-custom-labels.custom-view-func WHEN p-mode <> {&LOOKUP}
tt-custom-labels.reference-proc WHEN p-mode <> {&LOOKUP}
tt-custom-labels.language WHEN p-mode = {&add-def}
tt-custom-labels.tbl-name WHEN p-mode = {&add-def}
tt-custom-labels.fld-name WHEN p-mode = {&add-def}
tt-custom-labels.custom-tooltip WHEN p-mode <> {&LOOKUP}
tt-custom-labels.init-value-character WHEN p-mode <> {&LOOKUP}
tt-custom-labels.init-value-date WHEN p-mode <> {&LOOKUP}
tt-custom-labels.init-value-decimal WHEN p-mode <> {&LOOKUP}
tt-custom-labels.init-value-integer WHEN p-mode <> {&LOOKUP}
tt-custom-labels.init-value-logical WHEN p-mode <> {&LOOKUP}
tt-custom-labels.fld-data-type WHEN p-mode <> {&LOOKUP}
tt-custom-labels.widget-type WHEN p-mode <> {&LOOKUP}
tt-custom-labels.widget-width WHEN p-mode <> {&LOOKUP}
tt-custom-labels.widget-list-items
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
   HIDE
   b-exit IN FRAME {&FRAME-NAME}.
   ASSIGN
   b-quit:LABEL = "&Выход"
   b-quit:COLUMN = 1
   tt-custom-labels.widget-list-items:read-only = yes
   .

END.
APPLY "value-changed" TO tt-custom-labels.tbl-name.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
tt-custom-labels.call-type
tt-custom-labels.call-point
tt-custom-labels.custom-format
tt-custom-labels.custom-label
tt-custom-labels.custom-view-func
tt-custom-labels.language
tt-custom-labels.tbl-name
tt-custom-labels.fld-name
tt-custom-labels.fld-data-type
tt-custom-labels.custom-tooltip
tt-custom-labels.init-value-character
tt-custom-labels.init-value-date
tt-custom-labels.init-value-decimal
tt-custom-labels.init-value-integer
tt-custom-labels.init-value-logical
tt-custom-labels.reference-proc
tt-custom-labels.widget-type
tt-custom-labels.widget-width
.
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.
if tt-custom-labels.tbl-name = ? then do:
  tt-custom-labels.tbl-name = '':U.
end.
if tt-custom-labels.fld-name = ? then do:
  tt-custom-labels.fld-name = '':U.
end.
run utl/cuslabl1.p ( INPUT p-mode
                    ,INPUT NO /*p-silent*/
                     ,INPUT-OUTPUT v-rec
                     ,INPUT tt-custom-labels.tbl-name
                     ,INPUT tt-custom-labels.fld-name
                     ,INPUT tt-custom-labels.call-type
                     ,INPUT tt-custom-labels.call-point
                     ,INPUT tt-custom-labels.LANGUAGE
                     ,INPUT tt-custom-labels.fld-data-type
                     ,INPUT tt-custom-labels.custom-label
                     ,INPUT tt-custom-labels.custom-view-func
                     ,INPUT tt-custom-labels.reference-proc
                     ,INPUT tt-custom-labels.custom-format
                     ,INPUT tt-custom-labels.custom-tooltip
                      ,INPUT tt-custom-labels.init-value-character
                      ,INPUT tt-custom-labels.init-value-date
                      ,INPUT tt-custom-labels.init-value-decimal
                      ,INPUT tt-custom-labels.init-value-integer
                      ,INPUT tt-custom-labels.init-value-logical
                      ,INPUT tt-custom-labels.widget-type
                      ,INPUT tt-custom-labels.widget-width
                     ,INPUT tt-custom-labels.widget-LIST-ITEMS:SCREEN-VALUE
                     ) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

