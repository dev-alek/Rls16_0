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

Идентификаторы EasyFuel2

Автор: Сливенко Сергей Андреевич
Дата создания: 25/09/12
Author: Slivenko Sergey
Creation date: 25/09/12

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
define variable vss-description as character no-undo init "Идентификаторы EasyFuel2".
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
{ ref/dc-efdf2.i }
{ gbl/usrfulnf.i }
define variable is-ef-chr as character no-undo .
define variable par-type as character no-undo .
define variable v-init-mode as logical no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
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
&Scoped-define FIELDS-IN-QUERY-br-ef1 temp-ef1.rfn-code temp-ef1.limit temp-ef1.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ef1 temp-ef1.rfn-code temp-ef1.limit temp-ef1.status_
&Scoped-define ENABLED-TABLES-IN-QUERY-br-ef1 temp-ef1
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-ef1 temp-ef1
&Scoped-define SELF-NAME br-ef1
&Scoped-define QUERY-STRING-br-ef1 FOR EACH temp-ef1 BY temp-ef1.rfn-code
&Scoped-define OPEN-QUERY-br-ef1 OPEN QUERY {&SELF-NAME} FOR EACH temp-ef1 BY temp-ef1.rfn-code.
&Scoped-define TABLES-IN-QUERY-br-ef1 temp-ef1
&Scoped-define FIRST-TABLE-IN-QUERY-br-ef1 temp-ef1


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ef1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-card b-cli  ~
B-Help f-car-brand f-car-reg-number ~
br-ef1
&Scoped-Define DISPLAYED-OBJECTS f-car-brand f-car-reg-number

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 17 BY 1.

DEFINE BUTTON b-card
     LABEL "Карта"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     LABEL "Клиент"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 17 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-car-brand AS CHARACTER FORMAT "X(256)":U
     LABEL "Марка ТС"
     VIEW-AS FILL-IN
     SIZE 26 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-car-reg-number AS CHARACTER FORMAT "X(10)":U
     LABEL "Гос.рег.знак"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ef1 FOR
      temp-ef1 SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ef1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ef1 Dialog-Frame _FREEFORM
  QUERY br-ef1 DISPLAY
      temp-ef1.rfn-code COLUMN-LABEL "Номер RFN" format "X(16)"
 temp-ef1.limit COLUMN-LABEL "Максимальный!Объем"
 temp-ef1.status_ COLUMN-LABEL "Метка!активна" view-as toggle-box
 ENABLE
 temp-ef1.rfn-code
 temp-ef1.limit
 temp-ef1.status_
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 12.8 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-card AT ROW 1 COL 21 WIDGET-ID 36
     b-cli AT ROW 1 COL 31 WIDGET-ID 38
     B-Help AT ROW 1 COL 41 WIDGET-ID 120
     f-car-brand AT ROW 2.33 COL 14 COLON-ALIGNED
     f-car-reg-number AT ROW 3.93 COL 14 COLON-ALIGNED
     b-add AT ROW 5.27 COL 1 WIDGET-ID 28
     b-del AT ROW 5.27 COL 18 WIDGET-ID 46
     br-ef1 AT ROW 6.33 COL 1 WIDGET-ID 100
     /*SPACE(51.09) SKIP(14.59)*/
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Идентификаторы EasyFuel2"
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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить лимиты */
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


  CREATE buf_temp-ef1.
  ASSIGN
    buf_temp-ef1.name = "easyfuel2-rfn"
    buf_temp-ef1.new_ = yes
    buf_temp-ef1.d-card = p-d-card
  .

  buf_temp-ef1.rfn-code = "0".
  assign
  v-recid = recid(buf_temp-ef1)
  .
  {&open-query-br-ef1}
  reposition  br-ef1 to recid v-recid no-error .
  apply "ENTRY" to temp-ef1.rfn-code in browse br-ef1.


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


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить лимиты */
DO:
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
define buffer del_ext-classif for ub.ext-classif.
  IF NOT AVAILABLE temp-ef1 THEN RETURN NO-APPLY.
  FIND FIRST buf_temp-ef1 WHERE recid(buf_temp-ef1) = RECID(temp-ef1).
  FIND FIRST del_ext-classif NO-LOCK WHERE
            del_ext-classif.classif-subject = buf_temp-ef1.d-card
        AND del_ext-classif.classif-name = buf_temp-ef1.name
        AND del_ext-classif.CharKey_One  = buf_temp-ef1.rfn-code NO-ERROR.
  IF AVAILABLE del_ext-classif THEN DO:
      MESSAGE
      "Нельзя удалить существующие лимиты"
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
  END.
  DELETE buf_temp-ef1.
  {&open-query-br-ef1}
  reposition  br-ef1 to ROW 1 no-error .
  /*apply "ENTRY" to temp-ef1.rfn-code in browse br-ef1.*/
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


&Scoped-define BROWSE-NAME br-ef1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */


ON LEAVE OF
temp-ef1.rfn-code IN BROWSE br-ef1,
temp-ef1.limit in BROWSE br-ef1,
temp-ef1.status_ in BROWSE br-ef1 do:
define buffer buf_temp-ef1 for temp-ef1.

find first buf_temp-ef1 where recid(buf_temp-ef1) = recid(temp-ef1).
assign
buf_temp-ef1.rfn-code = (temp-ef1.rfn-code:screen-value in browse br-ef1)
buf_temp-ef1.limit = decimal(temp-ef1.limit:screen-value in browse br-ef1)
buf_temp-ef1.status_ = logical(temp-ef1.status_:screen-value in browse br-ef1)
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
    IF NOT (buf_Dis-card-type.card-media = integer({&dc-cm-ef2})) THEN DO:
      MESSAGE
      "Данное свойство можно задать ТОЛЬКО для карты типа EasyFuel2"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  FOR EACH temp-ef1:
    DELETE temp-ef1.
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
  DISPLAY f-car-brand f-car-reg-number
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-card b-cli B-Help f-car-brand
         f-car-reg-number
         b-add b-del br-ef1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
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
.


IF p-mode = {&add-def} THEN DO:
END.
DISPLAY
f-car-brand
f-car-reg-number
WITH FRAME {&frame-name}.

open query br-ef1 for each temp-ef1.

IF p-mode = {&LOOKUP} THEN DO:
    ASSIGN
    temp-ef1.rfn-code:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.status_:READ-ONLY in BROWSE br-ef1 = YES    .
END.
/*if p-dtm-code = {&dc-prop_easyfuel2-rfn} then do:
  temp-ef1.rfn-code:READ-ONLY in BROWSE br-ef1 = YES.
end. */
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-car-reg-number WHEN (p-mode <> {&LOOKUP} and p-dtm-code = {&dc-prop_easyfuel2})
f-car-brand WHEN (p-mode <> {&LOOKUP} and p-dtm-code = {&dc-prop_easyfuel2})
b-add WHEN p-mode <> {&LOOKUP}
b-del WHEN p-mode <> {&LOOKUP}
br-ef1
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
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
if p-dtm-code = {&dc-prop_easyfuel2} then do:
  ASSIGN
  FRAME {&FRAME-NAME}
  f-car-brand
  f-car-reg-number
  .
end.
/*проверим лимиты*/
FOR EACH buf_temp-ef1 :
   IF buf_temp-ef1.limit = 0
   THEN DO:
     MESSAGE
     substitute("Не заполнен разрешенный максимальный объем топлива для RFN с кодом &1", buf_temp-ef1.rfn-code)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
   END.
end.
FOR EACH buf_temp-ef1 :
   FIND FIRST buf_ext-classif WHERE
              buf_ext-classif.classif-subject =  p-d-card
          AND buf_ext-classif.classif-name    =  buf_temp-ef1.name
          AND buf_ext-classif.CharKey_One     =  buf_temp-ef1.rfn-code NO-ERROR.
   IF NOT AVAILABLE buf_ext-classif THEN DO:
    CREATE buf_ext-classif.
    ASSIGN
      buf_ext-classif.classif-subject = p-d-card
      buf_ext-classif.classif-name    = buf_temp-ef1.name
      buf_ext-classif.CharKey_One     = buf_temp-ef1.rfn-code
      buf_ext-classif.CharKey_Two     = string(buf_temp-ef1.limit)
      buf_ext-classif.CharKey_Three   = string(buf_temp-ef1.status_)
      buf_ext-classif.db-num          = 0
    .
   END.
   else do :
     ASSIGN
      buf_ext-classif.CharKey_Two     = string(buf_temp-ef1.limit)
      buf_ext-classif.CharKey_Three   = string(buf_temp-ef1.status_)
      buf_ext-classif.db-num          = 0
    .
   end.
END.
if p-dtm-code = {&dc-prop_easyfuel2} then do:
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
    CASE temp-dis-card-property.node-code :
      WHEN {&dc_prop_easyfuel_car-reg-number} THEN DO:
        temp-dis-card-property.property-value-character = f-car-reg-number.
      END.
      WHEN {&dc_prop_easyfuel_car-brand} THEN DO:
        temp-dis-card-property.property-value-character = f-car-brand.
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
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.

disable triggers for load of ub.ext-classif.

FOR EACH buf_temp-ef1 WHERE
       buf_temp-ef1.d-card = p-d-card
    and buf_temp-ef1.NEW_ = YES,
    EACH buf_ext-classif WHERE
        buf_ext-classif.CharKey_One = buf_temp-ef1.rfn-code:
   DELETE buf_ext-classif.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */