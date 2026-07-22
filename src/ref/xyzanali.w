&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER x-criterion-analysis FOR ub.criterion-analysis.
DEFINE TEMP-TABLE x-XYZ-analysis NO-UNDO LIKE ub.XYZ-analysis
field r-goods as integer .
DEFINE TEMP-TABLE x-XYZ-analysis-doc NO-UNDO LIKE ub.XYZ-analysis-doc.
DEFINE TEMP-TABLE x-XYZ-analysis-obj NO-UNDO LIKE ub.XYZ-analysis-obj.
DEFINE TEMP-TABLE x-XYZ-analysis-period NO-UNDO LIKE ub.XYZ-analysis-period.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма задания параметров для формирования XYZанализа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-mode as character no-undo .
define input  parameter p-id     like ub.xyz-analysis.xyz-id no-undo.
define input  parameter p-db-num like ub.xyz-analysis.db-num no-undo.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма задания параметров для формирования XYZанализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-pril.i new }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ rep/gn-extp.i  }
{ ref/def-hash.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ cmp/showinf.i  }

define variable p-rid-list    as  char no-undo .
define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Форма задания параметров для XYZанализа" .
define variable filter-point0 as character no-undo init "Форма_задания_параметров_для_XYZанализа" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define buffer locked_XYZ-analysis for ub.XYZ-analysis.
define variable v-last-code as integer   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define temp-table temp-rez no-undo
field n        as int
field xyz      as character
field Sum-cr   as decimal
field Sum_prc  as decimal
field qnty     as decimal
field qnty_prc as decimal
index pi as primary n
.
define temp-table temp-date no-undo
field date1 as date
field date2 as date
index pi date1
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-XYZ-analysis-obj x-XYZ-analysis-period ~
temp-rez x-XYZ-analysis-doc x-XYZ-analysis x-criterion-analysis ~
x-XYZ-analysis

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


/* Definitions for BROWSE BROWSE-rez                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-rez temp-rez.XYZ temp-rez.Sum-cr temp-rez.Sum_prc temp-rez.qnty temp-rez.qnty_prc
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-rez
&Scoped-define SELF-NAME BROWSE-rez
&Scoped-define QUERY-STRING-BROWSE-rez FOR EACH temp-rez
&Scoped-define OPEN-QUERY-BROWSE-rez OPEN QUERY {&SELF-NAME} FOR EACH temp-rez .
&Scoped-define TABLES-IN-QUERY-BROWSE-rez temp-rez
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-rez temp-rez


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
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame x-XYZ-analysis.xyz-name ~
x-XYZ-analysis.xyz-x x-XYZ-analysis.xyz-z x-abc-analysis.r-goods ~
x-XYZ-analysis.xyz-des x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id ~
x-criterion-analysis.cral-name x-XYZ-analysis.xyz-who-create ~
x-XYZ-analysis.xyz-date-create x-XYZ-analysis.xyz-db-num-create 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame x-XYZ-analysis.xyz-name ~
x-XYZ-analysis.xyz-x x-XYZ-analysis.xyz-z x-abc-analysis.r-goods ~
x-XYZ-analysis.xyz-des x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id ~
x-criterion-analysis.cral-name x-XYZ-analysis.xyz-who-create ~
x-XYZ-analysis.xyz-date-create x-XYZ-analysis.xyz-db-num-create 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame x-XYZ-analysis ~
x-XYZ-analysis x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame x-XYZ-analysis
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame x-XYZ-analysis
&Scoped-define THIRD-ENABLED-TABLE-IN-QUERY-Dialog-Frame x-criterion-analysis
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-obj}~
    ~{&OPEN-QUERY-BROWSE-period}~
    ~{&OPEN-QUERY-BROWSE-rez}~
    ~{&OPEN-QUERY-BROWSE-type-doc}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH x-XYZ-analysis NO-LOCK, ~
      EACH x-criterion-analysis WHERE TRUE /* Join to x-XYZ-analysis incomplete */ NO-LOCK, ~
      EACH x-XYZ-analysis WHERE TRUE /* Join to x-XYZ-analysis incomplete */ NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH x-XYZ-analysis NO-LOCK, ~
      EACH x-criterion-analysis WHERE TRUE /* Join to x-XYZ-analysis incomplete */ NO-LOCK, ~
      EACH x-XYZ-analysis WHERE TRUE /* Join to x-XYZ-analysis incomplete */ NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame x-XYZ-analysis ~
x-criterion-analysis x-XYZ-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame x-XYZ-analysis
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame x-criterion-analysis
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame x-abc-analysis


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS x-XYZ-analysis.xyz-name x-XYZ-analysis.xyz-x ~
x-XYZ-analysis.xyz-z x-XYZ-analysis.r-goods x-XYZ-analysis.xyz-des ~
x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id x-criterion-analysis.cral-name ~
x-XYZ-analysis.xyz-who-create x-XYZ-analysis.xyz-date-create ~
x-XYZ-analysis.xyz-db-num-create 
&Scoped-define ENABLED-TABLES x-XYZ-analysis x-XYZ-analysis ~
x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE x-XYZ-analysis
&Scoped-define SECOND-ENABLED-TABLE x-XYZ-analysis
&Scoped-define THIRD-ENABLED-TABLE x-criterion-analysis
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-save-rang B-save-doc-typd ~
B-rez B-Help B-crt B-add-obj B-del-obj B-add-period B-del-period B-add-doc ~
B-del-doc BROWSE-obj BROWSE-period BROWSE-type-doc B-gds-list BROWSE-rez ~
FILL-IN-1 FILL-IN-2 FILL-IN-9 FILL-IN-3 FILL-IN-10 FILL-rez F-time 
&Scoped-Define DISPLAYED-FIELDS x-XYZ-analysis.xyz-name ~
x-XYZ-analysis.xyz-x x-XYZ-analysis.xyz-z x-XYZ-analysis.r-goods ~
x-XYZ-analysis.xyz-des x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id ~
x-criterion-analysis.cral-name x-XYZ-analysis.xyz-who-create ~
x-XYZ-analysis.xyz-date-create x-XYZ-analysis.xyz-db-num-create 
&Scoped-define DISPLAYED-TABLES x-XYZ-analysis x-XYZ-analysis ~
x-criterion-analysis
&Scoped-define FIRST-DISPLAYED-TABLE x-XYZ-analysis
&Scoped-define SECOND-DISPLAYED-TABLE x-XYZ-analysis
&Scoped-define THIRD-DISPLAYED-TABLE x-criterion-analysis
&Scoped-Define DISPLAYED-OBJECTS v-IN_xyz-y v-IN_xyz-y-2 FILL-IN-1 ~
FILL-IN-2 FILL-IN-9 FILL-IN-3 FILL-IN-10 FILL-rez F-time

/* Custom List Definitions                                              */
/* List-pr,List-2,List-3,List-4,List-5,List-6                           */
&Scoped-define List-pr FILL-IN-1 FILL-IN-2 FILL-IN-9 FILL-IN-3 FILL-IN-10 ~
FILL-rez

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
DEFINE BUTTON B-add-doc
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить типы документов".

DEFINE BUTTON B-add-obj
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить объекты".

DEFINE BUTTON B-add-period
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить период".

DEFINE BUTTON B-crt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Справочник критериев анализа".

DEFINE BUTTON B-del-doc
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить тип документа".

DEFINE BUTTON B-del-obj
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить объект".

DEFINE BUTTON B-del-period
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить период".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Расчет"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-gds-list 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL "?" 
     SIZE 3 BY .88.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rez
     LABEL "Результат анализа"
     SIZE 20 BY 1 TOOLTIP "Просмотр результатов XYZанализа".

DEFINE BUTTON B-save-doc-typd
     LABEL "Сохранить ТД"
     SIZE 15 BY 1 TOOLTIP "Сохранить список типов док-тов(ТД) по выбранным объектам".

DEFINE BUTTON B-save-rang
     LABEL "Сохранить XYZ%"
     SIZE 16.5 BY 1 TOOLTIP "Сохранить соотношение ранжирования(XYZ%) по выбранным объектам".

DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Время создания анализа"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Соотношение ранжирования"
      VIEW-AS TEXT
     SIZE 25.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "% -"
      VIEW-AS TEXT
     SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-rez AS CHARACTER FORMAT "X(256)":U INITIAL "Результат анализа:"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-IN_xyz-y AS DECIMAL FORMAT ">9.9999" INITIAL 0
     LABEL "Y"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-IN_xyz-y-2 AS DECIMAL FORMAT ">9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 8 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-obj FOR
      x-XYZ-analysis-obj SCROLLING.

DEFINE QUERY BROWSE-period FOR
      x-XYZ-analysis-period SCROLLING.

DEFINE QUERY BROWSE-rez FOR
      temp-rez SCROLLING.

DEFINE QUERY BROWSE-type-doc FOR
      x-XYZ-analysis-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      x-XYZ-analysis,
      x-criterion-analysis SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _STRUCTURED
  QUERY BROWSE-obj NO-LOCK DISPLAY
      x-XYZ-analysis-obj.obj-type FORMAT "X(3)":U
      x-XYZ-analysis-obj.obj-code FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 13 BY 7.63
         TITLE "Объекты" EXPANDABLE TOOLTIP "Объекты XYZ анализа".

DEFINE BROWSE BROWSE-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-period Dialog-Frame _STRUCTURED
  QUERY BROWSE-period NO-LOCK DISPLAY
      x-XYZ-analysis-period.XYZp-start COLUMN-LABEL "Начало" FORMAT "99/99/99":U
      x-XYZ-analysis-period.XYZp-end COLUMN-LABEL "Конец" FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20 BY 7.63
         TITLE "Интервалы анализа" EXPANDABLE TOOLTIP "Интервалы анализа".

DEFINE BROWSE BROWSE-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-rez Dialog-Frame _FREEFORM
  QUERY BROWSE-rez DISPLAY
      temp-rez.XYZ       COLUMN-LABEL "X!Y!Z"           FORMAT "x(5)"
      temp-rez.Sum-cr    COLUMN-LABEL "Сумма!группы! "
      temp-rez.Sum_prc   COLUMN-LABEL "Доля!группы! "
      temp-rez.qnty      COLUMN-LABEL "Число!артик.!"
      temp-rez.qnty_prc  COLUMN-LABEL "Распределение!номенклатуры!по группам"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 54 BY 5.75 EXPANDABLE.

DEFINE BROWSE BROWSE-type-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-type-doc Dialog-Frame _STRUCTURED
  QUERY BROWSE-type-doc NO-LOCK DISPLAY
      f-name-doc ( buffer x-XYZ-analysis-doc) COLUMN-LABEL "Тип документа" FORMAT "x(22)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25 BY 7.63
         TITLE "Типы документов" EXPANDABLE TOOLTIP "Типы документов анализа".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-save-rang AT ROW 1 COL 26
     B-save-doc-typd AT ROW 1 COL 42.5
     B-rez AT ROW 1 COL 57.5
     B-Help AT ROW 1 COL 87.5
     x-XYZ-analysis.xyz-name AT ROW 3 COL 3
          LABEL "Название анализа"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
          FGCOLOR 4
     B-crt AT ROW 4 COL 25
     B-add-obj AT ROW 5 COL 1
     B-del-obj AT ROW 5 COL 4
     B-add-period AT ROW 5 COL 14
     B-del-period AT ROW 5 COL 17
     B-add-doc AT ROW 5 COL 34.5
     B-del-doc AT ROW 5 COL 37.5
     BROWSE-obj AT ROW 6.25 COL 1
     BROWSE-period AT ROW 6.25 COL 14
     BROWSE-type-doc AT ROW 6.25 COL 34
     x-XYZ-analysis.xyz-x AT ROW 7.25 COL 68 COLON-ALIGNED
          LABEL "меньше X" FORMAT ">9.9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     x-XYZ-analysis.xyz-z AT ROW 8.5 COL 68 COLON-ALIGNED
          LABEL "больше Z" FORMAT ">9.9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     v-IN_xyz-y AT ROW 10.25 COL 66 COLON-ALIGNED
     v-IN_xyz-y-2 AT ROW 10.25 COL 79 COLON-ALIGNED NO-LABEL
     x-XYZ-analysis.r-goods AT ROW 12 COL 66 NO-LABEL WIDGET-ID 4
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "По всем товарам", 1,
"Выборочно", 2
          SIZE 18.5 BY 1.75
     B-gds-list AT ROW 13 COL 84.38 WIDGET-ID 2
     x-XYZ-analysis.xyz-des AT ROW 14.25 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 96 BY 2.25
     BROWSE-rez AT ROW 17.25 COL 2
     x-XYZ-analysis.xyz-id AT ROW 2.25 COL 19 COLON-ALIGNED
          LABEL "Вн.код XYZ анализа"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-XYZ-analysis.cral-id AT ROW 4.25 COL 19.5 COLON-ALIGNED
          LABEL "Критерий анализа" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 3 BY .67
     x-criterion-analysis.cral-name AT ROW 4.25 COL 27 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 68 BY .67
     FILL-IN-1 AT ROW 6.25 COL 60 NO-LABEL
     FILL-IN-2 AT ROW 7.25 COL 78.5 COLON-ALIGNED NO-LABEL
     FILL-IN-9 AT ROW 8.5 COL 78.5 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 10.25 COL 75 COLON-ALIGNED NO-LABEL
     FILL-IN-10 AT ROW 10.25 COL 87.5 COLON-ALIGNED NO-LABEL
     FILL-rez AT ROW 16.5 COL 1.5 NO-LABEL
     x-XYZ-analysis.xyz-who-create AT ROW 17.75 COL 82 COLON-ALIGNED FORMAT "X(15)"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-XYZ-analysis.xyz-date-create AT ROW 18.5 COL 82 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 13 BY .67
     F-time AT ROW 19.25 COL 82 COLON-ALIGNED
     x-XYZ-analysis.xyz-db-num-create AT ROW 20 COL 82 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 3 BY .67
     SPACE(11.38) SKIP(2.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список XYZ-анализов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-criterion-analysis B "?" NO-UNDO ub ub.criterion-analysis
      TABLE: x-XYZ-analysis T "?" NO-UNDO ub ub.xyz-analysis
      TABLE: x-XYZ-analysis-doc T "?" NO-UNDO ub ub.xyz-analysis-doc
      TABLE: x-XYZ-analysis-obj T "?" NO-UNDO ub ub.xyz-analysis-obj
      TABLE: x-XYZ-analysis-period T "?" NO-UNDO ub ub.xyz-analysis-period
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-obj B-del-doc Dialog-Frame */
/* BROWSE-TAB BROWSE-period BROWSE-obj Dialog-Frame */
/* BROWSE-TAB BROWSE-type-doc BROWSE-period Dialog-Frame */
/* BROWSE-TAB BROWSE-rez xyz-des Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN x-XYZ-analysis.cral-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN x-criterion-analysis.cral-name IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-10 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-9 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-rez IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN v-IN_xyz-y IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-IN_xyz-y-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-who-create IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-x IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN x-XYZ-analysis.xyz-z IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-rez
/* Query rebuild information for BROWSE BROWSE-rez
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-rez .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-rez */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-type-doc
/* Query rebuild information for BROWSE BROWSE-type-doc
     _TblList          = "x-XYZ-analysis-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and
x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num"
     _FldNameList[1]   > "_<CALC>"
"f-name-doc ( buffer x-XYZ-analysis-doc)" "Тип документа" "x(22)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-type-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.x-XYZ-analysis,Temp-Tables.x-criterion-analysis WHERE Temp-Tables.x-XYZ-analysis ...,Temp-Tables.x-abc-analysis WHERE Temp-Tables.x-XYZ-analysis ..."
     _Options          = "no-lock"
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


&Scoped-define SELF-NAME B-add-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-doc Dialog-Frame
ON CHOOSE OF B-add-doc IN FRAME Dialog-Frame /* + */
DO:
define variable  pattr-codes as character no-undo.
define variable pattr-labels as character no-undo.
define variable ppresel-codes as character no-undo.
define variable  psel-codes as character no-undo.
&scop xyz_List       'ee,es,re,rs,we':u
&scop xyz_List-full 'расход внешний,касса продажа,возврат внешний,касса возврат,списание':u

pattr-codes      =  {&xyz_List} .
pattr-labels     =  {&xyz_List-full} .

if p-id = ? then p-id = 1 .
  run gbl/d-list.w (
      "b-sel,b-mark"     ,
      "Расширенный тип"  ,
      pattr-codes        ,
      pattr-labels       ,
      ","                ,
      ppresel-codes /*перечень уже выбранных*/ ,
      OUTPUT  psel-codes /*список*/            ) .

if  psel-codes = "" then return no-apply.
define variable ii as integer   no-undo .
define variable i-all as integer   no-undo .
i-all = num-entries (psel-codes) .

repeat ii = 1 to  i-all :
       find first x-XYZ-analysis-doc where x-XYZ-analysis-doc.XYZd-ext-doc-type = entry(ii, psel-codes ) no-error .
         if not available x-XYZ-analysis-doc   then do:
              create x-XYZ-analysis-doc .
              assign
                x-XYZ-analysis-doc.XYZ-id   = p-id
                x-XYZ-analysis-doc.db-num   = p-db-num
                x-XYZ-analysis-doc.XYZd-ext-doc-type = entry(ii, psel-codes )
              .

         end.
end.

{&OPEN-QUERY-BROWSE-type-doc}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-doc Dialog-Frame
ON return OF B-add-doc IN FRAME Dialog-Frame /* + */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-obj Dialog-Frame
ON CHOOSE OF B-add-obj IN FRAME Dialog-Frame /* + */
DO:
  define variable v-user-select as logical   no-undo .

  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  if p-id = ?
  then do:
    assign
      p-id = 1
    .
  end.

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  for each buf_userobjs_temp-user-obj
  on error undo, return no-apply
  :
    find first x-XYZ-analysis-obj
      where x-XYZ-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type
        and x-XYZ-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code
      no-error .
    if not available x-XYZ-analysis-obj
    then do :
      create x-XYZ-analysis-obj .
      assign
        x-XYZ-analysis-obj.XYZ-id   = p-id
        x-XYZ-analysis-obj.db-num   = p-db-num
        x-XYZ-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type
        x-XYZ-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.
  end.

  {&OPEN-QUERY-BROWSE-obj}

  if x-XYZ-analysis.XYZ-x = 0
  then do:
    run find-hash-obj in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-obj Dialog-Frame
ON return OF B-add-obj IN FRAME Dialog-Frame /* + */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-period Dialog-Frame
ON CHOOSE OF B-add-period IN FRAME Dialog-Frame /* + */
DO:
if p-id = ? then p-id = 1 .
define variable date-1  as date   no-undo .
define variable date-2  as date   no-undo .
define variable v-ok as logical   no-undo .

for each temp-date : delete temp-date . end.

   run ref/div-per.w (
        input-output  table temp-date
          ) .

    for each temp-date :
       find first x-XYZ-analysis-period where
          x-XYZ-analysis-period.XYZp-end   = temp-date.date2 and
          x-XYZ-analysis-period.XYZp-start = temp-date.date1 no-error .
       if not available x-XYZ-analysis-period then do:
        create x-XYZ-analysis-period .
        assign
          x-XYZ-analysis-period.XYZ-id     = p-id
          x-XYZ-analysis-period.db-num     = p-db-num
          x-XYZ-analysis-period.XYZp-end   = temp-date.date2
          x-XYZ-analysis-period.XYZp-start = temp-date.date1
        .
       end.
    end.
  {&OPEN-QUERY-BROWSE-period}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-period Dialog-Frame
ON return OF B-add-period IN FRAME Dialog-Frame /* + */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-crt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-crt Dialog-Frame
ON CHOOSE OF B-crt IN FRAME Dialog-Frame
DO:
define VAR v-rid-list    as  char no-undo .
      DISPLAY
       "" @ x-XYZ-analysis.cral-id
       "" @ x-criterion-analysis.cral-name
      WITH FRAME {&FRAME-NAME}.


run ref/critanal.w (parParentProc,"b-sel", "", OUTPUT v-rid-list ) no-error .
  if error-status :error or  v-rid-list = "" or v-rid-list = ? then do:
     message "Не выбран критерий анализа!" skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error
     .
     return no-apply.
  end.


  find first x-criterion-analysis no-lock where recid(x-criterion-analysis) = integer(v-rid-list) no-error.

      if error-status :error or  v-rid-list = "" or v-rid-list = ? then do:
        message "Не правильно выбран критерий анализа!" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
        .
        return no-apply.
      end.

      if x-criterion-analysis.cral-status <> 0 then do:
        message "Не правильно выбран критерий анализа! Статус критерия должен быть АКТИВНЫЙ ." skip
        view-as alert-box error
        .
        return no-apply.
      end.


   ASSIGN
      x-XYZ-analysis.cral-id = x-criterion-analysis.cral-id
    .
      DISPLAY
        x-XYZ-analysis.cral-id
        x-criterion-analysis.cral-name
      WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-crt Dialog-Frame
ON return OF B-crt IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-doc Dialog-Frame
ON CHOOSE OF B-del-doc IN FRAME Dialog-Frame /* - */
DO:
  IF AVAILABLE x-XYZ-analysis-doc THEN DELETE x-XYZ-analysis-doc.
  {&OPEN-QUERY-BROWSE-type-doc}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-obj Dialog-Frame
ON CHOOSE OF B-del-obj IN FRAME Dialog-Frame /* - */
DO:

 IF AVAILABLE x-XYZ-analysis-obj THEN DELETE x-XYZ-analysis-obj.
{&OPEN-QUERY-BROWSE-obj}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-period Dialog-Frame
ON CHOOSE OF B-del-period IN FRAME Dialog-Frame /* - */
DO:
  IF AVAILABLE x-XYZ-analysis-period THEN DELETE x-XYZ-analysis-period.
  {&OPEN-QUERY-BROWSE-period}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Расчет */
DO:
    run proc-save in this-procedure no-error.
    if error-status:error then do:
        case return-value
        :
        when "cral-id"
          then do:
              apply "CHOOSE" to B-crt IN FRAME Dialog-Frame .
          end.

        when "obj"
          then do:
              apply "CHOOSE" to B-add-obj IN FRAME Dialog-Frame .
          end.

        when "date"
          then do:
           apply "CHOOSE" to B-add-period IN FRAME Dialog-Frame .
          end.
        when "doc"
          then do:

            apply "CHOOSE" to B-add-doc IN FRAME Dialog-Frame .
          end.
        when "period"
          then do:
            apply "CHOOSE" to B-add-period IN FRAME Dialog-Frame .
          end.
        when "XYZ-name"
          then do:
            apply "entry" to x-xyz-analysis.xyz-name IN FRAME Dialog-Frame .

          end.

        otherwise do:
          MESSAGE  RETURN-VALUE view-as alert-box information .
        end.
        end case.
        return no-apply.
    end.


    find first locked_XYZ-analysis no-lock where
                      recid(locked_XYZ-analysis) = p-doc-rec no-error .

    run ref/xyz-a.p  (
         input parparentproc
       , input "xyz":U
       , input locked_XYZ-analysis.XYZ-id
       , input locked_XYZ-analysis.db-num
       , input table x-XYZ-analysis
       , input table x-XYZ-analysis-doc
       , input table x-XYZ-analysis-obj
       , input table x-XYZ-analysis-period )
    no-error.
    if error-status:error then do:
        MESSAGE "Ошибка расчета XYZ анализа"
        error-status :get-message(1)
        return-value
        "456" skip
     .
      return no-apply.
      end.
    run ref/xyz-view.w (
    parParentProc,
    locked_XYZ-analysis.XYZ-id ,
    locked_XYZ-analysis.db-num
    )  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds-list Dialog-Frame
ON CHOOSE OF B-gds-list IN FRAME Dialog-Frame /* ? */
DO:
define variable v-ps as character no-undo .
v-ps = "".
for each gds-list-hist:
  v-ps = v-ps + gds-list-hist.des + {&new-line}.
end.
  run gbl/d-prompt.w (
        'title=':u + "Список товаров" + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=10\':u
      + 'max-chars=1000\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=yes\':u
      , input-output v-ps
      ) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rez Dialog-Frame
ON CHOOSE OF B-rez IN FRAME Dialog-Frame /* Результат анализа */
DO:

  run ref/xyz-view.w (
  parParentProc,
  x-XYZ-analysis.XYZ-id ,
  x-XYZ-analysis.db-num
  ) no-error .
  if error-status :error then
  message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value                 skip
  "Ошибка процедуры XYZ-view.w"
  .
  run make-temp-rez .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save-doc-typd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save-doc-typd Dialog-Frame
ON CHOOSE OF B-save-doc-typd IN FRAME Dialog-Frame /* Сохранить ТД */
DO:
  if not can-find (first x-xyz-analysis-obj no-lock
        where x-xyz-analysis-obj.xyz-id = x-xyz-analysis.xyz-id and
              x-xyz-analysis-obj.db-num = x-xyz-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить список типов документов можно после определения списка объектов." view-as alert-box information .
              return .
  end.

  if not can-find (first x-xyz-analysis-doc no-lock
        where x-xyz-analysis-doc.xyz-id = x-xyz-analysis.xyz-id and
              x-xyz-analysis-doc.db-num = x-xyz-analysis.db-num  ) then do:
              message "Список типов документов для сохранения пуст! Заполните список типов документов." view-as alert-box information .
              return .
  end.


  run waitfram-show ("Ждите...").

  define variable v-list-obj as character no-undo .
  define variable v-list-doc as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-possb-keep-string-doc as logical   no-undo .
  define variable v-string-doc            as character no-undo .
  define variable v-hash-string-doc       as character no-undo .

  define variable v-id as integer   no-undo .
  define variable v-db as integer   no-undo .
  define variable v-recid as recid  no-undo .

  /* создадим строку для сохранения Obj  и Doc */
  v-list-obj = "".
  for each x-xyz-analysis-obj no-lock
      where x-xyz-analysis-obj.xyz-id = x-xyz-analysis.xyz-id and
            x-xyz-analysis-obj.db-num = x-xyz-analysis.db-num  :
            v-list-obj = v-list-obj + x-xyz-analysis-obj.obj-type + string(x-xyz-analysis-obj.obj-code) + "," .
  end.
  v-list-doc = "".

  for each x-xyz-analysis-doc no-lock
      where x-xyz-analysis-doc.xyz-id = x-xyz-analysis.xyz-id and
            x-xyz-analysis-doc.db-num = x-xyz-analysis.db-num  :
            v-list-doc = v-list-doc + x-xyz-analysis-doc.xyzd-ext-doc-type  + "," .
  end.


  run find-from-hash  (
     input v-list-obj
    ,input "doc-XYZ-def"
    ,input "doxd-possb-keep-string-obj"
    ,input "doxd-string-obj"
    ,input "doxd-hash-string-obj"
    ,input "doc-XYZ-def-obj"
    ,output v-recid
    ).

  run update-doc-xyz-def (
     input v-recid
    ,input v-list-obj
    ,input v-list-doc
    ).

  run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save-rang
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save-rang Dialog-Frame
ON CHOOSE OF B-save-rang IN FRAME Dialog-Frame /* Сохранить XYZ% */
DO:
  if not can-find (first x-XYZ-analysis-obj no-lock
        where x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
              x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить ранжирование можно после определения списка объектов." view-as alert-box information .
              return .
  end.
  if  x-XYZ-analysis.XYZ-x  = 0  or  x-XYZ-analysis.XYZ-z = 0  then do:
              message "Ранжирование XYZ не задано !!!" view-as alert-box information .
              return .
  end.
  run waitfram-show in this-procedure  ("Ждите...") .

  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-id as integer   no-undo .
  define variable v-db as integer   no-undo .
  define variable v-recid as recid  no-undo .

  /* создадим строку для сохранения */
  v-list-obj = "".
  for each x-XYZ-analysis-obj no-lock
      where x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num  :
            v-list-obj = v-list-obj + x-XYZ-analysis-obj.obj-type + string(x-XYZ-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  (
     input v-list-obj
    ,input "rang-XYZ-def"
    ,input "raxd-possb-keep-string-obj"
    ,input "raxd-string-obj"
    ,input "raxd-hash-string-obj"
    ,input "rang-XYZ-def-obj"
    ,output v-recid
    ).

  run update-rang-xyz-def (
     input v-recid
    ,input v-list-obj
    ,input x-XYZ-analysis.XYZ-x
    ,input x-XYZ-analysis.XYZ-y
    ,input x-XYZ-analysis.XYZ-z
    ) .

    x-XYZ-analysis.raxd-x = x-XYZ-analysis.XYZ-x .
    x-XYZ-analysis.raxd-y = x-XYZ-analysis.XYZ-y .
    x-XYZ-analysis.raxd-z = x-XYZ-analysis.XYZ-z .


  run waitfram-hide .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-rez
&Scoped-define SELF-NAME BROWSE-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-rez Dialog-Frame
ON ROW-DISPLAY OF BROWSE-rez IN FRAME Dialog-Frame
DO:
  IF AVAILABLE temp-rez THEN DO:
      IF  temp-rez.xyz = "X" THEN DO:
          temp-rez.xyz:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum-cr:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum_prc:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 12 .
      END.

      IF  temp-rez.xyz = "Y" THEN DO:
          temp-rez.xyz:fgcolor      in browse BROWSE-rez = 9 .
          temp-rez.Sum-cr:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 9 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 9 .
      END.



  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.r-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.r-goods Dialog-Frame
ON VALUE-CHANGED OF x-XYZ-analysis.r-goods IN FRAME Dialog-Frame
DO:
    ASSIGN x-XYZ-analysis.r-goods.
    IF x-XYZ-analysis.r-goods = 2 THEN DO:
       run str/gds-list.w (input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-IN_xyz-y-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-IN_xyz-y-2 Dialog-Frame
ON return OF v-IN_xyz-y-2 IN FRAME Dialog-Frame
DO:
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-XYZ-analysis.xyz-des
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-des Dialog-Frame
ON return OF x-XYZ-analysis.xyz-des IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-XYZ-analysis.xyz-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-name Dialog-Frame
ON return OF x-XYZ-analysis.xyz-name IN FRAME Dialog-Frame /* Название анализа */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-XYZ-analysis.xyz-x
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-x Dialog-Frame
ON LEAVE OF x-XYZ-analysis.xyz-x IN FRAME Dialog-Frame /* меньше X */
DO:
    ASSIGN x-XYZ-analysis.XYZ-x
           x-XYZ-analysis.XYZ-z
           .

  run proc-sel-rec in this-procedure
  ( x-XYZ-analysis.XYZ-x ,
  x-XYZ-analysis.XYZ-z)  no-error .
  if error-status :error then message return-value .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-x Dialog-Frame
ON return OF x-XYZ-analysis.xyz-x IN FRAME Dialog-Frame /* меньше X */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-XYZ-analysis.xyz-z
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-z Dialog-Frame
ON LEAVE OF x-XYZ-analysis.xyz-z IN FRAME Dialog-Frame /* больше Z */
DO:
  ASSIGN x-XYZ-analysis.XYZ-x
           x-XYZ-analysis.XYZ-z
           .
  run proc-sel-rec in this-procedure
  ( x-XYZ-analysis.XYZ-x ,
  x-XYZ-analysis.XYZ-z)  no-error .
  if error-status :error then message return-value .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-XYZ-analysis.xyz-z Dialog-Frame
ON return OF x-XYZ-analysis.xyz-z IN FRAME Dialog-Frame /* больше Z */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-obj
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
 { gbl/getcntxt.i get }
 { gbl/curdbnum.i v-db-num }
 define variable loc#log as logical   no-undo .
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
   if not loc#log then return .

  for each x-XYZ-analysis:
    delete x-XYZ-analysis.
  end.

  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_XYZ-analysis /*EXclusive-lock*/ no-lock  where
                  recid(locked_XYZ-analysis) = p-doc-rec no-wait no-error.
      if locked locked_XYZ-analysis then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись XYZ анализа занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_XYZ-analysis no-lock where
                       recid(locked_XYZ-analysis) = p-doc-rec no-error .
      if not avail locked_XYZ-analysis then do:
        find first locked_XYZ-analysis no-lock where
                   locked_XYZ-analysis.db-num = p-db-num and
                   locked_XYZ-analysis.XYZ-id = p-id
                   no-error .
      end.
    end.
    if not available locked_XYZ-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись XYZ анализа"
      view-as alert-box error .
      undo, return error.
    end.
    create x-XYZ-analysis.
    buffer-copy locked_XYZ-analysis to x-XYZ-analysis.
   end.
   else do:
          run cur-time in this-procedure(output v-date, output v-time).
          create x-XYZ-analysis.
          assign
          x-XYZ-analysis.XYZ-id = v-last-code + 1
          x-XYZ-analysis.db-num = v-db-num
          x-XYZ-analysis.XYZ-date-create = v-date
          x-XYZ-analysis.XYZ-time-create = v-time
          x-XYZ-analysis.XYZ-db-num-create = v-db-num
          x-XYZ-analysis.XYZ-who-create  = g#userid
         .
   end.

  run my_enable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus x-XYZ-analysis.XYZ-name.
END.
run disable_ui.

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
  DISPLAY v-IN_xyz-y v-IN_xyz-y-2 FILL-IN-1 FILL-IN-2 FILL-IN-9 FILL-IN-3 
          FILL-IN-10 FILL-rez F-time 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-XYZ-analysis THEN 
    DISPLAY x-XYZ-analysis.r-goods 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-XYZ-analysis THEN
    DISPLAY x-XYZ-analysis.xyz-name x-XYZ-analysis.xyz-x x-XYZ-analysis.xyz-z
          x-XYZ-analysis.xyz-des x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id
          x-XYZ-analysis.xyz-who-create x-XYZ-analysis.xyz-date-create
          x-XYZ-analysis.xyz-db-num-create
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-save-rang B-save-doc-typd B-rez B-Help 
         x-XYZ-analysis.xyz-name B-crt B-add-obj B-del-obj B-add-period 
         B-del-period B-add-doc B-del-doc BROWSE-obj BROWSE-period 
         BROWSE-type-doc x-XYZ-analysis.xyz-x x-XYZ-analysis.xyz-z 
         x-XYZ-analysis.r-goods B-gds-list x-XYZ-analysis.xyz-des BROWSE-rez 
         x-XYZ-analysis.xyz-id x-XYZ-analysis.cral-id 
         x-criterion-analysis.cral-name FILL-IN-1 FILL-IN-2 FILL-IN-9 FILL-IN-3 
         FILL-IN-10 FILL-rez x-XYZ-analysis.xyz-who-create 
         x-XYZ-analysis.xyz-date-create F-time x-XYZ-analysis.xyz-db-num-create 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-hash-obj Dialog-Frame
PROCEDURE find-hash-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-recid as recid     no-undo .


  v-list-obj = "".
  for each x-XYZ-analysis-obj no-lock
      where x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num  :
            v-list-obj = v-list-obj + x-XYZ-analysis-obj.obj-type + string(x-XYZ-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  in this-procedure (
     input v-list-obj
    ,input "rang-XYZ-def"
    ,input "raxd-possb-keep-string-obj"
    ,input "raxd-string-obj"
    ,input "raxd-hash-string-obj"
    ,input "rang-XYZ-def-obj"
    ,output v-recid
    ).

   find first ub.rang-XYZ-def no-lock where
              recid(ub.rang-XYZ-def) = v-recid
              no-error .
    if available ub.rang-XYZ-def then do:
       message "Найдено значение уровней ранжирования для данного списка объектов по умолчанию : "    skip
                ub.rang-XYZ-def.raxd-x "%" skip
                ub.rang-XYZ-def.raxd-z "%" .
       assign
        x-XYZ-analysis.XYZ-x  = ub.rang-XYZ-def.raxd-x
        x-XYZ-analysis.XYZ-y  = ub.rang-XYZ-def.raxd-y
        x-XYZ-analysis.XYZ-z  = ub.rang-XYZ-def.raxd-z
        x-XYZ-analysis.raxd-x = ub.rang-XYZ-def.raxd-x
        x-XYZ-analysis.raxd-y = ub.rang-XYZ-def.raxd-y
        x-XYZ-analysis.raxd-z = ub.rang-XYZ-def.raxd-z
       .

       display x-XYZ-analysis.XYZ-x
               x-XYZ-analysis.XYZ-z
               with frame {&frame-name} .
       apply "LEAVE" to x-XYZ-analysis.XYZ-z  in frame {&frame-name} .
    end.

  run find-from-hash in this-procedure  (
     input v-list-obj
    ,input "doc-XYZ-def"
    ,input "doxd-possb-keep-string-obj"
    ,input "doxd-string-obj"
    ,input "doxd-hash-string-obj"
    ,input "doc-XYZ-def-obj"
    ,output v-recid
    ).
   find first ub.doc-XYZ-def no-lock where
              recid(ub.doc-XYZ-def) = v-recid
              no-error .
    if available ub.doc-XYZ-def then do:
    for each ub.doc-XYZ-def-doc no-lock  where
            ub.doc-XYZ-def-doc.doxd-id = ub.doc-XYZ-def.doxd-id and
            ub.doc-XYZ-def-doc.db-num  = ub.doc-XYZ-def.db-num   :
        create x-XYZ-analysis-doc.
         assign
            x-XYZ-analysis-doc.XYZd-ext-doc-type = ub.doc-XYZ-def-doc.dxdd-ext-doc-type
            x-XYZ-analysis-doc.XYZ-id   = x-XYZ-analysis.XYZ-id
            x-XYZ-analysis-doc.db-num   = x-XYZ-analysis.db-num
         .
        {&OPEN-QUERY-BROWSE-type-doc}
    end.



    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-rez Dialog-Frame
PROCEDURE make-temp-rez :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bb_xyz-analysis for ub.xyz-analysis.
find first bb_xyz-analysis no-lock where
           bb_xyz-analysis.xyz-id = p-id and
           bb_xyz-analysis.db-num = p-db-num
           no-error .
for each temp-rez : delete temp-rez. end.

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 1
    temp-rez.xyz  = "X"
    temp-rez.Sum-cr   = bb_xyz-analysis.xyz-x-sum
    temp-rez.Sum_prc  = bb_xyz-analysis.xyz-x-sum-prc
    temp-rez.qnty     = bb_xyz-analysis.xyz-x-qnty
    temp-rez.qnty_prc = bb_xyz-analysis.xyz-x-prc-qnty
     .

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 2
    temp-rez.xyz  = "Y"
    temp-rez.Sum-cr   = bb_xyz-analysis.xyz-y-sum
    temp-rez.Sum_prc  = bb_xyz-analysis.xyz-y-sum-prc
    temp-rez.qnty     = bb_xyz-analysis.xyz-y-qnty
    temp-rez.qnty_prc = bb_xyz-analysis.xyz-y-prc-qnty
     .

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 3
    temp-rez.xyz  = "Z"
    temp-rez.Sum-cr   = bb_xyz-analysis.xyz-z-sum
    temp-rez.Sum_prc  = bb_xyz-analysis.xyz-z-sum-prc
    temp-rez.qnty     = bb_xyz-analysis.xyz-z-qnty
    temp-rez.qnty_prc = bb_xyz-analysis.xyz-z-prc-qnty
     .


    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 7
    temp-rez.xyz  = "ИТОГО"
    temp-rez.Sum-cr     =
                          bb_xyz-analysis.xyz-x-sum + bb_xyz-analysis.xyz-y-sum +
                          bb_xyz-analysis.xyz-z-sum

    temp-rez.Sum_prc    = 100
    temp-rez.qnty       =
                          bb_xyz-analysis.xyz-x-qnty + bb_xyz-analysis.xyz-y-qnty +
                          bb_xyz-analysis.xyz-z-qnty

    temp-rez.qnty_prc   = 100
     .


{&OPEN-QUERY-BROWSE-rez}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
if p-mode <> {&add-def} then do:
   assign frame {&frame-name}:title = "Просмотр XYZ анализа " .
    for each ub.XYZ-analysis-doc no-lock  where
            ub.XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and
            ub.XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num   :
        create x-XYZ-analysis-doc.
        BUFFER-COPY ub.XYZ-analysis-doc  TO x-XYZ-analysis-doc
            .
    end.


    for each ub.XYZ-analysis-obj no-lock  where
            ub.XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
            ub.XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num   :
        create x-XYZ-analysis-obj.
        BUFFER-COPY ub.XYZ-analysis-obj  TO x-XYZ-analysis-obj.

    end.

    for each ub.XYZ-analysis-period no-lock where
            ub.XYZ-analysis-period.XYZ-id = x-XYZ-analysis.XYZ-id and
            ub.XYZ-analysis-period.db-num = x-XYZ-analysis.db-num   :
        create x-XYZ-analysis-period.
        BUFFER-COPY ub.XYZ-analysis-period TO x-XYZ-analysis-period.
    end.
    run make-temp-rez in this-procedure .
end.


define variable v-user-name as character no-undo .

IF AVAILABLE x-XYZ-analysis THEN DO:
    f-time =  STRING (x-XYZ-analysis.XYZ-time-create,'HH:MM') .
  { gbl/usrfulnm.i
    x-XYZ-analysis.XYZ-who-create
    v-user-name }

    DISPLAY x-XYZ-analysis.XYZ-name
            x-XYZ-analysis.XYZ-x
            x-XYZ-analysis.XYZ-z
          {&list-pr}
          x-XYZ-analysis.XYZ-des
          x-XYZ-analysis.cral-id
          v-user-name  when p-mode <> {&add-def} @ x-XYZ-analysis.XYZ-who-create
          x-XYZ-analysis.XYZ-date-create   when p-mode <> {&add-def}
          f-time                           when p-mode <> {&add-def}
          x-XYZ-analysis.XYZ-db-num-create when p-mode <> {&add-def}
          x-XYZ-analysis.XYZ-id            when p-mode <> {&add-def}
          x-XYZ-analysis.r-goods           when p-mode <> {&add-def}
          b-gds-list                       when p-mode <> {&lookup}
      WITH FRAME Dialog-Frame.

    find first x-criterion-analysis no-lock where x-criterion-analysis.cral-id = x-XYZ-analysis.cral-id no-error .
       IF AVAILABLE x-criterion-analysis THEN
           DISPLAY x-criterion-analysis.cral-name WITH FRAME Dialog-Frame.
 END.
        if p-mode = {&add-def} then do:
        assign frame {&frame-name}:title = "Добавление XYZ анализа " .
        display  ""  @  x-criterion-analysis.cral-name     with frame {&frame-name} .

      end.
      if p-mode = {&lookup} then do:
        assign
          b-quit:label = "&Выход"
          b-quit:col = 1
        .
          hide b-exit in frame {&frame-name}.
          if x-XYZ-analysis.XYZ-x > 0 then
             run proc-sel-rec in this-procedure (x-XYZ-analysis.XYZ-x , x-XYZ-analysis.XYZ-z)  .
      end.


      ENABLE
      B-exit when p-mode <> {&lookup}
      b-quit
      B-Help
      x-XYZ-analysis.XYZ-name when p-mode <> {&lookup}
      B-crt                   when p-mode <> {&lookup}
      x-XYZ-analysis.XYZ-x    when p-mode <> {&lookup}
      x-XYZ-analysis.XYZ-z    when p-mode <> {&lookup}
      x-XYZ-analysis.r-goods  when p-mode <> {&lookup}
      b-gds-list              when p-mode <> {&lookup}

      FILL-IN-1
      B-add-obj               when p-mode <> {&lookup}
      B-del-obj               when p-mode <> {&lookup}
      B-add-period            when p-mode <> {&lookup}
      B-del-period            when p-mode <> {&lookup}
      B-add-doc               when p-mode <> {&lookup}
      B-del-doc               when p-mode <> {&lookup}
      x-XYZ-analysis.XYZ-des  when p-mode <> {&lookup}
      BROWSE-obj
      BROWSE-period
      BROWSE-type-doc
      B-save-doc-typd   when p-mode <> {&lookup}
      B-save-rang       when p-mode <> {&lookup}
      b-rez             when p-mode = {&lookup}
      WITH FRAME Dialog-Frame.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry =  true
  .

  do with frame {&frame-name} :
    if  x-XYZ-analysis.XYZ-name  :handle = p-widget-handle then do:    if B-crt                  :sensitive then do: apply "entry":u to B-crt                  .  return . end. end.
    if  B-crt              :handle = p-widget-handle then do:          if B-add-obj              :sensitive then do: apply "entry":u to B-add-obj              .  return . end. end.
    if  B-add-obj          :handle = p-widget-handle then do:          if B-add-period           :sensitive then do: apply "entry":u to B-add-period           .  return . end. end.
    if  B-add-period         :handle = p-widget-handle then do:        if B-add-doc              :sensitive then do: apply "entry":u to B-add-doc              .  return . end. end.
    if  B-add-doc        :handle = p-widget-handle then do:            if x-XYZ-analysis.XYZ-x   :sensitive then do: apply "entry":u to x-XYZ-analysis.XYZ-x   .  return . end. end.
    if  x-XYZ-analysis.XYZ-x        :handle = p-widget-handle then do: if x-XYZ-analysis.XYZ-z   :sensitive then do: apply "entry":u to x-XYZ-analysis.XYZ-z   .  return . end. end.
    if  x-XYZ-analysis.XYZ-z        :handle = p-widget-handle then do: if x-XYZ-analysis.XYZ-des :sensitive then do: apply "entry":u to x-XYZ-analysis.XYZ-des .  return . end. end.
    if  x-XYZ-analysis.XYZ-des      :handle = p-widget-handle then do: if B-exit                 :sensitive then do: apply "entry":u to B-exit                 .  return . end. end.
  end. /* do with frame */

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
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if p-mode = {&lookup} then do:
    return error.
end.

if not available x-XYZ-analysis then do:
    create x-XYZ-analysis.
end.

assign
frame {&frame-name}
x-XYZ-analysis.XYZ-id
x-XYZ-analysis.XYZ-name
x-XYZ-analysis.XYZ-x
x-XYZ-analysis.XYZ-z
x-XYZ-analysis.r-goods
.
IF  x-XYZ-analysis.XYZ-x  >= 100 or
    x-XYZ-analysis.XYZ-z >= 100  or
    x-XYZ-analysis.XYZ-x <= 0    or
    x-XYZ-analysis.XYZ-z <= 0
    THEN DO:
    return ERROR "Не верно установлено соотношение ранжирования ".

END.

IF x-XYZ-analysis.XYZ-x  >= x-XYZ-analysis.XYZ-z
    THEN DO:
    return ERROR "Уровень X должен быть меньше уровня Z " .
END.

assign
  x-xyz-analysis.xyz-des = x-xyz-analysis.xyz-des:screen-value.
 run ref/xyzanal1.p (
                input-output p-doc-rec
                ,p-mode
                ,x-XYZ-analysis.XYZ-id
                ,v-db-num
                ,x-XYZ-analysis.cral-id
                ,x-XYZ-analysis.XYZ-name
                ,x-XYZ-analysis.XYZ-des
                ,x-XYZ-analysis.raxd-x
                ,x-XYZ-analysis.raxd-y
                ,x-XYZ-analysis.raxd-z
                ,x-XYZ-analysis.XYZ-x
                ,x-XYZ-analysis.XYZ-y
                ,x-XYZ-analysis.XYZ-z
                ,x-XYZ-analysis.xyz-x-prc-qnty
                ,x-XYZ-analysis.xyz-x-qnty
                ,x-XYZ-analysis.xyz-x-sum-prc
                ,x-XYZ-analysis.xyz-x-sum
                ,x-XYZ-analysis.xyz-y-prc-qnty
                ,x-XYZ-analysis.xyz-y-qnty
                ,x-XYZ-analysis.xyz-y-sum-prc
                ,x-XYZ-analysis.xyz-y-sum
                ,x-XYZ-analysis.xyz-z-prc-qnty
                ,x-XYZ-analysis.xyz-z-qnty
                ,x-XYZ-analysis.xyz-z-sum-prc
                ,x-XYZ-analysis.xyz-z-sum
                ,x-XYZ-analysis.r-goods
                ,table x-XYZ-analysis-doc
                ,table x-XYZ-analysis-obj
                ,table x-XYZ-analysis-period
                            )
no-error .
if error-status :error then do:
  /* message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    return-value
    "Ошибка при сохранении записи"
    view-as alert-box error . */
    return error return-value .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-rec Dialog-Frame
PROCEDURE proc-sel-rec :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-XYZ-x as decimal   no-undo .
define input  parameter p-XYZ-z as decimal   no-undo .


define variable v-c as decimal   no-undo .
define variable v-a as decimal   no-undo .
define variable v-b as decimal   no-undo .
define variable v-a-pr as decimal   no-undo .
define variable v-b-pr as decimal   no-undo .

DISPLAY
  p-XYZ-x @ v-IN_xyz-y
  p-XYZ-z @ v-IN_xyz-y-2
  WITH FRAME {&FRAME-NAME} .
/*
 assign
  v-c    = rect-c:WIDTH-CHARS IN FRAME {&FRAME-NAME}
  v-a-pr = p-XYZ-x
  v-b-pr = p-XYZ-z
 .

 if v-a-pr =  v-b-pr then do:
    return error "Уровни ранжирования X и Y должны быть разными  !!! "  .
 end.

 if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
    return error "Уровень ранжирования X должны быть меньше Y  !!! "  .
 end.


 if v-a-pr > 100 then do:
    return error "Уровень ранжирования X должны быть меньше 100%  !!! "  .
 end.

 if v-b-pr > 100 then do:
    return error "Уровень ранжирования Y должны быть меньше 100%  !!! "  .
 end.
 v-a = v-a-pr * v-c / 100 .
 v-b = v-b-pr * v-c / 100 .
 if v-a > 0 then
    rect-a:WIDTH-CHARS =  v-a.
 if v-b > 0 then
    rect-b:WIDTH-CHARS =  v-b.
DISPLAY
  rect-c
  rect-b when v-b > 0
  rect-a /* when v-a > 0 */
WITH FRAME {&FRAME-NAME}.
DISPLAY
  rect-a
WITH FRAME {&FRAME-NAME}.
assign

  f-a = "X=" + string(v-a-pr)
  f-b = "Z=" + string(v-b-pr)

.
DISPLAY

  f-b when v-b > 0
  f-a when v-a > 0
WITH FRAME {&FRAME-NAME}.

  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_XYZ-analysis-doc FOR  x-XYZ-analysis-doc   ) :
  define variable v-ret as character no-undo .
  run get-name-from-ext-type in this-procedure ( buf_xyz-analysis-doc.xyzd-ext-doc-type , no , output v-ret ) .

  RETURN v-ret.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME