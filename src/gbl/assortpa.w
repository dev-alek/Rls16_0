&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE x_thbj-attr NO-UNDO LIKE ub.thbj-attr
       field p1 as char
       field d1 as int
       field d2 as int
       field d3 as int
       field d4 as int
       field d5 as int
       field d6 as int
       field d7 as int
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные параметры Ассортиментной политики

Автор: Чернова Светлана Александровна
Дата создания: 02/11/02
Author: Svetlana Chernova
Creation date: 02/11/02

This .W file was created with the Progress AppBuilder.

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры Ассортиментной политики" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer abc_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-abc no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-abc as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable p-mode as character no-undo .
define variable str-attr as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-tth-abc = buffer thbjattr_thbj-attr-abc:table-handle .
if g#db-num = 0 then p-mode = {&update}.
   else p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_thbj-attr

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 X_thbj-attr.p1 X_thbj-attr.obj-type X_thbj-attr.obj-code X_thbj-attr.d1 X_thbj-attr.d2 X_thbj-attr.d3 X_thbj-attr.d4 X_thbj-attr.d5 X_thbj-attr.d6   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2   
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH X_thbj-attr        NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr        NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 X_thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 X_thbj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help I-abc-mode I-abc-type ~
I-abc-one I-abc-two I-abc-sale-day abc-mode abc-type loc-abc-one_1 ~
loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 ~
loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 ~
loc-abc-two_5 loc-a loc-b loc-c loc-d loc-e loc-f BROWSE-2 v-abc-mode ~
v-abc-type v-abc-one v-abc-two v-abc-sale-day 
&Scoped-Define DISPLAYED-OBJECTS abc-mode abc-type loc-abc-one_1 ~
loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 ~
loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 ~
loc-abc-two_5 loc-a loc-b loc-c loc-d loc-e loc-f v-abc-mode v-abc-type ~
v-abc-one v-abc-two v-abc-sale-day 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE loc-a AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "A" NO-UNDO.

DEFINE VARIABLE loc-abc-one_1 AS DECIMAL FORMAT ">9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-one_2 AS DECIMAL FORMAT ">9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-one_3 AS DECIMAL FORMAT ">>9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-one_4 AS DECIMAL FORMAT ">>9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-one_5 AS DECIMAL FORMAT ">>9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-one_6 AS DECIMAL FORMAT ">>9.<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_1 AS DECIMAL FORMAT ">9.999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_2 AS DECIMAL FORMAT ">9.999":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_3 AS DECIMAL FORMAT ">9.9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_4 AS DECIMAL FORMAT ">9.9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_5 AS DECIMAL FORMAT ">9.999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE loc-abc-two_6 AS DECIMAL FORMAT ">>9":U INITIAL 100 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE loc-b AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "B" NO-UNDO.

DEFINE VARIABLE loc-c AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "C" NO-UNDO.

DEFINE VARIABLE loc-d AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "D" NO-UNDO.

DEFINE VARIABLE loc-e AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "E" NO-UNDO.

DEFINE VARIABLE loc-f AS INTEGER FORMAT ">>>>>>>":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 TOOLTIP "F" NO-UNDO.

DEFINE VARIABLE v-abc-mode AS CHARACTER FORMAT "X(256)":U INITIAL "Способ проведения АБС анализа" 
      VIEW-AS TEXT 
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-abc-one AS CHARACTER FORMAT "X(256)":U INITIAL "Проценты по умолчанию для простого АБС анализа .Уровни ранжирования" 
      VIEW-AS TEXT 
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-abc-sale-day AS CHARACTER FORMAT "X(256)":U INITIAL "Гарантийный запас по АВС в днях" 
      VIEW-AS TEXT 
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-abc-two AS CHARACTER FORMAT "X(256)":U INITIAL "Проценты по умолчанию для двухпроходного АБС анализа" 
      VIEW-AS TEXT 
     SIZE 82 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-abc-type AS CHARACTER FORMAT "X(256)":U INITIAL "Количество параметров для АБС анализа" 
      VIEW-AS TEXT 
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE I-abc-mode
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.5.

DEFINE IMAGE I-abc-one
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.

DEFINE IMAGE I-abc-sale-day
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.

DEFINE IMAGE I-abc-two
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.

DEFINE IMAGE I-abc-type
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 2.75.

DEFINE VARIABLE abc-mode AS CHARACTER INITIAL "simple" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Простой", "simple",
"Двухуровневый", "bimodal"
     SIZE 16 BY 1.75 NO-UNDO.

DEFINE VARIABLE abc-type AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "ABC", "ABC",
"ABCD", "ABCD",
"ABCDE", "ABCDE",
"ABCDEF", "ABCDEF"
     SIZE 9.5 BY 3 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      X_thbj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      X_thbj-attr.p1 FORMAT "X(8)":U COLUMN-LABEL " "
      X_thbj-attr.obj-type FORMAT "X(3)":U
      X_thbj-attr.obj-code FORMAT ">>>>>>>>>":U
      X_thbj-attr.d1  COLUMN-LABEL "A" FORMAT ">>>>":U
      X_thbj-attr.d2  COLUMN-LABEL "B" FORMAT ">>>>":U
      X_thbj-attr.d3  COLUMN-LABEL "C" FORMAT ">>>>":U
      X_thbj-attr.d4  COLUMN-LABEL "D" FORMAT ">>>>":U
      X_thbj-attr.d5  COLUMN-LABEL "E" FORMAT ">>>>":U
      X_thbj-attr.d6  COLUMN-LABEL "F" FORMAT ">>>>":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 6.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     abc-mode AT ROW 3 COL 4.75 NO-LABEL WIDGET-ID 2
     abc-type AT ROW 6 COL 4.75 NO-LABEL WIDGET-ID 12
     loc-abc-one_1 AT ROW 9.75 COL 2.75 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     loc-abc-one_2 AT ROW 9.75 COL 8 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     loc-abc-one_3 AT ROW 9.75 COL 13.13 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     loc-abc-one_4 AT ROW 9.75 COL 19.25 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     loc-abc-one_5 AT ROW 9.75 COL 25.25 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     loc-abc-one_6 AT ROW 9.75 COL 31.25 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     loc-abc-two_1 AT ROW 12 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     loc-abc-two_2 AT ROW 12 COL 14 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     loc-abc-two_3 AT ROW 13.04 COL 8.75 NO-LABEL WIDGET-ID 46
     loc-abc-two_4 AT ROW 13.04 COL 12.13 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     loc-abc-two_6 AT ROW 13.04 COL 17.5 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     loc-abc-two_5 AT ROW 14.13 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     loc-a AT ROW 17 COL 2.75 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     loc-b AT ROW 17 COL 7.88 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     loc-c AT ROW 17 COL 12.88 COLON-ALIGNED NO-LABEL WIDGET-ID 76
     loc-d AT ROW 17 COL 17.88 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     loc-e AT ROW 17 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     loc-f AT ROW 17 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     BROWSE-2 AT ROW 17 COL 36.5 WIDGET-ID 200
     v-abc-mode AT ROW 2.25 COL 1.5 NO-LABEL WIDGET-ID 6
     v-abc-type AT ROW 5.25 COL 1.5 NO-LABEL WIDGET-ID 18
     v-abc-one AT ROW 9 COL 1.5 NO-LABEL WIDGET-ID 20
     v-abc-two AT ROW 11 COL 1.5 NO-LABEL WIDGET-ID 38
     v-abc-sale-day AT ROW 16 COL 1.5 NO-LABEL WIDGET-ID 68
     "IIa." VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 13.08 COL 4.75 WIDGET-ID 54
          FGCOLOR 4 
     "IIb." VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 14.13 COL 4.75 WIDGET-ID 56
          FGCOLOR 4 
     "%% ABC-анализа внутри первой группы" VIEW-AS TEXT
          SIZE 36.5 BY 1 AT ROW 13 COL 25 WIDGET-ID 66
          FGCOLOR 1 
     "% Первой группы" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 12 COL 23.5 WIDGET-ID 64
          FGCOLOR 1 
     "% отсекания" VIEW-AS TEXT
          SIZE 11.75 BY 1 AT ROW 14.13 COL 16.25 WIDGET-ID 62
          FGCOLOR 1 
     "I." VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 12 COL 4.75 WIDGET-ID 52
          FGCOLOR 4 
     I-abc-mode AT ROW 3.04 COL 2.5 WIDGET-ID 10
     I-abc-type AT ROW 6 COL 2.5 WIDGET-ID 34
     I-abc-one AT ROW 9.83 COL 2.38 WIDGET-ID 36
     I-abc-two AT ROW 12.13 COL 2.25 WIDGET-ID 40
     I-abc-sale-day AT ROW 17.13 COL 2.5 WIDGET-ID 70
     SPACE(82.62) SKIP(5.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки ассортиментной политики"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x_thbj-attr T "?" NO-UNDO ub thbj-attr
      ADDITIONAL-FIELDS:
          field p1 as char
          field d1 as int
          field d2 as int
          field d3 as int
          field d4 as int
          field d5 as int
          field d6 as int
          field d7 as int
          
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 loc-f Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       loc-abc-two_2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN loc-abc-two_3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       loc-abc-two_6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-abc-mode IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-abc-mode:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-abc-one IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-abc-one:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-abc-sale-day IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-abc-sale-day:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-abc-two IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-abc-two:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-abc-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-abc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr
       NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_thbj-attr.upper-prop-code = ""abc-sale-day"""
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки ассортиментной политики */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки ассортиментной политики */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME abc-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL abc-mode Dialog-Frame
ON VALUE-CHANGED OF abc-mode IN FRAME Dialog-Frame
DO:
  ASSIGN abc-mode .
  IF abc-mode = 'bimodal' THEN DO:
          abc-type = 'ABC'.
      DISPLAY abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME {&FRAME-NAME}.
      DISABLE abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME {&FRAME-NAME}.
      ENABLE loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
          WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:

      ENABLE abc-type
          loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
          WITH FRAME {&FRAME-NAME} .
          /*loc-abc-two_1 = 0 .
          loc-abc-two_2 = 0 .
          loc-abc-two_3 = 0 .
          loc-abc-two_4 = 0 .
          loc-abc-two_5 = 0 .
          loc-abc-two_6 = 0 . */
      DISPLAY loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
              WITH FRAME {&FRAME-NAME}.
      DISABLE
          loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
          WITH FRAME {&FRAME-NAME}.

  END.
  APPLY "VALUE-CHANGED":U TO abc-type .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME abc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL abc-type Dialog-Frame
ON VALUE-CHANGED OF abc-type IN FRAME Dialog-Frame
DO:
  ASSIGN abc-type.
  display loc-a loc-b loc-c loc-d loc-e loc-f  WITH FRAME {&FRAME-NAME} .
  CASE abc-type:
      WHEN 'ABC' THEN DO:
          loc-abc-one_6 = 0 .
          loc-abc-one_5 = 0 .
          loc-abc-one_4 = 0 .
          loc-abc-one_3 = 100 .
          loc-e = 0.
          loc-d = 0.
          loc-f = 0.
          display loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-f loc-e loc-d WITH FRAME {&FRAME-NAME} .
          DISABLE loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-f loc-e loc-d WITH FRAME {&FRAME-NAME} .
          IF abc-mode = 'simple' THEN DO:
              ENABLE loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 WITH FRAME {&FRAME-NAME} .

              ENABLE loc-a loc-b loc-c WITH FRAME {&FRAME-NAME} .
           END.
           ELSE ENABLE loc-a loc-b loc-c loc-d loc-e WITH FRAME {&FRAME-NAME} .
      END.
      WHEN 'ABCD' THEN DO:
       loc-abc-one_4 = 100 .
       loc-abc-one_5 = 0 .
       loc-abc-one_6 = 0 .
       loc-e = 0.
       loc-f = 0.

       DISplay loc-abc-one_5 loc-abc-one_6 loc-f loc-e  WITH FRAME {&FRAME-NAME} .
       DISABLE loc-abc-one_5 loc-abc-one_6 loc-f loc-e  WITH FRAME {&FRAME-NAME} .
       ENABLE  loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-a loc-b loc-c loc-d WITH FRAME {&FRAME-NAME} .
      END.
      WHEN 'ABCDE' THEN DO:
       loc-abc-one_5 = 100 .
       loc-abc-one_6 = 0 .
       loc-f = 0.
       DISplay  loc-abc-one_6 loc-f  WITH FRAME {&FRAME-NAME} .
       DISABLE  loc-abc-one_6 loc-f WITH FRAME {&FRAME-NAME} .
       ENABLE loc-abc-one_5 loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-a loc-b loc-c loc-d loc-e WITH FRAME {&FRAME-NAME} .
      END.
      WHEN 'ABCDEF' THEN DO:
          loc-abc-one_6 = 100 .
          ENABLE loc-abc-one_5 loc-abc-one_6 loc-abc-one_4 loc-abc-one_1 loc-abc-one_2 loc-abc-one_3
           loc-f loc-e loc-d loc-a loc-b loc-c
           WITH FRAME {&FRAME-NAME} .
      END.

  END CASE.

  if  loc-abc-one_1 = 0 and loc-abc-one_1:SENSITIVE = false then hide loc-abc-one_1 in frame {&frame-name} .
  if  loc-abc-one_2 = 0 and loc-abc-one_2:SENSITIVE = false then hide loc-abc-one_2 in frame {&frame-name} .
  if  loc-abc-one_3 = 0 and loc-abc-one_3:SENSITIVE = false then hide loc-abc-one_3 in frame {&frame-name} .
  if  loc-abc-one_4 = 0 and loc-abc-one_4:SENSITIVE = false then hide loc-abc-one_4 in frame {&frame-name} .
  if  loc-abc-one_5 = 0 and loc-abc-one_5:SENSITIVE = false then hide loc-abc-one_5 in frame {&frame-name} .
  if  loc-abc-one_6 = 0 and loc-abc-one_6:SENSITIVE = false then hide loc-abc-one_6 in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-abc-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-abc-mode Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-abc-mode IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-abc-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-abc-one Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-abc-one IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-abc-sale-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-abc-sale-day Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-abc-sale-day IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-abc-two
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-abc-two Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-abc-two IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-abc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-abc-type Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-abc-type IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-abc-two_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-abc-two_1 Dialog-Frame
ON LEAVE OF loc-abc-two_1 IN FRAME Dialog-Frame
DO:
  ASSIGN loc-abc-two_1.
  loc-abc-two_2 = 100 - loc-abc-two_1.
  DISPLAY loc-abc-two_2 WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
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

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-assort_lookup':U
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
  if loc#log <> yes then do: return . end.
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY abc-mode abc-type loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 
          loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-abc-two_1 loc-abc-two_2 
          loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 loc-abc-two_5 loc-a loc-b 
          loc-c loc-d loc-e loc-f v-abc-mode v-abc-type v-abc-one v-abc-two 
          v-abc-sale-day 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-abc-mode I-abc-type I-abc-one I-abc-two 
         I-abc-sale-day abc-mode abc-type loc-abc-one_1 loc-abc-one_2 
         loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 loc-abc-two_1 
         loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_6 loc-abc-two_5 
         loc-a loc-b loc-c loc-d loc-e loc-f BROWSE-2 v-abc-mode v-abc-type 
         v-abc-one v-abc-two v-abc-sale-day 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

define variable temp-v-abc-one as character no-undo .
define variable temp-v-abc-two as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-abc:
  delete thbjattr_thbj-attr-abc.
end.

for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-abc-sale-day}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-abc-global}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-abc
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

FOR EACH thbjattr_thbj-attr:
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_A} THEN DO:
    loc-a = thbjattr_thbj-attr.property-value-integer.
    loc-a:private-data IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_B} THEN DO:
    loc-b = thbjattr_thbj-attr.property-value-integer.
    loc-b:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_C} THEN DO:
    loc-c = thbjattr_thbj-attr.property-value-integer.
    loc-c:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_D} THEN DO:
    loc-d = thbjattr_thbj-attr.property-value-integer.
    loc-d:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_E} THEN DO:
    loc-e = thbjattr_thbj-attr.property-value-integer.
    loc-e:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_F} THEN DO:
    loc-f = thbjattr_thbj-attr.property-value-integer.
    loc-f:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.

FOR EACH thbjattr_thbj-attr-abc:
  IF thbjattr_thbj-attr-abc.prop-code = {&attr-abc-global_abc-mode} THEN DO:
     abc-mode = thbjattr_thbj-attr-abc.property-value-character.
     abc-mode:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-abc)).
     display abc-mode with frame {&frame-name} .

  END.
  IF thbjattr_thbj-attr-abc.prop-code = {&attr-abc-global_abc-type} THEN DO:
     abc-type = thbjattr_thbj-attr-abc.property-value-character.
     abc-type:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-abc)).
     display abc-type with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-abc.prop-code = {&attr-abc-global_abc-one} THEN DO:
     temp-v-abc-one = thbjattr_thbj-attr-abc.property-value-character.
     loc-abc-one_1 = if num-entries (temp-v-abc-one,"/") >= 1 then decimal(entry(1,temp-v-abc-one,"/")) else 0.
     loc-abc-one_2 = if num-entries (temp-v-abc-one,"/") >= 2 then decimal(entry(2,temp-v-abc-one,"/")) else 0.
     loc-abc-one_3 = if num-entries (temp-v-abc-one,"/") >= 3 then decimal(entry(3,temp-v-abc-one,"/")) else 0.
     loc-abc-one_4 = if num-entries (temp-v-abc-one,"/") >= 4 then decimal(entry(4,temp-v-abc-one,"/")) else 0.
     loc-abc-one_5 = if num-entries (temp-v-abc-one,"/") >= 5 then decimal(entry(5,temp-v-abc-one,"/")) else 0.
     loc-abc-one_6 = if num-entries (temp-v-abc-one,"/") >= 6 then decimal(entry(6,temp-v-abc-one,"/")) else 0.
     display loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6 with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-abc.prop-code = {&attr-abc-global_abc-two} THEN DO:
     temp-v-abc-two = thbjattr_thbj-attr-abc.property-value-character.
     loc-abc-two_1 = decimal(entry(1,entry(1,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_1 = 0 .
     loc-abc-two_2 = decimal(entry(2,entry(1,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_2 = 0 .
     loc-abc-two_3 = decimal(entry(1,entry(2,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_3 = 0 .
     loc-abc-two_4 = decimal(entry(2,entry(2,temp-v-abc-two,";"),"/")) no-error .
     if error-status :error then loc-abc-two_4 = 0 .
     loc-abc-two_6 = 100.
     loc-abc-two_5 = decimal(entry(3,temp-v-abc-two,";")) no-error .
     if error-status :error then loc-abc-two_5 = 0 .
     display loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6 with frame {&frame-name} .
  END.

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-abc to temp-thbj-attr.
END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
             input   {&attr-abc-sale-day}
            ,input  ""
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .

v-abc-sale-day:screen-value = v-label .
i-abc-sale-day:private-data = v-tooltip .

run thbjattr_tooltip in this-procedure (
             input   {&attr-abc-global}
            ,input  "abc-mode"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-mode:screen-value = entry(2,v-label,":") .
I-abc-mode:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-abc-global}
            ,input  "abc-type"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-type:screen-value = entry(2,v-label,":") .
I-abc-type:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-abc-global}
            ,input  "abc-one"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-one:screen-value = entry(2,v-label,":") .
I-abc-one:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-abc-global}
            ,input  "abc-two"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-abc-two:screen-value = entry(2,v-label,":") .
I-abc-two:private-data = v-tooltip-code .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = {&update} then do:
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = ""
        and   buf_thbj-attr.obj-code = 0
        and   buf_thbj-attr.upper-prop-code = {&attr-abc-sale-day}
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-abc-sale-day} skip
        "Запись Глобальных ПАРАМЕТРОВ занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first abc_thbj-attr exclusive-lock where
              abc_thbj-attr.obj-type = ""
        and   abc_thbj-attr.obj-code = 0
        and   abc_thbj-attr.upper-prop-code = {&attr-abc-global}
        and   abc_thbj-attr.prop-code = '':u no-wait no-error.
     if locked abc_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-abc-global} skip
        "Запись Глобальных ПАРАМЕТРОВ abc занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = ""
    and   buf_thbj-attr.obj-code = 0
    and   buf_thbj-attr.upper-prop-code = {&attr-abc-sale-day}
    and   buf_thbj-attr.prop-code = '':u no-error.
    find first abc_thbj-attr no-lock where
          abc_thbj-attr.obj-type = ""
    and   abc_thbj-attr.obj-code = 0
    and   abc_thbj-attr.upper-prop-code = {&attr-abc-global}
    and   abc_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create  = true
      .
    message
    substitute ("Внимание!!!&1Параметра &1&2&1НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line},
                v-abc-sale-day:screen-value in frame {&frame-name}  )
                 view-as alert-box warning.
  end.
  if not available abc_thbj-attr then do:
    assign
      v-to-create-abc  = true
      .
    message
    substitute ("Внимание!!!&1Параметра abc НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.
  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  apply "value-changed":u to abc-mode in frame {&frame-name}.
  if p-mode <> {&update} then do:
     disable abc-mode abc-type with frame {&frame-name}.
     loc-abc-one_1:read-only = true .
     loc-abc-one_2:read-only = true .
     loc-abc-one_3:read-only = true .
     loc-abc-one_4:read-only = true .
     loc-abc-one_5:read-only = true .
     loc-abc-one_6:read-only = true .
     loc-abc-two_1:read-only = true .
     loc-abc-two_2:read-only = true .
     loc-abc-two_3:read-only = true .
     loc-abc-two_4:read-only = true .
     loc-abc-two_5:read-only = true .
     loc-abc-two_6:read-only = true .
     loc-a:read-only = true .
     loc-b:read-only = true .
     loc-c:read-only = true .
     loc-d:read-only = true .
     loc-e:read-only = true .
     loc-f:read-only = true .
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .

  END.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_thbj-attr for ub.thbj-attr .

for each buf_thbj-attr no-lock where
         buf_thbj-attr.upper-prop-code = "abc-sale-day" and
         buf_thbj-attr.prop-code <> "" Break by buf_thbj-attr.obj-type by buf_thbj-attr.obj-code :
   find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .

        if not available x_thbj-attr then do:
          create  x_thbj-attr.
          assign
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code
          .
        end.

       if buf_thbj-attr.obj-type  = "" then
        assign
          x_thbj-attr.p1 = "глобально"
        .
       if buf_thbj-attr.obj-type  = {&cmp} then
        assign
          x_thbj-attr.p1 = "фирма"
        .
       if buf_thbj-attr.obj-type  <> {&cmp} and buf_thbj-attr.obj-type  <> "" then
        assign
          x_thbj-attr.p1 = "объект"
        .

       case buf_thbj-attr.prop-code :
       when "A" then
            assign
             x_thbj-attr.d1 = buf_thbj-attr.property-value-integer
            .
       when "B" then
            assign
             x_thbj-attr.d2 = buf_thbj-attr.property-value-integer
            .
       when "C" then
            assign
             x_thbj-attr.d3 = buf_thbj-attr.property-value-integer
            .
       when "D" then
            assign
             x_thbj-attr.d4 = buf_thbj-attr.property-value-integer
            .
       when "E" then
            assign
             x_thbj-attr.d5 = buf_thbj-attr.property-value-integer
            .
       when "F" then
            assign
             x_thbj-attr.d6 = buf_thbj-attr.property-value-integer
            .
       end case.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-assort_update':U
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
  if loc#log <> yes then do: return error. end.

ASSIGN
    abc-mode FRAME {&FRAME-NAME}
    abc-type
    loc-abc-one_1 loc-abc-one_2 loc-abc-one_3 loc-abc-one_4 loc-abc-one_5 loc-abc-one_6
    loc-abc-two_1 loc-abc-two_2 loc-abc-two_3 loc-abc-two_4 loc-abc-two_5 loc-abc-two_6
    loc-a loc-b loc-c loc-d loc-e loc-f
    .

 if abc-mode = "simple" then do:
 if abc-type = "ABC"  then do:
     if loc-abc-one_3 <> 100 then message "Внимание! Меняю " loc-abc-one_3 " на 100% "  view-as alert-box information .
     loc-abc-one_3  = 100 .
     loc-abc-one_4 = 0 .
     loc-abc-one_5 = 0 .
     loc-abc-one_6 = 0 .
     loc-d = 0 .
     loc-e = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
 end.
 if abc-type = "ABCD"  then do:
     if loc-abc-one_4 <> 100 then message "Внимание! Меняю " loc-abc-one_4 " на 100% "  view-as alert-box information .
     loc-abc-one_4 = 100 .
     loc-abc-one_5 = 0 .
     loc-abc-one_6 = 0 .
     loc-e = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.

 end.
 if abc-type = "ABCDE"  then do:
     if loc-abc-one_5 <> 100 then message "Внимание! Меняю " loc-abc-one_5 " на 100% "  view-as alert-box information .
     loc-abc-one_5 = 100 .
     loc-abc-one_6 = 0 .
     loc-f = 0 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_4  <= 0  or loc-abc-one_4 >= loc-abc-one_5 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (4) " view-as alert-box error .
        return error.
     end.
 end.
 if abc-type = "ABCDEF"  then do:
     if loc-abc-one_6 <> 100 then message "Внимание! Меняю " loc-abc-one_6 " на 100% "  view-as alert-box information .
     loc-abc-one_6 = 100 .
     if loc-abc-one_1  <= 0  or loc-abc-one_1 >= loc-abc-one_2 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (1) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_2  <= 0  or loc-abc-one_2 >= loc-abc-one_3 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (2) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_3  <= 0  or loc-abc-one_3 >= loc-abc-one_4 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (3) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_4  <= 0  or loc-abc-one_4 >= loc-abc-one_5 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (4) " view-as alert-box error .
        return error.
     end.
     if loc-abc-one_5  <= 0  or loc-abc-one_5 >= loc-abc-one_6 then do:
        message "Неверно заданы % по умолчанию для Простого АВС анализа (5) " view-as alert-box error .
        return error.
     end.
 end.
 end.

assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-abc where
              recid(thbjattr_thbj-attr-abc) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr-abc:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.

  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
for each thbjattr_thbj-attr-abc,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-abc.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-abc.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-abc.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-abc.prop-code:
   buffer-compare
   thbjattr_thbj-attr-abc
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.

find first  thbjattr_thbj-attr-abc where
  thbjattr_thbj-attr-abc.prop-code = "abc-one" no-error .
  thbjattr_thbj-attr-abc.property-value-character = string(loc-abc-one_1) + "/" +
  string(loc-abc-one_2)  + "/" +
  string(loc-abc-one_3)  + "/" +
  string(loc-abc-one_4)  + "/" +
  string(loc-abc-one_5)  + "/" +
  string(loc-abc-one_6) .
find first  thbjattr_thbj-attr-abc where
  thbjattr_thbj-attr-abc.prop-code = "abc-two" no-error .
  thbjattr_thbj-attr-abc.property-value-character =
  string(loc-abc-two_1) + "/" + string(loc-abc-two_2) + ";" +
  string(loc-abc-two_3) + "/" + string(loc-abc-two_4) + ";" +
  string(loc-abc-two_5) .
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
      input "check":u
    , input ""
    , input 0
    , input {&attr-abc-sale-day}
    , input '':u
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.

do TRANSACTION
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input {&attr-abc-sale-day}
      ,input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input {&attr-abc-global}
      ,input table thbjattr_thbj-attr-abc
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.


end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

