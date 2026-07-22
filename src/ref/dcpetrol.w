&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Топливо для ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

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
define variable vss-description as character no-undo init "Топливо для ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ ref/dc-prop.i }
{ gbl/getcntxt.i DEF }
{ ref/temp-dcp.i }
define variable is-elved-chr as character no-undo .
define variable par-type as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-gds B-cdpay ~
rs-account-type f-car-brand f-car-reg-number rs-limit-type f-limit ~
f-limit-l f-quota RS-quota-period
&Scoped-Define DISPLAYED-OBJECTS f-gds-code f-gds-name f-cdpay-code ~
f-cdpay-name rs-account-type f-car-brand f-car-reg-number rs-limit-type ~
f-limit f-limit-l f-quota RS-quota-period

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cdpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

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
     SIZE 40 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-car-reg-number AS CHARACTER FORMAT "X(40)":U
     LABEL "Гос.рег.знак"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdpay-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Тип касс. пл-жа"
     VIEW-AS FILL-IN NATIVE
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdpay-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 62.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код товара"
     VIEW-AS FILL-IN NATIVE
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-gds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 62.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-limit AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Лимит кредита по данному топливу (сумма)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-limit-l AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Лимит кредита по данному топливу (кол-во)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-quota AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Квота на топливо за период времени"
     VIEW-AS FILL-IN
     SIZE 21 BY 1.07 NO-UNDO.

DEFINE VARIABLE rs-account-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Безлимитный бензиновый", 7,
"Безлимитный денежный", 6,
"Лимитный бензиновый", 5,
"Неопределено", 0
     SIZE 34.5 BY 5 NO-UNDO.

DEFINE VARIABLE rs-limit-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Лимит в валюте продаж", "sum",
"Лимит по кол-ву топлива", "qnty"
     SIZE 40.5 BY 2.13 NO-UNDO.

DEFINE VARIABLE RS-quota-period AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Месяц", "month",
"День", "day"
     SIZE 27 BY 1.77 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-gds-code AT ROW 2.5 COL 19 COLON-ALIGNED
     f-gds-name AT ROW 2.5 COL 35 COLON-ALIGNED NO-LABEL
     B-gds AT ROW 2.6 COL 32.5
     B-cdpay AT ROW 3.67 COL 32.5 WIDGET-ID 2
     f-cdpay-code AT ROW 3.77 COL 19 COLON-ALIGNED
     f-cdpay-name AT ROW 3.77 COL 35 COLON-ALIGNED NO-LABEL
     rs-account-type AT ROW 5.5 COL 63.5 NO-LABEL
     f-car-brand AT ROW 5.77 COL 19 COLON-ALIGNED
     f-car-reg-number AT ROW 7.33 COL 19 COLON-ALIGNED
     rs-limit-type AT ROW 8.5 COL 21 NO-LABEL
     f-limit AT ROW 11 COL 46.5 COLON-ALIGNED
     f-limit-l AT ROW 12.5 COL 46.5 COLON-ALIGNED
     f-quota AT ROW 14 COL 38 COLON-ALIGNED
     RS-quota-period AT ROW 14 COL 71 NO-LABEL
     SPACE(1.69) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Топливо по ДК"
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-cdpay-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-cdpay-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-cdpay-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-cdpay-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-gds-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-gds-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-gds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-gds-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Топливо по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cdpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cdpay Dialog-Frame
ON CHOOSE OF B-cdpay IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE variable v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
IF f-cdpay-code <> 0 THEN DO:
   FIND FIRST buf_cash-pay NO-LOCK WHERE
             buf_cash-pay.cdpay-code = f-cdpay-code
       AND buf_cash-pay.curr-code = 0 NO-ERROR.
   IF AVAILABLE buf_cash-pay THEN DO:
       ASSIGN
           v-rid-list = STRING(RECID(buf_cash-pay)).
   END.
END.

run ref/cashpays.w ( INPUT parparentproc
                    ,INPUT "b-sel"
                    ,input {&all}
                    ,INPUT v-cntxt-host-code-obj
                     ,INPUT v-cntxt-obj-type
                     ,INPUT v-cntxt-obj-code
                     ,OUTPUT v-rid-list) NO-ERROR.
IF NOT ERROR-STATUS:ERROR THEN DO:
  FIND FIRST buf_cash-pay NO-LOCK WHERE
            recid(buf_cash-pay) = INTEGER(v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-cdpay-code = buf_cash-pay.cdpay-code
  f-cdpay-name = buf_cash-pay.obj-name
  .
END.
DISPLAY
f-cdpay-code
f-cdpay-name
WITH FRAME {&FRAME-NAME}.
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


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE variable v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
   run ref/petrlref.p ( INPUT parparentproc
                  ,INPUT "b-sel"
                  ,OUTPUT v-rid-list ) NO-ERROR.
IF NOT ERROR-STATUS:ERROR THEN DO:
  FIND FIRST buf_goods NO-LOCK WHERE
            recid(buf_goods) = INTEGER(v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-gds-code = buf_goods.gds-code
  f-gds-name = buf_goods.gds-name
  .
END.
DISPLAY
f-gds-code
f-gds-name
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-limit-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-limit-type Dialog-Frame
ON VALUE-CHANGED OF rs-limit-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-limit-type.
  CASE rs-limit-type:
      WHEN "sum" THEN DO:
        DISPLAY
        f-limit
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        f-limit when p-mode <> {&lookup}
        WITH FRAME {&FRAME-NAME}.
        HIDE
        f-limit-l
        IN FRAME {&FRAME-NAME}.
      END.
      WHEN "qnty" THEN DO:
        DISPLAY
        f-limit-l
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        f-limit-l when p-mode <> {&lookup}
        WITH FRAME {&FRAME-NAME}.
        HIDE
        f-limit
        IN FRAME {&FRAME-NAME}.
      END.

  END CASE.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
  IF p-mode <> {&add-def}
  AND p-mode <> {&UPDATE}
  AND p-mode <> {&lookup} THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  /*проверим конф параметр is-elved*/
  { gbl/conf-rd.i
  "'is-elved'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  is-elved-chr
  par-type
  no-error
  }
  if error-status:error
  or logical(is-elved-chr) = no then do:
    message
    "В Вашей конфигурации нельзя работать с этим свойством ДК," skip
    "так как не включен конфигурационный параметр is-elved"
    view-as alert-box .
    undo, return error .
  end.

  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code.
  find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = p-dtm-code
      and buf_prop-ref.dt-code = p-dt-code.
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
  DISPLAY f-gds-code f-gds-name f-cdpay-code f-cdpay-name rs-account-type
          f-car-brand f-car-reg-number rs-limit-type f-limit f-limit-l f-quota
          RS-quota-period
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-gds B-cdpay rs-account-type f-car-brand
         f-car-reg-number rs-limit-type f-limit f-limit-l f-quota
         RS-quota-period
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
IF p-sum-id <> "":U THEN DO:
  FIND FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = integer(substring(p-sum-id, LENGTH("petrol-") + 1)) NO-ERROR.
  IF AVAILABLE buf_goods THEN DO:
     ASSIGN
     f-gds-code = buf_goods.gds-code
     f-gds-name = buf_goods.gds-name
     .
  END.
END.
FOR EACH temp-dis-card-property where
       temp-dis-card-property.dtm-code = p-dtm-code
    and temp-dis-card-property.sum-id = p-sum-id:
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_dc-petrol_car-reg-number} THEN DO:
       f-car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_dc-petrol_car-brand} THEN DO:
        f-car-brand = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_dc-petrol_limit-type} THEN DO:
        rs-limit-type = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_dc-petrol_sum-limit} THEN DO:
        f-limit = temp-dis-card-property.property-value-decimal.
     END.
     WHEN {&dc_prop_dc-petrol_qnty-limit} THEN DO:
        f-limit-l = temp-dis-card-property.property-value-decimal.
     END.
     WHEN {&dc_prop_dc-petrol_quota-period} THEN DO:
        rs-quota-period = temp-dis-card-property.property-value-character.
     END.
     WHEN {&dc_prop_dc-petrol_quota} THEN DO:
       f-quota = temp-dis-card-property.property-value-decimal.
     END.
     WHEN {&dc_prop_dc-petrol_account-type} THEN DO:
       IF p-mode = {&add-def}
       AND p-sum-id = 'petrol-':U     THEN DO:
         temp-dis-card-property.property-value-integer = 6.
       END.
       rs-account-type = temp-dis-card-property.property-value-integer.
     END.
     WHEN {&dc_prop_dc-petrol_cdpay-code} THEN DO:
       FIND FIRST buf_cash-pay NO-LOCK WHERE
                   buf_cash-pay.cdpay-code = temp-dis-card-property.property-value-integer
               and buf_cash-pay.curr-code = 0 NO-ERROR.
        IF AVAILABLE buf_cash-pay THEN DO:
            ASSIGN
            f-cdpay-code = buf_cash-pay.cdpay-code
            f-cdpay-name = buf_cash-pay.obj-name
            .
        END.
    END. /*WHEN {&dc_prop_dc-petrol_cdpay-code} THEN DO:*/
  END CASE.
END.

IF p-mode = {&add-def} THEN DO:
  ASSIGN
  rs-limit-type = "sum".
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
  IF buf_dis-card-type.dflt-debet-card  THEN DO:
    IF buf_dis-card-type.pay-code > 0  THEN DO:
      FIND FIRST buf_cash-pay NO-LOCK WHERE
            buf_cash-pay.cdpay-code = buf_dis-card-type.pay-code
          AND buf_cash-pay.curr-code = 0 NO-ERROR.
      IF AVAILABLE buf_cash-pay THEN DO:
          ASSIGN
          f-cdpay-code = buf_cash-pay.cdpay-code
          f-cdpay-name = buf_cash-pay.obj-name
          .
      END. /*IF AVAILABLE buf_cash-pay THEN DO:*/
    END. /*IF buf_dis-card-type.pay-code > 0  THEN DO:*/
  END. /*IF buf_dis-card-type.dflt-debet-card  THEN DO:*/
END.
DISPLAY
f-gds-code
f-gds-name
f-cdpay-code
f-cdpay-name
f-car-brand
f-car-reg-number
rs-limit-type
f-limit
f-limit-l
rs-quota-period
f-quota
rs-account-type
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-car-reg-number WHEN p-mode <> {&LOOKUP}
f-car-brand WHEN p-mode <> {&LOOKUP}
f-limit WHEN p-mode <> {&LOOKUP}
f-limit-l WHEN p-mode <> {&LOOKUP}
rs-limit-type WHEN p-mode <> {&LOOKUP}
f-quota WHEN p-mode <> {&LOOKUP}
rs-account-type WHEN p-mode <> {&LOOKUP}
rs-quota-period WHEN p-mode <> {&LOOKUP}
b-cdpay WHEN p-mode <> {&LOOKUP}
WITH FRAME {&frame-name}.
rs-account-type:disable(radio-label(string(0), RS-account-type:radio-buttons)).
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
APPLY "VALUE-CHANGED" to rs-limit-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
ASSIGN
FRAME {&FRAME-NAME}
rs-limit-type
f-gds-code
f-car-brand
f-car-reg-number
f-limit
f-limit-l
rs-quota-period
f-quota
rs-account-type
.
IF rs-account-type <> 6
AND p-sum-id = 'petrol-':U     THEN do:
  MESSAGE
  substitute("Если огрaничения вида топлива нет, то можно выбрать только &1"
             ,radio-label ( INPUT STRING(6)
                            ,INPUT rs-account-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME})
             )
  VIEW-AS ALERT-BOX ERROR.
UNDO, RETURN ERROR.

END.
IF rs-account-type = 6
AND p-sum-id <> 'petrol-':U     THEN do:
  MESSAGE
  substitute("Если есть ограничения вида топлива, то нельзя выбрать &1"
             ,radio-label ( INPUT STRING(6)
                            ,INPUT rs-account-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME})
             )
  VIEW-AS ALERT-BOX ERROR.
UNDO, RETURN ERROR.

END.
IF f-limit = ?
or f-limit-l = ?
OR f-quota = ?
/*OR (f-limit = 0 and rs-limit-type = "sum")
OR (f-limit-l = 0 and rs-limit-type = "qnty")
OR f-quota = 0
*/
THEN DO:
  MESSAGE
  "Не задано значение лимита и/или квоты по топливу"
  view-as ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
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
    temp-dis-card-property.data-type = buf_prop-map.node-value-type
    .
  END.
END.
FOR EACH temp-dis-card-property
   where temp-dis-card-property.d-card = p-d-card
and temp-dis-card-property.dtm-code = p-dtm-code
and temp-dis-card-property.dt-code = p-dt-code
   :
   CASE temp-dis-card-property.node-code:
     WHEN {&dc_prop_dc-petrol_car-reg-number} THEN DO:
       temp-dis-card-property.property-value-character = f-car-reg-number.
     END.
     WHEN {&dc_prop_dc-petrol_car-brand} THEN DO:
       temp-dis-card-property.property-value-character = f-car-brand.
     END.
     WHEN {&dc_prop_dc-petrol_limit-type} THEN DO:
        temp-dis-card-property.property-value-character = rs-limit-type.
     END.
     WHEN {&dc_prop_dc-petrol_sum-limit} THEN DO:
        temp-dis-card-property.property-value-decimal = f-limit .
     END.
     WHEN {&dc_prop_dc-petrol_qnty-limit} THEN DO:
        temp-dis-card-property.property-value-decimal = f-limit-l .
     END.
     WHEN {&dc_prop_dc-petrol_quota-period} THEN DO:
        temp-dis-card-property.property-value-character = rs-quota-period .
     END.
     WHEN {&dc_prop_dc-petrol_quota} THEN DO:
       temp-dis-card-property.property-value-decimal = f-quota .
     END.
     WHEN {&dc_prop_dc-petrol_account-type} THEN DO:
       temp-dis-card-property.property-value-integer = rs-account-type .
     END.
     WHEN {&dc_prop_dc-petrol_cdpay-code} THEN DO:
         temp-dis-card-property.property-value-integer = f-cdpay-code.
    END.
  END CASE.
END.
ASSIGN
p-setted = YES
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

