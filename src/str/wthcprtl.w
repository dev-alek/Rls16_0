&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-c-wth-parts NO-UNDO LIKE c-wth-parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог просмотра истории партии серийных МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/10/07
Author: Polina Gridchina
Creation date: 05/10/07

Input:

Output:

*/


/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as CHARACTER no-undo.
define input PARAMETER p-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог просмотра истории партии серийных МЦ".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }

DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR wealth.
DEF BUFFER b-wealth FOR wealth.
DEF BUFFER b-goods FOR goods.
DEF BUFFER LOCKED_wth-ser FOR wth-ser.
DEF BUFFER locked_wth-par FOR wth-par.
DEF BUFFER locked_c-wth-parts FOR c-wth-parts.
DEF BUFFER b-wth-par FOR wth-par.
DEF BUFFER buf_wth-gds FOR wth-gds.
DEF BUFFER buf_wth-doc FOR wth-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-c-wth-parts parts

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-c-wth-parts.VAT-pc ~
tt-c-wth-parts.wth-code tt-c-wth-parts.par-code tt-c-wth-parts.ser-code ~
tt-c-wth-parts.db-num tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo ~
tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty ~
tt-c-wth-parts.qnty-doc tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt ~
tt-c-wth-parts.price-rubl tt-c-wth-parts.price-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-c-wth-parts.wth-code ~
tt-c-wth-parts.par-code tt-c-wth-parts.ser-code tt-c-wth-parts.db-num ~
tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo ~
tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty ~
tt-c-wth-parts.qnty-doc tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt ~
tt-c-wth-parts.price-rubl tt-c-wth-parts.price-base
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-c-wth-parts
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-c-wth-parts
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-wth-parts SHARE-LOCK, ~
      EACH parts WHERE TRUE /* Join to tt-c-wth-parts incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-c-wth-parts SHARE-LOCK, ~
      EACH parts WHERE TRUE /* Join to tt-c-wth-parts incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-wth-parts parts
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-wth-parts
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame parts


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-wth-parts.wth-code tt-c-wth-parts.par-code ~
tt-c-wth-parts.ser-code tt-c-wth-parts.db-num tt-c-wth-parts.fact-rangeFrom ~
tt-c-wth-parts.fact-rangeTo tt-c-wth-parts.doc-rangeFrom ~
tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc ~
tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl ~
tt-c-wth-parts.price-base
&Scoped-define ENABLED-TABLES tt-c-wth-parts
&Scoped-define FIRST-ENABLED-TABLE tt-c-wth-parts
&Scoped-Define ENABLED-OBJECTS b-quit B-Help fl-artic fl-gds fl-prodType ~
fl-ProdCode fl-obj-name fl-wth-name fl-par-val fl-par-rate fl-maska RECT-1 ~
RECT-2 RECT-3 RECT-4 RECT-5
&Scoped-Define DISPLAYED-FIELDS tt-c-wth-parts.VAT-pc tt-c-wth-parts.wth-code ~
tt-c-wth-parts.par-code tt-c-wth-parts.ser-code tt-c-wth-parts.db-num ~
tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo ~
tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty ~
tt-c-wth-parts.qnty-doc tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt ~
tt-c-wth-parts.price-rubl tt-c-wth-parts.price-base
&Scoped-define DISPLAYED-TABLES tt-c-wth-parts
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-wth-parts
&Scoped-Define DISPLAYED-OBJECTS fl-artic fl-gds fl-prodType fl-ProdCode ~
fl-obj-name fl-wth-name fl-par-val fl-par-rate FILL-IN-2 FILL-IN-3 fl-maska ~
FILL-IN-4 FILL-IN-5 FILL-IN-6

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "        Диапазон (факт)"
      VIEW-AS TEXT
     SIZE 31 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "     Диапазон (документ)"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "       Срок годности"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "           Цена"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "              Серия"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-maska AS CHARACTER FORMAT "X(256)":U
     LABEL "Маска"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-par-rate AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-par-val AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название МЦ"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 5.25.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 65 BY 5.25.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 4.75.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.5 BY 4.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-parts,
      parts SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     tt-c-wth-parts.VAT-pc AT ROW 16 COL 48.5 COLON-ALIGNED WIDGET-ID 1118
          LABEL "НДС" FORMAT ">9.9<%"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-quit AT ROW 1 COL 1.5 WIDGET-ID 8
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     fl-artic AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 46
     fl-gds AT ROW 2.5 COL 52.5 COLON-ALIGNED WIDGET-ID 58
     fl-prodType AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 54
     fl-ProdCode AT ROW 3.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-obj-name AT ROW 3.5 COL 52.5 COLON-ALIGNED WIDGET-ID 290
     tt-c-wth-parts.wth-code AT ROW 4.5 COL 18 COLON-ALIGNED WIDGET-ID 246
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     fl-wth-name AT ROW 4.5 COL 52.5 COLON-ALIGNED WIDGET-ID 50
     tt-c-wth-parts.par-code AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 218
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fl-par-val AT ROW 5.5 COL 52.5 COLON-ALIGNED WIDGET-ID 52
     fl-par-rate AT ROW 5.5 COL 74 COLON-ALIGNED WIDGET-ID 250
     FILL-IN-2 AT ROW 7.75 COL 65.5 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     FILL-IN-3 AT ROW 7.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     tt-c-wth-parts.ser-code AT ROW 9 COL 11.5 COLON-ALIGNED WIDGET-ID 230
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-c-wth-parts.db-num AT ROW 10 COL 11.5 COLON-ALIGNED WIDGET-ID 176
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-c-wth-parts.fact-rangeFrom AT ROW 9 COL 76.5 COLON-ALIGNED WIDGET-ID 194
          LABEL "С"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.fact-rangeTo AT ROW 10 COL 76.5 COLON-ALIGNED WIDGET-ID 196
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.doc-rangeFrom AT ROW 9 COL 43 COLON-ALIGNED WIDGET-ID 262
          LABEL "C"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.doc-rangeTo AT ROW 10 COL 43 COLON-ALIGNED WIDGET-ID 264
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.fact-qnty AT ROW 11 COL 76.5 COLON-ALIGNED WIDGET-ID 266
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-c-wth-parts.qnty-doc AT ROW 11 COL 43 COLON-ALIGNED WIDGET-ID 224
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     fl-maska AT ROW 11 COL 11.5 COLON-ALIGNED WIDGET-ID 252
     FILL-IN-4 AT ROW 12.75 COL 2.5 NO-LABEL WIDGET-ID 278
     FILL-IN-5 AT ROW 12.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     tt-c-wth-parts.beg-dt AT ROW 14 COL 11.5 COLON-ALIGNED WIDGET-ID 168
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-wth-parts.end-dt AT ROW 15 COL 11.5 COLON-ALIGNED WIDGET-ID 182
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-wth-parts.price-rubl AT ROW 14 COL 48.5 COLON-ALIGNED WIDGET-ID 222
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-6 AT ROW 7.75 COL 2.5 NO-LABEL WIDGET-ID 1114
     tt-c-wth-parts.price-base AT ROW 15 COL 48.5 COLON-ALIGNED WIDGET-ID 1116
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 254
     RECT-2 AT ROW 7.25 COL 1.5 WIDGET-ID 256
     RECT-3 AT ROW 7.25 COL 34 WIDGET-ID 272
     RECT-4 AT ROW 12.5 COL 1.5 WIDGET-ID 280
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     RECT-5 AT ROW 12.5 COL 34 WIDGET-ID 288
     SPACE(31.87) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии Серийной материальной ценности" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-c-wth-parts T "?" NO-UNDO ub c-wth-parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.fact-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.qnty-doc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.VAT-pc IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-c-wth-parts.wth-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-c-wth-parts,ub.parts WHERE Temp-Tables.tt-c-wth-parts ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Партии Серийной материальной ценности */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии Серийной материальной ценности */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-parts.doc-rangeFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.doc-rangeFrom Dialog-Frame
ON LEAVE OF tt-c-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame /* C */
DO:
    tt-c-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-c-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-c-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-c-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.doc-rangeFrom Dialog-Frame
ON RETURN OF tt-c-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame /* C */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-parts.doc-rangeTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.doc-rangeTo Dialog-Frame
ON LEAVE OF tt-c-wth-parts.doc-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    tt-c-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-c-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-c-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-c-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.doc-rangeTo Dialog-Frame
ON RETURN OF tt-c-wth-parts.doc-rangeTo IN FRAME Dialog-Frame /* По */
DO:
  APPLY "tab":U TO SELF.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-parts.fact-rangeFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.fact-rangeFrom Dialog-Frame
ON LEAVE OF tt-c-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame /* С */
DO:
   tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
   int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.fact-rangeFrom Dialog-Frame
ON RETURN OF tt-c-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame /* С */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-parts.fact-rangeTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.fact-rangeTo Dialog-Frame
ON LEAVE OF tt-c-wth-parts.fact-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-parts.fact-rangeTo Dialog-Frame
ON RETURN OF tt-c-wth-parts.fact-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.

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

{ gbl/ed_date.i
  tt-c-wth-parts.beg-dt
  " "
  " "
  "'Годен до &1 (для партии товара, включительно)'"
}



{ gbl/ed_date.i
  tt-c-wth-parts.end-dt
  " "
  " "
  "'Годен до &1 (для партии товара, включительно)'"
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF par-mode <>  {&LOOKUP} THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  FIND FIRST LOCKED_c-wth-parts NO-LOCK WHERE
      recid(LOCKED_c-wth-parts) = p-rec
      NO-ERROR.
     IF NOT AVAILABLE LOCKED_c-wth-parts THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена партия с recid &1", p-rec)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
     END.
     FIND FIRST LOCKED_wealth NO-LOCK WHERE
                LOCKED_wealth.wth-code = LOCKED_c-wth-parts.wth-code NO-ERROR.
     IF NOT AVAILABLE LOCKED_wealth THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена МЦ с кодом &1 ",LOCKED_c-wth-parts.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
      /*   Номинал МЦ   */
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.par-code = LOCKED_c-wth-parts.par-code
           AND  LOCKED_wth-par.wth-code = LOCKED_c-wth-parts.wth-code          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с кодом &2", LOCKED_c-wth-parts.par-code,  LOCKED_c-wth-parts.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    /*   Серии МЦ   */
       FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = LOCKED_c-wth-parts.ser-code
           AND  LOCKED_wth-ser.db-num = LOCKED_c-wth-parts.db-num          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена серия с кодом &1-&2", LOCKED_c-wth-parts.ser-code,  LOCKED_c-wth-parts.db-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.

    CREATE tt-c-wth-parts.
    BUFFER-COPY LOCKED_c-wth-parts TO tt-c-wth-parts.
  { gbl/getcntxt.i get }
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  RUN disp-fl.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-fl Dialog-Frame
PROCEDURE disp-fl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR v-cash-type-pay AS CHAR no-undo.
define variable p-plt-id AS INT no-undo.
define variable  p-plt-db-num   AS INT no-undo.
define variable  p-pdf-id  AS INT no-undo.
define variable  p-pdf-db-num AS INT no-undo.
define variable  p-sale-price-base AS DEC no-undo.
define variable  p-sale-price-rubl AS DEC no-undo.
define variable  p-road-tax-base AS DEC no-undo.
define variable  p-road-tax-rubl AS DEC no-undo.
define variable  p-excise-base AS DEC no-undo.
define variable  p-excise-rubl AS DEC no-undo.
define variable  p-fact-order  AS DEC no-undo.

DEF BUFFER b-cash-pay FOR ub.cash-pay.
DEF BUFFER b-clients FOR ub.clients.

    fill-in-6:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "            Серия".
    fill-in-2:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "         Диапазон (факт)".
    fill-in-3:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "        Диапазон (док)".
    fill-in-4:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "        Срок годности".
    fill-in-5:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "           Цена".


  IF AVAILABLE locked_c-wth-parts THEN DO WITH FRAME {&FRAME-NAME}:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = locked_c-wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN DISP b-wealth.wth-name @ fl-wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  locked_c-wth-parts.wth-code AND b-wth-par.par-code = locked_c-wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN DISP b-wth-par.par-val @ fl-par-val
                                       b-wth-par.par-rate @ fl-par-rate.
      ELSE do:
          fl-par-val:SCREEN-VALUE = '?':U.
          fl-par-rate:SCREEN-VALUE = '0':U.
      END.
      FIND FIRST b-goods WHERE b-goods.gds-code = locked_c-wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN do:
                                DISP b-goods.artic     @ fl-artic
                                     b-goods.prod-type @ fl-prodType
                                     b-goods.prod-code @ fl-prodCode
                                     b-goods.gds-name  @ fl-gds.
        FIND FIRST b-clients WHERE b-clients.obj-type = b-goods.prod-type AND
             b-clients.obj-code = b-goods.prod-code NO-LOCK NO-ERROR.
        IF AVAILABLE b-clients THEN DISP b-clients.obj-name @ fl-obj-name.
      END.
      ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U.

      find first locked_wth-ser exclusive-LOCK WHERE
              locked_wth-ser.ser-code = LOCKED_c-wth-parts.ser-code AND
              locked_wth-ser.db-num = locked_c-wth-parts.db-num NO-ERROR.
      if available locked_wth-ser THEN
          ASSIGN fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska.
          /*При резервировании партии во внеш. расходе заполняем цену из множеств. прайс-листа */

  END.
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
  DISPLAY fl-artic fl-gds fl-prodType fl-ProdCode fl-obj-name fl-wth-name
          fl-par-val fl-par-rate FILL-IN-2 FILL-IN-3 fl-maska FILL-IN-4
          FILL-IN-5 FILL-IN-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-parts THEN
    DISPLAY tt-c-wth-parts.VAT-pc tt-c-wth-parts.wth-code tt-c-wth-parts.par-code
          tt-c-wth-parts.ser-code tt-c-wth-parts.db-num tt-c-wth-parts.fact-rangeFrom
          tt-c-wth-parts.fact-rangeTo tt-c-wth-parts.doc-rangeFrom
          tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc
          tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl
          tt-c-wth-parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help fl-artic fl-gds fl-prodType fl-ProdCode fl-obj-name
         tt-c-wth-parts.wth-code fl-wth-name tt-c-wth-parts.par-code fl-par-val
         fl-par-rate tt-c-wth-parts.ser-code tt-c-wth-parts.db-num
         tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo
         tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo
         tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc fl-maska
         tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl
         tt-c-wth-parts.price-base RECT-1 RECT-2 RECT-3 RECT-4 RECT-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

ENABLE
b-quit
B-Help

WITH FRAME {&frame-name}.
DISPLAY
   {&FIELDS-IN-QUERY-Dialog-Frame}
WITH FRAME {&frame-name}  .
/*У удаленных партий не показываем фактический диапазон.  Такие партии могут быть только в режиме просмотра.*/
if tt-c-wth-parts.stts = 1 then do:
  tt-c-wth-parts.fact-rangeFrom:screen-value = '?'.
  tt-c-wth-parts.fact-rangeTo:screen-value = '?'.
  tt-c-wth-parts.fact-qnty:screen-value = '0'.
end.
/* IF AVAILABLE LOCKED_wealth THEN fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.          */
/* IF AVAILABLE LOCKED_wth-par THEN fill-par:SCREEN-VALUE = string(LOCKED_wth-par.par-val). */
/*                                                                                          */
IF par-mode = {&LOOKUP} THEN DO:
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
VIEW FRAME {&frame-name}.
frame {&frame-name}:title = substitute("&1 &2"
                                     ,frame {&frame-name}:title
                                     ,par-mode
                                     ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME