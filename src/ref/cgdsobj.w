&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-gds-obj FOR ub.c-gds-obj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/09/07
Author: Bakhtadze Natalya
Creation date: 03/09/07

Автор: Перваков Михаил Сергеевич
Дата создания: 02/02/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as WIDGET-HANDLE no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "История изменения товара на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/cur-time.i }
{ gbl/userobjs.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-doc-type  as character no-undo format "X(10)" column-label "Тип".
define variable v-diff-qnty as decimal   no-undo format "->>,>>>,>>9.<<<" column-label "Разница" .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "" .
define variable filter-point0 as character no-undo init "cgdsobj" .
define variable sort-column-name as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cgdsobj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-gds-obj

/* Definitions for BROWSE BR-cgdsobj                                    */
&Scoped-define FIELDS-IN-QUERY-BR-cgdsobj X_c-gds-obj.corr-date X_c-gds-obj.corr-time-str X_c-gds-obj.fact-qnty X_c-gds-obj.old-fact-qnty (X_c-gds-obj.fact-qnty - X_c-gds-obj.old-fact-qnty) @ v-diff-qnty X_c-gds-obj.corr-user-db-num usrfulnf(X_c-gds-obj.corr-user-name) get-doc-type(buffer X_c-gds-obj) @ v-doc-type X_c-gds-obj.source-ref
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cgdsobj
&Scoped-define SELF-NAME BR-cgdsobj
&Scoped-define OPEN-QUERY-BR-cgdsobj /* OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-obj NO-LOCK. */ run OpenBr in THIS-PROCEDURE (INPUT YES, ~
       INPUT NO, ~
       INPUT NO) .
&Scoped-define TABLES-IN-QUERY-BR-cgdsobj X_c-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cgdsobj X_c-gds-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cgdsobj}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_c-gds-obj NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_c-gds-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_c-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_c-gds-obj


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS c-gds-obj.fact-qnty c-gds-obj.old-fact-qnty ~
c-gds-obj.fact-base c-gds-obj.old-fact-base c-gds-obj.fact-rubl ~
c-gds-obj.old-fact-rubl c-gds-obj.fact-sale c-gds-obj.old-fact-sale ~
c-gds-obj.fact-cli-qnty c-gds-obj.old-fact-cli-qnty
&Scoped-define ENABLED-TABLES c-gds-obj
&Scoped-define FIRST-ENABLED-TABLE c-gds-obj
&Scoped-Define ENABLED-OBJECTS b-exit b-show-doc B-print B-sch b-help ~
BR-cgdsobj sch-corr-date sch-source-ref sch-corr-user-name fi-obj fi-gds ~
fi-fact-qnty-descr fi-fact-base-descr fi-fact-rubl-descr fi-fact-sale-descr ~
fi-fact-cli-qnty-descr
&Scoped-Define DISPLAYED-FIELDS c-gds-obj.fact-qnty c-gds-obj.old-fact-qnty ~
c-gds-obj.fact-base c-gds-obj.old-fact-base c-gds-obj.fact-rubl ~
c-gds-obj.old-fact-rubl c-gds-obj.fact-sale c-gds-obj.old-fact-sale ~
c-gds-obj.fact-cli-qnty c-gds-obj.old-fact-cli-qnty
&Scoped-define DISPLAYED-TABLES c-gds-obj
&Scoped-define FIRST-DISPLAYED-TABLE c-gds-obj
&Scoped-Define DISPLAYED-OBJECTS sch-corr-date sch-source-ref ~
sch-corr-user-name fi-obj fi-gds fi-fact-qnty-descr fi-fact-base-descr ~
fi-fact-rubl-descr fi-fact-sale-descr fi-fact-cli-qnty-descr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-doc-type Dialog-Frame
FUNCTION get-doc-type RETURNS CHARACTER
  ( BUFFER buf_c-gds-obj FOR ub.c-gds-obj )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-show-doc
     LABEL "&Документ"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-fact-base-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-cli-qnty-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-qnty-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-rubl-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-sale-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 59.88 BY .67 NO-UNDO.

DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 60 BY .67 NO-UNDO.

DEFINE VARIABLE sch-corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате изм."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-source-ref AS CHARACTER FORMAT "X(16)":U
     LABEL "док-ту"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cgdsobj FOR
      X_c-gds-obj SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_c-gds-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cgdsobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cgdsobj Dialog-Frame _FREEFORM
  QUERY BR-cgdsobj DISPLAY
      X_c-gds-obj.corr-date COLUMN-LABEL "Дата"
      X_c-gds-obj.corr-time-str COLUMN-LABEL "Время"
      X_c-gds-obj.fact-qnty COLUMN-LABEL "Стало"
      X_c-gds-obj.old-fact-qnty COLUMN-LABEL "Было"
      (X_c-gds-obj.fact-qnty - X_c-gds-obj.old-fact-qnty) @ v-diff-qnty
      X_c-gds-obj.corr-user-db-num COLUMN-LABEL "БД"
      usrfulnf(X_c-gds-obj.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)"
      get-doc-type(buffer X_c-gds-obj) @ v-doc-type
      X_c-gds-obj.source-ref
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 10.08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-show-doc AT ROW 1 COL 31
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     BR-cgdsobj AT ROW 4.08 COL 1.25
     sch-corr-date AT ROW 14.25 COL 62 COLON-ALIGNED
     sch-source-ref AT ROW 14.25 COL 83 COLON-ALIGNED
     sch-corr-user-name AT ROW 14.29 COL 22 COLON-ALIGNED
     fi-obj AT ROW 2.13 COL 2.88
     fi-gds AT ROW 3.13 COL 8.88 COLON-ALIGNED
     ub.c-gds-obj.fact-qnty AT ROW 16.63 COL 16.38 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-fact-qnty-descr AT ROW 16.63 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-gds-obj.old-fact-qnty AT ROW 16.67 COL 48 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-fact-base-descr AT ROW 17.58 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-gds-obj.fact-base AT ROW 17.63 COL 16.38 COLON-ALIGNED
          LABEL "Сумма уч.цен" FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     ub.c-gds-obj.old-fact-base AT ROW 17.67 COL 48 COLON-ALIGNED NO-LABEL FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     fi-fact-rubl-descr AT ROW 18.58 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-gds-obj.fact-rubl AT ROW 18.63 COL 16.38 COLON-ALIGNED
          LABEL "Сумма уч.цен" FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     ub.c-gds-obj.old-fact-rubl AT ROW 18.67 COL 48 COLON-ALIGNED NO-LABEL FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     ub.c-gds-obj.fact-sale AT ROW 19.63 COL 16.38 COLON-ALIGNED
          LABEL "Сумма прод.цен" FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     fi-fact-sale-descr AT ROW 19.63 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-gds-obj.old-fact-sale AT ROW 19.67 COL 48 COLON-ALIGNED NO-LABEL FORMAT "->>,>>>,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 23.25 BY .67
          FGCOLOR 4
     ub.c-gds-obj.fact-cli-qnty AT ROW 20.63 COL 16.38 COLON-ALIGNED
          LABEL "Факт (пост)"
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     ub.c-gds-obj.old-fact-cli-qnty AT ROW 20.67 COL 48 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-fact-cli-qnty-descr AT ROW 20.71 COL 40.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 14.25 COL 1
          FGCOLOR 4
     "Стало:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 15.75 COL 18.5
     "Было:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 15.75 COL 50
     SPACE(40.49) SKIP(5.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История остатков товара на объекте"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-gds-obj B "?" ? ub c-gds-obj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cgdsobj b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN c-gds-obj.fact-base IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN c-gds-obj.fact-cli-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN c-gds-obj.fact-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN c-gds-obj.fact-rubl IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN c-gds-obj.fact-sale IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN fi-obj IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN c-gds-obj.old-fact-base IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN c-gds-obj.old-fact-rubl IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN c-gds-obj.old-fact-sale IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cgdsobj
/* Query rebuild information for BROWSE BR-cgdsobj
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-obj NO-LOCK. */
run OpenBr in THIS-PROCEDURE (INPUT YES, INPUT NO, INPUT NO) .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-cgdsobj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "X_c-gds-obj"
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История остатков товара на объекте */
DO:
  APPLY "END-ERROR":U TO SELF.
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


&Scoped-define SELF-NAME b-show-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-show-doc Dialog-Frame
ON CHOOSE OF b-show-doc IN FRAME Dialog-Frame /* Документ */
DO:
  if available X_c-gds-obj
  then do:
    run display-doc in this-procedure
      (input X_c-gds-obj.source-type
      ,input X_c-gds-obj.source-ref
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cgdsobj
&Scoped-define SELF-NAME BR-cgdsobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cgdsobj Dialog-Frame
ON DEFAULT-ACTION OF BR-cgdsobj IN FRAME Dialog-Frame
DO:
  if available X_c-gds-obj
  then do:
    run display-doc in this-procedure
      (input X_c-gds-obj.source-type
      ,input X_c-gds-obj.source-ref
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cgdsobj Dialog-Frame
ON VALUE-CHANGED OF BR-cgdsobj IN FRAME Dialog-Frame
DO:
  run display-record in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
DO:
   run proc-find-corr-date in this-procedure(yes, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
DO:
  run proc-find-corr-date in this-procedure(no, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-user-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON CTRL-J OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure(yes, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON RETURN OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure(no, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-source-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON CTRL-J OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure(yes, input frame {&frame-name} sch-source-ref) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON RETURN OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure(no, input frame {&frame-name} sch-source-ref) no-error.
  if error-status:error then return no-apply.
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
{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-gds-obj).  RUn OpenBR(yes, no, '':U).  REPOSITION br-cgdsobj to recid v-doc-rec No-ERROR. " }

{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run check-parameters in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  RUN Myenable in this-procedure .
  RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input '':U).
  run display-record in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-parameters Dialog-Frame
PROCEDURE check-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-obj-type like ub.clients.obj-type no-undo .
  define variable v-obj-code like ub.clients.obj-code no-undo .
  define buffer buf_clients for ub.clients .
  define buffer buf_goods   for ub.goods .

  define variable v-host-code   as integer   no-undo .
  define variable v-user-select as logical   no-undo .

  do for buf_clients, buf_goods
  on error undo, return error return-value
  :
    if  p-obj-type = ""
    and p-obj-code = 0
    then do:
      message
        "Текущий объект не задан" skip
        "Выберите объект" skip
        view-as alert-box information .

      { gbl/uobjsone.i
        parparentproc
        v-cntxt-db-num
        v-cntxt-userid
        v-host-code
        p-obj-type
        p-obj-code
        v-user-select
        v-obj-type
        v-obj-code
      }
      if v-user-select <> true
      then do:
        undo, return error "Объект не выбран" .
      end.
      assign
      p-obj-type = v-obj-type
      p-obj-code = v-obj-code
      .
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Объект не найден" skip
        "Объект" p-obj-type p-obj-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Объект" p-obj-type p-obj-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    do with frame {&frame-name}:
      assign
        fi-obj = substitute('&1 &2 &3':u
                           ,buf_clients.obj-type
                           ,buf_clients.obj-code
                           ,buf_clients.obj-name
                           )
        fi-gds = substitute('&1 &2 &3 &4':u
                           ,buf_goods.artic
                           ,buf_goods.prod-type
                           ,buf_goods.prod-code
                           ,buf_goods.gds-name
                           )
      .
    end. /* do with frame */
  end.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-doc Dialog-Frame
PROCEDURE display-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-doc-type as character no-undo .
  define input  parameter p-doc-code as character no-undo .

  define buffer buf_goods for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-trn-doc for ub.c-trn-doc.


  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    case p-doc-type
    :
      when {&table_trn-doc}
      then do:
        find first buf_trn-doc no-lock where buF_trn-doc.doc-code = p-doc-code no-error.
        if available buf_trn-doc then do:
          run str/showdoc.p
            (input parparentproc       /* parparentproc */
            ,input p-doc-code          /* p-doc-code    */
            ,input buf_goods.artic     /* p-artic       */
            ,input buf_goods.prod-type /* p-prod-type   */
            ,input buf_goods.prod-code /* p-prod-code   */
            ,input true                /* p-doc-type    */
            ) .
        end.
        else do:
          for each buf_c-trn-doc no-lock where
                  buf_c-trn-doc.doc-code = p-doc-code
              AND buf_c-trn-doc.is-del = yes:
              run str/c-doc.w ( input parparentproc, input buf_c-trn-doc.doc-code, input buf_c-trn-doc.chip-num ).
              leave.
          end.
          if not available buf_c-trn-doc then do:
            message
              vss-workfile vss-revision vss-description skip
              "Документ не может быть показан" skip
              "Тип документа" p-doc-type skip
              "Код документа" p-doc-code skip
              view-as alert-box error .
          end.
        end.
      end.
      when {&table_price-doc}
      then do:
        run str/showdoc.p
          (input parparentproc       /* parparentproc */
          ,input p-doc-code          /* p-doc-code    */
          ,input buf_goods.artic     /* p-artic       */
          ,input buf_goods.prod-type /* p-prod-type   */
          ,input buf_goods.prod-code /* p-prod-code   */
          ,input false               /* p-doc-type    */
          ) .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Документ не может быть показан" skip
          "Тип документа" p-doc-type skip
          "Код документа" p-doc-code skip
          view-as alert-box error .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-record Dialog-Frame
PROCEDURE display-record :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-gds-is-twounit as logical   no-undo .

  define buffer buf_goods for ub.goods .
  define buffer buf_currency for ub.currency .

  define variable v-host-code as integer   no-undo .
  define variable v-base-code as integer   no-undo .

  define variable v-curr-base as character no-undo .
  define variable v-curr-rubl as character no-undo .
  define variable v-curr-sale as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/gdscdat.i
      p-gds-code
      "'twounit=request':u"
      v-gds-is-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Атрибут" 'twounit=request':u skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .

    display
      buf_goods.unit-base @ fi-fact-qnty-descr
      with frame {&frame-name} .

    if v-gds-is-twounit = true
    then do:
      display
        buf_goods.unit-cli  @ fi-fact-cli-qnty-descr
        with frame {&frame-name} .
    end.

    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
    }
    { gbl/basecode.i
      v-host-code
      v-base-code
    }

    find first buf_currency no-lock
      where buf_currency.curr-code = v-base-code
      no-error .
    if available buf_currency
    then do:
      assign
        v-curr-base = buf_currency.curr-abbr
      .
    end.

    /* ищем название р у б л е в о й валюты */
    find first buf_currency no-lock
      where buf_currency.curr-code = 0
      .
    assign
      v-curr-rubl  = buf_currency.curr-abbr
    .

    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base}
    then do:
      assign
        v-curr-sale = v-curr-base
      .
    end.
    else do:
      assign
        v-curr-sale = v-curr-rubl
      .
    end.

    display
      v-curr-base @ fi-fact-base-descr
      v-curr-rubl @ fi-fact-rubl-descr
      v-curr-sale @ fi-fact-sale-descr
      with frame {&frame-name} .

    do with frame {&frame-name}:
      if v-gds-is-twounit = true
      then do:
        assign
          ub.c-gds-obj.fact-cli-qnty     :visible = true
          ub.c-gds-obj.old-fact-cli-qnty :visible = true
        .
      end.
      else do:
        assign
          ub.c-gds-obj.fact-cli-qnty     :visible = false
          ub.c-gds-obj.old-fact-cli-qnty :visible = false
        .
      end.
    end. /* do with frame */

    if available X_c-gds-obj
    then do:
      display
        X_c-gds-obj.fact-qnty       @   c-gds-obj.fact-qnty
        X_c-gds-obj.old-fact-qnty   @   c-gds-obj.old-fact-qnty
        X_c-gds-obj.fact-base       @   c-gds-obj.fact-base
        X_c-gds-obj.old-fact-base   @   c-gds-obj.old-fact-base
        X_c-gds-obj.fact-rubl       @   c-gds-obj.fact-rubl
        X_c-gds-obj.old-fact-rubl   @   c-gds-obj.old-fact-rubl
        X_c-gds-obj.fact-sale       @   c-gds-obj.fact-sale
        X_c-gds-obj.old-fact-sale   @   c-gds-obj.old-fact-sale
        with frame {&frame-name} .

      if v-gds-is-twounit = true
      then do:
        display
          X_c-gds-obj.fact-cli-qnty      @  c-gds-obj.fact-cli-qnty
          X_c-gds-obj.old-fact-cli-qnty  @  c-gds-obj.old-fact-cli-qnty
          with frame {&frame-name} .
      end.
    end.
    else do:
      display
        0 @ c-gds-obj.fact-qnty
        0 @ c-gds-obj.old-fact-qnty
        0 @ c-gds-obj.fact-base
        0 @ c-gds-obj.old-fact-base
        0 @ c-gds-obj.fact-rubl
        0 @ c-gds-obj.old-fact-rubl
        0 @ c-gds-obj.fact-sale
        0 @ c-gds-obj.old-fact-sale
        with frame {&frame-name} .

      if v-gds-is-twounit = true
      then do:
        display
          0 @ c-gds-obj.fact-cli-qnty
          0 @ c-gds-obj.old-fact-cli-qnty
          with frame {&frame-name} .
      end.
    end.

  end.
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
  DISPLAY sch-corr-date sch-source-ref sch-corr-user-name fi-obj fi-gds
          fi-fact-qnty-descr fi-fact-base-descr fi-fact-rubl-descr
          fi-fact-sale-descr fi-fact-cli-qnty-descr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.c-gds-obj THEN
    DISPLAY c-gds-obj.fact-qnty c-gds-obj.old-fact-qnty c-gds-obj.fact-base
          c-gds-obj.old-fact-base c-gds-obj.fact-rubl c-gds-obj.old-fact-rubl
          c-gds-obj.fact-sale c-gds-obj.old-fact-sale c-gds-obj.fact-cli-qnty
          c-gds-obj.old-fact-cli-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-show-doc B-print B-sch b-help BR-cgdsobj sch-corr-date
         sch-source-ref sch-corr-user-name fi-obj fi-gds c-gds-obj.fact-qnty
         fi-fact-qnty-descr c-gds-obj.old-fact-qnty fi-fact-base-descr
         c-gds-obj.fact-base c-gds-obj.old-fact-base fi-fact-rubl-descr
         c-gds-obj.fact-rubl c-gds-obj.old-fact-rubl c-gds-obj.fact-sale
         fi-fact-sale-descr c-gds-obj.old-fact-sale c-gds-obj.fact-cli-qnty
         c-gds-obj.old-fact-cli-qnty fi-fact-cli-qnty-descr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
sch-corr-date
sch-source-ref
sch-corr-user-name
fi-obj fi-gds
fi-fact-qnty-descr
fi-fact-base-descr
fi-fact-rubl-descr
fi-fact-sale-descr
fi-fact-cli-qnty-descr
WITH FRAME {&frame-name}.
  IF AVAILABLE ub.c-gds-obj THEN
    DISPLAY ub.c-gds-obj.fact-qnty ub.c-gds-obj.old-fact-qnty
          ub.c-gds-obj.fact-base ub.c-gds-obj.old-fact-base
          ub.c-gds-obj.fact-rubl ub.c-gds-obj.old-fact-rubl
          ub.c-gds-obj.fact-sale ub.c-gds-obj.old-fact-sale
          ub.c-gds-obj.fact-cli-qnty ub.c-gds-obj.old-fact-cli-qnty
      WITH FRAME {&frame-name}.
  ENABLE
  b-exit
  b-show-doc
  B-print
  B-sch
  b-help
  BR-cgdsobj
  sch-corr-date
  sch-source-ref
  sch-corr-user-name fi-obj fi-gds ub.c-gds-obj.fact-qnty
         fi-fact-qnty-descr ub.c-gds-obj.old-fact-qnty fi-fact-base-descr
         ub.c-gds-obj.fact-base ub.c-gds-obj.old-fact-base fi-fact-rubl-descr
         ub.c-gds-obj.fact-rubl ub.c-gds-obj.old-fact-rubl
         ub.c-gds-obj.fact-sale fi-fact-sale-descr ub.c-gds-obj.old-fact-sale
         ub.c-gds-obj.fact-cli-qnty ub.c-gds-obj.old-fact-cli-qnty
         fi-fact-cli-qnty-descr
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
define variable l-query-was-opened as logical no-undo .
define variable v-title as character no-undo .
define variable title0 as character no-undo.
title0 = "История остатков по товарам" + {&space-char}.

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


&scop flt-open-open-query OPEN QUERY br-cgdsobj FOR EACH X_c-gds-obj

&scop flt-open-dyn_open-query  FOR EACH X_c-gds-obj

&scop flt-open-query-handle query br-cgdsobj:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-gds-obj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-gds-obj

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
if p-open-query then do:
  ASSIGN
  frame {&frame-name}:TITLE = title0 + substitute("Объект &1&2 Остатки товара с кодом &3"
                                                  ,p-obj-type, p-obj-code
                                                  , p-gds-code
                                                ).
end.
assign
filter-point = filter-point0
.

{ gbl/fltopend.i
&where-cond = " ~
          X_c-gds-obj.obj-type = p-obj-type and X_c-gds-obj.obj-code = p-obj-code   ~
          and X_c-gds-obj.gds-code = p-gds-code "
&DYN_where-cond = " substitute(' X_c-gds-obj.obj-type = &1&2&1 and X_c-gds-obj.obj-code = &3   ~
          and X_c-gds-obj.gds-code = &4 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-gds-code) "

&use-ind    = "  "
&by         = " by X_c-gds-obj.chip-num descending " }

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-cgdsobj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-cgdsobj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-cgdsobj in frame {&frame-name}.
APPLY "ENTRY" TO br-cgdsobj.
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
define variable v-prod as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-gds-obj.gds-code COLUMN-LABEL "Код товара"
X_c-gds-obj.old-fact-qnty COLUMN-LABEL "Количество!было"
X_c-gds-obj.fact-qnty COLUMN-LABEL "Количество!стало"
v-action-chr FORMAT "X(10)" COLUMn-LABEL "Действие"
X_c-gds-obj.source-ref COLUMn-LABEL "№"
X_c-gds-obj.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-gds-obj.corr-user-db-num
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-gds-obj ).
DO WHILE available X_c-gds-obj :
      GET prev br-cgdsobj.
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
run waitfram-show in this-procedure ("Ждите...").
  GET next br-cgdsobj.
    DO WHILE available X_c-gds-obj :
      Display STREAM PrnLibStream
      X_c-gds-obj.gds-code
      X_c-gds-obj.old-fact-qnty COLUMN-LABEL "Количество!было"
      X_c-gds-obj.fact-qnty COLUMN-LABEL "Количество!стало"
      get-action(X_c-gds-obj.action-type) @ v-action-chr
      X_c-gds-obj.source-ref
      X_c-gds-obj.corr-date
      string(X_c-gds-obj.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-gds-obj.corr-user-name) @ v-for-user-name
      X_c-gds-obj.corr-user-db-num
      X_c-gds-obj.obj-type + string(X_c-gds-obj.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-cgdsobj.
END.
UNDERLINE  STREAM PrnLibStream
X_c-gds-obj.gds-code
X_c-gds-obj.old-fact-qnty
X_c-gds-obj.fact-qnty
v-action-chr
X_c-gds-obj.source-ref
X_c-gds-obj.corr-date
v-upd-time
v-for-user-name
X_c-gds-obj.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-gds-obj.gds-code
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
reposition br-cgdsobj to recid v-doc-rec no-error.
apply "entry" to br-cgdsobj in frame {&frame-name}.

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
  tbl = 'c-gds-obj'
  join-tbl = 'X_c-gds-obj'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action-type', 'Действие', 'hist-action',
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
                    ,INPUT (filter-point0 + {&delim-par} + "История остатков товаров" + {&delim-par} + 'yes':U)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.

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
define input parameter p-date AS DATE no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-corr-user-name
'':U @ sch-source-ref
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-gds-obj.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-source-ref Dialog-Frame
PROCEDURE proc-find-source-ref :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-gds-obj.corr-user-name no-undo.
assign
sch-corr-date = ?
.
display
sch-corr-date
'':U @ sch-corr-user-name
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and  X_c-gds-obj.source-ref begins &1 "
      , p-user)
    ).
apply "entry":u to sch-source-ref in frame {&frame-name} .

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
define input parameter p-user like ub.c-gds-obj.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
sch-corr-date
'':U @ sch-source-ref
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-gds-obj.corr-user-name = &1 "
      , p-user)
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

define variable dops as character no-undo.
CASE p-action:
   when {&c-gds-obj_close} then do:
      return "Закр.на факт".
   end.
   when {&c-gds-obj_delete} then do:
      return "Удаление".
   end.
END CASE.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-doc-type Dialog-Frame
FUNCTION get-doc-type RETURNS CHARACTER
  ( BUFFER buf_c-gds-obj FOR c-gds-obj ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  if available buf_c-gds-obj
  then do:
    case buf_c-gds-obj.source-type
    :
      when {&table_trn-doc}
      then do:
        return "документ" .
      end.
      when {&table_price-doc}
      then do:
        return "переоценка" .
      end.
      otherwise do:
        return buf_c-gds-obj.source-type .
      end.
    end case.
  end.

  RETURN "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME