&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-ok as logical no-undo . /* Заказы */

/* Local Variable Definitions ---                                       */
define variable fl              as character no-undo .
define variable post-grp_recids as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-cli-name      as character no-undo .
define variable list-dogovor    as character no-undo .
define variable v-rid-list      as character no-undo .
define variable v-dog-edi       as character no-undo .
define variable vOk             as logical   no-undo .
define variable glog            as logical   no-undo .
define variable listDogovor as character no-undo .
       
{ cmp/str-glbl.i              }
{ cmp/library.i               }
{ gbl/sel-date.i }
{ str/cntrcodes.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ rep/tt-date.i }

&scoped-define ALL_DOG_EDI "Все действующие договоры с EDI"
&scoped-define ALL_DOG     "Все действующие договоры"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br_date

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dateZakaz

/* Definitions for BROWSE br_date                                       */
&Scoped-define FIELDS-IN-QUERY-br_date tt-dateZakaz.dateStart ~
tt-dateZakaz.dateEnd 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_date 
&Scoped-define QUERY-STRING-br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br_date OPEN QUERY br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br_date tt-dateZakaz
&Scoped-define FIRST-TABLE-IN-QUERY-br_date tt-dateZakaz


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br_date}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit Btn_OK B-lkp B-Help i-exit BUTTON-1 ~
RECT-5 RECT-6 BUTTON-2 RECT-7 Date-order b-date rs_period Date-Start ~
Date-End RADIO-SET-1 sale_day br_date garant_day b-clients customer-name ~
SelectGood t-daygoods Goods-Editor F-button-1 F-button-2 b-date-Start b-date-End
&Scoped-Define DISPLAYED-OBJECTS Date-order rs_period text-sale-list1 ~
text-period_list2 Date-Start Date-End RADIO-SET-1 sale_day garant_day ~
text-client text-dogovor customer-name text-googs text-typedoc_list-2 ~
f-typedoc-desc SelectGood t-daygoods Goods-Editor F-button-1 F-button-2 ~
text-cliname

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define page-1 RECT-5 RECT-6 RECT-7 Date-order b-date ~
RADIO-SET-1 sale_day garant_day b-clients customer-name ~
SelectGood Goods-Editor text-client text-dogovor text-googs ~
text-sale-list1 text-cliname b-contract b-chooseContract b-chooseGoods
&Scoped-define page-2 Date-Start Date-End ~
rs_period text-period_list2 br_date bt-not-sel-all bt-not-sel-desel-all t-daygoods ~
b-date-Start b-date-End

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD customerName Dialog-Frame 
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chooseContract 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88 TOOLTIP "Выбрать договоры".

DEFINE BUTTON b-chooseGoods 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88 TOOLTIP "Выбрать товары".

DEFINE BUTTON b-clients 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88 TOOLTIP "Выбрать контрагента".

DEFINE BUTTON b-contract 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88 TOOLTIP "Выбрать договоры".

DEFINE BUTTON b-date 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88.

DEFINE BUTTON b-date-Start 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88.
  
DEFINE BUTTON b-date-End 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "" 
    SIZE 3 BY .88.
    
DEFINE BUTTON b-exit AUTO-END-KEY 
    LABEL "&Выход" 
    SIZE 10 BY 1
    BGCOLOR 8 .

/*DEFINE BUTTON B-Help*/
/*  LABEL "Помо&щь"   */
/*  SIZE 10 BY 1      */
/*  BGCOLOR 8 .       */

/*DEFINE BUTTON B-lkp*/
/*  LABEL "&Просмотр"*/
/*  SIZE 10 BY 1     */
/*  BGCOLOR 8 .      */

DEFINE BUTTON b-type-doc 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "Типы документов" 
    SIZE 3 BY .88 TOOLTIP "Типы документов"
    FONT 1.

DEFINE BUTTON bt-not-sel-all 
    LABEL "+" 
    SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
    LABEL "-" 
    SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON Btn_OK AUTO-GO 
    LABEL "_ В&ыполнить" 
    SIZE 12 BY 1
    BGCOLOR 8 .

DEFINE BUTTON BUTTON-1 
    IMAGE-UP FILE "adeicon\ts-up":U
    IMAGE-DOWN FILE "adeicon\ts-down":U
    IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
    LABEL "&1.Параметры" 
    SIZE 15 BY 1.17 TOOLTIP "Параметры".

DEFINE BUTTON BUTTON-2 
    IMAGE-UP FILE "adeicon\ts-up":U
    IMAGE-DOWN FILE "adeicon\ts-down":U
    IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
    LABEL "&2.Продолжение" 
    SIZE 15 BY 1.17 TOOLTIP "Продолжение".

DEFINE BUTTON i-exit 
    IMAGE-UP FILE "cmp/i-run.bmp":U
    IMAGE-DOWN FILE "cmp/i-run.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
    LABEL "" 
    SIZE 2.5 BY .75.

DEFINE VARIABLE customer-name       AS CHARACTER 
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 34 BY 2 TOOLTIP "Список выбранных Поставщиков"
    FONT 4 NO-UNDO.

DEFINE VARIABLE Goods-Editor        AS CHARACTER 
    VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
    SIZE 34 BY 2
    FONT 4 NO-UNDO.

DEFINE VARIABLE Date-order          AS DATE      FORMAT "99/99/9999":U 
    LABEL "Дата заказа" 
    VIEW-AS FILL-IN 
    SIZE 11 BY 1
    BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE Date-End            AS DATE      FORMAT "99/99/9999":U 
    LABEL "по" 
    VIEW-AS FILL-IN NATIVE 
    SIZE 13 BY 1
    BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE Date-Start          AS DATE      FORMAT "99/99/9999":U 
    LABEL "с" 
    VIEW-AS FILL-IN NATIVE 
    SIZE 13 BY 1
    BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE F-button-1          AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры" 
    VIEW-AS TEXT 
    SIZE 13 BY .67 TOOLTIP "Параметры" NO-UNDO.

DEFINE VARIABLE F-button-2          AS CHARACTER FORMAT "X(256)":U INITIAL "Продолжение" 
    VIEW-AS TEXT 
    SIZE 13 BY .71 TOOLTIP "Продолжение" NO-UNDO.

DEFINE VARIABLE f-typedoc-desc      AS CHARACTER 
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 50 BY 2 NO-UNDO.

DEFINE VARIABLE text-cliname        AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 50 BY 1 NO-UNDO.
  
DEFINE VARIABLE garant_day          AS INTEGER   FORMAT ">>>9":U INITIAL 7 
    LABEL "Гарантийный запас в днях" 
    VIEW-AS FILL-IN 
    SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE sale_day            AS INTEGER   FORMAT ">>9":U INITIAL ?
    VIEW-AS FILL-IN 
    SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE text-client         AS CHARACTER FORMAT "X(256)":U INITIAL "Контрагент:" 
    VIEW-AS FILL-IN 
    SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE text-dogovor        AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:" 
    VIEW-AS FILL-IN 
    SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE text-googs          AS CHARACTER FORMAT "X(256)":U INITIAL "Товары:" 
    VIEW-AS FILL-IN 
    SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE text-period_list2   AS CHARACTER FORMAT "X(256)":U INITIAL "Период продаж для анализа:" 
    VIEW-AS FILL-IN 
    SIZE 27.5 BY 1
    FONT 1 NO-UNDO.

DEFINE VARIABLE text-sale-list1     AS CHARACTER FORMAT "X(256)":U INITIAL "Обеспечение продаж на период в днях:" 
    VIEW-AS FILL-IN 
    SIZE 37.5 BY 1 NO-UNDO.

DEFINE VARIABLE text-typedoc_list-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Типы документов:" 
    VIEW-AS FILL-IN 
    SIZE 17 BY 1
    FONT 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1         AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "7", 1,
    "14", 2,
    "21", 3,
    "28", 4,
    "", 5
    SIZE 29 BY 1.25 NO-UNDO.

DEFINE VARIABLE rs_period           AS INTEGER 
    VIEW-AS RADIO-SET VERTICAL
    RADIO-BUTTONS 
    ".", 1,
    "", 2
    SIZE 2 BY 3 NO-UNDO.

DEFINE VARIABLE SelectGood          AS INTEGER 
    VIEW-AS RADIO-SET VERTICAL
    RADIO-BUTTONS 
    "Все по поставщику", 1,
    "Все по договору", 2,
    "Выборочно", 3
    SIZE 29.75 BY 3.25
    FGCOLOR 0 NO-UNDO.

DEFINE RECTANGLE RECT-5
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 93 BY 6.25.

DEFINE RECTANGLE RECT-6
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 93 BY 1.5.

DEFINE RECTANGLE RECT-7
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 93 BY 10.5.

DEFINE VARIABLE t-daygoods AS LOGICAL   INITIAL true 
    LABEL "Исключить дни без товара на остатке" 
    VIEW-AS TOGGLE-BOX
    SIZE 40 BY .83
    FONT 1 NO-UNDO.


define variable v-title    as character no-undo .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_date FOR 
    tt-dateZakaz SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_date Dialog-Frame _STRUCTURED
    QUERY br_date NO-LOCK DISPLAY
    tt-dateZakaz.dateStart COLUMN-LABEL "Начало" FORMAT "99/99/9999":U WIDTH 14
    tt-dateZakaz.dateEnd COLUMN-LABEL "Конец" FORMAT "99/99/9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 30 BY 7.71
         TITLE "Интервалы анализа" ROW-HEIGHT-CHARS 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1 COL 1 WIDGET-ID 4
    Btn_OK AT ROW 1 COL 11 WIDGET-ID 10
    /*  B-lkp AT ROW 1 COL 73.5 WIDGET-ID 8 */
    /*  B-Help AT ROW 1 COL 83.5 WIDGET-ID 6*/
    i-exit AT ROW 1.08 COL 11.13 WIDGET-ID 12 NO-TAB-STOP 
    BUTTON-1 AT ROW 2.5 COL 2 WIDGET-ID 14
    BUTTON-2 AT ROW 2.5 COL 17 WIDGET-ID 16
    Date-order AT ROW 4.25 COL 46 RIGHT-ALIGNED WIDGET-ID 50
    b-date AT ROW 4.29 COL 49.38 RIGHT-ALIGNED WIDGET-ID 374
    rs_period AT ROW 5.75 COL 44.30 NO-LABEL WIDGET-ID 40
    text-sale-list1 AT ROW 5.83 COL 2.63 NO-LABEL WIDGET-ID 84
    text-period_list2 AT ROW 6 COL 11.75 COLON-ALIGNED NO-LABEL WIDGET-ID 94
    Date-Start AT ROW 6 COL 47.75 COLON-ALIGNED WIDGET-ID 34
    b-date-Start AT ROW 6 COL 65 RIGHT-ALIGNED WIDGET-ID 374
    Date-End AT ROW 6 COL 83.38 RIGHT-ALIGNED WIDGET-ID 32
    b-date-End AT ROW 6 COL 86.63 RIGHT-ALIGNED WIDGET-ID 374
    RADIO-SET-1 AT ROW 7 COL 6.38 NO-LABEL WIDGET-ID 56
    sale_day AT ROW 7.13 COL 37.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 66
    bt-not-sel-all AT ROW 7.54 COL 51.75 WIDGET-ID 86 NO-TAB-STOP 
    bt-not-sel-desel-all AT ROW 7.54 COL 54.75 WIDGET-ID 88 NO-TAB-STOP 
    br_date AT ROW 7.54 COL 86.75 RIGHT-ALIGNED WIDGET-ID 200
    garant_day AT ROW 8.46 COL 37.88 RIGHT-ALIGNED WIDGET-ID 52
    text-client AT ROW 10.25 COL 2.5 NO-LABEL WIDGET-ID 80
    b-clients AT ROW 10.25 COL 35.63 RIGHT-ALIGNED WIDGET-ID 46
    text-dogovor AT ROW 11.75 COL 2.5 NO-LABEL WIDGET-ID 376
    customer-name AT ROW 12.83 COL 35.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 48
    text-googs AT ROW 15.08 COL 2.5 NO-LABEL WIDGET-ID 82
    text-typedoc_list-2 AT ROW 15.5 COL 11.75 COLON-ALIGNED NO-LABEL WIDGET-ID 96
    b-type-doc AT ROW 15.5 COL 31.75 WIDGET-ID 36
    f-typedoc-desc AT ROW 15.5 COL 35.75 COLON-ALIGNED NO-LABEL WIDGET-ID 90
    text-cliname AT ROW 10.25 COL 36.75 COLON-ALIGNED NO-LABEL WIDGET-ID 90
    SelectGood AT ROW 16.08 COL 2.5 NO-LABEL WIDGET-ID 68
    b-contract AT ROW 17.21 COL 35.63 RIGHT-ALIGNED WIDGET-ID 384
    t-daygoods AT ROW 18 COL 14 WIDGET-ID 92
    b-chooseContract AT ROW 18.38 COL 35.63 RIGHT-ALIGNED WIDGET-ID 386
    b-chooseGoods AT ROW 18.38 COL 38.75 RIGHT-ALIGNED WIDGET-ID 388
    Goods-Editor AT ROW 19.63 COL 2.5 NO-LABEL WIDGET-ID 54
    F-button-1 AT ROW 2.75 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 372
    F-button-2 AT ROW 2.75 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 348
    RECT-5 AT ROW 3.75 COL 2 WIDGET-ID 378
    RECT-6 AT ROW 10 COL 2 WIDGET-ID 380
    RECT-7 AT ROW 11.5 COL 2 WIDGET-ID 382
    SPACE(1.24) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE v-title WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-dateZakaz T "?" NO-UNDO 
      ADDITIONAL-FIELDS:
          field id as integer
          field dateStart as date
          field dateEnd as date
          
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br_date bt-not-sel-desel-all Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-chooseContract IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
ASSIGN 
    b-chooseContract:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-chooseGoods IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
ASSIGN 
    b-chooseGoods:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-clients IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
    b-clients:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-contract IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
ASSIGN 
    b-contract:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-date IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
    b-date:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-date-Start IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
    b-date-Start:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-date-End IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
    b-date-End:HIDDEN IN FRAME Dialog-Frame = TRUE.
    
/* SETTINGS FOR BUTTON b-type-doc IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR BROWSE br_date IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
    tt-dateZakaz.dateStart:AUTO-RESIZE IN BROWSE br_date = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR customer-name IN FRAME Dialog-Frame
   ALIGN-R 1                                                            */
ASSIGN 
    customer-name:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN Date-order IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN Date-End IN FRAME Dialog-Frame
   ALIGN-R 6                                                            */
/* SETTINGS FOR FILL-IN Date-Start IN FRAME Dialog-Frame
   6                                                                    */
/* SETTINGS FOR FILL-IN f-typedoc-desc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    f-typedoc-desc:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-cliname IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    text-cliname:READ-ONLY IN FRAME Dialog-Frame = TRUE.
  
/* SETTINGS FOR FILL-IN garant_day IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR EDITOR Goods-Editor IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
    Goods-Editor:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN sale_day IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR RADIO-SET SelectGood IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN text-client IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
    text-client:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-dogovor IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
    text-dogovor:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-googs IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
    text-googs:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-period_list2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    text-period_list2:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-sale-list1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
    text-sale-list1:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN text-typedoc_list-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    text-typedoc_list-2:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_date
/* Query rebuild information for BROWSE br_date
     _TblList          = "Temp-Tables.tt-dateZakaz"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-dateZakaz.dateStart
"tt-dateZakaz.dateStart" "Начало" "99/99/9999" "date" ? ? ? ? ? ? no ? no no "14" yes yes no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-date.abcd-ext-doc-type
"tt-dateZakaz.dateEnd" "Конец" "99/99/9999" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br_date */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chooseContract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chooseContract Dialog-Frame
ON CHOOSE OF b-chooseContract IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .

        APPLY "choose" TO b-contract .
        if list-dogovor = "" then 
        do:
            list-dogovor = customer-name .
            empty temp-table gds-list .
            SelectGood = 2 .
            Goods-Editor = "" .
            display SelectGood Goods-Editor with frame {&frame-name} .
            hide b-chooseContract b-chooseGoods in frame {&frame-name} .
            enable b-contract with frame {&frame-name} .
            return no-apply .
        end.
        if listDogovor <> "" then
            APPLY "choose" TO b-chooseGoods .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contract Dialog-Frame
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .

        if p-ok then 
        do:
            run check-contract-code-attr in this-procedure (input  substitute("&1,&2", "choose":u, "doc-type"),
                input  v-cntxt-host-code-obj,
                input  v-cli-type,
                input  v-cli-code,
                input  ?,
                input  parparentproc,
                input  today,
                input  "" ,
                input  "contract-edi_orders",
                output listDogovor) .

        end.
        else 
        do:
            run check-contract-code in this-procedure (input  substitute("&1,&2", "choose":u, "doc-type"),
                input  v-cntxt-host-code-obj,
                input  v-cli-type,
                input  v-cli-code,
                input  ?,
                input  parparentproc,
                input  today,
                input  "" ,
                output listDogovor) no-error.
        end.
        if listDogovor <> "" then do:
            listDogovor =  trim (listDogovor,",") .
            list-dogovor = listDogovor .
            empty temp-table gds-list .
            customer-name = customerName(list-dogovor) .
            display customer-name with frame {&frame-name} .
            find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
            if available (buf_clients) then
            run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all Dialog-Frame
ON choose OF bt-not-sel-all IN FRAME Dialog-Frame /* + */
    DO:
    
        run rep/choose_date.w (input parParentProc,
            input-output table tt-dateZakaz by-reference) .
        {&OPEN-QUERY-br_date}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chooseGoods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chooseGoods Dialog-Frame
ON CHOOSE OF b-chooseGoods IN FRAME Dialog-Frame
    DO:
        if list-dogovor = "" then
        do:
            message "Для выбора товара необходимо выбрать договор(ы)" view-as alert-box.
            SelectGood = 1 .
            display SelectGood with frame {&frame-name} .
            hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
            return no-apply.
        end.

        RUN str/contspec_choose.w (
            input  parparentproc,
            input  "b-mark,b-sel",
            input  {&lookup},
            input  v-cntxt-host-code-obj,
            input  list-dogovor,
            input integer(post-grp_recids),
            output table choose-gds-list
            ).
        find first gds-list no-error .
        if available (gds-list) then 
        do:
            find first choose-gds-list no-error .
            if available (choose-gds-list) then 
            do:
                v-rid-list = "" .
                Goods-Editor = "" .
                empty temp-table gds-list .
                for each choose-gds-list:
                    create gds-list.
                    buffer-copy choose-gds-list to gds-list .
                end.
            end.
            else 
            do:
                return no-apply .
            end.
        end.
        else 
        do:
            find first choose-gds-list no-error .
            if not available (choose-gds-list) then 
            do:
                SelectGood = 2 .
                Goods-Editor = "" .
                display SelectGood Goods-Editor with frame {&frame-name} .
                hide b-chooseContract b-chooseGoods in frame {&frame-name} .
                enable b-contract with frame {&frame-name} .
                return no-apply .
            end.
            else 
            do:
                v-rid-list = "" .
                Goods-Editor = "" .
                empty temp-table gds-list .
                for each choose-gds-list:
                    create gds-list.
                    buffer-copy choose-gds-list to gds-list .
                end.                
            end.
        end.
        for each gds-list:
            if lookup(string(gds-list.gds-code),v-rid-list,", ") > 0 then next .
            v-rid-list = v-rid-list + "," + string(gds-list.gds-code) .
        end.
        v-rid-list = trim(v-rid-list,",") .
        Goods-Editor = v-rid-list . 
        display Goods-Editor with frame {&frame-name} .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all Dialog-Frame
ON choose OF bt-not-sel-desel-all IN FRAME Dialog-Frame /* - */
    DO:
        if available (tt-dateZakaz) then 
        do:
            delete tt-dateZakaz .
        end.
        else 
        do:
            message "Не выбран интервал анализа для удаления"
                view-as alert-box.
        end.
        {&OPEN-QUERY-br_date}

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON LEAVE OF Date-End IN FRAME Dialog-Frame /* по */
    DO:
        if date(Date-End:screen-value) >= today then 
        do:
            message "Дата окончания периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
            return no-apply .
        end.  
        Assign  Date-End no-error.
        display Date-End with frame Dialog-Frame .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON LEAVE OF Date-Start IN FRAME Dialog-Frame /* с */
    DO:
        if date(Date-Start:screen-value) >= today then 
        do:
            message "Дата начала периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
            return no-apply .
        end.  
        Assign  Date-Start no-error.
        display Date-Start with frame Dialog-Frame .


    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_ok Dialog-Frame
ON CHOOSE OF btn_ok IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .
            define buffer buf_trn-doc         for ub.trn-doc . 
    define buffer buf_doc-line        for ub.doc-line .
    define buffer buf_goods           for ub.goods .
    define buffer buf_contract-specif for ub.contract-specif .
        if text-cliname = "" then 
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            return no-apply .
        end.
        if SelectGood = 3 and Goods-Editor = "" then 
        do:
            message "Товар не выбран!"
                view-as alert-box.
            return no-apply .
        end.
    
        if fl = "" then 
        do:
            message "Необходимо сходить на вкладку 'Продолжение...'"
                view-as alert-box.
            APPLY "choose" TO BUTTON-2 .
            return no-apply .
        end.
        vOk = true .
    
        case SelectGood:
            when 0 or 
            when 1 then 
                do:
                    glog = yes .
                    find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
                    if available (buf_clients) then 
                        run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                    if not glog then return no-apply .
                end.
        end case .

        find first gds-list no-error .
        if not available (gds-list) then 
        do:
            if p-ok then 
            do:
                message "Не найдены товары для создания заказа."
                    view-as alert-box.
                return no-apply .
            end. 
            else run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
        end.

        assign
            t-daygoods
            RADIO-SET-1
            rs_period
            .
        if not p-ok and (SelectGood = 0 or SelectGood = 1) then 
        do:
           block-trn-doc: 
           for each buf_trn-doc no-lock where buf_trn-doc.obj-code = v-cntxt-obj-code and
                buf_trn-doc.obj-type = v-cntxt-obj-type and
                buf_trn-doc.cli-code = buf_clients.obj-code and
                buf_trn-doc.cli-type = buf_clients.obj-type and
                buf_trn-doc.ext-doc-type = {&tdedt_pri_vnesh} and
                buf_trn-doc.status_ = {&fact}:
                   if buf_trn-doc.contract-code <> 0 then do:
                      find first ub.contract no-lock where ub.contract.host-code = buf_trn-doc.host-code and
                            ub.contract.cli-code = buf_trn-doc.cli-code and
                            ub.contract.cli-type = buf_trn-doc.cli-type and
                            ub.contract.status_ = {&current-contr} and 
                            ub.contract.contract-code = buf_trn-doc.contract-code no-error.
                            if available ub.contract and
                            (ub.contract.contract-date-end > today or ub.contract.contract-date-end = ?) and
                                ub.contract.contract-date-beg <= today then 
                            do:
                            end.
                            else
                               next block-trn-doc.
                   end.
                   else release ub.contract .
                for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
                    first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                    buf_goods.prod-code = buf_doc-line.prod-code and
                    buf_goods.prod-type = buf_doc-line.prod-type:
                    if available ub.contract then 
                    do:
                            for first buf_contract-specif no-lock where
                            buf_contract-specif.host-code = ub.contract.host-code and
                            buf_contract-specif.contract-num = ub.contract.contract-code and
                            buf_contract-specif.gds-code = buf_goods.gds-code:
                                find first gds-list where gds-list.gds-code = buf_contract-specif.gds-code and
                                    gds-list.contract = ub.contract.contract-prn-code and
                                    gds-list.contract-code = buf_contract-specif.contract-num no-error .
                                if not available (gds-list) then
                                do:
                                    create gds-list .
                                    buffer-copy buf_goods to gds-list
                                        assign
                                        gds-list.contract-code = ub.contract.contract-code
                                        gds-list.contract      = ub.contract.contract-prn-code
                                        .
                                end.
                          
                        end.
                    end.
                    else 
                    do:
                        find first gds-list where gds-list.gds-code = buf_goods.gds-code no-error .
                        if not available (gds-list) then
                        do:
                            create gds-list .
                            buffer-copy buf_goods to gds-list .
                        end.
                    end.
                end.
            end.
        end .
        if p-ok and customer-name = "БЕЗ ДОГОВОРА" then 
        do:
            message "Внимание! Формирование заказа невозможно, выберите договор(-ы)"
                view-as alert-box.
            return no-apply .
        end.

        run rep/r-rsrv-plan.p(input parParentProc,
            input p-ok,
            input post-grp_recids,
            input Date-order,
            input rs_period,    
            input Date-Start,
            input Date-End,
            input RADIO-SET-1,
            input sale_day,    
            input garant_day,
            input t-daygoods,
            input table tt-typeDocChoose,
            input table tt-dateZakaz,
            input table gds-list
            ) .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-exit Dialog-Frame
ON CHOOSE OF i-exit IN FRAME Dialog-Frame
    DO:
        APPLY "choose" TO btn_ok.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-type-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-type-doc Dialog-Frame
ON CHOOSE OF b-type-doc IN FRAME Dialog-Frame
    DO:
        f-typedoc-desc = "" .
        run ref/type_doc.w (input parParentProc, input-output table tt-typeDocChoose ) .

        for each tt-typeDocChoose:
            f-typedoc-desc = f-typedoc-desc + ", " + tt-typeDocChoose.typeName .
        end.
        f-typedoc-desc = trim(f-typedoc-desc,", ") .
        display f-typedoc-desc with frame Dialog-Frame .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clients Dialog-Frame
ON CHOOSE OF b-clients IN FRAME Dialog-Frame
    DO:
        define buffer bf_contract  for ub.contract .
        define buffer cli-post     for ub.clients .
        define buffer buf_contract for ub.contract .
    
        define variable v-nn             as integer   no-undo .
        define variable ii               as integer   no-undo .
        define variable vIsChange        as logical   no-undo init no.
        define variable old-list-dogovor as character no-undo .

        if p-ok then 
        do:
            run ref/cli-all.w
                ( parParentProc
                , "b-sel"
                , {&all}
                , {&all}
                , {&current}
                , ?
                , ?
                , "contract-edi_orders"
                , output post-grp_recids ) .
        end.
        else 
        do:
            run ref/cli-all.w
                ( parParentProc
                , "b-sel"
                , {&all}
                , {&all}
                , {&current}
                , ?
                , ?
                , ""
                , output post-grp_recids ) .        
        end.
        if post-grp_recids <> "" then
        do:
            Assign
                text-cliname  = ''
                customer-name = "".
            v-nn = num-entries( post-grp_recids ) .
            DO ii = 1 TO v-nn :
                FIND cli-post WHERE recid( cli-post ) = int(entry( ii, post-grp_recids )) NO-LOCK.
                if v-cli-code <> cli-post.obj-code or v-cli-type <> cli-post.obj-type then
                    vIsChange = yes.
                assign 
                    v-cli-code   = cli-post.obj-code
                    v-cli-type   = cli-post.obj-type
                    v-cli-name   = cli-post.obj-name
                    text-cliname = cli-post.obj-type + " " + string(cli-post.obj-code) + " " + cli-post.obj-name .
            END.
            if p-ok then customer-name = {&ALL_DOG_EDI} .
            else customer-name = {&ALL_DOG} .
            SelectGood = 1 .
            if p-ok then customer-name = {&ALL_DOG_EDI} .
            else customer-name = {&ALL_DOG} .            
            list-dogovor = "" .
            v-rid-list = "" .
            Goods-Editor = "" .
            empty temp-table gds-list .
            Display text-cliname customer-name SelectGood Goods-Editor with frame Dialog-Frame .
            hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
        end.
        else 
        do:
            if v-cli-code <> ? and v-cli-code <> 0 then 
            do:
                find cli-post where cli-post.obj-code = v-cli-code and
                    cli-post.obj-type = v-cli-type no-lock .
                post-grp_recids = string(recid (cli-post)) .
            end.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
    DO:
        assign RADIO-SET-1 .
        case RADIO-SET-1:
            when 5 then 
                do: 
                    enable sale_day with frame Dialog-Frame .
                end.
            otherwise 
            do:
                disable sale_day with frame Dialog-Frame .  
            end.
        end case .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME sale_day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sale_day Dialog-Frame
ON leave OF sale_day IN FRAME Dialog-Frame
    DO:
        assign sale_day .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON LEAVE OF Date-End IN FRAME Dialog-Frame /* по */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON LEAVE OF Date-Start IN FRAME Dialog-Frame /* С */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME garant_day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL garant_day Dialog-Frame
ON leave OF garant_day IN FRAME Dialog-Frame
    DO:
        assign garant_day .
        if garant_day = ? then return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rs_period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs_period Dialog-Frame
ON VALUE-CHANGED OF rs_period IN FRAME Dialog-Frame
    DO:
        assign rs_period .
        case rs_period:
            when 1 then 
                do: 
                    enable Date-End Date-Start b-date-End b-date-Start with frame Dialog-Frame .      
                    disable bt-not-sel-all bt-not-sel-desel-all br_date with frame Dialog-Frame .  
                    empty temp-table tt-dateZakaz .
                    {&OPEN-QUERY-br_date}
                end.
            otherwise 
            do:
                disable Date-End Date-Start b-date-End b-date-Start with frame Dialog-Frame .      
                enable bt-not-sel-all bt-not-sel-desel-all br_date with frame Dialog-Frame .  
            end.
        end case .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectGood
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectGood Dialog-Frame
ON VALUE-CHANGED OF SelectGood IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients    for ub.clients .
        define buffer buf_goods-attr for ub.gds-obj-attr .
        define buffer bf_contract    for ub.contract .
        define buffer cli-post       for ub.clients .
        define buffer buf_contract   for ub.contract .
        
        define variable ii               as integer   no-undo .
        define variable v-nn             as integer   no-undo .
        define variable vIsChange        as logical   no-undo init no.
        define variable old-list-dogovor as character no-undo .
    
        assign SelectGood .
        find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
        if available (buf_clients) then 
        do:
            case SelectGood:
                when 1 or 
                when 0 then 
                    do: /* Все по поставщику */
                        v-rid-list = "" .
                        list-dogovor = "" .
                        empty temp-table gds-list . 
                        if p-ok then customer-name = {&ALL_DOG_EDI} .
                        else customer-name = {&ALL_DOG} .
                        hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
                        run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                    end.
                when 2 then 
                    do: /* Все по договору */
                        hide b-chooseContract b-chooseGoods in frame {&frame-name} .
                        enable b-contract with frame {&frame-name} .
                        list-dogovor = "" .  
                        Goods-Editor = "" .
                        v-rid-list = "" .
                        empty temp-table gds-list .   
                        APPLY "choose" TO b-contract .
                        list-dogovor =  trim (list-dogovor,",") .
                        if list-dogovor = "" then 
                        do: 
                            SelectGood = 1 .  
                            if p-ok then customer-name = {&ALL_DOG_EDI} .
                            else customer-name = {&ALL_DOG} .      
                            display SelectGood customer-name with frame {&frame-name} .                      
                            hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
                        end.
                    end.
                when 3 then 
                    do: /* Выборочно */
                        enable b-chooseContract b-chooseGoods with frame {&frame-name} .
                        hide b-contract in frame {&frame-name} .
                        list-dogovor = "" .
                        empty temp-table gds-list . 
                        APPLY "choose" TO b-contract .
                       if list-dogovor = "" then 
                        do:
                            SelectGood = 1 .
                            if p-ok then customer-name = {&ALL_DOG_EDI} .                          
                            else customer-name = {&ALL_DOG} .
                            display SelectGood customer-name with frame {&frame-name} .  
                            hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
                            return no-apply .
                        end.                        
                        APPLY "choose" TO b-chooseGoods .
                        find first gds-list no-error .
                        if not available (gds-list) then 
                        do:
                            SelectGood = 2 .
                            hide b-chooseContract b-chooseGoods in frame {&frame-name} .
                            enable b-contract with frame {&frame-name} .       
                            display SelectGood with frame {&frame-name} .  
                            run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                            return no-apply .
                        end.

                    end .
            end case.
        end.
        else 
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            SelectGood = 1 .
            hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .
            display SelectGood with frame {&frame-name} .  
        end.
        Goods-Editor = v-rid-list .
        if not vOk then display Goods-Editor with frame Dialog-Frame .

        for each gds-list:
            for first buf_goods-attr no-lock where buf_goods-attr.gds-code = gds-list.gds-code and
                buf_goods-attr.attr-code = {&attr-min-zapas-o}:
                gds-list.minZapas = decimal (buf_goods-attr.attr-value) .
            end.
        end.
        find first gds-list where gds-list.minZapas = 0 no-error .
        if available (gds-list) then
        do:
            if vOk then
            do:
                if p-ok then 
                do:
                    message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»" skip
                        "Создать заказ?"
                        view-as alert-box question buttons YES-NO update glog .
                end.
                else 
                do:
                    message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»" skip
                        "Вывести отчет?"
                        view-as alert-box question buttons YES-NO update glog .
                end.
                if not glog then
                do:
                    APPLY "choose" TO BUTTON-1 .
                end.
            end.
            else
            do:
                message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»"
                    view-as alert-box.
            end.
        end.
        display SelectGood customer-name Goods-Editor with frame {&frame-name} .      
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* Параметры */
    DO:
        DISPLAY {&page-1} with FRAME {&FRAME-NAME}.
        case SelectGood:
            when 1 or 
            when 0 then 
                do:
                    hide b-chooseContract b-chooseGoods b-contract in frame {&frame-name} .          
                end.
            when 2 then 
                do:
                    hide b-chooseContract b-chooseGoods in frame {&frame-name} .     
                    enable b-contract with frame {&frame-name} .     
                end.        
            when 3 then 
                do:
                    hide b-contract in frame {&frame-name} .     
                    enable b-chooseContract b-chooseGoods with frame {&frame-name} .           
                end.
        end case .
        HIDE {&page-2} IN FRAME {&FRAME-NAME}.
        button-1:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame {&frame-name} .
        button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
        F-button-1:fgcolor = 1 .
        f-button-2:fgcolor = ? .
   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* Продолжение */
    DO:
        assign
            garant_day
            Date-order
            .
        if text-cliname = "" then 
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            return no-apply .
        end.
        if SelectGood = 3 and Goods-Editor = "" then 
        do:
            message "Товар не выбран!"
                view-as alert-box.
            return no-apply .
        end.
        DISPLAY {&page-2} with FRAME {&FRAME-NAME}.
        HIDE {&page-1} IN FRAME {&FRAME-NAME}.
        button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame {&frame-name} .
        button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
        F-button-2:fgcolor = 1 .
        f-button-1:fgcolor = ? .
    
        fl = "2" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date Dialog-Frame
ON CHOOSE OF b-date IN FRAME Dialog-Frame /* b-date */
    DO:
        run sel-date in this-procedure
            (input Date-order :handle
            ,input ""
            ) .

        if date(Date-order:screen-value) < today then 
        do:
            message "Дата заказа должна быть равна или больше текущей"
                view-as alert-box.
            display Date-order with frame Dialog-Frame .
            return no-apply .
        end.   
        assign Date-order .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-order Dialog-Frame
ON LEAVE OF Date-order IN FRAME Dialog-Frame /* Date-order */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-order Dialog-Frame
ON RETURN OF Date-order IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-order Dialog-Frame
ON TAB OF Date-order IN FRAME Dialog-Frame
    DO:
        date(Date-order:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.  
            display Date-order with frame Dialog-Frame .
            return no-apply .          
        end.    
        if string(Date-order) <> Date-order:screen-value then 
        do:
            if date(Date-order:screen-value) < today then 
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display Date-order with frame Dialog-Frame .
                return no-apply.
            end. 
            assign Date-order .
            display Date-order with frame Dialog-Frame .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-Start Dialog-Frame
ON CHOOSE OF b-date-Start IN FRAME Dialog-Frame /* b-date-Start */
    DO:
        run sel-date in this-procedure
            (input Date-Start :handle
            ,input ""
            ) .
      
        if Date-End < date(Date-Start:screen-value) then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .    
        end.
      
        if date(Date-Start:screen-value) >= today then 
        do:
            message "Дата начала периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
            return no-apply .
        end.   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-End Dialog-Frame
ON CHOOSE OF b-date-End IN FRAME Dialog-Frame /* b-date-End */
    DO:
        run sel-date in this-procedure
            (input Date-End :handle
            ,input ""
            ) .
        if date(Date-End:screen-value) < Date-Start then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .    
        end.
        if date(Date-End:screen-value) >= today then 
        do:
            message "Дата окончания периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
            return no-apply .
        end.   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON RETURN OF Date-End IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON TAB OF Date-End IN FRAME Dialog-Frame
    DO:
        date(Date-End:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.      
            display Date-End with frame Dialog-Frame .
            return no-apply .  
        end.
        if string(Date-End) <> Date-End:screen-value then 
        do:
            if date(Date-End:screen-value) < Date-Start then 
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .       
            end.
            if date(Date-End:screen-value) >= today then 
            do:
                message "Дата окончания периода продаж должна быть меньше текущей"
                    view-as alert-box.
                display Date-End with frame Dialog-Frame .
                return no-apply.
            end. 
            assign Date-End .
            display Date-End with frame Dialog-Frame .
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON RETURN OF Date-Start IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON TAB OF Date-Start IN FRAME Dialog-Frame
    DO:
        date(Date-Start:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.     
            display Date-Start with frame Dialog-Frame .
            return no-apply . 
        end.
        if string(Date-Start) <> Date-Start:screen-value then 
        do:
            if Date-End < date(Date-Start:screen-value) then 
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .       
            end.
            if date(Date-Start:screen-value) >= today then 
            do:
                message "Дата начала периода продаж должна быть меньше текущей"
                    view-as alert-box.
                display Date-Start with frame Dialog-Frame .
                return no-apply.
            end. 
            assign Date-Start .
            display Date-Start with frame Dialog-Frame .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br_date
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    
    { gbl/ed_date.i Date-order }
{ gbl/ed_date.i Date-Start }  
{ gbl/ed_date.i Date-End }

if p-ok then v-title = "Заказ товаров Магазина" .
else v-title = "Отчет по планированию заказа товаров Магазина и готовой продукции Кафе" .    
Date-order = today .
Date-End = today - 1 .
Date-Start = today - 28 .

/* Документы */
find first tt-typeDocChoose no-error .
if not available (tt-typeDocChoose) then 
do:
    create tt-typeDocChoose .
    assign
        tt-typeDocChoose.type-code = {&TDEDT_Ras_Vnesh_Kass}
        tt-typeDocChoose.typeName  = "расход внешний касса"
        .
    create tt-typeDocChoose .
    assign
        tt-typeDocChoose.type-code = {&TDEDT_Vozvrat_Vnesh_Kass}
        tt-typeDocChoose.typeName  = "возврат внешний касса"
        .    
end.  
for each tt-typeDocChoose:
    f-typedoc-desc = f-typedoc-desc + ", " + tt-typeDocChoose.typeName .
end.
f-typedoc-desc = trim(f-typedoc-desc,", ") .
display f-typedoc-desc with frame Dialog-Frame .
RUN enable_UI.
apply  "CHOOSE":U   to  button-1 in frame {&frame-name} .

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
    DISPLAY Date-order rs_period text-sale-list1 text-period_list2 Date-Start 
        Date-End RADIO-SET-1 sale_day garant_day text-client text-dogovor 
        customer-name text-googs SelectGood 
        t-daygoods Goods-Editor F-button-1 F-button-2 text-cliname
        WITH FRAME Dialog-Frame.
    ENABLE b-exit Btn_OK i-exit BUTTON-1 RECT-5 RECT-6 BUTTON-2 
        RECT-7 Date-order b-date rs_period Date-Start Date-End RADIO-SET-1 
        br_date garant_day b-clients customer-name SelectGood b-chooseContract b-chooseGoods
        t-daygoods Goods-Editor F-button-1 F-button-2 b-date-End b-date-Start b-contract
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    hide b-type-doc text-typedoc_list-2 f-typedoc-desc in frame Dialog-Frame .
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEdiDocs Dialog-Frame 
PROCEDURE getGoods :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input parameter p-list-dogovor as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define variable ii as integer no-undo .
    define buffer buf_trn-doc         for ub.trn-doc . 
    define buffer buf_doc-line        for ub.doc-line .
    define buffer buf_goods           for ub.goods .
    define buffer buf_contract-specif for ub.contract-specif .
  
    case SelectGood:
        when 1 or 
        when 0 then 
            do:
                if not p-ok then 
                do:
                    if list-dogovor <> "" then
                    do:
                        list-dogovor = "".
                        customer-name = "БЕЗ ДОГОВОРА" .
                        display customer-name with frame Dialog-Frame .
                    end.
                end.
                else 
                do:
                    for each ub.contract no-lock where ub.contract.cli-code = p-obj-code and
                        ub.contract.cli-type = p-obj-type and
                        (ub.contract.contract-date-end > today or ub.contract.contract-date-end = ?) and
                        ub.contract.contract-date-beg <= today and
                        ub.contract.status_ = {&current-contr}:

                        find first ub.contract-attr no-lock where ub.contract-attr.contract-code = ub.contract.contract-code and
                            ub.contract-attr.host-code = ub.contract.host-code and
                            ub.contract-attr.attr-code = "contract-edi_orders" and
                            ub.contract-attr.attr-value = string (true) no-error .
                        if not available (ub.contract-attr) then next .

                        for each buf_contract-specif no-lock where
                            buf_contract-specif.contract-num = ub.contract.contract-code :
                            find first gds-list where gds-list.gds-code = ub.contract-specif.gds-code and
                                gds-list.contract = ub.contract.contract-prn-code no-error .
                            if not available (gds-list) then
                            do:
                                find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
                                if available (buf_goods) then
                                do:                                          
                                    create gds-list .
                                    buffer-copy buf_goods to gds-list assign
                                        gds-list.contract-code = ub.contract.contract-code
                                        gds-list.contract      = ub.contract.contract-prn-code
                                        .
                                end.
                            end.
                        end.
                    end.

                   
                end.
            end.
        when 2 then 
            do:
                do ii = 1 to num-entries (list-dogovor):
                    find first ub.contract no-lock where ub.contract.contract-code = integer(entry(ii,list-dogovor,",")) no-error .
                    for each buf_contract-specif no-lock where buf_contract-specif.contract-num = ub.contract.contract-code:

                        find first gds-list where gds-list.gds-code = buf_contract-specif.gds-code and
                            gds-list.contract-code = buf_contract-specif.contract-num no-error .
                        if not available (gds-list) then
                        do:
                            find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
                            if available (buf_goods) then
                            do:
                                create gds-list .
                                buffer-copy buf_goods to gds-list assign
                                    gds-list.contract-code = ub.contract.contract-code
                                    gds-list.contract = ub.contract.contract-prn-code
                                    .
                            end.
                        end.
                    end.
                end.    
            end.

    end case .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION customerName Dialog-Frame 
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define variable ii    as integer   no-undo .
    define variable name_ as character no-undo .
    define buffer buf_contract for ub.contract .
 
    do ii = 1 to num-entries(p-dogovor):                                                                            
        find first buf_contract no-lock where buf_contract.contract-code = integer(entry(ii,p-dogovor,",")) no-error .
        if available (buf_contract) then
        do:
            name_ = name_ + ", " + buf_contract.contract-prn-code .
        end.
    end.  
    if name_ <> "" then name_ = trim(name_,",") .       
    RETURN name_ .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

