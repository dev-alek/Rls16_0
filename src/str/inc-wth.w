&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf02_clients FOR ub.clients.
DEFINE BUFFER buf02_wth-place FOR ub.wth-place.
DEFINE BUFFER buf03_clients FOR ub.clients.
DEFINE BUFFER buf03_wth-place FOR ub.wth-place.
DEFINE BUFFER buf04_clients FOR ub.clients.
DEFINE BUFFER buf04_wth-place FOR ub.wth-place.
DEFINE BUFFER buf05_clients FOR ub.clients.
DEFINE BUFFER buf05_wth-place FOR ub.wth-place.
DEFINE BUFFER buf07_clients FOR ub.clients.
DEFINE BUFFER buf07_wth-place FOR ub.wth-place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование автоматических документов МЦ на основе МЦ чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.


/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date$":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile$":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive$":u .
DEFINE VARIABLE vss-description as character no-undo init "Формирование автоматические документов МЦ на основе МЦ чеков" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
/*использовать смены на кассе для данного объекта*/
DEFINE VARIABLE cas-shft as logical no-undo init no.
/*использовать смены для данного объекта*/
DEFINE VARIABLE l-shift-on as logical no-undo init no.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
define variable v-obj-db-num as integer no-undo .
DEFINE VARIABLE v-can-back-shift AS LOGICAL NO-UNDO.

{ str/incwthtt.i "NEW SHARED" }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-07 RECT-03 RECT-02 RECT-05 B-exit ~
RECT-04 b-quit varshift-name varshift-num B-shift B-Help varshift-date T-02 ~
exter-inter-02 cli-type-02 cli-code-02 B-cli-02 w-p-code-02 B-place-02 T-03 ~
exter-inter-03 cli-type-03 cli-code-03 B-cli-03 w-p-code-03 B-place-03 T-04 ~
exter-inter-04 cli-type-04 cli-code-04 w-p-code-04 B-place-04 ~
exter-inter-05 T-05 cli-type-05 cli-code-05 B-cli-05 w-p-code-05 B-place-05 ~
exter-inter-07 T-07 cli-code-07 w-p-code-07 doc-type-02 cli-name-02 move-02 ~
w-p-name-02 doc-type-03 cli-name-03 move-03 w-p-name-03 doc-type-04 ~
cli-name-04 move-04 w-p-name-04 doc-type-05 cli-name-05 move-05 w-p-name-05 ~
doc-type-07 cli-name-07 move-07
&Scoped-Define DISPLAYED-OBJECTS varshift-name varshift-num varshift-date ~
T-02 exter-inter-02 cli-type-02 cli-code-02 w-p-code-02 T-03 exter-inter-03 ~
cli-type-03 cli-code-03 w-p-code-03 T-04 exter-inter-04 cli-type-04 ~
cli-code-04 w-p-code-04 exter-inter-05 T-05 cli-type-05 cli-code-05 ~
w-p-code-05 cli-type-07 cli-code-07 w-p-code-07 doc-type-02 cli-name-02 ~
move-02 w-p-name-02 doc-type-03 cli-name-03 move-03 w-p-name-03 doc-type-04 ~
cli-name-04 move-04 w-p-name-04 doc-type-05 cli-name-05 move-05 w-p-name-05 ~
cli-name-07 w-p-name-07

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli-02
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-cli-03
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-cli-04
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-cli-05
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-cli-07
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-place-02
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-place-03
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-place-04
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-place-05
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-place-07
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE VARIABLE cli-type-02 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type-03 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type-04 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type-05 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type-07 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code-02 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code-03 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code-04 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code-05 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code-07 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE cli-name-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.

DEFINE VARIABLE cli-name-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.

DEFINE VARIABLE cli-name-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.

DEFINE VARIABLE cli-name-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.

DEFINE VARIABLE cli-name-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.

DEFINE VARIABLE doc-type-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE doc-type-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE doc-type-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE doc-type-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE doc-type-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE move-02 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса ->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE move-03 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <-"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE move-04 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE move-05 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса ->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE move-07 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE varshift-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата учета (дата смены)"
     VIEW-AS FILL-IN
     SIZE 11.4 BY 1 NO-UNDO.

DEFINE VARIABLE varshift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.

DEFINE VARIABLE varshift-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "П"
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-code-02 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-code-03 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-code-04 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-code-05 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-code-07 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE w-p-name-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE w-p-name-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE w-p-name-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE w-p-name-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE w-p-name-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE exter-inter-02 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1,
"Внутриобъ", 2
     SIZE 13.1 BY 1.83 NO-UNDO.

DEFINE VARIABLE exter-inter-03 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внутриобъ", 2
     SIZE 13.1 BY 1 NO-UNDO.

DEFINE VARIABLE exter-inter-04 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1
     SIZE 13.1 BY 1 NO-UNDO.

DEFINE VARIABLE exter-inter-05 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1,
"Внутриобъ", 2
     SIZE 13.1 BY 1.83 NO-UNDO.

DEFINE VARIABLE exter-inter-07 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1
     SIZE 13.1 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-02
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.9 BY 3.5.

DEFINE RECTANGLE RECT-03
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.

DEFINE RECTANGLE RECT-04
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.

DEFINE RECTANGLE RECT-05
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.

DEFINE RECTANGLE RECT-07
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.

DEFINE VARIABLE T-02 AS LOGICAL INITIAL yes
     LABEL "Инкассация"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE T-03 AS LOGICAL INITIAL yes
     LABEL "Кассовый фонд"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE T-04 AS LOGICAL INITIAL yes
     LABEL "Перевод оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE T-05 AS LOGICAL INITIAL yes
     LABEL "Расход из кассы"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE T-07 AS LOGICAL INITIAL yes
     LABEL "Декл. ден.ящика"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     varshift-name AT ROW 1 COL 60.5 COLON-ALIGNED
     varshift-num AT ROW 1 COL 71 COLON-ALIGNED
     B-shift AT ROW 1 COL 80.5 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     varshift-date AT ROW 1.03 COL 45.1 COLON-ALIGNED
     T-02 AT ROW 4.47 COL 2.3
     exter-inter-02 AT ROW 4.47 COL 21.1 NO-LABEL
     cli-type-02 AT ROW 5.5 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-02 AT ROW 5.5 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-02 AT ROW 5.5 COL 64
     w-p-code-02 AT ROW 5.5 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-02 AT ROW 5.5 COL 91.3
     T-03 AT ROW 8.27 COL 2.3
     exter-inter-03 AT ROW 8.27 COL 21.1 NO-LABEL
     cli-type-03 AT ROW 9.27 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-03 AT ROW 9.27 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-03 AT ROW 9.27 COL 64
     w-p-code-03 AT ROW 9.27 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-03 AT ROW 9.27 COL 91.3
     T-04 AT ROW 12 COL 2.3
     exter-inter-04 AT ROW 12 COL 21.1 NO-LABEL
     cli-type-04 AT ROW 13 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-04 AT ROW 13 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-04 AT ROW 13 COL 64
     w-p-code-04 AT ROW 13 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-04 AT ROW 13 COL 91.3
     exter-inter-05 AT ROW 15.7 COL 21.1 NO-LABEL
     T-05 AT ROW 15.77 COL 2.3
     cli-type-05 AT ROW 16.77 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-05 AT ROW 16.77 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-05 AT ROW 16.77 COL 64
     w-p-code-05 AT ROW 16.77 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-05 AT ROW 16.77 COL 91.3
     exter-inter-07 AT ROW 19.2 COL 21.1 NO-LABEL
     T-07 AT ROW 19.27 COL 2.3
     cli-type-07 AT ROW 20.5 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-07 AT ROW 20.5 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-07 AT ROW 20.5 COL 64
     w-p-code-07 AT ROW 20.5 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-07 AT ROW 20.5 COL 91.3
     doc-type-02 AT ROW 4.47 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-02 AT ROW 4.47 COL 43 COLON-ALIGNED NO-LABEL
     move-02 AT ROW 4.47 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-02 AT ROW 4.47 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-03 AT ROW 8.27 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-03 AT ROW 8.27 COL 43 COLON-ALIGNED NO-LABEL
     move-03 AT ROW 8.27 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-03 AT ROW 8.27 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-04 AT ROW 12 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-04 AT ROW 12 COL 43 COLON-ALIGNED NO-LABEL
     move-04 AT ROW 12 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-04 AT ROW 12 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-05 AT ROW 15.7 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-05 AT ROW 15.7 COL 43 COLON-ALIGNED NO-LABEL
     move-05 AT ROW 15.7 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-05 AT ROW 15.7 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-07 AT ROW 19.27 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-07 AT ROW 19.3 COL 43 COLON-ALIGNED NO-LABEL
     move-07 AT ROW 19.33 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-07 AT ROW 19.33 COL 76.5 COLON-ALIGNED NO-LABEL
     "Контрагент" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.33 COL 46.6
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Тип документа МЦ" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.43 COL 22.5
          FGCOLOR 4
     "Направление перемещения" VIEW-AS TEXT
          SIZE 26.5 BY 1 AT ROW 2.27 COL 70.5
          FGCOLOR 4
     "Типы чеков" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.47 COL 1.8
          FGCOLOR 4
     RECT-07 AT ROW 18.5 COL 1.5
     RECT-03 AT ROW 7.47 COL 1.6
     RECT-02 AT ROW 3.7 COL 1.6
     RECT-05 AT ROW 14.97 COL 1.6
     RECT-04 AT ROW 11.2 COL 1.6
     SPACE(0.03) SKIP(7.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Формирование автоматических документов по чекам МЦ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf02_clients B "?" ? ub clients
      TABLE: buf02_wth-place B "?" ? ub wth-place
      TABLE: buf03_clients B "?" ? ub clients
      TABLE: buf03_wth-place B "?" ? ub wth-place
      TABLE: buf04_clients B "?" ? ub clients
      TABLE: buf04_wth-place B "?" ? ub wth-place
      TABLE: buf05_clients B "?" ? ub clients
      TABLE: buf05_wth-place B "?" ? ub wth-place
      TABLE: buf07_clients B "?" ? ub clients
      TABLE: buf07_wth-place B "?" ? ub wth-place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-cli-04 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-cli-07 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-cli-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-place-07 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-place-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX cli-type-07 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       cli-type-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN doc-type-07 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       doc-type-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR RADIO-SET exter-inter-07 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       exter-inter-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN move-07 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       move-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-07 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       T-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN w-p-name-07 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       w-p-name-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Формирование автоматических документов по чекам МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-02 Dialog-Frame
ON CHOOSE OF B-cli-02 IN FRAME Dialog-Frame
DO:
 define variable v_rid as character no-undo.
 define variable v-ref-rec as recid no-undo .
   FIND FIRST buf02_clients NO-LOCK WHERE
            buf02_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-02 AND
            buf02_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-02  NO-ERROR.
   IF available(buf02_clients) then do:
    run ref/cli-all.w ( INPUT parparentproc
                  , INPUT "b-sel":U
                  , (INPUT FRAME {&FRAME-NAME} cli-type-02)
                  , {&all}
                  , {&all}
                  , RECID( buf02_clients )
                  , ",,,,,,NO"
                  , ?
                  , OUTPUT v_rid ).


  END.
  ELSE DO:
    run ref/cli-all.w ( parparentproc
                  ,  INPUT "b-sel":U
                  , {&cmp}
                  , {&all}
                  , {&current}
                  , ?
                  , ",,,,,,NO"
                  , ?
                  , OUTPUT v_rid ).
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf02_clients NO-LOCK WHERE
               RECID( buf02_clients ) = v-ref-rec NO-ERROR.
    IF AVAIL buf02_clients THEN DO:
      if buf02_clients.obj-type = {&stock} or buf02_clients.obj-type = {&shop} then do:
        message "Неверно выбран контрагент"
        view-as alert-box error.
        return no-apply.
      end.
      ASSIGN
      cli-code-02 = buf02_clients.obj-code
      cli-type-02 = buf02_clients.obj-type
      cli-name-02 = buf02_clients.obj-name
      .
      DISPLAY
      cli-type-02
      cli-code-02
      cli-name-02
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.  /*v_rid <> ""*/
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-05 Dialog-Frame
ON CHOOSE OF B-cli-05 IN FRAME Dialog-Frame
DO:
  define variable v_rid as character no-undo.
  define variable v-ref-rec as recid no-undo .
   FIND FIRST buf05_clients NO-LOCK WHERE
            buf05_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-05 AND
            buf05_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-05  NO-ERROR.
   IF available(buf02_clients) then do:
    run ref/cli-all.w (parparentproc
                  , INPUT "b-sel":U
                  , (INPUT FRAME {&FRAME-NAME} cli-type-05)
                  , {&all}
                  , {&all}
                  , RECID( buf05_clients )
                  , ",,,,,,NO"
                  , ?
                    , OUTPUT v_rid ).
  END.
  ELSE DO:
    run ref/cli-all.w ( parparentproc
                  , INPUT "b-sel":U
                  , {&cmp}
                  , {&all}
                  , {&current}
                  , ?
                  , ",,,,,,NO"
                  , ?
                    , OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf05_clients NO-LOCK WHERE
               RECID( buf05_clients ) = v-ref-rec NO-ERROR.
    IF AVAIL buf05_clients THEN DO:
      if buf05_clients.obj-type = {&stock} or buf05_clients.obj-type = {&shop} then do:
        message "Неверно выбран контрагент"
        view-as alert-box error.
        return no-apply.
      end.
      ASSIGN
      cli-code-05 = buf05_clients.obj-code
      cli-type-05 = buf05_clients.obj-type
      cli-name-05 = buf05_clients.obj-name
      .
      DISPLAY
      cli-type-05
      cli-code-05
      cli-name-05
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.  /*v_rid <> ""*/
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable v-parameter as character no-undo .
  { gbl/stdbtn.i }
  run assign-fields in this-procedure no-error.
  if error-status:error then return no-apply.
  run check-fields in this-procedure no-error.
  if error-status:error then return no-apply.
  assign
  v-parameter = string(parhost-code) + {&delim-par} +
                 parobj-type + {&delim-par} +
                 string(parobj-code) + {&delim-par} +
                 string(0) /*p-auto*/
  .
  run str/diallog.w (
        input parParentProc
      , input this-procedure
      , input ("str/inc-wthr.p":U + {&delim-par} +
              "1":U  + {&delim-par} +  /*error-message-option*/
              "1":U + {&delim-par} +  /*auto-go-option*/
              "1":U)                  /*return-value-option*/
      , input v-parameter
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Формирование и обработка документов МЦ &2&3", parobj-type, parobj-code)
  ) no-error.
  if error-status:error
  and return-value <> "error"
  then do:
    message
    substitute("&1 &2"
              , error-status:get-message(1)
              , return-value )
    view-as alert-box error .
    return no-apply. .
  end.
  if return-value = "error":U then do:
    return no-apply. .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-place-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-place-02 Dialog-Frame
ON CHOOSE OF B-place-02 IN FRAME Dialog-Frame
DO:
   define variable was_found  AS LOG  NO-UNDO.
   define variable v_rid as character no-undo.
   define variable v-ref-rec as recid no-undo .

  IF cli-type-02 = {&shop} THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-02   AND
         ub.clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-02 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME {&FRAME-NAME} cli-code-02  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.

  FIND buf02_wth-place NO-LOCK WHERE
                    buf02_wth-place.host-code = parhost-code               AND
                    buf02_wth-place.obj-type    = cli-type-02  AND
                    buf02_wth-place.obj-code    = cli-code-02  AND
                    buf02_wth-place.w-p-code    = INPUT FRAME {&FRAME-NAME} w-p-code-02 NO-ERROR.
  IF AVAIL buf02_wth-place THEN DO:
        ASSIGN
        v_rid = string(RECID( buf02_wth-place ))
        .
  END.
  ASSIGN .
  run ref/wthplref.w (
                     input parparentproc
                    ,INPUT "b-sel":U
                    ,INPUT parhost-code
                    ,INPUT cli-type-02
                    ,INPUT cli-code-02
                    ,input {&g___object}
                    ,input-OUTPUT v_rid ).

  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf02_wth-place NO-LOCK WHERE
            RECID( buf02_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf02_wth-place THEN DO:
      DISPLAY
      buf02_wth-place.w-p-code @ w-p-code-02
      buf02_wth-place.w-p-name @ w-p-name-02
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-place-03
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-place-03 Dialog-Frame
ON CHOOSE OF B-place-03 IN FRAME Dialog-Frame
DO:
  define variable was_found  AS LOG  NO-UNDO.
 define variable v_rid as character no-undo.
 define variable v-ref-rec as recid no-undo .

  IF cli-type-03 = {&shop} THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-03   AND
         ub.clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-03 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME {&FRAME-NAME} cli-code-03  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.

  FIND buf03_wth-place NO-LOCK WHERE
                    buf03_wth-place.host-code = parhost-code               AND
                    buf03_wth-place.obj-type    = cli-type-03  AND
                    buf03_wth-place.obj-code    = cli-code-03  AND
                    buf03_wth-place.w-p-code    = INPUT FRAME {&FRAME-NAME} w-p-code-03 NO-ERROR.
  IF AVAIL buf03_wth-place THEN DO:
        ASSIGN v_rid = string(RECID( buf03_wth-place )).
  END.

  run ref/wthplref.w (
                    input parparentproc
                   ,INPUT "b-sel":U
                   ,INPUT parhost-code
                   ,INPUT cli-type-03
                   ,INPUT cli-code-03
                   ,input {&g___object}
                   ,input-OUTPUT v_rid ).

  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf03_wth-place NO-LOCK WHERE
            RECID( buf03_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf03_wth-place THEN DO:
      DISPLAY
      buf03_wth-place.w-p-code @ w-p-code-03
      buf03_wth-place.w-p-name @ w-p-name-03
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-place-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-place-05 Dialog-Frame
ON CHOOSE OF B-place-05 IN FRAME Dialog-Frame
DO:
   define variable was_found  AS LOG  NO-UNDO.
   define variable v_rid as character no-undo.
   define variable v-ref-rec as recid no-undo .

  IF cli-type-05 = {&shop} THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-05   AND
         ub.clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-05 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME {&FRAME-NAME} cli-code-05  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.

  FIND buf05_wth-place NO-LOCK WHERE
                    buf05_wth-place.host-code = parhost-code               AND
                    buf05_wth-place.obj-type    = cli-type-05  AND
                    buf05_wth-place.obj-code    = cli-code-05  AND
                    buf05_wth-place.w-p-code    = INPUT FRAME {&FRAME-NAME} w-p-code-05 NO-ERROR.
  IF AVAIL buf05_wth-place THEN DO:
        ASSIGN v_rid = string(RECID( buf05_wth-place )).
  END.

  run ref/wthplref.w (
                    input parparentproc
                   ,INPUT "b-sel":U
                   ,INPUT parhost-code
                   ,INPUT cli-type-05
                   ,INPUT cli-code-05
                   ,input {&g___object}
                  ,input-OUTPUT v_rid ).
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf05_wth-place NO-LOCK WHERE
            RECID( buf05_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf05_wth-place THEN DO:
      DISPLAY
      buf05_wth-place.w-p-code @ w-p-code-05
      buf05_wth-place.w-p-name @ w-p-name-05
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shift Dialog-Frame
ON CHOOSE OF B-shift IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj.

run str/sht-all.w (
            input parparentproc
          , INPUT parobj-type /*p-curr-obj-type*/
          , input parobj-code /*p-curr-obj-code*/
          , input 'b-sel'
          , input 'obj'
          , INPUT parobj-type /*p-curr-obj-type*/
          , input parobj-code /*p-curr-obj-code*/
          , input '':u
          , input-output v-rid-list) no-error.
if v-rid-list = '':U then do:
  return no-apply.
end.
find first buf_shift-obj no-lock where
        recid(buf_shift-obj) = integer(v-rid-list) .
if not (buf_shift-obj.obj-type = parobj-type
        and
        buf_shift-obj.obj-code = parobj-code
        )
or not (buf_shift-obj.status_ = {&sht-closed}
       or
       buf_shift-obj.status_ = {&sht-current}) then do:
  message
  substitute("Вы должны Выбрать ЗАКРЫТУЮ или ТЕКУЩУЮ смену по &1&2"
            , parobj-type
            , parobj-code)
  view-as alert-box error .
  return no-apply.
end.
assign
varshift-name = buf_shift-obj.shift-name
varshift-num = buf_shift-obj.shift-num
varshift-date = buf_shift-obj.shift-date
.
display
varshift-name
varshift-num
varshift-date
with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-02 Dialog-Frame
ON LEAVE OF cli-code-02 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-02 in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-02 Dialog-Frame
ON RETURN OF cli-code-02 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-02 in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-05 Dialog-Frame
ON LEAVE OF cli-code-05 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-05 in this-procedure no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-05 Dialog-Frame
ON RETURN OF cli-code-05 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-05 in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type-02 Dialog-Frame
ON VALUE-CHANGED OF cli-type-02 IN FRAME Dialog-Frame
DO:
   FIND FIRST buf02_clients NO-LOCK WHERE
          buf02_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-02 AND
          buf02_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-02 NO-ERROR.
IF AVAIL buf02_clients THEN DO:
    DISPLAY
    buf02_clients.obj-name @ cli-name-02 WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type-05 Dialog-Frame
ON VALUE-CHANGED OF cli-type-05 IN FRAME Dialog-Frame
DO:
     FIND FIRST buf05_clients NO-LOCK WHERE
          buf05_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-05 AND
          buf05_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-05 NO-ERROR.
IF AVAIL buf05_clients THEN DO:
    DISPLAY
    buf05_clients.obj-name @ cli-name-05 WITH FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exter-inter-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exter-inter-02 Dialog-Frame
ON VALUE-CHANGED OF exter-inter-02 IN FRAME Dialog-Frame
DO:
  assign exter-inter-02.
   run proc-inter-02 in this-procedure(exter-inter-02) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exter-inter-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exter-inter-05 Dialog-Frame
ON VALUE-CHANGED OF exter-inter-05 IN FRAME Dialog-Frame
DO:
   assign exter-inter-05.
   run proc-inter-05 in this-procedure(exter-inter-05) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-p-code-02
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-p-code-02 Dialog-Frame
ON LEAVE OF w-p-code-02 IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
   run proc-w-p-code-02 in this-procedure no-error.
   if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-p-code-02 Dialog-Frame
ON RETURN OF w-p-code-02 IN FRAME Dialog-Frame
DO:
   run proc-w-p-code-02 in this-procedure no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-p-code-05
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-p-code-05 Dialog-Frame
ON LEAVE OF w-p-code-05 IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
   run proc-w-p-code-05 in this-procedure no-error.
   if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-p-code-05 Dialog-Frame
ON RETURN OF w-p-code-05 IN FRAME Dialog-Frame
DO:
   run proc-w-p-code-05 in this-procedure no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME w-p-code-07
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-p-code-07 Dialog-Frame
ON LEAVE OF w-p-code-07 IN FRAME Dialog-Frame
DO:
    run proc-w-p-code-07 in this-procedure no-error.
  if error-status:error then return no-apply.

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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if parobj-type  <> {&shop} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-type" parobj-type
    view-as alert-box.
    return error.
    end.
    find first ub.sysconf No-LOCK WHERE
                ub.sysconf.host-code = parhost-code No-error.
  if not available ub.sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parhost-code" parhost-code
    view-as alert-box.
    return error.
  end.
  find first ub.shop No-LOCK WHERE
                 ub.shop.obj-code = parobj-code No-ERROR.
  if not available ub.shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-code" parobj-code
    view-as alert-box.
    return error.
  end.
  { gbl/objdbnum.i {&shop} ub.shop.obj-code v-obj-db-num }
  if v-obj-db-num <> v-cntxt-db-num then do:
    message
    substitute("Нельзя вызывать Формирование автоматических документов МЦ на основе МЦ чеков на чужой БД&1"  +
               "БД объекта &2, текущая БД &3"
               , {&new-line}
               , v-obj-db-num
               , v-cntxt-db-num)
    view-as alert-box .
  end.
  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-fields Dialog-Frame
PROCEDURE assign-fields :
assign
varshift-date
varshift-num
varshift-name
frame {&frame-name} T-02
frame {&frame-name} T-03
frame {&frame-name} T-04
frame {&frame-name} T-05
frame {&frame-name} T-07
exter-inter-02
exter-inter-03
exter-inter-04
exter-inter-05
exter-inter-07
cli-code-02 cli-code-03 cli-code-04 cli-code-05 cli-code-07
cli-type-02 cli-type-03 cli-type-04 cli-type-05 cli-code-07
w-p-code-02 w-p-code-03 w-p-code-04 w-p-code-05 w-p-code-07
.
for each temp-cre-doc:
    delete temp-cre-doc.
end.
if t-02 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 2
    temp-cre-doc.inter_ = (exter-inter-02 = 2)
    temp-cre-doc.exter_ = (exter-inter-02 = 1)
    temp-cre-doc.doc-type = doc-type-02
    temp-cre-doc.ext-doc-type = if  temp-cre-doc.inter_ then {&WDEDT_Exp_Obj} else {&wdedt_exp_ext}
    temp-cre-doc.cli-type = cli-type-02
    temp-cre-doc.cli-code= cli-code-02
    temp-cre-doc.out-w-p-code = (if temp-cre-doc.inter_ then w-p-code-02 else 0)
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num  = varshift-num
    temp-cre-doc.shift-name = varshift-name
    .

end.
if t-03 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 3
    temp-cre-doc.inter_ = (exter-inter-03 = 2)
    temp-cre-doc.exter_ = (exter-inter-03 = 1)
    temp-cre-doc.doc-type = doc-type-03
    temp-cre-doc.cli-type = cli-type-03
    temp-cre-doc.cli-code= cli-code-03
    temp-cre-doc.out-w-p-code = w-p-code-03
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type = {&WDEDT_Inc_Obj}.
end.
if t-04 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 4
    temp-cre-doc.inter_ = (exter-inter-04 = 2)
    temp-cre-doc.exter_ = (exter-inter-04 = 1)
    temp-cre-doc.doc-type = doc-type-04
    temp-cre-doc.cli-type = cli-type-04
    temp-cre-doc.cli-code= cli-code-04
    temp-cre-doc.out-w-p-code = w-p-code-04
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type = {&wdedt_inv}
     .
end.

if t-05 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 5
    temp-cre-doc.inter_ = (exter-inter-05 = 2)
    temp-cre-doc.exter_ = (exter-inter-05 = 1)
    temp-cre-doc.doc-type = doc-type-05
    temp-cre-doc.cli-type = cli-type-05
    temp-cre-doc.cli-code= cli-code-05
    temp-cre-doc.out-w-p-code = (if temp-cre-doc.inter_ then w-p-code-05 else 0)
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type =  if  temp-cre-doc.inter_ then {&WDEDT_Exp_Obj} else {&wdedt_exp_ext}
    .
end.
if t-07 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 7
    temp-cre-doc.inter_ = (exter-inter-07 = 2)
    temp-cre-doc.exter_ = (exter-inter-07 = 1)
    temp-cre-doc.doc-type = doc-type-07
    temp-cre-doc.cli-type = cli-type-07
    temp-cre-doc.cli-code= cli-code-07
    temp-cre-doc.out-w-p-code = w-p-code-07
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.ext-doc-type = {&wdedt_dec}
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-fields Dialog-Frame
PROCEDURE check-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
&scop wth-receipt-code trim(string(temp-cre-doc.chk-type))
define variable dops as character no-undo.

define buffer check_clients for ub.clients.
define buffer check_wth-place for ub.wth-place.

run gbl/chk-date.p (
                  INPUT parobj-type
                 ,INPUT parobj-code
                 ,INPUT varshift-date
                 ,INPUT time
                 ,INPUT varshift-date
                 ,INPUT varshift-num,
                 yes
                   ) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
   return error.
 END.

for each temp-cre-doc:
    dops = '':U.
    assign dops = {&wth-receipt-name} no-error.
    find first check_clients No-LOCK WHERE
                 check_clients.obj-type = temp-cre-doc.cli-type AND
                 check_clients.obj-code = temp-cre-doc.cli-code No-ERROR.
    if not avail check_clients or
       (temp-cre-doc.inter_ = yes and
         NOT(temp-cre-doc.cli-type = parobj-type AND
                 temp-cre-doc.cli-code = parobj-code)
       ) or
       (
        temp-cre-doc.exter_ = yes and
         (temp-cre-doc.cli-type = {&shop} or temp-cre-doc.cli-type = {&stock})
       )
       or (temp-cre-doc.doc-type = {&inventory} AND
           NOT ( temp-cre-doc.cli-type = {&cmp} and
                temp-cre-doc.cli-code = parhost-code)
          )
       then do:
       message
       "Неверный контрагент для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.

    end.
    if temp-cre-doc.inter_ = temp-cre-doc.exter_ then do:
      message
       "Неверный тип документа для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.
    end.
    if temp-cre-doc.inter_ then do:
        FIND FIRST check_wth-place No-LOCK WHERE
                          check_wth-place.obj-type = parobj-type AND
                          check_wth-place.obj-code = parobj-code AND
                          check_wth-place.w-p-code = temp-cre-doc.out-w-p-code No-ERROR.
        if not available check_wth-place then do:
      message
       "Неверный код МХ МЦ назначения для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.

        end.
    end.
end.


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
  DISPLAY varshift-name varshift-num varshift-date T-02 exter-inter-02
          cli-type-02 cli-code-02 w-p-code-02 T-03 exter-inter-03 cli-type-03
          cli-code-03 w-p-code-03 T-04 exter-inter-04 cli-type-04 cli-code-04
          w-p-code-04 exter-inter-05 T-05 cli-type-05 cli-code-05 w-p-code-05
          cli-type-07 cli-code-07 w-p-code-07 doc-type-02 cli-name-02 move-02
          w-p-name-02 doc-type-03 cli-name-03 move-03 w-p-name-03 doc-type-04
          cli-name-04 move-04 w-p-name-04 doc-type-05 cli-name-05 move-05
          w-p-name-05 cli-name-07 w-p-name-07
      WITH FRAME Dialog-Frame.
  ENABLE RECT-07 RECT-03 RECT-02 RECT-05 B-exit RECT-04 b-quit varshift-name
         varshift-num B-shift B-Help varshift-date T-02 exter-inter-02
         cli-type-02 cli-code-02 B-cli-02 w-p-code-02 B-place-02 T-03
         exter-inter-03 cli-type-03 cli-code-03 B-cli-03 w-p-code-03 B-place-03
         T-04 exter-inter-04 cli-type-04 cli-code-04 w-p-code-04 B-place-04
         exter-inter-05 T-05 cli-type-05 cli-code-05 B-cli-05 w-p-code-05
         B-place-05 exter-inter-07 T-07 cli-code-07 w-p-code-07 doc-type-02
         cli-name-02 move-02 w-p-name-02 doc-type-03 cli-name-03 move-03
         w-p-name-03 doc-type-04 cli-name-04 move-04 w-p-name-04 doc-type-05
         cli-name-05 move-05 w-p-name-05 doc-type-07 cli-name-07 move-07
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i parobj-type parobj-code  cas-shft }
{ gbl/objat.i
  parobj-type
  parobj-code
  "'shift-on=request'"
  l-shift-on
}

if l-shift-on and not cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.
if l-shift-on then do:
 { gbl/hostcode.i parobj-type parobj-code v-host-code }
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_wth-doc_create-back-shift':U
  {&cntxt-object}
  v-host-code
  parobj-type
  parobj-code
  0
  0
  0
  false
  v-can-back-shift
}
end.
run gbl/factdate.p (
                 INPUT        parobj-type,
                 INPUT        parobj-code,
                 INPUT-OUTPUT f-date,
                 INPUT-OUTPUT f-time,
                 INPUT-OUTPUT s-date,
                 INPUT-OUTPUT s-num,
                 INPUT-OUTPUT s-name,
                 INPUT        YES
                   ) NO-ERROR.
 IF ERROR-STATUS:ERROR
 and not v-can-back-shift THEN DO:
   return error.
 END.
/*найдем настройки по умолчанию*/
/*контрагенты*/
FIND FIRST buf02_clients No-LOCK WHERE
                 buf02_clients.obj-type = parobj-type and
                 buf02_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf03_clients No-LOCK WHERE
                 buf03_clients.obj-type = parobj-type and
                 buf03_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf04_clients No-LOCK WHERE
                 buf04_clients.obj-type = {&cmp} and
                 buf04_clients.obj-code = parhost-code No-ERROR.
FIND FIRST buf05_clients No-LOCK WHERE
                 buf05_clients.obj-type = parobj-type and
                 buf05_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf07_clients No-LOCK WHERE
                 buf07_clients.obj-type = {&cmp} and
                 buf07_clients.obj-code = parhost-code No-ERROR.
/*МХ*/
FIND FIRST buf02_wth-place No-LOCK WHERE
                  buf02_wth-place.obj-type = parobj-type AND
                  buf02_wth-place.obj-code = parobj-code AND
                  buf02_wth-place.main-cash-desk = yes No-ERROR.
FIND FIRST buf03_wth-place No-LOCK WHERE
                  buf03_wth-place.obj-type = parobj-type AND
                  buf03_wth-place.obj-code = parobj-code AND
                  buf03_wth-place.main-cash-desk = yes No-ERROR.
FIND FIRST buf05_wth-place No-LOCK WHERE
                  buf05_wth-place.obj-type = parobj-type AND
                  buf05_wth-place.obj-code = parobj-code AND
                  buf05_wth-place.main-cash-desk = yes No-ERROR.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
exter-inter-02 = 2
exter-inter-03 = 2
exter-inter-04 = 1
exter-inter-05 = 2
exter-inter-07 = 1
doc-type-02 = {&expense}
doc-type-03 = {&income}
doc-type-04 = {&inventory}
doc-type-05 = {&expense}
doc-type-07 = {&declaration}
cli-type-02:list-items in frame {&frame-name} = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char}  +
                                                                        {&shop} + {&comma-char}
cli-type-03:list-items =  {&shop} + {&comma-char}
cli-type-04:list-items = {&cmp} + {&comma-char}
cli-type-05:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char}   +
                                                                        {&shop} + {&comma-char}
cli-type-07:list-items = {&cmp} + {&comma-char}
.
assign
varshift-date = (if s-date = ? then f-date else s-date)
varshift-num = s-num
varshift-name = s-name
.
if available buf02_clients then
assign
cli-type-02 = buf02_clients.obj-type
cli-code-02 = buf02_clients.obj-code
cli-name-02 = buf02_clients.obj-name
.
if available buf03_clients then
assign
cli-type-03 = buf03_clients.obj-type
cli-code-03 = buf03_clients.obj-code
cli-name-03 = buf03_clients.obj-name
.
if available buf04_clients then
assign
cli-type-04 = buf04_clients.obj-type
cli-code-04 = buf04_clients.obj-code
cli-name-04 = buf04_clients.obj-name
.

if available buf05_clients then
assign
cli-type-05 = buf05_clients.obj-type
cli-code-05 = buf05_clients.obj-code
cli-name-05 = buf05_clients.obj-name
.
if available buf07_clients then
assign
cli-type-07 = buf07_clients.obj-type
cli-code-07 = buf07_clients.obj-code
cli-name-07 = buf07_clients.obj-name
.
/***/
if available buf02_wth-place then
assign
w-p-code-02 = buf02_wth-place.w-p-code
w-p-name-02 = buf02_wth-place.w-p-name
.

if available buf03_wth-place then
assign
w-p-code-03 = buf03_wth-place.w-p-code
w-p-name-03 = buf03_wth-place.w-p-name
.

if available buf04_wth-place then
assign
w-p-code-04 = buf04_wth-place.w-p-code
w-p-name-04 = buf04_wth-place.w-p-name
.

if available buf05_wth-place then
assign
w-p-code-05 = buf05_wth-place.w-p-code
w-p-name-05 = buf05_wth-place.w-p-name
.

if available buf07_wth-place then
assign
w-p-code-07 = buf07_wth-place.w-p-code
w-p-name-07 = buf07_wth-place.w-p-name
.




DISPLAY
varshift-date
varshift-num
T-02 exter-inter-02 cli-type-02 cli-code-02 cli-name-02 w-p-code-02 doc-type-02 w-p-name-02 move-02
T-03 exter-inter-03  cli-type-03  cli-code-03 cli-name-03 w-p-code-03 doc-type-03 w-p-name-03 move-03
T-04 exter-inter-04  cli-type-04  cli-code-04 cli-name-04  doc-type-04  move-04
T-05 exter-inter-05  cli-type-05  cli-code-05 cli-name-05 w-p-code-05 doc-type-05 w-p-name-05 move-05
T-07 exter-inter-07  cli-type-07  cli-code-07 cli-name-07 doc-type-07 move-07
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
varshift-date when not l-shift-on
varshift-num when cas-shft
T-02 exter-inter-02 cli-type-02 cli-code-02 B-cli-02 w-p-code-02 B-place-02 doc-type-02
T-03 exter-inter-03                 w-p-code-03     B-place-03                 doc-type-03
T-04 exter-inter-04                                         doc-type-04
T-05 exter-inter-05  cli-type-05 cli-code-05 b-cli-05 w-p-code-05 B-place-05 doc-type-05
T-07 exter-inter-07  doc-type-07
b-shift WHEN (l-shift-on AND v-can-back-shift)
WITH FRAME {&frame-name} .
IF NOT (l-shift-on AND v-can-back-shift) THEN DO:
  HIDE
  b-shift IN FRAME {&FRAME-NAME}.
END.
HIDE
b-cli-03
b-cli-04
b-cli-07
b-place-04
b-place-07
in frame {&frame-name}.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED" to exter-inter-02 in frame {&frame-name}.
APPLY "VALUE-CHANGED" to exter-inter-05 in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cli-code-02 Dialog-Frame 
PROCEDURE proc-cli-code-02 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
      FIND FIRST buf02_clients NO-LOCK WHERE
                buf02_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-02 AND
                buf02_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-02 NO-ERROR.
  IF AVAIL buf02_clients THEN DO:
    CASE buf02_clients.obj-type:
      when {&shop} then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf02_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-02 in frame {&frame-name}.
          return error.
        end.
      end.
      when {&stock} then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf02_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-02 in frame {&frame-name}.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf02_clients.obj-name @ cli-name-02 WITH FRAME {&FRAME-NAME}.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cli-code-05 Dialog-Frame 
PROCEDURE proc-cli-code-05 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
      FIND FIRST buf05_clients NO-LOCK WHERE
                buf05_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-05 AND
                buf05_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-05 NO-ERROR.
  IF AVAIL buf05_clients THEN DO:
    CASE buf05_clients.obj-type:
      when {&shop} then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf05_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-05 in frame {&frame-name}.
          return error.
        end.
      end.
      when {&stock} then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf05_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-05 in frame {&frame-name}.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf05_clients.obj-name @ cli-name-05 WITH FRAME {&FRAME-NAME}.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cli-code-07 Dialog-Frame 
PROCEDURE proc-cli-code-07 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
      FIND FIRST buf07_clients NO-LOCK WHERE
                buf07_clients.obj-type = INPUT FRAME {&FRAME-NAME} cli-type-07 AND
                buf07_clients.obj-code = INPUT FRAME {&FRAME-NAME} cli-code-07 NO-ERROR.
  IF AVAIL buf07_clients THEN DO:
    CASE buf07_clients.obj-type:
      when {&shop} then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf07_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-07 in frame {&frame-name}.
          return error.
        end.
      end.
      when {&stock} then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf07_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-07 in frame {&frame-name}.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf07_clients.obj-name @ cli-name-07 WITH FRAME {&FRAME-NAME}.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-inter-02 Dialog-Frame 
PROCEDURE proc-inter-02 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter loc-inter as integer no-undo.
/*1- внешний*/
/*2- внутриобъектный*/
CASE loc-inter :
    when 2 then do:
        cli-type-02:list-items in frame {&frame-name} = {&shop} + {&comma-char}.
        assign
        cli-type-02 = parobj-type
        cli-code-02 = parobj-code
        .
        display
        cli-type-02
        cli-code-02
        with frame {&frame-name}.
        disable
        cli-type-02
        cli-code-02
        b-cli-02
        with frame {&frame-name}.
        enable
        b-place-02
        w-p-code-02
        with frame {&frame-name}.
        APPLY "VALUE-CHANGED" to cli-type-02.
        APPLY "LEAVE" to w-p-code-02 in frame {&frame-name}.
    end.
    when 1 then do:
        cli-type-02:list-items in frame {&frame-name} = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char}  .

        assign
        cli-type-02 = {&cmp}
        cli-code-02 = 0
        .
        display
        cli-type-02
        cli-code-02
        '':U @ cli-name-02
        with frame {&frame-name}.
        ENABLE
        cli-type-02
        cli-code-02
        b-cli-02
        with frame {&frame-name}.
        hide
        w-p-code-02
        b-place-02
        w-p-name-02
        in frame {&frame-name}.
    end.
    END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-inter-05 Dialog-Frame 
PROCEDURE proc-inter-05 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter loc-inter as integer no-undo.
/*1- внешний*/
/*2- внутриобъектный*/
CASE loc-inter :
    when 2 then do:
            cli-type-05:list-items in frame {&frame-name} = {&shop} + {&comma-char}.
        assign
        cli-type-05 = parobj-type
        cli-code-05 = parobj-code
        .
        display
        cli-type-05
        cli-code-05
        with frame {&frame-name}.
        disable
        cli-type-05
        cli-code-05
        b-cli-05
        with frame {&frame-name}.
        enable
        b-place-05
        w-p-code-05
        with frame {&frame-name}.
        APPLY "VALUE-CHANGED" to cli-type-05.
            APPLY "LEAVE" to w-p-code-02 in frame {&frame-name}.
    end.
    when 1 then do:
            cli-type-05:list-items in frame {&frame-name} = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char}  .
        assign
        cli-type-05 = {&cmp}
        cli-code-05 = 0
        .
        display
        cli-type-05
        cli-code-05
        '':U @ cli-name-05
        with frame {&frame-name}.
        ENABLE
        cli-type-05
        cli-code-05
        b-cli-05
        with frame {&frame-name}.
        hide
        w-p-code-05
        b-place-05
        w-p-name-05
        in frame {&frame-name}.
    end.
    END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-w-p-code-02 Dialog-Frame 
PROCEDURE proc-w-p-code-02 :
IF INPUT FRAME {&FRAME-NAME} T-02 = YES  THEN DO:
  FIND FIRST buf02_wth-place NO-LOCK WHERE
            buf02_wth-place.obj-type = buf02_clients.obj-type      AND
            buf02_wth-place.obj-code = buf02_clients.obj-code      AND
            buf02_wth-place.w-p-code = INPUT FRAME {&FRAME-NAME} w-p-code-02 NO-ERROR.
  IF AVAIL buf02_wth-place THEN DO:
    DISPLAY
    buf02_wth-place.w-p-name @ w-p-name-02
    WITH FRAME {&FRAME-NAME}.
  END.
  else return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-w-p-code-05 Dialog-Frame 
PROCEDURE proc-w-p-code-05 :
IF INPUT FRAME {&FRAME-NAME} T-05 = YES  THEN DO:
  FIND FIRST buf05_wth-place NO-LOCK WHERE
            buf05_wth-place.obj-type = buf05_clients.obj-type      AND
            buf05_wth-place.obj-code = buf05_clients.obj-code      AND
            buf05_wth-place.w-p-code = INPUT FRAME {&FRAME-NAME} w-p-code-05 NO-ERROR.
  IF AVAIL buf05_wth-place THEN DO:
    DISPLAY
    buf05_wth-place.w-p-name @ w-p-name-05
    WITH FRAME {&FRAME-NAME}.
  END.
  else return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-w-p-code-07 Dialog-Frame 
PROCEDURE proc-w-p-code-07 :
IF INPUT FRAME {&FRAME-NAME} T-07 = YES  THEN DO:
  FIND FIRST buf07_wth-place NO-LOCK WHERE
            buf07_wth-place.obj-type = buf07_clients.obj-type      AND
            buf07_wth-place.obj-code = buf07_clients.obj-code      AND
            buf07_wth-place.w-p-code = INPUT FRAME {&FRAME-NAME} w-p-code-07 NO-ERROR.
  IF AVAIL buf07_wth-place THEN DO:
    DISPLAY
    buf07_wth-place.w-p-name @ w-p-name-07
    WITH FRAME {&FRAME-NAME}.
  END.
  else return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

