&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавить/редактировать границы торговой наценки на группы товаров

Автор: Чернова Светлана Александровна
Дата создания: 06/26/09
Author: Svetlana Chernova
Creation date: 06/26/09


Автор1: Бахтадзе Наталья Викторовна

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
define input parameter p-node-code like ub.gds-grp-obj.node-code no-undo.
define input parameter  p-option as character no-undo.
/*может быть {&company} {&g___object} "object-list":U */
define input parameter  p-host-code like ub.sysconf.host-code no-undo.
define input parameter  p-obj-type like ub.clients.obj-type no-undo.
define input parameter  p-obj-code like ub.clients.obj-code no-undo.

define output parameter p-rec as recid no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Границы торговой наценки на группы товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ ref/grplib.i   }
{ ref/grpobj.i   }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/ggoattr.i  }
{ gbl/objsrv.i }
{ ref/gds-attr.i }

define variable v-host-name        like ub.clients.obj-name no-undo.
define variable v-full-name        as character  no-undo .
define variable v-old-value        as character  no-undo .
define variable v-value-changed    as logical    no-undo init no.
define variable v-marg-min         as decimal    no-undo .
define variable v-marg-max         as decimal    no-undo .
define variable v-increase-pc      as decimal    no-undo .
define variable v-round-method     as character  no-undo .
define variable v-base             as decimal    no-undo .
define variable v-cli-type         as character  no-undo .
define variable v-cli-code         as integer    no-undo .
define variable v-cli-name         as character  no-undo .
define variable v-notcorr          as character  no-undo .
define variable v-type             as character  no-undo .
define variable v-alc-min-price    as character  no-undo .
define variable v-marg-pr-paraf    as character  no-undo .
define variable v-level-dis-attr   as character  no-undo .
define variable v-no-inc-auto-rep  as character  no-undo . 
define variable v-ban-sales-via-cd as character  no-undo .
define variable v-table-menu       as character  no-undo .
define variable v-alchol           as character  no-undo .
define variable v-mark             as character  no-undo .
define variable v-sum-grp          as integer    no-undo .
define variable v-mark-type        as character  no-undo .
define variable ix                 as integer    no-undo .

/* Temp-Table and Buffer definitions                                    */
define temp-table tt-level-dis-attr no-undo
   field attr-code  like global-state-attr.attr-code
   field attr-value like global-state-attr.attr-value
   index pi            attr-value descending
   index pi1 is unique attr-value
   attr-code .

DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE goods
   field emrc as character.

define temp-table tt-emc-price no-undo 
   field obj-code as integer 
   field obj-type as character
   field gds-name as character 
   field gds-code as integer
   field price    as decimal
   .

define temp-table temp_obj-list no-undo
   field host-code like ub.sysconf.host-code
   field obj-type  as character
   field obj-code  as integer
   index pi is primary unique obj-type obj-code
   .
define buffer buf_gds-grp-obj for ub.gds-grp-obj.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-level-dis

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-level-dis-attr temp_obj-list

/* Definitions for BROWSE br-level-dis                                  */
&Scoped-define FIELDS-IN-QUERY-br-level-dis tt-level-dis-attr.attr-code tt-level-dis-attr.attr-value   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-level-dis   
&Scoped-define SELF-NAME br-level-dis
&Scoped-define QUERY-STRING-br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-level-dis OPEN QUERY {&SELF-NAME} FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-level-dis tt-level-dis-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-level-dis tt-level-dis-attr


/* Definitions for BROWSE BR-temp_obj-list                              */
&Scoped-define FIELDS-IN-QUERY-BR-temp_obj-list temp_obj-list.obj-type + {&space-char} + string(temp_obj-list.obj-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-temp_obj-list   
&Scoped-define SELF-NAME BR-temp_obj-list
&Scoped-define QUERY-STRING-BR-temp_obj-list FOR EACH temp_obj-list
&Scoped-define OPEN-QUERY-BR-temp_obj-list OPEN QUERY {&SELF-NAME} FOR EACH temp_obj-list.
&Scoped-define TABLES-IN-QUERY-BR-temp_obj-list temp_obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-temp_obj-list temp_obj-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-level-dis}~
    ~{&OPEN-QUERY-BR-temp_obj-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help l-income-cli l-marg ~
l-marg-pr-paraf l-rmethod l-increase-pc l-notcorr l-alc-min-price ~
l-level-dis n-no-inc-auto-rep n-ban-sales-via-cd BR-temp_obj-list RS-option ~
n-alchol n-mark fill-sum-grp r-sum-grp fi-increase-pc c-mark-type c-emrc-type ~
fi-marg-min fi-marg-max S-round-method F-base fi-cli-type fi-cli-code r-cli ~
fi-cli-name fi-notcorr fi-alc-min-price br-level-dis fi-marg-pr-paraf B-add ~
B-chg B-del fi-grp-name n-increase-pc l-min l-max n-rmethod n-income-cli ~
n-notcorr n-alc-min-price n-level-dis 
&Scoped-Define DISPLAYED-OBJECTS n-no-inc-auto-rep n-ban-sales-via-cd ~
RS-option n-alchol n-mark fill-sum-grp fi-increase-pc c-mark-type n-marg ~
fi-marg-min fi-marg-max S-round-method F-base fi-cli-type fi-cli-code c-emrc-type~
fi-cli-name fi-notcorr fi-alc-min-price n-marg-pr-paraf fi-marg-pr-paraf ~
fi-grp-name n-increase-pc l-min l-max n-rmethod n-income-cli n-notcorr ~
n-alc-min-price n-level-dis 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-cli-name Dialog-Frame
FUNCTION func-cli-name RETURNS CHARACTER
  ( p-type as char, p-code as int  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

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

DEFINE BUTTON r-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1 TOOLTIP "Для заказов ОО".

DEFINE BUTTON r-sum-grp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1 TOOLTIP "Группа товаров на кассе".

DEFINE VARIABLE c-mark-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип маркировки" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "1","1"
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE c-emrc-type      AS CHARACTER FORMAT "X(256)":U 
   LABEL "Тип ЕМЦ" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "1","1"
   DROP-DOWN-LIST
   SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE fi-notcorr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "Да","yes",
                     "Нет","no",
                     "?","?",
                     " ",""
     DROP-DOWN-LIST
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE n-marg AS CHARACTER INITIAL "Диапазон торговой наценки %" 
     VIEW-AS EDITOR
     SIZE 19.63 BY 2.17
     FGCOLOR 5  NO-UNDO.

DEFINE VARIABLE n-marg-pr-paraf AS CHARACTER INITIAL "Наценка к цене внутреннего прихода партии %" 
     VIEW-AS EDITOR
     SIZE 17.5 BY 2.5
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE F-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-alc-min-price AS CHARACTER FORMAT "X(255)" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1 TOOLTIP "Для алкоголя, %сод.спирта,мин.цена;%сод.спирта,мин.цена"
     FGCOLOR 4 .

DEFINE VARIABLE fi-cli-code AS INTEGER FORMAT ">>>>>" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 TOOLTIP "Для заказов ОО".

DEFINE VARIABLE fi-cli-name AS CHARACTER FORMAT "X(20)" 
     VIEW-AS FILL-IN 
     SIZE 28 BY 1 TOOLTIP "Для заказов ОО"
     FGCOLOR 4 .

DEFINE VARIABLE fi-cli-type AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.13 BY 1 TOOLTIP "Для заказов ОО".

DEFINE VARIABLE fi-grp-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 57.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-increase-pc AS DECIMAL FORMAT "->>>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE fi-marg-max AS DECIMAL FORMAT "->>>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE fi-marg-min AS DECIMAL FORMAT "->>>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE fi-marg-pr-paraf AS DECIMAL FORMAT "->>>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1.

DEFINE VARIABLE fill-sum-grp AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Группа товаров на кассе" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE l-max AS CHARACTER FORMAT "X(256)":U INITIAL "Макс" 
      VIEW-AS TEXT 
     SIZE 6.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-min AS CHARACTER FORMAT "X(256)":U INITIAL "Мин" 
      VIEW-AS TEXT 
     SIZE 6.5 BY .67 NO-UNDO.

DEFINE VARIABLE n-alc-min-price AS CHARACTER FORMAT "X(256)":U INITIAL "Правила определения мин.цены алкоголя" 
      VIEW-AS TEXT 
     SIZE 37.38 BY 1 TOOLTIP "Для алкоголя"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-income-cli AS CHARACTER FORMAT "X(256)":U INITIAL "Внутренний поставщик" 
      VIEW-AS TEXT 
     SIZE 20.13 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-increase-pc AS CHARACTER FORMAT "X(256)":U INITIAL "Торговая наценка %" 
      VIEW-AS TEXT 
     SIZE 19.75 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-level-dis AS CHARACTER FORMAT "X(256)":U INITIAL "Границы пороговой наценки" 
      VIEW-AS TEXT 
     SIZE 27 BY .67
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-notcorr AS CHARACTER FORMAT "X(256)":U INITIAL "Запрет на кор-ку рассчитанного заказа" 
      VIEW-AS TEXT 
     SIZE 37.38 BY 1 TOOLTIP "Для заказов ОП"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-rmethod AS CHARACTER FORMAT "X(256)":U INITIAL "Метод округления" 
      VIEW-AS TEXT 
     SIZE 16.13 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE IMAGE l-alc-min-price
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1.

DEFINE IMAGE l-income-cli
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1.

DEFINE IMAGE l-increase-pc
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.

DEFINE IMAGE l-level-dis
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1 TOOLTIP "Для пороговых наценок".

DEFINE IMAGE l-marg
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.

DEFINE IMAGE l-marg-pr-paraf
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.

DEFINE IMAGE l-notcorr
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1 TOOLTIP "Для заказов ОП".

DEFINE IMAGE l-rmethod
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.

DEFINE VARIABLE RS-option AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 38.13 BY 3.71 NO-UNDO.

DEFINE VARIABLE S-round-method AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
     SIZE 20.38 BY 6.04 NO-UNDO.

DEFINE VARIABLE n-alchol AS LOGICAL INITIAL no 
     LABEL "По умолчанию алкоголь" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-ban-sales-via-cd AS LOGICAL INITIAL no 
     LABEL "Запрет продажи через кассу" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-mark AS LOGICAL INITIAL no 
     LABEL "По умолчанию обязательная маркировка" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE n-no-inc-auto-rep AS LOGICAL INITIAL no 
     LABEL "Не учитывать в автоматической отчетности" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY 1
     FGCOLOR 3  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-level-dis FOR 
      tt-level-dis-attr SCROLLING.

DEFINE QUERY BR-temp_obj-list FOR 
      temp_obj-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-level-dis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-level-dis Dialog-Frame _FREEFORM
  QUERY br-level-dis NO-LOCK DISPLAY
      tt-level-dis-attr.attr-code COLUMN-LABEL "Интервал" FORMAT "X(15)":U
      tt-level-dis-attr.attr-value COLUMN-LABEL "% Наценки" FORMAT "X(15)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 31.5 BY 4.5 FIT-LAST-COLUMN.

DEFINE BROWSE BR-temp_obj-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-temp_obj-list Dialog-Frame _FREEFORM
  QUERY BR-temp_obj-list DISPLAY
      temp_obj-list.obj-type  + {&space-char} + string(temp_obj-list.obj-code)
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 15 BY 9.58
         TITLE "Список объектов".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 57
     n-no-inc-auto-rep AT ROW 3 COL 65
     n-ban-sales-via-cd AT ROW 4 COL 65
     BR-temp_obj-list AT ROW 4.13 COL 47.63
     RS-option AT ROW 4.17 COL 2 NO-LABEL
     n-alchol AT ROW 6 COL 65
     n-mark AT ROW 7 COL 65
     fill-sum-grp AT ROW 8 COL 88.38 COLON-ALIGNED
     r-sum-grp AT ROW 8 COL 101.13
     fi-increase-pc AT ROW 8.67 COL 31.88 RIGHT-ALIGNED NO-LABEL
     c-mark-type AT ROW 9.33 COL 79 COLON-ALIGNED WIDGET-ID 50
     c-EMRC-type AT ROW 10.5 COL 79 COLON-ALIGNED WIDGET-ID 50
     n-marg AT ROW 10.29 COL 2.13 NO-LABEL
     fi-marg-min AT ROW 10.38 COL 32.13 RIGHT-ALIGNED NO-LABEL
     fi-marg-max AT ROW 11.38 COL 32.13 RIGHT-ALIGNED NO-LABEL
     S-round-method AT ROW 13.08 COL 23.13 NO-LABEL
     F-base AT ROW 15.38 COL 42.63 COLON-ALIGNED NO-LABEL
     fi-cli-type AT ROW 19.42 COL 24.88 RIGHT-ALIGNED NO-LABEL
     fi-cli-code AT ROW 19.42 COL 31.25 RIGHT-ALIGNED NO-LABEL
     r-cli AT ROW 19.42 COL 32.5
     fi-cli-name AT ROW 19.42 COL 62.38 RIGHT-ALIGNED NO-LABEL
     fi-notcorr AT ROW 20.75 COL 36.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     fi-alc-min-price AT ROW 21.75 COL 62.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 12
     br-level-dis AT ROW 24 COL 1.13 WIDGET-ID 200
     n-marg-pr-paraf AT ROW 24 COL 36.5 NO-LABEL WIDGET-ID 44
     fi-marg-pr-paraf AT ROW 24 COL 62 RIGHT-ALIGNED NO-LABEL
     B-add AT ROW 28.54 COL 2 WIDGET-ID 12
     B-chg AT ROW 28.54 COL 12 WIDGET-ID 14
     B-del AT ROW 28.54 COL 22 WIDGET-ID 16
     fi-grp-name AT ROW 3.08 COL 2 COLON-ALIGNED NO-LABEL
     n-increase-pc AT ROW 8.63 COL 2 NO-LABEL
     l-min AT ROW 10.25 COL 35.5 COLON-ALIGNED NO-LABEL
     l-max AT ROW 11.5 COL 35.5 COLON-ALIGNED NO-LABEL
     n-rmethod AT ROW 13.08 COL 5.88 NO-LABEL
     n-income-cli AT ROW 19.42 COL 1.13 NO-LABEL
     n-notcorr AT ROW 20.63 COL 1.13 NO-LABEL WIDGET-ID 6
     n-alc-min-price AT ROW 21.75 COL 1 NO-LABEL WIDGET-ID 10
     n-level-dis AT ROW 23 COL 1.13 NO-LABEL
     l-income-cli AT ROW 19.42 COL 64
     l-marg AT ROW 10.71 COL 34.75
     l-marg-pr-paraf AT ROW 24 COL 64
     l-rmethod AT ROW 13.17 COL 44.13
     l-increase-pc AT ROW 8.63 COL 34.75
     l-notcorr AT ROW 20.75 COL 46.5 WIDGET-ID 4
     l-alc-min-price AT ROW 21.75 COL 64 WIDGET-ID 16
     l-level-dis AT ROW 23 COL 28 WIDGET-ID 42
     SPACE(79.12) SKIP(5.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры на объектах для группы товаров"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-temp_obj-list n-ban-sales-via-cd Dialog-Frame */
/* BROWSE-TAB br-level-dis fi-alc-min-price Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-alc-min-price IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-cli-code IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-cli-name IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-cli-type IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-increase-pc IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-marg-max IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-marg-min IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fi-marg-pr-paraf IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN n-alc-min-price IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-income-cli IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-increase-pc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-level-dis IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR EDITOR n-marg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       n-marg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR n-marg-pr-paraf IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       n-marg-pr-paraf:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN n-notcorr IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-rmethod IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-level-dis
/* Query rebuild information for BROWSE br-level-dis
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-level-dis */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-temp_obj-list
/* Query rebuild information for BROWSE BR-temp_obj-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_obj-list.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-temp_obj-list */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Параметры на объектах для группы товаров */
DO:
  run proc-b-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры на объектах для группы товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO :

 define variable v-pole1 as character no-undo .
 define variable v-pole2 as character no-undo .

  run str/lvldsc.w ( input-output v-pole1 , input-output v-pole2 ) .
  create tt-level-dis-attr.
  assign
    tt-level-dis-attr.attr-code  = v-pole1
    tt-level-dis-attr.attr-value = v-pole2
  no-error
  .
  if error-status :error then do:
    message
      "Пороговая наценка," skip
      "где интервал " v-pole1 skip
      "наценка " v-pole2 "," skip
      "уже есть."
    view-as alert-box error.
    delete tt-level-dis-attr.
  end.
  else do:
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-level-dis
&Scoped-define SELF-NAME br-level-dis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-level-dis Dialog-Frame
ON RIGHT-MOUSE-CLICK OF br-level-dis IN FRAME Dialog-Frame
DO:
    assign
    n-level-dis:fgcolor = 3
    l-level-dis:visible = true
    .
    for each tt-level-dis-attr.
      delete tt-level-dis-attr.
    end.
    hide
    br-level-dis
    B-add
    B-chg
    B-del
    in frame {&frame-name}.
    ENABLE l-level-dis
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END*/

ON RIGHT-MOUSE-CLICK OF fi-marg-pr-paraf IN FRAME Dialog-Frame
DO:
    assign
    n-marg-pr-paraf:fgcolor = 15
    l-marg-pr-paraf:visible = true
    v-marg-pr-paraf = '':U
    .
    hide
    fi-marg-pr-paraf
    in frame {&frame-name}.
    ENABLE l-marg-pr-paraf
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END*/

ON ENTRY OF fi-marg-max IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-max:screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-alc-min-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-alc-min-price Dialog-Frame
ON ENTRY OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-alc-min-price :screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-alc-min-price Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
  assign
    n-alc-min-price:fgcolor = 3
    l-alc-min-price:visible = true
    v-alc-min-price = '':U
    .
    hide
    FI-alc-min-price
    in frame {&frame-name}.
    ENABLE l-alc-min-price
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-alc-min-price Dialog-Frame
ON VALUE-CHANGED OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
  assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-alc-min-price :screen-value then no else yes )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-code Dialog-Frame
ON ENTRY OF fi-cli-code IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-cli-code:screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-code Dialog-Frame
ON LEAVE OF fi-cli-code IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-cli-code:screen-value then no else yes )
.
 run leave-proc-cli in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-code Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-cli-code IN FRAME Dialog-Frame
DO:
    assign
    n-income-cli:fgcolor = 3
    l-income-cli:visible = true
    v-cli-type = '':U
    v-cli-code = 0
    .
    hide
    FI-cli-type
    FI-cli-code
    fi-cli-name
    r-cli
    in frame {&frame-name}.
    ENABLE l-income-cli
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-type Dialog-Frame
ON ENTRY OF fi-cli-type IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-cli-type :screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-type Dialog-Frame
ON LEAVE OF fi-cli-type IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-cli-type :screen-value then no else yes )
.

/*  if lookup(fi-cli-type :screen-value, {&stock_shop} ) = 0 then
    apply "choose"  to r-cli in frame {&frame-name} .
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cli-type Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-cli-type IN FRAME Dialog-Frame
DO:
    assign
    n-income-cli:fgcolor = 3
    l-income-cli:visible = true
    v-cli-type = '':U
    v-cli-code = 0
    .
    hide
    FI-cli-type
    FI-cli-code
    r-cli
    fi-cli-name
    in frame {&frame-name}.
    ENABLE l-income-cli
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-increase-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-increase-pc Dialog-Frame
ON ENTRY OF fi-increase-pc IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-max:screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-increase-pc Dialog-Frame
ON LEAVE OF fi-increase-pc IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-increase-pc:screen-value then no else yes )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-increase-pc Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-increase-pc IN FRAME Dialog-Frame
DO:
   if p-option = "global" then return no-apply.
    assign
    n-increase-pc:fgcolor = 15
    l-increase-pc:visible = true
    v-increase-pc = ?
    .
    hide
    fi-increase-pc
    in frame {&frame-name}.
    ENABLE l-increase-pc
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-marg-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-marg-max Dialog-Frame
ON LEAVE OF fi-marg-max IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-marg-max:screen-value then no else yes )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-marg-max Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-marg-max IN FRAME Dialog-Frame
DO:
    assign
    n-MARG:fgcolor = 15
    l-MARG:visible = true
    v-marg-min = ?
    v-marg-max = ?
    .
    hide
    FI-MARG-MIN
    FI-MARG-MAX
    in frame {&frame-name}.
    ENABLE l-marg
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-marg-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-marg-min Dialog-Frame
ON ENTRY OF fi-marg-min IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-min :screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-marg-min Dialog-Frame
ON LEAVE OF fi-marg-min IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-marg-min :screen-value then no else yes )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-marg-min Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-marg-min IN FRAME Dialog-Frame
DO:
    assign
    n-MARG:fgcolor = 15
    l-MARG:visible = true
    v-marg-min = ?
    v-marg-max = ?
    .
    hide
    FI-MARG-MIN
    FI-MARG-MAX
    in frame {&frame-name}.
    ENABLE l-marg
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-notcorr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-notcorr Dialog-Frame
ON ENTRY OF fi-notcorr IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-notcorr :screen-value
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-notcorr Dialog-Frame
ON RIGHT-MOUSE-CLICK OF fi-notcorr IN FRAME Dialog-Frame
DO:
  assign
    n-notcorr:fgcolor = 3
    l-notcorr:visible = true
    v-notcorr = '':U
    .
    hide
    FI-notcorr
    in frame {&frame-name}.
    ENABLE l-notcorr
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-notcorr Dialog-Frame
ON VALUE-CHANGED OF fi-notcorr IN FRAME Dialog-Frame
DO:
  assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-notcorr :screen-value then no else yes )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-alc-min-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-alc-min-price Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-alc-min-price IN FRAME Dialog-Frame
DO:
  IF l-alc-min-price:visible then do:
    assign
    n-alc-min-price:fgcolor = ?
    l-alc-min-price:visible = false.
    enable
    fi-alc-min-price
    with frame {&frame-name}.
    display
     fi-alc-min-price
    with frame {&frame-name}.
    APPLY "ENTRY" TO fi-alc-min-price.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-income-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-income-cli Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-income-cli IN FRAME Dialog-Frame
DO:
  IF l-income-cli:visible then do:
    assign
    n-income-cli:fgcolor = ?
    l-income-cli:visible = false.
    enable
    fi-cli-type
    fi-cli-code
    r-cli
    with frame {&frame-name}.
    display
    v-cli-type @ fi-cli-type
    v-cli-code @ fi-cli-code
    v-cli-name @ fi-cli-name
    with frame {&frame-name}.
    APPLY "ENTRY" TO fi-cli-type.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-increase-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-increase-pc Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME Dialog-Frame
DO:
  IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable fi-increase-pc with frame {&frame-name}.
    display v-increase-pc @ fi-increase-pc
        with frame {&frame-name}.
    APPLY "ENTRY" TO fi-increase-pc.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-level-dis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-level-dis Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-level-dis IN FRAME Dialog-Frame
DO:

  IF l-level-dis:visible then do:
    assign
    n-level-dis:fgcolor = ?
    l-level-dis:visible = false.
    enable
    br-level-dis
    B-add
    B-chg
    B-del
    with frame {&frame-name}.
    display
    br-level-dis
    B-add
    B-chg
    B-del
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-marg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-marg Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-marg IN FRAME Dialog-Frame
DO:
  IF l-marg:visible then do:
    assign
    n-marg:fgcolor = ?
    l-marg:visible = false.
    enable
    fi-marg-min
    fi-marg-max
    with frame {&frame-name}.
    display
    v-marg-min @ fi-marg-min
    v-marg-max @ fi-marg-max
    with frame {&frame-name}.
    APPLY "ENTRY" TO fi-MARG-MIN.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-marg-pr-paraf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-marg-pr-paraf Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-marg-pr-paraf IN FRAME Dialog-Frame
DO:
  IF l-marg-pr-paraf:visible then do:
    assign
    n-marg-pr-paraf:fgcolor = ?
    l-marg-pr-paraf:visible = false.
    enable
    fi-marg-pr-paraf
    with frame {&frame-name}.
    display
    fi-marg-pr-paraf
    v-marg-pr-paraf @ fi-marg-pr-paraf
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-notcorr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-notcorr Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-notcorr IN FRAME Dialog-Frame
DO:
  IF l-notcorr:visible then do:
    assign
    n-notcorr:fgcolor = ?
    l-notcorr:visible = false.
    enable
    fi-notcorr
    with frame {&frame-name}.
    display
     fi-notcorr
    with frame {&frame-name}.
    APPLY "ENTRY" TO fi-notcorr.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-rmethod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-rmethod Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-rmethod IN FRAME Dialog-Frame
DO:
  IF l-rmethod:visible then do:
    assign
    n-rmethod:fgcolor = ?
    l-rmethod:visible = false.
    enable
    s-round-method
    with frame {&frame-name}.
    assign
    s-round-method:screen-value = v-round-method.
    APPLY "ENTRY" TO s-round-method.
    APPLY "VALUE-CHANGED" to S-round-method.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME n-alchol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL n-alchol Dialog-Frame
ON VALUE-CHANGED OF n-alchol IN FRAME Dialog-Frame /* По умолчанию алкоголь */
DO:
  IF n-alchol:checked then do:
/*  n-alchol = logical(if v-alchol = "" then "no" else v-alchol).*/
      enable n-mark
      with frame {&frame-name}.
  end.
  else hide
    n-mark  in frame {&frame-name} 
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  /* 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sum-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sum-grp Dialog-Frame
ON CHOOSE OF r-sum-grp IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.

    run ref/sum-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      assign
      v-sum-grp = buf_sum-grp.grp-code
      .
    end.
    else v-sum-grp = 0 .
      fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON RIGHT-MOUSE-CLICK OF S-round-method IN FRAME Dialog-Frame
DO:
   if p-option = "global" then return no-apply.
    assign
    n-rmethod:fgcolor = 15
    l-rmethod:visible = true
    v-round-method = '':U
    .
    hide
    s-round-method
    f-base
    in frame {&frame-name}.
    ENABLE l-rmethod
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
  S-round-method
  .
  if lookup(S-round-method, {&pr-rounds-need-coef}) > 0 then do:
    display
    f-base
    with frame {&frame-name}.
    enable
    f-base
    with frame {&frame-name}.
  end.
  else do:
    hide
    f-base
    in frame {&frame-name}.
    disable
    f-base
    with frame {&frame-name}.
  end.
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
{ ref/ord-trgg.i cli fi- p- }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if NOT (p-mode = {&add-def} or p-mode = {&update} or p-mode = {&lookup}) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
        view-as alert-box ERROR.
        undo, return error.
    end.
  find first ub.gds-grp where
                ub.gds-grp.node-code = p-node-code no-error.
    if not avail ub.gds-grp then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-node-code" p-node-code
            view-as alert-box ERROR.
            undo, return error.
    end.
    run grplib-get-full-name in this-procedure( input p-node-code,
                                                                        output v-full-name) no-error.
  CASE p-option:
    when {&company} then do:
      find first ub.sysconf no-lock where
                  ub.sysconf.host-code = p-host-code no-error.
    if not avail ub.sysconf then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code" p-host-code
            view-as alert-box ERROR.
            undo, return error.
    end.
        find first ub.clients no-lock where
                  ub.clients.obj-type = {&cmp}
              AND ub.clients.obj-code = p-host-code.
    assign
      v-host-name = replace(ub.clients.obj-name, {&comma-char}, {&space-char}).
    end.

    when {&g___object} then do:
        find first ub.clients no-lock where
                  ub.clients.obj-type = p-obj-type
              AND ub.clients.obj-code = p-obj-code no-error.
    if not avail ub.clieNts then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-obj-type и/или p-obj-code host-code" p-obj-type p-obj-code
            view-as alert-box ERROR.
            undo, return error.
        end.
    end.

  END CASE.
  RUN FILL-TABLES IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then  do:
    undo, return error.
  end.
  RUN MYenable.
  run proc-load.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-attr Dialog-Frame
PROCEDURE create-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define input parameter v-min-marg           as decimal                  no-undo .
  define input parameter v-max-marg           as decimal                  no-undo .
  define input parameter v-increase-pc        like ub.gds-grp.increase-pc no-undo .
  define input parameter v-round-method       as character                no-undo .
  define input parameter v-base               as decimal                  no-undo .
  define input parameter v-cli-type           as character                no-undo .
  define input parameter v-cli-code           as integer                  no-undo .
  define input parameter v-notcorr            as character                no-undo .
  define input parameter v-alc-min-price      as character                no-undo .
  define input parameter v-marg-pr-paraf      as character                no-undo .
  define input parameter v-level-dis-attr     as character                no-undo .
  define input parameter v-no-inc-auto-rep    as character                no-undo .
  define input parameter v-ban-sales-via-cd   as character                no-undo .
  
  define input parameter v-alchol             as character                no-undo . 
  define input parameter v-mark               as character                no-undo . 
  define input parameter v-sum-grp            as character                no-undo .
  define input parameter v-mark-type          as character                no-undo .  
  define input parameter v-emrc-type          as character                no-undo .  
  
  DEFINE VARIABLE v-node-code  like ub.gds-grp.node-code  no-undo .
  DEFINE VARIABLE v-upper-code like ub.gds-grp.upper-code no-undo .
  DEFINE VARIABLE v-delete     as logical                 no-undo .
  DEFINE VARIABLE rid as recid no-undo.

define buffer buf_clients   for ub.clients.
if fi-cli-type:visible in frame  {&frame-name}  then do:
    if v-cli-type = ""
        then do:
          message "Не верно введен тип поставщика! "  view-as alert-box information .
          return error .
        end.


    if v-cli-code = 0
        then do:
          message "Не верно введен код поставщика! "  view-as alert-box information .
          return error .
        end.

    if not( v-cli-type = {&shop} or
      v-cli-type = {&stock} )
        then do:
          message "Не верно введен тип поставщика! Может быть только магазин или склад ! "  v-cli-type view-as alert-box information .
          return error .
        end.


  find first buf_clients no-lock
      where buf_clients.obj-type = v-cli-type
        and buf_clients.obj-code = v-cli-code
  no-error.
  if not available buf_clients
  then do:
    message "Такого " v-cli-type v-cli-code " нет в справочнике клиентов ! "   view-as alert-box information .
    return error .
  end.
end.



  if v-min-marg <> ? and
  v-min-marg > v-max-marg then do:
      message
      "Минимальная наценка не может быть больше максимальной. Наценки не могут быть заданы."
      view-as alert-box error.
      return error.

  end.
  if (v-min-marg = ? ) <> (v-max-marg = ?) then do:
    message
    "Нельзя задать только одну границу диапазона"
    view-as alert-box  error .
    return error .
  end.
  if v-min-marg = ? and v-max-marg = ? and v-increase-pc = ? and
     v-cli-type = "":U and v-cli-code = 0 and
    (v-round-method = "":U or v-round-method = ?) then do:
      message
      "Вы не задали ни торговую наценку, ни диапазон торговых наценок, ни метод округления"
      view-as alert-box error.
      return error.
  end.
  if v-increase-pc = ? and p-option = "global" then do:
    message
    "Нельзя запретить корневое значение торговой наценки"
    view-as alert-box error .
    return error.
  end.
  if lookup(v-round-method, {&pr-rounds-need-coef}) > 0 and
    v-base = 0 then do:
    message
    "Введите ненулевое значение коэффициента!"
    view-as alert-box error .
    return error.
  end.
  case p-option :
    when "global":U then do:
      assign
      v-node-code = ub.gds-grp.node-code
      v-upper-code = ub.gds-grp.upper-code
      .
      run ref/gdsgrp01.p (
              input {&update}
              ,input no /*p-silent*/
              ,input no /*p-get-node-code*/
              ,input no /*p-fill-tax-from-upper*/
              ,input-output  v-node-code
              ,input-output  v-upper-code
              ,input gds-grp.node-name
              ,input gds-grp.calc-method
              ,input v-increase-pc
              ,input v-round-method
              ,input v-base
              ,output rid
              ) no-error .
      run grp-obj-write in this-procedure (
            input p-node-code
          , input 0
          , input ""
          , input 0
          , input v-min-marg
          , input v-max-marg
          , input v-increase-pc
          , input gds-grp.calc-method
          , input v-round-method
          , input v-base
          , input v-cli-type
          , input v-cli-code
      ) no-error.
      if error-status :error then do:
        undo, return error.
      end.
      /* запись параметра */
      run ggoattr-write (
         input   p-node-code
        ,input   0
        ,input   ""
        ,input   0
        ,input   {&ggoattr-NotCorrOP}
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   0
        ,input   ""
        ,input   0
        ,input   {&ggoattr-alc-min-price}
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
/*      run ggoattr-write (*/
/*         input   p-node-code*/
/*        ,input   0*/
/*        ,input   ""*/
/*        ,input   0*/
/*        ,input   {&ggoattr-marg-pr-paraf}*/
/*        ,input   v-marg-pr-paraf*/
/*        ) no-error .*/
/*      if error-status :error then do:*/
/*        undo, return error.*/
/*      end.*/
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-marg-pr-paraf}
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-marg-pr-paraf}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-level-dis}
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-level-dis}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-no-inc-auto-rep}
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-no-inc-auto-rep}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-ban-sales-via-cd}
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-ban-sales-via-cd}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-sum-grp <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-sum-grps}
          ,input   v-sum-grp
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
       end.
       else do: 
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-sum-grps}
          ,output  v-sum-grp
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.  
      if v-mark-type <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-type}
          ,input   v-mark-type
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
       end.
       else do: 
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-type}
          ,output  v-mark-type
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.  

/*Проверка на товары в группе с другим ЕМЦ*/
               define buffer buf_goods-attr for ub.goods-attr .
               define buffer buf_goods      for ub.goods .
               define variable v-ask        as character no-undo .
               define variable v-price-emc  as decimal   no-undo .
               define variable v-value-emrc as character no-undo .
               define variable v-type-emrc  as character no-undo .     
               define variable v-del        as logical   no-undo .
               define variable choice       as integer   no-undo .
     
      
               empty temp-table tt-goods .
               for each buf_goods no-lock where buf_goods.grp-code = p-node-code:
                  run gds-attr-value (
                     input   buf_goods.gds-code
                     ,input   {&attr-emrc-type}
                     ,output   v-value-emrc
                     ,output   v-type-emrc
                     ) no-error .
                  if v-value-emrc <> v-emrc-type then 
                  do:   
                     create tt-goods .
                     buffer-copy buf_goods to tt-goods .
                     for first ub.Code where ub.Code.parent = "emc" and 
                        ub.Code.Code = v-value-emrc no-lock:
                        tt-goods.emrc = ub.Code.CodeName . 
                     end.
                  end.
               end.
               if can-find (first tt-goods) then 
               do:
                  run ref/emrc-mes.w (input parparentproc,
                     input table tt-goods,
                     output v-ask)  .
               end.
               case v-ask:
                  when "cancel" then 
                     do:
                        leave .
                     end.
                  when "true" then 
                     do:
                        for each tt-goods:
                           run gds-attr-delete IN THIS-PROCEDURE(
                              input tt-goods.gds-code
                              ,INPUT {&attr-emrc-type}
                              ,output v-del ) .
                        end.
                     end.
                  when "false" then 
                     do:
                     end.
               end case .
               find last ub.Code no-lock where ub.Code.parent = "emc" + {&delim-par} + v-emrc-type and  
                  ub.Code.status_ = {&bef-current-status-int} and ub.Code.code <= iso-date(today) no-error .
               if available (ub.Code) then 
               do:
                  run gbl/d-askw.w (
                     input "Вопрос"
                     ,input  "Проверить цены товара на соответствие ЕМЦ?"
                     ,input "|"
                     ,input "Да|Нет"
                     ,input "Установить ЕМЦ и провести проверку по всем объектам|Установить ЕМЦ без проверки"
                     ,input 1
                     ,input 2
                     ,output choice).
                  if choice = 1 then 
                  do:                     
                     v-price-emc = decimal(ub.Code.CodeValue) .
                     /* по всем магазинам */
                     for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj and 
                        buf_clients.obj-type = {&shop}: 
                        for each buf_goods no-lock where buf_goods.grp-code = p-node-code,
                           last ub.price-all no-lock where ub.price-all.gds-code = buf_goods.gds-code and 
                           ub.price-all.obj-code = buf_clients.obj-code and
                           ub.price-all.obj-type = buf_clients.obj-type and
                           ub.price-all.main-indication = 0 and
                           ub.price-all.type-price = 0:
                           if ub.price-all.price-sale < v-price-emc then 
                           do:
                              create tt-emc-price .            
                              assign
                                 tt-emc-price.gds-name = buf_goods.gds-name
                                 tt-emc-price.gds-code = buf_goods.gds-code
                                 tt-emc-price.price    = ub.price-all.price-sale
                                 tt-emc-price.obj-code = buf_clients.obj-code
                                 tt-emc-price.obj-type = buf_clients.obj-type
                                 .
                           end.
                        end.

                     end.
                     if can-find (first tt-emc-price) then 
                     do:
                        run print-list (input v-price-emc,
                           input table tt-emc-price).

                     end.    
                     else 
                     do:
                        message "Несоответствий товаров по ЕМЦ - не найдено."
                           view-as alert-box.
                     end.    
                  end.
               end.
               else 
               do:
                  if c-emrc-type <> "" then 
                  do:
                     find last ub.Code no-lock where ub.Code.parent = "emc" + {&delim-par} + v-emrc-type and  
                        ub.Code.status_ = {&bef-current-status-int} and ub.Code.code > iso-date(today) no-error .
                     if available (ub.Code) then 
                     do:
                        message "Для выбранного типа ЕМЦ установлено ограничение, которое станет активным только с " ub.Code.misc1
                           view-as alert-box.
                     end.
                     else 
                     do:
                        message "Для выбранного типа ЕМЦ не установлено ни одного значения." skip
                           "Для корректной работы добавьте актуальное значение ЕМЦ"
                           view-as alert-box.
                     end.
                  end.
               end.
               
               if v-emrc-type <> ""
                  then 
               do:      
                  run ggoattr-write (
                     input   p-node-code
                     ,input   0
                     ,input   ""
                     ,input   0
                     ,input   {&ggoattr-emrc-type}
                     ,input   v-emrc-type
                     ) no-error .
                  if error-status :error then 
                  do:
                     undo, return error.
                  end.
               end.
               else 
               do: 
                  run ggoattr-delete (
                     input   p-node-code
                     ,input   0
                     ,input   ""
                     ,input   0
                     ,input   {&ggoattr-emrc-type}
                     ,output  v-emrc-type
                     ) no-error .
                  if error-status :error then 
                  do:
                     undo, return error.
                  end.
               end.  
            end.
    when {&company} then do:
      run grp-obj-write in this-procedure (
              input p-node-code
            , input p-host-code
            , input ""
            , input 0
            , input v-min-marg
            , input v-max-marg
            , input v-increase-pc
            , input gds-grp.calc-method
            , input v-round-method
            , input v-base
            , input v-cli-type
            , input v-cli-code

        ) no-error.
      if error-status :error
      then do:
          undo, return error.
      end.
      /* запись параметра */
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   ""
        ,input   0
        ,input   {&ggoattr-NotCorrOP}
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   ""
        ,input   0
        ,input   {&ggoattr-alc-min-price}
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
/*      run ggoattr-write (*/
/*         input   p-node-code*/
/*        ,input   p-host-code*/
/*        ,input   ""*/
/*        ,input   0*/
/*        ,input   {&ggoattr-marg-pr-paraf}*/
/*        ,input   v-marg-pr-paraf*/
/*        ) no-error .*/
/*      if error-status :error then do:*/
/*        undo, return error.*/
/*      end.*/
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-marg-pr-paraf}
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-marg-pr-paraf}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-level-dis}
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-level-dis}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-no-inc-auto-rep}
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-no-inc-auto-rep}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-ban-sales-via-cd}
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   {&ggoattr-ban-sales-via-cd}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
            if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
    when {&g___object} then do:
    run grp-obj-write in this-procedure (
            input p-node-code
          , input p-host-code
          , input p-obj-type
          , input p-obj-code
          , input v-min-marg
          , input v-max-marg
          , input v-increase-pc
          , input gds-grp.calc-method
          , input v-round-method
          , input v-base
          , input v-cli-type
          , input v-cli-code
      ) no-error.
      if error-status :error
      then do:
          undo, return error.
      end.
      /* запись параметра */
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   p-obj-type
        ,input   p-obj-code
        ,input   {&ggoattr-NotCorrOP}
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   p-obj-type
        ,input   p-obj-code
        ,input   {&ggoattr-alc-min-price}
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
/*      run ggoattr-write (*/
/*         input   p-node-code*/
/*        ,input   p-host-code*/
/*        ,input   p-obj-type*/
/*        ,input   p-obj-code*/
/*        ,input   {&ggoattr-marg-pr-paraf}*/
/*        ,input   v-marg-pr-paraf*/
/*        ) no-error .*/
/*      if error-status :error then do:*/
/*        undo, return error.*/
/*      end.*/
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-marg-pr-paraf}
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-marg-pr-paraf}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-level-dis}
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-level-dis}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-no-inc-auto-rep}
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-no-inc-auto-rep}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-ban-sales-via-cd}
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   {&ggoattr-ban-sales-via-cd}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
    when "object-list":U then do:
      for each temp_obj-list:
        run grp-obj-write in this-procedure (
              input p-node-code
            , input temp_obj-list.host-code
            , input temp_obj-list.obj-type
            , input temp_obj-list.obj-code
            , input v-min-marg
            , input v-max-marg
            , input v-increase-pc
            , input gds-grp.calc-method
            , input v-round-method
            , input v-base
            , input v-cli-type
            , input v-cli-code

        ) no-error.
        if error-status :error
          then do:
              undo, return error.
        end.
      /* запись параметра */
      run ggoattr-write (
         input   p-node-code
        ,input   temp_obj-list.host-code
        ,input   temp_obj-list.obj-type
        ,input   temp_obj-list.obj-code
        ,input   {&ggoattr-NotCorrOP}
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   temp_obj-list.host-code
        ,input   temp_obj-list.obj-type
        ,input   temp_obj-list.obj-code
        ,input   {&ggoattr-alc-min-price}
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
/*      run ggoattr-write (*/
/*         input   p-node-code*/
/*        ,input   temp_obj-list.host-code*/
/*        ,input   temp_obj-list.obj-type*/
/*        ,input   temp_obj-list.obj-code*/
/*        ,input   {&ggoattr-marg-pr-paraf}*/
/*        ,input   v-marg-pr-paraf*/
/*        ) no-error .*/
/*      if error-status :error then do:*/
/*        undo, return error.*/
/*      end.*/
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-marg-pr-paraf}
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-marg-pr-paraf}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-level-dis}
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-level-dis}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-no-inc-auto-rep}
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-no-inc-auto-rep}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-ban-sales-via-cd}
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   {&ggoattr-ban-sales-via-cd}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
            if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-alchol-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   {&ggoattr-mark-grp}
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      
      end.
    end.
  end case.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-load Dialog-Frame 
PROCEDURE proc-load :
define variable v-list as character no-undo.
define variable vi as integer no-undo.
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.

MarkType = ObjSrv:Env:Marking:Types:MapType.
do vi = 1 to MarkType:GetItemByLab(vi):     
   objType  = ObjSrv:Env:Marking:Types:CurrProp.
   v-list = v-list + "," + objType:Label_ + "," + objType:NameProp.
end.

v-list = trim(v-list, ",").
c-mark-type:list-item-pairs in frame {&FRAME-NAME} = v-list.
v-list = "".
for each code where Code.parent eq "emc" no-lock:
      v-list = v-list + "," + Code.CodeName + "," + Code.code.
   end.

   v-list = "," + v-list .
   c-emrc-type:list-item-pairs in frame {&FRAME-NAME} = v-list.
   if p-mode = {&add-def} OR p-mode = {&update} then 
   do:
      enable c-mark-type c-emrc-type with frame {&FRAME-NAME}.
   end.

   display c-mark-type c-emrc-type with frame {&FRAME-NAME}.
   c-mark-type:visible in frame {&frame-name} = p-option eq "global". 
   c-emrc-type:visible in frame {&frame-name} = p-option eq "global".
  
end procedure.

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
  DISPLAY RS-option fi-increase-pc n-marg fi-marg-min fi-marg-max S-round-method
          F-base fi-cli-type fi-cli-code fi-cli-name fi-notcorr fi-alc-min-price
          n-marg-pr-paraf fi-marg-pr-paraf fi-grp-name n-increase-pc l-min l-max n-rmethod
          n-income-cli n-notcorr n-alc-min-price n-level-dis fill-sum-grp r-sum-grp
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help l-income-cli l-marg l-marg-pr-paraf l-rmethod l-increase-pc
         l-notcorr l-alc-min-price l-level-dis BR-temp_obj-list RS-option
         fi-increase-pc fi-marg-min fi-marg-max S-round-method F-base
         fi-cli-type fi-cli-code r-cli fi-cli-name fi-notcorr fi-alc-min-price
         br-level-dis fi-marg-pr-paraf fi-grp-name n-increase-pc l-min l-max n-rmethod
         n-income-cli n-notcorr n-alc-min-price n-level-dis fill-sum-grp r-sum-grp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-obj-list as character no-undo.
define variable  v-host-code like ub.sysconf.host-code no-undo .
CASE p-option:
    when "global":U then do:
    CASE p-mode:
        when {&update} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = 0
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end. /*update*/
        when {&lookup} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = 0
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end. /*{&lookup}*/
        END CASE. /*p-mode*/
    end. /*when global*/
    when {&company} then do:
    CASE p-mode:
        when {&add-def} then do:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0 no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для фирмы" v-host-name
            view-as alert-box error.
            undo, return error.
          end.
        end. /*add-def*/
        when {&update} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end. /*update*/
        when {&lookup} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end. /*{&lookup}*/
        END CASE. /*p-mode*/
    end. /*when company*/
    when {&g___object} then do:
    CASE p-mode:
        when {&add-def} then do:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для объекта" p-obj-type p-obj-code
            view-as alert-box error.
            undo, return error.
          end.
        end. /*add-def*/
        when {&update} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code.
        end. /*update*/
        when {&lookup} then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code.
        end. /*{&lookup}*/
        END CASE. /*p-mode*/
    end. /*g___object*/
    when "object-list":U then do:
    CASE p-mode:
        when {&add-def}
        then do:
          { gbl/uobjclr.i  }

          define variable v-object-available as logical   no-undo .
          { gbl/usobjava.i
            v-cntxt-db-num
            {&action-head-code-main}
            v-cntxt-userid
            p-obj-type
            p-obj-code
            v-object-available
          }
          if v-object-available = true
          then do:
            { gbl/uobjapnd.i
              p-obj-type
              p-obj-code
            }
          end.

          define variable v-user-select as logical   no-undo .
          { gbl/uobjsman.i
            parparentproc
            v-cntxt-db-num
            v-cntxt-userid
            v-host-code
            p-obj-type
            p-obj-code
            v-user-select
          }
          if v-user-select <> true
          then do:
            message
              "Объект не выбран"
              view-as alert-box information .
            return .
          end.

          define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

          for each temp_obj-list:
              delete temp_obj-list.
          end.
          for each buf_userobjs_temp-user-obj
          on error undo, return error return-value
          :
              CASE buf_userobjs_temp-user-obj.obj-type:
                  when {&shop} then do:
                      find first ub.shop no-lock where
                                  ub.shop.obj-code = buf_userobjs_temp-user-obj.obj-code.
                      assign
                      v-host-code = ub.shop.host-code.
                  end.
                  when {&stock} then do:
                              find first ub.store no-lock where
                                  ub.store.obj-code = buf_userobjs_temp-user-obj.obj-code.
                      assign
                      v-host-code = ub.store.host-code.

                  end.
              END CASE.
              create temp_obj-list.
              assign
                  temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                  temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
                    temp_obj-list.host-code = v-host-code

              .
          end.

    llist:
    for each temp_obj-list:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = temp_obj-list.host-code
                   AND buf_gds-grp-obj.obj-type = temp_obj-list.obj-type
                   AND buf_gds-grp-obj.obj-code = temp_obj-list.obj-code no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для объекта" temp_obj-list.obj-type temp_obj-list.obj-code
            view-as alert-box error.
            delete temp_obj-list.
            NEXT llist.
          end.  /*avail*/
          end. /*for each temp_obj-list*/
        end. /*add-def*/
         END CASE. /*p-mode*/
    end. /*object-list*/


END CASE. /*p-option*/
if available buf_gds-grp-obj then do:
    assign
    v-marg-min     = buf_gds-grp-obj.min-increase
    v-marg-max     = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    v-cli-type     = buf_gds-grp-obj.cli-type
    v-cli-code     = buf_gds-grp-obj.cli-code

    .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-NotCorrOP}
      ,output  v-notcorr
      ,output  v-type ) no-error .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-alc-min-price}
      ,output  v-alc-min-price
      ,output  v-type ) no-error .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-marg-pr-paraf}
      ,output  v-marg-pr-paraf
      ,output  v-type ) no-error .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-level-dis}
      ,output  v-level-dis-attr
      ,output  v-type ) no-error .
    
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-no-inc-auto-rep}
      ,output  v-no-inc-auto-rep
      ,output  v-type ) no-error .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-ban-sales-via-cd}
      ,output  v-ban-sales-via-cd
      ,output  v-type ) no-error .
      
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-alchol-grp}
      ,output  v-alchol
      ,output  v-type ) no-error .
      
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-mark-grp}
      ,output  v-mark
      ,output  v-type ) no-error .
      
      
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-sum-grps}
      ,output  v-sum-grp
      ,output  v-type ) no-error .

    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   {&ggoattr-mark-type}
      ,output  c-mark-type
      ,output  v-type ) no-error .
            
repeat ix = 1 to num-entries (v-level-dis-attr, {&delim-par}) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, {&delim-par}), {&comma-char}) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, {&delim-par}), {&comma-char}) .
end.

end.
else do:
    assign
    v-marg-min      = 0
    v-marg-max      = 0
    v-increase-pc   = 0
    v-round-method  = "":U
    v-base          = 0
    v-cli-type      = "":U
    v-notcorr       = "":U
    v-cli-code      = 0
    v-alc-min-price = "":U
    v-no-inc-auto-rep = "no"
    v-ban-sales-via-cd = "no"
    v-alchol        = "no"
    v-mark          = "no"
    v-sum-grp       = 0
    .
end.


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
define variable v-value as character no-undo.
define variable v-type as character no-undo.
assign
s-round-method:list-items in frame {&frame-name} = {&pr-rounds}.
f-base = v-base.
APPLY "VALUE-CHANGED" to s-round-method.
CASE p-mode:
    when {&add-def} then do:
            assign
            RS-option:radio-buttons in frame {&frame-name} =
                                                    "Фирма" + {&space-char} + v-host-name + {&comma-char} + {&company} + {&comma-char} +
                                                    "Объект" + {&space-char} + p-obj-type + string(p-obj-code) + {&comma-char} + {&g___object} + {&comma-char} +
                                                    "Список объектов" + {&comma-char} + "object-list":U.


    end.
    when {&update} then do:
        assign
    RS-option:radio-buttons = "Глобально" + {&comma-char} + "global":U + {&comma-char} +
                                            "Фирма" + {&comma-char} + {&company} + {&comma-char} +
                                            "Объект" + {&comma-char} + {&g___object} .


    end.
    when {&lookup} then do:
        assign
    RS-option:radio-buttons = "Глобально" + {&comma-char} + "global":U + {&comma-char} +
                                            "Фирма" + {&comma-char} + {&company} + {&comma-char} +
                                            "Объект" + {&comma-char} + {&g___object} .


    end.
END CASE.
assign
rs-option = p-option.

DISPLAY
n-marg
n-increase-pc
n-rmethod
n-income-cli
RS-option
v-full-name @ fi-grp-name
l-max l-min
n-notcorr
l-notcorr
n-alc-min-price
l-alc-min-price
n-level-dis
l-level-dis
n-marg-pr-paraf
n-no-inc-auto-rep
n-ban-sales-via-cd
WITH FRAME Dialog-Frame.

run Show-hide-lock in this-procedure.
ENABLE
b-quit
b-exit
B-Help
n-no-inc-auto-rep
n-ban-sales-via-cd
 WITH FRAME Dialog-Frame.

if p-option = "object-list":U then do:
    display
    BR-temp_obj-list
    with frame {&frame-name}.
    enable
    BR-temp_obj-list
    with frame {&frame-name}.
    {&OPEN-QUERY-{&BROWSE-NAME}}
end.
else do:
    hide
BR-temp_obj-list
    in frame {&frame-name}.
end.

{ gbl/conf-rd.i
  "'is-tm'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-value
  v-type
  no-error
}


v-value = "no".
{ gbl/conf-rd.i
  "'alcohol'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-value
  v-type
  no-error
}
if v-value = "yes" then do:
    enable 
    n-alchol 
    with frame {&frame-name}.
end.
if v-alchol = "yes" then do:
    enable 
    n-mark 
    with frame {&frame-name}.
end.  
enable 
  fill-sum-grp 
  r-sum-grp
  c-mark-type
  with frame {&frame-name} .    
if p-mode = {&lookup} then do:
    disable
     B-exit 
     B-Help 
     BR-temp_obj-list 
     RS-option 
     fi-increase-pc 
     n-marg 
     fi-marg-min 
     fi-marg-max 
     S-round-method 
     F-base 
     fi-cli-type 
     fi-cli-code 
     r-cli 
     fi-cli-name 
     fi-notcorr 
     fi-alc-min-price 
     br-level-dis
     n-marg-pr-paraf 
     fi-marg-pr-paraf 
     fi-grp-name 
     n-increase-pc 
     l-min 
     l-max 
     n-rmethod 
     n-no-inc-auto-rep 
     n-ban-sales-via-cd
     n-alchol
     n-mark
     fill-sum-grp
     r-sum-grp 
     n-income-cli 
     n-notcorr 
     n-alc-min-price 
     n-level-dis 
     l-income-cli 
     l-marg 
     l-marg-pr-paraf 
     l-rmethod 
     l-increase-pc 
     l-notcorr 
     c-mark-type
     l-alc-min-price 
     l-level-dis 
     B-add 
     B-chg 
     B-del  WITH FRAME Dialog-Frame.
    hide  
     l-income-cli 
     l-marg 
     l-marg-pr-paraf 
     l-rmethod 
     l-increase-pc 
     l-notcorr 
     l-alc-min-price 
     l-level-dis  in frame {&frame-name}.
end.        

  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-save Dialog-Frame
PROCEDURE proc-b-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
frame {&frame-name}
n-no-inc-auto-rep
n-ban-sales-via-cd

n-alchol
n-mark
fill-sum-grp
fi-notcorr
fi-alc-min-price
fi-cli-type fi-cli-code
fi-marg-max fi-marg-min
fi-increase-pc
s-round-method
f-base
fi-marg-pr-paraf
c-mark-type

v-increase-pc  = if fi-increase-pc:sensitive
                 and fi-increase-pc:visible then fi-increase-pc else ?
v-marg-min  = if fi-marg-min:sensitive
              and fi-marg-min:visible then fi-marg-min else ?
v-marg-max  = if fi-marg-max:sensitive
              and fi-marg-max:visible
              then fi-marg-max else ?
v-round-method = if s-round-method:sensitive
                 and s-round-method:visible
                 then s-round-method else "":U
v-base         = if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                  then f-base
                  else 0
v-cli-type   =  if fi-cli-type:sensitive
                and fi-cli-type:visible
                then fi-cli-type else "":U
v-cli-code   =  if fi-cli-code:sensitive
                and fi-cli-code:visible
                then fi-cli-code else 0

v-notcorr   =  if fi-notcorr:sensitive
                and fi-notcorr:visible
                then fi-notcorr else "":U
.
v-alc-min-price =  if  fi-alc-min-price:sensitive
                   and fi-alc-min-price:visible
                  then fi-alc-min-price else "":U
.
v-marg-pr-paraf =  if  fi-marg-pr-paraf:sensitive
                   and fi-marg-pr-paraf:visible
                  then string (fi-marg-pr-paraf) else "":U
.
if br-level-dis:sensitive and br-level-dis:visible
then do:
  assign
    v-level-dis-attr = ""
  .
  for each tt-level-dis-attr /*by tt-level-dis-attr.attr-code descending*/ :
    assign
      v-level-dis-attr = v-level-dis-attr + tt-level-dis-attr.attr-code + {&comma-char} + tt-level-dis-attr.attr-value + {&delim-par}
    .
  end.
end.
else do:
  assign
    v-level-dis-attr = ""
  .
end.

run create-attr in this-procedure ( input v-marg-min
                                   ,input v-marg-max
                                   ,input v-increase-pc
                                   ,input v-round-method
                                   ,input v-base
                                   ,input v-cli-type
                                   ,input v-cli-code
                                   ,input v-notcorr
                                   ,input v-alc-min-price
                                   ,input v-marg-pr-paraf
                                   ,input v-level-dis-attr
                                   ,input string(n-no-inc-auto-rep)
                                   ,input string(n-ban-sales-via-cd)

                                   ,input string(n-alchol)
                                   ,input string(n-mark)
                                   ,input fill-sum-grp
                                   ,input c-mark-type
                                   ,input c-emrc-type
                                  ) no-error.
if error-status:error then do:
   message error-status :get-message(1) .
   undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-hide-lock Dialog-Frame
PROCEDURE show-hide-lock :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
v-cli-name = func-cli-name (v-cli-type,v-cli-code) .
CASE p-mode:
  when {&update} or when {&lookup} then do: /* ТН-3197 Арн. 16.04.2015 */
    if v-marg-min <> ? and v-marg-max <> ? then do:
      display
      v-marg-min @ fi-marg-min
      v-marg-max @ fi-marg-max
      with frame {&frame-name}
      .
      ENABLE
      fi-marg-max
      fi-marg-min
      with frame {&frame-name}
      .
      hide
      l-marg
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-marg-max
      fi-marg-min
      in frame {&frame-name}
      .
      ENABLE
      l-marg
      with frame {&frame-name}.
      display
      l-marg
      with frame {&frame-name}.
    end.
    if v-increase-pc <> ? then do:
      display
      v-increase-pc @ fi-increase-pc
      with frame {&frame-name}
      .
      ENABLE
      fi-increase-pc
      with frame {&frame-name}
      .
      assign
      n-increase-pc:fgcolor = ?
      .
      hide
      l-increase-pc
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-increase-pc
      in frame {&frame-name}
      .
      ENABLE
      l-increase-pc
      with frame {&frame-name}.

      display
      l-increase-pc
      with frame {&frame-name}.
    end.
    if v-round-method <> "":U then do:
      assign
      s-round-method:screen-value = v-round-method
      .
      ENABLE
      s-round-method
      with frame {&frame-name}
      .
      assign
      n-rmethod:fgcolor = ?
      .
      hide
      l-rmethod
      in frame {&frame-name}
      .
      APPLY "VALUE-CHANGED" to s-round-method.
    end.
    else do:
      APPLY "VALUE-CHANGED" to s-round-method.
      hide
      s-round-method
      in frame {&frame-name}
      .
      ENABLE
      l-rmethod
      with frame {&frame-name}.

      display
      l-rmethod
      with frame {&frame-name}.
    end.

    if v-cli-type <> "" and v-cli-code <> 0 then do:
      display
      v-cli-type @ fi-cli-type
      v-cli-code @ fi-cli-code
      v-cli-name @ fi-cli-name
      with frame {&frame-name}
      .
      ENABLE
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      with frame {&frame-name}
      .
      hide
      l-income-cli
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      in frame {&frame-name}
      .
      ENABLE
      l-income-cli
      with frame {&frame-name}.
      display
      l-income-cli
      with frame {&frame-name}.
    end.

    if v-notcorr <> ""  then do:
      fi-notcorr = v-notcorr .
      display
       fi-notcorr
      with frame {&frame-name}
      .
      ENABLE
      fi-notcorr
      with frame {&frame-name}
      .
      hide
      l-notcorr
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-notcorr
      in frame {&frame-name}
      .
      ENABLE
      l-notcorr
      with frame {&frame-name}.
      display
      l-notcorr
      with frame {&frame-name}.
    end.
    if v-alc-min-price <> ""  then do:
      fi-alc-min-price = v-alc-min-price .
      display
       fi-alc-min-price
      with frame {&frame-name}
      .
      ENABLE
      fi-alc-min-price
      with frame {&frame-name}
      .
      hide
      l-alc-min-price
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-alc-min-price
      in frame {&frame-name}
      .
      ENABLE
      l-alc-min-price
      with frame {&frame-name}.
      display
      l-alc-min-price
      with frame {&frame-name}.
    end.
    if v-marg-pr-paraf <> ""  then do:
      fi-marg-pr-paraf = decimal (v-marg-pr-paraf).
      display
      fi-marg-pr-paraf
      with frame {&frame-name}
      .
      ENABLE
      fi-marg-pr-paraf
      with frame {&frame-name}
      .
      hide
      l-marg-pr-paraf
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-marg-pr-paraf
      in frame {&frame-name}
      .
      ENABLE
      l-marg-pr-paraf
      with frame {&frame-name}.
      display
      l-marg-pr-paraf
      with frame {&frame-name}.
    end.
    if can-find (first tt-level-dis-attr) then do:
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
      display
      br-level-dis
      B-add
      B-chg
      B-del
      with frame {&frame-name}
      .
      ENABLE
      br-level-dis
      B-add
      B-chg
      B-del
      with frame {&frame-name}
      .
      hide
      l-level-dis
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      br-level-dis
      B-add
      B-chg
      B-del
      in frame {&frame-name}
      .
      ENABLE
      l-level-dis
      with frame {&frame-name}.
      display
      l-level-dis
      with frame {&frame-name}.
    end.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame {&FRAME-NAME}.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame {&FRAME-NAME}.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame {&FRAME-NAME}.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame {&FRAME-NAME}.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame {&FRAME-NAME}.
  end.
    when {&lookup} then do:
    if v-marg-min <> ? and v-marg-max <> ? then do:
      display
      v-marg-min @ fi-marg-min
      v-marg-max @ fi-marg-max
      with frame {&frame-name}
      .
      ENABLE
      fi-marg-max
      fi-marg-min
      with frame {&frame-name}
      .
      hide
      l-marg
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-marg-max
      fi-marg-min
      in frame {&frame-name}
      .
      ENABLE
      l-marg
      with frame {&frame-name}.
      display
      l-marg
      with frame {&frame-name}.
    end.
    if v-increase-pc <> ? then do:
      display
      v-increase-pc @ fi-increase-pc
      with frame {&frame-name}
      .
      ENABLE
      fi-increase-pc
      with frame {&frame-name}
      .
      assign
      n-increase-pc:fgcolor = ?
      .
      hide
      l-increase-pc
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-increase-pc
      in frame {&frame-name}
      .
      ENABLE
      l-increase-pc
      with frame {&frame-name}.

      display
      l-increase-pc
      with frame {&frame-name}.
    end.
    if v-round-method <> "":U then do:
      assign
      s-round-method:screen-value = v-round-method
      .
      ENABLE
      s-round-method
      with frame {&frame-name}
      .
      assign
      n-rmethod:fgcolor = ?
      .
      hide
      l-rmethod
      in frame {&frame-name}
      .
      APPLY "VALUE-CHANGED" to s-round-method.
    end.
    else do:
      APPLY "VALUE-CHANGED" to s-round-method.
      hide
      s-round-method
      in frame {&frame-name}
      .
      ENABLE
      l-rmethod
      with frame {&frame-name}.

      display
      l-rmethod
      with frame {&frame-name}.
    end.

    if v-cli-type <> "" and v-cli-code <> 0 then do:
      display
      v-cli-type @ fi-cli-type
      v-cli-code @ fi-cli-code
      v-cli-name @ fi-cli-name
      with frame {&frame-name}
      .
      ENABLE
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      with frame {&frame-name}
      .
      hide
      l-income-cli
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      in frame {&frame-name}
      .
      ENABLE
      l-income-cli
      with frame {&frame-name}.
      display
      l-income-cli
      with frame {&frame-name}.
    end.

    if v-notcorr <> ""  then do:
      fi-notcorr = v-notcorr .
      display
       fi-notcorr
      with frame {&frame-name}
      .
      ENABLE
      fi-notcorr
      with frame {&frame-name}
      .
      hide
      l-notcorr
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-notcorr
      in frame {&frame-name}
      .
      ENABLE
      l-notcorr
      with frame {&frame-name}.
      display
      l-notcorr
      with frame {&frame-name}.
    end.
    if v-alc-min-price <> ""  then do:
      fi-alc-min-price = v-alc-min-price .
      display
       fi-alc-min-price
      with frame {&frame-name}
      .
      ENABLE
      fi-alc-min-price
      with frame {&frame-name}
      .
      hide
      l-alc-min-price
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-alc-min-price
      in frame {&frame-name}
      .
      ENABLE
      l-alc-min-price
      with frame {&frame-name}.
      display
      l-alc-min-price
      with frame {&frame-name}.
    end.
    if v-marg-pr-paraf <> ""  then do:
      fi-marg-pr-paraf = decimal (v-marg-pr-paraf).
      display
      fi-marg-pr-paraf
      with frame {&frame-name}
      .
      ENABLE
      fi-marg-pr-paraf
      with frame {&frame-name}
      .
      hide
      l-marg-pr-paraf
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      fi-marg-pr-paraf
      in frame {&frame-name}
      .
      ENABLE
      l-marg-pr-paraf
      with frame {&frame-name}.
      display
      l-marg-pr-paraf
      with frame {&frame-name}.
    end.
    if can-find (first tt-level-dis-attr) then do:
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
      display
      br-level-dis
      B-add
      B-chg
      B-del
      with frame {&frame-name}
      .
      ENABLE
      br-level-dis
      B-add
      B-chg
      B-del
      with frame {&frame-name}
      .
      hide
      l-level-dis
      in frame {&frame-name}
      .
    end.
    else do:
      hide
      br-level-dis
      B-add
      B-chg
      B-del
      in frame {&frame-name}
      .
      ENABLE
      l-level-dis
      with frame {&frame-name}.
      display
      l-level-dis
      with frame {&frame-name}.
    end.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame {&FRAME-NAME}.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame {&FRAME-NAME}.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame {&FRAME-NAME}.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame {&FRAME-NAME}.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame {&FRAME-NAME}.
  end.
  when {&add-def} then do:
    hide
    fi-marg-max
    fi-marg-min
    in frame {&frame-name}
    .
    ENABLE
    l-marg
    with frame {&frame-name}.
    display
    l-marg
    with frame {&frame-name}.
    hide
    fi-increase-pc
    in frame {&frame-name}
    .
    ENABLE
    l-increase-pc
    with frame {&frame-name}.

    display
    l-increase-pc
    with frame {&frame-name}.
    hide
    s-round-method
    in frame {&frame-name}
    .
    ENABLE
    l-rmethod
    with frame {&frame-name}.

    display
    l-rmethod
    with frame {&frame-name}.

    hide
    fi-cli-type
    fi-cli-code
    r-cli
    fi-cli-name
    in frame {&frame-name}
    .
    ENABLE
    l-income-cli
    with frame {&frame-name}.
    display
    l-income-cli
    with frame {&frame-name}.

    hide
    fi-notcorr
    in frame {&frame-name}
    .
    ENABLE
    l-notcorr
    with frame {&frame-name}.
    display
    l-notcorr
    with frame {&frame-name}.

    hide
    fi-alc-min-price
    in frame {&frame-name}
    .
    ENABLE
    l-alc-min-price
    with frame {&frame-name}.
    display
    l-alc-min-price
    with frame {&frame-name}.
    hide
    fi-marg-pr-paraf
    in frame {&frame-name}
    .
    ENABLE
    l-marg-pr-paraf
    with frame {&frame-name}.
    display
    l-marg-pr-paraf
    with frame {&frame-name}.
    hide
    br-level-dis
    B-add
    B-chg
    B-del
    in frame {&frame-name}
    .
    ENABLE
    l-level-dis
    with frame {&frame-name}.
    display
    l-level-dis
    with frame {&frame-name}.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame {&FRAME-NAME}.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame {&FRAME-NAME}.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame {&FRAME-NAME}.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame {&FRAME-NAME}.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame {&FRAME-NAME}.
  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-cli-name Dialog-Frame
FUNCTION func-cli-name RETURNS CHARACTER
  ( p-type as char, p-code as int  ) :
/*------------------------------------------------------------------------------
  Purpose:  Имя объекта
------------------------------------------------------------------------------*/
define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = p-type
           and buf_clients.obj-code = p-code
    no-error.
    if not available buf_clients
    then do:
      RETURN "" .
    end.
    else do:
       RETURN buf_clients.obj-name    .
    end.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME