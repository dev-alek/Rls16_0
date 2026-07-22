&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
using ibs.th.gbl.sys.objsrv.
using ibs.th.bge.is_motp.*.
using ibs.th.str.utd.edoctype .
using ibs.th.str.marking.sts.*.
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-utd


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-utd 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка кодов маркировки

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-type as integer no-undo .
define input parameter i-Pack as  character  no-undo .
define input-output parameter p-connect as com-handle no-undo .
define output parameter p-rid-list as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список УПД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
define variable v-obj-active            as logical     no-undo .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
    { gbl/objat.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      "'active=request'"
      v-obj-active
}
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }
{ str/edo.i }
{ str/temp_upd.i }
{ bge/esysattr.i }
{ gbl/usr-flt.i  }

/* Local Variable Definitions ---                                       */
define variable log-res-Token           as log         no-undo.
define variable log-res-recheck         as logical     no-undo .
define variable varlog                  as logical     no-undo .
define variable rr                      as recid       no-undo.
define variable v_type                  as char        no-undo.
define variable v-is-deploy             as logical     no-undo .
define variable v-rid-list              as character   no-undo .
define variable v-db-list               as character   no-undo .
define variable v-sertif                as character   no-undo .
define variable v-sertif_num            as character   no-undo .
define variable Vflaginout as logical no-undo.
define variable vToken                  as character   no-undo .
define variable row_utd                 as rowid       no-undo .
define variable recid_utd               as integer     no-undo .
define variable ii                      as integer     no-undo .
define variable v-time                  as integer     no-undo .
define variable time_old_start          as datetime-tz no-undo.
define variable v-Token-error           as logical     no-undo initial false.
define variable time_motp               as datetime-tz no-undo.
define variable vtime                   as int64       no-undo.
define variable mflagExit               as logical     no-undo.
define variable v-flag                  as logical     no-undo .
define variable v-void-logical          as logical     no-undo .
define variable v-current-sort-string   as character   no-undo .
define variable v-current-sertif-string as character   no-undo .
define variable mode-erprn              as logical     no-undo .
define variable conf-par                as character   no-undo .
define variable par-type                as character   no-undo .
define VARIABLE v-mes-Token             as LOGICAL     no-undo .
define buffer buf_utd     for ub.utd .
define buffer buf_clients for ub.clients .
define temp-table tt-obj-list no-undo
    field obj-code as integer
    field obj-type as character
    .

define temp-table tt-sertif no-undo
    field Name_                          as character
    field BeginDate                      as datetime
    field EndDate                        as datetime
    field Thumbprint                     as character
    field IssuerName                     as character
    field OrganizationName               as character 
    field SerialNumber                   as character
    field IsQualifiedElectronicSignature as character
    field INN                            as character 
    field KPP                            as character 
    field JobTitle                       as character 
    field CanEncrypt                     as character
    .
define variable StatusTH  as class ibs.th.str.utd.sts.th   no-undo .
define variable StatusEDI as class ibs.th.str.utd.sts.edi  no-undo .
define variable EdocType  as class ibs.th.str.utd.edoctype no-undo .
  

def    var      Marking   as class mark                    no-undo .

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_utd FOR tt-utd.


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-utd
&Scoped-define BROWSE-NAME br-utd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_utd

/* Definitions for BROWSE br-utd                                        */
&Scoped-define FIELDS-IN-QUERY-br-utd X_utd.DocumentNumber X_utd.EDocType ~
X_utd.DocumentDate X_utd.cli-code X_utd.sts X_utd.sts-edi X_utd.LoadDate ~
X_utd.DocumentExt 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-utd 
&Scoped-define QUERY-STRING-br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-utd OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-utd X_utd
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd X_utd


/* Definitions for DIALOG-BOX d-utd                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-utd ~
    ~{&OPEN-QUERY-br-utd}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-update b-sel b-utd b-add b-del b-servis b-pack ~
F-date-to F-date-from F-sertif b-choose-sertif obj-list bt-sel-obj ~
f-DocumentNumber B-refresh RADIO-SET-1 c-status-edi RADIO-SET-2 c-status ~
c-type b-mark br-utd B-write-sertif B-write-cancel b_anul b_nakl ~
B-write-Token b_recheck b_recEDI mark-num 
&Scoped-Define DISPLAYED-OBJECTS F-date-to F-date-from F-sertif obj-list ~
f-DocumentNumber RADIO-SET-1 c-status-edi RADIO-SET-2 c-status c-type ~
mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD CliName d-utd 
FUNCTION CliName RETURNS CHARACTER
    (input p-cli-code as integer, input p-cli-type as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD EdoTypeName d-utd 
FUNCTION EdoTypeName RETURNS CHARACTER
    ( input p-stsTH as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusEDIName d-utd 
FUNCTION StatusEDIName RETURNS CHARACTER
    ( input p-stsEDI as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName d-utd 
FUNCTION StatusTHName RETURNS CHARACTER
    ( input p-stsTH as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName d-utd 
FUNCTION checkmark RETURNS logical
    ( input idb-num as integer,
      input idoc-id as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-print 
    MENU-ITEM m_akt          LABEL "Акт приема-передачи".

DEFINE MENU POPUP-MENU-b-servis 
    MENU-ITEM m___Token      LABEL "Отключить запрос Token"
    MENU-ITEM m_nakl         LABEL "Формирование накладной"
    MENU-ITEM m_recheck      LABEL "Повторно проверить"
    MENU-ITEM m_recEDI       LABEL "Получение данных ЭДО"
    MENU-ITEM m_checknakl    LABEL "Связать с ПН"
    MENU-ITEM m_return       LABEL "Реквизиты возврата".
    MENU-ITEM m_return_send  LABEL "Отправит возврат повторно".
    menu-item m_dekl_sertif  label "Сертификаты/декларации".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
    LABEL "&Добавить":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-choose-sertif 
    LABEL "Выбор" 
    SIZE 10 BY 1.

DEFINE BUTTON b-del 
    LABEL "&Удалить":L 
    SIZE 10 BY 1.
     
DEFINE BUTTON b-pack 
    LABEL "Пакет":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-inout 
    LABEL "Исходящие":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
    LABEL "&Выход ":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-hist 
    IMAGE-UP FILE "cmp/b-hist.bmp":U
    IMAGE-DOWN FILE "cmp/b-hist.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
    LABEL "Ис&тория" 
    SIZE 3 BY 1.

DEFINE BUTTON b-mark 
    LABEL "&*" 
    SIZE 3 BY 1.

DEFINE BUTTON b-print 
    IMAGE-UP FILE "cmp/b-print.bmp":U
    IMAGE-DOWN FILE "cmp/b-print.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U NO-CONVERT-3D-COLORS
    LABEL "Печать" 
    SIZE 3 BY 1.

DEFINE BUTTON B-refresh 
    LABEL "Обновить" 
    SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
    LABEL "&Выбор":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-servis 
    LABEL "Сервис" 
    SIZE 10 BY 1.

DEFINE BUTTON b-update 
    LABEL "&Изменить":L 
    SIZE 10 BY 1.

DEFINE BUTTON b-utd 
    LABEL "&Просмотр":L 
    SIZE 10 BY 1.

DEFINE BUTTON B-write-cancel 
    LABEL "Отказать в подписи" 
    SIZE 27 BY 1.13.

DEFINE BUTTON B-write-sertif 
    LABEL "Подписать" 
    SIZE 27 BY 1.13.

DEFINE BUTTON B-write-Token 
    LABEL "Получить Token" 
    SIZE 27 BY 1.13.
    
DEFINE BUTTON B-LK_RECEIPT 
    LABEL "Док-ты Вывода из оборота (ОСУ)" 
    SIZE 31 BY 1.13.    

DEFINE BUTTON bt-not-sel-all 
    LABEL "+" 
    SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
    LABEL "-" 
    SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE VARIABLE f-mark AS CHARACTER FORMAT "X(256)":U 
    LABEL "Марка" 
    VIEW-AS FILL-IN 
    SIZE 38 BY 1 NO-UNDO.

DEFINE BUTTON b_cl_mark 
    LABEL "Сбросить" 
    SIZE 10 BY 1.13.

DEFINE BUTTON bt-sel-obj 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..." 
    SIZE 3.5 BY 1.04.

DEFINE BUTTON b_anul 
    LABEL "Аннуляция" 
    SIZE 27 BY 1.13.

DEFINE BUTTON b_oneUtd
    LABEL "Получить данные из Диадок" 
    SIZE 27 BY 1.13.

DEFINE VARIABLE c-status         AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
    LABEL "Статус ТН" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все","0",
    "Получен от поставщика","2",
    "Требует корректировки","3",
    "Ожидает поставки","4",
    "Требует подписания","5"
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.

DEFINE VARIABLE c-status-edi     AS INTEGER   FORMAT "-999":U INITIAL 0 
    LABEL "Статус EDI" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",1,
    "Получен от поставщика",2,
    "Требует корректировки",3,
    "Ожидает поставки",4,
    "Требует подписания",5
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.

DEFINE VARIABLE c-type           AS INTEGER   FORMAT "-999":U INITIAL 0 
    LABEL "Тип" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",0,
    "Получен от поставщика",2,
    "Требует корректировки",3,
    "Ожидает поставки",4,
    "Требует подписания",5
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-date-from      AS DATE      FORMAT "99/99/9999":U 
    VIEW-AS FILL-IN 
    SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE F-date-to        AS DATE      FORMAT "99/99/9999":U 
    LABEL "За период с" 
    VIEW-AS FILL-IN 
    SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-DocumentNumber AS CHARACTER FORMAT "X(256)":U 
    LABEL "Номер документа" 
    VIEW-AS FILL-IN 
    SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE F-sertif         AS CHARACTER FORMAT "X(256)":U 
    LABEL "Сертификат" 
    VIEW-AS FILL-IN 
    SIZE 41.13 BY 1
    BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE F-timeToken      AS Character FORMAT "X(256)":U INITIAL ? 
    VIEW-AS FILL-IN 
    SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num         AS INTEGER   FORMAT "->>>9":U INITIAL 0 
    VIEW-AS TEXT 
    SIZE 4 BY 1
    FGCOLOR 7 NO-UNDO.

DEFINE VARIABLE obj-list         AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 18.38 BY 1 NO-UNDO.

DEFINE VARIABLE R-obj            AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "Все", 1,
    "Выборочно", 2
    SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1      AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "Все", 0,
    "В работе", 2,
    "Требуется корректировка", 1
    SIZE 52.5 BY 1.25 NO-UNDO.

DEFINE VARIABLE RADIO-SET-2      AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "Все", 0,
    "Требуется подпись", 1,
    "Подписано", 2
    SIZE 47 BY 1.25 NO-UNDO.
define variable mdoc-id as character no-undo.
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-utd FOR 
    X_utd SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-utd d-utd _STRUCTURED
    QUERY br-utd NO-LOCK DISPLAY
    mark-string( input recid(X_utd), input v-rid-list) column-label "*" format "X(1)":U
    X_utd.DocumentNumber COLUMN-LABEL "Номер!документа" FORMAT "x(60)":U width 15
    X_utd.EDoTypeName COLUMN-LABEL "Тип" FORMAT "X(30)":U width 9
    X_utd.DocumentDate COLUMN-LABEL "Дата док-та" FORMAT "99/99/9999":U
    X_utd.obj-name COLUMN-LABEL "Объект" FORMAT "X(30)":U width 6
    X_utd.cli-code COLUMN-LABEL "Код! пост-ка" FORMAT ">>>>9999999":U
    X_utd.cli-name COLUMN-LABEL "Название!поставщика" FORMAT "X(30)":U width 19
    X_utd.total COLUMN-LABEL "Сумма" FORMAT "->>>>>>>>>>99.99":U width 13
    X_utd.vat COLUMN-LABEL "Сумма! НДС" FORMAT "->>>>>>>>>>99.99":U width 9
    X_utd.stts COLUMN-LABEL "Статус ТН" FORMAT "X(40)":U width 14
    X_utd.stts-edi COLUMN-LABEL "Статус EDI" FORMAT "X(40)":U width 14
    (if X_utd.AmendmentRequested then "+":U else "") format "X(1)":U LABEL "И"
    X_utd.ModifyTime_ column-label "Время!послед.!измен." format "X(7)":U
    X_utd.doc-code COLUMN-LABEL "Номер!документа ТН" FORMAT "x(15)":U
    X_utd.orig-code COLUMN-LABEL "Номер!ориг.документа" FORMAT "x(15)":U WIDTH 50
    X_utd.LoadDate COLUMN-LABEL "Дата загр" FORMAT "99/99/9999":U
    X_utd.DocumentExt COLUMN-LABEL "ID документа" FORMAT "x(80)":U WIDTH 50
    substitute ("&1_&2",X_utd.db-num, X_utd.doc-id) @ mdoc-id COLUMN-LABEL "Внутр.!номер" FORMAT "x(12)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 17.63 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-utd
    b-exit AT ROW 1 COL 1.5
    b-update AT ROW 1 COL 11.5 WIDGET-ID 222
    b-sel AT ROW 1 COL 11.5 WIDGET-ID 222
    b-utd AT ROW 1 COL 21.5 WIDGET-ID 230
    b-add AT ROW 1 COL 31.5 WIDGET-ID 266
    b-del AT ROW 1 COL 41.5 WIDGET-ID 280
    b-pack AT ROW 1 COL 51.5 WIDGET-ID 284
    b-inout AT ROW 1 COL 71.5 WIDGET-ID 484
    B-refresh AT ROW 1 COL 106 WIDGET-ID 286
    b-servis AT ROW 1 COL 116 WIDGET-ID 288
    b-print AT ROW 1 COL 126.13 WIDGET-ID 62
    b-hist AT ROW 1 COL 129 WIDGET-ID 64
    F-date-to AT ROW 2.29 COL 13.5 COLON-ALIGNED WIDGET-ID 238
    F-date-from AT ROW 2.29 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 36
    F-sertif AT ROW 2.29 COL 78.5 COLON-ALIGNED WIDGET-ID 232 NO-TAB-STOP 
    b-choose-sertif AT ROW 2.29 COL 121.88 WIDGET-ID 234
    obj-list AT ROW 3.5 COL 47.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
    bt-sel-obj AT ROW 3.5 COL 48.38 WIDGET-ID 28
    f-DocumentNumber AT ROW 3.5 COL 120.5 RIGHT-ALIGNED WIDGET-ID 276
    R-obj AT ROW 3.54 COL 11.5 NO-LABEL WIDGET-ID 290
    RADIO-SET-1 AT ROW 4.75 COL 2.5 NO-LABEL WIDGET-ID 250
    c-status AT ROW 5.08 COL 74.5 COLON-ALIGNED WIDGET-ID 228
    RADIO-SET-2 AT ROW 5.88 COL 2.5 NO-LABEL WIDGET-ID 282
    c-status-edi AT ROW 6.13 COL 74.5 COLON-ALIGNED WIDGET-ID 248
    c-type AT ROW 7.17 COL 74.5 COLON-ALIGNED WIDGET-ID 278
    bt-not-sel-all AT ROW 7.21 COL 5.5 WIDGET-ID 10 NO-TAB-STOP 
    bt-not-sel-desel-all AT ROW 7.21 COL 8.5 WIDGET-ID 12 NO-TAB-STOP 
    b-mark AT ROW 7.21 COL 11.5 WIDGET-ID 4 NO-TAB-STOP
    f-mark AT ROW 7.21 COL 15.5 WIDGET-ID 98
    b_cl_mark AT ROW 7.14 COL 60.5
    br-utd AT ROW 8.21 COL 1.5
    B-write-sertif AT ROW 26.38 COL 4 WIDGET-ID 236
    B-write-cancel AT ROW 26.38 COL 36.25 WIDGET-ID 70
    b_anul AT ROW 26.38 COL 68.75 WIDGET-ID 246
    b_oneUtd AT ROW 26.38 COL 101.63 WIDGET-ID 254
    B-write-Token AT ROW 27.67 COL 4 WIDGET-ID 240
    B-LK_RECEIPT AT ROW 27.67 COL 63 WIDGET-ID 440
    F-timeToken AT ROW 27.67 COL 128 RIGHT-ALIGNED NO-LABEL WIDGET-ID 294
    mark-num AT ROW 7.21 COL 1.5 NO-LABEL WIDGET-ID 8
    "Время Token:" VIEW-AS TEXT
    SIZE 12.5 BY .75 AT ROW 27.75 COL 96.5 WIDGET-ID 298
    "по" VIEW-AS TEXT
    SIZE 2.5 BY .67 AT ROW 2.46 COL 27 WIDGET-ID 38
    "Объекты:" VIEW-AS TEXT
    SIZE 8 BY .67 AT ROW 3.71 COL 2.63 WIDGET-ID 296
    SPACE(121.87) SKIP(24.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Список УПД":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_utd B "NEW SHARED" ? ub utd
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-utd
   FRAME-NAME                                                           */
/* BROWSE-TAB br-utd b-mark d-utd */
ASSIGN 
    FRAME d-utd:SCROLLABLE = FALSE.

ASSIGN 
    b-print:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN 
    b-print:MENU-MOUSE = 1.
ASSIGN 
    b-servis:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-servis:HANDLE.
ASSIGN 
    b-servis:MENU-MOUSE = 1.
ASSIGN 
    br-utd:COLUMN-RESIZABLE IN FRAME d-utd = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME d-utd
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME d-utd
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-DocumentNumber IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN F-timeToken IN FRAME d-utd
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN mark-num IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN obj-list IN FRAME d-utd
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-utd
/* Query rebuild information for BROWSE br-utd
     _TblList          = "X_utd"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.X_utd.DocumentNumber
"X_utd.DocumentNumber" "Номер!документа" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_utd.EDocType
"X_utd.EDocType" "Тип" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.X_utd.DocumentDate
"X_utd.DocumentDate" "Дата документа" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.X_utd.cli-code
"X_utd.cli-code" "Код!поставщика ТН" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.X_utd.sts
"X_utd.sts" "Статус ТН" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.X_utd.sts-edi
"X_utd.sts-edi" "Статус EDI" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.X_utd.LoadDate
"X_utd.LoadDate" "Дата загрузки" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.X_utd.DocumentExt
"X_utd.DocumentExt" "ID документа" ? "character" ? ? ? ? ? ? no ? no no "27.63" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-utd */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-utd
/* Query rebuild information for DIALOG-BOX d-utd
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-utd */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-utd d-utd
ON GO OF FRAME d-utd /* Список УПД */
    DO:
    /*    p-rid-list = v-rid-list.*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-utd
ON choose OF b-add IN FRAME d-utd /* Добавить */
    DO:
        define variable Log-Res as logical no-undo.

        /*Проверка прав */
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_add':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
        if log-res then 
        do:
            subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
            MySeqUtd = ?.
            run str/upd_browse.w (input parparentproc,
                input ?,
                input ?,
                input 2,
                input {&add-def},
                input mDiadocConnection
                ) no-error.
            run init-sort .
            unsubscribe "getNextseq".
            {&OPEN-QUERY-br-utd}
        end.      
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-sertif d-utd
ON CHOOSE OF b-choose-sertif IN FRAME d-utd /* Выбор */
    DO:
        /*Задаем параметры подлючения к серверу*/
        /*Получение списка сертификатов*/
        run str/sertif.w (input parparentproc,
            output v-sertif_num
            ) no-error .
        if v-sertif_num <> "" then 
        do:
            run proc-sertif (yes).
        end.
        run enable_BUTTON .

        F-sertif = v-sertif_num .
        if f-sertif <> "" then 
        do:
            enable       B-write-Token with frame {&frame-name} .
        end.
        else 
        do:
            disable       B-write-Token with frame {&frame-name} .
        end.  
        display
            F-sertif
            with frame {&frame-name} .  
    /*Подключение по сертификату*/

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON ROW-DISPLAY OF br-utd IN FRAME d-utd
    DO:
        if AVAILABLE (X_utd) then 
        do:      
            /*    if X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:HaveToCreateReceipt:KeyIntDB or      */
            /*       X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:RequestsMyRevocation:KeyIntDB or     */
            /*       X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WaitingForRecipientSignature:KeyIntDB*/
            /*    then do:                                                                       */
            /*          X_utd.DocumentNumber:fGCOLOR in browse br-utd = CYAN_COLOR.              */
            /*          X_utd.EDoTypeName:fGCOLOR in browse br-utd = CYAN_COLOR.                 */
            /*          X_utd.DocumentDate:fGCOLOR in browse br-utd = CYAN_COLOR.                */
            /*          X_utd.cli-code:fGCOLOR in browse br-utd = CYAN_COLOR.                    */
            /*          X_utd.cli-name:fGCOLOR in browse br-utd = CYAN_COLOR.                    */
            /*          X_utd.total:fGCOLOR in browse br-utd = CYAN_COLOR.                       */
            /*          X_utd.vat:fGCOLOR in browse br-utd = CYAN_COLOR.                         */
            /*          X_utd.stts:fGCOLOR in browse br-utd = CYAN_COLOR.                        */
            /*          X_utd.stts-edi:fGCOLOR in browse br-utd = CYAN_COLOR.                    */
            /*          X_utd.ModifyTime_:fGCOLOR in browse br-utd = CYAN_COLOR.                 */
            /*          X_utd.doc-code:fGCOLOR in browse br-utd = CYAN_COLOR.                    */
            /*          X_utd.orig-code:fGCOLOR in browse br-utd = CYAN_COLOR.                   */
            /*          X_utd.LoadDate:fGCOLOR in browse br-utd = CYAN_COLOR.                    */
            /*          X_utd.DocumentExt:fGCOLOR in browse br-utd = CYAN_COLOR.                 */
            /*          X_utd.doc-id:fGCOLOR in browse br-utd = CYAN_COLOR.                      */
            /*    end.                                                                           */
            if X_utd.GrayZone then 
            do:
                X_utd.DocumentNumber:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.EDoTypeName:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.DocumentDate:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.cli-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.cli-name:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.total:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.vat:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.stts:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.stts-edi:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.ModifyTime_:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.doc-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.orig-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.LoadDate:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.DocumentExt:bGCOLOR in browse br-utd = GRAY_COLOR.
                mdoc-id:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.obj-name:bGCOLOR in browse br-utd = GRAY_COLOR.        
            end.  
            if X_utd.edoctype = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
            do:
                case X_utd.sts:
                    when ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:edocError:KeyIntDB then
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.cli-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.cli-name:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.total:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.vat:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.stts:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.doc-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.orig-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = RED_COLOR.
                            mdoc-id:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.obj-name:fGCOLOR in browse br-utd = RED_COLOR.
                        end.
                    when ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB
                    then 
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.cli-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.cli-name:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.total:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.vat:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.stts:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.doc-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.orig-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = CYAN_COLOR.
                            mdoc-id:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.obj-name:fGCOLOR in browse br-utd = CYAN_COLOR.        
                        end.               
                    when ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
                    then
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = 13.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = 13.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = 13.
                            X_utd.cli-code:fGCOLOR in browse br-utd = 13.
                            X_utd.cli-name:fGCOLOR in browse br-utd = 13.
                            X_utd.total:fGCOLOR in browse br-utd = 13.
                            X_utd.vat:fGCOLOR in browse br-utd = 13.
                            X_utd.stts:fGCOLOR in browse br-utd = 13.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = 13.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = 13.
                            X_utd.doc-code:fGCOLOR in browse br-utd = 13.
                            X_utd.orig-code:fGCOLOR in browse br-utd = 13.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = 13.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = 13.
                            mdoc-id:fGCOLOR in browse br-utd = 13.
                            X_utd.obj-name:fGCOLOR in browse br-utd = 13.
                        end.        
                end.
            end.
        end.
    end. 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME         
      
&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-utd
ON choose OF b-del IN FRAME d-utd /* Удалить */
    DO:
        define buffer bf_utd               for ub.utd .
        define buffer bf_utd-lines         for ub.utd-lines .
        define buffer bf_utd-marking-lines for ub.utd-marking-lines .
        define buffer bf_marking           for ub.marking .
        define variable Log-Res as logical no-undo.
        define variable undelete as logical no-undo .
        define variable vCount   as integer no-undo .
        if AVAILABLE (X_utd) then 
        do:
            /*Проверка прав */
            { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_delete':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
            if log-res then 
            do: 
              if v-rid-list <> "" then
              do:
                message "Удалить"  num-entries(v-rid-list) "документа?"
                        view-as alert-box question buttons yes-no update undelete.
                if not undelete then return no-apply.
              end.
              else v-rid-list = string(recid(X_utd)).
              do vCount = 1 to num-entries(v-rid-list):  
                find first X_utd no-lock where recid(X_utd) = int(entry(vCount, v-rid-list)) no-error .
                if X_utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB or X_utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB  
                    then 
                do:
                    if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
                    do:
                        if not undelete then
                        message "Удалить документ " + X_utd.DocumentNumber + "?"
                            view-as alert-box question buttons yes-no update undelete.
                        if undelete then 
                        do:
                            find first bf_utd exclusive-lock where bf_utd.db-num = X_utd.db-num and bf_utd.doc-id = int(entry(vCount, v-rid-list)) no-error .
                            /*        for each bf_utd-marking-lines where bf_utd-marking-lines.db-num = X_utd.db-num and bf_utd-marking-lines.doc-id = X_utd.doc-id:*/
                            /*          for each bf_marking where bf_marking.mark = bf_utd-marking-lines.mark:                                                      */
                            /*            delete bf_marking .                                                                                                       */
                            /*          end.                                                                                                                        */
                            /*     end.                                                                                                                             */
                            delete bf_utd .
                        end. /*if undelete then*/
                    end. /*if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then*/
                    else 
                    do:
                        message "Документ " + string (X_utd.DocumentNumber) + " не может быть удален"
                            view-as alert-box.
                    end. 
                end. /*if X_utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB or X_utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB*/
                else 
                do:
                    if X_utd.db-num = v-cntxt-db-num and 
                        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and 
                        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB then 
                    do:
                        if not undelete then
                        message "Удалить документ " + X_utd.DocumentNumber + "?"
                            view-as alert-box question buttons yes-no update undelete.
                        if undelete then 
                        do:                            
                            find first bf_utd exclusive-lock where bf_utd.db-num = X_utd.db-num and bf_utd.doc-id = X_utd.doc-id no-error .
                            /*        for each bf_utd-marking-lines where bf_utd-marking-lines.db-num = X_utd.db-num and bf_utd-marking-lines.doc-id = X_utd.doc-id:*/
                            /*          for each bf_marking where bf_marking.mark = bf_utd-marking-lines.mark:                                                      */
                            /*            delete bf_marking .                                                                                                       */
                            /*          end.                                                                                                                        */
                            /*     end.                                                                                                                             */
                            delete bf_utd .
                        end. /*if undelete then*/
                    end.
                    else 
                    do:
                        message "Документ " + string (X_utd.DocumentNumber) + " не может быть удален"
                            view-as alert-box.
                    end.                     
                end.
              end.
              v-rid-list = "".         
              run init-sort .
              {&OPEN-QUERY-br-utd}
            end.   /*if log-res then*/
        end.

        else 
        do:
            message "Нет документа для удаления"
                view-as alert-box.
        end.    
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-utd
ON CHOOSE OF b-exit IN FRAME d-utd /* Выход  */
    DO:
        if v-current-sort-string <> "" then 
        do:
            c-status = string(entry(1,v-current-sort-string,{&delim-key})) .
            c-status-edi = integer(entry(2,v-current-sort-string,{&delim-key})) . 
            c-type = integer(entry(3,v-current-sort-string,{&delim-key})) .
            RADIO-SET-1 = integer(entry(4,v-current-sort-string,{&delim-key})) .
            RADIO-SET-2 = integer(entry(4,v-current-sort-string,{&delim-key})) .
        end.  
        v-current-sort-string =c-status + {&delim-key} + string(c-status-edi) + {&delim-key} + string(c-type) +
            {&delim-key} + string(RADIO-SET-1) + {&delim-key} + string (RADIO-SET-2).
        v-current-sertif-string = v-sertif_num.
        run uf-set(
            input {&uf-UPD}
            , input v-cntxt-userid
            , input v-current-sertif-string
            , input v-current-sort-string
            , input no
            , input no
            , input no
            , input no
            ) no-error.
   
   
        assign
            mflagExit = yes
            .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-LK_RECEIPT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-LK_RECEIPT d-utd
ON choose OF B-LK_RECEIPT IN FRAME d-utd /* История */
DO:
  define variable v-lk_receipt-list as character no-undo .
  run str/LK_RECEIPT-docs.w ( parparentproc, "", output v-lk_receipt-list) .
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-utd
ON choose OF b-hist IN FRAME d-utd /* История */
    DO:
        define variable v-rid-list as character no-undo.
        if available (X_utd) then 
        do:
            row_utd = rowid (X_utd) .
            run ref/cutdhist.w (
                X_utd.db-num, 
                X_utd.doc-id,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
            br-utd:refresh ().
            reposition br-utd to rowid row_utd.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-utd
ON CHOOSE OF b-mark IN FRAME d-utd /* * */
    DO:
        define variable loc#log as logical no-undo .
        if available X_utd then 
        do:
            { gbl/markstrn.i X_utd v-rid-list }
            row_utd = rowid(X_utd).
            loc#log = {&browse-name}:refresh() .
            reposition br-utd to rowid row_utd.

            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
            do:
                loc#log = {&browse-name}:select-next-row ().
                apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
            end.
            if num-entries( v-rid-list ) = 0 then 
            do:
                hide mark-num in frame {&frame-name}.
            end.
            else 
            do:
                display
                    num-entries( v-rid-list ) @ mark-num
                    with frame {&frame-name}.
            end.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-refresh d-utd
ON CHOOSE OF B-refresh IN FRAME d-utd /* Обновить */
    DO:
        f-date-from = date(f-date-from:screen-value) .
        f-date-to   = date(f-date-to:screen-value) .
        run init-sort .
        {&OPEN-QUERY-br-utd}
        run enable_BUTTON.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-utd
ON CHOOSE OF b-sel IN FRAME d-utd /* Выбор */
    DO:
        define buffer buf_utd for ub.utd .
        if v-rid-list = "" then 
        do:
            if available (X_utd) then 
            do:
                find first buf_utd no-lock where buf_utd.doc-id = X_utd.doc-id and buf_utd.db-num = X_utd.db-num no-error .
                v-rid-list = string(recid(buf_utd)) .
            end.  
        end.  
        p-rid-list = v-rid-list .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-update d-utd
ON CHOOSE OF b-update IN FRAME d-utd /* Изменить */
    DO:
        define var      doc-id   like ub.utd.doc-id no-undo .
        define var      db-num   like ub.utd.db-num no-undo .
        define var      EDocType like ub.utd.EDocType no-undo .
        define variable Log-Res  as logical no-undo.
        if available (x_utd) then 
        do:
            /*Проверка прав */
            { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_update':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
            if log-res then 
            do:  

                row_utd = rowid(X_utd) . 
                assign
                    doc-id   = x_utd.doc-id
                    db-num   = x_utd.db-num
                    EDocType = x_utd.EDocType
                    .
                subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                MySeqUtd = ?.
                if v-obj-active or X_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or X_utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB 
                  or X_utd.EDocType = objSrv:Env:utd:EDocType:edoc:KeyIntDB
                then 
                do: 

                    run str/upd_browse.w (input parparentproc,
                        input x_utd.doc-id,
                        input x_utd.db-num,
                        input x_utd.EDocType,
                        input {&update},
                        input mDiadocConnection
                        )  .
                end.
                else 
                do:
                    run str/upd_browse.w (input parparentproc,
                        input x_utd.doc-id,
                        input x_utd.db-num,
                        input x_utd.EDocType,
                        input {&lookup},
                        input mDiadocConnection
                        )  .
                end.
                unsubscribe "getNextseq".  
            end.
            else 
            do: 
                message "Не выбран УПД"
                    view-as alert-box.  
                return no-apply .
            end.
            run init-id (doc-id, db-num).
            br-utd:refresh ().

            reposition br-utd to rowid row_utd.
        end.  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-utd d-utd
ON choose OF b-utd IN FRAME d-utd /* Просмотр */
    DO:
        define variable Log-Res as logical no-undo.
        if available (x_utd) then 
        do:
            /*Проверка прав */
            { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_lookup':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
            if log-res then 
            do:    

                row_utd = rowid (X_utd) .
                subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                MySeqUtd = ?.
     
                run str/upd_browse.w (input parparentproc,
                    input x_utd.doc-id,
                    input x_utd.db-num,
                    input x_utd.EDocType,
                    input {&lookup},
                    input mDiadocConnection
                    ) no-error .
                unsubscribe "getNextseq".
    
    
            end.
            else 
            do: 
                message "Не выбран УПД"
                    view-as alert-box.  
                return no-apply .
            end.
            reposition br-utd to rowid row_utd no-error .
        end.      
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-write-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-write-cancel d-utd
ON CHOOSE OF B-write-cancel IN FRAME d-utd /* Отказать в подписи */
    DO:
        define variable Log-Res as logical no-undo.

        /*Проверка прав */
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_close':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
        if log-res then 
        do:
            if v-rid-list <> "" then 
            do:
                do ii = 1 to num-entries (v-rid-list):
                    recid_utd = integer(entry(ii,v-rid-list)) .
                    find first x_utd where recid (x_utd) = recid_utd .
                    run SendResponse( X_utd.db-num, X_utd.doc-id, no, no) no-error.        
                    if  error-status:error then 
                    do: 
                        
                        return return-value .
                    end.
                end.  
                run init-sort in this-procedure .
                {&OPEN-QUERY-br-utd}
            end.   
            else 
            do:
                if available (X_utd) then 
                do:
                    row_utd = rowid (X_utd) .
                    find first x_utd where rowid (x_utd) = row_utd .
                    run SendResponse( X_utd.db-num, X_utd.doc-id, no, no) no-error.        
                    if  error-status:error then 
                    do: 
                        message return-value
                        view-as alert-box.
                        return return-value .
                    end.
                    run init-id (X_utd.doc-id, X_utd.db-num).  
                    br-utd:refresh () no-error.
                    reposition br-utd to rowid row_utd no-error .
                end. /* */
            end.
        end.    
        v-rid-list = "" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-write-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-write-sertif d-utd
ON CHOOSE OF B-write-sertif IN FRAME d-utd /* Подписать */
    DO:
        define variable Log-Res as logical no-undo.

        /*Проверка прав */
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_close':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
        if log-res then 
        do:    
            if v-rid-list <> "" then 
            do:
                do ii = 1 to num-entries (v-rid-list):
                    recid_utd = integer(entry(ii,v-rid-list)) .
                    find first x_utd where recid (x_utd) = recid_utd .
                    if checkMark(x_utd.db-num,x_utd.doc-id)
                    then do:
                       run SendResponse( X_utd.db-num, X_utd.doc-id, yes, no) no-error.          
                       if  error-status:error then 
                       do: 
                           return return-value .
                       end.
                    end.
                end. 
                run init-sort in this-procedure .
                {&OPEN-QUERY-br-utd} 
            end.   
            else 
            do:
                if available (X_utd) then 
                do:
                    row_utd = rowid (X_utd) .
                    find first x_utd where rowid (x_utd) = row_utd .
                    if checkMark(x_utd.db-num,x_utd.doc-id)
                    then do:
                       run SendResponse( X_utd.db-num, X_utd.doc-id, yes, no) no-error.        
                       if  error-status:error then 
                       do: 
                          message return-value
                        view-as alert-box.
                           return return-value .
                       end.
                       run init-id (X_utd.doc-id, X_utd.db-num).  
                       br-utd:refresh () no-error.
                       reposition br-utd to rowid row_utd no-error .
                    end.
                end.  
            end.
        end.    
        v-rid-list = "" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-write-Token
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-write-Token d-utd
ON choose OF B-write-Token IN FRAME d-utd /* Получить Token */
    DO:
        define buffer buf_ext-system      for ub.ext-system .
        define buffer buf_ext-system-attr for ub.ext-system-attr .
    
        if v-sertif_num = "" then 
        do: 
            message "Сертификат не выбран"
                view-as alert-box.
            return .
        end.       
        v-mes-Token = yes .
        run proc-Token .
        run enable_BUTTON .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-utd
&Scoped-define SELF-NAME br-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON entry OF br-utd IN FRAME d-utd
    DO:
        /*  f-DocumentNumber = "" .                            */
        /*  display f-DocumentNumber with frame {&frame-name} .*/
        /*  run init-sort .                                    */
        /*  {&OPEN-QUERY-br-utd}                               */
        run enable_BUTTON .  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON mouse-select-dblclick OF br-utd IN FRAME d-utd
    DO:
        if AVAILABLE (X_utd) then 
        do:         
            if v-obj-active or X_utd.EDocType = EdocType:UTD:KeyIntDB or X_utd.EDocType = EdocType:UCD:KeyIntDB then 
            do: 
                apply "Choose" to b-update in frame {&frame-name}.
            end.
            else 
            do:
                apply "Choose" to b-utd in frame {&frame-name}.
            end.  
        end.  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all d-utd
ON CHOOSE OF bt-not-sel-all IN FRAME d-utd /* + */
    DO:
        define variable loc#log as logical no-undo .

        if available X_utd then 
        do:
            v-rid-list = "" .
            for each X_utd no-lock:
                { gbl/markstrn.i X_utd v-rid-list }
                loc#log = {&browse-name}:refresh() .
            end.
        end.
        if num-entries( v-rid-list ) <> 0 then 
        do:
            display
                num-entries( v-rid-list ) @ mark-num
                with frame {&frame-name}.
        end.
/*        v-rid-list = "" .*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all d-utd
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-utd /* - */
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        loc#log = {&browse-name}:refresh() .
        hide mark-num in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj d-utd
ON CHOOSE OF bt-sel-obj IN FRAME d-utd /* ... */
    DO:
        define variable v-obj-list         as character no-undo.
        define variable v-exclude-obj-list as character no-undo.

        define variable v-object-available as logical   no-undo.

   
        {gbl/uobjclr.i}
    
        {gbl/usobjava.i
     v-cntxt-db-num
     {&action-head-code-main}
     v-cntxt-userid
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-object-available
     no-error}
     
        if error-status :error then 
        do:
            message vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры gbl/usobjava.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error.
            undo, return no-apply.
        end. /* if error-status */

        if v-object-available = true then 
        do:
            {gbl/uobjapnd.i
         v-cntxt-obj-type
         v-cntxt-obj-code}
        end.

        define variable v-user-select as logical no-undo.
        {gbl/uobjsman.i
     parparentproc
     v-cntxt-db-num
     v-cntxt-userid
     v-cntxt-host-code-obj
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-user-select}
     
        if v-user-select <> true then 
        do:
            message "Объект не выбран" view-as alert-box information.
        end.
        else 
        do:
            v-obj-list = "" .
            empty temp-table tt-obj-list .

            for each userobjs_temp-user-obj:
                create tt-obj-list .
                assign
                    tt-obj-list.obj-code = userobjs_temp-user-obj.obj-code
                    tt-obj-list.obj-type = userobjs_temp-user-obj.obj-type
                    .
                v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "")
                    + userobjs_temp-user-obj.obj-type + " " + string( userobjs_temp-user-obj.obj-code).
            /*        for first ub.clients no-lock where ub.clients.obj-code = userobjs_temp-user-obj.obj-code and ub.clients.obj-type = userobjs_temp-user-obj.obj-type:*/
            /*          v-db-list = v-db-list + "," + string( ub.clients.db-num).                                                                                        */
            /*        end.                                                                                                                                               */
            end. /* for each userobjs_temp-user-obj */
        end.
        obj-list:screen-value = v-obj-list.
        run init-sort in this-procedure .
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-inout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inout d-utd
ON CHOOSE OF b-inout IN FRAME d-utd /* Аннуляция */
DO:
   Vflaginout = not Vflaginout.
   b-inout:label = if Vflaginout then "Входящие" else "Исходящие" .
   run init-sort .
   {&OPEN-QUERY-br-utd}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME menu-item m_return_send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL  menu-item m_return_send
ON CHOOSE OF menu-item m_return_send /* Возрат */
DO:
   define variable vsend as logical no-undo.
   vsend = not logical(getattrutdex (X_utd.db-num,X_utd.doc-id,"returnSend","no")).
   if not vsend
   then
      message "Документ был отправлен ранее, отправить повторно?"
      view-as alert-box question buttons yes-no update vsend.
   if vsend
   then 
      run bge/sendutd.p(parparentproc,
                        v-sertif,
                        X_utd.db-num,
                        X_utd.doc-id) no-error.
      if error-status:error
      then do:
         message return-value
         view-as alert-box.
         
      end.      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME menu-item m_dekl_sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL  menu-item m_dekl_sertif
ON CHOOSE OF menu-item m_dekl_sertif /* Сертификаты/декларации */
DO:

  if v-rid-list <> "" then 
  do:
    do ii = 1 to num-entries (v-rid-list):
      recid_utd = integer(entry(ii,v-rid-list)) .
      find first x_utd where recid (x_utd) = recid_utd .
      create tt-sert-utd .
      assign
        tt-sert-utd.doc-id = x_utd.doc-id
        tt-sert-utd.db-num = x_utd.db-num
        tt-sert-utd.documentDate = x_utd.documentDate
        tt-sert-utd.documentNumber = x_utd.documentNumber
        tt-sert-utd.cli-code = x_utd.cli-code
        tt-sert-utd.cli-type = x_utd.cli-type        
        .  
    end.  
  end.   
  else 
  do:
    if available (X_utd) then 
    do:
      row_utd = rowid (X_utd) .
      find first x_utd where rowid (x_utd) = row_utd .
      create tt-sert-utd .
      assign
        tt-sert-utd.doc-id = x_utd.doc-id
        tt-sert-utd.db-num = x_utd.db-num
        tt-sert-utd.documentDate = x_utd.documentDate
        tt-sert-utd.documentNumber = x_utd.documentNumber
        tt-sert-utd.cli-code = x_utd.cli-code
        tt-sert-utd.cli-type = x_utd.cli-type
        . 
    end. /* */
  end.
  run rep/dekl_sertif.p (parparentproc, table tt-sert-utd) no-error .   
  empty temp-table tt-sert-utd .
  v-rid-list = "" .
  apply "Choose" to b-refresh in frame {&frame-name}.         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
            
&Scoped-define SELF-NAME b-pack
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pack d-utd
ON CHOOSE OF b-pack IN FRAME d-utd /* пакет */
    DO:
   
        define variable v-rid-list as character no-undo.
        if available X_utd
            then 
        do:
            v-current-sertif-string = v-sertif_num.
            run uf-set(
                input {&uf-UPD}
                , input v-cntxt-userid
                , input v-current-sertif-string
                , input v-current-sort-string
                , input no
                , input no
                , input no
                , input no
                ) no-error.
            run str\upd.w (parparentproc, p-mode, p-type, X_utd.PackageId,input-output mDiadocConnection, output v-rid-list).
            run uf-get (
                input {&uf-UPD}
                , input  v-cntxt-userid
                , output v-current-sertif-string
                , output v-current-sort-string
                , output v-void-logical
                , output v-void-logical
                , output v-void-logical
                , output v-void-logical
                ) no-error.
            if v-current-sertif-string <> "" then 
            do:
                F-sertif = v-current-sertif-string .
                v-sertif_num = v-current-sertif-string .
                display F-sertif with frame {&frame-name} .
            end. 
            run enable_BUTTON.
        end.
        v-rid-list = "" .
    end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_anul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_anul d-utd
ON CHOOSE OF b_anul IN FRAME d-utd /* Аннуляция */
    DO:
        define variable load-sts as logical no-undo .
        if v-rid-list <> "" then
        do:
            do ii = 1 to num-entries (v-rid-list):
                recid_utd = integer(entry(ii,v-rid-list)) .
                find first x_utd where recid (x_utd) = recid_utd .
                if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or X_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB then 
                do:
                    message "Документ с номером: " + X_utd.DocumentNumber + " " + string(X_utd.DocumentDate) + " подписан и обработан в системе." skip
                        "Убедитесь, что товар не оприходован в системе." skip
                        "Вы уверены, что хотите подписать аннуляцию?" skip
                        view-as alert-box question buttons yes-no update load-sts.
                    if load-sts <> true then 
                    do:
                        return .
                    end.  
                end.
                run Sendansver( X_utd.db-num, X_utd.doc-id, "RevocationRequest","") no-error.
                if  error-status:error then
                do:
                    return return-value .
                end.
            end.
            run init-sort in this-procedure .
            {&OPEN-QUERY-br-utd}
        end.
        else
        do:
            if available (X_utd) then
            do:
                row_utd = rowid (X_utd) .
                find first x_utd where rowid (x_utd) = row_utd .
                if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or X_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB then 
                do:
                    message "Документ с номером: " + X_utd.DocumentNumber + "подписан и обработан в системе." skip
                        "Убедитесь, что товар не оприходован в системе." skip
                        "Вы уверены, что хотите подписать аннуляцию?" skip
                        view-as alert-box question buttons yes-no update load-sts.
                    if load-sts <> true then 
                    do:
                        return .
                    end.  
                end.  
                run Sendansver( X_utd.db-num, X_utd.doc-id, "RevocationRequest","") no-error.
                if  error-status:error then
                do:
                    message return-value
                    view-as alert-box.
                    return return-value .
                end.
                run init-id (X_utd.doc-id, X_utd.db-num).  
                br-utd:refresh () no-error.
                reposition br-utd to rowid row_utd no-error .
            end.
        end.
        v-rid-list = "" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_akt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_akt POPUP-MENU-b-print
ON CHOOSE OF menu-item m_return /* Реквизиты возврата */
DO:
   define variable row_utd as rowid no-undo.
   if available (X_utd) 
   then do with FRAME d-utd:
      define variable mMode as character  no-undo.
      mMode = if     X_utd.edoctype = EdocType:Returns:KeyIntDB
                 and X_utd.sts      = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB  
              then {&update}
              else {&lookup}.
      run str/upd_org.w (parparentproc, mDiadocConnection, X_utd.db-num, X_utd.doc-id,{&update}) .
      row_utd = rowid(x_utd).
      run init-id (X_utd.doc-id, X_utd.db-num).  
      br-utd:refresh () no-error.
      reposition br-utd to rowid row_utd no-error .
                
              
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_akt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_akt POPUP-MENU-b-print
ON CHOOSE OF menu-item m_akt /* Печать акт  приема-передачи */
    DO:
        if available (X_utd) then 
        do:
            if X_utd.edoctype = EdocType:UTD:KeyIntDB or 
                X_utd.edoctype = EdocType:AKT:KeyIntDB then 
            do:
                run rep/akt-utd.p (parparentproc, X_utd.db-num, X_utd.doc-id) no-error .
            end.  
            else 
            do:
                message "Акт приема-передачи не печатается для данного типа документа"
                    view-as alert-box.
            end.  
        end.  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_nakl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_nakl POPUP-MENU-b-servis
ON CHOOSE OF menu-item m_nakl /* Формирование накладной */
    DO:
        define variable v-check-db-num  as integer    no-undo .
        define variable v-check-user-id as character  no-undo .
   
        { gbl/getcurus.i
    v-check-db-num
    v-check-user-id
    no-error
  }

        if v-rid-list <> "" then 
        do:
            do ii = 1 to num-entries (v-rid-list):
                for first buf_utd no-lock where recid(buf_utd) = integer(entry(ii,v-rid-list)):
                    run ibs\th\str\utd\adaputd.p
                        (buf_utd.db-num, /*DocumentID*/
                        buf_utd.doc-id, /* OrganizationId*/
                        v-check-user-id /*User-Id*/
                        ) no-error .
                    def var v-msg as char no-undo.
                    if not error-status:error
                    then do:
                       if return-value matches "*ошибка*"
                       then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
                       else v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Товары данной поставки можно продавать на кассе.").
                    end.
                    else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
                    message v-msg view-as alert-box.
               end.  
            end.
            message "Накладные сформированы"
                view-as alert-box.   
            run init-sort in this-procedure .
            {&OPEN-QUERY-br-utd}
        end.  
        else 
        do:
            if available (X_utd) then 
            do:
                v-rid-list = string(recid(X_utd)) .
                find first buf_utd no-lock where buf_utd.doc-id = X_utd.doc-id and buf_utd.db-num = X_utd.db-num no-error .
                run ibs\th\str\utd\adaputd.p
                    (X_utd.db-num, /*DocumentID*/
                    X_utd.doc-id, /* OrganizationId*/
                    v-check-user-id /*User-Id*/
                    )  no-error.
                
                    if not error-status:error
                    then do:
                       if return-value matches "*ошибка*"
                       then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
                       else v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Товары данной поставки можно продавать на кассе.").
                    end.
                    else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
                    message v-msg view-as alert-box.
                run init-id (X_utd.doc-id, X_utd.db-num).
                
           end.  
        end.  
        v-rid-list = "" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_recEDI
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_recEDI POPUP-MENU-b-servis
ON CHOOSE OF menu-item m_recEDI /* Получить данные ЭДО */
    DO:
        define variable Log-Res as logical no-undo.

        /*Проверка прав */
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_request':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
        if log-res then
        do:
            run getNewupd no-error.
            if error-status:error then
            do:
                return return-value .
            end.
            run init-sort .
            {&OPEN-QUERY-br-utd}
        end.
        v-rid-list = "" .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_oneUtd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_oneUtd IN FRAME d-utd
ON CHOOSE OF b_oneUtd IN FRAME d-utd /* Повторно проверить */
    DO:

        if available (X_utd) then 
        do:
            recid_utd = recid (X_utd) .
            find first x_utd where recid (x_utd) = recid_utd .
            run updOneUTD(X_utd.db-num, X_utd.doc-id ) no-error  .       
            if  error-status:error then 
            do: 
                return return-value .
            end.
            run init-id (X_utd.doc-id, X_utd.db-num).  
        end.  
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON value-changed OF br-utd IN FRAME d-utd
    DO:
        run enable_BUTTON .
        b-pack:visible = (i-pack eq ? or i-pack eq "")
            and available X_utd and   X_utd.PackageId ne "" and X_utd.PackageId ne ? .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_recheck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_recheck POPUP-MENU-b-servis
ON CHOOSE OF MENU-ITEM m_recheck /* Повторно проверить */
    DO:
        define variable Log-Res as logical no-undo.
        { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_recheck':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
        if log-res then 
        do:
            define buffer buf_c-utd for ub.c-utd .
            if v-rid-list <> "" then 
            do:
                do ii = 1 to num-entries (v-rid-list):
                    /*            recid_utd = integer(entry(ii,v-rid-list)) .*/
                    find first x_utd where recid (x_utd) = integer(entry(ii,v-rid-list)) .
                    subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                    MySeqUtd = ?.
            
                    Recheck(X_utd.db-num, X_utd.doc-id).
                    unsubscribe "getNextseq".
                end.  
                run init-sort in this-procedure .
            end.   
            else 
            do:
                if available (X_utd) then 
                do:
                    recid_utd = recid (X_utd) .
                    subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                    MySeqUtd = ?.
            
                    Recheck(X_utd.db-num, X_utd.doc-id).
                    unsubscribe "getNextseq".
                    run init-id (X_utd.doc-id, X_utd.db-num).
                end.  
            end.
            {&OPEN-QUERY-br-utd}
            v-rid-list = "" .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_checknakl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_checknakl POPUP-MENU-b-servis
ON CHOOSE OF MENU-ITEM m_checknakl /* Привязать накладную */
    DO:
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer X_clients for ub.clients .
    define buffer Nakl_utd  for ub.utd .
    define variable loc-ref-list as character no-undo . 
    
        if available (X_utd) then 
        do:
           if ((X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB)
           or (X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WithRecipientPartiallySignature:KeyIntDB))
              and X_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
           do:
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = X_utd.doc-code no-error .
              if available (buf_trn-doc) then 
              do:
                 if buf_trn-doc.status_ = {&fact} then 
                 do:
                    message "Накладная " + string(buf_trn-doc.doc-code)+ " по документу " + X_utd.DocumentNumber + " уже создана."
                       view-as alert-box.
                    return no-apply .
                 end.
                 if buf_trn-doc.status_ <> {&fact} then 
                 do:
                    message "Накладная " + string(buf_trn-doc.doc-code)+ " по документу " + X_utd.DocumentNumber + " уже создана." skip
                       "Закройте накладную на факт"
                       view-as alert-box.
                    return no-apply .
                 end.  
              end.
           end.        
           else 
           do:
              message "Для документа нельзя привязать накладную."
                 view-as alert-box.
              return no-apply .
           end.               

            find first X_clients no-lock where X_clients.obj-code = X_utd.cli-code and 
                                               X_clients.obj-type = X_utd.cli-type no-error .
                                               
           if available (X_clients) then do:   

            run str/all-docs.w
                (input parparentproc
                ,input X_utd.host-code
                ,input X_utd.obj-type 
                ,input X_utd.obj-code
                ,input {&client-cmp}
                ,input {&fact}
                ,input {&TDEDT_Pri_Vnesh}
                ,input ?
                ,input ?
                ,input "b-sel,b-mark":U
                ,input ?
                ,input ?
                ,input recid(X_clients)
                ,output loc-ref-list ).
            if loc-ref-list = "" then 
            do:
                message
                    "Документы не выбраны"
                    view-as alert-box error.
                return no-apply.
            END.
            else do:
                find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) and buf_trn-doc.status_ = {&fact} no-error .
                if not available (buf_trn-doc) then 
                do:
                    message
                        "Документ не закрыт до статуса - факт"
                        view-as alert-box error.
                    return no-apply.
                end.  
 
                find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) and buf_trn-doc.status_ = {&fact} 
                and buf_trn-doc.fact-date >= X_utd.DocumentDate no-error .
                if not available (buf_trn-doc) then 
                do:
                    message
                        "Накладная создана раньше документа"
                        view-as alert-box error.
                    return no-apply.
                end.    
                else do:
                find first Nakl_utd no-lock where Nakl_utd.doc-code = buf_trn-doc.doc-code no-error .
                if available (Nakl_utd) then do:
                    message
                        "Накладная " + string(buf_trn-doc.doc-code) + " привязана к другому документу УПД " + string(Nakl_utd.DocumentNumber)
                        view-as alert-box error.
                    return no-apply.                   
                end.
                end.   
            end .    
            find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) no-error .
            if available (buf_trn-doc) then do:
                find first Nakl_utd exclusive-lock where Nakl_utd.doc-id = X_utd.doc-id 
                                                     and Nakl_utd.db-num = X_utd.db-num no-error . 
                Nakl_utd.doc-code = buf_trn-doc.doc-code .
                run init-sort .
                {&OPEN-QUERY-br-utd}
            end.    
            end.
            else message "Не найден поставщик " + X_utd.cli-type + " " + string(X_utd.cli-code) + "."
                 view-as alert-box.
                       
        end. 
        else do:
            message "Не найден документ."
                 view-as alert-box.
            
        end.    
         
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status d-utd
ON VALUE-CHANGED OF c-status IN FRAME d-utd /* Статус ТН */
    DO:
        assign c-status .
        run init-sort .
        {&OPEN-QUERY-br-utd}
  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status-edi d-utd
ON VALUE-CHANGED OF c-status-edi IN FRAME d-utd /* Статус EDI */
    DO:
        assign c-status-edi .
        run init-sort .
        {&OPEN-QUERY-br-utd}
  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-type d-utd
ON VALUE-CHANGED OF c-type IN FRAME d-utd /* Тип */
    DO:
        assign c-type .
        run init-sort .
        {&OPEN-QUERY-br-utd}
  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from d-utd
ON RETURN OF F-date-from IN FRAME d-utd
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from d-utd
ON TAB OF F-date-from IN FRAME d-utd
    DO:
        if string(F-date-from) <> F-date-from:screen-value then 
        do:
            assign F-date-from .
        end.
        if F-date-from < F-date-to then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            return no-apply .       
        end.
        run init-sort .
        {&OPEN-QUERY-br-utd}
        run enable_BUTTON.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mark Dialog-Frame
ON return,tab OF f-mark IN FRAME d-utd /* mark */
DO:
   if f-mark eq f-mark:screen-value
   then
      return no-apply.
   assign
      f-mark
   .
   f-mark:sensitive    = f-mark eq "".
   b_cl_mark:visible   = f-mark ne "".
   b_cl_mark:sensitive = b_cl_mark:visible. 
   apply "entry" to b_cl_mark IN FRAME d-utd .
   run init-sort .
   {&OPEN-QUERY-br-utd}
   run enable_BUTTON.  
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_cl_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_cl_mark IN FRAME d-utd
ON CHOOSE OF b_cl_mark  IN FRAME d-utd /* Повторно проверить */
DO:
   f-mark:screen-value = "".
   assign
      f-mark
   .
   f-mark:sensitive    = f-mark eq "".
   b_cl_mark:visible   = f-mark ne "".
   b_cl_mark:sensitive = b_cl_mark:visible.
   apply "entry" to f-mark IN FRAME d-utd .
   run init-sort .
   {&OPEN-QUERY-br-utd}
   run enable_BUTTON. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME F-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-to d-utd
ON RETURN OF F-date-to IN FRAME d-utd /* За период с */
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-to d-utd
ON TAB OF F-date-to IN FRAME d-utd /* За период с */
    DO:
        if string(F-date-from) <> F-date-from:screen-value then 
        do:
            assign F-date-to .
        end.
        if F-date-from < F-date-to then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            return no-apply .       
        end.
        run init-sort .
        {&OPEN-QUERY-br-utd}
        run enable_BUTTON.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-DocumentNumber
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-DocumentNumber d-utd
ON value-changed OF f-DocumentNumber IN FRAME d-utd /* Номер документа */
    DO:
        assign f-DocumentNumber .
        run init-sort .
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___Token
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___Token d-utd
ON CHOOSE OF MENU-ITEM m___Token /* Отключить запрос Token */
    DO:
        define variable v-ok as logical no-undo .
        if F-sertif <> "" then v-ok = yes . 
        else v-ok = no .
        run str/dialog-Token.w (input v-ok, input-output v-flag) no-error .

        if not v-flag then 
        do:
            run enable_BUTTON .
        end.  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 d-utd
ON value-changed OF RADIO-SET-1 IN FRAME d-utd
    DO:
        assign RADIO-SET-1 .
        run init-sort .
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME R-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-obj d-utd
ON value-changed OF R-obj IN FRAME d-utd
    DO:
        assign R-obj .
        if R-obj = 1 then 
        do:
            hide
                bt-sel-obj
                obj-list
                in frame {&frame-name} .
            empty temp-table tt-obj-list .
        end.
        else 
        do:
            enable
                bt-sel-obj
                with frame {&frame-name} .      
            display
                obj-list
                with frame {&frame-name} .      
            apply "choose" to bt-sel-obj in frame {&frame-name}. 
        end.
        
        run init-sort .
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RADIO-SET-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-2 d-utd
ON value-changed OF RADIO-SET-2 IN FRAME d-utd
    DO:
        assign RADIO-SET-2 .
        run init-sort .
        {&OPEN-QUERY-br-utd}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RADIO-SET-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-timeToken d-utd
ON value-changed OF F-timeToken IN FRAME d-utd
    DO:
        if v-Token-error then 
        do:
            if v-sertif_num <> "" or v-cntxt-db-num = 0 then 
            do:
                F-timeToken:fgcolor = 12 .
                F-timeToken = "не получено" .
            end.
            else F-timeToken = "" .
        end.
        else 
        do:
            if time_motp <> ? then 
            do:
                F-timeToken:fgcolor = 0 .
                F-timeToken = string(time_motp,"99/99/9999 HH:MM:SS") .
            end.
            else F-timeToken = "" . 
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-utd 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
    APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/brwrepos.i
  &line-num= 9
}

    
    { gbl/ed_date.i f-date-from }
    { gbl/ed_date.i f-date-to }

    

    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_gettok':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res-Token
}

    /*Проверка прав */
    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_recheck':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res-recheck
}

    { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_fact':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  false
                  varlog
                }
    run uf-get (
        input {&uf-UPD}
        , input  v-cntxt-userid
        , output v-current-sertif-string
        , output v-current-sort-string
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        ) no-error.
    if v-current-sertif-string <> "" then 
    do:
        F-sertif = v-current-sertif-string .
    end. 
    Marking = ObjSrv:Env:Marking:Sts:Mark.

  { gbl/conf-rd.i
        "'is-erpRN'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          NO
          conf-par
          par-type
          no-error
          }
  if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.

    StatusTH = ObjSrv:Env:Utd:Sts:TH.
    StatusEDI = ObjSrv:Env:Utd:Sts:EDI.
    EdocType = ObjSrv:Env:Utd:EDocType.      

    F-date-to = today - 7.
    F-date-from = today .

    if v-current-sertif-string <> "" then 
    do:
        F-sertif = v-current-sertif-string .
    end.  
    run init-temp in this-procedure .
    { gbl/diasize.i }
    run diasize_init in this-procedure .
    run enable_UI in this-procedure .
    apply "value-changed" to br-utd IN FRAME {&frame-name}.
    if time_motp <> ? then 
    do:

        if v-sertif <> "" and mode-erprn = false then 
        do:
            vtime = max(1,time_motp + 10500000 - now).
            block-wait:  

            do while not mflagExit:
                /*WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name} pause vtime .*/

                WAIT-FOR CHOOSE OF FRAME {&frame-name}  focus f-mark pause vtime .
    
                vtime = max(0,time_motp + 10500000 - now).
                if vtime = 0 and not v-flag then
                    run proc-Token no-error .
                vtime = max(60000,time_motp + 10500000 - now).
   
            end.
        end.
        else 
        do:

            WAIT-FOR GO OF FRAME {&FRAME-NAME} focus f-mark .
        end.  
    end.
    else 
    do:

        WAIT-FOR GO OF FRAME {&FRAME-NAME} focus f-mark .
    end.  
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-utd  _DEFAULT-DISABLE
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
    HIDE FRAME d-utd.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_BUTTON d-utd 
PROCEDURE enable_BUTTON :
    

    F-timeToken = string(time_motp) .
    apply "value-changed" to F-timeToken in frame {&frame-name}.
    display
        F-timeToken
        with frame {&frame-name} .
    if available (X_utd) and mDiadocConnection <> ? 
        then 
    do:                      
        enable
            b_anul
            B-write-cancel
            B-write-sertif
            with frame {&frame-name} .
        menu-item m_return_send:sensitive in menu POPUP-MENU-b-servis = varlog and X_utd.EDocType eq ObjSrv:Env:Utd:EDocType:returns:KeyIntDB .
    end. 
    else 
    do:
       menu-item m_return_send:sensitive in menu POPUP-MENU-b-servis = no.
        if AVAILABLE (X_utd) and (X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB or X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB) then 
        do:
            enable
                B-write-sertif
                with frame {&frame-name} .
        end.
        else 
        do:
            DISABLE
                B-write-sertif
                with frame {&frame-name} .

        end.        
        disable
            b_anul
            B-write-cancel
            with frame {&frame-name} .
     
    end.         
    if mDiadocConnection <> ? 
        then enable  b_oneUtd with frame {&frame-name} .
    else disable b_oneUtd with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _Function checkMark d-utd 
function checkMark returns logical 
   (idb-num as integer, 
    idoc-id as integer ):
   define buffer cancel_utd-lines for ub.utd-marking-lines .
   define buffer cancel_marking           for ub.marking .
   define buffer X_utd                    for X_utd .
   define variable v-write-cancel as logical no-undo .
   v-write-cancel = false .
   define variable vpen as integer no-undo.
   define variable vdel as integer no-undo.
   v-write-cancel = true.
   define variable vqnty as decimal no-undo.
   block-line:
   for each cancel_utd-lines where cancel_utd-lines.doc-id = idoc-id and cancel_utd-lines.db-num = idb-num no-lock: 
      vqnty = decimal(GetAttrUtdlinesex(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode","0")).
      if vqnty ne 0
      then do:
         v-write-cancel = false .
         leave block-line.
      end.
   end.
   if     v-write-cancel
   then do:
      find first utd where utd.db-num eq idb-num
                       and utd.doc-id eq idoc-id
      no-lock no-error.
      if available  utd
         and utd.sts-edi <> ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB 
         and utd.sts-edi <> ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB
      then
         return no.
      else
         return yes.
   end.
   else
      return yes.
END function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-utd 
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
    if p-mode = "" then 
    do:
        ENABLE
            b-inout
            br-utd
            b-pack
            b-exit
            b-update
            R-obj
            b-utd
            b-hist
            b-print
            b-del
            b-refresh
            c-status
            c-status-edi
            RADIO-SET-1
            c-type
            F-date-from
            F-date-to
            b-mark
            bt-not-sel-all
            b-servis
            f-DocumentNumber
            f-mark
            radio-set-2
            bt-not-sel-desel-all
            B-LK_RECEIPT
            WITH FRAME {&frame-name}.
        display
            b-inout
            B-write-Token
            b_anul
            B-write-cancel
            b_oneUtd
            B-write-sertif
            F-sertif
            mark-num
            F-date-from
            F-date-to
            f-mark
            with frame {&frame-name} .
        enable
            b-choose-sertif
            with frame {&frame-name} .   
        hide b-sel b_cl_mark in frame {&frame-name} . 
        if v-obj-active then enable b-add with frame {&frame-name} .    
        if v-cntxt-db-num <> 0 
        then
          hide B-LK_RECEIPT in frame {&frame-name} . 
    end.
    if p-mode = {&select} then 
    do:
        ENABLE
            b-inout
            b-mark
            bt-not-sel-all
            b-sel
            br-utd
            b-exit
            b-utd
            bt-not-sel-desel-all
            R-obj
            radio-set-2
            c-status
            c-status-edi
            RADIO-SET-1
            c-type
            F-date-from
            F-date-to
            f-DocumentNumber
            f-mark
            WITH FRAME {&frame-name}.
        display     F-date-from
            b-inout
            F-date-to
            with frame {&frame-name} .
        disable
            b-hist
            b-print
            b-del
            b-refresh
            b-servis
            B-write-Token
            b_anul
            B-write-cancel
            b_oneUtd
            B-write-sertif
            F-sertif
            mark-num
            b-choose-sertif
            f-mark
            with frame {&frame-name} .    
        hide b-update b_cl_mark in frame {&Frame-name} .
    end.  
    if log-res-Token then 
    do:
        menu-item m___Token:sensitive in menu POPUP-MENU-b-servis = yes.
    end.
    else 
    do:
        menu-item m___Token:sensitive in menu POPUP-MENU-b-servis = no.  
    end.
    if log-res-recheck then 
    do:
        menu-item m_recheck:sensitive in menu POPUP-MENU-b-servis = yes .
    end.
    else 
    do:
        menu-item m_recheck:sensitive in menu POPUP-MENU-b-servis = no .
    end.     
    if varlog then 
    do:
        menu-item m_nakl:sensitive in menu POPUP-MENU-b-servis = yes .
    end.
    else 
    do:
        menu-item m_nakl:sensitive in menu POPUP-MENU-b-servis = no .
    end.  
    if v-current-sertif-string <> "" then 
    do:
        v-sertif_num =  v-current-sertif-string .
        run proc-sertif (no).
        F-sertif = v-sertif_num .
        if f-sertif <> "" then 
        do:
            enable       B-write-Token with frame {&frame-name} .
        end.
        else 
        do:
            disable       B-write-Token with frame {&frame-name} .
        end.  
        display
            F-sertif
            with frame {&frame-name} .  
        run enable_BUTTON .
    end. 
  
  if mode-erprn then 
  do:
     DISABLE
        B-write-sertif
        b-choose-sertif
      with frame {&frame-name} .
    browse br-utd:GET-BROWSE-COLUMN(11):VISIBLE = no no-error.
  end.  
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-id d-utd 
PROCEDURE init-id :
    /* --------------------------------------------------------------------
                        Purpose:     ENABLE the User Interface
                        Parameters:  <none>
                        Notes:       Here we display/view/enable the widgets in the
                                     user-interface.  In addition, OPEN all queries
                                     associated with each FRAME and BROWSE.
                                     These statements here are based on the "Other
                                     Settings" section of the widget Property Sheets.
                         -------------------------------------------------------------------- */
    define input parameter p-doc-id as integer no-undo .
    define input parameter p-db-num as integer no-undo .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .

    find first X_utd exclusive-lock where X_utd.doc-id = p-doc-id and X_utd.db-num = p-db-num no-error .
    if available (X_utd) then 
    do: 
        X_utd.GrayZone = no .
        FOR EACH buf_utd NO-LOCK where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num:
            X_utd.sts = buf_utd.sts .
            X_utd.sts-edi = buf_utd.sts-edi .
            X_utd.stts = StatusTHName(buf_utd.sts).
            X_utd.stts-edi = StatusEDIName(buf_utd.sts-edi).
            X_utd.doc-code = buf_utd.doc-code.
            if v-cntxt-db-num <> 0 then 
            do:
                for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num 
                    and buf_utd-marking-lines.doc-id = buf_utd.doc-id,
                    first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                    and buf_marking.sts = Marking:GrayZone:KeyIntDB:
                    X_utd.GrayZone = yes .
                    leave .                                                                                                
                end.                                             
            end.  
        end.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-sort d-utd 
PROCEDURE init-sort :
    /* --------------------------------------------------------------------
                        Purpose:     ENABLE the User Interface
                        Parameters:  <none>
                        Notes:       Here we display/view/enable the widgets in the
                                     user-interface.  In addition, OPEN all queries
                                     associated with each FRAME and BROWSE.
                                     These statements here are based on the "Other
                                     Settings" section of the widget Property Sheets.
                         -------------------------------------------------------------------- */

    define variable p-ok    as logical no-undo .
    define variable v-days  as integer no-undo .
    define variable v-days1 as integer no-undo .
    define variable v-days2 as integer no-undo .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    if AVAILABLE (X_utd) then empty temp-table X_utd .
    /*  if v-current-sort-string <> "" then do:                                */
    /*    c-status = string(entry(1,v-current-sort-string,{&delim-key})) .     */
    /*    c-status-edi = integer(entry(2,v-current-sort-string,{&delim-key})) .*/
    /*    c-type = integer(entry(3,v-current-sort-string,{&delim-key})) .      */
    /*    RADIO-SET-1 = integer(entry(4,v-current-sort-string,{&delim-key})) . */
    /*    RADIO-SET-2 = integer(entry(4,v-current-sort-string,{&delim-key})) . */
    /*  end.                                                                   */
  
    define variable mQuery as handle    no-undo.
    define variable vqry   as character no-undo.
    create query mQuery.
    mQuery:set-buffers(buffer buf_utd:HANDLE).
    define variable vinout as character no-undo.
    
    if       i-Pack ne "" 
        and i-pack ne ?
    then do:
       if not Vflaginout
       then
          vinout = " (buf_utd.Direction eq 'inbound' or buf_utd.Direction eq '') ".
       else
          vinout = " buf_utd.Direction ne 'inbound'".
    
        vqry = substitute("FOR EACH buf_utd where buf_utd.PackageId eq '&1' and &2 no-lock" ,  i-pack,vinout).
    
    end. 
    else do:
       if not Vflaginout
       then
          vinout = substitute (" buf_utd.host-code = &1 and (buf_utd.Direction eq 'inbound'  or buf_utd.Direction eq '') ",  v-cntxt-host-code-obj).
       else
          vinout = " buf_utd.Direction ne 'inbound' and buf_utd.Direction ne '' " .
    
        vqry = substitute("FOR EACH buf_utd where &1 and buf_utd.DocumentDate >= &2 and buf_utd.DocumentDate <= &3 no-lock" , vinout,f-date-to,f-date-from).
    end.
    define variable vGdsCode  as integer   no-undo.
    define variable vGtin     as character no-undo.
    define variable vMark     as character no-undo.
    define variable vMarkGtin as character no-undo.
    define variable vInt      as logical   no-undo.
    define variable vi        as integer   no-undo.
    define buffer goods             for goods.
    define buffer bar-code          for bar-code.
    define buffer prod-bc           for prod-bc.
    define buffer utd-lines         for utd-lines.
    define buffer utd-marking-lines for utd-marking-lines.
    assign
       vGdsCode = 0
       vGtin    = ""
       vMark    = ""
    .
    if f-mark ne ""
    then do:
       int(f-mark) no-error.
       vInt = not error-status:error.
       if vInt
       then
          find first goods where goods.gds-code eq int(f-mark) no-lock no-error.
       if available goods
       then do:
          vGdsCode  = goods.gds-code.
       end.
       else do:
          if vInt
          then
             find first bar-code where bar-code.b-code eq int(f-mark) no-lock no-error.
          if available bar-code
          then do:
             vGdsCode  = bar-code.gds-code.
          end.
          else do:
             block-fill:
             do vi = 0 to 10:
                find first prod-bc where prod-bc.b-str eq fill("0",vi) + f-mark no-lock no-error.
                if available prod-bc
                then
                   leave block-fill.
             end. 
             if available prod-bc
             then do:    
                if prod-bc.bc-on-type = {&gtin}
                then
                   vGtin = prod-bc.b-str.
                else do:
                    find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
                    if available bar-code
                    then
                       vGdsCode  = bar-code.gds-code.
                end.
             end.
             else do:
                vMark     = getcodeident(f-mark).
                vMarkGtin = getGtinByDM (f-mark).
             end.
          end.
       end.
    end. 
    mQuery:query-prepare(vqry).
    mQuery:query-open ().
    mQuery:get-first ().
                                                                         
    /*  FOR EACH buf_utd NO-LOCK where buf_utd.host-code = v-cntxt-host-code-obj and buf_utd.DocumentDate >= f-date-to and buf_utd.DocumentDate <= f-date-from :*/
    do while not mQuery:query-off-end:
        if       i-Pack ne "" 
            and i-pack ne ?
            and buf_utd.DocumentDate < f-date-to
            then 
        do:
            f-date-to = buf_utd.DocumentDate.
            display f-date-to. 
        end.
        
        if buf_utd.EDocType = EdocType:LK_RECEIPT:KeyIntDB /* Вывод из оборота */
        or buf_utd.EDocType = EdocType:Mark_Collect:KeyIntDB /* Сбор марок */
        then do :
          mQuery:get-next (). 
          next .
        end .
        if vGdsCode  ne 0
        then do:
           find first utd-lines where utd-lines.db-num   eq buf_utd.db-num
                                  and utd-lines.doc-id   eq buf_utd.doc-id
                                  and utd-lines.gds-code eq vGdsCode
           no-lock no-error.
           if not available utd-lines
           then do :
              mQuery:get-next (). /* Вывод из оборота */
              next .
           end .
        end.
        if vGtin ne ""
        then do:
           find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                          and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                          and utd-marking-lines.mark     begins "01" + vGtin + "21"
           no-lock no-error.
           if not available utd-marking-lines
           then
              find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                             and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                             and utd-marking-lines.mark     begins "02" + vGtin + "37"
              no-lock no-error.
           if not available utd-marking-lines
           then do :
              mQuery:get-next (). /* Вывод из оборота */
              next .
           end .
        end.
        if vMark ne ""
        then do:
           find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                          and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                          and utd-marking-lines.mark     begins vMark
           no-lock no-error.
           if not available utd-marking-lines
           then
              find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                             and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                             and utd-marking-lines.mark     begins "02" + vMarkGtin + "37"
              no-lock no-error.
           
           if not available utd-marking-lines
           then do :
              mQuery:get-next (). /* Вывод из оборота */
              next .
           end .
        end.
        create X_utd .
        buffer-copy buf_utd to X_utd . 
        X_utd.stts = StatusTHName(X_utd.sts).
        X_utd.stts-edi = StatusEDIName(X_utd.sts-edi).
        X_utd.cli-name = CliName(X_utd.cli-code, X_utd.cli-type).
        X_utd.EdoTypeName = EdoTypeName(X_utd.EDocType).
        X_utd.GrayZone = no .
        X_utd.obj-name = buf_utd.obj-type + " " + string(buf_utd.obj-code) .
        for first ub.utd no-lock where ub.utd.DocumentExt = buf_utd.parentDocumentExt and ub.utd.OrganizationExt = buf_utd.parentOrganizationExt:
            if ub.utd.DocumentNumber <> buf_utd.documentNumber then 
                X_utd.orig-code = ub.utd.DocumentNumber .
        end.     

        if X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and 
        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB and 
        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB then 
        do:
            if X_utd.ModifyDate <> ? and X_utd.ModifyTime <> ? and X_utd.ModifyTime <> 0 then 
            do:
                if today = X_utd.ModifyDate then 
                do:
                    X_utd.ModifyTime_ = string((time - X_utd.ModifyTime), "HH:MM") .
                end.
                else 
                do:
                    if time < X_utd.ModifyTime then X_utd.ModifyTime_ = string((time - X_utd.ModifyTime), "HH:MM") .
                    else X_utd.ModifyTime_ = "> суток" .
                end.    
            end.
        end.

        if v-cntxt-db-num <> 0 then 
        do:
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = X_utd.db-num 
                and buf_utd-marking-lines.doc-id = X_utd.doc-id,
                first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                and buf_marking.sts = Marking:GrayZone:KeyIntDB:
                X_utd.GrayZone = yes .
                leave .                                                                                                
            end.                                             
        end. 
        mQuery:get-next ().
    end.
    delete object mQuery.
    find first tt-obj-list no-error .
    if available (tt-obj-list) then 
    do:
        for each X_utd:
            p-ok = false .
            for each tt-obj-list:
                if X_utd.obj-code = tt-obj-list.obj-code and X_utd.obj-type = tt-obj-list.obj-type then p-ok = true.
            end.
            if p-ok <> true then delete X_utd .  
        end.  
    end.
    if c-status <> "-1" then 
    do:
        for each X_utd where X_utd.sts <> integer(c-status):
            delete X_utd .
        end.  
    end.    
    if c-status-edi <> 0 then 
    do:
        for each X_utd where X_utd.sts-edi <> c-status-edi:
            delete X_utd .
        end.  
    end.
    case RADIO-SET-1:
        when 1 then 
            do:
                for each X_utd :
                    if StatusTH:CheckStsErr(X_utd.sts)
                        then next.
                    delete X_utd .
                end.  
            end.  
        when 2 then 
            do:
                for each X_utd where X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB or 
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:ConfirmedUcd:KeyIntDB or
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB:
                    delete X_utd .
                end.  
            end.  
    end case.
    case RADIO-SET-2:
        when 1 then 
            do:
                for each X_utd where X_utd.sts-edi > 100 :
                    delete X_utd .
                end.  
            end.  
        when 2 then 
            do:
                for each X_utd where X_utd.sts-edi < 100 :
                    delete X_utd .
                end.  
            end.  
    end case.  
    if c-type <> 0 then
    do:
        for each X_utd where X_utd.EDocType <> c-type:
            delete X_utd .
        end.
    end.
    if f-DocumentNumber <> "" then 
    do:
        for each X_utd :
            if X_utd.DocumentNumber begins f-DocumentNumber
                then next.
            delete X_utd .
        end.
    end.  
    apply "value-changed" to br-utd IN FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-utd 
PROCEDURE init-temp :
    /* --------------------------------------------------------------------
                        Purpose:     ENABLE the User Interface
                        Parameters:  <none>
                        Notes:       Here we display/view/enable the widgets in the
                                     user-interface.  In addition, OPEN all queries
                                     associated with each FRAME and BROWSE.
                                     These statements here are based on the "Other
                                     Settings" section of the widget Property Sheets.
                         -------------------------------------------------------------------- */

    define variable ii         as integer   no-undo .
    define variable Status_    as character no-undo .
    define variable Status_EDI as character no-undo .
    define variable Edoc_type  as character no-undo .

    Status_ = "Все" + {&comma-char} + '-1':U .

    do ii = 1 to StatusTH:mapType:GetItemByLab(ii):
        if StatusTH:CurrProp:KeyIntDB >= 50
        and StatusTH:CurrProp:KeyIntDB < 60
        then next . /* Вывод из оборота */
        Status_ = Status_ + {&comma-char} + StatusTH:CurrProp:Label_ + {&comma-char} + string(StatusTH:CurrProp:KeyIntDB) .
    end.

    Status_EDI = "Все" + {&comma-char} + '0':U .

    do ii = 1 to StatusEDI:mapType:GetItemByLab(ii):
        Status_EDI = Status_EDI + {&comma-char} + replace(StatusEDI:CurrProp:Label_,",","") + {&comma-char} + string(StatusEDI:CurrProp:KeyIntDB) .
    end.
  
    Edoc_Type = "Все" + {&comma-char} + '0':U .
  
    do ii = 1 to EdocType:mapType:GetItemByLab(ii):
      if EdocType:CurrProp = EdocType:LK_RECEIPT /* Вывод из оборота */
      or EdocType:CurrProp = EdocType:Mark_Collect /* Сбор марок */
      then next . 
        Edoc_type = Edoc_type + {&comma-char} + EdocType:CurrProp:Label_ + {&comma-char} + string(EdocType:CurrProp:KeyIntDB) .
    end.

    ASSIGN
        c-status-edi:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_EDI .
    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_ .
    ASSIGN
        c-type:LIST-ITEM-PAIRS  in frame {&frame-name} = Edoc_type .

    c-status = "-1" .
    c-status-edi = 0 . 
    RADIO-SET-1 = 2 .  
    radio-set-1:screen-value = "2" .
    if p-mode = {&select} and p-type <> 0 then 
    do:
        c-type = integer(p-type) .
        c-type:screen-value = string(c-type) .
    end.  
    if not mode-erprn then 
    do:
    run proc-Token .
    end.
    run init-sort .
    {&OPEN-QUERY-br-utd}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sertif d-utd 
PROCEDURE proc-sertif :
    /* --------------------------------------------------------------------
                        Purpose:     ENABLE the User Interface
                        Parameters:  <none>
                        Notes:       Here we display/view/enable the widgets in the
                                     user-interface.  In addition, OPEN all queries
                                     associated with each FRAME and BROWSE.
                                     These statements here are based on the "Other
                                     Settings" section of the widget Property Sheets.
                         -------------------------------------------------------------------- */
    define input  parameter iChange as logical no-undo.
    define variable vCertificates    as component-handle no-undo.
    define variable vCertificate     as component-handle no-undo.
    define variable mDiadocApi       as component-handle no-undo.
    define variable mReflector       as component-handle no-undo.
    define variable vCertificateName as component-handle no-undo .
    define variable vi               as integer          no-undo.
    if mDiadocApi eq ?
        then
        create "Diadoc.DiadocClient":U mDiadocApi no-error.
    if mDiadocApi eq ?
        then
        return.
    if    (    p-connect eq ? 
        and (i-pack eq ? or i-pack eq "")
        )
        or iChange
        then 
    do:

        vCertificates = mDiadocApi:GetPersonalCertificates(true).
        cerfcnt:
        do vi = 1 to  vCertificates:count:
            vCertificate = vCertificates:GetItem(vi - 1).
            if vCertificate:SerialNumber = v-sertif_num then 
            do: 
                v-sertif = vCertificate:Thumbprint .
                leave cerfcnt.
            end.    
        end.
        conectbyCertif(v-sertif) .        
        p-connect = mDiadocConnection.
        if mDiadocConnection ne ?
        then
           run SendAuto.
    end.
    else 
    do:
        mDiadocConnection = p-connect.
        if mDiadocConnection ne ? then run SendAuto.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-Token d-utd 
PROCEDURE proc-Token :
    /* --------------------------------------------------------------------
                        Purpose:     ENABLE the User Interface
                        Parameters:  <none>
                        Notes:       Here we display/view/enable the widgets in the
                                     user-interface.  In addition, OPEN all queries
                                     associated with each FRAME and BROWSE.
                                     These statements here are based on the "Other
                                     Settings" section of the widget Property Sheets.
                         -------------------------------------------------------------------- */
    define buffer buf_ext-system      for ub.ext-system .
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable oMotp as class ibs.th.bge.is_motp.is_motp no-undo .
    for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = {&attr-esys-obj}
        and buf_ext-system-attr.esya-attr-value  = v-cntxt-obj-type + string(v-cntxt-obj-code)
        /* and buf_ext-system-attr.db-num           = buf_db.db-num */
        :
        find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-is_motp})
            and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id 
            no-error .
        R-obj = 2 .
        empty temp-table tt-obj-list .

        create tt-obj-list .
        assign
            tt-obj-list.obj-code = v-cntxt-obj-code
            tt-obj-list.obj-type = v-cntxt-obj-type
            .
        obj-list = v-cntxt-obj-type + " " + string(v-cntxt-obj-code) . 
        display obj-list r-obj with frame {&frame-name} . 
        disable bt-sel-obj with frame {&frame-name} .
        if available buf_ext-system then leave .

    /*        run init-sort .         */
    /*            {&OPEN-QUERY-br-utd}*/
    end .
    if not available buf_ext-system
        then
        for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = {&attr-esys-host-code}
            and buf_ext-system-attr.esya-attr-value  = string(v-cntxt-host-code-obj)
            /* and buf_ext-system-attr.db-num           = buf_db.db-num */
            :
            find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-is_motp})
                and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id 
                no-error .
            if available buf_ext-system then leave .
        end .                                      
    if not available buf_ext-system
        then 
    do :
        if v-mes-Token then 
        do:
            message "Нет внешней системы с типом ИС МОТП" view-as alert-box .
            return .
        end. 
        else return . 
    end.    
         
    v-mes-Token = no .
    oMotp = new is_motp(buf_ext-system.db-num, buf_ext-system.esys-id) .
    time_motp = oMotp:currTokenDT .
    /*vToken = oMotp:authorize(input pKey, input pMode) .                                                        */
    /*                                                                                                           */
    /*pKey - ключ, по которому ищется сертификат.                                                                */
    /*pMode - что за ключ. Сейчас реализованы отпечаток сертификата (ThumbPrint) и серийный номер (SerialNumber).*/
    /*                                                                                                           */
    /*Для авторизации по серийному номеру будет так:                                                             */
    /*vToken = oMotp:authorize(input “01957BD10043AB1685421BAAE6508FB175”, input ”SerialNumber”) .               */

    /*Для авторизации по отпечатку:*/
    if v-sertif <> ? and v-sertif <> "" then 
    do:

        vToken = oMotp:authorize(input v-sertif, input "ThumbPrint") no-error .
        if error-status:error
            then 
        do:
            /*      time_motp = datetime-tz(now - 10500000) .*/
            time_motp = oMotp:currTokenDT .
            vtime = max(0,time_motp + 10500000 - now).
            if vtime = 0 then v-Token-error = true .
            else v-Token-error = false .

            /*      v-Token-error = true .         */
            /*      time_motp = oMotp:currTokenDT .*/
            message oMotp:MSG view-as alert-box .  
        end.  
        else 
        do:
            time_motp = oMotp:currTokenDT . 
            v-Token-error = false.
        end.

    end.
    else 
    do:
        time_motp = oMotp:currTokenDT .
        vtime = max(0,time_motp + 10500000 - now).
        if vtime = 0 then v-Token-error = true .
        else v-Token-error = false .
    end.     
    apply "value-changed" to F-timeToken IN FRAME {&frame-name}.              
    /* Это теперь внутри метода autorize. Там же обновляется время (атрибут AuthTokenDT)
    find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-is_motp}) no-error.
    if not available buf_ext-system
      then 
    do :
      message "Внешняя система не найдена с типом: " + {&openxml-type-is_motp}
        view-as alert-box.    
      return .
    end.

    find first buf_ext-system-attr exclusive-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
      and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
      and buf_ext-system-attr.esya-attr-code = "AuthToken"
      no-error .
    if not available buf_ext-system-attr
      then 
    do :
      create buf_ext-system-attr.
      assign
        buf_ext-system-attr.db-num         = buf_ext-system.db-num
        buf_ext-system-attr.esys-id        = buf_ext-system.esys-id
        buf_ext-system-attr.esya-attr-code = "AuthToken"
        .
    end.
    buf_ext-system-attr.esya-attr-value = vToken .
    */
    delete object oMotp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION CliName d-utd 
FUNCTION CliName RETURNS CHARACTER
    (input p-cli-code as integer, input p-cli-type as character) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define variable v-cli-name as character no-undo .
    find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
        and buf_clients.obj-type = p-cli-type no-error .
    if available (buf_clients) then v-cli-name = buf_clients.obj-name .
    RETURN v-cli-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION EdoTypeName d-utd 
FUNCTION EdoTypeName RETURNS CHARACTER
    ( input p-stsTH as integer ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN EdocType:GetLabel(p-stsTH) .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION StatusEDIName d-utd 
FUNCTION StatusEDIName RETURNS CHARACTER
    ( input p-stsEDI as integer ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define variable v-status-name as character no-undo .
    define buffer buf_utd-attr for ub.utd-attr .
  
    if p-stsEDI = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB then 
    do:

        find first buf_utd-attr no-lock where buf_utd-attr.doc-id = buf_utd.doc-id and
            buf_utd-attr.db-num = buf_utd.db-num and
            buf_utd-attr.attr-code = "sendcode"  no-error .
        if available (buf_utd-attr) then 
        do:
            case buf_utd-attr.attr-value:
                when "2" then 
                    do:
                        v-status-name = "(С расхождением)" .
                    end.
                when "3" then 
                    do:
                        v-status-name = "(Не принято)" .
                    end.
                otherwise 
                do:
                    v-status-name = "" .
                end.       
            end case .   
        end.           
        RETURN StatusEdi:GetLabel(p-stsEDI) + " " + v-status-name.   /* Function return value. */
    end.
    else 
    do:  
        RETURN StatusEdi:GetLabel(p-stsEDI).   /* Function return value. */
    end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION StatusTHName d-utd 
FUNCTION StatusTHName RETURNS CHARACTER
    ( input p-stsTH as integer ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN StatusTH:GetLabel(p-stsTH) .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

