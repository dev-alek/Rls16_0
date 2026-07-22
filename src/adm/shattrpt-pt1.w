&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр шапки документа

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр шапки документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/color.i    }
{ gbl/twowin.i   }
{ str/trdcalib.i }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
{ cmp/trg-def.i  }
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.

define variable v-tth           as   handle       no-undo .
define variable v-to-create     as   logical      no-undo .
DEFINE VARIABLE v-db-num        like ub.db.db-num no-undo.

define variable v-list-dop-info-full as character    no-undo.
define variable v-list-dop-info      as character    no-undo.

define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

define variable v-list-sec-fields-full as character    no-undo.
define variable v-list-sec-fields      as character    no-undo.

define temp-table sect_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.

DEFINE VARIABLE parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE VARIABLE p-mode        AS CHARACTER           NO-UNDO.
DEFINE VARIABLE p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES clients
&Scoped-define FIRST-EXTERNAL-TABLE clients


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR clients.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-3 RECT-2 RECT-5 RECT-6 RECT-7 ~
r-algoincptrl t-mand-chioce-autocar t-trn-reas-sug t-calc-free-vol ~
t-calc-free-vol-sug r-expptrl r-inpptrl B-set_dop-info B-set_sec-fields ~
sec-fields r-temp-for-pomi r-algrvspt t-rvsnmter t-invclipt f-invclipt ~
b-invclipt r-denstclc mass-proc mass-proc-in-lgas otkl-fact-volue otkl-temp ~
otkl-density otkl-water v-dop-info v-sec-fields 
&Scoped-Define DISPLAYED-OBJECTS r-algoincptrl t-mand-chioce-autocar ~
t-trn-reas-sug t-calc-free-vol t-calc-free-vol-sug r-expptrl r-inpptrl ~
dop-info sec-fields r-temp-for-pomi r-algrvspt t-rvsnmter t-invclipt ~
f-invclipt r-denstclc mass-proc mass-proc-in-lgas otkl-fact-volue otkl-temp ~
Prc-dev-mass otkl-density otkl-water Dev-paid-trans v-dop-info v-sec-fields ~
f-invclipt-name 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-invclipt 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .92.

DEFINE BUTTON B-set_dop-info 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 2.63 BY 1.08.

DEFINE BUTTON B-set_sec-fields 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 2.63 BY 1.08.

DEFINE VARIABLE dop-info AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51 BY 3 NO-UNDO.

DEFINE VARIABLE sec-fields AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 1 BY 1 NO-UNDO.

DEFINE VARIABLE Dev-paid-trans AS DECIMAL FORMAT "->9.99":U INITIAL 1 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE f-invclipt LIKE clients.obj-code
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-invclipt-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 78 BY 1 NO-UNDO.

DEFINE VARIABLE mass-proc AS CHARACTER FORMAT "X(256)":U 
     LABEL "  Допустимый % расхождения массы в резервуаре" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE mass-proc-in-lgas AS DECIMAL FORMAT ">9.99":U INITIAL 0 
     LABEL "Допустимый % расхождения массы при приеме СУГ" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE otkl-density AS CHARACTER FORMAT "9X999":U INITIAL "0.000" 
     LABEL "Плотности" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE otkl-fact-volue AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Фактического объема" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE otkl-temp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Температуры" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE otkl-water AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Воды" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE Prc-dev-mass AS DECIMAL FORMAT "->9.99":U INITIAL .65 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-dop-info AS CHARACTER FORMAT "X(256)":U INITIAL "Обязательные поля доп.инфо. ПН по НП" 
      VIEW-AS TEXT 
     SIZE 37.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-sec-fields AS CHARACTER FORMAT "X(256)":U INITIAL "Обязательные поля в секциях ПН по НП" 
      VIEW-AS TEXT 
     SIZE 37.5 BY 1 NO-UNDO.

DEFINE VARIABLE r-algoincptrl AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "стандарт", 1,
"с комиссионным приемом", 2
     SIZE 37 BY 1 NO-UNDO.

DEFINE VARIABLE r-algrvspt AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Алгоритм N1", 1,
"Алгоритм N2", 2,
"Алгоритм N3", 3,
"Алгоритм N4", 4
     SIZE 71.5 BY .83 NO-UNDO.

DEFINE VARIABLE r-denstclc AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "среднее по сменной сверке и внеш.приходам (shft_rvs-inc)", "shft_rvs-inc",
"среднее по сверкам (avrg-rvs)", "avrg-rvs",
"среднеарифметическое значение окаймляющих сверок (avrg-chk)", "avrg-chk",
"среднее значение по расчетно-книжным данным (shft_sys-inc)", "shft_sys-inc",
"плотность, аппроксимирующая расчетно-книжные остатки к фактическим (fact-approx)", "fact-approx"
     SIZE 84.5 BY 2.75 NO-UNDO.

DEFINE VARIABLE r-expptrl AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Масса", "weight",
"Объем", "volume"
     SIZE 23.5 BY .83 NO-UNDO.

DEFINE VARIABLE r-inpptrl AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Масса+плотность", "weight",
"Объем+плотность", "volume",
"Масса+объем", "weight+",
"Объем+масса", "volume+"
     SIZE 66 BY .83 NO-UNDO.

DEFINE VARIABLE r-temp-for-pomi AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "15°С", 1,
"20°С", 2
     SIZE 17 BY .75 TOOLTIP "Используется только при передаче в ПО к МИ" NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 118 BY 4.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 118 BY 4.25.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 118 BY 2.5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 56.38 BY 2.5.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 61 BY 5.5.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 56.38 BY 3.

DEFINE VARIABLE t-calc-free-vol AS LOGICAL INITIAL no 
     LABEL "Контроль свободного объема в резервуаре при приеме НП" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-calc-free-vol-sug AS LOGICAL INITIAL no 
     LABEL "Контроль свободного объема в резервуаре при приеме СУГ" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-invclipt AS LOGICAL INITIAL no 
     LABEL "Контрагент для списания ЕУ при инвентаризации топлива по сверке:" 
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY .83 NO-UNDO.

DEFINE VARIABLE t-mand-chioce-autocar AS LOGICAL INITIAL no 
     LABEL "Обязательный выбор автотранспорта из справочника" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-rvsnmter AS LOGICAL INITIAL no 
     LABEL "Расхождение в инвентаризации по сверке делать без учета погрешности измерения" 
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-trn-reas-sug AS LOGICAL INITIAL no 
     LABEL "Обязательный выбор этапа для приема газовоза" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     r-algoincptrl AT ROW 1.25 COL 36.5 NO-LABEL WIDGET-ID 118
     t-mand-chioce-autocar AT ROW 2.25 COL 2 WIDGET-ID 106
     t-trn-reas-sug AT ROW 3 COL 2 WIDGET-ID 532
     t-calc-free-vol AT ROW 3.75 COL 2 WIDGET-ID 534
     t-calc-free-vol-sug AT ROW 4.5 COL 2 WIDGET-ID 536
     r-expptrl AT ROW 6 COL 66 NO-LABEL WIDGET-ID 50
     r-inpptrl AT ROW 6.75 COL 53 NO-LABEL WIDGET-ID 526
     dop-info AT ROW 8 COL 45.5 NO-LABEL WIDGET-ID 492
     B-set_dop-info AT ROW 8.25 COL 41 WIDGET-ID 496
     B-set_sec-fields AT ROW 9.25 COL 41 WIDGET-ID 596
     sec-fields AT ROW 9.25 COL 45.5 NO-LABEL WIDGET-ID 592
     r-temp-for-pomi AT ROW 11.25 COL 61 NO-LABEL WIDGET-ID 96
     r-algrvspt AT ROW 12.5 COL 38.5 NO-LABEL WIDGET-ID 80
     t-rvsnmter AT ROW 13.5 COL 2.5 WIDGET-ID 58
     t-invclipt AT ROW 14.25 COL 2.5 WIDGET-ID 74
     f-invclipt AT ROW 15.25 COL 2.5 HELP
          "" NO-LABEL WIDGET-ID 60
     b-invclipt AT ROW 15.25 COL 13 WIDGET-ID 68
     r-denstclc AT ROW 17.5 COL 2.5 NO-LABEL WIDGET-ID 518
     mass-proc AT ROW 20.5 COL 48 COLON-ALIGNED WIDGET-ID 100
     mass-proc-in-lgas AT ROW 21.5 COL 3 WIDGET-ID 600
     otkl-fact-volue AT ROW 23.75 COL 84.13 COLON-ALIGNED WIDGET-ID 506
     otkl-temp AT ROW 24.75 COL 84.13 COLON-ALIGNED WIDGET-ID 508
     Prc-dev-mass AT ROW 25.42 COL 53.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 616
     otkl-density AT ROW 25.75 COL 84.13 COLON-ALIGNED WIDGET-ID 510
     otkl-water AT ROW 26.75 COL 84.13 COLON-ALIGNED WIDGET-ID 512
     Dev-paid-trans AT ROW 26.83 COL 53.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 8
     v-dop-info AT ROW 8.25 COL 2.5 NO-LABEL WIDGET-ID 498
     v-sec-fields AT ROW 9.25 COL 2.5 NO-LABEL WIDGET-ID 598
     f-invclipt-name AT ROW 15.25 COL 16.5 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     "%" VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 25.42 COL 55.38 WIDGET-ID 624
     "Относительная предельная погрешность" VIEW-AS TEXT
          SIZE 37 BY .67 AT ROW 22.83 COL 5.25 WIDGET-ID 112
     "до 200т. - ±0,65%     более 200т. - ±0,5%" VIEW-AS TEXT
          SIZE 42 BY .67 AT ROW 24.42 COL 2.88 WIDGET-ID 610
     "Максимально допустимые отклонения:" VIEW-AS TEXT
          SIZE 33.75 BY .79 AT ROW 22.83 COL 61.38 WIDGET-ID 504
     "Допустимое отклонение между объемом продаж" VIEW-AS TEXT
          SIZE 43 BY .63 AT ROW 26.83 COL 2.63 WIDGET-ID 620
     "метода измерения массы в резервуаре" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 23.67 COL 5.5 WIDGET-ID 608
     "Алгоритм принятия топлива к учету:" VIEW-AS TEXT
          SIZE 34.5 BY 1 AT ROW 1.25 COL 2 WIDGET-ID 116
     "Тип ввода топлива во всех документах кроме прихода внешнего :" VIEW-AS TEXT
          SIZE 63 BY .83 AT ROW 6 COL 2.5 WIDGET-ID 514
     "Тип ввода топлива в документах прихода внешнего :" VIEW-AS TEXT
          SIZE 49 BY .83 AT ROW 6.71 COL 2.5 WIDGET-ID 48
     "Алгоритм вычисления плотности топлива для продаж :" VIEW-AS TEXT
          SIZE 50.5 BY .63 AT ROW 16.75 COL 3 WIDGET-ID 36
     "Температура, к которой приводится плотность и объем °С :" VIEW-AS TEXT
          SIZE 58 BY .83 AT ROW 11.25 COL 2.5 WIDGET-ID 516
     "Настройки инвентаризации по сверке" VIEW-AS TEXT
          SIZE 35.5 BY .67 AT ROW 12.5 COL 2.5 WIDGET-ID 78
     "топлива на кассе и объемом по счетчик" VIEW-AS TEXT
          SIZE 43.5 BY .58 AT ROW 27.54 COL 2.63 WIDGET-ID 618
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME F-Main
     "Процент допустимого отклонения массы" VIEW-AS TEXT
          SIZE 38.25 BY .75 AT ROW 25.42 COL 2.63 WIDGET-ID 622
     "топлива на конец смены" VIEW-AS TEXT
          SIZE 38.75 BY .58 AT ROW 26.13 COL 2.63 WIDGET-ID 626
     "л." VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 26.83 COL 55.38 WIDGET-ID 10
     RECT-1 AT ROW 16.5 COL 1.5 WIDGET-ID 38
     RECT-3 AT ROW 5.5 COL 1.5 WIDGET-ID 66
     RECT-2 AT ROW 12.25 COL 1.5 WIDGET-ID 64
     RECT-5 AT ROW 22.75 COL 2 WIDGET-ID 500
     RECT-6 AT ROW 22.75 COL 58 WIDGET-ID 502
     RECT-7 AT ROW 25.25 COL 2 WIDGET-ID 612
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   External Tables: ub.clients
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 27.42
         WIDTH              = 118.75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN Dev-paid-trans IN FRAME F-Main
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR EDITOR dop-info IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       dop-info:HIDDEN IN FRAME F-Main           = TRUE
       dop-info:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-invclipt IN FRAME F-Main
   ALIGN-L LIKE = ub.clients.obj-code EXP-LABEL EXP-HELP EXP-SIZE       */
/* SETTINGS FOR FILL-IN f-invclipt-name IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       f-invclipt-name:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN mass-proc-in-lgas IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN Prc-dev-mass IN FRAME F-Main
   NO-ENABLE ALIGN-R                                                    */
ASSIGN 
       sec-fields:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN v-dop-info IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-sec-fields IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-invclipt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-invclipt V-table-Win
ON CHOOSE OF b-invclipt IN FRAME F-Main
DO:
  define variable rid-list as character no-undo .
  define buffer buf_clients for ub.clients.

    run ref/cli-all.w
      ( input parParentProc
      , input "b-sel"
      , input {&cmp}
      , input {&all}
      , input {&current}
      , input ?
      , input "yes,yes,yes,,,,ИЛИ"
      , input "lock-cli-type":U
      , output rid-list
      ) .

    find first buf_clients no-lock
      where recid(buf_clients) = integer( rid-list )
      no-error.
    if available buf_clients then do:
      assign
        f-invclipt      = buf_clients.obj-code
        f-invclipt-name = buf_clients.obj-name
      .
    end.
    else do:
      assign
        f-invclipt      = ?
        f-invclipt-name = "":U
      .
    end.

    display
      f-invclipt
      f-invclipt-name
      with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-set_dop-info
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-set_dop-info V-table-Win
ON CHOOSE OF B-set_dop-info IN FRAME F-Main
DO:
  run select-dop-info in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-set_sec-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-set_sec-fields V-table-Win
ON CHOOSE OF B-set_sec-fields IN FRAME F-Main
DO:
  run select-sec-fields in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME otkl-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL otkl-density V-table-Win
ON LEAVE OF otkl-density IN FRAME F-Main /* Плотности */
DO:
  assign
  otkl-density no-error  .
  if error-status:error or decimal (otkl-density) > 1 then do:
    message "Формат поля должен быть меньше единицы и три знака после запятой"
    view-as alert-box.
    RETURN NO-APPLY.
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME otkl-fact-volue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL otkl-fact-volue V-table-Win
ON LEAVE OF otkl-fact-volue IN FRAME F-Main /* Фактического объема */
DO:
  assign
  otkl-fact-volue
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME otkl-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL otkl-temp V-table-Win
ON LEAVE OF otkl-temp IN FRAME F-Main /* Температуры */
DO:
  assign
  otkl-temp
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME otkl-water
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL otkl-water V-table-Win
ON LEAVE OF otkl-water IN FRAME F-Main /* Воды */
DO:
  assign
  otkl-water
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-invclipt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-invclipt V-table-Win
ON VALUE-CHANGED OF t-invclipt IN FRAME F-Main /* Контрагент для списания ЕУ при инвентаризации топлива по сверке: */
DO:
  assign
    t-invclipt
  .
  if t-invclipt = true then do:
    enable
      f-invclipt
      b-invclipt
      with frame {&frame-name} .
    display
      f-invclipt-name
      with frame {&frame-name} .
  end.
  else do:
    assign
      f-invclipt       = ?
      f-invclipt-name = "":U
    .
    display
      f-invclipt
      f-invclipt-name
      with frame {&frame-name} .
    hide
      f-invclipt
      b-invclipt
      f-invclipt
      in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */
/* no_app_help.i */
{ gbl/personly.i }

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF
        
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "clients"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "clients"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}
  if p-mode = {&lookup} then do:        
      run disable-all IN THIS-PROCEDURE.          
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-all V-table-Win  _DEFAULT-DISABLE
PROCEDURE disable-all :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/  
    disable
      all
      with frame {&frame-name} .       
    enable      
      B-set_dop-info
      B-set_sec-fields
      with frame {&frame-name} .
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PartOne-Init V-table-Win 
PROCEDURE PartOne-Init :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER iParparentproc AS WIDGET-HANDLE       NO-UNDO.
  DEFINE INPUT PARAMETER iMode          AS CHARACTER           NO-UNDO.
  DEFINE INPUT PARAMETER iObjtype       LIKE ub.clients.obj-type NO-UNDO.
  DEFINE INPUT PARAMETER iObjcode       LIKE ub.shop.obj-code    NO-UNDO.
  DEFINE INPUT PARAMETER TABLE FOR temp-thbj-attr.
  
  define variable v-entry           as character  no-undo .
  define buffer buf_clients for ub.clients .
  
  assign
     parparentproc = iParparentproc
     p-mode        = iMode
     p-obj-type    = iObjtype
     p-obj-code    = iObjcode
     .
  for each temp-thbj-attr no-lock      
        :     
        
    assign
      v-entry = temp-thbj-attr.prop-code
    .
    case v-entry:
      when {&attr-petrol_denstclc} then do:
        assign
          r-denstclc = temp-thbj-attr.property-value-character
          r-denstclc :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
    /*------------------
      when {&attr-petrol_autopump} then do:
        assign
          t-autopump = temp-thbj-attr.property-value-logical
          t-autopump :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
        when {&attr-petrol_autopump-izm} then do: 
          assign t-autopump-izm =  temp-thbj-attr.property-value-logical
                 t-autopump-izm :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
          end.
     ------------------*/
         /* 
      when {&attr-petrol_autopump-skip-time} then do: 
          assign t-autopump-skip-time =  temp-thbj-attr.property-value-integer
             t-autopump-skip-time :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      */
      /*-----------    
      when {&attr-petrol_avtinvpm} then do:
        assign
          t-avtinvpm = temp-thbj-attr.property-value-logical
          t-avtinvpm :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      -----*/
      when {&attr-petrol_expptrl} then do:
        assign
          r-expptrl = temp-thbj-attr.property-value-character
          r-expptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_inpptrl} then do:
        assign
          r-inpptrl = temp-thbj-attr.property-value-character
          r-inpptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_rvsnmter} then do:
        assign
          t-rvsnmter = temp-thbj-attr.property-value-logical
          t-rvsnmter :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_invclipt} then do:
        assign
          f-invclipt = temp-thbj-attr.property-value-integer
          f-invclipt :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      /*------------
      when {&attr-petrol_olddens} then do:
        assign
          t-olddens = temp-thbj-attr.property-value-logical
          t-olddens :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      --------*/
      when {&attr-petrol_algrvspt} then do:
        assign
          r-algrvspt = temp-thbj-attr.property-value-integer
          r-algrvspt :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      when {&attr-petrol_temp-for-pomi} then do:
        assign
          r-temp-for-pomi = temp-thbj-attr.property-value-integer
          r-temp-for-pomi :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      /*
      when {&attr-petrol_rvs-wt-email} then do:
        assign
          rvs-wt-email = temp-thbj-attr.property-value-character
          rvs-wt-email :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
        .
      end.
      */
      when {&attr-petrol_CriticalDif} then 
          do:
            assign 
              mass-proc = temp-thbj-attr.property-value-character 
              mass-proc :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
      when {&attr-petrol_algoincome} then 
          do: 
            assign
              r-algoincptrl = temp-thbj-attr.property-value-integer 
              r-algoincptrl :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.
      when {&attr-petrol_otkl-fact-volue} then 
          do: 
            assign
              otkl-fact-volue = temp-thbj-attr.property-value-decimal 
              otkl-fact-volue :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.
      when {&attr-petrol_otkl-temp} then 
          do: 
            assign
              otkl-temp = temp-thbj-attr.property-value-decimal 
              otkl-temp :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.          
      when {&attr-petrol_otkl-density} then 
          do: 
            assign
              otkl-density = temp-thbj-attr.property-value-character 
              otkl-density :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
              if otkl-density = "" then otkl-density = "0.000" .
          end.          
      when {&attr-petrol_otkl-water} then 
          do: 
            assign
              otkl-water = temp-thbj-attr.property-value-decimal 
              otkl-water :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
              .
          end.                                            
      when {&attr-petrol_mand-choice-autocar} then 
          do: 
            assign
              t-mand-chioce-autocar = temp-thbj-attr.property-value-logical 
              t-mand-chioce-autocar :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
          /*
      when {&attr-petrol_block-nozzle} then 
          do: 
            assign
              t-block-nozzle = temp-thbj-attr.property-value-logical 
              t-block-nozzle :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.          
      when {&attr-petrol_timeout-block-nozzle} then 
          do: 
            assign
              timeout-block-nozzle = temp-thbj-attr.property-value-integer 
              timeout-block-nozzle :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
          */  
        when {&attr-petrol_dop-info} then 
          do:
            assign 
              dop-info = temp-thbj-attr.property-value-character 
              dop-info :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_sec-fields} then 
          do:
            assign 
              sec-fields = temp-thbj-attr.property-value-character 
              sec-fields :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_CriticalDifInLgas} then 
          do:
            assign 
              mass-proc-in-lgas = temp-thbj-attr.property-value-decimal 
              mass-proc-in-lgas :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_calc-free-vol} then 
          do: 
            assign
              t-calc-free-vol = temp-thbj-attr.property-value-logical 
              t-calc-free-vol :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_calc-free-vol-sug} then 
          do: 
            assign
              t-calc-free-vol-sug = temp-thbj-attr.property-value-logical 
              t-calc-free-vol-sug :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        when {&attr-petrol_trn-reas-sug} then 
          do: 
            assign
              t-trn-reas-sug = temp-thbj-attr.property-value-logical 
              t-trn-reas-sug :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        /*  
        when {&attr-petrol_rvd-own-nb} then 
          do: 
            assign
              t-rvd-own-nb = temp-thbj-attr.property-value-logical 
              t-rvd-own-nb :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.          
        when {&attr-petrol_qr-scan-time} then
          do:
            assign
              qr-scan-time = temp-thbj-attr.property-value-integer
              qr-scan-time :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .
        end.        
        when {&attr-petrol_trnscanqr} then 
          do: 
            assign
              t-trnscanqr = temp-thbj-attr.property-value-logical 
              t-trnscanqr :private-data in frame {&frame-name} = "recid=" + string(recid(temp-thbj-attr))
            .  
          end.
        */  
        otherwise do:
            delete temp-thbj-attr.
        end.
    end case.  
  end.
  
  find first buf_clients no-lock
    where buf_clients.obj-code = f-invclipt
      and buf_clients.obj-type = {&cmp}
    no-error.
  if available buf_clients then do:
    assign
      t-invclipt      = true
      f-invclipt-name = buf_clients.obj-name
    .
  end.
  else do:
    assign
      t-invclipt      = false
      f-invclipt-name = "":U
    .
  end.
  
  RUN proc-init-dop-info.
  RUN proc-init-sec-fields.
  
  define variable v-obj-code as integer no-undo .
  define variable v-obj-type as character no-undo .
  if p-obj-code = 0 then do:
      assign
      v-obj-code = v-cntxt-obj-code
      v-obj-type = v-cntxt-obj-type
      .
  end.
  else do:
      assign
      v-obj-code = p-obj-code
      v-obj-type = p-obj-type
      .      
  end.
  
    find last ub.shift-obj no-lock where ub.shift-obj.obj-code = v-obj-code and
        ub.shift-obj.obj-type = v-obj-type no-error .
    if available (ub.shift-obj) then 
    do:
        find first ub.shift-param no-lock where ub.shift-param.obj-code = ub.shift-obj.obj-code and
            ub.shift-param.obj-type = ub.shift-obj.obj-type and
            ub.shift-param.shift-date = ub.shift-obj.shift-date and
            ub.shift-param.shift-name = ub.shift-obj.shift-name and
            ub.shift-param.shift-num = ub.shift-obj.shift-num no-error .
        if not available (ub.shift-param) then 
        do:
            find first ub.shift-param no-lock where ub.shift-param.obj-code = 0 and
                ub.shift-param.obj-type = "" and
                ub.shift-param.shift-date = 01.01.1900 no-error .
            if available (ub.shift-param) then
                assign
                    dev-paid-trans = ub.shift-param.dev-paid-trans
                    prc-dev-mass   = ub.shift-param.prc-dev-mass
                    .
        end.
        else 
        do:
            assign
                dev-paid-trans = ub.shift-param.dev-paid-trans
                prc-dev-mass   = ub.shift-param.prc-dev-mass
                .
        end.
    end.         
    display dev-paid-trans prc-dev-mass with frame {&frame-name} .
 
  apply "value-changed" to t-invclipt in frame {&frame-name} .
     
  DISPLAY {&DISPLAYED-OBJECTS}
      WITH FRAME {&FRAME-NAME}.    
  hide dop-info in frame {&frame-name} .
  hide sec-fields in frame {&frame-name} .
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
   
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PartOne-Get V-table-Win  _ADM-SEND-RECORDS
PROCEDURE PartOne-Get :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/
   DEFINE OUTPUT PARAMETER TABLE FOR temp-thbj-attr.
  
   define variable wh                as widget-handle  no-undo .
   define variable fh                as widget-handle  no-undo . 
   define buffer buf_clients for ub.clients .
   
   ASSIGN FRAME {&FRAME-NAME} {&DISPLAYED-OBJECTS}.

   display dop-info sec-fields with frame {&frame-name} .
   hide dop-info sec-fields in frame {&frame-name} .

  
  assign
    frame {&frame-name} t-invclipt
    frame {&frame-name} f-invclipt  
    fh = frame {&frame-name}:first-child
    wh = fh:first-child
  .

  if t-invclipt = true then do:
    find first buf_clients no-lock
      where buf_clients.obj-code = f-invclipt
        and buf_clients.obj-type = {&cmp}
      no-error.
    if not available buf_clients then do:
      message
        "Некорректное значение НАСТРОЙКИ"    skip
        t-invclipt:label                     skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  do while valid-handle(wh):
    if wh:private-data begins "recid=" then do:
      find first temp-thbj-attr  
        where recid(temp-thbj-attr) = integer(entry(2, wh:private-data, '='))
      .                    
      assign
        buffer temp-thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      .
    end.
    wh = wh:next-sibling.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-dop-info shattrpt 
PROCEDURE proc-init-dop-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


   assign
      v-list-dop-info      = {&trdcattr-car-num} + "," + {&trdcattr-fio-driver} + "," + {&trdcattr-time-income} + "," + {&trdcattr-date-income} + "," + {&trdcattr-time-pour} + "," + {&trdcattr-date-pour} + "," + {&trdcattr-inspection-cert} + ","
      + {&trdcattr-date-cert} + "," + {&trdcattr-date-pasport}  + "," + {&trdcattr-num-pasport} + "," + {&trdcattr-condition} + "," + {&trdcattr-seals-condition} + "," + {&trdcattr-acc-ship} + "," + {&trdcattr-doc-not} + "," + {&trdcattr-spisok-not-doc} + "," + {&trdcattr-ptbobj} + 
      "," + {&trdcattr-ptb-item-pour} + "," + {&trdcattr-autoent}.
      v-list-dop-info-full = {&label-trdcattr-car-num} + "," + {&label-trdcattr-fio-driver} + "," + {&label-trdcattr-time-income} + "," + {&label-trdcattr-date-income} + "," + {&label-trdcattr-time-pour} + "," + {&label-trdcattr-date-pour} + "," + {&label-trdcattr-inspection-cert} + ","
      + {&label-trdcattr-date-cert} + "," + {&label-trdcattr-date-pasport} + "," + {&label-trdcattr-num-pasport} + "," + {&label-trdcattr-condition} + "," + {&label-trdcattr-seals-condition} + "," + {&label-trdcattr-acc-ship} + "," + {&label-trdcattr-doc-not} + "," + {&label-trdcattr-spisok-not-doc} +
       "," + {&label-trdcattr-ptbobj} + "," + {&label-trdcattr-ptb-item-pour} + "," + {&label-trdcattr-autoent}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-sec-fields shattrpt 
PROCEDURE proc-init-sec-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


   assign
      v-list-sec-fields      = "section-name,cli-qnty,doc-dens,group-np,list-tank,"
                             + "ttn-temp,acc-ship,doc-dens-st,doc-qnty,doc-volume,"
                             + "shape,pour,num-passport,car-vol,pasp-dens,"
                             + "a-b-tarir,tank-density,tank-temp,dens-temp,"
                             + "place-si,place-si-temp,accessIDLowerLevel".
      v-list-sec-fields-full = "Номер секции,Масса по док.,Плотность по док. (при раб. темп.),Группа НП/Давление насыщенных паров,Резервуар,"
                             + "Температура по ТТН,Погр. изм. пост.,Плотность по док. (при станд. темп.),Кол-во по док.,Объем по док.,"
                             + "Форма горловины,Тип налива,Дата и номер паспорта качества,Объем по свидетельству о поверке,Плотность по паспорту,"
                             + "Отклонение от тарировочной планки,Плотность топлива,Температура замера объема,Температура замера плотности,"
                             + "Средство измерения плотности,Средство измерения температуры,Идентиф. доступа (ключ) «нижнего уровня»".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-dop-info shattrpt 
PROCEDURE select-dop-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical    no-undo.
define variable v-accepted      as logical    no-undo.
define variable v-mode          as integer    no-undo.
define variable V-EX as logical   no-undo .

do
with frame {&frame-name}
on error undo, return error
:
if p-mode = {&lookup} then v-mode = 0 .
else v-mode = 1 .

    run twowin_clear in this-procedure.

    do v-counter = 1 to num-entries( v-list-dop-info-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-dop-info-full )
            v-value = entry( v-counter, v-list-dop-info )
            v-ex = false
        .
           if  lookup (v-value , dop-info ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Обязательные поля: &1", v-VALUE)
            , input  V-EX
        ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор обязательного поля доп.инфо ПН":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        dop-info = "" .
        for each temp_twowin_itemsSelected_col :
        dop-info = dop-info +  temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        dop-info = trim(dop-info, ",") .
        display dop-info with frame {&frame-name} .
        hide dop-info in frame {&frame-name} .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-sec-fields shattrpt 
PROCEDURE select-sec-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical    no-undo.
define variable v-accepted      as logical    no-undo.
define variable v-mode          as integer    no-undo.
define variable V-EX as logical   no-undo .

do
with frame {&frame-name}
on error undo, return error
:
if p-mode = {&lookup} then v-mode = 0 .
else v-mode = 1 .

    run twowin_clear in this-procedure.

    do v-counter = 1 to num-entries( v-list-sec-fields-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-sec-fields-full )
            v-value = entry( v-counter, v-list-sec-fields )
            v-ex = false
        .
           if  lookup (v-value , sec-fields ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Обязательные поля: &1", v-VALUE)
            , input  V-EX
        ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор обязательного поля в секциях ПН":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table sect_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        sec-fields = "" .
        for each sect_twowin_itemsSelected_col :
        sec-fields = sec-fields +  sect_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        sec-fields = trim(sec-fields, ",") .   
        display sec-fields with frame {&frame-name} .
        hide sec-fields in frame {&frame-name} .  
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

