&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Лимиты EasyFuel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-sum-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dt-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-emitent-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-d-card AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
{ ref/temp-dcp.i DEF }
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR temp-dis-card-property.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Лимиты EasyFuel".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ ref/dc-prop.i }
{ gbl/key-rec.i }
{ ref/extclass.i }
{ rul/propreft.i }
{ gbl/getcntxt.i DEF }
{ ref/temp-dcp.i }
define stream stmxmlout .
{ str/cd-xml.i }
{ ref/dc-efdf.i }
{ gbl/usrfulnf.i }
define variable is-ef-chr as character no-undo .
define variable par-type as character no-undo .
define variable v-init-mode as logical no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE VARIABLE v-petrol-code AS INTEGER NO-UNDO EXTENT 4.
&scop name-label "Название!топлива"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ef1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-ef1

/* Definitions for BROWSE br-ef1                                        */
&Scoped-define FIELDS-IN-QUERY-br-ef1 temp-ef1.petrol-num temp-ef1.petrol-code temp-ef1.ef-petrol-code get-gds-name(temp-ef1.petrol-code) temp-ef1.standard-dose temp-ef1.day-limit temp-ef1.unlim-day-limit temp-ef1.month-limit temp-ef1.unlim-month-limit temp-ef1.common-limit temp-ef1.unlim-common-limit   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ef1 temp-ef1.petrol-num temp-ef1.standard-dose temp-ef1.day-limit temp-ef1.month-limit temp-ef1.common-limit temp-ef1.unlim-day-limit temp-ef1.unlim-month-limit temp-ef1.unlim-common-limit   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-ef1 temp-ef1
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-ef1 temp-ef1
&Scoped-define SELF-NAME br-ef1
&Scoped-define QUERY-STRING-br-ef1 FOR EACH temp-ef1 BY temp-ef1.petrol-code
&Scoped-define OPEN-QUERY-br-ef1 OPEN QUERY {&SELF-NAME} FOR EACH temp-ef1 BY temp-ef1.petrol-code.
&Scoped-define TABLES-IN-QUERY-br-ef1 temp-ef1
&Scoped-define FIRST-TABLE-IN-QUERY-br-ef1 temp-ef1


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ef1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-card b-cli b-initialize ~
B-Help f-car-brand f-access-key f-car-reg-number rs-ef-format ~
f-init-date-time b-add-limits b-del-limits br-ef1 l-ef-format 
&Scoped-Define DISPLAYED-OBJECTS f-car-brand f-access-key f-car-reg-number ~
rs-ef-format f-init-date-time f-issued-by-name f-init-operator-name ~
l-ef-format 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame 
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add-limits 
     LABEL "Добавить лимиты" 
     SIZE 17 BY 1.

DEFINE BUTTON b-card 
     LABEL "Карта" 
     SIZE 10 BY 1.

DEFINE BUTTON b-cli 
     LABEL "Клиент" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del-limits 
     LABEL "Удалить лимиты" 
     SIZE 17 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-initialize AUTO-GO 
     LABEL "Инициализация МБ" 
     SIZE 20 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-access-key AS CHARACTER FORMAT "X(8)":U 
     LABEL "Ключ доступа" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-brand AS CHARACTER FORMAT "X(256)":U 
     LABEL "Марка ТС" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-car-reg-number AS CHARACTER FORMAT "X(10)":U 
     LABEL "Гос.рег.знак" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-init-date-time AS CHARACTER FORMAT "X(19)":U 
     LABEL "Дата и время прошивки" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE f-init-operator-name AS CHARACTER FORMAT "X(20)":U 
     LABEL "Инициализировал" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE f-issued-by-name AS CHARACTER FORMAT "X(20)":U 
     LABEL "Выдал" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE l-ef-format AS CHARACTER FORMAT "X(256)":U INITIAL "Формат данных на МБ" 
      VIEW-AS TEXT 
     SIZE 20 BY .67 NO-UNDO.

DEFINE VARIABLE rs-ef-format AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "1", 1,
"2", 2
     SIZE 7 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ef1 FOR 
      temp-ef1 SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ef1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ef1 Dialog-Frame _FREEFORM
  QUERY br-ef1 DISPLAY
      temp-ef1.petrol-num COLUMN-LABEL "№ топ.!на МБ" format "9"
 temp-ef1.petrol-code COLUMN-LABEL "Код!топлива!(IBS TH)"
 temp-ef1.ef-petrol-code COLUMN-LABEL "Код!топлива!EasyFuel"
 get-gds-name(temp-ef1.petrol-code) COLUMN-LABEL {&name-label} FORMAT "X(10)"
 temp-ef1.standard-dose COLUMN-LABEL "Стандартная!доза" FORMAT ">>,>>9"
 temp-ef1.day-limit   COLUMN-LABEL "Дневной!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-day-limit COLUMN-LABEL  "Дневн!лимит!неогран" label-font 4 view-as toggle-box
 temp-ef1.month-limit COLUMN-LABEL  "Месячный!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-month-limit COLUMN-LABEL  "Месячн!лимит!неогран" label-font 4 view-as toggle-box
 temp-ef1.common-limit COLUMN-LABEL "Общий!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-common-limit COLUMN-LABEL  "Общий!лимит!неогран" label-font 4 view-as toggle-box
 ENABLE
 temp-ef1.petrol-num
 temp-ef1.standard-dose
 temp-ef1.day-limit
 temp-ef1.month-limit
 temp-ef1.common-limit
 temp-ef1.unlim-day-limit
 temp-ef1.unlim-month-limit
 temp-ef1.unlim-common-limit
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.8 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-card AT ROW 1 COL 38 WIDGET-ID 36
     b-cli AT ROW 1 COL 48 WIDGET-ID 38
     b-initialize AT ROW 1 COL 58 WIDGET-ID 34
     B-Help AT ROW 1 COL 95
     f-car-brand AT ROW 2.33 COL 14 COLON-ALIGNED
     f-access-key AT ROW 2.33 COL 76 COLON-ALIGNED WIDGET-ID 30 PASSWORD-FIELD 
     f-car-reg-number AT ROW 3.93 COL 14 COLON-ALIGNED
     rs-ef-format AT ROW 3.93 COL 48 NO-LABEL WIDGET-ID 22
     f-init-date-time AT ROW 3.93 COL 76.5 COLON-ALIGNED WIDGET-ID 32
     b-add-limits AT ROW 5.27 COL 1 WIDGET-ID 28
     b-del-limits AT ROW 5.27 COL 18 WIDGET-ID 46
     f-issued-by-name AT ROW 5.27 COL 41 COLON-ALIGNED WIDGET-ID 44
     f-init-operator-name AT ROW 5.27 COL 77.5 COLON-ALIGNED WIDGET-ID 42
     br-ef1 AT ROW 6.33 COL 1 WIDGET-ID 100
     l-ef-format AT ROW 3.93 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     SPACE(51.09) SKIP(14.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Идентификаторы и лимиты EasyFuel"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_dis-card B "?" ? ub dis-card
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ef1 f-init-operator-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       f-access-key:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-init-operator-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-issued-by-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ef1
/* Query rebuild information for BROWSE br-ef1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-ef1 BY temp-ef1.petrol-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-ef1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Идентификаторы и лимиты EasyFuel */
DO:
  RUN undo-proc IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Идентификаторы и лимиты EasyFuel */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-limits
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-limits Dialog-Frame
ON CHOOSE OF b-add-limits IN FRAME Dialog-Frame /* Добавить лимиты */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define VARIABLE v-tbl-row    as rowid     no-undo.
  define variable v-tbl-name   as character no-undo.
  define variable v-sum-id   as character no-undo.
  DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
  define variable v-recid as recid no-undo .
  DEFINE BUFFER buf_goods FOR ub.goods.
  DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
  DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
  DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
  /*
  run ref/gds-ef.w ( INPUT parparentproc
                    ,INPUT "b-sel"
                    ,INPUT "" /*list-mode*/
                    ,OUTPUT v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  FIND FIRST buf_Ext-classif NO-LOCK WHERE
            recid(buf_ext-classif) = INTEGER(v-rid-list).
run gen-row-keyr  IN THIS-PROCEDURE (
  input  buf_ext-classif.uniq-key-rec
  ,input  ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
  ,INPUT "ub"
  ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,INPUT no-lock
  ,OUTPUT v-tbl-row
  ,OUTPUT v-tbl-name).
  FIND FIRST buf_goods NO-LOCK WHERE
            rowid(buf_goods) = v-tbl-row.
  FIND FIRST buf_temp-ef1 NO-LOCK WHERE
            buf_temp-ef1.sum-id = STRING(buf_goods.gds-code)
        and buf_temp-ef1.d-card = p-d-card
            NO-ERROR.
  IF AVAILABLE buf_temp-ef1 THEN DO:
      MESSAGE
      "Для данного МБ уже определены лимиты на данное топливо"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  v-sum-id = propreft-petrol-to-string(buf_goods.gds-code).
  */
  run ref/proprefs.w (
                    input parparentproc
                  ,input 'b-sel'
                  ,input "dtm-code"
                  ,input STRING({&dc-prop_easyfuel-limits})
                  ,input '':U
                  ,input buf_Dis-card-type.uniq-key-rec
                  ,input-output  v-rid-list) no-error.
    find first buf_prop-ref no-lock where
              recid(buf_prop-ref) = integer(v-rid-list) no-error .
    if not available buf_prop-ref then return no-apply.
  FIND FIRST buf_temp-ef1 NO-LOCK WHERE
           buf_temp-ef1.d-card = p-d-card
        and buf_temp-ef1.sum-id = buf_prop-ref.sum-id NO-ERROR.
  IF AVAILABLE buf_temp-ef1 THEN DO:
      MESSAGE
      "Для данного МБ уже определены лимиты на данное топливо"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  CREATE buf_temp-ef1.
  ASSIGN
  buf_temp-ef1.sum-id = buf_prop-ref.sum-id
  buf_temp-ef1.dt-code = buf_prop-ref.dt-code
  buf_temp-ef1.dtm-code = buf_prop-ref.dtm-code
  buf_temp-ef1.new_ = yes
  buf_temp-ef1.d-card = p-d-card
  .
  v-gds-code = propreft-string-to-petrol(buf_prop-ref.sum-id).
  ASSIGN
  buf_temp-ef1.petrol-code = v-gds-code
  .
  ASSIGN
  buf_temp-ef1.ef-petrol-code = get-ef-petrol-code( buf_temp-ef1.petrol-code)
  buf_temp-ef1.petrol-num = 0
  v-recid = recid(buf_temp-ef1)
  .
  {&open-query-br-ef1}
  reposition  br-ef1 to recid v-recid no-error .
  apply "ENTRY" to temp-ef1.petrol-num in browse br-ef1.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-card Dialog-Frame
ON CHOOSE OF b-card IN FRAME Dialog-Frame /* Карта */
DO:
DEFINE VARIABLE v-ri AS RECID NO-UNDO.
  IF AVAILABLE X_dis-card THEN DO:
      v-ri = RECID(X_dis-card).
      run ref/dcardi.w ( INPUT parparentproc
                        ,INPUT {&LOOKUP}
                        ,INPUT X_dis-card.emitent-host-code
                        ,INPUT v-cntxt-host-code-obj
                        ,INPUT v-cntxt-obj-type
                        ,INPUT v-cntxt-obj-code
                        ,INPUT ? /*cli-ri*/
                        ,INPUT-OUTPUT v-ri) NO-ERROR.
     IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Клиент */
DO:
  IF AVAILABLE X_clients THEN DO:
      run ref/showcli.p (
       input parParentProc
      ,input X_clients.obj-type /* p-obj-type */
      ,input X_clients.obj-code /* p-obj-code */
      ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-limits
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-limits Dialog-Frame
ON CHOOSE OF b-del-limits IN FRAME Dialog-Frame /* Удалить лимиты */
DO:
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER del_dis-card-property FOR ub.dis-card-property.
  IF NOT AVAILABLE temp-ef1 THEN RETURN NO-APPLY.
  FIND FIRST buf_temp-ef1 WHERE recid(buf_temp-ef1) = RECID(temp-ef1).
  FIND FIRST del_dis-card-property NO-LOCK WHERE
            DEL_dis-card-property.d-card = buf_temp-ef1.d-card
       AND  DEL_dis-card-property.dt-code = buf_temp-ef1.dt-code
      AND DEL_dis-card-property.host-code = 0
      AND DEL_dis-card-property.obj-type = ""
      AND DEL_dis-card-property.obj-code = 0 NO-ERROR.
  IF AVAILABLE DEL_dis-card-property THEN DO:
      MESSAGE
      "Нельзя удалить существующие лимиты"
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
  END.
  DELETE buf_temp-ef1.
  {&open-query-br-ef1}
  reposition  br-ef1 to ROW 1 no-error .
  apply "ENTRY" to temp-ef1.petrol-num in browse br-ef1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-initialize
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-initialize Dialog-Frame
ON CHOOSE OF b-initialize IN FRAME Dialog-Frame /* Инициализация МБ */
DO:
 ASSIGN
 p-setted = YES
 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ef1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

on value-changed of
temp-ef1.unlim-day-limit in browse br-ef1 do:
define variable old-unlim-day-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-day-limit = temp-ef1.unlim-day-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-day-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.day-limit = ?
    buf_temp-ef1.unlim-day-limit = yes
    .
    temp-ef1.day-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.day-limit = ? then
    assign
    buf_temp-ef1.day-limit = 0
    .
    buf_temp-ef1.unlim-day-limit = no.

    temp-ef1.day-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.day-limit
temp-ef1.unlim-day-limit
with browse br-ef1.
end.

on value-changed of
temp-ef1.unlim-month-limit in browse br-ef1 do:
define variable old-unlim-month-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-month-limit = temp-ef1.unlim-month-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-month-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.month-limit = ?
    buf_temp-ef1.unlim-month-limit = yes
    .
    temp-ef1.month-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.month-limit = ? then
    assign
    buf_temp-ef1.month-limit = 0
    .
    buf_temp-ef1.unlim-month-limit = no.
    temp-ef1.month-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.month-limit
temp-ef1.unlim-month-limit
with browse br-ef1.
end.

on value-changed of
temp-ef1.unlim-common-limit in browse br-ef1 do:
define variable old-unlim-common-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-common-limit = temp-ef1.unlim-common-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-common-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.common-limit = ?
    buf_temp-ef1.unlim-common-limit = yes
    .
    temp-ef1.common-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.common-limit = ? then
    assign
    buf_temp-ef1.common-limit = 0
    .
    buf_temp-ef1.unlim-month-limit = no.
    temp-ef1.common-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.common-limit
temp-ef1.unlim-common-limit
with browse br-ef1.
end.

ON LEAVE OF
temp-ef1.petrol-num IN BROWSE br-ef1,
temp-ef1.month-limit in BROWSE br-ef1,
temp-ef1.day-limit in BROWSE br-ef1,
temp-ef1.standard-dose in BROWSE br-ef1,
temp-ef1.common-limit in BROWSE br-ef1 do:
define variable old-petrol-num as integer no-undo .
define variable old-month-limit as decimal no-undo .
define variable old-day-limit as decimal no-undo .
define variable old-standard-dose as decimal no-undo .
define variable old-common-limit as decimal no-undo .
define variable v-petrol-num as integer no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-petrol-num = temp-ef1.petrol-num
old-month-limit = temp-ef1.month-limit
old-day-limit = temp-ef1.day-limit
old-standard-dose = temp-ef1.standard-dose
old-common-limit = temp-ef1.common-limit
.
assign
v-petrol-num = integer(temp-ef1.petrol-num:screen-value in browse br-ef1)
.
if v-petrol-num > 4 then do:
  message
  "№ топлива на МБ EasyFuel не может быть больше 4!"
  view-as alert-box error .
  assign
  temp-ef1.petrol-num:screen-value in browse br-ef1 = string(old-petrol-num)
  .
  return no-apply.
end.
find first buf_temp-ef1 where
         buf_temp-ef1.d-card = p-d-card
      and buf_temp-ef1.petrol-num = v-petrol-num
      and v-petrol-num > 0
      and recid(buf_temp-ef1) <> recid(temp-ef1) no-error.
if available buf_temp-ef1 then do:
  message
  "Уже есть такой № топлива на МБ EasyFuel!"
  view-as alert-box error .
  assign
  temp-ef1.petrol-num:screen-value = string(old-petrol-num)
  .
  return no-apply.
end.
if decimal(temp-ef1.month-limit:screen-value in browse br-ef1) > 1000000 then do:
  message
  "Месячный лимит не может превышать 1000000"
  view-as alert-box error.
  assign
  temp-ef1.month-limi:screen-value = string(old-month-limit)
  .
  return no-apply.
end.
if decimal(temp-ef1.day-limit:screen-value in browse br-ef1) > 32000 then do:
  message
  "Дневной лимит не может превышать 32000"
  view-as alert-box error.
  assign
  temp-ef1.day-limit:screen-value = string(old-day-limit)
  .
  return no-apply.
end.
if decimal(temp-ef1.standard-dose:screen-value in browse br-ef1) > 32000 then do:
  message
  "Стандартная доза не может превышать 32000"
  view-as alert-box error.
  assign
  temp-ef1.standard-dose:screen-value = string(old-standard-dose)
  .
  return no-apply.
end.
if decimal(temp-ef1.common-limit:screen-value in browse br-ef1) > 1000000 then do:
  message
  "Общий лимит не может превышать 1000000"
  view-as alert-box error.
  assign
  temp-ef1.common-limi:screen-value = string(old-common-limit)
  .
  return no-apply.
end.

find first buf_temp-ef1 where recid(buf_temp-ef1) = recid(temp-ef1).
assign
buf_temp-ef1.petrol-num = integer(temp-ef1.petrol-num:screen-value in browse br-ef1)
buf_temp-ef1.month-limit = decimal(temp-ef1.month-limit:screen-value in browse br-ef1)
buf_temp-ef1.day-limit = decimal(temp-ef1.day-limit:screen-value in browse br-ef1)
buf_temp-ef1.standard-dose = decimal(temp-ef1.standard-dose:screen-value in browse br-ef1)
buf_temp-ef1.common-limit = decimal(temp-ef1.common-limit:screen-value in browse br-ef1)
.
END.

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
    FIND FIRST buf_Dis-card-type NO-LOCK WHERE
          buf_dis-card-type.emitent-host-code = p-emitent-host-code
      AND   buf_dis-card-type.TYPE = p-type
    AND buf_dis-card-type.host-code = 0
    AND buf_Dis-card-type.obj-type = '':U
    AND buf_Dis-card-type.obj-code = 0 NO-ERROR.
    IF NOT AVAILABLE buf_dis-card-type THEN DO:
      MESSAGE
      "Не определен тип ДК" SKIP
        "Невозможно задать свойство"
        VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END. /*IF NOT AVAILABLE buf_dis-card-type THEN DO:*/
    IF NOT (buf_Dis-card-type.card-media = integer({&dc-cm-ef})) THEN DO:
      MESSAGE
      "Данное свойство можно задать ТОЛЬКО для карты типа EASY-FUEL"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
 FOR EACH temp-ef1:
    DELETE temp-ef1.
  END.
  FOR EACH temp-ef2:
    DELETE temp-ef2.
  END.
  IF p-mode <> {&add-def}
  AND p-mode <> {&UPDATE}
  AND p-mode <> {&lookup}
  and p-mode <> {&lookup} + {&comma-char} + "init"
  THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  assign
  v-init-mode = (if num-entries(p-mode) > 1
                 and entry(2, p-mode) = "init"
                 then yes
                 else no)
  p-mode = entry(1, p-mode)
  .
  /*проверим конф параметр is-ef*/
  { gbl/conf-rd.i
  "'is-ef'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  is-ef-chr
  par-type
  no-error
  }
  if error-status:error
  or logical(is-ef-chr) = no then do:
    message
    "В Вашей конфигурации нельзя работать с этим свойством ДК," skip
    "так как не включен конфигурационный параметр is-ef"
    view-as alert-box .
    undo, return error .
  end.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code.
  find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = p-dtm-code
      and buf_prop-ref.dt-code = p-dt-code.

  case p-dtm-code:
    when {&dc-prop_easyfuel} then do:
    end.
    when {&dc-prop_easyfuel-limits} then do:
    end.
  end case.
  FIND FIRST X_dis-card NO-LOCK WHERE
            X_dis-card.d-card = p-d-card NO-ERROR.
  IF AVAILABLE X_dis-card THEN DO:
      FIND FIRST X_clients NO-LOCK WHERE
                X_clients.obj-type = X_dis-card.cli-type
           AND X_clients.obj-code = X_dis-card.cli-code NO-ERROR.
  END.
  RUN Myenable IN THIS-PROCEDURE.
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
  DISPLAY f-car-brand f-access-key f-car-reg-number rs-ef-format 
          f-init-date-time f-issued-by-name f-init-operator-name l-ef-format 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-card b-cli b-initialize B-Help f-car-brand 
         f-access-key f-car-reg-number rs-ef-format f-init-date-time 
         b-add-limits b-del-limits br-ef1 l-ef-format 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generate-access-key Dialog-Frame 
PROCEDURE generate-access-key :
DEFINE output PARAMETER p-access-key AS CHARACTER NO-UNDO.
SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
{ gbl/pencrypt.i p-d-card p-access-key }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-ef for temp-ef.
find first buf_Dis-card no-lock where
          buf_Dis-card.d-card = p-d-card no-error.
run fill-main-table in this-procedure ( input p-d-card, buffer buf_dis-card) no-error.
if error-status:error then do:
  undo, return error .
end.
find first buf_temp-ef.
assign
f-car-reg-number = buf_temp-ef.car-reg-number
f-car-brand = buf_temp-ef.car-brand
rs-ef-format = buf_temp-ef.ef-format
f-access-key = buf_temp-ef.access-key
v-petrol-code[1]= buf_temp-ef.petrol-code-1
v-petrol-code[2]= buf_temp-ef.petrol-code-2
v-petrol-code[3]= buf_temp-ef.petrol-code-3
v-petrol-code[4]= buf_temp-ef.petrol-code-4
f-init-date-time =  buf_temp-ef.init-date-time
f-init-operator-name = usrfulnf(buf_temp-ef.init-operator)
f-issued-by-name = usrfulnf(buf_temp-ef.issued-by)
.
IF f-access-key = ""
OR trim(f-access-key, "*") = ""
   THEN DO:
 RUN  generate-access-key IN THIS-PROCEDURE ( OUTPUT f-access-key) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     "Ошибка при генерации кода доступа"
     VIEW-AS ALERT-BOX ERROR.
     RUN undo-proc IN THIS-PROCEDURE .
     UNDO, RETURN ERROR.
 END.
END.
ASSIGN
v-h = br-ef1:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&name-label} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.


IF p-mode = {&add-def} THEN DO:
END.
DISPLAY
f-car-brand
f-car-reg-number
rs-ef-format
l-ef-format
f-access-key
f-init-date-time
f-init-operator-name
f-issued-by-name
WITH FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    ASSIGN
    temp-ef1.petrol-num:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.month-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.day-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-common-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-month-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-day-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.standard-dose:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.common-limit:READ-ONLY in BROWSE br-ef1 = YES
    .
END.
if p-dtm-code = {&dc-prop_easyfuel-limits} then do:
  temp-ef1.petrol-num:READ-ONLY in BROWSE br-ef1 = YES.
end.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-car-reg-number WHEN (p-mode <> {&LOOKUP} and p-dtm-code = {&dc-prop_easyfuel})
f-car-brand WHEN (p-mode <> {&LOOKUP} and p-dtm-code = {&dc-prop_easyfuel})
/*rs-ef-format WHEN (p-mode = {&add-def} and p-dtm-code = {&dc-prop_easyfuel} )*/
b-add-limits WHEN p-mode <> {&LOOKUP}
b-del-limits WHEN p-mode <> {&LOOKUP}
br-ef1
b-initialize WHEN (v-init-mode and p-dtm-code = {&dc-prop_easyfuel})
b-card WHEN AVAILABLE X_dis-card
b-cli WHEN AVAILABLE X_dis-card
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP}  THEN DO:
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  .
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
END.
CASE rs-ef-format:
  WHEN 1  THEN DO:
     {&OPEN-QUERY-br-ef1}
    define buffer buf_temp-ef1 for temp-ef1 .
    if p-dtm-code = {&dc-prop_easyfuel-limits} then do:
      find first buf_temp-ef1 where
                buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.dt-code = p-dt-code.
      reposition br-ef1 to recid recid(buf_temp-ef1) no-error.
      apply "ENTRY" to br-ef1.
      case p-node-code:
        when {&dc_prop_easyfuel-limits_month-limit} then do:
          apply "ENTRY" to temp-ef1.month-limit in browse br-ef1.
        end.
        when {&dc_prop_easyfuel-limits_day-limit} then do:
          apply "ENTRY" to temp-ef1.day-limit in browse br-ef1.
        end.
        when {&dc_prop_easyfuel-limits_standard-dose} then do:
          apply "ENTRY" to temp-ef1.standard-dose in browse br-ef1.
        end.
        when {&dc_prop_easyfuel-limits_common-limit} then do:
          apply "ENTRY" to temp-ef1.common-limit in browse br-ef1.
        end.
        otherwise do:
          apply "ENTRY" to br-ef1.
        end.
      end case.
    end.
    apply "value-changed" to temp-ef1.unlim-day-limit in browse br-ef1.
    apply "value-changed" to temp-ef1.unlim-month-limit in browse br-ef1.
    apply "value-changed" to temp-ef1.unlim-common-limit in browse br-ef1.
  END.
END CASE.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = SUBSTITUTE("&1 для &2 ",  FRAME {&FRAME-NAME}:TITLE, p-d-card).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
DEFINE BUFFER bufl_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
if p-dtm-code = {&dc-prop_easyfuel} then do:
  ASSIGN
  FRAME {&FRAME-NAME}
  f-car-brand
  f-car-reg-number
  rs-ef-format
  .
end.
/*проверим лимиты*/
FOR EACH buf_temp-ef1:
  FOR FIRST bufl_prop-head no-lock WHERE
            bufl_prop-head.dtm-code = {&dc-prop_easyfuel-limits},
        EACH buf_prop-map NO-LOCK WHERE
            buf_prop-map.dtm-code = bufl_prop-head.dtm-code
         and buf_prop-map.node-code > 0:
   IF buf_temp-ef1.month-limit = 0
   OR buf_temp-ef1.day-limit = 0
   OR buf_temp-ef1.standard-dose = 0
   or buf_temp-ef1.common-limit = 0
   THEN DO:
     MESSAGE
     substitute("Не заполнены лимиты для топлива с кодом &1", buf_temp-ef1.petrol-code)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
   END.
   if buf_temp-ef1.petrol-num > 0 then do:
     if get-ef-petrol-code(buf_temp-ef1.petrol-code) = 0 then do:
      MESSAGE
      substitute("Неопределен код топлива EASYFUEL для кода топлива IBS TH &1", buf_temp-ef1.petrol-code)
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
     end.
   end.
  end.
end.
FOR EACH buf_temp-ef1:
    FOR FIRST bufl_prop-head no-lock WHERE
            bufl_prop-head.dtm-code = {&dc-prop_easyfuel-limits},
        EACH buf_prop-map NO-LOCK WHERE
            buf_prop-map.dtm-code = bufl_prop-head.dtm-code
         and buf_prop-map.node-code > 0:
   FIND FIRST buf_temp-dis-card-property WHERE
            buf_temp-dis-card-property.d-card =  p-d-card
       AND buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code
       AND buf_temp-dis-card-property.host-code = p-host-code
       AND buf_temp-dis-card-property.obj-type = p-obj-type
       AND buf_temp-dis-card-property.obj-code = p-obj-code
       AND buf_temp-dis-card-property.obj-code = p-obj-code
       AND buf_temp-dis-card-property.node-code = buf_prop-map.node-code NO-ERROR.
   IF NOT AVAILABLE buf_temp-dis-card-property THEN DO:
      CREATE buf_temp-dis-card-property.
      ASSIGN
      buf_temp-dis-card-property.d-card =  p-d-card
      buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code
      buf_temp-dis-card-property.dtm-code = buf_temp-ef1.dtm-code
      buf_temp-dis-card-property.sum-id = buf_temp-ef1.sum-id
      buf_temp-dis-card-property.host-code = p-host-code
      buf_temp-dis-card-property.obj-type = p-obj-type
      buf_temp-dis-card-property.obj-code = p-obj-code
      buf_temp-dis-card-property.obj-code = p-obj-code
      buf_temp-dis-card-property.node-code = buf_prop-map.node-code
      buf_temp-dis-card-property.node-label = buf_prop-map.node-label
      buf_temp-dis-card-property.prop-label = bufl_prop-head.prop-label
      buf_temp-dis-card-property.data-type = entry(1, buf_prop-map.node-value-type)
      .
   END.
   IF VALID-HANDLE(BUFFER buf_temp-dis-card-property:BUFFER-FIELD(SUBSTITUTE("property-value-&1", entry(1, buf_prop-map.node-value-type))))
   AND VALID-HANDLE(BUFFER buf_temp-ef1:BUFFER-FIELD(buf_prop-map.node-name)) THEN DO:

       ASSIGN
       BUFFER buf_temp-dis-card-property:BUFFER-FIELD(SUBSTITUTE("property-value-&1", entry(1, buf_prop-map.node-value-type))):BUFFER-VALUE =
       BUFFER buf_temp-ef1:BUFFER-FIELD(buf_prop-map.node-name):BUFFER-VALUE.
   END.
   ELSE DO:
       MESSAGE
       SUBSTITUTE("Не могу сохранить поле temp-ef1.&1 в поле temp-dis-card-property.&1"
                  ,buf_prop-map.node-label)
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
   END.
    END.
END.
if p-dtm-code = {&dc-prop_easyfuel} then do:
  FOR EACH buf_prop-map NO-LOCK WHERE
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code > 0:
    FIND FIRST temp-dis-card-property WHERE
              temp-dis-card-property.d-card = p-d-card
        AND   temp-dis-card-property.dt-code = p-dt-code
        AND   temp-dis-card-property.node-code = buf_prop-map.node-code
        AND   temp-dis-card-property.host-code = p-host-code
        AND   temp-dis-card-property.obj-type = p-obj-type
        AND   temp-dis-card-property.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE temp-dis-card-property THEN DO:
      CREATE temp-dis-card-property.
      ASSIGN
      temp-dis-card-property.d-card = p-d-card
      temp-dis-card-property.dt-code = p-dt-code
      temp-dis-card-property.dtm-code = p-dtm-code
      temp-dis-card-property.sum-id = p-sum-id
      temp-dis-card-property.node-code = buf_prop-map.node-code
      temp-dis-card-property.host-code = p-host-code
      temp-dis-card-property.obj-type = p-obj-type
      temp-dis-card-property.obj-code = p-obj-code
      temp-dis-card-property.prop-label = buf_prop-head.prop-label
      temp-dis-card-property.node-label = buf_prop-map.node-label
      temp-dis-card-property.data-type = entry(1, buf_prop-map.node-value-type)
      .
    END.
  END.
  FOR EACH temp-dis-card-property
    where temp-dis-card-property.d-card = p-d-card
  and temp-dis-card-property.dtm-code = p-dtm-code
  and temp-dis-card-property.dt-code = p-dt-code
    :
    CASE temp-dis-card-property.node-code:
      WHEN {&dc_prop_easyfuel_car-reg-number} THEN DO:
        temp-dis-card-property.property-value-character = f-car-reg-number.
      END.
      WHEN {&dc_prop_easyfuel_car-brand} THEN DO:
        temp-dis-card-property.property-value-character = f-car-brand.
      END.
      WHEN {&dc_prop_easyfuel_ef-format} THEN DO:
        temp-dis-card-property.property-value-integer = rs-ef-format.
      END.
      WHEN {&dc_prop_easyfuel_access-key} THEN DO:
        temp-dis-card-property.property-value-character = f-access-key.
      END.
      WHEN {&dc_prop_easyfuel_init-date-time} THEN DO:
        /*
        сохраняется в другом месте
        */
      END.
      WHEN {&dc_prop_easyfuel_issued-by} THEN DO:
        temp-dis-card-property.property-value-character = v-cntxt-userid.
      END.
      WHEN {&dc_prop_easyfuel_petrol-code-1} THEN DO:
        FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                      buf_temp-ef1.d-card = p-d-card
                  and buf_temp-ef1.petrol-num = 1 NO-ERROR.
        IF AVAILABLE buf_temp-ef1 THEN DO:
          temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
        END.

      END.
    WHEN {&dc_prop_easyfuel_petrol-code-2} THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                    buf_temp-ef1.d-card = p-d-card
                and buf_temp-ef1.petrol-num = 2 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.

    END.
    WHEN {&dc_prop_easyfuel_petrol-code-3} THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                  buf_temp-ef1.d-card = p-d-card
               and  buf_temp-ef1.petrol-num = 3 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.

    END.
    WHEN {&dc_prop_easyfuel_petrol-code-4} THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                buf_temp-ef1.d-card = p-d-card
               and buf_temp-ef1.petrol-num = 4 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.
    END.
    END CASE.
  END.
end.
ASSIGN
p-setted = YES
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE undo-proc Dialog-Frame 
PROCEDURE undo-proc :
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.

FOR EACH buf_temp-ef1 WHERE
       buf_temp-ef1.d-card = p-d-card
    and buf_temp-ef1.NEW_ = YES,
    EACH buf_temp-dis-card-property WHERE
        buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code:
   DELETE buf_temp-dis-card-property.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame 
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER ) :
DEFINE buffer buf_goods FOR ub.goods.
FIND FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_goods THEN do:
  IF buf_goods.chk-name <> '' THEN RETURN buf_goods.chk-name.
  RETURN buf_goods.gds-name.
END.
RETURN "!!НЕИЗВЕСТНЫЙ ТОВАР".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

