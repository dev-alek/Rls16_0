&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-layout-elem-rule NO-UNDO LIKE ub.layout-elem-rule.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для ввода, просмотра и изменения привязок элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/08
Author: Bakhtadze Natalya
Creation date: 10/03/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-device-type as character no-undo .
define input-output parameter table for tt0-layout-elem-rule.
define input-output parameter table for tt0-rule-call-param.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма для ввода, просмотра и изменения привязок элемента раскладки".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ rul/rulcalpa.i }
{ cmp/titlmode.i }
define variable v-admin as logical no-undo .
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-rule-call-param

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rule-call-param tt0-layout-elem-rule

/* Definitions for BROWSE BR-rule-call-param                            */
&Scoped-define FIELDS-IN-QUERY-BR-rule-call-param tt-rule-call-param.param-name tt-rule-call-param.param-label tt-rule-call-param.param-data-type get-param-value( INPUT tt-rule-call-param.param-data-type ,INPUT tt-rule-call-param.param-2-data-type ,INPUT tt-rule-call-param.param-3-data-type ,INPUT tt-rule-call-param.p-index ,INPUT tt-rule-call-param.param-value-character ,INPUT tt-rule-call-param.param-value-date ,INPUT tt-rule-call-param.param-value-decimal ,INPUT tt-rule-call-param.param-value-integer ,INPUT tt-rule-call-param.param-value-logical)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rule-call-param
&Scoped-define SELF-NAME BR-rule-call-param
&Scoped-define QUERY-STRING-BR-rule-call-param FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rule-call-param OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-rule-call-param tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rule-call-param tt-rule-call-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt0-layout-elem-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt0-layout-elem-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt0-layout-elem-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt0-layout-elem-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help E-des f-elem-label ~
f-elem-tooltip B-image-id-up B-image-id-down B-image-id-insen b-chg ~
BR-rule-call-param
&Scoped-Define DISPLAYED-OBJECTS f-rule-name E-des f-elem-label ~
f-elem-tooltip f-image-id-up f-image-id-down f-image-id-insen

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-image-id-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.

DEFINE BUTTON B-image-id-insen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.

DEFINE BUTTON B-image-id-up
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 6"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE E-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 3 NO-UNDO.

DEFINE VARIABLE f-elem-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Label"
     VIEW-AS FILL-IN NATIVE
     SIZE 29.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-elem-tooltip AS CHARACTER FORMAT "X(256)":U
     LABEL "Tooltip"
     VIEW-AS FILL-IN NATIVE
     SIZE 89 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-down AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии DOWN"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-insen AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии INSENSITIVE"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-up AS CHARACTER FORMAT "X(256)":U
     LABEL "Изобр. в состоянии UP"
     VIEW-AS FILL-IN NATIVE
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-rule-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 98 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rule-call-param FOR
      tt-rule-call-param SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt0-layout-elem-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rule-call-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rule-call-param Dialog-Frame _FREEFORM
  QUERY BR-rule-call-param NO-LOCK DISPLAY
      tt-rule-call-param.param-name column-label "Название"
tt-rule-call-param.param-label column-label "Название"
tt-rule-call-param.param-data-type column-label  "Тип!данных"
get-param-value( INPUT tt-rule-call-param.param-data-type
                ,INPUT tt-rule-call-param.param-2-data-type
                ,INPUT tt-rule-call-param.param-3-data-type
                ,INPUT tt-rule-call-param.p-index
                ,INPUT tt-rule-call-param.param-value-character
                ,INPUT tt-rule-call-param.param-value-date
                ,INPUT tt-rule-call-param.param-value-decimal
                ,INPUT tt-rule-call-param.param-value-integer
                ,INPUT tt-rule-call-param.param-value-logical) column-label "Значение"
format "X(255)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.27
         TITLE "Параметры" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-rule-name AT ROW 2 COL 1 NO-LABEL WIDGET-ID 96
     E-des AT ROW 3 COL 1 NO-LABEL WIDGET-ID 98
     f-elem-label AT ROW 6 COL 8 COLON-ALIGNED WIDGET-ID 74
     f-elem-tooltip AT ROW 7 COL 1 WIDGET-ID 92
     f-image-id-up AT ROW 8 COL 31 COLON-ALIGNED WIDGET-ID 78
     B-image-id-up AT ROW 8 COL 95 WIDGET-ID 86
     f-image-id-down AT ROW 9 COL 31 COLON-ALIGNED WIDGET-ID 82
     B-image-id-down AT ROW 9 COL 95 WIDGET-ID 88
     f-image-id-insen AT ROW 10 COL 31 COLON-ALIGNED WIDGET-ID 84
     B-image-id-insen AT ROW 10 COL 95 WIDGET-ID 90
     b-chg AT ROW 11.5 COL 1 WIDGET-ID 94
     BR-rule-call-param AT ROW 12.5 COL 1 WIDGET-ID 300
     SPACE(0.49) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Свойства элемента для раскладки"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-layout-elem-rule T "?" NO-UNDO ub layout-elem-rule
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rule-call-param b-chg Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       E-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-elem-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-elem-tooltip IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-down IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-down:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-insen IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-insen:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-up IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-up:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-rule-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rule-call-param
/* Query rebuild information for BROWSE BR-rule-call-param
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-rule-call-param */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-layout-elem-rule SHARE-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Свойства элемента для раскладки */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
  p-ok = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Свойства элемента для раскладки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available tt-rule-call-param then do:
     bell.
     return no-apply.
  end.
  run proc-b-chg in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-image-id-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-image-id-down Dialog-Frame
ON CHOOSE OF B-image-id-down IN FRAME Dialog-Frame /* Btn 6 */
DO:
  define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-down
     with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-image-id-insen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-image-id-insen Dialog-Frame
ON CHOOSE OF B-image-id-insen IN FRAME Dialog-Frame /* Btn 6 */
DO:
  define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-insen
     with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-image-id-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-image-id-up Dialog-Frame
ON CHOOSE OF B-image-id-up IN FRAME Dialog-Frame /* Btn 6 */
DO:
define variable v-file-name as character no-undo.
  run proc-file in this-procedure ( output v-file-name ) no-error.
  if not error-status:error then do:
     display
     v-file-name @ f-image-id-up
     with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-image-id-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-image-id-down Dialog-Frame
ON LEAVE OF f-image-id-down IN FRAME Dialog-Frame /* Изобр. в состоянии DOWN */
DO:
    define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

    ASSIGN
    f-image-id-down.
    IF f-image-id-down <> '' THEN DO:

    run gbl/filename.p ( INPUT f-image-id-down
                        ,OUTPUT v-full-path
                         ,OUTPUT v-path
                         ,OUTPUT v-file-name
                         ,OUTPUT v-file-name-no-ext
                         ,OUTPUT v-file-name-ext) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN DO:
           MESSAGE
           substitute("Ошибка при поиске файла &1&2&3&2&4"
                      , f-image-id-down
                      , {&NEW-LINE}
                      , error-status:get-message(1)
                      , RETURN-VALUE
                      )
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
       END.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-image-id-insen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-image-id-insen Dialog-Frame
ON LEAVE OF f-image-id-insen IN FRAME Dialog-Frame /* Изобр. в состоянии INSENSITIVE */
DO:
    define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

    ASSIGN
    f-image-id-insen.
    IF f-image-id-insen <> '' THEN DO:

    run gbl/filename.p ( INPUT f-image-id-insen
                        ,OUTPUT v-full-path
                         ,OUTPUT v-path
                         ,OUTPUT v-file-name
                         ,OUTPUT v-file-name-no-ext
                         ,OUTPUT v-file-name-ext) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN DO:
           MESSAGE
           substitute("Ошибка при поиске файла &1&2&3&2&4"
                      , f-image-id-insen
                      , {&NEW-LINE}
                      , error-status:get-message(1)
                      , RETURN-VALUE
                      )
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
       END.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-image-id-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-image-id-up Dialog-Frame
ON LEAVE OF f-image-id-up IN FRAME Dialog-Frame /* Изобр. в состоянии UP */
DO:
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

  ASSIGN
  f-image-id-up.
  IF f-image-id-up <> '' THEN DO:

  run gbl/filename.p ( INPUT f-image-id-up
                      ,OUTPUT v-full-path
                       ,OUTPUT v-path
                       ,OUTPUT v-file-name
                       ,OUTPUT v-file-name-no-ext
                       ,OUTPUT v-file-name-ext) NO-ERROR.
     IF ERROR-STATUS:ERROR THEN DO:
         MESSAGE
         substitute("Ошибка при поиске файла &1&2&3&2&4"
                    , f-image-id-up
                    , {&NEW-LINE}
                    , error-status:get-message(1)
                    , RETURN-VALUE
                    )
        VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
     END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rule-call-param
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), {&comma-char}).
  end.
  if lookup( p-mode, {&add-def} + {&comma-char} + {&update}) = 0 then do:
     message
     substitute("Неверное значение параметра p-mode=&1", p-mode)
     vss-workfile vss-revision vss-description skip
     view-as alert-box error .
     undo, return error .
  end.
  for each buf_tt-rule-call-param:
    delete buf_tt-rule-call-param.
  end.
  for each buf_tt0-rule-call-param:
    create buf_tt-rule-call-param.
    buffer-copy buf_tt0-rule-call-param to buf_tt-rule-call-param.
  end.
   RUN Myenable in this-procedure .
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
  DISPLAY f-rule-name E-des f-elem-label f-elem-tooltip f-image-id-up
          f-image-id-down f-image-id-insen
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help E-des f-elem-label f-elem-tooltip B-image-id-up
         B-image-id-down B-image-id-insen b-chg BR-rule-call-param
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_rule FOR ub.RULE.
ASSIGN
tt-rule-call-param.param-data-type:visible in browse br-rule-call-param = (v-admin = yes)
tt-rule-call-param.param-name:visible in browse br-rule-call-param = (v-admin = yes)
.
find first tt0-layout-elem-rule where tt0-layout-elem-rule.uniq-key-rec = p-uniq-key-rec.
assign
frame {&frame-name}:title = substitute("Функции для элемента ракладки &1 &2 &3"
                                     , (if p-mode = {&add-def} then '' else tt0-layout-elem-rule.layout-id)
                                     , title-mode(p-mode)
                                     ,( if v-admin then  "Режим IBS" else ''))
.


FIND FIRST buf_rule NO-LOCK WHERE
          buf_rule.RULE_id = tt0-layout-elem-rule.RULE_id NO-ERROR.
IF AVAILABLE buf_rule THEN DO:

ASSIGN
f-rule-name = buf_rule.NAME
e-des:SCREEN-VALUE IN FRAME {&FRAME-NAME}  = buf_rule.documentation
.
END.
ELSE DO:
ASSIGN
f-rule-name = substitute("!!!Неизвестная функция &1",tt-rule-call-param.RULE_id).
END.

DISPLAY
f-rule-name
tt0-layout-elem-rule.elem-label  @ f-elem-label
tt0-layout-elem-rule.elem-tooltip  @ f-elem-tooltip
tt0-layout-elem-rule.image-id-up  @ f-image-id-up
tt0-layout-elem-rule.image-id-down  @ f-image-id-down
tt0-layout-elem-rule.image-id-insen @ f-image-id-insen
WITH FRAME {&frame-name} .
ENABLE
B-exit
b-quit
B-Help
b-chg when can-find(first tt-rule-call-param where tt-rule-call-param.call_id = p-uniq-key-rec)
f-image-id-up WHEN p-mode <> {&LOOKUP}  and p-device-type =  {&th-pos-screen}
f-image-id-down WHEN p-mode <> {&LOOKUP} and p-device-type = {&th-pos-screen}
f-image-id-insen WHEN p-mode <> {&LOOKUP} and p-device-type = {&th-pos-screen}
f-elem-label
f-elem-tooltip  when  (p-mode <> {&LOOKUP}) and p-device-type = {&th-pos-screen}
B-image-id-up WHEN (p-mode <> {&LOOKUP})   and p-device-type =  {&th-pos-screen}
B-image-id-down WHEN (p-mode <> {&LOOKUP})  and p-device-type = {&th-pos-screen}
B-image-id-insen WHEN (p-mode <> {&LOOKUP}) and p-device-type = {&th-pos-screen}
BR-rule-call-param
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label in frame {&frame-name} = "&Выход"
  b-quit:column = 1.
  hide b-exit in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
run Openbr in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
OPEN QUERY br-rule-call-param
FOR EACH tt-rule-call-param WHERE tt-rule-call-param.call_id = tt0-layout-elem-rule.uniq-key-rec
NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
DEFINE VARIABLE v-rec AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.
v-param-data-type = tt-rule-call-param.param-data-type +
                    (if tt-rule-call-param.param-2-data-type = '':U
                     then '':U
                     else {&comma-char}) +
                    tt-rule-call-param.param-2-data-type
                     .
if lookup("READ-ONLY", tt-rule-call-param.param-3-data-type) > 0 then do:
  message
  "Данный параметр задан как READ-ONLY (Только для чтения)" skip
  "Изменения не допускаются"
  view-as alert-box error .
  undo, return error .
end.
CASE  v-param-data-type:
  when {&abl-datatype-integer} then do:
    assign
    v-value-integer = tt-rule-call-param.param-value-integer.
    run gbl/d-integer.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-integer
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                      ,INPUT tt-rule-call-param.param-value-character
                                      ,INPUT tt-rule-call-param.param-value-date
                                      ,INPUT tt-rule-call-param.param-value-decimal
                                      ,INPUT v-value-integer
                                      ,INPUT tt-rule-call-param.param-value-logical).


  end.
  when {&abl-datatype-decimal} then do:
    assign
    v-value-decimal = tt-rule-call-param.param-value-decimal.
    run gbl/d-decimal.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-decimal
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                      ,INPUT tt-rule-call-param.param-value-character
                                      ,INPUT tt-rule-call-param.param-value-date
                                      ,INPUT v-value-decimal
                                      ,INPUT tt-rule-call-param.param-value-decimal
                                      ,INPUT tt-rule-call-param.param-value-logical).


  end.

  when {&abl-datatype-character} then do:
    assign
    v-value-character = tt-rule-call-param.param-value-character.
    run gbl/d-character.w (
          input ?
         ,input (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=4\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-character
        , output v-ok
            ).
        if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT v-value-character
                                     ,INPUT tt-rule-call-param.param-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT tt-rule-call-param.param-value-logical).


  end.
  when {&abl-datatype-logical} then do:
    assign
    v-value-logical = tt-rule-call-param.param-value-logical.
    run gbl/d-logical.w (
          input ?
         ,input  (
          'title=':u + substitute("Изменение параметра &1", tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + tt-rule-call-param.param-label + '\':u
        + 'format=' + (if tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-logical
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT tt-rule-call-param.param-value-character
                                     ,INPUT tt-rule-call-param.param-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT v-value-logical).

  end.
  when {&abl-datatype-date} then do:
    assign
    v-value-date = tt-rule-call-param.param-value-date.
      run gbl/d-inpday.w
        (input ?                  /* h-callback    */
        ,input substitute("Изменение параметра &1", tt-rule-call-param.param-label)        /* p-title       */
        ,input ""                 /* p-description */
        ,input-output v-value-date /* p-date        */
        ,output v-ok              /* p-ok          */
        ) NO-ERROR.

    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                     ,INPUT tt-rule-call-param.param-value-character
                                     ,INPUT v-value-date
                                     ,INPUT tt-rule-call-param.param-value-decimal
                                     ,INPUT tt-rule-call-param.param-value-integer
                                     ,INPUT tt-rule-call-param.param-value-logical).
  end.
  otherwise do:
    assign
    v-value-character = tt-rule-call-param.param-value-character
    v-value-date = tt-rule-call-param.param-value-date
    v-value-decimal = tt-rule-call-param.param-value-decimal
    v-value-integer = tt-rule-call-param.param-value-integer
    v-value-logical = tt-rule-call-param.param-value-logical
    .
    run ref/rule-dtt.p (
                         input parparentproc
                        ,input {&update}
                        ,input tt0-layout-elem-rule.uniq-key-rec
                        ,input tt-rule-call-param.param-data-type
                        ,input tt-rule-call-param.param-2-data-type
                        ,input tt-rule-call-param.param-3-data-type
                        ,input tt-rule-call-param.p-index
                        ,input-output v-value-character
                        ,input-output v-value-date
                        ,input-output v-value-decimal
                        ,input-output v-value-integer
                        ,input-output v-value-logical
                        ,output v-ok
                        ) no-error.

    if not error-status:error
    and v-ok then do:
      RUN set-value IN THIS-PROCEDURE (
                                       INPUT tt-rule-call-param.profile_id
                                      ,INPUT tt-rule-call-param.once-more
                                      ,INPUT '':U
                                      ,INPUT tt-rule-call-param.call_id
                                      ,INPUT tt-rule-call-param.codex_id
                                      ,INPUT tt-rule-call-param.ruleset_id
                                      ,INPUT tt-rule-call-param.order_id
                                      ,INPUT tt-rule-call-param.param-name
                                      ,INPUT tt-rule-call-param.p-index
                                       ,INPUT v-value-character
                                       ,INPUT v-value-date
                                       ,INPUT v-value-decimal
                                       ,INPUT v-value-integer
                                       ,INPUT v-value-logical).
    end.
  end. /*otherwise*/
end case.

ASSIGN
v-rec = Rowid(tt-rule-call-param)
.
run openbr in this-procedure .
REPOSITION br-rule-call-param TO Rowid v-rec NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-rule-call-param TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY" TO br-rule-call-param in frame {&frame-name} .
APPLY "VALUE-CHANGED" TO br-rule-call-param in frame {&frame-name} .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-file Dialog-Frame
PROCEDURE proc-file :
define output parameter file-name as character no-undo.
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
SYSTEM-DIALOG GET-FILE v_os-file
TITLE "Задайте файл для изображения"
FILTERS
  "Все ico файлы (*.ico) " "*.ico",
  "Все файлы (*.*)"                      "*.*"
INITIAL-FILTER 1
DEFAULT-EXTENSION ".xml"
USE-FILENAME
MUST-EXIST
UPDATE ll_commit
.
IF ll_commit <> YES THEN do:
    RETURN NO-APPLY.
end.
IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
    BELL.
    MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
run gbl/filename.p (
                input  v_os-file
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  return no-apply.
end.
assign
file-name = v-full-path.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.

assign
frame {&frame-name}
f-elem-label
f-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
.

if f-elem-label = '' then do:
  message
  "Вы не определили лейбл"
  view-as alert-box error .
  undo, return error .
end.

for each buf_tt-rule-call-param:
  find first buf_tt0-rule-call-param where
           buf_tt0-rule-call-param.call_id = buf_tt-rule-call-param.call_id
       and buf_tt0-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
       and buf_tt0-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
       and buf_tt0-rule-call-param.order_id = buf_tt-rule-call-param.order_id
       and buf_tt0-rule-call-param.param-name = buf_tt-rule-call-param.param-name
       and buf_tt0-rule-call-param.p-index = buf_tt-rule-call-param.p-index
             .
  buffer-copy buf_tt-rule-call-param to buf_tt0-rule-call-param.
end.

assign
tt0-layout-elem-rule.elem-label = f-elem-label
tt0-layout-elem-rule.elem-tooltip = f-elem-tooltip
tt0-layout-elem-rule.image-id-up = f-image-id-up
tt0-layout-elem-rule.image-id-down = f-image-id-down
tt0-layout-elem-rule.image-id-insen = f-image-id-insen
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-value Dialog-Frame
PROCEDURE set-value :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-param-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
FIND FIRST buf_tt-rule-call-param WHERE
    buf_tt-rule-call-param.call_id = p-call-id
AND buf_tt-rule-call-param.codex_id = p-codex-id
AND buf_tt-rule-call-param.ruleset_id = p-ruleset-id
AND buf_tt-rule-call-param.order_id = p-order-id
AND buf_tt-rule-call-param.param-name = p-param-name
AND buf_tt-rule-call-param.p-index = p-index.
assign
buf_tt-rule-call-param.param-value-character = p-value-character
buf_tt-rule-call-param.param-value-date      = p-value-date
buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
buf_tt-rule-call-param.param-value-integer   = p-value-integer
buf_tt-rule-call-param.param-value-logical   = p-value-logical
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
