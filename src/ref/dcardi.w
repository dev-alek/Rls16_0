&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-card-long FOR ub.dis-card-long.
DEFINE BUFFER locked_dis-card-property FOR ub.dis-card-property.
DEFINE TEMP-TABLE temp-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE tt0-dis-card-long NO-UNDO LIKE ub.dis-card-long.
DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дисконтная карта - добавление,изменение

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter ref-mode as char no-undo .
define input parameter paremitent-host-code like ub.sysconf.host-code no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.shop.obj-code no-undo.
define input parameter cli-ri           as recid no-undo . /*нуден только при доабвлении копировании перевыпуске*/
define input-output parameter dc-ri           as recid no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Дисконтная карта - добавление,изменение" .
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ str/clc-dcpc.i }
{ gbl/cur-time.i }
{ ref/discprop.i }
{ gbl/clntattr.i }
{ gbl/perproc.i }
{ ref/tmpchgs.i "NEW SHARED" temp-labels update }
{ ref/tmpchgs.i  }
{ rul/tempcont.i }
define variable v-curr-r-b as character no-undo .
define buffer sourced_dis-card for ub.dis-card.
define buffer main_dis-card for ub.dis-card.
define variable v-is-copy as logical no-undo .
define variable v-is-sourced as logical no-undo .
define variable v-is-subsid as logical no-undo .
define variable v-tab-order as character no-undo .
define variable v-update-property as logical no-undo .
define variable v-found-copy-prop as logical no-undo .
define variable v-can-edit as logical no-undo .
define variable v-is-dct-client as logical no-undo .
define variable v-initial-type as character no-undo .
define variable v-initial-emitent-host-code as integer no-undo .
DEFINE BUFFER cli-buf FOR ub.clients.
DEFINE BUFFER shop-buf FOR ub.shop.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-dis-card

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame temp-dis-card.d-card ~
temp-dis-card.is-subsid temp-dis-card.d-pcnt temp-dis-card.cash-d-pcnt ~
temp-dis-card.category temp-dis-card.credit-card temp-dis-card.debet-card ~
temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date ~
temp-dis-card.valid-from temp-dis-card.valid-date temp-dis-card.issue-code ~
temp-dis-card.cli-message temp-dis-card.first-main-card temp-dis-card.type ~
temp-dis-card.first-card temp-dis-card.emitent-host-code ~
temp-dis-card.main-card
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame temp-dis-card.d-card ~
temp-dis-card.d-pcnt temp-dis-card.cash-d-pcnt temp-dis-card.category ~
temp-dis-card.credit-card temp-dis-card.debet-card temp-dis-card.staff-card ~
temp-dis-card.lim-kr temp-dis-card.issue-date temp-dis-card.valid-from ~
temp-dis-card.valid-date temp-dis-card.issue-code temp-dis-card.cli-message ~
temp-dis-card.type temp-dis-card.first-card temp-dis-card.emitent-host-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame temp-dis-card
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame temp-dis-card
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH temp-dis-card SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH temp-dis-card SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame temp-dis-card
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame temp-dis-card


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS temp-dis-card.d-card temp-dis-card.d-pcnt ~
temp-dis-card.cash-d-pcnt temp-dis-card.category temp-dis-card.credit-card ~
temp-dis-card.debet-card temp-dis-card.staff-card temp-dis-card.lim-kr ~
temp-dis-card.issue-date temp-dis-card.valid-from temp-dis-card.valid-date ~
temp-dis-card.issue-code temp-dis-card.cli-message temp-dis-card.type ~
temp-dis-card.first-card temp-dis-card.emitent-host-code
&Scoped-define ENABLED-TABLES temp-dis-card
&Scoped-define FIRST-ENABLED-TABLE temp-dis-card
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 RECT-2 RECT-3 RECT-4 b-quit ~
b-prop B-ltype b-long B-hist B-Help B-type T-overissue B-scard ~
v-pcnt-method B-shop emitent-name var-r-b-abbr issue-code-name
&Scoped-Define DISPLAYED-FIELDS temp-dis-card.d-card ~
temp-dis-card.is-subsid temp-dis-card.d-pcnt temp-dis-card.cash-d-pcnt ~
temp-dis-card.category temp-dis-card.credit-card temp-dis-card.debet-card ~
temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date ~
temp-dis-card.valid-from temp-dis-card.valid-date temp-dis-card.issue-code ~
temp-dis-card.cli-message temp-dis-card.first-main-card temp-dis-card.type ~
temp-dis-card.first-card temp-dis-card.emitent-host-code ~
temp-dis-card.main-card
&Scoped-define DISPLAYED-TABLES temp-dis-card
&Scoped-define FIRST-DISPLAYED-TABLE temp-dis-card
&Scoped-Define DISPLAYED-OBJECTS T-overissue v-pcnt-method emitent-name ~
var-r-b-abbr issue-code-name

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

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-long
     LABEL "Номера"
     SIZE 10 BY 1.

DEFINE BUTTON B-ltype
     LABEL "Тип карты"
     SIZE 10 BY 1.

DEFINE BUTTON b-prop
     LABEL "&Свойства"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-scard
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-shop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE BUTTON B-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.3 BY 1 NO-UNDO.

DEFINE VARIABLE issue-code-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.4 BY 1 NO-UNDO.

DEFINE VARIABLE var-r-b-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE v-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 45.3 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 3.27.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 3.13.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 9.5.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.5 BY 1.43.

DEFINE VARIABLE T-overissue AS LOGICAL INITIAL no
     LABEL "Перевыпуск"
     VIEW-AS TOGGLE-BOX
     SIZE 15.2 BY .93 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      temp-dis-card SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-prop AT ROW 1 COL 41 WIDGET-ID 2
     B-ltype AT ROW 1 COL 51
     b-long AT ROW 1 COL 61
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-type AT ROW 2.63 COL 34.8
     temp-dis-card.d-card AT ROW 5.43 COL 15.3 COLON-ALIGNED
          LABEL "Номер карты"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     temp-dis-card.is-subsid AT ROW 5.43 COL 61
          LABEL "Дополн. карта"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY .93
     T-overissue AT ROW 5.5 COL 38
     B-scard AT ROW 6.87 COL 39
     temp-dis-card.d-pcnt AT ROW 8.13 COL 20 COLON-ALIGNED
          LABEL "% скидки на товар"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          FGCOLOR 4
     temp-dis-card.cash-d-pcnt AT ROW 9.3 COL 20 COLON-ALIGNED
          LABEL "% скидки на итог"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          FGCOLOR 4
     temp-dis-card.category AT ROW 9.3 COL 48.5 COLON-ALIGNED
          LABEL "Категория" FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     v-pcnt-method AT ROW 10.47 COL 24 NO-LABEL
     temp-dis-card.credit-card AT ROW 12.13 COL 3
          LABEL "Кредитная карта"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.debet-card AT ROW 12.13 COL 38.5
          LABEL "Дебетовая карта"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.staff-card AT ROW 12.13 COL 60.5
          LABEL "Карта персонала"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.lim-kr AT ROW 13.53 COL 15.5 COLON-ALIGNED
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 19.6 BY .93
     temp-dis-card.issue-date AT ROW 15.4 COL 15.5 COLON-ALIGNED
          LABEL "Дата выдачи"
          VIEW-AS FILL-IN
          SIZE 11.3 BY 1.03
     temp-dis-card.valid-from AT ROW 15.4 COL 46.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Действует с"
          VIEW-AS FILL-IN
          SIZE 12.6 BY .97
     temp-dis-card.valid-date AT ROW 15.4 COL 75.1 COLON-ALIGNED
          LABEL "Действует до"
          VIEW-AS FILL-IN
          SIZE 12.6 BY .97
     temp-dis-card.issue-code AT ROW 16.83 COL 15.8 COLON-ALIGNED
          LABEL "Выдал магазин"
          VIEW-AS FILL-IN
          SIZE 6.6 BY .93
     B-shop AT ROW 16.83 COL 32.9
     temp-dis-card.cli-message AT ROW 18.63 COL 2.5
          LABEL "Сообщ. для клиента(POS MAGIA)"
          VIEW-AS FILL-IN
          SIZE 45.5 BY 1
     temp-dis-card.first-main-card AT ROW 2.6 COL 74 COLON-ALIGNED
          LABEL "Первичная основная карта"
           VIEW-AS TEXT
          SIZE 20 BY .67
          FGCOLOR 4
     temp-dis-card.type AT ROW 2.67 COL 15.4 COLON-ALIGNED
          LABEL "Тип карты"
           VIEW-AS TEXT
          SIZE 15.1 BY 1 TOOLTIP "Тип карты"
          FGCOLOR 4
     temp-dis-card.first-card AT ROW 3.93 COL 73.5 COLON-ALIGNED
          LABEL "Первичная карта"
           VIEW-AS TEXT
          SIZE 20.5 BY .67
          FGCOLOR 9
     temp-dis-card.emitent-host-code AT ROW 4.03 COL 15.3 COLON-ALIGNED
          LABEL "Эмитент"
		  FORMAT ">>>>>>>>99"
           VIEW-AS TEXT
          SIZE 7.1 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     emitent-name AT ROW 4.17 COL 20.8 COLON-ALIGNED NO-LABEL
     temp-dis-card.sourced-card AT ROW 6.87 COL 15.5 COLON-ALIGNED
          LABEL "К карте"
           VIEW-AS TEXT
          SIZE 20 BY .67
     temp-dis-card.main-card AT ROW 6.87 COL 64.5 COLON-ALIGNED
          LABEL "Основная"
           VIEW-AS TEXT
          SIZE 25.5 BY .67
          FGCOLOR 4
     var-r-b-abbr AT ROW 13.53 COL 38 COLON-ALIGNED NO-LABEL
     issue-code-name AT ROW 16.83 COL 34.9 COLON-ALIGNED NO-LABEL
     "Использовать скидку" VIEW-AS TEXT
          SIZE 20.9 BY .93 AT ROW 10.47 COL 2.5
     RECT-1 AT ROW 11.67 COL 2
     RECT-2 AT ROW 15.03 COL 2
     RECT-3 AT ROW 2.17 COL 2
     RECT-4 AT ROW 18.37 COL 2
     SPACE(18.29) SKIP(0.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дисконтная карта".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-card-long B "?" ? ub dis-card-long
      TABLE: locked_dis-card-property B "?" ? ub dis-card-property
      TABLE: temp-dis-card T "?" NO-UNDO ub dis-card
      TABLE: tt0-dis-card-long T "?" NO-UNDO ub dis-card-long
      TABLE: tt0-dis-card-property T "?" NO-UNDO ub dis-card-property
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

ASSIGN
       B-scard:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN temp-dis-card.cash-d-pcnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.category IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN temp-dis-card.cli-message IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX temp-dis-card.credit-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.d-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.d-pcnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX temp-dis-card.debet-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.emitent-host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.first-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.first-main-card IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR TOGGLE-BOX temp-dis-card.is-subsid IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN temp-dis-card.issue-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.issue-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.lim-kr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.main-card IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN
       temp-dis-card.main-card:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN temp-dis-card.sourced-card IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN
       temp-dis-card.sourced-card:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX temp-dis-card.staff-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.valid-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dis-card.valid-from IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.temp-dis-card"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дисконтная карта */
DO:
   RUN check-update-prop IN THIS-PROCEDURE ( input yes) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
   dc-ri = ?.
   run perproc-delete-from-parent (  input this-procedure , input "").
   APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run check-update-prop in this-procedure ( input no) .
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run perproc-delete-from-parent( input this-procedure , input "").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
    DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
      run ref/cdchist.w (
                    INPUT parparentproc
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input "":U
                    ,input "one":U
                    ,input temp-dis-card.d-card
                    ,input temp-dis-card.card-num
                    ,input parobj-type
                    ,input parobj-code
                    ,input parhost-code
                    ,input ? /*p-corr-user-db-num */
                    ,input "":U /*p-corr-user-name */
                    ,input "":U /*p-subject*/
                    ,input ? /*p-db-num */
                    /*записи в выборке*/
                    ,input-output v-list
                 ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-long
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-long Dialog-Frame
ON CHOOSE OF b-long IN FRAME Dialog-Frame /* Номера */
DO:
  if not available temp-dis-card then return no-apply.
  run proc-b-long in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ltype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ltype Dialog-Frame
ON CHOOSE OF B-ltype IN FRAME Dialog-Frame /* Тип карты */
DO:
  DEFINE VARIABLE v-ri AS RECID NO-UNDO.
  DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
  IF AVAILABLE temp-dis-card THEN DO:
      FIND FIRST buf_dis-card-type NO-LOCK WHERE
                buf_dis-card-type.emitent-host-code = input frame {&frame-name} temp-dis-card.emitent-host-code
          AND buf_dis-card-type.TYPE = input frame {&frame-name}  temp-dis-card.TYPE
          AND buf_dis-card-type.host-code = 0
          AND buf_dis-card-type.obj-TYPE = "":U
          AND buf_dis-card-type.obj-code = 0
          NO-ERROR.
    IF AVAILABLE buf_dis-card-type  THEN DO:
        ASSIGN
            v-ri = RECID(buf_dis-card-type)
            .
        run ref/dc-typei.w (
                        input parparentproc
                      , input {&lookup}
                      , input parhost-code
                      , input parobj-type
                      , input parobj-code
                      , INPUT-OUTPUT v-ri ) NO-ERROR.
    END.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop Dialog-Frame
ON CHOOSE OF b-prop IN FRAME Dialog-Frame /* Свойства */
DO:

    if not available temp-dis-card then return no-apply.
    run proc-b-prop in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  RUN check-update-prop IN THIS-PROCEDURE ( input yes) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
   dc-ri = ?.
   run perproc-delete-from-parent ( input this-procedure , input "").
   apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-scard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-scard Dialog-Frame
ON CHOOSE OF B-scard IN FRAME Dialog-Frame
DO:
 run proc-b-scard in this-procedure no-error.
 if error-status:error then return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shop Dialog-Frame
ON CHOOSE OF B-shop IN FRAME Dialog-Frame /* Btn 2 */
DO:
 RUN local-shop-chk ("issue-code", "button").
  apply "entry" to temp-dis-card.issue-code in FRAME {&FRAME-NAME}.
  return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type Dialog-Frame
ON CHOOSE OF B-type IN FRAME Dialog-Frame
DO:
 run proc-b-type in this-procedure no-error.
 if error-status:error then return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dis-card.credit-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dis-card.credit-card Dialog-Frame
ON VALUE-CHANGED OF temp-dis-card.credit-card IN FRAME Dialog-Frame /* Кредитная карта */
DO:
  run enable-lim-kr in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dis-card.is-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dis-card.is-subsid Dialog-Frame
ON VALUE-CHANGED OF temp-dis-card.is-subsid IN FRAME Dialog-Frame /* Дополн. карта */
DO:
  ASSIGN t-overissue.
  CASE t-overissue:
    when yes then do:
        VIEW
        temp-dis-card.sourced-card
        In frame {&frame-name}.
        DISPLAY
        b-scard
        with frame {&frame-name}.
        ENABLE
        b-scard
        with frame {&frame-name}.
    end.
    when no then do:
        DISABLE
        b-scard
        temp-dis-card.sourced-card
        with frame {&frame-name}.
        HIDE
        b-scard
        temp-dis-card.sourced-card
        in frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dis-card.issue-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dis-card.issue-code Dialog-Frame
ON LEAVE OF temp-dis-card.issue-code IN FRAME Dialog-Frame /* Выдал магазин */
DO:
    if input frame {&frame-name} temp-dis-card.issue-code <> temp-dis-card.issue-code then do:
    run local-shop-chk ("issue-code", "leave-message").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dis-card.issue-code Dialog-Frame
ON RETURN OF temp-dis-card.issue-code IN FRAME Dialog-Frame /* Выдал магазин */
DO:
    run local-shop-chk ("issue-code", "ret-mouse").
  apply "entry" to temp-dis-card.issue-code in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-overissue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-overissue Dialog-Frame
ON VALUE-CHANGED OF T-overissue IN FRAME Dialog-Frame /* Перевыпуск */
DO:
  ASSIGN t-overissue.
  CASE t-overissue:
    when yes then do:
        VIEW
        temp-dis-card.sourced-card
        In frame {&frame-name}.
        DISPLAY
        b-scard
        with frame {&frame-name}.
        ENABLE
        b-scard
        with frame {&frame-name}.
    end.
    when no then do:
        DISABLE
        b-scard
        temp-dis-card.sourced-card
        with frame {&frame-name}.
        HIDE
        b-scard
        temp-dis-card.sourced-card
        in frame {&frame-name}.
    end.
  END CASE.
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
{ ref/tabhndmv.i v-tab-order UNDERLINE-TB }
{ gbl/ed_date.i temp-dis-card.issue-date }
{ gbl/ed_date.i temp-dis-card.valid-date }
{ gbl/ed_date.i temp-dis-card.valid-from }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if ref-mode <> {&update}
  and ref-mode <> {&add-def}
  and ref-mode <> {&add-copy}
  and ref-mode <> {&lookup}
  and ref-mode <> ({&update} + {&comma-char} + {&add-copy}) /*перевыпуск*/
  and ref-mode <> ({&add-def} + {&comma-char} + {&add-copy}) /*дополнительная*/
  and ref-mode <> {&dct-client} /*КЛИЕНТ-СЧЕТ*/
  then do:
    message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова ref-mode"
    view-as alert-box ERROR.
    return error.
  end.
  if paremitent-host-code < 0 or paremitent-host-code = ? then do:
    message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова paremitent-host-code"
    view-as alert-box ERROR.
    return error.
  end.
  for each temp-dis-card:
    delete temp-dis-card.
  end.
  for each temp-labels:
    delete temp-labels.
  end.
  for each temp-changes:
     delete temp-changes.
  end.

  if ref-mode = ({&update} + {&comma-char} + {&add-copy}) then do:
    assign
    v-is-sourced = yes
    ref-mode  = {&add-def}
    .
  end.
  if ref-mode = ({&add-def} + {&comma-char} + {&add-copy}) then do:
    assign
    v-is-subsid = yes
    ref-mode  = {&add-def}
    .
  end.

  if ref-mode = {&add-copy} then do:
    assign
    v-is-copy = yes
    ref-mode  = {&add-def}
    .
  end.
{ gbl/curr-r-b.i
  v-curr-r-b
}
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN DO:
    undo main-block, return error .
  END.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-update-prop Dialog-Frame
PROCEDURE check-update-prop :
define input parameter p-exit-without-save as logical no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable v-updated as logical no-undo .
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
if ref-mode <> {&add-def} then do:
  if v-update-property then do:
    for each tt0-dis-card-property NO-LOCK where
            tt0-dis-card-property.d-card = ub.dis-card.d-card:
      if tt0-dis-card-property.dt-code = 0
      and tt0-dis-card-property.node-code = 0
      then next.
      find first buf_dis-card-property NO-LOCK WHERE
              buf_dis-card-property.d-card = tt0-dis-card-property.d-card
        AND   buf_dis-card-property.host-code = tt0-dis-card-property.host-code
        AND   buf_dis-card-property.obj-type = tt0-dis-card-property.obj-type
        AND   buf_dis-card-property.obj-code = tt0-dis-card-property.obj-code
        AND   buf_dis-card-property.dt-code = tt0-dis-card-property.dt-code
        AND   buf_dis-card-property.node-code = tt0-dis-card-property.node-code
        no-error.
      assign
      v-updated = no.
      if available  buf_dis-card-property then do:
        v-updated-str = "":U.
        BUFFER-COMPARE tt0-dis-card-property
                    TO buf_dis-card-property
                    case-sensitive
                    SAVE result IN v-updated-str.
        assign
        v-created = yes
        v-updated = (v-updated-str <> "":U)
        .
      end.
      else do:
        assign
        v-updated = yes.
      end.
      ASSIGN
      v-update-property = (v-update-property or v-updated).
    End.
    FOR EACH buf_dis-card-property where
            buf_dis-card-property.d-card = dis-card.d-card
            :
      if buf_dis-card-property.dt-code = 0
      and buf_dis-card-property.node-code = 0
      then next.
      FIND FIRST tt0-dis-card-property NO-LOCK WHERE
                tt0-dis-card-property.d-card   = buf_dis-card-property.d-card
            AND tt0-dis-card-property.host-code = buf_dis-card-property.host-code
            AND tt0-dis-card-property.obj-type = buf_dis-card-property.obj-type
            AND tt0-dis-card-property.obj-code = buf_dis-card-property.obj-code
            AND tt0-dis-card-property.dt-code = buf_dis-card-property.dt-code
            and tt0-dis-card-property.node-code = buf_dis-card-property.node-code   NO-ERROR.
        IF NOT AVAILABLE tt0-dis-card-property THEN DO:
          assign
          v-deleted = yes.
          ASSIGN
          v-update-property = (v-deleted OR v-update-property).
        END.
    END.
  end.
end.
if (v-is-sourced or v-is-copy or v-is-subsid) and v-found-copy-prop then v-update-property = yes.
if ref-mode = {&add-def} then return.
if not p-exit-without-save then return.
IF v-update-property THEN DO:
    MESSAGE
    substitute("Были изменены свойства ДК &1&2"
              ,(if v-found-copy-prop then " или были унаследованы свойства ДК" else "":U)
              , {&NEW-LINE}
              )
    "Сделанные изменения будут отменены" skip
    "Продолжить?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF NOT glog  THEN RETURN error.
END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-r-b-abbr Dialog-Frame
PROCEDURE display-r-b-abbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-curr-r-b  as character no-undo .
{ gbl/curr-r-b.i v-curr-r-b  no-error }
if paremitent-host-code = 0
and v-curr-r-b = {&r-b-base}
then do:
  var-r-b-abbr = ?.
end.
else do:
  { gbl/r-b-abbr.i paremitent-host-code var-r-b-abbr no-error }
end.
display var-r-b-abbr
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-lim-kr Dialog-Frame
PROCEDURE enable-lim-kr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if temp-dis-card.credit-card:screen-value in frame {&frame-name} = "yes" and ref-mode <> {&lookup}
THEN DO:
    enable
    temp-dis-card.lim-kr with frame {&frame-name}.
    DISABLE
    temp-dis-card.debet-card
    with frame {&frame-name}.

END.
ELSE DO:
    disable
    temp-dis-card.lim-kr with frame {&frame-name}.
    IF ref-mode <> {&LOOKUP} THEN
    ENABLE
    temp-dis-card.debet-card
    with frame {&frame-name}.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY T-overissue v-pcnt-method emitent-name var-r-b-abbr issue-code-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE temp-dis-card THEN
    DISPLAY temp-dis-card.d-card temp-dis-card.is-subsid temp-dis-card.d-pcnt
          temp-dis-card.cash-d-pcnt temp-dis-card.category
          temp-dis-card.credit-card temp-dis-card.debet-card
          temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date
          temp-dis-card.valid-from temp-dis-card.valid-date
          temp-dis-card.issue-code temp-dis-card.cli-message
          temp-dis-card.first-main-card temp-dis-card.type
          temp-dis-card.first-card temp-dis-card.emitent-host-code
          temp-dis-card.main-card
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 RECT-2 RECT-3 RECT-4 b-quit b-prop B-ltype b-long B-hist
         B-Help B-type temp-dis-card.d-card T-overissue B-scard
         temp-dis-card.d-pcnt temp-dis-card.cash-d-pcnt temp-dis-card.category
         v-pcnt-method temp-dis-card.credit-card temp-dis-card.debet-card
         temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date
         temp-dis-card.valid-from temp-dis-card.valid-date
         temp-dis-card.issue-code B-shop temp-dis-card.cli-message
         temp-dis-card.type temp-dis-card.first-card
         temp-dis-card.emitent-host-code emitent-name var-r-b-abbr
         issue-code-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varalien-str as character no-undo .
define variable v-type as character no-undo .
define variable v-exist as logical no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.

FOR EACH tt0-dis-card-property:
    DELETE tt0-dis-card-property.
END.
FOR EACH temp-dis-card:
    DELETE temp-dis-card.
END.
if ref-mode = {&dct-client} then do:
  find first buf_dis-card-type no-lock where
            buf_dis-card-type.type = {&dct-client}
        and buf_dis-card-type.emitent-host-code = 0 no-error.
  if not available buf_Dis-card-type then do:
    message
    substitute("В Вашей системе невозможно работать с картами типа КЛИЕНТ-СЧЕТ&1" +
               "Отсутствует специальный тип карты КЛИЕНТ-СЧЕТ"
               , {&new-line})
    view-as alert-box error .
    undo, return error .
  end.
  FIND ub.clients WHERE recid( ub.clients ) = cli-ri NO-LOCK.
  if not avail ub.clients then do:
    dc-ri = ?.
    undo, return error.
  end.
  if ub.clients.obj-type = {&shop} OR ub.clients.obj-type = {&stock} then do:
    dc-ri = ?.
    message
    substitute("Дисконтныe карты выдаются&1"  +
               "только внешним контрагентам"
               , {&new-line})
    view-as alert-box error.
    undo, return error.
  end.
&scop dct-client-obj-type clients.obj-type
&scop dct-client-obj-code clients.obj-code
  find first ub.dis-card no-lock where
           ub.dis-card.d-card = {&dct-client-card-no} no-error .
  if not available ub.dis-card then do:
    assign
    v-is-dct-client = yes
    ref-mode = {&add-def}
    .
  end.
  else do:
    find first ub.dis-card exclusive-lock where
            ub.dis-card.d-card = {&dct-client-card-no} no-error .
    if locked ub.dis-card then do:
      message vss-workfile vss-revision vss-description skip
              "Запись дисконтной карты занята"
      view-as alert-box error .
      return error.
    end.
    assign
    v-is-dct-client = yes
    ref-mode = {&update}
    dc-ri = recid(dis-card)
    .
  end.
end.
  CASE ref-mode:
    when {&update} then do:
      find first dis-card exclusive-lock where
                recid(dis-card) = dc-ri no-wait no-error.
      if locked dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты занята"
        view-as alert-box error .
        return error.
      end.
      if not available dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      find first clients No-LOCK WHERE
                 clients.obj-type = dis-card.cli-type AND
                 clients.obj-code = dis-card.cli-code no-error .
      if not avail clients then do:
        message vss-workfile vss-revision vss-description skip
                "Запись клиента дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      create temp-dis-card.
      buffer-copy dis-card to temp-dis-card.
      assign
      v-initial-type = temp-dis-card.type
      v-initial-emitent-host-code = temp-dis-card.emitent-host-code
      .
    end.
    when {&lookup} then do:
      find first dis-card No-LOCK where recid(dis-card) = dc-ri no-error.
      if not available dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      find first clients No-LOCK WHERE
                 clients.obj-type = dis-card.cli-type AND
                 clients.obj-code = dis-card.cli-code no-error .
      if not avail clients then do:
        message vss-workfile vss-revision vss-description skip
                "Запись клиента дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      create temp-dis-card.
      buffer-copy dis-card to temp-dis-card.
    end.
    when {&add-def} then do:
      if v-is-copy then do:
        find first dis-card No-LOCK where recid(dis-card) = dc-ri no-error.
        if not available dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись дисконтной карты для копирования не найдена"
          view-as alert-box error .
          return error.
        end.
        if dis-card.type = {&dct-client} then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя копировать карту типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        if v-is-copy and dis-card.mask-card = yes then
        buffer-copy dis-card
        except cli-type cli-code issue-date sourced-card issue-code valid-from valid-date saldo-base saldo-rubl mask-card
        first-card first-main-card main-card is-subsid overissue-num
        to temp-dis-card.
        else
        buffer-copy dis-card
        except cli-type cli-code d-card issue-date sourced-card issue-code valid-from valid-date saldo-base saldo-rubl mask-card
        first-card first-main-card main-card is-subsid overissue-num
        to temp-dis-card.
      end. /*v-is-copy*/
      if v-is-subsid then do:
        find first main_dis-card exclusive-lock where
                  recid(main_dis-card) = dc-ri no-wait no-error.
        if locked main_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись основной дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
        if not available main_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись основной дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        if main_dis-card.mask-card then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя выпускать дополнительную карту к карте-маске"
          view-as alert-box error .
          return error.
        end.
        if main_dis-card.type = {&dct-client} then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя выпускать дополнительную карту к карте типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        find first clients No-LOCK WHERE
                  clients.obj-type = main_dis-card.cli-type AND
                  clients.obj-code = main_dis-card.cli-code no-error .
        if not avail clients then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись клиента основной дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        buffer-copy main_dis-card except d-card cli-type cli-code
        issue-date issue-code valid-from valid-date sourced-card saldo-base saldo-rubl
        to temp-dis-card
        assign
        temp-dis-card.main-card = main_dis-card.d-card
        temp-dis-card.is-subsid = yes
        .
      end.  /*v-is-subsid*/
      if v-is-sourced then do:
        find first sourced_dis-card exclusive-lock where
                  recid(sourced_dis-card) = dc-ri no-wait no-error.
        if locked sourced_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись перевыпускаемой дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
        if not available sourced_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись перевыпускаемой дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        if sourced_dis-card.mask-card then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя перевыпускать карту-маску"
          view-as alert-box error .
          return error.
        end.
        if sourced_dis-card.type = {&dct-client} then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя перевыпускать карту типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        find first clients No-LOCK WHERE
                  clients.obj-type = sourced_dis-card.cli-type AND
                  clients.obj-code = sourced_dis-card.cli-code no-error .
        if not avail clients then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись клиента дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        buffer-copy sourced_dis-card except d-card
        issue-date issue-code valid-from valid-date sourced-card saldo-base saldo-rubl
        to temp-dis-card
        assign
        temp-dis-card.sourced-card = sourced_dis-card.d-card
        .
      end.  /*v-is-sourced*/
      if not v-is-sourced then do:
        FIND clients WHERE recid( clients ) = cli-ri NO-LOCK.
          if not avail clients then do:
            dc-ri = ?.
            return error.
          end.
          if clients.obj-type = {&shop} OR clients.obj-type = {&stock} then do:
            dc-ri = ?.
            message "Дисконтную карты выдаются" skip
                    "только внешним контрагентам"
            view-as alert-box error.
            return error.
          end.
        end.
        /*проверим что не чужой*/
        run clntattr-value in this-procedure (
                                              input clients.obj-type
                                              ,input  clients.obj-code
                                              ,input  {&attr-alien}
                                              ,output varalien-str
                                              ,output v-type) no-error .
        if not error-status:error
        AND logical(varalien-str) = yes then do:
          message
          "Нельзя изменять выдать ДК ЧУЖОМУ клиенту/фирме"
          view-as alert-box error .
          undo, return error .
        end.
        if v-is-copy and available temp-dis-card then do:
          assign
          temp-dis-card.cli-type = clients.obj-type
          temp-dis-card.cli-code = clients.obj-code
          .
        end.
      if not avail temp-dis-card then create temp-dis-card.
      assign
      temp-dis-card.cli-type = clients.obj-type
      temp-dis-card.cli-code = clients.obj-code
      .
      if v-is-dct-client then do:
        assign
        temp-dis-card.type = buf_dis-card-type.type
        temp-dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
        temp-dis-card.d-card = {&dct-client-card-no}
        .
      end.

    end. /*{&add-def}*/
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-shop-chk Dialog-Frame
PROCEDURE local-shop-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "issue-code" and p-action = "ret-mouse" then do:
   { ref/shop-chk.i issue-code ret-mouse temp-dis-card temp-dis-card.emitent-host-code }
end.
if p-man = "issue-code" and p-action = "button" then do:
   { ref/shop-chk.i issue-code button temp-dis-card temp-dis-card.emitent-host-code }
end.
if p-man = "issue-code" and p-action = "leave-message" then do:
   { ref/shop-chk.i issue-code leave-message temp-dis-card temp-dis-card.emitent-host-code }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
{&OPEN-QUERY-Dialog-Frame}
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
assign
v-tab-order =
"b-quit,b-exit,b-prop,b-long,b-hist,b-ltype,b-help,b-type,":U +
"type,d-card,t-overissue,b-scard,d-pcnt,cash-d-pcnt,category,v-pcnt-method,credit-card,debet-card,staff-card,lim-kr,":U +
"valid-from,valid-date,issue-date,issue-code,b-shop,cli-message".


GET FIRST Dialog-Frame.

assign
v-pcnt-method:Radio-buttons in frame {&frame-name} =
 "{&bef-dc-d-pcnt-good-full}" + {&comma-char} + string({&dc-d-pcnt-good}) + {&comma-char} +
 "{&bef-dc-d-pcnt-cash-full}" + {&comma-char} + string({&dc-d-pcnt-cash}) + {&comma-char} +
 "{&bef-dc-d-pcnt-both-full}" + {&comma-char} + string({&dc-d-pcnt-both})
v-pcnt-method = (if ref-mode = {&add-def} and not (v-is-copy or v-is-sourced or v-is-subsid)
               then {&dc-d-pcnt-good}
               else string(temp-dis-card.d-pcnt-method))
.


DISPLAY emitent-name
WITH FRAME {&FRAME-NAME}.
if avail temp-dis-card and temp-dis-card.sourced-card <> "" then
t-overissue = yes.
IF AVAILABLE temp-dis-card
THEN
DISPLAY
temp-dis-card.d-card
temp-dis-card.d-pcnt
temp-dis-card.cash-d-pcnt
temp-dis-card.category
temp-dis-card.issue-date
temp-dis-card.issue-code
temp-dis-card.category
temp-dis-card.credit-card
temp-dis-card.lim-kr
temp-dis-card.type
(IF temp-dis-card.cli-message = ? THEN "":U ELSE temp-dis-card.cli-message) temp-dis-card.cli-message
temp-dis-card.emitent-host-code
temp-dis-card.valid-from
temp-dis-card.valid-date
temp-dis-card.sourced-card
t-overissue
v-pcnt-method
WITH FRAME {&FRAME-NAME}.
IF temp-dis-card.sourced-card <> '':U THEN DO:
  DISPLAY
  temp-dis-card.first-card
  WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
  HIDE
  temp-dis-card.first-card
   IN FRAME {&FRAME-NAME}.
END.
IF temp-dis-card.is-subsid THEN DO:
  DISPLAY
  temp-dis-card.is-subsid
  temp-dis-card.main-card
  WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
  HIDE
  temp-dis-card.is-subsid
  temp-dis-card.main-card
  IN FRAME {&FRAME-NAME}.
END.
IF temp-dis-card.sourced-card <> '':U
and temp-dis-card.is-subsid
THEN DO:
DISPLAY
temp-dis-card.first-main-card
WITH FRAME {&FRAME-NAME}.
end.
else do:
hide
temp-dis-card.first-main-card
in FRAME {&FRAME-NAME}.
end.
IF avail temp-dis-card then do:
if temp-dis-card.debet-card = ? THEN do:
  ASSIGN
  temp-dis-card.debet-card  = NO
  .
end.
DISPLAY
temp-dis-card.debet-card
WITH FRAME {&frame-name}.
if ref-mode = {&add-def}
and temp-dis-card.issue-code = 0
then do:
  temp-dis-card.issue-code = parobj-code.
end.

display
temp-dis-card.issue-code
with frame {&frame-name} .
if not temp-dis-card.mask-card then do:
  { ref/shop-chk.i issue-code on temp-dis-card temp-dis-card.emitent-host-code}
end.
IF temp-dis-card.staff-card = ? THEN do:
      temp-dis-card.staff-card = NO.
END.
DISPLAY
temp-dis-card.staff-card
WITH FRAME {&frame-name}.
end.
if ref-mode = {&add-def} then do:
run cur-time in this-procedure ( output v-today, output v-time).
  display
  v-today @ temp-dis-card.issue-date
  parobj-code @ temp-dis-card.issue-code
  v-today @ temp-dis-card.valid-from
  WITH FRAME {&frame-name}.
end.
assign
frame {&frame-name}:title = frame {&frame-name}:title + {&colon-char} + {&space-char} + ub.clients.obj-name
.

ENABLE
B-exit when ref-mode <> {&lookup}
b-quit
b-ltype WHEN (ref-mode <> {&add-def} or v-is-sourced or v-is-subsid)
b-long
b-hist WHEN ref-mode <> {&add-def}
B-Help
B-type when ref-mode <> {&lookup}
t-overissue when (ref-mode = {&add-def} and not v-is-copy and not v-is-sourced and not v-is-subsid)
temp-dis-card.d-card when ref-mode = {&add-def}
temp-dis-card.d-pcnt when ref-mode <> {&lookup}
temp-dis-card.cash-d-pcnt when ref-mode <> {&lookup}
temp-dis-card.category when ref-mode <> {&lookup}
temp-dis-card.issue-date when ref-mode <> {&lookup}
temp-dis-card.issue-code when (ref-mode <> {&lookup} and not temp-dis-card.mask-card)
temp-dis-card.valid-from  when ref-mode <> {&lookup}
temp-dis-card.valid-date  when ref-mode <> {&lookup}
B-shop when (ref-mode <> {&lookup} and not temp-dis-card.mask-card)
temp-dis-card.credit-card when (paremitent-host-code <> 0 and
                              (ref-mode = {&add-def} or
                               (ref-mode = {&update} AND NOT temp-dis-card.credit-card)
                              )
                             ) and ref-mode <> {&lookup}
temp-dis-card.debet-card WHEN    (ref-mode = {&add-def} or
                               (ref-mode = {&update} AND NOT temp-dis-card.credit-card))
temp-dis-card.staff-card when ref-mode <> {&lookup}
temp-dis-card.cli-message when ref-mode <> {&lookup}
b-prop
WITH FRAME {&frame-name}.
if v-is-dct-client then do:
disable
B-type
t-overissue
temp-dis-card.d-card
with frame {&frame-name} .
run proc-b-type in this-procedure .
display
temp-dis-card.d-card
with frame {&frame-name} .
end.

CASE ref-mode:
when {&lookup} then do:
  b-quit:label = "&Выход".
  Hide b-exit in frame {&frame-name}.
  apply "entry" to b-quit.
end.
when {&add-def} then do:
  if v-is-sourced then do:
    disable
    b-type
    temp-dis-card.emitent-host-code
    t-overissue
    with frame {&frame-name} .
  end.
  if v-is-subsid then do:
    disable
    b-type
    temp-dis-card.emitent-host-code
    t-overissue
    with frame {&frame-name} .
  end.
  APPLY "entry" to temp-dis-card.d-card.
end.
when {&update} then do:
  APPLY "entry" to temp-dis-card.d-pcnt.
end.
END CASE.
hide
b-long in frame {&frame-name} .
run enable-lim-kr in this-procedure.
run display-r-b-abbr in this-procedure no-error.
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-{&frame-name}}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-long Dialog-Frame
PROCEDURE proc-b-long :
DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-long for ub.dis-card-long.

message
"Функционал в разработке" view-as alert-box .
return.
/*
do
on error undo, return ERROR RETURN-VALUE
:
assign frame {&frame-name}
temp-dis-card.d-card
temp-dis-card.emitent-host-code
.
if ref-mode = {&update} then do:
  do transaction
  on error undo, return error return-value
  on stop undo, return error return-value
  :
      Find first locked_dis-card-long exclusive-lock  where
              locked_dis-card-long.d-card = temp-dis-card.d-card
          and locked_dis-card-long.long-d-card = '':U
          and locked_dis-card-long.card-media = 0
          no-error no-wait.
      if not available locked_dis-card-long
      and not locked locked_dis-card-long then do:
        create locked_dis-card-long.
        assign
        locked_dis-card-long.d-card =  temp-dis-card.d-card
        locked_dis-card-long.long-d-card = '':U
        locked_dis-card-long.card-media = 0
        .
      end.
      if locked locked_dis-card-long then do:
      Find first locked_dis-card-long exclusive-lock  where
              locked_dis-card-long.d-card =  temp-dis-card.d-card
          and locked_dis-card-long.long-d-card = '':U
          and locked_dis-card-long.card-media = 0
          no-error .
      end.
      run trg/lock-dcl.p persistent set v-proc-handle (recid(locked_dis-card-long)) .
      run perproc-create-proc in this-procedure (
                                                input  this-procedure
                                                ,input  "trg/lock-dcl.p"
                                                ,input  v-proc-handle
                                                ,input  no
                                                ,input  "":u
                                                ,input v-cntxt-userid
                                                ,input 0 /*p-rank-to-delete*/
                                                ,output v-id) .
  end.
end.
CASE ref-mode:
  WHEN {&UPDATE} or
  when {&lookup}
  THEN DO:
    if not v-update-property then do:
      FOR EACH buf_dis-card-long no-lock where
      buf_dis-card-long.d-card =  temp-dis-card.d-card :
      if buf_dis-card-long.long-d-card = '':U then next.
        CREATE tt0-dis-card-long.
        BUFFER-COPY buf_dis-card-long TO tt0-dis-card-long.
      END.
    end.
  END.
  WHEN {&ADD-def} THEN DO:
    /*может быть только для копировании или перевыпуске*/
  END.
END CASE.
for each tt0-dis-card-long :
  assign
  tt0-dis-card-long.d-card            = temp-dis-card.d-card
  .
end.
/*
r u n ref/d c - l o n g i.w (
                input parparentproc
              ,input ref-mode
              ,input temp-dis-card.d-card
              ,input temp-dis-card.emitent-host-code
              ,input temp-dis-card.type
              ,input parhost-code
              ,input parobj-type
              ,input parobj-code
              ,input no /*instant-update*/
              ,output v-updated-now
              ,input-output table tt0-dis-card-long
                ) no-error.
if error-status:error then do:
  return no-apply.
end.
*/
ASSIGN
v-update-property = v-update-property OR v-updated-now
.
if v-update-property then do:
end.
else do:
  for each tt0-dis-card-long:
    delete tt0-dis-card-long.
  end.
end.

end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-prop Dialog-Frame
PROCEDURE proc-b-prop :
define variable v-data-type as character no-undo . /*тип атрибута*/
define variable v-format as character no-undo .  /* формат атрибута*/
define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .  /*пользователь может изменять в броусе*/

DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.


  do
  on error undo, return error
  :
assign frame {&frame-name}
temp-dis-card.d-card
temp-dis-card.emitent-host-code
.
if ref-mode = {&update} then do:
  do transaction
  on error undo, return error return-value
  on stop undo, return error return-value
  :
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = temp-dis-card.d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error no-wait.
      if not available locked_dis-card-property
      and not locked locked_dis-card-property then do:
        create locked_dis-card-property.
        assign
        locked_dis-card-property.host-code = 0
        locked_dis-card-property.obj-type =  '':U
        locked_dis-card-property.obj-code = 0
        locked_dis-card-property.d-card =  temp-dis-card.d-card
        locked_dis-card-property.dt-code = 0
        locked_dis-card-property.node-code = 0
        .
      end.
      if locked locked_dis-card-property then do:
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card =  temp-dis-card.d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error .
      end.
      run trg/lock-dcp.p persistent set v-proc-handle (recid(locked_dis-card-property)) .
      run perproc-create-proc in this-procedure (
                                                 input  this-procedure
                                                ,input  "trg/lock-dcp.p"
                                                ,input  v-proc-handle
                                                ,input  no
                                                ,input  "":u
                                                ,input v-cntxt-userid
                                                ,input 0 /*p-rank-to-delete*/
                                                ,output v-id) .
  end.
end.
CASE ref-mode:
  WHEN {&UPDATE} or
  when {&lookup}
  THEN DO:
    if not v-update-property then do:
      FOR EACH buf_dis-card-property no-lock where
      buf_dis-card-property.d-card =  temp-dis-card.d-card :
      if buf_dis-card-property.dt-code = 0 then next.
        CREATE tt0-dis-card-property.
        BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
      END.
    end.
  END.
  WHEN {&ADD-def} THEN DO:
    /*может быть только для копировании или перевыпуске*/
    if not v-update-property then do:
      FOR EACH buf_dis-card-property no-lock where
            buf_dis-card-property.d-card = (if v-is-copy
                                        then ub.dis-card.d-card
                                        else (if v-is-sourced
                                              then sourced_dis-card.d-card
                                              else main_dis-card.d-card))
                                              :
      if buf_dis-card-property.dt-code = 0 then next.
        run discprop-node-code in this-procedure (
                                            input buf_dis-card-property.dtm-code
                                           ,input buf_dis-card-property.dt-code
                                          ,output v-data-type
                                          ,output v-format
                                          ,output v-label
                                          ,output v-range
                                          ,output v-rw-option
                                          ).
        if error-status:error or lookup("C", v-rw-option) = 0  then next.
        assign
        v-found-copy-prop = yes.
        CREATE tt0-dis-card-property.
        BUFFER-COPY buf_dis-card-property EXCEPT d-card TO tt0-dis-card-property.
      end.
    END.
  END.
END CASE.
for each tt0-dis-card-property :
  assign
  tt0-dis-card-property.d-card            = temp-dis-card.d-card
  .
end.
run ref/discprpi.w (
                input parparentproc
              ,input ref-mode
              ,input temp-dis-card.d-card
              ,input temp-dis-card.emitent-host-code
              ,input temp-dis-card.type
              ,input parhost-code
              ,input parobj-type
              ,input parobj-code
              ,input no /*instant-update*/
              ,output v-updated-now
              ,input-output table tt0-dis-card-property
                ) no-error.
if error-status:error then do:
  return no-apply.
end.
ASSIGN
v-update-property = v-update-property OR v-updated-now
.
if v-update-property then do:
end.
else do:
  for each tt0-dis-card-property:
    delete tt0-dis-card-property.
  end.
end.

end.
end procedure. /* proc-b-prop */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-scard Dialog-Frame
PROCEDURE proc-b-scard :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable cli-list as character no-undo.
define buffer source_dis-card for ub.dis-card.
run ref/discards.w (
                     input parparentproc
                   ,input  "b-sel"
                   ,input  "client":U
                   ,input parhost-code
                   ,input parobj-type
                   ,input parobj-code
                   ,input '':U
                   ,input recid(ub.clients)
                   ,output cli-list ) .

if cli-list = "":U then return.
FIND FIRST source_dis-card no-lock where
                  recid(source_dis-card) = integer(cli-list).
if NOT
(    source_dis-card.cli-type = clients.obj-type and source_dis-card.cli-code = clients.obj-code) then do:
    message "Надо выбрать карту того же клиента"
    view-as alert-box error.
    return error.
end.
IF not (source_dis-card.emitent-host-code = paremitent-host-code) then do:
    message "Надо выбрать карту того же эмиттента"
    view-as alert-box error.
    return error.
end.
DISPLAY
source_dis-card.d-card @ temp-dis-card.sourced-card
with frame {&frame-name}.
message
"Скопировать в новую карту параметры старой карты"
view-as alert-box QUESTION buttons YES-NO
update loc#log.
if loc#log then do:
  FIND FIRST ub.dis-card-type No-LOCK WHERE
                      ub.dis-card-type.type = source_dis-card.type AND
                      ub.dis-card-type.emitent-host-code = source_dis-card.emitent-host-code No-ERROR.
    if not available ub.dis-card-tYpe then do:
        message "Не найден тип дисконтной карты для карты" source_dis-card.d-card
        view-as alert-box error.
        return error.
    end.
    assign
    v-pcnt-method = string(source_dis-card.d-pcnt-method)
    .
    display
    dis-card-type.type @ temp-dis-card.type
    source_dis-card.d-pcnt @ temp-dis-card.d-pcnt
    source_dis-card.cash-d-pcnt @ temp-dis-card.cash-d-pcnt
    source_dis-card.category @ temp-dis-card.category
    v-pcnt-method
    with frame {&frame-name}.
    temp-dis-card.credit-card:screen-value = string(dis-card-type.dflt-credit-card).
    run enable-lim-kr in this-procedure .
    if temp-dis-card.lim-kr:sensitive in frame {&frame-name} then
    display
    source_dis-card.lim-kr @ temp-dis-card.lim-kr
    with frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type Dialog-Frame
PROCEDURE proc-b-type :
define variable v-rid-list as character no-undo.
define buffer b_clients for ub.clients.
DEFINE VARIABLE from-card as decimal no-undo.
DEFINE VARIABLE for-old as decimal no-undo .
DEFINE VARIABLE for-new as decimal no-undo .
DEFINE VARIABLE for-sum as decimal no-undo .
define variable choice as integer.
define variable v-ok as logical no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .

define variable old-emitent-name as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_temp-tables for temp-tables.

main-block:
do
on error undo, return error
:
  if avail temp-dis-card then do:
    FIND FIRST buf_dis-card-type NO-LOCK WHERE
              buf_dis-card-type.emitent-host-code = temp-dis-card.emitent-host-code AND
              buf_dis-card-type.host-code = 0 AND
              buf_dis-card-type.obj-type = "":U AND
              buf_dis-card-type.obj-code = 0 AND
              buf_dis-card-type.type = temp-dis-card.type No-ERROR.
    if not avail buf_dis-card-type then do:
    end.
    v-rid-list = string(recid(buf_dis-card-type)).
  end.
  if NOT V-IS-DCT-CLIENT then do:
    run ref/dc-types.w (
                     input parparentproc
                    ,input (if paremitent-host-code = 0 then {&all} else {&company})
                    ,input "b-sel":U
                    ,input paremitent-host-code
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input-output v-rid-list) .
    if v-rid-list = ""
    or (available buf_dis-card-type and v-rid-list = string(recid(buf_dis-card-type)))
    then return no-apply.
    find first buf_dis-card-type no-lock where
              recid(buf_dis-card-type) = integer(v-rid-list) No-ERROR.
    if not avail buf_dis-card-type then return no-apply.
  end.
  old-emitent-name = emitent-name.
  if buf_dis-card-type.emitent-host-code = 0 then do:
    emitent-name = "Глобальная".
  end.
  else do:
    find first b_clients No-LOCK WHERE
                b_clients.obj-type = {&cmp} and
                b_clients.obj-code = buf_dis-card-type.emitent-host-code No-ERROR.
    if not avail buf_dis-card-type then return no-apply.
      emitent-name = b_clients.obj-name.
  end.
  display
  buf_dis-card-type.type @ temp-dis-card.type
  buf_dis-card-type.emitent-host-code @ temp-dis-card.emitent-host-code
  emitent-name
  with frame {&frame-name}
  .
  if ref-mode = {&add-def} then do:
      assign
      v-pcnt-method = string(buf_dis-card-type.dflt-d-pcnt-method)
      .
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-pcnt}
        v-d-pcnt
      }
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-cash-pcnt}
        v-cash-d-pcnt
      }
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.

      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-categ}
        v-categ
      }
      if v-categ = ? then do:
        v-categ = 0.
      end.
      display
      v-d-pcnt @ temp-dis-card.d-pcnt
      v-cash-d-pcnt @ temp-dis-card.cash-d-pcnt
      v-categ @ temp-dis-card.category
      v-pcnt-method
      with frame {&frame-name}.
      ASSIGN
      temp-dis-card.credit-card:screen-value = string(buf_dis-card-type.dflt-credit-card)
      temp-dis-card.debet-card:SCREEN-VALUE  = string(buf_dis-card-type.dflt-debet-card)
      temp-dis-card.staff-card:SCREEN-VALUE  = string(buf_dis-card-type.dflt-staff-card)
      .
      run enable-lim-kr in this-procedure .
      if temp-dis-card.lim-kr:sensitive in frame {&frame-name} then
      display
      buf_dis-card-type.lim-kr @ temp-dis-card.lim-kr
      with frame {&frame-name}.

  end.
  if ref-mode = {&update} then do:
    /*todo*/
    assign
    temp-dis-card.type = v-initial-type
    temp-dis-card.emitent-host-code = v-initial-emitent-host-code
    .
    run str/saledc.p
      (
       input parparentproc
      ,input this-procedure :handle
      ,input ? /*p-log-handle*/
      ,input {&dct-proc_one-card-check}
      ,input buf_dis-card-type.emitent-host-code
      ,input buf_dis-card-type.type
      ,input 0 /*p-profile-id*/
      ,input 0 /*p-codex-id*/
      ,input 0 /*p-ruleset-id*/
      ,input g#db-num
      ,input temp-dis-card.d-card
      ,input ? /*doc-date - выставим внутри*/
      ,input ? /*fact-date - выставим внутри*/
      ,input ? /*cre-pay*/
      ,input 1 /*p-sign*/
      ,input 1 /* p-direction */
      ,input no /*p-save*/
      ) no-error .
    if error-status:error then do:
      display
      temp-dis-card.type
      temp-dis-card.emitent-host-code
      emitent-name
      with frame {&frame-name}
      .
      undo main-block, return error return-value .
    end.
    find first buf_temp-tables where buf_temp-tables.tbl-name = {&table_dis-card} no-error.
    if available buf_temp-tables then do:
      run ref/view-chg.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input {&table_dis-card}
                    ,input buffer temp-dis-card:handle
                    ,input buf_temp-tables.new-tbl-handle
                    ,input {&update} + {&comma-char} + "available"
                    ,input 0 /*p-limit-access*/
                    ,input substitute("Изменения в реквизитах карты, вызванные изменением типа карты &1"
                                      , temp-dis-card.d-card) /*p-title*/
                    ,input "Текущие реквизиты карты"
                    ,input "Согласно новому типу карты должно быть"
                    ,input '':U /*на будущее - 3 -я колонка*/
                    ,input substitute("Вы можете подтвердить или отвергнуть изменения,&1" +
                                      "однако после следующей операции пересчета&1" +
                                      "реквизиты карты будут изменены в соответствии с правилами,&1" +
                                      "установленными для ее текущего типа, если только карта не будет находится в статусе &2"
                                      , {&new-line}
                                      , {&blocked-status}
                                      ) /*p-descr*/
                    ,output v-ok
                    ) no-error .
      if error-status:error then do:
        display
        temp-dis-card.type
        temp-dis-card.emitent-host-code
        emitent-name
        with frame {&frame-name}
        .
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error.
        undo, return error .
      end.
      if v-ok then do:
        for each temp-labels where temp-labels.f_update :
          if temp-labels.f_update then
          assign
          buffer temp-dis-card:handle:buffer-field(temp-labels.f_name):buffer-value = buf_temp-tables.new-tbl-handle:buffer-field(temp-labels.f_name):buffer-value
          .
        end.
        DISPLAY
        temp-dis-card.d-pcnt
        temp-dis-card.cash-d-pcnt
        temp-dis-card.category
        temp-dis-card.issue-date
        temp-dis-card.issue-code
        temp-dis-card.lim-kr
        (IF temp-dis-card.cli-message = ? THEN "":U ELSE temp-dis-card.cli-message) temp-dis-card.cli-message
        temp-dis-card.valid-date
        temp-dis-card.valid-from
        WITH FRAME {&FRAME-NAME}.
      end.
    end. /*if available buf_temp-tables then do:*/
    for each buf_temp-tables:
      if valid-handle(buf_temp-tables.new-table-handle) then do:
        delete object buf_temp-tables.new-table-handle.
      end.
      delete buf_temp-tables.
    end.
  end. /*update*/
  assign
  temp-dis-card.type = buf_dis-card-type.type
  temp-dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
  .
  if buf_dis-card-type.type = {&dct-client} then do:
&scop dct-client-obj-type temp-DIs-card.cli-type
&scop dct-client-obj-code temp-dis-card.cli-code
    disable
    t-overissue when t-overissue:sensitive
    temp-dis-card.d-card
    with frame {&frame-name}.
    DISPLAY
    {&dct-client-card-no} @ TEMP-DIS-CARD.D-CARD
    with frame {&frame-name}.
  end.
  ELSE DO:
    if input temp-dis-card.d-card = {&dct-client-card-no} then do:
      temp-dis-card.d-card:screen-value = ''.
    end.
  END.
end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable choice as integer no-undo .
define variable glog as logical no-undo .
define variable v-can-issue as logical no-undo .
define variable v-data-type as character no-undo . /*тип атрибута*/
define variable v-format as character no-undo .  /* формат атрибута*/
define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .  /*пользователь может изменять в броусе*/
define buffer source_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_attr-prop for ub.attr-prop.
assign
frame {&frame-name}
temp-dis-card.type
temp-dis-card.d-card
.

if ref-mode = {&add-def}
and not v-update-property then do:
  FOR EACH buf_dis-card-property no-lock where
        buf_dis-card-property.d-card = (if v-is-copy
                                    then ub.dis-card.d-card
                                    else (if v-is-sourced
                                          then sourced_dis-card.d-card
                                          else main_dis-card.d-card)):
    if buf_dis-card-property.dtm-code = 0 then next.
    if discprop-usercanedit( input buf_dis-card-property.dtm-code, input g#db-num) = no then next.
    run discprop-node-code in this-procedure (
                                        input buf_dis-card-property.dtm-code
                                        ,input buf_dis-card-property.dt-code
                                      ,output v-data-type
                                      ,output v-format
                                      ,output v-label
                                      ,output v-range
                                      ,output v-rw-option
                                      ).
    if error-status:error or lookup("C", v-rw-option) = 0  then next.
    assign
    v-found-copy-prop = yes.
    CREATE tt0-dis-card-property.
    BUFFER-COPY buf_dis-card-property to tt0-dis-card-property
    assign
    tt0-dis-card-property.d-card = d-card
    tt0-dis-card-property.main-card = temp-dis-card.main-card
    tt0-dis-card-property.first-card = temp-dis-card.first-card
    tt0-dis-card-property.first-main-card = temp-dis-card.first-main-card
    tt0-dis-card-property.card-num = temp-dis-card.card-num
    .
  end.
END.


if (v-is-sourced or v-is-copy or v-is-subsid) and v-found-copy-prop then v-update-property = yes.
if v-update-property then do:
  run gbl/d-askw.w (
                    input "Сохранение изменений"
                    ,input  "Были изменены свойств ДК" + (if v-found-copy-prop then " или наследуются свойства ДК" else "":U)
                    ,input "|"
                    ,input "Сохранить ВСЕ|Кроме свойств|Отмена"
                    ,input "Сохранить изменения ДК и изменения свойств ДК|Сохранить изменения ДК|Ничего не сохранять"
                    ,input 1
                    ,input 3
                    ,output choice).
  if choice = 2 then v-update-property = no.
  if choice = 3 then return.
end.
IF ref-mode = {&LOOKUP} THEN RETURN .
find first temp-dis-card  no-error.
if not avail temp-dis-card then do:
  create temp-dis-card.
  assign
  frame {&frame-name} v-pcnt-method
  temp-dis-card.cli-type = ub.clients.obj-type
  temp-dis-card.cli-code = ub.clients.obj-code
  temp-dis-card.d-card
  temp-dis-card.emitent-host-code
  temp-dis-card.status_ = {&current-status}
  temp-dis-card.d-pcnt-method = integer(v-pcnt-method)
  .
end.
assign
temp-dis-card.type
temp-dis-card.d-card
temp-dis-card.emitent-host-code
temp-dis-card.d-pcnt
temp-dis-card.cash-d-pcnt
temp-dis-card.category
temp-dis-card.credit-card
temp-dis-card.lim-kr
temp-dis-card.debet-card
temp-dis-card.staff-card
temp-dis-card.cli-message
temp-dis-card.issue-date
temp-dis-card.issue-code
temp-dis-card.valid-from
temp-dis-card.valid-date
v-pcnt-method
temp-dis-card.d-pcnt-method = integer(v-pcnt-method)
t-overissue
.
if temp-dis-card.type = '':U then do:
  message
  "Не выбран тип ДК"
  view-as alert-box error .
  undo, return error '':U.
end.
if ref-mode = {&add-def} and t-overissue then
assign
temp-dis-card.sourced-card
.
if ref-mode = {&add-def} and temp-dis-card.sourced-card <> "":U then do:
  find first source_dis-card no-lock where
            source_dis-card.d-card = temp-dis-card.sourced-card no-error .
  if available source_dis-card then do:
    if source_dis-card.type <> temp-dis-card.type then do:
      message
      substitute("У перевыпускаемой карты &1 - тип &2, а у карты &3, к которой перевыпускается карта &1 - тип &4&5" +
                "Вы уверены, что хотите перевыпустить карту с другим типом?"
                , temp-dis-card.d-card
                , temp-dis-card.type
                , source_Dis-card.d-card
                , source_dis-card.type
                ,{&new-line}
                )
      view-as alert-box question buttons yes-no update glog.
      if not glog then undo, return error .
    end.
    if source_dis-card.status_ = {&deleted-status} then do:
      message
      substitute("Карта &2, к которой перевыпускается карта &1 - имеет статус &3&4" +
                "Вы уверены, что хотите перевыпустить карту к удаленной карте?"
                , temp-dis-card.d-card
                , source_Dis-card.d-card
                , source_Dis-card.status_
                ,{&new-line}
                )
      view-as alert-box question buttons yes-no update glog.
      if not glog then undo, return error .

    end.
  end.
end.

if ref-mode = {&add-def}
then do:
   run ref/dcardi04.p (
                  input temp-dis-card.d-card
                 ,input temp-dis-card.type
                 ,input temp-dis-card.emitent-host-code
                 ,input temp-dis-card.issue-code
                 ,output v-can-issue) no-error .
   if error-status:error
   or not v-can-issue  then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
   end.
end.

for each tt0-dis-card-property :
  assign
  tt0-dis-card-property.d-card            = temp-dis-card.d-card
  .
end.

DO ON ERROR UNDO, RETURN ERROR:
  run ref/dcardi01.p (
                   input parparentproc
                  ,input this-procedure
                  ,input ?
                  ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                  ,input no /*p-silent*/
                  ,input-output dc-ri
                  ,input ref-mode
                  ,input '':U /*par-mode2*/
                  ,input parobj-type
                  ,input parobj-code
                  ,input temp-dis-card.d-card
                  ,input temp-dis-card.emitent-host-code
                  ,input temp-dis-card.cli-type
                  ,input temp-dis-card.cli-code
                  ,input (if ref-mode = {&add-def} then {&current-status} else temp-dis-card.status_)
                  ,input temp-dis-card.type
                  ,input temp-dis-card.d-pcnt
                  ,input temp-dis-card.cash-d-pcnt
                  ,input temp-dis-card.category
                  ,input temp-dis-card.d-pcnt-method
                  ,input temp-dis-card.credit-card
                  ,input temp-dis-card.lim-kr
                  ,input temp-dis-card.debet-card
                  ,input temp-dis-card.staff-card
                  ,input temp-dis-card.issue-date
                  ,input temp-dis-card.issue-code
                  ,input temp-dis-card.valid-from
                  ,input temp-dis-card.valid-date
                  ,input temp-dis-card.sourced-card
                  ,input temp-dis-card.cli-message
                  ,input temp-dis-card.mask-card
                  ,input (if v-is-subsid
                          or ref-mode = {&update}
                          then temp-dis-card.main-card
                          else temp-dis-card.d-card)
                  ,input temp-dis-card.is-subsid
                  ,INPUT v-update-property
                  ,INPUT table tt0-dis-card-property
                  ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
END. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME