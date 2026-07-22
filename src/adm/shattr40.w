&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE BUFFER X_shop FOR shop.
DEFINE BUFFER X_store FOR store.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "staff-options"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/23/10
Author: Bakhtadze Natalya
Creation date: 07/23/10

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'staff-options'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }
{ cmp/trg-def.i }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-tth as handle no-undo .
define variable v-t-shft as integer no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-noanshftstaff ~
t-obyznumbukv t-obyznumbukvAdm t-minparol t-minparolAdm t-TimeAvail ~
t-TimeAvailAdm t-TimeBlock t-TimeBlockAdm t-LastPaswd t-LastPaswdAdm 
&Scoped-Define DISPLAYED-OBJECTS t-noanshftstaff t-obyznumbukv ~
t-obyznumbukvAdm t-minparol t-minparolAdm t-TimeAvail t-TimeAvailAdm ~
t-TimeBlock t-TimeBlockAdm t-LastPaswd t-LastPaswdAdm 

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
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE t-LastPaswd AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Количество старых паролей с которыми не должен совпадать новый пароль" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-LastPaswdAdm AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-minparol AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Минимальная длина пароля" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-minparolAdm AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-TimeAvail AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Время жизни пароля" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-TimeAvailAdm AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-TimeBlock AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Время до блокировки пользователя после окончания действия пароля" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-TimeBlockAdm AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY .79 NO-UNDO.

DEFINE VARIABLE t-noanshftstaff AS LOGICAL INITIAL no 
     LABEL "Запрет на ввод произвольных данных при вводе персонала смены" 
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-obyznumbukv AS LOGICAL INITIAL no 
     LABEL "Обязательное сочетание цифровых и буквенных символов" 
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-obyznumbukvAdm AS LOGICAL INITIAL no 
     LABEL "Обязательное сочетание цифровых и буквенных символов (АДМ)" 
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-noanshftstaff AT ROW 2.17 COL 4
     t-obyznumbukv AT ROW 3.08 COL 4
     t-obyznumbukvAdm AT ROW 4.08 COL 4 WIDGET-ID 14
     t-minparol AT ROW 6.5 COL 72.5 COLON-ALIGNED WIDGET-ID 4
     t-minparolAdm AT ROW 6.5 COL 85.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     t-TimeAvail AT ROW 7.5 COL 72.5 COLON-ALIGNED WIDGET-ID 6
     t-TimeAvailAdm AT ROW 7.5 COL 85.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     t-TimeBlock AT ROW 8.5 COL 72.5 COLON-ALIGNED WIDGET-ID 8
     t-TimeBlockAdm AT ROW 8.5 COL 85.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     t-LastPaswd AT ROW 9.5 COL 72.5 COLON-ALIGNED WIDGET-ID 10
     t-LastPaswdAdm AT ROW 9.5 COL 85.5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     "Пользователь" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 5.5 COL 72 WIDGET-ID 12
     "Администратор" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 5.5 COL 85 WIDGET-ID 24
     SPACE(0.24) SKIP(4.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры работы с пользователями и персоналом"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_store B "?" ? ub store
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры работы с пользователями и персоналом */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-noanshftstaff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-noanshftstaff Dialog-Frame
ON VALUE-CHANGED OF t-noanshftstaff IN FRAME Dialog-Frame /* Запрет на ввод произвольных данных при вводе персонала смены */
DO:
    ASSIGN
  t-noanshftstaff.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-obyznumbukv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-obyznumbukv Dialog-Frame
ON VALUE-CHANGED OF t-obyznumbukv IN FRAME Dialog-Frame /* Обязательное сочетание цифровых и буквенных символов */
DO:
    ASSIGN
  t-obyznumbukv.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-TimeAvail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-TimeAvail Dialog-Frame
ON leave OF t-TimeAvail IN FRAME Dialog-Frame /* Время жизни пароля */
DO:
   if integer(t-TimeAvail:screen-value in frame {&frame-name}) > 60 then do:
      message "Время жизни пароля не должно превышать 60 дней"
      view-as alert-box.
      return no-apply .
   end.
/*   if integer(t-TimeAvail:screen-value in frame {&frame-name}) < 1 then do:*/
/*      message "Время жизни пароля должно превышать 1 день"                 */
/*      view-as alert-box.                                                   */
/*      return no-apply .                                                    */
/*   end.                                                                    */
    ASSIGN
  t-TimeAvail.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-TimeBlock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-TimeBlock Dialog-Frame
ON leave OF t-TimeBlock IN FRAME Dialog-Frame /* Время до блокировки пользователя после окончания действия пароля */
DO:
   if integer(t-TimeBlock:screen-value in frame {&frame-name}) > 120 then do:
      message "Время до блокировки пользователя после окончания действия пароля не должно превышать 120 дней"
      view-as alert-box.
      return no-apply .
   end.
   if integer(t-TimeBlock:screen-value in frame {&frame-name}) < 30 and integer(t-TimeBlock:screen-value in frame {&frame-name}) <> 0 then do:
      message "Время до блокировки пользователя после окончания действия пароля должно быть больше 30 дней"
      view-as alert-box.
      return no-apply .
   end.   
    ASSIGN
  t-TimeBlock.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-TimeBlockAdm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-TimeBlockAdm Dialog-Frame
ON leave OF t-TimeBlockAdm IN FRAME Dialog-Frame /* Время до блокировки пользователя после окончания действия пароля */
DO:
   if integer(t-TimeBlockAdm:screen-value in frame {&frame-name}) > 120 then do:
      message "Время до блокировки пользователя после окончания действия пароля не должно превышать 120 дней"
      view-as alert-box.
      return no-apply .
   end.
   if integer(t-TimeBlockAdm:screen-value in frame {&frame-name}) < 30 and integer(t-TimeBlockAdm:screen-value in frame {&frame-name}) <> 0 then do:
      message "Время до блокировки пользователя после окончания действия пароля должно быть больше 30 дней"
      view-as alert-box.
      return no-apply .
   end.   
    ASSIGN
  t-TimeBlockAdm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-TimeAvailAdm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-TimeAvailAdm Dialog-Frame
ON leave OF t-TimeAvailAdm IN FRAME Dialog-Frame /* Время жизни пароля (АДМ) */
DO:
   if integer(t-TimeAvailAdm:screen-value in frame {&frame-name}) > 60 then do:
      message "Время жизни пароля не должно превышать 60 дней"
      view-as alert-box.
      return no-apply .
   end.
/*   if integer(t-TimeAvailAdm:screen-value in frame {&frame-name}) < 1 then do:*/
/*      message "Время жизни пароля должно превышать 1 день"                    */
/*      view-as alert-box.                                                      */
/*      return no-apply .                                                       */
/*   end.                                                                       */
    ASSIGN
  t-TimeAvailAdm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-obyznumbukvAdm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-obyznumbukvAdm Dialog-Frame
ON VALUE-CHANGED OF t-obyznumbukvAdm IN FRAME Dialog-Frame /* Обязательное сочетание цифровых и буквенных символов (АДМ) */
DO:
    ASSIGN
  t-obyznumbukv.
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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  and p-obj-type <> {&stock}
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
  end.
  if p-obj-type = {&stock} then do:
    FIND FIRST X_store NO-LOCK WHERE X_store.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_store THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&stock~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры склада в чужой БД" skip
        "склад принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-staff-options}
        and locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-staff-options}
    and   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable in this-procedure .
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
  DISPLAY t-noanshftstaff t-obyznumbukv t-obyznumbukvAdm t-minparol 
          t-minparolAdm t-TimeAvail t-TimeAvailAdm t-TimeBlock t-TimeBlockAdm 
          t-LastPaswd t-LastPaswdAdm 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-noanshftstaff t-obyznumbukv t-obyznumbukvAdm 
         t-minparol t-minparolAdm t-TimeAvail t-TimeAvailAdm t-TimeBlock 
         t-TimeBlockAdm t-LastPaswd t-LastPaswdAdm 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop-time AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-staff-options}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
&glob propVal IF v-entry = "~{&propCode~}" THEN DO: ~
    assign ~
    t-~{&propCode~} = thbjattr_thbj-attr.property-value-~{&propType~} ~
    t-~{&propCode~}:private-data in frame ~{&frame-name~} = "recid=" + string(recid(thbjattr_thbj-attr)) ~
    . ~
  END.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  
  &glob propType logical
  
  &glob propcode {&bef-attr-staff-options_noanshftstaff}
  {&propVal}
  
  &glob propcode {&bef-attr-staff-options_obyznumbukv}
  {&propVal}
  &glob propcode {&bef-attr-staff-options_obyznumbukv}Adm
  {&propVal}
  
  &glob propType integer
  &glob propcode {&bef-attr-staff-options_minparol}
  {&propVal}
  &glob propcode {&bef-attr-staff-options_minparol}Adm
  {&propVal}
  
  &glob propcode {&bef-attr-staff-options_TimeAvail}
  {&propVal}
  &glob propcode {&bef-attr-staff-options_TimeAvail}Adm
  {&propVal}
  
  &glob propcode {&bef-attr-staff-options_TimeBlock}
  {&propVal}
  &glob propcode {&bef-attr-staff-options_TimeBlock}Adm
  {&propVal}
  
  &glob propcode {&bef-attr-staff-options_LastPaswd}
  {&propVal}
  &glob propcode {&bef-attr-staff-options_LastPaswd}Adm
  {&propVal}
  
  
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
/*v-tab-order = "t-noanshftstaff, t-obyznumbukv, t-minparol"*/
.
    IF p-obj-type = '' and p-obj-code = 0 THEN DO:
       define variable VsuperAdm as logical no-undo.
       find first user-account-attr where user-account-attr.user-id    eq g#userid
                                   and user-account-attr.attr-code  eq "superadm"
       no-lock no-error.
       VsuperAdm = available user-account-attr and logical(user-account-attr.attr-value) eq yes no-error.
        display 
        t-noanshftstaff t-obyznumbukv t-minparol t-obyznumbukvAdm t-minparolADm t-TimeAvail t-TimeBlock t-LastPaswd t-TimeAvailAdm t-TimeBlockAdm t-LastPaswdAdm
        WITH FRAME {&frame-name}.
        ENABLE
        B-exit WHEN p-mode = {&UPDATE}
        b-quit
        B-Help
        t-noanshftstaff    WHEN p-mode = {&UPDATE}
        t-obyznumbukv      WHEN p-mode = {&UPDATE}
        t-minparol         WHEN p-mode = {&UPDATE}
        t-TimeAvail        WHEN p-mode = {&UPDATE}
        t-TimeBlock        WHEN p-mode = {&UPDATE} 
        t-LastPaswd        WHEN p-mode = {&UPDATE}
        t-obyznumbukvAdm   WHEN p-mode = {&UPDATE} and VsuperAdm
        t-minparolAdm      WHEN p-mode = {&UPDATE} and VsuperAdm
        t-TimeAvailAdm     WHEN p-mode = {&UPDATE} and VsuperAdm
        t-TimeBlockAdm     WHEN p-mode = {&UPDATE} and VsuperAdm 
        t-LastPaswdAdm     WHEN p-mode = {&UPDATE} and VsuperAdm
        
        WITH FRAME {&frame-name}.
    END.
    ELSE DO:
        DISPLAY
        t-noanshftstaff
        WITH FRAME {&frame-name}.
        ENABLE
        B-exit WHEN p-mode = {&UPDATE}
        b-quit
        B-Help
        t-noanshftstaff WHEN p-mode = {&UPDATE}
        WITH FRAME {&frame-name}.        
    END.
    VIEW FRAME {&frame-name}.
    IF p-mode = {&LOOKUP} THEN DO:
      HIDE
      b-exit
      IN FRAME {&FRAME-NAME}.
      ASSIGN
      b-quit:LABEL = "&Выход"
      .
    END.
        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-t-shft AS integer NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
t-noanshftstaff t-obyznumbukv t-minparol t-LastPaswd t-LastPaswdAdm t-minparolAdm
t-obyznumbukvAdm t-TimeAvail t-TimeAvailAdm t-TimeBlock t-TimeBlockAdm
.

assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:

    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    if wh:sensitive
    or wh:name = "zero-cashier"
    then do:
      assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if v-same = no then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
run adm/shattri.p (
              input "check":U
             , input p-obj-type
             , input p-obj-code
             , input {&attr-staff-options}
             , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
            ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-staff-options}
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1) SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

