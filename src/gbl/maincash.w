&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Основное окно АРМа Касса

Автор: Белоусов Илья Александрович
Дата создания: 07/09/08
Author: Ilia Belousov
Creation date: 07/09/08

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle    no-undo .
define input parameter p-pid      as integer          no-undo.
define input parameter p-user-id  as character        no-undo.
define input parameter p-cash-num as integer          no-undo.
define input parameter p-emul     as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Основное окно АРМа Касса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/color.i    }
define stream slip-out.

{ gbl/cd-mode.i }
{ cmp/t-tnved.i  new }

DEFINE VARIABLE v-h-timer     AS COM-HANDLE           NO-UNDO .
define variable v-etime       as INT64                no-undo.
define variable v-delta-time  as INT64             no-undo.
define variable v-cd-mode     as character INIT "0"   no-undo.
define variable v-cd-submode  as character INIT "0"   no-undo.
define variable v-psn-name    as character    no-undo.
/*
define variable v-fr-time     as integer      no-undo.
define variable v-fr-date     as date         no-undo.
*/
define variable v-curr-num    as integer      no-undo.
define variable v-curr-type   as integer      no-undo.
define variable v-summ-nett    as decimal      no-undo.


define variable v-ok          as logical      no-undo.
define variable v-err-message as character    no-undo.
define variable v-qnt         as decimal      no-undo.
define variable v-message     as character    no-undo.
define variable v-disp-message-1    as character    no-undo.
define variable v-disp-message-2    as character    no-undo.
define variable v-fr-model    as integer      no-undo. /* модель ФР */
define variable v-summ-fr-1    as decimal      no-undo.
define variable v-summ-for-pay    as decimal   no-undo.
define variable v-fr-type         as character no-undo .
define variable v-time-chk-close  as integer   no-undo. /* время закрытия последнего чека */
define variable v-com-port        as character no-undo .
define variable v-layout-id       as character no-undo . /* раскладка
                     клавиатуры    */

define variable v-layout-id-screen       as character no-undo . /* раскладка
                     интерфейса  */


define buffer buf_cash-desk for ub.cash-desk .

define buffer buf_cash-desk-attr for ub.cash-desk-attr .
define buffer buf_layout-elem-rule for layout-elem-rule .

/*Препроцессоры определяющие шрифы*/
&glob screen-size   12

&glob f_frame_12          24
&glob f_ed-msgs_big_12    21
&glob f_ed-msgs_small_12  18
&glob f_src_12            27
&glob f-src-label_12      36
&glob f_br-line_12        39
&glob f_br-line_bold_12   33
&glob f_balance_12        30
&glob f_mode_12           36
&glob f_br-line-row_12    14


&glob f_frame_14          25
&glob f_ed-msgs_big_14    22
&glob f_ed-msgs_small_14  19
&glob f_src_14            28
&glob f-src-label_14      37
&glob f_br-line_14        40
&glob f_br-line_bold_14   34
&glob f_balance_14        31
&glob f_mode_14           37
&glob f_br-line-row_14    20

&glob f_frame_15          26
&glob f_ed-msgs_big_15    23
&glob f_ed-msgs_small_15  20
&glob f_src_15            29
&glob f-src-label_15      38
&glob f_br-line_15        41
&glob f_br-line_bold_15   35
&glob f_balance_15        32
&glob f_mode_15           38
&glob f_br-line-row_15    20

   &scoped-define m-width 77.50
   &scoped-define m-height 19.17
&scoped-define ruleChoiceFromRefBook 1978
&scoped-define ruleSetDiscountCard   1998
&scoped-define StartSentinel ";"
&scoped-define EndSentinel   "?"
define variable v-font-ed-msgs_big   as integer no-undo.
define variable v-font-ed-msgs_small as integer no-undo.
define variable v-font-br-line       as integer no-undo.
define variable v-font-br-line_bold  as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bufbr_tt-line

/* Definitions for BROWSE br-line                                       */
&Scoped-define FIELDS-IN-QUERY-br-line bufbr_tt-line.src bufbr_tt-line.line-name substring(bufbr_tt-line.qnty-str,6) @ bufbr_tt-line.qnty-str substring(bufbr_tt-line.price-str,5) @ bufbr_tt-line.price-str bufbr_tt-line.summ-netto-rub bufbr_tt-line.summ-discont-rub bufbr_tt-line.summ-brutto bufbr_tt-line.num bufbr_tt-line.line-seller-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-line   
&Scoped-define SELF-NAME br-line
&Scoped-define QUERY-STRING-br-line FOR EACH bufbr_tt-line
&Scoped-define OPEN-QUERY-br-line OPEN QUERY {&SELF-NAME} FOR EACH bufbr_tt-line.
&Scoped-define TABLES-IN-QUERY-br-line bufbr_tt-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-line bufbr_tt-line


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-br-line}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS v-src-label v-date v-ed-message v-mode-name ~
v-label-balance v-card-num v-client-name v-chk-num v-src-input f1 br-line ~
f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 v-balance v-time v-total v-discount ~
v-payment b-exit v-disc-pay v-dop-mess RECT-1 RECT-4 RECT-5 RECT-6 
&Scoped-Define DISPLAYED-OBJECTS v-src-label v-date v-ed-message ~
v-mode-name v-label-balance v-card-num v-client-name v-chk-num v-src-input ~
v-balance v-time v-total v-discount v-payment v-disc-pay v-dop-mess 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f_src-label C-Win 
FUNCTION f_src-label RETURNS CHARACTER
  ( vf-src-label as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU m_whelp 
       MENU-ITEM m_version      LABEL "О программе"   
       RULE
       MENU-ITEM m_cash         LABEL "Справка по АРМу ~"Кассир~"" ACCELERATOR "CTRL-F1".

DEFINE MENU MENU-BAR-C-Win MENUBAR
       SUB-MENU  m_whelp        LABEL "Справка"       .


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 11 BY 1.46.

DEFINE BUTTON f1 
     LABEL "F1":U 
     SIZE 8.5 BY 1.46
     BGCOLOR 8 .

DEFINE BUTTON f10 
     LABEL "F10":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f11 
     LABEL "F11":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f12 
     LABEL "F12":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f2 
     LABEL "F2":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f3 
     LABEL "F3":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f4 
     LABEL "F4":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f5 
     LABEL "F5":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f6 
     LABEL "F6":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f7 
     LABEL "F7":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f8 
     LABEL "F8":U 
     SIZE 11 BY 1.46.

DEFINE BUTTON f9 
     LABEL "F9":U 
     SIZE 11 BY 1.46.

DEFINE VARIABLE v-ed-message AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 65 BY 1.5
     BGCOLOR 8 FONT 20 NO-UNDO.

DEFINE VARIABLE v-balance AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 39.5 BY 2.5
     FGCOLOR 4 FONT 30 NO-UNDO.

DEFINE VARIABLE v-card-num AS CHARACTER FORMAT "X(20)":U 
     LABEL "Карта" 
      VIEW-AS TEXT 
     SIZE 14 BY .58 NO-UNDO.

DEFINE VARIABLE v-chk-num AS CHARACTER FORMAT "X(256)":U 
     LABEL "Чек №" 
      VIEW-AS TEXT 
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-client-name AS CHARACTER FORMAT "X(40)":U 
     LABEL "Клиент" 
      VIEW-AS TEXT 
     SIZE 34 BY .58 NO-UNDO.

DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
      VIEW-AS TEXT 
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-disc-pay AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Скидка" 
      VIEW-AS TEXT 
     SIZE 8.38 BY .67 NO-UNDO.

DEFINE VARIABLE v-discount AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Скидка" 
      VIEW-AS TEXT 
     SIZE 8.38 BY .67 NO-UNDO.

DEFINE VARIABLE v-dop-mess AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 30 BY .67 NO-UNDO.

DEFINE VARIABLE v-label-balance AS CHARACTER FORMAT "X(20)":U 
      VIEW-AS TEXT 
     SIZE 10 BY 2
     FONT 28 NO-UNDO.

DEFINE VARIABLE v-mode-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 12 BY .79
     FGCOLOR 4 FONT 1 NO-UNDO.

DEFINE VARIABLE v-payment AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Оплата" 
      VIEW-AS TEXT 
     SIZE 8.38 BY .67 NO-UNDO.

DEFINE VARIABLE v-src-input AS CHARACTER FORMAT "X(45)":U 
     VIEW-AS FILL-IN 
     SIZE 24.13 BY 1.21
     BGCOLOR 8 FONT 28 NO-UNDO.

DEFINE VARIABLE v-src-label AS CHARACTER FORMAT "X(55)":U 
      VIEW-AS TEXT 
     SIZE 28.5 BY .67
     FONT 6 NO-UNDO.

DEFINE VARIABLE v-time AS CHARACTER FORMAT "X(8)":U INITIAL "0" 
      VIEW-AS TEXT 
     SIZE 5.38 BY .67 NO-UNDO.

DEFINE VARIABLE v-total AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Итого" 
      VIEW-AS TEXT 
     SIZE 8.38 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 1.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 14 BY 1.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 65 BY .88.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.5 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-line FOR 
      bufbr_tt-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-line C-Win _FREEFORM
  QUERY br-line DISPLAY
      bufbr_tt-line.src        COLUMN-LABEL "Код"             FORMAT "x(16)":U  WIDTH 10
    bufbr_tt-line.line-name    COLUMN-LABEL "Товар/Оплата"  FORMAT "x(40)":U  WIDTH 18
    substring(bufbr_tt-line.qnty-str,6) @ bufbr_tt-line.qnty-str    COLUMN-LABEL "Кол-во"        FORMAT "x(11)":U  WIDTH 9
    substring(bufbr_tt-line.price-str,5) @ bufbr_tt-line.price-str   COLUMN-LABEL "Цена"          FORMAT "x(20)":U  WIDTH 9
    bufbr_tt-line.summ-netto-rub   COLUMN-LABEL "Сумма"         FORMAT "->>,>>>,>>9.99":U WIDTH 10
    bufbr_tt-line.summ-discont-rub COLUMN-LABEL "Скидка"        FORMAT "->>,>>>,>>9.99":U WIDTH 6
    bufbr_tt-line.summ-brutto  COLUMN-LABEL "Стоим. б/с"    FORMAT "->>,>>>,>>9.99":U WIDTH 10
    bufbr_tt-line.num          COLUMN-LABEL "№"             FORMAT ">>9":U           WIDTH 5
    bufbr_tt-line.line-seller-name COLUMN-LABEL "Продавец" FORMAT "x(20)":U          WIDTH 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 65 BY 11.29
         FONT 25 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     v-src-label AT ROW 3 COL 3.5 NO-LABEL WIDGET-ID 104
     v-date AT ROW 19.29 COL 62.38 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     v-ed-message AT ROW 1 COL 65 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
     v-mode-name AT ROW 19.21 COL 1.5 NO-LABEL WIDGET-ID 96
     v-label-balance AT ROW 16.75 COL 16 NO-LABEL WIDGET-ID 80
     v-card-num AT ROW 15.58 COL 4.38 COLON-ALIGNED WIDGET-ID 70
     v-client-name AT ROW 15.58 COL 29.5 COLON-ALIGNED WIDGET-ID 72
     v-chk-num AT ROW 19.29 COL 17 COLON-ALIGNED WIDGET-ID 68
     v-src-input AT ROW 2.67 COL 30.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     f1 AT ROW 2.54 COL 57.5 WIDGET-ID 4
     br-line AT ROW 4.08 COL 1 WIDGET-ID 200
     f2 AT ROW 2.5 COL 66.5 WIDGET-ID 6
     f3 AT ROW 4 COL 66.5 WIDGET-ID 8
     f4 AT ROW 5.5 COL 66.5 WIDGET-ID 10
     f5 AT ROW 7 COL 66.5 WIDGET-ID 12
     f6 AT ROW 8.54 COL 66.5 WIDGET-ID 14
     f7 AT ROW 10.04 COL 66.5 WIDGET-ID 16
     f8 AT ROW 11.54 COL 66.5 WIDGET-ID 18
     f9 AT ROW 13.04 COL 66.5 WIDGET-ID 20
     f10 AT ROW 14.54 COL 66.5 WIDGET-ID 22
     f11 AT ROW 16.04 COL 66.5 WIDGET-ID 24
     f12 AT ROW 17.54 COL 66.5 WIDGET-ID 26
     v-balance AT ROW 16.5 COL 26.5 NO-LABEL WIDGET-ID 38
     v-time AT ROW 19.29 COL 72 NO-LABEL WIDGET-ID 62
     v-total AT ROW 16.33 COL 14.38 RIGHT-ALIGNED WIDGET-ID 42
     v-discount AT ROW 16.92 COL 5 COLON-ALIGNED WIDGET-ID 44
     v-payment AT ROW 17.79 COL 5 COLON-ALIGNED WIDGET-ID 46
     b-exit AT ROW 1 COL 66.5 WIDGET-ID 82
     v-disc-pay AT ROW 18.38 COL 5 COLON-ALIGNED WIDGET-ID 112
     v-dop-mess AT ROW 19.29 COL 31.5 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     RECT-1 AT ROW 19.13 COL 1 WIDGET-ID 34
     RECT-4 AT ROW 19.13 COL 64 WIDGET-ID 84
     RECT-5 AT ROW 15.46 COL 1 WIDGET-ID 92
     RECT-6 AT ROW 19.13 COL 32.5 WIDGET-ID 110
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 77 BY 19.17
         FONT 24 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,Dfields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Касса IBS TH POS"
         HEIGHT             = 19.17
         WIDTH              = 77
         MAX-HEIGHT         = 19.17
         MAX-WIDTH          = 77.5
         VIRTUAL-HEIGHT     = 19.17
         VIRTUAL-WIDTH      = 77.5
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-C-Win:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-line f1 DEFAULT-FRAME */
ASSIGN 
       br-line:NUM-LOCKED-COLUMNS IN FRAME DEFAULT-FRAME     = 2.

/* SETTINGS FOR FILL-IN v-balance IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
ASSIGN 
       v-balance:AUTO-RESIZE IN FRAME DEFAULT-FRAME      = TRUE.

ASSIGN 
       v-card-num:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       v-chk-num:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       v-client-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       v-date:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       v-dop-mess:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR EDITOR v-ed-message IN FRAME DEFAULT-FRAME
   ALIGN-R                                                              */
ASSIGN 
       v-ed-message:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN v-label-balance IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
ASSIGN 
       v-label-balance:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN v-mode-name IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
ASSIGN 
       v-mode-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN v-src-label IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-time IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-total IN FRAME DEFAULT-FRAME
   ALIGN-R                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-line
/* Query rebuild information for BROWSE br-line
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bufbr_tt-line.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-line */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

/* OCX BINARY:FILENAME is: exe\wrx\gbl\maincash.wrx */

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME DEFAULT-FRAME:HANDLE
       ROW             = 18.75
       COLUMN          = 73.5
       HEIGHT          = 1.25
       WIDTH           = 4
       WIDGET-ID       = 60
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */
      CtrlFrame:MOVE-AFTER(f11:HANDLE IN FRAME DEFAULT-FRAME).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Касса IBS TH POS */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */

   RUN rule-run        IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT KEYLABEL(LASTKEY), INPUT {&th-pos-keyboard},   OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   ASSIGN
      v-src-input = "":U
   .

   RUN Post_Enable_Ui IN THIS-PROCEDURE.
   RETURN no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Касса IBS TH POS */
DO:
  /* This event will close the window and terminate the procedure.  */
  IF v-cd-mode = {&cd-mode-ready} then APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Касса IBS TH POS */
DO:
   define variable v-delta-x    as decimal      no-undo.
   define variable v-delta-y    as decimal      no-undo.
   define variable v-prp-x    as decimal      no-undo.
   define variable v-prp-y    as decimal      no-undo.

   define variable ii    as integer      no-undo.
   define variable v-hcol    as handle      no-undo.
   /* определение минимального размера экрана */
/*не допускаем изменение экрана меньше минимального размера*/
   if {&window-name} :WIDTH-CHARS < {&m-width}
   then do:
      assign
      {&window-name} :WIDTH-CHARS = {&m-width}
      .
   end.
   if {&window-name} :HEIGHT-CHARS < {&m-height}
   then do:
      assign
      {&window-name} :HEIGHT-CHARS = {&m-height}
      .
   end.
   /*определяем коэффициент изменения*/
   assign
      v-delta-x = (frame {&frame-name} :WIDTH-PIXELS  - {&window-name} :WIDTH-PIXELS )
      v-delta-y = (frame {&frame-name} :HEIGHT-PIXELS - {&window-name} :HEIGHT-PIXELS)
      v-prp-x = ({&window-name} :WIDTH-PIXELS / frame {&frame-name} :WIDTH-PIXELS )
      v-prp-y = ({&window-name} :HEIGHT-PIXELS / frame {&frame-name} :HEIGHT-PIXELS ) .

    /*При увеличении размеров окна, размеры фрэйма изменяем  до масштабирования внутренностей*/
   if v-prp-x >= 1 then assign
      frame {&frame-name} :WIDTH-PIXELS          = {&window-name} :WIDTH-PIXELS
      frame {&frame-name} :virtual-width-PIXELS  = {&window-name} :WIDTH-PIXELS.
   if v-prp-y >= 1 then assign
           frame {&frame-name} :HEIGHT-PIXELS          = {&window-name} :HEIGHT-PIXELS
           frame {&frame-name} :virtual-HEIGHT-PIXELS  = {&window-name} :HEIGHT-PIXELS
   .

   define variable v-widget   as handle       no-undo.
   assign
      v-widget = FRAME {&frame-name}:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
   .

   DO WHILE  VALID-HANDLE(v-widget)
   :
      CASE v-widget:TYPE:
      OTHERWISE do:
              assign
               v-widget :WIDTH-PIXELS  = v-widget :WIDTH-PIXELS  * v-prp-x
               v-widget :HEIGHT-PIXELS = v-widget :HEIGHT-PIXELS * v-prp-y
               v-widget :x  = v-widget :x  * v-prp-x
               v-widget :y = v-widget :y * v-prp-y

            .

      end.
      END CASE.
      assign
         v-widget = v-widget:NEXT-SIBLING
      .
   END.
/* при уменьшении размеров окна, размеры фрэйма изменяем после масштабирования внутренностей */
   if v-prp-x < 1 then assign
      frame {&frame-name}:virtual-width-PIXELS    = {&window-name} :WIDTH-PIXELS
      frame {&frame-name} :WIDTH-PIXELS           = {&window-name} :WIDTH-PIXELS
       .

   if v-prp-y < 1 then assign
          frame {&frame-name} :virtual-HEIGHT-PIXELS  = {&window-name} :HEIGHT-PIXELS
          frame {&frame-name} :HEIGHT-PIXELS          = {&window-name} :HEIGHT-PIXELS
             .

/* Переопределение шрифтов*/
&scope set-fonts   ~
 FRAME ~{&frame-name~}:font = ~{&f_frame_~{&screen-size~}~}. ~
br-line:font =     ~{&f_br-line_~{&screen-size~}~}. ~
v-balance:font =   ~{&f_balance_~{&screen-size~}~}. ~
v-src-label:font = ~{&f-src-label_~{&screen-size~}~}. ~
v-src-input:font = ~{&f_src_~{&screen-size~}~}. ~
v-mode-name:font  = ~{&f_mode_~{&screen-size~}~}. ~
v-font-ed-msgs_big   = ~{&f_ed-msgs_big_~{&screen-size~}~}. ~
v-font-ed-msgs_small = ~{&f_ed-msgs_small_~{&screen-size~}~}. ~
v-font-br-line       = ~{&f_br-line_~{&screen-size~}~}. ~
v-font-br-line_bold  = ~{&f_br-line_bold_~{&screen-size~}~}. ~
v-label-balance:font = ~{&f-src-label_~{&screen-size~}~}. ~
br-line:ROW-HEIGHT-PIXELS = ~{&f_br-line-row_~{&screen-size~}~}.

if   {&window-name} :WIDTH-CHARS >= 130
   and   {&window-name} :HEIGHT-CHARS >= 28
then do:
&scope screen-size  15
{&set-fonts}
end.
else if   {&window-name} :WIDTH-CHARS >= 107
   and   {&window-name} :HEIGHT-CHARS >= 20
then do:
&scope screen-size  14
{&set-fonts}
end.
else do:
 &scope screen-size  12
{&set-fonts}
end.
/*Перепрорисовывем сообщение, чтобы изменить шрифт и обновляем броуз*/
run p_ed-msgs(input v-ed-message:screen-value, input ?).
br-line:refresh() no-error.


   /*масштабирование колонок в браузере*/
   def var v-hb as handle no-undo.
   def var v-colwdt as dec no-undo.
   do ii = 1 to br-line:num-columns:
    v-hb = br-line:GET-BROWSE-COLUMN(ii).
    v-hb:WIDTH-PIXELS = v-hb:WIDTH-PIXELS * v-prp-x.
    v-hb:COLUMN-FONT = 24.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit C-Win
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Выход */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
   apply "ENTRY":U TO v-src-input.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-line
&Scoped-define SELF-NAME br-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-line C-Win
ON ROW-DISPLAY OF br-line IN FRAME DEFAULT-FRAME
DO:

  IF bufbr_tt-line.type = 1
  THEN DO:
    assign
      bufbr_tt-line.num             :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.line-name       :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-netto-rub  :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-discont-rub:font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.src             :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.qnty-str        :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.price-str       :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-brutto     :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.line-seller-name:font in browse br-line = v-font-br-line_bold
     .
     bufbr_tt-line.src:screen-value in browse br-line = '':U.
  END.
  ELSE DO:
    assign
      bufbr_tt-line.num             :font in browse br-line = v-font-br-line
      bufbr_tt-line.line-name       :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-netto-rub  :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-discont-rub:font in browse br-line = v-font-br-line
      bufbr_tt-line.src             :font in browse br-line = v-font-br-line
      bufbr_tt-line.qnty-str        :font in browse br-line = v-font-br-line
      bufbr_tt-line.price-str       :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-brutto     :font in browse br-line = v-font-br-line
      bufbr_tt-line.line-seller-name:font in browse br-line = v-font-br-line
    .
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-line C-Win
ON VALUE-CHANGED OF br-line IN FRAME DEFAULT-FRAME
DO:
   assign
      v-curr-num = bufbr_tt-line.num
      v-curr-type = bufbr_tt-line.type
   .
   RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame C-Win OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  None required for OCX.
  Notes:
------------------------------------------------------------------------------*/
define variable v-old-cd-mode    as character    no-undo.
define variable v-old-cd-submode    as character    no-undo.
define variable v-old-ok    as logical      no-undo.
define variable v-message-local    as character    no-undo.
define variable v-ok-local          as logical      no-undo.

   ASSIGN
      v-time = STRING(TIME, "HH:MM:SS":U)
      v-date = TODAY
      v-old-cd-mode    = v-cd-mode
      v-old-cd-submode = v-cd-submode
      v-old-ok         = v-ok
   .

   IF TIME modulo 1 = 0
   THEN DO:
      /*
      output stream slip-out to "time.txt" append.
      export stream slip-out STRING(time, "HH:MM:SS") "time".
      OUTPUT STREAM slip-out CLOSE.
      */

      DISPLAY v-time v-date
      WITH FRAME  {&frame-name}.
      /* !!!
      assign
         v-src-input
      .
      */
   END.
   /*
   RUN get-time-close IN THIS-PROCEDURE (OUTPUT v-time-chk-close) .

   IF  v-cd-mode = {&cd-mode-ready}
   AND ( v-time-chk-close > 10 )
   AND NOT p-emul
   THEN DO:
      { gbl/disp-str.i
         v-disp-message-1
         v-disp-message-2
         v-message-local
         v-ok-local
      }
      RUN reset-time-close IN THIS-PROCEDURE .
      /*
      output stream slip-out to "time.txt" append.
      export stream slip-out STRING(time, "HH:MM:SS") "reset".
      OUTPUT STREAM slip-out CLOSE.
      */
   END.
*/
     /*
   IF TIME modulo 5 = 0
   THEN DO:
      RUN cd-context ( INPUT-OUTPUT v-cd-mode
                     , INPUT-OUTPUT v-cd-submode
                     , output v-message
                     , output v-ok
                     ) .
      /*
      output stream slip-out to "time.txt" append.
      export stream slip-out STRING(time, "HH:MM:SS") "context".
      OUTPUT STREAM slip-out CLOSE.
      */
      IF v-ok <> v-old-ok
      OR v-old-cd-mode    <> v-cd-mode
      OR v-old-cd-submode <> v-cd-submode
      THEN DO:

         IF  v-old-cd-mode = {&cd-mode-block}
         AND v-old-cd-mode <> v-cd-mode
         THEN DO:

            ASSIGN
               v-message = CHR(10)
            .
         END.
         /*
         output stream slip-out to "time.txt" append.
         export stream slip-out STRING(time, "HH:MM:SS") "chr".
         OUTPUT STREAM slip-out CLOSE.
         */
         /*
         RUN enable_UI IN THIS-PROCEDURE.
         */
         RUN post_enable_UI IN THIS-PROCEDURE.
      END.
   end.
     */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f1 C-Win
ON CHOOSE OF f1 IN FRAME DEFAULT-FRAME /* F1 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
   return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f10 C-Win
ON CHOOSE OF f10 IN FRAME DEFAULT-FRAME /* F10 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f11 C-Win
ON CHOOSE OF f11 IN FRAME DEFAULT-FRAME /* F11 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f12 C-Win
ON CHOOSE OF f12 IN FRAME DEFAULT-FRAME /* F12 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f2 C-Win
ON CHOOSE OF f2 IN FRAME DEFAULT-FRAME /* F2 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f3 C-Win
ON CHOOSE OF f3 IN FRAME DEFAULT-FRAME /* F3 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f4 C-Win
ON CHOOSE OF f4 IN FRAME DEFAULT-FRAME /* F4 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f5 C-Win
ON CHOOSE OF f5 IN FRAME DEFAULT-FRAME /* F5 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f6 C-Win
ON CHOOSE OF f6 IN FRAME DEFAULT-FRAME /* F6 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f7 C-Win
ON CHOOSE OF f7 IN FRAME DEFAULT-FRAME /* F7 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f8 C-Win
ON CHOOSE OF f8 IN FRAME DEFAULT-FRAME /* F8 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f9 C-Win
ON CHOOSE OF f9 IN FRAME DEFAULT-FRAME /* F9 */
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT {&SELF-NAME}:name, INPUT {&th-pos-screen}, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cash C-Win
ON CHOOSE OF MENU-ITEM m_cash /* Справка по АРМу "Кассир" */
DO:
  message
  "Навигация между элементами интерфейса осуществляется табуляцией," skip
  "по браузеру – клавишами «Вверх/Вниз/Влево/Вправо»." skip(2)
  "Функциональные клавиши на PC-клавиатуре:" skip
  "Enter  - ввод данных" skip
  "Esc    - выход из режима/системы" skip
  "Del    - удаление выделенной линии чека" skip
  "*      - перевод кассы в режим ввода количества"  skip
  "F1     - нажатие на кнопку выбора (кнопка рядом с полем для ввода). Открывает справочник, соответствующий состоянию кассы."  skip
  "F2-F12 - соответсвуют функциональным кнопкам на экране"
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_version
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_version C-Win
ON CHOOSE OF MENU-ITEM m_version /* О программе */
DO:
   run gbl/version.p no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-ed-message
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-ed-message C-Win
ON ENTRY OF v-ed-message IN FRAME DEFAULT-FRAME
DO:
  { gbl/stdbtn.i b-exit }
  undo, return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-src-input
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-src-input C-Win
ON ENTER OF v-src-input IN FRAME DEFAULT-FRAME
DO:
  def var v-md as char no-undo .
  def var v-egalite as int initial 0  no-undo .
  def var v-widget-id as char no-undo .
   ASSIGN
      v-src-input
   .
   if substr(v-src-input,1,1) = {&StartSentinel} and 
      substr(v-src-input,length(v-src-input),1) = {&EndSentinel} 
      then
   do:
     if v-cd-mode = {&cd-mode-sale}
           OR v-cd-mode = {&cd-mode-ret} then 
     do:
      assign
         v-md = substitute("&1.&2", v-cd-mode, v-cd-submode)
      .
     end.
     else 
     do:
      assign
         v-md = v-cd-mode
      .
     end.
     
     v-egalite = index(v-src-input,"=") .
     
     if v-egalite = 0 then
     do:
       v-egalite = length(v-src-input)   .
     end.
     v-src-input = substr(v-src-input,2,v-egalite - 2) .
     
     if v-cd-submode = {&cd-submode-goods} then
     do:
      find first buf_layout-elem-rule no-lock where
                 buf_layout-elem-rule.layout-id = v-layout-id-screen
             and buf_layout-elem-rule.mode-id   = v-md    
             and buf_layout-elem-rule.rule_id = {&RuleSetDiscountCard}
             no-error.
      if avail buf_layout-elem-rule then
      do:        
       v-widget-id  = buf_layout-elem-rule.widget-id .
       
       RUN rule-run        IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                             , INPUT-OUTPUT v-cd-submode
                                             , INPUT v-widget-id
                                             , INPUT {&th-pos-screen}
                                             , OUTPUT v-message
                                             , OUTPUT v-ok ) NO-ERROR.
       IF ERROR-STATUS:ERROR  THEN 
       DO:
        ASSIGN
         v-ok = FALSE
         .
       END.
       RUN enable_UI IN THIS-PROCEDURE.
       RUN post_enable_UI IN THIS-PROCEDURE.
 
      end .  /* if avail layout-elem-rule  */
     end.    /* v-cd-submode = {&cd-submode-goods}*/
   end. 
   ASSIGN
      v-src-input  = IF INDEX(v-src-input, ".":U) > 0 THEN REPLACE(v-src-input,",":U,"":U)
                                                      ELSE REPLACE(v-src-input,",":U,".":U)
      v-delta-time = ETIME - v-etime
      v-etime      = 0
   .

   IF  v-src-input <> "":U
   /*OR  v-cd-mode   =  "0":U {&cd-mode-ready}*/
   THEN DO:
      RUN set-input-time IN THIS-PROCEDURE ( INPUT v-delta-time, OUTPUT v-err-message, OUTPUT v-ok ).
      RUN set-src IN THIS-PROCEDURE ( INPUT v-src-input,  OUTPUT v-err-message, OUTPUT v-ok ).
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT {&SELF-NAME}:name
                                     , INPUT {&th-pos-screen}
                                     , OUTPUT v-message
                                     , OUTPUT v-ok ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         ASSIGN
            v-ok = FALSE
         .
      END.

      ASSIGN
         v-src-input = "":U
      .
      RUN Enable_Ui IN THIS-PROCEDURE.
      RUN Post_Enable_Ui IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-src-input C-Win
ON VALUE-CHANGED OF v-src-input IN FRAME DEFAULT-FRAME
DO:
  IF (v-etime = 0)
  THEN DO:
  assign
     v-etime = ETIME
  .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.


on any-key OF {&WINDOW-NAME} ANYWHERE /*FRAME {&frame-name} , v-src-input , br-line */  
do :
   DO
   WITH FRAME {&frame-name}
   :
   define variable v-old-cd-mode    as character    no-undo.
   define variable v-old-cd-submode    as character    no-undo.
   define variable v-key    as character    no-undo.
   define variable v-c-src-input as char  no-undo .
   assign v-key = string(lastkey)
          v-ok = no .
 
   if v-layout-id <> '' then  /*  id keyboard */
   do:
     find first buf_layout-elem-rule no-lock
               where buf_layout-elem-rule.layout-id = v-layout-id
               and buf_layout-elem-rule.widget-id = v-key
               no-error.
     if avail buf_layout-elem-rule then
     do:
         v-c-src-input = input v-src-input .
         /* если выбор */
         if buf_layout-elem-rule.rule_id = {&ruleChoiceFromRefBook} then
         do:
            RUN set-src IN THIS-PROCEDURE ( INPUT v-c-src-input,  
                                            OUTPUT v-err-message, 
                                            OUTPUT v-ok ) .
         end.
         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT v-key
                                         , INPUT {&th-pos-keyboard}
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR
                                        .
                                                    
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            .
         END.
         
         if v-ok = no then 
            assign 
               v-src-input = ""
               v-c-src-input = "" .

         if buf_layout-elem-rule.rule_id = {&ruleChoiceFromRefBook} then
         do:
           v-src-input = '' .
         end.
           RUN enable_UI IN THIS-PROCEDURE .
           RUN post_enable_UI IN THIS-PROCEDURE .
           if v-c-src-input <> '' then
           do:
             assign
               v-src-input = v-c-src-input .
            RUN set-src IN THIS-PROCEDURE ( INPUT v-src-input,  
                                            OUTPUT v-err-message, 
                                            OUTPUT v-ok ) .
            RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                             , INPUT-OUTPUT v-cd-submode
                                             , INPUT "v-src-input"
                                             , INPUT {&th-pos-screen}
                                             , OUTPUT v-message
                                             , OUTPUT v-ok ) NO-ERROR.
             IF ERROR-STATUS:ERROR
             THEN DO:
                 ASSIGN
                   v-ok = FALSE
                    .
             END.
             assign v-src-input = "" .
             RUN Enable_Ui IN THIS-PROCEDURE.
             RUN Post_Enable_Ui IN THIS-PROCEDURE.
           end.
           Return no-apply .
           
      
     end.          
   end.    /* if keyboard */

   assign
      v-key = KEYLABEL(LASTKEY)
   .

   CASE v-key:
      WHEN "CURSOR-UP":U OR
      WHEN "CURSOR-DOWN":U
      THEN DO:

         APPLY "ENTRY":U TO br-line.
         IF NOT AVAILABLE bufbr_tt-line
         THEN DO:
            IF CAN-FIND (tt-line NO-LOCK)
            THEN DO:
               query br-line :handle :get-first( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
         END.
         ELSE DO:
            IF v-key = "CURSOR-UP":U
            THEN DO:
               query br-line :handle :get-prev( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
            ELSE DO:
               query br-line :handle :get-next( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
            CASE bufbr_tt-line.type:
               WHEN 0
               THEN DO:
                  assign
                     v-message                = SUBSTITUTE  ( "&1 &2x&3"
                                                            , bufbr_tt-line.line-name
                                                            , bufbr_tt-line.qnty
                                                            , bufbr_tt-line.price
                                                            )
                  .
               END.
               WHEN 1
               THEN DO:
                  assign
                     v-message                = SUBSTITUTE  ( "&1 &2"
                                                            , bufbr_tt-line.line-name
                                                            , bufbr_tt-line.summ-netto
                                                            )
                  .
               END.
               OTHERWISE DO:
               END.
            END CASE.
         END.
      END.
      WHEN "CURSOR-LEFT":U
      THEN DO:
         APPLY "CURSOR-LEFT"  TO br-line .
      END.
      WHEN "CURSOR-RIGHT":U
      THEN DO:
         APPLY "CURSOR-RIGHT"  TO br-line .
      END.
      WHEN "*":U
      THEN DO:
      END.  
      WHEN "F1":U OR
      WHEN "F2":U OR
      WHEN "F3":U OR
      WHEN "F4":U OR
      WHEN "F5":U OR
      WHEN "F6":U OR
      WHEN "F7":U OR
      WHEN "F8":U OR
      WHEN "F9":U OR
      WHEN "F10":U OR
      WHEN "F11":U OR
      WHEN "F12":U OR
      WHEN "CTRL-S":U
      THEN DO:
      
         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT v-key
                                         , INPUT {&th-pos-screen}
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            .
         END.

         RUN enable_UI IN THIS-PROCEDURE.
         RUN post_enable_UI IN THIS-PROCEDURE.
      END. 
      WHEN "ENTER":U
      THEN DO:
         IF focus:name = "v-src-input":U
         THEN DO:
                 
            APPLY "LEAVE":U TO v-src-input.
            RETURN NO-APPLY.
         END.
         IF focus:name = "v-ed-message":U
         THEN DO:
            RETURN NO-APPLY.
         END.


         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT focus:name
                                         , INPUT {&th-pos-keyboard}
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            . 
         END.

         RUN enable_UI IN THIS-PROCEDURE.
         RUN post_enable_UI IN THIS-PROCEDURE.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   END.
end.

on "*":U OF FRAME {&frame-name} , v-src-input , br-line do :

   DO
   WITH FRAME {&frame-name}
   :
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT "*":U
                                     , INPUT {&th-pos-keyboard}
                                     , OUTPUT v-message
                                     , OUTPUT v-ok
                                     ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
            ASSIGN
               v-ok = FALSE
            .
      END.

      RUN enable_UI IN THIS-PROCEDURE.
      RUN post_enable_UI IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.


on "DEL":U OF FRAME {&frame-name} , v-src-input , br-line do :

   DO
   WITH FRAME {&frame-name}
   :
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT "DEL":U
                                     , INPUT {&th-pos-keyboard}
                                     , OUTPUT v-message
                                     , OUTPUT v-ok
                                     ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
            ASSIGN
               v-ok = FALSE
            .
      END.

      RUN enable_UI IN THIS-PROCEDURE.
      RUN post_enable_UI IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.

{ cmp/showinf.i  }
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   IF p-emul
   THEN DO:
      run set-emul-mode IN THIS-PROCEDURE (OUTPUT v-message, OUTPUT v-ok).
   END.

   define buffer buf_user-account      for ub.user-account .

   FIND FIRST buf_user-account
        where buf_user-account.user-id = p-user-id
        no-lock
        .

   ASSIGN
      v-psn-name = SUBSTITUTE ( "&1 &2&3&4&5":U
                              , buf_user-account.last-name
                              , SUBSTRING(buf_user-account.first-name, 1, 1)
                              , IF buf_user-account.first-name <> "":U THEN ".":U ELSE "":U
                              , SUBSTRING(buf_user-account.second-name, 1, 1)
                              , IF buf_user-account.first-name <> "":U
                                AND buf_user-account.second-name <> "":U THEN ".":U ELSE "":U
                              )
   .

   assign
      {&WINDOW-NAME} :max-width          = session :width-chars
      {&WINDOW-NAME} :virtual-width      = session :width-chars
      {&WINDOW-NAME} :max-height         = session :height-chars
      {&WINDOW-NAME} :virtual-height     = session :height-chars
   .

    RUN set-cashier IN THIS-PROCEDURE  ( output v-message
                                       , output v-ok
                                       ) .
    if v-ok = no then
    do:
    
      return .                                  
    
    end .  

    DO
    TRANSACTION
    :
      FIND FIRST buf_cash-desk
           WHERE buf_cash-desk.db-num   = v-cntxt-db-num
             AND buf_cash-desk.obj-code = v-cntxt-obj-code
             AND buf_cash-desk.pos-type = {&cd-type-ibs-th}
             AND buf_cash-desk.cash-num = p-cash-num
           EXCLUSIVE-LOCK
           NO-WAIT
           NO-ERROR
           .
      IF NOT AVAILABLE buf_cash-desk
      THEN DO:
         IF LOCKED buf_cash-desk
         THEN DO:
            message
               SUBSTITUTE("Касса &1 уже работает", p-cash-num)
               skip
            view-as alert-box information.
            RETURN.
         END.
         ELSE DO:
            message
               "Касса №" p-cash-num
               skip "на объекте" v-cntxt-obj-type v-cntxt-obj-code
               SKIP "не найдена"
            view-as alert-box information.
            RETURN.
         END.
      END.
      assign
        v-fr-type = buf_cash-desk.fr-type 
        .

      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
            and buf_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_fisreg}
            and buf_cash-desk-attr.attr-code = {&cda-IBS-TH_fisreg_com-port}
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign 
         v-com-port = buf_cash-desk-attr.attr-value-character
      .    
     end.    

      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
  and buf_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_devices}
  and buf_cash-desk-attr.attr-code = {&cda-IBS-TH_devices_keyboard-layout-id}
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign 
         v-layout-id = buf_cash-desk-attr.attr-value-character
      .    
     end.   


      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
  and buf_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_interface}
  and buf_cash-desk-attr.attr-code = {&cda-IBS-TH_interface_screen-layout-id}
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign 
         v-layout-id-screen = buf_cash-desk-attr.attr-value-character
      .    
     end.   

    END.




    { gbl/getcntxt.i get }


    { str/libthpos_create-context.i
      parparentproc
      ?
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-serial-code
      v-r-b
      v-base-code
      no-error
    }
   IF ERROR-STATUS:ERROR
   THEN DO:
      message  "Ошибка инициализации кассы IBS TH №"   p-cash-num
         skip "магазина №"                             v-cntxt-obj-code
         skip "БД №"                                   v-cntxt-db-num
         skip RETURN-VALUE
         SKIP error-status :get-message(1)
         SKIP error-status :get-message(2)
         SKIP error-status :get-message(3)
      view-as alert-box information.
      QUIT.
   END.

   run set-cd-base-code in this-procedure (INPUT v-base-code, OUTPUT v-message, OUTPUT v-ok) .


   IF ERROR-STATUS:ERROR
   OR NOT v-ok
   THEN DO:
      assign
         v-ok = no
         v-message = v-err-message
      .
      message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
      view-as alert-box information.
      RETURN NO-APPLY.
   END.

   IF NOT p-emul
   THEN DO:
      { gbl/fr-init.i
      p-cash-num
      v-cntxt-obj-code
      v-serial-code
      v-fr-type
      v-com-port
      v-fr-model
      v-err-message
      v-ok
      NO-ERROR
      }
      
      IF ERROR-STATUS:ERROR
      OR NOT v-ok
      THEN DO:
         message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
         view-as alert-box information.
         RETURN.
      END.
      IF NOT v-ok
      THEN DO:
         assign
            v-message = v-err-message
         .
      END.
        

      RUN set-context-serial ( INPUT v-serial-code
                             , INPUT v-fr-model
                             , OUTPUT v-message
                             , OUTPUT v-ok
                             ) .

   END.

   RUN set-cd-prop IN THIS-PROCEDURE (OUTPUT v-message, OUTPUT v-ok).
   IF NOT v-ok
   THEN DO:
      message
         v-message
         skip
      view-as alert-box error.
      RETURN.
   END.


   IF NOT p-emul
   THEN DO:
      RUN get-display-adv IN THIS-PROCEDURE  ( OUTPUT v-disp-message-1
                                             , OUTPUT v-disp-message-2
                                             , OUTPUT v-message
                                             , OUTPUT v-ok
                                             ) .
      /* Инициализация модуля Сбербанка */
      /* !!! v-cashless-system */
      { gbl/sb-init.i
         v-cashless-system
         v-err-message
         v-ok
         NO-ERROR
      }
      IF ERROR-STATUS:ERROR
      OR NOT v-ok
      THEN DO:
 /*        assign
            v-ed-message:FGCOLOR  IN FRAME {&frame-name} = RED_COLOR
         . */
         message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
         view-as alert-box information.
         RETURN NO-APPLY.
      END.


      IF v-customer-display-plug
      THEN DO:
         { gbl/disp-init.i
            v-disp-message-1
            v-disp-message-2
            v-customer-display-type
            v-customer-display-port
            v-message
            v-ok
            NO-ERROR
         }
         IF ERROR-STATUS:ERROR
         OR NOT v-ok
         THEN DO:
/*            assign
               v-ed-message:FGCOLOR  IN FRAME {&frame-name} = RED_COLOR
            .  */
            message
            SKIP RETURN-VALUE
            SKIP trim(error-status :get-message(1))
            SKIP trim(error-status :get-message(2))
            SKIP trim(error-status :get-message(3))
            SKIP v-err-message
            view-as alert-box information.
            RETURN NO-APPLY.
         END.
      END.
   END.


   RUN fill-tt IN THIS-PROCEDURE.

   RUN cd-context ( INPUt-OUTPUT v-cd-mode
                  , INPUt-output v-cd-submode
                  , output v-message
                  , output v-ok
                  ) .

   RUN annul-lost-chk IN THIS-PROCEDURE ( output v-message
                                        , output v-ok
                                        ) .
   IF NOT v-ok
   THEN DO:
      message
         v-message
         skip
      view-as alert-box error.
   END.

   RUN enable_UI IN THIS-PROCEDURE.
  /*Максимизация окна.       ПОСАДИТЬ НА ПАРАМЕТР               */
   {&window-name} :HEIGHT-CHARS = {&window-name} :FULL-HEIGHT-CHARS.
   {&window-name} :width-CHARS = {&window-name} :FULL-width-CHARS.
   {&window-name} :X = session:WORK-AREA-X.
   {&window-name} :Y = session:WORK-AREA-Y.

  /*  apply "WINDOW-MAXIMIZED":U to c-win.    */
   apply "window-resized":U to c-win.
   RUN post_enable_UI IN THIS-PROCEDURE.

   { gbl/disp-str.i
      v-cashier-name
      '':U
      v-err-message
      v-ok
      NO-ERROR
   }

   IF NOT THIS-PROCEDURE:PERSISTENT THEN
      WAIT-FOR CLOSE OF THIS-PROCEDURE FOCUS v-src-input.

   RELEASE buf_cash-desk.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load C-Win  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "exe\wrx\gbl\maincash.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "exe\wrx\gbl\maincash.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  RUN control_load.
  DISPLAY v-src-label v-date v-ed-message v-mode-name v-label-balance v-card-num 
          v-client-name v-chk-num v-src-input v-balance v-time v-total 
          v-discount v-payment v-disc-pay v-dop-mess 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE v-src-label v-date v-ed-message v-mode-name v-label-balance v-card-num 
         v-client-name v-chk-num v-src-input f1 br-line f2 f3 f4 f5 f6 f7 f8 f9 
         f10 f11 f12 v-balance v-time v-total v-discount v-payment b-exit 
         v-disc-pay v-dop-mess RECT-1 RECT-4 RECT-5 RECT-6 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI C-Win 
PROCEDURE post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, LEAVE
:
   define variable v-ok-local          as logical      no-undo.
   define variable v-widget      as handle       no-undo.
   define variable v-label       as character    no-undo.
   define variable v-tooltip       as character    no-undo.
   define variable v-cd-subname  as character    no-undo.
   define variable v-ccc    as character    no-undo.
   define variable v-message-local    as character    no-undo.
   /*
   define variable v-disc-type    as character  /* INIT {&discnt-v-pcnt} */  no-undo. /* per - процентная, abs - абсолютная */
   */

   /*
   output stream slip-out to "time.txt" append.
   export stream slip-out STRING(time, "HH:MM:SS") "post".
   OUTPUT STREAM slip-out CLOSE.
   */

   define buffer buf_tt-line     for tt-line .
   RUN get-mode-name IN THIS-PROCEDURE ( INPUT v-cd-mode
                                     , INPUT v-cd-submode
                                     , OUTPUT v-mode-name
                                     , OUTPUT v-ok-local
                                     ) .
    define variable v-title as character no-undo .
    define variable v-version-name as character no-undo .
    define variable v-version-name-str as character no-undo .
    define variable v-host-str         as character no-undo .
    define variable v-obj-str          as character no-undo .
    define variable v-user-str         as character no-undo .
    define variable v-db-num-str       as character no-undo .
    define variable v-user-id-str      as character no-undo .
    define variable v-process-id-str   as character no-undo .

    run gbl/getvers.p
      (output v-version-name
      ) .
    assign
      v-version-name-str = substitute("ITH &1", v-version-name)
    .

    assign
      v-db-num-str = substitute("БД: &1", v-cntxt-db-num)
    .

    assign
      v-user-id-str = substitute("Кассир: &1", v-psn-name)
    .

    assign
      v-host-str = substitute("Фирма: &1 &2"
                              ,{&cmp}
                              ,v-cntxt-host-code-obj
                              )
    .
    assign
      v-obj-str = substitute("Объект: &1 &2"
                            ,v-cntxt-obj-type
                            ,v-cntxt-obj-code
                            )
    .

    assign
      v-title = substitute('Касса IBS TH POS &1, &2, &3, &4, &5, &6, PID &7':U
                          ,p-cash-num /* номер кассы */
                          ,v-db-num-str /* БД           */
                          ,v-host-str /* Фирма        */
                          ,v-obj-str /* Объект       */
                          ,v-user-id-str /* Пользователь */
                          ,v-version-name-str /* Версия       */
                          ,p-pid
                          )
    .

   ASSIGN
      C-Win:TITLE = v-title
   .
   RUN get-submode-name IN THIS-PROCEDURE ( INPUT v-cd-mode
                                       , INPUT v-cd-submode
                                       , OUTPUT v-cd-subname
                                       , OUTPUT v-ok-local
                                       ) .
   ASSIGN
      v-src-label:screen-value IN FRAME {&frame-name} = f_src-label(v-cd-subname)
   .
   RUN get-chk-num  IN THIS-PROCEDURE  ( OUTPUT v-chk-num
                                       , OUTPUT v-ok-local
                                       ) .
   run get-aux-mess in this-procedure (
                                          output v-dop-mess
                                        , OUTPUT v-ok-local
                                        ).
   RUN get-card-num ( OUTPUT v-card-num
                    , OUTPUT v-client-name
                    , OUTPUT v-ok-local
                    ) .
   IF v-cd-mode = {&cd-mode-sale}
   OR v-cd-mode = {&cd-mode-ret}
   THEN DO:
      RUN summ-for-pay  ( INPUt-OUTPUT v-cd-mode
                        , INPUt-output v-cd-submode
                        , output v-message-local
                        , output v-ok-local
                        ) .
   END.

   IF  v-cd-mode <> {&cd-mode-ready}
   AND v-cd-mode <> {&cd-mode-block}
   THEN DO:
      RUN get-all-summ (  OUTPUT v-total
                        , OUTPUT v-summ-nett
                        , OUTPUT v-discount
                        , OUTPUT v-payment
                        , OUTPUT v-summ-fr-1
                        , OUTPUT v-summ-for-pay
                        , OUTPUT v-disc-pay
                        , OUTPUT v-message-local
                        , OUTPUT v-ok-local
                        ) .
   END.
   IF v-summ-for-pay = 0
   THEN DO:
      ASSIGN
         v-summ-for-pay =  IF v-cd-mode = {&cd-mode-ret} THEN v-payment - v-summ-nett
                                                         ELSE v-summ-nett - v-payment
      .
   END.
   IF  v-payment = 0
   AND v-cd-mode = {&cd-mode-ready}
   THEN DO:
      ASSIGN
         v-summ-for-pay = 0
      .
   END.

   ASSIGN
      v-label-balance = IF v-cd-mode = {&cd-mode-ret} THEN IF (v-summ-for-pay) > 0 THEN "Сдача:" ELSE "К оплате:"
                                                      ELSE IF (v-summ-for-pay) < 0 THEN "Сдача:" ELSE "К оплате:"
      v-balance = ABS(v-summ-for-pay)
   .

   RUN get-curr-num ( OUTPUT v-curr-type
                    , OUTPUT v-curr-num
                    , OUTPUT v-message-local
                    , OUTPUT v-ok-local
                    ) .
   IF v-curr-num <> 0
   THEN DO:
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num
           AND buf_tt-line.type = v-curr-type
         no-lock
         no-error
         .
      IF AVAILABLE buf_tt-line
      THEN DO:
         reposition br-line to rowid rowid( buf_tt-line ) no-error.
      END.
   END.

   /*
   IF  v-cd-mode = {&cd-mode-ret}
   AND v-summ-fr-1 < v-total
   THEN DO:
      ASSIGN
         v-message = SUBSTITUTE("Суммы в ДЯ &1 недостаточно для выплаты", v-summ-fr-1)
      .
   END.
   */

   CASE v-cd-mode:
      WHEN {&cd-mode-sale} OR
      WHEN {&cd-mode-ret} THEN DO:
         IF v-cd-submode = {&cd-submode-price}
         AND AVAILABLE bufbr_tt-line
         THEN DO:
            ASSIGN
               v-src-input = trim(STRING(bufbr_tt-line.price, "->>>>>>>>9.99"))
            .
         END.
      END.
      /*
         ASSIGN
            v-label-balance = IF (v-payment - v-total) < 0 THEN "Сдача:" ELSE "К выплате:"
            v-balance = ABS(v-payment - v-total)
         .
      */
      OTHERWISE DO:
      END.
   END CASE.
   run get-disc-type IN THIS-PROCEDURE ( OUTPUT v-disc-type
                                       , OUTPUT v-message-local
                                       , OUTPUT v-ok-local
                                       ) .
   CASE v-disc-type:
      WHEN {&discnt-v-sum}
      THEN DO:
         assign
            v-src-label:screen-value IN FRAME {&frame-name} = f_src-label("Сумма скидки")
         .
      END.
      WHEN {&discnt-v-pcnt}
      THEN DO:
         assign
            v-src-label:screen-value IN FRAME {&frame-name} = f_src-label("Процент скидки")
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
    
   
   DISPLAY
      v-src-input
      v-chk-num
      v-dop-mess
      v-card-num
      v-client-name
      v-payment
      v-total
      v-balance
      v-discount
      v-disc-pay
      v-label-balance
      v-mode-name
   WITH FRAME {&frame-name}.


   IF v-message <> "":U
   THEN DO:
      run p_ed-msgs(input v-message, input v-ok) no-error.
/*      ASSIGN
         v-ed-message = f_ed-msg(v-message)
      .
      IF v-ok
      THEN DO:
         assign
            v-ed-message:FGCOLOR  IN FRAME {&frame-name} = BLACK_COLOR
         .
      END.
      ELSE DO:
         assign
            v-ed-message:FGCOLOR  IN FRAME {&frame-name} = RED_COLOR
         .
      END.
  /*    IF LENGTH(v-ed-message) < 40
      OR INDEX(v-ed-message, {&new-line}) > 0
      THEN v-ed-message:FONT  IN FRAME {&frame-name} = 9 .
      ELSE v-ed-message:FONT  IN FRAME {&frame-name} = 1 .   */

      DISPLAY
         v-ed-message
      WITH FRAME {&frame-name}.  */
   END.
   assign
      v-widget = FRAME {&frame-name}:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
   .

   DO WHILE  VALID-HANDLE(v-widget)
   :

      IF  v-widget:TYPE = "BUTTON":U
      THEN DO:
         RUN key-enable IN THIS-PROCEDURE ( INPUT v-cd-mode
                                          , INPUT v-cd-submode
                                          , INPUT v-widget:NAME
                                          , OUTPUT v-ok-local
                                          , OUTPUT v-label
                                          , OUTPUT v-tooltip
                                          ) NO-ERROR.
                                          
         
         IF v-ok-local
         AND ERROR-STATUS:ERROR = FALSE
         THEN DO:
            ASSIGN
               v-widget:SENSITIVE = TRUE
               v-widget:LABEL = v-label
               v-widget:tooltip = v-tooltip
            .
         END.
         ELSE DO:
            ASSIGN
               v-widget:SENSITIVE = FALSE
               v-widget:LABEL     = v-widget:NAME
            .
         END.
      END.

      assign
         v-widget = v-widget:NEXT-SIBLING
      .
   END.

end.  /* do on error */

IF ERROR-STATUS:ERROR
THEN DO:
   message
      202 v-message-local
      skip RETURN-VALUE
      SKIP error-status :get-message(1)
   view-as alert-box error.
END.
apply 'entry':U to v-src-input.

END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_ed-msgs C-Win 
PROCEDURE p_ed-msgs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-msgs as character no-undo.
define input parameter p-ok  as logical no-undo.

v-ed-message:screen-value in frame {&frame-name} = p-msgs.
/*Если ошибка, то красным цветом */
if p-ok then v-ed-message:FGCOLOR in frame {&frame-name} = Black_COLOR.
else if p-ok  = no then  v-ed-message:FGCOLOR in frame {&frame-name} = RED_COLOR.
/*Если p-err = ?, то цвет остается прежним. Это используется при перерисовке экрана */

/*Если сообщение большое, то меняем шрифт на меньший*/
 IF LENGTH(p-msgs) > {&g-ed-msgs}
      OR INDEX(v-ed-message, {&new-line}) > 0
 THEN v-ed-message:FONT  = v-font-ed-msgs_small.
 else v-ed-message:FONT  = v-font-ed-msgs_big .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f_src-label C-Win 
FUNCTION f_src-label RETURNS CHARACTER
  ( vf-src-label as char ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
if  vf-src-label > "" then do:
    return fill(" ":U,38 - length(vf-src-label)) + vf-src-label  + ':':U.
end.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

