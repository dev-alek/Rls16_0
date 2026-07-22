&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE x-abc-analysis NO-UNDO LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-abc-analysis-doc NO-UNDO LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-abc-analysis-obj NO-UNDO LIKE ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-abc-analysis-period NO-UNDO LIKE ub.abc-analysis-period.
DEFINE BUFFER x-criterion-analysis FOR ub.criterion-analysis.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма задания параметров для формирования АВСанализа

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

define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode as character no-undo .
define input  parameter p-id     like ub.abc-analysis.abc-id NO-UNDO.
define input  parameter p-db-num like ub.abc-analysis.db-num NO-UNDO.
define input-output parameter p-doc-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма задания параметров для формирования АВСанализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-pril.i new }
{ cmp/showinf.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ rep/gn-extp.i  }
{ ref/def-hash.i }
{ gbl/thbjattr.i }

define variable p-rid-list    as  char no-undo .
define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Форма задания параметров для АВСанализа" .
define variable filter-point0 as character no-undo init "Форма_задания_параметров_для_АВСанализа" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define buffer locked_abc-analysis for ub.abc-analysis.
define variable v-last-code as integer   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define variable par-abc-mode as character no-undo .
define variable par-abc-one  as character no-undo .
define variable par-abc-two  as character no-undo .
define variable par-type     as character no-undo .
define variable v-abc-one as character no-undo .

define temp-table temp-rez no-undo
field n        as int
field ABC      as character
field Sum-cr   as decimal
field Sum_prc  as decimal
field qnty     as decimal
field qnty_prc as decimal
index pi as primary n
.

define variable par-abc-type as character no-undo .

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
&Scoped-define INTERNAL-TABLES x-abc-analysis-obj x-abc-analysis-period ~
temp-rez x-abc-analysis-doc x-abc-analysis x-criterion-analysis

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


/* Definitions for BROWSE BROWSE-rez                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-rez temp-rez.ABC temp-rez.Sum-cr temp-rez.Sum_prc temp-rez.qnty temp-rez.qnty_prc
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-rez
&Scoped-define SELF-NAME BROWSE-rez
&Scoped-define QUERY-STRING-BROWSE-rez FOR EACH temp-rez
&Scoped-define OPEN-QUERY-BROWSE-rez OPEN QUERY {&SELF-NAME} FOR EACH temp-rez .
&Scoped-define TABLES-IN-QUERY-BROWSE-rez temp-rez
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-rez temp-rez


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
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame x-abc-analysis.double-line-proc ~
x-abc-analysis.abc-type x-abc-analysis.LE-proc x-abc-analysis.r-goods ~
x-abc-analysis.abc-name x-abc-analysis.abc-a x-abc-analysis.abc-b ~
x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e ~
x-abc-analysis.abc-des x-abc-analysis.abc-id x-abc-analysis.cral-id ~
x-criterion-analysis.cral-name x-abc-analysis.abc-who-create ~
x-abc-analysis.abc-date-create x-abc-analysis.abc-db-num-create
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
x-abc-analysis.double-line-proc x-abc-analysis.abc-type ~
x-abc-analysis.LE-proc x-abc-analysis.r-goods x-abc-analysis.abc-name ~
x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c ~
x-abc-analysis.abc-d x-abc-analysis.abc-e x-abc-analysis.abc-des ~
x-abc-analysis.abc-id x-abc-analysis.cral-id x-criterion-analysis.cral-name ~
x-abc-analysis.abc-who-create x-abc-analysis.abc-date-create ~
x-abc-analysis.abc-db-num-create
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame x-abc-analysis ~
x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame x-abc-analysis
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame x-criterion-analysis
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-obj}~
    ~{&OPEN-QUERY-BROWSE-period}~
    ~{&OPEN-QUERY-BROWSE-rez}~
    ~{&OPEN-QUERY-BROWSE-type-doc}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH x-abc-analysis NO-LOCK, ~
      EACH x-criterion-analysis WHERE TRUE /* Join to x-abc-analysis incomplete */ NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH x-abc-analysis NO-LOCK, ~
      EACH x-criterion-analysis WHERE TRUE /* Join to x-abc-analysis incomplete */ NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame x-abc-analysis ~
x-criterion-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame x-abc-analysis
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame x-criterion-analysis


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS x-abc-analysis.double-line-proc ~
x-abc-analysis.abc-type x-abc-analysis.LE-proc x-abc-analysis.r-goods ~
x-abc-analysis.abc-name x-abc-analysis.abc-a x-abc-analysis.abc-b ~
x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e ~
x-abc-analysis.abc-des x-abc-analysis.abc-id x-abc-analysis.cral-id ~
x-criterion-analysis.cral-name x-abc-analysis.abc-who-create ~
x-abc-analysis.abc-date-create x-abc-analysis.abc-db-num-create
&Scoped-define ENABLED-TABLES x-abc-analysis x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE x-abc-analysis
&Scoped-define SECOND-ENABLED-TABLE x-criterion-analysis
&Scoped-Define ENABLED-OBJECTS BROWSE-rez FILL-IN-11 B-gds-list b-quit ~
B-exit B-save-rang B-save-doc-typd B-rez B-Help B-crt B-add-obj B-del-obj ~
B-add-period B-del-period B-add-doc B-del-doc BROWSE-obj BROWSE-period ~
BROWSE-type-doc FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6 FILL-IN-3 FILL-IN-5 ~
FILL-rez F-time FILL-IN-7 RECT-f RECT-E RECT-D RECT-C RECT-B RECT-A
&Scoped-Define DISPLAYED-FIELDS x-abc-analysis.double-line-proc ~
x-abc-analysis.abc-type x-abc-analysis.LE-proc x-abc-analysis.r-goods ~
x-abc-analysis.abc-name x-abc-analysis.abc-a x-abc-analysis.abc-b ~
x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e ~
x-abc-analysis.abc-des x-abc-analysis.abc-id x-abc-analysis.cral-id ~
x-criterion-analysis.cral-name x-abc-analysis.abc-who-create ~
x-abc-analysis.abc-date-create x-abc-analysis.abc-db-num-create
&Scoped-define DISPLAYED-TABLES x-abc-analysis x-criterion-analysis
&Scoped-define FIRST-DISPLAYED-TABLE x-abc-analysis
&Scoped-define SECOND-DISPLAYED-TABLE x-criterion-analysis
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-11 FILL-IN-1 FILL-IN-2 FILL-IN-4 ~
FILL-IN-6 FILL-IN-3 FILL-IN-5 FILL-rez F-time FILL-IN-7

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-abc,fill-ins                        */
&Scoped-define List-abc x-abc-analysis.abc-a x-abc-analysis.abc-b ~
x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e
&Scoped-define fill-ins FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6 FILL-IN-3 ~
FILL-IN-5 FILL-IN-7

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
     LABEL "Товары"
     SIZE 10 BY 1 TOOLTIP "Просмотр результатов АВСанализа по товарам".

DEFINE BUTTON B-save-doc-typd
     LABEL "Сохранить ТД"
     SIZE 15 BY 1 TOOLTIP "Сохранить список типов док-тов(ТД) по выбранным объектам".

DEFINE BUTTON B-save-rang
     LABEL "Сохранить АВС%"
     SIZE 16.5 BY 1 TOOLTIP "Сохранить соотношение ранжирования(АВС%) по выбранным объектам".

DEFINE VARIABLE F-a AS CHARACTER FORMAT "X(256)":U INITIAL "А=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-b AS CHARACTER FORMAT "X(256)":U INITIAL "B=9999"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-c AS CHARACTER FORMAT "X(256)":U INITIAL "C=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE F-d AS CHARACTER FORMAT "X(256)":U INITIAL "D=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE F-E AS CHARACTER FORMAT "X(256)":U INITIAL "E=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 5  NO-UNDO.

DEFINE VARIABLE F-F AS CHARACTER FORMAT "X(256)":U INITIAL "F=9999"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 7  NO-UNDO.

DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(5)":U
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Уровни ранжирования нарастающим итогом"
      VIEW-AS TEXT
     SIZE 38.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "IIб. Отсекание по % во 2й группе:"
      VIEW-AS TEXT
     SIZE 35 BY .67 TOOLTIP "2 этап - Отсечь во 2й группе товыры с низким процентом по критерию"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Доли по критерию анализа"
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "I.Разбить товары в пропорции:"
      VIEW-AS TEXT
     SIZE 29.5 BY .67 TOOLTIP "1 этап - Разбить товары в пропорции методом ABC"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "IIа. ABC-анализ 1й группы:"
      VIEW-AS TEXT
     SIZE 27.5 BY .67 TOOLTIP "2 этап - Разбить товары 1й группы методом ABC"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-rez AS CHARACTER FORMAT "X(256)":U INITIAL "Результат анализа:"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-A
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

DEFINE RECTANGLE RECT-B
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

DEFINE RECTANGLE RECT-C
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

DEFINE RECTANGLE RECT-D
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

DEFINE RECTANGLE RECT-E
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

DEFINE RECTANGLE RECT-f
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-obj FOR
      x-abc-analysis-obj SCROLLING.

DEFINE QUERY BROWSE-period FOR
      x-abc-analysis-period SCROLLING.

DEFINE QUERY BROWSE-rez FOR
      temp-rez SCROLLING.

DEFINE QUERY BROWSE-type-doc FOR
      x-abc-analysis-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      x-abc-analysis,
      x-criterion-analysis SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _STRUCTURED
  QUERY BROWSE-obj NO-LOCK DISPLAY
      x-abc-analysis-obj.obj-type FORMAT "X(3)":U
      x-abc-analysis-obj.obj-code FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13 BY 5.75
         TITLE "Объекты" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Объекты АВС анализа".

DEFINE BROWSE BROWSE-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-period Dialog-Frame _STRUCTURED
  QUERY BROWSE-period NO-LOCK DISPLAY
      x-abc-analysis-period.abcp-start COLUMN-LABEL "Начало" FORMAT "99/99/99":U
      x-abc-analysis-period.abcp-end COLUMN-LABEL "Конец" FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20 BY 5.75
         TITLE "Интервалы анализа" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Интервалы анализа".

DEFINE BROWSE BROWSE-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-rez Dialog-Frame _FREEFORM
  QUERY BROWSE-rez DISPLAY
      temp-rez.ABC       COLUMN-LABEL "A!B!C"           FORMAT "x(5)"
      temp-rez.Sum-cr    COLUMN-LABEL "Сумма!группы! "  FORMAT "->>>>>>>>>>9.99"
      temp-rez.Sum_prc   COLUMN-LABEL "Доля!группы! "
      temp-rez.qnty      COLUMN-LABEL "Число!артик.!"    FORMAT ">>>>>>9.99"
      temp-rez.qnty_prc  COLUMN-LABEL "Распределение!номенклатуры!по группам"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 57.75 BY 8.29 ROW-HEIGHT-CHARS .67 EXPANDABLE.

DEFINE BROWSE BROWSE-type-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-type-doc Dialog-Frame _STRUCTURED
  QUERY BROWSE-type-doc NO-LOCK DISPLAY
      f-name-doc ( buffer x-abc-analysis-doc) COLUMN-LABEL "Тип документа" FORMAT "x(22)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25 BY 5.75
         TITLE "Типы документов" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Типы документов анализа".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BROWSE-rez AT ROW 12.46 COL 1.25
     x-abc-analysis.double-line-proc AT ROW 5.83 COL 59.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9.75 BY .88
     x-abc-analysis.abc-type AT ROW 2.08 COL 39.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Простой", "1":U,
"Двухуровневый", "2":U
          SIZE 30 BY .71
          FGCOLOR 4
     FILL-IN-11 AT ROW 5.83 COL 69.75 COLON-ALIGNED NO-LABEL
     FILL-IN-8 AT ROW 5 COL 57.5 COLON-ALIGNED NO-LABEL
     x-abc-analysis.LE-proc AT ROW 16.71 COL 86.38 COLON-ALIGNED
          LABEL "<= %" FORMAT "->>>>9.999"
          VIEW-AS FILL-IN
          SIZE 8 BY .83 TOOLTIP "Ограничение последней группы"
     x-abc-analysis.r-goods AT ROW 18.21 COL 60.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "По всем товарам", 1,
"Выборочно", 2
          SIZE 18.5 BY 1.75
     B-gds-list AT ROW 19.21 COL 78.88
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-save-rang AT ROW 1 COL 36.75
     B-save-doc-typd AT ROW 1 COL 53.25
     B-rez AT ROW 1 COL 68.25
     B-Help AT ROW 1 COL 87.5
     x-abc-analysis.abc-name AT ROW 2.92 COL 3
          LABEL "Название анализа"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
          FGCOLOR 4
     B-crt AT ROW 4 COL 25
     B-add-obj AT ROW 4.92 COL 1
     B-del-obj AT ROW 4.92 COL 4
     B-add-period AT ROW 4.92 COL 14
     B-del-period AT ROW 4.92 COL 17
     B-add-doc AT ROW 4.92 COL 34.5
     B-del-doc AT ROW 4.92 COL 37.5
     BROWSE-obj AT ROW 5.96 COL 1
     BROWSE-period AT ROW 5.96 COL 14
     BROWSE-type-doc AT ROW 5.96 COL 34
     x-abc-analysis.abc-a AT ROW 9 COL 61 COLON-ALIGNED
          LABEL "A" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-b AT ROW 9 COL 73 COLON-ALIGNED
          LABEL "B" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-c AT ROW 9 COL 86 COLON-ALIGNED
          LABEL "C" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-d AT ROW 10 COL 61 COLON-ALIGNED
          LABEL "D" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-e AT ROW 10 COL 73 COLON-ALIGNED
          LABEL "E" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-des AT ROW 20.75 COL 45.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 52.5 BY 2
     x-abc-analysis.abc-id AT ROW 2.25 COL 19 COLON-ALIGNED
          LABEL "Вн.код ABC анализа"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-abc-analysis.cral-id AT ROW 4.13 COL 19.5 COLON-ALIGNED
          LABEL "Критерий анализа" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 3 BY .67
     x-criterion-analysis.cral-name AT ROW 4.25 COL 26.5 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 68 BY .67
     FILL-IN-1 AT ROW 7.75 COL 59.5 NO-LABEL
     FILL-IN-2 AT ROW 9 COL 67.25 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 9 COL 92.25 COLON-ALIGNED NO-LABEL
     FILL-IN-6 AT ROW 10 COL 79.25 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 9 COL 79.25 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     FILL-IN-5 AT ROW 10 COL 67.25 COLON-ALIGNED NO-LABEL
     F-a AT ROW 14 COL 58.5 COLON-ALIGNED NO-LABEL
     F-b AT ROW 14 COL 66 COLON-ALIGNED NO-LABEL
     F-c AT ROW 14 COL 73.5 COLON-ALIGNED NO-LABEL
     F-d AT ROW 14 COL 81 COLON-ALIGNED NO-LABEL
     F-E AT ROW 14 COL 88.5 COLON-ALIGNED NO-LABEL
     F-F AT ROW 15 COL 73.5 COLON-ALIGNED NO-LABEL
     FILL-rez AT ROW 11.71 COL 1.5 NO-LABEL
     x-abc-analysis.abc-who-create AT ROW 20.8 COL 23.5 COLON-ALIGNED FORMAT "X(15)"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-abc-analysis.abc-date-create AT ROW 21.5 COL 23.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 13 BY .67
     F-time AT ROW 21.5 COL 37 COLON-ALIGNED NO-LABEL
     x-abc-analysis.abc-db-num-create AT ROW 22.25 COL 23.5 COLON-ALIGNED
          LABEL "БД создания анализа"
           VIEW-AS TEXT
          SIZE 3 BY .67
     FILL-IN-7 AT ROW 11.25 COL 60.5 NO-LABEL
     FILL-IN-9 AT ROW 6.92 COL 59.5 COLON-ALIGNED NO-LABEL
     FILL-IN-10 AT ROW 15.92 COL 59.5 COLON-ALIGNED NO-LABEL
     RECT-f AT ROW 12.25 COL 60.5
     RECT-E AT ROW 12.25 COL 60.5
     RECT-D AT ROW 12.25 COL 60.5
     RECT-C AT ROW 12.25 COL 60.5
     RECT-B AT ROW 12.25 COL 60.5
     RECT-A AT ROW 12.25 COL 60.5
     SPACE(39.36) SKIP(8.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список ABC-анализов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-abc-analysis T "?" NO-UNDO ub ub.abc-analysis
      TABLE: x-abc-analysis-doc T "?" NO-UNDO ub ub.abc-analysis-doc
      TABLE: x-abc-analysis-obj T "?" NO-UNDO ub ub.abc-analysis-obj
      TABLE: x-abc-analysis-period T "?" NO-UNDO ub ub.abc-analysis-period
      TABLE: x-criterion-analysis B "?" NO-UNDO ub criterion-analysis
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
/* BROWSE-TAB BROWSE-rez 1 Dialog-Frame */
/* BROWSE-TAB BROWSE-obj B-del-doc Dialog-Frame */
/* BROWSE-TAB BROWSE-period BROWSE-obj Dialog-Frame */
/* BROWSE-TAB BROWSE-type-doc BROWSE-period Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN x-abc-analysis.abc-a IN FRAME Dialog-Frame
   5 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-b IN FRAME Dialog-Frame
   5 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-c IN FRAME Dialog-Frame
   5 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-d IN FRAME Dialog-Frame
   5 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-db-num-create IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-e IN FRAME Dialog-Frame
   5 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN x-abc-analysis.abc-who-create IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN x-abc-analysis.cral-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN x-criterion-analysis.cral-name IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN x-abc-analysis.double-line-proc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN F-a IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-a:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-b IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-b:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-c IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-c:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-d IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-d:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-E IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-E:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-F IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-F:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
ASSIGN
       FILL-IN-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-10 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FILL-IN-11:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L 6                                                            */
ASSIGN
       FILL-IN-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-8 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN-9 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-rez IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN x-abc-analysis.LE-proc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

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
"x-abc-analysis-period.abcp-start" "Начало" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.x-abc-analysis-period.abcp-end
"x-abc-analysis-period.abcp-end" "Конец" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
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
     _TblList          = "x-abc-analysis-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
x-abc-analysis-doc.db-num = x-abc-analysis.db-num"
     _FldNameList[1]   > "_<CALC>"
"f-name-doc ( buffer x-abc-analysis-doc)" "Тип документа" "x(22)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-type-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.x-abc-analysis,Temp-Tables.x-criterion-analysis WHERE Temp-Tables.x-abc-analysis ..."
     _Options          = "no-lock"
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


&Scoped-define SELF-NAME x-abc-analysis.abc-a
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-a Dialog-Frame
ON LEAVE OF x-abc-analysis.abc-a IN FRAME Dialog-Frame /* A */
DO:
    ASSIGN x-abc-analysis.abc-a
           x-abc-analysis.abc-b
           x-abc-analysis.abc-c
           x-abc-analysis.abc-d
           x-abc-analysis.abc-e
           .
  RUN proc-sel-rec
  ( x-abc-analysis.abc-a,
    x-abc-analysis.abc-b,
    x-abc-analysis.abc-c,
    x-abc-analysis.abc-d,
    x-abc-analysis.abc-e
    )  no-error .
  if error-status :error then message return-value .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-a Dialog-Frame
ON return OF x-abc-analysis.abc-a IN FRAME Dialog-Frame /* A */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-b Dialog-Frame
ON LEAVE OF x-abc-analysis.abc-b IN FRAME Dialog-Frame /* B */
DO:
        ASSIGN {&list-abc}  .
  RUN proc-sel-rec
  ( x-abc-analysis.abc-a,
    x-abc-analysis.abc-b,
    x-abc-analysis.abc-c,
    x-abc-analysis.abc-d,
    x-abc-analysis.abc-e
    )  no-error .
  if error-status :error then message return-value .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-b Dialog-Frame
ON return OF x-abc-analysis.abc-b IN FRAME Dialog-Frame /* B */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-c Dialog-Frame
ON LEAVE OF x-abc-analysis.abc-c IN FRAME Dialog-Frame /* C */
DO:
    ASSIGN {&list-abc}  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-c Dialog-Frame
ON return OF x-abc-analysis.abc-c IN FRAME Dialog-Frame /* C */
DO:
 run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
 return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-d
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-d Dialog-Frame
ON LEAVE OF x-abc-analysis.abc-d IN FRAME Dialog-Frame /* D */
DO:
    ASSIGN {&list-abc}  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-d Dialog-Frame
ON return OF x-abc-analysis.abc-d IN FRAME Dialog-Frame /* D */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
 return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-des
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-des Dialog-Frame
ON return OF x-abc-analysis.abc-des IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-e
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-e Dialog-Frame
ON LEAVE OF x-abc-analysis.abc-e IN FRAME Dialog-Frame /* E */
DO:
    ASSIGN {&list-abc}  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-e Dialog-Frame
ON return OF x-abc-analysis.abc-e IN FRAME Dialog-Frame /* E */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
 return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-name Dialog-Frame
ON return OF x-abc-analysis.abc-name IN FRAME Dialog-Frame /* Название анализа */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.abc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.abc-type Dialog-Frame
ON VALUE-CHANGED OF x-abc-analysis.abc-type IN FRAME Dialog-Frame
DO:
  ASSIGN x-abc-analysis.abc-type .
  if x-abc-analysis.abc-type = "2" then do:
      display FILL-IN-10 FILL-IN-11 FILL-IN-8 FILL-IN-9 x-abc-analysis.LE-proc  x-abc-analysis.double-line-proc
      with FRAME {&FRAME-NAME} .
      enable  x-abc-analysis.LE-proc x-abc-analysis.double-line-proc  with FRAME {&FRAME-NAME} .
   end.

  else do:
      HIDE FILL-IN-10 FILL-IN-11 FILL-IN-8 FILL-IN-9 x-abc-analysis.LE-proc x-abc-analysis.double-line-proc
      IN FRAME {&FRAME-NAME} .
  end.

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
&scop abc_List       'ee,es,re,rs,we':u
&scop abc_List-full 'расход внешний,касса продажа,возврат внешний,касса возврат,списание':u

pattr-codes      =  {&abc_List} .
pattr-labels     =  {&abc_List-full} .

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
       find first x-abc-analysis-doc where x-abc-analysis-doc.abcd-ext-doc-type = entry(ii, psel-codes ) no-error .
         if not available x-abc-analysis-doc   then do:
              create x-abc-analysis-doc .
              assign
                x-abc-analysis-doc.abc-id   = p-id
                x-abc-analysis-doc.db-num   = p-db-num
                x-abc-analysis-doc.abcd-ext-doc-type = entry(ii, psel-codes )
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
define variable p-obj-type like ub.clients.obj-type no-undo.
define variable p-obj-code like ub.clients.obj-code no-undo.

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
    on error undo, return no-apply  :
    find first x-abc-analysis-obj where
               x-abc-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type and
               x-abc-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code no-error .
    if error-status :error then do :
        create x-abc-analysis-obj .
        assign
          x-abc-analysis-obj.abc-id   = p-id
          x-abc-analysis-obj.db-num   = p-db-num
          x-abc-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type
          x-abc-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code
        .

    end.
  end.
{&OPEN-QUERY-BROWSE-obj}
 if x-abc-analysis.abc-a = 0 then do:
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

   run gbl/get-per.w (
        output        v-ok ,
        input-output  date-1  ,
        input-output  date-2  ) .
    if v-ok then do:
       find first x-abc-analysis-period where
          x-abc-analysis-period.abcp-end   = date-2 and
          x-abc-analysis-period.abcp-start = date-1 no-error .
       if not available x-abc-analysis-period then do:
        create x-abc-analysis-period .
        assign
          x-abc-analysis-period.abc-id     = p-id
          x-abc-analysis-period.db-num     = p-db-num
          x-abc-analysis-period.abcp-end   = date-2
          x-abc-analysis-period.abcp-start = date-1
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
       "" @ x-abc-analysis.cral-id
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
      x-abc-analysis.cral-id = x-criterion-analysis.cral-id
    .
      DISPLAY
        x-abc-analysis.cral-id
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
  IF AVAILABLE x-abc-analysis-doc THEN DELETE x-abc-analysis-doc.
  {&OPEN-QUERY-BROWSE-type-doc}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-obj Dialog-Frame
ON CHOOSE OF B-del-obj IN FRAME Dialog-Frame /* - */
DO:

 IF AVAILABLE x-abc-analysis-obj THEN DELETE x-abc-analysis-obj.
{&OPEN-QUERY-BROWSE-obj}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-period Dialog-Frame
ON CHOOSE OF B-del-period IN FRAME Dialog-Frame /* - */
DO:
  IF AVAILABLE x-abc-analysis-period THEN DELETE x-abc-analysis-period.
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
        when "doc"
          then do:
              apply "CHOOSE" to B-add-doc IN FRAME Dialog-Frame .
          end.
        when "period"
          then do:
              apply "CHOOSE" to B-add-period IN FRAME Dialog-Frame .
          end.
        when "abc-name"
          then do:
              apply "entry" to x-abc-analysis.abc-name IN FRAME Dialog-Frame .
          end.
        when "abc-rang"
          then do:
              apply "entry" to x-abc-analysis.abc-a IN FRAME Dialog-Frame .
          end.

        otherwise do:
          MESSAGE  RETURN-VALUE "ДЛЯ ОТЛАДКИ !!! " view-as alert-box information .
        end.
        end case.
        return no-apply.
    end.


    find first locked_abc-analysis no-lock where
                      recid(locked_abc-analysis) = p-doc-rec no-error .
    run ref/abc-a.p  (
        input parparentproc
      , input "abc":U
      , input locked_abc-analysis.abc-id
      , input locked_abc-analysis.db-num
      , input table x-abc-analysis
      , input table x-abc-analysis-doc
      , input table x-abc-analysis-obj
      , input table x-abc-analysis-period )
    no-error.
    if error-status:error then do:
        MESSAGE "Ошибка расчета АВС анализа"
        error-status :get-message(1)
        return-value
        "456" skip
    .
      return no-apply.
      end.
    run ref/abc-view.w (
    parParentProc,
    locked_abc-analysis.abc-id ,
    locked_abc-analysis.db-num
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
ON CHOOSE OF B-rez IN FRAME Dialog-Frame /* Товары */
DO:

  run ref/abc-view.w (
  parParentProc,
  x-abc-analysis.abc-id ,
  x-abc-analysis.db-num
  ) no-error .
  if error-status :error then
  message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value                 skip
  "Ошибка процедуры abc-view.w"
  .
  run make-temp-rez .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save-doc-typd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save-doc-typd Dialog-Frame
ON CHOOSE OF B-save-doc-typd IN FRAME Dialog-Frame /* Сохранить ТД */
DO:
  if not can-find (first x-abc-analysis-obj no-lock
        where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-obj.db-num = x-abc-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить список типов документов можно после определения списка объектов." view-as alert-box information .
              return .
  end.

  if not can-find (first x-abc-analysis-doc no-lock
        where x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-doc.db-num = x-abc-analysis.db-num  ) then do:
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

  /* создадим строку для сохранения OBJ  и DOC */
  v-list-obj = "".
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.
  v-list-doc = "".

  for each x-abc-analysis-doc no-lock
      where x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-doc.db-num = x-abc-analysis.db-num  :
            v-list-doc = v-list-doc + x-abc-analysis-doc.abcd-ext-doc-type  + "," .
  end.


  run find-from-hash  (
     input v-list-obj
    ,input "doc-abc-def"
    ,input "doad-possb-keep-string-obj"
    ,input "doad-string-obj"
    ,input "doad-hash-string-obj"
    ,input "doc-abc-def-obj"
    ,output v-recid
    ).

  run update-doc-def (
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
ON CHOOSE OF B-save-rang IN FRAME Dialog-Frame /* Сохранить АВС% */
DO:
  if not can-find (first x-abc-analysis-obj no-lock
        where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-obj.db-num = x-abc-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить ранжирование можно после определения списка объектов." view-as alert-box information .
              return .
  end.
  if  x-abc-analysis.abc-a  = 0  or  x-abc-analysis.abc-b = 0  then do:
              message "Ранжирование АВС не задано !!!" view-as alert-box information .
              return .
  end.
  run waitfram-show ("Ждите...").

  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-id as integer   no-undo .
  define variable v-db as integer   no-undo .
  define variable v-recid as recid  no-undo .

  /* создадим строку для сохранения */
  v-list-obj = "".
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  (
     input v-list-obj
    ,input "rang-abc-def"
    ,input "raad-possb-keep-string-obj"
    ,input "raad-string-obj"
    ,input "raad-hash-string-obj"
    ,input "rang-abc-def-obj"
    ,output v-recid
    ).

  run update-rang-def (
     input v-recid
    ,input v-list-obj
    ,input x-abc-analysis.abc-a
    ,input x-abc-analysis.abc-b
    ,input x-abc-analysis.abc-c
    ,input x-abc-analysis.abc-d
    ,input x-abc-analysis.abc-e
    ,input x-abc-analysis.abc-f ) .
    assign
        x-abc-analysis.raad-a = x-abc-analysis.abc-a
        x-abc-analysis.raad-b = x-abc-analysis.abc-b
        x-abc-analysis.raad-c = x-abc-analysis.abc-c
        x-abc-analysis.raad-d = x-abc-analysis.abc-d
        x-abc-analysis.raad-e = x-abc-analysis.abc-e
        x-abc-analysis.raad-f = x-abc-analysis.abc-f
    .

  run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-rez
&Scoped-define SELF-NAME BROWSE-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-rez Dialog-Frame
ON ROW-DISPLAY OF BROWSE-rez IN FRAME Dialog-Frame
DO:
  IF AVAILABLE temp-rez THEN DO:
      IF  temp-rez.ABC = "A" THEN DO:
          temp-rez.ABC:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum-cr:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum_prc:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 12 .
      END.

      IF  temp-rez.ABC = "B" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 9 .
          temp-rez.Sum-cr:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 9 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 9 .
      END.

      IF  temp-rez.ABC = "D" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 3 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 3 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 3 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 3 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 3 .
      END.
      IF  temp-rez.ABC = "E" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 5 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 5 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 5 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 5 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 5 .
      END.
      IF  temp-rez.ABC = "F" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 7 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 7 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 7 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 7 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 7 .
      END.



  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.double-line-proc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.double-line-proc Dialog-Frame
ON LEAVE OF x-abc-analysis.double-line-proc IN FRAME Dialog-Frame /* double-line-proc */
DO:
  ASSIGN x-abc-analysis.double-line-proc .
  FILL-IN-11 = "/ " + string(100 - x-abc-analysis.double-line-proc) + " %" .
  DISPLAY FILL-IN-11 WITH FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x-abc-analysis.r-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x-abc-analysis.r-goods Dialog-Frame
ON VALUE-CHANGED OF x-abc-analysis.r-goods IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.r-goods.
    IF x-abc-analysis.r-goods = 2 THEN DO:
       run str/gds-list.w (input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
    END.
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

  for each x-abc-analysis:
    delete x-abc-analysis.
  end.

/* Параметры по умолчанию */
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

run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-mode'  ,
  output  par-abc-mode ,
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

run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-one'  ,
  output  par-abc-one ,
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
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-two'  ,
  output  par-abc-two ,
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

  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_abc-analysis /*EXclusive-lock*/ no-lock  where
                  recid(locked_abc-analysis) = p-doc-rec no-wait no-error.
      if locked locked_abc-analysis then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись АBC анализа занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_abc-analysis no-lock where
                       recid(locked_abc-analysis) = p-doc-rec no-error .
      if not avail locked_abc-analysis then do:
        find first locked_abc-analysis no-lock where
                   locked_abc-analysis.db-num = p-db-num and
                   locked_abc-analysis.abc-id = p-id
                   no-error .
      end.
    end.
    if not available locked_abc-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись АBC анализа"
      view-as alert-box error .
      undo, return error.
    end.
    create x-abc-analysis.
    buffer-copy locked_abc-analysis to x-abc-analysis.
   end.
   else do:
          run cur-time in this-procedure(output v-date, output v-time).
          create x-abc-analysis.
          assign
          x-abc-analysis.abc-id = v-last-code + 1
          x-abc-analysis.db-num = v-db-num
          x-abc-analysis.cral-id = 1
          x-abc-analysis.abc-date-create = v-date
          x-abc-analysis.abc-time-create = v-time
          x-abc-analysis.abc-db-num-create = v-db-num
          x-abc-analysis.abc-who-create  = g#userid
         .
/*
message par-abc-type
        par-abc-mode
        par-abc-one
        par-abc-two
        .
  */

   if par-abc-mode = "bimodal":U then do:
       /* "80/20;50/80;0.01" */
      x-abc-analysis.abc-type = "2" .
      if num-entries(par-abc-two,";") <> 3 then do:
         message "Неверно задан конфигурационный параметр abc-two" view-as alert-box error .
         return error return-value .
      end.
      else do:
         x-abc-analysis.double-line-proc = decimal(entry(1 ,entry(1 , par-abc-two ,";" ),"/" )) .
         x-abc-analysis.LE-proc          = decimal(entry(3 , par-abc-two,";" ))  .
         v-abc-one                       =  entry(2 , par-abc-two,";" )  .
      case par-abc-type :
        when 'ABC' then do:
           if num-entries (v-abc-one ,"/") < 2 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее двух уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , v-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = 100 .
        end.
        when 'ABCD' then do:
           if num-entries (v-abc-one ,"/") < 3 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее трех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , v-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = 100 .
        end.
        when 'ABCDE' then do:
           if num-entries (v-abc-one ,"/") < 4 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее четырех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , v-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , v-abc-one,"/" )) .
           x-abc-analysis.abc-E = 100 .
        end.
        when 'ABCDEF' then do:
           if num-entries (v-abc-one ,"/") < 5 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее пяти уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , v-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , v-abc-one,"/" )) .
           x-abc-analysis.abc-E = decimal(  entry ( 5 , v-abc-one,"/" )) .
           x-abc-analysis.abc-f = 100 .
        end.
      end case.

      end.
   end.
   else do:
      /* par-abc-one */
      x-abc-analysis.abc-type = "1" .
      case par-abc-type :
        when 'ABC' then do:
           if num-entries (par-abc-one,"/") < 2 then do:
              message "Неверно задан конфигурационный параметр abc-one , задайте не менее двух уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.

           x-abc-analysis.abc-a = decimal( entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = 100 .
        end.
        when 'ABCD' then do:
           if num-entries (par-abc-one,"/") < 3 then do:
              message "Неверно задан конфигурационный параметр abc-one , задайте не менее трех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.

           x-abc-analysis.abc-a = decimal( entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one,"/" )) .
           x-abc-analysis.abc-d = 100 .
        end.
        when 'ABCDE' then do:
           if num-entries (par-abc-one,"/") < 4 then do:
               message "Неверно задан конфигурационный параметр abc-one , задайте не менее четырех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.

           x-abc-analysis.abc-a = decimal(  entry ( 1 , par-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , par-abc-one,"/" )) .
           x-abc-analysis.abc-E = 100 .
        end.
        when 'ABCDEF' then do:
           if num-entries (par-abc-one,"/") < 5 then do:
             message "Неверно задан конфигурационный параметр abc-one , задайте не менее пяти уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.

           x-abc-analysis.abc-a = decimal(  entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-E = decimal(  entry ( 5 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-f = 100 .
        end.
      end case.

   end.
   end.
   run my_enable in this-procedure .
       find first x-criterion-analysis no-lock where x-criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
       if available x-criterion-analysis then
           display x-criterion-analysis.cral-name with frame dialog-frame.
  hide b-save-doc-typd  b-save-rang in frame {&frame-name} .
  wait-for go of frame {&frame-name} focus x-abc-analysis.abc-name.
end.
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
  DISPLAY FILL-IN-11 FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6 FILL-IN-3 FILL-IN-5
          FILL-rez F-time FILL-IN-7
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-abc-analysis THEN
    DISPLAY x-abc-analysis.double-line-proc x-abc-analysis.abc-type
          x-abc-analysis.LE-proc x-abc-analysis.r-goods x-abc-analysis.abc-name
          x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c
          x-abc-analysis.abc-d x-abc-analysis.abc-e x-abc-analysis.abc-des
          x-abc-analysis.abc-id x-abc-analysis.cral-id
          x-abc-analysis.abc-who-create x-abc-analysis.abc-date-create
          x-abc-analysis.abc-db-num-create
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-rez x-abc-analysis.double-line-proc x-abc-analysis.abc-type
         FILL-IN-11 x-abc-analysis.LE-proc x-abc-analysis.r-goods B-gds-list
         b-quit B-exit B-save-rang B-save-doc-typd B-rez B-Help
         x-abc-analysis.abc-name B-crt B-add-obj B-del-obj B-add-period
         B-del-period B-add-doc B-del-doc BROWSE-obj BROWSE-period
         BROWSE-type-doc x-abc-analysis.abc-a x-abc-analysis.abc-b
         x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e
         x-abc-analysis.abc-des x-abc-analysis.abc-id x-abc-analysis.cral-id
         x-criterion-analysis.cral-name FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6
         FILL-IN-3 FILL-IN-5 FILL-rez x-abc-analysis.abc-who-create
         x-abc-analysis.abc-date-create F-time x-abc-analysis.abc-db-num-create
         FILL-IN-7 RECT-f RECT-E RECT-D RECT-C RECT-B RECT-A
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
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  (
     input v-list-obj
    ,input "ub.rang-abc-def"
    ,input "ub.raad-possb-keep-string-obj"
    ,input "ub.raad-string-obj"
    ,input "ub.raad-hash-string-obj"
    ,input "ub.rang-abc-def-obj"
    ,output v-recid
    ).

   find first ub.rang-abc-def no-lock where
              recid(ub.rang-abc-def) = v-recid
              no-error .
    if available ub.rang-abc-def then do:
       message "Найдено значение уровней ранжирования для данного списка объектов по умолчанию : " skip
                ub.rang-abc-def.raad-a                                                                skip
                ub.rang-abc-def.raad-b                                                                skip
                ub.rang-abc-def.raad-c                                                                skip
               if  ub.rang-abc-def.raad-d = 0 then "" else string(ub.rang-abc-def.raad-d)                skip
               if  ub.rang-abc-def.raad-e = 0 then "" else string(ub.rang-abc-def.raad-e)                skip
               if  ub.rang-abc-def.raad-f = 0 then "" else string(ub.rang-abc-def.raad-f)
               .

       define variable raad-def as character no-undo .
       define variable v-raad-d as decimal   no-undo .
       define variable v-raad-e as decimal   no-undo .
       define variable v-raad-c as decimal   no-undo .
       if ub.rang-abc-def.raad-d = 0 and  ub.rang-abc-def.raad-e = 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABC":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e = 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABCD":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e > 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABCDE":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e > 0 and ub.rang-abc-def.raad-f > 0 then raad-def = "ABCDEF":U .
       assign
         v-raad-d = ub.rang-abc-def.raad-d
         v-raad-e = ub.rang-abc-def.raad-e
         v-raad-c = ub.rang-abc-def.raad-c
       .

       if length(raad-def) < length(par-abc-type) then do:
          if  ub.rang-abc-def.raad-d = 100 then v-raad-d = 0 .
          if  ub.rang-abc-def.raad-e = 100 then v-raad-e = 0 .
          if  ub.rang-abc-def.raad-c = 100 then v-raad-c = 0 .
       end.

       assign
        x-abc-analysis.abc-a  = ub.rang-abc-def.raad-a
        x-abc-analysis.abc-b  = ub.rang-abc-def.raad-b
        x-abc-analysis.abc-c  = v-raad-c
        x-abc-analysis.abc-d  = v-raad-d
        x-abc-analysis.abc-e  = v-raad-e
        x-abc-analysis.abc-f  = ub.rang-abc-def.raad-f
        x-abc-analysis.raad-f = ub.rang-abc-def.raad-f
        x-abc-analysis.raad-a = ub.rang-abc-def.raad-a
        x-abc-analysis.raad-b = ub.rang-abc-def.raad-b
        x-abc-analysis.raad-c = v-raad-c
        x-abc-analysis.raad-d = v-raad-d
        x-abc-analysis.raad-e = v-raad-e
       .

       if par-abc-type = "ABC":U  then do:
       assign
           x-abc-analysis.abc-c = 100
           x-abc-analysis.abc-d = 0
           x-abc-analysis.abc-e = 0
           x-abc-analysis.abc-f = 0
       .
       end.
       if par-abc-type = "ABCD":U  then do:
       assign
           x-abc-analysis.abc-d = 100
           x-abc-analysis.abc-e = 0
           x-abc-analysis.abc-f = 0
       .
       end.
       if par-abc-type = "ABCDE":U  then do:
       assign
           x-abc-analysis.abc-e = 100
           x-abc-analysis.abc-f = 0
       .
       end.

       if par-abc-type = "ABCDEF":U  then do:
       assign
           x-abc-analysis.abc-f = 100
       .
       end.


       display x-abc-analysis.abc-a
               x-abc-analysis.abc-b
               x-abc-analysis.abc-c  when par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
               x-abc-analysis.abc-d  when par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
               x-abc-analysis.abc-e  when par-abc-type = "ABCDEF":U

               with frame {&frame-name} .
       apply "LEAVE" to x-abc-analysis.abc-b  in frame {&frame-name} .
    end.

  run find-from-hash  (
     input v-list-obj
    ,input "ub.doc-abc-def"
    ,input "ub.doad-possb-keep-string-obj"
    ,input "ub.doad-string-obj"
    ,input "ub.doad-hash-string-obj"
    ,input "ub.doc-abc-def-obj"
    ,output v-recid
    ).
   find first ub.doc-abc-def no-lock where
              recid(ub.doc-abc-def) = v-recid
              no-error .
    if available ub.doc-abc-def then do:
    for each ub.doc-abc-def-doc no-lock  where
            ub.doc-abc-def-doc.doad-id = ub.doc-abc-def.doad-id and
            ub.doc-abc-def-doc.db-num  = ub.doc-abc-def.db-num   :
        create x-abc-analysis-doc.
         assign
            x-abc-analysis-doc.abcd-ext-doc-type = ub.doc-abc-def-doc.dadd-ext-doc-type
            x-abc-analysis-doc.abc-id   = x-abc-analysis.abc-id
            x-abc-analysis-doc.db-num   = x-abc-analysis.db-num
         .
        {&OPEN-QUERY-BROWSE-type-doc}
    end.



    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-rez Dialog-Frame
PROCEDURE make-temp-rez :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bb_abc-analysis for ub.abc-analysis.
find first bb_abc-analysis no-lock where
           bb_abc-analysis.abc-id = p-id and
           bb_abc-analysis.db-num = p-db-num
           no-error .
for each temp-rez : delete temp-rez. end.

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 1
    temp-rez.ABC  = "A"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-a-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-a-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-a-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-a-prc-qnty
     .

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 2
    temp-rez.ABC  = "B"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-b-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-b-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-b-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-b-prc-qnty
     .

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 3
    temp-rez.ABC  = "C"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-c-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-c-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-c-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-c-prc-qnty
     .

    if LENGTH(par-abc-type) >= 4 or bb_abc-analysis.abc-type = "2" then  do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 4
        temp-rez.ABC  = "D"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-d-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-d-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-d-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-d-prc-qnty
        .

    end.

    if LENGTH(par-abc-type) >= 5 or bb_abc-analysis.abc-type = "2" then do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 5
        temp-rez.ABC  = "E"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-e-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-e-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-e-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-e-prc-qnty
        .

    end.

    if LENGTH(par-abc-type) >= 6 then do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 6
        temp-rez.ABC  = "F"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-f-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-f-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-f-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-f-prc-qnty
        .

    end.

    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 7
    temp-rez.ABC  = "ИТОГО"
    temp-rez.Sum-cr     =
                          bb_abc-analysis.abc-a-sum + bb_abc-analysis.abc-b-sum +
                          bb_abc-analysis.abc-c-sum + bb_abc-analysis.abc-d-sum +
                          bb_abc-analysis.abc-e-sum + bb_abc-analysis.abc-f-sum

    temp-rez.Sum_prc    = 100
    temp-rez.qnty       =
                          bb_abc-analysis.abc-a-qnty + bb_abc-analysis.abc-b-qnty +
                          bb_abc-analysis.abc-c-qnty + bb_abc-analysis.abc-d-qnty +
                          bb_abc-analysis.abc-e-qnty + bb_abc-analysis.abc-f-qnty

    temp-rez.qnty_prc   = 100
     .


{&OPEN-QUERY-BROWSE-rez}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :

   case par-abc-type :
   when 'AB':U then do:
          hide
              f-c in frame {&frame-name}
              f-d in frame {&frame-name}
              f-e
              f-f
              rect-c
              rect-d
              rect-e
              rect-f
              fill-in-3
              fill-in-4
              fill-in-5
              fill-in-6
              in frame {&frame-name} .
   end.

   when 'ABC':U then do:
          hide
              f-d in frame {&frame-name}
              f-e
              f-f
              rect-d
              rect-e
              rect-f
              fill-in-4
              fill-in-5
              fill-in-6
              in frame {&frame-name} .
              x-abc-analysis.LE-proc:label = "E <= % "  .
   end.

   when 'ABCD':U then do:
     hide
        f-e
        f-f
        rect-e
        rect-f
        fill-in-5
        fill-in-6
        in frame {&frame-name} .
     x-abc-analysis.LE-proc:label = "F <= % "  .
   end.

   when 'ABCDE':U  then do:
      hide
      f-f
      rect-f
      fill-in-6
      in frame {&frame-name} .
      x-abc-analysis.LE-proc:label = "G <= % "  .
   end.
   when 'ABCDEF':U then do:
      x-abc-analysis.LE-proc:label = "H <= % "  .
   end.
   otherwise do:
     message "Не верно задан параметр abc-type " par-abc-type view-as alert-box error .
   end.
   end case.


    if p-mode <> {&add-def} then do:
   assign frame {&frame-name}:title = "Просмотр АВС анализа " .
    for each ub.abc-analysis-doc no-lock  where
            ub.abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-doc.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-doc.
        BUFFER-COPY ub.abc-analysis-doc  TO x-abc-analysis-doc
            .
    end.


    for each ub.abc-analysis-obj no-lock  where
            ub.abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-obj.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-obj.
        BUFFER-COPY ub.abc-analysis-obj  TO x-abc-analysis-obj.

    end.

    for each ub.abc-analysis-period no-lock where
            ub.abc-analysis-period.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-period.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-period.
        BUFFER-COPY ub.abc-analysis-period TO x-abc-analysis-period.
    end.

    run make-temp-rez in this-procedure .
end.

define variable v-user-name as character no-undo .
IF AVAILABLE x-abc-analysis THEN DO:
    f-time =  STRING (x-abc-analysis.abc-time-create,'HH:MM') .

  { gbl/usrfulnm.i
    x-abc-analysis.abc-who-create
    v-user-name }

    DISPLAY x-abc-analysis.abc-name
            x-abc-analysis.abc-a
            x-abc-analysis.abc-b
            x-abc-analysis.abc-c when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-d when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-e when  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-des
            x-abc-analysis.cral-id
            v-user-name          when p-mode <> {&add-def} @  x-abc-analysis.abc-who-create
            x-abc-analysis.abc-date-create   when p-mode <> {&add-def}
            f-time                           when p-mode <> {&add-def}
            x-abc-analysis.abc-db-num-create when p-mode <> {&add-def}
            x-abc-analysis.abc-id when p-mode <> {&add-def}
            fill-in-1
            fill-in-2
            fill-in-3
            fill-in-4 when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
            fill-in-5 when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
            fill-in-6 when  par-abc-type = "ABCDEF":U
            fill-in-7
            B-rez                             when p-mode <> {&add-def}
            FILL-rez                          when p-mode <> {&add-def}
            x-abc-analysis.r-goods
            x-abc-analysis.abc-type
            x-abc-analysis.LE-proc WHEN  x-abc-analysis.abc-type = "2"
            x-abc-analysis.double-line-proc WHEN  x-abc-analysis.abc-type = "2"
            fill-in-8  WHEN  x-abc-analysis.abc-type = "2"
            fill-in-9  WHEN  x-abc-analysis.abc-type = "2"
            fill-in-10 WHEN  x-abc-analysis.abc-type = "2"
            fill-in-11 WHEN  x-abc-analysis.abc-type = "2"
            WITH FRAME Dialog-Frame.

    find first x-criterion-analysis no-lock where x-criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
       IF AVAILABLE x-criterion-analysis THEN
           DISPLAY x-criterion-analysis.cral-name WITH FRAME Dialog-Frame.
 END.
  rect-a:bgcolor in frame {&frame-name} = 4.
  rect-b:bgcolor in frame {&frame-name} = 1.
  rect-c:bgcolor in frame {&frame-name} = 15.
  rect-d:bgcolor in frame {&frame-name} = 3.
  rect-e:bgcolor in frame {&frame-name} = 5.
  rect-f:bgcolor in frame {&frame-name} = 7.


      if p-mode = {&add-def} then do:
        assign frame {&frame-name}:title = "Добавление АВС анализа " .
        display  ""  @  x-criterion-analysis.cral-name     with frame {&frame-name} .
        hide rect-a
             rect-b
             rect-c
             rect-d
             rect-e
             rect-f
             B-rez
             FILL-rez
             BROWSE-rez
             in frame {&frame-name} .
        hide  x-abc-analysis.abc-c
              x-abc-analysis.abc-d
              x-abc-analysis.abc-e
              in frame {&frame-name} .
        if x-abc-analysis.abc-a > 0 then
              run proc-sel-rec (
                  x-abc-analysis.abc-a ,
                  x-abc-analysis.abc-b ,
                  x-abc-analysis.abc-c ,
                  x-abc-analysis.abc-d ,
                  x-abc-analysis.abc-e
                  )  .
      end.


      if p-mode = {&lookup} then do:
        assign
          b-quit:label = "&Выход"
          b-quit:col = 1
        .
          hide b-exit in frame {&frame-name}.
          if x-abc-analysis.abc-a > 0 then
             run proc-sel-rec (
                 x-abc-analysis.abc-a ,
                 x-abc-analysis.abc-b ,
                 x-abc-analysis.abc-c ,
                 x-abc-analysis.abc-d ,
                 x-abc-analysis.abc-e
                 )  .

      end.



      ENABLE
      B-exit when p-mode <> {&lookup}
      b-quit
      B-Help
      x-abc-analysis.abc-name when p-mode <> {&lookup}
      B-crt                   when p-mode <> {&lookup}
      x-abc-analysis.abc-a    when p-mode <> {&lookup}
      x-abc-analysis.abc-b    when p-mode <> {&lookup}
      x-abc-analysis.abc-c    when p-mode <> {&lookup} and (par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U)
      x-abc-analysis.abc-d    when p-mode <> {&lookup} and (par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U                             )
      x-abc-analysis.abc-e    when p-mode <> {&lookup} and (par-abc-type = "ABCDEF":U                                                           )
      FILL-IN-1
      B-add-obj               when p-mode <> {&lookup}
      B-del-obj               when p-mode <> {&lookup}
      B-add-period            when p-mode <> {&lookup}
      B-del-period            when p-mode <> {&lookup}
      B-add-doc               when p-mode <> {&lookup}
      B-del-doc               when p-mode <> {&lookup}
      x-abc-analysis.abc-des  when p-mode <> {&lookup}
      BROWSE-obj
      BROWSE-period
      BROWSE-type-doc
      BROWSE-rez        when p-mode = {&lookup}
      B-save-doc-typd   when p-mode <> {&lookup}
      B-save-rang       when p-mode <> {&lookup}
      b-rez             when p-mode = {&lookup}
      x-abc-analysis.r-goods  when p-mode <> {&lookup}
      x-abc-analysis.abc-type when p-mode <> {&lookup}
      x-abc-analysis.LE-proc  when ( p-mode = {&add-def} and  x-abc-analysis.abc-type = "2")
      b-gds-list        when p-mode <> {&lookup}
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
    FILL-IN-11 = "/ " + string ( 100 - x-abc-analysis.double-line-proc ) + " %" .
    if x-abc-analysis.abc-type <> "2" then do:
      hide FILL-IN-8 FILL-IN-9 FILL-IN-10 FILL-IN-11 x-abc-analysis.le-proc x-abc-analysis.double-line-proc in frame {&frame-name} .
    end.
    else do:
      display  FILL-IN-8 FILL-IN-9 FILL-IN-10 FILL-IN-11  x-abc-analysis.le-proc x-abc-analysis.double-line-proc with frame {&frame-name} .
      if p-mode = {&add-def} then
         enable  x-abc-analysis.le-proc x-abc-analysis.double-line-proc with frame {&frame-name} .

    end.
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
    if  x-abc-analysis.abc-name  :handle = p-widget-handle then do:    if B-crt                  :sensitive then do: apply "entry":u to B-crt                  .  return . end. end.
    if  B-crt              :handle = p-widget-handle then do:          if B-add-obj              :sensitive then do: apply "entry":u to B-add-obj              .  return . end. end.
    if  B-add-obj          :handle = p-widget-handle then do:          if B-add-period           :sensitive then do: apply "entry":u to B-add-period           .  return . end. end.
    if  B-add-period         :handle = p-widget-handle then do:        if B-add-doc              :sensitive then do: apply "entry":u to B-add-doc              .  return . end. end.
    if  B-add-doc        :handle = p-widget-handle then do:            if x-abc-analysis.abc-a   :sensitive then do: apply "entry":u to x-abc-analysis.abc-a   .  return . end. end.
    if  x-abc-analysis.abc-a        :handle = p-widget-handle then do: if x-abc-analysis.abc-b   :sensitive then do: apply "entry":u to x-abc-analysis.abc-b   .  return . end. end.
    if  x-abc-analysis.abc-b        :handle = p-widget-handle then do: if x-abc-analysis.abc-c   :sensitive then do: apply "entry":u to x-abc-analysis.abc-c .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-c        :handle = p-widget-handle then do: if x-abc-analysis.abc-d   :sensitive then do: apply "entry":u to x-abc-analysis.abc-d .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-d        :handle = p-widget-handle then do: if x-abc-analysis.abc-e   :sensitive then do: apply "entry":u to x-abc-analysis.abc-e .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-e        :handle = p-widget-handle then do: if x-abc-analysis.abc-des :sensitive then do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-des      :handle = p-widget-handle then do: if B-exit                 :sensitive then do: apply "entry":u to B-exit                 .  return . end. end.
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

if not available x-abc-analysis then do:
    create x-abc-analysis.
end.

assign
frame {&frame-name}
x-abc-analysis.abc-id
x-abc-analysis.abc-name
x-abc-analysis.abc-a
x-abc-analysis.abc-b
x-abc-analysis.abc-c
x-abc-analysis.abc-d
x-abc-analysis.abc-e
x-abc-analysis.r-goods
x-abc-analysis.LE-proc
x-abc-analysis.abc-type
.
IF r-goods = 1 THEN DO:
/* историю списка запишем в параметры */
END.


if LENGTH(par-abc-type) = 3 then do:
x-abc-analysis.abc-c = 100  .
x-abc-analysis.abc-d = 0    .
x-abc-analysis.abc-e = 0    .
x-abc-analysis.abc-f = 0    .

end.

if LENGTH(par-abc-type) = 4 then do:
x-abc-analysis.abc-d = 100    .
x-abc-analysis.abc-e = 0    .
x-abc-analysis.abc-f = 0    .

end.
if LENGTH(par-abc-type) = 5 then do:
x-abc-analysis.abc-e = 100    .
x-abc-analysis.abc-f = 0    .

end.
if LENGTH(par-abc-type) = 6 then do:
x-abc-analysis.abc-f = 100    .

end.


assign
  x-abc-analysis.abc-des = x-abc-analysis.abc-des:SCREEN-VALUE
  .
 run ref/abcanal1.p (
                input-output p-doc-rec
                ,p-mode
                ,table x-abc-analysis
                ,table x-abc-analysis-doc
                ,table x-abc-analysis-obj
                ,table x-abc-analysis-period
                ) no-error .
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
define input  parameter p-abc-a as decimal   no-undo .
define input  parameter p-abc-b as decimal   no-undo .
define input  parameter p-abc-c as decimal   no-undo .
define input  parameter p-abc-d as decimal   no-undo .
define input  parameter p-abc-e as decimal   no-undo .

define variable v-a as decimal   no-undo .
define variable v-b as decimal   no-undo .
define variable v-c as decimal   no-undo .
define variable v-d as decimal   no-undo .
define variable v-e as decimal   no-undo .
define variable v-f as decimal   no-undo .

define variable v-a-pr as decimal   no-undo .
define variable v-b-pr as decimal   no-undo .
define variable v-c-pr as decimal   no-undo .
define variable v-d-pr as decimal   no-undo .
define variable v-e-pr as decimal   no-undo .
define variable old-par-abc-type as character no-undo .
old-par-abc-type = par-abc-type .
if p-abc-e = 100  then  par-abc-type = 'ABCDE':U .
if p-abc-d = 100  then  par-abc-type = 'ABCD':U .
if p-abc-c = 100  then  par-abc-type = 'ABC':U .
if p-abc-e <> 0 and p-abc-e <> 100 then  par-abc-type = 'ABCDEF':U .

if LENGTH(par-abc-type) > LENGTH(old-par-abc-type) then message "Анализ проведен по типу " par-abc-type " а тип работы выставленный в параметре конфигурации " old-par-abc-type
   view-as alert-box information
.

case par-abc-type :
   when 'ABC':U
   then do:
        assign
          v-c    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
        .

        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.

        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.

        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.
        v-a = v-a-pr * v-c / 100 .
        v-b = v-b-pr * v-c / 100 .
        if v-a > 0 then
            rect-a:WIDTH-CHARS in frame {&frame-name}  =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
            rect-c:WIDTH-CHARS =  v-c.
        DISPLAY
          rect-c
          rect-b when v-b > 0
          rect-a
        WITH FRAME {&FRAME-NAME}.
        DISPLAY
          rect-a
        WITH FRAME {&FRAME-NAME}.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( 100 - v-b-pr )
          f-d = ""
          f-e = ""
          f-f = ""
        .
        DISPLAY
          f-c when v-b > 0
          f-b when v-b > 0
          f-a when v-a > 0
        WITH FRAME {&FRAME-NAME}.
        hide
        f-d  rect-d x-abc-analysis.abc-d fill-in-4
        f-e  rect-e x-abc-analysis.abc-e fill-in-5
        f-f  rect-f                      fill-in-6

        in frame {&frame-name} .
   end.

   when 'ABCD':U
   then do:
        assign
          v-d    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
        .


        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.


        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.

        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.

        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.

        v-a = v-a-pr * v-d / 100 .
        v-b = v-b-pr * v-d / 100 .
        v-c = v-c-pr * v-d / 100 .

        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
            rect-d:WIDTH-CHARS =  v-d.

        DISPLAY
          rect-d
          rect-c when v-c > 0
          rect-b when v-b > 0
          rect-a
        WITH FRAME {&FRAME-NAME}.
        DISPLAY
          rect-a
        WITH FRAME {&FRAME-NAME}.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( v-c-pr - v-b-pr )
          f-d = "D=" + string( 100 - v-c-pr )
          f-e = ""
          f-f = ""
        .
        display
          f-a when v-a > 0
          f-b when v-b > 0
          f-c when v-c > 0
          f-d when v-d > 0
        with frame {&frame-name}.

        hide
        f-e  rect-e x-abc-analysis.abc-e fill-in-5
        f-f  rect-f                      fill-in-6

        in frame {&frame-name} .


   end.

   when 'ABCDE':U
   then do:
        assign
          v-e    = 37.5
          v-d-pr = p-abc-d
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
        .

        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.

        if v-c-pr >  v-d-pr and v-d-pr <> 0 then do:
            return error "Уровень ранжирования C должны быть меньше D  !!! "  .
        end.


        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.

        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.

        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.
        if v-d-pr > 100 then do:
            return error "Уровень ранжирования D должны быть меньше 100%  !!! "  .
        end.


        v-a = v-a-pr * v-e / 100 .
        v-b = v-b-pr * v-e / 100 .
        v-c = v-c-pr * v-e / 100 .
        v-d = v-d-pr * v-e / 100 .

        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
        if v-d > 0 then
            rect-d:WIDTH-CHARS =  v-d.
            rect-e:WIDTH-CHARS =  v-e.

        DISPLAY
          rect-e
          rect-d when v-d > 0
          rect-c when v-c > 0
          rect-b when v-b > 0
          rect-a
        WITH FRAME {&FRAME-NAME}.
        DISPLAY
          rect-a
        WITH FRAME {&FRAME-NAME}.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( v-c-pr - v-b-pr )
          f-d = "D=" + string( v-d-pr - v-c-pr )
          f-e = "E=" + string( 100 - v-d-pr )
          f-f = ""
        .
        display
          f-a when v-a > 0
          f-b when v-b > 0
          f-c when v-c > 0
          f-d when v-d > 0
          f-e when v-e > 0
        with frame {&frame-name}.
        hide
        f-f  rect-f fill-in-6

        in frame {&frame-name} .


   end.
   when 'ABCDEF':U
   then do:

        assign
          v-f    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
          v-d-pr = p-abc-d
          v-e-pr = p-abc-e
        .


        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.

        if v-c-pr >  v-d-pr and v-d-pr <> 0 then do:
            return error "Уровень ранжирования C должны быть меньше D  !!! "  .
        end.

        if v-d-pr >  v-e-pr and v-e-pr <> 0 then do:
            return error "Уровень ранжирования D должны быть меньше E  !!! "  .
        end.


        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.

        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.

        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.
        if v-d-pr > 100 then do:
            return error "Уровень ранжирования D должны быть меньше 100%  !!! "  .
        end.
        if v-e-pr > 100 then do:
            return error "Уровень ранжирования E должны быть меньше 100%  !!! "  .
        end.


        v-a = v-a-pr * v-f / 100 .
        v-b = v-b-pr * v-f / 100 .
        v-c = v-c-pr * v-f / 100 .
        v-d = v-d-pr * v-f / 100 .
        v-e = v-e-pr * v-f / 100 .

        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
        if v-d > 0 then
            rect-d:WIDTH-CHARS =  v-d.
        if v-e > 0 then
            rect-e:WIDTH-CHARS =  v-e.
            rect-f:WIDTH-CHARS =  v-f.

   /*message
   v-a
   v-b
   v-c
   v-d
   v-e
   .
   */

DISPLAY
  rect-f
  rect-e
  rect-d
  rect-c
  rect-b
  rect-a
WITH FRAME {&FRAME-NAME}.

assign
  f-a = "A=" + string( v-a-pr)
  f-b = "B=" + string( v-b-pr - v-a-pr )
  f-c = "C=" + string( v-c-pr - v-b-pr )
  f-d = "D=" + string( v-d-pr - v-c-pr )
  f-e = "E=" + string( v-e-pr - v-d-pr )
  f-f = "F=" + string( 100    - v-e-pr )
.
  display
    f-a when v-a > 0
    f-b when v-b > 0
    f-c when v-c > 0
    f-d when v-d > 0
    f-e when v-e > 0
    f-f when v-f > 0
  with frame {&frame-name}.

   end.
end case.
    DISPLAY
      x-abc-analysis.abc-a
      x-abc-analysis.abc-b
      x-abc-analysis.abc-c when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
      x-abc-analysis.abc-d when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
      x-abc-analysis.abc-e when  par-abc-type = "ABCDEF":U
    with frame {&frame-name}.
 par-abc-type = old-par-abc-type .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-name-doc Dialog-Frame
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_abc-analysis-doc FOR  x-abc-analysis-doc   ) :
  define variable v-ret as character no-undo .
  run get-name-from-ext-type (buf_abc-analysis-doc.abcd-ext-doc-type , no , output v-ret ) .

  RETURN v-ret.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME