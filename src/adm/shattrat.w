&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME shattrat


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS shattrat 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран настроек АВТОПРОЦЕССОВ

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/09/08
Author: Dmitry Ukhanov
Creation date: 10/09/08

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-mode        AS CHARACTER           NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран настроек АВТОПРОЦЕССОВ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/color.i    }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define variable v-tth           as handle   no-undo .
define variable v-to-create     as logical  no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME shattrat

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-email-list ~
f-user-list maxColMarks 
&Scoped-Define DISPLAYED-OBJECTS f-email-list f-user-list maxColMarks ~
label-email-list label-user-list 

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-email-list AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 55 BY 5 DROP-TARGET NO-UNDO.

DEFINE VARIABLE f-user-list AS CHARACTER FORMAT "x(8)" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE label-email-list AS CHARACTER FORMAT "X(256)":U INITIAL "Список email для отправки сообщений" 
      VIEW-AS TEXT 
     SIZE 47.5 BY .67 NO-UNDO.

DEFINE VARIABLE label-user-list AS CHARACTER FORMAT "X(256)":U INITIAL "Список логинов исключенных из проверки подключений при обновление системы" 
      VIEW-AS TEXT 
     SIZE 75 BY .67 NO-UNDO.

DEFINE VARIABLE maxColMarks AS INTEGER FORMAT "->>>>,>>>,>>9":U INITIAL 1000 
     LABEL "Максимальное количество очищаемых марок" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME shattrat
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 50 WIDGET-ID 4
     f-email-list AT ROW 3.74 COL 4.5 NO-LABEL WIDGET-ID 22
     f-user-list AT ROW 10.74 COL 2.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     maxColMarks AT ROW 11.89 COL 43.38 COLON-ALIGNED WIDGET-ID 30
     label-email-list AT ROW 2.74 COL 2.5 NO-LABEL WIDGET-ID 28
     label-user-list AT ROW 9.74 COL 2.5 NO-LABEL WIDGET-ID 28
     SPACE(0.99) SKIP(3.54)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки АВТОПРОЦЕССОВ" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX shattrat
   FRAME-NAME                                                           */
ASSIGN 
       FRAME shattrat:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN label-email-list IN FRAME shattrat
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       label-email-list:READ-ONLY IN FRAME shattrat        = TRUE.

/* SETTINGS FOR FILL-IN label-user-list IN FRAME shattrat
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       label-user-list:READ-ONLY IN FRAME shattrat        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX shattrat
/* Query rebuild information for DIALOG-BOX shattrat
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX shattrat */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME shattrat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shattrat shattrat
ON WINDOW-CLOSE OF FRAME shattrat /* Настройки АВТОПРОЦЕССОВ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit shattrat
ON CHOOSE OF B-exit IN FRAME shattrat /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK shattrat 


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

  if  p-mode <> {&lookup}
    and p-mode <> {&update}
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      view-as alert-box error.
      undo, return error.
  end.
  if p-obj-type <> {&db}
    and p-obj-type <> '':u
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      view-as alert-box error.
      undo, return error.
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

/*  if p-obj-type = {&db} then*/
/*   frame {&frame-name}:title = substitute( "&1. БД &2", frame {&frame-name}:title,  p-obj-code) .*/

  if p-mode = {&update} then do:
    find first locked_thbj-attr exclusive-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = {&attr-auto-task}
        and locked_thbj-attr.prop-code = "":u
    no-wait no-error.
    if locked locked_thbj-attr then do:
      message
        vss-workfile vss-revision vss-description skip
        "Запись ПАРАМЕТРЫ(АТРИБУТЫ) занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_thbj-attr no-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = {&attr-auto-task}
        and locked_thbj-attr.prop-code = '':u
      no-error.
  end.
  if not available locked_thbj-attr then do:
    assign
      v-to-create  = yes
    .
    message
      substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ", {&new-line} )
      view-as alert-box warning .
  end.

  assign
    v-tth = buffer thbjattr_thbj-attr:table-handle
  .

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.

  RUN enable_UI.

  if p-mode = {&lookup} then do:
    disable
      all
      with frame {&frame-name}
      .
    enable
      b-exit
      b-help
      with frame {&frame-name}
      .
     assign
       b-exit:label = "Вы&ход"
     .
     hide b-quit in frame {&frame-name} .
  end.
  if p-obj-type <> '':U then 
  do:
    hide maxColMarks  in frame {&frame-name} .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI shattrat  _DEFAULT-DISABLE
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
  HIDE FRAME shattrat.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI shattrat  _DEFAULT-ENABLE
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
  DISPLAY f-email-list f-user-list maxColMarks label-email-list label-user-list 
      WITH FRAME shattrat.
  ENABLE B-exit b-quit B-Help f-email-list f-user-list maxColMarks 
      WITH FRAME shattrat.
  {&OPEN-BROWSERS-IN-QUERY-shattrat}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets shattrat 
PROCEDURE fill-widgets :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-entry           as character  no-undo .


do
on error undo, return error return-value
:
  for each thbjattr_thbj-attr
  :
    delete thbjattr_thbj-attr .
  end.
  for each temp-thbj-attr
  :
    delete temp-thbj-attr .
  end.

  run adm/shattri.p
    ( input "init":U
    , input p-obj-type
    , input p-obj-code
    , input {&attr-auto-task}
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , INPUT-OUTPUT table-handle v-tth
    ) no-error .
  if error-status:error
    and not available locked_thbj-attr
  then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.

  for each thbjattr_thbj-attr:
    assign
      v-entry = thbjattr_thbj-attr.prop-code
    .
    case v-entry:
      when {&attr-auto-task_send-msg-to-email} then do:
        assign
          f-email-list  = thbjattr_thbj-attr.property-value-character
          f-email-list  :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-auto-task_user-list} then do:
        assign
          f-user-list  = thbjattr_thbj-attr.property-value-character
          f-user-list  :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-auto-task_maxColMarks} then do:
        assign
          maxColMarks  = thbjattr_thbj-attr.property-value-integer
          maxColMarks  :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.      

    end case.

    create temp-thbj-attr.
    buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save shattrat 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-sale-add        as character      no-undo .
define variable v-param-type      as character      no-undo .
define variable wh                as widget-handle  no-undo .
define variable fh                as widget-handle  no-undo .
define variable v-same            as logical        no-undo .

do
on error undo, return error return-value
:
  if p-mode = {&lookup} then do:
    return .
  end.

  assign
    frame {&frame-name} f-email-list
    frame {&frame-name} f-user-list
    fh = frame {&frame-name}:first-child
    wh = fh:first-child
  .

  do while valid-handle(wh):
    if wh:private-data begins "recid=" then do:
      find first thbjattr_thbj-attr
        where recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
      .
      assign
        buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      .
    end.
    wh = wh:next-sibling.
  end.

  assign
    v-same = yes
  .

  for each thbjattr_thbj-attr,
      first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
  :
    buffer-compare thbjattr_thbj-attr to temp-thbj-attr save result in v-same.
    if v-same = false then do:
      leave.
    end.
  end.

/*  if v-same = false*/
/*    and v-to-create = true*/
/*    and p-obj-type <> '':U*/
/*  then do: */
/*    message*/
/*      "вы действительно хотите сохранить набор" */
/*      view-as alert-box.*/
/*    assign*/
/*      v-same = true*/
/*    .*/
/*  end.*/

  if v-same = true
    and v-to-create = false
  then do:
    return.
  end.

  /*проверим корректность*/
  run adm/shattri.p
    ( input "check":U
    , input p-obj-type
    , input p-obj-code
    , input {&attr-auto-task}
    , INPUT '':U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .

  if error-status :error then do:
    message
      "Некорректное значение ПАРАМЕТРОВ"  skip
      error-status:get-message(1)         skip
      return-value
    view-as alert-box error .
    undo, return error .
  end.


  run thbjattr_set-section in this-procedure
    ( input p-obj-type
    , input p-obj-code
    , input {&attr-auto-task}
    , input table thbjattr_thbj-attr
    ) no-error.
  if error-status:error then do:
    message
      error-status:get-message(1)  skip
      return-value
    view-as alert-box.
    undo, return error.
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

