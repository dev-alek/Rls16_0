&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
using ibs.th.gbl.sys.objsrv.
using ibs.th.bge.is_motp.*.
using ibs.th.str.utd.edoctype .
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-utd


/* Temp-Table and Buffer definitions                                    */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-utd 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документы Вывода из оборота

Author: Sergey SLivenko
Creation date: 01/07/2022

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
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

DEFINE BUFFER X_utd FOR tt-utd.

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
  

/* Temp-Table and Buffer definitions                                    */

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
F-date-to F-date-from F-sertif b-choose-sertif obj-list bt-sel-obj b-trn-doc ~
c-status ~
b-mark br-utd B-write-sertif ~
mark-num 
&Scoped-Define DISPLAYED-OBJECTS F-date-to F-date-from F-sertif obj-list ~
c-status 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD CliName d-utd 

FUNCTION CliName RETURNS CHARACTER
    (input p-cli-code as integer, input p-cli-type as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
&Scoped-define QUERY-STRING-br-utd FOR EACH X_utd NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-utd OPEN QUERY br-utd FOR EACH X_utd NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-utd X_utd
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd X_utd


/* Definitions for DIALOG-BOX d-utd                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-utd ~
    ~{&OPEN-QUERY-br-utd}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-utd b-print b-hist F-date-to ~
F-date-from F-sertif b-choose-sertif R-obj obj-list bt-sel-obj c-status ~
b-mark br-utd B-write-sertif 
&Scoped-Define DISPLAYED-OBJECTS F-date-to F-date-from F-sertif R-obj ~
obj-list c-status 

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
FUNCTION doc-type RETURNS CHARACTER
    ( input p-doc-code as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-sertif 
     LABEL "Выбор" 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON B-refresh 
    LABEL "Обновить" 
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

DEFINE BUTTON b-utd 
     LABEL "&Просмотр":L 
     SIZE 10 BY 1.

DEFINE BUTTON B-write-sertif 
     LABEL "Подписать и отправить" 
     SIZE 27 BY 1.
     
DEFINE BUTTON b-errors 
   LABEL "Ошибки/проблемы" 
   SIZE 16 BY 1.
   
DEFINE BUTTON b-comment 
   LABEL "Комментарий" 
   SIZE 16 BY 1.   

DEFINE BUTTON bt-not-sel-all 
     LABEL "+" 
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
     LABEL "-" 
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-sel-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.6 BY 1.05.
     
define button b-trn-doc
  label "Первичный документ"
  size 19 by 1 .    

DEFINE VARIABLE c-status AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     LABEL "Статус" 
     VIEW-AS COMBO-BOX INNER-LINES 11
     LIST-ITEM-PAIRS "Все","0"
     DROP-DOWN-LIST
     SIZE 55.6 BY 1 NO-UNDO.

/*DEFINE VARIABLE rs-filt      AS INTEGER*/
/*    VIEW-AS RADIO-SET HORIZONTAL       */
/*    RADIO-BUTTONS                      */
/*    "Все", 0,                          */
/*    "В работе", 1                      */
/*    SIZE 25 BY 1.25 NO-UNDO.           */

DEFINE VARIABLE F-date-from AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 10.8 BY 1 NO-UNDO.

DEFINE VARIABLE F-date-to AS DATE FORMAT "99/99/9999":U 
     LABEL "За период с" 
     VIEW-AS FILL-IN 
     SIZE 10.8 BY 1 NO-UNDO.

DEFINE VARIABLE F-sertif AS CHARACTER FORMAT "X(256)":U 
     LABEL "Сертификат" 
     VIEW-AS FILL-IN 
     SIZE 41.2 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE obj-list AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 18.4 BY 1 NO-UNDO.

DEFINE VARIABLE R-obj AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 18.6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-utd FOR 
      X_utd SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-utd d-utd _STRUCTURED
  QUERY br-utd NO-LOCK DISPLAY
      mark-string(recid(X_utd), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
      X_utd.DocumentNumber COLUMN-LABEL "Номер!документа" FORMAT "x(16)":U
      doc-type(X_utd.doc-code) COLUMN-LABEL "Тип" FORMAT "X(15)":U
      X_utd.DocumentDate COLUMN-LABEL "Дата документа" FORMAT "99/99/9999":U
      X_utd.stts COLUMN-LABEL "Статус ТН" FORMAT "X(44)":U
      X_utd.LoadDate COLUMN-LABEL "Дата загрузки" FORMAT "99/99/9999":U
      X_utd.DocumentExt COLUMN-LABEL "ID документа" FORMAT "x(50)":U
            WIDTH 40.6
  enable
      X_utd.DocumentExt          
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 14.95 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-utd
     b-exit AT ROW 1 COL 1.6
     b-utd AT ROW 1 COL 12 WIDGET-ID 230
     b-trn-doc at row 1 col 22.4
     B-refresh AT ROW 1 COL 100 WIDGET-ID 286
     b-print AT ROW 1 COL 126.2 WIDGET-ID 62
     b-errors at row 1 col 110
     b-hist AT ROW 1 COL 129 WIDGET-ID 64
     F-date-to AT ROW 2.29 COL 13.6 COLON-ALIGNED WIDGET-ID 238
     F-date-from AT ROW 2.29 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     F-sertif AT ROW 2.29 COL 78.6 COLON-ALIGNED WIDGET-ID 232 NO-TAB-STOP 
     b-choose-sertif AT ROW 2.29 COL 121.8 WIDGET-ID 234
     R-obj AT ROW 3.52 COL 11.6 NO-LABEL WIDGET-ID 290
     obj-list AT ROW 3.52 COL 47.4 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
     bt-sel-obj AT ROW 3.52 COL 48.4 WIDGET-ID 28
     c-status AT ROW 3.52 COL 74 COLON-ALIGNED WIDGET-ID 228
     bt-not-sel-all AT ROW 4.76 COL 2.6 WIDGET-ID 10 NO-TAB-STOP 
     bt-not-sel-desel-all AT ROW 4.76 COL 5.6 WIDGET-ID 12 NO-TAB-STOP 
     b-mark AT ROW 4.76 COL 8.6 WIDGET-ID 4 NO-TAB-STOP 
/*     rs-filt AT ROW 4.6 COL 14 widget-id 40 no-label*/
     br-utd AT ROW 6.05 COL 1.6
     B-write-sertif AT ROW 21.5 COL 2 WIDGET-ID 236
     b-comment at row 21.5 col 30 WIDGET-ID 220
     "Объекты:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 3.71 COL 2.6 WIDGET-ID 296
     "по" VIEW-AS TEXT
          SIZE 2.6 BY .67 AT ROW 2.48 COL 27 WIDGET-ID 38
     SPACE(102.99) SKIP(19.84)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список документов Вывода из оборота (ОСУ)":L.


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
       FRAME d-utd:SCROLLABLE       = FALSE.

ASSIGN 
       br-utd:COLUMN-RESIZABLE IN FRAME d-utd       = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME d-utd
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME d-utd
   NO-ENABLE                                                            */
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
"X_utd.DocumentExt" "ID документа" ? "character" ? ? ? ? ? ? no ? no no "13.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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
ON GO OF FRAME d-utd /* Список документов Вывода из оборота (ОСУ) */
DO:
/*    p-rid-list = v-rid-list.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-errors
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-errors d-utd
ON CHOOSE OF b-errors IN FRAME d-utd /* Ошибки */
DO:
  if available X_utd
  then do :
    run ref/dialog-error.w (input X_utd.db-num, input X_utd.doc-id, input "" , input 0) .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-comment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-comment d-utd
ON CHOOSE OF b-comment IN FRAME d-utd /* Ошибки */
DO:
  if available X_utd
  then do :
    row_utd = rowid (X_utd) .
    run str/LK_RECEIPT-comment.w (input X_utd.db-num, input X_utd.doc-id) .
    run init-sort in this-procedure .
    {&OPEN-QUERY-br-utd} 
    br-utd:refresh ().
    reposition br-utd to rowid row_utd no-error .
    apply "value-changed" to br-utd IN FRAME {&frame-name}.
  end .
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

    F-sertif = v-sertif_num .
    if f-sertif <> "" then 
    do:
      enable B-write-sertif with frame {&frame-name} .
    end.
    else 
    do:
      disable B-write-sertif with frame {&frame-name} .
    end.  
    display
        F-sertif
        with frame {&frame-name} .  
/*Подключение по сертификату*/

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
  end.  
  v-current-sort-string = c-status .
  v-current-sertif-string = v-sertif_num.
  run uf-set(
      input {&uf-LK_RECEIPT}
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


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-utd
ON choose OF b-hist IN FRAME d-utd /* История */
DO:
  define variable v-rid-list_ as character no-undo.
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
        input-output v-rid-list_ ) .
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
  end.
  apply "entry" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-trn-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-trn-doc d-utd
ON choose OF b-trn-doc IN FRAME d-utd /* Просмотр */
DO:
  define variable g-log as logical no-undo.
  if available (x_utd) then 
  do:
    find first trn-doc where trn-doc.doc-code = x_utd.doc-code no-lock no-error.
    if not available trn-doc then do:
      message "Не найден документ для просмотра" view-as alert-box.
      return no-apply .
    end.

    case trn-doc.doc-type
    :
      when {&income}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_income_lookup':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      when {&expense}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_lookup':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      when {&write-off}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_write-off_lookup':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      when {&inventory}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_inventory_lookup':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      when {&return}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_return_lookup':U
          {&cntxt-object}
          trn-doc.host-code
          trn-doc.obj-type
          trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      otherwise do:
        message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" skip
         "Тип документа" trn-doc.doc-type skip
         "Код документа" trn-doc.doc-code skip
         view-as alert-box error .
        undo, return no-apply .
      end.
    end case .

    if not g-log then return no-apply.
    row_utd = rowid (X_utd) .
    find doc-line where doc-line.doc-code  = trn-doc.doc-code no-lock no-error.
    
    run str/trn-lkp.p (parparentproc, recid(trn-doc), recid(doc-line)).  
    
    reposition br-utd to rowid row_utd no-error .
  end.      
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
    apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
/*        { gbl/chk-actg.i          */
/*          v-cntxt-db-num          */
/*          v-cntxt-userid          */
/*          {&action-head-code-main}*/
/*          'actn_edi-doc_lookup':U */
/*          {&cntxt-firm}           */
/*          v-cntxt-host-code-obj   */
/*          '':U                    */
/*          0                       */
/*          0                       */
/*          0                       */
/*          0                       */
/*          true                    */
/*          log-res                 */
/*        }                         */
    log-res = yes .
    if log-res then 
    do:    

      row_utd = rowid (X_utd) .
      
      run str/upd_browse.w (input parparentproc,
            input x_utd.doc-id,
            input x_utd.db-num,
            input x_utd.EDocType,
            input {&lookup},
            input mDiadocConnection
      ) no-error .


    end.
    
    reposition br-utd to rowid row_utd no-error .
  end.
  else 
  do: 
    message "Не выбран УПД"
        view-as alert-box.  
    return no-apply .
  end.      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-write-sertif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-write-sertif d-utd
ON CHOOSE OF B-write-sertif IN FRAME d-utd /* Подписать и отправить */
DO:
  define variable Log-Res as logical no-undo.
  define variable oMotp as class ibs.th.bge.is_motp.is_motp no-undo .
  define variable vUUID as character no-undo .  
  
  define buffer buf_ext-system      for ub.ext-system .
  define buffer buf_ext-system-attr for ub.ext-system-attr .
  define buffer buf_trn-doc for ub.trn-doc . 
  
    
     
        /*Проверка прав */
  
/*        { gbl/chk-actg.i          */
/*          v-cntxt-db-num          */
/*          v-cntxt-userid          */
/*          {&action-head-code-main}*/
/*          'actn_edi-doc_close':U  */
/*          {&cntxt-firm}           */
/*          v-cntxt-host-code-obj   */
/*          '':U                    */
/*          0                       */
/*          0                       */
/*          0                       */
/*          0                       */
/*          true                    */
/*          log-res                 */
/*        }                         */
  log-res = yes .
  if log-res then 
  do:  
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
            return no-apply .
        end. 
        else return no-apply . 
    end.    
      
    oMotp = new is_motp(buf_ext-system.db-num, buf_ext-system.esys-id) .
    oMotp:isDebug = session:debug-alert .
    if oMotp:currToken = ""
    or oMotp:currToken = ?
    then do :
      vToken = oMotp:authorize(input f-sertif, input "SerialNumber") no-error .
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
          return no-apply . 
      end.
    end .
    else do :
      vToken = oMotp:currToken .
    end .
    if vToken > ""
    then do :
      if v-rid-list <> "" then 
      do:
        utd_ :
        do ii = 1 to num-entries (v-rid-list):
          recid_utd = integer(entry(ii,v-rid-list)) .
          find first x_utd where recid (x_utd) = recid_utd .
          if x_utd.sts <> StatusTH:LK_RECEIPT_New:KeyIntDB
          then next utd_ .
          if not can-find(buf_trn-doc no-lock where buf_trn-doc.doc-code = X_utd.doc-code)
          then next utd_ .
      
          vUUID = oMotp:SendDoc_LK_RECEIPT ( vToken,
                                             x_utd.db-num,
                                             x_utd.doc-id,
                                             f-sertif,
                                             "SerialNumber"
                                            )
          .
          
        end. 
        run init-sort in this-procedure .
        {&OPEN-QUERY-br-utd} 
        apply "value-changed" to br-utd IN FRAME {&frame-name}.
      end.   
      else 
      do:
        if available (X_utd) then 
        do:
          row_utd = rowid (X_utd) .
          find first x_utd where rowid (x_utd) = row_utd .
          if x_utd.sts <> StatusTH:LK_RECEIPT_New:KeyIntDB
          then do :
            message 'Возможно только для документов в статусе "Требует подписания"' view-as alert-box .
            return no-apply .
          end .
          if not can-find(buf_trn-doc no-lock where buf_trn-doc.doc-code = X_utd.doc-code)
          then do :
            message 'Первичный документ удален. Подписание и отправка документа невозможна.' view-as alert-box .
            return no-apply .
          end .
          vUUID = oMotp:SendDoc_LK_RECEIPT ( vToken,
                                             x_utd.db-num,
                                             x_utd.doc-id,
                                             f-sertif,
                                             "SerialNumber"
                                            )
          .
          if vUUID = ?
          or trim(vUUID) = ""
          then do :
            message oMotp:MSG view-as alert-box .
          end .
          else do :
            
          end .
          run init-sort in this-procedure .
          {&OPEN-QUERY-br-utd} 
          apply "value-changed" to br-utd IN FRAME {&frame-name}.
        end.  
      end.
    end .
    
    delete object oMotp.
  end.    
  v-rid-list = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd                                                              */
/*ON mouse-select-dblclick OF br-utd IN FRAME d-utd                                                                   */
/*DO:                                                                                                                 */
/*        if AVAILABLE (X_utd) then                                                                                   */
/*        do:                                                                                                         */
/*            if v-obj-active or X_utd.EDocType = EdocType:UTD:KeyIntDB or X_utd.EDocType = EdocType:UCD:KeyIntDB then*/
/*            do:                                                                                                     */
/*                apply "Choose" to b-update in frame {&frame-name}.                                                  */
/*            end.                                                                                                    */
/*            else                                                                                                    */
/*            do:                                                                                                     */
/*                apply "Choose" to b-utd in frame {&frame-name}.                                                     */
/*            end.                                                                                                    */
/*        end.                                                                                                        */
/*    END.                                                                                                            */
/*                                                                                                                    */
/*/* _UIB-CODE-BLOCK-END */                                                                                           */
/*&ANALYZE-RESUME                                                                                                     */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON ROW-DISPLAY OF br-utd IN FRAME d-utd
DO:
  define buffer buf_trn-doc for ub.trn-doc .
  if AVAILABLE (X_utd) then 
  do:      
    if not can-find(buf_trn-doc no-lock where buf_trn-doc.doc-code = X_utd.doc-code)
    then do :
      X_utd.DocumentNumber:fGCOLOR in browse br-utd = RED_COLOR.
    end .
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON value-changed OF br-utd IN FRAME d-utd
DO:
  if available x_utd
  then do :
    if x_utd.sts = StatusTH:LK_RECEIPT_New:KeyIntDB
    then do :
      if f-sertif > ""
      then do :
        enable b-write-sertif with frame {&frame-name} .
      end .
    end .
    else do :
      disable b-write-sertif with frame {&frame-name} .
    end .
    if x_utd.sts = StatusTH:LK_RECEIPT_Error:KeyIntDB
    or x_utd.sts = StatusTH:LK_RECEIPT_Signed:KeyIntDB
    or x_utd.sts = StatusTH:LK_RECEIPT_SentDelete:KeyIntDB
    or x_utd.sts = StatusTH:LK_RECEIPT_ConfirmedHand:KeyIntDB
    or x_utd.sts = StatusTH:LK_RECEIPT_DeleteHand:KeyIntDB
    then do :
      enable b-comment with frame {&frame-name} .
    end .
    else do :
      disable b-comment with frame {&frame-name} .
    end .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-utd
ON CHOOSE OF b-print IN FRAME d-utd /* + */
DO:
  define variable loc#log as logical no-undo .
  define buffer bf_utd for ub.utd .
  define variable v-rec-list as character no-undo .
  v-rec-list = "" .

  if v-rid-list > ""
  then do :
    do ii = 1 to num-entries (v-rid-list):
      recid_utd = integer(entry(ii,v-rid-list)) .
      find first X_utd where recid (x_utd) = recid_utd .
      find first bf_utd no-lock where bf_utd.db-num = X_utd.db-num
                                  and bf_utd.doc-id = X_utd.doc-id
                                  no-error .
      if available bf_utd
      then do :
        v-rec-list = v-rec-list + string(rowid(bf_utd)) + "," .
      end .
    end .
  end .
  else do :
    if available X_utd 
    then do:
      find first bf_utd no-lock where bf_utd.db-num = X_utd.db-num
                                  and bf_utd.doc-id = X_utd.doc-id
                                  no-error .
      if available bf_utd
      then do :
        v-rec-list = string(rowid(bf_utd)) .
      end .
    end.
  end .
  v-rec-list = trim(v-rec-list, ",") .
  if v-rec-list > ""
  then do :
    run rep/LK_RECEIPT-print.p (input parparentproc,
                                input v-rec-list) .
  end .
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status d-utd
ON VALUE-CHANGED OF c-status IN FRAME d-utd /* Статус */
DO:
  assign c-status .
  run init-sort .
  {&OPEN-QUERY-br-utd}
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME rs-filt                       */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-filt d-utd*/
/*ON VALUE-CHANGED OF rs-filt IN FRAME d-utd /* Статус */*/
/*DO:                                                    */
/*  assign rs-filt .                                     */
/*  run init-sort .                                      */
/*  {&OPEN-QUERY-br-utd}                                 */
/*                                                       */
/*END.                                                   */
/*                                                       */
/*/* _UIB-CODE-BLOCK-END */                              */
/*&ANALYZE-RESUME                                        */

&Scoped-define SELF-NAME F-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from d-utd
ON RETURN OF F-date-from IN FRAME d-utd
DO:
  apply "TAB":U to self .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME F-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from d-utd
ON leave OF F-date-from IN FRAME d-utd
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
ON leave OF F-date-to IN FRAME d-utd /* За период с */
DO:
  if string(F-date-to) <> F-date-to:screen-value then 
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
  apply "value-changed" to br-utd IN FRAME {&frame-name}.
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
      input {&uf-LK_RECEIPT}
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

  StatusTH = ObjSrv:Env:Utd:Sts:TH.
  EdocType = ObjSrv:Env:Utd:EDocType.      

  F-date-to = today - 8.
  F-date-from = today - 1 .

  if v-current-sertif-string <> "" then 
  do:
      F-sertif = v-current-sertif-string .
  end.  
  
  run init-temp in this-procedure .
  { gbl/diasize.i }
  run diasize_init in this-procedure .
  run enable_UI in this-procedure .
  apply "value-changed" to br-utd IN FRAME {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name} .
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
    X_utd.DocumentExt:column-read-only in browse br-utd = yes .
    
    if p-mode = "" then 
    do:
        ENABLE
            br-utd
            b-exit
            R-obj
            b-utd
            b-trn-doc
            b-errors
            b-hist
            b-print
            c-status
/*            rs-filt*/
            b-refresh
            F-date-from
            F-date-to
            b-mark
            bt-not-sel-all
            bt-not-sel-desel-all
            WITH FRAME {&frame-name}.
        display
            B-write-sertif
            F-sertif
            F-date-from
            F-date-to
            with frame {&frame-name} .
        enable
            b-choose-sertif
            with frame {&frame-name} .   
    end.
    if p-mode = {&select} then 
    do:
        ENABLE
            b-mark
            bt-not-sel-all 
            br-utd
            b-exit
            bt-not-sel-desel-all
            R-obj
            c-status
/*            rs-filt*/
            F-date-from
            F-date-to
            WITH FRAME {&frame-name}.
        display     F-date-from
            F-date-to
            with frame {&frame-name} .
        disable
            b-hist
            b-refresh
            b-print
            B-write-sertif
            F-sertif
            b-choose-sertif
            with frame {&frame-name} .    
    end.  
    if v-current-sertif-string <> "" then 
    do:
        v-sertif_num =  v-current-sertif-string .
        F-sertif = v-sertif_num .
        if f-sertif <> "" then 
        do:
            enable       B-write-sertif with frame {&frame-name} .
        end.
        else 
        do:
            disable       B-write-sertif with frame {&frame-name} .
        end.  
        display
            F-sertif
            with frame {&frame-name} .  
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
    find first x_utd no-lock no-error .
    if AVAILABLE (X_utd) then empty temp-table X_utd .
  
    define variable mQuery as handle    no-undo.
    define variable vqry   as character no-undo.
    create query mQuery.
    mQuery:set-buffers(buffer buf_utd:HANDLE).
  
    
    vqry = substitute("FOR EACH buf_utd where buf_utd.EDocType = &1 and buf_utd.host-code = &2 and buf_utd.DocumentDate >= &3 and buf_utd.DocumentDate <= &4 no-lock" , EdocType:LK_RECEIPT:KeyIntDB, v-cntxt-host-code-obj, f-date-to, f-date-from).
    mQuery:query-prepare(vqry).
    mQuery:query-open ().
    mQuery:get-first ().
                                                                         
    /*  FOR EACH buf_utd NO-LOCK where buf_utd.host-code = v-cntxt-host-code-obj and buf_utd.DocumentDate >= f-date-to and buf_utd.DocumentDate <= f-date-from :*/
    do while not mQuery:query-off-end:
      create X_utd .
      buffer-copy buf_utd to X_utd . 
      X_utd.stts = StatusTHName(X_utd.sts).
      X_utd.cli-name = CliName(X_utd.cli-code, X_utd.cli-type).
      X_utd.EdoTypeName = EdoTypeName(X_utd.EDocType).
      X_utd.GrayZone = no .
      X_utd.obj-name = buf_utd.obj-type + " " + string(buf_utd.obj-code) .
      mQuery:get-next ().
    end.
    delete object mQuery.
    find first tt-obj-list no-error .
    if available (tt-obj-list) then 
    do:
      for each X_utd:
        p-ok = false .
        obj-list_ :
        for each tt-obj-list:
          if X_utd.obj-code = tt-obj-list.obj-code
          and X_utd.obj-type = tt-obj-list.obj-type
          then do :
            p-ok = true.
            leave obj-list_ .
          end .
        end.
        if p-ok <> true then delete X_utd .  
      end.  
    end.
    if c-status <> "-1"
    then do:
      if c-status = "0"
      then do :
        for each X_utd where X_utd.sts <> StatusTH:LK_RECEIPT_New:KeyIntDB
                         and X_utd.sts <> StatusTH:LK_RECEIPT_Error:KeyIntDB
                         and X_utd.sts <> StatusTH:LK_RECEIPT_SentDelete:KeyIntDB
                         and X_utd.sts <> StatusTH:LK_RECEIPT_Signed:KeyIntDB
        :
          delete X_utd .
        end.
      end .
      else do :
        for each X_utd where X_utd.sts <> integer(c-status):
          delete X_utd .
        end.  
      end .
    end.    
/*    if rs-filt = 1                                                             */
/*    then do :                                                                  */
/*      for each X_utd where X_utd.sts <> StatusTH:LK_RECEIPT_New:KeyIntDB       */
/*                       and X_utd.sts <> StatusTH:LK_RECEIPT_Error:KeyIntDB     */
/*                       and X_utd.sts <> StatusTH:LK_RECEIPT_SentDelete:KeyIntDB*/
/*                       and X_utd.sts <> StatusTH:LK_RECEIPT_Signed:KeyIntDB    */
/*      :                                                                        */
/*        delete X_utd .                                                         */
/*      end.                                                                     */
/*    end .                                                                      */
    
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

    Status_ = "Все" + {&comma-char} + '-1':U + {&comma-char}
            + "В работе" + {&comma-char} + '0':U .

    do ii = 1 to StatusTH:mapType:GetItemByLab(ii):
        if StatusTH:CurrProp:KeyIntDB >= 50
        and StatusTH:CurrProp:KeyIntDB < 60
        then do : /* Вывод из оборота */
          Status_ = Status_ + {&comma-char} + StatusTH:CurrProp:Label_ + {&comma-char} + string(StatusTH:CurrProp:KeyIntDB) .
        end .
    end.

    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_ .

    c-status = "0" .
/*    rs-filt = 1 .*/
    display c-status with frame {&frame-name} .
  
    run proc-Token .
    run init-sort .
    {&OPEN-QUERY-br-utd}
    apply "value-changed" to br-utd IN FRAME {&frame-name}.
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

    if oMotp:currToken = ""
    or oMotp:currToken = ?
    then do :
    
        if f-sertif <> ? and f-sertif <> "" then 
        do:
  
          vToken = oMotp:authorize(input f-sertif, input "SerialNumber") no-error .
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
              message "Ошибка авторизации в ГИС МТ." skip oMotp:MSG view-as alert-box .  
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
      
    end .   
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION doc-type d-utd 
FUNCTION doc-type RETURNS CHARACTER
    ( input p-doc-code as character ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
  define buffer bf_trn-doc for ub.trn-doc .
  for first bf_trn-doc no-lock where bf_trn-doc.doc-code = p-doc-code :
    case bf_trn-doc.ext-doc-type :
      when {&TDEDT_Spi_Prvo} then return "Производство" .
      when {&TDEDT_Inv} then return "Инвентаризация" .
      when {&TDEDT_Spi_Vnesh} then return "Списание" .
      otherwise do :
        return "?" .
      end .
    end case .
  end .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

