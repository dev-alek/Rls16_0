&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-tot_ FOR ub.dis-host.
DEFINE BUFFER X_dis-tot_host FOR ub.dis-host.
DEFINE BUFFER X_dis-tot_obj FOR ub.dis-obj.
DEFINE BUFFER X_prop-ref_ FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_host FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref_obj FOR ub.prop-ref.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список dis-obj


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-curr-host-code as integer no-undo .
define input parameter p-curr-obj-type as character no-undo .
define input parameter p-curr-obj-code as integer no-undo .
define input parameter p-list-mode as character no-undo .
/*{&all} dtm-code dt-code */
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define input parameter p-dtm-code as integer no-undo .
define input parameter p-dt-code as integer no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список dis-obj".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-list-mode as character no-undo .
define variable filter-point-label as character no-undo init "Итоги по ДК" .
define variable filter-point0 as character no-undo init "dis-tots" .
define variable filter-point as character no-undo init "dis-tots" .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-tot_

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-tot_ X_prop-ref_ X_dis-tot_host ~
X_prop-ref_host X_dis-tot_obj X_prop-ref_obj

/* Definitions for BROWSE br-dis-tot_                                   */
&Scoped-define FIELDS-IN-QUERY-br-dis-tot_ mark-string(recid(X_dis-tot_), v-rid-list) X_prop-ref_.sum-id X_prop-ref_.caller_id X_prop-ref_.dtm-code X_dis-tot_.d-card X_dis-tot_.gds-tot-rubl X_dis-tot_.gds-dis-rubl X_dis-tot_.pay-tot-rubl X_dis-tot_.gds-tot-base X_dis-tot_.gds-dis-base X_dis-tot_.pay-tot-base X_dis-tot_.num-chk
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-tot_
&Scoped-define SELF-NAME br-dis-tot_
&Scoped-define QUERY-STRING-br-dis-tot_ FOR EACH X_dis-tot_ NO-LOCK, ~
           FIRST X_prop-ref_ NO-LOCK WHERE          X_prop-ref_.dt-code = X_dis-tot_.dt-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-tot_ OPEN QUERY br-dis-tot_ FOR EACH X_dis-tot_ NO-LOCK, ~
           FIRST X_prop-ref_ NO-LOCK WHERE          X_prop-ref_.dt-code = X_dis-tot_.dt-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-tot_ X_dis-tot_ X_prop-ref_
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-tot_ X_dis-tot_
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-tot_ X_prop-ref_


/* Definitions for BROWSE br-dis-tot_host                               */
&Scoped-define FIELDS-IN-QUERY-br-dis-tot_host mark-string(recid(X_dis-tot_host), v-rid-list) X_prop-ref_host.sum-id X_prop-ref_host.caller_id X_prop-ref_host.dtm-code X_dis-tot_host.d-card X_dis-tot_host.host-code X_dis-tot_host.gds-tot-rubl X_dis-tot_host.gds-dis-rubl X_dis-tot_host.pay-tot-rubl X_dis-tot_host.gds-tot-base X_dis-tot_host.gds-dis-base X_dis-tot_host.pay-tot-base X_dis-tot_host.num-chk
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-tot_host
&Scoped-define SELF-NAME br-dis-tot_host
&Scoped-define QUERY-STRING-br-dis-tot_host FOR EACH X_dis-tot_host NO-LOCK, ~
           FIRST X_prop-ref_host NO-LOCK WHERE          X_prop-ref_host.dt-code = X_dis-tot_host.dt-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-tot_host OPEN QUERY br-dis-tot_host FOR EACH X_dis-tot_host NO-LOCK, ~
           FIRST X_prop-ref_host NO-LOCK WHERE          X_prop-ref_host.dt-code = X_dis-tot_host.dt-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-tot_host X_dis-tot_host ~
X_prop-ref_host
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-tot_host X_dis-tot_host
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-tot_host X_prop-ref_host


/* Definitions for BROWSE br-dis-tot_obj                                */
&Scoped-define FIELDS-IN-QUERY-br-dis-tot_obj mark-string(recid(X_dis-tot_obj), v-rid-list) X_prop-ref_obj.sum-id X_prop-ref_obj.caller_id X_prop-ref_obj.dtm-code X_dis-tot_obj.d-card X_dis-tot_obj.obj-code X_dis-tot_obj.obj-type X_dis-tot_obj.gds-tot-rubl X_dis-tot_obj.gds-dis-rubl X_dis-tot_obj.pay-tot-rubl X_dis-tot_obj.gds-tot-base X_dis-tot_obj.gds-dis-base X_dis-tot_obj.pay-tot-base X_dis-tot_obj.num-chk
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-tot_obj
&Scoped-define SELF-NAME br-dis-tot_obj
&Scoped-define QUERY-STRING-br-dis-tot_obj FOR EACH X_dis-tot_obj NO-LOCK, ~
           FIRST X_prop-ref_obj NO-LOCK WHERE          X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-tot_obj OPEN QUERY br-dis-tot_obj FOR EACH X_dis-tot_obj NO-LOCK, ~
           FIRST X_prop-ref_obj NO-LOCK WHERE          X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-tot_obj X_dis-tot_obj X_prop-ref_obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-tot_obj X_dis-tot_obj
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-tot_obj X_prop-ref_obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-tot_}~
    ~{&OPEN-QUERY-br-dis-tot_host}~
    ~{&OPEN-QUERY-br-dis-tot_obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel rs-region b-lkp b-card ~
b-sch B-print b-history B-Help b-dtm-code b-dt-code rs-curr br-dis-tot_obj ~
br-dis-tot_host br-dis-tot_ mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-region f-dtm-code f-dtm-name f-dt-code ~
f-sum-id rs-curr mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-card
     LABEL "Карта"
     SIZE 10 BY 1.

DEFINE BUTTON b-dt-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.

DEFINE BUTTON b-dtm-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE f-dt-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код итога"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код объекта"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtm-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 31.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-curr AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нац.вал.", "1",
"Баз.вал.", "2",
"Нац.вал.и баз.вал.", "3"
     SIZE 40.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-region AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты", "1",
"Фирмы", "2",
"Глобально", "3"
     SIZE 30 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-tot_ FOR
                X_dis-tot_,
                X_prop-ref_ SCROLLING.


DEFINE QUERY br-dis-tot_host FOR
                X_dis-tot_host,
                X_prop-ref_host SCROLLING.


DEFINE QUERY br-dis-tot_obj FOR X_dis-tot_obj, X_prop-ref_obj scrolling.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-tot_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-tot_ Dialog-Frame _FREEFORM
  QUERY br-dis-tot_ NO-LOCK DISPLAY
      mark-string(recid(X_dis-tot_), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_.num-chk COLUMN-LABEL "Число чеков" format "->>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.87 FIT-LAST-COLUMN.

DEFINE BROWSE br-dis-tot_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-tot_host Dialog-Frame _FREEFORM
  QUERY br-dis-tot_host NO-LOCK DISPLAY
      mark-string(recid(X_dis-tot_host), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_dis-tot_host.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_host.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_host.num-chk COLUMN-LABEL "Число чеков" format "->>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.87 FIT-LAST-COLUMN.

DEFINE BROWSE br-dis-tot_obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-tot_obj Dialog-Frame _FREEFORM
  QUERY br-dis-tot_obj NO-LOCK DISPLAY
      mark-string(recid(X_dis-tot_obj), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-tot_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_dis-tot_obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_obj.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_obj.num-chk COLUMN-LABEL "Число чеков" format "->>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.87 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 12
     b-sel AT ROW 1 COL 25 WIDGET-ID 10
     rs-region AT ROW 1 COL 35 NO-LABEL WIDGET-ID 26
     b-lkp AT ROW 1 COL 66 WIDGET-ID 6
     b-card AT ROW 1 COL 76 WIDGET-ID 16
     b-sch AT ROW 1 COL 86 WIDGET-ID 2
     B-print AT ROW 1 COL 89 WIDGET-ID 20
     b-history AT ROW 1 COL 92 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     f-dtm-code AT ROW 2 COL 1 WIDGET-ID 34
     b-dtm-code AT ROW 2 COL 22.5 WIDGET-ID 32
     f-dtm-name AT ROW 2 COL 25.5 NO-LABEL WIDGET-ID 30
     f-dt-code AT ROW 3 COL 3 WIDGET-ID 36
     b-dt-code AT ROW 3 COL 22.5 WIDGET-ID 38
     f-sum-id AT ROW 3 COL 25.5 NO-LABEL WIDGET-ID 40
     rs-curr AT ROW 3 COL 58 NO-LABEL WIDGET-ID 22
     br-dis-tot_obj AT ROW 4 COL 1.5 WIDGET-ID 100
     br-dis-tot_host AT ROW 4 COL 1.5 WIDGET-ID 200
     br-dis-tot_ AT ROW 4 COL 1.5 WIDGET-ID 300
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(78.50) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_dis-tot_ B "?" ? ub dis-host
      TABLE: X_dis-tot_host B "?" ? ub dis-host
      TABLE: X_dis-tot_obj B "?" ? ub dis-obj
      TABLE: X_prop-ref_ B "?" ? ub prop-ref
      TABLE: X_prop-ref_host B "?" ? ub prop-ref
      TABLE: X_prop-ref_obj B "?" ? ub prop-ref
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-tot_obj rs-curr Dialog-Frame */
/* BROWSE-TAB br-dis-tot_host br-dis-tot_obj Dialog-Frame */
/* BROWSE-TAB br-dis-tot_ br-dis-tot_host Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-dt-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-dtm-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-sum-id IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-tot_
/* Query rebuild information for BROWSE br-dis-tot_
     _START_FREEFORM
OPEN QUERY br-dis-tot_
FOR EACH X_dis-tot_ NO-LOCK,
    FIRST X_prop-ref_ NO-LOCK WHERE
         X_prop-ref_.dt-code = X_dis-tot_.dt-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-tot_ FOR
                X_dis-tot_,
                X_prop-ref_ SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-tot_ */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-tot_host
/* Query rebuild information for BROWSE br-dis-tot_host
     _START_FREEFORM
OPEN QUERY br-dis-tot_host
FOR EACH X_dis-tot_host NO-LOCK,
    FIRST X_prop-ref_host NO-LOCK WHERE
         X_prop-ref_host.dt-code = X_dis-tot_host.dt-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-tot_host FOR
                X_dis-tot_host,
                X_prop-ref_host SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-tot_host */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-tot_obj
/* Query rebuild information for BROWSE br-dis-tot_obj
     _START_FREEFORM
OPEN QUERY br-dis-tot_obj
FOR EACH X_dis-tot_obj NO-LOCK,
    FIRST X_prop-ref_obj NO-LOCK WHERE
         X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-tot_obj FOR X_dis-tot_obj, X_prop-ref_obj scrolling.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-tot_obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-card Dialog-Frame
ON CHOOSE OF b-card IN FRAME Dialog-Frame /* Карта */
DO:
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
  WHEN {&g___object} THEN DO:
    IF NOT AVAILABLE X_dis-tot_obj THEN RETURN NO-APPLY.
    v-d-card = X_dis-tot_obj.d-card.
  END.
  WHEN {&company} THEN DO:
    IF NOT AVAILABLE X_dis-tot_host THEN RETURN NO-APPLY.
    v-d-card = X_dis-tot_host.d-card.
  END.
  WHEN "global" THEN DO:
    IF NOT AVAILABLE X_dis-tot_ THEN RETURN NO-APPLY.
    v-d-card = X_dis-tot_.d-card.
  END.
END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  run ref/dcardi.w (
                input parparentproc
              , input {&lookup}
              , input buf_dis-card.emitent-host-code
              , input p-curr-host-code
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input ?
              , input-output v-ri ) .

END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dt-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dt-code Dialog-Frame
ON CHOOSE OF b-dt-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input 'dis-tot':U
              ,input (if f-dtm-code = ? then 0 else f-dtm-code)
              ,input '':U
              ,input '':U /*p-caller-ird*/
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  v-list-mode = p-list-mode.
  assign
  f-dt-code = ?
  f-sum-id = '':U.
  DISPLAY
  f-sum-id
  f-dt-code
  WITH FRAME {&FRAME-NAME}.
  run openbr in this-procedure ( input yes, input no, input '':U).
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
if buf_prop-ref.dt-code = f-dtm-code then return no-apply.
ASSIGN
f-dt-code = buf_prop-ref.dt-code
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
f-dt-code
WITH FRAME {&FRAME-NAME}.
v-list-mode ="dt-code".
run openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dtm-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dtm-code Dialog-Frame
ON CHOOSE OF b-dtm-code IN FRAME Dialog-Frame /* Btn 3 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
 run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,input "general-view"
                         ,input {&prop-head-gen-dis-card-type}
                         ,input-output v-rid-list ) NO-ERROR.
 IF ERROR-STATUS:error OR v-rid-list = '':U THEN DO:
    UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_prop-head NO-LOCK WHERE
           recid(buf_prop-head) = INTEGER(v-rid-list) NO-ERROR.
 IF NOT AVAILABLE buf_prop-head  THEN DO:
  v-list-mode = p-list-mode.
  run openbr in this-procedure ( input yes, input no, input '':U).
  UNDO, RETURN NO-APPLY.
 END.
 if buf_prop-head.dtm-code = f-dtm-code then return no-apply.
 assign
 f-dtm-code = buf_prop-head.dtm-code
 f-dtm-name = buf_prop-head.prop-label
 .
 display
 f-dtm-code
 f-dtm-name
 with frame {&frame-name} .
 v-list-mode = "dtm-code".
 run openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
define variable parref-list as character no-undo .
CASE rs-region:
  when {&g___object} then do:
    if available X_dis-tot_obj  then do:
      run ref/cdchist.w (
                        INPUT parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input "":U
                        ,input "subject":U
                        ,input X_dis-tot_obj.d-card
                        ,input ? /*dis-card.card-num*/
                        ,input X_dis-tot_obj.obj-type
                        ,input X_dis-tot_obj.obj-code
                        ,input X_dis-tot_obj.host-code
                        ,input ? /*p-corr-user-db-num */
                        ,input "":U /*p-corr-user-name */
                        ,input {&table_dis-obj} /*p-subject*/
                        ,input ? /*p-db-num */
                        /*записи в выборке*/
                        ,input-output parref-list
                    ) no-error .
        apply "entry" to br-dis-tot_obj.
     end.
   end.
   when {&company} then do:
     if available X_dis-tot_host then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-tot_host.d-card
                          ,input ? /*dis-card.card-num*/
                          ,input '':U
                          ,input 0
                          ,input X_dis-tot_host.host-code
                          ,input ? /*p-corr-user-db-num */
                          ,input "":U /*p-corr-user-name */
                          ,input {&table_dis-host} /*p-subject*/
                          ,input ? /*p-db-num */
                          /*записи в выборке*/
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-tot_host.
      end.
    end.
    when "global" then do:
     if available X_dis-tot_ then do:
      run ref/cdchist.w (
                          INPUT parparentproc
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input "":U
                          ,input "subject"
                          ,input X_dis-tot_.d-card
                          ,input ? /*dis-card.card-num*/
                          ,input '':U
                          ,input 0
                          ,input 0 /*host-code*/
                          ,input ? /*p-corr-user-db-num */
                          ,input "":U /*p-corr-user-name */
                          ,input {&table_dis-host} /*p-subject*/
                          ,input ? /*p-db-num */
                          /*записи в выборке*/
                          ,input-output parref-list
                      ) no-error .
        apply "entry" to br-dis-tot_host.
      end.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-rec as recid no-undo.
DEFINE VARIABLE v-d-card AS CHARACTER NO-UNDO.
DEFINE variable v-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
CASE rs-region:
    WHEN {&g___object} THEN DO:
      IF NOT AVAILABLE X_dis-tot_obj THEN RETURN NO-APPLY.
      v-d-card = X_dis-tot_obj.d-card.
    END.
    WHEN {&company} THEN DO:
      IF NOT AVAILABLE X_dis-tot_host THEN RETURN NO-APPLY.
      v-d-card = X_dis-tot_host.d-card.
    END.
    WHEN "global" THEN DO:
      IF NOT AVAILABLE X_dis-tot_ THEN RETURN NO-APPLY.
      v-d-card = X_dis-tot_.d-card.
    END.
 END CASE.
find first buf_dis-card no-lock where
           buf_dis-card.d-card = v-d-card no-error .
if avail buf_dis-card then do:
  assign
  v-ri = recid( buf_dis-card )
 .
  if buf_dis-card.emitent-host-code = p-curr-host-code
  or buf_dis-card.emitent-host-code = 0 then do:
      run ref/dc-view.w ( input parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input buf_dis-card.d-card
                    ,input NO /*t-legacy*/
                    ,input NO /*t-subsid*/
                    ) NO-ERROR.
  end.
  else do:
      message "Данная дисконтная карта принадлежит другой фирме - просмотр запрещен!"
      view-as alert-box ERROR.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_dis-tot_obj then do:
 { gbl/markstrn.i X_dis-tot_obj v-rid-list }
  glog = br-dis-tot_obj:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-dis-tot_obj:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-tot_obj in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-tot_obj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-doc-rec as recid no-undo .
 CASE rs-region:
     WHEN {&g___object} THEN DO:
      v-doc-rec = recid( X_dis-tot_obj ).
      DO WHILE available X_dis-tot_obj :
        GET prev br-dis-tot_obj.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-tot_obj to recid v-doc-rec no-error.
      apply "entry" to br-dis-tot_obj in frame {&frame-name}.
   END.
   WHEN {&company} THEN DO:
      v-doc-rec = recid( X_dis-tot_host ).
      DO WHILE available X_dis-tot_host :
          GET prev br-dis-tot_host.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-tot_host to recid v-doc-rec no-error.
      apply "entry" to br-dis-tot_host in frame {&frame-name}.

  END.
  WHEN "global" THEN DO:
      v-doc-rec = recid( X_dis-tot_ ).
      DO WHILE available X_dis-tot_ :
          GET prev br-dis-tot_.
      END.
      run PrintProc IN THIS-PROCEDURE ( f-dtm-code, rs-region) .
      reposition br-dis-tot_ to recid v-doc-rec no-error.
      apply "entry" to br-dis-tot_ in frame {&frame-name}.

  END.
 END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE (INPUT rs-region) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_dis-tot_obj then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_dis-tot_obj ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-curr Dialog-Frame
ON VALUE-CHANGED OF rs-curr IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-curr.
  CASE rs-curr:
    WHEN {&r-b-rubl} THEN DO:
        ASSIGN
        X_dis-tot_.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_host.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_host.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_host.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_obj.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        X_dis-tot_obj.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        X_dis-tot_obj.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        .
    END.
    WHEN {&r-b-base} THEN DO:
        ASSIGN
        X_dis-tot_.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = NO
        X_dis-tot_.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_host.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_host.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_host.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = NO
        X_dis-tot_host.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_obj.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        X_dis-tot_obj.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        X_dis-tot_obj.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = NO
        X_dis-tot_obj.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        .
    END.
    OTHERWISE DO:
        ASSIGN
        X_dis-tot_.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_ = YES
        X_dis-tot_host.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_host = YES
        X_dis-tot_host.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_host = yes
        X_dis-tot_host.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_host = yes
        X_dis-tot_host.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_host = yes
        X_dis-tot_obj.gds-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.gds-dis-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.pay-tot-rubl:VISIBLE IN BROWSE br-dis-tot_Obj = YES
        X_dis-tot_obj.gds-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = yes
        X_dis-tot_obj.gds-dis-base:VISIBLE IN BROWSE br-dis-tot_Obj = yes
        X_dis-tot_obj.pay-tot-base:VISIBLE IN BROWSE br-dis-tot_Obj = yes
        .

    END.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-region Dialog-Frame
ON VALUE-CHANGED OF rs-region IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-region.
  RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-tot_
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_dis-tot_obj).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-dis-tot_obj to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-dis-tot_obj. " }

{ gbl/app_help.i }
{ gbl/setfltnm.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(p-list-mode, {&ALL} + {&comma-char} + "dtm-code" + {&comma-char} + "dt-code") = 0  THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description SKIP
    "Неверное значение параметра p-list-mode" p-list-mode
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
  if lookup(p-region, {&g___object} + {&comma-char} + {&company} + {&comma-char} + "global")  = 0 then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-region" p-region SKIP
        "Нет хранилища данных"  p-region
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
  end.
  IF p-list-mode = "dtm-code" THEN DO:

    FIND FIRST buf_prop-head NO-LOCK WHERE
              buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-head THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dtm-code" p-dtm-code SKIP
        "Нет объекта-операнда c кодом"  p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
  END.
  IF p-list-mode = "dt-code"
  OR (p-list-mode = "dtm-code" AND p-dt-code > 0) THEN DO:

    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dt-code = p-dt-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-ref THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Нет итога c кодом"  p-dt-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.

    END.
    IF p-list-mode = "dtm-code"
    AND p-dtm-code <> buf_prop-ref.dtm-code THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        substitute("Код итога &1 соответствует  коду объекта &2, хотя p-dtm-code = &3"
                   , p-dt-code
                   , buf_prop-ref.dtm-code
                   , p-dtm-code)
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.


    END.
  END.
  { gbl/getcntxt.i get }
   v-list-mode = p-list-mode.
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
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
  DISPLAY rs-region f-dtm-code f-dtm-name f-dt-code f-sum-id rs-curr mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel rs-region b-lkp b-card b-sch B-print b-history 
         B-Help b-dtm-code b-dt-code rs-curr br-dis-tot_obj br-dis-tot_host 
         br-dis-tot_ mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
{ gbl/curr-r-b.i v-curr-r-b }
ASSIGN
rs-curr:RADIO-BUTTONS IN FRAME {&FRAME-NAME}= "Нац.вал." + {&comma-char} + {&r-b-rubl} + {&comma-char} +
                        "Баз.вал." + {&comma-char} + {&r-b-base} + {&comma-char} +
                        "все" + {&comma-char} + {&all}
rs-curr = v-curr-r-b
rs-region:RADIO-BUTTONS = "Объекты" + {&comma-char} + {&g___object} + {&comma-char} +
                        "Фирмы" + {&comma-char} + {&company} + {&comma-char} +
                        "Глобально" + {&comma-char} + "global"
rs-region = (IF p-region = '':U
             THEN {&g___object}
             ELSE p-region)
.
if p-list-mode = "dtm-code" then do:
  assign
  f-dtm-code  = buf_prop-head.dtm-code
  f-dtm-name  = buf_prop-head.prop-label
  .
  if p-dtm-code = 1 then do:
    assign
    X_prop-ref_.sum-id:visible in browse br-dis-tot_ = no
    X_prop-ref_.caller_id:visible in browse br-dis-tot_ = no
    X_prop-ref_host.sum-id:visible in browse br-dis-tot_host = no
    X_prop-ref_host.caller_id:visible in browse br-dis-tot_host = no
    X_prop-ref_obj.sum-id:visible in browse br-dis-tot_obj = no
    X_prop-ref_obj.caller_id:visible in browse br-dis-tot_obj = no
    .
  end.
  assign
  X_prop-ref_.dtm-code:visible in browse br-dis-tot_ = no
  X_prop-ref_host.dtm-code:visible in browse br-dis-tot_host = no
  X_prop-ref_obj.dtm-code:visible in browse br-dis-tot_obj = no
  .

end.
else do:
  f-dtm-code = ?.
end.
if p-list-mode = "dt-code"
or (p-list-mode = "dtm-code" and p-dt-code > 0)
then do:
  assign
  f-dt-code  = buf_prop-ref.dtm-code
  f-sum-id   = buf_prop-ref.sum-id
  .
end.
else do:
  f-dt-code = ?.
end.
display
f-dtm-code
f-dtm-name
f-dt-code
f-sum-id
rs-region
with frame {&frame-name} .
ENABLE
rs-curr
rs-region
b-quit
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-card
b-sch
b-print
b-history
b-dtm-code WHEN (p-list-mode <> "dtm-code")
b-dt-code WHEN (p-list-mode <> "dt-code"
                AND NOT (p-list-mode = "dtm-code" AND p-dt-code > 0)
                and NOT (p-list-mode = "dtm-code" AND p-dtm-code = 1)
                )
br-dis-tot_obj
br-dis-tot_host
br-dis-tot_
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure ( input yes, input no, input '':U).
APPLY "VALUE-CHANGED" to rs-curr.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
CASE rs-region:
  WHEN {&g___object} THEN DO:
    RUN Openbr_obj ( INPUT p-open-query
                    ,INPUT p-find-next
                    ,INPUT p-find-condition).
    br-dis-tot_obj:move-to-top() in frame {&frame-name} .
    apply "ENTRY" to br-dis-tot_obj.
    apply "VALUE-CHANGED" to br-dis-tot_obj.
  END.
  WHEN {&company} THEN DO:
    RUN Openbr_host ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
    br-dis-tot_host:move-to-top().
    apply "ENTRY" to br-dis-tot_host.
    apply "VALUE-CHANGED" to br-dis-tot_host.
  END.
  WHEN "global" THEN DO:
    RUN Openbr_ ( INPUT p-open-query
                      ,INPUT p-find-next
                      ,INPUT p-find-condition).
     br-dis-tot_:move-to-top().
     apply "ENTRY" to br-dis-tot_.
     apply "VALUE-CHANGED" to br-dis-tot_.
  END.

END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_ Dialog-Frame 
PROCEDURE Openbr_ :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-dis-tot_ FOR EACH X_dis-tot_ NO-LOcK

&scop flt-open-dyn_open-query  FOR EACH X_dis-tot_ NO-LOcK

&scop flt-open-query-handle QUERY br-dis-tot_:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-tot_

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name  X_dis-tot_

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode.
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все итоги по ДК по фирмам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ NO-LOCK WHERE X_prop-ref_.dt-code = X_dis-tot_.dt-code
    { gbl/fltopend.i
        &where-cond = " X_dis-tot_.host-code = 0 "
        &use-ind    = "  "

        &by         = " " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все итоги по ДК по фирмам по объекту-операнду &1", f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ NO-LOCK WHERE ~
                                          X_prop-ref_.dt-code = X_dis-tot_.dt-code AND ~
                                          X_prop-ref_.dtm-code = f-dtm-code
&scop flt-open-dyn_open-query-tail    substitute('  , FIRST X_prop-ref_ NO-LOCK WHERE ~
                                          X_prop-ref_.dt-code = X_dis-tot_.dt-code AND ~
                                          X_prop-ref_.dtm-code = &1', f-dtm-code)

      { gbl/fltopend.i
        &where-cond = " X_dis-tot_.host-code = 0 "
        &use-ind    = "  "
        &by         = " " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Все итоги &1 по ДК по фирмам по объекту-операнду &2"
                                        , f-sum-id
                                        , f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_ WHERE ~
                                           X_prop-ref_.dt-code = X_dis-tot_.dt-code ~
        { gbl/fltopend.i
            &where-cond = "X_dis-tot_.host-code = 0 and X_dis-tot_.dt-code = f-dt-code "
            &dyn_where-cond = " substitute(' X_dis-tot_.host-code = 0 and X_dis-tot_.dt-code = &1', f-dt-code) "
            &use-ind    = "  "
            &by         = " " }

  END.

END CASE.
if not p-open-query then
REPOSITION br-dis-tot_ to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-tot_:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-tot_.
APPLY "VALUE-CHANGED" TO br-dis-tot_ in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_host Dialog-Frame 
PROCEDURE Openbr_host :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dis-tot_host FOR EACH X_dis-tot_host NO-LOcK

&scop flt-open-dyn_open-query FOR EACH X_dis-tot_host NO-LOcK

&scop flt-open-query-handle QUERY br-dis-tot_host:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-tot_host

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-tot_host


&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode + "_host".
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все итоги по ДК по фирмам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host NO-LOCK WHERE X_prop-ref_host.dt-code = X_dis-tot_host.dt-code

    { gbl/fltopend.i
        &where-cond = " X_dis-tot_host.host-code > 0  "
        &use-ind    = "  "

        &by         = " " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все итоги по ДК по фирмам по объекту-операнду &1", f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host NO-LOCK WHERE ~
                                          X_prop-ref_host.dt-code = X_dis-tot_host.dt-code AND ~
                                          X_prop-ref_host.dtm-code = f-dtm-code

&scop flt-open-dyn_open-query-tail   substitute('   , FIRST X_prop-ref_host NO-LOCK WHERE ~
                                          X_prop-ref_host.dt-code = X_dis-tot_host.dt-code AND ~
                                          X_prop-ref_host.dtm-code = &1', f-dtm-code)

      { gbl/fltopend.i
        &where-cond = " X_dis-tot_host.host-code > 0 "
        &use-ind    = "  "
        &by         = " " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Все итоги &1 по ДК по фирмам по объекту-операнду &2"
                                        , f-sum-id
                                        , f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_host WHERE ~
                                           X_prop-ref_host.dt-code = X_dis-tot_host.dt-code ~
        { gbl/fltopend.i
            &where-cond = " X_dis-tot_host.host-code > 0 and  X_dis-tot_host.dt-code = f-dt-code "
            &dyn_where-cond = " substitute('X_dis-tot_host.host-code > 0 and  X_dis-tot_host.dt-code = &1', f-dt-code )"
            &use-ind    = "  "
            &by         = " " }

  END.

END CASE.
if not p-open-query then
REPOSITION br-dis-tot_host to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-tot_host:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-tot_host.
APPLY "VALUE-CHANGED" TO br-dis-tot_host in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr_obj Dialog-Frame 
PROCEDURE Openbr_obj :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-dis-tot_obj FOR EACH X_dis-tot_obj NO-LOcK

&scop flt-open-dyn_open-query FOR EACH X_dis-tot_obj NO-LOcK

&scop flt-open-query-handle QUERY br-dis-tot_obj:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-tot_obj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-tot_obj


&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + v-list-mode + "_obj".
CASE v-list-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point-label = substitute("Все итоги по ДК по объектам")
    frame {&frame-name}:title = filter-point-label
    .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj NO-LOCK WHERE X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code
    { gbl/fltopend.i
        &where-cond = " true "
        &use-ind    = "  "

        &by         = " " }
    END.
    when "dtm-code" then do:
        assign
        filter-point-label = substitute("Все итоги по ДК по объектам по объекту-операнду &1", f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj NO-LOCK WHERE ~
                                          X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code AND ~
                                          X_prop-ref_obj.dtm-code = f-dtm-code
&scop flt-open-dyn_open-query-tail    substitute('  , FIRST X_prop-ref_obj NO-LOCK WHERE ~
                                          X_prop-ref_obj.dt-code = X_dis-tot_obj.dt-code AND ~
                                          X_prop-ref_obj.dtm-code = &1', f-dtm-code)

      { gbl/fltopend.i
        &where-cond = " true"~
        &use-ind    = "  "
        &by         = " " }

  END.
  when "dt-code" then do:
        assign
        filter-point-label = substitute("Все итоги &1 по ДК по объектам по объекту-операнду &2"
                                        , f-sum-id
                                        , f-dtm-code)
        frame {&frame-name}:title = filter-point-label
        .
&scop flt-open-open-query-tail      , FIRST X_prop-ref_obj WHERE ~
                                           X_prop-ref_Obj.dt-code = X_dis-tot_obj.dt-code ~
        { gbl/fltopend.i
            &where-cond = " X_dis-tot_obj.dt-code = f-dt-code "
            &dyn_where-cond = " substitute('X_prop-ref_obj.dt-code = &1', f-dt-code) "
            &use-ind    = "  "
            &by         = " " }

  END.

END CASE.
if not p-open-query then
REPOSITION br-dis-tot_obj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-tot_obj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-dis-tot_obj.
APPLY "VALUE-CHANGED" TO br-dis-tot_obj in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Printproc Dialog-Frame 
PROCEDURE Printproc :
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable  date_string        as character no-undo.
define variable  Line               as character no-undo.
define variable  for-time           as character no-undo .
define variable  accum-count        as integer   no-undo .
define variable  accum-gds-tot-base as decimal   no-undo .
define variable  accum-gds-tot-rubl as decimal   no-undo .
define variable  accum-gds-dis-base as decimal   no-undo .
define variable  accum-gds-dis-rubl as decimal   no-undo .
define variable  accum-pay-tot-base as decimal   no-undo .
define variable  accum-pay-tot-rubl as decimal   no-undo .
define variable  accum-num-chk      as integer   no-undo .
DEFINE FRAME dis-tot_
X_prop-ref_.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_.num-chk COLUMN-LABEL "Число чеков" format ">>>,>>9"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .


DEFINE FRAME dis-tot_host
X_prop-ref_host.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_host.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_host.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_host.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_host.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>9"
X_dis-tot_host.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_host.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_host.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_host.num-chk COLUMN-LABEL "Число чеков" format ">>>,>>9"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

DEFINE FRAME dis-tot_obj
X_prop-ref_obj.sum-id COLUMN-LABEL "Идентификатор"
X_prop-ref_obj.caller_id COLUMN-LABEL "Доп!Идентификатор"
X_prop-ref_obj.dtm-code COLUMN-LABEL "Код!объекта-!операнда" format ">>9"
X_dis-tot_obj.d-card COLUMN-LABEL "№ ДК" FORMAT "X(19)"
X_dis-tot_obj.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>9"
X_dis-tot_obj.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_dis-tot_obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная!нац.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.pay-tot-rubl COLUMN-LABEL "Сумма оплат!нац.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_obj.gds-tot-base COLUMN-LABEL "Сумма товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.gds-dis-base COLUMN-LABEL "Скидка товарная!баз.вал." format "->>,>>>,>>>,>>>,>>9.99"
X_dis-tot_obj.pay-tot-base COLUMN-LABEL "Сумма оплат!баз.вал." FORMAT "->>,>>>,>>>,>>>,>>>.<<"
X_dis-tot_obj.num-chk COLUMN-LABEL "Число чеков" format ">>>,>>9"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", {&A4_LS}).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream unformatted
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(0)
(if f-dtm-code <> 0 then f-dtm-name else '':U) skip(0)
(if f-dt-code <> ? then f-sum-id else '':U)
.
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
CASE p-region:
  when "global" then do:
    FORM with FRAME dis-tot_ .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-tot_  no-lock.
    DO WHILE available X_dis-tot_:
      Display STREAM PrnLibStream
      X_prop-ref_.sum-id
      X_prop-ref_.caller_id
      X_prop-ref_.dtm-code
      X_dis-tot_.d-card
      X_dis-tot_.gds-tot-rubl
      X_dis-tot_.gds-dis-rubl
      X_dis-tot_.pay-tot-rubl
      X_dis-tot_.gds-tot-base
      X_dis-tot_.gds-dis-base
      X_dis-tot_.pay-tot-base
      X_dis-tot_.num-chk
      with FRAME dis-tot_ .
      DOWN STREAM PrnLibStream 1 with FRAME dis-tot_ .
      assign
      accum-count = accum-count + 1
      accum-gds-tot-base = accum-gds-tot-base + X_dis-tot_.gds-tot-base
      accum-gds-tot-rubl = accum-gds-tot-rubl + X_dis-tot_.gds-tot-rubl
      accum-gds-dis-base = accum-gds-dis-base + X_dis-tot_.gds-dis-base
      accum-gds-dis-rubl = accum-gds-dis-rubl + X_dis-tot_.gds-dis-rubl
      accum-pay-tot-base = accum-pay-tot-base + X_dis-tot_.pay-tot-base
      accum-pay-tot-rubl = accum-pay-tot-rubl + X_dis-tot_.pay-tot-rubl
      accum-num-chk = accum-num-chk + X_dis-tot_.num-chk
      .
      GET next br-dis-tot_ no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_.sum-id
    X_prop-ref_.caller_id
    X_prop-ref_.dtm-code
    X_dis-tot_.d-card
    X_dis-tot_.gds-tot-rubl
    X_dis-tot_.gds-dis-rubl
    X_dis-tot_.pay-tot-rubl
    X_dis-tot_.gds-tot-base
    X_dis-tot_.gds-dis-base
    X_dis-tot_.pay-tot-base
    X_dis-tot_.num-chk
    with FRAME dis-tot_ .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_.sum-id
    accum-count @ X_dis-tot_.d-card
    accum-gds-tot-base @   X_dis-tot_.gds-tot-rubl
    accum-gds-tot-rubl @   X_dis-tot_.gds-dis-rubl
    accum-gds-dis-base @   X_dis-tot_.pay-tot-rubl
    accum-gds-dis-rubl @   X_dis-tot_.gds-tot-base
    accum-pay-tot-base @   X_dis-tot_.gds-dis-base
    accum-pay-tot-rubl @   X_dis-tot_.pay-tot-base
    accum-num-chk      @   X_dis-tot_.num-chk
    with frame dis-tot_.
  end.
  when {&company} then do:
    FORM with FRAME dis-tot_host .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-tot_host  no-lock.
    DO WHILE available X_dis-tot_host:
      Display STREAM PrnLibStream
      X_prop-ref_host.sum-id
      X_prop-ref_host.caller_id
      X_prop-ref_host.dtm-code
      X_dis-tot_host.d-card
      X_dis-tot_host.host-code
      X_dis-tot_host.gds-tot-rubl
      X_dis-tot_host.gds-dis-rubl
      X_dis-tot_host.pay-tot-rubl
      X_dis-tot_host.gds-tot-base
      X_dis-tot_host.gds-dis-base
      X_dis-tot_host.pay-tot-base
      X_dis-tot_host.num-chk
      with FRAME dis-tot_host .
      DOWN STREAM PrnLibStream 1 with FRAME dis-tot_host .
      assign
      accum-count = accum-count + 1
      accum-gds-tot-base = accum-gds-tot-base + X_dis-tot_host.gds-tot-base
      accum-gds-tot-rubl = accum-gds-tot-rubl + X_dis-tot_host.gds-tot-rubl
      accum-gds-dis-base = accum-gds-dis-base + X_dis-tot_host.gds-dis-base
      accum-gds-dis-rubl = accum-gds-dis-rubl + X_dis-tot_host.gds-dis-rubl
      accum-pay-tot-base = accum-pay-tot-base + X_dis-tot_host.pay-tot-base
      accum-pay-tot-rubl = accum-pay-tot-rubl + X_dis-tot_host.pay-tot-rubl
      accum-num-chk = accum-num-chk + X_dis-tot_host.num-chk
      .
      GET next br-dis-tot_host no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_host.sum-id
    X_prop-ref_host.caller_id
    X_prop-ref_host.dtm-code
    X_dis-tot_host.d-card
    X_dis-tot_host.host-code
    X_dis-tot_host.gds-tot-rubl
    X_dis-tot_host.gds-dis-rubl
    X_dis-tot_host.pay-tot-rubl
    X_dis-tot_host.gds-tot-base
    X_dis-tot_host.gds-dis-base
    X_dis-tot_host.pay-tot-base
    X_dis-tot_host.num-chk
    with FRAME dis-tot_host .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_host.sum-id
    accum-count @ X_dis-tot_host.d-card
    accum-gds-tot-base @   X_dis-tot_host.gds-tot-rubl
    accum-gds-tot-rubl @   X_dis-tot_host.gds-dis-rubl
    accum-gds-dis-base @   X_dis-tot_host.pay-tot-rubl
    accum-gds-dis-rubl @   X_dis-tot_host.gds-tot-base
    accum-pay-tot-base @   X_dis-tot_host.gds-dis-base
    accum-pay-tot-rubl @   X_dis-tot_host.pay-tot-base
    accum-num-chk      @   X_dis-tot_host.num-chk
    with frame dis-tot_host.
  end.
  when {&g___object} then do:
    FORM with FRAME dis-tot_obj .
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-dis-tot_obj  no-lock.
    DO WHILE available X_dis-tot_obj:
      Display STREAM PrnLibStream
      X_prop-ref_obj.sum-id
      X_prop-ref_obj.caller_id
      X_prop-ref_obj.dtm-code
      X_dis-tot_obj.d-card
      X_dis-tot_obj.obj-code
      X_dis-tot_obj.obj-type
      X_dis-tot_obj.gds-tot-rubl
      X_dis-tot_obj.gds-dis-rubl
      X_dis-tot_obj.pay-tot-rubl
      X_dis-tot_obj.gds-tot-base
      X_dis-tot_obj.gds-dis-base
      X_dis-tot_obj.pay-tot-base
      X_dis-tot_obj.num-chk
      with FRAME dis-tot_obj .
      DOWN STREAM PrnLibStream 1 with FRAME dis-tot_obj .
      assign
      accum-count = accum-count + 1
      accum-gds-tot-base = accum-gds-tot-base + X_dis-tot_obj.gds-tot-base
      accum-gds-tot-rubl = accum-gds-tot-rubl + X_dis-tot_obj.gds-tot-rubl
      accum-gds-dis-base = accum-gds-dis-base + X_dis-tot_obj.gds-dis-base
      accum-gds-dis-rubl = accum-gds-dis-rubl + X_dis-tot_obj.gds-dis-rubl
      accum-pay-tot-base = accum-pay-tot-base + X_dis-tot_obj.pay-tot-base
      accum-pay-tot-rubl = accum-pay-tot-rubl + X_dis-tot_obj.pay-tot-rubl
      accum-num-chk = accum-num-chk + X_dis-tot_obj.num-chk
      .
      GET next br-dis-tot_obj no-lock.
    END.
    UNDERLINE  STREAM PrnLibStream
    X_prop-ref_obj.sum-id
    X_prop-ref_obj.caller_id
    X_prop-ref_obj.dtm-code
    X_dis-tot_obj.d-card
    X_dis-tot_obj.obj-code
    X_dis-tot_obj.obj-type
    X_dis-tot_obj.gds-tot-rubl
    X_dis-tot_obj.gds-dis-rubl
    X_dis-tot_obj.pay-tot-rubl
    X_dis-tot_obj.gds-tot-base
    X_dis-tot_obj.gds-dis-base
    X_dis-tot_obj.pay-tot-base
    X_dis-tot_obj.num-chk
    with FRAME dis-tot_obj .
    DISPLAY STREAM PrnLibStream
    "Итого" @ X_prop-ref_obj.sum-id
    accum-count @ X_dis-tot_obj.d-card
    accum-gds-tot-base @   X_dis-tot_obj.gds-tot-rubl
    accum-gds-tot-rubl @   X_dis-tot_obj.gds-dis-rubl
    accum-gds-dis-base @   X_dis-tot_obj.pay-tot-rubl
    accum-gds-dis-rubl @   X_dis-tot_obj.gds-tot-base
    accum-pay-tot-base @   X_dis-tot_obj.gds-dis-base
    accum-pay-tot-rubl @   X_dis-tot_obj.pay-tot-base
    accum-num-chk      @   X_dis-tot_obj.num-chk
    with frame dis-tot_obj.
  end.
end case.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame 
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid-list AS CHARACTER NO-undo.
CASE p-option:
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
define variable loc-point as character no-undo .
define variable loc-label as character no-undo .
CASE p-region:
  WHEN {&g___object} THEN DO:
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('host-code', 'Фирма', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    assign
      tbl = 'dis-obj'
      join-tbl = 'X_dis-tot_obj'
      fld = ""
      lab = ""
      spr = ""
      dim = '0'
      loc-point = substitute('&1_obj', filter-point)
      loc-label = substitute('&1 ОБъект', filter-point-label)
      .

  END.
  WHEN {&company} THEN DO:
     run fltfield-add in this-procedure('host-code', 'Фирма', '',
     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
     assign
       tbl = 'dis-host'
       join-tbl = 'X_dis-tot_host'
       fld = ""
       lab = ""
       spr = ""
       dim = '0'
      loc-point = substitute('&1_host', filter-point)
      loc-label = substitute('&1 Фирма', filter-point-label)

       .
  END.
  WHEN "global" THEN DO:
      assign
        tbl = 'dis-host'
        join-tbl = 'X_dis-tot_'
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
      loc-point = substitute('&1', filter-point)
      loc-label = substitute('&1', filter-point-label)

        .
  END.
END CASE.
run fltfield-add in this-procedure('d-card', '№ карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-tot-base', 'Сум. тов. в ценах продажи баз вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-tot-rubl', 'Сум. тов. в ценах продажи нац вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-dis-base', 'Скидка в ценах продажи баз вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-dis-rubl', 'Скидка в ценах продажи нац вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-tot-base', 'Сумма оплат в баз вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-tot-rubl', 'Сумма оплат в нац вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk', 'Кол-во чеков', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (loc-point + {&delim-par} + loc-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

