&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_condition-keeping FOR ub.condition-keeping.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пакетное изменение списка товаров - ввод доплнительной информации по товару

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Created: 22/07/98

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type LIKE ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code LIKE ub.clients.obj-code no-undo .

define output parameter destin_ like ub.goods.destin no-undo .
define output parameter attrib_ like ub.goods.attrib no-undo .
define output parameter user-rule_ like ub.goods.user-rule no-undo .
define output parameter sert_ like ub.goods.sert no-undo .
define output parameter struct_ like ub.goods.struct no-undo .
define output parameter deadline_ like ub.goods.deadline no-undo .
define output parameter sort_ like ub.goods.sort no-undo .
define output parameter nationality_       like ub.goods.nationality no-undo .
define output parameter tnved_       like ub.goods.tnved format "x(10)" no-undo .
define output parameter unit-cst_       like ub.goods.unit-cst no-undo .
define output parameter cst-base-rate_       like ub.goods.cst-base-rate no-undo .
define output parameter normal-wastage_ like ub.goods.normal-wastage no-undo .
define output parameter normal-waste_ like ub.goods.normal-waste no-undo .
define output parameter cond-keep-code_ like ub.goods.cond-keep-code no-undo .
define output parameter proof_      like goods.proof no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable rid-tnved as recid no-undo.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/t-tnved.i  }
{ gbl/getcntxt.i def }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help l-normal-waste ~
l-attrib l-tnved l-destin l-normal-wastage l-userrule l-sert l-struct ~
l-unit-cst l-cst-base-rate l-deadline l-sort RECT-10 l-nationality ~
l-cond-keep-code l-proof cond-keep-code n-tnved n-unit-cst n-cst-base-rate ~
n-nationality n-destin n-attrib n-userrule n-sert n-struct n-deadline-2 ~
n-sort n-deadline n-normal-wastage n-normal-waste n-cond-keep-code proof
&Scoped-Define DISPLAYED-OBJECTS TNVED tnved-name unit-cst cst-base-rate ~
NATIONALITY Destin Attrib UserRule Sert Struct DeadLine Sort normal-wastage ~
normal-waste cond-keep-code proof n-tnved n-unit-cst n-cst-base-rate ~
n-nationality n-destin n-attrib n-userrule n-sert n-struct n-deadline-2 ~
n-sort n-deadline n-normal-wastage n-normal-waste proof n-cond-keep-code ~
cond-keep-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON r-cnd-keep
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     size 2.75 by 0.92.

DEFINE BUTTON r-cst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     size 2.75 by 0.92.

DEFINE VARIABLE Attrib AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 55 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE cond-keep-code AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cond-keep-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY .67 NO-UNDO.

DEFINE VARIABLE cst-base-rate AS DECIMAL FORMAT ">>,>>9.9999999999" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE DeadLine AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     size 9.75 by 0.92
     BGCOLOR 12 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Destin AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 57.63 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE n-attrib AS CHARACTER FORMAT "X(256)":U INITIAL "Характеристики"
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-cond-keep-code AS CHARACTER FORMAT "X(256)":U INITIAL "Код услов.хран."
      VIEW-AS TEXT
     SIZE 15 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-cst-base-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Коэффициент"
      VIEW-AS TEXT
     SIZE 12.75 BY 1 NO-UNDO.

DEFINE VARIABLE n-deadline AS CHARACTER FORMAT "X(256)":U INITIAL "Срок хранения"
      VIEW-AS TEXT
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-deadline-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Срок хранения"
      VIEW-AS TEXT
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-destin AS CHARACTER FORMAT "X(256)":U INITIAL "Назначение"
      VIEW-AS TEXT
     SIZE 11.25 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-nationality AS CHARACTER FORMAT "X(256)":U INITIAL "Статус (национальность)"
      VIEW-AS TEXT
     SIZE 24.38 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-normal-wastage AS CHARACTER FORMAT "X(256)":U INITIAL "Ест.убыль"
      VIEW-AS TEXT
     SIZE 11.63 BY 1
     BGCOLOR 8 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-normal-waste AS CHARACTER FORMAT "X(256)":U INITIAL "Отходы"
      VIEW-AS TEXT
     SIZE 11.63 BY 1
     BGCOLOR 8 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-sert AS CHARACTER FORMAT "X(256)":U INITIAL "Сертификат"
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-sort AS CHARACTER FORMAT "X(256)":U INITIAL "Сорт"
      VIEW-AS TEXT
     SIZE 4.88 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-struct AS CHARACTER FORMAT "X(256)":U INITIAL "Состав(комплектность)"
      VIEW-AS TEXT
     SIZE 22.75 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-tnved AS CHARACTER FORMAT "X(256)":U INITIAL "Код ТНВЭД"
      VIEW-AS TEXT
     SIZE 12.75 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-unit-cst AS CHARACTER FORMAT "X(256)":U INITIAL "Тамож.ед"
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-userrule AS CHARACTER FORMAT "X(256)":U INITIAL "Пра-ла экспл."
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE normal-wastage AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE normal-waste AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE proof AS DECIMAL FORMAT ">9.99%":U INITIAL 0 
     LABEL "Алкоголь" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Sert AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 56.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Sort AS CHARACTER FORMAT "X(30)":U
     VIEW-AS FILL-IN
     size 10.25 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Struct AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 47 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TNVED AS CHARACTER FORMAT "x(10)"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tnved-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE unit-cst AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 6.38 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE UserRule AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 53.25 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE IMAGE l-attrib
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-cond-keep-code
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-cst-base-rate
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-deadline
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-destin
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-nationality
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-normal-wastage
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-normal-waste
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-proof
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-sert
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-sort
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-struct
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-tnved
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-unit-cst
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE IMAGE l-userrule
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 6.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 74.5 BY 1.5.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 12.13
     BGCOLOR 0 FGCOLOR 0 .

DEFINE VARIABLE NATIONALITY AS CHARACTER INITIAL "Российский"
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "Российский","Иностранный"
     SIZE 24.63 BY 1
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     TNVED AT ROW 4.04 COL 18 COLON-ALIGNED NO-LABEL
     tnved-name AT ROW 4.04 COL 30.13 COLON-ALIGNED NO-LABEL
     unit-cst AT ROW 5.25 COL 17.38 COLON-ALIGNED NO-LABEL
     r-cst AT ROW 5.33 COL 26.5
     cst-base-rate AT ROW 5.38 COL 55 COLON-ALIGNED NO-LABEL
     NATIONALITY AT ROW 6.58 COL 43.25 NO-LABEL
     Destin AT ROW 9.29 COL 16.63 COLON-ALIGNED NO-LABEL
     Attrib AT ROW 10.71 COL 19.25 COLON-ALIGNED NO-LABEL
     UserRule AT ROW 12.13 COL 21 COLON-ALIGNED NO-LABEL
     Sert AT ROW 13.54 COL 17.75 COLON-ALIGNED NO-LABEL
     Struct AT ROW 14.96 COL 27.25 COLON-ALIGNED NO-LABEL
     DeadLine AT ROW 16.54 COL 42.75 COLON-ALIGNED NO-LABEL
     Sort AT ROW 16.54 COL 62.5 COLON-ALIGNED NO-LABEL
     normal-wastage AT ROW 17.75 COL 16.75 COLON-ALIGNED NO-LABEL
     normal-waste AT ROW 17.88 COL 42.13 COLON-ALIGNED NO-LABEL
     cond-keep-code AT ROW 19.5 COL 20.5 COLON-ALIGNED NO-LABEL
     r-cnd-keep AT ROW 19.5 COL 28
     proof AT ROW 21.25 COL 20.5 COLON-ALIGNED WIDGET-ID 6
     n-tnved AT ROW 4 COL 7 NO-LABEL
     n-unit-cst AT ROW 5.29 COL 9.5 NO-LABEL
     n-cst-base-rate AT ROW 5.42 COL 43.25 NO-LABEL
     n-nationality AT ROW 6.54 COL 17.75 NO-LABEL
     n-destin AT ROW 9.25 COL 7.13 NO-LABEL
     n-attrib AT ROW 10.71 COL 7.25 NO-LABEL
     n-userrule AT ROW 12.13 COL 7.13 NO-LABEL
     n-sert AT ROW 13.5 COL 5.75 NO-LABEL
     n-struct AT ROW 15.04 COL 5.88 NO-LABEL
     n-deadline-2 AT ROW 16.5 COL 29.75 NO-LABEL
     n-sort AT ROW 16.5 COL 59.13 NO-LABEL
     n-deadline AT ROW 16.54 COL 29.5 NO-LABEL
     n-normal-wastage AT ROW 17.75 COL 6.25 NO-LABEL
     n-normal-waste AT ROW 17.88 COL 31.63 NO-LABEL
     n-cond-keep-code AT ROW 19.25 COL 6.5 NO-LABEL
     cond-keep-name AT ROW 19.5 COL 29.5 COLON-ALIGNED NO-LABEL
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.88 BY 1 AT ROW 2 COL 24
          BGCOLOR 3
     l-normal-waste AT ROW 17.79 COL 29.5
     l-attrib AT ROW 10.71 COL 4.25
     RECT-9 AT ROW 8.5 COL 2.5
     l-tnved AT ROW 4.29 COL 4.25
     l-destin AT ROW 9.25 COL 4.25
     l-normal-wastage AT ROW 17.79 COL 4
     l-userrule AT ROW 12.04 COL 4
     l-sert AT ROW 13.5 COL 3.63
     l-struct AT ROW 15.08 COL 3.5
     l-unit-cst AT ROW 5.38 COL 6.88
     l-cst-base-rate AT ROW 5.38 COL 41
     l-deadline AT ROW 16.54 COL 27
     l-sort AT ROW 16.5 COL 56.63
     RECT-10 AT ROW 2.25 COL 2.5
     l-nationality AT ROW 6.5 COL 15
     l-cond-keep-code AT ROW 19.25 COL 3.5
     RECT-12 AT ROW 21 COL 2.5 WIDGET-ID 10
     l-proof AT ROW 21.25 COL 9.5 WIDGET-ID 12
     SPACE(66.74) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS THREE-D  SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 
         TITLE BGCOLOR 8 FGCOLOR 1 "Введите изменения атрибутов товара для пакетной обработки":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_condition-keeping B "?" ? ub condition-keeping
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE                                                            */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN Attrib IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cond-keep-name IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst-base-rate IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN DeadLine IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN Destin IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN n-attrib IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-cond-keep-code IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-cst-base-rate IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-deadline IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-deadline-2 IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-destin IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-nationality IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-normal-wastage IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-normal-waste IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-sert IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-sort IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-struct IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-tnved IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-unit-cst IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-userrule IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR SELECTION-LIST NATIONALITY IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN normal-wastage IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN normal-waste IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN proof IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-cnd-keep IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-cst IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-12 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-9 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN Sert IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN Sort IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN Struct IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TNVED IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tnved-name IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN unit-cst IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN UserRule IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Attrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Attrib DLGOKCAN
ON RIGHT-MOUSE-CLICK OF Attrib IN FRAME DLGOKCAN
DO:

    assign
    n-attrib:fgcolor = 15
    attrib = ""
    l-attrib:visible = true.
    display attrib with frame {&frame-name}.
    disable attrib with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel DLGOKCAN
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN /* Отмена */
DO:
    return "отказ" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Ввод */
DO:
define variable choice as log no-undo .
            assign
                Destin
                Attrib
                UserRule
                Sert
                Struct
                DeadLine
                Sort
                cst-base-rate
                NATIONALITY = IF NATIONALITY:SCREEN-VALUE = ? THEN "Российский" else
                                 NATIONALITY:SCREEN-VALUE
                TNVED
                unit-cst
                normal-wastage
                normal-waste
                cond-keep-code
                proof
                .
            assign
            destin_ = (if destin:sensitive  then Destin else ?)
            attrib_ = if Attrib:sensitive then Attrib else ?
            user-rule_ = if userrule:sensitive  then userrule else ?
            sert_ = if sert:sensitive then Sert else ?
            struct_ = if struct:sensitive then Struct else ?
            deadline_ = if Deadline:sensitive then Deadline else ?
            sort_ = if Sort:sensitive then Sort else ?
            cst-base-rate_ = if Cst-base-rate:sensitive  then cst-base-rate else ?
            NATIONALITY_ = if Nationality:sensitive then nationality else ?
            TNVED_ = if tnved:sensitive then tnved else ?
            unit-cst_ = if unit-cst:sensitive then unit-cst else ?
            normal-wastage_ = if normal-wastage:sensitive then normal-wastage else ?
            normal-waste_ = if normal-waste:sensitive then normal-waste else ?
            cond-keep-code_ = if cond-keep-code:sensitive then cond-keep-code else ?
            proof_ = if proof:sensitive then proof else ?
            
            .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cond-keep-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cond-keep-code DLGOKCAN
ON LEAVE OF cond-keep-code IN FRAME DLGOKCAN
DO:
      RUN proc-leave-cond-keep-code IN THIS-PROCEDURE (INPUT LASTKEY) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cond-keep-code DLGOKCAN
ON RIGHT-MOUSE-CLICK OF cond-keep-code IN FRAME DLGOKCAN
DO:
  assign
    n-cond-keep-code:fgcolor = 15
    cond-keep-code = ?
    l-cond-keep-code:visible = true.
    display cond-keep-code with frame {&frame-name}.
    disable cond-keep-code r-cnd-keep with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cst-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cst-base-rate DLGOKCAN
ON RIGHT-MOUSE-CLICK OF cst-base-rate IN FRAME DLGOKCAN
DO:

    assign
    n-cst-base-rate:fgcolor = 15
    cst-base-rate = ?
    l-cst-base-rate:visible = true.
    display cst-base-rate with frame {&frame-name}.
    disable cst-base-rate with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DeadLine
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadLine DLGOKCAN
ON RIGHT-MOUSE-CLICK OF DeadLine IN FRAME DLGOKCAN
DO:

    assign
    n-deadline:fgcolor = 15
    deadline = ?
    l-deadline:visible = true.
    display deadline with frame {&frame-name}.
    disable deadline with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Destin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Destin DLGOKCAN
ON RIGHT-MOUSE-CLICK OF Destin IN FRAME DLGOKCAN
DO:

    assign
    n-destin:fgcolor = 15
    destin = ""
    l-destin:visible = true.
    display destin with frame {&frame-name}.
    disable destin with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-attrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-attrib DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-attrib IN FRAME DLGOKCAN
DO:
    IF l-attrib:visible then do:
    assign
    n-attrib:fgcolor = ?
    l-attrib:visible = false.
    enable attrib with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-cond-keep-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-cond-keep-code DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-cond-keep-code IN FRAME DLGOKCAN
DO:
    IF l-cond-keep-code:visible then do:
    assign
    n-cond-keep-code:fgcolor = ?
    l-cond-keep-code:visible = false.
    enable cond-keep-code r-cnd-keep with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-cst-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-cst-base-rate DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-cst-base-rate IN FRAME DLGOKCAN
DO:
    IF l-cst-base-rate:visible then do:
    assign
    n-cst-base-rate:fgcolor = ?
    l-cst-base-rate:visible = false.
    enable cst-base-rate with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-deadline
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-deadline DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-deadline IN FRAME DLGOKCAN
DO:
    IF l-deadline:visible then do:
    assign
    n-deadline:fgcolor = ?
    l-deadline:visible = false.
    enable deadline with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-destin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-destin DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-destin IN FRAME DLGOKCAN
DO:
    IF l-destin:visible then do:
    assign
    n-destin:fgcolor = ?
    l-destin:visible = false.
    enable destin with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-nationality
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-nationality DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-nationality IN FRAME DLGOKCAN
DO:
    IF l-nationality:visible then do:
    assign
    n-nationality:fgcolor = ?
    l-nationality:visible = false.
    enable nationality with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-normal-wastage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-normal-wastage DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-normal-wastage IN FRAME DLGOKCAN
DO:
    assign
    n-normal-wastage:fgcolor = ?
    l-normal-wastage:visible = false.
    enable normal-wastage with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-normal-waste
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-normal-waste DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-normal-waste IN FRAME DLGOKCAN
DO:
    IF l-normal-waste:visible then do:
    assign
    n-normal-waste:fgcolor = ?
    l-normal-waste:visible = false.
    enable normal-waste with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-proof
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-proof DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-proof IN FRAME DLGOKCAN
DO:
    IF l-proof:visible then do:
    assign
    proof:fgcolor = ?
    l-proof:visible = false.
    enable proof with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-sert DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-sert IN FRAME DLGOKCAN
DO:
    IF l-sert:visible then do:
    assign
    n-sert:fgcolor = ?
    l-sert:visible = false.
    enable sert with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-sort DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-sort IN FRAME DLGOKCAN
DO:
    IF l-sort:visible then do:
    assign
    n-sort:fgcolor = ?
    l-sort:visible = false.
    enable sort with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-struct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-struct DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-struct IN FRAME DLGOKCAN
DO:
    IF l-struct:visible then do:
    assign
    n-struct:fgcolor = ?
    l-struct:visible = false.
    enable struct with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-tnved
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-tnved DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-tnved IN FRAME DLGOKCAN
DO:
    IF l-tnved:visible then do:
    assign
    n-tnved:fgcolor = ?
    l-tnved:visible = false.
    enable tnved with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-unit-cst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-unit-cst DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-unit-cst IN FRAME DLGOKCAN
DO:
    IF l-unit-cst:visible then do:
    assign
    n-unit-cst:fgcolor = ?
    l-unit-cst:visible = false.
    enable unit-cst with frame {&frame-name}.
    enable r-cst with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-userrule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-userrule DLGOKCAN
ON MOUSE-SELECT-CLICK OF l-userrule IN FRAME DLGOKCAN
DO:
    IF l-userrule:visible then do:
    assign
    n-userrule:fgcolor = ?
    l-userrule:visible = false.
    enable userrule with frame {&frame-name}.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NATIONALITY
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NATIONALITY DLGOKCAN
ON RIGHT-MOUSE-CLICK OF NATIONALITY IN FRAME DLGOKCAN
DO:

    assign
    n-nationality:fgcolor = 15
    nationality = ""
    l-nationality:visible = true.
    display nationality with frame {&frame-name}.
    disable nationality with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME normal-wastage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL normal-wastage DLGOKCAN
ON RIGHT-MOUSE-CLICK OF normal-wastage IN FRAME DLGOKCAN
DO:

    assign
    n-normal-wastage:fgcolor = 15
    normal-wastage = ?
    l-normal-wastage:visible = true.
    display normal-wastage with frame {&frame-name}.
    disable normal-wastage with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME normal-waste
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL normal-waste DLGOKCAN
ON RIGHT-MOUSE-CLICK OF normal-waste IN FRAME DLGOKCAN
DO:

    assign
    n-normal-waste:fgcolor = 15
    normal-waste = ?
    l-normal-waste:visible = true.
    display normal-waste with frame {&frame-name}.
    disable normal-waste with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME proof
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL proof DLGOKCAN
ON RIGHT-MOUSE-CLICK OF proof IN FRAME DLGOKCAN
DO:

    assign
    proof:fgcolor = 15
    proof = ?
    l-proof:visible = true.
    display proof with frame {&frame-name}.
    disable proof with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME r-cnd-keep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cnd-keep DLGOKCAN
ON CHOOSE OF r-cnd-keep IN FRAME DLGOKCAN
DO:
    RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-ERROR.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cst DLGOKCAN
ON CHOOSE OF r-cst IN FRAME DLGOKCAN
DO:
define variable ref-rec as recid no-undo .
    run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? then do:
      apply "entry" to r-cst in frame {&frame-name}.
      return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ unit-cst with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sert DLGOKCAN
ON RIGHT-MOUSE-CLICK OF Sert IN FRAME DLGOKCAN
DO:

    assign
    n-sert:fgcolor = 15
    sert = ""
    l-sert:visible = true.
    display sert with frame {&frame-name}.
    disable sert with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sort DLGOKCAN
ON RIGHT-MOUSE-CLICK OF Sort IN FRAME DLGOKCAN
DO:

    assign
    n-sort:fgcolor = 15
    sort = ""
    l-sort:visible = true.
    display sort with frame {&frame-name}.
    disable sort with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Struct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Struct DLGOKCAN
ON RIGHT-MOUSE-CLICK OF Struct IN FRAME DLGOKCAN
DO:

    assign
    n-struct:fgcolor = 15
    struct = ""
    l-struct:visible = true.
    display struct with frame {&frame-name}.
    disable struct with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TNVED
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TNVED DLGOKCAN
ON LEAVE OF TNVED IN FRAME DLGOKCAN
DO:
    FIND FIRST TT-tnved WHERE TT-tnved.tnved = input frame {&frame-name} tnved no-error.
  if not available TT-tnved then do:
    message "Код ТНВЭД не найден в справочнике." view-as alert-box error.
    display ? @ tnved with frame {&frame-name}.
    run ch-tnved.
    return no-apply.
  end.
  else
  if length(trim(input frame {&frame-name} tnved)) <> 10 then do:
     message "Код ТНВЭД привязки к товару должен быть 10-ти символьный." view-as alert-box error.
     display ? @ tnved with frame {&frame-name}.
     run ch-tnved.
     return no-apply.
   end.
  else
  display TT-tnved.f-name @ tnved-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TNVED DLGOKCAN
ON RIGHT-MOUSE-CLICK OF TNVED IN FRAME DLGOKCAN
DO:

    assign
    n-tnved:fgcolor = 15
    tnved = ""
    l-tnved:visible = true.
    display tnved with frame {&frame-name}.
    disable tnved with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME unit-cst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cst DLGOKCAN
ON LEAVE OF unit-cst IN FRAME DLGOKCAN
DO:
  APPLY "RETURN" to unit-cst.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cst DLGOKCAN
ON RETURN OF unit-cst IN FRAME DLGOKCAN
DO:
define variable ref-rec as recid no-undo .
  if not can-find( ub.units where
                           ub.units.unit-name = input frame {&frame-name} unit-cst ) then do:
      run ref/units.w ( input parparentproc, input yes, output ref-rec ).

    if ref-rec = ? then  do:
            apply "entry" to unit-cst in frame {&frame-name}.
            return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ unit-cst with frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cst DLGOKCAN
ON RIGHT-MOUSE-CLICK OF unit-cst IN FRAME DLGOKCAN
DO:

    assign
    n-unit-cst:fgcolor = 15
    unit-cst = ""
    l-unit-cst:visible = true.
    display unit-cst with frame {&frame-name}.
    disable unit-cst with frame {&frame-name}.
    disable r-cst with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME UserRule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UserRule DLGOKCAN
ON RIGHT-MOUSE-CLICK OF UserRule IN FRAME DLGOKCAN
DO:

    assign
    n-userrule:fgcolor = 15
    userrule = ""
    l-userrule:visible = true.
    display userrule with frame {&frame-name}.
    disable userrule with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

    RUN enable_UI.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-tnved DLGOKCAN
PROCEDURE ch-tnved :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run ref/t-tnved.w (yes, output rid-tnved).
  find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
  if available tt-tnved then disp tt-tnved.tnved @ tnved
                                  tt-tnved.f-name @ tnved-name with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
  DISPLAY       n-attrib n-cst-base-rate n-deadline
                n-deadline-2 n-destin n-nationality
                n-sert n-sort n-struct
                n-tnved n-unit-cst n-userrule n-normal-wastage n-normal-waste n-cond-keep-code proof
    with frame {&frame-name}.
  ENABLE        Btn_OK Btn_Cancel b-help
                n-attrib n-cst-base-rate n-deadline
                n-deadline-2 n-destin n-nationality
                n-sert n-sort n-struct
                n-tnved n-unit-cst n-userrule
                l-attrib l-cst-base-rate l-deadline
                l-destin l-nationality
                l-sert l-sort l-struct
                l-tnved l-unit-cst l-userrule l-normal-wastage l-normal-waste l-cond-keep-code l-proof
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-cond-keep-code DLGOKCAN
PROCEDURE proc-b-cond-keep-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-rid-list as character no-undo.
define variable v-sts as integer no-undo.
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
{ gbl/stdbtn.i }
assign
v-cond-keep-code = FRAME {&FRAME-NAME} cond-keep-code
cond-keep-code
v-sts = INTEGER({&current-status-int})
    .
IF available X_condition-keeping THEN v-rid-list = string(RECID(X_condition-keeping)) .
run ref/cndkeeps.w (
                INPUT parParentProc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input "b-sel":U /* bttns*/
               ,input {&all}
               ,input-output v-sts
               ,input-output v-rid-list).

    if v-rid-list <> "":U then do:
        FIND FIRST buf_condition-keeping WHERE
             recid( buf_condition-keeping ) = integer(v-rid-list) NO-LOCK .
        FIND FIRST X_condition-keeping WHERE
        RECID(X_condition-keeping) = RECID(buf_condition-keeping).
        assign
        cond-keep-code = buf_condition-keeping.cond-keep-code
        cond-keep-name = buf_condition-keeping.cond-keep-name
               .
        DISPLAY
        cond-keep-code
        cond-keep-name
        with frame {&frame-name} .
        RETURN.
    end.
    IF v-cond-keep-code = ? THEN DO:
       ASSIGN
       cond-keep-code = v-cond-keep-code
       cond-keep-name = "":U
       .
       RELEASE X_condition-keeping.
       DISPLAY
       cond-keep-code
       cond-keep-name
       with frame {&frame-name} .
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-leave-cond-keep-code DLGOKCAN
PROCEDURE proc-leave-cond-keep-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-lastkey AS integer NO-UNDO.
{ gbl/stdbtn.i }
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.

ASSIGN
v-cond-keep-code = FRAME {&frame-name} cond-keep-code
cond-keep-code.
FIND FIRST buf_condition-keeping WHERE
 buf_condition-keeping.cond-keep-code = cond-keep-code NO-LOCK NO-error.

if not available buf_condition-keeping then do:
    IF v-cond-keep-code <> ? THEN DO:
        MESSAGE
        "Нет условий хранения с кодом" cond-keep-code
        VIEW-AS ALERT-BOX ERROR.

        IF LASTKEY = KEYCODE("return") THEN DO:
            RUN proc-b-cond-keep-code  IN THIS-PROCEDURE NO-error.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            assign
            cond-keep-code = v-cond-keep-code.

        END.
    END.
    ELSE DO:
      IF p-LASTKEY = KEYCODE("return") THEN DO:
            MESSAGE
         "Нет условий хранения с кодом" cond-keep-code
         VIEW-AS ALERT-BOX ERROR.
      END.

    END.
    ASSIGN
    cond-keep-code = ?
    cond-keep-name = "":U
    .
    display
    cond-keep-code
    cond-keep-name
    with frame {&frame-name}.
    IF p-LASTKEY = KEYCODE("return") THEN DO:
      RUN proc-b-cond-keep-code  IN THIS-PROCEDURE NO-error.
      IF ERROR-STATUS:ERROR THEN RETURN error.
    END.
end.
else do:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            recid(X_condition-keeping) = RECID(buf_condition-keeping).
  assign
  cond-keep-name = buf_condition-keeping.cond-keep-name
  .
    display
    cond-keep-name
    cond-keep-code
    with frame {&frame-name}.
    .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME