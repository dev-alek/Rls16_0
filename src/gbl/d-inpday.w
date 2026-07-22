&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Универсальное окно для ввода даты

Автор: Перваков Михаил Сергеевич
Дата создания: 07/14/00
Author: Mikhail Pervakov
Creation date: 07/14/00

Пример использования:

run gbl/d-inpday.w
  (input ""
  ,input ?
  ,input-output v-date
  ,output lok
  ).
if lok then do:

end.

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter h-callback    as handle    no-undo .
define input        parameter p-title       as character no-undo .
define input        parameter p-description as character no-undo .
define input        parameter p-mode        as character no-undo .
define input-output parameter p-date        as date      no-undo .
define output       parameter p-ok          as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальное окно для ввода месяца и года".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/date-str.i }

define variable v-date         as date no-undo .

define variable v-curr-day     as integer no-undo .
define variable v-month-begin as date no-undo .
define variable v-curr-month  as integer no-undo .
define variable v-curr-year   as integer no-undo .
define variable v-last-day    as integer no-undo .

define variable v-month-offset as integer no-undo .
define variable v-day-handle   as handle no-undo extent 42 .
define variable v-rect-handle  as handle no-undo extent 42 .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable holy-string as character no-undo .

define temp-table tt-holyday no-undo
field holy-date as date
index pi
holy-date
.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-yesterday b-today b-tomorrow ~
b-print b-help editor-description b-prev-day b-next-day FI-date CB-Month ~
b-prev-month b-next-month FI-Year b-prev-year b-next-year editor-holiday ~
fi-month-name
&Scoped-Define DISPLAYED-OBJECTS editor-description CB-Month FI-Year ~
editor-holiday

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-next-day
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-next-month
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-next-year
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-day
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-month
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-year
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-today
     LABEL "&Сегодня"
     SIZE 10 BY 1.

DEFINE BUTTON b-tomorrow
     LABEL "&Завтра"
     SIZE 10 BY 1.

DEFINE BUTTON b-yesterday
     LABEL "&Вчера"
     SIZE 10 BY 1.

DEFINE VARIABLE CB-Month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "         1","         2","         3","         4","         5","         6","         7","         8","         9","        10","        11","        12"
     SIZE 7 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE editor-description AS CHARACTER
     VIEW-AS EDITOR
     SIZE 86.5 BY 1.71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE editor-holiday AS CHARACTER
     VIEW-AS EDITOR
     SIZE 34.75 BY 11.5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-day-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-10 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-11 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-12 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-13 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-14 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-15 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-16 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-17 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-18 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-19 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-20 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-21 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-22 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-23 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-24 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-25 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-26 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-27 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-28 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-29 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-30 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-31 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-32 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-33 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-34 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-35 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-36 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-37 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-38 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-39 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-4 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-40 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-41 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-42 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-5 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-6 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-7 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-8 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-day-9 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-4 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-5 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-6 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE FI-header-7 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.

DEFINE VARIABLE fi-month-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 26.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-Year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-26
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-27
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-28
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-29
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-30
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-31
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-32
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-34
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-35
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-36
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-37
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-38
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-40
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-41
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-42
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-yesterday AT ROW 1 COL 21
     b-today AT ROW 1 COL 31
     b-tomorrow AT ROW 1 COL 41
     b-print AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     editor-description AT ROW 2.29 COL 1.5 NO-LABEL
     b-prev-day AT ROW 4.21 COL 22.88
     b-next-day AT ROW 4.21 COL 26.88
     FI-date AT ROW 4.25 COL 7.88 COLON-ALIGNED
     CB-Month AT ROW 5.5 COL 8 COLON-ALIGNED
     b-prev-month AT ROW 5.54 COL 23
     b-next-month AT ROW 5.54 COL 27
     FI-Year AT ROW 6.79 COL 8 COLON-ALIGNED
     b-prev-year AT ROW 6.88 COL 23
     b-next-year AT ROW 6.88 COL 27
     editor-holiday AT ROW 9.67 COL 51.63 NO-LABEL
     fi-month-name AT ROW 5.71 COL 29.5 COLON-ALIGNED NO-LABEL
     FI-header-1 AT ROW 8.42 COL 1.5 COLON-ALIGNED NO-LABEL
     FI-header-2 AT ROW 8.42 COL 8.5 COLON-ALIGNED NO-LABEL
     FI-header-3 AT ROW 8.42 COL 15.25 COLON-ALIGNED NO-LABEL
     FI-header-4 AT ROW 8.42 COL 22 COLON-ALIGNED NO-LABEL
     FI-header-5 AT ROW 8.42 COL 29 COLON-ALIGNED NO-LABEL
     FI-header-6 AT ROW 8.42 COL 35.75 COLON-ALIGNED NO-LABEL
     FI-header-7 AT ROW 8.42 COL 42.5 COLON-ALIGNED NO-LABEL
     FI-day-1 AT ROW 10.17 COL 1.75 COLON-ALIGNED NO-LABEL
     FI-day-2 AT ROW 10.17 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-3 AT ROW 10.17 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-4 AT ROW 10.17 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-5 AT ROW 10.17 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-6 AT ROW 10.17 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-7 AT ROW 10.17 COL 43 COLON-ALIGNED NO-LABEL
     FI-day-8 AT ROW 12.08 COL 1.75 COLON-ALIGNED NO-LABEL
     FI-day-9 AT ROW 12.08 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-10 AT ROW 12.08 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-11 AT ROW 12.08 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-12 AT ROW 12.08 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-13 AT ROW 12.08 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-14 AT ROW 12.08 COL 43 COLON-ALIGNED NO-LABEL
     FI-day-15 AT ROW 14.08 COL 1.75 COLON-ALIGNED NO-LABEL
     FI-day-16 AT ROW 14.08 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-17 AT ROW 14.08 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-18 AT ROW 14.08 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-19 AT ROW 14.08 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-20 AT ROW 14.08 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-21 AT ROW 14.08 COL 43 COLON-ALIGNED NO-LABEL
     FI-day-22 AT ROW 16 COL 1.75 COLON-ALIGNED NO-LABEL
     FI-day-23 AT ROW 16 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-24 AT ROW 16 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-25 AT ROW 16 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-26 AT ROW 16 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-27 AT ROW 16 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-28 AT ROW 16 COL 43 COLON-ALIGNED NO-LABEL
     FI-day-29 AT ROW 17.92 COL 1.75 COLON-ALIGNED NO-LABEL
     FI-day-30 AT ROW 17.92 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-31 AT ROW 17.92 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-32 AT ROW 17.92 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-33 AT ROW 17.92 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-34 AT ROW 17.92 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-35 AT ROW 17.92 COL 43 COLON-ALIGNED NO-LABEL
     FI-day-36 AT ROW 19.92 COL 1.75 COLON-ALIGNED NO-LABEL
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME D-Dialog
     FI-day-37 AT ROW 19.92 COL 8.75 COLON-ALIGNED NO-LABEL
     FI-day-38 AT ROW 19.92 COL 15.5 COLON-ALIGNED NO-LABEL
     FI-day-39 AT ROW 19.92 COL 22.5 COLON-ALIGNED NO-LABEL
     FI-day-40 AT ROW 19.92 COL 29.25 COLON-ALIGNED NO-LABEL
     FI-day-41 AT ROW 19.92 COL 36 COLON-ALIGNED NO-LABEL
     FI-day-42 AT ROW 19.92 COL 43 COLON-ALIGNED NO-LABEL
     RECT-33 AT ROW 17.42 COL 29.75
     RECT-34 AT ROW 17.42 COL 36.5
     RECT-20 AT ROW 13.58 COL 36.5
     RECT-24 AT ROW 15.5 COL 16
     RECT-25 AT ROW 15.5 COL 23
     RECT-11 AT ROW 11.58 COL 23
     RECT-36 AT ROW 19.42 COL 2.25
     RECT-29 AT ROW 17.42 COL 2.25
     RECT-31 AT ROW 17.42 COL 16
     RECT-23 AT ROW 15.5 COL 9.25
     RECT-32 AT ROW 17.42 COL 23
     RECT-17 AT ROW 13.58 COL 16
     RECT-18 AT ROW 13.58 COL 23
     RECT-19 AT ROW 13.58 COL 29.75
     RECT-13 AT ROW 11.58 COL 36.5
     RECT-22 AT ROW 15.5 COL 2.25
     RECT-21 AT ROW 13.58 COL 43.5
     RECT-30 AT ROW 17.42 COL 9.25
     RECT-16 AT ROW 13.58 COL 9.25
     RECT-15 AT ROW 13.58 COL 2.25
     RECT-14 AT ROW 11.58 COL 43.5
     RECT-12 AT ROW 11.58 COL 29.75
     RECT-28 AT ROW 15.5 COL 43.5
     RECT-42 AT ROW 19.42 COL 43.5
     RECT-5 AT ROW 9.67 COL 29.75
     RECT-6 AT ROW 9.67 COL 36.5
     RECT-4 AT ROW 9.67 COL 23
     RECT-40 AT ROW 19.42 COL 29.75
     RECT-39 AT ROW 19.42 COL 23
     RECT-38 AT ROW 19.42 COL 16
     RECT-37 AT ROW 19.42 COL 9.25
     RECT-1 AT ROW 9.67 COL 2.25
     RECT-41 AT ROW 19.42 COL 36.5
     RECT-35 AT ROW 17.42 COL 43.5
     RECT-26 AT ROW 15.5 COL 29.75
     RECT-3 AT ROW 9.67 COL 16
     RECT-27 AT ROW 15.5 COL 36.5
     RECT-10 AT ROW 11.58 COL 16
     RECT-9 AT ROW 11.58 COL 9.25
     RECT-8 AT ROW 11.58 COL 2.25
     RECT-7 AT ROW 9.67 COL 43.5
     RECT-2 AT ROW 9.67 COL 9.25
     SPACE(72.74) SKIP(10.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор даты"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

ASSIGN
       editor-description:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN
       editor-holiday:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR FILL-IN FI-date IN FRAME D-Dialog
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN FI-day-1 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-1:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-10 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-10:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-11 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-11:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-12 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-12:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-13 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-13:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-14 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-14:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-15 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-15:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-16 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-16:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-17 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-17:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-18 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-18:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-19 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-19:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-2 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-2:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-20 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-20:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-21 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-21:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-22 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-22:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-23 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-23:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-24 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-24:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-25 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-25:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-26 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-26:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-27 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-27:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-28 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-28:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-29 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-29:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-3 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-3:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-30 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-30:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-31 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-31:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-32 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-32:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-33 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-33:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-34 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-34:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-35 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-35:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-36 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-36:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-37 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-37:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-38 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-38:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-39 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-39:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-4 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-4:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-40 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-40:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-41 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-41:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-42 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-42:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-5 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-5:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-6 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-6:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-7 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-7:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-8 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-8:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-day-9 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       FI-day-9:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR FILL-IN FI-header-1 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-2 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-3 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-4 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-5 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-6 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FI-header-7 IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN fi-month-name IN FRAME D-Dialog
   NO-DISPLAY                                                           */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-1:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-10 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-10:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-11 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-11:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-12 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-12:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-13 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-13:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-14 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-14:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-15 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-15:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-16 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-16:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-17 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-17:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-18 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-18:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-19 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-19:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-2 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-2:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-20 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-20:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-21 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-21:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-22 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-22:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-23 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-23:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-24 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-24:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-25 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-25:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-26 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-26:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-27 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-27:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-28 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-28:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-29 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-29:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-3:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-30 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-30:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-31 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-31:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-32 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-32:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-33 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-33:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-34 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-34:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-35 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-35:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-36 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-36:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-37 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-37:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-38 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-38:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-39 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-39:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-4 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-4:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-40 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-40:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-41 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-41:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-42 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-42:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-5 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-5:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-6:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-7 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-7:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-8 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-8:HIDDEN IN FRAME D-Dialog           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-9 IN FRAME D-Dialog
   NO-ENABLE                                                            */
ASSIGN
       RECT-9:HIDDEN IN FRAME D-Dialog           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON GO OF FRAME D-Dialog /* Выбор даты */
DO:

  define variable v-new-month as integer no-undo .
  define variable v-new-day   as integer no-undo .
  define variable v-new-year  as integer no-undo .

  assign
    v-new-month = integer (cb-month :screen-value)
    v-new-year  = integer (fi-year  :screen-value)
    v-new-day   = v-curr-day
  .

  assign
    v-date = date(v-new-month, v-new-day, v-new-year)
  .

  if v-date = ?
  then do:
    message
      "Недопустимая дата" skip
      "месяц" v-new-month skip
      "день"  v-new-day   skip
      "год"   v-new-year  skip
      view-as alert-box error .
    return no-apply . /* --->>>--- */
  end.

  if  h-callback <> ?
  and valid-handle(h-callback)
  then do:
    if h-callback :get-signature("cb-d-inpday-validate") <> ""
    then do:
      define variable v-ok as logical no-undo .
      define variable v-message as character no-undo .
      run cb-d-inpday-validate in h-callback
        (input  v-date
        ,output v-ok
        ,output v-message
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости даты" skip
          "Вызывающая программа" h-callback :file-name skip
          "Внутренняя процедура" "cb-d-inpday-validate" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if v-ok <> true
      then do:
        message
          v-message
          view-as alert-box information .
        return no-apply . /* --->>>--- */
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки диапазона дат" skip
        "В вызывающей программе отсутствует внутренняя процедура" "cb-d-inpday-validate" skip
        "Вызывающая программа" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
  end.

  assign
    p-date = v-date
    p-ok   = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Выбор даты */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit D-Dialog
ON CHOOSE OF b-exit IN FRAME D-Dialog /* Ввод */
DO:
  { gbl/stdbtn.i }

   run save-holyday in this-procedure .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next-day D-Dialog
ON CHOOSE OF b-next-day IN FRAME D-Dialog /* >> */
DO:
  { gbl/stdbtn.i }

  run select-day in this-procedure
    (input 1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next-month D-Dialog
ON CHOOSE OF b-next-month IN FRAME D-Dialog /* >> */
DO:
  { gbl/stdbtn.i }

  run select-month in this-procedure
    (input 1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next-year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next-year D-Dialog
ON CHOOSE OF b-next-year IN FRAME D-Dialog /* >> */
DO:
  { gbl/stdbtn.i }

  run select-year in this-procedure
    (input 1
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev-day D-Dialog
ON CHOOSE OF b-prev-day IN FRAME D-Dialog /* << */
DO:
  run select-day in this-procedure
    (input -1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev-month D-Dialog
ON CHOOSE OF b-prev-month IN FRAME D-Dialog /* << */
DO:
  { gbl/stdbtn.i }

  run select-month in this-procedure
    (input -1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev-year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev-year D-Dialog
ON CHOOSE OF b-prev-year IN FRAME D-Dialog /* << */
DO:
  { gbl/stdbtn.i }

  run select-year in this-procedure
    (input -1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print D-Dialog
ON CHOOSE OF b-print IN FRAME D-Dialog /* Печать */
DO:
  { gbl/stdbtn.i }

  run gbl/prnmonth.p
    (input  v-curr-month /* p-month */
    ,input  v-curr-year  /* p-year  */
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit D-Dialog
ON CHOOSE OF b-quit IN FRAME D-Dialog /* Отмена */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-today
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-today D-Dialog
ON CHOOSE OF b-today IN FRAME D-Dialog /* Сегодня */
DO:
  { gbl/stdbtn.i }

  define variable v-today as date no-undo .
  define variable v-time as integer no-undo .
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .
  run set-date in this-procedure
    (input v-today
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tomorrow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tomorrow D-Dialog
ON CHOOSE OF b-tomorrow IN FRAME D-Dialog /* Завтра */
DO:
  { gbl/stdbtn.i }

  define variable v-today as date no-undo .
  define variable v-time as integer no-undo .
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .
  run set-date in this-procedure
    (input v-today + 1
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-yesterday
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-yesterday D-Dialog
ON CHOOSE OF b-yesterday IN FRAME D-Dialog /* Вчера */
DO:
  { gbl/stdbtn.i }

  define variable v-today as date no-undo .
  define variable v-time as integer no-undo .
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .
  run set-date in this-procedure
    (input v-today - 1
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-Month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-Month D-Dialog
ON VALUE-CHANGED OF CB-Month IN FRAME D-Dialog /* Месяц */
DO:
  run display-month-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FI-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FI-date D-Dialog
ON LEAVE OF FI-date IN FRAME D-Dialog /* Дата */
DO:
  if input frame {&frame-name} FI-date <> ?
  then do:
    assign
      v-curr-day   = day(input frame {&frame-name} FI-date)
    .
    assign
      cb-month :screen-value = string(month(input frame {&frame-name} FI-date)
                                     ,cb-month :format )
    .
    assign
      fi-year :screen-value  = string(year(input frame {&frame-name} FI-date)
                                     ,fi-year :format )
    .
  end.

  run display-month-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FI-Year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FI-Year D-Dialog
ON LEAVE OF FI-Year IN FRAME D-Dialog /* Год */
DO:
  run display-month-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */
run init-tt-holyday .

if p-title <> ""
then do:
  assign
    frame {&frame-name} :title = p-title
  .
end.

on left-mouse-click of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  run set-curr-day
    (input self :name
    ).
end.

on left-mouse-dblclick of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  run set-curr-day
    (input self :name
    ).
  if p-mode <> "holyday" then do :
    apply 'choose':u to b-exit .
  end.
end.

on right-mouse-click of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  if p-mode = "holyday"
  then do :
    run set-holy-day
      (input self :name
      ).
  end.
end.


assign
  FI-header-1 :screen-value  = "Пнд"
  FI-header-2 :screen-value  = "Втр"
  FI-header-3 :screen-value  = "Срд"
  FI-header-4 :screen-value  = "Чтв"
  FI-header-5 :screen-value  = "Птн"
  FI-header-6 :screen-value  = "Сбт"
  FI-header-7 :screen-value  = "Вск"
.

assign
  v-day-handle  [1]  = FI-day-1  :handle
  v-rect-handle [1]  = RECT-1    :handle
  v-day-handle  [2]  = FI-day-2  :handle
  v-rect-handle [2]  = RECT-2    :handle
  v-day-handle  [3]  = FI-day-3  :handle
  v-rect-handle [3]  = RECT-3    :handle
  v-day-handle  [4]  = FI-day-4  :handle
  v-rect-handle [4]  = RECT-4    :handle
  v-day-handle  [5]  = FI-day-5  :handle
  v-rect-handle [5]  = RECT-5    :handle
  v-day-handle  [6]  = FI-day-6  :handle
  v-rect-handle [6]  = RECT-6    :handle
  v-day-handle  [7]  = FI-day-7  :handle
  v-rect-handle [7]  = RECT-7    :handle
  v-day-handle  [8]  = FI-day-8  :handle
  v-rect-handle [8]  = RECT-8    :handle
  v-day-handle  [9]  = FI-day-9  :handle
  v-rect-handle [9]  = RECT-9    :handle

  v-day-handle  [10] = FI-day-10 :handle
  v-rect-handle [10] = RECT-10   :handle
  v-day-handle  [11] = FI-day-11 :handle
  v-rect-handle [11] = RECT-11   :handle
  v-day-handle  [12] = FI-day-12 :handle
  v-rect-handle [12] = RECT-12   :handle
  v-day-handle  [13] = FI-day-13 :handle
  v-rect-handle [13] = RECT-13   :handle
  v-day-handle  [14] = FI-day-14 :handle
  v-rect-handle [14] = RECT-14   :handle
  v-day-handle  [15] = FI-day-15 :handle
  v-rect-handle [15] = RECT-15   :handle
  v-day-handle  [16] = FI-day-16 :handle
  v-rect-handle [16] = RECT-16   :handle
  v-day-handle  [17] = FI-day-17 :handle
  v-rect-handle [17] = RECT-17   :handle
  v-day-handle  [18] = FI-day-18 :handle
  v-rect-handle [18] = RECT-18   :handle
  v-day-handle  [19] = FI-day-19 :handle
  v-rect-handle [19] = RECT-19   :handle

  v-day-handle  [20] = FI-day-20 :handle
  v-rect-handle [20] = RECT-20   :handle
  v-day-handle  [21] = FI-day-21 :handle
  v-rect-handle [21] = RECT-21   :handle
  v-day-handle  [22] = FI-day-22 :handle
  v-rect-handle [22] = RECT-22   :handle
  v-day-handle  [23] = FI-day-23 :handle
  v-rect-handle [23] = RECT-23   :handle
  v-day-handle  [24] = FI-day-24 :handle
  v-rect-handle [24] = RECT-24   :handle
  v-day-handle  [25] = FI-day-25 :handle
  v-rect-handle [25] = RECT-25   :handle
  v-day-handle  [26] = FI-day-26 :handle
  v-rect-handle [26] = RECT-26   :handle
  v-day-handle  [27] = FI-day-27 :handle
  v-rect-handle [27] = RECT-27   :handle
  v-day-handle  [28] = FI-day-28 :handle
  v-rect-handle [28] = RECT-28   :handle
  v-day-handle  [29] = FI-day-29 :handle
  v-rect-handle [29] = RECT-29   :handle

  v-day-handle  [30] = FI-day-30 :handle
  v-rect-handle [30] = RECT-30   :handle
  v-day-handle  [31] = FI-day-31 :handle
  v-rect-handle [31] = RECT-31   :handle
  v-day-handle  [32] = FI-day-32 :handle
  v-rect-handle [32] = RECT-32   :handle
  v-day-handle  [33] = FI-day-33 :handle
  v-rect-handle [33] = RECT-33   :handle
  v-day-handle  [34] = FI-day-34 :handle
  v-rect-handle [34] = RECT-34   :handle
  v-day-handle  [35] = FI-day-35 :handle
  v-rect-handle [35] = RECT-35   :handle
  v-day-handle  [36] = FI-day-36 :handle
  v-rect-handle [36] = RECT-36   :handle
  v-day-handle  [37] = FI-day-37 :handle
  v-rect-handle [37] = RECT-37   :handle
  v-day-handle  [38] = FI-day-38 :handle
  v-rect-handle [38] = RECT-38   :handle
  v-day-handle  [39] = FI-day-39 :handle
  v-rect-handle [39] = RECT-39   :handle

  v-day-handle  [40] = FI-day-40 :handle
  v-rect-handle [40] = RECT-40   :handle
  v-day-handle  [41] = FI-day-41 :handle
  v-rect-handle [41] = RECT-41   :handle
  v-day-handle  [42] = FI-day-42 :handle
  v-rect-handle [42] = RECT-42   :handle
.

assign
  p-ok = false
.


{ gbl/app_help.i }

/* Main Block code for ADM SmartDialogs.
   Checks to be sure the Dialog Box has not been run persistent;
   creates any SmartObjects contained in the Dialog Box;
   sets up standard Dialog initialization and termination.
*/

IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended ":U SKIP
            "to be run Persistent or to be placed ":U SKIP
            "in another SmartObject at UIB design time.":U
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).

  run init-date in this-procedure .

  run set-date in this-procedure
    (input v-date
    ) .

  if p-description <> ""
  then do:
    assign
      editor-description :visible      = true
/*      editor-description :screen-value = p-description*/
    .
    define variable v-date-description as character no-undo .
    run date-str in this-procedure
      (input  date(v-curr-month, v-curr-day, v-curr-year)
      ,output v-date-description
      ) .
    assign
      editor-description :screen-value = substitute(p-description, v-date-description)
    .
  end.
  else do:
    assign
      editor-description :visible      = false
    .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN dispatch IN THIS-PROCEDURE ('destroy':U).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-holyday D-Dialog
PROCEDURE check-holyday :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-month   as integer   no-undo .
  define input  parameter p-day     as integer   no-undo .

  define variable v-holyday     as logical   no-undo .
  define variable v-state       as logical   no-undo .
  define variable v-description as character no-undo .

  assign
    v-holyday = false
    v-state   = false
  .

  case p-month
  :
    when 1
    then do:
      case p-day
      :
        when 1 or
        when 2
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "1,2 января - Государственный праздник. Новый год."
          .
        end.
        when 7
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "7 января - Государственный праздник. Рождество Христово."
          .
        end.
      end.
    end.
    when 2
    then do:
      case p-day
      :
        when 14
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "14 февраля - День Святого Валентина (день всех влюбленных)."
          .
        end.
        when 23
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "23 февраля - Государственный праздник. День защитника Отечества."
          .
        end.
      end.
    end.
    when 3
    then do:
      case p-day
      :
        when 8
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "8 марта - Государственный праздник. Международный женский день."
          .
        end.
        when 19
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "19 марта - Государственный праздник. День работников торговли."
          .
        end.
      end.
    end.
    when 4
    then do:
      case p-day
      :
        when 5
        then do:
          assign
            v-holyday = true
            v-description = "5 апреля 1242 года - день победы русского войска во главе с князем Александром Невским над немецкими рыцарями на Чудском озере (Ледовое побоище - 1242 год)."
          .
        end.
        when 12
        then do:
          assign
            v-holyday = true
            v-description = "12 апреля - день космонавтики."
          .
        end.
      end.
    end.
    when 5
    then do:
      case p-day
      :
        when 1 or
        when 2
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "1, 2 мая - Государственный праздник. Праздник весны и труда."
          .
        end.
        when 9
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "9 мая - Государственный праздник. День Победы [над Фашистской Германией]."
          .
        end.
      end.
    end.
    when 6
    then do:
      case p-day
      :
        when 12
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "12 июня - Государственный праздник. День России (день принятия Декларации о государственном суверенитете РФ)."
          .
        end.
        when 25
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "25 июня - день дружбы и единения славян."
          .
        end.
      end.
    end.
    when 7
    then do:
      case p-day
      :
        when 10
        then do:
          assign
            v-holyday = true
            v-description = "10 июля 1709 года - день победы русской армии под командованием Петра I над шведской армией в Полтавской битве (1709 год)."
          .
        end.
      end.
    end.
    when 8
    then do:
      case p-day
      :
        when 9
        then do:
          assign
            v-holyday = true
            v-description = "9 августа 1714 года - день первой в российской истории морской победы русского флота под командованием Петра I над шведским флотом у мыса Гангут (Гангутское сражение - 1714 год)"
          .
        end.
        when 23
        then do:
          assign
            v-holyday = true
            v-description = "23 августа 1943 года - день воинской славы России. День разгрома советскими войсками немецко-фашистских войск на Курской дуге."
          .
        end.
      end.
    end.
    when 9
    then do:
      case p-day
      :
        when 1
        then do:
          assign
            v-holyday = true
            v-description = "1 сентября 1994 года - начало разработки информационой системы IBS Trade House."
          .
        end.
        when 7
        then do:
          assign
            v-holyday = true
            v-description = "7 сентября 1812 года - день сражения русской армии под командованием Кутузова с армией Наполеона около села Бородино (Бородинское сражение - 1812 год)."
          .
        end.
        when 8
        then do:
          assign
            v-holyday = true
            v-description = "8 сентября 1380 года - день победы русского войска во главе с князем Дмитрием Донским над монголо-татарским войском на Куликовом поле (Куликовская битва - 1380 год)."
          .
        end.
        when 9
        then do:
          assign
            v-holyday = true
            v-description = "9 сентября 1790 года - день победы русского флота под командованием Федора Ушакова над турецким флотом у острова Тендра (1790 год)."
          .
        end.
      end.
    end.
    when 10
    then do:
      case p-day
      :
        when 22
        then do:
          assign
            v-holyday = true
            v-description = "22 октября 1721 года - Акт поднесения Государю Царю Петру I титула Императора Всероссийского наименования Великого и Отца Отечества."
          .
        end.
      end.
    end.
    when 11
    then do:
      case p-day
      :
        when 2
        then do:
          assign
            v-holyday = true
            v-description = "2 ноября 1992 года - день основания компании IBS."
          .
        end.
        when 4
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "4 ноября - День народного единства."
          .
        end.
        when 5
        then do:
          assign
            v-holyday = true
            v-description = "5 ноября 1612 года - день освобождения Москвы от польских интервентов народным ополчением под руководством Кузьмы Минина и Дмитрия Пожарского (1612 год)."
          .
        end.
      end.
    end.
    when 12
    then do:
      case p-day
      :
        when 1
        then do:
          assign
            v-holyday = true
            v-description = "1 декабря 1853 года - день победы русской эскадры под командованием Нахимова над турецкой эскадрой в Синопской бухте (Синопское сражение - 1853 год)."
          .
        end.
        when 12
        then do:
          assign
            v-holyday = true
            v-state   = true
            v-description = "12 декабря - Государственный праздник. День конституции РФ."
          .
        end.
        when 24
        then do:
          assign
            v-holyday = true
            v-description = "24 декабря 1790 года - день взятия турецкой крепости Измаил русскими войсками под командованием Александра Суворова (1790 год)."
          .
        end.
      end.
    end.
  end case .

  do with frame {&frame-name}:
    if v-holyday = true
    then do:
      assign
        editor-holiday :screen-value = v-description
      .
    end.
    else do:
      assign
        editor-holiday :screen-value = ""
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-calendar D-Dialog
PROCEDURE display-calendar :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  assign
    v-curr-month   = integer(cb-month :screen-value in frame {&frame-name})
    v-curr-year    = integer(fi-year :screen-value  in frame {&frame-name})
    v-month-begin  = date(v-curr-month
                         ,1
                         ,v-curr-year
                         )
    v-month-offset = (weekday(v-month-begin) + 5) mod 7
  .

  run gbl/lastday.p
    (input  v-month-begin
    ,output v-last-day
    ).

  if v-curr-day > v-last-day
  then do:
    assign
      v-curr-day = v-last-day
    .
  end.
  if v-curr-day = ?
  or v-curr-day <= 0
  then do:
    assign
      v-curr-day = 1
    .
  end.


  do with frame {&frame-name}:
    assign
      FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
    .
    run check-holyday in this-procedure
      (input  v-curr-month
      ,input  v-curr-day
      ) .
    if  p-description <> ""
    and index(p-description, '&1':u) > 0
    then do:
      define variable v-date-description as character no-undo .
      run date-str in this-procedure
        (input  date(v-curr-month, v-curr-day, v-curr-year)
        ,output v-date-description
        ) .
      assign
        editor-description :screen-value = substitute(p-description, v-date-description)
      .
    end.
  end. /* do with frame */

  define variable ind as integer no-undo .

  define variable l-immediate-display as logical no-undo .
  assign
    l-immediate-display        = session :immediate-display
    session :immediate-display = false
  .

  do ind = 1 to 42 :
    run set-box-state in this-procedure
      (input ind
      ,input (if ind  >= v-month-offset + 1
              and ind <= v-month-offset + v-last-day
              then ind - v-month-offset
              else - day(date(v-curr-month, 1, v-curr-year) + ind - (v-month-offset + 1) )
             )
      ).
  end.

  assign
    session :immediate-display = l-immediate-display
  .
  run init-holyday .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-month-name D-Dialog
PROCEDURE display-month-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable v-month-name as character no-undo .

  do with frame {&frame-name}:
    run gbl/monthnam.p
      (input integer(cb-month :screen-value)
      ,output v-month-name
      ).

    assign
      fi-month-name :screen-value = v-month-name
    .

  end.

  run display-calendar .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-holyday D-Dialog
PROCEDURE init-holyday :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

for each tt-holyday use-index pi
   where tt-holyday.holy-date >= date(v-curr-month,1,v-curr-year)
     and tt-holyday.holy-date <= date(v-curr-month,v-last-day,v-curr-year) no-lock :
  if day(tt-holyday.holy-date) <> 0 then do :
   run set-box-state-holy
     (input day(tt-holyday.holy-date) + v-month-offset
     ,input day(tt-holyday.holy-date)
     ).
   end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt-holyday D-Dialog
PROCEDURE init-tt-holyday :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo .

find first sysconf-attr no-lock
     where sysconf-attr.attr-code = "holyday"
       and sysconf-attr.host-code = 0
       and sysconf-attr.attr-value <> "" no-error.
if available sysconf-attr then do :
  do ii = 1 to num-entries(sysconf-attr.attr-value,",") :
    if not can-find(first tt-holyday where tt-holyday.holy-date = date(entry(ii,sysconf-attr.attr-value,",")) ) then do :
      create tt-holyday .
      assign
        tt-holyday.holy-date = date(entry(ii,sysconf-attr.attr-value,","))
      .
    end.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog _DEFAULT-ENABLE
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
  DISPLAY editor-description CB-Month FI-Year editor-holiday
      WITH FRAME D-Dialog.
  ENABLE b-exit b-quit b-yesterday b-today b-tomorrow b-print b-help
         editor-description b-prev-day b-next-day FI-date CB-Month b-prev-month
         b-next-month FI-Year b-prev-year b-next-year editor-holiday
         fi-month-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-date D-Dialog
PROCEDURE init-date :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  assign
    v-date = p-date
  .
  if v-date = ?
  then do:
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).
    assign
      v-date = v-today
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-day D-Dialog
PROCEDURE select-day :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-shift-value as integer no-undo .

  define variable v-current-date as date      no-undo .

  do with frame {&frame-name}:
    assign
      v-current-date = date(v-curr-month, v-curr-day, v-curr-year)
    .
    if v-current-date <> ?
    then do:
      run set-date in this-procedure
        (input v-current-date + p-shift-value
        ) .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-holyday D-Dialog
PROCEDURE save-holyday :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

if p-mode = "holyday" then do :
  holy-string = "" .
  for each tt-holyday use-index pi
    where tt-holyday.holy-date > date(month(today),day(today),year(today) - 2)
      and tt-holyday.holy-date < date(month(today),day(today),year(today) + 2) no-lock :
    holy-string = holy-string + "," + string(tt-holyday.holy-date) .
  end.
  holy-string = left-trim (holy-string , ",") .
  find first sysconf-attr exclusive-lock
       where sysconf-attr.attr-code  = "holyday"
         and sysconf-attr.host-code = 0 no-error .
  if not available sysconf-attr then do :
    create sysconf-attr .
    assign
      sysconf-attr.attr-code  = "holyday"
      sysconf-attr.host-code  = 0
    .
  end.
  sysconf-attr.attr-value = holy-string .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-month D-Dialog
PROCEDURE select-month :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-shift-value as integer no-undo .

  define variable v-current-month as integer no-undo .

  do with frame {&frame-name}:
    assign
      v-current-month = integer (cb-month :screen-value)
    .

    assign
      v-current-month = v-current-month + p-shift-value
    .
    if v-current-month < 1
    then do:
      assign
        v-current-month = 1
      .
    end.
    if v-current-month > 12
    then do:
      assign
        v-current-month = 12
      .
    end.

    assign
      cb-month :screen-value = string(v-current-month)
    .
  end.

  run display-month-name .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-year D-Dialog
PROCEDURE select-year :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-shift-value as integer no-undo .

  define variable v-current-year as integer no-undo .

  do with frame {&frame-name}:
    assign
      v-current-year = integer (fi-year :screen-value)
    .

    assign
      v-current-year = v-current-year + p-shift-value
    .
    if v-current-year < 0
    then do:
      assign
        v-current-year = 0
      .
    end.
    if v-current-year > 9999
    then do:
      assign
        v-current-year = 9999
      .
    end.

    assign
      fi-year :screen-value = string(v-current-year)
    .
  end.

  run display-month-name .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-box-state D-Dialog
PROCEDURE set-box-state :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter v-box-number as integer no-undo .
  define input parameter v-display-day as integer no-undo .

  if v-display-day = 0
  or v-display-day = ?
  then do:
    if v-day-handle  [v-box-number] :visible <> false
    then do:
      assign
        v-day-handle  [v-box-number] :visible = false
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> ""
    then do:
      assign
        v-day-handle  [v-box-number] :screen-value = ""
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> false
    then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = false
      .
    end.
    if v-rect-handle [v-box-number] :visible <> false
    then do:
      assign
        v-rect-handle [v-box-number] :visible = false
      .
    end.
  end.
  else do:
    if v-display-day > 0
    then do:
      /* это показывается текущий день месяца */
      if v-day-handle  [v-box-number] :visible <> true
      then do:
        assign
          v-day-handle  [v-box-number] :visible = true
        .
      end.
      if v-day-handle  [v-box-number] :screen-value <> string(v-display-day)
      then do:
        assign
          v-day-handle  [v-box-number] :screen-value = string(v-display-day)
        .
      end.

      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ).

      if  v-display-day = day(v-today)
      and v-curr-month  = month(v-today)
      and v-curr-year   = year(v-today)
      then do:
        if v-day-handle  [v-box-number] :bgcolor <> YELLOW_COLOR
        then do:
          assign
            v-day-handle  [v-box-number] :bgcolor = YELLOW_COLOR
          .
        end.
      end.
      else do:
        if v-day-handle  [v-box-number] :bgcolor <> GREY_COLOR
        then do:
          assign
            v-day-handle  [v-box-number] :bgcolor = GREY_COLOR
          .
        end.
      end.

      if v-display-day = v-curr-day
      then do:
        assign
          v-rect-handle [v-box-number] :bgcolor = GREEN_COLOR
        .
      end.
      else do:
        assign
          v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
        .
      end.
      if v-rect-handle [v-box-number] :visible <> true
      then do:
        assign
          v-rect-handle [v-box-number] :visible = true
        .
      end.
      if v-rect-handle  [v-box-number] :sensitive <> true
      then do:
        assign
          v-rect-handle  [v-box-number] :sensitive = true
        .
      end.
    end.
    else do:
      /* это показывается день предыдущего или последующего месяца */
      if v-day-handle  [v-box-number] :visible <> true
      then do:
        assign
          v-day-handle  [v-box-number] :visible = true
        .
      end.
      if v-day-handle  [v-box-number] :screen-value <> string(abs(v-display-day))
      then do:
        assign
          v-day-handle  [v-box-number] :screen-value = string(abs(v-display-day))
        .
      end.
      if v-day-handle  [v-box-number] :bgcolor <> ?
      then do:
        assign
          v-day-handle  [v-box-number] :bgcolor = ?
        .
      end.
      if v-rect-handle  [v-box-number] :sensitive <> false
      then do:
        assign
          v-rect-handle  [v-box-number] :sensitive = false
        .
      end.
      if v-rect-handle [v-box-number] :visible <> false
      then do:
        assign
          v-rect-handle [v-box-number] :visible = false
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-box-state-holy D-Dialog
PROCEDURE set-box-state-holy :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter v-box-number as integer no-undo .
  define input parameter v-display-day as integer no-undo .

  if v-display-day > 0
  then do:
    if v-rect-handle [v-box-number] :bgcolor <> GREEN_COLOR then do :
      if  v-rect-handle [v-box-number] :bgcolor <> RED_COLOR
      then do:
        assign
          v-rect-handle [v-box-number] :bgcolor = RED_COLOR
        .
        find first tt-holyday no-lock
        where tt-holyday.holy-date = date(v-curr-month,v-display-day,v-curr-year) no-error.
        if not available tt-holyday then do :
          create tt-holyday.
          assign
            holy-date = date(v-curr-month,v-display-day,v-curr-year)
          .
        end.
      end.
      else do:
        assign
          v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
        .
        find first tt-holyday no-lock
        where tt-holyday.holy-date = date(v-curr-month,v-display-day,v-curr-year) no-error.
        if available tt-holyday then do :
          delete tt-holyday.
        end.
      end.
    end.
    else do :
      find first tt-holyday no-lock
      where tt-holyday.holy-date = date(v-curr-month,v-display-day,v-curr-year) no-error.
        if not available tt-holyday then do :
          create tt-holyday.
          assign
            holy-date = date(v-curr-month,v-display-day,v-curr-year)
          .
        end.
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-curr-day D-Dialog
PROCEDURE set-curr-day :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-rect-name as character no-undo .

  define variable v-box-ind as integer no-undo .

  assign
    v-box-ind = integer (substring (p-rect-name, 6))
  .

  define variable v-new-day as integer no-undo .
  define variable v-old-day as integer no-undo .
  assign
    v-new-day = if  v-box-ind >= v-month-offset + 1
                and v-box-ind <= v-month-offset + v-last-day
                then v-box-ind - v-month-offset
                else 0
  .

  if  v-new-day <> 0
  and v-new-day <> v-curr-day
  then do:
    assign
      v-old-day = v-curr-day
      v-curr-day = v-new-day
    .
    run set-box-state
      (input v-old-day + v-month-offset
      ,input v-old-day
      ).
    if can-find(first tt-holyday where tt-holyday.holy-date = date(v-curr-month,v-old-day,v-curr-year))
    then do :
      run set-box-state-holy
        (input v-old-day + v-month-offset
        ,input v-old-day
        ).
    end.
    run set-box-state
      (input v-new-day + v-month-offset
      ,input v-new-day
      ).

    do with frame {&frame-name}:
      assign
        FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
      .
      run check-holyday in this-procedure
        (input v-curr-month
        ,input v-curr-day
        ) .
      if  p-description <> ""
      and index(p-description, '&1':u) > 0
      then do:
        define variable v-date-description as character no-undo .
        run date-str in this-procedure
          (input  date(v-curr-month, v-curr-day, v-curr-year)
          ,output v-date-description
          ) .
        assign
          editor-description :screen-value = substitute(p-description, v-date-description)
        .
      end.
    end. /* do with frame */
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-curr-day D-Dialog
PROCEDURE set-holy-day :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-rect-name as character no-undo .

  define variable v-box-ind as integer no-undo .

  assign
    v-box-ind = integer (substring (p-rect-name, 6))
  .
  define variable v-new-day as integer no-undo .
  define variable v-old-day as integer no-undo .
  assign
    v-new-day = if  v-box-ind >= v-month-offset + 1
                and v-box-ind <= v-month-offset + v-last-day
                then v-box-ind - v-month-offset
                else 0
  .
  if  v-new-day <> 0
  then do:
    run set-box-state-holy
      (input v-new-day + v-month-offset
      ,input v-new-day
      ).
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-date D-Dialog
PROCEDURE set-date :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-date as date      no-undo .

  do with frame {&frame-name}:
    assign
      CB-Month                = month(p-date)
      CB-Month :screen-value  = string(month(p-date))
      FI-Year                 = year(p-date)
      FI-Year  :screen-value  = string(year(p-date))
      v-curr-day              = day(p-date)
    .
  end. /* do with frame */

  run display-month-name in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME