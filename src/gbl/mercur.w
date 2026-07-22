&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Параметры для работы с ФГИС Меркурий

Автор: Чернова Светлана Александровна
Дата создания: 08/03/09
Author: Svetlana Chernova
Creation date: 08/03/09

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/onewin.i   }
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable v-to-create-trn-g as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .

assign
v-tth  = buffer thbjattr_thbj-attr:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 RECT-2 B-quit B-Help v-apikey ~
v-login v-password v-login-is v-manual-vcd v-close r-type-connect v-qrcode ~
cb-section v-proxy-addres v-proxy-login v-proxy-pswd v-proxy-ssl 
&Scoped-Define DISPLAYED-OBJECTS v-apikey v-login v-password v-login-is ~
v-manual-vcd v-close r-type-connect v-qrcode cb-section v-proxy-addres ~
v-proxy-login v-proxy-pswd v-proxy-ssl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-section AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
     LABEL "Сервер" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "тестовый","1",
                     "основной","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-apikey AS CHARACTER FORMAT "X(256)":U 
     LABEL "APIKey" 
     VIEW-AS FILL-IN 
     SIZE 97 BY 1 NO-UNDO.

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE v-login-is AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин входа в ИС" 
     VIEW-AS FILL-IN 
     SIZE 50.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE v-proxy-addres AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес прокси-сервера" 
     VIEW-AS FILL-IN 
     SIZE 52 BY 1 TOOLTIP "Адрес прокси-сервера в формате <IP>:<Port>" NO-UNDO.

DEFINE VARIABLE v-proxy-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-proxy-pswd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-qrcode AS CHARACTER FORMAT "X(256)":U 
     LABEL "Настройки для печати QR-кода" 
     VIEW-AS FILL-IN 
     SIZE 50.13 BY 1 NO-UNDO.

DEFINE VARIABLE r-type-connect AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Локально", 1,
"через ГБД", 2
     SIZE 30 BY 1.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 106.5 BY 3.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 106.5 BY 3.25.

DEFINE VARIABLE v-close AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE v-manual-vcd AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
     
DEFINE VARIABLE v-proxy-ssl AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.     


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88
     v-apikey AT ROW 3.04 COL 106 RIGHT-ALIGNED WIDGET-ID 2
     v-login AT ROW 4.25 COL 8 COLON-ALIGNED WIDGET-ID 4
     v-password AT ROW 4.25 COL 106 RIGHT-ALIGNED WIDGET-ID 6
     v-login-is AT ROW 6.75 COL 54.88 COLON-ALIGNED WIDGET-ID 22
     v-manual-vcd AT ROW 8.17 COL 57 WIDGET-ID 10
     v-close AT ROW 9.17 COL 57 WIDGET-ID 20
     r-type-connect AT ROW 9.92 COL 57 NO-LABEL WIDGET-ID 24
     v-qrcode AT ROW 11.17 COL 54.88 COLON-ALIGNED WIDGET-ID 8
     cb-section AT ROW 12.5 COL 54.88 COLON-ALIGNED WIDGET-ID 34
     v-proxy-addres AT ROW 15.25 COL 22.5 COLON-ALIGNED WIDGET-ID 42
     v-proxy-login AT ROW 16.5 COL 22.5 COLON-ALIGNED WIDGET-ID 44 PASSWORD-FIELD 
     v-proxy-pswd AT ROW 16.5 COL 54 COLON-ALIGNED WIDGET-ID 46 PASSWORD-FIELD
     v-proxy-ssl AT ROW 15.25 COL 89 COLON-ALIGNED WIDGET-ID 48 
     "Разрешено закрывать документ без указ. ВСД:" VIEW-AS TEXT
          SIZE 44.63 BY .92 AT ROW 9.08 COL 54.51 RIGHT-ALIGNED WIDGET-ID 18
     "Параметры подключения через Прокси-сервер:" VIEW-AS TEXT
          SIZE 43 BY .67 AT ROW 14.25 COL 35 WIDGET-ID 38
     "Разрешено вводить код ВСД вручную:" VIEW-AS TEXT
          SIZE 44.63 BY .92 AT ROW 8.08 COL 54.51 RIGHT-ALIGNED WIDGET-ID 12
     "Тип взаимодействия:" VIEW-AS TEXT
          SIZE 44.63 BY .92 AT ROW 10.04 COL 54.51 RIGHT-ALIGNED WIDGET-ID 28
     "  Параметры коннекта к ВЕТИС.API" VIEW-AS TEXT
          SIZE 32.5 BY .67 AT ROW 2 COL 37.5 WIDGET-ID 30
     "SSL прокси" VIEW-AS TEXT
          SIZE 10.63 BY .92 AT ROW 15.25 COL 88 RIGHT-ALIGNED WIDGET-ID 28     
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 36
     RECT-2 AT ROW 14.5 COL 1.5 WIDGET-ID 40
     SPACE(0.24) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры для работы с ФГИС Меркурий"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* SETTINGS FOR FILL-IN v-apikey IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN v-password IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR TEXT-LITERAL "Разрешено вводить код ВСД вручную:"
          SIZE 44.63 BY .92 AT ROW 8.08 COL 54.51 RIGHT-ALIGNED         */

/* SETTINGS FOR TEXT-LITERAL "Разрешено закрывать документ без указ. ВСД:"
          SIZE 44.63 BY .92 AT ROW 9.08 COL 54.51 RIGHT-ALIGNED         */

/* SETTINGS FOR TEXT-LITERAL "Тип взаимодействия:"
          SIZE 44.63 BY .92 AT ROW 10.04 COL 54.51 RIGHT-ALIGNED        */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Параметры для работы с ФГИС Меркурий */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры для работы с ФГИС Меркурий */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-section
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-section Dialog-Frame
ON VALUE-CHANGED OF cb-section IN FRAME Dialog-Frame /* Сервер */
DO:
  assign cb-section .
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
if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .
    run enable_UI.
    run init-tt.
    RUN fill-widgets.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY v-apikey v-login v-password v-login-is v-manual-vcd v-close 
          r-type-connect v-qrcode cb-section v-proxy-addres v-proxy-login 
          v-proxy-pswd v-proxy-ssl 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 RECT-2 B-quit B-Help v-apikey v-login v-password 
         v-login-is v-manual-vcd v-close r-type-connect v-qrcode cb-section 
         v-proxy-addres v-proxy-login v-proxy-pswd v-proxy-ssl 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

   assign
      v-tth = buffer temp-thbj-attr:table-handle
   .
   
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-mercur}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").

FOR EACH temp-thbj-attr
  :
    IF temp-thbj-attr.prop-code = {&attr-mercur_apikey} THEN DO:
       v-apikey = temp-thbj-attr.property-value-character.
       display v-apikey with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_login} THEN DO:
       v-login = temp-thbj-attr.property-value-character.
       display v-login with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_password} THEN DO:
       v-password = temp-thbj-attr.property-value-character.
       display v-password with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_qrcode} THEN DO:
       v-qrcode = temp-thbj-attr.property-value-character.
       display v-qrcode with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_close} THEN DO:
       v-close = temp-thbj-attr.property-value-logical.
       display v-close with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_manual-vcd} THEN DO:
       v-manual-vcd = temp-thbj-attr.property-value-logical.
       display v-manual-vcd with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_login_is} THEN DO:
       v-login-is = temp-thbj-attr.property-value-character.
       display v-login-is with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_type-connect} THEN DO:
       r-type-connect = temp-thbj-attr.property-value-integer .
       if r-type-connect = ? then r-type-connect = 1 .
       display r-type-connect with frame {&frame-name} .
    END.    
    IF temp-thbj-attr.prop-code = {&attr-mercur_server} THEN DO:
       cb-section = string(temp-thbj-attr.property-value-integer) .
/*       if r-type-connect = ? then r-type-connect = 1 .*/
       display cb-section with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_proxy-addres} THEN DO:
       v-proxy-addres = temp-thbj-attr.property-value-character.
       display v-proxy-addres with frame {&frame-name} .
    END.
     IF temp-thbj-attr.prop-code = {&attr-mercur_proxy-login} and temp-thbj-attr.property-value-character > '' THEN DO:
        {gbl/pdecrypt.i temp-thbj-attr.property-value-character v-proxy-login no-error}
        display v-proxy-login with frame {&frame-name} .            
    END.
    IF temp-thbj-attr.prop-code = {&attr-mercur_proxy-pswd} and temp-thbj-attr.property-value-character > '' THEN DO:
        {gbl/pdecrypt.i temp-thbj-attr.property-value-character v-proxy-pswd no-error}
       display v-proxy-pswd with frame {&frame-name} .       
    END. 
    IF temp-thbj-attr.prop-code = {&attr-mercur_proxy-ssl} THEN DO:
       v-proxy-ssl = temp-thbj-attr.property-value-logical.
       display v-proxy-ssl with frame {&frame-name} .
    END. 


END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-mode = {&lookup} then do:
  DISABLE
    v-apikey
    v-login
    v-password
    v-qrcode
    v-close
    v-manual-vcd 
    v-login-is
    r-type-connect
    cb-section
  with frame {&frame-name} .
end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .

define buffer buf_temp-thbj-attr for temp-thbj-attr .

IF p-mode = {&LOOKUP} THEN RETURN .

ASSIGN FRAME {&FRAME-NAME}
    v-apikey
    v-login
    v-password
    v-qrcode
    v-close
    v-manual-vcd 
    v-login-is
    r-type-connect
    cb-section
    v-proxy-addres
    v-proxy-login
    v-proxy-pswd
    v-proxy-ssl
    .

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_apikey} .
    temp-thbj-attr.property-value-character = v-apikey.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_login} .
    temp-thbj-attr.property-value-character = v-login.
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_password} .
    temp-thbj-attr.property-value-character = v-password.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_qrcode} .
    temp-thbj-attr.property-value-character = v-qrcode.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_close} .
    temp-thbj-attr.property-value-logical = v-close.
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_manual-vcd} .
    temp-thbj-attr.property-value-logical = v-manual-vcd.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_login_is} .
    temp-thbj-attr.property-value-character = v-login-is.
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_type-connect} .
    temp-thbj-attr.property-value-integer = r-type-connect.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_server} .
    temp-thbj-attr.property-value-integer = integer(cb-section).
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_proxy-addres} .
    temp-thbj-attr.property-value-character = v-proxy-addres.
    def var v-proxy-enc as char no-undo. 
    
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_proxy-login} .
    if v-proxy-login > ''
    then do :
      {gbl/pencrypt.i v-proxy-login v-proxy-enc no-error}
      temp-thbj-attr.property-value-character = if v-proxy-addres > '' then v-proxy-enc else "":U.
    end.
    else temp-thbj-attr.property-value-character = "":U .
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_proxy-pswd} .
    if v-proxy-pswd > ''
    then do :
      {gbl/pencrypt.i v-proxy-pswd v-proxy-enc no-error }
      temp-thbj-attr.property-value-character = if v-proxy-addres > '' then v-proxy-enc else "":U.
    end.
    else temp-thbj-attr.property-value-character = "":U .
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-mercur_proxy-ssl} .
    temp-thbj-attr.property-value-logical = v-proxy-ssl.
        
    do transaction:
        RUN thbjattr_set-section IN THIS-PROCEDURE (
             input p-obj-type
            ,input p-obj-code
            ,input {&attr-mercur}
            ,INPUT table temp-thbj-attr
        ) NO-ERROR.
        if error-status:error then do:
            message "Не удалось сохранить настройки"
            view-as alert-box.
            undo, return error.
        end.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

