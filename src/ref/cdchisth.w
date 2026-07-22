&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-dc-hist FOR c-dc-hist.
DEFINE BUFFER X_c-dc-hist FOR c-dc-hist.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER x_dis-card FOR dis-card.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*контекст сессии*/
/*define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.*/
/*define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.  */
/*define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.  */

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} {&company} "one":U ""card-num" subject":U "subject-object":U*/
define input parameter p-d-card   like ub.c-dc-hist.d-card no-undo .
define input parameter p-card-num like ub.dis-card.card-num no-undo .
/*define input parameter p-obj-type like ub.c-dc-hist.obj-type no-undo.  */
/*define input parameter p-obj-code like ub.c-dc-hist.obj-code no-undo.  */
/*define input parameter p-host-code like ub.c-dc-hist.host-code no-undo.*/
define input parameter p-corr-user-db-num  like ub.c-dc-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-dc-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-dc-hist.subject no-undo .
/*стартуем с текущей БД обычно*/
define input parameter p-db-num  like ub.c-dc-hist.corr-user-db-num no-undo .

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории ДК":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
define variable filter-point as character no-undo init "cdchist" .
define variable filter-point0 as character no-undo init "cdchist" .
define variable filter-label as character no-undo init "Список полной истории ДК" .
define variable filter-label0 as character no-undo init "Список полной истории ДК" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-cli as character no-undo .
define variable v-cli-name like ub.clients.obj-name no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
{ gbl/fltopend.i defproc }
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.
define buffer x_clients-sysconf for ub.clients.
define buffer x_clients-obj for ub.clients.

{ ref/tmpchgs.i "NEW SHARED"}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-dc-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-dc-hist                                    */
&Scoped-define FIELDS-IN-QUERY-br-dc-hist mark-string(recid(X_c-dc-hist), v-rid-list) X_c-dc-hist.corr-date usrfulnf(X_c-dc-hist.corr-user-name) string(X_c-dc-hist.corr-time, "HH:MM:SS":U) X_c-dc-hist.corr-user-db-num X_c-dc-hist.is-news get-action(X_c-dc-hist.action) X_c-dc-hist.source-ref X_c-dc-hist.host-code X_c-dc-hist.d-card get-source-type(X_c-dc-hist.source-type) if v-find then get-cli(X_c-dc-hist.d-card) else "":U v-cli-name get-subject(X_c-dc-hist.subject) X_c-dc-hist.obj-type + string(X_c-dc-hist.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dc-hist X_c-dc-hist.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-br-dc-hist X_c-dc-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-dc-hist X_c-dc-hist
&Scoped-define SELF-NAME br-dc-hist
&Scoped-define QUERY-STRING-br-dc-hist FOR EACH X_c-dc-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dc-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-dc-hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dc-hist X_c-dc-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-dc-hist X_c-dc-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
B-lookup B-print B-sch B-Help br-dc-hist sch-db-num sch-corr-date ~
sch-d-card sch-corr-user-name BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num sch-db-num ~
sch-corr-date sch-d-card sch-corr-user-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli Dialog-Frame
FUNCTION get-cli RETURNS CHARACTER
  ( p-d-card as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-source-type Dialog-Frame
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Дкарта"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате изменения"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-d-card AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-db-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "по БД"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-dc-hist FOR
      X_c-dc-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.

DEFINE BROWSE br-dc-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dc-hist Dialog-Frame _FREEFORM
  QUERY br-dc-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-dc-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-dc-hist.corr-date FORMAT "99/99/9999":U
      usrfulnf(X_c-dc-hist.corr-user-name) FORMAT "X(18)":U
      string(X_c-dc-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      X_c-dc-hist.corr-user-db-num FORMAT ">>>>9":U
      X_c-dc-hist.is-news FORMAT "+/":U
      get-action(X_c-dc-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-dc-hist.source-ref FORMAT "X(255)":U WIDTH 15
      X_c-dc-hist.host-code COLUMN-LABEL "Фирма" FORMAT "99999":U
      X_c-dc-hist.d-card COLUMN-LABEL "Дкарта" FORMAT "X(19)":U
      get-source-type(X_c-dc-hist.source-type) COLUMN-LABEL "Источн.!измен."
      if v-find then get-cli(X_c-dc-hist.d-card) else "":U COLUMN-LABEL "Влад-ц карты" FORMAT "X(12)":U
      v-cli-name COLUMN-LABEL "Имя влад-ца карты" FORMAT "X(20)":U
      get-subject(X_c-dc-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      X_c-dc-hist.obj-type + string(X_c-dc-hist.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
  ENABLE
      X_c-dc-hist.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     B-lookup AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-dc-hist AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-d-card AT ROW 13.67 COL 48.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная история по ДК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-dc-hist B "?" NO-UNDO ub c-dc-hist
      TABLE: X_c-dc-hist B "?" ? ub c-dc-hist
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_db B "?" ? ub db
      TABLE: x_dis-card B "?" ? ub dis-card
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dc-hist B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-dc-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dc-hist
/* Query rebuild information for BROWSE br-dc-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-dc-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-dc-hist */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по ДК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME B-lookup                              */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame*/
/*ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Дкарта */       */
/*DO:                                                            */
/*define variable v-ri as recid no-undo .                        */
/*define buffer buf_dis-card for ub.dis-card.                    */
/*find first buf_dis-card no-lock where                          */
/*           buf_dis-card.d-card = X_c-dc-hist.d-card no-error . */
/*if avail buf_dis-card then do:                                 */
/*  assign                                                       */
/*  v-ri = recid( buf_dis-card )                                 */
/* .                                                             */
/*  run ref/dcardi.w (                                           */
/*                input parparentproc                            */
/*              , input {&lookup}                                */
/*              , input buf_dis-card.emitent-host-code           */
/*              , input p-curr-host-code                         */
/*              , input p-curr-obj-type                          */
/*              , input p-curr-obj-code                          */
/*              , input ?                                        */
/*              , input-output v-ri ) .                          */
/*                                                               */
/*end.                                                           */
/*END.                                                           */
/*                                                               */
/*/* _UIB-CODE-BLOCK-END */                                      */
/*&ANALYZE-RESUME                                                */


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-dc-hist then do:
    { gbl/markstrn.i X_c-dc-hist v-rid-list }
    loc#log = br-dc-hist:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dc-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-dc-hist in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-dc-hist in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-dc-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-dc-hist ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dc-hist
&Scoped-define SELF-NAME br-dc-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dc-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-dc-hist IN FRAME Dialog-Frame
DO:
   run proc-br-dc-hist in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dc-hist Dialog-Frame
ON RETURN OF br-dc-hist IN FRAME Dialog-Frame
DO:
  run proc-br-dc-hist in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dc-hist Dialog-Frame
ON VALUE-CHANGED OF br-dc-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame /* Дате изменения */
DO:
   run proc-find-corr-date in this-procedure ( yes, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame /* Дате изменения */
DO:
  run proc-find-corr-date in this-procedure ( no, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-user-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON CTRL-J OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure ( yes, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON RETURN OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure ( no, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-d-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-d-card Dialog-Frame
ON CTRL-J OF sch-d-card IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-d-card in this-procedure ( yes, input frame {&frame-name} sch-d-card) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-d-card Dialog-Frame
ON RETURN OF sch-d-card IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-d-card in this-procedure ( no, input frame {&frame-name} sch-d-card) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-db-num Dialog-Frame
ON CTRL-J OF sch-db-num IN FRAME Dialog-Frame /* БД */
DO:
  run proc-find-db-num in this-procedure ( yes, input frame {&frame-name} sch-db-num) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-db-num Dialog-Frame
ON RETURN OF sch-db-num IN FRAME Dialog-Frame /* БД */
DO:
  run proc-find-db-num in this-procedure ( no, input frame {&frame-name} sch-db-num) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-corr-user-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-corr-user-db-num Dialog-Frame
ON RETURN OF v-corr-user-db-num IN FRAME Dialog-Frame /* по БД */
DO:
  assign
  v-corr-user-db-num
  .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-dc-hist" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-dc-hist"). run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num). ~
             reposition br-dc-hist to recid v-doc-rec no-error. ~
             apply 'value-changed' to br-dc-hist. "  }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-dc-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-dc-hist"
  &sort-clmn_1    = "X_c-dc-hist.corr-date"
  &sort-clmn_2    = "X_c-dc-hist.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure  ( input yes, input no, input no, input v-corr-user-db-num)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if p-mode <> {&all}
 and p-mode <> {&company}
 and p-mode <> "one":U
 and p-mode <> "subject":U
 and p-mode <> "subject-object":U
 and p-mode <> "card-num":U
 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
/*
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code no-error.
if not available X_curr_sysconf then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-curr-host-code"
  p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
*/
/* if p-mode = {&company} then do:                                  */
/*  find first x_clients-sysconf no-lock where                      */
/*                x_clients-sysconf.obj-type = {&cmp}               */
/*            and x_clients-sysconf.obj-code = p-host-code no-error.*/
/*    if not available x_clients-sysconf then do:                   */
/*        message                                                   */
/*        vss-workfile vss-revision vss-description skip            */
/*        "Неверное значение параметра вызова p-host-code"          */
/*        p-curr-host-code                                          */
/*        view-as alert-box ERROR.                                  */
/*        return.                                                   */
/*    end.                                                          */
/*    find first X_sysconf no-lock where                            */
/*                    X_sysconf.host-code = p-host-code no-error.   */
/*    if not available X_sysconf then do:                           */
/*      message                                                     */
/*      vss-workfile vss-revision vss-description skip              */
/*      "Неверное значение параметра вызова p-host-code"            */
/*      p-host-code                                                 */
/*      view-as alert-box ERROR.                                    */
/*      return.                                                     */
/*    end.                                                          */
/*  end.                                                            */
/*                                                                  */
/* if p-mode = {&g___object} then do:                               */
/*  find first x_clients-obj no-lock where                          */
/*                x_clients-obj.obj-type = p-obj-type               */
/*            and x_clients-obj.obj-code = p-obj-code no-error.     */
/*    if not available x_clients-obj then do:                       */
/*        message                                                   */
/*        vss-workfile vss-revision vss-description skip            */
/*        "Неверное значение параметра вызова p-obj-type/p-obj-code"*/
/*        p-obj-type p-obj-code                                     */
/*        view-as alert-box ERROR.                                  */
/*        return.                                                   */
/*    end.                                                          */
/* end.                                                             */

 if p-mode = "one":U then do:
  find first x_dis-card no-lock where
                x_dis-card.d-card = p-d-card  no-error.
    if not available x_dis-card then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-d-card" p-d-card
        view-as alert-box ERROR.
        return.
    end.
  end.
/* if p-mode = "card-num":U then do:                                */
/*  find first x_dis-card no-lock where                             */
/*                x_dis-card.card-num = p-card-num  no-error.       */
/*    if not available x_dis-card then do:                          */
/*        message                                                   */
/*        vss-workfile vss-revision vss-description skip            */
/*        "Неверное значение параметра вызова p-card-num" p-card-num*/
/*        view-as alert-box ERROR.                                  */
/*        return.                                                   */
/*    end.                                                          */
/*  end.                                                            */

/* if p-mode = "db-num":U then do:                                                  */
/*  find first X_db no-lock where                                                   */
/*                X_db.db-num = p-corr-user-db-num no-error.                        */
/*    if not available X_db then do:                                                */
/*        message                                                                   */
/*        vss-workfile vss-revision vss-description skip                            */
/*        "Неверное значение параметра вызова p-corr-user-db-num" p-corr-user-db-num*/
/*        view-as alert-box ERROR.                                                  */
/*        return.                                                                   */
/*    end.                                                                          */
/*  end.                                                                            */
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-dc-hist No-LOCK where
                 recid(find_c-dc-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-dc-hist then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  if p-mode <> {&all} then do:
    assign
    v-find = yes.
    end.
    else do:
    assign
    v-cli = get-cli(p-d-card)
    .
  end.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-dc-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-dc-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 14
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,11,14,9,12,13,10'"
    &prev-order-column-condition_2 = " p-mode <> {&all} "
    }
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .
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
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-d-card
          sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num B-print B-sch B-Help
         br-dc-hist sch-db-num sch-corr-date sch-d-card sch-corr-user-name
         BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
br-dc-hist:num-locked-columns in frame {&frame-name} = 1
X_c-dc-hist.source-ref:resizable in browse br-dc-hist = yes
X_c-dc-hist.corr-date:read-only in browse br-dc-hist = yes
br-changes:title = "":U
v-corr-user-db-num = v-db-num
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY
v-db-num @ v-corr-user-db-num
sch-db-num
sch-corr-date
sch-d-card
sch-corr-user-name
mark-num
WITH FRAME {&frame-name}.
ENABLE
v-corr-user-db-num
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
B-sch
B-Print
B-Help
br-dc-hist
sch-corr-date
sch-corr-user-name
sch-d-card when p-mode = {&all}
sch-db-num when p-mode = {&all}
BR-changes mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE sch-corr-user-name IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-db-num like ub.c-dc-hist.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной истории ДК" + {&space-char}.
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dc-hist FOR EACH X_c-dc-hist

&scop flt-open-open-query-tail

&scop flt-open-dyn_open-query  FOR EACH X_c-dc-hist

&scop flt-open-query-handle query br-dc-hist:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-dc-hist

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-dc-hist

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-db-num:
  when ? then do:
    CASE p-mode :
/*      WHEN {&all}        THEN DO:                                                                                                         */
/*      assign                                                                                                                              */
/*      filter-point = filter-point0 + p-mode                                                                                               */
/*      filter-label = filter-label0                                                                                                        */
/*      .                                                                                                                                   */
/*      { gbl/fltopend.i                                                                                                                    */
/*          &where-cond = " TRUE "                                                                                                          */
/*          &use-ind    = " use-index idate "                                                                                               */
/*          &by         = "  " }                                                                                                            */
/*      END.                                                                                                                                */
/*      WHEN {&company} THEN DO:                                                                                                            */
/*        assign                                                                                                                            */
/*        filter-point = filter-point0 + p-mode                                                                                             */
/*        filter-label = substitute("&1: Фирма", filter-label0)                                                                             */
/*        .                                                                                                                                 */
/*        if p-open-query then do:                                                                                                          */
/*          ASSIGN                                                                                                                          */
/*          frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2 Фирма: (&3) &4",                                                */
/*                                                            p-d-card, v-cli-name, p-host-code, x_clients-sysconf.obj-name).               */
/*        end.                                                                                                                              */
/*        { gbl/fltopend.i                                                                                                                  */
/*          &where-cond = " ~                                                                                                               */
/*          X_c-dc-hist.d-card  = p-d-card AND ~                                                                                            */
/*          (X_c-dc-hist.host-code  = p-host-code  or X_c-dc-hist.host-code = 0) ~                                                          */
/*                        "                                                                                                                 */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.d-card  = &1&2&1 AND ~                                                             */
/*          (X_c-dc-hist.host-code  = &3  or X_c-dc-hist.host-code = 0)', ~{&double-quote~}, p-d-card, p-host-code ) "                      */
/*                                                                                                                                          */
/*          &use-ind    = " use-index idate "                                                                                               */
/*          &by         = "  " }                                                                                                            */
/*      END.                                                                                                                                */
/*      WHEN {&g___object} THEN DO:                                                                                                         */
/*        assign                                                                                                                            */
/*        filter-point = filter-point0 + p-mode                                                                                             */
/*        filter-label = substitute("&1: Объект", filter-label0)                                                                            */
/*        .                                                                                                                                 */
/*        if p-open-query then do:                                                                                                          */
/*          ASSIGN                                                                                                                          */
/*          frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2 Объект: &3&4",                                                  */
/*                                                            p-d-card, v-cli-name, p-obj-type , p-obj-code).                               */
/*        end.                                                                                                                              */
/*        { gbl/fltopend.i                                                                                                                  */
/*          &where-cond = " ~                                                                                                               */
/*          X_c-dc-hist.d-card  = p-d-card AND ~                                                                                            */
/*          X_c-dc-hist.obj-type  = p-obj-type AND ~                                                                                        */
/*          X_c-dc-hist.obj-code  = p-obj-code AND ~                                                                                        */
/*          (X_c-dc-hist.host-code  = p-host-code  or X_c-dc-hist.host-code = 0) ~                                                          */
/*                        "                                                                                                                 */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.d-card  = &1&2&1 AND ~                                                             */
/*          X_c-dc-hist.obj-type  = &1&3&1 AND ~                                                                                            */
/*          X_c-dc-hist.obj-code  = &4 AND ~                                                                                                */
/*          (X_c-dc-hist.host-code  = &5 or X_c-dc-hist.host-code = 0)', ~{&double-quote~}, p-d-card, p-obj-type, p-obj-code, p-host-code) "*/
/*                                                                                                                                          */
/*          &use-ind    = " use-index ishow "                                                                                               */
/*          &by         = "  " }                                                                                                            */
/*      END.                                                                                                                                */

      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Карта", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2",
                                                                p-d-card, v-cli-name ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-dc-hist.d-card  = p-d-card  ~
                        "
          &dyn_where-cond = " substitute(' X_c-dc-hist.d-card  = &1&2&1', ~{&double-quote~}, p-d-card)  "

          &use-ind    = " "
          &by         = "  " }
      END.
/*      WHEN "card-num":u THEN DO:                                                                                                                                     */
/*        assign                                                                                                                                                       */
/*        filter-point = filter-point0 + p-mode                                                                                                                        */
/*        filter-label = substitute("&1: Карта (с учетом перевыпуска)", filter-label0)                                                                                 */
/*        .                                                                                                                                                            */
/*        if p-open-query then do:                                                                                                                                     */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1 (с учетом перевыпуска): &2",                                                            */
/*                                                                    p-d-card, v-cli-name ).                                                                          */
/*        end.                                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                                             */
/*          &where-cond = " ~                                                                                                                                          */
/*          X_c-dc-hist.card-num  = p-card-num  ~                                                                                                                      */
/*                        "                                                                                                                                            */
/*          &dyn_where-cond = " substitute('  X_c-dc-hist.card-num  = &1', p-card-num) "                                                                               */
/*                                                                                                                                                                     */
/*          &use-ind    = "  "                                                                                                                                         */
/*          &by         = "  " }                                                                                                                                       */
/*      END.                                                                                                                                                           */
/*                                                                                                                                                                     */
/*      WHEN "subject":u THEN DO:                                                                                                                                      */
/*  &scop hn-dc-hist-code p-subject                                                                                                                                    */
/*        assign                                                                                                                                                       */
/*        filter-point = filter-point0 + p-mode                                                                                                                        */
/*        v-subject-chr = {&hn-dc-hist-name}                                                                                                                           */
/*        filter-label = substitute("&1: Предмет изменения", filter-label0)                                                                                            */
/*        .                                                                                                                                                            */
/*        if p-open-query then do:                                                                                                                                     */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2, Предмет изменения &3",                                                             */
/*                                                                p-d-card, v-cli-name, v-subject-chr ).                                                               */
/*        end.                                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                                             */
/*          &where-cond = " ~                                                                                                                                          */
/*          X_c-dc-hist.d-card  = p-d-card AND  ~                                                                                                                      */
/*          X_c-dc-hist.subject = p-subject AND ~                                                                                                                      */
/*          (p-host-code = ? or X_c-dc-hist.host-code = p-host-code) AND ~                                                                                             */
/*          (p-obj-code = 0 or (X_c-dc-hist.obj-type =  p-obj-type and X_c-dc-hist.obj-code = p-obj-code)) ~                                                           */
/*                        "                                                                                                                                            */
/*          &where-cond = " substitute('  X_c-dc-hist.d-card  = &1&2&1 AND  ~                                                                                          */
/*          X_c-dc-hist.subject = &1&3&1 AND ~                                                                                                                         */
/*          (&4 = ? or X_c-dc-hist.host-code = &4) AND ~                                                                                                               */
/*          (&5 = 0 or (X_c-dc-hist.obj-type =  &1&6&1 and X_c-dc-hist.obj-code = &5))', ~{&double-quote~}, p-d-card, p-subject, p-host-code, p-obj-code, p-obj-type) "*/
/*                                                                                                                                                                     */
/*          &use-ind    = "  "                                                                                                                                         */
/*          &by         = "  " }                                                                                                                                       */
/*      END.                                                                                                                                                           */
/*      WHEN "subject-object":u THEN DO:                                                                                                                               */
/*  &scop hn-dc-hist-code p-subject                                                                                                                                    */
/*        assign                                                                                                                                                       */
/*        filter-point = filter-point0 + p-mode                                                                                                                        */
/*        v-subject-chr = {&hn-dc-hist-name}                                                                                                                           */
/*        filter-label = substitute("&1: Предмет изменения по объекту", filter-label0)                                                                                 */
/*        .                                                                                                                                                            */
/*        if p-open-query then do:                                                                                                                                     */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2, Предмет изменения &3 Объект &4&5",                                                 */
/*                                                                p-d-card, v-cli-name, v-subject-chr, p-obj-type, p-obj-code ).                                       */
/*        end.                                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                                             */
/*          &where-cond = " ~                                                                                                                                          */
/*          X_c-dc-hist.d-card  = p-d-card AND  ~                                                                                                                      */
/*          X_c-dc-hist.subject = p-subject AND  ~                                                                                                                     */
/*          X_c-dc-hist.obj-type = p-obj-type AND  ~                                                                                                                   */
/*          X_c-dc-hist.obj-code = p-obj-code ~                                                                                                                        */
/*                        "                                                                                                                                            */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.d-card  = &1&2&1 AND  ~                                                                                       */
/*          X_c-dc-hist.subject = &1&3&1 AND  ~                                                                                                                        */
/*          X_c-dc-hist.obj-type = &1&4&1 AND  ~                                                                                                                       */
/*          X_c-dc-hist.obj-code = &5', ~{&double-quote~}, p-d-card, p-subject, p-obj-type, p-obj-code) "                                                              */
/*                                                                                                                                                                     */
/*          &use-ind    = " use-index ishow "                                                                                                                          */
/*          &by         = "  " }                                                                                                                                       */
/*      END.                                                                                                                                                           */
    END CASE.

  end.
  otherwise do:
    CASE p-mode :
/*      WHEN {&all}        THEN DO:                                                                                                                    */
/*      assign                                                                                                                                         */
/*      filter-point = filter-point0 + p-mode                                                                                                          */
/*      filter-label = substitute("&1", filter-label0)                                                                                                 */
/*      .                                                                                                                                              */
/*      { gbl/fltopend.i                                                                                                                               */
/*          &where-cond = " TRUE "                                                                                                                     */
/*          &use-ind    = "  use-index ishow "                                                                                                         */
/*          &by         = "  " }                                                                                                                       */
/*      END.                                                                                                                                           */
/*      WHEN {&company} THEN DO:                                                                                                                       */
/*        assign                                                                                                                                       */
/*        filter-point = filter-point0 + p-mode                                                                                                        */
/*        filter-label = substitute("&1: Фирма", filter-label0)                                                                                        */
/*        .                                                                                                                                            */
/*        if p-open-query then do:                                                                                                                     */
/*          ASSIGN                                                                                                                                     */
/*          frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2 Фирма: (&3) &4 БД: &5",                                                    */
/*                                                            p-d-card, v-cli-name, p-host-code, x_clients-sysconf.obj-name, p-db-num).                */
/*        end.                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                             */
/*          &where-cond = " ~                                                                                                                          */
/*          X_c-dc-hist.corr-user-db-num = p-db-num ANd  ~                                                                                             */
/*          X_c-dc-hist.d-card  = p-d-card AND ~                                                                                                       */
/*          (X_c-dc-hist.host-code  = p-host-code  or X_c-dc-hist.host-code = 0) ~                                                                     */
/*                        "                                                                                                                            */
/*          &where-cond = " substitute('  X_c-dc-hist.corr-user-db-num = &1 ANd  ~                                                                     */
/*          X_c-dc-hist.d-card  = &2&3&2 AND ~                                                                                                         */
/*          (X_c-dc-hist.host-code  = &4 or X_c-dc-hist.host-code = 0)', p-db-num, ~{&double-quote~}, p-d-card, p-host-code)  "                        */
/*                                                                                                                                                     */
/*          &use-ind    = " use-index ishow "                                                                                                          */
/*          &by         = "  " }                                                                                                                       */
/*      END.                                                                                                                                           */
/*      WHEN {&g___object} THEN DO:                                                                                                                    */
/*        assign                                                                                                                                       */
/*        filter-point = filter-point0 + p-mode                                                                                                        */
/*        filter-label = substitute("&1: Объект", filter-label0)                                                                                       */
/*        .                                                                                                                                            */
/*        if p-open-query then do:                                                                                                                     */
/*          ASSIGN                                                                                                                                     */
/*          frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2 Объект: &3&4 БД: &5",                                                      */
/*                                                            p-d-card, v-cli-name, p-obj-type , p-obj-code, p-db-num).                                */
/*        end.                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                             */
/*          &where-cond = " ~                                                                                                                          */
/*          X_c-dc-hist.corr-user-db-num = p-db-num ANd  ~                                                                                             */
/*          X_c-dc-hist.d-card  = p-d-card AND ~                                                                                                       */
/*          X_c-dc-hist.obj-type  = p-obj-type AND ~                                                                                                   */
/*          X_c-dc-hist.obj-code  = p-obj-code AND ~                                                                                                   */
/*          (X_c-dc-hist.host-code  = p-host-code  or X_c-dc-hist.host-code = 0) ~                                                                     */
/*                        "                                                                                                                            */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.corr-user-db-num = &1 ANd  ~                                                                  */
/*          X_c-dc-hist.d-card  = &2&3&2 AND ~                                                                                                         */
/*          X_c-dc-hist.obj-type  = &2&4&2 AND ~                                                                                                       */
/*          X_c-dc-hist.obj-code  = &5 AND ~                                                                                                           */
/*          (X_c-dc-hist.host-code  = &6  or X_c-dc-hist.host-code = 0)', p-db-num, ~{&double-quote~}, p-d-card, p-obj-type, p-obj-code, p-host-code) "*/
/*                                                                                                                                                     */
/*          &use-ind    = " use-index ishow "                                                                                                          */
/*          &by         = "  " }                                                                                                                       */
/*      END.                                                                                                                                           */

      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Карта", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2 БД: &3",
                                                                p-d-card, v-cli-name, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-dc-hist.corr-user-db-num = p-db-num ANd  ~
          X_c-dc-hist.d-card  = p-d-card  ~
                        "
          &dyn_where-cond = " substitute(' X_c-dc-hist.corr-user-db-num = &1 ANd  ~
          X_c-dc-hist.d-card  = &2&3&2', p-db-num , ~{&double-quote~}, p-d-card) "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
/*      WHEN "card-num":u THEN DO:                                                                                                        */
/*        assign                                                                                                                          */
/*        filter-point = filter-point0 + p-mode                                                                                           */
/*        filter-label = substitute("&1: Карта (с учетом перевыпуска)", filter-label0)                                                    */
/*        .                                                                                                                               */
/*        if p-open-query then do:                                                                                                        */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1 (с учетом перевыпуска): &2 БД: &3",                        */
/*                                                                    p-d-card, v-cli-name, p-db-num ).                                   */
/*        end.                                                                                                                            */
/*        { gbl/fltopend.i                                                                                                                */
/*          &where-cond = " ~                                                                                                             */
/*          X_c-dc-hist.corr-user-db-num = p-db-num ANd  ~                                                                                */
/*          X_c-dc-hist.card-num  = p-card-num  ~                                                                                         */
/*                        "                                                                                                               */
/*          &dyn_where-cond = " substitute('X_c-dc-hist.corr-user-db-num = &1 ANd  ~                                                      */
/*          X_c-dc-hist.card-num  = &2 ', p-db-num, p-card-num) "                                                                         */
/*                                                                                                                                        */
/*          &use-ind    = " use-index ishowc "                                                                                            */
/*          &by         = "  " }                                                                                                          */
/*      END.                                                                                                                              */
/*                                                                                                                                        */
/*      WHEN "subject":u THEN DO:                                                                                                         */
/*  &scop hn-dc-hist-code p-subject                                                                                                       */
/*        assign                                                                                                                          */
/*        filter-point = filter-point0 + p-mode                                                                                           */
/*        filter-label = substitute("&1: Предмет изменения", filter-label0)                                                               */
/*        v-subject-chr = {&hn-dc-hist-name}                                                                                              */
/*        .                                                                                                                               */
/*        if p-open-query then do:                                                                                                        */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2, Предмет изменения &3 БД: &4",                         */
/*                                                                p-d-card, v-cli-name, v-subject-chr, p-db-num ).                        */
/*        end.                                                                                                                            */
/*        { gbl/fltopend.i                                                                                                                */
/*          &where-cond = " ~                                                                                                             */
/*          X_c-dc-hist.corr-user-db-num = p-db-num  AND ~                                                                                */
/*          X_c-dc-hist.d-card  = p-d-card AND  ~                                                                                         */
/*          X_c-dc-hist.subject = p-subject AND ~                                                                                         */
/*          (p-host-code = ? or X_c-dc-hist.host-code = p-host-code) AND ~                                                                */
/*          (p-obj-code = 0 or (X_c-dc-hist.obj-type =  p-obj-type and X_c-dc-hist.obj-code = p-obj-code)) ~                              */
/*                        "                                                                                                               */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.corr-user-db-num = &1  AND ~                                                     */
/*          X_c-dc-hist.d-card  = &2&3&2 AND  ~                                                                                           */
/*          X_c-dc-hist.subject = &2&4&2 AND ~                                                                                            */
/*          (&5 = ? or X_c-dc-hist.host-code = &5) AND ~                                                                                  */
/*          (&6 = 0 or (X_c-dc-hist.obj-type =  &2&7&2 and X_c-dc-hist.obj-code = &6))' ~                                                 */
/*          , p-db-num ~                                                                                                                  */
/*          ,~{&double-quote~} ~                                                                                                          */
/*          ,p-d-card ~                                                                                                                   */
/*          ,p-subject ~                                                                                                                  */
/*          ,p-host-code ~                                                                                                                */
/*          ,p-obj-code ~                                                                                                                 */
/*          ,p-obj-type ) "                                                                                                               */
/*                                                                                                                                        */
/*          &use-ind    = " use-index ishow "                                                                                             */
/*          &by         = "  " }                                                                                                          */
/*      END.                                                                                                                              */
/*      WHEN "subject-object":u THEN DO:                                                                                                  */
/*  &scop hn-dc-hist-code p-subject                                                                                                       */
/*        assign                                                                                                                          */
/*        filter-point = filter-point0 + p-mode                                                                                           */
/*        v-subject-chr = {&hn-dc-hist-name}                                                                                              */
/*        filter-label = substitute("&1: Предмет изменения по объекту", filter-label0)                                                    */
/*        .                                                                                                                               */
/*        if p-open-query then do:                                                                                                        */
/*          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" ДКарта &1: &2, Предмет изменения &3 Объект &4&5 БД: &6 ",            */
/*                                                                p-d-card, v-cli-name, v-subject-chr, p-obj-type, p-obj-code, p-db-num ).*/
/*        end.                                                                                                                            */
/*        { gbl/fltopend.i                                                                                                                */
/*          &where-cond = " ~                                                                                                             */
/*          X_c-dc-hist.corr-user-db-num = p-db-num  AND ~                                                                                */
/*          X_c-dc-hist.d-card  = p-d-card AND  ~                                                                                         */
/*          X_c-dc-hist.subject = p-subject AND  ~                                                                                        */
/*          X_c-dc-hist.obj-type = p-obj-type AND  ~                                                                                      */
/*          X_c-dc-hist.obj-code = p-obj-code ~                                                                                           */
/*                        "                                                                                                               */
/*          &dyn_where-cond = " substitute(' X_c-dc-hist.corr-user-db-num = &1  AND ~                                                     */
/*          X_c-dc-hist.d-card  = &2&3&2 AND  ~                                                                                           */
/*          X_c-dc-hist.subject = &2&4&2 AND  ~                                                                                           */
/*          X_c-dc-hist.obj-type = &2&5&2 AND  ~                                                                                          */
/*          X_c-dc-hist.obj-code = &6 ', p-db-num, ~{&double-quote~}, p-d-card, p-subject , p-obj-type, p-obj-code) "                     */
/*                                                                                                                                        */
/*          &use-ind    = " use-index ishow "                                                                                             */
/*          &by         = "  " }                                                                                                          */
/*      END.                                                                                                                              */
    END CASE.
  end.
END CASE.

if not p-open-query and v-doc-rec <> ?  then
REPOSITION br-dc-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dc-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-dc-hist in frame {&frame-name}.
APPLY "ENTRY" TO br-dc-hist.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-doc-rec as recid no-undo.
define variable v-subject-chr as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
define variable v-source-type as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
v-obj COLUMN-LABEL "Контрагент" FORMAT "X(8)"
v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
v-cli      COLUMN-LABEL "Влад-ц карты" FORMAT "X(12)"
v-cli-name COLUMN-LABEL "Имя влад-ца карты" FORMAT "X(20)"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-dc-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-dc-hist.source-ref COLUMn-LABEL "№"
X_c-dc-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-dc-hist.corr-user-db-num
X_c-dc-hist.host-code COLUMN-LABEL "Фирма"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-dc-hist ).
DO WHILE available X_c-dc-hist :
      GET prev br-dc-hist.
END.
run prn-lib-open-stream  in this-procedure (
                                             input parparentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(180)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME HistoryList  .
run waitfram-show in this-procedure ( input "Ждите...").
  GET next br-dc-hist.
    DO WHILE available X_c-dc-hist :
      Display STREAM PrnLibStream
       X_c-dc-hist.obj-type + string(X_c-dc-hist.obj-code) @ v-obj
      get-action(X_c-dc-hist.action) @ v-action-chr
      (if v-find then get-cli(X_c-dc-hist.d-card) else "":U )  @ v-cli
      v-cli-name
      get-subject(X_c-dc-hist.subject) @ v-subject-chr
      X_c-dc-hist.is-news
      get-source-type(X_c-dc-hist.source-type) @ v-source-type
      X_c-dc-hist.source-ref
      X_c-dc-hist.corr-date
      string(X_c-dc-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-dc-hist.corr-user-name) @ v-for-user-name
      X_c-dc-hist.corr-user-db-num
      X_c-dc-hist.host-code
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-dc-hist.
END.
UNDERLINE  STREAM PrnLibStream
v-obj
v-action-chr
v-cli
v-cli-name
v-subject-chr
X_c-dc-hist.is-news
v-source-type
X_c-dc-hist.source-ref
X_c-dc-hist.corr-date
v-upd-time
v-for-user-name
X_c-dc-hist.corr-user-db-num
X_c-dc-hist.host-code
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ v-obj
string(accum-count)  @ v-action-chr
with frame HistoryList.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 8
                                          ).
reposition br-dc-hist to recid v-doc-rec no-error.
apply "entry" to br-dc-hist in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'c-dc-hist'
  join-tbl = 'X_c-dc-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Контрагент', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'dc-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-type', 'Источник_измен-я', 'hist-source-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-dc-hist Dialog-Frame
PROCEDURE proc-br-dc-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-corr-date Dialog-Frame
PROCEDURE proc-find-corr-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-d-card
0 @ sch-db-num
"":U @ sch-corr-user-name
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-dc-hist.corr-date = &1 "
          , v-date-chr)
        ,input v-corr-user-db-num
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-d-card Dialog-Frame
PROCEDURE proc-find-d-card :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-d-card like ub.c-dc-hist.d-card no-undo.
display
"":U @ sch-corr-user-name
with frame {&frame-name}.
display
"":U @ sch-corr-user-name
0 @ sch-db-num
sch-corr-date
with frame {&frame-name}.
assign
p-d-card = replace(p-d-card, {&double-quote}, "":U)
p-d-card = replace(p-d-card, {&single-quote}, {&single-quote} + {&single-quote})
p-d-card = {&double-quote} + p-d-card + {&double-quote}.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-dc-hist.d-card = &1 "
      , p-d-card)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-d-card in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-db-num Dialog-Frame
PROCEDURE proc-find-db-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-db-num like ub.c-dc-hist.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
"":U @ sch-d-card
sch-corr-date
with frame {&frame-name}.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-dc-hist.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame
PROCEDURE proc-find-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-dc-hist.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-d-card
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-dc-hist.corr-user-name = &1 "
      , p-user)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-dc-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cdchisv.p (
                   input X_c-dc-hist.d-card
                  ,input X_c-dc-hist.chip-num
                  ,input X_c-dc-hist.corr-user-db-num
                  ,input X_c-dc-hist.obj-type
                  ,input X_c-dc-hist.obj-code
                  ,input X_c-dc-hist.host-code
                  ,input X_c-dc-hist.subject
                  ,input X_c-dc-hist.action
                  ,input no /*p-silent*/
                  ,output v-description
               ) no-error .
Open QUery br-changes for each temp-changes.
assign
br-changes:title in frame {&frame-name} = v-description
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli Dialog-Frame
FUNCTION get-cli RETURNS CHARACTER
  ( p-d-card as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
find first buf_dis-card no-lock where
          buf_dis-card.d-card = ENTRY(1, p-d-card, {&delim-par}) no-error .
if not avail buf_dis-card then do:
  assign
  v-cli-name = "!!! Неизвестный владелец ДК!!!".
end.
find first buf_clients no-lock where
          buf_clients.obj-type = buf_dis-card.cli-type
      AND buf_clients.obj-code = buf_dis-card.cli-code
      no-error.
if not available buf_clients then do:
  assign
  v-cli-name = "!!! Неизвестный владелец ДК!!!".
end.
else do:
  assign
  v-cli-name = buf_clients.obj-name
  .
end.

RETURN (buf_clients.obj-type + string(buf_clients.obj-code)).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-source-type Dialog-Frame
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-source-code p-source-type
define variable v-dop as character no-undo .
assign
v-dop = {&hn-source-name}
no-error
.
RETURN v-dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-dc-hist-code p-subject
  RETURN {&hn-dc-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME