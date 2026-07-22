&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER x-criterion-analysis FOR ub.criterion-analysis.
DEFINE NEW SHARED BUFFER x-XYZ-analysis FOR ub.XYZ-analysis.
DEFINE BUFFER x-XYZ-analysis-doc FOR ub.XYZ-analysis-doc.
DEFINE BUFFER x-XYZ-analysis-obj FOR ub.XYZ-analysis-obj.
DEFINE BUFFER x-XYZ-analysis-period FOR ub.XYZ-analysis-period.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заголовков XYZ-анализа

Автор: Чернова Светлана Александровна
Дата создания: 05/24/05
Author: Svetlana Chernova
Creation date: 05/24/05

*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-bttn        as character no-undo .
define output parameter p-rid-list    as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список заголовков XYZ-анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
{ gbl/getcntxt.i def }
{ ref/def-hash.i }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ rep/html-conv.i }

&scop cop-l1       mark-string(recid( x-XYZ-analysis), p-rid-list)
&scop dyn_cop-l1       substitute('dynamic-function(&1mark-string&1, recid(x-xyz-analysis), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2       x-XYZ-analysis.XYZ-name
&scop cop-l3       x-criterion-analysis.cral-name
&scop cop-l4       x-XYZ-analysis.XYZ-x
&scop cop-l5       x-XYZ-analysis.XYZ-y
&scop cop-l6       x-XYZ-analysis.XYZ-z
&scop cop-l7       x-XYZ-analysis.XYZ-string-obj
&scop cop-l8       x-XYZ-analysis.XYZ-string-period
&scop cop-l9       x-XYZ-analysis.XYZ-string-doc
&scop cop-l10      x-XYZ-analysis.XYZ-date-create
&scop cop-l11      STRING (x-XYZ-analysis.XYZ-time-create,'HH:MM')
&scop cop-l12      x-XYZ-analysis.XYZ-db-num-create
&scop cop-l13      x-XYZ-analysis.XYZ-id

&scop col-l1        '*'
&scop col-l2        'Наименование'
&scop col-l3        'Критерий!анализа'
&scop col-l4        ' X%'
&scop col-l5        ' Y%'
&scop col-l6        'Z%'
&scop col-l7        'Строка!объектов'
&scop col-l8        'Строка!периодов'
&scop col-l9        'Строка!документов'
&scop col-l10       'Дата!создания'
&scop col-l11       'Время!созд'
&scop col-l12       'БД'
&scop col-l13       'Внутр!№'

define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .

define variable  v-def as character no-undo .
define variable p-curr-obj-code as integer   no-undo .
define variable p-curr-obj-type as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .
{ gbl/getcntxt.i get }


assign
  p-curr-obj-type    = v-cntxt-obj-type
  p-curr-obj-code    = v-cntxt-obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1XYZ

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-XYZ-analysis x-criterion-analysis ~
x-XYZ-analysis-obj x-XYZ-analysis-period x-XYZ-analysis-doc

/* Definitions for BROWSE BROWSE-1XYZ                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1XYZ mark-string(recid( x-XYZ-analysis), p-rid-list) v-def x-XYZ-analysis.XYZ-name x-criterion-analysis.cral-name x-XYZ-analysis.XYZ-x x-XYZ-analysis.XYZ-z x-XYZ-analysis.XYZ-string-obj x-XYZ-analysis.XYZ-string-period x-XYZ-analysis.XYZ-string-doc x-XYZ-analysis.XYZ-date-create STRING (x-XYZ-analysis.XYZ-time-create,'HH:MM') x-XYZ-analysis.XYZ-db-num-create x-xyz-analysis.xyz-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1XYZ x-XYZ-analysis.XYZ-name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1XYZ x-XYZ-analysis
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1XYZ x-XYZ-analysis
&Scoped-define SELF-NAME BROWSE-1XYZ
&Scoped-define QUERY-STRING-BROWSE-1XYZ FOR EACH x-XYZ-analysis NO-LOCK, ~
             EACH x-criterion-analysis OF x-XYZ-analysis NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1XYZ OPEN QUERY {&SELF-NAME} FOR EACH x-XYZ-analysis NO-LOCK, ~
             EACH x-criterion-analysis OF x-XYZ-analysis NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1XYZ x-XYZ-analysis ~
x-criterion-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1XYZ x-XYZ-analysis
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1XYZ x-criterion-analysis


/* Definitions for BROWSE BROWSE-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-obj x-XYZ-analysis-obj.obj-type ~
x-XYZ-analysis-obj.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-obj
&Scoped-define QUERY-STRING-BROWSE-obj FOR EACH x-XYZ-analysis-obj ~
      WHERE x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-obj OPEN QUERY BROWSE-obj FOR EACH x-XYZ-analysis-obj ~
      WHERE x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-obj x-XYZ-analysis-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-obj x-XYZ-analysis-obj


/* Definitions for BROWSE BROWSE-period                                 */
&Scoped-define FIELDS-IN-QUERY-BROWSE-period ~
x-XYZ-analysis-period.XYZp-start x-XYZ-analysis-period.XYZp-end
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-period
&Scoped-define QUERY-STRING-BROWSE-period FOR EACH x-XYZ-analysis-period ~
      WHERE x-XYZ-analysis-period.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-period.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-period OPEN QUERY BROWSE-period FOR EACH x-XYZ-analysis-period ~
      WHERE x-XYZ-analysis-period.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-period.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-period x-XYZ-analysis-period
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-period x-XYZ-analysis-period


/* Definitions for BROWSE BROWSE-type-doc                               */
&Scoped-define FIELDS-IN-QUERY-BROWSE-type-doc ~
f-name-doc ( buffer x-XYZ-analysis-doc)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-type-doc
&Scoped-define QUERY-STRING-BROWSE-type-doc FOR EACH x-XYZ-analysis-doc ~
      WHERE x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-type-doc OPEN QUERY BROWSE-type-doc FOR EACH x-XYZ-analysis-doc ~
      WHERE x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and ~
x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-type-doc x-XYZ-analysis-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-type-doc x-XYZ-analysis-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-XYZ-analysis.xyz-des ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-XYZ-analysis.xyz-des ~

&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1XYZ}~
    ~{&OPEN-QUERY-BROWSE-obj}~
    ~{&OPEN-QUERY-BROWSE-period}~
    ~{&OPEN-QUERY-BROWSE-type-doc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.x-XYZ-analysis.xyz-des ~
x-XYZ-analysis.xyz-name
&Scoped-define ENABLED-TABLES ub.x-XYZ-analysis x-XYZ-analysis
&Scoped-define FIRST-ENABLED-TABLE ub.x-XYZ-analysis
&Scoped-define SECOND-ENABLED-TABLE x-XYZ-analysis
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup B-print ~
B-Help BROWSE-1XYZ BROWSE-obj BROWSE-period BROWSE-type-doc mark-num ~
v-user-name
&Scoped-Define DISPLAYED-FIELDS ub.x-XYZ-analysis.xyz-des ~
x-XYZ-analysis.xyz-name x-criterion-analysis.cral-name
&Scoped-define DISPLAYED-TABLES ub.x-XYZ-analysis x-XYZ-analysis ~
x-criterion-analysis
&Scoped-define FIRST-DISPLAYED-TABLE ub.x-XYZ-analysis
&Scoped-define SECOND-DISPLAYED-TABLE x-XYZ-analysis
&Scoped-define THIRD-DISPLAYED-TABLE x-criterion-analysis
&Scoped-Define DISPLAYED-OBJECTS mark-num v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_XYZ-analysis-doc FOR  x-XYZ-analysis-doc   )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Формирование нового анализа".

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр результата анализа".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY BROWSE-1XYZ FOR
      x-XYZ-analysis,
      x-criterion-analysis SCROLLING.

DEFINE QUERY BROWSE-obj FOR
      x-XYZ-analysis-obj SCROLLING.

DEFINE QUERY BROWSE-period FOR
      x-XYZ-analysis-period SCROLLING.

DEFINE QUERY BROWSE-type-doc FOR
      x-XYZ-analysis-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1XYZ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1XYZ Dialog-Frame _FREEFORM
  QUERY BROWSE-1XYZ NO-LOCK DISPLAY
      mark-string(recid( x-XYZ-analysis), p-rid-list)  COLUMN-LABEL "*" FORMAT "X(1)":U
      v-def   COLUMN-LABEL "d!e!f" FORMAT "x(1)":U WIDTH 1
      x-XYZ-analysis.XYZ-name                         COLUMN-LABEL "Наименование" FORMAT "X(30)":U WIDTH 20
      x-criterion-analysis.cral-name                  COLUMN-LABEL "Критерий!анализа" FORMAT "X(55)":U WIDTH 20
      x-XYZ-analysis.XYZ-x                            COLUMN-LABEL "   X%  " FORMAT ">9.9":U WIDTH 7
      x-XYZ-analysis.XYZ-z                            COLUMN-LABEL "   Z%  " FORMAT ">9.9":U WIDTH 7
      x-XYZ-analysis.XYZ-string-obj                   COLUMN-LABEL "Строка!объектов" FORMAT "X(30)":U WIDTH 10
      x-XYZ-analysis.XYZ-string-period                COLUMN-LABEL "Строка!периодов" FORMAT "X(30)":U WIDTH 10
      x-XYZ-analysis.XYZ-string-doc                   COLUMN-LABEL "Строка!документов" FORMAT "X(30)":U WIDTH 10
      x-XYZ-analysis.XYZ-date-create                  COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (x-XYZ-analysis.XYZ-time-create,'HH:MM') COLUMN-LABEL "Время!созд" FORMAT "x(5)":U WIDTH 5
      x-XYZ-analysis.XYZ-db-num-create                COLUMN-LABEL "БД" FORMAT ">>>>9":U
      x-xyz-analysis.xyz-id                           COLUMN-LABEL "Вн.!№" FORMAT ">>>>>>>>>9":U
  ENABLE
      x-XYZ-analysis.XYZ-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 11 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _STRUCTURED
  QUERY BROWSE-obj NO-LOCK DISPLAY
      x-XYZ-analysis-obj.obj-type FORMAT "X(3)":U
      x-XYZ-analysis-obj.obj-code FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 13 BY 6.75
         TITLE "Объекты" FIT-LAST-COLUMN TOOLTIP "Объекты XYZ анализа".

DEFINE BROWSE BROWSE-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-period Dialog-Frame _STRUCTURED
  QUERY BROWSE-period NO-LOCK DISPLAY
      x-XYZ-analysis-period.XYZp-start COLUMN-LABEL "Начало" FORMAT "99/99/99":U
      x-XYZ-analysis-period.XYZp-end COLUMN-LABEL "Конец" FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20 BY 6.75
         TITLE "Интервалы анализа" FIT-LAST-COLUMN TOOLTIP "Интервалы анализа".

DEFINE BROWSE BROWSE-type-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-type-doc Dialog-Frame _STRUCTURED
  QUERY BROWSE-type-doc NO-LOCK DISPLAY
      f-name-doc ( buffer x-XYZ-analysis-doc) COLUMN-LABEL "Тип документа" FORMAT "x(22)":U
            WIDTH 22
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25 BY 6.75
         TITLE "Типы документов" FIT-LAST-COLUMN TOOLTIP "Типы документов анализа".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 14
     B-sel AT ROW 1 COL 17
     B-add AT ROW 1 COL 27
     B-lookup AT ROW 1 COL 37
     B-chg AT ROW 1 COL 57.5
     B-del AT ROW 1 COL 67.5
     B-print AT ROW 1 COL 77.5
     B-Help AT ROW 1 COL 87.5
     BROWSE-1XYZ AT ROW 3 COL 1
     BROWSE-obj AT ROW 16.25 COL 2
     BROWSE-period AT ROW 16.25 COL 15
     BROWSE-type-doc AT ROW 16.25 COL 35
     ub.x-XYZ-analysis.xyz-des AT ROW 16.25 COL 60.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 37.88 BY 6.79 TOOLTIP "Описание анализа"
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL
     x-XYZ-analysis.xyz-name AT ROW 14.25 COL 2 NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 72 BY .67 TOOLTIP "Наименование анализа"
          FGCOLOR 4
     v-user-name AT ROW 14.25 COL 80.13 COLON-ALIGNED WIDGET-ID 2
     x-criterion-analysis.cral-name AT ROW 15.25 COL 1.5 NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 96.5 BY .67 TOOLTIP "Критерий анализа"
          FGCOLOR 4
     SPACE(0.38) SKIP(7.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список XYZ-анализов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-criterion-analysis B "NEW SHARED" ? ub criterion-analysis
      TABLE: x-XYZ-analysis B "NEW SHARED" ? ub XYZ-analysis
      TABLE: x-XYZ-analysis-doc B "?" ? ub XYZ-analysis-doc
      TABLE: x-XYZ-analysis-obj B "?" ? ub XYZ-analysis-obj
      TABLE: x-XYZ-analysis-period B "?" ? ub XYZ-analysis-period
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1XYZ B-Help Dialog-Frame */
/* BROWSE-TAB BROWSE-obj BROWSE-1XYZ Dialog-Frame */
/* BROWSE-TAB BROWSE-period BROWSE-obj Dialog-Frame */
/* BROWSE-TAB BROWSE-type-doc BROWSE-period Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x-criterion-analysis.cral-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-FORMAT                                         */
ASSIGN
       x-criterion-analysis.cral-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-name IN FRAME Dialog-Frame
   ALIGN-L EXP-FORMAT                                                   */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1XYZ
/* Query rebuild information for BROWSE BROWSE-1XYZ
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x-XYZ-analysis NO-LOCK,
      EACH x-criterion-analysis OF x-XYZ-analysis NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1XYZ */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-obj
/* Query rebuild information for BROWSE BROWSE-obj
     _TblList          = "x-XYZ-analysis-obj"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num"
     _FldNameList[1]   = Temp-Tables.x-XYZ-analysis-obj.obj-type
     _FldNameList[2]   = Temp-Tables.x-XYZ-analysis-obj.obj-code
     _Query            is OPENED
*/  /* BROWSE BROWSE-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-period
/* Query rebuild information for BROWSE BROWSE-period
     _TblList          = "x-XYZ-analysis-period"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-XYZ-analysis-period.XYZ-id = x-XYZ-analysis.XYZ-id and
x-XYZ-analysis-period.db-num = x-XYZ-analysis.db-num"
     _FldNameList[1]   > Temp-Tables.x-XYZ-analysis-period.XYZp-start
"x-XYZ-analysis-period.XYZp-start" "Начало" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.x-XYZ-analysis-period.XYZp-end
"x-XYZ-analysis-period.XYZp-end" "Конец" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-period */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-type-doc
/* Query rebuild information for BROWSE BROWSE-type-doc
     _TblList          = "x-XYZ-analysis-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and
x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num"
     _FldNameList[1]   > "_<CALC>"
"f-name-doc ( buffer x-XYZ-analysis-doc)" "Тип документа" "x(22)" ? ? ? ? ? ? ? no ? no no "22" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-type-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список XYZ-анализов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ABC-XYZ_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }

  if not loc#log then return no-apply.

  run proc-add in this-procedure (output loc-doc-rec ) no-error  .
  if error-status :error then message
  error-status :get-message(1)
  return-value .

  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
      reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
      {&cant-positioning}

  END.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).
 /* Проверка прав */
   run ref/xyzanali.w
     ( input parparentproc ,
       input  {&update} ,
       input {&first-table-in-query-{&browse-name}}.xyz-id ,
       input {&first-table-in-query-{&browse-name}}.db-num ,
       input-output loc-doc-rec
       ) .
   /*loc#log = {&BROWSE-NAME}:REFRESH() . */
   run OpenBR in this-procedure .
   reposition {&BROWSE-NAME} to recid loc-doc-rec .
   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
   apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ABC-XYZ_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
    if loc#log = false  then return no-apply .
    message "Удалить XYZ анализ ?"
      view-as alert-box question
      buttons yes-no
      update g-log as logical.
    if g-log = false then return no-apply.
    run waitfram-show in this-procedure ("Ждите...").
    run proc-b-del in this-procedure .
    run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).
 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ABC-XYZ_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
   if not loc#log then return no-apply.
   run ref/xyzanali.w
   (  input parparentproc ,
      input  {&lookup} ,
      input {&first-table-in-query-{&browse-name}}.xyz-id ,
      input {&first-table-in-query-{&browse-name}}.db-num ,
      input-output loc-doc-rec )
      .
   loc#log = {&browse-name}:refresh() .
   apply "entry" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  p-rid-list = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  p-rid-list = "" THEN DO:
      IF AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} THEN p-rid-list = string(RECID({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}})).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1XYZ
&Scoped-define SELF-NAME BROWSE-1XYZ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1XYZ Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1XYZ IN FRAME Dialog-Frame
DO:
define variable  p-abc-id   as integer   no-undo .
define variable  p-db-num   as integer   no-undo .

    IF AVAILABLE x-XYZ-analysis THEN DO :
      v-def = "" .
          run find-def-analysis-obj in this-procedure
          ( input  "xyz"
          ,input  p-curr-obj-type
          ,input  p-curr-obj-code
          ,output p-abc-id
          ,output p-db-num   ) .

       if p-abc-id = x-xyz-analysis.xyz-id and p-db-num = x-xyz-analysis.db-num
          then v-def = "x" .
          else "" .

       IF  x-criterion-analysis.cral-status <> 0 THEN
        ASSIGN
          x-XYZ-analysis.XYZ-name:fgcolor in browse {&browse-name} = DARK_GRAY_COLOR
          x-criterion-analysis.cral-name:fgcolor in browse {&browse-name} = DARK_GRAY_COLOR
        .
       ELSE
        ASSIGN
          x-XYZ-analysis.XYZ-name:fgcolor in browse {&browse-name} = ?
          x-criterion-analysis.cral-name:fgcolor in browse {&browse-name} = ?
        .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1XYZ Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1XYZ IN FRAME Dialog-Frame
DO:

    IF AVAILABLE x-XYZ-analysis THEN DO :
  { gbl/usrfulnm.i
     x-XYZ-analysis.XYZ-who-create
     v-user-name }
        DISPLAY x-XYZ-analysis.XYZ-des
                x-XYZ-analysis.XYZ-name
                x-criterion-analysis.cral-name
                v-user-name
        WITH FRAME Dialog-Frame.
      {&OPEN-QUERY-BROWSE-type-doc}
      {&OPEN-QUERY-BROWSE-obj}
      {&OPEN-QUERY-BROWSE-period}
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
{ gbl/setfltnm.i no-button }
{ gbl/app_help.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = x-XYZ-analysis
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &sort-clmn_11   =   "{&cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
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

    { gbl/mv-clmn.i
    &browse-name = "{&browse-name}"
    &frame-name = "{&frame-name}"
    &ext-col = 13
    &start-column = 3
    }

  { gbl/curdbnum.i v-db-num }
  x-XYZ-analysis.XYZ-des:READ-ONLY IN FRAME {&FRAME-NAME} = TRUE.
  x-XYZ-analysis.XYZ-name:READ-ONLY IN FRAME {&FRAME-NAME} = TRUE.
  x-XYZ-analysis.XYZ-name:READ-ONLY IN browse {&browse-name}  = TRUE.
  run my_enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_ui in this-procedure .

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
  DISPLAY mark-num v-user-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-XYZ-analysis THEN
    DISPLAY x-XYZ-analysis.xyz-des x-XYZ-analysis.xyz-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lookup B-print B-Help BROWSE-1XYZ
         BROWSE-obj BROWSE-period BROWSE-type-doc x-XYZ-analysis.xyz-des
         mark-num x-XYZ-analysis.xyz-name v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   {&cop-l2}:resizable in browse {&browse-name} = true .
   {&cop-l3}:resizable in browse {&browse-name} = true .

  ENABLE b-quit
         B-mark      when LOOKUP("b-mark":U, p-bttn ) > 0
         mark-num
         B-sel       when LOOKUP("b-sel":U, p-bttn ) > 0
         B-add       when LOOKUP("b-add":U, p-bttn ) > 0
         B-del       when LOOKUP("b-del":U, p-bttn ) > 0
         B-lookup
         B-print
         B-Help
         {&browse-name}
         BROWSE-obj
         BROWSE-period
         BROWSE-type-doc
         x-XYZ-analysis.XYZ-des
         x-XYZ-analysis.XYZ-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR Dialog-Frame
PROCEDURE OpenBR :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-open-query     as logical   no-undo init true .
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .

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

define variable title0 as character no-undo init "Список Ассортиментных матриц".


&scop flt-open-open-query OPEN QUERY BROWSE-1XYZ FOR EACH x-XYZ-analysis

&scop flt-open-dyn_open-query  FOR EACH x-xyz-analysis

&scop flt-open-query-handle query BROWSE-1xyz:handle

&scop flt-open-find-buffer-name x-xyz-analysis

&scop flt-open-open-query-tail , EACH x-criterion-analysis OF x-XYZ-analysis

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          x-XYZ-analysis

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer x-XYZ-analysis for XYZ-analysis .

&scop flt-open-debug-file

&scop flt-open-waitfram             true


{ gbl/fltopend.i
  &where-cond = " true   "
  &where-cond = " 'true' "
  &use-ind    = " "
  &by         = " " }

APPLY "ENTRY" TO {&browse-name} in frame {&frame-name}.
APPLY "VALUE-CHANGED" TO {&browse-name} in frame {&frame-name}.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output  parameter p-doc-rec as recid     no-undo .

run ref/xyzanali.w
    ( input parparentproc ,
      input  {&add-def} ,
      input  ? ,
      input v-db-num ,
      input-output p-doc-rec ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable loc-doc-rec as recid   no-undo.
define variable g#log       as logical no-undo .
define variable br-handle   as handle  no-undo.

if not available x-XYZ-analysis then return error.
 find current x-XYZ-analysis exclusive-lock no-error .
        if not available x-XYZ-analysis then do:
          message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1)   skip
                    "Ошибка при определении записи x-XYZ-analysis"
                    view-as alert-box error .
          return .
        end.
  delete x-XYZ-analysis .
  br-handle = {&browse-name}:handle in frame {&frame-name} .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    loc-doc-rec = RECID(x-XYZ-analysis) .
  end.

   run openbr in this-procedure .
   apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
   reposition {&browse-name} to recid loc-doc-rec no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

def var date_string     as      char    no-undo.
def var Line                as      char    no-undo.
def var for-time as char.
define variable v-time  as character no-undo .


/*Печать HTML*/
           run get-report-num (
            output p-report-id
        ).
        
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    /*шапка*/
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
             "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip

                '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
            
 /*определяем кол-во колонок*/

    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        '<TR class="set_columns">'skip
            '<TD style="width: 150px;"></TD>'skip
            '<TD style="width: 150px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 70px;"></TD>'skip
            '<TD style="width: 70px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 70px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
            '<TD style="width: 30px;"></TD>'skip
            '<TD style="width: 50px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 14px;">Список XYZ-анализов</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 14px;">Дата печати: ' + string(date_string,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .

     put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Наименование</TH>'skip
            '<TH style="text-align: center;">Критерий анализа</TH>'skip
            '<TH style="text-align: center;">X%</TH>'skip
            '<TH style="text-align: center;">Y%</TH>'skip
            '<TH style="text-align: center;">def X%</TH>'skip
            '<TH style="text-align: center;">def Y%</TH>'skip
            '<TH style="text-align: center;">Строка объектов</TH>'skip
            '<TH style="text-align: center;">Строка периодов</TH>'skip
            '<TH style="text-align: center;">Строка документов</TH>'skip
            '<TH style="text-align: center;">Дата создания</TH>'skip
            '<TH style="text-align: center;">Время создания</TH>'skip
            '<TH style="text-align: center;">БД</TH>'skip
            '<TH style="text-align: center;">Кто провел анализ</TH>'skip
        '</TR>'skip
        .

            
     for each x-XYZ-analysis :
       
put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD style="text-align: center"> ' + string(x-XYZ-analysis.XYZ-name) + '</TD>'skip
                                  '<TD style="text-align: center"> ' + string(x-criterion-analysis.cral-name) + '</TD>'skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-XYZ-analysis.XYZ-x,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-XYZ-analysis.XYZ-x <> ? then fnc-convert-dot-to-colon(x-XYZ-analysis.XYZ-x,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-XYZ-analysis.XYZ-y,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-XYZ-analysis.XYZ-y <> ? then fnc-convert-dot-to-colon(x-XYZ-analysis.XYZ-y,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-XYZ-analysis.raxd-x,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-XYZ-analysis.raxd-x <> ? then fnc-convert-dot-to-colon(x-XYZ-analysis.raxd-x,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-XYZ-analysis.raxd-y,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-XYZ-analysis.raxd-y <> ? then fnc-convert-dot-to-colon(x-XYZ-analysis.raxd-y,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD> ' + string(x-XYZ-analysis.XYZ-string-obj) + '</TD>'skip
                                  '<TD> ' + string(x-XYZ-analysis.XYZ-string-period) + '</TD>'skip
                                  '<TD> ' + string(x-XYZ-analysis.xyz-string-doc) + '</TD>'skip
                                  '<TD> ' + string(x-XYZ-analysis.xyz-date-create,"99/99/99") + '</TD>'skip
                                  '<TD> ' + STRING (x-XYZ-analysis.XYZ-time-create,'HH:MM') + '</TD>'skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-XYZ-analysis.xyz-db-num-create,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-XYZ-analysis.db-num <> ? then fnc-convert-dot-to-colon(x-XYZ-analysis.db-num,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD> ' + STRING (x-XYZ-analysis.xyz-who-create) + '</TD>'skip
                              '</TR>'skip    
                              .
      END.
                                     
   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
output stream OutStr-html close.                                
                                                          
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_XYZ-analysis-doc FOR  x-XYZ-analysis-doc   ) :
    define variable v-ret as character no-undo .
    run get-name-from-ext-type in this-procedure (buf_XYZ-analysis-doc.XYZd-ext-doc-type , no ,  output  v-ret ) .
  RETURN v-ret.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num automain
PROCEDURE get-report-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
