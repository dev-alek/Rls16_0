&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно редактирования признаков товара по строке документа

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/30/03


*/

/* ***************************  Definitions  ************************** */

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-node-code   as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter p-update-doc  as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Окно редактирования признаков товара по строке документа".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u,parparentproc,p-doc-code,p-gds-code,p-node-code,p-mode,p-update-doc)" }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i  }
{ gbl/prt-doc.i  }
{ gbl/waitfram.i }
{ cmp/operlist.i }

define variable v-filter-mode        as character no-undo .
define variable v-sort-mode          as character no-undo .
define variable v-doc-qnty           as decimal   no-undo .
define variable v-fact-qnty          as decimal   no-undo .
define variable v-prt-free-qnty      as decimal   no-undo .
define variable v-prt-fact-qnty      as decimal   no-undo .
define variable v-need-refresh       as logical   no-undo .
define variable v-sort-mode-int      as integer   no-undo .
define variable v-filter-mode-int    as integer   no-undo .
define variable v-can-create-gds-dtl as logical   no-undo .
define variable v-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-obj-code           like ub.trn-doc.obj-code no-undo .

define variable v-prt-name as character no-undo format "x(35)" label "Признак" .

&glob sort-b-code        'sort-b-code':u
&glob sort-sort-code     'sort-sort-code':u
&glob sort-tree          'sort-tree':u
&glob filter-b-code      'filter-b-code':u
&glob filter-prt-obj     'filter-prt-obj':u
&glob filter-not-zero    'filter-not-zero':u
&glob filter-doc         'filter-doc':u
&glob select-alt-current 'alt-current':u
&glob select-alt-all     'alt-all':u
&glob select-prod-all    'prod-all':u

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-gds-prt

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 b-code get-prt-name(buffer temp-gds-prt) @ v-prt-name doc-qnty fact-qnty prt-free-qnty prt-fact-qnty price-base price-rubl price-sale
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-gds-prt . */ run local-open-query in this-procedure (input ? ) .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-qnty b-scale b-crebcprt b-codes ~
b-alt b-rest b-arch b-print b-help b-refresh fi-search-b-code ~
RADIO-SET-sort RADIO-SET-filter BROWSE-1 fi-gds-label fi-gds fi-obj ~
fi-obj-label fi-sort-label fi-filter-label fi-doc-qnty fi-fact-qnty ~
fi-prt-free-qnty fi-prt-fact-qnty
&Scoped-Define DISPLAYED-OBJECTS fi-search-b-code RADIO-SET-sort ~
RADIO-SET-filter fi-gds-label fi-gds fi-obj fi-obj-label fi-sort-label ~
fi-filter-label fi-doc-qnty fi-fact-qnty fi-prt-free-qnty fi-prt-fact-qnty

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prt-name Dialog-Frame
FUNCTION get-prt-name RETURNS CHARACTER
  ( BUFFER buf_temp-gds-prt FOR temp-gds-prt )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-alt
     LABEL "&Неос/Доп"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-arch
     LABEL "&Арх.Товар"
     SIZE 11 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-codes
     LABEL "&Коды"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-crebcprt
     LABEL "Добав.БК"
     SIZE 11 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-qnty
     LABEL "&Изменить"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-refresh
     LABEL "Обновить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rest
     LABEL "&Остатки"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-scale
     LABEL "&Шкала"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-doc-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "По документу"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Фактически по документу"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-filter-label AS CHARACTER FORMAT "X(256)":U INITIAL "Фильтр:"
      VIEW-AS TEXT
     SIZE 23.63 BY .67 NO-UNDO.

DEFINE VARIABLE fi-gds AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-gds-label AS CHARACTER FORMAT "X(256)":U INITIAL "Товар:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-label AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE fi-prt-fact-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-prt-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-search-b-code AS CHARACTER FORMAT "X(40)":U
     LABEL "Код(весь)"
     VIEW-AS FILL-IN
     SIZE 28.75 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE fi-sort-label AS CHARACTER FORMAT "X(256)":U INITIAL "Сортировка/Вид:"
      VIEW-AS TEXT
     SIZE 23.75 BY .67 NO-UNDO.

DEFINE VARIABLE RADIO-SET-filter AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"На объекте", 2,
"Остаток", 3,
"Документ", 4
     SIZE 53.75 BY .88
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RADIO-SET-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "&Бар-код", 1,
"&Признак", 2,
"&Дерево", 3
     SIZE 39 BY .79
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      b-code
      get-prt-name(buffer temp-gds-prt) @ v-prt-name
      doc-qnty
      fact-qnty
      prt-free-qnty
      prt-fact-qnty
      price-base
      price-rubl
      price-sale
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 98.88 BY 13.96.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-qnty AT ROW 1 COL 9
     b-scale AT ROW 1 COL 21
     b-crebcprt AT ROW 1 COL 29
     b-codes AT ROW 1 COL 40
     b-alt AT ROW 1 COL 48
     b-rest AT ROW 1 COL 58
     b-arch AT ROW 1 COL 68
     b-print AT ROW 1 COL 79
     b-help AT ROW 1 COL 89
     b-refresh AT ROW 2 COL 9
     fi-search-b-code AT ROW 2.13 COL 61.38 COLON-ALIGNED
     RADIO-SET-sort AT ROW 5.21 COL 28 NO-LABEL
     RADIO-SET-filter AT ROW 6.21 COL 27.63 NO-LABEL
     BROWSE-1 AT ROW 9.17 COL 1
     fi-gds-label AT ROW 3.38 COL 1.88 NO-LABEL
     fi-gds AT ROW 3.38 COL 16.75 NO-LABEL
     fi-obj AT ROW 4.25 COL 16.63 NO-LABEL
     fi-obj-label AT ROW 4.29 COL 1.75 NO-LABEL
     fi-sort-label AT ROW 5.33 COL 1.88 NO-LABEL
     fi-filter-label AT ROW 6.42 COL 2.13 NO-LABEL
     fi-doc-qnty AT ROW 7.25 COL 17.38 COLON-ALIGNED
     fi-fact-qnty AT ROW 7.29 COL 62.25 COLON-ALIGNED
     fi-prt-free-qnty AT ROW 8.29 COL 17.25 COLON-ALIGNED
     fi-prt-fact-qnty AT ROW 8.33 COL 62.13 COLON-ALIGNED
     SPACE(18.86) SKIP(14.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Признаки товара".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 RADIO-SET-filter Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* SETTINGS FOR FILL-IN fi-filter-label IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-gds IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-gds-label IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-obj IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-obj-label IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-sort-label IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-gds-prt . */
run local-open-query in this-procedure (input ? ) .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Признаки товара */
DO:
  /* если пользователь нажал горячую клавишу закрытия формы */
  /* то необходимо передать фокус к кнопке выхода, */
  /* чтобы сработали триггеры */
  { gbl/stdbtn.i b-exit }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Признаки товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-alt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-alt Dialog-Frame
ON CHOOSE OF b-alt IN FRAME Dialog-Frame /* Неос/Доп */
DO:
  { gbl/stdbtn.i }

  run show-alt in this-procedure .

  assign
    v-need-refresh = true
  .
  run local-open-query in this-procedure
    (input ? /* p-reposition-node-code */
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch Dialog-Frame
ON CHOOSE OF b-arch IN FRAME Dialog-Frame /* Арх.Товар */
DO:
  { gbl/stdbtn.i }

  run show-gds-arch in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-codes Dialog-Frame
ON CHOOSE OF b-codes IN FRAME Dialog-Frame /* Коды */
DO:
  { gbl/stdbtn.i }

  run show-codes in this-procedure .

  assign
    v-need-refresh = true
  .
  run local-open-query in this-procedure
    (input ? /* p-reposition-node-code */
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-crebcprt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-crebcprt Dialog-Frame
ON CHOOSE OF b-crebcprt IN FRAME Dialog-Frame /* Добав.БК */
DO:
  { gbl/stdbtn.i }

  define variable v-create-bar-code as integer   no-undo .
  define variable v-is-new          as logical   no-undo .

  define buffer buf_bar-code for ub.bar-code .
  define variable v-reposition-node-code as integer   no-undo .

  if available temp-gds-prt
  then do:
    assign
      v-reposition-node-code = temp-gds-prt.node-code
    .
  end.
  else do:
    assign
      v-reposition-node-code = ?
    .
  end.

  run str/crebcprt.w
    (input  parparentproc     /* parparentproc   */
    ,input  p-gds-code        /* p-gds-code      */
    ,input  false             /* p-message-on    */
    ,output v-create-bar-code /* p-create-b-code */
    ,output v-is-new          /* p-is-new        */
    ) .

  if v-is-new = true
  then do:
    assign
      v-need-refresh = true
    .
  end.

  find first buf_bar-code no-lock
    where buf_bar-code.b-code = v-create-bar-code
    no-error .
  if available buf_bar-code
  then do:
    assign
      v-reposition-node-code = buf_bar-code.node-code
    .
  end.

  run local-open-query in this-procedure
    (input v-reposition-node-code /* p-reposition-node-code */
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  { gbl/stdbtn.i }

  run print-temp-gds-prt in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qnty Dialog-Frame
ON CHOOSE OF b-qnty IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/stdbtn.i }

  run edit-qnty in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  { gbl/stdbtn.i }

  define variable v-reposition-node-code as integer   no-undo .

  if available temp-gds-prt
  then do:
    assign
      v-reposition-node-code = temp-gds-prt.node-code
    .
  end.
  else do:
    assign
      v-reposition-node-code = ?
    .
  end.

  run make-temp-table in this-procedure no-error .
  run waitfram-hide in this-procedure .
  run local-open-query in this-procedure
    (input v-reposition-node-code /* p-reposition-node-code */
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rest Dialog-Frame
ON CHOOSE OF b-rest IN FRAME Dialog-Frame /* Остатки */
DO:
  { gbl/stdbtn.i }

  run show-rest in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scale Dialog-Frame
ON CHOOSE OF b-scale IN FRAME Dialog-Frame /* Шкала */
DO:
  { gbl/stdbtn.i }

  run show-scale in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run edit-qnty in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search-b-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-b-code Dialog-Frame
ON RETURN OF fi-search-b-code IN FRAME Dialog-Frame /* Код(весь) */
DO:
  define variable v-find-next as logical   no-undo .

  if fi-search-b-code <> input frame {&frame-name} fi-search-b-code then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.

  do with frame {&frame-name}:
    assign
      fi-search-b-code
    .
  end. /* do with frame */

  run search-bar-code in this-procedure
    (input fi-search-b-code
    ,input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-filter Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-filter IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    radio-set-filter
    .
  define variable v-reposition-node-code as integer   no-undo .

  if available temp-gds-prt
  then do:
    assign
      v-reposition-node-code = temp-gds-prt.node-code
    .
  end.
  else do:
    assign
      v-reposition-node-code = ?
    .
  end.

  run translate-filter in this-procedure
    (input  radio-set-filter
    ,output v-filter-mode
    ) .

  run local-open-query in this-procedure
    (input v-reposition-node-code /* p-reposition-node-code */
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-sort Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-sort IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    radio-set-sort
    .

  define variable v-reposition-node-code as integer   no-undo .

  if available temp-gds-prt
  then do:
    assign
      v-reposition-node-code = temp-gds-prt.node-code
    .
  end.
  else do:
    assign
      v-reposition-node-code = ?
    .
  end.

  run translate-sort in this-procedure
    (input  radio-set-sort
    ,output v-sort-mode
    ) .

  run local-open-query in this-procedure
    (input v-reposition-node-code /* p-reposition-node-code */
    ) .
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


on window-close of frame {&frame-name}
do:
  apply 'end-error':u to frame {&frame-name}.
end.

on 'end-error':u of frame {&frame-name}
do:
  return no-apply .
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run validate-input-parameters in this-procedure .

  run str/prt-mode.p
    (input  p-doc-code           /* p-doc-code           */
    ,input  p-gds-code           /* p-gds-code           */
    ,input  p-update-doc         /* p-update-doc         */
    ,output v-sort-mode-int      /* p-sort-mode          */
    ,output v-filter-mode-int    /* p-filter-mode        */
    ,output v-can-create-gds-dtl /* p-can-create-gds-dtl */
    ) .

  assign
    RADIO-SET-sort   = v-sort-mode-int
    RADIO-SET-filter = v-filter-mode-int
  .

  run translate-sort in this-procedure
    (input  radio-set-sort
    ,output v-sort-mode
    ) .

  run translate-filter in this-procedure
    (input  radio-set-filter
    ,output v-filter-mode
    ) .

  define variable v-ok as logical   no-undo .

  assign
    v-ok = {&browse-name} :set-repositioned-row(5, "conditional")
  .

  run make-temp-table in this-procedure .
  run waitfram-hide in this-procedure .

  RUN enable_UI.

  run show-input-info in this-procedure .

  if fi-search-b-code <> ""
  then do:
    run search-bar-code in this-procedure
      (input fi-search-b-code
      ,input true
      ) no-error .
    if error-status :error
    then do:
      assign
        fi-search-b-code :screen-value = ""
      .
      assign
        fi-search-b-code
      .
    end.
  end.

  run tune-interface in this-procedure .

  if p-node-code <> ?
  then do:
    run reposition-query in this-procedure
      (input p-node-code
      ) .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE edit-qnty Dialog-Frame
PROCEDURE edit-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-reposition-node-code as integer   no-undo .

  define variable v-terminal-prt as logical   no-undo .

  do
  on error undo, return error return-value
  :
    if available temp-gds-prt
    then do:
      { gbl/prtat.i
        temp-gds-prt.node-code
        'terminal-prt=request':u
        v-terminal-prt
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута признака" skip
          "Код признака" temp-gds-prt.node-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-terminal-prt = true
      then do:
        assign
          v-reposition-node-code = temp-gds-prt.node-code
        .

        run str/prt-edit.p
          (input  parparentproc          /* parparentproc */
          ,input  p-doc-code             /* p-doc-code    */
          ,input  p-gds-code             /* p-gds-code    */
          ,input  temp-gds-prt.node-code /* p-node-code   */
          ,input  p-mode                 /* p-mode        */
          ) .

        if p-mode <> {&lookup}
        then do:
          /* считываем данные из БД */
          run make-temp-table in this-procedure no-error .
          run waitfram-hide in this-procedure .
          run local-open-query in this-procedure
            (input v-reposition-node-code /* p-reposition-node-code */
            ) .
        end.
      end.
      else do:
        message
          "Количества можно указывать только для самых подробных признаков" skip
          view-as alert-box information .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY fi-search-b-code RADIO-SET-sort RADIO-SET-filter fi-gds-label fi-gds
          fi-obj fi-obj-label fi-sort-label fi-filter-label fi-doc-qnty
          fi-fact-qnty fi-prt-free-qnty fi-prt-fact-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-qnty b-scale b-crebcprt b-codes b-alt b-rest b-arch b-print
         b-help b-refresh fi-search-b-code RADIO-SET-sort RADIO-SET-filter
         BROWSE-1 fi-gds-label fi-gds fi-obj fi-obj-label fi-sort-label
         fi-filter-label fi-doc-qnty fi-fact-qnty fi-prt-free-qnty
         fi-prt-fact-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-sort-code Dialog-Frame
PROCEDURE get-sort-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-node-code as integer   no-undo .
  define output parameter p-sort-code as character no-undo .

  define buffer buf_gds-prt for ub.gds-prt .

  define variable v-upper-code as integer   no-undo .
  define variable v-sort-code  as character no-undo .
  define variable v-curr-node-sort as character no-undo .

  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .

  do while true
  :
    assign
      v-curr-node-sort = string(buf_gds-prt.prt-num, '999999999':u)
    .
    assign
      v-upper-code = buf_gds-prt.upper-code
    .
    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = v-upper-code
      no-error .
    if not available buf_gds-prt
    then do:
      leave .
    end.

    assign
      v-sort-code = v-curr-node-sort  + '/' + v-sort-code
    .

  end.

  assign
    p-sort-code = v-sort-code
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-reposition-node-code as integer   no-undo .

  define variable v-last-node-code as integer   no-undo .

  if p-reposition-node-code <> ?
  then do:
    assign
      v-last-node-code = p-reposition-node-code
    .
  end.
  else do:
    if available temp-gds-prt
    then do:
      assign
        v-last-node-code = temp-gds-prt.b-code
      .
    end.
    else do:
      assign
        v-last-node-code = ?
      .
    end.
  end.

  if  v-need-refresh = true
  and v-filter-mode = {&filter-b-code}
  then do:
    /* если на экране показаны все бар-коды */
    /* и пользователь открывал диалог просмотра бар-кодов */
    /* то необходимо повторно считать данные из таблицы бар-кодов */
    /* так как он мог добавить новые бар-коды */
    run make-temp-table in this-procedure no-error .
    run waitfram-hide in this-procedure .

    assign
      v-need-refresh = false
    .
  end.

  display
    v-doc-qnty      @ fi-doc-qnty
    v-fact-qnty     @ fi-fact-qnty
    v-prt-free-qnty @ fi-prt-free-qnty
    v-prt-fact-qnty @ fi-prt-fact-qnty
    with frame {&frame-name} .

  case v-filter-mode :
    when {&filter-b-code} then do:
      case v-sort-mode
      :
        when {&sort-b-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-list = true
            by b-code .
        end.
        when {&sort-sort-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-list = true
            by sort-code .
        end.
        when {&sort-tree}
        then do:
          open query {&browse-name} for each temp-gds-prt
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    when {&filter-prt-obj} then do:
      case v-sort-mode
      :
        when {&sort-b-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-prt = true
              and temp-gds-prt.show-list = true
            by b-code .
        end.
        when {&sort-sort-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-prt = true
              and temp-gds-prt.show-list = true
            by sort-code .
        end.
        when {&sort-tree}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-prt = true
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    when {&filter-not-zero} then do:
      case v-sort-mode
      :
        when {&sort-b-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-rest = true
              and temp-gds-prt.show-list = true
            by b-code .
        end.
        when {&sort-sort-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-rest = true
              and temp-gds-prt.show-list = true
            by sort-code .
        end.
        when {&sort-tree}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-rest = true
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    when {&filter-doc} then do:
      case v-sort-mode
      :
        when {&sort-b-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-doc  = true
              and temp-gds-prt.show-list = true
            by b-code .
        end.
        when {&sort-sort-code}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-doc  = true
              and temp-gds-prt.show-list = true
            by sort-code .
        end.
        when {&sort-tree}
        then do:
          open query {&browse-name} for each temp-gds-prt
            where temp-gds-prt.show-doc = true
            by sort-code .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-sort-mode" skip
            "" v-sort-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестное значение переменной v-filter-mode" skip
        "" v-filter-mode skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  if v-last-node-code <> ?
  then do:
    run reposition-query in this-procedure
      (input v-last-node-code
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-table Dialog-Frame
PROCEDURE make-temp-table :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-root-node as integer   no-undo .
  define variable v-prt-level as integer   no-undo .
  define variable v-ind       as integer   no-undo .
  define variable v-node-code as integer   no-undo .
  define variable v-is-new    as logical   no-undo .
  define variable v-term-prt  as logical   no-undo .

  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_goods        for ub.goods .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_gds-prt      for ub.gds-prt .
  define buffer buf_gds-dtl      for ub.gds-dtl .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .
    assign
    v-obj-type = buf_trn-doc.obj-type
    v-obj-code = buf_trn-doc.obj-code
    .
    for each buf_temp-gds-prt
    on error undo, return error return-value
    :
      delete buf_temp-gds-prt .
    end.

    assign
      v-doc-qnty      = 0
      v-fact-qnty     = 0
      v-prt-free-qnty = 0
      v-prt-fact-qnty = 0
    .

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .

    { gbl/gdsrtnod.i
      p-gds-code
      v-root-node
    }

    { gbl/prtlevel.i
      v-root-node
      v-prt-level
    }

    assign
      v-ind = 0
    .

    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = buf_goods.artic
        and buf_gds-dtl.prod-type = buf_goods.prod-type
        and buf_gds-dtl.prod-code = buf_goods.prod-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Просмотр признаков накладной &1", v-ind)
          ) .
      end.

      assign
        v-node-code = buf_gds-dtl.prt-code
      .

      { gbl/barcodcr.i
        buf_goods.gds-code
        v-node-code
        "''"
        "''"
        buf_goods.unit-base
        ?
        v-is-new
        buf_bar-code
      }

      { gbl/prtat.i
        v-node-code
        "'terminal-prt=request':u"
        v-term-prt
      }

      if v-term-prt = true
      then do:
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          .

        create buf_temp-gds-prt .
        assign
          buf_temp-gds-prt.b-code        = buf_bar-code.b-code
          buf_temp-gds-prt.node-code     = v-node-code
          buf_temp-gds-prt.upper-code    = buf_gds-prt.upper-code
          buf_temp-gds-prt.prt-name      = buf_gds-prt.f-name
          buf_temp-gds-prt.node-name     = buf_gds-prt.node-name
          buf_temp-gds-prt.doc-qnty      = buf_gds-dtl.doc-qnty
          buf_temp-gds-prt.fact-qnty     = buf_gds-dtl.fact-qnty
          buf_temp-gds-prt.prt-free-qnty = 0
          buf_temp-gds-prt.prt-fact-qnty = 0
          buf_temp-gds-prt.price-base    = buf_gds-dtl.price-base
          buf_temp-gds-prt.price-rubl    = buf_gds-dtl.price-rubl
          buf_temp-gds-prt.price-sale    = ?
          buf_temp-gds-prt.show-list     = true
          buf_temp-gds-prt.show-prt      = true
          buf_temp-gds-prt.show-rest     = true
          buf_temp-gds-prt.show-doc      = true
          buf_temp-gds-prt.prt-level     = v-prt-level
        .

        assign
          v-doc-qnty  = v-doc-qnty  + buf_gds-dtl.doc-qnty
          v-fact-qnty = v-fact-qnty + buf_gds-dtl.fact-qnty
        .

        run get-sort-code in this-procedure
          (input  buf_temp-gds-prt.node-code
          ,output buf_temp-gds-prt.sort-code
          ) .
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно обработать признак накладной для нетерминального признака" skip
          "Документ" buf_trn-doc.doc-code skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          "Код признака" v-node-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    assign
      v-ind = 0
    .
    for each buf_prt-obj no-lock
      where buf_prt-obj.obj-type  = buf_trn-doc.obj-type
        and buf_prt-obj.obj-code  = buf_trn-doc.obj-code
        and buf_prt-obj.artic     = buf_goods.artic
        and buf_prt-obj.prod-type = buf_goods.prod-type
        and buf_prt-obj.prod-code = buf_goods.prod-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Просмотр признаков товара на объекте &1", v-ind)
          ) .
      end.

      assign
        v-node-code = buf_prt-obj.prt-code
      .

      { gbl/barcodcr.i
        buf_goods.gds-code
        v-node-code
        "''"
        "''"
        buf_goods.unit-base
        ?
        v-is-new
        buf_bar-code
      }
      { gbl/prtat.i
        v-node-code
        "'terminal-prt=request':u"
        v-term-prt
      }

      if v-term-prt = true
      then do:
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          .

        find first buf_temp-gds-prt
          where buf_temp-gds-prt.node-code = v-node-code
          no-error .
        if not available buf_temp-gds-prt
        then do:
          create buf_temp-gds-prt .
          assign
            buf_temp-gds-prt.b-code        = buf_bar-code.b-code
            buf_temp-gds-prt.node-code     = v-node-code
            buf_temp-gds-prt.upper-code    = buf_gds-prt.upper-code
            buf_temp-gds-prt.prt-name      = buf_gds-prt.f-name
            buf_temp-gds-prt.node-name     = buf_gds-prt.node-name
            buf_temp-gds-prt.doc-qnty      = 0
            buf_temp-gds-prt.fact-qnty     = 0
            buf_temp-gds-prt.prt-free-qnty = 0
            buf_temp-gds-prt.prt-fact-qnty = 0
            buf_temp-gds-prt.price-base    = ?
            buf_temp-gds-prt.price-rubl    = ?
            buf_temp-gds-prt.price-sale    = ?
            buf_temp-gds-prt.show-list     = true
            buf_temp-gds-prt.show-prt      = false
            buf_temp-gds-prt.show-rest     = false
            buf_temp-gds-prt.show-doc      = false
            buf_temp-gds-prt.prt-level     = v-prt-level
          .
        end.

        assign
          buf_temp-gds-prt.show-prt      = true
          buf_temp-gds-prt.prt-free-qnty = buf_prt-obj.free-qnty
          buf_temp-gds-prt.prt-fact-qnty = buf_prt-obj.fact-qnty
          buf_temp-gds-prt.price-sale    = buf_prt-obj.price-sale
        .

        assign
          v-prt-free-qnty = v-prt-free-qnty + buf_prt-obj.free-qnty
          v-prt-fact-qnty = v-prt-fact-qnty + buf_prt-obj.fact-qnty
        .

        if (buf_temp-gds-prt.prt-free-qnty <> 0
            and buf_temp-gds-prt.prt-free-qnty <> ?
            )
        or (buf_temp-gds-prt.prt-fact-qnty <> 0
            and buf_temp-gds-prt.prt-fact-qnty = ?
            )
        then do:
          assign
            buf_temp-gds-prt.show-rest = true
          .
        end.

        run get-sort-code in this-procedure
          (input  buf_temp-gds-prt.node-code
          ,output buf_temp-gds-prt.sort-code
          ) .
      end.
    end.

    assign
      v-ind = 0
    .
    for each buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = buf_goods.unit-base
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Просмотр бар-кодов &1", v-ind)
          ) .
      end.

      /* просматриваем все бар-коды товара */
      find first buf_temp-gds-prt
        where buf_temp-gds-prt.node-code = buf_bar-code.node-code
        no-error .
      if not available buf_temp-gds-prt
      then do:
        { gbl/prtat.i
          buf_bar-code.node-code
          "'terminal-prt=request':u"
          v-term-prt
        }

        if v-term-prt = true
        then do:
          find first buf_gds-prt no-lock
            where buf_gds-prt.node-code = buf_bar-code.node-code
            .
          create buf_temp-gds-prt .
          assign
            buf_temp-gds-prt.b-code        = buf_bar-code.b-code
            buf_temp-gds-prt.node-code     = buf_bar-code.node-code
            buf_temp-gds-prt.upper-code    = buf_gds-prt.upper-code
            buf_temp-gds-prt.prt-name      = buf_gds-prt.f-name
            buf_temp-gds-prt.node-name     = buf_gds-prt.node-name
            buf_temp-gds-prt.doc-qnty      = 0
            buf_temp-gds-prt.fact-qnty     = 0
            buf_temp-gds-prt.prt-free-qnty = 0
            buf_temp-gds-prt.prt-fact-qnty = 0
            buf_temp-gds-prt.price-base    = ?
            buf_temp-gds-prt.price-rubl    = ?
            buf_temp-gds-prt.price-sale    = ?
            buf_temp-gds-prt.show-list     = true
            buf_temp-gds-prt.show-prt      = false
            buf_temp-gds-prt.show-rest     = false
            buf_temp-gds-prt.show-doc      = false
            buf_temp-gds-prt.prt-level     = v-prt-level
          .

          run get-sort-code in this-procedure
            (input  buf_temp-gds-prt.node-code
            ,output buf_temp-gds-prt.sort-code
            ) .
        end.
      end.
    end.


    /* обрабатываем все терминальные признаки и создаем записи промежуточных уровней */
    define variable v-level-tree as integer   no-undo .

    do v-level-tree = v-prt-level to 2 by -1
    :

      define buffer upper_temp-gds-prt for temp-gds-prt .
      for each buf_temp-gds-prt
        where buf_temp-gds-prt.prt-level = v-level-tree
      :
        find first upper_temp-gds-prt
          where upper_temp-gds-prt.node-code = buf_temp-gds-prt.upper-code
          no-error .
        if not available upper_temp-gds-prt
        then do:
          find first buf_gds-prt no-lock
            where buf_gds-prt.node-code = buf_temp-gds-prt.upper-code
            .
          find first buf_goods no-lock
            where buf_goods.gds-code = p-gds-code
            .
          find first buf_bar-code no-lock
            where buf_bar-code.gds-code  = buf_goods.gds-code
              and buf_bar-code.node-code = buf_gds-prt.node-code
              and buf_bar-code.part-code = ""
              and buf_bar-code.in-code   = ""
              and buf_bar-code.unit-cli  = buf_goods.unit-base
            no-error .
          define variable v-b-code as integer   no-undo .
          if available buf_bar-code
          then do:
            assign
              v-b-code = buf_bar-code.b-code
            .
          end.
          else do:
            assign
              v-b-code = ?
            .
          end.

          create upper_temp-gds-prt .
          assign
            upper_temp-gds-prt.b-code        = v-b-code
            upper_temp-gds-prt.node-code     = buf_gds-prt.node-code
            upper_temp-gds-prt.upper-code    = buf_gds-prt.upper-code
            upper_temp-gds-prt.prt-name      = ( if v-level-tree <> 2
                                                 then buf_gds-prt.f-name
                                                 else buf_gds-prt.node-name
                                               )
            upper_temp-gds-prt.node-name     = buf_gds-prt.node-name
            upper_temp-gds-prt.doc-qnty      = 0
            upper_temp-gds-prt.fact-qnty     = 0
            upper_temp-gds-prt.prt-free-qnty = 0
            upper_temp-gds-prt.prt-fact-qnty = 0
            upper_temp-gds-prt.price-base    = ?
            upper_temp-gds-prt.price-rubl    = ?
            upper_temp-gds-prt.price-sale    = ?
            upper_temp-gds-prt.show-list     = false
            upper_temp-gds-prt.show-prt      = false
            upper_temp-gds-prt.show-rest     = false
            upper_temp-gds-prt.prt-level     = v-level-tree - 1
          .
          run get-sort-code in this-procedure
            (input  upper_temp-gds-prt.node-code
            ,output upper_temp-gds-prt.sort-code
            ) .
        end.
        assign
          upper_temp-gds-prt.doc-qnty      = upper_temp-gds-prt.doc-qnty      + buf_temp-gds-prt.doc-qnty
          upper_temp-gds-prt.fact-qnty     = upper_temp-gds-prt.fact-qnty     + buf_temp-gds-prt.fact-qnty
          upper_temp-gds-prt.prt-free-qnty = upper_temp-gds-prt.prt-free-qnty + buf_temp-gds-prt.prt-free-qnty
          upper_temp-gds-prt.prt-fact-qnty = upper_temp-gds-prt.prt-fact-qnty + buf_temp-gds-prt.prt-fact-qnty
        .
        if buf_temp-gds-prt.show-prt = true
        then do:
          assign
            upper_temp-gds-prt.show-prt = true
          .
        end.
        if buf_temp-gds-prt.show-rest = true
        then do:
          assign
            upper_temp-gds-prt.show-rest = true
          .
        end.
        if buf_temp-gds-prt.show-doc = true
        then do:
          assign
            upper_temp-gds-prt.show-doc = true
          .
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-temp-gds-prt Dialog-Frame
PROCEDURE print-temp-gds-prt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* распечатать признаки по товару */

  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-gds-prt)
  .

  run str/prtdcxls.p
    (input this-procedure :handle
    ,input frame {&frame-name} :title
    ,input "Сортировка/Вид"
    ,input radio-label(string(RADIO-SET-sort),   RADIO-SET-sort   :radio-buttons)
    ,input "Фильтр"
    ,input radio-label(string(RADIO-SET-filter), RADIO-SET-filter :radio-buttons)
    ) .

  reposition {&browse-name} to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition {&browse-name} to row 1 .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prt-doc_get-current Dialog-Frame
PROCEDURE prt-doc_get-current :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-available     as logical   no-undo .
  define output parameter p-b-code        as integer   no-undo .
  define output parameter p-prt-name      as character no-undo .
  define output parameter p-doc-qnty      as decimal   no-undo .
  define output parameter p-fact-qnty     as decimal   no-undo .
  define output parameter p-prt-free-qnty as decimal   no-undo .
  define output parameter p-prt-fact-qnty as decimal   no-undo .
  define output parameter p-price-base    as decimal   no-undo .
  define output parameter p-price-rubl    as decimal   no-undo .
  define output parameter p-price-sale    as decimal   no-undo .

  if available temp-gds-prt
  then do:
    assign
      p-available     = true
      p-b-code        = temp-gds-prt.b-code
      p-prt-name      = get-prt-name(buffer temp-gds-prt)
      p-doc-qnty      = temp-gds-prt.doc-qnty
      p-fact-qnty     = temp-gds-prt.fact-qnty
      p-prt-free-qnty = temp-gds-prt.prt-free-qnty
      p-prt-fact-qnty = temp-gds-prt.prt-fact-qnty
      p-price-base    = temp-gds-prt.price-base
      p-price-rubl    = temp-gds-prt.price-rubl
      p-price-sale    = temp-gds-prt.price-sale
    .
  end.
  else do:
    assign
      p-available = false
    .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prt-doc_get-first Dialog-Frame
PROCEDURE prt-doc_get-first :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  apply "home":u to browse {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prt-doc_get-next Dialog-Frame
PROCEDURE prt-doc_get-next :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  get next {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-reposition-node-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if p-reposition-node-code <> ?
    then do:
      define buffer buf_reposition_temp-gds-prt for temp-gds-prt .

      define variable v-reposition-rowid as rowid     no-undo .

      find first buf_reposition_temp-gds-prt
        where buf_reposition_temp-gds-prt.node-code = p-reposition-node-code
        no-error .
      if available buf_reposition_temp-gds-prt
      then do:
        assign
          v-reposition-rowid = rowid(buf_reposition_temp-gds-prt)
        .

        reposition {&browse-name} to rowid v-reposition-rowid no-error .
        if error-status :error
        then do:
          reposition {&browse-name} to row 1 .
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE search-bar-code Dialog-Frame
PROCEDURE search-bar-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-search-code  as character no-undo .
  define input  parameter p-first-search as logical   no-undo .

  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .

  define variable v-b-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .

    run gbl/getbcode.p
      (input  parparentproc
      ,input  p-search-code        /* p-search-code */
      ,input  buf_trn-doc.obj-type /* p-obj-type    */
      ,input  buf_trn-doc.obj-code /* p-obj-code    */
      ,input  true                 /* p-with-chs    */
      ,output v-b-code             /* p-b-code      */
      ) .
    if v-b-code = ?
    then do:
      if p-first-search <> true
      then do:
        message
          "Бар-код не найден !"
          "Бар-код" p-search-code skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      if p-first-search <> true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Бар-код не найден !"
          "Бар-код" v-b-code skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

    if buf_bar-code.gds-code <> p-gds-code
    then do:
      if p-first-search <> true
      then do:
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          .
        message
          "Заданный бар-код принадлежит другому товару" skip
          "В данном окне поиск работает только внутри бар-кодов одного товара"
          "Бар-код" fi-search-b-code skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          buf_goods.gds-name skip
          view-as alert-box information .
      end.
      undo, return error return-value .
    end.

    find first buf_temp-gds-prt
      where buf_temp-gds-prt.node-code = buf_bar-code.node-code
      no-error .
    if available buf_temp-gds-prt
    then do:
      define variable v-curr-rowid as rowid no-undo .
      assign
        v-curr-rowid = rowid(temp-gds-prt)
      .
      reposition {&browse-name} to rowid rowid(buf_temp-gds-prt) no-error .
      if error-status :error
      then do:
        message
          "Признак с указанным бар-кодом не показывается в заданных условиях выбора" skip
          "Бар-код"  buf_temp-gds-prt.b-code        skip
          "Признак"  buf_temp-gds-prt.prt-name      skip
          "Свободно" buf_temp-gds-prt.prt-free-qnty skip
          "Факт"     buf_temp-gds-prt.prt-fact-qnty skip
          "Цена"     buf_temp-gds-prt.price-sale    skip
          view-as alert-box information .

        reposition {&browse-name} to rowid v-curr-rowid no-error .
        if error-status :error
        then do:
          reposition {&browse-name} to row 1 .
        end.
      end.
    end.
    else do:
      message
        "Внутренняя ошибка - не найден указанный признак" skip
        "Код товара" p-gds-code skip
        "Задан бар-код" v-b-code skip
        "Код признака" buf_bar-code.node-code skip
        view-as alert-box error .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-alt Dialog-Frame
PROCEDURE show-alt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-select-function as character no-undo .

  define variable v-rec-list as character no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    if available temp-gds-prt
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        .

      run gbl/d-list.w
        (input "b-sel"
        ,input "Просмотр"
        ,input {&select-alt-current}
          + {&comma-char} + {&select-alt-all}
          + {&comma-char} + {&select-prod-all}
        ,input "Существующие неосновные цены"
          + {&comma-char} + "Все неосновные коды"
          + {&comma-char} + "Дополнительные коды"
        ,input {&comma-char}
        ,'':U
        ,output v-select-function
        ).

      case v-select-function
      :
        when {&select-alt-current}
        then do:
          run ref/alt-cds.w
            (input  parparentproc        /* parParentProc */
            ,input  buf_trn-doc.obj-type /* p-obj-type    */
            ,input  buf_trn-doc.obj-code /* p-obj-code    */
            ,input  'code-current':u     /* mode          */
            ,input  p-gds-code           /* g-code        */
            ,input  temp-gds-prt.b-code  /* base-bc       */
            ,output v-rec-list           /* rec-list      */
            ).
        end.
        when {&select-alt-all}
        then do:
          run ref/alt-cds.w
            (input  parparentproc        /* parParentProc */
            ,input  buf_trn-doc.obj-type /* p-obj-type    */
            ,input  buf_trn-doc.obj-code /* p-obj-code    */
            ,input  'code-all':u         /* mode          */
            ,input  p-gds-code           /* g-code        */
            ,input  temp-gds-prt.b-code  /* base-bc       */
            ,output v-rec-list           /* rec-list      */
            ).
        end.
        when {&select-prod-all}
        then do:
          run ref/prod-cds.w
            (input  parparentproc        /* parParentProc */
            ,input  buf_trn-doc.obj-type /* p-obj-type    */
            ,input  buf_trn-doc.obj-code /* p-obj-code    */
            ,input  'code-all':u         /* mode          */
            ,input  p-gds-code           /* g-code        */
            ,input  temp-gds-prt.b-code  /* base-bc       */
            ,output v-rec-list           /* rec-list      */
            ).
        end.
      end case.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-codes Dialog-Frame
PROCEDURE show-codes :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if available temp-gds-prt
  then do:
    run ref/alt-bc.w
      (input parparentproc       /* parparentproc */
      ,input v-obj-type
      ,input v-obj-code
      ,input temp-gds-prt.b-code /* base-bc       */
      ).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-gds-arch Dialog-Frame
PROCEDURE show-gds-arch :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .
    run gbl/shgdsarh.p
      (INPUT PARPARENTPROC
      ,input p-gds-code           /* p-gds-code */
      ,input buf_trn-doc.obj-type /* p-obj-type */
      ,input buf_trn-doc.obj-code /* p-obj-code */
      ) .
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-input-info Dialog-Frame
PROCEDURE show-input-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}:

    define buffer buf_goods for ub.goods .
    define buffer buf_trn-doc for ub.trn-doc .

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if  available buf_goods
    and available buf_trn-doc
    then do:
      assign
        fi-gds :screen-value = substitute("&1 &2 &3 &4"
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        ,buf_goods.gds-name
                                        )
      .
      assign
        frame {&frame-name} :title = substitute("Редактирование признаков. Документ &1. Товар &1 &2 &3 &4"
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.artic
                                                ,buf_goods.prod-type
                                                ,buf_goods.prod-code
                                                ,buf_goods.gds-name
                                                )
      .
    end.
    else do:
      assign
        fi-gds :screen-value = ''
      .
      assign
        frame {&frame-name} :title = "Редактирование признаков"
      .
    end.

    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
      where buf_clients.obj-type = buf_trn-doc.obj-type
        and buf_clients.obj-code = buf_trn-doc.obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj :screen-value = substitute('&1 &2 &3'
                                ,buf_clients.obj-type
                                ,buf_clients.obj-code
                                ,buf_clients.obj-name
                                )
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-rest Dialog-Frame
PROCEDURE show-rest :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    if available temp-gds-prt
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        .
      define variable v-host-code as integer   no-undo .

      { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
      }

      define buffer buf_goods for ub.goods .

      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .

      run rep/gds-objs.w
        (input  parparentproc
        ,input  buf_goods.artic
        ,input  buf_goods.prod-type
        ,input  buf_goods.prod-code
        ,input  v-host-code
        ,input  temp-gds-prt.node-code
        ).
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-scale Dialog-Frame
PROCEDURE show-scale :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-root-node as character no-undo .

  { gbl/gdsrtnod.i
    p-gds-code
    v-root-node
  }

  run str/showprop.w
    (input v-root-node /* p-root-node */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE translate-filter Dialog-Frame
PROCEDURE translate-filter :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-filter-int  as integer   no-undo .
  define output parameter p-filter-mode as character no-undo .

  case p-filter-int :
    when 1 then do:
      assign
        p-filter-mode = {&filter-b-code}
      .
    end.
    when 2 then do:
      assign
        p-filter-mode = {&filter-prt-obj}
      .
    end.
    when 3 then do:
      assign
        p-filter-mode = {&filter-not-zero}
      .
    end.
    when 4 then do:
      assign
        p-filter-mode = {&filter-doc}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение параметра фильтрации" skip
        "Параметр фильтрации" p-filter-int skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE translate-sort Dialog-Frame
PROCEDURE translate-sort :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-sort-int  as integer   no-undo .
  define output parameter p-sort-mode as character no-undo .


  case p-sort-int :
    when 1 then do:
      assign
        p-sort-mode = {&sort-b-code}
      .
    end.
    when 2 then do:
      assign
        p-sort-mode = {&sort-sort-code}
      .
    end.
    when 3 then do:
      assign
        p-sort-mode = {&sort-tree}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение параметра сортировки" skip
        "Параметр сортировки" p-sort-int skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tune-interface Dialog-Frame
PROCEDURE tune-interface :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}:
      if p-mode = {&lookup}
      then do:
        assign
          b-qnty :label = "Пр&осмотр"
        .
      end.
      else do:
        assign
          b-qnty :label = "&Изменить"
        .
      end.

      apply 'entry':u to browse {&browse-name} .
    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-input-parameters Dialog-Frame
PROCEDURE validate-input-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_goods   for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_gds-dtl for ub.gds-dtl .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Режим" p-mode skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        "Редактирование количеств по документу" p-update-doc skip
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
        "Не найден товар" skip
        "Режим" p-mode skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        "Редактирование количеств по документу" p-update-doc skip
        view-as alert-box error .
      undo, return error return-value .
    end.


    define variable v-valid-obj as logical   no-undo .
    { gbl/objat.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      "'check-exist':u"
      v-valid-obj
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден объект" skip
        "Режим" p-mode skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
        "Редактирование количеств по документу" p-update-doc skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if lookup(p-mode, {&lookup} + {&comma-char} + {&prt-def}) = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный режим" skip
        "Режим" p-mode skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        "Редактирование количеств по документу" p-update-doc skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-update-doc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение признака Редактирование количеств по документу" skip
        "Режим" p-mode skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        "Редактирование количеств по документу" p-update-doc skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prt-name Dialog-Frame
FUNCTION get-prt-name RETURNS CHARACTER
  ( BUFFER buf_temp-gds-prt FOR temp-gds-prt ) :

  define variable v-return-prt-name as character no-undo .

  if v-sort-mode = {&sort-tree}
  then do:
    assign
      v-return-prt-name = fill(" ", 2 * (buf_temp-gds-prt.prt-level - 1) )+ buf_temp-gds-prt.node-name
    .
  end.
  else do:
    assign
      v-return-prt-name = buf_temp-gds-prt.prt-name
    .
  end.

  RETURN v-return-prt-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME