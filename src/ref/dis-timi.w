&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER root_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER template_dis-time-rule FOR ub.dis-time-rule.
DEFINE TEMP-TABLE term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt-dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt0-term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root like ub.dis-time-rule.templ-rl-root NO-UNDO.
DEFINE INPUT PARAMETER p-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
define input parameter p-upper-time-rule-num like ub.dis-time-rule.upper-time-rule-num no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование расписаний".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/distruls.i "work" }
{ gbl/disrules.i "work" }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ cmp/operlist.i }

define variable v-time-rule-num          like ub.dis-time-rule.time-rule-num          no-undo .
define variable vt-des               like ub.dis-time-rule.des               no-undo .
define variable vt-level-1           as character no-undo .
define variable vt-level-2           as character no-undo .
define variable vt-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable vt-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable vt-output-display as logical   no-undo . /* виден в броусе */
define variable vt-tree              as character no-undo .
define variable vt-other          as character no-undo . /* еще чего - нибудь */
DEFINE VARIABLE v-tab-order       AS CHARACTER NO-UNDO.
DEFINE variable v-display-time-from          AS CHARACTER no-undo .
DEFINE variable v-display-time-to            AS CHARACTER no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-term-dtr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-term_dis-time-rule tt-dis-time-rule

/* Definitions for BROWSE br-term-dtr                                   */
&Scoped-define FIELDS-IN-QUERY-br-term-dtr tt0-term_dis-time-rule.date-from ~
tt0-term_dis-time-rule.date-to v-display-time-from v-display-time-to ~
tt0-term_dis-time-rule.week-day-0 tt0-term_dis-time-rule.week-day-1 ~
tt0-term_dis-time-rule.week-day-2 tt0-term_dis-time-rule.week-day-3 ~
tt0-term_dis-time-rule.week-day-4 tt0-term_dis-time-rule.week-day-5 ~
tt0-term_dis-time-rule.week-day-6 tt0-term_dis-time-rule.week-day-7 ~
tt0-term_dis-time-rule.month-day tt0-term_dis-time-rule.des ~
tt0-term_dis-time-rule.time-rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-term-dtr
&Scoped-define QUERY-STRING-br-term-dtr FOR EACH tt0-term_dis-time-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-term-dtr OPEN QUERY br-term-dtr FOR EACH tt0-term_dis-time-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-term-dtr tt0-term_dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-term-dtr tt0-term_dis-time-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-time-rule.des ~
tt-dis-time-rule.date-from tt-dis-time-rule.date-to ~
tt-dis-time-rule.month-day tt-dis-time-rule.week-day-1 ~
tt-dis-time-rule.week-day-2 tt-dis-time-rule.week-day-3 ~
tt-dis-time-rule.week-day-4 tt-dis-time-rule.week-day-5 ~
tt-dis-time-rule.week-day-6 tt-dis-time-rule.week-day-7
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-dis-time-rule.des ~
tt-dis-time-rule.date-from tt-dis-time-rule.date-to ~
tt-dis-time-rule.month-day tt-dis-time-rule.week-day-1 ~
tt-dis-time-rule.week-day-2 tt-dis-time-rule.week-day-3 ~
tt-dis-time-rule.week-day-4 tt-dis-time-rule.week-day-5 ~
tt-dis-time-rule.week-day-6 tt-dis-time-rule.week-day-7
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-dis-time-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-dis-time-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-dis-time-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-time-rule.des ~
tt-dis-time-rule.date-from tt-dis-time-rule.date-to ~
tt-dis-time-rule.month-day tt-dis-time-rule.week-day-1 ~
tt-dis-time-rule.week-day-2 tt-dis-time-rule.week-day-3 ~
tt-dis-time-rule.week-day-4 tt-dis-time-rule.week-day-5 ~
tt-dis-time-rule.week-day-6 tt-dis-time-rule.week-day-7
&Scoped-define ENABLED-TABLES tt-dis-time-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-time-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-hist B-Help B-add B-del ~
br-term-dtr fhour fmin fsec thour tmin tsec RS-week-day B-exit-1 B-quit-1 ~
lfromt ltot
&Scoped-Define DISPLAYED-FIELDS tt-dis-time-rule.des ~
tt-dis-time-rule.date-from tt-dis-time-rule.date-to ~
tt-dis-time-rule.month-day tt-dis-time-rule.week-day-1 ~
tt-dis-time-rule.week-day-2 tt-dis-time-rule.week-day-3 ~
tt-dis-time-rule.week-day-4 tt-dis-time-rule.week-day-5 ~
tt-dis-time-rule.week-day-6 tt-dis-time-rule.week-day-7
&Scoped-define DISPLAYED-TABLES tt-dis-time-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-time-rule
&Scoped-Define DISPLAYED-OBJECTS fhour fmin fsec thour tmin tsec ~
RS-week-day lfromt ltot

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit-1
     LABEL "Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit-1
     LABEL "Отмена"
     SIZE 10 BY 1.

DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE lfromt AS CHARACTER FORMAT "X(256)":U INITIAL "С"
      VIEW-AS TEXT
     SIZE 3.5 BY .67 NO-UNDO.

DEFINE VARIABLE ltot AS CHARACTER FORMAT "X(256)":U INITIAL "До"
      VIEW-AS TEXT
     SIZE 3.5 BY .67 NO-UNDO.

DEFINE VARIABLE thour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-week-day AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Понедельник", 1,
"Вторник", 2,
"Среда", 3,
"Четверг", 4,
"Пятница", 5,
"Суббота", 6,
"Воскресенье", 7,
"Все дни недели", 0
     SIZE 17 BY 7.75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-term-dtr FOR
      tt0-term_dis-time-rule SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-dis-time-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-term-dtr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-term-dtr Dialog-Frame _STRUCTURED
  QUERY br-term-dtr NO-LOCK DISPLAY
      tt0-term_dis-time-rule.date-from FORMAT "99/99/9999":U
      tt0-term_dis-time-rule.date-to FORMAT "99/99/9999":U
      v-display-time-from COLUMN-LABEL "Время!начала" FORMAT "X(8)":U
            WIDTH 9
      v-display-time-to COLUMN-LABEL "Время!конца" FORMAT "X(8)":U
            WIDTH 9
      tt0-term_dis-time-rule.week-day-0 COLUMN-LABEL "ДН" FORMAT "*/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-1 COLUMN-LABEL "Пн" FORMAT "Пн/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-2 COLUMN-LABEL "Вт" FORMAT "Вт/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-3 COLUMN-LABEL "Ср" FORMAT "Ср/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-4 COLUMN-LABEL "Чт" FORMAT "Чт/":U
      tt0-term_dis-time-rule.week-day-5 COLUMN-LABEL "Птн" FORMAT "Птн/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-6 COLUMN-LABEL "Сб" FORMAT "Сб/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-7 COLUMN-LABEL "Вс" FORMAT "Вс/":U
      tt0-term_dis-time-rule.month-day FORMAT ">9":U
      tt0-term_dis-time-rule.des FORMAT "X(255)":U
      tt0-term_dis-time-rule.time-rule-num FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 63 BY 14.5
         FONT 4
         TITLE "Детализация" EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-hist AT ROW 1 COL 61
     B-Help AT ROW 1 COL 71
     tt-dis-time-rule.des AT ROW 2.25 COL 9 COLON-ALIGNED
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     B-add AT ROW 4 COL 59
     B-del AT ROW 4 COL 69
     tt-dis-time-rule.date-from AT ROW 5 COL 15 COLON-ALIGNED
          LABEL "Начало периода"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     br-term-dtr AT ROW 5.25 COL 36
     tt-dis-time-rule.date-to AT ROW 6.25 COL 15 COLON-ALIGNED
          LABEL "Конец периода"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     fhour AT ROW 8 COL 3.5 COLON-ALIGNED NO-LABEL
     fmin AT ROW 8 COL 7.5 COLON-ALIGNED NO-LABEL
     fsec AT ROW 8 COL 11.5 COLON-ALIGNED NO-LABEL
     thour AT ROW 9.25 COL 3.5 COLON-ALIGNED NO-LABEL
     tmin AT ROW 9.25 COL 7.5 COLON-ALIGNED NO-LABEL
     tsec AT ROW 9.25 COL 11.5 COLON-ALIGNED NO-LABEL
     tt-dis-time-rule.month-day AT ROW 10.75 COL 12.5 COLON-ALIGNED
          LABEL "День месяца"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
          FGCOLOR 4
     tt-dis-time-rule.week-day-1 AT ROW 12 COL 1.5
          LABEL "Понедельник"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     RS-week-day AT ROW 12 COL 18.5 NO-LABEL
     tt-dis-time-rule.week-day-2 AT ROW 13 COL 1.5
          LABEL "Вторник"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-3 AT ROW 14 COL 1.5
          LABEL "Среда"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-4 AT ROW 15 COL 1.5
          LABEL "Четверг"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-5 AT ROW 16 COL 1.5
          LABEL "Пятница"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-6 AT ROW 17 COL 1.5
          LABEL "Суббота"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-7 AT ROW 18 COL 1.5
          LABEL "Воскресенье"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     B-exit-1 AT ROW 20 COL 3
     B-quit-1 AT ROW 20 COL 13
     lfromt AT ROW 8.25 COL 1 NO-LABEL
     ltot AT ROW 9.25 COL 1 NO-LABEL
     SPACE(94.74) SKIP(12.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расписание типа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: root_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: template_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: term_dis-time-rule T "?" NO-UNDO ub dis-time-rule
      TABLE: tt-dis-time-rule T "?" NO-UNDO ub dis-time-rule
      TABLE: tt0-term_dis-time-rule T "?" NO-UNDO ub dis-time-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-term-dtr date-from Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-exit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-quit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.month-day:VISIBLE IN BROWSE br-term-dtr = FALSE.

/* SETTINGS FOR FILL-IN tt-dis-time-rule.date-from IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.date-from:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-time-rule.date-to IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.date-to:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-time-rule.des IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       fmin:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       fsec:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN lfromt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       lfromt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN ltot IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       ltot:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-time-rule.month-day IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.month-day:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       RS-week-day:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       thour:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       tmin:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       tsec:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-3 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-3:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-4 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-4:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-5 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-5:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-6 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-6:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-dis-time-rule.week-day-7 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-time-rule.week-day-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-term-dtr
/* Query rebuild information for BROWSE br-term-dtr
     _TblList          = "Temp-Tables.tt0-term_dis-time-rule WHERE Temp-Tables.tt-dis-rule <external> ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt0-term_dis-time-rule.date-from
"tt0-term_dis-time-rule.date-from" ? ? "date" ? ? ? ? ? ? no ? no no ? no no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.tt0-term_dis-time-rule.date-to
"tt0-term_dis-time-rule.date-to" ? ? "date" ? ? ? ? ? ? no ? no no ? no no no "U" "" ""
     _FldNameList[3]   > "_<CALC>"
"v-display-time-from" "Время!начала" "X(8)" ? ? ? ? ? ? ? no ? no no "9" yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"v-display-time-to" "Время!конца" "X(8)" ? ? ? ? ? ? ? no ? no no "9" yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.tt0-term_dis-time-rule.week-day-0
"tt0-term_dis-time-rule.week-day-0" "ДН" "*~~/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.tt0-term_dis-time-rule.week-day-1
"tt0-term_dis-time-rule.week-day-1" "Пн" "Пн/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[7]   > Temp-Tables.tt0-term_dis-time-rule.week-day-2
"tt0-term_dis-time-rule.week-day-2" "Вт" "Вт/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[8]   > Temp-Tables.tt0-term_dis-time-rule.week-day-3
"tt0-term_dis-time-rule.week-day-3" "Ср" "Ср/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[9]   > Temp-Tables.tt0-term_dis-time-rule.week-day-4
"tt0-term_dis-time-rule.week-day-4" "Чт" "Чт/" "logical" ? ? ? ? ? ? no ? no no ? no no no "U" "" ""
     _FldNameList[10]   > Temp-Tables.tt0-term_dis-time-rule.week-day-5
"tt0-term_dis-time-rule.week-day-5" "Птн" "Птн/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[11]   > Temp-Tables.tt0-term_dis-time-rule.week-day-6
"tt0-term_dis-time-rule.week-day-6" "Сб" "Сб/" "logical" ? ? ? ? ? ? no ? no no "3" no no no "U" "" ""
     _FldNameList[12]   > Temp-Tables.tt0-term_dis-time-rule.week-day-7
"tt0-term_dis-time-rule.week-day-7" "Вс" "Вс/" "logical" ? ? ? ? ? ? no ? no no ? no no no "U" "" ""
     _FldNameList[13]   > Temp-Tables.tt0-term_dis-time-rule.month-day
"tt0-term_dis-time-rule.month-day" ? ? "integer" ? ? ? ? ? ? no ? no no ? no no no "U" "" ""
     _FldNameList[14]   = Temp-Tables.tt0-term_dis-time-rule.des
     _FldNameList[15]   = Temp-Tables.tt0-term_dis-time-rule.time-rule-num
     _Query            is NOT OPENED
*/  /* BROWSE br-term-dtr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-dis-time-rule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расписание типа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    BELL.
    RETURN NO-APPLY.
END.

  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit-1 Dialog-Frame
ON CHOOSE OF B-exit-1 IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-b-exit-1 IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
  if NOT available locked_dis-time-rule then return no-apply.
  run ref/disctrls.w (
                   INPUT parParentProc
                  ,input "":U /*bttns*/
                  ,input "rl-root":U /**p-mode*/
                  ,input tt-dis-time-rule.time-rule-num
                  ,input tt-dis-time-rule.upper-time-rule-num
                  ,input-output v-rid-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit-1 Dialog-Frame
ON CHOOSE OF B-quit-1 IN FRAME Dialog-Frame /* Отмена */
DO:
  RUN proc-b-quit-1 IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-term-dtr
&Scoped-define SELF-NAME br-term-dtr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-term-dtr Dialog-Frame
ON ROW-DISPLAY OF br-term-dtr IN FRAME Dialog-Frame /* Детализация */
DO:
  ASSIGN
  v-display-time-from = STRING(tt0-term_dis-time-rule.time-from, "HH:MM:SS")
  v-display-time-to   = STRING(tt0-term_dis-time-rule.time-to, "HH:MM:SS").
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fhour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fhour Dialog-Frame
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure (input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fmin Dialog-Frame
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure (input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fsec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fsec Dialog-Frame
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure (input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME thour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL thour Dialog-Frame
ON LEAVE OF thour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure (input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tmin Dialog-Frame
ON LEAVE OF tmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure (input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tsec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tsec Dialog-Frame
ON LEAVE OF tsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure (input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _\MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> {&add-def}
  and p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-mode <> {&add-def} THEN DO:

  END.
  for each tt-dis-time-rule:
    delete tt-dis-time-rule.
  end.
  for each tt0-term_dis-time-rule:
    delete tt0-term_dis-time-rule.
  end.
if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_dis-time-rule EXclusive-lock where
                   recid(locked_dis-time-rule) = p-recid no-wait no-error.
      if locked locked_dis-time-rule then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись РАСПИСАНИЕ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_dis-time-rule no-lock where
                       recid(locked_dis-time-rule) = p-recid no-error .
      if not avail locked_dis-time-rule then do:
        find first locked_dis-time-rule no-lock where
                   locked_dis-time-rule.time-rule-num = p-time-rule-num no-error .
      end.
    end.
    if not available locked_dis-time-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись РАСПИСАНИЯ с номером" p-time-rule-num
      view-as alert-box error .
      undo, return error.
    end.
    if locked_dis-time-rule.time-rule-num <= {&max-num-dr-template}
    and p-mode = {&update} then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя редактировать ШАБЛОНЫ РАСПИСАНИЙ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-dis-time-rule.
    buffer-copy locked_dis-time-rule to tt-dis-time-rule
    .
   end.
   else do:
       FIND FIRST template_dis-time-rule NO-LOCK WHERE
                    template_dis-time-rule.time-rule-num = p-templ-rl-root .
       create tt-dis-time-rule.
       BUFFER-COPY template_dis-time-rule TO tt-dis-time-rule
       ASSIGN
       tt-dis-time-rule.upper-time-rule-num = template_dis-time-rule.time-rule-num
       tt-dis-time-rule.templ-rl-root  = template_dis-time-rule.time-rule-num
       tt-dis-time-rule.root        = yes
       tt-dis-time-rule.des = trim(template_dis-time-rule.des, "@":U)
       .
  end.
  run dtr-code  in this-procedure (
     input  (if p-templ-rl-root > 0 then p-templ-rl-root else tt-dis-time-rule.templ-rl-root)
    ,output vt-des
    ,output vt-upper-time-rule-num
    ,output vt-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output vt-output-display
    ,output vt-tree
    ,output vt-other
                               ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-templ-rl-root" p-templ-rl-root SKIP
     error-status:get-message(1) SKIP
     RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.

  END.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  if p-upper-time-rule-num > {&max-num-dr-template} then do:
    assign
    vt-tree = "":U.
  end.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time Dialog-Frame
PROCEDURE check-time :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-screen-value as integer no-undo.
define input parameter p-mode as character no-undo.
define variable v-limit as integer no-undo.
CASE p-mode:
    when "hour":U then do:
         v-limit = 23.
    end.
    when "min":U then do:
          v-limit = 59.
    end.
    when "sec" then do:
          v-limit = 59.
    end.
END.

  if int(p-screen-value) > v-limit then do:
    bell.
    Message "Неверное время!" view-as alert-box ERROR.
    return error.
  end.

 if error-status:error then return error.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-hide-fields Dialog-Frame
PROCEDURE display-hide-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-other AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-main AS LOGICAL NO-UNDO. /*какую записб редактируем 1 - main 0 терминальную - подчин*/
DEFINE INPUT PARAMETER p-display-hide AS integer NO-UNDO. /*1 - display 0 hide*/
CASE p-display-hide:
    WHEN 1 THEN DO:
      IF p-main THEN DO:
        IF lookup("time-from":U, vt-level-1) > 0
        THEN DO:
           DISPLAY
           fhour fmin fsec
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           fhour WHEN p-mode <> {&LOOKUP}
           fmin WHEN p-mode <> {&LOOKUP}
           fsec WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          fhour fmin fsec
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("time-to", vt-level-1) > 0 THEN DO:
           DISPLAY
           thour tmin tsec
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           thour WHEN p-mode <> {&LOOKUP}
           tmin WHEN p-mode <> {&LOOKUP}
           tsec WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          thour tmin tsec
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("date-from":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.date-from
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.date-from WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.date-from
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("date-to":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.date-to
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.date-to WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.date-to
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("month-day":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.month-day
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.month-day WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.month-day
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-1":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-1
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-1 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-1
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-2":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-2
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-2 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-2
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-3":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-3
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-3 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-3
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-4":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-4
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-4 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-4
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-5":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-5
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-5 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-5
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-6":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-6
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-6 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-6
          in FRAME {&FRAME-NAME}.
        end.
        IF lookup("week-day-7":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-7
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           tt-dis-time-rule.week-day-7 WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-7
          in FRAME {&FRAME-NAME}.
        end.
        IF (lookup("week-day-0", vt-level-1) > 0
        or lookup("week-day-1", vt-level-1) > 0
        or lookup("week-day-2", vt-level-1) > 0
        or lookup("week-day-3", vt-level-1) > 0
        or lookup("week-day-4", vt-level-1) > 0
        or lookup("week-day-5", vt-level-1) > 0
        or lookup("week-day-6", vt-level-1) > 0
        or lookup("week-day-7", vt-level-1) > 0)
        AND lookup("week-day-c":U, p-tree) = 0
        AND lookup("week-day-a":U, p-tree) = 0
        AND lookup("week-day-b":U, p-tree) = 0
        AND lookup("week-day-c":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           RS-week-day
           WITH FRAME {&FRAME-NAME}.
           ENABLE
           RS-week-day WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          RS-week-day
          in FRAME {&FRAME-NAME}.
        end.
        if rs-week-day:sensitive in frame {&frame-name} then do:
          if lookup("week-day-0", vt-level-1) = 0 then do:
            if lookup("0", rs-week-day:radio-buttons) > 0 then
            rs-week-day:disable(radio-label(string(0), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-1", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(1), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-2", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(2), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-3", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(3), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-4", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(4), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-5", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(5), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-6", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(6), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-7", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(7), rs-week-day:radio-buttons)).
          end.
        end.

      END. /*p-main = 1*/
      ELSE DO:
          IF lookup("time-period":U, vt-level-2) > 0
          OR lookup("time-period":U, p-tree) > 0
          THEN DO:
             DISPLAY
             fhour fmin fsec
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             fhour WHEN p-mode <> {&LOOKUP}
             fmin WHEN p-mode <> {&LOOKUP}
             fsec WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            fhour fmin fsec
            in FRAME {&FRAME-NAME}.
          end.
          IF lookup("time-to":U, vt-level-2) > 0
          OR lookup("time-period":U, p-tree) > 0  THEN DO:
             DISPLAY
             thour tmin tsec
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             thour WHEN p-mode <> {&LOOKUP}
             tmin WHEN p-mode <> {&LOOKUP}
             tsec WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            thour tmin tsec
            in FRAME {&FRAME-NAME}.
          end.
          IF lookup("date-from":U, vt-level-2) > 0
          OR lookup("date-period":U, p-tree) > 0 THEN DO:
             DISPLAY
             tt-dis-time-rule.date-from
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.date-from WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.date-from
            in FRAME {&FRAME-NAME}.
          end.
          IF lookup("date-to":U, vt-level-2) > 0
          OR lookup("date-period":U, p-tree) > 0 THEN DO:
             DISPLAY
             tt-dis-time-rule.date-to
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.date-to WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.date-to
            in FRAME {&FRAME-NAME}.
          end.
          IF lookup("month-day":U, vt-level-2) > 0  THEN DO:
             view
             tt-dis-time-rule.month-day
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.month-day WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.month-day
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-1":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-1
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-1 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-1
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-2":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-2
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-2 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-2
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-3":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-3
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-3 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-3
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-4":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-4
             In FRAME {&FRAME-NAME}.
             enable
             tt-dis-time-rule.week-day-4 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-4
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-5":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-5
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-5 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-5
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-6":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-6
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-6 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-6
            in FRAME {&FRAME-NAME}.
          end.
          IF (lookup("week-day-7":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
         THEN DO:
             view
             tt-dis-time-rule.week-day-7
             in FRAME {&FRAME-NAME}.
             ENABLE
             tt-dis-time-rule.week-day-7 WHEN p-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-7
            in FRAME {&FRAME-NAME}.
          end.
        IF (lookup("week-day-0":U, vt-level-2) > 0
        or lookup("week-day-1":U, vt-level-2) > 0
        or lookup("week-day-2":U, vt-level-2) > 0
        or lookup("week-day-3":U, vt-level-2) > 0
        or lookup("week-day-4":U, vt-level-2) > 0
        or lookup("week-day-5":U, vt-level-2) > 0
        or lookup("week-day-6":U, vt-level-2) > 0
        or lookup("week-day-7":U, vt-level-2) > 0
        )
        and lookup("week-day-c":U, p-tree) = 0
        AND (lookup("week-day-a":U, p-tree) > 0
        OR lookup("week-day-b":U, p-tree) > 0)
        AND lookup("week-day-c":U, p-other, ";") = 0 THEN DO:
           view
           RS-week-day
           in FRAME {&FRAME-NAME}.
           ENABLE
           RS-week-day WHEN p-mode <> {&LOOKUP}
           WITH FRAME {&FRAME-NAME}.
        END.
        else do:
          hide
          RS-week-day
          in FRAME {&FRAME-NAME}.
        end.
     END. /*p-main = 0*/
   END.
   WHEN 0 THEN DO:
       HIDE
       fhour fmin fsec
       thour tmin tsec
       RS-week-day
       tt-dis-time-rule.date-from
       tt-dis-time-rule.date-to
       tt-dis-time-rule.month-day
       tt-dis-time-rule.week-day-1
       tt-dis-time-rule.week-day-2
       tt-dis-time-rule.week-day-3
       tt-dis-time-rule.week-day-4
       tt-dis-time-rule.week-day-5
       tt-dis-time-rule.week-day-6
       tt-dis-time-rule.week-day-7
       in FRAME {&FRAME-NAME}.
   END.
  END CASE.
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
  DISPLAY fhour fmin fsec thour tmin tsec RS-week-day lfromt ltot
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-time-rule THEN
    DISPLAY tt-dis-time-rule.des tt-dis-time-rule.date-from
          tt-dis-time-rule.date-to tt-dis-time-rule.month-day
          tt-dis-time-rule.week-day-1 tt-dis-time-rule.week-day-2
          tt-dis-time-rule.week-day-3 tt-dis-time-rule.week-day-4
          tt-dis-time-rule.week-day-5 tt-dis-time-rule.week-day-6
          tt-dis-time-rule.week-day-7
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-hist B-Help tt-dis-time-rule.des B-add B-del
         tt-dis-time-rule.date-from br-term-dtr tt-dis-time-rule.date-to fhour
         fmin fsec thour tmin tsec tt-dis-time-rule.month-day
         tt-dis-time-rule.week-day-1 RS-week-day tt-dis-time-rule.week-day-2
         tt-dis-time-rule.week-day-3 tt-dis-time-rule.week-day-4
         tt-dis-time-rule.week-day-5 tt-dis-time-rule.week-day-6
         tt-dis-time-rule.week-day-7 B-exit-1 B-quit-1 lfromt ltot
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable f-chr as character no-undo .
define variable t-chr as character no-undo .
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
IF p-mode = {&add-def} THEN RETURN.
FOR EACH buf_tt0-term_dis-time-rule:
    DELETE buf_tt0-term_dis-time-rule.
END.
if (lookup("time-from":U, vt-tree) = 0
AND lookup("time-period":U, vt-tree) = 0) then do:
  assign
  f-chr = string(tt-dis-time-rule.time-from, "HH:MM:SS")
  fhour = integer(substring(f-chr, 1, 2))
  fmin  = integer(substring(f-chr, 4, 2))
  fsec  = integer(substring(f-chr, 7, 2))
  .
end.
if (lookup("time-to":U, vt-tree) = 0
          AND lookup("time-period":U, vt-tree) = 0) then do:
  assign
  t-chr = string(tt-dis-time-rule.time-to, "HH:MM:SS")
  thour = integer(substring(t-chr, 1, 2))
  tmin  = integer(substring(t-chr, 4, 2))
  tsec  = integer(substring(t-chr, 7, 2))
  .
end.
IF lookup("week-day-0", vt-level-1) > 0
OR lookup("week-day-1", vt-level-1) > 0
OR lookup("week-day-2", vt-level-1) > 0
OR lookup("week-day-3", vt-level-1) > 0
OR lookup("week-day-4", vt-level-1) > 0
OR lookup("week-day-5", vt-level-1) > 0
OR lookup("week-day-6", vt-level-1) > 0
OR lookup("week-day-7", vt-level-1) > 0
AND lookup("week-day-c":U, vt-tree) = 0
AND lookup("week-day-a":U, vt-tree) = 0
AND lookup("week-day-b":U, vt-tree) = 0
AND lookup("week-day-c":U, vt-other, ";") = 0 THEN DO:
  if tt-dis-time-rule.week-day-0 then
  RS-week-day = 0.
  if tt-dis-time-rule.week-day-1 then
  RS-week-day = 1.
  if tt-dis-time-rule.week-day-2 then
  RS-week-day = 2.
  if tt-dis-time-rule.week-day-3 then
  RS-week-day = 3.
  if tt-dis-time-rule.week-day-4 then
  RS-week-day = 4.
  if tt-dis-time-rule.week-day-5 then
  RS-week-day = 5.
  if tt-dis-time-rule.week-day-6 then
  RS-week-day = 6.
  if tt-dis-time-rule.week-day-7 then
  RS-week-day = 7.
end.

FOR EACH buf_dis-time-rule NO-LOCK WHERE
        buf_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num:
  CREATE buf_tt0-term_dis-time-rule.
  BUFFER-COPY buf_dis-time-rule
  TO buf_tt0-term_dis-time-rule
  ASSIGN
  buf_tt0-term_dis-time-rule.time-from = (IF lookup("time-from":U, vt-level-2) = 0
                                          AND lookup("time-period":U, vt-level-2) = 0
                                    THEN 0
                                    ELSE buf_dis-time-rule.time-from)
  buf_tt0-term_dis-time-rule.time-to = (IF lookup("time-to":U, vt-level-2) = 0
                                              AND lookup("time-period":U, vt-level-2) = 0
                                        THEN 0
                                        ELSE buf_dis-time-rule.time-to)
  buf_tt0-term_dis-time-rule.date-from = (IF lookup("date-from":U, vt-level-2) = 0
                                          AND lookup("date-period":U, vt-level-2) = 0
                                    THEN 01/01/1990
                                    ELSE buf_dis-time-rule.date-from)
  buf_tt0-term_dis-time-rule.date-to = (IF lookup("date-to":U, vt-level-2) = 0
                                              AND lookup("date-period":U, vt-level-2) = 0
                                        THEN 01/01/1990
                                        ELSE buf_dis-time-rule.date-to)

  buf_tt0-term_dis-time-rule.month-day = (IF lookup("month-day":U, vt-level-2) = 0
                                           THEN 0
                                   ELSE buf_dis-time-rule.month-day)
  buf_tt0-term_dis-time-rule.week-day-0 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-0)
  buf_tt0-term_dis-time-rule.week-day-1 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                          AND lookup("week-day-b":U, vt-level-2) = 0
                                          AND lookup("week-day-c":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-1)
  buf_tt0-term_dis-time-rule.week-day-2 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                          AND lookup("week-day-b":U, vt-level-2) = 0
                                          AND lookup("week-day-c":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-2)
  buf_tt0-term_dis-time-rule.week-day-3 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-3)
  buf_tt0-term_dis-time-rule.week-day-4 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-4)
  buf_tt0-term_dis-time-rule.week-day-5 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-5)
  buf_tt0-term_dis-time-rule.week-day-6 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-6)
  buf_tt0-term_dis-time-rule.week-day-7 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-7)
  .

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable ii AS INTEGER NO-UNDO.
ASSIGN
v-tab-order = "des,b-add,b-del,date-from,date-to,fhour,fmin,fsec,thour,tmin,tsec,month-day" +
              "week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,week-day-6,week-day-7,RS-week-day," +
              "b-exit-1,b-quit-1"
FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2 &3"
                                      , (if p-mode = {&add-def} then '' else string(p-time-rule-num))
                                      , FRAME {&FRAME-NAME}:TITLE
                                      , vt-des
                                      )
.

IF LOOKUP("week-day-b", vt-tree) > 0
OR LOOKUP("week-day-b", vt-other, ";") > 0 THEN DO:
  define variable kkk as character no-undo .
  kkk = rs-week-day:RADIO-BUTTONS.
  kkk = substring(kkk, 1, R-INDEX(kkk, {&comma-char}) - 1).
  kkk = substring(kkk, 1, R-INDEX(kkk, {&comma-char}) - 1).
  ASSIGN
  rs-week-day:RADIO-BUTTONS = kkk
  .

END.
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, YES /*main record*/, 1 /*display*/).
IF vt-tree = "":U THEN DO:
  HIDE
  br-term-dtr
  b-exit-1
  b-quit-1
  b-add
  b-del
  in FRAME {&FRAME-NAME}.
END.
ELSE DO:
DO ii = 1 TO NUM-ENTRIES(vt-tree):
    ASSIGN
    v-display-time-from:VISIBLE IN BROWSE br-term-dtr = no
    v-display-time-to:VISIBLE IN BROWSE br-term-dtr = no
    .
    case ENTRY(ii, vt-tree):
        WHEN "date-from":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = YES
             .
        END.
        WHEN "date-to":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "date-period":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = YES
            tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "time-from":U THEN DO:
            ASSIGN
            v-display-time-from:VISIBLE IN BROWSE br-term-dtr = YES
             .
        END.
        WHEN "time-to":U THEN DO:
            ASSIGN
            v-display-time-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "time-period":U THEN DO:
            ASSIGN
            v-display-time-from:VISIBLE IN BROWSE br-term-dtr = YES
            v-display-time-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "month-day":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.month-day:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "week-day-0" THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-a" THEN DO:
          ASSIGN
          tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
          .

        END.
        WHEN "week-day-b" THEN DO:
          ASSIGN
          tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
          .
        END.
        WHEN "week-day-1"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
            .

        END.
        WHEN "week-day-2"  THEN DO:
        ASSIGN
        tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
        .
   END.
    WHEN "week-day-3" THEN DO:
        ASSIGN
        tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
        .
   END.
        WHEN "week-day-4"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-5" THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-6"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-7"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
     END CASE.
    END. /*do ii*/
    ENABLE
    b-add WHEN p-mode <> {&LOOKUP}
    b-DEL WHEN p-mode <> {&LOOKUP}
    WITH FRAME {&FRAME-NAME}.
END.
IF AVAILABLE tt-dis-time-rule THEN
DISPLAY
tt-dis-time-rule.des
WITH FRAME Dialog-Frame.
/*
display
tt-dis-time-rule.date-from WHEN tt-dis-time-rule.date-from <> 12/31/1989
tt-dis-time-rule.date-to WHEN tt-dis-time-rule.date-to <> 12/31/1989
tt-dis-time-rule.month-day WHEN tt-dis-time-rule.month-day <> - 1
lfromt WHEN tt-dis-time-rule.time-from <> - 1
ltot   WHEN tt-dis-time-rule.time-to <> - 1
fhour  WHEN tt-dis-time-rule.time-from <> - 1
fmin   WHEN tt-dis-time-rule.time-from <> - 1
fsec   WHEN tt-dis-time-rule.time-from <> - 1
thour  WHEN tt-dis-time-rule.time-to <> - 1
tmin   WHEN tt-dis-time-rule.time-to <> - 1
tsec   WHEN tt-dis-time-rule.time-to <> - 1
tt-dis-time-rule.week-day-1 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-1 <> ?)
tt-dis-time-rule.week-day-2 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-2 <> ?)
tt-dis-time-rule.week-day-3 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-3 <> ?)
tt-dis-time-rule.week-day-4 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-4 <> ?)
tt-dis-time-rule.week-day-5 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-5 <> ?)
tt-dis-time-rule.week-day-6 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-6 <> ?)
tt-dis-time-rule.week-day-7 WHEN (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-7 <> ?)
RS-week-day WHEN (LOOKUP("week-day-a":U, vt-other) > 0 OR LOOKUP("week-day-b":U, vt-other) > 0)
WITH FRAME Dialog-Frame.
 */
IF (LOOKUP("week-day-a":U, vt-other) > 0 and LOOKUP("week-day-b":U, vt-other) > 0) THEN HIDE
rs-week-day  IN FRAME {&FRAME-NAME}.
ENABLE
b-quit
B-exit WHEN p-mode <> {&lookup}
b-hist when p-mode <> {&add-def}
B-Help
tt-dis-time-rule.des WHEN p-mode <> {&lookup}
WITH FRAME Dialog-Frame.
if p-mode <> {&lookup} then do:
 /*
  ENABLE
  tt-dis-time-rule.date-from WHEN tt-dis-time-rule.date-from <> 12/31/1989
  tt-dis-time-rule.date-to WHEN tt-dis-time-rule.date-to <> 12/31/1989
  tt-dis-time-rule.month-day WHEN tt-dis-time-rule.month-day <> - 1
  fhour when tt-dis-time-rule.time-from <> - 1
  fmin  when tt-dis-time-rule.time-from <> - 1
  fsec  when tt-dis-time-rule.time-from <> - 1
  thour when tt-dis-time-rule.time-to <> - 1
  tmin  when tt-dis-time-rule.time-to <> - 1
  tsec  when tt-dis-time-rule.time-to <> - 1
  tt-dis-time-rule.week-day-1 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-1 <> ?)
  tt-dis-time-rule.week-day-2 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-2 <> ?)
  tt-dis-time-rule.week-day-3 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-3 <> ?)
  tt-dis-time-rule.week-day-4 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-4 <> ?)
  tt-dis-time-rule.week-day-5 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-5 <> ?)
  tt-dis-time-rule.week-day-6 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-6 <> ?)
  tt-dis-time-rule.week-day-7 when (LOOKUP("week-day-c":U, vt-other) > 0 AND tt-dis-time-rule.week-day-7 <> ?)
  RS-week-day                 when (LOOKUP("week-day-a":U, vt-other) > 0 OR LOOKUP("week-day-b":U, vt-other) > 0)
  WITH FRAME Dialog-Frame.
  */
end.
VIEW FRAME Dialog-Frame.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    .

END.
IF vt-tree <> "":u THEN DO:
  ENABLE
  br-term-dtr
  WITH FRAME {&FRAME-NAME}.
  RUN openbr-term-dtr.
  IF p-mode = {&LOOKUP} THEN APPLY "ENTRY" TO b-exit.
  ELSE APPLY "entry" to b-add.
END.
ELSE DO:
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr-term-dtr Dialog-Frame
PROCEDURE openbr-term-dtr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY BR-term-dtr
  FOR  EACH tt0-term_dis-time-rule WHERE
           tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num
BY tt0-term_dis-time-rule.date-from
BY tt0-term_dis-time-rule.date-to
BY tt0-term_dis-time-rule.time-from
BY tt0-term_dis-time-rule.time-to
BY tt0-term_dis-time-rule.week-day-0
BY tt0-term_dis-time-rule.week-day-1
BY tt0-term_dis-time-rule.week-day-2
BY tt0-term_dis-time-rule.week-day-3
BY tt0-term_dis-time-rule.week-day-4
BY tt0-term_dis-time-rule.week-day-5
BY tt0-term_dis-time-rule.week-day-6
BY tt0-term_dis-time-rule.week-day-7
BY tt0-term_dis-time-rule.month-day
 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
IF vt-tree = "":U THEN RETURN ERROR.
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, NO /*main record*/, 1 /*display*/).

IF lookup("date-from", vt-level-2) > 0
AND tt-dis-time-rule.date-from:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   today @ tt-dis-time-rule.date-from
   WITH FRAME {&FRAME-NAME}.
END.
IF lookup("date-to", vt-level-2) > 0
AND tt-dis-time-rule.date-to:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   today @ tt-dis-time-rule.date-to
   WITH FRAME {&FRAME-NAME}.
END.
IF lookup("time-from", vt-level-2) > 0
AND fhour:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ fhour
   0 @ fmin
   0 @ fsec
   WITH FRAME {&FRAME-NAME}.
END.
IF lookup("time-to", vt-level-2) > 0
AND fhour:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ thour
   0 @ tmin
   0 @ tsec
   WITH FRAME {&FRAME-NAME}.
END.
IF lookup("month-day", vt-level-2) > 0
AND tt-dis-time-rule.month-day:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   1 @ tt-dis-time-rule.month-day
   WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-1", vt-level-2) > 0
AND tt-dis-time-rule.week-day-1:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-1:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-1
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-2", vt-level-2) > 0
AND tt-dis-time-rule.week-day-2:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-2:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-2
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-3", vt-level-2) > 0
AND tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-3:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-3
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-4", vt-level-2) > 0
AND tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-4:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-4
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-5", vt-level-2) > 0
AND tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-5:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-5
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-6", vt-level-2) > 0
AND tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-6:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-6
  WITH FRAME {&FRAME-NAME}.
END.
IF lookup("week-day-7", vt-level-2) > 0
AND tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-7:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "no".
  DISPLAY
  tt-dis-time-rule.week-day-7
  WITH FRAME {&FRAME-NAME}.

END.
IF (lookup("week-day-0", vt-level-2) > 0
or lookup("week-day-1", vt-level-2) > 0
or lookup("week-day-2", vt-level-2) > 0
or lookup("week-day-3", vt-level-2) > 0
or lookup("week-day-4", vt-level-2) > 0
or lookup("week-day-5", vt-level-2) > 0
or lookup("week-day-6", vt-level-2) > 0
or lookup("week-day-7", vt-level-2) > 0
) AND RS-week-day:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    RS-Week-day = 1.
    DISPLAY Rs-week-day
    WITH FRAME {&FRAME-NAME}.
END.

ENABLE
b-exit-1
b-quit-1
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U THEN RETURN ERROR.
IF NOT AVAILABLE tt0-term_dis-time-rule THEN RETURN.
FIND first buf_tt0-term_dis-time-rule WHERE RECID(buf_tt0-term_dis-time-rule) = RECID(tt0-term_dis-time-rule).
DELETE buf_tt0-term_dis-time-rule.
RUN rename-term_dis-time-rule.
RUN openbr-term-dtr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit-1 Dialog-Frame
PROCEDURE proc-b-exit-1 :
DEFINE VARIABLE v-time-from LIKE ub.dis-time-rule.time-from NO-UNDO.
DEFINE VARIABLE v-time-to  LIKE ub.dis-time-rule.time-to NO-UNDO.
DEFINE VARIABLE v-date-from LIKE ub.dis-time-rule.date-from NO-UNDO.
DEFINE VARIABLE v-date-to  LIKE ub.dis-time-rule.date-to NO-UNDO.
DEFINE VARIABLE v-month-day  LIKE ub.dis-time-rule.month-day NO-UNDO.
DEFINE VARIABLE v-week-day-0  LIKE ub.dis-time-rule.week-day-0 NO-UNDO.
DEFINE VARIABLE v-week-day-1  LIKE ub.dis-time-rule.week-day-1 NO-UNDO.
DEFINE VARIABLE v-week-day-2  LIKE ub.dis-time-rule.week-day-2 NO-UNDO.
DEFINE VARIABLE v-week-day-3  LIKE ub.dis-time-rule.week-day-3 NO-UNDO.
DEFINE VARIABLE v-week-day-4  LIKE ub.dis-time-rule.week-day-4 NO-UNDO.
DEFINE VARIABLE v-week-day-5  LIKE ub.dis-time-rule.week-day-5 NO-UNDO.
DEFINE VARIABLE v-week-day-6  LIKE ub.dis-time-rule.week-day-6 NO-UNDO.
DEFINE VARIABLE v-week-day-7  LIKE ub.dis-time-rule.week-day-7 NO-UNDO.

DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.

DEFINE VARIABLE v-dub AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U  THEN RETURN ERROR.
/*проверим что такого нет*/
ASSIGN
v-date-from = tt-dis-time-rule.date-from
v-date-to = tt-dis-time-rule.date-to
v-month-day = tt-dis-time-rule.month-day
v-time-from = tt-dis-time-rule.time-from
v-time-to = tt-dis-time-rule.time-to
v-week-day-0 = tt-dis-time-rule.week-day-0
v-week-day-1 = tt-dis-time-rule.week-day-1
v-week-day-2 = tt-dis-time-rule.week-day-2
v-week-day-3 = tt-dis-time-rule.week-day-3
v-week-day-4 = tt-dis-time-rule.week-day-4
v-week-day-5 = tt-dis-time-rule.week-day-5
v-week-day-6 = tt-dis-time-rule.week-day-6
v-week-day-7 = tt-dis-time-rule.week-day-7
.

IF tt-dis-time-rule.date-from:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-date-from = INPUT FRAME {&frame-name} tt-dis-time-rule.date-from
  .
END.
IF tt-dis-time-rule.date-to:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-date-to = INPUT FRAME {&frame-name} tt-dis-time-rule.date-to
  .
END.
IF fhour:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  fhour
  fmin
  fsec
  v-time-from = fhour * 3600 + fmin * 60 + fsec
  .
END.
IF thour:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  thour
  tmin
  tsec
  v-time-to = thour * 3600 + tmin * 60 + tsec
  .
END.
IF tt-dis-time-rule.month-day:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-month-day = INPUT FRAME {&frame-name} tt-dis-time-rule.month-day
  .
END.
IF RS-week-day:sensitive IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    RS-week-day
    v-week-day-0 = (IF rs-week-day = 0 THEN YES ELSE v-week-day-0)
    v-week-day-1 = (IF rs-week-day = 1 THEN YES ELSE v-week-day-1)
    v-week-day-2 = (IF rs-week-day = 2 THEN YES ELSE v-week-day-2)
    v-week-day-3 = (IF rs-week-day = 3 THEN YES ELSE v-week-day-3)
    v-week-day-4 = (IF rs-week-day = 4 THEN YES ELSE v-week-day-4)
    v-week-day-5 = (IF rs-week-day = 5 THEN YES ELSE v-week-day-5)
    v-week-day-6 = (IF rs-week-day = 6 THEN YES ELSE v-week-day-6)
    v-week-day-7 = (IF rs-week-day = 7 THEN YES ELSE v-week-day-7)
    .
END.
IF tt-dis-time-rule.week-day-1:SENSITIVE IN  FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-1 = tt-dis-time-rule.week-day-1
    .
END.
IF tt-dis-time-rule.week-day-2:SENSITIVE IN  FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-2 = tt-dis-time-rule.week-day-2
    .
END.
IF tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-3 = tt-dis-time-rule.week-day-3
    .
END.
IF tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-4 = tt-dis-time-rule.week-day-4
    .
END.
IF tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-5 = tt-dis-time-rule.week-day-5
    .
END.
IF tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-6 = tt-dis-time-rule.week-day-6
    .
END.
IF tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    v-week-day-7 = tt-dis-time-rule.week-day-7
    .
END.
_dub:
FOR EACH buf_tt0-term_dis-time-rule WHERE
        buf_tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num:
  ASSIGN
  v-time-rule-num = max(buf_tt0-term_dis-time-rule.time-rule-num, v-time-rule-num)
  .
    if lookup("time-from", vt-level-2) > 0
    and lookup("time-from":U, vt-tree) > 0
    AND lookup("time-period":U, vt-tree) = 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.time-from = v-time-from then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("Уже есть РАСПИСАНИЕ для такого начала периода времени &1", string(v-time-from, "hh:mm:ss"))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    if lookup("time-to", vt-level-2) > 0
    and lookup("time-to":U, vt-tree) > 0
    AND lookup("time-period":U, vt-tree) = 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.time-to = v-time-to then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("Уже есть РАСПИСАНИЕ для такого конца периода времени &1", string(v-time-to, "hh:mm:ss":U))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    IF lookup("time-period":U, vt-tree) > 0 then do:
       if lookup("week-day-a":U, vt-tree) > 0
       and not (v-week-day-0 = buf_tt0-term_dis-time-rule.week-day-0
           and  v-week-day-1 = buf_tt0-term_dis-time-rule.week-day-1
           and  v-week-day-2 = buf_tt0-term_dis-time-rule.week-day-2
           and  v-week-day-3 = buf_tt0-term_dis-time-rule.week-day-3
           and  v-week-day-4 = buf_tt0-term_dis-time-rule.week-day-4
           and  v-week-day-5 = buf_tt0-term_dis-time-rule.week-day-5
           and  v-week-day-6 = buf_tt0-term_dis-time-rule.week-day-6
           and  v-week-day-7 = buf_tt0-term_dis-time-rule.week-day-7) then.
       else DO:
        IF (v-time-from <=  buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-to >=  buf_tt0-term_dis-time-rule.time-to )  /* buf_tt0  внутри*/
        OR (v-time-from >=  buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-from <=  buf_tt0-term_dis-time-rule.time-to )
        OR (v-time-to >= buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-to <=  buf_tt0-term_dis-time-rule.time-to ) THEN DO:

          assign
          v-dub = yes
          .
          MESSAGE
          substitute("Есть РАСПИСАНИЕ пересекающееся с данным периодом времени &1-&2"
                      , string(v-time-from, "hh:mm:ss")
                      , string(v-time-to, "hh:mm:ss"))
          VIEW-AS ALERT-BOX.
          LEAVE _dub.
        end.
      end.
    END. /*IF lookup("time-period":U, vt-tree) > 0 then do:*/
    if lookup("date-from", vt-level-2) > 0
    and lookup("date-from":U, vt-tree) > 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.date-from = v-date-from then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("Уже есть РАСПИСАНИЕ для такого начала периода дат &1", v-date-from)
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    if lookup("date-to", vt-level-2) > 0
    and lookup("date-to":U, vt-tree) > 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.date-to = v-date-to then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("Уже есть РАСПИСАНИЕ для такого конца периода дат &1", v-date-from)
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    IF lookup("date-to", vt-level-2) > 0
    AND lookup("date-from", vt-level-2) > 0
    AND lookup("date-period":U, vt-tree) > 0  THEN DO:
        IF (v-date-from <=  buf_tt0-term_dis-time-rule.date-from
           AND
           v-date-to >=  buf_tt0-term_dis-time-rule.date-to )
        OR (v-date-from >=  buf_tt0-term_dis-time-rule.date-from
            AND
            v-date-to >=  buf_tt0-term_dis-time-rule.date-to )
        OR (v-date-from >= buf_tt0-term_dis-time-rule.date-to
            AND
            v-date-to <=  buf_tt0-term_dis-time-rule.date-to ) THEN DO:
        END.
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("Есть РАСПИСАНИЕ пересекающееся с данным периодом дат &1:&2"
                   , string(v-date-from)
                   , string(v-date-to))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    END.

END.
IF v-dub THEN UNDO, RETURN ERROR.
CREATE buf_tt0-term_dis-time-rule.
BUFFER-COPY tt-dis-time-rule
EXCEPT time-rule-num
    upper-time-rule-num des
    lvl-num
    is-term
    root
TO buf_tt0-term_dis-time-rule
ASSIGN
buf_tt0-term_dis-time-rule.time-rule-num = v-time-rule-num + 1
buf_tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num
buf_tt0-term_dis-time-rule.date-from = (IF lookup("date-from", vt-level-2) = 0
                                        THEN 12/31/1989
                                        ELSE v-date-from)
buf_tt0-term_dis-time-rule.date-to = (IF lookup("date-to", vt-level-2) = 0
                                       THEN 12/31/1989
                                       ELSE v-date-to)
buf_tt0-term_dis-time-rule.time-from = (IF lookup("time-from", vt-level-2) = 0
                                        THEN 0
                                        ELSE v-time-from)
buf_tt0-term_dis-time-rule.time-to = (IF lookup("time-to", vt-level-2) = 0
                                      THEN 0
                                      ELSE v-time-to)
buf_tt0-term_dis-time-rule.month-day = (IF lookup("month-day", vt-level-2) = 0
                                        THEN 0
                                        ELSE v-month-day)
buf_tt0-term_dis-time-rule.week-day-0 = (IF lookup("week-day-0", vt-level-2) = 0
                                         tHEN NO
                                         ELSE v-week-day-0)
buf_tt0-term_dis-time-rule.week-day-1 = (IF lookup("week-day-1", vt-level-2) = 0
                                        THEN NO
                                        ELSE v-week-day-1)
buf_tt0-term_dis-time-rule.week-day-2 = (IF lookup("week-day-2", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-2)
buf_tt0-term_dis-time-rule.week-day-3 = (IF lookup("week-day-3", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-3)
buf_tt0-term_dis-time-rule.week-day-4 = (IF lookup("week-day-4", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-4)
buf_tt0-term_dis-time-rule.week-day-5 = (IF lookup("week-day-5", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-5)
buf_tt0-term_dis-time-rule.week-day-6 = (IF lookup("week-day-6", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-6)
buf_tt0-term_dis-time-rule.week-day-7 = (IF lookup("week-day-7", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-7)
buf_tt0-term_dis-time-rule.sts   = INTEGER({&non-root-status-int})
buf_tt0-term_dis-time-rule.root   = no
buf_tt0-term_dis-time-rule.is-term   = yes
buf_tt0-term_dis-time-rule.lvl-num   = tt-dis-time-rule.lvl-num + 1
.
RELEASE buf_tt0-term_dis-time-rule.
RUN display-hide-fields IN THIS-PROCEDURE(vt-tree, vt-other, NO, 0).
HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
IN FRAME {&FRAME-NAME}.
RUN rename-term_dis-time-rule.
RUN openbr-term-dtr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-quit-1 Dialog-Frame
PROCEDURE proc-b-quit-1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, NO /*main record*/, 0 /*display*/).

HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
IN FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dub-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.

if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-dis-time-rule then do:
    create tt-dis-time-rule.
end.

assign frame {&frame-name}
tt-dis-time-rule.des
.
IF vt-tree = "":U THEN DO:
    IF tt-dis-time-rule.date-from:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.date-from
    .
    IF tt-dis-time-rule.date-to:SENSITIVE IN FRAME {&FRAME-NAME} THEN
     ASSIGN
    tt-dis-time-rule.date-to
    .
    IF fhour:SENSITIVE IN FRAME {&FRAME-NAME} THEN
     ASSIGN
    fhour
    fmin
    fsec
    tt-dis-time-rule.time-from = (fhour * 3600 + fmin * 60 + fsec)
     .
    IF thour:SENSITIVE IN FRAME {&FRAME-NAME} THEN
     ASSIGN
    thour
    tmin
    tsec
    tt-dis-time-rule.time-to = (thour * 3600 + tmin * 60 + tsec)
     .
    IF tt-dis-time-rule.month-day:SENSITIVE IN FRAME {&FRAME-NAME} THEN
     ASSIGN
    tt-dis-time-rule.month-day
     .
    IF tt-dis-time-rule.week-day-1:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-1.
    IF tt-dis-time-rule.week-day-2:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-2.
    IF tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-3.
    IF tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-4.
    IF tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-5.
    IF tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-6.
    IF tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    tt-dis-time-rule.week-day-7.
    IF RS-week-day:SENSITIVE IN FRAME {&FRAME-NAME} THEN do:
      assign
      tt-dis-time-rule.week-day-0 = (if lookup("week-day-0", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-1 = (if lookup("week-day-1", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-2 = (if lookup("week-day-2", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-3 = (if lookup("week-day-3", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-4 = (if lookup("week-day-4", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-5 = (if lookup("week-day-5", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-6 = (if lookup("week-day-6", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-7 = (if lookup("week-day-7", vt-level-1) > 0 then no else ?)
      .
      ASSIGN
      rs-week-day
      tt-dis-time-rule.week-day-0 = (IF rs-week-day = 0
                                THEN yes
                                ELSE tt-dis-time-rule.week-day-0)
      tt-dis-time-rule.week-day-1 = (IF rs-week-day = 1
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-1)
      tt-dis-time-rule.week-day-2 = (IF rs-week-day = 2
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-2)
      tt-dis-time-rule.week-day-3 = (IF rs-week-day = 3
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-3)
      tt-dis-time-rule.week-day-4 = (IF rs-week-day = 4
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-4)
      tt-dis-time-rule.week-day-5 = (IF rs-week-day = 5
                            THEN  yes
                            ELSE tt-dis-time-rule.week-day-5)
      tt-dis-time-rule.week-day-6 = (IF rs-week-day = 6
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-6)
      tt-dis-time-rule.week-day-7 = (IF rs-week-day = 7
                            THEN  yes
                            ELSE tt-dis-time-rule.week-day-7)
      .
    end.

END.
ELSE DO:

END.
run ref/diffdstr.p (
                input p-mode
              , INPUT TABLE tt-dis-time-rule
              , INPUT TABLE tt0-term_dis-time-rule
              , OUTPUT v-dub-time-rule-num) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-dub-time-rule-num <> 0 THEN DO:
  MESSAGE
  substitute("В системе уже существует точно такое же расписание (расписание № &1)", v-dub-time-rule-num) SKIP
  "Вы уверены, что хотите создать еще одно такое же расписание?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-log.
  IF NOT v-log THEN undo, RETURN ERROR.
END.


run ref/dis-tim1.p (
 input (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num ) /* p-rule-num */
,input p-templ-rl-root
,input p-templ-rl-root
,input tt-dis-time-rule.des
,input tt-dis-time-rule.date-from
,input tt-dis-time-rule.date-to
,input tt-dis-time-rule.time-from
,input tt-dis-time-rule.time-to
,input tt-dis-time-rule.month-day
,input tt-dis-time-rule.week-day-0
,input tt-dis-time-rule.week-day-1
,input tt-dis-time-rule.week-day-2
,input tt-dis-time-rule.week-day-3
,input tt-dis-time-rule.week-day-4
,input tt-dis-time-rule.week-day-5
,input tt-dis-time-rule.week-day-6
,input tt-dis-time-rule.week-day-7
,input tt-dis-time-rule.upper-time-rule-num
,input tt-dis-time-rule.value-type
,input table tt0-term_dis-time-rule
,input-output p-recid
,input p-mode
,input NO /*p-silent */
) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rename-term_dis-time-rule Dialog-Frame
PROCEDURE rename-term_dis-time-rule :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE variable v-time-from          like ub.dis-time-rule.time-from         no-undo .
DEFINE variable v-time-to            like ub.dis-time-rule.time-to           no-undo .
DEFINE variable v-date-from          like ub.dis-time-rule.date-from         no-undo .
DEFINE variable v-date-to            like ub.dis-time-rule.date-to           no-undo .
DEFINE variable v-week-day-0         like ub.dis-time-rule.week-day-0        no-undo .
DEFINE variable v-week-day-1         like ub.dis-time-rule.week-day-1        no-undo .
DEFINE variable v-week-day-2         like ub.dis-time-rule.week-day-2        no-undo .
DEFINE variable v-week-day-3         like ub.dis-time-rule.week-day-3        no-undo .
DEFINE variable v-week-day-4         like ub.dis-time-rule.week-day-4        no-undo .
DEFINE variable v-week-day-5         like ub.dis-time-rule.week-day-5        no-undo .
DEFINE variable v-week-day-6         like ub.dis-time-rule.week-day-6        no-undo .
DEFINE variable v-week-day-7         like ub.dis-time-rule.week-day-7        no-undo .
DEFINE variable v-month-day          like ub.dis-time-rule.month-day         no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U  THEN RETURN ERROR.

FOR EACH buf_tt0-term_dis-time-rule:
    buf_tt0-term_dis-time-rule.des = "".
END.
IF LOOKUP("date-from", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" С &1 ", STRING(buf_tt0-term_dis-time-rule.date-from, "99/99/9999"))
        .
    END.

END.
IF LOOKUP("date-period", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" С &1 до &2"
                                                 , STRING(buf_tt0-term_dis-time-rule.date-from, "99/99/9999")
                                     , STRING(buf_tt0-term_dis-time-rule.date-to, "99/99/9999"))
        .
    END.

END.
IF LOOKUP("date-to", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-to DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" По &1 ", STRING(buf_tt0-term_dis-time-rule.date-to, "99/99/9999"))
.
    END.

END.
IF LOOKUP("time-from", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" С &1 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS"))
.
    END.

END.
IF LOOKUP("time-to", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" До &1 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS"))
.
    END.

END.
IF LOOKUP("time-period", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" С &1 до &2 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS")
                                              , STRING(buf_tt0-term_dis-time-rule.time-to, "HH:MM:SS"))
.
    END.

END.
IF LOOKUP("month-day", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.month-day DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" Число месяца &1 ", buf_tt0-term_dis-time-rule.month-day)
.
    END.

END.
IF LOOKUP("week-day-a", vt-tree) > 0
or LOOKUP("week-day-b", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule:
        ASSIGN
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   (IF buf_tt0-term_dis-time-rule.week-day-0 THEN " Все дни недели" ELSE "") +
                                   (IF buf_tt0-term_dis-time-rule.week-day-1 THEN " Понедельник" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-2 THEN " Вторник" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-3 THEN " Среда" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-4 THEN " Четверг" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-5 THEN " Пятница" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-6 THEN " Суббота" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-7 THEN " Воскресенье" ELSE "")
.
    END.

END.
IF LOOKUP("week-day-0", vt-tree) > 0  THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule:
        ASSIGN
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   (IF buf_tt0-term_dis-time-rule.week-day-0 THEN " Все дни недели" ELSE "") +
                                   (IF buf_tt0-term_dis-time-rule.week-day-1 THEN " Пн" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-2 THEN " Вт" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-3 THEN " Ср" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-4 THEN " Чт" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-5 THEN " Птн" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-6 THEN " Сб" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-7 THEN " Вс" ELSE "")
.
    END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME