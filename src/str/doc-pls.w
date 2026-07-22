&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-tt-doc-pl


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE SHARED TEMP-TABLE tt-doc-pl NO-UNDO 
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-tt-doc-pl
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Распределение по местам хранения товара в документе

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/17/07
Author: Dmitry Ukhanov
Creation date: 09/17/07

*/

/*----------------------------------------------------------------------*/
/*         This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc               as handle    no-undo .
define input  parameter p-mode                      as character no-undo .
define input  parameter p-upd-field                 as character no-undo .
define input  parameter p-upd-units                 as character no-undo .
define input  parameter p-doc-code                  like ub.trn-doc.doc-code        no-undo .
define input  parameter p-gds-code                  like ub.goods.gds-code          no-undo .
define input  parameter p-doc-line-unit-cli         like ub.doc-line.unit-cli       no-undo .
define input  parameter p-doc-line-cli-base-rate    like ub.doc-line.cli-base-rate  no-undo .
define input  parameter p-doc-line-doc-density      like ub.doc-line.doc-density    no-undo .
define input  parameter p-doc-line-fact-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-cli-qnty         like ub.doc-line.cli-qnty       no-undo .
define input  parameter p-doc-line-doc-qnty         like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-qnty        like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-doc-cli-qnty     like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-cli-qnty    like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-rest-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
define input  parameter p-doc-line-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Распределение по местам хранения товара в документе":U .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }

&global-define curr-proc-name 'doc-pls':U
&scoped-define rest-density "Плотность"

define variable v-mode      as character no-undo .
define variable v-upd-units as character no-undo .

define variable v-is-ptrl   as character no-undo .
define variable tt-density  as decimal   no-undo .
define variable pl-j        as integer   no-undo .

define variable par-type          as character no-undo .
define variable v-value-char      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-rvd-own-nb      as logical   no-undo .
define variable v-tth             as handle    no-undo .
 
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_place  for ub.place .

define temp-table tt-info no-undo
  field info-num  as integer
  field info-type as character  FORMAT "X(29)":U label "":U
  field info-stts as character  FORMAT "X(15)":U label "":U
  field qnty      as character  FORMAT "X(16)":U label "":C16
  field cli-qnty  as character  FORMAT "X(16)":U label "":C16
  field density   as character  FORMAT "X(16)":U label "":C16
  index pi is unique primary info-num
  .

define temp-table save-tt-doc-pl no-undo like tt-doc-pl .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-tt-doc-pl
&Scoped-define BROWSE-NAME br-doc-pl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-doc-pl tt-info

/* Definitions for BROWSE br-doc-pl                                     */
&Scoped-define FIELDS-IN-QUERY-br-doc-pl tt-doc-pl.pl-code tt-doc-pl.cli-qnty tt-doc-pl.doc-qnty tt-doc-pl.cli-doc-qnty tt-doc-pl.fact-qnty tt-doc-pl.cli-fact-qnty tt-doc-pl.rest-af-qnty tt-doc-pl.cli-rest-af-qnty tt-density tt-doc-pl.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-doc-pl
&Scoped-define SELF-NAME br-doc-pl
&Scoped-define QUERY-STRING-br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-doc-pl OPEN QUERY {&SELF-NAME} FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-doc-pl tt-doc-pl
&Scoped-define FIRST-TABLE-IN-QUERY-br-doc-pl tt-doc-pl


/* Definitions for BROWSE br-info                                       */
&Scoped-define FIELDS-IN-QUERY-br-info tt-info.info-type tt-info.info-stts tt-info.qnty tt-info.cli-qnty tt-info.density
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-info
&Scoped-define SELF-NAME br-info
&Scoped-define QUERY-STRING-br-info FOR EACH tt-info
&Scoped-define OPEN-QUERY-br-info OPEN QUERY {&SELF-NAME} FOR EACH tt-info .
&Scoped-define TABLES-IN-QUERY-br-info tt-info
&Scoped-define FIRST-TABLE-IN-QUERY-br-info tt-info


/* Definitions for DIALOG-BOX f-tt-doc-pl                               */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-tt-doc-pl ~
    ~{&OPEN-QUERY-br-doc-pl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-lkp b-help br-doc-pl br-info
&Scoped-Define DISPLAYED-OBJECTS f-pl-name f-units-base

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add DEFAULT
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg DEFAULT
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del DEFAULT
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp DEFAULT
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-doc-line-cli-doc-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-fact-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-qnty LIKE ub.doc-line.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-rest-af-qnty LIKE ub.inv-line.after-cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-doc-qnty LIKE ub.doc-line.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-fact-qnty LIKE ub.doc-line.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-rest-af-qnty LIKE ub.doc-line.cli-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-label-density AS CHARACTER FORMAT "x(25)":U INITIAL "Плотность"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-pl-name LIKE ub.place.pl-name FORMAT "99999999999":U
     LABEL "Место хранения"
     VIEW-AS FILL-IN
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-label AS CHARACTER FORMAT "X(256)":U INITIAL "Итого по строке документа:"
      VIEW-AS TEXT
     SIZE 27.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-doc-qnty LIKE ub.doc-pl.cli-doc-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-fact-qnty LIKE ub.doc-pl.cli-fact-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-qnty LIKE ub.doc-pl.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-rest-af-qnty LIKE ub.doc-pl.cli-rest-af-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-doc-qnty LIKE ub.doc-pl.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-fact-qnty LIKE ub.doc-pl.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-rest-af-qnty LIKE ub.doc-pl.rest-af-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-units-base LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-units-cli LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-doc-pl FOR
      tt-doc-pl SCROLLING.

DEFINE QUERY br-info FOR
      tt-info SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-doc-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-doc-pl f-tt-doc-pl _FREEFORM
  QUERY br-doc-pl NO-LOCK DISPLAY
      tt-doc-pl.pl-code COLUMN-LABEL "Место хр." FORMAT "99999999999":U
            WIDTH 10
      tt-doc-pl.cli-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.doc-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-doc-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.fact-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-fact-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 18.5
      tt-doc-pl.rest-af-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-rest-af-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-density COLUMN-LABEL {&rest-density} FORMAT "->>9.9999999999":U
            WIDTH 14
      tt-doc-pl.gds-code FORMAT "99999999999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS DROP-TARGET SIZE 96.5 BY 5.25 FIT-LAST-COLUMN.

DEFINE BROWSE br-info
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-info f-tt-doc-pl _FREEFORM
  QUERY br-info DISPLAY
      tt-info.info-type
 tt-info.info-stts
 tt-info.qnty
 tt-info.cli-qnty
 tt-info.density
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-AUTO-VALIDATE NO-ROW-MARKERS SEPARATORS NO-TAB-STOP SIZE 96.5 BY 5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-tt-doc-pl
     b-quit AT ROW 1 COL 2
     b-add AT ROW 1 COL 12 WIDGET-ID 2
     b-chg AT ROW 1 COL 22 WIDGET-ID 4
     b-lkp AT ROW 1 COL 32 WIDGET-ID 6
     b-del AT ROW 1 COL 42 WIDGET-ID 8
     b-help AT ROW 1 COL 88
     br-doc-pl AT ROW 2.25 COL 2 WIDGET-ID 200
     f-pl-name AT ROW 7.75 COL 16.5 COLON-ALIGNED HELP
          "" WIDGET-ID 24
          LABEL "Место хранения" FORMAT "X(78)"
     br-info AT ROW 9 COL 2 HELP
          "" WIDGET-ID 300
     f-units-base AT ROW 14.25 COL 45 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 20 FORMAT "X(5)"
     f-units-cli AT ROW 14.25 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 40 FORMAT "X(5)"
     f-label-density AT ROW 14.25 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 172
     f-tot-doc-pl-rest-af-qnty AT ROW 15.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 78
          LABEL "Стало"
     f-tot-doc-pl-cli-rest-af-qnty AT ROW 15.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 76
     f-tot-doc-pl-rest-density AT ROW 15.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     f-tot-doc-pl-doc-qnty AT ROW 16.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 44
          LABEL "Заявлено"
     f-tot-doc-pl-cli-doc-qnty AT ROW 16.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 56
     f-tot-doc-pl-cli-qnty AT ROW 17 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 74
          LABEL "по ТТН" FORMAT "->>,>>>,>>9.<<<"
     f-tot-doc-pl-fact-qnty AT ROW 17.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 48
          LABEL "Фактически"
     f-tot-doc-pl-cli-fact-qnty AT ROW 17.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 54
     f-doc-line-rest-af-qnty AT ROW 19 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 82
          LABEL "Стало"
     f-doc-line-cli-rest-af-qnty AT ROW 19 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 80
     f-doc-line-rest-density AT ROW 19 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     f-doc-line-cli-qnty AT ROW 20 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 72
          LABEL "по ТТН"
     f-doc-line-doc-qnty AT ROW 20 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 60
          LABEL "Заявлено"
     f-doc-line-cli-doc-qnty AT ROW 20 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 58
     f-doc-line-doc-density AT ROW 20 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     f-doc-line-fact-qnty AT ROW 21 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 68
          LABEL "Фактически"
     f-doc-line-cli-fact-qnty AT ROW 21 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 66
     f-doc-line-fact-density AT ROW 21 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     f-tot-doc-label AT ROW 19 COL 3 NO-LABEL WIDGET-ID 210
     "Итого по местам хранения" VIEW-AS TEXT
          SIZE 24.5 BY .67 AT ROW 15.75 COL 3 WIDGET-ID 52
     rect-tot AT ROW 15.5 COL 2 WIDGET-ID 50
     SPACE(0.74) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Места хранения по документу"
         DEFAULT-BUTTON b-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: tt-doc-pl T "SHARED" NO-UNDO ub doc-pl
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-tt-doc-pl
   FRAME-NAME                                                           */
/* BROWSE-TAB br-doc-pl rect-tot f-tt-doc-pl */
/* BROWSE-TAB br-info f-pl-name f-tt-doc-pl */
ASSIGN
       FRAME f-tt-doc-pl:SCROLLABLE       = FALSE
       FRAME f-tt-doc-pl:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-add IN FRAME f-tt-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-chg IN FRAME f-tt-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-del IN FRAME f-tt-doc-pl
   NO-ENABLE                                                            */
ASSIGN
       br-doc-pl:ALLOW-COLUMN-SEARCHING IN FRAME f-tt-doc-pl = TRUE
       br-doc-pl:COLUMN-RESIZABLE IN FRAME f-tt-doc-pl       = TRUE
       br-doc-pl:COLUMN-MOVABLE IN FRAME f-tt-doc-pl         = TRUE.

ASSIGN
       br-info:COLUMN-RESIZABLE IN FRAME f-tt-doc-pl       = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-doc-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN
       f-doc-line-cli-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-fact-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN
       f-doc-line-cli-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN
       f-doc-line-cli-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-rest-af-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.inv-line.after-cli-qnty EXP-LABEL EXP-SIZE */
ASSIGN
       f-doc-line-cli-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-doc-density IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-doc-line-doc-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-doc-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-doc-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.doc-qnty EXP-LABEL EXP-SIZE  */
ASSIGN
       f-doc-line-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-fact-density IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-doc-line-fact-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-fact-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-fact-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.fact-qnty EXP-LABEL EXP-SIZE */
ASSIGN
       f-doc-line-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-rest-af-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN
       f-doc-line-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-rest-density IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-doc-line-rest-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-rest-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-label-density IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-label-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-label-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-pl-name IN FRAME f-tt-doc-pl
   NO-ENABLE LIKE = ub.place.pl-name EXP-LABEL EXP-FORMAT EXP-SIZE      */
ASSIGN
       f-pl-name:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-label IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       f-tot-doc-label:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-label:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-doc-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-doc-qnty EXP-SIZE          */
ASSIGN
       f-tot-doc-pl-cli-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-fact-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-fact-qnty EXP-SIZE         */
ASSIGN
       f-tot-doc-pl-cli-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-qnty EXP-LABEL EXP-FORMAT EXP-SIZE */
ASSIGN
       f-tot-doc-pl-cli-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-rest-af-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-rest-af-qnty EXP-LABEL EXP-SIZE */
ASSIGN
       f-tot-doc-pl-cli-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-doc-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.doc-qnty EXP-LABEL EXP-SIZE    */
ASSIGN
       f-tot-doc-pl-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-fact-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.fact-qnty EXP-LABEL EXP-SIZE   */
ASSIGN
       f-tot-doc-pl-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-rest-af-qnty IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.rest-af-qnty EXP-LABEL EXP-SIZE */
ASSIGN
       f-tot-doc-pl-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-rest-density IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-tot-doc-pl-rest-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-rest-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-units-base IN FRAME f-tt-doc-pl
   NO-ENABLE LIKE = ub.goods.unit-base EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN
       f-units-base:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-units-cli IN FRAME f-tt-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.goods.unit-base EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN
       f-units-cli:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-units-cli:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.

/* SETTINGS FOR RECTANGLE rect-tot IN FRAME f-tt-doc-pl
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-doc-pl
/* Query rebuild information for BROWSE br-doc-pl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-doc-pl
      WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Where[1]         = "Temp-Tables.tt-doc-pl.gds-code = p-gds-code"
     _Query            is OPENED
*/  /* BROWSE br-doc-pl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-info
/* Query rebuild information for BROWSE br-info
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-info .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-info */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX f-tt-doc-pl
/* Query rebuild information for DIALOG-BOX f-tt-doc-pl
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX f-tt-doc-pl */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-tt-doc-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tt-doc-pl f-tt-doc-pl
ON WINDOW-CLOSE OF FRAME f-tt-doc-pl /* Места хранения по документу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-tt-doc-pl
ON CHOOSE OF b-add IN FRAME f-tt-doc-pl /* Добавить */
DO:
  { gbl/stdbtn.i }

  define variable v-free-pl-list as   character         no-undo .
  define variable v-pl-code      like ub.doc-pl.pl-code no-undo .
  define variable v-pl-code2      like ub.doc-pl.pl-code no-undo .

/*  assign                                                                                                    */
/*    v-free-pl-list = "":U                                                                                   */
/*  .                                                                                                         */
/*                                                                                                            */
/*  for each buf_pl-gds no-lock                                                                               */
/*    where buf_pl-gds.obj-code = buf_trn-doc.obj-code                                                        */
/*      and buf_pl-gds.obj-type = buf_trn-doc.obj-type                                                        */
/*      and buf_pl-gds.gds-code = p-gds-code                                                                  */
/*  on error undo, return no-apply                                                                            */
/*  :                                                                                                         */
/*    find first tt-doc-pl                                                                                    */
/*      where tt-doc-pl.gds-code = p-gds-code                                                                 */
/*        and tt-doc-pl.obj-code = buf_trn-doc.obj-code                                                       */
/*        and tt-doc-pl.obj-type = buf_trn-doc.obj-type                                                       */
/*        and tt-doc-pl.out-code = buf_trn-doc.doc-code                                                       */
/*        and tt-doc-pl.pl-code  = buf_pl-gds.pl-code                                                         */
/*      no-error .                                                                                            */
/*    if not available tt-doc-pl then do:                                                                     */
/*      if v-free-pl-list <> "":U then do:                                                                    */
/*        assign                                                                                              */
/*          v-free-pl-list = v-free-pl-list + {&comma-char}                                                   */
/*        .                                                                                                   */
/*      end.                                                                                                  */
/*      assign                                                                                                */
/*        v-free-pl-list = v-free-pl-list + substitute( "&1", buf_pl-gds.pl-code )                            */
/*      .                                                                                                     */
/*    end.                                                                                                    */
/*  end.                                                                                                      */
/*                                                                                                            */
/*  if v-free-pl-list = "":U then do:                                                                         */
/*    message                                                                                                 */
/*      substitute( "В документе &1 все места хранения товара &2 уже заведены.", p-doc-code, p-gds-code ) skip*/
/*      view-as alert-box information.                                                                        */
/*  end.                                                                                                      */
/*  else do:                                                                                                  */
/*    if num-entries( v-free-pl-list, {&comma-char} ) = 1 then do:*/
/*      assign                                                    */
/*        v-pl-code = integer( v-free-pl-list )                   */
/*      .                                                         */
/*    end.                                                        */
/*    else do:                                                    */
      assign
        v-pl-code = ?
        v-pl-code2 = ?
      .
/*    end.*/

    for each save-tt-doc-pl
    on error undo, return no-apply
    :
      delete save-tt-doc-pl.
    end.
    for each tt-doc-pl
    on error undo, return no-apply
    :
      create save-tt-doc-pl.
      buffer-copy tt-doc-pl to save-tt-doc-pl .
    end.
    block_create:
    do
    on error  undo, retry
    on stop   undo, retry
    on endkey undo, retry
    :
      if retry then do:
        for each tt-doc-pl
        on error undo, return no-apply
        :
          delete tt-doc-pl .
        end.
        for each save-tt-doc-pl
        on error undo, return no-apply
        :
          create tt-doc-pl.
          buffer-copy save-tt-doc-pl to tt-doc-pl .
          delete save-tt-doc-pl.
        end.
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении данных на месте хранения.") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        leave block_create .
      end.
      if not available buf_trn-doc then
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
      .
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
          run str/doc-pl-int.w
            ( input parparentproc
            , input v-mode
            , input p-upd-field
            , input v-upd-units
            , input p-doc-code
            , input p-gds-code
            , input v-pl-code
            , input v-pl-code2
            , input p-doc-line-unit-cli
            , input p-doc-line-cli-base-rate
            , input p-doc-line-doc-density
            , input p-doc-line-fact-density
            , input p-doc-line-cli-qnty
            , input p-doc-line-doc-qnty
            , input p-doc-line-fact-qnty
            , input p-doc-line-doc-cli-qnty
            , input p-doc-line-fact-cli-qnty
            , input p-doc-line-rest-density
            , input p-doc-line-rest-af-qnty
            , input p-doc-line-cli-rest-af-qnty
            ) .
      end.
      else do :
          run str/doc-pl.w
            ( input parparentproc
            , input v-mode
            , input p-upd-field
            , input v-upd-units
            , input p-doc-code
            , input p-gds-code
            , input v-pl-code
            , input p-doc-line-unit-cli
            , input p-doc-line-cli-base-rate
            , input p-doc-line-doc-density
            , input p-doc-line-fact-density
            , input p-doc-line-cli-qnty
            , input p-doc-line-doc-qnty
            , input p-doc-line-fact-qnty
            , input p-doc-line-doc-cli-qnty
            , input p-doc-line-fact-cli-qnty
            , input p-doc-line-rest-density
            , input p-doc-line-rest-af-qnty
            , input p-doc-line-cli-rest-af-qnty
            ) .
      end.
      
      run calc-qnty in this-procedure .
    end.

    {&OPEN-QUERY-br-doc-pl}
    apply "value-changed" to br-doc-pl IN FRAME {&frame-name}.
    { str/doc-pl.i disp-total }
/*  end.*/
  apply "entry" to browse br-doc-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg f-tt-doc-pl
ON CHOOSE OF b-chg IN FRAME f-tt-doc-pl /* Изменить */
DO:
  { gbl/stdbtn.i }

  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.

  for each save-tt-doc-pl
  on error undo, return no-apply
  :
    delete save-tt-doc-pl.
  end.

  create save-tt-doc-pl.
  buffer-copy tt-doc-pl to save-tt-doc-pl .

  block_update:
  do
  on error  undo, retry
  on stop   undo, retry
  on endkey undo, retry
  :
    if retry then do:
      buffer-copy save-tt-doc-pl to tt-doc-pl .
      delete save-tt-doc-pl.
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при изменении данных на месте хранения.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      leave block_update .
    end.
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
        run str/doc-pl-int.w
          ( input parparentproc
          , input v-mode
          , input p-upd-field
          , input v-upd-units
          , input p-doc-code
          , input p-gds-code
          , input tt-doc-pl.pl-code
          , input tt-doc-pl.pl-code2
          , input p-doc-line-unit-cli
          , input p-doc-line-cli-base-rate
          , input p-doc-line-doc-density
          , input p-doc-line-fact-density
          , input p-doc-line-cli-qnty
          , input p-doc-line-doc-qnty
          , input p-doc-line-fact-qnty
          , input p-doc-line-doc-cli-qnty
          , input p-doc-line-fact-cli-qnty
          , input p-doc-line-rest-density
          , input p-doc-line-rest-af-qnty
          , input p-doc-line-cli-rest-af-qnty
          ) .
    end.
    else do :
/*        if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and pl-j = 1*/
/*          then v-mode = {&lookup}.                                   */ 
        run str/doc-pl.w
          ( input parparentproc
          , input (if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and pl-j = 1 then {&lookup} else v-mode)
          , input p-upd-field
          , input v-upd-units
          , input p-doc-code
          , input p-gds-code
          , input tt-doc-pl.pl-code
          , input p-doc-line-unit-cli
          , input p-doc-line-cli-base-rate
          , input p-doc-line-doc-density
          , input p-doc-line-fact-density
          , input p-doc-line-cli-qnty
          , input p-doc-line-doc-qnty
          , input p-doc-line-fact-qnty
          , input p-doc-line-doc-cli-qnty
          , input p-doc-line-fact-cli-qnty
          , input p-doc-line-rest-density
          , input p-doc-line-rest-af-qnty
          , input p-doc-line-cli-rest-af-qnty
          ) .
    end.

    run calc-qnty in this-procedure
      .
  end.

  delete save-tt-doc-pl .

  {&OPEN-QUERY-br-doc-pl}
  apply "value-changed" to br-doc-pl IN FRAME {&frame-name}.
  { str/doc-pl.i disp-total }
  apply "entry" to browse br-doc-pl .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-tt-doc-pl
ON CHOOSE OF b-del IN FRAME f-tt-doc-pl /* Удалить */
DO:
  { gbl/stdbtn.i }

  define variable v-delete as logical   no-undo .

  if v-mode = {&lookup} then do:
    return no-apply .
  end.

  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.

  message
    "Вы уверены, что хотите удалить запись?" skip
    view-as alert-box question buttons yes-no update v-delete
    .
  if v-delete = true then do:
    delete tt-doc-pl .
    {&OPEN-QUERY-br-doc-pl}
    apply "value-changed" to br-doc-pl IN FRAME {&frame-name}.
    { str/doc-pl.i disp-total }
  end.
  else do:
    return no-apply .
  end.
  apply "entry" to browse br-doc-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp f-tt-doc-pl
ON CHOOSE OF b-lkp IN FRAME f-tt-doc-pl /* Просмотр */
DO:
  { gbl/stdbtn.i }
  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.
  if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do :
      run str/doc-pl-int.w
        ( input parparentproc
         ,input {&lookup}
         ,input p-upd-field
         ,input v-upd-units
         ,input p-doc-code
         ,input p-gds-code
         ,input tt-doc-pl.pl-code
         ,input tt-doc-pl.pl-code2
         ,input p-doc-line-unit-cli
         ,input p-doc-line-cli-base-rate
         ,input p-doc-line-doc-density
         ,input p-doc-line-fact-density
         ,input p-doc-line-cli-qnty
         ,input p-doc-line-doc-qnty
         ,input p-doc-line-fact-qnty
         ,input p-doc-line-doc-cli-qnty
         ,input p-doc-line-fact-cli-qnty
         ,input p-doc-line-rest-density
         ,input p-doc-line-rest-af-qnty
         ,input p-doc-line-cli-rest-af-qnty
        ).
  end.
  else do :
      run str/doc-pl.w
        ( input parparentproc
         ,input {&lookup}
         ,input p-upd-field
         ,input v-upd-units
         ,input p-doc-code
         ,input p-gds-code
         ,input tt-doc-pl.pl-code
         ,input p-doc-line-unit-cli
         ,input p-doc-line-cli-base-rate
         ,input p-doc-line-doc-density
         ,input p-doc-line-fact-density
         ,input p-doc-line-cli-qnty
         ,input p-doc-line-doc-qnty
         ,input p-doc-line-fact-qnty
         ,input p-doc-line-doc-cli-qnty
         ,input p-doc-line-fact-cli-qnty
         ,input p-doc-line-rest-density
         ,input p-doc-line-rest-af-qnty
         ,input p-doc-line-cli-rest-af-qnty
        ).
  end.
  apply "entry" to browse br-doc-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit f-tt-doc-pl
ON CHOOSE OF b-quit IN FRAME f-tt-doc-pl /* Выход */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-doc-pl
&Scoped-define SELF-NAME br-doc-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-doc-pl f-tt-doc-pl
ON ROW-DISPLAY OF br-doc-pl IN FRAME f-tt-doc-pl
DO:
  if tt-doc-pl.rest-af-qnty <> 0.0
    and tt-doc-pl.cli-rest-af-qnty <> 0.0
  then do:
    assign
      tt-density = tt-doc-pl.cli-rest-af-qnty / tt-doc-pl.rest-af-qnty
    .
  end.
  else do:
    assign
      tt-density = p-doc-line-rest-density
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-doc-pl f-tt-doc-pl
ON VALUE-CHANGED OF br-doc-pl IN FRAME f-tt-doc-pl
DO:

  define variable v-state-measure-qnty     like ub.rvs-line.state-measure-qnty     no-undo .
  define variable v-measure-qnty           like ub.rvs-line.measure-qnty           no-undo .
  define variable v-state-measure-cli-qnty like ub.rvs-line.state-measure-cli-qnty no-undo .
  define variable v-measure-cli-qnty       like ub.rvs-line.measure-cli-qnty       no-undo .
  define variable v-rvs-state-density      like ub.rvs-line.state-density          no-undo .
  define variable v-rvs-density            like ub.rvs-line.density                no-undo .
  define variable v-label                  as   character                          no-undo .

  for each tt-info
  :
    delete tt-info .
  end.

  if available tt-doc-pl then do:
    find first buf_place no-lock
      where buf_place.obj-code = tt-doc-pl.obj-code
        and buf_place.obj-type = tt-doc-pl.obj-type
        and buf_place.pl-code  = tt-doc-pl.pl-code
      no-error
      .
    if available buf_place then do:
      display
        buf_place.pl-name @ f-pl-name
        with frame {&frame-name}
        .
    end.

    find first buf_pl-gds no-lock
      where buf_pl-gds.obj-code = tt-doc-pl.obj-code
        and buf_pl-gds.obj-type = tt-doc-pl.obj-type
        and buf_pl-gds.pl-code  = tt-doc-pl.pl-code
        and buf_pl-gds.gds-code = tt-doc-pl.gds-code
      no-error .
    if available buf_pl-gds then do:
      create tt-info .
      assign
        tt-info.info-num  = 1
        tt-info.info-type = "Остаток РКн"
        tt-info.info-stts = "(свободно)"
        tt-info.qnty      = string( buf_pl-gds.free-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( buf_pl-gds.cli-free-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( (buf_pl-gds.cli-free-qnty / buf_pl-gds.free-qnty), "->>9.9999999999":U )
      .
      create tt-info .
      assign
        tt-info.info-num  = 2
/*        tt-info.info-type = "Остаток РКн"*/
        tt-info.info-stts = "(фактически)"
        tt-info.qnty      = string( buf_pl-gds.fact-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( buf_pl-gds.cli-fact-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( buf_pl-gds.cli-fact-qnty / buf_pl-gds.fact-qnty, "->>9.9999999999":U )
      .
    end.

    run get-from-rvs in this-procedure
      ( input  tt-doc-pl.out-code
       ,input  tt-doc-pl.gds-code
       ,input  tt-doc-pl.pl-code
       ,output v-state-measure-qnty
       ,output v-measure-qnty
       ,output v-state-measure-cli-qnty
       ,output v-measure-cli-qnty
       ,output v-rvs-state-density
       ,output v-rvs-density
       ,output v-label
      ) no-error .

    if v-label <> "":U then do:
      create tt-info .
      assign
        tt-info.info-num  = 3
        tt-info.info-type = v-label
        tt-info.info-stts = "(измерено)"
        tt-info.qnty      = string( v-measure-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( v-measure-cli-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( v-rvs-density, "->>9.9999999999":U )
      .
      create tt-info .
      assign
        tt-info.info-num  = 4
/*        tt-info.info-type = v-label*/
        tt-info.info-stts = "(фактически)"
        tt-info.qnty      = string( v-state-measure-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( v-state-measure-cli-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( v-rvs-state-density, "->>9.9999999999":U )
      .
    end.
  end.
  {&OPEN-QUERY-br-info}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-tt-doc-pl


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ str/doc-pl.i def }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define variable v-add-mode1     as   character         no-undo .
  define variable v-av-place      as   logical           no-undo .
  define variable v-pl-code       like ub.doc-pl.pl-code no-undo .
  define variable v-single-place  as   logical           no-undo .
  define variable v-chk-qnty      as   decimal           no-undo .
  define variable v-new-qnty      as   decimal           no-undo .
  define variable v-column-handle as   handle            no-undo .
  define variable v-for-upd-units as   character         no-undo .
  define variable v-loc1          like ub.place.loc1     no-undo .
  define variable v-pl-fact-qnty  as   decimal           no-undo . 
  define variable v-pl-cli-fact-qnty  as   decimal       no-undo . 

  assign /* это нужно для устранения глюка прогресса всязанного с передачей параметров - обрезаем все переменные соответственно их decimals */
    p-doc-line-cli-base-rate    = p-doc-line-cli-base-rate
    p-doc-line-doc-density      = p-doc-line-doc-density
    p-doc-line-fact-density     = p-doc-line-fact-density
    p-doc-line-cli-qnty         = p-doc-line-cli-qnty
    p-doc-line-doc-qnty         = p-doc-line-doc-qnty
    p-doc-line-fact-qnty        = p-doc-line-fact-qnty
    p-doc-line-doc-cli-qnty     = p-doc-line-doc-cli-qnty
    p-doc-line-fact-cli-qnty    = p-doc-line-fact-cli-qnty
    p-doc-line-rest-density     = p-doc-line-rest-density
    p-doc-line-rest-af-qnty     = p-doc-line-rest-af-qnty
    p-doc-line-cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
  .

  assign
    v-mode = entry( 1, p-mode, {&delim-par} )
  .
  if num-entries( p-mode, {&delim-par} ) >= 2
  then do:
    assign
      v-add-mode1 = entry( 2, p-mode, {&delim-par} )
    .
  end.
  assign
    v-upd-units     = p-upd-units
    v-for-upd-units = p-upd-units
  .
  
  pl-j = 0.
  for each tt-doc-pl no-lock:
    pl-j = pl-j + 1.  
  end.
  
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    .

  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do :
      br-doc-pl:handle:add-like-column ("tt-doc-pl.pl-code2", 1) .
      br-doc-pl:handle:get-browse-column (1):label = "Место хр. c" .
      br-doc-pl:handle:get-browse-column (2):label = "Место хр. на" .
      br-doc-pl:handle:get-browse-column (1):width-chars = 11 .
      br-doc-pl:handle:get-browse-column (2):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (3):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (4):width-chars = 13 .
      br-doc-pl:handle:get-browse-column (5):width-chars = 14 .
      br-doc-pl:handle:get-browse-column (6):width-chars = 15 .
      br-doc-pl:handle:get-browse-column (7):width-chars = 16 .
  end.
  if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
      br-doc-pl:handle:add-like-column ("tt-doc-pl.pl-code2", 2) .
      br-doc-pl:handle:get-browse-column (1):label = "Место хр. c" .
      br-doc-pl:handle:get-browse-column (2):label = "Место хр. на" .
      br-doc-pl:handle:get-browse-column (1):width-chars = 11 .
      br-doc-pl:handle:get-browse-column (2):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (3):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (4):width-chars = 13 .
      br-doc-pl:handle:get-browse-column (5):width-chars = 14 .
      br-doc-pl:handle:get-browse-column (6):width-chars = 15 .
      br-doc-pl:handle:get-browse-column (7):width-chars = 16 .
  end.
  
  if p-upd-field = "doc":U then do:
    assign
      p-doc-line-fact-cli-qnty = p-doc-line-doc-cli-qnty
      p-doc-line-fact-qnty     = p-doc-line-doc-qnty
    .
  end.

  { str/doc-pl.i init-tot p-gds-code v-is-ptrl }

  assign
    v-av-place     = false
    v-single-place = false
    v-pl-code      = ?
  .
  
  if num-entries( p-mode, {&delim-par} ) >= 3
  then do:
    if entry(3, p-mode, {&delim-par} ) begins "place"
    then do :
      v-loc1 = entry(2, entry(3, p-mode, {&delim-par}), "=") .
      for first buf_place no-lock where buf_place.obj-code = buf_trn-doc.obj-code
                                    and buf_place.obj-type = buf_trn-doc.obj-type
                                    and buf_place.loc1 = v-loc1
                                    and buf_place.status_ <> {&deleted-status},
      first buf_pl-gds no-lock where buf_pl-gds.obj-code = buf_trn-doc.obj-code
                                 and buf_pl-gds.obj-type = buf_trn-doc.obj-type
                                 and buf_pl-gds.gds-code = p-gds-code
                                 and buf_pl-gds.pl-code = buf_place.pl-code
                                 :
        assign
          v-av-place     = true
          v-single-place = true
          v-pl-code      = buf_place.pl-code
        .                           
      end .
    end .
  end .
  
  if v-pl-code = ?
  then do :
    block_check-pl-gds :
    for each buf_pl-gds no-lock
      where buf_pl-gds.obj-code = buf_trn-doc.obj-code
        and buf_pl-gds.obj-type = buf_trn-doc.obj-type
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      assign
        v-av-place = true
      .
      if v-single-place = false then do:
        assign
          v-pl-code      = buf_pl-gds.pl-code
          v-single-place = true
        .
      end.
      else do:
        assign
          v-single-place = false
        .
        leave block_check-pl-gds .
      end.
    end.
  end .

  if v-add-mode1 <> "":U then do:
    case v-add-mode1 :
      when "update-dens":U
      or when "update-dens-cli":U
      or when "update-dens-base":U
      then do:
        if v-single-place
        then do :
          find first tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.pl-code  = v-pl-code
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
            no-error .
        end .
        else do :
          find first tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
            no-error .
        end .
        if available tt-doc-pl then do:
          case v-add-mode1 :
            when "update-dens-cli":U then do:
              assign
                v-upd-units     = "cli":U
                v-for-upd-units = "base":U
              .
            end.
            when "update-dens-base":U then do:
              assign
                v-upd-units     = "base":U
                v-for-upd-units = "cli":U
              .
            end.
          end case.
          pl-j = 0.
          for each tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
              and ((v-single-place and tt-doc-pl.pl-code = v-pl-code) or not v-single-place)
          on error undo, return error return-value
          :
            if p-upd-field = "rest":U
              or p-upd-field = "rest-fact":U
            then do:
              pl-j = pl-j + 1.
/*              if v-single-place = true then do:*/
/*                if v-for-upd-units = "base":U then do:*/
/*                  assign*/
/*                    tt-doc-pl.cli-rest-af-qnty = tt-doc-pl.rest-af-qnty * p-doc-line-rest-density*/
/*                  .*/
/*                end.*/
/*                else do:*/
/*                  assign*/
/*                    tt-doc-pl.rest-af-qnty = tt-doc-pl.cli-rest-af-qnty / p-doc-line-rest-density*/
/*                  .*/
/*                end.*/
/*                { str/doc-pl.i clc-doc-pl-for-rest tt-doc-pl }*/
/*              end.*/
/*              else do:*/
/*                message*/
/*                  vss-workfile vss-revision vss-description skip*/
/*                  substitute("Нельзя пересчитать плотность этим методом т.к. у товара есть несколько мест хранения") skip*/
/*                  view-as alert-box error .*/
/*                return error .*/
/*              end.*/
            end.
            else do:
              if v-for-upd-units = "base":U then do:
                if p-upd-field = "doc":U
                  or p-upd-field = "fact-doc":U
                then do:
                  assign
                    tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                  .
                end.
                assign
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                .
              end.
              else do:
                if p-upd-field = "doc":U
                  or p-upd-field = "fact-doc":U
                then do:
                  assign
                    tt-doc-pl.doc-qnty = tt-doc-pl.cli-doc-qnty / p-doc-line-doc-density
                  .
                end.
                assign
                  tt-doc-pl.fact-qnty = tt-doc-pl.cli-fact-qnty / p-doc-line-fact-density
                .
              end.
              if p-upd-field = "doc":U
                or p-upd-field = "fact-doc":U
              then do:
                assign
                  tt-doc-pl.cli-qnty = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                .
                if abs(tt-doc-pl.cli-qnty - tt-doc-pl.cli-doc-qnty) < 0.0011
                then do :
                  assign
                    tt-doc-pl.cli-qnty = tt-doc-pl.cli-doc-qnty
                  .
                end .
              end.
            end.
          end.
          if v-mode = {&autoupdate}
            and ( v-single-place = true
                  or ( v-single-place = false
                      and v-add-mode1 = "update-dens":U
                    )
                )
          then do:
            return .
          end.
        end.
      end.
      when "calc-qnty":U then do:
        run calc-qnty in this-procedure .
        if v-mode = {&autoupdate} then do:
          return .
        end.
      end.
    end case.
  end.

  if v-mode <> {&lookup}
    and p-upd-field <> "rest":U
    and p-upd-field <> "rest-fact":U
    and buf_trn-doc.status_ <> {&fact}
  then do:
    if v-av-place = true then do:
      if v-single-place = true then do:
        find first tt-doc-pl
          where tt-doc-pl.gds-code = p-gds-code
            and tt-doc-pl.obj-code = buf_trn-doc.obj-code
            and tt-doc-pl.obj-type = buf_trn-doc.obj-type
            and tt-doc-pl.out-code = buf_trn-doc.doc-code
            and tt-doc-pl.pl-code  = v-pl-code
          no-error .
        if not available tt-doc-pl then do:
          create tt-doc-pl .
          assign
            tt-doc-pl.gds-code               = p-gds-code
            tt-doc-pl.obj-code               = buf_trn-doc.obj-code
            tt-doc-pl.obj-type               = buf_trn-doc.obj-type
            tt-doc-pl.out-code               = buf_trn-doc.doc-code
            tt-doc-pl.pl-code                = v-pl-code
          .
        end.
        assign
          tt-doc-pl.cli-qnty         = p-doc-line-cli-qnty
          tt-doc-pl.cli-doc-qnty     = p-doc-line-doc-cli-qnty
          tt-doc-pl.doc-qnty         = p-doc-line-doc-qnty
          tt-doc-pl.cli-fact-qnty    = p-doc-line-fact-cli-qnty
          tt-doc-pl.fact-qnty        = p-doc-line-fact-qnty
          tt-doc-pl.rest-af-qnty     = p-doc-line-rest-af-qnty
          tt-doc-pl.cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
        .
        case p-upd-field :
/*          when "rest":U then do:*/
/*            assign*/
/*              v-chk-qnty = tt-doc-pl.rest-af-qnty*/
/*            .*/
/*          end.*/
          when "doc":U then do:
            assign
              v-chk-qnty = tt-doc-pl.doc-qnty
            .
          end.
          when "fact":U
          or when "fact-doc":U
          then do:
            assign
              v-chk-qnty = tt-doc-pl.fact-qnty
            .
          end.
        end case.

        if v-chk-qnty <> 0.0 then do:
          { str/chkqnpl.i
            buf_trn-doc.doc-type
            tt-doc-pl.obj-type
            tt-doc-pl.obj-code
            tt-doc-pl.pl-code
            tt-doc-pl.gds-code
            true
            v-chk-qnty
            v-new-qnty
          }
          if v-chk-qnty <> v-new-qnty then do:
            case p-upd-field :
/*              when "rest":U then do:*/
/*                assign*/
/*                  tt-doc-pl.cli-rest-af-qnty = v-new-qnty * p-doc-line-rest-density*/
/*                  tt-doc-pl.rest-af-qnty     = v-new-qnty*/
/*                .*/
/*                { str/doc-pl.i clc-doc-pl-for-rest tt-doc-pl }*/
/*              end.*/
              when "doc":U then do:
                assign
                  tt-doc-pl.doc-qnty      = v-new-qnty
                  tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                  tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-doc-qnty
                  tt-doc-pl.fact-qnty     = tt-doc-pl.doc-qnty
                .
              end.
              when "fact":U then do:
                assign
                  tt-doc-pl.fact-qnty     = v-new-qnty
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                .
              end.
              when "fact-doc":U  then do:
                assign
                  tt-doc-pl.fact-qnty     = v-new-qnty
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                  tt-doc-pl.doc-qnty      = tt-doc-pl.fact-qnty * p-doc-line-doc-qnty / p-doc-line-fact-qnty
                  tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                  tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                .
              end.
            end case.
          end.
        end.
        if v-mode = {&autoupdate} then do:
          return .
        end.
      end. /* if v-single-place = true */
      
      if v-mode = {&autoupdate} then do:
        assign
          v-pl-fact-qnty      = 0
          v-pl-cli-fact-qnty  = 0
        .
        for each tt-doc-pl :
          assign
            v-pl-fact-qnty = v-pl-fact-qnty + tt-doc-pl.fact-qnty
            v-pl-cli-fact-qnty = v-pl-cli-fact-qnty + tt-doc-pl.cli-fact-qnty
          .
        end .
        if abs(p-doc-line-fact-qnty - v-pl-fact-qnty) <= 0.001
        and abs(p-doc-line-fact-cli-qnty - v-pl-cli-fact-qnty) <= 0.001
        then do :
          return .
        end .
      end.
    end.
    else do:
      message
        substitute( "Товара &1 не привязан к месту хранения", p-gds-code ) skip
        substitute( "на объекте &1 &2.", buf_trn-doc.obj-type, buf_trn-doc.obj-code ) skip
        view-as alert-box error.
      return error .
    end.
  end.

  { gbl/app_help.i }

  RUN enable_UI.

  assign
    frame {&frame-name} :title = substitute("Распределение по местам хранения товара &1 в документе &2", p-gds-code, p-doc-code )
    tt-doc-pl.gds-code  :visible in browse br-doc-pl = false
    tt-info.qnty        :label in browse br-info = f-units-base
    tt-info.cli-qnty    :label in browse br-info = f-units-cli
    tt-info.density     :label in browse br-info = f-label-density
  .
/*  if v-is-ptrl = "yes":U then do:*/
/*    assign*/
/*      tt-doc-pl.cli-qnty         :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.doc-qnty         :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.cli-doc-qnty     :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.fact-qnty        :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.cli-fact-qnty    :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.rest-af-qnty     :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*      tt-doc-pl.cli-rest-af-qnty :format in browse br-doc-pl = "->>,>>>,>>9.999":U*/
/*    .*/
/*  end.*/

  { str/doc-pl.i enable-tot-fld v-is-ptrl }

  {&OPEN-QUERY-br-doc-pl}

  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    assign
      tt-doc-pl.cli-qnty         :visible in browse br-doc-pl = false
      tt-doc-pl.cli-doc-qnty     :visible in browse br-doc-pl = false
      tt-doc-pl.doc-qnty         :visible in browse br-doc-pl = false
      tt-doc-pl.cli-fact-qnty    :label in browse br-doc-pl = "Разница" + {&space-char} + f-units-cli
      tt-doc-pl.fact-qnty        :label in browse br-doc-pl = "Разница" + {&space-char} + f-units-base
      tt-doc-pl.cli-rest-af-qnty :label in browse br-doc-pl = "Стало" + {&space-char} + f-units-cli
      tt-doc-pl.rest-af-qnty     :label in browse br-doc-pl = "Стало" + {&space-char} + f-units-base
    .
  end.
  else do:
    assign
      tt-doc-pl.cli-qnty         :label in browse br-doc-pl = tt-doc-pl.cli-qnty  :label in browse br-doc-pl + {&space-char} + "(" + trim( p-doc-line-unit-cli ) + ")"
      tt-doc-pl.cli-doc-qnty     :label in browse br-doc-pl = tt-doc-pl.doc-qnty  :label in browse br-doc-pl + {&space-char} + f-units-cli
      tt-doc-pl.doc-qnty         :label in browse br-doc-pl = tt-doc-pl.doc-qnty  :label in browse br-doc-pl + {&space-char} + f-units-base
      tt-doc-pl.cli-fact-qnty    :label in browse br-doc-pl = tt-doc-pl.fact-qnty :label in browse br-doc-pl + {&space-char} + f-units-cli
      tt-doc-pl.fact-qnty        :label in browse br-doc-pl = tt-doc-pl.fact-qnty :label in browse br-doc-pl + {&space-char} + f-units-base
      tt-doc-pl.cli-rest-af-qnty :visible in browse br-doc-pl = false
      tt-doc-pl.rest-af-qnty     :visible in browse br-doc-pl = false
    .
  end.

  if buf_goods.unit-base = buf_goods.unit-cli then do:
    assign
      tt-doc-pl.cli-doc-qnty     :visible in browse br-doc-pl = false
      tt-doc-pl.cli-fact-qnty    :visible in browse br-doc-pl = false
      tt-doc-pl.cli-rest-af-qnty :visible in browse br-doc-pl = false
      tt-info.cli-qnty           :visible in browse br-info   = false
      tt-info.density            :visible in browse br-info   = false
    .
  end.

  if ( p-upd-field <> "rest":U
       and p-upd-field <> "rest-fact":U
     )
    or buf_goods.unit-base = buf_goods.unit-cli
  then do:
    assign
      v-column-handle = browse br-doc-pl :handle :first-column
    .
    do while v-column-handle <> ?
    :
      if v-column-handle :label = {&rest-density} then do:
        assign
          v-column-handle :visible = false
        .
        leave.
      end.
      assign
        v-column-handle = v-column-handle :next-column
      .
    end.
  end.

  if v-mode <> {&lookup}
    and buf_trn-doc.status_ <> {&fact}
  then do:
    enable
      b-chg
      with frame {&frame-name} .
    if p-upd-field = "doc":U
      or p-upd-field = "fact-doc":U
    then do:
      if v-mode <> {&TDEDT_Pri_Perem}
      then do :
        enable
          b-add
          b-del
        with frame {&frame-name} .
      end .
      if v-mode = {&autoupdate}
        and v-single-place = true
      then do:
        apply "choose" to b-add in frame {&frame-name}.
      end.
    end.
  end.

  apply "value-changed" to br-doc-pl in frame {&frame-name}.

  { str/doc-pl.i disp-total }

  apply "entry" to br-doc-pl IN FRAME {&frame-name}.
  
  find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
      .
      
  run adm/shattri.p (
             input "get":U
            ,input  buf_trn-doc.obj-type
            ,input  buf_trn-doc.obj-code
            ,input  {&attr-petrol}
            ,input  {&attr-petrol_rvd-own-nb} /*p-param-code*/
            ,output v-value-char
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-rvd-own-nb
            ,output par-type
            ,input-output table-handle v-tth
            ) no-error .
  if error-status:error then do:
      if valid-object(v-tth) then delete object v-tth.
      v-rvd-own-nb = false .
  end.
  if v-rvd-own-nb = false
  and buf_trn-doc.cli-code > 0
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = buf_trn-doc.cli-type
                                         and ub.clients-attr.obj-code = buf_trn-doc.cli-code
                                         and ub.clients-attr.attr-code = {&attr-owner-code}
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(buf_trn-doc.host-code)
      then do :     
        disable b-add b-chg b-del with frame {&frame-name}.
      end .
    end .
  end .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-qnty f-tt-doc-pl
PROCEDURE calc-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error  undo, return error substitute( "&1 (calc-qnty). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (calc-qnty). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (calc-qnty). endkey", vss-workfile )
  :

    define variable v-count-doc-pl         as integer   no-undo .
    define variable v-null-fact-qnty       as logical   no-undo .
    define variable v-tot-fact-qnty        as decimal   no-undo .
    define variable v-correct-cli-qnty     as decimal   no-undo .
    define variable v-correct-doc-qnty     as decimal   no-undo .
    define variable v-correct-cli-doc-qnty as decimal   no-undo .
    if p-upd-field = "fact-doc":U then do:
      assign
        v-null-fact-qnty       = false
        v-count-doc-pl         = 0
        v-tot-fact-qnty        = 0.0
        v-correct-cli-qnty     = p-doc-line-cli-qnty
        v-correct-doc-qnty     = p-doc-line-doc-qnty
        v-correct-cli-doc-qnty = p-doc-line-doc-cli-qnty
      .
      for each tt-doc-pl
      on error  undo, return error substitute( "&1 (tt-doc-pl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (tt-doc-pl). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (tt-doc-pl). endkey", vss-workfile )
      :
        if tt-doc-pl.fact-qnty = 0.0 then do:
          assign
            v-null-fact-qnty = true
          .
        end.
        assign
          v-tot-fact-qnty        = v-tot-fact-qnty + tt-doc-pl.fact-qnty
          v-count-doc-pl         = v-count-doc-pl + 1
          tt-doc-pl.doc-qnty     = tt-doc-pl.fact-qnty * p-doc-line-doc-qnty / p-doc-line-fact-qnty
          tt-doc-pl.cli-qnty     = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
          tt-doc-pl.cli-doc-qnty = tt-doc-pl.doc-qnty * p-doc-line-doc-density
          v-correct-cli-qnty     = v-correct-cli-qnty     - tt-doc-pl.cli-qnty
          v-correct-doc-qnty     = v-correct-doc-qnty     - tt-doc-pl.doc-qnty
          v-correct-cli-doc-qnty = v-correct-cli-doc-qnty - tt-doc-pl.cli-doc-qnty
        .
        if absolute( v-correct-cli-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-qnty = tt-doc-pl.cli-qnty + v-correct-cli-qnty
          .
        end.
        if absolute( v-correct-doc-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.doc-qnty = tt-doc-pl.doc-qnty + v-correct-doc-qnty
          .
        end.
        if absolute( v-correct-cli-doc-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-doc-qnty = tt-doc-pl.cli-doc-qnty + v-correct-cli-doc-qnty
          .
        end.
      end.
      if v-null-fact-qnty = true then do:
        if v-count-doc-pl = 1 then do:
          find first tt-doc-pl .
          assign
            tt-doc-pl.doc-qnty     = p-doc-line-doc-qnty
            tt-doc-pl.cli-qnty     = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
            tt-doc-pl.cli-doc-qnty = tt-doc-pl.doc-qnty * p-doc-line-doc-density
          .
        end.
        else do:
          if v-tot-fact-qnty = 0.0 then do:
            return error substitute( "Если необходимо задавать нулевое кол-во, то это допустимо только при выборе одного места хранения!" ) .
          end.
          else do:
            return error substitute( "На одном из мест хранения задано нулевое кол-во, добавление других мест недопустимо!" ) .
          end.
        end.

      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-tt-doc-pl  _DEFAULT-DISABLE
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
  HIDE FRAME f-tt-doc-pl.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-tt-doc-pl  _DEFAULT-ENABLE
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
  DISPLAY f-pl-name f-units-base
      WITH FRAME f-tt-doc-pl.
  ENABLE b-quit b-lkp b-help br-doc-pl br-info
      WITH FRAME f-tt-doc-pl.
  VIEW FRAME f-tt-doc-pl.
  {&OPEN-BROWSERS-IN-QUERY-f-tt-doc-pl}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME