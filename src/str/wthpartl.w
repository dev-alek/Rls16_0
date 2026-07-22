&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-wth-parts NO-UNDO LIKE ub.wth-parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог добавлени\изменения партии серийных МЦ

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
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter pobj-type  like ub.clients.obj-type no-undo .
define input parameter pobj-code  like ub.clients.obj-code no-undo .
define input parameter par-mode as CHARACTER no-undo.
define input parameter pw-p-code as integer no-undo.
define input parameter pwth-code   as integer no-undo.
define input parameter ppar-code as integer no-undo.
define input parameter pin-code as CHARACTER no-undo.
define input parameter pout-code as CHARACTER no-undo.
define input parameter pser-code as integer no-undo.
define input parameter pdb-num as integer no-undo.
define input parameter pfact-rangefrom as integer no-undo.
define input parameter pfact-rangeto as INTEGER no-undo.
define input parameter ptype as CHARACTER no-undo.
define input-output PARAMETER p-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог добавлени\изменения партии серийных МЦ".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/sel-date.i }
/* { str/mplfacor.i } */
/* { str/mpl-auto.i } */
{ str/wthparts.i }
/* { gbl/cur-time.i } */
/* { trg/factord.i }  */

DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER b-wealth FOR ub.wealth.
DEF BUFFER b-goods FOR ub.goods.
DEF BUFFER LOCKED_wth-ser FOR ub.wth-ser.
DEF BUFFER buf_wth-ser FOR ub.wth-ser.
DEF BUFFER locked_wth-par FOR ub.wth-par.
DEF BUFFER locked_wth-parts FOR ub.wth-parts.
DEF BUFFER b-wth-par FOR ub.wth-par.
DEF BUFFER buf_wth-gds FOR ub.wth-gds.
DEF BUFFER buf_wth-doc FOR ub.wth-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-wth-parts

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-wth-parts.VAT-pc ~
tt-wth-parts.wth-code tt-wth-parts.par-code tt-wth-parts.ser-code ~
tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom tt-wth-parts.fact-rangeTo ~
tt-wth-parts.doc-rangeFrom tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty ~
tt-wth-parts.qnty-doc tt-wth-parts.beg-dt tt-wth-parts.end-dt ~
tt-wth-parts.price-rubl tt-wth-parts.price-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-wth-parts.wth-code ~
tt-wth-parts.par-code tt-wth-parts.ser-code tt-wth-parts.db-num ~
tt-wth-parts.fact-rangeFrom tt-wth-parts.fact-rangeTo ~
tt-wth-parts.doc-rangeFrom tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty ~
tt-wth-parts.qnty-doc tt-wth-parts.beg-dt tt-wth-parts.end-dt ~
tt-wth-parts.price-rubl tt-wth-parts.price-base
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-wth-parts
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-wth-parts
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wth-parts SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-wth-parts SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wth-parts
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wth-parts


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-parts.wth-code tt-wth-parts.par-code ~
tt-wth-parts.ser-code tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom ~
tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom ~
tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc ~
tt-wth-parts.beg-dt tt-wth-parts.end-dt tt-wth-parts.price-rubl ~
tt-wth-parts.price-base
&Scoped-define ENABLED-TABLES tt-wth-parts
&Scoped-define FIRST-ENABLED-TABLE tt-wth-parts
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help fl-artic fl-gds ~
fl-prodType fl-maska fl-ProdCode fl-obj-name fl-wth-name fl-par-val ~
fl-par-rate B-wth-ser b-choose-last-date b-choose-last-date-po RECT-1 ~
RECT-2 RECT-3 RECT-4 RECT-5
&Scoped-Define DISPLAYED-FIELDS tt-wth-parts.VAT-pc tt-wth-parts.wth-code ~
tt-wth-parts.par-code tt-wth-parts.ser-code tt-wth-parts.db-num ~
tt-wth-parts.fact-rangeFrom tt-wth-parts.fact-rangeTo ~
tt-wth-parts.doc-rangeFrom tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty ~
tt-wth-parts.qnty-doc tt-wth-parts.beg-dt tt-wth-parts.end-dt ~
tt-wth-parts.price-rubl tt-wth-parts.price-base
&Scoped-define DISPLAYED-TABLES tt-wth-parts
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-parts
&Scoped-Define DISPLAYED-OBJECTS fl-artic fl-gds fl-prodType fl-maska ~
fl-ProdCode fl-obj-name fl-wth-name fl-par-val fl-par-rate FILL-IN-2 ~
FILL-IN-3 FILL-IN-4 FILL-IN-5 FILL-IN-6

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

DEFINE BUTTON b-choose-last-date-po
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-wth-ser
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

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
      tt-wth-parts SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 2
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 8
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     tt-wth-parts.VAT-pc AT ROW 16 COL 48.5 COLON-ALIGNED WIDGET-ID 1118
          LABEL "НДС" FORMAT ">9.9<%"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     fl-artic AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 46
     fl-gds AT ROW 2.5 COL 52.5 COLON-ALIGNED WIDGET-ID 58
     fl-prodType AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 54
     fl-maska AT ROW 11 COL 11.5 COLON-ALIGNED WIDGET-ID 252
     fl-ProdCode AT ROW 3.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-obj-name AT ROW 3.5 COL 52.5 COLON-ALIGNED WIDGET-ID 290
     tt-wth-parts.wth-code AT ROW 4.5 COL 18 COLON-ALIGNED WIDGET-ID 246
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     fl-wth-name AT ROW 4.5 COL 52.5 COLON-ALIGNED WIDGET-ID 50
     tt-wth-parts.par-code AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 218
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fl-par-val AT ROW 5.5 COL 52.5 COLON-ALIGNED WIDGET-ID 52
     fl-par-rate AT ROW 5.5 COL 74 COLON-ALIGNED WIDGET-ID 250
     FILL-IN-2 AT ROW 7.75 COL 65.5 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     tt-wth-parts.ser-code AT ROW 9 COL 11.5 COLON-ALIGNED WIDGET-ID 230
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     B-wth-ser AT ROW 9 COL 20.5 WIDGET-ID 32
     FILL-IN-3 AT ROW 7.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     tt-wth-parts.db-num AT ROW 10 COL 11.5 COLON-ALIGNED WIDGET-ID 176
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-wth-parts.fact-rangeFrom AT ROW 9 COL 76.5 COLON-ALIGNED WIDGET-ID 194
          LABEL "С"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.fact-rangeTo AT ROW 10 COL 76.5 COLON-ALIGNED WIDGET-ID 196
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.doc-rangeFrom AT ROW 9 COL 43 COLON-ALIGNED WIDGET-ID 262
          LABEL "C"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.doc-rangeTo AT ROW 10 COL 43 COLON-ALIGNED WIDGET-ID 264
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.fact-qnty AT ROW 11 COL 76.5 COLON-ALIGNED WIDGET-ID 266
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-wth-parts.qnty-doc AT ROW 11 COL 43 COLON-ALIGNED WIDGET-ID 224
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-wth-parts.beg-dt AT ROW 14 COL 11.5 COLON-ALIGNED WIDGET-ID 168
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date AT ROW 14 COL 26 WIDGET-ID 274
     tt-wth-parts.end-dt AT ROW 15 COL 11.5 COLON-ALIGNED WIDGET-ID 182
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date-po AT ROW 15 COL 26 WIDGET-ID 276
     tt-wth-parts.price-rubl AT ROW 14 COL 48.5 COLON-ALIGNED WIDGET-ID 222
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-4 AT ROW 12.75 COL 2.5 NO-LABEL WIDGET-ID 278
     tt-wth-parts.price-base AT ROW 15 COL 48.5 COLON-ALIGNED WIDGET-ID 1116
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-5 AT ROW 12.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     FILL-IN-6 AT ROW 7.75 COL 2.5 NO-LABEL WIDGET-ID 1114
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 254
     RECT-2 AT ROW 7.25 COL 1.5 WIDGET-ID 256
     RECT-3 AT ROW 7.25 COL 34 WIDGET-ID 272
     RECT-4 AT ROW 12.5 COL 1.5 WIDGET-ID 280
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
      TABLE: tt-wth-parts T "?" NO-UNDO ub wth-parts
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

ASSIGN
       B-wth-ser:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-parts.fact-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
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
/* SETTINGS FOR FILL-IN tt-wth-parts.qnty-doc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-parts.VAT-pc IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wth-parts.wth-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-wth-parts"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Партии Серийной материальной ценности */
DO:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-wth-ser
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-wth-ser Dialog-Frame
ON CHOOSE OF B-wth-ser IN FRAME Dialog-Frame
DO:

      v-rid-list = ''.
      run ref/wths-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input pobj-type
                        ,input pobj-code
                        ,input {&wth-par}           /*{&wealth}*/
                        ,INPUT pwth-code
                        ,input ppar-code
                        ,input-output v-rid-list) .
      if v-rid-list = "" then return .
      find first locked_wth-ser NO-LOCK WHERE
              recid(locked_wth-ser) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wth-ser then do:
          ASSIGN tt-wth-parts.ser-code:SCREEN-VALUE = STRING(LOCKED_wth-ser.ser-code)
                 tt-wth-parts.db-num:SCREEN-VALUE = string(LOCKED_wth-ser.db-num)
                 fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska
                 .

         APPLY 'tab':U TO SELF.
     END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.beg-dt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.beg-dt Dialog-Frame
ON RETURN OF tt-wth-parts.beg-dt IN FRAME Dialog-Frame /* Годен с */
DO:
  IF SELF:SCREEN-VALUE = '':U THEN APPLY 'tab':U TO SELF.
  ELSE APPLY "entry":U TO tt-wth-parts.end-dt.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.doc-rangeFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.doc-rangeFrom Dialog-Frame
ON LEAVE OF tt-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame /* C */
DO:
    tt-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.doc-rangeFrom Dialog-Frame
ON RETURN OF tt-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame /* C */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.doc-rangeTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.doc-rangeTo Dialog-Frame
ON LEAVE OF tt-wth-parts.doc-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    tt-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.doc-rangeTo Dialog-Frame
ON RETURN OF tt-wth-parts.doc-rangeTo IN FRAME Dialog-Frame /* По */
DO:
  APPLY "tab":U TO SELF.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.end-dt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.end-dt Dialog-Frame
ON RETURN OF tt-wth-parts.end-dt IN FRAME Dialog-Frame /* Годен по */
DO:
  IF SELF:SCREEN-VALUE = '':U THEN APPLY 'tab':U TO SELF.
  ELSE APPLY "entry":U TO tt-wth-parts.price-rubl.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.fact-rangeFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.fact-rangeFrom Dialog-Frame
ON LEAVE OF tt-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame /* С */
DO:
   tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
   int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.fact-rangeFrom Dialog-Frame
ON RETURN OF tt-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame /* С */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.fact-rangeTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.fact-rangeTo Dialog-Frame
ON LEAVE OF tt-wth-parts.fact-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.fact-rangeTo Dialog-Frame
ON RETURN OF tt-wth-parts.fact-rangeTo IN FRAME Dialog-Frame /* По */
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-parts.price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.price-rubl Dialog-Frame
ON LEAVE OF tt-wth-parts.price-rubl IN FRAME Dialog-Frame /* Цена (руб) */
DO:
DEFINE VARIABLE v-base-rate AS DEC.
DEFINE VARIABLE v-base-scale AS DEC.

ASSIGN FRAME Dialog-Frame tt-wth-parts.price-rubl.
    { gbl/baserate.i p-curr-host-code
                  buf_wth-doc.DOC-DATE
                  v-base-rate
                  v-base-scale
                  no-error      }
  tt-wth-parts.price-base = dec(tt-wth-parts.price-rubl) / v-base-rate.
  DISPLAY tt-wth-parts.price-base WITH FRAME dialog-frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-parts.price-rubl Dialog-Frame
ON RETURN OF tt-wth-parts.price-rubl IN FRAME Dialog-Frame /* Цена (руб) */
DO:
DEFINE VARIABLE v-base-rate AS DEC.
DEFINE VARIABLE v-base-scale AS DEC.

ASSIGN FRAME Dialog-Frame tt-wth-parts.price-rubl.
    { gbl/baserate.i p-curr-host-code
                  buf_wth-doc.DOC-DATE
                  v-base-rate
                  v-base-scale
                  no-error      }
  tt-wth-parts.price-base = dec(tt-wth-parts.price-rubl) / v-base-rate.
  DISPLAY tt-wth-parts.price-base WITH FRAME dialog-frame.
   APPLY 'tab':U TO SELF.
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
  tt-wth-parts.beg-dt
  " "
  " "
  "'Годен до &1 (для партии товара, включительно)'"
}

on choose of b-choose-last-date in frame {&frame-name}
do:
  run sel-date in this-procedure
    (input tt-wth-parts.beg-dt :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.


{ gbl/ed_date.i
  tt-wth-parts.end-dt
  " "
  " "
  "'Годен до &1 (для партии товара, включительно)'"
}

on choose of b-choose-last-date-po in frame {&frame-name}
do:
  run sel-date in this-procedure
    (input tt-wth-parts.end-dt :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, {&add-def} + {&comma-char} +
                      {&UPDATE} + {&comma-char} +
                      {&LOOKUP}) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  if lookup(pout-code,{&WDEDT_List-Zone}) = 0 and (par-mode = {&add-def} or par-mode = {&update} ) then do:
    find first buf_wth-doc exclusive-lock where
            buf_wth-doc.doc-code = pout-code no-error .
    if NOT available buf_wth-doc then do:
      message substitute('Не найден документ МЦ с номером &1',pout-code) view-as alert-box error.
      return.
    END.
  end.

  /*Если не добавление то ищем партию*/
  IF par-mode <> {&add-def} THEN DO:
       IF par-mode = {&LOOKUP} THEN DO:
       FIND FIRST LOCKED_wth-parts NO-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
          NO-ERROR.

     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-parts exclusive-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
            NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wth-parts THEN DO:
        MESSAGE pin-code SKIP pout-code SKIP pfact-rangefrom SKIP pfact-rangeto SKIP
        SUBSTITUTE("Не найдена партия с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
     END.
  end.

  FIND FIRST LOCKED_wealth No-LOCK WHERE
            LOCKED_wealth.wth-code = if par-mode = {&add-def} then pwth-code else LOCKED_wth-parts.wth-code  NO-ERROR.
  IF NOT AVAILABLE LOCKED_wealth THEN DO:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " pwth-code
      view-as alert-box error.
      return error.
  END.
  FIND FIRST LOCKED_wth-par NO-LOCK WHERE
            LOCKED_wth-par.wth-code = (if par-mode = {&add-def} then pwth-code  else LOCKED_wth-parts.wth-code)
       AND  LOCKED_wth-par.par-code = (if par-mode = {&add-def} then ppar-code else LOCKED_wth-parts.par-code)
 NO-ERROR.
  IF NOT AVAILABLE LOCKED_wth-par THEN DO:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " ppar-code
      view-as alert-box error.
      return error.
  END.

  IF par-mode = {&add-def} THEN DO:
    if buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter_ then do:
      message substitute('Режим добавления для документов внутреннего прихода запрещен!')
      view-as alert-box error.
      return error.
    end.
    CREATE tt-wth-parts.
      IF pwth-code <> 0  THEN do:
        tt-wth-parts.wth-code = LOCKED_wealth.wth-code.
          IF ppar-code <> 0  THEN do:
            tt-wth-parts.par-code = LOCKED_wth-par.par-code.
          END.

      END.
  END.
  ELSE DO:
/*     IF par-mode = {&LOOKUP} THEN DO: /*  Серия МЦ   */
       FIND FIRST LOCKED_wth-parts NO-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
          NO-ERROR.

     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-parts EXCLUSIVE-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
            NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wth-parts THEN DO:
        MESSAGE pin-code SKIP pout-code SKIP pfact-rangefrom SKIP pfact-rangeto SKIP
        SUBSTITUTE("Не найдена партия с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
     END. */
/*     IF par-mode = {&UPDATE} and LOCKED_wth-parts.stts = 1 then do:
        MESSAGE pin-code SKIP pout-code SKIP pfact-rangefrom SKIP pfact-rangeto SKIP
        SUBSTITUTE("Режим изменения для удаленных партий запрещен.")
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.

     end.    */
    /*   Серии МЦ   */
    FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = LOCKED_wth-parts.ser-code
           AND  LOCKED_wth-ser.db-num = LOCKED_wth-parts.db-num          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена серия с кодом &1-&2", LOCKED_wth-parts.ser-code,  LOCKED_wth-parts.db-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.

    CREATE tt-wth-parts.
    BUFFER-COPY LOCKED_wth-parts TO tt-wth-parts.
  END.
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
define variable v-vat-pc as decimal no-undo.
define variable v-beg-dt as date    no-undo.
define variable v-end-dt as date    no-undo.
define variable v-mpl-date as date    no-undo.
define variable v-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
define variable v-price-base       LIKE ub.wth-parts.price-base no-undo .

/*DEF VAR v-cash-type-pay AS CHAR no-undo.*/
/*define variable p-plt-id AS INT no-undo.*/
/*define variable  p-plt-db-num   AS INT no-undo.*/
/*define variable  p-pdf-id  AS INT no-undo.*/
/*define variable  p-pdf-db-num AS INT no-undo.*/
/*define variable  p-sale-price-base AS DEC no-undo.*/
/*define variable  p-sale-price-rubl AS DEC no-undo.*/
/*define variable  p-road-tax-base AS DEC no-undo.*/
/*define variable  p-road-tax-rubl AS DEC no-undo.*/
/*define variable  p-excise-base AS DEC no-undo.*/
/*define variable  p-excise-rubl AS DEC no-undo.*/
/*define variable  p-fact-order  AS DEC no-undo.*/

DEF BUFFER b-cash-pay FOR ub.cash-pay.
DEF BUFFER b-clients  FOR ub.clients.

    fill-in-6:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "            Серия".
    fill-in-2:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "         Диапазон (факт)".
    fill-in-3:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "        Диапазон (док)".
    fill-in-4:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "        Срок годности".
    fill-in-5:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "           Цена".


  IF AVAILABLE locked_wth-parts THEN DO WITH FRAME {&FRAME-NAME}:
      DISP
      locked_wealth.wth-name @ fl-wth-name
      LOCKED_wth-par.par-val @ fl-par-val
      LOCKED_wth-par.par-rate @ fl-par-rate
      LOCKED_wth-ser.maska @ fl-maska.
      FIND FIRST b-goods WHERE b-goods.gds-code = locked_wth-parts.gds-code NO-LOCK NO-ERROR.
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

 /*     find first locked_wth-ser NO-LOCK WHERE
              locked_wth-ser.ser-code = LOCKED_wth-parts.ser-code AND
              locked_wth-ser.db-num = locked_wth-parts.db-num NO-ERROR.
      if available locked_wth-ser THEN
          ASSIGN fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska.    */
      if available buf_wth-doc
      and (buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext} or  (buf_wth-doc.doc-type = {&exchange} and ptype = {&expense}))
      and par-mode = {&update} and
      tt-wth-parts.beg-dt = ? AND tt-wth-parts.end-dt = ? THEN DO:
            RUN init_prtdate ( INPUT buf_wth-doc.obj-type
                              ,INPUT buf_wth-doc.obj-code
                              ,INPUT locked_wth-ser.ser-code
                              ,INPUT locked_wth-ser.db-num
                              ,INPUT buf_wth-doc.doc-date
                              ,OUTPUT v-beg-dt
                              ,OUTPUT v-end-dt ) NO-ERROR.
            if error-status:error then do:
             message return-value skip
              error-status:get-message(1)
             view-as alert-box error .
            end.
            else do:
              disp  v-beg-dt @ tt-wth-parts.beg-dt
                    v-end-dt @ tt-wth-parts.end-dt
              with frame {&frame-name}.
            end.

      END.

          /*При резервировании партии во внеш. расходе заполняем цену из множеств. прайс-листа */
      if available buf_wth-doc
      and (buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext} or  (buf_wth-doc.doc-type = {&exchange} and ptype = {&expense}))
      and par-mode = {&update} and
      (tt-wth-parts.price-rubl = 0 or tt-wth-parts.price-rubl = ? ) then do:
              v-beg-dt = date(tt-wth-parts.beg-dt:screen-value) no-error.
              run set-wthmpl-date ( buf_wth-doc.doc-code
                            ,buf_wth-doc.doc-date
                            , v-beg-dt
                            , output v-mpl-date) no-error.

                  RUN INIT_prtprice (
                          buf_wth-doc.host-code
                        , buf_wth-doc.obj-type
                        , buf_wth-doc.obj-code
                        , buf_wth-doc.cli-type
                        , buf_wth-doc.cli-code
                        , locked_wth-parts.wth-code
                        , locked_wth-parts.gds-code
                        , locked_wth-parts.par-code
                        , v-mpl-date
                        , OUTPUT  v-vat-pc
                        , OUTPUT  v-price-rubl
                        , OUTPUT  v-price-base
                ) NO-ERROR.
          if error-status:error then undo, return error return-value + error-status:get-message(1) .
       /*
        FIND FIRST b-cash-pay WHERE b-cash-pay.wth-code = pwth-code NO-LOCK NO-ERROR.
        IF AVAILABLE b-cash-pay THEN v-cash-type-pay = STRING(recid(b-cash-pay)).
        ELSE v-cash-type-pay = ?.
        run fact-order-mpl (
            INPUT buf_wth-doc.doc-date ,
            INPUT pobj-type ,
            INPUT pobj-code ,
            OUTPUT p-fact-order
            ) no-error .
        if error-status:error then do:
          message   return-value skip error-status:get-message(1)
          skip  'Получение цены из множественного прайс-листа отклонено.'
          view-as alert-box.
          return.
        end.
        define variable vat-p as dec no-undo.
        { gbl/pftxvalg.i b-goods.gds-code {&vat-tax-code} ? p-curr-host-code pobj-type pobj-code vat-p no-error }
        tt-wth-parts.vat-pc:screen-value = string(vat-p).

        run mpl-autoprice in this-procedure
          ( input   ( true )
            ,input   buf_wth-doc.cli-type
            ,input   buf_wth-doc.cli-code
            ,input   b-goods.gds-code
            ,input   b-goods.gds-code
            ,input   pobj-type
            ,input   pobj-code
            ,input   0
            ,input   0
            ,input   ""  /* вид оплаты */
            ,input   v-cash-type-pay  /* тип кассового платежа */
            ,input   p-fact-order
            ,output  p-plt-id
            ,output  p-plt-db-num
            ,output  p-pdf-id
            ,output  p-pdf-db-num
            ,output  p-sale-price-base
            ,output  p-sale-price-rubl
            ,output  p-road-tax-base
            ,output  p-road-tax-rubl
            ,output  p-excise-base
            ,output  p-excise-rubl
            ) no-error .
         if error-status:error then do:
          message   return-value skip error-status:get-message(1) view-as alert-box.
          return.
         end.
         */
         tt-wth-parts.vat-pc:screen-value = string(v-vat-pc).
         tt-wth-parts.price-rubl:screen-value = string(v-price-rubl).
         apply 'leave':U to tt-wth-parts.price-rubl.
       end.

  END.
  ELSE DO:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = pwth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN fl-wth-name:SCREEN-VALUE = b-wealth.wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  pwth-code AND b-wth-par.par-code = ppar-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN do: fl-par-val:SCREEN-VALUE = string(b-wth-par.par-val).
                                      fl-par-rate:SCREEN-VALUE = string(b-wth-par.par-rate).
      END.
      ELSE do:
          fl-par-val:SCREEN-VALUE = '?':U.
          fl-par-rate:SCREEN-VALUE = '0':U.
      END.
      find first buf_wth-gds no-lock where
              buf_wth-gds.wth-code = pwth-code   no-error .
      if available buf_wth-gds then do:
          FIND FIRST b-goods WHERE b-goods.gds-code = buf_wth-gds.gds-code NO-LOCK NO-ERROR.
          IF AVAILABLE b-goods THEN DO:  fl-artic:SCREEN-VALUE = b-goods.artic .
                                         fl-prodType:SCREEN-VALUE = string(b-goods.prod-type).
                                         fl-prodCode:SCREEN-VALUE = string(b-goods.prod-code).
                                         fl-gds:SCREEN-VALUE = b-goods.gds-name .
             FIND FIRST b-clients WHERE b-clients.obj-type = b-goods.prod-type AND
                  b-clients.obj-code = b-goods.prod-code NO-LOCK NO-ERROR.
             IF AVAILABLE b-clients THEN fl-obj-name:SCREEN-VALUE = b-clients.obj-name.
          END.
          ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
                 fl-prodType:SCREEN-VALUE = '?':U
                 fl-prodCode:SCREEN-VALUE = '?':U
                 fl-gds:SCREEN-VALUE = '?':U.
      end.
      /*В режиме добавления если только одна серия заведена на указанный номинал, то автоматически ее проставляем*/
      if par-mode = {&add-def} and not available LOCKED_wth-ser then do:
        find buf_wth-ser where buf_wth-ser.wth-code = pwth-code
                           and buf_wth-ser.wth-code = ppar-code
                           and  buf_wth-ser.stts = 0 no-lock no-error.
        if available buf_wth-ser then do:
          find first locked_wth-ser no-LOCK WHERE
              recid(locked_wth-ser) = recid(buf_wth-ser) NO-ERROR.
          if available locked_wth-ser then do:
            ASSIGN tt-wth-parts.ser-code:SCREEN-VALUE = STRING(LOCKED_wth-ser.ser-code)
                 tt-wth-parts.db-num:SCREEN-VALUE = string(LOCKED_wth-ser.db-num)
                 fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska
                 .
          end.
        end.
      end.
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
  DISPLAY fl-artic fl-gds fl-prodType fl-maska fl-ProdCode fl-obj-name
          fl-wth-name fl-par-val fl-par-rate FILL-IN-2 FILL-IN-3 FILL-IN-4
          FILL-IN-5 FILL-IN-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-parts THEN
    DISPLAY tt-wth-parts.VAT-pc tt-wth-parts.wth-code tt-wth-parts.par-code
          tt-wth-parts.ser-code tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom
          tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom
          tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc
          tt-wth-parts.beg-dt tt-wth-parts.end-dt tt-wth-parts.price-rubl
          tt-wth-parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help fl-artic fl-gds fl-prodType fl-maska fl-ProdCode
         fl-obj-name tt-wth-parts.wth-code fl-wth-name tt-wth-parts.par-code
         fl-par-val fl-par-rate tt-wth-parts.ser-code B-wth-ser
         tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom
         tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom
         tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc
         tt-wth-parts.beg-dt b-choose-last-date tt-wth-parts.end-dt
         b-choose-last-date-po tt-wth-parts.price-rubl tt-wth-parts.price-base
         RECT-1 RECT-2 RECT-3 RECT-4 RECT-5
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
B-exit WHEN par-mode <> {&LOOKUP}
b-quit
B-Help
WITH FRAME {&frame-name}.
IF par-mode = {&add-def} THEN DO:
    ENABLE
    b-wth-ser
/*    tt-wth-parts.fact-rangeFrom WHEN buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Int}
    tt-wth-parts.fact-rangeTo WHEN buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Int}   */
    tt-wth-parts.doc-rangeFrom
    tt-wth-parts.doc-rangeTo
    WITH FRAME {&frame-name}.
END.
DISPLAY
   {&FIELDS-IN-QUERY-Dialog-Frame}
WITH FRAME {&frame-name}  .
IF par-mode = {&update} THEN DO:
    ENABLE
        tt-wth-parts.fact-rangeFrom WHEN (buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter_)
        tt-wth-parts.fact-rangeTo   WHEN (buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter_)
        tt-wth-parts.doc-rangeFrom  WHEN not (buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter_)
        tt-wth-parts.doc-rangeTo    WHEN not (buf_wth-doc.doc-type = {&income} and not buf_wth-doc.exter_)
 WITH FRAME {&frame-name}.
END.
if (par-mode = {&update} or par-mode = {&add-def}) and
   (buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext} or
    (buf_wth-doc.ext-doc-type = {&WDEDT_Exch}    and ptype = {&Expense}))
    then do:
      enable
        tt-wth-parts.price-rubl
      WITH FRAME {&frame-name}.
     if locked_wth-ser.chk-bdt <> 0 then do:
        disable
          tt-wth-parts.beg-dt
          b-choose-last-date
          WITH FRAME {&frame-name}.
        /*if locked_wth-ser.chk-bdt = 2 then tt-wth-parts.beg-dt:screen-value = string(locked_wth-ser.beg-dt).   */
      end.
      else do:
        enable
          tt-wth-parts.beg-dt
          b-choose-last-date
          WITH FRAME {&frame-name}.
      end.
      if locked_wth-ser.chk-edt <> 0 then do:
        disable
          tt-wth-parts.end-dt
          b-choose-last-date-po
          WITH FRAME {&frame-name}.
          /*if locked_wth-ser.chk-edt = 2 then tt-wth-parts.end-dt:screen-value = string(locked_wth-ser.end-dt).    */
      end.
      else do:
        enable
          tt-wth-parts.end-dt
          b-choose-last-date-po
          WITH FRAME {&frame-name}.
      end.

end.
/*У удаленных партий не показываем фактический диапазон.  Такие партии могут быть только в режиме просмотра.*/

if tt-wth-parts.stts = 1 and par-mode = {&lookup} then do:
  tt-wth-parts.fact-rangeFrom:screen-value = '?'.
  tt-wth-parts.fact-rangeTo:screen-value = '?'.
  tt-wth-parts.fact-qnty:screen-value = '0'.
end.
/* IF AVAILABLE LOCKED_wealth THEN fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.          */
/* IF AVAILABLE LOCKED_wth-par THEN fill-par:SCREEN-VALUE = string(LOCKED_wth-par.par-val). */
/*                                                                                          */
IF par-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit IN FRAME {&FRAME-NAME}
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
VIEW FRAME {&frame-name}.
frame {&frame-name}:title = substitute("&1 &2"
                                     ,frame {&frame-name}:title
                                     ,par-mode
                                     ).
/*IF  par-mode = {&add-def} THEN DO:*/
/*    APPLY 'choose':U TO b-wth.*/
/*END.*/
APPLY 'entry':U TO b-wth-ser.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-EndDate AS date NO-UNDO.
DEFINE VARIABLE v-BegDate AS date NO-UNDO.

IF par-mode = {&LOOKUP} THEN UNDO, RETURN.
assign
FRAME {&frame-name} {&FIELDS-IN-QUERY-Dialog-Frame}.
if  par-mode = {&update} then v-rec = recid(locked_wth-parts).
do transaction on error undo, return error
               on stop  undo, return error
               on quit  undo, return error :
  if buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext} or
    (buf_wth-doc.ext-doc-type = {&WDEDT_Exch}    and ptype = {&Expense})
    and available locked_wth-ser
   then do:  /*при внешнем расходе проверяем на обязательность задания срока годности*/
    if locked_wth-ser.chk-bdt = 2 and locked_wth-ser.beg-dt <> ? then v-BegDate = locked_wth-ser.beg-dt.
    else  v-BegDate = tt-wth-parts.beg-dt.
    if locked_wth-ser.chk-edt = 2 and locked_wth-ser.end-dt <> ? then v-EndDate = locked_wth-ser.end-dt.
    else  v-EndDate = tt-wth-parts.end-dt.

    if (v-BegDate = ? and not locked_wth-ser.chk-bdt = 1)  or (v-EndDate = ? and not locked_wth-ser.chk-edt = 1)  then do:
        message 'Не указан срок действия партии' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.beg-dt.
        return error.
    end.
    if not (v-BegDate = ? or v-EndDate = ?) and v-BegDate > v-EndDate  then do:
        message 'Неверно указан срок действия партии' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.beg-dt.
        return error.
    end.
    if tt-wth-parts.price-rubl = 0 OR  tt-wth-parts.price-rubl = ? then do:
        message 'Не указана цена!.' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.price-rubl.
        return error.

    end.
  end.
  if buf_wth-doc.doc-type = {&income} and buf_wth-doc.exter_ = no then do:
    run wth-parts-inter-edit in this-procedure ( INPUT tt-wth-parts.fact-rangeFrom ,
                                                 INPUT tt-wth-parts.fact-rangeTo  ,
                                                 INPUT-OUTPUT v-rec
                                                )  no-error.
    if error-status:error then do:
        MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        apply 'entry':U to tt-wth-parts.fact-rangeFrom.
        undo, return error.
    end.

  end.
  /*Если документ с расш. типом внешнего прихода или внутр. прихода, то только изменение записи .  (Нельзя проверять только приход, т.к. погашение тоже внеш. приход )*/
  else if lookup(buf_wth-doc.ext-doc-type,{&WDEDT_Not-Rezerv}) > 0   then do:

          run str/wthpartp.p    ( INPUT    par-mode,
                    INPUT     buf_wth-doc.obj-type,
                    INPUT     buf_wth-doc.obj-code,
                    INPUT     pw-p-code,
                    INPUT     tt-wth-parts.wth-code,
                    INPUT     tt-wth-parts.par-code,
                    INPUT     tt-wth-parts.in-code ,
                    INPUT     buf_wth-doc.doc-code,
                    INPUT     tt-wth-parts.ser-code,
                    INPUT     tt-wth-parts.db-num  ,
                    INPUT     tt-wth-parts.fact-rangeFrom ,
                    INPUT     tt-wth-parts.fact-rangeTo  ,
                    INPUT     tt-wth-parts.doc-rangeFrom ,
                    INPUT     tt-wth-parts.doc-rangeTo,
                    INPUT     buf_wth-doc.host-code     ,
                    INPUT     buf_wth-doc.contract-code  ,  /* p-contract-code   */
                    INPUT     tt-wth-parts.price-rubl    ,
                    INPUT     tt-wth-parts.price-base    ,
                    INPUT     tt-wth-parts.supp-type,       /* p-supp-type       */
                    INPUT     tt-wth-parts.supp-code,       /*p-supp-code        */
                    INPUT     tt-wth-parts.in-obj-type ,          /*p-in-obj-type     */
                    INPUT     tt-wth-parts.in-obj-code ,          /*p-in-obj-code     */
                    INPUT     buf_wth-doc.ext-doc-type,  /*p-ext-doc-type    */
                    INPUT     b-goods.gds-code,      /*p-gds-code        */
                    INPUT     tt-wth-parts.stts  ,          /*p-stts            */
                    INPUT     tt-wth-parts.beg-dt  ,
                    INPUT     tt-wth-parts.end-dt  ,
                    INPUT     tt-wth-parts.vat-pc  ,
                    INPUT     tt-wth-parts.cli-code,                         /*p-cli-code        */
                    INPUT     tt-wth-parts.cli-type,                         /*p-cli-type        */
                    INPUT     tt-wth-parts.out-obj-code,                         /*p-out-obj-code    */
                    INPUT     tt-wth-parts.out-obj-type,                         /*p-out-obj-type    */
                    INPUT     tt-wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                    INPUT     tt-wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                    INPUT     buf_wth-doc.doc-code,
                    INPUT     no,
                    INPUT     ptype,
                    INPUT-OUTPUT v-rec
                    ) no-error.
      if error-status:error then DO:
        { gbl/reterhnd.i error }
        undo , return error.
      end.

  end.
  else do:
  /*Если изменяем зарезервированную партию по документу, то сначала делаем разрезервирование, затем опять резервирование*/
    if LOCKED_wth-parts.out-code = pout-code then do:
      run  wth-doc-razrez ( input RECID(LOCKED_wth-parts),
                            input no) no-error.
      if error-status:error then DO:
        MESSAGE RETURN-VALUE + {&new-line} + error-status:get-message(1) VIEW-AS ALERT-BOX ERROR.
        undo, return error.
      end.
      v-rec = ?.
    end.

    RUN wth-parts-rezerv ( yes
                         ,tt-wth-parts.fact-rangeFrom
                        , tt-wth-parts.fact-RangeTo
                        /*, tt-wth-parts.Doc-rangeFrom
                        , tt-wth-parts.Doc-RangeTo  */
                        , tt-wth-parts.beg-dt
                        , tt-wth-parts.end-dt
                        , tt-wth-parts.ser-code
                        , tt-wth-parts.db-num
                        , tt-wth-parts.price-rubl
                        , tt-wth-parts.price-base
                        , tt-wth-parts.vat-pc
                        , p-curr-host-code
                        , pobj-type
                        , pobj-code
                        , pw-p-code
                        , pwth-code
                        , ppar-code
                        , pin-code
                        , pout-code
                        , tt-wth-parts.cli-type
                        , tt-wth-parts.cli-code
                        , buf_wth-doc.ext-doc-type
                        , b-goods.gds-code
                        , ptype
                        , INPUT-OUTPUT v-rec
                        ) no-error .
    if error-status:error then do:
        MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        undo, return error.
    end.

  end.
end. /*transaction*/
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

