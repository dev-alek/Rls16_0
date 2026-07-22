&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-pl-gds-obj FOR ub.c-pl-gds-obj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/05
Author: Bakhtadze Natalya
Creation date: 08/15/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER  parparentproc     AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER  p-mode     AS CHARACTER NO-UNDO.
/*place one*/
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-pl-code  as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "История изменения товара на складском месте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/userobjs.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-doc-type  as character no-undo format "X(10)" column-label "Тип".
define variable v-diff-qnty as decimal   no-undo format "->>,>>>,>>9.<<<" column-label "Разница" .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-label0 as character no-undo init "История остатков на складских местах" .
define variable filter-label as character no-undo init "История остатков на складских местах" .
define variable filter-point0 as character no-undo init "cplgdsob" .
define variable filter-point as character no-undo init "cplgdsob" .
define variable sort-column-name as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cplgdsobj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-pl-gds-obj

/* Definitions for BROWSE BR-cplgdsobj                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cplgdsobj X_c-pl-gds-obj.corr-date X_c-pl-gds-obj.corr-time-str X_c-pl-gds-obj.fact-qnty X_c-pl-gds-obj.old-fact-qnty (X_c-pl-gds-obj.fact-qnty - X_c-pl-gds-obj.old-fact-qnty) @ v-diff-qnty X_c-pl-gds-obj.free-qnty X_c-pl-gds-obj.old-free-qnty X_c-pl-gds-obj.cli-fact-qnty X_c-pl-gds-obj.old-cli-fact-qnty X_c-pl-gds-obj.cli-free-qnty X_c-pl-gds-obj.old-cli-free-qnty X_c-pl-gds-obj.corr-user-db-num usrfulnf(X_c-pl-gds-obj.corr-user-name) get-doc-type(buffer X_c-pl-gds-obj) @ v-doc-type X_c-pl-gds-obj.source-ref
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cplgdsobj
&Scoped-define SELF-NAME BR-cplgdsobj
&Scoped-define OPEN-QUERY-BR-cplgdsobj /* OPEN QUERY {&SELF-NAME} FOR EACH X_c-pl-gds-obj NO-LOCK. */ run OpenBr in this-procedure ( input YES, ~
       input NO, ~
       input NO).
&Scoped-define TABLES-IN-QUERY-BR-cplgdsobj X_c-pl-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cplgdsobj X_c-pl-gds-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cplgdsobj}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_c-pl-gds-obj NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_c-pl-gds-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_c-pl-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_c-pl-gds-obj


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.c-pl-gds-obj.fact-qnty ~
ub.c-pl-gds-obj.old-fact-qnty ub.c-pl-gds-obj.cli-qnty ~
ub.c-pl-gds-obj.old-cli-qnty ub.c-pl-gds-obj.free-qnty ~
ub.c-pl-gds-obj.old-free-qnty
&Scoped-define ENABLED-TABLES ub.c-pl-gds-obj
&Scoped-define FIRST-ENABLED-TABLE ub.c-pl-gds-obj
&Scoped-Define ENABLED-OBJECTS b-exit b-show-doc B-print B-sch b-help ~
BR-cplgdsobj sch-gds-code sch-corr-date sch-source-ref sch-corr-user-name ~
fi-obj fi-gds fi-place fi-fact-qnty-descr fi-cli-qnty-descr ~
fi-free-qnty-descr
&Scoped-Define DISPLAYED-FIELDS ub.c-pl-gds-obj.fact-qnty ~
ub.c-pl-gds-obj.old-fact-qnty ub.c-pl-gds-obj.cli-qnty ~
ub.c-pl-gds-obj.old-cli-qnty ub.c-pl-gds-obj.free-qnty ~
ub.c-pl-gds-obj.old-free-qnty
&Scoped-define DISPLAYED-TABLES ub.c-pl-gds-obj
&Scoped-define FIRST-DISPLAYED-TABLE ub.c-pl-gds-obj
&Scoped-Define DISPLAYED-OBJECTS sch-gds-code sch-corr-date sch-source-ref ~
sch-corr-user-name fi-obj fi-gds fi-place fi-fact-qnty-descr ~
fi-cli-qnty-descr fi-free-qnty-descr

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
  ( BUFFER buf_c-pl-gds-obj FOR c-pl-gds-obj )  FORWARD.

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

DEFINE VARIABLE fi-cli-qnty-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.3 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-qnty-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.3 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-free-qnty-descr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.3 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 59.9 BY .67 NO-UNDO.

DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 60 BY .67 NO-UNDO.

DEFINE VARIABLE fi-place AS CHARACTER FORMAT "X(256)":U
     LABEL "Скл.место"
      VIEW-AS TEXT
     SIZE 59.9 BY .67 NO-UNDO.

DEFINE VARIABLE sch-corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате изм."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-gds-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "товару"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-source-ref AS CHARACTER FORMAT "X(9)":U
     LABEL "док-ту"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cplgdsobj FOR
      X_c-pl-gds-obj SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_c-pl-gds-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cplgdsobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cplgdsobj Dialog-Frame _FREEFORM
  QUERY BR-cplgdsobj DISPLAY
      X_c-pl-gds-obj.corr-date COLUMN-LABEL "Дата"
      X_c-pl-gds-obj.corr-time-str COLUMN-LABEL "Время"
      X_c-pl-gds-obj.fact-qnty COLUMN-LABEL "Стало!факт"
      X_c-pl-gds-obj.old-fact-qnty COLUMN-LABEL "Было!факт"
      (X_c-pl-gds-obj.fact-qnty - X_c-pl-gds-obj.old-fact-qnty) @ v-diff-qnty
      X_c-pl-gds-obj.free-qnty COLUMN-LABEL "Стало!своб"
      X_c-pl-gds-obj.old-free-qnty COLUMN-LABEL "Было!своб"
      X_c-pl-gds-obj.cli-fact-qnty COLUMN-LABEL "Стало!факт!ед.пост"
      X_c-pl-gds-obj.old-cli-fact-qnty COLUMN-LABEL "Было!факт!ед. пост"
      X_c-pl-gds-obj.cli-free-qnty COLUMN-LABEL "Стало!своб!ед.пост"
      X_c-pl-gds-obj.old-cli-free-qnty COLUMN-LABEL "Было!факт!ед.пост"
      X_c-pl-gds-obj.corr-user-db-num COLUMN-LABEL "БД"
      usrfulnf(X_c-pl-gds-obj.corr-user-name)
      get-doc-type(buffer X_c-pl-gds-obj) @ v-doc-type
      X_c-pl-gds-obj.source-ref
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 11.07.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-show-doc AT ROW 1 COL 31
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     BR-cplgdsobj AT ROW 5.07 COL 1.3
     sch-gds-code AT ROW 16.3 COL 44.6 COLON-ALIGNED
     sch-corr-date AT ROW 16.3 COL 64.1 COLON-ALIGNED
     sch-source-ref AT ROW 16.3 COL 83.1 COLON-ALIGNED
     sch-corr-user-name AT ROW 16.33 COL 22.1 COLON-ALIGNED
     fi-obj AT ROW 2.13 COL 2.9
     fi-gds AT ROW 3.13 COL 8.9 COLON-ALIGNED
     fi-place AT ROW 4.13 COL 10 COLON-ALIGNED
     ub.c-pl-gds-obj.fact-qnty AT ROW 18.63 COL 16.4 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-fact-qnty-descr AT ROW 18.63 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-pl-gds-obj.old-fact-qnty AT ROW 18.67 COL 48 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     ub.c-pl-gds-obj.cli-qnty AT ROW 19.63 COL 16.4 COLON-ALIGNED
          LABEL "Факт (пост)"
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-cli-qnty-descr AT ROW 19.63 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-pl-gds-obj.old-cli-qnty AT ROW 19.63 COL 48 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     ub.c-pl-gds-obj.free-qnty AT ROW 20.63 COL 16.5 COLON-ALIGNED
          LABEL "Своб-но"
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     fi-free-qnty-descr AT ROW 20.63 COL 40.5 COLON-ALIGNED NO-LABEL
     ub.c-pl-gds-obj.old-free-qnty AT ROW 20.63 COL 48 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 13 BY .67
          FGCOLOR 4
     "Было:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 17.77 COL 50
     "Стало:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 17.77 COL 18.5
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 16.27 COL 1
          FGCOLOR 4
     SPACE(89.09) SKIP(4.30)
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
      TABLE: X_c-pl-gds-obj B "?" ? ub c-pl-gds-obj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cplgdsobj b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.c-pl-gds-obj.cli-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-pl-gds-obj.fact-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fi-obj IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ub.c-pl-gds-obj.free-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-pl-gds-obj.old-free-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cplgdsobj
/* Query rebuild information for BROWSE BR-cplgdsobj
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH X_c-pl-gds-obj NO-LOCK. */
run OpenBr in this-procedure ( input YES, input NO, input NO).
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-cplgdsobj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "X_c-pl-gds-obj"
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
  if available X_c-pl-gds-obj
  then do:
    run display-doc in this-procedure
      (input X_c-pl-gds-obj.source-type
      ,input X_c-pl-gds-obj.source-ref
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cplgdsobj
&Scoped-define SELF-NAME BR-cplgdsobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cplgdsobj Dialog-Frame
ON DEFAULT-ACTION OF BR-cplgdsobj IN FRAME Dialog-Frame
DO:
  if available X_c-pl-gds-obj
  then do:
    run display-doc in this-procedure
      (input X_c-pl-gds-obj.source-type
      ,input X_c-pl-gds-obj.source-ref
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cplgdsobj Dialog-Frame
ON VALUE-CHANGED OF BR-cplgdsobj IN FRAME Dialog-Frame
DO:
  run display-record in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
DO:
   run proc-find-corr-date in this-procedure ( input yes, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
DO:
  run proc-find-corr-date in this-procedure ( input no, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-user-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON CTRL-J OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure ( input yes, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON RETURN OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure ( input no, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-gds-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON CTRL-J OF sch-gds-code IN FRAME Dialog-Frame /* товару */
DO:
  run proc-find-gds-code in this-procedure ( input yes, input frame {&frame-name} sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON RETURN OF sch-gds-code IN FRAME Dialog-Frame /* товару */
DO:
  run proc-find-gds-code in this-procedure ( input no, input frame {&frame-name} sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-source-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON CTRL-J OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure ( input yes, input frame {&frame-name} sch-source-ref) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON RETURN OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure ( input no, input frame {&frame-name} sch-source-ref) no-error.
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
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-pl-gds-obj).  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-cplgdsobj to recid v-doc-rec No-ERROR. ~
               apply 'value-changed' to br-cplgdsobj. " }

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
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  run display-record in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-parameters Dialog-Frame 
PROCEDURE check-parameters :
define variable v-obj-type like ub.clients.obj-type no-undo .
  define variable v-obj-code like ub.clients.obj-code no-undo .

  define buffer buf_clients for ub.clients .
  define buffer buf_goods   for ub.goods .
  define buffer buf_place  for ub.place .

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
      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
      }

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

    IF p-mode = 'one' THEN DO:
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
    END.
    find first buf_place no-lock
      where buf_place.obj-type = p-obj-type
        AND buf_place.obj-code = p-obj-code
        AND buf_place.pl-code = p-pl-code
      no-error .
    if not available buf_place
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Объект" p-obj-type p-obj-code skip
        "Код складского места" p-pl-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    do with frame {&frame-name}:
      if available buf_clients then do:
      assign
        fi-obj = substitute('&1 &2 &3':u
                           ,buf_clients.obj-type
                           ,buf_clients.obj-code
                           ,buf_clients.obj-name
                           ).
      end.
      if available buf_goods then do:
        fi-gds = substitute('&1 &2 &3 &4':u
                           ,buf_goods.artic
                           ,buf_goods.prod-type
                           ,buf_goods.prod-code
                           ,buf_goods.gds-name
                           )
        .
      end.
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
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = p-doc-code no-error .
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
                AND buf_c-trn-doc.is-del = yes :
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

  do
  on error undo, return error return-value
  :
    IF NOT AVAILABLE X_c-pl-gds-obj THEN DO:
        assign
        ub.c-pl-gds-obj.fact-qnty:visible in frame {&frame-name} = no
        ub.c-pl-gds-obj.old-fact-qnty:visible in frame {&frame-name} = no
        ub.c-pl-gds-obj.cli-qnty:visible in frame {&frame-name} = no
        ub.c-pl-gds-obj.old-cli-qnty:visible in frame {&frame-name} = no
        ub.c-pl-gds-obj.free-qnty:visible in frame {&frame-name} = no
        ub.c-pl-gds-obj.old-free-qnty:visible in frame {&frame-name} = no
        .
    END.
    else do:
      { gbl/gdscdat.i
        X_c-pl-gds-obj.gds-code
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
          "Код товара" X_c-pl-gds-obj.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_goods no-lock
        where buf_goods.gds-code = X_c-pl-gds-obj.gds-code
        .

      display
        buf_goods.unit-base @ fi-fact-qnty-descr
        with frame {&frame-name} .

      if v-gds-is-twounit = true
      then do:
        display
          buf_goods.unit-cli  @ fi-cli-qnty-descr
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

      do with frame {&frame-name}:
        if v-gds-is-twounit = true
        then do:
          assign
            c-pl-gds-obj.cli-qnty     :visible = true
            c-pl-gds-obj.old-cli-qnty :visible = true
          .
        end.
        else do:
          assign
            c-pl-gds-obj.cli-qnty     :visible = false
            c-pl-gds-obj.old-cli-qnty :visible = false
          .
        end.
      end. /* do with frame */
    end.
    if available X_c-pl-gds-obj
    then do:
      display
        X_c-pl-gds-obj.fact-qnty     @ c-pl-gds-obj.fact-qnty
        X_c-pl-gds-obj.old-fact-qnty @ c-pl-gds-obj.old-fact-qnty
        X_c-pl-gds-obj.free-qnty     @ c-pl-gds-obj.free-qnty
        X_c-pl-gds-obj.old-free-qnty @ c-pl-gds-obj.old-free-qnty
        with frame {&frame-name} .

      if v-gds-is-twounit = true
      then do:
        display
          X_c-pl-gds-obj.cli-qnty      @ c-pl-gds-obj.cli-qnty
          X_c-pl-gds-obj.old-cli-qnty  @ c-pl-gds-obj.old-cli-qnty
          with frame {&frame-name} .
      end.
    end.
    else do:
      display
        0 @ c-pl-gds-obj.fact-qnty
        0 @ c-pl-gds-obj.old-fact-qnty
        0 @ c-pl-gds-obj.cli-qnty
        0 @ c-pl-gds-obj.old-cli-qnty
        with frame {&frame-name} .

      if v-gds-is-twounit = true
      then do:
        display
          0 @ c-pl-gds-obj.cli-qnty
          0 @ c-pl-gds-obj.old-cli-qnty
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
  DISPLAY sch-gds-code sch-corr-date sch-source-ref sch-corr-user-name fi-obj 
          fi-gds fi-place fi-fact-qnty-descr fi-cli-qnty-descr 
          fi-free-qnty-descr 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.c-pl-gds-obj THEN 
    DISPLAY ub.c-pl-gds-obj.fact-qnty ub.c-pl-gds-obj.old-fact-qnty 
          ub.c-pl-gds-obj.cli-qnty ub.c-pl-gds-obj.old-cli-qnty 
          ub.c-pl-gds-obj.free-qnty ub.c-pl-gds-obj.old-free-qnty 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-show-doc B-print B-sch b-help BR-cplgdsobj sch-gds-code 
         sch-corr-date sch-source-ref sch-corr-user-name fi-obj fi-gds fi-place 
         ub.c-pl-gds-obj.fact-qnty fi-fact-qnty-descr 
         ub.c-pl-gds-obj.old-fact-qnty ub.c-pl-gds-obj.cli-qnty 
         fi-cli-qnty-descr ub.c-pl-gds-obj.old-cli-qnty 
         ub.c-pl-gds-obj.free-qnty fi-free-qnty-descr 
         ub.c-pl-gds-obj.old-free-qnty 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DISPLAY
  fi-obj
  fi-gds WHEN p-mode = 'one':U
  fi-place
  fi-fact-qnty-descr
  fi-cli-qnty-descr
  fi-free-qnty-descr
  WITH FRAME {&frame-name}.
  IF AVAILABLE ub.c-pl-gds-obj THEN
    DISPLAY ub.c-pl-gds-obj.fact-qnty ub.c-pl-gds-obj.old-fact-qnty
          ub.c-pl-gds-obj.cli-qnty ub.c-pl-gds-obj.old-cli-qnty
          ub.c-pl-gds-obj.free-qnty ub.c-pl-gds-obj.old-free-qnty
  WITH FRAME {&frame-name}.
  ENABLE
  b-exit
  b-show-doc
  b-sch
  b-help
  BR-cplgdsobj
  fi-obj
  fi-gds WHEN p-mode = 'one':U
  fi-place
  ub.c-pl-gds-obj.fact-qnty fi-fact-qnty-descr
  ub.c-pl-gds-obj.old-fact-qnty ub.c-pl-gds-obj.cli-qnty
  fi-cli-qnty-descr ub.c-pl-gds-obj.old-cli-qnty
  ub.c-pl-gds-obj.free-qnty fi-free-qnty-descr
  ub.c-pl-gds-obj.old-free-qnty
  sch-corr-date
  sch-gds-code when p-mode = 'place'
  sch-source-ref
  sch-corr-user-name
  WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
HIDE sch-corr-user-name IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
def var l-query-was-opened as logical no-undo .
define variable v-title as character no-undo .
define variable title0 as character no-undo.
title0 = "История остатков по складским местам" + {&space-char}.

def var sort-column-phrase as character no-undo .

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


&scop flt-open-open-query OPEN QUERY br-cplgdsobj FOR EACH X_c-pl-gds-obj

&scop flt-open-open-query-tail

&scop flt-open-query-handle query br-cplgdsobj:handle

&scop flt-open-dyn_open-query  FOR EACH X_c-pl-gds-obj

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-pl-gds-obj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-pl-gds-obj

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-mode :
  WHEN 'place':U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одно скл.место", filter-label0)
      .
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute("Объект &1&2 Остатки товаров на складском месте &3"
                                                        ,p-obj-type
                                                        ,p-obj-code
                                                        ,p-pl-code
                                                      ).
    end.
      { gbl/fltopend.i
            &where-cond = " ~
                          X_c-pl-gds-obj.obj-type = p-obj-type and X_c-pl-gds-obj.obj-code = p-obj-code   ~
                          AND X_c-pl-gds-obj.pl-code = p-pl-code "
            &dyn_where-cond = " substitute(' X_c-pl-gds-obj.obj-type = &1&2&1 and X_c-pl-gds-obj.obj-code = &3   ~
                          AND X_c-pl-gds-obj.pl-code = &4 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-pl-code)"

            &use-ind    = " "
            &by         = " by X_c-pl-gds-obj.gds-code by X_c-pl-gds-obj.chip-num descending " }

  END.
  WHEN 'one':U THEN  DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одно скл.место один товар", filter-label0)
      .
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute("Объект &1&2 Остатки товара с кодом &3 на складском месте &4"
                                                        ,p-obj-type, p-obj-code
                                                        , p-gds-code
                                                        , p-pl-code
                                                      ).
      end.
            { gbl/fltopend.i
            &where-cond = " ~
                          X_c-pl-gds-obj.obj-type = p-obj-type and X_c-pl-gds-obj.obj-code = p-obj-code   ~
                          AND X_c-pl-gds-obj.pl-code = p-pl-code and X_c-pl-gds-obj.gds-code = p-gds-code "
            &dyn_where-cond = " substitute(' X_c-pl-gds-obj.obj-type = &1&2&1 and X_c-pl-gds-obj.obj-code = &3   ~
                          AND X_c-pl-gds-obj.pl-code = &4 and X_c-pl-gds-obj.gds-code = &5 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-pl-code, p-gds-code)"

            &use-ind    = "  "
            &by         = " by X_c-pl-gds-obj.chip-num descending " }
  END.
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-cplgdsobj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-cplgdsobj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-cplgdsobj in frame {&frame-name}.
APPLY "ENTRY" TO br-cplgdsobj.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
def var date_string     as      char    no-undo.
def var Line                as      char    no-undo.
def var for-time as char.
def var accum-count as integer.
define variable v-doc-rec as recid no-undo.
define variable v-prod as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-pl-gds-obj.gds-code COLUMN-LABEL "Код товара"
X_c-pl-gds-obj.pl-code COLUMN-LABEL "Код скл.!места"
X_c-pl-gds-obj.old-fact-qnty COLUMN-LABEL "Количество!было"
X_c-pl-gds-obj.fact-qnty COLUMN-LABEL "Количество!стало"
v-action-chr FORMAT "X(10)" COLUMn-LABEL "Действие"
X_c-pl-gds-obj.source-ref COLUMn-LABEL "№"
X_c-pl-gds-obj.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name  column-label "Изменил" format "X(18)"
X_c-pl-gds-obj.corr-user-db-num
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-pl-gds-obj ).
DO WHILE available X_c-pl-gds-obj :
      GET prev br-cplgdsobj.
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
  GET next br-cplgdsobj.
    DO WHILE available X_c-pl-gds-obj :
      Display STREAM PrnLibStream
      X_c-pl-gds-obj.gds-code
      X_c-pl-gds-obj.pl-code
      X_c-pl-gds-obj.old-fact-qnty COLUMN-LABEL "Количество!было"
      X_c-pl-gds-obj.fact-qnty COLUMN-LABEL "Количество!стало"
      get-action(X_c-pl-gds-obj.action-type) @ v-action-chr
      X_c-pl-gds-obj.source-ref
      X_c-pl-gds-obj.corr-date
      string(X_c-pl-gds-obj.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-pl-gds-obj.corr-user-name) @ v-for-user-name
      X_c-pl-gds-obj.corr-user-db-num
      X_c-pl-gds-obj.obj-type + string(X_c-pl-gds-obj.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-cplgdsobj.
END.
UNDERLINE  STREAM PrnLibStream
X_c-pl-gds-obj.gds-code
X_c-pl-gds-obj.pl-code
X_c-pl-gds-obj.old-fact-qnty
X_c-pl-gds-obj.fact-qnty
v-action-chr
X_c-pl-gds-obj.source-ref
X_c-pl-gds-obj.corr-date
v-upd-time
v-for-user-name
X_c-pl-gds-obj.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-pl-gds-obj.gds-code
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
reposition br-cplgdsobj to recid v-doc-rec no-error.
apply "entry" to br-cplgdsobj in frame {&frame-name}.

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
  tbl = 'c-pl-gds-obj'
  join-tbl = 'X_c-pl-gds-obj'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-code', 'Код товара', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pl-code', 'Код складского места', '',
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
                    ,INPUT (filter-point + {&delim-par} + filter-label + {&delim-par} + 'yes':U)
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
0 @ sch-gds-code
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
        ,input substitute("and X_c-pl-gds-obj.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-gds-code Dialog-Frame 
PROCEDURE proc-find-gds-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-gds-code like ub.c-pl-gds-obj.gds-code no-undo.
define variable v-gds-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
sch-corr-date
'':U @ sch-source-ref
with frame {&frame-name}.
assign
v-gds-code = string(p-gds-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-pl-gds-obj.gds-code = &1 "
      , v-gds-code)
    ).
apply "entry":u to sch-gds-code in frame {&frame-name} .

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
define input parameter p-user like ub.c-pl-gds-obj.corr-user-name no-undo.
assign
sch-corr-date = ?
.
display
sch-corr-date
0 @ sch-gds-code
'':U @ sch-corr-user-name
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-pl-gds-obj.source-type = 'trn-doc' and X_c-pl-gds-obj.source-ref = &1 "
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
define input parameter p-user like ub.c-pl-gds-obj.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
sch-corr-date
0 @ sch-gds-code
'':U @ sch-source-ref
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-pl-gds-obj.corr-user-name = &1 "
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


RETURN dops.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-doc-type Dialog-Frame 
FUNCTION get-doc-type RETURNS CHARACTER
  ( BUFFER buf_c-pl-gds-obj FOR c-pl-gds-obj ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  if available buf_c-pl-gds-obj
  then do:
    case buf_c-pl-gds-obj.source-type
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
        return buf_c-pl-gds-obj.source-type .
      end.
    end case.
  end.

  RETURN "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

