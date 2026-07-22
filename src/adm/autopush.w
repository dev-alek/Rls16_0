&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME autopush
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS autopush
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматические задани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматические задания".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ adm/push-m.i   }
{ adm/autotask.i DEFINE }
{ gbl/color.i }
{ cmp/library.i  }
{ ref/shd-attr.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define buffer buf_db for ub.db .

define variable log-exit   as logical   no-undo .
define variable v-par-val  as character no-undo .
define variable v-par-type as character no-undo .
define variable par-is-bge as logical   no-undo .
define variable par-is-edi as character no-undo .
define variable par-type   as character no-undo .
define variable is-edi as logical   no-undo .
define variable line-row   as rowid     no-undo .

define variable v-c-date as date      no-undo .
define variable v-c-time as integer   no-undo .
DEFINE VARIABLE v-start AS LOGICAL NO-UNDO INIT YES.
DEFINE BUFFER buf_temp-autotask FOR temp-autotask.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME autopush
&Scoped-define BROWSE-NAME BR-autotask

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-autotask buf_db

/* Definitions for BROWSE BR-autotask                                   */
&Scoped-define FIELDS-IN-QUERY-BR-autotask temp-autotask.task-name temp-autotask.date-time temp-autotask.overtime temp-autotask.corr NO-LABEL
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-autotask
&Scoped-define SELF-NAME BR-autotask
&Scoped-define QUERY-STRING-BR-autotask FOR EACH temp-autotask
&Scoped-define OPEN-QUERY-BR-autotask OPEN QUERY {&SELF-NAME} FOR EACH temp-autotask.
&Scoped-define TABLES-IN-QUERY-BR-autotask temp-autotask
&Scoped-define FIRST-TABLE-IN-QUERY-BR-autotask temp-autotask


/* Definitions for BROWSE db-list                                       */
&Scoped-define FIELDS-IN-QUERY-db-list buf_db.db-num buf_db.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-db-list
&Scoped-define SELF-NAME db-list
&Scoped-define QUERY-STRING-db-list FOR EACH buf_db NO-LOCK
&Scoped-define OPEN-QUERY-db-list OPEN QUERY {&SELF-NAME} FOR EACH buf_db NO-LOCK.
&Scoped-define TABLES-IN-QUERY-db-list buf_db
&Scoped-define FIRST-TABLE-IN-QUERY-db-list buf_db


/* Definitions for DIALOG-BOX autopush                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-autopush ~
    ~{&OPEN-QUERY-BR-autotask}~
    ~{&OPEN-QUERY-db-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-not-send b-do-now b-help i-exit ~
db-list BR-autotask

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-do-now DEFAULT
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1 TOOLTIP "Выполнить задание без учета расписания".

DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON b-not-send DEFAULT
     LABEL "Новости: Нет &подтверждений"
     SIZE 28 BY 1 TOOLTIP "Просмотр неотправленной и неподтвержденний информации".

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-autotask FOR
      temp-autotask SCROLLING.

DEFINE QUERY db-list FOR
      buf_db SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-autotask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-autotask autopush _FREEFORM
  QUERY BR-autotask DISPLAY
      temp-autotask.task-name FORMAT "X(18)" COLUMN-LABEL "Тип задания"
temp-autotask.date-time FORMAT "X(16)" COLUMN-LABEL "Очередной сеанс"
temp-autotask.overtime FORMAT "#/" COLUMN-LABEL "Не вып"
temp-autotask.corr FORMAT "X(3)" NO-LABEL
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52 BY 21.13 FIT-LAST-COLUMN.

DEFINE BROWSE db-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS db-list autopush _FREEFORM
  QUERY db-list DISPLAY
      buf_db.db-num
buf_db.db-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46 BY 21.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME autopush
     b-exit AT ROW 1 COL 1
     b-not-send AT ROW 1 COL 15
     b-do-now AT ROW 1 COL 47
     b-help AT ROW 1 COL 89
     i-exit AT ROW 1.13 COL 47.13 WIDGET-ID 4
     db-list AT ROW 2 COL 1
     BR-autotask AT ROW 2 COL 47
     SPACE(0.09) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Автоматические задания"
         CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX autopush
   FRAME-NAME                                                           */
/* BROWSE-TAB db-list i-exit autopush */
/* BROWSE-TAB BR-autotask db-list autopush */
ASSIGN
       FRAME autopush:SCROLLABLE       = FALSE
       FRAME autopush:HIDDEN           = TRUE.

ASSIGN
       BR-autotask:HIDDEN  IN FRAME autopush                = TRUE.

ASSIGN
       db-list:HIDDEN  IN FRAME autopush                = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-autotask
/* Query rebuild information for BROWSE BR-autotask
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-autotask.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-autotask */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE db-list
/* Query rebuild information for BROWSE db-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_db NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE db-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME autopush
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL autopush autopush
ON WINDOW-CLOSE OF FRAME autopush /* Автоматические задания */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-do-now
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-do-now autopush
ON CHOOSE OF b-do-now IN FRAME autopush /* _ Выполнить */
DO:
  DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl.
  if not available buf_db then do:
    message "Не выбрана база данных"
      view-as alert-box error.
    return no-apply.
  end.
  if not available temp-autotask then do:
    message "Не выбрано автоматическое задание"
      view-as alert-box error.
    return no-apply.
  end.
  IF temp-autotask.task-type = {&btpr-type-autonws}  THEN DO:
      find first buf_sys-ctrl no-lock.

      if buf_sys-ctrl.db-num <> 0
        and buf_db.db-num <> 0
      then do:
        message "Обмен новостями возможен только с БД 0 !"
          view-as alert-box error.
        return no-apply.
      end.

      if buf_sys-ctrl.db-num = buf_db.db-num then do:
        message "Обмен новостями с текущей БД невозможен!"
          view-as alert-box error.
        return no-apply.
      end.
  END.

  run write-new-bp in this-procedure
    ( input temp-autotask.task-type
     ,input buf_db.db-num
    ) no-error.
  if error-status :error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit autopush
ON CHOOSE OF b-exit IN FRAME autopush /* Выход */
DO:
  assign
    log-exit = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-not-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-not-send autopush
ON CHOOSE OF b-not-send IN FRAME autopush /* Новости: Нет подтверждений */
DO:
  IF NOT AVAILABLE buf_db THEN DO:
    message "Не выбрана база данных"
    view-as alert-box error.
    return no-apply.
  END.
  run nws/v-route.w
    ( input parparentproc
    , input buf_db.db-num
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-autotask
&Scoped-define SELF-NAME BR-autotask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-autotask autopush
ON ROW-DISPLAY OF BR-autotask IN FRAME autopush
DO:
  IF AVAIL temp-autotask THEN DO:
    RUN set-row-color.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME db-list
&Scoped-define SELF-NAME db-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL db-list autopush
ON VALUE-CHANGED OF db-list IN FRAME autopush
DO:
  RUN fill-autotask IN THIS-PROCEDURE ( input buf_db.db-num).
  OPEN QUERY br-autotask FOR EACH temp-autotask NO-LOCK WHERE
                                  temp-autotask.db-num = buf_db.db-num.
  reposition BR-autotask to rowid line-row no-error .                               
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-autotask
&Scoped-define SELF-NAME br-autotask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-autotask autopush
ON VALUE-CHANGED OF br-autotask IN FRAME autopush
DO:
  if available temp-autotask
  then
  line-row = rowid(temp-autotask) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BR-autotask
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK autopush


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  define buffer buf_BatchProcess   for ub.BatchProcess .
  define buffer buf-c_BatchProcess for ub.BatchProcess .

  assign
    log-exit = false
  .

  RUN enable_UI.
  APPLY "value-changed" TO BROWSE db-list.
  assign
    par-is-bge = TRUE
  .
  { gbl/conf-rd.i "'is-bge'" "''" "''" 0 "''" "''" "''" yes v-par-val v-par-type no-error }
  if error-status:error
     or v-par-type <> "L":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра is-bge!"
      view-as alert-box error.
    return error .
  end.
  if v-par-val <> "yes" then do:
    assign
      par-is-bge = FALSE
    .
  end.

{ gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" yes par-is-edi par-type }
  assign
      is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .

  for each buf_temp-autotask:
    delete buf_temp-autotask.
  end.



  do while not log-exit
  on error undo, return error
  :
    wait-for
      go of frame {&frame-name}
      or close of this-procedure
      or value-changed of db-list in frame {&frame-name}
      or choose of b-do-now in frame {&frame-name}
      focus frame {&frame-name}
      pause 1
    .

    IF v-start THEN DO:
        v-start = NO.
        ENABLE
        db-list
        br-autotask
        WITH FRAME {&FRAME-NAME}.
        APPLY "value-changed" TO BROWSE db-list.
    END.
    else do:
      APPLY "value-changed" TO BROWSE db-list.
    end.
  end.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI autopush  _DEFAULT-DISABLE
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
  HIDE FRAME autopush.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI autopush  _DEFAULT-ENABLE
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
  ENABLE b-exit b-not-send b-do-now b-help i-exit db-list BR-autotask
      WITH FRAME autopush.
  VIEW FRAME autopush.
  {&OPEN-BROWSERS-IN-QUERY-autopush}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-autotask autopush
PROCEDURE fill-autotask :
define input parameter p-db-num as integer no-undo .
   run cur-time in this-procedure
      ( output v-c-date
       ,output v-c-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      return error.
    end.
for each buf_temp-autotask :
  delete buf_temp-autotask.
end.
if (p-db-num = 0
and v-cntxt-db-num > 0)
or (p-db-num > 0
and v-cntxt-db-num = 0)
then do:
    { adm/autotask.i ASSIGN {&btpr-type-autonws} }
end.
    { adm/autotask.i ASSIGN {&btpr-type-autoarh} }

    { adm/autotask.i ASSIGN {&btpr-type-mercury} }
    
    { adm/autotask.i ASSIGN {&btpr-type-hddtest} }

    { adm/autotask.i ASSIGN {&btpr-type-is_motp} }

    { adm/autotask.i ASSIGN {&btpr-type-is_diadoc} }

    if par-is-bge = true then do:
     { adm/autotask.i ASSIGN {&btpr-type-autoexp} }
    END.
if p-db-num = v-cntxt-db-num then do:
    { adm/autotask.i ASSIGN {&btpr-type-autooxml} }

    { adm/autotask.i ASSIGN {&btpr-type-autogetcd} }

    { adm/autotask.i ASSIGN {&btpr-type-autosale} }
    
    { adm/autotask.i ASSIGN {&btpr-type-is_PM} }
end.

    { adm/autotask.i ASSIGN {&btpr-type-autosuz} }

  if p-db-num = 0 then do:
    { adm/autotask.i ASSIGN {&btpr-type-autocbnk} }
  end.
    { adm/autotask.i ASSIGN {&btpr-type-autofree} }

    IF NOT v-start THEN DO:
        br-autotask:REFRESH() IN FRAME {&FRAME-NAME}.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color autopush
PROCEDURE set-row-color :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable iFGColor AS INTEGER NO-UNDO.
  define variable iBGColor AS INTEGER NO-UNDO.

  IF temp-autotask.overtime THEN DO:
      ASSIGN
        iFGColor = RED_COLOR
        iBGColor = WHITE_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.

    ASSIGN
      temp-autotask.date-time:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      temp-autotask.date-time:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-new-bp autopush
PROCEDURE write-new-bp :
define input parameter p-task-type as   character    no-undo .
  define input parameter p-db-num    like ub.db.db-num no-undo .

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      "Недопустимо вызывать процедуру из транзакции!" skip
      view-as alert-box error .
  end.

  block_bp:
  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .
    define buffer buf_sys-ctrl     for ub.sys-ctrl .

    define variable v-curr-date as date      no-undo .
    define variable v-curr-time as integer   no-undo .
    define variable v-date      as date      no-undo .
    define variable v-time      as integer   no-undo .

    define variable v-log       as logical   no-undo .

    define variable v-cancel    as logical   no-undo .
    define variable v-msg       as character no-undo .

    define variable v-str       as character no-undo .

    do for buf_BatchProcess
    on error undo, return error return-value
    :
      find first buf_sys-ctrl no-lock .
      find first buf_BatchProcess
        where buf_BatchProcess.BP_Status   = {&btpr-normal}
          and buf_BatchProcess.BP_Type     = p-task-type
          and buf_BatchProcess.CharKey_One = string( p-db-num )
          and buf_BatchProcess.CharKey_Two = "manual":U
        no-error
      .
      if available buf_BatchProcess then do:
        message "Изменение времени запуска уже производилось." skip
                "Установлено:" string( buf_BatchProcess.BP_ExecSysDate, "99.99.9999") buf_BatchProcess.BP_ExecSysTime skip
                "Вы действительно хотите его изменить?"
                view-as alert-box question buttons yes-no update v-log.
      end.
      else do:
        assign
          v-log = true
        .
      end.
    end.
    if v-log = false then do:
      assign
        v-msg = "Время очередного сеанса не изменено!"
      .
      undo, leave block_bp.
    end.

    assign
      v-str = get-str-type( p-task-type )
    .
    if v-str = ? then do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" p-task-type
        view-as alert-box error.
      return error.
    end.
    case p-task-type :
      when {&btpr-type-autoarh}
      then do:
        run adm/arc-shdp.w
          (input  buf_sys-ctrl.db-num /* p-cre-db-num */
          ,input  p-task-type         /* p-task-type  */
          ,input  -1                  /* p-task-num   */
          ,output v-cancel            /* p-cancel     */
          ) no-error .
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = true
        then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when {&btpr-type-autoexp}
      then do:
        run bge/bge-shdp.w
          (input  parparentproc
          ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
          ,input  p-task-type         /* p-task-type  */
          ,input  -1                  /* p-task-num   */
          ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when {&btpr-type-autogetcd}
      then do:
        run str/gcd-shdp.w
          ( input  parparentproc
           ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
           ,input  p-task-type         /* p-task-type  */
           ,input  -1                  /* p-task-num   */
           ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when {&btpr-type-autosale}
      then do:
        run str/sal-shdp.w
          ( input parparentproc
           ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
           ,input  p-task-type         /* p-task-type  */
           ,input  -1                  /* p-task-num   */
           ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.

      when {&btpr-type-autosuz}
      then do:
         
        run str/suz-shdp.w
          (input parparentproc
          ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
          ,input  p-task-type         /* p-task-type  */
          ,input  -1                  /* p-task-num   */
          ,output v-cancel           /* p-cancel      */
          ) no-error .
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        
/*        message                                                                              */
/*        "К сожалению, невозможно изменить время запуска отчетов по расписанию таким способом"*/
/*        view-as alert-box error .                                                            */
/*        v-cancel = yes.                                                                      */
        if v-cancel = true
        then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when {&btpr-type-autocbnk}
      then do:
          define variable v-params        as character    no-undo.
          define variable v-object-list        as character    no-undo.
          define variable v-doc-type-list      as character    no-undo.
          define variable v-hsch-list          as character    no-undo.
          define variable v-csch-list          as character    no-undo.
          define variable v-date-list          as character    no-undo.

        run bge/clb-shdp.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input 'shd':U
                        ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
                        ,input  p-task-type         /* p-task-type  */
                        ,input  -1                  /* p-task-num   */
                        ,input ?
                        ,output v-cancel
                        ,output v-params
                        ,output v-object-list
                        ,output v-doc-type-list
                        ,output v-date-list
                        ,output v-hsch-list
                        ,output v-csch-list
                      ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when {&btpr-type-is_PM}
      then do:
        run adm/isPM-shdp.w
          (input  buf_sys-ctrl.db-num
          ,input  p-task-type
          ,input  -1
          ,output v-cancel
          ) no-error.
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end .
      when {&btpr-type-autofree}
      then do:
        define variable v-free-id as character no-undo .
        define variable v-value as character no-undo .
        define buffer buf_schedule-attr for ub.schedule-attr.
        run adm/freeshdp.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input 'shd':U
                        ,input  buf_sys-ctrl.db-num /* p-cre-db-num */
                        ,input  p-task-type         /* p-task-type  */
                        ,input  -1                  /* p-task-num   */
                        ,input ?
                        ,input-output v-free-id /*p-free-id*/
                        ,output v-cancel
                        ,output v-params
                      ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.

        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
        else do:
          /*запишем атрибут типа*/
          run schedule-attr-get-free-props in this-procedure (input v-free-id, output v-value).
          /*получим свойства*/
          do transaction
          on error undo, return error return-value
          :
            for each buf_schedule-attr where
                    buf_schedule-attr.cre-db-num = buf_sys-ctrl.db-num
                AND buf_schedule-attr.task-type = p-task-type
                AND buf_schedule-attr.task-num = - 1
                and buf_schedule-attr.attr-code begins {&attr-schd-free-id} + {&delim-par}
            on error undo, return error error-status:get-message(1) :
              delete buf_schedule-attr.
            end.
          end.
          run schedule-attr-write in this-procedure (
                                                       input string(p-db-num)
                                                      ,input p-task-type
                                                      ,input - 1
                                                      ,input ({&attr-schd-free-id} + {&delim-par} + v-free-id)
                                                      ,input v-value ).
        end.
      end.
    end.
    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      return error.
    end.

    assign
      v-date = v-curr-date
      v-time = v-curr-time
    .

    block_ed:
    do while true
    on error undo, return error
    :
      run adm/d-ed-d-t.w ( input-output v-date
                      ,input-output v-time
                    ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
          "Ошибка при редактировании даты!"
          view-as alert-box error.
        return error.
      end.
      if v-date = ?
        or v-time = ?
      then do:
        assign
          v-msg = "Время очередного сеанса не изменено!"
        .
        undo, leave block_bp.
      end.
      if v-date > v-curr-date
        or ( v-date = v-curr-date
             and v-time >= v-curr-time
           )
      then do:
/*        assign*/
/*          v-curr-date = v-date*/
/*          v-curr-time = v-time*/
/*        .*/
        leave block_ed.
      end.
      else do:
        message "Время очередного сеанса не может быть меньше текущего!"
          view-as alert-box error.
      end.
    end.

    run push-abtpr in this-procedure
      ( input parparentproc
       ,input p-db-num
       ,input p-task-type
       ,input "manual":U
       ,input v-date
       ,input v-time
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при записи времени внеочередного запуска!" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      return error.
    end.

    assign
      v-msg = substitute( "Команда на запуск &1 для БД &2 отправлена", v-str, p-db-num )
              + {&new-line} + "и должна быть обработана в течении минуты."
    .

  end.

  if v-msg <> "":U then do:
    message v-msg
      view-as alert-box information.
  end.
  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME