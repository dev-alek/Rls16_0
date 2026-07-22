&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.cash-pay-attr
       field user-can-edit as log
       field code as character
       field value_ as character.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты типа кассового платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/24/05
Author: Bakhtadze Natalya
Creation date: 05/24/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo.
define input parameter p-curr-code  like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo.
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo.
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты типа кассового платежа".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ ref/cp-attr.i interface parparentproc }
{ cmp/showinf.i }
{ gbl/get-regf.i }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.

&scoped-define  cp-attr-type-get-error message "Ошибка при определении названия и типа атрибута типа кассового платежа!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  cp-attr-value-get-error message "Ошибка при определении значения атрибута типа кассового платежа!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  cp-attr-write-get-error message "Ошибка при изменении значения атрибута типа кассового платежа!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&scoped-define  cp-attr-delete-get-error message "Ошибка при удалении атрибута типа кассового платежа!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

DEFINE MENU MENU-b-ins .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Temp-hattr

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 Temp-hattr.attr-code ~
get-region(temp-hattr.host-code, temp-hattr.obj-type, temp-hattr.obj-code) ~
Temp-hattr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH Temp-hattr NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 Temp-hattr
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 Temp-hattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-ins b-lkp b-chg b-del b-help ~
v-obj-name cd-cdpay-code cd-curr-code
&Scoped-Define DISPLAYED-OBJECTS v-obj-name cd-cdpay-code cd-curr-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут типа кассового платежа".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут типа кассового платежа".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут типа кассового платежа".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр атрибута типа кассового платежа".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE cd-cdpay-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код типа платежа"
      VIEW-AS TEXT
     SIZE 9.63 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cd-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 55 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      Temp-hattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      get-region(temp-hattr.host-code, temp-hattr.obj-type, temp-hattr.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
            WIDTH 13
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(45)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     BROWSE-2 AT ROW 4.46 COL 1
     v-obj-name AT ROW 2 COL 2.5 NO-LABEL
     cd-cdpay-code AT ROW 3.25 COL 2.5
     cd-curr-code AT ROW 3.25 COL 33.5
     SPACE(48.24) SKIP(15.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты типа кассового платежа".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Temp-hattr T "?" NO-UNDO ub cash-pay-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as character
          field value_ as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BROWSE-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cd-cdpay-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cd-curr-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "Temp-Tables.Temp-hattr"
     _FldNameList[1]   > Temp-Tables.Temp-hattr.attr-code
"Temp-hattr.attr-code" "Атрибут" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > "_<CALC>"
"get-region(temp-hattr.host-code, temp-hattr.obj-type, temp-hattr.obj-code)" "Действует" "X(12)" ? ? ? ? ? ? ? no ? no no "13" yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.Temp-hattr.attr-value
"Temp-hattr.attr-value" "Значение" "X(45)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты типа кассового платежа */
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
  RUN init-proc in this-procedure .
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
define variable attr-range as integer no-undo .  /*область действия*/
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run cp-attr-code (
    input  temp-hattr.code
    ,output attr-type
    ,output attr-format
    ,output attr-label
    ,output attr-range
    ,output attr-user-can-edit
    ,output attr-output-display
    ,output attr-other
    ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
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
                       input p-cdpay-code
                      ,input p-curr-code
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input {&deletion}
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута некорректно" skip
      v-error-code
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.


  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для типа кассового платежа"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run cp-attr-delete in this-procedure(
                                    input p-cdpay-code
                                    ,input p-curr-code
                                    ,input temp-hattr.host-code
                                    ,input temp-hattr.obj-type
                                    ,input temp-hattr.obj-code
                                    ,input temp-hattr.code
                                    ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
       {&cp-attr-delete-get-error}
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
define variable attr-range as integer no-undo . /*область действия*/
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
  return no-apply.
end.
Run init-proc in this-procedure .
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BROWSE-2 to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
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
    run cp-attr-write in this-procedure (
                                    input p-cdpay-code
                                    ,input p-curr-code
                                    ,input temp-hattr.host-code
                                    ,input temp-hattr.obj-type
                                    ,input temp-hattr.obj-code
                                    ,input add-option
                                    ,input temp-hattr.attr-value)  no-error.
    updated = yes.
  End.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON RETURN OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }

 frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure no-error.
  if error-status:error then return error.
  Run init-proc in this-procedure .
  view frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_cash-pay-attr} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-ins in frame {&frame-name} .
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
  DISPLAY v-obj-name cd-cdpay-code cd-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-lkp b-chg b-del b-help v-obj-name cd-cdpay-code
         cd-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define var  attr-range as integer no-undo .           /* область действия  */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */

define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
for each  Temp-hattr share-lock: delete Temp-hattr. end.

add-option = "".

find first buf_cash-pay where buf_cash-pay.cdpay-code =  p-cdpay-code
                   AND buf_cash-pay.curr-code = p-curr-code

                        no-lock no-error .

Assign
    cd-cdpay-code = buf_cash-pay.cdpay-code
    cd-curr-code = buf_cash-pay.curr-code

    .
display cd-cdpay-code cd-curr-code
  with frame {&frame-name}  .

   For each buf_cash-pay-attr where
            buf_cash-pay-attr.cdpay-code  = p-cdpay-code
       and  buf_cash-pay-attr.curr-code  = p-curr-code
            no-lock :
          run cp-attr-code in this-procedure (
                                              input buf_cash-pay-attr.attr-code
                                              ,output attr-type
                                              ,output attr-format
                                              ,output attr-label
                                              ,output attr-range
                                              ,output attr-user-can-edit
                                              ,output attr-output-display
                                              ,output attr-other ).

          if attr-output-display = true then DO:
              run cp-attr-value in this-procedure (
                                                  input buf_cash-pay-attr.cdpay-code
                                                  ,input buf_cash-pay-attr.curr-code
                                                  ,input buf_cash-pay-attr.host-code
                                                  ,input buf_cash-pay-attr.obj-type
                                                  ,input buf_cash-pay-attr.obj-code
                                                  ,input buf_cash-pay-attr.attr-code
                                                  ,output attr-value
                                                  ,output attr-type ).

              create Temp-hattr.
              assign
              Temp-hattr.attr-code = attr-label
              Temp-hattr.value_ = buf_cash-pay-attr.attr-value
              Temp-hattr.attr-value = (if attr-type = {&type-log}
                                      then string(attr-value = "yes":U, attr-format)
                                      else attr-value)
              Temp-hattr.user-can-edit = attr-user-can-edit
              Temp-hattr.code = buf_cash-pay-attr.attr-code
              temp-hattr.host-code = buf_cash-pay-attr.host-code
              temp-hattr.obj-type = buf_cash-pay-attr.obj-type
              temp-hattr.obj-code = buf_cash-pay-attr.obj-code
              .
      End.
    End.   /* FOR EACH */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define variable attr-range as integer no-undo .       /* область дейтсвия */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */
define variable v-version as decimal no-undo .

define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-cd as character no-undo .
define variable v-cd-list as character no-undo .
DEFINE BUFFER buf_Cash-pay FOR ub.cash-pay.
ASSIGN
b-ins:POPUP-MENU IN FRAME {&frame-name}  = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
Temp-hattr.attr-value:width in browse browse-2 = 45
Temp-hattr.attr-value:resizable in browse browse-2 = yes
.
if p-mode <> {&lookup} then do:
  run attr-pop-create-items in this-procedure  (
                                                 input {&table_cash-pay-attr}
                                                ,input 'cp-attr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'cp-attr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-ins:handle
                                                ,input {&cp-attr-list}
                                              ).
end.

FIND FIRST buf_Cash-pay NO-LOCK WHERE
            buf_Cash-pay.cdpay-code = p-cdpay-code
      AND   buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    v-obj-name = buf_cash-pay.obj-name.
END.
ASSIGN b-ins:MENU-MOUSE in frame {&frame-name}  = 1.

DISPLAY
v-obj-name
WITH FRAME {&frame-name} .
ENABLE
b-quit
b-del when p-mode = {&update}
b-ins when p-mode = {&update}
b-chg when p-mode = {&update}
b-lkp
b-help BROWSE-2
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-range as integer no-undo .          /*область действия*/
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .

define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-ask-labels as character no-undo .
define variable choice as integer no-undo .

define var loc#log as logical no-undo.
case p-add:
  when yes then do:
    run cp-attr-code in this-procedure (
                                          input  add-option          /* p-code           */
                                          ,output attr-type           /* p-type           */
                                          ,output attr-format         /* p-format         */
                                          ,output attr-label          /* p-label          */
                                          ,output attr-range          /* p-range          */
                                          ,output attr-user-can-edit  /* p-user-can-edit  */
                                          ,output attr-output-display /* p-output-display */
                                          ,output attr-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    /*определим область действия если это нужно*/
    CASE attr-range:
      /*задаем то что выйдет если нажать первую опцию*/
      when integer({&global-int}) then do:
        assign
        v-ask-labels = "Глобально"
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
      when integer({&global-host-int}) then do:
        assign
        v-ask-labels = substitute("Глобально|Фирма &1", p-host-code)
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
      when integer({&object-int}) then do:
        assign
        v-ask-labels = substitute("&1&2", p-obj-type, p-obj-code)
        v-host-code = p-host-code
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
      end.
      when integer({&global-host-object-int}) then do:
        assign
        v-ask-labels = substitute("Глобально|Фирма &1|&2&3", p-host-code, p-obj-type, p-obj-code)
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
    END CASE.
    if num-entries(v-ask-labels, "|") > 1 then do:
      run gbl/d-askw.w (
                          input "Область действия атрибута"
                          ,input "Выберите область действия атрибута"
                          ,input "|"
                          ,input (v-ask-labels + "|Отменить")
                          ,input fill("|", num-entries(v-ask-labels, "|"))
                          ,input 1
                          ,input num-entries(v-ask-labels, "|") + 1
                          ,output choice).
      if choice = num-entries(v-ask-labels, "|") + 1 then do:
        undo, return error .
      end.
    end.
    CASE choice:
      when 1 then do:
        /*ничего не делаем все уже есть*/
      end.
      when 2 then do:
        /*может быть для объекта или для фирмы так как глобально - это 1-ый entry*/
        if v-host-code <> 0  /*"фирма,объект"*/
        then do:
          /*тогда это объект*/
          assign
          v-obj-type  = p-obj-type
          v-obj-code  = p-obj-code
          .
        end.
        if num-entries(v-ask-labels, "|") = 3  /*можно выбирать из 3*/  then do:
          /*тогда это фирма*/
          assign
          v-host-code = p-host-code
          .
        end.
      end.
      when 3 then do:
        /*может быть только для объекта*/
        assign
        v-host-code = p-host-code
        v-obj-type  = p-obj-type
        v-obj-code  = p-obj-code
        .
      end.
    END CASE.
    if p-mode <> {&add-def} then do:
      run temp-cp-attr-exist in this-procedure (
                                                input p-cdpay-code
                                                ,input p-curr-code
                                                ,input v-host-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input add-option
                                                ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.


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
                                          input p-cdpay-code
                                        , input p-curr-code
                                        , input v-host-code
                                        , input v-obj-type
                                        , input v-obj-code
                                        , output attr-value) no-error .
          if error-status:error then do:
              assign
              attr-value = "":U
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
                      then attr-value
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
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run cp-attr-code in this-procedure (
                                          input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-range
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&cp-attr-type-get-error}
        return error.
    END.
    RUN cp-attr-VALUE IN THIS-PROCEDURE (
                                         INPUT p-cdpay-code
                                         ,INPUT p-curr-code
                                         ,input TEMP-hattr.host-code
                                         ,input TEMP-hattr.obj-type
                                         ,input TEMP-hattr.obj-code
                                         ,input TEMP-hattr.code
                                         ,OUTPUT ATTR-VALUE
                                         ,OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        {&cp-attr-value-get-error}
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.

  end.
  if v-spr = "":U then do:
    run gbl/d-prompt.w (
      'title=':u + "Изменение атрибута типа кассового платежа" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u
    , input-output attr-value
        ).
    if return-value = 'false':u then return error.
  END.
  ELSE DO:
    if v-spr-param = "":U then do:
      run  value(v-spr)
                  in this-procedure (
                                       input p-cdpay-code
                                      ,input p-curr-code
                                      ,input (if p-add then v-host-code else temp-hattr.host-code)
                                      ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                      ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
    end.
    else do:
      run  value( v-spr )  in this-procedure (
                                              input p-cdpay-code
                                              ,input p-curr-code
                                              ,input (if p-add then v-host-code else temp-hattr.host-code)
                                              ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                              ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                              ,input v-spr-param
                                              ,input-output attr-value
                                              ,output v-setted) no-error .
    end.
    if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check) in this-procedure (
                                          input p-cdpay-code
                                          ,input p-curr-code
                                          ,input (if p-add = yes then add-option else temp-hattr.attr-code)
                                          ,input attr-value
                                          ,input (if p-add then {&add-def} else {&update})
                                          ,output v-correct
                                          ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задание атрибута некорректно" skip
      v-error-code
      view-as alert-box error .
      undo, return error .
    end.
  end.

  run cp-attr-write in this-procedure (
                                        input p-cdpay-code
                                        ,input p-curr-code
                                        ,input (if p-add then v-host-code else temp-hattr.host-code)
                                        ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                        ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                        ,input (if p-add then add-option else temp-hattr.code)
                                        ,input attr-value
                                      ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
  else do:
      {&cp-attr-write-get-error}
  end.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.

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
define variable attr-range as integer no-undo .              /*для области действия*/
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .

  run cp-attr-code in this-procedure (
                       input temp-hattr.code
                      ,output attr-type
                      ,output attr-format
                      ,output attr-label
                      ,output attr-range
                      ,output attr-user-can-edit
                      ,output attr-output-display
                      ,output attr-other ) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    {&cpattr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "display" then do:
    v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U).
    run value(v-run-name) in this-procedure (
                                             input p-cdpay-code
                                            ,INPUT p-curr-code
                                            ,input temp-hattr.code
                                            ,input temp-hattr.attr-value
                                            ,input p-host-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                             )
                                             no-error .
    if error-status:error then undo, return error .
    return .
  end.
END.
message
"Расширенный просмотр ДАННОГО атрибута НЕ ПРЕДУСМОТРЕН!"
view-as alert-box Warning.
BELL.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-cp-attr-exist Dialog-Frame
PROCEDURE temp-cp-attr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .

    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-version        as decimal   no-undo .

    run cp-attr-code in this-procedure (
                                        input  p-code           /* p-code           */
                                        ,output v-type           /* p-type           */
                                        ,output v-format         /* p-format         */
                                        ,output v-label          /* p-label          */
                                        ,output v-range          /* p-range          */
                                        ,output v-user-can-edit  /* p-user-can-edit  */
                                        ,output v-output-display /* p-output-display */
                                        ,output v-other          /* p-other          */
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.cdpay-code = p-cdpay-code
        and buf_temp-hattr.curr-code  = p-curr-code
        and buf_temp-hattr.host-code  = p-host-code
        and buf_temp-hattr.obj-type   = (if v-version = 14.0 then '':U else p-obj-type)
        and (v-version = 14.0 or buf_temp-hattr.obj-code   = p-obj-code)
        and buf_temp-hattr.attr-code = p-code
      no-error .

    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME