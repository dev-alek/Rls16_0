&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
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

Выбор несколько дат

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/16/04 4:49

*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define temp-table temp-dates no-undo
field dates as date
index pi is unique primary   dates .

define input        parameter p-buttons  as character no-undo .
define input        parameter p-title    as character no-undo .
define input        parameter h-callback as handle    no-undo .
define input-output parameter p-date     as date      no-undo .
define output       parameter p-ok       as logical   no-undo .
define input-output parameter table for  temp-dates append   .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "выбор несколько дат".
{ cmp/vssrevis.i }
{ gbl/color.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
define variable v-date         as date no-undo .

define variable v-curr-day     as integer no-undo .
define variable v-month-begin as date no-undo .
define variable v-curr-month  as integer no-undo .
define variable v-curr-year   as integer no-undo .
define variable v-last-day    as integer no-undo .

define variable v-month-offset as integer no-undo .
define variable v-day-handle   as handle no-undo extent 42 .
define variable v-rect-handle  as handle no-undo extent 42 .
define variable v-old-mode as logical no-undo .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help CB-Month b-prev-month ~
b-next-month FI-Year b-prev-year b-next-year fi-month-name
&Scoped-Define DISPLAYED-OBJECTS CB-Month FI-Year

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

DEFINE BUTTON b-next-month
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-next-year
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-month
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-year
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CB-Month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "         1","         2","         3","         4","         5","         6","         7","         8","         9","        10","        11","        12"
     DROP-DOWN-LIST
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE FI-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

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
     SIZE 28.5 BY .67 NO-UNDO.

DEFINE VARIABLE FI-Year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

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
     b-help AT ROW 1 COL 50.5
     CB-Month AT ROW 3.58 COL 10.5 COLON-ALIGNED
     b-prev-month AT ROW 3.58 COL 20.75
     b-next-month AT ROW 3.58 COL 24.75
     FI-Year AT ROW 4.83 COL 10.5 COLON-ALIGNED
     b-prev-year AT ROW 4.92 COL 20.75
     b-next-year AT ROW 4.92 COL 24.75
     FI-date AT ROW 2.5 COL 10.5 COLON-ALIGNED
     fi-month-name AT ROW 3.75 COL 28 COLON-ALIGNED NO-LABEL
     FI-header-1 AT ROW 6.33 COL 5.25 COLON-ALIGNED NO-LABEL
     FI-header-2 AT ROW 6.33 COL 12.25 COLON-ALIGNED NO-LABEL
     FI-header-3 AT ROW 6.33 COL 19 COLON-ALIGNED NO-LABEL
     FI-header-4 AT ROW 6.33 COL 25.75 COLON-ALIGNED NO-LABEL
     FI-header-5 AT ROW 6.33 COL 32.75 COLON-ALIGNED NO-LABEL
     FI-header-6 AT ROW 6.33 COL 39.5 COLON-ALIGNED NO-LABEL
     FI-header-7 AT ROW 6.33 COL 46.25 COLON-ALIGNED NO-LABEL
     FI-day-1 AT ROW 8.08 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-2 AT ROW 8.08 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-3 AT ROW 8.08 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-4 AT ROW 8.08 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-5 AT ROW 8.08 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-6 AT ROW 8.08 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-7 AT ROW 8.08 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-8 AT ROW 10 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-9 AT ROW 10 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-10 AT ROW 10 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-11 AT ROW 10 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-12 AT ROW 10 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-13 AT ROW 10 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-14 AT ROW 10 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-15 AT ROW 12 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-16 AT ROW 12 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-17 AT ROW 12 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-18 AT ROW 12 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-19 AT ROW 12 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-20 AT ROW 12 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-21 AT ROW 12 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-22 AT ROW 13.92 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-23 AT ROW 13.92 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-24 AT ROW 13.92 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-25 AT ROW 13.92 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-26 AT ROW 13.92 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-27 AT ROW 13.92 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-28 AT ROW 13.92 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-29 AT ROW 15.83 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-30 AT ROW 15.83 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-31 AT ROW 15.83 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-32 AT ROW 15.83 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-33 AT ROW 15.83 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-34 AT ROW 15.83 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-35 AT ROW 15.83 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-36 AT ROW 17.83 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-37 AT ROW 17.83 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-38 AT ROW 17.83 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-39 AT ROW 17.83 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-40 AT ROW 17.83 COL 33 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME D-Dialog
     FI-day-41 AT ROW 17.83 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-42 AT ROW 17.83 COL 46.75 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 7.58 COL 6
     RECT-42 AT ROW 17.33 COL 47.25
     RECT-41 AT ROW 17.33 COL 40.25
     RECT-40 AT ROW 17.33 COL 33.5
     RECT-39 AT ROW 17.33 COL 26.75
     RECT-38 AT ROW 17.33 COL 19.75
     RECT-37 AT ROW 17.33 COL 13
     RECT-36 AT ROW 17.33 COL 6
     RECT-35 AT ROW 15.33 COL 47.25
     RECT-11 AT ROW 9.5 COL 26.75
     RECT-34 AT ROW 15.33 COL 40.25
     RECT-33 AT ROW 15.33 COL 33.5
     RECT-32 AT ROW 15.33 COL 26.75
     RECT-31 AT ROW 15.33 COL 19.75
     RECT-30 AT ROW 15.33 COL 13
     RECT-29 AT ROW 15.33 COL 6
     RECT-28 AT ROW 13.42 COL 47.25
     RECT-27 AT ROW 13.42 COL 40.25
     RECT-26 AT ROW 13.42 COL 33.5
     RECT-25 AT ROW 13.42 COL 26.75
     RECT-24 AT ROW 13.42 COL 19.75
     RECT-23 AT ROW 13.42 COL 13
     RECT-22 AT ROW 13.42 COL 6
     RECT-21 AT ROW 11.5 COL 47.25
     RECT-20 AT ROW 11.5 COL 40.25
     RECT-19 AT ROW 11.5 COL 33.5
     RECT-18 AT ROW 11.5 COL 26.75
     RECT-17 AT ROW 11.5 COL 19.75
     RECT-16 AT ROW 11.5 COL 13
     RECT-15 AT ROW 11.5 COL 6
     RECT-14 AT ROW 9.5 COL 47.25
     RECT-13 AT ROW 9.5 COL 40.25
     RECT-12 AT ROW 9.5 COL 33.5
     RECT-10 AT ROW 9.5 COL 19.75
     RECT-9 AT ROW 9.5 COL 13
     RECT-8 AT ROW 9.5 COL 6
     RECT-7 AT ROW 7.58 COL 47.25
     RECT-6 AT ROW 7.58 COL 40.25
     RECT-5 AT ROW 7.58 COL 33.5
     RECT-4 AT ROW 7.58 COL 26.75
     RECT-3 AT ROW 7.58 COL 19.75
     RECT-2 AT ROW 7.58 COL 13
     SPACE(41.87) SKIP(11.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите месяц и год"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FI-date IN FRAME D-Dialog
   NO-DISPLAY NO-ENABLE                                                 */
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





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON GO OF FRAME D-Dialog /* Введите месяц и год */
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

  if v-date = ? then do:
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
    if h-callback :get-signature("validate-month-year") <> ""
    then do:
      define variable lok as logical no-undo .
      run validate-month-year in h-callback
        (input v-date
        ,output lok
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости месяца и года" skip
          "файл" h-callback :file-name skip
          "процедура" "validate-month-year" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if lok <> true then do:
        return no-apply . /* --->>>--- */
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки диапазона дат" skip
        "В указанной процедуре отсутствует внутренняя процедура validate-month-year " skip
        "файл" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
  end.

  assign
    p-date  = v-date
    p-ok = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Введите месяц и год */
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


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit D-Dialog
ON CHOOSE OF b-quit IN FRAME D-Dialog /* Отмена */
DO:
  { gbl/stdbtn.i }

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

if p-title <> "" then do:
  assign
    frame {&frame-name} :title = p-title
  .
end.

if p-buttons = ""
   then v-old-mode = true  .
   else v-old-mode = false .


on mouse-select-click of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  run set-curr-day
    (input self :name
    ).
end.

on mouse-select-dblclick of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:

  run set-curr-day
    (input self :name
    ).
  apply 'choose':u to b-exit .
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
  v-date = p-date
.
if v-date = ? then do:
  assign
    v-date = today
  .
end.

assign
  CB-Month                = month(v-date)
  CB-Month :screen-value  = string(month(v-date))
  FI-Year                 = year(v-date)
  FI-Year  :screen-value  = string(year(v-date))
  v-curr-day              = day(v-date)
.

assign
  p-ok = false
.


run display-month-name in this-procedure .

{ gbl/app_help.i }
{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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

  if v-curr-day > v-last-day then do:
    assign
      v-curr-day = v-last-day
    .
  end.
  if v-curr-day = ?
  or v-curr-day <= 0 then do:
    assign
      v-curr-day = 1
    .
  end.


  do with frame {&frame-name}:
    assign
      FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
    .
  end. /* do with frame */

  define variable ind as integer no-undo .

  define variable l-immediate-display as logical no-undo .
  assign
    l-immediate-display        = session :immediate-display
    session :immediate-display = false
  .

  v-curr-day = ? .
  do ind = 1 to 42 :
    run set-box-state in this-procedure
      (input ind
      ,input  (if ind  >= v-month-offset + 1
              and ind <= v-month-offset + v-last-day
              then ind - v-month-offset
              else 0
             )
      ).
  end.

  assign
    session :immediate-display = l-immediate-display
  .


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  DISPLAY CB-Month FI-Year
      WITH FRAME D-Dialog.
  ENABLE b-exit b-quit b-help CB-Month b-prev-month b-next-month FI-Year
         b-prev-year b-next-year fi-month-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
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
    if v-current-month < 1 then do:
      assign
        v-current-month = 1
      .
    end.
    if v-current-month > 12 then do:
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
    if v-current-year < 0 then do:
      assign
        v-current-year = 0
      .
    end.
    if v-current-year > 9999 then do:
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
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
  or v-display-day = ? then do:
    if v-day-handle  [v-box-number] :visible <> false then do:
      assign
        v-day-handle  [v-box-number] :visible = false
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> "" then do:
      assign
        v-day-handle  [v-box-number] :screen-value = ""
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> false then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = false
      .
    end.
    if v-rect-handle [v-box-number] :visible <> false then do:
      assign
        v-rect-handle [v-box-number] :visible = false
      .
    end.
  end.
  else do:
    if v-day-handle  [v-box-number] :visible <> true then do:
      assign
        v-day-handle  [v-box-number] :visible = true
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> string(v-display-day) then do:
      assign
        v-day-handle  [v-box-number] :screen-value = string(v-display-day)
      .
    end.
    if v-display-day = v-curr-day then do:

        if v-old-mode then do:
           v-rect-handle [v-box-number] :bgcolor = RED_COLOR .
        end.
        else do:
           v-rect-handle [v-box-number] :bgcolor =  BLUE_COLOR .
        end.

    end.
    else do:
      assign
        v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
      .
    end.
    if v-rect-handle [v-box-number] :visible <> true then do:
      assign
        v-rect-handle [v-box-number] :visible = true
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> true then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = true
      .
    end.
  end.

END PROCEDURE.

PROCEDURE del-box-state :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter v-box-number as integer no-undo .
  define input parameter v-display-day as integer no-undo .

  if v-display-day = 0
  or v-display-day = ? then do:
    if v-day-handle  [v-box-number] :visible <> false then do:
      assign
        v-day-handle  [v-box-number] :visible = false
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> "" then do:
      assign
        v-day-handle  [v-box-number] :screen-value = ""
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> false then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = false
      .
    end.
    if v-rect-handle [v-box-number] :visible <> false then do:
      assign
        v-rect-handle [v-box-number] :visible = false
      .
    end.
  end.
  else do:
    if v-day-handle  [v-box-number] :visible <> true then do:
      assign
        v-day-handle  [v-box-number] :visible = true
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> string(v-display-day) then do:
      assign
        v-day-handle  [v-box-number] :screen-value = string(v-display-day)
      .
    end.
    if v-display-day = v-curr-day then do:
      assign
        v-rect-handle [v-box-number] :bgcolor = Grey_COLOR
      .
    end.
    else do:
      assign
        v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
      .
    end.
    if v-rect-handle [v-box-number] :visible <> true then do:
      assign
        v-rect-handle [v-box-number] :visible = true
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> true then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = true
      .
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
  and v-new-day <> v-curr-day then do:
    assign
      v-old-day = v-curr-day
      v-curr-day = v-new-day
    .
    /*-----------*/
    if v-old-mode = true then do:
        run set-box-state
          (input v-old-day + v-month-offset
          ,input v-old-day
          ).

    end.

   run set-box-state
      (input v-new-day + v-month-offset
      ,input v-new-day
      ).

    if v-old-mode = false  then do:
     if not can-find (first temp-dates where temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) ) then do:
          create temp-dates no-error .
          assign temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) no-error .
        end.
        Else do:
            run del-box-state
              (input v-new-day + v-month-offset
              ,input v-new-day  ).

             find first temp-dates where temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) no-error .
             delete temp-dates no-error .
             v-rect-handle [v-curr-day] :bgcolor = GREY_COLOR.
        end.
    end.

            do with frame {&frame-name}:
              assign
                FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
              .
            end. /* do with frame */



  end.



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