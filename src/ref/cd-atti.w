&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.cash-desk-attr
       field user-can-edit as log
       field code as character
       field value_ as character
       field to-send as logical
       iNDEX pi is unique primary
       db-num
       obj-code
       pos-type
       cash-num
       upper-attr-code
       code

       INDEX attrc
       attr-code
       db-num

       INDEX ichar
       upper-attr-code
       attr-code
       attr-value-character

       iNDEX idate
       upper-attr-code
       attr-code
       attr-value-date

       INDEX idec
       upper-attr-code
       attr-code
       attr-value-decimal

       INDEX iint
       upper-attr-code
       attr-code
       attr-value-integer

       INDEX ilog
       upper-attr-code
       attr-code
       attr-value-logical

       INDEX iuattr
       upper-attr-code
       db-num

       index itype
       attr-value-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты и/или параметры кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/16/04
Author: Bakhtadze Natalya
Creation date: 06/16/04

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as char no-undo.
define input parameter p-ref-mode as character no-undo . /*oper или ref*/
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo.
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo.
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input parameter p-glog   as LOGICAL no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты и/или параметры кассы".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cd-attr.i interface parparentproc }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc2 }
{ gbl/color.i }
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as character no-undo.
define variable add-option-section as character no-undo.
define variable send-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable v-view-col as logical no-undo extent 6.
define buffer buf_cash-desk for ub.cash-desk.
DEFINE VARIABLE v-ch_ AS WIDGET-HANDLE NO-UNDO EXTENT 5.
define variable v-glog as logical no-undo .
define variable v-cash-desk-host-code as integer no-undo .

&scoped-define  cd-attr-type-get-error message "Ошибка при определении названия и типа атрибута/параметра кассы!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  cd-attr-value-get-error message "Ошибка при определении значения атрибута/параметра кассы!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  cd-attr-write-get-error message "Ошибка при изменении значения атрибута/параметра кассы!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&scoped-define  cd-attr-delete-get-error message "Ошибка при удалении атрибута/параметра кассы!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

DEFINE MENU MENU-b-ins .
&scoped-define label-clmn_character "Значение!(строковое)"
&scoped-define label-clmn_date "Значение!(Дата)"
&scoped-define label-clmn_decimal "Значение!(Десятичное)"
&scoped-define label-clmn_integer "Значение!(Целое)"
&scoped-define label-clmn_logical "Значение!(Логическое)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-attrs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Temp-hattr

/* Definitions for BROWSE br-attrs                                      */
&Scoped-define FIELDS-IN-QUERY-br-attrs Temp-hattr.attr-code Temp-hattr.attr-value-character Temp-hattr.attr-value-date Temp-hattr.attr-value-decimal Temp-hattr.attr-value-integer Temp-hattr.attr-value-logical to-send
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attrs
&Scoped-define SELF-NAME br-attrs
&Scoped-define QUERY-STRING-br-attrs FOR EACH Temp-hattr NO-LOCK
&Scoped-define OPEN-QUERY-br-attrs OPEN QUERY {&SELF-NAME} FOR EACH Temp-hattr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-attrs Temp-hattr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attrs Temp-hattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attrs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-ins b-chg b-lkp b-del B-send b-help ~
cd-db-num cd-obj-code cd-pos-type cd-cash-num
&Scoped-Define DISPLAYED-OBJECTS cd-db-num cd-obj-code cd-pos-type ~
cd-cash-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-send
       MENU-ITEM m_current      LABEL "Выделенный"
       MENU-ITEM m_all          LABEL "Все"           .


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут/параметр кассы".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут/параметр кассы".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут/параметр кассы".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE BUTTON B-send
     LABEL "&Послать"
     SIZE 10 BY 1.

DEFINE VARIABLE cd-cash-num AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "№"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cd-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cd-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "маг"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cd-pos-type AS CHARACTER FORMAT "X(10)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 16 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attrs FOR
      Temp-hattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attrs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attrs Dialog-Frame _FREEFORM
  QUERY br-attrs DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут/Параметр" FORMAT "X(255)":U
            WIDTH 30
      Temp-hattr.attr-value-character COLUMN-LABEL {&label-clmn_character}  FORMAT "X(255)":U
            WIDTH 35
      Temp-hattr.attr-value-date COLUMN-LABEL {&label-clmn_date} FORMAT "99/99/9999":U
      Temp-hattr.attr-value-decimal COLUMN-LABEL {&label-clmn_decimal} FORMAT "->>>,>>>,>>9.99":U
            WIDTH 16
      Temp-hattr.attr-value-integer COLUMN-LABEL {&label-clmn_integer} FORMAT "->>>,>>>,>>9":U
      Temp-hattr.attr-value-logical COLUMN-LABEL {&label-clmn_logical} FORMAT "+/-":U
      to-send COLUMN-LABEL "Подлежит!пересылке" FORMAT "+/-":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.97
         FONT 4.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     B-send AT ROW 1 COL 61
     b-help AT ROW 1.03 COL 95
     br-attrs AT ROW 4.47 COL 1
     cd-db-num AT ROW 3.3 COL 1
     cd-obj-code AT ROW 3.3 COL 15
     cd-pos-type AT ROW 3.3 COL 33.8
     cd-cash-num AT ROW 3.3 COL 58.8
     SPACE(31.49) SKIP(19.14)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты и/или Параметры кассы".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Compile into: .
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Temp-hattr T "?" NO-UNDO ub cash-desk-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as character
          field value_ as character
          field to-send as logical
          iNDEX pi is unique primary
          db-num
          obj-code
          pos-type
          cash-num
          upper-attr-code
          code

          INDEX attrc
          attr-code
          db-num

          INDEX ichar
          upper-attr-code
          attr-code
          attr-value-character

          iNDEX idate
          upper-attr-code
          attr-code
          attr-value-date

          INDEX idec
          upper-attr-code
          attr-code
          attr-value-decimal

          INDEX iint
          upper-attr-code
          attr-code
          attr-value-integer

          INDEX ilog
          upper-attr-code
          attr-code
          attr-value-logical

          INDEX iuattr
          upper-attr-code
          db-num

          index itype
          attr-value-type
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-attrs b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-send:HANDLE.

/* SETTINGS FOR BROWSE br-attrs IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cd-cash-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cd-db-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cd-obj-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cd-pos-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attrs
/* Query rebuild information for BROWSE br-attrs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Temp-hattr NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-attrs */
&ANALYZE-RESUME




/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

/* OCX BINARY:FILENAME is: exe\wrx\ref\cd-atti.wrx */

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME Dialog-Frame:HANDLE
       ROW             = 1.53
       COLUMN          = 81.5
       HEIGHT          = 1.6
       WIDTH           = 5.5
       WIDGET-ID       = 2
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */
      CtrlFrame:MOVE-AFTER(b-help:HANDLE IN FRAME Dialog-Frame).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты и/или Параметры кассы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error.
  if error-status:error then return no-apply.
  run init-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
    if not p-glog and Temp-hattr.code = "last-check-params" then 
    return no-apply .  
    if not v-glog and Temp-hattr.code <> "last-check-params" then return no-apply .
  
  run cd-attr-code in this-procedure (
                                       input  temp-hattr.upper-attr-code
                                      ,input  temp-hattr.code
                                      ,output attr-type
                                      ,output attr-format
                                      ,output attr-label
                                      ,output attr-user-can-edit
                                      ,output attr-output-display
                                      ,output attr-other
                                      ,output v-prop-list
                                      ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут/Параметр нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
     do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-db-num
                      ,input p-obj-code
                      ,input p-pos-type
                      ,INPUT p-cash-num
                      ,input temp-hattr.upper-attr-code
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input {&deletion}
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута/параметра" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута/параметра некорректно" skip
      return-value
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.


  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут/параметр " temp-hattr.attr-code skip
  " для кассы"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run cd-attr-delete in this-procedure (
                                          input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,input temp-hattr.upper-attr-code
                                        ,input temp-hattr.code
                                        ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
       {&cd-attr-delete-get-error}
       return no-apply.
    end.
    delete temp-hattr.
    updated = yes.
    run init-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ins Dialog-Frame
ON CHOOSE OF b-ins IN FRAME Dialog-Frame /* Добавить */
DO:
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  add-option-section = ''.
  return no-apply.
end.
run init-proc in this-procedure .
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
add-option-section = ''.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition br-attrs to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    if not avail temp-hattr then return no-apply.
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход  */
DO:
/*
  for each temp-hattr no-lock:
    run cd-attr-write in this-procedure (
                                    input p-db-num,
                                    input p-obj-code,
                                    input add-option,
                                    input temp-hattr.attr-value)  no-error.
    updated = yes.
  End.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-send Dialog-Frame
ON CHOOSE OF B-send IN FRAME Dialog-Frame /* Послать */
DO:
  if send-option = "" then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if send-option = "":U then return no-apply.
  if send-option = {&all} then send-option = '':U.
  run proc-b-send in this-procedure ( input '', input send-option ) no-error .
  if error-status:error then do:
    send-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame Dialog-Frame OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
IF p-ref-mode <> "oper"
OR p-mode <> {&LOOKUP}
THEN RETURN.

RUN init-proc IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
  send-option = {&all}.
  apply "CHOOSE" to b-send in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_current
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_current Dialog-Frame
ON CHOOSE OF MENU-ITEM m_current /* Выделенный */
DO:
  IF NOT AVAILABLE temp-hattr THEN RETURN NO-APPLY.
  send-option = temp-hattr.CODE.
  apply "CHOOSE" to b-send in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attrs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }

 frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


ON ROW-DISPLAY OF br-attrs IN frame {&frame-name}
DO:
  IF AVAIL temp-hattr THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT temp-hattr.attr-value-type).
  END.
END.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  find first buf_Cash-desk where
            buf_cash-desk.obj-code =  p-obj-code
        and buf_cash-desk.db-num =  p-db-num
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = p-cash-num
            no-lock no-error .
  { ref/attr-pop.i prepare }
  run MyEnable in this-procedure no-error.
  if error-status:error then do:
    message p-mode skip error-status:error error-status:get-message(1)
    view-as alert-box .
    return error.
  end.
  if return-value = "return" then do:
    run attr-pop-clean-up in this-procedure ( input {&table_cash-desk-attr} ).
    run disable_UI in this-procedure .
    return.
  end.
  run init-proc in this-procedure .
  view frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_cash-desk-attr} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
add-option-section = p-upper-attr-code
.
APPLY "CHOOSE" to b-ins in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load Dialog-Frame  _CONTROL-LOAD
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

OCXFile = SEARCH( "exe\wrx\ref\cd-atti.wrx":U ).
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
  /* при неоьходимости RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.*/
END.
ELSE MESSAGE "exe\wrx\ref\cd-atti.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

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
  RUN control_load.
  DISPLAY cd-db-num cd-obj-code cd-pos-type cd-cash-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-chg b-lkp b-del B-send b-help cd-db-num cd-obj-code
         cd-pos-type cd-cash-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define variable  attr-type as character no-undo .          /* тип атрибута      */
define variable  attr-format as character no-undo .        /* формат атрибута   */
define variable  attr-label as character no-undo .         /* лабел атрибута    */
define variable  attr-character as character no-undo .         /* значение атрибута */
define variable  attr-date as date no-undo .         /* значение атрибута */
define variable  attr-decimal as decimal no-undo .         /* значение атрибута */
define variable  attr-integer as integer no-undo .         /* значение атрибута */
define variable  attr-logical as logical no-undo .         /* значение атрибута */
define variable  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define variable  attr-output-display as logical no-undo .  /* виден в броусе    */
define variable  attr-other as char no-undo .              /* еще чего - нибудь */
define variable v-prop-list as character no-undo .
define variable attr-from-gbd as logical no-undo .
define variable attr-from-ubd as logical no-undo .
define variable attr-news as logical no-undo .
define variable v-one-send-param as logical no-undo .
define variable v-all-send-param as logical no-undo .
define variable v-compl-root as logical no-undo .
define variable jj as integer no-undo .

define buffer buf_cash-desk-attr for ub.cash-desk-attr.
for each  Temp-hattr share-lock:
  delete Temp-hattr.
end.

add-option = "".
add-option-section = "".

Assign
cd-db-num = buf_cash-desk.db-num
cd-obj-code = buf_cash-desk.obj-code
cd-pos-type = buf_cash-desk.pos-type
cd-cash-num = buf_cash-desk.cash-num
v-view-col[1] = no
v-view-col[2] = no
v-view-col[3] = no
v-view-col[4] = no
v-view-col[5] = no
v-view-col[6] = no
.
display
cd-db-num
cd-obj-code
cd-pos-type
cd-cash-num
with frame {&frame-name}  .
_cash-desk-attr:
For each buf_cash-desk-attr where
        buf_cash-desk-attr.obj-code = p-obj-code
  and  buf_cash-desk-attr.db-num  = p-db-num
  and  buf_cash-desk-attr.pos-type  = p-pos-type
  and  buf_cash-desk-attr.cash-num  = p-cash-num
        no-lock :
  if buf_cash-desk-attr.upper-attr-code = '' then do:
    if p-ref-mode = "oper" then do:
      if not (buf_Cash-desk-attr.attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
    else do:
      if (buf_Cash-desk-attr.attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
  end.
  else do:
    if p-ref-mode = "oper" then do:
      if not (buf_Cash-desk-attr.upper-attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
    else do:
      if (buf_Cash-desk-attr.upper-attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
  end.
  v-compl-root = no.
  run cd-attr-code in this-procedure (
                                          input buf_cash-desk-attr.upper-attr-code
                                        , input buf_cash-desk-attr.attr-code
                                        , output attr-type
                                        , output attr-format
                                        , output attr-label
                                        , output attr-user-can-edit
                                        , output attr-output-display
                                        , output attr-other
                                        , output v-prop-list
                                        ).
  if index( attr-other,  "compl-root=") > 0
  and num-entries(buf_cash-desk-attr.attr-code , {&delim-par}) > 1 then do:
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "compl-root":U then do:
        assign
        v-compl-root = logical(entry(lookup(entry(1, buf_cash-desk-attr.attr-code, {&delim-par}),v-prop-list), entry(2, entry(jj, attr-other, {&slash-char}), "=":U)))
        .
      end.
      if v-compl-root  then next _cash-desk-attr.
    end.
  end.
  if p-mode <> {&lookup}
  then do:
    run cd-attr-news in this-procedure (
                                        input buf_cash-desk-attr.upper-attr-code
                                      , input buf_cash-desk-attr.attr-code
                                      , output attr-news
                                      , output attr-from-gbd
                                      , output attr-from-ubd).
    if v-cntxt-db-num = 0
    and buf_cash-desk.db-num <> v-cntxt-db-num
    and attr-from-gbd <> yes
    then  attr-user-can-edit = no.
    if buf_cash-desk.db-num = v-cntxt-db-num
    and attr-from-ubd <> yes and v-cntxt-db-num <> 0
    then
    assign
    attr-user-can-edit = no.
  end.
  if attr-output-display = true then DO:
    run cd-attr-value in this-procedure (
                                            input buf_cash-desk-attr.db-num
                                          ,input buf_cash-desk-attr.obj-code
                                          ,input buf_cash-desk-attr.pos-type
                                          ,input buf_cash-desk-attr.cash-num
                                          ,input buf_cash-desk-attr.upper-attr-code
                                          ,input buf_cash-desk-attr.attr-code
                                          ,output attr-character
                                          ,output attr-date
                                          ,output attr-decimal
                                          ,output attr-integer
                                          ,output attr-logical
                                          ,output attr-type ) .
    create Temp-hattr.
    assign
    temp-hattr.obj-code = buf_cash-desk-attr.obj-code
    temp-hattr.pos-type = buf_cash-desk-attr.pos-type
    temp-hattr.cash-num = buf_cash-desk-attr.cash-num
    temp-hattr.db-num = buf_cash-desk-attr.db-num
    Temp-hattr.upper-attr-code = buf_cash-desk-attr.upper-attr-code
    Temp-hattr.attr-code = attr-label
    Temp-hattr.attr-value-character = attr-character
    Temp-hattr.attr-value-date = attr-date
    Temp-hattr.attr-value-decimal = attr-decimal
    Temp-hattr.attr-value-integer = attr-integer
    Temp-hattr.attr-value-logical = attr-logical
    Temp-hattr.attr-value-type = attr-type
    Temp-hattr.user-can-edit = attr-user-can-edit
    Temp-hattr.code = buf_cash-desk-attr.attr-code
    .
    case attr-type:
      when {&abl-datatype-character} then do:
        assign
        v-view-col[1] = yes.
      end.
      when {&abl-datatype-date} then do:
        assign
        v-view-col[2] = yes.
      end.
      when {&abl-datatype-decimal} then do:
        assign
        v-view-col[3] = yes.
      end.
      when {&abl-datatype-integer} then do:
        assign
        v-view-col[4] = yes.
      end.
      when {&abl-datatype-logical} then do:
        assign
        v-view-col[5] = yes.
      end.
    end case.

    case Temp-hattr.code:
       when {&cda-IBM-XML_operative_USE_FFD_VERSION} then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "авт" .
             when "2" then Temp-hattr.attr-value-character = "1.05" .
             when "3" then Temp-hattr.attr-value-character = "1.1" .
             when "4" then Temp-hattr.attr-value-character = "1.2" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .
       end.
       when {&cda-IBM-XML_operative_KKT_FFD_VERSION} then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "авт" .
             when "2" then Temp-hattr.attr-value-character = "1.05" .
             when "3" then Temp-hattr.attr-value-character = "1.1" .
             when "4" then Temp-hattr.attr-value-character = "1.2" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .
       end.       
       when {&cda-IBM-XML_operative_KKT_SCHEMA} then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "с ожиданием ответа" .
             when "1" then Temp-hattr.attr-value-character = "без ожидания ответа" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .          
       end.   
    end case .   

    run cd-attr-send-param in this-procedure ( input Temp-hattr.upper-attr-code
                                              ,input Temp-hattr.code
                                              ,output Temp-hattr.to-send).
    v-all-send-param = Temp-hattr.to-send or v-all-send-param.
    assign
    v-view-col[6] = v-all-send-param.
  End.
End.   /* FOR EACH */
RUN view-hide-columns IN THIS-PROCEDURE (INPUT NO).
b-send:sensitive in frame {&frame-name} = v-all-send-param.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable attr-type as character no-undo .          /* тип атрибута      */
define variable attr-format as character no-undo .        /* формат атрибута   */
define variable attr-label as character no-undo .         /* лабел атрибута    */
define variable attr-value as character no-undo .         /* значение атрибута */
define variable attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define variable attr-output-display as logical no-undo .  /* виден в броусе    */
define variable attr-other as char no-undo .              /* еще чего - нибудь */
define variable v-prop-list as character no-undo .
define variable attr-from-gbd as logical no-undo .
define variable attr-from-ubd as logical no-undo .
define variable attr-news as logical no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-auto as character no-undo .
DEFINE variable v-ch0 AS HANDLE NO-UNDO.
define variable v-found as logical no-undo .
RUN control_load IN THIS-PROCEDURE .
ASSIGN
B-send:POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-B-send:HANDLE
temp-hattr.attr-value-character:resizable IN BROWSE br-attrs = YES
b-ins:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-ins:HANDLE
temp-hattr.attr-code:resizable in browse br-attrs = yes
b-ins:MENU-MOUSE = 1
chCtrlFrame:PSTimer:ENABLED  = (p-pos-type = {&cd-type-ibs-th}
                               OR
                               p-pos-type = {&cd-type-ibs-th-mob}
                               )
                               AND
                               p-mode = {&LOOKUP}
chCtrlFrame:PSTimer:INTERVAL = IF NOT (p-pos-type = {&cd-type-ibs-th}
                               OR
                               p-pos-type = {&cd-type-ibs-th-mob}
                               )
                               AND
                               p-mode = {&LOOKUP} THEN 0
                                ELSE 3000
.
ASSIGN
v-ch0 = br-attrs:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_character} THEN
   v-ch_[1] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_date} THEN
   v-ch_[2] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_decimal} THEN
   v-ch_[3] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_integer} THEN
   v-ch_[4] = v-ch0.
   IF v-ch0:LABEL = {&label-clmn_logical} THEN
   v-ch_[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
do v-jj = 1 to num-entries ({&cd-attr-list}):
  if not entry(v-jj, {&cd-attr-list}) begins p-pos-type then next.
  if p-ref-mode = "oper" then do:
    if not entry(v-jj, {&cd-attr-list}) begins (p-pos-type + "_operative") then next.
  end.
  else do:
    if entry(v-jj, {&cd-attr-list}) begins (p-pos-type + "_operative") then next.
  end.
  v-found = yes.
  if p-mode <> {&lookup} then do:
    v-prop-list = ''.
    run cd-attr-code in this-procedure (
                                        input  entry(v-jj, {&cd-attr-list})
                                        ,input  ''
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ,output v-prop-list
                                        )  .
    run attr-pop-create-items in this-procedure  (
                                                  input {&table_cash-desk-attr}
                                                  ,input 'cd-attr-manual-edit'   /*p-get-section-num-proc-name*/
                                                  ,input 'cd-attr-tooltip'
                                                  ,input 'choose-to-edit'
                                                  ,input menu menu-b-ins:handle
                                                  ,input entry(v-jj, {&cd-attr-list})
                                                  ,input v-prop-list
                                                ).
  end.
end.
if not v-found then do:
  if p-ref-mode = "oper" then do:
    message
    "Для данного типа кассы не найдено оперативных данных для изменения/просмотра"
      view-as alert-box warning.
  end.
  else do:
    message
    "Для данного типа кассы не найдено настроек для изменения/просмотра"
      view-as alert-box warning.
  end.
    return "return".
end.
if p-mode <> {&lookup} then do:
  for each tt-attr-property where
            tt-attr-property.table-name = {&table_cash-desk-attr}:
    v-prop-list = ''.
    run cd-attr-code in this-procedure (
                                         input  tt-attr-property.upper-attr-code
                                        ,input  tt-attr-property.attr-code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ,output v-prop-list
                                        ) .
    v-auto = '':U.
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "auto":U then do:
        assign
        v-auto = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        .
      end.
    end.
    /*входит наша касса в этот список?*/
    if valid-handle (tt-attr-property.menu-item-handle) then do:
      assign
      tt-attr-property.menu-item-handle:sensitive = (v-auto = '':U
                                                        or
                                                        lookup(string(buf_cash-desk.auto),  v-auto) > 0)
      .
      run cd-attr-news in this-procedure (
                                           input  tt-attr-property.upper-attr-code
                                          ,input  tt-attr-property.attr-code
                                          ,output attr-news
                                          ,output attr-from-gbd
                                          ,output attr-from-ubd).
      if v-cntxt-db-num = 0
      and buf_cash-desk.db-num <> v-cntxt-db-num
      and attr-from-gbd <> yes  then do:
        tt-attr-property.menu-item-handle:sensitive = no.
      end.
      if buf_cash-desk.db-num = v-cntxt-db-num
      and attr-from-ubd <> yes and v-cntxt-db-num <> 0 then do:
        tt-attr-property.menu-item-handle:sensitive = no.
      end.
      release tt-attr-property.
    end.
 end.
end.
if p-mode = {&update} then do:
  v-found = no.
  for each  tt-attr-property where
           tt-attr-property.table-name = {&table_cash-desk-attr}:
    if tt-attr-property.menu-item-handle:sensitive = yes then do:
      v-found = yes.
      leave.
    end.
  end.
  if not v-found then do:
    if p-ref-mode = "oper" then do:
      message
      "Для данного типа кассы не найдено оперативных данных, которые разрешено менять из данной БД"
      view-as alert-box warning.
    end.
    else do:
      message
      "Для данного типа кассы не найдено настроек, которые разрешено менять из данной БД"
      view-as alert-box warning.
    end.
    return "return".
  end.
end. /*if p-mode = {&update} then do:*/
ENABLE
b-quit
b-lkp
b-del when p-mode = {&update}
b-ins when p-mode = {&update}
b-chg when p-mode = {&update}
b-help br-attrs
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
ASSIGN
b-ins:MENU-MOUSE = 1
b-send:MENU-MOUSE = 1
.

      { gbl/hostcode.i
    {&shop}
    p-obj-code
    v-cash-desk-host-code
    }
    
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cashdesk-reference_input-deletion-updating':U
        {&cntxt-object}
        v-cash-desk-host-code
        {&shop}
        p-obj-code
        0
        0
        0
        false
        v-glog
        }

        
        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-character as character no-undo .
define variable attr-date as date no-undo .         /* значение атрибута */
define variable attr-decimal as decimal no-undo .         /* значение атрибута */
define variable attr-integer as integer no-undo .         /* значение атрибута */
define variable attr-logical as logical no-undo .         /* значение атрибута */

define variable v-prop-list as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .

define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-sprlevel as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable glog  as logical no-undo .

define variable loc#log as logical no-undo.
case p-add:
  when yes then do:
    if p-mode <> {&add-def} then do:
    if not p-glog and add-option = "last-check-params" then 
    return no-apply .  
    if not v-glog and add-option <> "last-check-params" then return no-apply .

      run temp-cd-attr-exist in this-procedure (
                                                   input p-db-num
                                                  ,input p-obj-code
                                                  ,input p-pos-type
                                                  ,input p-cash-num
                                                  ,input add-option-section
                                                  ,input add-option
                                                  ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут/параметр уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    run cd-attr-code in this-procedure (
                                           input  add-option-section   /* p-ucode */
                                          ,input  add-option          /* p-code           */
                                          ,output attr-type           /* p-type           */
                                          ,output attr-format         /* p-format         */
                                          ,output attr-label          /* p-label          */
                                          ,output attr-user-can-edit  /* p-user-can-edit  */
                                          ,output attr-output-display /* p-output-display */
                                          ,output attr-other          /* p-other          */
                                          ,output v-prop-list
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        .
      end.
    end. /*jj*/
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                         input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,output attr-character
                                        ,output attr-date
                                        ,output attr-decimal
                                        ,output attr-integer
                                        ,output attr-logical
                                        ) no-error .
          if error-status:error then do:
              assign
              attr-character = "":U
              .
          end.
    end.
    CASE attr-type:
      when {&type-log} then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-character
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        v-attr-value = ?
        .
      end.
      when {&type-char} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-character
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-character = v-attr-value
    .
  end.
  when no then do:
    if not p-glog and TEMP-hattr.code = "last-check-params" then 
    return no-apply .  
    if not v-glog and TEMP-hattr.code <> "last-check-params" then return no-apply .

    run cd-attr-code in this-procedure (
                                           input TEMP-hattr.upper-attr-code
                                          ,input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other
                                          ,output v-prop-list
                                          ) no-error.
    IF ERROR-STATUS:ERROR
    THEN DO:
        {&cd-attr-type-get-error}
        return error.
    END.
    if temp-hattr.user-can-edit = no then do:
      message
      "Нельзя менять атрибут/параметр!"
      view-as alert-box error .
      undo, return error .
    end.
    RUN cd-ATTR-VALUE IN THIS-PROCEDURE (
                                          INPUT p-db-num
                                         ,INPUT p-obj-code
                                         ,INPUT p-pos-type
                                         ,input p-cash-num
                                         ,input TEMP-hattr.upper-attr-code
                                         ,input TEMP-hattr.code
                                         ,OUTPUT ATTR-character
                                         ,output attr-date
                                         ,output attr-decimal
                                         ,output attr-integer
                                         ,output attr-logical
                                         ,OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        {&cd-attr-value-get-error}
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "sprlevel":U then do:
      assign
      v-sprlevel = entry(2, entry(jj, attr-other, {&slash-char}), "=":U)
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U then do:
      if v-sprlevel = "cd" then do:
        assign
        v-spr = entry(2, entry(jj, attr-other, {&slash-char}), "=":U)
        .
      end.
      else do:
        assign
        v-spr = string(entry(lookup(if p-add then add-option else temp-hattr.code, v-prop-list ),  entry(2, entry(jj, attr-other, {&slash-char}), "=":U)))
        .
      end.
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(lookup(if p-add then add-option else temp-hattr.code, v-prop-list ),  entry(2, entry(jj, attr-other, {&slash-char}), "=":U)))
      .
    end.

  end.
  if v-spr = "":U then do:
    define variable v-ok as logical no-undo .
     case attr-type:
      when {&abl-datatype-character} then do:
        run gbl/d-character.w (
             input ?
            ,input (
            'title=':u + "Изменение атрибута/параметра кассы" + '\':u
          + 'text1=':u + attr-label + '\':u
          + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
          + 'fillin_row=4\':u
          + 'fillin_col=4\':u
          + 'fillin_width=20\':u
          + 'fillin_height=1\':u
          + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u  )
          , input-output attr-character
          , output v-ok
                ).
      end.
      when {&abl-datatype-date} then do:
        run gbl/d-inpday.w
          (input ?                  /* h-callback    */
          ,input substitute("Изменение атрибута/параметра кассы &1", attr-label)        /* p-title       */
          ,input ""                 /* p-description */
          ,input-output attr-date /* p-date        */
          ,output v-ok              /* p-ok          */
          ) NO-ERROR.
      end.
      when {&abl-datatype-decimal} then do:
        run gbl/d-decimal.w (
              input ?
              ,input (
              'title=':u + "Изменение атрибута/параметра кассы" + '\':u
            + 'text1=':u + attr-label + '\':u
            + 'format=' + attr-format + '\':u
            + 'fillin_row=3\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u  )
            , input-output attr-decimal
            , output v-ok
                ).
      end.
      when {&abl-datatype-integer} then do:
        run gbl/d-integer.w (
              input ?
              ,input (
              'title=':u + "Изменение атрибута/параметра кассы" + '\':u
            + 'text1=':u + attr-label + '\':u
            + 'format=' + attr-format + '\':u
            + 'fillin_row=3\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u  )
            , input-output attr-integer
            , output v-ok
                ).
      end.
      when {&abl-datatype-logical} then do:
        run gbl/d-logical.w (
           input ?
          ,input  (
          'title=':u + "Изменение атрибута/параметра кассы" + '\':u
          + 'text1=':u + attr-label + '\':u
          + 'format=' + "yes/no"  + '\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=20\':u
          + 'fillin_height=1\':u
          + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u)
          , input-output attr-logical
          , output v-ok
                ).
      end.
    end case.
    if not v-ok then return error.
    run cd-attr-write in this-procedure (
                                          input p-db-num
                                          ,input p-obj-code
                                          ,input p-pos-type
                                          ,input p-cash-num
                                          ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                          ,input (if p-add then add-option else temp-hattr.code)
                                          ,input attr-character
                                          ,input attr-date /*p-attr-date*/
                                          ,input attr-decimal /*p-attr-decimal*/
                                          ,input attr-integer /*p-attr-integer*/
                                          ,input attr-logical /*p-attr-logical*/
                                        ) no-error .
    IF NOT error-status:error then do:
        assign
        updated = yes
        .
    END.
    else do:
        {&cd-attr-write-get-error}
    end.
  END.
  ELSE DO:
    if v-sprlevel = '' then do:
      run  value(v-spr) in this-procedure (
                                       input parparentproc
                                      ,input p-db-num
                                      ,input p-obj-code
                                      ,input p-pos-type
                                      ,INPUT p-cash-num
                                      ,input-output attr-character
                                      ,input-output attr-date
                                      ,input-output attr-decimal
                                      ,input-output attr-integer
                                      ,input-output attr-logical
                                      ,output v-setted) no-error .
    end.
    if v-sprlevel = 'cd' then do:
      run  value(v-spr) (
                                       input parparentproc
                                      ,input {&update}
                                      ,input p-db-num
                                      ,input p-obj-code
                                      ,input p-pos-type
                                      ,INPUT p-cash-num
                                      ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                      ,input (if p-add then add-option else temp-hattr.code)
                                      ,output v-setted) no-error .
    end.
    if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-db-num
                      ,input p-obj-code
                      ,input p-pos-type
                      ,input p-cash-num
                      ,input (if p-add = yes then add-option-section else temp-hattr.upper-attr-code)
                      ,input (if p-add = yes then add-option else temp-hattr.code)
                      ,input attr-character
                      ,input attr-date
                      ,input attr-decimal
                      ,input attr-integer
                      ,input attr-logical
                      ,input (if p-add then {&add-def} else {&update})
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута/параметра" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута/параметра некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run cd-attr-write in this-procedure (
                                        input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                        ,input (if p-add then add-option else temp-hattr.code)
                                        ,input attr-character
                                        ,input attr-date
                                        ,input attr-decimal
                                        ,input attr-integer
                                        ,input attr-logical
                                      ) no-error .
  IF NOT error-status:error then do:
    assign
    updated = yes
    .
  END.
  else do:
    {&cd-attr-write-get-error}
  end.
End.
Else message "Изменение атрибута/параметра невозможно !" view-as alert-box error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-prop-list as character no-undo .
define variable v-run-name as character no-undo .
define variable v-sprlevel as character no-undo .
define variable v-setted as logical no-undo .
define variable jj as integer no-undo .

  run cd-attr-code in this-procedure (
                       input temp-hattr.upper-attr-code
                      ,input temp-hattr.code
                      ,output attr-type
                      ,output attr-format
                      ,output attr-label
                      ,output attr-user-can-edit
                      ,output attr-output-display
                      ,output attr-other
                      ,output v-prop-list
                      ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    {&cdattr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "sprlevel":U then do:
    assign
    v-sprlevel = entry(2, entry(jj, attr-other, {&slash-char}), "=":U)
    .
  end.
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "display":U then do:
    if v-sprlevel = "cd" then do:
      assign
      v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U)
      .
    end.
    else do:
      assign
      v-run-name = string(entry(lookup(entry(1, temp-hattr.code, {&delim-par}), v-prop-list ),  entry(2, entry(jj, attr-other, {&slash-char}), "=":U)))
      .
    end.
  end.
end.
if v-sprlevel = 'cd' then do:
  run  value(v-run-name) (
                                    input parparentproc
                                  ,input {&lookup}
                                  ,input p-db-num
                                  ,input p-obj-code
                                  ,input p-pos-type
                                  ,INPUT p-cash-num
                                  ,input temp-hattr.upper-attr-code
                                  ,input temp-hattr.code
                                  ,output v-setted) no-error .
end.
else do:
  run value(v-run-name) in this-procedure(
                                         input parparentproc
                                        ,input temp-hattr.db-num
                                        ,input temp-hattr.obj-code
                                        ,input temp-hattr.pos-type
                                        ,input temp-hattr.cash-num
                                        ,input temp-hattr.upper-attr-code
                                        ,input temp-hattr.code
                                        ,input temp-hattr.attr-value-character
                                        ,input temp-hattr.attr-value-date
                                        ,input temp-hattr.attr-value-decimal
                                        ,input temp-hattr.attr-value-integer
                                        ,input temp-hattr.attr-value-logical
                                          )
                                          no-error .

end.
if error-status:error then undo, return error .
return .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-send Dialog-Frame
PROCEDURE proc-b-send :
define input parameter p-section as character no-undo .
DEFINE INPUT PARAMETER p-what-send AS CHARACTER NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-one-send-param as logical no-undo .
if v-parameter <> '':U then do:
  run cd-attr-send-param in this-procedure ( input Temp-hattr.upper-attr-code
                                            ,input Temp-hattr.code
                                            ,output v-one-send-param) no-error .
  if not v-one-send-param then do:
    message
    "Данный атрибут/параметр пересылке не подлежит"
    view-as alert-box WARNING.
    return error.
  end.
end.
assign
v-parameter =  string(buf_cash-desk.db-num) + {&delim-par} +
            string(buf_cash-desk.obj-code) + {&delim-par} +
            buf_cash-desk.pos-type + {&delim-par} +
            string(buf_cash-desk.cash-num) + {&delim-par} +
            'U' + {&delim-par} + p-what-send + {&delim-par} + p-section.

if buf_cash-desk.db-num = v-cntxt-db-num then do:
  run str/diallog.w ( INPUT parparentproc
                , INPUT this-procedure
                , INPUT 'str/send-par.p':U
                , input v-parameter
                , no
                , ''
                , 'Отправка параметров касс').
end.
else do:
     /*сделаем команду run-file для файла sendbynw.p с параметром v-parameter*/
    run nws/cr-route.p (
                   input {&send-cmd}
                  ,input "command" + {&delim-nws} + "run-file" + {&delim-nws} + "str/send-par.p" + {&delim-nws} + v-parameter
                  ,input ?
                  ,input string(buf_cash-desk.db-num)
                  ) no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при отсылке параметра на кассу через СПН&1"  +
                 "&2&1&3&1"
                 , error-status:get-message(1)
                 , return-value )
      view-as alert-box error .
    end.
    else do:
       message
       "Команда на отсылку параметра на кассу успешно отправлена через СПН"
       view-as alert-box.
    end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-cd-attr-exist Dialog-Frame
PROCEDURE temp-cd-attr-exist :
do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .

    run cd-attr-code in this-procedure (
                                         input  p-ucode           /* p-ucode           */
                                        ,input  p-code           /* p-code           */
                                        ,output v-type           /* p-type           */
                                        ,output v-format         /* p-format         */
                                        ,output v-label          /* p-label          */
                                        ,output v-user-can-edit  /* p-user-can-edit  */
                                        ,output v-output-display /* p-output-display */
                                        ,output v-other          /* p-other          */
                                        ,output v-prop-list
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.db-num  = p-db-num
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.pos-type  = p-pos-type
        and buf_temp-hattr.cash-num  = p-cash-num
        and buf_temp-hattr.code = p-code
        and buf_temp-hattr.upper-attr-code = p-ucode
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-hide-columns Dialog-Frame
PROCEDURE view-hide-columns :
DEFINE INPUT PARAMETER p-find AS LOGICAL NO-UNDO.
IF p-find THEN DO:
   v-view-col[1] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = {&abl-datatype-character}).
   v-view-col[2] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = {&abl-datatype-date}).
   v-view-col[3] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = {&abl-datatype-decimal}).
   v-view-col[4] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = {&abl-datatype-integer}).
   v-view-col[5] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = {&abl-datatype-logical}).
END.
assign
temp-hattr.attr-value-character:visible in browse br-attrs = v-view-col[1]
temp-hattr.attr-value-date:visible in browse br-attrs = v-view-col[2]
temp-hattr.attr-value-decimal:visible in browse br-attrs = v-view-col[3]
temp-hattr.attr-value-integer:visible in browse br-attrs = v-view-col[4]
temp-hattr.attr-value-logical:visible in browse br-attrs = v-view-col[5]
temp-hattr.to-send:visible in browse br-attrs = v-view-col[6]
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME