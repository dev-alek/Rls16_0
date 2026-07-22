&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER x-abc-analysis FOR ub.abc-analysis.
DEFINE BUFFER x-abc-analysis-doc FOR ub.abc-analysis-doc.
DEFINE BUFFER x-abc-analysis-obj FOR ub.abc-analysis-obj.
DEFINE BUFFER x-abc-analysis-period FOR ub.abc-analysis-period.
DEFINE NEW SHARED BUFFER x-criterion-analysis FOR ub.criterion-analysis.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заголовков ABC-анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/30/05
Author: Svetlana Chernova
Creation date: 03/30/05

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
define variable vss-description as character no-undo init "Список заголовков ABC-анализа".
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
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ rep/html-conv.i }


&scop cop-l1       mark-string(recid(x-abc-analysis) , p-rid-list)
&scop dyn_cop-l1       substitute('dynamic-function(&1mark-string&1, recid(x-abc-analysis), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2       x-abc-analysis.abc-name
&scop cop-l3       x-criterion-analysis.cral-name
&scop cop-l4       x-abc-analysis.abc-a
&scop cop-l5       x-abc-analysis.abc-b - x-abc-analysis.abc-a
&scop cop-l6       x-abc-analysis.abc-c - x-abc-analysis.abc-b
&scop cop-l7       if ( x-abc-analysis.abc-d - x-abc-analysis.abc-c ) < 0 then 0 else x-abc-analysis.abc-d - x-abc-analysis.abc-c
&scop cop-l8       if ( x-abc-analysis.abc-e - x-abc-analysis.abc-d ) < 0 then 0 else x-abc-analysis.abc-e - x-abc-analysis.abc-d
&scop cop-l9       if ( x-abc-analysis.abc-f - x-abc-analysis.abc-e ) < 0 then 0 else x-abc-analysis.abc-f - x-abc-analysis.abc-e
&scop copv-l5      v-b
&scop copv-l6      v-c
&scop copv-l7      v-d
&scop copv-l8      v-e
&scop copv-l9      v-f
&scop cop-l10      x-abc-analysis.abc-string-obj
&scop cop-l11      x-abc-analysis.abc-string-period
&scop cop-l12      x-abc-analysis.abc-string-doc
&scop cop-l13      x-abc-analysis.abc-date-create
&scop cop-l14      STRING (x-abc-analysis.abc-time-create,'HH:MM')
&scop cop-l15      x-abc-analysis.abc-db-num-create
&scop cop-l16      x-abc-analysis.abc-who-create
&scop cop-l17      v-def
&scop cop-l18      x-abc-analysis.abc-id

&scop col-l1        '*'

&scop col-l2        'Наименование'
&scop col-l3        'Критерий!анализа'
&scop col-l4        'A%'
&scop col-l5        'B%'
&scop col-l6        'C%'
&scop col-l7        'D%'
&scop col-l8        'E%'
&scop col-l9        'F%'
&scop col-l10       'Строка!объектов'
&scop col-l11       'Строка!периодов'
&scop col-l12       'Строка!документов'
&scop col-l13       'Дата!создания'
&scop col-l14       'Время!созд'
&scop col-l15       'БД'
&scop col-l16       'Кто провел!анализ'
&scop col-l17       'd!e!f'
&scop col-l18       'Внутренний!№'

&scop head-col ~
 {&col-l1} + '#' + ~
 {&col-l2} + '#' + ~
 {&col-l3} + '#' + ~
 {&col-l4} + '#' + ~
 {&col-l5} + '#' + ~
 {&col-l6} + '#' + ~
 {&col-l7} + '#' + ~
 {&col-l8} + '#' + ~
 {&col-l9} + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l15} + '#' + ~
 {&col-l16} + '#' + ~
 {&col-l17} + '#' + ~
 {&col-l18}


define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Список АВС анализов" .
define variable filter-point0 as character no-undo init "Список_АВС_анализов" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .

define variable par-abc-type as character no-undo .
define variable v-b as decimal   no-undo .
define variable v-c as decimal   no-undo .
define variable v-d as decimal   no-undo .
define variable v-e as decimal   no-undo .
define variable v-f as decimal   no-undo .

define variable v-def as character no-undo .
define variable p-curr-obj-code as integer   no-undo .
define variable p-curr-obj-type as character no-undo .
define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .

assign
  p-curr-obj-type    = v-cntxt-obj-type
  p-curr-obj-code    = v-cntxt-obj-code
.

run uf-get in this-procedure(
     input  {&uf-list-abc}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  end.

if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
   v-size-col1  = decimal (entry(2, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col2  = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 20.
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 20.

   if v-order-col = "" or v-order-col = ? then v-order-col = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-ABC

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-abc-analysis x-criterion-analysis ~
x-abc-analysis-obj x-abc-analysis-period x-abc-analysis-doc

/* Definitions for BROWSE BROWSE-ABC                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-ABC mark-string ( buffer x-abc-analysis, p-rid-list ) v-def x-abc-analysis.abc-name x-criterion-analysis.cral-name {&cop-l4} {&cop-l5} @ v-b {&cop-l6} @ v-c {&cop-l7} @ v-d {&cop-l8} @ v-e {&cop-l9} @ v-f x-abc-analysis.abc-string-obj x-abc-analysis.abc-string-period x-abc-analysis.abc-string-doc x-abc-analysis.abc-date-create STRING (x-abc-analysis.abc-time-create,'HH:MM') x-abc-analysis.abc-db-num-create x-abc-analysis.abc-who-create x-abc-analysis.abc-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-ABC x-abc-analysis.abc-name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-ABC x-abc-analysis
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-ABC x-abc-analysis
&Scoped-define SELF-NAME BROWSE-ABC
&Scoped-define QUERY-STRING-BROWSE-ABC FOR EACH x-abc-analysis NO-LOCK, ~
             EACH x-criterion-analysis OF x-abc-analysis NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-ABC OPEN QUERY {&SELF-NAME} FOR EACH x-abc-analysis NO-LOCK, ~
             EACH x-criterion-analysis OF x-abc-analysis NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-ABC x-abc-analysis ~
x-criterion-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-ABC x-abc-analysis
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-ABC x-criterion-analysis


/* Definitions for BROWSE BROWSE-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-obj x-abc-analysis-obj.obj-type ~
x-abc-analysis-obj.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-obj
&Scoped-define QUERY-STRING-BROWSE-obj FOR EACH x-abc-analysis-obj ~
      WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-obj OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj ~
      WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-obj x-abc-analysis-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-obj x-abc-analysis-obj


/* Definitions for BROWSE BROWSE-period                                 */
&Scoped-define FIELDS-IN-QUERY-BROWSE-period ~
x-abc-analysis-period.abcp-start x-abc-analysis-period.abcp-end
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-period
&Scoped-define QUERY-STRING-BROWSE-period FOR EACH x-abc-analysis-period ~
      WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-period OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period ~
      WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-period x-abc-analysis-period
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-period x-abc-analysis-period


/* Definitions for BROWSE BROWSE-type-doc                               */
&Scoped-define FIELDS-IN-QUERY-BROWSE-type-doc ~
f-name-doc ( buffer x-abc-analysis-doc)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-type-doc
&Scoped-define QUERY-STRING-BROWSE-type-doc FOR EACH x-abc-analysis-doc ~
      WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-type-doc OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc ~
      WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and ~
x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-type-doc x-abc-analysis-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-type-doc x-abc-analysis-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-abc-analysis.abc-des ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-abc-analysis.abc-des ~

&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-ABC}~
    ~{&OPEN-QUERY-BROWSE-obj}~
    ~{&OPEN-QUERY-BROWSE-period}~
    ~{&OPEN-QUERY-BROWSE-type-doc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.x-abc-analysis.abc-des ~
x-abc-analysis.abc-name
&Scoped-define ENABLED-TABLES ub.x-abc-analysis x-abc-analysis
&Scoped-define FIRST-ENABLED-TABLE ub.x-abc-analysis
&Scoped-define SECOND-ENABLED-TABLE x-abc-analysis
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup B-print ~
B-Help BROWSE-ABC BROWSE-obj BROWSE-period BROWSE-type-doc mark-num ~
v-user-name
&Scoped-Define DISPLAYED-FIELDS ub.x-abc-analysis.abc-des ~
x-abc-analysis.abc-name x-criterion-analysis.cral-name
&Scoped-define DISPLAYED-TABLES ub.x-abc-analysis x-abc-analysis ~
x-criterion-analysis
&Scoped-define FIRST-DISPLAYED-TABLE ub.x-abc-analysis
&Scoped-define SECOND-DISPLAYED-TABLE x-abc-analysis
&Scoped-define THIRD-DISPLAYED-TABLE x-criterion-analysis
&Scoped-Define DISPLAYED-OBJECTS mark-num v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_abc-analysis-doc FOR  x-abc-analysis-doc   )  FORWARD.

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
DEFINE new shared QUERY BROWSE-ABC FOR
      x-abc-analysis,
      x-criterion-analysis SCROLLING.

DEFINE QUERY BROWSE-obj FOR
      x-abc-analysis-obj SCROLLING.

DEFINE QUERY BROWSE-period FOR
      x-abc-analysis-period SCROLLING.

DEFINE QUERY BROWSE-type-doc FOR
      x-abc-analysis-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-ABC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-ABC Dialog-Frame _FREEFORM
  QUERY BROWSE-ABC NO-LOCK DISPLAY
      mark-string ( recid( x-abc-analysis), p-rid-list )  COLUMN-LABEL "*" FORMAT "X(1)":U
      x-abc-analysis.abc-name                         COLUMN-LABEL "Наименование" FORMAT "X(30)":U WIDTH 20
      x-criterion-analysis.cral-name                  COLUMN-LABEL "Критерий!анализа" FORMAT "X(55)":U WIDTH 20
     {&cop-l4}          COLUMN-LABEL "A%" FORMAT ">>.<":U WIDTH 4
     {&cop-l5}  @ v-b   COLUMN-LABEL "B%" FORMAT ">>.<":U WIDTH 4
     {&cop-l6}  @ v-c   COLUMN-LABEL "C%" FORMAT ">>.<":U WIDTH 4
     {&cop-l7}  @ v-d   COLUMN-LABEL "D%" FORMAT ">>.<":U WIDTH 4
     {&cop-l8}  @ v-e   COLUMN-LABEL "E%" FORMAT ">>.<":U WIDTH 4
     {&cop-l9}  @ v-f   COLUMN-LABEL "F%" FORMAT ">>.<":U WIDTH 4
      x-abc-analysis.abc-string-obj                   COLUMN-LABEL "Строка!объектов" FORMAT "X(30)":U WIDTH 10
      x-abc-analysis.abc-string-period                COLUMN-LABEL "Строка!периодов" FORMAT "X(30)":U WIDTH 10
      x-abc-analysis.abc-string-doc                   COLUMN-LABEL "Строка!документов" FORMAT "X(30)":U WIDTH 10
      x-abc-analysis.abc-date-create                  COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (x-abc-analysis.abc-time-create,'HH:MM') COLUMN-LABEL "Время!созд" FORMAT "x(5)":U WIDTH 5
      x-abc-analysis.abc-db-num-create                COLUMN-LABEL "БД" FORMAT ">>>>9":U
      x-abc-analysis.abc-who-create                   COLUMN-LABEL "Кто провел!анализ" FORMAT "X(15)":U WIDTH 10
      v-def   COLUMN-LABEL "d!e!f" FORMAT "x(1)":U WIDTH 1
      x-abc-analysis.abc-id                           COLUMN-LABEL "Внутренний!№" FORMAT ">>>>>>>>>9":U
  ENABLE
      x-abc-analysis.abc-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 11 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _STRUCTURED
  QUERY BROWSE-obj NO-LOCK DISPLAY
      x-abc-analysis-obj.obj-type FORMAT "X(3)":U
      x-abc-analysis-obj.obj-code FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13 BY 6.75
         TITLE "Объекты" FIT-LAST-COLUMN TOOLTIP "Объекты АВС анализа".

DEFINE BROWSE BROWSE-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-period Dialog-Frame _STRUCTURED
  QUERY BROWSE-period NO-LOCK DISPLAY
      x-abc-analysis-period.abcp-start COLUMN-LABEL "Начало" FORMAT "99/99/99":U
      x-abc-analysis-period.abcp-end COLUMN-LABEL "Конец" FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20 BY 6.75
         TITLE "Интервалы анализа" FIT-LAST-COLUMN TOOLTIP "Интервалы анализа".

DEFINE BROWSE BROWSE-type-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-type-doc Dialog-Frame _STRUCTURED
  QUERY BROWSE-type-doc NO-LOCK DISPLAY
      f-name-doc ( buffer x-abc-analysis-doc) COLUMN-LABEL "Тип документа" FORMAT "x(22)":U
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
     BROWSE-ABC AT ROW 3 COL 1
     BROWSE-obj AT ROW 16.25 COL 2
     BROWSE-period AT ROW 16.25 COL 15
     BROWSE-type-doc AT ROW 16.25 COL 35
     ub.x-abc-analysis.abc-des AT ROW 16.25 COL 60.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 37.88 BY 6.79 TOOLTIP "Описание анализа"
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL
     x-abc-analysis.abc-name AT ROW 14.21 COL 2 NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 72.5 BY .67 TOOLTIP "Наименование анализа"
          FGCOLOR 4
     v-user-name AT ROW 14.21 COL 80.5 COLON-ALIGNED WIDGET-ID 2
     x-criterion-analysis.cral-name AT ROW 15.25 COL 1.5 NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 96.5 BY .67 TOOLTIP "Критерий анализа"
          FGCOLOR 4
     SPACE(0.38) SKIP(7.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список ABC-анализов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-abc-analysis B "NEW SHARED" ? ub abc-analysis
      TABLE: x-abc-analysis-doc B "?" ? ub abc-analysis-doc
      TABLE: x-abc-analysis-obj B "?" ? ub abc-analysis-obj
      TABLE: x-abc-analysis-period B "?" ? ub abc-analysis-period
      TABLE: x-criterion-analysis B "NEW SHARED" ? ub criterion-analysis
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-ABC B-Help Dialog-Frame */
/* BROWSE-TAB BROWSE-obj BROWSE-ABC Dialog-Frame */
/* BROWSE-TAB BROWSE-period BROWSE-obj Dialog-Frame */
/* BROWSE-TAB BROWSE-type-doc BROWSE-period Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN x-abc-analysis.abc-name IN FRAME Dialog-Frame
   ALIGN-L EXP-FORMAT                                                   */
/* SETTINGS FOR BUTTON B-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       BROWSE-ABC:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* SETTINGS FOR FILL-IN x-criterion-analysis.cral-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-FORMAT                                         */
ASSIGN
       x-criterion-analysis.cral-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-ABC
/* Query rebuild information for BROWSE BROWSE-ABC
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x-abc-analysis NO-LOCK,
      EACH x-criterion-analysis OF x-abc-analysis NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-ABC */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-obj
/* Query rebuild information for BROWSE BROWSE-obj
     _TblList          = "x-abc-analysis-obj"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
x-abc-analysis-obj.db-num = x-abc-analysis.db-num"
     _FldNameList[1]   = Temp-Tables.x-abc-analysis-obj.obj-type
     _FldNameList[2]   = Temp-Tables.x-abc-analysis-obj.obj-code
     _Query            is OPENED
*/  /* BROWSE BROWSE-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-period
/* Query rebuild information for BROWSE BROWSE-period
     _TblList          = "x-abc-analysis-period"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and
x-abc-analysis-period.db-num = x-abc-analysis.db-num"
     _FldNameList[1]   > Temp-Tables.x-abc-analysis-period.abcp-start
"x-abc-analysis-period.abcp-start" "Начало" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.x-abc-analysis-period.abcp-end
"x-abc-analysis-period.abcp-end" "Конец" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-period */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-type-doc
/* Query rebuild information for BROWSE BROWSE-type-doc
     _TblList          = "x-abc-analysis-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
x-abc-analysis-doc.db-num = x-abc-analysis.db-num"
     _FldNameList[1]   > "_<CALC>"
"f-name-doc ( buffer x-abc-analysis-doc)" "Тип документа" "x(22)" ? ? ? ? ? ? ? no ? no no "22" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список ABC-анализов */
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

  RUN proc-add (output loc-doc-rec ) no-error  .
  if error-status :error then message
  error-status :get-message(1)
  return-value .

  if loc-doc-rec <> ? THEN DO:
      RUn OpenBR in this-procedure .
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

   run ref/abcanali.w
     ( INPUT parParentProc ,
       INPUT  {&update} ,
       INPUT {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.abc-id ,
       INPUT {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num ,
       input-output loc-doc-rec
       ) .
   /*loc#log = {&BROWSE-NAME}:REFRESH() . */
   run OpenBR .
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
define variable v-log as logical   no-undo .
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
    v-log
  }
   if v-log = false then return no-apply.
    message "Удалить АВС анализ ?"
      view-as alert-box question
      buttons yes-no
      update g-log as logical.
    if g-log = false then return no-apply.
    run waitfram-show ("Ждите...").
    run proc-b-del in this-procedure no-error.
    if error-status:error then do:
          run waitfram-hide .
          return no-apply.
       end.
    run waitfram-hide .

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
   run ref/abcanali.w
   ( input parparentproc ,
     input {&lookup} ,
     input {&first-table-in-query-{&browse-name}}.abc-id ,
     input {&first-table-in-query-{&browse-name}}.db-num ,
     input-output loc-doc-rec ) .
   loc#log = {&BROWSE-NAME}:refresh() .
   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
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
  p-rid-list = "" .
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column
    v-list        = column-handle:label + "#"
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.

   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .

   repeat v-i = 1 to {&browse-name}:num-columns :
      v-elem = entry( v-i, v-list , "#") .

      v-pos = lookup( v-elem , {&head-col} , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.

   define variable v-list-str as character no-undo .

   v-list-str = "" .
   repeat v-i = 1 to num-entries(v-list-new) :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 1 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim(v-list-str ,",")  +  {&delim-par}
              + string(decimal( {&cop-l2}:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( {&cop-l3}:width     in browse {&browse-name})) +  {&delim-par}  .

run uf-set in this-procedure(
    input  {&uf-list-abc}
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "uf-set"
      view-as alert-box error
    .


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


&Scoped-define BROWSE-NAME BROWSE-ABC
&Scoped-define SELF-NAME BROWSE-ABC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ABC Dialog-Frame
ON ROW-DISPLAY OF BROWSE-ABC IN FRAME Dialog-Frame
DO:
define variable  p-abc-id   as integer   no-undo .
define variable  p-db-num   as integer   no-undo .

   IF AVAILABLE x-abc-analysis THEN DO :
      v-def = "" .
          run find-def-analysis-obj in this-procedure
          ( input  "abc"
          ,input  p-curr-obj-type
          ,input  p-curr-obj-code
          ,output p-abc-id
          ,output p-db-num   ) .

       if p-abc-id = x-abc-analysis.abc-id and p-db-num = x-abc-analysis.db-num
          then v-def = "x" .
          else "" .
       IF  x-criterion-analysis.cral-status <> 0 THEN
        ASSIGN
          x-abc-analysis.abc-name:fgcolor in browse {&browse-name} = DARK_GRAY_COLOR
          x-criterion-analysis.cral-name:fgcolor in browse {&browse-name} = DARK_GRAY_COLOR
        .
       ELSE
        ASSIGN
          x-abc-analysis.abc-name:fgcolor in browse {&browse-name} = ?
          x-criterion-analysis.cral-name:fgcolor in browse {&browse-name} = ?
        .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ABC Dialog-Frame
ON VALUE-CHANGED OF BROWSE-ABC IN FRAME Dialog-Frame
DO:
/* message x-abc-analysis.abc-name . */

    IF AVAILABLE x-abc-analysis THEN DO :
          { gbl/usrfulnm.i
    x-abc-analysis.abc-who-create
    v-user-name }

        DISPLAY x-abc-analysis.abc-des
                x-abc-analysis.abc-name
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
{ gbl/setfltnm.i no-button}
{ gbl/app_help.i }
{ gbl/srt-clmd.i
  &browse-name   = "{&browse-name}"
  &frame-name    = "{&frame-name}"
  &table-name    = x-abc-analysis
  &label-clmn_1  = "{&col-l1}"
  &label-clmn_2  = "{&col-l2}"
  &label-clmn_3  = "{&col-l3}"
  &label-clmn_4  = "{&col-l4}"
  &label-clmn_5  = "{&col-l5}"
  &label-clmn_6  = "{&col-l6}"
  &label-clmn_7  = "{&col-l7}"
  &label-clmn_8  = "{&col-l8}"
  &label-clmn_9  = "{&col-l9}"
  &label-clmn_10 = "{&col-l10}"
  &label-clmn_11 = "{&col-l11}"
  &label-clmn_12 = "{&col-l12}"
  &label-clmn_13 = "{&col-l13}"
  &label-clmn_14 = "{&col-l14}"
  &label-clmn_15 = "{&col-l15}"
  &label-clmn_16 = "{&col-l16}"
  &label-clmn_17 = "{&col-l17}"
  &label-clmn_18 = "{&col-l18}"
  &sort-clmn_1   = "{&cop-l1}"
  &dyn_sort-clmn_1   = "{&dyn_cop-l1}"
  &sort-clmn_2   = "{&cop-l2}"
  &sort-clmn_3   = "{&cop-l3}"
  &sort-clmn_4   = "{&cop-l4}"
  &sort-clmn_5   = "{&cop-l5}"
  &sort-clmn_6   = "{&cop-l6}"
  &sort-clmn_7   = "{&cop-l7}"
  &sort-clmn_8   = "{&cop-l8}"
  &sort-clmn_9   = "{&cop-l9}"
  &sort-clmn_10  = "{&cop-l10}"
  &sort-clmn_11  = "{&cop-l11}"
  &sort-clmn_12  = "{&cop-l12}"
  &sort-clmn_13  = "{&cop-l13}"
  &sort-clmn_14  = "{&cop-l14}"
  &sort-clmn_15  = "{&cop-l15}"
  &sort-clmn_16  = "{&cop-l16}"
  &sort-clmn_18  = "{&cop-l18}"
  &open-query    = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}
x-abc-analysis.abc-who-create:visible in browse {&browse-name}  = false .
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/curdbnum.i v-db-num }
  x-abc-analysis.abc-des:read-only  in frame {&frame-name} = true.
  x-abc-analysis.abc-name:read-only in frame {&frame-name} = true.
  x-abc-analysis.abc-name:read-only in browse {&browse-name}  = true.

  run my_enable in this-procedure .

  { gbl/mv-clmn.i
    &ext-col = 18
    &start-column = 2
    &frame-name = {&frame-name}
    &browse-name = {&browse-name}
    &prev-order-column_1 = v-order-col
    &prev-order-column-condition_1 = " true = true  "
  }
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
RUN disable_UI in this-procedure .

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
  IF AVAILABLE x-abc-analysis THEN
    DISPLAY x-abc-analysis.abc-des x-abc-analysis.abc-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lookup B-print B-Help BROWSE-ABC
         BROWSE-obj BROWSE-period BROWSE-type-doc x-abc-analysis.abc-des
         mark-num x-abc-analysis.abc-name v-user-name
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
define variable  par-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.

   case par-abc-type :
   when 'ABC':U
   then do:
        assign
            {&copv-l7}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
            {&copv-l8}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
            {&copv-l9}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
        .

   end.

   when 'ABCD':U
   then do:
        assign
            {&copv-l8}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
            {&copv-l9}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
        .

   end.

   when 'ABCDE':U
   then do:
        assign
            {&copv-l9}:VISIBLE IN BROWSE BROWSE-ABC = FALSE
        .

   end.
   when 'ABCDEF':U
   then do:

   end.

   otherwise do:
     message "Не верно задан параметр abc-type " par-abc-type view-as alert-box error .
   end.
   end case.
   {&cop-l2}:resizable in browse BROWSE-ABC = true .
   {&cop-l3}:resizable in browse BROWSE-ABC = true .
   {&cop-l2}:width     in browse BROWSE-ABC   = v-size-col1 .
   {&cop-l3}:width     in browse BROWSE-ABC   = v-size-col2 .


  ENABLE b-quit
         B-mark      when LOOKUP("b-mark":U, p-bttn ) > 0
         mark-num
         B-sel       when LOOKUP("b-sel":U, p-bttn ) > 0
         B-add       when LOOKUP("b-add":U, p-bttn ) > 0
         B-del       when LOOKUP("b-del":U, p-bttn ) > 0
         B-lookup
         B-print
         B-Help
         browse-abc
         browse-obj
         browse-period
         browse-type-doc
         x-abc-analysis.abc-des
         x-abc-analysis.abc-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  RUN OpenBR.
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


&scop flt-open-open-query OPEN QUERY BROWSE-Abc FOR EACH x-abc-analysis

&scop flt-open-dyn_open-query  FOR EACH x-abc-analysis

&scop flt-open-query-handle query BROWSE-Abc:handle

&scop flt-open-find-buffer-name x-abc-analysis

&scop flt-open-open-query-tail , EACH x-criterion-analysis OF x-abc-analysis

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          x-abc-analysis

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer x-abc-analysis for abc-analysis .

&scop flt-open-debug-file

&scop flt-open-waitfram             true


{ gbl/fltopend.i
  &where-cond = " true   "
  &where-cond = " 'true'   "
  &use-ind    = " "
  &by         = " " }

APPLY "ENTRY" TO BROWSE-ABC in frame {&frame-name}.
APPLY "VALUE-CHANGED" TO BROWSE-ABC in frame {&frame-name}.



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

run ref/abcanali.w
  ( input parparentproc ,
    input  {&add-def} ,
    input  ? ,
    input v-db-num ,
    input-output p-doc-rec
    ) .
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
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define variable br-handle as handle NO-UNDO.
define variable g#log  as logical   no-undo .
if not available x-abc-analysis then return error.
 find current x-abc-analysis exclusive-lock no-error .
        if not available x-abc-analysis then do:
          message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1)   skip
                    "Ошибка при определении записи x-abc-analysis"
                    view-as alert-box error .
          return .
        end.

  delete x-abc-analysis .
  br-handle = {&browse-name}:handle in frame {&frame-name} .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    loc-doc-rec = RECID(x-abc-analysis) .
  end.

   RUN OpenBr.
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
            '<TD colspan="13" STYLE="font-size: 14px;">Список ABC-анализов</TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="13" STYLE="font-size: 14px;">Дата печати: ' + string(date_string,"99.99.9999") + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .

     put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH rowspan="2" style="text-align: center;">Наименование</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Критерий анализа</TH>'skip
            '<TH style="text-align: center;">I</TH>'skip
            '<TH style="text-align: center;">II</TH>'skip
            '<TH style="text-align: center;">III</TH>'skip
            '<TH style="text-align: center;">=<</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Строка объектов</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Строка периодов</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Строка документов</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Дата создания</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Время создания</TH>'skip
            '<TH rowspan="2" style="text-align: center;">БД</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Кто провел анализ</TH>'skip
        '</TR>'skip
        '<TR>'skip
            '<TH style="text-align: center;">A%</TH>'skip
            '<TH style="text-align: center;">A%</TH>'skip
            '<TH style="text-align: center;">B%</TH>'skip
            '<TH style="text-align: center;">E%</TH>'skip
        '</TR>'skip
        .

            
     for each x-abc-analysis :
       
put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD style="text-align: center"> ' + string(x-abc-analysis.abc-name) + '</TD>'skip
                                  '<TD style="text-align: center"> ' + string(x-criterion-analysis.cral-name) + '</TD>'skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-abc-analysis.abc-a,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-abc-analysis.abc-a <> ? then fnc-convert-dot-to-colon(x-abc-analysis.abc-a,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-abc-analysis.abc-b,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-abc-analysis.abc-b <> ? then fnc-convert-dot-to-colon(x-abc-analysis.abc-b,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-abc-analysis.double-line-proc,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-abc-analysis.double-line-proc <> ? then fnc-convert-dot-to-colon(x-abc-analysis.double-line-proc,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-abc-analysis.le-proc,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-abc-analysis.le-proc <> ? then fnc-convert-dot-to-colon(x-abc-analysis.le-proc,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD> ' + string(x-abc-analysis.abc-string-obj) + '</TD>'skip
                                  '<TD> ' + string(x-abc-analysis.abc-string-period) + '</TD>'skip
                                  '<TD> ' + string(x-abc-analysis.abc-string-doc) + '</TD>'skip
                                  '<TD> ' + string(x-abc-analysis.abc-date-create,"99/99/99") + '</TD>'skip
                                  '<TD> ' + STRING (x-abc-analysis.abc-time-create,'HH:MM') + '</TD>'skip
                                  '<TD num="0" val="' + fnc-convert-dot-to-colon(x-abc-analysis.abc-db-num-create,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if x-abc-analysis.abc-db-num-create <> ? then fnc-convert-dot-to-colon(x-abc-analysis.abc-db-num-create,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                                  '<TD> ' + STRING (x-abc-analysis.abc-who-create) + '</TD>'skip
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


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_abc-analysis-doc FOR  x-abc-analysis-doc   ) :
    define variable v-ret as character no-undo .
    run get-name-from-ext-type in this-procedure (buf_abc-analysis-doc.abcd-ext-doc-type , no ,  output  v-ret ) .
  RETURN v-ret.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME